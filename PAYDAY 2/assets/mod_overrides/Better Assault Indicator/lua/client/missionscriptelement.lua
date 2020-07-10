local heists = { "rvd2", "red2", "vit" }
local id = { 100023, 101685, 102042 }
local requested_id = nil
local _f_on_executed = MissionScriptElement.client_on_executed
function MissionScriptElement:client_on_executed()
    _f_on_executed(self)
    if self._id == requested_id then
        managers.hud:SetEndlessClient(true, true)
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