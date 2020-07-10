local _f_on_executed = MissionScriptElement.client_on_executed
function MissionScriptElement:client_on_executed()
    _f_on_executed(self)
    if self._id == 100075 or self._id == 200350 then
        managers.hud:SetEndlessClient(true, false)
    end
end