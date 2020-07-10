local fade, fade_c = ArmStatic.fade_animate, ArmStatic.fade_c_animate;
local function line(fgr, p, s, size)
    if fgr:get("text_rect") then fgr:rect(size):attach(s, 2, size/3);
    else fgr:shape(size):attach(s, 2, size/3); end
end

function MUIStats:InitPanels()
    local muiFont = ArmStatic.font_index(self._muiFont)
    local panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:child("stats_panel")
    local loot_panel = panel:child("loot_panel")
    local time_left_panel = panel:panel({
        layer = 1,
        name = "time_left_panel",
        visible = true
    })
    self._time_left_panel = time_left_panel
    time_left_panel:bitmap({
        name = "icon",
        texture = "guis/textures/pd2/specialization/icons_atlas",
        texture_rect = { 196, 70, 52, 52 } -- placeholder icon
    })
    time_left_panel:text({
        name = "amount",
        font = muiFont,
        text = managers.localization:text("hud_time_left") .. "00:00"
    })

    local spawns_left_panel = panel:panel({
        layer = 1,
        name = "spawns_left_panel",
        visible = true
    })
    self._spawns_left_panel = spawns_left_panel
    spawns_left_panel:bitmap({
        name = "icon",
        texture = "guis/textures/pd2/specialization/icons_atlas",
        texture_rect = { 196, 70, 52, 52 } -- placeholder icon
    })
    spawns_left_panel:text({
        name = "amount",
        font = muiFont,
        text = managers.localization:text("hud_spawns_left") .. "0"
    })

    local size = self._muiSize
    local mul = self._muiWMul
    local width = size * mul
    local s33 = size / 3
    --Figure(time_left_panel):progeny(line, s33):adapt()
    Figure(time_left_panel):shape(width, size / 3 * 2):attach(loot_panel, 3)
    Figure(spawns_left_panel):shape(width, size / 3 * 2):attach(time_left_panel, 3)

    --self._time_left_panel:set_y(loot_panel:y() + time_left_panel:h() + 10)
    --self._spawns_left_panel:set_y(time_left_panel:y() + spawns_left_panel:h() + 10)

    local hPos = self._muiHPos;
    local vPos = self._muiVPos;
    local hMargin = self._muiHMargin;
    local vMargin = self._muiVMargin;
    local alpha = self._muiAlpha;
    -- Resize
    --[[local size = self._muiSize
    local mul = self._muiWMul
    local hPos = self._muiHPos;
    local vPos = self._muiVPos;
    local hMargin = self._muiHMargin;
    local vMargin = self._muiVMargin;
    local alpha = self._muiAlpha;
    local width = size * mul
    Figure(time_left_panel):shape(width, size / 3 * 2):attach(loot_panel, 3)
    Figure(spawns_left_panel):shape(width, size / 3 * 2):attach(time_left_panel, 3)
    Figure(panel):view(alpha):adapt(time_left_panel):align(hPos, vPos, hMargin, vMargin)]]
    self:ResizeBAIPanels(panel)
    --Figure(panel):view(alpha):adapt(time_left_panel):align(hPos, vPos, hMargin, vMargin);
end

function MUIStats:ResizeBAIPanels(stats_panel)
    local s33 = self._muiSize/3;
    
    local time = self._time_left_panel;
    local spawns = self._spawns_left_panel
    local time_i = time:child("icon")
    local time_t = time:child("amount")
    local spawns_i = spawns:child("icon")
    local spawns_t = spawns:child("amount")
    local bag = stats_panel:child("loot_panel"):child("bag_panel")
    local secured = stats_panel:child("loot_panel"):child("title")
    
    local indent_t = time:w() * 0.05
    local indent_s = spawns:w() * 0.05

    Figure(time):attach(secured, 3)
    Figure(time_i):shape(s33):attach(secured, 2, s33)
    Figure(time_t):rect(s33):attach(time_i, 2):fill()
    
    --[[Figure(spawns):progeny(line, s33):adapt():attach(time, 3):shift(indent_s)
    Figure(spawns_i):shape(s33):attach(time, 2, s33)
    Figure(spawns_t):rect(s33):attach(spawns_i, 2):fill()]]
    
    --[[Figure(time):progeny(line, s33):adapt():attach(bag, 3):shift(indent_t);
    Figure(time_i):shape(s33):attach(bag, 2, s33);
    
    Figure(spawns):progeny(line, s33):adapt():attach(time, 3):shift(indent_s)
    Figure(spawns_i):shape(s33):attach(time, 2, s33)]]
