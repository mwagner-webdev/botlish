#!/usr/bin/env python3
"""oracle.py -- an independent model of parameterized applications checked
exactly, for audit/applied-type-bound/tools/fuzz.tcl
(APPLIED-TYPE-BOUND-PRECISION-MILESTONE-1.md, "Oracle and fuzzing").

It shares no code with the compiler. Its language is small:

  type   ["atom", "int"|"str"] | ["any"] | ["var", SLOT] | ["list", TYPE]
         | ["app", NAME, [TYPE...]]
  decl   {"name": NAME, "slots": [SLOT...], "fields": [[FIELD, TYPE]...]}
         (a field's type mentions only the declaration's slots and earlier
         declarations: the declarations are acyclic)
  value  ["lit", "int"|"str"] | ["any"] (a value the program gives as any)
         | ["list", VALUE] (a one-element List literal)
         | ["cons", NAME, [[FIELD, VALUE]...], null | [TYPE...]]
           (a construction, its application written or inferred)
  case   {"decls": [decl...], "expected": TYPE, "value": VALUE}

Two checks:

  * exact: the value's exact type is inferred bottom-up -- a construction
    binds its slots from its field values in field order (a slot a later
    field establishes differently is a conflict, IMPRINT), an explicit
    application holds every field value to its substituted field type
    exactly (TYPE) -- and the case is accepted when that type equals the
    expected one (applications are invariant: equality, never subtyping;
    `any` is only `any`).
  * old: the same, every type cut the way the type bound cuts it (past
    APPLIED_DEPTH applications nested directly in arguments the arguments
    are `any`), a construction's field types read out of its own cut type
    and its slots read out of its fields' cut types -- the check the
    compiler made before the milestone. It is used only to classify how a
    verdict changed.

Usage:
  python3 -I oracle.py check CASES.jsonl   -> one JSON verdict per line:
      {"exact": "accept"|"TYPE"|"IMPRINT", "model": ..., "old": ..., "cut": 0|1}
      (model: exact along application spines, a List's contents as the
      bound keeps them -- the verdict the compiler must give)
  python3 -I oracle.py selftest
"""

import json
import sys

APPLIED_DEPTH = 6


class Reject(Exception):
    def __init__(self, kind):
        super().__init__(kind)
        self.kind = kind


def decls_of(case):
    return {d["name"]: d for d in case["decls"]}


def substitute(t, binding):
    k = t[0]
    if k == "var":
        return binding[t[1]]
    if k == "list":
        return ["list", substitute(t[1], binding)]
    if k == "app":
        return ["app", t[1], [substitute(a, binding) for a in t[2]]]
    return t


def match(declared, actual, binding):
    """Binds DECLARED's slots from ACTUAL (exactly); raises on a mismatch."""
    stack = [(declared, actual)]
    while stack:
        d, a = stack.pop()
        k = d[0]
        if k == "var":
            slot = d[1]
            if slot not in binding:
                binding[slot] = a
            elif binding[slot] != a:
                raise Reject("IMPRINT")
            continue
        if k == "list":
            if a[0] != "list":
                raise Reject("TYPE")
            stack.append((d[1], a[1]))
            continue
        if k == "app":
            if a[0] != "app" or a[1] != d[1] or len(a[2]) != len(d[2]):
                raise Reject("TYPE")
            for dp, ap in reversed(list(zip(d[2], a[2]))):
                stack.append((dp, ap))
            continue
        if d != a:
            raise Reject("TYPE")


def exact_type(value, decls):
    """The exact type of VALUE (post-order, explicit stack)."""
    out = []
    stack = [(value, 0)]
    while stack:
        v, phase = stack.pop()
        k = v[0]
        if k == "lit":
            out.append(["atom", v[1]])
            continue
        if k == "any":
            out.append(["any"])
            continue
        if k == "list":
            if phase == 0:
                stack.append((v, 1))
                stack.append((v[1], 0))
            else:
                out.append(["list", out.pop()])
            continue
        # cons
        fields = v[2]
        if phase == 0:
            stack.append((v, 1))
            for _, fv in reversed(fields):
                stack.append((fv, 0))
            continue
        n = len(fields)
        types = out[len(out) - n:] if n else []
        del out[len(out) - n:]
        decl = decls[v[1]]
        given = {f: t for (f, _), t in zip(fields, types)}
        explicit = v[3]
        if explicit is not None:
            binding = dict(zip(decl["slots"], explicit))
            for name, declared in decl["fields"]:
                if substitute(declared, binding) != given[name]:
                    raise Reject("TYPE")
            out.append(["app", decl["name"], list(explicit)])
            continue
        binding = {}
        for name, declared in decl["fields"]:
            if declared_mentions(declared):
                match(declared, given[name], binding)
            elif declared != given[name]:
                raise Reject("TYPE")
        if decl["slots"]:
            out.append(["app", decl["name"], [binding[s] for s in decl["slots"]]])
        else:
            out.append(["app", decl["name"], []])
    return out[0]


