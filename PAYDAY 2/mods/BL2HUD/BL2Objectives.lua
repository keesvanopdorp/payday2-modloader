--TODO Rewrite this to be bit cleaner...
BLObjectives = BLObjectives or class()
function BLObjectives:init(hud)
	self._hud_panel = hud.panel 
		if self._hud_panel:child("objectives_panel") then
			self._hud.panel:remove(self._hud_panel:child("objectives_panel"))
		end
	local icon_atlas = "guis/textures/BL2HUD/icon_atlas"
	local objectives_panel = self._hud_panel:panel({
		visible = false,
		name = "objectives_panel",
		h = 100,
		w = 500,
		y = 150,
	})
	objectives_panel:set_right(self._hud_panel:right())
	local heist_panel = self._hud_panel:panel({
		name = "heist_panel",
		h = 50,
		w = 300,
		y = 150,
	})
	heist_panel:set_right(self._hud_panel:right())
	local lname = managers.job:current_level_data()
	local cname = managers.localization:text(lname.name_id)
	local hname = heist_panel:text({
			name = "hname",
			font = "fonts/font_large_mf",
			color = Color(255,128, 209, 221)/255,
			layer = 2,
			font_size = 22,
			text = cname .. " ",
			align = "right",
	})
	local _,_,w,_ = hname:text_rect()
	local timer_text = heist_panel:text({
		name = "timer_text",
		text = "",
		font_size = 19,
		font = "fonts/font_large_mf",
		color = Color.white,
		align = "left",
		layer = 2,
		wrap = false,
		word_wrap = false,
		y = 18,
		x = heist_panel:w()-w-5,
	})
	local obj_i = objectives_panel:bitmap({
		name = "obj_i",
		texture = icon_atlas,
		texture_rect = {140,96,20,20},
		x = objectives_panel:w()-20,
		visible = false,
		layer = 2,
		y = 34,
		h = 16,
		w = 16,
	})
	local obj_d = self._hud_panel:bitmap({
		name = "obj_d",
		texture = icon_atlas,
		texture_rect = {96,96,20,20},
		layer = 3,
		h = 16,
		w = 16,
		visible = false,
		x = objectives_panel:right()-20,
		y = self._hud_panel:center_y(),
	})
	
	local obj_f = objectives_panel:bitmap({
		name = "obj_f",
		texture = icon_atlas,
		texture_rect = {56,96,20,20},
		layer = 3, 
		visible = false,
		x = objectives_panel:w()-20,
		y = 34,
		h = 16,
		w = 16,
	})
	
	local obj_text = objectives_panel:text({
		name = "obj_text",
		text = "",
		align = "right",
		font = "fonts/font_large_mf",
		font_size = 20,
		color = Color.white,
		layer = 2,
		x = -21,
		y = 32,
	})

	local obj_am = objectives_panel:text({
		name = "obj_am",
		text = "",
		align = "right",
		font = "fonts/font_large_mf",
		layer = 2,
		font_size = 20,
		color = Color.white,
		x = obj_text:x(),
		y = 33,
	})
	local d_obj = self._hud_panel:panel({
		visible = false,
		name = "d_obj",
		h = 100,
		w = 500,
		y = 150,
	})
	d_obj:set_right(self._hud_panel:right())
	local d_obj_text = d_obj:text({
		name = "d_obj_text",
		text = "",
		align = "right",
		font = "fonts/font_large_mf",
		font_size = 20,
		color = Color.white,
		layer = 2,
		x = -21,
		y = 32,
	})
	local d_obj_f = d_obj:bitmap({
		name = "d_obj_f",
		texture = icon_atlas,
		texture_rect = {56,96,20,20},
		layer = 4,
		color = Color(255,254, 209, 48)/255,
		visible = false,
		x = d_obj:w()-20,
		y = 34,
		h = 16,
		w = 16,
	})
	local d_obj_am = d_obj:text({
		name = "d_obj_am",
		text = "",
		align = "right",
		font = "fonts/font_large_mf",
		layer = 2,
		font_size = 20,
		color = Color.white,
		x = d_obj_text:x(),
		y = 33,
	})
	local d_obj_bx = d_obj:bitmap({   
		name = "d_obj_bx",
		texture = icon_atlas,
		texture_rect = {96,96,20,20},
		layer = 3,
		h = 16,
		w = 16,
		visible = false,
		x = d_obj:w()-20,
		y = 34,
	})
	local d_obj_i = d_obj:bitmap({
		name = "d_obj_i",
		texture = icon_atlas,
		texture_rect = {140,96,20,20},
		x = d_obj:w()-20,
		visible = false,
		layer = 2,
		y = 34,
		h = 16,
		w = 16,
	})	
	
	
	
	self._last_time = 0
	self._text = ""
