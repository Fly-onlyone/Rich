---
tags: [glossary]
---

# Bang

> A command, written `[!Action …]`, that changes skin state at runtime.

Bangs are the verbs of a Rainmeter skin. Monterey uses `!SetVariable` and
`!WriteKeyValue` for [[Settings Persistence Pattern]], `!UpdateMeasureGroup` /
`!UpdateMeterGroup` for the [[Group Bang Pattern]], and `!Refresh`, `!Redraw`,
`!ActivateConfig`, `!SkinCustomMenu` for navigation. Bangs fire from mouse actions,
`IfCondition` results, `FinishAction`, and Lua via `SKIN:Bang(...)`.

## See also

- [[_index]]
- [[Variable]]
- [[Update & Refresh Model]]
