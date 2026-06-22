---
name: core-fix
description: Make a small, scoped fix without the full feature pipeline — typos, one-line bugs, config tweaks — still tested and lightly reviewed. Use when: a typo/one-line bug/config tweak that doesn't warrant the full feature pipeline, but still needs a test + light review.
---

## One-Liner
The fast lane for trivial fixes — skip the full pipeline but never skip the test + light review; if it grows, promote it to a feature or bugfix.

Fix: $ARGUMENTS

## Scope (important)
Use **only** for trivial, low-risk changes: a typo, a one-line bug, a config value, a doc fix. If the
change needs design, touches multiple components, or alters real behavior, it is **not** a core-fix —
route it to [workflow-feature](../workflow-feature/SKILL.md) or
[workflow-bugfix](../workflow-bugfix/SKILL.md) so it gets the full review + test + verify pipeline.

## Do
1. Make the minimal change.
2. Run the relevant existing tests (and add one if the fix is a behavior bug).
3. Self-review the diff (correctness + no scope creep).
4. Commit with a clear message (`ship-commit-msg`).

## Rule
core-fix is **not** a backdoor around the quality gates. When in doubt about size or risk, escalate
to a workflow. Never use it to slip an untested behavior change into the codebase.
