local function AddEventSilent(event, f, delay)
    BAI.Events[#BAI.Events + 1] = { event_name = event, func = f, delay = delay or 0 }
end

local BAIFunctionForced = false

local _w_change_assaultbanner_setting = HUDManager.change_assaultbanner_setting
function HUDManager:change_assaultbanner_setting(setting, value)
    _w_change_assaultbanner_setting(self, setting, value)
    if self._hud_assault_corner then
        self._hud_assault_corner:QueryWolfHUDOptions()
    end
end

function HUDAssaultCorner:QueryWolfHUDOptions(update)
    self.wolfhud.position = WolfHUD:getSetting({"AssaultBanner", "POSITION"}, 3)
    self.wolfhud.hudlist_enabled = WolfHUD:getSetting({"HUDList", "ENABLED"}, true)
    self.wolfhud.hudlist_show_hostages = WolfHUD:getSetting({"HUDList", "RIGHT_LIST", "show_hostages"}, true)
    if update then

    end
end

function HUDAssaultCorner:QueryBAIOptions()
    self.wolfhud.bai.aai_visible = BAI:GetOption("show_advanced_assault_info")
    self.wolfhud.bai.aai_panel = BAI.settings.advanced_assault_info.aai_panel
    self.wolfhud.bai.captain_panel = BAI.settings.advanced_assault_info.captain_panel
end

function HUDAssaultCorner:InitWolfHUDOptions()
    local offset = 46
    if self.wolfhud.hudlist_enabled and self.wolfhud.hudlist_show_hostages then
        self.wolfhud.hostages_hidden = true
        if not BAI.settings.completely_hide_hostage_panel then
            BAI.settings.completely_hide_hostage_panel = true
            BAIFunctionForced = true
        end
        self._hud_panel:child("hostages_panel"):set_visible(false)
        self._hud_panel:child("hostages_panel"):set_alpha(0)
        offset = 0
    end

    local delay = 0.75

    local function Endless()
        local offset = self._bg_box:h() + 8
        if self.wolfhud.position ~= 3 and self.wolfhud.hostages_hidden then
            offset = 0
        else
            if not self.wolfhud.hostages_hidden and BAI:IsHostagePanelVisible("endless") then
                offset = self._bg_box:h() + 54
            end
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.EndlessAssaultStart, Endless, delay)

    local function NoReturn(active)
        local offset = self._bg_box:h() + 8
        if self.wolfhud.position ~= 3 then
            offset = 0
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.NoReturn, NoReturn, delay)

    local function NormalAssaultOverride()
        local offset = self._bg_box:h() + 54
        if self.wolfhud.position ~= 3 then
            if self.wolfhud.hostages_hidden and self.wolfhud.bai.aai_panel == 1 then
                offset = 0
            else
                offset = 46
            end
        else
            if self.wolfhud.hostages_hidden then
                if self.wolfhud.bai.aai_panel == 1 then
                    offset = 46
                end
            else
                if self.wolfhud.bai.aai_panel == 1 and BAI:IsHostagePanelHidden("assault") then
                    offset = 46
                end
            end
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.NormalAssaultOverride, NormalAssaultOverride, delay)

    local function Update()
        self:QueryBAIOptions()
        self:QueryWolfHUDOptions(true)
    end

    AddEventSilent(BAI.EventList.Update, Update)

    local function Assault()
        local offset = self._bg_box:h() + 54
        if self.wolfhud.position ~= 3 then
            if self.wolfhud.hostages_hidden then
                offset = self.wolfhud.bai.aai_panel == 1 and 0 or 46
            else
                if self.wolfhud.bai.aai_panel == 1 then
                    offset = BAI:IsHostagePanelVisible("assault") and 46 or 0
                else
                    offset = 46
                end
            end
        else
            if self.wolfhud.hostages_hidden and self.wolfhud.bai.aai_panel == 1 then
                offset = 46
            end
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.AssaultStart, Assault, delay)

    local function AssaultEnd()
        local offset = self._bg_box:h() + 54
        if self.wolfhud.position ~= 3 then
            if self.wolfhud.hostages_hidden then
                offset = 0
            else
                offset = BAI:GetOption("completely_hide_hostage_panel") and 0 or 46
            end
        else
            if self.wolfhud.hostages_hidden then
                if BAI:GetOption("show_assault_states") then
                    offset = BAI:IsStateEnabled("control") and 46 or 0
                end
            else
                if BAI:GetOption("show_assault_states") and BAI:IsStateDisabled("control") then
                    offset = 46
                end
            end
            --[[if BAI:GetOption("completely_hide_hostage_panel") then
                if BAI:GetOption("show_wave_survived") then
                end
                if BAI:GetOption("show_assault_states") then
                    if BAI:IsStateEnabled("control") then
                        offset = 46
                    end
                else
                end
            end
            if BAI:GetOption("show_assault_states") then
                offset = 46
            else
                offset = BAI:GetOption("completely_hide_hostage_panel") and 0 or 46
            end]]
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.AssaultEnd, AssaultEnd, 0.90)

    self:MoveHUDList(offset)
end

local _BAI_InitAAIPanel = HUDAssaultCorner.InitAAIPanel
function HUDAssaultCorner:InitAAIPanel()
    _BAI_InitAAIPanel(self)
    if not self.AAIPanel or not self.wolfhud.hostages_hidden then
        return
    end

    self._hud_panel:child("time_panel"):set_x(self._hud_panel:w() - self._hud_panel:child("time_panel"):w())
    self._hud_panel:child("spawns_panel"):set_right(self._hud_panel:child("time_panel"):left() - 3)
end

local _w_update_hudlist_offset = HUDAssaultCorner.update_hudlist_offset
function HUDAssaultCorner:update_hudlist_offset(banner_visible, move)
    _w_update_hudlist_offset(self, banner_visible)
    banner_visible = banner_visible or (self._assault or self._point_of_no_return or self._casing)
    if not move and self.wolfhud.position ~= 3 then
        banner_visible = false
    end
    local offset = banner_visible and (self._bg_box:h() + 54) or 0
    if self.wolfhud.position ~= 3 then -- Not right
        if self.wolfhud.hostages_hidden then
            if self.wolfhud.bai.aai_panel == 2 then
                offset = banner_visible and 46 or 0
            else
                offset = 0
            end
        else
            offset = banner_visible and 46 or 0
        end
    end
    self:MoveHUDList(offset)
end

function HUDAssaultCorner:MoveHUDList(offset)
    if self.wolfhud.hudlist_enabled and managers.hud.change_list_setting then
        managers.hud:change_list_setting("right_list_height_offset", offset)
    end
end

local _BAI_offset_hostages = HUDAssaultCorner._offset_hostages
function HUDAssaultCorner:_offset_hostages(hostage_panel, is_offseted, box_h)
    if self.wolfhud.position == 3 then
        _BAI_offset_hostages(self, hostage_panel, is_offseted, box_h)
    end
end

local _f_set_hostage_offseted = HUDAssaultCorner._set_hostage_offseted
function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    if self.wolfhud.position < 3 then
        if is_offseted then
            self:start_assault_callback()
        else
            local offset = self.wolfhud.hostages_hidden and 0 or (BAI.settings.completely_hide_hostage_panel and 0 or 46)
            self:MoveHUDList(offset)
        end
    else
        _f_set_hostage_offseted(self, is_offseted)
    end
end