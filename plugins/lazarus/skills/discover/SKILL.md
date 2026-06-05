---
name: discover
description: Read-only discovery phase for any unfamiliar codebase — legacy, freshly inherited, open-source you want to contribute to, or a healthy repo you simply don't know yet. Triages how the app is meant to run, what its intended behavior is, and what acceptance criteria would prove a repair is done. Use this skill whenever the user wants to onboard or get oriented in a repo, explore an unfamiliar codebase, understand how something is meant to work, scope an app, figure out why something won't start, identify blockers, or generate a ratifiable plan before any changes. Trigger on phrases like "explore this codebase", "help me get oriented", "I'm new to this repo", "onboard this repo", "what's preventing this from running", "make this run locally", "scope this app", or any request to investigate a codebase before changing it. This is the FIRST phase of repair work — always run this before the repair skill.
---

# Discover

This skill runs the read-only discovery phase that produces a ratifiable plan before any changes. It is designed for any repository where intended behavior must be inferred from the code itself rather than assumed — whether the code is old and broken, freshly inherited, open-source you're new to, or perfectly healthy but unfamiliar.

## When this skill applies

- The user wants to onboard or get oriented in an unfamiliar repo (broken or not)
- The user says the app won't run, won't build, or behaves unexpectedly
- The user wants a plan before any code changes
- The user is about to use the repair skill (this is its prerequisite)

If the user is asking for a long-term ownership review (modernization, refactor vs replace, architecture audit), use the `audit` skill instead.

## Workflow

### 1. Enter Plan Mode

Confirm you are in Plan Mode before starting. Plan Mode enforces read-only access at the tool level — no edits, no shell commands that modify state, no git operations. If the user has not entered Plan Mode, ask them to press Shift+Tab twice or type `/plan`, then proceed.

Note on the one write this skill makes: Plan Mode blocks writes too, so you cannot create `DISCOVERY.md` while still in Plan Mode. Do all investigation read-only, then present the plan via `ExitPlanMode`. The single file write in step 5 happens only *after* the user approves and you have left Plan Mode — it is not a license to make code edits, which remain out of scope for this skill.

### 2. Identify scope

Before reading any code, determine repository shape:

- Single project or monorepo (check for `pnpm-workspace.yaml`, `lerna.json`, `nx.json`, `turbo.json`, `workspaces` field in `package.json`, Cargo workspace, Go workspace)
- Primary languages and frameworks
- Whether a CLAUDE.md already exists at the root or in any workspace

For monorepos, ask the user which workspace is in scope before continuing. Do not try to discover all workspaces in one pass — that produces shallow output. Either pick one workspace with the user, or produce per-workspace DISCOVERY files.

### 3. Use the Explore Subagent for large repos

Plan Mode auto-activates the Explore Subagent for codebase research. For repos over ~200 files, explicitly request it: "Use the Explore Subagent to map the repository structure." The subagent runs in a separate context window and reports a summary, keeping the main session's context clean.

For very large repos (over ~2000 files), recommend the `repo-explorer` custom subagent that ships with this toolkit (invoked by name; Haiku-tier cost and a strict read-only tool allowlist).

### 4. Trace evidence, not assumptions

Every claim in DISCOVERY.md must carry a confidence tag:

- `[VERIFIED]` — observed in a tool call (file contents, command output that you can cite)
- `[INFERRED]` — strong evidence from one source (e.g., `package.json` has a `dev` script, so the dev command is `npm run dev`)
- `[ASSUMED]` — best guess from context, no direct evidence

Do NOT promote `[INFERRED]` or `[ASSUMED]` claims to `[VERIFIED]` until they're actually executed and observed during the repair phase.

### 5. Produce DISCOVERY.md

Write the output to `DISCOVERY.md` at the repository root. Use this structure:

```markdown
# DISCOVERY.md

## Repository shape
- Type: [single project | monorepo with N workspaces]
- Languages: [list]
- Frameworks: [list with versions]
- Workspace in scope: [if monorepo]

## Intended behavior (inferred)
[A few sentences. What does this app appear to do? Cite README, package description, route definitions, schema, or test names as evidence.]

## Setup commands
- Install: `<cmd>` [tag]
- Build: `<cmd>` [tag]
- Test: `<cmd>` [tag]
- Start: `<cmd>` [tag]
- Lint/typecheck: `<cmd>` [tag]

## Required environment
- [VAR_NAME]: [purpose] [tag]
- ...

## Blockers preventing local startup
1. [Title] — [evidence] — [tag] — [severity: critical/high/medium]
2. ...

## Proposed Mechanical Definition of Done
The repair phase is done when ALL of these check:
- [ ] `<install cmd>` exits 0
- [ ] `<build cmd>` exits 0
- [ ] `<test cmd>` passes (specify which subset is acceptable)
- [ ] `<start cmd>` runs for 30s without unhandled exception
- [ ] One end-to-end smoke check: <concrete assertion against this app>
- [ ] Each blocker above has status: fixed | mitigated | deferred-with-reason

## Out of scope
[What this discovery deliberately does NOT cover. Be honest.]

## Open questions for ratification
[Things the human must decide before repair starts. Be specific.]
```

Note on the smoke check for **hardware- or service-coupled apps**: if the one end-to-end assertion can't be run without something you can't supply — a physical device, a paid/external API, real credentials, a running database — say so explicitly. Make it a ratification Open Question and mark that DoD item `requires: <X>` instead of a plain checkbox. Never fake a smoke check or silently drop it; "this needs the camera / DB / API key to verify" is the correct, honest output, not a green check you didn't earn.

### 6. Stop for ratification

Do NOT proceed to repair. After writing DISCOVERY.md, present a short summary in chat and ask the user to:

1. Review the proposed Definition of Done — these are the mechanical checks that will determine when repair is complete
2. Confirm scope (especially for monorepos)
3. Resolve any open questions
4. Approve, modify, or reject

When the user approves, they should invoke the `repair` skill in a fresh prompt that references the ratified DISCOVERY.md.

## Anti-patterns to avoid

- Producing a "plan" that's actually a narrative with no commands. The DoD section must be runnable assertions.
- Skipping the confidence tags. Untagged claims become load-bearing fact three turns later.
- Auto-promoting `[INFERRED]` to `[VERIFIED]` without execution. That defeats the entire point.
- Trying to discover an entire monorepo in one pass. Pick a workspace.
- Recommending fixes during discovery. This phase is observation only.
- Continuing into repair without explicit user ratification.

## Research grounding

The verified/inferred/assumed split exists because long-running agent workflows convert assumptions into facts over time (see arxiv 2602.16666 — "Towards a Science of AI Agent Reliability"). The mechanical DoD requirement is from arxiv 2602.00164 — fix-related agent PRs fail most often at test cases catching the wrong fix, not at build/deploy.
