---
name: dev-python
description: Phase 5 implementation in Python — language idioms, tooling, and project layout. Composes with a component skill (dev-be/dev-cli/dev-batch).
---

Use **with** a component skill (e.g. `dev-be` for a service, `dev-batch` for a job) — the component
skill says *what* to build; this says *how* in Python. Follow
[../../resources/conventions/python.md](../../resources/conventions/python.md).

## Setup & tooling
- Virtualenv / the project's manager (uv/poetry/pip); pin dependencies.
- Type hints on public functions; `mypy`/`pyright` clean.
- Lint/format: `ruff` + `black` — must pass before review.
- Test runner: `pytest`; `test_*.py`; fixtures over setup duplication.

## Idioms
- Raise specific exceptions; never bare `except:`; let unexpected errors propagate.
- Validate external input at boundaries (pydantic or dataclasses + checks).
- Prefer pure functions; dependency-inject side effects for testability.
- Use context managers for resources; avoid mutable default args.

## Layout
- Package under `src/<pkg>/` (or the repo's layout); tests under `tests/`.

Hand off to `check-code-review` then the test types selected by `check-test-strategy`.
