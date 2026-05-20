---
tags: [operations]
---

# Loading & Refreshing Skins

> There is no build step — you load a config in Rainmeter and refresh it after every
> edit to see the change.

## Source

- Every `Widgets/<Name>/<Size>.ini`, `Extras/*/*.ini`, and root `Settings.ini` is a
  loadable Rainmeter *config*

## How it works

1. Install [Rainmeter](https://www.rainmeter.net/) and point it at this repo folder (or
   load the packaged `.rmskin` — see [[Packaging a rmskin]]).
2. **Load** a widget from the Rainmeter *Manage* window, or right-click an empty
   desktop area → the skin's menu.
3. After editing any `.ini` / `.inc` / `.lua`, **Refresh** the affected skin
   (right-click the skin → *Refresh*, or *Refresh all*).

A *refresh* re-parses the `.ini` and re-runs the whole [[Skin Composition Flow]], so
changes to included files only take effect on refresh. An *update* is the periodic tick
described in [[Update & Refresh Model]] and does not re-read files.

## Gotchas

- Editing a shared include (theme, size, scaffold) requires refreshing **every** widget
  that includes it, not just one.

## See also

- [[_index]]
- [[Reading the Rainmeter Log]]
