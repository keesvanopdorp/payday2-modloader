function HUDAssaultCorner:SetImage(image)
end

local _BAI_start_assault = HUDAssaultCorner._start_assault
function HUDAssaultCorner:_start_assault(text_list)
    _BAI_start_assault(self, text_list)
    if BAI:IsHostagePanelHidden(self.assault_type) then
        self:_hide_hostages()
    end
end

function HUDAssaultCorner:_end_assault()
    if not self._assault then
        self._start_assault_after_hostage_offset = nil

        return
    end

    self:RemoveASCalls()

    self:_set_feedback_color(nil)

    self._assault = false
    local endless_assault = self._assault_endless
    self._assault_endless = false
    self.assault_type = nil
    local box_text_panel = self._assault_panel_v2:child("text_panel")

    box_text_panel:stop()
    box_text_panel:clear()

    --box_text_panel:animate(ClassClbk(self, "_hide_blink"))

    self._remove_hostage_offset = true
    self._start_assault_after_hostage_offset = nil

    if self:should_display_waves() then
        self.wave_survived = true
        self:_update_assault_hud_color(self._assault_survived_color)
        self:_set_text_list(self:_get_survived_assault_strings())
        box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
        self._wave_bg_box:stop()
        self._wave_bg_box:animate(callback(self, self, "_animate_wave_completed"), self)
        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            self:_update_assault_hud_color(self._assault_survived_color)
            self.wave_survived = true
            self.wave_survived_endless = endless_assault
            self:_set_text_list(self:_get_survived_assault_strings(endless_assault))
            box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
            box_text_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
        else
            if BAI:GetOption("show_assault_states") then
                self:UpdateAssaultStateOverride("control")
                if BAI:IsHostagePanelVisible() then
                    self:_show_hostages()
                end
            else
                self:_set_text_list(self:_get_incoming_textlist())
                self:_update_assault_hud_color(Color.white)
                box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
            end
        end
    end
    if not self.dont_override_endless then
        self.endless_client = false
    end
    BAI:CallEvent(BAI.EventList.AssaultEnd)
    self.trigger_assault_start_event = true -- Used for AssaultStart event; bugfix
end

function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud)
    local wave_text = panel:child("num_waves")
    local bg = panel:child("bg")

    wait(1.4)
    wave_text:set_text(self:get_completed_waves_string())
    bg:stop()
    bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
    wait(7.2)
    if BAI:GetOption("show_assault_states") then
        self:UpdateAssaultStateOverride("control")
    else
        self:_set_text_list(self:_get_incoming_textlist())
        self:_animate_update_assault_hud_color(Color.white)
    end
    self.wave_survived = false
    if BAI:IsHostagePanelVisible() then
        self:_show_hostages()
    end
end

function HUDAssaultCorner:_animate_normal_wave_completed(panel, assault_hud)
    wait(8.6)
    self.wave_survived = false
    self.wave_survived_endless = false
    if BAI:GetOption("show_assault_states") then
        self:UpdateAssaultStateOverride("control")
        if BAI:IsHostagePanelVisible() then
            self:_show_hostages()
        end
    else
        self:_set_text_list(self:_get_incoming_textlist())
        self:_animate_update_assault_hud_color(Color.white)
    end
end

function HUDAssaultCorner:show_point_of_no_return_timer()
    self._point_of_no_return = true

    local delay_time = self._assault and 1.2 or 0
    local box_text_panel = self._assault_panel_v2:child("text_panel")
    box_text_panel:stop()
    box_text_panel:clear()
    box_text_panel:animate(ClassClbk(self, "_animate_show_noreturn"), delay_time)
    self.NoReturnText:animate(ClassClbk(self, "_show_blink"))
    self:_set_feedback_color(self._noreturn_color)
    self:_animate_update_assault_hud_color(self._noreturn_color)
    self:_start_assault(self:_get_no_return_textlist())
end

function HUDAssaultCorner:_hide_hostages()
    self.num_hostages:set_visible(false)
end

function HUDAssaultCorner:_show_hostages()
    self.num_hostages:set_visible(true)
end

function HUDAssaultCorner:UpdateAssaultStateColor(state, force_update)
    if state then
        if BAI:IsStateDisabled(state) then
            return
        end
        self:_animate_update_assault_hud_color(BAI:GetColor(state))
        self._assault_panel_v2:child("text_panel"):animate(callback(self, self, "_animate_text_change_assault_state"), state)
        if force_update and self.is_host then
            self:UpdateAssaultStateOverride(managers.groupai:state():GetAssaultState())
        end
    end
end

function HUDAssaultCorner:UpdateAssaultColor(color, assault_type)
    self:_animate_update_assault_hud_color(BAI:GetColor(color))
    self._assault_panel_v2:child("text_panel"):animate(callback(self, self, "_animate_text_change_normal_assault"), assault_type)
