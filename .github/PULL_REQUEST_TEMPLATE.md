<!-- Thanks for contributing to Lazarus! 🧟 -->

**What does this change?**
A short summary.

**Why?**
The motivation / linked issue (e.g. "Closes #12").

**How did you test it?**
- [ ] `claude plugin validate ./plugins/lazarus` and `claude plugin validate .` pass
- [ ] Ran a real install (`claude plugin marketplace add ./.` + `claude plugin install lazarus@cognitivecode`) → `✔ enabled`
- [ ] If I touched the guard: piped destructive + benign payloads through `check-destructive.sh` (exit 2 / exit 0) and added a CI test case
- [ ] `scripts/check-destructive.sh` is still executable (git mode `100755`)

**Notes for reviewers**
Anything worth calling out.
