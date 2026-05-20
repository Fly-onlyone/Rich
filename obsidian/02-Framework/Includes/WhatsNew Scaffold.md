---
tags: [framework, includes]
---

# WhatsNew Scaffold

> The `WhatsNew.inc` layout for the changelog / onboarding popup shown after an update.

## Source

- `@Resources/Scripts/Includes/WhatsNew.inc` — popup `[Rainmeter]`, content [[Meter]]s, close button

## How it works

`WhatsNew.inc` is the boilerplate for the [[WhatsNew Screen]]. Its `[Variables]` block runs an include cascade similar to [[Settings Scaffold]] — [[Global Variables]], localized strings, the active theme, the **Large** [[Size Definitions]] entry, and [[Layout State]].

The layout stacks two changelog rows, each an `[Icon]` + `[Title]` + `[Text]` trio (the second row reuses the first via `MeterStyle`). A `[WhatsNew]` header, a faint divider `[Line]`, and a `[Close]` button finish the popup. `[Close]` writes `Medium` as the widget's size into `Layout.inc` and activates the `Medium.ini` skin via a [[Bang]].

## Depends on

- [[Global Variables]] — fonts and theme colors
- [[Layout State]] — `[Close]` persists the chosen size here
- [[Size Definitions]] — forces the Large layout

## Used by

- The What's New popup skin ([[Update & Refresh Model]])

## See also

- [[_index]]
- [[WhatsNew Screen]]
