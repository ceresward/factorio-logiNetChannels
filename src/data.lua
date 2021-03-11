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