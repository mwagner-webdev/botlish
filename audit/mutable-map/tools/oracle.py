#!/usr/bin/env python3
"""oracle.py -- the independent model of std::mutable_map and std::mutable_set
(ORDERED-MUTABLE-MAP-SET.md, "Oracle").

It shares nothing with the Botlish implementation but the meaning of the
public operations. A map is modelled by a Python dict, whose iteration order
is insertion order with exactly the collection's rules: setting an existing
key keeps its position, deleting a key and setting it again appends it. A set
is modelled independently of the map: a membership set plus the ordered list
of its live elements.

Keys are integers: the fuzzer builds every Botlish key of a program from one
integer id by a construction that is injective in the id (an Int, its
decimal text, a struct holding it, a List starting with it, an enum case of a
small domain), so two Botlish keys are equal exactly when their ids are.
Values are integers.

Input (standard input): a JSON list of operations, each a list
[OP, ...] on variables named by strings:

    ["new", V, "map"|"set"]        a new empty collection V
    ["copy", V, W]                 W is a logical copy of V
    ["set", V, K, X]               map V: key K's value is X
    ["at", V, K]                   map V: observe K's value, or -1
    ["contains", V, K]             observe 1 if K is a key/element, else 0
    ["remove", V, K]               map: observe the removed value or -1;
                                   set: observe 1 if removed, else 0
    ["add", V, K]                  set: observe 1 if added, else 0
    ["length", V]                  observe the count
    ["clear", V]
    ["iterate", V]                 observe -9, then each entry (map: K, X;
                                   set: K) in iteration order
    ["bump", V, OFFSET]            map: for each entry of a snapshot of V,
                                   in order: observe K, set K's value to
                                   X + 1, set key K + OFFSET to X;
                                   set: for each element K of a snapshot,
                                   observe K, remove K, add K + OFFSET
    ["fill", V, A, B, STEP, X]     map: set each key K of A, A+STEP, ... < B
                                   to X + K
    ["fill", V, A, B, STEP]        set: add each of them
    ["drain", V, A, B, STEP]       remove keys A, A+STEP, ... < B (map or
                                   set), observing nothing
    ["reorder", V, MODE, B, ABSENT]
                                   (PROVEN-COLLECTION-REORDERING.md) a
                                   candidate order CANDIDATE(L, MODE, B,
                                   ABSENT) of V's current order L (below),
                                   as a set (a repeated key once, at its
                                   first place): when its members are
                                   exactly V's, V's order becomes it,
                                   contents unchanged; otherwise observe
                                   -7 (the mismatch) and V is unchanged.
                                   Then observe V's count
    ["reorder-same", V]            V reordered by its own current order:
                                   nothing changes; observe V's count
    ["reorder-via-order", V, B]    V's order, rotated by B, then V
                                   reordered by it; observe V's count
    ["reloop", V]                  for each key K of a snapshot of V, in
                                   order: observe K, then reorder V by its
                                   current order reflected (MODE 1, B 0)

CANDIDATE(L, MODE, B, ABSENT), n = len(L):
    0  rotated:   L[(i + B) mod n] for i < n
    1  reflected: L[(B - i) mod n] for i < n
    2  L's even positions, then its odd ones
    3  L without its last key
    4  L, then ABSENT
    5  ABSENT, then L without its first key
    6  L shuffled: for i from n - 1 down to 1, positions i and
       (B * 7919 + i * 104729) mod (i + 1) swapped (Fisher-Yates, seeded
       by B)

Order is not content: the map's dict and the set's membership are what
they were; only the sequence a reorder installs changes. The model never
asks how the compiler proved an order (a proof is no run-time event).

Output: the observations, one JSON list of integers.
"""

import json
import sys


