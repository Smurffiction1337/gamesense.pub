local knife_lefthand = ui.new_checkbox("MISC", "Miscellaneous", "Switch Knife Hand")

local changed = false

client.set_event_callback("paint", function()
    if ui.get(knife_lefthand)  == false then return end
    local local_player = entity.get_local_player()
    if local_player == nil then return end
    local weapon = entity.get_player_weapon(local_player)

    if entity.get_classname(weapon) == "CKnife" then
        cvar.cl_righthand:set_raw_int(cvar.cl_righthand:get_string() == "0" and 1 or 0)
        changed = true
    elseif changed then
        cvar.cl_righthand:set_raw_int(tonumber(cvar.cl_righthand:get_string()))
        changed = false
    end
end)

client.set_event_callback("shutdown", function()
    if changed then
        cvar.cl_righthand:set_raw_int(tonumber(cvar.cl_righthand:get_string()))
    end
end)

ui.set_callback(knife_lefthand, function()
    if changed then
        cvar.cl_righthand:set_raw_int(tonumber(cvar.cl_righthand:get_string()))
    end
end)