# Convention: Python

- **Type hints** on public functions; run `mypy`/`pyright` clean.
- **Format/lint**: `ruff` + `black`; must pass before review.
- **Errors**: raise specific exceptions; never bare `except:`; let unexpected errors propagate.
- **Structure**: small functions; pure where possible; dependency-inject side effects for testability.
- **Validation**: pydantic (or dataclasses + checks) at boundaries.
- **Tests**: `pytest`; `test_*.py`; fixtures over setup duplication.
- **No secrets** in code; use env/config; never log credentials.
