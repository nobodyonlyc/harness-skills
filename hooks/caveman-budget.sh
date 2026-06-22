#!/usr/bin/env bash
# Suggest enabling caveman compression for inter-agent prompts when token usage runs high.
# Event: Stop. Soft (exit 0). See resources/token-budget.md + vendor/caveman.
CONTEXT_FILE=".harness/context.json"
TRACE_FILE=".harness/trace.md"
[ -f "$TRACE_FILE" ] || exit 0

# Threshold for the nudge: half the context warning threshold (caveman is cheaper than checkpointing).
THRESHOLD=$(python3 -c "
import json
try:
    print(int(json.load(open('$CONTEXT_FILE')).get('context_warn_threshold', 150000)) // 2)
except Exception:
    print(75000)
" 2>/dev/null || echo 75000)

LAST_TOKENS=$(grep -oE 'tokens=[0-9]+' "$TRACE_FILE" 2>/dev/null | tail -1 | grep -oE '[0-9]+' | head -1)
LAST_TOKENS="${LAST_TOKENS:-0}"

if [ "$LAST_TOKENS" -gt "$THRESHOLD" ] 2>/dev/null; then
  echo "CAVEMAN BUDGET: ~${LAST_TOKENS} tokens. Consider /caveman for inter-agent prompts (resources/token-budget.md)." >&2
fi
exit 0
