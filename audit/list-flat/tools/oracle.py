#!/usr/bin/env python3
"""The independent model of std::list::flat (LIST-FLAT-MILESTONE-1.md) for
audit/list-flat/tools/fuzz.tcl: written from the milestone's semantics
section, never from the compiler or the runtimes.

    python3 -I oracle.py < CASES.json      one expected value per line
    python3 -I oracle.py selftest          checks the model on fixed cases

CASES.json is a list of cases; a case is {"depth": D, "lists": LISTS}:
LISTS is a List of inner Lists of elements, flattened D times (1 or 2; for
2 the elements of the inner Lists are themselves Lists of elements). An
element is {"int": N}, {"str": S}, {"bool": B}, {"ints": [N...]} (a List of
Ints, kept as one element) or {"p": N} (the struct FuzzP {x: N}). The output
is each case's flattened value as Botlish prints it.
"""

import json
import sys


def flat(lists):
    """One level of nesting removed, in order: the elements of the first
    List, then of the second, and so on. Nothing is compared, converted or
    flattened further."""
    result = []
    for inner in lists:
        assert isinstance(inner, list), "flat of a List that holds a non-List"
        for element in inner:
            result.append(element)
    return result


def show(value):
    if isinstance(value, list):
        return "[" + ", ".join(show(v) for v in value) + "]"
    if "int" in value:
        return str(value["int"])
    if "str" in value:
        return '"' + value["str"] + '"'
    if "bool" in value:
        return "true" if value["bool"] else "false"
    if "ints" in value:
        return "[" + ", ".join(str(n) for n in value["ints"]) + "]"
    if "p" in value:
        return "FuzzP {x: %d}" % value["p"]
    raise ValueError(value)


def expected(case):
    value = case["lists"]
    for _ in range(case["depth"]):
        value = flat(value)
    return show(value)


def selftest():
    one = {"int": 1}
    two = {"int": 2}
    s = {"str": "ab"}
    checks = [
        ({"depth": 1, "lists": []}, "[]"),
        ({"depth": 1, "lists": [[], []]}, "[]"),
        ({"depth": 1, "lists": [[one, two], [], [s]]}, '[1, 2, "ab"]'),
        ({"depth": 1, "lists": [[{"ints": [1, 2]}], [{"ints": []}]]}, "[[1, 2], []]"),
        ({"depth": 1, "lists": [[two, one], [one]]}, "[2, 1, 1]"),
        ({"depth": 2, "lists": [[[one], []], [[two]]]}, "[1, 2]"),
        ({"depth": 1, "lists": [[{"p": 3}, {"bool": False}]]}, "[FuzzP {x: 3}, false]"),
    ]
    for case, want in checks:
        got = expected(case)
        if got != want:
            raise SystemExit(f"selftest: {case} gave {got}, expected {want}")
    print(f"selftest: {len(checks)} cases agree")


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "selftest":
        selftest()
        return
    for case in json.load(sys.stdin):
        print(expected(case))


main()
