---
name: legacy-repair
description: Repair phase for legacy or unfamiliar codebases. Consumes a ratified DISCOVERY.md and works through blockers until the Mechanical Definition of Done passes. Use this skill whenever the user wants to fix a legacy app, make a codebase run locally, stabilize a broken stack, work through the blockers identified by the legacy-discover skill, or execute against a ratified plan. Trigger on phrases like "fix this codebase", "make this run", "stabilize this app", "execute the repair plan", "work through the blockers", or any request to repair an app that has a DISCOVERY.md or a ratified plan. REQUIRES DISCOVERY.md to exist first — if it doesn't, run the legacy-discover skill instead.
---

# Legacy Repair

This skill executes against a ratified `DISCOVERY.md`. It is NOT a generic "fix the bug" skill — it requires upstream discovery to have produced a Mechanical Definition of Done, and it treats that DoD as the contract for completion.

## Hard precondition

`DISCOVERY.md` MUST exist at the repository root and contain a `## Proposed Mechanical Definition of Done` section. If it doesn't:

1. Stop. Do not proceed with repair.
2. Tell the user the legacy-discover skill must run first.
3. Offer to run it now.

This precondition exists because agent repair without an upstream contract has a documented failure mode: the agent silently redefines success as it goes (see arxiv 2604.04580 — "Beyond Fixed Tests").

## Workflow

### 1. Load and confirm the contract

Read `DISCOVERY.md`. State back to the user, in two or three sentences:

- What the app appears to do
- What the Mechanical Definition of Done requires
- Which blockers will be worked through

Ask the user to confirm before starting. If they need to amend the DoD, do that now — never silently mid-repair.

### 2. Recommend execution mode

- Small repair (under 10 blockers, ≤30 minutes estimated): Plan Mode → human approves → Auto-Accept for the bounded execution
- Large repair (10+ blockers, multi-hour, user is walking away): Plan Mode → human approves → Auto-Accept Mode and a checkpoint cadence
- Mixed: handle the small predictable items in Auto-Accept, pause for human review on anything that touches the DoD assertions

Make the recommendation explicitly. Do not silently switch modes.

### 3. Execute blockers in dependency order

Work through blockers from `DISCOVERY.md` in this order, regardless of how they were listed:

1. Environment/config issues (env vars, `.env.example`, paths)
2. Dependency/install issues (package manager, lockfile, version conflicts)
3. Build issues (compile, transpile, bundle)
4. Runtime startup issues (first failure on `<start cmd>`)
5. Test failures
6. Main-flow integration

After each fix, attempt the next step in the chain. If a fix doesn't work after two genuine attempts, mark the blocker `deferred-with-reason` and move on — don't grind.

### 4. Maintain VERIFICATION_REPORT.md

For every assertion in the DoD, log to `VERIFICATION_REPORT.md` at the repo root:

```markdown
# VERIFICATION_REPORT.md

## DoD: <install cmd> exits 0
- Command: `npm install`
- Run at: <timestamp>
- Exit code: 0
- stderr summary: <if any>
- Status: PASS

## DoD: <start cmd> runs for 30s without unhandled exception
- Command: `npm run dev`
- Observed: process stayed up, /health returned 200 at t+10s
- Status: PASS

## DoD: <smoke check>
- Assertion: POST /api/sessions → 201 with token; GET /api/me with that token → 200
- Result: PASS / FAIL with detail

## Blockers from DISCOVERY.md
1. [Title] — status: fixed | mitigated | deferred-with-reason — files changed: [list]
```

This file is the audit trail. Do NOT modify `DISCOVERY.md` in place — its purpose is to preserve what was believed before repair.

### 5. DoD amendment protocol

If during repair you discover the DoD was wrong — the smoke assertion was based on a misread of the code, the test command doesn't exist, the proposed acceptance criteria don't match real behavior — DO NOT silently rewrite it.

Propose an amendment to the user:

```
DoD AMENDMENT PROPOSED:
- Original: <quoted from DISCOVERY.md>
- Issue: <evidence that the original is wrong>
- Proposed change: <new assertion>
- Justification: <why this better reflects intended behavior>
```

Pause and wait for ratification. If the user is not available (autonomous run), mark the affected DoD item `blocked-pending-amendment` and continue with the rest.

### 6. Promote verified knowledge to CLAUDE.md

When a command, convention, or constraint is `[VERIFIED]` (actually executed and observed), it MAY be promoted to `CLAUDE.md` at the repository root. Examples worth promoting:

- "Test command: `pnpm test --filter web`" (verified to exit 0 on a green test)
- "Database migrations must run before `npm run dev`" (verified by observing the failure when skipped)
- "Do NOT run `prisma migrate reset` — this codebase has production-pointer fixtures"

Do NOT promote `[INFERRED]` or `[ASSUMED]` claims. CLAUDE.md should be verified-only by construction.

### 7. Stopping condition

Stop when EITHER:

- Every DoD assertion in `DISCOVERY.md` has status PASS, or `deferred-with-reason` documented in `VERIFICATION_REPORT.md`
- A blocker requires external dependency (credentials, third-party service, infrastructure) that you cannot create — stop and surface it

Do NOT stop because "the app feels working." The DoD is the contract.

### 8. Final summary

Produce `IMPLEMENTATION_SUMMARY.md` at repo root:

```markdown
# IMPLEMENTATION_SUMMARY.md

## What was broken
<concise list from DISCOVERY.md blockers>

## What changed
<files changed, grouped by reason>

## How to run it now
<exact commands>

## Validation performed
<DoD assertions checked, with results>

## Main behavior verified
<what now works end-to-end>

## Remaining blockers
<anything still blocked by external factors, with explicit reason>

## DoD amendments accepted
<list of amendments the user approved during repair>

## Follow-up work
<recommended next steps, separate from the functional repair>
```

## Anti-patterns to avoid

- Starting repair without DISCOVERY.md — the whole architecture collapses
- Modifying DISCOVERY.md in place — destroys the forensic record
- Silently rewriting the DoD when something doesn't match — propose, don't rewrite
- Treating "build passes" as success — agent PR research shows test failures, not build failures, are the dominant cause of bad repairs
- Promoting unverified claims to CLAUDE.md — pollutes durable guidance with assumptions
- Continuing to grind on a blocker after two genuine attempts — mark deferred and move on
- Removing business logic just because it looks old or doesn't match modern patterns

## Research grounding

The DoD amendment protocol comes from arxiv 2604.04580 — Li et al. argue repository-level repair is "fundamentally not optimization under fixed tests, but search over evolving behavioral constraints." The test-pass-not-just-build-pass requirement comes from arxiv 2602.00164 — Alam et al. found test failures and "prior resolution of the same issues by other PRs" are the dominant non-integration causes for fix-related agent PRs.
