#!/usr/bin/env python3
"""Writes the golden port of tests/list-flat.test (LIST-FLAT-MILESTONE-1.md)
from one table: the suite tests/golden/list-flat.bot, its manifest fragment
audit/golden/migration/fragments/list-flat.tsv and the census
audit/golden/migration/census/list-flat.tsv. Every Tcl test of the file has
a census row; the source-expressible ones are ported (fragment rows), the
rest classified with what only the Tcl test observes.

    python3 -I audit/list-flat/tools/golden-port.py [ROOT]

Then regenerate the manifest (merge.tcl -names ...), as
tests/golden/README.md says. Deterministic: rerunning it on an unchanged
table rewrites the same three files.
"""

import os
import sys
import textwrap

ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else
                       os.path.join(os.path.dirname(__file__), "..", "..", ".."))
OLD = "tests/list-flat.test"
SUITE = "list-flat.bot"
ALL4 = "interp, compile, cranelift-generic, cranelift"
OLD_BACKENDS = ALL4 + " (lf: one strict compile, outcomeUnderHir, must agree)"

# Ported tests: NAME, HELPER, EXPECTED-or-CODE, BODY, CLASS, STRENGTH, NOTES.
# HELPER value: std::test::value(NAME, EXPECTED, body); rejects:
# std::test::rejects(NAME, DiagnosticCode::CODE, body). BODY is the code of
# the static compile block (its last expression the value).
PORTED = [
    ("list-flat-examples", "value", "[[1, 2, 3, 4], [], [[1, 2], [3]]]", """
        [std::list::flat([[1, 2], [], [3, 4]]), std::list::flat([[], []]), std::list::flat([[[1, 2]], [[3]]])]
    """, "DIRECT", "equal", "-"),
    ("list-flat-empty-outer", "value", "[]", """
        std::list::flat([])
    """, "DIRECT", "equal", "-"),
    ("list-flat-empty-inners", "value", "[[], [], [1, 2], [1]]", """
        [std::list::flat([[]]), std::list::flat([[], [], []]), std::list::flat([[], [1], [], [], [2], []]), std::list::flat([[1], [], []])]
    """, "DIRECT", "equal", "-"),
    ("list-flat-one-inner", "value", "[[1, 2, 3], [7]]", """
        [std::list::flat([[1, 2, 3]]), std::list::flat([[7]])]
    """, "DIRECT", "equal", "-"),
    ("list-flat-singletons", "value", "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]", """
        std::list::flat([[1], [2], [3], [4], [5], [6], [7], [8], [9], [10]])
    """, "DIRECT", "equal", "-"),
    ("list-flat-order-and-duplicates", "value", "[[3, 1, 1, 3, 2, 2, 2], [1, 1, 1]]", """
        [std::list::flat([[3, 1], [1, 3], [2, 2, 2]]), std::list::flat([[1, 1], [1]])]
    """, "DIRECT", "equal", "-"),
    ("list-flat-one-level-only", "value", "[[[1, [2]], [], [3], []], [[[1]]]]", """
        [std::list::flat([[[1, [2]]], [[]], [[3], []]]), std::list::flat([[[[1]]]])]
    """, "DIRECT", "equal", "-"),
    ("list-flat-twice", "value", "[1, 2, 3, 4]", """
        std::list::flat(std::list::flat([[[1, 2], [3]], [[4]], [[]]]))
    """, "DIRECT", "equal", "-"),
    ("list-flat-concatenation", "value", "[[1, 2, 3], [3, 1, 2, 3], [1, 2]]", """
        xs = [1, 2]
        ys = [3]
        [std::list::flat([xs, ys]), std::list::flat([ys, xs, ys]), std::list::flat([xs, []])]
    """, "DIRECT", "equal", "-"),
    ("list-flat-method-syntax", "value", "[[1, 2, 3], [1, 2]]", """
        [[[1], [2, 3]].flat(), [[[1]], [[2]]].flat().flat()]
    """, "DIRECT", "equal", "-"),
    ("list-flat-element-kinds", "value",
     '[["ab", "cd", "é\U0001d11e"], [true, false, true], [1.5, -0.25], [\'a\', \'b\', \'c\'], [FlatColor::Red, FlatColor::Green, FlatColor::Red], [FlatP {x: 1, tag: "one"}, FlatP {x: 2, tag: "two"}], [{a: 1, b: "x2"}, {a: 2, b: "y3"}], [unit, unit], [18446744073709551616, -1], [42, 42]]', """
        fn inc(n: int) -> int:
            n + 1
        strs = std::list::flat([["ab", "cd"], ["é\U0001d11e"]])
        bools = std::list::flat([[true], [false, true]])
        floats = std::list::flat([[1.5], [], [-0.25]])
        chars = std::list::flat([['a', 'b'], ['c']])
        colors = std::list::flat([[FlatColor::Red], [FlatColor::Green, FlatColor::Red]])
        ps = std::list::flat([[FlatP {x: 1, tag: "one"}], [FlatP {x: 2, tag: "two"}]])
        anon = std::list::flat([[{a: 1, b: "x2"}], [{a: 2, b: "y3"}]])
        units = std::list::flat([[unit], [unit]])
        big = std::list::flat([[18446744073709551616], [-1]])
        fns = std::list::flat([[inc], [inc]])
        called = loop f in fns:
            f(41)
        [strs, bools, floats, chars, colors, ps, anon, units, big, called]
    """, "DIRECT", "equal", "The Tcl program's enum Color and struct P are the suite's top-level FlatColor and FlatP (renamed)."),
    ("list-flat-heterogeneous-elements", "value", '[1, "two", [3], true]', """
        std::list::flat([[1, "two"], [[3]], [true]])
    """, "DIRECT", "equal", "-"),
    ("list-flat-equality-and-hash", "value", "[true, true, false]", """
        [std::list::flat([[1], [2, 3]]) == [1, 2, 3], hash(std::list::flat([[1], [2, 3]])) == hash([1, 2, 3]), std::list::flat([[1], [2]]) == [2, 1]]
    """, "DIRECT", "equal", "-"),
    ("list-flat-mutable-elements", "value", "[[1, 1, 1], 1]", """
        v = std::mutable_vector::from_list([1])
        w = std::mutable_vector::from_list([2])
        xs = std::list::flat([[v], [w, v]])
        first = loop m in xs:
            std::mutable_vector::length(m)
        [first, std::mutable_vector::length(v)]
    """, "DIRECT", "equal", "The Tcl program's unused bump helper is dropped."),
    ("list-flat-type-int", "value", "[1, 2, 3]", """
        fn f(xss: List[List[int]]) -> List[int]:
            std::list::flat(xss)
        fn exactly(xs: List[int]) -> List[int]:
            xs
        exactly(std::list::flat([[1], [2, 3]]))
    """, "HARNESS-DIFFERENCE", "weaker", "The static type is observed as admissibility to a declared List[int] parameter (Lists are admitted invariantly), not as its text."),
    ("list-flat-type-str", "value", '["ab", "cd", "ef"]', """
        fn exactly(xs: List[str]) -> List[str]:
            xs
        exactly(std::list::flat([["ab"], ["cd", "ef"]]))
    """, "HARNESS-DIFFERENCE", "weaker", "Admissibility to a declared List[str] parameter, not the type's text."),
    ("list-flat-type-structs", "value", "[1, 3]", """
        fn named(xs: List[FlatQ]) -> int:
            std::list::length(xs)
        anon = std::list::flat([[{a: 1}], [{a: 2}, {a: 3}]])
        [named(std::list::flat([[FlatQ {x: 1}], []])), std::list::length(anon)]
    """, "HARNESS-DIFFERENCE", "weaker", "Admissibility to a declared List[FlatQ] parameter (the Tcl program's struct P is the suite's FlatQ); an anonymous struct type has no source spelling, so its half is the value only."),
    ("list-flat-type-nested", "value", "[[[1, 2], [3]], [1, 2]]", """
        fn lists(xs: List[List[int]]) -> List[List[int]]:
            xs
        fn ints(xs: List[int]) -> List[int]:
            xs
        [lists(std::list::flat([[[1, 2]], [[3]], []])), ints(std::list::flat(std::list::flat([[[1, 2]]])))]
    """, "HARNESS-DIFFERENCE", "weaker", "Admissibility to declared List[List[int]] and List[int] parameters."),
    ("list-flat-type-never", "value", "[0, 0, 0]", """
        fn none(xs: List[int]{length: 0}) -> int:
            std::list::length(xs)
        [none(std::list::flat([])), none(std::list::flat([[], []])), none(std::list::flat([[]]))]
    """, "HARNESS-DIFFERENCE", "weaker", "List[never] has no source spelling: the empty List's type is observed as admissibility to a declared List[int]{length: 0} parameter (no element, proven)."),
    ("list-flat-type-refined-elements", "value", "[[1, 2, 3], [1, 2, 3]]", """
        fn digit(n: int) -> FlatDigit:
            if n >= 0 and n <= 9:
                n
            else:
                0
        fn digits(xss: List[List[FlatDigit]]) -> List[FlatDigit]:
            std::list::flat(xss)
        fn exactly(xs: List[FlatDigit]) -> List[FlatDigit]:
            xs
        ds = [[digit(1), digit(2)], [], [digit(3)]]
        [exactly(std::list::flat(ds)), exactly(digits(ds))]
    """, "HARNESS-DIFFERENCE", "weaker", "The Tcl program's type Digit is the suite's FlatDigit; the refined element type is observed as admissibility to a declared List[FlatDigit] parameter."),
    ("list-flat-type-length-product", "value", "[6, 8]", """
        fn six(xs: List[int]{length: 6}) -> int:
            std::list::length(xs)
        fn f(xss: List[List[int]{length: 2}]{length: 4}) -> List[int]{length: 8}:
            std::list::flat(xss)
        [six(std::list::flat([[1, 2], [3, 4], [5, 6]])), std::list::length(f([[1, 2], [3, 4], [5, 6], [7, 8]]))]
    """, "HARNESS-DIFFERENCE", "weaker", "The proven length N*M is observed as admissibility to a declared List[int]{length: 6} parameter and an accepted declared List[int]{length: 8} result; the Tcl test also pins the absence of a length for non-uniform inner lengths (type text)."),
    ("list-flat-length-proof-removes-bounds-check", "value", "[40, 4]", """
        xs = std::list::flat([[10, 20], [30, 40]])
        [std::list::at(xs, 3), std::list::length(xs)]
    """, "DIRECT", "equal", "Accepted with no handler: the proven length removes IndexNotFound (an unproven index would make the block UnhandledError)."),
    ("list-flat-exact-value", "value", '["ab", 1]', """
        xs = std::list::flat([[1, 2], ["ab"]])
        s = std::list::at(xs, 2)
        n = std::list::at(xs, 0)
        [s, n]
    """, "DIRECT", "split", "The value, accepted with no handler (the exact value proves both indices); the projections' static types (str, int) stay in the Tcl test."),
    ("list-flat-declared-length-unproven", "rejects", "Type", """
        fn f(xss: List[List[int]]) -> List[int]{length: 2}:
            std::list::flat(xss)
        f([[1], [2]])
    """, "STATIC-COMPILE-ADAPTATION", "equal", "-"),
    ("list-flat-type-generic-forwarder", "value", '[[1, 2, 3], ["ab"], 3]', """
        fn g(xs):
            std::list::flat(xs)
        fn ints(xs: List[int]) -> int:
            std::list::length(xs)
        p = g([[1], [2, 3]])
        q = g([["ab"]])
        [p, q, ints(p)]
    """, "HARNESS-DIFFERENCE", "weaker", "The instance's precise List[int] is observed as admissibility to a declared List[int] parameter; the Tcl test pins both instances' type text."),
    ("list-flat-type-imprinted", "value", '[[1, 1, 2, 2], ["ab", "ab"]]', """
        fn pairs(xs: List[T]) -> List[List[T]]:
            loop x in xs:
                [x, x]
        fn joined(xss: List[List[T]]) -> List[T]:
            std::list::flat(xss)
        fn ints(xs: List[int]) -> List[int]:
            xs
        fn strs(xs: List[str]) -> List[str]:
            xs
        [ints(joined(pairs([1, 2]))), strs(joined(pairs(["ab"])))]
    """, "HARNESS-DIFFERENCE", "weaker", "Admissibility of the imprinted results to declared List[int] and List[str] parameters."),
    ("list-flat-returned-from-functions", "value", "[[], [], [0, 0, 1, 0, 1, 2]]", """
        fn rows(n: int) -> List[List[int]]:
            loop i from 0 to n:
                loop j from 0 to i:
                    j
        fn total(n: int) -> List[int]:
            std::list::flat(rows(n))
        [total(0), total(1), total(4)]
    """, "DIRECT", "equal", "-"),
    ("list-flat-not-lists", "rejects_at", ("Type", "LINE:COL std::list::flat([1, 2])"), """
        std::list::flat([1, 2])
    """, "STATIC-COMPILE-ADAPTATION", "weaker", "The code and its location in the suite file (the argument); the message stays in the Tcl test."),
    ("list-flat-not-a-list", "rejects", "Type", """
        std::list::flat(5)
    """, "STATIC-COMPILE-ADAPTATION", "split", "flat(5); the Tcl test also rejects flat(\"ab\") and pins the message."),
    ("list-flat-method-receiver", "rejects", "Type", """
        [1, 2].flat()
    """, "STATIC-COMPILE-ADAPTATION", "weaker", "The code only; the receiver noun of the message stays in the Tcl test."),
    ("list-flat-strings-of-lists", "rejects", "Type", """
        std::list::flat(["ab", "cd"])
    """, "STATIC-COMPILE-ADAPTATION", "equal", "-"),
    ("list-flat-rigid-variable", "rejects", "Type", """
        fn f(xs: List[T]) -> List[T]:
            std::list::flat(xs)
        f([[1]])
    """, "STATIC-COMPILE-ADAPTATION", "weaker", "The code only; the message (not every T is list) stays in the Tcl test."),
    ("list-flat-declared-result-mismatch", "rejects", "Type", """
        fn f(xss: List[List[int]]) -> List[str]:
            std::list::flat(xss)
        f([[1]])
    """, "STATIC-COMPILE-ADAPTATION", "equal", "-"),
    ("list-flat-poison-no-cascade", "rejects", "Type", """
        xs = std::list::flat([1, 2])
        std::list::length(xs)
    """, "STATIC-COMPILE-ADAPTATION", "weaker", "The first diagnostic's code; that it is the only one (no cascade) a static compile block cannot observe (it reifies the first diagnostic)."),
    ("list-flat-affine", "rejects", "AffineListOperationUnsupported", """
        fn make(seed: int) -> Coroutine{args: [FlatMessage], return: FlatEvent}:
            coroutine {step} = flat_worker(seed)
            step
        xss = [[make(1)], [make(2)]]
        ys = std::list::flat(xss)
        1
    """, "STATIC-COMPILE-ADAPTATION", "equal", "The Tcl program's worker, Message and Event are the suite's flat_worker, FlatMessage and FlatEvent."),
    ("list-flat-argument-once", "value", "[[1, 2], [0, 7]]", """
        fn make(place log: MutableVector[int]) -> List[List[int]]:
            flat_note(log, 7)
            [[1], [2]]
        log = std::mutable_vector::from_list([0])
        r = std::list::flat(make(log))
        entries = loop x in log:
            x
        [r, entries]
    """, "DIRECT", "equal", "The Tcl program's note helper is the suite's flat_note; entries are read with a loop in the block."),
    ("list-flat-sources-unchanged", "value", "[[[1, 2], [3], [1, 2]], [1, 2], [3], [1, 2, 3, 1, 2], [1, 2, 3, 1, 2, 4], [1, 2, 3, 1, 2]]", """
        a = [1, 2]
        b = [3]
        outer = [a, b, a]
        r = std::list::flat(outer)
        r2 = r.append(4)
        [outer, a, b, r, r2, std::list::flat(outer)]
    """, "DIRECT", "equal", "-"),
    ("list-flat-shared-inner", "value", "[[1, 2, 3, 1, 2, 3, 1, 2, 3], 9, [[1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3]]]", """
        row = [1, 2, 3]
        grid = [row, row, row]
        flat = std::list::flat(grid)
        [flat, std::list::length(flat), std::list::flat([grid, [row]])]
    """, "DIRECT", "equal", "-"),
    ("list-flat-in-every-position", "value", "[[0], [4, 5], [1, 2], [3], 2]", """
        fn r(xss: List[List[int]]) -> List[int]:
            return std::list::flat(xss)
        fn pick(c: bool) -> List[int]:
            if c:
                std::list::flat([[1], [2]])
            else:
                std::list::flat([[3]])
        b = std::list::flat([[0]])
        [b, r([[4], [5]]), pick(true), pick(false), std::list::length(std::list::flat([[1], [2]]))]
    """, "DIRECT", "equal", "-"),
    ("list-flat-collecting-loop", "value", "[[100, 30, 31, 32, 20, 21], [[0], [], [1], [], [3], [], [0], [], [2], []]]", """
        fn expand(x: int) -> List[int]:
            if x == 0:
                []
            elif x == 1:
                [100]
            else:
                loop i from 0 to x:
                    x * 10 + i
        xs = [0, 1, 3, 0, 2]
        chunks = loop x in xs:
            expand(x)
        nested = loop x in xs:
            [[x], []]
        [std::list::flat(chunks), std::list::flat(nested)]
    """, "DIRECT", "equal", "-"),
    ("list-flat-collecting-loop-continue", "value", "[1, -1, 3, -3, 4, -4]", """
        chunks = loop x in [1, 2, 3, 4]:
            if x == 2:
                continue
            [x, -x]
        std::list::flat(chunks)
    """, "DIRECT", "equal", "-"),
    ("list-flat-chunk-fold", "value", "[[[1, 2], [3], [-4], [4], [5]], [1, 2, 3, -4, 4, 5], [], []]", """
        ts = [1, 2, 0, 3, -4, 0, 0, 5]
        [flat_chunks(ts), std::list::flat(flat_chunks(ts)), std::list::flat(flat_chunks([])), std::list::flat(flat_chunks([0, 0]))]
    """, "DIRECT", "equal", "The Tcl prelude's Chunks, close and chunks are the suite's top-level FlatChunks, flat_close and flat_chunks."),
    ("list-flat-fold-break-continue", "value", "[[1, 1, 3, 3], [], []]", """
        fn upto(xs: List[int], stop: int) -> List[List[int]]:
            fold x in xs with intermediate acc []:
                if x == stop:
                    break
                if x < 0:
                    continue
                acc.append([x, x])
        [std::list::flat(upto([1, -2, 3, 9, 4], 9)), std::list::flat(upto([], 9)), std::list::flat(upto([9, 1], 9))]
    """, "DIRECT", "equal", "-"),
    ("list-flat-fold-of-flat", "value", "[[], [0, 0, 1, 1, 2, 2]]", """
        fn grow(n: int) -> List[int]:
            fold i from 0 to n with intermediate acc []:
                std::list::flat([acc, [i, i]])
        [grow(0), grow(3)]
    """, "DIRECT", "equal", "-"),
    ("list-flat-large", "value", "[10000, 49995000, [1, 2]]", """
        fn mk(m, k):
            loop i from 0 to m:
                loop j from 0 to k:
                    i * k + j
        fn sum(xs: List[int]) -> int:
            fold x in xs with intermediate s 0:
                s + x
        big = std::list::flat(mk(100, 100))
        empties = loop i from 0 to 5000:
            if i == 2500:
                [1, 2]
            else:
                []
        sparse = std::list::flat(empties)
        [std::list::length(big), sum(big), sparse]
    """, "DIRECT", "equal", "-"),
]

