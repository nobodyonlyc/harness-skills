# Task-State Convention (crash recovery + progress)

`.harness/features.json` records **which** features exist and their coarse status. It does **not**
record where inside a task the work is. `.harness/tasks/<id>.md` makes that durable.

## Ownership — this file is agent-maintained
The harness CLI **creates** the scaffold at `./harness start <id>` and **reads** it at
`./harness resume`. It **never ticks the boxes**. Updating it is the **workflow's job** — if a
workflow does not update it, it silently goes stale (every box stays `[ ]` even after the feature
passes). The `task-state-guard` hook is the backstop: it **blocks `harness verify <id>`** (exit 2)
while the implementation/tests/review boxes are still unticked, and warns softly at session Stop.
Bypass the verify block with `harness verify <id> --override-snapshot` when intentional.

## Lifecycle
1. **Right after `./harness start <id>`** — expand the minimal scaffold into the full template below.
2. **At every phase boundary** (the step-gate, see [step-gate.md](step-gate.md)) — tick the boxes
   just finished, update `## Current phase` + `## Next step`, append any `## Decisions`, and commit.
   A crash then loses at most one phase.
3. **Kept** after the feature passes — it is the durable decision record; `harness clean` must never
   touch `.harness/tasks/`.

## Markers
`[ ]` not started · `[/]` in progress · `[x]` done. Tick `[x]` **only** when that exact step is
genuinely finished — **never tick ahead**.

## Template (expand the scaffold to this at start)
```markdown
# Task State — <id>: <title>

- Mode: gated | auto
- Collab: solo | team (team: also Assignee + Branch)
- Workflow: workflow-feature | workflow-bugfix | ...

## Current phase
<one of: analysis | design | plan | code | review | test | fix | verify | ship>

## Phase checklist
- [ ] Plan approved (docs/design-docs/<id>/plan.md)
- [ ] Implementation complete
- [ ] Selected tests written AND passing (per check-test-strategy — not existence checks)
- [ ] Code review clean (findings in evidence ## Review)
- [ ] `./harness verify <id>` succeeded
- [ ] Evidence written (docs/design-docs/<id>/evidence.md)

## Decisions
- <ISO> — chose X over Y because <reason> (approved by user / [auto])

## Next step
<single concrete next action a fresh session should take>
```

## Rule
The task-state checkpoint is part of the step-gate, not optional. In `auto` mode you still update
the file (the gate becomes a logged decision, but the durable state must stay current).
