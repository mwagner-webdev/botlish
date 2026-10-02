# COLLECTING-LOOPS.md

Complete the numeric collecting-loop forms (`through`, `down from`) and add
lockstep iteration (`and`) with a statically proven common cardinality.

## Outcome

Four numeric loop forms and lockstep composition are implemented end to end
(surface parser → HIR → core IR / interpreter → Tcl compiler → native NIR and
Cranelift → standalone executables), with the interpreter as the semantic
reference. The numeric forms are one regular family; lockstep is a general
"iteration domains share one proven cardinality" construct, not `enumerate`.

One premise of the task did not match the code and was resolved with the
user before implementation: **`loop i from a to b:` was a *procedural* loop**
(body values discarded, natural exhaustion `unit`, `break VALUE` override at
the core-IR level), not a collecting one
(R2A3-COUNTED-LOOPS-FINAL-SOURCE.md; RETURNING-ITERABLE-LOOPS.md "Why counted
loops remain unchanged"). The user decided: *make all currently existing and
specified loops collecting.* So every numeric loop, including the pre-existing
`from .. to`, now has `loop x in xs:`'s result model. That is the one place an
existing program's meaning changes (its result is the List of body values, not
`unit`); see "Behavior change" below. A bare `loop:` has no iteration domain
and is unchanged (see "Open questions").

## Syntax

```botlish
loop i from a to b:                  # a <= i <  b   ascending, end exclusive
loop i from a through b:             # a <= i <= b   ascending, end inclusive
loop i down from b to a:             # b >= i >  a   descending, end exclusive
loop i down from b through a:        # b >= i >= a   descending, end inclusive
loop x in xs and i from 0 to list_length(xs):    # lockstep
```

| syntax | direction | first value | stops when |
|---|---|---|---|
| `from a to b` | up | `a` | `i >= b` |
| `from a through b` | up | `a` | `i > b` |
| `down from b to a` | down | `b` | `i <= a` |
| `down from b through a` | down | `b` | `i < a` |

`from`/`down from` carry direction, `to`/`through` carry endpoint inclusion;
`to` is exclusive, `through` inclusive. Direction never reverses by itself:
`from 5 through 2` and `down from 2 through 5` are empty.

Grammar (`surface/parser.tcl`):

```
loop   = "loop" [ clause { "and" clause } ] ":" suite
clause = IDENT "in" operand
       | IDENT [ "down" ] "from" operand ( "to" | "through" ) operand
```

`in`, `from`, `down`, `to`, `through` and `by` are contextual: none is a lexer
keyword and each stays an ordinary name everywhere else (and even as a loop
variable: `loop down from 1 through 3:` works; pinned in
`tests/loop-collecting.test`). `and` is already a keyword (the boolean
operator), so a clause *operand* is parsed one precedence level below it
(`LoopOperand`): `loop x in a and b:` no longer means `x in (a and b)`; an
operand that needs the boolean operator is parenthesized. `by` is still
recognized only to be rejected as reserved.

Names: the language's list length is `list_length(xs)` (`length` is the String
length); the task text's `length(list)` is spelled `list_length(xs)` in
source. No built-in was added or renamed.

## Exact semantics

* **Collecting.** Like `loop x in xs:` (RETURNING-ITERABLE-LOOPS.md): each
  normal body completion contributes its value, in order; `continue`
  contributes nothing; a bare `break` ends the loop with the List collected so
  far; `return` and errors propagate out as before; exhaustion yields the whole
  List (`[]` for an empty domain). One result model for every loop with an
  iteration clause; `break VALUE` is a syntax error at the surface
  (PAYLOAD-FREE-BREAK.md) and the HIR diagnostic `LISTLOOP-BREAK-VALUE` now
  guards `countloop`/`lockloop` targets too (raw core IR only).
* **Domains.** Bounds are arbitrary-precision `Int`s, checked dynamically (a
  non-Int bound is the ordinary `TYPE` error, no new loop-only error kind),
  evaluated once, in the enclosing scope, in written order, before the first
  iteration (the order the existing loop already had; nothing new is promised
  about independent bounds beyond that). The loop variable is a fresh immutable
  binding per iteration and is not in scope in any clause operand.
* **Empty domains.** The body never runs; the result is `[]`. Under each form
  that is: `a >= b`, `a > b`, `b <= a`, `b < a` respectively.
