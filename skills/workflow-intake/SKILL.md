---
name: workflow-intake
description: Single entry point — classify ANY incoming prompt into a lifecycle route (build/change the product through the 9 phases) OR a direct route (one-off task dispatched straight to a skill), set mode, then dispatch. Nothing dead-ends. Use when: a new prompt arrives and the route is unknown, starting any harness session, deciding between bootstrap/feature/bugfix, onboarding a legacy repo, a one-off ask (explain/fix/review/research/design/test/config), or a request is too vague to act on yet.
metadata:
  layer: workflow
  tier: entry
---

Incoming request: $ARGUMENTS

## One-Liner
Never act before you classify: read state → pick a route → set mode → dispatch. The router owns no
work itself; it guarantees every run starts in the right mode AND that no request dead-ends — there
is always a route, including a direct catch-all for one-off asks that don't belong to the lifecycle.

Two families of route:
- **Lifecycle (A)** — the request *builds or changes the product*. Runs the full 9-phase machinery:
  creates/advances a US, sets persona/autonomy/collab, tracks a session, runs review + tests + verify.
- **Direct (B)** — the request is a *one-off task* (understand, fix, review, research, design, test,
  config). Dispatched straight to the matching skill chain. No US, no full gates, lightweight trace.

Classify the prompt, (for lifecycle) confirm with the user, set the run's mode, then dispatch.
Every gate uses the **ask-user** capability ([../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)).

## Phase 0 — Read current state (always first)
```bash
./harness status      # backlog, WIP, blocked
./harness resume      # computed next step (when a session was in progress)
```
**Empty-request guard:** if the prompt is not actionable (`.`, `ok`, `hi`, `continue`, blank, a
greeting) — do NOT classify or dispatch. Report the state above and ask what the user wants. Never
auto-start bootstrap just because the repo is empty.
**Gate:** current backlog/WIP/blocked state is in hand, and the prompt is actionable (not empty).

## Phase 1 — Classify & confirm
First decide the **family** with one question: *does this request build or change the product through
the lifecycle (A), or is it a one-off task to act on now (B)?* Then pick the case within that family.

**Dispatch = read and follow the linked `SKILL.md`** (do not act on the bare name).

### Family A — Lifecycle routes (full 9-phase machinery; continue to Phase 2–4)
| Case | Signal | Dispatch |
|---|---|---|
| **1. New project** | empty/greenfield repo; "build me a …" | [workflow-bootstrap](../workflow-bootstrap/SKILL.md) |
| **2. Execute a US** | a backlog US id; "do F12" | analyse US → split child-tasks `F<id>-T<n>` → [workflow-feature](../workflow-feature/SKILL.md) / [workflow-bugfix](../workflow-bugfix/SKILL.md) |
| **3. Add feature** | existing harness repo + new capability | read source ([core-explain](../core-explain/SKILL.md)) → BA delta → add US → [workflow-feature](../workflow-feature/SKILL.md) |
| **4. Legacy onboard** | "add harness to a non-harness project" | survey → docs → safe `harness init` → seed backlog |

