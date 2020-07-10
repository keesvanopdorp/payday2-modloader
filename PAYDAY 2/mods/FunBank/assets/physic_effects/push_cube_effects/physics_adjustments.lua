Hooks:PostHook(DLCTweakData, "init", "fbs_dlc_tweakdata", function (self, tweak_data, ...)
	self.custom_heist = {
		free = true,
		content = {}
	}
end)