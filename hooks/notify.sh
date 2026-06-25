#!/usr/bin/env bash
# gate-audit: advisory — desktop/terminal notification; no pass/fail decision.
# Desktop/terminal notification when the agent finishes a turn. Event: Stop.
MESSAGE="${CLAUDE_NOTIFICATION_MESSAGE:-Claude finished}"
printf "\a"
if command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\"" 2>/dev/null
  exit 0
fi
if command -v notify-send >/dev/null 2>&1; then
  notify-send "Claude Code" "$MESSAGE" --icon=terminal 2>/dev/null
fi
exit 0
