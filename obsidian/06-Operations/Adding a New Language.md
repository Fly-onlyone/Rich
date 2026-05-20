---
tags: [operations, extending, localization]
---

# Adding a New Language

> A language is a folder of `#t…#` token definitions mirroring an existing one, plus a
> registry entry.

## Source

- `@Resources/Languages/<lang>/` — the new language folder
- `@Resources/Languages/all.inc` — the language registry
- `@Resources/Scripts/Contexts/Languages.inc` — the picker menu

## How it works

Checklist:

1. Copy `@Resources/Languages/en/` to `@Resources/Languages/<lang>/` (keeping the same
   file layout: `Widget.inc`, `Settings.inc`, `Widgets/*`, `Settings/*`, `Extras/*`).
2. Translate every token value; **keep the token keys unchanged**.
3. Add the language's display name to `all.inc` (e.g. `it=Italiano`).
4. Add a menu item to `Contexts/Languages.inc` so users can select it.
5. Save every file in the correct encoding — see [[File Encoding Notes]].

The `<lang>` folder name must match what gets written to the `Language` variable.

## Gotchas

- A missing token file or key falls back to a raw, unresolved `[#t…#]` string on screen.
- `FormatLocale=#Language#` is used by date measures, so the folder name should be a
  valid locale code.

## See also

- [[_index]]
- [[Localization Flow]]
- [[Localization Token Pattern]]
