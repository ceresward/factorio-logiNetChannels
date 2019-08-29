-- data.lua

local friendsBlueprint = table.deepcopy(data.raw["selection-tool"]["selection-tool"])
friendsBlueprint.name = "friends-blueprint"
friendsBlueprint.selection_mode = {"buildable-type","friend"}
friendsBlueprint.entity_type_filters = {"simple-entity"}
friendsBlueprint.entity_filter_mode = "blacklist"
friendsBlueprint.show_in_library = true

data:extend{friendsBlueprint}

-- log(serpent.block(data.raw["selection-tool"]))
