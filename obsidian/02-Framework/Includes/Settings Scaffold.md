---
tags: [framework, includes]
---

# Settings Scaffold

> The `Settings.inc` shell for a per-widget settings page — header chrome plus the full include cascade.

## Source

- `@Resources/Scripts/Includes/Settings.inc` — settings-page `[Rainmeter]`, header [[Meter]]s, include chain

## How it works

`Settings.inc` is the boilerplate for each widget's settings skin. Its `[Variables]` block `@Include`s [[Global Variables]], the localized widget strings, the localized Widget file, the active theme, the **Large** [[Size Definitions]] entry, [[Context Scaffold]], the [[Per-Widget Variables]] file, and finally [[Layout State]] (`Layout.inc`).

It defines four shared header [[Meter]]s: `[IconMeter]` (the widget's PNG icon), `[Title]` (localized via the `[#t...]` [[Localization Token Pattern]]), `[SaveText]` (a right-aligned link that re-activates the widget at its chosen size), and `[Description]` (gray subtitle text). All positions are proportional to `WidgetWidth`/`WidgetHeight`.

## Depends on

- [[Layout State]] — reads the widget's chosen size for `[SaveText]`
- [[Per-Widget Variables]] — current values shown on the page
- [[Size Definitions]] — forces the Large layout

## Used by

- Per-widget settings skins ([[Settings Panel Flow]])

## See also

- [[_index]]
- [[Widgets Settings Tab]]
- [[Include Cascade Pattern]]
