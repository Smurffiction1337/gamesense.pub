--region setup/config
-- Set this to either "a" or "b", depending on where you want the menu for the lua to be.
local script_menu_location = "b"
--endregion

--region gs_api
--region Client
local client = {
	latency = client.latency,
	log = client.log,
	userid_to_entindex = client.userid_to_entindex,
	set_event_callback = client.set_event_callback,
	screen_size = client.screen_size,
	eye_position = client.eye_position,
	color_log = client.color_log,
	delay_call = client.delay_call,
	visible = client.visible,
	exec = client.exec,
	trace_line = client.trace_line,
	draw_hitboxes = client.draw_hitboxes,
	camera_angles = client.camera_angles,
	draw_debug_text = client.draw_debug_text,
	random_int = client.random_int,
	random_float = client.random_float,
	trace_bullet = client.trace_bullet,
	scale_damage = client.scale_damage,
	timestamp = client.timestamp,
	set_clantag = client.set_clantag,
	system_time = client.system_time,
	reload_active_scripts = client.reload_active_scripts
}
--endregion

--region Entity
local entity = {
	get_local_player = entity.get_local_player,
	is_enemy = entity.is_enemy,
	hitbox_position = entity.hitbox_position,
	get_player_name = entity.get_player_name,
	get_steam64 = entity.get_steam64,
	get_bounding_box = entity.get_bounding_box,
	get_all = entity.get_all,
	set_prop = entity.set_prop,
	is_alive = entity.is_alive,
	get_player_weapon = entity.get_player_weapon,
	get_prop = entity.get_prop,
	get_players = entity.get_players,
	get_classname = entity.get_classname,
	get_game_rules = entity.get_game_rules,
	get_player_resource = entity.get_prop,
	is_dormant = entity.is_dormant,
}
--endregion

--region Globals
local globals = {
	realtime = globals.realtime,
	absoluteframetime = globals.absoluteframetime,
	tickcount = globals.tickcount,
	curtime = globals.curtime,
	mapname = globals.mapname,
	tickinterval = globals.tickinterval,
	framecount = globals.framecount,
	frametime = globals.frametime,
	maxplayers = globals.maxplayers,
	lastoutgoingcommand = globals.lastoutgoingcommand,
}
--endregion

--region Ui
local ui = {
	new_slider = ui.new_slider,
	new_combobox = ui.new_combobox,
	reference = ui.reference,
	set_visible = ui.set_visible,
	is_menu_open = ui.is_menu_open,
	new_color_picker = ui.new_color_picker,
	set_callback = ui.set_callback,
	set = ui.set,
	new_checkbox = ui.new_checkbox,
	new_hotkey = ui.new_hotkey,
	new_button = ui.new_button,
	new_multiselect = ui.new_multiselect,
	get = ui.get,
	new_textbox = ui.new_textbox,
	mouse_position = ui.mouse_position
}
--endregion

--region Renderer
local renderer = {
	text = renderer.text,
	measure_text = renderer.measure_text,
	rectangle = renderer.rectangle,
	line = renderer.line,
	gradient = renderer.gradient,
	circle = renderer.circle,
	circle_outline = renderer.circle_outline,
	triangle = renderer.triangle,
	world_to_screen = renderer.world_to_screen,
	indicator = renderer.indicator,
	texture = renderer.texture,
	load_svg = renderer.load_svg
}
--endregion
--endregion

--region dependencies
--region dependency: havoc_color
--region helpers
--- Convert HSL to RGB.
---
--- Original function by EmmanuelOga:
--- https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
---
--- @param color Color
local function update_rgb_space(color)
	local r, g, b

	if (color.s == 0) then
		r, g, b = color.l, color.l, color.l
	else
		function hue_to_rgb(p, q, t)
			if t < 0   then t = t + 1 end
			if t > 1   then t = t - 1 end
			if t < 1/6 then return p + (q - p) * 6 * t end
			if t < 1/2 then return q end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end

			return p
		end

		local q = 0

		if (color.l < 0.5) then
			q = color.l * (1 + color.s)
		else
			q = color.l + color.s - color.l * color.s
		end

		local p = 2 * color.l - q

		r = hue_to_rgb(p, q, color.h + 1/3)
		g = hue_to_rgb(p, q, color.h)
		b = hue_to_rgb(p, q, color.h - 1/3)
	end

	color.r = r * 255
	color.g = g * 255
	color.b = b * 255
