# Role-based review + review provenance

This document records the mechanism that makes the Phase-6 review **enforceable** and **role-aware**.

## The problem
`harness verify` is trustworthy because it *executes* the test commands — exit code is evidence that
cannot be forged. Review had no equivalent: it produced only text in `evidence.md ## Review`, and the
textual gates (`review-gate`, `review-fix-gate`) only check that text exists / has no open `- [ ]`.
A model could self-review, write "No issues found", or skip review entirely and still pass. There
was also no notion of *who* reviewed — a Go backend change could be "reviewed" by a faceless agent
with no language expertise.

## The mechanism (two halves)

### 1. Role from the design (`scripts/role-resolver.sh`, `resources/phase-roles.md`)
Each phase maps to an **archetype** (design→architect, review→techlead, security→security-reviewer,
qa→qa-engineer); the **expertise** is resolved from the machine-readable Stack block by wrapping
`experts-resolver.sh`. So `--phase review` on a Go backend yields a *Go Backend Tech Lead* whose
prompt loads `dev-be → dev-go → golang-pro`. The role is a deterministic lookup over the design, not
a model's choice. Unresolved stack → a generic role (never blocks).

### 2. Provenance bound to the diff (`harness review`, `review-provenance-gate.sh`)
- `harness review open <id> --phase <p> --role '<spec>'` mints a one-time nonce, computes the current
  git diff-hash (`git diff HEAD`, hashed like `verification_hash`), and prints the role brief.
- The reviewer subagent (spawned with the role; **never the author**) does the review.
- `harness review record <id> --nonce <n> --verdict clean|findings --findings <N>` stamps provenance
  (verdict, findings, role, diff_hash) — the nonce is single-use.
- `harness review status <id> [--json]` reports `CURRENT` / `STALE` / `NONE` vs the working tree.
- `review-provenance-gate.sh` (PreToolUse) blocks `harness verify <id>` unless state is **CURRENT**:
  `NONE` = no review ran; `STALE` = the tree changed after the review (re-review required).
  `--override-snapshot` bypasses. Fail-open where the binary/subcommand is absent (never false-block).

This restores the test↔review symmetry: execution-as-evidence ↔ provenance-as-evidence.

| | Test | Review |
|---|---|---|
| Evidence | test exit code | provenance row bound to diff-hash |
| Who creates it | `harness verify` runs the cmd | `harness review record` (CLI) |
| Anti-stale | verification snapshot | diff-hash CURRENT/STALE |
| Gate | exit 0 | provenance CURRENT + no open `- [ ]` |

## Where each phase consumes it
`check-review-loop` is the keystone (resolve role → open → spawn → record → loop). `check-code-review`,
`check-security-review` (`--phase security`), `check-qa` (`--phase qa`) carry the role; all four
workflows (`workflow-bootstrap/feature/bugfix/team`) reference the role-based spawn.
`resources/agent-tool-mapping.md` documents the `spawn-subagents` role + provenance obligation.

On Claude Code, the `SubagentStop` hook `review-record-reminder.sh` nudges the agent to record
provenance after a reviewer subagent finishes (advisory; it cannot know the verdict, so it never
fabricates one).

## Honest limits
- A hook/skill can *name* the obligation and the gate can *enforce diff-bound provenance*, but
  neither can force a single agent that is determined to self-open + self-record to truly act as two
  independent parties. The nonce raises the cost and leaves a trail; **true** independence requires a
  deterministic orchestrator that spawns the reviewer itself — a future epic.
- The diff-hash is `git diff HEAD` (tracked changes only); brand-new untracked files are not in it.
- Enforcement is fail-open where the new `harness` binary is absent, to avoid breaking older setups.

## Implemented by
H-M2 (CLI, repo `harness`), F52 (role-resolver), F53 (gate), F54 (per-phase wiring), F55 (SubagentStop
reminder + tests + docs).
