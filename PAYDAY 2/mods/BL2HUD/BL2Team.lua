
function BL2Box(panel, params)  --Used as bars at start now just to debug and see the panels when i need too
	local box_panel = panel:panel(params)
	local color = Color(1,0,0,0)
	local color_bg = Color(255,114, 114, 114) / 255
	box_panel:rect({
		name = "bg",
		halign = "grow",
		valign = "grow",
		blend_mode = "normal",
		color = color_bg,
		alpha = 0.45,
		layer = 0
	})
	local left = box_panel:bitmap({
		name = "left",
		halign = "left",
		color = color,
		visible = true,
		layer = 10,
		w = 2,
		h = box_panel:h()
	})
	local right = box_panel:bitmap({
		name = "right",
		halign = "right",
		color = color,
		visible = true,
		layer = 10,
		w = 2,
		h = box_panel:h()
	})
	local bottom = box_panel:bitmap({
		name = "bottom",
		valign = "bottom",
		color = color,
		visible = true,
		layer = 10,
		w = box_panel:w(),
		h = 2
	})
	local top = box_panel:bitmap({
		name = "top",
		valign = "top",
		color = color,
		visible = true,
		layer = 10,
		w = box_panel:w(),
		h = 2
		})
	right:set_right(box_panel:w())
	bottom:set_bottom(box_panel:h())
		
	return box_panel
end
function BL2Cat(type,i,is_main)
	local ES = ""
	
	if is_main and i == 1 then
		ES = managers.blackmarket:equipped_secondary().weapon_id
	elseif is_main and i == 2 then
		ES = managers.blackmarket:equipped_primary().weapon_id
	elseif not is_main and i then
		ES = i
	end
	
	local CS = tweak_data.weapon[ES].categories
	
	if CS[1] == "akimbo" then
		return CS[2] == string.lower(type)
	else
		return CS[1] == string.lower(type)
	end
