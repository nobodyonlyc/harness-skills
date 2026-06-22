---
name: workflow-bugfix
description: Fix a bug on an existing harness project via structured debugging — build a reliable pass/fail signal first, then hypothesize, confirm, and fix minimally. Use when: a reported bug, a hard-to-reproduce failure, a regression, a mysterious/intermittent error, agent-assisted root-cause analysis.
---

Bug report: $ARGUMENTS

## One-Liner
Build a fast, deterministic, agent-runnable pass/fail signal first — the bug is 90% fixed once you
have it. Never theorize before you can reproduce.

## Core Philosophy
Most debugging fails because the engineer jumps to hypotheses without a reproducible signal, then
"fixes" symptoms. Build the loop, let the loop drive everything, and only change code once a single
hypothesis is confirmed. Smaller footprint than `workflow-feature`, same review/test/verify gates.

## The six phases (each ends in a Gate)
### Phase 1 — Build a feedback loop
Create the fastest reproducible signal: unit test > integration test > CLI script > REPL > fuzz.
Must be agent-runnable, deterministic, and emit pass/fail (not "looks wrong").
**Gate:** a script/test reproducibly demonstrates the failure.
### Phase 2 — Reproduce exactly
Confirm the loop shows the **reported** failure, not a nearby one. A different failure = a second bug
(note it, don't chase it).
**Gate:** loop output matches the report word-for-word.
### Phase 3 — Hypothesize (before touching code)
Generate **3–5 ranked, falsifiable, independent** hypotheses.
```
H1 (most likely): <cause> → predicts <observable> → test by <action>
H2: …
```
**Gate:** each hypothesis has a concrete, testable prediction.
### Phase 4 — Confirm one
Bisect / instrument / add logging to confirm or kill hypotheses cheaply (use `core-explore` to
locate). Do not fix yet.
**Gate:** exactly one hypothesis is confirmed by evidence from the loop.
### Phase 5 — Minimal fix
Smallest change that turns the loop green. Resist scope creep; a larger design problem becomes a
**separate feature** (WIP=1).
**Gate:** the Phase-1 loop is now green.
### Phase 6 — Regression + verify
`test-regression` is **mandatory** (a bug edits existing behavior) plus the loop's reproduction test;
run [check-review-loop](../check-review-loop/SKILL.md); then `./harness verify <id>`.
**Gate:** reproduction test + regression green, review findings resolved, evidence recorded.

## Rules
- **Failing test before fix** — a fix without a reproducing test is not accepted.
- **Regression required** — `check-test-strategy` always includes regression here.
- **Task-state** — tick the reproduce→fix→regression→verify boxes in `.harness/tasks/<id>.md`
  ([../../resources/task-state.md](../../resources/task-state.md)).
- Step-gate + token-budget as in [workflow-feature](../workflow-feature/SKILL.md). Persona controls
  reporting depth ([../../resources/persona-mode.md](../../resources/persona-mode.md)).

**Delegate craft depth to the experts.** For stack-trace/log analysis and hypothesis-driven
isolation, load the vendored [`debugging-wizard`](../debugging-wizard/SKILL.md) and the six-phase
[`debug-diagnose`](../debug-diagnose/SKILL.md) (see
[../../resources/expert-skills-map.md](../../resources/expert-skills-map.md)). This workflow keeps
the feedback-loop-first discipline, the gates, and the regression+verify close-out.
