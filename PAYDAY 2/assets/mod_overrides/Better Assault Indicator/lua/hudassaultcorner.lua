local BAI = BAI
local function AddEventSilent(event, f, delay)
    BAI.Events[#BAI.Events + 1] = { event_name = event, func = f, delay = delay or 0 }
end

function HUDAssaultCorner:InitBAI()
    self.CompatibleHost = false
    self.BAIHost = false
    self.was_endless = false
    self.is_client = Network:is_client()
    self.is_host = not self.is_client
    self.assault_state = "nil"
    self.heists_with_fake_endless_assault = { "framing_frame_1", "gallery", "watchdogs_2", "bph" } -- Framing Frame Day 1, Art Gallery, Watch Dogs Day 2, Hell's Island
    self.assault_type = nil
    self.trigger_assault_start_event = true
    self.is_skirmish = managers.skirmish and managers.skirmish:is_skirmish() or false -- Because MUI is shit
    self.is_crimespree = managers.crime_spree and managers.crime_spree:is_active() or false -- Same as comment above
    self.mutators = managers.mutators and managers.mutators:are_mutators_active() or false
    if self.mutators and Global.mutators.active_on_load["MutatorAssaultExtender"] then
        self.assault_extender_modifier = true
    end
    local level_id = Global.game_settings.level_id
    if self.is_client then
        dofile(BAI.ClientPath .. "EnemyManager.lua")
        dofile(BAI.ClientPath .. "assault_time.lua")
        dofile(BAI.ClientPath .. "UnitNetworkHandler.lua")
        self.diff = self:GetCorrectDiff(level_id)
        -- Safe House Nightmare, The Biker Heist Day 2, Cursed Kill Room, Escape: Garage, Escape: Cafe, Escape: Cafe (Day)
        self.heists_with_endless_assaults = { "haunted", "chew", "hvh", "escape_garage", "escape_cafe", "escape_cafe_day" }
        -- Pentpay Bank (Loud); The Hangar (E1M1 from DOOM)
        self.custom_heists_with_endless_assault = { "q_bank_sky_loud", "hangar_matt" }
        self.endless_client = table.contains(self.heists_with_endless_assaults, level_id) or table.contains(self.custom_heists_with_endless_assault, level_id)
        if self.is_crimespree then
            self.assault_extender_modifier = managers.crime_spree:DoesServerHasAssaultExtenderModifier()
        end
        if self.mutators and Global.mutators.active_on_load["MutatorEndlessAssaults"] then
            self:SetEndlessClient(true)
        end
        self.level_id = level_id
    end
    dofile(BAI.LuaPath .. "GroupAIStateBesiege.lua")
    self.no_endless_assault_override = table.contains(self.heists_with_fake_endless_assault, level_id)
    dofile(BAI.LuaPath .. "compatibility.lua")
    --dofile(BAI.LuaPath .. "CivilianDamage.lua")
    BAI.SetVariables = function()
        managers.localization:SetVariables()
    end
    self:ApplyHUDCompatibility(BAI.settings.hud_compatibility)
    self:ApplyModCompatibility(1)
    self:ApplyHooks()
    if BAI:IsHostagePanelHidden() and not self._mui then
        self:_hide_hostages()
    end
    self:LoadCustomText()
    self:UpdateColors()
    self:InitAAIPanel()
    self:InitCaptainPanel()
    --self:InitTradeDelayPanel()
    self.assault_panel_position_disabled = true -- Remove it when the feature is working correctly
    self:UpdateAssaultPanelPosition()
    log("[BAI] Successfully initialized") --If the mod doesn't crash above, then this is the good sign that something works here
end

function HUDAssaultCorner:InitAAIPanel()
    if not self.AAIPanel then
        return
    end

    local icons = tweak_data.bai
    local panel_h = 38
    local panel_w = 145
    local icon_wh = 38
    local right
    if self:should_display_waves() then
        right = self._hud_panel:child("wave_panel"):left() - 3
    else
        right = self._hud_panel:child("hostages_panel"):left() - 3
    end

    self._time_left_panel = self._hud_panel:panel({
        name = "time_panel",
        w = panel_w,
        h = panel_h,
        alpha = 0,
        visible = true
    })
    local time_panel = self._time_left_panel

    time_panel:set_top(0)
    time_panel:set_right(right)

    if BAI:IsHostagePanelHidden() then
        time_panel:set_x(self._hud_panel:w() - time_panel:w())
    end

    local time_icon = time_panel:bitmap({
        texture = icons.time_left.texture,
        texture_rect = icons.time_left.texture_rect,
        name = "time_icon",
        layer = 1,
        y = 0,
        x = 0,
        valign = "top",
        h = icon_wh,
        w = icon_wh
    })
    self._time_bg_box = HUDBGBox_create(time_panel, {
        x = 0,
        y = 0,
        w = panel_w - panel_h,
        h = panel_h
    }, {
        blend_mode = "add"
    })

    time_icon:set_right(time_panel:w() + 5)
    time_icon:set_center_y(self._time_bg_box:h() / 2)
    self._time_bg_box:set_right(time_icon:left())

    self._time_left_text = self._time_bg_box:text({
        layer = 1,
        vertical = "center",
        name = "time_left",
        align = "center",
        text = "04:20",
        y = 0,
        x = 0,
        valign = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        color = Color.white,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })

    local spawns_w = 107.5
    self._spawns_left_panel = self._hud_panel:panel({
        name = "spawns_panel",
        w = spawns_w,
        h = panel_h,
        alpha = 0,
        visible = true
    })
    local spawns_panel = self._spawns_left_panel

    spawns_panel:set_top(0)
    spawns_panel:set_right(time_panel:left() - 3)

    local spawns_icon = spawns_panel:bitmap({
        texture = icons.spawns_left.texture,
        name = "spawns_icon",
        layer = 1,
        y = 0,
        x = 0,
        valign = "top",
        h = icon_wh,
        w = icon_wh
    })
    self._spawns_bg_box = HUDBGBox_create(spawns_panel, {
        x = 0,
        y = 0,
        w = spawns_w - panel_h,
        h = panel_h
    }, {
        blend_mode = "add"
    })

    spawns_icon:set_right(spawns_panel:w() + 7.5)
    spawns_icon:set_center_y(self._spawns_bg_box:h() / 2)
    self._spawns_bg_box:set_right(spawns_icon:left())

    self._spawns_left_text = self._spawns_bg_box:text({
        layer = 1,
        vertical = "center",
        name = "spawns_left",
        align = "center",
        text = "0420",
        y = 0,
        x = 0,
        valign = "center",
        w = self._spawns_bg_box:w(),
        h = self._spawns_bg_box:h(),
        color = Color.white,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })
    self:InitAAIPanelEvents()
    log("[BAI] AAI Panel Initialized")
end

function HUDAssaultCorner:InitAAIPanelEvents()
    AddEventSilent(BAI.EventList.AssaultStart, function()
        managers.hud._hud_assault_corner:SetHook(true, 1)
    end)
    local function End(active)
        self:SetHook(false)
    end
    AddEventSilent(BAI.EventList.AssaultEnd, End)
    AddEventSilent(BAI.EventList.AssaultEnd, End, 2) -- Bugfix
    AddEventSilent(BAI.EventList.Captain, function(active)
        managers.hud._hud_assault_corner:SetHook(not active)
    end)
    AddEventSilent(BAI.EventList.EndlessAssaultStart, End)
    AddEventSilent(BAI.EventList.NoReturn, End)
    AddEventSilent(BAI.EventList.NormalAssaultOverride, function()
        managers.hud._hud_assault_corner:SetHook(true)
    end)
end

function HUDAssaultCorner:InitCaptainPanel()
    if not self.AAIPanel then
        return
    end

    self._captain_panel = self._hud_panel:panel({
        name = "captain_panel",
        w = 70,
        h = 38,
        x = 0, -- Changed dynamically
        y = 0,
        alpha = 0,
        visible = true
    })
    local captain_panel = self._captain_panel

    local captain_icon = captain_panel:bitmap({
        texture = tweak_data.bai.captain.texture,
        name = "captain_icon",
        layer = 1,
        y = 0,
        x = 0,
        valign = "top"
    })

    if BAI:IsHostagePanelVisible("captain") then
        captain_panel:set_right(self._hud_panel:child("hostages_panel"):left() - 3)
    else
        captain_panel:set_x(self._hud_panel:w() - captain_panel:w())
    end

    self._captain_bg_box = HUDBGBox_create(captain_panel, {
        x = 0,
        y = 0,
        w = 38,
        h = 38
    }, {
        blend_mode = "add"
    })

    captain_icon:set_right(captain_panel:w() + 5)
    captain_icon:set_center_y(self._captain_bg_box:h() / 2)
    self._captain_bg_box:set_right(captain_icon:left())

    local num_reduction = self._captain_bg_box:text({
        layer = 1,
        vertical = "center",
        name = "num_reduction",
        align = "center",
        text = "0%",
        y = 0,
        x = 0,
        valign = "center",
        w = self._captain_bg_box:w(),
        h = self._captain_bg_box:h(),
        color = Color.white,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })

    self:InitCaptainPanelEvents()

    log("[BAI] AAI Captain Panel Initialized")
end

function HUDAssaultCorner:InitCaptainPanelEvents()
    AddEventSilent(BAI.EventList.Captain, function(active)
        managers.hud._hud_assault_corner:SetCaptainHook(active)
    end)
end

function HUDAssaultCorner:InitTradeDelayPanel()
    if not (self.AAIPanel and self.Vanilla) then
        return
    end

    local trade_delay_panel = self._hud_panel:panel({
        name = "trade_delay_panel",
        w = 145,
        h = 38,
        x = 0, -- Changed dynamically
        y = self._bg_box:h() + 8,
        alpha = 0,
        visible = true
    })
    local trade_delay_icon = trade_delay_panel:bitmap({
        texture = "guis/textures/pd2/hud_buff_shield",
        name = "trade_delay_icon",
        layer = 1,
        y = 0,
        x = 0,
        valign = "top",
        h = 38,
        w = 38
    })

    if BAI:IsHostagePanelVisible("captain") then
        trade_delay_panel:set_right(self._hud_panel:child("hostages_panel"):left() - 3)
    else
        trade_delay_panel:set_x(self._hud_panel:w() - 70)
    end

    self._trade_delay_bg_box = HUDBGBox_create(trade_delay_panel, {
        x = 0,
        y = 0,
        w = 107,
        h = 38
    }, {
        blend_mode = "add"
    })

    trade_delay_icon:set_right(trade_delay_panel:w() + 5)
    trade_delay_icon:set_center_y(self._trade_delay_bg_box:h() / 2)
    self._trade_delay_bg_box:set_right(trade_delay_icon:left())

    local num_delay = self._trade_delay_bg_box:text({
        layer = 1,
        vertical = "center",
        name = "num_delay",
        align = "center",
        text = "00:00",
        y = 0,
        x = 0,
        valign = "center",
        w = self._trade_delay_bg_box:w(),
        h = self._trade_delay_bg_box:h(),
        color = Color.white,
        font = tweak_data.hud_corner.assault_font,
        font_size = tweak_data.hud_corner.numhostages_size
    })

    log("[BAI] Trade Delay Panel Initialized")
end

function HUDAssaultCorner:LoadCustomText(update)
    local table =
    {
        ["assault"] =
        {
            "hud_assault_assault", -- Overwrites original game string
            "hud_assault"
        },
        ["captain"] =
        {
            "hud_assault_vip", -- Overwrites original game string
            "hud_captain"
        },
        ["endless"] =
        {
            "hud_assault_endless",
            "hud_endless"
        },
        ["survived"] =
        {
            "hud_assault_survived", -- Overwrites original game string
            "hud_survived"
        },
        ["escape"] = "hud_assault_point_no_return_in", -- Overwrites original game string
        ["control"] = "hud_control",
        ["anticipation"] = "hud_anticipation",
        ["build"] = "hud_build",
        ["sustain"] = "hud_sustain",
        ["fade"] = "hud_fade"
    }
    local load_default =
    { -- BAI default strings; original default text loaded
        -- Long text
        "hud_assault_assault_gensec",
        "hud_assault_assault_zeal",
        "hud_assault_assault_fbi",
        "hud_assault_assault_murkywater",
        "hud_assault_assault_russian",
        "hud_assault_assault_federales",
        "hud_assault_endless",
        "hud_assault_endless_gensec",
        "hud_assault_endless_zeal",
        "hud_assault_endless_fbi",
        "hud_assault_endless_halloween",
        "hud_assault_endless_murkywater",
        "hud_assault_endless_russian",
        "hud_assault_endless_federales",
        -- Short text

        -- Both
        "hud_assault",
        "hud_captain",
        "hud_endless",
        "hud_survived",
        "hud_control",
        "hud_anticipation",
        "hud_build",
        "hud_sustain",
        "hud_fade"
    }
    for _, v in pairs(load_default) do
        LocalizationManager._custom_localizations[v] = managers.localization:text(v .. "_default")
    end
    local restore_default =
    { -- Game default strings; nilled when restored so original text from the game will be used instead
        "hud_assault_assault",
        "hud_assault_vip",
        "hud_assault_survived",
        "hud_assault_point_no_return_in"
    }
    for _, v in pairs(restore_default) do
        LocalizationManager._custom_localizations[v] = nil
    end
    local panel = BAI.settings.assault_panel
    local text_modifier = Global.game_settings.difficulty
    local custom_localization = LocalizationManager._custom_localizations
    local factions =
    { -- Factions in Vanilla game; custom factions are not supported!
        -- "swat" not included (Normal and Hard difficulty)
        "fbi",
        "gensec",
        "zeal",
        "russia",
        "zombie", -- Endless Assault only
        "murkywater",
        "federales"
    }
    if BAI:GetOption("faction_assault_text") then
        text_modifier = tweak_data.levels:get_ai_group_type()
        if Global.game_settings.level_id == "haunted" then
            text_modifier = "zombie"
        end
        if text_modifier == "america" then
            local diff_modifier = Global.game_settings.difficulty
            if BAI:IsOr(diff_modifier, "normal", "hard") then -- Normal, Hard
                text_modifier = "swat"
            elseif BAI:IsOr(diff_modifier, "overkill", "overkill_145") then -- Very Hard, OVERKILL
                text_modifier = "fbi"
            elseif BAI:IsOr(diff_modifier, "easy_wish", "overkill_290") then -- Mayhem, Death Wish
                text_modifier = "gensec"
            else --sm_wish; Death Sentence
                text_modifier = "zeal"
            end
        end
    end
    for k, v in pairs(panel) do
        if table[k] then
            local t = table[k]
            if type(t) == "table" then
                if type(v.custom_text) == "table" then
                    if v.custom_text[text_modifier] ~= "" then
                        custom_localization[t[1] .. (factions[text_modifier] and ("_" .. text_modifier) or "")] = v.custom_text[text_modifier]
                    end
                    if v.short_custom_text[text_modifier] ~= "" then
                        custom_localization[t[2]] = v.short_custom_text[text_modifier]
                    end
                else
                    if v.custom_text ~= "" then
                        custom_localization[t[1]] = v.custom_text
                    end
                    if v.short_custom_text ~= "" then
                        custom_localization[t[2]] = v.short_custom_text
                    end
                end
            else
                if v.custom_text ~= "" then
                    custom_localization[t] = v.custom_text
                end
            end
        end
    end
    log("[BAI] Custom assault text " .. (update and "updated" or "loaded"))
end

function HUDAssaultCorner:UpdateAssaultPanelPosition(update)
    if self.assault_panel_position_disabled then
        self.assault_panel_position = 3
        return
    end
    local bai_position = BAI:GetOption("assault_panel_position")
    if self.assault_panel_position then
        if self.assault_panel_position ~= bai_position then
            self.assault_panel_position = bai_position
            if self._opened then -- animate assault panel movement if it is opened
                return
            end
        end
    end
    self.assault_panel_position = bai_position
    if self.assault_panel_position ~= 3 then -- Not Left; default game and BAI behavior
        if self.assault_panel_position == 1 then -- Right
            self._hud_panel:child("assault_panel"):set_right(self._bg_box:w() + self._hud_panel:child("assault_panel"):child("icon_assaultbox"):w())
            self._hud_panel:child("casing_panel"):set_right(self._bg_box:w() + self._hud_panel:child("assault_panel"):child("icon_assaultbox"):w())
            self._hud_panel:child("point_of_no_return_panel"):set_right(self._bg_box:w() + self._hud_panel:child("assault_panel"):child("icon_assaultbox"):w())
            self._hud_panel:child("buffs_panel"):set_right(self._hud_panel:child("assault_panel"):right() + 83)
        else -- Centre
            self._hud_panel:child("assault_panel"):set_right(self._hud_panel:w() / 2 + 150)
            self._hud_panel:child("casing_panel"):set_right(self._hud_panel:w() / 2 + 150)
            self._hud_panel:child("point_of_no_return_panel"):set_right(self._hud_panel:w() / 2 + 150)
            self._hud_panel:child("buffs_panel"):set_x(self._hud_panel:child("assault_panel"):left() + self._bg_box:left() - 3 - self._hud_panel:child("buffs_panel"):w())
            -- Also move other things in the HUD to remove cluttering
            local self = managers.hud -- this self has different reference (managers.hud) in the else clause; everywhere else is still managers.hud._hud_assault_corner (or HUDAssaultCorner)
            local timer_msg = self._hud_player_downed._hud_panel:child("downed_panel"):child("timer_msg") -- Downed Timer
            timer_msg:set_y(96)
            self._hud_player_downed._hud.timer:set_y(math.round(timer_msg:bottom() - 6))
            if self:alive("guis/mask_off_hud") then
                self:script("guis/mask_off_hud").mask_on_text:set_y(96) -- Hold [G] to mask up
            end
            timer_msg = self._hud_player_custody._hud_panel:child("custody_panel"):child("timer_msg") -- Released from Custody Timer
            timer_msg:set_y(96)
            self._hud_player_custody._hud_panel:child("custody_panel"):child("timer"):set_y(math.round(timer_msg:bottom() - 6))
        end
    end
    log("[BAI] Assault Panel Position " .. (update and "updated" or "loaded"))
end

function HUDAssaultCorner:ApplyHooks()
    if not self.applied then
        dofile(BAI.LuaPath .. "assault_states.lua")
        dofile(BAI.LuaPath .. "localizationmanager.lua")
        managers.localization:SetVariables(self.is_client)
        if self.is_host and self.assault_extender_modifier then
            managers.localization:CSAE_Activate()
        end
        self.applied = true
    end
end

function HUDAssaultCorner:SetTimer()
    if self.is_host then
        return
    end
    self:SetSpawns()
    local sustain
    if self.is_skirmish then
        local value1, value2 = self:CalculateSkirmishTime()
        self.client_time_left = TimerManager:game():time() + value1
        sustain = value2
    else
        sustain = self:CalculateValueFromDiff()
        self.client_time_left = TimerManager:game():time() + self:CalculateAssaultTime() + sustain
        if self.assault_extender_modifier then
            self.client_time_left = self.client_time_left + (sustain / 2)
        end
    end
    if not self.CompatibleHost then
        local tweak = tweak_data.group_ai[self.is_skirmish and "skirmish" or "besiege"].assault
        BAI:DelayCall("BAI_AssaultStateChange_Sustain", tweak.build_duration, function()
            managers.hud:UpdateAssaultState("sustain")
        end)
        BAI:DelayCall("BAI_AssaultStateChange_Fade", tweak.build_duration + sustain, function()
            managers.hud:UpdateAssaultState("fade")
        end)
    end
end

function HUDAssaultCorner:SetSpawns()
    self.client_spawns_left = self:CalculateSpawnsFromDiff()
end

function HUDAssaultCorner:SetTimeLeft(time)
    if self.is_host then
        return
    end
    self.client_time_left = TimerManager:game():time() + time
end

function HUDAssaultCorner:GetAssaultTime(sender)
    if self.is_host and self._assault and not self._assault_endless and not self._assault_vip and sender then
        local tweak = tweak_data.group_ai.besiege.assault
        if self.is_skirmish then
            tweak = tweak_data.group_ai.skirmish.assault
        end
        local gai_state = managers.groupai:state()
        local assault_data = gai_state and gai_state._task_data.assault
        local get_value = gai_state._get_difficulty_dependent_value or function() return 0 end
        local get_mult = gai_state._get_balancing_multiplier or function() return 0 end

        if not (tweak and gai_state and assault_data and assault_data.active) then
            return
        end

        local time_left = assault_data.phase_end_t - gai_state._t
        local add
        if self.is_crimespree or self.assault_extender_modifier then
            local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), 0.5) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
            add = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", sustain_duration) - sustain_duration
            if add == 0 and self._wave_number == 1 and assault_data.phase == "build" then
                add = sustain_duration / 2 
            end
        end
        if assault_data.phase == "build" then
            local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), 0.5) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
            time_left = time_left + sustain_duration + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        elseif assault_data.phase == "sustain" then
            time_left = time_left + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        end
        LuaNetworking:SendToPeer(sender, BAI.AAI_SyncMessage, time_left)
    end
