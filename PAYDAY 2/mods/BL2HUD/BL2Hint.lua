--TODO also a currently just a temp way of moving it bit out of the face ...
CloneClass(HUDHint)
function HUDHint:init(...)
	self.orig.init(self, ...)
	self._hint_panel:set_y(75)
end