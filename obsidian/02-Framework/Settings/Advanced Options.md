---
tags: [framework, settings]
---

# Advanced Options

> The Appearance-tab block of numeric `InputText` fields for widget size, padding, corner radius, and opacity.

## Source

- `@Resources/Scripts/Settings/Appearence/AdvancedOptions.inc` — four label/value/input rows

## How it works

`AdvancedOptions.inc` exposes four tunable values: `WidgetBase` (size), `PaddingBase`, `RadiusBase`, and `WidgetOpacity` (background-card opacity — see [[Widget Scaffold]]). Each row pairs a localized label, a clickable value display, and a hidden [[InputText Plugin]] measure. Clicking the value runs `!CommandMeasure "InputN" "ExecuteBatch ALL"` to open the editor; on confirm, `Command1` does `!WriteKeyValue` into `Global.inc` then `!RefreshGroup Rich`.

The radius row (`Label3`/`Value3`/`Input3`) is hidden when `[&EffectAsNumber]=4`, because the Blur effect has no rounded corners to configure, and the panel height tracks that with `Floor([&EffectAsNumber] / 4)`. The opacity row (`Label4`/`Value4`/`Input4`) is always shown, so under Blur the panel holds size, padding, and opacity.

## Depends on

- [[InputText Plugin]] — supplies the editable numeric fields
- [[Global Variables]] — `WidgetBase`/`PaddingBase`/`RadiusBase`/`WidgetOpacity` written here
- [[Theme As Number]] — hides the radius row under Blur

## Used by

- [[Appearance Settings Tab]] — includes this as its middle subfile

## See also

- [[_index]]
- [[Settings Persistence Pattern]]
- [[Theme Options]]
