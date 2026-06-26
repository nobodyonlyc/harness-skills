#!/usr/bin/env bash
# FROZEN verification for F53 — the review-provenance enforcement gate.
#
# Builds a throwaway harness project (real binary + git repo), then asserts the hook's exit code:
#   non-verify command            -> allow (0)
#   verify, no provenance (NONE)  -> block (1)
#   verify, after open+record     -> allow (0)   [state CURRENT]
#   verify, after a tracked edit  -> block (1)   [state STALE]
#   verify --override-snapshot    -> allow (0)   [explicit bypass]
#   no harness binary reachable   -> allow (0)   [fail-open, never false-block]
#
# Usage: bash scripts/test-review-provenance-gate.sh   (exit 0 = pass)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/hooks/review-provenance-gate.sh"
[ -f "$HOOK" ] || { echo "test-review-provenance-gate: missing $HOOK" >&2; exit 1; }

# Locate a harness binary that supports the `review` subcommand.
BIN=""
for c in "$ROOT/../../harness" "$(command -v harness 2>/dev/null || true)"; do
  [ -n "$c" ] && [ -x "$c" ] || continue
  if "$c" review --help >/dev/null 2>&1; then
    BIN="$(cd "$(dirname "$c")" && pwd)/$(basename "$c")"; break
  fi
done
[ -n "$BIN" ] || { echo "test-review-provenance-gate: no harness binary with 'review' found" >&2; exit 1; }

fail=0
pass=0
check() { # <desc> <expected-rc> <actual-rc>
  if [ "$2" -eq "$3" ]; then pass=$((pass + 1)); else
    echo "FAIL: $1 (expected rc=$2, got rc=$3)" >&2; fail=1
  fi
}

WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

(
  cd "$WORK"
  git init -q
  git config user.email "t@t.dev"; git config user.name "Gate Test"
  echo "seed" > seed.txt
  git add -A && git commit -qm init
  cp "$BIN" ./harness
  ./harness init --bare >/dev/null 2>&1
  ./harness add FT1 "gate test" --priority 1 --behavior "x" --verifications "unit:true" >/dev/null 2>&1
)

# run the hook from inside WORK so it finds ./harness; capture rc
run() { ( cd "$WORK" && CLAUDE_TOOL_INPUT_COMMAND="$1" bash "$HOOK" >/dev/null 2>&1; echo $? ); }

# 1. non-verify command -> allow
check "non-verify command allowed" 0 "$(run 'harness status')"

# 2. verify with no provenance -> block
check "verify with NONE provenance blocked" 1 "$(run 'harness verify FT1')"

# 3. open + record -> CURRENT -> allow
OUT="$(cd "$WORK" && ./harness review open FT1 --phase review --role '{"archetype":"techlead"}' 2>&1)"
NONCE="$(printf '%s' "$OUT" | awk -F': ' '/nonce/{gsub(/ /,"",$2);print $2; exit}')"
( cd "$WORK" && ./harness review record FT1 --nonce "$NONCE" --verdict clean >/dev/null 2>&1 )
check "verify with CURRENT provenance allowed" 0 "$(run 'harness verify FT1')"

# 4. modify a tracked file -> STALE -> block
( cd "$WORK" && echo "post-review change" >> seed.txt )
check "verify with STALE provenance blocked" 1 "$(run 'harness verify FT1')"

# 5. --override-snapshot bypass -> allow (even though STALE)
check "override-snapshot bypass allowed" 0 "$(run 'harness verify FT1 --override-snapshot')"

# 6. fail-open: no harness binary reachable -> allow
EMPTY="$(mktemp -d)"
RC="$( cd "$EMPTY" && PATH="/usr/bin:/bin" CLAUDE_PROJECT_DIR="/nonexistent" \
        CLAUDE_TOOL_INPUT_COMMAND="harness verify FT1" bash "$HOOK" >/dev/null 2>&1; echo $? )"
rm -rf "$EMPTY"
check "fail-open when no binary reachable" 0 "$RC"

echo "test-review-provenance-gate: $pass passed, fail=$fail"
exit $fail
