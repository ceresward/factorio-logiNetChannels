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
        -- TODO: need to account for the possibility that the prereqs might not exist (overhaul mods can delete them)
        -- Notes from Discord discussion (thanks calciumwizard):
        -- 1. Conditionally creating the tech based on a mod setting is possible, but not a great idea; the user might
        --    not be able to get to the settings menu if the error is already occurring (b/c it's a data phase error)
        -- 2. It should be possible to just simply check if the prereqs are available here in data.lua, and skip
        --    creating the tech based on that (or, maybe create the tech but only include prereqs if they exist)
        -- 3. Deleting vanilla prototypes is generally frowned upon, so I shouldn't worry about it too much (i.e.
        --    I probably shouldn't let it hold up the 1.1 release)
        prerequisites = { "utility-science-pack", "logistic-robotics" },
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
local channelChanger = {
    type = "selection-tool",
    name = "logistic-channel-changer",
    icons = {
        {icon = "__base__/graphics/icons/upgrade-planner.png", icon_size = 64, icon_mipmaps = 4},
        {icon = "__LogiNetChannels__/graphics/icons/channel-changer-shortcut-x32-white.png", icon_size = 32, scale = 0.75},
    },
    flags = {"hidden", "not-stackable", "spawnable", "only-in-cursor", "draw-logistic-overlay"},
    subgroup = "other",
    stack_size = 1,
    selection_color = data.raw["upgrade-item"]["upgrade-planner"].selection_color,
    alt_selection_color = data.raw["upgrade-item"]["upgrade-planner"].selection_color,
    selection_mode = {"nothing"},
    alt_selection_mode = {"nothing"},
    selection_cursor_box_type = "copy",
    alt_selection_cursor_box_type = "copy",
}

local channelChangerShortcut = {
    name = "give-logistic-channel-changer",
    type = "shortcut",
    action = "spawn-item",
    item_to_spawn = "logistic-channel-changer",
    -- TODO: polish existing shortcut icon (improve appearance, add mipmaps, etc.)
    -- TODO: add small_icon, disabled_icon, and disabled_small_icon variants
    icon = {
        filename = "__LogiNetChannels__/graphics/icons/channel-changer-shortcut-x32-white.png",
        priority = "extra-high-no-scale",
        size = 32,
        scale = 0.5,
        flags = {"gui-icon"}
    },
    style = "green",
    technology_to_unlock = "logistic-channels",
}

data:extend{
    channelChanger,
    channelChangerShortcut
}