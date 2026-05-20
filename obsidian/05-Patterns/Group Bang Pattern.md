---
tags: [pattern]
---

# Group Bang Pattern

> When many measures or meters must refresh together, tag them with a `Group=` and refresh the whole group with one bang.

## When to apply
Any widget where a data update should propagate to a batch of measures and meters at once.

## The pattern
```ini
[CurrentTemp]
Measure=Calc
Group=Measures
...

[OpenMeteoParser]
Measure=WebParser
FinishAction=[!UpdateMeasureGroup Measures][!UpdateMeterGroup Meters][!Redraw]
```

## Why
Tagging sections `Group=Measures` / `Group=Meters` lets one `!UpdateMeasureGroup` / `!UpdateMeterGroup` (or `!RefreshGroup`) bang fan out to all of them, instead of naming each section individually. Used by `@Resources/Scripts/Widgets/Weather.inc`, `Monitor.inc`, and `Timer.lua`'s `update()`.

## Don't
- Don't list every section by name in the action — that's brittle and easy to leave incomplete.
- Don't forget to add `Group=` to a new measure, or it silently won't refresh.

## See also
- [[_index]]
- [[Update & Refresh Model]]
