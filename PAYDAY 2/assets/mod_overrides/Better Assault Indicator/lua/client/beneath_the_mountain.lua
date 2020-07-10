if core then
    core:module("CoreElementInstance")
    core:import("CoreMissionScriptElement")
end

local _f_on_executed = ElementInstanceOutputEvent.client_on_executed
function ElementInstanceOutputEvent:client_on_executed(...)
    _f_on_executed(self, ...)
    if self._id == 100274 or self._id == 101774 then
        managers.hud:SetEndlessClient()
    end
    if self._id == 100287 then
        managers.hud:SetNormalAssaultOverride()
    end
end