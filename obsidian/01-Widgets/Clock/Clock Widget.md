---
tags: [widgets, clock]
---

# Clock Widget

> An analog clock skin — rotating hands over a clock-face image — that also renders a digital time/date readout in its Wide size.

## Source

- `Widgets/Clock/Small.ini`, `Medium.ini`, `Large.ini`, `Wide.ini` — per-size skin entry points
- `Widgets/Clock/Settings.ini` — settings panel (seconds, 24-hour, timezone)
- `@Resources/Scripts/Widgets/Clock.inc` — shared meter/measure definitions
- `@Resources/Variables/Clock.inc` — persisted user preferences
- `@Resources/Languages/en/Widgets/Clock.inc` — UI strings

## How it works

Every size skin sets `WidgetSize` then pulls in the shared includes via the [[Include Cascade Pattern]]: `Variables/Clock.inc`, the `Widget.inc` scaffold, `Scripts/Widgets/Clock.inc`, and the language file. The Small, Medium and Large sizes render the analog [[Clock Hands]] over an [[Analog Clock Faces]] image. The Wide size is purely digital — it overrides with its own `TimeMeasure`/`DateMeasure` string meters and never includes `Scripts/Widgets/Clock.inc`. The skin updates every 100 ms so the second hand moves smoothly.

## Depends on

- [[Widget Scaffold]] — supplies sizing and theme variables
- [[Clock Hands]] — analog hand meters
- [[Analog Clock Faces]] — dark-mode face image
- [[Clock Timezones]] — selectable time zone

## Used by

- [[Skin Composition Flow]]

## Gotchas

- Wide.ini deliberately omits `@Include3` (`Scripts/Widgets/Clock.inc`) — it is the only digital-only Clock size.

## See also

- [[_index]]
- [[Calendar Widget]]
- [[Timer Widget]]
