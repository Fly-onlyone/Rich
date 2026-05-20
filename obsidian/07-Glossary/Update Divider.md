---
tags: [glossary]
---

# Update Divider

> A [[Section]] option (`UpdateDivider=N`) setting how many skin ticks pass between that
> section's updates; `-1` means "never update on the tick".

Monterey sets `DefaultUpdateDivider=-1` skin-wide, freezing every section by default, so
the periodic tick stays cheap. A section opts back in with its own `UpdateDivider`, or is
refreshed explicitly by a [[Bang]]. See [[Update & Refresh Model]] for the whole picture.

## See also

- [[_index]]
- [[Update & Refresh Model]]
- [[Group Bang Pattern]]
