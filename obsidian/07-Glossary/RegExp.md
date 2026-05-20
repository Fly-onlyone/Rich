---
tags: [glossary]
---

# RegExp

> The regular expression a [[WebParser]] applies to a response, or a [[Substitute]] uses
> to match values.

The Weather widget's forecast `RegExp` is a single large pattern: it uses `(?U)` for
non-greedy matching and repeats a `#T#` capture-group macro to grab every element of the
JSON arrays in order. Downstream measures then select captures by position — see
[[Weather Forecast Parsing]].

## See also

- [[_index]]
- [[WebParser]]
- [[Substitute]]
