# RETURNING-ITERABLE-LOOPS.md

**Partially superseded by COLLECTING-LOOPS.md:** the section "Why counted
loops remain unchanged" below is no longer true. COLLECTING-LOOPS.md made
`loop i from a to b:` (and the new numeric forms) collecting loops with
exactly the semantics this report gives `loop x in xs:`.

## Outcome

`loop x in xs:` (core IR `listloop`) already existed as a language
construct before this milestone (added for BYTE-SET.md, audited in
LISTLOOP-BREAK-TYPE-SOUNDNESS.md), fully implemented in the surface
parser, HIR, the interpreter, and the Tcl "compile" backend, but *not* in
the native (Cranelift) backend's own Rust runtime — its native lowering
lived entirely in `native/lower.tcl` (Tcl-side NIR generation), already a
genuine direct-traversal CFG loop with no Iterator/callback abstraction.

Its one load-bearing gap against this milestone's required semantics was
`break`: a bare `break` ended the loop with `unit` as the *whole* listloop's
result, and `break VALUE` overrode that result with VALUE, discarding
whatever had been collected — a deliberate, previously-audited design
(LISTLOOP-BREAK-TYPE-SOUNDNESS.md), directly incompatible with this
milestone's required "bare break returns the collected prefix; break VALUE
is invalid" semantics. Per this milestone's own stop condition (item 6/78),
this was reported to the user before any change; the user chose to redefine
listloop's break semantics to match the milestone spec. That redefinition,
the native backend's own discarded-result optimization, a small cardinality-
fact module, and the four stdlib helpers are what this milestone actually
built; see "Prior loop architecture" below for exactly what pre-existed.

## Prior loop architecture

Before this milestone, `loop x in xs:` already had:

- Surface syntax (`surface/parser.tcl`), core IR (`core/ir.tcl`'s
  `listloop`), and HIR (`hir/hir.tcl`'s `listloop` node: `iterable`,
  `elementBinding`, `bodyScope`, `body`).
