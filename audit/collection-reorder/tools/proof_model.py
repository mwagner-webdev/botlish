#!/usr/bin/env python3
"""proof_model.py -- an independent model of which reorders the compiler
admits (PROVEN-COLLECTION-REORDERING.md, "Relational proof"), for
audit/collection-reorder/tools/proofs.tcl.

It reads the generator's own statement tree (JSON on standard input), never
the compiler's HIR, and applies the documented rules:

  * every place (a map or set variable, a box's field) has a members token;
    parameters and anything a function returns have tokens of their own;
  * `o = m.order()` and `o = m.validate_order(c)` (its result) give o m's
    token; a copy has its source's token; a box literal gives its fields
    their values' tokens;
  * a membership change of a place (set, remove, clear, add, a place call
    over it or over a box holding it) gives the place a fresh token;
  * `m.reorder(o)` (and `s.reorder(o)` of a set) is admitted exactly when
    o's token is m's, and changes no token;
  * an `if` joins its branches: a place keeps its token when both give it
    the same one (a branch that returns gives nothing), an `if` value
    likewise; a handled validation joins its result with the handler's
    value;
  * a loop gives every place it may change (anywhere in its body) a fresh
    token on entry, walks its body once, and gives them fresh tokens again
    after it.

Output: the ids of the reorder sites it rejects, one JSON list.
"""

import json
import sys


class Model:
    def __init__(self):
        self.next = 0
        self.rejected = []

    def fresh(self):
        self.next += 1
        return ("t", self.next)

    def read(self, state, place):
        # A place no statement has set yet (a parameter) has its own token,
        # the same on every path.
        return state.get(place, ("init", place))

    def kill(self, state, place):
        for p in list(state):
            if p == place or p.startswith(place + "."):
                state[p] = self.fresh()
        state[place] = self.fresh()

    def expr(self, state, e):
        if e["k"] == "order":
            return self.read(state, e["src"])
        if e["k"] == "var":
            return self.read(state, e["v"])
        return self.fresh()

    def join(self, a, b):
        if a is None:
            return b
        if b is None:
            return a
        result = {}
        for p in set(a) | set(b):
            x = a.get(p, ("init", p))
            y = b.get(p, ("init", p))
            result[p] = x if x is not None and x == y else self.fresh()
        return result

    def written(self, body):
        places = set()
        for s in body:
            k = s["k"]
            if k == "kill":
                places.add(s["place"])
            elif k in ("if",):
                places |= self.written(s["then"]) | self.written(s["else"])
            elif k in ("loop", "early"):
                places |= self.written(s["body"])
            elif k == "validate" and s["h"]["k"] == "kills":
                places.add(s["h"]["place"])
        return places

    def block(self, state, body):
        """Walks BODY from STATE: the state at its end, or None (it never
        completes)."""
        state = dict(state)
        for s in body:
            state = self.stmt(state, s)
            if state is None:
                return None
        return state

    def stmt(self, state, s):
        k = s["k"]
        if k == "order":
            state[s["dst"]] = self.read(state, s["src"])
        elif k == "validate":
            success = self.read(state, s["map"])
            h = s["h"]
            if h["k"] == "return":
                state[s["dst"]] = success
            elif h["k"] == "kills":
                other = dict(state)
                self.kill(other, h["place"])
                value = self.expr(other, h["e"])
                joined = self.join(state, other)
                joined[s["dst"]] = success if success == value else self.fresh()
                state = joined
            else:
                value = self.expr(state, h["e"])
                state[s["dst"]] = success if success == value else self.fresh()
        elif k in ("copyo", "copym"):
            state[s["dst"]] = self.read(state, s["src"])
        elif k == "box":
            state[s["dst"] + ".m"] = self.read(state, s["m"])
            state[s["dst"] + ".o"] = self.read(state, s["o"])
        elif k == "copyw":
            state[s["dst"] + ".m"] = self.read(state, s["src"] + ".m")
            state[s["dst"] + ".o"] = self.read(state, s["src"] + ".o")
        elif k == "kill":
            self.kill(state, s["place"])
        elif k == "read":
            pass
        elif k == "reorder":
            if self.read(state, s["order"]) != self.read(state, s["place"]):
                self.rejected.append(s["site"])
        elif k == "helper":
            state[s["dst"]] = self.fresh()
        elif k == "if":
            state = self.join(self.block(state, s["then"]), self.block(state, s["else"]))
        elif k == "ifv":
            a = self.expr(state, s["then"])
            b = self.expr(state, s["else"])
            state[s["dst"]] = a if a == b else self.fresh()
        elif k == "early":
            # `if b: BODY; return`: the branch never completes.
            self.block(state, s["body"])
        elif k == "loop":
            entry = dict(state)
            for p in self.written(s["body"]):
                self.kill(entry, p)
            self.block(entry, s["body"])
            for p in self.written(s["body"]):
                self.kill(state, p)
        else:
            raise ValueError("unknown statement %r" % (k,))
        return state


def main():
    program = json.loads(sys.stdin.read())
    model = Model()
    model.block({}, program)
    print(json.dumps(model.rejected))
    return 0


if __name__ == "__main__":
    sys.exit(main())
