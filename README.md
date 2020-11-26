# factorio-logiNetChannels
Source repository for the Factorio mod Logistic Network Channels

## Description

Logistic Network Channels is a mod for the video game [Factorio](https://factorio.com/).  It adds to logistic networks the concept of communication channels.  Logistic entities can be assigned to different channels, and entities will only form a network with other entities on the same channel.  This allows the player to create separate logistic networks in areas where they would normally overlap and be merged by the game into one network.  Separate networks are useful because logistic bots are often faster and more power efficient when they can be focused on specific tasks, instead of being constantly reassigned to fulfill different requests from the entire network.

![In this screenshot, the right roboports are in range of the left roboports, yet they are not on the same network.  This is because the right roboports are assigned to channel 1, while the left roboports are on channel 0.  The passive provider chests have the same configuration.](/screenshots/readme-1.png)

Additional information about how the mod works, features, and limitations can be found on the [Factorio mod portal page](https://mods.factorio.com/mod/LogiNetChannels)

## Roadmap

### 1.2
- [ ] Optional feature: unlock channels through research
- [ ] Ability to set assigned channel using circuit signals

### Unscheduled
- [ ] Ability to change channels by directly entering a number instead of fiddling with the slider
- [ ] Keep channel force diplomacy (friends/cease-fire) in sync with the main player force diplomacy (possibly as a separate library mod)
- [ ] Edit/view channel property from the main entity GUI instead of the upper left corner
    - _Blocked: mod API does not yet support modifying base game GUIs_

## Release Notes

See https://mods.factorio.com/mod/LogiNetChannels/changelog
