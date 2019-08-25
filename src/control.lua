--control.lua

require("mod-gui")

--
--   [ROADMAP]
--
-- 1.1:
-- [ ] Add an optional tech unlock
-- [ ] Add a player setting for showing/hiding the hover info?
--
-- TBD:
-- [ ] Append channel editor/viewer to existing vanilla GUIs (waiting on mod API support)
-- [ ] Sync channel force relationships to base force on relationship change events instead of periodically (waiting
--     on mod API support)
--

function get_editor_gui(player)
	local parent = mod_gui.get_frame_flow(player)
	if not parent.logiNetChannelEditor then
		local editor = mod_gui.get_frame_flow(player).add{
			type="frame",
			name="logiNetChannelEditor",
			caption="Logistic Network Channel",
			direction="horizontal"
		}
		editor.visible = false;
		
		editor.add{
			type="flow",
			name="flow",
			caption="Logistic Network Channel",
			direction="horizontal"
		}
		editor.flow.style.horizontal_spacing = 12;
		
		local channelLimit = settings.global["logiNetChannelLimit"].value
		editor.flow.add{
			type="label",
			name="channelLabel",
			caption="0"
		}
		editor.flow.channelLabel.style.font = "default-large-semibold"
		editor.flow.add{
			type="slider",
			name="channelSlider",
			minimum_value=0,
			maximum_value=(channelLimit-1),
			value_step=1,
			discrete_slider=true,
			discrete_values=true
		}
	end
	return parent.logiNetChannelEditor
end

function is_multichannel()
    local channelLimit = global.channelLimit
	return channelLimit and channelLimit > 1
end

function is_editable_entity(entity)
	return entity and (entity.logistic_network or #entity.get_logistic_point() > 0)
end

function get_hover_gui(player)
	local parent = mod_gui.get_frame_flow(player)
	if not parent.logiNetChannelHover then
		local hover = mod_gui.get_frame_flow(player).add{
			type="label",
			name="logiNetChannelHover",
			caption="Logistic Network Channel",
		}
	end
	return parent.logiNetChannelHover
end

function update_hover_gui(player)
	local hover = get_hover_gui(player)
	local editor = get_editor_gui(player)
    
	if is_multichannel() and not editor.visible and is_editable_entity(player.selected) then
		hover.caption = "Logistic Network Channel: "..get_channel(player.selected)
		hover.visible = true
	else
		hover.visible = false
	end
end

function get_channel_force(base_force, channel)
	if not channel or channel == 0 then
		return base_force
	else
		local channel_force_name = base_force.name .. ".channel." .. channel
		if not game.forces[channel_force_name] then
			local channel_force = game.create_force(channel_force_name)
			channel_force.set_friend(base_force, true)
			channel_force.set_cease_fire(base_force, true)
			base_force.set_friend(channel_force, true)
			base_force.set_cease_fire(channel_force, true)
		end
		return game.forces[channel_force_name]
	end
end

function parse_channel_forcename(force_name)
    local FORCE_REGEX = "(.+)%.channel%.(%d+)"
    local base_name, channel = string.match(force_name, FORCE_REGEX)
    return base_name, tonumber(channel)
end

function get_channel(entity)
	local _, channel = parse_channel_forcename(entity.force.name)
	return channel or 0
end

function set_channel(entity, channel)
	local base_name, _ = parse_channel_forcename(entity.force.name)
	base_name = base_name or entity.force.name
	
	local base_force = game.forces[base_name]
	if not base_force then
		-- TODO: do something better...
		game.print("Unable to find force: "..base_name)
		return
	end
	
	entity.force = get_channel_force(base_force, channel)
end

function syncChannelLimit()
	local currentLimit = global.channelLimit
	local newLimit = settings.global["logiNetChannelLimit"].value;
	
    game.print("[Logistic Network Channels] Channel limit changing from "..tostring(currentLimit).." to "..
        tostring(newLimit));
        
	if currentLimit and currentLimit > newLimit then
        local mergedForceCount = 0
		for name,force in pairs(game.forces) do
			local baseName, channel = parse_channel_forcename(name)
			if channel and channel >= newLimit then
				game.merge_forces(name, baseName)
                mergedForceCount = mergedForceCount + 1
			end
		end
        
        if mergedForceCount > 0 then
            game.print("[Logistic Network Channels] Warning!  Channel limit has been reduced, "..mergedForceCount..
                " channels above the new limit have been merged back into channel 0.")
        end
	end
    
    global.channelLimit = newLimit;
end

script.on_init(syncChannelLimit)
script.on_configuration_changed(
    function(data)
        -- game.print("on_configuration_changed: ".. serpent.block(data))
        syncChannelLimit()
    end
   )
script.on_event(defines.events.on_runtime_mod_setting_changed,
	function(event)
		if event.setting == "logiNetChannelLimit" then
            -- game.print("on_runtime_mod_setting_changed")
			syncChannelLimit()
		end
	end
)

script.on_event(defines.events.on_gui_value_changed,
	function(event)
		local player = game.get_player(event.player_index)
		local editor = get_editor_gui(player);
		if editor.flow.channelSlider == event.element then
			editor.flow.channelLabel.caption = editor.flow.channelSlider.slider_value
		end
	end
)

script.on_event(defines.events.on_gui_opened,
	function(event)
		local entity = event.entity
		if is_multichannel() and is_editable_entity(entity) then
			local player = game.get_player(event.player_index)
			local editor = get_editor_gui(player)
            local channel = get_channel(entity);
            
            editor.flow.channelSlider.set_slider_minimum_maximum(0, global.channelLimit - 1)
			editor.flow.channelSlider.slider_value = channel
			editor.flow.channelLabel.caption = channel
			editor.visible = true
			
			update_hover_gui(player)
		end
	end
)

script.on_event(defines.events.on_gui_closed,
	function(event)
        local entity = event.entity
		if is_multichannel() and is_editable_entity(entity) then
			local player = game.get_player(event.player_index)
			local editor = get_editor_gui(player);
			
			local channel = editor.flow.channelSlider.slider_value;
			set_channel(entity, channel)
			editor.visible = false
			
			update_hover_gui(player)
		end
	end
)

script.on_event(defines.events.on_entity_settings_pasted,
	function(event)
		local source = event.source;
		local destination = event.destination;
		if is_multichannel() and is_editable_entity(source) and is_editable_entity(destination)
		then
			local player = game.get_player(event.player_index)
			
			local channel = get_channel(source);
			set_channel(destination, channel)
			
			update_hover_gui(player)
		end
	end
)

script.on_event(defines.events.on_selected_entity_changed,
	function(event)
        if is_multichannel() then
            local player = game.get_player(event.player_index)
            local entity = player.selected
            update_hover_gui(player)
        end
	end
)


