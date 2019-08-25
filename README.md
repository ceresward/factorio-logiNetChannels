# factorio-logiNetChannels
Source repository for the Factorio mod Logistic Network Channels

## Description

Logistic Network Channels is a mod for the video game [Factorio](https://factorio.com/).  It adds to logistic networks the concept of communication channels.  Logistic entities can be assigned to different channels, and entities will only form a network with other entities on the same channel.  This allows the player to create separate logistic networks in areas where they would normally overlap and be merged by the game into one network.  Separate networks are useful because logistic bots are often faster and more power efficient when they can be focused on specific tasks, instead of being constantly reassigned to fulfill different requests from the entire network.

![In this screenshot, the right roboports are in range of the left roboports, yet they are not on the same network.  This is because the right roboports are assigned to channel 1, while the left roboports are on channel 0.  The passive provider chests have the same configuration.](/screenshots/readme-1.png)

### How it works

The mod works by creating factions for each channel that are linked with the main player faction(s).  For example, when an entity of the `player` faction is assigned to channel 1, that entity gets transferred to faction `player.channel.1`.  The channel factions are configured to have mutual `friend` and `cease-fire` relationships with the main player faction, which allows the player to continue interacting with the entities as thought they were still part of the main player faction.  Channel 0 is special - entities on channel 0 are assigned to the main player force, as they normally are.  And if the channel limit is reduced while a map is running, any entities that get orphaned get reassigned back to channel 0.

### Features

- Assign logistics entities to up to 50 different network channels using the entity GUI
- Map-configurable setting for the channel limit (1-50; setting the channel limit to 1 disables mod features)
- Copy channel setting when copy-pasting entity settings
- Mod checks in a generic way for logistics entities, so modded entities should just work

### Limitations

- Factorio has a limit of 60 forces per map.  So the maximum channel limit is set conservatively at 50 channels.  Note that other mods may also add forces to the game, so the effective limit may be even lower.  Also, in multiplayer, there may be multiple player forces.  Each player force will have its own set of channels, so take that into account.  Example: in a PVP map with three player forces, the channel limit should be set no higher than 18 (18 * 3 = 54).
- Even with `friend` and `cease-fire`, logistic networks from other forces will not make deliveries to the player.  So all entities for player delivery should remain on channel 0.
- Similarly, construction bots will not build or repair entities from other forces, so construction bots should remain on channel 0 as well.
- The logistic networks for channels beyond 0 are not highlighted in map mode, and do not appear in the Logistic Networks GUI ( <kbd>L</kbd> )
- It is not currently possible to keep the channel force diplomacy (`friend`/`cease-fire`) in sync with the main force diplomacy.  For example, suppose a different mod creates a new force `foobar`, and later gives it `cease-fire` with `player`.  The channel forces `player.channel.#` do not automatically get the cease-fire as well, so entities from `foobar` may still try and attack logistic network entities on channels other than channel 0.

## Roadmap

### 1.1
- [ ] Unlock channels through research (optional)
- [ ] Player-specific setting for showing/hiding the hover info
- [ ] Ability to set channel by circuit signal
- [ ] Let players label channels to help keep track of which is which

### Unscheduled
- [ ] Append channel editor/viewer to existing vanilla GUIs (mod API does not yet support)
- [ ] Keep channel force diplomacy with other forces in sync with the main player force diplomacy (needs diplomacy change listeners to be added to the mod API)

## Release Notes

### 1.0

- [X] Logic for getting and setting channels on entities
- [X] GUIs for viewing and editing the channel setting for individual entities
- [X] Map setting for changing the channel limit
