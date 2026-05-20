---
tags: [framework, settings]
---

# Advanced Options

> The Appearance-tab block of numeric `InputText` fields for widget size, padding, and corner radius.

## Source

- `@Resources/Scripts/Settings/Appearence/AdvancedOptions.inc` — three label/value/input rows

## How it works

`AdvancedOptions.inc` exposes three tunable layout values: `WidgetBase` (size), `PaddingBase`, and `RadiusBase`. Each row pairs a localized label, a clickable value display, and a hidden [[InputText Plugin]] measure. Clicking the value runs `!CommandMeasure "InputN" "ExecuteBatch ALL"` to open the editor; on confirm, `Command1` does `!WriteKeyValue` into `Global.inc` then `!RefreshGroup Monterey`.

The radius row (`Label3`/`Value3`/`Input3`) and the panel are sized with `Floor([&EffectAsNumber] / 4)` and hidden when `[&EffectAsNumber]=4`, because the Blur effect has no rounded corners to configure. So under Blur the panel shrinks to just size and padding.

## Depends on

- [[InputText Plugin]] — supplies the editable numeric fields
- [[Global Variables]] — `WidgetBase`/`PaddingBase`/`RadiusBase` written here
- [[Theme As Number]] — hides the radius row under Blur

## Used by

- [[Appearance Settings Tab]] — includes this as its middle subfile

## See also

- [[_index]]
- [[Settings Persistence Pattern]]
- [[Theme Options]]