### Family B — Direct routes (one-off; skip Phase 2–4, dispatch now, lightweight trace)
| Case | Signal | Dispatch |
|---|---|---|
| **5. Understand** | "explain / where / how does X work", read-only inspection | [core-explore](../core-explore/SKILL.md) → [core-explain](../core-explain/SKILL.md) |
| **6. Diagnose & fix** | a concrete defect with no backlog US; "this is broken, fix it" | [debug-diagnose](../debug-diagnose/SKILL.md) → [core-fix](../core-fix/SKILL.md) |
| **7. Review** | "review this diff / PR / security / refactor / QA" | [check-code-review](../check-code-review/SKILL.md) / [check-pr-review](../check-pr-review/SKILL.md) / [check-security-review](../check-security-review/SKILL.md) / [check-refactor](../check-refactor/SKILL.md) / [check-qa](../check-qa/SKILL.md) |
| **8. Standalone craft** | one-off design, test-authoring, or language task with no lifecycle | design: [design-api](../design-api/SKILL.md)/[design-architecture](../design-architecture/SKILL.md)/[design-database](../design-database/SKILL.md)/[design-ui](../design-ui/SKILL.md) · test: [test-unit](../test-unit/SKILL.md)/[test-integration](../test-integration/SKILL.md)/[test-e2e](../test-e2e/SKILL.md) · language: resolve via [experts-resolver.sh](../../scripts/experts-resolver.sh) |
| **9. Ops & config** | harness/agent config, commit msg, PR, release, deploy | [update-config (host)] · [ship-commit-msg](../ship-commit-msg/SKILL.md) / [ship-pr-create](../ship-pr-create/SKILL.md) / [ship-release](../ship-release/SKILL.md) / [ship-deploy](../ship-deploy/SKILL.md) |
| **10. Research** | external/multi-source investigation, compare options, fact-find | `deep-research` (host skill — invoke by name) |
| **→ Catch-all** | a direct task matching none above | pick the **single best-matching skill by layer** and dispatch; if truly none fit, proceed with general assistance. **Never dead-end.** |

**Confirm policy:**
- **Family A** — always **confirm the case with the user** (click-select) before dispatching; re-classify on correction.
- **Family B** — dispatch immediately; confirm only when the sub-type is genuinely ambiguous.
- **Escalation** — if a direct task turns out to need lifecycle treatment (touches many files, needs
  review + tests + verify, or the user wants it tracked), stop and re-route to Family A (case 2/3).

**Gate:** exactly one route is chosen; for Family A the user has confirmed it (click-select); for
Family B a skill chain (or the catch-all) is selected so the request never dead-ends.

> **Phases 2–4 are Family A (lifecycle) only.** Family B (direct) routes skip them: no
> persona/autonomy/collab ceremony and no required session — dispatch the chosen skill chain now and
> record a one-line trace (`.harness/trace.md`). Start a session only if the task escalates to Family A.

## Phase 2 — Persona & autonomy (persist to context.json)
Per [../../resources/persona-mode.md](../../resources/persona-mode.md) and
[../../resources/autonomy-mode.md](../../resources/autonomy-mode.md):

**Always ask for `user_role` — never default it.** Unless the user has *explicitly stated their
persona this session* (e.g. "I'm non-technical", "treat me as a developer"), use the **ask-user**
capability ([../../resources/agent-tool-mapping.md](../../resources/agent-tool-mapping.md)) to have
them pick before continuing. A value already sitting in `context.json` from a prior session does
**not** count as answered — confirm it. Do not present `Developer` as a pre-selected default.

> Ask: *"How should I work with you?"* → **Developer** / **Non-Technical** / **Product**.

Only after the user picks, persist it:
```bash
./harness config set user_role <chosen>           # Developer | Non-Technical | Product
./harness config set auto_advance false            # true for Non-Technical
```
- **Developer** → gated, exhaustive questioning, trade-offs surfaced.
- **Non-Technical** → auto-advance between USs, requirement-level questions in plain language,
  technical defaults chosen + logged.
- **Autonomy** defaults to `gated`; switch to `auto` only if the user explicitly asks for an
  unattended run. Record the mode in the task-state `Mode:` field.

**Gate:** `user_role` was chosen by the user this session (not silently defaulted); `user_role` +
`auto_advance` are persisted to config and reflected in the task-state `Mode:`.

## Phase 3 — Collaboration mode
Record `solo` (default, global WIP=1) or `team` (per-assignee claim + branch + PR gate, see
[workflow-team](../workflow-team/SKILL.md)) in the task-state `Collab:` field. Detect `team` when the user mentions multiple
people/agents or `features.json` already has an `assignee`/`branch`; when ambiguous, ask-user.

**Gate:** the task-state `Collab:` field reads `solo` or `team`.

## Phase 4 — Start session
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
