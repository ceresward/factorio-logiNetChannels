local badges = {}

function badges.createOrUpdate(playerIndex, entity, channel)
    local badgeId = getPlayerBadges(playerIndex)[entity.unit_number]
    if badgeId and rendering.is_valid(badgeId) then
        rendering.set_text(badgeId, tostring(channel))
    else
        -- TODO: improve the L&F of the rendered text:
        --   1. Vertical centering of the text over the entity
        --   2. Go back to white color?
        --   3. Slightly bigger numbers?
        --   4. Test w/ moving Spidertrons (should work...)
        badgeId = rendering.draw_text {
            text = tostring(channel),
            surface = entity.surface,
            target = entity,
            color = {1.0, 1.0, 0.5},
            players = {playerIndex},
            alignment = "center",
            scale = 2.0,
        }
        getPlayerBadges(playerIndex)[entity.unit_number] = badgeId
    end
end

function badges.updateIfValid(playerIndex, entity, channel)
    local badgeId = getPlayerBadges(playerIndex)[entity.unit_number]
    if badgeId and rendering.is_valid(badgeId) then
        rendering.set_text(badgeId, tostring(channel))
    end
end

function badges.destroy(playerIndex, entity)
    local badgeId = getPlayerBadges(playerIndex)[entity.unit_number]
    if badgeId ~= nil then
        rendering.destroy(badgeId)
        getPlayerBadges(playerIndex)[entity.unit_number] = nil
    end
end

function badges.destroyAll(playerIndex)
    for _, badgeId in pairs(getPlayerBadges(playerIndex)) do
        rendering.destroy(badgeId)
    end
    clearPlayerBadges(playerIndex)
end


-----------------------------------------------------------
--  Private functions
-----------------------------------------------------------

function getPlayerBadges(playerIndex)
    global.badges = global.badges or {}
    global.badges[playerIndex] = global.badges[playerIndex] or {}
    return global.badges[playerIndex]
end

function clearPlayerBadges(playerIndex)
    global.badges = global.badges or {}
    global.badges[playerIndex] = {}
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end
  

return badges