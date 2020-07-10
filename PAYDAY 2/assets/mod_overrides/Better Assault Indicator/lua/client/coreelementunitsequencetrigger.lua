if core then
    core:module("CoreElementUnitSequenceTrigger")
    core:import("CoreMissionScriptElement")
    core:import("CoreCode")
end

local heists = { "glace", "peta2", "hox_2", "ukrainian_job" }
local id = { 100131, 101723, 101890, 101371 }
local override = false
local requested_id = nil
local dont_trigger_again = false
function ElementUnitSequenceTrigger:client_on_executed(...) --Added new function to ElementUnitSequenceTrigger
    if not dont_trigger_again then
        if self._id == requested_id then
            dont_trigger_again = true
            managers.hud:SetEndlessClient(true, override)
        end
    end
end

function GetID()
    for k, v in pairs(heists) do
        if Global.game_settings.level_id == v then
            if v ~= "hox_2" and v ~= "ukrainian_job" then
                override = true
            end
            requested_id = id[k]
            break
        end
    end
end

GetID()