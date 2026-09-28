# PAYLOAD-FREE-BREAK.md

## Outcome

**Achieved, with a deliberate, user-approved scope narrowing from the
milestone's own default guidance.** At the surface language level, `break`
now takes no value in any loop kind (`loop:`, `loop i from a to b:`,
`loop x in xs:`), nested or not: `break VALUE` is a syntax error, raised by
the parser itself, the same for every loop kind and every nesting depth.
This is the primary invariant the milestone asked for, and it holds with no
exceptions anywhere a Botlish program can be written.

What did **not** happen, by explicit user decision after a stop-and-report
(the milestone's own items 46/75-77): the payload was not deleted from the
HIR/core-IR representation, the interpreter, the Tcl compiler, or the
native lowering. A corpus search (item 45) turned up real, load-bearing
`break VALUE` usage below the surface parser -- most importantly
`bench/loop-count.ir`, the canonical `loop-count` performance benchmark
referenced throughout ~15 historical audit reports and directly exercised
by `tests/native-root-liveness.test`, `tests/hir-call-facts.test` and
`native/generate-scalar-audit.tcl` -- that fundamentally depends on a bare
loop's `break VALUE` to produce a value at all (Botlish has no mutation).
Deleting the payload universally would have meant rewriting or retiring
that benchmark and orphaning its comparison trail, which items 62/78.14
explicitly require to stay stable. Per the user's explicit direction (see
"Two-tier design" below), the fix is scoped to exactly where the language
needs it -- the surface parser -- leaving the lower representation
(deliberately) able to carry a value, but **unreachable from any Botlish
program**.

## Motivation

The milestone's own framing: `break` should answer exactly one question
("should this loop iterate again?"), never "what unrelated value should
this loop expression become?" Before this milestone, `break VALUE`
overrode a bare loop's or counted loop's own result with an arbitrary,
unrelated type, joined via a general `lub` across every reachable break
site -- a real (if narrowly used) soundness/complexity surface: a loop's
result type depended on which break sites were reachable and what they
happened to evaluate to.

## Old break semantics (pre-milestone, still true at the raw core-IR level)

```
listloop (`loop x in xs:`)      break -> collected prefix; break VALUE -> compile error (already true before this milestone, RETURNING-ITERABLE-LOOPS.md)
countloop (`loop i from a to b:`) break -> existing procedural result; break VALUE -> overrides loop result with VALUE
bare loop (`loop:`)             break -> existing procedural result; break VALUE -> overrides loop result with VALUE
```

## New universal break rule (surface language)

The only valid surface spelling is `break`. `break VALUE` is a syntax
error, in every loop kind, nested or not, including inside a conditional,
including when the payload expression would itself have a side effect
(the expression is never even parsed as an expression -- see "Payload
expression is never evaluated" below).

## Two-tier design

This is the central design decision of this milestone, made explicit
because the default "remove the payload everywhere, including any internal
construction path below the parser" guidance (items 12, 14, 17-27) would
have broken real, load-bearing content. Two representations exist:

1. **The surface language.** `surface/parser.tcl`'s own `break` case (in
   `Simple`) is the *sole* enforcement point: after consuming `break`, if
   the next token is not `NEWLINE`/`DEDENT`/`EOF`, parsing fails
   immediately with a syntax error, before anything resembling an
   expression is ever parsed. No valid parse can produce a surface AST
   `break` node with a value, in any loop kind -- so nothing below the
   parser (HIR resolution, typing, lowering, any backend) can ever observe
   a break payload that originated from a real Botlish program, regardless
   of `-strict` settings (a syntax error is not a deferred diagnostic; it
   raises unconditionally, at parse time).

