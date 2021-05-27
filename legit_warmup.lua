local check = ui.new_checkbox("Rage", "Other", "Anti-warmup rage")
local rage_ref = ui.reference("RAGE", "Aimbot", "Enabled")
local aa_ref = ui.reference("AA", "Anti-aimbot angles", "Enabled")
local fakelag_ref = ui.reference("AA", "Fake lag", "Enabled")
local rage = false
local aa = false
local fakelag = false

local function reset()
	local warmup = entity.get_prop(entity.get_game_rules(), "m_bWarmupPeriod");
	
	if warmup ~= 1 then
		if rage then
			if entity.get_local_player() and warmup then
				ui.set(rage_ref, true)
				rage = false
				client.unset_event_callback("paint_ui", reset)
			elseif entity.get_local_player() == nil and warmup == nil then
				ui.set(rage_ref, true)
				rage = false
				client.unset_event_callback("paint_ui", reset)
			end
		end
		if aa then
			if entity.get_local_player() and warmup then
				ui.set(aa_ref, true)
				aa = false
				client.unset_event_callback("paint_ui", reset)
			elseif entity.get_local_player() == nil and warmup == nil then
				ui.set(aa_ref, true)
				aa = false
				client.unset_event_callback("paint_ui", reset)
			end
		end
		if fakelag then
			if entity.get_local_player() and warmup then
				ui.set(fakelag_ref, true)
				fakelag = false
				client.unset_event_callback("paint_ui", reset)
			elseif entity.get_local_player() == nil and warmup == nil then
				ui.set(fakelag_ref, true)
				fakelag = false
				client.unset_event_callback("paint_ui", reset)
			end
		end
		
		if entity.get_local_player() and warmup then
			client.unset_event_callback("paint_ui", reset)
		end
	end
end

local function warmup_func()
	if ui.get(check) then
		local warmup = entity.get_prop(entity.get_game_rules(), "m_bWarmupPeriod");
		local valveDS = entity.get_prop(entity.get_game_rules(), "m_bIsValveDS");
		client.set_event_callback("player_spawn", warmup_func)
		client.set_event_callback("net_update_end", warmup_func)
		client.set_event_callback("paint_ui", reset)
		if warmup >= 1 and valveDS == 1 then
			if ui.get(rage_ref) then
				ui.set(rage_ref, false)
				rage = true
			end
			if ui.get(aa_ref) then
				ui.set(aa_ref, false)
				aa = true
			end
			if ui.get(fakelag_ref) then
				ui.set(fakelag_ref, false)
				fakelag = true
			end
		else
			client.unset_event_callback("player_spawn", warmup_func)
			client.unset_event_callback("net_update_end", warmup_func)
			reset()
		end
	else
		reset()
	end
end

client.set_event_callback("post_config_load", function()
	rage = false
	aa = false
	fakelag = false
end)

warmup_func()
client.set_event_callback("player_connect_full", warmup_func)
client.set_event_callback("round_prestart", warmup_func)