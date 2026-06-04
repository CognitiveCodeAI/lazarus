# Security Policy

Lazarus is a Claude Code plugin whose whole point is to make working in an unfamiliar
codebase **safer** — so we take security reports seriously.

## Supported versions

Lazarus is distributed as a plugin versioned by git commit (the latest `main` is the
supported version). Fixes land on `main`; update with `/plugin update lazarus@cognitivecode`.

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Use GitHub's **private vulnerability reporting**:
**[Open a private report »](https://github.com/CognitiveCodeAI/lazarus/security/advisories/new)**
(Security tab → "Report a vulnerability".)

If that's unavailable, email **larry@cognitivecode.ai** with subject `Lazarus security`.

Please include: what you found, steps to reproduce, and the impact you expect. We aim to
acknowledge within a few days and will keep you updated as we work on a fix.

## What's especially in scope

- **The destructive-command guard** (`plugins/lazarus/scripts/check-destructive.sh`) —
  any input that should be blocked but isn't (a bypass), or any way to make the hook
  fail *open* (allow when it should deny). The guard is designed to **fail closed**; a
  case where it fails open is the highest-severity report.
- The plugin manifest/hook wiring causing unintended command execution.

## Out of scope

- Actions you explicitly run yourself outside Claude Code.
- The behavior of a *target* repository that Lazarus is pointed at.
