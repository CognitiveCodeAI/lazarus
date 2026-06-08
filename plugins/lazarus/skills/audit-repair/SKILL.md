---
name: audit-repair
description: Strategic repair phase — executes a ratified CODEBASE_AUDIT.md. Consumes the audit's §11 Top 10 Action Items (and any user-selected §10 Modernization Plan phases / §9 refactors), applies each change behind a ratify-before-action gate, and verifies it against that item's acceptance check until every selected item is PASS or deferred-with-reason. Use this skill when the user wants to execute or remediate the findings of a codebase audit, work the Top 10 action items, apply the modernization plan, or fix what the audit found. Trigger on "execute the audit", "fix the audit findings", "work the Top 10 action items", "remediate the audit", "apply the modernization plan". This is the strategic apply phase — the audit→audit-repair counterpart to discover→repair. It is NOT for making a broken app run (use repair, which consumes DISCOVERY.md), NOT the read-only audit itself (use audit), and NOT issue-filing (use lazarus-github:issues, which files §11 as GitHub Issues). REQUIRES a ratified CODEBASE_AUDIT.md with a "## 11. Top 10 Action Items" section — if it doesn't exist, run the audit skill first.
---

# Audit-Repair

This skill executes against a **ratified `CODEBASE_AUDIT.md`**. It is the strategic counterpart to `repair`: where `repair` consumes `DISCOVERY.md` and works blockers until the app *runs* (a Mechanical Definition of Done), `audit-repair` consumes the audit and executes its **findings** — security, reliability, refactoring, and modernization items — verifying each against its own acceptance check. It is an **apply** skill (it edits code and runs build/test commands); it is not read-only.

It is deliberately **per-finding, not monolithic**: it works one action item at a time through a ratify-then-act-then-verify loop, so it cannot sprawl across the whole audit or declare victory early.

## Hard precondition

