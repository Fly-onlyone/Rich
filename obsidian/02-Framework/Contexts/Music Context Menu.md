---
tags: [framework, contexts]
---

# Music Context Menu

> The right-click menu of the Music widget for picking which media player Rainmeter reads from.

## Source

- `@Resources/Scripts/Contexts/Music.inc` — fills the `Music*` title/action pairs

## How it works

`Contexts/Music.inc` defines `MusicContextTitle*` / `MusicContextAction*` pairs listing players: Default, AIMP, CAD, iTunes, Winamp, WMP, Spotify, WLM.

Each action `!WriteKeyValue`s **two** keys into `Variables\Music.inc` — the `Plugin` (`MediaPlayer` for the built-in default, `NowPlaying` for the rest) and the `PlayerName` — then runs `!Refresh`. This is the [[Settings Persistence Pattern]].

A `[SetMusicTickMark]` String [[Measure]] joins `#Plugin# - #PlayerName#` and uses `IfMatch` to append a checkmark `[\x2714]` to the active player — the [[Tickmark Indicator]].

## Depends on

- [[Context Scaffold]] — relays the title/action pairs
- [[Tickmark Indicator]] — marks the active player
- [[Settings Persistence Pattern]] — persists `Plugin` + `PlayerName`

## Used by

- [[Context Menu Flow]]
- [[Music Widget]] — right-click opens this menu

## Gotchas

- Music is the only context that persists two keys per choice; most write one.

## See also

- [[_index]]
- [[Context Menu Factory Pattern]]
