# golden-port.py -- writes tests/golden/fold-loops.bot and its manifest
# fragment (audit/golden/migration/fragments/fold-loops.tsv) from one table:
# every source-expressible test of tests/fold-loops.test, ported
# (FOLD-LOOPS-MILESTONE-1.md, "Tests"). Run from the repository root:
#
#   python3 -I audit/fold-loops/tools/golden-port.py
#
# A row: (Tcl test, golden name, group, outcome, expected, body lines, class,
# strength, notes, retained). outcome "value": expected is a Botlish literal;
# "rejects": expected is a DiagnosticCode case. The body lines are the
# static compile block's code (its last expression the value).

TESTS = []

def t(name, group, outcome, expected, body, cls="DIRECT", strength="equal", notes="-", retained="-", new=None):
    TESTS.append(dict(old="fold-loops-" + name, new="fold-loops-" + (new or name), group=group,
                      outcome=outcome, expected=expected, body=body.strip("\n").split("\n"),
                      cls=cls, strength=strength, notes=notes, retained=retained))

# --- basics -----------------------------------------------------------------
t("sum", "basics", "value", "[10, 7, 0]", """
fn sum(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        acc + x
[sum([1, 2, 3, 4]), sum([7]), sum([])]
""")
t("empty-is-initial", "basics", "value", "42", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 42:
        acc * 1000 + x
f([])
""")
t("singleton", "basics", "value", "53", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 5:
        acc * 10 + x
f([3])
""")
t("order-of-iterations", "basics", "value", "1234", """
fn digits(xs: List[int]) -> int:
    fold d in xs with intermediate n 0:
        n * 10 + d
digits([1, 2, 3, 4])
""")
for name, header, expected in [("up-to", "i from 1 to 5", "10"), ("up-through", "i from 1 through 5", "15"),
                               ("down-to", "i down from 5 to 1", "14"), ("down-through", "i down from 5 through 1", "15"),
                               ("up-to-empty", "i from 5 to 1", "0"), ("down-empty", "i down from 1 to 5", "0")]:
    t("count-" + name, "basics", "value", expected, f"""
fn f() -> int:
    fold {header} with intermediate s 0:
        s + i
f()
""", notes="Generated in Tcl by a foreach over the four numeric forms and two empty domains; here one body per row.")
t("count-order", "basics", "value", "4321", """
fn f() -> int:
    fold i down from 4 through 1 with intermediate n 0:
        n * 10 + i
f()
""")
t("lockstep", "basics", "value", "20", """
fn dot(xs: List[int]) -> int:
    fold x in xs and i from 0 to std::list::length(xs) with intermediate t 0:
        t + x * i
dot([5, 6, 7])
""")
t("bare", "basics", "value", "[0, 8, 111]", """
fn collatz_steps(n: int) -> int:
    s = fold with intermediate st {n: n, steps: 0}:
        if st.n == 1:
            break
        if st.n.mod(2) == 0:
            {n: st.n.shift_right(1), steps: st.steps + 1}
        else:
            {n: st.n * 3 + 1, steps: st.steps + 1}
    s.steps
[collatz_steps(1), collatz_steps(6), collatz_steps(27)]
""")
t("bare-return", "basics", "value", "8", """
fn first_square_over(n: int) -> int:
    fold with intermediate i 1:
        if i * i > n:
            return i
        i + 1
first_square_over(50)
""")
t("big-ints", "basics", "value", "1180591620717411303424", """
fn f() -> int:
    fold i from 0 to 70 with intermediate p 1:
        p * 2
f()
""")

