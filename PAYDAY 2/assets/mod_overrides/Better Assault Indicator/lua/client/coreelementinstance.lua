if core then
    core:module("CoreElementInstance")
    core:import("CoreMissionScriptElement")
end

local heists = { "born", "dah", "man", "jolly", "dinner", "kenaz" }
local id = { 100720, 104949, 102754, 100781, 104979, 100379 }
local override = false
local requested_id = nil
local _f_on_executed = ElementInstanceOutputEvent.client_on_executed
local dont_trigger_again = false
function ElementInstanceOutputEvent:client_on_executed(...)
    _f_on_executed(self, ...)
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
            if v ~= "dinner" then
                override = true
            end
            requested_id = id[k]
            break
        end
    end
end

GetID()