local client_set_event_callback, client_unset_event_callback, entity_get_local_player, entity_hitbox_position, entity_is_alive, renderer_line, renderer_world_to_screen, ui_get, ui_new_checkbox, ui_reference = client.set_event_callback, client.unset_event_callback, entity.get_local_player, entity.hitbox_position, entity.is_alive, renderer.line, renderer.world_to_screen, ui.get, ui.new_checkbox, ui.reference

local thirdperson = { ui_reference("VISUALS", "Effects", "Force third person (alive)") }
local real_pos = ui_new_checkbox("LUA", "B", "[S] Show real position")

local hitboxes = {}

local function draw_line(pos1, pos2, r, g, b, a)
    if pos1[1] and pos2[1] then
        renderer_line(pos1[1], pos1[2], pos2[1], pos2[2], r, g, b, a)
    end
end

local function draw_skeleton(r, g, b, a)
	for i=1, #hitboxes do
		local v = hitboxes[i]
		if v[1] and v[2] and v[3] then
			hitboxes[i] = { renderer_world_to_screen( v[1], v[2], v[3] ) }
		end
	end

    draw_line(hitboxes[1], hitboxes[2], r, g, b, a)
    draw_line(hitboxes[2], hitboxes[7], r, g, b, a)
    draw_line(hitboxes[7], hitboxes[18], r, g, b, a)
    draw_line(hitboxes[7], hitboxes[16], r, g, b, a)
    draw_line(hitboxes[7], hitboxes[5], r, g, b, a)
    draw_line(hitboxes[5], hitboxes[3], r, g, b, a)

    -- waist
    draw_line(hitboxes[3], hitboxes[8], r, g, b, a)
    draw_line(hitboxes[3], hitboxes[9], r, g, b, a)

    -- left leg
    draw_line(hitboxes[8], hitboxes[10], r, g, b, a)
    draw_line(hitboxes[10], hitboxes[12], r, g, b, a)

    -- right leg
    draw_line(hitboxes[9], hitboxes[11], r, g, b, a)
    draw_line(hitboxes[11], hitboxes[13], r, g, b, a)

    -- left arm
    draw_line(hitboxes[18], hitboxes[19], r, g, b, a)
    draw_line(hitboxes[19], hitboxes[15], r, g, b, a)

    -- right arm
    draw_line(hitboxes[16], hitboxes[17], r, g, b, a)
    draw_line(hitboxes[17], hitboxes[14], r, g, b, a)
end

client_set_event_callback("net_update_end", function()
    local local_player = entity_get_local_player()
    hitboxes = {}

    for i=1, 19 do
        local wx, wy, wz = entity_hitbox_position(local_player, i-1)
        hitboxes[i] = {wx, wy, wz}
    end
end)

local function on_paint()
    if not ui_get(thirdperson[2]) then
        return
    end

    local local_player = entity_get_local_player()
    local alive = entity_is_alive(local_player)

    if not alive then
        return
    end
    
    draw_skeleton(255, 255, 255, 255)
end

ui.set_callback(real_pos, function()
    if ui_get(real_pos) then
        client_set_event_callback("paint", on_paint)
    else
        client_unset_event_callback("paint", on_paint)
    end
end)