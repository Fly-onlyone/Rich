---
tags: [framework, settings]
---

# Extras Settings Tab

> The settings tab that manages Monterey's companion skins — ThemeUpdater, Sidebar, and Unlock.

## Source

- `@Resources/Scripts/Settings/Extras.inc` — the tab content: three companion-skin toggle rows

## How it works

`Extras.inc` lists three companion skins, each as a section with a title, a green/grey toggle pair, and localized help text. The skins are resolved through `#ROOTCONFIG#\Extras\...` so the toggles work when the checkout is linked under a development folder name such as `Rich`.

Each row has a `*Opened` [[Measure]] using the [[ConfigActive Plugin]] to detect whether that companion config is loaded; the `[&...Opened:]` value drives which toggle pill shows. Clicking a toggle runs `!ToggleConfig` on the matching config and `.ini`. The Sidebar toggle additionally calls `!ZPosGroup` to layer the skin, and the Unlock help text links to an installer `.lnk`.

## Depends on

- [[ConfigActive Plugin]] — detects which companion skins are active
- [[ThemeUpdater Skin]] — one of the companion skins toggled here
- [[Shape Meter]] — draws the toggle pills

## Used by

- [[Settings Tab Dispatch]] — loads this file when `SettingsTab=Extras`

## See also

- [[_index]]
- [[Battery Settings Tab]]
- [[Widgets Settings Tab]]
