---
tags: [widgets, calendar]
---

# Calendar Today Highlight

> The red filled circle drawn behind the current day's number, with weekend days dimmed for visual contrast.

## Source

- `@Resources/Scripts/Widgets/Calendar.inc` — `RedCircle` shape meter
- `@Resources/Scripts/Widgets/Calendar.lua` — `initRedCircle`, `getTextColor`, `isWeekend`

## How it works

`RedCircle` is a [[Shape Meter]] ellipse filled `240,60,60`, sized off `WidgetHeight`. During [[Calendar Grid Logic]] the day loop compares each `dd` against today's date; on a match `initRedCircle(x, y)` bangs the circle's `X`/`Y` to that cell. Text color is decided by `getTextColor(weekday, today)`: today's number is forced white (`ffffff`) so it reads over the red disc; other days use `#ForegroundColor#` with opacity `ff` on weekdays and `80` on weekends, so Saturday/Sunday appear dimmed. The same dimming applies to the weekday header `Label` meters.

## Depends on

- [[Calendar Grid Logic]] — supplies the cell coordinates and weekday
- [[Theme System]] — `#ForegroundColor#` adapts day text to the theme
- [[Group Bang Pattern]] — `RedCircle` is in group `Meters`

## Used by

- [[Calendar Widget]]

## Gotchas

- `RedCircle` is declared with no `X`/`Y`; until Lua positions it, it sits at `0,0`.

## See also

- [[_index]]
- [[Week Start Setting]]
