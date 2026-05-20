---
tags: [widgets, volume]
---

# Volume Widget

> A Rainmeter widget that displays and controls system audio — master volume plus an optional per-app mixer.

## Source

- `Widgets/Volume/Medium.ini` — Medium layout: device name, level bar, mute icon
- `Widgets/Volume/Large.ini` — Large layout: master bar plus five per-app rows
- `Widgets/Volume/Settings.ini` — exposes the `Step` (scroll increment) option
- `@Resources/Scripts/Widgets/Volume.inc` — shared measures (audio plugins, animations)
- `@Resources/Variables/Volume.inc` — persisted `Step` value

## How it works

Each size `.ini` is a [[Widget Scaffold]] that `@Include`s the shared `Volume.inc` (measures) and the localized strings. [[Master Volume Control]] drives the level [[Shape Meter]] in every size; [[Per-App Volume]] adds the five-app mixer in `Large.ini`. The mute/level icon swaps via the `VolumeIcon` variable. Scroll over the bar steps volume by `#Step#`.

## Depends on

- [[Master Volume Control]] — the always-present level control
- [[Per-App Volume]] — the Large-only mixer
- [[Widget Scaffold]] — common skin structure

## Used by

- [[Skin Composition Flow]]

## See also

- [[_index]]
- [[Settings Persistence Flow]]