end

local _f_hide_casing = HUDAssaultCorner.hide_casing
function HUDAssaultCorner:hide_casing()
    self._casing_show_hostages = true
    _f_hide_casing(self)
end

local _f_start_assault = HUDAssaultCorner._start_assault
function HUDAssaultCorner:_start_assault(text_list)
    _f_start_assault(self, text_list)
    self._opened = true
    if self.was_endless then
        self.was_endless = false
        self:SetImage("assault")
    end
    if not (self._assault_vip or self._assault_endless) and self.trigger_assault_start_event then
        self.trigger_assault_start_event = false
        if BAI:GetOption("show_assault_states") and self.is_skirmish then
            self:_popup_wave_started()
        end
        BAI:CallEvent(BAI.EventList.AssaultStart)
    end
end

function HUDAssaultCorner:_start_endless_assault(text_list)
    if self._assault_vip then
        self:_start_assault(self:_get_assault_strings())
        return
    end
    if not self._assault_endless then
        BAI:CallEvent(BAI.EventList.EndlessAssaultStart)
    end
    self._assault_endless = true
    self.assault_type = "endless"
    self:_start_assault(text_list)
    self:SetImage("padlock")
    self:_update_assault_hud_color(self._assault_endless_color)
end

function HUDAssaultCorner:_end_assault()
    if not self._assault then
         self._start_assault_after_hostage_offset = nil
         return
    end
    self:RemoveASCalls()
    self:_set_feedback_color(nil)
    self._assault = false
    local endless_assault = self._assault_endless
    self._assault_endless = false
    self.assault_type = nil
    local box_text_panel = self._bg_box:child("text_panel")
    box_text_panel:stop()
    box_text_panel:clear()
    self._remove_hostage_offset = true
    self._start_assault_after_hostage_offset = nil
    local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
    icon_assaultbox:stop()
    if self:should_display_waves() then
        self.wave_survived = true
        self:_update_assault_hud_color(self._assault_survived_color)
        self:_set_text_list(self:_get_survived_assault_strings())
        box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
        icon_assaultbox:stop()
        icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))
        self._wave_bg_box:stop()
        self._wave_bg_box:animate(callback(self, self, "_animate_wave_completed"), self)
        if self.is_skirmish then
            self:_popup_wave_finished()
        end
    else
        if BAI:GetOption("show_wave_survived") then
            self:_update_assault_hud_color(self._assault_survived_color)
            self.wave_survived = true
            if endless_assault then
                self.wave_survived_endless = true
                self:SetImage("padlock")
            end
            self:_set_text_list(self:_get_survived_assault_strings(endless_assault))
            box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
            icon_assaultbox:stop()
            icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))
            box_text_panel:animate(callback(self, self, "_animate_normal_wave_completed"), self)
        else
            if BAI:GetOption("show_assault_states") then
                self:UpdateAssaultStateOverride("control", true)
            else
                self:_close_assault_box()
            end
        end
    end
    if not self.dont_override_endless then
        self.endless_client = false
    end
    BAI:CallEvent(BAI.EventList.AssaultEnd)
    self.trigger_assault_start_event = true -- Used for AssaultStart event; bugfix
