#!/usr/bin/env python3
"""The independent oracle of hir/lifetime.tcl (STORAGE-LIFETIME-FACTS-MILESTONE-1.md).

    python3 -I audit/storage-lifetime/tools/oracle.py generate SEED COUNT DIR [--strings 0|1]
    python3 -I audit/storage-lifetime/tools/oracle.py selftest

`generate` writes COUNT programs (DIR/gSEED_K.bot) and, beside each, the
facts this file's own model of the program predicts (DIR/gSEED_K.json).
Nothing here reads the compiler: the programs are built from a small
statement language whose meaning this file states (immutable bindings, one
definition per name, Strings that a concatenation may keep, MutableVectors
that a push stores into, folds whose intermediate is carried, yields that
suspend), and the expectations are computed over that language's own syntax
tree:

  * suspensions: for every `yield` of the coroutine `worker`, the bindings
    (and fold positions, `pos@LINE`) some path still reads after it resumes
    -- the continuation of the yield, worked out by a recursive model of
    sequences, branches and fold iterations (a fold's next iteration reads
    what its body reads of outer bindings, its intermediate and its
    position; the iteration's own bindings and counter are made again);
  * producers: for every String, List or MutableVector it builds, in the
    plain function `make` and in `worker`, the verdict per region: escapes
    the activation when the returned value reaches it; escapes the
    iteration of an enclosing fold when it does, or a binding made outside
    the fold's body reaches it; escapes the segment (worker only) when a
    binding live across a yield reaches it and it may have been made before
    that yield.

Containment follows the contract hir/lifetime.tcl documents, independently
stated here: a String concatenation may keep its operands, keep(s) is s, a
MutableVector holds what it was made from and what is pushed into it, a
List literal holds its element.
"""

import json
import os
import random
import sys

# ---------------------------------------------------------------------------
# The program model


class Stmt:
    """A statement: kind, fields, and the line it is written on."""

    def __init__(self, kind, **fields):
        self.kind = kind
        self.line = 0
        self.__dict__.update(fields)


