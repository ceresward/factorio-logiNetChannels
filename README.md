# factorio-logiNetChannels
Source repository for the Factorio mod Logistic Network Channels

## Description

Logistic Network Channels is a mod for the video game [Factorio](https://factorio.com/).  It adds to logistic networks the concept of communication channels.  Logistic entities can be assigned to different channels, and entities will only form a network with other entities on the same channel.  This allows the player to create separate logistic networks in areas where they would normally overlap and be merged by the game into one network.  Separate networks are useful because logistic bots are often faster and more power efficient when they can be focused on specific tasks, instead of being constantly reassigned to fulfill different requests from the entire network.

![In this screenshot, the right roboports are in range of the left roboports, yet they are not on the same network.  This is because the right roboports are assigned to channel 1, while the left roboports are on channel 0.  The passive provider chests have the same configuration.](/screenshots/readme-1.png)

Additional information about how the mod works, features, and limitations can be found on the [Factorio mod portal page](https://mods.factorio.com/mod/LogiNetChannels)

## Roadmap

### 1.1
- [ ] Unlock channels through research (optional)
- [ ] Player-specific setting for showing/hiding the hover info
- [ ] Ability to set channel by circuit signal
- [ ] Let players label channels to help keep track of which is which

### Unscheduled
- [ ] Append channel editor/viewer to existing vanilla GUIs (mod API does not yet support)
- [ ] Keep channel force diplomacy with other forces in sync with the main player force diplomacy (needs diplomacy change listeners to be added to the mod API)
- [ ] Find a workaround if possible for the blueprinting limitation

## Release Notes

See https://mods.factorio.com/mod/LogiNetChannels/changelog
