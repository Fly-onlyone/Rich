---
tags: [glossary]
---

# Substitute

> A [[Measure]] option that rewrites the measure's output by find-and-replace, optionally
> with regular expressions (`RegExpSubstitute=1`).

Monterey uses `Substitute` constantly: mapping WMO weather codes to icon names
([[Weather Code Icons]]), turning the `Theme` string into a number
([[Theme-As-Number Pattern]]), normalizing `"-0"` to `"0"` on rounded temperatures, and
swapping newline markers in the Notes widget.

## See also

- [[_index]]
- [[RegExp]]
- [[Measure]]
