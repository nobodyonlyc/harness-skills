#!/usr/bin/env bash
# Deterministic experts resolver — the lookup that backs a `harness experts` step.
#
# Given a stack (language + optional framework + component), print the EXACT skill chain to load:
#       component skill  ->  language wrapper  ->  vendored expert
# as skill NAMES (the cross-host contract) plus each name's relative skills/<name>/SKILL.md path
# (the FALLBACK for any host without name resolution). ZERO model judgment: resolution is a table
# lookup over the SAME single source of truth F46 established — the metadata.delegates frontmatter
# on the harness skills (read here exactly as scripts/gen-expert-map.sh reads it).
#
# Inputs (flags win; otherwise the Stack block is parsed):
#   --language <key>      e.g. go, python, typescript, java   (lowercased; matches a delegate key)
#   --framework <key>     e.g. django, react, spring-boot     (optional)
#   --component <c>       be|fe|cli|db|batch                  (optional; inferred from framework else dev-be)
#   --stack <path>        Stack block file to parse           (default docs/design/architecture.md)
#   --format <fmt>        table (default) | names             (names = one skill name per line, in order)
#
# Output (table format):
#   role <TAB> name <TAB> skills/<name>/SKILL.md
# Unknown language/framework -> non-zero exit with a clear message (fail loud, never guess).
#
# Usage:
#   experts-resolver.sh --language go --component be
#   experts-resolver.sh --language python --framework django --component be --format names
#   experts-resolver.sh --stack docs/design/architecture.md --component be
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec python3 - "$ROOT" "$@" <<'PY'
import os, re, sys

root = sys.argv[1]
argv = sys.argv[2:]
skills_dir = os.path.join(root, "skills")

# ---- argument parsing (no argparse dep on field names; explicit + deterministic) -----------
opts = {"language": None, "framework": None, "component": None,
        "stack": os.path.join(root, "docs", "design", "architecture.md"),
        "format": "table"}
# default stack path is relative to CWD, not skills-src root, when the caller passes one.
i = 0
while i < len(argv):
    a = argv[i]
    key = a[2:] if a.startswith("--") else None
    if key in opts and i + 1 < len(argv):
        opts[key] = argv[i + 1]
        i += 2
        continue
    sys.stderr.write(f"experts-resolver: unknown or malformed argument '{a}'\n")
    sys.exit(2)

ITEM = re.compile(r"-\s*\{(.+?)\}\s*$")

def parse_frontmatter(text):
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    meta = {}
    in_meta = in_delegates = False
    delegates = []
    for line in text[3:end].splitlines():
        if re.match(r"^metadata:\s*$", line):
            in_meta = True
            continue
        if in_meta:
            if line and not line.startswith(" "):
                in_meta = in_delegates = False
                continue
            m = re.match(r"^\s{2}(\w[\w-]*):\s*(.*)$", line)
            if m and not line.lstrip().startswith("-"):
                k, v = m.group(1), m.group(2).strip()
                if k == "delegates":
                    in_delegates = True
                    continue
                in_delegates = False
                meta[k] = v.strip('"').strip("'")
                continue
            if in_delegates:
                im = ITEM.search(line)
                if im:
                    pairs = {}
                    for chunk in im.group(1).split(","):
                        if ":" in chunk:
                            kk, vv = chunk.split(":", 1)
                            pairs[kk.strip()] = vv.strip().strip('"').strip("'")
                    delegates.append(pairs)
    if delegates:
        meta["delegates"] = delegates
    return meta

# ---- build the lookup index from frontmatter (single source of truth) ----------------------
# lang_wrappers[key]   -> wrapper skill name   (only layer: language skills)
# lang_expert[key]     -> expert name          (any skill that maps the language)
# fw_expert[key]       -> expert name
# fw_component[key]    -> owning component skill (dev-be / dev-fe)
lang_wrappers, lang_expert, fw_expert, fw_component = {}, {}, {}, {}
for name in sorted(os.listdir(skills_dir)):
    sp = os.path.join(skills_dir, name, "SKILL.md")
    if not os.path.isfile(sp):
        continue
    with open(sp, encoding="utf-8") as f:
        meta = parse_frontmatter(f.read())
    layer = meta.get("layer", "")
    for d in meta.get("delegates", []):
        to = d.get("to")
        if not to:
            continue
        if "language" in d:
            key = d["language"].lower()
            lang_expert.setdefault(key, to)
            if layer == "language":
                lang_wrappers.setdefault(key, name)
        elif "framework" in d:
            key = d["framework"].lower()
            fw_expert.setdefault(key, to)
            fw_component.setdefault(key, name)

# ---- normalization for fuzzy Stack-block values (flags are matched verbatim, lowercased) ---
ALIAS = {  # version-stripped, lowercased spellings that don't collapse to a delegate key
    "c#": "csharp", "c++": "cpp", "asp.net core": "aspnet", "aspnet core": "aspnet",
    ".net": "csharp", "node.js": "javascript", "nodejs": "javascript", "node": "javascript",
}

