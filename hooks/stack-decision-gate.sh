#!/usr/bin/env bash
# gate-audit: mechanical — reads architecture.md + stack-versions.md; blocks.
# Block `harness verify <id>` if docs/design/architecture.md exists but the stack is not properly
# researched: (a) a complete machine-readable `## Stack` block (language + pinned version + LTS
# marker), and (b) the dedicated artifact docs/design/stack-versions.md citing a fetched source URL
# + version (proof the versions were web-researched via design-stack-research, not recalled).
# Enforces design-architecture + design-stack-research + stack-defaults.md.
# Event: PreToolUse(Bash). 0=allow, 1=block.
COMMAND="${CLAUDE_TOOL_INPUT_COMMAND:-${TOOL_CALL_INPUT:-$*}}"

echo "$COMMAND" | grep -qE '(\./harness|harness) verify' || exit 0
echo "$COMMAND" | grep -q -- '--override-snapshot' && exit 0

FEATURE_ID=$(echo "$COMMAND" | sed -E 's/.*(harness) verify[[:space:]]+(--[a-z-]+[[:space:]]+)*([A-Za-z0-9_-]+).*/\3/')
{ [ -z "$FEATURE_ID" ] || [ "$FEATURE_ID" = "$COMMAND" ]; } && exit 0

ARCH="docs/design/architecture.md"
# Only enforce once an architecture doc exists (i.e. a stack was meant to be decided).
[ -f "$ARCH" ] || exit 0

# Dedicated research artifact: docs/design/stack-versions.md must exist and carry a real fetched
# source URL + a pinned version — proof the versions were web-researched (design-stack-research),
# not recalled. A text marker in the Stack block can be faked; a cited source URL is the evidence.
SV="docs/design/stack-versions.md"
if [ ! -f "$SV" ]; then
  echo "STACK GATE [${FEATURE_ID}]: missing ${SV} — run design-stack-research to web-research and record each version." >&2
  echo "  Versions must be fetched from the official source, not recalled (stack-defaults.md Rule 0)." >&2
  exit 1
fi
if ! grep -qE 'https?://' "$SV"; then
  echo "STACK GATE [${FEATURE_ID}]: ${SV} cites no source URL — record the official URL you fetched per technology." >&2
  exit 1
fi
if ! grep -qE '[0-9]+(\.[0-9x]+)?' "$SV"; then
  echo "STACK GATE [${FEATURE_ID}]: ${SV} has no pinned version — record the researched latest LTS/stable." >&2
  exit 1
fi

# Extract the "## Stack" section (heading line through the next "## " heading).
STACK=$(awk '
  /^##[[:space:]]+[Ss]tack/ { grab=1; next }
  grab && /^##[[:space:]]/   { grab=0 }
  grab                       { print }
' "$ARCH" 2>/dev/null)

if [ -z "$(echo "$STACK" | tr -d '[:space:]')" ]; then
  echo "STACK GATE [${FEATURE_ID}]: ${ARCH} has no machine-readable '## Stack' block." >&2
  echo "  Add a '## Stack (machine-readable)' block (see resources/stack-defaults.md Rule 3)." >&2
  exit 1
fi

if ! echo "$STACK" | grep -qiE '^[-*[:space:]]*language:'; then
  echo "STACK GATE [${FEATURE_ID}]: Stack block missing a 'language:' line." >&2
  exit 1
fi

# At least one pinned version (a concrete number such as 22, 22.x, 17.4).
if ! echo "$STACK" | grep -qE '[0-9]+(\.[0-9x]+)?'; then
  echo "STACK GATE [${FEATURE_ID}]: Stack block has no pinned version — research and pin the latest LTS." >&2
  exit 1
fi

# Proof the version was researched, not recalled.
if ! echo "$STACK" | grep -qiE 'lts|as of|verified|current stable'; then
  echo "STACK GATE [${FEATURE_ID}]: Stack block lacks an LTS/research marker (e.g. 'LTS', 'as of <date>', 'verified')." >&2
  echo "  Per stack-defaults.md Rule 0, pin the researched latest LTS and record version + date + source." >&2
  exit 1
fi

# No leftover placeholders.
if echo "$STACK" | grep -qiE '\bTBD\b|\bTODO\b|\bFILL\b|<[a-z][a-z -]*>'; then
  echo "STACK GATE [${FEATURE_ID}]: Stack block still contains placeholders (TBD/TODO/FILL/<…>)." >&2
  exit 1
fi
exit 0
