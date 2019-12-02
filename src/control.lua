--control.lua

require("mod-gui")

function get_editor_gui(player)
	local parent = mod_gui.get_frame_flow(player)
	if not parent.logiNetChannelEditor then
		local editor = mod_gui.get_frame_flow(player).add{
			type="frame",
			name="logiNetChannelEditor",
			caption="Logistic Network Channel",
			direction="vertical"
		}
		editor.visible = false;
		
		local sliderRow = editor.add{ type="flow", name="sliderRow", caption="Slider Row", direction="horizontal" }
		sliderRow.style.horizontal_spacing = 12;
		
		sliderRow.add{ type="label", name="label", caption="0" }
		sliderRow.label.style.font = "default-large-semibold"
        
        local channelLimit = settings.global["logiNetChannelLimit"].value
		sliderRow.add{
			type="slider", name="slider",
			minimum_value=0, maximum_value=(channelLimit-1), value_step=1,
			discrete_slider=true, discrete_values=true
		}
        
        local labelRow = editor.add{ type="flow", name="labelRow", caption="Label Row", direction="horizontal" }
        labelRow.style.horizontal_spacing = 12;
        
        labelRow.add{ type="label", name="label", caption="Label: " }
        labelRow.add{ type="textfield", name="textfield", lose_focus_on_confirm=true }
	end
	return parent.logiNetChannelEditor
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

function reset_guis(player)
    local parent = mod_gui.get_frame_flow(player)
    if parent.logiNetChannelEditor then
        parent.logiNetChannelEditor.destroy()
    end
    if parent.logiNetChannelHover then
        parent.logiNetChannelHover.destroy()
    end
end

function is_multichannel()
    local channelLimit = global.channelLimit
	return channelLimit and channelLimit > 1
end

