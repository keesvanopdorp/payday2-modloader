local multiplier = BAI.Language == "thai" and 2 or 1

local assault_data
if Network:is_server() then
    local gai_state = managers.groupai:state()
    assault_data = gai_state and gai_state._task_data.assault
end
local delta = 0

function HUDAssaultCorner:SetVariables()
    self.show_spawns_left = BAI.settings.advanced_assault_info.show_spawns_left
    self.spawn_numbers = BAI.settings.advanced_assault_info.spawn_numbers
    self.show_time_left = BAI.settings.advanced_assault_info.show_time_left
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfo(t, dt)
    if assault_data and assault_data.active then
        if self.show_spawns_left then
            if self.spawn_numbers == 1 then
                self:UpdateSpawnsLeft(math.max(managers.localization:CalculateSpawnsLeft()))
            else
                self:UpdateSpawnsLeft(managers.enemy:GetNumberOfEnemies())
            end
        end

        if self.show_time_left then
            self:UpdateTimeLeft(managers.localization:CalculateTimeLeft())
            return
        end

        self:UpdateTimeLeft(managers.localization:text("hud_overdue"))
        return
    end

    if self.is_client then
        if self.show_spawns_left then
            if self.spawn_numbers == 1 then
                self:UpdateSpawnsLeft(managers.hud:GetSpawnsLeft())
            else
                self:UpdateSpawnsLeft(managers.enemy:GetNumberOfEnemies())
            end
        end

        if self.show_time_left then
            self:UpdateTimeLeft(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()))
            return
        end

        self:UpdateTimeLeft(managers.localization:text("hud_overdue"))
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoPos(t, dt)
    delta = delta + dt
    if delta > 0.5 then
        delta = 0
        local panel = self._hud_panel
        local x = self._hud_panel:child("assault_panel"):center_x()
        managers.hud:make_fine_text(panel:child("assault_time_left"))
        panel:child("assault_time_left"):set_center_x(x)
        managers.hud:make_fine_text(panel:child("assault_spawns_left"))
        panel:child("assault_spawns_left"):set_center_x(x)
    end
end

function HUDAssaultCorner:SetPositionUpdater()
end

function HUDAssaultCorner:UpdateTimeLeft(time)
    self._hud_panel:child("assault_time_left"):set_text(managers.localization:text("hud_time_left_short") .. time)
end

function HUDAssaultCorner:UpdateSpawnsLeft(spawns)
    self._hud_panel:child("assault_spawns_left"):set_text(managers.localization:text("hud_spawns_left_short") .. math.floor(spawns))
end

function HUDAssaultCorner:InitText()
    local const = pdth_hud.constants
    local panel = self._hud_panel
    local assault_panel = panel:child("assault_panel")
    local captain_assembled = panel:text({
        name = "captain_fully_assembled",
        text = utf8.to_upper(managers.localization:text("hud_captain_active")),
        blend_mode = "normal",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true,
        alpha = 0
    })

    managers.hud:make_fine_text(captain_assembled)
    captain_assembled:set_center_x(assault_panel:center_x())
    captain_assembled:set_top(assault_panel:top() - 20)

    local assault_time_left = panel:text({
        name = "assault_time_left",
        text = managers.localization:text("hud_time_left_short") .. "4 " .. managers.localization:text("hud_min") .. " 20 " .. managers.localization:text("hud_s"),
        blend_mode = "normal",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true,
        alpha = 0
    })

    managers.hud:make_fine_text(assault_time_left)
    assault_time_left:set_center_x(assault_panel:center_x())
    assault_time_left:set_top(assault_panel:top() - 20)

    local assault_spawns_left = panel:text({
        name = "assault_spawns_left",
        text = managers.localization:text("hud_spawns_left_short") .. "420",
        blend_mode = "normal",
        layer = 1,
        color = Color.red,
        font_size = const.assault_font_size,
        font = tweak_data.menu.small_font,
        visible = true,
        alpha = 0
    })

    managers.hud:make_fine_text(assault_spawns_left)
    assault_spawns_left:set_center_x(assault_panel:center_x())
    assault_spawns_left:set_top(assault_panel:top() - 40)

    self:SetVariables()
