if core then
    core:import("CoreMissionScriptElement")
end

local dont_trigger_again = false
function ElementEnemyPreferedAdd:client_on_executed(...) --Added new function to ElementEnemyPreferedAdd
    if not dont_trigger_again then
        if self._id == 101239 then
            dont_trigger_again = true
            managers.hud:SetEndlessClient(true, true)
        end
    end
end