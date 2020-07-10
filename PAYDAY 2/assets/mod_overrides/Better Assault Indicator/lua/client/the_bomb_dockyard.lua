local _f_DialogManager_queue_dialog = DialogManager.queue_dialog
function DialogManager:queue_dialog(id, ...)
	if id == "Play_pln_cr2_104" then
		managers.hud:SetEndlessClient(true)
		managers.hud:SetEndlessAssaultOverrideFromStart()
	end
	return _f_DialogManager_queue_dialog(self, id, ...)
end

function HUDManager:SetEndlessAssaultOverrideFromStart()
	self._hud_assault_corner:SetEndlessAssaultOverrideFromStart()
end

function HUDAssaultCorner:SetEndlessAssaultOverrideFromStart()
	if not self._assault_endless then
		if ArmStatic and MUIStats then
			MUIStats:sync_start_assault(managers.job:current_level_wave_count())
		else
			self:_start_endless_assault(self:_get_assault_endless_strings())
		end
    end
end