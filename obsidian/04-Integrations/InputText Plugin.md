---
tags: [integration]
---

# InputText Plugin

> A Rainmeter [[Plugin]] that pops up an in-skin text field so the user can type values directly into a widget.

## Used for
- [[Weather Widget]] — entering a city name
- [[Notes Text Editing]] — note body text
- Reminders and the [[Timer State Machine]] — text and duration entry
- [[Widgets Settings Tab]] — colour and number inputs

## Configuration
- `Plugin=InputText` with styling keys (`FontFace`, `FontColor`, `SolidColor`, `X/Y/W/H`).
- `DefaultValue=` pre-fills the field; `FocusDismiss=0` keeps it open on focus loss.
- `CommandN=` holds the bangs run on submit, with `$UserInput$` substituted for the typed text.
- Triggered via `!CommandMeasure "<measure>" "ExecuteBatch ALL"`.

## Wire-up
- `Widgets/Weather/Settings.ini` — `[Option1Input]` city field

## Auth mode
N/A (Rainmeter plugin DLL)

## Gotchas
- `$UserInput$` is only valid inside the `CommandN` keys; referencing it elsewhere yields the literal string.
- The plugin DLL must be bundled in the `.rmskin` or any widget with input fields fails to load.

## See also
- [[_index]]
- [[Settings Persistence Pattern]]
