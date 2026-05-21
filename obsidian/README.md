# Rich for Rainmeter — Documentation Vault

This folder is an [Obsidian](https://obsidian.md) vault: a graph-linked, atomic-note
knowledge base for the **Rich for Rainmeter** skin pack.

## Open it

**In Obsidian:** *Open folder as vault* → select this `obsidian/` folder.

**As plain markdown:** every note is standard markdown — browse the folders directly in
any editor or on GitHub. `[[Wikilinks]]` are just text; Obsidian turns them into a graph.

Start at **[[_HOME]]** — the root Map of Content.

## What's inside

- `00-Architecture/` — cross-cutting flows (the include cascade, theming, weather data flow…)
- `01-Widgets/` — one subfolder per widget (Clock, Calendar, Music, Weather, …)
- `02-Framework/` — the shared `@Resources` machinery (includes, themes, sizes, contexts, settings)
- `03-Extras/` — the standalone companion skins
- `04-Integrations/` — the Open-Meteo API and every Rainmeter plugin used
- `05-Patterns/` — recurring conventions of the codebase
- `06-Operations/` — how to load, refresh, package, and debug the skin
- `07-Glossary/` — Rainmeter terminology

## Conventions

- **One concept per note**, 50–200 words, heavily cross-linked.
- Notes link to source file *paths* — they never embed code (code rots; notes shouldn't).
- Diagrams are Mermaid fenced blocks — no binary images.
- `_Templates/` holds the note shapes; every note follows one.

## Optional CLI smoke test (Obsidian 1.12+)

```powershell
$cli = "C:\Users\$env:USERNAME\AppData\Local\Programs\Obsidian\Obsidian.com"
& $cli files total
```
