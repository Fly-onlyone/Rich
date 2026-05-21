---
tags: [framework, contexts]
---

# Language Context Menu

> The right-click menu for selecting the skin's UI language.

## Source

- `@Resources/Scripts/Contexts/Languages.inc` — fills the `Languages*` title/action pairs

## How it works

`Contexts/Languages.inc` defines `LanguagesContextTitle*` / `LanguagesContextAction*` pairs for the four supported languages: `ru`, `ua`, `en`, `de`. The titles use localized strings (`#ru#`, `#ua#`, etc.) so each is shown in its own language.

Each action `!WriteKeyValue`s `Language` into `Variables\Global.inc`, then runs `!RefreshGroup Rich` so every skin in the group reloads with the new locale — the [[Settings Persistence Pattern]] feeding the [[Localization Flow]].

A `[SetLanguageTickMark]` String [[Measure]] reads `#Language#` and `IfMatch` appends a checkmark `[\x2714]` to the active language — the [[Tickmark Indicator]].

## Depends on

- [[Context Scaffold]] — relays the title/action pairs
- [[Tickmark Indicator]] — marks the active language
- [[Localization Flow]] — `!RefreshGroup` reloads localized strings

## Used by

- [[Context Menu Flow]]

## Gotchas

- The `de` branch reuses `IfMatchAction3` (a likely copy-paste slip), so its checkmark may not appear correctly.

## See also

- [[_index]]
- [[Context Menu Factory Pattern]]
