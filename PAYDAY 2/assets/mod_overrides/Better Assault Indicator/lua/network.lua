Hooks:Add("NetworkReceivedData", "NetworkReceivedData_BAI", function(sender, id, data)
    if id == BAI.SyncMessage then
        if data == BAI.data.EA then -- Client
            managers.hud:SetEndlessClient()
        end
        if data == BAI.data.BAI_Q then -- Host
            LuaNetworking:SendToPeer(sender, id, BAI.data.BAI_A)
        end
        if data == BAI.data.BAI_A then -- Client
            managers.hud:SetCompatibleHost(true)
            LuaNetworking:SendToPeer(1, id, BAI.data.EA_Q)
            LuaNetworking:SendToPeer(1, BAI.EE_SyncMessage, BAI.data.EE_FSS1_Q)
            --LuaNetworking:SendToPeer(1, id, BAI.data.ResendAS)
        end
        if data == BAI.data.EA_Q then -- Host
            if managers.hud:GetAssaultMode() ~= "phalanx" and managers.groupai:state():get_hunt_mode() then -- Notifies drop-in client about Endless Assault in progress
                LuaNetworking:SendToPeer(sender, id, BAI.data.EA)
            end
        end
        if data == BAI.data.NA_O then -- Client
            managers.hud:SetNormalAssaultOverride()
        end
        if data == BAI.data.ResendAS then -- Host
            LuaNetworking:SendToPeer(sender, BAI.ASO_SyncMessage, managers.groupai:state():GetAssaultState())
        end
        if data == BAI.data.ResendTime then -- Host
            managers.hud:GetAssaultTime(sender)
        end
    end
    if id == BAI.AS_SyncMessage then -- Client
        if BAI:GetOption("show_assault_states") then
            managers.hud:UpdateAssaultState(data)
        end
    end
    if id == "AssaultStates_Net" then
        if BAI:GetOption("show_assault_states") then
            if data == "control" and not managers.hud._hud_assault_corner._assault then
                managers.hud:UpdateAssaultState("control")
                return
            end
            if data == "control" and BAI.settings.show_wave_survived then
                return
            end
            if BAI:IsOr(data, "anticipation", "build") then
                return
            end
            managers.hud:UpdateAssaultState(data)
        end
    end
    if id == BAI.ASO_SyncMessage then -- Client
        if BAI:GetOption("show_assault_states") then
            managers.hud:UpdateAssaultStateOverride(data, true)
        end
    end
    if id == BAI.AAI_SyncMessage then -- Client
        managers.hud:SetTimeLeft(data)
    end
    if id == BAI.EE_SyncMessage then
        if data == BAI.data.EE_FSS1_Q then -- Host
            if BAI.EasterEgg.FSS.AIReactionTimeTooHigh then
                LuaNetworking:SendToPeer(sender, id, BAI.data.EE_FSS1_A)
            end
        end
        if data == BAI.data.EE_FSS1_A then -- Client
            BAI.EasterEgg.FSS.AIReactionTimeTooHigh = true
        end
    end
    if id == BAI.EE_ResetSyncMessage then
        BAI.EasterEgg.FSS.AIReactionTimeTooHigh = false
        LuaNetworking:SendToPeer(1, BAI.EE_SyncMessage, BAI.data.EE_FSS1_Q)
    end

    -- KineticHUD
    if id == BAI.HUD.KineticHUD.DownCounter then
        managers.hud:SetCompatibleHost()
    end
    if id == BAI.HUD.KineticHUD.SyncAssaultPhase then
        if BAI:GetOption("show_assault_states") then
            data = utf8.to_lower(data)
            if data == "control" and BAI:GetOption("show_wave_survived") then
                return
            end
            if BAI:IsOr(data, "anticipation", "build", "regroup") then
                return
            end
            managers.hud:UpdateAssaultState(data)
        end
    end
    -- KineticHUD
end)

local function WhichOverride(current_level_id)
    if current_level_id == "spa" then
        return "elementdifficulty.lua"
    elseif current_level_id == "born" or current_level_id == "dah" or current_level_id == "man" or current_level_id == "jolly" or current_level_id == "dinner" or current_level_id == "kenaz" then
        return "coreelementinstance.lua"
    elseif current_level_id == "pbr" then
        return "beneath_the_mountain.lua"
    elseif current_level_id == "glace" or current_level_id == "peta2" or current_level_id == "hox_2" or current_level_id == "ukrainian_job" then
        return "coreelementunitsequencetrigger.lua"
    elseif current_level_id == "pbr2" then
        return "birth_of_sky.lua"
    elseif current_level_id == "hox_1" then
        return "elementareatrigger.lua"
    elseif current_level_id == "mad" or current_level_id == "sah" then
        return "coreelementcounter.lua"
    elseif current_level_id == "help" then
        return "elementenemypreferedadd.lua"
    elseif current_level_id == "crojob2" then
        return "the_bomb_dockyard.lua"
    elseif current_level_id == "pines" then
        return "white_xmas.lua"
    elseif current_level_id == "office_strike" then -- custom heist
        return "office_strike.lua"
    else --"rvd2", "red2", "vit"
        return "missionscriptelement.lua"
    end
end

local function IsPlayingSupportedHeistWithEA()
    local heists = { "rvd2", "dah", "red2", "glace", "dinner", "man", "mad", "pbr", "pbr2", "pines", "born", "hox_1", "hox_2", "kenaz", "crojob2", "jolly", "spa", "peta2", "ukrainian_job", "help", "sah", "vit" }
    local custom_heists = { "office_strike" }
    return table.contains(heists, Global.game_settings.level_id) or table.contains(custom_heists, Global.game_settings.level_id)
end

Hooks:Add("BaseNetworkSessionOnLoadComplete", "BaseNetworkSessionOnLoadComplete_BAI", function(local_peer, id)
    if not managers.hud then
        return
    end
    if Network:is_client() then
        LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.BAI_Q)
    end
    if Network:is_client() and not managers.hud:GetCompatibleHost() and IsPlayingSupportedHeistWithEA() then
        dofile(BAI.ClientPath .. WhichOverride(Global.game_settings.level_id))
    end
end)