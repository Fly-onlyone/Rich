---
tags: [framework, contexts]
---

# Monitor Context Menu

> The right-click menu of the Monitor widget for choosing which system metric a meter slot displays.

## Source

- `@Resources/Scripts/Contexts/Monitor.inc` — fills the `Monitor*` title/action pairs

## How it works

`Contexts/Monitor.inc` defines `MonitorContextTitle*` / `MonitorContextAction*` pairs: None, CPU, RAM, Disk, Net, Battery.

Each action `!WriteKeyValue`s the chosen metric into the variable named by `[#Meter]` — the indirection lets one menu file serve whichever meter slot was right-clicked — writing into `Variables\Monitor.inc`, then `!Refresh`. This follows the [[Settings Persistence Pattern]].

A `[SetTickMark]` String [[Measure]] reads `[#[#Meter]]` and uses `IfMatch` with `!SetOption` to append `[\x2714]` to the active metric's title — the [[Tickmark Indicator]].

## Depends on

- [[Context Scaffold]] — relays the title/action pairs
- [[Tickmark Indicator]] — marks the active metric
- [[Settings Persistence Pattern]] — persists the `Meter` slot's value

## Used by

- [[Context Menu Flow]]
- [[Monitor Widget]] — right-click opens this menu

## Gotchas

- Writes to the variable named by `#Meter#`, not a fixed key — the slot must be set before the menu opens.

## See also

- [[_index]]
- [[Context Menu Factory Pattern]]
