---
tags: [widgets, music]
---

# Music Widget

> A now-playing widget that shows the current track's title, artist, and album cover, with hover-revealed transport controls.

## Source

- `Widgets/Music/Medium.ini` — Medium-size layout (cover + text + buttons)
- `Widgets/Music/Large.ini` — Large-size layout with cropped cover mask
- `Widgets/Music/Settings.ini` — settings panel (player picker row)
- `@Resources/Scripts/Widgets/Music.inc` — shared measures
- `@Resources/Languages/en/Widgets/Music.inc` — UI strings

## How it works

Both size variants follow the [[Widget Scaffold]] pattern: they pull in `Variables/Music.inc`, the shared `Widget.inc`, the measure script `Scripts/Widgets/Music.inc`, and the localized strings. The shared script defines `TitleMeasure`, `ArtistMeasure`, `CoverMeasure`, and `StateMeasure` via [[Media Player Integration]].

Each [[Meter]] reads its [[Measure]] with `DynamicVariables=1`. `StateMeasure` (0 = stopped, 1 = playing, 2 = paused) drives `Hidden` flags so play/pause/back/next buttons appear only on hover. When stopped, `NoMusicMeter` shows the localized "No music" string. Double-clicking the background launches `#MusicApp#`.

## Depends on

- [[Media Player Integration]] — supplies track metadata and transport bangs
- [[Album Art Coloring]] — recolors the widget from the cover
- [[Widget Scaffold]] — include chain and proportional sizing

## Used by

- [[Skin Composition Flow]] — placed onto the desktop as a skin

## Gotchas

- `Hidden` formulas combine `#Hovered#` with `[StateMeasure]` — both must be re-evaluated, so meters carry `DynamicVariables=1`.

## See also

- [[_index]]
- [[Music Context Menu]]
- [[Settings Persistence Flow]]
