# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Monterey for Rainmeter** — a macOS-style widget pack for Windows, built entirely as a [Rainmeter](https://www.rainmeter.net/) skin. There is **no compiler, build system, package manager, or test suite**. The repo is a tree of Rainmeter config files (`.ini` / `.inc`), Lua scripts, images, fonts, and localization files that Rainmeter loads and renders directly.

The `.idea/` folder just means the repo was opened in IntelliJ — this is **not** a Java project; ignore those files (`palantir-java-format.xml` etc. are irrelevant). Upstream: `creewick/MontereyRainmeter`.

## Documentation vault

A full developer knowledge base lives in [`obsidian/`](./obsidian/_HOME.md) — a graph-linked Obsidian vault of ~150 atomic notes covering architecture flows, every widget, the shared framework, conventions, integrations, and operations. **Start at `obsidian/_HOME.md`.** It is the source of truth for cross-cutting behavior the code does not make obvious; consult the relevant note before changing a class of behavior, and update the matching note when you change it.

## Working in this repo (no build/lint/test)

- **Run / test a change:** load the skin in Rainmeter and *Refresh* it (right-click → Refresh). Each `Widgets/<Name>/<Size>.ini`, each `Extras/*/*.ini`, and the root `Settings.ini` is an independent Rainmeter "config" loaded and refreshed on its own.
- **Debug API/data issues:** several configs ship a parallel `*Debug` WebParser measure (e.g. `OpenMeteoParserDebug`, `UpdateCityDebug`) whose `FinishAction` dumps the raw response to the Rainmeter log via `!Log`. Read it in Rainmeter → *About* → *Log*.
- **Distribution:** end users install a `.rmskin` package built with Rainmeter's Skin Packager. No packager config and no `.rmskin` are committed to the repo.

## File encoding — important

