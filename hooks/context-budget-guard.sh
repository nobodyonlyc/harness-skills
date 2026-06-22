#!/usr/bin/env bash
# Warn when token context approaches threshold. Event: Stop.
# Soft by default; set CONTEXT_GUARD_HARD=1 to block.
CONTEXT_FILE=".harness/context.json"
TRACE_FILE=".harness/trace.md"
[ -f "$CONTEXT_FILE" ] || exit 0

THRESHOLD=$(python3 -c "
import json
try:
    print(json.load(open('$CONTEXT_FILE')).get('context_warn_threshold', 150000))
except Exception:
    print(150000)
" 2>/dev/null || echo 150000)

LAST_TOKENS=0
if [ -f "$TRACE_FILE" ]; then
  LAST_TOKENS=$(grep -oE 'tokens=[0-9]+' "$TRACE_FILE" 2>/dev/null | tail -1 | grep -oE '[0-9]+' | head -1)
fi
LAST_TOKENS="${LAST_TOKENS:-0}"

if [ "$LAST_TOKENS" -gt "$THRESHOLD" ] 2>/dev/null; then
  echo "CONTEXT BUDGET: ~${LAST_TOKENS} tokens used (threshold ${THRESHOLD}). Checkpoint: ./harness session stop && commit && ./harness resume" >&2
  [ "${CONTEXT_GUARD_HARD:-0}" = "1" ] && exit 1
fi
exit 0
