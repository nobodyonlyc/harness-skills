---
name: workflow-team
description: Coordinate solo vs team development on a shared harness backlog — claim, branch, per-assignee WIP=1, PR integration gate, handoff, and features.json conflict resolution.
---

The backlog (`.harness/features.json`, git-tracked) is the coordination layer — not chat, not a
spreadsheet. This skill defines how **solo** and **team** runs differ; everything else (the phase
chain, gates) is shared with [workflow-feature](../workflow-feature/SKILL.md).

## Solo vs team

| | **solo** (default) | **team** |
|---|---|---|
| WIP | global WIP=1 | WIP=1 **per assignee** |
| Claim | none | `./harness start <id> --assignee <name> --branch` |
| Integration | checkpoint on current branch | feature branch → **PR review gate** → merge |
| Auto-advance | allowed (esp. Non-Technical) | off — each assignee holds one US |

Record the choice in the task-state `Collab:` field (set at `workflow-intake` Phase 0.7).

## Team loop (per developer)
1. **Pull first** — `git pull` before claiming, so `features.json` is current.
2. **Claim & start** — `./harness start <id> --assignee <you> --branch`; commit + push the
   `features.json` change immediately (claim is only real once pushed).
3. **Work** the standard phase chain on your branch (review + required tests + verify).
4. **Integrate** — open a PR; the review gate (`check-pr-review`) must pass before merge.
5. **Push status** — when `verify` marks the US `passing`, commit `features.json` and push so
   teammates see it on `git pull`.

## Handoff (mid-US)
`./harness session stop` writes `docs/session-handoff.md`. Commit it with `plan.md` + `evidence.md`
+ `features.json`. The incoming developer reads all three before `./harness start <id> --force`
(re-assign), then pushes immediately.

## Conflict rules
- **features.json merge conflict** (simultaneous claims): keep the **first committer's** claim
  (`git log --oneline .harness/features.json` decides); the loser claims a different US. Never
  force-push `features.json`.
- **Never start a US assigned to someone else** without explicit agreement; document agreement in
  the commit message before `--force`.
- Blocked on a teammate's US → `./harness block <your-id> --reason "..."`, notify them, do not silently take over.

## Cross-cutting
Persona, step-gate, and token-budget apply identically to solo and team
([../../resources/persona-mode.md](../../resources/persona-mode.md),
[../../resources/step-gate.md](../../resources/step-gate.md)). Branch naming and state-merge follow
`../../resources/conventions/` (branch-convention / state-merge-convention) when present.
