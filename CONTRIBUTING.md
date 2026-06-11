# Contributing to Lazarus

Thanks for helping raise dead codebases! 🧟 Issues, ideas, and PRs are all welcome.

## Ways to contribute

- **🐛 Found a bug?** Open an issue with the Bug Report template.
- **💡 Have an idea?** Open an issue with the Feature Request template, or start a [Discussion](https://github.com/CognitiveCodeAI/lazarus/discussions).
- **🛡️ Security issue?** Don't open a public issue — see [SECURITY.md](SECURITY.md).
- **🔧 Want to send a PR?** Read on.

## Repo layout

This repo **is** the plugin marketplace. It ships three plugins — the **core** plugin and two optional **siblings**:

```
plugins/lazarus/                 # core plugin
├── .claude-plugin/plugin.json   # manifest (NO version field — git SHA is the version)
├── skills/                      # discover, repair, audit, audit-repair, gitalive, gitalive-repair
├── agents/repo-explorer.md      # read-only Haiku exploration subagent
├── hooks/hooks.json             # wires the guard as a PreToolUse hook (auto-loaded)
└── scripts/check-destructive.sh # the destructive-command guard

plugins/lazarus-github/          # optional sibling — files an audit's Top 10 as GitHub Issues
├── .claude-plugin/plugin.json
└── skills/issues/SKILL.md

plugins/lazarus-forge/           # optional sibling — pre-build design review for new skills/plugins
├── .claude-plugin/plugin.json
└── skills/design-review/SKILL.md
```

**Sibling-plugin pattern.** Anything outward-facing (filing GitHub Issues, posting to Slack, Linear/Jira) ships as a separate opt-in plugin in this same marketplace — never bundled into core — so the core install stays zero-config and a `gh`/API failure can't reach anyone who didn't opt in. `lazarus-github` was the first sibling; `lazarus-forge` the second.

## Dev loop

1. Clone and edit under `plugins/lazarus/`.
2. **Validate:** `claude plugin validate ./plugins/lazarus` and `claude plugin validate .`
   (the only expected warning is "No version specified" — that's intentional).
3. **Test the guard** by piping a payload through it:
   ```bash
   echo '{"tool_name":"Bash","tool_input":{"command":"terraform destroy"}}' \
     | plugins/lazarus/scripts/check-destructive.sh   # should exit 2 (deny)
   echo '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' \
     | plugins/lazarus/scripts/check-destructive.sh   # should exit 0 (allow)
   ```
4. **Real install test** (catches load-time errors that `validate` misses):
   ```bash
   claude plugin marketplace add ./.    # from the repo root
   claude plugin install lazarus@cognitivecode
   claude plugin list                   # expect: Status ✔ enabled
   # cleanup:
   claude plugin uninstall lazarus@cognitivecode && claude plugin marketplace remove cognitivecode
   ```

CI runs the JSON checks, `shellcheck`, and the guard tests on every PR — run them locally first and you'll sail through.

## Gotchas (please respect these)

- **Keep the guard executable.** `scripts/check-destructive.sh` must stay `chmod +x` (git mode `100755`) or it won't run after a clone.
- **Don't declare `"hooks"` in `plugin.json`.** The standard `hooks/hooks.json` is auto-loaded; declaring it again causes "Duplicate hooks file detected" and the plugin fails to load (yet `validate` still passes — only a real install catches it).
- **A skill's directory name must match the `name:` in its `SKILL.md` frontmatter.**
- **Don't add a `version` field** unless you intend to bump it on every change — Lazarus uses the git SHA as the version so every push auto-updates for users.
- When extending the **guard's blocklist**, it's one regex (`PATTERN`) in `check-destructive.sh`. Add a matching test to `.github/workflows/ci.yml`.

## PRs

- Branch from `main`, keep changes focused, and describe what you changed and how you tested it (the PR template has a checklist).
- Be kind — see our [Code of Conduct](CODE_OF_CONDUCT.md).
