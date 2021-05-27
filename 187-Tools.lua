-- local variables for API functions. any changes to the line below will be lost on re-generation
local bit_band, bit_bnot, client_camera_angles, client_color_log, client_create_interface, client_delay_call, client_find_signature, client_get_cvar, client_register_esp_flag, client_screen_size, client_set_cvar, client_set_event_callback, entity_get_all, entity_get_classname, entity_get_player_weapon, entity_get_players, entity_get_prop, entity_set_prop, globals_absoluteframetime, globals_mapname, math_abs, math_ceil, math_cos, math_floor, math_rad, math_sin, panorama_open, require, error, math_max, renderer_circle_outline, renderer_line, renderer_measure_text, renderer_text, string_upper, ui_new_button, ui_new_color_picker, ui_new_label, ui_reference, pairs, string_lower, table_concat, ui_new_slider, tostring, ui_new_hotkey, tonumber = bit.band, bit.bnot, client.camera_angles, client.color_log, client.create_interface, client.delay_call, client.find_signature, client.get_cvar, client.register_esp_flag, client.screen_size, client.set_cvar, client.set_event_callback, entity.get_all, entity.get_classname, entity.get_player_weapon, entity.get_players, entity.get_prop, entity.set_prop, globals.absoluteframetime, globals.mapname, math.abs, math.ceil, math.cos, math.floor, math.rad, math.sin, panorama.open, require, error, math.max, renderer.circle_outline, renderer.line, renderer.measure_text, renderer.text, string.upper, ui.new_button, ui.new_color_picker, ui.new_label, ui.reference, pairs, string.lower, table.concat, ui.new_slider, tostring, ui.new_hotkey, tonumber

require("bit")

local ffi = require 'ffi'
local js = panorama_open()
local api = js.MyPersonaAPI
local name = api.GetName()

local csgo_weapons = require("gamesense/csgo_weapons")
local vector = require "vector"
local ffi = require('ffi')

ffi.cdef [[
typedef bool(__thiscall* lgts)(float, float, float, float, float, float, short);
typedef void***(__thiscall* FindHudElement_t)(void*, const char*);
typedef void(__cdecl* ChatPrintf_t)(void*, int, int, const char*, ...);
]]

local ui_new_checkbox = ui.new_checkbox
local ui_new_multiselect = ui.new_multiselect
local ui_get = ui.get
local client_log = client.log -- (string)
local client_userid_to_entindex = client.userid_to_entindex -- (userid)
local entity_get_player_name = entity.get_player_name -- (index)
local entity_get_local_player = entity.get_local_player

local find_material = materialsystem.find_material
local engine_client = ffi.cast(ffi.typeof('void***'), client_create_interface('engine.dll', 'VEngineClient014'))
local console_is_visible = ffi.cast(ffi.typeof('bool(__thiscall*)(void*)'), engine_client[0][11])

local signature = '\x55\x8B\xEC\x83\xEC\x08\x8B\x15\xCC\xCC\xCC\xCC\x0F\x57'
local signature_gHud = '\xB9\xCC\xCC\xCC\xCC\x88\x46\x09'
local signature_FindElement = '\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x57\x8B\xF9\x33\xF6\x39\x77\x28'
local match = client_find_signature('client.dll', signature) or error('client_find_signature fucked up')
local line_goes_through_smoke = ffi.cast('lgts', match) or error('ffi.cast fucked up')
local match = client_find_signature('client.dll', signature_gHud) or error('signature not found')
local hud = ffi.cast('void**', ffi.cast('char*', match) + 1)[0] or error('hud is nil')
local helement_match = client_find_signature('client.dll', signature_FindElement) or error('FindHudElement not found')
local hudchat = ffi.cast('FindHudElement_t', helement_match)(hud, 'CHudChat') or error('CHudChat not found')
local chudchat_vtbl = hudchat[0] or error('CHudChat instance vtable is nil')
local print_to_chat = ffi.cast('ChatPrintf_t', chudchat_vtbl[27])

local function print_chat(text)
	print_to_chat(hudchat, 0, 0, text)
end



-- header
ui_new_label("LUA", "B", " ")
ui_new_label("LUA", "B", " ")
ui_new_label("LUA", "B", " ")
ui_new_label("LUA", "B", " ")
ui_new_label("LUA", "B", " ")
ui_new_label("LUA", "B", "------------    1 8 7 - T 0 0 L S . L U A    ------------")
ui_new_label("LUA", "B", " ")


-------------------------------------------------------------------------
-----  Weaponchams
-------------------------------------------------------------------------
local wchams_enable = ui.new_checkbox("LUA", "B", "Enable Weapon based Chams")
local guns = {'Knife/Zeus','Pistol','SMG','Rifle','Shotgun','Sniper','LMG','Other','Grenades'}
local chams, options = ui_reference("Visuals", "Colored Models", "Weapon viewmodel"), ui.new_multiselect("LUA", "B", "  Weaponchams", {"Rifle", "Sniper", "LMG", "Shotgun", "SMG", "Pistol", "Knife/Zeus", "Grenades", "Other"})
ui.set(chams, false)