def declared_mentions(t):
    stack = [t]
    while stack:
        x = stack.pop()
        if x[0] == "var":
            return True
        if x[0] == "list":
            stack.append(x[1])
        elif x[0] == "app":
            stack.extend(x[2])
    return False


def check_exact(case):
    decls = decls_of(case)
    try:
        t = exact_type(case["value"], decls)
    except Reject as r:
        return r.kind
    return "accept" if t == case["expected"] else "TYPE"


AGGREGATE_DEPTH = 3


def model(t, agg=0, nesting=0, in_list=False):
    """A type as the bound keeps its aggregates: exact along application
    spines, inside a List an application cut at APPLIED_DEPTH applications
    below the element, a List AGGREGATE_DEPTH Lists deep the bare kind."""
    k = t[0]
    if k == "list":
        if agg >= AGGREGATE_DEPTH:
            return ["listkind"]
        return ["list", model(t[1], agg + 1, 0, True)]
    if k == "app":
        if in_list and nesting >= APPLIED_DEPTH and t[2]:
            return ["app", t[1], [["any"] for _ in t[2]]]
        return ["app", t[1], [model(a, agg, nesting + 1 if a[0] == "app" else 0, in_list) for a in t[2]]]
    if k == "known":
        return t
    return t


def truncate(t, h):
    """T known only H applications below its top (None: all of it)."""
    if h is None:
        return strip(t)
    t = strip(t)
    if t[0] != "app":
        return t
    if h <= 0:
        return ["app", t[1], [["any"] for _ in t[2]]]
    return ["app", t[1], [truncate(a, h - 1) if a[0] == "app" else a for a in t[2]]]


def strip(t):
    if t[0] == "known":
        return t[1]
    if t[0] == "app":
        return ["app", t[1], [strip(a) for a in t[2]]]
    return t


def horizon_of(t):
    return t[2] if t[0] == "known" else None


def known_equal(a, b):
    """Two knowledge terms describe the same type as far as either is
    known: ["known", T, H] is T known H applications deep (a slot read out
    of a List's contents), compared to that horizon."""
    stack = [(a, b)]
    while stack:
        x, y = stack.pop()
        hx, hy = horizon_of(x), horizon_of(y)
        if hx is not None or hy is not None:
            h = min(v for v in (hx, hy) if v is not None)
            if truncate(x, h) != truncate(y, h):
                return False
            continue
        if x[0] == "app" and y[0] == "app":
            if x[1] != y[1] or len(x[2]) != len(y[2]):
                return False
            stack.extend(zip(x[2], y[2]))
            continue
        if x != y:
            return False
    return True


def bind_known(declared, actual, binding, in_list=False, depth=0):
    """match() over knowledge: a slot read out of a List's contents is
    known only to the horizon the bound leaves there."""
    stack = [(declared, actual, in_list, depth)]
    while stack:
        d, a, inside, n = stack.pop()
        k = d[0]
        if k == "var":
            slot = d[1]
            if inside and a[0] != "known":
                a = ["known", model(a, 0, 0, True) if a[0] == "app" else a, APPLIED_DEPTH - n]
            if slot not in binding:
                binding[slot] = a
            elif not known_equal(binding[slot], a):
                raise Reject("IMPRINT")
            continue
        if k == "list":
            if a[0] != "list":
                raise Reject("TYPE")
            stack.append((d[1], a[1], True, 0))
            continue
        if k == "app":
            a2 = a[1] if a[0] == "known" else a
            if a2[0] != "app" or a2[1] != d[1] or len(a2[2]) != len(d[2]):
                raise Reject("TYPE")
            h = horizon_of(a)
            for dp, ap in reversed(list(zip(d[2], a2[2]))):
                if h is not None:
                    ap = ["known", ap, h - 1]
                stack.append((dp, ap, inside, n + 1))
            continue
        if not known_equal(d, a):
            raise Reject("TYPE")


