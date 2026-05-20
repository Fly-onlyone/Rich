---
tags: [extras]
---

# Unlock Scheduled Task

> A Windows Scheduled Task that detects session-unlock events and flips a flag file the [[Unlock Skin]] watches.

## Source
- `@Resources/Scripts/Extras/Unlock/Install.cmd` — registers the task via `schtasks`
- `@Resources/Scripts/Extras/Unlock/task.xml` — the task definition
- `@Resources/Scripts/Extras/Unlock/Start.bat` — writes `1` to `State.txt`
- `@Resources/Scripts/Extras/Unlock/Stop.bat` — writes `0` to `State.txt`

## How it works
`Install.cmd` runs `schtasks /Create /TN "RainmeterUnlockPCAnimation" /XML "task.xml"`, registering the task from the bundled XML. `task.xml` declares a `SessionStateChangeTrigger` with `StateChange=SessionUnlock`, so Windows fires it the moment the user unlocks their session.

The task's action runs `Start.bat`, which writes `1` into `State.txt` in the Unlock script folder. The [[Unlock Skin]] polls that file, sees `1`, and plays its animation; the animation's first step calls `Stop.bat`, which writes `0` back, re-arming the flag for the next unlock.

## Depends on
- Windows Task Scheduler (`schtasks`) — hosts the trigger

## Used by
- [[Unlock Skin]] — reads the `State.txt` flag the task sets

## Gotchas
- `task.xml` hard-codes a working directory of `%USERPROFILE%\Documents\Rainmeter\Skins\Monterey\@Resources\Scripts\Extras\Unlock`; a non-default Rainmeter install path breaks it.
- `Install.cmd` must be run from inside the Unlock folder (it `cd %1`s and references `task.xml` by relative name).

## See also
- [[_index]]
- [[Unlock Skin]]