class OrderedSetModel:
    """A membership set and the ordered list of live elements."""

    def __init__(self, other=None):
        self.members = set(other.members) if other else set()
        self.order = list(other.order) if other else []

    def add(self, k):
        if k in self.members:
            return 0
        self.members.add(k)
        self.order.append(k)
        return 1

    def remove(self, k):
        if k not in self.members:
            return 0
        self.members.discard(k)
        self.order.remove(k)
        return 1

    def contains(self, k):
        return 1 if k in self.members else 0

    def clear(self):
        self.members = set()
        self.order = []

    def __len__(self):
        return len(self.order)


def candidate(order, mode, b, absent):
    n = len(order)
    if mode == 0:
        c = [order[(i + b) % n] for i in range(n)]
    elif mode == 1:
        c = [order[(b - i) % n] for i in range(n)]
    elif mode == 2:
        c = order[0::2] + order[1::2]
    elif mode == 3:
        c = order[:-1]
    elif mode == 4:
        c = order + [absent]
    elif mode == 5:
        c = [absent] + order[1:]
    elif mode == 6:
        c = list(order)
        for k in range(1, n):
            i = n - k
            j = (b * 7919 + i * 104729) % (i + 1)
            c[i], c[j] = c[j], c[i]
    else:
        raise ValueError("unknown reorder mode %r" % (mode,))
    seen = []
    for k in c:
        if k not in seen:
            seen.append(k)
    return seen


def current_order(v):
    return list(v.order) if isinstance(v, OrderedSetModel) else list(v.keys())


def install(env, var, order):
    """VAR's order becomes ORDER (a permutation of its members)."""
    v = env[var]
    if isinstance(v, OrderedSetModel):
        assert set(order) == v.members
        v.order = list(order)
    else:
        assert set(order) == set(v.keys())
        env[var] = {k: v[k] for k in order}


def reorder(env, var, mode, b, absent, out):
    order = current_order(env[var])
    c = candidate(order, mode, b, absent)
    if set(c) == set(order):
        install(env, var, c)
    else:
        out.append(-7)


def run(ops):
    env = {}
    out = []
    for op in ops:
        name = op[0]
        if name == "new":
            env[op[1]] = {} if op[2] == "map" else OrderedSetModel()
        elif name == "copy":
            v = env[op[1]]
            env[op[2]] = dict(v) if isinstance(v, dict) else OrderedSetModel(v)
        elif name == "set":
            env[op[1]][op[2]] = op[3]
        elif name == "at":
            out.append(env[op[1]].get(op[2], -1))
        elif name == "contains":
            v = env[op[1]]
            out.append(v.contains(op[2]) if isinstance(v, OrderedSetModel) else (1 if op[2] in v else 0))
        elif name == "remove":
            v = env[op[1]]
            if isinstance(v, OrderedSetModel):
                out.append(v.remove(op[2]))
            else:
                out.append(v.pop(op[2], -1))
        elif name == "add":
            out.append(env[op[1]].add(op[2]))
        elif name == "length":
            out.append(len(env[op[1]]))
        elif name == "clear":
            env[op[1]].clear()
        elif name == "iterate":
            v = env[op[1]]
            out.append(-9)
            if isinstance(v, OrderedSetModel):
                out.extend(v.order)
            else:
                for k, x in v.items():
                    out.extend([k, x])
        elif name == "bump":
            v = env[op[1]]
            offset = op[2]
            if isinstance(v, OrderedSetModel):
                for k in list(v.order):
                    out.append(k)
                    v.remove(k)
                    v.add(k + offset)
            else:
                for k, x in list(v.items()):
                    out.append(k)
                    v[k] = x + 1
                    v[k + offset] = x
        elif name == "fill":
            var, a, b, step = op[1:5]
            v = env[var]
            for k in range(a, b, step):
                if isinstance(v, OrderedSetModel):
                    v.add(k)
                else:
                    v[k] = op[5] + k
        elif name == "drain":
            _, var, a, b, step = op
            v = env[var]
            for k in range(a, b, step):
                if isinstance(v, OrderedSetModel):
                    v.remove(k)
                else:
                    v.pop(k, None)
        elif name == "reorder":
            reorder(env, op[1], op[2], op[3], op[4], out)
            out.append(len(env[op[1]]))
        elif name == "reorder-same":
            out.append(len(env[op[1]]))
        elif name == "reorder-via-order":
            order = current_order(env[op[1]])
            install(env, op[1], candidate(order, 0, op[2], None))
            out.append(len(env[op[1]]))
        elif name == "reloop":
            for k in current_order(env[op[1]]):
                out.append(k)
                order = current_order(env[op[1]])
                install(env, op[1], candidate(order, 1, 0, None))
        else:
            raise ValueError("unknown operation %r" % (name,))
    return out


