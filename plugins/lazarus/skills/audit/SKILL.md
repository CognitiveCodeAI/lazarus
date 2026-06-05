---
name: audit
description: Principal-engineer-grade audit of any codebase for ownership, modernization, or refactor-vs-replace decisions — useful on legacy systems, freshly inherited services, open-source projects, and healthy code you simply want a senior read on. Produces a strategic 12-section report covering architecture, risks, dependencies, testing, security, reliability, frontend/accessibility, and a phased modernization plan. Use this skill whenever the user wants to audit a codebase, do a principal engineer review, assess whether a codebase is safe to maintain or worth replacing, decide between refactor and rewrite, evaluate a system for ownership, or produce a strategic technical review. Trigger on phrases like "audit this codebase", "principal engineer review", "is this safe to maintain", "should we rewrite or refactor", "ownership assessment", "modernization plan", or any request for a strategic codebase evaluation. This is DIFFERENT from discover — that skill scopes immediate blockers; this skill produces a long-term ownership view.
---

# Audit

This skill produces an ownership-grade audit. It is read-only, evidence-based, and prioritizes serious engineering risk over cosmetic concerns. The output is a strategic document that should help the user decide whether to maintain, refactor, modernize, or replace a system. It applies to any codebase — old or new, broken or healthy.

## When this skill applies

Use this skill when the user's question is **strategic**, not tactical:

- "I just inherited this — should I own it?"
- "Is it worth modernizing or should we rewrite?"
- "What's the actual risk profile here?"
- "Help me make a refactor-vs-replace recommendation"

If the user just wants the app to run locally, use `discover` followed by `repair` instead. This skill is the wrong tool for that.

## Workflow

### 1. Enter Plan Mode

This skill is read-only. Confirm Plan Mode is active and do all investigation inside it — no edits, no state-changing commands. Plan Mode blocks writes too, so the audit document cannot be created while still in Plan Mode: do the analysis read-only, present a short plan via `ExitPlanMode`, and write `CODEBASE_AUDIT.md` (and optionally a `CLAUDE.draft.md`) only *after* the user approves and you have left Plan Mode. Those two output files are the *only* writes this skill ever makes — it never edits the codebase under audit.

One consequence to respect honestly: while read-only you **cannot run the test suite or the build**. If a finding or recommendation leans on whether tests pass or the build is green, see step 4 — you must either get the user to authorize running them, or tag the claim as not-executed and not treat it as load-bearing.

### 2. Scope detection first

Before any deep inspection:

- Measure the repo: file count, language breakdown, depth
- Identify monorepo workspaces if any
- For repos under ~500 files: produce the full 12-section audit
- For repos over ~500 files: produce an inspection plan first, identify the top 10 highest-risk areas, then audit those. Tell the user the audit is prioritized, not exhaustive.
- For monorepos: produce one audit per workspace, or one overall plus per-workspace appendices

### 3. Use the Explore Subagent

For any repo over ~200 files, explicitly request the Explore Subagent for codebase mapping. For repos over ~2000 files, use the custom `repo-explorer` subagent that ships with this toolkit (invoked by name; Haiku-tier cost and a strict read-only tool allowlist).

### 4. Apply confidence tags

Every claim in the audit carries a tag:

- `[VERIFIED]` — **re-observed in tool output during THIS audit pass.** Not "I'm confident," not "a prior audit said so." If you did not see it with your own tool call this run, it is not `[VERIFIED]`.
- `[INFERRED]` — strong evidence from one source
- `[ASSUMED]` — best guess from context

Three failure modes this tagging exists to prevent — guard against all of them:

- **Carried-forward inflation.** If you are revising or building on an earlier audit, anything copied from its text is `[INFERRED]` at best (the earlier audit is one source) until you re-observe it this pass. Tagging carried-over prose `[VERIFIED]` is the single worst integrity error this skill can make — it launders an old guess into a fresh fact.
- **Coverage claims you didn't execute.** "Tests protect the critical path" / "the build is green" / "the happy-path e2e passes" are `[VERIFIED]` only if you actually ran them this pass. Read-only Plan Mode cannot run anything (step 1), so by default these are `[INFERRED — tests exist and read like they cover X, not executed]`. If your refactor-vs-replace recommendation in §1 leans on test coverage as a reason *not* to rewrite, that's load-bearing: either ask the user to authorize stepping out of read-only to run the suite/build and record the real result, or state plainly in §7 and §1 that the coverage claim is unverified and weight it accordingly. Do not let an unrun test suite silently support a "don't rewrite" call.
- **Grep counts presented as precise.** Numbers from `grep`/`rg` (e.g. "72 uses of `any`, down 42%") are heuristic — a `:\s*any` pattern misses `as any`, `any[]`, `Record<string, any>`. Tag them `[INFERRED]`, state the exact pattern used, and report direction ("materially fewer") rather than a load-bearing precise figure. Never compare a count to a prior audit's number unless you've confirmed both used the identical pattern.

For an audit specifically, separate **age** from **risk**. Old code is not bad code by default — only flag findings where there is concrete evidence of harm or upgrade-blocker risk.

### 5. Produce CODEBASE_AUDIT.md

Use exactly this 12-section structure. Lock the H2 names — downstream skills and prompts may reference them.