2. **HIR/core IR, reachable independently of the surface parser.** Two
   internal construction paths sit below the parser and were **already**
   there before this milestone: `hir::syntax::breakNode`'s own optional
   `value` argument (direct HIR construction, used by
   `tests/hir-syntax.test`), and -- far more importantly -- `hir::build`'s
   `fromIR` (raw core-IR *text* lifted straight to HIR, `-origin {ir {}}`),
   which is how `bench/loop-count.ir`, `examples/02-loop-break.ir` and
   `examples/hir/05-control.hir`/`.ir` are loaded, including through the
   **native backend** (`native::buildProgramHir` calls the identical
   `hir::syntax::fromIR` + `hir::buildSyntax` pipeline the surface frontend
   uses, with `-strict 0`). These two paths still construct and execute a
   value-bearing `break` for a `loop:`/countloop target with its full
   pre-milestone "overrides the loop's own result, discarding whatever was
   in flight" semantics, completely unchanged, end to end: HIR resolution,
   `hir/types.tcl`'s `breakTypes`/`lub` typing, the interpreter's
   `core::completion::payload`-forwarding in `op-loop`/`op-countloop`, the
   Tcl compiler's break-value evaluation, and native lowering's break-value
   evaluation/move-into-result-register are **all untouched**.

   Both paths were checked against the corpus: no listloop-targeted
   `break VALUE` exists anywhere below the parser either (RETURNING-
   ITERABLE-LOOPS.md already confirmed this for the surface corpus; the
   `.ir`/`.hir` fixtures confirm it for the raw-IR corpus too), so
   `hir/resolve.tcl`'s pre-existing `LISTLOOP-BREAK-VALUE` diagnostic (the
   *only* semantic-level break-value restriction that predates this
   milestone) is left exactly as it was, unconditionally rejecting a
   listloop-targeted valued break regardless of where the HIR came from.
   Nothing depended on relaxing it, so it wasn't touched.

Why this satisfies the user's stated condition ("acceptable if it is
functionally dead from surface/HIR-as-produced-by-Botlish-source, and
helps with implementing `leave` later"):

- **Functionally dead from surface**: verified directly (see "Corpus
  blast-radius search" and the new parser/lowering tests below) -- no
  sequence of characters a person can type as Botlish source produces a
  break AST node, HIR node, or core-IR node with a value, in any loop kind,
  under any compile option.
- **`leave` scaffolding**: the ADR's future `leave VALUE` (a type-safe
  early loop exit whose payload is constrained to the loop's own result
  type) needs exactly this core-IR/HIR shape -- a break-like completion
  that legitimately carries a value and becomes the loop's own result. That
  shape, and its full interpreter/compiler/native lowering, already exists,
  untouched, ready for a future HIR-level `leave` node to lower into it
  (with proper type constraints added at that layer, not here). This
  milestone does not implement `leave`; it only avoids deleting the
  substrate it would need.

`core/ir.tcl`'s header comment and `hir/resolve.tcl`'s `break` case now
document this two-tier design in place, so a future reader does not
mistake the untouched lower layer for an oversight.

## Loop result disciplines retained in this milestone

Unchanged, exactly as before -- this milestone did not redesign the loops
themselves:

```
loop:                    procedural, natural completion is via break only (no natural exhaustion path exists)
loop i from START to END:  procedural, natural exhaustion and break both produce unit
loop x in XS:             collecting, natural exhaustion and bare break both produce List[bodyType]
```

Counted-loop body values remain discarded; listloop's own break-returns-
prefix semantics (RETURNING-ITERABLE-LOOPS.md) are unchanged and unaffected
by this milestone.

## Surface/parser change

`surface/parser.tcl`'s `Simple` proc previously shared one `return - break`
case; it now has two. `return` is unchanged (still `"return" [expression]`).
`break`'s own case: `Advance`, then if the next token is not
`NEWLINE`/`DEDENT`/`EOF`, `Fail` immediately with `"break" does not take a
value, found ...` -- no attempt to parse an expression is ever made. The
grammar comment, the `valued` production, the "if as a value" prose, and
the shared `if`-value error message (`an "if" value must be the whole
right side of "=" or "return"`, `break` removed from the list) were all
updated to match. `Statement`'s own "the if/loop/handledcall suite already
ended the line" check no longer includes `break` in its kind set (dead for
break regardless, since break's value is now always `""`, but removed for
honesty).

## Resolver/HIR change

None to the resolution logic itself (see "Two-tier design" above):
`hir/resolve.tcl`'s `break` case still threads `value`/`target` exactly as
before, and its `LISTLOOP-BREAK-VALUE` diagnostic is unchanged. What
changed is documentation: a new comment explains explicitly why no
universal `BREAK-TAKES-NO-VALUE`-style resolver defense was added for a
bare/countloop target, despite item 14's default guidance to add one --
because the surface parser already makes it unreachable, and the
below-parser paths that can still reach it are deliberately preserved.

## Core IR change

None functionally. `core/ir.tcl`'s shape validator still accepts both
`(break)` and `(break EXPR)` (`ExpectLength $node 1 2`), and its lexical-
placement `check` still recurses into a break's own value expression when
present. Its header comment now documents that no valid Botlish program
can ever produce the 2-element shape, and why it is kept anyway.

## Completion representation

