---
tags: [framework, settings]
---

# Language Settings Tab

> The settings tab for choosing the interface language and the temperature unit.

## Source

- `@Resources/Scripts/Settings/Language.inc` — the tab content: language and temperature rows

## How it works

`Language.inc` first chains three includes — `Languages/all.inc`, `Scripts/Contexts/Languages.inc`, and `Scripts/Contexts/Units.inc` — which supply the available options and their context menus.

It then draws two rows. The language row's `[LanguageValue]` shows the current `[#[#Language]]` token; clicking it sets `Context` to `Languages`, updates the tick-mark measure, and opens the [[Language Context Menu]] via `!SkinCustomMenu`. The temperature row works the same way through the [[Units Context Menu]]. Selecting an item from either menu writes the new value and refreshes, applying the choice across all widgets.

## Depends on

- [[Language Context Menu]] — popup for picking a language
- [[Units Context Menu]] — popup for picking a temperature unit
- [[Localization Token Pattern]] — `[#t...]` tokens render localized labels

## Used by

- [[Settings Tab Dispatch]] — loads this file when `SettingsTab=Language`

## See also

- [[_index]]
- [[Localization Flow]]
- [[Battery Settings Tab]]
