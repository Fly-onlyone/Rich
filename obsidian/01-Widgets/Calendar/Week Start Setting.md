---
tags: [widgets, calendar]
---

# Week Start Setting

> The `SundayWeek` toggle that decides whether the calendar's first column is Sunday or Monday, re-laying both the header and the day grid.

## Source

- `@Resources/Variables/Calendar.inc` — stores `SundayWeek` (default `0`)
- `Widgets/Calendar/Settings.ini` — `Option1` toggle UI
- `@Resources/Scripts/Widgets/Calendar.lua` — reads `SundayWeek` in layout math

## How it works

`SundayWeek` is a 0/1 flag. The Settings skin shows a labelled switch (`tCalendarSundayWeek`, "Week starts on Sunday"); clicking it runs `!WriteKeyValue Variables SundayWeek <0|1>` against `Variables/Calendar.inc` then `!Refresh`. On the next load, `Calendar.lua` uses `SundayWeek` in three places: `initWeekdayLabels` rotates the header label order with `(a - SundayWeek) % 7`, `initDaysLabels` shifts each day's column with `(weekday - 1 + SundayWeek) % 7`, and `isLastWeekDay`/`getWeekCount` use it to decide where week-rows break. The whole grid re-lays from one variable.

## Depends on

- [[Settings Persistence Pattern]] — `!WriteKeyValue` persists the toggle
- [[Calendar Grid Logic]] — consumes `SundayWeek` in column math
- [[Localization Token Pattern]] — `tWeekDays` supplies the header letters

## Used by

- [[Calendar Widget]]

## Gotchas

- The setting only takes effect after `!Refresh`; the Lua reads it once at `Initialize()`.

## See also

- [[_index]]
- [[Calendar Today Highlight]]
