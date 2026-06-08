# `TOOL_DESIGN_REVIEW.md` template (locked section order — verdict FIRST)

Round-stamp the file (`TOOL_DESIGN_REVIEW.r1.md`, `r2`, …) or keep append-only round sections; never overwrite a prior round. Co-locate with the proposal (or `docs/`), or deliver in-chat.

```markdown
# Tool Design Review — <proposal name> — round <N>

## Verdict
**<BUILD | BUILD-WITH-CHANGES | DO-NOT-BUILD | NEEDS-MORE-DETAIL>**
One-paragraph reason. Convergence: Blocking items: <N> (was <M> last round).
This verdict is advisory input to a human ratifier; a human may override it.

## Input classification
- Input tier: <Idea | Proposal | Draft Skill Package | Build-Ready Package> — [ARTIFACT] evidence
- Blast-radius tier: <read-only/no-network | writes-files | executes/network/MCP | schedules/external> — evidence
- Rubric subset applied (and why this depth)

## Required changes (ONLY for BUILD-WITH-CHANGES — closed, numbered, re-checkable)
1. <id> — <change> — severity — evidence class — how to verify it's resolved
2. ...
(Nothing outside this list blocks. On re-review only these + genuine new material-safety issues are in scope.)

## Findings
Grouped by severity (Critical → Low). Each:
- **<stable-id>** · severity · evidence class([ARTIFACT]/[RUNTIME-DOC]/[HOUSE-RULE]/[STANDARD]/[JUDGMENT])
- What (quote/measure from the proposal)
- Why it matters (consequence if shipped)
- Recommended fix
- Blocking? (yes/no — no Critical/High may rest on [JUDGMENT] alone)

## Non-blocking notes (do NOT gate)
Medium/Low observations and optional improvements. Explicitly excluded from the verdict.

## Runtime verification log
Every platform claim made above, with how it was verified THIS run (doc URL fetched / live tool surface enumerated / observed), and any conditional tools classified (Windows-only, MCP-gated, …).

## Missing artifacts (ONLY for NEEDS-MORE-DETAIL)
The exact artifacts required to reach a reviewable tier — purpose, non-goals, trust boundary, tool ask, output contract, trigger — so the author can resubmit. No critique of an invented design.

## Self-check
The SKILL.md self-check gate, each line asserted pass before this report was emitted.
```

Notes:
- **Verdict is the first H2** — a reader sees the disposition before any prose.
- For `NEEDS-MORE-DETAIL`, the **Findings** section is omitted entirely; the report is the verdict + the missing-artifacts list. Do not pad it with speculative findings.
- For `BUILD`, the **Required changes** section is omitted; only **Non-blocking notes** appear.
- Keep it proportionate — a clean read-only one-liner gets a short report, not a 12-section teardown.
