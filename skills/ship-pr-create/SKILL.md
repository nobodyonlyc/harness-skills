---
name: ship-pr-create
description: Phase 9 pull request — open a PR with a clear summary, the test evidence, and a review checklist; the entry to the team integration gate.
---

Input: a feature branch ready for integration.

## Create the PR
- **Title**: the feature/US summary (Conventional-Commit style).
- **Body**:
  - What changed and why (link the US / feature id).
  - **Test evidence** — which test types ran (UT/IT/regression/e2e/perf/security) and their results,
    pulled from evidence `## Test`.
  - Migration / rollout notes; breaking changes called out.
  - 🤖 generation trailer if required by the project.
- Target the integration branch; ensure it is rebased and conflict-free.

## Gate
Opening the PR triggers [check-pr-review](../check-pr-review/SKILL.md) — the **team integration
gate**. Merge only after it passes. Do not self-merge where a second reviewer is required.
Use `gh` for GitHub operations.