class Gen:
    def __init__(self, rng, strings=True):
        self.rng = rng
        self.strings = strings
        self.count = 0

    def fresh(self, prefix):
        self.count += 1
        return f"{prefix}{self.count}"

    def int_expr(self, scope, depth=0):
        ints = scope["int"]
        choices = ["lit", "var", "var", "add"]
        if self.strings and scope["str"]:
            choices += ["len", "len"]
        if self.strings and scope["vec"]:
            choices.append("veclen")
        c = self.rng.choice(choices)
        if c == "lit" or (c in ("var", "add") and not ints):
            return ("lit", self.rng.randint(0, 9))
        if c == "var":
            return ("var", self.rng.choice(ints))
        if c == "add":
            if depth > 1:
                return ("var", self.rng.choice(ints))
            return ("add", self.int_expr(scope, depth + 1), self.int_expr(scope, depth + 1))
        if c == "len":
            return ("len", self.rng.choice(scope["str"]))
        return ("veclen", self.rng.choice(scope["vec"]))

    def block(self, scope, depth, coroutine, size):
        stmts = []
        scope = {k: list(v) for k, v in scope.items()}
        for _ in range(size):
            s = self.stmt(scope, depth, coroutine)
            if s is not None:
                stmts.append(s)
        return stmts

    def stmt(self, scope, depth, coroutine):
        kinds = ["int", "int"]
        if self.strings:
            kinds += ["to", "to", "cat", "keep", "vec", "push", "push"]
        if coroutine:
            kinds += ["yield", "yield", "yield"]
        if depth < 2:
            kinds += ["if", "fold"]
        if not coroutine and self.strings and scope["str"] and depth > 0:
            kinds.append("ret")
        k = self.rng.choice(kinds)
        if k == "int":
            n = self.fresh("n")
            s = Stmt("int", name=n, expr=self.int_expr(scope))
            scope["int"].append(n)
            return s
        if k == "to":
            n = self.fresh("s")
            s = Stmt("to", name=n, expr=self.int_expr(scope))
            scope["str"].append(n)
            return s
        if k == "cat":
            if len(scope["str"]) < 1:
                return None
            n = self.fresh("s")
            s = Stmt("cat", name=n, a=self.rng.choice(scope["str"]), b=self.rng.choice(scope["str"]))
            scope["str"].append(n)
            return s
        if k == "keep":
            if not scope["str"]:
                return None
            n = self.fresh("s")
            s = Stmt("keep", name=n, a=self.rng.choice(scope["str"]))
            scope["str"].append(n)
            return s
        if k == "vec":
            if not scope["str"]:
                return None
            n = self.fresh("v")
            s = Stmt("vec", name=n, a=self.rng.choice(scope["str"]))
            scope["vec"].append(n)
            return s
        if k == "push":
            if not scope["vec"] or not scope["str"]:
                return None
            return Stmt("push", vec=self.rng.choice(scope["vec"]), a=self.rng.choice(scope["str"]))
        if k == "yield":
            return Stmt("yield", expr=self.int_expr(scope))
        if k == "ret":
            return Stmt("ret", cond=self.cond(scope), a=self.rng.choice(scope["str"]))
        if k == "if":
            cond = self.cond(scope)
            then = self.block(scope, depth + 1, coroutine, self.rng.randint(1, 3))
            other = self.block(scope, depth + 1, coroutine, self.rng.randint(0, 3))
            return Stmt("if", cond=cond, then=then, other=other)
        # fold
        n = self.fresh("f")
        i = self.fresh("i")
        acc = self.fresh("a")
        init = self.int_expr(scope)
        inner = {k2: list(v) for k2, v in scope.items()}
        inner["int"] += [i, acc]
        body = self.block(inner, depth + 1, coroutine, self.rng.randint(1, 4))
        # The body's value: the next intermediate, over what is in scope at
        # its end (the body's own bindings included).
        end = {k2: list(v) for k2, v in inner.items()}
        for st in body:
            if st.kind == "int":
                end["int"].append(st.name)
            elif st.kind in ("to", "cat", "keep"):
                end["str"].append(st.name)
            elif st.kind == "vec":
                end["vec"].append(st.name)
        last = ("add", ("var", acc), self.int_expr(end))
        s = Stmt("fold", name=n, i=i, acc=acc, init=init, body=body, last=last)
        scope["int"].append(n)
        return s

    def cond(self, scope):
        # Only conditions no analysis decides (a parameter's value): the
        # model takes every branch as possible, and so must the compiler.
        c = self.rng.choice(["flag", "cmp"])
        if c == "flag":
            return ("flag",)
        return ("gt", ("var", "seed"), ("lit", self.rng.randint(0, 9)))


# ---------------------------------------------------------------------------
# Botlish text, with every statement's line recorded


def expr_text(e):
    k = e[0]
    if k == "lit":
        return str(e[1])
    if k == "var":
        return e[1]
    if k == "add":
        return f"{expr_text(e[1])} + {expr_text(e[2])}"
    if k == "len":
        return f"std::str::length({e[1]})"
    if k == "veclen":
        return f"std::mutable_vector::length({e[1]})"
    if k == "flag":
        return "flag"
    if k == "gt":
        return f"{expr_text(e[1])} > {expr_text(e[2])}"
    raise ValueError(k)


