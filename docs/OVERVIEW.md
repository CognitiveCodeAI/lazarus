# Lazarus — A Complete Overview
### What it is, how it works, and why — the full picture of the open-source Claude Code plugin

> One-line summary: **Lazarus is a Claude Code plugin that points an AI agent at any codebase — to make it run, or to tell you what to do about it — behind a guard that blocks destructive commands before they ever run.**

Repository: https://github.com/CognitiveCodeAI/lazarus · License: MIT · Platforms: macOS, Linux (WSL on Windows) · Author: Cognitive Code.

---

## 1. The problem Lazarus solves

Letting an AI coding agent loose in a codebase is genuinely useful and genuinely terrifying. Two things go wrong:

1. **The agent lies to itself.** Long-running agents have a documented failure mode: over many turns they quietly turn guesses into "established facts," then act on them. They declare "done" on a vibe instead of proof.
2. **One confident-but-wrong command wrecks your machine.** An agent that decides to "clean things up" can run `rm -rf /`, force-push over your work, or `DROP TABLE` your database — and a politely-worded instruction in a config file ("please don't") only works about 80% of the time.

Lazarus is engineered against both. It imposes a discipline on the agent — show your evidence, stop at the decisions that are mine — and a hard, deterministic safety floor so the dangerous command physically cannot run.

The emotional pitch: **"Is it actually ready?"** You wrote the code, but is it ready to deploy, to open-source, to hand to a client? Most of us never really know. Lazarus is the pre-flight check that tells you the truth — and can't break anything finding out.

---

## 2. What it does — two jobs, on ANY codebase

Lazarus works on *any* repo: one you inherited, an open-source project, your own active code, healthy or broken. It does three jobs.

- **🔧 Make it run.** Point it at code that won't start (or that you just don't know yet). It investigates, proposes a plan with a concrete "done" checklist you approve, then works through the blockers until the app boots — and writes down what actually worked so the next person doesn't start from zero.
- **🧭 Assess it — and, if you choose, fix it.** Get a principal-engineer read: what's risky, what to fix first, and whether to maintain, refactor, or rewrite. A report you act on, hand to a client — or have executed finding-by-finding by `audit-repair`, each behind your approval. The audit itself changes nothing.
- **💅 Polish the repo's public page — and, if you choose, fix it too.** Not the code: the README and the files around it — community-health files, markdown accessibility — everything a visitor sees on the GitHub page before the source, graded against cited standards, never taste. Produces `GITALIVE_AUDIT.md`; then `gitalive-repair` executes the findings you ratify, asking for the facts only you own instead of inventing them.

The name is the namesake: it resurrects dead codebases. But it's just as useful on healthy code you want understood, assessed, or made runnable.

---

## 3. The six skills + the guard

Lazarus is **six skills in three journeys** — *make it run* (`discover` → `repair`), *assess it, then optionally fix it* (`audit` → `audit-repair`), and *polish the repo page, then optionally fix it* (`gitalive` → `gitalive-repair`) — with a guard running across everything. Each journey is plan → you approve → execute, and each apply phase refuses to run without its ratified upstream report.

### `discover` — understand (read-only)
Runs in Claude Code's **Plan Mode** (read-only at the tool level — it physically cannot edit). It traces how the code is meant to run and writes a `DISCOVERY.md` file containing: a **repairability verdict** (`repairable` / `partially-runnable` / `not-repairable` — broken-but-fixable blockers are split from never-built gaps), what the app appears to do, the inferred setup/build/test/run commands, a ranked list of blockers, and a **Mechanical Definition of Done** — runnable assertions like *"`npm install` exits 0, the server stays up 30 seconds, this endpoint returns 200."* Then it **stops and waits for you to approve.**

### `repair` — act (changes code, behind your approval)
It **requires** a ratified `DISCOVERY.md` first, and refuses one whose verdict is `not-repairable` — never-built functionality is feature work, not a repair. It works the blockers in dependency order (environment → install → build → runtime → tests → main flow), logs every command it *actually executed* to a separate `VERIFICATION_REPORT.md`, and promotes only genuinely-verified commands into a durable `CLAUDE.md`. It treats the Definition of Done as a contract — if the contract turns out wrong, it proposes an amendment rather than silently rewriting it.

