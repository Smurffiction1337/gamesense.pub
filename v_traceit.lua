-- local variables for API functions. any changes to the line below will be lost on re-generation
local client_eye_position, client_screen_size, client_set_event_callback, client_trace_bullet, client_trace_line, entity_get_local_player, entity_get_players, entity_hitbox_position, renderer_line, renderer_world_to_screen, ui_get, ui_new_checkbox, ui_new_multiselect, ui_new_color_picker, ui_new_combobox, ui_new_slider, ui_reference, ui_set_callback, ui_set_visible, ipairs, entity_get_prop, math_sqrt, math_abs, math_min, math_max = client.eye_position, client.screen_size, client.set_event_callback, client.trace_bullet, client.trace_line, entity.get_local_player, entity.get_players, entity.hitbox_position, renderer.line, renderer.world_to_screen, ui.get, ui.new_checkbox, ui.new_multiselect, ui.new_color_picker, ui.new_combobox, ui.new_slider, ui.reference, ui.set_callback, ui.set_visible, ipairs, entity.get_prop, math.sqrt, math.abs, math.min, math.max

local teammates = ui_reference("VISUALS", "Player ESP", "Teammates")
local menu_enabled = ui_new_checkbox("VISUALS", "Player ESP", "Player Tracers")

local menu_color_hit = ui_new_color_picker("VISUALS", "Player ESP", "Color Hit", 0, 255, 0, 255)

local hitboxes = {
    "Head",
    "Neck",
    "Pelvis",
    "Spine 0",
    "Spine 1",
    "Spine 2",
    "Spine 3",
    "Upper Left Leg",
    "Upper Right Leg",
    "Lower Left Leg",
    "Lower Right Leg",
    "Left Ankle",
    "Right Ankle",
    "Left Hand",
    "Right Hand",
    "Upper Left Arm",
    "Lower Left Arm",
    "Upper Right Arm",
    "Lower Right Arm"
}

local menu_hitbox_tracers = ui_new_multiselect("VISUALS", "Player ESP", "Hitbox", hitboxes)

local menu_only_closest = ui_new_checkbox("VISUALS", "Player ESP", "Only closest")

local menu_visibility_check = ui_new_combobox("VISUALS", "Player ESP", "Tracer check", "None", "Damage", "Visible")
local menu_color_miss = ui_new_color_picker("VISUALS", "Player ESP", "Color Miss", 255, 0, 0, 255)

local menu_damage_threshold = ui_new_slider("VISUALS", "Player ESP", "Damage Threshold", 1, 100, 1, true, "", 1, {[1] = "Can hit", [100] = "HP"})

local menu_distance_calculations = ui_new_combobox("VISUALS", "Player ESP", "Fade mode", "None", "Near crosshair", "Distance")
local menu_distance_factor = ui_new_slider("VISUALS", "Player ESP", "Distance factor", 1, 5, 1, true)