local function contains(item, val)
	table = ui.get(item)
	for i=1,#table do
		if table[i] == val then
			return true
		end
	end
	return false
end

local function on_item_equip(e)
	if client.userid_to_entindex( e.userid ) == entity.get_local_player() then
		if e.weptype == -1 or e.weptype == 0 then
			num = 1
		elseif e.weptype > 7 then
			num = 8
		else
			num = e.weptype+1
		end
		ui.set(chams, contains(options, guns[num]))
	end
end
client_set_event_callback("item_equip", on_item_equip)


-------------------------------------------------------------------------
-----  Console Color
-------------------------------------------------------------------------
local enable_ccolor = ui.new_checkbox("LUA", "B", "Enable Console Color")
local recolor_console = ui_new_color_picker('LUA', 'B', 'VGUI Color picker', 50, 0, 61, 100)
local materials = { 'vgui_white', 'vgui/hud/800corner1', 'vgui/hud/800corner2', 'vgui/hud/800corner3', 'vgui/hud/800corner4' }


client_set_event_callback('paint', function()
local r, g, b, a = ui.get(recolor_console)

if not console_is_visible(engine_client) then
	r, g, b, a = 255, 255, 255, 255
end

for _, mat in pairs(materials) do
	find_material(mat):alpha_modulate(a)
	find_material(mat):color_modulate(r, g, b)
end
end)



-------------------------------------------------------------------------
----- Center Indicators
-------------------------------------------------------------------------
local client_log = client.log
local ui_get, ui_set = ui.get, ui.set
local ui_set_callback = ui.set_callback
local ui_set_visible = ui.set_visible
local draw_text = renderer_text
local renderer_rectangle, renderer_gradient = renderer.rectangle, renderer.gradient
local floor = math_floor
local table_insert, table_remove = table.insert, table.remove
local unpack = table.unpack

local indicators = {}
local indicators_clr = {}

local x, y = client_screen_size()

local master = ui.new_checkbox("LUA", "B", "  Center Indicator")
local custom_gap = ui.new_checkbox("LUA", "B", "Custom gap")
local gap = ui_new_slider("LUA", "B", "Gap", 0, 1000, 20, true, 'px')

