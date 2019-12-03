-- settings.lua

data:extend({
    {
        setting_type = "runtime-global",
		name = "logiNetChannelLimit",
        type = "int-setting",
        default_value = 8,
		minimum_value = 1,
		maximum_value = 50
    },
})