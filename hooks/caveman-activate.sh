#!/usr/bin/env bash
# Standing rule: caveman is ON by default for inter-agent prompts + subagent results in every
# workflow. This hook activates it at session start — records caveman_mode:on in context.json and
# injects the directive. Event: SessionStart. Soft (exit 0). See resources/token-budget.md.
#
# NOTE: a hook cannot verify the model actually compressed a prompt; it sets the flag and states the
# rule. The skills (token-budget.md + workflow-*) carry the portable rule for every agent.
CONTEXT_FILE=".harness/context.json"

# Merge-safe write of caveman_mode:on (preserve any other keys); create the file if absent.
python3 - "$CONTEXT_FILE" <<'PY' 2>/dev/null || true
import json, sys, os
path = sys.argv[1]
data = {}
if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f) or {}
    except Exception:
        data = {}
if data.get("caveman_mode") != "on":
    data["caveman_mode"] = "on"
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
PY

echo "CAVEMAN RULE: on by default — apply opt-caveman to inter-agent prompts + subagent results (lite). NOT to user-facing output or reasoning, never where it weakens a gate. See resources/token-budget.md." >&2
exit 0