def strip_version(s):
    # drop tokens that look like versions ("15.x", "3.2", "v22", "8") and parentheticals
    s = re.sub(r"\([^)]*\)", " ", s)
    toks = [t for t in s.split() if not re.search(r"\d", t)]
    return " ".join(toks).strip()

def norm(s):
    return re.sub(r"[^a-z0-9]", "", s.lower())

def match_key(value, index):
    """Resolve a raw stack value to a delegate key present in `index`."""
    raw = value.strip().lower()
    raw = strip_version(raw)
    if raw in ALIAS:
        cand = ALIAS[raw]
        if cand in index:
            return cand
    if raw in index:           # exact (already a key)
        return raw
    nv = norm(raw)
    for key in index:          # normalized match against keys (sorted for determinism)
        if norm(key) == nv:
            return key
    return None

# ---- read inputs: flags win, else parse the Stack block ------------------------------------
language = opts["language"]
framework = opts["framework"]
notes = []

if (not language or not framework) and os.path.isfile(opts["stack"]):
    in_block = False
    with open(opts["stack"], encoding="utf-8") as f:
        for line in f:
            if re.match(r"^##\s+Stack\b", line):
                in_block = True
                continue
            if in_block:
                if line.startswith("## "):
                    break
                m = re.match(r"^-\s*language:\s*(.+)$", line)
                if m and not language:
                    language = m.group(1).strip()
                m = re.match(r"^-\s*framework:\s*(.+)$", line)
                if m and not framework:
                    framework = m.group(1).strip()

if not language and not framework:
    sys.stderr.write("experts-resolver: no language/framework given (flags or a Stack block "
                     f"at {opts['stack']}); nothing to resolve.\n")
    sys.exit(2)

# ---- resolve each input to a delegate key --------------------------------------------------
lang_key = None
if language:
    lang_key = language.strip().lower()
    if lang_key not in lang_expert and lang_key not in lang_wrappers:
        resolved = match_key(language, {**lang_expert, **lang_wrappers})
        if not resolved:
            sys.stderr.write(f"experts-resolver: language '{language}' is not in the map. "
                             "Run scripts/gen-expert-map.sh and add a delegate, or check spelling.\n")
            sys.exit(1)
        lang_key = resolved

fw_key = None
if framework:
    fw_key = framework.strip().lower()
    if fw_key not in fw_expert:
        resolved = match_key(framework, fw_expert)
        if not resolved:
            sys.stderr.write(f"experts-resolver: framework '{framework}' is not in the map. "
                             "Run scripts/gen-expert-map.sh and add a delegate, or check spelling.\n")
            sys.exit(1)
        fw_key = resolved

# ---- resolve the chain ---------------------------------------------------------------------
VALID_COMPONENTS = {"be", "fe", "cli", "db", "batch"}
if opts["component"]:
    c = opts["component"].strip().lower()
    if c not in VALID_COMPONENTS:
        sys.stderr.write(f"experts-resolver: --component '{c}' must be one of "
                         f"{sorted(VALID_COMPONENTS)}.\n")
        sys.exit(2)
    component = "dev-" + c
elif fw_key and fw_component.get(fw_key):
    component = fw_component[fw_key]          # inferred from the framework's owning skill
    notes.append(f"component inferred from framework '{fw_key}' -> {component}")
else:
    component = "dev-be"                       # default for a bare backend language
    notes.append("component defaulted to dev-be (no --component, no framework to infer from)")

wrapper = lang_wrappers.get(lang_key) if lang_key else None
expert = fw_expert.get(fw_key) if fw_key else (lang_expert.get(lang_key) if lang_key else None)

# ---- emit ----------------------------------------------------------------------------------
chain = [("component", component)]
if wrapper:
    chain.append(("language", wrapper))
if expert:
    chain.append(("expert", expert))

# every emitted name must resolve to a SKILL.md (fallback path is real)
for _, n in chain:
    if not os.path.isfile(os.path.join(skills_dir, n, "SKILL.md")):
        sys.stderr.write(f"experts-resolver: resolved skill '{n}' has no skills/{n}/SKILL.md\n")
        sys.exit(1)

if opts["format"] == "names":
    sys.stdout.write("\n".join(n for _, n in chain) + "\n")
    sys.exit(0)

out = ["# experts resolver — skill chain to load, in order",
       "# contract = NAME (load by name on CC/Codex/Antigravity); fallback = relative SKILL.md path"]
for note in notes:
    out.append(f"# note: {note}")
if lang_key and not wrapper:
    out.append(f"# note: language '{lang_key}' has no dedicated wrapper; expert runs under {component}")
for role, n in chain:
    out.append(f"{role}\t{n}\tskills/{n}/SKILL.md")
sys.stdout.write("\n".join(out) + "\n")
PY
