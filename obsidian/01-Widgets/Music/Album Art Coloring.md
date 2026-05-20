---
tags: [widgets, music]
---

# Album Art Coloring

> Recolors the Music widget's background and foreground to match the dominant colors sampled from the current album cover.

## Source

- `@Resources/Scripts/Widgets/Music.inc` — `CoverChameleonMeasure`, `CoverColor`, `CoverForegroundColor`, `IsColorTheme`

## How it works

`CoverChameleonMeasure` is a [[Chameleon Plugin]] `Type=File` measure whose `Path` points at `CoverMeasure` (see [[Media Player Integration]]). When the cover image changes, its `OnUpdateAction` updates the two child color measures and redraws.

`CoverColor` extracts the cover's `Average` color; `CoverForegroundColor` extracts a readable `Foreground1` color. Each uses `IfCondition` against `StateMeasure`: while a track is loaded it `!SetVariable`s `BackgroundColor` / `ForegroundColor` to the sampled values; when stopped it falls back to `#LightThemeBackground#` / `#LightThemeForeground#`, then updates the affected meters.

Both color measures are `Disabled` when `IsColorTheme=1` — meaning themes 4 and 5 already supply a fixed color scheme, so cover sampling is skipped.

## Depends on

- [[Chameleon Plugin]] — samples palette colors from the image
- [[Media Player Integration]] — provides the cover path
- [[Theming Flow]] — `IsColorTheme` decides whether to override theme colors

## Used by

- [[Music Widget]] — its meters read `BackgroundColor` / `ForegroundColor`

## Gotchas

- On color themes (4, 5) coloring is disabled — do not expect the widget to recolor there.

## See also

- [[_index]]
- [[DynamicVariables Pattern]]
