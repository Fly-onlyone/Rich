---
tags: [framework, themes]
---

# Color Theme

> A dynamic theme that samples the desktop wallpaper with the Chameleon plugin to derive accent-matched colors.

## Source

- `@Resources/Scripts/Themes/Color.inc` — the theme definition

## How it works

`Color.inc` adds a `[ChameleonMeasure]` parent (`Plugin=Chameleon`, `Type=Desktop`) plus child [[Measure]]s that read the wallpaper: `BackgroundColor` (`Color=Average`), `ForegroundColor` (`Color=Foreground1`), and `DarkMode` (`Color=Luminance`).

The `DarkMode` measure uses `RegExpSubstitute` to bucket the luminance into `0` (bright wallpaper) or `1` (dark wallpaper), then writes it back to the `#DarkMode#` [[Variable]].

Two String measures, `[ColorThemeBackground]` and `[ColorThemeForeground]`, take user-configured templates and `Substitute` the placeholders `%0` (background) and `%1` (foreground) with the sampled colors, then push the result into `BackgroundColor`/`ForegroundColor` via `OnUpdateAction`.

## Depends on

- [[Theme System]] — includes this file when `#Theme#` is `Color`
- [[Chameleon Plugin]] — samples the desktop palette
- [[Substitute]] — fills the `%0`/`%1` placeholders

## Used by

- [[Theming Flow]]

## See also

- [[_index]]
- [[Blur Theme]]
- [[Theme System]]
