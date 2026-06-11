# assets

Images used by the project README and the repo's GitHub presentation.

| File | Used for | Referenced from |
|------|----------|-----------------|
| `banner2.jpg` | Hero image at the top of the README | `README.md` |
| `demo.svg`    | Animated "Watch it work" terminal | `README.md` |
| `guard.png`   | Inline image in the "makes it safe to run" section | `README.md` |
| `gitalive-before-after.jpg` | Before/after panel in the "GitAlive" spotlight section (generated with gpt-image-2) | `README.md` |
| `og-card.png` | Social-preview card (how the repo unfurls on Slack/X/etc.) | GitHub → repo **Settings → General → Social preview** (not referenced from `README.md`) |

**Updating an image.** Replace the file in place and keep the same name, so the README keeps
resolving it, then stage just that one file — e.g. `git add assets/banner2.jpg`. Avoid
`git add assets/*` / `git add -A`, which can sweep up local scratch files (`*.local-backup.*`,
which are git-ignored).

**Social preview.** Upload `og-card.png` under GitHub → repo **Settings → General → Social preview**
so the card shows when the repo is shared.
