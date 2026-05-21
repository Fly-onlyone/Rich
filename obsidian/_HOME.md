---
tags: [moc, home]
---

# Rich for Rainmeter — Knowledge Vault

A graph-linked tour of the **Rich for Rainmeter** codebase. **Start with the
architecture flows** to build mental scaffolding, then drill into widgets, the framework,
or patterns as needed.

> **Rich for Rainmeter** is a macOS-style widget pack for Windows, built entirely as
> a [Rainmeter](https://www.rainmeter.net/) skin — a tree of declarative `.ini`/`.inc`
> config files (mostly UTF-16 LE) plus three Lua scripts. There is no compiler and no
> test suite; Rainmeter loads and renders the files directly. The hard part is invisible
> in any single file: a widget is *composed at load time* by a cascade of `@Include`
> directives that splice in theme, size, language, and per-widget logic.

## 🧭 Start here — Architecture flows

- [[Skin Composition Flow]] — how a size `.ini` becomes a rendered widget via `@Include` chaining
- [[Theming Flow]] — how the `Theme` variable repaints every widget
- [[Sizing Flow]] — how one widget renders at four sizes
- [[Localization Flow]] — how UI text is swapped per language
- [[Settings Persistence Flow]] — how user choices survive a refresh
- [[Weather Data Flow]] — how Open-Meteo JSON becomes forecast meters
- [[Settings Panel Flow]] — how the standalone settings skin drives the widgets
- [[Context Menu Flow]] — how right-click menus are built and routed
- [[Update & Refresh Model]] — Rainmeter's update tick and group bangs

## 🧱 Widgets

The ten end-user widgets. → [[01-Widgets/_index|All widgets]]

- [[01-Widgets/Clock/_index|Clock]] — analog/digital clock with timezones
- [[01-Widgets/Calendar/_index|Calendar]] — month grid with Lua date logic
- [[01-Widgets/Music/_index|Music]] — media player control + album-art coloring
- [[01-Widgets/Weather/_index|Weather]] — Open-Meteo forecast
- [[01-Widgets/Monitor/_index|Monitor]] — CPU/RAM/Disk/Net/Battery gauges
- [[01-Widgets/Volume/_index|Volume]] — system and per-app volume
- [[01-Widgets/Notes/_index|Notes]] — editable sticky note
- [[01-Widgets/Reminders/_index|Reminders]] — Lua-backed to-do list
- [[01-Widgets/Timer/_index|Timer]] — countdown with alarm
- [[01-Widgets/AIUsage/_index|AI Usage]] — Claude/Codex 5h + 7d rate-limit usage

## ⚙️ Framework

The shared `@Resources` machinery every widget depends on. → [[02-Framework/_index|All framework]]

- [[02-Framework/Includes/_index|Includes]] — the shared skin scaffolds
- [[02-Framework/Themes/_index|Themes]] — palettes, effects, and appearance resolution
- [[02-Framework/Sizes/_index|Sizes]] — the four size definitions
- [[02-Framework/Contexts/_index|Contexts]] — right-click menu definitions
- [[02-Framework/Settings/_index|Settings]] — the settings-panel pages
- [[02-Framework/Variables/_index|Variables]] — global and persisted state

## 🧩 Extras

→ [[03-Extras/_index|Standalone companion skins]]

## 🔌 External Integrations

→ [[04-Integrations/_index|Open-Meteo API + Rainmeter plugins]]

## 🪢 Patterns

→ [[05-Patterns/_index|Codebase conventions]]

## 🛠️ Operations

→ [[06-Operations/_index|Load, refresh, package, debug]]

## 📖 Glossary

→ [[07-Glossary/_index|Rainmeter terminology]]

## 🎯 Reading paths

**New contributor:** [[Skin Composition Flow]] → [[Widget Scaffold]] → [[01-Widgets/Clock/_index|Clock]] → [[Include Cascade Pattern]]

**Widget author:** [[Skin Composition Flow]] → [[Proportional Layout Pattern]] → [[Settings Persistence Pattern]] → [[Adding a New Widget]]

**Theming / appearance:** [[Theming Flow]] → [[Theme System]] → [[Blur Theme]] → [[Theme-As-Number Pattern]]

**Localization:** [[Localization Flow]] → [[Localization Token Pattern]] → [[Adding a New Language]]

**Operations / packaging:** [[Update & Refresh Model]] → [[Loading & Refreshing Skins]] → [[Reading the Rainmeter Log]] → [[Packaging a rmskin]]
