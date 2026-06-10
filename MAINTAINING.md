# Maintainer notes (publishing & updating)

This repository **is** the marketplace.

```
lazarus/                 ← this directory IS the GitHub repo root
├── .claude-plugin/marketplace.json        ← lists ALL plugins; "name" = cognitivecode (the @handle)
├── plugins/lazarus/                        ← core
│   ├── .claude-plugin/plugin.json          ← plugin manifest (no version → git SHA is the version)
│   ├── skills/{discover,repair,audit,audit-repair,presentation}/SKILL.md
│   ├── agents/repo-explorer.md
│   ├── hooks/hooks.json                     ← auto-loaded; do NOT also list it in plugin.json
│   └── scripts/check-destructive.sh         ← the guard (must stay executable / git mode 100755)
├── plugins/lazarus-github/                ← optional companion (audit's §11 → GitHub Issues)
│   ├── .claude-plugin/plugin.json
│   └── skills/issues/SKILL.md
└── plugins/lazarus-forge/                 ← optional companion (pre-build design review)
    ├── .claude-plugin/plugin.json
    └── skills/design-review/SKILL.md
```

**Pushing updates.** `plugin.json` deliberately omits `version`, so Claude Code uses the git commit SHA — every push is a new version and `claude plugin update` pulls it, no number to bump. (If you'd rather have named releases, add `"version"` and bump it on every change — but if you set it and forget to bump, updates silently stop.)

```bash
# edit files, then:
git commit -am "…" && git push
# devs pick it up with:  /plugin update lazarus@cognitivecode
```

**Validate before pushing** (the only expected warning is "No version specified"):

```bash
claude plugin validate ./plugins/lazarus   # plugin manifest + components
claude plugin validate .                          # marketplace manifest
```

**Gotcha that passes validation but fails to load:** never declare `"hooks": "./hooks/hooks.json"` in `plugin.json` — the standard `hooks/hooks.json` is auto-loaded, and declaring it too triggers "Duplicate hooks file detected." Only list *additional* hook files. Always test with a real local install (`claude plugin marketplace add ./. && claude plugin install …`), not just `validate`.

**Renaming the marketplace.** The string after `@` in `lazarus@cognitivecode` is `name` in `.claude-plugin/marketplace.json`.
