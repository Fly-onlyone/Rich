---
tags: [framework, contexts]
---

# Tickmark Indicator

> A String measure pattern that appends a checkmark glyph to the context-menu item matching the current setting.

## Source

- `@Resources/Scripts/Contexts/Widget.inc` — `[SetTickMark]` (widget size)
- `@Resources/Scripts/Contexts/Music.inc` — `[SetMusicTickMark]`
- `@Resources/Scripts/Contexts/Monitor.inc` — `[SetTickMark]`
- `@Resources/Scripts/Contexts/Units.inc`, `Languages.inc` — unit/language variants

## How it works

Most context files include a `Set*TickMark` String [[Measure]]. Its `String` holds the currently-persisted value (e.g. `#WidgetSize#`, `#Units#`, `#Plugin# - #PlayerName#`). A series of `IfMatch` / `IfMatchAction` rules compares that value against each option.

When one matches, the action rewrites that option's `ContextTitle*` to append `  [\x2714]` — the Unicode U+2714 heavy check mark. The menu then visibly shows which choice is active. Monitor's variant uses `!SetOption Rainmeter` directly; others use `!SetVariable` on the `*ContextTitle*` variable.

## Depends on

- [[Measure]] — the `String` measure with `IfMatch` rules
- [[Substitute]] — `\x2714` escape resolves to the checkmark glyph

## Used by

- [[Widget Context Menu]], [[Music Context Menu]], [[Monitor Context Menu]], [[Units Context Menu]], [[Language Context Menu]]

## Gotchas

- [[Sidebar Context Menu]] and [[Timezone Context Menu]] have no tickmark — their items are commands or too numerous to mark.

## See also

- [[_index]]
- [[Context Menu Factory Pattern]]
