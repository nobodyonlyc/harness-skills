#!/usr/bin/env bash
# role-resolver — the design-derived ROLE SPEC for the subagent a lifecycle phase must spawn.
#
# A reviewer must not be a generic blob: phase=review on a Go backend should spawn a "Go Backend
# Tech Lead", phase=security a "Security Reviewer", etc. The *expertise* is DERIVED FROM THE DESIGN
# — this wraps experts-resolver.sh, which reads the machine-readable Stack block — so the role is a
# table lookup over the design, not a model's guess.
#
# Inputs:
#   --phase <p>        design | review | security | qa | code        (required)
#   --language <k>     passthrough to experts-resolver (e.g. go)     (optional)
#   --framework <k>    passthrough (e.g. react, django)              (optional)
#   --component <c>    be|fe|cli|db|batch                            (optional)
#   --stack <path>     Stack block file (default docs/design/architecture.md)
#   --format <fmt>     json (default) | brief
#
# Output (json): a role spec object {phase, archetype, title, language, component, base_skill,
#   expertise[], mandate, based_on, independent}. Exit 2 on an unknown phase / bad args.
# A stack that does not resolve is NON-FATAL: a valid spec with expertise:[] is emitted (exit 0) so
# spawning never blocks (agent-tool-mapping: missing capability uses a fallback, never blocks).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLVER="$HERE/experts-resolver.sh"

PHASE="" FMT="json"
PASS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --phase)    PHASE="${2:-}"; shift 2 ;;
    --format)   FMT="${2:-}"; shift 2 ;;
    --language|--framework|--component|--stack)
                PASS+=("$1" "${2:-}"); shift 2 ;;
    -h|--help)  sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "role-resolver: unknown argument '$1'" >&2; exit 2 ;;
  esac
done
[ -n "$PHASE" ] || { echo "role-resolver: --phase is required" >&2; exit 2; }

# Resolve the expertise chain from the design. Non-fatal on failure (degraded role spec).
TABLE="$(bash "$RESOLVER" "${PASS[@]}" --format table 2>/dev/null || true)"

PHASE="$PHASE" FMT="$FMT" TABLE="$TABLE" python3 <<'PY'
import os, json, sys

phase = os.environ["PHASE"].strip().lower()
fmt = os.environ["FMT"].strip().lower()
table = os.environ.get("TABLE", "")

# phase -> (archetype, archetype_human, mandate, base_skill)
# SOURCE OF TRUTH for the phase->role mapping; resources/phase-roles.md documents this table.
PHASE_ROLES = {
    "design":   ("architect", "Architect",
                 "Review the architecture/design for soundness, boundaries, scalability, and "
                 "trade-offs; challenge weak choices rather than rubber-stamp.",
                 "design-architecture"),
    "review":   ("techlead", "Tech Lead",
                 "Apply the check-code-review dimensions (correctness, security, contract, scope, "
                 "clarity). Try to find problems; do not approve by default.",
                 "check-code-review"),
    "security": ("security-reviewer", "Security Reviewer",
                 "Audit for auth/authz, injection, secrets, data exposure, deserialization, and "
                 "dependency risk (check-security-review).",
                 "check-security-review"),
    "qa":       ("qa-engineer", "QA Engineer",
                 "Run the selected test set and reproduce each failure with a test before fixing "
                 "(check-qa).",
                 "check-qa"),
    "code":     ("implementer", "Implementer",
                 "Implement per the design following the expert chain; the expert never replaces a "
                 "quality gate.",
                 "dev-be"),
}
if phase not in PHASE_ROLES:
    sys.stderr.write(f"role-resolver: unknown --phase '{phase}'. Known: {sorted(PHASE_ROLES)}\n")
    sys.exit(2)
archetype, archetype_h, mandate, base_skill = PHASE_ROLES[phase]

# Parse the experts-resolver table: role<TAB>name<TAB>path  (skip '#' comment/note lines).
chain = {}
expertise = []
for line in table.splitlines():
    if not line or line.startswith("#"):
        continue
    parts = line.split("\t")
    if len(parts) >= 2:
        role, name = parts[0], parts[1]
        chain[role] = name
        expertise.append(name)

COMPONENT_H = {"dev-be": "Backend", "dev-fe": "Frontend", "dev-cli": "CLI",
               "dev-db": "Database", "dev-batch": "Batch"}
LANG_H = {"dev-go": "Go", "dev-python": "Python", "dev-rust": "Rust", "dev-js-ts": "TypeScript"}

component = chain.get("component", "")
wrapper = chain.get("language", "")
language_h = LANG_H.get(wrapper, "")
component_h = COMPONENT_H.get(component, "")

# Title: "<Language> <Component> <Archetype>" with empty parts dropped.
title = " ".join(p for p in [language_h, component_h, archetype_h] if p) or archetype_h

spec = {
    "phase": phase,
    "archetype": archetype,
    "title": title,
    "language": language_h or None,
    "component": component or None,
    "base_skill": base_skill,
    "expertise": expertise,            # skill chain to load, in order (component -> language -> expert)
    "mandate": mandate,
    "based_on": "docs/design/architecture.md#stack" if expertise else None,
    "independent": True,               # the reviewer must not be the author
}

if fmt == "brief":
    exp = ", ".join(expertise) if expertise else "(generic — stack unresolved)"
    print(f"{title} [{archetype}] — expertise: {exp}")
    print(f"  mandate: {mandate}")
else:
    print(json.dumps(spec, indent=2))
PY
