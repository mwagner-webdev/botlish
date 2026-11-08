#!/usr/bin/env python3
"""oracle.py -- an independent model of recursive affine ownership
(OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md).

    python3 -I oracle.py decide FILE     one verdict per query of FILE
    python3 -I oracle.py selftest        the hand cases

It shares no code with the compiler (hir/ownership.tcl) and states the
question from its definition:

    A type is a recursive affine type iff its ownership unfolding -- applied
    struct fields, anonymous struct fields, List / MutableVector /
    MutableArray elements, through affine values only -- has an infinite path
    that crosses a container element infinitely often.

The unfolding is modelled as a pushdown system over the *positions* of the
declarations' field type trees: a position is (declaration, field, path in
the field's type tree), a frame is (declaration, affinity vector of its
arguments). Entering an application pushes a frame; reaching one of the
frame's slot variables pops back to the argument's position in the frame
below. An infinite run pushes frames it never pops, infinitely often, so it
repeats a frame head (declaration and vector) with the later one above the
earlier (the "repeating heads" argument for pushdown Buechi automata). The
oracle therefore:

 1. computes each (declaration, vector)'s affinity by its own least fixpoint
    over every vector (no per-slot summary, no probes);
 2. computes, per (declaration, vector), which of its slots it exits to and
    whether a container was crossed on the way (matched calls) -- by a
    worklist over positions, again per vector, not per declaration;
 3. builds the head graph: an edge (D, A) -> (S, A') for every application
    position reachable inside D's frame (intra-frame steps and matched
    calls), labelled with whether a container was crossed;
 4. answers "bad" iff, from the query's own frame-less walk, a head lying on
    a cycle of the head graph that crosses a container is reachable, every
    position visited being affine.

Input (decide): lines

    decl NAME {SLOT ...} {FIELD TYPE ...}
    query ID TYPE

with TYPE a brace term: int | co | ptr T | fn T | var SLOT | list T |
mutvec T | mutarray T | anon {NAME T ...} | app NAME {T ...}.  `co` is an
affine root (a coroutine handle), `ptr T` a C pointer (an affine root whose
pointee is an identity, never owned), `fn T` a function type over T (owns no
value), `int` anything unrestricted. Output: `ID bad` or `ID ok` per query.
"""

import sys


# ---------------------------------------------------------------------------
# Brace terms

def parse_term(text):
    """A brace term (a Tcl-like list) as nested Python lists of str."""
    tokens = []
    i = 0
    while i < len(text):
        c = text[i]
        if c.isspace():
            i += 1
        elif c in "{}":
            tokens.append(c)
            i += 1
        else:
            j = i
            while j < len(text) and not text[j].isspace() and text[j] not in "{}":
                j += 1
            tokens.append(text[i:j])
            i = j
    pos = 0

    def items(end):
        nonlocal pos
        out = []
        while pos < len(tokens) and tokens[pos] != end:
            if tokens[pos] == "{":
                pos += 1
                out.append(items("}"))
                pos += 1
            else:
                out.append(tokens[pos])
                pos += 1
        return out

    return items(None)


def to_type(item):
    """A type from a parsed item: a word, or a list whose head is the kind."""
    if isinstance(item, str):
        return (item,)
    head = item[0]
    if head in ("int", "co", "any"):
        return (head,)
    if head in ("ptr", "fn", "list", "mutvec", "mutarray"):
        return (head, to_type(item[1]))
    if head == "var":
        return ("var", item[1])
    if head == "anon":
        fields = item[1]
        return ("anon", tuple((fields[k], to_type(fields[k + 1])) for k in range(0, len(fields), 2)))
    if head == "app":
        return ("app", item[1], tuple(to_type(a) for a in item[2]))
    raise ValueError("unknown type form %r" % (item,))


def type_of(text):
    return to_type(parse_term(text))


class Program:
    def __init__(self):
        self.decls = {}   # NAME -> (slots tuple, ((field, type), ...))
        self.queries = []  # (id, type)

    def decl(self, name, slots, fields):
        self.decls[name] = (tuple(slots), tuple(fields))

    @staticmethod
    def parse(text):
        p = Program()
        for line in text.splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = parse_term(line)
            if parts[0] == "decl":
                fields = parts[3]
                p.decl(parts[1], parts[2], [(fields[k], to_type(fields[k + 1])) for k in range(0, len(fields), 2)])
            elif parts[0] == "query":
                p.queries.append((parts[1], to_type(parts[2])))
            else:
                raise ValueError("unknown line %r" % line)
        return p


# ---------------------------------------------------------------------------
# Affinity: a least fixpoint over every (declaration, vector)

def vectors(n):
    for bits in range(1 << n):
        yield tuple(bool(bits >> k & 1) for k in range(n))


