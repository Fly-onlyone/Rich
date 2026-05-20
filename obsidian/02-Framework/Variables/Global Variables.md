---
tags: [framework, variables]
---

# Global Variables

> `Global.inc` — the skin-wide defaults every scaffold includes first: theme, language, units, base sizes, fonts, colors.

## Source

- `@Resources/Variables/Global.inc` — the `[Variables]` block of skin-wide defaults

## How it works

`Global.inc` is the root of the [[Include Cascade Pattern]] — every scaffold `@Include`s it before anything else. It declares:

- **Appearance state** — `Palette` (default `Light`), `Theme` as the effect selector (default `Blur`), `DarkMode`, `BatterySaverMode`, the `DarkThemeFrom`/`DarkThemeTo` schedule (`23:00`–`09:00`), and `WidgetOpacity` (whole-widget transparency percent, default `100` — see [[Widget Scaffold]]).
- **Colors** — light/dark/wallpaper-effect background and foreground hex values plus `GrayColor`; popular fixed palettes live under `Scripts/Palettes/`.
- **Sizing** — `WidgetBase`, `PaddingBase`, `RadiusBase` (see [[WidgetBase Grid Unit]]).
- **Locale** — `Language` (`en`), `Units` (`celsius`), `FontFace` (`SF Pro Display`).

Because it loads first, any later include can override a value or reference it as a [[Variable]].

## Used by

- [[Widget Scaffold]], [[Window Scaffold]], [[Settings Scaffold]], [[WhatsNew Scaffold]]

## Gotchas

- `Theme` is still the persisted effect string for compatibility; the scaffolds add an `EffectAsNumber` measure to map it numerically — see [[Theme As Number]].

## See also

- [[_index]]
- [[Theme System]]
- [[Theming Flow]]
