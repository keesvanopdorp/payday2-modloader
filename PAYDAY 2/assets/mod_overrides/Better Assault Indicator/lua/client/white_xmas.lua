core:import("CoreMissionScriptElement")
core:import("CoreClass")

local _f_on_executed = MissionScriptElement.client_on_executed
function MissionScriptElement:client_on_executed()
    _f_on_executed(self)
    if self._id == 101473 then
        managers.hud._hud_assault_corner:WhiteXmasEndlessAssault()
    end
end

function HUDAssaultCorner:WhiteXmasEndlessAssault()
    if not self._assault_vip then
        self.endless_client = true
    end
end