---
tags: [widgets, monitor]
---

# Monitor Widget

> A system-resource widget that displays CPU, RAM, Disk, Network, and Battery usage as animated gauges or histogram bars.

## Source

- `Widgets/Monitor/Medium.ini` — 2x2 Roundline gauge layout
- `Widgets/Monitor/Large.ini` — 6-row Histogram list layout
- `Widgets/Monitor/Settings.ini` — per-slot metric picker
- `@Resources/Scripts/Widgets/Monitor.inc` — measures and animation
- `@Resources/Languages/en/Widgets/Monitor.inc` — UI strings

## How it works

Following the [[Widget Scaffold]] pattern, both variants include `Variables/Monitor.inc`, `Widget.inc`, the `Monitor.inc` measure script, and localized strings. Each visible slot reads a `#Meter1#`..`#Meter6#` variable that names which [[Monitor Metrics]] feed it, so slots are fully reconfigurable.

Medium draws four `Roundline` [[Meter]]s; Large draws up to six `Histogram` rows that hide themselves when their measure equals `-1` (the `None` metric). [[Monitor Color Thresholds]] tint each gauge, and [[Monitor Gauge Animation]] eases the needle toward new values. Double-clicking opens Task Manager.

## Depends on

- [[Monitor Metrics]] — the measures behind each slot
- [[Monitor Gauge Animation]] — smooth needle movement
- [[Monitor Color Thresholds]] — green/yellow/red coloring
- [[Widget Scaffold]] — include chain and layout variables

## Used by

- [[Skin Composition Flow]] — placed onto the desktop as a skin

## Gotchas

- A slot set to `None` resolves to `-1`; its meters are hidden via `Hidden` formulas — empty slots are intentional, not bugs.

## See also

- [[_index]]
- [[Monitor Context Menu]]
- [[Battery Settings Tab]]
