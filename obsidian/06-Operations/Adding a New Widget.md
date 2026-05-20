---
tags: [operations, extending]
---

# Adding a New Widget

> A new widget is a new folder of size `.ini` files plus its shared logic, variables,
> and translations — wired into the existing cascade.

## Source

- `Widgets/<Name>/` — the new widget folder
- `@Resources/Scripts/Widgets/<Name>.inc` (+ optional `.lua`)
- `@Resources/Variables/<Name>.inc`

## How it works

Checklist, modelled on an existing widget:

1. Create `Widgets/<Name>/` with `Small/Medium/Wide/Large.ini` — each sets `WidgetName`,
   `WidgetSize`, and the four `@Include`s of the [[Skin Composition Flow]].
2. Add `@Resources/Scripts/Widgets/<Name>.inc` for measures and meters (and a `.lua`
   if it needs real logic).
3. Add `@Resources/Variables/<Name>.inc` for its defaults.
4. Add a token file `Languages/<lang>/Widgets/<Name>.inc` for **every** language.
5. Add a default size entry to `@Resources/Variables/Layout.inc`.
6. Add an icon to `@Resources/Images/Icons/` and a row to the
   [[Widgets Settings Tab]] list.

## Gotchas

- Skipping step 4 for any language leaves untranslated `[#t…#]` tokens visible as raw
  text in that language.

## See also

- [[_index]]
- [[Skin Composition Flow]]
- [[Adding a New Language]]
