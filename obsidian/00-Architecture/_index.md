---
tags: [moc, architecture]
---

# Architecture — Map of Content

> Cross-cutting flows that span many files. Read these first — every other note in the
> vault assumes you understand them.

## Composition & rendering

- [[Skin Composition Flow]] — how `@IncludeN` chaining assembles a widget at load time
- [[Update & Refresh Model]] — the update tick, `UpdateDivider`, and group bangs

## Appearance

- [[Theming Flow]] — `Theme` variable → theme include → repaint
- [[Sizing Flow]] — `WidgetSize` → size include → dimensions
- [[Localization Flow]] — `Language` variable → language includes → `#t…#` tokens

## State & data

- [[Settings Persistence Flow]] — `!WriteKeyValue` / Lua `setAndSave` back into `Variables/*.inc`
- [[Weather Data Flow]] — Open-Meteo fetch → WebParser → positional parsing → meters

## Configuration surfaces

- [[Settings Panel Flow]] — the standalone `Settings.ini` skin and its tabbed pages
- [[Context Menu Flow]] — right-click → `Context` variable → `Contexts/*.inc`

## See also

- [[_HOME]]
- [[02-Framework/_index|Framework]]
- [[05-Patterns/_index|Patterns]]
