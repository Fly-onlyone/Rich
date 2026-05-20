---
tags: [framework, contexts]
---

# Widget Context Menu

> The right-click menu for an individual widget, offering edit, size, removal, feedback, and settings actions.

## Source

- `@Resources/Scripts/Contexts/Widget.inc` — fills the `Widget*` title/action pairs

## How it works

`Contexts/Widget.inc` is the default context (right-clicking a widget sets `Context` to `Widget`). It defines numbered `WidgetContextTitle*` / `WidgetContextAction*` pairs that [[Context Scaffold]] forwards to Rainmeter's `ContextTitle*` / `ContextAction*`.

Items include opening `Settings.ini`, four size choices (Small / Medium / Wide / Large), Remove Widget, Send Feedback, and Edit Widgets. Size choices `!WriteKeyValue` the widget's `WidgetSize` into `Layout.inc` then `!ActivateConfig` the matching layout — the [[Settings Persistence Pattern]] in action.

A `[SetTickMark]` String [[Measure]] reads `#WidgetSize#` and uses `IfMatch` to append `[\x2714]` (a checkmark) to the currently-selected size's title — see [[Tickmark Indicator]].

## Depends on

- [[Context Scaffold]] — relays the title/action pairs
- [[Tickmark Indicator]] — marks the active size
- [[Settings Persistence Pattern]] — persists the chosen size

## Used by

- [[Context Menu Flow]]
- [[Widget Scaffold]] — sets `Context` to `Widget` on right-click

## See also

- [[_index]]
- [[Context Menu Factory Pattern]]
