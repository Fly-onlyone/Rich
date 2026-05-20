---
tags: [moc, patterns]
---

# Patterns — Map of Content

> Recurring conventions of the codebase. Learn these once; they repeat in every widget.

## Composition

- [[Include Cascade Pattern]] — layering behavior with numbered `@IncludeN` directives
- [[Theme-As-Number Pattern]] — mapping the `Theme` string to a number for conditionals
- [[Context Menu Factory Pattern]] — numbered title/action pairs build dynamic menus

## State

- [[Settings Persistence Pattern]] — `!WriteKeyValue` writes choices back into `.inc` files
- [[Lua Set-And-Save Pattern]] — the `setAndSave` helper that writes and sets in one call
- [[DynamicVariables Pattern]] — when `DynamicVariables=1` is required

## Layout & content

- [[Proportional Layout Pattern]] — positioning meters by expressions of widget size
- [[Localization Token Pattern]] — `#t…#` tokens for all user-facing text

## Updates & debugging

- [[Group Bang Pattern]] — tagging sections with `Group=` for wholesale refresh
- [[Debug Measure Pattern]] — parallel `*Debug` WebParser measures that log raw data

## See also

- [[_HOME]]
- [[00-Architecture/_index|Architecture]]
