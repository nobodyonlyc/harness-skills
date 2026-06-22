#!/usr/bin/env bash
# Block verify if evidence.md ## Review section is a placeholder. Runs after quality-gate. PreToolUse(Bash).
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) verify' || exit 0
echo "$COMMAND" | grep -q -- '--override-snapshot' && exit 0

FEATURE_ID=$(echo "$COMMAND" | sed -E 's/.*(harness) verify[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
{ [ -z "$FEATURE_ID" ] || [ "$FEATURE_ID" = "$COMMAND" ]; } && exit 0

EVIDENCE="docs/design-docs/${FEATURE_ID}/evidence.md"
[ -f "$EVIDENCE" ] || exit 0

REVIEW_CONTENT=$(awk '/^## [Rr]eview/,/^## [^R]/' "$EVIDENCE" 2>/dev/null | grep -v '^##')
REVIEW_LEN=$(echo "$REVIEW_CONTENT" | tr -d '[:space:]' | wc -c | tr -d ' ')
if [ "${REVIEW_LEN:-0}" -lt 30 ]; then
  echo "REVIEW GATE [${FEATURE_ID}]: ## Review section is too sparse (${REVIEW_LEN} chars)." >&2
  exit 1
fi
if echo "$REVIEW_CONTENT" | grep -qi "TODO\|FILL IN\|placeholder\|N/A$"; then
  echo "REVIEW GATE [${FEATURE_ID}]: ## Review section still contains placeholder text." >&2
  exit 1
fi
exit 0
