---
tags: [widgets, timer]
---

# Timer Widget

> A countdown-timer skin with a circular progress ring, editable hours/minutes/seconds, and start/pause/continue/stop controls driven by a Lua script.

## Source

- `Widgets/Timer/Medium.ini` — timer ring, digit meters, control buttons
- `Widgets/Timer/Settings.ini` — default-time editor
- `@Resources/Scripts/Widgets/Timer.lua` — control logic
- `@Resources/Scripts/Widgets/Timer.inc` — state measures
- `@Resources/Variables/Timer.inc` — persisted timer state

## How it works

`Medium.ini` `@Include`s the persisted [[Per-Widget Variables]], the [[Widget Scaffold]], `Timer.inc`, and localized strings. `TimeMeter` is a Roundline [[Meter]] bound to the `Percentage` measure. `HoursMeter`/`MinutesMeter`/`SecondsMeter` display digits and accept mouse-scroll and `InputText` edits, all forwarded to `Timer.lua`. The four control buttons (`Start`/`Pause`/`Continue`/`Stop`) call Lua functions and show/hide based on the [[Timer State Machine]]. Layout is fully proportional ([[Proportional Layout Pattern]]).

## Depends on

- [[Timer State Machine]] — decides which buttons and meters show
- [[Timer Time Arithmetic]] — converts scroll/input into durations
- [[Per-Widget Variables]] — persisted `StartTime`/`EndTime`/`PauseTime`

## Used by

- [[Skin Composition Flow]]

## See also

- [[_index]]
- [[Update & Refresh Model]]
