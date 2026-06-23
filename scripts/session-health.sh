#!/usr/bin/env bash
# Quick session-health readout: is caveman compression active for this project, and how close is the
# context to the budget thresholds? Run from the project root:
#   bash .harness/skills-src/scripts/session-health.sh
set -uo pipefail

CTX=".harness/context.json"
TRACE=".harness/trace.md"

CAV="off"; WARN=150000; HARD=""
if [ -f "$CTX" ]; then
  vals="$(python3 -c "
import json
try: c=json.load(open('$CTX'))
except Exception: c={}
w=int(c.get('context_warn_threshold',150000))
print(c.get('caveman_mode','off'), w, c.get('context_hard_threshold', w*3//2))
" 2>/dev/null)"
  [ -n "$vals" ] && read -r CAV WARN HARD <<<"$vals"
fi

TOKENS=0
if [ -f "$TRACE" ]; then
  TOKENS=$(grep -oE 'tokens=[0-9]+' "$TRACE" 2>/dev/null | tail -1 | grep -oE '[0-9]+' | head -1)
fi
TOKENS="${TOKENS:-0}"

echo "== session health =="
echo "Caveman compression : ${CAV:-off}"
if [ "${CAV:-off}" != "on" ]; then
  echo "    not active — the SessionStart/PreInvocation activation hook did not run"
  echo "    (or is not wired for this host). caveman only compresses inter-agent prompts in workflows."
fi
echo "Context (last trace): ~${TOKENS} tokens   warn=${WARN:-?}   critical=${HARD:-?}"
if [ "${TOKENS}" -gt "${HARD:-225000}" ] 2>/dev/null; then
  echo "    OVER CRITICAL — start a fresh session: ./harness session stop && commit, then resume new."
elif [ "${TOKENS}" -gt "${WARN:-150000}" ] 2>/dev/null; then
  echo "    over warn threshold — checkpoint soon."
fi
echo "Tip: log exact usage with  ./harness trace --skill <n> --purpose <p> --result 'tokens=<N>'"
