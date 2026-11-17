---
tags: [operations, release]
---

# Packaging a rmskin

> End users install the skin as a single `.rmskin` file. `script/build-package.ps1`
> builds it from the repo, and pushing a `vX.Y.Z` tag publishes it as a GitHub release.

## Source

- `script/build-package.ps1` — stages and packs the `.rmskin`
- `packaging/Plugins/<Name>/{32bit,64bit}/<Name>.dll` — the bundled third-party plugins
- `.github/workflows/release.yml` — tag → GitHub release
- `cliff.toml` — release-notes config (git-cliff)

## How it works

`pwsh script/build-package.ps1 -Version 1.2.0` writes `dist/Rich_1.2.0.rmskin`:

1. Copies the **tracked** files of `@Resources/`, `Widgets/`, `Extras/`, `Settings.ini`
   and `LICENSE` into `Skins/Rich/`. Gitignored local files (`Secrets.inc`, the AI
   Usage caches) never ship.
2. Stamps the version into every `[Metadata] Version=` of the staged copies, in each
   file's own encoding. The repo's `Version=` keys are never edited by hand.
3. Copies the plugins to `Plugins/{32bit,64bit}/`, checking that each DLL's PE header
   matches its folder.
4. Generates `RMSKIN.ini`: `Load=Rich\Settings.ini` (the settings panel opens after
   install), `MinimumRainmeter`, `MinimumWindows`, and a `VariableFiles` list of every
   `@Resources/Variables/*.inc`.
5. Zips the folder and appends the 16-byte `.rmskin` footer (the zip size as a
   little-endian UInt64, then `\0RMSKIN\0`), the same format as Rainmeter's Skin Packager.

To release, push a tag: `git tag v1.2.0 && git push origin v1.2.0`. `release.yml` runs
the [[Static Checks]], builds `Rich.rmskin`, writes notes from the Conventional Commits
since the previous stable tag, and publishes the release. A tag with a suffix
(`v1.2.0-rc.1`) publishes a pre-release. Every push to any branch also uploads a dev
`.rmskin` as a CI artifact.

## Gotchas

- **Settings survive upgrades only through `VariableFiles`.** The installer moves the
  old `Skins\Rich` to `@Backup`, then copies each old `[Variables]` value into the new
  file, but only for keys present in **both** files. A key the new package lacks is
  dropped.
- A new third-party `Plugin=` needs its 32- and 64-bit DLLs in `packaging/Plugins/`;
  the [[Static Checks]] fail until they are there. Plugins that ship with Rainmeter
  (ActionTimer, InputText, PowerPlugin, RunCommand, UsageMonitor, Win7AudioPlugin, …)
  are never bundled; the installer skips them.
- Don't build with `rmskin-builder` / `rmskin-action`: it rewrites `RMSKIN.ini` with
  escaped backslashes (`Load=Rich\\Settings.ini`), which Rainmeter reads literally.
- Don't test-install a package on a dev machine whose `Skins\Rich` is a junction to the
  repo: the installer moves it to `@Backup`. Use Windows Sandbox or a VM.

## See also

- [[_index]]
- [[Static Checks]]
- [[Adding a New Widget]]
- [[Plugin]]
