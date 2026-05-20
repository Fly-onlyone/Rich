---
tags: [integration]
---

# Open-Meteo API

> A free, keyless HTTP weather service supplying both the forecast data and city geocoding for the [[Weather Widget]].

## Used for
- [[Weather Widget]] — current, hourly, and daily forecast
- [[Weather Data Flow]] — city name to latitude/longitude lookup

## Configuration
- Forecast endpoint: `api.open-meteo.com/v1/forecast` with `latitude`, `longitude`, `temperature_unit=#Units#`, `current_weather=true`, plus `hourly` and `daily` parameters and `timezone=auto`.
- Geocoding endpoint: `geocoding-api.open-meteo.com/v1/search` with `name=#City#`, `count=1`, `language=#Language#`.
- The forecast response is parsed by one giant [[RegExp]] using the `#T#` capture-group token; the geocoding response yields name, latitude, longitude.

## Wire-up
- `@Resources/Scripts/Widgets/Weather.inc` — `[OpenMeteoParser]` [[WebParser]] for the forecast
- `Widgets/Weather/Settings.ini` — `[UpdateCity]` WebParser for geocoding

## Auth mode
No key required — Open-Meteo is fully keyless for non-commercial use.

## Gotchas
- An unused `APIKey` variable still sits in `@Resources/Variables/Weather.inc`; it is dead leftover from a previous weather provider and is never sent.
- Forecast `UpdateRate` is `60*30` (30 min); calling more often risks rate limiting.

## See also
- [[_index]]
- [[Debug Measure Pattern]]
