local huds = {"holoui", "pdth_hud_reborn", "restoration_mod", "mui", "halo_reach_hud"}
local function UpdateOneItem(self, menu, item_to_update, status)
    for _, item in pairs(menu.items) do
        if item.id == item_to_update then
            self:AnimateItemEnabled(item, status)
            break
        end
    end
end

local function UpdateItems(self, menu, items_to_update, status)
    for _, item in pairs(menu.items) do
        for _, itu in pairs(items_to_update) do
            if item.id == itu then
                self:AnimateItemEnabled(item, status)
                break
            end
        end
    end
end

local function CheckHUDCompatibility(self, menu, h)
    UpdateOneItem(self, menu, "bai_show_advanced_assault_info_choice", h ~= 4)
    if h == 4 then -- MUI
        UpdateItems(self, menu, { "advanced_assault_info", "bai_hide_assault_text_choice", "bai_faction_assault_text_choice" }, false)
    else -- Different HUD
        UpdateOneItem(self, menu, "advanced_assault_info", BAI:GetOption("show_advanced_assault_info"))
        UpdateOneItem(self, menu, "bai_hide_assault_text_choice", BAI:GetOption("show_assault_states") or BAI:GetOption("show_advanced_assault_info"))
        UpdateOneItem(self, menu, "bai_faction_assault_text_choice", not BAI:GetOption("hide_assault_text"))
    end
end

local function UpdateHUDItems(self, menu_name, value)
    local menu = self:GetMenu(menu_name)
    for _, item in pairs(menu.items) do
        for _, v in pairs(huds) do
            if item.id == v then
                self:AnimateItemEnabled(item, false)
            end
        end
    end
    local h = 0
    if value == 1 then -- Autodetect
        if Holo then
            h = 1
        elseif pdth_hud then
            h = 2
        elseif restoration then
            h = 3
        elseif MUIMenu then
            h = 4
        elseif NobleHUD then
            h = 5
        end
    elseif value == 5 then -- HoloUI
        h = 1
    elseif value == 7 then -- PD:TH HUD Reborn
        h = 2
    elseif value == 8 then -- Restoration Mod
        h = 3
    elseif value == 9 then -- MUI
        h = 4
    elseif value == 11 then -- Halo: Reach HUD
        h = 5
    end
    CheckHUDCompatibility(self, menu, h)
    if BAI:IsOr(h, 0, 4) then
        return
    end
    for _, item in pairs(menu.items) do
        if item.id == huds[h] then
            self:AnimateItemEnabled(item, true)
        end
    end
end

-- Shared functions
function BAIMenu:SetNormalColor(color, panel)
    local c = BAI.settings.assault_panel[panel]
    c.r = color.red
    c.g = color.green
    c.b = color.blue
end

function BAIMenu:HideHostagePanel(value, panel)
    BAI.settings.assault_panel[panel].hide_hostage_panel = value
end

function BAIMenu:SetCustomText(value, panel, text)
    if text then
        BAI.settings.assault_panel[panel].custom_text[text] = value
    else
        BAI.settings.assault_panel[panel].custom_text = value
    end
end

function BAIMenu:SetCustomShortText(value, panel, text)
    if text then
        BAI.settings.assault_panel[panel].short_custom_text[text] = value
    else
        BAI.settings.assault_panel[panel].short_custom_text = value
    end
end

function BAIMenu:SetStateEnabled(value, panel)
    BAI.settings.assault_panel[panel].enabled = value
end

function BAIMenu:SetRestorationColor(color, panel, c)
    local clr = BAI.settings.hud.restoration_mod.assault_panel[panel][c]
    clr.r = color.red
    clr.g = color.green
    clr.b = color.blue
end

-- Main Menu
function BAIMenu:BAIMenuCreatedCallback()
    UpdateHUDItems(self, "bai_menu", BAI:GetOption("hud_compatibility"))
end

function BAIMenu:callback_bai_mod_language(value)
    BAI.settings.mod_language = value
end

function BAIMenu:callback_bai_compatibility(value)
    BAI.settings.hud_compatibility = value
    UpdateHUDItems(self, "bai_menu", value)
end

function BAIMenu:callback_bai_show_wave_survived(value)
    BAI.settings.show_wave_survived = value
end

function BAIMenu:callback_bai_completely_hide_hostage_panel(value)
    BAI.settings.completely_hide_hostage_panel = value
end

function BAIMenu:fcc_bai_show_difficulty_name_instead_of_skulls(focus)
    if focus then
        local h = select(4, self._tooltip:text_rect())
        self._tooltip_bottom_enabled:set_top(h + 18)
        local hh = select(4, self._tooltip_bottom_enabled:text_rect())
        self._menu_difficulty_name_enabled:set_top(hh + 63)
        self._tooltip_bottom_disabled:set_top(self._menu_difficulty_name_enabled:bottom() + 10)
        local hhh = select(4, self._tooltip_bottom_disabled:text_rect())
        self._menu_difficulty_name_disabled:set_top(self._tooltip_bottom_disabled:top() - self._tooltip:top() + hhh + 18)
    end
    self._menu_difficulty_name_enabled:set_visible(focus)
    self._tooltip_bottom_enabled:set_visible(focus)
    self._menu_difficulty_name_disabled:set_visible(focus)
    self._tooltip_bottom_disabled:set_visible(focus)
