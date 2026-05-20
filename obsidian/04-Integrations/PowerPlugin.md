---
tags: [integration]
---

# PowerPlugin

> The built-in Rainmeter [[Plugin]] that reports battery percentage and AC line (charging) state.

## Used for
- [[Monitor Widget]] — battery percentage bar and battery colour tiers
- [[AutoLowPowerMode Skin]] — detects AC vs battery to toggle `BatterySaverMode`

## Configuration
- `PowerState=Percent` — battery charge 0–100 (used by the Monitor widget)
- `PowerState=ACLine` — `1` on AC power, `0` on battery (used by AutoLowPowerMode)
- The Monitor `[BatteryMeasure]` runs `IfCondition` tiers to set `BatteryColor` green/yellow/red.

## Wire-up
- `@Resources/Scripts/Widgets/Monitor.inc` — `[BatteryMeasure]` with `PowerState=Percent`
- `Extras/AutoLowPowerMode/AutoLowPowerMode.ini` — `[PowerState]` with `PowerState=ACLine`

## Auth mode
N/A (Rainmeter plugin DLL — ships with Rainmeter)

## Gotchas
- On a desktop with no battery, `Percent` behaviour is undefined; the Monitor widget should be hidden in that case.
- PowerPlugin ships with Rainmeter, so it needs no separate bundling.

## See also
- [[_index]]
- [[UsageMonitor Plugin]]