Unchanged. `core::completion::breaking {v}` still takes a value (a Tcl-
protocol-level necessity, not merely a language one: `return -code break
VALUE` is how a compiled break crosses certain Tcl-proc boundaries in the
Tcl backend, via `core::completion::fromTclCode`'s own code-3 case, and
Tcl's `return -code N` protocol always carries *some* result). For any
break reachable from a real Botlish program, that value is always
`core::value::unit`, by construction of the parser/lowering above -- never
a caller-supplied "alternate result value" in the sense the milestone's
guiding principle warns against. For a raw-IR-sourced break, it is
whatever the raw IR says, exactly as before.

## Interpreter change

None. `core::forms::op-break`, `core::forms::op-loop`, `core::forms::op-
countloop` and `core::forms::op-listloop` are byte-for-byte unchanged.
`op-loop`/`op-countloop` still do
`[core::completion::normal [core::completion::payload $completion]]` on a
`break` completion -- for any break lowered from a real Botlish program
this is always `unit` (satisfying items 19-20's *observable* requirement
exactly, without touching the code), and for a raw-IR-sourced break it
still forwards whatever payload the break carried, deliberately.

## Tcl compile change

None. `compiler/compiler.tcl`'s `break` case in `CompileExpr` is unchanged:
it still evaluates `[N $e value]` when present and moves it into the
loop's result variable. For HIR built from any real Botlish program, `[N
$e value]` is always `""` (the parser guarantees it), so this evaluation
never fires in practice; for HIR built via `fromIR` (e.g. a raw-IR program
compiled through the "compile" backend, exercised by `tests/hir-call-
facts.test`-style native-vs-compile comparisons), it still evaluates and
moves the payload as before.

## Native lowering change

None. `native/lower.tcl`'s shared `break` case (`native::lower::Expr`'s
`break` branch) is unchanged: for a listloop target it moves the
accumulator/discard placeholder (RETURNING-ITERABLE-LOOPS.md, unaffected);
for a bare/countloop target it still evaluates `[dict get $node value]`
when present and moves it into `$resultReg`. For HIR built from any real
Botlish program this branch is dead code (the value is always absent) but
was not removed, since it is exactly what `bench/loop-count.ir`'s own
native-compiled `work` function needs, unchanged, to keep its generated
code (and every asm/vcode comparison built against it) identical.

## Type-system change

None. `hir/types.tcl`'s `breakTypes`/`lub` machinery for `loop`/`countloop`
is untouched. For a real Botlish program, every break contributing to
`ctx breakTypes` is now, unconditionally, `unit` (the parser guarantees no
break ever has a value), so `lub(unit, unit, ..., unit)` always collapses
to `unit` -- `lub(never, unit) = unit`. This is *observably* identical to
the "clean" redesign items 28-33 describe (a bare loop's type is `unit` if
a break is reachable, `never` if not; a countloop's type is always `unit`)
without deleting the machinery that computes it, because for a raw-IR-
sourced program the same machinery still needs to join genuinely different
break-payload types (exactly `bench/loop-count.ir`'s own `work` function,
whose loop is typed `int` via its break's own payload type -- confirmed
directly against `audit/post-call-facts/before/loop-count/hir.txt`, which
still applies unchanged).

## Removed breakTypes/payload machinery

**None was removed.** This is the milestone's most significant deviation
from its own default instructions (items 27, 40, 60), made explicitly by
user decision after the stop-and-report above. See "Two-tier design" and
the architecture/typing Q&A below for the full reasoning per removed-vs-
kept item.

## Bare-loop result invariant

Confirmed directly, both before and after this milestone (unchanged
machinery, unchanged observable result): a bare loop's only successful
loop-local completion is via `break` (there is no natural-exhaustion path
-- `while 1` never exits on its own). For any real Botlish program, every
reachable break now contributes exactly `unit`; a bare loop with no
reachable break is typed `never` (a true, permanent divergence -- this is
not a bug, `never` is the correct type for "does not complete normally").
`examples/surface/07-loop-break.bot` pins this directly (`loop: break`
`# expect: unit`).

## Countloop result invariant

Confirmed: `normal exhaustion type == bare-break exit type == unit`, for
any real Botlish program, unconditionally -- no join is needed to see
this, since every break contributing to the join is now always `unit` by
parser construction. `tests/loop-counted.test`'s pre-existing
`loop-counted-natural-exhaustion-is-unit` and `loop-counted-break-bare`
both still pass unchanged, now joined by
`loop-counted-break-value-rejected` (`break VALUE` is a syntax error).

## Listloop result invariant

