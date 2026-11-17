---
tags: [operations, gotcha]
---

# File Encoding Notes

> Skin files are UTF-16 LE with BOM, or BOM-less pure ASCII. Rainmeter reads a BOM-less
> file as ANSI, so non-ASCII text in one breaks. Check the encoding before editing.

## Source

- `.ini` / `.inc` files across the repo
- `.lua` files under `@Resources/Scripts/Widgets/`

## How it works

Rainmeter's native encoding is **UTF-16 LE with BOM**, and most of this repo's
`.ini` / `.inc` / `.lua` files use it — in an editor they show characters spaced out or
with a leading BOM. The rest (e.g. `Widgets/Weather/Settings.ini`) have no BOM and must
stay **pure ASCII**: Rainmeter reads a BOM-less file as ANSI, not UTF-8. The same holds
for `AIUsage.ps1`, which runs under Windows PowerShell 5.1.

When editing:

- **Preserve each file's existing encoding.** Do not let an editor "helpfully" convert.
- The Obsidian vault itself is UTF-8 — that is fine; vault notes are not skin files.

## Gotchas

- A UTF-16 file silently re-saved as UTF-8 may load but mis-render non-ASCII text, or
  fail a `RegExp` that expected exact bytes.
- Even a typographic dash or arrow in a BOM-less file counts as non-ASCII. Use plain
  ASCII, or save the file as UTF-16 LE. The [[Static Checks]] enforce this.

## See also

- [[_index]]
- [[Adding a New Language]]
