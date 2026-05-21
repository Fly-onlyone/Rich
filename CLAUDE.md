# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Rich for Rainmeter** — a macOS-style widget pack for Windows, built entirely as a [Rainmeter](https://www.rainmeter.net/) skin. There is **no compiler, build system, package manager, or test suite**. The repo is a tree of Rainmeter config files (`.ini` / `.inc`), Lua scripts, images, fonts, and localization files that Rainmeter loads and renders directly.

The `.idea/` folder just means the repo was opened in IntelliJ — this is **not** a Java project; ignore those files (`palantir-java-format.xml` etc. are irrelevant). The pack is **Rich**, a rebrand of the upstream `creewick/MontereyRainmeter`.

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
@Resources/Variables/Global.inc               skin-wide defaults (Palette, Theme, Language, Units...)
@Resources/Scripts/Palettes/<Palette>.inc      active colour scheme -> sets Palette{Background,Foreground,Accent}Color
@Resources/Scripts/Themes/<Theme>.inc          active effect -> resolves Background/ForegroundColor
@Resources/Scripts/Sizes/<WidgetSize>.inc      active size  -> sets WidgetWidth/WidgetHeight
@Resources/Languages/<lang>/Widget.inc         shared localized strings
@Resources/Scripts/Includes/Context.inc + Scripts/Contexts/Widget.inc   right-click menu
```

So **palette, effect, size, and language are all selected by variables** (`Palette`, `Theme`, `WidgetSize`, `Language`) and applied uniformly by swapping which include file is pulled in. To change behavior across every widget, edit the shared include — not each widget. Note: `@IncludeN` numbers must be unique within a `[Variables]` section; a reused number silently overrides the earlier include.

## Directory layout

- `Widgets/<Name>/` — one folder per widget (Clock, Calendar, Music, Weather, Monitor, Volume, Notes, Reminders, Timer, AIUsage). Each has four size files (`Small`/`Medium`/`Wide`/`Large.ini`), a `Settings.ini` (its settings-panel page), and `WhatsNew.ini` (changelog popup).
- `@Resources/` — everything shared:
  - `Variables/` — per-widget default variables + `Global.inc` (skin-wide defaults) + `Layout.inc`. **Persisted settings live here** (see below).
  - `Scripts/Includes/` — shared scaffolds: `Widget.inc`, `Window.inc`, `Settings.inc`, `Context.inc`, `WhatsNew.inc`.
  - `Scripts/Palettes/` — color schemes (`Light`, `Dark`, `Dracula`, `Nord`, … 15 total); each defines `Palette{Background,Foreground,Accent}Color` + `PaletteDarkMode`.
  - `Scripts/Themes/` — visual *effects* (`Solid/Auto/Color/Blur.inc`; `Light/Dark.inc` are legacy, unused); the active `Theme` is included by name.
  - `Scripts/Sizes/` — `Small/Medium/Wide/Large.inc`; define `WidgetWidth`/`WidgetHeight` from `WidgetBase`.
  - `Scripts/Widgets/` — per-widget logic: `.inc` (measures + meters) and `.lua` (Calendar, Reminders, Timer).
  - `Scripts/Contexts/` — right-click context-menu definitions.
  - `Scripts/Settings/` — pages/tabs of the settings panel.
  - `Images/`, `Fonts/` (SF Pro Display), `Languages/` (`en`, `ru`, `ua`, `de`), `Sounds/`.
- `Extras/` — standalone companion skins, each its own config: `AutoLowPowerMode`, `Sidebar`, `ThemeUpdater`, `Unlock`.
- `Settings.ini` (root) — the settings-panel skin shell.

## Key conventions

- **Settings persistence:** user choices are saved by writing them back into `@Resources/Variables/*.inc` with the `!WriteKeyValue` bang. In Lua this is the `setAndSave(variable, value)` helper, which writes the key *and* `!SetVariable`s it live. Editing those `Variables/*.inc` files changes the shipped defaults.
- **Settings panel layering:** the settings window's background panels (`[Container]`, `[SidebarMeter]`, `[RightHalfMeter]`, `[RightBottomMeter]`) live at the end of `Scripts/Settings/Sidebar.inc` — an earlier `@Include` than the tab content — so they render *behind* it. Meters draw in `@Include` order (earlier = behind); panels placed in `Settings.ini`'s own body would render on top of the tab content and wash it out.
- **Theming — Palette + Effect + Accent:** two variables drive colour. `Palette` (default `Monokai`) selects a scheme file in `@Resources/Scripts/Palettes/`, each defining `PaletteBackgroundColor`, `PaletteForegroundColor`, `PaletteAccentColor`, and `PaletteDarkMode`. `Theme` (default `Blur`) selects a visual *effect* in `@Resources/Scripts/Themes/` (`Solid`/`Auto`/`Color`/`Blur`); the palette is `@Include`d **before** the effect, and the effect resolves the final `BackgroundColor`/`ForegroundColor`/`DarkMode` that meters consume. `Theme` is mapped to an integer by the recurring `[EffectAsNumber]` String measure (`Solid`→1, `Auto`→2, `Color`→3, `Blur`→4) for conditional `Hidden=` expressions. `PaletteAccentColor` is each scheme's signature hue — used directly (independent of effect) for the clock second hand and the calendar today-highlight. `Blur` uses the `FrostedGlass` plugin for the acrylic effect; `Auto`/`Color` use the `Chameleon` plugin (time-of-day schedule / wallpaper sampling).
- **Layout math:** meters are positioned with expressions relative to `WidgetWidth`/`WidgetHeight` (e.g. `X=(#WidgetPadding# + #WidgetWidth# * 0.05)`), so one set of files works at all four sizes.
- **Widget opacity:** `WidgetOpacity` in `Global.inc` (percent, default `100`) sets the translucency of each widget's **background card only** — text, icons, and clock hands stay fully opaque. `Widget.inc`'s `[OpacityScript]` measure runs `Scripts/Includes/Opacity.lua`, which scales the effect's base background alpha (`255`, or `160` under `Blur` so the acrylic look survives at `100`%) by the percentage and writes a 2-hex `WidgetBackgroundAlpha` that the `[BackgroundMeter]` fill colour appends. `WidgetBackgroundAlpha` defaults to `ff` (`Global.inc`) / `a0` (`Blur.inc`) so popups and the settings panel keep their look. The Appearance tab's *Advanced Options* exposes the percentage beside Widget size/padding/radius.
- **Localization:** UI strings are token variables named `#t...#`, defined in `Languages/<lang>/...` and referenced via the nested form `[#t...#]`. Never hardcode display text.
- **Group bangs:** measures/meters are tagged `Group=Measures` / `Group=Meters` so logic can refresh them wholesale with `!UpdateMeasureGroup` / `!UpdateMeterGroup`. Every skin's `[Rainmeter]` section is also tagged `Group=Rich`: a settings write that must reach the running widgets persists with `!WriteKeyValue` and then reloads them with **`!RefreshGroup Rich`** (reloads every pack skin — widgets *and* the settings panel). Use `!RefreshGroup Rich`, **not** `!RefreshApp` — `!RefreshApp` does not reliably reload the already-loaded widget configs, so a theme/size change would update only the settings panel.

## Weather widget specifics

Weather uses the free **Open-Meteo** API — no key required. `@Resources/Variables/Weather.inc` keeps an empty `APIKey` variable that nothing in the skin currently reads. Secrets (API keys) belong in `@Resources/Variables/Secrets.inc` — a **gitignored** local-override file `@Include`d at the end of `Weather.inc`; copy the tracked `Secrets.inc.example` to create it. Its `APIKey=` overrides the empty default.

- Forecast: `OpenMeteoParser` (WebParser) calls `api.open-meteo.com/v1/forecast`.
- City search: `UpdateCity` (in `Widgets/Weather/Settings.ini`) calls `geocoding-api.open-meteo.com` and writes the resolved `Latitude`/`Longitude`/`City` back into `Variables/Weather.inc`.
- The forecast `RegExp` is one large positional pattern: it captures every JSON array element with the `#T#` capture-group macro, and downstream measures select values by hard-coded `StringIndex` offsets (current temp = 2; hourly temps start at 4; hourly weather codes at 34; daily lows at 64; daily highs at 70; daily icons at 76). **If you change which fields the API URL requests, every index offset must be recalculated** — this is the most common source of weather bugs.
- WMO `weathercode` integers are mapped to icon names via the `IconName` substitution table in `Weather.inc`.

## AI Usage widget specifics

The **AIUsage** widget (`Widgets/AIUsage/`) shows how much of the **5-hour rolling** and **7-day** rate-limit budget **remains**, for **one provider at a time** — Codex or Claude. The active provider is the `Provider` variable in `Variables/AIUsage.inc`, switchable at runtime by clicking the provider name on the widget or via the right-click menu (`Scripts/Contexts/AIUsage.inc`). It draws two rounded `Shape` bars with a near-cap warning colour.

- **Parser:** `@Resources/Scripts/Widgets/AIUsage.ps1` (PowerShell) reads both providers' live usage endpoints and writes a flat `@Resources/AIUsageData.txt` line. It is run by the **RunCommand** plugin — `[MeasureRun]` in `Scripts/Widgets/AIUsage.inc` — once on load and every `#AIUsageRefreshSeconds#` (default `900`). `RunCommand.dll` is **not** bundled with Rainmeter; it must be added to the `.rmskin` package.
- **Read-back:** `[MeasureData]` (WebParser, `file://`) parses `AIUsageData.txt`; ten `Group=AIData` child measures + `Group=AICalc` `Calc` measures derive *remaining* (`100 − used`). Meters bind to the active provider via the nested `#Provider#` form (e.g. `MeasureName=Measure#Provider#5Left`, fill colour `[#[#Provider]5Color]`), re-resolved by the `!Refresh` a provider switch fires. No run/refresh loop.
- **Codex:** live **account-wide** usage from `chatgpt.com/backend-api/wham/usage` (`rate_limit.primary_window`/`secondary_window` → `used_percent` + epoch `reset_at`), authenticating with the OAuth token from `~/.codex/auth.json` (`Bearer` + `chatgpt-account-id` header). Reflects the Codex CLI, IDE **and** cloud — the local `~/.codex/sessions` rollout files are a stale snapshot and are no longer used. Cached to `@Resources/AIUsage-codex-cache.json`; on failure the widget shows the cached value.
- **Claude:** `AIUsage.ps1` reads **account-wide** usage live from Anthropic's undocumented `/api/oauth/usage` endpoint (`five_hour`/`seven_day` → `utilization` + ISO `resets_at`), authenticating with the OAuth token from `~/.claude/.credentials.json` (`Bearer` + `anthropic-beta: oauth-2025-04-20`). Reflects Claude Code, Claude Desktop **and** claude.ai web, and works with Claude Code closed. The endpoint 429s aggressively, so each good reading is cached to `@Resources/AIUsage-claude-cache.json` — while throttled the widget shows that cached value (reset countdowns re-derived from the stored timestamps). Only with no cache does Claude show unavailable (`MeasureActiveErr` → `ActiveErr`/`ActiveOk`). The widget reads the OAuth credential each refresh — a consideration before distributing the pack.
- Threshold colours (`Green`/`Yellow`/`RedColor`, `YellowStarts`/`RedStarts`) live in `Variables/AIUsage.inc`, mirroring `Monitor.inc`. Colour keys off *used* %, so a near-empty *remaining* bar turns red.
- Images in `@Resources/Images/AIUsage/`: `5h.png`/`7d.png` (30×30 monochrome, tinted with `#ForegroundColor#`) for the row windows; `Claude.png`/`Codex.png` (full-colour provider logos, **untinted**) shown before the name. Fonts and icon sizes scale with `#AIUsageFS#` — a per-size font scale set in each `Widgets/AIUsage/<Size>.ini`; `Wide` bumps it ×1.3 so its content isn't dwarfed by the wide canvas.

## Monitor widget specifics

The **Monitor** widget (`Widgets/Monitor/`) shows CPU / RAM / Disk / Network usage gauges (plus Battery on the `Large` size). Slot assignment is the `Meter1`–`Meter6` variables in `Variables/Monitor.inc`; a slot set to `None` resolves to `-1` and is hidden. `Small` shows one gauge, `Medium`/`Wide` four Roundline gauges, `Large` six Histogram rows.

- **Measures** (`@Resources/Scripts/Widgets/Monitor.inc`) are each chosen to match Windows Task Manager:
  - **CPU** — UsageMonitor `Alias=CPU` (= `Processor \ % Processor Time`, total). Win8+ Task Manager nominally uses `% Processor Utility`, but on Turbo-Boosting CPUs that counter reads ≈2× high, so `% Processor Time` is the closer practical match. CPU is bursty — it will not match Task Manager to the exact digit.
  - **RAM** — built-in `PhysicalMemory` measures: `RAMMonitor` (a `Calc`) = `RAMUsed / RAMTotal * 100`, i.e. physical RAM in use — *not* commit charge / `% Committed Bytes In Use` (which includes the page file and reads ~10 % off Task Manager).
  - **Disk** — UsageMonitor on `PhysicalDisk \ % Idle Time` (`Name=_Total`, `InvertMeasure=1`) → activity (100 − idle) = Task Manager's "active time". `Name=_Total` must be pinned or the plugin reads an arbitrary disk instance.
  - **Net** — built-in `NetIn` + `NetOut` measures (auto-track the active adapter). The gauge is % of `NetLinkSpeed` (Mbps, in `Variables/Monitor.inc`) — this **must be set to the machine's real link speed** (default `1000` for gigabit Ethernet) or it is off by a constant factor.
- **Gauge updates:** each metric has an `ActionTimer` measure whose `[ActionList]` is fixed to `2`, so on every new reading it runs `ActionList2=Update` — the gauge **snaps** straight to the value (no easing, so the display never trails real usage). `ActionList1` is a disabled 10-step easing path; set `[ActionList]` `Formula=1` to re-enable the glide. Measures poll once per second (`UpdateDivider` 10, matching Task Manager); gauge meters refresh at `UpdateDivider=1`.
- Threshold colours (`Green`/`Yellow`/`RedColor`, `YellowStarts`/`RedStarts`) live in `Variables/Monitor.inc`; the AIUsage widget mirrors this scheme.
