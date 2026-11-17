---
tags: [integration]
---

# TrayIcon Plugin

> A Rainmeter [[Plugin]] that places an icon in the Windows system tray and routes its mouse clicks to skin bangs.

## Used for
- [[Sidebar Skin]] — the tray icon that shows, hides, and configures the skin

## Configuration
- `Plugin=TrayIcon` with `IconName=` (an `.ico` path, here switched by `#DarkMode#`) and `ToolTipText=`.
- `LeftMouseUpAction` and `RightMouseUpAction` hold bangs — the Sidebar uses them to fade the skin group and open the context menu.
- `DynamicVariables=1` lets `IconName` re-resolve when the theme changes.

## Wire-up
- `Extras/Sidebar/Sidebar.ini` — `[TrayIcon]` [[Measure]]

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- Only one tray icon per skin instance; the Sidebar is the single host.
- Third-party: the 32- and 64-bit DLLs are bundled in the `.rmskin` from `packaging/Plugins/TrayIcon/`; without them the Sidebar extra fails to load. See [[Packaging a rmskin]].

## See also
- [[_index]]
- [[ConfigActive Plugin]]
