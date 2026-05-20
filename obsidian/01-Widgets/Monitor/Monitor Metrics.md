---
tags: [widgets, monitor]
---

# Monitor Metrics

> The five system measures (CPU, RAM, Disk, Net, Battery) that supply usage percentages to the Monitor widget's slots.

## Source

- `@Resources/Scripts/Widgets/Monitor.inc` — `CPUMonitor`, `RAMMonitor`, `DiskMonitor`, `NetBytes`/`NetWidth`, `BatteryMeasure` and their `Rounded` companions
- `@Resources/Variables/Monitor.inc` — slot assignments and threshold colors

## How it works

CPU, RAM, Disk, and Net are [[UsageMonitor Plugin]] measures: CPU uses `Alias=CPU`, the others select a `Category`/`Counter` pair. `BatteryMeasure` uses the [[PowerPlugin]] `PowerState=Percent`. Each raw measure has a `Calc` companion (`CPURounded`, `RAMRounded`, ...) that rounds the value to a whole number for display and threshold checks.

Network is special: `NetBytes` and `NetWidth` are combined in `NetRounded` as `NetBytes * 8 / NetWidth * 100` and clamped 0-100. Each raw measure's `OnChangeAction` updates its `Rounded` measure, which then triggers [[Monitor Gauge Animation]].

`UpdateDivider` is `#BatterySaverMode#`-aware — 10 ticks normally, 20 in saver mode — so polling slows to save power. See [[Battery Settings Tab]].

## Depends on

- [[UsageMonitor Plugin]] — CPU/RAM/Disk/Net counters
- [[PowerPlugin]] — battery percent
- [[Per-Widget Variables]] — `BatterySaverMode`, slot names

## Used by

- [[Monitor Widget]] — slots bind to `[#MeterN#]Measure`
- [[Monitor Color Thresholds]] — reads raw measures
- [[Monitor Gauge Animation]] — animates toward `Rounded` values

## See also

- [[_index]]
- [[Measure]]