def known_type(value, decls):
    """The value's type as far as the compiler's evidence knows it: exact
    along the constructions' application spines, a List literal's type as
    the bound keeps it, a slot its construction reads out of a List's
    contents known to that horizon."""
    k = value[0]
    if k == "lit":
        return ["atom", value[1]]
    if k == "any":
        return ["any"]
    if k == "list":
        return model(["list", strip(known_type(value[1], decls))])
    decl = decls[value[1]]
    given = {f: known_type(fv, decls) for f, fv in value[2]}
    explicit = value[3]
    binding = {}
    for name, declared in decl["fields"]:
        if declared_mentions(declared):
            bind_known(declared, given[name], binding)
    if explicit is not None:
        for slot, a in zip(decl["slots"], explicit):
            binding.setdefault(slot, a)
    return ["app", decl["name"], [binding[s] for s in decl["slots"]]]


def check_model(case):
    """The verdict the compiler must give: the exact check's construction
    rules (exact_type), the value then compared with the expected type as
    far as its evidence knows it (known_type), a List's contents as the
    bound keeps them (model)."""
    decls = decls_of(case)
    try:
        exact_type(case["value"], decls)
    except Reject as r:
        return r.kind
    sys.setrecursionlimit(20000)
    try:
        k = known_type(case["value"], decls)
    except Reject as r:
        return r.kind
    return "accept" if known_equal(k, model(case["expected"])) else "TYPE"


# ---------------------------------------------------------------------------
# The old, bounded check (for classification only)

def cut(t, nesting=0):
    """T with the applied-type bound applied: an application APPLIED_DEPTH
    or more applications deep (directly in arguments) keeps no argument; a
    List restarts the count (the aggregate bound is not modelled: the
    generator nests Lists only shallowly)."""
    k = t[0]
    if k == "app":
        if nesting >= APPLIED_DEPTH and t[2]:
            return ["app", t[1], [["any"] for _ in t[2]]]
        return ["app", t[1], [cut(a, nesting + 1) if a[0] == "app" else cut(a, 0) for a in t[2]]]
    if k == "list":
        return ["list", cut(t[1], 0)]
    return t


def is_cut(t):
    stack = [(t, 0)]
    while stack:
        x, n = stack.pop()
        if x[0] == "app":
            if n >= APPLIED_DEPTH and x[2] and all(a == ["any"] for a in x[2]):
                return True
            for a in x[2]:
                stack.append((a, n + 1 if a[0] == "app" else 0))
        elif x[0] == "list":
            stack.append((x[1], 0))
    return False


def old_type(value, decls):
    """The value's type as the bounded check computed it."""
    k = value[0]
    if k == "lit":
        return ["atom", value[1]]
    if k == "any":
        return ["any"]
    if k == "list":
        return ["list", old_type(value[1], decls)]
    decl = decls[value[1]]
    given = {f: old_type(fv, decls) for f, fv in value[2]}
    explicit = value[3]
    if explicit is not None:
        own = cut(["app", decl["name"], list(explicit)])
    else:
        binding = {}
        for name, declared in decl["fields"]:
            if declared_mentions(declared):
                match(declared, given[name], binding)
        own = cut(["app", decl["name"], [binding[s] for s in decl["slots"]]])
    # The field check against the construction's own (cut) type.
    args = dict(zip(decl["slots"], own[2]))
    for name, declared in decl["fields"]:
        if cut(substitute(declared, args)) != given[name]:
            raise Reject("TYPE")
    return own


def check_old(case):
    decls = decls_of(case)
    try:
        t = old_type(case["value"], decls)
    except Reject as r:
        return r.kind
    except RecursionError:
        return "TYPE"
    return "accept" if t == cut(case["expected"]) else "TYPE"


def any_cut(case):
    decls = decls_of(case)
    try:
        t = exact_type(case["value"], decls)
    except Reject:
        t = None
    return int(is_cut(cut(case["expected"])) or (t is not None and is_cut(cut(t))))


