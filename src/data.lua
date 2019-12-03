-- data.lua

local friendsBlueprint = table.deepcopy(data.raw["selection-tool"]["selection-tool"])
friendsBlueprint.icon = "__LogiNetChannels__/graphics/icons/friends-blueprint.png"
friendsBlueprint.icon_size = 32
friendsBlueprint.name = "friends-blueprint"
friendsBlueprint.selection_mode = {"buildable-type","friend"}
friendsBlueprint.entity_type_filters = {"simple-entity"}
friendsBlueprint.entity_filter_mode = "blacklist"
friendsBlueprint.show_in_library = true

local friendsShortcut = table.deepcopy(data.raw["shortcut"]["give-blueprint"])
friendsShortcut.name = "give-friends-blueprint"
friendsShortcut.localised_name = nil
friendsShortcut.icon = {
    filename = "__LogiNetChannels__/graphics/icons/friends-blueprint.png";
    size = 32
}
friendsShortcut.item_to_create = "friends-blueprint"

data:extend{
    friendsBlueprint,
    friendsShortcut
}

-- log(serpent.block(data.raw["selection-tool"]))
