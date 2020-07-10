-- Hoxton Breakout Day 1
function ElementAreaTrigger:client_on_executed(...) --Added new function to ElementAreaTrigger
    if self._id == 102160 then
        managers.hud:SetEndlessClient()
    elseif self._id == 102048 then
        managers.hud:SetNormalAssaultOverride()
    end
end