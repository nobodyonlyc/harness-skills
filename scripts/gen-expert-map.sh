#!/usr/bin/env bash
# Generate the expert-skills map from skill frontmatter — the SINGLE source of truth.
#
# Each harness skill that delegates craft to a vendored expert declares it in its
# SKILL.md frontmatter:
#     metadata:
#       layer: language        # component|language|design|test|review|workflow
#       tier: mechanical       # entry|judgment|mechanical
#       delegates:
#         - {language: go, to: golang-pro}
#         - {framework: django, label: "Django (Python)", to: django-expert}
#         - {trigger: "review depth", to: code-reviewer}
#
# This script reads every skills/*/SKILL.md, collects the delegate rows, and emits the
# GENERATED region of resources/expert-skills-map.md (tables + machine-checked fenced list).
#
# Usage:
#   gen-expert-map.sh            # print the generated region to stdout (used by lint to diff)
#   gen-expert-map.sh --write    # rewrite the region between the GENERATED sentinels in the map
#
# Exit 0 on success; non-zero on a parse/structure error.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec python3 - "$ROOT" "${1:-}" <<'PY'
import os, re, sys

root = sys.argv[1]
mode = sys.argv[2] if len(sys.argv) > 2 else ""
skills_dir = os.path.join(root, "skills")
map_path = os.path.join(root, "resources", "expert-skills-map.md")

START = "<!-- GENERATED:START — source of truth is skill frontmatter (metadata.delegates); run scripts/gen-expert-map.sh --write -->"
END = "<!-- GENERATED:END -->"

ITEM = re.compile(r"-\s*\{(.+?)\}\s*$")

def parse_frontmatter(text):
    """Return (metadata dict) for the YAML frontmatter; metadata['delegates'] is a list of dicts."""
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    fm = text[3:end].splitlines()
    meta = {}
    in_meta = False
    in_delegates = False
    delegates = []
    for line in fm:
        if re.match(r"^metadata:\s*$", line):
            in_meta = True
            continue
        if in_meta:
            # leave metadata block when a non-indented key appears
            if line and not line.startswith(" "):
                in_meta = False
                in_delegates = False
                continue
            m = re.match(r"^\s{2}(\w[\w-]*):\s*(.*)$", line)
            if m and not line.lstrip().startswith("-"):
                key, val = m.group(1), m.group(2).strip()
                if key == "delegates":
                    in_delegates = True
                    continue
                in_delegates = False
                meta[key] = val.strip('"').strip("'")
                continue
            if in_delegates:
                im = ITEM.search(line)
                if im:
                    pairs = {}
                    for chunk in im.group(1).split(","):
                        if ":" not in chunk:
                            continue
                        k, v = chunk.split(":", 1)
                        pairs[k.strip()] = v.strip().strip('"').strip("'")
                    delegates.append(pairs)
    if delegates:
        meta["delegates"] = delegates
    return meta

rows = []  # (table, skill, trigger_label, expert)
experts = set()
errors = []

for name in sorted(os.listdir(skills_dir)):
    sp = os.path.join(skills_dir, name, "SKILL.md")
    if not os.path.isfile(sp):
        continue
    with open(sp, encoding="utf-8") as f:
        meta = parse_frontmatter(f.read())
    for d in meta.get("delegates", []):
        to = d.get("to")
        if not to:
            errors.append(f"{name}: delegate entry without 'to:' -> {d}")
            continue
        if "language" in d:
            table, key = "lang", d["language"]
        elif "framework" in d:
            table, key = "fw", d["framework"]
        elif "trigger" in d:
            table, key = "tdd", d["trigger"]
        else:
            errors.append(f"{name}: delegate '{to}' needs one of language|framework|trigger -> {d}")
            continue
        label = d.get("label") or (key.capitalize() if table != "tdd" else key)
        rows.append((table, name, label, to))
        experts.add(to)

if errors:
    sys.stderr.write("gen-expert-map: frontmatter errors:\n  " + "\n  ".join(errors) + "\n")
    sys.exit(2)

def table(title, head, key):
    sel = sorted([r for r in rows if r[0] == key], key=lambda r: (r[1], r[2].lower(), r[3]))
    out = [f"### {title}", f"| Harness skill | {head} | Delegate to |", "|---|---|---|"]
    for _, skill, label, expert in sel:
        out.append(f"| `{skill}` | {label} | `{expert}` |")
    return "\n".join(out)

parts = []
parts.append(START)
parts.append("")
parts.append(table("Languages", "Language / stack", "lang"))
parts.append("")
parts.append(table("Web frameworks", "Framework / stack", "fw"))
parts.append("")
parts.append(table("Test / design / debug", "Trigger", "tdd"))
parts.append("")
parts.append("## Vendored experts (generated; machine-checked by scripts/lint-expert-map.sh)")
parts.append("Every name below resolves to `skills/<name>/SKILL.md`. This fenced block is the single")
parts.append("source the lint parses; it is generated from the `delegates` frontmatter above.")
parts.append("")
parts.append("```text")
parts.extend(sorted(experts))
parts.append("```")
parts.append(END)
region = "\n".join(parts) + "\n"

if mode == "--write":
    with open(map_path, encoding="utf-8") as f:
        doc = f.read()
    if START not in doc or END not in doc:
        sys.stderr.write(
            f"gen-expert-map: sentinels not found in {map_path}.\n"
            f"Add a region delimited by:\n  {START}\n  {END}\n")
        sys.exit(3)
    pre = doc[: doc.index(START)]
    post = doc[doc.index(END) + len(END):]
    with open(map_path, "w", encoding="utf-8") as f:
        f.write(pre + region + post.lstrip("\n"))
    sys.stderr.write(f"gen-expert-map: wrote region ({len(experts)} experts, {len(rows)} rows)\n")
else:
    sys.stdout.write(region)
PY
