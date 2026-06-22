#!/usr/bin/env bash
# Block dangerous git operations on protected branches. Event: PreToolUse(Bash).
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

if echo "$COMMAND" | grep -qE 'git push.*(--force|-f)\b'; then
  if echo "$COMMAND" | grep -qE '\b(main|master)\b'; then
    echo "BLOCKED: force-push to main/master is not allowed." >&2
    exit 1
  fi
fi

if echo "$COMMAND" | grep -qE 'git reset --hard'; then
  echo "WARNING: git reset --hard discards uncommitted changes." >&2
fi
exit 0
