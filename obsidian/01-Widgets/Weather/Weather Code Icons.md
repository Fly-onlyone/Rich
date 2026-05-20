---
tags: [widgets, weather]
---

# Weather Code Icons

> The substitution table that maps WMO `weathercode` integers to weather icon file names used by the widget's image meters.

## Source

- `@Resources/Scripts/Widgets/Weather.inc` — `IconName` variable and the `*Icon*` measures
- `@Resources/Languages/en/Widgets/Weather.inc` — `tWeatherCode*` descriptive strings

## How it works

The `[Variables]` section defines `IconName`, a comma-separated `Substitute` table mapping WMO `weathercode` values to icon names: `99/96/95`→thunder, `85/82/81/80`→rain, `77/75/73/71`→snow, `67/66/65/63/61`→rain, `57/56/55/53/51`→drizzle, `48/45`→fog, `3`→overcast, `2`→cloudy, `1/0`→sunny. Icon [[Measure]]s (`CurrentIcon`, `HourlyIcon*`, `DailyIcon*`) read a `weathercode` from [[Weather Forecast Parsing]] and apply `Substitute=#IconName#` ([[Substitute]]). [[Meter]]s then load `Images\Weather\[CurrentIcon].png`. The text description is resolved separately via `tWeatherCode<code>` localized strings.

## Depends on

- [[Weather Forecast Parsing]] — supplies the raw `weathercode`
- [[Substitute]] — applies the lookup table

## Used by

- [[Weather Widget]] — icon image meters

## Gotchas

- Icon names and `tWeatherCode*` strings are separate tables; a code with an icon mapping but no localized string would render a blank description.

## See also

- [[_index]]
- [[Localization Flow]]
