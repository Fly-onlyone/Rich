---
tags: [widgets, calendar]
---

# Calendar Today Highlight

> The accent-coloured filled circle drawn behind the current day's number, with weekend days dimmed for visual contrast.

## Source

- `@Resources/Scripts/Widgets/Calendar.inc` — `RedCircle` shape meter
- `@Resources/Scripts/Widgets/Calendar.lua` — `initRedCircle`, `getTextColor`, `isWeekend`

## How it works

`RedCircle` is a [[Shape Meter]] ellipse filled with the active palette's `#PaletteAccentColor#`, sized off `WidgetHeight`. (The meter keeps its legacy name `RedCircle`; it is no longer fixed red.) During [[Calendar Grid Logic]] the day loop compares each `dd` against today's date; on a match `initRedCircle(x, y)` bangs the circle's `X`/`Y` to that cell. Text color is decided by `getTextColor(weekday, today)`: today's number uses `[#BackgroundColor]` so a dark digit reads over the bright accent disc (and a light digit over the Light palette's blue accent); other days use `#ForegroundColor#` with opacity `ff` on weekdays and `80` on weekends, so Saturday/Sunday appear dimmed. The same dimming applies to the weekday header `Label` meters.

## Depends on

- [[Calendar Grid Logic]] — supplies the cell coordinates and weekday
- [[Theme System]] — `#PaletteAccentColor#` tints the disc; `#BackgroundColor#`/`#ForegroundColor#` colour the day text
- [[Group Bang Pattern]] — `RedCircle` is in group `Meters`

## Used by

- [[Calendar Widget]]

## Gotchas

- `RedCircle` is declared with no `X`/`Y`; until Lua positions it, it sits at `0,0`.

## See also

- [[_index]]
- [[Week Start Setting]]
