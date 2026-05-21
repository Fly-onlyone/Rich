---
tags: [framework, settings]
---

# Battery Settings Tab

> The settings tab that toggles Battery Saver Mode and the optional automatic low-power switch.

## Source

- `@Resources/Scripts/Settings/Battery.inc` — the tab content: two toggle rows and help text

## How it works

`Battery.inc` draws a `BatterySaverMode` toggle as two [[Shape Meter]] pills — `BatterySaverModeFalse` (grey) and `BatterySaverModeTrue` (green). Each is hidden based on the `#BatterySaverMode#` [[Variable]]; clicking flips it via `!WriteKeyValue Variables BatterySaverMode <0|1>` into `Global.inc` followed by `!RefreshGroup Rich`. Battery Saver Mode reduces widget animation and refresh rate.

A second row, `BatteryAuto`, toggles the [[AutoLowPowerMode Skin]]. Its state is read with the [[ConfigActive Plugin]] (`[&BatteryAutoOpened:]`), and clicking runs `!ToggleConfig` on `Rich\Extras\AutoLowPowerMode`. Localized help text sits below both rows.

## Depends on

- [[Shape Meter]] — draws the toggle pills
- [[ConfigActive Plugin]] — detects whether AutoLowPowerMode is loaded
- [[AutoLowPowerMode Skin]] — the companion skin the second toggle controls
- [[Global Variables]] — `BatterySaverMode` is persisted here

## Used by

- [[Settings Tab Dispatch]] — loads this file when `SettingsTab=Battery`

## See also

- [[_index]]
- [[Settings Persistence Pattern]]
- [[Extras Settings Tab]]
