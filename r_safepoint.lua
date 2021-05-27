local client_set_event_callback, client_unset_event_callback, client_userid_to_entindex, client_register_esp_flag, entity_get_players, entity_is_enemy, globals_tickcount, globals_tickinterval, plist_set, plist_get, ui_get, ui_new_checkbox, ui_new_slider, ui_new_color_picker, ui_set_callback, ui_set_visible = client.set_event_callback, client.unset_event_callback, client.userid_to_entindex, client.register_esp_flag, entity.get_players, entity.is_enemy, globals.tickcount, globals.tickinterval, plist.set, plist.get, ui.get, ui.new_checkbox, ui.new_slider, ui.new_color_picker, ui.set_callback, ui.set_visible

local master_switch = ui_new_checkbox("Rage", "Other", "Enable Safe Point after X misses")
local max_misses    = ui_new_slider("Rage", "Other", "- Misses to enable Safe Point", 1, 5, 2)
local reset_time    = ui_new_slider("Rage", "Other", "- Seconds to reset misses", 5, 15, 10)

local esp_flag      = ui_new_checkbox("Rage", "Other", "- Add 'SAFE' flag to ESP")

ui_set_visible(max_misses, false)
ui_set_visible(reset_time, false)
ui_set_visible(esp_flag, false)

local shot_data = {}

local function on_aim_miss(e)
    if not ui_get(master_switch) then return end

    if e.reason ~= "?" then return end

    local entindex  = e.target
    local data      = {}

    if shot_data[entindex] == nil then
        data.tickcount  = globals_tickcount()
        data.misses     = 0

        shot_data[entindex] = data
    end

    data.tickcount  = globals_tickcount()
    data.misses     = shot_data[entindex].misses + 1

    shot_data[entindex] = data

    if shot_data[entindex].misses >= ui_get(max_misses) then
        plist_set(entindex, "Override safe point", "On")
    end
end

local function on_run_command(e)
    if not ui_get(master_switch) then return end

    if shot_data == nil then return end
    
    local current_tickcount = globals_tickcount()
    local players           = entity_get_players(true)

    for i = 1, #players do
        local entindex = players[i]

        if shot_data[entindex] == nil then return end

        local miss_tickcount    = shot_data[entindex].tickcount
        local delta             = current_tickcount - miss_tickcount
        local time_elapsed      = delta * globals_tickinterval()

        if time_elapsed >= ui_get(reset_time) then
            plist_set(entindex, "Override safe point", "-")

            shot_data[entindex] = nil
        end
    end
end

local function on_player_death(e)
    if not ui_get(master_switch) then return end

    if shot_data == nil then return end

    local entindex = client_userid_to_entindex(e.userid)
    
    if not entity_is_enemy(entindex) then return end

    plist_set(entindex, "Override safe point", "-")

    shot_data[entindex] = nil
end

local function on_round_prestart()
    if not ui_get(master_switch) then return end

    if shot_data == nil then return end

    local players = entity_get_players(true)

    for i = 1, #players do
        local entindex = players[i]

        if shot_data[entindex] == nil then return end

        plist_set(entindex, "Override safe point", "-")

        shot_data[entindex] = nil
    end
end

client_register_esp_flag("SAFE", 255, 0, 0, function(player)
    if not ui_get(master_switch) then return false end

    if not ui_get(esp_flag) then return false end

    return plist_get(player, "Override safe point") == "On"
end)


ui_set_callback(master_switch, function()
    local enabled = ui_get(master_switch)
    local update_callback = enabled and client_set_event_callback or client_unset_event_callback

    update_callback("aim_miss", on_aim_miss)
    update_callback("run_command", on_run_command)
    update_callback("player_death", on_player_death)
    update_callback("round_prestart", on_round_prestart)

    ui_set_visible(max_misses, enabled)
    ui_set_visible(reset_time, enabled)
    ui_set_visible(esp_flag, enabled)
end)