---
tags: [pattern]
---

# Context Menu Factory Pattern

> When a [[Skin]] needs a right-click menu, define it as numbered title/action pairs in a `Contexts/*.inc` file and render it with `!SkinCustomMenu`.

## When to apply
Any skin or widget that exposes a custom right-click menu.

## The pattern
```ini
; in Scripts/Contexts/Widget.inc
ContextTitle=Show Settings
ContextAction=[!ActivateConfig "Rich\Settings"]
ContextTitle2=Refresh
ContextAction2=[!Refresh]

; trigger
RightMouseUpAction=[!SetVariable Context "Widget"][!SkinCustomMenu]
```

## Why
Each menu lives as numbered `ContextTitle` / `ContextAction` pairs in `@Resources/Scripts/Contexts/`. Setting a `Context` variable then calling `!SkinCustomMenu` lets one skin select among several menu definitions. The [[Sidebar Skin]] and every widget use this so menus stay data-driven and [[Localization Token Pattern]]-friendly.

## Don't
- Don't hard-code menu entries inline in the skin — keep them in the `Contexts/*.inc` file.
- Don't skip a number in the title/action sequence, or the menu truncates there.

## See also
- [[_index]]
- [[Context Menu Flow]]
