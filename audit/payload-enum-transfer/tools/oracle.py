#!/usr/bin/env python3
"""oracle.py -- an independent model of payload-bearing enum transfer
(PORTABILITY-PAYLOAD-ENUM-TRANSFER-MILESTONE-1.md).

Written from the milestone's rules, not from the compiler: it imports
nothing of the repository and shares no code with hir/transfer.tcl,
core/transfer.tcl or native/src/runtime/transfer.rs. For a small type
language -- int, str, bool, List[T], named structs and enums (payload-free
and payload-bearing cases), plus Fn and any for the static judgement -- it
predicts:

  * Sendable: every payload field of every case, every field of a struct,
    every element of a List, recursively; Fn none, any unknown.
  * The schema's canonical text and its fingerprint (64-bit FNV-1a of the
    text's UTF-8): nodes numbered in the order a walk in sorted order meets
    them, a struct's fields sorted, an enum's cases sorted, a payload-free
    enum `enum ID {CASES}`, a payload-bearing one
    `penum ID {CASE NODE|- ...}` whose payloads are anonymous structs.
  * A value's bytes: "BOTX", version 1, the fingerprint (8 bytes,
    little-endian), then the value: an Int its minimal two's complement
    after a varuint byte count, a String its UTF-8 after a varuint count, a
    Bool one byte, a List a varuint count and its elements, a struct its
    fields in sorted order, an enum its case's index among the sorted case
    names then (payload-bearing case) its payload's fields in sorted order.
  * The outcome of decoding any byte string as a type: ok (with the value),
    or TransferMalformed, TransferVersion, TransferTypeMismatch,
    TransferInvalidValue, TransferLimit -- in the order the format checks
    them -- with counts admitted against each node's minimum size (the
    milestone's fixpoint: core/transfer.tcl's MinSizes, specified in its
    comment, reimplemented here).

Usage:
  python3 -I oracle.py selftest
  python3 -I oracle.py run SPEC.json [--lines]
                                         (prints a JSON report, or one line
                                         per fact)

SPEC: {"enums": {NAME: [[CASE, null | [[FIELD, TYPE], ...]], ...]},
       "structs": {NAME: [[FIELD, TYPE], ...]},
       "cases": [{"type": TYPE, "value": VALUE, "mutations": [BYTES, ...]}],
       "types": [TYPE, ...]}
VALUE: {"k": "int", "v": "DECIMAL"} | {"k": "str", "v": TEXT} |
       {"k": "bool", "v": BOOL} | {"k": "list", "v": [VALUE, ...]} |
       {"k": "enum", "e": NAME, "c": CASE, "f": null | {FIELD: VALUE}} |
       {"k": "struct", "s": NAME, "f": {FIELD: VALUE}}
"""

import json
import sys

MAGIC = b"BOTX"
VERSION = 1
MAX_INT_BYTES = 1 << 20
ZERO_BUDGET = 1 << 24
MAX_VARUINT = (1 << 62) - 1
MAX_MIN = 1 << 40


def parse_type(t):
    t = t.strip()
    if t.startswith("List[") and t.endswith("]"):
        return ("list", parse_type(t[5:-1]))
    return ("name", t)


def type_text(t):
    if t[0] == "list":
        return "List[" + type_text(t[1]) + "]"
    return t[1]


class Decls:
    def __init__(self, spec):
        self.enums = {}
        for name, cases in spec.get("enums", {}).items():
            self.enums[name] = [(c, None if fields is None else [(f, parse_type(ft)) for f, ft in fields]) for c, fields in cases]
        self.structs = {name: [(f, parse_type(ft)) for f, ft in fields] for name, fields in spec.get("structs", {}).items()}

    def payload(self, enum, case):
        for c, fields in self.enums[enum]:
            if c == case:
                return fields
        raise KeyError(case)

    def has_payloads(self, enum):
        return any(fields is not None for _, fields in self.enums[enum])


# ---------------------------------------------------------------------------
# Sendable

