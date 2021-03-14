--control.lua

local guis = require("control.guis")
local channels = require("control.channels")

function is_map_multichannel()
    local channelLimit = global.channelLimit
    return channelLimit ~= nil and channelLimit > 1
end

function has_logistic_channels(entity)
    function is_channel_tech_researched(force)
        -- Channel tech is considered to be researched for the purposes of mod features if it is disabled
        local channelTech = force.technologies["logistic-channels"]
        return (not channelTech.enabled) or channelTech.researched
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

    return entity and is_channel_tech_researched(entity.force) and is_logistics_entity(entity)
end

function has_entity_opened(player)
    return player.opened_gui_type == defines.gui_type.entity
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
    set_channels({entity}, channel)
end

function set_channels(entities, channel)
    local baseForceCache = {}
    local newForceCache = {}

    for _, entity in pairs(entities) do
        local base_force = baseForceCache[entity.force]
        if not base_force then
            local base_force_name, _ = channels.parse_force_name(entity.force.name)
            base_force = game.forces[base_force_name]
            if not base_force then
                -- TODO: do something better...
                game.print("Unable to set entity channel: cannot find player force '"..base_name.."'")
                return
            end
            baseForceCache[entity.force] = base_force
        end

        local new_force = newForceCache[base_force]
        if not new_force then
            new_force = get_or_create_channel_force(base_force, channel)
            newForceCache[base_force] = new_force
        end

        if (entity.force ~= new_force) then
            entity.force = new_force
        end
    end

    for _, player in pairs(game.players) do
        if guis.hover_gui(player).visible then
            update_hover_gui(player)
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
    function is_holding_changer(player)
        return player.cursor_stack and player.cursor_stack.valid_for_read
            and player.cursor_stack.name == "logistic-channel-changer"
    end

    local hover = guis.hover_gui(player)
    local editor = guis.editor_gui(player)
    local changer = guis.changer_gui(player)
    
    local show = nil
    if is_map_multichannel() then
        if has_entity_opened(player) and has_logistic_channels(player.opened) then
            show = "editor"
        elseif is_holding_changer(player) then
            show = "changer"
        elseif is_hover_enabled(player) and has_logistic_channels(player.selected) then
            show = "hover"
        end
        
        if show == "editor" and not editor.visible then
            editor.sliderRow.slider.set_slider_minimum_maximum(0, global.channelLimit - 1)
            update_editor_gui(player, get_channel(player.opened))
        elseif show == "changer" and not changer.visible then
            update_changer_gui(player, changer.sliderRow.slider.slider_value)
        elseif show == "hover" then
            update_hover_gui(player)
        end
    end

    editor.visible = (show == "editor")
    hover.visible = (show == "hover")
    changer.visible = (show == "changer")
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

function update_changer_gui(player, channel)
    if channel and channel > 0 then
        local channel_force_name = channels.to_force_name(player.force.name, channel)
        guis.update_changer(player, channel, get_channel_label(channel_force_name))
    else
        -- Note: channel_label can be nil; it isn't used for the default channel
        guis.update_changer(player, 0, nil)
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
                " channels above the new limit have been merged into the default channel.")
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

function syncChannelTechEnabled()
    -- Enable/disable channel tech based on mod startup setting.  Disabling channel tech removes
    -- it from the research screen.  Mod features will always be enabled if the tech is disabled

    for name, force in pairs(game.forces) do
        local channelTech = force.technologies["logistic-channels"]
        local enable_research = settings.startup["logiNetChannels-require-research"].value

        if enable_research then
            channelTech.enabled = true
        else
            -- This is a small hack to deal with the tech unlock for channel changer shortcuts. If
            -- a player hasn't unlocked the shortcut yet, and joins a map with tech disabled, they
            -- won't be able to use the shortcut at all.  Hack is
            channelTech.researched = true
            channelTech.enabled = false
        end
        channelTech.enabled = settings.startup["logiNetChannels-require-research"].value
    end
end


-----------------------------------------------------------
--  [EVENTS]                                             --
-----------------------------------------------------------

script.on_init(
    function()
        syncChannelLimit()
        syncChannelTechEnabled()
    end
)

