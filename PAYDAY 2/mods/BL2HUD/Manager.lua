if RequiredScript == "lib/managers/hudmanagerpd2" then
	
	function HUDManager:_create_downed_hud(hud)
		hud = hud or managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD)
		self._hud_player_downed = BL2Downed:new(hud)
	end
	
	function HUDManager:on_arrested()
		self._hud_player_downed:on_arrested()
	end
	
	function HUDManager:_create_heist_timer(hud)
		hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		self._hud_heist_timer = BLObjectives:new(hud, tweak_data.levels[Global.game_settings.level_id].hud or {})
	end
	function HUDManager:feed_heist_time(time)
		self._hud_heist_timer:set_time(time)
	end
	
	function HUDManager:_create_objectives(hud)
	end
	
	function HUDManager:activate_objective(data)
		self._hud_heist_timer:activate_objective(data)
	end
	function HUDManager:complete_sub_objective(data)
	end
	function HUDManager:update_amount_objective(data)
		self._hud_heist_timer:update_amount_objective(data);
	end
	function HUDManager:remind_objective(id)
	end
	function HUDManager:complete_objective(data)
	end
	function HUDManager:_create_temp_hud(hud)
		hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		self._hud_temp = BL2Carry:new(hud)
	end
	function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max)
		self._teammate_panels[id]:set_ammo_amount_by_type(selection_index, max_clip, current_clip, current_left, max)
	end
	
	function HUDManager:_create_teammates_panel(hud)
	hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	
	self._hud.teammate_panels_data = self._hud.teammate_panels_data or {}
	self._teammate_panels = {}
	
	if hud.panel:child("teammates_panel") then
		hud.panel:remove(hud.panel:child("teammates_panel"))
	end
	
	local teammates_panel = hud.panel:panel({
		name = "teammates_panel",
		w = hud.panel:w(),
		h = hud.panel:h(),
	})

	for i = 1, 4 do
		local is_player = i == HUDManager.PLAYER_PANEL
		
		local teammate = BL2Team:new(i, teammates_panel, is_player, hud.panel:w())
		
		self._hud.teammate_panels_data[i] = { 
			taken = false,
			special_equipments = {},
		}
		
		table.insert(self._teammate_panels, teammate)
	end

	end
	
	local update_original = HUDManager.update
	
	function HUDManager:update(...)
		for i, panel in ipairs(self._teammate_panels) do
			panel:update(...)
		end
		
		return update_original(self, ...)
	end
	
	function HUDManager:arrange_panels()
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		local hud_panel = hud.panel
		local gap = 3
		local gap_offset = 0
		local scale = BL2Options._data.team_scale
		
		for i, teammate in ipairs(self._teammate_panels) do
			local panel = teammate:panel()
			local waiting = teammate:is_waiting()
			
			
			if panel:visible() or waiting then
				if i == HUDManager.PLAYER_PANEL then
					panel:set_bottom(hud_panel:h())
				else
					local panel_h = panel:visible() and panel:h() or 75*scale
					panel:set_top(gap_offset)
					gap_offset = gap_offset + gap + panel_h
				end
			end
		end
	end
	
	function HUDManager:present(params)
		local BLSet = BL2Options._data
		if BLSet.hide_presenter then
			return
		else
			if self._hud_presenter then
				self._hud_presenter:present(params)
			end
		end
	end
	
end