end

function BAIMenu:callback_bai_show_difficulty_name_instead_of_skulls(value)
    BAI.settings.show_difficulty_name_instead_of_skulls = value
end

function BAIMenu:callback_bai_show_assault_states(value)
    BAI.settings.show_assault_states = value
end

function BAIMenu:callback_bai_hide_assault_text(value)
    BAI.settings.hide_assault_text = value
    UpdateOneItem(self, self:GetMenu("bai_menu"), "bai_faction_assault_text_choice", not value)
end

function BAIMenu:callback_bai_show_advanced_assault_info(value)
    BAI.settings.show_advanced_assault_info = value
end

function BAIMenu:callback_bai_faction_assault_text(value)
    BAI.settings.faction_assault_text = value
end

function BAIMenu:callback_HideAssaultTextEnabled()
    UpdateOneItem(self, self:GetMenu("bai_menu"), "bai_hide_assault_text_choice", BAI:GetOption("show_assault_states") or BAI:GetOption("show_advanced_assault_info"))
end

-- Advanced Assault Info
function BAIMenu:BAIAAIMenuCreatedCallback()
    UpdateOneItem(self, self:GetMenu("bai_advanced_assault_info_menu"), "bai_aai_panel_update_rate_choice", BAI.settings.advanced_assault_info.aai_panel == 2)
end

function BAIMenu:callback_bai_show_time_left(value)
    BAI.settings.advanced_assault_info.show_time_left = value
end

function BAIMenu:fcc_bai_time_format(focus)
    if focus then
        self._tooltip:set_text(self._tooltip:text() ..
        "\n[" .. managers.localization:text("bai_time_format_1") .. " - 88.64]" ..
        "\n[" .. managers.localization:text("bai_time_format_2") .. " - 88.64 " .. managers.localization:text("hud_s") .. "]" ..
        "\n[" .. managers.localization:text("bai_time_format_3") .. " - 88]" ..
        "\n[" .. managers.localization:text("bai_time_format_4") .. " - 88 " .. managers.localization:text("hud_s") .. "]" ..
        "\n[" .. managers.localization:text("bai_time_format_5") .. " - 1 " .. managers.localization:text("hud_min") .. " 28 " .. managers.localization:text("hud_s") .. "]" ..
        "\n[" .. managers.localization:text("bai_time_format_6") .. " - 01:28]")
    end
end

function BAIMenu:callback_bai_time_format(value)
    BAI.settings.advanced_assault_info.time_format = value
end

function BAIMenu:callback_bai_show_spawns_left(value)
    BAI.settings.advanced_assault_info.show_spawns_left = value
end

function BAIMenu:fcc_bai_aai_panel(focus)
    if focus then
        self._tooltip:set_text(self._tooltip:text() ..
        "\n\n" .. managers.localization:text("bai_compatible_huds", {VALUE = managers.localization:text("bai_aai_panel_2")}) ..
        managers.localization:text("bai_compatibility_2") .. "\n" ..
        managers.localization:text("bai_compatibility_3") .. "\n" ..
        managers.localization:text("bai_compatibility_5") .. "\n" ..
        managers.localization:text("bai_compatibility_6") .. "\n" ..
        managers.localization:text("bai_compatibility_8") .. " - " .. managers.localization:text("bai_restoration_mod_alpha_tape_only") .. "\n" ..
        managers.localization:text("bai_compatibility_10") .. "\n\n" ..
        managers.localization:text("bai_incompatible_huds", {VALUE = managers.localization:text("bai_aai_panel_1")}) .. 
        managers.localization:text("bai_compatibility_12") .. "\n\n" ..
        managers.localization:text("bai_default_option", {VALUE = managers.localization:text("bai_aai_panel_1")}) .. "\n\n" ..
        managers.localization:text("bai_aai_panel_1") .. ":")
        local h = select(4, self._tooltip:text_rect())
        self._menu_aai_panel_1:set_top(h + 18)
        self._tooltip_bottom_disabled:set_text(managers.localization:text("bai_aai_panel_2") .. ":")
        self._tooltip_bottom_disabled:set_top(self._menu_aai_panel_1:bottom() + 10)
        local hhh = select(4, self._tooltip_bottom_disabled:text_rect())
        self._menu_aai_panel_2:set_top(self._tooltip_bottom_disabled:top() - self._tooltip:top() + hhh + 18)
    else
        self._tooltip_bottom_disabled:set_text(managers.localization:text("bai_disabled"))
    end
    self._menu_aai_panel_1:set_visible(focus)
    self._menu_aai_panel_2:set_visible(focus)
    self._tooltip_bottom_disabled:set_visible(focus)
end

function BAIMenu:callback_bai_aai_panel(value)
    BAI.settings.advanced_assault_info.aai_panel = value
    UpdateOneItem(self, self:GetMenu("bai_advanced_assault_info_menu"), "bai_aai_panel_update_rate_choice", value == 2)
