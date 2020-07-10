if core then
    core:module("CoreElementCounter")
    core:import("CoreMissionScriptElement")
    core:import("CoreClass")
end

local heists = { "mad", "sah" }
local id = { 100523, 101177 }
local requested_id = nil
local dont_trigger_again = false
function ElementCounter:client_on_executed(...)
    if not dont_trigger_again then
        if self._id == requested_id and self._values.counter_target == 2 then
            dont_trigger_again = true
            managers.hud:SetEndlessClient(true, true)
        end
    end
end

function GetID()
    for k, v in pairs(heists) do
        if Global.game_settings.level_id == v then
            requested_id = id[k]
            break
        end
    end
end

GetID()