---
tags: [operations, ci]
---

# Static Checks

> `script/test-skin.ps1` catches what Rainmeter only reveals at runtime, or never. It
> runs locally, in the pre-commit hook, and in CI on every push.

## Source

- `script/test-skin.ps1` — the checks
- `.githooks/pre-commit`, `.githooks/commit-msg` — the local hooks
- `.github/workflows/ci.yml` — CI: checks, secret scan (gitleaks), dev package
- `.luacheckrc`, `PSScriptAnalyzerSettings.psd1` — linter configs

## How it works

`pwsh script/test-skin.ps1` (add `-Staged` for staged files only) prints
`path:line: [check] message` and exits 1 on any problem:

| Check | Catches |
|---|---|
| `encoding` | A `.ini`/`.inc`/`.lua` that is neither UTF-16 LE with BOM nor pure ASCII, see [[File Encoding Notes]] |
| `keys` | A key defined twice in one section (incl. a reused `@IncludeN`), or a `[Section]` declared twice with clashing keys |
| `include` | A static `@Include=#@#…` target that does not exist (gitignored local overrides like `Secrets.inc` are allowed) |
| `i18n` | A `Languages/en` file or key missing from another language, or a key only the other language has |
| `plugins` | A third-party `Plugin=` without its DLLs in `packaging/Plugins`, see [[Packaging a rmskin]] |
| `tracked` | `Secrets.inc` or the AI Usage runtime caches committed |
| `wikilinks` | A wikilink in this vault that resolves to no note |
| `lua`, `powershell` | luacheck and PSScriptAnalyzer findings, when the tools are installed (CI always runs both) |

Enable the hooks once per clone: `git config core.hooksPath .githooks`. `pre-commit`
runs the checks on the staged files; `commit-msg` rejects subjects that are not
Conventional Commits, because the release notes are built from them.

## Gotchas

- Rainmeter merges a `[Section]` declared twice in one file into **one** section: two
  meters that share a name become one meter with clashing keys. Give every meter a
  unique name.
- The Lua scripts are UTF-16 LE, which luacheck cannot read, so the script lints UTF-8
  copies (`-LuaUtf8Dir`). `.luacheckrc` allows Rainmeter's style of keeping state in
  globals set in `Initialize()`.
- File lookups are case-insensitive, like Rainmeter on Windows, so CI on Linux agrees
  with a local run.

## See also

- [[_index]]
- [[Packaging a rmskin]]
- [[File Encoding Notes]]
