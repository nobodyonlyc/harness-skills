---
name: test-performance
description: Phase 7 performance testing — measure latency/throughput/resource use against a stated NFR. Required only when the task has a performance requirement. Use when: a task states a latency/throughput NFR, measuring p95/throughput against a target, or the test-strategy selected performance. Do not run blindly.
---

## One-Liner
Measure against the stated NFR target — never blindly: representative load, warm-up, p50/p95/p99 +
throughput + resources on a noted environment, compared to target and prior baseline.

**Activation:** required only when a **latency/throughput NFR** is stated for the task
(per [check-test-strategy](../check-test-strategy/SKILL.md)). Do not run blindly.

## Run
- Define the **target** from the NFR (e.g. p95 < 200ms at N rps; job processes M rows < T).
- Measure under a representative load with warm-up; report p50/p95/p99 + throughput + resource use.
- Run on a stable environment; note hardware so results are comparable.
- Compare against the target and any prior baseline; a regression beyond threshold fails the gate.

## Record
Record the numbers vs the target in evidence `## Test`; this is the `performance:` verification.
If the target is missed, profile and fix (or, with approval, renegotiate the NFR — a logged decision).
```
## Test
- performance: PASS — p95 <Xms @ <N> rps (target: p95 < 200ms); throughput <Y>; mem <Z>
  env: <hardware/instance>   baseline: <ref>
```

**Gate:** measured numbers meet the stated NFR target (or the NFR was renegotiated with logged approval).
