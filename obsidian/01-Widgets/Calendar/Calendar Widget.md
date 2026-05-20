---
tags: [widgets, calendar]
---

# Calendar Widget

> A month-view skin that draws the current month as a weekday-header row plus a day grid, with today circled and weekends dimmed.

## Source

- `Widgets/Calendar/Medium.ini`, `Large.ini` — per-size skin entry points
- `Widgets/Calendar/Settings.ini` — week-start setting panel
- `@Resources/Scripts/Widgets/Calendar.inc` — meters (`Month`, `Label1-7`, `Day1-31`, `RedCircle`)
- `@Resources/Scripts/Widgets/Calendar.lua` — grid layout logic
- `@Resources/Variables/Calendar.inc` — persisted `SundayWeek` setting
- `@Resources/Languages/en/Widgets/Calendar.inc` — month-agnostic strings and `tWeekDays`

## How it works

Each size skin includes `Variables/Calendar.inc`, the `Widget.inc` scaffold, the language file, and `Scripts/Widgets/Calendar.inc`. The `.inc` declares static meters: a `Month` string, seven `Label` meters for the weekday header, 31 `Day` meters, and a `RedCircle`. The `Lua` script measure runs `Initialize()` to position and fill every meter ([[Calendar Grid Logic]]). A `MeasureDay` time measure watches the day number and re-runs `Initialize()` plus `!UpdateMeterGroup Meters` at midnight. The skin refreshes only every 5000 ms — it does not need sub-second updates.

## Depends on

- [[Widget Scaffold]] — sizing and theme variables
- [[Calendar Grid Logic]] — Lua positions the day grid
- [[Calendar Today Highlight]] — circles the current day
- [[Week Start Setting]] — Monday-vs-Sunday first column

## Used by

- [[Skin Composition Flow]]

## See also

- [[_index]]
- [[Clock Widget]]
