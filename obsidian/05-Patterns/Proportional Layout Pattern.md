---
tags: [pattern]
---

# Proportional Layout Pattern

> When one widget `.inc` must render correctly at every widget size, position [[Meter]]s by expressions of `#WidgetWidth#` / `#WidgetHeight#` instead of fixed pixels.

## When to apply
Any meter in a widget that ships in multiple sizes (the skin has four).

## The pattern
```ini
[Option1Title]
Meter=String
FontSize=(#WidgetWidth# * 0.035)
X=(#WidgetPadding# + #WidgetWidth# * 0.05)
Y=(#WidgetPadding# + #WidgetHeight# * 0.33)
W=(#WidgetWidth# * 0.5)
```

## Why
`#WidgetWidth#` and `#WidgetHeight#` come from the size `.inc` chosen by the [[Include Cascade Pattern]]. Expressing every coordinate, font size, and dimension as a fraction means a single widget file scales to all four sizes with no per-size duplication. See `Widgets/Weather/Settings.ini`.

## Don't
- Don't mix hard-coded pixels with proportional values in the same widget — it breaks at other sizes.
- Don't forget `#WidgetPadding#` in `X`/`Y` offsets, or meters drift on padded sizes.

## See also
- [[_index]]
- [[Sizing Flow]]
