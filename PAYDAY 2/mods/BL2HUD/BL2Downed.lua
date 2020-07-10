BL2Downed = BL2Downed or class()

function BL2Downed:init(hud)
	self._hud = hud
	self._hud_panel = hud.panel
	local extra_atlas = "guis/textures/BL2HUD/extra_atlas"
	if self._hud_panel:child("downed_panel") then
		self._hud_panel:remove(self._hud_panel:child("downed_panel"))
	end
	self._current_time = 0
	self._max_time = 0
	local scale = BL2Options._data.player_scale
	
	local downed_panel = self._hud_panel:panel({
		name = "downed_panel",
		w = 408*scale,
		h = 100*scale,
		x = self._hud_panel:center_x() - 204*scale,
		y = self._hud_panel:bottom()-200*scale,
	})
	
	local downed_bg = downed_panel:bitmap({
		name = "downed_bg",
		texture = extra_atlas,
		texture_rect = {1,285,408,78},
		layer = 1,
		w = 408*scale,
		h = 78*scale,
		y = 10*scale,
	})
	local downed_f = downed_panel:bitmap({
		name = "downed_f",
		texture = extra_atlas,
		texture_rect = {75,373,435,67},
		x = 75*scale,
		y = 25*scale,
		layer = 2,
		h = 49*scale,
		w = 313*scale,
	})
	local downed_icon = downed_panel:bitmap({
		name = "downed_icon",
		texture = extra_atlas,
		texture_rect = {6,373,66,74},
		layer = 3,
		h = 55*scale,
		w = 50*scale,
	})
	local downed_icon_r = downed_panel:bitmap({
		name = "downed_icon_r",
		texture = extra_atlas,
		texture_rect = {429,198,64,64},
		w = 50*scale,
		h = 50*scale,
		visible = false,
		layer = 3,
	})
	
	local timer_msg = downed_panel:text({
		name = "timer_msg",
		text = "test",
		color = Color(255,244, 178, 183)/255,
		font = "fonts/font_large_mf",
		align = "right",
		font_size = 22*scale,
		layer = 5,
		x = -40*scale,
		y = downed_f:h()+12*scale,
	})
	local downed_status = downed_panel:text({
		name = "downed_status",
		text = "status",
		align = "left",
		color = Color.white,
		font = "fonts/font_medium_noshadow",
		font_size = 35*scale,
		layer = 5,
		x = 100*scale,
		y = 15*scale,
	})
	self._hud.timer:set_visible(false)
	self._hud.arrest_finished_text:set_font(Idstring(tweak_data.hud.medium_font_noshadow))
	self._hud.arrest_finished_text:set_font_size(tweak_data.hud_mask_off.text_size)
	self:set_arrest_finished_text()
	local _, _, w, h = self._hud.arrest_finished_text:text_rect()
	self._hud.arrest_finished_text:set_h(h)
	self._hud.arrest_finished_text:set_y(28*scale)
	self._hud.arrest_finished_text:set_center_x(self._hud_panel:center_x())
	self._timer_text = nil
	self._status = nil
end

function BL2Downed:on_downed()
	local downed_panel = self._hud_panel:child("downed_panel")
	local status = downed_panel:child("downed_status")
	self._status = "DOWNED!"
	status:set_text(" "..self._status)
	self._timer_text = utf8.to_upper(managers.localization:text("hud_custody_in"))
	downed_panel:stop()
	downed_panel:animate(callback(self,self,"bar"),30,30)
end
function BL2Downed:on_arrested()
	local downed_panel = self._hud_panel:child("downed_panel")
	local status = downed_panel:child("downed_status")
	self._status = "CUFFED!"
	status:set_text(" "..self._status)
	self._timer_text = utf8.to_upper(managers.localization:text("hud_uncuffed_in"))
	downed_panel:stop()
	downed_panel:animate(callback(self,self,"bar"),60,60)
end

