---
tags: [framework, settings]
---

# Theme Options

> The effect-options block of the Appearance tab — it now shows only the inputs relevant to dynamic effects.

## Source

- `@Resources/Scripts/Settings/Appearence/ThemeOptions.inc` — `InputText` fields for Auto schedule and Wallpaper color templates

## How it works

`ThemeOptions.inc` defines a `DarkThemeFrom`/`DarkThemeTo` time pair for the Auto effect and `ColorThemeBackground`/`ColorThemeForeground` template fields for the Wallpaper effect. Each input is an [[InputText Plugin]] measure whose `Command1` writes into `Global.inc` followed by `!RefreshGroup Rich` so every loaded widget re-reads the changed theme state.

Visibility is driven by [[Theme As Number]]'s `EffectAsNumber`: the whole panel is hidden for Solid and Blur, Auto fields show at `2`, and Wallpaper fields show at `3`.

## Depends on

- [[InputText Plugin]] — provides the editable color fields
- [[Theme As Number]] — selects which effect field set is shown
- [[Global Variables]] — color values are persisted here

## Used by

- [[Appearance Settings Tab]] — includes this as its bottom subfile

## Gotchas

- Fixed palettes do not expose editable color fields; add or change palette files under `@Resources/Scripts/Palettes/`.

## See also

- [[_index]]
- [[Theme-As-Number Pattern]]
- [[Theme Selector]]
