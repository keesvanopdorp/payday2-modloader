local as_text = ""
function NobleHUD:SetAssaultPhase(text, send_to_peers)
    -- You picked the wrong house, fool. That's my job!
    --local assault_phase_label = self._score_panel:child("assault_phase_label")
    if text ~= as_text then
        as_text = text
		--assault_phase_label:set_text(text)
		--self:animate(assault_phase_label,"animate_killfeed_text_in",nil,0.3,20,self.color_data.hud_vitalsoutline_blue,self.color_data.hud_text_flash)
		if send_to_peers then -- Atleast I will network your sync message.
			LuaNetworking:SendToPeers(self.network_messages.sync_assault,text)
		end
	end
end

function NobleHUD:SetAssaultPhase_BAI(text, text_id)
    if text_id and not BAI:IsOr(text_id, "survived", "escape") and BAI:ShowFSSAI() and BAI:IsCustomTextDisabled(text_id) then
        text = "hud_fss_mod_" .. math.random(1, 3)
    end
    local color = text_id and BAI:GetRightColor(text_id) or self.color_data.hud_vitalsoutline_blue
    local assault_phase_label = self._score_panel:child("assault_phase_label")
    if (text and text ~= assault_phase_label:text()) or (color ~= assault_phase_label:color() or false) then 
        assault_phase_label:set_text(managers.localization:text(text))
        self:animate(assault_phase_label, "animate_killfeed_text_in", nil, 0.3, 20, color, self.color_data.hud_text_flash)
    end
    self._score_panel:child("aai"):animate(callback(BAIAnimation, BAIAnimation, "NobleHUD_animate_color"), color)
end

function NobleHUD:SetHostagePanelVisible(visibility)
    self._score_panel:child("hostages_panel"):set_alpha(visibility and 1 or 0)
end

local c = Color.red
local _f_create_score = NobleHUD._create_score
function NobleHUD:_create_score(hud)
    _f_create_score(self, hud)
    local score_panel = self._score_panel
    local aai = score_panel:text({
        name = "aai",
        text = "", -- 999 | 4 min 00 s
        align = "left",
        x = score_panel:child("wave_label"):x(),
        y = score_panel:child("wave_label"):y(),
        color = self.color_data.hud_vitalsoutline_blue,
        font = self.fonts.eurostile_ext,
        font_size = 20,
        layer = 4,
        alpha = 0
    })
    local captain_active = score_panel:text({
        name = "captain_active",
        text = managers.localization:text("hud_captain_active"),
        align = "left",
        x = score_panel:child("wave_label"):x(),
        y = score_panel:child("wave_label"):y(),
        color = self.color_data.hud_vitalsoutline_blue,
        font = self.fonts.eurostile_ext,
        font_size = 20,
        layer = 4,
        alpha = 0
    })
    if BAI:GetHUDOption("halo_reach_hud", "use_bai_color") then
        local cc = BAI:GetColor("escape")
        score_panel:child("ponr_label"):set_color(cc)
        score_panel:child("ponr_timer"):set_color(cc)
        c = cc
    end
    local self = managers.hud._hud_assault_corner
    if self:should_display_waves() then
        aai:set_y(aai:y() - 32) -- Move it above assault phase label when "WaveX/Y" text is visible
    end
    self:SetVariables()
end

local assault_data
if Network:is_server() then
    local gai_state = managers.groupai:state()
    assault_data = gai_state and gai_state._task_data.assault
end

function HUDAssaultCorner:SetVariables()
    self.show_spawns_left = BAI.settings.advanced_assault_info.show_spawns_left
    self.spawn_numbers = BAI.settings.advanced_assault_info.spawn_numbers
    self.show_time_left = BAI.settings.advanced_assault_info.show_time_left
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfo(t, dt)
    if assault_data and assault_data.active then
        local spawns_left, time_left
        if self.show_spawns_left then
            if self.spawn_numbers == 1 then
                spawns_left = math.max(managers.localization:CalculateSpawnsLeft(), 0)
            else
                spawns_left = managers.enemy:GetNumberOfEnemies()
            end
        end

        if self.show_time_left then
            time_left = managers.localization:CalculateTimeLeft()
        end
        self:UpdateAAIText(time_left, spawns_left)
        return
    end

    if self.is_client then
        local time, spawns
        if self.show_spawns_left then
            if self.spawn_numbers == 1 then
                spawns = managers.hud:GetSpawnsLeft()
            else
                spawns = managers.enemey:GetNumberOfEnemies()
            end
        end
        if self.show_time_left then
            time = managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft())
        end
        self:UpdateAAIText(time, spawns)
    end
