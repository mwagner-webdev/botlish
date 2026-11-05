#!/usr/bin/env python3
# oracle.py -- an independent model of the component analyses of
# parameterized nominal types (PARAMETERIZED-DECLARATION-SUMMARIES-
# MILESTONE-1.md, "Oracle").
#
# It shares no code and no algorithm with the compiler's declaration
# summaries (hir/summaries.tcl). The compiler summarizes each declaration
# once, slot by slot, by probing it with one representative argument per
# class and joining the slots' entries. This model never probes and never
# decomposes by slot: it answers an application S[A1, ..., An] by abstract
# interpretation over the finite graph whose nodes are (declaration, the
# abstract values of all its arguments together), solved as one least
# fixpoint by a worklist -- so it also checks that the compiler's per-slot
# join is exact. Neither unfolds an application: a node's arguments are
# abstract values, finitely many per declaration.
#
# Its type language is the fuzzer's (audit/declaration-summaries/tools/
# fuzz.tcl writes the same declarations as Botlish source):
#
#   int str               scalars
#   any                   (an argument only) the unknown type
#   C                     Coroutine{args: [Message], return: Event}
#   F                     Fn{args: [int], return: int}
#   G                     Fn{args: [any], return: int}
#   E                     Fn{args: [], return: int, errors: [Oops]}
#   V                     MutableVector[int]
#   ["List", t]           List[t]
#   ["Arg", t]            Fn{args: [t], return: int}
#   ["Ret", t]            Fn{args: [], return: t}
#   ["App", S, [t, ...]]  an application of declaration S
#   ["Slot", i]           (in a declaration's fields) its i-th slot
#
# and the properties it decides are the compiler's for those forms:
#
#   affine     a value owns a coroutine handle (hir::types::IsAffine)
#   bearing    an erased value forgets an obligation (hir::callables::Bearing)
#   totality   total / unknown / none (hir::types::Totality, both operations
#              agree on these forms)
#   carried    the declared errors an erased value carries
#              (hir::callables::CarriedErrors)
#   mutable    a value holds a MutableVector or MutableArray
#              (hir::types::MentionsMutable)
#
#   python3 -I oracle.py SPEC.json      answers every query of SPEC on stdout
#   python3 -I oracle.py selftest       checks the model on hand-made cases
#
# SPEC: {"decls": {NAME: {"slots": N, "fields": [TYPE, ...]}, ...},
#        "queries": [TYPE, ...]}; the answer is one JSON object per query:
# {"affine": 0|1, "bearing": 0|1, "totality": "total"|"unknown"|"none",
#  "carried": [ERROR, ...], "mutable": 0|1}.
import json
import sys

TOTALITY = ["total", "unknown", "none"]


class Property:
    """A property: its abstract value of every atom, of every constructor
    applied to its operand's abstract value, its bottom and its join."""

    def atom(self, name):
        raise NotImplementedError

    def list_of(self, v):
        raise NotImplementedError

    def arg_of(self, v, is_any):
        raise NotImplementedError

    def ret_of(self, v):
        raise NotImplementedError

    bottom = None

    def join(self, a, b):
        raise NotImplementedError


class Affine(Property):
    bottom = 0

    def atom(self, name):
        return 1 if name == "C" else 0

    def list_of(self, v):
        return v

    def arg_of(self, v, is_any):
        return 0          # a function value owns nothing

    def ret_of(self, v):
        return 0

    def join(self, a, b):
        return max(a, b)


class Bearing(Property):
    # The value is (bears, is-not-any): an argument at a Fn's argument
    # position obliges a caller exactly when it is not `any`.
    bottom = (0, 1)

    def atom(self, name):
        bears = {"F": 1, "E": 1}.get(name, 0)
        return (bears, 0 if name == "any" else 1)

    def list_of(self, v):
        return (v[0], 1)

    def arg_of(self, v, is_any):
        # (v[1] is 0 for `any` alone: an argument bound to it, or written.)
        return (v[1], 1)

    def ret_of(self, v):
        return (v[0], 1)

    def join(self, a, b):
        # Only the bears part joins (a struct is never `any`).
        return (max(a[0], b[0]), 1)


class Totality(Property):
    bottom = 0

    def atom(self, name):
        return {"int": 0, "str": 0, "any": 1}.get(name, 2)   # C F G E V: none

    def list_of(self, v):
        return v

    def arg_of(self, v, is_any):
        return 2           # a function has no equality

    def ret_of(self, v):
        return 2

    def join(self, a, b):
        return max(a, b)


class Carried(Property):
    bottom = frozenset()

    def atom(self, name):
        return frozenset(["Oops"]) if name == "E" else frozenset()

    def list_of(self, v):
        return v

    def arg_of(self, v, is_any):
        return frozenset()  # an argument type carries nothing

    def ret_of(self, v):
        return v

    def join(self, a, b):
        return a | b


class Mutable(Property):
    bottom = 0

    def atom(self, name):
        return 1 if name == "V" else 0

    def list_of(self, v):
        return v

    def arg_of(self, v, is_any):
        return 0           # a function is no place

    def ret_of(self, v):
        return 0

    def join(self, a, b):
        return max(a, b)


PROPERTIES = {"affine": Affine(), "bearing": Bearing(), "totality": Totality(),
              "carried": Carried(), "mutable": Mutable()}


