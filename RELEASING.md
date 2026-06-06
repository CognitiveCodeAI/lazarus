# Releasing Lazarus

Plugins are versioned by git commit (no `version` field in `plugin.json`), so `/plugin update` always pulls the latest `main`. GitHub tags/Releases (e.g. `v0.2.0`) are **human-facing markers, not version gates** — cut them when a milestone is worth announcing.

## Pre-tag checklist

Run from a clean clone of the exact commit you intend to tag.

### 1. Validate manifests  *(also enforced in CI)*

```bash
claude plugin validate ./plugins/lazarus
claude plugin validate ./plugins/lazarus-github
claude plugin validate .
# only expected warning: "No version specified"
```

### 2. Guard tests  *(also enforced in CI)*

CI runs `shellcheck` plus block/allow/precision assertions on `scripts/check-destructive.sh`. Re-run locally if you touched the guard or its blocklist.

### 3. Real-install smoke test  *(manual — not yet in CI)*

`claude plugin validate` checks manifests but **not** install-time behavior — file modes on shipped scripts, skills/hooks registering after load, etc. Run a full install cycle in an **isolated config dir** so it never touches your live `~/.claude` (which has Lazarus active):

```bash
SMOKE=$(mktemp -d); REPO="$(pwd)"
HOME="$SMOKE" claude plugin marketplace add "$REPO"
HOME="$SMOKE" claude plugin install lazarus@cognitivecode
HOME="$SMOKE" claude plugin install lazarus-github@cognitivecode
HOME="$SMOKE" claude plugin list      # expect every plugin: Status ✔ enabled
# teardown — use `rm -r`, NOT `rm -rf`: the guard blocks `rm -rf <path>`
rm -r "$SMOKE"
```

Expect each plugin `✔ enabled` and each skill present under the install cache (`…/plugins/cache/<marketplace>/<plugin>/<sha>/skills/<skill>/SKILL.md`). If anything fails to enable, **do not tag — fix it first.**

> Never run `claude plugin install`/`uninstall` against your real `~/.claude` mid-session — isolating `HOME` keeps the test from disturbing (or breaking) your working environment.

### 4. Tag + notes

```bash
gh release create v0.X.0 --target main --title "Lazarus v0.X.0 — <theme>" --notes-file <notes> --latest
```

Keep notes to **what actually shipped on `main`.** Do not document unbuilt or speculative features — releases describe the code at the tag, not the roadmap. Roadmap items go under a "deliberately not in this release" heading.

## Future

A CI smoke test (a scratch-container job that installs Claude Code and runs step 3 on every PR) would make the manual step automatic. Deferred until the maintenance cost is worth it.