end

function HUDAssaultCorner:UpdateAAIText(time, spawns)
    local text
    if spawns then
        text = spawns
    end
    if time then
        if text then
            text = text .. " | " .. time
        else
            text = time
        end
    end
    NobleHUD._score_panel:child("aai"):set_text(text or "")
end

function HUDAssaultCorner:UpdatePONRBox()
    if NobleHUD._score_panel and NobleHUD._score_panel:child("ponr_label") and NobleHUD._score_panel:child("ponr_timer") then
        self._noreturn_color = BAI:GetColor("escape")
        self._point_of_no_return_color = self._noreturn_color
        c = self._noreturn_color
        local score_panel = self._score_panel
        score_panel:child("ponr_label"):set_color(cc)
        score_panel:child("ponr_timer"):set_color(cc)
    end
end

--[[
    Why are you the way that you are?
    Honestly, every time I try to do something fun or exciting, you make it not that way.
    I hate so much about the things you choosed to be...

    This is one of those things.
]]
function NobleHUD:AnimatePONRFlash(beep)
	local ponr_text = self._score_panel:child("ponr_timer")
	self:animate_stop(ponr_text)
	ponr_text:set_font_size(24)
	ponr_text:set_color(c)
	if beep then 
		self:animate(ponr_text,"animate_killfeed_text_in",nil,0.5,24,self.color_data.hud_hint_orange,self.color_data.hud_hint_lightorange)
	else -- Stop making my life harder. Seriously!
		self:animate(ponr_text,"animate_killfeed_text_in",nil,0.5,24,c,Color.white)
	end
end

function HUDAssaultCorner:show_point_of_no_return_timer()
    self._point_of_no_return = true
    --NobleHUD:animate(NobleHUD._score_panel:child("assault_phase_label"), "animate_fadeout", nil, 0.3, 1, 1) -- Disabled due to bug
    self:SetHook(false)
    NobleHUD:SetAssaultPhase_BAI("hud_no_return", "escape")
    BAI:CallEvent(BAI.EventList.NoReturn, true)
end

function HUDAssaultCorner:_start_endless_assault(text_list)
    if self._assault_vip then
        NobleHUD:SetAssaultPhase_BAI("hud_captain", "captain")
        return
    end
    if not self._assault_endless then
        BAI:CallEvent(BAI.EventList.EndlessAssaultStart)
    end
    self._assault_endless = true
    self.assault_type = "endless"
    NobleHUD:SetAssaultPhase_BAI("hud_endless", "endless")
end

function HUDAssaultCorner:_start_assault(text_list)
    self._assault = true
    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        BAI:CallEvent(BAI.EventList.AssaultStart)
        if BAI:GetOption("show_assault_states") and self.is_host or (self.is_client and self.CompatibleHost) then
            if BAI:IsStateEnabled("build") then
                NobleHUD:SetAssaultPhase_BAI("hud_build", "build")
            end
        else
            NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
        end
        if self.is_skirmish then
            self:_popup_wave_started()
            if alive(self._wave_bg_box) then
                self._wave_bg_box:stop()
                self._wave_bg_box:animate(callback(self, self, "_animate_wave_started"), self)
            end
        end
    end
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
    if self._assault_mode == mode then
        return
    end
    self._assault_mode = mode
    self._assault_vip = mode == "phalanx"
    BAI:CallEvent(BAI.EventList.Captain, self._assault_vip)
    if mode == "phalanx" then
        if BAI:IsHostagePanelHidden("captain") then
            self:_hide_hostages()
        end
        self._assault_endless = false
        NobleHUD:SetAssaultPhase_BAI("hud_captain", "captain")
    else
        self:SetTimeLeft(5) -- Set Time Left to 5 seconds when Captain is defeated
        if BAI:IsHostagePanelVisible("assault") then
            self:_show_hostages()
        end
        if BAI:GetOption("show_assault_states") then
            self:UpdateAssaultState("fade") -- When Captain is defeated, Assault state is automatically set to Fade state
        else
            NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
        end
    end
end

