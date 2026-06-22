# Step Gate (confirm before the next step)

The pipeline never silently runs the whole lifecycle. After **each phase/step** completes, the
orchestrator stops and asks the user how to proceed — *unless* the run is `auto`, where the choice
becomes a logged decision (see [autonomy-mode](autonomy-mode.md)).

## The gate (gated mode)
At the end of every phase, use **ask-user** (click-select, see
[agent-tool-mapping](agent-tool-mapping.md)) with these options:

| Option | Effect |
|---|---|
| **Run next step** (recommended) | Advance to the next phase only, then gate again |
| **Run all remaining** | Switch this run to `auto` for the rest (records the mode change) |
| **Revise this step** | Redo the step just finished with the user's feedback, then re-gate |
| **Stop** | Checkpoint (`harness session stop`) and end the session |

Show a one-line summary of what the finished step produced (and the artifact path) so the user
decides with context, not blind.

## auto mode
In `auto`, do not stop at the gate. Instead pick "run next", append a line to the task-state
`## Decisions`, and continue — **except** when the next step is on the always-stop list
([autonomy-mode](autonomy-mode.md)), which always stops regardless of mode.

## Persona interaction
- **Non-Technical** defaults to auto-advance between User Stories, so the gate is mostly silent —
  but it still fires (in plain language) before irreversible/outward-facing steps.
- **Developer** is gated by default: the gate fires after every phase.
See [persona-mode](persona-mode.md).

## Why a gate and a hook
The skill drives the gate (asks the question); a `step-gate` hook (F12) is the backstop that
nudges if a skill tries to advance phases without recording a gate decision. Belt and suspenders:
the contract lives in the skill, the enforcement in the hook.