end

function MUIStats:sync_set_assault_mode(mode)
    if self._assault_mode == mode then
        return
    end
    self._assault_vip = mode == "phalanx"
    self._assault_mode = mode
    BAI:CallEvent(BAI.EventList.Captain, self._assault_vip)
    self:UpdateColor(BAI:GetRightColor(mode == "phalanx" and "captain" or "assault"))
    if BAI:IsHostagePanelVisible() then
        if mode == "phalanx" then
            if BAI:IsHostagePanelHidden("captain") then
                self:_hide_hostages()
            end
            self._assault_endless = false
        else
            if BAI:IsHostagePanelVisible("assault") then
                self:_show_hostages()
            end
        end
    end
    if mode ~= "phalanx" then
        --self:SetTimeLeft(5) -- Set Time Left to 5 seconds when Captain is defeated
        if (self.is_host or (self.is_client and self.CompatibleHost)) and BAI.settings.show_assault_states then
            self:UpdateAssaultState("fade")
        else
            self:UpdateAssaultText(self:GetAssaultText(), "assault")
        end
    else
        self:UpdateAssaultText("hud_captain", "captain")
    end
end

local _MUI_set_wave = MUIStats.set_wave
function MUIStats:set_wave(wave)
    _MUI_set_wave(self, wave)
    self._wave_number = wave or 0
end

local function CalculateSkirmishTime()
    local tweak_skirmish = tweak_data.group_ai.skirmish
    return tweak_skirmish.build_duration + tweak_skirmish.sustain_duration_max[1] + tweak_skirmish.fade_duration
end

local function CalculateAssaultTime()
    local assault_tweak = tweak_data.group_ai.besiege.assault
    return assault_tweak.build_duration + assault_tweak.fade_duration
end

function MUIStats:SetTimer()
    if self.is_host then
        return
    end
    if self.is_skirmish then
        self.client_time_left = TimerManager:game():time() + CalculateSkirmishTime()
    else
        local sustain = managers.hud._hud_assault_corner:CalculateValueFromDiff()
        self.client_time_left = TimerManager:game():time() + CalculateAssaultTime() + sustain
        if self.is_crimespree and managers.crime_spree:DoesServerHasAssaultExtenderModifier() then
            self.client_time_left = self.client_time_left + (sustain / 2)
        end
    end
end

function MUIStats:SetTimeLeft(time)
    self.client_time_left = TimerManager:game():time() + time
end

function MUIStats:set_no_return(state)
    if self._no_return == state then return end
    self._no_return = state;
    fade_c(self._heist_time, state and BAI:GetColor("escape") or Color.white, 1);
    self.wave_survived = false
    self:SetAssaultText(managers.localization:text("hud_escape"))
    self:UpdateColor(BAI:GetColor("escape"))
    self:_hide_hostages()
end

local _MUI_sync_start_assault = MUIStats.sync_start_assault
function MUIStats:sync_start_assault(wave)
    if self._no_return then
        return
    end
    _MUI_sync_start_assault(self, wave)
    self._assault = true
    if self:GetEndlessAssault() then
        if not self._assault_endless then
            self.trigger_assault_start_event = false
            BAI:CallEvent(BAI.EventList.EndlessAssaultStart)
        end
        self._assault_endless = true
        self:UpdateColor(BAI:GetRightColor("endless"))
        self:UpdateAssaultText("hud_endless", "endless")
    else
        if self.trigger_assault_start_event then
            self.trigger_assault_start_event = false
            BAI:CallEvent(BAI.EventList.AssaultStart)
        end
        if self.is_client then
            --self:SetTimer()
        end
        if not BAI:GetOption("show_difficulty_name_instead_of_skulls")then
            self:UpdateAssaultText("hud_assault", "assault")
        end
        if BAI.settings.show_assault_states then
            if self.is_host or (self.is_client and self.CompatibleHost) then
                if BAI:IsStateEnabled("build") then
                    self:UpdateAssaultText("hud_build", "build")
                end
            end
        end
    end
    if BAI:IsHostagePanelHidden(self._assault_endless and "endless_assault" or "assault") then
        self:_hide_hostages()
    end