end

function HUDAssaultCorner:UpdatePONRBox()
    if not self._point_of_no_return then
        local const = pdth_hud.constants
        self._noreturn_color = BAI:GetColor("escape")
        self._point_of_no_return_color = self._noreturn_color
        if self._hud_panel:child("point_of_no_return_panel") then
            self._hud_panel:remove(self._hud_panel:child("point_of_no_return_panel"))
        end
        local point_of_no_return_panel = self._hud_panel:panel({
            visible = false,
            name = "point_of_no_return_panel",
        })

        local point_of_no_return_text = point_of_no_return_panel:text({
            name = "point_of_no_return_text",
            text = "",
            blend_mode = "normal",
            layer = 1,
            color = self._noreturn_color,
            font_size = const.no_return_t_font_size,
            font = tweak_data.menu.small_font
        })
        point_of_no_return_text:set_text(BAI:IsCustomTextEnabled("escape") and managers.localization:text("hud_assault_point_no_return_in") or managers.localization:text("time_escape"))
        managers.hud:make_fine_text(point_of_no_return_text)
        point_of_no_return_text:set_right(point_of_no_return_panel:w())
        point_of_no_return_text:set_top(0)

        local point_of_no_return_timer = point_of_no_return_panel:text({
            name = "point_of_no_return_timer",
            text = "",
            blend_mode = "normal",
            layer = 1,
            color = self._noreturn_color,
            font_size = const.no_return_timer_font_size,
            font = tweak_data.menu.small_font
        })
        managers.hud:make_fine_text(point_of_no_return_timer)
        point_of_no_return_timer:set_right(point_of_no_return_text:right())
        point_of_no_return_timer:set_top(point_of_no_return_text:bottom())
    end
end

function HUDAssaultCorner:SetImage(image)
end

function HUDAssaultCorner:set_buff_enabled(buff_name, enabled)
    self._hud_panel:child("captain_fully_assembled"):animate(callback(BAIAnimation, BAIAnimation, enabled and "FadeIn" or "FadeOut"))
end

local _BAI_start_assault_callback = HUDAssaultCorner.start_assault_callback
function HUDAssaultCorner:start_assault_callback()
    _BAI_start_assault_callback(self)
    if not self._assault_endless then
        if BAI:GetOption("show_assault_states") then
            if BAI:IsStateEnabled("build") then
                self:UpdateAssaultText("hud_build")
            end
        end
    end
end

function HUDAssaultCorner:_start_assault(text_list)
    local assault_panel = self._hud_panel:child("assault_panel")
    local control_assault_title = assault_panel:child("control_assault_title")
    local num_hostages = self._hud_panel:child("num_hostages")
    local casing_panel = self._hud_panel:child("casing_panel")
    self._assault = true
    assault_panel:set_visible(true)
    num_hostages:set_alpha(0.7)
    casing_panel:set_visible(false)
    self._is_casing_mode = false

    local color, text, text_id
    if self._assault_endless then
        color = self._assault_endless_color
        text = "hud_endless"
        if BAI:ShowFSSAI() then
            text = "hud_fss_mod_" .. math.random(1, 3)
            text_id = nil
        end
    else
        color = self._assault_color
        text = self:GetAssaultText()
    end

    if self._assault_mode == "phalanx" then
        color = self._vip_assault_color
        text = "hud_captain"
        self.assault_type = "captain"
    end

    self:UpdateAssaultText(text)
    self._fx_color = color

    self:_update_assault_hud_color(color)

    assault_panel:stop()
    assault_panel:animate(callback(self, self, "flash_assault_title"), true)

    if BAI:IsHostagePanelHidden(self.assault_type) then
        self:_hide_hostages()
    end

    if alive(self._wave_bg_box) then
        self._wave_bg_box:stop()
        self._wave_bg_box:animate(callback(self, self, "_animate_wave_started"), self)
    end

    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        if self.is_skirmish then
            self:_popup_wave_started()
        end
        BAI:CallEvent(BAI.EventList.AssaultStart)
    end