# --- continue and break -----------------------------------------------------
t("continue-first", "control", "value", "4", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        if x == 2:
            continue
        acc + x
f([1, 2, 3])
""")
t("continue-after-work", "control", "value", "2", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        doubled = acc + x * 2
        if doubled > 4:
            continue
        doubled
f([1, 2, 3])
""")
t("continue-every-iteration", "control", "value", "9", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 9:
        if x > 0:
            continue
        acc + x
f([1, 2, 3])
""")
t("break-first", "control", "value", "7", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 7:
        if x > 0:
            break
        acc + x
f([1, 2, 3])
""")
t("break-later", "control", "value", "3", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        if x > 2:
            break
        acc + x
f([1, 2, 3, 4])
""")
t("break-discards-next", "control", "value", "3", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        next = acc + x
        if next > 5:
            break
        next
f([1, 2, 3, 4])
""")
t("continue-and-break", "control", "value", "3", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        if x < 0:
            continue
        if x == 0:
            break
        acc + x
f([1, -5, 2, 0, 100])
""")
t("break-in-count", "control", "value", "12", """
fn f() -> int:
    fold i from 0 to 100 with intermediate acc 0:
        if i == 3:
            continue
        if i == 6:
            break
        acc + i
f()
""")

# --- evaluation order (the log is a MutableVector place the program owns) ----
LOG = """
fn note(place log: MutableVector[int], n: int) -> int:
    log.push(n)
    n
fn entries(log: MutableVector[int]) -> List[int]:
    loop v in log:
        v
"""
t("initial-once-ordered", "order", "value", "[[26], [0, 1, 2, 3, 10, 10]]", LOG + """
fn f() -> List[List[int]]:
    log = std::mutable_vector::from_list([0])
    r = fold x in [note(log, 1), note(log, 2)] with intermediate acc note(log, 3):
        acc + x + note(log, 10)
    [[r], entries(log)]
f()
""")
t("initial-once-empty", "order", "value", "[[5], [0, 5]]", LOG + """
fn f() -> List[List[int]]:
    log = std::mutable_vector::from_list([0])
    r = fold x in [] with intermediate acc note(log, 5):
        acc + note(log, 99)
    [[r], entries(log)]
f()
""")
t("initial-once-bare", "order", "value", "[[4], [0, 1, 2, 2, 2]]", LOG + """
fn f() -> List[List[int]]:
    log = std::mutable_vector::from_list([0])
    r = fold with intermediate acc note(log, 1):
        if acc > 3:
            break
        acc + note(log, 2) - 1
    [[r], entries(log)]
f()
""")
t("count-bounds-before-initial", "order", "value", "[[8], [0, 1, 3, 5]]", LOG + """
fn f() -> List[List[int]]:
    log = std::mutable_vector::from_list([0])
    r = fold i from note(log, 1) to note(log, 3) with intermediate acc note(log, 5):
        acc + i
    [[r], entries(log)]
f()
""")
t("statement-position", "order", "value", "[0, 1, 3, 6]", LOG + """
fn f() -> List[int]:
    log = std::mutable_vector::from_list([0])
    fold x in [1, 2, 3] with intermediate s 0:
        note(log, s + x)
    entries(log)
f()
""")
t("discarded-fold-still-runs", "order", "value", "[0, 100, 101, 103]", LOG + """
fn f() -> List[int]:
    log = std::mutable_vector::from_list([0])
    fold x in [1, 2, 3] with intermediate s 100:
        note(log, s)
        s + x
    entries(log)
f()
""")

# --- errors (an input the compiler cannot decide: the registration's k) ------
ERRS_NOTE = "The error helpers boom/bang are the suite's top-level declarations, and k comes from register_fold_error_tests(1, 0) so that no call is a statically known failure (KnownError)."
t("initial-error", "errors", "value", "[-1, 1]", """
fn f(xs: List[int], k: int) -> int errors FoldBoom:
    fold x in xs with intermediate acc fold_boom(k):
        acc + x
fn run(k: int) -> int:
    f([1], k):
        on FoldBoom:
            -1
[run(one), run(zero)]
""", notes=ERRS_NOTE)
t("iterable-error-first", "errors", "value", "[2, 0]", """
fn f(k: int) -> int errors FoldBoom, FoldBang:
    fold x in fold_bang(k) with intermediate acc fold_boom(k):
        acc + x
fn run(k: int) -> int:
    f(k):
        on FoldBoom:
            1
        on FoldBang:
            2
[run(one), run(zero)]
""", notes=ERRS_NOTE)
t("body-error", "errors", "value", "[-1, 3]", LOG + """
fn g(place log: MutableVector[int], xs: List[int]) -> int errors FoldBoom:
    fold x in xs with intermediate acc 0:
        if x > 2:
            fold_boom(x)
        else:
            note(log, x)
            acc + x
fn f(xs: List[int]) -> List[int]:
    log = std::mutable_vector::from_list([0])
    r = g(log, xs):
        on FoldBoom:
            -1
    [r, std::list::length(entries(log))]
f(digits)
""", notes=ERRS_NOTE + " The input List is the registration's digits, [1, 2, 3, 4].")
t("return", "errors", "value", "[3, -6]", """
fn find(xs: List[int], target: int) -> int:
    total = fold x in xs with intermediate acc 0:
        if x == target:
            return acc
        acc + x
    -total
[find([1, 2, 3], 3), find([1, 2, 3], 9)]
""")
t("handled-in-body", "errors", "value", "102", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        v = fold_boom(x - 1):
            on FoldBoom:
                100
        acc + v
f([1, 2, 3])
""", notes=ERRS_NOTE)

