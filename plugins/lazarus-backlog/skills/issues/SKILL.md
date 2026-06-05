---
name: issues
description: Optional Lazarus companion — turn a CODEBASE_AUDIT.md "Top 10 Action Items" (§11) into GitHub Issues. Reads the audit produced by the Lazarus `audit` skill, proposes issues from the ranked action items (each carrying its acceptance check), splits items that are really epics into sub-issues, lets you ratify the set before anything is created, and dedups by a stable per-item key so re-running after a re-audit (which may re-rank items) never makes duplicates. Use when the user wants to turn an audit into a backlog, file the audit's action items as issues/tickets, or "create GitHub issues from the audit." GitHub Issues only — uses the gh CLI. REQUIRES a CODEBASE_AUDIT.md with a §11 section.
---

# Audit → GitHub Issues

This is an **optional companion** to the core Lazarus plugin, installed separately on purpose. It does the one outward-facing thing the core skills never do: it creates artifacts *outside* the repo — GitHub Issues. The core `discover` / `repair` / `audit` skills stay read-only or local-repair; this skill is opt-in by install so that outward-facing behavior (and any `gh` CLI failure modes) only ever reaches people who asked for it.

It turns the `## 11. Top 10 Action Items` section of a `CODEBASE_AUDIT.md` (produced by the `audit` skill) into GitHub Issues — each carrying the item's **acceptance check** (a runnable command, or the observable assertion the audit specified when no one-liner fits).

## Hard precondition

Two things must be true before this skill proposes anything. If either fails, **stop** and say exactly what to fix — never partially file issues.

1. **The audit exists.** A `CODEBASE_AUDIT.md` with a `## 11. Top 10 Action Items` section must be at the repo root. If not, tell the user to run the `audit` skill first (it produces the §11 this is built from) and offer to do that.
2. **GitHub is reachable.** `gh auth status` must succeed and `gh repo view` must resolve the current repo. If `gh` is missing, unauthenticated, or no repo is detected, stop and report the exact gap — do not create anything.

## Workflow

### 1. Parse §11 into structured items

Read `CODEBASE_AUDIT.md` and extract each Top 10 Action Item: rank/number, priority, action, impact, effort (S/M/L), risk, files involved, and its **acceptance check** (a runnable command, or an observable assertion). For each item derive a **stable dedup key** — a kebab-case slug of the action title (e.g. "Require JWT_SECRET; remove the 'superSecret' fallback" → `require-jwt-secret-remove-superSecret-fallback`). Key on the slug, **not the rank**: a re-audit can re-rank the same finding, and a rank-based key would then duplicate it or skip the wrong one.

If an action item is really an **epic** — it spans many files/routes/concerns, or the audit flagged it as one — plan to split it into sub-issues, each with its own acceptance check and its own slug (e.g. `<parent-slug>--<sub>`). You'll surface the split in step 3 for the user to accept or collapse.

Never invent a field the audit didn't provide; if an item has no acceptance check, carry it through as "no acceptance check specified."

### 2. Check for already-filed items (dedup — skip-if-exists)

Before proposing anything, find issues this skill created previously:

```
gh issue list --label lazarus-audit --state all --limit 200 --json number,title,body,url
```

Every issue this skill creates carries a hidden provenance marker in its body: `<!-- lazarus:audit-item:<slug> -->` (the stable slug from step 1, **not** the rank). Build the set of slugs that already have an issue. **v1 policy is skip-if-exists:** an item whose slug already has an issue is NOT recreated — report it as "already filed" with a link to the existing issue. Do not edit, reopen, or close existing issues; a human may have changed them.

### 3. Propose the set and ratify (the gate)

Present a table of what *would* be created — title (the action), priority/severity, effort, target labels — and which items are skipped as already-filed. For any item you split in step 1, show its proposed **sub-issues grouped under it**, so the user can accept the split or collapse it back into one issue. Ask the user to:

- choose which items (and sub-issues) to file (default: all not-yet-filed),
- accept or collapse any proposed splits,
- confirm or adjust labels and (optionally) a milestone,
- approve.

**Create nothing until the user approves.** This skill never files issues silently — the ratification gate is the whole point, exactly as in the core skills.

### 4. Create the approved issues

For each approved item, `gh issue create` with:

- **title:** the action, concise and imperative
- **body:** impact · risk · effort · files involved · the **acceptance check** under an explicit **"Acceptance check"** heading · a provenance footer: `From CODEBASE_AUDIT.md §11 ("<action title>"), generated <date>.` followed by the hidden marker `<!-- lazarus:audit-item:<slug> -->`
- **labels:** `lazarus-audit` plus one severity/priority label. If a needed label doesn't exist, create it only with the user's ok (`gh label create`).
- **milestone:** only if the user specified one.

Use the values from the audit verbatim; date the provenance footer with the real run date.

### 5. Report

List every created issue (number + URL) and every skipped item (with its existing-issue link). State plainly: this skill is **create-only** — it does not track or update issues after creation, so re-running picks up only newly-added §11 items.

## Anti-patterns to avoid

- Filing issues before the user ratifies the set — the gate is the point.
- Duplicating items on re-run — always check the `lazarus-audit` provenance markers first.
- Keying dedup on the §11 rank number — ranks shift between audits; key on the stable action slug so a re-audit doesn't duplicate or mis-skip a finding.
- Cramming a multi-part action item into one giant issue — propose a split when it's really an epic, each sub-issue with its own acceptance check.
- Editing, closing, or reopening existing issues — v1 is create-only; a human may have touched them.
- Inventing fields §11 didn't provide — carry "no acceptance check specified" rather than fabricating an acceptance check.
- Half-filing on a broken `gh` — verify auth + repo in the precondition; fail cleanly, never partially.
- Touching the codebase or the `CODEBASE_AUDIT.md` — this skill only *reads* the audit and *writes* issues; it changes nothing in the repo.

## Scope (what this is not)

A one-shot transform plus dedup — not a project-management integration, not two-way sync, not issue lifecycle tracking. Offer-to-update-existing and other trackers (Linear, Jira) are deliberately out of v1; they would arrive as their own sibling plugins with their own auth stories.
