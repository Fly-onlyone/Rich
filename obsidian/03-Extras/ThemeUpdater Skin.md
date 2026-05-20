---
tags: [extras]
---

# ThemeUpdater Skin

> A headless extra [[Skin]] that switches the skin between light and dark on a daily time schedule.

## Source
- `Extras/ThemeUpdater/ThemeUpdater.ini` — the skin config

## How it works
The skin converts the current time and the configured `#DarkThemeFrom#` / `#DarkThemeTo#` boundaries into seconds-of-day (`[SecondsNow]`, `[SecondsStart]`, `[SecondsEnd]`). The `[IsBetween]` Calc [[Measure]] tests whether *now* falls inside the dark window, handling both same-day and overnight ranges.

Four `IfCondition` branches compare `#DarkMode#` against `[IsBetween]`; whenever they disagree, `!WriteKeyValue` persists the new `DarkMode` value to `Global.inc` and `!RefreshGroup Monterey` reloads the skin. A separate `[ChameleonMeasure]` (group `ColorTheme`) keeps the [[Chameleon Plugin]] desktop sample fresh for the auto/color themes.

## Depends on
- [[Chameleon Plugin]] — refreshes wallpaper colour sampling
- [[Settings Persistence Pattern]] — persists `DarkMode` to `Global.inc`
- [[DynamicVariables Pattern]] — `[IsBetween]` re-reads `#DarkMode#` at runtime
- [[Group Bang Pattern]] — `!RefreshGroup Monterey` applies the switch

## Used by
- The `Auto` value of [[Theme As Number]] / [[Theming Flow]]

## Gotchas
- The overnight case (`SecondsStart > SecondsEnd`) needs its own pair of conditions; both day and night ranges are covered.

## See also
- [[_index]]
- [[Theming Flow]]