end

function MUIStats:GetEndlessAssault()
    if not self.no_endless_assault_override then
        if self.is_host and managers.groupai:state():get_hunt_mode() then
            LuaNetworking:SendToPeers(BAI.SyncMessage, BAI.data.EA)
            return true
        end -- Returns false
        return self.endless_client
    end
    return false
end

function MUIStats:start_assault()
    local panel = self._assault_panel;
    panel:stop();
    panel:animate(callback(panel, self, "assault_pulse"));
end

function MUIStats:GetAssaultPanel()
    return self._assault_panel
end

function MUIStats:sync_end_assault()
    local panel = self._assault_panel
    local panel2 = self._wave_panel
    self._assault = false
    self._assault_endless = false
    if BAI:GetOption("show_wave_survived") then
        self.wave_survived = true
        self:UpdateColor(BAI:GetColor("survived"))
        self:UpdateAssaultText("hud_survived", "survived")
        panel2:animate(callback(panel, self, "WaveSurvived", self))
    else
        if BAI:GetOption("show_assault_states") then
            if self.is_host or (self.is_client and self.CompatibleHost) then
                self:UpdateAssaultStateOverride("control")
            else
                self:_close_assault_box()
            end
        else
            self:_close_assault_box()
        end
    end
    if BAI:IsHostagePanelVisible() then
        self:_show_hostages()
    end
    if not self.dont_override_endless then
        self.endless_client = false
    end
    BAI:CallEvent(BAI.EventList.AssaultEnd)
    self.trigger_assault_start_event = true
end

function MUIStats.WaveSurvived(o, hud)
    wait(8.6)
    if BAI.settings.show_assault_states then
        if hud.is_host or (hud.is_client and hud.CompatibleHost) then
            hud:UpdateAssaultStateOverride("control", true)
        else
            hud:_close_assault_box()
        end
    else
        hud:_close_assault_box()
    end
end

function MUIStats:_hide_hostages()
    self._supplement_list:child("hostages_panel"):set_visible(false)
end

function MUIStats:_show_hostages()
    self._supplement_list:child("hostages_panel"):set_visible(true)
end

function MUIStats:UpdateColor(color)
    color = color or Color.white
    local panel = self._assault_panel
    fade_c(panel:child("risk"), color, 1)
    fade_c(panel:child("title"), color, 1)
    fade_c(panel:child("icon"), color, 1)
end

function MUIStats:_close_assault_box()
    self.wave_survived = false
    local panel = self._assault_panel
    panel:stop()
    panel:animate(callback(panel, self, "assault_end"))
end

function HUDAssaultCorner:UpdatePONRBox()
end

function MUIStats:UpdateAssaultText(text, text_id)
    if BAI:ShowFSSAI() and Global.game_settings.difficulty == "sm_wish" and text_id and BAI:IsCustomTextDisabled(text_id) then
        text = "hud_fss_mod_" .. math.random(1, 3)
    end
    self:SetAssaultText(text)
end

function MUIStats:SetAssaultText(text)
    self._assault_panel:child("title"):set_text(utf8.to_upper(managers.localization:text(text)))
    self:MakeFineText(self._assault_panel:child("title"))
end

function MUIStats:MakeFineText(text)
    local x, y, w, h = text:text_rect()
    
    text:set_size(w, h)
    text:set_position(math.round(text:x()), math.round(text:y()))
end