local function contains(tbl, val) for i=1,#tbl do if tbl[i] == val then return true end end return false end
	local function make_even(x)
		return bit_band(x + 1, bit_bnot(1))
	end

	local function insertIndicator(text, color)
		if text == nil then return end
		if color == nil then color = {255,255,255,255} end
		if not contains(indicators, text) then
			table_insert(indicators, text)
			table_insert(indicators_clr, color)
		end
	end

	local function drawIndicators()
		local sw, sh = floor(x*0.5 + 0.5), y
		sh = ui_get(custom_gap) and sh - ui_get(gap) or sh

		if #indicators > 0 and #indicators_clr > 0 then
			local iterator = 0
			for k, v in pairs(indicators) do
				iterator = iterator + 1
				local wi, he = renderer_measure_text('c+', v)
				local wii = make_even(wi) / 2
				local gx, gy = sw - (wi / 2), sh - (he / 2) + 2
				renderer_gradient(gx-wii, ((gy + 10) - (iterator * 30)), wii, he, 0, 0, 0, 0, 0, 0, 0, 40, true)
				renderer_rectangle(gx, ((gy + 10) - (iterator * 30)), wi, he, 0,0,0,40)
				renderer_gradient(gx+wi, ((gy + 10) - (iterator * 30)), wii, he, 0, 0, 0, 40, 0, 0, 0, 0, true)

				draw_text(sw, ((sh + 10) - (iterator * 30)), indicators_clr[iterator][1], indicators_clr[iterator][2], indicators_clr[iterator][3], indicators_clr[iterator][4], 'c+', 0, v)
			end
		end
	end

	local function on_paint()
		drawIndicators()
		indicators = {}
		indicators_clr = {}
	end
	local function on_indicator(e)
		if not contains(indicators, e) then
			insertIndicator(e.text, {e.r,e.g,e.b,e.a})
		end
	end
	local function menuHandle()
		bool = ui_get(master)
		ui_set_visible(custom_gap,bool)
		ui_set_visible(gap,bool and ui_get(custom_gap))
	end
	local function callbackHandle()
		menuHandle()
		local czechbox = ui_get(master)
		local update_callback = czechbox and client_set_event_callback or client.unset_event_callback
		update_callback('indicator', on_indicator)
		update_callback('paint', on_paint)
	end
	ui_set_callback(master, callbackHandle)
	ui_set_callback(custom_gap, menuHandle)
	menuHandle()


	-------------------------------------------------------------------------
	----- Flags
	-------------------------------------------------------------------------
	local checkbox = ui.new_checkbox("LUA", "B", "Callout flag")
	local players = entity_get_players(true)

	client_register_esp_flag(".", 214, 34, 133, function(ent)
	if ui.get(checkbox) then
		local PlayerPos = entity_get_prop(ent, "m_bSpotted")
		return true, string_upper(tostring(PlayerPos))
	end
	end)


	-------------------------------------------------------------------------
	----- 360 Trickshot
	-------------------------------------------------------------------------
	local trick_enable = ui.new_checkbox("LUA", "B", "Enable 360° Trickshot helper")
	local trickshotmode = ui_new_hotkey( "LUA", "B", "360° Trickshot helper", false )
	local trickshotspeed = ui_new_slider( "LUA", "B", "360° speed", 8, 100, 15, true, "x", 1, true )

	local function vec_3( _x, _y, _z )
		return { x = _x or 0, y = _y or 0, z = _z or 0 }
	end

	function round( x )
		return x >= 0 and math_floor( x+0.5 ) or math_ceil( x-0.5 )
	end

	local function normalize_as_yaw( yaw )
		if yaw > 180 or yaw < -180 then
			local revolutions = round( math_abs( yaw / 360 ) )

			if yaw < 0 then
				yaw = yaw + 360 * revolutions
			else
				yaw = yaw - 360 * revolutions
			end
		end

		return yaw
	end

	local angle = 0
	local original = 0
	local once = false
	local complete = false
	client_set_event_callback( "setup_command", function( cmd )
	if ui.get( trickshotmode ) then
		local camera = vec_3( client_camera_angles( ) )
		if not once then
			angle = camera.y
			original = angle
			once = true
		end

		if angle > original - 360 then
			angle = angle - ( ( ui.get( trickshotspeed ) * 100 ) * globals_absoluteframetime( ) )
			cmd.yaw = normalize_as_yaw( angle )
			complete = false
		else
			complete = true
		end
	else
		once = false
	end
	end )

	local width, height = client_screen_size( )
	client_set_event_callback( "paint", function( )
	if ui.get( trickshotmode ) then
		renderer_circle_outline( width / 2, height / 2, complete and 55 or 255, 255, complete and 55 or 255, 255, 10, -90, math_abs( angle - original ) * 0.02777777777 / 10, 4 )
	end
	end )


	-------------------------------------------------------------------------
	----- 180 Bhop
	-------------------------------------------------------------------------
	local check = ui.new_checkbox("LUA", "B", "Backwards Bunnyhop")
	local hotkey = ui_new_hotkey("LUA", "B", "180° Turn key")
	local turn_speed = ui_new_slider("LUA", "B", "180° Turn speed", 1, 50, 5)

	function angle_mod(angle)
		return ((360/65536)*(bit_band(angle *(65536 / 360), 65535)))
	end

	function normalize(angle)
		while angle > 180 do
			angle = angle - 360
		end
		while angle < -180 do
			angle = angle + 360
		end
		return angle
	end

	function approach_angle(target, value, speed)
		target = angle_mod(target)
		value = angle_mod(value)

		delta = target - value

		if speed < 0 then
			speed = -speed
		end

		if delta < -180 then
			delta = delta + 360
		elseif delta > 180 then
			delta = delta - 360
		end

		if delta > speed then
			value = value + speed
		elseif delta < -speed then
			value = value - speed
		else
			value = target
		end

		return value
	end

	local cur_yaw = nil
	local last_angle = nil
	client_set_event_callback("setup_command", function(c)
	cur_yaw = c.yaw

	if ui.get(check) then
		if last_angle == nil then
			last_angle = c.yaw
		end

		if ui.get(hotkey) then
			last_angle = approach_angle(c.yaw + 180, last_angle, ui.get(turn_speed))
		else
			last_angle = approach_angle(c.yaw, last_angle, ui.get(turn_speed))
		end

		c.yaw = last_angle
	end
	end)

	client_set_event_callback("paint", function()
	local screen = { client_screen_size() }
	if ui.get(check) and cur_yaw and last_angle then
		renderer_text(screen[1]/2, screen[2]/3-25, 255, 255, 255, 255, "c", 0, "TURN")
		renderer_circle_outline(screen[1]/2, screen[2]/3, 100, 100, 100, 255, 15, 0, 1, 15)
		renderer_circle_outline(screen[1]/2, screen[2]/3, 0, 0, 0, 255, 15, 0, 1, 1)
		renderer_line(screen[1]/2, screen[2]/3, screen[1]/2+math_sin(math_rad(cur_yaw-last_angle+180))*15, screen[2]/3+math_cos(math_rad(cur_yaw-last_angle+180))*15, 0, 0, 0, 255)
	end
	end)


	-------------------------------------------------------------------------
	----- Knivehand
	-------------------------------------------------------------------------
	local knife_lefthand = ui.new_checkbox("MISC", "Miscellaneous", "Switch Knife Hand")

	local changed = false

	client_set_event_callback("paint", function()
	if ui.get(knife_lefthand)  == false then return end
	local local_player = entity.get_local_player()
	if local_player == nil then return end
	local weapon = entity_get_player_weapon(local_player)

	if entity_get_classname(weapon) == "CKnife" then
		cvar.cl_righthand:set_raw_int(cvar.cl_righthand:get_string() == "0" and 1 or 0)
		changed = true
	elseif changed then
		cvar.cl_righthand:set_raw_int(tonumber(cvar.cl_righthand:get_string()))
		changed = false
	end
	end)

	client_set_event_callback("shutdown", function()
	if changed then
		cvar.cl_righthand:set_raw_int(tonumber(cvar.cl_righthand:get_string()))
	end
	end)

	ui.set_callback(knife_lefthand, function()
	if changed then
		cvar.cl_righthand:set_raw_int(tonumber(cvar.cl_righthand:get_string()))
	end
	end)



	-------------------------------------------------------------------------
	----- Bloom effects
	-------------------------------------------------------------------------

	local mat_ambient_light_r, mat_ambient_light_g, mat_ambient_light_b = cvar.mat_ambient_light_r, cvar.mat_ambient_light_g, cvar.mat_ambient_light_b
	local r_modelAmbientMin = cvar.r_modelAmbientMin

	local enable_bloom = ui.new_checkbox("LUA", "B", "Enable Bloom effects")
	local wallcolor_reference = ui.new_checkbox("LUA", "B", "Wall Color")
	local wallcolor_color_reference = ui_new_color_picker("LUA", "B", "Wall Color", 255, 0, 0, 128)

	local bloom_reference = ui_new_slider("LUA", "B", "Bloom scale", -1, 500, -1, true, nil, 0.01, {[-1]="Off"})
	local exposure_reference = ui_new_slider("LUA", "B", "Auto Exposure", -1, 2000, -1, true, nil, 0.001, {[-1]="Off"})
	local model_ambient_min_reference = ui_new_slider("LUA", "B", "Minimum model brightness", 0, 1000, -1, true, nil, 0.05)

	local max_val = 1

	local bloom_default, exposure_min_default, exposure_max_default
	local bloom_prev, exposure_prev, model_ambient_min_prev, wallcolor_prev

	local function reset_bloom(tone_map_controller)
		if bloom_default == -1 then
			entity_set_prop(tone_map_controller, "m_bUseCustomBloomScale", 0)
			entity_set_prop(tone_map_controller, "m_flCustomBloomScale", 0)
		else
			entity_set_prop(tone_map_controller, "m_bUseCustomBloomScale", 1)
			entity_set_prop(tone_map_controller, "m_flCustomBloomScale", bloom_default)
		end
	end

	local function reset_exposure(tone_map_controller)
		if exposure_min_default == -1 then
			entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMin", 0)
			entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMin", 0)
		else
			entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMin", 1)
			entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMin", exposure_min_default)
		end
		if exposure_max_default == -1 then
			entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMax", 0)
			entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMax", 0)
		else
			entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMax", 1)
			entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMax", exposure_max_default)
		end
	end

	local function on_paint()
		local wallcolor = ui_get(wallcolor_reference)
		if wallcolor or wallcolor_prev then
			if wallcolor then
				local r, g, b, a = ui_get(wallcolor_color_reference)
				r, g, b = r/255, g/255, b/255
				local a_temp = a / 128 - 1
				local r_res, g_res, b_res
				if a_temp > 0 then
					local multiplier = 900^(a_temp) - 1
					a_temp = a_temp * multiplier
					r_res, g_res, b_res = r*a_temp, g*a_temp, b*a_temp
				else
					a_temp = a_temp * max_val
					r_res, g_res, b_res = (1-r)*a_temp, (1-g)*a_temp, (1-b)*a_temp
				end
				if mat_ambient_light_r:get_float() ~= r_res or mat_ambient_light_g:get_float() ~= g_res or mat_ambient_light_b:get_float() ~= b_res then
					mat_ambient_light_r:set_raw_float(r_res)
					mat_ambient_light_g:set_raw_float(g_res)
					mat_ambient_light_b:set_raw_float(b_res)
				end
			else
				mat_ambient_light_r:set_raw_float(0)
				mat_ambient_light_g:set_raw_float(0)
				mat_ambient_light_b:set_raw_float(0)
			end
		end
		wallcolor_prev = wallcolor

		local model_ambient_min = ui_get(model_ambient_min_reference)
		if model_ambient_min > 0 or (model_ambient_min_prev ~= nil and model_ambient_min_prev > 0) then
			if r_modelAmbientMin:get_float() ~= model_ambient_min*0.05 then
				r_modelAmbientMin:set_raw_float(model_ambient_min*0.05)
			end
		end
		model_ambient_min_prev = model_ambient_min

		local bloom = ui_get(bloom_reference)
		local exposure = ui_get(exposure_reference)
		if bloom ~= -1 or exposure ~= -1 or bloom_prev ~= -1 or exposure_prev ~= -1 then
			local tone_map_controllers = entity_get_all("CEnvTonemapController")
			for i=1, #tone_map_controllers do
				local tone_map_controller = tone_map_controllers[i]
				if bloom ~= -1 then
					if bloom_default == nil then
						if entity_get_prop(tone_map_controller, "m_bUseCustomBloomScale") == 1 then
							bloom_default = entity_get_prop(tone_map_controller, "m_flCustomBloomScale")
						else
							bloom_default = -1
						end
					end
					entity_set_prop(tone_map_controller, "m_bUseCustomBloomScale", 1)
					entity_set_prop(tone_map_controller, "m_flCustomBloomScale", bloom*0.01)
				elseif bloom_prev ~= nil and bloom_prev ~= -1 and bloom_default ~= nil then
					reset_bloom(tone_map_controller)
				end
				if exposure ~= -1 then
					if exposure_min_default == nil then
						if entity_get_prop(tone_map_controller, "m_bUseCustomAutoExposureMin") == 1 then
							exposure_min_default = entity_get_prop(tone_map_controller, "m_flCustomAutoExposureMin")
						else
							exposure_min_default = -1
						end
						if entity_get_prop(tone_map_controller, "m_bUseCustomAutoExposureMax") == 1 then
							exposure_max_default = entity_get_prop(tone_map_controller, "m_flCustomAutoExposureMax")
						else
							exposure_max_default = -1
						end
					end
					entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMin", 1)
					entity_set_prop(tone_map_controller, "m_bUseCustomAutoExposureMax", 1)
					entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMin", math_max(0.0000, exposure*0.001))
					entity_set_prop(tone_map_controller, "m_flCustomAutoExposureMax", math_max(0.0000, exposure*0.001))
				elseif exposure_prev ~= nil and exposure_prev ~= -1 and exposure_min_default ~= nil then
					reset_exposure(tone_map_controller)
				end
			end
		end
		bloom_prev = bloom
		exposure_prev = exposure
	end
	client_set_event_callback("paint", on_paint)

	local function task()
		if globals_mapname() == nil then
			bloom_default, exposure_min_default, exposure_max_default = nil, nil, nil
		end
		client_delay_call(0.5, task)
	end
	task()

	local function on_shutdown()
		local tone_map_controllers = entity_get_all("CEnvTonemapController")
		for i=1, #tone_map_controllers do
			local tone_map_controller = tone_map_controllers[i]
			if bloom_prev ~= -1 and bloom_default ~= nil then
				reset_bloom(tone_map_controller)
			end
			if exposure_prev ~= -1 and exposure_min_default ~= nil then
				reset_exposure(tone_map_controller)
			end
		end
		mat_ambient_light_r:set_raw_float(0)
		mat_ambient_light_g:set_raw_float(0)
		mat_ambient_light_b:set_raw_float(0)
		r_modelAmbientMin:set_raw_float(0)
	end
	client_set_event_callback("shutdown", on_shutdown)




	-------------------------------------------------------------------------
	----- Shot Logger
	-------------------------------------------------------------------------
	
