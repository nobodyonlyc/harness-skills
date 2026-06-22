# Autonomy Mode (gated vs auto)

The pipeline gates many steps behind **ask-user**. That suits interactive work but fights long
unattended runs. Autonomy mode chooses, once and up front, how much a run stops for the user.

## The two modes

| | `gated` (default) | `auto` |
|---|---|---|
| Per-step ask-user gates | Stop and wait | Decide autonomously, log it, continue |
| Plan / design approval | User approves | Agent approves its own plan, records rationale |
| Always-stop list (below) | Stop | **Still stop** |
| Best for | Interactive work, first run, teammates | Overnight / long runs the user explicitly asked for |

**Default is `gated`.** `auto` is opt-in: the user enables it explicitly ("run F30 in auto",
"do this unattended"). A first-time run never surprises the user by deciding on its own.

## Where it is set and stored
- Chosen once at intake ([../skills/workflow-intake/SKILL.md](../skills/workflow-intake/SKILL.md)).
- Written to the task-state file's `Mode:` field so a recovering session inherits it without re-asking.

## Logged decisions (auto mode)
When `auto` skips a gate it MUST record the decision so the run is auditable. Append to the
task-state `## Decisions`:
```
- <ISO timestamp> — [auto] <decision> because <reason>; alternative considered: <X>
```
A wrong decision is recoverable from this log; an unrecorded one is not.

## Always-stop list (overrides BOTH modes)
Even in `auto`, STOP and ask before:
- Deleting/overwriting data or files **outside the active feature's scope**.
- `git push --force`, history rewrites, pushing to a shared/protected branch.
- Deploying to production or any non-local environment.
- Destructive schema/data migrations (drop/alter that loses data).
- Anything touching payments, credentials, secrets, or external side effects (email, paid APIs at scale).
- Work exceeding the active feature's scope (WIP=1) — surface it, do not silently expand.

When in doubt, treat it as always-stop. Relationship to [step-gate](step-gate.md): step-gate
defines the *between-phase* confirmation; autonomy-mode decides whether that confirmation stops or logs.