* **Inclusive without overflow.** `through` is tested with `<=`/`>=` against
  the endpoint; no `b + 1` / `a - 1` is formed at any level, so there is no
  `INT_MAX + 1` / `INT_MIN - 1` artifact. At HIR the endpoint kind is the field
  `endKind: inclusive`, never rewritten arithmetic; the only `+ 1` that exists
  is the *mathematical* cardinality formula (a compile-time proof object that
  is never materialized).
* **Lockstep.** One loop; position `k = 0, 1, …`; iteration `k` binds every
  clause variable to its domain's `k`-th element (list item, or
  `a ± k`) and runs the body once. `continue` advances all clauses (there is no
  way to advance one), `break` ends the whole loop, a body error ends it, and
  the result is collected exactly like a single-domain loop's. `and` is not a
  Cartesian product (nested loops remain the way to write that), not `zip`
  (no shortest-wins), and has no runtime length check.

## Iteration domains and cardinality (HIR)

`hir/hir.tcl` documents the nodes; `hir/cardinality.tcl` is the proof
vocabulary; `hir/lockstep.tcl` is its one consumer.

* `countloop`: `start end direction (up|down) endKind (exclusive|inclusive)`
  plus the induction binding and body. `start` is *where iteration begins*
  (`a` for `from a`, `b` for `down from b`) and `end` the limit, so the same
  two fields describe all four forms; direction and endpoint inclusion are
  explicit semantic data, never `end + 1` / `start - 1`.
* `listloop`: unchanged (`iterable`, `elementBinding`).
* `lockloop`: `domains` (a list of `{kind list binding iterable}` or
  `{kind count binding start end direction endKind}` dicts in written order),
  `bodyScope`, `body`. It is *one* node with several domains and one iteration
  scope binding one parameter per domain, not nested loops. The surface keeps
  the same shape (`loop` node `clauses`, one entry per written clause; the
  single-clause forms also keep their older per-form fields). The architecture
  is "iteration domain + cardinality fact": nothing in it knows the word
  `enumerate`, and any number of clauses is supported.
* **Cardinality.** `hir::cardinality::domains` lists a loop's domains and
  `hir::cardinality::of_domain` returns the domain's exact cardinality as a
  symbolic *linear form* over atoms (below). The formulas, as mathematics on
  unbounded integers:

  | domain | cardinality |
  |---|---|
  | `x in L` | `length(L)` |
  | `i from a to b` | `max(b - a, 0)` |
  | `i from a through b` | `max(b - a + 1, 0)` |
  | `i down from b to a` | `max(b - a, 0)` |
  | `i down from b through a` | `max(b - a + 1, 0)` |

  `max(F, 0)` is folded into the form: a provably nonnegative `F` stays `F`, a
  constant clamps, anything else becomes one nonnegative atom `{max F}`.
  Atoms name immutable values only: `{len KEY}` (the length of one List value;
  `KEY` is the defining expression an alias chain ends at, or a parameter /
  loop binding), `{max FORM}`, `{v B}` (an Int-valued binding) and `{e E}` (one
  specific expression no rule folds, equal only to itself). Immutable
  single-assignment bindings are what make equal atoms the same value — the
  argument `hir/exactvalue.tcl` already relies on.
* **Existing facts reused**, no new List-length inference: exact Ints and exact
  List literals from `hir/exactvalue.tcl` (followed through immutable
  bindings); the `+ - *` and `list_length` natives; `list(...)` literals; and
  this file's own exact/`max` output-length fact for collecting loops (a
  `ys = loop x in xs: …` with no `break`/`continue` has exactly `length(xs)`
  elements, which now also covers numeric and lockstep loops).
* **Comparison.** Two cardinalities are `equal` iff their normalized forms are
  identical; `unequal` iff they differ by a nonzero constant (both are ≥ 0, so
  a constant gap is a real gap); otherwise `unknown`.

## Lockstep validation and diagnostics

`hir::lockstep::verify` runs with the other HIR checks (`hir::CheckOnce`),
compares every clause against the first, and records one diagnostic per
rejected loop:

* `LOCKSTEP-UNPROVEN` — "lockstep loop requires equal iteration counts; could
  not prove `length(xs)` == `length(ys)` (clause 1 vs clause 2)".