local aimbotlog_enable = ui.new_checkbox("LUA", "B", "Advanced aimbot logging")
local on_fire_enable = ui.new_checkbox("LUA", "B", "Fire log")
local on_fire_colour = ui.new_color_picker("LUA", "B", "Fire log", 147, 112, 219, 255)
local on_miss_enable = ui.new_checkbox("LUA", "B", "Miss log")
local on_miss_colour = ui.new_color_picker("LUA", "B", "Miss log", 255, 253, 166, 255)
local on_damage_enable = ui.new_checkbox("LUA", "B", "Damage log")
local on_damage_colour = ui.new_color_picker("LUA", "B", "Damage log", 100, 149, 237, 255)
local str_fmt = string.format

local function handle_menu()
	if ui.get(aimbotlog_enable) then
		ui.set_visible(on_fire_enable, true)
		ui.set_visible(on_fire_colour, true)
		ui.set_visible(on_miss_enable, true)
		ui.set_visible(on_miss_colour, true)
		ui.set_visible(on_damage_enable, true)
		ui.set_visible(on_damage_colour, true)
	else
		ui.set_visible(on_fire_enable, false)
		ui.set_visible(on_fire_colour, false)
		ui.set_visible(on_miss_enable, false)
		ui.set_visible(on_miss_colour, false)
		ui.set_visible(on_damage_enable, false)
		ui.set_visible(on_damage_colour, false)
	end