function MUIStats:UpdateAssaultState(state)
    if not self._assault_vip and not self._assault_endless and not self._no_return then
        if BAI.settings.show_assault_states then
            if state and self.assault_state ~= state then
                self.assault_state = state
                BAI:SyncAssaultState(state)
                BAI:CallEvent("AssaultStateChange", state)
                if state == "build" then
                    self:UpdateColor(BAI:GetColor(state))
                    return
                end
                if state == "anticipation" and self.is_client and not self.CompatibleHost then
                    return
                end
                if BAI:IsStateDisabled(state) then
                    if BAI:IsOr(state, "control", "anticipation") then
                        if self._assault then
                            self._assault = false
                            self:_close_assault_box()
                        end
                    else
                        if self._assault then
                            --[[if BAI.settings.show_advanced_assault_info then
                            else
                            end]] -- AAI not visible in MUI, yet
                            self:UpdateAssaultText(self:GetAssaultText(), "assault")
                            self:UpdateColor(BAI:GetColor("assault"))
                        end
                    end
                    return
                end
                if BAI:IsOr(state, "control", "anticipation") then
                    if not self._assault then
                        self:start_assault()
                        self:UpdateAssaultText("hud_" .. state, state)
                    else
                        if state == "anticipation" then
                            self:UpdateAssaultText("hud_anticipation", "anticipation")
                        end
                    end
                else
                    --[[if BAI.settings.show_advanced_assault_info then
                    else
                    end]]
                    self:UpdateAssaultText("hud_" .. state, state)
                end
                self:UpdateColor(BAI:GetColor(state))
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

function MUIStats:UpdateAssaultStateOverride(state, override)
    if not self._assault_vip and not self._assault_endless and not self._no_return then
        if BAI.settings.show_assault_states then
            if state then
                BAI:CallEvent("AssaultStateChange", state, true)
                if BAI:IsOr(state, "control", "anticipation") then
                    self.assault_state = state
                    if BAI:IsStateDisabled(state) then
                        self:_close_assault_box()
                        return
                    end
                    self._assault = true
                    if override then
                        self.wave_survived = false
                        self:UpdateColor(BAI:GetColor(state))
                        self:UpdateAssaultText("hud_" .. state, state)
                    end    
                else
                    self.assault_state = state
                    if BAI:IsStateDisabled(state) then
                        self:UpdateColor(BAI:GetColor("assault"))
                        self:UpdateAssaultText(self:GetAssaultText(), "assault")
                        return
                    end
                    self:UpdateColor(BAI:GetColor(state))
                end
                if self.is_host then
                    BAI:SyncAssaultState(state, true)
                end
            end
        end
    end
end

function MUIStats:SetNormalAssaultOverride()
    if self.is_client and self.level_id == "hox_1" then
        self:SetTimeLeft(5)
    end
    self._assault_endless = false
    if BAI.settings.show_assault_states then
        if self.is_host then
            local new_state = managers.groupai:state():GetAssaultState() or "sustain" -- To be sure the game does not crash
            self:UpdateAssaultStateOverride(new_state)
            self:UpdateAssaultText("hud_" .. new_state, new_state)
        else
            if not self.BAIHost then
                self:UpdateColor(BAI:GetColor("assault"))
                self:UpdateAssaultText(self:GetAssaultText(), "assault")
            end
        end
    else
        self:UpdateColor(BAI:GetColor("assault"))
        self:UpdateAssaultText(self:GetAssaultText(), "assault")
    end
    if BAI:IsHostagePanelVisible("assault") then
        self:_show_hostages()
    end
    BAI:CallEvent(BAI.EventList.NormalAssaultOverride)
end

function MUIStats:GetAssaultText()
    return BAI:GetOption("show_difficulty_name_instead_of_skulls") and tweak_data.difficulty_name_id or "hud_assault"
end

function MUIStats:SetEndlessClient(setter, dont_override)
    self.endless_client = setter
    if dont_override then
        self.dont_override_endless = true
    end
end

