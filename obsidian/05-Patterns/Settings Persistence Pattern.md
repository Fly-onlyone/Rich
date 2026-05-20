---
tags: [pattern]
---

# Settings Persistence Pattern

> When a user changes a setting at runtime, persist it to disk *and* apply it live in the same action.

## When to apply
Any setting the user can change — theme, city, dark mode, battery saver — that must survive a skin refresh.

## The pattern
```ini
LeftMouseUpAction=[!WriteKeyValue Variables Theme "Dark" "#@#Variables\Global.inc"][!SetVariable Theme "Dark"][!Refresh]
```

## Why
`!WriteKeyValue` writes the value into the `.inc` file so it survives reloads, but it does *not* update the in-memory variable. `!SetVariable` updates the live value so the change is visible immediately. Pairing them gives both durability and instant feedback. Seen across `@Resources/Scripts/Settings/` and in `Widgets/Weather/Settings.ini`.

## Don't
- Don't call only `!WriteKeyValue` — the change won't show until the next refresh.
- Don't call only `!SetVariable` — the change is lost on refresh.
- Don't write to the wrong `.inc` file; the path must match where the variable is defined.

## See also
- [[_index]]
- [[Lua Set-And-Save Pattern]]
