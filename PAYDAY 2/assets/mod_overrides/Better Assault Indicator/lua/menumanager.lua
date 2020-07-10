BAI:Hook(MenuCallbackHandler, "resume_game", function(self)
    BAI:EasterEggInit()
    if managers.hud:IsHost() then
        LuaNetworking:SendToPeers(BAI.EE_ResetSyncMessage, "")
    end
    if BAI.Update then
        BAI.Update = false
        BAI:CallEvent(BAI.EventList.Update)
        BAI.SetVariables()
        managers.hud:UpdateAssaultPanelPosition(true)
        --[[if BAI.settings.show_assault_states then
            if managers.hud:IsClient() then
                if managers.hud:GetCompatibleHost() then
                    if managers.hud:IsNormalPoliceAssault() then
                        LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendAS)
                    else -- No active police assault. Is Wave Survived banner enabled and showed ?
                        if managers.hud:IsWaveSurvivedShowed() then
                            managers.hud:UpdateAssaultColor("survived_box", "wave_survived")
                        end
                    end
                    return
                else
                    self:UpdateAssaultColor()
                end
            else
                if managers.hud:IsNormalPoliceAssault() then
                    managers.hud:UpdateAssaultStateColor(managers.hud:GetAssaultState(), true)
                else -- No active police assault. Is Wave Survived banner enabled and showed ?
                    if managers.hud:IsWaveSurvivedShowed() then
                        managers.hud:UpdateAssaultColor("survived_box", "wave_survived")
                    end
                end
            end
        else
            self:UpdateAssaultColor()
        end]]  
    end
end)

function MenuCallbackHandler:UpdateAssaultColor()
    local mutation = ""
    if managers.mutators and managers.mutators:are_mutators_active() then
        mutation = "_mutated"
    end
    if managers.hud:GetAssaultMode() == "phalanx" then -- Captain is on the scene
        managers.hud:UpdateAssaultColor("captain_box" .. mutation, "captain")
    else
        if managers.hud:IsPoliceAssault() then
            if managers.hud:IsEndlessPoliceAssault() then 
                managers.hud:UpdateAssaultColor("endless_box" .. mutation, "endless_assault")
            else
                managers.hud:UpdateAssaultColor(managers.hud:IsSkirmish() and "holdout_box" or ("assault_box" .. mutation), "assault")
            end
        else -- No active police assault. Is Wave Survived banner enabled and showed ?
            if managers.hud:IsWaveSurvivedShowed() then
                managers.hud:UpdateAssaultColor("survived_box", "wave_survived")
            end
        end
    end
end