# Kept in Tcl: NAME, STATUS, SUBSYSTEM, OBSERVES, TCL_RETAINED, TAGS, NOTES.
KEPT = [
    ("list-flat-type-join", "KEEP-INTERNAL", "hir-core-nir", "the static types' text of flat over inner Lists of joined element types: list{length: 2}, List[P]", "-", "INTERNAL", "the raw list kind a join gives has no source spelling to admit to: compiler representation"),
    ("list-flat-module-binding", "KEEP-MULTI-PROGRAM", "surface", "a module binding retaining flat of structurally known Lists, read through m::get() on every backend", "the module file beside its program", "MULTI-PROGRAM,MULTI-BACKEND", "a module of its own: two files"),
    ("list-flat-arity", "KEEP-RUNTIME-ONLY", "surface", "outcomeUnderHir of flat() and flat(a, b): {error {CORE SEMANTIC ARITY} {std::list::flat expects 1 argument(s), got N}} on all four backends", "a native's arity is checked when the call runs", "RUNTIME-ONLY:ARITY,MULTI-BACKEND,MESSAGE", "ARITY is no declared error: it would abort a golden suite"),
    ("list-flat-dynamic-element", "KEEP-RUNTIME-ONLY", "surface", "an `any` argument with a non-List element: {error {CORE SEMANTIC TYPE} {std::list::flat element 2: expected list, got 2}} on all four backends", "the run-time TYPE error and its message", "RUNTIME-ONLY:TYPE,MULTI-BACKEND,MESSAGE", "TYPE at run time is no declared error: it would abort a golden suite"),
    ("list-flat-dynamic-heterogeneous", "KEEP-RUNTIME-ONLY", "surface", "a List[any] literal mixing a List and a String: the run-time TYPE error with element 1's position, on all four backends", "the run-time TYPE error and its message", "RUNTIME-ONLY:TYPE,MULTI-BACKEND,MESSAGE", "TYPE at run time is no declared error"),
    ("list-flat-forwarder-contract", "KEEP-RUNTIME-ONLY", "surface", "an untyped forwarder: g(5) rejected (TYPE, the inherited checked contract list), g([1, 2]) the run-time TYPE error of element 0", "the run-time half", "RUNTIME-ONLY:TYPE,MULTI-BACKEND", "the compile-time half alone is list-flat-not-a-list's property"),
    ("list-flat-nir-one-op", "KEEP-INTERNAL", "hir-core-nir", "the NIR of a flat call: exactly one op listflat, no construct, listappend or listnew", "-", "INTERNAL,NATIVE-ONLY", "compiler representation, which no Botlish program observes"),
    ("list-flat-nir-loop-operand", "KEEP-INTERNAL", "hir-core-nir", "the NIR of flat of a collecting loop: one construct list flat (the plan materialized once), one op listflat, no listappend", "-", "INTERNAL,NATIVE-ONLY", "compiler representation, which no Botlish program observes"),
    ("list-flat-compile-code", "KEEP-INTERNAL", "hir-core-nir", "the Tcl compiler's generated code calls core::lists::flat", "-", "INTERNAL", "compiler representation"),
    ("list-flat-hir-text", "KEEP-INTERNAL", "hir-core-nir", "HIR text of a flat call reads back identically and runs on interp and compile", "-", "INTERNAL", "compiler representation"),
    ("list-flat-interchange", "KEEP-INTERNAL", "hir-core-nir", "the HIR interchange text of a flat call decodes and runs on every backend", "-", "INTERNAL,MULTI-BACKEND", "compiler representation"),
    ("list-flat-core-ir-text", "KEEP-INTERNAL", "hir-core-nir", "core IR text calling std::list::flat runs on every backend", "-", "INTERNAL,CORE-IR,MULTI-BACKEND", "core IR text, which no Botlish program writes"),
    ("list-flat-registration", "KEEP-INTERNAL", "hir-core-nir", "the registry entry of std::list::flat (arity, kinds, element kinds, shape, length, ownership, errors)", "-", "INTERNAL", "the native registry"),
    ("list-flat-linear-copies", "KEEP-INTERNAL", "native", "native::allocationReport: flat allocates one List of 24 + 8n bytes and copies exactly n elements for m = 1000 singletons, 4 large Lists and 5000 empty Lists", "-", "INTERNAL,NATIVE-ONLY", "allocation counts, which no Botlish program observes: the structural linearity evidence"),
    ("list-flat-random-differential", "KEEP-NOT-EXPRESSIBLE", "surface", "40 seeded random nested Lists flattened by every backend against an independent Tcl model", "the generator and the model", "MULTI-BACKEND,DYNAMIC-INPUT", "the program is generated by the Tcl test at run time; audit/list-flat/tools/fuzz.tcl is its larger sibling"),
    ("list-flat-executable", "KEEP-MULTI-PROGRAM", "native", "standalone AOT executable stdout, plain and with BOTLISH_NATIVE_GC_STRESS=1, agreeing with the in-process backends", "the executable and its GC-stress run", "MULTI-BACKEND,MULTI-PROGRAM,STDOUT,MAIN-TCL", "its in-process semantics are the golden suite's collecting-loop tests"),
]