def sendable(decls, t, seen=None):
    """'total', 'none' or 'unknown'."""
    seen = set() if seen is None else seen
    if t[0] == "list":
        return sendable(decls, t[1], seen)
    name = t[1]
    if name in ("int", "str", "bool"):
        return "total"
    if name.startswith("Fn"):
        return "none"
    if name == "any":
        return "unknown"
    if name in seen:
        return "total"
    seen = seen | {name}
    if name in decls.enums:
        parts = [ft for _, fields in decls.enums[name] if fields for _, ft in fields]
    elif name in decls.structs:
        parts = [ft for _, ft in decls.structs[name]]
    else:
        return "unknown"
    worst = "total"
    for p in parts:
        c = sendable(decls, p, seen)
        if c == "none":
            return "none"
        if c == "unknown":
            worst = "unknown"
    return worst


# ---------------------------------------------------------------------------
# The schema

class Schema:
    """Nodes: ('int',), ('str',), ('bool',), ('list', N),
    ('struct', ID, [(FIELD, N)]), ('enum', ID, [CASE]),
    ('penum', ID, [(CASE, N | None)])."""

    def __init__(self, decls, t):
        self.decls = decls
        self.nodes = []
        self.keys = {}
        self.node(t)

    def node(self, t):
        key = type_text(t) if not isinstance(t, str) else t
        if key in self.keys:
            return self.keys[key]
        index = len(self.nodes)
        self.keys[key] = index
        self.nodes.append(None)
        self.nodes[index] = self.make(t)
        return index

    def make(self, t):
        if isinstance(t, str):
            # An anonymous payload struct, keyed by its text "{f: T, ...}".
            raise AssertionError("unreachable")
        if t[0] == "list":
            return ("list", self.node(t[1]))
        name = t[1]
        if name in ("int", "str", "bool"):
            return (name,)
        if name in self.decls.structs:
            fields = self.decls.structs[name]
            return ("struct", name, [(f, self.node(ft)) for f, ft in sorted(fields, key=lambda x: x[0])])
        if name in self.decls.enums:
            cases = sorted(c for c, _ in self.decls.enums[name])
            if not self.decls.has_payloads(name):
                return ("enum", name, cases)
            payloads = []
            for c in cases:
                fields = self.decls.payload(name, c)
                if fields is None:
                    payloads.append((c, None))
                else:
                    payloads.append((c, self.anonymous(fields)))
            return ("penum", name, payloads)
        raise ValueError("no schema for " + name)

    def anonymous(self, fields):
        ordered = sorted(fields, key=lambda x: x[0])
        key = "{" + ", ".join(f + ": " + type_text(ft) for f, ft in ordered) + "}"
        if key in self.keys:
            return self.keys[key]
        index = len(self.nodes)
        self.keys[key] = index
        self.nodes.append(None)
        self.nodes[index] = ("struct", "", [(f, self.node(ft)) for f, ft in ordered])
        return index

    def text(self):
        lines = ["botlish-transfer 1"]
        for i, n in enumerate(self.nodes):
            kind = n[0]
            if kind in ("int", "str", "bool"):
                line = kind
            elif kind == "list":
                line = "list %d" % n[1]
            elif kind == "struct":
                line = "struct %s {%s}" % (n[1] or "{}", " ".join("%s %d" % (f, c) for f, c in n[2]))
            elif kind == "enum":
                line = "enum %s {%s}" % (n[1], " ".join(n[2]))
            else:
                line = "penum %s {%s}" % (n[1], " ".join("%s %s" % (c, "-" if p is None else str(p)) for c, p in n[2]))
            lines.append("%d %s" % (i, line))
        return "\n".join(lines)

    def fingerprint(self):
        h = 0xcbf29ce484222325
        for b in self.text().encode("utf-8"):
            h = ((h ^ b) * 0x100000001b3) & 0xffffffffffffffff
        return h

    def min_sizes(self):
        count = len(self.nodes)
        sizes = [0] * count
        for _ in range(count + 1):
            changed = False
            for n, node in enumerate(self.nodes):
                kind = node[0]
                if kind == "struct":
                    size = sum(sizes[c] for _, c in node[2])
                elif kind == "penum":
                    size = 1 + min(0 if p is None else sizes[p] for _, p in node[2])
                else:
                    size = 1
                size = min(size, MAX_MIN)
                if size != sizes[n]:
                    sizes[n] = size
                    changed = True
            if not changed:
                break
        return sizes


