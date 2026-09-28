# R2.a.3: counted loops + final `emailish?` source normalization

**Partially superseded by PAYLOAD-FREE-BREAK.md.** This report documents
`break VALUE` as part of a counted loop's "final" design, overriding the
loop's own result exactly like a bare `loop:`'s own established semantics.
PAYLOAD-FREE-BREAK.md later removes that surface-language capability
outright: `break` never takes a value, in any loop kind, including a
counted loop -- rejected at the surface parser itself, a plain syntax
error, not merely re-derived as unsound. Everything else this report
documents about counted loops (ascending, exclusive-end, unit-step,
arbitrary-precision Int, natural exhaustion producing `unit`, nested-loop
targeting, per-iteration closure capture, backend parity) is unaffected
and remains current. Read every mention of `break VALUE`/`break i * 100`-
shaped examples below as the historical record of a design later replaced;
see PAYLOAD-FREE-BREAK.md for the current rule and for why the raw core-IR
level (below the surface parser) deliberately keeps the old override
semantics alive as a "two-tier" design, preserving this report's own
`bench/loop-count.ir` example and the `NATIVE-AUDIT.md`/asm-comparison
trail unchanged.

## Outcome

**Achieved.** `loop i from START to END:` — ascending, unit-step,
exclusive-end, over arbitrary-precision `Int` — is a new counted-loop
construct, implemented as a genuine semantic control-flow node through
every stage of the pipeline (surface parser → HIR → core IR → interpreter
/ Tcl compiler / native NIR+Cranelift), never as a synthetic recursive
function. `web::emailish?`'s `scan_while` and `domain_loop` — the last two
self-tail-recursive helpers left over from before this construct
existed — are rewritten around it: `scan_while` directly, `domain?`
(replacing `domain_loop`, which no longer exists) from the domain
grammar's own structure rather than by mechanically translating the old
recursive cursor-jump shape. Every local predicate helper now uses the
trailing-`?` idiom (`local_char?`, `label_char?`, `tld?`, `domain?`).
Exact `Emailish` semantics are unchanged, confirmed both by the existing
corpus and a fresh domain-edge corpus, and by direct differential testing
against the pre-R2.a.3 implementation. Full regression:
**2544/2544 passed**, 86 test files (62 of them new, in
`tests/loop-counted.test`), no skips, on `interp`+`compile`. A focused
native GC-stress test for the new construct's own CFG backedge
(`tests/native-root-liveness.test`'s `root-loop-carried-counted-1`) passes
under `BOTLISH_NATIVE_GC_STRESS=1`. `web::emailish?`'s own source is now
**frozen** (see "Final source freeze" below).

No compiler-optimization code was written or modified to make this source
possible: every range/allocation/instance change reported below is a
*measured consequence* of writing idiomatic source over an already-general
mechanism (the same `+`/`<` NIR ops, the same generic backward-liveness
fixpoint, the same specialization/blockescape machinery), never a change
to that machinery's own policy.

## Why counted loops were added before freeze

`scan_while` and (before this milestone) `domain_loop` encoded ordinary
forward numeric traversal as self-tail recursion, because Botlish had no
direct counted-loop syntax: bare `loop:` re-runs its body with no way to
carry an advanced position between iterations except mutation, and
`loop x in EXPR:` needs an already-materialized collection, not a range of
character positions. `loop i from START to END:` is the smallest
construct that lets this traversal be written directly, so R2.a.3 adds it
and then performs the source normalization the earlier R2.a milestones
explicitly deferred (see R2A1-MODULE-FN-BRIDGE-REACHABILITY.md and
R2A2-TRAILING-QUESTION-IDENTIFIERS.md's own "next step" notes).

## Existing loop architecture (before this milestone)

- Surface: `surface/parser.tcl`'s `Loop` production, grammar
  `"loop" [ IDENT "in" expression ] ":" suite`. `in` is recognized
  *contextually* (one token of lookahead after the loop variable's own
  name), never a lexer keyword — the established precedent (shared with
  `type X = Int in 0..10`'s own domain `in`).
- Core IR: `(loop BODY-BLOCK)` and `(listloop LIST-EXPR ELEMENT-BLOCK)`
  (`core/ir.tcl`). `listloop`'s `ELEMENT-BLOCK` is a `(block (ELEM)
  BODY...)` — lexically inline (not a callable boundary), one parameter.
- Completions: five kinds only (`core/completion.tcl`) —
  `value`/`return`/`break`/`continue`/`propagate-error` — threaded through
  every construct uniformly; a loop's own handler is just a `switch` on
  completion kind.
- HIR: `loop`/`listloop` expr kinds, a `loop`-kind scope for the iteration,
  `break`/`continue` targets resolved via a `ctx loop` field carrying the
  enclosing loop's own ExprId.
- Native lowering: `listloop` already showed the exact backedge shape to
  reuse — a loop-carried register (the "multi-definition-site register"
  pattern already used for `if`'s own join register) rebound via `move` at
  a `continueLabel`, with `dict set fn loops $e [list $continueLabel $exit
  $resultReg]` making the *already-generic* `break`/`continue` lowering
  work with no change.

## Chosen source grammar

```
loop IDENT from expression to expression : suite
```

`from`/`to` are recognized exactly the way `in` already is: one token of
lookahead immediately after the loop variable's name dispatches to the
`in` form, the `from` form, or (see below) the reserved `down` form;
neither is a lexer keyword, so both remain ordinary identifiers everywhere
else in the language (pinned:
`loop-counted-from-usable-as-identifier`/`-from-as-plain-name`,
`tests/loop-counted.test`). `through`/`by` are recognized the same
contextual way, immediately after the counted form's start/end
expressions, and rejected with a "reserved, not implemented yet"
diagnostic. No global keyword-table change (`surface/lexer.tcl` is
untouched).

The one AST-node design choice: `loop`'s existing surface node kind is
*extended* with four new optional fields (`countName`, `countNameSpan`,
`countStart`, `countEnd`), mirroring the codebase's own existing precedent
of a bare `loop:` and a `loop x in EXPR:` sharing one node kind
distinguished by which fields are set — not a new AST node kind. The same
choice is made at HIR (a new `countloop` expr kind, parallel to but
distinct from `listloop`, since their value/completion semantics
genuinely differ — see item 8 below) and core IR (`(countloop START-EXPR
END-EXPR ELEMENT-BLOCK)`, the direct three-argument generalization of
`(listloop LIST-EXPR ELEMENT-BLOCK)`).

## Reserved future grammar

- `loop i down from HIGH to LOW:` (descending) — `down` immediately after
  the loop variable produces a "reserved for a future counted-loop form"
  diagnostic. Not implemented.
- `loop i from LOW through HIGH:` (inclusive end) — `through` immediately
  after the start expression produces the same kind of diagnostic. Not
  implemented; `to` is always exclusive.
- `loop i from LOW to HIGH by STEP:` (explicit stride) — `by` immediately
  after the end expression produces the same kind of diagnostic. Not
  implemented; a counted loop always steps by exactly 1.
- `loop x in xs and y in ys:` (proof-checked lockstep iteration) — `and`
  is already a global keyword (the boolean operator), so this milestone
  reserves no *new* token for it; the intended future meaning (compiler-
  proven equal iteration count, no runtime mismatch/truncation/padding
  handling) is documented here and in the grammar comment, but nothing is
  implemented. Writing this form today does not silently parse as
  something else: `xs and y` parses as an ordinary boolean expression (an
  operand of `and` cannot itself contain a bare `in`), and the parser then
  fails expecting `:` — a generic but not misleading diagnostic.

No existing source identifier was broken by any of this: `from`, `to`,
`down`, `through`, `by` all remain valid ordinary names (pinned in
`tests/loop-counted.test`); `and`/`or`/`not` were already reserved before
this milestone.

## Semantic definition

`loop i from start to end: body` evaluates `start` then `end`, exactly
once each, left to right, in the enclosing scope. `i` is bound, fresh and
immutable, to `start`, `start+1`, ..., stopping (without running `body`)
the first time `i` would equal or exceed `end`. `start >= end` runs the
body zero times. Reaching `end` without a `break` completes normally with
`unit`, never a collected List — `body`'s own value is *discarded* each
iteration (procedural, not collecting), the deliberate distinction from
`loop x in EXPR:`. `break`/`continue`/`return`/errors compose exactly as
they already do for bare `loop`/`listloop` (same five-kind completion
machinery, same lexical-target resolution) — no special-casing anywhere.

## Int/error semantics

`start`/`end` must be `Int`, checked the same dynamic way every other Int
operation is (`core::value::expect`/`RequireKind`/`EmitArgGuards` per
backend — the exact same mechanism `+`/`<`/listloop's own iterable check
already use), never a new loop-only error kind. A statically-provable-Int
bound skips the check entirely (ordinary type-directed intrinsic
compilation, unchanged machinery). The induction variable is
arbitrary-precision `Int`, never native `i64`: see "Large-Int correctness"
below.

## Binding/scope semantics

- `i` gets an ordinary `BindingId`/`ScopeId`, `kind param`, in a `loop`-
  kind iteration scope — the identical convention `listloop`'s own element
  binding already uses (`hir/resolve.tcl`'s `countloop` case mirrors its
  `listloop` case exactly, `NewBinding ... param $iteration ...`).
- `i` is *not* in scope in `start`/`end` (both resolved in the enclosing
  `ctx`, before the iteration scope exists) — pinned
  (`loop-counted-i-not-in-bounds-hir`).
- `i` does not escape after the loop — pinned
  (`loop-counted-i-not-after-loop`).
- Ordinary shadowing rules apply to `i` in a nested scope — pinned
  (`loop-counted-shadowing`).
- A closure capturing `i` captures that iteration's own immutable value,
  confirmed end to end on every backend including native, where `i`'s own
  register *is* the loop-carried register mutated across the backedge —
  correct because Cranelift's own SSA construction over `def_var`/`use_var`
  gives each capture site the value valid at that specific program point,
  not a live reference to a later-mutated cell (pinned:
  `loop-counted-closure-captures-per-iteration`/`-parity`, all four
  backends agree).

## Completion semantics

Natural exhaustion: `unit`. Normal body completion: discarded (not
collected). `continue`: skip the rest of the body, advance to `i+1` (never
re-run the current `i`, never skip an extra one — pinned:
`loop-counted-continue-sequence`, `-continue-count` via `test-log`
side-effect observation, `-end-exclusive-under-continue`). `break`/`break
VALUE`: ends the loop immediately with that value (or `unit`) as the whole
loop's own result — reuses the *same* completion/backedge machinery
`break` already had, no special-casing (spec-required; confirmed by
`grep`: `native/lower.tcl`'s `Expr`'s `break`/`continue` cases needed zero
changes). `return`: returns from the lexically enclosing function, not
some hidden loop-internal function — pinned
(`loop-counted-return-propagates`/`-parity`). Errors propagate exactly as
they already do through `loop`/`listloop` — pinned
(`loop-counted-error-propagates`/`-parity`).

## HIR/core representation

Core IR: `(countloop START-EXPR END-EXPR ELEMENT-BLOCK)`, `ELEMENT-BLOCK`
a `(block (I) BODY...)` — the direct three-argument generalization of
`listloop`'s own shape (`core/ir.tcl`'s `CheckElementBlock` is reused
unchanged). HIR: a `countloop` expr kind (`start`, `end`, `countBinding`,
`bodyScope`, `body`) — a `loop`-kind scope, exactly `listloop`'s own
representation choice, so every existing pass that already treats a
`loop`-kind scope generically (`hir::aot::InLoopOf`'s self-tail exclusion,
in particular) needed **zero** changes to already do the right thing for
`countloop` too.

## Why no synthetic recursive function

Verified directly, not merely by construction: `hir::specialize::analyze`
on a function containing a `countloop` shows exactly the function's own
used instance in the `used` set — no `hidden_loop_function` or similar
(pinned: `loop-counted-no-extra-instance`). `hir::children` (the generic
HIR traversal every specialization/capture/StringRegion pass builds on)
walks a `countloop`'s `start`/`end`/`body` directly, with no synthetic
call node anywhere in between. The scope kind is `loop`, not `block`, so
it is never a materialized closure/`Block` value (pinned:
`loop-counted-no-materialized-block`) and is invisible to
`hir::aot::materializedBlocks`/`hir::blockescape::analyze` by construction
(neither one enumerates `loop`-kind scopes as closures at all — they only
ever look at `block` expr kinds).

## Interpreter lowering

`core/evaluator.tcl`'s `op-countloop`: evaluates `start`/`end` once
(ordinary `core::interp::evalIn`), then a Tcl `while {$i < $end} { ... }`
over the *same* five-kind completion `switch` every other loop form uses —
`value`/`continue` advance, `break` returns `core::completion::normal`
with its payload, `return`/`propagate-error` pass through unchanged. `i`
advances with `set i [expr {$i + 1}]`, **never Tcl's `incr`**: AGENTS.md
documents a confirmed Tcl-core bug where `incr` inside a compiled proc
silently wraps at the i64 boundary instead of promoting to a bignum, and
this loop must stay correct for an `Int` of any magnitude —
`core/primitives.tcl`'s own `add`/`less` already use exactly this
`expr`-only idiom, so `op-countloop` matches established house style, not
an ad hoc precaution.

## Compile (Tcl) lowering

`compiler/compiler.tcl`'s `CompileCountLoop`: `start`/`end` compile via
`CountBoundWord` (a `core::value::expect` runtime check when not already
statically `int`, mirroring `RequireKind`'s own per-argument check, minus
its "defer to a generic call" escape hatch, which a countloop has no use
for). Iteration compiles to Tcl's own `for {} {$i < $end} {set i [expr
{$i + 1}]} { BODY }` — **`for`, not `while`**: this is the one place this
milestone's design differs in kind from a naive port of `CompileListLoop`.
Tcl's `continue` inside `for`'s body runs the `for`'s own *next* script
(the induction advance) before re-testing; inside `while`'s body it would
skip straight to the condition, skipping any body-trailing increment
entirely — silently breaking `continue`'s own "advance to i+1" semantics.
This was caught by writing a smoke test for `continue` and finding it
would loop forever with `while`, before it ever reached the committed
test suite.

## Native/NIR lowering

`native/lower.tcl`'s `CountLoop` (dispatched from `Expr`'s `countloop`
case): the same real CFG backedge `ListLoop` already uses — `jump`/`label`
blocks, a loop-carried register (`idxReg`) rebound via `move` at a
`continueLabel`, `dict set fn loops $e [list $continueLabel $exit
$resultReg]` making the *already-generic* `break`/`continue` NIR lowering
work unmodified. Simpler than `ListLoop` in two ways: no list to index
(`start`/`end` drive `op ilt`/`op iadd` directly — the *same* general NIR
ops an ordinary `<`/`+` call already lowers to, not a list-length-specific
operation), and no accumulator (`i` itself *is* the one loop-carried
register; an ordinary body completion is simply discarded, never
appended). `EmitArgGuards`'s own int-kind check on `start`/`end` is fed by
`hir/aot.tcl`'s new `Require` call for this node (see below) — without
that, native lowering would hit a hard `{NATIVE BUG}` the first time a
dynamically-typed bound reached it, confirmed by reading `EmitArgGuards`'s
own contract before adding the `Require` call, not after debugging a
crash.

### Focused excerpt

```
fn f(n):
    loop i from 0 to n:
        n
```

HIR/core: `(countloop (const int 0) (ref n) (block (i) (ref n)))`.

NIR (`native::nir`, abbreviated):
```
func 1 "f" params=1 ...
    %1 = int 0
  label L0
    jump L0                 ; preheader -> header
  label L0
    %2 = op ilt %0(idx) %n
    br %2 L1 L2
  label L1                  ; body
    ... (n) ...
    jump L3                 ; -> continueLabel
  label L3                  ; continue: advance
    %3 = op iadd %0 1
    %0 = move %3
    jump L0
  label L2                  ; normal exit
    %4 = unit
    %result = move %4
    jump L5
  label L5
    ret %result
end
```
(labels renumbered for legibility; the real dump is in the report's own
generation logs). No `call`/`tail`/`callenv` represents the backedge
anywhere — confirmed directly against the compiled `bench/refined-checks.ir`
NIR text: `web::emailish?`'s own `scan_while`/`domain?` bodies contain
`jump`/`label`/`br` for their counted loops and zero `tail`/`tailenv`
lines (down from 2 self-tail `tail` sites before this milestone — see
"Machine/NIR census").

## Range-analysis support

`hir/range.tcl`'s `countloop` case (the one file this milestone was
explicitly permitted to extend) seeds the induction binding directly from
`start <= i < end`: `min` = `start`'s own Range minimum (`-inf` if
unknown), `max` = `end`'s own Range maximum minus one (`+inf` if
unknown) — ordinary interval arithmetic on an already-computed Range,
intersected with `TypeFact int`, never a new relational solver. Confirmed
non-trivial on real source: in `web::emailish?`, both `scan_while`'s `i`
and `domain?`'s `j` get `max` bounded by `length(v)`'s own
`collectionLength` fact (`smallMax`, i.e. `4611686018427387902` = that
bound minus one) — a real, useful fact the old recursive `scan_while` had
no equivalent binding to attach to at all. `min` stays unbounded for both
(`-inf`): each is a `<generic>` instance reached from more than one call
site with different `start` arguments (a literal `0` and an unconstrained
parameter), and the Range lattice's own join across call sites is
correctly conservative there — not a regression, the same conservativeness
`check.n`'s own R2.a.1 finding already documents for generic-instance
capture.

## Large-Int correctness

Pinned directly: `loop-counted-large-int-boundary`/`-parity` crosses
`4611686018427387903` (the tagged-small-Int boundary, `smallMax`) with a
two-iteration loop and checks both values land correctly on every
backend; `loop-counted-large-int-sum`/`-parity` sums a range starting
*beyond* `2^63` (`9223372036854775806`..`9223372036854775810`), a
magnitude no native `i64` could represent at all, and gets the correct
arbitrary-precision result (`36893488147419103230`) on every backend
including native. Native lowering never bakes in machine-`i64` overflow
semantics: `op ilt`/`op iadd` are the same general ops ordinary `+`/`<`
already use, so the raw-vs-BigInt representation choice is made per
callsite by the *existing* `RawEligibleCall`/range-proof machinery,
unmodified by this milestone — for `web::emailish?`'s own induction
variables specifically, the unbounded-`min` finding above means they do
*not* qualify for raw-`i64` lowering at these generic instances and fall
back to tagged/BigInt-capable operations, which is semantically exactly
as correct, just not as fast (an unclaimed future specialization
opportunity, not a defect).

## Allocation-free loop control

Confirmed via `native::allocationReport` on a standalone fixture
(`fn f(n): loop i from 0 to n: unit`, `native::allocationReport`'s `total
allocations`): **0** — no List/Range/iterator/Block allocation for a
scalar counted loop, matching a bare `loop:`'s own allocation profile
exactly. (`web::emailish?`'s own allocation numbers, driven by
`String`/`Block`/`List`/`ImmutableSet` construction inside the loop
bodies and elsewhere in the function, are reported separately below —
those are the *program's* allocations, not the loop construct's own.)

## Focused syntax/semantic tests

`tests/loop-counted.test` — new file, 62 tests, covering (see spec items
43-46, matched one for one): basic ascending/exclusive-end shape and
parity; zero iterations (`start == end`, `start > end`); one/several
iterations; negative start; negative-to-positive; dynamic start/dynamic
end; bounds evaluated exactly once, left to right (raw-core-IR
`test-tick`/`test-log` fixtures, the identical idiom `loop-in.test`'s own
"evaluated once" test uses); natural exhaustion is `unit`, never collected
into a List; non-Int bounds are an ordinary dynamic `TYPE` error (same
error *kind* on every backend; message text is not required to match
verbatim — see "Required compiler-census questions" #38 below for why);
scope (`i` not in `start`/`end`, not after the loop), shadowing, and
per-iteration closure capture; `break`/`break VALUE`/bare `break`;
`continue` (including an off-by-one pin and an exclusivity-under-continue
pin); `return`-from-enclosing-function; error propagation with no partial
result; nested combinations (counted-in-counted, counted-in-bare,
bare-in-counted, counted-in-listloop, listloop-in-counted); the
tagged-small-Int boundary and a magnitude beyond native `i64`; existing
`loop x in EXPR:`/bare `loop:` regression; `from`/`down`/`to`/`through`/
`by` still usable as ordinary identifiers; the AST shape of a parsed
counted loop; eight malformed/reserved-form parser diagnostics; and the
no-synthetic-instance/no-materialized-Block invariants.

## Focused GC-stress backedge test

`tests/native-root-liveness.test`'s new `root-loop-carried-counted-1`:
real Botlish surface source (not hand-NIR, unlike its `root-loop-carried-1`
neighbor — a counted loop's genuinely new interest is whether the ordinary
HIR→native pipeline roots it correctly, not a hand-crafted NIR shape), a
managed `String` bound outside a 20-iteration counted loop and read every
iteration (so it must stay live across the loop's own `jump`/`label`
backedge) while each iteration also allocates fresh, immediately-garbage
`String` values (`concat`'s own junk), run under
`BOTLISH_NATIVE_GC_STRESS=1` (collect before every single allocation).
Passes, returning the untouched original string. The full repository-wide
GC-stress suite is left to CI's own `gc-stress` job
(`.github/workflows/tests.yml`), per spec item 80's explicit allowance —
stated here explicitly, not run locally for this milestone beyond the
focused fixture above.

## Existing-loop regression

Bare `loop:`, `loop x in EXPR:`, `break`/`continue`/`break VALUE`,
nested-loop completions: unmodified, and every existing test for them
still passes verbatim (`tests/loops.test`, `tests/loop-in.test`). Three
negative controls with no new syntax at all — `bench/fib.ir`,
`bench/loop-count.ir`, `bench/sum-refined.ir` — produce the identical
values, NIR line counts, and zero-allocation profile they always have;
this milestone touched no existing `switch` arm for `if`/`call`/`loop`/
`listloop` anywhere in the pipeline, only added new ones, so no existing
lowering path's *output* could have changed by construction.

## `web::emailish?` source before

See git history at commit `b472022` (R2.a.2's own final state) for the
verbatim pre-R2.a.3 `lib/web.bot` — `scan_while` and `domain_loop` both
self-tail-recursive, helpers named `is_local_char`/`is_label_char`/
`tld_ok`.

## Final `web::emailish?` source

```botlish
namespace web

local_extra_chars = immutable_set_from_list([".", "_", "%", "+", "-"])

fn emailish?(v):

    n = length(v)

    fn char_at(i):
        substring(v, i, i + 1)

    fn local_char?(c):
        is_tcl_alnum(c) or immutable_set_contains(local_extra_chars, c)

    fn label_char?(c):
        is_tcl_alnum(c) or c == "-"

    fn scan_while(start, predicate):
        loop i from start to n:
            if predicate(char_at(i)):
                continue
            return i
        n

    fn tld?(i):
        e = scan_while(i, is_tcl_alpha)
        if e == n:
            e - i >= 2
        else:
            false

    fn domain?(start):
        loop j from start to n:
            if char_at(j) == ".":
                if j == start:
                    return false
                if char_at(j - 1) == ".":
                    return false
                if tld?(j + 1):
                    return true
            else:
                if not label_char?(char_at(j)):
                    return false
        false

    local_end = scan_while(0, local_char?)
    if local_end == 0:
        false
    else:
        if local_end >= n:
            false
        else:
            if char_at(local_end) == "@":
                domain?(local_end + 1)
            else:
                false
```
(full file, with commentary, is `lib/web.bot`; `hex_digits`,
`additional_unreserved_chars`, `is_unreserved`, `uri_escape_text` are
unchanged and omitted here.)

## `scan_while` rewrite

Old: `scan_while(i, predicate)` — self-tail-recursive, base case `i >=
n`. New: `loop i from start to n: if predicate(char_at(i)): continue;
return i` then a trailing `n`. No `else`: `if COND: continue` followed by
`return i` at the same indent is the idiomatic early-exit shape this
codebase already uses for `if`-without-`else` statement forms; adding an
`else` here would only re-indent `return i` without changing behavior. The
natural-exhaustion value `n` directly replaces the old base case's `i` —
verified equivalent because every actual call site in this module already
guarantees `start <= n` (so on natural exhaustion `start == n`, and old
and new both return `n` in that case) — not a silent behavior change for
any call this program makes. Predicate-passing is unchanged: `predicate`
remains an ordinary first-class parameter (`local_char?` and
`is_tcl_alpha` flow through it exactly as before; `label_char?` no longer
does — `domain?` now calls it directly, see "Post-freeze compiler
findings"), the deliberately preserved compiler finding this milestone
does not try to specialize away.

## `scan_while` must stop being recursive — confirmed

Directly verified against the compiled `bench/refined-checks.ir` NIR text
(`native::lower::program`): `scan_while`'s own function body contains
`jump`/`label`/`br` (the counted loop's own backedge) and **zero**
`tail`/`tailenv` lines. `blockescape-region-companion-refined-checks-5`
(rewritten for this milestone) pins the *global* consequence: this
benchmark's total `tail` count drops from 5 (R2.a) to 3, and none of the
3 remaining ones belong to `emailish?`'s own helpers any more (they are
`uri_escape_text`'s `esc_bytes`/`esc_from` and the benchmark's own `check`
driver — all three pre-existing, untouched by this milestone).

## Domain parser rewrite

`domain_loop` is gone entirely, replaced by `domain?` — not a
recursion-preserving rename. The rewrite is driven directly from the
domain grammar (one or more non-empty label segments separated by `.`,
followed by a final alphabetic TLD of length >= 2), using one structural
fact the old recursive algorithm's own greedy left-to-right behavior
already relied on implicitly: at every `.`, the text *after* it is a
candidate TLD, but the text after any `.` other than the domain's own
*last* one necessarily contains a further `.`, so `tld?`'s all-alphabetic
check can only ever succeed at the last `.`. A single forward counted
loop over character positions therefore needs **no loop-carried state**
(no "remembered last dot") to find the correct split: at each `.`, check
`tld?` on what follows — true means accept immediately (this dot,
whichever one the loop is currently at, is provably the domain's last
one, because a non-last dot's own `tld?` check is guaranteed to fail);
false means try the next position, exactly the old recursion's own greedy
behavior. A `.` is additionally rejected on sight if it opens the domain
(`j == start`) or immediately follows another `.` (`char_at(j - 1) ==
"."`) — both are *local* checks (no state carried across positions).
Reaching `end` with no accepting `.` ever found (no `.` at all, a
trailing `.`, or a too-short/non-alphabetic final segment) is the one
remaining rejection, via natural loop exhaustion. `return true`/`return
false` inside the loop return from `domain?` itself, exactly the intended
`return`-from-enclosing-function use spec item 12 calls out. The result:
`domain?` is not merely non-`domain_loop`-recursive, it is not
self-recursive *at all* any more (confirmed: zero `tail` lines in its own
compiled body) — exceeding the milestone's stated minimum (only
`domain_loop`'s own name and self-tail shape were required to disappear).

## Predicate helper naming cleanup

`is_local_char` → `local_char?`, `is_label_char` → `label_char?`,
`tld_ok` → `tld?`, `domain_loop` → `domain?` (new algorithm, not a rename).
`char_at`/`scan_while` keep their existing names (neither is a boolean
predicate). `is_tcl_alnum`/`is_tcl_alpha` (native APIs) are untouched, per
spec item 54.

## Semantic parity

Verified two ways. (1) The existing corpus
(`tests/emailish-predicate.test`'s own valid/invalid table, plus
`tests/module-fn-bridge-reachability.test`'s parallel corpus) passes
unmodified — every test in both files still passes verbatim after the
rewrite. (2) A fresh domain-edge corpus (spec item 52) was run through
both the *old* (pre-R2.a.3, via `git show b472022:lib/web.bot`) and *new*
implementations side by side, as a standalone differential script, before
this rewrite was committed:

| address | expect | old | new |
|---|---|---|---|
| `someone@example.com` | true | true | true |
| `not-an-email` | false | false | false |
| `@example.com` | false | false | false |
| `"a b"@example.com` | false | false | false |
| `foo@bad_domain.com` | false | false | false |
| `foo@example.c` | false | false | false |
| (empty) | false | false | false |
| `@` | false | false | false |
| `user@example.com` | true | true | true |
| `user@a.b.com` | true | true | true |
| `user@a.b.cde` | true | true | true |
| `user@example.c` | false | false | false |
| `user@example.` | false | false | false |
| `user@.example.com` | false | false | false |
| `user@example..com` | false | false | false |
| `user@example.com.` | false | false | false |
| `user@example_foo.com` | false | false | false |
| `user@example-.com` | true (preserved) | true | true |
| `user@-example.com` | true (preserved) | true | true |
| `café@例え.テスト` | true | true | true |

Zero mismatches. `example-.com`/`-example.com` are deliberately **not**
newly rejected (spec item 52: do not start enforcing no-leading/trailing-
hyphen DNS rules the old implementation never enforced) — both preserved
exactly as accepted.

## Closure/OpenInstances before/after

Unchanged in structure, changed only in the numbers a differently-shaped
source produces. `web::emailish?<generic>` remains a closure (captures
`local_extra_chars`, R2.a.1's own finding, untouched — spec item 89
confirms this explicitly, not investigated further per item 61).
`local_char?` (renamed from `is_local_char`) remains its own nested
closure, still 800 allocations (one per real `emailish?` call in the
benchmark) — unchanged in *kind*, R2.a.1's own finding. `char_at` remains
the one shared, flattened, non-capturing instance region-analysis already
gave it (`captures=0`) — now duplicated into two NIR-level function
bodies (a region-companion `results=3` variant and a plain one), a
pre-existing native-lowering mechanism (StringRegion companion functions,
unrelated to this milestone) that already existed before R2.a.3 for the
identical reason (confirmed: `blockescape-region-companion-refined-checks-2`,
unmodified, still passes). No new anonymous/materialized-Block instance
exists anywhere in `emailish?`'s own region (`hir::specialize::analyze`
shows the identical 26 used instances by *count*, only two of them
renamed and one — `domain_loop`/`domain?` — behaviorally simplified).

## Range facts before/after

`check.n`: unchanged, still unbounded (`[-∞, +∞]`) — `check<generic>`
still captures the `web::emailish?` closure, R2.a.1's own finding, not
revisited (`emailish-predicate-check-n-control`, unmodified, still
passes). New: `scan_while`'s `i` and `domain?`'s `j` induction bindings
(countloop-local bindings, distinct from the functions' own `start`
parameters) now get a real, non-trivial `max` bound —
`length(v)`'s own `collectionLength` fact (`smallMax`, i.e.
`[…, 4611686018427387902]`) — that the old recursive `scan_while`/
`domain_loop` had no binding to seed at all (a self-tail-recursive
function's own parameter Range comes from `hir/induction.tcl`'s narrower
`==`-termination proof, which never applied to `domain_loop`'s own `>=`-
style base case, and never applied to `scan_while` at all since its own
base case only ever widened). `min` stays unbounded for both (`-inf`):
each is a `<generic>` instance reached from more than one call site with
differing `start` arguments, and the Range lattice's own cross-call-site
join is correctly conservative there.

## Allocation/String census

`bench/refined-checks.ir` (800 real `emailish?` calls), before (R2.a.2,
commit `b472022`) vs. after (this milestone), via
`native::allocationReport`:

| | R2.a.2 | R2.a.3 |
|---|---|---|
| total allocations | 10023 | 8823 |
| allocated bytes | (unchanged proportionally) | see below |
| String | 9204 | 8004 |
| List | 12 | 12 |
| ImmutableSet | 2 | 2 |
| Block | 803 | 803 |
| StringPlan | 2 | 2 |
| GC cycles | 0 | 0 |

The 1200-allocation drop (all String) is a genuine, measured
source-induced payoff, not an optimizer change: the old `domain_loop`
called `char_at(label_end)` as an *explicit extra check* after each
`scan_while(i, label_char?)` scan, on top of every `char_at` call
`scan_while`'s own predicate already made internally; the new `domain?`
reads `char_at(j)`/`char_at(j - 1)` directly at each position it visits,
with no redundant re-scan. `Block`/`List`/`ImmutableSet` counts are
byte-for-byte unchanged (the module-retained set and its own capturing
closures are untouched by the loop rewrite, exactly as spec item 56
requires). A standalone scalar counted loop
(`fn f(n): loop i from 0 to n: unit`) allocates **0** — confirmed
separately (see "Allocation-free loop control" above); this benchmark's
own allocations are all from `String`/`Block`/`List`/`ImmutableSet`
construction *inside* the loop bodies and module scope, not from the loop
construct itself.

## Machine/NIR census

`bench/refined-checks.ir`, before (R2.a.2) vs. after (R2.a.3):

| | R2.a.2 | R2.a.3 |
|---|---|---|
| compiled functions (NIR `func` defs) | 25 | 24 |
| used instances (`hir::specialize`) | 26 | 26 |
| machine-code bytes | 10027 | 10258 |
| NIR lines | 662 | 688 |
| call | 22 | 21 |
| callenv | 3 | 3 |
| callmulti | 2 | 0 |
| callvalue | 1 | 1 |
| tail | 5 | 3 |
| tailenv | 0 | 0 |
| guard | 5 | 3 |
| closure | 4 | 4 |
| fnvalue | 1 | 0 |
| capture | 5 | 5 |

(R2.a.2's own row is R2A2-TRAILING-QUESTION-IDENTIFIERS.md's committed
table, itself identical to R2.a.1's, since that milestone changed no
allocation/NIR shape.) `callmulti`/`fnvalue` both drop to 0, and
`tail`/`guard` both drop by 2, tracking the elimination of `scan_while`'s
and `domain_loop`'s own self-tail call machinery (a self-tail call's own
multi-value rebind apparatus and its own guard checks disappear once
there is no self-tail call left to make). `NIR lines` *grows* (662 → 688):
a counted loop's own backedge shape (preheader/header/body/continue/exit,
five labels) is more NIR-verbose per loop than a bare self-tail `tail`
instruction was, even though there are fewer of them and no longer carry
guard/multi-value overhead.

**`compiled functions` drops by one, but not for the reason it looks
like.** `domain_loop`'s replacement, `domain?`, is still exactly one
function — the actual missing function is `label_char?` (renamed from
`is_label_char`), which no longer exists as a separate compiled function
*at all*: it is fully inlined into `domain?` by this repository's own
pre-existing tiny-leaf-inlining pass (`TINY-EXACT-LEAF-INLINING.md`/
`TINY-LEAF-DEFAULT-ON.md`; confirmed unmodified — R3/leaf-inlining is
explicitly out of scope for this milestone, spec item 63), triggered
purely as a consequence of *how the new source calls it*: the old
`domain_loop` passed `is_label_char` as a **value**, `scan_while(i,
is_label_char)` (an escaping callback, not inlinable); the new `domain?`
calls `label_char?(char_at(j))` **directly** (an ordinary, non-escaping,
statically-known call), which is exactly the shape the existing inliner
already knows how to fold. Grep-confirmed: `label_char` does not appear
anywhere in the regenerated `audit/native-scalar-asm/bench/refined-
checks.{asm,vcode,summary.txt}`.

**Per-function machine-code bytes** (`native::roots`'s own per-function
breakdown, matched by position — `web::emailish?`'s own helpers only,
everything before/after this range in the array is byte-for-byte
identical, confirming `char::codepoint`/`byte::*`/`ascii::*` and
`web::is_unreserved`/`uri_escape_text`'s own helpers/`check` are
untouched by this milestone):

| function | R2.a.2 | R2.a.3 |
|---|---|---|
| `web::emailish?` | 833 | 753 |
| `char_at` (×2, unchanged) | 262 / 222 | 262 / 222 |
| `local_char?` (was `is_local_char`) | 272 | 272 |
| `label_char?` (was `is_label_char`) | 249 | *(inlined into `domain?`)* |
| `scan_while` | 552 | 528 |
| `tld?` (was `tld_ok`) | 468 | 468 |
| `domain?` (was `domain_loop`) | 660 | 1244 |

`char_at`/`local_char?`/`tld?` are byte-for-byte identical — their own
bodies genuinely did not change (only `tld_ok`→`tld?`'s name did).
`web::emailish?`'s own body shrinks (833 → 753): its call sites into
`scan_while`/`domain?` are unchanged in kind, so this is `scan_while`'s
own modest shrink (552 → 528, the counted loop's backedge is leaner than
the old base-case-plus-self-tail-call shape) reflected through. `domain?`
very nearly doubles (660 → 1244) — almost entirely `label_char?`'s own
249 bytes landing inline (249 alone accounts for most of the 584-byte
growth; the rest is the new position-at-a-time control-flow shape itself,
which briefly touches every character rather than jumping by whole
labels). Net machine-code size for the whole benchmark grows by 231 bytes
(10027 → 10258, +2.3%) despite *fewer* functions, *fewer* allocations, and
*fewer* self-tail backedges — a legible, honestly-reported trade (a
directly-called leaf now compiles inline rather than as a shared call),
not a regression this milestone's own scope calls for chasing (spec item
70: no allocation/size target; item 87: do not pre-select the next
optimization from this alone).

## Callgrind census

Not run for this milestone: `audit/native-scalar-asm/`'s own disassembly-
based corpus (regenerated below) is the audit tooling this repository
already has wired up and committed; callgrind/`audit-native` is a
separate, heavier tool this milestone's own scope (a source-normalization
and one language feature, explicitly not a performance-ranking milestone)
does not require. Dynamic instruction-level ranking remains pending, as
it already was after every prior R2.a submilestone.

## Canonical negative controls

`bench/fib.ir`, `bench/loop-count.ir`, `bench/sum-refined.ir` — none uses
the new syntax. Confirmed identical value, NIR line count, and
zero-allocation profile to their known-good baseline (no delta requiring
explanation): `fib` → `int 17711`, `loop-count` → `int 3500`,
`sum-refined` → `int 80200`, all three `total allocations: 0`. This
follows from construction, not merely from re-running them: this
milestone added new `switch` arms (`countloop`) to every relevant file
but modified **zero** existing arms for `if`/`call`/`loop`/`listloop`/
anything else these three programs' own compiled shape could reach.

## Final source freeze

`web::emailish?`'s Botlish source (`lib/web.bot`) is frozen as of this
milestone's own commit. Future optimizer work (higher-order target
propagation, module-static retained-value representation, range↔
blockescape integration, R3 inlining, relational bounds, StringRegion/
traversal work) measures against this exact source; no further *source*
changes to `emailish?` are in scope merely to make some future
optimization easier, absent a new explicit source-design reason.

## Post-freeze compiler findings

- `web::emailish?`'s own predicate-callvalue count: unchanged from
  R2.a.2 (`callvalue: 1` in the machine/NIR census above) —
  `scan_while(i, predicate)`'s own `predicate(char_at(i))` call remains
  the one genuinely dynamic higher-order call site in this module.
  `local_char?` and `is_tcl_alpha` still flow through it as ordinary
  first-class values (`label_char?` no longer does — see the next item).
- `label_char?` (renamed from `is_label_char`) stopped being passed
  through `scan_while` as a value at all in the *new* `domain?` — it is
  now called directly, `label_char?(char_at(j))`, an ordinary ("known")
  call, not a `callvalue`. This is the one genuine higher-order-shape
  change this milestone's source rewrite produced (a direct, measured
  consequence of the algorithm no longer scanning a whole label in one
  `scan_while` call before checking the next character — the new
  `domain?` inspects one character at a time, so `label_char?` no longer
  needs to travel as a callback) — and it goes further than merely
  losing its `callvalue` status: no longer escaping as a value makes it
  eligible for this repository's own pre-existing tiny-leaf inliner
  (untouched by this milestone), which now folds it directly into
  `domain?`'s own body — `label_char?` no longer exists as a separate
  compiled function at all (see "Machine/NIR census").
- `char_at` Strings: 8004, down from 9204 (see "Allocation/String
  census"). `scan_while` remains the dominant source of the remaining
  materialization (its own predicate-invoked `char_at` calls, for the
  local-part scan and the TLD's alpha scan), not `domain?` (which now
  calls `char_at` directly rather than through `scan_while`, one call per
  domain character it actually inspects — no redundant re-scan).
- Module-retained closure structure (R2.a.1's own finding: module-
  retained set → `web::emailish?` closure → callers capture the closure →
  generic-keyed caller) is confirmed still present, unchanged, and not
  investigated further, exactly as spec item 89 anticipates.
- **StringRegion regains real visibility** (spec item 88's own question,
  answered with fresh data, `tests/native-string-view.test`): `domain?`
  now reads `char_at(j)`/`char_at(j - 1)` *directly* at every character
  position it visits, not just once per label the way `domain_loop`'s own
  single post-`scan_while` check did. On `"café@例え.テスト"` (a real
  matching address whose Unicode domain is mostly inspected by `domain?`),
  raw `char_at` String allocations go from 13 to 15 (more call *sites*,
  a direct source-shape consequence — not an optimizer change), but
  `hir/stringregion.tcl` (untouched) now eliminates 7 of them instead of
  2 (`-string-region-opt 1`: 11 surviving → 8 surviving). `"not-an-email"`
  (rejected before `domain?` is ever reached, since it has no `"@"`) is
  unaffected: 12 raw / 12 surviving, unchanged.

## Recommended next milestone

Given this milestone's own findings, the strongest remaining optimization
candidate is **higher-order exact-target propagation** for
`scan_while(i, predicate)`'s one remaining `callvalue` site: `predicate`
is always one of a small, statically-enumerable set of closures
(`local_char?`, `is_tcl_alpha`) at its only two call sites in this module,
so proving the target statically (rather than dispatching through a
`callvalue`) is plausible without touching StringRegion, specialization
policy, or range↔blockescape integration — none of which this milestone's
findings newly motivate ahead of the others. Not decided here, per spec
item 87 — offered as this report's own read of where the ceiling now sits,
not a commitment.

## Required-question answers (spec items 91-95)

**Language (1-12).** 1. `loop IDENT from expression to expression :
suite`. 2. Yes. 3. Zero iterations. 4. Yes. 5. Left to right. 6. No. 7.
Yes, semantically. 8. No. 9. No. 10. `unit`. 11. Discarded, not
collected. 12. `break`: ends the loop with its value (or `unit`) as the
loop's own result. `continue`: skips the rest of the body, advances to
`i+1`. `return`: returns from the lexically enclosing function. Errors:
propagate exactly as through any other loop.

**Representation (13-20).** 13. A `countloop` HIR/core-IR node (`start`,
`end`, `countBinding`, `bodyScope`/`ELEMENT-BLOCK`, `body`). 14. No. 15.
No. 16. No. 17. A loop-carried NIR register, rebound via `move` at the
backedge — the same "multi-definition-site register" pattern `listloop`'s
own index/accumulator and `if`'s own join register already use. 18. Yes.
19. No (confirmed: zero `tail`/`call`/`callenv` lines represent a
`countloop`'s own backedge in any compiled fixture checked). 20. Via the
same generic backward-liveness fixpoint every other backedge already
gets (`native/src/codegen/roots.rs`'s `Cfg::build`/`analyze` are
backedge-agnostic by construction — no loop-shape-specific rooting code
was added).

**Future syntax (21-24).** 21. Contextual, one-token-of-lookahead
recognition, exactly like `in`; none of `down`/`through`/`by` is a lexer
keyword. 22. No. 23. Compiler-proven equal iteration count, no runtime
mismatch/truncation/padding handling. 24. No (see "Reserved future
grammar").

**Source (25-32).** 25. No. 26. No, replaced by the non-recursive
`domain?`. 27. `domain?`, rewritten directly from the domain grammar
(greedy left-to-right TLD-candidate check at every `.`, no loop-carried
state). 28. Yes, confirmed by differential testing against the pre-R2.a.3
implementation on the existing corpus plus a fresh domain-edge corpus,
zero mismatches. 29. `local_char?`, `label_char?`, `tld?`, `domain?`. 30.
`char_at`, `scan_while` — neither is a boolean predicate. 31. No helper
was removed for having become a pure transliteration artifact;
`domain_loop` was replaced outright (a new algorithm, not merely renamed).

**Compiler census (33-50).** 33/34. 26 used instances / 26, unchanged in
count. 35. See "Machine/NIR census": `tail` 5→3, `callmulti` 2→0,
`fnvalue` 1→0. 36. `call` 21 (down from 22, since one prior generic `call`
belonged to a self-tail-eliminated helper's now-gone recursive
structure). 37. `callvalue` unchanged at 1 (`scan_while`'s own
`predicate(...)` call). 38. `local_char?`, `is_tcl_alpha` (via
`scan_while`'s own `predicate` parameter). 39/40. Unchanged from R2.a.1:
`web::emailish?<generic>` remains the one closure-capturing instance in
this region; no new `OpenInstances`/`blockescape` entry was created or
removed. 41. See "Range facts before/after": `scan_while`'s `i` and
`domain?`'s `j` induction bindings (not the `start` parameters) now get
`max` bounded by
`length(v)`'s `collectionLength` fact; `min` stays unbounded (multi-call-
site join). 42. Unchanged, still `[-∞, +∞]` (`check<generic>`, still
capturing the `web::emailish?` closure). 43. Unchanged from R2.a.1/2:
module-retained set → closure → generic-keyed caller. 44/45. Machine
bytes 10027 → 10258 (+231, +2.3% — `label_char?`'s own 249 bytes landing
inline in `domain?` rather than in its own function, see "Machine/NIR
census"'s per-function table); NIR lines 662 → 688. 46/47. Total
allocations 10023 → 8823; String 9204 → 8004 (both from `domain?` calling
`char_at` directly instead of through an extra re-scan). Block/List/
ImmutableSet unchanged. 48. Not separately re-measured beyond
`native::roots`'s own structural counts already exercised by
`tests/native-root-liveness.test`. 49. Yes, genuinely: see "StringRegion
regains real visibility" above — `domain?`'s direct, character-at-a-time
`char_at` reads let `hir/stringregion.tcl` (untouched) eliminate 7 of 15
raw allocations on a real matching Unicode address, up from 2 of 13
before this milestone. 50. See
"Recommended next milestone": higher-order exact-target propagation for
`scan_while`'s one remaining `callvalue` site.

## Stop conditions

Both stop-and-report triggers in spec item 98 were checked and neither
fired: the HIR/core IR representation expressed the induction binding
directly, with no forced fallback to an ordinary function/call; and the
final domain grammar was expressible with the counted loop and no
mutable state (the "no loop-carried last-dot" insight in "Domain parser
rewrite" above is exactly the reason no stop was needed). The counted-loop
feature's own 16 stop-condition items (spec item 96) and R2.a's 13 (spec
item 97) are all satisfied, per the sections above.

## Full regression

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
...
all.tcl:	Total	2544	Passed	2544	Skipped	0	Failed	0
Sourced 86 Test Files.
```

(`interp` and `compile` Tcl backends; `stdlib.test`/`native.test` also
exercise `cranelift`/`cranelift-generic` within that same run, and
`tests/loop-counted.test`'s own parity tests exercise all four backends
directly via `outcomeUnder`.)

## GC stress

Focused local run only (`tests/native-root-liveness.test`'s
`root-loop-carried-counted-1`, under `BOTLISH_NATIVE_GC_STRESS=1`):
passes. The full repository-wide GC-stress suite is left to CI's own
`gc-stress` job (`.github/workflows/tests.yml`), per spec item 80's
explicit allowance for this milestone.

## Rust tests

No Rust production code changed: counted-loop lowering stays entirely in
`native/lower.tcl` (Tcl), expressed with NIR forms
(`jump`/`label`/`br`/`op ilt`/`op iadd`/`move`) that already existed for
`listloop`/`if`. `cargo build --release --manifest-path native/Cargo.toml`
was run (rustc 1.98.1, after installing a current `stable` toolchain per
AGENTS.md — the sandbox's preinstalled 1.94.1 was too old for the pinned
`cranelift-*`/`wasmtime-internal-*` crates) to produce the audit corpus
and exercise the native backend in the full regression; no Rust source
changed, so no `cargo test` run was needed.