end

	BL2Team = BL2Team or class()
	
	function BL2Team:init(id,panel,is_player,hw)
		self._id = id
		local main_player = id == HUDManager.PLAYER_PANEL
		local player = is_player
		local bar_atlas = "guis/textures/BL2HUD/bar_atlas"
		local icon_atlas = "guis/textures/BL2HUD/icon_atlas"
		local extra_atlas = "guis/textures/BL2HUD/extra_atlas"
		local tazed_atlas = "guis/textures/BL2HUD/light_atlas"
		local tabs_texture = "guis/textures/pd2/hud_tabs"
		self._BLSet = BL2Options._data
		self._main_player = main_player
		
		local scale = main_player and self._BLSet.player_scale or self._BLSet.team_scale or 1
		local hide = not main_player and self._BLSet.hide_team
		
		local teammate_panel = panel:panel({
			name = "" .. id,
			visible = false,
		})
		
		if main_player then
			teammate_panel:set_h(200*scale)
			teammate_panel:set_w(hw)
		end
		
		--No touchy ... its my Special Loha Super Secret method of testing some things rooKb
		--[[
			self._test_tx = teammate_panel:text({ 
				name = "test",
				font = "fonts/font_large_mf",
				font_size = 16,
				text = "Prop3R is a Pleb",
				layer = 8,
			})
			self._test_tx2 = teammate_panel:text({ 
				name = "test2",
				font = "fonts/font_large_mf",
				font_size = 16,
				text = "Killer29 *Hey mom, im on TV",
				layer = 8,
				y = 15,
			})
		]]
		
		self._player_panel = teammate_panel:panel({name = "player"})
		local name = teammate_panel:text({
			name = "name",
			text = "",
			layer = 5,
			color = Color.white,
			font_size = 22*scale,
			font = "fonts/font_medium_noshadow",
			visible = not main_player,
			y = 2*scale,
		})
		teammate_panel:panel({name = "name_bg", visible = false})
		teammate_panel:text({
			name = "b_status",
			text = "",
			layer = 5,
			font_size = 22*scale,
			font = "fonts/font_medium_noshadow",
			visible = false,
			y = 2*scale,
		})

		local cable_ties_panel = self._player_panel:panel({
			name = "cable_ties_panel",
			h = main_player and 30*scale or 20*scale,
			w = main_player and 30*scale or 25*scale,
			x = main_player and teammate_panel:right()-55*scale or 0,
			y = main_player and teammate_panel:h()-35*scale or 5*scale,
			alpha = hide and 0 or 1,
		})
		
		local radial_health_panel = self._player_panel:panel({
			name = "radial_health_panel",
			h = (main_player and 30*scale or 15*scale),
			w = (main_player and 300*scale or 125*scale),
			y = (main_player and self._player_panel:bottom()-60*scale or 30*scale),
			x = (main_player and 0 or hide and 40*scale or 95*scale),
		})
		self._player_panel:panel({
			name = "poc",
			h = 0,
			w = 0,
			x = main_player and teammate_panel:right() or radial_health_panel:right()+25*scale,
			visible = false,
		})
		local shield_panel = self._player_panel:panel({
			name = "shield_panel",
			h = (main_player and 35*scale or 10*scale),
			w = (main_player and 250*scale or 100*scale),
			y = (main_player and radial_health_panel:top()-40*scale or radial_health_panel:top()-10*scale),
			x = radial_health_panel:x(),
		})
		local tazed_panel = self._player_panel:panel({ --I've come to a sad realization that the electrified condition doesnt trigger by default on main_player
			name = "tazed_panel",						--also thats why for everyones safety for now ive moved the tazed animation to trigger when not main player and i am aware of that that this doesnt get triggered at all in that case.
			h = main_player and 35*scale or 15*scale,
			w = main_player and 250*scale or 110*scale,
			y = main_player and shield_panel:y()+7*scale or shield_panel:y()-2*scale,
			x = main_player and shield_panel:x()+22*scale or shield_panel:x()-2*scale,
			layer = 4,
			visible = false,
		})
		local bolt = tazed_panel:bitmap({
			name = "tazed4",
			texture = tazed_atlas,
			texture_rect = {1,2,158,32},
			w =	main_player and 162*scale or 108*scale,
			h = main_player and 31*scale or 16*scale,
		})
		tazed_panel:bitmap({
			name = "tazed1",
			texture = tazed_atlas,
			texture_rect = {0,33,158,32},
			w =	bolt:w(),
			h = bolt:h(),
		})
		tazed_panel:bitmap({
			name = "tazed3",
			texture = tazed_atlas,
			texture_rect = {0,64,158,32},
			w =	bolt:w(),
			h = bolt:h(),
		})
		tazed_panel:bitmap({
			name = "tazed2",
			texture = tazed_atlas,
			texture_rect = {2,99,158,32},
			w =	bolt:w(),
			h = bolt:h(),
		})
		
		local grenades_panel = self._player_panel:panel({
			name = "grenades_panel",
			h = main_player and 40*scale or 30*scale,
			w = main_player and 250*scale or 30*scale,
			y = main_player and shield_panel:y() or 23*scale,
			x = main_player and teammate_panel:right()-250*scale or 0,
			alpha = hide and 0 or 1,
		})
		local deployable_equipment_panel = self._player_panel:panel({
			name = "deployable_equipment_panel",
			h = 60*scale,
			w = 40*scale,
			y = (main_player and shield_panel:top()-55*scale or -15*scale),
			x = (main_player and 23*scale or shield_panel:left()-40*scale),
		})
		
		local weapons_panel = self._player_panel:panel({
			name = "weapons_panel",
			h = (main_player and 60*scale or 50*scale),
			w = (main_player and 300*scale or 50*scale),
			y = (main_player and radial_health_panel:y()-8*scale or cable_ties_panel:top()),
			x = (main_player and teammate_panel:right()-300*scale or cable_ties_panel:right()),
			alpha = hide and 0 or 1,
		})
		local carry_panel = self._player_panel:panel({
			name = "carry_panel",
			visible = false,
			layer = 1,
			w = 20*scale,
			h = 20*scale,
			x = 0,
			y = 43*scale,
			alpha = hide and 0 or 1,
		})
		local carry_bag = carry_panel:bitmap({
			name = "carry_bag",
			texture = tabs_texture,
			texture_rect =  {32,33,32,31},
			w = 16*scale,
			h = 16*scale,
			color = Color(255,200, 216, 235)/ 255,
			x = 1.5*scale,
			y = 1.5*scale,
		})
		carry_panel:bitmap({
			name = "carry_bag_bg",
			texture = tabs_texture,
			texture_rect =  {32,33,32,31},
			w = 19*scale,
			h = 19*scale,
			layer = carry_bag:layer()-1,
			color = Color(255,22, 89, 133) / 255,
		})
		
		local active_weapons = weapons_panel:panel({name = "active_weapons"})
		local inactive_weapons = weapons_panel:panel({name = "inactive_weapons"})
		
		local grenade_icon = grenades_panel:bitmap({
			name = "grenade_icon",
			h = main_player and 25*scale or 17*scale,
			w = main_player and 25*scale or 17*scale,
			x = (main_player and 220*scale or 0),
			y = (main_player and 8*scale or 3*scale),
			color = Color(255,200, 216, 235)/ 255,
			layer = 6,
		})
		local grenade_icon_bg = grenades_panel:bitmap({
			name = "grenade_icon_bg",
			h = main_player and 31*scale or 23*scale,
			w = main_player and 31*scale or 23*scale,
			color = Color(255,22, 89, 133) / 255,
			layer = 5,
		})
		grenades_panel:text({
			name = "grenade_tx",
			layer = 8,
			color = Color.white,
			text = "000",
			font = "fonts/font_medium_noshadow",
			font_size = main_player and 24*scale or 17*scale,
			align = main_player and "right" or "left",
			y = main_player and 5*scale or 5*scale,
			x = main_player and -grenade_icon:w()-18*scale or 8*scale,
		})
		local grenade_act = grenades_panel:bitmap({
			name = "grenade_act",
			layer = 4,
			texture = extra_atlas,
			texture_rect = {425,112,64,64},
			h = main_player and 41*scale or 31*scale,
			w = main_player and 41*scale or 31*scale,
			visible = false,
		})
		grenade_icon_bg:set_center(grenade_icon:center())
		grenade_act:set_center(grenade_icon:center())
		
		local ties_icon = cable_ties_panel:bitmap({
			name = "ties_icon",
			layer = 2,
			h = main_player and 20*scale or 17*scale,
			w = main_player and 20*scale or 17*scale,
			color = Color(255,200, 216, 235)/ 255,
		})
		local ties_icon_bg = cable_ties_panel:bitmap({
			name = "ties_icon_bg",
			layer = 1,
			color = Color(255,22, 89, 133) / 255,
			h = main_player and 26*scale or 22*scale,
			w = main_player and 26*scale or 22*scale,
		})
		ties_icon_bg:set_center(ties_icon:center())
		
		cable_ties_panel:text({
			name = "ties_text",
			layer = 4,
			align = "left",
			font = "fonts/font_medium_noshadow",
			font_size = main_player and 20*scale or 17*scale,
			text = "",
			x = 8*scale,
			y = 5*scale,
		})
		local ammo_icon_a = active_weapons:bitmap({
			name = "ammo_icon",
			texture = icon_atlas,
			texture_rect = {43*3,43*0,42,42},
			layer = 1,
			h = main_player and 35*scale or 24*scale,
			w = main_player and 35*scale or 24*scale,
			x = main_player and weapons_panel:w()-35*scale or 0,
			y = main_player and 0 or -1*scale,
		})
		local ammo_icon_i = inactive_weapons:bitmap({
			name = "ammo_icon",
			texture = icon_atlas,
			texture_rect = {43*3,43*1,42,42},
			layer = 1,
			h = main_player and 28*scale or 24*scale,
			w = main_player and 28*scale or 24*scale,
			x = main_player and ammo_icon_a:left()-218*scale or 0,
			y = main_player and 30*scale or 18*scale,
		})
		
		if main_player then
			local exp_panel = teammate_panel:panel({
				name = "exp_panel",
				h = 50*scale,
				w = 400*scale,
				x = teammate_panel:w()/2 - 200*scale,
				y = radial_health_panel:y()+15*scale,
				layer = 0,
			})
			local exp_ot = exp_panel:bitmap({
				name = "exp_ot",
				texture = extra_atlas,
				texture_rect = {0,256,400,28},
				h = 30*scale,
				w = 400*scale,
				layer = 3,
				color = Color.black,
			})
			exp_panel:bitmap({
				name = "exp_f",
				texture = extra_atlas,
				texture_rect = {0,232,400,28},
				h = exp_ot:h(),
				w = 0,
				layer = 2,
			})
			exp_panel:bitmap({
				name = "exp_bg",
				texture = extra_atlas,
				texture_rect = {0,204,400,28},
				h = exp_ot:h(),
				w = exp_ot:w(),
				color = Color(255,74, 74, 74) / 255,
				layer = 1,
			})
			self._player_panel:text({
				name = "exp_tx",
				text = "",
				font = "fonts/font_large_mf",
				font_size = 21*scale,
				align = "left",
				layer = 5,
				visible = false,
			})
			self._gained_exp = 0
			self:set_exp(exp_panel)
			
			local ammo_bar_ot_a = active_weapons:bitmap({
				name = "ammo_bar_ot",
				texture = bar_atlas,
				texture_rect = {383,71,-198,20},
				layer = 3,
				h = 20*scale,
				w = 190*scale,
				y = 8*scale,
				x = ammo_icon_a:left()-190*scale, 
			})
			active_weapons:bitmap({
				name = "ammo_bar_f",
				texture = bar_atlas,
				texture_rect = {182,132,198,20},
				layer = 2,
				h = ammo_bar_ot_a:h(),
				w = ammo_bar_ot_a:w(),
				x = ammo_bar_ot_a:x(),
				y = ammo_bar_ot_a:y(),
			})
			active_weapons:bitmap({
				name = "ammo_bar_bg",
				texture = bar_atlas,
				texture_rect = {382,36,-198,20},
				layer = 1,
				h = ammo_bar_ot_a:h(),
				w = ammo_bar_ot_a:w(),
				x = ammo_bar_ot_a:x(),
				y = ammo_bar_ot_a:y(),
			})
			active_weapons:text({
				name = "ammo_amount",
				text = "1996",
				font = "fonts/font_medium_noshadow",
				font_size = 25*scale,
				layer = 5,
				align = "right",
				x = -ammo_icon_a:w()-7*scale,
				y = 10*scale,
			})
			
			local ammo_bar_ot_i = inactive_weapons:bitmap({
				name = "ammo_bar_ot",
				texture = bar_atlas,
				texture_rect = {185,91,198,-20},
				layer = 3,
				h = 15*scale,
				w = 160*scale,
				y = ammo_icon_i:y()+6*scale,
				x = ammo_icon_i:right(),
			})
			inactive_weapons:bitmap({
				name = "ammo_bar_f",
				texture = bar_atlas,
				texture_rect = {380,152,-198,-20},
				layer = 2,
				color = Color(0.9,0.9,0.8),
				h = ammo_bar_ot_i:h(),
				w = ammo_bar_ot_i:w(),
				x = ammo_bar_ot_i:x(),
				y = ammo_bar_ot_i:y(),
			})
			inactive_weapons:bitmap({
				name = "ammo_bar_bg",
				texture = bar_atlas,
				texture_rect = {184,56,198,-20},
				layer = 1,
				h = ammo_bar_ot_i:h(),
				w = ammo_bar_ot_i:w(),
				x = ammo_bar_ot_i:x(),
				y = ammo_bar_ot_i:y(),
			})
			inactive_weapons:text({
				name = "ammo_amount",
				text = "1996",
				font = "fonts/font_medium_noshadow",
				font_size = 20*scale,
				layer = 5,
				align = "left",
				x = ammo_icon_i:right()+10*scale,
				y = ammo_icon_i:bottom()-20*scale,
			})
			
			local ammo_status_panel = panel:panel({
				name = "ammo_status_panel"..id,
				w = 150*scale,
				h = 30*scale,
				visible = false,
				x = panel:center_x()+(panel:center_x()/3),
				y = panel:center_y()+(panel:center_y()/3),
			})	
			ammo_status_panel:text({
				name = "ammo_status",
				text = "",
				layer = 5,
				align = left,
				color = Color.white,
				font_size = 20*scale,
				font = "fonts/font_large_mf",
				x = 23*scale,
				y = 5*scale,
			})
			ammo_status_panel:bitmap({
				name = "ammo_status_icon",
				texture = icon_atlas,
				texture_rect = {2,88,36,36},
				layer = 3,
				w = 25*scale,
				h = 25*scale,
				y = 2*scale,
			})
			
			local grenade_ot = grenades_panel:bitmap({
				name = "grenade_ot",
				texture = bar_atlas,
				texture_rect = {178,72,-140,15},
				layer = 3,
				h = 20*scale,
				w = 150*scale,
				x = grenades_panel:w()-185*scale,
				y = 10*scale,
				color = Color.black,
			})
			grenades_panel:bitmap({
				name = "grenade_f",
				texture = bar_atlas,
				texture_rect = {34,133,140,15},
				layer = 2,
				h = grenade_ot:h(),
				w = grenade_ot:w(),
				x = grenade_ot:x(),
				y = grenade_ot:y(),
			})
			grenades_panel:bitmap({
				name = "grenade_bg",
				texture = bar_atlas,
				texture_rect = {178,38,-140,15},
				layer = 1,
				h = grenade_ot:h(),
				w = grenade_ot:w(),
				x = grenade_ot:x(),
				y = grenade_ot:y(),
			})
			
			local swan_panel = panel:panel({
				name = "swan_panel"..id,
				w = 392*scale,
				h = 116*scale,
				x = panel:center_x()-196*scale,
				y = panel:bottom()-200*scale,
				visible = false,
			})
			swan_panel:bitmap({
				name = "swan_bg",
				texture = extra_atlas,
				texture_rect = {4,84,392,116},
				layer = 1,
				w = 392*scale,
				h = 116*scale,
				alpha = 0.75,
			})
			swan_panel:bitmap({
				name = "swan_f",
				texture = extra_atlas,
				texture_rect = {0,0,260,70},
				layer = 2,
				x = 75*scale,
				y = 36*scale,
				w = 241*scale,
				h = 67*scale,
			})
			
			local shield_icon = shield_panel:bitmap({
			name = "shield_icon",
			texture = icon_atlas,
			texture_rect = {48,133,32,32},
			w = 25*scale,
			h = 25*scale,
			y = 8*scale,
			layer = 1,
		})		
			shield_panel:text({
			name = "shield_tx",
			text = "",
			font = "fonts/font_medium_noshadow",
			font_size = 24*scale,
			layer = 6,
			align = "left",
			color = Color.white,
			x = shield_icon:w()+10*scale,
			y = 5*scale,
		})	
			shield_panel:bitmap({
				name = "shield_warn",
				texture = icon_atlas,
				texture_rect = {6,133,32,32},
				w = 20*scale,
				h = 20*scale,
				x = 175*scale,
				y = 10*scale,
				visible = false,
			})
			
			local health_icon = radial_health_panel:bitmap({
				name = "health_icon",
				texture = icon_atlas,
				texture_rect = {48,176,32,32},
				h = 25*scale,
				w = 25*scale,
				layer = 1,
				y = -2*scale,
			})
			radial_health_panel:text({
				name = "health_tx",
				text = " 0",
				font = "fonts/font_medium_noshadow",
				font_size = 26*scale,
				layer = 5,
				align = "left",
				color = Color.white,
				x = health_icon:w()+10*scale,
				y = 2*scale,
			})
			radial_health_panel:bitmap({
				name = "health_warn",
				texture = icon_atlas,
				texture_rect = {4,175,32,32},
				w = 20*scale,
				h = 20*scale,
				visible = false,
				x = 215*scale,
			})
			
			local stored_panel = self._player_panel:panel({
				name = "stored_panel",
				w = 160*scale,
				h = 30*scale,
				visible = false,
				y = self._player_panel:h()-33*scale,
				x = 85*scale,
			})
			local stored_ot = stored_panel:bitmap({
				name = "stored_ot",
				texture = bar_atlas,
				texture_rect = {178,87,-139,-15},
				w = 130*scale,
				h = 15*scale,
				layer = 3,
				y = 3*scale,
				color = Color.black,
			})
			
			stored_panel:bitmap({
				name = "stored_f",
				texture = bar_atlas,
				texture_rect = {10,8,139,15},
				layer = 2,
				w = 0,
				h = stored_ot:h(),
				y = stored_ot:y(),
			})
			
			stored_panel:bitmap({
				name = "stored_bg",
				texture = bar_atlas,
				texture_rect = {178,54,-140,-15},
				w = stored_ot:w(),
				h = stored_ot:h(),
				layer = 1,
				y = stored_ot:y(),
			})
			
			stored_panel:bitmap({
				name = "stored_icon",
				texture = icon_atlas,
				texture_rect = {6,219,32,32},
				w = 22*scale,
				h = 22*scale,
				x = stored_ot:right(),
			})
			
			stored_panel:text({
				name = "stored_tx",
				font = "fonts/font_medium_noshadow",
				font_size = 20*scale,
				align = "right",
				text = "0 ",
				layer = 5,
				x = -36*scale,
				y = 5*scale,
			})
			
			self._swan_panel = swan_panel
			self._ammo_status = ammo_status_panel
			
			local deployable_box_f = deployable_equipment_panel:bitmap({
				name = "deployable_box_f",
				texture = icon_atlas,
				texture_rect = {181,93,50,64},
				h = 53*scale,
				w = 36*scale,
				layer = 1,
				x = (deployable_equipment_panel:w()-36*scale)/2,
				y = (deployable_equipment_panel:h()-53*scale)/2,
			})			
			deployable_equipment_panel:bitmap({
				name = "deployable_box_e",
				texture = icon_atlas,
				texture_rect = {171,171,44,44},
				h = 36*scale,
				w = 36*scale,
				layer = 0,
				alpha = 0.4,
				x = (deployable_equipment_panel:w()-36*scale)/2,
				y = deployable_box_f:y()+17*scale,
			})
			
			else
			active_weapons:text({
				name = "ammo_amount_c",
				font = "fonts/font_medium_noshadow",
				font_size = 17*scale,
				text = "",
				layer = 5,
				align = "left",
				y = 4*scale,
				x = ammo_icon_a:right()-14*scale,
			})
			inactive_weapons:text({
				name = "ammo_amount_c",
				font = "fonts/font_medium_noshadow",
				font_size = 17*scale,
				text = "",
				layer = 5,
				align = "left",
				y = 23*scale,
				x = ammo_icon_i:right()-14*scale,
			})
			local downed_panel = teammate_panel:panel({
				name = "downed_panel",
				h = 50*scale,
				w = 250*scale,
				y = 12*scale,
				visible = false,
			})
			downed_panel:bitmap({
				name = "downed_bg",
				texture = extra_atlas,
				texture_rect = {1,285,408,78},
				layer = 1,
				h = 50*scale,
				w = 250*scale,
			})
			downed_panel:bitmap({
				name = "downed_f",
				texture = extra_atlas,
				texture_rect = {75,373,435,67},
				layer = 2,
				h = 31*scale,
				w = 190*scale,
				y = 10*scale,
				x = 46*scale,
			})
			downed_panel:bitmap({
				name = "downed_icon",
				texture = extra_atlas,
				texture_rect = {6,373,66,74},
				layer = 3,
				visible = true,
			})
			downed_panel:bitmap({
				name = "downed_icon_2",
				texture = extra_atlas,
				texture_rect = {429,198,64,64},
				layer = 3,
				visible = false,
			})
			downed_panel:text({
				name = "downed_status",
				text = "",
				align = "left",
				layer = 4,
				font = "fonts/font_medium_noshadow",
				font_size = 27*scale,
				x = 55*scale,
				y = 25*scale,
			})
			downed_panel:bitmap({
				name = "swan_icon",
				texture = "guis/textures/pd2/hud_swansong_icon",
				texture_rect = {0,0,64,64},
				layer = 3,
				visible = false,
				rotation = -25,
			})
			teammate_panel:bitmap({
				name = "custody_icon",
				texture = "guis/textures/hud_icons",
				texture_rect = {192,464,48,48},
				w = 28*scale,
				h = 28*scale,
				visible = false,
				x = radial_health_panel:center_x(),
				y = radial_health_panel:top(),
			})
			teammate_panel:bitmap({
				name = "tazed_icon",
				texture = icon_atlas,
				texture_rect = {48,217,32,32},
				w = 28*scale,
				h = 28*scale,
				visible = false,
				layer = 6,
			})
		end
		
		deployable_equipment_panel:bitmap({
			name = "deployable_icon",
			color = main_player and Color(255,150, 240, 150)/ 255 or Color(255,137, 211, 220)/ 255,
			w = main_player and 26*scale or 26*scale,
			h = main_player and 26*scale or 26*scale, 
			layer = 3,
			visible = false,
			rotation = main_player and 0 or -25,
			x = (deployable_equipment_panel:w()-25*scale)/2,
			y = ((deployable_equipment_panel:h()-53*scale)/2)+19*scale,
		})
		deployable_equipment_panel:bitmap({
			name = "deployable_icon_bg",
			color = main_player and Color(255,36, 202, 58) / 255 or Color(255,25, 101, 98) / 255,
			w = main_player and 29*scale or 29*scale,
			h = main_player and 29*scale or 29*scale,
			layer = 2,
			rotation = main_player and 0 or -25,
			x = (deployable_equipment_panel:w()-28*scale)/2,
			y = ((deployable_equipment_panel:h()-56*scale)/2)+19*scale,
			visible = false,
		})
		deployable_equipment_panel:text({
			name = "deployable_amount",
			align = main_player and "center" or "right",
			text = "000",
			font = main_player and "fonts/font_large_mf" or "fonts/font_medium_noshadow",
			font_size = main_player and 18*scale or 18*scale,
			layer = 5,
			color = Color.white,
			y = main_player and 4*scale or 37*scale,
			x = main_player and -4*scale or 0,
			visible = false,
		})
		
		local shield_ot = shield_panel:bitmap({
			name = "shield_ot",
			texture = bar_atlas,
			texture_rect = {39,72,139,15},
			layer = 3,
			h = (main_player and 20*scale or 10*scale),
			w = (main_player and 150*scale or 100*scale),
			x = (main_player and 25*scale or 0),
			y = (main_player and 10*scale or 0),
			color = Color.black,
		})
		shield_panel:bitmap({
			name = "shield_f",
			texture = bar_atlas,
			texture_rect = {33,104,140,15},
			layer = 2,
			h = shield_ot:h(),
			w = shield_ot:w(),
			x = shield_ot:x(),
			y = shield_ot:y(),
		})
		shield_panel:bitmap({
			name = "shield_bg",
			texture = bar_atlas,
			texture_rect = {38,38,140,15},
			layer = 1,
			h = shield_ot:h(),
			w = shield_ot:w(),
			x = shield_ot:x(),
			y = shield_ot:y(),
		})
		
		shield_panel:bitmap({
			name = "shield_absorb",
			texture = bar_atlas,
			texture_rect = main_player and {14,156,152,33} or {184,162,160,27},
			layer = 4,
			h = main_player and 37*scale or 11*scale,
			w = 0,
			x = main_player and 22*scale or 0,
			y = main_player and 0 or 0,
			visible = false,
		})
		
		
		local health_ot = radial_health_panel:bitmap({
			name = "health_ot",
			texture = bar_atlas,
			texture_rect = {185,71,198,20},
			layer = 3,
			h = main_player and 20 * scale or 13*scale,
			w = main_player and 190*scale or 125*scale,
			x = (main_player and 25*scale or 0*scale),
		})
		radial_health_panel:bitmap({
			name = "health_f",
			texture = bar_atlas,
			texture_rect = {184,101,198,20},
			layer = 2,
			h = health_ot:h(),
			w = health_ot:w(),
			x = health_ot:x(),
		})
		radial_health_panel:bitmap({
			name = "health_bg",
			texture = bar_atlas,
			texture_rect = {184,36,198,20},
			layer = 1,
			h = health_ot:h(),
			w = health_ot:w(),
			x = health_ot:x(),
		})
		local infamy = self._player_panel:text({
			name = "infamy",
			layer = 5,
			font = "fonts/font_medium_noshadow",
			font_size = main_player and 20*scale or 19*scale,
			text = "",
			x = main_player and teammate_panel:w()/2-175*scale or 0,
			y = main_player and radial_health_panel:y()+33*scale or radial_health_panel:y()+13*scale,
			alpha = hide and 0 or 1,
		})
		self._player_panel:text({
			name = "level",
			layer = 5,
			font = "fonts/font_medium_noshadow",
			font_size = main_player and 25*scale or 25*scale,
			text = "",
			x = main_player and 0 or deployable_equipment_panel:x()+6*scale,
			y = main_player and infamy:y()-4*scale or infamy:y()-5*scale,
		})		
		self._player_panel:text({
			name = "perk",
			layer = 5,
			font = "fonts/font_medium_noshadow",
			font_size = main_player and 20*scale or 19*scale,
			text = "",
			x = main_player and 0 or radial_health_panel:x()-3*scale,
			y = infamy:y(),
		})
		
		self._deployable_equipment_panel = deployable_equipment_panel
		self._cable_ties_panel = cable_ties_panel
		self._grenades_panel = grenades_panel
		
		if WolfHUD then
			self._wsp = main_player and "PLAYER" or "TEAMMATE"
		end
		
		if HUDManager.DOWNS_COUNTER_PLUGIN then
			if WolfHUD and WolfHUD:getSetting({"CustomHUD", self._wsp, "DOWNCOUNTER"}, true) then
				self:init_down(teammate_panel)
			elseif not WolfHUD then
				self:init_down(teammate_panel)
			end
		end
		
		if HUDManager.ACCURACY_PLUGIN and main_player then
			if WolfHUD and WolfHUD:getSetting({"CustomHUD", "PLAYER", "SHOW_ACCURACY"}, true) then
				self:init_acc(teammate_panel)
			elseif not WolfHUD then
				self:init_acc(teammate_panel)
			end
		end		
		
		if HUDManager.KILL_COUNTER_PLUGIN then
			if WolfHUD and not WolfHUD:getSetting({"CustomHUD", self._wsp, "KILLCOUNTER", "HIDE"}, false) then
				self:init_kill(teammate_panel)
			elseif not WolfHUD then
				self:init_kill(teammate_panel)
			end
		end
			
		self._stack = false
		self._special_equipment = {}
		self._panel = teammate_panel
		self:create_waiting_panel(panel)
		self._bl2_status = ""
		self._shield = {1,true}
		self._health = {2,0,0} -- ratio , current , max
		self._maniac = 0
		self._stack_info = {0,0}
		self._weapon_selected = 1
		self._has_usable = {true , ""}
		self._ammo_status_data = {}
		self._max_absorb = tweak_data.upgrades.cocaine_stacks_dmg_absorption_value * tweak_data.upgrades.values.player.cocaine_stack_absorption_multiplier[1] * tweak_data.upgrades.max_total_cocaine_stacks  / tweak_data.upgrades.cocaine_stacks_convert_levels[2]
	end
	
	--[[function BL2Team:tazed_test()
		local tazed_panel = self._player_panel:child("tazed_panel")
		tazed_panel:stop()
		tazed_panel:animate(callback(self,self,"tazed_anim"))
	end
	
	function BL2Team:tazed_anim(panel)
		local t1 = panel:child("tazed1")
		local t2 = panel:child("tazed2")
		local t3 = panel:child("tazed3")
		local t4 = panel:child("tazed4")
		local shield_ot = self._player_panel:child("shield_panel"):child("shield_ot")
		local t = 0
		local s = 0.4
		local ds = 4/s
		
		while panel:visible() do 
			local dt = coroutine.yield()
			t = t + dt
			if t >= 1*s then
				t = 0
			end
			local c = math.abs(0.7*math.sin(360*t))
			shield_ot:set_color(Color(1,c,c,c))
			t1:set_visible(t >= 0 and t <= 1/ds)
			t2:set_visible(t >= 1/ds and t <= 2/ds)
			t3:set_visible(t >= 2/ds and t <= 3/ds)
			t4:set_visible(t >= 3/ds and t <= 4/ds)
		end
	end]]
	
	function BL2Team:create_waiting_panel(parent_panel)
		local scale = self._BLSet.team_scale
		
		local panel = parent_panel:panel({
		h = 75*scale,
		w = 250*scale,
		visible = false,
		})
		panel:set_lefttop(self._panel:lefttop())
		
		local detection = panel:panel({
			name = "detection",
			w = 32*scale,
			h = 32*scale,
		})
		local detection_ring_left_bg = detection:bitmap({
			name = "detection_left_bg",
			texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
			alpha = 0.2,
			blend_mode = "add",
			w = detection:w(),
			h = detection:h()
		})
		local detection_ring_right_bg = detection:bitmap({
			name = "detection_right_bg",
			texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
			alpha = 0.2,
			blend_mode = "add",
			w = detection:w(),
			h = detection:h()
		})
		local detection_ring_left = detection:bitmap({
			name = "detection_left",
			texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			layer = 1,
			w = detection:w(),
			h = detection:h()
		})
		local detection_ring_right = detection:bitmap({
			name = "detection_right",
			texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
			render_template = "VertexColorTexturedRadial",
			blend_mode = "add",
			layer = 1,
			w = detection:w(),
			h = detection:h()
		})
		detection_ring_right_bg:set_texture_rect(detection_ring_right_bg:texture_width(), 0, -detection_ring_right_bg:texture_width(), detection_ring_right_bg:texture_height())
		detection_ring_right:set_texture_rect(detection_ring_right:texture_width(), 0, -detection_ring_right:texture_width(), detection_ring_right:texture_height())
		local detection_value = panel:text({
			name = "detection_value",
			font_size = 20*scale,
			font = "fonts/font_large_mf",
			align = "center",
			vertical = "center"
		})
		detection_value:set_center_x(detection:left() + detection:w() / 2)
		detection_value:set_center_y(detection:top() + detection:h() / 2 + 2)
		
		local name = panel:text({
			name = "name",
			font_size = 20*scale,
			font = "fonts/font_medium_noshadow",
			align = "left",
			x = detection:w()+5,
			y = 1,
		})
		local perk = panel:text({
			name = "perk",
			font_size = 18*scale,
			font = "fonts/font_medium_noshadow",
			align = "left",
			x = detection:w()+5*scale,
			y = 18*scale,
		})
		local deploy_panel = panel:panel({
			name = "deploy_panel",
			w = 32*scale,
			h = 26*scale,
			y = 14*scale,
		})
		local deploy_icon = deploy_panel:bitmap({
			name = "deploy_icon",
			color = Color(255,137, 211, 220)/ 255,
			w = 20*scale,
			h = 20*scale,
			layer = 2,
		})
		local deploy_icon_bg = deploy_panel:bitmap({
			name = "deploy_icon_bg",
			color = Color(255,25, 101, 98) / 255,
			w = 23*scale,
			h = 23*scale,
			layer = 1,
		})
		local deploy_amount = deploy_panel:text({
			name = "deploy_amount",
			align = "right",
			font = "fonts/font_medium_noshadow",
			font_size = 16*scale,
			layer = 2,
			x = 3*scale,
			y = 5*scale,
		})
		local throw_panel = panel:panel({
			name = "throw_panel",
			h = 26*scale,
			w = 26*scale,
			y = 16*scale,
		})
		local throw_icon = throw_panel:bitmap({
			name = "throw_icon",
			color = Color(255,137, 211, 220)/ 255,
			w = 20*scale,
			h = 20*scale,
			layer = 2,
		})
		local throw_icon_bg = throw_panel:bitmap({
			name = "throw_icon_bg",
			color = Color(255,25, 101, 98) / 255,
			w = 23*scale,
			h = 23*scale,
			layer = 1,		
		})
		
		self._wait_panel = panel
	end
	
	local set_icon_data = function(image, icon, rect)
	if rect then
		image:set_image(icon, unpack(rect))
		return
	end
	local text, rect = tweak_data.hud_icons:get_icon_data(icon or "fallback")
	image:set_image(text, unpack(rect))