# ---------------------------------------------------------------------------
# Encoding

def varuint(n):
    out = bytearray()
    while n >= 0x80:
        out.append((n & 0x7f) | 0x80)
        n >>= 7
    out.append(n)
    return bytes(out)


def int_bytes(n):
    if n == 0:
        return varuint(0)
    count = 1
    while not (-(1 << (8 * count - 1)) <= n < (1 << (8 * count - 1))):
        count += 1
    return varuint(count) + (n & ((1 << (8 * count)) - 1)).to_bytes(count, "little")


def encode(schema, value):
    out = bytearray(MAGIC)
    out.append(VERSION)
    out += schema.fingerprint().to_bytes(8, "little")
    out += encode_value(schema, 0, value)
    return bytes(out)


def encode_value(schema, n, v):
    node = schema.nodes[n]
    kind = node[0]
    if kind == "int":
        return int_bytes(int(v["v"]))
    if kind == "str":
        raw = v["v"].encode("utf-8")
        return varuint(len(raw)) + raw
    if kind == "bool":
        return bytes([1 if v["v"] else 0])
    if kind == "list":
        return varuint(len(v["v"])) + b"".join(encode_value(schema, node[1], x) for x in v["v"])
    if kind == "struct":
        return b"".join(encode_value(schema, c, v["f"][f]) for f, c in node[2])
    if kind == "enum":
        return varuint(node[2].index(v["c"]))
    # penum
    cases = [c for c, _ in node[2]]
    i = cases.index(v["c"])
    p = node[2][i][1]
    out = varuint(i)
    if p is not None:
        out += encode_value(schema, p, {"f": v["f"]})
    return out


# ---------------------------------------------------------------------------
# Decoding: the outcome of any byte string

class Refused(Exception):
    def __init__(self, kind):
        super().__init__(kind)
        self.kind = kind


class Reader:
    def __init__(self, raw, pos):
        self.raw = raw
        self.pos = pos
        self.budget = ZERO_BUDGET

    def byte(self):
        if self.pos >= len(self.raw):
            raise Refused("malformed")
        b = self.raw[self.pos]
        self.pos += 1
        return b

    def take(self, count):
        if count > len(self.raw) - self.pos:
            raise Refused("malformed")
        out = self.raw[self.pos:self.pos + count]
        self.pos += count
        return out

    def varuint(self):
        value = 0
        for i in range(10):
            b = self.byte()
            value |= (b & 0x7f) << (7 * i)
            if b & 0x80 == 0:
                if b == 0 and i > 0:
                    raise Refused("malformed")
                if value > MAX_VARUINT:
                    raise Refused("limit")
                return value
        raise Refused("malformed")


def decode(schema, raw):
    """(OUTCOME, VALUE): OUTCOME 'ok' (VALUE the value, in the spec's VALUE
    form) or a refusal's kind."""
    if len(raw) < 13 or raw[:4] != MAGIC:
        return ("malformed", None)
    if raw[4] != VERSION:
        return ("version", None)
    if int.from_bytes(raw[5:13], "little") != schema.fingerprint():
        return ("mismatch", None)
    r = Reader(raw, 13)
    mins = schema.min_sizes()
    try:
        v = decode_value(schema, mins, r, 0)
    except Refused as e:
        return (e.kind, None)
    if r.pos != len(raw):
        return ("malformed", None)
    return ("ok", v)


