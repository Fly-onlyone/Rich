---
tags: [widgets, aiusage]
---

# AIUsage Widget

> Tracks how much of the **5-hour rolling** and **7-day** rate-limit budget **remains** for one provider at a time — Codex or Claude — drawn as two refined bars with a near-cap warning colour.

## Source

- `Widgets/AIUsage/Small.ini` · `Medium.ini` · `Wide.ini` · `Large.ini` — thin size files; all four share one meter set
- `Widgets/AIUsage/Settings.ini` — per-widget settings page (scaffold only)
- `@Resources/Scripts/Widgets/AIUsage.inc` — measures + the refined single-provider bar meters
- `@Resources/Scripts/Widgets/AIUsage.ps1` — PowerShell parser (calls both providers' live usage endpoints; writes `@Resources/AIUsageData.txt`)
- `@Resources/Scripts/Contexts/AIUsage.inc` — right-click menu (provider switch + standard entries)
- `@Resources/Variables/AIUsage.inc` — `Provider` choice, threshold colours, `AIUsageRefreshSeconds`
- `@Resources/Images/AIUsage/5h.png` · `7d.png` — 30×30 monochrome row icons (clock / calendar)
- `@Resources/Languages/<lang>/Widgets/AIUsage.inc` — UI strings

## How it works

Following the [[Widget Scaffold]] pattern, every size file includes `Variables/AIUsage.inc`, `Widget.inc`, the `AIUsage.inc` measure/meter script, and localized strings. The meters live in `AIUsage.inc` (not the size files), positioned with `#WidgetWidth#`/`#WidgetHeight#` fractions so one layout scales to all four sizes.

The widget shows **one provider at a time** — the `Provider` variable (`Codex` | `Claude`). Each row leads with a clock (5h) or calendar (7d) icon, then a thick rounded `Shape` bar showing budget **remaining** and the remaining `%`. Meters bind to the active provider through the nested `#Provider#` form (`Measure#Provider#5Left`, fill colour `[#[#Provider]5Color]`).

The data pipeline avoids any `!Refresh` loop:

1. `[MeasureRun]` (the **RunCommand** plugin) runs `AIUsage.ps1` — once on load via `[MeasureInit]`, then every `#AIUsageRefreshSeconds#` (default `300`) via `[MeasureTimer]`.
2. `AIUsage.ps1` reads the local session files for **both** providers and writes a single delimited line to `@Resources/AIUsageData.txt`.
3. `[MeasureRun]`'s `FinishAction` tells `[MeasureData]` (a WebParser `file://` measure) to re-read that file.
4. Ten `Group=AIData` children expose raw values; `Group=AICalc` `Calc` measures derive *remaining* (`100 − used`); bars are coloured by [[Monitor Color Thresholds|the green/yellow/red threshold idea]] shared with the Monitor widget (keyed off *used* %, so a near-empty bar is red).

**Switching provider** — clicking the provider name, or a right-click menu entry from `Contexts/AIUsage.inc`, writes `Provider` to `Variables/AIUsage.inc` and `!Refresh`es, which re-resolves every `#Provider#`-bound meter.

**Codex** is read **live** from `chatgpt.com/backend-api/wham/usage` — `rate_limit.primary_window`/`secondary_window` → `used_percent` + epoch `reset_at` — using the OAuth token from `~/.codex/auth.json`. Account-wide (Codex CLI + IDE + cloud); the local `~/.codex/sessions` rollout files are a stale snapshot and are no longer used. Each good reading is cached to `@Resources/AIUsage-codex-cache.json` for use while the endpoint is throttled.

**Claude** is read **live** from Anthropic's undocumented `/api/oauth/usage` endpoint — `five_hour`/`seven_day` → `utilization` + ISO `resets_at` — using the OAuth token from `~/.claude/.credentials.json`. This is account-wide (Claude Code + Desktop + web) and works with Claude Code closed. The endpoint 429s aggressively, so each good reading is cached to `@Resources/AIUsage-claude-cache.json`; while throttled the widget shows the cached value. Only with no cache do the bars hide and the widget show an "unavailable" hint.

## Depends on

- [[Widget Scaffold]] — include chain and layout variables
- [[WebParser]] — reads back the parser's output file
- RunCommand plugin — runs the PowerShell parser

## Gotchas

- `RunCommand.dll` is **not** bundled with Rainmeter — it must be added to the `.rmskin` package, like the pack's other third-party plugins.
- `AIUsage.png` is the dedicated 50 × 50 dark glass usage-bars icon used by the Settings UI and `README.md`; regenerate it from `icon-prompt.md` if the design changes.
- Both usage endpoints (Codex `wham/usage`, Claude `oauth/usage`) are **undocumented** — they can rate-limit or change without notice; the widget reads each provider's OAuth credential every refresh (a consideration before distributing the pack).
- The 5h/7d row icons (`Images/AIUsage/5h.png` · `7d.png`) are generated from `icon-prompt-5h-7d.md`; until generated, the rows render without an icon (the bars still work).

## See also

- [[_index]]
- [[Adding a New Widget]]