- Interpreter lowering (`core/evaluator.tcl`'s `op-listloop`): eager,
  left-to-right, one iteration-scope per element, `continue` skipping
  accumulation, `return`/error propagating directly.
- Tcl "compile" backend lowering (`compiler/compiler.tcl`'s
  `CompileListLoop`): a Tcl `foreach` with a manual accumulator,
  `continue` mapped to Tcl `continue`.
- Native (Cranelift) backend lowering (`native/lower.tcl`'s `ListLoop`):
  already a genuine indexed CFG loop — evaluate the iterable once, get its
  length, an index/accumulator register pair rebound at the loop's own
  back edge, `listget` at a proven-in-bounds index, `listappend` to grow
  the result. No Iterator, no per-element pair object, no synthetic
  recursive function. `break`/`continue` already shared the same
  `loops`-dict registration mechanism a bare `loop`/`countloop` used.
- Static typing (`hir/types.tcl`): `List[R]`, `R` the body's own type,
  already correctly excluding `continue` and using the existing empty-List
  convention for exhaustion.
- Cardinality-relevant tests, closure-per-iteration lexical discipline (via
  the same per-iteration scope machinery `loop`/`countloop` already used),
  and iterable-evaluated-once, already covered by `tests/loop-in.test`.

Only `break`'s own semantics (this report's main subject), the native
backend's discarded-result optimization, a cardinality-fact
representation, and the four stdlib search/reduction helpers were new.

## Surface syntax

Unchanged: `ys = loop x in xs: BODY`. No new keyword; no `collect`/`map`/
`lmap` introduced (items 36-38: hard non-goals, upheld).

## Why iterable loops return Lists

Every normal per-iteration body value is retained, in order, into one
output List — the general collection-transformation primitive items 1 and
83 describe, replacing `map`/`filter`/`filter_map` outright (`list::any?`/
`all?`/`none?`/`find` below are the only higher-order helpers this
milestone adds, and each is a genuine search/reduction, not a
transformation `loop x in xs: ...` could not already express directly).

## Why counted loops remain unchanged

`loop i from start to end:` (`countloop`) is procedural, not collecting
(core/ir.tcl's own documented distinction, unchanged): an ordinary body
value is discarded, not accumulated, and `break` (with or without a value)
still overrides the result — exactly a bare `loop:`'s own semantics, which
this milestone also leaves untouched. Scope item 2 requires this
explicitly; R2A3-COUNTED-LOOPS-FINAL-SOURCE.md's own shipped semantics are
unaffected. All existing `tests/loop-counted.test`/`tests/loops.test`
coverage passes unchanged (see "Full regression").

## Evaluation order

`xs` is evaluated exactly once, in the enclosing scope, before any
iteration — pre-existing behavior, re-pinned by
`loop-in-iterable-evaluated-once` (`tests/loop-in.test`): a
`test-tick`-instrumented iterable expression ticks exactly once regardless
of the List's own length. Elements are visited left to right, one at a
time, eagerly; a `continue`d iteration is never revisited, and nothing
after a `break` is visited (both pinned by dedicated tests below).

## Normal-value retention

Unchanged: an iteration whose body completes with an ordinary value
contributes that value to the result, in order. `[2, 4, 6]` for `loop x in
[1, 2, 3]: x + x`.

## `continue` semantics

Unchanged: contributes nothing for that iteration, moves on. The ordinary
Botlish filtering idiom (item 4): `loop x in xs: if x % 2 == 0: continue \n
x`. No `list::filter` exists or is needed.

## `break` semantics — the actual redefinition

**Before this milestone:** a valueless `break` made the whole listloop's
result `unit`; `break VALUE` made it VALUE — in both cases discarding
whatever had already been collected (LISTLOOP-BREAK-TYPE-SOUNDNESS.md's own
subject, and exactly a bare `loop`'s own semantics, reused verbatim for
listloop).

**After this milestone:** a bare `break` ends the loop immediately and
returns the List collected so far — the accumulated prefix — never `unit`,
never overriding the accumulator. `loop x in [1, 2, 3, 4]: if x == 3: break
\n x` now produces `[1, 2]` (`loop-in-break-returns-prefix`). A listloop now
has exactly one stable result type for every successful exit: `List[R]`,
whether by normal exhaustion or a bare break.

This was a genuine breaking change to already-shipped, tested, audited
behavior, so it was reported to the user (per the milestone's own item
6/78 stop condition) before being made; the user confirmed redefining
listloop's break semantics to match this milestone's spec. No shipped
`lib/*.bot` or `examples/` source used `break`/`break VALUE` inside a
`loop x in ...:` (`byte::set`'s own listloop has no break at all), so the
change's real-code blast radius was zero; the cost was entirely in
`tests/loop-in.test`'s own adversarial-soundness section (rewritten, see
below) and `LISTLOOP-BREAK-TYPE-SOUNDNESS.md` (marked superseded, its own
content preserved as a historical record of the prior design).

## `break-value` decision

**`break VALUE` inside a returning iterable loop is now a compile-time
error**, exactly the milestone's own preferred rule (item 6): a listloop
has exactly one stable result type, so a break payload of some unrelated
type could never soundly coexist with it. Rejected at `hir/resolve.tcl`
(the `break` case, where a break's `target` loop is already resolved) as
soon as the target's own HIR node kind is `listloop` and the break node
carries a value — diagnostic kind `LISTLOOP-BREAK-VALUE`. A bare `loop:` or
`countloop` target is completely unaffected: `break VALUE` there keeps its
pre-existing override semantics unchanged (`loop-in-break-value-plain-loop-
unaffected`).

This removes, rather than re-derives, the hazard LISTLOOP-BREAK-TYPE-
SOUNDNESS.md's audit had to reason about (an incompatible break-payload
type reaching a declared `List[int]` result at runtime): with `break
VALUE` rejected outright, `hir/types.tcl`'s listloop case no longer needs
to lub break-payload types into its own result type at all — it is always
exactly `MakeList(bodyType)`, unconditionally (see "Element type" below).

## `return`/Error propagation

Unchanged, and unaffected by the break redefinition: `return` inside a
listloop's body propagates out of the enclosing function, abandoning the
loop with no partially-collected List ever observable; a propagating error
does the same. Both pinned by pre-existing tests
(`loop-in-return-propagates`, `loop-in-error-propagates`, and their parity
variants), which continued to pass unmodified.

## Element binding/scoping

Unchanged: `x` is an immutable, per-iteration-fresh lexical binding, not
visible in the iterable expression, visible only in the body, not visible
after the loop. Uses the same per-iteration scope machinery `loop`/
`countloop` already had before this milestone (`core::env::child`/
`core::interp::enterScope` per iteration at the interpreter, a fresh
`OpenScope` per Tcl `foreach`/`for` iteration in the compile backend, and
native's own per-iteration `EnterScope` in `ListLoop`) — nothing new was
needed for freshness itself.

## Closure-per-iteration semantics

Closures created in different iterations capture that iteration's own
value, never one shared mutable slot (`loop-in-closure-per-iteration`,
new): `fs = loop x in [1, 2, 3]: fn f(): x \n f`, then `loop g in fs: g()`
yields `[1, 2, 3]`, not `[3, 3, 3]` — proved by actually *calling* the
closures (not merely inspecting them), across all four backends
(`loop-in-closure-per-iteration-parity`). This test exercises the native
backend's own per-iteration closure-capture path (each iteration's `x`
becomes its own captured cell, exactly like a plain `loop`'s own body
would), also run under `BOTLISH_NATIVE_GC_STRESS=1` (see "GC/rooting"
below) since a closure captured on one iteration must stay valid and
correct after the loop's own iteration scope is released and possibly
collected.

## HIR/core representation

Unchanged: core IR `(listloop LIST-EXPR ELEMENT-BLOCK)`, HIR `listloop`
node with `iterable`/`elementBinding`/`bodyScope`/`body` fields (see
"Prior loop architecture"). No synthetic callback boundary was ever
introduced or considered: `native::lower::ListLoop` lowers straight to a
CFG loop, never to a `list_map(xs, closure(body))`-shaped call (item 69's
stop condition never came close to triggering).

## Interpreter lowering

One-line change to `core/evaluator.tcl`'s `op-listloop`: the `break` case
now returns `[core::completion::normal [core::value::listOf $results]]`
(the prefix already accumulated) instead of the break completion's own
payload. Since HIR guarantees a listloop-targeted break is always bare, a
break's payload is simply never consulted here even for a hand-written raw
core-IR program that violates that invariant (`core::eval` operates below
HIR and has no diagnostic of its own to give) — bare and "valued" break
behave identically at this layer, both ending the loop with the prefix.

## Tcl compile lowering

`compiler/compiler.tcl`'s `CompileListLoop`/`CompileLoop`/`CompileCountLoop`
now register `[list $result $acc]` (not a bare `$result`) in `ctx loops`;
the shared `break` case checks for a non-empty accumulator to tell a
listloop target apart from a plain `loop`/`countloop` target, and when
present sets `$result` to `core::value::listOf $acc` (the prefix) instead
of the break's own payload. `continue` was already a plain Tcl `continue`
and needed no change.

**Chosen strategy: kept the manual foreach+accumulator shape, did not
switch to a literal Tcl `lmap`.** Item 24 suggests preferring genuine Tcl
`lmap` when it "gives the correct compile-backend semantics cleanly" — and
semantically it would: Tcl's own `lmap` already treats `break` as "return
the collected prefix" and `continue` as "skip", a precise match for the
redefined semantics. This was evaluated and set aside: `CompileListLoop`'s
existing per-iteration scope machinery (materialized vs. box-local
bindings, `OpenScope`/`DeclareScope`) is written against an ordinary Tcl
statement-script body, and folding it into an `lmap` body (whose last
*expression* value, not a `set` statement, is what gets collected) would
have required reshaping that machinery for a low-risk, already-correct,
already-fully-tested construct, for a benefit that is real but purely
about generated Tcl code quality, not new capability. This is recorded as
evidence per item 55 ("the compiler should eventually learn to erase
unnecessary abstraction... do not source-optimize around it" — read here
as: do not backend-rewrite around it either, absent a concrete need), not
adopted. The Tcl backend also does not implement the discarded-result
optimization (see "Discarded-result path" below) for the same
risk/reward reason — item 20's hard requirement is scoped to "the native
compiler"; item 24's own Tcl-backend language is the softer "may be
preferable".

## Native CFG lowering

`native/lower.tcl`'s `ListLoop` already lowered directly to a real CFG
loop (see "Prior loop architecture"); this milestone's changes are the
`break`/discarded-result pieces:

- **`break`'s own lowering** (`native::lower::Expr`'s `break` case): the
  loop registration `dict set fn loops $e [list $continueLabel $exit
  $resultReg accReg]` grew a fourth element, the listloop's own
  accumulator register (`""` for a plain `loop`/`countloop`, unchanged).
  `break`'s shared lowering checks that field: non-empty means a listloop
  target, and it moves the accumulator (the prefix) into `$resultReg`
  instead of evaluating and moving the break's own value (which HIR
  guarantees is never present for a listloop target, so nothing is
  evaluated there at all).
