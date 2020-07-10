local BAI = BAI
function HUDAssaultCorner:_set_text_list(text_list)
    self:set_text("assault", text_list)
end

function HUDAssaultCorner:GetRisk()
    local difficulty = ""
    if self.is_crimespree then
        difficulty = managers.localization:to_upper_text("menu_cs_level", {
            level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")
        })
    elseif BAI:GetOption("show_difficulty_name_instead_of_skulls") then
        difficulty = self:GetDifficultyName()
    else
        for i = 1, managers.job:current_difficulty_stars() do
            difficulty = difficulty .. managers.localization:get_default_macro("BTN_SKULL")
        end
    end
    return difficulty
end

function HUDAssaultCorner:_get_state_strings(state)
    local difficulty = self:GetRisk()
    local state_text = "hud_" .. state
    return (managers.localization:to_upper_text(state_text) .. " " .. difficulty)
end

function HUDAssaultCorner:_get_assault_strings(state, aai) -- Apply Holy water after reading this
    local difficulty = self:GetRisk()
    if self._assault_mode == "normal" then
        local assault_text = "hud_assault_assault"
        local hud_state
        if state and BAI:IsOr(state, "build", "sustain", "fade") and BAI:GetOption("show_assault_states") then
            hud_state = managers.localization:to_upper_text("hud_" .. state)
        end
        if BAI:GetOption("hide_assault_text") and hud_state then
            return hud_state .. " " .. difficulty
        end
        local return_text = managers.localization:to_upper_text(assault_text .. self:GetFactionAssaultText())
        if hud_state then
            return_text = return_text .. " " .. hud_state .. " " .. difficulty
        else
            return_text = return_text .. " " .. difficulty
        end
        return return_text
    else
        return (managers.localization:to_upper_text("hud_assault_vip") .. " " .. difficulty)
    end
end

function HUDAssaultCorner:_get_assault_endless_strings()
    local difficulty = self:GetRisk()
    local return_text = "hud_assault_endless"
    return_text = return_text .. self:GetFactionAssaultText()
    return (managers.localization:to_upper_text(return_text) .. " " .. difficulty)
end

function HUDAssaultCorner:_get_survived_assault_strings(endless)
    local difficulty = self:GetRisk()
    local survived_text = "hud_assault_survived" .. (endless and "_endless" or "")
    if BAI:IsCustomTextEnabled("survived") then
        survived_text = "hud_assault_survived"
    else
        survived_text = survived_text .. self:GetFactionAssaultText(true)
    end
    return (managers.localization:to_upper_text(survived_text) .. " " .. difficulty)
end

function HUDAssaultCorner:_start_assault(s)
	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
	if alive(self._wave_bg_box) then
        local panel = self._hud_panel:child("wave_panel")
	    local wave_text = panel:child("num_waves")
		local num_waves = self._wave_bg_box:child("num_waves")
	    num_waves:set_text(self:get_completed_waves_string())
		self._hud_panel:child("wave_panel"):set_visible(true)
    end

    icon_assaultbox:set_color(Color("ffcc66"))
    local started_now = not self._assault
    self._assault = true

    self:set_text("assault", s)
	assault_panel:animate(callback(self, self, "animate_assault_in_progress"))

    self._opened = true
    if self.was_endless then
        self.was_endless = false
        self:SetImage("assault")
    end

    if started_now and self.is_skirmish then
        self:_popup_wave_started()
    end

    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        if BAI:GetOption("show_assault_states") and self.is_skirmish then
            self:_popup_wave_started()
        end
        BAI:CallEvent(BAI.EventList.AssaultStart)
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
	self._remove_hostage_offset = true
	self._start_assault_after_hostage_offset = nil
	local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
    icon_assaultbox:stop()
    if self:should_display_waves() then
        self.wave_survived = true
        self._assault = true
        self:_start_assault(self:_get_survived_assault_strings())
        self:_update_assault_hud_color(self._assault_survived_color)
        icon_assaultbox:animate(callback(self, self, "_animate_wave_completed"), self)
        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            self.wave_survived = true
            self:_start_assault(self:_get_survived_assault_strings(endless_assault))
            self:_update_assault_hud_color(self._assault_survived_color)
            if endless_assault then
                self.wave_survived_endless = true
                self:SetImage("padlock")
            end
            icon_assaultbox:animate(callback(self, self, "_animate_normal_wave_completed"), self)
        else
            if BAI:GetOption("show_assault_states") then
                self:UpdateAssaultStateOverride("control", true)
            else
                self:_close_assault_box()
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
    local wave_text = self._wave_bg_box:child("num_waves")

    wait(1.4)
    wave_text:set_text(self:get_completed_waves_string())
    wait(7.2)
    if BAI:GetOption("show_assault_states") then
        self:UpdateAssaultStateOverride("control")
    else
        assault_hud:_close_assault_box()
    end
    self.wave_survived = false
end

function HUDAssaultCorner:_close_assault_box()
    local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
    icon_assaultbox:stop()
    local function close_done()
        icon_assaultbox:stop()
        icon_assaultbox:animate(callback(self, self, "_hide_icon_assaultbox"))
        self:sync_set_assault_mode("normal")
    end
    self._bg_box:stop()
    self._hud_panel:child("assault_panel"):animate(callback(nil, _G, "set_alpha"), 0)	
    self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), close_done)
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    if self.was_endless then
        self:SetImage("assault")
        self.was_endless = false
    end
    self:_set_text_list(self:_get_state_strings(state))
    self:_animate_update_assault_hud_color(BAI:GetColor(state))
    if override then
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):stop()
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):animate(callback(self, self, "_show_icon_assaultbox"))
    end
