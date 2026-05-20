---
tags: [widgets, reminders]
---

# Reminders Widget

> An editable to-do list widget with a named list, an item count, and click-to-edit reminder rows.

## Source

- `Widgets/Reminders/Medium.ini` — list name plus three visible item rows
- `Widgets/Reminders/Large.ini` — list name plus eight visible item rows
- `@Resources/Scripts/Widgets/Reminders.lua` — list logic
- `@Resources/Variables/Reminders.inc` — `ListName` and `Item1..ItemN`

## How it works

Each size `.ini` is a [[Widget Scaffold]] holding all [[Meter]]s and `InputText` [[Measure]]s directly; a `[Lua]` Script measure loads `Reminders.lua`. Items render as `Item1..ItemN` `String` meters that hide via `Hidden=(#ItemsCount# < N)`. The list name is colored by a `Chameleon` plugin sampling the list icon. An "and more" row counts overflow beyond the visible rows. All add/edit/delete behavior lives in [[Reminders List Logic]].

## Depends on

- [[Widget Scaffold]] — common skin structure
- [[Reminders List Logic]] — the Lua add/edit/delete logic
- [[InputText Plugin]] — item entry

## Used by

- [[Skin Composition Flow]]

## Gotchas

- Medium shows up to 3 rows, Large up to 8; extra items collapse into the "+ N more" line.

## See also

- [[_index]]
- [[Settings Persistence Flow]]
