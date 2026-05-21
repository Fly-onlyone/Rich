---
tags: [framework, settings]
---

# WhatsNew Screen

> The changelog / first-run screen that greets users after an update, with a continue button to dismiss it.

## Source

- `@Resources/Scripts/Settings/WhatsNew.inc` — the changelog UI shown inside `Settings.ini`
- `@Resources/Scripts/Includes/WhatsNew.inc` — the generic per-widget WhatsNew scaffold

## How it works

`Scripts/Settings/WhatsNew.inc` builds a welcome panel inside the settings window: a bold `[Title]` ("Welcome to Rich Rainmeter 1.0.1"), a `[SubTitle]`, and a rounded `[WhatsNew]` shape containing icon/title/text entries describing each change. Several later entries (Low Power Mode, Extras section) are commented out — only the Weather widget fix is live. A `[UserGuide]` link points new users to the GitHub wiki.

The separate `Scripts/Includes/WhatsNew.inc` is the reusable [[WhatsNew Scaffold]] used by individual widgets: it reads `#Icon1#`/`#Title1#`/`#Text1#` variables and provides a `[Close]` button that writes the widget size back to Medium and reactivates the config.

## Depends on

- [[WhatsNew Scaffold]] — the generic include behind per-widget changelogs
- [[Global Variables]] — `SidebarWidth`, `WidgetCenterX`, `FontFace`

## Used by

- [[Window Scaffold]] — the settings WhatsNew renders inside `Settings.ini`

## See also

- [[_index]]
- [[About Settings Tab]]
- [[Skin Composition Flow]]
