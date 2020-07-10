_G.BL2Options = _G.BL2Options or {}
BL2Options._path = ModPath
BL2Options._data_path = SavePath.."bl2_config.txt"
BL2Options._prefix_path = SavePath.."bl2_prefix_data.txt"
BL2Options._prefix = {}
BL2Options._data = {}


function BL2Options:Save()
	local file = io.open( self._data_path, "w+")
	if file then
		file:write(json.encode(self._data))
		file:close()
	end
end

function BL2Options:Load()
	local file = io.open(self._data_path, "r")
	if file then
		self._data = json.decode(file:read("*all"))
		file:close()
	else 
		self:Create(1)
	end
	
	local prefix_file = io.open(self._prefix_path,"r")
	if prefix_file then
		self._prefix = json.decode(prefix_file:read("*all"))
		prefix_file:close()
	else
		self:Create(2)
	end
end


function BL2Options:Create(i)
if i == 1 then
	self._data = {
		player_scale = 1,
		team_scale = 1,
		player_prefix = 1,
		team_prefix = 1,
		hide_team = false,
		exp_panel = 1,
		name = false,
		hide_presenter = false,
	}
	self:Save()
else
	self._prefix = { 
		perk_1 = "Neutral", 		--Perk level based Prefixes
		perk_3 = "Lawful",
		perk_5 = "Evil",
		perk_7 = "Chaotic",
		perk_9 = "Legendary",
		
		level_001 = "Neutral",		--Level based Prefixes
		level_010 = "Lawful",		--Doing the whole 0 even before the number only so the table.sort function sorts it correctly later down the line
		level_020 = "Graceful",
		level_030 = "Tricky",
		level_040 = "Altered",
		level_050 = "Evil",
		level_060 = "Vengeful",
		level_070 = "Driven",
		level_080 = "Savage",
		level_090 = "Grand",
		level_100 = "Legendary",
		
		custom_one_1 = "Neutral",		--Custom set 1
		custom_one_2 = "Lawful",
		custom_one_3 = "Chaotic",
		custom_one_4 = "Evil",
		custom_one_5 = "Legendary",
		
		custom_two_1 = "Graceful",		--Custom set 2
		custom_two_2 = "Tricky",
		custom_two_3 = "Altered",
		custom_two_4 = "Vengeful",
		custom_two_5 = "Savage",
	}
	local prefix_file = io.open(self._prefix_path,"w+")
	if prefix_file then
		prefix_file:write(json.encode(self._prefix))
		prefix_file:close()
	end
end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BL2Options",
	function(loc)
	loc:load_localization_file(BL2Options._path.."menu/en.txt")
end)


Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_BL2Options", function( menu_manager )
	
	MenuCallbackHandler.callback_bl_player_scale = function(self, item)
		BL2Options._data.player_scale = item:value()
		BL2Options:Save()
	end
	
	MenuCallbackHandler.callback_bl_team_scale = function(self, item)
		BL2Options._data.team_scale = item:value()
		BL2Options:Save()
	end
	
	MenuCallbackHandler.callback_bl_hide_team = function(self, item)
		BL2Options._data.hide_team = (item:value() == "on" and true or false)
		BL2Options:Save()
	end
	
	MenuCallbackHandler.callback_player_exp_panel = function(self, item)
		BL2Options._data.exp_panel = item:value()
		BL2Options:Save()
	end
	
	MenuCallbackHandler.callback_team_name_color = function(self, item)
		BL2Options._data.name = (item:value() == "on" and true or false)
		BL2Options:Save()
	end
	
	MenuCallbackHandler.callback_bl_player_prefix = function(self, item)
		BL2Options._data.player_prefix = item:value()
		BL2Options:Save()
	end
	
	MenuCallbackHandler.callback_bl_team_prefix = function(self, item)
		BL2Options._data.team_prefix = item:value()
		BL2Options:Save()
	end
	------------------------------------------
	MenuCallbackHandler.callback_bl_hide_presenter = function(self, item)
		BL2Options._data.hide_presenter = (item:value() == "on" and true or false)
		BL2Options:Save()
	end
	 -----------------------------------------
	BL2Menus = {"menu/bl2_menu.txt","menu/bl2_menu_player.txt","menu/bl2_menu_team.txt","menu/bl2_temp_menu.txt"}
	BL2Options:Load()
	for _,v in ipairs(BL2Menus) do 
		MenuHelper:LoadFromJsonFile( BL2Options._path .. v, BL2Options, BL2Options._data)
	end
	
end )