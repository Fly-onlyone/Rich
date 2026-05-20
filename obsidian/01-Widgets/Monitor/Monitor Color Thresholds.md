---
tags: [widgets, monitor]
---

# Monitor Color Thresholds

> Per-metric `IfCondition` logic that colors each Monitor gauge green, yellow, or red based on configurable usage thresholds.

## Source

- `@Resources/Scripts/Widgets/Monitor.inc` — `IfCondition` blocks on `CPURounded`, `RAMRounded`, `DiskRounded`, `NetRounded`, `BatteryMeasure`
- `@Resources/Variables/Monitor.inc` — `GreenColor`, `YellowColor`, `RedColor`, `YellowStarts`, `RedStarts`

## How it works

Each metric's [[Measure]] carries three `IfCondition` rules. Below `#YellowStarts#` (default 75) it `!SetVariable`s the metric's color (e.g. `CPUColor`) to `#GreenColor#`; between `YellowStarts` and `#RedStarts#` (default 90) to `#YellowColor#`; at or above `RedStarts` to `#RedColor#`.

Gauge meters read the color indirectly as `[#[#Meter1]Color]` — the slot variable names the metric, which names the color variable. Battery inverts the logic: it tests `100 - BatteryMeasure`, so a low charge crosses the red threshold.

`YellowStarts` and `RedStarts` are plain variables, so editing `Variables/Monitor.inc` retunes every gauge at once.

## Depends on

- [[Monitor Metrics]] — the raw measures evaluated by `IfCondition`
- [[Per-Widget Variables]] — threshold and color variables

## Used by

- [[Monitor Widget]] — `LineColor` / `PrimaryColor` read the color variable

## Gotchas

- Battery uses `100 - value`, opposite to the other metrics — a low battery is the "red" case.

## See also

- [[_index]]
- [[Theming Flow]]
