---
tags: [widgets, clock]
---

# Analog Clock Faces

> The static dial artwork — a tinted circle plus a PNG face image — that the rotating [[Clock Hands]] are layered on top of.

## Source

- `@Resources/Scripts/Widgets/Clock.inc` — `ClockCircle` shape, `Clockface` image meter, `ClockCircleColor` measure
- `Widgets/Clock/Small.ini` — overrides `Clockface` to the small-face image

## How it works

Two stacked meters form the dial. `ClockCircle` is a [[Shape Meter]] ellipse whose fill color is resolved by the `ClockCircleColor` string [[Measure]] via [[Substitute]] — `#DarkMode#` of `0` maps to a translucent white, `1` to a translucent dark gray. On top, the `Clockface` [[Meter]] is an image whose path embeds `#DarkMode#`: `Images/Clock/face-#DarkMode#.png`. Small.ini swaps this for `small-face-#DarkMode#.png`. Both circle and face size off `ClockfaceSize`, derived from `WidgetHeight` and `ClockfacePadding`, so the dial scales per widget size.

## Depends on

- [[Theme System]] — `#DarkMode#` selects the light/dark face PNG
- [[Substitute]] — maps dark-mode flag to a circle fill color
- [[Proportional Layout Pattern]] — `ClockfaceSize` scales the dial

## Used by

- [[Clock Widget]]
- [[Clock Hands]] — hands render over the face

## Gotchas

- The face image is chosen by filename interpolation, not a measure — there is no fallback if the PNG is missing.

## See also

- [[_index]]
- [[Clock Hands]]