Most `.ini` / `.inc` files are **UTF-16 LE with BOM** (Rainmeter's native encoding); a few newer ones (e.g. `Widgets/Weather/Settings.ini`) are UTF-8. When editing, **preserve each file's existing encoding** — saving a UTF-16 skin file as UTF-8 (or vice versa) can break how Rainmeter parses it. Check the encoding per file before editing.

## Architecture — the include cascade

A widget is never defined in one file. The project is understood by following how `@IncludeN` directives compose a skin at load time.

A widget **size file** (e.g. `Widgets/Clock/Small.ini`) is deliberately thin: it sets `WidgetName`, `WidgetSize`, a few overrides, and chains includes:

```
Widgets/<Name>/<Size>.ini
  -> @Resources/Variables/<Name>.inc           per-widget variable defaults
  -> @Resources/Scripts/Includes/Widget.inc    shared widget scaffold
  -> @Resources/Scripts/Widgets/<Name>.inc     this widget's measures & meters
  -> @Resources/Languages/<lang>/Widgets/<Name>.inc   localized strings
```

`Widget.inc` in turn pulls in the global layer:

```
@Resources/Variables/Global.inc               skin-wide defaults (Theme, Language, Units...)
@Resources/Scripts/Themes/<Theme>.inc          active theme -> sets Background/ForegroundColor
@Resources/Scripts/Sizes/<WidgetSize>.inc      active size  -> sets WidgetWidth/WidgetHeight
@Resources/Languages/<lang>/Widget.inc         shared localized strings
@Resources/Scripts/Includes/Context.inc + Scripts/Contexts/Widget.inc   right-click menu
```

So **theme, size, and language are all selected by variables** (`Theme`, `WidgetSize`, `Language`) and applied uniformly by swapping which include file is pulled in. To change behavior across every widget, edit the shared include — not each widget. Note: `@IncludeN` numbers must be unique within a `[Variables]` section; a reused number silently overrides the earlier include.

## Directory layout

- `Widgets/<Name>/` — one folder per widget (Clock, Calendar, Music, Weather, Monitor, Volume, Notes, Reminders, Timer). Each has four size files (`Small`/`Medium`/`Wide`/`Large.ini`), a `Settings.ini` (its settings-panel page), and `WhatsNew.ini` (changelog popup).
- `@Resources/` — everything shared:
  - `Variables/` — per-widget default variables + `Global.inc` (skin-wide defaults) + `Layout.inc`. **Persisted settings live here** (see below).
  - `Scripts/Includes/` — shared scaffolds: `Widget.inc`, `Window.inc`, `Settings.inc`, `Context.inc`, `WhatsNew.inc`.
  - `Scripts/Themes/` — `Light/Dark/Auto/Color/Blur.inc`; the active one is included by name.
  - `Scripts/Sizes/` — `Small/Medium/Wide/Large.inc`; define `WidgetWidth`/`WidgetHeight` from `WidgetBase`.
  - `Scripts/Widgets/` — per-widget logic: `.inc` (measures + meters) and `.lua` (Calendar, Reminders, Timer).
  - `Scripts/Contexts/` — right-click context-menu definitions.
  - `Scripts/Settings/` — pages/tabs of the settings panel.
  - `Images/`, `Fonts/` (SF Pro Display), `Languages/` (`en`, `ru`, `ua`, `de`), `Sounds/`.
- `Extras/` — standalone companion skins, each its own config: `AutoLowPowerMode`, `Sidebar`, `ThemeUpdater`, `Unlock`.
- `Settings.ini` (root) — the settings-panel skin shell.

## Key conventions

- **Settings persistence:** user choices are saved by writing them back into `@Resources/Variables/*.inc` with the `!WriteKeyValue` bang. In Lua this is the `setAndSave(variable, value)` helper, which writes the key *and* `!SetVariable`s it live. Editing those `Variables/*.inc` files changes the shipped defaults.
- **Theming:** the `Theme` variable (default `Blur`) is mapped to a number by the recurring `[ThemeAsNumber]` String measure (`Light`→1 … `Blur`→5) for use in conditional `Hidden=` expressions. `Blur` is special — it uses the `FrostedGlass` plugin for the acrylic effect and the `Chameleon` plugin to auto-detect Windows light/dark mode.
- **Layout math:** meters are positioned with expressions relative to `WidgetWidth`/`WidgetHeight` (e.g. `X=(#WidgetPadding# + #WidgetWidth# * 0.05)`), so one set of files works at all four sizes.
- **Localization:** UI strings are token variables named `#t...#`, defined in `Languages/<lang>/...` and referenced via the nested form `[#t...#]`. Never hardcode display text.
- **Group bangs:** measures/meters are tagged `Group=Measures` / `Group=Meters` so logic can refresh them wholesale with `!UpdateMeasureGroup` / `!UpdateMeterGroup`. Every skin's `[Rainmeter]` section is also tagged `Group=Monterey`: a settings write that must reach the running widgets persists with `!WriteKeyValue` and then reloads them with **`!RefreshGroup Monterey`** (reloads every pack skin — widgets *and* the settings panel). Use `!RefreshGroup Monterey`, **not** `!RefreshApp` — `!RefreshApp` does not reliably reload the already-loaded widget configs, so a theme/size change would update only the settings panel.

## Weather widget specifics

Weather uses the free **Open-Meteo** API — no key required. `@Resources/Variables/Weather.inc` keeps an empty `APIKey` variable that nothing in the skin currently reads. Secrets (API keys) belong in `@Resources/Variables/Secrets.inc` — a **gitignored** local-override file `@Include`d at the end of `Weather.inc`; copy the tracked `Secrets.inc.example` to create it. Its `APIKey=` overrides the empty default.

- Forecast: `OpenMeteoParser` (WebParser) calls `api.open-meteo.com/v1/forecast`.
- City search: `UpdateCity` (in `Widgets/Weather/Settings.ini`) calls `geocoding-api.open-meteo.com` and writes the resolved `Latitude`/`Longitude`/`City` back into `Variables/Weather.inc`.
- The forecast `RegExp` is one large positional pattern: it captures every JSON array element with the `#T#` capture-group macro, and downstream measures select values by hard-coded `StringIndex` offsets (current temp = 2; hourly temps start at 4; hourly weather codes at 34; daily lows at 64; daily highs at 70; daily icons at 76). **If you change which fields the API URL requests, every index offset must be recalculated** — this is the most common source of weather bugs.
- WMO `weathercode` integers are mapped to icon names via the `IconName` substitution table in `Weather.inc`.