function HUDAssaultCorner:set_buff_enabled(buff_name, enabled)
    if enabled and not self._enabled then
        self._enabled = true
        --NobleHUD:animate(NobleHUD._score_panel:child("aai"), "animate_fadein", nil, 0.3, 1, 0) -- Disabled due to bug
        BAI:Animate(NobleHUD._score_panel:child("captain_active"), 1, "FadeIn")
    elseif not enabled then
        self._enabled = false
        BAI:Animate(NobleHUD._score_panel:child("captain_active"), 0, "FadeOut")
        --NobleHUD:animate(NobleHUD._score_panel:child("aai"), "animate_fadeout", nil, 0.3, 1, 1) -- Disabled due to bug
    end
    if enabled then 
		NobleHUD:AddBuff(buff_name)
	else
		NobleHUD:RemoveBuff(buff_name)
	end
end

function HUDAssaultCorner:_end_assault()
    if not self._assault then
         self._start_assault_after_hostage_offset = nil
         return
    end
    self:RemoveASCalls()
    self.assault_type = nil
    self._assault = nil
    self._assault_endless = nil
    if self:should_display_waves() then
        NobleHUD:AnimateNormalWaveComplete()
        self._wave_bg_box:stop()
		self._wave_bg_box:animate(callback(self, self, "_animate_wave_completed"), self)
        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            NobleHUD:AnimateNormalWaveComplete()
        else
            if BAI:GetOption("show_assault_states") then
                if self.is_host or (self.is_client and self.CompatibleHost) then
                    self:UpdateAssaultStateOverride("control", true)
                    if BAI:IsHostagePanelVisible() then
                        NobleHUD:SetHostagePanelVisible(true)
                    end
                else
                    NobleHUD:_close_assault_box()
                end
            else
                NobleHUD:_close_assault_box()
            end
        end
    end
    if not self.dont_override_endless then
        self.endless_client = false
    end
    BAI:CallEvent(BAI.EventList.AssaultEnd)
    self.trigger_assault_start_event = true
end

function NobleHUD:AnimateNormalWaveComplete(wave)
    managers.hud._hud_assault_corner.wave_survived = true
    self:SetAssaultPhase_BAI("hud_survived", "survived")
    self:AddDelayedCallback(function()
        local hud = managers.hud._hud_assault_corner
        hud.wave_survived = false
        if BAI:GetOption("show_assault_states") then
            if hud.is_host or (hud.is_client and hud.CompatibleHost) then
                hud:UpdateAssaultStateOverride("control")
                if BAI:IsHostagePanelVisible() then
                    self:SetHostagePanelVisible(true)
                end
            else
                self:_close_assault_box()
            end
        else
            self:_close_assault_box()
        end
    end, nil, 8.6)
end

function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud)
    local wave_text = panel:child("num_waves")
    local bg = panel:child("bg")

    wait(1.4)
    wave_text:set_text(self:get_completed_waves_string())
    bg:stop()
    bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
    wait(7.2)
    self.wave_survived = false
end

function NobleHUD:_close_assault_box()
    self:SetAssaultPhase_BAI("noblehud_hud_assault_phase_standby")
end

function HUDAssaultCorner:SetNormalAssaultOverride()
    if self.is_client and self.level_id == "hox_1" then
        self:SetTimeLeft(5)
    end
    self:SetImage("assault")
    self._assault_endless = false
    self.was_endless = false
    if BAI:GetOption("show_assault_states") then
        if self.is_host then
            self:UpdateAssaultStateOverride(managers.groupai:state():GetAssaultState())
        else
            if not self.BAIHost then
                NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
            else
                LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
            end
        end
    else
        NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
        if BAI.settings.show_advanced_assault_info and self.is_client then
            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
        end
    end
    NobleHUD:SetHostagePanelVisible(BAI:IsHostagePanelVisible("assault"))
    BAI:CallEvent(BAI.EventList.NormalAssaultOverride)
end

