---
tags: [framework, variables]
---

# Per-Widget Variables

> One `.inc` file per widget under `@Resources/Variables/` holding that widget's own defaults and persisted user settings.

## Source

- `@Resources/Variables/Clock.inc` — `ShowSeconds`, `24HourFormat`, `Timezone`
- `@Resources/Variables/Weather.inc` — `APIKey`, `City`, `Latitude`, `Longitude`
- `@Resources/Variables/Timer.inc` — `StartTime`, `EndTime`, `PauseTime`, `VisibleTime`

## How it works

Each widget owns a small `[Variables]` file under `@Resources/Variables/`. It holds settings that are specific to that widget — display options, API credentials, geocoordinates, timer state.

These files serve two roles. As **defaults** they ship sensible starting values. As **persistence targets** they also receive runtime writes: settings pages and widgets use `!WriteKeyValue` [[Bang]]s to update them, and timer-style state (`StartTime`, `PauseTime`) is rewritten as the widget runs. [[Settings Scaffold]] `@Include`s `#WidgetName#.inc` so the page shows current values.

## Used by

- [[Settings Scaffold]] — includes the file for the widget being configured
- The widget's own skin (via its include cascade)

## Gotchas

- Mixing defaults and live state in one file means a user reset must re-supply defaults explicitly.

## See also

- [[_index]]
- [[Settings Persistence Pattern]]
- [[Layout State]]
