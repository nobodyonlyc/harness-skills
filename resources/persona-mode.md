# Persona Mode (Developer vs Non-Technical)

Every workflow branches on **`user_role`** so the *same* pipeline behaves differently for a
developer and a non-technical user. Persona changes **how much you ask, in what language, and
what you surface vs decide** — it never removes a quality gate.

Set at intake and stored in `.harness/context.json`:
```bash
./harness config set user_role Developer        # or Non-Technical (or Product)
./harness config set auto_advance false          # true for Non-Technical
```

## The contract

| Dimension | **Non-Technical** | **Developer** |
|---|---|---|
| Language | Plain, outcome/feature/screen terms; no jargon | Technical and precise |
| Questions | **Requirement-level only** — who uses it, what it must do, must-haves — batched into a few click-select asks | **Exhaustive** — stack, architecture, DB schema, API contracts, test strategy, edge cases, NFRs |
| Technical decisions | Agent picks sensible **defaults** and **logs** them; does not ask | Surfaces **trade-offs** and asks the user to choose |
| What is shown | Requirements, scope, UX, what changed in user terms | Full design docs, diagrams, schema, contracts |
| Stop cadence | **Auto-advance** between User Stories (still obeys always-stop) | **Gated** — stop after each phase/step |
| Suggestions | About scope, requirements, UX ("add login?") | About design, optimization, technical risk ("JWT vs session?") |

## How each phase reads persona

- **① BA** (`plan-ba-analysis`): Non-tech → elicit goals in business language, propose a small
  must-have set, confirm. Dev → drill acceptance criteria, edge cases, NFRs, data ownership.
- **② System design**: Non-tech → choose conventional defaults (stack, DB) **from the default-stack
  table in [stack-defaults.md](stack-defaults.md)** and log rationale. Dev → present options +
  trade-offs, get approval. Both personas must **web-research the current latest LTS version** of each
  chosen technology before recording it — an actual `web-research` tool call, never recalled from
  memory ([stack-defaults.md](stack-defaults.md) Rule 0, [agent-tool-mapping.md](agent-tool-mapping.md)).
- **③ UI**: Non-tech → show a clickable mockup and ask "does this match?" Dev → confirm
  component breakdown, states, responsive rules.
- **④ Plan tasks**: Non-tech → keep task list coarse, hide IDs. Dev → full child-task split + test strategy.
- **⑥ Review / ⑦ Test**: **identical for both** — gates are persona-independent. A non-tech run
  still runs review + the required test types; it just reports results in plain language.
- **⑨ Deploy**: both stop (always-stop), but non-tech gets a plain-language "ready to publish?" confirm.

## Rules
- Persona is a **communication + question-depth** setting, **not** a quality setting. Review,
  test selection, and verify gates run the same regardless of role.
- When `user_role` is unknown **or carried over from a prior session and not confirmed this
  session**, **ask first** — never silently default to `Developer` (a `persona-gate` hook nudges,
  and `workflow-intake` Phase 2 makes the ask mandatory).
- Non-Technical defaults to `auto_advance=true` but still honors the
  [autonomy-mode](autonomy-mode.md) always-stop list and the [step-gate](step-gate.md) on
  irreversible actions.
- A non-tech user can always request detail ("explain the technical choice") — escalate language on demand.
