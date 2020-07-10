BLChallenge = BLChallenge or class()

function BLChallenge:init(hud)
	self._hud_panel = hud.panel 
	if self._hud_panel:child("challenge_panel") then
		self._hud.panel:remove(self._hud_panel:child("challenge_panel"))
	end
	local challenge_panel = self._hud_panel:panel({
		name = "challenge_panel",
		h = 300,
		w = 400,
		y = hud.panel:h() / 2,
	})
	
	local test = "yes"
	
	self._challenge_data = {}
	
	local challenges = managers.challenge:get_all_active_challenges()
	for i, v in pairs(challenges) do
		for j, o in pairs(v.objectives) do
			self._challenge_data[i.."_"..j] = {progress = o.progress or "na",
												max_progress = o.max_progress,
												is_completed = o.completed,
												name_id = v.name_id,
												desc =  v.desc_id,
												desc_obj = v.objective_id or string.find(managers.localization:text(o.desc_id),"$progress") and v.desc_id or o.desc_id}
		end
	end
	
	--[[
	local daily = managers.custom_safehouse:get_daily_challenge()
	for i, v in pairs(daily.trophy.objectives) do
			self._challenge_data["safehouse_"..i] = {progress = v.progress or "na",max_progress = v.max_progress,is_completed = v.completed,name_id = daily.trophy.name_id,desc = daily.trophy.desc_id,desc_obj = daily.trophy.objective_id or v.desc_id}
	end
	
	local trophy = managers.custom_safehouse:trophies()
	for i, v in pairs(trophy) do
		for j, o in pairs(v.objectives) do
			self._challenge_data["trophy_"..i.."_"..j] = {progress = o.progress or "na",max_progress = o.max_progress,is_completed = o.completed,name_id = v.name_id,desc = v.desc_id,desc_obj = v.objective_id or o.desc_id}
		end
	end]]
	--[[
	local arbiter = managers.tango:challenges()
	for i, v in pairs(arbiter) do
		for j, o in pairs(v.objectives) do
			self._challenge_data["tango_"..i.."_"..j] = {progress = v.objectives[1].progress+v.objectives[2].progress+v.objectives[3].progress,
														max_progress = v.objectives[1].max_progress+v.objectives[2].max_progress+v.objectives[3].max_progress,
														is_completed = o.completed,
														name_id = v.name_id,
														desc = v.desc_id,
														desc_obj = v.objectives[1].desc_id
														}
		end
	end
	]]
	self._keys = {}
	self._n = 0
	for i,v in pairs(self._challenge_data) do
		self._n = self._n + 1
		self._keys[self._n] = i
	end
	
	self._test_tx = challenge_panel:text({ 
		name = "test",
		font = "fonts/font_large_mf",
		font_size = 18,
		text = test,
		layer = 8,
		wrap = true,
		word_wrap = true,
	})
	self._n = 1
	SaveTable(self._keys, "keys.txt")
end

function BLChallenge:update(t,dt)
	local old_data = self._challenge_data
	self._challenge_data = {}
	local challenges = managers.challenge:get_all_active_challenges()
	local daily = managers.custom_safehouse:get_daily_challenge()
	local trophy = managers.custom_safehouse:trophies()
	local arbiter = managers.tango:challenges()
	self._n = self._n + 0.005
	if self._n > #self._keys then
		self._n = 1
	end
	
	local key = self._keys[math.round(self._n)]
	if old_data[key].desc then
		self._test_tx:set_text(key.."\n NAME : "..managers.localization:text(old_data[key].name_id) .. "\n DESC: "..managers.localization:text(old_data[key].desc).."\n OBJ DESC: "..managers.localization:text(old_data[key].desc_obj).."\n PROG: "..old_data[key].progress.."/"..old_data[key].max_progress)
	end

	for i, v in pairs(challenges) do
		for j, o in pairs(v.objectives) do
			self._challenge_data[i.."_"..j] = {progress = o.progress or "na",
												max_progress = o.max_progress,
												is_completed = o.completed,
												name_id = v.name_id,
												desc =  v.desc_id,
												desc_obj = v.objective_id or string.find(managers.localization:text(o.desc_id),"$progress") and v.desc_id or o.desc_id}
		end
	end
	--[[
	for i, v in pairs(daily.trophy.objectives) do
			self._challenge_data["safehouse_"..i] = {progress = v.progress or "na",max_progress = v.max_progress,is_completed = v.completed,name_id = daily.trophy.name_id,desc = daily.trophy.desc_id,desc_obj = daily.trophy.objective_id or v.desc_id}
	end
	for i, v in pairs(trophy) do
		for j, o in pairs(v.objectives) do
			self._challenge_data["trophy_"..i.."_"..j] = {progress = o.progress or "na",max_progress = o.max_progress,is_completed = o.completed,name_id = v.name_id,desc = v.desc_id,desc_obj = v.objective_id or o.desc_id}
		end
	end]]
	--[[
	for i, v in pairs(arbiter) do
		for j, o in pairs(v.objectives) do
			self._challenge_data["tango_"..i.."_"..j] = {progress = v.objectives[1].progress+v.objectives[2].progress+v.objectives[3].progress,
														max_progress = v.objectives[1].max_progress+v.objectives[2].max_progress+v.objectives[3].max_progress,
														is_completed = o.completed,
														name_id = v.name_id,
														desc = v.desc_id,
														desc_obj = v.objectives[1].desc_id
														}
		end
	end]]
	
	--[[for i,v in pairs(old_data) do
		if v.progress ~= self._challenge_data[i].progress then
			local data = self._challenge_data[i]
			self._test_tx:set_text(data.progress)
		end
	end]]
end

