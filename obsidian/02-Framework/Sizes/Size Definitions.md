---
tags: [framework, sizes]
---

# Size Definitions

> The four `.inc` files that each set `WidgetWidth`/`WidgetHeight` for one widget footprint.

## Source

- `@Resources/Scripts/Sizes/Small.inc` — 1x1 footprint
- `@Resources/Scripts/Sizes/Medium.inc` — 2x2 footprint
- `@Resources/Scripts/Sizes/Wide.inc` — 4x2 footprint
- `@Resources/Scripts/Sizes/Large.inc` — 4x4 footprint

## How it works

Each size file is a tiny `[Variables]` block that sets just `WidgetWidth` and `WidgetHeight`. `Small.inc` sets both to `#WidgetBase#`. The larger sizes compute dimensions from the [[WidgetBase Grid Unit]] terms: Medium is `(2*WidgetBase + 2*PaddingBase)`, Wide is `(4*WidgetBase + 6*PaddingBase)` wide by Medium's height, and Large is `(4*WidgetBase + 6*PaddingBase)` square.

[[Widget Scaffold]] `@Include`s whichever file `#WidgetSize#` names, so a widget changes shape simply by activating a different size skin. Every [[Meter]] then scales because all coordinates are proportional.

## Depends on

- [[WidgetBase Grid Unit]] — `WidgetBase`/`PaddingBase` are the only inputs

## Used by

- [[Widget Scaffold]] — includes the active size
- [[Settings Scaffold]] and [[WhatsNew Scaffold]] — hard-code Large

## See also

- [[_index]]
- [[Sizing Flow]]
- [[Proportional Layout Pattern]]
