#!/usr/bin/env bash
# Enforce that resources/expert-skills-map.md is a faithful projection of the skill frontmatter.
#
# Three checks:
#   1. CONSISTENCY — the committed GENERATED region equals what scripts/gen-expert-map.sh produces
#      from the current frontmatter. Frontmatter is the single source of truth; the map must not drift.
#   2. RESOLUTION  — every expert name in the generated fenced list resolves to skills/<name>/SKILL.md.
#   3. DETERMINISM — the generator is stable (two runs are byte-identical), so the lint cannot flap.
#
# Usage: bash scripts/lint-expert-map.sh
# Exit 0 = all checks pass; exit 1 otherwise.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

gen="scripts/gen-expert-map.sh"
map="resources/expert-skills-map.md"
[ -f "$map" ] || { echo "lint-expert-map: missing $map" >&2; exit 1; }
[ -x "$gen" ] || { echo "lint-expert-map: missing/!executable $gen" >&2; exit 1; }

START="<!-- GENERATED:START"
END="<!-- GENERATED:END -->"

fail=0

# --- 3. Determinism: generator output must be reproducible -------------------------------
a="$(bash "$gen" 2>/dev/null)"
b="$(bash "$gen" 2>/dev/null)"
if [ "$a" != "$b" ]; then
  echo "lint-expert-map: FAIL — generator is non-deterministic (two runs differ)" >&2
  fail=1
fi

# --- 1. Consistency: committed region must equal generated region ------------------------
committed="$(awk -v s="$START" -v e="$END" '
  index($0,s){inreg=1} inreg{print} index($0,e){inreg=0}
' "$map")"
if [ -z "$committed" ]; then
  echo "lint-expert-map: FAIL — no GENERATED region found in $map (run '$gen --write')" >&2
  fail=1
elif [ "$committed" != "$a" ]; then
  echo "lint-expert-map: FAIL — $map drifted from skill frontmatter. Diff (committed vs generated):" >&2
  diff <(printf '%s\n' "$committed") <(printf '%s\n' "$a") >&2 || true
  echo "  Fix: run 'bash $gen --write' and commit." >&2
  fail=1
fi

# --- 2. Resolution: every listed expert is vendored -------------------------------------
names="$(printf '%s\n' "$a" | awk '
  /^```/ { infence = !infence; next }
  infence { print }
' | sed -E 's/[[:space:]]+//g' | grep -v '^$')"

count=0
if [ -z "$names" ]; then
  echo "lint-expert-map: FAIL — generated fenced expert list is empty" >&2
  fail=1
else
  while IFS= read -r n; do
    [ -n "$n" ] || continue
    count=$((count + 1))
    if [ ! -f "skills/$n/SKILL.md" ]; then
      echo "  MISS: expert '$n' is mapped but skills/$n/SKILL.md is not vendored" >&2
      fail=1
    fi
  done <<< "$names"
fi

if [ "$fail" -eq 0 ]; then
  echo "lint-expert-map: PASS ($count experts; map in sync with frontmatter)"
else
  echo "lint-expert-map: FAIL" >&2
fi
exit "$fail"