TOP = '''# list-flat.bot -- std::list::flat[T](lists: List[List[T]]) -> List[T]
# (LIST-FLAT-MILESTONE-1.md), as a source-level specification:
#
# * flat is the elements of the first List, then of the second, and so on:
#   exactly one level of nesting removed, in order, duplicates kept, empty
#   inner Lists contributing nothing, the elements as they are.
# * It is an ordinary call: the argument is evaluated once, before it; the
#   outer List and its Lists are unchanged and may be shared.
# * Its type is List[T] for a List[List[T]] (an empty List's List[never]);
#   N inner Lists of one proven length M make a List of proven length N*M.
# * A List whose elements are of another known kind is a compile-time TYPE
#   error; a List of affine values is AffineListOperationUnsupported.
# * Collecting loops and folds compose with it as written (no fusion).
#
# Ported from tests/list-flat.test, which stays authoritative and unchanged;
# a golden test keeps its Tcl test's name. What only the Tcl tests observe
# (types' text, messages, NIR, allocation counts, run-time-only errors,
# executables, module programs) stays there. This file is generated by
# audit/list-flat/tools/golden-port.py from the same table as its fragment.
import std::compiler
import std::coroutine
import std::list
import std::mutable_vector
import std::test

# Declarations the tests need (top-level only), renamed to stay apart from
# the other suites': the Tcl programs' Color, P, Digit, Chunks, Message,
# Event and their helpers.
enum FlatColor:
    Red, Green

struct FlatP:
    x: int
    tag: str

struct FlatQ:
    x: int

type FlatDigit = Int in 0..9

struct FlatMessage:
    value: int

struct FlatEvent:
    value: int

fn flat_worker(seed: int, resume FlatMessage) -> FlatEvent:
    message = yield FlatEvent {value: seed}
    return FlatEvent {value: message.value}

fn flat_note(place log: MutableVector[int], n: int) -> int:
    log.push(n)
    n

struct FlatChunks:
    done: List[List[int]]
    current: List[int]

fn flat_close(c: FlatChunks) -> List[List[int]]:
    if std::list::length(c.current) == 0:
        c.done
    else:
        c.done.append(c.current)

fn flat_chunks(tokens: List[int]) -> List[List[int]]:
    final = fold t in tokens with intermediate c FlatChunks {done: [], current: []}:
        if t == 0:
            FlatChunks {done: flat_close(c), current: []}
        elif t < 0:
            FlatChunks {done: flat_close(c).append([t]).append([-t]), current: []}
        else:
            FlatChunks {done: c.done, current: c.current.append(t)}
    flat_close(final)

fn register_list_flat_tests():
'''

