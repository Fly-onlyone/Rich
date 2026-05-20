---
tags: [integration]
---

# FrostedGlass Plugin

> A Rainmeter [[Plugin]] that renders a Windows acrylic/blur backdrop behind a [[Skin]] window.

## Used for
- [[Blur Theme]] — gives widgets their translucent frosted-glass look

## Configuration
- `Type=Acrylic` — selects the Windows acrylic blur material
- `Corner=Round` — rounds the blurred region's corners
- The blur sits behind a semi-transparent `[BackgroundMeter]` shape filled at `#BackgroundColor#a0`

## Wire-up
- `@Resources/Scripts/Themes/Blur.inc` — `[FrostedGlass]` plugin [[Measure]]

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- Used only by the Blur theme; the Light, Dark, Auto, and Color themes never declare it.
- The plugin DLL must be bundled in the `.rmskin`, or the Blur theme fails to load.

## See also
- [[_index]]
- [[Chameleon Plugin]]
