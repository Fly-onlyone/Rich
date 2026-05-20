---
tags: [integration]
---

# UsageMonitor Plugin

> The built-in Rainmeter [[Plugin]] that reads Windows performance counters for CPU, memory, disk, and network usage.

## Used for
- [[Monitor Widget]] — the four CPU / RAM / Disk / Network usage bars

## Configuration
- CPU: `Alias=CPU`
- RAM: `Category=Memory`, `Counter=% Committed Bytes In Use`
- Disk: `Category=LogicalDisk`, `Counter=% Disk Time`
- Network: `Category=Network Interface`, `Counter=Bytes total/sec` and `Current bandwidth`
- Each measure's `UpdateDivider` is a [[Theme-As-Number Pattern]]-style expression `(#BatterySaverMode# = 0 ? 10 : 20)`.

## Wire-up
- `@Resources/Scripts/Widgets/Monitor.inc` — `[CPUMonitor]`, `[RAMMonitor]`, `[DiskMonitor]`, `[NetBytes]`, `[NetWidth]`

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- Network usage is computed as `NetBytes * 8 / NetWidth * 100`, clamped to 0–100; `NetWidth` (link bandwidth) refreshes only hourly.
- Disk `% Disk Time` can exceed 100, so `[DiskRounded]` clamps it.
- The plugin DLL must be bundled in the `.rmskin` or the Monitor widget fails to load.

## See also
- [[_index]]
- [[PowerPlugin]]
