#!/usr/bin/env bash
# FROZEN verification for F52 — the design-derived role-resolver.
#
# Asserts: a known stack yields the right archetype + title + expertise chain (derived from the
# design via experts-resolver); each phase maps to its archetype; output is valid JSON; an unknown
# phase fails loud; and an unresolved stack degrades to a valid, non-blocking generic spec.
#
# Usage: bash scripts/test-role-resolver.sh   (exit 0 = pass)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
R="scripts/role-resolver.sh"
[ -f "$R" ] || { echo "test-role-resolver: missing $R" >&2; exit 1; }

fail=0
pass=0

# field "<desc>" "<json-key>" "<expected>" -- <role-resolver args...>
field() {
  local desc="$1" key="$2" expected="$3"; shift 3
  local got
  got="$(bash "$R" "$@" 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('$key'))" 2>/dev/null)"
  if [ "$got" = "$expected" ]; then
    pass=$((pass + 1))
  else
    echo "FAIL: $desc" >&2
    echo "  args    : $*" >&2
    echo "  key     : $key" >&2
    echo "  expected: $expected" >&2
    echo "  got     : $got" >&2
    fail=1
  fi
}

# expertise array, comma-joined, for exact-chain assertions
field_expertise() {
  local desc="$1" expected="$2"; shift 2
  local got
  got="$(bash "$R" "$@" 2>/dev/null | python3 -c "import json,sys; print(','.join(json.load(sys.stdin).get('expertise',[])))" 2>/dev/null)"
  if [ "$got" = "$expected" ]; then
    pass=$((pass + 1))
  else
    echo "FAIL: $desc" >&2
    echo "  args    : $*" >&2
    echo "  expected expertise: $expected" >&2
    echo "  got      expertise: $got" >&2
    fail=1
  fi
}

# --- 1. Go backend review → Go Backend Tech Lead, full design-derived chain ------------------
field "go/be review archetype" archetype "techlead" --phase review --language go --component be
field "go/be review title"     title     "Go Backend Tech Lead" --phase review --language go --component be
field "go/be review based_on"  based_on  "docs/design/architecture.md#stack" --phase review --language go --component be
field_expertise "go/be review chain" "dev-be,dev-go,golang-pro" --phase review --language go --component be

# --- 2. Phase → archetype mapping -----------------------------------------------------------
field "design phase archetype"   archetype "architect"         --phase design   --language go --component be
field "security phase archetype" archetype "security-reviewer" --phase security --language go --component be
field "qa phase archetype"       archetype "qa-engineer"       --phase qa       --language go --component be
field "code phase archetype"     archetype "implementer"       --phase code     --language go --component be

# --- 3. Another stack: python/django backend ------------------------------------------------
field "py/django review title" title "Python Backend Tech Lead" --phase review --language python --framework django --component be

# --- 4. Output is valid JSON ----------------------------------------------------------------
if bash "$R" --phase review --language go --component be 2>/dev/null | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
  pass=$((pass + 1))
else
  echo "FAIL: json output is not valid JSON" >&2; fail=1
fi

# --- 5. Unknown phase fails loud (exit 2) ---------------------------------------------------
if bash "$R" --phase bogus --language go --component be >/dev/null 2>&1; then
  echo "FAIL: unknown phase should exit non-zero" >&2; fail=1
else
  pass=$((pass + 1))
fi

# --- 6. Missing --phase fails loud ----------------------------------------------------------
if bash "$R" --language go --component be >/dev/null 2>&1; then
  echo "FAIL: missing --phase should exit non-zero" >&2; fail=1
else
  pass=$((pass + 1))
fi

# --- 7. Unresolved stack degrades (valid JSON, empty expertise, exit 0, based_on null) ------
# No --language/--framework and (most likely) no Stack block at CWD → experts-resolver yields
# nothing, but the role spec must still be valid and non-blocking.
if out="$(bash "$R" --phase review --stack /nonexistent/architecture.md 2>/dev/null)"; then
  exp="$(echo "$out" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d['expertise']), d['based_on'], d['archetype'])" 2>/dev/null)"
  if [ "$exp" = "0 None techlead" ]; then
    pass=$((pass + 1))
  else
    echo "FAIL: degraded spec wrong: got '$exp' (want '0 None techlead')" >&2; fail=1
  fi
else
  echo "FAIL: degraded (unresolved stack) should still exit 0" >&2; fail=1
fi

echo "test-role-resolver: $pass passed, fail=$fail"
exit $fail
