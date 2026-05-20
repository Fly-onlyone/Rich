---
tags: [integration]
---

# Chameleon Plugin

> A Rainmeter [[Plugin]] that samples colours from the desktop wallpaper so the skin can adapt its palette automatically.

## Used for
- [[Color Theme]] — background, foreground, and dark-mode detection
- [[Blur Theme]] — luminance-driven light/dark choice
- [[Music Widget]] — accent colours sampled from album art / wallpaper
- [[ThemeUpdater Skin]] — keeps the desktop sample fresh

## Configuration
- `Type=Desktop` — sample the wallpaper; child measures use `Parent=` to share it
- `Color=Average` / `Foreground1` — pick a background or foreground colour
- `Color=Luminance` with `RegExpSubstitute=1` and a `Substitute` maps brightness to a `0`/`1` dark-mode flag
- `OnUpdateAction` pushes results into `#BackgroundColor#`, `#ForegroundColor#`, `#DarkMode#`

## Wire-up
- `@Resources/Scripts/Themes/Color.inc` — `[ChameleonMeasure]` and colour children
- `@Resources/Scripts/Themes/Blur.inc` — `[DarkMode]` luminance child

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- Child measures must set `Parent=ChameleonMeasure`; a stray measure without a parent re-samples the desktop independently.
- The plugin DLL must be bundled in the `.rmskin` or all themes break.

## See also
- [[_index]]
- [[FrostedGlass Plugin]]
