---
tags: [extras]
---

# Sidebar Skin

> A system-tray launcher [[Skin]] whose tray icon shows, hides, and configures the whole Rich skin set through a right-click menu.

## Source
- `Extras/Sidebar/Sidebar.ini` — the skin config

## How it works
The skin places a `[TrayIcon]` [[Measure]] using the [[TrayIcon Plugin]], with `IconName` pointing at a light/dark icon variant via `#DarkMode#`. A left click runs `!ZPosGroup` and `!ToggleFadeGroup` against the `Rich` group, fading every widget skin in or out. A right click sets `Context` to `Sidebar` and calls `!SkinCustomMenu`, which renders the dynamic menu defined in `@Resources/Scripts/Contexts/Sidebar.inc`.

Its `[Variables]` section is a textbook [[Include Cascade Pattern]]: numbered `@includeN` lines pull in `Global.inc`, the localized `Sidebar.inc` language file, shared `Context.inc`, the active `#Theme#.inc`, and the Sidebar context menu.

## Depends on
- [[TrayIcon Plugin]] — provides the tray icon and mouse actions
- [[Context Menu Factory Pattern]] — builds the right-click menu
- [[Include Cascade Pattern]] — layers globals, language, theme, contexts
- [[Localization Token Pattern]] — tray menu text is token-driven

## Used by
- The end user, as the primary entry point to the skin

## Gotchas
- `DynamicVariables=1` is required so `IconName` re-resolves `#DarkMode#` when the theme changes.

## See also
- [[_index]]
- [[Context Menu Flow]]
