#!/usr/bin/env bash
# gate-audit: mechanical — reads docs/design-docs/<id>/plan.md (presence/content); blocks.
# Block `harness start <id>` if plan.md is missing or still a template. Event: PreToolUse(Bash).
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) start' || exit 0
echo "$COMMAND" | grep -q -- '--force' && exit 0

FEATURE_ID=$(echo "$COMMAND" | sed -E 's/.*(harness) start[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
{ [ -z "$FEATURE_ID" ] || [ "$FEATURE_ID" = "$COMMAND" ]; } && exit 0

PLAN="docs/design-docs/${FEATURE_ID}/plan.md"
if [ ! -f "$PLAN" ]; then
  echo "PHASE GUARD [${FEATURE_ID}]: plan.md not found. Run: ./harness plan ${FEATURE_ID}" >&2
  exit 1
fi
if grep -qE '<!-- (TODO|FILL|REPLACE)' "$PLAN" 2>/dev/null; then
  echo "PHASE GUARD [${FEATURE_ID}]: plan.md still has unfilled template sections." >&2
  exit 1
fi
CONTENT_LEN=$(grep -v '^#\|^---\|^$' "$PLAN" 2>/dev/null | tr -d '[:space:]' | wc -c | tr -d ' ')
if [ "${CONTENT_LEN:-0}" -lt 50 ]; then
  echo "PHASE GUARD [${FEATURE_ID}]: plan.md appears empty (${CONTENT_LEN} chars)." >&2
  exit 1
fi
exit 0