function MUIStats:UpdateVariables()
    self.is_client = Network:is_client()
    self.is_host = not self.is_client
    self.CompatibleHost = false
    self.BAIHost = false
    self.assault_state = "nil"
    self.heists_with_fake_endless_assault = { "framing_frame_1", "gallery", "watchdogs_2", "bph" } -- Framing Frame Day 1, Art Gallery, Watch Dogs Day 2, Hell's Island
    self.no_endless_assault_override = table.contains(self.heists_with_fake_endless_assault, Global.game_settings.level_id)
    self.is_skirmish = managers.skirmish and managers.skirmish:is_skirmish() or false -- Because MUI is shit
    self.is_crimespree = managers.crime_spree and managers.crime_spree:is_active() or false -- Same as comment above
    if self.is_client then -- Safe House Nightmare, The Biker Heist Day 2, Cursed Kill Room, Escape: Garage, Escape: Cafe, Escape: Cafe (Day)
        self.heists_with_endless_assaults = { "haunted", "chew", "hvh", "escape_garage", "escape_cafe", "escape_cafe_day" }
        self.endless_client = table.contains(self.heists_with_endless_assaults, Global.game_settings.level_id)
        if self.mutators and Global.mutators.active_on_load["MutatorEndlessAssaults"] then
            self.endless_client = true
            self.dont_override_endless = true
        end
    end
    self.trigger_assault_start_event = true
end

function MUIStats:SetCompatibleHost(BAI)
    self.CompatibleHost = true
    self.BAIHost = BAI
end

function MUIStats:UpdateAssaultColor(color, assault_type)
    self:UpdateColor(color)
    if BAI:IsHostagePanelVisible(assault_type) then
        self:_show_hostages()
    else
        self:_hide_hostages()
    end
end

function MUIStats:UpdateAssaultStateColor(state, force_update)
    if state then
        if BAI:IsStateDisabled(state) then
            return
        end
        self:UpdateColor(color)
        self:UpdateAssaultText("hud_" .. state, state)
        if BAI:IsHostagePanelVisible(assault_type) then
            self:_show_hostages()
        else
            self:_hide_hostages()
        end
        if force_update and self.is_host then
            self:UpdateAssaultState(managers.groupai:state():GetAssaultState())
        end
    end
end

function MUIStats:GetAssaultTime(sender)
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

-- //
-- // Re-routes
-- //
-- Fix this mess
function HUDAssaultCorner:UpdateAssaultState(state)
    MUIStats:UpdateAssaultState(state)
end

function HUDAssaultCorner:UpdateAssaultStateOverride(state, override)
    MUIStats:UpdateAssaultStateOverride(state, override)
end

function HUDAssaultCorner:SetNormalAssaultOverride()
    MUIStats:SetNormalAssaultOverride()
end

function HUDAssaultCorner:SetEndlessClient(setter, dont_override)
    MUIStats:SetEndlessClient(setter, dont_override)
end

function HUDAssaultCorner:SetCompatibleHost(BAI)
    MUIStats:SetCompatibleHost(BAI)
end

function HUDAssaultCorner:UpdateColors()
end

function HUDManager:UpdateColors()
end

function HUDManager:UpdateAssaultColor(color, assault_type)
    MUIStats:UpdateAssaultColor(color, assault_type)
end

function HUDManager:UpdateAssaultStateColor(state, force_update)
    MUIStats:UpdateAssaultStateColor(state, force_update)
end

function HUDManager:SetCaptainBuff(buff)
end

function HUDManager:GetAssaultMode()
    return MUIStats._assault_mode
end

function HUDManager:IsNormalPoliceAssault()
    return MUIStats._assault and not MUIStats._assault_endless
end

function HUDManager:IsPoliceAssault()
    return MUIStats._assault
end

function HUDManager:IsEndlessPoliceAssault()
    return MUIStats._assault_endless
end

function HUDManager:IsWaveSurvivedShowed()
    return MUIStats.wave_survived
end

function HUDManager:GetAssaultState()
    return MUIStats.assault_state
end

function HUDManager:IsHost()
    return MUIStats.is_host
end

function HUDManager:IsClient()
    return MUIStats.is_client
end

function HUDManager:IsSkirmish()
    return MUIStats.is_skirmish
end

function HUDManager:GetTimeLeft()
    return MUIStats.client_time_left - TimerManager:game():time()
end

function HUDManager:GetAssaultTime(sender)
    MUIStats:GetAssaultTime(sender)
end

function HUDManager:GetCompatibleHost()
    return MUIStats.CompatibleHost
end

function HUDManager:GetBAIHost()
    return MUIStats.BAIHost
end

function HUDManager:SetCivilianKilled(amount)
end