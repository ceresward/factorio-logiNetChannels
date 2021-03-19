local badges = {}

local badgeScale = 2

function badges.createOrUpdate(playerIndex, entity, channel)
    local badgeId = getPlayerBadges(playerIndex)[entity.unit_number]
    if badgeId and rendering.is_valid(badgeId) then
        rendering.set_text(badgeId, tostring(channel))
    else
        badgeId = rendering.draw_text {
            text = tostring(channel),
            -- text = "██",  -- Can be used for checking text bounding box / alignment
            surface = entity.surface,
            target = entity,
            -- 5/16 ratio is techically closer to center, but it kinda looks better at 1/4
            --target_offset = {0, -badgeScale*5/16},
            target_offset = {0, -badgeScale/4},
            color = {1.0, 1.0, 0.75},
            players = {playerIndex},
            alignment = "center",
            scale = badgeScale,
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