---
tags: [widgets, weather]
---

# Weather Error State

> The error-handling path: an `IsError` flag, an `ErrorCode`, a corner warning badge, and a dedicated `Error.ini` skin that explains the failure.

## Source

- `@Resources/Scripts/Widgets/Weather.inc` — `IsError`, `ErrorCode`, `SetIsError`
- `Widgets/Weather/Error.ini` — the full-screen error skin
- `Widgets/Weather/Medium.ini`, `Large.ini` — `ErrorCircle` badge
- `@Resources/Languages/en/Widgets/Weather.inc` — `tWeatherError*` strings

## How it works

`OpenMeteoParser`'s `OnConnectErrorAction` sets `IsError`. The `ErrorCode` [[WebParser]] [[Measure]] plus the `SetIsError` measure inspect the response for an `"error"` field and toggle the `IsError`/`ErrorCode` variables ([[DynamicVariables Pattern]]). On the normal skins, `ErrorCircle` is a red badge [[Meter]] hidden when `#IsError#=0`; clicking it opens `Error.ini`. `Error.ini` matches `ErrorCode` against `1|401|404|429` (`IsKnownError`) and shows the matching `tWeatherError<code>Title/Text/Action` strings, with action buttons that restart, open [[Weather City Search]], or close back to the widget.

## Depends on

- [[Weather Forecast Parsing]] — `OnConnectErrorAction` raises the flag
- [[Localization Flow]] — `tWeatherError*` strings

## Used by

- [[Weather Widget]] — hosts the `ErrorCircle` badge

## Gotchas

- `OpenMeteoParser`'s error action contains a typo `!SerVariable`, so `ErrorCode` is mainly set by the `SetIsError`/`IsKnownError` measures.

## See also

- [[_index]]
- [[Weather Data Flow]]
