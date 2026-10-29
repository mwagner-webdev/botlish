#!/usr/bin/env python3
# Python equivalent of bench/test-selection.bot: "which test groups are
# affected by this set of changed files?" -- a named record per test group,
# a closure factory over a set of changed paths, and the selection, search
# and exclusion queries the Botlish program makes with it.
#
# Invoked by bench/bench.tcl; see fib.py for the --runs/value/best_us
# protocol shared by all equivalents. The printed value's shape matches
# core::value::show's rendering of a Botlish List (strings double-quoted,
# Bools true/false).
#
# Mapping: Test is the Botlish struct (a NamedTuple), make_changed returns
# a closure over a frozenset (std::immutable_set), affected is any() over a
# test's dependencies, select_affected the returning-loop selection,
# first_affected the std::list::find with its NotFound fallback, and
# untouched_by_a the std::list::none? query. The test list and both
# changed-file sets are built inside each timed run, as the Botlish program
# builds them on every run.
import sys
import time
from typing import List, NamedTuple


class Test(NamedTuple):
    name: str
    dependencies: List[str]


def make_changed(changed):
    changed_set = frozenset(changed)

    def changed_p(path):
        return path in changed_set

    return changed_p


def affected(test, changed_p):
    return any(changed_p(dep) for dep in test.dependencies)


def select_affected(tests, changed_p):
    return [test for test in tests if affected(test, changed_p)]


def first_affected(tests, changed_p):
    found = next((test for test in tests if affected(test, changed_p)), Test("<none>", []))
    return found.name


def run_once():
    tests = [
        Test("parser-tests", ["src/parser.bot", "src/ast.bot"]),
        Test("lexer-tests", ["src/lexer.bot", "src/token.bot"]),
        Test("resolve-tests", ["hir/resolve.tcl", "hir/hir.tcl"]),
        Test("types-tests", ["hir/types.tcl", "hir/hir.tcl"]),
        Test("specialize-tests", ["hir/specialize.tcl", "hir/range.tcl"]),
        Test("native-lower-tests", ["native/lower.tcl", "native/native.tcl"]),
        Test("compile-tests", ["compiler/compiler.tcl"]),
        Test("web-tests", ["stdlib/web.bot", "stdlib/byte.bot"]),
        Test("ascii-tests", ["stdlib/ascii.bot"]),
        Test("list-tests", ["stdlib/list.bot"]),
        Test("byte-tests", ["stdlib/byte.bot", "core/scalarbits.tcl"]),
        Test("char-tests", ["stdlib/char.bot", "core/unicodechar.tcl"]),
        Test("docs-tests", ["README.md", "AGENTS.md"]),
        Test("bench-tests", ["bench/bench.tcl"]),
    ]
    changed_a = make_changed(["stdlib/web.bot", "hir/hir.tcl"])
    changed_b = make_changed(["README.md"])
    probe = changed_a("stdlib/web.bot")
    selected_a = select_affected(tests, changed_a)
    selected_b = select_affected(tests, changed_b)
    docs_deps = ["README.md", "AGENTS.md"]
    untouched_by_a = not any(changed_a(dep) for dep in docs_deps)
    return [len(selected_a), len(selected_b), first_affected(tests, changed_a), probe, untouched_by_a]


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

    run_once()  # untimed warmup
    best = None
    value = None
    for _ in range(runs):
        t0 = time.perf_counter()
        value = run_once()
        dt = (time.perf_counter() - t0) * 1_000_000
        if best is None or dt < best:
            best = dt

    print(f"value: {show(value)}")
    print(f"best_us: {best:.3f}")
