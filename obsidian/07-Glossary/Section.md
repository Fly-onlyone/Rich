---
tags: [glossary]
---

# Section

> A `[Name]` block inside an `.ini` — the unit a [[Meter]], [[Measure]], or the special
> `[Rainmeter]` / `[Variables]` blocks are defined in.

Sections are referenced by name elsewhere: `[SectionName]` inlines a measure's value,
`[&SectionName]` reads it raw. Most of Rich's logic is sections wired together by
name across many `@Include`d files.

## See also

- [[_index]]
- [[Meter]]
- [[Measure]]
- [[Variable]]
