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