# --- scope -------------------------------------------------------------------
t("scope-does-not-leak", "scope", "rejects", "Unbound", """
fn f(xs: List[int]) -> int:
    t = fold x in xs with intermediate acc 0:
        acc + x
    acc
f([1])
""")
t("not-in-scope-in-initial", "scope", "rejects", "Unbound", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc acc:
        acc + x
f([1])
""", new="not-in-scope-in-initial/initial", notes="The Tcl test's first program.", cls="DIRECT")
t("not-in-scope-in-initial", "scope", "rejects", "Unbound", """
fn f() -> int:
    fold i from 0 to acc with intermediate acc 0:
        acc + i
f()
""", new="not-in-scope-in-initial/operand", notes="The Tcl test's second program.")
t("immutable", "scope", "rejects", "Duplicate", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        acc = acc + x
        acc
f([1])
""", cls="DIRECT", strength="weaker", notes="The code only; the location and message stay in the Tcl test.",
  retained="the DUPLICATE diagnostic's line:column and message")
t("shadow-in-branch", "scope", "value", "103", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        if x > 1:
            acc = 100
            acc + x
        else:
            acc + x
f([1, 2, 3])
""")
t("shadows-outer", "scope", "value", "[3, 1000]", """
fn f(xs: List[int]) -> List[int]:
    acc = 1000
    r = fold x in xs with intermediate acc 0:
        acc + x
    [r, acc]
f([1, 2])
""")
t("duplicate-name", "scope", "rejects", "DuplicateLoopVariable", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate x 0:
        x
f([1])
""", new="duplicate-name/single", notes="The Tcl test's first program.")
t("duplicate-name", "scope", "rejects", "DuplicateLoopVariable", """
fn f(xs: List[int]) -> int:
    fold x in xs and i from 0 to std::list::length(xs) with intermediate i 0:
        x
f([1])
""", new="duplicate-name/lockstep", notes="The Tcl test's second program.")

