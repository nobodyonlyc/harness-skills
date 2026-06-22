---
name: core-file-ops
description: Mechanical file operations — create, move, rename, or delete files and directories. Fast-tier, low-judgment. Use when: creating/moving/renaming/deleting files or directories as a mechanical step, not as part of a larger judgment-heavy change.
---

## One-Liner
Mechanical create/move/rename/delete — low-judgment file plumbing; confirm before deleting or overwriting anything you did not create.

Operation: $ARGUMENTS

## Do
- Create / move / rename / delete files and directories as requested.
- Update obvious references (imports, paths) that the move breaks; run a quick build/lint to confirm.
- Use the version-control move (`git mv`) so history is preserved.

## Rules
- **Look before deleting/overwriting.** Inspect the target first; if its content contradicts how it
  was described, or you did not create it, **stop and surface it** instead of proceeding.
- Deleting/overwriting data **outside the active task's scope** is always-stop
  ([../../resources/autonomy-mode.md](../../resources/autonomy-mode.md)) — confirm with the user.
- Tier: **fast** — mechanical work; escalate to `strong` only if a move requires judgment about
  what references to rewrite.
