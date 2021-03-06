--control.lua

local guis = require("control.guis")
local channels = require("control.channels")

function is_multichannel()
    local channelLimit = global.channelLimit
	return channelLimit ~= nil and channelLimit > 1
end

function is_logistics_entity(entity)
    -- Note:  the parameter value MUST be a LuaEntity!  There is no way to safely check the type
    -- of an arbitrary Factorio object, so this must be the caller's responsibility
    function has_logistic_network()
        return (entity and entity.logistic_network) ~= nil
    end
    function has_logistic_points()
        return (entity and entity.get_logistic_point) ~= nil and #entity.get_logistic_point() > 0;
    end

    return has_logistic_network() or has_logistic_points()
end

function is_logistics_entity_opened(player)
    function is_entity_opened()
        return player.opened_gui_type == defines.gui_type.entity
    end
    return is_entity_opened() and is_logistics_entity(player.opened)
end

function get_channel_force(base_force, channel)
    if not channel or channel == 0 then
		return base_force
	else
        local channel_force_name = channels.to_force_name(base_force.name, channel)
        return game.forces[channel_force_name]
    end
end

function get_or_create_channel_force(base_force, channel)
	if not channel or channel == 0 then
		return base_force
	else
		local channel_force_name = channels.to_force_name(base_force.name, channel)
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
    local _, channel = channels.parse_force_name(entity.force.name)
	return channel or 0
end

function set_channel(entity, channel)
	local base_name, _ = channels.parse_force_name(entity.force.name)
	local base_force = game.forces[base_name]
	if not base_force then
		-- TODO: do something better...
		game.print("Unable to set entity channel: cannot find player force '"..base_name.."'")
		return
	end
    
    local new_force = get_or_create_channel_force(base_force, channel)
    if (entity.force ~= new_force) then
        entity.force = new_force

        -- Note: in multiplayer, any player may have the entity opened/selected, not just the player that set the channel.
        --       So it is necessary to check all players to see if they need a GUI update.
        for _, player in pairs(game.players) do
            if player.opened == entity and guis.editor_gui(player).visible then
                update_editor_gui(player, channel)
            elseif player.selected == entity and guis.hover_gui(player).visible then
                update_hover_gui(player)
            end
        end
    end
end

function get_channel_label(channel_force_name)
    global.channel_labels = global.channel_labels or {}
    return global.channel_labels[channel_force_name] or ''
end

function set_channel_label(channel_force_name, label)
    global.channel_labels = global.channel_labels or {}
    
    local _, channel = channels.parse_force_name(channel_force_name)
    if channel and channel > 0 then
        if label == '' then
            label = nil;
        end
        global.channel_labels[channel_force_name] = label;
    end
end

function show_hide_guis(player)
    function is_hover_enabled(player)
        return settings.get_player_settings(player)["logiNetChannels-show-hover"].value
    end

    local hover = guis.hover_gui(player)
	local editor = guis.editor_gui(player)
    
    local show = nil
    if is_multichannel() then
        if is_logistics_entity_opened(player) then
            show = "editor"
        elseif is_hover_enabled(player) and is_logistics_entity(player.selected) then
            show = "hover"
        end
    end

    if show == "editor" and not editor.visible then
        editor.sliderRow.slider.set_slider_minimum_maximum(0, global.channelLimit - 1)
        update_editor_gui(player, get_channel(player.opened))
    elseif show == "hover" then
        update_hover_gui(player)
    end

    editor.visible = (show == "editor")
    hover.visible = (show == "hover")
end

function update_editor_gui(player, channel)
    if channel and channel > 0 then
        local base_force_name, _ = channels.parse_force_name(player.opened.force.name)
        local channel_force_name = channels.to_force_name(base_force_name, channel)
        guis.update_editor(player, channel, get_channel_label(channel_force_name))
    else
        -- Note: channel_label can be nil; it isn't used for the default channel
        guis.update_editor(player, 0, nil)
    end
end