end
handle_menu()
ui.set_callback(aimbotlog_enable, handle_menu)

local function on_aim_fire(e)
    if ui.get(aimbotlog_enable) and ui.get(on_fire_enable) and e ~= nil then
    	local r, g, b = ui.get(on_fire_colour)
        local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
        local group = hitgroup_names[e.hitgroup + 1] or "?"
        local tickrate = client.get_cvar("cl_cmdrate") or 64
        local target_name = entity.get_player_name(e.target)
        local ticks = math.floor((e.backtrack * tickrate) + 0.5)
        local flags = {
        e.teleported and 't' or '',
        e.interpolated and 'i' or '',
        e.extrapolated and 'e' or '',
        e.boosted and 'b' or '',
        e.high_priority and 'h' or ''
    	}

        client.color_log(r, g, b,
        "fired at " ..
        string.lower(target_name) ..
        "'s " ..
        group ..
        " for " ..
        e.damage ..
        " damage (hc: " ..
        str_fmt("%d", e.hit_chance) ..
        "%  bt: " ..
        e.backtrack ..
        " (", ticks, " tks) " ..
        " flgs: " ..
        table.concat(flags) ..
        ")")
    end
end

local function on_player_hurt(e)
	if ui.get(aimbotlog_enable) and ui.get(on_damage_enable) then
    local attacker_id = client.userid_to_entindex(e.attacker)
    if attacker_id == nil then
        return
    end

    if attacker_id ~= entity.get_local_player() then
        return
    end

    local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
    local group = hitgroup_names[e.hitgroup + 1] or "?"
    local target_id = client.userid_to_entindex(e.userid)
    local target_name = entity.get_player_name(target_id)

    local message = "hit " .. string.lower(target_name) .. "'s " .. group .. " for " .. e.dmg_health .. " damage (" .. e.health .. " remaining)"
    if e.health <= 0 then
        message = message .. " *dead*"
    end

    
    local r, g, b = ui.get(on_damage_colour)
    client.color_log(r, g, b, message) 
    end
