---
tags: [framework, settings]
---

# About Settings Tab

> The settings tab showing the Monterey logo, version, license, credits, and outbound links.

## Source

- `@Resources/Scripts/Settings/About.inc` — the tab content: logo, text blocks, link buttons

## How it works

`About.inc` is presentational only — it has no toggles or [[InputText Plugin]] fields. It places the Monterey logo image, then a stack of string [[Meter|meter]] rows: the "Monterey Rainmeter" title, the version (`#tVersion#` label plus a literal `1.0.1`), the license (`CC BY-NC-SA 4.0`), and an "inspired by" credit to Big Sur for Rainmeter.

Several rows carry a `LeftMouseUpAction` that opens an external URL — the author's GitHub, the Creative Commons license page, the inspiration's DeviantArt page. Three bottom buttons styled by `[GitHub]` link to the project's GitHub repo, Telegram, and the Rainmeter forum thread.

## Depends on

- [[Global Variables]] — `SidebarWidth`, `FontFace`, `ForegroundColor` for layout
- [[Localization Token Pattern]] — `#tVersion#`, `#tLicense#`, `#tInspired#` labels

## Used by

- [[Settings Tab Dispatch]] — loads this file when `SettingsTab=About`

## See also

- [[_index]]
- [[WhatsNew Screen]]
- [[Sidebar Settings]]