# --- nesting -----------------------------------------------------------------
t("nested-folds", "nesting", "value", "30705", """
fn f(rows: List[List[int]]) -> int:
    fold row in rows with intermediate total 0:
        row_sum = fold v in row with intermediate s 0:
            s + v
        total * 100 + row_sum
f([[1, 2], [3, 4], [5]])
""")
t("nested-break-targets-inner", "nesting", "value", "8", """
fn f(rows: List[List[int]]) -> int:
    fold row in rows with intermediate total 0:
        capped = fold v in row with intermediate s 0:
            if v > 9:
                break
            s + v
        total + capped
f([[1, 20, 2], [3, 4]])
""")
t("nested-continue-targets-inner", "nesting", "value", "12", """
fn f(rows: List[List[int]]) -> int:
    fold row in rows with intermediate total 0:
        evens = fold v in row with intermediate s 0:
            if v.mod(2) == 1:
                continue
            s + v
        total + evens
f([[1, 2, 3, 4], [6, 7]])
""")
t("loop-in-fold", "nesting", "value", "3", """
fn f(rows: List[List[int]]) -> int:
    fold row in rows with intermediate n 0:
        prefix = loop v in row:
            if v < 0:
                break
            v
        n + std::list::length(prefix)
f([[1, 2, -1, 4], [5]])
""")
t("fold-in-loop", "nesting", "value", "[9, 4]", """
fn f(rows: List[List[int]]) -> List[int]:
    loop row in rows:
        if row == []:
            continue
        fold v in row with intermediate m 0:
            if v > m:
                v
            else:
                m
f([[3, 9, 2], [], [4]])
""")
t("fold-break-in-loop-body", "nesting", "value", "[1, 5]", """
fn f(rows: List[List[int]]) -> List[int]:
    loop row in rows:
        fold v in row with intermediate s 0:
            if v == 0:
                break
            s + v
f([[1, 0, 5], [2, 3]])
""")

# --- positions ---------------------------------------------------------------
t("positions", "positions", "value", "[12, 6, -6, 0]", """
fn twice(n: int) -> int:
    n * 2
fn a(xs: List[int]) -> int:
    t = fold x in xs with intermediate s 0:
        s + x
    twice(t)
fn b(xs: List[int]) -> int:
    return fold x in xs with intermediate s 1:
        s * x
fn c(xs: List[int], flag: bool) -> int:
    if flag:
        fold x in xs with intermediate s 0:
            s - x
    else:
        0
xs = [1, 2, 3]
[a(xs), b(xs), c(xs, true), c(xs, false)]
""")
t("top-level", "positions", "value", "16", """
fold x in [1, 2, 3] with intermediate s 10:
    s + x
""", cls="HARNESS-DIFFERENCE", notes="The Tcl test's fold is the whole program's last statement; here it is the last expression of the static compile block, which is the body's value.")

