# Diagnostic recovery and method-resolution correctness

The first black-box 15-puzzle workload (`mwagner-webdev/botlish-15-puzzle`,
its `surprise-log.md` and `REPORT.md`) succeeded, but its most expensive
compiler behaviors were diagnostic ones: a failed method call that became a
silent `any` and surfaced as a type error somewhere else (S13), a compiler
that reported one error per run (S4, S15), and one malformed construct
reported as a chain of follow-on errors (S17). This milestone changes how the
compiler fails, in exactly those three areas, under one rule:

> More independent errors; fewer dependent errors.

No language feature, stdlib operation, proof, warning, import rule, method
rule or backend behavior was added or changed. A valid program compiles to
the same HIR, runs the same way and warns the same way (section 9). Every
program that was rejected is still rejected; what changed is what it is told.

| | before | after |
|---|---|---|
| failed method sugar (S13) | typed `any`; reported, if at all, as a TYPE error at the function result or at a parameter, alone | poison; the missing import is MISSING-IMPORT at the method name, the same diagnostic the explicit spelling gets; nothing restates it |
| independent errors (S15) | a strict compilation raised the first diagnostic; a resolution failure stopped it before any check ran | every independent diagnostic, in one error and one compilation, past resolution failures |
| a call's unhandled errors (S4) | one diagnostic per error, and only the first raised | one diagnostic per call naming the whole set |
| a malformed construct (S17) | the parser's error plus the lexer's bracket guesses and the dangling clauses: four errors | one |
| the corpus (section 8) | first compilation: 12 of 29 known primaries, 10 cascades; 27 compilations to see every primary | 29 of 29, no cascade; 14 compilations (one per file) |

## Contents

