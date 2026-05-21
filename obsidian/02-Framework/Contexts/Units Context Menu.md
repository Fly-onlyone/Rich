---
tags: [framework, contexts]
---

# Units Context Menu

> The right-click menu for choosing the temperature unit used by weather widgets.

## Source

- `@Resources/Scripts/Contexts/Units.inc` — fills the `Units*` title/action pairs

## How it works

`Contexts/Units.inc` defines `UnitsContextTitle*` / `UnitsContextAction*` pairs for the three temperature units: Celsius, Fahrenheit, Kelvin. Titles are localized strings (`[#tCelsius]`, etc.).

Each action `!WriteKeyValue`s `Units` into `Variables\Global.inc`, then runs `!RefreshGroup Rich` so all widgets re-read the unit — the [[Settings Persistence Pattern]].

A `[SetUnitsTickMark]` String [[Measure]] reads `#Units#` and uses `IfMatch` to append a checkmark `[\x2714]` to the currently-selected unit — the [[Tickmark Indicator]].

## Depends on

- [[Context Scaffold]] — relays the title/action pairs
- [[Tickmark Indicator]] — marks the active unit
- [[Settings Persistence Pattern]] — persists the `Units` value

## Used by

- [[Context Menu Flow]]

## See also

- [[_index]]
- [[Context Menu Factory Pattern]]