end

--- Convert RGB to HSL.
---
--- Original function by EmmanuelOga:
--- https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
---
--- @param color Color
local function update_hsl_space(color)
	local r, g, b = color.r / 255, color.g / 255, color.b / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, l

	l = (max + min) / 2

	if (max == min) then
		h, s = 0, 0
	else
		local d = max - min

		if (l > 0.5) then
			s = d / (2 - max - min)
		else
			s = d / (max + min)
		end

		if (max == r) then
			h = (g - b) / d

			if (g < b) then
				h = h + 6
			end
		elseif (max == g) then
			h = (b - r) / d + 2
		elseif (max == b) then
			h = (r - g) / d + 4
		end

		h = h / 6
	end

	color.h, color.s, color.l = h, s, l or 255
end

--- Validate the RGB+A space and clamp errors.
---
--- @param color Color
local function validate_rgba(color)
	if (color.r < 0) then
		color.r = 0
	elseif (color.r > 255) then
		color.r = 255
	end

	if (color.g < 0) then
		color.g = 0
	elseif (color.g > 255) then
		color.g = 255
	end

	if (color.b < 0) then
		color.b = 0
	elseif (color.b > 255) then
		color.b = 255
	end

	if (color.a < 0) then
		color.a = 0
	elseif (color.a > 255) then
		color.a = 255
	end
end

--- Validate the HSL+A space and clamp errors.
---
--- @param color Color
local function validate_hsla(color)
	if (color.h < 0) then
		color.h = 0
	elseif (color.h > 1) then
		color.h = 1
	end

	if (color.s < 0) then
		color.s = 0
	elseif (color.s > 1) then
		color.s = 1
	end

	if (color.l < 0) then
		color.l = 0
	elseif (color.l > 1) then
		color.l = 1
	end

	if (color.a < 0) then
		color.a = 0
	elseif (color.a > 255) then
		color.a = 255
	end
end
--endregion

--region class.color
local Color = {}

--- Color metatable.
local color_mt = {
	__index = Color,
	__call = function(tbl, ...) return Color.new_rgba(...) end
}

--- Create new color object in using the RGB+A space.
---
--- @param r int
--- @param g int
--- @param b int
--- @param a int
--- @return Color
function Color.new_rgba(r, g, b, a)
	if (a == nil) then
		a = 255
	end

	local object = setmetatable({r = r, g = g, b = b, a = a, h = 0, s = 0, l = 0}, color_mt)

	validate_rgba(object)
	update_hsl_space(object)

	return object
end

--- Create new color object in using the HSL+A space.
---
--- @param self Color
--- @param h int
--- @param s int
--- @param l int
--- @param a int
--- @return Color
function Color.new_hsla(h, s, l, a)
	if (a == nil) then
		a = 255
	end

	local object = setmetatable({r = 0, g = 0, b = 0, a = a, h = h, s = s, l = l}, color_mt)

	validate_hsla(object)
	update_rgb_space(object)

	return object
end

--- Create a color from a UI reference.
---
--- @param ui_reference ui_reference
--- @since 1.1.0-release
function Color.new_from_ui_color_picker(ui_reference)
	return Color.new_rgba(unpack(ui.get(ui_reference)))
end

--- Overwrite current color using RGB+A space.
---
--- @param self Color
--- @param r int
--- @param g int
--- @param b int
--- @param a int
function Color.set_rgba(self, r, g, b, a)
	if (a == nil) then
		a = 255
	end

	self.r, self.g, self.b, self.a = r, g, b, a

	validate_rgba(self)
	update_hsl_space(self)
end

--- Overwrite current color using HSL+A space.
---
--- @param self Color
--- @param h int
--- @param s int
--- @param l int
--- @param a int
function Color.set_hsla(self, h, s, l, a)
	if (a == nil) then
		a = 255
	end

	self.h, self.s, self.l, self.a = h, s, l, a

	validate_hsla(self)
	update_rgb_space(self)
end

--- Overwrite current color using a UI reference.
---
--- @param ui_reference ui_reference
--- @since 1.1.0-release
function Color.set_from_ui_color_picker(ui_reference)
	return Color.set_rgba(unpack(ui.get(ui_reference)))
end