* `LOCKSTEP-UNEQUAL` — "…; clause 1 iterates 3 times but clause 2 iterates 4
  times" (also e.g. `length(xs)` vs `length(xs) + 1`).
* `DUPLICATE-LOOP-VARIABLE` — two clauses bind the same name.

Equal-at-runtime is irrelevant: `loop x in xs and y in ys:` over two
parameters is rejected even when the caller passes equal lists. There is no
fallback to a runtime check. For a `-strict 0` lowering (diagnostics kept) a
rejected loop is marked (`unproven` on its HIR node) and *replays the
diagnostic* as an unconditional run-time error in the interpreter and Tcl
compiler — it never runs the loop; native sees the diagnostic as an AOT
blocker like any other. The reference interpreter additionally cross-checks the
proof it is handed and reports an internal error ("the compiler's
equal-cardinality proof was wrong") on a mismatch; that is an oracle for
fuzzing, not language semantics.

### What is accepted (pinned in `tests/loop-collecting.test`)

* `loop x in xs and i from 0 to list_length(xs):` (canonical; `through`/`down`
  variants, numeric clause first, three clauses);
* `n = list_length(xs)` then `… i from 0 to n` (alias chain through the
  immutable binding);
* different syntax, same exact cardinality: `i from 0 to n and j from 10 to 10
  + n`; `i from 0 through n and j down from n through 0`;
  `from 0 through list_length(xs) - 1`-style offsets;
* all-empty constant domains, e.g. `from 3 to 1` with `from 5 through 0`;
* two lists when their lengths are known by construction: the same list (or an
  alias), `ys = loop x in xs: …` against `xs`, equal-length list literals.

### What is rejected

* unknown relation: `x in xs and y in ys` (parameters), two separate calls,
  `from 0 to n and j from 0 to n + 1` (they are equal for `n < 0`, so this is
  *unproven*, not disproven);
* provably different: `from 0 to 3` vs `from 0 to 4`, `length(xs)` vs
  `length(xs) + 1`, literal lists of different length.

## Lowering

* **Core IR** (`core/ir.tcl`): `(countloop START END BLOCK ?up|down to|through?)`
  — the trailing words default to the original `up to` form — and
  `(lockloop (DOMAIN…) BLOCK ?REJECTED?)` with `DOMAIN` = `(list EXPR)` or
  `(count START END DIRECTION ENDKIND)`. `hir::lower` emits them; core IR is
  the Tcl reference interpreter's representation only.
* **Interpreter** (`core/evaluator.tcl`): `op-countloop` iterates arbitrary
  precision Tcl integers with `<`, `<=`, `>`, `>=` and `expr`-based advance
  (never `incr`: AGENTS.md's i64 bug); `op-lockloop` builds each domain, takes
  the common count, cross-checks it, and runs `k = 0…`.
* **Tcl compiler** (`compiler/compiler.tcl`): `for` with the matching
  comparison and a collecting accumulator registered with the loop (so the
  shared `break` yields the prefix); `lockloop` is one `for` over a position
  counter (`lindex` / `start ± k`).
* **Native** (`native/lower.tcl`): both read the resolved HIR directly (no
  core IR on the native path, AGENTS.md). `CountLoop` is `ListLoop`'s
  CFG shape with a numeric induction register: `op ilt|ile|igt|ige` against
  the endpoint, `op iadd|isub 1` at the continue label, and the usual
  `discarded` optimization (a loop whose List nothing reads allocates no
  output List; the existing corpus' statement-position loops — `lib/web.bot`'s
  `scan_while`/`domain?`, `lib/mutarray.bot` — compile to the same loop body as
  before). `LockLoop` is one CFG loop: each numeric clause keeps its own
  induction register, all list clauses share one position register, everything
  advances at the single continue label, and the continuation test is the
  first clause's own — HIR has proven every other clause the same length, so
  the `listget` at the shared position is in bounds by construction and no
  runtime cardinality check exists. No descending/inclusive loop becomes a
  recursive call; nothing here lowers HIR to core IR or back.
* **Passes updated** (every one that knows loop kinds): `hir/types.tcl`
  (`List[R]`), `hir/range.tcl` (`InductionSeed`), `hir/completions.tcl`,
  `hir/callables.tcl`, `hir/signatures.tcl`, `hir/construction.tcl`,
  `hir/aot.tcl` (body value used, not discarded), `hir/escape.tcl`,
  `hir/format.tcl`/`hir/read.tcl` (HIR text round trip), `native/rawabi.tcl`
  (body value is a result-List element).

## RawInt interaction

Unchanged: no RawInt semantics, selection policy or heuristic was touched.
The new loops are additional consumers/producers of the same proven facts:
`hir::range::InductionSeed` supplies the induction binding's interval (up/to
`[start.min, end.max-1]`, up/through `[start.min, end.max]`, down/to
`[end.min+1, start.max]`, down/through `[end.min, start.max]`) — arithmetic on
*range bounds*, not program values, so it cannot overflow — and the loop's own
test/advance are the generic tagged-or-BigInt `ilt…`/`iadd`/`isub` ops, exactly
as the old counted loop's were. Large Int bounds work without RawInt (tests at
and beyond `i64` and the tagged-small-Int boundary, on every backend).