# --- intermediates -----------------------------------------------------------
t("bool", "intermediates", "value", "[true, false, true]", """
fn all_positive(xs: List[int]) -> bool:
    fold x in xs with intermediate ok true:
        ok and x > 0
[all_positive([1, 2]), all_positive([1, -2]), all_positive([])]
""")
t("string", "intermediates", "value", '"a, bc, d"', """
fn join(xs: List[str]) -> str:
    fold x in xs with intermediate out "":
        if out == "":
            x
        else:
            out.concat(", ").concat(x)
join(["a", "bc", "d"])
""")
t("list", "intermediates", "value", "[2, 4, 6]", """
fn evens(xs: List[int]) -> List[int]:
    fold x in xs with intermediate out []:
        if x.mod(2) == 0:
            out.append(x)
        else:
            out
evens([1, 2, 3, 4, 6])
""")
t("struct", "intermediates", "value", "[3, 16, 9]", """
fn stats(xs: List[int]) -> List[int]:
    s = fold x in xs with intermediate st {n: 0, sum: 0, max: 0}:
        m = if x > st.max:
            x
        else:
            st.max
        {n: st.n + 1, sum: st.sum + x, max: m}
    [s.n, s.sum, s.max]
stats([3, 9, 4])
""")
t("named-struct", "intermediates", "value", "[-2, 7]", """
fn bounds(xs: List[int]) -> FoldRange:
    fold x in xs with intermediate r FoldRange {low: 1000, high: -1000}:
        lo = if x < r.low:
            x
        else:
            r.low
        hi = if x > r.high:
            x
        else:
            r.high
        FoldRange {low: lo, high: hi}
b = bounds([4, -2, 7])
[b.low, b.high]
""", notes="The Tcl program's struct Range is the suite's top-level FoldRange.")
t("nested-struct", "intermediates", "value", "[2, 1, 3]", """
fn f(xs: List[int]) -> List[int]:
    s = fold x in xs with intermediate st {pos: {line: 1, col: 0}, seen: []}:
        if x == 0:
            {pos: {line: st.pos.line + 1, col: 0}, seen: st.seen}
        else:
            {pos: {line: st.pos.line, col: st.pos.col + 1}, seen: st.seen.append(x)}
    [s.pos.line, s.pos.col, std::list::length(s.seen)]
f([5, 6, 0, 7])
""")
t("list-of-lists", "intermediates", "value", "[[1], [2, 2], [-2], [1]]", """
fn chunks(xs: List[int]) -> List[List[int]]:
    fold x in xs with intermediate out []:
        if x == 0:
            out
        elif x == 1:
            out.append([x])
        else:
            out.append([x, x]).append([-x])
chunks([1, 0, 2, 1])
""")
t("generic", "intermediates", "value", '[6, "<xy"]', """
fn reduce(xs, initial, step):
    fold x in xs with intermediate acc initial:
        step(acc, x)
fn add(a, b):
    a + b
fn cat(a: str, b: str) -> str:
    a.concat(b)
[reduce([1, 2, 3], 0, add), reduce(["x", "y"], "<", cat)]
""")
t("refined", "intermediates", "value", "[101, 1]", """
fn clamp(n: int) -> FoldPercent:
    if n < 0:
        return 0
    if n > 100:
        return 100
    n
fn needs(p: FoldPercent) -> int:
    p + 1
fn f(xs: List[int]) -> int:
    p = fold x in xs with intermediate acc clamp(0):
        clamp(acc + x)
    needs(p)
[f([30, 50, 40]), f([-5])]
""", notes="The Tcl program's type Percent is the suite's top-level FoldPercent.")
t("mutable-vector", "intermediates", "value", "[4, 1]", """
fn f(xs: List[int]) -> List[int]:
    v = std::mutable_vector::from_list([0])
    w = fold x in xs with intermediate acc v:
        acc.push(x * 10)
        acc
    [std::mutable_vector::length(w), std::mutable_vector::length(v)]
f([1, 2, 3])
""")
t("mutable-map", "intermediates", "value", "301", """
fn total(m: std::mutable_map::MutableMap[str, int]) -> int:
    fold e in m with intermediate t 0:
        t + e.value
fn build() -> std::mutable_map::MutableMap[str, int] errors std::mutable_map::KeyNotFound:
    m = std::mutable_map::create[str, int]()
    m.set("a", 1)
    m.set("b", 20)
    m.set("c", 300)
    m.remove("b")
    m
m = build():
    on std::mutable_map::KeyNotFound:
        std::mutable_map::create[str, int]()
total(m)
""")