end

function HUDAssaultCorner:_hide_icon_assaultbox(icon_assaultbox)
    local TOTAL_T = 1
    local t = TOTAL_T
    while t > 0 do
        local dt = coroutine.yield()
        t = t - dt
        local alpha = math.round(math.abs(math.cos(t * 360 * 2)))
        icon_assaultbox:set_alpha(alpha)
        if self._remove_hostage_offset and t < 0.03 then
            self:_set_hostages_offseted(false)
        end
    end
    if self._remove_hostage_offset then
        self:_set_hostages_offseted(false)
    end
    icon_assaultbox:set_alpha(0)
    if self._casing_show_hostages then
        self._casing_show_hostages = false
        self:_show_hostages() -- Hack; Figure out a better solution
    end
    if BAI:IsHostagePanelVisible() and not self._casing then
        self:_show_hostages(true) -- Another hack; TODO: Revise BAI animation functions
    end
end

function HUDAssaultCorner:SetImage(image)
    if image and BAI:IsOr(image, "assault", "padlock") then
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):set_image("guis/textures/pd2/hud_icon_" .. image .. "box")
        if image == "padlock" then
            self.was_endless = true
        end
    end
end

function HUDAssaultCorner:SetNormalAssaultOverride() -- Beneath the Mountain only
    if self.is_client and self.level_id == "hox_1" then
        self:SetTimeLeft(5)
    end
    self:SetImage("assault")
    self._assault_endless = false
    self.was_endless = false
    if BAI:GetOption("show_assault_states") then
        if self.is_host then
            self:UpdateAssaultStateOverride(managers.groupai:state():GetAssaultState())
        else
            if not self.BAIHost then
                self:_animate_update_assault_hud_color(self._assault_color)
                self:_set_text_list(self:_get_assault_strings(nil, true))
            else
                LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
            end
        end
    else
        self:_animate_update_assault_hud_color(self._assault_color)
        self:_set_text_list(self:_get_assault_strings(nil, true))
        if BAI.settings.show_advanced_assault_info and self.is_client then
            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
        end
    end
    BAI:CallEvent(BAI.EventList.NormalAssaultOverride)