function update_hover_gui(player)
    local channel_force_name = player.selected.force.name
    local _, channel = channels.parse_force_name(channel_force_name)

    if channel and channel > 0 then
        guis.update_hover(player, channel, get_channel_label(channel_force_name))
    else
        guis.update_hover(player, 0, {"logiNetChannel.default_label"})
    end
end

function syncChannelLimit()
	local currentLimit = global.channelLimit
	local newLimit = settings.global["logiNetChannelLimit"].value;
    
    if (currentLimit ~= newLimit) then
        game.print("[Logistic Network Channels] Channel limit changing from "..tostring(currentLimit).." to "..
            tostring(newLimit));
    end
        
	if currentLimit and currentLimit > newLimit then
        local mergedForceCount = 0
		for name,force in pairs(game.forces) do
			local baseName, channel = channels.parse_force_name(name)
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

-- Syncs all writeable properties from srcTech into destTech
function syncTech(srcTech, destTech)
    destTech.researched = srcTech.researched
    destTech.enabled = srcTech.enabled;
    destTech.visible_when_disabled = srcTech.visible_when_disabled;
    destTech.level = srcTech.level;
end
    
function syncSingleTechToChannels(technology)
    for channel = 1,global.channelLimit do
        local channel_force = get_channel_force(technology.force, channel)
        if channel_force then
            syncTech(technology, channel_force.technologies[technology.name])
        end
    end
end

function syncAllTechToChannel(base_force, channel)
    local channel_force = get_channel_force(base_force, channel)
    if channel_force then
        for name,tech in pairs(base_force.technologies) do
            syncTech(tech, channel_force.technologies[name])
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
            if not channels.is_channel_force_name(force.name) then
                syncAllTechToChannels(force)
            end
        end
        for name, player in pairs(game.players) do
            guis.reset_guis(player)
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
        local editor = guis.editor_gui(player);
        
        if event.element == editor.sliderRow.slider and editor.visible then
            local channel = editor.sliderRow.slider.slider_value
            update_editor_gui(player, channel)
        end
	end
)

script.on_event(defines.events.on_gui_confirmed,
    function(event)
        local player = game.get_player(event.player_index)
        local editor = guis.editor_gui(player);
        if event.element == editor.sliderRow.textfield and editor.visible then
            local channel = channels.parse_nearest_channel(editor.sliderRow.textfield.text)
            update_editor_gui(player, channel)
        end
    end
)

script.on_event(defines.events.on_gui_text_changed,
    function(event)
        local player = game.get_player(event.player_index)
		local editor = guis.editor_gui(player);
        
        if event.element == editor.labelRow.textfield and is_logistics_entity_opened(player) then
            local channel = editor.sliderRow.slider.slider_value
            local base_force_name, _ = channels.parse_force_name(player.opened.force.name)
            local channel_force_name = channels.to_force_name(base_force_name, channel)
            set_channel_label(channel_force_name, editor.labelRow.textfield.text)
            update_editor_gui(player, channel)
        end
    end
)

script.on_event(defines.events.on_gui_opened,
	function(event)
		local entity = event.entity
		if is_multichannel() and is_logistics_entity(entity) then
			local player = game.get_player(event.player_index)
			local editor = guis.editor_gui(player)
            local channel = get_channel(entity)
            
            show_hide_guis(player)
		end
	end
)

script.on_event(defines.events.on_gui_closed,
	function(event)
        local entity = event.entity
		if is_multichannel() and is_logistics_entity(entity) then
			local player = game.get_player(event.player_index)
			local editor = guis.editor_gui(player);
			
			local channel = editor.sliderRow.slider.slider_value;
			set_channel(entity, channel)
			
			show_hide_guis(player)
		end
	end
)

script.on_event(defines.events.on_entity_settings_pasted,
	function(event)
		local source = event.source;
		local destination = event.destination;
		if is_multichannel() and is_logistics_entity(source) and is_logistics_entity(destination) then
			local player = game.get_player(event.player_index)
			
            local channel = get_channel(source)
			set_channel(destination, channel)
		end
	end
)

script.on_event(defines.events.on_selected_entity_changed,
	function(event)
        if is_multichannel() then
            local player = game.get_player(event.player_index)
            local entity = player.selected
            show_hide_guis(player)
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
