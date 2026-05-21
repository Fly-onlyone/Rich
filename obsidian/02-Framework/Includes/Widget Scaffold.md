---
tags: [framework, includes]
---

# Widget Scaffold

> The shared `Widget.inc` boilerplate every widget skin pulls in — it is the hub of the include cascade.

## Source

- `@Resources/Scripts/Includes/Widget.inc` — `[Rainmeter]` settings, background, and `@Include` chain

## How it works

`Widget.inc` defines the `[Rainmeter]` section: it joins the `Rich` [[Section]] group, disables auto-update (`DefaultUpdateDivider=-1`), and binds `RightMouseUpAction` to set the `Context` [[Variable]] and open the [[Bang]]-driven custom menu. It draws `[BackgroundMeter]`, a rounded [[Shape Meter]] sized by `WidgetWidth`/`WidgetHeight`/`WidgetRadius`. An `[OpacityScript]` [[Measure]] runs `Scripts/Includes/Opacity.lua`, which turns the global `WidgetOpacity` percentage into a 2-hex `WidgetBackgroundAlpha` (scaled by the effect's base alpha — `160` under Blur, `255` otherwise) that `[BackgroundMeter]`'s fill colour appends — so opacity tints the background card only, leaving text and icons opaque.

Its `[Variables]` block runs the cascade: `@Include` pulls [[Global Variables]], then the localized Widget file, the active theme, the active size, [[Context Scaffold]], and the per-widget context. It also defines `WidgetPadding`, `WidgetRadius`, `WidgetCenterX`, and `WidgetCenterY`.

## Depends on

- [[Global Variables]] — supplies `PaddingBase`/`RadiusBase`, `WidgetOpacity`, and theme defaults
- [[Size Definitions]] — supplies `WidgetWidth`/`WidgetHeight`
- [[Context Scaffold]] — wires the right-click menu

## Used by

- Every widget skin `.ini` ([[Skin Composition Flow]])

## See also

- [[_index]]
- [[Include Cascade Pattern]]
- [[Window Scaffold]]
