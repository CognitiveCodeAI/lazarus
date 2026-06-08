# Design-Review Rubric

The full evaluation surface. Every finding carries a **stable kebab-case ID** (the row key), an **evidence class**, and a **severity** (see `SKILL.md`). Apply the subset matching the proposal's **blast-radius tier** — depth scales with what the thing can do, so a read-only single-file skill does not earn the full trust battery.

Each row lists the **minimum input tier** at which it becomes assessable (Idea / Proposal / Draft Skill Package / Build-Ready). Below that tier the dimension is `insufficient-to-assess` (which may drive `NEEDS-MORE-DETAIL`), never a fabricated finding.

## A. Purpose & scope

| ID | Question | Min tier | Notes |
|---|---|---|---|
| `purpose.defined` | Is there a single, defensible purpose? | Idea | No defensible purpose → candidate `DO-NOT-BUILD`. |
| `purpose.non-goals` | Are non-goals stated, not just goals? | Proposal | Absent non-goals is a real gap, not polish. |
| `purpose.differentiation` | Does it overlap an existing skill (`audit`/`discover`/`repair`/`audit-repair`/built-ins)? | Proposal | Overlap without differentiation → High. |
| `scope.proportion` | Is scope matched to v1 (not the everything-bagel)? | Proposal | Over-broad scope → wrong-rubric risk; recommend deferral with reasons. |

## B. Runtime fit (LIVE-VERIFIED — never from memory)

Every row here must be `[RUNTIME-DOC]`, confirmed against official docs and/or the live tool surface **this run**. A claim you cannot re-verify is `[JUDGMENT]` and cannot, alone, block.

| ID | Question | Min tier | Notes |
|---|---|---|---|
| `runtime.artifact-type` | Is the artifact a real CC type (skill/plugin/agent/MCP/hook)? | Proposal | Reviewing a non-CC artifact → say so, scope out. |
| `runtime.frontmatter` | Are frontmatter fields real and correctly used (`description`, `when_to_use`, `allowed-tools`, `disallowed-tools`, invocation control)? | Draft | Verify field names live; do not assert from memory. |
| `runtime.desc-cap` | Does `description`+`when_to_use` survive the listing truncation, with triggers/disambiguation front-loaded? | Draft | Check the *property* (triggers survive), re-verify the current cap value live — do not hardcode an integer. |
| `runtime.layout` | Does the path/layout match how this repo's plugins actually ship (`plugins/<plugin>/skills/<name>/`, manifest placement, no `version`)? | Draft | A path resolving to nothing = placement never decided. |
| `runtime.load` | Will it actually LOAD (not just pass `validate`)? | Build-Ready | See `D. Load-time`. |

## C. Trust boundary, permissions & tool access — PER ARTIFACT TYPE

The restrict mechanic differs by type; a single generic "tool access" question gives wrong advice for three of the four. Pick the lane.

| ID | Lane | Verified mechanic to check |
|---|---|---|
| `trust.skill-tools` | **Skill** | `allowed-tools` only *pre-approves* (does NOT restrict); `disallowed-tools` *removes* from the pool but **clears on the user's next message** and **cannot name arbitrary MCP tools**. So a skill's read-only-ness rests on `disallowed-tools` + Plan Mode + prose guardrail together — never on `allowed-tools` alone. |
| `trust.agent-tools` | **Subagent** | A subagent's `tools:` list is a **hard allowlist** that genuinely restricts (e.g. `repo-explorer`: `Read, Grep, Glob, LS, WebFetch`). Telling an agent author their list "only pre-approves" is wrong. |
| `trust.mcp-naming` | **MCP** | MCP tools follow `mcp__<server>__<tool>` and **cannot** be placed in `disallowed-tools`; they are reached via discovery. Telling an MCP author to "add it to `disallowed-tools`" is impossible advice. |
| `trust.hook-layer` | **Hook** | Hooks are a separate **deterministic** layer (stdin-JSON), not a tool-pool concern; fail-closed posture and precise field extraction matter (cf. the Lazarus destructive-command guard). |
| `trust.least-priv` | All | Is the tool ask least-privilege for the stated purpose? Effecting tools (mutation/exec/network/delegation/scheduling) present without a stated need → High. |
| `trust.readonly-claim` | All | Does a "read-only" claim match the requested tools? A read-only claim is contradicted — an **auto-block** — by unscoped `Write`, `Edit`, `Bash`, or any tool that mutates the reviewed artifact or external state. A **single explicitly scoped review/report-artifact write** (e.g. `TOOL_DESIGN_REVIEW.md`, `PRESENTATION_AUDIT.md`) is **allowed** only if the artifact path, the approval gate, and the no-other-mutation boundary are all stated and tested (path named, written only after `ExitPlanMode`/ratify, and a file-inventory/`git` check proving nothing else changed). A scoped artifact write that names its path + gate + boundary is not a contradiction; an *unscoped* `Write` (could target any file) still is. |
| `trust.deny-completeness` | Skill | If it claims no-exec/no-network, does the deny list cover the live effecting surface (verified this run), with conditional tools classified (deny-if-present), not memorized? |

