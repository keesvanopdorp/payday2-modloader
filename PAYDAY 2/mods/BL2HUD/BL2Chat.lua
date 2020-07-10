--TODO, This is also just a temp thing, so the chat doesnt overlap with equipment
CloneClass(HUDChat)
function HUDChat:init(...)

	local scale = BL2Options._data.player_scale
	self.orig.init(self, ...)
	self._panel:set_bottom(self._panel:parent():h() - 150*scale)
end
