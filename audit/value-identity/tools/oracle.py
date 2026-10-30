#!/usr/bin/env python3
# oracle.py -- an independent model of immutable maps, frozen sets and their
# identity (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md, "Oracle").
#
#   python3 -I audit/value-identity/tools/oracle.py selftest
#   python3 -I audit/value-identity/tools/oracle.py run K0 K1 < PROGRAM.json
#
# It shares no code with the compiler or either runtime, and nothing but the
# meaning of the operations with the standard library:
#
#   * a MutableMap is a Python dict (insertion-ordered, with exactly the
#     collection's rules: a new key last, a present key's value replaced in
#     place, a removed key gone, `reorder` the order an id list gives);
#   * an ImmutableMap is a frozen snapshot of one: its ordered associations;
#     equality is Python mapping equality, iteration the stored order;
#   * a frozen MutableSet is its set of members.
#
# Keys and values are ids: the fuzzer builds every Botlish key and value from
# an Int by an injective construction (key_json and value_json state it, as
# the fuzzer's builders write it), so two are equal exactly when their ids
# are. Hashes are computed from JSON descriptions of the values by the
# Hashable oracle's encoding (audit/hashable/tools/oracle.py: written from
# the reports, not from either runtime), the identity of a map being its
# associations in no order.
#
# PROGRAM is {"keys": KIND, "values": KIND, "maps": [MAP, ...]}, each MAP
# {"capacity": N|null, "ops": [OP, ...]} with OP one of ["set", K, V],
# ["remove", K], ["clear"], ["reorder", [K, ...]] (the order's ids, which the
# fuzzer takes from the map's current order), and the program's observations
# are, for the frozen maps F0..Fn in order (`run` prints them, one per line):
#
#   per map     its length, then each association's key id and value id in
#               iteration order
#   pairwise    for every i < j: 1 if Fi == Fj else 0, and 1 if their
#               public hashes are equal else 0
#   per map     its public hash, then its table hash under K0 K1
#   as keys     the number of distinct maps (a MutableMap keyed by them, a
#               MutableSet of them), then for each map the index of the
#               first map equal to it (the map keyed by maps is set in
#               order, first one wins its key's position, the last its value)

import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "hashable", "tools"))
import oracle as hashable  # noqa: E402  (the Hashable oracle: an independent encoder)

MAP_ID = "std::immutable_map::ImmutableMap"


def key_json(kind, i):
    if kind in ("int", "collide", "kcollide"):
        return {"int": str(i)}
    if kind == "str":
        return {"str": str(i)}
    if kind == "struct":
        return {"struct": {"id": "P", "fields": [["id", {"int": str(i)}], ["name", {"str": str(i)}]]}}
    if kind == "list":
        return {"list": [{"int": str(i)}, {"int": "3"}]}
    if kind == "imap":
        return small_map_json(i)
    raise ValueError(kind)


def value_json(kind, x):
    if kind == "int":
        return {"int": str(x)}
    if kind == "str":
        return {"str": str(x)}
    if kind == "list":
        return {"list": [{"int": str(x)}, {"int": str(x + 1)}]}
    if kind == "imap":
        return small_map_json(x)
    raise ValueError(kind)


def small_map_json(i):
    # The fuzzer's `small(i)`: the ImmutableMap[int, int] {i: 2i, i + 1: i + 5}.
    return {"identity": {"id": MAP_ID, "associations": [
        [{"int": str(i)}, {"int": str(2 * i)}], [{"int": str(i + 1)}, {"int": str(i + 5)}]]}}


def run_map(spec):
    d = {}
    for op in spec["ops"]:
        if op[0] == "set":
            d[op[1]] = op[2]
        elif op[0] == "remove":
            d.pop(op[1], None)
        elif op[0] == "clear":
            d = {}
        elif op[0] == "reorder":
            order = op[1]
            assert sorted(order) == sorted(d.keys()), "a reorder's order holds exactly the keys"
            d = {k: d[k] for k in order}
        else:
            raise ValueError(op)
    return d


def observe(program, key):
    kk, vk = program["keys"], program["values"]
    frozen = [run_map(m) for m in program["maps"]]
    out = []
    for d in frozen:
        out.append(len(d))
        for k, v in d.items():
            out += [k, v]
    public = hashable.Mode()
    table = hashable.Mode(key)
    def json_of(d):
        return {"identity": {"id": MAP_ID, "associations": [[key_json(kk, k), value_json(vk, v)] for k, v in d.items()]}}
    hashes = [(public.whole(json_of(d)) & hashable.MASK61, table.whole(json_of(d)) & hashable.MASK61) for d in frozen]
    n = len(frozen)
    for i in range(n):
        for j in range(i + 1, n):
            out.append(1 if frozen[i] == frozen[j] else 0)
            out.append(1 if hashes[i][0] == hashes[j][0] else 0)
    for p, t in hashes:
        out += [p, t]
    distinct = []
    for d in frozen:
        if d not in distinct:
            distinct.append(d)
    out.append(len(distinct))
    out.append(len(distinct))
    for d in frozen:
        out.append(next(i for i, e in enumerate(frozen) if e == d))
    return out


def selftest():
    a = run_map({"ops": [["set", 1, 10], ["set", 2, 20], ["set", 1, 11]]})
    b = run_map({"ops": [["set", 2, 20], ["set", 1, 11]]})
    assert a == b and list(a) != list(b)
    c = run_map({"ops": [["set", 1, 1], ["remove", 1], ["set", 1, 1], ["set", 2, 2], ["reorder", [2, 1]]]})
    assert list(c) == [2, 1]
    program = {"keys": "int", "values": "int", "maps": [{"ops": [["set", 1, 1], ["set", 2, 2]]},
                                                        {"ops": [["set", 2, 2], ["set", 1, 1]]},
                                                        {"ops": [["set", 2, 1], ["set", 1, 2]]}]}
    out = observe(program, (1, 2))
    # Lengths and orders, then equal / equal public hash for (0,1) (0,2) (1,2).
    assert out[:15] == [2, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 2, 1, 1, 2], out[:15]
    eq = out[15:21]
    assert eq == [1, 1, 0, 0, 0, 0], eq
    assert out[-5:] == [2, 2, 0, 0, 2], out[-5:]
    print("selftest ok")


def main():
    if sys.argv[1:] == ["selftest"]:
        selftest()
        return
    if len(sys.argv) != 4 or sys.argv[1] != "run":
        sys.exit("usage: oracle.py selftest | run K0 K1 < PROGRAM.json")
    key = (int(sys.argv[2]), int(sys.argv[3]))
    program = json.loads(sys.stdin.buffer.read().decode("utf-8"))
    for x in observe(program, key):
        print(x)


if __name__ == "__main__":
    main()
