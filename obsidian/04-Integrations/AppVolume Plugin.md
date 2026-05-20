---
tags: [integration]
---

# AppVolume Plugin

> A Rainmeter [[Plugin]] that reads and controls per-application audio volume from the Windows audio session mixer.

## Used for
- [[Volume Widget]] — per-app volume sliders and mute state

## Configuration
- A parent `[AppVolume]` measure enumerates audio sessions; `IgnoreSystemSound=1` drops the system-sounds session.
- Indexed children `[AppVolume1]`…`[AppVolume5]` set `Parent=AppVolume` and `Index=1..5` to read individual apps.
- `Substitute=".exe":""` cleans process names for display.
- A mute value of `-1` flags a session as not present.

## Wire-up
- `@Resources/Scripts/Widgets/Volume.inc` — `[AppVolume]` parent plus five indexed children

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- Only five app slots exist; extra audio sessions are not shown.
- Each child's value drives a separate [[ActionTimer Plugin]] for smooth bar animation.
- The plugin DLL must be bundled in the `.rmskin` or the Volume widget fails to load.

## See also
- [[_index]]
- [[Win7AudioPlugin]]
