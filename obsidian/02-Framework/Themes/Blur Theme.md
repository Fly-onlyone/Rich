---
tags: [framework, themes]
---

# Blur Theme

> A theme that renders an acrylic blur behind widgets using the FrostedGlass plugin while tinting the blur from the selected palette.

## Source

- `@Resources/Scripts/Themes/Blur.inc` — the theme definition

## How it works

`Blur.inc` declares a `[FrostedGlass]` [[Measure]] (`Type=Acrylic`, `Corner=Round`) that paints a system blur behind the skin. It resolves `BackgroundColor`, `ForegroundColor`, and `DarkMode` from the active palette values, then uses `[PaletteThemeState]` to push those values into live variables during refresh.

`[BackgroundMeter]` fills with `#BackgroundColor#a0`. The alpha is still translucent enough for acrylic blur to show through, but it is stronger than the old `...60` tint so palettes such as `CyberpunkNeon` and `TokyoNight` visibly affect widget surfaces.

## Depends on

- [[Theme System]] — includes this file when `#Theme#` is `Blur`
- [[FrostedGlass Plugin]] — provides the acrylic blur

## Used by

- [[Theming Flow]]

## Gotchas

- Blur **overrides** `WidgetPadding=0` and `WidgetRadius=8` — different from the default radius of 20. Other themes reset these to `#PaddingBase#`/`#RadiusBase#`, so layout shifts when switching to or from Blur.
- The background is intentionally semi-transparent (`...a0`); a solid fill would hide the acrylic effect.

## See also

- [[_index]]
- [[Color Theme]]
- [[Theme System]]
