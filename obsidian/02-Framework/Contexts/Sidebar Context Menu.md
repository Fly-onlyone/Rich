---
tags: [framework, contexts]
---

# Sidebar Context Menu

> The right-click menu for the Sidebar skin, offering settings, disable, and quit actions.

## Source

- `@Resources/Scripts/Contexts/Sidebar.inc` — fills the `Sidebar*` title/action pairs

## How it works

`Contexts/Sidebar.inc` is a short context file with three `SidebarContextTitle*` / `SidebarContextAction*` pairs, all using localized titles:

- **Edit Widgets** — `!WriteKeyValue`s `SettingsTab=Widgets` into `Layout.inc`, then toggles and activates the `Settings.ini` skin.
- **Disable Sidebar** — `!ShowFadeGroup` then `!DeactivateConfig` the current config.
- **Quit Rainmeter** — runs `!Quit`.

[[Context Scaffold]] relays these pairs to Rainmeter's `ContextTitle*` / `ContextAction*`. Unlike most context menus, the Sidebar menu has no [[Tickmark Indicator]] — its items are commands, not a single-select option list.

## Depends on

- [[Context Scaffold]] — relays the title/action pairs
- [[Settings Persistence Pattern]] — Edit Widgets persists `SettingsTab`

## Used by

- [[Context Menu Flow]]
- [[Sidebar Skin]] — right-click opens this menu

## See also

- [[_index]]
- [[Context Menu Factory Pattern]]
