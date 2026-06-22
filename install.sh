#!/usr/bin/env bash
# Wire harness-skills into a consuming project for each detected agent.
#
# This is the F01 SKELETON. Real per-agent projection lands in F11 (skills/workflows)
# and F12 (hooks + config-templates). The references to `.claude/skills` and
# `.agent/workflows` below are intentional anchors so later features can flesh them out.
set -euo pipefail

# Resolve the directory this script lives in (the submodule root) and the project root.
SKILLS_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git -C "$SKILLS_SRC/.." rev-parse --show-toplevel 2>/dev/null || cd "$SKILLS_SRC/../.." && pwd)"

echo "==> harness-skills install"
echo "    source : $SKILLS_SRC"
echo "    project: $PROJECT_ROOT"

# Ensure the nested caveman submodule is present.
if [ ! -e "$SKILLS_SRC/vendor/caveman/.git" ] && [ ! -f "$SKILLS_SRC/vendor/caveman/SKILL.md" ]; then
  echo "==> pulling nested submodules (vendor/caveman) ..."
  git -C "$SKILLS_SRC" submodule update --init --recursive || \
    echo "    WARN: could not init vendor/caveman (run: git submodule update --init --recursive)"
fi

# --- Claude Code: symlink .claude/skills -> skills-src/skills  (fleshed out in F11) ---
wire_claude_code() {
  echo "==> [skeleton] Claude Code: would symlink .claude/skills -> $SKILLS_SRC/skills"
}

# --- Antigravity: generate .agent/workflows/harness-* adapters  (fleshed out in F11) ---
wire_antigravity() {
  echo "==> [skeleton] Antigravity: would generate .agent/workflows/harness-* adapters"
}

# --- Codex: path-based, no projection needed ---
wire_codex() {
  echo "==> [skeleton] Codex: path-based, reads $SKILLS_SRC/skills/<name>/SKILL.md"
}

# --- Hooks: merge config-templates into per-agent settings  (fleshed out in F12) ---
wire_hooks() {
  echo "==> [skeleton] Hooks: would wire $SKILLS_SRC/hooks/*.sh via config-templates/"
}

wire_claude_code
wire_antigravity
wire_codex
wire_hooks

echo "==> done (skeleton). Real wiring is implemented in F11/F12."