end

function HUDAssaultCorner:UpdatePONRBox()
    if not self._point_of_no_return then
        --[[local assault_panel_v2 = self._assault_panel_v2
        local PointOfNoReturnPanel = self._hud_panel:panel({
            w = 120,
            h = 40
        })
        PointOfNoReturnPanel:set_top(0)
        PointOfNoReturnPanel:set_right(assault_panel_v2:left())

        local NoReturnChronoPanel = self._hud_panel:panel({
            y = 0,
            h = 40,
            layer = 0,
            valign = "top"
        })

        self.NoReturnText = NoReturnChronoPanel:text({
            font = "fonts/font_eurostile_ext",
            font_size = 28,
            vertical = "top",
            align = "center",
            text = "0:00",
            color = BAI:GetColor("escape"),
            alpha = 0
        })]]
        self._point_of_no_return_color = BAI:GetColor("escape")
        self.NoReturnText:set_color(self._point_of_no_return_color)
    end
end

function HUDAssaultCorner:_animate_text(text_panel, bg_box, color, color_function, speed_text)
    local text_list = (bg_box or self._assault_banner):script().text_list
    local text_index = 0
    local texts = {}
    local padding = 10
    
    local function create_new_text(text_panel, text_list, text_index, texts)
        if texts[text_index] and texts[text_index].text then
            text_panel:remove(texts[text_index].text)

            texts[text_index] = nil
        end

        local text_id = text_list[text_index]
        local text_string = ""

        if type(text_id) == "string" then
            text_string = managers.localization:to_upper_text(text_id)
        elseif text_id == Idstring("risk") then
            local use_stars = true

            if managers.crime_spree:is_active() then
                text_string = text_string .. managers.localization:to_upper_text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")})
                use_stars = false
            end

            if use_stars then
                for i = 1, managers.job:current_difficulty_stars(), 1 do
                    text_string = text_string .. managers.localization:get_default_macro("BTN_SKULL")
                end
            end
        end

        local font_type = "fonts/font_medium_mf" -- Changed line

        if NepgearsyHUDReborn.Options:GetValue("AssaultBarFont") then
            if NepgearsyHUDReborn.Options:GetValue("AssaultBarFont") == 2 then
                font_type = "fonts/font_eurostile_ext"
            elseif NepgearsyHUDReborn.Options:GetValue("AssaultBarFont") == 3 then
                font_type = "fonts/font_pdth"
            end
        end

        local mod_color = color_function and color_function() or color or self._assault_color
        local text = text_panel:text({
            vertical = "center",
            h = 10,
            w = 10,
            align = "center",
            blend_mode = "add",
            layer = 1,
            text = text_string,
            color = mod_color,
            font_size = tweak_data.hud_corner.assault_size,
            font = font_type
        })
        local _, _, w, h = text:text_rect()

        text:set_size(w, h)

        texts[text_index] = {
            x = text_panel:w() + w * 0.5 + padding * 2,
            text = text
        }
    end

    while true do
        local dt = coroutine.yield()
        local last_text = texts[text_index]

        if last_text and last_text.text then
            if last_text.x + last_text.text:w() * 0.5 + padding < text_panel:w() then
                text_index = text_index % #text_list + 1

                create_new_text(text_panel, text_list, text_index, texts)
            end
        else
            text_index = text_index % #text_list + 1

            create_new_text(text_panel, text_list, text_index, texts)
        end

        local speed = speed_text or 90

        for i, data in pairs(texts) do
            if data.text then
                data.x = data.x - dt * speed

                data.text:set_center_x(data.x)
                data.text:set_center_y(text_panel:h() * 0.5)

                if data.x + data.text:w() * 0.5 < 0 then
                    text_panel:remove(data.text)

                    data.text = nil
                elseif color_function then
                    data.text:set_color(color_function())
                end
            end
        end
    end
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    self:_set_text_list(self:_get_state_strings(state))
    self:_animate_update_assault_hud_color(BAI:GetColor(state))
    if override then
        self._assault_panel_v2:child("text_panel"):animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
    end
end

function HUDAssaultCorner:_set_hostages_offseted(is_offseted)
end

local _f_set_control_info = HUDAssaultCorner.set_control_info
function HUDAssaultCorner:set_control_info(data)
    if not self.num_hostages:visible() then
        self.num_hostages:set_text(data.nr_hostages)
        return
    end
    _f_set_control_info(self, data)
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetAnimationOption("enable_animations") and BAI:GetAnimationOption("animate_color_change") then
        self._assault_panel_v2:child("text_panel"):animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"), self._current_assault_color)
    else
        self:_update_assault_hud_color(color)
    end
end