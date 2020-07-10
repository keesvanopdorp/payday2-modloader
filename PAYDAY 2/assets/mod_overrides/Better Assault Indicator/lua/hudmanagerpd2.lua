function HUDManager:GetAssaultMode()
    return self._hud_assault_corner:get_assault_mode()
end

function HUDManager:SetEndlessClient(dont_override)
    self._hud_assault_corner:SetEndlessClient(dont_override)
end

function HUDManager:SetCompatibleHost(BAI)
    self._hud_assault_corner:SetCompatibleHost(BAI)
end

function HUDManager:SetNormalAssaultOverride()
    self._hud_assault_corner:SetNormalAssaultOverride()
end

function HUDManager:UpdateCustomText()
    self._hud_assault_corner:LoadCustomText(true)
end

function HUDManager:UpdateColors()
    self._hud_assault_corner:UpdateColors()
end

function HUDManager:UpdateAssaultColor(color, assault_type)
    self._hud_assault_corner:UpdateAssaultColor(color, assault_type)
end

function HUDManager:UpdateAssaultState(state)
    self._hud_assault_corner:UpdateAssaultState(state)
end

function HUDManager:UpdateAssaultState_Mod(state)
    self._hud_assault_corner:UpdateAssaultState_Mod(state)
end

function HUDManager:UpdateAssaultStateOverride(state, override)
    self._hud_assault_corner:UpdateAssaultStateOverride(state, override)
end

function HUDManager:UpdateAssaultStateColor(state, force_update)
    self._hud_assault_corner:UpdateAssaultStateColor(state, force_update)
end

function HUDManager:IsNormalPoliceAssault()
    return self._hud_assault_corner._assault and not self._hud_assault_corner._assault_endless
end

function HUDManager:IsPoliceAssault()
    return self._hud_assault_corner._assault
end

function HUDManager:IsEndlessPoliceAssault()
    return self._hud_assault_corner._assault_endless
end

function HUDManager:IsWaveSurvivedShowed()
    return self._hud_assault_corner.wave_survived
end

function HUDManager:GetAssaultState()
    return self._hud_assault_corner.assault_state
end

function HUDManager:IsHost()
    return self._hud_assault_corner.is_host
end

function HUDManager:IsClient()
    return self._hud_assault_corner.is_client
end

function HUDManager:IsSkirmish()
    return self._hud_assault_corner.is_skirmish
end

function HUDManager:GetTimeLeft()
    return self._hud_assault_corner.client_time_left - TimerManager:game():time()
end

function HUDManager:GetSpawnsLeft()
    return math.floor(self._hud_assault_corner.client_spawns_left - managers.enemy.force_spawned)
end

function HUDManager:SetTimeLeft(time)
    self._hud_assault_corner:SetTimeLeft(time)
end

function HUDManager:GetAssaultTime(sender)
    self._hud_assault_corner:GetAssaultTime(sender)
end

function HUDManager:GetCompatibleHost()
    return self._hud_assault_corner.CompatibleHost
end

function HUDManager:GetBAIHost()
    return self._hud_assault_corner.BAIHost
end

function HUDManager:UpdateAssaultPanelPosition(update)
    self._hud_assault_corner:UpdateAssaultPanelPosition(update)
end

function HUDManager:SetCaptainBuff(buff)
    self._hud_assault_corner:SetCaptainBuff(buff)
end

function HUDManager:SetCivilianKilled(amount)
    self._hud_assault_corner:SetCivilianKilled(amount)
end

function HUDManager:StartEndlessAssaultClient(dont_override)
    self:SetEndlessClient(dont_override)
    self._hud_assault_corner:start_assault_callback()
end

-- Used for Debug only
--[[function HUDManager:activate_objective(data)
    self._hud_objectives:activate_objective(data)
    log("[BAI] Objective ID: " .. data.id)
end]]

BAI:Hook(HUDManager, "_create_assault_corner", function(self)
    dofile(BAI.LuaPath .. "hudassaultcorner.lua")
    if self._hud_assault_corner and self._hud_assault_corner.InitBAI then
        self._hud_assault_corner:InitBAI()
    else
        log("[BAI] Can't execute code in HUDAssaultCorner! Are you sure it wasn't deleted?")
    end
end)

--[[if HUDListManager then
    local _f_activate_objective = HUDManager.activate_objective
    function HUDManager:activate_objective(data)
        _f_activate_objective(self, data)
        if self._hud_assault_corner.assault_panel_position == 1 then
            managers.hudlist:change_setting("left_list_y", data.amount and 108 or 86)
        end
    end
end]]