# --- interactions --------------------------------------------------------------
t("callable-step", "interactions", "value", "11", """
fn fold_with(xs: List[int], f: Fn{args: [int, int], return: int}) -> int:
    fold x in xs with intermediate acc 0:
        f(acc, x)
fn mul_add(a: int, b: int) -> int:
    a * 2 + b
fold_with([1, 0, 1, 1], mul_add)
""")
t("closure-in-body", "interactions", "value", "6", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 1:
        fn add(n: int) -> int:
            acc + n
        add(x)
f([2, 3])
""")
t("coroutine", "interactions", "value", "[1, 3, 6, 6]", """
fn running(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        yield acc + x
        acc + x
fn drive() -> List[int]:
    coroutine {step, first} = running([1, 2, 3])
    a = step()
    b = step()
    c = step()
    [first, a, b, c]
drive()
""")

# --- typing and diagnostics -----------------------------------------------------
t("conflict-kinds", "diagnostics", "rejects", "FoldIntermediateType", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        "no"
f([1])
""", strength="weaker", notes="The code only.", retained="the diagnostic's line:column and message")
t("conflict-missing-else", "diagnostics", "rejects", "FoldIntermediateType", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        if x > 1:
            acc + x
f([1])
""", strength="weaker", notes="The code only.", retained="the diagnostic's line:column and message")
t("conflict-branch", "diagnostics", "rejects", "FoldIntermediateType", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc {n: 0}:
        if x > 2:
            {n: acc.n + 1, extra: true}
        else:
            acc
f([1, 5])
""", strength="weaker", notes="The code of the first diagnostic; that it is the only one (no UNPROVEN-FIELD cascade) stays in Tcl.",
  retained="that no further diagnostic is reported, and the first one's location and message")
t("conflict-named-structs", "diagnostics", "rejects", "FoldIntermediateType", """
fn f(xs: List[int]) -> int:
    r = fold x in xs with intermediate s FoldA {v: 0}:
        FoldB {v: x}
    0
f([1])
""", notes="The Tcl program's structs A and B are the suite's top-level FoldA and FoldB.")
t("conflict-incompatible-initial", "diagnostics", "rejects", "FoldIntermediateType", """
fn f(xs: List[int]) -> int:
    t = fold x in xs with intermediate acc "":
        x + 1
    t + 1
f([1])
""")
t("no-conflict-dynamic", "diagnostics", "value", "1", """
fn f(xs: List[int], seed) -> any:
    fold x in xs with intermediate acc seed:
        x
f([1], 0)
""", cls="HARNESS-DIFFERENCE", notes="The Tcl test checks the strict compilation is accepted; here the accepted block's value is compared too.")
t("no-conflict-paths-that-leave", "diagnostics", "value", "5", """
fn f(xs: List[int]) -> int errors FoldBoom:
    fold x in xs with intermediate acc 0:
        if x == 1:
            continue
        if x == 2:
            break
        if x == 3:
            return -1
        if x == 4:
            fail FoldBoom
        acc + x
f([5, 1, 2, 3]):
    on FoldBoom:
        0
""", cls="HARNESS-DIFFERENCE", notes="The Tcl test checks the strict compilation is accepted; here a run of it is compared too: 5 is carried, 1 continues, 2 breaks with 5.")
t("unhandled-initial", "diagnostics", "rejects", "UnhandledError", """
fn f(xs: List[int], k: int) -> int:
    fold x in xs with intermediate acc fold_boom(k):
        acc + x
f([1], 0)
""")
t("result-type-checked", "diagnostics", "rejects", "Type", """
fn needs_str(s: str) -> str:
    s
fn f(xs: List[int]) -> str:
    t = fold x in xs with intermediate acc 0:
        acc + x
    needs_str(t)
f([1])
""")
t("cardinality-not-domain", "diagnostics", "rejects", "LockstepUnproven", """
fn f(xs: List[int]) -> List[int]:
    r = fold x in xs with intermediate out []:
        out.append(x).append(x)
    loop a in r and i from 0 to std::list::length(xs):
        a + i
f([1, 2])
""")
t("affine-rejected", "diagnostics", "rejects", "AffineFoldUnsupported", """
fn gen() -> int:
    yield 1
    2
fn f(n: int) -> int:
    coroutine {step: h} = gen()
    c = fold i from 0 to n with intermediate c h:
        c
    0
f(2)
""", strength="weaker", notes="The code of the first diagnostic.", retained="both diagnostics' locations and messages")
t("break-outside", "diagnostics", "rejects", "BreakOutsideLoop", """
fn f(xs: List[int]) -> int:
    fold x in xs with intermediate acc 0:
        fn g() -> int:
            break
        acc + x
f([1])
""")

# --- syntax -------------------------------------------------------------------
t("parse-fold-is-a-name", "syntax", "value", "[3, 6, 4]", """
fold = 3
fn twice(fold: int) -> int:
    fold * 2
s = {fold: 4}
[fold, twice(fold), s.fold]
""")
t("parse-with-is-a-variable", "syntax", "value", "5", """
fn f(xs: List[int]) -> int:
    fold with in xs with intermediate intermediate 0:
        intermediate + with
f([2, 3])
""")

GROUPS = ["basics", "control", "order", "errors", "scope", "nesting", "positions", "intermediates",
          "interactions", "diagnostics", "syntax"]

HEADER = '''# fold-loops.bot -- folding loops (FOLD-LOOPS-MILESTONE-1.md), as a
# source-level specification:
#
# * `fold CLAUSES with intermediate acc INITIAL:` iterates exactly as `loop
#   CLAUSES:` does -- every clause form, lockstep, or none (until a break) --
#   but carries one value instead of collecting: `acc` is bound, in each
#   iteration, to the value the previous one produced (INITIAL for the
#   first); a normal completion of the body is the next one; the fold is the
#   last one, and an empty fold is INITIAL.
# * `continue` keeps the intermediate; a bare `break` ends the fold with the
#   current intermediate (never the value the body was about to produce);
#   `return` and errors leave the fold as they leave a loop.
# * The loop's operands are evaluated first, in written order, then INITIAL,
#   exactly once; the body then runs per iteration (the log tests: a
#   MutableVector place written by note()).
# * The intermediate is bound in the body only, immutable there (a
#   duplicate), shadowable in a nested scope, never visible in INITIAL, the
#   operands or after the fold, and never named like a loop variable.
# * The fold's type is the intermediate's: the join of INITIAL's and every
#   normal completion's; a join only the dynamic type covers is
#   FoldIntermediateType, an affine intermediate AffineFoldUnsupported.
# * `fold`, `with` and `intermediate` stay ordinary names elsewhere.
#
# Ported from tests/fold-loops.test, which stays authoritative and
# unchanged; a golden test keeps its Tcl test's name unless the fragment
# file (audit/golden/migration/fragments/fold-loops.tsv) records otherwise.
# What only the Tcl tests observe (HIR, Core IR and NIR text, types,
# diagnostic locations and messages, related locations, parse errors,
# -strict 0 runs) stays there. This file is generated by
# audit/fold-loops/tools/golden-port.py from the same table as its fragment.
#
# Imports: compiler and test; coroutine for yields; list, str, mutable_map
# and mutable_vector for the programs that use them.
import std::compiler
import std::coroutine
import std::list
import std::mutable_map
import std::mutable_vector
import std::str
import std::test

# Declarations the tests need (top-level only), renamed to stay apart from
# the other suites' and each other's: the Tcl programs' Range, Percent, A, B
# and their error helpers.
struct FoldRange:
    low: int
    high: int

type FoldPercent = Int in 0..100

struct FoldA:
    v: int

struct FoldB:
    v: int

error FoldBoom
error FoldBang

# Fails (FoldBoom) for an odd N: the error tests pass an N no proof decides.
fn fold_boom(n: int) -> int errors FoldBoom:
    if n.mod(2) == 1:
        fail FoldBoom
    n

fn fold_bang(n: int) -> List[int] errors FoldBang:
    if n > 0:
        fail FoldBang
    [n]

type FoldFactor = Int in 0..100

context struct FoldScale:
    factor: FoldFactor

# fold-loops-context: the body needs the installed FoldScale, so the
# registration function computes and the body compares (a body is a function
# value and cannot need a context).
fn fold_scaled(x: int, context s: FoldScale) -> int:
    x * s.factor

fn fold_scaled_sum(xs: List[int], context s: FoldScale) -> int:
    fold x in xs with intermediate acc 0:
        acc + fold_scaled(x)
'''

def code(name):
    return "t_" + name.replace("/", "_").replace("-", "_")

lines = [HEADER]
for group in GROUPS:
    params = ""
    if group == "errors":
        params = "one: int, zero: int, digits: List[int]"
    lines.append(f"fn register_fold_{group}_tests({params}):")
    for row in [r for r in TESTS if r["group"] == group]:
        fn = code(row["new"][len("fold-loops-"):])
        lines.append(f"    fn {fn}() errors std::compiler::CompilerError:")
        lines.append(f"        static compile:")
        for l in row["body"]:
            lines.append("            " + l if l else "")
        if row["outcome"] == "value":
            lines.append(f'    std::test::value("{row["new"]}", {row["expected"]}, {fn})')
        else:
            lines.append(f'    std::test::rejects("{row["new"]}", std::compiler::DiagnosticCode::{row["expected"]}, {fn})')
        lines.append("")
    if group == "interactions":
        lines.append("    # The context test: computed here, compared by the body.")
        lines.append("    context_value = fold_scaled_sum([1, 2, 4])")
        lines.append("    fn context() errors std::compiler::CompilerError:")
        lines.append("        context_value")
        lines.append('    std::test::value("fold-loops-context", 21, context)')
        lines.append("")
    lines[-1:] = [""]
    lines.append("")
lines.append("fn register_fold_loops_tests():")
for group in GROUPS:
    if group == "errors":
        lines.append("    register_fold_errors_tests(1, 0, [1, 2, 3, 4])")
    else:
        lines.append(f"    register_fold_{group}_tests()")
lines.append("")
lines.append("with context std::test::suite()")
lines.append("with context FoldScale {factor: 3}")
lines.append("register_fold_loops_tests()")
lines.append("std::test::report()")
open("tests/golden/fold-loops.bot", "w").write("\n".join(lines) + "\n")

# The registration function of the interactions group needs the context.
src = open("tests/golden/fold-loops.bot").read()
src = src.replace("fn register_fold_interactions_tests():", "fn register_fold_interactions_tests(context s: FoldScale):")
src = src.replace("fn register_fold_loops_tests():", "fn register_fold_loops_tests(context s: FoldScale):")
open("tests/golden/fold-loops.bot", "w").write(src)

# The fragment.
COLS = "old_file old_test suite new_test category outcome old_backends new_backends class also static handler api verbosity strength old_lines new_lines mutants notes subsystem status tcl_retained tcl_layer freeze tags".split()
rows = []
def frag(old, new, outcome, cls, strength, notes, retained, body_lines, tags):
    status = "SPLIT" if retained != "-" else "MIGRATED"
    d = dict(old_file="tests/fold-loops.test", old_test=old, suite="fold-loops.bot", new_test=new,
             category="fold-loops", outcome=outcome,
             old_backends="interp, compile, cranelift-generic, cranelift (fl: -strict 0 HIR without diagnostics, outcomeUnderHir, must agree)" if outcome == "value" else "strict compilation (flDiagnostics/flKinds)",
             new_backends="interp, compile, cranelift-generic, cranelift", **{"class": cls}, also="-",
             static="convention", handler="no", api="simple", verbosity="more-verbose", strength=strength,
             old_lines=str(len(body_lines)), new_lines=str(len(body_lines) + 2), mutants="-", notes=notes,
             subsystem="surface", status=status, tcl_retained=retained, tcl_layer="-", freeze="-", tags=tags)
    rows.append("\t".join(d[c] for c in COLS))
for r in TESTS:
    tags = "MULTI-BACKEND" if r["outcome"] == "value" else "STATIC"
    frag(r["old"], r["new"], "value" if r["outcome"] == "value" else "rejection", r["cls"], r["strength"],
         r["notes"], r["retained"], r["body"], tags)
frag("fold-loops-context", "fold-loops-context", "value", "HARNESS-DIFFERENCE", "equal",
     "Computed in the registration function, which requires the installed FoldScale (a body is a function value and cannot need a context); the Tcl program installs Scale itself.",
     "-", ["", "", "", "", "", "", "", "", "", "", ""], "MULTI-BACKEND")
open("audit/golden/migration/fragments/fold-loops.tsv", "w").write("\t".join(COLS) + "\n" + "\n".join(rows) + "\n")
print(len(TESTS) + 1, "golden tests")