## Behavior change

Pre-existing counted loops now collect. Concretely: `loop i from 0 to 3: i`
was `unit` and is `[0, 1, 2]`; `break` returned `unit` and now returns the
collected prefix; a counted loop that is the last expression of a function now
returns a List. In the shipped corpus every counted loop is in statement
position (`lib/web.bot`, `lib/mutarray.bot`), so nothing observable changed
there and the native discarded-result optimization keeps their code identical.
`tests/loop-counted.test` was updated for the new results and for the two
reserved-diagnostic tests (`down from`, `through`), which are now implemented.

## Tests

* `tests/loop-collecting.test` (140 tests, every behavioral one on all four
  in-process backends: interpreter, Tcl compiler, native generic, native):
  - all four numeric forms: empty, single, several, reversed, negative, equal
    endpoints, big and beyond-`i64` bounds, dynamic bounds, body arithmetic at
    the `i64` edge, `continue`/`break`/`return`, nesting both ways, closures;
  - bounds evaluated once and in order (raw IR, `test-tick`/`test-log`);
  - parser: all forms, clause lists, contextual keywords, error messages;
  - lockstep: enumerate-shaped, `list_length` proof, alias proof, numeric
    first, inclusive/descending mixes, shifted domains, negative `n`, three
    clauses, lists equal by construction, empty, large Ints, `continue`,
    `break`, `return`, body error, non-list operand, not-Cartesian, nesting
    (lockstep in/around ordinary loops and in lockstep), scope, duplicates;
  - rejections: unknown, unequal constants, off-by-one, literals, symbolic,
    unrelated parameters, call results, third clause, `-strict 0` replay;
  - representation: HIR fields, one `lockloop` node, cardinality formulas and
    symbolic normalization, HIR text round trip, core IR validation;
  - native: discarded loops build no List, retained loops accumulate, the four
    comparison ops, lockstep is one CFG loop; standalone executables (with and
    without GC stress).
* `tests/loop-counted.test` (60) updated; `loop-in`, `loops`, `surface-*`,
  `hir-*` unchanged and green.
* Full per-file suite: see "Verification".

## Verification

