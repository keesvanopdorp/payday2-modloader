-- Original code written by Kamikaze94. For original code, go see WolfHUD (WolfHUD/lua/AdvAssault.lua)
-- "Fixed" and improved by me
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
local crimespree = managers.crime_spree:is_active()
local assault_extender = false
local spacer = string.rep(" ", 10)
local sep = string.format("%s%s%s", spacer, managers.localization:text("hud_assault_end_line"), spacer)

--[[local enemies_defeated_time_limit = 30
local drama_engagement_time_limit = 60
if managers.hud._hud_assault_corner.is_skirmish then
    enemies_defeated_time_limit = 0
    drama_engagement_time_limit = 0
end
local additional_time
local first_pass
local second_pass]]

local text_original = LocalizationManager.text
function LocalizationManager:text(string_id, macros)
    return string_id == "hud_advanced_info" and self:HUDAdvancedInfo() or text_original(self, string_id, macros)
end

function LocalizationManager:SetVariables(client)
    self.show_spawns_left = BAI.settings.advanced_assault_info.show_spawns_left
    self.spawn_numbers = BAI.settings.advanced_assault_info.spawn_numbers
    self.show_time_left = BAI.settings.advanced_assault_info.show_time_left
    self.time_left_format = BAI.settings.advanced_assault_info.time_format
    self.is_client = client
end

function LocalizationManager:CSAE_Activate()
    assault_extender = true
end

function LocalizationManager:CalculateSpawnsLeft() -- For better overriding when other mods change spawn calculation
    if tweak and gai_state and assault_data and assault_data.active then
        return get_value(gai_state, tweak.force_pool) * get_mult(gai_state, tweak.force_pool_balance_mul) - assault_data.force_spawned
    end
    return 0
end

function LocalizationManager:CalculateSpawnsLeftClient() -- For better overriding when other mods change spawn calculation
    return get_value(gai_state, tweak.force_pool) * get_mult(gai_state, tweak.force_pool_balance_mul) - assault_data.force_spawned
end

function LocalizationManager:CalculateTimeLeft() -- For better overriding when other mods change assault time left calculation
    if tweak and gai_state and assault_data and assault_data.active then
        local add
        local time_left
        time_left = assault_data.phase_end_t - gai_state._t
        if crimespree or assault_extender then
            local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), math.random()) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
            add = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", sustain_duration) - sustain_duration
            if add == 0 and gai_state._assault_number == 1 and assault_data.phase == "build" then
                add = sustain_duration / 2
            end
        end
        if assault_data.phase == "build" then
            local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), math.random()) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
            time_left = time_left + sustain_duration + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        elseif assault_data.phase == "sustain" then
            time_left = time_left + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        --[[elseif assault_data.phase == "fade" then
            if time_left < 0 then -- What the hell is this?
                local nr_enemies = gai_state:_count_police_force(gai_state, "assault")
                local too_long = gai_state._t > assault_data.phase_end_t + enemies_defeated_time_limit
                if nr_enemies <= 10 or too_long then
                    local drama_pass = gai_state._drama_data.amount < tweak_data.drama.assault_fade_end
					local engagement_pass = gai_state:_count_criminals_engaged_force(gai_state, 11) <= 10
                    local taking_too_long = gai_state._t > assault_data.phase_end_t + drama_engagement_time_limit
                    if drama_pass and engagement_pass or taking_too_long then
                        additional_time = nil
                        first_pass = false
                        second_pass = false
                        self:FormatTimeLeft(-1)
                    else
                        if not additional_time then
                            first_pass = true
                            second_pass = true
                            additional_time = gai_state._t + drama_engagement_time_limit
                        end
                        if first_pass and not second_pass then
                            second_pass = true
                            additional_time = additional_time + drama_engagement_time_limit - enemies_defeated_time_limit
                        end
                        return "+" .. self:FormatTimeLeft(additional_time - gai_state._t)
                    end
                end
                if not additional_time then
                    first_pass = true
                    additional_time = gai_state._t + enemies_defeated_time_limit
                end
                return "+" .. self:FormatTimeLeft(additional_time - gai_state._t)
            end]]
        end
        return self:FormatTimeLeft(time_left)
    end
    --additional_time = nil
    --first_pass = false
    --second_pass = false
    return self:FormatTimeLeft(-1)
end

function LocalizationManager:FormatTimeLeft(time_left) -- Code optimization purposes
    if time_left < 0 then
        time_left = self:text("hud_overdue")
    else
        if self.time_left_format == 1 or self.time_left_format == 2 then
            time_left = string.format("%.2f", time_left)
            if self.time_left_format == 2 then
                time_left = time_left .. " " .. self:text("hud_s")
            end
        elseif self.time_left_format == 3 or self.time_left_format == 4 then
            time_left = string.format("%.0f", time_left)
            if self.time_left_format == 4 then
                time_left = time_left .. "  " .. self:text("hud_s")
            end
        else
            local min = math.floor(time_left / 60)
            local s = math.floor(time_left % 60)
            if s >= 60 then
                s = s - 60
                min = min + 1
            end
            if self.time_left_format == 5 then
                time_left = string.format("%.0f%s%s%s%.0f%s%s", min, " ", self:text("hud_min"), "  ", s, " ", self:text("hud_s"))
            else
                time_left = string.format("%.0f%s%s", min, ":", (s <= 9 and "0" .. s or s))
            end
        end
    end
    return time_left
end

function LocalizationManager:HUDAdvancedInfo()
    if tweak and gai_state and assault_data and assault_data.active then
        local s = nil

        if self.show_spawns_left then
            local spawns_left
            if self.spawn_numbers == 1 then
                spawns_left = self:text("hud_spawns_left") .. " " .. math.round(math.max(self:CalculateSpawnsLeft(), 0))
            else
                spawns_left = self:text("hud_spawns_left") .. " " .. managers.enemy:GetNumberOfEnemies()
            end
            s = string.format("%s", spawns_left)
        end

        if self.show_time_left then
            local time_left = self:text("hud_time_left") .. " " .. self:CalculateTimeLeft()

            if s then
                s = string.format("%s%s%s", s, sep, time_left)
            else
                s = string.format("%s", time_left)
            end
        end

        if s then
            return s
        end
        return self:text("hud_time_left") .. " " .. self:text("hud_overdue")
    end

    if self.is_client then
        local s = nil

        if self.show_spawns_left then
            local spawns_left
            if self.spawn_numbers == 1 then
                spawns_left = self:text("hud_spawns_left") .. " " .. managers.hud:GetSpawnsLeft()
            else
                spawns_left = self:text("hud_spawns_left") .. " " .. managers.enemy:GetNumberOfEnemies()
            end
            s = string.format("%s", spawns_left)
        end

        if self.show_time_left then
            local time_left = self:text("hud_time_left") .. " " .. self:FormatTimeLeft(managers.hud:GetTimeLeft())
            if s then
                return string.format("%s%s%s", s, sep, time_left)
            else
                return string.format("%s", time_left)
            end
        end
    end
    return self:text("hud_time_left") .. " " .. self:text("hud_overdue")
end