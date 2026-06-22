---
name: ship-commit-msg
description: Phase 9 commit message — write a Conventional Commit message from the staged diff. Mechanical, fast-tier.
---

Input: the staged diff. Output: a commit message.

## Format (Conventional Commits)
```
<type>(<scope>): <summary ≤ 72 chars>

<body: what changed and why, wrapped>
```
- `type`: feat, fix, refactor, test, docs, chore, perf, build, ci.
- Summary in imperative mood; no trailing period.
- Body explains **why** (the what is in the diff); reference the feature/US id.
- Append the project's required trailer (e.g. `Co-Authored-By:`) when configured.

## Rules
- One logical change per commit. Do not commit unrelated changes together.
- Never include secrets or large generated blobs.
- Tier: **fast** — this is mechanical (see [../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)).