end

function HUDAssaultCorner:_start_endless_assault(text_list)
    if not self._assault_endless then
        BAI:CallEvent(BAI.EventList.EndlessAssaultStart)
    end
    self._assault_endless = true
    self.assault_type = "endless"
    self:_start_assault(text_list)
    self:_update_assault_hud_color(self._assault_endless_color)
    self:UpdateAssaultText("hud_endless")
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
    if self._assault_mode == mode then
        return
    end
    self._assault_mode = mode
    local text = self:GetAssaultText()
    local color = self._assault_color
    if mode == "phalanx" then
        color = self._vip_assault_color
        text = "hud_captain"
    end
    self._fx_color = color
    self:_animate_update_assault_hud_color(color)

    self:UpdateAssaultText(text)
    self._assault_vip = mode == "phalanx"

    BAI:CallEvent(BAI.EventList.Captain, self._assault_vip)

    if mode == "phalanx" then
        if BAI:IsHostagePanelHidden("captain") then
            self:_hide_hostages()
        end
        self._assault_endless = false
    else
        self:SetTimeLeft(5) -- Set Time Left to 5 seconds when Captain is defeated
        if BAI:IsHostagePanelVisible("assault") then
            self:_show_hostages()
        end
        if BAI:GetOption("show_assault_states") then
            self:UpdateAssaultState("fade") -- When Captain is defeated, Assault state is automatically set to Fade state
        end
    end
end

function HUDAssaultCorner:show_point_of_no_return_timer()
    local delay_time = self._assault and 1.2 or 0
    local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
    point_of_no_return_panel:stop()
    point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
    self._point_of_no_return = true
    self:_close_assault_box()
end

function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
    self._PoNR_flashing = true
    local const = PDTHHud.constants
    local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
    local function flash_timer(o)
        local t = 0
        while t < 0.5 do
            t = t + coroutine.yield()
            local n = 1 - math.sin(t * 180)
            local r = math.lerp(self._noreturn_color.r, 1, n)
            local g = math.lerp(self._noreturn_color.g, 0.8, n)
            local b = math.lerp(self._noreturn_color.b, 0.2, n)
            o:set_color(Color(r, g, b))

            if BetterLightFX then
                BetterLightFX:StartEvent("PointOfNoReturn")
                BetterLightFX:SetColor(r, g, b, 1, "PointOfNoReturn")
            end

            o:set_font_size(math.lerp(const.no_return_timer_font_size , const.no_return_timer_font_size_pulse, n))
        end
        if BetterLightFX then
            BetterLightFX:EndEvent("PointOfNoReturn")
        end
    end

    local point_of_no_return_timer = point_of_no_return_panel:child("point_of_no_return_timer")
    point_of_no_return_timer:animate(flash_timer)
 end

local _f_update_assault_hud_color = HUDAssaultCorner._update_assault_hud_color
function HUDAssaultCorner:_update_assault_hud_color(color, animation)
    local panel = self._hud_panel
    local assault_panel = panel:child("assault_panel")

    if not animation then
        assault_panel:child("icon_assaultbox"):stop()
    end

    _f_update_assault_hud_color(self, color)
    local control_assault_title = assault_panel:child("control_assault_title")
    control_assault_title:set_color(BAI.settings.hud.pdth_hud_reborn.custom_text_color and BAI:GetColorFromTable(BAI.settings.hud.pdth_hud_reborn.color) or color)
    panel:child("captain_fully_assembled"):set_color(color)
    panel:child("assault_time_left"):set_color(color)
    panel:child("assault_spawns_left"):set_color(color)
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetAnimationOption("enable_animations") and BAI:GetAnimationOption("animate_color_change") then
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):stop()
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"))
    else
        self:_update_assault_hud_color(color)
    end
