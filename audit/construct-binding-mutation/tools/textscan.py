#!/usr/bin/env python3
"""textscan.py -- an independent, textual cross-check of census.tcl
(CONSTRUCT-BINDING-MUTATION-CENSUS-1.md, section 11): every name a construct
binds -- a loop variable, a lockstep variable, a fold intermediate, a
handler's payload or pattern fields, a destructuring statement's fields --
and every line of that construct's block where the name is the destination
of a mutation: NAME[.FIELD...].OP( for a mutating operation, the
std:: function spelling with NAME first, or NAME[.FIELD...] as an argument
of a function some file of the repository declares with a `place`
parameter.

The generated bindings and this census's own corpus are left out, as
census.tcl leaves them out. It reads text only (no compiler), so it also
covers files the HIR census
could not compile standalone (modules of packages, other targets). It
over-approximates (a name shadowed in the block, a same-named function).

    python3 -I audit/construct-binding-mutation/tools/textscan.py [ROOT]
"""
import os, re, subprocess, sys

root = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
files = subprocess.run(["git", "-C", root, "ls-files", "*.bot"], capture_output=True, text=True).stdout.split()
files = [f for f in files if not f.startswith("generated/") and not f.startswith("tools/c-bindgen/fixture/expected/")
         and not f.startswith("audit/construct-binding-mutation/")]

OPS = r"(push|pop|take|swap|clear|set|copy|add|remove|reorder)"
# Functions declared with a place parameter, anywhere.
place_fns = set()
decl = re.compile(r"^\s*(?:private\s+)?(?:nomethod\s+)?fn\s+([A-Za-z_][\w?]*)\s*\((.*)")
for f in files:
    try:
        text = open(os.path.join(root, f), encoding="utf-8").read()
    except OSError:
        continue
    for line in text.split("\n"):
        m = decl.match(line)
        if m and re.search(r"(^|[(,]\s*)place\s+\w+\s*:", m.group(2)):
            place_fns.add(m.group(1))

binders = [
    ("loop-element", re.compile(r"\b(?:loop|fold)\s+(\w+)\s+in\b")),
    ("lockstep-element", re.compile(r"\band\s+(\w+)\s+in\b")),
    ("fold-intermediate", re.compile(r"\bwith\s+intermediate\s+(\w+)\b")),
    ("handler-payload", re.compile(r"^\s*on\s+[\w:]+\s+(\w+)\s*:\s*$")),
]
pattern_handler = re.compile(r"^\s*on\s+[\w:]+\s+\{([^}]*)\}\s*:\s*$")
pattern_stmt = re.compile(r"^\s*\{([^}]*)\}\s*=")

def indent(s):
    return len(s) - len(s.lstrip(" "))

def fields(spec):
    names = []
    for part in spec.split(","):
        part = part.strip()
        if not part:
            continue
        names.append(part.split(":")[-1].strip())
    return [n for n in names if re.fullmatch(r"\w+", n)]

hits = []
for f in files:
    try:
        lines = open(os.path.join(root, f), encoding="utf-8").read().split("\n")
    except OSError:
        continue
    for i, line in enumerate(lines):
        code = line.split("#", 1)[0] if not line.lstrip().startswith("#") else ""
        if not code.strip():
            continue
        bound = []
        for cat, rx in binders:
            for m in rx.finditer(code):
                bound.append((cat, m.group(1)))
        m = pattern_handler.match(code)
        if m:
            bound += [("destructured-field:handler", n) for n in fields(m.group(1))]
        m = pattern_stmt.match(code)
        stmt = bool(m)
        if m:
            bound += [("destructured-field:statement", n) for n in fields(m.group(1))]
        if not bound:
            continue
        base = indent(line)
        # The construct's block: the following lines indented deeper (for a
        # destructuring statement: the rest of its own block).
        j = i + 1
        while j < len(lines):
            l = lines[j]
            if l.strip() and not l.lstrip().startswith("#"):
                if stmt and indent(l) < base:
                    break
                if not stmt and indent(l) <= base:
                    break
            j += 1
        for cat, name in bound:
            n = re.escape(name)
            mut = re.compile(r"(?<![\w.])" + n + r"(?:\.\w+)*\." + OPS + r"\(")
            fnform = re.compile(r"std::mutable_(?:vector|array|map|set)::" + OPS + r"\(\s*" + n + r"\b")
            for k in range(i + 1, j):
                body = lines[k].split("#", 1)[0]
                found = mut.search(body) or fnform.search(body)
                if not found:
                    for c in re.finditer(r"(?<![\w.:])([A-Za-z_][\w?]*)\(([^()]*)", body):
                        if c.group(1) in place_fns and re.search(r"(^|,)\s*" + n + r"(\.\w+)*\s*(,|$)", c.group(2)):
                            found = c
                            break
                if found:
                    hits.append((f, k + 1, cat, name, lines[k].strip()))
for h in hits:
    print("%s:%d\t%s\t%s\t%s" % h)
print("files: %d, place functions: %d, sites: %d" % (len(files), len(place_fns), len(hits)), file=sys.stderr)
