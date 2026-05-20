---
tags: [widgets, volume]
---

# Master Volume Control

> The system master-volume readout and slider, backed by `Win7AudioPlugin` and smoothed by `ActionTimer`.

## Source

- `@Resources/Scripts/Widgets/Volume.inc` — `VolumeMeasure`, `VolumeMeasureAnimation`, `VolumeTotal`, `VolumeChangedAction`
- `Widgets/Volume/Medium.ini` / `Large.ini` — `VolumeMeter`, icon, device-name meters

## How it works

`VolumeMeasure` is a [[Win7AudioPlugin]] [[Plugin]] [[Measure]] reading the default device's level. On change it fires `VolumeMeasureAnimation`, an [[ActionTimer Plugin]] measure that eases the `VolumeTotal` variable toward the real value in ten steps (the [[Group Bang Pattern]] drives the redraw). The level [[Shape Meter]] reads `VolumeTotal`; clicking or dragging the bar feeds `SetVolumeWithMouse` back into `ChangeVolume`/`SetVolume`. `VolumeChangedAction` maps the level to `VolumeIcon` (mute / low / mid / high) so the icon image swaps with state.

## Depends on

- [[Win7AudioPlugin]] — reads and sets system volume
- [[ActionTimer Plugin]] — smooths the bar transition

## Used by

- [[Volume Widget]]

## Gotchas

- A level of `-1` means muted; meters use `Hidden` checks on `VolumeIcon`/`VolumeMute` to hide the bar text.

## See also

- [[_index]]
- [[Per-App Volume]]