end

function BLObjectives:set_time(time)
	local timer_text = self._hud_panel:child("heist_panel"):child("timer_text")
	if math.floor(time) < self._last_time then
		return
	end
	self._last_time = time
	time = math.floor(time)
	local hours = math.floor(time / 3600)
	time = time - hours * 3600
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)
	if hours > 0 then
		self._text = (hours < 10 and "0" .. hours or hours) .. ":" .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
	elseif seconds > 0 or minutes > 0 then	
		self._text = (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
	end
	timer_text:set_text(" "..self._text)
end

function BLObjectives:activate_objective(data)

	self._active_objective_id = data.id
	local objectives_panel = self._hud_panel:child("objectives_panel")
	local objective_text = objectives_panel:child("obj_text")
	local amount_text = objectives_panel:child("obj_am")
	local icon = objectives_panel:child("obj_i")
	local d_obj = self._hud_panel:child("d_obj")
	local d_obj_am = d_obj:child("d_obj_am")
	local old = objective_text:text()
	
	
	objective_text:set_text(data.text .. ": ")
	icon:set_visible(true)
	
	if data.amount then
	self:update_amount_objective(data)
	amount_text:set_visible(true)
	else
	amount_text:set_text("")
	amount_text:set_visible(false)
	end
	
	if not (old == "") and data.text .. ": " ~= old then 
	self:CObjective(d_obj,old)
	else
	objectives_panel:stop()
	objectives_panel:animate(callback(self,self,"_animate_activate_objective"))
	end
	
	
end

function BLObjectives:CObjective(panel,text)
	local objectives_panel = self._hud_panel:child("objectives_panel")
	local d_obj = panel
	local d_text = d_obj:child("d_obj_text")
	d_text:set_text(text)
	
	d_obj:stop()
	d_obj:animate(callback(self,self,"_animate_done_objective"))
end

function BLObjectives:_animate_done_objective(d_obj)
	local d_text = d_obj:child("d_obj_text")
	local d_obj_f = d_obj:child("d_obj_f")
	local d_obj_am = d_obj:child("d_obj_am")
	local d_obj_bx = d_obj:child("d_obj_bx")
	local icon = d_obj:child("d_obj_i")
	local obj_d = self._hud_panel:child("obj_d")
	local x1 = d_obj:right()-20
	local y1 = d_obj:top()+34
	local x2 = self._hud_panel:center_x()
	local y2 = self._hud_panel:center_y()

	local tx1 = -21
	local tx2 = -91
	local _,_,txw,_ = d_obj_am:text_rect()
	local tx = d_obj:w()-20
	
	d_text:set_x(tx1-txw)
	d_obj_bx:set_x(tx)
	d_obj_f:set_x(tx)
	d_obj_am:set_x(tx1)
	
	local objectives_panel = self._hud_panel:child("objectives_panel")
	
	objectives_panel:stop()
	objectives_panel:set_visible(false)
	d_obj:set_visible(true)
	local T = 0.5
	local t = T
	obj_d:set_visible(true)
	icon:set_visible(true)
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		obj_d:set_x(math.round(math.clamp(x1-x2*2*t,x2,x1)))
		obj_d:set_y(math.round(math.clamp(y1+y2*2*t,y1,y2)))
	end
	obj_d:set_visible(false)
	icon:set_visible(false)
	local T = 0.3
	local t = T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local vis = math.abs(0.7 * math.sin(180*(t*3.3)))
		d_obj_bx:set_visible(true)
		d_obj_f:set_visible(true)
		d_text:set_x(math.round(math.clamp(tx1-txw-400*t,tx2-txw,tx1-txw)))
		d_obj_bx:set_x(math.round(math.clamp(tx-400*t,tx-70,tx)))
		d_obj_f:set_x(math.round(math.clamp(tx-400*t,tx-70,tx)))
		d_obj_am:set_x(math.round(math.clamp(tx1-400*t,tx2,tx1)))
		d_obj_f:set_alpha(vis)
	end
		d_obj_f:set_visible(false)
	wait(2)
	local T = 1
	local t = T
	while t > 0 do
	local dt = coroutine.yield()
	t = t - dt
	local vis = math.abs(0.7 * math.sin(180*t))
		d_text:set_x(math.round(math.clamp(300-400*t,tx1-txw,300)))
		d_obj_bx:set_x(math.round(math.clamp(tx+320-400*t,tx,tx+320)))
		d_obj_f:set_x(math.round(math.clamp(tx+320-400*t,tx,tx+320)))
		d_obj_am:set_x(math.round(math.clamp(300-400*t,tx1,300)))
		d_obj_f:set_alpha(vis)
	end
	d_obj_bx:set_visible(false)
	d_obj:set_visible(false)
	
	d_obj_am:set_text("")
	objectives_panel:animate(callback(self,self,"_animate_activate_objective"))
end

function BLObjectives:_animate_activate_objective(objectives_panel)
local text = objectives_panel:child("obj_text")
local icon = objectives_panel:child("obj_i")
local icon_f = objectives_panel:child("obj_f")
local am = objectives_panel:child("obj_am")
local x1 = objectives_panel:w()
local x2 = -21
local _,_,x3,_ = am:text_rect()
objectives_panel:set_visible(true)
local T = 1.5
local t = T
while t > 0 do 
	local dt = coroutine.yield()
	t = t - dt
	icon_f:set_visible(true)
	local vis = math.abs(0.7*(math.sin(t * 120*3)))
	text:set_x(math.clamp(x2-x3+300*t,x2-x3,x1))
	am:set_x(math.clamp(x2+300*t,x2,x1))
	icon:set_x(math.clamp(x1-20+300*t,x1-20,x1))
	icon_f:set_x(math.clamp(x1-20+300*t,x1-20,x1))
	icon_f:set_alpha(vis)
	end
local T = 2
local t = T
while t > 0 do 
	local dt = coroutine.yield()
	t = t - dt
	icon_f:set_visible(true)
	local vis = math.abs(0.7*(math.sin(t * 120*3)))
	icon_f:set_alpha(vis)
end

icon_f:set_visible(false)

end


function BLObjectives:update_amount_objective(data)
	if data.id == self._active_objective_id then
		local amount = data.amount and string.format("%d/%d", data.current_amount or 0, data.amount)
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local amount_text = objectives_panel:child("obj_am")
		local dobj = self._hud_panel:child("d_obj")
		local d_obj_am = dobj:child("d_obj_am")	
		amount_text:set_text(amount.." ")
		if data.current_amount > 0 then
		objectives_panel:stop()
		objectives_panel:animate(callback(self,self,"_update_amount_objective"))
		d_obj_am:set_text(amount.." ")
		end
	end
end

function BLObjectives:_update_amount_objective(obj)
	local text = obj:child("obj_text")
	local icon = obj:child("obj_i")
	local icon_f = obj:child("obj_f")
	local am = obj:child("obj_am")
	local x5 = obj:w()-20
	local x1 = -21
	local x2 = -91
	local _,_,x3,_ = am:text_rect()
	
	local T = 0.3
	local t = T
	icon_f:set_visible(true)
	while t > 0 do
	dt = coroutine.yield()
	t = t - dt
	local vis = math.abs(0.7 * math.sin(180*t*3.3))
	text:set_x(math.clamp(x1-x3-400*t,x2-x3,x1-x3))
	am:set_x(math.clamp(x1-400*t,x2,x1))
	icon:set_x(math.clamp(x5-400*t,x5-70,x5))
	icon_f:set_x(math.clamp(x5-400*t,x5-70,x5))
	icon_f:set_alpha(vis)
	end
	icon_f:set_visible(false)
end