- **`continue`'s own lowering** is unchanged: jumps straight to
  `$continueLabel`, which only advances the index and loops back, never
  re-running the accumulation step (pre-existing).
- Both share the exact same rooting the pre-existing normal-exit path
  already required (the accumulator register was already live across the
  whole loop, including every back edge, before this milestone) — no new
  rooting mechanism was needed for `break` to also read it.

## Retained-result builder path

Unchanged in shape from before this milestone: `listnew` once, `listappend`
once per contributed element, `listget`/`listlen` for traversal — one
logical output collection, matching item 14's semantic goal directly (see
"Allocation census" for why this is *not* one physical allocation at the
runtime level, a pre-existing, unrelated characteristic of `listappend`
itself).

## Discarded-result path

**New in this milestone**, native backend only. `ListLoop` now computes
`retained = ![dict exists $context discarded $e]` — reusing
`hir::aot::context`'s own pre-existing `discarded` fact (`hir/aot.tcl`:
"all but the last of a sequence", already used elsewhere in
`native/lower.tcl`, e.g. `Bind`'s envless-function check) rather than
inventing a new liveness analysis. When `retained` is false:

- No `listnew`/`listappend` is ever emitted — direct traversal only
  (`listlen`/`listget` still run, exactly once per visited element, for
  the body's own side effects).
- `$resultReg` (never read by anything, by construction of "discarded") is
  filled with a `unit` placeholder on both the normal-exit and break
  paths, matching a discarded countloop's own natural-exhaustion value.
- `break`'s own accumulator slot is set to the sentinel `"discard"`
  (distinguishable from both a real register and a plain loop/countloop's
  `""`), so the shared `break` case knows there is no real accumulator to
  move, and moves the same `unit` placeholder instead.

Confirmed structurally (`tests/native-listloop.test`): a discarded
listloop's own generated NIR contains no `listappend` instruction at all —
regardless of whether a `break` is reachable inside it
(`native-listloop-discarded-no-list`, `native-listloop-discarded-break-no-
output-list`) — while still containing `listlen`/`listget`
(`native-listloop-discarded-still-traverses`).

## Cardinality facts

**New module**, `hir/cardinality.tcl`, per items 15-19/51-52's own explicit
"a narrowly scoped metadata representation is preferable to a general
theorem engine" scoping — this is not a relational fact system, and
deliberately independent of `hir/range.tcl`'s own per-specialization-
instance argument-fact machinery, which this needs none of.

`hir::cardinality::analyze $hir` returns, for every listloop, `exact` (no
break/continue targeting it is reachable in its own body — output length
==input length on every normal completion) or `max` (a break or continue
targeting it is reachable — output length <= input length). This depends
on exactly one already-resolved fact: `hir/resolve.tcl`'s own `target`
field on every break/continue node, resolved once, purely syntactically,
independent of reachability/types — so a nested loop's own break/continue
(targeting the *inner* loop) correctly never downgrades an outer listloop's
own fact. No path-sensitive counting is attempted (item 20 as it applies
to this fact module): a break/continue on a statically-dead path still
downgrades exact to max, mirroring `hir::aot::context`'s own similarly
syntactic-not-path-sensitive `discarded` fact.

Verified directly: a listloop with neither break nor continue reachable is
`exact`; one with a reachable `continue` is `max`; one with a reachable
bare `break` is `max` — matching items 15/16/19 precisely (script probe,
see "Full regression" section for the automated pin in
`tests/hir-*` coverage this module's own procs receive incidentally via
`hir/hir.tcl`'s load list).

## Element type

Simplified, `hir/types.tcl`'s `listloop` case: always exactly
`MakeList(bodyType)` — no longer joined (`lub`) against `ctx breakTypes`.
Before this milestone, a listloop's own result type had to account for
every reachable `break VALUE`'s own payload type, widening to `any` when
incompatible with the body's own `List[R]`. Since `break VALUE` is now
rejected outright at `hir/resolve.tcl` for a listloop target, no valid
program ever reaches `hir/types.tcl` with a break payload type to
reconcile, so the join was removed rather than kept as now-dead code:
`loop-in-break-still-precise-type` pins that a listloop with a reachable
*bare* break keeps its exact `List[int]` typing (not merely "not `any`"),
directly exercising the simplified path. `continue`/`return`/error remain
excluded from element typing, unchanged.

## Allocation census

Focused native cases, `byKind List allocations` from `native::
allocationReport`, plus generated-NIR instruction occurrences
(`native::nir`):

| Case | List allocations | `listnew` | `listappend` | `callvalue` |
|---|---|---|---|---|
| Retained, exact-length transform (`x + 1` over `[1, 2, 3]`) | 5 | 2 | 1 | 0 |
| Retained, continue-shaped (skip `x==2` over `[1, 2, 3, 4]`) | 5 | 2 | 1 | 0 |
| Retained, break-shaped (break at `x==3` over `[1, 2, 3, 4]`) | 4 | 2 | 1 | 0 |
| Discarded traversal (same transform, result unused) | 1 | 1 | 0 | 0 |
| `list::any?([1, 3, 4], is_even)` | 1 | 1 | 0 | 1 |
| `list::all?([2, 4, 6], is_even)` | 1 | 1 | 0 | 1 |
| `list::none?([1, 3, 5], is_even)` | 1 | 1 | 0 | 1 |
| `list::find([5, 6, 7], is_even)` (successful) | 1 | 1 | 0 | 1 |
| `list::find([1, 3, 5], is_even)` (unsuccessful) | n/a* | 1 | 0 | 1 |

\* The unsuccessful `find` case genuinely raises `NotFound`, so running it
to completion for a runtime allocation report just raises that same error;
confirmed structurally instead (`native-listloop-find-no-output-list-
failing`): no `listappend` anywhere in its generated program, matching the
successful case's own zero.

Every retained case's single `listnew` beyond the loop's own accumulator
is the iterable *literal*'s own construction (`[1, 2, 3]` etc., `Const`'s
list case — one variadic `listnew` call, unrelated to the loop); every
discarded/helper case's lone allocation is that same input-literal
construction, with **zero** additional List allocations caused by the
loop's own returning-loop semantics — confirming items 39-40's required
"no" answer for all four helpers, and the general discarded-loop case
(`side_effect(x)`-shaped) alike. The retained cases are not "1 output
List" at the allocation level, only at the semantic level — see "Known
optimization deficits" for why (pre-existing `listappend` copy-on-append
behavior, unrelated to this milestone).

