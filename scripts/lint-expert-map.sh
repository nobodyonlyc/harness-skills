#!/usr/bin/env bash
# Check that every expert skill named in resources/expert-skills-map.md is actually vendored.
# Source of truth: the fenced ```text block under "## Vendored experts" in that file.
# Usage: bash scripts/lint-expert-map.sh
# Exit 0 = every listed expert resolves to skills/<name>/SKILL.md; exit 1 otherwise.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

map="resources/expert-skills-map.md"
[ -f "$map" ] || { echo "lint-expert-map: missing $map" >&2; exit 1; }

# Extract the names inside the first fenced block that follows the "Vendored experts" header.
names="$(awk '
  /^##[[:space:]]+Vendored experts/ { insec=1; next }
  insec && /^```/ { infence = !infence; if (!infence) exit; next }
  insec && infence { print }
' "$map" | sed -E 's/[[:space:]]+//g' | grep -v '^$')"

if [ -z "$names" ]; then
  echo "lint-expert-map: no expert names found in the fenced list of $map" >&2
  exit 1
fi

fail=0
count=0
while IFS= read -r n; do
  [ -n "$n" ] || continue
  count=$((count + 1))
  if [ ! -f "skills/$n/SKILL.md" ]; then
    echo "  MISS: expert '$n' listed in map but skills/$n/SKILL.md is not vendored" >&2
    fail=1
  fi
done <<< "$names"

if [ "$fail" -eq 0 ]; then
  echo "lint-expert-map: PASS ($count experts vendored)"
else
  echo "lint-expert-map: FAIL" >&2
fi
exit "$fail"
