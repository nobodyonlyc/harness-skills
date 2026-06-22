---
name: plan-skeleton
description: Phase 4 skeleton generation — create the minimal project/file structure and build tooling for a greenfield project so the dev phase has a working frame. Use when: scaffolding a greenfield project's structure and build tooling, or producing a runnable frame before the dev phase starts.
---

## One-Liner
Stand up the smallest runnable frame — structure + build tooling that passes `init.sh` — so the dev phase has something green to build on, not a blank repo.

Input: the **Stack block** in `docs/design/architecture.md` (the machine-readable source of truth —
language, framework, db, package-manager, test-runner, and the **pinned LTS versions**). Output: a
runnable skeleton under `source/` (or repo root).

## Produce
- **Directory layout** matching the architecture (per component).
- **Build/run config** — package manifest, scripts, lint/test config, so `./init.sh` and `./run.sh`
  work from the start. **Pin every manifest to the exact versions from the Stack block** — do not
  float to "latest" at install time; the researched LTS version is the contract (`.nvmrc` /
  `go.mod` / `pyproject.toml` / framework deps must match the Stack block).
- **Stubs** — entry point, a health/smoke path, and placeholders for the planned components.
- A **passing baseline** — the smoke test / `./init.sh` must be green before any feature work
  (harness hard rule: fix the baseline first).

## Persona
- **Non-Technical** — report "the project frame is set up and runs" in plain language; no file dump.
- **Developer** — confirm layout + tooling choices match the **craft source resolved from the Stack
  block** ([../../resources/stack-defaults.md](../../resources/stack-defaults.md) Rule 2): the
  `../../resources/conventions/<lang>.md` guide when one exists, otherwise the mapped vendored expert
  ([../../resources/expert-skills-map.md](../../resources/expert-skills-map.md)). A stack without a
  `conventions/` file is fully supported — follow its expert.

## Gate
Step-gate; ensure the skeleton builds + the smoke test passes before handing to `dev-*`. For
existing projects this skill is skipped (the frame already exists).
