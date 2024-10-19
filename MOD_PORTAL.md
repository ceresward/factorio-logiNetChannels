# Notice: Factorio 2.0 Plans

Some of you may be wondering, what will happen with this mod when Factorio 2.0 and the Space Age DLC are released?  The short answer is - this mod will be updated to support Factorio 2.0 and Space Age, and you can still play with it if you like.  However, you may find you no longer need it!  The Factorio team have made a number of awesome improvements to how bots behave that should help to make large networks a lot less annoying to deal with:

- Robots are chosen to service requests based on predicted arrival time instead of nearest idle robot
- Individual roboports can now be configured to keep a certain number of robots stationed at the roboport at all times
- Robots are now much smarter when picking a roboport to recharge at

You can read more about all of these changes in [FFF-374](https://www.factorio.com/blog/post/fff-374).  I have yet to see how effective these changes are in practice, however I am optimistic that they will be good enough to remove the need for this mod.  I am not planning on making any major updates to this mod in the future unless there is still a need for it.

# Description

Logistic Network Channels adds to logistic networks the concept of communication channels.  Logistic entities can be assigned to different channels, and entities will only form a network with other entities on the same channel.  This allows the player to create separate logistic networks in areas where they would normally overlap and be merged by the game into one network.  Separate networks are useful because logistic bots are often faster and more power efficient when they can be focused on specific tasks, instead of being constantly reassigned to fulfill different requests from the entire network.

## How it works

The mod works by creating factions for each channel that are linked with the main player faction(s).  For example, when an entity of the `player` faction is assigned to channel 1, that entity gets transferred to faction `player.channel.1`.  The channel factions are configured to have mutual `friend` and `cease-fire` relationships with the main player faction, which allows the player to continue interacting with the entities as thought they were still part of the main player faction.  Channel 0 is special - entities on channel 0 are assigned to the main player force, as they normally are.  And if the channel limit is reduced while a map is running, any entities that get orphaned get reassigned back to channel 0.

## Features

- Assign logistics entities to up to 50 different network channels using the entity GUI
- Map-configurable setting for the channel limit (1-50; setting the channel limit to 1 disables mod features)
- Copy channel setting when copy-pasting entity settings
- Mod checks in a generic way for logistics entities, so modded entities should just work
- Use the channel changer to quickly view and change channel settings

## Limitations

- Factorio has a limit of 60 forces per map.  So the maximum channel limit is set conservatively at 50 channels.  Note that other mods may also add forces to the game, so the effective limit may be even lower.  Also, in multiplayer, there may be multiple player forces.  Each player force will have its own set of channels, so take that into account.  Example: in a PVP map with three player forces, the channel limit should be set no higher than 18 (18 * 3 = 54).
- Some logistics-related functionality will only work with networks and entities assigned to the default channel (channel 0):
    - Personal logistic requests will only be served from the default channel
    - Map mode will only highlight networks on the default channel
    - The Logistic Networks GUI (L key) will only show networks on the default channel
    - Construction bots will only build ghosts when operating on the default channel.  They can repair entities from non-default channels, but only if they are operating on that same channel.
- Channel force diplomacy (`friend`/`cease-fire`) is not currently being kept in sync with the main force diplomacy.  For example, suppose a new force `foobar` is created mid-game, and is given `cease-fire` with the `player` force.  The cease-fire is not currently propagated to channel forces (`player.channel.#` ).  This means entities from `foobar` may incorrectly attack the player's logistic network entities on non-default channels, due to the missing diplomacy rule.

# Roadmap

Please see the [Github project](https://github.com/ceresward/factorio-logiNetChannels) for the development roadmap

## Attribution

- Remote Control icon made by [Freepik](https://www.freepik.com) from [www.flaticon.com](https://www.flaticon.com/)