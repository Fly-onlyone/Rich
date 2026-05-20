---
tags: [moc, glossary]
---

# Glossary — Map of Content

> Rainmeter terminology used throughout the vault. Short definitions; follow the links
> for where each concept shows up.

## Skin anatomy

- [[Skin]] — a loaded `.ini` and everything it draws
- [[Config]] — a folder/`.ini` Rainmeter can load
- [[Section]] — a `[Name]` block inside an `.ini`
- [[Variable]] — a `#Name#` value substituted at parse time
- [[Container]] — a meter clipped inside another meter

## Building blocks

- [[Meter]] — something drawn on screen
- [[Measure]] — something that produces a value
- [[Shape Meter]] — a vector meter (rectangles, ellipses, lines)
- [[Plugin]] — a `.dll` that adds measure/meter types
- [[WebParser]] — the measure that fetches and regex-parses web data

## Behavior

- [[Bang]] — an `!Action` command (`!SetVariable`, `!Refresh`, …)
- [[Substitute]] — value rewriting on a measure
- [[RegExp]] — the regular expression a WebParser applies
- [[Update Divider]] — how often a section updates relative to the skin tick

## See also

- [[_HOME]]
- [[00-Architecture/_index|Architecture]]
