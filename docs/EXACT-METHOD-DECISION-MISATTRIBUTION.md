# The exact method-call decision charges an outer call's problem to an inner call

Status: **fixed** by METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, which
replaced the exact decision and the kind filter with one decision whose
verdicts are a call's own checks (`subject`), certified relative to the
decided configuration (`hir/methods.tcl`). The reproducer below compiles and
runs; `tests/method-resolution.test` pins it and its variants
(`mr-reported-chain-*`, `mr-argument-nested-*`). The rest of this document is
the defect as reported, 2026-10-24: it names procedures
(`hir::DecideMethodCallsExact`, `hir::MethodCallProblems`,
`hir/methodfilter.tcl`) that no longer exist.

## Summary

`hir::DecideMethodCallsExact`, the reference decision of method-style calls
(METHOD-SUGAR.md; METHOD-DECISION-FILTER.md, "the exact decision"), can reject
a valid program. It needs a chain `a.f().g()` in which:

* the inner call has several candidates, and
* one of the outer call's candidates sorts before the right one and rejects
  the inner call's result.

The outer candidate's rejection of its receiver is reported at the
receiver's position, which is the inner call's own node. The exact decision
counts every diagnostic located inside a call as that call's own problem. So
it charges the outer problem to the inner call's one valid candidate, and
reports NO-APPLICABLE-METHOD for the inner call and AMBIGUOUS-METHOD-CALL for
the outer one.

The kind filter (`hir/methodfilter.tcl`) decides the same program correctly,
and so does the free-call spelling. That has two consequences:

* A program's outcome depends on whether the filter or the exact decision
  decides it. That breaks METHOD-DECISION-FILTER.md's claim that the filter
  "changes how many builds a decision takes, never its outcome": the
  outcome it changes is the exact decision's wrong one.
* With the filter on, the default, a valid chain gets two spurious errors as
  soon as anything else in the program makes the filter hand over.

## Reproduction

An application module `bag.bot` beside the program:

```
struct Bag:
    n: int

fn length(b: Bag) -> int:
    b.n
```

and the program `main.bot`:

```
import std::list
import std::str
import std::mutable_array
import std::mutable_vector
import bag

fn f() -> int errors IndexNotFound:
    [[1, 2], [3]].at(1).length()

r = f():
    on IndexNotFound:
        -1
r
```

Compiled with `surface::readProgramFile FILE -strict 0 -warnings off -cache ""`:

| spelling | `hir::methodFilter 1` (default) | `hir::methodFilter 0` (the exact decision) |
|---|---|---|
| `[[1, 2], [3]].at(1).length()` | 0 diagnostics | 2 diagnostics (below) |
| `std::list::length(std::list::at([[1, 2], [3]], 1))` | 0 diagnostics | 0 diagnostics |

The exact decision's two:

```
NO-APPLICABLE-METHOD: method-style call "at": none of the visible functions of
that name accepts the receiver (std::list::at: argument for parameter "b" cannot
be proven to satisfy bag::Bag (argument type: List[int]); std::mutable_array::at:
the receiver is a list, but argument 1 of native std::mutable_array::at requires
mutarray; std::mutable_vector::at: the receiver is a list, but argument 1 of
native std::mutable_vector::at requires mutvec)

AMBIGUOUS-METHOD-CALL: method-style call "length" is ambiguous: more than one
visible function accepts the receiver (std::list::length,
std::mutable_vector::length, std::str::length); there is no precedence between
them: call the one you mean explicitly, e.g. std::list::length(receiver, ...)
```

The first message names `bag::Bag`, a parameter of `bag::length`, as a reason
`std::list::at` fails. That is the misattribution.

**Through the filter, with an unrelated call.** Add to the same program a
function the filter cannot settle (an untyped receiver):

```
fn u(x) -> int:
    x.length()
```

and call `u([7])` from `f`. With the filter on, the compilation now reports
four diagnostics. Two are correct: the AMBIGUOUS-METHOD-CALL of `x.length()`
and a TYPE that follows from it. The other two are the same spurious pair on
the valid chain, because the filter handed the whole program to the exact
decision.

**Variants checked** (each with the four `std` imports above, filter off):

| outer candidate beside `std::list::length` | inner call | result |
|---|---|---|
| `std::boxlen::length(b: Box)` (sorts before `std::list`) | `.at(i)`, three candidates | rejected |
| `std::zbox::length(b: Box)` (sorts after `std::list`) | the same | compiles |
| `bag::length(b: Bag)` (application module: sorts before every `std::` name) | the same | rejected |
| `std::boxlen::length` with only `std::list` imported | `.at(i)`, one candidate (not decided) | compiles |

The program with the real standard library alone (`std::mutable_map::length`
beside `std::list::length`) does not trigger it: `std::list` sorts first.

The defect predates the method-filter follow-up of ORDERED-MUTABLE-MAP-SET.md
(Compiler changes, item 6). The reproduction gives the same result on
c6930a4d, the commit before it, and on b335fe04.

## Mechanism

1. **Candidate order.** `hir::resolve::MethodCandidates` returns a call's
   candidates sorted by display name (`string compare` of `NS::NAME`). An
   application module's `bag::length` therefore precedes every `std::`
   candidate.
