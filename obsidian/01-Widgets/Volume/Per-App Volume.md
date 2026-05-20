---
tags: [widgets, volume]
---

# Per-App Volume

> The Large-layout audio mixer that shows and controls volume for up to five individual applications.

## Source

- `@Resources/Scripts/Widgets/Volume.inc` — `AppVolume` parent plus `AppVolume1`–`AppVolume5` children and their animations
- `Widgets/Volume/Large.ini` — `AppName1`–`5`, `VolumeMeter1`–`5`, `SetAppVolumeWithMouse`

## How it works

`AppVolume` is a parent [[AppVolume Plugin]] [[Measure]]; `AppVolume1`–`AppVolume5` are child measures keyed by `Index` that each report one app's name and level. A `Substitute` strips `.exe` from the name. Each child has its own `ActionTimer` animation easing a `VolumeAppN` variable, exactly like [[Master Volume Control]]. Rows hide via `Hidden=([AppVolume:] < N)` when fewer apps are playing. Scrolling, clicking the bar (`SetAppVolumeWithMouse` keyed by `MouseIndex`), or clicking the name (`ToggleMute`) controls each app.

## Depends on

- [[AppVolume Plugin]] — enumerates per-app audio sessions
- [[ActionTimer Plugin]] — smooths each row's bar
- [[Master Volume Control]] — shares the animation pattern

## Used by

- [[Volume Widget]]

## Gotchas

- Only the Large layout includes the mixer; Medium has master volume only.
- `IgnoreSystemSound=1` keeps the Windows system-sounds session out of the list.

## See also

- [[_index]]
- [[Group Bang Pattern]]
