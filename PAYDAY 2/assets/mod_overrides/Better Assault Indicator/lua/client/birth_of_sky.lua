local function Between(number, start_n, end_n, inclusive)
    if inclusive then
        return number >= start_n and number <= end_n
    else
        return number > start_n and number < end_n
    end
end

if core then
    core:module("CoreElementUnitSequenceTrigger")
    core:import("CoreMissionScriptElement")
    core:import("CoreCode")
end

function ElementUnitSequenceTrigger:client_on_executed(...) --Added new function to ElementUnitSequenceTrigger
    if self._id == 100072 or Between(self._id, 100133, 100135, true) then
        managers.hud:SetEndlessClient(true)
    end
end