Unchanged, exactly as RETURNING-ITERABLE-LOOPS.md left it: natural
exhaustion and bare break both produce `List[bodyType]`; `break VALUE`
targeting a listloop remains rejected -- now doubly so, both by the
pre-existing `LISTLOOP-BREAK-VALUE` semantic diagnostic (still reachable
from below the parser, pinned by the new
`loop-in-break-value-rejected-below-parser` test) and, for any real
Botlish program, by the parser itself (now the *first* rejection reached,
pinned by the rewritten `loop-in-break-value-rejected`/`-nested-still-
invalid` tests, which now expect a `SURFACE SYNTAX` error instead of the
old `CORE SEMANTIC LISTLOOP-BREAK-VALUE`).

## Nested-loop targeting

Unaffected -- item 41's own instruction ("do NOT remove target analysis")
was never at risk, since no target-resolution code was touched.
`tests/loop-counted.test`'s nested-loop tests (counted-in-counted,
counted-in-bare, bare-in-counted, counted-in-listloop, listloop-in-
counted) all still pass; new nested/conditional parser-rejection tests
(`tests/surface-parser.test`'s `parse-error-break-value-nested`/
`-conditional`) confirm a nested/conditional `break VALUE` is rejected at
the correct, innermost position regardless of nesting depth.

## Corpus blast-radius search (item 45)

Searched `lib/`, `examples/`, `bench/`, `tests/` for every `break VALUE`
occurrence before any production edit. Classified:

- **Real, non-test Botlish source (`.bot`)**: `examples/surface/07-loop-
  break.bot` (`break 42`), `examples/surface/08-return.bot` (`break b`).
  Both migrated (see "Real-source migration" below). `lib/*.bot` and
  `bench/*.bot` contain zero `break` occurrences of any kind.
- **Raw core-IR/HIR text below the surface parser, non-test**:
  `examples/02-loop-break.ir`, `examples/hir/05-control.hir`/`.ir`, and
  **`bench/loop-count.ir`** (the canonical `loop-count` benchmark). All
  four left completely unchanged -- see "Two-tier design".
- **Test fixtures using raw core-IR/HIR list syntax directly** (`core::eval`
  /`core::evalIn`/`hir::build`-style, never through `surface::parse`):
  `tests/loops.test`, `tests/control.test`, `tests/backends.test`,
  `tests/hir-lowering.test`, `tests/hir-resolution.test`, `tests/hir-
  syntax.test`, `tests/hir-types.test`, `tests/inference.test`,
  `tests/native.test` (its raw-IR cases), `tests/acceptance.test`. All left
  unchanged -- they exercise exactly the deliberately-preserved lower
  layer.
- **Test fixtures using real surface Botlish source, needing migration**:
  `tests/surface-parser.test`, `tests/surface-lowering.test`,
  `tests/surface-samples.test`, `tests/loop-in.test` (its surface-level
  cases only), `tests/loop-counted.test`, `tests/native.test` (its
  surface-level `parity "..."` cases), `tests/native-tiny-leaf-
  inline.test`, `tests/typed-callable-escape.test`. All migrated -- see
  "Test migration" below.

## Real-source migration

Both real, non-test `.bot` uses were migrated, behavior-preservingly where
possible:

- `examples/surface/07-loop-break.bot`: repurposed (its old subject,
  "break carries the loop's value", is exactly the removed behavior) to
  demonstrate the new invariant directly: `loop:\n    break\n`, `# expect:
  unit`.
- `examples/surface/08-return.bot`: `break b` -> `return b` inside
  `first_positive`. This is behavior-preserving and not a "replacement
  mechanism" for break's old semantics (item 47's own prohibition): the
  original loop never actually iterated more than once (nothing re-entered
  it), so `break b` and `return b` were already observationally identical
  there -- `break` was, in retrospect, not doing anything a `return`
  couldn't already do in that specific example.

No other real (non-test) Botlish or raw-IR source used `break VALUE`
anywhere in the repository.

## Test migration

Every test that asserted the old bare/countloop "break VALUE overrides the
loop's result" behavior *through surface source* was migrated into either
a syntax-error rejection test or a behavior-preserving rewrite using
`return` (never a new mechanism standing in for break's old role, per item
47):

- `tests/loop-counted.test`: `loop-counted-break-value`/`-break-parity`
  (asserted `break i * 100` overrides the result) replaced by
  `loop-counted-break-value-rejected` (asserts the syntax error).
  `loop-counted-nested-counted-in-bare`, `-bare-in-counted`, `-nested-
  parity` (used `break go(0, 0)`/`break 1` to hand a computed value out of
  a bare loop) rewritten to compute the value first, then break bare (Unit,
  discarded), then reference the already-computed value -- still
  genuinely exercising the same nested-loop-targeting shape.
  `loop-counted-existing-bare-loop-still-parses` (`break 42` -> `42`)
  rewritten to `break` -> `unit`.
