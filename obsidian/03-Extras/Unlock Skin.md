---
tags: [extras]
---

# Unlock Skin

> A fullscreen extra [[Skin]] that plays a brief padlock-opening animation each time the Windows session is unlocked.

## Source
- `Extras/Unlock/Unlock.ini` — the skin config

## How it works
The skin sizes itself to the whole screen area and stays click-through and always-on-top. `[CheckStateMeasure]` is a [[WebParser]] that polls a local `State.txt` file every 5 seconds; `[StateMeasure]` reads its value and, on `IfMatch=1`, fires the `Animate` measure.

`[Animate]` is an [[ActionTimer Plugin]] measure. Its `ActionList1` unhides the lock and unlock [[Meter]] images, repeats an `Unlock` step 6 times (nudging the unlock image upward) to animate the latch, waits, then hides everything. The `Unhide` step also runs `Stop.bat` to reset the flag, so the animation plays once per unlock.

## Depends on
- [[ActionTimer Plugin]] — drives the stepped animation sequence
- [[Unlock Scheduled Task]] — sets `State.txt` to `1` on session unlock
- [[WebParser]] — polls the `State.txt` flag file

## Used by
- [[Extras Settings Tab]] — enables or disables this extra

## Gotchas
- The animation never runs unless [[Unlock Scheduled Task]] is installed to write `State.txt`.
- `Unhide` calls `Stop.bat` immediately, so the flag clears even while the animation is still playing.

## See also
- [[_index]]
- [[Unlock Scheduled Task]]
