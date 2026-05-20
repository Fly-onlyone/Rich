---
tags: [widgets, weather]
---

# Weather Widget

> A Rainmeter skin that shows current conditions plus a 6-hour and 6-day forecast for one city, sourced from the Open-Meteo API.

## Source

- `Widgets/Weather/Medium.ini` — Medium layout: city, temp, icon, description
- `Widgets/Weather/Large.ini` — Large layout: adds hourly strip and daily rows
- `@Resources/Scripts/Widgets/Weather.inc` — shared measures (parsing, calc)
- `@Resources/Variables/Weather.inc` — persisted `City`, `Latitude`, `Longitude`

## How it works

Each size variant (`Medium.ini`, `Large.ini`) `@Include`s the [[Widget Scaffold]], the persisted [[Per-Widget Variables]], the shared `Weather.inc` script, and the localized strings. Layout coordinates are all expressed as fractions of `#WidgetWidth#`/`#WidgetHeight#` ([[Proportional Layout Pattern]]). [[Meter]]s read parsed [[Measure]]s by name and tint icon images with `#ForegroundColor#`. The Large layout also draws the daily high/low bars via [[Weather Forecast Parsing]] and `MeterStep`.

## Depends on

- [[Weather Forecast Parsing]] — supplies all temperature/code values
- [[Weather Code Icons]] — maps codes to icon images
- [[Weather City Search]] — resolves the city via Settings
- [[Open-Meteo API]] — upstream data source

## Used by

- [[Skin Composition Flow]]

## See also

- [[_index]]
- [[Weather Data Flow]]
- [[Weather Error State]]
