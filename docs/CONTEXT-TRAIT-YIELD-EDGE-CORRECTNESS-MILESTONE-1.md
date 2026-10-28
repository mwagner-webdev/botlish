# Context-trait yield-edge correctness, milestone 1

A narrow compiler-correctness milestone. The event-loop exploration
(EVENT-LOOP-EXPLORATION.md, section 12) found that the coroutine analysis can
take a context-trait operation for an unrelated yielding function that has
the same name in the trait's module. This milestone fixes that defect and the
mechanism behind it. It does not touch the event loop itself, affine resource
lifetimes or drop actions.

The invariant this milestone establishes:

> Every semantic analysis of a call uses the function or operation the
> compiler actually resolved. No other declaration gains influence over a
> call by sharing its name.

## Contents

1. [Result](#1-result)
2. [Reproduction](#2-reproduction)
3. [Root cause](#3-root-cause)
4. [Correction](#4-correction)
5. [Regression coverage](#5-regression-coverage)
6. [Cross-analysis audit](#6-cross-analysis-audit)
7. [Event-loop validation](#7-event-loop-validation)
8. [Testing evidence](#8-testing-evidence)
9. [Remaining limitations](#9-remaining-limitations)

---

## 1. Result

**Fixed.** `audit/event-loop/repro/trait-op-yield-edge/app.bot` compiles under
`-warnings error` and evaluates to 5, the trait implementation's value. A
trait operation no longer takes a visible function of its name as its
callee in any of these places:

* the coroutine call graph, its resume protocols and its coroutine roots;
* the `UNWRAPPED-YIELD` check of top-level calls;
* the context requirements of top-level calls;
* and, for context-trait operations, the call's flags, variadic collection
  and `nomethod` rule.

Each of these takes its information from the operation, and through the
operation from its implementation. Genuine yields still propagate and are
still reported: a direct or method-syntax call of the yielding function, a
wrapper of one, and a selected implementation that yields.

The original driver names now work too. `audit/event-loop/tools/original-names.tcl`
renames the scheduler's `Driver` operations back to `now` and `wait`. Those
names sit beside evloop's own `now`, which requires the Loop context, and its
yielding `wait`. Every deterministic scenario produces the same trace under
either name, on all four backends.

Two related defects remain, both specific to ordinary (value) traits; they
are recorded in [section 9](#9-remaining-limitations). The first: a visible
function's flags or variadic parameter can still distort an ordinary trait
operation's call. The second: the compiler service's definition and
references facts still name the visible function.

## 2. Reproduction

The reduced program from the exploration (`audit/event-loop/repro/trait-op-yield-edge/`):

```
# m.bot
struct Reg:
    slot: int

context trait Driver:
    fn wait(deadline: int) -> int

fn wait(reg: Reg) -> int:
    yield reg.slot
    1

fn run(context d: Driver) -> int:
    d.wait(5)

# impl.bot
opaque context struct D:
    x: int

fn create() -> D:
    D {x: 0}

fn wait(deadline: int, context d: D) -> int:
    deadline

# app.bot
import m
import impl
with context impl::create()
m::run()
```

Before the fix (commit `cf668038`):

```
$ tclsh9.0 main.tcl audit/event-loop/repro/trait-op-yield-edge/app.bot
== app.bot (interp)
   error: audit/event-loop/repro/trait-op-yield-edge/app.bot:4:1: m::run may suspend, but this call does not start a coroutine (start it with "coroutine {step, first} = m::run(...)", or call it from a function that runs inside a coroutine):
    m::run, which calls m::wait at .../m.bot:18:5
     -> m::wait, which yields directly at .../m.bot:14:5 (CORE SEMANTIC UNWRAPPED-YIELD)
```

After the fix:

```
$ tclsh9.0 main.tcl -warnings error audit/event-loop/repro/trait-op-yield-edge/app.bot
== app.bot (interp)
   value: 5
```

The HIR of the checked build, before the fix (`surface::readProgramFile
... -strict 0`; e14 is `d.wait(5)`):

```
e14 call  method {name wait ...}  traitCall {trait m::Driver requirement wait ... shape candidate context 1}  target {}
e15 ref   name m::wait  binding b1          <- the call's callee
hir::contexts::Callee e14 = e2              <- m::wait's block
```

Typing knew that `e14` was the trait's operation and recorded `traitCall`.
It typed the callee as the requirement's contract and gave the call no
`target`. The callee expression itself, however, was still a reference to
`m::wait`.

## 3. Root cause

The defect is a placeholder callee that several analyses read as the
resolved callee. It is not specific to `wait`.

1. **Resolution chooses a callee before the receiver's type is known.**
   `receiver.op(args)` is method syntax. When a function `op` is visible --
   declared lexically or imported -- `hir/resolve.tcl` resolves the call to
   the ordinary call `op(receiver, args)`: its callee becomes a `ref` to that
   function, recorded as `method`. It also applies that function's call
   shape: its flags (`hir::flags::ResolveCall`), its variadic collection
   (`hir::variadic::Arguments`) and its `nomethod` rule. When no such
   function is visible, the call stays the call of the projection
   `receiver.op`.

2. **Typing then decides that the call is a trait operation.** In
   `hir::traits::TypeCall`, a receiver whose static type is a trait view,
   or a context-trait binding, makes the call the trait's operation
   (TRAITS.md, "Trait operations"). The trait declaration is authoritative,
   and the method-candidate rule is not consulted. TypeCall records
   `traitCall`, types the callee as the requirement's contract and leaves
   `target` empty. The operation's implementation, the witness's or the
   selected context's, is bound only in the monomorphized program (build
   2), where the call becomes a direct call of it.

3. **The callee expression keeps the placeholder.** After typing, the call
   still holds a `ref` to the visible function. The analyses that ask
   "which block does this call call?" use the shared function
   `hir::contexts::Callee`, which reads the callee `ref` first. Of its
   callers, only the per-function edge loop of `hir::contexts::verify`
   skipped trait calls, with its own guard. `hir/direct.tcl`,
   `hir/cardinality.tcl` and `hir/resourceescape.tcl` check `traitCall`
   before they use `Callee`. No other caller did.

4. **The coroutine analysis runs before typing.** `hir::coroutines::analyze`
   infers resume protocols, which type every `yield`, so it runs before
   type inference. At that point no call has a `traitCall` record yet, so
   no guard could have helped. It built the edge `m::run -> m::wait`, which
   made `m::run` yield-capable. `hir::coroutines::verify` then derived "may
   yield" over that edge and reported `UNWRAPPED-YIELD` at the top-level
   call.

So the analysis did not look a name up again. The identity was lost earlier.
Resolution put a provisional candidate in the callee position. Typing later
decided that the call had no such callee. Every reader of the callee
position that came before typing, or that did not check `traitCall`, took
the provisional candidate for the resolved callee. The defect is the same
for ordinary traits (`s.area()` with a yielding `area` visible) and for
context traits. Its other symptoms (section 6) have the same cause.

## 4. Correction

Four changes, each localized:

1. **An operation on a context-trait binding consults no method candidate**
   (`hir::resolve::ContextTraitOperation`, `hir::contexts::TraitBinding`).
   The receiver `d` refers to a context-trait binding. Build 1 binds it to
   `context#load("T")`, and the binding's declaration states its trait.
   Such a call is the trait's operation whatever functions are visible.
   No candidate could be its valid ordinary call either, because a
   context-trait binding cannot be passed as a value (CONTEXT-TRAIT-MISUSE).
   So resolution leaves the call as the call of the projection `d.wait`,
   the form a trait operation already has when no function of its name is
   visible. Nothing downstream can then read a candidate, flags, a variadic
   collection or a `nomethod` rule from it.

   The receiver's binding is found by the lexical walk the reference itself
   uses (`LexicalTarget`). A rebinding of `d` is therefore not an operation
   on the context-trait binding.

   `CheckTraitBindings` now uses the same `TraitBinding`, so the two
   readings of what a context-trait binding is cannot diverge.

2. **`hir::contexts::Callee` returns no callee for a typed trait operation.**
   This is the shared identity function. Every analysis that runs after
   typing therefore gets "no exact callee" for an operation, whatever
   method syntax stood in: `hir::coroutines::verify`'s top-level check,
   `hir::contexts::verify`'s top-level requirements, `hir::affine`'s call
   consumer, `hir::mutvec`'s freshness and any future caller. The separate
   guard in `hir::contexts::verify` is now redundant and was removed, with
   its comment moved to `Callee`.

3. **The coroutine analysis is told which calls are trait operations**
   (`hir::check`, `hir::CheckWith`; `hir::coroutines::Target`, `Consulted`,
   `TraitOperations`). An ordinary trait operation's receiver may be a view
   that only typing establishes, for example `t = pick(s); t.area()`, so
   resolution cannot set it aside. The pre-typing analysis takes a set of
   calls to treat as operations. These calls are never edges, coroutine
   roots or use-site protocol constraints.

   The analysis records each method-style call whose written callee it
   read: a root, an edge into a yield-capable function, or a use-site
   constraint. After a check, `TraitOperations` returns the recorded calls
   that typing made trait operations. If that set differs from the one the
   analysis was given, `hir::check` checks again from the same input with
   that set.

   This converges on the second check. Whether a call is a trait operation
   depends on whether its receiver's static type is a view, and only a
   declared trait type makes a view (TRAITS.md, "Entering"). Protocols are
   structs, unit or any, so no protocol can make a receiver a view.
   `hir::check` fails with an internal error if the set has not settled
   after three checks.

   A program none of whose trait operations' written callees the analysis
   reads is checked once, as before. The second check happens only in the
   situation this milestone fixes.

4. **An unknown context-trait operation in the projection form reports only
   `TRAIT-UNKNOWN-OPERATION`** (`hir::traits::TypeCall`). Its callee is
   marked as a trait callee, as a known operation's already was, so the
   projection is not checked again as a field access. Before, the
   projection form also reported an `UNPROVEN-FIELD` that only restated the
   first diagnostic. Change 1 sends more calls to that form, for example
   `d.nope(5)` with a yielding `nope` visible, so this cascade would
   otherwise have replaced the spurious `UNWRAPPED-YIELD` with another
   spurious diagnostic.

None of this adds syntax, an annotation, a name-based exception or a
runtime change. Overload and method-resolution semantics are unchanged.
The method decision never decided a trait operation: it kept whatever
candidate a trait operation stood at (`TraitCallsDecided`). A context-trait
operation simply no longer enters the decision. The event-loop scheduler is
unchanged.

The selected implementation of a context-trait operation is still invisible
before monomorphization (COROUTINES.md, "Trait-implementation yields are
invisible before monomorphization"). Its yields reach the caller in build 2,
where the operation is a direct call of the implementation. This milestone
keeps that guarantee as it was and does not attempt selection before typing
([section 9](#9-remaining-limitations)).

## 5. Regression coverage

`tests/context-traits.test` (context traits; private modules `std::ty::drv`,
`sim`, `alt`, `ysim`):

| test | case |
|---|---|
| `ct-operation-identity-repro` | the committed reproduction itself, `-warnings error`, value 5 on interp and compile (its context struct's unbounded `int` field has no native context slot, CONTEXT-NATIVE-LOWERING-UNSUPPORTED, so the native backends run the same program with a bounded field in the next test) |
| `ct-operation-identity-unrelated-yield` | 1. the operation does not acquire the yield effect of a same-named yielding function of the trait's module; a wrapper calling the operation stays non-yielding (6); values through two different implementations, 4 backends |
| `ct-operation-identity-genuine-yield` | 2. the yielding function called directly or through a wrapper (6) is `UNWRAPPED-YIELD` at the top level and runs in a coroutine (`[7, 111]`); a function making both the operation and `reg.wait()` yields through the latter (`[3, 106]`), 4 backends |
| `ct-operation-identity-genuine-chain` | the `UNWRAPPED-YIELD` chain names the genuine call site (`drv.bot:24:17`, `reg.wait()`), never the operation |
| `ct-operation-identity-implementation-yield` | 3. a selected implementation that yields: the top-level call is `UNWRAPPED-YIELD` explained through `std::ty::ysim::wait`, never through `std::ty::drv::wait` (reported by the monomorphized program's check) |
| `ct-operation-identity-implementation-yield-limitation` | the recorded limitation: a coroutine whose only yield is the implementation's is `COROUTINE-RHS-NOT-YIELDING`, with and without the same-named function |
| `ct-operation-identity-order` | 4. three declaration orders of the module and two import orders, the same value on 4 backends |
| `ct-operation-identity-modules` | 5. a yielding `wait` in another module (an import candidate), beside a local one (two candidates), and in the entry program |
| `ct-operation-identity-call-shape` | a visible `wait` with flags, a variadic parameter, or `nomethod`: the operation is unaffected (before: `ARITY`, `CONTEXT-TRAIT-MISUSE` + `TYPE`, `NOMETHOD-CALL`) |
| `ct-operation-identity-rejections` | 7. an undeclared operation with a yielding function of its name visible is `TRAIT-UNKNOWN-OPERATION` alone; two installed implementations are `AMBIGUOUS-CONTEXT-IMPLEMENTATION` alone; none is `MISSING-CONTEXT` alone; passing the binding in an ordinary call of the yielding function is `CONTEXT-TRAIT-MISUSE` and, being a real call of it, `UNWRAPPED-YIELD` |
| `ct-operation-identity-hir` | the checked HIR: every operation has no `method` record, a field-shaped `traitCall`, a projection callee and no `Callee`; the yield-capable coroutine edges are exactly `both -> wait` (the genuine call), `deep -> poll`, `poll -> wait`; nothing set aside |

`tests/traits.test` (ordinary traits; private modules `std::shapes`,
`std::ysq`; the trait, an unrelated yielding `area` and the consumers in the
entry program):

| test | case |
|---|---|
| `trait-operation-identity-unrelated-yield` | 1 and 6 for ordinary traits, with three kinds of receiver: a declared trait parameter, a local that typing makes a view (`t = pick(s)`), and a top-level call's view result; 4 backends |
| `trait-operation-identity-context` | a visible `area` requiring an uninstalled context: no `MISSING-CONTEXT`, at the top level or in a function |
| `trait-operation-identity-genuine-yield` | 2: `reg.area()` beside `s.area()` keeps its effect; the chain names `<input>:28:16`; a coroutine runs it, 4 backends |
| `trait-operation-identity-implementation-yield` | 3: a witness's yielding implementation reaches the caller (monomorphized program), named; the recorded limitation for a coroutine |
| `trait-operation-identity-coroutine-root` | a trait operation is no coroutine root: `COROUTINE-RHS-NOT-YIELDING` from the checked program (before: an internal error from the monomorphized program) |
| `trait-operation-identity-set-aside` | the checked HIR sets aside exactly the three consulted operations, none of them an edge; a program whose visible function does not yield sets nothing aside (one check) |

The numbers 1-7 are the milestone brief's required cases. Case 3 (an
operation whose selected implementation genuinely yields) is covered twice:
the effect is never lost, and the documented limitation is pinned so that a
later fix has to change the test deliberately.

On the tree before the fix, 16 of the 17 tests fail. The one that passes is
`ct-operation-identity-genuine-yield`, which checks that a genuine yield is
preserved, and that was already true.

**Mutants.** Seven new mutants, each a reintroduction of a part of the defect:

| mutant | file | killed by |
|---|---|---|
| `operation-callee-is-candidate` (Callee reads the placeholder) | audit/traits | `trait-operation-identity-context`, `-unrelated-yield` |
| `operations-not-set-aside` (analyze ignores the set) | audit/traits | 5 `trait-operation-identity-*` tests |
| `check-not-repeated` (hir::check checks once) | audit/traits | 5 `trait-operation-identity-*` tests |
| `consulted-never-recorded` | audit/traits | 5 `trait-operation-identity-*` tests |
| `operation-consults-candidates` (resolution consults candidates for a context-trait receiver) | audit/context-traits | `ct-operation-identity-call-shape`, `-hir` |
| `operation-receiver-binding-unrecognized` (TraitBinding never) | audit/context-traits | `ct-one-way`, `ct-one-way-message`, `ct-operation-identity-*` |
| `unknown-operation-field-access` | audit/context-traits | `ct-operation-identity-rejections` |

The context-traits harness (`audit/context-traits/tools/mutate.tcl`) now
copies `audit/event-loop/repro` into its private tree, because
`ct-operation-identity-repro` compiles it. The module-privacy harness does
the same for its own reproductions. Without the copy, that test failed in
every private tree and "killed" every mutant trivially. That is exactly what
happened in the first run of the three context-trait mutants above, each of
which was also killed by a legitimate test.

Three existing static-decisions mutants that edit `hir::check`'s demotion
re-check now edit the same text in `hir::CheckWith`. They are
`recheck-rounds-across-checks`, `recheck-rounds-not-shared` and
`recheck-analysis-repeated`. Their text was re-indented, and the third
passes the analysis its set as well, so each remains a mutant of the same
rule.

## 6. Cross-analysis audit

Every consumer of a call's callee identity was inspected. Where a consumer
was suspect, the pristine tree and the fixed tree were compared on a probe
program.

| consumer | reads | before | now |
|---|---|---|---|
| `hir::coroutines::analyze` (edges, protocols, roots, use-site constraints) | `Callee`, before typing | **defect**: edge to the visible function (the reported bug, and the same for ordinary traits: `s.area()`, `t = pick(s); t.area()`); a coroutine whose right side is `s.area()` took the visible function as its root (rejected only by the monomorphized program, as an internal error) | set aside (changes 1, 3) |
| `hir::coroutines::verify`, top-level `UNWRAPPED-YIELD` | `Callee` | **defect**: `pick(make()).area()` at the top level, with a yielding `area` visible, was `UNWRAPPED-YIELD` | fixed (change 2) |
| `hir::coroutines::verify`, functions as values | `Denotes` of a `ref` | not affected: a callee `ref` is not "observed" | -- |
| `hir::coroutines::YieldUses` (use-site inference) | `Callee` | **defect**: a yield passed to an operation took the visible function's declared struct parameter as a constraint | set aside (change 3) |
| `hir::contexts::verify`, function edges | `Callee`, guarded | not affected (its own guard) | the guard is `Callee`'s |
| `hir::contexts::verify`, top-level requirements and selection | `Callee` | **defect**: a top-level `pick(make()).area()` acquired the context requirement of a visible `area`: `MISSING-CONTEXT` | fixed (change 2) |
| resolution: flags, variadic collection, `nomethod` | the chosen candidate | **defect**: `ARITY`; `CONTEXT-TRAIT-MISUSE` + `TYPE`; `NOMETHOD-CALL` | fixed for context traits (change 1); ordinary traits remain ([section 9](#9-remaining-limitations)) |
| method decision (`hir/methods.tcl`) | `traitCall` | trait operations already decided by their trait (`TraitCallsDecided`) | a context-trait operation no longer enters the decision |
| error effects (`hir::completions`) | `calleeErrors` from the requirement | not affected: an operation is charged its requirement's errors (a visible `wait` that always fails changes nothing, before and after) | -- |
| direct modules (`hir/direct.tcl`) | `traitCall` first | not affected: any implementation's module | -- |
| cardinality (`CallReach`) | `traitCall` first | not affected | -- |
| context-resource escape | skips `traitCall` | not affected | -- |
| static dependencies (`hir/staticdeps.tcl`) | `target` | not affected: an operation has no target (the coroutine graph now agrees with it) | -- |
| affine call consumer (`hir::affine::CallConsumer`) | `Callee` | read the visible function's declared parameters for an operation's argument; no observable difference found (three parameter shapes, a coroutine handle argument) | the operation's contract (change 2) |
| MutableVector freshness (`hir::mutvec::Fresh`) | `Callee` | read only by the elaboration, which runs on the monomorphized program (no operations): not observable | `Callee` (change 2) |
| compiler service (`service::at`, references) | the callee `ref`'s binding | **defect**: the operation's name had the visible function as its binding, definition and reference | fixed for context traits (the operation is the projection: "not a name", its hover the operation's contract); ordinary traits remain ([section 9](#9-remaining-limitations)) |

**Unrelated observation.** A coroutine binding whose right side never yields
is reported as `COROUTINE-RHS-NOT-YIELDING`, preceded by a `TYPE` diagnostic
on the enclosing function's declared result. For example, `fn start() ->
int: coroutine {step, first} = f(); first`, with `f` an ordinary function,
also reports "function result does not prove declared type int". The second
diagnostic follows from the first. This predates the milestone and is
unrelated to callee identity. Separately, the traits mutant
`runtime-wrapper` no longer applies to `hir/resolve.tcl`, at `cf668038` as
now ([section 8](#8-testing-evidence)).

## 7. Event-loop validation

The prototype still uses the `clock`/`block` workaround: its scheduler,
native drivers, benchmark programs and report all use those names. Renaming
them everywhere would change about a hundred lines of experimental
artifacts, the SDL3 and native-driver parts among them, which this
environment cannot fully validate. The brief allows keeping the names in
that case. The original names are instead checked directly:

* the reproduction (`repro/trait-op-yield-edge/`) passes on its own and is
  a permanent test (`ct-operation-identity-repro`);
* `audit/event-loop/tools/original-names.tcl` copies `src/` and renames the
  `Driver` operations back to `now` and `wait`. It renames the trait's
  requirements and every operation call in `evloop.bot`, and the
  deterministic driver's implementations in `simdrv.bot`, counting each
  replacement. The renamed operations sit beside evloop's own `now`, which
  requires `Loop`, and its yielding `wait`, the exact collision that
  produced the workaround. The tool requires every deterministic scenario
  (`a-*.bot`) to compile under `-warnings error` in both trees, to give one
  outcome on every backend, and to give the same trace under either name.

Results are in [section 8](#8-testing-evidence). The scheduler, its drivers
and its scenarios are unchanged. The report's section 12 and the
exploration's README record the fix and the tool.

## 8. Testing evidence

All commands were run on Linux x86-64 with Tcl 9.0.1 (the `.deb` packages
AGENTS.md pins), `LANG=C.utf8 LC_ALL=C.utf8`, and the native backend built
in release mode (rustc 1.97.0).

**Reproduction, before and after.** Section 2 has both outcomes:
`tclsh9.0 main.tcl audit/event-loop/repro/trait-op-yield-edge/app.bot` is
`UNWRAPPED-YIELD` at `cf668038` and evaluates to 5 now. With `-warnings
error` it is also 5.

**The new tests** (17):

```
tclsh9.0 tests/context-traits.test -match 'ct-operation-identity-*'    # 11 passed
tclsh9.0 tests/traits.test -match 'trait-operation-identity-*'         # 6 passed
```

The same two commands, run with the new test files on a worktree of
`cf668038`, fail 10 of 11 and 6 of 6.

**Baselines before the change** (`cf668038`): `tests/coroutines.test` 81/81,
`tests/context-traits.test` 40/40, `tests/traits.test` 78/78.

**The whole local suite** (`tclsh9.0 tests/local.tcl -jobs 3`: every Tcl
test file on interp and compile, golden duplicates skipped, and every golden
suite on four backends, through the front-end cache; 103 minutes from an
empty cache):

```
Tcl tests on interp    7507 passed, 1 failed, 101 skipped, 2276 golden duplicates skipped
Tcl tests on compile   7502 passed, 1 failed, 106 skipped, 2276 golden duplicates skipped
Golden suites: 109 run, 0 failed; tests passed: interp 5257/5257, compile 5257/5257,
               cranelift-generic 5165/5165, cranelift 5267/5267
```

The one failure on each backend was `static-economics.test`'s
`se-property-demotion-keeps-diagnostics`. That is a structural test that
reads `[info body hir::check]`, and the demotion re-check had moved into
`hir::CheckWith`. The test now reads `hir::CheckWith` and checks that
`hir::check` calls it. After that change, `tests/static-economics.test`
passes 87/87 on both interp and compile (`CORE_BACKEND=interp|compile`).

**Fuzzers** (each with 0 disagreements and 0 failures):

| command | programs |
|---|---|
| `audit/coroutines/tools/fuzz.tcl -seed 1`, `-seed 2`, `-seed 3` | 50 each |
| `audit/context-traits/tools/fuzz.tcl -seed 1`, `-seed 2` | 50 each |
| `audit/traits/tools/fuzz.tcl -seed 1`, `-seed 2` | 100 each |
| `audit/direct-modules/tools/fuzz.tcl -seed 1`, `-seed 2` | 60 each |
| `audit/static-decisions/tools/fuzz.tcl -seed 17`, `-seed 41` | 20 each (484 and 564 static sites) |
| `audit/method-eligible/tools/fuzz.tcl 40 1` | 40 seeds, 184 of 184 round trips |
| `audit/affine/tools/fuzz.tcl -seed 1` | 30 |

`static-decisions` seed 41 reports "layout pairs taking different rounds:
2". The tree before the change prints the identical report for that seed.

**Event loop.** `tclsh9.0 audit/event-loop/tools/original-names.tcl`
reported PASS with 44 checks: 6 replacements counted, the two collisions
present, and for each of the 12 deterministic scenarios one outcome per
tree on 4 backends and the same trace under either name. The same tool,
run on a worktree of `cf668038`, fails on `a-smoke` with the original bug
in the full scheduler:

```
a-smoke.bot:26:1: main may suspend, but this call does not start a coroutine ...
    main, which calls evloop::run at a-smoke.bot:21:5
     -> evloop::run, which calls evloop::wait at evloop.bot:1026:21
     -> evloop::wait, which yields directly at evloop.bot:668:5
```

**Mutation.**

* `audit/traits/tools/mutate.tcl -only operation-callee-is-candidate,operations-not-set-aside,check-not-repeated,consulted-never-recorded`:
  4 mutants, 4 killed.
* `audit/context-traits/tools/mutate.tcl -only 'operation-*,unknown-operation-field-access'`
  (after the harness copies `audit/event-loop/repro`): 3 mutants, 3
  killed.
* `audit/static-decisions/tools/mutate.tcl -only recheck-rounds-across-checks,recheck-rounds-not-shared,recheck-analysis-repeated`
  (the three re-anchored mutants): 3 mutants, 3 killed.
* The whole of `audit/traits/tools/mutate.tcl`: 24 mutants, 23 killed, 0
  survived, 1 not applied. The one not applied is `runtime-wrapper`, whose
  `hir/resolve.tcl` text no longer occurs. It is equally "not applied" at
  `cf668038` and edits code this milestone does not touch: a pre-existing
  staleness, recorded here and not fixed.
* The whole of `audit/context-traits/tools/mutate.tcl`: 59 mutants, 44
  killed, 0 survived, 15 skipped. The skipped ones are the `darwin-*` and
  `windows-*` mutants, whose killing tests run on macOS or Windows only.
  The repro test is now in the harness's tree and kills none of them
  spuriously.
* `audit/coroutines/tools/mutate.tcl -only call-crosses-yield,context-reselected-per-resume,effect-one-caller,handle-as-fn,protocol-widened-any,scalar-resume-accepted,two-protocols-accepted`
  (every coroutine mutant that edits `hir/coroutines.tcl`,
  `hir/contexts.tcl`, `hir/resolve.tcl` or `hir/types.tcl`): 7 mutants, 7
  killed.
* Every edit of every `audit/*/mutants.txt` was checked with a script that
  counts each replaced text's occurrences: the set of edits that do not
  apply exactly once is the same as at `cf668038`. The exceptions are
  multi-edit mutants whose later edit applies to an earlier edit's result,
  and the hash-table audit's relative paths. No mutant text of this
  milestone's files was left behind.

**HIR interchange and cache.** `audit/hir-interchange/tools/roundtrip.tcl
-via interchange` reported 12 suites and 108 artifacts and outcomes, 0
differ. With `-via cache` it reported 12 suites and 120, 0 differ. These
cover the coroutine table's new `operations` and `consulted` keys, which
the interchange carries.

**Method resolution.** `audit/method-resolution/tools/oracle.tcl 200 1`
reported 1128 calls with 0 disagreements. `... 200 1 -contexts 1` reported
1202 calls, 18 of them rejected by an obligation, with 0 disagreements.

**Not run here.** These need hosts or schedules this environment does not
have:

* the static-decisions sequential comparison
  (`audit/static-decisions/tools/compare.tcl`), which AGENTS.md reserves for
  CI;
* macOS and Windows, and Linux AArch64;
* GC stress: the change emits no native code and changes no runtime.

The SDL3 and native-driver parts of the event-loop checks were not run:
the renamed operations were exercised through the deterministic driver.

## 9. Remaining limitations

* **Ordinary trait operations still take a visible function's call shape.**
  The receiver of an ordinary trait operation may be a view that only
  typing establishes, and resolution, which applies a candidate's flags and
  variadic collection, runs before typing. So `s.area()`, with `fn
  area(x: int, flags :big)` visible, is still a `TYPE` arity error. With
  `fn area(variadic xs: List[int])` visible beside an imported `area`, it
  is still `NO-APPLICABLE-METHOD` plus `TRAIT-VIEW-MISUSE`. Both are false
  rejections, never a wrong acceptance. A fix would have to feed typing's
  verdict back into resolution: a rebuild in which the call is resolved in
  the projection form, as change 1 does for context traits. That
  rebuild would happen for every program in which a trait operation has a
  visible same-named function, a common shape. It would also change build
  counts, which the static decision economics pins. It belongs with the
  method decision, not in this milestone.
* **The compiler service names the visible function for an ordinary trait
  operation.** At `s.area()`, `service::at` reports the visible `area` as
  the construct's binding, definition and reference (its hover type is the
  operation's contract). Context-trait operations are correct (section 6).
  The service could skip a `ref` that is the callee of a typed trait
  operation. That is a service change, with its own tests and mutants,
  left for a follow-up.
* **Trait-implementation yields are invisible before monomorphization**
  (COROUTINES.md, unchanged). An operation whose implementation yields is
  still rejected when it should be: the top-level call is `UNWRAPPED-YIELD`,
  reported by the monomorphized program's check and naming the clone. A
  coroutine whose only yield is reached through an operation is falsely
  `COROUTINE-RHS-NOT-YIELDING`. For a context trait the selection is
  program-wide unique (`hir::contexts::verify`'s `selected`), so a later
  milestone could give the build-1 coroutine analysis an edge to the
  selected implementation through this milestone's feedback loop. The edge
  would also have to appear in `hir/staticdeps.tcl`'s yield reachability.
  Ordinary traits would need per-witness analysis.