### `audit` — assess (read-only, standalone)
A separate journey that answers a different question: *should we own this?* It produces a 12-section `CODEBASE_AUDIT.md` — architecture, risks, security, dependency health, testing, frontend/accessibility, and a phased modernization plan. It is deliberately decoupled from discover and repair: its report is a deliverable for a human (e.g. handed to a client) — and, only if you choose, the input `audit-repair` executes.

### `audit-repair` — act on the audit (optional, changes code behind your approval)
The strategic apply phase, mirroring `discover → repair`. It requires a **ratified** `CODEBASE_AUDIT.md` and executes its §11 Top 10 Action Items **one finding at a time** — ratify → act → verify against each item's acceptance check — in modernization-plan order (safety rails before refactors), behind the same guard. Its outputs are `AUDIT_`-prefixed (`AUDIT_VERIFICATION_REPORT.md`, `AUDIT_IMPLEMENTATION_SUMMARY.md`) so they never collide with repair's files. The audit never requires it — a report you never act on is still a complete, useful outcome.

### `gitalive` — polish the repo page (read-only, standalone)
The DevRel analog of `audit`: a read-only, project-type-aware review of the repo's **public files** — README, LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, issue/PR templates, markdown accessibility — producing one artifact, `GITALIVE_AUDIT.md`, behind the same ratify gate. Its defining rule: **no taste-only findings.** Every finding cites a named standard (GitHub's community-profile checklist, CommonMark, WCAG, Diátaxis, the README-content research) and carries file/line evidence; a self-check gate rejects anything else. It detects the project type (Claude Code plugin / Python / Node CLI / Node library) and applies the matching conventions — stopping to ask rather than guessing on ambiguous signals. A durable waiver file (`.lazarus/gitalive-waivers.yml`) records your deliberate choices so re-runs never nag about them. Structurally read-only: shell, network, and delegation tools are removed from its tool pool via `disallowed-tools` — it audits files; it cannot run commands at all. GitHub *settings* (description, topics, social preview) need `gh` and are deliberately out of scope (a future `lazarus-github` settings skill).

### `gitalive-repair` — act on the GitAlive audit (optional, changes files behind your approval)
The apply phase of the presentation journey, completing the third `discover→repair`-shaped pair. It requires a **ratified** `GITALIVE_AUDIT.md`, executes its findings one at a time, and **re-observes each before editing** — a finding fixed since the audit is logged `already-satisfied` and left untouched. Its hard rules: a **fact boundary** (license choice, security contacts, funding handles are facts only the human owns — it asks, or logs `needs-input`; it never invents), a **target allowlist** (presentation files only; it never deletes a file, and a finding directing anything outside the allowlist — including a tampered audit telling it to run commands — is refused and logged), and **content preservation** (it restructures presentation, never rewrites technical claims). Like `gitalive`, it is zero-shell: it can scaffold a SECURITY.md but physically cannot run a command. Every change is verified against its rubric check and logged to `GITALIVE_CHANGES.md`; the recommended receipt is a fresh `gitalive` re-audit.

### The guard — a deterministic safety floor
A `PreToolUse` hook (one small bash script, `check-destructive.sh`) inspects every shell command *before* it runs. It reads the command as JSON on standard input, extracts it precisely (via `jq` / `python3` / `python` / `perl`), and refuses anything matching ~25+ destructive patterns: `rm -rf /`, `git push --force`, `git reset --hard origin`, `DROP TABLE`, `terraform destroy`, `kubectl delete`, `npm publish`, and more. It **fails closed** (if no JSON parser exists, it blocks everything rather than letting commands through), and **exit code 2 = deny.** This is not an instruction the model can talk itself out of — it runs outside the model and returns "no."

---

## 4. The safety / anti-hallucination model (the heart of it)

