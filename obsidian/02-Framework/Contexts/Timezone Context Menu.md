---
tags: [framework, contexts]
---

# Timezone Context Menu

> A paged right-click menu listing 40+ world timezones for the Clock widget.

## Source

- `@Resources/Scripts/Contexts/Timezones1.inc` — page 1 (UTC-12 to UTC-03:30)
- `@Resources/Scripts/Contexts/Timezones2.inc` — page 2 (UTC-03 to UTC+06:30)
- `@Resources/Scripts/Contexts/Timezones3.inc` — page 3 (UTC+07 to UTC+14)

## How it works

The timezone list is too long for one menu, so it is split across three `Timezones1/2/3.inc` files. Each defines `Timezones#ContextTitle*` / `Timezones#ContextAction*` pairs; selecting a zone `!WriteKeyValue`s `Timezone` into `Variables\#WidgetName#.inc` then `!Refresh`es — the [[Settings Persistence Pattern]].

Paging works by re-setting the `Context` [[Variable]]: a "next/prev" item runs `[!SetVariable Context "Timezones2"][!SkinCustomMenu]`, which re-opens the menu reading the new page through [[Context Scaffold]].

## Depends on

- [[Context Scaffold]] — relays the title/action pairs and re-renders on paging
- [[Settings Persistence Pattern]] — persists the `Timezone` value

## Used by

- [[Context Menu Flow]]
- [[Clock Timezones]] — right-click opens this menu

## Gotchas

- All three pages keep a "Local time" item; only the paging arrows differ between pages.

## See also

- [[_index]]
- [[Context Menu Factory Pattern]]
