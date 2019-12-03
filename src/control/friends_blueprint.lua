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