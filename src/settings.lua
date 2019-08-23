-- settings.lua

data:extend({
    {
        setting_type = "runtime-global",
		name = "logiNetChannelLimit",
		localised_name = "New Game Network Channel Limit",
		localised_description = "Maximum number of logistic network channels per player faction (1-50).  "..
			"This setting is applied only when a new game is created; changing this setting will not affect an existing game\n\n"..
			"WARNING: each channel creates a new faction, and there is a hard limit of 60 factions per game!  "..
			"For example, if there are three player factions, then the channel limit should be set no higher than "..
			"19 (19*3 + 3 = 60)",
        type = "int-setting",
        default_value = 8,
		minimum_value = 1,
		maximum_value = 50
    },
})