---
tags: [framework, settings]
---

# Widgets Settings Tab

> The settings tab that lists all ten Rich widgets with a toggle switch to load or unload each one.

## Source

- `@Resources/Scripts/Settings/Widgets.inc` — the tab content: nine icon/title/toggle rows

## How it works

`Widgets.inc` renders a vertical grid of nine entries (Clock, Calendar, Monitor, Weather, Notes, Reminders, Music, Volume, Timer). Each row has an icon [[Meter]], a localized title, and a pill-shaped toggle drawn as two [[Shape Meter]]s — a grey "off" state and a green "on" state.

A per-widget `WidgetNOpened` [[Measure]] uses the [[ConfigActive Plugin]] (`Plugin=ConfigActive`, `ConfigName=#ROOTCONFIG#\Widgets\<Name>`) to detect whether that widget config is loaded — `#ROOTCONFIG#` resolves to the skin's root folder name, so it works regardless of what the pack folder is called. The `[&WidgetNOpened:]` value drives each toggle's `Hidden` so only the correct state shows. Clicking the toggle fires `!ToggleConfig` with the widget's size variant (e.g. `#ClockWidgetSize#.ini`), and `OnChangeAction=[!Refresh]` redraws the tab.

## Depends on

- [[ConfigActive Plugin]] — detects which widget configs are active
- [[Shape Meter]] — draws the toggle pills
- [[Layout State]] — supplies per-widget `*WidgetSize` variables

## Used by

- [[Settings Tab Dispatch]] — loads this file when `SettingsTab=Widgets`

## See also

- [[_index]]
- [[Skin Composition Flow]]
- [[Extras Settings Tab]]
