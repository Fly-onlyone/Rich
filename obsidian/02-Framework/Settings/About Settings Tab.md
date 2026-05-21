---
tags: [framework, settings]
---

# About Settings Tab

> The settings tab showing the Rich logo, version, license, credits, and outbound links.

## Source

- `@Resources/Scripts/Settings/About.inc` — the tab content: logo, text blocks, link buttons

## How it works

`About.inc` is presentational only — it has no toggles or [[InputText Plugin]] fields. It places the Rich logo image, then a centred stack of string [[Meter|meter]] rows: the **Rich** title, the version (`#tVersion#` label plus a literal `2.0`), the license (`CC BY-NC-SA 4.0`), and an "inspired by" credit to Big Sur for Rainmeter.

A few rows carry a `LeftMouseUpAction` that opens an external URL — the Creative Commons license page and the inspiration's DeviantArt page. A single centred `[GitHub]` button links to the project's repo (`github.com/Fly-onlyone/Rich`). Note `[Title]` doubles as the `MeterStyle=Title` base for the version/license/inspired rows, so its `StringAlign=Center` is overridden per row — `Right` for labels, `Left` for values.

## Depends on

- [[Global Variables]] — `SidebarWidth`, `WidgetWidth`, `FontFace`, `ForegroundColor` for layout
- [[Localization Token Pattern]] — `#tVersion#`, `#tLicense#`, `#tInspired#` labels

## Used by

- [[Settings Tab Dispatch]] — loads this file when `SettingsTab=About`

## See also

- [[_index]]
- [[WhatsNew Screen]]
- [[Sidebar Settings]]
