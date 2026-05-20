---
tags: [framework, themes]
---

# Auto Theme

> A theme that picks the Light or Dark color set at runtime based on the `DarkMode` variable.

## Source

- `@Resources/Scripts/Themes/Auto.inc` — the theme definition

## How it works

`Auto.inc` resets the layout metrics (`WidgetPadding`, `WidgetRadius`) like the static themes, then adds an `[AutoThemeMeasure]` Calc [[Measure]]. Its `Formula` reads `#DarkMode#` and an `IfCondition` tests `(#DarkMode# = 1)`.

- `IfTrueAction` sets `BackgroundColor`/`ForegroundColor` to the **dark** globals — the same values [[Dark Theme]] uses.
- `IfFalseAction` sets them to the **light** globals — the same as [[Light Theme]].

So Auto does not define its own palette; it switches between the two static palettes by branching on whatever currently populates `#DarkMode#` (typically the system light/dark setting).

## Depends on

- [[Theme System]] — includes this file when `#Theme#` is `Auto`
- [[Light Theme]] / [[Dark Theme]] — supplies the two palettes it switches between

## Used by

- [[Theming Flow]]

## Gotchas

- Auto only reacts to whatever sets `#DarkMode#`; it does not detect the wallpaper itself like [[Color Theme]] does.

## See also

- [[_index]]
- [[Color Theme]]
- [[Theme System]]
