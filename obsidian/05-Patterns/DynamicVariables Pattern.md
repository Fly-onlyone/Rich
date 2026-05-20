---
tags: [pattern]
---

# DynamicVariables Pattern

> When a [[Measure]] or [[Meter]] reads a variable that changes at runtime, it must set `DynamicVariables=1` or the value freezes at parse time.

## When to apply
Any section referencing `#Variables#`, `[Sections]`, or `[#computed#]` tokens whose value is updated by `!SetVariable` or another measure.

## The pattern
```ini
[CurrentTemp]
Measure=Calc
Formula=Round([CurrentTempValue],0)
DynamicVariables=1
```

## Why
By default Rainmeter resolves variables and section references once, when the skin is parsed. `DynamicVariables=1` re-resolves them on every update, so a measure that reads `#City#`, `#DarkMode#`, or a `[#t...#]` token reflects later changes. Nearly every measure in `@Resources/Scripts/Widgets/Weather.inc` sets it; so does `[IsBetween]` in `Extras/ThemeUpdater/ThemeUpdater.ini`.

## Don't
- Don't omit it on a section that reads a runtime-changed variable — it will appear stuck on the old value.
- Don't set it blanket on every static section — it costs needless re-parsing each update.

## See also
- [[_index]]
- [[Update & Refresh Model]]