1. [Part A: failed method resolution never becomes `any`](#1-part-a-failed-method-resolution-never-becomes-any)
2. [Poison](#2-poison)
3. [Part B: independent errors in one compilation](#3-part-b-independent-errors-in-one-compilation)
4. [Complete unhandled error sets](#4-complete-unhandled-error-sets)
5. [Part C: parser synchronization](#5-part-c-parser-synchronization)
6. [Static compile](#6-static-compile)
7. [The `any` audit](#7-the-any-audit)
8. [Diagnostic-efficiency corpus](#8-diagnostic-efficiency-corpus)
9. [Valid programs, isolation, interchange, backends](#9-valid-programs-isolation-interchange-backends)
10. [Tests that changed, and why](#10-tests-that-changed-and-why)
11. [Performance](#11-performance)
12. [What is not done](#12-what-is-not-done)
13. [What to run when changing this](#13-what-to-run-when-changing-this)

## 1. Part A: failed method resolution never becomes `any`

### Root cause

`receiver.name(args)` is method sugar for `name(receiver, args)` when a
function `name` is visible (METHOD-SUGAR.md). When none is, the written form
keeps its older meaning: a call of the *field* `name` of the receiver.
`hir/resolve.tcl` builds `call (project receiver name) args` and marks the
projection `methodCallee 1` -- for diagnostics only.

The old path for `s.concat("ab")` with `s : str` and no `import std::str`:

1. `hir::types::Project` typed the projection: the receiver is no struct, so
   it returned `any`.
2. `hir::types::Call` typed the call of an `any` callee: `any`.
3. `hir::range::verifyDeclaredResults` -- the first check `hir::CheckOnce`
   runs -- found the function's result `any`, which does not prove `str`:
   TYPE "function result does not prove declared type str", at the function.
4. `hir::structs::verify`, later in the same pass, reported the projection
   (NOT-A-STRUCT, with a hint that `std::str::concat` exists).
5. A strict compilation raised the first diagnostic: step 3's.

So the programmer was told the result type was wrong, at the function head,
and nothing else. Passed to a `str` parameter instead (S13's second shape),
the `any` failed that parameter's check: "argument ... cannot be proven to
satisfy str (argument type: any)". The explicit spelling `std::str::concat(s,
"ab")` meanwhile got the loader's "namespace "std::str" is not imported; add
`import std::str`".

### The new path

* The projection's failure is definitional -- NOT-A-STRUCT, UNKNOWN-FIELD
  and OPAQUE-REPRESENTATION hold in every context (hir/structs.tcl) -- so
  `hir::types::Project` makes it *poison* (section 2): typed `never`, the
  bottom type, without being a divergence. The call of a poisoned callee is
  poison too, and the function's result is poison: there is no result left
  to hold to `-> str`.
* `hir::structs::ProjectionProblem`, for a `methodCallee` projection whose
  failure is definitional, asks `UnimportedCandidates`: the functions of
  that name the call would apply if their namespace were imported -- by
  method resolution's own rules (`MethodCandidates`,
  `hir::methods::NativeMismatch`): not imported by the code the call is in,
  not `nomethod`, of the call's arity (the receiver first), an intrinsic's
  first parameter of the receiver's kind. The candidates are the intrinsics
  of every namespace and the members of every module the compilation
  loaded (a module only some other file imports is known; a module nobody
  imports is never searched). When there are any, the diagnostic is
  MISSING-IMPORT at the method name, worded as the loader's:

      namespace "std::str" is not imported; add `import std::str` to use `std::str::concat`
      (the method-style call ".concat(...)" applies only a function visible
      by that name)

  When there is none -- a genuinely unknown method -- it stays the
  projection's own diagnostic (NOT-A-STRUCT, UNKNOWN-FIELD), now also
  poison. The hint no longer names a function the call would not apply:
  `s.empty?()` on a `str` used to suggest `import std::mutable_vector`.
* A generic function (`fn shout(s): s.concat("!")`) is typed `any` for `s`
  in its own analysis (an unproven field, which an instance may cure); the
  semantic instance for `s : str` finds the failure, poisons it, and its
  call is poison in the caller (`hir::semantic::PoisonedCall`). The
  instance's problem is reported at that call with the explicit spelling's
  kind: `call to shout with s : str is invalid: namespace "std::str" is not
  imported...` (MISSING-IMPORT).

No import is implied. The call is rejected; the diagnostic names what is
missing, as the explicit spelling's does, and `static compile:` reifies
both as `std::compiler::DiagnosticCode::MissingImport`. Ambiguity is unchanged
(two imported functions that accept the receiver are still
AMBIGUOUS-METHOD-CALL); a callable field called with method syntax is still
the field's call.

Before and after (the S13 reduction, r7.bot):

    before: error: program.bot:3:5: function result does not prove declared type str (CORE SEMANTIC TYPE)
    after:  error: program.bot:4:7: namespace "std::str" is not imported; add `import std::str` to use `std::str::concat` (the method-style call ".concat(...)" applies only a function visible by that name) (CORE SEMANTIC MISSING-IMPORT)

Each use of a missing import is reported where it is written, in both
spellings: two calls are two diagnostics. (A first version reported a
missing import once per file and namespace. The static-decisions CI
comparison rejected it: one `static compile:` block's diagnostic then
depended on whether another block used the same namespace, and the batched
scheduler mispredicted a build in `imports-unimported.bot` and
`methods-list-without-str.bot`.)

## 2. Poison

The compiler already had one recovery placeholder: an unresolved reference
is typed `never` (and the completion and range analyses treat it as never
completing). `never` suppresses every mismatch -- it is admissible
everywhere and carries nothing -- but it is also a divergence: what follows
it is unreachable, and unreachable code is not checked. Used for a failed
projection, it would hide the next statement's independent errors, and a
second failed call in the same argument list.

Poison is `never` minus the divergence (hir/types.tcl, "Poison"):

* typed `never` and recorded in HIR's `poisoned` side table (ExprIds, and
  the BindingIds a poisoned value is bound to);
* `hir::types::Halts` is the divergence test every composite now asks:
  `never` and not poison. A sequence, a call's arguments and a construction
  stay reachable after a poisoned child; a poisoned `if` condition leaves
  both branches reachable and undecided;
* it spreads through what consumes the value: a call with a poisoned callee
  or argument, a bind (its binding, so every reference), an anonymous
  struct, a projection, a sequence ending in it, a loop over a poisoned
  iterable (its element binding), a block whose every normal completion is
  poison (its calls are poison, never a divergence of the caller), a handled
  call;
* two checks that hold a value to a declared boundary skip it explicitly,
  because `never` is not admitted at an aggregate one (a pre-existing
  quirk this milestone does not change: `fn f() -> List[int] errors E: fail
  E` is still rejected): `verifyDeclaredResults` (a poisoned function
  result) and the argument checks (`VerifyCall`, `VerifyStructuralCall`).
  A method-style call whose receiver is poison decides nothing
  (`DecideMethodCalls`).

Poison exists only where its diagnostic does: only reachable code (a
failing projection in dead code is typed `any`, as before, and reported
nowhere), only semantic inference (region inference keeps `never`: such a
call always raises there), and only source programs -- a program read from
core IR text has lost its declarations (a coroutine's `resume` type), so a
failure its weaker types show is no definitional one, and the lenient core
IR path runs such code. So a valid program's HIR has no `poisoned` table
(`dr-poison-valid-program-absent`), and `hir::types::show` never prints it:
it is recovery state, not a type.

No backend compiles it either. A strict compilation raises, and a static
decision never runs its builds, but a lenient one (`-strict 0`, the test
harness's) keeps its diagnostics and runs anyway, each a run-time error
where it is reached. Typed `never`, a poisoned expression would be a
divergence to a backend, and it is not one: the failed projection still
runs and raises, or completes -- with an opaque field's value, or with the
value of a handler whose type is inadmissible. So every backend entry point (`hir::lower`,
`core::compiler::compileHir`, `native::prepareHir`) compiles
`hir::recovery::runnable` of its HIR: a poisoned HIR is checked again
without poison (`unpoisoned`), typed exactly as before poison existed,
keeping its diagnostics, as `hir::check` already does when it demotes a
violated contract and `native::prepareHir` when it drops a violated
declared type (`dr-poison-lenient-run`; `proven-bounds.test`'s
`bounds-values-agree-unknown` found the first version wrong: `compile`
dropped the code after the handler, and native code trapped).

Poison is also what three other `any` stand-ins became (section 7): an
operation a trait does not declare (TRAIT-UNKNOWN-OPERATION), a handled call
whose handler has no type in common with it, and a semantic instance's
failed projection. A method-style call the decision rejects
(AMBIGUOUS-METHOD-CALL, NO-APPLICABLE-METHOD) became one later: the
reported program resolves it to no candidate, its written callee poison,
so nothing of the placeholder candidate it stood at during the decision is
reported (METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md).

## 3. Part B: independent errors in one compilation

### How diagnostics were short-circuited

HIR has always collected diagnostics as data (`hir::Diagnose`); the checks
of `hir::CheckOnce` run to completion. Three things cut a compilation short:

1. The strict boundary (`surface::lower::Finish`, `hir::BuildSyntax`)
   raised the first diagnostic and dropped the rest.
2. The source frontend built with `-halt-on-resolution-errors 1`: a program
   with an unbound name, an unknown type or error, a misplaced `break` was
   never checked at all ("nothing below runs on a HIR whose names are not
   all resolved").
3. The loader raised at its first rejected qualified reference.

### Where accumulation now occurs

* **The strict boundary** raises every diagnostic `hir::recovery::reported`
  keeps, as one error (`core::raiseDiagnostics`): the first one's error code
  and message -- exactly what a single-diagnostic program always raised --
  then a line `LOCATION: MESSAGE (CODE)` per further one, and the list as the
  return option `-diagnostics`. `main.tcl` prints each on a line of its own.
  The order is the build's, documented and deterministic: resolution
  diagnostics first (source order), then each check's, in the order
  `CheckOnce` runs them, each in its own walk; never a hash order (Tcl dicts
  keep insertion order). The first is the one static compile reifies
  (STATIC-COMPILE.md item 27): a strict compilation and a `static compile:`
  block agree on the primary.
* **Past resolution failures.** The source frontend no longer halts:
  `surface::modules::BuildProgram` checks a program whose resolution failed
  (the lenient `-strict 0` path always did; `hir::buildSyntax -strict 1` and
  core IR text still halt). `hir::BuildOnce` records the resolution
  diagnostics (`resolutionDiagnostics`, recovery bookkeeping of a rejected
  program only), and `hir/recovery.tcl` decides what the checks may add: a
  *unit* -- one top-level expression of the program or of a module section
  (a function declaration, a statement) -- is *tainted* when a resolution
  diagnostic is located in it or when it refers to a binding a tainted unit
  declares, transitively (a fixpoint: `mutual:` groups refer forward). The
  check diagnostics of tainted units are dependent and not reported.
* **Within the checks**, the phase that rejects an expression owns it: the
  ownership analysis's erasure of an argument (AFFINE-ERASURE-UNSUPPORTED)
  is not reported when an earlier check rejected that argument or the call's
  form (`p + 1` with a C pointer `p`, a call of a C function pointer).
  Obligations a valid call may still carry (an unhandled error, a missing
  context: `hir::MethodObligationKinds`) do not reject it.
* **One written destructuring is one error**: a pattern whose source is no
  struct, or an opaque one, reports its first field
  (`hir::structs::SynthesizedReceiver`: the projections of a binding the front
  end synthesized), while two written projections are two sites and two
  diagnostics.
* **The loader** checks every qualified reference of every file it loads and
  raises them together once the program is loaded
  (`RaiseReferenceErrors`), each module before the file importing it, each
  file's in source order.

Declaration-header failures stay where they were: a struct, enum, error,
trait, layout or type declaration the registries cannot establish is raised
at once, because the registries name each other in a fixed order and no
later declaration can be analyzed without the earlier. A file with loader
errors is not checked further either: its references cannot be resolved.

Before and after (three independent errors of three kinds in one module):

    before: error: program.bot:5:9: unbound name "offset" (CORE SEMANTIC UNBOUND)
    after:  error: program.bot:5:9: unbound name "offset" (CORE SEMANTIC UNBOUND)
            error: program.bot:7:10: function result does not prove declared type str (CORE SEMANTIC TYPE)
            error: program.bot:11:7: struct type Pair has no field "b" (known fields: a) (CORE SEMANTIC UNKNOWN-FIELD)

and the taint (an unknown result type, a function that uses it, an
independent one):

    fn parse(text: str) -> Board:      # unknown type: reported
        text
    fn render() -> str:                # its value comes from parse: tainted, not reported
        parse("x")
    fn score(n: int) -> str:           # independent: reported
        n

## 4. Complete unhandled error sets

The completion analysis computes a call's effective errors as a set and
used to emit one UNHANDLED-ERROR per member; a strict compilation showed the
first, and S4's programmer fixed the five errors of `from_cells` one per
compilation (then collapsed them into one error with an enum payload). The
four legality checks of `hir/completions.tcl` (an exact call, a call through
a structural type or a coroutine resume, an uncontracted callable, a native)
and the coroutine resume check of `hir/affine.tcl` now emit one diagnostic
per call naming the whole unhandled set, sorted (the canonical order of
every error set: `effectiveErrors`, a contract's `errors`). The single-error
wording is unchanged:

    this call may produce the declared error "B", which is neither handled here ...
    this call may produce the declared errors "A", "B" and "C", which are neither handled here ...

Propagation is unchanged: nothing is marked handled because something was
diagnosed. Handling one member leaves exactly the rest
(`dr-unhandled-set-remaining`). A rejected `static compile:` block carries
the whole set in its one CompilerError message.

`examples/stdlib/corpus.tcl`'s `corpus::driven` was itself a one-error-at-a-
time loop (it read one error name out of the rejection, added a handler and
compiled again); it now adds every named error at once.

## 5. Part C: parser synchronization

Recovery was already line-based: a statement that fails is an `error` node
and parsing resumes after its line and the block under it. What it did not
know is which other diagnostics its failure made. The demonstrated cascades,
and the rule that now removes each (surface/parser.tcl's `Independent`,
surface/lexer.tcl):

| shape | before | rule | after |
|---|---|---|---|
| S17: `x = "a".concat(if c:` ... `else:` ... `"n")` | `(` never closed; the if rule; `else` without `if`; unmatched `)` | a malformed construct (the region recovery skips, `Failed`) is one error: the lexer's bracket guesses inside it are its consequences; an `elif`/`else` right after a failed statement is part of it (neither starts a statement); the user's closer of a bracket the lexer force-closed is that bracket's, not unmatched | the if rule |
| `if c` (no colon) with `elif`/`else` clauses | the error, then each clause as a stray | as above | the error |
| `x = f(1 +` at the end of a line | `(` never closed; `expected an expression, found ""` | an error at a closer the lexer inserted is the bracket's consequence | `(` never closed |
| `x = 1 $ 2` | unexpected character; `expected end of line, found integer 2` | a skipped character is its construct's primary | unexpected character |
| `x = {a: (1}` | (strict: `}` does not match `(`) | an error at a token the lexer diagnosed itself is the lexer's | `}` does not match `(` |
| `f("abc)` | (strict: `(` never closed) | a bracket left open around an unterminated literal is the literal's consequence (the closer is inside it) | unterminated string |
| `fn broken(x: int -> int:` ... `struct Point:` | the header error; everything after it inside the parenthesis, unreported | a declaration line (`struct NAME`, `error NAME`, `type NAME`, `import`, ...) ends a bracket left open, like a statement line | the header error and the struct's own error |
| `struct Point:` / `    x int` | the field error; `expected an expression, found end of block` | a statement that fails inside its own block is skipped to that block's end | the field error |

Every rule is a grammar boundary or the lexer's own recovery, never a
comparison of messages: two malformed constructs the parser resynchronizes
between are two errors, two brackets each left open are two, and an `else`
after a statement that parsed is still an error of its own. A strict parse
(`surface::parse` without `-recover`) now raises what a recovering one
reports -- every independent syntax error, the first one's code -- where it
raised the lexer's first diagnostic, or the parser's first.

## 6. Static compile

The CompilerError of a rejected block is, as before, one diagnostic: the
block's first in the build that rejected it (STATIC-COMPILE.md item 27). It
is not extended to a list on purpose: which build rejects a block is the
scheduler's choice (STATIC-DECISION-ECONOMICS.md), and the decision economics
guarantee only the *first* diagnostic is scheduler-independent; a list of
every diagnostic would make an outcome depend on the scheduler, which is
forbidden. The new behavior reaches static compile where it is a diagnostic:
a failed method call reifies as `MissingImport` (as the explicit spelling's
deferred loader reference does), a grouped UNHANDLED-ERROR's message lists
the whole set, poison removes the TYPE cascade that could come first, and a
program with static sites reports all of its own independent diagnostics
(`dr-static-*`). Compatibility: a block that used to reify `NotAStruct` for
a missing import now reifies `MissingImport`, and one that reified a TYPE
cascade of an `any` now reifies its cause. The rounds still stop after
resolution (`Round ... 1`); only the final program is checked past it.

## 7. The `any` audit

Every place a member or method resolution failure, or its recovery, made an
`any`, classified:

| where | what | class | now |
|---|---|---|---|
| `Project`, receiver not a struct (NOT-A-STRUCT) | the S13 path | accidental semantic escape | poison |
| `Project`, struct without the field (UNKNOWN-FIELD) | `p.lenght` | accidental semantic escape | poison |
| `Project`, opaque receiver outside its owner | hid the field's type | recovery-only placeholder (deliberate: no representation leak) | poison: still nothing named, now nothing restated |
| `Project`, receiver of unknown struct type (UNPROVEN-FIELD) | a generic body's `x.f` | intentional language-level unknown: a semantic instance may cure it | kept |
| `Project` in unreachable code | no diagnostic there | intentional (nothing reported) | kept |
| `Project` in a semantic instance | `shout("hi")`'s instance | accidental escape into the caller | poison; the call is poison (`PoisonedCall`) |
| `hir::traits::TypeCall`, undeclared trait operation | "typed any as a stand-in" | recovery-only placeholder | the call is poison |
| `Handle`, a handler with no type in common with the call | the lub widened to `any` | recovery-only placeholder (the widening itself is a soundness measure for instances, kept) | poison in the generic walk |
| a call of an `any` callee | a dynamic field call | intentional (dynamic call) | kept |
| a call of a statically non-callable value (a C function pointer) | `cb(v)` | recovery-only placeholder, C FFI | kept (FFI is out of scope); the ownership fallout at its arguments is not reported (section 3) |
| unknown struct construction, unknown annotation type | resolution failures | recovery-only placeholders | kept; their dependents are tainted (section 3) |

## 8. Diagnostic-efficiency corpus

`audit/diagnostic-recovery/corpus/` holds 14 intentionally invalid
programs (a 15th, `method-rejections`, came with
METHOD-RESOLUTION-DIAGNOSTICS-MILESTONE-2.md: its two cascades were a
rejected method call's placeholder's), each with its known independent primaries (location, and a message
fragment where one site carries several), a line-preserving fix per primary,
and its known cascades. `audit/diagnostic-recovery/tools/efficiency.tcl`
compiles each as a programmer would -- with a checkout's `main.tcl`,
black-box -- and simulates the edit-compile loop: every primary a
compilation reports is fixed before the next; a compilation that reports
only fallout costs a round of investigation, after which the first open
primary is fixed (the 15-puzzle log's bisections). `results.txt` beside it
records both runs: before is commit `0531fc8`, the tree this milestone
started from.

| case | primaries | before: first compilation (diagnostics / primaries / cascades) | after | before: compilations | after |
|---|---:|---|---|---:|---:|
| app-modules | 3 | 1 / 1 / 0 | 3 / 3 / 0 | 3 | 1 |
| call-arguments | 3 | 1 / 0 / 1 | 3 / 3 / 0 | 3 | 1 |
| functions-independent | 3 | 1 / 1 / 0 | 3 / 3 / 0 | 3 | 1 |
| if-missing-colon | 2 | 4 / 2 / 2 | 2 / 2 / 0 | 1 | 1 |
| loader-references | 2 | 1 / 1 / 0 | 2 / 2 / 0 | 2 | 1 |
| mixed-phases | 3 | 1 / 1 / 0 | 3 / 3 / 0 | 3 | 1 |
| poisoned-binding | 2 | 1 / 1 / 0 | 2 / 2 / 0 | 2 | 1 |
| resolution-taint | 2 | 1 / 1 / 0 | 2 / 2 / 0 | 2 | 1 |
| s13-argument | 1 | 1 / 0 / 1 | 1 / 1 / 0 | 1 + bisection | 1 |
| s13-generic | 1 | 1 / 0 / 1 | 1 / 1 / 0 | 1 + bisection | 1 |
| s13-return | 1 | 1 / 0 / 1 | 1 / 1 / 0 | 1 + bisection | 1 |
| s17-if-operand | 2 | 5 / 2 / 3 | 2 / 2 / 0 | 1 | 1 |
| s4-unhandled-set | 3 | 1 / 1 / 0 | 1 / 3 / 0 | 3 | 1 |
| synthetic-closer | 1 | 2 / 1 / 1 | 1 / 1 / 0 | 1 | 1 |
| **total (14 files)** | **29** | **22 / 12 / 10** | **27 / 29 / 0** | **27** | **14** |

(The after run's 27 diagnostics carry 29 primaries: S4's three unhandled
errors are one diagnostic.) No case reports a diagnostic that is neither a
known primary nor a known cascade, before or after, and every case compiles
and runs once its primaries' fixes are applied. The before column's
"bisection" cases are those whose first compilation pointed at no primary
at all -- the S13 experience; the simulation charges them one compilation
and assumes the programmer then found the cause.

The corpus's reductions and where they come from: `s13-return` and
`s13-argument` are S13's two shapes (r7.bot and the parameter variant),
`s13-generic` the same through a generic function; `s4-unhandled-set` is
S4's construction failures; `s17-if-operand` is S17 (`"...".concat(if cond:
...)` across lines); `functions-independent`, `mixed-phases`,
`app-modules`, `loader-references`, `call-arguments`, `poisoned-binding` and
`resolution-taint` are the spec's required independent-error and cascade
shapes; `if-missing-colon` and `synthetic-closer` are parser cascades found
while auditing S17.

## 9. Valid programs, isolation, interchange, backends

**A valid program compiles to the same HIR.** Every corpus program
(`examples/`, `bench/`, every `stdlib/` module compiled standalone: 67) and
every golden suite (94) was compiled by the front end before (`0531fc8`)
and after, and the outcomes compared: for an accepted program `hir::format`'s
whole HIR text, its warnings and whether the HIR has any recovery state
(`poisoned`, `resolutionDiagnostics`); for a rejected one its error code.

* The 59 accepted corpus programs: identical HIR text and warnings. The 8
  rejected ones (the library modules that fail standalone, which the
  warning gate's manifest lists) fail with the same code.
* 78 golden suites: identical HIR text and warnings. The other 16 differ
  only in what a rejected `static compile:` block is replaced by -- the
  reified CompilerError's code, location and message: a grouped unhandled
  set (8 suites), MissingImport where NotAStruct was (7), and in
  `diagnostic-recovery.bot` the S13 blocks, whose first diagnostic used to
  be the TYPE cascade. No other node of any program differs.
* No accepted program's HIR has poison or recovery bookkeeping.
* The warning gate passes unchanged: 63 corpus programs, 21 library
  loaders, its 40 manifest entries.

**Tests.** Every Tcl test on interp and compile (`tests/local.tcl -all 1
-parts tcl`): 7867 and 7863 passed, none failed (3 and 7 skipped). Every
golden suite on every backend (`tests/local.tcl -parts golden`, 94 suites):
4726 tests on interp and on compile, 4634 on cranelift-generic and 4736 on
cranelift, none failed.

**Backends.** `audit/compilation-isolation/tools/interleave.tcl -print 1`,
run in both trees, checksums each of its ten suites' core IR, Tcl compiler
code, specialized and generic NIR and outcome on all four backends. Across
the trees every outcome is identical, and seven suites' artifacts are
byte-identical. Those of `errors.bot`, `declared-errors.bot` and
`representation.bot` differ only by their rejected blocks' messages (a
grouped unhandled set; `representation.bot`'s expectation of it changed
with it). No backend compiles poison (section 2).

**Isolation.** Recovery state is HIR side tables of a rejected HIR
(`poisoned`, `resolutionDiagnostics`, `unpoisoned`), never process state
(the loader's accumulation lives in its per-compilation state). Within each
tree `interleave.tcl` reports 80 artifacts and outcomes, 0 differ;
`tests/compilation-isolation.test` passes, and so does `dr-isolation` (a
rejected compilation between two builds of a valid program changes nothing).

**Interchange.** An invalid program never produces interchange text: `main.tcl
-emit-hir-interchange` of a rejected program prints every diagnostic,
exits 1 and writes no file (`dr-interchange-rejected`). `roundtrip.tcl -via
interchange` (90 artifacts and outcomes) and `-via cache` (100) report no
difference, and `tests/hir-interchange.test` and `tests/hir-cache.test` pass.

**Single executable.** `single/build.sh` (the pinned Tcl 9.0.1 base kit)
builds a 7.7 MB executable needing only glibc. Copied to a directory outside
the repository and run with nothing but HOME, PATH and the locale in its
environment:

    $ ./botlish s13.bot
       error: s13.bot:2:7: namespace "std::str" is not imported; add `import std::str` to use `std::str::concat` (the method-style call ".concat(...)" applies only a function visible by that name) (CORE SEMANTIC MISSING-IMPORT)
    $ ./botlish three.bot
       error: three.bot:5:9: unbound name "offset" (CORE SEMANTIC UNBOUND)
       error: three.bot:7:10: function result does not prove declared type str (CORE SEMANTIC TYPE)
       error: three.bot:11:7: struct type Pair has no field "b" (known fields: a) (CORE SEMANTIC UNKNOWN-FIELD)
    $ ./botlish s17.bot
       error: s17.bot:2:20: an "if" value must be the whole right side of "=" or "return" (SURFACE SYNTAX)
       error: s17.bot:9:8: expected an expression, found end of line (SURFACE SYNTAX)
    $ ./botlish cascade.bot
       error: cascade.bot:5:42: argument for parameter "n" cannot be proven to satisfy int (argument type: str) (CORE SEMANTIC TYPE)
       error: cascade.bot:5:17: cannot project field "trim_all" from a value of type str: ... (CORE SEMANTIC NOT-A-STRUCT)
       error: cascade.bot:5:32: namespace "std::list" is not imported; add `import std::list` to use `std::list::length` (...) (CORE SEMANTIC MISSING-IMPORT)
    $ ./botlish fixed.bot              # s13.bot with `import std::str`
       value: "qab"

(each rejected one exits 1; `fixed.bot` also runs on `-backend cranelift`).

**The audits AGENTS.md names for the code this touched**, all passing: the
fuzzers of static compile (seeds 1, 2), static decisions (seeds 17 and 41,
with the same statistics as before: seed 41 has two layout pairs that take
different rounds, as it had), error payloads (and `-fault unhandled`, `-fault wrong-namespace`),
structural contracts (and `-fault carrier`, `unknown`, `drop`), method
eligibility, SAME-FAILURE, traits, context traits, affine values,
coroutines, opaque structs and destructuring; the mutation harnesses of
diagnostic recovery (25 of 25 killed), error payloads (44), traits (20),
static compile (21), structural contracts (18), context traits (23),
compilation isolation (14), HIR interchange (27), affine values (29),
SAME-FAILURE (15), coroutines (52) and static decisions (73), all killed;
every one of the repository's 625 mutants still applies. The batched-against-sequential
static-decisions comparison runs in CI only (AGENTS.md). Its first run on
this branch found the scheduler disagreement section 1 describes (two uses
of one missing import merged into one diagnostic); on the fix, every suite
agrees under both schedulers (all six jobs of the `static-decisions`
workflow pass).

## 10. Tests that changed, and why

Every test whose expectation changed is in one of these classes; none was
updated mechanically.

* **The program has several independent errors** (now reported together):
  `dm-stale-fully-mediated` (the entry program's own marker is stale too),
  `ma-place-receiver` (the temporary receiver's call may also raise
  IndexNotFound, which the fix does not remove), `trait-witness-join-handled`
  (the handler's inadmissibility, which the test already asserted in the
  lenient HIR), `contexts-placement`'s fourth program (`g()` always fails: a
  KNOWN-ERROR of its own; its helper now reads the first diagnostic),
  `ca-imprint-same-path` (a pointer cannot be the program's result; the
  helper reads the first).
* **The diagnostic is now the explicit spelling's** (MISSING-IMPORT for a
  method call whose function's namespace is not imported):
  `method-not-visible-other-namespace-import`,
  `method-not-visible-no-type-import-needed-or-used` (once the type import
  loads the module), `method-alias-does-not-import`,
  `imports-non-transitive-methods`, `imports-method-requires-the-import` (it
  also checks the message names only `list`, not the namespaces whose
  function would not apply), `imports-cache-does-not-leak-importer-state`,
  `ns-method-requires-an-import` (the method and the qualified spelling now
  agree).
* **A cascade is no longer reported**: `opaque-no-fallout-types` (the TYPE
  error naming `any`), the opaque fuzzer's `nested`, `inner-through` and
  `no-fallout` expectations (UNPROVEN-FIELD and TYPE fallout of the
  rejected access), `ep-whole-binding-is-the-payload` and
  `ep-multiple-payload-errors` (the TYPE fallout of an unknown payload
  field), `trait-hidden-method-unavailable`,
  `trait-unknown-operation-is-the-cause`, `trait-witness-join-rejected`
  (the result join restating the body's), `parse-recover-elif`,
  `parse-recover-lexical`, `destructure-reject-list-source-message` and
  the destructuring fuzzer (one pattern, one error; it now compares the two
  spellings' primaries).
* **A call's unhandled errors are one diagnostic**: `errors-rejects-
  unhandled-at-top-level`, `errors-byte-from-int-unhandled-rejected`,
  `errors-generic-bounded-fixture`, `nerr-compiler-fixture`,
  `abi-numeric-conversion-failure-points-at-the-call`,
  `hoc-undeclared-through-helper`, `hoc-top-level` (their helpers now
  normalize a grouped message to its sorted names).
* **The tested design changed**: `sr-strict-stops-before-typing` and
  `me-nomethod-error-before-typing` pinned that a strict build never types
  a program that fails to resolve; they now pin that it does, and that
  nothing depending on the failure is reported.

Location-stripping helpers that matched `[^ ]*\.bot:L:C` ate the line break
between two diagnostics; they now stop at it.

Nine golden suites pinned the old diagnoses and changed as their Tcl
originals did (each test's fragment row in
`audit/golden/migration/fragments/` says what it now pins):
`callable-contracts.bot` (three unhandled sets), `representation.bot` (the
conversion's two bounds in one diagnostic), and `imports-unimported.bot`,
`imports-library-modules.bot`, `methods-byte-without-list.bot`,
`methods-list-without-str.bot`, `methods-type-import-only.bot`,
`stdlib-namespaces-unimported.bot` and `stdlib-namespaces-str-only.bot`
(MissingImport for a method call). One port lost strength:
`method-not-visible-module-function/method`. The framework's own imports
load `list`, so in a suite `[1, 2, 3].any?(big)` is the missing import of
`list`, while the Tcl program, which loads no `list`, still gets
NOT-A-STRUCT (section 12). Its row is now `weaker`, and the Tcl test runs
locally again (it is no longer a frozen duplicate).

`diagnostic-recovery.bot` (four tests) and `diagnostic-recovery-imported.bot`
(one) port the five tests of `tests/diagnostic-recovery.test` a block can
express: the codes and whole messages blocks reify for a missing import in
both spellings and for an unhandled set, the callable field, and the S13
program with its import. The other 46 are classified in
`audit/golden/migration/census/diagnostic-recovery.tsv`: they observe the
whole set of diagnostics a rejected compilation reports (a block reifies its
first), syntax recovery, several files or programs, HIR internals,
main.tcl, or a rejected program's lenient run. The manifest is regenerated (`merge.tcl`), and both new suites
pass `audit/golden/tools/perturb.tcl`.

## 11. Performance

`audit/diagnostic-recovery/tools/timing.tcl` compiles each program with one
tree's strict front end (warnings off, no cache) and takes the median wall
time. The trees were measured alternately, six times each (three
compilations per measurement, after a warm-up), with nothing else running:

| program | before (ms) | after (ms) | change |
|---|---:|---:|---:|
| `examples/games/2048/golden.bot` (3 static decision builds) | 10103 | 10429 | +3.2% |
| `examples/games/2048/demo.bot` | 1977 | 1939 | -1.9% |
| `examples/stdlib/csv.bot` | 186 | 212 | +14.3% |
| `tests/golden/values.bot` | 5540 | 5435 | -1.9% |
| corpus `mixed-phases` (rejected) | 6.6 | 9.3 | +2.7 ms |
| corpus `s4-unhandled-set` (rejected) | 18.6 | 18.0 | -0.6 ms |
| corpus `s17-if-operand` (rejected, syntax) | 1.8 | 3.4 | +1.6 ms |

On this machine the noise is 5 to 15 percent: an earlier alternation, made
before two hot-path guards in `hir/types.tcl` (`Halts` and the dead-call
type only for a `never`), measured `csv.bot` at -10.7% and the 2048 suite at
+4.9%. A per-phase profile of the 2048 suite (three compilations per tree,
twice) puts its whole front end at 10.97 s and 10.59 s before and 10.69 s
and 9.75 s after. Type inference and the checks are no slower; the lexer's
recovery bookkeeping (the structural, skipped and synthetic tokens) costs
30 to 60 ms of its 0.25 to 0.3 s. A valid program's compilation time is
therefore unchanged within the measurement's noise. A rejected program takes
a few milliseconds more: it is now checked past its resolution failures, and
the parser works out which syntax errors are independent. Static decisions
take the same number of builds (the 2048 suite: 3 rounds and 3 builds, before
and after). No build pays for lenient-run recovery:
`hir::recovery::runnable` runs only at a backend entry point, only for a
HIR with poison.

## 12. What is not done

* Declaration-registry failures (a struct, enum, error, trait, layout or
  type declaration) still stop the compilation at the first (section 3).
* A file with loader errors is not checked further.
* The contract-boundary TYPE diagnostics of `hir::completions::ReportOutside`
  (a callable used at a structural type that does not declare an error it
  may raise) are one per error: all now reported, not grouped.
* C FFI stand-ins (a failed imprint's `cptr`, a call of a C function
  pointer's `any`) are left as they are (C FFI behavior is outside this
  milestone); only the ownership fallout at a rejected argument is not
  reported.
* `never` is still not admitted at a declared aggregate boundary (section
  2): changing it would accept programs that are rejected today.
* Found, not fixed: a lenient run of a program that reads an opaque field
  outside its owner is a NATIVE BUG on `cranelift` (the specialized
  lowering), before this milestone as after it; `dr-poison-lenient-run`
  leaves that backend out for that program.
* A method call's missing import is found among the intrinsics and the
  modules the compilation loaded. A standard module nothing imports is not
  read for a diagnostic: reading it would make a rejected block's reified
  message depend on a file outside the program's dependencies, which the
  front-end cache would then have to track. Such a call keeps NOT-A-STRUCT
  with the visibility hint (`method-not-visible-module-function`'s
  `[1, 2, 3].any?(big)` in a program that loads no `list`).

## 13. What to run when changing this

If you change poison (`hir/types.tcl`, "Poison", and its uses in
`hir/range.tcl`, `hir/structs.tcl`, `hir/semantic.tcl`, `hir/hir.tcl`'s
method decisions), the missing-import diagnosis of method syntax
(`hir/structs.tcl`'s `ProjectionProblem`, `UnimportedCandidates`), the
grouped unhandled sets (`hir/completions.tcl`'s `Unhandled`), the reported
set (`hir/recovery.tcl`), the strict boundaries (`surface::lower::Finish`,
`hir::BuildSyntax`, `core::raiseDiagnostics`), the loader's accumulation or
the parser's and lexer's recovery, run `tests/diagnostic-recovery.test`,
`audit/diagnostic-recovery/tools/mutate.tcl` (every mutant in its
`mutants.txt` must still apply and be killed) and
`audit/diagnostic-recovery/tools/efficiency.tcl` (every case: all primaries
in the first compilation, no cascade, clean once fixed; regenerate
`results.txt` with `-root` on the tree before a change that moves a
number).
