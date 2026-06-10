# PRESENTATION_AUDIT.md — template and finding schema

The report uses exactly these H2 sections, in this order. The locked order keeps re-audits diffable and lets `presentation-repair` (the future apply skill) parse findings mechanically.

## The template

```markdown
# Presentation Audit

## 1. Scorecard
- **Project type:** <type> — <one-line evidence> — <[VERIFIED]|[INFERRED]>
- **Community profile:** ✅/❌ per file — README · LICENSE · CONTRIBUTING · CODE_OF_CONDUCT · SECURITY · issue templates · PR template
- **Per-category grade (file-based categories only):**
  | Category | Grade | Critical | High | Medium | Low |
  |---|---|---|---|---|---|
  | README | A–F | n | n | n | n |
  | Community files | A–F | n | n | n | n |
  | Markdown accessibility | A–F | n | n | n | n |

## 2. Project Type & Detection Evidence
<signals found, precedence applied, and — if detection was ambiguous — the confirmation that was asked and the user's answer>

## 3. Findings
<grouped by severity, Critical → Low; every entry is the full finding schema below>

## 4. Discoverability (settings) — out of core scope
Repo description, topics, social-preview, and homepage are GitHub settings audited by the
`lazarus-github` settings skill (they need `gh`). Install that companion for this coverage.

## 5. Waived Items
<each waived id + reason, carried from `.lazarus/presentation-waivers.yml`; "None." if empty>

## 6. Self-Check Gate Result
<the gate checklist from SKILL.md, each line asserted pass before this file was written>
```

Grades: **A** = no findings above Low · **B** = Mediums only · **C** = at least one High · **D/F** = Critical(s) present (F when the category's core artifact — README, LICENSE — is missing outright).

## Finding schema (every finding, no field optional)

```yaml
- id: community.license            # stable kebab key, == rubric row id
  severity: Critical               # Critical | High | Medium | Low (calibration below)
  evidence: "no LICENSE / LICENSE.md / COPYING at repo root (Glob); README says 'open source'"
  standard: GH-COMMUNITY           # citation key from rubric.md
  confidence: "[VERIFIED]"         # [VERIFIED] observed this run | [INFERRED] | [ASSUMED]
  recommended_fix: "Add an OSI-approved LICENSE (MIT matches plugin.json's `license: MIT`)."
  scope: universal                 # universal | type:<plugin|python|node-cli|node-lib>
  waived: false                    # true + reason if present in .lazarus/presentation-waivers.yml
```

A finding missing any field — most importantly missing `evidence` or `standard` — must not ship.

## Severity calibration (one worked example per level)

**Critical** — blocks use or legal reuse:
```yaml
- id: community.license
  severity: Critical
  evidence: "No LICENSE / LICENSE.md / COPYING at root (Glob); README claims 'open source'."
  standard: GH-COMMUNITY
  confidence: "[VERIFIED]"
  recommended_fix: "Add OSI-approved LICENSE; MIT matches plugin.json `license: MIT`."
  scope: universal
```

**High** — a first-time user can't get started, or the README renders wrong:
```yaml
- id: readme.usage
  severity: High
  evidence: "README has Install but no runnable usage/quick-start; first code fence is line 78, unlabeled."
  standard: README-RESEARCH
  confidence: "[VERIFIED]"
  recommended_fix: "Add a Quick Start with one copy-paste invocation for the detected type (plugin: marketplace add + install)."
  scope: type:plugin
```

**Medium** — real defect, not blocking; degrades trust or accessibility:
```yaml
- id: md.alt-text
  severity: Medium
  evidence: "3 of 4 images lack alt text: assets/banner2.png, assets/guard.png, assets/og-card.png (README L4, L31, L52)."
  standard: WCAG-MD
  confidence: "[VERIFIED]"
  recommended_fix: "Add descriptive alt text to each image; decorative-only may use empty alt=\"\"."
  scope: universal
```

**Low** — polish; safe to defer or waive:
```yaml
- id: readme.toc
  severity: Low
  evidence: "README is 240 lines with 11 H2s and no table of contents."
  standard: README-RESEARCH
  confidence: "[INFERRED]"
  recommended_fix: "Add a ToC after the intro for navigability; optional for READMEs under ~150 lines."
  scope: universal
```