class Writer:
    def __init__(self):
        self.lines = []

    def emit(self, indent, text):
        self.lines.append("    " * indent + text)
        return len(self.lines)

    def block(self, stmts, indent):
        for s in stmts:
            self.stmt(s, indent)

    def stmt(self, s, indent):
        k = s.kind
        if k == "int":
            s.line = self.emit(indent, f"{s.name} = {expr_text(s.expr)}")
        elif k == "to":
            s.line = self.emit(indent, f"{s.name} = std::int::to_string({expr_text(s.expr)})")
        elif k == "cat":
            s.line = self.emit(indent, f"{s.name} = {s.a}.concat({s.b})")
        elif k == "keep":
            s.line = self.emit(indent, f"{s.name} = keep({s.a})")
        elif k == "vec":
            s.line = self.emit(indent, f"{s.name} = std::mutable_vector::from_list([{s.a}])")
        elif k == "push":
            s.line = self.emit(indent, f"{s.vec}.push({s.a})")
        elif k == "yield":
            s.line = self.emit(indent, f"yield {expr_text(s.expr)}")
        elif k == "ret":
            s.line = self.emit(indent, f"if {expr_text(s.cond)}:")
            self.emit(indent + 1, f"return {s.a}")
        elif k == "if":
            s.line = self.emit(indent, f"if {expr_text(s.cond)}:")
            if s.then:
                self.block(s.then, indent + 1)
            else:
                self.emit(indent + 1, "0")
            if s.other:
                self.emit(indent, "else:")
                self.block(s.other, indent + 1)
        elif k == "fold":
            s.line = self.emit(indent, f"{s.name} = fold {s.i} from 0 to 3 with intermediate {s.acc} {expr_text(s.init)}:")
            self.block(s.body, indent + 1)
            self.emit(indent + 1, expr_text(s.last))
        else:
            raise ValueError(k)


def expr_reads(e):
    k = e[0]
    if k == "var":
        return {e[1]}
    if k == "add":
        return expr_reads(e[1]) | expr_reads(e[2])
    if k in ("len", "veclen"):
        return {e[1]}
    if k == "flag":
        return {"flag"}
    if k == "gt":
        return expr_reads(e[1]) | expr_reads(e[2])
    return set()


def stmt_reads(s):
    """Everything statement S reads, nested statements included."""
    k = s.kind
    if k in ("int", "to", "yield"):
        return expr_reads(s.expr)
    if k == "cat":
        return {s.a, s.b}
    if k in ("keep", "vec"):
        return {s.a}
    if k == "push":
        return {s.vec, s.a}
    if k == "ret":
        return expr_reads(s.cond) | {s.a}
    if k == "if":
        r = expr_reads(s.cond)
        for t in s.then + s.other:
            r |= stmt_reads(t)
        return r
    if k == "fold":
        r = expr_reads(s.init) | expr_reads(s.last)
        for t in s.body:
            r |= stmt_reads(t)
        return r
    raise ValueError(k)


def stmt_defines(s):
    k = s.kind
    if k in ("int", "to", "cat", "keep", "vec", "fold"):
        return {s.name}
    return set()


def seq_reads(stmts):
    r = set()
    for s in stmts:
        r |= stmt_reads(s)
    return r


def ends(s):
    """1 if statement S never completes normally (a return in every path)."""
    return False


# ---------------------------------------------------------------------------
# Liveness after each yield of worker


def suspensions(body, result_reads):
    """{line: set of names live after the yield on that line}."""
    out = {}

    def walk(stmts, after, fold_ctx):
        # AFTER: what is live after the sequence completes. FOLD_CTX: the
        # innermost enclosing fold's facts, for positions.
        for idx, s in enumerate(stmts):
            rest = stmts[idx + 1:]
            live_after = seq_live(rest, after)
            if s.kind == "yield":
                out[s.line] = set(live_after)
            elif s.kind == "if":
                walk(s.then, live_after, fold_ctx)
                walk(s.other, live_after, fold_ctx)
            elif s.kind == "fold":
                head = fold_head(s, live_after)
                # After the body completes: the next intermediate is
                # computed (reads LAST), then the head (minus the
                # intermediate, which that completion makes again).
                body_after = (head - {s.acc}) | expr_reads(s.last)
                walk(s.body, body_after, s)

    def seq_live(stmts, after):
        # Live before STMTS, given AFTER: every read of the rest (each name
        # is defined once and read only after its definition), then AFTER,
        # minus what the rest defines.
        live = set(after)
        for s in reversed(stmts):
            if s.kind == "fold":
                live = fold_head(s, live) | expr_reads(s.init)
                live -= {s.acc, f"pos@{s.line}"}
                live -= {s.name}
            elif s.kind == "if":
                live = (seq_live(s.then, live) | seq_live(s.other, live)) | expr_reads(s.cond)
            elif s.kind == "ret":
                live = live | expr_reads(s.cond) | {s.a}
            else:
                live = (live - stmt_defines(s)) | stmt_reads(s)
        return live

    def fold_head(s, after):
        # Live at the fold's head: its position and intermediate, every
        # outer binding its body or LAST reads (the next iteration reads
        # them again), and what is live after the fold (but its own result).
        own = {s.i, s.acc}
        for t in s.body:
            own |= all_defines(t)
        reads = (seq_reads(s.body) | expr_reads(s.last)) - own
        return {f"pos@{s.line}", s.acc} | reads | (set(after) - {s.name})

    walk(body, set(result_reads), None)
    return out


