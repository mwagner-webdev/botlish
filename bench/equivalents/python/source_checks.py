#!/usr/bin/env python3
# Python equivalent of bench/source-checks.bot: a small lint pass whose
# lexical classifiers of an identifier's leading character are held in a
# List of callables and invoked from it, then a selection of the invalid
# names and a search for the first one.
#
# Invoked by bench/bench.tcl; see fib.py for the --runs/value/best_us
# protocol shared by all equivalents. The printed value's shape matches
# core::value::show's rendering of a Botlish List (strings double-quoted).
#
# Mapping: CHECKS is the Botlish `checks` List (two Tcl character classes
# and two ordinary functions); classify_leading applies each to the first
# character, as `loop check in checks: check(c)` does; the empty name
# short-circuits to four false flags before the List is consulted.
# tcl_alpha/tcl_alnum are Tcl 9's [:alpha:]/[:alnum:] (refined_checks.py
# explains the mapping to isalpha()/isdecimal()).
import sys
import time


def tcl_alpha(c):
    return c.isalpha()


def tcl_alnum(c):
    return c.isalpha() or c.isdecimal()


def is_underscore(c):
    return c == "_"


def is_hyphen(c):
    return c == "-"


CHECKS = [tcl_alpha, tcl_alnum, is_underscore, is_hyphen]


def classify_leading(name):
    if len(name) == 0:
        return [False, False, False, False]
    c = name[0]
    return [check(c) for check in CHECKS]


def valid_start(name):
    flags = classify_leading(name)
    return flags[0] or flags[2]


def invalid_name(name):
    return not valid_start(name)


def run_once(candidates):
    invalid_names = [name for name in candidates if not valid_start(name)]
    first_invalid = next((name for name in candidates if invalid_name(name)), "<none>")
    return [len(candidates), len(invalid_names), first_invalid, len(candidates) - len(invalid_names)]


def show(value):
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, str):
        escaped = value.replace("\\", "\\\\").replace('"', '\\"')
        return f'"{escaped}"'
    if isinstance(value, list):
        return "[" + ", ".join(show(v) for v in value) + "]"
    return str(value)


def parse_args(argv):
    runs = 5
    i = 0
    while i < len(argv):
        if argv[i] == "--runs":
            i += 1
            runs = int(argv[i])
        i += 1
    return runs


if __name__ == "__main__":
    runs = parse_args(sys.argv[1:])
    candidates = [
        "emailish?",
        "scan_while",
        "list_get",
        "_internal",
        "über_count",
        "2fast",
        "make_changed?",
        "_private_state",
        "9bad_name",
        "-flag",
        "is_tcl_alpha",
        "évalue",
        "-verbose",
        "",
        "x_1",
        "café_name",
    ]

    run_once(candidates)  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = run_once(candidates)
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print(f"value: {show(value)}")
    print(f"best_us: {best:.3f}")
