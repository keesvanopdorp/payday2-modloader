local BAI = BAI
local HUDs =
{
    [0] = "WolfHUD",
    [1] = "VanillaHUD Plus",
    [2] = "Vanilla",
    [3] = "VoidUI",
    [4] = "Sora's HUD Reborn",
    [5] = "HoloUI",
    [6] = "SydneyHUD",
    [7] = "PD:TH HUD Reborn",
    [8] = "Restoration Mod",
    [9] = "MUI",
    [10] = "KineticHUD",
    [11] = "Halo: Reach HUD",
    [12] = "Hotline Miami HUD"
}

local Mods =
{
    [2] = "Vanilla",
    [3] = "PAYDAY 2 Hyper Heisting"
}

local function AddEventSilent(event, f, delay)
    BAI.Events[#BAI.Events + 1] = { event_name = event, func = f, delay = delay or 0 }
end

function HUDAssaultCorner:ApplyHUDCompatibility(number, detection)
    if _G.IS_VR then
        log("[BAI] VR Mode detected. VR Mode compatibility applied.")
        return
    end
    if number == 1 then
        if BeardLib then -- Some HUDs require BeardLib, let's check them first
            if restoration and restoration:all_enabled("HUD/MainHUD", "HUD/AssaultPanel") then
                self:ApplyHUDCompatibility(8, true)
                return
            elseif PDTHHud and PDTHHud.Options:GetValue("HUD/Assault") then
                self:ApplyHUDCompatibility(7, true)
                return
            elseif NepgearsyHUDReborn then -- Look's like he also forgot to update the code to reflect the mod name change
                self:ApplyHUDCompatibility(4, true)
                return
            elseif Holo and Holo.Options:GetValue("TopHUD") and Holo:ShouldModify("HUD", "Assault") then
                self:ApplyHUDCompatibility(VHUDPlus and 2 or 5, true) -- TODO: Check if VHUDPlus is also crashing other HUDs
                return
            elseif NobleHUD then
                self:ApplyHUDCompatibility(11, true)
                return
            end
        end
        if MUIStats then
            self:ApplyHUDCompatibility(9, true)
        elseif VoidUI and VoidUI.options.enable_assault then
            self:ApplyHUDCompatibility(3, true)
        elseif HMH and HMH:GetOption("assault") then
            self.Vanilla = true
            self:ApplyHUDCompatibility(12, true)
        elseif SydneyHUD then
            self.Vanilla = true
            self:ApplyHUDCompatibility(6, true)
        elseif KineticHUD then
            self.Vanilla = true
            self:ApplyHUDCompatibility(10, true)
        else
            self.Vanilla = true
            self:ApplyHUDCompatibility(2, true)
        end
        return
    end
    if number == 3 then
        self.is_safehouse_raid = managers.job:current_level_id() == "chill_combat"
        BAI:ApplyHUDCompatibility("void_ui")
        if BAI:GetAAIOption("time_format") == 5 then
            BAI.settings.advanced_assault_info.time_format = 6
        end
    elseif number == 4 then
        BAI:Unhook("", "upd_recon_tasks_PostHook")
        BAI:ApplyHUDCompatibility("soras_hud_reborn")
    elseif number == 5 then
        BAI:DelayCall("bai_holoui_compatibility", 2, function()
            BAI:Unhook("HoloUI", "start_assault")
            BAI:Unhook("HoloUI", "end_assault")
            BAI:ApplyHUDCompatibility("holoui")
        end)
    elseif number == 6 then
        self.center_assault_banner = SydneyHUD:GetOption("center_assault_banner")
        BAI:ApplyHUDCompatibility("sydneyhud")
        self.assault_panel_position_disabled = true
        AddEventSilent(BAI.EventList.EndlessAssaultStart, function()
            managers.hud._hud_assault_corner:SpamChat("Endless")
        end)
        AddEventSilent(BAI.EventList.AssaultStateChange, function(state, override)
            if not BAI:IsOr(state, "control", "anticipation") then
                local spam =
                {
                    ["build"] = "Build",
                    ["sustain"] = "Sustain",
                    ["fade"] = "Fade"
                }
                managers.hud._hud_assault_corner:SpamChat(spam[state])
            end
        end)
        AddEventSilent("MoveHUDList", function(self)
            if self.SetHUDListOffset then
                local offset = self._bg_box:h() + 54
                if self.center_assault_banner then
                    offset = BAI:GetOption("completely_hide_hostage_panel") and 0 or 46
                else
                    if BAI:GetOption("completely_hide_hostage_panel") then
                        offset = self._bg_box:h() + 8
                    end
                end
                self:SetHUDListOffset(offset)
            end
        end)
        local function AssaultStart()
            self:HUDTimer(false)
        end
        AddEventSilent(BAI.EventList.AssaultStart, AssaultStart)
        AddEventSilent(BAI.EventList.NoReturn, AssaultStart)
        self:InitBAI()
    elseif number == 7 then
        BAI.SetVariables = function()
            managers.hud._hud_assault_corner:SetVariables()
        end
        BAI:ApplyHUDCompatibility("pdth_hud_reborn")
        self:InitText()
        self.assault_panel_position_disabled = true
        self:AddHookEvents()
    elseif number == 8 then
        self.is_safehouse_raid = managers.job:current_level_id() == "chill_combat"
        self._v2_corner = restoration.Options:GetValue("HUD/AssaultStyle") == 2
        BAI:ApplyHUDCompatibility("restoration_mod")
        self:InitCornerText()
        if self._v2_corner then
            BAI.SetVariables = function()
                managers.hud._hud_assault_corner:SetVariables()
            end
            self:SetVariables()
            self:AddHookEvents(nil, nil, nil, function()
                local self = managers.hud._hud_assault_corner
                if self.is_host then
                    if not BAI:GetOption("show_assault_states") then
                        self:_update_corner_color(nil, "assault", true)
                        self:SetAlphaCornerText(self:GetAssaultText())
                    end
                else
                    if BAI:GetOption("show_assault_states") and not self.CompatibleHost then
                        self:_update_corner_color(nil, "assault", true)
                        self:SetAlphaCornerText(self:GetAssaultText())
                    end
                end
                self:SetHook(true)
            end)
        end
        self.assault_panel_position_disabled = true
    elseif number == 9 then
        self._mui = true
        BAI:ApplyHUDCompatibility("mui")
        MUIStats:UpdateVariables()
        --MUIStats:InitPanels()
    elseif number == 10 then
        BAI:Unhook("khud", "detect_assaultphase")
        BAI:Unhook("khud", "detect_regroupphase")
        BAI:ApplyHUDCompatibility("kinetichud")
        self._hud_panel:child("assault_clone"):child("phase_timer"):set_visible(false)
        --self:_set_phase_time_visible(false)
        AddEventSilent(BAI.EventList.NormalAssaultOverride, function()
            managers.hud._hud_assault_corner:_set_phase_time_visible(true)
        end)
    elseif number == 11 then
        BAI.SetVariables = function()
            managers.hud._hud_assault_corner:SetVariables()
        end
        BAI:ApplyHUDCompatibility("halo_reach_hud")
        self.assault_panel_position_disabled = true
        if BAI:IsHostagePanelHidden() then
            NobleHUD:SetHostagePanelVisible(false)
        end
        self:AddHookEvents()
    elseif number == 12 then
        BAI:ApplyHUDCompatibility("hotline_miami_hud")
        BAI.settings.advanced_assault_info.aai_panel = 2
        if self:should_display_waves() then
            self._hud_panel:child("wave_panel"):set_visible(true)
        end
        local function UpdateOffset(active)
            if active then
                local assault_panel = self._hud_panel:child("assault_panel")
                local icon_offset = select(3, assault_panel:child("text"):text_rect())
                --log("[BAI] Icon Offset: " .. icon_offset)
                self._hud_panel:child("buffs_panel"):set_x(assault_panel:left() + self._bg_box:left() - icon_offset)
                self._vip_bg_box:child("vip_icon"):set_center(self._vip_bg_box:w() / 2, self._vip_bg_box:h() / 2 - 5)
            end
        end
        AddEventSilent(BAI.EventList.Captain, UpdateOffset)
    end -- 2 = Vanilla HUD
    if number == 2 and WolfHUD then
        self.wolfhud = { bai = {} }
        BAI:ApplyHUDCompatibility("wolfhud")
        AddEventSilent("MoveHUDList", function(self)
            if self.update_hudlist_offset then
                self:update_hudlist_offset(true, false)
            end
        end)
        self:QueryWolfHUDOptions()
        self:QueryBAIOptions()
        self:InitWolfHUDOptions()
        number = 0
    end
    if number == 2 and VHUDPlus then
        self.vhudplus = { bai = {} }
        BAI:ApplyHUDCompatibility("vanillahud_plus")
        self:QueryVHUDPlusOptions()
        self:QueryBAIOptions()
        self:InitVHUDOptionsOptions()
        AddEventSilent("MoveHUDList", function(self)
            if self.UpdateHUDListOffset then
                self:UpdateHUDListOffset(true, true)
            end
            if self.vhudplus.center and not VHUDPlus:getSetting({"AssaultBanner", "MUI_ASSAULT_FIX"}, false) then
                managers.hud._hud_heist_timer._heist_timer_panel:set_visible(false)
            end
        end)
        number = 1
    end
    self:SetCompatibilityFlags(number)
    self:SetCommonHooks(number)
    log("[BAI] " .. (detection and (number == 2 and ("No HUD detected. ") or (HUDs[number] .. " detected. ")) or "") .. HUDs[number] .. " compatibility applied.")
end

function HUDAssaultCorner:AddHookEvents(as, eas, ae, c, nr, nao)
    local function TrueHook()
        self:SetHook(true)
    end
    local function FalseHook()
        self:SetHook(false)
    end
    local function ParameterHook(active)
        self:SetHook(not active)
    end
    AddEventSilent(BAI.EventList.AssaultStart, as or TrueHook)
    AddEventSilent(BAI.EventList.EndlessAssaultStart, eas or FalseHook)
    AddEventSilent(BAI.EventList.AssaultEnd, ae or FalseHook)
    AddEventSilent(BAI.EventList.Captain, c or ParameterHook)
    AddEventSilent(BAI.EventList.NoReturn, nr or ParameterHook)
    AddEventSilent(BAI.EventList.NormalAssaultOverride, nao or TrueHook)
end

function HUDAssaultCorner:ApplyModCompatibility(number, detection)
    if number == 1 then
        if NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY == "HYPERHEISTSHIN" then
            self:ApplyModCompatibility(3, true)
        else
            self:ApplyModCompatibility(2, true)
        end
        return
    end
    if number == 3 then
        BAI:ApplyModCompatibility("payday_2_hyper_heisting")
        BAI.EasterEgg.FSS.AIReactionTimeTooHigh = BAI:IsOr(Global.game_settings.difficulty, "overkill_290", "sm_wish")
    end -- 2 = Vanilla
    log("[BAI] " .. (detection and (number == 2 and ("No Mod detected. ") or (Mods[number] .. " mod detected. ")) or "") .. Mods[number] .. " mod compatibility applied.")
end

function HUDAssaultCorner:SetCompatibilityFlags(hud)
    if (self.Vanilla or hud == 2) or BAI:IsOr(hud, 3, 5, 8) then -- 3 = Void UI; 5 = HoloUI; 8 = Restoration Mod
        self.AAIPanel = not self._v2_corner
        if hud ~= 3 then -- Void UI
            self.AnimateHostagesPanel = true
            self._hud_panel:child("hostages_panel"):set_visible(true)
            self._hud_panel:child("hostages_panel"):set_alpha(1)
            self.AAIFunction = "AAIPanel"
            self.AAIFunctionArgs1 = { "_time_bg_box" }
            self.AAIFunctionArgs2 = { "_spawns_bg_box" }
            if hud == 5 then -- 5 = HoloUI
                self.AAIFunction = "AAIPanelHoloUI"
                self.AAIFunctionArgs1[2] = "time_left"
                self.AAIFunctionArgs2[2] = "spawns_left"
            end
        else
            self.AAIFunction = "AAIPanelVoidUI"
            self.AAIFunctionArgs1 = { callback(self, self, "_blink_background") }
            self.AAIFunctionArgs2 = self.AAIFunctionArgs1
        end
    end
    if hud == 10 then -- KineticHUD
        local function ShowTimer()
            self:_set_phase_time_visible(true)
        end

        local function HideTimer()
            self:_set_phase_time_visible(false)
        end

        AddEventSilent(BAI.EventList.AssaultStart, ShowTimer)
        AddEventSilent(BAI.EventList.EndlessAssaultStart, HideTimer)
        AddEventSilent(BAI.EventList.AssaultEnd, HideTimer)
    end
    if self.Vanilla or hud == 3 then
        AddEventSilent(BAI.EventList.AssaultStart, function()
            if BAI:IsHostagePanelHidden("assault") then
                managers.hud._hud_assault_corner:_hide_hostages()
            end
        end, 0.5)
        AddEventSilent(BAI.EventList.AssaultEnd, function()
            if BAI:IsHostagePanelVisible() then
                managers.hud._hud_assault_corner:_show_hostages()
            end
        end)
        AddEventSilent(BAI.EventList.EndlessAssaultStart, function()
            if BAI:IsHostagePanelHidden("endless") then
                managers.hud._hud_assault_corner:_hide_hostages()
            end
        end, 0.5)
        AddEventSilent(BAI.EventList.NormalAssaultOverride, function()
            if BAI:IsHostagePanelVisible("assault") then
                managers.hud._hud_assault_corner:_show_hostages()
            else
                managers.hud._hud_assault_corner:_hide_hostages()
            end
        end)
        AddEventSilent(BAI.EventList.Captain, function(active)
            if BAI:IsHostagePanelVisible(active and "captain" or "assault") then
                managers.hud._hud_assault_corner:_show_hostages()
            else
                managers.hud._hud_assault_corner:_hide_hostages()
            end
        end)
    end
end

function HUDAssaultCorner:SetCommonHooks(hud)
    if self.is_host then
        return
    end
    AddEventSilent(BAI.EventList.AssaultStart, function()
        if not BAI:GetOption("show_assault_states") then
            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
        end
    end, 40)
    AddEventSilent(BAI.EventList.AssaultStart, function()
        managers.enemy.force_spawned = 0
    end)
    if hud == 9 then -- MUI
        return
    end
    local function RemoveCalls()
        self:RemoveASCalls()
    end
    local function RemoveCallsCondition(active)
        if active then
            self:RemoveASCalls()
        end
    end
    AddEventSilent(BAI.EventList.EndlessAssaultStart, RemoveCalls)
    AddEventSilent(BAI.EventList.Captain, RemoveCallsCondition)
    AddEventSilent(BAI.EventList.NoReturn, RemoveCalls)
end