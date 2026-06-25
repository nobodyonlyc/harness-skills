#!/usr/bin/env bash
# FROZEN verification (F48) — AUTO-LOG half of the expert-inject hook.
#
# Asserts that at code-phase entry the hook records the resolved chain to BOTH observability sinks —
# .harness/trace.md and the task-state file — automatically, that it is IDEMPOTENT (a second run does
# not duplicate), and that it logs nothing outside the code phase.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/hooks/expert-inject.sh"
[ -x "$HOOK" ] || { echo "test-expert-inject-log: missing/!executable $HOOK" >&2; exit 1; }

fail=0
pass=0
check() { if [ "$2" -eq 0 ]; then pass=$((pass + 1)); else echo "FAIL: $1" >&2; fail=1; fi; }

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

run_hook() { ( cd "$1" && bash "$HOOK" >/dev/null 2>&1 ); }

# --- Code phase: both sinks get the chain ---------------------------------------------------
d1="$(mktemp -d)"
mkfixture "$d1" "FX1" "code" "- language: Go
- runtime: Go 1.23.x"
run_hook "$d1"

ts="$d1/.harness/tasks/FX1.md"
trace="$d1/.harness/trace.md"

[ -f "$trace" ] && c=0 || c=1; check "trace.md created" "$c"
grep -q 'expert-inject' "$trace" 2>/dev/null && c=0 || c=1; check "trace logs the expert-inject skill" "$c"
grep -q 'dev-be dev-go golang-pro' "$trace" 2>/dev/null && c=0 || c=1; check "trace logs the full chain" "$c"
grep -q 'feature=FX1' "$trace" 2>/dev/null && c=0 || c=1; check "trace tags the feature id" "$c"

grep -q '^## Resolved skill chain (auto)' "$ts" 2>/dev/null && c=0 || c=1; check "task-state gains the chain section" "$c"
grep -q 'dev-be dev-go golang-pro' "$ts" 2>/dev/null && c=0 || c=1; check "task-state logs the full chain" "$c"

# --- Idempotency: a second run must not duplicate -------------------------------------------
run_hook "$d1"
sec_count=$(grep -c '^## Resolved skill chain (auto)' "$ts" 2>/dev/null || echo 0)
[ "${sec_count:-0}" -eq 1 ] && c=0 || c=1; check "task-state section not duplicated (got $sec_count)" "$c"
trace_count=$(grep -c 'feature=FX1' "$trace" 2>/dev/null || echo 0)
[ "${trace_count:-0}" -eq 1 ] && c=0 || c=1; check "trace line not duplicated (got $trace_count)" "$c"

# --- Non-code phase: nothing logged --------------------------------------------------------
d2="$(mktemp -d)"
mkfixture "$d2" "FX2" "review" "- language: Go"
run_hook "$d2"
[ ! -f "$d2/.harness/trace.md" ] && c=0 || c=1; check "review phase writes no trace" "$c"
grep -q '^## Resolved skill chain (auto)' "$d2/.harness/tasks/FX2.md" 2>/dev/null && c=1 || c=0
check "review phase adds no task-state section" "$c"

rm -rf "$d1" "$d2"

if [ "$fail" -eq 0 ]; then
  echo "test-expert-inject-log: PASS ($pass checks)"
else
  echo "test-expert-inject-log: FAIL" >&2
fi
exit "$fail"
