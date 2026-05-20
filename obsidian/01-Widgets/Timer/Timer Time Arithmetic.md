---
tags: [widgets, timer]
---

# Timer Time Arithmetic

> The Lua math that converts scroll-wheel and text input into a duration, computes the countdown's end time, and corrects for paused intervals.

## Source

- `@Resources/Scripts/Widgets/Timer.lua` — `increase`, `input`, `start`, `continue`
- `@Resources/Scripts/Widgets/Timer.inc` — `TimeLeft`, `Percentage`, `EndTime`

## How it works

`increase(type, value)` adds hours/minutes/seconds (scaled to seconds) to `VisibleTime`; `input(type, value)` replaces one component by computing current hours/minutes/seconds via modulo math. Both clamp the result to `0..86399` seconds (`24*60*60-1`) with `math.min`/`math.max`.

`start()` reads `TrueNow`, stores `StartTime`, and sets `EndTime = now + duration`. While running, `TimeLeft` = `EndTime - now`. `pause()` records `PauseTime`; `continue()` shifts both `StartTime` and `EndTime` forward by `now - PauseTime` so the paused interval is subtracted — preventing drift. `Percentage` divides `TimeLeft` by total span to drive the progress ring.

## Depends on

- [[Timer State Machine]] — `IsPaused`/`IsStarted` feed `TimeLeft`
- [[Lua Set-And-Save Pattern]] — `setAndSave` persists `StartTime`/`EndTime`

## Used by

- [[Timer Widget]] — scroll/input handlers and the progress ring

## Gotchas

- Duration is clamped to under 24 hours; values past `86399` seconds silently saturate.
- `continue()` recomputes `EndTime` rather than resuming a stored remainder — skipping this would lose the paused duration.

## See also

- [[_index]]
- [[Update & Refresh Model]]