end

function HUDAssaultCorner:_get_assault_endless_strings()
    if managers.job:current_difficulty_stars() > 0 then
        local ids_risk = self:GetRisk()
        return {
            "hud_assault_endless",
            "hud_assault_padlock",
            ids_risk,
            "hud_assault_padlock",
            "hud_assault_endless",
            "hud_assault_padlock",
            ids_risk,
            "hud_assault_padlock"
        }
    else
        return {
            "hud_assault_endless",
            "hud_assault_padlock",
            "hud_assault_endless",
            "hud_assault_padlock",
            "hud_assault_endless",
            "hud_assault_padlock",
        }
    end
end

function HUDAssaultCorner:UpdatePONRBox()
    self._noreturn_color = BAI:GetColor("escape")
    local panel = self._hud_panel:child("point_of_no_return_panel")
    panel:child("icon_noreturnbox"):set_color(self._noreturn_color)
    local bg_box = self._noreturn_bg_box
    bg_box:child("left_top"):set_color(self._noreturn_color)
    bg_box:child("left_bottom"):set_color(self._noreturn_color)
    bg_box:child("right_top"):set_color(self._noreturn_color)
    bg_box:child("right_bottom"):set_color(self._noreturn_color)
    local text = bg_box:child("point_of_no_return_text")
    local timer = bg_box:child("point_of_no_return_timer")
    text:set_color(self._noreturn_color)
    text:set_text(utf8.to_upper(managers.localization:text("hud_assault_point_no_return_in", {time = ""})))
    text:set_right(math.round(timer:left()))
    timer:set_color(self._noreturn_color)
