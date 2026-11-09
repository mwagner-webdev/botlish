#!/usr/bin/env python3
"""matrix.py -- the census's bounded table of element-type precision
(TEXT-AND-COLLECTION-PRECISION-CENSUS.md, section H).

    python3 -I audit/text-collection-precision/tools/matrix.py

For each element type it writes one program (in a private temporary
directory, removed afterwards) whose every operation feeds a probe
parameter of another type, runs `main.tcl -check`, and reads the type the
checker states for the argument ("argument type: T") out of each TYPE
diagnostic: the checker's own static type of that operation's result. It
prints a Markdown table, one row per operation and one column per type.

A second table reads the binding table of the same programs (bindings.tcl,
through the compiler service: what a hover shows): for every operation that
declares a loop clause binding, the type its declaration records
(LOOP-CLAUSE-BINDING-TYPE-CORRECTNESS-MILESTONE-1.md). Each must equal the
service's presentation and every type the checker gives its references,
and an element must be the checker's loop element type of the first table;
a counter is int. `List[int]{length: 2}` is a refined element (a declared
result keeps its length), `unknown` the negative control: an element the
checker itself knows only as `any` (encode_utf8 without std::byte loaded,
M3), which the record must not make more precise.
Exit status 1 when an operation produced no diagnostic or an unexpected one,
or a loop clause binding's record disagrees.
"""
import os, re, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# type -> (declarations, body of `fn mk(s: str)` making a List of it, probe
# parameter type[, mk's declared result])
TYPES = {
    "Byte": ("import std::byte\n", "s.encode_utf8()", "str"),
    "UnicodeChar": ("", "loop i from 0 to std::str::length(s):\n        std::str::char_at(s, i)", "str"),
    "Small": ("error Big\n\ntype Small = Int in 0..9\n\nfn small(n: int) -> Small errors Big:\n"
              "    if n < 0 or n > 9:\n        fail Big\n    n\n",
              "loop i from 0 to 3:\n        small(i):\n            on Big:\n                0", "str"),
    "int": ("", "loop i from 0 to std::str::length(s):\n        i", "str"),
    "Holder": ("struct Holder:\n    n: int\n", "loop i from 0 to std::str::length(s):\n        Holder {n: i}", "str"),
    "str": ("", "loop i from 0 to std::str::length(s):\n        std::str::substring(s, i, i + 1)", "int"),
    "List[int]{length: 2}": ("", "loop i from 0 to std::str::length(s):\n        [i, i]", "str",
                             "List[List[int]{length: 2}]"),
    "unknown": ("", "s.encode_utf8()", "str"),
}
FIELD = {"Byte": "std::byte::Byte", "unknown": "any"}

# operation -> (body over xs = mk(s), declares IndexNotFound)
OPS = [
    ("index", "    probe(xs.at(0))\n", True),
    ("loop element", "    loop x in xs:\n        probe(x)\n", False),
    ("collecting loop, element", "    ys = loop x in xs:\n        x\n    probe(ys.at(0))\n", True),
    ("collecting loop, result", "    ys = loop x in xs:\n        x\n    probe(ys)\n", False),
    ("fold intermediate", "    f = fold x in xs with intermediate acc xs.at(0):\n        x\n    probe(f)\n", True),
    ("std::list::flat, element", "    probe(std::list::flat([xs, xs]).at(0))\n", True),
    ("std::list::append, element", "    probe(xs.append(xs.at(0)).at(0))\n", True),
    ("undeclared result", "    probe(ret(xs))\n", False),
    ("imprinted result (List[T] -> T)", "    probe(first(xs))\n", True),
    ("struct field", "    probe(Box {items: xs}.items.at(0))\n", True),
    ("destructured field", "    {items} = Box {items: xs}\n    probe(items.at(0))\n", True),
    ("lockstep loop element", "    loop x in xs and i from 0 to std::list::length(xs):\n        probe(x)\n", False),
]