end

local function on_aim_miss(e)
	if ui.get(aimbotlog_enable) and ui.get(on_miss_enable) and e ~= nil then
	local r, g, b = ui.get(on_miss_colour)
    local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
    local group = hitgroup_names[e.hitgroup + 1] or "?"
    local target_name = entity.get_player_name(e.target)
    local reason
    if e.reason == "?" then
    	reason = "resolver"
    else
    	reason = e.reason
    end

        client.color_log(r, g, b,
        "missed " ..
        string.lower(target_name) ..
        "'s " ..
        group ..
        " due to "
        ..
        reason)
    end
end

client.set_event_callback('aim_fire', on_aim_fire)
client.set_event_callback('player_hurt', on_player_hurt)
client.set_event_callback('aim_miss', on_aim_miss)




-------------------------------------------------------------------------
----- Spam Buttons
-------------------------------------------------------------------------
local vars = {
	misc = {
		name = false
	},
}

local references = {
	misc = {
		namesteal = ui_reference('MISC', 'Miscellaneous', 'Steal player name'),
	},
}

local spam1 = ui_new_button('LUA', 'B', 'GAMESENSE > ALL', function()
local player = entity.get_local_player()
if not vars.misc.name then
	name = entity.get_player_name(player)
	vars.misc.name = true
end
ui.set(references.misc.namesteal, true)
client_set_cvar('name', 'GAMESENSE > ALL')
client_delay_call(0.15, client_set_cvar, 'name', 'GAMESENSE > ALL')
client_delay_call(0.45, client_set_cvar, 'name', 'GAMESENSE > ALL')
client_delay_call(0.6, client_set_cvar, 'name', name)
if name == entity.get_player_name(player) then
	vars.misc.name = false
end
end)


local spam2 = ui_new_button('LUA', 'B', '187hackerbande > ALL', function()
local player = entity.get_local_player()
if not vars.misc.name then
	name = entity.get_player_name(player)
	vars.misc.name = true
end
ui.set(references.misc.namesteal, true)
client_set_cvar('name', '187hackerbande.xyz > ALL')
client_delay_call(0.15, client_set_cvar, 'name', '187hackerbande.xyz > ALL')
client_delay_call(0.45, client_set_cvar, 'name', '187hackerbande.xyz > ALL')
client_delay_call(0.6, client_set_cvar, 'name', name)
if name == entity.get_player_name(player) then
	vars.misc.name = false
end
end)

