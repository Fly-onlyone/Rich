---
tags: [framework, includes]
---

# Context Scaffold

> The `Context.inc` wiring that turns a per-widget context file into Rainmeter's right-click custom menu.

## Source

- `@Resources/Scripts/Includes/Context.inc` — 25 numbered `ContextTitle`/`ContextAction` pairs

## How it works

`Context.inc` contains a `[Rainmeter]` section with `ContextTitle`/`ContextAction` keys numbered 1 through 25. Each value is an indirect lookup: `ContextTitle3` reads `[#[#Context]ContextTitle3]`, where the `Context` [[Variable]] names the active context group (set to the widget name by [[Widget Scaffold]]'s `RightMouseUpAction`).

This indirection lets one shared include serve every widget — the actual menu labels and [[Bang]]s live in `@Resources/Scripts/Contexts/<Widget>.inc`. Empty slots simply resolve to blank and are skipped by Rainmeter.

## Depends on

- The `Context` [[Variable]] — selects which context group to read

## Used by

- [[Widget Scaffold]] — `@Include`d into every widget
- [[Window Scaffold]] and [[Settings Scaffold]] — included though menus are cleared

## See also

- [[_index]]
- [[Context Menu Flow]]
