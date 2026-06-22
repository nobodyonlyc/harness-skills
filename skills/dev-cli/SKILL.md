---
name: dev-cli
description: Phase 5 CLI implementation — build command-line interfaces for a child-task with clear argument parsing, exit codes, and scriptable output.
---

Input: the child-task `plan.md` + design docs.

## Implement
- Define **commands/subcommands**, flags, and arguments; provide `--help` for each.
- Use correct **exit codes** (0 success, non-zero per error class) — scripts depend on them.
- Make output **scriptable** (stable, parseable) and human-readable; keep errors on stderr.
- Follow the language guide in [../../resources/conventions/](../../resources/conventions/).

## Self-check
- `--help` is accurate; exit codes are correct; no interactive prompt in non-TTY mode.

## Handoff
To `check-code-review` then `test-unit` (arg parsing/exit codes) and `test-integration` (end-to-end
command runs) as the frozen strategy requires.
