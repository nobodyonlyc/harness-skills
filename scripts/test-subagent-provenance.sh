#!/usr/bin/env bash
# FROZEN verification for F55 — SubagentStop review-record reminder + end-to-end provenance chain.
#
# Part A: the reminder hook is advisory and correct — silent with no in-progress feature, silent when
#         provenance is CURRENT, and emits a record reminder when provenance is NONE. Always exit 0.
# Part B: end-to-end — role-resolver --phase review feeds --role into `harness review open`, `record`
#         makes status CURRENT. Proves resolver -> CLI -> status work together (the spawn pipeline).
#
# Usage: bash scripts/test-subagent-provenance.sh   (exit 0 = pass)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/hooks/review-record-reminder.sh"
RR="$ROOT/scripts/role-resolver.sh"
[ -f "$HOOK" ] || { echo "test-subagent-provenance: missing $HOOK" >&2; exit 1; }
[ -f "$RR" ]   || { echo "test-subagent-provenance: missing $RR" >&2; exit 1; }

BIN=""
for c in "$ROOT/../../harness" "$(command -v harness 2>/dev/null || true)"; do
  [ -n "$c" ] && [ -x "$c" ] || continue
  if "$c" review --help >/dev/null 2>&1; then BIN="$(cd "$(dirname "$c")" && pwd)/$(basename "$c")"; break; fi
done
[ -n "$BIN" ] || { echo "test-subagent-provenance: no harness binary with 'review' found" >&2; exit 1; }

fail=0; pass=0
check() { if [ "$2" -eq 0 ]; then pass=$((pass + 1)); else echo "FAIL: $1" >&2; fail=1; fi; }

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
(
  cd "$WORK"
  git init -q; git config user.email t@t.dev; git config user.name T
  echo seed > seed.txt; git add -A; git commit -qm init
  cp "$BIN" ./harness
  ./harness init --bare >/dev/null 2>&1
  ./harness add FT9 "e2e" --priority 1 --behavior x --verifications "unit:true" >/dev/null 2>&1
)

run_hook() { ( cd "$WORK" && bash "$HOOK" 2>&1 ); }   # combined stdout+stderr

# --- Part A1: no in-progress feature -> silent --------------------------------------------
A1="$(run_hook)"
[ -z "$A1" ] && check "silent when no in-progress feature" 0 || check "silent when no in-progress feature" 1

# mark FT9 in_progress (plan+start need docs; just flip status via re-add path: use start --force after a plan)
( cd "$WORK" && mkdir -p docs/design-docs/FT9 && printf 'plan\nreal content here to pass the gate\n' > docs/design-docs/FT9/plan.md && printf 'evidence content that is sufficiently long for the harness gate\n' > docs/design-docs/FT9/evidence.md && ./harness start FT9 --force >/dev/null 2>&1 )

# --- Part A2: in-progress + NONE provenance -> emits a record reminder ----------------------
A2="$(run_hook)"
echo "$A2" | grep -q "REVIEW PROVENANCE \[FT9\]" && check "reminds when provenance is NONE" 0 || check "reminds when provenance is NONE" 1
echo "$A2" | grep -q "harness review record FT9" && check "reminder includes the record command" 0 || check "reminder includes the record command" 1

# --- Part B: end-to-end role-resolver -> open(--role) -> record -> CURRENT ------------------
SPEC="$(bash "$RR" --phase review --language go --component be 2>/dev/null)"
echo "$SPEC" | grep -q 'Tech Lead' && check "role-resolver yields a tech-lead spec" 0 || check "role-resolver yields a tech-lead spec" 1
OUT="$( cd "$WORK" && ./harness review open FT9 --phase review --role "$SPEC" 2>&1 )"
NONCE="$(printf '%s' "$OUT" | awk -F': ' '/nonce/{gsub(/ /,"",$2);print $2; exit}')"
[ -n "$NONCE" ] && check "open prints a nonce" 0 || check "open prints a nonce" 1
( cd "$WORK" && ./harness review record FT9 --nonce "$NONCE" --verdict clean >/dev/null 2>&1 )
STATE="$( cd "$WORK" && ./harness review status FT9 --json 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['state'])" )"
[ "$STATE" = "CURRENT" ] && check "status is CURRENT after record" 0 || check "status is CURRENT after record (got $STATE)" 1

# --- Part A3: in-progress + CURRENT provenance -> silent again ------------------------------
A3="$(run_hook)"
[ -z "$A3" ] && check "silent when provenance is CURRENT" 0 || check "silent when provenance is CURRENT" 1

# hook always exits 0 (advisory)
( cd "$WORK" && bash "$HOOK" >/dev/null 2>&1 ); check "hook exits 0 (advisory)" $?

echo "test-subagent-provenance: $pass passed, fail=$fail"
exit $fail
