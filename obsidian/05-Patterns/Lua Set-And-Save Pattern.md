---
tags: [pattern]
---

# Lua Set-And-Save Pattern

> When a Lua widget script changes a persisted variable, route it through a single `setAndSave` helper instead of issuing bangs ad hoc.

## When to apply
Any Lua-driven widget (e.g. the [[Timer State Machine]]) that mutates variables which must persist across refreshes.

## The pattern
```lua
function setAndSave(variable, value)
    SKIN:Bang('!WriteKeyValue', 'Variables', variable, value, '#@#Variables/Timer.inc')
    SKIN:Bang('!SetVariable', variable, value)
end
```

## Why
It is the [[Settings Persistence Pattern]] expressed in Lua: one call both writes the value to disk and updates the live variable. Centralising it in one helper means `start`, `pause`, `continue`, and `stop` can't accidentally forget either half. Defined in `@Resources/Scripts/Widgets/Timer.lua`.

## Don't
- Don't call `!WriteKeyValue` or `!SetVariable` directly from state functions — use the helper.
- Don't hard-code the `.inc` path in every caller; keep it inside `setAndSave`.

## See also
- [[_index]]
- [[Settings Persistence Pattern]]
