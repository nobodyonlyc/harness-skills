---
name: check-pr-review
description: Phase 6 PR review — review an integration pull request in team mode before merge, covering the full change set, tests, and migration safety. Use when: reviewing an integration PR in team mode, the pre-merge gate, evaluating a feature branch for merge, or checking migration/conflict safety across a full change set.
---

## One-Liner
The PR review is the team integration gate: judge the **whole** change set (not one task) —
dimensions, tests-in-CI, migration safety, features.json integrity, conflicts — and merge only
when every finding is resolved or accepted.

Input: a PR (team integration gate, see [workflow-team](../workflow-team/SKILL.md)).

## Review the whole change set
- All `check-code-review` dimensions, applied across the PR's full diff (not just one task).
- **Tests present** — the required test types per the frozen strategy are included and pass in CI.
- **Migration safety** — destructive/data-losing migrations are flagged (always-stop) and coordinated.
- **features.json** — claim/status changes are consistent; no accidental overwrite of a teammate's record.
- **Conflicts** — no unresolved merge markers; rebased on the integration branch.

```
PR review summary (mirror into evidence ## Review)
- [ ] <finding> (file:line, severity)     # blocks merge
- [x] <finding> — fixed in <sha> / (accepted: <reason>)
Verdict: APPROVE only when no - [ ] remains.
```

## Record
Post findings as PR comments (use `--comment` style) and mirror the summary into the feature's
evidence `## Review`. Approve only when findings are resolved or explicitly accepted.

## Gate
The PR review is the **team integration gate** — merge is blocked until it passes. Never self-approve
your own PR without a second reviewer where the team requires one.