def decode_value(schema, mins, r, n):
    # (Recursive: the fuzzer's values are shallow. The production codecs
    # walk with work stacks; their order of checks is this one.)
    node = schema.nodes[n]
    kind = node[0]
    if kind == "int":
        count = r.varuint()
        if count > MAX_INT_BYTES:
            raise Refused("limit")
        if count == 0:
            return {"k": "int", "v": "0"}
        b = r.take(count)
        last = b[-1]
        if count == 1 and last == 0:
            raise Refused("invalid")
        if count > 1:
            below = b[-2]
            if (last == 0 and below & 0x80 == 0) or (last == 0xff and below & 0x80 != 0):
                raise Refused("invalid")
        return {"k": "int", "v": str(int.from_bytes(b, "little", signed=True))}
    if kind == "str":
        count = r.varuint()
        b = r.take(count)
        try:
            text = b.decode("utf-8", errors="strict")
        except UnicodeDecodeError:
            raise Refused("invalid")
        if any(0xD800 <= ord(ch) <= 0xDFFF for ch in text):
            raise Refused("invalid")
        return {"k": "str", "v": text}
    if kind == "bool":
        b = r.byte()
        if b > 1:
            raise Refused("invalid")
        return {"k": "bool", "v": b == 1}
    if kind == "list":
        count = r.varuint()
        m = mins[node[1]]
        if m > 0:
            if count > (len(r.raw) - r.pos) // m:
                raise Refused("malformed")
        else:
            r.budget -= count
            if r.budget < 0:
                raise Refused("limit")
        return {"k": "list", "v": [decode_value(schema, mins, r, node[1]) for _ in range(count)]}
    if kind == "struct":
        fields = {f: decode_value(schema, mins, r, c) for f, c in node[2]}
        if node[1] == "":
            return {"f": fields}
        return {"k": "struct", "s": node[1], "f": fields}
    if kind == "enum":
        i = r.varuint()
        if i >= len(node[2]):
            raise Refused("invalid")
        return {"k": "enum", "e": node[1], "c": node[2][i], "f": None}
    i = r.varuint()
    if i >= len(node[2]):
        raise Refused("invalid")
    c, p = node[2][i]
    if p is None:
        return {"k": "enum", "e": node[1], "c": c, "f": None}
    return {"k": "enum", "e": node[1], "c": c, "f": decode_value(schema, mins, r, p)["f"]}


# ---------------------------------------------------------------------------
# Commands

def run(spec):
    decls = Decls(spec)
    report = {"cases": [], "types": []}
    for case in spec.get("cases", []):
        t = parse_type(case["type"])
        schema = Schema(decls, t)
        data = encode(schema, case["value"])
        outcomes = []
        for m in case.get("mutations", []):
            outcome, value = decode(schema, bytes(m))
            outcomes.append(outcome)
        back, value = decode(schema, data)
        assert back == "ok" and value == case["value"], (back, value, case["value"])
        report["cases"].append({
            "text": schema.text(),
            "fingerprint": "%016x" % schema.fingerprint(),
            "bytes": list(data),
            "outcomes": outcomes,
        })
    for t in spec.get("types", []):
        report["types"].append(sendable(decls, parse_type(t)))
    return report


