---
name: principal-audit
description: Principal-engineer-grade audit of a codebase for ownership, modernization, or refactor-vs-replace decisions. Produces a strategic 12-section report covering architecture, risks, dependencies, testing, security, reliability, and a phased modernization plan. Use this skill whenever the user wants to audit a codebase, do a principal engineer review, assess whether a codebase is safe to maintain or worth replacing, decide between refactor and rewrite, evaluate a legacy system for ownership, or produce a strategic technical review. Trigger on phrases like "audit this codebase", "principal engineer review", "is this safe to maintain", "should we rewrite or refactor", "ownership assessment", "modernization plan", or any request for a strategic codebase evaluation. This is DIFFERENT from legacy-discover — that skill scopes immediate blockers; this skill produces a long-term ownership view.
---

# Principal Engineer Audit

This skill produces an ownership-grade audit. It is read-only, evidence-based, and prioritizes serious engineering risk over cosmetic concerns. The output is a strategic document that should help the user decide whether to maintain, refactor, modernize, or replace a system.

## When this skill applies

Use this skill when the user's question is **strategic**, not tactical:

- "I just inherited this — should I own it?"
- "Is it worth modernizing or should we rewrite?"
- "What's the actual risk profile here?"
- "Help me make a refactor-vs-replace recommendation"

If the user just wants the app to run locally, use `legacy-discover` followed by `legacy-repair` instead. This skill is the wrong tool for that.

## Workflow

### 1. Enter Plan Mode

This skill is strictly read-only. Confirm Plan Mode is active. The only writes permitted are `CODEBASE_AUDIT.md` and (optionally) a proposed `CLAUDE.md` draft.

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

- `[VERIFIED]` — observed in tool output
- `[INFERRED]` — strong evidence from one source
- `[ASSUMED]` — best guess from context

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

If a severity bucket has more than 15 findings, group similar ones with a list of locations.

## 5. Security Review
Cover: secrets, auth/authz, input handling, dependency CVEs, logging/PII, file/network/database/command execution risks.

## 6. Reliability and Operations Review
Cover: failure modes, timeouts/retries, error handling, logging/observability, concurrency, deployment fragility.

## 7. Testing Assessment
Cover: what tests exist, what they actually protect, critical untested flows, refactor-safety gaps, the most valuable tests to add first.

## 8. Dependency and Build Assessment
Cover: package managers/lockfiles, outdated or risky dependencies, build reproducibility, runtime/version assumptions, upgrade blockers.

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
Ranked. For each: priority, action, impact, effort (S/M/L), risk, files involved, validation command.

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
- Assuming a dependency is used because it's listed in package files — confirm usage
- Treating old code as bad by default — separate age from risk
- Recommending rewrite without evidence it's cheaper or safer than incremental modernization
- Generic advice like "add tests" — name the exact tests and flows
- Writing CLAUDE.md directly during audit — propose a draft, don't commit it
- Skipping confidence tags — the audit becomes load-bearing without a paper trail
- Producing a 30-page audit when a 5-page one would be more useful

## Research grounding

The four-dimension reliability framework (consistency, robustness, predictability, safety) from arxiv 2602.16666 underpins the severity classification. The separation of age from risk and the bias against rewrite recommendations come from empirical findings that "not-merged PRs tend to involve larger code changes, touch more files" (arxiv 2601.15195) — large rewrites have worse outcomes than incremental work, on average.