local spam3 = ui_new_button('LUA', 'B', '187shop.xyz', function()
local player = entity.get_local_player()
if not vars.misc.name then
	name = entity.get_player_name(player)
	vars.misc.name = true
end
ui.set(references.misc.namesteal, true)
client_set_cvar('name', '> Community Locker')
client_delay_call(0.15, client_set_cvar, 'name', '> Trust Fucker')
client_delay_call(0.45, client_set_cvar, 'name', 'Visit: 187shop.xyz')
client_delay_call(0.6, client_set_cvar, 'name', name)
if name == entity.get_player_name(player) then
	vars.misc.name = false
end
end)

local spam5 = ui_new_button('LUA', 'B', 'Semirage du Hurensohn', function()
local player = entity.get_local_player()
if not vars.misc.name then
	name = entity.get_player_name(player)
	vars.misc.name = true
end
ui.set(references.misc.namesteal, true)
client_set_cvar('name', 'Jetzt klatsch es ...')
client_delay_call(0.15, client_set_cvar, 'name', 'Semirage du Hurensohn')
client_delay_call(0.45, client_set_cvar, 'name', 'Dummer Awall Nigger')
client_delay_call(0.6, client_set_cvar, 'name', name)
if name == entity.get_player_name(player) then
	vars.misc.name = false
end
end)