## D. Hidden execution, injection & load-time

| ID | Question | Min tier | Notes |
|---|---|---|---|
| `exec.dynamic-injection` | Any `!`-prefixed / dynamic-context command in the artifact source? | Draft | Verify whether the artifact type supports dynamic injection in the current release before flagging; keep a deterministic grep backstop for an actual executable fence. |
| `exec.untrusted-input` | Does it read untrusted content (READMEs, issues, web, MCP resources)? Is that content treated as DATA, not instructions? | Proposal | Unmitigated injection surface = **auto-block**. |
| `exec.credential` | Any credential/secret access path? | Draft | Any → High at least; justify or remove. |
| `load.real-install` | For loadable artifacts, does the plan verify via a **real local install** (marketplace add + install, observe `Status`), not just `validate`? | Build-Ready | `validate` passes things that fail to load (e.g. declaring `hooks` in `plugin.json` → "Duplicate hooks file detected"). Stopping at `validate` is itself a finding. |

## E. Output contract, evidence & convergence

| ID | Question | Min tier | Notes |
|---|---|---|---|
| `out.contract` | Is there a defined output contract downstream can consume? | Proposal | Unusable/under-specified output → High. |
| `out.artifact-home` | Does any written artifact have a defined, intentional home (not `cwd` root)? | Proposal | Inheriting the wrong "write to repo root" assumption is a real defect. |
| `out.forensic` | Are assessment artifacts versioned / never overwritten in place? | Proposal | Family invariant. |
| `evidence.model` | Does the design require evidence/citations for its own claims, with judgment labeled as judgment? | Proposal | A reviewer/auditor design with no evidence model is incomplete. |
| `converge.verdict` | If it is itself a gate/reviewer, does it emit a bounded verdict and converge? | Proposal | Productizing an open-ended reviewer reproduces the never-terminating loop. |

## F. Lifecycle, cost & discoverability

| ID | Question | Min tier | Notes |
|---|---|---|---|
| `life.drift` | Are platform-dependent claims pinned to a re-verifiable source with a re-check trigger (not a hardcoded snapshot that will rot)? | Proposal | The single most common slow-failure in skill design. |
| `cost.budget` | Model tier, subagent fan-out, context loaded per run, user latency — is the cost posture sane? | Proposal | Cost is a first-class value (e.g. `repo-explorer` pinned to Haiku). |
| `name.trigger` | Does the name/trigger collide with or poach a sibling (`audit`, `/review`, `/code-review`, `/security-review`)? Is the head-noun unambiguous? | Draft | Disambiguate explicitly, the way `audit` disambiguates from `discover`. |
| `invoke.who` | Is who-invokes (model-auto-gate vs user-invoked second opinion) decided and reflected in the trigger? | Proposal | The description IS the trigger; this choice dictates it. |

## Trigger / proportionality rules

- **State the blast-radius tier first**, then apply only the matching subset. `read-only/no-network` → A, B, E, F + `trust.least-priv`/`trust.readonly-claim`. `executes/network/MCP` or `schedules/external` → all sections, full C + D.
- **Novelty is not risk.** Never raise severity for unfamiliarity alone (`name.trigger`, `out.contract`, etc. judged on consequence, not convention).

## Dimensions considered and ruled NOT-APPLICABLE (named, not padded)

So "completeness" is not inflated with non-risks — weigh, then exclude with a reason:

- **Internationalization** — internal English-only dev tooling; N/A unless the proposal is user-facing multilingual.
- **Multi-tenant / permission-scoping** — single-user CLI; the only relevant "permission scoping" is the tool-access analysis in §C.
- **Observability / telemetry** — no runtime to instrument for a design; the nearest real concern is traceability that the built thing matched the approved design (covered by `out.forensic`).
- **Accessibility / i18n of the review output** — only "the report renders as clean CommonMark" applies (self-check).

If a reviewer adds one of these as a *finding*, that is itself a proportionality defect.
