---
tags: [framework, variables]
---

# Layout State

> `Layout.inc` — the persisted record of each widget's chosen size and the active settings tab.

## Source

- `@Resources/Variables/Layout.inc` — `<Widget>WidgetSize` keys plus `SettingsTab`

## How it works

`Layout.inc` is a `[Variables]` block holding one `<Widget>WidgetSize` [[Variable]] per widget (e.g. `ClockWidgetSize=Medium`, `WeatherWidgetSize=Large`) and a single `SettingsTab` key recording which tab the settings window last showed.

Unlike [[Global Variables]], this file is **written at runtime**: a [[Bang]] like `!WriteKeyValue Variables <Widget>WidgetSize Medium "...\Layout.inc"` persists the user's choice. [[Widget Scaffold]] then `@Include`s the matching [[Size Definitions]] file via `#WidgetSize#`, so the widget reloads at the saved footprint.

## Depends on

- [[Size Definitions]] — the stored value names one of these files

## Used by

- [[Settings Scaffold]] and [[WhatsNew Scaffold]] — include it and write to it
- [[Widget Scaffold]] — reads `#WidgetSize#` indirectly

## Gotchas

- Editing this file changes layout for all widgets at once; it is shared state, not per-skin.

## See also

- [[_index]]
- [[Settings Persistence Pattern]]
- [[Settings Persistence Flow]]