function is_editable_entity(entity)
	return entity and (entity.logistic_network or #entity.get_logistic_point() > 0)
end

local FORCE_REGEX = "(.+)%.channel%.(%d+)"

function parse_channel_forcename(force_name)
    local base_name, channel = string.match(force_name, FORCE_REGEX)
    return base_name, tonumber(channel)
end

function is_channel_force(force)
    return string.match(force.name, FORCE_REGEX) ~= nil
end

function get_channel_force_name(base_name, channel)
    if not channel or channel == 0 then
		return base_name
	else
        return base_name .. ".channel." .. channel
    end
end

function get_channel_force(base_force, channel)
    if not channel or channel == 0 then
		return base_force
	else
        local channel_force_name = get_channel_force_name(base_force.name, channel)
        return game.forces[channel_force_name]
    end
end

function get_or_create_channel_force(base_force, channel)
	if not channel or channel == 0 then
		return base_force
	else
		local channel_force_name = get_channel_force_name(base_force.name, channel)
		if not game.forces[channel_force_name] then
			local channel_force = game.create_force(channel_force_name)
			channel_force.set_friend(base_force, true)
			channel_force.set_cease_fire(base_force, true)
			base_force.set_friend(channel_force, true)
			base_force.set_cease_fire(channel_force, true)
            syncAllTechToChannel(base_force, channel)
		end
		return game.forces[channel_force_name]
	end
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
		game.print("Unable to set entity channel: cannot find player force '"..base_name.."'")
		return
	end
	
	entity.force = get_or_create_channel_force(base_force, channel)
end

function get_channel_label(channel_force_name)
    global.channel_labels = global.channel_labels or {}
    
    local _, channel = parse_channel_forcename(channel_force_name)
    if channel and channel > 0 then
        return global.channel_labels[channel_force_name]
    end
    
    return 'default'
end

function set_channel_label(channel_force_name, label)
    global.channel_labels = global.channel_labels or {}
    
    local _, channel = parse_channel_forcename(channel_force_name)
    if channel and channel > 0 then
        global.channel_labels[channel_force_name] = label;
    end
end

function update_guis(player)
	local hover = get_hover_gui(player)
	local editor = get_editor_gui(player)
    
    local show_hover = false
    local show_editor = false
	if is_multichannel() then
        show_editor = is_editable_entity(player.opened)
        show_hover = not show_editor and is_editable_entity(player.selected)
    end
    
    if show_editor then
        local channel = editor.sliderRow.slider.slider_value
        if channel and channel >= 0 then
            editor.sliderRow.label.caption = channel
            local channel_force_name = get_channel_force_name(player.opened.force.name, channel)
            editor.labelRow.textfield.text = get_channel_label(channel_force_name) or ''
            editor.labelRow.textfield.enabled = (channel > 0)
        else
            editor.sliderRow.label.caption = '?'
            editor.labelRow.textfield.text = ''
            editor.labelRow.textfield.enabled = false
        end
    end
        
    if show_hover then
        local caption = "Logistic Network Channel: "..get_channel(player.selected)
        local label = get_channel_label(player.selected.force.name)
        if label then
            caption = caption..' ('..label..')'
        end
        hover.caption = caption
    end
    
    editor.visible = show_editor
    hover.visible = show_hover
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

function syncSingleTechToChannels(technology)
    for channel = 1,global.channelLimit do
        local channel_force = get_channel_force(technology.force, channel)
        if channel_force then
            channel_force.technologies[technology.name].researched = technology.researched
        end
    end
end

function syncAllTechToChannel(base_force, channel)
    local channel_force = get_channel_force(base_force, channel)
    if channel_force then
        for name,tech in pairs(base_force.technologies) do
            channel_force.technologies[name].researched = tech.researched;
        end
    end
end

function syncAllTechToChannels(base_force)
    for channel = 1,global.channelLimit do
        syncAllTechToChannel(base_force, channel)
    end
end

script.on_init(syncChannelLimit)
script.on_configuration_changed(
    function(data)
        -- game.print("on_configuration_changed: ".. serpent.block(data))
        syncChannelLimit()
        for name, force in pairs(game.forces) do
            if not is_channel_force(force) then
                syncAllTechToChannels(force)
            end
        end
        for name, player in pairs(game.players) do
            reset_guis(player)
        end
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
        
		if editor.sliderRow.slider == event.element then
            update_guis(player)
		end
        
	end
)

script.on_event(defines.events.on_gui_text_changed,
    function(event)
        local player = game.get_player(event.player_index)
		local editor = get_editor_gui(player);
        
        if editor.labelRow.textfield == event.element and is_editable_entity(player.opened) then
            local channel = editor.sliderRow.slider.slider_value
            local channel_force_name = get_channel_force_name(player.opened.force.name, channel)
            set_channel_label(channel_force_name, editor.labelRow.textfield.text)
            update_guis(player)
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
            
            editor.sliderRow.slider.set_slider_minimum_maximum(0, global.channelLimit - 1)
			editor.sliderRow.slider.slider_value = channel
			
			update_guis(player)
		end
	end
)

script.on_event(defines.events.on_gui_closed,
	function(event)
        local entity = event.entity
		if is_multichannel() and is_editable_entity(entity) then
			local player = game.get_player(event.player_index)
			local editor = get_editor_gui(player);
			
			local channel = editor.sliderRow.slider.slider_value;
			set_channel(entity, channel)
			
			update_guis(player)
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
			
			update_guis(player)
		end
	end
)

script.on_event(defines.events.on_selected_entity_changed,
	function(event)
        if is_multichannel() then
            local player = game.get_player(event.player_index)
            local entity = player.selected
            update_guis(player)
        end
	end
)

script.on_event(defines.events.on_research_finished,
    function(event)
        if is_multichannel() then
            syncSingleTechToChannels(event.research)
        end
    end
)

script.on_event(defines.events.on_player_selected_area, 
    function(event)
        -- TODO: create blueprint from selected entities
        if event.item == 'friends-blueprint' and #event.entities > 0 then
            -- log(serpent.block(event))
            
            -- Emulates vanilla blueprint behavior by doing the following:
            -- 1) Create a new blueprint and puts it in the player's hand
            -- 2) Copy blueprint entities from the selection area into the blueprint (adjusting for position)
            -- 3) Open blueprint GUI (currently disabled b/c it's weird opening the GUI while the blueprint is buildable
            --    in the player's hand, and I don't know how to get around that yet)
            
            -- Calculate the entity area (smallest BoundingBox that covers all entity positions), and also its center
            local entity_area = { left_top={}, right_bottom={} }
            for i,entity in ipairs(event.entities) do
                if i == 1 then
                    entity_area.left_top.x = entity.position.x
                    entity_area.left_top.y = entity.position.y
                    entity_area.right_bottom.x = entity.position.x
                    entity_area.right_bottom.y = entity.position.y
                else
                    entity_area.left_top.x = math.min(entity_area.left_top.x, entity.position.x)
                    entity_area.left_top.y = math.min(entity_area.left_top.y, entity.position.y)
                    entity_area.right_bottom.x = math.max(entity_area.right_bottom.x, entity.position.x)
                    entity_area.right_bottom.y = math.max(entity_area.right_bottom.y, entity.position.y)
                end
            end
            entity_area.center = {
                x = (entity_area.left_top.x + entity_area.right_bottom.x) / 2,
                y = (entity_area.left_top.y + entity_area.right_bottom.y) / 2
            }
            
            local blueprint_entities = {}
            for i,entity in ipairs(event.entities) do
                table.insert(blueprint_entities, {
                    entity_number = i,
                    name = entity.name,
                    position = {
                        -- Position in blueprint should be relative to the center of the entity area
                        x = entity.position.x - entity_area.center.x,
                        y = entity.position.y - entity_area.center.y
                    }
                })
            end
            
            local player = game.get_player(event.player_index)
            player.cursor_stack.set_stack{name='blueprint'}
            player.cursor_stack.set_blueprint_entities(blueprint_entities)
            -- player.opened = player.cursor_stack
        end
    end
)