- `tests/surface-parser.test`: `parse-loop`'s `loop:\n    break 42\n` case
  removed (folded into the new rejection table below); `parse-if-values`'s
  `break if c: ...` case removed (break can never have an if-value at all
  now); a new `parse-error-break-value-*` table (6 cases: bare/counted/
  list loop, nested, conditional, a call whose side effect must never run)
  plus `parse-break-if-value-error` and `parse-break-value-not-evaluated`
  added.
- `tests/surface-lowering.test`: the `loop "loop:\n break 42"` lowering
  rule and the `break-if` lowering rule removed (both now syntax errors);
  `break 2` -> `break` in two structural tests that didn't care about the
  value; a new `lower-break-if-value-error` test confirms the syntax error
  survives through `surface::compile`'s whole pipeline, not just
  `surface::parse`.
- `tests/surface-samples.test`: `surface-run-continue`'s `break t` ->
  wrapped in a function, `return t`.
- `tests/loop-in.test`: `loop-in-break-value-rejected`/`-nested-still-
  invalid` (surface source, listloop target) rewritten to expect the new,
  earlier `SURFACE SYNTAX` rejection instead of the old `CORE SEMANTIC
  LISTLOOP-BREAK-VALUE`; a new `-strict0-still-errors` test pins that this
  is never deferred (a syntax error, unlike a semantic diagnostic); a new
  `-below-parser` test (built via `hir::build`'s `fromIR`, not
  `surface::compile`) confirms `LISTLOOP-BREAK-VALUE` still fires for the
  deliberately-preserved lower layer.
- `tests/native.test`: `native-basic-4`'s `break 42`/`break n` -> `return
  42`/`return n` (docstring updated to match; a new `native-basic-4-bare-
  break` test keeps bare-break parity coverage); `native-closure-3`'s
  `break get` -> `return get`.
- `tests/native-tiny-leaf-inline.test`: `tiny-leaf-ineligible-loop`'s
  `break total` -> `break` (the test only inspects compiled-body
  structure, never the loop's actual value).
- `tests/typed-callable-escape.test`:
  `callable-escape-loop-break-different-rejected` (originally testing that
  hir/types.tcl's callable-type-join machinery rejects two differently-
  typed callables joined through a loop's break) rewritten: the program is
  still rejected, but now for an entirely different, earlier reason (a
  plain syntax error -- break can no longer carry a callable value at all,
  so this can never reach the callable-escape check in the first place).

No test was migrated by inventing a new mechanism to reproduce break's old
role; every migration either asserts the new rejection or uses `return`
where the surrounding code already made that behaviorally identical.

## Structural before/after (item 59 completion-shape census, item 60 lowering census)

| Layer | Before | After |
|---|---|---|
| Surface AST | `break` node has a `value` field, populated by parsing an expression when present | `value` field still exists (shared shape with `return`), but the parser *never* populates it -- any attempt raises a syntax error before an expression is even parsed |
| HIR | `break` node: `value` ("" if none), `target` | Unchanged. Reachable from below the parser only (`hir::syntax::breakNode`, `fromIR`) |
| Core IR | `(break)` / `(break EXPR)` | Unchanged. `core::ir::check` still accepts both shapes |
| Interpreter completion | `{break V}`, `core::completion::breaking {v}` | Unchanged (Tcl `-code break` protocol boundary requires a value slot to exist structurally) |
| Tcl compile context | `ctx loops` registration + payload evaluation/move in `break`'s case | Unchanged |
| Native lowering metadata | `dict set fn loops $e [list ... resultReg accReg]` + payload evaluation/move | Unchanged |
| NIR | Payload-evaluating/moving instructions still generated for a raw-IR-sourced bare/countloop break | Unchanged (dead code for any surface-compiled program, since the value is always absent there) |

Nothing was deleted below the surface parser. What disappeared is
**reachability**, not code: no surface Botlish program, under any compile
option, can construct a break node with a value, in any loop kind. The
`breakTypes`/`lub`-based typing, the payload-evaluation branches in the Tcl
compiler and native lowering, and the `LISTLOOP-BREAK-VALUE`-adjacent
special-casing all remain, exactly as items 27/40/60 describe them, but as
dead-for-surface machinery serving the deliberately-preserved raw-IR tier
rather than as removed code.

## Canonical controls (item 62)

`fib`, `loop-count`, `sum-refined`, `refined-checks` (and `web::emailish?`'s
own `scan_while`) are untouched by every change in this milestone: no
production logic changed at all (only documentation and the surface
parser, which none of these four benchmarks' own generated programs ever
exercise through a break-with-value path -- `bench/loop-count.ir` is raw
IR, never parsed by `surface/parser.tcl`). Re-ran `bench/loop-count.ir`
through the native backend directly (`tests/native-root-liveness.test`,
`tests/hir-call-facts.test`) as part of the full regression below: byte-
identical behavior, confirming the two-tier design actually delivers on
its own stated purpose.

## List stdlib controls (item 63)

`list::any?`/`all?`/`none?`/`find` (`lib/list.bot`) contain no `break` of
any kind (confirmed by the corpus search above) and were not touched. Their
four `callvalue` sites are unaffected.

## GC stress (item 68)

Focused runs, each in isolation (matching prior milestones' own established
practice for this file set):

```
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/loop-in.test          34/34 passing
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/loop-counted.test     61/61 passing
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/native-listloop.test  12/12 passing
```

**107/107 passing, 0 failed**, run individually as established practice
(RETURNING-ITERABLE-LOOPS.md's own prior note: a full-suite concurrent
GC-stress run can produce spurious, CPU-contention-caused failures in
unrelated exhaustive tests -- avoided here the same way). No object-
lifetime-relevant production code was touched by this milestone (see
"Structural before/after"), so this result was expected, not merely hoped
for. No repository-wide local GC-stress run was performed; CI's own
`gc-stress` job on `main` owns that, per AGENTS.md.

## Full regression (item 67)

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
```

