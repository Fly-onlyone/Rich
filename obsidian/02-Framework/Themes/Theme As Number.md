---
tags: [framework, themes]
---

# Theme As Number

> A recurring String measure, now named `EffectAsNumber` in code, that maps the textual effect value in `#Theme#` to a small integer so it can be used in numeric conditions.

## Source

- `@Resources/Scripts/Includes/Widget.inc` — defines the `[EffectAsNumber]` measure

## How it works

[[Widget Scaffold]] declares an `[EffectAsNumber]` String [[Measure]] whose `String` is `#Theme#`. A `Substitute` maps effect names to digits: `"Solid":"1"`, `"Auto":"2"`, `"Color":"3"`, `"Blur":"4"`. The old `"Light"` and `"Dark"` values map to `1` for compatibility with persisted pre-split settings.

The numeric form lets widgets write comparison expressions that text cannot express directly. Meters reference it through the bind syntax `[&EffectAsNumber]` inside conditional formulas — for example `Hidden=([&EffectAsNumber]=4)` — to show or hide elements for the Blur effect.

## Depends on

- [[Theme System]] — supplies the `#Theme#` variable being mapped
- [[Substitute]] — performs the name-to-digit mapping

## Used by

- [[Theme-As-Number Pattern]] — the reusable idiom built on this measure
- Widget meters with theme-conditional `Hidden=` expressions

## See also

- [[_index]]
- [[Theme System]]
- [[Theme-As-Number Pattern]]
