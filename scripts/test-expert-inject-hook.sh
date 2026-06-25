#!/usr/bin/env bash
# FROZEN verification (F48) — INJECTION half of the expert-inject hook.
#
# Asserts that at code-phase entry the hook injects a system-reminder naming the EXACT skill chain
# (by name) resolved from the Stack block, with the SKILL.md fallback path, and that it stays silent
# outside the code phase.
#
# Strategy: build a throwaway project fixture (features.json + task-state + architecture.md), run the
# hook from that CWD (the hook finds the resolver by its own path, independent of CWD), and inspect
# the hook's combined stdout+stderr.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/hooks/expert-inject.sh"
[ -x "$HOOK" ] || { echo "test-expert-inject-hook: missing/!executable $HOOK" >&2; exit 1; }

fail=0
pass=0
check() { # <desc> <cond 0/1>
  if [ "$2" -eq 0 ]; then pass=$((pass + 1)); else echo "FAIL: $1" >&2; fail=1; fi
}

# mkfixture <dir> <id> <phase> <stack-body>
mkfixture() {
  local dir="$1" id="$2" phase="$3" stack="$4"
  mkdir -p "$dir/.harness/tasks" "$dir/docs/design"
  printf '{"features":[{"id":"%s","status":"in_progress"}]}\n' "$id" > "$dir/.harness/features.json"
  cat > "$dir/.harness/tasks/$id.md" <<EOF
# Task State — $id: fixture

## Current phase
$phase

## Phase checklist
- [ ] Implementation complete
EOF
  cat > "$dir/docs/design/architecture.md" <<EOF
# Architecture
## Stack (machine-readable)
$stack
## Handoff
EOF
}

run_hook() { ( cd "$1" && bash "$HOOK" 2>&1 ); }

# --- Case 1: Go backend, code phase -> dev-be dev-go golang-pro -----------------------------
d1="$(mktemp -d)"
mkfixture "$d1" "FX1" "code" "- language: Go
- runtime: Go 1.23.x (LTS; verified as of 2026-06-25)"
out1="$(run_hook "$d1")"
echo "$out1" | grep -q 'dev-be'    && c=0 || c=1; check "go backend names dev-be" "$c"
echo "$out1" | grep -q 'dev-go'    && c=0 || c=1; check "go backend names dev-go" "$c"
echo "$out1" | grep -q 'golang-pro' && c=0 || c=1; check "go backend names golang-pro" "$c"
echo "$out1" | grep -q 'skills/dev-go/SKILL.md' && c=0 || c=1; check "go backend emits fallback path" "$c"
echo "$out1" | grep -qi 'system-reminder' && c=0 || c=1; check "emits a system-reminder block" "$c"

# --- Case 2: React frontend, code phase -> dev-fe dev-js-ts react-expert --------------------
d2="$(mktemp -d)"
mkfixture "$d2" "FX2" "code" "- language: TypeScript
- framework: React 18.x"
out2="$(run_hook "$d2")"
echo "$out2" | grep -q 'dev-fe'       && c=0 || c=1; check "react infers dev-fe" "$c"
echo "$out2" | grep -q 'react-expert' && c=0 || c=1; check "react names react-expert" "$c"

# --- Case 3: non-code phase -> nothing injected --------------------------------------------
d3="$(mktemp -d)"
mkfixture "$d3" "FX3" "design" "- language: Go"
out3="$(run_hook "$d3")"
[ -z "$out3" ] && c=0 || c=1; check "design phase injects nothing" "$c"

# --- Case 4: code phase but no Stack/language -> nothing (fail-quiet) -----------------------
d4="$(mktemp -d)"
mkdir -p "$d4/.harness/tasks" "$d4/docs/design"
printf '{"features":[{"id":"FX4","status":"in_progress"}]}\n' > "$d4/.harness/features.json"
cat > "$d4/.harness/tasks/FX4.md" <<'EOF'
## Current phase
code
EOF
printf '# Architecture\n## Stack (machine-readable)\n- database: PostgreSQL 17\n## Handoff\n' > "$d4/docs/design/architecture.md"
out4="$(run_hook "$d4")"
[ -z "$out4" ] && c=0 || c=1; check "code phase with no language injects nothing" "$c"

rm -rf "$d1" "$d2" "$d3" "$d4"

if [ "$fail" -eq 0 ]; then
  echo "test-expert-inject-hook: PASS ($pass checks)"
else
  echo "test-expert-inject-hook: FAIL" >&2
fi
exit "$fail"