A ratified `CODEBASE_AUDIT.md` MUST exist at the repository root and contain a `## 11. Top 10 Action Items` section (the audit's ranked, acceptance-checked work list). If it doesn't:

1. Stop. Do not proceed.
2. Tell the user the `audit` skill must run first (it produces the §11 this skill executes).
3. Offer to run it now.

This mirrors `repair`'s `DISCOVERY.md` precondition and `lazarus-github:issues`'s §11 precondition. The reason is the same documented failure mode: agent repair without a ratified upstream contract silently redefines success as it goes (arxiv 2604.04580 — "Beyond Fixed Tests"). The user-confirmed selection of §11 items + their acceptance checks **is** this skill's ratified contract — the strategic analog of `repair`'s DoD.

## Trust boundary (read before relying on the guard)

This skill mutates code (`Edit`/`Write`) and executes commands (`Bash`). Two honest facts about what protects against that:

- The core-`lazarus` **destructive-command guard fires on `Bash` only** (`hooks.json` matcher `"Bash"`). It backstops every command this skill runs and fails closed — but it does **not** fire on `Edit`/`Write`. So the **code-mutation** surface is *not* guarded by the hook.
- Mutation safety therefore rests on **ratify-before-action + Plan Mode + behavior-preservation** (tests green before and after — step 6), not on the guard. Do not over-credit the guard.

Acceptance-check commands are read from `CODEBASE_AUDIT.md` and run **as written**. Surface the literal command text at ratification (step 2) so the human approves what will actually execute.

## Workflow

### 1. Load and confirm the contract (the selection gate)

Read `CODEBASE_AUDIT.md`. State back to the user in a few sentences:

- What the audit found (overall health, top risks)
- Which items you propose to execute. **Default: all of §11 Top 10 Action Items.** The user may add §10 Modernization Plan phases or §9 refactoring opportunities, or pare the set down.
- For each selected item, its **acceptance check** (the runnable command or observable assertion the audit specified) and its **files involved**.

Ask the user to **ratify the selection** before any change. Never silently expand scope to items the user didn't select, and never invent findings beyond the audit.

For each selected item, derive a **stable kebab-case slug** from its §11 action title. The slug algorithm has **one canonical definition — `lazarus-github:issues`'s** (fully-lowercase slugify: lowercase the title, every run of non-alphanumerics → a single `-`, trim ends; e.g. `Require JWT_SECRET; remove the 'superSecret' fallback` → `require-jwt-secret-remove-supersecret-fallback`). Do **not** re-specify a divergent rule here: reference that canonical definition, because two skills independently describing "the exact algorithm" is how interop silently drifts (if `issues` changes its slugging, marker-matching breaks with no error). Treat slug-agreement as a build-time test — assert `audit-repair` and `issues` produce the identical slug for a sample §11 title — so drift fails loudly instead of silently. Key all status on this slug so an executed action lines up with a filed issue. **Issue interop is one-way and read-only:** you MAY read the hidden provenance marker `<!-- lazarus:audit-item:<slug> -->` that `issues` writes to detect an item was already filed and note it in the summary — you never write, update, or close an issue.

### 2. Recommend execution mode

- Small set (≤ ~5 items, low-risk, ≤30 min): Plan Mode → human approves → Auto-Accept for the bounded execution.
- Large or high-risk set (refactors, dependency upgrades, multi-hour): Plan Mode → human approves → Auto-Accept with a checkpoint cadence and a pause on any item that changes behavior.
- Mixed: handle predictable low-risk items in Auto-Accept; pause for human review on refactors and anything touching an acceptance assertion.

Make the recommendation explicitly; do not silently switch modes. **Before recommending Auto-Accept, surface the literal acceptance-check commands** that will run, so the human approves the actual command text (the `Bash`-only guard is the fail-closed backstop, not a substitute for that approval).

### 3. Execute in risk order (safety rails before refactors)

Work the selected items in the audit's **§10 Modernization Plan order**, not §11 rank order:

1. **Phase 0/1 — stabilize + safety rails first:** tests, linting, types, CI, config validation. These create the net everything else lands on.
2. **Phase 2 — refactor high-value areas** (only after the net exists).
3. **Phase 3 — architectural modernization.**

Within a phase, do lower-risk items first. This mirrors `repair`'s safety-before-risk ordering: never refactor on a codebase with no test coverage you just declined to add.

**Fallback for items with no §10 home:** not every selected §11 item necessarily appears in the §10 Modernization Plan. A selected item that has no phase position in §10 runs **after** the phased items, ordered low-risk-first by its §11 risk rating. Never leave a selected item without a defined execution position.

### 4. Execute one finding, then verify it — the per-finding loop

For each selected item, in order:

1. Apply the change to the files the audit named.
2. **Run its acceptance check and record the result** (step 5). The acceptance check is that item's Definition of Done.
3. Only when it passes (or is deferred) move to the next item. Do not batch unverified changes.

### 5. Maintain AUDIT_VERIFICATION_REPORT.md (namespaced)

For every selected item, log to **`AUDIT_VERIFICATION_REPORT.md`** at the repo root — deliberately prefixed so it never clobbers `repair`'s identically-purposed `VERIFICATION_REPORT.md` when both the tactical and strategic workflows run on the same repo (forensic-separation invariant):

```markdown
# AUDIT_VERIFICATION_REPORT.md

## <slug>: <action title>  (§11 #<rank>)
- Acceptance check: `<command>`  (or: <observable assertion the audit stated>)
- Files changed: [list]
- Run at: <timestamp>
- Result: <exit 0 / assertion observed>  — Status: PASS | mitigated | deferred-with-reason
- Confidence: [VERIFIED]  (only if executed + observed this run)
- Already filed as issue: <yes, via marker> | no
```

**`PASS` requires observed evidence, never a judgment call:**

- **Runnable-command acceptance check:** `PASS` = the command was executed this run and met its exit/assertion criterion → `[VERIFIED]`.
- **Assertion-only acceptance check** (the audit allows "a concrete observable assertion" where no one-liner fits): `PASS` requires the **relevant tests green before AND after**, **plus** the stated observable assertion explicitly checked and recorded. Never self-declare `PASS` on an unverified assertion — that re-introduces the silent success-redefinition this skill's precondition exists to prevent.
- **Selected §9/§10 items** carry no per-item acceptance check in the audit, so their completion contract is **behavior-preservation**: relevant tests green before and after, plus any observable assertion the audit stated for them.
- **Safety-rail items that *create* the test net** (e.g. "add tests for module X", "stand up CI") have a **bootstrapping exception**: there are no before-tests to diff against, so "tests green before and after" cannot apply to the very item whose deliverable *is* the net. Their acceptance is that the new tests/CI **exist, pass, and run under the build** (the item's own acceptance check), not a before/after comparison. Before/after behavior-preservation governs refactors made *on* an existing net — Phase 2/3 — not the Phase 0/1 items that build it.

Do NOT modify `CODEBASE_AUDIT.md` in place — it preserves what the audit believed before remediation.

### 6. Acceptance-check amendment protocol

If during execution you find an acceptance check is wrong — the command doesn't exist, the assertion misreads the code, the criterion doesn't match intended behavior — DO NOT silently rewrite it. Propose an amendment:

```
ACCEPTANCE-CHECK AMENDMENT PROPOSED:
- Item: <slug> — <action title>
- Original check: <quoted from CODEBASE_AUDIT.md §11>
- Issue: <evidence the original is wrong>
- Proposed check: <new command/assertion>
- Justification: <why this better reflects intended behavior>
```

Pause for ratification. In an autonomous run with no user available, mark the item `blocked-pending-amendment` and continue with the rest.

### 7. Preserve behavior; separate age from risk

- Run the relevant tests **before and after** any refactor; a refactor that changes observed behavior is a regression, not a remediation — revert or fix before moving on.
- **Never remove business logic just because it looks old** or doesn't match a modern pattern. The audit separates age from risk; so does this skill. Modernize structure, not behavior.

### 8. Two attempts, then defer

If an item's acceptance check doesn't pass after two genuine attempts, mark it `deferred-with-reason` in `AUDIT_VERIFICATION_REPORT.md` and move on — don't grind. Likewise, if an item requires something you cannot create (credentials, a third-party service, infrastructure), stop on that item and surface it.

### 9. Promote verified knowledge to CLAUDE.md

When a command, convention, or constraint is `[VERIFIED]` (actually executed and observed), it MAY be promoted to `CLAUDE.md` at the repo root (e.g. "Lint: `pnpm lint` — verified clean after the lint-rules item"). Do NOT promote `[INFERRED]`/`[ASSUMED]` claims; `CLAUDE.md` stays verified-only by construction.

### 10. Stopping condition

Stop when EITHER:

- Every selected item has status `PASS` or `deferred-with-reason` documented in `AUDIT_VERIFICATION_REPORT.md`, or
- A selected item requires an external dependency you cannot provide — stop and surface it.

Do NOT stop because "the codebase feels better." The ratified selection + acceptance checks are the contract.

### 11. Final summary

Produce **`AUDIT_IMPLEMENTATION_SUMMARY.md`** at repo root:

```markdown
# AUDIT_IMPLEMENTATION_SUMMARY.md

## Audit items executed
<selected items, by slug + rank, with final status>

## What changed
<files changed, grouped by action item>

## Validation performed
<per-item acceptance-check results, with PASS evidence>

## Behavior preservation
<tests run before/after refactors, with results>

## Remaining / deferred
<deferred-with-reason items and external blockers, each with explicit reason>

## Acceptance-check amendments accepted
<list of amendments the user approved>

## Already-filed issues detected
<items whose lazarus:audit-item marker was found, with note — never modified>

## Follow-up work
<recommended next steps beyond the ratified selection>
```

## Anti-patterns to avoid

- Running without a ratified `CODEBASE_AUDIT.md` §11 — the contract is the whole point; stop and run `audit` first.
- Modifying `CODEBASE_AUDIT.md` in place — destroys the forensic record.
- Writing `VERIFICATION_REPORT.md` / `IMPLEMENTATION_SUMMARY.md` (un-prefixed) — those are `repair`'s; use the `AUDIT_`-prefixed names so the two workflows never clobber each other.
- Declaring `PASS` on an assertion-only item without observed evidence — that is the silent success-redefinition the precondition guards against.
- Over-crediting the destructive-command guard — it covers `Bash`, not `Edit`/`Write`; mutation safety is ratify + Plan Mode + behavior-preservation.
- Refactoring before the safety rails exist — execute in Modernization-Plan order, nets first.
- Removing business logic because it looks old — separate age from risk; modernize structure, not behavior.
- Silently rewriting an acceptance check when it's wrong — propose an amendment, pause for ratification.
- Expanding scope to items the user didn't select, or inventing findings beyond the audit.
- Filing/closing/editing GitHub issues — interop is one-way, read-only (detect via the marker only); outward-facing writes stay in `lazarus-github:issues`.
- Grinding on one item past two genuine attempts — mark deferred and move on.

## Research grounding

The ratified-contract precondition and the acceptance-check amendment protocol come from arxiv 2604.04580 (Li et al.) — repository-level repair is "search over evolving behavioral constraints," not optimization under fixed tests; an upstream contract that the agent may amend (but not silently rewrite) is the documented mitigation. The behavior-preservation / tests-before-and-after requirement on refactors comes from arxiv 2602.00164 (Alam et al.) — test failures, not build failures, are the dominant non-integration cause of bad fix PRs. The separation of age from risk and the bias against rewrite carry over from the `audit` skill's grounding (arxiv 2601.15195 — large rewrites correlate with worse outcomes than incremental work).
