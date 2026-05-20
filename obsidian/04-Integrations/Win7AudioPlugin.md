---
tags: [integration]
---

# Win7AudioPlugin

> The built-in Rainmeter [[Plugin]] that reads and sets the system master (default-device) audio volume.

## Used for
- [[Volume Widget]] — the main system volume bar and mute icon

## Configuration
- `[VolumeMeasure]` is a plain `Plugin=Win7AudioPlugin` [[Measure]] with `UpdateDivider=1` and `DynamicVariables=1`.
- Its `OnChangeAction` updates `[VolumeChangedAction]` and kicks the `VolumeMeasureAnimation` [[ActionTimer Plugin]].
- `[VolumeChangedAction]` maps the volume into icon tiers (`-1` muted/absent, `0`, `1`, `2`, `3`) and a `VolumeMute` flag.

## Wire-up
- `@Resources/Scripts/Widgets/Volume.inc` — `[VolumeMeasure]` and `[VolumeChangedAction]`

## Auth mode
N/A (Rainmeter plugin DLL — ships with Rainmeter)

## Gotchas
- Win7AudioPlugin ships with Rainmeter, so unlike third-party plugins it does not need separate bundling.
- A value of `-1` means muted or no default device; the widget treats it as a distinct icon state.

## See also
- [[_index]]
- [[AppVolume Plugin]]