def program(tname):
    decls, mk, ptype = TYPES[tname][:3]
    result = f" -> {TYPES[tname][3]}" if len(TYPES[tname]) > 3 else ""
    parts = ["import std::str\nimport std::list\n", decls,
             f"\nfn probe(t: {ptype}) -> int:\n    1\n",
             f"\nfn mk(s: str){result}:\n    {mk}\n",
             "\nfn ret(xs):\n    xs\n",
             "\nfn first(xs: List[T]) -> T errors IndexNotFound:\n    xs.at(0)\n",
             f"\nstruct Box:\n    items: List[{FIELD.get(tname, tname)}]\n"]
    line = "".join(parts).count("\n")
    where = {}
    for op, body, errors in OPS:
        name = re.sub(r"[^a-z]+", "_", op)
        header = f"\nfn op_{name}(s: str){' errors IndexNotFound' if errors else ''}:\n    xs = mk(s)\n"
        start = line + header.count("\n") + 1
        parts.append(header + body)
        line += (header + body).count("\n")
        for k in range(start, line + 1):
            where[k] = op
    parts.append("\n1\n")
    return "".join(parts), where


def clause_bindings(path, where):
    """op -> [(name, recorded, service, refs)] of the loop clause bindings
    each operation's function declares (bindings.tcl)."""
    run = subprocess.run(["tclsh9.0", os.path.join(ROOT, "audit", "text-collection-precision", "tools", "bindings.tcl"), path],
                         capture_output=True, text=True,
                         env=dict(os.environ, LANG="C.utf8", LC_ALL="C.utf8"))
    found = {}
    for out in run.stdout.splitlines():
        line, name, kind, owner, clause, recorded, service, refs = (out.split("\t") + [""] * 8)[:8]
        op = where.get(int(line))
        if op is None or clause != "1":
            continue
        found.setdefault(op, []).append((name, recorded, service, [r for r in refs.split(" | ") if r]))
    return found


def unrefined(t):
    """T as a TYPE diagnostic spells it: without a List's length."""
    return re.sub(r"\{length: \d+\}", "", t)


def main():
    table, bad, bindings = {}, [], {}
    with tempfile.TemporaryDirectory(prefix="tcp-matrix-") as tmp:
        for tname in TYPES:
            text, where = program(tname)
            path = os.path.join(tmp, re.sub(r"[^A-Za-z0-9]+", "_", tname) + ".bot")
            with open(path, "w", encoding="utf-8") as f:
                f.write(text)
            run = subprocess.run(["tclsh9.0", os.path.join(ROOT, "main.tcl"), "-check", "-warnings", "off", path],
                                 capture_output=True, text=True,
                                 env=dict(os.environ, LANG="C.utf8", LC_ALL="C.utf8"))
            got = {}
            for out in run.stdout.splitlines():
                m = re.match(r"\s*error: [^:]+:(\d+):\d+: (.*)", out)
                if not m:
                    continue
                op = where.get(int(m.group(1)))
                t = re.search(r"argument type: (.*?)(?:, facts:.*)?\) \(CORE", m.group(2))
                if op is None or t is None:
                    bad.append(f"{tname}: unexpected diagnostic: {m.group(2)}")
                    continue
                got[op] = t.group(1)
            for op, _, _ in OPS:
                if op not in got:
                    bad.append(f"{tname}: {op}: no diagnostic")
            table[tname] = got
            found = clause_bindings(path, where)
            bindings[tname] = found
            element = got.get("loop element")
            for op, entries in found.items():
                for name, recorded, service, refs in entries:
                    if service != recorded:
                        bad.append(f"{tname}: {op}: {name} recorded {recorded}, presented {service}")
                    for r in refs:
                        if r != recorded:
                            bad.append(f"{tname}: {op}: {name} recorded {recorded}, a reference {r}")
                    expected = "int" if name == "i" else element
                    if unrefined(recorded) != expected:
                        bad.append(f"{tname}: {op}: {name} recorded {recorded}, the checker's {expected}")
    print("| operation | " + " | ".join(TYPES) + " |")
    print("|---|" + "---|" * len(TYPES))
    for op, _, _ in OPS:
        print(f"| {op} | " + " | ".join(f"`{table[t].get(op, '?')}`" for t in TYPES) + " |")
    print()
    print("| loop clause bindings: recorded type | " + " | ".join(TYPES) + " |")
    print("|---|" + "---|" * len(TYPES))
    for op, _, _ in OPS:
        if not any(op in bindings[t] for t in TYPES):
            continue
        cells = [", ".join(f"{n}: `{rec}`" for n, rec, _, _ in bindings[t].get(op, [])) or "?" for t in TYPES]
        print(f"| {op} | " + " | ".join(cells) + " |")
    for b in bad:
        print(b, file=sys.stderr)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
