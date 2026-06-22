---
name: dev-batch
description: Phase 5 batch/job implementation — build scheduled or bulk-processing jobs for a child-task with idempotency, checkpointing, and observability. Use when: building a scheduled or bulk-processing job, needing idempotency/checkpointing/back-pressure, processing data in bounded batches, or the Phase 5 batch slice.
---

## One-Liner
Jobs must be safe to re-run (idempotent) and resumable after failure (checkpointed), process in
bounded batches with back-pressure, and emit observability to logs/metrics — never to chat.

Input: the child-task `plan.md` + design docs.

## Implement
- Make jobs **idempotent** (safe to re-run) and **checkpointed** (resumable after failure).
- Process in bounded batches; apply back-pressure; cap memory.
- Emit **observability** — progress, counts, and failures to logs/metrics, not chat.
- Follow the language guide in [../../resources/conventions/](../../resources/conventions/).

## Examples (Bad vs Good)
```python
# BAD: loads everything, no checkpoint, re-run double-applies
for row in db.fetch_all():        # unbounded memory
    send_email(row)               # re-run emails everyone again
# GOOD: bounded batches, checkpointed cursor, idempotent guard
while (batch := db.fetch_after(cursor, limit=500)):
    for row in batch:
        if not row.emailed:        # idempotent: skip already-done
            send_email(row); mark_emailed(row)
    cursor = batch[-1].id; save_checkpoint(cursor)   # resumable
```

## Self-check
- Re-running the job does not double-apply; a mid-run failure resumes cleanly.
**Gate:** re-run does not double-apply and a mid-run failure resumes cleanly from the checkpoint.

## Handoff
To `check-code-review` then `test-integration` + **performance** tests when an NFR on throughput
exists (per the frozen strategy).

**Caveman level** — item lists and progress/count data passed between agents are pure data →
`ultra`; routine run summaries → `full` (per the Level selection matrix in
[../../resources/token-budget.md](../../resources/token-budget.md)).
