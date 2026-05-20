---
tags: [pattern]
---

# Theme-As-Number Pattern

> When meters must show or hide based on the active effect, map the `Theme` effect string to a number once and test the number.

## When to apply
Any widget that needs effect-conditional layout (e.g. hiding a meter only in the Blur effect).

## The pattern
```ini
[EffectAsNumber]
Measure=String
String=#Theme#
DynamicVariables=1
Substitute="Light":"1","Dark":"1","Solid":"1","Auto":"2","Color":"3","Blur":"4"
```

## Why
`Hidden=` and other conditional expressions work cleanly with numbers but awkwardly with strings. Converting `#Theme#` to a small numeric effect code once (in `@Resources/Scripts/Includes/Widget.inc`) lets every meter write expressions like `Hidden=([&EffectAsNumber] = 4)`. It centralises the string-to-number mapping in one place.

## Don't
- Don't compare `#Theme#` as a raw string in many meters — a renamed effect then needs edits everywhere.
- Don't forget `DynamicVariables=1`, or the measure freezes at the parse-time theme.

## See also
- [[_index]]
- [[Theme As Number]]
