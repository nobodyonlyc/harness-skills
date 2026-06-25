#!/usr/bin/env bash
# gate-audit: mechanical — reads .harness/context.json (user_role); blocks in HARD mode.
# Nudge to set user_role (Developer/Non-Technical) before starting a feature, so persona-driven
# behavior is active. Event: PreToolUse(Bash). Soft by default (exit 0); HARNESS_PERSONA_HARD=1 to block.
# See resources/persona-mode.md.
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) start' || exit 0

CONTEXT_FILE=".harness/context.json"
ROLE=""
[ -f "$CONTEXT_FILE" ] && ROLE=$(python3 -c "
import json
try:
    print(json.load(open('$CONTEXT_FILE')).get('user_role',''))
except Exception:
    print('')
" 2>/dev/null)

if [ -z "$ROLE" ]; then
  echo "PERSONA GATE: user_role is not set. Run: ./harness config set user_role Developer (or Non-Technical)" >&2
  echo "  Persona controls question depth + language (resources/persona-mode.md)." >&2
  [ "${HARNESS_PERSONA_HARD:-0}" = "1" ] && exit 1
fi
exit 0