local function handleUI()
    local enabled = ui_get(menu_enabled)
    ui_set_visible(menu_color_hit, enabled)
    ui_set_visible(menu_hitbox_tracers, enabled)
    if ((#ui_get(menu_hitbox_tracers)) > 1) then
        ui_set_visible(menu_only_closest, enabled)
    else
        ui_set_visible(menu_only_closest, false)
    end
    ui_set_visible(menu_visibility_check, enabled)
    ui_set_visible(menu_distance_calculations, enabled)
    if ui_get(menu_visibility_check) ~= "None" then
        ui_set_visible(menu_color_miss, enabled)
    else
        ui_set_visible(menu_color_miss, false)
    end
    if ui_get(menu_visibility_check) == "Damage" then
        ui_set_visible(menu_damage_threshold, enabled)
    else
        ui_set_visible(menu_damage_threshold, false)
    end
    if ui_get(menu_distance_calculations) ~= "None" then
        ui_set_visible(menu_distance_factor, enabled)
    else
        ui_set_visible(menu_distance_factor, false)
    end
end

ui_set_callback(menu_enabled, handleUI)
ui_set_callback(menu_hitbox_tracers, handleUI)
ui_set_callback(menu_visibility_check, handleUI)
ui_set_callback(menu_distance_calculations, handleUI)

handleUI() --call handleUI to not fuck up when reloading cfg/luas

function indexIn(t,val)
    for k,v in ipairs(t) do 
        if v == val then return k end
    end
end

--distance functions
local function distance2d(x1, y1, x2, y2)
    local x, y = math_abs(x1-x2), math_abs(y1-y2)
    return math_sqrt(x*x+y*y)
end

local function distance3d(x1, y1, z1, x2, y2, z2)
    local x, y, z = math_abs(x1-x2), math_abs(y1-y2), math_abs(z1-z2)
    return math_sqrt(x*x+y*y+z*z)
end

client_set_event_callback("paint", function(ctx)
    if not ui_get(menu_enabled) then return end
    local players = entity_get_players(not ui_get(teammates))
    if #players == nil then return end

    local me = entity_get_local_player()

    local vis_type = ui_get(menu_visibility_check)
    local dist_type = ui_get(menu_distance_calculations)
    local dist_factor = ui_get(menu_distance_factor)
    local closest_only = ui_get(menu_only_closest)

    local trace_hitboxes = ui_get(menu_hitbox_tracers)

    for i = 1, #players do 
        if players[i] ~= me then
            local player_lines = {}
            local last_dist = math.huge
            for n = 1, #trace_hitboxes do
                local hbox_x, hbox_y, hbox_z = entity_hitbox_position(players[i], indexIn(hitboxes, trace_hitboxes[n])-1)
                local me_x, me_y, me_z = client_eye_position()

                local hit = false

                if vis_type == "Damage" then
                    local entindex, damage = client_trace_bullet(me, me_x, me_y, me_z, hbox_x, hbox_y, hbox_z)
                    local min_damage = ui_get(menu_damage_threshold)
                    if min_damage == 100 then
                        min_damage = entity_get_prop(players[i], "m_iHealth")
                    end

                    if damage >= min_damage and entindex == players[i] then
                        hit = true
                    end
                elseif vis_type == "Visible" then
                    local fraction, entindex = client_trace_line(me, me_x, me_y, me_z, hbox_x, hbox_y, hbox_z)
                    if entindex == players[i] then 
                        hit = true
                    end
                else
                    hit = true
                end

                local r, g, b, a = 0, 0, 0, 0
                if hit then
                    r, g, b, a = ui_get(menu_color_hit)
                else
                    r, g, b, a = ui_get(menu_color_miss)
                end

                local xa, ya = renderer_world_to_screen(hbox_x, hbox_y, hbox_z)
                if xa ~= nil then
                    local w, h = client_screen_size()

                    if dist_type == "Near crosshair" then
                        local distance = distance2d(w/2, h/2, xa, ya)
                        local distance_delta = distance - 25*dist_factor
                        local max_fade_delta = 150*dist_factor - 25*dist_factor
                        local new_a = math_max(0, math_min(a, (a * (distance_delta / max_fade_delta))))
                        a = new_a
                    elseif dist_type == "Distance" then
                        -- calculate 3d distance between you and the current player, and fade the line depending on the distance
                        local distance = distance3d(me_x, me_y, me_z, hbox_x, hbox_y, hbox_z)
                        local new_a = math_max(0, ((300*dist_factor) - distance) / (300*dist_factor)) * a
                        a = new_a
                    end

                    if closest_only then
                        local cur_dist = distance2d(w/2, h/2, xa, ya)
                        if last_dist > cur_dist and hit then
                            player_lines[1] = {w/2, h/2, xa, ya, r, g, b, a}
                            last_dist = cur_dist
                        end
                    else
                        player_lines[#player_lines+1] = {w/2, h/2, xa, ya, r, g, b, a}
                    end
                end
            end

            for i = 1, #player_lines do
                renderer_line(player_lines[i][1], player_lines[i][2], player_lines[i][3], player_lines[i][4], player_lines[i][5], player_lines[i][6], player_lines[i][7], player_lines[i][8])
            end
        end
    end
end)