end

local _BAI_InitAAIPanel = HUDAssaultCorner.InitAAIPanel
function HUDAssaultCorner:InitAAIPanel()
    _BAI_InitAAIPanel(self)
    if not self.AAIPanel then
        return
    end

    local c = Color("ff80df")
    local c2 = Color("66ffff")
    self._hud_panel:child("time_panel"):child("time_icon"):set_color(c)
    self._hud_panel:child("spawns_panel"):child("spawns_icon"):set_color(c)
    self._time_bg_box:child("time_left"):set_color(c2)
    self._time_bg_box:child("bg"):hide()
    self._spawns_bg_box:child("spawns_left"):set_color(c2)
    self._spawns_bg_box:child("bg"):hide()

    local right

    if self:should_display_waves() then
        right = self._hud_panel:child("wave_panel"):left() - 3
    else
        right = self._hud_panel:w() - 92
    end

    self._hud_panel:child("time_panel"):set_right(right)

    if BAI:IsHostagePanelHidden() then
        self._hud_panel:child("time_panel"):set_x(self._hud_panel:w() - self._hud_panel:child("time_panel"):w())
    end

    self._hud_panel:child("spawns_panel"):set_right(self._hud_panel:child("time_panel"):left() - 3)
end

local _BAI_InitCaptainPanel = HUDAssaultCorner.InitCaptainPanel
function HUDAssaultCorner:InitCaptainPanel()
    _BAI_InitCaptainPanel(self)
    if not self.AAIPanel then
        return
    end

    self._hud_panel:child("captain_panel"):child("captain_icon"):set_color(Color("ff80df"))
    self._captain_bg_box:child("num_reduction"):set_color(Color("66ffff"))
    self._captain_bg_box:child("bg"):hide()

    if BAI:IsHostagePanelVisible("captain") then
        self._hud_panel:child("captain_panel"):set_right(self._hud_panel:w() - 92)
    else
        self._hud_panel:child("captain_panel"):set_x(self._hud_panel:w() - 70)
    end
end

function BAIAnimation:ColorChange(o, new_color, color_function, old_color)
    local oa = managers.hud._hud_assault_corner._hud_panel:child("assault_panel")
    new_color = new_color or Color.white
    color_function = color_function or o.set_color
    old_color = old_color or o:color()
    local t = 0

    while t < 1 do
        t = t + coroutine.yield()
        local r = old_color.r + (t * (new_color.r - old_color.r))
        local g = old_color.g + (t * (new_color.g - old_color.g))
        local b = old_color.b + (t * (new_color.b - old_color.b))
        color_function(Color(oa:alpha(), r, g, b), true) -- Changed 255 to alpha
    end
    color_function(new_color, true)
end

function BAIAnimation:AAIPanel(p, bg)
    local t = managers.hud._hud_assault_corner[bg]:child((bg == "_time_bg_box" and "time_" or "spawns_") .. "left")
    self:FadeIn(p)
    for i = 1, 3, 1 do
        set_alpha(t, 0.6)
	    set_alpha(t, 1)
    end
end

local _f_set_hostage_offseted = HUDAssaultCorner._set_hostage_offseted
function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    _f_set_hostage_offseted(self, is_offseted)
    if self:should_display_waves() then
        local wave_panel = self._hud_panel:child("wave_panel")
        wave_panel:stop()
        wave_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)
    end
end

function HUDAssaultCorner:_offset_hostages(o, is_offseted)
    local t = 0
    local from = o:y()
    local target = is_offseted and self._hud_panel:child("assault_panel"):bottom() or 0
    while t < 0.5 do
        t = t + coroutine.yield()
		o:set_top(math.lerp(from, target, math.sin(t * 200)))
    end
    o:set_top(target)
end

local _f_update_assault_hud_color = HUDAssaultCorner._update_assault_hud_color
function HUDAssaultCorner:_update_assault_hud_color(color)
    _f_update_assault_hud_color(self, color)
    self._hud_panel:child("assault_panel"):child("text"):set_color(color)
end

function HUDAssaultCorner:_hide_hostages()
	self._hud_panel:child("hostages_panel"):animate(callback(nil, _G, "set_alpha"), 0)
end

function HUDAssaultCorner:_show_hostages()
	if not self._point_of_no_return then
		self._hud_panel:child("hostages_panel"):animate(callback(nil, _G, "set_alpha"), 1)
	end
end

local function sign(v)
	return (v >= 0 and 1) or -1
end

local function round(v, bracket)
    bracket = bracket or 1
	return math.floor(v / bracket + sign(v) * 0.5) * bracket
end

function HUDAssaultCorner:SetCaptainBuff(buff)
    if not (self.AAIPanel and BAI.settings.advanced_assault_info.captain_panel) then
        return
    end
    self._captain_bg_box:child("num_reduction"):set_text((round(buff, 0.01) * 100) .. "%")
    self._captain_bg_box:child("num_reduction"):stop()
    self._captain_bg_box:child("num_reduction"):animate(function(o)
        set_alpha(o, 0.6)
        set_alpha(o, 1)
        set_alpha(o, 0.6)
        set_alpha(o, 1)
    end)
end