---
name: ship-deploy
description: Phase 9 deploy — release a build to an environment. Deploying to any non-local environment is an always-stop action requiring explicit user confirmation. Use when: deploying a build to any environment, releasing to staging/production, running deploy-time migrations, or any outward-facing rollout.
---

## One-Liner
Deploying to any non-local environment is always-stop: confirm with the user every time (even in an
auto run), deploy only verified work, and never deploy without a rollback plan and post-deploy check.

Input: a verified release/build + a target environment.

## ALWAYS-STOP
Deploying to **any non-local environment** (staging, production, anything outward-facing) is on the
**always-stop list** ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)) — it
overrides both `gated` and `auto`. **Get explicit user confirmation before deploying**, every time,
even in an unattended run.

**Gate:** the build is verified and the target is identified; if non-local, you have NOT proceeded
without explicit user confirmation.

## Procedure
1. Pre-checks: target env, version, migrations to run, rollback plan, health check.
2. **Confirm with the user** (click-select: deploy / hold) showing env + version + what will change.
3. Deploy; run migrations in the correct order (destructive ones are separately always-stop).
4. **Verify post-deploy** — health check + smoke of the key flow; watch error rates.
5. On failure → execute the rollback plan; report.

```text
Pre-deploy checklist (show in the confirm prompt)
  env:        <staging | production>
  version:    <tag>
  migrations: <list, order>   destructive? <yes→separate always-stop>
  rollback:   <how to undo>
  healthcheck:<endpoint / smoke flow>
```

**Gate:** post-deploy health check + key-flow smoke pass; on failure the rollback plan was executed
and the outcome reported.

## Rules
- Never deploy unverified work. Never auto-deploy to production.
- Local-only runs (dev server, ephemeral preview) are not always-stop, but still report what started.
