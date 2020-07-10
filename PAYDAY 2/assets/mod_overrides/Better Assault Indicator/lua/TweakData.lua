function TweakData:InitBAI()
    self.bai =
    {
        time_left =
        {
            texture = "guis/dlcs/opera/textures/pd2/specialization/icons_atlas",
            texture_rect = { 0, 0, 64, 64 }
        },
        spawns_left =
        {
            texture = "guis/textures/pd2_mod_bai/spawns_left"
        },
        captain =
        {
            texture = "guis/textures/pd2/hud_buff_shield"
        }--[[,
        trade_delay =
        {
            texture = "guis/textures/pd2/hud_buff_shield"
        }]]
    }
end

tweak_data:InitBAI()