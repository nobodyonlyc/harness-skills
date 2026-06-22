#!/usr/bin/env bash
# Backstop for the step-gate contract: when stopping with an in-progress feature, remind the agent
# to confirm with the user before advancing to the next step. Event: Stop. Soft (exit 0).
# The real gate lives in the skills (resources/step-gate.md); this is the belt-and-suspenders nudge.
FEATURES=".harness/features.json"
CONTEXT_FILE=".harness/context.json"
[ -f "$FEATURES" ] || exit 0

IN_PROGRESS=$(jq '[.features[]? | select(.status == "in_progress")] | length' "$FEATURES" 2>/dev/null)
[ "${IN_PROGRESS:-0}" -gt 0 ] 2>/dev/null || exit 0

# In auto mode the gate is a logged decision, not a stop — stay quiet.
MODE=""
[ -f "$CONTEXT_FILE" ] && MODE=$(python3 -c "
import json
try:
    print(json.load(open('$CONTEXT_FILE')).get('autonomy_mode',''))
except Exception:
    print('')
" 2>/dev/null)
[ "$MODE" = "auto" ] && exit 0

echo "STEP GATE: confirm with the user before the next step (run next / run all / revise / stop)." >&2
echo "  See resources/step-gate.md." >&2
exit 0
