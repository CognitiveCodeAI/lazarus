# Scaffolds — community-health file templates

Neutral starting points for the files `gitalive` most often finds missing. Every `«ASK-USER: …»` placeholder MUST be resolved via `AskUserQuestion` before the file is written — **a file is never written with a placeholder still in it.** Adapt tone and detail to the repo (read the README first); these are floors, not ceilings.

## CONTRIBUTING.md

Must actually explain dev setup, tests, and the PR process (presence alone fails `community.contributing`).

```markdown
# Contributing

Thanks for your interest in contributing!

## Dev setup
«ASK-USER: install/build commands — or derive them from the README/manifest and confirm»

## Running tests
«ASK-USER: test command — or derive from the manifest and confirm; if the project has no tests, say so honestly»

## Submitting changes
1. Fork the repo and create a branch from `main`.
2. Make your change; keep it focused.
3. «ASK-USER: any required checks (lint/typecheck) before a PR?»
4. Open a pull request describing what and why.

## Reporting bugs
Open an issue with reproduction steps, expected vs. actual behavior, and your environment.
```

## CODE_OF_CONDUCT.md

Recommend the **Contributor Covenant** (the de-facto standard GitHub's community profile recognizes) — but adopting a code of conduct is the maintainer's call, and it names an enforcement contact:

- Confirm: «ASK-USER: adopt Contributor Covenant v2.1? And what enforcement contact (email) should it name?»
- On yes: write the standard Contributor Covenant v2.1 text with the provided contact. On no: offer the waiver path (`community.code-of-conduct` in `.lazarus/gitalive-waivers.yml`) instead of a half-hearted custom CoC.

## SECURITY.md

```markdown
# Security Policy

## Reporting a vulnerability

Please do not open a public issue for security problems.
Report privately to «ASK-USER: security contact — email, or the repo's GitHub private
vulnerability-reporting link» and include steps to reproduce.

You should receive a response within «ASK-USER: response-time commitment, e.g. 7 days —
only promise what will actually be honored».

## Supported versions
«ASK-USER: which versions/branches receive security fixes? For a rolling main-only
project: "The latest release / main branch."»
```

## Issue templates (`.github/ISSUE_TEMPLATE/`)

`bug_report.md`:

```markdown
---
name: Bug report
about: Something doesn't work
---

**What happened**

**What you expected**

**Steps to reproduce**

**Environment** («ASK-USER: the env facts this project actually needs — OS? runtime version? tool version?»)
```

`feature_request.md`:

```markdown
---
name: Feature request
about: Suggest an idea
---

**The problem you're trying to solve**

**Your proposed solution**

**Alternatives you've considered**
```

## PULL_REQUEST_TEMPLATE.md

```markdown
## What does this PR do?

## Why?

## How was it tested?

«ASK-USER: any project-specific checklist items (docs updated? changelog entry?)»
```

## SUPPORT.md (optional — only when a finding asks for it)

```markdown
# Support

- **Questions / help:** «ASK-USER: where? Discussions, issues, a chat server?»
- **Bugs:** open an issue with reproduction steps.
- **Security problems:** see [SECURITY.md](./SECURITY.md) — never a public issue.
```

## LICENSE — special case, not a template

Adding a license is a **legal decision**. Never paste one in unprompted:

1. Gather evidence (manifest `license` fields, README claims) and present it.
2. «ASK-USER: which license? (evidence suggests X)» — the user's explicit choice is required.
3. On answer: write the standard, unmodified text of the chosen license (e.g. MIT with «ASK-USER: copyright holder + year»). Standard license texts are fixed legal instruments — never paraphrase or edit them.
```
