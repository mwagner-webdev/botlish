# Trait-implementation yield inference, milestone 1

A compiler-correctness milestone. It completes the other half of
CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md, which established that a
visible function of a trait operation's name never takes part in the
operation's call. This milestone makes the implementation the program
actually selects take part:

> Once a trait operation's implementation is selected, its actual coroutine
> effects are attributed to the call. A coroutine neither loses a genuine
> yield nor acquires one from an implementation it does not invoke.

It is not an event-loop milestone and not a redesign of coroutine effects:
no syntax, annotation, runtime change or new kind of coroutine.

## Contents

1. [Result](#1-result)
2. [Starting evidence](#2-starting-evidence)
3. [Root cause](#3-root-cause)
4. [Architecture](#4-architecture)
5. [Context traits](#5-context-traits)
6. [Ordinary traits](#6-ordinary-traits)
7. [Coroutine protocols](#7-coroutine-protocols)
8. [Cross-analysis consistency](#8-cross-analysis-consistency)
9. [Compiler economics](#9-compiler-economics)
10. [Diagnostics](#10-diagnostics)
11. [Testing](#11-testing)
12. [Remaining limitations](#12-remaining-limitations)
13. [Files](#13-files)

---

## 1. Result

**Fixed** for context traits and for statically selected ordinary-trait
implementations, including imprinted (constrained-slot) functions. The
checked program -- build 1, before monomorphization -- now attributes to a
trait operation the yield effect and the resume protocol of the
implementation the program binds it to, and nothing else. Programs that were
falsely rejected now compile and run, identically on all four backends:

| program | before | now |
|---|---|---|
| a coroutine of a context-trait operation's function whose selected implementation yields (`audit/trait-implementation-yield/repro/context/coroutine.bot`) | COROUTINE-RHS-NOT-YIELDING | `[5, 106]` |
| a coroutine of a trait-polymorphic function with a yielding witness, through an intermediate function, beside a non-yielding witness's call (`.../ordinary/coroutine.bot`) | COROUTINE-RHS-NOT-YIELDING | `[3, 3, 18, 32]` |
| the same with the implementation's own resume message (`.../ordinary/protocol.bot`) | COROUTINE-RESUME-ARITY, COROUTINE-RHS-NOT-YIELDING | `[3, 16, 5]` |
| the event-loop scheduler, unchanged, under a driver whose `block` yields to the host (`audit/event-loop/repro/host-stepped-driver/`) | COROUTINE-RHS-NOT-YIELDING | the host steps `main` |

Genuine misuse is still rejected, now by the checked program and in source
terms: a top-level call that may suspend through an implementation is
UNWRAPPED-YIELD naming the operation, the implementation and the
specialization (before: "in the monomorphized program", naming the clone
`twice<ysq::YSq>`), and a coroutine whose selected implementation does not
yield is still COROUTINE-RHS-NOT-YIELDING -- whatever other implementations or
visible same-named functions yield.

The one boundary left (section 12): a coroutine construction *inside* a
trait-polymorphic function whose root yields only through that function's
own witnesses is judged by the function as written, which is checked against
its traits alone, and is rejected.

## 2. Starting evidence

At `24de220d` (the tree this milestone starts from), the three regression
tests the preceding milestone left pin the defect:
`ct-operation-identity-implementation-yield`,
`ct-operation-identity-implementation-yield-limitation`
(tests/context-traits.test) and `trait-operation-identity-implementation-yield`
(tests/traits.test). Minimal programs, committed under
`audit/trait-implementation-yield/repro/` (each directory is its own
application root):

**Context trait.** `drv.bot` declares `context trait Driver: fn wait(deadline:
int) -> int`, `fn run(context d: Driver) -> int: d.wait(5)` and `fn
wrapper(context d: Driver) -> int: run() + 1`; `ysim.bot`'s `YSim` implements
`wait` with a `yield deadline`; `sim.bot`'s `Sim` without one.

```
$ tclsh9.0 main.tcl audit/trait-implementation-yield/repro/context/coroutine.bot   # YSim installed
   error: coroutine.bot:4:1: drv::wrapper never yields (it has no reachable yield and calls no
   function that may yield), so there is no coroutine to start: call it directly
   (CORE SEMANTIC COROUTINE-RHS-NOT-YIELDING)
$ tclsh9.0 main.tcl audit/trait-implementation-yield/repro/context/top.bot         # drv::run() at the top level
   error: top.bot:4:1: in the monomorphized program: drv::run<drv::Driver=ysim::YSim> may suspend,
   but this call does not start a coroutine (...):
    drv::run<drv::Driver=ysim::YSim>, which calls ysim::wait at drv.bot:5:5
     -> ysim::wait, which yields directly at ysim.bot:10:5 (CORE SEMANTIC UNWRAPPED-YIELD)
$ tclsh9.0 main.tcl audit/trait-implementation-yield/repro/context/negative.bot    # Sim installed
   error: negative.bot:4:1: drv::wrapper never yields (...) (CORE SEMANTIC COROUTINE-RHS-NOT-YIELDING)
```

**Ordinary trait.** `trait Shaped: fn area(self: Shaped) -> int`, `fn
measure(s: Shaped) -> int: s.area()`, `fn twice(s: Shaped) -> int:
measure(s) + measure(s)`; `ysq.bot`'s `YSq` implements `area` with a yield,
`shapes.bot`'s `Sq` without.

```
$ tclsh9.0 main.tcl audit/trait-implementation-yield/repro/ordinary/coroutine.bot
   error: coroutine.bot:13:1: twice never yields (...) (CORE SEMANTIC COROUTINE-RHS-NOT-YIELDING)
$ tclsh9.0 main.tcl audit/trait-implementation-yield/repro/ordinary/top.bot
   error: top.bot:13:26: in the monomorphized program: twice<ysq::YSq> may suspend, but this call
   does not start a coroutine (start it with "coroutine {step, first} = twice<ysq::YSq>(...)", ...):
    twice<ysq::YSq>, which calls measure<ysq::YSq> at top.bot:11:5
     -> measure<ysq::YSq>, which calls ysq::area at top.bot:8:5
     -> ysq::area, which yields directly at ysq.bot:8:5 (CORE SEMANTIC UNWRAPPED-YIELD)
$ tclsh9.0 main.tcl audit/trait-implementation-yield/repro/ordinary/protocol.bot   # area declares resume Tick
   error: protocol.bot:20:8: this coroutine has the zero-message protocol: resume it with no
   argument, "step()", got 1 argument(s) (CORE SEMANTIC COROUTINE-RESUME-ARITY)
   error: protocol.bot:19:1: measure never yields (...) (CORE SEMANTIC COROUTINE-RHS-NOT-YIELDING)
```

The negative control (`ordinary/negative.bot`: a coroutine of `measure` for
the non-yielding `Sq`) was rightly COROUTINE-RHS-NOT-YIELDING, and still is.

Classified (the brief's five questions):

| symptom | class |
|---|---|
| a coroutine whose only yield is an implementation's is COROUTINE-RHS-NOT-YIELDING | the yield is not recognized (no edge) |
| `protocol.bot`'s COROUTINE-RESUME-ARITY | the resume protocol is not inferred (the implementation's `resume Tick` never reaches the root: zero-message by default) |
| `twice` through `measure` | the effect does not propagate through intermediate functions (the same missing edge, one level down) |
| UNWRAPPED-YIELD "in the monomorphized program", naming clones | the diagnostic is produced in the wrong phase |
| `twice` for `Sq` and for `YSq` in one program | different implementations of one operation: build 1 had one node for `twice`, so it could not have told them apart |

## 3. Root cause

`hir::coroutines::analyze` runs before the types are inferred (it infers the
resume protocols that type every `yield`). A trait operation's
implementation is known only after typing: a context trait's from the
installed contexts' types and the program-wide selection
(`hir::contexts::verify`'s `selected`), an ordinary trait's from the static
type of the receiver (its witness), per semantic instance of a
trait-polymorphic function. It was bound only by the monomorphization's plan
(`hir::traits::Plan`), which runs after build 1 has been checked, and only
when build 1 has no diagnostic at all.

So in build 1 an operation had no edge (the preceding milestone made sure it
had no *wrong* edge), and every judgment build 1 makes from the call graph
was made without the implementation's effect:

1. **Yield capability and `mayYield`** -- COROUTINE-RHS-NOT-YIELDING for a
   construction whose root yields only through an implementation; no
   UNWRAPPED-YIELD for a top-level call that suspends.
2. **Protocols** -- the implementation's declared `resume T` or use-site
   constraints never reached the root: zero-message by default.
3. **Construction types** -- `coroutine#create` is typed from the root's
   protocol and outward type: with no capable root, `Coroutine{resume: unit,
   yield: any}`, a cascade of TYPE and arity diagnostics in the code that
   uses the handle.

Because build 1 then had a diagnostic, the program never reached build 2,
where the operation is an ordinary call of the implementation and every
judgment would have been right. When build 1 had *no* diagnostic -- a
top-level call that suspends -- build 2's check found the problem and
reported it in terms of the clones.

There is a second, independent reason ordinary traits failed: build 1 has
one block per trait-polymorphic function, but the effect of `measure` is
different for each witness. No edge from `measure`'s one node could be right
for both `YSq` and `Sq`.

## 4. Architecture

The desired invariant: a final coroutine-effect judgment has the
implementations the compiled call can actually invoke. Four approaches were
compared against the compiler as it is.

1. **Earlier implementation identity** (an edge to the selected
   implementation before typing). Possible only where the selection is known
   before typing; it is not: the context selection reads the installed
   values' types, a witness the receiver's type. It is possible from the
   *previous* check's typing, which is what the preceding milestone's
   feedback loop (`hir::check`, `hir::coroutines::TraitOperations`) already
   does for the operations to set aside.
2. **Deferred effect resolution** (leave an operation's effect open in build
   1 and let build 2 judge). Build 1 would still have to *type* the
   construction -- its handle's protocol, its first value's type -- and
   those depend on the effect. Typing them `any` makes build 1 reject
   correct programs (a declared result cannot be proven from `any`) or
   accept wrong ones that only build 2 reports, in clone terms: the
   diagnostics-in-the-wrong-phase defect, made systematic. Rejected.
3. **Specialization-aware inference** (infer effects per concrete witness).
   Needed for ordinary traits, and the plan already computes exactly the
   specializations the monomorphized program will have, from build 1's own
   semantic instances (TRAITS.md, "Specialization"). The question is only
   where the coroutine analysis can see them.
4. **Hybrid.** Chosen:
   * the coroutine analysis keeps running first in every check, but is told,
     through `hir::check`'s feedback, the trait-operation edges the previous
     check's typing found (the context trait's program-wide provider, the
     witness's implementation) -- approach 1 through the existing loop;
   * those edges come from the plan's own call resolution
     (`hir::traits::PlanCalls`, the first part of `hir::traits::Plan`,
     split off unchanged), so build 1's call graph *is* build 2's -- one
     source of truth, not a second resolver that could drift;
   * a trait-polymorphic (or per-binding imprinted) function gets, besides
     its own node per block, one node per specialization the plan makes of
     it: approach 3 inside the existing analysis. A context-trait function
     needs none: the program has one provider per context trait, so its own
     nodes take the selected implementation's edges.

Moving the coroutine analysis after typing was ruled out at the start: its
protocols type every `yield`, and type inference reads them.

**The feedback loop** (`hir::check`, `hir::coroutines::Feedback`). Each check
runs the whole of `hir::CheckWith`; after it, `Feedback` computes from the
checked HIR the operations to set aside (as before) and the
trait-operation graph (`Implementations`): it runs `PlanCalls`, takes every
action that binds an operation (`trait`, `context`) or redirects a call to a
specialization (`redirect`), and keeps the edges whose target may yield. The
feedback is the union of the given one and the new one; `hir::check` checks
again until it is unchanged.

*Termination.* The feedback only grows (it is a union), so every check but
the last is followed by a strictly larger feedback; and it is a set over
finitely many calls, implementations and specializations (the plan's
specializations come from semantic instances, which are budgeted). So the
loop ends. `hir::check` fails with an internal error past 64 checks, which
only a compiler bug could reach (a non-canonical feedback that never
compares equal). Typically build 1 is checked twice: the second check
confirms the edges. A third is needed when the second check's typing gives
an operation a witness it had none for -- a yield typed by the protocol an
implementation fixes, passed to a trait parameter
(`trait-implementation-yield-rounds`, an adversarial program that needs it).

*Why a union.* Taking only the last check's edges would let a program whose
edges change the very types that select them oscillate. With the union an
edge, once found, stays; the only imprecision this can cause is in such a
self-referential program, and it is conservative (an extra edge can add a
yield or a protocol constraint, never remove one; build 2 checks the
monomorphized program anyway).

*What is kept.* Only edges into a node that may yield syntactically, and an
operation's edges where the operation receives a yield's value (its
implementation's declared parameter type may fix the protocol: use-site
inference). Any other edge changes no protocol, no yield effect and no
diagnostic. And only the specializations that differ from their function as
written (`hir::coroutines::Distinct`): a specialization is distinct when one
of its calls resolves otherwise than the same call of the function's own
node does -- an operation bound to an implementation, a call of a distinct
specialization. Any other one would have exactly its function's nodes; an
edge into it is the call's exact edge, which needs no entry. (A
trait-polymorphic function that yields by itself, whatever its witness, is
the common case: the golden suite `coroutines.bot` has one, `greet`.) So a
program none of whose implementations yields keeps an empty graph and is
checked exactly as before (one check). An empty feedback is `{}`, so the
loop's comparison is cheap and the HIR of such a program carries no new keys.

*When the plan is asked* (`hir::coroutines::MayBind`). Running the plan's
call resolution after every check would cost every program that has both a
coroutine and a trait operation -- every golden suite with a trait, since
`std::test`'s runner is a coroutine -- 2-4% of its compilation (section 9).
`Implementations` asks it only when an edge could be kept, which this
check's own results decide without the plan. A kept edge needs an operation
that receives a yield's value, or an implementation that may yield; and an
implementation that may yield reaches a yield, after the last operation on
the way, through ordinary calls and calls of specializations alone, which
the coroutine analysis -- made with no trait-operation edge -- saw as
ordinary calls (a specialization's calls are its function's). So the
analysis already found that implementation yield-capable. The plan is asked
when

* a yield-capable function is in the implementation index
  (`hir::traits::ImplInfo`, which conformance and context-trait
  satisfaction both read) under the name of a declared trait's
  requirement -- every implementation is such a function; or
* a trait operation has a yield, or a binding of one, as an argument; or
* an earlier check found edges (the analysis then saw those instead of
  some ordinary calls, and the argument above does not apply).

The index is read only to rule the plan out, never to bind anything: an
operation's implementation is still the plan's.

## 5. Context traits

The plan gives each context-trait function one clone, under the program-wide
selection (`hir::traits::ContextSelection`), and binds each operation in it
to the selected context's implementation (`hir::contexts::satisfiesTrait`'s
mapping). `Implementations` records that binding as an edge of the
function's *own* node (context `""`): a context-trait function behaves alike
in every activation the program can make. An implementation that requires a
context trait itself is the plan's `{context OP K}` action, whose clone is
again that function's own node.

* A yielding implementation makes the operation's callers yield, through any
  number of wrappers, and through implementations that call other context
  traits' operations or ordinary yielding functions
  (`ct-implementation-yield-transitive`: `[100, 8]`, `[100, 16]`, `[5, 12]`,
  `[1, 5, 7]`).
* A non-yielding implementation adds nothing: with `Sim` selected, the
  operation's function is not yield-capable although `YSim` (imported, not
  installed) and a same-named function of the trait's module yield
  (`ct-implementation-yield-negative`).
* The same source yields or not by which context is installed
  (`ct-implementation-yield-negative`, last case).
* A top-level call that may suspend is UNWRAPPED-YIELD in build 1, the chain
  through the implementation (`ct-implementation-yield-chain`).
* A missing or ambiguous provider stays a selection error and selects
  nothing: no edge (the plan binds nothing without a selection). Its
  construction is reported once -- MISSING-CONTEXT or
  AMBIGUOUS-CONTEXT-IMPLEMENTATION -- without the COROUTINE-RHS-NOT-YIELDING
  that used to follow it: whether the root yields depends on the
  implementation, which does not exist (`hir::coroutines::Unselected`,
  `SelectionRejected`; `ct-implementation-yield-selection-errors`). This is
  a dependency of the construction's own diagnostics (the selection
  diagnostic is reported at the same call, earlier in the same check), never
  a program-wide one: a construction no call selects for -- in a function
  the program never calls -- is judged as before.
* An operation in a function the program never calls has no edge: the plan
  never walks it, and the monomorphized program drops it
  (`ct-implementation-yield-hir`).

## 6. Ordinary traits

An ordinary trait operation's implementation depends on the witness, and a
trait-polymorphic function is used with several witnesses in one program. The
call graph therefore has, for each specialization `K` the plan makes (a clone
key `{FUNCTION WITNESSES SELECTION ?BINDING?}`), a node `{K B}` for every
block `B` of the function's region (the function and the functions nested in
it). `hir::coroutines::Build` makes them; `Resolve` gives each call of a node
its target in that node's context:

| call | target in a specialization `K` | target in a block's own node |
|---|---|---|
| a trait operation | the plan's implementation for `K`'s witness | only when the function's own analysis already binds it (a concrete witness; `WitnessFree`), else none |
| a call of a trait-polymorphic function | the plan's specialization (clone node) | the same, when the call passes concrete witnesses |
| any other call | its exact callee, in `K`'s region a node of `K` | its exact callee |

So `twice<YSq>` reaches `measure<YSq>` and `ysq::area`, while `twice<Sq>`
reaches `measure<Sq>` and `shapes::area` and does not yield. A call in
non-polymorphic code with concrete witnesses -- `coroutine {step, first} =
twice(ysq::make(3))`, `twice(shapes::make(4))` at the top level -- is an edge
to its specialization, exactly as the plan redirects it. Tested:

* one yielding and one non-yielding witness in one program, through an
  intermediate function and two levels deep
  (`trait-implementation-yield-coroutine`);
* a non-yielding witness's specialization never yields, beside a yielding
  witness and a yielding same-named function (`-negative`);
* a local view the typing establishes, in a trait-polymorphic function (per
  witness) and in an ordinary function (concrete witness), and an operation
  on a view at the top level, which is now UNWRAPPED-YIELD in build 1
  (`-local-view`);
* a nested function performing the operation on the enclosing view, used as
  a function value: UNWRAPPED-YIELD for the yielding specialization only
  (`-function-value`);
* imprinted functions (TRAIT-CONSTRAINED-IMPRINTED-TYPES.md): `show(p:
  P[T])` with `p.value.describe()`, specialized per binding of `T`
  (`-imprint`).

**Typing per specialization.** A specialization's protocol can differ from
its function's own (the implementation imposes one). Yields and coroutine
constructions written in a trait-polymorphic function are typed, in a
semantic instance of it, as its specialization for the instance's witnesses
(`hir::coroutines::SpecializedNode`, from the instance's entry types through
`hir::traits::CloneWitnesses` and `InstanceBinding`, the plan's own key);
the function's generic analysis types them as the function as written. The
test `-own-yield` reads the instance's type of `m = yield 0` in `measure` for
`std::ma::A`: `std::ma::MsgA`, as in the monomorphized clone.

## 7. Coroutine protocols

The protocol fixed point (`hir::coroutines::Solve`) is unchanged; it runs
over the nodes, so an implementation's protocol reaches its callers like any
callee's, per specialization:

* an implementation declaring `resume Msg` makes the coroutine's protocol
  `Msg`, also through a wrapper; resuming with nothing is
  COROUTINE-RESUME-ARITY, with another struct TYPE
  (`ct-implementation-yield-protocol`);
* two witnesses whose implementations declare different protocols, used in
  one program: each specialization's coroutine is resumed with its own
  message (`trait-implementation-yield-witnesses`: `[3, 4, 71, 1009]`);
* direct yields of the function itself combined with an implementation's
  (`ct-implementation-yield-transitive`, `trait-implementation-yield-own-yield`);
* a function calling an operation whose implementation declares `Msg` and a
  function declaring `Other` is COROUTINE-RESUME-CONFLICT, explained through
  the implementation; a trait-polymorphic function declaring `resume MsgA`
  is a conflict in its specialization for `B` alone (`-own-yield`). A
  specialization's conflict is reported only when the function's own node
  has none: a specialization reaches every constraint its function does.
* use-site inference reads an implementation's declared parameter types
  through the operation (the parameter offset of a field-shaped call),
  exactly as the monomorphized program's direct call of it does.

Nothing is widened: no union, no `any` protocol, no new message type. A
function's own projection of a yield's value needs its own protocol
(COROUTINE-RESUME-UNDERCONSTRAINED, the function as written), as before.

## 8. Cross-analysis consistency

* **The coroutine call graph and monomorphization** read one resolution: the
  plan's actions (`hir::traits::PlanCalls`). The split of `Plan` moved its
  call-resolution loop unchanged into `PlanCalls`; `Plan` places the clones
  as before. `trait-implementation-yield-agreement` compares, for ordinary
  traits (two witnesses, through intermediate functions, per-witness
  protocols) and context traits, the functions build 1's analysis says may
  yield -- each specialization named by its clone -- with the functions
  build 2's analysis says may yield: identical.
* **Static dependencies.** `hir/staticdeps.tcl` reads each trait operation's
  implementations (`hir::coroutines::ImplementationTargets`, the graph's
  kept edges, every context's) as call targets: in a region's own targets
  (`R -> R:impl`), in a subtree's, and in the yield reachability
  (`callEdges`, so `yieldAll`/`yieldStruct` follow operations too). An
  operation's implementations for every witness are a superset of each
  specialization's -- conservative, which costs at most a build.
  `se-equal-implementation-yield` (tests/static-economics.test): a
  construction's block is accepted while the block in the selected
  implementation yields and COROUTINE-RHS-NOT-YIELDING once that block is
  rejected; batched equals sequential with no misprediction, and without the
  new edges (the mutant `staticdeps-implementations-ignored`) the batched
  scheduler mispredicts.
* **Typing** reads the specialized nodes in semantic instances
  (`SpecializedNode`); verification judges every construction, top-level
  call and function value from the program as written, with a specialization
  as the node of a call that names one.
* **Callee identity** is unchanged: `hir::contexts::Callee` still returns no
  callee for a typed trait operation; the operation's implementation enters
  only the coroutine analysis, through the graph.
* **HIR interchange and the front-end cache.** The graph and the
  specialized tables are part of the HIR's `coroutines` side table (only
  when the graph is not empty), which interchange carries as data; section
  11 has the round trips.

## 9. Compiler economics

TBD

## 10. Diagnostics

| situation | diagnostic |
|---|---|
| a coroutine yielding only through a selected implementation | accepted |
| a coroutine whose selected implementation does not yield | COROUTINE-RHS-NOT-YIELDING (unchanged) |
| a top-level call that may suspend through an implementation | UNWRAPPED-YIELD in the checked program, the chain through each operation and its implementation |
| a top-level operation call whose implementation may yield | UNWRAPPED-YIELD naming the operation and the implementation |
| conflicting protocols | COROUTINE-RESUME-CONFLICT, the reason through the implementation; a specialization's named |
| missing or ambiguous provider at a construction | MISSING-CONTEXT or AMBIGUOUS-CONTEXT-IMPLEMENTATION alone |

A chain step through an operation names the operation and the selected
implementation (`hir::coroutines::Via`):

```
std::ty::d::wrapper may suspend, but this call does not start a coroutine (start it with
"coroutine {step, first} = std::ty::d::wrapper(...)", or call it from a function that runs inside a coroutine):
    std::ty::d::wrapper, which calls std::ty::d::run at d.bot:11:5
     -> std::ty::d::run, which calls std::ty::w::wait, the implementation of std::ty::d::Driver's
        operation wait for the installed context std::ty::w::W, at d.bot:8:5
     -> std::ty::w::wait, which calls std::ty::w::pause at w.bot:15:5
     -> std::ty::w::pause, which calls std::ty::c::tick, the implementation of std::ty::d::Clock's
        operation tick for the installed context std::ty::c::C, at w.bot:12:5
     -> std::ty::c::tick, which yields directly at c.bot:10:5
```

A specialization is named by its function and witnesses, `measure (for
std::ysq::YSq)`; the "start it with" suggestion names the function as
written. When a function's own node already may yield (a yield that does not
depend on the witness), the diagnostic names the function, not a
specialization: the preceding milestone's chain `both, which calls area at
<input>:28:16` is unchanged. No diagnostic names a same-named visible
function, and none says "in the monomorphized program".

## 11. Testing

TBD

## 12. Remaining limitations

Each with a reproducer that is a test.

* **A construction inside a trait-polymorphic function whose root yields
  only through that function's own witness** is judged by the function as
  written and rejected:

  ```
  fn start(s: Shaped):
      coroutine {step, first} = measure(s)     # COROUTINE-RHS-NOT-YIELDING
      first
  start(std::ysq::make(3))
  ```

  (`trait-implementation-yield-generic-body`, second case.) The information
  that is missing where the judgment is made: `start` is checked against its
  traits alone, once (TRAITS.md, "No delayed duck typing"), and a trait's
  requirement says nothing about suspending; whether `measure(s)` yields is
  a fact of each specialization, not of `start`. Accepting it would need
  either an effect in the trait contract (a language change: a requirement
  that declares it may suspend, and implementations checked against it) or
  checking a generic body once per specialization (a change to the trait
  model, with diagnostics per witness). Neither is a fix of inference. The
  same construction with a concrete witness (`measure(std::ysq::make(5))`
  inside `start`) runs (same test, first case), and so does any
  construction outside trait-polymorphic code. For the same reason a
  trait-polymorphic function's own yield whose value is used is typed by
  the function's own protocol: a projection of it needs `resume T`
  declared, and an operation on the function's view that receives it fixes
  no protocol there (use-site inference through an operation works where
  the operation is bound: `trait-implementation-yield-use-site`).
* **A trait operation is no coroutine's root** (`coroutine {step, first} =
  s.area()`): unchanged, the preceding milestone's decision that the right
  side is a direct call of a named function
  (`trait-operation-identity-coroutine-root`). Wrapping the operation in a
  function is enough.
* **The selection-failure cascade is suppressed at the construction only.**
  A construction inside a function, whose top-level call is the one with
  MISSING-CONTEXT, still gets COROUTINE-RHS-NOT-YIELDING beside it (e.g.
  `fn start(context d: Driver): coroutine {step, first} = run()` with no
  provider installed: MISSING-CONTEXT then COROUTINE-RHS-NOT-YIELDING, as
  before this milestone). Suppressing it would make one site's diagnostic
  depend on another call's selection, a program-wide channel of the static
  decisions; the first diagnostic, the one that matters, is already right.
* **Unchanged from the preceding milestone** (its section 9, out of scope
  here): an ordinary trait operation still takes a visible same-named
  function's call shape (flags, variadic collection) before typing, and the
  compiler service names that function as the operation's definition.

## 13. Files

Compiler:

* `hir/coroutines.tcl` -- the call graph's nodes (a block's own, a
  specialization's `{K BLOCK}`: `Build`, `BlockOf`, `ContextOf`), each call's
  target in a node's context (`Resolve`, `Root`), the analysis over nodes
  (`analyze`, `YieldUses`, `Solve`'s reasons, `ExplainReason`, `Name`,
  `Via`), the trait-operation edges a typing found (`Implementations`,
  `WitnessFree`, `UseCalls`, `AddClone`, `UnionGraph`, `CanonicalGraph`), the
  feedback (`Feedback`), the specializations' typing (`ShapeResult`'s
  context, `SpecializedNode`, `NodeInfo`, `CapableNodes`, `Outward`,
  `YieldTypes`), verification over nodes (`verify`, `CallTargets`,
  `ResultMismatch`, `Chain`, `thunkErrors`), the selection dependency
  (`Unselected`, `SelectionRejected`) and staticdeps' reading
  (`ImplementationTargets`).
* `hir/hir.tcl` -- `hir::check` checks until the feedback (operations and
  edges) is unchanged; `hir::CheckWith` passes it on; the `checks` and
  `effectPlans` counters.
* `hir/traits.tcl` -- `hir::traits::PlanCalls`, the plan's call
  resolution, split off `hir::traits::Plan` unchanged (a clone record's
  `node` may be empty for a caller without syntax).
* `hir/types.tcl` -- `hir::types::ShapeResult` passes the typing context to
  the coroutine shapes.
* `hir/semantic.tcl` -- `hir::semantic::Instance`, the record of an instance
  of the run in progress.
* `hir/staticdeps.tcl` -- implementations as call targets (`implTargets`:
  regions' own targets, subtrees, `callEdges`).
* `hir/completions.tcl` -- `YieldFinalsOf` over the nodes, specializations'
  roots included.
* `hir/contexts.tcl` -- `Callee`'s comment.

Tests and tools:

* `tests/context-traits.test` -- `ct-operation-identity-implementation-yield`
  (now the checked program's diagnostic), `ct-implementation-yield-coroutine`
  (was `ct-operation-identity-implementation-yield-limitation`) and the
  `ct-implementation-yield-*` section.
* `tests/traits.test` -- `trait-operation-identity-implementation-yield` and
  the `trait-implementation-yield-*` section, with `effectAgreement`.
* `tests/static-economics.test` -- `se-equal-implementation-yield`.
* `audit/trait-implementation-yield/repro/` -- the minimal programs of
  section 2; `audit/trait-implementation-yield/tools/fuzz.tcl` -- the
  differential fuzzer.
* `audit/event-loop/repro/host-stepped-driver/` -- the scheduler under a
  host-stepped driver; `audit/event-loop/README.md` lists it.
* Mutants: `audit/traits/tools/mutants.txt` (11 new), `audit/context-traits/
  tools/mutants.txt` (4 new), `audit/static-decisions/tools/mutants.txt` (1
  new); re-anchored: `check-not-repeated` (traits), `effect-one-caller`,
  `call-crosses-yield`, `protocol-widened-any` (coroutines) and
  `recheck-analysis-repeated`'s replacement (static decisions).
  `audit/context-traits/tools/mutate.tcl` copies `src/evloop.bot` into its
  private tree.

Documentation: this report; COROUTINES.md (point 8 and the limitation);
CONTEXT-TRAITS.md (section 5); CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-
MILESTONE-1.md (section 9, a note); INDEX.md; Compilerpedia's
`concept.coroutines` (a rule and an example) and
`error.coroutine-rhs-not-yielding` (likely causes).