end

function HUDAssaultCorner:_end_assault()
    self:RemoveASCalls()
    local assault_panel = self._hud_panel:child("assault_panel")
    local control_assault_title = assault_panel:child("control_assault_title")
    local num_hostages = self._hud_panel:child("num_hostages")
    self:_show_hostages(1)
    if not self._assault then
        return
    end
    self._assault = false
    self._assault_endless = false
    self.assault_type = nil

    if BetterLightFX then
        BetterLightFX:EndEvent("AssaultIndicator")
    end

    if self:should_display_waves() then
        self.wave_survived = true
        self:_update_assault_hud_color(self._assault_survived_color)
        self:UpdateAssaultText("hud_survived")
        self._wave_bg_box:stop()
        self._wave_bg_box:animate(callback(self, self, "_animate_wave_completed"), self)
        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            self.wave_survived = true
            self:_update_assault_hud_color(self._assault_survived_color)
            self:UpdateAssaultText("hud_survived")
            assault_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
        else
            if BAI:GetOption("show_assault_states") then
                self:UpdateAssaultStateOverride("control")
            else
                self:_close_assault_box()
            end
        end
    end

    if not self.dont_override_endless then
        self.endless_client = false
    end

    if BAI:IsHostagePanelVisible() then
        self:_show_hostages()
    end

    BAI:CallEvent(BAI.EventList.AssaultEnd)

    self.trigger_assault_start_event = true
end

function HUDAssaultCorner:_close_assault_box()
    local assault_panel = self._hud_panel:child("assault_panel")
    assault_panel:set_visible(false)
    assault_panel:stop()
end

function HUDAssaultCorner:SetHook(hook)
    if not BAI:ShowAdvancedAssaultInfo() then
        return
    end
    self:ChangeAdvancedAssaultInfoVisibility(hook)
    if hook then
        managers.hud:add_updator("BAI_UpdateAAI", callback(self, self, "UpdateAdvancedAssaultInfo"))
        managers.hud:add_updator("BAI_UpdateAAIPos", callback(self, self, "UpdateAdvancedAssaultInfoPos"))
    else
        managers.hud:remove_updator("BAI_UpdateAAI")
        managers.hud:remove_updator("BAI_UpdateAAIPos")
    end
end

function HUDAssaultCorner:_hide_hostages()
    BAI:Animate(self._hud_panel:child("num_hostages"), 0, "FadeOut")
end

function HUDAssaultCorner:_show_hostages(alpha)
    if not self._point_of_no_return then
        BAI:Animate(self._hud_panel:child("num_hostages"), alpha or 0.7, "FadeIn", alpha or 0.7)
    end
end

function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    self:start_assault_callback()
end

function HUDAssaultCorner:ChangeAdvancedAssaultInfoVisibility(check)
    local panel = self._hud_panel
    local time = panel:child("assault_time_left")
    local spawns = panel:child("assault_spawns_left")
    if check then
        if self.show_spawns_left then
            BAI:Animate(spawns, 1, "FadeIn")
        end
        if self.show_time_left then
            BAI:Animate(time, 1, "FadeIn")
        end
    else -- Hide them
        BAI:Animate(spawns, 0, "FadeOut")
        BAI:Animate(time, 0, "FadeOut")
    end
end

function HUDAssaultCorner:UpdateAssaultText(text)
    local text_title = self._hud_panel:child("assault_panel"):child("control_assault_title")
    if utf8.len(managers.localization:text(text)) > 8 then
        self:UpdateAssaultTextFontSize(text, text_title)
    else
        text_title:set_font_size(22 * multiplier * pdth_hud.Options:GetValue("HUD/Scale"))
        text_title:set_text(utf8.to_upper(managers.localization:text(text)))
        managers.hud:make_fine_text(text_title)
        text_title:set_center_x(self._hud_panel:child("assault_panel"):child("icon_assaultbox"):center_x())
        --text_title:set_center_y(self._hud_panel:child("assault_panel"):child("icon_assaultbox"):center_y())
    end
