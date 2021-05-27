----------------------------------------------------------------------------------------------------------
--                                                                                                       --
--                    		  				Beutified Indicators       		                        	 --
--                          				  by Smurffiction                            				 --
--                                                                                                       --
-----------------------------------------------------------------------------------------------------------

local i_on = ui.new_checkbox("LUA", "A", "Enable 187 Indicators")
local mindmgref = ui.reference("Rage", "Aimbot", "Minimum damage")
local laglimitref = ui.reference("AA", "Fake lag", "Limit")
local hcref = ui.reference("Rage", "Aimbot", "Minimum hit chance")
local fakeduck, fakeduck_key = ui.reference("Rage", "Other", "Duck peek assist")
local quickpeek, quickpeek_key = ui.reference("Rage", "Other", "quick peek assist")
local doubletap, doubletap_key = ui.reference("Rage", "Other", "Double tap")
local onshot, onshot_key = ui.reference("AA", "Other", "On shot anti-aim")
local slowref, hk_slowref = ui.reference("AA", "Other", "Slow motion")

local textcolor = ui.new_color_picker("LUA", "A", 255, 255, 255, 255)
local xpos = ui.new_slider("LUA", "A", "X Position", -600, 600, 138, true, "px", 1)
local ypos = ui.new_slider("LUA", "A", "Y Position", -25, 32, -1, true, "px", 1)


client.set_event_callback("paint", function()
	if not ui.get(i_on) then return end

	if entity.get_local_player() == nil then
		return
	end

	local weap_classname = entity.get_classname(entity.get_player_weapon(entity.get_local_player()))
	if weap_classname == "CKnife" or weap_classname == "CSmokeGrenade" or weap_classname == "CFlashbang" or weap_classname == "CHEGrenade" or weap_classname == "CDecoyGrenade" or weap_classname == "CIncendiaryGrenade"  then
		return
	end

	local screenX, screenY = client.screen_size()
	local xPos = screenX / 2 + 1 * ui.get(xpos)
	local yPos = screenY / 2 + 20 - 15 * ui.get(ypos)
	local eyeX, eyeY, eyeZ = client.eye_position()
	local pitch, yaw = client.camera_angles()
	local ent_exists = false
	local wall_dmg = 0
	local sin_pitch = math.sin(math.rad(pitch))
	local cos_pitch = math.cos(math.rad(pitch))
	local sin_yaw = math.sin(math.rad(yaw))
	local cos_yaw = math.cos(math.rad(yaw))
	local dirVector = { cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch }
	local fraction, entindex = client.trace_line(entity.get_local_player(), eyeX, eyeY, eyeZ, eyeX + (dirVector[1] * 8192), eyeY + (dirVector[2] * 8192), eyeZ + (dirVector[3] * 8192))
	local r, g, b, a = ui.get(textcolor)
	local mindmg = ui.get(mindmgref)
	local laglimit = ui.get(laglimitref)
	local hc = ui.get(hcref)


	if fraction < 1 then
		local entindex_1, dmg = client.trace_bullet(entity.get_local_player(), eyeX, eyeY, eyeZ, eyeX + (dirVector[1] * (8192 * fraction + 128)), eyeY + (dirVector[2] * (8192 * fraction + 128)), eyeZ + (dirVector[3] * (8192 * fraction + 128)))

		if entindex_1 ~= nil then
			ent_exists = true
		end

		if wall_dmg < dmg then
			wall_dmg = dmg
		end
	end

			renderer.text(xPos, yPos, 102, 222, 75, a, "cbd", 0, "DMG: ", mindmg)
			renderer.text(xPos, yPos + 12, 230, 25, 117, a, "cbd", 0, "BANG: ", wall_dmg)
			renderer.text(xPos, yPos + 24, 95, 75, 222, a, "cbd", 0, "LAG: ", laglimit)
			renderer.text(xPos, yPos + 36, 95, 75, 222, a, "cbd", 0, "HC: ", hc)

                             	      if ui.get(fakeduck) then
                                        renderer.text(xPos, yPos + 50, 245, 197, 66, a, "cbd", nil, " DUCK ")
                                    else
                                        renderer.text(xPos, yPos + 50, 245, 197, 66, a, "cbd", nil, "      ")
                                    end

                                    if ui.get(doubletap, true) and ui.get(doubletap_key) then
                                        renderer.text(xPos, yPos + 61, 245, 197, 66, a, "cbd", nil, " DT ")
                                    else
                                        renderer.text(xPos, yPos + 61, 245, 197, 66, a, "cbd", nil, " ")
                                    end
			      
                                    if ui.get(quickpeek_key) then
				renderer.text(xPos, yPos + 72, 245, 197, 66, a, "cbd", nil, " PEEK ")
			      else
				renderer.text(xPos, yPos + 72, 245, 197, 66, a, "cbd", nil, "      ")
			      end

                                    if ui.get(onshot_key) then
				renderer.text(xPos, yPos + 83, 245, 197, 66, a, "cbd", nil, " ONSHOT ")
                                    else
				renderer.text(xPos, yPos + 83, 245, 197, 66, a, "cbd", nil, " ")
			      end

			      if ui.get(hk_slowref) then
				renderer.text(xPos, yPos + 94, 32, 41, 135, a, "cbd", nil, " SLOW MOTION ")
                                    else
				renderer.text(xPos, yPos + 94, 32, 41, 135, a, "cbd", nil, " ")
			      end
end)