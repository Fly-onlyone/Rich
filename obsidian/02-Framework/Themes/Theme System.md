---
tags: [framework, themes]
---

# Theme System

> The mechanism by which the active palette and effect `.inc` files are `@Include`d to supply `BackgroundColor`, `ForegroundColor`, and `DarkMode` to every widget.

## Source

- `@Resources/Scripts/Includes/Widget.inc` — includes `Palettes/#Palette#.inc` before `Themes/#Theme#.inc`
- `@Resources/Scripts/Palettes/` — fixed palette color contracts
- `@Resources/Scripts/Themes/` — visual effect contracts

## How it works

Every widget pulls in [[Widget Scaffold]] (`Includes/Widget.inc`), which includes the selected palette first and the selected effect second. `#Palette#` selects a fixed color file such as `Dracula`, `CatppuccinMocha`, or `CyberpunkNeon`; `#Theme#` is retained as the effect variable and selects `Solid`, `Auto`, `Color`, or `Blur`.

Each palette file defines `PaletteBackgroundColor`, `PaletteForegroundColor`, `PaletteAccentColor`, and `PaletteDarkMode`. Each effect file must resolve the final `BackgroundColor`, `ForegroundColor`, and `DarkMode` values that meters consume. `PaletteAccentColor` is the scheme's signature hue (e.g. Dracula purple, Nord frost, Gruvbox orange); it is read straight from the palette — independent of the active effect — for the clock second hand and the calendar today-highlight. `Solid` and `Blur` also use `[PaletteThemeState]` to push the palette values into live variables during refresh so loaded widgets repaint from the selected palette. The `BackgroundMeter` shape then fills with `#BackgroundColor#`.

## Depends on

- [[Widget Scaffold]] — performs the `@Include`
- [[Theme As Number]] — maps the effect value in `#Theme#` to a comparable integer

## Used by

- [[Theming Flow]] — describes the end-to-end resolution
- Every [[Widget Scaffold]]-based skin

## See also

- [[_index]]
- [[Theming Flow]]