Run across both `interp` and `compile` backends (the harness's own
default), with the native (Cranelift) backend built
(`cargo build --release --manifest-path native/Cargo.toml`, rustc 1.98.1
via `rustup toolchain install stable`, per AGENTS.md) so every
`cranelift`/`cranelift-generic` parity case in the suite (including
`tests/native.test`, `tests/native-listloop.test`, and the loop-count-
based `tests/native-root-liveness.test`/`tests/hir-call-facts.test`) ran
for real rather than reporting `NATIVE NOT-BUILT`:

```
all.tcl:  Total 2615  Passed 2615  Skipped 0  Failed 0
Sourced 90 Test Files.
```

**2615/2615 passing, 0 failed**, on both `interp` and `compile` (exit code
0 for the whole two-backend run), 90 test files, 0 skipped. Net +8 over
the pre-milestone baseline (2607, RETURNING-ITERABLE-LOOPS.md's own final
count): the new parser/lowering/HIR rejection and below-parser-defense
tests added across `tests/surface-parser.test`, `tests/surface-lowering
.test`, `tests/loop-counted.test`, `tests/loop-in.test` and
`tests/native.test` slightly outnumber the tests removed/merged during
migration.

## Remaining ADR work deliberately postponed

`leave VALUE`, `with intermediate`, countloop collection semantics, and any
new syntax/keyword reservation remain entirely out of scope, exactly as
items 3, 65-66 require. This milestone leaves the raw-IR-level value-
bearing break/loop-result machinery intact specifically so that future
`leave` work has a lowering target to build on, without having to
reintroduce it from scratch.

## Readiness for higher-order dogfooding workloads

The surface language's `break` is now unconditionally payload-free, with
no per-loop-kind exception visible to any Botlish program; the canonical
benchmarks, the list stdlib's higher-order helpers, and every existing
backend-parity guarantee are unaffected (confirmed by the full regression
above). The tree is ready to return to the higher-order/compiler-
dogfooding workloads this milestone was meant to precede.

---

## Required architecture questions (item 70)

1. **Where was `break VALUE` parsed?** `surface/parser.tcl`'s `Simple`
   proc, previously a shared `return - break` case parsing an optional
   trailing expression. Now split: `break`'s own case never parses an
   expression at all.
2. **Where was its payload stored in AST/HIR/core?** Surface AST `break`
   node's `value` field; HIR `break` node's `value` field; core IR's
   `(break EXPR)` 2-element shape. All three still exist as *representable
   shapes* (unchanged), but the surface AST's is never populated by the
   parser and the HIR/core-IR ones are only reachable via the deliberately-
   preserved below-parser construction paths.
3. **Where did target resolution occur?** `hir/resolve.tcl`'s `break` case
   (`SetField hir $e target $loop`, from `[dict get $ctx loop]`).
   Completely unchanged -- target resolution was never part of this
   milestone's removal (item 41).
