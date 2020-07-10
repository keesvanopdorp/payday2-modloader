local function AddEventSilent(event, f, delay)
    BAI.Events[#BAI.Events + 1] = { event_name = event, func = f, delay = delay or 0 }
end

local _BAI_close_assault_box = HUDAssaultCorner._close_assault_box
function HUDAssaultCorner:_close_assault_box()
    _BAI_close_assault_box(self)
    if not (BAI.settings.show_assault_states or BAI.settings.show_wave_survived) or not self.CompatibleHost then
        self:HUDTimer(true)
    end
end

local _BAI_UpdatePONRBox = HUDAssaultCorner.UpdatePONRBox
function HUDAssaultCorner:UpdatePONRBox()
    _BAI_UpdatePONRBox(self)
    if self.center_assault_banner then
        self._hud_panel:child("point_of_no_return_panel"):set_right(self._hud_panel:w() / 2 + 150)
        self._hud_panel:child("point_of_no_return_panel"):child("icon_noreturnbox"):set_visible(false)
    end
end

if SydneyHUD:GetOption("center_assault_banner") then
    local _f_show_casing = HUDAssaultCorner.show_casing
    function HUDAssaultCorner:show_casing(mode)
        self._casing = true
        _f_show_casing(self, mode)
    end

    function HUDAssaultCorner:_set_hostage_offseted(is_offseted)
        if self._casing or not is_offseted then
            return
        end
        self:start_assault_callback()
    end

    function HUDAssaultCorner:_set_hostages_offseted(is_offseted)
    end
end

function HUDAssaultCorner:InitBAI()
    self.hudlist_enabled = SydneyHUD:GetOption("hudlist_enabled")
    local offset = self.center_assault_banner and 46 or self._bg_box:h() + 54
    if BAI:GetOption("completely_hide_hostage_panel") then
        offset = self.center_assault_banner and 0 or self._bg_box:h() + 8
    end

    local delay = 0.75

    local function AssaultStart()
        local offset = self._bg_box:h() + 54
        if self.center_assault_banner then
            if BAI.settings.advanced_assault_info.aai_panel == 2 then
                offset = 46
            else
                if BAI:GetOption("completely_hide_hostage_panel") or BAI:IsHostagePanelHidden("assault") then
                    offset = 0
                end
            end
        end

        self:SetHUDListOffset(offset)
    end

    AddEventSilent(BAI.EventList.AssaultStart, AssaultStart, delay)

    local function EndlessAssaultStart()
        local offset = self._bg_box:h() + 8
        if self.center_assault_banner then
            if BAI:GetOption("completely_hide_hostage_panel") or BAI:IsHostagePanelHidden("endless") then
                offset = 0
            end
        end

        self:SetHUDListOffset(offset)
    end

    AddEventSilent(BAI.EventList.EndlessAssaultStart, EndlessAssaultStart, delay)

    local function NormalAssaultOverride()
        local offset = self._bg_box:h() + 54
        if self.center_assault_banner then
            if BAI:GetOption("completely_hide_hostage_panel") or BAI:IsHostagePanelHidden("assault") then
                offset = BAI.settings.advanced_assault_info.aai_panel == 2 and 46 or 0
            else
                offset = 46
            end
        else
            if BAI:GetOption("completely_hide_hostage_panel") or BAI:IsHostagePanelHidden("assault") then
                if BAI.settings.advanced_assault_info.aai_panel == 1 then
                    offset = self._bg_box:h() + 8
                end
            else
                offset = 46
            end
        end

        self:SetHUDListOffset(offset)
    end

    AddEventSilent(BAI.EventList.NormalAssaultOverride, NormalAssaultOverride, delay)

    local function Captain(active)
        local offset = self._bg_box:h() + 54
        if active then -- Captain panel is visible
            if self.center_assault_banner then
                offset = BAI:IsHostagePanelHidden("captain") and 0 or 46
            else
                offset = self._bg_box:h() + (BAI:IsHostagePanelHidden("captain") and 8 or 54)
            end
        else
            local condition = BAI:IsHostagePanelVisible("assault") or BAI.settings.advanced_assault_info.aai_panel == 2
            if self.center_assault_banner then
                offset = condition and 46 or 0
            else
                offset = self._bg_box:h() + (condition and 54 or 8)
            end
        end

        self:SetHUDListOffset(offset)
    end

    AddEventSilent(BAI.EventList.Captain, Captain, delay)

    local function AssaultEnd()
        local offset = self._bg_box:h() + 54
        if self.center_assault_banner then
            if BAI:IsHostagePanelVisible() then
                offset = 46
            end
        else
            if BAI:IsHostagePanelHidden() then
                offset = self._bg_box:h() + 8
            end
        end

        self:SetHUDListOffset(offset)
    end

    AddEventSilent(BAI.EventList.AssaultEnd, AssaultEnd, 0.90)

    self:SetHUDListOffset(offset)
end

function HUDAssaultCorner:SetHUDListOffset(offset)
    if managers.hudlist and self.hudlist_enabled then
        --log("[BAI] Changed HUDList's Right List Offset to: " .. (offset or -1))
        managers.hudlist:change_setting("right_list_y", offset)
    end
end