---
tags: [operations, gotcha]
---

# File Encoding Notes

> Most skin files are UTF-16 LE — saving one as UTF-8 (or vice versa) can break how
> Rainmeter parses it. Check the encoding before editing.

## Source

- `.ini` / `.inc` files across the repo
- `.lua` files under `@Resources/Scripts/Widgets/`

## How it works

Rainmeter's native encoding is **UTF-16 LE with BOM**, and most of this repo's
`.ini` / `.inc` / `.lua` files use it — in an editor they show characters spaced out or
with a leading BOM. A few newer files (e.g. `Widgets/Weather/Settings.ini`) are UTF-8.

When editing:

- **Preserve each file's existing encoding.** Do not let an editor "helpfully" convert.
- The Obsidian vault itself is UTF-8 — that is fine; vault notes are not skin files.

## Gotchas

- A UTF-16 file silently re-saved as UTF-8 may load but mis-render non-ASCII text, or
  fail a `RegExp` that expected exact bytes.

## See also

- [[_index]]
- [[Adding a New Language]]
