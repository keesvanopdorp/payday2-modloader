--TODO, This is just temp so the panel doesn't get offscreen

CloneClass(HUDWaitingLegend)

function HUDWaitingLegend:show_on(teammate_hud, peer)
	if self._box then
		self._box:stop()
	end
	local scale = BL2Options._data.team_scale
	local panel = teammate_hud._panel
	self._panel:set_world_leftbottom(panel:world_left(), panel:world_top()+75*scale)
	self._current_peer = peer or managers.network:session():local_peer()
	self:update_buttons()
	self._block_input_until = Application:time() + 0.5
end

