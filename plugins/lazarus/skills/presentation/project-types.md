# Project-type detection + overlays

A Claude Code plugin, a Python library, a Node CLI, and a Node library have materially different README and badge conventions. **Applying the wrong rubric is itself a defect** — so detection comes first, runs on manifest signals only, and stops to ask when ambiguous.

## Detection precedence (first match wins)

| Order | Signal (via `Glob`/`Read` only) | Detected type |
|---|---|---|
| 1 | `.claude-plugin/` containing `plugin.json` or `marketplace.json` | **Claude Code plugin** |
| 2 | `pyproject.toml` or `setup.py` | **Python library / tool** |
| 3 | `package.json` **with** a `bin` field | **Node CLI** |
| 4 | `package.json` **without** a `bin` field | **Node library** |
| 5 | none of the above | **Generic / unknown** (fallback) |

**Ambiguity rule (hard stop).** If signals for *more than one* type are present (e.g. both `pyproject.toml` and `package.json`), do **not** silently pick by precedence. Tag the detection `[INFERRED]`, and confirm the primary type with the user (`AskUserQuestion`) **before applying any overlay**. The detected type, the evidence for it, and its confidence are the first line of the audit.

**Fallback honesty.** For Generic/unknown: apply the universal rubric only, and state plainly in section 2 of the report that no type was detected and exactly which signals were checked.

## Overlays

Each overlay *adds* type-specific expectations to the universal tier. Overlay findings carry `scope: type:<type>`.

### Claude Code plugin (`type:plugin`)

| ID | Standard | Baseline | Observable check |
|---|---|---|---|
| `plugin.install-block` | CC-SKILLS | Critical | Install instructions use `/plugin marketplace add` + `/plugin install` (NOT `npm install`/`pip install`), and mention activation (`/reload-plugins` or restart). |
| `plugin.command-list` | CC-SKILLS | High | README lists the skills/commands the plugin provides, with their namespaced invocations (`/<plugin>:<skill>`). |
| `plugin.demo-asset` | README-RESEARCH | Low | A demo (screenshot, GIF, or animated terminal) shows the plugin working. |
| `plugin.manifest-parity` | CC-SKILLS | Medium | `plugin.json` description ≈ `marketplace.json` entry ≈ README one-liner — one product, one story. |

### Python library / tool (`type:python`)

| ID | Standard | Baseline | Observable check |
|---|---|---|---|
| `python.install` | README-RESEARCH | Critical | `pip install <package>` (or uv/poetry equivalent) matching the name in `pyproject.toml`. |
| `python.import-usage` | README-RESEARCH | High | A fenced Python block showing import + minimal use. |
| `python.badges` | README-RESEARCH | Medium | PyPI version + supported-Python-versions badges (when published); CI badge when CI exists. |
| `python.version-range` | README-RESEARCH | Medium | Supported Python range stated and consistent with `requires-python`. |

### Node CLI (`type:node-cli`)

| ID | Standard | Baseline | Observable check |
|---|---|---|---|
| `node-cli.install` | README-RESEARCH | Critical | `npm i -g <package>` (or `npx <package>`) matching `package.json` `name`. |
| `node-cli.invocation` | README-RESEARCH | High | A fenced block showing the actual command invocation (the `bin` name) with typical flags. |
| `node-cli.badges` | README-RESEARCH | Medium | npm version + downloads badges (when published); CI badge when CI exists. |
| `node-cli.node-range` | README-RESEARCH | Medium | Supported Node range stated and consistent with `engines`. |

### Node library (`type:node-lib`)

| ID | Standard | Baseline | Observable check |
|---|---|---|---|
| `node-lib.install` | README-RESEARCH | Critical | `npm install <package>` matching `package.json` `name`. |
| `node-lib.import-usage` | README-RESEARCH | High | A fenced block showing `import`/`require` + minimal API use. |
| `node-lib.api-section` | README-RESEARCH | Medium | An API/reference section (or a link to one) for the exported surface. |
| `node-lib.esm-types` | README-RESEARCH | Low | Optional: ESM/CJS support and TypeScript-types note. |

## Deferred types (v0.2+ — named, not silent)

SaaS/web-frontend, Go, Rust, Docker image, GitHub Action, and monorepo-multi-type each need their own overlay and carry weaker or more divergent detection signals. Until the four-type engine is proven, they fall to **Generic/unknown** — universal rubric only, fallback stated honestly. Never improvise an overlay for an unsupported type.
