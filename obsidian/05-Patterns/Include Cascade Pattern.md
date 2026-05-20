---
tags: [pattern]
---

# Include Cascade Pattern

> When a [[Skin]] needs to layer globals, language, theme, sizing, and context behaviour, pull them in as a numbered `@IncludeN` cascade.

## When to apply
Any skin or widget whose `[Variables]` section must compose several `.inc` files in a deliberate order.

## The pattern
```ini
[Variables]
@Include=#@#Variables\Global.inc
@Include2=#@#Languages\#Language#\Widget.inc
@Include3=#@#Scripts\Palettes\#Palette#.inc
@Include4=#@#Scripts\Themes\#Theme#.inc
@Include5=#@#Scripts\Sizes\#WidgetSize#.inc
@Include6=#@#Scripts\Includes\Context.inc
@Include7=#@#Scripts\Contexts\Widget.inc
```

## Why
Later includes can reference variables defined by earlier ones (effect files read palette variables, sizing reads `#WidgetSize#`). Numbering makes the load order explicit and lets each layer override or extend the previous. See `@Resources/Scripts/Includes/Widget.inc` for the canonical cascade.

## Don't
- Don't reuse a number within one `[Variables]` section — a duplicate `@Include2` silently drops one file.
- Don't depend on a variable before the include that defines it appears in the cascade.

## See also
- [[_index]]
- [[Skin Composition Flow]]
