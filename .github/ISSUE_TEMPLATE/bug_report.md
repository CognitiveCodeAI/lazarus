---
name: 🐛 Bug report
about: Something in Lazarus didn't work as expected
title: "[bug] "
labels: bug
---

**What happened?**
A clear description of the bug.

**What did you expect?**
What you thought would happen instead.

**Steps to reproduce**
1. Pointed Lazarus at … (what kind of repo / stack)
2. Said / ran …
3. Saw …

**Which part?**
- [ ] `legacy-discover` (discovery)
- [ ] `legacy-repair` (repair)
- [ ] `principal-audit` (audit)
- [ ] the destructive-command guard (hook)
- [ ] install / update / `/plugin …`
- [ ] not sure

**Environment**
- OS: (macOS / Linux + version)
- Claude Code version: (`claude --version`)
- Lazarus version: (`claude plugin list` → the version/SHA)
- Available JSON parser(s): (any of `jq` / `python3` / `python` / `perl`)

**Logs / output**
Paste any relevant output (redact anything sensitive).
