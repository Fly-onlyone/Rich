---
tags: [framework, themes]
---

# Light Theme

> A static theme that sets fixed light background/foreground hex colors and `DarkMode=0`.

## Source

- `@Resources/Scripts/Themes/Light.inc` — the theme definition

## How it works

`Light.inc` is the simplest theme: a single `[Variables]` section with no [[Measure]]s. It sets `BackgroundColor=#LightThemeBackground#` and `ForegroundColor=#LightThemeForeground#` (drawing the values from global variables) and hard-codes `DarkMode=0`.

It also restores the default layout metrics — `WidgetPadding=#PaddingBase#` and `WidgetRadius=#RadiusBase#` — so a widget switching away from [[Blur Theme]] gets its normal padding and radius back. Because nothing is computed, there is no plugin dependency and the theme applies instantly on load.

## Depends on

- [[Theme System]] — includes this file when `#Theme#` is `Light`

## Used by

- [[Auto Theme]] — falls back to these colors when `DarkMode` is 0
- [[Theming Flow]]

## See also

- [[_index]]
- [[Dark Theme]]
- [[Theme System]]