def selftest():
    # The rules the collections pin, on the model itself.
    ops = [["new", "m", "map"], ["set", "m", 1, 10], ["set", "m", 2, 20], ["set", "m", 3, 30],
           ["set", "m", 2, 21], ["remove", "m", 1], ["set", "m", 1, 11], ["iterate", "m"],
           ["copy", "m", "n"], ["set", "m", 4, 40], ["length", "n"], ["length", "m"],
           ["new", "s", "set"], ["add", "s", 5], ["add", "s", 6], ["add", "s", 5], ["remove", "s", 5],
           ["add", "s", 5], ["iterate", "s"], ["bump", "s", 100], ["iterate", "s"]]
    expect = [10, -9, 2, 21, 3, 30, 1, 11, 3, 4, 1, 1, 0, 1, 1, -9, 6, 5, 6, 5, -9, 106, 105]
    got = run(ops)
    if got != expect:
        print("selftest FAILED: %r != %r" % (got, expect))
        return 1
    # Reordering (PROVEN-COLLECTION-REORDERING.md): order only, contents
    # kept; a candidate with other members is a mismatch and changes nothing.
    ops = [["new", "m", "map"], ["set", "m", 1, 10], ["set", "m", 2, 20], ["set", "m", 3, 30],
           ["copy", "m", "n"], ["reorder", "m", 1, 0, -1], ["iterate", "m"], ["iterate", "n"],
           ["reorder", "m", 3, 0, -1], ["reorder", "m", 4, 0, -1], ["reorder", "m", 5, 0, -1],
           ["reorder", "m", 0, 1, -1], ["iterate", "m"], ["set", "m", 4, 40], ["remove", "m", 3],
           ["set", "m", 3, 33], ["iterate", "m"], ["reorder-via-order", "m", 2], ["iterate", "m"],
           ["new", "s", "set"], ["add", "s", 5], ["add", "s", 6], ["add", "s", 7], ["reorder", "s", 2, 0, 5],
           ["iterate", "s"], ["reorder", "s", 4, 0, 6], ["reloop", "s"], ["iterate", "s"], ["reorder-same", "s"],
           ["add", "s", 8], ["reorder", "s", 6, 3, 0], ["iterate", "s"]]
    expect = [3, -9, 1, 10, 3, 30, 2, 20, -9, 1, 10, 2, 20, 3, 30, -7, 3, -7, 3, -7, 3, 3,
              -9, 3, 30, 2, 20, 1, 10, 30, -9, 2, 20, 1, 10, 4, 40, 3, 33, 4, -9, 4, 40, 3, 33, 2, 20, 1, 10,
              1, 1, 1, 3, -9, 5, 7, 6, 3, 5, 7, 6, -9, 5, 6, 7, 3,
              1, 4, -9, 7, 8, 6, 5]
    got = run(ops)
    if got != expect:
        print("selftest FAILED (reorder): %r != %r" % (got, expect))
        return 1
    print("selftest ok")
    return 0


def main(argv):
    if len(argv) > 1 and argv[1] == "selftest":
        return selftest()
    text = sys.stdin.buffer.read().decode("utf-8")
    print(json.dumps(run(json.loads(text))))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
