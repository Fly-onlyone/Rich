---
tags: [widgets, notes]
---

# Notes Widget

> A sticky-note widget with an editable yellow header and a body of free text that survives skin refreshes.

## Source

- `Widgets/Notes/Small.ini` — body only, no header text
- `Widgets/Notes/Medium.ini` / `Large.ini` — editable header, body, last-update line
- `@Resources/Variables/Notes.inc` — persisted `Header`, `Content`, `LastUpdate`

## How it works

Notes is a script-less widget — there is **no** `Notes.inc` and **no** `Notes.lua`. Every [[Measure]] and [[Meter]] lives directly in each `Widgets/Notes/<Size>.ini`, which `@Include`s only `Variables/Notes.inc`, the [[Widget Scaffold]], and the localized strings. A `YellowHeader` [[Shape Meter]] rounds its corners by drawing inside a `Mask` [[Container]]. The header and body are plain `String` meters whose editing is handled by [[Notes Text Editing]].

## Depends on

- [[Widget Scaffold]] — common skin structure
- [[Notes Text Editing]] — the editable header/body behavior

## Used by

- [[Skin Composition Flow]]

## Gotchas

- Small omits the editable header entirely — only the body is editable.

## See also

- [[_index]]
- [[Settings Persistence Flow]]
