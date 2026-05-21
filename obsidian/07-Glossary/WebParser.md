---
tags: [glossary]
---

# WebParser

> A built-in [[Measure]] type that fetches a URL and extracts values from the response
> with a [[RegExp]].

A parent `WebParser` downloads and matches; child `WebParser` measures with the same
`URL=[Parent]` pick capture groups by `StringIndex`. Rich uses it for the
[[Weather Data Flow]] and city geocoding. `FinishAction` fires when the fetch completes;
`OnConnectErrorAction` / `OnRegExpErrorAction` handle failure.

## See also

- [[_index]]
- [[RegExp]]
- [[Weather Forecast Parsing]]
