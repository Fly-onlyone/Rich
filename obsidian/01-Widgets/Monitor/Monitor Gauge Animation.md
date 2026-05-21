---
tags: [widgets, monitor]
---

# Monitor Gauge Animation

> Each Monitor gauge snaps straight to its newest reading. An ActionTimer easing path also exists but is disabled.

## Source

- `@Resources/Scripts/Widgets/Monitor.inc` — `CPUAnimation`, `RAMAnimation`, `DiskAnimation`, `NetAnimation`, `ActionList`, and the `#...Value#` variables

## How it works

When a `Rounded` [[Measure]] changes, its `OnChangeAction` stops then re-executes the metric's [[ActionTimer Plugin]] measure with `[&ActionList]`. The `[ActionList]` [[Measure]] is fixed to `2`, so the ActionTimer always runs `ActionList2=Update` — which sets `#CPUValue#` straight to the new `CPURounded` value and updates the gauge `Calc` measure (`CPUMeasure`). The gauge therefore **snaps** to each reading with no delay. `OnRefreshAction` kicks all four on skin load.

## Easing (disabled)

`ActionList1=Repeat AddStep, 100, 10` is an easing path: `AddStep` would nudge `#CPUValue#` halfway toward the target every 100 ms for ten steps, gliding the gauge over ~1 s. It is **off** because `[ActionList]` resolves to `2` (snap), not `1` (ease). Easing made the displayed number trail real usage by up to a second, so it was disabled. To restore it, set `[ActionList]` `Formula=1` (or `1 + #BatterySaverMode#` for the original saver-aware behaviour).

## Depends on

- [[ActionTimer Plugin]] — runs the `Update` / `AddStep` [[Bang]] lists
- [[Monitor Metrics]] — supplies the `Rounded` target values
- [[DynamicVariables Pattern]] — `#...Value#` must re-resolve when set

## Used by

- [[Monitor Widget]] — gauges/histograms render the value

## Gotchas

- Stop-then-Execute on every change cancels any in-flight run so rapid updates don't queue up.

## See also

- [[_index]]
- [[Group Bang Pattern]]
