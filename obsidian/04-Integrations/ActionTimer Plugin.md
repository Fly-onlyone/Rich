---
tags: [integration]
---

# ActionTimer Plugin

> A Rainmeter [[Plugin]] that runs timed, stepped sequences of bangs — used everywhere the skin needs smooth animation.

## Used for
- [[Monitor Widget]] — eases usage bars toward new values
- [[Volume Widget]] — eases the master and per-app volume bars
- [[Unlock Skin]] — plays the padlock-opening latch animation

## Configuration
- `ActionListN=` defines a sequence; `Repeat <Action>, <ms>, <count>` loops a step, `Wait <ms>` pauses.
- Each named action (e.g. `AddStep`, `Unlock`) is a key holding the bangs to fire.
- Driven by `!CommandMeasure <measure> "Execute N"` / `"Stop N"`.

## Wire-up
- `@Resources/Scripts/Widgets/Monitor.inc` — `[CPUAnimation]` and siblings
- `@Resources/Scripts/Widgets/Volume.inc` — `[VolumeMeasureAnimation]` and per-app animations
- `Extras/Unlock/Unlock.ini` — `[Animate]`

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- The widgets pick `ActionList1` vs `ActionList2` via `[&ActionList]`, which is `1 + #BatterySaverMode#` — battery saver mode skips the animation and snaps instantly.
- The plugin DLL must be bundled in the `.rmskin` or animated widgets fail to load.

## See also
- [[_index]]
- [[Group Bang Pattern]]