class Model:
    def __init__(self, program):
        self.p = program
        self.aff = {}
        for name, (slots, _) in program.decls.items():
            for v in vectors(len(slots)):
                self.aff[(name, v)] = False
        changed = True
        while changed:
            changed = False
            for key in list(self.aff):
                if self.aff[key]:
                    continue
                name, v = key
                slots, fields = program.decls[name]
                env = dict(zip(slots, v))
                if any(self.affine(t, env) for _, t in fields):
                    self.aff[key] = True
                    changed = True
        self.exits = {}
        self.heads = {}

    def affine(self, t, env):
        """Affinity of type T in a frame whose slot affinities are ENV."""
        k = t[0]
        if k in ("co", "ptr"):
            return True
        if k == "var":
            return env.get(t[1], False)
        if k in ("list", "mutvec", "mutarray"):
            return self.affine(t[1], env)
        if k == "anon":
            return any(self.affine(f, env) for _, f in t[1])
        if k == "app":
            if t[1] not in self.p.decls:
                return False
            return self.aff[(t[1], self.vector(t, env))]
        return False

    def vector(self, app, env):
        slots = self.p.decls[app[1]][0]
        args = list(app[2]) + [("any",)] * (len(slots) - len(app[2]))
        return tuple(self.affine(a, env) for a in args[:len(slots)])

    # -----------------------------------------------------------------------
    # Positions of a frame: a worklist over (position, crossed)

    def frame_walk(self, roots, env, slots):
        """From ROOTS (types at crossed 0) in a frame whose slots are SLOTS
        with affinities ENV: the exits {(slot, crossed)} and the heads
        {(decl, vector, crossed)} reachable, every position affine."""
        exits = set()
        heads = set()
        work = [(t, False) for t in roots]
        seen = set()
        while work:
            t, crossed = work.pop()
            if (t, crossed) in seen:
                continue
            seen.add((t, crossed))
            if not self.affine(t, env):
                continue
            k = t[0]
            if k == "var":
                if t[1] in slots:
                    exits.add((t[1], crossed))
            elif k in ("list", "mutvec", "mutarray"):
                work.append((t[1], True))
            elif k == "anon":
                for _, f in t[1]:
                    work.append((f, crossed))
            elif k == "app" and t[1] in self.p.decls:
                v = self.vector(t, env)
                heads.add((t[1], v, crossed))
                callee_slots = self.p.decls[t[1]][0]
                args = list(t[2]) + [("any",)] * (len(callee_slots) - len(t[2]))
                for slot, c in self.exits_of(t[1], v):
                    work.append((args[callee_slots.index(slot)], crossed or c))
        return exits, heads

    def exits_of(self, name, v):
        """The matched calls of frame (NAME, V): {(slot, crossed)}, a least
        fixpoint over every frame (computed once for all)."""
        if not self.exits:
            for key in self.aff:
                self.exits[key] = set()
            changed = True
            while changed:
                changed = False
                for (n, vec) in list(self.exits):
                    slots, fields = self.p.decls[n]
                    env = dict(zip(slots, vec))
                    found, _ = self.frame_walk([f for _, f in fields], env, slots)
                    if not found <= self.exits[(n, vec)]:
                        self.exits[(n, vec)] |= found
                        changed = True
        return self.exits[(name, v)]

    def head_edges(self, name, v):
        key = (name, v)
        if key not in self.heads:
            slots, fields = self.p.decls[name]
            env = dict(zip(slots, v))
            if not self.aff[key]:
                self.heads[key] = set()
            else:
                _, heads = self.frame_walk([f for _, f in fields], env, slots)
                self.heads[key] = {((n, vec), c) for n, vec, c in heads if self.aff[(n, vec)]}
        return self.heads[key]

    # -----------------------------------------------------------------------
    # The verdict

    def bad(self, t):
        _, roots = self.frame_walk([t], {}, ())
        start = {(n, vec) for n, vec, _ in roots if self.aff[(n, vec)]}
        # Every head reachable from the query.
        reach = set()
        work = list(start)
        while work:
            h = work.pop()
            if h in reach:
                continue
            reach.add(h)
            for h2, _ in self.head_edges(*h):
                work.append(h2)
        # A crossing edge u -> w lies on a cycle iff u is reachable from w.
        for u in reach:
            for w, c in self.head_edges(*u):
                if c and self.reaches(w, u):
                    return True
        return False

    def reaches(self, a, b):
        seen = set()
        work = [a]
        while work:
            h = work.pop()
            if h == b:
                return True
            if h in seen:
                continue
            seen.add(h)
            for h2, _ in self.head_edges(*h):
                work.append(h2)
        return False


def decide(program):
    model = Model(program)
    return [(qid, "bad" if model.bad(t) else "ok") for qid, t in program.queries]