## GC/rooting

Focused `BOTLISH_NATIVE_GC_STRESS=1` runs (forces a GC attempt at every
allocation site), each in isolation:

```
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/loop-in.test          33/33 passing
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/list-stdlib.test      24/24 passing
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/native-listloop.test  12/12 passing
```

`tests/loop-in.test` covers a returning loop producing managed values (the
List/String cases throughout), the closure-per-iteration tests (managed
Block values captured and called back after their own iteration scope is
released — the case most likely to expose a stack-walking/rooting bug if
the accumulator register or a captured cell were not correctly tracked
across the loop's own back edge), and the nested-loop cases (List-of-List
results). `tests/list-stdlib.test` and `tests/native-listloop.test`
between them cover a discarded loop whose body allocates (`predicate(x)`'s
own call frame, `mod`'s own boxed Int result) with the loop's own
accumulator register never live at all. No rooting or allocation-behavior
regression was observed in any of the three, run individually (matching
LISTLOOP-BREAK-TYPE-SOUNDNESS.md's own prior note that a full-suite
concurrent GC-stress run can produce spurious, CPU-contention-caused
failures in unrelated exhaustive tests — avoided here by running each
focused file alone). No repository-wide local GC-stress run was performed;
CI's own `gc-stress` job on `main` owns that, per AGENTS.md.

## Interpreter/compile/cranelift/cranelift-generic parity

All new semantic tests (`tests/loop-in.test`'s rewritten break section,
the new closure-per-iteration tests, `tests/list-stdlib.test`'s parity
tests) are parity-checked across all four backends via the existing
`loopParity`/`listlibParity` helpers. No discrepancy was found on any of
them.

## `list::any?`/`all?`/`none?`/`find`

`lib/list.bot`, a new stdlib module (`namespace list`), ordinary Botlish —
none implemented as natives (item 39). Each is built directly on `loop x
in xs:`, using only `return`/`fail` for short-circuiting; none of the
four's own loop result is ever read.

```
fn any?(xs, predicate) -> bool:
    loop x in xs:
        if predicate(x):
            return true
    false

fn all?(xs, predicate) -> bool:
    loop x in xs:
        if not predicate(x):
            return false
    true

fn none?(xs, predicate) -> bool:
    loop x in xs:
        if predicate(x):
            return false
    true

fn find(xs, predicate) errors NotFound:
    loop x in xs:
        if predicate(x):
            return x
    fail NotFound
```

**No `continue` appears in any of the four** (a deliberate simplification
of the milestone's own "approximate" idiom text, items 40-43, which does
include one): since every one of these four functions always discards its
own listloop's collected List (each short-circuits via `return`/`fail`,
and the exhaustion path falls through to a separate `true`/`false`/`fail`
statement after the loop, never the loop's own value), whether a skipped
iteration's `if`-with-no-`else` contributes `unit` or `continue` skips it
entirely is unobservable — both produce a List that is thrown away either
way. Confirmed directly: with `continue` removed, every one of
`tests/list-stdlib.test`'s 24 cases (correctness, empty-List edges,
short-circuiting via a poison trailing element, a native predicate, and
four-way parity) still passes unchanged, and the native discarded-result
optimization still applies identically (`tests/native-listloop.test`'s
`list::any?`/`all?`/`none?`/`find` allocation pins are unaffected by the
presence or absence of `continue`, since `hir::aot::context`'s own
`discarded` fact is purely about statement position, independent of a
loop body's own control flow).

`error NotFound` is the checked absence convention `find` uses (item 63):
no existing generic/List "not found" error existed in this codebase to
reuse, so this is the smallest new one, following exactly `lib/byte.bot`'s
own `error BelowRange`/`AboveRange` convention (a bare, undecorated
PascalCase error name, declared in the same namespace). An empty `xs` and
a nonempty `xs` with no match both fail identically
(`list-find-empty-fails`, `list-find-no-match-fails`).

### Required stdlib answers (items 75)

24. Written in Botlish: yes.
25. `any?([])`: `false`.
26. `all?([])`: `true`.
27. `none?([])`: `true`.
28. `find([], predicate)`: the same checked `NotFound` failure as any other
    no-match case.
29. All four short-circuit: yes, proved by a "poison" trailing element
    whose predicate application would itself raise a runtime error if ever
    reached (`mod` of a non-Int) — the poison element is never reached in
    any of the four's own short-circuit tests.
30. Predicate invocation left-to-right, once per visited element: yes,
    inherited directly from the listloop's own left-to-right, exactly-once
    -per-element evaluation order — no additional invocation-order
    machinery of these helpers' own.

## Higher-order `callvalue` census (items 48, 76)

31. `predicate(x)` in each of the four helpers lowers to `callvalue`: yes
    — `predicate` is an untyped parameter, so every call through it is an
    ordinary dynamic call, exactly like `lib/web.bot`'s pre-existing
    `scan_while`'s own `predicate(char_at(i))`. No special-casing.
32. New static `callvalue` sites: exactly 4 — one `predicate(x)` call site
    per helper (`any?`, `all?`, `none?`, `find`), each a single static call
    expression in its own function body.
33. `InstanceClosed` (or any devirtualization): none of the four is
    `InstanceClosed` at its own `predicate(x)` call site — the parameter's
    own target is never statically known there, exactly as expected for an
    untyped higher-order parameter.
34. Predicate targets exact at the caller but lost at the helper
    parameter: yes, by construction, at every one of `tests/list-stdlib.
    test`'s call sites — `is_even` (an ordinary Botlish function) and
    `is_tcl_alpha` (a native) are both statically exact, nameable targets
    at their own call sites (`list::any?([...], is_even)`), but that
    exactness is not threaded through `any?`'s own `predicate` parameter:
    inside `any?`'s body, `predicate(x)` sees only "some untyped
    callable", not "exactly `is_even`".
35. Any helper unexpectedly devirtualizing already: no.

No optimization of any of this was attempted (items 47, 81) — this census
is deliberately left as the honest baseline the next milestone's
higher-order/callable-provenance work is meant to build on, exactly as
`web::emailish?`'s own `scan_while` predicate call was left untouched
(item 60; unmodified this milestone, confirmed unchanged below).

## Canonical performance controls

`fib`, `loop-count`, `sum-refined`, `refined-checks`, and
`web::emailish?`'s own `scan_while` remain untouched by every change in
this milestone: the interpreter change is a one-line swap inside
`op-listloop`'s own `break` case (not reached by any of these workloads,
none of which use a listloop `break` at all); the Tcl-backend change is
confined to `CompileListLoop`/`CompileLoop`/`CompileCountLoop`'s own
`break`-registration bookkeeping; the native-backend changes are confined
to `ListLoop`'s own discarded/retained branch and `break`'s own lowering
case, gated on HIR facts (`discarded`, a break's own `target` node kind)
these controls' own generated NIR never triggers, since none of them
contains a `loop x in ...:` at all. No regeneration of these controls'
own generated-code artifacts was therefore needed or performed; their
existing `bench/`/`audit/` baselines remain the correct comparison point.

## Full regression

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
```

Run across `interp` and `compile` backends (the harness's own default),
plus `cranelift`/`cranelift-generic` wherever `stdlib.test`/`native.test`/
the new `tests/list-stdlib.test`/`tests/native-listloop.test` exercise
them via `outcomeUnder`/`moduleParity`-style helpers.

- Pre-existing suite (87 test files, before this milestone's two new test
  files were added), both `interp` and `compile`: **2562/2562 passing, 0
  failed**, confirming zero regressions in every already-shipped
  construct — counted loops (`tests/loop-counted.test`, `tests/loops.
  test`) unaffected, every backend-parity suite unaffected.
- `tests/loop-in.test` (rewritten break section, closure-per-iteration
  tests added): **33/33 passing**, all four backends agreeing on every
  parity case, native (`cranelift`) included.
- `tests/list-stdlib.test` (new): **24/24 passing** — correctness, empty-
  List edges, short-circuit-via-poison-element, a native predicate
  (`is_tcl_alpha`) alongside an ordinary Botlish one, and four-way parity
  for `any?`/`all?`/`none?`/`find`.
- `tests/native-listloop.test` (new): **12/12 passing** — retained-vs-
  discarded NIR structure, the retained-path allocation-shape census,
  break's own allocation shape, and the four stdlib helpers' own zero-
  output-List allocation pins.
- `tests/hir-cardinality.test` (new): **7/7 passing** — exact-vs-max for
  no-break/no-continue, continue-reachable, break-reachable, both
  reachable, a nested inner break not downgrading the outer loop's own
  fact, `return` not weakening exact, and `analyze` covering every
  listloop in a program.

Combined full-suite run, both backends, all 90 test files (87 pre-existing
+ the 3 new ones above), `LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl`:

```
all.tcl:  Total 2607  Passed 2607  Skipped 0  Failed 0
Sourced 90 Test Files.
```

**2607/2607 passing, 0 failed**, on both `interp` and `compile` (exit code
0 for the whole two-backend run). Exactly 2562 (the pre-existing baseline)
+ 45 new (loop-in.test's own growth from 31 to 33, plus 24 + 12 + 7 from
the three new files) = 2607.

## Known optimization deficits

- **Retained listloop List construction is O(n) physical allocations, not
  the "one logical output collection" item 14 describes as a semantic
  goal**: an empty accumulator (`listnew`, one allocation) plus one
  copying `listappend` per contributed element (`rt_list_append`'s own
  pre-existing copy-on-append behavior, unrelated to and unchanged by this
  milestone — `tests/native-alloc.test`'s own prior "list_append copies
  the existing elements" pin already documented this). For a 3-element
  fully-retained transform: 1 (input List) + 1 (empty accumulator) + 3
  (one append per element) = 5 List allocations total. Recorded as
  compiler evidence (item 55), not fixed here. *Since fixed*: the
  accumulator is now a private List plan materialized once
  (COLLECTING-LOOPS.md, "Native result List"): 1 (input) + 1 (empty
  accumulator) + 1 (materialization) = 3 Lists and 1 ListPlan, whatever
  the element count; the allocation tables above record the original
  lowering.
- **The Tcl compile backend does not implement the discarded-result
  optimization.** `list::any?`/`all?`/`none?`/`find` (and any other
  discarded listloop) still build and discard a real Tcl-level
  accumulator List under the `compile` backend — only the native backend
  elides it. See "Tcl compile lowering" above for the reasoning (item 20's
  hard requirement is native-only; item 24's Tcl-backend language is
  advisory).
- **The Tcl compile backend does not use a literal `lmap`**, despite item
  24's suggestion that it would fit these semantics cleanly — see "Tcl
  compile lowering" above.
- **`web::emailish?`'s own `scan_while` `callvalue` remains untouched, as
  required** (item 60) — not a deficit, confirmed here for completeness.

## Readiness for real-world callable harnesses

The language primitive (`loop x in xs:`, with its redefined `break`) and
the four stdlib helpers are in place, tested across all four backends, and
deliberately unoptimized at their own `predicate(x)`/`callvalue` call
sites — exactly the honest, unforced baseline the next milestone's
higher-order/callable-provenance work (test selection, compiler-pass
lists, returned matcher closures) needs to build on. The cardinality-fact
module (`hir/cardinality.tcl`) and the discarded-result native lowering
are both structured to extend cleanly to a future multi-input lockstep
form (`loop x in xs and y in ys:`, explicitly out of scope here, item 65)
without requiring rework: neither depends on there being exactly one
input binding.
