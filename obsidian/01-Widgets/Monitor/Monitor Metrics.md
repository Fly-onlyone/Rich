---
tags: [widgets, monitor]
---

# Monitor Metrics

> The five system measures (CPU, RAM, Disk, Net, Battery) that supply usage percentages to the Monitor widget's slots.

## Source

- `@Resources/Scripts/Widgets/Monitor.inc` — `CPUMonitor`, `RAMTotal`/`RAMUsed`/`RAMMonitor`, `DiskMonitor`, `NetIn`/`NetOut`, `BatteryMeasure` and their `Rounded` companions
- `@Resources/Variables/Monitor.inc` — slot assignments, `NetLinkSpeed`, and threshold colors

## How it works

Each metric is sourced to track what Windows Task Manager reports:

- **CPU** — [[UsageMonitor Plugin]] measure with `Alias=CPU` (= `Processor \ % Processor Time`, total). Windows 8+ added a `% Processor Utility` counter that Task Manager nominally uses, but on Turbo-Boosting CPUs it reads markedly higher (≈2× on some hardware), so the legacy `% Processor Time` is the closer practical match. CPU is a bursty signal — it will not match Task Manager to the exact digit moment-to-moment.
- **RAM** — built-in `PhysicalMemory` measures: `RAMTotal` (`Total=1`, total RAM) and `RAMUsed` (RAM in use); `RAMMonitor` is a `Calc` = `RAMUsed / RAMTotal * 100` — physical RAM in use, *not* commit charge. RAM is stable, so this matches Task Manager exactly.
- **Disk** — [[UsageMonitor Plugin]] measure on `Category=PhysicalDisk` / `Counter=% Idle Time` / `Name=_Total` with `InvertMeasure=1`, so it reports *activity* (100 − idle) directly — Task Manager's "active time". `Name=_Total` must be pinned, or UsageMonitor reads an arbitrary disk instance.
- **Net** — built-in `NetIn` + `NetOut` measures, which auto-track the active ("best") interface. `NetRounded` = `(NetIn + NetOut) * 8 / (#NetLinkSpeed# * 1000000) * 100`, clamped 0–100. `NetLinkSpeed` (Mbps, in `Variables/Monitor.inc`, default `1000`) **must match the machine's real adapter link speed**, or the gauge is off by a constant factor.
- **Battery** — [[PowerPlugin]] `PowerState=Percent`.

Each raw measure has a `Calc` companion (`CPURounded`, `RAMRounded`, ...) that rounds the value to a whole number for display and threshold checks. Each `OnChangeAction` updates its `Rounded` measure, which then triggers [[Monitor Gauge Animation]].

`UpdateDivider` is `#BatterySaverMode#`-aware — 10 ticks normally, 20 in saver mode — so polling slows to save power (`RAMTotal` polls far slower, 100/200, since total RAM rarely changes). See [[Battery Settings Tab]].

## Depends on

- [[UsageMonitor Plugin]] — CPU and Disk counters
- [[PowerPlugin]] — battery percent
- [[Per-Widget Variables]] — `BatterySaverMode`, `NetLinkSpeed`, slot names

## Used by

- [[Monitor Widget]] — slots bind to `[#MeterN#]Measure`
- [[Monitor Color Thresholds]] — reads raw measures
- [[Monitor Gauge Animation]] — animates toward `Rounded` values

## See also

- [[_index]]
- [[Measure]]