def selftest():
    """The milestone's fixed vectors (tests/payload-enum-transfer.test's
    pet-vector-* and pet-schema-*), derived again here."""
    spec = {
        "enums": {
            "Color": [["Red", None], ["Green", None], ["Blue", None]],
            "Message": [["Ping", None], ["Text", [["body", "str"]]], ["Number", [["value", "int"]]], ["Batch", [["items", "List[int]"]]]],
            "Shape": [["Dot", None], ["Rect", [["w", "int"], ["h", "int"], ["label", "str"], ["filled", "bool"]]]],
            "Outer": [["Empty", None], ["Wrap", [["inner", "Message"]]]],
            "Tree": [["Leaf", [["value", "int"]]], ["Branch", [["children", "List[Tree]"]]]],
            "Expr": [["Lit", [["value", "int"]]], ["Neg", [["e", "Expr"]]], ["Add", [["left", "Expr"], ["right", "Expr"]]]],
        },
    }
    decls = Decls(spec)
    I = lambda n: {"k": "int", "v": str(n)}
    S = lambda s: {"k": "str", "v": s}
    E = lambda e, c, f=None: {"k": "enum", "e": e, "c": c, "f": f}
    vectors = [
        ("Color", E("Color", "Green"), [1], "81952409bbdce335"),
        ("Message", E("Message", "Ping"), [2], "627b87415786bd05"),
        ("Message", E("Message", "Number", {"value": I(300)}), [1, 2, 44, 1], None),
        ("Shape", E("Shape", "Rect", {"w": I(3), "h": I(-1), "label": S("é"), "filled": {"k": "bool", "v": True}}), [1, 1, 1, 255, 2, 195, 169, 1, 3], "dc9e61e6ea435f1a"),
        ("Outer", E("Outer", "Wrap", {"inner": E("Message", "Text", {"body": S("x")})}), [1, 3, 1, 120], "ee4c21aa86f3ed94"),
        ("Message", E("Message", "Batch", {"items": {"k": "list", "v": [I(1), I(300)]}}), [0, 2, 1, 1, 2, 44, 1], None),
        ("Tree", E("Tree", "Branch", {"children": {"k": "list", "v": [E("Tree", "Leaf", {"value": I(1)}), E("Tree", "Branch", {"children": {"k": "list", "v": []}})]}}), [0, 2, 1, 1, 1, 0, 0], "35f0957bd1ce64a5"),
        ("Expr", E("Expr", "Neg", {"e": E("Expr", "Add", {"left": E("Expr", "Lit", {"value": I(2)}), "right": E("Expr", "Lit", {"value": I(-2)})})}), [2, 0, 1, 1, 2, 1, 1, 254], "3ecf4892df3b00a2"),
    ]
    failures = 0
    for t, v, body, fp in vectors:
        schema = Schema(decls, parse_type(t))
        data = encode(schema, v)
        if list(data[13:]) != body:
            print("FAIL bytes %s: %s, expected %s" % (t, list(data[13:]), body))
            failures += 1
        if fp is not None and "%016x" % schema.fingerprint() != fp:
            print("FAIL fingerprint %s: %016x, expected %s" % (t, schema.fingerprint(), fp))
            failures += 1
        outcome, back = decode(schema, data)
        if outcome != "ok" or back != v:
            print("FAIL round trip %s: %s" % (t, outcome))
            failures += 1
        # Every proper prefix after the header ends inside the value; a
        # byte more is trailing.
        for k in range(13, len(data)):
            if decode(schema, data[:k])[0] != "malformed":
                print("FAIL prefix %s %d" % (t, k))
                failures += 1
        if decode(schema, data + b"\x00")[0] != "malformed":
            print("FAIL trailing %s" % t)
            failures += 1
    # A case index past the cases; a payload-free case of a payload enum
    # takes one byte; an Expr is at least 2 bytes (its fixpoint).
    schema = Schema(decls, parse_type("Message"))
    bad = bytearray(encode(schema, E("Message", "Ping")))
    bad[13] = 4
    if decode(schema, bytes(bad))[0] != "invalid":
        print("FAIL case index")
        failures += 1
    expr = Schema(decls, parse_type("Expr"))
    if expr.min_sizes()[0] != 2:
        print("FAIL Expr min %s" % expr.min_sizes())
        failures += 1
    # Sendable.
    spec["enums"]["Bad"] = [["Ok", None], ["Run", [["f", "Fn{}"]]]]
    spec["enums"]["Loose"] = [["Ok", None], ["X", [["x", "any"]]]]
    decls = Decls(spec)
    for t, want in [("Message", "total"), ("Tree", "total"), ("List[Expr]", "total"), ("Bad", "none"), ("List[Bad]", "none"), ("Loose", "unknown")]:
        got = sendable(decls, parse_type(t))
        if got != want:
            print("FAIL sendable %s: %s" % (t, got))
            failures += 1
    print("selftest: %d failure(s)" % failures)
    return failures


def main(argv):
    if len(argv) >= 2 and argv[1] == "selftest":
        return 1 if selftest() else 0
    if len(argv) in (3, 4) and argv[1] == "run":
        with open(argv[2], encoding="utf-8") as f:
            spec = json.load(f)
        report = run(spec)
        if len(argv) == 4 and argv[3] == "--lines":
            # One line per fact, for a reader with no JSON parser
            # (audit/payload-enum-transfer/tools/fuzz.tcl).
            for k, case in enumerate(report["cases"]):
                print("fingerprint %d %s" % (k, case["fingerprint"]))
                print("bytes %d %s" % (k, " ".join(str(b) for b in case["bytes"])))
                print("outcomes %d %s" % (k, " ".join(case["outcomes"])))
            for k, cls in enumerate(report["types"]):
                print("sendable %d %s" % (k, cls))
        else:
            json.dump(report, sys.stdout, ensure_ascii=False)
        return 0
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
