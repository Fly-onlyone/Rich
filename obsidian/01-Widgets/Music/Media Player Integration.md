---
tags: [widgets, music]
---

# Media Player Integration

> The set of plugin measures that fetch now-playing metadata and send transport commands to whichever music player the user selected.

## Source

- `@Resources/Scripts/Widgets/Music.inc` — `TitleMeasure`, `ArtistMeasure`, `CoverMeasure`, `StateMeasure`
- `@Resources/Variables/Music.inc` — `Plugin` and `PlayerName` defaults

## How it works

Four measures of type [[Plugin]] each set `Plugin=#Plugin#` and `PlayerName=#PlayerName#`, differing only by `PlayerType` (`Title`, `Artist`, `Cover`, `State`). They read live data from the [[MediaPlayer Plugin]] (or `NowPlaying`, depending on the selected player).

`CoverMeasure` exposes a cover image path used by [[Album Art Coloring]]. `StateMeasure` reports playback state and, via `OnUpdateAction`, refreshes the button [[Meter]] group. Transport [[Bang]]s are sent with `!CommandMeasure "TitleMeasure" "PlayPause"` (also `Next`, `Previous`) from the button meters.

`Plugin` and `PlayerName` are written by the [[Music Context Menu]] — picking AIMP, Spotify, iTunes, etc. switches the plugin and player name together.

## Depends on

- [[MediaPlayer Plugin]] — underlying now-playing data source
- [[Per-Widget Variables]] — stores `Plugin` / `PlayerName`

## Used by

- [[Music Widget]] — binds meters to these measures
- [[Album Art Coloring]] — consumes `CoverMeasure`

## Gotchas

- `Plugin` may be `MediaPlayer` or `NowPlaying` — the context menu sets the matching pair; mismatching them breaks playback data.

## See also

- [[_index]]
- [[Music Context Menu]]
