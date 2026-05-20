---
tags: [pattern]
---

# Debug Measure Pattern

> When a [[WebParser]] [[RegExp]] is failing, add a parallel `*Debug` parser that captures the raw response and logs it.

## When to apply
While developing or troubleshooting any WebParser-backed feature where the real `RegExp` may not match.

## The pattern
```ini
[OpenMeteoParserDebug]
Measure=WebParser
URL=https://api.open-meteo.com/v1/forecast?...
RegExp=.*
FinishAction=[!Log "[WEATHER DATA]: [&OpenMeteoParserDebug]"]
```

## Why
The production parser uses a strict multi-group `RegExp`; when the API response shape changes, it silently fails. A twin measure with `RegExp=.*` captures everything and `!Log`s it to the Rainmeter log, so you can see the actual JSON. Both `@Resources/Scripts/Widgets/Weather.inc` and `Widgets/Weather/Settings.ini` ship such a `*Debug` parser.

## Don't
- Don't leave the debug parser firing on a tight `UpdateRate` in a release — it spams the log.
- Don't point the debug parser at a different URL than the real one, or you debug the wrong response.

## See also
- [[_index]]
- [[Reading the Rainmeter Log]]
