#!/usr/bin/env bash
# Check that a skill meets the deep-skill bar (resources/skill-depth-standard.md).
# Usage: bash scripts/lint-depth.sh <skill-name>
# Exit 0 = meets the bar, exit 1 = fails (prints which markers are missing).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

name="${1:-}"
[ -n "$name" ] || { echo "usage: lint-depth.sh <skill-name>" >&2; exit 2; }
sk="skills/$name/SKILL.md"
[ -f "$sk" ] || { echo "lint-depth: no such skill: $name" >&2; exit 2; }

fail=0
miss() { echo "  MISS [$name]: $*" >&2; fail=1; }

# 1. Triggers — description has a "Use when" clause
grep -qiE '^description:.*use when' "$sk" || miss "frontmatter description needs a 'Use when:' clause (triggers)"

# 2. One-Liner section
grep -qiE '^#+ *one[- ]?liner|one-liner' "$sk" || miss "missing a One-Liner section"

# 3. At least one explicit Gate
grep -qiE '(\*\*gate\*\*|^#*[[:space:]]*gate|gate:)' "$sk" || miss "no explicit 'Gate:' checkpoint found"

# 4. On-demand depth: a references/ dir OR an inline fenced example/output template
if [ ! -d "skills/$name/references" ]; then
  grep -qE '^```' "$sk" || miss "no references/ dir and no inline fenced example/output template"
fi

if [ "$fail" -eq 0 ]; then
  echo "lint-depth [$name]: PASS"
else
  echo "lint-depth [$name]: FAIL" >&2
fi
exit "$fail"