function BL2Downed:bar(panel,time,max)
	local scale = BL2Options._data.player_scale
	local downed_panel = self._hud_panel:child("downed_panel")
	local bar = downed_panel:child("downed_f")
	local icon = downed_panel:child("downed_icon")
	local bar_bg = downed_panel:child("downed_bg")
	local timer_msg = downed_panel:child("timer_msg")
	local x1 = bar_bg:left()+58*scale
	local y1 = bar_bg:h()/2+10*scale
	local T = time
	self._max_time = max
	local R = self._max_time
	bar:set_color(Color(1,1,1,1))
	local r = T/R
	local t = T
	while t > 0 do
		local dt = coroutine.yield()
		local f = 0.4 + math.abs(0.6*math.sin(360*t))
		t = t - dt
		r = t/R
		self._current_time = t
		bar:set_w(math.clamp(313*r,0,313)*scale)
		bar:set_texture_rect(75,373,math.clamp(435*r,0,435),67)
		icon:set_color(Color(1,f,f))
		icon:set_size(math.clamp(math.abs(85+5*math.sin(540*t))*0.89,80*0.89,90*0.89)*scale,math.clamp(math.abs(85+5*math.sin(540*t)),80,90)*scale)
		icon:set_center(x1,y1)
		timer_msg:set_text(self._timer_text .." "..tonumber(self._hud.timer:text()).." ")
	end
	
end

function BL2Downed:flash(panel)
	local scale = BL2Options._data.player_scale
	local downed_panel = self._hud_panel:child("downed_panel")
	local icon_r = downed_panel:child("downed_icon_r")
	local bar_bg = downed_panel:child("downed_bg")
	local t = 0
	local x1 = bar_bg:left()+58*scale
	local y1 = bar_bg:h()/2+10*scale
	while icon_r:visible() do
		local dt = coroutine.yield()
		local f = 0.4 + math.abs(0.6*math.sin(360*t))
		t = t - dt
		icon_r:set_color(Color(f,1,f))
		icon_r:set_size(math.clamp(math.abs(65+5*math.sin(540*t)),60,70)*scale,math.clamp(math.abs(65+5*math.sin(540*t)),60,70)*scale)
		icon_r:set_center(x1,y1)
	end
end

function BL2Downed:show_timer()
	local downed_panel = self._hud_panel:child("downed_panel")
	downed_panel:stop()
	downed_panel:animate(callback(self,self,"bar"),self._current_time,self._max_time)
	local bar = downed_panel:child("downed_f")
	local timer_msg = downed_panel:child("timer_msg")
	local icon = downed_panel:child("downed_icon")
	local icon_r = downed_panel:child("downed_icon_r")
	local downed_status = downed_panel:child("downed_status")
	downed_status:set_text(" "..self._status)
	timer_msg:set_visible(true)
	icon_r:set_visible(false)
	icon:set_visible(true)
	bar:set_alpha(1)
end

function BL2Downed:hide_timer()
	local downed_panel = self._hud_panel:child("downed_panel")
	local bar = downed_panel:child("downed_f")
	local bar_bg = downed_panel:child("downed_bg")
	local icon = downed_panel:child("downed_icon")
	local icon_r = downed_panel:child("downed_icon_r")
	local timer_msg = downed_panel:child("timer_msg")
	local downed_status = downed_panel:child("downed_status")
	local w = self._current_time / self._max_time
	local is_downed = self._status == "DOWNED!"
	downed_panel:stop()
	icon_r:set_visible(true)
	icon:set_visible(false)
	timer_msg:set_visible(false)
	bar:set_texture_rect(75,446,math.clamp(435*w,0,435),67)
	bar:set_color(Color(255,57, 186, 0)/255)
	bar:set_alpha(0.7)
		if is_downed then
			downed_status:set_text(" ".."YOU ARE BEING REVIVED!")
			else
			downed_status:set_text(" ".."YOU ARE BEING UNCUFFED!")
		end
	downed_panel:animate(callback(self,self,"flash"))
end

function BL2Downed:set_arrest_finished_text()
	self._hud.arrest_finished_text:set_text(utf8.to_upper(managers.localization:text("hud_instruct_finish_arrest", {
		BTN_INTERACT = managers.localization:btn_macro("interact")
	})))
end
function BL2Downed:show_arrest_finished()
	self._hud.arrest_finished_text:set_visible(true)
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")
	timer_msg:set_visible(false)
	self._hud.timer:set_visible(false)
end
function BL2Downed:hide_arrest_finished()
	self._hud.arrest_finished_text:set_visible(false)
end
