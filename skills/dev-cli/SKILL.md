---
name: dev-cli
description: Phase 5 CLI implementation — build command-line interfaces for a child-task with clear argument parsing, exit codes, and scriptable output. Use when: building a command-line interface for a child-task, defining commands/flags/exit codes, making output scriptable, or the Phase 5 CLI slice.
---

## One-Liner
A CLI is an API for scripts: correct exit codes, parseable stdout, errors on stderr, accurate
`--help`, and no interactive prompt in a non-TTY — so automation can depend on it.

Input: the child-task `plan.md` + design docs.

## Implement
- Define **commands/subcommands**, flags, and arguments; provide `--help` for each.
- Use correct **exit codes** (0 success, non-zero per error class) — scripts depend on them.
- Make output **scriptable** (stable, parseable) and human-readable; keep errors on stderr.
- Follow the language guide in [../../resources/conventions/](../../resources/conventions/).

## Examples (Bad vs Good)
```python
# BAD: error to stdout, exit 0 on failure, prose mixed into machine output
print("error: not found"); sys.exit(0)            # scripts can't detect the failure
# GOOD: error to stderr, non-zero exit, clean parseable stdout
print("error: not found", file=sys.stderr); sys.exit(2)
print(json.dumps(result))                          # stdout stays scriptable
```

## Self-check
- `--help` is accurate; exit codes are correct; no interactive prompt in non-TTY mode.
**Gate:** exit codes correct, stdout parseable, errors on stderr, `--help` accurate.

## Handoff
To `check-code-review` then `test-unit` (arg parsing/exit codes) and `test-integration` (end-to-end
command runs) as the frozen strategy requires.