end

function HUDAssaultCorner:UpdateAssaultTextFontSize(text, text_title)
    local assault_box_icon = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
    local scale = pdth_hud.Options:GetValue("HUD/Scale")
    for i = 21, 1, -1 do --Start at 21, end at 1, step by -1
        text_title:set_font_size(i * multiplier * scale)
        text_title:set_text(utf8.to_upper(managers.localization:text(text)))
        managers.hud:make_fine_text(text_title)
        text_title:set_center_x(assault_box_icon:center_x())
        if text_title:w() < assault_box_icon:w() then
            break -- Exit from loop, because the text is now fully visible and not cut off.
        end
    end
end

function HUDAssaultCorner:UpdateAssaultState(state)
    if not self._assault_vip and not self._assault_endless and not self._point_of_no_return then
        if BAI:GetOption("show_assault_states") then
            if state and self.assault_state ~= state then
                self.assault_state = state
                BAI:SyncAssaultState(state)
                BAI:CallEvent("AssaultStateChange", state)
                if state == "build" then
                    self:UpdateAssaultText(self:TryToShowEasterEgg("hud_" .. state, state))
                    self:_update_assault_hud_color(BAI:GetColor(state))
                    return
                end
                if BAI:IsStateDisabled(state) then
                    if BAI:IsOr(state, "control", "anticipation") then
                        if self._assault then
                            self._assault = false
                            self:_close_assault_box()
                        end
                    else
                        if self._assault then
                            if BAI.settings.show_advanced_assault_info and self.is_client then
                                LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                            end
                            self:_animate_update_assault_hud_color(self._assault_color)
                            self:UpdateAssaultText(self:GetAssaultText())
                        end
                    end
                    return
                end
                if BAI:IsOr(state, "control", "anticipation") then
                    if not self._assault then
                        self.trigger_assault_start_event = false
                        self:_start_assault(self:_get_state_strings(state))
                        self:UpdateAssaultText("hud_" .. state)
                        self.trigger_assault_start_event = true
                    else
                        if state == "anticipation" then
                            self:UpdateAssaultText("hud_anticipation")
                        end
                    end
                else
                    if BAI.settings.show_advanced_assault_info and self.is_client then
                        LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                    end
                    self:UpdateAssaultText(self:TryToShowEasterEgg("hud_" .. state, state))
                end
                if state == "control" then
                    self:_update_assault_hud_color(BAI:GetColor(state))
                else
                    self:_animate_update_assault_hud_color(BAI:GetColor(state))
                end
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

local _BAI_UpdateAssaultStateOverride = HUDAssaultCorner.UpdateAssaultStateOverride
function HUDAssaultCorner:UpdateAssaultStateOverride(state, override)
    _BAI_UpdateAssaultStateOverride(self, state, override)
    if not self._assault_vip and not self._assault_endless and not self._point_of_no_return then
        if BAI:GetOption("show_assault_states") then
            if state then
                if BAI:IsOr(state, "control", "anticipation") then
                    if BAI:IsStateDisabled(state) then
                        self:_close_assault_box()
                        return
                    end
                    self:UpdateAssaultText("hud_" .. state)
                else
                    if BAI:IsStateDisabled(state) then
                        self:UpdateAssaultText(self:GetAssaultText())
                        self:_animate_update_assault_hud_color(self._assault_color)
                        return
                    end
                    self:UpdateAssaultText(self:TryToShowEasterEgg("hud_" .. state, state))
                end
                self:_animate_update_assault_hud_color(BAI:GetColor(state))
            end
        end
    end
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
end

