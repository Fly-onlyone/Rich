---
tags: [widgets, weather]
---

# Weather Forecast Parsing

> The single [[WebParser]] measure and offset-indexed child measures that turn one Open-Meteo JSON response into every temperature, code, and icon value the widget displays.

## Source

- `@Resources/Scripts/Widgets/Weather.inc` — `OpenMeteoParser` plus all child measures
- `@Resources/Variables/Weather.inc` — supplies `Latitude`/`Longitude`/`Units`

## How it works

`OpenMeteoParser` is a `WebParser` [[Measure]] hitting `api.open-meteo.com/v1/forecast`, requesting `current_weather`, 30 hourly `temperature_2m`/`weathercode` values, and 6 daily min/max/`weathercode` values. One long [[RegExp]] uses the `#T#` capture macro (`T=(.*)[,\}]`) once per JSON array element, so the whole payload becomes a flat list of numbered capture groups.

Child `WebParser` measures (`URL=[OpenMeteoParser]`) then select a value by hard-coded `StringIndex`: current temp = 2, hourly temps from 4, hourly codes from 34, daily lows from 64, highs from 70, daily icons from 76. `Calc` measures round each value; `OnConnectErrorAction` raises [[Weather Error State]].

## Depends on

- [[Open-Meteo API]] — JSON source
- [[RegExp]] — flattens the response into indexed groups
- [[Update & Refresh Model]] — `UpdateRate` controls polling

## Used by

- [[Weather Widget]]
- [[Weather Code Icons]]

## Gotchas

- `StringIndex` offsets are hard-coded. Adding or removing any requested API field shifts every subsequent index — the top weather bug. The `Variables` section keeps `T=(.*)[,\}]` as the shared capture macro.

## See also

- [[_index]]
- [[Weather Data Flow]]