class Model:
    def __init__(self, decls, prop):
        self.decls = decls
        self.prop = prop
        self.values = {}        # (decl, args) -> abstract value
        self.users = {}         # node -> nodes whose value read it

    def eval(self, t, env, reader):
        """The abstract value of type T, its slots ENV's values; READER the
        node whose value is being computed (a dependency edge)."""
        p = self.prop
        if isinstance(t, str):
            return p.atom(t)
        tag = t[0]
        if tag == "Slot":
            return env[t[1]]
        if tag == "List":
            return p.list_of(self.eval(t[1], env, reader))
        if tag == "Arg":
            return p.arg_of(self.eval(t[1], env, reader), t[1] == "any")
        if tag == "Ret":
            return p.ret_of(self.eval(t[1], env, reader))
        if tag == "App":
            args = tuple(self.eval(a, env, reader) for a in t[2])
            node = (t[1], args)
            if reader is not None:
                self.users.setdefault(node, set()).add(reader)
            if node not in self.values:
                self.values[node] = p.bottom
                self.solve(node)
            return self.values[node]
        raise ValueError("unknown type %r" % (t,))

    def compute(self, node):
        name, args = node
        value = self.prop.bottom
        for field in self.decls[name]["fields"]:
            value = self.prop.join(value, self.eval(field, list(args), node))
        return value

    def solve(self, start):
        work = [start]
        while work:
            node = work.pop()
            value = self.compute(node)
            if value != self.values[node]:
                self.values[node] = value
                work.extend(self.users.get(node, ()))

    def answer(self, t):
        # A concrete type: its slots are bound to nothing.
        return self.eval(t, [], None)


def answers(decls, query):
    result = {}
    for name, prop in PROPERTIES.items():
        # One fresh model per query: an answer never depends on an earlier one.
        v = Model(decls, prop).answer(query)
        if name == "bearing":
            v = v[0]
        elif name == "totality":
            v = TOTALITY[v]
        elif name == "carried":
            v = sorted(v)
        result[name] = v
    return result


def selftest():
    decls = {
        "Box": {"slots": 1, "fields": [["Slot", 0]]},
        "Phantom": {"slots": 1, "fields": ["int"]},
        "W": {"slots": 1, "fields": [["List", ["App", "W", [["List", ["Slot", 0]]]]]]},
        "Mixed": {"slots": 2, "fields": [["Slot", 0], ["List", ["App", "Mixed", [["Slot", 0], ["List", ["Slot", 1]]]]]]},
        "Handler": {"slots": 1, "fields": [["Arg", ["Slot", 0]]]},
        "A": {"slots": 1, "fields": [["List", ["App", "B", [["List", ["Slot", 0]]]]]]},
        "B": {"slots": 1, "fields": [["App", "A", [["Slot", 0]]], ["Slot", 0]]},
        "Tree": {"slots": 0, "fields": [["List", ["App", "Tree", []]], "F"]},
    }
    cases = [
        (["App", "Box", ["int"]], {"affine": 0, "bearing": 0, "totality": "total", "carried": [], "mutable": 0}),
        (["App", "Box", ["C"]], {"affine": 1, "bearing": 0, "totality": "none", "carried": [], "mutable": 0}),
        (["App", "Box", ["E"]], {"affine": 0, "bearing": 1, "totality": "none", "carried": ["Oops"], "mutable": 0}),
        (["App", "Phantom", ["C"]], {"affine": 0, "bearing": 0, "totality": "total", "carried": [], "mutable": 0}),
        (["App", "W", ["C"]], {"affine": 0, "bearing": 0, "totality": "total", "carried": [], "mutable": 0}),
        (["App", "W", ["F"]], {"affine": 0, "bearing": 0, "totality": "total", "carried": [], "mutable": 0}),
        (["App", "Mixed", ["int", "C"]], {"affine": 0, "bearing": 0, "totality": "total", "carried": [], "mutable": 0}),
        (["App", "Mixed", ["C", "int"]], {"affine": 1, "bearing": 0, "totality": "none", "carried": [], "mutable": 0}),
        (["App", "Handler", ["int"]], {"affine": 0, "bearing": 1, "totality": "none", "carried": [], "mutable": 0}),
        (["App", "Handler", ["any"]], {"affine": 0, "bearing": 0, "totality": "none", "carried": [], "mutable": 0}),
        (["App", "A", ["V"]], {"affine": 0, "bearing": 0, "totality": "none", "carried": [], "mutable": 1}),
        (["App", "A", ["int"]], {"affine": 0, "bearing": 0, "totality": "total", "carried": [], "mutable": 0}),
        (["App", "Tree", []], {"affine": 0, "bearing": 1, "totality": "none", "carried": [], "mutable": 0}),
    ]
    failures = 0
    for query, expected in cases:
        got = answers(decls, query)
        if got != expected:
            failures += 1
            print("FAIL", json.dumps(query), "got", got, "expected", expected)
    print("oracle selftest: %d cases, %d failures" % (len(cases), failures))
    return failures == 0


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    if sys.argv[1] == "selftest":
        return 0 if selftest() else 1
    spec = json.load(open(sys.argv[1]))
    for query in spec["queries"]:
        print(json.dumps(answers(spec["decls"], query), sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
