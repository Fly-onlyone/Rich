---
tags: [widgets, aiusage]
---

# AIUsage Widget

> Tracks how much of the **5-hour rolling** and **7-day** rate-limit budget **remains** for Claude — drawn as two refined bars with a near-cap warning colour.

## Source

- `Widgets/AIUsage/Small.ini` · `Medium.ini` · `Wide.ini` · `Large.ini` — thin size files; all four share one meter set
- `Widgets/AIUsage/Settings.ini` — per-widget settings page (scaffold only)
- `@Resources/Scripts/Widgets/AIUsage.inc` — measures + the refined bar meters
- `@Resources/Scripts/Widgets/AIUsage.ps1` — PowerShell parser (calls Claude's live usage endpoint; writes `@Resources/AIUsageData.txt`)
- `@Resources/Variables/AIUsage.inc` — threshold colours, live bar colours, `AIUsageRefreshSeconds`
- `@Resources/Images/AIUsage/5h.png` · `7d.png` — 30×30 monochrome row icons (clock / calendar); `Claude.png` — full-colour logo before the name (untinted)
- Right-click menu — the standard widget menu (`Scripts/Contexts/Widget.inc`); the widget has no custom context file
- `@Resources/Languages/<lang>/Widgets/AIUsage.inc` — UI strings

## How it works

Following the [[Widget Scaffold]] pattern, every size file includes `Variables/AIUsage.inc`, `Widget.inc`, the `AIUsage.inc` measure/meter script, and localized strings. The meters live in `AIUsage.inc` (not the size files), positioned with `#WidgetWidth#`/`#WidgetHeight#` fractions so one layout scales to all four sizes.

The widget is **Claude-only** — no provider switch. Each row leads with a clock (5h) or calendar (7d) icon, then a thick rounded `Shape` bar showing budget **remaining** and the remaining `%`. Meters bind directly to the Claude measures (`MeasureClaude5Left`, fill colour `#Claude5Color#`).

The data pipeline avoids any `!Refresh` loop:

1. `[MeasureRun]` (the **RunCommand** plugin) runs `AIUsage.ps1` — on load and then every `#AIUsageRefreshSeconds#` (default `900`), both driven by `[MeasureTimer]`: a `Calc` measure carrying `IfConditionMode=1`, so its `IfTrueAction` re-fires on every tick — the load-time update *and* each interval — instead of only on the first false→true edge (which would fire once and freeze the widget).
2. `AIUsage.ps1` reads Claude's live usage and writes a single delimited line (`claude5=…|claude7=…|claude5r=…|claude7r=…|claudeerr=…|`) to `@Resources/AIUsageData.txt`.
3. `[MeasureRun]`'s `FinishAction` tells `[MeasureData]` (a WebParser `file://` measure) to re-read that file.
4. Five `Group=AIData` children (`StringIndex` 1–5) expose raw values; `Group=AICalc` `Calc` measures derive *remaining* (`100 − used`); bars are coloured by [[Monitor Color Thresholds|the green/yellow/red threshold idea]] shared with the Monitor widget (keyed off *used* %, so a near-empty bar is red).

**Claude** is read **live** from Anthropic's undocumented `/api/oauth/usage` endpoint — `five_hour`/`seven_day` → `utilization` + ISO `resets_at` — using the OAuth token from `~/.claude/.credentials.json`. This is account-wide (Claude Code + Desktop + web) and works with Claude Code closed. The endpoint 429s aggressively, so each good reading is cached to `@Resources/AIUsage-claude-cache.json`; while throttled the widget shows the cached value. Only with no cache do the bars hide and the widget show an "unavailable" hint.

## Depends on

- [[Widget Scaffold]] — include chain and layout variables
- [[WebParser]] — reads back the parser's output file
- RunCommand plugin — runs the PowerShell parser

## Gotchas

- `RunCommand.dll` ships with Rainmeter (4.5+), so it is not bundled in the `.rmskin`.
- `AIUsage.png` is the dedicated 50 × 50 dark glass usage-bars icon used by the Settings UI and `README.md`; regenerate it from `icon-prompt.md` if the design changes.
- The Claude `oauth/usage` endpoint is **undocumented** — it can rate-limit or change without notice; the widget reads the Claude OAuth credential every refresh (a consideration before distributing the pack).
- Codex support was removed: the widget, parser and data line are Claude-only. A stale `@Resources/AIUsage-codex-cache.json` left from older versions is unused and safe to delete.
- The 5h/7d row icons (`Images/AIUsage/5h.png` · `7d.png`) are generated from `icon-prompt-5h-7d.md`; until generated, the rows render without an icon (the bars still work).

## See also

- [[_index]]
- [[Adding a New Widget]]