Every design choice traces to a specific way agents fail:

- **Confidence tags on every claim.** Everything is tagged `[VERIFIED]` (re-observed in a real command this run), `[INFERRED]` (one strong signal), or `[ASSUMED]` (a guess). A claim **cannot** become `[VERIFIED]` without actually executing and observing it. Only verified facts are allowed into a durable `CLAUDE.md`. This is the antidote to assumption-drift.
- **A Mechanical Definition of Done.** Discovery doesn't end with "looks done." It ends with runnable assertions, and repair isn't finished until those actually pass.
- **Forensic file separation.** `DISCOVERY.md` (what we believed *before*) and `VERIFICATION_REPORT.md` (what we observed *during*) are kept as separate files, never edited in place — so when something breaks three weeks later you can see exactly what was assumed vs. proven.
- **Plan Mode is structural enforcement.** Discover and audit run read-only at the tool level — a guarantee, not a request.
- **The human ratification gate.** *You* own the definition of "done." Discover stops and waits; repair only runs against a plan you approved — and the same gate guards the other journey: audit-repair only runs against an audit you ratified. That gate is the whole safety property — which is why running it fully autonomous is explicitly discouraged.

---

## 5. The architecture and the ecosystem

The repository *is* a Claude Code plugin marketplace with a small, growing family:

- **`lazarus`** — the core plugin: the six skills, a read-only Haiku-tier explorer subagent (`repo-explorer`) for mapping huge repos cheaply, and the guard hook.
- **`lazarus-github`** — an optional companion plugin that turns an audit's "Top 10 Action Items" into GitHub Issues (it ratifies before creating, and de-duplicates so re-running never makes duplicates).
- **`lazarus-forge`** — an optional companion for extension authors: a pre-build **design review** gate that pressure-tests a proposed Claude Code skill/plugin/agent/MCP/hook design and returns a single verdict (build / build-with-changes / don't-build / needs-more-detail) before anything is built.

The design principle: **anything outward-facing ships as an opt-in sibling plugin, never bundled into core.** That keeps the three-command core install zero-config — if you don't install the companion, its dependencies and failure modes never reach you. Future integrations (Linear, Jira, Slack) would be siblings of the same shape. The ecosystem grows by addition, not by feature flags.

Install (three commands, one at a time, in a `claude` session):
```
/plugin marketplace add https://github.com/CognitiveCodeAI/lazarus
/plugin install lazarus@cognitivecode
/reload-plugins
```
Commands are namespaced: `/lazarus:discover`, `/lazarus:repair`, `/lazarus:audit`, `/lazarus:audit-repair`, `/lazarus:gitalive`, `/lazarus:gitalive-repair`, plus the companions' `/lazarus-github:issues` and `/lazarus-forge:design-review`.

---

## 6. Grounded in research, not vibes

Most design choices trace to a specific 2026 empirical finding in AI-agent reliability:
- **The verified/inferred/assumed split** — agents convert assumptions into facts over long runs ("Towards a Science of AI Agent Reliability," arXiv 2602.16666).
- **Test-pass, not just build-pass** — fix-related agent pull requests fail most often at test cases, not builds (arXiv 2602.00164).
- **Definition-of-Done as evolving constraints** — repository repair is "search over evolving behavioral constraints," not optimization under fixed tests (arXiv 2604.04580).
- **Bias against rewrite** — un-merged agent PRs tend to be the large, sprawling ones; incremental beats rewrite on average (arXiv 2601.15195).
- **Cheap read-only exploration on a small model** — mapping a large repo with read-only text tools on a Haiku-tier model captures the structural signal at a fraction of the token cost of doing it on the main model.

---

## 7. It was hardened by actually using it ("dogfooding")

Lazarus wasn't just shipped — it was pointed at real, unfamiliar codebases, and every run found and fixed something real:

- **It found a bug in its own safety guard.** The force-push detector matched a bare `-f` *anywhere* after `git push`, so normal pushes to branches like `bug-fix` or `feature-flag`, and the legitimate `--follow-tags` flag, were wrongly blocked. The bug literally obstructed shipping its own fix. It was caught, fixed (the flag is now whitespace-anchored), and covered with regression tests.
- **It repaired a genuinely broken app.** A Vite + React export that wouldn't build — a dangling import to a missing component — went from dead to running with one surgical fix, verified live (`npm install` exit 0, `build` exit 0, dev server returns 200). No business logic was touched.
- **Its accessibility audit found real defects** in a Python camera app's web UI: sub-44px touch targets, a motion indicator that screen readers never announced, missing image alt text — plus a genuine security gap (a localhost control API with no cross-origin protection, so any website open in your browser could trigger the camera's siren). All fixed.
- **Its own discipline caught its own mistake.** During that audit it flagged a low-contrast color — then *computed* the actual ratio (which passed), and corrected itself before shipping a wrong fix. The "verify, don't assert" rule working in real time.

