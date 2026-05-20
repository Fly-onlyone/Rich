---
tags: [widgets, weather]
---

# Weather City Search

> The Settings screen that lets the user type a city name and resolves it to coordinates via Open-Meteo's geocoding API, persisting the result.

## Source

- `Widgets/Weather/Settings.ini` — `Option1Input`, `UpdateCity`, `City`/`Latitude`/`Longitude`
- `@Resources/Variables/Weather.inc` — target file for persisted values

## How it works

`Option1Input` is an `InputText` plugin [[Measure]]. On submit it sets the `City` variable, shows "Updating...", and triggers `UpdateCity` — a [[WebParser]] [[Measure]] hitting `geocoding-api.open-meteo.com/v1/search?name=#City#&count=1`. A [[RegExp]] extracts `name`, `latitude`, and `longitude`. Its `FinishAction` uses `!WriteKeyValue` to write `Latitude`, `Longitude`, and `City` back into `@Resources/Variables/Weather.inc` ([[Settings Persistence Pattern]]). `UpdateCityDebug` logs the raw response ([[Debug Measure Pattern]]).

## Depends on

- [[Open-Meteo API]] — geocoding endpoint
- [[Settings Persistence Pattern]] — `!WriteKeyValue` writes to `Weather.inc`

## Used by

- [[Weather Widget]] — reads the persisted coordinates
- [[Weather Error State]] — `Action401`/`Action404` open Settings

## Gotchas

- `OnRegExpErrorAction` shows "City not found"; `OnConnectErrorAction` shows "Connection error" — neither raises the full [[Weather Error State]] skin.

## See also

- [[_index]]
- [[Settings Persistence Flow]]
