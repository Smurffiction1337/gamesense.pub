local vector = require "vector"

-- >> local variables

_ = ui.new_label( "LUA", "A", " " )
_ = ui.new_label( "LUA", "A", " " )

local aind = {
    enabled = ui.new_multiselect("lua", "a", "Angle indicator", "Default circle", "Real", "Fake", "LBY"),
    rad = ui.new_slider("lua", "a", "Radius", 5, 35, 10),
    circle_acc = ui.new_slider("lua", "a", "Circle accuracy", 1, 30, 1, true, "", 0.1),
    d_lbl = ui.new_label("lua", "a", "Default circle color"),
    d_clr = ui.new_color_picker("lua", "a", "d_clr_22", 30, 30, 30, 255),
    r_lbl = ui.new_label("lua", "a", "Real color"),
    r_clr = ui.new_color_picker("lua", "a", "r_clr_22", 255, 255, 255, 255),
    f_lbl = ui.new_label("lua", "a", "Fake color"),
    f_clr = ui.new_color_picker("lua", "a", "f_clr_22", 255, 0, 0, 255),
    l_lbl = ui.new_label("lua", "a", "LBY color"),
    l_clr = ui.new_color_picker("lua", "a", "l_clr_22", 0, 150, 255, 255),
    diff_ren = ui.new_checkbox("lua", "a", "3D render in TP")
}
local w, h = client.screen_size()

_ = ui.new_label( "LUA", "A", " " )

-- >> local functions
local function draw_circle_3d(x, y, z, radius, degrees, start_at, r, g, b, a)
	local accuracy = ui.get(aind.circle_acc)/10
    local old = { x, y }
	for rot=start_at, degrees+start_at, accuracy do
		local rot_t = math.rad(rot)
		local line_ = vector(radius * math.cos(rot_t) + x, radius * math.sin(rot_t) + y, z)
        local current = { x, y }
        current.x, current.y = renderer.world_to_screen(line_.x, line_.y, line_.z)
		if current.x ~=nil and old.x ~= nil then
			renderer.line(current.x, current.y, old.x, old.y, r, g, b, a)
		end
		old.x, old.y = current.x, current.y
	end
end

local function is_thirdperson()
	local x, y, z = client.eye_position()
	local pitch, yaw = client.camera_angles()
	yaw = yaw - 180
	pitch, yaw = math.rad(pitch), math.rad(yaw)
    x = x + math.cos(yaw)*4
	y = y + math.sin(yaw)*4
	z = z + math.sin(pitch)*4
	local wx, wy = renderer.world_to_screen(x, y, z)
	return wx ~= nil
end

-- >> callbacks
local function on_paint()
    if entity.get_local_player() == nil or entity.is_alive(entity.get_local_player()) == false then return end
    local lp_pos = vector(entity.get_origin(entity.get_local_player()))
    local _, head_rot = entity.get_prop(entity.get_local_player(), "m_angAbsRotation");local _, fake_rot = entity.get_prop(entity.get_local_player(), "m_angEyeAngles");local lby_rot = entity.get_prop(entity.get_local_player(), "m_flLowerBodyYawTarget");local _, cam_rot = client.camera_angles()
    local c3d = { degrees=50, start_at=head_rot, start_at2=fake_rot, start_at3=lby_rot }
    local options = ui.get(aind.enabled);local radius_ = ui.get(aind.rad);local r_clr, f_clr, d_clr, l_clr = {ui.get(aind.r_clr)}, {ui.get(aind.f_clr)}, {ui.get(aind.d_clr)}, {ui.get(aind.l_clr)}

    for i=1, #options do
        opt = options[i]
        if opt == "Default circle" then
            if ui.get(aind.diff_ren) then
                if is_thirdperson() then
                    draw_circle_3d(lp_pos.x, lp_pos.y, lp_pos.z, radius_+2*i, 360, 0, d_clr[1], d_clr[2], d_clr[3], d_clr[4])
                else
                    renderer.circle_outline(w/2, h/2, d_clr[1], d_clr[2], d_clr[3], d_clr[4], radius_*2+4*i, 0, 1, 1)
                end
            else
                renderer.circle_outline(w/2, h/2, d_clr[1], d_clr[2], d_clr[3], d_clr[4], radius_*2+4*i, 0, 1, 1)
            end
        elseif opt == "Real" then
            if ui.get(aind.diff_ren) then
                if is_thirdperson() then
                    draw_circle_3d(lp_pos.x, lp_pos.y, lp_pos.z, radius_+2*i, c3d.degrees, c3d.start_at, r_clr[1], r_clr[2], r_clr[3], r_clr[4])
                else
                    c3d.start_at = cam_rot-c3d.start_at-120
                    renderer.circle_outline(w/2, h/2, r_clr[1], r_clr[2], r_clr[3], r_clr[4], radius_*2+4*i, c3d.start_at, 0.2, 1)
                end
            else
                c3d.start_at = cam_rot-c3d.start_at-120
                renderer.circle_outline(w/2, h/2, r_clr[1], r_clr[2], r_clr[3], r_clr[4], radius_*2+4*i, c3d.start_at, 0.2, 1)
            end
        elseif opt == "Fake" then
            if ui.get(aind.diff_ren) then
                if is_thirdperson() then
                    draw_circle_3d(lp_pos.x, lp_pos.y, lp_pos.z, radius_+2*i, c3d.degrees, c3d.start_at2, f_clr[1], f_clr[2], f_clr[3], f_clr[4])
                else
                    c3d.start_at2 = cam_rot-c3d.start_at2-120
                    renderer.circle_outline(w/2, h/2, f_clr[1], f_clr[2], f_clr[3], f_clr[4], radius_*2+4*i, c3d.start_at2, 0.2, 1)
                end
            else
                c3d.start_at2 = cam_rot-c3d.start_at2-120
                renderer.circle_outline(w/2, h/2, f_clr[1], f_clr[2], f_clr[3], f_clr[4], radius_*2+4*i, c3d.start_at2, 0.2, 1)
            end
        elseif opt == "LBY" then
            if ui.get(aind.diff_ren) then
                if is_thirdperson() then
                    draw_circle_3d(lp_pos.x, lp_pos.y, lp_pos.z, radius_+2*i, c3d.degrees, c3d.start_at3, l_clr[1], l_clr[2], l_clr[3], l_clr[4])
                else
                    c3d.start_at3 = cam_rot-c3d.start_at3-120
                    renderer.circle_outline(w/2, h/2, l_clr[1], l_clr[2], l_clr[3], l_clr[4], radius_*2+4*i, c3d.start_at3, 0.2, 1)
                end
            else
                c3d.start_at3 = cam_rot-c3d.start_at3-120
                renderer.circle_outline(w/2, h/2, l_clr[1], l_clr[2], l_clr[3], l_clr[4], radius_*2+4*i, c3d.start_at3, 0.2, 1)
            end
        end
    end
end
client.set_event_callback("paint", on_paint)

_ = ui.new_label( "LUA", "A", " " )
_ = ui.new_label( "LUA", "A", " " )
