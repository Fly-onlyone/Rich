---
tags: [extras]
---

# AutoLowPowerMode Skin

> A headless extra [[Skin]] that watches AC power state and flips the `BatterySaverMode` variable so widgets throttle their update rates on battery.

## Source
- `Extras/AutoLowPowerMode/AutoLowPowerMode.ini` — the skin config

## How it works
The skin is invisible: it has only a `[DummyMeter]` and a single `[PowerState]` [[Measure]]. That measure uses the [[PowerPlugin]] with `PowerState=ACLine`, returning `1` on AC power and `0` on battery, polled every 60 updates.

Its `OnChangeAction` runs `!WriteKeyValue` to persist `BatterySaverMode` as `(1-#CURRENTSECTION#)` into `@Resources/Variables/Global.inc`, then `!RefreshGroup Monterey` to reload every skin in the group. Because `BatterySaverMode` flips to `1` on battery, widgets like the [[Monitor Widget]] read it through their `UpdateDivider` expressions and slow down.

## Depends on
- [[PowerPlugin]] — supplies the `ACLine` power state
- [[Settings Persistence Pattern]] — persists `BatterySaverMode` to `Global.inc`
- [[Group Bang Pattern]] — `!RefreshGroup Monterey` applies the change everywhere

## Used by
- [[Battery Settings Tab]] — toggles this extra on or off

## Gotchas
- It writes the inverse of the section value (`1-#CURRENTSECTION#`); `BatterySaverMode=1` means *on battery*.

## See also
- [[_index]]
- [[Update & Refresh Model]]
