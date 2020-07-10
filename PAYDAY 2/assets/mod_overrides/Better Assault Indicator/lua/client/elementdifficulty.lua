local _f_on_executed = ElementDifficulty.client_on_executed
function ElementDifficulty:client_on_executed(...)
    _f_on_executed(self, ...)
    if self._id == 100887 then
        managers.hud:SetEndlessClient(true, true)
    end
end