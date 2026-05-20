---
tags: [integration]
---

# MediaPlayer Plugin

> A Rainmeter [[Plugin]] that exposes now-playing metadata and transport controls for whatever media app is active.

## Used for
- [[Music Widget]] — track title, artist, album art, progress, and play/pause/skip controls

## Configuration
- A parent `Measure=Plugin` / `Plugin=MediaPlayer` measure with child measures setting `PlayerType=` for title, artist, cover, position, state, etc.
- Transport actions are issued through `!CommandMeasure` bangs (`PlayPause`, `Next`, `Previous`).

## Wire-up
- `@Resources/Variables/Music.inc` — `Plugin=MediaPlayer` declarations for the Music widget

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- The plugin reports nothing when no supported player is running; the widget should handle the empty state.
- The plugin DLL must be bundled in the `.rmskin` or the Music widget fails to load.

## See also
- [[_index]]
- [[Win7AudioPlugin]]
