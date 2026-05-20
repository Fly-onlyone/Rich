---
tags: [operations, release]
---

# Packaging a rmskin

> End users install the skin as a single `.rmskin` file — a package built with
> Rainmeter's own Skin Packager.

## Source

- The repo tree itself is the package contents
- No packager config file is committed to the repo

## How it works

A `.rmskin` is a self-installing archive. To build one:

1. Open Rainmeter's **Skin Packager** (in the installer toolset / *Manage* tools).
2. Add the skin folders (`Widgets/`, `Extras/`) and `@Resources/`.
3. Set the package name (`Monterey`), author, and version.
4. Export — the result is `Monterey.rmskin`, which the README points users to.

The `.rmskin` is **not** checked into the repo; releases are published on GitHub.

## Gotchas

- The package must include `@Resources/` — the widgets are non-functional without the
  shared [[02-Framework/_index|Framework]] files they `@Include`.
- Bump the `Version` in each widget's `[Metadata]` section to match the release.

## See also

- [[_index]]
- [[Adding a New Widget]]
