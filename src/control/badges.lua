-----------------------------------------------------------
--  Internal implementation
-----------------------------------------------------------

local badgeScale = 2

local function getPlayerBadges(playerIndex)
    storage.badges = storage.badges or {}
    storage.badges[playerIndex] = storage.badges[playerIndex] or {}
    return storage.badges[playerIndex]
end

local function clearPlayerBadges(playerIndex)
    storage.badges = storage.badges or {}
    storage.badges[playerIndex] = {}
end

-----------------------------------------------------------
-- External API
-----------------------------------------------------------

local badges = {}
function badges.createOrUpdate(playerIndex, entity, channel)
    local badgeId = getPlayerBadges(playerIndex)[entity.unit_number]
    local badge = badgeId and rendering.get_object_by_id(badgeId)
    if badge and badge.valid then
        badge.text = tostring(channel)
    else
        badge = rendering.draw_text {
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
        getPlayerBadges(playerIndex)[entity.unit_number] = badge.id
    end
end

function badges.updateIfValid(playerIndex, entity, channel)
    local badgeId = getPlayerBadges(playerIndex)[entity.unit_number]
    local badge = badgeId and rendering.get_object_by_id(badgeId)
    if badge and badge.valid then
        badge.text = tostring(channel)
    end
end

function badges.destroy(playerIndex, entity)
    local badgeId = getPlayerBadges(playerIndex)[entity.unit_number]
    local badge = badgeId and rendering.get_object_by_id(badgeId)
    if badge ~= nil then
        badge.destroy()
        getPlayerBadges(playerIndex)[entity.unit_number] = nil
    end
end

function badges.destroyAll(playerIndex)
    for _, badgeId in pairs(getPlayerBadges(playerIndex)) do
        rendering.get_object_by_id(badgeId).destroy()
    end
    clearPlayerBadges(playerIndex)
end

return badges