# ---------------------------------------------------------------------------
# Hand cases

SELFTEST = """
decl Node {T} {value {var T} children {list {app Node {{var T}}}}}
decl W {T} {next {list {app W {{list {var T}}}}}}
decl PhantomRec {T} {next {list {app PhantomRec {{list {var T}}}}}}
decl Mixed {A B} {value {var A} next {list {app Mixed {{var A} {list {var B}}}}}}
decl GrowA {T} {b {list {app GrowB {{list {var T}}}}}}
decl GrowB {T} {a {app GrowA {{var T}}} v {var T}}
decl R {} {handle co children {list {app R {}}}}
decl Plain {} {n int children {list {app Plain {}}}}
decl PtrRec {} {p {ptr int} kids {list {app PtrRec {}}}}
decl PtrOnly {} {p {ptr {app PtrOnly {}}}}
decl Holder {T} {t {app Node {{var T}}}}
decl Swap {T U} {v {var T} next {list {app Swap {{var U} int}}}}
decl SwapBack {T U} {v {var T} next {list {app Swap2 {{var U} {var T}}}}}
decl Swap2 {T U} {v {var T} next {list {app Swap2 {{var U} {var T}}}}}
decl G {T} {c {var T} g {app G {{list {var T}}}}}
decl Self {} {c co s {app Self {}}}
decl Box {T} {value {var T}}
decl Through {} {c co kids {list {app Box {{app Through {}}}}}}
decl Fun {T} {f {fn {var T}} kids {list {app Fun {{var T}}}}}
decl Tree {} {t {app Unrelated {}} c co}
decl Unrelated {} {kids {list {app Unrelated {}}}}
decl NA1 {T} {b {list {app NB1 {{list {var T}}}}}}
decl NB1 {T} {a {app NA1 {{var T}}}}
decl NA2 {T} {b {list {app NB2 {{list {var T}}}}} v {var T}}
decl NB2 {T} {a {app NA2 {{var T}}}}
decl C0 {} {n {app C1 {}}}
decl C1 {} {n {app C2 {}}}
decl C2 {} {n {app C3 {}}}
decl C3 {} {c co}
query node-co {app Node {co}}
query node-int {app Node {int}}
query w-co {app W {co}}
query phantomrec-co {app PhantomRec {co}}
query mixed-co-int {app Mixed {co int}}
query mixed-int-co {app Mixed {int co}}
query growa-co {app GrowA {co}}
query growb-co {app GrowB {co}}
query r {app R {}}
query plain {app Plain {}}
query ptrrec {app PtrRec {}}
query ptronly {app PtrOnly {}}
query holder-co {app Holder {co}}
query swap-int-co {app Swap {int co}}
query swap-co-co {app Swap {co co}}
query swap2-co-int {app Swap2 {co int}}
query g-co {app G {co}}
query self {app Self {}}
query box-box-co {app Box {{app Box {co}}}}
query box-node-co {app Box {{app Node {co}}}}
query through {app Through {}}
query fun-co {app Fun {co}}
query tree {app Tree {}}
query na1-co {app NA1 {co}}
query na2-co {app NA2 {co}}
query growa-list {app GrowA {{list co}}}
query chain {app C0 {}}
query list-node {list {app Node {co}}}
"""

EXPECTED = {
    "node-co": "bad", "node-int": "ok", "w-co": "ok", "phantomrec-co": "ok",
    "mixed-co-int": "bad", "mixed-int-co": "ok", "growa-co": "bad",
    "growb-co": "bad", "r": "bad", "plain": "ok", "ptrrec": "bad",
    "ptronly": "ok", "holder-co": "bad", "swap-int-co": "ok",
    "swap-co-co": "ok", "swap2-co-int": "bad", "g-co": "ok", "self": "ok",
    "box-box-co": "ok", "box-node-co": "bad", "through": "bad",
    "fun-co": "ok", "tree": "ok", "na1-co": "ok", "na2-co": "bad",
    "growa-list": "bad", "chain": "ok", "list-node": "bad",
}


def selftest():
    results = dict(decide(Program.parse(SELFTEST)))
    failures = [(q, results.get(q), want) for q, want in EXPECTED.items() if results.get(q) != want]
    for q, got, want in failures:
        print("FAIL %s: %s, expected %s" % (q, got, want))
    print("%d hand cases, %d failures" % (len(EXPECTED), len(failures)))
    return 1 if failures else 0


def main(argv):
    if len(argv) >= 2 and argv[1] == "selftest":
        return selftest()
    if len(argv) >= 3 and argv[1] == "decide":
        with open(argv[2], encoding="utf-8") as f:
            program = Program.parse(f.read())
        for qid, verdict in decide(program):
            print(qid, verdict)
        return 0
    sys.stderr.write(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
