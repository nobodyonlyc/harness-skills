#!/usr/bin/env bash
# Block `harness verify <id>` if any recorded test-type verdict is not green.
# A verdict line like "- unit: PASS …" / "- integration: FAIL …" under ## Test must read PASS for
# every test type the agent recorded (unit/integration/regression/e2e/performance/security). You
# cannot verify a feature whose own evidence records a failing or unfinished test tier.
# Event: PreToolUse(Bash). Exit 0 = allow, Exit 1 = block.
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) verify' || exit 0
echo "$COMMAND" | grep -q -- '--override-snapshot' && exit 0

FEATURE_ID=$(echo "$COMMAND" | sed -E 's/.*(harness) verify[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
{ [ -z "$FEATURE_ID" ] || [ "$FEATURE_ID" = "$COMMAND" ]; } && exit 0

EVIDENCE="docs/design-docs/${FEATURE_ID}/evidence.md"
[ -f "$EVIDENCE" ] || exit 0

# For each recorded "<type>: <status> …" verdict line, the first word after the colon is the status.
BAD=$(grep -iE '^[-*[:space:]]*(unit|integration|regression|e2e|performance|security):' "$EVIDENCE" 2>/dev/null \
  | sed -E 's/^[-*[:space:]]*([a-zA-Z0-9]+):[[:space:]]*([A-Za-z]+).*/\1 \2/' \
  | awk '{ s=toupper($2); if (s=="FAIL"||s=="FAILED"||s=="FAILING"||s=="PENDING"||s=="TODO"||s=="SKIP"||s=="SKIPPED"||s=="WIP"||s=="FIXME"||s=="RED") print $1 }')

if [ -n "$BAD" ]; then
  echo "TEST-TYPE GATE [${FEATURE_ID}]: recorded test verdict(s) not green: $(echo "$BAD" | tr '\n' ' ')." >&2
  echo "  Every '<type>:' line in evidence ## Test must read PASS before verify. Fix the tests, don't relax the record." >&2
  exit 1
fi
exit 0