--- Unpack RGB+A space.
---
--- @param self Color
function Color.unpack_rgba(self)
	return self.r, self.g, self.b, self.a
end

--- Unpack HSL+A space.
---
--- @param self Color
function Color.unpack_hsla(self)
	return self.h, self.s, self.l, self.a
end

--- Unpack RGB, HSL, and A space.
---
--- @param self Color
--- @since 1.1.0-release
function Color.unpack_all(self)
	return self.r, self.g, self.b, self.h, self.s, self.l, self.a
end

--- Selects a color contrast.
---
--- Determines whether a colour is most visible against white or black, and returns white for 0, and 1 for black.
---
--- @param self Color
--- @return int
function Color.select_contrast(self)
	local contrast = self.r * 0.213 + self.g * 0.715 + self.b * 0.072

	if (contrast < 150) then
		return 0
	end

	return 1
end

--- Generates a color contrast.
---
--- Determines whether a colour is most visible against white or black, and returns a new color object for the one chosen.
---
--- @param self Color
--- @return Color
function Color.generate_contrast(self)
	local contrast = self:select_contrast()

	if (contrast == 0) then
		return Color.new_rgba(255, 255, 255)
	end

	return Color.new_rgba(0, 0, 0)
end

--- Set the hue of the color.
---
--- @param self Color
--- @param h float
function Color.set_hue(self, h)
	if (h < 0) then
		h = 0
	elseif (h > 1) then
		h = 1
	end

	self.h = h

	update_rgb_space(self)
end

--- Shift the hue of the color by a given amount.
---
--- Use negative numbers go to down the spectrum.
---
--- @param self Color
--- @param amount float
function Color.shift_hue(self, amount)
	local h = self.h + amount

	h = h % 1

	self.h = h

	update_rgb_space(self)
end

--- Shift the hue of the color by a given amount, but do not loop the spectrum.
---
--- Use negative numbers go to down the spectrum.
---
--- @param self Color
--- @param amount float
function Color.shift_hue_clamped(self, amount)
	local h = math.min(1, math.max(0, self.h + amount))

	self.h = h

	update_rgb_space(self)
end

--- Shift the hue of the color by a given amount, but keep within an upper and lower hue bound.
---
--- Use negative numbers go to down the spectrum.
---
--- @param self Color
--- @param amount float
--- @param lower_bound float
--- @param upper_bound float
function Color.shift_hue_within(self, amount, lower_bound, upper_bound)
	local h = self.h + amount

	if (h < lower_bound) then
		h = lower_bound
	elseif (h > upper_bound) then
		h = upper_bound
	end

	self.h = h

	update_rgb_space(self)
end

--- Returns true if hue is below or equal to a given hue.
---
--- @param self Color
--- @param h float
function Color.hue_is_below(self, h)
	return self.h <= h
end

--- Returns true if hue is above or equal to a given hue.
---
--- @param self Color
--- @param h float
function Color.hue_is_above(self, h)
	return self.h >= h
end

--- Returns true if hue is betwen two given hues.
---
--- @param self Color
--- @param lower_bound float
--- @param upper_bound float
function Color.hue_is_between(self, lower_bound, upper_bound)
	return self.h >= lower_bound and self.h <= upper_bound
end

--- Set the saturation of the color.
---
--- @param self Color
--- @param s float
function Color.set_saturation(self, s)
	if (s < 0) then
		s = 0
	elseif (s > 1) then
		s = 1
	end

	self.s = s

	update_rgb_space(self)
end

--- Shift the saturation of the color by a given amount.
---
--- Use negative numbers to decrease saturation.
---
--- @param self Color
--- @param amount float
function Color.shift_saturation(self, amount)
	local s = math.min(1, math.max(0, self.s + amount))

	self.s = s

	update_rgb_space(self)
end

--- Shift the saturation of the color by a given amount, but keep within an upper and lower saturation bound.
---
--- Use negative numbers to decrease saturation.
---
--- @param self Color
--- @param amount float
function Color.shift_saturation_within(self, amount, lower_bound, upper_bound)
	local s = self.s + amount

	if (s < lower_bound) then
		s = lower_bound
	elseif (s > upper_bound) then
		s = upper_bound
	end

	self.s = s

	update_rgb_space(self)
end

--- Returns true if saturation is below or equal to a given saturation.
---
--- @param self Color
--- @param s float
function Color.saturation_is_below(self, s)
	return self.s <= s