Environment: Tcl 9.0.1 (the repo's pinned `.deb`), rustc 1.97, release build of
`native/`, `LANG=C.utf8 LC_ALL=C.utf8`.

* **Test suite** — every `tests/*.test` file run on the final tree: 4004 tests,
  0 failed, 0 skipped (this count was taken before the last additions of this
  milestone: 14 more `loop-collecting` tests, the executable/native-NIR tests,
  and 2 `native-root-liveness` tests, all passing individually: 140 and 20
  respectively). The one baseline comparison attempted (clean worktree of
  `HEAD`) could not finish inside the tool's background time limit, so the
  claim is "no failure on the final tree", not a before/after diff; the only
  tests whose expectations changed are the deliberate ones in
  `tests/loop-counted.test`.
* **GC stress** (`BOTLISH_NATIVE_GC_STRESS=1`) — `loop-collecting`,
  `loop-counted`, `loop-in`, `loops`, `native-listloop`,
  `native-root-liveness` (including the new collecting/lockstep root tests)
  pass. CI's own `gc-stress` job on the branch was not run from this session.
* **Differential fuzzing** — `fuzz.sh 1 300` × four ranges (seeds 1–1200; 300
  numeric loops vs the independent model + 4 backends, 300 legal lockstep
  loops vs the zip model + 4 backends, 300 deliberately unequal loops, all
  rejected at compile time: 142 `LOCKSTEP-UNEQUAL`, 125 `LOCKSTEP-UNPROVEN`,
  33 degenerate shifts of an already-empty domain skipped; 300 soundness
  programs): 0 failures. A further 2000 soundness programs (seeds 10003–18002;
  473 accepted by the compiler, each run on 30 parameter assignments on the
  cross-checking interpreter and on 3 across all backends): 0 unsound
  acceptances. A GC-stress slice (seeds 5000–5059): 0 failures.
* **NIR** — for a statement-position `loop i from 0 to n:` the generated
  function body is byte-identical to the pre-change output (no `listnew`/
  `listappend`); no performance numbers were collected (none required).

## Fuzzing

`audit/collecting-loops/tools/fuzz.tcl` (and `fuzz.sh`, which runs it in
slices: native JIT memory lives for the life of a process):

* **numeric** — random loops (all four forms, bounds from small literals,
  parameters, parameter ± k, outer-variable ± k, and values around/past
  `i64`/tagged-small boundaries; random `continue`/`break`/`return` guards; one
  nested level) compared against an *independent Tcl model* of the semantics
  and across all four backends;
* **lockstep** — legal programs built so each clause has the same proven
  cardinality (constant, parameter, `list_length`, collecting-loop result;
  all numeric forms and offsets): must be accepted and equal the zip model on
  every backend;
* **unequal** — the same constructions with one clause shifted: must be
  rejected at compile time (`LOCKSTEP-UNEQUAL` or `LOCKSTEP-UNPROVEN`);
* **sound** — random clause pairs over two free parameters: whenever one is
  accepted it is run over a grid of parameter values (negative, zero,
  positive) on the cross-checking interpreter — an accepted program with
  unequal runtime counts is an unsound proof rule — and over several on all
  backends.

Results: see "Verification".

The harness caps each slice (`ulimit`, `timeout`) because an early generator
revision paired a huge literal with a small one, producing an astronomically
large (but legitimate) domain; big values are now generated only as a *window*
(both bounds near a boundary).

## Known proof limitations

What currently stops additional legal lockstep programs from proving equal:

* **Relational facts are linear and syntactic.** Cardinalities are linear forms
  over atoms; there is no solver. `from 0 to n` vs `from 0 to n + 1` is
  *unproven* because the two are equal when `n < 0`; with `n >= 0` known (e.g.
  `n = list_length(xs)`) the same pair is `UNEQUAL`, but the compiler does not
  use branch/range facts (`if n >= 0:`) to strengthen a parameter — wiring
  `hir/range.tcl` intervals into the comparison is the natural extension.
* **Multiplication and non-linear arithmetic** are atoms unless one side is a
  constant; `n * n`, `n - n` etc. are not simplified beyond linear forms
  (`n - n` does fold to 0).
* **Calls are never assumed equal.** `f(x)` twice is two atoms (no purity or
  determinism facts are used), as is anything `hir/exactvalue.tcl` cannot fold.
* **List lengths**: only literals, aliases, `list(...)`, and the exact-length
  output of a collecting loop are known. `list_append`, `list::` helpers,
  struct fields and values flowing through function results are not (no new
  List-length inference was added, per scope). `ys = loop … if c: continue …`
  (not exact) is unknown.
* **A list clause cannot be shifted**: a list's length has no `+ 1` form, so
  list-vs-numeric pairs prove only when the numeric side normalizes to
  exactly `length(xs)`.
* **Aliasing through `if`/closures** stops the alias chain (the `bind` must be
  a plain single assignment).

## Corpus refactoring opportunities now unlocked

* Recursive accumulator loops that count down (`fn drive(i, total): if i <=
  0: return total …`) can become `loop i down from n through 1:` plus a direct
  result.
* `loop-counted.test`, `lib/web.bot`'s `scan_while`/`tld?`/`domain?` and
  `lib/mutarray.bot`'s `from_list`/`create` can use collected results directly
  (e.g. `from_list` as `loop x in xs and i from 0 to …` without a manual
  index) — not changed in this milestone.
* Manual index maintenance around `list_get(xs, i)` becomes
  `loop x in xs and i from 0 to list_length(xs):`.

## Answers to the required questions

1. Existing `from … to …` unchanged? Its *domain and endpoint* semantics are
   unchanged; its **result** changed from `unit` to the collected List, by the
   user's explicit decision (see Outcome / Behavior change).
2. Is `to` exclusive? Yes.
3. Is `through` inclusive? Yes.
4. `down from … to …`: `b, b-1, …` while `i > a` (end exclusive).
5. `down from … through …`: `b, b-1, …` while `i >= a` (end inclusive).
6. Zero iterations when the domain is empty: `from a to b` with `a >= b`;
   `from a through b` with `a > b`; `down from b to a` with `b <= a`;
   `down from b through a` with `b < a`. The result is `[]`; the body never
   runs.
7. Inclusive loops without `end + 1` / `start - 1`? Yes: `<=`/`>=` tests; the
   HIR carries `endKind`.
8. Arbitrary-precision bounds still valid? Yes, on every backend, including
   beyond `i64` and across the tagged-small-Int boundary.
9. Bound expressions evaluated once? Yes (pinned for all four forms).
10. All four forms collecting with the same body semantics? Yes.
11. Reduction syntax introduced? No.
12. HIR representation: `countloop` with `direction` and `endKind` fields;
    `listloop`; `lockloop` with a `domains` list (see above).
13. Cardinality representation/proof: symbolic linear forms over immutable-value
    atoms with `max(·,0)` folded (`hir/cardinality.tcl`); compared in
    `hir/lockstep.tcl`.
14. Formulas: `max(b-a,0)`, `max(b-a+1,0)`, `max(b-a,0)`, `max(b-a+1,0)` for the
    four forms in table order (with `start`/`end` as the first/second written
    operand).
15. Cardinality of `x in list`: `length(list)`.
16. Does `x in xs and i from 0 to length(xs)` compile? Yes (spelled
    `list_length(xs)`).
17. Lockstep is one loop, not nesting? Yes (`lockloop`, one CFG loop natively).
18. Does lockstep stop at the shortest domain? **no**
19. Can unequal/unknown cardinalities fall back to a runtime check? **no**
20. Diagnostic when equality cannot be proved: `LOCKSTEP-UNPROVEN` — "lockstep
    loop requires equal iteration counts; could not prove A == B (clause 1 vs
    clause N)"; provably different cardinalities: `LOCKSTEP-UNEQUAL`.
21. Equivalent but syntactically different domains lockstep? Yes when the
    normalized linear forms are identical (e.g. `0 to n` with `10 to 10 + n`).
22. List/list lockstep when equal length is provable? Yes (same list, aliases,
    `ys = loop x in xs: …`, equal literals).
23. Does `continue` advance all domains? Yes.
24. Does `break` terminate the whole lockstep loop? Yes.
25. Interpreter/compiler/native results identical? Yes — pinned by the test
    suite and checked by the fuzzers on every run.
26. Did RawInt semantics change? **no**
27. Was any profitability/performance heuristic added? **no**
28. What prevents more legal lockstep cases from proving equal? See "Known proof
    limitations": linear syntactic forms only, no range/branch facts, calls are
    never assumed equal, no List-length inference beyond existing facts.

## Open questions

* **Bare `loop:` was left as it is.** It has no iteration domain; making it
  collecting would change `bench/loop-count.ir`'s documented core-IR `break
  VALUE` benchmark and its recorded comparison trail (PAYLOAD-FREE-BREAK.md's
  "two-tier design"). The instruction "make all existing loops collecting" was
  read as covering the loops with iteration clauses. If bare `loop:` should
  collect too, that is a separate, mostly mechanical change in
  `hir/types.tcl` / the three backends plus that benchmark's treatment.
* **`break VALUE` / `leave VALUE`.** `break VALUE` is gone from the surface (a
  parse error, PAYLOAD-FREE-BREAK.md). It survives only *below* the parser, in
  core IR / HIR, for a bare loop (`bench/loop-count.ir`); no surface program can
  produce it, and a collecting loop's HIR now rejects it. `leave VALUE` does not
  exist yet — it is only mentioned as the intended future lowering target in a
  `hir/resolve.tcl` comment.