end

function HUDAssaultCorner:show_point_of_no_return_timer()
    local delay_time = self._assault and 1.2 or 0
    self:_close_assault_box()
    local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
    self:_hide_hostages()
    point_of_no_return_panel:stop()
    point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
    self:_set_feedback_color(self._noreturn_color)
    self._point_of_no_return = true
    BAI:CallEvent(BAI.EventList.NoReturn, true)
end

BAI:Hook(HUDAssaultCorner, "hide_point_of_no_return_timer", function(self)
    BAI:CallEvent(BAI.EventList.NoReturn, false)
end)

function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
    local function flash_timer(o)
        local t = 0

        while t < 0.5 do
            t = t + coroutine.yield()
            local n = 1 - math.sin(t * 180)
            local r = math.lerp(self._noreturn_color.r, 1, n)
            local g = math.lerp(self._noreturn_color.g, 0.8, n)
            local b = math.lerp(self._noreturn_color.b, 0.2, n)

            o:set_color(Color(r, g, b))
            o:set_font_size(math.lerp(tweak_data.hud_corner.noreturn_size, tweak_data.hud_corner.noreturn_size * 1.25, n))
        end
    end

    local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")

    point_of_no_return_timer:animate(flash_timer)
end

function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud)
    local wave_text = panel:child("num_waves")
    local bg = panel:child("bg")

    wait(1.4)
    wave_text:set_text(self:get_completed_waves_string())
    bg:stop()
    bg:animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"), {})
    wait(7.2)
    if BAI:GetOption("show_assault_states") then
        self:UpdateAssaultStateOverride("control")
    else
        assault_hud:_close_assault_box()
    end
    self.wave_survived = false
end

function HUDAssaultCorner:UpdateAssaultStateColor(state, force_update)
    if state then
        if BAI:IsStateDisabled(state) then
            return
        end
        self:_animate_update_assault_hud_color(BAI:GetColor(state))
        self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text_change_assault_state"), state)
        if force_update and self.is_host then
            self:UpdateAssaultState(managers.groupai:state():GetAssaultState())
        end
    end
end

function HUDAssaultCorner:UpdateAssaultColor(color, assault_type)
    self:_animate_update_assault_hud_color(BAI:GetColor(color))
    self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text_change_normal_assault"), assault_type)
end

function HUDAssaultCorner:UpdateAssaultStateOverride(state, override)
    if not self._assault_vip and not self._assault_endless and not self._point_of_no_return then
        if BAI:GetOption("show_assault_states") then
            if state then
                self.assault_state = state
                BAI:CallEvent("AssaultStateChange", state, true)
                BAI:SyncAssaultState(state, true)
                if BAI:IsOr(state, "control", "anticipation") then
                    if BAI:IsStateDisabled(state) then
                        self:_close_assault_box()
                        return
                    end
                    self._assault = true
                    self:UpdateAssaultStateOverride_Override(state, override)
                else
                    if BAI:IsStateDisabled(state) then
                        self:_animate_update_assault_hud_color(self._assault_color)
                        self:_set_text_list(self:_get_assault_strings(nil, true))
                        if BAI.settings.show_advanced_assault_info and self.is_client then
                            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                        end
                        return
                    end
                    if BAI.settings.show_advanced_assault_info and self.is_client then
                        LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                    end
                    self:_set_text_list(self:_get_assault_strings(state, true))
                    self:_animate_update_assault_hud_color(BAI:GetColor(state))
                end
            end
        end
    end
end

function HUDAssaultCorner:UpdateAssaultStateOverride_Override(state, override)
    if self.was_endless then
        self:SetImage("assault")
        self.was_endless = false
    end
    self:_set_text_list(self:_get_state_strings(state))
    self:_animate_update_assault_hud_color(BAI:GetColor(state))
    if override then
        self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):stop()
        self._hud_panel:child("assault_panel"):child("icon_assaultbox"):animate(callback(self, self, "_show_icon_assaultbox"))
    end
end

function HUDAssaultCorner:start_assault_callback()
    self:SetTimer()
    if self:GetEndlessAssault() then
        self:_start_endless_assault(self:_get_assault_endless_strings())
    else
        self.assault_type = "assault"
        local state_enabled = BAI:GetOption("show_assault_states") and BAI:IsStateEnabled("build") or false
        self:_start_assault(self:_get_assault_strings(state_enabled and "build" or nil, true))
        self:_update_assault_hud_color(state_enabled and BAI:GetColor("build") or self._assault_color) -- Don't animate color transition
        if BAI.settings.show_advanced_assault_info and self.is_client then
            LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
        end
    end
end

function HUDAssaultCorner:UpdateColors()
    self._assault_color = self.is_skirmish and BAI:GetColor("holdout") or BAI:GetRightColor("assault")
    self._vip_assault_color = BAI:GetRightColor("captain")
    self._assault_endless_color = BAI:GetRightColor("endless")
    self._assault_survived_color = BAI:GetColor("survived")
    self:UpdatePONRBox()
end

function HUDAssaultCorner:SetCompatibleHost(BAI)
    self.CompatibleHost = true
    if BAI then
        self.BAIHost = true
    end
end