script.on_configuration_changed(
    function(data)
        -- game.print("on_configuration_changed: ".. serpent.block(data))
        
        syncChannelLimit()
        syncChannelTechEnabled()
        
        -- Sync channel tech during mod upgrade:
        --   When loading a map that was using a pre-tech version of the mod, auto-research the
        --   tech if its prerequisites are already researched (but only when research is enabled!)
        local mod_changes = data.mod_changes["LogiNetChannels"]
        local mod_old_version = mod_changes and mod_changes.old_version
        local is_pretech_upgrade =  mod_old_version and mod_old_version:find("^1.0") ~= nil
        if is_pretech_upgrade then
            -- game.print("[LogiNetChannels] Detected pre-tech previous mod version: " .. mod_old_version)
            log("[LogiNetChannels] Detected pre-tech previous mod version: " .. mod_old_version)
            for name, force in pairs(game.forces) do
                local channelTech = force.technologies["logistic-channels"]
                -- game.print("[LogiNetChannels] Channel tech enabled? " .. tostring(channelTech.enabled))
                log("[LogiNetChannels] ".. force.name ..": channel tech enabled? " .. tostring(channelTech.enabled))
                if channelTech.enabled then
                    local allPrereqsResearched = true
                    for _, prereq in pairs(channelTech.prerequisites) do
                        allPrereqsResearched = allPrereqsResearched and prereq.researched
                    end
                    -- game.print("[LogiNetChannels] " .. force.name .. ": channel tech prereqs already researched?  " .. tostring(allPrereqsResearched))
                    log("[LogiNetChannels] " .. force.name .. ": channel tech prereqs already researched?  " .. tostring(allPrereqsResearched))
                    if allPrereqsResearched then
                        channelTech.researched = true
                    end
                end
            end
        end
        
        for name, force in pairs(game.forces) do
            -- Check if the force is a channel force, and if so, sync tech from the main force...just in case
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
        if editor.visible and event.element == editor.sliderRow.slider then
            local channel = editor.sliderRow.slider.slider_value
            update_editor_gui(player, channel)
        end

        local changer = guis.changer_gui(player);
        if changer.visible and event.element == changer.sliderRow.slider then
            local channel = changer.sliderRow.slider.slider_value
            update_changer_gui(player, channel)
        end
    end
)

script.on_event(defines.events.on_gui_confirmed,
    function(event)
        local player = game.get_player(event.player_index)

        local editor = guis.editor_gui(player);
        if editor.visible and event.element == editor.sliderRow.textfield then
            local channel = channels.parse_nearest_channel(editor.sliderRow.textfield.text)
            update_editor_gui(player, channel)
        end

        local changer = guis.changer_gui(player);
        if changer.visible and event.element == changer.sliderRow.textfield then
            local channel = channels.parse_nearest_channel(changer.sliderRow.textfield.text)
            update_changer_gui(player, channel)
        end
    end
)

script.on_event(defines.events.on_player_cursor_stack_changed,
    function(event)
        local player = game.get_player(event.player_index)
        show_hide_guis(player)
    end
)

script.on_event(defines.events.on_gui_opened,
    function(event)
        if is_map_multichannel() then
            local entity = event.entity
            if has_logistic_channels(entity) then
                local player = game.get_player(event.player_index)
                local editor = guis.editor_gui(player)
                local channel = get_channel(entity)
                
                show_hide_guis(player)
            end
        end
    end
)

script.on_event(defines.events.on_gui_closed,
    function(event)
        if event.gui_type == defines.gui_type.entity and is_map_multichannel() then
            local entity = event.entity
            if entity and has_logistic_channels(entity) then
                local player = game.get_player(event.player_index)
                local editor = guis.editor_gui(player);
                
                -- Apply new channel setting
                local channel = editor.sliderRow.slider.slider_value
                set_channel(entity, channel)

                -- Apply new channel label setting
                local label = editor.labelRow.textfield.text
                local base_force_name, _ = channels.parse_force_name(entity.force.name)
                local channel_force_name = channels.to_force_name(base_force_name, channel)
                set_channel_label(channel_force_name, label)
                
                show_hide_guis(player)
            end
        end
    end
)

script.on_event(defines.events.on_entity_settings_pasted,
    function(event)
        if is_map_multichannel() then
            local source = event.source;
            local destination = event.destination;
            if has_logistic_channels(source) and has_logistic_channels(destination) then
                local player = game.get_player(event.player_index)
                
                local channel = get_channel(source)
                set_channel(destination, channel)
            end
        end
    end
)

script.on_event(defines.events.on_selected_entity_changed,
    function(event)
        if is_map_multichannel() then
            local player = game.get_player(event.player_index)
            local entity = player.selected
            show_hide_guis(player)
        end
    end
)

script.on_event(defines.events.on_research_finished,
    function(event)
        if is_map_multichannel() then
            syncSingleTechToChannels(event.research)
        end
    end
)

script.on_event(defines.events.on_mod_item_opened,
    function(event)
        game.print("on_mod_item_opened")
        if event.item.name == 'logistic-channel-changer' then
            game.print("logistic-channel-changer: item opened")
        end
    end
)

script.on_event(defines.events.on_player_selected_area,
    function(event)
        -- Note: can add check for #event.entities > 0 for actual implementation
        if event.item == 'logistic-channel-changer' then
            game.print("logistic-channel-changer: area selected")
        end
        if event.item == 'logistic-channel-changer' and #event.entities > 0 then
            local player = game.get_player(event.player_index)
            local channel = guis.changer_gui(player).sliderRow.slider.slider_value
            game.print("logistic-channel-changer: updating "..tostring(#event.entities).." entities to channel "..channel)
            
            set_channels(event.entities, channel)
            -- for _, entity in pairs(event.entities) do
            --     set_channel(entity, channel)
            -- end
        end
    end
)
