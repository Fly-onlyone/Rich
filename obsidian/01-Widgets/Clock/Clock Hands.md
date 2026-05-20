---
tags: [widgets, clock]
---

# Clock Hands

> The three rotating analog hands (hour, minute, second) drawn as combined shapes and spun by angles derived from the current time.

## Source

- `@Resources/Scripts/Widgets/Clock.inc` — `HourHand`, `MinuteHand`, `SecondHand` shape meters and the `Time` measure
- `@Resources/Variables/Clock.inc` — `ShowSeconds` toggle that hides the second hand

## How it works

A single `[Time]` measure runs `OnUpdateAction` bangs that compute three angle variables from the section's seconds value using modulo arithmetic: `SecondsAngle = (sec % 60) * 6`, `MinutesAngle = (sec % 3600) / 10`, and `HoursAngle = (sec % 43200) / 120`. Each hand is a [[Shape Meter]] that unions a counterweight rectangle with a pointer rectangle, then applies `Combine ... | Rotate <angle>,centerX,centerY`. Hand thickness and length come from proportional variables (`ClockhandWidth`, `HourHandHeight`, etc.). Hands recolor with dark mode via `#ForegroundColor#`; the second hand is fixed orange (`ff9900`).

## Depends on

- [[Update & Refresh Model]] — `OnUpdateAction` and `UpdateDivider` drive the rotation
- [[Proportional Layout Pattern]] — hand dimensions scale with `WidgetHeight`
- [[DynamicVariables Pattern]] — angle variables must re-evaluate each tick

## Used by

- [[Clock Widget]]
- [[Analog Clock Faces]] — hands are layered over the face

## Gotchas

- `SecondHand` is `Hidden` when `ShowSeconds = 0`; Small.ini also overrides its shapes to be thinner.
- When `ShowSeconds = 0` (or battery saver), `UpdateDivider` becomes 10 so hands only step every second.

## See also

- [[_index]]
- [[Analog Clock Faces]]
