# Cognitive Code — Claude Code Plugins

Internal Claude Code marketplace. Right now it hosts one plugin: **`legacy-toolkit`** — skills for onboarding, repairing, and auditing legacy codebases, plus a deterministic guard that blocks destructive shell commands.

---

## For developers — install it (one time)

> Replace `<your-org>/claude-legacy-marketplace` below with the real GitHub repo path once it's pushed (see the maintainer section).

Inside any `claude` session, run these two slash commands:

```
/plugin marketplace add <your-org>/claude-legacy-marketplace
/plugin install legacy-toolkit@cognitivecode
```

That's it. The plugin installs at **user scope (global)** — it's now active in **every** repo you open with Claude Code. No copying files, no editing settings, no per-project setup.

(If you prefer the terminal, the same two commands work as `claude plugin marketplace add …` / `claude plugin install …`.)

### What you just got

- **Three skills** that trigger automatically from plain English:
  - `legacy-discover` — "make this codebase run locally" → investigates read-only, writes `DISCOVERY.md` with a checklist of what "done" means, and stops for your review.
  - `legacy-repair` — "execute the repair plan" → works through the blockers, logs what it actually ran to `VERIFICATION_REPORT.md`, and writes a verified `CLAUDE.md`.
  - `principal-audit` — "do a principal engineer audit" → strategic `CODEBASE_AUDIT.md` (architecture, risks, refactor-vs-replace). Read-only.
- **A read-only explorer subagent** (`repo-explorer`) for cheaply mapping big repos.
- **A safety hook** that blocks destructive bash commands (`rm -rf`, `git push --force`, `terraform destroy`, `DROP TABLE`, …) **before they run** — and composes with any hooks you already have, so nothing of yours is overwritten.

### Using it

Open a legacy repo, run `claude`, then just talk to it:

> Make this codebase run locally.   *(discovery — produces a plan, then waits)*
> Execute the repair plan.          *(repair — fixes blockers against that plan)*
> Do a principal engineer audit of this codebase.   *(strategic review)*

### Requirements

The guard hook parses tool input with `jq`, `python3`, `python`, or `perl` — at least one of which is present on virtually every dev machine (macOS ships `python3` + `perl`). If somehow none are installed, the hook **fails safe**: it blocks bash commands until you install one, rather than letting them through unchecked.

### Updating / removing

```
/plugin update legacy-toolkit@cognitivecode     # pull the latest the maintainer pushed
/plugin uninstall legacy-toolkit@cognitivecode  # remove it
```

---

## For the maintainer — publish & update

This repository **is** the marketplace. Its layout:

```
claude-legacy-marketplace/                 ← push THIS directory as a GitHub repo
├── .claude-plugin/
│   └── marketplace.json                   ← lists the plugin(s); "name" = cognitivecode
└── plugins/
    └── legacy-toolkit/
        ├── .claude-plugin/plugin.json     ← plugin manifest (no version → see below)
        ├── skills/{legacy-discover,legacy-repair,principal-audit}/SKILL.md
        ├── agents/repo-explorer.md
        ├── hooks/hooks.json               ← auto-loaded; do NOT also list it in plugin.json
        └── scripts/check-destructive.sh   ← the guard (executable)
```

### First publish

```bash
cd claude-legacy-marketplace
git init && git add -A && git commit -m "Initial legacy-toolkit plugin"
git branch -M main
git remote add origin git@github.com:<your-org>/claude-legacy-marketplace.git
git push -u origin main
```

Then tell the team to run the two install commands above (with the real repo path).

### Pushing updates

`plugin.json` deliberately has **no `version` field**, so Claude Code uses the git commit SHA as the version. Practical effect: **every push is a new version** and `claude plugin update` pulls it — you never have to remember to bump a number. (Trade-off: no explicit release labels. If you'd rather have named releases, add `"version": "1.0.0"` to `plugin.json` and bump it on every change — but note that if you set a version and forget to bump it, updates silently stop reaching the team.)

```bash
# edit files, then:
git commit -am "…"; git push
# developers pick it up with:  /plugin update legacy-toolkit@cognitivecode
```

### Validate before pushing

```bash
claude plugin validate ./plugins/legacy-toolkit   # plugin manifest + components
claude plugin validate .                          # marketplace manifest
```

(The only expected warning is "No version specified" — intentional, per above.)

### Private repo note

If the GitHub repo is private, developers' existing `git` credentials (Keychain / `gh auth`) cover the manual install and update. For **background** auto-updates, each dev needs a `GITHUB_TOKEN` in their environment.

### Renaming the marketplace

The string after `@` in `legacy-toolkit@cognitivecode` is the `name` in `.claude-plugin/marketplace.json`. Change it there if you want a different handle; tell the team the new one.
