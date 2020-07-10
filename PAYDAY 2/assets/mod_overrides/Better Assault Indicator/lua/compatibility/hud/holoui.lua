function HUDAssaultCorner:SetImage(image)
end

local _BAI_start_assault = HUDAssaultCorner._start_assault
function HUDAssaultCorner:_start_assault(text_list)
    _BAI_start_assault(self, text_list)
    if alive(self._bg_box) then
        self._bg_box:stop()
        self._bg_box:child("text_panel"):stop()
        self._bg_box:show()
        self:left_grow(self._bg_box)
        self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), self._bg_box, nil, function() return managers.hud._hud_assault_corner:assault_attention_color_function() end)
        if alive(self._wave_bg_box) then
            self._wave_bg_box:child("bg"):stop()
        end
    end
    if BAI:IsHostagePanelHidden(self.assault_type) then
        self:_hide_hostages()
    end
end

function HUDAssaultCorner:_update_assault_hud_color(color)
    self._current_assault_color = color
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetHUDOption("holoui", "update_text_color") then
        if BAI:GetAnimationOption("enable_animations") and BAI:GetAnimationOption("animate_color_change") then
            self._bg_box:animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"), self._current_assault_color)
        else
            self:_update_assault_hud_color(color)
        end
    end
end

function HUDAssaultCorner:assault_attention_color_function()
    return BAI:GetHUDOption("holoui", "update_text_color") and self._current_assault_color or Holo:GetColor("TextColors/Assault")
end

function HUDAssaultCorner:show_point_of_no_return_timer()
    local delay_time = self._assault and 1.2 or 0
    self:_close_assault_box()
    local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
    self:_hide_hostages()
    point_of_no_return_panel:stop()
    point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
    self:_set_feedback_color(self._noreturn_color)
    self._point_of_no_return = true
    if BAI:GetHUDOption("holoui", "update_text_color") then
        self._noreturn_bg_box:child("point_of_no_return_text"):set_color(self._noreturn_color)
    end
    BAI:CallEvent(BAI.EventList.NoReturn, true)
end

function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
    local flash_timer
    if BAI:GetHUDOption("holoui", "update_text_color") then
        flash_timer = function(o)
            local t = 0
            while t < 0.5 do
                t = t + coroutine.yield()
                local n = 1 - math.sin(t * 180)
                local r = math.lerp(self._noreturn_color.r, 1, n)
                local g = math.lerp(self._noreturn_color.g, 0.8, n)
                local b = math.lerp(self._noreturn_color.b, 0.2, n)
                o:set_color(Color(r, g, b))
                local font_size = (tweak_data.hud_corner.noreturn_size)
                o:set_font_size(math.lerp(font_size, font_size * 1.25, n))
            end
        end
    else
        flash_timer = function(o)
            local t = 0
            while t < 0.5 do
                t = t + coroutine.yield()
                local font_size = (tweak_data.hud_corner.noreturn_size)
                o:set_font_size(math.lerp(font_size, font_size * 1.25, n))
            end
        end
    end
    local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
    point_of_no_return_timer:animate(flash_timer)
end

function HUDAssaultCorner:_show_icon_assaultbox(icon)
    icon:set_alpha(1)
    play_color(this._back_button, BAI:GetHUDOption("holoui", "update_text_color") and self._current_assault_color or Holo:GetColor("TextColors/Menu"))
    play_value(this._back_marker, "alpha", 360, {callback = function()
        icon:set_rotation(0)
    end})
end

local _BAI_InitAAIPanel = HUDAssaultCorner.InitAAIPanel
function HUDAssaultCorner:InitAAIPanel()
    _BAI_InitAAIPanel(self)
    if not self.AAIPanel then
        return
    end
    HUDBGBox_recreate(self._time_bg_box, {
        name = "Hostages",
        w = 107,
        h = 32,
    })
    HUDBGBox_recreate(self._spawns_bg_box, {
        name = "Hostages",
        w = 107,
        h = 32,
    })
end

local _BAI_InitCaptainPanel = HUDAssaultCorner.InitCaptainPanel
function HUDAssaultCorner:InitCaptainPanel()
    _BAI_InitCaptainPanel(self)
    if not self.AAIPanel then
        return
    end
    HUDBGBox_recreate(self._captain_bg_box, {
        name = "Hostages",
        w = 38,
        h = 32,
    })
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
    local bg = self._captain_bg_box
    bg:child("bg"):stop()
    local pbuff = bg:child("num_reduction")
    pbuff:stop()
    pbuff:set_text((round(buff, 0.01) * 100) .. "%")
    play_value(pbuff, "alpha", 0.25, {time = 1, callback = function()
        play_value(pbuff, "alpha", 1, {time = 1})
    end})
end