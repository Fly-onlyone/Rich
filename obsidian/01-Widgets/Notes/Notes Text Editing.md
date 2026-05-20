---
tags: [widgets, notes]
---

# Notes Text Editing

> The click-to-edit mechanism that captures header and body text via `InputText` and persists it to `Variables/Notes.inc`.

## Source

- `Widgets/Notes/Medium.ini` / `Large.ini` / `Small.ini` — `HeaderInput`, `ContentInput`, `FilteredValue`
- `@Resources/Variables/Notes.inc` — `Header`, `Content`, `LastUpdate` keys

## How it works

Clicking the header or body runs `ExecuteBatch ALL` on an [[InputText Plugin]] [[Measure]]. On commit, `Command1` runs `!WriteKeyValue` to save `Header`/`Content` plus the current `LastUpdate` time into `Variables/Notes.inc`, then `!SetVariable` and `!UpdateMeter` to refresh the display in place — the [[Settings Persistence Pattern]]. The body `InputText` uses a `RegExpSubstitute` to encode newlines, converting `\r\n` into the `[*\13*][*\10*]` token pair so multi-line text round-trips through the single-line `.inc` key. `FilteredValue` decodes it back for display.

## Depends on

- [[InputText Plugin]] — captures keyboard entry
- [[Settings Persistence Pattern]] — `!WriteKeyValue` then `!SetVariable`

## Used by

- [[Notes Widget]]

## Gotchas

- Newlines must survive an INI key — the `\r\n` [[Substitute]] is what makes multi-line notes possible.
- Medium/Large show a "Press Enter to save" hint on the header while editing; Small does not.

## See also

- [[_index]]
- [[Settings Persistence Flow]]
