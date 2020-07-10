--[[Basic hook made by MiamiCenter, and changed by Offyerrocker to get it working.]]

local orig_get_dlc_stuff = ContractBrokerHeistItem.get_dlc_name_and_color

function ContractBrokerHeistItem:get_dlc_name_and_color(job_tweak,...)
    local dlc_name = ""
    local dlc_color = Color(1, 0, 1)
	local cheat_installed = false
    local checked_mods = {
        ["Silent Assassin"] = true, ["Pirate Perfection"] = true, ["Carry Stacker Reloaded"] = true, ["DLC Unlocker"] = true, ["Carry Stacker"] = true
    }

    local installed_mods = BLT.Mods.mods
    for _,mod in pairs(installed_mods) do 
        local id = mod:GetId()
        if checked_mods[id] then
			cheat_installed = true
        end
    end
    if job_tweak.dlc then
        if job_tweak.dlc == "custom_heist" then
            if SystemInfo:distribution() == Idstring("STEAM") and cheat_installed == false then
				dlc_color = Color("00FF00")
                dlc_name = managers.localization:to_upper_text("cn_menu_custom_heist")
			elseif SystemInfo:distribution() == Idstring("STEAM") and cheat_installed == true then
				dlc_color = Color("FF4000")
				dlc_name = managers.localization:to_upper_text("cn_menu_uninstall_cheats")
            end
			return dlc_name, dlc_color
        end
    end
    return orig_get_dlc_stuff(self,job_tweak,...)
end
