---
tags: [framework, settings]
---

# Sidebar Settings

> The settings panel's left navigation column — the tab buttons that switch between settings pages.

## Source

- `@Resources/Scripts/Settings/Sidebar.inc` — defines `SidebarWidth` and the tab button rows

## How it works

`Sidebar.inc` sets `SidebarWidth=180`, fixing the width of the left column for the whole settings panel. It then draws a stack of navigation rows — Widgets, Extras, Appearence, Language, Battery, About — each made of a `*Shape` highlight, an icon, and a `*Text` label.

Clicking a tab label runs `!WriteKeyValue Variables SettingsTab "<Name>" "Layout.inc"` then `!Refresh` — the [[Settings Tab Dispatch]] mechanism. The active tab's `*Shape` highlight is shown by `[BackgroundMeter]`'s `OnUpdateAction=[!ShowMeter "[#SettingsTab]Shape"]`. A `[Support]` row instead opens a feedback form URL.

## Depends on

- [[Layout State]] — `SettingsTab` written here, `SidebarWidth` consumed downstream
- [[Settings Tab Dispatch]] — the write-and-refresh routing this sidebar triggers
- [[Localization Token Pattern]] — `#tWidgets#`, `#tAbout#` etc. label the tabs

## Used by

- [[Window Scaffold]] — `Settings.ini` includes the sidebar via `@include2`

## See also

- [[_index]]
- [[Settings Panel Flow]]
- [[Settings Tab Dispatch]]
