# Skill Categories

Skills are stored **flat** — one directory per skill: `skills/<name>/SKILL.md`. Grouping is
encoded in the **name prefix**; this file is the index. Workflows are the entry points; they
orchestrate the leaf skills through the 9-phase lifecycle.

## Prefix → group

| Prefix | Group | Default model-tier |
|---|---|---|
| `workflow-` | Multi-agent orchestrators (entry points) | strong |
| `plan-` | Business analysis & task planning | strong |
| `design-` | System / data / API / UI design | strong |
| `dev-` | Implementation — by component (be/fe/cli/db/batch) and by language (js-ts/python/go/rust); a language skill composes with a component skill | strong |
| `check-` | Review & quality gates (check-review-loop: independent review + fix loop; check-security-review: deep security pass) | strong |
| `test-` | Test execution by type | strong (fast for pure runners) |
| `ship-` | Commit / PR / release / deploy | fast (release & deploy → strong) |
| `core-` | Everyday single-agent tasks | fast / strong |
| `opt-` | Token & cost optimization | fast |

## The 9-phase lifecycle (what a workflow drives)

| Phase | Skills | Notes |
|---|---|---|
| ① Business analysis | `plan-ba-analysis`, `plan-us-backlog` | persona-aware elicitation |
| ② System design | `design-architecture`, `design-database`, `design-api`, `design-detailed` | trade-offs surfaced to devs |
| ③ UI design | `design-ui`, `design-ux-flow` | generate-image, HTML/CSS fallback |
| ④ Plan tasks | `plan-tasks`, `plan-skeleton` | **freezes the per-task test-strategy** into immutable verifications |
| ⑤ Code | `dev-be`, `dev-fe`, `dev-cli`, `dev-db`, `dev-batch` | follow `resources/conventions/` |
| ⑥ Review | `check-code-review`, `check-pr-review`, `check-refactor` | hard gate → evidence `## Review` |
| ⑦ Test | `check-test-strategy` → `test-unit`, `test-integration`, `test-regression`, `test-e2e`, `test-performance`, `test-security` | strategy selects required types per system requirement |
| ⑧ Fix bug | `check-qa`, `workflow-bugfix` | reproduce → fix → re-verify loop to green |
| ⑨ Deploy | `ship-commit-msg`, `ship-pr-create`, `ship-release`, `ship-deploy` | deploy is an always-stop confirm |

Cross-cutting: `workflow-intake` (classify request, set persona/mode/collab), `workflow-team`
(solo vs team), `opt-caveman` (token optimization).

## Test-type selection (phase ⑦)

`check-test-strategy` reads each feature's characteristics and outputs the **required** test set:

| Test type | Required when |
|---|---|
| Unit (UT) | always |
| Integration (IT) | multiple components / external integration |
| Regression | change touches existing behavior |
| E2E | a user-facing end-to-end flow exists |
| Performance | a latency/throughput NFR is stated |
| Security | auth, secrets, sensitive data, or external surface involved |

Because harness verifications are immutable after `start`, the selected commands are written
into the child-task's `--verifications` at **plan time** (phase ④).

## Notes

- Prefix is classification only — each skill still runs independently per agent
  (Claude Code `/<name>`, Codex by path, Antigravity `/harness-<name>`).
- Capability names inside skills (`ask-user`, `spawn-subagents`, `generate-image`) map per
  agent in [resources/agent-tool-mapping.md](resources/agent-tool-mapping.md).
- Model-tier (`fast`/`strong`) tells an orchestrator which model to spawn a subagent on;
  **when in doubt use `strong`** — cost never weakens a review/test gate.