function HUDAssaultCorner:UpdateAssaultState(state)
    if not self._assault_vip and not self._assault_endless and not self._point_of_no_return then
        if BAI:GetOption("show_assault_states") then
            if state and self.assault_state ~= state then
                self.assault_state = state
                BAI:SyncAssaultState(state)
                BAI:CallEvent("AssaultStateChange", state)
                if state == "build" and self.is_client then
                    LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                    return
                end
                if BAI:IsOr(state, "control", "anticipation") and self.is_client and not self.CompatibleHost then
                    return
                end
                if BAI:IsStateDisabled(state) then
                    if BAI:IsOr(state, "control", "anticipation") then
                        if self._assault then
                            self._assault = false
                            NobleHUD:SetAssaultPhase_BAI("noblehud_hud_assault_phase_standby")
                        end
                    else
                        if self._assault then
                            if BAI.settings.show_advanced_assault_info and self.is_client then
                                LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                            end
                            NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
                        end
                    end
                    return
                end
                if BAI:IsOr(state, "control", "anticipation") then
                    if not self._assault then
                        if WolfHUD and self.update_hudlist_offset then
                            self:update_hudlist_offset(true)
                        end
                    end
                else
                    if BAI.settings.show_advanced_assault_info and self.is_client then
                        LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                    end
                end
                NobleHUD:SetAssaultPhase_BAI("hud_" .. state, state)
            end
        else
            if state and self.assault_state ~= state then
                self.assault_state = state
                BAI:SyncAssaultState(state)
                BAI:CallEvent("AssaultStateChange", state)
            end
        end
    end
end

function HUDAssaultCorner:UpdateAssaultStateOverride(state, override)
    if not self._assault_vip and not self._assault_endless and not self._point_of_no_return then
        if BAI:GetOption("show_assault_states") then
            if state then
                self.assault_state = state
                BAI:CallEvent("AssaultStateChange", state, true)
                if BAI:IsOr(state, "control", "anticipation") then
                    if BAI:IsStateDisabled(state) then
                        NobleHUD:SetAssaultPhase_BAI("noblehud_hud_assault_phase_standby")
                        return
                    end
                    self._assault = true
                    NobleHUD:SetAssaultPhase_BAI("hud_" .. state, state)
                else
                    if BAI:IsStateDisabled(state) then
                        NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
                        if BAI.settings.show_advanced_assault_info and self.is_client then
                            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                        end
                        return
                    end
                    if BAI.settings.show_advanced_assault_info and self.is_client then
                        LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                    end
                    NobleHUD:SetAssaultPhase_BAI("hud_" .. state, state)
                end
                BAI:SyncAssaultState(state, true)
            end
        end
    end
end

function HUDAssaultCorner:GetNobleHUDColor(type)
    if not BAI:GetHUDOption("halo_reach_hud", "use_bai_color") then
        return NobleHUD.color_data.hud_vitalsoutline_blue
    end
    if type then
        return BAI:GetRightColor(type)
    end
    return NobleHUD.color_data.hud_vitalsoutline_blue
end

function HUDAssaultCorner:SetHook(hook)
    if not BAI:ShowAdvancedAssaultInfo() then
        return
    end
    NobleHUD._score_panel:child("aai"):animate(callback(BAIAnimation, BAIAnimation, hook and "FadeIn" or "FadeOut"))
    if hook then
        --NobleHUD:animate(NobleHUD._score_panel:child("aai"), "animate_fadein", nil, 0.3, 1, 0) -- Disabled due to bug
        managers.hud:add_updator("BAI_UpdateAAI", callback(self, self, "UpdateAdvancedAssaultInfo"))
    else
        --NobleHUD:animate(NobleHUD._score_panel:child("aai"), "animate_fadeout", nil, 0.3, 1, 1) -- Disabled due to bug
        managers.hud:remove_updator("BAI_UpdateAAI")
    end
end

function HUDAssaultCorner:show_casing(mode) --Disables casing mode indicator
end

function HUDAssaultCorner:UpdateAssaultStateColor(state, force_update)
    if state then
        if BAI:IsStateDisabled(state) then
            return
        end
        NobleHUD:SetAssaultPhase_BAI("hud_" .. state, state)
        if BAI:IsHostagePanelHidden() then
            NobleHUD:SetHostagePanelVisible(BAI:IsHostagePanelVisible("assault"))
        end
        if force_update and self.is_host then
            self:UpdateAssaultState(managers.groupai:state():GetAssaultState())
        end
    end
end

function HUDAssaultCorner:UpdateAssaultColor(color, assault_type)
    NobleHUD:SetAssaultPhase_BAI("hud_assault", "assault")
    if BAI:IsHostagePanelHidden() then
        NobleHUD:SetHostagePanelVisible(false)
        if assault_type ~= "wave_survived" and BAI:IsHostagePanelVisible(assault_type) then
            NobleHUD:SetHostagePanelVisible(true)
        end
    end
end