function HUDAssaultCorner:_get_assault_strings(state, aai) -- Apply Holy water after reading this
    if self._assault_mode == "normal" then
        if (state or aai) and (BAI:GetOption("show_assault_states") or BAI:ShowAdvancedAssaultInfo()) and BAI:GetOption("hide_assault_text") then
            local tbl = {}
            local ids_risk = self:GetRisk()
            local risk = managers.job:current_difficulty_stars() > 0
            local state_condition = state and BAI:IsOr(state, "build", "sustain", "fade") and BAI:GetOption("show_assault_states")
            local aai_condition = aai and BAI:ShowAdvancedAssaultInfo() and (BAI.settings.advanced_assault_info.aai_panel == 1 or not self.AAIPanel)
            for i = 1, 3 do -- if i == 1 only, the text dissapears from the assault panel which does not look nice
                if state_condition then
                    tbl[#tbl + 1] = "hud_" .. state
                    tbl[#tbl + 1] = "hud_assault_end_line"
                end
                if aai_condition then -- Adds advanced assault info
                    tbl[#tbl + 1] = "hud_advanced_info"
                    tbl[#tbl + 1] = "hud_assault_end_line"
                end
                if risk then
                    tbl[#tbl + 1] = ids_risk
                    tbl[#tbl + 1] = "hud_assault_end_line"
                end
            end
            return tbl
        end
        local assault_text = "hud_assault_assault"
        if BAI:IsCustomTextDisabled("assault") then
            assault_text = assault_text .. self:GetFactionAssaultText()
        end
        local ids_risk = self:GetRisk()
        local tbl = {
            assault_text,
            "hud_assault_end_line",
            assault_text,
            "hud_assault_end_line"
        }
        local risk = managers.job:current_difficulty_stars() > 0
        if risk then -- Adds risk icon
            table.insert(tbl, 3, ids_risk)
            table.insert(tbl, 4, "hud_assault_end_line")
            table.insert(tbl, 7, ids_risk)
            table.insert(tbl, 8, "hud_assault_end_line")
        else
            table.insert(tbl, 5, assault_text) -- Adds another assault line to return text like in Vanilla game
            table.insert(tbl, 6, "hud_assault_end_line")
        end
        if state and BAI:IsOr(state, "build", "sustain", "fade") and BAI:GetOption("show_assault_states") then -- Adds assault state
            local hud_state = "hud_" .. state
            if risk then
                table.insert(tbl, 3, hud_state)
                table.insert(tbl, 4, "hud_assault_end_line")
                table.insert(tbl, 9, hud_state)
                table.insert(tbl, 10, "hud_assault_end_line")
            else
                tbl[3] = hud_state -- Replaces second assault line with assault state
                table.insert(tbl, 7, hud_state)
                table.insert(tbl, 8, "hud_assault_end_line")
            end
        end
        if aai and BAI:ShowAdvancedAssaultInfo() and (BAI.settings.advanced_assault_info.aai_panel == 1 or not self.AAIPanel) then -- Adds advanced assault info
            if state then
                table.insert(tbl, 5, "hud_advanced_info")
                table.insert(tbl, 6, "hud_assault_end_line")
                table.insert(tbl, risk and 13 or 11, "hud_advanced_info")
                table.insert(tbl, risk and 14 or 12, "hud_assault_end_line")
            else
                tbl[3] = "hud_advanced_info" -- Replaces second assault line with advanced assault info
                table.insert(tbl, risk and 9 or 7, "hud_advanced_info")
                table.insert(tbl, risk and 10 or 8, "hud_assault_end_line")
            end
        end
        return tbl
    else
        if managers.job:current_difficulty_stars() > 0 then
            local ids_risk = self:GetRisk()
            return {
                "hud_assault_vip",
                "hud_assault_padlock",
                ids_risk,
                "hud_assault_padlock",
                "hud_assault_vip",
                "hud_assault_padlock",
                ids_risk,
                "hud_assault_padlock"
            }
        else
            return {
                "hud_assault_vip",
                "hud_assault_padlock",
                "hud_assault_vip",
                "hud_assault_padlock",
                "hud_assault_vip",
                "hud_assault_padlock"
            }
        end
    end
end

function HUDAssaultCorner:_get_survived_assault_strings(endless)
    local survived_text = "hud_assault_survived" .. (endless and "_endless" or "")
    local end_line = "hud_assault_" .. (endless and "padlock" or "end_line")
    if BAI:IsCustomTextEnabled("survived") then
        survived_text = "hud_assault_survived"
    else
        survived_text = survived_text .. self:GetFactionAssaultText(true)
    end
    if managers.job:current_difficulty_stars() > 0 then
        local ids_risk = self:GetRisk()
        return {
            survived_text,
            end_line,
            ids_risk,
            end_line,
            survived_text,
            end_line,
            ids_risk,
            end_line
        }
    else
        return {
            survived_text,
            end_line,
            survived_text,
            end_line,
            survived_text,
            end_line
        }
    end
end

function HUDAssaultCorner:_get_state_strings(state)
    local state_text = "hud_" .. state
    if managers.job:current_difficulty_stars() > 0 then
        local ids_risk = self:GetRisk()
        return {
            state_text,
            "hud_assault_end_line",
            ids_risk,
            "hud_assault_end_line",
            state_text,
            "hud_assault_end_line",
            ids_risk,
            "hud_assault_end_line"
        }
    else
        return {
            state_text,
            "hud_assault_end_line",
            state_text,
            "hud_assault_end_line",
            state_text,
            "hud_assault_end_line",
            state_text,
            "hud_assault_end_line"
        }
    end
end

function HUDAssaultCorner:_animate_normal_wave_completed(panel, assault_hud)
    wait(8.6)
    self.wave_survived = false
    self.wave_survived_endless = false
    if BAI:GetOption("show_assault_states") then
        self:UpdateAssaultStateOverride("control")
    else
        self:_close_assault_box()
    end
end

function HUDAssaultCorner:GetRisk()
    local difficulty
    if self.is_crimespree or not BAI:GetOption("show_difficulty_name_instead_of_skulls") then
        difficulty = Idstring("risk")
    else
        difficulty = self:GetDifficultyName()
    end
    return difficulty
end

function HUDAssaultCorner:GetDifficultyName()
    if tweak_data ~= nil then
        return tweak_data.difficulty_name_id
    else
        return Idstring("risk") -- Better safe than sorry
    end
end

function HUDAssaultCorner:GetEndlessAssault()
    if not self.no_endless_assault_override then
        if self.is_host and managers.groupai:state():get_hunt_mode() then
            LuaNetworking:SendToPeers(BAI.SyncMessage, BAI.data.EA)
            return true
        end -- Returns nil on host
        return self.endless_client
    end
    return false
end

function HUDAssaultCorner:_animate_text_change_normal_assault(panel, assault_type)
    wait(0.1)
    if BAI:IsOr(assault_type, "normal", "captain") then
        self:_set_text_list(self:_get_assault_strings(nil, true))
    elseif assault_type == "endless_assault" then
        self:_set_text_list(self:_get_assault_endless_strings())
    else
        if self.wave_survived_endless then
            self:_set_text_list(self:_get_survived_assault_endless_strings())
        else
            self:_set_text_list(self:_get_survived_assault_strings())
        end
    end
    if BAI:IsHostagePanelHidden() then
        self:_hide_hostages()
        if assault_type ~= "wave_survived" and BAI:IsHostagePanelVisible(assault_type) then
            self:_show_hostages()
        end
    end
end

function HUDAssaultCorner:_animate_text_change_assault_state(panel, state)
    wait(0.1)
    if BAI:IsOr(state, "control", "anticipation") then
        self:_set_text_list(self:_get_state_strings(state))
    else
        self:_set_text_list(self:_get_assault_strings(state, true))
        if BAI:IsHostagePanelHidden() then
            if BAI:IsHostagePanelVisible("assault") then
                self:_show_hostages()
            else
                self:_hide_hostages()
            end
        end
    end
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
    if self._assault_mode == mode then
        return
    end
    self._assault_mode = mode
    self._assault_vip = mode == "phalanx"
    BAI:CallEvent(BAI.EventList.Captain, self._assault_vip)
    self:_set_text_list(self:_get_assault_strings())
    self:SetImage(self._assault_vip and "padlock" or "assault")
    if mode == "phalanx" then
        self._assault_endless = false
        self:_animate_update_assault_hud_color(self._vip_assault_color)
    else
        self:SetTimeLeft(5) -- Set Time Left to 5 seconds when Captain is defeated
        if BAI:GetOption("show_assault_states") then
            self:UpdateAssaultState("fade") -- When Captain is defeated, Assault state is automatically set to Fade state
        else
            self:_animate_update_assault_hud_color(self._assault_color)
        end
    end
end

function HUDAssaultCorner:SetEndlessClient(dont_override)
    self.endless_client = true
    if dont_override then
        self.dont_override_endless = true
    end
end

function HUDAssaultCorner:UpdateAssaultState(state)
    if not self._assault_vip and not self._assault_endless and not self._point_of_no_return then
        if BAI:GetOption("show_assault_states") then
            if state and self.assault_state ~= state then
                self.assault_state = state
                BAI:SyncAssaultState(state)
                BAI:CallEvent("AssaultStateChange", state)
                if state == "build" and self.is_client then
                    LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                    return
                end
                if BAI:IsStateDisabled(state) then
                    if BAI:IsOr(state, "control", "anticipation") then
                        if self._assault then
                            self._assault = false
                            self._start_assault_after_hostage_offset = nil
                            self:_close_assault_box()
                        end
                    else
                        if self._assault then
                            if BAI.settings.show_advanced_assault_info and self.is_client then
                                LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                            end
                            self:_set_text_list(self:_get_assault_strings(nil, true))
                            self:_animate_update_assault_hud_color(self._assault_color)
                        end
                    end
                    return
                end
                if BAI:IsOr(state, "control", "anticipation") then
                    if not self._assault then
                        self.trigger_assault_start_event = false
                        self:_start_assault(self:_get_state_strings(state))
                        self:_set_hostages_offseted(true)
                        self.trigger_assault_start_event = true
                        BAI:CallEvent("MoveHUDList", self)
                    else
                        if state == "anticipation" then
                            self:_set_text_list(self:_get_state_strings(state))
                        end
                    end
                else
                    if BAI.settings.show_advanced_assault_info and self.is_client then
                        LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.ResendTime)
                    end
                    self:_set_text_list(self:_get_assault_strings(state, true))
                end
                if state == "control" then
                    self:_update_assault_hud_color(BAI:GetColor(state))
                else
                    self:_animate_update_assault_hud_color(BAI:GetColor(state))
                end
            end
        else
            if state and self.assault_state ~= state then
                self.assault_state = state
                BAI:SyncAssaultState(state)
                BAI:CallEvent("AssaultStateChange", state)
            end
        end
    end
end

function HUDAssaultCorner:_animate_update_assault_hud_color(color)
    if BAI:GetAnimationOption("enable_animations") and BAI:GetAnimationOption("animate_color_change") then
        self._bg_box:animate(callback(BAIAnimation, BAIAnimation, "ColorChange"), color, callback(self, self, "_update_assault_hud_color"), self._current_assault_color)
    else
        self:_update_assault_hud_color(color)
    end
end

function HUDAssaultCorner:_popup_wave_started()
    self:_popup_wave(self:wave_popup_string_start(), tweak_data.screen_colors.skirmish_color) -- Orange
end

function HUDAssaultCorner:_popup_wave_finished()
    self:_popup_wave(self:wave_popup_string_end(), Color(1, 0.12549019607843137, 0.9019607843137255, 0.12549019607843137)) -- Green
end

local _f_set_hostage_offseted = HUDAssaultCorner._set_hostage_offseted
function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    if self.assault_panel_position == 2 then
        local panel = managers.hud._hud_heist_timer._hud_panel:child("heist_timer_panel")
        self._remove_hostage_offset = nil

        panel:stop()
        panel:animate(callback(self, self, "_offset_hostage", is_offseted))

        return
    end

    if self.assault_panel_position == 1 then
        local panel = managers.hud._hud_objectives._hud_panel:child("objectives_panel")
        self._remove_hostage_offset = nil

        local panel_h = panel:h()

        panel:stop()
        panel:animate(callback(self, self, "_offset_hostage", is_offseted))

        if HUDListManager then -- Don't trigger assault start twice
            managers.hudlist:list("left_list")._panel:animate(callback(self, self, "_offset_hostages"), is_offseted, panel_h)
        end

        return
    end

    if self.AAIPanel then
        self._time_left_panel:stop()
        self._time_left_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        self._spawns_left_panel:stop()
        self._spawns_left_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        self._captain_panel:stop()
        self._captain_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)
    end

    _f_set_hostage_offseted(self, is_offseted)
end

function HUDAssaultCorner:_set_hostages_offseted(is_offseted)
    if self.assault_panel_position == 2 then
        local panel = managers.hud._hud_heist_timer._hud_panel:child("heist_timer_panel")
        self._remove_hostage_offset = nil

        panel:stop()
        panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        return
    end

    if self.assault_panel_position == 1 then
        local panel = managers.hud._hud_objectives._hud_panel:child("objectives_panel")
        self._remove_hostage_offset = nil

        local panel_h = panel:h()

        panel:stop()
        panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        if HUDListManager then
            managers.hudlist:list("left_list")._panel:animate(callback(self, self, "_offset_hostages"), is_offseted, panel_h)
        end

        return
    end

    local hostage_panel = self._hud_panel:child("hostages_panel")
    self._remove_hostage_offset = nil

    hostage_panel:stop()
    hostage_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

    local wave_panel = self._hud_panel:child("wave_panel")

    if wave_panel then
        wave_panel:stop()
        wave_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)
    end

    if self.AAIPanel then
        self._time_left_panel:stop()
        self._time_left_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        self._spawns_left_panel:stop()
        self._spawns_left_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)

        self._captain_panel:stop()
        self._captain_panel:animate(callback(self, self, "_offset_hostages"), is_offseted)
    end
end

function HUDAssaultCorner:_offset_hostages(hostage_panel, is_offseted) -- Just offseting panels, nothing more!
    local TOTAL_T = 0.18
    local OFFSET = self._bg_box:h() + 8
    local from_y = is_offseted and 0 or OFFSET
    local target_y = is_offseted and OFFSET or 0
    local t = (1 - math.abs(hostage_panel:y() - target_y) / OFFSET) * TOTAL_T
    while t < TOTAL_T do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        hostage_panel:set_y(math.lerp(from_y, target_y, lerp))
    end
end

function HUDAssaultCorner:_offset_hostages_width(hostage_panel, is_offseted) -- Animation for the assault panel when moving on the screen
    local TOTAL_T = 0.18
    local OFFSET = self._bg_box:w()
    local from_x = is_offseted and 0 or OFFSET
    local target_x = is_offseted and OFFSET or 0
    local t = (1 - math.abs(hostage_panel:x() - target_x) / OFFSET) * TOTAL_T
    while t < TOTAL_T do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        hostage_panel:set_x(math.lerp(from_x, target_x, lerp))
    end
end

local _f_close_assault_box = HUDAssaultCorner._close_assault_box
function HUDAssaultCorner:_close_assault_box()
    _f_close_assault_box(self)
    self._opened = false
end

local _f_show_hostages = HUDAssaultCorner._show_hostages
function HUDAssaultCorner:_show_hostages(no_animation)
    if not self._point_of_no_return and self.AnimateHostagesPanel and not no_animation then
        BAI:Animate(self._hud_panel:child("hostages_panel"), 1, "FadeIn")
        return
    end
    _f_show_hostages(self)
end

local _f_hide_hostages = HUDAssaultCorner._hide_hostages
function HUDAssaultCorner:_hide_hostages(no_animation)
    if self.AnimateHostagesPanel and not no_animation then
        BAI:Animate(self._hud_panel:child("hostages_panel"), 0, "FadeOut")
        return
    end
    _f_hide_hostages(self)
end

function HUDAssaultCorner:GetFactionAssaultText(ws)
    if BAI:ShowFSSAI() then
        return "_fss_mod_" .. math.random(1, 3)
    end
    if not BAI:GetOption("faction_assault_text") or ws or self.is_crimespree then
        return ""
    end
    local difficulty, faction = Global.game_settings.difficulty, tweak_data.levels:get_ai_group_type()
    if faction == "russia" then -- Every mission with Akan (Russian) enemies
        return "_russia"
    elseif Global.game_settings.level_id == "haunted" or faction == "zombie" then -- Safehouse Nightmare and every mission with zombie enemies
        return "_zombie"
    elseif faction == "murkywater" then -- Every mission with murkywater enemies
        return "_murkywater"
    elseif faction == "federales" then -- Every mission with federales (Spanish FBI) enemies
        return "_federales"
    elseif BAI:IsOr(difficulty, "normal", "hard") then -- Normal, Hard
        return ""
    elseif BAI:IsOr(difficulty, "overkill", "overkill_145") then -- Very Hard, OVERKILL
        return "_fbi"
    elseif BAI:IsOr(difficulty, "easy_wish", "overkill_290") then -- Mayhem, Death Wish
        return "_gensec"
    else --sm_wish; Death Sentence
        return "_zeal"
    end
end

local local_t = 0
local t_max = BAI:GetAAIOption("aai_panel_update_rate")
function HUDAssaultCorner:SetHook(hook, delay)
    if hook then
        local function f()
            if not BAI:ShowAdvancedAssaultInfo() or BAI:GetAAIOption("aai_panel") == 1 then
                return
            end
            local extension = ""
            if BAI:GetAAIOption("spawn_numbers") == 2 then
                extension = "BSN" -- Better Spawn Numbers
            end
            if self.is_client then
                extension = extension .. "Client"
            end
            managers.hud:add_updator("BAI_UpdateAAI", callback(self, self, "UpdateAdvancedAssaultInfo" .. extension))
            if BAI:GetAAIOption("show_time_left") then
                BAI:Animate(self._time_left_panel, 1, self.AAIFunction, unpack(self.AAIFunctionArgs1))
            end
            if BAI:GetAAIOption("show_spawns_left") then
                BAI:Animate(self._spawns_left_panel, 1, self.AAIFunction, unpack(self.AAIFunctionArgs2))
            end
        end

        BAI:DelayCall("ShowAAIPanel", delay or 1, f)
        --[[
            There's a weird bug, where all animations are stopped after 0.5 seconds after the assault panel is fully opened.
            Don't know what causes it, yet. Maybe a bug in the engine ?

            This delayed call ensures the fade in animation of AAI panel is properly played after a certain delay has passed (default 1 second;
            0 seconds for Captain (defeated) and Normal Assault Override events)
            after the assault panel is fully opened.

            TODO:
            Find out the cause of this issue and fix it
        ]]
    else
        BAI:RemoveDelayedCall("ShowAAIPanel")
        managers.hud:remove_updator("BAI_UpdateAAI")
        local_t = 0
        BAI:Animate(self._time_left_panel, 0, "FadeOut")
        BAI:Animate(self._spawns_left_panel, 0, "FadeOut")
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfo(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self._time_left_text:set_text(managers.localization:CalculateTimeLeft())
        self._spawns_left_text:set_text(math.round(math.max(managers.localization:CalculateSpawnsLeft(), 0)))
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoBSN(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self._time_left_text:set_text(managers.localization:CalculateTimeLeft())
        self._spawns_left_text:set_text(managers.enemy:GetNumberOfEnemies())
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoClient(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self._time_left_text:set_text(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()))
        self._spawns_left_text:set_text(managers.hud:GetSpawnsLeft())
        local_t = 0
    end
end

function HUDAssaultCorner:UpdateAdvancedAssaultInfoBSNClient(t, dt)
    local_t = local_t + dt
    if local_t > t_max then
        self._time_left_text:set_text(managers.localization:FormatTimeLeft(managers.hud:GetTimeLeft()))
        self._spawns_left_text:set_text(managers.enemy:GetNumberOfEnemies())
        local_t = 0
    end
end

function HUDAssaultCorner:SetCaptainHook(active)
    if not (BAI:ShowAdvancedAssaultInfo() and BAI:GetAAIOption("captain_panel")) then
        return
    end
    BAI:Animate(self._captain_panel, active and 1 or 0, active and "FadeIn" or "FadeOut")
end

local function round(v, bracket)
    bracket = bracket or 1
    local sign = v >= 0 and 1 or -1
    return math.floor(v / bracket + sign * 0.5) * bracket
end

function HUDAssaultCorner:SetCaptainBuff(buff)
    if not (self.AAIPanel and BAI:GetAAIOption("captain_panel")) then
        return
    end
    self._captain_bg_box:child("num_reduction"):set_text((round(buff, 0.01) * 100) .. "%")
    self._captain_bg_box:child("bg"):animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"))
end

function HUDAssaultCorner:FormatTime(time)
    time = math.max(math.floor(time), 0)
    local minutes = math.floor(time / 60)
    time = time - minutes * 60
    local seconds = math.round(time)
    local text = ""

    return text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
end

function HUDAssaultCorner:SetTradeDelay(time, killed_ammount)
    if killed_ammount == 0 then
        if BAI.settings.advanced_assault_info.trade_delay_panel_when ~= 1 then
        end
    end
    self._trade_delay_bg_box:child("num_delay"):set_text(self:FormatTime(time))
    self._trade_delay_bg_box:child("bg"):animate(callback(nil, _G, "HUDBGBox_animate_bg_attention"))
end

function HUDAssaultCorner:SetCivilianKilled(amount)
    if amount then
        if amount < 0 then
            amount = 0
        end
        self.civilians_killed = amount
        local tweak = tweak_data.player.damage
        local time = tweak.base_respawn_time_penalty
        if amount > 0 then
            time = time + (tweak.respawn_time_penalty * self.civilians_killed)
        end
        self:SetTradeDelay(time, amount)
        return
    end
    self.civilians_killed = (self.civilians_killed or 0) + 1
    local tweak = tweak_data.player.damage
    local time = tweak.base_respawn_time_penalty + (tweak.respawn_time_penalty * self.civilians_killed)
    self:SetTradeDelay(time, self.civilians_killed)
end

function HUDAssaultCorner:RemoveASCalls()
    if self.is_client then
        BAI:RemoveDelayedCall("BAI_AssaultStateChange_Sustain")
        BAI:RemoveDelayedCall("BAI_AssaultStateChange_Fade")
    end
end