function HUDAssaultCorner:SetNormalAssaultOverride()
    if self.is_client and self.level_id == "hox_1" then
        self:SetTimeLeft(5)
    end
    self._assault_endless = false
    if BAI:GetOption("show_assault_states") then
        if self.is_host then
            self:UpdateAssaultStateOverride(managers.groupai:state():GetAssaultState())
        else
            if not self.CompatibleHost then
                self:_animate_update_assault_hud_color(self._assault_color)
                self:UpdateAssaultText(self:GetAssaultText())
            end
        end
    else
        self:_animate_update_assault_hud_color(self._assault_color)
        self:UpdateAssaultText(self:GetAssaultText())
        if BAI.settings.show_advanced_assault_info and self.is_client then
            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
        end
    end
    if BAI:IsHostagePanelVisible("assault") then
        self:_show_hostages()
    end
    BAI:CallEvent(BAI.EventList.NormalAssaultOverride)
end

function HUDAssaultCorner:UpdateAssaultStateColor(state, force_update)
    self:SetVariables()
    if state then
        if BAI:IsStateDisabled(state) then
            return
        end
        self:_animate_update_assault_hud_color(BAI:GetColor(state))
        self._hud_panel:child("assault_panel"):child("control_assault_title"):animate(callback(self, self, "_animate_text_change_assault_state"), state)
        if force_update and self.is_host then
            self:UpdateAssaultState(managers.groupai:state():GetAssaultState())
        end
    end
end

function HUDAssaultCorner:UpdateAssaultColor(color, assault_type)
    self:_animate_update_assault_hud_color(BAI:GetColor(color))
    self._hud_panel:child("assault_panel"):child("control_assault_title"):animate(callback(self, self, "_animate_text_change_normal_assault"), assault_type)
end

function HUDAssaultCorner:_animate_text_change_normal_assault(panel, assault_type)
    wait(0.1)
    if BAI:IsOr(assault_type, "normal", "captain") then
        if assault_type == "captain" then
            self:UpdateAssaultText("hud_captain")
        else
            self:SetHook(BAI.settings.show_advanced_assault_info)
            self:UpdateAssaultText(self:GetAssaultText())
        end
    elseif assault_type == "endless_assault" then
        self:UpdateAssaultText("hud_endless")
    else
        self:UpdateAssaultText("hud_survived")
    end
    if BAI:IsHostagePanelHidden() then
        self:_hide_hostages()
        if assault_type ~= "wave_survived" then
            if BAI:IsHostagePanelVisible(assault_type) then
                self:_show_hostages()
            end
        end
    end
    self:SetVariables()
end

function HUDAssaultCorner:_animate_text_change_assault_state(panel, state)
    wait(0.1)
    if BAI:IsOr(state, "control", "anticipation") then
        self:UpdateAssaultText("hud_" .. state)
        self:_animate_update_assault_hud_color(BAI:GetColor(state))
    else
        self:UpdateAssaultText("hud_" .. state)
        self:SetHook(BAI.settings.show_advanced_assault_info)
        self:_animate_update_assault_hud_color(BAI:GetColor(state))
        if BAI:IsHostagePanelHidden() then
            if BAI:IsHostagePanelVisible("assault") then
                self:_show_hostages()
            else
                self:_hide_hostages()
            end
        end
    end
end

function HUDAssaultCorner:GetAssaultText()
    if BAI:ShowFSSAI() and BAI:IsCustomTextDisabled("assault") then
        return "hud_fss_mod_" .. math.random(1, 3)
    end
    if BAI:GetOption("show_difficulty_name_instead_of_skulls") and not self.is_crimespree then
        if self:GetDifficultyName() ~= Idstring("risk") then -- For instances where "tweak_data is nil"
            return name
        end
    end
    return "hud_assault"
end

function HUDAssaultCorner:TryToShowEasterEgg(text, text_id)
    if BAI:ShowFSSAI() and BAI:IsCustomTextDisabled(text_id) then
        return "hud_fss_mod_" .. math.random(1, 3)
    end
    return text
end

function HUDAssaultCorner:_set_text_list(text_list)
end