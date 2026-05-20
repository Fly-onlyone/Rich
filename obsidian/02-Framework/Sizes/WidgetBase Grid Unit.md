---
tags: [framework, sizes]
---

# WidgetBase Grid Unit

> The three atomic constants — `WidgetBase`, `PaddingBase`, `RadiusBase` — every size and layout formula derives from.

## Source

- `@Resources/Variables/Global.inc` — defines `WidgetBase=75`, `PaddingBase=8`, `RadiusBase=20`

## How it works

The skin has no hard-coded pixel sizes. Instead [[Global Variables]] declares three base units: `WidgetBase` (75px, the size of one grid cell), `PaddingBase` (8px, the gap between cells), and `RadiusBase` (20px, the corner rounding).

[[Size Definitions]] builds each footprint by multiplying these — e.g. a 2x2 widget is `2*WidgetBase + 2*PaddingBase`. [[Widget Scaffold]] sets `WidgetPadding=#PaddingBase#` and `WidgetRadius=#RadiusBase#`. Changing one constant rescales the entire skin proportionally, which is the heart of the [[Proportional Layout Pattern]].

## Used by

- [[Size Definitions]] — multiplies `WidgetBase`/`PaddingBase` into footprints
- [[Widget Scaffold]] — maps to `WidgetPadding`/`WidgetRadius`

## Gotchas

- These are plain numbers, not measures — they only re-evaluate on skin refresh, so a global resize needs every active skin reloaded.

## See also

- [[_index]]
- [[Global Variables]]
- [[Sizing Flow]]