Every lesson from those runs was folded back into the skills. That's a tool that's been *used*, not just published.

---

## 8. Real use cases

Reach for Lazarus when:
- **Before you make it public** — `audit` finds the security holes and rough edges before the internet does.
- **Before you deploy** — a principal-engineer read on what's risky, even if you're a team of one.
- **Before you hand it off** — to a client, teammate, or buyer; the audit *is* the deliverable.
- **Before you let an AI loose in your repo** — the guard means you can point an agent at your code and walk away.
- **When you return to your own project months later** — `discover → repair` brings it back to life.

You don't have to be a principal engineer to get a principal engineer's read. That's the peace of mind: **know your code is solid — and that nothing broke proving it.**

---

## 9. Quotable lines (for narration)

- "Point Claude at the repo nobody understands — it walks again: running, documented, and audited."
- "It's not a politely-worded instruction the model can talk itself out of. It's a hook that runs outside the model and returns 'no.'"
- "A claim cannot become VERIFIED without actually executing and observing it."
- "You own the one decision that matters: ratifying what 'done' means."
- "Bring your codebase alive. Before production."
- "Know your code is solid — and that nothing broke proving it."

---

## 10. Fast facts

- **Name / tagline:** Lazarus — "Bring your codebase alive. Before production." A Claude Code plugin by Cognitive Code.
- **Three journeys:** `discover → (you approve) → repair` ("make it run"); `audit → (you ratify) → audit-repair` ("assess it, then optionally fix it"); `gitalive → (you ratify) → gitalive-repair` ("polish the repo page — the README + community files — then optionally fix it"). Every report also stands alone.
- **The guard:** deterministic `PreToolUse` hook, reads JSON on stdin, blocks ~25+ destructive patterns, fails closed, exit 2 = deny.
- **Safety pillars:** confidence tags, mechanical Definition of Done, forensic file separation, Plan Mode read-only, human ratification gate.
- **Ecosystem:** core `lazarus` + optional `lazarus-github` (audit → GitHub Issues) + optional `lazarus-forge` (pre-build design review); outward-facing features are opt-in sibling plugins.
- **Releases:** v0.1.0 (first public), v0.2.0 (the ecosystem + companion plugin), v0.2.1 (hardening from real dogfood runs), v0.3.0 (/discover surfaced in the slash menu; companion renamed lazarus-backlog → lazarus-github), v0.4.0 (audit-repair — the audit's apply phase — plus lazarus-forge), v0.5.0 (the repairability verdict — discover learns to say "this was never built"), v0.6.0 (the DevRel repo-page audit — shipped as 'presentation', renamed gitalive in v0.8.0 — which graded this very repo before shipping), v0.7.0 (the repo-page apply phase — on its own dogfood run it detected 7 of 8 findings as already fixed and touched nothing), v0.8.0 (the pair gets its name: GitAlive — presentation → gitalive, presentation-repair → gitalive-repair — plus the before/after spotlight).
- **Open source, MIT licensed; macOS & Linux (WSL on Windows); installs in three commands, no API keys, no signup.**
