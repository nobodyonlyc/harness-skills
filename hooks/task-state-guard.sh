#!/usr/bin/env bash
# Backstop for the task-state convention (resources/task-state.md). SOFT (exit 0).
# - PreToolUse(Bash) on `harness verify <id>`: warn if the task-state still shows implementation/tests
#   not ticked (the agent likely forgot to update it).
# - Stop: warn for any in_progress feature whose task-state has made no progress since `start`
#   (no [x] and no [/]).
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"
TASKS_DIR=".harness/tasks"
FEATURES=".harness/features.json"

warn_verify() {
  local id="$1"
  local f="$TASKS_DIR/$id.md"
  [ -f "$f" ] || return 0
  if grep -qiE '^- \[ \].*(implementation|tests|review)' "$f"; then
    echo "TASK-STATE GUARD [$id]: verifying, but $f still has unticked implementation/tests/review boxes." >&2
    echo "  Update .harness/tasks/$id.md to reflect real progress (resources/task-state.md)." >&2
  fi
}

# --- verify path ---
if echo "$COMMAND" | grep -qE '(\./harness|harness) verify'; then
  ID=$(echo "$COMMAND" | sed -E 's/.*(harness) verify[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
  [ -n "$ID" ] && [ "$ID" != "$COMMAND" ] && warn_verify "$ID"
  exit 0
fi

# --- Stop path: only when not a harness command (i.e. end-of-turn) ---
if [ -z "$COMMAND" ] && [ -f "$FEATURES" ]; then
  IDS=$(jq -r '.features[]? | select(.status == "in_progress") | .id' "$FEATURES" 2>/dev/null)
  for id in $IDS; do
    f="$TASKS_DIR/$id.md"
    [ -f "$f" ] || continue
    if ! grep -qE '^- \[(x|/)\]' "$f"; then
      echo "TASK-STATE GUARD [$id]: $f shows no progress since start (no [x]/[/]). Update it at each phase boundary." >&2
    fi
  done
fi
exit 0
