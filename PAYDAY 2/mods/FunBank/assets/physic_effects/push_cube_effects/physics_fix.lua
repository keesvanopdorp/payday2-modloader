--Basic Hook by MiamiCenter, but changed by Offyerrocker to get it working.
Hooks:PostHook(WINDLCManager, "init", "fbs_dlcmanager", function (self, ...)
        table.insert(Global.dlc_manager.all_dlc_data,custom_heist_free = {
            source_id = "103582791433980119"
        }
    )
end)