local spam6 = ui_new_button('LUA', 'B', 'Deine Mama', function()
local player = entity.get_local_player()
if not vars.misc.name then
	name = entity.get_player_name(player)
	vars.misc.name = true
end
ui.set(references.misc.namesteal, true)
client_set_cvar('name', 'Deine')
client_delay_call(0.15, client_set_cvar, 'name', 'Deine Mama')
client_delay_call(0.45, client_set_cvar, 'name', 'Deine Mama stinkt')
client_delay_call(0.6, client_set_cvar, 'name', name)
if name == entity.get_player_name(player) then
	vars.misc.name = false
end
end

	-------------------------------------------------------------------------
	----- Panorama Report Panel
	-------------------------------------------------------------------------
	local panorama_loadstring = panorama.loadstring

	local layout = [[
	<root>
	<styles>
	<include src="file://{resources}/styles/csgostyles.css" />
	<include src="file://{resources}/styles/mainmenu.css" />
	</styles>

	<Panel class="horizontal-center">
	<RadioButton id="CustomReportBtn"
	class="mainmenu-navbar__btn-small PauseMenuModeOnly"
	onmouseover="UiToolkitAPI.ShowTextTooltip('CustomReportBtn','Report Tool');"
	onmouseout="UiToolkitAPI.HideTextTooltip();">
	<Image textureheight="32" texturewidth="-1" src="file://{images}/icons/ui/warning.svg" />
	</RadioButton>
	</Panel>
	</root>
	]]

	local panel = panorama_loadstring([[
	ReportEssientials = {
		ReportAll : function(teamName, muting){
			if(!teamName){
				teamName = (GameStateAPI.GetPlayerTeamName(GameStateAPI.GetLocalOrInEyePlayerXuid()) == "CT") ? "TERRORIST" : "CT"
			}
			var oPlayerList = GameStateAPI.GetPlayerDataJSO()
			var reportPlayerXUIDList = []
			if ( !oPlayerList || Object.keys( oPlayerList ).length === 0 ){
				return false
			}
			for ( var i in oPlayerList[ teamName ] ){
				var xuid = oPlayerList[ teamName ][ i ];
				if ( xuid == 0 )
				continue;

				if(GameStateAPI.IsXuidValid(xuid) && !GameStateAPI.IsFakePlayer(xuid)){
					reportPlayerXUIDList.push(xuid)
				}
			}
			reportPlayerXUIDList.forEach(function(item, index){
				$.Schedule(index, ReportEssientials.ReportCore(item, muting))
				if(index == (reportPlayerXUIDList.length - 1)){$.Schedule(index, function(){$.DispatchEvent('BlurrrButton')})}
			})
		},
		ReportCore : function(xuid, muting){
			return function(){
				if(GameStateAPI.GetLocalPlayerXuid() == xuid)
				return
				var cats = ["textabuse", "voiceabuse", "grief", "wallhack", "aimbot", "speedhack"]
				cats.forEach(function(item, index){
					if (!GameStateAPI.IsReportCategoryEnabledForSelectedPlayer(xuid, item)){
						cats.splice(index, 1)
					}
				})
				var ifMuted = false
				if(muting){
					ifMuted = GameStateAPI.IsSelectedPlayerMuted(xuid)
				}
				GameStateAPI.SubmitPlayerReport(xuid, cats.toString() + ",")
				$.Msg("[Report] Reporting " + xuid + " with " + cats.toString())
				if(muting && (GameStateAPI.IsSelectedPlayerMuted(xuid) != ifMuted)){
					GameStateAPI.ToggleMute(xuid)
				}
			}
		}
	}

	var _GetCurrentMenus = function(){
		var _ItemConstruct = function(name, cmd){
			return {
				label : name,
				jsCallback : cmd
			}
		}
		var Menu = []
		Menu.push(_ItemConstruct("Report All Terrorist", function(){ReportEssientials.ReportAll("TERRORIST", false);}))
		Menu.push(_ItemConstruct("Report All CT", function(){ReportEssientials.ReportAll("CT", false);}))
		Menu.push(_ItemConstruct("Report All Enemies", function(){ReportEssientials.ReportAll();}))
		Menu.push(_ItemConstruct("Report Enemies (No Mute)", function(){ReportEssientials.ReportAll(false, true);}))
		return Menu
	}
	return {
		create : function(layout){
			var obj_LSidebarMenu = $.GetContextPanel().FindChildTraverse('JsMainMenuNavBar')
			if(!obj_LSidebarMenu){
				return
			}
			var panel = $.CreatePanel("Panel", obj_LSidebarMenu, "CustomReportBtnPanel")
			if(!panel)
			return
			if(!panel.BLoadLayoutFromString(layout, false, false))
			return
			obj_LSidebarMenu.MoveChildAfter(panel, obj_LSidebarMenu.FindChildTraverse("MainMenuNavBarSettings"))
			var button = panel.FindChildTraverse("CustomReportBtn")
			if(button) {
				var _ShowVote = function () {
					button.checked = false
					var contextMenuPanel = UiToolkitAPI.ShowSimpleContextMenu( "CustomReportBtn", "", _GetCurrentMenus())
					contextMenuPanel.AddClass( "ContextMenu_NoArrow" );
				};
				button.SetPanelEvent("onactivate", _ShowVote)
			}
			$.DefineEvent( 'BlurrrButton', 0, '', "Button go blurrr" );
			var handleFunc = $.RegisterForUnhandledEvent( 'BlurrrButton', function(){
				if(button) {
					button.checked = false
				}
			})

			return {
				destroy : function() {
					if(panel != null) {
						$.UnregisterForUnhandledEvent( 'BlurrrButton', handleFunc )
						panel.RemoveAndDeleteChildren()
						panel.DeleteAsync(0.0)
						panel = null
					}
				},
				panel : panel
			}
		}
	}
	]],"CSGOMainMenu")().create(layout)

	client_set_event_callback("shutdown", function()
	if panel then
		panel.destroy()
	end
	end)


	local client_console_cmd = client.exec
	client_console_cmd("exec autoexec")
	client_console_cmd("clear")

	--foot
	ui_new_label("LUA", "B", " ")
	ui_new_label("LUA", "B", "              mailto:  ceo@187shop.xyz  ")
	ui_new_label("LUA", "B", "             Discord: Smurffiction#1337 ")
	ui_new_label("LUA", "B", "            Telegram: Smurffiction1337  ")
	ui_new_label("LUA", "B", "------------------------------------------------")
	ui_new_label("LUA", "B", " ")
	ui_new_label("LUA", "B", " ")
	ui_new_label("LUA", "B", " ")



	-- AScii
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, ' ----------------------------------------------------------------------------------------------- ')
	client_color_log(252, 248, 3, ' ----------------------------------------------------------------------------------------------- ')

	client_color_log(3, 148, 252, '     ██╗ █████╗ ███████╗████████╗ ██████╗  ██████╗ ██╗     ███████╗   ██╗     ██╗   ██╗ █████╗   ')
	client_color_log(3, 148, 252, '    ███║██╔══██╗╚════██║╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝   ██║     ██║   ██║██╔══██╗  ')
	client_color_log(3, 148, 252, '    ╚██║╚█████╔╝    ██╔╝   ██║   ██║   ██║██║   ██║██║     ███████╗   ██║     ██║   ██║███████║  ')
	client_color_log(3, 148, 252, '     ██║██╔══██╗   ██╔╝    ██║   ██║   ██║██║   ██║██║     ╚════██║   ██║     ██║   ██║██╔══██║  ')
	client_color_log(3, 148, 252, '     ██║╚█████╔╝   ██║     ██║   ╚██████╔╝╚██████╔╝███████╗███████║██╗███████╗╚██████╔╝██║  ██║  ')
	client_color_log(3, 148, 252, '     ╚═╝ ╚════╝    ╚═╝     ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝  ')
	client_color_log(3, 148, 252, '                              1 8 7 h a c k e r b a n d e . x y z                                ')
	client_color_log(252, 248, 3, ' ----------------------------------------------------------------------------------------------- ')
	client_color_log(252, 248, 3, ' ----------------------------------------------------------------------------------------------- ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')
	client_color_log(252, 248, 3, '   ')