4. **Where did the payload participate in loop type inference?**
   `hir/types.tcl`'s `ctx breakTypes` dict + `lub`, in the `loop` and
   `countloop` cases (`listloop`'s own case never read it, even before
   this milestone -- RETURNING-ITERABLE-LOOPS.md). Still there, unchanged;
   for any real Botlish program every contribution is now `unit`.
5. **Which backends evaluated/moved the payload?** The Tcl compiler
   (`compiler/compiler.tcl`'s `break` case) and the native backend
   (`native/lower.tcl`'s `break` case, bare/countloop branch). Both still
   do, unchanged, for the raw-IR-sourced case only.
6. **What internal completion representation carried it?**
   `core::completion::breaking {v}` (`{break V}`). Unchanged, kept for the
   Tcl `-code break` protocol boundary.
7. **Which payload-specific fields/branches were deleted?** None. See
   "Two-tier design" for why, and "Removed breakTypes/payload machinery"
   above.
8. **Does any valid internal representation still allow a Break payload?**
   Yes, deliberately: HIR/core IR constructed via `hir::syntax::breakNode`'s
   own optional value or `hir::build`'s `fromIR` (raw core-IR text). Not
   reachable from any surface Botlish program under any compile option.

## Required semantic questions (item 71)

9. **Is `break` zero-operand everywhere?** At the surface language level:
   yes, unconditionally. At the raw core-IR/HIR level (below the parser):
   no, by deliberate design (see above).
10. **Can `break VALUE` occur in a bare loop?** In Botlish source: no
    (syntax error). In raw core-IR/HIR: yes, unchanged.
11. **In a countloop?** Same answer as 10.
12. **In a listloop?** In Botlish source: no (syntax error, the earliest of
    two independent rejections). In raw core-IR/HIR: no either -- this was
    already true before this milestone and stays true; nothing depended on
    relaxing it.
13. **What does bare-loop break produce?** `unit`, for any real Botlish
    program (the parser guarantees the completion's value slot is always
    `core::value::unit`). For a raw-IR-sourced program: whatever the raw IR
    supplies.
14. **What does countloop exhaustion produce?** `unit`.
15. **What does countloop break produce?** `unit`, for any real Botlish
    program -- same type/result discipline as 14. (Raw-IR-sourced: as
    supplied.)
16. **What does listloop exhaustion produce?** `List[bodyType]`.
17. **What does listloop break produce?** `List[bodyType]` (the collected
    prefix) -- same result type as 16, unchanged from RETURNING-ITERABLE-
    LOOPS.md.

## Required typing questions (item 72)

18. **Does any loop type depend on break payloads?** For any real Botlish
    program: no -- every payload the type system could ever see is `unit`,
    by parser construction, so the join is observably a no-op. The
    machinery computing it still exists (see item 8/60/the deviation
    explanation).
19. **Does any `breakTypes`-style LUB remain?** Yes, in `hir/types.tcl`,
    unchanged, deliberately (see "Two-tier design" -- reused as-is, not for
    an unrelated construct, for the raw-IR-sourced case).
20. **Can two break sites widen a loop to `any`?** For a real Botlish
    program: no (both sites always contribute `unit`, which never widens).
    For a raw-IR-sourced program: yes, unchanged (exactly
    `bench/loop-count.ir`-style programs may still do this, deliberately).
21. **Can Return/Error affect the loop's ordinary result type?** No,
    unaffected by this milestone -- `return`'s own type flows into `ctx
    returnType`, entirely disjoint from `breakTypes`; propagating errors
    are similarly never folded in. Unchanged.
22. **Is there any new union-type behavior?** No. No union/variant
    machinery was added or touched.

## Required lowering questions (item 73)

23. **Does interpreter Break carry a language value?** Structurally yes
    (`core::completion::breaking {v}`); for any real Botlish program that
    value is always `unit`, never data derived from source.
24. **Does Tcl break lowering evaluate a payload expression?** For HIR from
    a real Botlish program: never (the value is always absent). For
    `fromIR`-sourced HIR: yes, unchanged, deliberately.
25. **Does native break lowering evaluate one?** Same answer as 24.
26. **Does countloop break still need a result-override path?** The code
    path still exists (see above) but is unreachable/a no-op for any real
    Botlish program: every value it could evaluate is now definitionally
    absent there.
27. **Does bare loop?** Same answer as 26.
28. **Does listloop still correctly finalize its prefix?** Yes, unchanged
    (RETURNING-ITERABLE-LOOPS.md's own mechanism, not touched by this
    milestone).
29. **Does discarded listloop still avoid output-list construction?** Yes,
    unchanged (same reason as 28).

## Required corpus questions (item 74)

30. **How many real `break VALUE` uses existed outside tests?** Two real,
    non-test Botlish (`.bot`) uses (`examples/surface/07-loop-break.bot`,
    `08-return.bot`), both migrated. Three real, non-test raw core-IR/HIR
    uses (`examples/02-loop-break.ir`, `examples/hir/05-control.hir`/`.ir`,
    `bench/loop-count.ir`), all deliberately left unchanged (two-tier
    design). `lib/*.bot` and `bench/*.bot`: zero.
31. **Which test cases depended on the old behavior?** See "Test
    migration" above for the full, itemized list (10 test files touched;
    ~20 individual test cases rewritten or replaced).
32. **Were any benchmark/source programs changed?** No benchmark
    (`bench/*.ir`, `bench/*.bot`) was changed. Two documentation/example
    programs (`examples/surface/07-loop-break.bot`, `08-return.bot`) were.
33. **Are `list::any?`/`all?`/`none?`/`find` unchanged?** Yes, byte-for-byte
    (no `break` of any kind in their source).
34. **Are the existing `scan_while` and four stdlib `callvalue` sites
    unchanged?** Yes -- `web::emailish?`'s `scan_while` was never touched,
    and this milestone made no change anywhere near a `callvalue` site.

## Stop conditions actually triggered

- **Item 75 (real usage)**: triggered. Reported to the user before any
  production edit (see conversation), with the exact corpus findings above.
  The user's resolution -- the two-tier design, conditioned on it being
  "functionally dead from surface/HIR" and useful as `leave` scaffolding --
  is implemented and documented throughout this report.
- **Item 76 (hidden dependency)**: not triggered. No non-loop construct was
  found reusing the value-bearing Break completion as a general nonlocal-
  result mechanism; `core::completion::breaking`'s value slot exists solely
  for the Tcl `-code break` protocol boundary, which is loop-break-specific
  by construction (Tcl reserves code 3 for `break`).
- **Item 77 (type architecture)**: not triggered. No union type or new
  generic completion-type system was introduced; the type-system machinery
  left in place is the same `lub`-based mechanism that already existed
  before this milestone, not a new one.

## Success condition (item 78), checked against what was actually built

1. `break` accepts no operand **at the surface level**, unconditionally --
   yes.
2. No loop-specific exception to that rule, **at the surface level** -- yes
   (the parser's own rejection is loop-kind-agnostic; the one remaining
   loop-kind-specific check, `LISTLOOP-BREAK-VALUE`, is now unreachable
   from any surface program and was left in place only for the
   below-parser tier, where it was already correct and untouched).
3. Every loop form has one intrinsic ordinary result type -- yes, for any
   real Botlish program (verified by the type-system questions above).
4. Natural exhaustion and bare-break exits agree wherever both exist --
   yes, unchanged (countloop: `unit`/`unit`; listloop: `List[T]`/`List[T]`;
   bare loop has no natural-exhaustion path to compare against).
5. Listloop still returns its collected prefix on break -- yes, unchanged.
6. Bare/count loops no longer support result override through break, **for
   any real Botlish program** -- yes. (Not true for the deliberately-
   preserved raw-IR tier, by design.)
7. Loop type inference no longer *observably* joins break payload types for
   any real Botlish program -- yes; the underlying machinery that could
   still do so for a raw-IR-sourced program was kept, by explicit user
   decision.
8. Internal Break representation is payload-free "as far down the pipeline
   as practical" -- reinterpreted, by explicit user decision, as "as far
   down the pipeline as the surface language can ever reach": the surface
   parser is the actual practical boundary here, given the real, load-
   bearing content the corpus search found below it.
9. Interpreter/Tcl-compile/native lowering contain no valid break-payload
   evaluation path **reachable from a real Botlish program** -- yes. They
   do still contain one reachable from `fromIR`-sourced raw IR, by design.
10. Nested-loop targeting remains correct -- yes, untouched and re-tested.
11. No new syntax (`leave`, intermediate loops, etc.) was introduced --
    confirmed, none.
12. Counted-loop collection semantics are deliberately unchanged --
    confirmed.
13. Existing list stdlib higher-order helpers remain unchanged and
    unoptimized -- confirmed.
14. Canonical compiler benchmarks remain stable -- confirmed, and this is
    the entire reason the two-tier design exists rather than the
    milestone's own literal default.
15. Focused GC stress passes -- see results above.
16. Full ordinary regression passes -- see results above.
17. The tree is ready to return immediately to realistic higher-order
    compiler-dogfooding workloads -- yes.