end

--- Returns true if saturation is above or equal to a given saturation.
---
--- @param self Color
--- @param s float
function Color.saturation_is_above(self, s)
	return self.s >= s
end

--- Returns true if saturation is betwen two given saturations.
---
--- @param self Color
--- @param lower_bound float
--- @param upper_bound float
function Color.saturation_is_between(self, lower_bound, upper_bound)
	return self.s >= lower_bound and self.s <= upper_bound
end

--- Set the lightness of the color.
---
--- @param self Color
--- @param l float
function Color.set_lightness(self, l)
	if (l < 0) then
		l = 0
	elseif (l > 1) then
		l = 1
	end

	self.l = l

	update_rgb_space(self)
end

--- Shift the lightness of the color within a given amount.
---
--- Use negative numbers to decrease lightness.
---
--- @param self Color
--- @param amount float
function Color.shift_lightness(self, amount)
	local l = math.min(1, math.max(0, self.l + amount))

	self.l = l

	update_rgb_space(self)
end

--- Shift the lightness of the color by a given amount, but keep within an upper and lower lightness bound.
-----
----- Use negative numbers to decrease lightness.
---
--- @param self Color
--- @param amount float
function Color.shift_lightness_within(self, amount, lower_bound, upper_bound)
	local l = self.l + amount

	if (l < lower_bound) then
		l = lower_bound
	elseif (l > upper_bound) then
		l = upper_bound
	end

	self.l = l

	update_rgb_space(self)
end

--- Returns true if lightness is below or equal to a given lightness.
---
--- @param self Color
--- @param l float
function Color.lightness_is_below(self, l)
	return self.l <= l
end

--- Returns true if lightness is above or equal to a given lightness.
---
--- @param self Color
--- @param l float
function Color.lightness_is_above(self, l)
	return self.l >= l
end

--- Returns true if lightness is betwen two given lightnesses.
---
--- @param self Color
--- @param lower_bound float
--- @param upper_bound float
function Color.lightness_is_between(self, lower_bound, upper_bound)
	return self.l >= lower_bound and self.l <= upper_bound
end

--- Sets the alpha of the color.
---
--- @param self Color
--- @param alpha int
--- @since 1.1.0-release
function Color.set_alpha(self, alpha)
	self.a = alpha

	validate_rgba(self)
end

--- Returns true if the color is truely invisible (0 alpha).
---
--- @param self Color
function Color.is_invisible(self)
	return self.a == 0
end

--- Returns true if the color is invisible to within a given tolerance (0-255 alpha).
---
--- @param self Color
--- @param tolerance int
function Color.is_invisible_within(self, tolerance)
	return self.a <= 0 + tolerance
end

--- Returns true if the color is truely visible (255 alpha).
---
--- @param self Color
function Color.is_visible(self)
	return self.a == 255
end

--- Returns true if the color is visible to within a given tolerance (0-255 alpha).
---
--- @param self Color
--- @param tolerance int
function Color.is_visible_within(self, tolerance)
	return self.a >= 255 - tolerance
end

--- Increase the alpha of the color by a given amount.
---
--- @param self Color
--- @param amount int
function Color.fade_in(self, amount)
	if (self.a == 255) then
		return
	end

	self.a = self.a + amount

	if (self.a > 255) then
		self.a = 255
	end
end

--- Decrease the alpha of the color by a given amount.
---
--- @param self Color
--- @param amount int
function Color.fade_out(self, amount)
	if (self.a == 0) then
		return
	end

	self.a = self.a - amount

	if (self.a < 0) then
		self.a = 0
	end
end
--endregion
--endregion
--endregion

--region globals
local health_hue_offset = 0.05
local health_green_hue = 0.28 + health_hue_offset
--endregion

--region ui
if (script_menu_location ~= "a" and script_menu_location ~= "b") then
	script_menu_location = "a"
end

local ui_enable_plugin = ui.new_checkbox(
	"lua",
	script_menu_location,
	"Enable Havoc Health ESP"
)

local ui_enable_hp_text = ui.new_checkbox(
	"lua",
	script_menu_location,
	"|   Health Text"
)

local ui_enable_hp_bar = ui.new_checkbox(
	"lua",
	script_menu_location,
	"|   Health Bar"
)