end

function BAIMenu:fcc_bai_aai_panel_update_rate(focus)
    if focus then
        self._tooltip:set_text(self._tooltip:text() ..
        "\n\n" .. managers.localization:text("bai_compatible_huds_option") ..
        managers.localization:text("bai_compatibility_2") .. "\n" ..
        managers.localization:text("bai_compatibility_3") .. "\n" ..
        managers.localization:text("bai_compatibility_5") .. "\n" ..
        managers.localization:text("bai_compatibility_6") .. "\n" ..
        managers.localization:text("bai_compatibility_8") .. " - " .. managers.localization:text("bai_restoration_mod_alpha_tape_only") .. "\n" ..
        managers.localization:text("bai_compatibility_10") .. "\n" ..
        managers.localization:text("bai_compatibility_12") .. "\n\n" ..
        managers.localization:text("bai_default_option", {VALUE = "0.10"}))
    end
end

function BAIMenu:callback_bai_aai_panel_update_rate(value)
    BAI.settings.advanced_assault_info.aai_panel_update_rate = value
end

function BAIMenu:callback_bai_show_trade_delay_panel(value)
    BAI.settings.advanced_assault_info.trade_delay_panel = value
end

function BAIMenu:callback_bai_show_trade_delay_panel_when(value)
    BAI.settings.advanced_assault_info.trade_delay_panel_when = value
end

function BAIMenu:callback_bai_trade_delay_panel_position(value)
    BAI.settings.advanced_assault_info.trade_delay_panel_position = value
end

function BAIMenu:fcc_bai_show_captain_panel(focus)
    if focus then
        self._tooltip:set_text(self._tooltip:text() ..
        "\n\n" .. managers.localization:text("bai_compatible_huds_option") ..
        managers.localization:text("bai_compatibility_2") .. "\n" ..
        managers.localization:text("bai_compatibility_3") .. "\n" ..
        managers.localization:text("bai_compatibility_5") .. "\n" ..
        managers.localization:text("bai_compatibility_6") .. "\n" ..
        managers.localization:text("bai_compatibility_8") .. " - " .. managers.localization:text("bai_restoration_mod_alpha_tape_only") .. "\n" ..
        managers.localization:text("bai_compatibility_10") .. "\n" ..
        managers.localization:text("bai_compatibility_12") .. "\n\n" ..
        managers.localization:text("bai_default_option", {VALUE = managers.localization:text("bai_disabled"):gsub(":", "")}) .. "\n\n" ..
        managers.localization:text("bai_enabled") .. ":")
        local h = select(4, self._tooltip:text_rect())
        self._menu_captain_panel_enabled:set_top(h + 18)
        self._tooltip_bottom_disabled:set_top(self._menu_captain_panel_enabled:bottom() + 10)
        local hhh = select(4, self._tooltip_bottom_disabled:text_rect())
        self._menu_captain_panel_disabled:set_top(self._tooltip_bottom_disabled:top() - self._tooltip:top() + hhh + 18)
    end
    self._menu_captain_panel_enabled:set_visible(focus)
    self._menu_captain_panel_disabled:set_visible(focus)
    self._tooltip_bottom_disabled:set_visible(focus)
end

function BAIMenu:callback_bai_spawn_numbers(value)
    BAI.settings.advanced_assault_info.spawn_numbers = value
end

function BAIMenu:callback_bai_show_captain_panel(value)
    BAI.settings.advanced_assault_info.captain_panel = value
end

-- Animations
function BAIMenu:callback_bai_enable_animations(value)
    BAI.settings.animation.enable_animations = value
end

function BAIMenu:callback_bai_animate_color_change(value)
    BAI.settings.animation.animate_color_change = value
end

function BAIMenu:callback_bai_animate_hostage_panel(value)
    BAI.settings.animation.animate_hostage_panel = value
end

-- HoloUI
function BAIMenu:callback_bai_holoui_update_text_color(value)
    BAI.settings.hud.holoui.update_text_color = value
end

-- PD:TH HUD Reborn
function BAIMenu:callback_bai_pdth_hud_reborn_custom_text_color(value)
    BAI.settings.hud.pdth_hud_reborn.custom_text_color = value
end

function BAIMenu:callback_bai_pdth_hud_reborn_text_box(clr)
    local c = BAI.settings.hud.pdth_hud_reborn.color
    c.r = clr.red
    c.g = clr.green
    c.b = clr.blue
end

-- Restoration Mod
function BAIMenu:callback_bai_restoration_mod_use_alpha_assault_text(value)
    BAI.settings.hud.restoration_mod.use_alpha_assault_text = value
end

function BAIMenu:callback_bai_restoration_mod_use_alpha_endless_text(value)
    BAI.settings.hud.restoration_mod.use_alpha_endless_text = value
end

function BAIMenu:callback_bai_restoration_mod_include_cover_text(value)
    BAI.settings.hud.restoration_mod.include_cover_text = value
end

-- Halo: Reach HUD
function BAIMenu:callback_bai_halo_reach_hud_use_bai_color(value)
    BAI.settings.hud.halo_reach_hud.use_bai_color = value
end