#!/usr/bin/env python3
# oracle.py -- an independent model of tree struct values and std::tree::walk
# (TREE-STRUCT-MILESTONE-1.md, "Oracle and fuzzing").
#
#   python3 -I oracle.py run K0 K1 < PROGRAM.json     the observations, one per line
#   python3 -I oracle.py selftest
#
# A program (audit/tree-struct/tools/fuzz.tcl writes its description) is a
# list of trees of one declaration:
#
#   {"declaration": "T", "payload": "int"|"str"|"list", "trees": [TREE, ...]}
#   TREE = {"id": N, "kids": [TREE, ...]}
#
# each node's payload a function of its id alone (int: 3 * id; str: "n" and
# the id's decimal text; list: [id, id + 1]), so two nodes are equal exactly
# when their ids and children are. The model is written from the rules, not
# from either runtime: a tree is the ordered rooted tree its nodes describe;
# preorder visits a node and then each child's subtree, first to last;
# breadth-first visits every node at depth N before any at depth N + 1, each
# parent's children in order; equality compares ids and children in order.
# Everything here is iterative, so a chain thousands deep is no problem for
# Python's recursion limit -- except the exact hashes, which reuse the
# Hashable oracle (audit/hashable/tools/oracle.py, imported, never copied): a
# tree's canonical input is its struct's, so the struct encoding is the
# reference, with the recursion limit raised for it.
#
# The observations, in fuzz.tcl's order:
#   for each tree: -1, its preorder ids, -2, its breadth-first ids
#   for each pair i < j: 1 if tree i == tree j else 0
#   for each tree: its public hash, its table hash under the key K0 K1
#   the number of distinct trees, then for each tree the index of the first
#   tree equal to it (what a MutableMap keyed by the trees answers)

import importlib.util
import json
import os
import sys
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
HASHABLE = os.path.join(HERE, "..", "..", "hashable", "tools", "oracle.py")


def hashable_oracle():
    spec = importlib.util.spec_from_file_location("hashable_oracle", os.path.normpath(HASHABLE))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def preorder(tree):
    out, stack = [], [tree]
    while stack:
        node = stack.pop()
        out.append(node["id"])
        stack.extend(reversed(node["kids"]))
    return out


def breadth_first(tree):
    out, queue = [], deque([tree])
    while queue:
        node = queue.popleft()
        out.append(node["id"])
        queue.extend(node["kids"])
    return out


def equal(a, b):
    pairs = [(a, b)]
    while pairs:
        x, y = pairs.pop()
        if x["id"] != y["id"] or len(x["kids"]) != len(y["kids"]):
            return False
        pairs.extend(zip(x["kids"], y["kids"]))
    return True


def payload(kind, ident):
    if kind == "int":
        return {"int": str(3 * ident)}
    if kind == "str":
        return {"str": "n" + str(ident)}
    if kind == "list":
        return {"list": [{"int": str(ident)}, {"int": str(ident + 1)}]}
    raise ValueError(f"unknown payload kind {kind}")


def struct_json(declaration, kind, tree):
    """The Hashable oracle's value of TREE: the struct it is."""
    def node(n):
        return {"struct": {"id": declaration, "fields": [
            ["id", {"int": str(n["id"])}],
            ["payload", payload(kind, n["id"])],
            ["kids", {"list": [node(k) for k in n["kids"]]}]]}}
    return node(tree)


def observations(program, key):
    hashable = hashable_oracle()
    sys.setrecursionlimit(max(sys.getrecursionlimit(), 100000))
    trees = program["trees"]
    out = []
    for t in trees:
        out.append(-1)
        out.extend(preorder(t))
        out.append(-2)
        out.extend(breadth_first(t))
    for i in range(len(trees)):
        for j in range(i + 1, len(trees)):
            out.append(1 if equal(trees[i], trees[j]) else 0)
    for t in trees:
        v = struct_json(program["declaration"], program["payload"], t)
        out.append(hashable.Mode().whole(v) & hashable.MASK61)
        out.append(hashable.Mode(key).whole(v) & hashable.MASK61)
    first = []
    for i, t in enumerate(trees):
        first.append(next(j for j in range(i + 1) if equal(trees[j], t)))
    out.append(len(set(first)))
    out.extend(first)
    return out


def selftest():
    leaf = lambda i: {"id": i, "kids": []}
    t = {"id": 1, "kids": [{"id": 2, "kids": [leaf(4), leaf(5)]}, leaf(3)]}
    assert preorder(t) == [1, 2, 4, 5, 3]
    assert breadth_first(t) == [1, 2, 3, 4, 5]
    assert equal(t, json.loads(json.dumps(t)))
    swapped = {"id": 1, "kids": [leaf(3), {"id": 2, "kids": [leaf(4), leaf(5)]}]}
    assert not equal(t, swapped)
    chain = leaf(0)
    for i in range(1, 5000):
        chain = {"id": i, "kids": [chain]}
    assert preorder(chain) == list(range(4999, -1, -1)) == breadth_first(chain)
    # The milestone's pinned public hashes (tests/tree-struct.test's
    # ts-hash-pinned), through the Hashable oracle: Node {value, children}.
    hashable = hashable_oracle()
    def node(v, kids):
        return {"struct": {"id": "Node", "fields": [["value", {"int": str(v)}], ["children", {"list": kids}]]}}
    assert hashable.Mode().whole(node(5, [])) & hashable.MASK61 == 642836735067814376
    assert hashable.Mode().whole(node(1, [node(2, [node(4, [])]), node(3, [])])) & hashable.MASK61 == 1750255903726798086
    print("selftest ok")


def main():
    if sys.argv[1:] == ["selftest"]:
        selftest()
        return
    if len(sys.argv) != 4 or sys.argv[1] != "run":
        sys.exit("usage: oracle.py selftest | run K0 K1 < PROGRAM.json")
    key = (int(sys.argv[2]), int(sys.argv[3]))
    program = json.loads(sys.stdin.buffer.read().decode("utf-8"))
    for value in observations(program, key):
        print(value)


if __name__ == "__main__":
    main()
