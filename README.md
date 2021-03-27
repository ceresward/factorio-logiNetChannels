# factorio-logiNetChannels
Source repository for the Factorio mod Logistic Network Channels

## Description

Logistic Network Channels is a mod for the video game [Factorio](https://factorio.com/).  It adds to logistic networks the concept of communication channels.  Logistic entities can be assigned to different channels, and entities will only form a network with other entities on the same channel.  This allows the player to create separate logistic networks in areas where they would normally overlap and be merged by the game into one network.  Separate networks are useful because logistic bots are often faster and more power efficient when they can be focused on specific tasks, instead of being constantly reassigned to fulfill different requests from the entire network.

![In this screenshot, the right roboports are in range of the left roboports, yet they are not on the same network.  This is because the right roboports are assigned to channel 1, while the left roboports are on channel 0.  The passive provider chests have the same configuration.](/screenshots/readme-1.png)

Additional information about how the mod works, features, and limitations can be found on the [Factorio mod portal page](https://mods.factorio.com/mod/LogiNetChannels)

## Roadmap

### 1.2
- [ ] Keep channel force diplomacy (friends/cease-fire) in sync with the main player force diplomacy (possibly as a separate library mod)

### Unscheduled
- [ ] Ability to set assigned channel using circuit signals (if possible; still investigating)
- [ ] Edit/view channel property from the main entity GUI instead of the upper left corner
    - _Blocked: mod API does not yet support modifying base game GUIs_
- [ ] Save channel information in blueprints (if possible; still investigating)
- [ ] Ability to change on the fly which channel serves as the default channel, so personal logistics can be served by channels other than channel 0 from time to time

## Release Notes

See https://mods.factorio.com/mod/LogiNetChannels/changelog

## Attribution

- Remote Control icon made by [Freepik](https://www.freepik.com) from [www.flaticon.com](https://www.flaticon.com/)