def all_defines(s):
    d = stmt_defines(s)
    if s.kind == "if":
        for t in s.then + s.other:
            d |= all_defines(t)
    elif s.kind == "fold":
        d |= {s.i, s.acc}
        for t in s.body:
            d |= all_defines(t)
    return d


# ---------------------------------------------------------------------------
# Containment and verdicts


def producers(body, result_vars, yields_live):
    """[{line kind verdicts}] for every producer of BODY.

    RESULT_VARS: the bindings the function's returned values may be.
    YIELDS_LIVE: {yield line: live names} (worker), {} for make.
    """
    sites = []          # (site, line, kind, folds, path)
    points = {}         # binding -> set of sites it may be
    contains = {}       # site -> set of sites it may hold
    defined_in = {}     # binding -> tuple of enclosing folds' lines
    yield_paths = {}    # yield line -> path

    def walk(stmts, folds, path):
        for idx, s in enumerate(stmts):
            here = path + ((id(stmts), idx),)
            k = s.kind
            for name in stmt_defines(s):
                defined_in[name] = folds
            if k == "to":
                site = f"str@{s.line}"
                sites.append((site, s.line, "str", folds, here))
                points[s.name] = {site}
                contains.setdefault(site, set())
            elif k == "cat":
                site = f"str@{s.line}"
                sites.append((site, s.line, "str", folds, here))
                points[s.name] = {site}
                contains[site] = set(points.get(s.a, set())) | set(points.get(s.b, set()))
            elif k == "keep":
                points[s.name] = set(points.get(s.a, set()))
            elif k == "vec":
                lst = f"list@{s.line}"
                vec = f"mutvec@{s.line}"
                sites.append((lst, s.line, "list", folds, here))
                sites.append((vec, s.line, "mutvec", folds, here))
                contains[lst] = set(points.get(s.a, set()))
                contains[vec] = {lst} | set(points.get(s.a, set()))
                points[s.name] = {vec}
            elif k == "push":
                for v in points.get(s.vec, set()):
                    contains.setdefault(v, set()).update(points.get(s.a, set()))
            elif k == "yield":
                yield_paths[s.line] = here
            elif k == "if":
                walk(s.then, folds, here + (("then",),))
                walk(s.other, folds, here + (("else",),))
            elif k == "fold":
                defined_in[s.i] = folds + (s.line,)
                defined_in[s.acc] = folds
                walk(s.body, folds + (s.line,), here + (("body", s.line),))

    walk(body, (), ())

    def reach(start):
        seen = set(start)
        work = list(start)
        while work:
            o = work.pop()
            for c in contains.get(o, set()):
                if c not in seen:
                    seen.add(c)
                    work.append(c)
        return seen

    escaped = set()
    for v in result_vars:
        escaped |= reach(points.get(v, set()))

    def precedes(p, y):
        # 1 if the statement at path P may run before the one at path Y:
        # earlier in a common sequence, or both inside a fold (an earlier
        # iteration ran everything of its body).
        common_folds = False
        for a, b in zip(p, y):
            if a == b:
                if a[0] == "body":
                    common_folds = True
                continue
            if isinstance(a[0], int) and isinstance(b[0], int) and a[0] == b[0]:
                return a[1] < b[1] or common_folds
            return common_folds
        return common_folds

    result = []
    for site, line, kind, folds, path in sites:
        verdicts = {}
        act = "escapes" if site in escaped else "confined"
        verdicts["activation"] = act
        depth = 0
        for f in folds:
            depth += 1
            if act == "escapes":
                verdicts[f"iteration@{f}"] = "escapes"
                continue
            outside = [b for b, fs in defined_in.items() if fs[:depth] != folds[:depth]]
            outside += ["seed", "flag"]
            hit = False
            for b in outside:
                if site in reach(points.get(b, set())):
                    hit = True
                    break
            verdicts[f"iteration@{f}"] = "escapes" if hit else "confined"
        if act == "escapes":
            verdicts["segment"] = "escapes"
        else:
            seg = "confined"
            for yl, live in yields_live.items():
                if not precedes(path, yield_paths[yl]):
                    continue
                for b in live:
                    if b.startswith("pos@"):
                        continue
                    if site in reach(points.get(b, set())):
                        seg = "escapes"
                        break
                if seg == "escapes":
                    break
            verdicts["segment"] = seg
        result.append({"line": line, "kind": kind, "verdicts": verdicts})
    return result