END = '''
with context std::test::suite()
register_list_flat_tests()
std::test::report()
'''


def ident(name):
    return "t_" + name[len("list-flat-"):].replace("-", "_")


def main():
    lines = TOP.split("\n")
    out = list(lines)
    pending_at = []
    for name, helper, expected, body, klass, strength, notes in PORTED:
        fn = ident(name)
        out.append(f"    fn {fn}() errors std::compiler::CompilerError:")
        out.append("        static compile:")
        code = textwrap.dedent(body).strip("\n").split("\n")
        first_line = len(out) + 1
        for line in code:
            out.append("            " + line if line else "")
        if helper == "value":
            out.append(f'    std::test::value("{name}", {expected}, {fn})')
        elif helper == "rejects":
            out.append(f'    std::test::rejects("{name}", std::compiler::DiagnosticCode::{expected}, {fn})')
        else:
            code_case, marker = expected
            needle = marker.split(" ", 1)[1]
            line = first_line
            column = out[line - 1].index(needle) + 1 + len("std::list::flat(")
            out.append(f'    std::test::rejects_at("{name}", std::compiler::DiagnosticCode::{code_case}, {line}, {column}, {fn})')
        out.append("")
    text = "\n".join(out).rstrip("\n") + "\n" + END
    with open(os.path.join(ROOT, "tests", "golden", SUITE), "w", encoding="utf-8") as f:
        f.write(text)

    fheader = ["old_file", "old_test", "suite", "new_test", "category", "outcome", "old_backends",
               "new_backends", "class", "also", "static", "handler", "api", "verbosity", "strength",
               "old_lines", "new_lines", "mutants", "notes", "subsystem", "status", "tcl_retained",
               "tcl_layer", "freeze", "tags"]
    rows = []
    for name, helper, expected, body, klass, strength, notes in PORTED:
        outcome = {"value": "value", "rejects": "diagnostic", "rejects_at": "diagnostic-at"}[helper]
        static = "yes" if helper != "value" else "convention"
        nlines = len(textwrap.dedent(body).strip("\n").split("\n")) + 3
        tags = ["MULTI-BACKEND"]
        if helper == "rejects_at":
            tags.append("LOCATION")
        status = "SPLIT" if strength == "split" else "MIGRATED"
        retained = "-"
        if strength in ("weaker", "split"):
            retained = "the static type's text or the diagnostic's message" if klass != "DIRECT" else "the projections' static types"
        rows.append([OLD, name, SUITE, name, "lists", outcome, OLD_BACKENDS, ALL4, klass, "-", static,
                     "no", "simple", "similar", strength, str(nlines), str(nlines), "-", notes, "surface",
                     status, retained, "-", "-", ",".join(tags)])
    with open(os.path.join(ROOT, "audit", "golden", "migration", "fragments", "list-flat.tsv"), "w", encoding="utf-8") as f:
        f.write("\t".join(fheader) + "\n")
        for row in rows:
            f.write("\t".join(row) + "\n")

    cheader = ["old_file", "old_test", "subsystem", "status", "confidence", "observes", "source_theorem",
               "outcome", "tcl_retained", "tags", "notes"]
    order = []
    with open(os.path.join(ROOT, OLD), encoding="utf-8") as f:
        for line in f:
            if line.startswith("test list-flat-"):
                order.append(line.split()[1])
    ported = {p[0]: p for p in PORTED}
    kept = {k[0]: k for k in KEPT}
    crow = []
    for name in order:
        if name in ported:
            _, helper, expected, body, klass, strength, notes = ported[name]
            outcome = {"value": "value", "rejects": "diagnostic", "rejects_at": "diagnostic-at"}[helper]
            crow.append([OLD, name, "surface", "MIGRATE", "high",
                         "lf: identical outcome on " + ALL4 + ": " + name[len("list-flat-"):].replace("-", " "),
                         "-", outcome, "-", "MULTI-BACKEND", "-"])
        elif name in kept:
            _, status, subsystem, observes, retained, tags, notes = kept[name]
            crow.append([OLD, name, subsystem, status, "high", observes, "-", "none", retained, tags, notes])
        else:
            raise SystemExit(f"golden-port.py: {name} is neither ported nor kept")
    for name in list(ported) + list(kept):
        if name not in order:
            raise SystemExit(f"golden-port.py: {name} is no test of {OLD}")
    with open(os.path.join(ROOT, "audit", "golden", "migration", "census", "list-flat.tsv"), "w", encoding="utf-8") as f:
        f.write("\t".join(cheader) + "\n")
        for row in crow:
            f.write("\t".join(row) + "\n")
    print(f"wrote tests/golden/{SUITE} ({len(PORTED)} tests), the fragment and the census ({len(crow)} rows)")


main()
