---
tags: [integration]
---

# ConfigActive Plugin

> A Rainmeter [[Plugin]] that reports whether a given skin [[Config]] is currently loaded.

## Used for
- [[Widgets Settings Tab]] — shows which widgets are active
- [[Extras Settings Tab]] — shows which extras are active
- [[Battery Settings Tab]] — shows whether AutoLowPowerMode is running

## Configuration
- `Plugin=ConfigActive` with `ConfigName=` set to the skin path to probe.
- Returns `1` when that config is loaded, `0` when it is not — typically read into a toggle/checkbox meter.

## Wire-up
- `@Resources/Scripts/Settings/Widgets.inc` — per-widget active checks
- `@Resources/Scripts/Settings/Extras.inc` — per-extra active checks
- `@Resources/Scripts/Settings/Battery.inc` — AutoLowPowerMode active check

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- `ConfigName` must match the config's folder path exactly, or the measure always reports `0`.
- The plugin DLL must be bundled in the `.rmskin` or the settings tabs fail to load.

## See also
- [[_index]]
- [[TrayIcon Plugin]]
