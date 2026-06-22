---
name: dev-batch
description: Phase 5 batch/job implementation — build scheduled or bulk-processing jobs for a child-task with idempotency, checkpointing, and observability.
---

Input: the child-task `plan.md` + design docs.

## Implement
- Make jobs **idempotent** (safe to re-run) and **checkpointed** (resumable after failure).
- Process in bounded batches; apply back-pressure; cap memory.
- Emit **observability** — progress, counts, and failures to logs/metrics, not chat.
- Follow the language guide in [../../resources/conventions/](../../resources/conventions/).

## Self-check
- Re-running the job does not double-apply; a mid-run failure resumes cleanly.

## Handoff
To `check-code-review` then `test-integration` + **performance** tests when an NFR on throughput
exists (per the frozen strategy).
