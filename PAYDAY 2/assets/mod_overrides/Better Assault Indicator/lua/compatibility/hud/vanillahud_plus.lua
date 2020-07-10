local function AddEventSilent(event, f, delay)
    BAI.Events[#BAI.Events + 1] = { event_name = event, func = f, delay = delay or 0 }
end

local BAIFunctionForced = false

function HUDAssaultCorner:QueryVHUDPlusOptions(update)
    self.vhudplus.center = VHUDPlus:getSetting({"AssaultBanner", "USE_CENTER_ASSAULT"}, true)
    self.vhudplus.hudlist_enabled = VHUDPlus and VHUDPlus:getSetting({"HUDList", "ENABLED"}, true)
    self.vhudplus.hostages_hidden = not VHUDPlus:getSetting({"HUDList", "ORIGNIAL_HOSTAGE_BOX"}, false)
    if update then

    end
end

function HUDAssaultCorner:QueryBAIOptions()
    self.vhudplus.bai.aai_visible = BAI:GetOption("show_advanced_assault_info")
    self.vhudplus.bai.aai_panel = BAI.settings.advanced_assault_info.aai_panel
    self.vhudplus.bai.captain_panel = BAI.settings.advanced_assault_info.captain_panel
end

function HUDAssaultCorner:InitVHUDOptionsOptions()
    local offset = 46
    if self.vhudplus.hudlist_enabled and self.vhudplus.hostages_hidden then
        self.vhudplus.hostages_hidden = true
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
        if self.vhudplus.center then
            if self.vhudplus.hostages_hidden or BAI:IsHostagePanelHidden("endless") then
                offset = 0
            end
        else
            if not self.vhudplus.hostages_hidden and BAI:IsHostagePanelVisible("endless") then
                offset = self._bg_box:h() + 54
            end
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.EndlessAssaultStart, Endless, delay)

    local function NoReturn(active)
        local offset = self._bg_box:h() + 8
        if self.vhudplus.center then
            offset = 0
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.NoReturn, NoReturn, delay)

    local function NormalAssaultOverride()
        local offset = self._bg_box:h() + 54
        if self.vhudplus.center then
            if self.vhudplus.hostages_hidden and self.vhudplus.bai.aai_panel == 1 then
                offset = 0
            else
                offset = 46
            end
        else
            if self.vhudplus.hostages_hidden then
                if self.vhudplus.bai.aai_panel == 1 then
                    offset = 46
                end
            else
                if self.vhudplus.bai.aai_panel == 1 and BAI:IsHostagePanelHidden("assault") then
                    offset = 46
                end
            end
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.NormalAssaultOverride, NormalAssaultOverride, delay)

    local function Update()
        self:QueryBAIOptions()
        self:QueryVHUDPlusOptions(true)
    end

    AddEventSilent(BAI.EventList.Update, Update)

    local function Assault()
        local offset = self._bg_box:h() + 54
        if self.vhudplus.center then
            if self.vhudplus.hostages_hidden then
                offset = self.vhudplus.bai.aai_panel == 1 and 0 or 46
            else
                if self.vhudplus.bai.aai_panel == 1 then
                    offset = BAI:IsHostagePanelVisible("assault") and 46 or 0
                else
                    offset = 46
                end
            end
        else
            if self.vhudplus.hostages_hidden and self.vhudplus.bai.aai_panel == 1 then
                offset = 46
            end
        end
        self:MoveHUDList(offset)
    end

    AddEventSilent(BAI.EventList.AssaultStart, Assault, delay)

    local function AssaultEnd()
        local offset = self._bg_box:h() + 54
        if self.vhudplus.center then
            if self.vhudplus.hostages_hidden then
                offset = 0
            else
                offset = BAI:GetOption("completely_hide_hostage_panel") and 0 or 46
            end
        else
            if self.vhudplus.hostages_hidden then
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
        if self.vhudplus.center then
            managers.hud._hud_heist_timer._heist_timer_panel:set_visible(false)
        end
    end

    AddEventSilent(BAI.EventList.AssaultEnd, AssaultEnd, 0.90)

    self:MoveHUDList(offset)
end

local _BAI_InitAAIPanel = HUDAssaultCorner.InitAAIPanel
function HUDAssaultCorner:InitAAIPanel()
    _BAI_InitAAIPanel(self)
    if not (self.AAIPanel and self.vhudplus.hostages_hidden) then
        return
    end

    self._hud_panel:child("time_panel"):set_x(self._hud_panel:w() - self._hud_panel:child("time_panel"):w())
    self._hud_panel:child("spawns_panel"):set_right(self._hud_panel:child("time_panel"):left() - 3)
end

function HUDAssaultCorner:UpdateHUDListOffset(banner_visible, move)
    banner_visible = banner_visible or (self._assault or self._point_of_no_return or self._casing)
    local offset = banner_visible and (self._bg_box:h() + 54) or 0
    if self.vhudplus.center then -- Not right
        if self.vhudplus.hostages_hidden then
            if self.vhudplus.bai.aai_panel == 2 then
                offset = banner_visible and 46 or 0
            else
                offset = 0
            end
        else
            offset = banner_visible and 46 or 0
        end
    else
        if self.vhudplus.hostages_hidden then
            offset = 46
        end
    end
    if self.vhudplus.center and self.vhudplus.hostages_hidden then
        offset = 0
    end
    self:MoveHUDList(offset)
end

function HUDAssaultCorner:MoveHUDList(offset)
    if self.vhudplus.hudlist_enabled and managers.hud.change_list_setting then
        managers.hud:change_list_setting("right_list_height_offset", offset)
    end
end

local _BAI_offset_hostages = HUDAssaultCorner._offset_hostages
function HUDAssaultCorner:_offset_hostages(hostage_panel, is_offseted, box_h)
    if not self.vhudplus.center then
        _BAI_offset_hostages(self, hostage_panel, is_offseted, box_h)
    end
end

local _f_set_hostage_offseted = HUDAssaultCorner._set_hostage_offseted
function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
    if self.vhudplus.center then
        if is_offseted then
            self:start_assault_callback()
        else
            local offset = self.vhudplus.hostages_hidden and 0 or (BAI.settings.completely_hide_hostage_panel and 0 or 46)
            self:MoveHUDList(offset)
        end
    else
        _f_set_hostage_offseted(self, is_offseted)
    end
end