---
tags: [pattern]
---

# Localization Token Pattern

> When UI text must be translatable, never hard-code strings — reference a `#t...#` token resolved from the active language file.

## When to apply
Every piece of user-facing text in a [[Meter]] or context menu.

## The pattern
```ini
; defined per language in Languages/<lang>/Widget.inc
tWeatherCity=City

; referenced in the widget
[Option1Title]
Meter=String
Text=#tWeatherCity#
```

## Why
A language `.inc` chosen by the [[Include Cascade Pattern]] defines every `t*` token; meters reference them so swapping `#Language#` re-skins all text at once. Computed tokens use the `[#t...#]` bracket form so the name itself can be built dynamically — e.g. `[#tWeatherCode[&CurrentDescriptionValue]]` in `@Resources/Scripts/Widgets/Weather.inc` picks a token by weather code.

## Don't
- Don't put literal English in `Text=` — it won't translate.
- Don't forget `DynamicVariables=1` on meters using the `[#t...#]` computed form.

## See also
- [[_index]]
- [[Localization Flow]]
