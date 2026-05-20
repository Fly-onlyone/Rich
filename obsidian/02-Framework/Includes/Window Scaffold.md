---
tags: [framework, includes]
---

# Window Scaffold

> The `Window.inc` boilerplate that provides chrome for the settings window rather than a widget.

## Source

- `@Resources/Scripts/Includes/Window.inc` — settings-window `[Rainmeter]` settings and background

## How it works

`Window.inc` is a slimmer cousin of [[Widget Scaffold]] used by `Settings.ini`. Its `[Rainmeter]` section sets `Update=1000` (the window ticks every second, unlike widgets which freeze), disables snapping/keep-on-screen, and sets `DragMargins=0,0,0,-45` so the top strip is draggable. `RightMouseUpAction` is cleared — no custom menu on the window.

`[BackgroundMeter]` is a rounded [[Shape Meter]] with a faint `808080` stroke. The `[Variables]` block `@Include`s [[Global Variables]], [[Context Scaffold]], and the active theme, then derives `WidgetCenterX`/`WidgetCenterY`.

## Depends on

- [[Global Variables]] — theme and base sizing
- [[Context Scaffold]] — menu wiring (included though unused)

## Used by

- `Settings.ini` ([[Settings Panel Flow]])

## See also

- [[_index]]
- [[Settings Scaffold]]
- [[Update & Refresh Model]]
