local tweak, gai_state, assault_data, get_value, get_mult
if Network:is_server() then
    tweak = tweak_data.group_ai.besiege.assault
    if managers.hud._hud_assault_corner.is_skirmish then
        tweak = tweak_data.group_ai.skirmish.assault
    end
    gai_state = managers.groupai:state()
    assault_data = gai_state and gai_state._task_data.assault
    get_value = gai_state._get_difficulty_dependent_value or function() return 0 end
    get_mult = gai_state._get_balancing_multiplier or function() return 0 end
end
local crimespree = managers.crime_spree and managers.crime_spree:is_active() or false
local assault_extender = false

function LocalizationManager:CSAE_Activate()
    assault_extender = true
end

local _f_CalculateSpawnsLeft = LocalizationManager.CalculateSpawnsLeft
function LocalizationManager:CalculateSpawnsLeft()
    local spawns = _f_CalculateSpawnsLeft(self)
    return gai_state._assault_number <= 2 and (spawns * 0.75) or spawns
end

function LocalizationManager:CalculateTimeLeft()
    local assault_number_sustain_t_mul
    if gai_state._assault_number <= 2 then
        assault_number_sustain_t_mul = 0.75 
    else
        assault_number_sustain_t_mul = 1
    end
    
    local add
    local time_left = assault_data.phase_end_t - gai_state._t
    if crimespree or assault_extender then
        local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), math.random()) * get_mult(gai_state, tweak.sustain_duration_balance_mul) * assault_number_sustain_t_mul
        add = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", sustain_duration) - sustain_duration
        if add == 0 and gai_state._assault_number == 1 and assault_data.phase == "build" then
            add = sustain_duration / 2 * assault_number_sustain_t_mul
        end
    end
    if assault_data.phase == "build" then
        local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), math.random()) * get_mult(gai_state, tweak.sustain_duration_balance_mul) * assault_number_sustain_t_mul
        time_left = time_left + sustain_duration + tweak.fade_duration
        if add then
            time_left = time_left + add
        end
    elseif assault_data.phase == "sustain" then
        time_left = time_left + tweak.fade_duration
        if add then
            time_left = time_left + add
        end
    end
    return self:FormatTimeLeft(time_left)
end

function HUDAssaultCorner:GetAssaultTime(sender)
    if self.is_host and self._assault and not self._assault_endless and not self._assault_vip and sender then
        local tweak = tweak_data.group_ai.besiege.assault
        if self.is_skirmish then
            tweak = tweak_data.group_ai.skirmish.assault
        end
        local gai_state = managers.groupai:state()
        local assault_data = gai_state and gai_state._task_data.assault
        local get_value = gai_state._get_difficulty_dependent_value or function() return 0 end
        local get_mult = gai_state._get_balancing_multiplier or function() return 0 end
        
        if not (tweak and gai_state and assault_data and assault_data.active) then
            return
        end

        local sustain_multiplier = 1
        if self._wave_number <= 2 then
            sustain_multiplier = 0.75
        end

        local time_left = assault_data.phase_end_t - gai_state._t
        local add
        if self.is_crimespree or self.assault_extender_modifier then
            local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), 0.5) * get_mult(gai_state, tweak.sustain_duration_balance_mul) * sustain_multiplier
            add = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", sustain_duration) - sustain_duration
            if add == 0 and self._wave_number == 1 and assault_data.phase == "build" then
                add = sustain_duration / 2 
            end
        end
        if assault_data.phase == "build" then
            local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), 0.5) * get_mult(gai_state, tweak.sustain_duration_balance_mul) * sustain_multiplier
            time_left = time_left + sustain_duration + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        elseif assault_data.phase == "sustain" then
            time_left = time_left + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        end
        LuaNetworking:SendToPeer(sender, BAI.AAI_SyncMessage, time_left)
    end
end

local _f_CalculateValueFromDiff = HUDAssaultCorner.CalculateValueFromDiff
function HUDAssaultCorner:CalculateValueFromDiff()
    local sustain = _f_CalculateValueFromDiff(self)
    local sustain_multiplier = 1
    if self._wave_number <= 2 then
        sustain_multiplier = 0.75
    end
    return sustain * sustain_multiplier, sustain_multiplier
end

local _f_CalculateSpawnsFromDiff = HUDAssaultCorner.CalculateSpawnsFromDiff
function HUDAssaultCorner:CalculateSpawnsFromDiff()
    local spawns = _f_CalculateSpawnsFromDiff(self)
    return self._wave_number <= 2 and (spawns * 0.75) or spawns
end

function HUDAssaultCorner:SetTimer()
    if self.is_host then
        return
    end
    self:SetSpawns()
    if self.is_skirmish then
        self.client_time_left = TimerManager:game():time() + self:CalculateSkirmishTime()
    else
        local sustain, sustain_multiplier = self:CalculateValueFromDiff()
        self.client_time_left = TimerManager:game():time() + self:CalculateAssaultTime() + sustain
        if self.assault_extender_modifier then
            self.client_time_left = self.client_time_left + (sustain / 2 * sustain_multiplier)
        end
    end
end