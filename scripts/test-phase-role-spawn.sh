#!/usr/bin/env bash
# FROZEN verification for F54 — per-phase role-based subagent spawn + provenance wiring.
#
# This is a content lint: it asserts that the review/QA skills and every workflow actually reference
# the design-derived role (role-resolver) and the CLI provenance flow (harness review open/record /
# review-provenance-gate), so a host reading the SKILL.md is told to spawn a ROLE, not a faceless
# agent, and to record provenance. It does not re-test the resolver/gate behavior (F52/F53 do that).
#
# Usage: bash scripts/test-phase-role-spawn.sh   (exit 0 = pass)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0
pass=0
must() { # <file> <needle> <desc>
  if [ -f "$1" ] && grep -qF -- "$2" "$1"; then
    pass=$((pass + 1))
  else
    echo "FAIL: $3 — '$2' not found in $1" >&2; fail=1
  fi
}

# Supporting artifacts exist
[ -x scripts/role-resolver.sh ] && pass=$((pass + 1)) || { echo "FAIL: scripts/role-resolver.sh missing/!exec" >&2; fail=1; }
[ -f resources/phase-roles.md ] && pass=$((pass + 1)) || { echo "FAIL: resources/phase-roles.md missing" >&2; fail=1; }

# check-review-loop: full role + provenance flow
CRL="skills/check-review-loop/SKILL.md"
must "$CRL" "role-resolver"            "review-loop resolves a role"
must "$CRL" "harness review open"      "review-loop opens provenance"
must "$CRL" "harness review record"    "review-loop records provenance"
must "$CRL" "review-provenance-gate"   "review-loop cites the provenance gate"

# review skills carry the role
must "skills/check-code-review/SKILL.md"     "role-resolver"      "code-review names the role"
must "skills/check-security-review/SKILL.md" "--phase security"   "security-review uses security phase"
must "skills/check-security-review/SKILL.md" "role-resolver"      "security-review names the role"
must "skills/check-qa/SKILL.md"              "--phase qa"         "qa uses the qa phase"

# capability doc documents role + provenance
must "resources/agent-tool-mapping.md" "role-resolver"   "agent-tool-mapping documents role resolution"
must "resources/agent-tool-mapping.md" "harness review"  "agent-tool-mapping documents provenance"

# every workflow references the role-based spawn
for w in workflow-bootstrap workflow-feature workflow-bugfix workflow-team; do
  must "skills/$w/SKILL.md" "role-resolver" "$w spawns a role-based reviewer"
done

echo "test-phase-role-spawn: $pass passed, fail=$fail"
exit $fail