```markdown
# Principal Engineer Codebase Audit

## 1. Executive Summary
- What this codebase appears to do
- Overall health: Good / Mixed / Risky / Critical
- Maintain vs refactor vs replace recommendation, with one paragraph of reasoning
- Top 5 risks (one line each)
- Top 5 quick wins (one line each)

## 2. Repository Map
- Main directories with one-line purpose
- Important files (entry points, config, build, deploy, CI)
- Generated/vendor/legacy areas to deprioritize

## 3. Architecture Overview
- Main components
- Data/control flow
- External dependencies (databases, APIs, queues, caches, auth)
- Deployment model
- A simple text diagram if useful

## 4. Findings
Grouped by severity. For each finding:
- Title
- Severity: Critical / High / Medium / Low
- Evidence: file/function/module references
- Why it matters
- Suggested fix
- Risk of fixing: Low / Medium / High
- Confidence tag

Apply these lenses so the findings aren't skewed toward one layer — sweep correctness/logic, security, reliability, performance, AND, for any user-facing app, **frontend & accessibility**. For a UI the a11y/UX layer is not cosmetic: missing or sub-44px touch targets, missing ARIA labels and roles, insufficient color contrast, no keyboard navigation, hardcoded colors that defeat theming, and missing loading/error/empty states are real production defects — and for a tablet- or mobile-first app used in the field, a too-small tap target is an operational failure, not a nitpick. Weight these by how the app is actually used. If the repo has no UI, say so and skip the lens rather than padding.

If a severity bucket has more than 15 findings, group similar ones with a list of locations.

## 5. Security Review
Cover: secrets, auth/authz, input handling, dependency CVEs, logging/PII, file/network/database/command execution risks.

## 6. Reliability and Operations Review
Cover: failure modes, timeouts/retries, error handling, logging/observability, concurrency, deployment fragility.

## 7. Testing Assessment
Cover: what tests exist, what they actually protect, critical untested flows, refactor-safety gaps, the most valuable tests to add first. State explicitly whether you **ran** the suite this pass or only read it — "the tests exist and appear to cover X" is `[INFERRED]`, "the suite passed (N tests, 0 failures)" is `[VERIFIED]` and requires you to have actually executed it (see step 4). If the maintain-vs-rewrite call leans on coverage, this distinction is load-bearing.

## 8. Dependency and Build Assessment
Cover: package managers/lockfiles, outdated or risky dependencies, build reproducibility, runtime/version assumptions, upgrade blockers. Before classifying a dependency's risk, classify *where it runs*: production runtime, client/browser bundle, build-time only, or dev/test only — and trace it (import graph, bundler output, `dependencies` vs `devDependencies`), don't infer from the name. A "high-severity" dependency that only runs at build time or in tests is a different risk than one shipped to every user; calling something the "only prod-runtime high" is a claim you must trace, not assume.

## 9. Refactoring Opportunities
Split into: low-risk cleanup, medium-risk refactors, high-risk architectural changes. For each: what to change, why, files involved, prerequisites, test coverage needed first.

## 10. Modernization Plan
Phased:
- Phase 0: Stabilize and document
- Phase 1: Safety rails (tests, linting, types, CI, config validation)
- Phase 2: Refactor high-value areas
- Phase 3: Modernize architecture
Each phase: objectives, concrete tasks, expected impact, risk level, suggested order.

## 11. Top 10 Action Items
Ranked. For each: priority, **action** (a specific, stable title — downstream tools key on it), impact, effort (S/M/L), risk, files involved, and an **acceptance check** — a runnable command where one fits, otherwise a concrete observable assertion (e.g. signed token `exp` ≤ 24h). If an action is really an epic spanning many files/concerns, say so, so it can be split when turned into tickets.

## 12. Open Questions
Only questions that materially affect the audit. Do NOT ask generic questions.
```

### 6. Optionally propose a CLAUDE.md draft

If the repo has no CLAUDE.md, you MAY produce `CLAUDE.draft.md` at the root containing:

- Verified setup/build/test/run commands (only `[VERIFIED]` claims)
- Conventions inferred from the code (tagged)
- Do-not-touch list (destructive operations specific to this repo)

Mark it explicitly as a proposal. The user reviews and promotes to `CLAUDE.md` themselves. Do NOT write `CLAUDE.md` directly during the audit — that puts unreviewed guidance into durable form. (Research note: arxiv 2510.21413 found there is no established AGENTS.md/CLAUDE.md structure across OSS yet, with high variance in content. Anchor to OpenAI's commands-first example if asked for a template.)

## Anti-patterns to avoid

- Inventing architecture that isn't visible in the repo
- Assuming a dependency is used because it's listed in package files — confirm usage, and confirm *where* it runs (runtime vs build vs test) before rating its risk
- Tagging carried-forward or prior-audit prose `[VERIFIED]` — if you didn't re-observe it this pass, it's `[INFERRED]` at most
- Leaning a "don't rewrite" recommendation on test coverage you never ran — run it (with permission) or mark the claim unverified
- Skewing the findings to the backend — apply the frontend/accessibility lens on any user-facing app
- Headlining grep-derived counts as precise facts — they're directional `[INFERRED]` estimates; state the pattern
- Treating old code as bad by default — separate age from risk
- Recommending rewrite without evidence it's cheaper or safer than incremental modernization
- Generic advice like "add tests" — name the exact tests and flows
- Writing CLAUDE.md directly during audit — propose a draft, don't commit it
- Skipping confidence tags — the audit becomes load-bearing without a paper trail
- Producing a 30-page audit when a 5-page one would be more useful

## Research grounding

The four-dimension reliability framework (consistency, robustness, predictability, safety) from arxiv 2602.16666 underpins the severity classification. The separation of age from risk and the bias against rewrite recommendations come from empirical findings that "not-merged PRs tend to involve larger code changes, touch more files" (arxiv 2601.15195) — large rewrites have worse outcomes than incremental work, on average.
