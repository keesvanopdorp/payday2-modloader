BL2Carry = BL2Carry or class()
function BL2Carry:init(hud)
	self._hud_panel = hud.panel
	if self._hud_panel:child("carry_panel") then
		self._hud_panel:remove(self._hud_panel:child("carry_panel"))
	end
	local scale = BL2Options._data.player_scale
	self._carry_panel = self._hud_panel:panel({
		name = "carry_panel",
		w = 200*scale,
		h = 50*scale,
		x = hud.panel:right() - 200*scale,
		y = hud.panel:bottom() - 122*scale,
		visible = false,
	})
	local bag = self._carry_panel:bitmap({
		name = "bag",
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect =  {32,33,32,31},
		layer = 1,
		w = 22*scale,
		h = 22*scale,
		x = 173*scale,
		color = Color(255,200, 216, 235)/ 255,
		rotation = 15,
		--y = 5*scale,
	})
	local bag_bg = self._carry_panel:bitmap({
		name = "bag_bg",
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = {32,33,32,31},
		layer = 0,
		w = 24*scale,
		h = 24*scale,
		color = Color(255,22, 89, 133) / 255,
		rotation = 15,
		--y = 5*scale,
	})
	bag_bg:set_center(bag:center())
	
	self._carry_panel:text({
		name = "carry_item",
		font = "fonts/font_medium_noshadow",
		font_size = 20*scale,
		layer = 2,
		align = "right",
		x = -35*scale,
		y = 2*scale
	})
	
	--[[self._carry_panel:text({  --TODO for future
		name = "carry_value",
		font = "fonts/font_medium_noshadow",
		font_size = 16*scale,
		layer = 2,
		y = 20*scale,
		x = -35*scale,
		align = "right",
	})]]
	
end


function BL2Carry:show_carry_bag(id,value)
	self._carry_panel:set_visible(true)
	local panel = self._carry_panel
	local carry = panel:child("carry_item")
	local data = tweak_data.carry[id]
	
	carry:set_text(data.name_id and managers.localization:text(data.name_id) or "Invalid NameID")
	
end

function BL2Carry:hide_carry_bag()
	self._carry_panel:set_visible(false)
end

function BL2Carry:set_stamina_value(value)

end

function BL2Carry:set_max_stamina(value)

end