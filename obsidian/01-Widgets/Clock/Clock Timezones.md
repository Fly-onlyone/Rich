---
tags: [widgets, clock]
---

# Clock Timezones

> The user-selectable time zone for the Clock, chosen from a three-part context menu and persisted to `Variables/Clock.inc`.

## Source

- `@Resources/Variables/Clock.inc` — stores `Timezone` (default `local`)
- `Widgets/Clock/Settings.ini` — `Option3Value` opens the timezone menu
- `@Resources/Scripts/Contexts/Timezones1.inc`, `Timezones2.inc`, `Timezones3.inc` — the menu entries

## How it works

Every `Time` measure (`[Time]` in `Clock.inc`, `TimeMeasure` in Wide.ini) reads `TimeZone=#Timezone#`. The Settings skin's `Option3Value` meter sets `Context` to `Timezones1` then fires `!SkinCustomMenu`. Each `Timezones#.inc` file defines `Timezones#ContextTitle#`/`ContextAction#` pairs; selecting one runs `!WriteKeyValue Variables Timezone "<offset>"` against `Variables/#WidgetName#.inc` and `!Refresh`. The menu spans three files chained by a "more" entry that switches `Context` and re-opens the menu, working around Rainmeter's per-menu item limit.

## Depends on

- [[Timezone Context Menu]] — the shared 3-file menu mechanism
- [[Settings Persistence Pattern]] — `!WriteKeyValue` saves the choice
- [[Context Menu Flow]] — how `!SkinCustomMenu` is triggered

## Used by

- [[Clock Widget]]
- [[Clock Hands]] — hand angles follow the selected zone via the `Time` measure

## Gotchas

- `WidgetName` makes the menu generic; the same `Timezones#.inc` files serve any timezone-aware widget.
- A typo (`Timezoens1ContextAction21`) exists in `Timezones1.inc` — harmless, it is an unused trailing key.

## See also

- [[_index]]
- [[Clock Widget]]
