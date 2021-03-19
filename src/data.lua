-- data.lua


-- GUI styles
local default_gui = data.raw["gui-style"].default
default_gui["logiNetChannels_textfield_edit_channel"] = {
    type = "textbox_style",
    parent = "search_textfield_with_fixed_width",
    minimal_width = 40,
    maximal_width = 40,
    font = "default-large-semibold"
}

default_gui["logiNetChannels_slider_edit_channel"] = {
    type = "slider_style",
    parent = "notched_slider",
    natural_width = 240
}


-- Technology prototypes
-- TODO: try loading mod w/ various overhaul mods; will the tech prereqs cause any problems?
data:extend({
    {
        type = "technology",
        name = "logistic-channels",
        icon_size = 150,
        icon = "__LogiNetChannels__/graphics/tech.png",
        effects = {
            {
                type = "nothing",
                effect_description = {"logiNetChannel.tech_effect_description"}
            }
        },
        prerequisites = { "utility-science-pack","logistic-robotics" },
        unit = {
          count = 100,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"utility-science-pack", 1}
          },
          time = 30
        },
        --order = "c-k-d"
    }
})


-- Channel changer tool
local channelChanger = table.deepcopy(data.raw["selection-tool"]["selection-tool"])
-- TODO: create custom icon
--channelChanger.icon = "__FriendBlueprints__/graphics/icons/friends-blueprint.png"
--channelChanger.icon_size = 32
channelChanger.name = "logistic-channel-changer"
channelChanger.selection_mode = {"any-entity","friend"}
channelChanger.entity_filter_mode = "whitelist"
channelChanger.entity_type_filters = {"roboport","logistic-container","spider-vehicle"}
table.insert(channelChanger.flags, "only-in-cursor")
table.insert(channelChanger.flags, "draw-logistic-overlay")
channelChanger.selection_color = data.raw["upgrade-item"]["upgrade-planner"].selection_color

local channelChangerShortcut = {
    name = "give-logistic-channel-changer",
    type = "shortcut",
    action = "spawn-item",
    item_to_spawn = "logistic-channel-changer",
    -- TODO: create custom icons
    icon = table.deepcopy(data.raw["shortcut"]["give-blueprint"].icon),
    disabled_icon = table.deepcopy(data.raw["shortcut"]["give-blueprint"].disabled_icon),
    small_icon = table.deepcopy(data.raw["shortcut"]["give-blueprint"].small_icon),
    disabled_small_icon = table.deepcopy(data.raw["shortcut"]["give-blueprint"].disabled_small_icon),
    style = "green",
    technology_to_unlock = "logistic-channels",
}

data:extend{
    channelChanger,
    channelChangerShortcut
}