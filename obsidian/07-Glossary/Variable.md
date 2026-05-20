---
tags: [glossary]
---

# Variable

> A named value written `#Name#`, substituted into options when a [[Section]] is parsed.

Variables are declared in `[Variables]` blocks or `.inc` files. Monterey leans on them
heavily: `#Theme#`, `#WidgetSize#`, `#Language#` select which file an `@Include`
resolves to, and `#WidgetWidth#` drives layout math. `!SetVariable` changes one live;
[[Settings Persistence Pattern]] writes it to disk. Options that read variables changed
at runtime need the [[DynamicVariables Pattern]].

## See also

- [[_index]]
- [[Section]]
- [[Substitute]]