def returned_vars(body, last):
    r = {last} if last else set()

    def walk(stmts):
        for s in stmts:
            if s.kind == "ret":
                r.add(s.a)
            elif s.kind == "if":
                walk(s.then)
                walk(s.other)
            elif s.kind == "fold":
                walk(s.body)

    walk(body)
    return r


# ---------------------------------------------------------------------------
# A program


def program(rng, strings=True):
    gen = Gen(rng, strings)
    w = Writer()
    w.emit(0, "import std::coroutine")
    if strings:
        w.emit(0, "import std::int")
        w.emit(0, "import std::str")
        w.emit(0, "import std::mutable_vector")
        w.emit(0, "")
        w.emit(0, "fn keep(s: str) -> str:")
        w.emit(1, "s")
    w.emit(0, "")
    # worker: a coroutine.
    scope = {"int": ["seed"], "str": [], "vec": []}
    wbody = gen.block(scope, 0, True, rng.randint(3, 8))
    if not any(s.kind == "yield" for s in wbody):
        wbody.append(Stmt("yield", expr=("var", "seed")))
    end = {"int": ["seed"], "str": [], "vec": []}
    for s in wbody:
        if s.kind in ("int", "fold"):
            end["int"].append(s.name)
    wlast = ("add", ("var", "seed"), gen.int_expr(end))
    w.emit(0, "fn worker(seed: int, flag: bool) -> int:")
    w.block(wbody, 1)
    w.emit(1, expr_text(wlast))
    w.emit(0, "")
    mbody = []
    mlast = None
    if strings:
        scope = {"int": ["seed"], "str": [], "vec": []}
        mbody = gen.block(scope, 0, False, rng.randint(3, 8))
        first = Stmt("to", name=gen.fresh("s"), expr=("var", "seed"))
        mbody.insert(0, first)
        strs = [first.name] + [s.name for s in mbody if s.kind in ("to", "cat", "keep")]
        mlast = rng.choice(strs)
        w.emit(0, "fn make(seed: int, flag: bool) -> str:")
        w.block(mbody, 1)
        w.emit(1, mlast)
        w.emit(0, "")
    w.emit(0, "coroutine {step, first} = worker(3, true)")
    w.emit(0, "r = step()")
    if strings:
        w.emit(0, "x = make(5, false)")
        w.emit(0, "[first, r, std::str::length(x)]")
    else:
        w.emit(0, "[first, r]")
    text = "\n".join(w.lines) + "\n"
    live = suspensions(wbody, expr_reads(wlast))
    facts = {
        "suspensions": [{"line": line, "live": sorted(names)} for line, names in sorted(live.items())],
        "producers": {
            "worker": producers(wbody, set(), live),
            "make": producers(mbody, returned_vars(mbody, mlast), {}) if strings else [],
        },
    }
    return text, facts


