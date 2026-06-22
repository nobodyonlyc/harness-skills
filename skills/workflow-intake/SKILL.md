---
name: workflow-intake
description: Single entry point — classify any incoming prompt into one of 4 cases, set persona/autonomy/collab, then dispatch to the matching harness workflow. Use when: a new prompt arrives and the route is unknown, starting any harness session, deciding between bootstrap/feature/bugfix, onboarding a legacy repo, or a request is too vague to act on yet.
---

Incoming request: $ARGUMENTS

## One-Liner
Never act before you classify: read state → pick one of 4 cases → set persona/autonomy/collab →
dispatch. The router owns no work itself; it guarantees every run starts in the right mode.

Classify the prompt, confirm with the user, set the run's persona/autonomy/collab, then dispatch.
Every gate uses the **ask-user** capability ([../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)).

## Phase -1 — Read current state (always first)
```bash
./harness status      # backlog, WIP, blocked
./harness resume      # computed next step (when a session was in progress)
```
**Empty-request guard:** if the prompt is not actionable (`.`, `ok`, `hi`, `continue`, blank, a
greeting) — do NOT classify or dispatch. Report the state above and ask what the user wants. Never
auto-start bootstrap just because the repo is empty.
**Gate:** current backlog/WIP/blocked state is in hand, and the prompt is actionable (not empty).

## Phase 0 — Classify & confirm
Decide which case, then **confirm with the user** (click-select) before dispatching. Re-classify on correction.

| Case | Signal | Dispatch |
|---|---|---|
| **1. New project** | empty/greenfield repo; "build me a …" | `workflow-bootstrap` |
| **2. Execute a US** | a backlog US id; "do F12" | analyse US → split child-tasks `F<id>-T<n>` → `workflow-feature` / `workflow-bugfix` |
| **3. Add feature** | existing harness repo + new capability | read source (`core-explain`) → BA delta → add US → `workflow-feature` |
| **4. Legacy onboard** | "add harness to a non-harness project" | survey → docs → safe `harness init` → seed backlog |

**Gate:** exactly one case is chosen and the user has confirmed it (click-select).

## Phase 0.5 — Persona & autonomy (persist to context.json)
Per [../../resources/persona-mode.md](../../resources/persona-mode.md) and
[../../resources/autonomy-mode.md](../../resources/autonomy-mode.md):
```bash
./harness config set user_role Developer        # or Non-Technical
./harness config set auto_advance false          # true for Non-Technical
```
- **Developer** → gated, exhaustive questioning, trade-offs surfaced.
- **Non-Technical** → auto-advance between USs, requirement-level questions in plain language,
  technical defaults chosen + logged.
- **Autonomy** defaults to `gated`; switch to `auto` only if the user explicitly asks for an
  unattended run. Record the mode in the task-state `Mode:` field.

**Gate:** `user_role` + `auto_advance` are persisted to config and reflected in the task-state `Mode:`.

## Phase 0.7 — Collaboration mode
Record `solo` (default, global WIP=1) or `team` (per-assignee claim + branch + PR gate, see
`workflow-team`) in the task-state `Collab:` field. Detect `team` when the user mentions multiple
people/agents or `features.json` already has an `assignee`/`branch`; when ambiguous, ask-user.

**Gate:** the task-state `Collab:` field reads `solo` or `team`.

## Phase 0.8 — Start session
```bash
./harness session start --goal "<intent>"
```

**Gate:** a session is active and control has been handed to the dispatched workflow.

## Cross-cutting rules (every route)
- **Step-gate** — after each phase, confirm before advancing per
  [../../resources/step-gate.md](../../resources/step-gate.md); in `auto`, log the decision instead.
- **Full gates** — every executed US runs review + the required test types + verify.
- **Caveman (on by default)** — apply [opt-caveman](../opt-caveman/SKILL.md) to every inter-agent
  prompt and subagent result, and write long artifacts to files; this is a standing rule for all
  routes, not opt-in ([../../resources/token-budget.md](../../resources/token-budget.md)).
- **Tracking** — record each step as a harness task; bookend with `session start/stop`.
- **Task-state** — right after `./harness start <id>`, expand `.harness/tasks/<id>.md` to the full
  template and update + commit it at every phase boundary ([../../resources/task-state.md](../../resources/task-state.md)).
