---
tags: [framework, settings]
---

# Theme Selector

> The Appearance tab selector that lets the user choose a fixed color palette separately from the visual effect.

## Source

- `@Resources/Scripts/Settings/Appearence/ThemeSelector.inc` — palette swatch grid plus effect selector

## How it works

`ThemeSelector.inc` draws Shape-meter swatches for `Light`, `Dark`, and the popular palettes (`Dracula`, `CatppuccinMocha`, `SolarizedDark`, `Nord`, `GruvboxDark`, `TokyoNight`, `OneDark`, `Monokai`, `RosePine`, `EverforestDark`, `CyberpunkNeon`). Clicking a swatch writes `Palette` in `Global.inc`, then runs `!RefreshGroup Monterey` so every skin in the `Monterey` group — all loaded widgets and the settings panel — reloads and picks up the palette include change immediately.

The effect row writes the legacy `Theme` variable as `Solid`, `Auto`, `Color`, or `Blur`. Auto and Color additionally `!ActivateConfig` `#ROOTCONFIG#\Extras\ThemeUpdater`, since those dynamic modes still need the background updater running and the skin root may not be named `Monterey` during development. Hidden border groups mark the active palette and effect.

## Depends on

- [[Global Variables]] — `Palette` and `Theme` are written into `Global.inc`
- [[Theme System]] — resolves the selected palette and effect
- [[ThemeUpdater Skin]] — activated for Auto/Color modes

## Used by

- [[Appearance Settings Tab]] — includes this as its top subfile

## See also

- [[_index]]
- [[Theming Flow]]
- [[Theme Options]]
