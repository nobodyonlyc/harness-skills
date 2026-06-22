---
name: ship-deploy
description: Phase 9 deploy — release a build to an environment. Deploying to any non-local environment is an always-stop action requiring explicit user confirmation.
---

Input: a verified release/build + a target environment.

## ALWAYS-STOP
Deploying to **any non-local environment** (staging, production, anything outward-facing) is on the
**always-stop list** ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)) — it
overrides both `gated` and `auto`. **Get explicit user confirmation before deploying**, every time,
even in an unattended run.

## Procedure
1. Pre-checks: target env, version, migrations to run, rollback plan, health check.
2. **Confirm with the user** (click-select: deploy / hold) showing env + version + what will change.
3. Deploy; run migrations in the correct order (destructive ones are separately always-stop).
4. **Verify post-deploy** — health check + smoke of the key flow; watch error rates.
5. On failure → execute the rollback plan; report.

## Rules
- Never deploy unverified work. Never auto-deploy to production.
- Local-only runs (dev server, ephemeral preview) are not always-stop, but still report what started.
