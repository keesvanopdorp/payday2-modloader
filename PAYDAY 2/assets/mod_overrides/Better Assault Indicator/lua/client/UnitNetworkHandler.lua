BAI:Hook(GroupAIStateBase, "set_whisper_mode", function(self, enabled, ...)
    if not enabled and Global.statistics_manager.playing_from_start then
        managers.hud:UpdateAssaultState("control")
    end
end)