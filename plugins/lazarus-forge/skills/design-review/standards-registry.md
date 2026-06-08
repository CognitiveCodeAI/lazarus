# Standards Registry

Citation keys the rubric and findings draw on. Split into **HARD** (verifiable; mandatory citation) and **SOFT** (design heuristics; labeled reasoning, **never** dressed as a citation). The whole point: "cite a standard, not an opinion" stays honest where standards exist, and "show your reasoning" stays honest where they don't — because this domain has *few* hard external standards and many judgment calls.

**Last verified against live runtime + official docs: 2026-06-07.** This file is a *dated cache*, not an oracle (see Live-verification contract). Re-verify when this skill's contract changes.

## HARD standards (mandatory citation; re-verified live at review time)

| Key | Source | Used for | Verify by |
|---|---|---|---|
| `CC-SKILLS` | Official Claude Code skills/plugins docs | frontmatter fields, `description`+`when_to_use` listing truncation, progressive disclosure, invocation control | `WebFetch` the skills docs THIS run |
| `CC-TOOLS` | Official Claude Code tools reference + **live tool surface** | which tools exist, names, `allowed-tools` vs `disallowed-tools` semantics, conditional tools | `WebFetch` docs **and** enumerate the live surface (`ToolSearch`) THIS run |
| `CC-PLANMODE` | Official Plan Mode / permission-mode docs | read-only enforcement semantics (a structural tool-level guarantee the skill verifies but cannot itself turn on) | `WebFetch` docs THIS run |
| `CC-PLUGINS` | Official plugin/marketplace docs | layout (`plugins/<plugin>/skills/<name>/`, manifest placement, version-less convention), load-time gotchas | `WebFetch` + this repo's `CLAUDE.md` |
| `LZ-INVARIANTS` | This repo's `CLAUDE.md` + skill bodies | Plan-Mode read-only, confidence tags, ratify-before-action, forensic artifact separation, the destructive-command guard | quote the repo file |
| `MD-COMMONMARK` | CommonMark spec | the review report must render clean | named spec |

Any `[RUNTIME-DOC]` finding must name how it was verified **this run**. A platform claim that could not be re-verified is downgraded to `[JUDGMENT]` and may not, alone, block.

## SOFT heuristics (labeled reasoning — NEVER formatted as a citation)

These are principal-engineering judgment, not external standards. Present them as **explicitly-reasoned argument with the trade-off named**, tagged `[JUDGMENT]`. Do not manufacture a fake citation for them.

- **Least privilege** — request the narrowest tool/permission set for the stated purpose.
- **Fail-closed** — when a guard can't decide, deny (cf. the Lazarus destructive-command hook).
- **Trust-boundary minimization** — shrink the effecting/network/delegation surface; keep only what the purpose needs (and document why anything network-bearing is retained, so a later "purity" pass can't strip a needed capability).
- **Single responsibility / non-overlap** — one defensible job; don't poach a sibling's trigger.
- **Convergence over perfection** — a gate must terminate; bound the blocking set and re-review.
- **Proportionality** — review depth (and the reviewed thing's own machinery) scales to blast radius.
- **Evidence over taste** — predictions are judgment until proven; name the build-time test instead of asserting the outcome.

## Conditional-tool classification (the rule that replaces "drop it from memory")

A tool absent from *one* session's surface is **not** automatically nonexistent — it may be runtime-conditional. Classify, do not delete:

| Class | Examples | Behavior in a deny-list review |
|---|---|---|
| **Always-present** | `Bash`, `Edit`, `Write`, `Read`, `Skill`, `ToolSearch` | must be covered if effecting |
| **OS-conditional** | `PowerShell` (Windows) | deny-if-present; note the OS gate; absence ≠ fiction |
| **MCP-gated** | the MCP resource/`*Mcp*` tools | appear only with MCP servers configured; deny-if-present, classify |
| **Feature/enterprise-gated** | team/onboarding/share tools | gated by product surface; classify by availability, don't assert |
| **Deferred** | tools surfaced on demand in a session | enumerate via `ToolSearch`; present-but-latent, not absent |

When reviewing a proposal's deny list, the finding is **"verify this against the live surface + docs and classify conditional tools,"** never **"these tools don't exist."** (This rule exists because a draft deny list once named conditional tools as if absolute — the failure this skill must not reproduce.)

## Live-verification contract (for THIS skill's own maintenance)

- Store **no** inline tool list, char cap, or field name as ground truth in the rubric prose — reference the live docs/surface by pointer.
- Carry a **last-verified date** (top of this file) and re-verify on material contract change.
- This skill's own `disallowed-tools` (in `SKILL.md`) is subject to the same rule: it was verified 2026-06-07 with conditional tools included as deny-if-present; it is re-verified, not re-memorized, when the contract changes.
