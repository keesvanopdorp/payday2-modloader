if not RequiredScript then
    return
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
    BAI:Init()
    dofile(BAI.LuaPath .. "animations.lua")
    dofile(BAI.LuaPath .. "network.lua")
    dofile(BAI.LuaPath .. "hudmanagerpd2.lua")
    dofile(BAI.LuaPath .. "menumanager.lua")
    BAI:DelayCall("BAI_MUI_HookDelay", 2, function()
        if MUIStats then -- MUI
            dofile(BAI.LuaPath .. "hudassaultcorner.lua")
            HUDAssaultCorner:InitBAI()
        end
    end)
end

if RequiredScript == "core/lib/utils/coreapp" then
    if BAI then
        BAI = BAI or {}
        return
    end

    BAI = {
        --- Sync Messages; do not change them!
        SyncMessage = "BAI_Message",
        AS_SyncMessage = "BAI_AssaultState",
        ASO_SyncMessage = "BAI_AssaultStateOverride",
        AAI_SyncMessage = "BAI_AdvancedAssaultInfo_TimeLeft",
        EE_SyncMessage = "BAI_EasterEgg",
        EE_ResetSyncMessage = "BAI_EasterEgg_Reset",
        --- Sync Messages

        --- Data Sync Messages; do not change them!
        data =
        {
            EA = "endless_triggered",
            BAI_Q = "BAI?";
            BAI_A = "BAI!",
            EA_Q = "IsEndlessAssault?",
            NA_O = "NormalAssaultOverride",
            ResendAS = "RequestCurrentAssaultState",
            ResendTime = "RequestCurrentAssaultTimeLeft",
            EE_FSS1_Q = "AIReactionTimeTooHigh?",
            EE_FSS1_A = "AIReactionTimeTooHigh"
        },
        --- Data Sync Messages

        --- Easter Eggs
        EasterEgg =
        {
            FSS =
            {
                AIReactionTimeTooHigh = false
            }
        },
        --- Easter Eggs

        --- HUD Synchronization
        HUD =
        {
            KineticHUD =
            {
                DownCounter = "DownCounterStandalone", -- I use this to know if the host has KineticHUD/NobleHUD active
                SyncAssaultPhase = "SyncAssaultPhase"
            }
        },
        --- HUD Synchronization

        --- Event List
        EventList =
        {
            AssaultStart = "AssaultStart",
            EndlessAssaultStart = "EndlessAssaultStart",
            AssaultStateChange = "AssaultStateChange", -- (state: string -> control or anticipation or build or sustain or fade; override: bool -> true or false)
            Captain = "Captain", -- (active: bool -> true or false)
            AssaultEnd = "AssaultEnd",
            NoReturn = "NoReturn", -- (active: bool -> true or false)
            NormalAssaultOverride = "NormalAssaultOverride",
            Update = "Update"
        },
        -- Devs are free to add their custom events. BAI itself does not trigger custom events. You have to trigger them manually via method BAI:CallEvent(<your event>).
        -- Custom events does not have to be in the Event List.
        --- Event List

        Events =
        {
        },

        Modules =
        {
        },

        ModPath = ModPath,
        LocPath = ModPath .. "loc/",
        LuaPath = ModPath .. "lua/",
        MenuPath = ModPath .. "menu/",
        HostPath = ModPath .. "lua/host/",
        ClientPath = ModPath .. "lua/client/",
        HUDCompatibilityPath = ModPath .. "lua/compatibility/hud/",
        ModCompatibilityPath = ModPath .. "lua/compatibility/mod/",
        MenuCompatibilityPath = ModPath .. "menu/compatibility/",
        SettingsSaveFilePath = SavePath .. "bai.json",
        Update = false,
        Language = "english",
        SaveDataVer = 5
    }

    function BAI:Init()
        self.IsHost = Network:is_server()
        self.IsClient = not self.IsHost
        self.color_type = managers.mutators and (managers.mutators:are_mutators_active() and "_mutated" or "") or ""
        self.CustomTextLength = "long"
        self:EasterEggInit()
    end

    function BAI:EasterEggInit()
        local diff = Global.game_settings.difficulty
        self.EasterEgg.FSS.AIReactionTimeTooHigh = (FullSpeedSwarm and (FullSpeedSwarm.settings.task_throughput > 600 or FullSpeedSwarm.settings.task_throughput == 0) and self.IsHost and diff == "sm_wish") or
            (managers.crime_spree and managers.crime_spree:is_active() and managers.crime_spree:server_spree_level() >= 500 or false)
    end

    function BAI:PreHook(object, func, pre_call)
        Hooks:PreHook(object, func, "BAI_Pre_" .. func, pre_call)
    end

    function BAI:Hook(object, func, post_call)
        Hooks:PostHook(object, func, "BAI_" .. func, post_call)
    end

    function BAI:Unhook(mod, id)
        Hooks:RemovePostHook((mod and (mod .. "_") or "BAI_") .. id)
    end

    function BAI:ApplyHUDCompatibility(hud)
        dofile(self.HUDCompatibilityPath .. hud .. ".lua")
        local _v2_corner = managers.hud._hud_assault_corner._v2_corner
        if self:IsOr(hud, "pdth_hud_reborn", "restoration_mod", "halo_reach_hud", "mui") then
            if hud == "restoration_mod" then
                self.CustomTextLength = _v2_corner and "short_first" or "long"
            else
                self.CustomTextLength = "short_first"
            end
        end
    end

    function BAI:ApplyModCompatibility(mod)
        dofile(self.ModCompatibilityPath .. mod .. ".lua")
    end

    function BAI:DelayCall(name, t, func)
        DelayedCalls:Add(name, t, func)
    end

    function BAI:RemoveDelayedCall(name)
        DelayedCalls:Remove(name)
    end

    function BAI:Load()
        self:LoadDefaultValues()
        local file = io.open(self.SettingsSaveFilePath, "r")
        if file then
            local table = json.decode(file:read('*all')) or {}
            file:close()
            if table.SaveDataVer and table.SaveDataVer == self.SaveDataVer then
                self:LoadValues(self.settings, table)
                log("[BAI] Loaded user settings")
            else
                self.SaveDataNotCompatible = true
                self:Save()
            end
        end
        for _, mod in pairs(BLT.Mods:Mods()) do
            if mod:GetName() == "Better Assault Indicator" and mod:GetAuthor() == "Dom" then
                self.ModVersion = tonumber(mod:GetVersion())
                break
            end
        end
    end

    function BAI:LoadValues(bai_table, file_table)
        for k, v in pairs(file_table) do -- Load subtables in table and calls the same method to load subtables or values in that subtable
            if type(file_table[k]) == "table" and bai_table[k] then
                self:LoadValues(bai_table[k], v)
            end
        end
        for k, v in pairs(file_table) do
            if type(file_table[k]) ~= "table" then
                if bai_table and bai_table[k] ~= nil then -- Load values to the table
                    bai_table[k] = v
                end
            end
        end
    end

    function BAI:Save()
        self.settings.SaveDataVer = self.SaveDataVer
        self.settings.ModVersion = self.ModVersion
        local file = io.open(self.SettingsSaveFilePath, "w+")
        if file then
            file:write(json.encode(self.settings) or {})
            file:close()
        end
    end

    function BAI:LoadDefaultValues()
        local file = io.open(self.MenuPath .. "default_values.json", "r")
        if file then
            self.settings = json.decode(file:read('*all') or { mod_language = 1 })
            log("[BAI] Default values loaded")
            file:close()
        else
            log("[BAI Warning] No default values were found! Game may crash unexpectedly!")
            self.settings = { mod_language = 1 }
        end
    end

    function BAI:GetRightColor(type)
        if not type or not self.settings.assault_panel[type] then
            return Color.white
        end
        if self:IsOr(type, "assault", "captain", "endless") then
            return self:GetColor(type .. self.color_type)
        else
            return self:GetColor(type)
        end
    end

    function BAI:GetColor(type)
        if not type or not self.settings.assault_panel[type] then
            return Color.white
        end
        return self:GetColorFromTable(self.settings.assault_panel[type])
    end

    function BAI:GetColorRestoration(type)
        if not type or not self.settings.hud.restoration_mod.assault_panel[type] then
            return Color.white
        end
        local c = self.settings.hud.restoration_mod.assault_panel[type]
        return self:GetColorFromTable(c.c1), self:GetColorFromTable(c.c2)
    end

    function BAI:GetColorFromTable(value)
        if value and value.r and value.g and value.b then
            return Color(255, value.r, value.g, value.b) / 255
        end
        return Color.white
    end

    function BAI:IsHostagePanelVisible(type)
        if self.settings.completely_hide_hostage_panel then
            return false
        end
        if not type or not self.settings.assault_panel[type] then
            return true
        end
        return not self.settings.assault_panel[type].hide_hostage_panel -- 'hide_hostage_panel' variable is set true => Hide Hostage Panel, otherwise not
    end

    function BAI:IsHostagePanelHidden(type)
        return not self:IsHostagePanelVisible(type)
    end

    function BAI:IsStateEnabled(state) -- Change Enabled to Visible
        if not state or not self.settings.assault_panel[state] then
            return true
        end
        return self.settings.assault_panel[state].enabled
    end

    function BAI:IsStateDisabled(state)
        return not self:IsStateEnabled(state)
    end

    function BAI:IsCustomTextEnabled(text)
        if not text or not self.settings.assault_panel[text] then
            return false
        end
        local t = self.settings.assault_panel[text]
        if self.CustomTextLength == "long" then
            return t.custom_text and t.custom_text ~= "" or false
        elseif self.CustomTextLength == "short_first" then
            return t.short_custom_text and (t.short_custom_text ~= "") or (t.custom_text and t.custom_text ~= "")
        else
            return t.short_custom_text and t.short_custom_text ~= "" or false
        end
    end

    function BAI:IsCustomTextDisabled(text)
        return not self:IsCustomTextEnabled(text)
    end

    function BAI:ShowAdvancedAssaultInfo()
        return self.settings.show_advanced_assault_info and (self.settings.advanced_assault_info.show_time_left or self.settings.advanced_assault_info.show_spawns_left)
    end

    function BAI:ShowFSSAI()
        return self.EasterEgg.FSS.AIReactionTimeTooHigh and math.random(0, 100) % 10 == 0
    end

    function BAI:CallEvent(event_name, ...)
        if not event_name then
            log("[BAI] Event Name cannot be a nil value")
            return
        end
        for k, v in ipairs(self.Events) do
            if v.event_name == event_name then
                if v.delay > 0 then
                    self:DelayCall("BAI_CallEvent_" .. v.event_name .. "_" .. k, v.delay, v.func)
                else
                    v.func(...)
                end
            end
        end
    end

    function BAI:RegisterModule(module_name, event_name, func, delay)
        if not module_name then
            log("[BAI] Module Name cannot be a nil value")
            return
        end
        if not event_name then
            log("[BAI] Event Name cannot be a nil value")
            return
        end
        if not func then
            log("[BAI] Function cannot be a nil value")
            return
        end
        if not type(func) == "function" then
            log("[BAI] Passed function is not a function")
            return
        end
        if delay and type(delay) ~= "number" then
            log("[BAI] Passed delay is not a number")
            return
        end
        self.Events[#self.Events + 1] = { event_name = event_name, func = func, delay = delay or 0 }
        log("[BAI] Module '" .. module_name .. "' registered")
    end

    function BAI:GetOption(option)
        if option then
            return self.settings[option]
        end
    end

    function BAI:GetAAIOption(option)
        if option then
            return self.settings.advanced_assault_info[option]
        end
    end

    function BAI:GetHUDOption(hud, option)
        if hud and option then
            return self.settings.hud[hud][option]
        end
    end

    function BAI:GetAnimationOption(option, check_enabled)
        check_enabled = check_enabled or true
        if option then
            if check_enabled then
                if not self.settings.animation.enable_animations then
                    return false
                end
            end
            return self.settings.animation[option]
        end
    end

    function BAI:Animate(o, a, f, ...)
        o:stop()
        if self:GetAnimationOption("enable_animations", false) then
            o:animate(callback(BAIAnimation, BAIAnimation, f), ...)
        else
            o:set_alpha(a)
        end
    end

    function BAI:IsOr(string, ...)
        for i = 1, select("#", ...) do
            if string == select(i, ...) then
                return true
            end
        end
        return false
    end

    function BAI:SyncAssaultState(state, override, stealth_broken, no_as_mod)
        if self.IsClient then
            return
        end
        if state then
            if not self:IsOr(state, "control", "anticipation", "build") or stealth_broken then
                LuaNetworking:SendToPeers(self["AS" .. (override and "O" or "") .. "_SyncMessage"], state)
            end
            if not no_as_mod then
                LuaNetworking:SendToPeers("AssaultStates_Net", state)
                LuaNetworking:SendToPeers("SyncAssaultPhase", state) -- KineticHUD and NobleHUD
            end
        end
    end

    log("[BAI] Loading saved settings")
    BAI:Load()
end