def generate(seed, count, out, strings=True):
    os.makedirs(out, exist_ok=True)
    rng = random.Random(seed)
    for k in range(count):
        text, facts = program(rng, strings)
        name = f"g{seed}_{k}"
        with open(os.path.join(out, name + ".bot"), "w", encoding="utf-8") as f:
            f.write(text)
        with open(os.path.join(out, name + ".json"), "w", encoding="utf-8") as f:
            json.dump(facts, f, indent=1, sort_keys=True)


# ---------------------------------------------------------------------------
# Self test: the model on hand-written programs whose facts are known


def selftest():
    # p18's shape: x is read only in the branch that never resumes.
    body = [
        Stmt("int", name="x", expr=("add", ("var", "seed"), ("lit", 3))),
        Stmt("int", name="y", expr=("add", ("var", "seed"), ("lit", 1))),
        Stmt("if", cond=("flag",),
             then=[Stmt("yield", expr=("var", "y"))],
             other=[Stmt("int", name="z", expr=("var", "x"))]),
    ]
    w = Writer()
    w.block(body, 1)
    live = suspensions(body, set())
    assert live == {body[2].then[0].line: set()}, live
    # A binding read after a yield is live across it; one read before is not.
    body = [
        Stmt("int", name="k", expr=("var", "seed")),
        Stmt("int", name="d", expr=("var", "seed")),
        Stmt("yield", expr=("var", "d")),
        Stmt("int", name="a", expr=("add", ("var", "seed"), ("var", "k"))),
    ]
    w = Writer()
    w.block(body, 1)
    live = suspensions(body, {"a"})
    assert live == {body[2].line: {"k", "seed"}}, live
    # A fold: its position and intermediate, and outer bindings its body
    # reads, are live at a yield in its body.
    fold = Stmt("fold", name="f", i="i", acc="a", init=("lit", 0),
                body=[Stmt("yield", expr=("var", "a"))],
                last=("add", ("var", "a"), ("var", "o")))
    body = [Stmt("int", name="o", expr=("var", "seed")), fold]
    w = Writer()
    w.block(body, 1)
    live = suspensions(body, {"f"})
    assert live == {fold.body[0].line: {f"pos@{fold.line}", "a", "o"}}, live
    # Containment: a String pushed into an outer vector escapes the fold's
    # iteration, one kept in a vector of the iteration does not.
    inner = [Stmt("to", name="t", expr=("var", "i")),
             Stmt("push", vec="v", a="t"),
             Stmt("to", name="u", expr=("var", "i")),
             Stmt("vec", name="w", a="u")]
    fold = Stmt("fold", name="f", i="i", acc="a", init=("lit", 0), body=inner,
                last=("add", ("var", "a"), ("lit", 1)))
    body = [Stmt("to", name="s", expr=("var", "seed")), Stmt("vec", name="v", a="s"), fold]
    w = Writer()
    w.block(body, 1)
    got = {(p["line"], p["kind"]): p["verdicts"] for p in producers(body, {"s"}, {})}
    f = f"iteration@{fold.line}"
    assert got[(inner[0].line, "str")] == {"activation": "confined", f: "escapes", "segment": "confined"}, got
    assert got[(inner[2].line, "str")] == {"activation": "confined", f: "confined", "segment": "confined"}, got
    assert got[(body[0].line, "str")]["activation"] == "escapes", got
    # Determinism.
    a = program(random.Random(7))
    b = program(random.Random(7))
    assert a == b
    print("oracle selftest: ok")


if __name__ == "__main__":
    if len(sys.argv) >= 2 and sys.argv[1] == "selftest":
        selftest()
    elif len(sys.argv) >= 5 and sys.argv[1] == "generate":
        strings = True
        if "--strings" in sys.argv:
            strings = sys.argv[sys.argv.index("--strings") + 1] != "0"
        generate(int(sys.argv[2]), int(sys.argv[3]), sys.argv[4], strings)
    else:
        print(__doc__)
        sys.exit(2)