2. **Trials.** `hir::DecideMethodCallsExact` builds the program once per
   candidate index t. In build t every undecided call stands at its t-th
   candidate, or at its last one if it has fewer. A candidate's problems are
   recorded from build t only when t is below the call's candidate count. So
   `std::list::at`, the first of `at`'s three candidates, is judged by build 0
   alone.
3. **Build 0.** In build 0, `length` also stands at its first candidate,
   `bag::length`. That candidate's parameter rejects its argument, the List
   `at` returns. `hir/range.tcl` reports the rejected argument at the
   argument expression ("argument for parameter ... cannot be proven to
   satisfy ...", anchored at `$arg`). That follows METHOD-SUGAR.md, "Source
   locations and diagnostics": a receiver rejected by parameter 1 is located
   at the receiver. Here the receiver is the `at` call's node.
4. **Attribution.** `hir::MethodCallProblems` takes a call's problems to be
   every diagnostic whose expression is in the call's subtree, the call's own
   node included, minus the obligation kinds. The outer call's diagnostic is
   located at the inner call's node, so it is counted as a problem of
   `std::list::at`.
5. **Validity.** Problems shared by every candidate are ignored. `at`'s other
   two candidates have problems of their own (the native kind mismatch), and
   their results are poison, which the outer argument check skips. So
   nothing is shared, and `std::list::at` comes out invalid. With no valid
   candidate, `at` is NO-APPLICABLE-METHOD, and the outer call is left
   without a receiver of a known type: three of `length`'s four candidates
   accept it, AMBIGUOUS-METHOD-CALL.

The filter is not affected because it never reads diagnostics to rule a
candidate out. It excludes by the receiver's kind (and a named struct's
declaration), and certifies its decisions with a build in which every call
stands at its decision.

## When it occurs

All three conditions must hold:

* **An inner method call with several candidates.** A call with one
  candidate is not decided, so no problem is charged to it.
* **An earlier-sorting outer candidate that rejects the inner result.** For
  example, an application module or an early-sorting `std::` module that
  defines a function named like a common method (`length`, `at`, `get`, ...)
  over its own type.
* **The exact decision runs.** That happens when:
  * the filter is off (`BOTLISH_METHOD_FILTER=0`, `hir::methodFilter 0`);
  * the exact decision's own audits run (`hir::methodBuildAudit`,
    `hir::methodBuildReuse 0`, which bypass the filter);
  * the filter audit runs (`BOTLISH_METHOD_FILTER_AUDIT=1`): it would fail
    with "the filter decided methodChoices differently from the exact
    decision";
  * the filter hands the program over for any other reason: an untyped
    receiver it cannot settle, a genuine ambiguity, a chosen candidate with a
    problem of its own, or the wave limit.

None of the golden suites contains such a chain: `bench/method-filter.tcl
-suites -audit 1` agrees on all of them. The method-filter fuzzer never
generated one before it was extended to named-struct receivers.

## How it was found, and how the test tooling avoids it

`audit/method-filter/tools/fuzz.tcl` was extended with named-struct receivers
for the nominal rule (METHOD-DECISION-FILTER.md). Its private module then
defined a `length` over a struct, and seed 7 disagreed: the filter certified
the program and the exact decision rejected it. Reproducing the case on the
compiler before the nominal rule showed the same rejection. There the filter
handed the program over, so the old filter and the exact decision agreed on
the wrong outcome.

The fuzzer's modules now define no function named `length`, `at` or `get`
(the comment above its private library says why), so the fuzzer tests the
filter and not this defect. Nothing in the test suite pins the defect, and
nothing works around it in the compiler.

## What a fix would involve (not done)

The diagnostic that misleads the exact decision is correct as a diagnostic.
It is located where METHOD-SUGAR.md says. What is wrong is the exact
decision's notion of which diagnostics belong to a call. A fix that keeps to
AGENTS.md's rules (never suppress or attribute by message text) would record
the provenance as data:

* An argument check's diagnostic would name the call whose check produced it
  (a field of the diagnostic, written by `hir::Diagnose`'s callers in
  `hir/range.tcl` and the other argument checks).
* `hir::MethodCallProblems` would count a diagnostic only if the check that
  produced it belongs to the call's subtree: the call's own check, or one of
  the calls nested in it. It would not count one that merely sits at a node
  of the subtree.

Other approaches, such as judging an inner candidate only in builds where the
outer call stands at a candidate that accepts its result, change the
decision's build schedule and its economics (STATIC-DECISION-ECONOMICS.md), so
they cost more to argue.

What it would touch and need:

* It changes the exact decision's outcomes. It does so only for programs the
  exact decision rejects today, but the exact decision defines the outcome of
  every method call. That is a semantic change in its own right.
* A new field of `hir::Diagnose` (AGENTS.md, "Static intrinsics": run the
  static-compile harnesses) and the reuse of decisions across static rounds
  (`hir::static::MethodSeeds`; the static-decisions comparison in CI).
* Tests in `tests/method-sugar.test` and `tests/method-filter.test` (with
  census rows), mutants for the attribution, and the method-filter fuzzer's
  trigger restored (a `length` in its private modules).

Until then: write the chain with qualified calls, or avoid naming an
application module's function like a method of the standard collections.
