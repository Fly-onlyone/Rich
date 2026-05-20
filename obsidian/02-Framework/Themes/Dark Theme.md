---
tags: [framework, themes]
---

# Dark Theme

> A static theme that sets fixed dark background/foreground hex colors and `DarkMode=1`.

## Source

- `@Resources/Scripts/Themes/Dark.inc` — the theme definition

## How it works

`Dark.inc` mirrors [[Light Theme]] exactly in structure: a single `[Variables]` section with no [[Measure]]s. It sets `BackgroundColor=#DarkThemeBackground#`, `ForegroundColor=#DarkThemeForeground#`, and hard-codes `DarkMode=1`.

It also resets `WidgetPadding=#PaddingBase#` and `WidgetRadius=#RadiusBase#` to the default layout metrics, so switching to Dark from [[Blur Theme]] restores normal padding and corner radius. Being fully static, it has no plugin dependency and renders immediately.

## Depends on

- [[Theme System]] — includes this file when `#Theme#` is `Dark`

## Used by

- [[Auto Theme]] — falls back to these colors when `DarkMode` is 1
- [[Theming Flow]]

## See also

- [[_index]]
- [[Light Theme]]
- [[Theme System]]
