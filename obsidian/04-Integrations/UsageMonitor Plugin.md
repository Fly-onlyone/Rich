---
tags: [integration]
---

# UsageMonitor Plugin

> The built-in Rainmeter [[Plugin]] that reads Windows performance counters — used by the Monitor widget for CPU and disk usage.

## Used for
- [[Monitor Widget]] — the CPU and Disk usage gauges. (RAM and Network now use Rainmeter's built-in `PhysicalMemory` and `NetIn`/`NetOut` measure types instead — see [[Monitor Metrics]].)

## Configuration
- CPU: `Alias=CPU` — the plugin's shortcut for `Processor \ % Processor Time \ _Total`. (The Windows 8+ `Processor Information \ % Processor Utility` counter was tried but reads ≈2× high on Turbo-Boosting CPUs, so the legacy counter is the closer match to Task Manager.)
- Disk: `Category=PhysicalDisk`, `Counter=% Idle Time`, `Name=_Total`, `InvertMeasure=1` — inverting idle time yields disk *activity* (= Task Manager's "active time"). `Name=_Total` must be pinned, or the plugin reads an arbitrary disk instance.
- Each measure's `UpdateDivider` is a [[Theme-As-Number Pattern]]-style expression `(#BatterySaverMode# = 0 ? 10 : 20)`.

## Wire-up
- `@Resources/Scripts/Widgets/Monitor.inc` — `[CPUMonitor]`, `[DiskMonitor]`

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- `% Idle Time` is a well-behaved 0–100 counter; the old `% Disk Time` overflowed past 100.
- Disk and processor categories expose multiple instances — pin `Name=` (`_Total`) or the reading is an arbitrary instance, not the system total.
- The plugin DLL must be bundled in the `.rmskin` or the Monitor widget fails to load.

## See also
- [[_index]]
- [[PowerPlugin]]
