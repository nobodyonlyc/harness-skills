#!/usr/bin/env bash
# Block dangerous git operations on protected branches. Event: PreToolUse(Bash).
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

if echo "$COMMAND" | grep -qE 'git push.*(--force(-with-lease)?|[[:space:]]-f\b)'; then
  # Block when the protected branch is named explicitly (e.g. `git push -f origin master`),
  # OR when no branch is given — `git push -f` pushes the CURRENT branch, so resolve it.
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
  if echo "$COMMAND" | grep -qE '\b(main|master)\b' || \
     echo "$CURRENT_BRANCH" | grep -qE '^(main|master)$'; then
    echo "BLOCKED: force-push to main/master is not allowed (current branch: ${CURRENT_BRANCH:-unknown})." >&2
    exit 1
  fi
fi

if echo "$COMMAND" | grep -qE 'git reset --hard'; then
  echo "WARNING: git reset --hard discards uncommitted changes." >&2
fi
exit 0