local ui_enable_hp_gradient = ui.new_checkbox(
	"lua",
	script_menu_location,
	"|   Health Gradient"
)

local ui_hp_gradient_alpha = ui.new_slider(
	"lua",
	script_menu_location,
	"|      Health Gradient Opacity",
	10,
	255,
	50
)

local function handle_ui()
	local menu_visible = ui.get(ui_enable_plugin)

	ui.set_visible(ui_enable_hp_text, menu_visible)
	ui.set_visible(ui_enable_hp_bar, menu_visible)
	ui.set_visible(ui_enable_hp_gradient, menu_visible)

	local hp_gradient_enabled = ui.get(ui_enable_hp_gradient)

	ui.set_visible(ui_hp_gradient_alpha, menu_visible and hp_gradient_enabled)
end
--endregion

--region hooks
local player_healths = {}

client.set_event_callback("paint", function()
	if (ui.get(ui_enable_plugin) == false) then
		return
	end

	local local_player = entity.get_local_player()
	local observer_mode = entity.get_prop(local_player, "m_iObserverMode")
	local active_players = {}

	if (observer_mode == 0 or observer_mode == 1 or observer_mode == 2 or observer_mode == 6) then
		active_players = entity.get_players(true)
	elseif (observer_mode == 4 or observer_mode == 5) then
		local all_players = entity.get_players()
		local observer_target = entity.get_prop(local_player, "m_hObserverTarget")
		local observer_target_team = entity.get_prop(observer_target, "m_iTeamNum")

		for test_player = 1, #all_players do
			if (
				observer_target_team ~= entity.get_prop(all_players[test_player], "m_iTeamNum") and
				all_players[test_player ] ~= local_player
			) then
				table.insert(active_players, all_players[test_player])
			end
		end
	end

	for i = 1, #active_players do
		local player = active_players[i]
		local box_top_x, box_top_y, box_bottom_x, box_bottom_y, box_alpha = entity.get_bounding_box(player)

		if (box_top_x ~= nil or box_top_y ~= nil or box_bottom_x ~= nil or box_bottom_y ~= nil or box_alpha ~= 0) then
			local health_width = box_bottom_x - box_top_x
			local health_height = box_bottom_y - box_top_y

			local health_color = Color.new_hsla(health_green_hue, 1, 0.56, ui.get(ui_hp_gradient_alpha))
			local player_health = entity.get_prop(player, "m_iHealth")

			local factor = 1 - (100 - player_health) / 100
			local hue = math.max(0, factor * health_green_hue - health_hue_offset)

			health_color:set_hue(hue)

			if (ui.get(ui_enable_hp_gradient) == true) then
				renderer.gradient(
					box_top_x,
					box_top_y,
					health_width,
					health_height,

					health_color.r,
					health_color.g,
					health_color.b,
					1,

					health_color.r,
					health_color.g,
					health_color.b,
					health_color.a,
					false
				)
			end

			if (ui.get(ui_enable_hp_bar) == true) then
				if (player_healths[player] == nil) then
					player_healths[player] = player_health
				end

				if (player_healths[player] > player_health) then
					factor = 1 - (100 - player_healths[player] - 0.45) / 100
					player_healths[player] = player_healths[player] - 0.45
				else
					player_healths[player] = player_health
				end

				local health_bar_x = box_top_x - 5
				local health_bar_height = box_bottom_y - health_height * factor

				renderer.gradient(
					health_bar_x,
					box_top_y,
					2,
					health_height,
					health_color.r,
					health_color.g,
					health_color.b,
					1,
					health_color.r,
					health_color.g,
					health_color.b,
					50,
					false
				)

				renderer.gradient(
					box_top_x - 5,
					health_bar_height,
					2,
					math.floor(health_height * factor),
					health_color.r,
					health_color.g,
					health_color.b,
					75,
					health_color.r,
					health_color.g,
					health_color.b,
					255,
					false
				)
			end

			if (ui.get(ui_enable_hp_text) == true) then
				renderer.text(
					box_top_x - 3,
					box_bottom_y,
					health_color.r,
					health_color.g,
					health_color.b,
					255,
					"r",
					0,
					player_health
				)
			end
		end
	end
end)

ui.set_callback(ui_enable_plugin, handle_ui)
ui.set_callback(ui_enable_hp_gradient, handle_ui)
--endregion

--region overrides
handle_ui()
--endregion