end
	
	function BL2Team:set_waiting(waiting, peer)
		local my_peer = managers.network:session():peer(self._peer_id)
		peer = peer or my_peer
		
		
		if self._wait_panel then
			if waiting then
				self._panel:set_visible(false)
				self._wait_panel:set_lefttop(self._panel:lefttop())
				local detection = self._wait_panel:child("detection")
				local detection_value = self._wait_panel:child("detection_value")
				local current, reached = managers.blackmarket:get_suspicion_offset_of_peer(peer, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
				detection:child("detection_left"):set_color(Color(0.5 + current * 0.5, 1, 1))
				detection:child("detection_right"):set_color(Color(0.5 + current * 0.5, 1, 1))
				detection_value:set_text(math.round(current * 100))
				if reached then
					detection_value:set_color(Color(255, 255, 42, 0) / 255)
				else
					detection_value:set_color(tweak_data.screen_colors.text)
				end
				local name = self._wait_panel:child("name")
				name:set_text(" "..(0 < peer:rank() and managers.experience:rank_string(peer:rank()) or "LV.") .." " .. (peer:level() or " ").."  " .. peer:name())
				local outfit = peer:profile().outfit
				outfit = outfit or managers.blackmarket:unpack_outfit_from_string(peer:profile().outfit_string) or {}
				local perk = self._wait_panel:child("perk")
				perk:set_text(managers.localization:text(tweak_data.skilltree.specializations[tonumber(outfit.skills.specializations[1])].name_id).." "..outfit.skills.specializations[2])
				local _,_,pw,_ = perk:text_rect()
				local deploy_panel = self._wait_panel:child("deploy_panel")
				deploy_panel:set_x(perk:x()+pw+5)
				
				local has_deployable = outfit.deployable and outfit.deployable ~= "nil"
				local deploy_image = deploy_panel:child("deploy_icon")
				local deploy_image_bg = deploy_panel:child("deploy_icon_bg")
				if has_deployable then
					set_icon_data(deploy_image, tweak_data.equipments[outfit.deployable].icon)
					set_icon_data(deploy_image_bg, tweak_data.equipments[outfit.deployable].icon)
					deploy_image:set_position(1.5, 1.5)
					deploy_image_bg:set_position(0, 0)
				else
					set_icon_data(deploy_image, "none_icon")
					set_icon_data(deploy_image_bg, "none_icon")
					deploy_image:set_world_center(self._wait_panel:child("deploy_panel"):world_center())
					deploy_image_bg:set_world_center(self._wait_panel:child("deploy_panel"):world_center())
				end
				local deploy_amount = deploy_panel:child("deploy_amount")
				deploy_amount:set_text(has_deployable and "x" .. outfit.deployable_amount .. " " or "")
				
				local throw_panel = self._wait_panel:child("throw_panel")
				
				local throw_icon = throw_panel:child("throw_icon")
				local throw_icon_bg = throw_panel:child("throw_icon_bg")
				
				set_icon_data(throw_icon, outfit.grenade and tweak_data.blackmarket.projectiles[outfit.grenade].icon)
				set_icon_data(throw_icon_bg, outfit.grenade and tweak_data.blackmarket.projectiles[outfit.grenade].icon)
				throw_icon:set_position(1.5, 1.5)
				throw_icon_bg:set_position(0, 0)
				throw_panel:set_left(deploy_panel:right())
				
			elseif self._ai or my_peer and my_peer:unit() then
				self._panel:set_visible(true)
			end
		self._wait_panel:set_visible(waiting)
		managers.hud:arrange_panels()
		end
	end
	
	function BL2Team:is_waiting()
		return self._wait_panel:visible()
	end
	
	function BL2Team:set_condition(icon_data, text) --TODO Rewrite this whole mess
		local is_player = self._peer_id and (not self._ai)
		local panel = self._player_panel
		local health = panel:child("radial_health_panel")
		local shield = panel:child("shield_panel")
		local is_custody = icon_data == "mugshot_in_custody"
		local is_electrified = icon_data == "mugshot_electrified"
		health:set_visible(not is_custody)
		shield:set_visible(health:visible())
		
			if not self._main_player then
				if is_player then
					if icon_data == "mugshot_normal" then
						self:conditions(1)
					elseif icon_data == "mugshot_downed" then
						self._bl2_status = "IS DYING!"
						self:conditions(2)
					elseif icon_data == "mugshot_cuffed" then
						self._bl2_status = "IS CUFFED!"
						self:conditions(2)
					elseif icon_data == "mugshot_swansong" then
						self:conditions(2)
					elseif icon_data == "mugshot_in_custody" then
						self:conditions(1)
					end
				end
				local custody_icon = self._panel:child("custody_icon")
				local tazed_icon = self._panel:child("tazed_icon")
				local tazed_panel = panel:child("tazed_panel")
				
				tazed_icon:stop()
				tazed_icon:set_visible(is_electrified and not panel:visible())
				tazed_panel:set_visible(is_electrified and panel:visible())
				
				custody_icon:set_visible(is_custody)
				if is_electrified then
					tazed_icon:animate(callback(self,self,"_flash"))
				end
			end
	end
	
	function BL2Team:_flash(panel)
	local t = 0
	local s = 0.4
	local ds = 4/s
	local tazed_panel = self._player_panel:child("tazed_panel")
	local t1 = tazed_panel:child("tazed1")
	local t2 = tazed_panel:child("tazed2")
	local t3 = tazed_panel:child("tazed3")
	local t4 = tazed_panel:child("tazed4")
	
		while panel:visible() do 
			dt = coroutine.yield()
			t = t + dt
			if t >= 20 then
			t = 0
			end
			local f = math.abs(math.sin(360*t))
			panel:set_alpha(f)
		end
		
		
		while tazed_panel:visible() do
			local dt = coroutine.yield()
			t = t + dt
			if t >= 1*s then
				t = 0
			end
			t1:set_visible(t >= 0 and t <= 1/ds)
			t2:set_visible(t >= 1/ds and t <= 2/ds)
			t3:set_visible(t >= 2/ds and t <= 3/ds)
			t4:set_visible(t >= 3/ds and t <= 4/ds)
		end
	end
	
	function BL2Team:conditions(c) --TODO No seriously all of this needs to be re-written
		local panel = self._player_panel
		local name = self._panel:child("name")
		local tazed_icon = self._panel:child("tazed_icon")
		local downed_panel = self._panel:child("downed_panel")
		local scale = self._BLSet.team_scale
		local hide = self._BLSet.hide_team
		
		if c == 1 then
			panel:set_visible(true)
			downed_panel:set_visible(false)
			name:set_x(hide and 37*scale or 92*scale)
		elseif c == 2 then
			panel:set_visible(false)
			downed_panel:set_visible(true)
		else
			return
		end
	end
	
	
	function BL2Team:start_timer(time)
	if not self._main_player then
		local scale = self._BLSet.team_scale
		self._timer_paused = 0
		self._timer = time
		local downed_panel = self._panel:child("downed_panel")
		local swan_icon = downed_panel:child("swan_icon")
		local downed_status = downed_panel:child("downed_status")
		local downed_icon = downed_panel:child("downed_icon")
		local downed_icon_2 = downed_panel:child("downed_icon_2")
		local is_player = self._peer_id and (not self._ai)
		local name = self._panel:child("name")
		local b_status = self._panel:child("b_status")
		downed_panel:stop()
		if is_player then
			downed_panel:set_visible(true)
			downed_status:set_text(" "..self._bl2_status)
			downed_icon:set_visible(true)
			swan_icon:set_visible(false)
			downed_icon_2:set_visible(false)
			name:set_x(50*scale)
		else 
			b_status:set_visible(true)
		end
		downed_panel:animate(callback(self, self, "_animated_downed"),is_player)
	end
	end
	
	function BL2Team:set_pause_timer(pause)
	if not self._main_player then
		if not self._timer_paused then
			return
		end
		self._timer_paused = self._timer_paused + (pause and 1 or -1)
		end
	end
	
	function BL2Team:is_timer_running()
		return self._panel:child("downed_panel"):visible()
	end
	
	function BL2Team:_animated_downed(panel,is_player)
	local scale = self._BLSet.team_scale
	local downed_panel = self._panel:child("downed_panel")
	local downed_bg = downed_panel:child("downed_bg")
	local downed_f = downed_panel:child("downed_f")
	local downed_icon = downed_panel:child("downed_icon")
	local downed_icon_2 = downed_panel:child("downed_icon_2")
	local downed_status = downed_panel:child("downed_status")
	local name = self._panel:child("name")
	local is_downed = self._bl2_status == "IS DYING!"
	local player = self._player_panel
	local x1 = downed_bg:left() + 35*scale
	local y1 = downed_bg:h()/2
	local t = 0
	local b_status = self._panel:child("b_status")
	local _,_,nw,_ = name:text_rect()
	
	if is_downed then
		status = " IS REVIVING!"
	else
		status = " IS UNCUFFING!"
	end
	
	local max_time = self._timer
	
		while self._timer >= 0 or downed_panel:visible() do
			local dt = coroutine.yield()
			if self._timer_paused == 0 then
				self._timer = self._timer - dt
					if is_player then
						player:set_visible(false)
						name:set_x(50*scale)
						local r = self._timer/max_time
						local f = 0.4 + math.abs(0.6*math.sin(360*self._timer))
						downed_f:set_w(math.clamp(190*scale*r,0,190*scale))
						downed_f:set_texture_rect(75,373,math.clamp(435*r,0,435),67)
						downed_f:set_color(Color(1,1,1,1))
						downed_icon:set_color(Color(1,f,f))
						downed_icon:set_size(math.clamp(math.abs(40*scale+5*scale*math.sin(540*self._timer))*0.89,35*scale*0.89,45*scale*0.89),math.clamp(math.abs(40*scale+5*scale*math.sin(540*self._timer)),35*scale,45*scale))
						downed_icon:set_center(x1,y1)
						downed_icon:set_visible(true)
						downed_icon_2:set_visible(false)
						downed_status:set_text(" "..self._bl2_status)
					else
						b_status:set_x(nw)
						b_status:set_text(" CUSTODY IN ".. math.round(self._timer).."!")
						b_status:set_color(Color(1,0.7,0,0))
					end
			else
				t = t - dt
				if is_player then
					player:set_visible(false)
					name:set_x(50*scale)
					local r = self._timer/max_time
					local f = 0.4 + math.abs(0.6*math.sin(360*t))
					downed_f:set_texture_rect(75,446,435*r,67)
					downed_f:set_color(Color(255,57, 186, 0)/255)
					downed_icon_2:set_color(Color(f,1,f))
					downed_icon_2:set_size(math.clamp(math.abs(40*scale+5*scale*math.sin(540*t)),35*scale,45*scale),math.clamp(math.abs(40*scale+5*scale*math.sin(540*t)),35*scale,45*scale))
					downed_icon_2:set_center(x1,y1)
					downed_icon:set_visible(false)
					downed_icon_2:set_visible(true)
					downed_status:set_text(status)
				else
					b_status:set_x(nw)
					b_status:set_text(" GETTING UP!")
					b_status:set_color(Color(1,0,0.7,0))
				end
			end
		end
	end
	
	function BL2Team:stop_timer()
		if not alive(self._panel) then
			return
		end
		if not self._main_player then
			local is_player = self._peer_id and (not self._ai)
			local downed_panel = self._panel:child("downed_panel")
			local b_status = self._panel:child("b_status")
			downed_panel:stop()
			b_status:set_visible(false)
		end
	end
	
	function BL2Team:set_carry_info(carry_id, value) --TODO
		local carry_panel = self._player_panel:child("carry_panel")
		carry_panel:set_visible(true)
	end
	
	function BL2Team:remove_carry_info()
		local carry_panel = self._player_panel:child("carry_panel")
		carry_panel:set_visible(false)
	end
	
	function BL2Team:set_health(data)
		local panel = self._panel:child("player")
		local health_panel = panel:child("radial_health_panel")
		local base = health_panel:child("health_bg")
		local bar = health_panel:child("health_f")
		local old_ratio = self._health[1]
		local old_current = self._health[2]
		local old_max = self._health[3]
		local ratio = data.current / data.total
		local tx = data.current*10
		
		if old_ratio == 2 then  --Was used as a ducktape fix first ... most likely not required anymore
			bar:set_w(math.clamp(base:w()*ratio,0,base:w()))
			bar:set_texture_rect(math.clamp(184-(198*(ratio-1)),184,382),101,math.clamp(198+(198*(ratio-1)),0,198),20)
			if self._main_player then
				local text = health_panel:child("health_tx")
				text:set_text(" "..math.round(data.current*10))
			end
		end
		
		self._health[1] = ratio
		self._health[2] = data.current
		self._health[3] = data.total 
		
		if old_ratio ~= 2 then
			if old_ratio ~= ratio or old_current ~= data.current or old_max ~= data.total then
				bar:stop()
				bar:animate(callback(self,self,"_anim_health"),ratio,old_ratio,tx)
			end
		end
		if ratio <= 0.3 and old_ratio > 0.3 then
			base:stop()
			base:animate(callback(self,self,"_health_warn"))
		elseif ratio > 0.3 then
			if self._main_player then
				health_panel:child("health_warn"):set_visible(false)
			end
			base:stop()
			base:set_color(Color(1,1,1))
		end
		
		if self._shield[2] then
			self:set_armor({current = 0, total = 1})
		end
	end
	
	function BL2Team:_health_warn(panel)
		local health_panel = self._player_panel:child("radial_health_panel")
		local t = 0
		
		while self._health[1] <= 0.3 do
			local dt = coroutine.yield()
			t = t + dt
			if t >= 20 then
				t = 0
			end
			local ratio = self._health[1]
			if self._main_player then
				local health_warn = health_panel:child("health_warn")
				local f = math.abs(math.sin((900 - 1200*ratio)*(t+dt*((ratio/0.3) - 1))))
				health_warn:set_visible(f >= 0.7)			
			end
			if ratio <= 0.25 then
				local f = 0.4 + math.abs(0.6*math.sin(360*t))
				panel:set_color(Color(1,f,f))
			else
				panel:set_color(Color(1,1,1))
			end
		end
	end
	
	function BL2Team:_anim_health(panel,new,old,ntx)
		local w = self._panel:child("player"):child("radial_health_panel"):child("health_ot"):w()
		local text,otx
		
		if self._main_player then
			text = self._panel:child("player"):child("radial_health_panel"):child("health_tx")
			otx = tonumber(text:text())
			tx = otx - ntx
		end
		
		local l = old - new
		local T = math.clamp(math.abs(l),0.3,0.7)
		local t = T
		
		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			local r = new + t/T * l
			panel:set_w(math.clamp(w*r,0,w))
			panel:set_texture_rect(math.clamp(184-(198*(r-1)),184,382),101,math.clamp(198+(198*(r-1)),0,198),20)
			if self._main_player then
				local ctx = math.clamp(ntx + t/T * tx,0,ntx)
				text:set_text(" "..math.round(ctx))
			end
		end
	end
	
	function BL2Team:stored_max()
		local amount = managers.player:body_armor_value("skill_max_health_store", nil, 1)
		local multiplier = managers.player:upgrade_value("player", "armor_max_health_store_multiplier", 1)
		local mh = managers.player:max_health()
		local max = (amount * multiplier) / mh
		return {max,mh}
	end
	
	function BL2Team:set_stored_health(data)
		if self._main_player then
			local mh = managers.player:max_health()
			local max = self:stored_max()
			local r = data / max[1]
			local old_r = self._stack_info[1]
			local player_panel = self._panel:child("player")
			local stored_panel = player_panel:child("stored_panel")
			local tx = data*max[2]*10
			self._stack_info[1] = r
			if old_r ~= r then
				stored_panel:stop()
				stored_panel:animate(callback(self,self,"_stack_panel"),old_r,r,tx)
			end
		end
	end
	
	function BL2Team:_stack_panel(panel,old,new,ntx)
		local base = panel:child("stored_ot")
		local bar = panel:child("stored_f")
		local text = panel:child("stored_tx")
		local l = old - new
		local otx = tonumber(text:text())
		local tx = otx - ntx
		local T = math.clamp(math.abs(l),0.2,0.5)
		local t = T
		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			local r = new + t/T*l
			local cs = math.clamp(ntx + t/T * tx,0,ntx)
			bar:set_w(math.clamp(base:w()*r,0,base:w()))
			bar:set_texture_rect(10,8,math.clamp(139*r,0,139),15)
			bar:set_right(base:right()-1)
			text:set_text(math.round(cs).." ")
		end
	end
	
	function BL2Team:set_stored_health_max(data) --Don't rely on this, it doesn't update on max health changes based on crew chief or converts, Atleast it didn't when i tested
		if self._main_player then				--Still reliable for testing if ex-pres is equiped LUL
			local player_panel = self._panel:child("player")
			local stored_panel = player_panel:child("stored_panel")
			if self._stack then
				return
			else
			self._stack = data > 0 
			end
			stored_panel:set_visible(self._stack)
		end
	end
	
	function BL2Team:update(t,dt)
		if self._main_player then
			local exp_set = self._BLSet.exp_panel
			if exp_set > 2 and exp_set ~= 4 then
				return
			else
				if self._gained_exp ~= managers.experience:get_xp_dissected(true, 0, true) then
					local exp_panel = self._panel:child("exp_panel")
					if exp_panel then
						local old_exp = self._gained_exp
						self._gained_exp = managers.experience:get_xp_dissected(true, 0, true)
						exp_panel:stop()
						exp_panel:animate(callback(self,self,"gain_exp"),old_exp)
					end
				end
			end
		end
	end
	
	
	function BL2Team:gain_exp(panel,old)
		local at_max_level = managers.experience:current_level() == managers.experience:level_cap()
		local next_level_data = managers.experience:next_level_data() or {}
		local player_panel = self._player_panel
		local exp_ot = panel:child("exp_ot")
		local exp_bg = panel:child("exp_bg")
		local exp_tx = player_panel:child("exp_tx")
		local exp_f = panel:child("exp_f")
		local gain = self._gained_exp - old
		local exp_r = 0
		local exp_font = 21 * self._BLSet.player_scale
		local exp_font_2 = exp_font - 4
		
		if self._BLSet.exp_panel == 2 and at_max_level then
			return
		end
		
		if at_max_level then
		exp_r = managers.custom_safehouse:coins()%1 + self._gained_exp / (next_level_data.points or 1000000)
		else
		local current = next_level_data.current_points or 0
		exp_r = (current+self._gained_exp) / (next_level_data.points or 1)
		end
		
		exp_tx:set_text(" "..gain.."xp")
		local _,_,tw,_ = exp_tx:text_rect()
		
		exp_tx:set_visible(true)
		exp_tx:set_alpha(0)
		exp_tx:set_x(panel:center_x()-tw)
		exp_tx:set_font_size(exp_font)
		exp_tx:set_y(0)
		
		local T = 0.25
		local t = T
		while t > 0 do
			dt = coroutine.yield()
			t = t - dt
			r = t/T
			exp_tx:set_color(Color(255,255, 255-49*r, 255-207*r)/255)
			exp_tx:set_alpha(1-0.45*r)
		end
		wait(1)
		local T = 0.6
		local t = T
		while t > 0 do 
			dt = coroutine.yield()
			t = t - dt
			r = t / T
			exp_tx:set_y(panel:y()-panel:y()*r)
			exp_tx:set_font_size(exp_font_2+4*r)
		end
		local T = 0.25
		local t = T
		while t > 0 do 
			dt = coroutine.yield()
			t = t - dt
			r = t/T
			exp_ot:set_color(Color(1*r,1*r,1*r))
			exp_bg:set_color(Color(255,74+181*r,74+181*r,74+181*r)/255)
			exp_tx:set_alpha(1*r)
		end
		
		exp_f:set_texture_rect(0,232,400*math.clamp(exp_r,0,1),28)
		exp_f:set_w(exp_bg:w()*math.clamp(exp_r,0,1))
		
		exp_tx:set_visible(false)
	end
	
	function BL2Team:set_exp(panel)
		local exp_f = panel:child("exp_f")
		local exp_bg = panel:child("exp_bg")
		local next_level_data = managers.experience:next_level_data() or {}
		local at_max_level = managers.experience:current_level() == managers.experience:level_cap()
		local exp_r = 0
		local exp_set = self._BLSet.exp_panel
		if (exp_set == 4 and at_max_level) or exp_set == 5 then
			panel:parent():remove(panel)
			return
		elseif(exp_set == 2 and at_max_level) or exp_set == 3 then
			return
		end
		
		if at_max_level then
		exp_r = managers.custom_safehouse:coins()%1
		--exp_f:set_color(Color(1,0.5,1))
		else
		exp_r = (next_level_data.current_points or 0) / (next_level_data.points or 1)
		exp_f:set_color(Color(1,1,1))
		end
		exp_f:set_texture_rect(0,232,400*math.clamp(exp_r,0,1),28)
		exp_f:set_w(exp_bg:w()*math.clamp(exp_r,0,1))
		
	end
	
	function BL2Team:set_ammo_amount_by_type(id, max_clip, current_clip, current_left, max)
		
		local weapons_panel = self._player_panel:child("weapons_panel")
		if weapons_panel then
			local active = id == self._weapon_selected or id == 3 and self._ammo_status_data[2][3]
			local weapon_panel = weapons_panel:child(active and "active_weapons" or "inactive_weapons")
			local icon = weapon_panel:child("ammo_icon")
			local ratio = current_clip/max_clip
			local left_reserve = current_left - current_clip
			local old_ratio = 0
			local switch = false
			local sc = current_left - current_clip
			local tratio = current_left/max
			local oid = id ~= 1 and 2 or 1
			local tx = ""

			if id < 3 and self._ammo_status_data[oid] then
				old_ratio = self._ammo_status_data[id][1]
				switch = self._ammo_status_data[id][3] == not active and self._ammo_status_data[oid][3] == not active
			end
			if id == 3 and self._ammo_status_data[id] then
				old_ratio = self._ammo_status_data[id][1]
			end

			self._ammo_status_data[id] = {ratio,left_reserve,id == 3 and self._ammo_status_data[2][3] or active}
			
			if self._main_player then
			if ratio <= 0.3 and old_ratio > 0.3 or ratio <= 0.3 and switch then
				weapon_panel:stop()
				weapon_panel:animate(callback(self,self,"_ammo_animation"),id,active)
			elseif ratio > 0.3 then
				weapon_panel:stop()
				local bg = weapon_panel:child("ammo_bar_bg")
				bg:set_color(Color(1,1,1))
				self._ammo_status:set_visible(false)
			end
					local bg = weapon_panel:child("ammo_bar_bg")
					local text = weapon_panel:child("ammo_amount")
					local line = weapon_panel:child("ammo_bar_f")
					local texture = active and {182,132,math.clamp(ratio*198,0,198),20} or {math.clamp(380+(198*(ratio-1)),132,380),152,math.clamp(-198+(-198*(ratio-1)),-198,0),-20}
					line:set_w(active and math.clamp(ratio*bg:w(),0,bg:w()) or math.clamp(ratio*bg:w(),0,bg:w()))
					line:set_texture_rect(unpack(texture))
					
					if active then
					line:set_right(bg:right())
					end
					
					if sc < 0 then
						tx = current_clip .. " / " .. current_left
					else
						tx = current_clip .. " / " .. left_reserve
					end
					
					tx = active and tx .. " " or " " .. tx 
					text:set_text(tx)
					
				elseif not self._BLSet.hide_team then
					weapon_panel = weapons_panel:child(id == 1 and "inactive_weapons" or "active_weapons")
					local text = weapon_panel:child("ammo_amount_c")
					text:set_text(" x"..current_left)
					if sc < 0 then
						text:set_color(current_left == 0 and Color(1,1,0,0) or Color(1,1,1,1))
					else
						text:set_color(tratio < 0.3 and Color(1,1,tratio/0.3,0) or Color(1,1,1,1))
					end
				end
		end
	end
	
	function BL2Team:_ammo_animation(panel,id,active)
	local t = 0
		if self._main_player then
			local ammo_status = self._ammo_status
			local text = ammo_status:child("ammo_status")
			local icon = ammo_status:child("ammo_status_icon")
			local bg = panel:child("ammo_bar_bg")
			while self._ammo_status_data[id][1] <= 0.3 do
				local ratio = self._ammo_status_data[id][1]
				local left = self._ammo_status_data[id][2]
				local dt = coroutine.yield()
				t = t + dt
				if t >= 20 then
					t = 0
				end
				local f = 0.4 + math.abs(0.6*math.sin((180*(-ratio/0.3+1)+360)*t))
				bg:set_color(Color(1,f,f))
				if active then
					if left > 0 then
						ammo_status:set_visible(true)
						text:set_text(" "..utf8.to_upper(managers.localization:btn_macro("reload")).."RELOAD")
						text:set_color(Color.white)
						icon:set_texture_rect(2,88,36,36)
						local f = math.abs(math.sin((900 - 1200*ratio)*(t+dt*((ratio/0.3) - 1))))
						icon:set_visible(f >= 0.7)
					elseif left == 0 and ratio > 0 then 
						ammo_status:set_visible(false)
					elseif ratio == 0 and left == 0 then
						ammo_status:set_visible(true)
						text:set_text(" OUT OF AMMO")
						text:set_color(Color(255,217, 51, 51)/255)
						icon:set_texture_rect(217,46,36,36)
						icon:set_visible(true)
					end
				end
			end
		end
	end
	
	function BL2Team:set_weapon_selected(id,icon)
		local selected = id == 1
		self._weapon_selected = id
		local secondary = "active_weapons"
		local primary = "inactive_weapons"
		
		if self._main_player then
			secondary = selected and "active_weapons" or "inactive_weapons"
			primary = selected and "inactive_weapons" or "active_weapons"
			self:_set_weapon_icon(secondary,1)
			self:_set_weapon_icon(primary,2)
		elseif not self._BLSet.hide_team then
			local weapons_panel = self._player_panel:child("weapons_panel")
			local weapon_panel1 = weapons_panel:child("inactive_weapons")           --Ye this part is not confusing at all x)
			local weapon_panel2 = weapons_panel:child("active_weapons")
			local text1 = weapon_panel1:child("ammo_amount_c")
			local text2 = weapon_panel2:child("ammo_amount_c")
			text1:set_alpha(selected and 1 or 0.7)
			text2:set_alpha(selected and 0.7 or 1)
		end
	end
	
	function BL2Team:_set_weapon_icon(slot,id)
		local weapons_panel = self._player_panel:child("weapons_panel")
		local weapon_panel = weapons_panel:child(slot)
		local ammo_icon = weapon_panel:child("ammo_icon")
		local main_player = self._main_player
	
		if BL2Cat("assault_rifle",id,main_player) then
			ammo_icon:set_texture_rect(43*4,43*0,42,42)	
		elseif BL2Cat("pistol",id,main_player) then
			ammo_icon:set_texture_rect(43*0,43*0,42,42)
		elseif BL2Cat("smg",id,main_player) then
			ammo_icon:set_texture_rect(43*0,43*1,42,42)			
		elseif BL2Cat("shotgun",id,main_player) then
			ammo_icon:set_texture_rect(43*1,43*0,42,42)			
		elseif BL2Cat("saw",id,main_player) then
			ammo_icon:set_texture_rect(43*3,43*0,42,42)			
		elseif BL2Cat("lmg",id,main_player) then
			ammo_icon:set_texture_rect(43*5,43*0,42,42)			
		elseif BL2Cat("snp",id,main_player) or BL2Cat("bow",id,main_player) or BL2Cat("crossbow",id,main_player) then
			ammo_icon:set_texture_rect(43*3,43*1,42,42)			
		elseif BL2Cat("grenade_launcher",id,main_player) then
			ammo_icon:set_texture_rect(43*2,43*0,42,42)			
		elseif BL2Cat("minigun",id,main_player) then
			ammo_icon:set_texture_rect(43*2,43*1,42,42)			
		elseif BL2Cat("flamethrower",id,main_player) then
			ammo_icon:set_texture_rect(43*4,43*1,42,42)
		end
	end
	
	function BL2Team:set_armor(data)
		self._shield[2] = false
		local teammate_panel = self._panel
		local shield_panel = teammate_panel:child("player"):child("shield_panel")
		local shield_bg = shield_panel:child("shield_bg")
		local ratio = data.current/data.total
		local x = 33 - (140*(ratio-1))
		local w = 140 + (140*(ratio-1))  ---Note that this is the textures width and not panels width ...
		local old_ratio = self._shield[1]
		self._shield[1] = ratio
		shield_panel:child("shield_f"):set_w(math.clamp(ratio * shield_panel:child("shield_bg"):w(),0,shield_panel:child("shield_bg"):w()))
		shield_panel:child("shield_f"):set_texture_rect(math.clamp(x,33,173),104,math.clamp(w,0,140),15)
		
		if self._main_player then
			local text = math.round(math.clamp(data.current*10,0,data.total*10))
			shield_panel:child("shield_tx"):set_text(" "..text)
		end
		
		if ratio <= 0.3 and old_ratio > 0.3 then
			shield_panel:stop()
			shield_panel:animate(callback(self,self,"_shield_warn"))
		elseif ratio > 0.3 then
				if self._main_player then
					shield_panel:child("shield_warn"):set_visible(false)
				end
			shield_panel:stop()
			shield_bg:set_color(Color(1,1,1))
		end
		
	end
	
	function BL2Team:_shield_warn()
		local shield_panel = self._player_panel:child("shield_panel")
		local shield_bg = shield_panel:child("shield_bg")
		local t = 0
		while self._shield[1] <= 0.3 do
		local ratio = self._shield[1]
		local dt = coroutine.yield()
		t = t + dt
		if t >= 20 then
			t = 0
		end
			if self._main_player then
				local shield_warn = shield_panel:child("shield_warn")
				local f = math.abs(math.sin((900 - 1200*ratio)*(t+dt*((ratio/0.3) - 1))))
				shield_warn:set_visible(f >= 0.7)
			end
			if self._shield[1] <= 0.2 then
				local f = 0.4 + math.abs(0.6*math.sin(360*t))
				shield_bg:set_color(Color(1,f,f))
			else
				shield_bg:set_color(Color(1,1,1))
			end
		end
	end
	
	function BL2Team:add_special_equipment(data)
		local teammate_panel = self._panel
		local id = data.id
		local scale = self._main_player and self._BLSet.player_scale or self._BLSet.team_scale
		if self._panel:child(id) then
			self._panel:remove(self._panel:child(id))
		end
		local equipment_panel = teammate_panel:panel({
			name = id,
			h = self._main_player and 24*scale or 19*scale,
			w = self._main_player and 24*scale or 19*scale,
		})
		
		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
		
		local icon = equipment_panel:bitmap({
			name = "icon",
			texture = texture,
			texture_rect = texture_rect,
			color = Color(255,247, 229, 45)/255,
			layer = 7,
			h = equipment_panel:h()*0.85,
			w = equipment_panel:w()*0.85,
		})
		local icon_ot = equipment_panel:bitmap({
			name = "icon_ot",
			texture = texture,
			texture_rect = texture_rect,
			color = Color(255,165, 123, 0)/255,
			layer = 6,
			h = equipment_panel:h(),
			w = equipment_panel:w(),
		})
		local icon_bg = equipment_panel:bitmap({
			name = "icon_bg",
			texture = "guis/textures/BL2HUD/icon_atlas",
			texture_rect = {83,129,84,84},
			layer = 5,
			h = equipment_panel:h(),
			w = equipment_panel:w(),
		})
		icon:set_center(icon_bg:center())
		icon_ot:set_center(icon_bg:center())
		
		if data.amount then
			local amount_text = equipment_panel:text({
				name = "amount",
				align = "right",
				layer = 9,
				font = "fonts/font_medium_noshadow",
				font_size = self._main_player and 17*scale or 15*scale,
				text = "x"..tostring(data.amount),
				color = Color.white,
				visible = 1 < data.amount,
				y = self._main_player and 10*scale or 5*scale,
			})
		end
		table.insert(self._special_equipment, equipment_panel)
		self:layout_special_equipments()
	end
	
	function BL2Team:layout_special_equipments()
		local teammate_panel = self._panel
		local special_equipment = self._special_equipment
		local scale = self._main_player and self._BLSet.player_scale or self._BLSet.team_scale
		
		for i, panel in ipairs(special_equipment) do
			if self._main_player then
				local exp_base = teammate_panel:child("exp_panel")
				local grenade_base = teammate_panel:child("player"):child("grenades_panel")
				panel:set_right((exp_base and exp_base:right() or grenade_base:right()-(panel:w()/2)) -i*panel:w())
				panel:set_top((exp_base and exp_base:y()+15*scale or grenade_base:top()-panel:h()-25*scale))
			else
				local perk = self._player_panel:child("perk")
				local _,_,pw,_ = perk:text_rect()
				panel:set_left(perk:x()+pw+3*scale+(i-1)*panel:w())
				panel:set_top(perk:top())
			end
		end
	end
	
	function BL2Team:remove_special_equipment(equipment)
		local teammate_panel = self._panel
		local special_equipment = self._special_equipment
		for i, panel in ipairs(special_equipment) do
			if panel:name() == equipment then
				local data = table.remove(special_equipment, i)
				teammate_panel:remove(panel)
				self:layout_special_equipments()
				return
			end
		end
	end
	
	function BL2Team:set_special_equipment_amount(equipment_id, amount)
		local special_equipment = self._special_equipment
		for i, panel in ipairs(special_equipment) do
			if panel:name() == equipment_id then
				panel:child("amount"):set_text("x"..tostring(amount))
				panel:child("amount"):set_visible(amount > 1)
				return
			end
		end
	end
	
	function BL2Team:clear_special_equipment()
		self:remove_panel()
		self:add_panel()
	end
	
	function BL2Team:set_state(state)
		local teammate_panel = self._panel
		local name = teammate_panel:child("name")
		local is_player = state == "player"
		local downed_panel = teammate_panel:child("downed_panel")
		local scale = self._BLSet.team_scale
		local hide = self._BLSet.hide_team
		
		teammate_panel:child("player"):set_visible(is_player)
		
		if not self._main_player then
			local custody_icon = teammate_panel:child("custody_icon")
			local tazed_icon = teammate_panel:child("tazed_icon")
		if not is_player then
			teammate_panel:set_w(200*scale)
			teammate_panel:set_h(HUDManager.KILL_COUNTER_PLUGIN and 40*scale or 25*scale)
			name:set_x(0)
			local _,_,nw,_ = name:text_rect()
			custody_icon:set_position(nw+3*scale,0)
			tazed_icon:set_position(nw+3*scale,0)
			if teammate_panel:child("killcount_panel") then
				teammate_panel:child("killcount_panel"):set_position(0,22*scale)
			end
		end
			if is_player then
			tazed_icon:set_position(downed_panel:right()-5*scale,20*scale)
			teammate_panel:set_w(400*scale)
			teammate_panel:set_h(80*scale)
			name:set_x(hide and 37*scale or 92*scale)
			custody_icon:set_position(100*scale,20*scale)
			if teammate_panel:child("killcount_panel") then
				teammate_panel:child("killcount_panel"):set_position(teammate_panel:child("downcounter_panel") and teammate_panel:child("downcounter_panel"):right() or 0 , self._player_panel:child("radial_health_panel"):bottom() + 15*scale)
			end
			end
		end

		managers.hud:arrange_panels()
	end
	
	function BL2Team:set_name(team_name)
		local panel = self._panel
		local name = panel:child("name")
		
		name:set_text(" "..team_name)
		if not self._ai then
			self:set_level_info()
		end
	end
	
	function BL2Team:set_level_info()
		local infamy = self._player_panel:child("infamy")
		local level = self._player_panel:child("level")
		local perk = self._player_panel:child("perk")
		local lvl = ""
		local inf = ""
		local prk = ""
		local prefix = ""
		local s = self._BLSet
		
		if self._main_player and self._panel:child("exp_panel") then
			local cs = managers.skilltree:get_specialization_value("current_specialization")
				if cs then
					local set = self._BLSet.player_prefix
					local ct = managers.skilltree:get_specialization_value(cs, "tiers", "current_tier")
					local cd = tweak_data.skilltree.specializations[cs]
					local ep = managers.localization:text(cd.name_id)
					lvl = managers.experience:current_level()
					
					
					if set == 1 then
						prefix = self:prefix("perk_",tonumber(ct))
					elseif set == 2 then
						prefix = self:prefix("level_",tonumber(lvl))
					else 
						prefix = self:prefix(set == 3 and "custom_one_" or set == 4 and "custom_two_",false)
					end
					
					prk = tonumber(ct) > 0 and prefix .. ep or ""
					inf = (managers.experience:current_rank() or 0) > 0 and managers.experience:rank_string(managers.experience:current_rank()) or "LV."
				end
		elseif not self._main_player then
			local outfit = managers.network:session():peer(self._peer_id):blackmarket_outfit()
			local prk_id, prk_lvl = unpack(outfit.skills.specializations)
			local data = tweak_data.skilltree.specializations[tonumber(prk_id)]
			local name_id = data and data.name_id
			if name_id then
				local set = self._BLSet.team_prefix
				local text = managers.localization:text(name_id)
				local inf_tx = managers.network:session():peer(self._peer_id):rank()
				
				lvl = managers.network:session():peer(self._peer_id):level()
					
					if set == 1 then
						prefix = self:prefix("perk_",tonumber(prk_lvl))
					elseif set == 2 then
						prefix = self:prefix("level_",tonumber(lvl))
					else 
						prefix = self:prefix(set == 3 and "custom_one_" or set == 4 and "custom_two_")
					end			
				
				prk = tonumber(prk_lvl) > 0 and prefix .. text or ""
				inf = (inf_tx or 0) > 0 and managers.experience:rank_string(inf_tx) or "LV."
				
				local primary_id = managers.weapon_factory:get_weapon_id_by_factory_id(outfit.primary.factory_id)
				local secondary_id = managers.weapon_factory:get_weapon_id_by_factory_id(outfit.secondary.factory_id)
				
				self:_set_weapon_icon("active_weapons",primary_id)
				self:_set_weapon_icon("inactive_weapons",secondary_id)
			end
		else
			return
		end
		
		level:set_text(" "..lvl)
		perk:set_text(" "..prk)
		infamy:set_text(" "..inf)
		
		local _,_,wi,_ = infamy:text_rect()
		local _,_,wl,_ = level:text_rect()
		
		if self._main_player then
			level:set_x(infamy:x()+wi+1)
			perk:set_x(level:x()+wl+5)
		else
			infamy:set_x(level:x()-wi-2)
		end
	end
	
	function BL2Team:prefix(set,value)
		local prefix = ""
		local prefix_data = BL2Options._prefix
		local sorted = {}
		local level
		
		for i in pairs(prefix_data) do
			if string.find(i,set) then
				table.insert(sorted,i)
			end
		end
		table.sort(sorted)
		
		if value then
			level = value
		else
			level = math.random(#sorted)
		end
		
		for _, k in ipairs(sorted) do 
			local perk_level = string.gsub(k,set,"")
			if tonumber(perk_level) <= level then
				prefix = prefix_data[k] .. " "
			end
		end
		
		return prefix
	end
	
	function BL2Team:set_callsign(id)
		local name = self._panel:child("name")
		if self._BLSet.name and not self._cheater then --Else it overrides the cheater red color
			name:set_color(tweak_data.chat_colors[id])
		end
	end
	
	function BL2Team:set_ai(ai)
		self._ai = ai
	end
	
	function BL2Team:peer_id()
		return self._peer_id
	end
	
	function BL2Team:set_peer_id(id)
		self._peer_id = id
	end
	
	function BL2Team:add_panel()
		local teammate_panel = self._panel
			if not self._wait_panel:visible() then
				teammate_panel:set_visible(true)
			end
		managers.hud:arrange_panels()
	end
	
	function BL2Team:remove_panel()
		local teammate_panel = self._panel
		teammate_panel:set_visible(false)
		
		local special_equipment = self._special_equipment
		while special_equipment[1] do
			teammate_panel:remove(table.remove(special_equipment))
		end
		
		local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
		deployable_equipment_panel:set_visible(false)
		
		self:set_custom_radial()
		self:remove_carry_info()
		self:set_condition("mugshot_normal")
		self:teammate_progress(false, false, false, false)
		self:set_cheater(false)
		self._bl2_status = ""
		self:set_info_meter({
			current = 0,
			total = 0,
			max = 1
		})
		self._stack = false
		self._peer_id = nil
		self._ai = nil
		self._ab_act = nil
		self:stop_timer()
		self._health = {2,0,0}
		if self._main_player then
			self._swan_panel:set_visible(false)
			self._player_panel:child("stored_panel"):set_visible(false)
			self._player_panel:child("stored_panel"):child("stored_tx"):set_text("0 ")
			self._player_panel:child("stored_panel"):child("stored_f"):set_w(0)
			if self._mg then
				self._mg = nil
			end
		end
		self._player_panel:child("shield_panel"):child("shield_absorb"):set_visible(false)
		self._shield = {1,true}
		managers.hud:arrange_panels()
	end
	
	function BL2Team:set_weapon_firemode(id, firemode)
	--TODO?
	end
	
	function BL2Team:set_deployable_equipment(data)
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
		local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
		local deployable_icon = deployable_equipment_panel:child("deployable_icon")
		local deployable_icon_bg = deployable_equipment_panel:child("deployable_icon_bg")
		
		deployable_equipment_panel:set_visible(true)
		deployable_icon:set_visible(true)
		deployable_icon:set_image(icon, unpack(texture_rect))
		deployable_icon_bg:set_image(icon, unpack(texture_rect))
		
		self:set_deployable_equipment_amount(1, data)		
	end
	
	function BL2Team:set_deployable_equipment_from_string(data)
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
		local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
		local deployable_icon = deployable_equipment_panel:child("deployable_icon")
		local deployable_icon_bg = deployable_equipment_panel:child("deployable_icon_bg")
		
		deployable_equipment_panel:set_visible(true)
		deployable_icon:set_visible(true)
		deployable_icon:set_image(icon, unpack(texture_rect))
		deployable_icon_bg:set_image(icon, unpack(texture_rect))
		
		self:set_deployable_equipment_amount_from_string(1, data)
	end
	
	function BL2Team:set_deployable_equipment_amount(index,data)
		local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
		local amount = deployable_equipment_panel:child("deployable_amount")
		local icon_bg = deployable_equipment_panel:child("deployable_icon_bg")
		local icon = deployable_equipment_panel:child("deployable_icon")
		local v = false
		
			if data.amount > 0 then
				v = true
			end
		
		if self._main_player then
			local active = deployable_equipment_panel:child("deployable_box_f")
			local inactive = deployable_equipment_panel:child("deployable_box_e")
			
			inactive:set_visible(not v)
			active:set_visible(v)
		end
		
		local text = self._main_player and data.amount or "x"..data.amount.." "
		
		amount:set_text(tostring(text))
		
		icon:set_color(v and self._main_player and Color(255,150, 240, 150)/ 255 or v and Color(255,137, 211, 220)/ 255 or Color(175,114, 114, 114) / 255)
		icon_bg:set_visible(v)
		amount:set_visible(v)
	end
	
	function BL2Team:set_deployable_equipment_amount_from_string(index, data)
		local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
		local amount = deployable_equipment_panel:child("deployable_amount")
		local icon_bg = deployable_equipment_panel:child("deployable_icon_bg")
		local icon = deployable_equipment_panel:child("deployable_icon")
		local v = false
		
		for i = 1, #data.amount do
			if data.amount[i] > 0 then
				v = true
			end
		end
		
		if self._main_player then
			local active = deployable_equipment_panel:child("deployable_box_f")
			local inactive = deployable_equipment_panel:child("deployable_box_e")
			
			inactive:set_visible(not v)
			active:set_visible(v)
		end		
		local text = self._main_player and data.amount_str or "x"..data.amount_str.." "
		
		amount:set_text(text)
		
		icon:set_color(v and self._main_player and Color(255,150, 240, 150)/ 255 or v and Color(255,137, 211, 220)/ 255 or Color(175,114, 114, 114) / 255)
		icon_bg:set_visible(v)
		amount:set_visible(v)
		
	end
	
	function BL2Team:set_cable_tie(data)
		local cable_ties_panel = self._player_panel:child("cable_ties_panel")
		local ties_icon = cable_ties_panel:child("ties_icon")
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
		local ties_icon_bg = cable_ties_panel:child("ties_icon_bg")
		
		ties_icon:set_image(icon,unpack(texture_rect))
		ties_icon_bg:set_image(icon,unpack(texture_rect))
		self:set_cable_ties_amount(data.amount)
	
	end
	
	function BL2Team:set_cable_ties_amount(amount)
		local cable_ties_panel = self._player_panel:child("cable_ties_panel")
		if cable_ties_panel then
			local ties_text = cable_ties_panel:child("ties_text")
		
			if amount > 0 then
				ties_text:set_color(Color.white)
			else
				ties_text:set_color(Color(255,217, 51, 51)/255)
			end
			
			local tx = " x"..amount
			
			ties_text:set_text(tx)
		end
	end
	
	function BL2Team:set_cheater(state)
		self._cheater = state
		self._panel:child("name"):set_color(state and tweak_data.screen_colors.pro_color or Color.white)
	end
	
	function BL2Team:set_grenades(data)
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
		local grenades_panel = self._player_panel:child("grenades_panel")
		if grenades_panel then
			local grenade_icon = grenades_panel:child("grenade_icon")
			local grenade_icon_bg = grenades_panel:child("grenade_icon_bg")
			grenades_panel:set_visible(true)
			grenade_icon:set_image(icon,unpack(texture_rect))
			grenade_icon_bg:set_image(icon,unpack(texture_rect))
			
			if self._main_player and not self._mg then
				self._mg = data.amount
			end
			
			self:set_grenades_amount(data)
		end
	end
	
	function BL2Team:set_grenades_amount(data)
	local grenades_panel = self._player_panel:child("grenades_panel")
	if grenades_panel then
		local text = grenades_panel:child("grenade_tx")
		local tx = " x"..data.amount
			if self._main_player then
				local bar = grenades_panel:child("grenade_f")
				local base = grenades_panel:child("grenade_bg")
				local ratio = data.amount / self._mg
				tx = data.amount.." / "..self._mg.." "
				
				bar:set_w(math.clamp(base:w()*ratio,0,base:w()))
				bar:set_texture_rect(34,133,math.clamp(140*ratio,0,140),15)
				bar:set_right(base:right())
			else
				if data.amount > 0 then
					text:set_color(Color.white)
				else
					text:set_color(Color(255,217, 51, 51)/255)
				end
			end 
		--[[if data.has_cooldown then
			tx = self._main_player and "Ready! " or " R"
		end]]
		self._has_usable[1] = data.amount == 0
		self._has_usable[2] = tx
		text:set_text(tx)
	end
	end
	
	function BL2Team:set_grenade_cooldown(data)
		local grenades_panel = self._player_panel:child("grenades_panel")
		local bar = grenades_panel:child("grenade_f")
		local s = self._main_player and self._BLSet.player_scale or self._BLSet.team_scale
		local gw = 150 * s
		local main = self._main_player
		
		if grenades_panel then
			local text = grenades_panel:child("grenade_tx")
			local end_time = data and data.end_time
			local duration = data and data.duration
			local base = grenades_panel:child("grenade_bg")
			
			if not end_time or not duration then
				if bar then
					bar:stop()
				end
				return
			end
			local function grenade_cooldown(panel)
				repeat
					local now = managers.game_play_central:get_heist_timer()
					local left = end_time - now
					local prog = 0 + left/duration
					
					if self._main_player then
						panel:set_w(math.clamp(gw - gw*prog,0,gw))
						panel:set_texture_rect(34,133,math.clamp(140 - 140*prog,0,140),15)
						panel:set_right(base:right())
					end
					
					if text:color() == Color.white and self._has_usable[1] then
						text:set_text(" "..string.format("%2.1f",left))
					end
					
					coroutine.yield()
				until left <= 0
			end
			
			if bar then
				bar:stop()
				bar:animate(grenade_cooldown)
			end
			
		end
		
		if self._main_player then
			managers.network:session():send_to_peers("sync_grenades_cooldown", end_time, duration)
		end
	end
	
			--[[
			if self._main_player then
				local bar = grenades_panel:child("grenade_f")
				local base = grenades_panel:child("grenade_bg")
				local o_r = 0
				tx = data.cooldown > 0 and data.cooldown.." " or "Ready! "
				if not self._cooldown_max then
					self._cooldown_max = data.cooldown 
				end
				
				local r = data.cooldown / self._cooldown_max
				if self._cooldown_previous then
					o_r = self._cooldown_previous ~= r and self._cooldown_previous or 0
					if o_r ~= 0 then
						bar:stop()
						bar:animate(callback(self,self,"_animated_cooldown"),r,o_r)
					end
				else
					bar:stop()
					bar:animate(callback(self,self,"_animated_cooldown"),r,o_r)
				end
				self._cooldown_previous = data.cooldown > 0 and r or nil
			else
				tx = data.cooldown > 0 and " "..data.cooldown or " R"
				if data.cooldown > 0 then
					text:set_color(Color(255,217, 51, 51)/255)
				else
					text:set_color(Color.white)
				end
			end
			
			if not self._ab_act then
			text:set_text(tx)	
			end
		end
	end
	
	function BL2Team:_animated_cooldown(panel,ratio,old_ratio)
	local grenades_panel = self._player_panel:child("grenades_panel")
	if grenades_panel then
		local base = grenades_panel:child("grenade_bg")
		local dif = old_ratio - ratio
		local T = 1
		local t = T
			while t > 0 do
				local dt = coroutine.yield()
				t = t - dt
				local r = ratio + t/T * dif
				panel:set_w(math.clamp(150 - 150*r,0,150))
				panel:set_texture_rect(34,133,math.clamp(140 - 140*r,0,140),15)
				panel:set_right(base:right())
			end
		end
	end
	]]
	
	function BL2Team:activate_ability_radial(time_left, time_total)
	-- TODO?
		local grenades_panel = self._player_panel:child("grenades_panel")
		local grenade_act = grenades_panel:child("grenade_act")
		local grenade_tx = grenades_panel:child("grenade_tx")
		if grenades_panel then
			time_total = time_total or time_left
			local prog = time_left / time_total
			
			
		local function anim(o)
			grenade_act:set_visible(true)
			grenade_tx:set_color(Color(255,239, 252, 0)/255)
			over(time_left, function (p)
				local progress = prog * math.lerp(1, 0, p)
				grenade_act:set_rotation(progress)    --TODO
				
				grenade_tx:set_text(" "..string.format("%2.1f",time_total*progress))
			end)
			grenade_tx:set_color(Color.white)
			grenade_tx:set_text(self._has_usable[2])
			grenade_act:set_visible(false)
		end
		
		grenade_act:stop()
		grenade_act:animate(anim)
		
		end

	
		if self._main_player then
			local current_time = managers.game_play_central:get_heist_timer()
			local end_time = current_time + time_left

			managers.network:session():send_to_peers("sync_ability_hud", end_time, time_total)
		end
	end
	
	function BL2Team:set_ability_radial(data)
		local grenades_panel = self._player_panel:child("grenades_panel")
		if grenades_panel then
			local grenade_act = grenades_panel:child("grenade_act")
			local text = grenades_panel:child("grenade_tx")
			local r = data.current/data.total
			self._ab_act = data.current > 0
			grenade_act:set_visible(data.current > 0)
			grenade_act:set_rotation(-540*data.current)

			if data.current > 0 then
				text:set_color(Color(255,239, 252, 0)/255)
				text:set_text(" "..string.format("%2.1f",data.current))
			else
				text:set_color(Color.white)
			end
		end
	end
	
	function BL2Team:panel()
		return self._panel
	end
	
	function BL2Team:set_custom_radial(data)
	local ratio = 0
	
	if data then
		ratio = data.current/data.total
	end
	
	local scale = self._main_player and self._BLSet.player_scale or self._BLSet.team_scale
	local hide = self._BLSet.hide_team
	
	local is_player = self._peer_id and (not self._ai)
	
		if self._main_player then
			local swan_panel = self._swan_panel
			local swan_f = swan_panel:child("swan_f")
			swan_f:set_w(math.clamp(241*scale*ratio,0,241*scale))
			swan_f:set_texture_rect(0,0,260*ratio,70)
			swan_panel:set_visible(ratio > 0)
		elseif is_player and not self._main_player then --TODO Redo this at some point to make it less of a mess and animate it 
			local name = self._panel:child("name")
			local downed_panel = self._panel:child("downed_panel")
			local swan_icon = downed_panel:child("swan_icon")
			local downed_f = downed_panel:child("downed_f")
			local downed_bg = downed_panel:child("downed_bg")
			local downed_icon = downed_panel:child("downed_icon")
			local downed_icon_2 = downed_panel:child("downed_icon_2")
			local downed_status = downed_panel:child("downed_status")
			self._player_panel:set_visible(ratio <= 0)
			downed_icon:set_visible(ratio <= 0)
			downed_status:set_text(" IS GOING DOWN!")
			downed_icon_2:set_visible(false)
			downed_f:set_w(math.clamp(190*scale*ratio,0,190*scale))
			downed_f:set_color(Color(255,150, 253, 255)/255)
			downed_f:set_texture_rect(75,446,math.clamp(435*ratio,0,435),67)
			name:set_x(ratio > 0 and 50*scale or hide and 37*scale or 92*scale)
			if not swan_icon:visible() then
				swan_icon:stop()
				swan_icon:set_visible(ratio > 0)
				swan_icon:animate(callback(self,self,"_swan_flash"))
			end
			swan_icon:set_visible(ratio > 0)  -- Because the above one triggers animation
		end
	end
	
	function BL2Team:_swan_flash(panel)
		local scale = self._BLSet.team_scale
		local downed_panel = self._panel:child("downed_panel")
		local downed_bg = downed_panel:child("downed_bg")
		local x1 = downed_bg:left() + 35*scale
		local y1 = downed_bg:h()/2
		local t = 0
		while panel:visible() do
			downed_panel:set_visible(true)
			local dt = coroutine.yield()
			t = t + dt
			if t >= 20 then
				t = 0
			end
			local f = math.sin(540*t)
			panel:set_color(Color(255,200+15*f,255, 255)/255)
			panel:set_size((40+5*f)*scale,(40+5*f)*scale)
			panel:set_center(x1,y1)
		end
	end
	
	function BL2Team:teammate_progress(enabled, tweak_data_id, timer, success) 
		if not self._main_player then
		local teammate_panel = self._panel
		local name = teammate_panel:child("name")
			if enabled then
			name:set_alpha(0.7)
			elseif success then
			name:set_alpha(1)
			else
			name:set_alpha(1)
			end
		end
	end
	
	function BL2Team:set_info_meter(data) --stacks
		if self._main_player then
			local player_panel = self._panel:child("player")
			local stored_panel = player_panel:child("stored_panel")
			local old_r = self._stack_info[2]
			local r = data.current/data.total
			local text = 600/data.total*data.current
			self._stack_info[2] = r
			
			if old_r ~= r then
				stored_panel:stop()
				stored_panel:animate(callback(self,self,"_stack_panel"),old_r,r,text)
			end
			if self._stack then
				return
			else
				self._stack = data.total > 0 
			end
			stored_panel:set_visible(self._stack)
		end
	end
	
	function BL2Team:set_absorb_active(absorb_amount)
		local shield_panel = self._player_panel:child("shield_panel")
		local shield_absorb = shield_panel:child("shield_absorb")
		local old_r = self._maniac
		local r = absorb_amount/self._max_absorb
		self._maniac = r 
		
		if absorb_amount > 0 then
			shield_absorb:set_visible(true)
		end
		
		if r ~= old_r then
			shield_absorb:stop()
			shield_absorb:animate(callback(self,self,"_absorb_anim"),old_r,r)
		end
		
		if self._main_player then
			managers.network:session():send_to_peers("sync_damage_absorption_hud", absorb_amount)
		end
	end
	
	function BL2Team:_absorb_anim(panel,old,new)
	local scale = self._main_player and self._BLSet.player_scale or self._BLSet.team_scale or 1
	
	local w = self._main_player and 157*scale or 106*scale
	local l = old - new 
	local T = math.clamp(math.abs(l),0.3,0.7)
	local t = T
	
	while t > 0 do 
		local dt = coroutine.yield()
		t = t - dt
		local r = new + t/T * l
		panel:set_w(w*r)
		if self._main_player then
			panel:set_texture_rect(14,156,152*r,33)
		else
			panel:set_texture_rect(184,162,160*r,27)
		end
	end
	end
	
	function BL2Team:set_absorb_personal(absorb_amount) --Unused ?
		self._absorb_personal_amount = absorb_amount
	end

	function BL2Team:set_absorb_max(absorb_amount) --Unused ?
		self._absorb_max_amount = absorb_amount
	end
	
	function BL2Team:_damage_taken()
	--TODO ?
	end
	
	function BL2Team:recreate_weapon_firemode()
	--TODO
	end
	
	--Custom Script and so on comp (mostly Seven's scripts) ... 
	--TODO
	function BL2Team:set_weapon_firemode_burst()
	end
	
	function BL2Team:increment_kill_count(is_special, headshot)
		local data = self._killcount
		self._killcount.kill = data.kill + 1
		self._killcount.special = data.special + (is_special and 1 or 0)
		self._killcount.headshot = data.headshot + (headshot and 1 or 0)
		self:update_text(self._panel)
	end
		
	function BL2Team:update_text(panel)
		local data = self._killcount
		local kill = data.kill
		local spec = data.special
		local hs = data.headshot
		local tx = panel:child("killcount_panel"):child("killcount_text")
		local text = " " .. kill
		
		if WolfHUD then
			if WolfHUD:getSetting({"CustomHUD", self._wsp, "KILLCOUNTER", "SHOW_SPECIAL_KILLS"}, true) then
				text = text .. "/".. spec 
			end
			if WolfHUD:getSetting({"CustomHUD", self._wsp, "KILLCOUNTER", "SHOW_HEADSHOT_KILLS"}, true) then
				text = text .. " (" .. hs .. ")"
			end
		else
			text = " "..kill.."/"..spec.." (" .. hs ..")"
		end
		tx:set_text(text)
	end	
	
	function BL2Team:reset_kill_count()
		self._killcount.kill = 0
		self._killcount.special = 0
		self._killcount.headshot = 0
	end
	
	function BL2Team:set_accuracy(value)
		if self._main_player then
		local text = self._panel:child("acc_panel"):child("acc_text")
		text:set_text(" "..tostring(value).."%")
		end
	end
	
	function BL2Team:set_revives(value)
		self._downs = value
		local down = self._main_player and self._max_downs - value or value
		local downcounter_panel = self._panel:child("downcounter_panel")
		local text = downcounter_panel:child("downs")
		local icon = downcounter_panel:child("icon")
		text:set_text(self._main_player and " "..tostring(down).."/"..tostring(self._max_downs) or " "..tostring(down))
		text:set_color(down == self._max_downs and Color(1,1,0,0) or Color.white)
		icon:set_color(down == self._max_downs and Color(1,1,0,0) or Color.white)
	end
	
	function BL2Team:increment_downs()
		self._downs = self._downs + 1
		local downcounter_panel = self._panel:child("downcounter_panel")
		local text = downcounter_panel:child("downs")
		local icon = downcounter_panel:child("icon")
		text:set_text(self._main_player and " "..tostring(self._downs).."/"..tostring(self._max_downs) or " "..tostring(self._downs))
		text:set_color(self._downs == self._max_downs and Color(1,1,0,0) or Color.white)
		icon:set_color(down == self._max_downs and Color(1,1,0,0) or Color.white)
	end
	
	function BL2Team:reset_downs()
		local downcounter_panel = self._panel:child("downcounter_panel")
		local text = downcounter_panel:child("downs")
		local icon = downcounter_panel:child("icon")
		self._downs = 0
		text:set_text(self._main_player and " "..tostring(self._downs).."/"..tostring(self._max_downs) or " "..tostring(self._downs))
		text:set_color(self._downs == self._max_downs and Color(1,1,0,0) or Color.white)
		icon:set_color(down == self._max_downs and Color(1,1,0,0) or Color.white)
	end		
	
	function BL2Team:init_acc(panel)
			local scale = self._main_player and self._BLSet.player_scale or self._BLSet.team_scale
			local acc_panel = panel:panel({
				name = "acc_panel",
				w = 50*scale,
				h = 20*scale,
				x = self._player_panel:child("deployable_equipment_panel"):right(),
				y = self._player_panel:child("shield_panel"):top()-15*scale,
			})
			local icon = acc_panel:bitmap({
				name = "icon",
				texture = "guis/textures/pd2/pd2_waypoints",
				texture_rect = {96,0,32,32},
				layer = 2,
				w = 16 * scale,
				h = 16 * scale,
			})
			local icon_bg = acc_panel:bitmap({
				name = "icon_bg",
				texture = "guis/textures/pd2/pd2_waypoints",
				texture_rect = {96,0,32,32},
				layer = 1,
				w = 19 * scale,
				h = 19 * scale,
				color = Color.black,
			})
			icon_bg:set_center(icon:center())
			acc_panel:text({
				name = "acc_text",
				font = "fonts/font_large_mf",
				font_size = 20*scale,
				text = " 0%",
				x = icon_bg:right()-5*scale,
			})
	end
	
	function BL2Team:init_kill(panel)
		local color = Color.white
		if WolfHUD then
			color = WolfHUD:getColorSetting({"CustomHUD", self._wsp, "KILLCOUNTER", "COLOR"}, "yellow")
		end
	
		local scale = self._main_player and self._BLSet.player_scale or self._BLSet.team_scale
		local killcount_panel = panel:panel({
			name = "killcount_panel",
			w = 150*scale,
			h = 20*scale,
			x = self._main_player and (panel:child("acc_panel") and panel:child("acc_panel"):right() or self._player_panel:child("deployable_equipment_panel"):right()) or 0,
			y = self._main_player and (panel:child("acc_panel") and panel:child("acc_panel"):y() or self._player_panel:child("shield_panel"):top()-15*scale ) or 22*scale,
		})
		local icon = killcount_panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/hud_difficultymarkers_2",
			texture_rect = {0,0,28,28},
			layer = 2,
			w = 16*scale,
			h = 16*scale,
			color = color,
		})
		local icon_bg = killcount_panel:bitmap({
			name = "icon_bg",
			texture = "guis/textures/pd2/hud_difficultymarkers_2",
			texture_rect = {0,0,28,28},
			layer = 1,
			color = Color.black,
			w = 19*scale,
			h = 19*scale,
		})
		icon_bg:set_center(icon:center())
		killcount_panel:text({
			name = "killcount_text",
			font = "fonts/font_large_mf",
			font_size = 20*scale,
			text = " 0/0 (0)",
			x = icon_bg:right()-5*scale,
			color = color,
		})
		self._killcount = {kill = 0,special = 0, headshot = 0}
		self:update_text(panel)
	end
	
	function BL2Team:init_down(panel)
		local scale = self._main_player and self._BLSet.player_scale or self._BLSet.team_scale
		self._max_downs = managers.crime_spree:modify_value("PlayerDamage:GetMaximumLives", (Global.game_settings.difficulty == "sm_wish" and 2 or tweak_data.player.damage.LIVES_INIT) + (self._main_player and managers.player:upgrade_value("player", "additional_lives", 0) or 0)) - 1
		self._downs = 0
		local downcounter_panel = panel:panel({
			name = "downcounter_panel",
			h = 20*scale,
			w = 50*scale,
			y = self._main_player and self._player_panel:child("radial_health_panel"):bottom() or self._player_panel:child("radial_health_panel"):bottom() + 16*scale,
			x = self._main_player and self._player_panel:child("radial_health_panel"):left()+6*scale or 0,
		})
		local icon = downcounter_panel:bitmap({
			name = "icon",
			texture = "guis/textures/pd2/hud_difficultymarkers_2",
			texture_rect = {3,3,24,24},
			layer = 2,
			w = 14*scale,
			h = 14*scale,
		})
		local icon_bg = downcounter_panel:bitmap({
			name = "icon_bg",
			texture = "guis/textures/pd2/hud_difficultymarkers_2",
			texture_rect = {3,3,24,24},
			layer = 1,
			color = Color.black,
			w = 16*scale,
			h = 16*scale,
		})
		icon_bg:set_center(icon:center())
		downcounter_panel:text({
			name = "downs",
			font = "fonts/font_large_mf",
			font_size = 20*scale,
			text = self._main_player and " " .. tostring(self._downs) .. "/" .. tostring(self._max_downs) or " " .. tostring(self._downs),
			layer = 1,
			y = -2*scale,
			x = icon:right()-5*scale,
		})
	end
	
	function BL2Team:set_ability_icon(icon)
	
	end
	
	function BL2Team:set_delayed_damage(damage)
		
		if self._main_player then
			managers.network:session():send_to_peers("sync_delayed_damage_hud", damage)
		end
	end
	
	function BL2Team:animate_grenade_flash()
		
	end