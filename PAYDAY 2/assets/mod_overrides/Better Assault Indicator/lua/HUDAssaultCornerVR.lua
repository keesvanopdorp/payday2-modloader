local _vr_f_init = HUDAssaultCornerVR.init
function HUDAssaultCornerVR:init(hud, full_hud, tweak_hud)
    _vr_f_init(self, hud, full_hud, tweak_hud)
    log("[BAI] VR Mode Initialized")
end

function HUDAssaultCornerVR:show_point_of_no_return_timer()
    local delay_time = self._assault and 1.2 or 0

    self:_close_assault_box()
    self._hud_panel:child("point_of_no_return_panel"):stop()
    self._hud_panel:child("point_of_no_return_panel"):animate(callback(self, self, "_animate_show_noreturn"), delay_time)
    self._watch_point_of_no_return_timer:set_visible(true)
    self:_set_feedback_color(self._noreturn_color)

    self._point_of_no_return = true

    managers.hud._hud_heist_timer:hide()
end