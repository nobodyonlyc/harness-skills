#!/usr/bin/env bash
# Structure linter for harness-skills.
# Validates ONLY what exists, so it stays green from an empty scaffold and tightens
# as features land. Run from the repo root: bash scripts/validate.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0
err() { echo "  FAIL: $*" >&2; fail=1; }
note() { echo "  ok: $*"; }

echo "== validate harness-skills =="

# 1. Required top-level files
for f in README.md CATEGORIES.md install.sh scripts/validate.sh; do
  [ -e "$f" ] || err "missing required file: $f"
done
[ -x install.sh ] || err "install.sh is not executable"
[ -x scripts/validate.sh ] || err "scripts/validate.sh is not executable"

# 2. Every skill must have SKILL.md with name + description frontmatter
if [ -d skills ]; then
  for d in skills/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    sk="$d/SKILL.md"
    if [ ! -f "$sk" ]; then err "skill '$name' has no SKILL.md"; continue; fi
    head -n 12 "$sk" | grep -qiE '^name:' || err "skill '$name' SKILL.md missing 'name:' frontmatter"
    head -n 12 "$sk" | grep -qiE '^description:' || err "skill '$name' SKILL.md missing 'description:' frontmatter"
  done
fi

# 3. Every hook must be syntactically valid bash
if [ -d hooks ]; then
  for h in hooks/*.sh; do
    [ -e "$h" ] || continue
    bash -n "$h" || err "hook '$h' has a bash syntax error"
  done
fi

# 4. If caveman is vendored, expect a .gitmodules entry pointing at it
if [ -e .gitmodules ]; then
  grep -q 'vendor/caveman' .gitmodules || err ".gitmodules present but no vendor/caveman submodule entry"
fi

if [ "$fail" -eq 0 ]; then
  echo "== validate: PASS =="
else
  echo "== validate: FAIL =="
fi
exit "$fail"