def verdict(case):
    sys.setrecursionlimit(20000)
    return {"exact": check_exact(case), "model": check_model(case), "old": check_old(case), "cut": any_cut(case)}


# ---------------------------------------------------------------------------

def selftest():
    box = {"name": "Box", "slots": ["T"], "fields": [["value", ["var", "T"]]]}
    pair = {"name": "Pair", "slots": ["A", "B"], "fields": [["first", ["var", "A"]], ["second", ["var", "B"]]]}
    two = {"name": "Two", "slots": ["T"], "fields": [["a", ["app", "Box", [["var", "T"]]]], ["b", ["var", "T"]]]}

    def nest(n, leaf):
        v = leaf
        for _ in range(n):
            v = ["cons", "Box", [["value", v]], None]
        return v

    def ty(n, leaf):
        t = leaf
        for _ in range(n):
            t = ["app", "Box", [t]]
        return t

    i, s = ["atom", "int"], ["atom", "str"]
    checks = []
    for n in (1, 6, 7, 30):
        c = {"decls": [box], "expected": ty(n, i), "value": nest(n, ["lit", "int"])}
        checks.append((f"box-{n}", verdict(c)["exact"], "accept"))
        c = {"decls": [box], "expected": ty(n, i), "value": nest(n, ["lit", "str"])}
        checks.append((f"box-bad-{n}", verdict(c)["exact"], "TYPE"))
    # The old check's false rejection from seven deep on.
    c = {"decls": [box], "expected": ty(7, i), "value": nest(7, ["lit", "int"])}
    checks.append(("old-7", verdict(c)["old"], "TYPE"))
    c = {"decls": [box], "expected": ty(6, i), "value": nest(6, ["lit", "int"])}
    checks.append(("old-6", verdict(c)["old"], "accept"))
    # The old check accepted a deep mismatch the cut hid -- once its own
    # construction checks pass (an any leaf there).
    c = {"decls": [box], "expected": ty(12, i), "value": nest(12, ["any"])}
    checks.append(("any-12", verdict(c)["exact"], "TYPE"))
    # Slots: a conflict in Two is IMPRINT however deep.
    c = {"decls": [box, two], "expected": ["app", "Two", [ty(9, i)]],
         "value": ["cons", "Two", [["a", nest(10, ["lit", "int"])], ["b", nest(9, ["lit", "str"])]], None]}
    checks.append(("two-conflict", verdict(c)["exact"], "IMPRINT"))
    c = {"decls": [box, two], "expected": ["app", "Two", [ty(9, i)]],
         "value": ["cons", "Two", [["a", nest(10, ["lit", "int"])], ["b", nest(9, ["lit", "int"])]], None]}
    checks.append(("two-ok", verdict(c)["exact"], "accept"))
    # Pair: the slot a mismatch is in matters, and positions are slots.
    v = ["lit", "int"]
    t = i
    for k in range(9):
        v = ["cons", "Pair", [["first", ["lit", "int"]], ["second", v]], None]
        t = ["app", "Pair", [i, t]]
    checks.append(("pair-ok", verdict({"decls": [pair], "expected": t, "value": v})["exact"], "accept"))
    swapped = ["app", "Pair", [t[2][1], t[2][0]]]
    checks.append(("pair-swapped", verdict({"decls": [pair], "expected": swapped, "value": v})["exact"], "TYPE"))
    # An explicit application holds its fields exactly.
    c = {"decls": [box], "expected": ty(8, i), "value": ["cons", "Box", [["value", nest(7, ["lit", "str"])]], ty(7, i)]}
    checks.append(("explicit-bad", verdict(c)["exact"], "TYPE"))
    failed = [(n, got, want) for n, got, want in checks if got != want]
    for n, got, want in checks:
        print(f"{'ok  ' if got == want else 'FAIL'} {n}: {got} (expected {want})")
    print(f"{len(checks)} checks, {len(failed)} failed")
    return 1 if failed else 0


def main(argv):
    if len(argv) >= 2 and argv[1] == "selftest":
        return selftest()
    if len(argv) == 3 and argv[1] == "check":
        with open(argv[2], encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line:
                    print(json.dumps(verdict(json.loads(line))))
        return 0
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
