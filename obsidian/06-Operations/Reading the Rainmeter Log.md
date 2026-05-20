---
tags: [operations, debugging]
---

# Reading the Rainmeter Log

> Rainmeter has no debugger — the log is the only window into what a skin is doing.

## Source

- Rainmeter → *About* → *Log* tab
- `[!Log "…"]` bangs scattered through the skins

## How it works

The log records skin errors (bad `RegExp`, missing files, plugin failures) as they
happen. Two ways the codebase uses it:

1. **Errors** — a malformed measure or a missing include shows up here first.
2. **`*Debug` measures** — several configs ship a parallel WebParser whose `RegExp` is
   `.*` and whose `FinishAction` is `[!Log "[WEATHER DATA]: …"]`. Loading the widget
   dumps the *raw* API response to the log so you can see what the real parser had to
   work with. This is the [[Debug Measure Pattern]].

To debug Weather, watch for `[WEATHER DATA]` and `[GEOCODING DATA]` log lines.

## Gotchas

- `*Debug` measures still hit the network on every load — they are diagnostic, not
  something to leave wired into a release build.

## See also

- [[_index]]
- [[Debug Measure Pattern]]
- [[Weather Data Flow]]
