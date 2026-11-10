# Emission binding provenance correctness, milestone 1

Corrects the binding provenance the emission checker (`hir/emission.tcl`)
lacked: EMISSION-BINDING-AND-SIGNATURE-DEPENDENCY-CENSUS-MILESTONE-1.md
found that a proof can read facts the front end derived from a diagnosed
declaration -- a non-local binding's value, a structural function type's
`never` -- without knowing they came from incomplete analysis. Most such
cases gave a misleading `rejected` in a program already rejected for an
UNBOUND; one, V2, gave a certificate, which the memo then reused after an
edit it could not see.

The milestone changes one production file, adds no HIR field, language
construct, diagnostic, certificate format or dependency graph, and keeps
EMISSION-IDENTITY-AND-FEASIBILITY-CORRECTNESS-MILESTONE-1.md's two
corrections exactly as they were.

Evidence is labelled throughout:

* **tested** -- pinned by a test of tests/emission-claims.test;
* **observed** -- seen in a run (a census row, an audit's output, a
  measurement);
* **inspection** -- established by reading the code;
* **inferred** -- follows from the design, not run;
* **not tested** -- said, not checked.

1. [Result](#1-result)
2. [Starting defects and census findings](#2-starting-defects-and-census-findings)
3. [The R1 and V2 reproducers](#3-the-r1-and-v2-reproducers)
4. [Binding and initializer representations](#4-binding-and-initializer-representations)
5. [Diagnostic provenance](#5-diagnostic-provenance)
6. [The implemented dependency rule](#6-the-implemented-dependency-rule)
7. [Memoized binding traversal](#7-memoized-binding-traversal)
8. [Module bindings](#8-module-bindings)
9. [Captured bindings](#9-captured-bindings)
10. [Destructured bindings and aliases](#10-destructured-bindings-and-aliases)
11. [Structural callable `never`](#11-structural-callable-never)
12. [Independent contracts and irrelevant references](#12-independent-contracts-and-irrelevant-references)
13. [Reified diagnostics and reachability](#13-reified-diagnostics-and-reachability)
14. [Conservative dependency decisions](#14-conservative-dependency-decisions)
15. [Certificate and memo trust](#15-certificate-and-memo-trust)
16. [Compiler-service revisions](#16-compiler-service-revisions)
17. [HIR interchange](#17-hir-interchange)
18. [Differential and mutation evidence](#18-differential-and-mutation-evidence)
19. [JSON and CSV preservation](#19-json-and-csv-preservation)
20. [Performance](#20-performance)
21. [Regression and CI results](#21-regression-and-ci-results)
22. [Production files changed](#22-production-files-changed)
23. [Remaining cases and limitations](#23-remaining-cases-and-limitations)
24. [Recommendation](#24-recommendation)
25. [Final evaluation questions](#25-final-evaluation-questions)

## 1. Result

**V2's certificate hole is closed, with the variants of it this milestone
found.** A call through a function value whose structural type says it
never returns -- the join of the inferred results of the functions it may
be -- now asks where that type came from. V2, where one of the functions is
an unresolved name's `never`, is `dependent`, with no certificate, fresh or
after V1; V1, where both genuinely loop, keeps its certificate (tested).
The same question closes four variants the census did not record, each
certified at its commit in a rejected program: the value returned by a
helper whose inferred result joins the two functions (V4, `choose()()`), a
local of the claimed function (V5), a captured value (V6), and a call whose
*result type* is a narrow domain joined from such a function (V3: a
`Digit`, which an edit of the unresolved name to `17` makes every Int).

**Binding provenance follows what typed the facts.** A non-local binding's
exact value and type -- a module binding, a value an enclosing function
bound, an imported one -- are checked by one memoized, cycle-safe search
over the code that typed them: the binding's defining code, the bindings it
names, and the bodies of the functions it calls that declare no result. A
source in that code (a resolution diagnostic's expression, poison, a
syntax-dependent reference) makes the claim dependent. R1, B3c, B6, D1,
D2, B8, B8f, X2, SC1 and S5d are `dependent` (they were `rejected`); a
captured loop element over an unresolved value (L1, new) too.

**What took no part keeps its verdict.** A dead branch (B3b), a declared
result over an unresolved body (B5), a valid captured value beside an
unrelated diagnostic (B8e), an unrelated unresolved binding (Z1), an
unresolved callee read only as a callee (R2), a rejected static block as a
statement (SC2), a check diagnostic in an initializer -- certified as before
(tested). B3, B8b and G1, whose facts every repair keeps but whose code
holds the unresolved name, are decided `dependent` (section 14).

**Certificates are trustworthy across edits.** Provenance is no
fingerprint: V2's claimed function is the same text as V1's, typed the
same. So a compilation holding a source -- a resolution diagnostic, poison
or a syntax-dependent reference -- neither reuses nor memoizes a
certificate. That is exactly the set of compilations in which a provenance
question can answer 1; one whose only diagnostics are the checks' (an
unhandled error) keeps the memo (tested).

**Accepted programs are untouched.** An accepted program has no source, so
every question answers 0 without a scan (tested: no search on any accepted
program; observed: JSON's 22 and CSV's 52 claims certified, the census,
the fuzzer, the loop differential and the structural identity audit
identical to their committed results).

| | the parent (cbaa040) | this milestone |
|---|---:|---:|
| census open cases (rejected-program verdicts not the appropriate one) | 20 | 6 (B2b, S1, K1; S4b, S5b, S6b undecided) |
| census false certificates | 0 | 0 |
| certificates in rejected programs resting on a recovery-derived `never` or type (V2-V6) | 5 | 0 |
| memo reuse in a compilation with a resolution diagnostic | yes | no |
| emission tests | 123 | 138 |
| emission mutants (all killed) | 101 | 119 |

## 2. Starting defects and census findings

The census (its sections 6-12, 19, 21.3) left 20 open cases, every one a
rejected program:

* **class A, a wrong verdict**: placeholder facts used, the verdict
  `rejected` where `dependent` is appropriate -- R1, B2b, B3c, B6, D1, D2,
  B8, B8f, X2, SC1, S1, S5d, K1 -- and one certificate where `dependent` is
  appropriate, V2;
* **class B, a missing certificate dependency**: V2's certificate records
  neither function it relies on, and the `callable` sequence reused V1's
  certificate for it;
* **undecided**: B3, B8b, G1 (facts every repair keeps), S4b, S5b, S6b
  (signature components whose verdict depends on the repair).

Its prototype (`audit/emission-dependencies/prototype/corrections.patch`,
section 21.3) proposed `BindingDependent`, read by `RefValue` and by the
`never` branch of a value call, and the memo rule. It was not applied:
its identity and feasibility parts were superseded by the previous
milestone, and its binding part had three gaps this milestone found
(inspection; each closed below):

1. **Cycles.** Its `CodeDependent` followed a nested function's code
   without a memo; a self-recursive nested function with an inferred result
   called from a captured value's initializer, in a compilation with any
   resolution diagnostic, would recurse without end.
2. **Sources.** It took every diagnosed expression (check diagnostics
   included) as a source, but its memo rule trusted compilations with only
   check diagnostics: a claim could be dependent fresh and reused from the
   memo in one compilation (process history).
3. **Coverage.** It asked only for a value call whose callee is a reference
   to a non-local binding: V4 (the callee a call), V5 (a local, in the
   walk's environment) and V6 kept their certificates, and V3 (a narrow
   result, not `never`) was not asked at all.

## 3. The R1 and V2 reproducers

**R1** (`k = missing()`, `yield 48 + k`), on the parent and now (observed,
the census; tested, `ec-provenance-module-bindings`):

| | the parent | now |
|---|---|---|
| strict | UNBOUND | UNBOUND |
| lenient verdict | rejected (EMIT-END-SYMBOL, EMIT-REJECTED in the HIR, withheld by recovery) | dependent, no EMIT diagnostic |
| hover | "rejected -- the analysis found a trace the recognizer does not accept (see its diagnostics)" | "not checked -- its code, or code whose facts it reads, holds another diagnostic" |

`k`'s bind (value `missing()`, reachable) leaves `k` typed `any`: the walk
read it through `RefValue` as `*`, so `48 + *` was every Int. Now `RefValue`
asks `Dependent {v k}`: `k`'s defining code is the call `missing()`, whose
callee reference is the UNBOUND's expression, a source.

**V2** (`fn g(): missing()`, `fn h()` looping, `f = if pick(): g else: h`,
the claimed `emitter` yielding `1`, calling `f()`, yielding `A`; observed,
a scratch reproducer of the parent and the census):

* `f` is `fn {args {} return never errors {}}`: the join of `g`'s inferred
  `never` (the placeholder) and `h`'s (genuine). The call `f()` has no
  target; its type is `never`; the walk ended there, read nothing, and
  certified the claim, depending on `emitter` alone;
* V1's `emitter` and V2's are the same canonical text, typed the same: the
  fingerprints are equal, so the memo, with V1's certificate in it, reused
  it for V2 (the census's `callable` sequence: V1 fresh, V2 reused, V1
  reused);
* with the memo off, V2 was certified fresh too.

Now (tested, `ec-provenance-structural-never`, `ec-provenance-memo`):

| sequence, one process | the parent | now |
|---|---|---|
| V1 | proven, fresh | proven, fresh |
| V2 | proven, **reused** (V1's certificate) | dependent, fresh, no certificate |
| V1 | proven, reused | proven, reused |

The `never` branch of a value call asks `Dependent {x CALLEE}`: the
callee reference names `f`, a value binding; `f`'s defining code refers
to `g`, a function that declares no result; `g`'s body holds the UNBOUND.

## 4. Binding and initializer representations

Unchanged from the census's section 3 (inspection). What this milestone
relies on:

* a value binding is declared by a `bind` whose value is not a `block`
  (Botlish has no anonymous function: every block is a bind's value, a
  function's declaration); a function binding by a `bind` of a block;
* a loop's clause bindings (a list loop's element, a counted loop's
  counter, a lockstep domain's binding) and a fold's intermediate are
  `param` bindings with no `declaredBy`; their loop is found by scanning
  the loops once (`ClauseMap`, built only when a question reaches one);
* an initializer after code that never completes is `reachable 0` but
  **typed from its own code**: `z = missing()` then `k = d3()` leaves `k`
  typed `Digit` (observed). An unreachable declaration's facts are its
  code's, not inference's default -- the census's prototype treated them as
  the default, through recovery's unit graph, which this milestone does not
  need;
* poison holds expressions and bindings; `resolutionDiagnostics` holds the
  resolution phase's diagnostics (a rejected static block's unhandled
  CompilerError among them: SC1's UNHANDLED-ERROR, located at the reified
  `fail`); a syntax hole is poison with a SYNTAX-HOLE resolution diagnostic.

## 5. Diagnostic provenance

A *source* is what makes a fact incomplete -- what the front end could not
establish -- and nothing else:

* the expression of a resolution diagnostic (an unresolved name's
  reference; an unresolved parameter or result type's function block; a
  rejected static block's unhandled reified failure);
* a poisoned expression or binding (a TYPE in an initializer);
* a syntax-dependent reference.

A resolution diagnostic with no expression makes every question answer 1,
as recovery's unit graph does (`*`).

Check diagnostics are not sources: an unhandled error, a known failure, an
ownership rule. The analysis that typed the code completed; its facts are
the code's (tested: `k = boom()` at module level, its UNHANDLED-ERROR
reported, `boom` declared `-> Digit` -- the claim reading `k` certified).
This is narrower than the walk's own `Taint`, which makes a claim
dependent on any diagnostic in the code it walks (EMISSION-CALLEE-
DEPENDENCY-CORRECTNESS-MILESTONE-1.md), and it is what makes the memo rule
exact (section 15).

## 6. The implemented dependency rule

Two kinds of fact reach the walk from code it never evaluates (inspection,
`hir/emission.tcl`'s Provenance section):

1. **a non-local binding's facts** -- `RefValue` of a binding declared
   outside the function being walked (a module binding, a value an
   enclosing function bound, an imported one): its exact Int value and its
   static type;
2. **a call through a function value with no target** -- `EvalCall`: the
   call's static type, the callee's result type, is the join of the
   inferred results of the functions the value may be. Where it is `never`
   the walk ends; otherwise it is the call's value.

Each asks `Dependent` of a provenance node:

| node | what it stands for | direct (a source of its own) | successors |
|---|---|---|---|
| `{v B}` | the facts of value binding B | B poisoned | the nodes its defining code refers to |
| `{f E}` | the inferred result of function block E (no declared result) | E itself a source (an unresolved signature component) | the nodes its body refers to |
| `{x E}` | the code of expression E (a callee) | -- | the nodes E refers to |

A node's code is scanned once (`ScanCode`): a source met is direct; a
reference contributes the node its binding names (`RefNode`):

* a value binding -- one a bind of no function declares, a loop clause
  binding, a fold intermediate -- is `{v B}`;
* a function that declares no result is `{f E}`;
* anything else is no node: a function with a declared result (typed by
  its declaration, a contract every repair of its body keeps: B5), a
  parameter (its declared type), a root or ambient binding.

A function's declaration (a `bind` of a block) inside scanned code is no
part of a value; a reference to the function is followed instead. Only the
code that typed the facts counts: where a root is reachable, its reachable
part (a dead branch contributes nothing: B3b); where the root itself is
unreachable, all of it (section 4).

The two readers taint the summary being walked through the existing
`tainted` flag, so `CheckClaim` reports the claim `dependent` exactly as
for its own code: no certificate, no EMIT diagnostic, nothing memoized.
The facts themselves are read as before -- an unknown is never replaced by
a guess. Neither reader asks where nothing is read: a callee reference
read only as a callee (R2), a value call typed `any` (no fact) or `unit`
(one value).

## 7. Memoized binding traversal

`Dependent NODE` is a depth-first search over the nodes NODE reaches, on an
explicit stack (a chain of declarations is as long as the program writes
it; nothing recurses on the host's stack), each node's scan memoized
(`provenanceEdges`) and each answer memoized (`provenance`) for the
compilation:

* a search that finds a source answers 1 for the nodes on its path (each
  reaches the source);
* a search that finds none answers 0 for every node it visited (each
  reaches only visited nodes, none a source);
* a node is visited once per search, so cycles end: a recursive function, a
  fold body naming its intermediate. The census's argument that an alias
  chain has no cycle (single assignment, no forward reference) is true of
  bindings but not of functions (recursion), so the search does not rely
  on it.

A search that found a source marks no node off its path: a clean sibling
explored before the source stays unknown and is answered by its own
search (tested, `ec-provenance-search`, which a mutant marking every
visited node kills).

Bounds (observed, section 20): a chain of 400 aliases is one search of 401
nodes, and a second claim reading it takes the memo; the census corpus's
92 compilations searched 34 times, scanning 57 nodes, 113 expressions and
following 23 edges, the deepest stack 3. A trusted compilation scans
nothing.

## 8. Module bindings

| case | initializer | the parent | now | test |
|---|---|---|---|---|
| R1 | `missing()` | rejected | dependent | module-bindings |
| B3c | `if missing(): 1 else: 2` | rejected | dependent | module-bindings |
| B6 | `helper()`, `helper`'s inferred `never` an unresolved call's | rejected | dependent | module-bindings |
| S5d | `helper()`, `helper -> Missing` | rejected | dependent | module-bindings |
| SC1 | a rejected static block, its CompilerError unhandled | rejected | dependent | module-bindings, static-compile |
| X2 | an imported `k = missing()` | rejected | dependent | imported |
| X1, X5 | an imported `k = 1` (X5: beside a broken function of the module) | proven | proven | imported |
| R1v | `k = 1` | proven | proven | accepted |
| Z1 | an unrelated `z = missing()`, the claim reading nothing of it | proven | proven | memo-trust |

A helper's inferred result is part of the value's facts (B6, S5d: its
unresolved signature component is a resolution diagnostic on its block);
a helper's declared result is not (B5, and B5 two calls down -- `h2()`
whose body calls `h1() -> Digit`: certified, `ec-provenance-independent`).
A recursive helper reaching the unresolved name is dependent; a recursive
helper whose code is clean adds nothing, beside an unrelated unresolved
name (`ec-provenance-transitive`).

## 9. Captured bindings

A nested claimed function reads an enclosing function's value through its
own type and exact value (`RefValue`, `CanonBinding`), never its callers'
facts: caller independence is unchanged (inspection). The question names
the captured binding by its identity (a binding id), never its spelling:

| case | the enclosing function | the parent | now |
|---|---|---|---|
| B8 | `k = missing()` | rejected | dependent |
| B8f | `j = missing()`, `k = j` (`k` unreachable, typed from `j`) | rejected | dependent |
| -- | `{k, j} = missing()` | rejected | dependent |
| L1 | `ys = missing()`, the claim inside `loop y in ys:` reads `y` | rejected | dependent |
| B8c | `k = 1` (accepted) | proven | proven |
| B8e | `k = 1`, an unrelated `missing()` later | proven | proven |
| -- | `k = d3()`, a `Digit` | proven | proven |
| -- | `k = if true: 1 else: missing()` | proven | proven |
| -- | `outer1`'s `k = missing()` read by `inner1`, `outer2`'s `k = 1` by `inner2` | rejected, proven | dependent, proven |
| -- | the same, both nested claims named `inner` | rejected, proven | dependent, proven |

(tested, `ec-provenance-captures`). The last row composes with the
previous milestone's identity rule: the two `inner`s share a name, so
neither is memoized, and each is decided from its own code and its own
captured binding. A mutant taking a reference's binding by its spelling is
killed by the two-scopes row (`provenance-capture-by-name`).

Recovery's unit granularity would have made B8e dependent (its enclosing
function is one unit, tainted by the later `missing()`); the scan of `k`'s
own defining code does not.

## 10. Destructured bindings and aliases

Destructuring lowers to a bind of the value and binds of projections
(`destructure#N = missing()`, `k = destructure#N.k`), each a module or
local statement, the later ones unreachable after the first's `never`
(inspection of D1's HIR). `k`'s defining code is the projection, whose
receiver names `destructure#N`, whose defining code is the unresolved call
-- an alias chain followed like any other. D1 and D2 (a struct field of an
unresolved call, destructured) are dependent; an alias chain `a = missing()`,
`b = a`, `c = b`, `k = c` is dependent (tested). No field sensitivity is
added: a projection's whole receiver is its provenance, as its whole
receiver is what typed it. D2v, the valid program, stays the census's
precision loss (an exact field value through destructuring is not
followed), unchanged.

Mutants dropping the alias edge (`provenance-alias-unfollowed`), the
projection (`provenance-destructure-lost`) or the unreachable code
(`provenance-unreachable-trusted`) are each killed.

## 11. Structural callable `never`

A call through a function value has a block target when the value's type
names its block (an alias, a List element of one function): those calls are
`Read` or walked, as before (C1 certified, C2 dependent). Only a value
whose type is a structural `Fn` -- a join -- has no target, and only there
does the walk rely on a type it did not derive. The milestone asks at
every such call whose type gives the walk a fact:

| case | where the structural value comes from | the parent | now |
|---|---|---|---|
| V1 | `f = if pick(): g else: h`, both loop (accepted) | proven, depends on `emitter` | proven, depends on `emitter` |
| V1 beside an unrelated `z = missing()` | the same | proven | proven (fresh: the compilation is untrusted) |
| V2 | V1, `g`'s body `missing()` | proven | dependent |
| V4 | `choose()()`, `choose`'s inferred result the join | proven | dependent |
| V4v | V4, both loop (accepted) | proven | proven |
| V5 | a local of the claimed function, `f = if pick(): g else: h` | proven | dependent |
| V6 | captured from an enclosing function's nested `g`, `h` | proven | dependent |
| V7 | `std::list::at([g, h], 0)()` | dependent | dependent |
| V3 | `yield 48 + f()`, `f`'s result `Digit` joined from `g` (`if pick(): missing()`, then `d3()`) and `h` | proven | dependent |
| V3v | V3, `g` valid (accepted) | proven | proven |
| V3r | V3, the name repaired to `17` | rejected | rejected |
| R2 | `f = missing`, `f()` as a statement (type `any`) | proven | proven |
| B2b | `f = missing`, `yield 48 + f()` (type `any`) | rejected | rejected |

(tested, `ec-provenance-structural-never`; the census corpus holds V3 to
V7). V5 is the demonstrated omission that justifies asking about a local
the walk binds: the walk evaluates `f`'s initializer, but `g`'s and `h`'s
bodies, which typed it, are no code the walk reads.

V3 is the same hole through a result instead of `never`: a certificate
true of the code (the unresolved call fails at run time, so `g` returns a
`Digit` or fails) but not of the repair V3r, whose claim is rejected. The
question is asked where the call's type is anything but `any` -- no fact
at all: R2 and B2b, whose callee is an unresolved name and whose type is
`any` -- or `unit`, one value. B2b stays the census's acknowledged
limitation: asking there makes R2 dependent too (`provenance-value-any-
checked`, a mutant that does so, is killed by R2's test).

No requirement is added that a structural type identify its functions, no
change to function-type joins or to `never`.

## 12. Independent contracts and irrelevant references

Kept as the census's appropriate verdicts (tested,
`ec-provenance-independent`):

| case | why it is independent | verdict |
|---|---|---|
| B3b | the unresolved branch is dead (`if true:`) | proven |
| B5 | `helper -> Digit` over an unresolved body: the declaration types the call | proven |
| B5 two calls down | `h2()` (inferred) calls `h1() -> Digit` (unresolved body): the declaration stops the chain | proven |
| Z1's neighbour | `k = 1` beside an unrelated `z = missing()` | proven |
| an unreachable declaration | `z = missing()` then `k = d3()`: unreachable, typed `Digit` by its own code | proven |
| SC2 | a rejected static block as a statement, then `k = 1` | proven |
| a check diagnostic | `k = boom()`, unhandled `Oops`, `boom -> Digit` | proven |
| R2 | `f = missing`, `f()` a statement: the proof uses nothing of `f` | proven |
| SC3 | the claimed function's own declared static block (accepted) | proven |

A mutant following a declared result into its body
(`provenance-declared-callee-followed`), one making every non-local fact
of an untrusted compilation dependent (`provenance-unrelated-taints`) and
one making a check diagnostic a source
(`provenance-check-diagnostic-source`) are each killed.

## 13. Reified diagnostics and reachability

A rejected `static compile:` block's diagnostic stays its block's
(tested, `ec-provenance-static-compile`, `-independent`, `-module-bindings`):

* **SC1**, a module binding whose initializer is a rejected block in value
  position, its CompilerError unhandled: the program's own UNHANDLED-ERROR
  (a resolution diagnostic, located at the reified `fail`) is a source:
  dependent;
* **SC2**, a rejected block as a statement before `k = 1`: `k`'s code is
  `1`: proven; the statement-position rule
  (`hir::static::reifiedStatement`) is unchanged;
* **SC3**, the claimed function's own block in value position, its
  CompilerError declared (accepted): proven;
* **a handled reified CompilerError** reached through an initializer --
  `k = safe()`, `safe` (inferred) handling `attempt()`, whose body holds the
  rejected block and declares CompilerError -- in a compilation holding an
  unrelated unresolved name: the scan passes through the reified `fail`,
  which carries no diagnostic, and the claim is certified; with
  `attempt` not declaring the error, its UNHANDLED-ERROR is the program's:
  dependent.

The reified UNBOUND inside a block is no diagnostic of the program at all,
so nothing can take it for a source; a mutant treating every reified
failure as one (`provenance-reified-escapes`) is killed by the handled
case.

Reachability: a dead branch inside a reachable initializer is skipped
(B3b); an initializer made unreachable by earlier code is read whole,
because inference typed it (section 4). An initializer made unreachable by
a recovery-derived `never` therefore depends exactly when it refers to
what that `never` left untyped (D1, D2, B8f), not merely because it
follows it (`z = missing()` then `k = 1`: proven).

## 14. Conservative dependency decisions

B3 (`k = if missing(): 1 else: 1`), B8b (the same, captured) and G1 (`k =
missing()`, the claim guarding `k` itself) are `dependent`. Each proof is
true of every repair of the program (the census, section 6), so this is a
recovery-verdict policy, not a finding that the claim is false:

* it is the rule the checker already applies to a claim's own code -- a
  claim whose walk reads a diagnosed expression is dependent, whether or
  not the trace depends on it (`ec-recovery-dependent`);
* telling the cases apart would need a counterfactual (would a narrower
  fact have changed the verdict?) that the walk does not compute;
* all three are rejected programs (strict: UNBOUND, tested), so a
  dependent verdict hides no certificate an accepted program would have.

The census record now states `appropriate dependent` for them, class U
kept. B3b (a dead branch), B5 (a contract), R2 (no fact read) and B8e (an
unrelated diagnostic) are not conservative cases and keep their
certificates.

## 15. Certificate and memo trust

**The rule.** `Reset` computes `trusted`: no resolution diagnostic, no
poison, no syntax-dependent reference -- exactly the compilations in which
no source exists, so in which every provenance question answers 0. A
compilation that is not trusted neither reuses a memoized certificate nor
memoizes one; a dependent claim was never memoized.

**Why reuse must be declined.** Provenance is no fingerprint: a
certificate depends on the canonical code of every function its proof
read, which records a non-local binding by name, exact Int value and type
fact, and every expression's type fact -- but not the initializer that
typed them, nor the bodies a structural type was joined from. V1 and V2
have equal fingerprints. A narrower, per-certificate rule would need a
provenance record in the certificate, a new format the brief rules out.

**Why storage is declined too.** Storing from an untrusted compilation is
sound (a stored certificate is reused only in a trusted compilation, where
the same fingerprints mean the same facts and every question answers 0);
it is declined anyway, as the brief's safe minimum states, so that no
certificate of a compilation with recovery-derived facts is ever kept. It
changes one census sequence: `signature`'s MR3 after MRM is now reused
(MRM no longer overwrites MR3's entry), where the parent proved it again.

**What keeps the memo.** A compilation whose only diagnostics are checks'
(ec-memo-reuse's second program holds an UNHANDLED-ERROR) is trusted: its
facts are complete. The census's prototype distinguished the same way but
took check diagnostics as sources, so a claim could be dependent fresh and
certified from the memo (section 2, gap 2); here the source set and the
trust set are one definition.

**Transitions** (tested, `ec-provenance-memo`, `-memo-trust`; every step's
verdicts equal to the memo off's):

| sequence | verdicts, reuse |
|---|---|
| V1, V2, V1 | proven fresh; dependent fresh; proven reused |
| `k = 1`, `k = missing()`, `k = 1` | proven fresh; dependent fresh; proven reused |
| `k = 1`, `k = 17`, `k = 1` (an exact value) | proven reused; rejected fresh; proven reused |
| `k = i17()` (`int`), `k = d3()` (`Digit`) (a type) | rejected fresh; proven fresh |
| `k = d3()` plus an unrelated `w = 2` | proven reused |
| Z1 (untrusted), Z1 repaired, again, Z1 | proven fresh, nothing memoized; proven fresh; proven reused; proven fresh |
| an unhandled-error program, twice | proven fresh; proven reused |
| `k = missing()` | dependent; nothing memoized |

The census's sequences agree (`binding`: R1 dependent fresh; `callable`:
V2 dependent fresh; `callable-narrow`: V3v fresh, V3 dependent fresh, V3v
reused; `trust`: Z1, Z1v fresh, Z1v reused, Z1 fresh). Mutants dropping
either half of the rule, or widening it to every diagnostic, are killed.

## 16. Compiler-service revisions

`ec-provenance-service` drives one workspace, the process's memo kept,
through seven revisions, and compares each claim's hover with a fresh
compilation's (memo off): a valid module binding (certified), its
initializer made unresolved (not checked), repaired (certified), an
unrelated function added (certified), a captured binding made unresolved
(not checked), V2 (not checked), V1 (certified) -- every hover equal to the
fresh one (tested). A dependent claim never shows a certificate; an
independent one is never made dependent by another declaration's
diagnostic. The hover's dependent text now says what the verdict means
when the diagnostic is in another declaration: "not checked -- its code,
or code whose facts it reads, holds another diagnostic".

## 17. HIR interchange

`ec-provenance-interchange` encodes R1, a dependent captured binding, V2
and V1, and decodes each with the memo on and off: every one reads back as
the same HIR (verified again by `hir::emission::reverify`: dependent,
dependent, dependent, proven). V2's dependent record forged `proven` with
V1's certificate is refused (`HIR INTERCHANGE EMISSION`), with the memo
holding V1's certificate: the untrusted compilation reuses nothing, so the
reader derives `dependent` and the text disagrees (tested; a mutant that
lets the untrusted compilation reuse is killed by this test too). No
field is added to the interchange format: the receiving process recomputes
every answer from the HIR.

## 18. Differential and mutation evidence

**The dependency census** (`audit/emission-dependencies/tools/census.tcl`,
every backend; `results/census.md`): 0 false certificates, 0 differences
from the updated record, 6 open cases (20 on the parent). The record's
changed `observed` lines are the 14 cases of section 1 and the `binding`,
`signature` and `callable` sequences; V3 to V7, L1, L1v, Z1v and the
`callable-narrow` and `trust` sequences are new.

Before and after, the census's 20 open cases:

| case | class | the parent | now | appropriate | |
|---|---|---|---|---|---|
| R1 | A | rejected | dependent | dependent | closed |
| B3 | U | proven+ | dependent | dependent | conservative (section 14) |
| B3c | A | rejected | dependent | dependent | closed |
| B6 | A | rejected | dependent | dependent | closed |
| D1 | A | rejected | dependent | dependent | closed |
| D2 | A | rejected | dependent | dependent | closed |
| G1 | U | proven+ | dependent | dependent | conservative |
| B8 | A | rejected | dependent | dependent | closed |
| B8b | U | proven+ | dependent | dependent | conservative |
| B8f | A | rejected | dependent | dependent | closed |
| X2 | A | rejected | dependent | dependent | closed |
| SC1 | A | rejected | dependent | dependent | closed |
| B2b | A | rejected | rejected | dependent | open: a value call's `any` result (section 23) |
| V2 | A, B | proven+ (reused after V1) | dependent | dependent | closed |
| S1 | A | rejected | rejected | dependent | open: a signature component |
| S4b | U | rejected | rejected | undecided | open: a signature component |
| S5b | U | proven+ | proven+ | undecided | open: a signature component |
| S5d | A | rejected | dependent | dependent | closed |
| S6b | U | proven+ | proven+ | undecided | open: a signature component |
| K1 | A | rejected | rejected | dependent | open: a native's result type |

Every other case of the corpus keeps its verdict, its strict outcome and
its certificate's dependencies; the four accepted false certificates the
identity milestone corrected (N2, N4b, F1, F3) stay rejected, their runs
invalid on every backend (observed).

**The existing differentials**, each compared with its committed result:

| tool | result |
|---|---|
| `audit/emission-claims/tools/census.tcl -part all` | identical but for the committed file's hand-written last sentence (no false proof; 31 of 31 mistakes decided as expected) |
| `audit/emission-claims/tools/fuzz.tcl -seeds 1-40` | byte-identical to `results/fuzz.md`: 0 false proofs |
| `audit/emission-claims/tools/loops.tcl -count 150 -seed 11 -cross 10` | the committed seed-11 section exactly but for its timing line: 25,350 runs, 0 false certificates, 0 regressions, 45 cross-backend checks agreeing |
| `audit/emission-identity/tools/structure.tcl -seeds 1-40` | identical to `results/structure.md`: 0 false certificates, 0 history differences |
| `audit/csv-emission/tools/differential.tcl -part all` | CSV-DIFF |
| `audit/csv-emission/tools/census.tcl` | CSV-CENSUS |

**Mutation.** Eighteen mutants were added to
`audit/emission-claims/tools/mutants.txt` (section "Binding provenance"),
one per way the rule could be wrong; six existing ones were updated to the
code they mutate, each still a mutant of its rule:

| mutant | what it does | killed by |
|---|---|---|
| `provenance-refvalue-unread` | a non-local binding's facts read without asking | module-bindings, captures, imported, ... |
| `provenance-unreachable-trusted` | an unreachable declaration skipped as dead code | module-bindings, captures, transitive |
| `provenance-alias-unfollowed` | an initializer naming a value binding not followed | module-bindings, captures, memo, service |
| `provenance-destructure-lost` | a projection no part of its value | module-bindings, captures |
| `provenance-capture-by-name` | a reference's binding taken by its spelling | captures |
| `provenance-clause-unread` | a loop element with no defining code | captures (L1) |
| `provenance-inferred-callee-ignored` | an inferred result no fact of its code | module-bindings, structural-never, memo |
| `provenance-declared-callee-followed` | a declared result followed into its body | independent, transitive |
| `provenance-value-never-unread` | V2's structural `never` believed | structural-never, memo, service |
| `provenance-value-result-unread` | V3's narrow result believed | structural-never |
| `provenance-value-any-checked` | a value call typed `any` asks (R2 dependent) | independent, structural-never |
| `provenance-reified-escapes` | every reified failure a source | static-compile |
| `provenance-unrelated-taints` | every non-local fact of an untrusted compilation dependent | independent, captures, memo-trust, ... |
| `provenance-check-diagnostic-source` | a check diagnostic a source | independent |
| `provenance-search-overmarks` | a found search marks every visited node | search |
| `provenance-memo-trusts-recovered` | an untrusted compilation reuses | memo, interchange |
| `provenance-memo-stores-recovered` | an untrusted compilation memoizes | memo-trust |
| `provenance-memo-every-diagnostic` | any diagnostic makes a compilation untrusted | memo-trust, ec-memo-reuse |

(test names abbreviated: `ec-provenance-*`). A poisoned binding's own check
has no mutant: `hir::types::Bind` poisons every alias and reference of a
poisoned value, which `Taint` reads, so removing it is equivalent (B4, B8d
and H1 stay dependent; inspection).

One existing mutant became equivalent and was made killable again:
`callee-nested-untainted` (the callee read only for a statement call)
survived the whole files, because an unresolved callee nested in an
expression is now also caught by the value call's provenance question. A
new test of the narrower invariant, `ec-callee-before-arguments` (an
unresolved name called with an argument that genuinely never returns: the
walk ends at the argument, before the call and before the provenance
question, so only the callee read first makes the claim dependent), kills
it.

The whole catalog, run by `audit/emission-claims/tools/mutate.tcl` on the
final tree: MUTANTS-ALL (`audit/emission-claims/results/mutants.md`).
`tools/mutant-catalogs.tcl`: CATALOGS.

## 19. JSON and CSV preservation

`examples/dfa/json/emit_probes.bot`'s 22 claims and
`examples/dfa/csv/probes.bot`'s 52 are certified, with the parent's summary
counts (JSON 140 computed, 60 reused, 44 rounds; CSV 207, 121, 104) and,
compiled twice in one process, every claim reused the second time (22 of
22, 52 of 52; observed). Neither workload reads a non-local binding or
calls through a value (the census's section 23), so no provenance question
is asked of either; both are trusted. `tests/csv-emission.test`: 36 of 36;
`tests/dfa-workloads.test`: 21 of 21. The counted-loop correction, the
`-1` result rule's removal, the `children`/`reads` distinction, the
named-callee dependency, `ReadsIdentified`, the feasibility flag, caller
independence, certificate re-verification and runtime erasure
(`ec-native-erasure`, `ec-identity-native-erasure`) are untouched
(inspection; their tests pass).

## 20. Performance

PERFORMANCE

## 21. Regression and CI results

REGRESSION

## 22. Production files changed

One: `hir/emission.tcl`. PRODLINES The Provenance section (`Dependent`,
`Provenance`, `Source`, `ScanCode`, `RefNode`, `DefiningCode`,
`ClauseMap`, `Operand`, and the readers' entry points), the source set and
`trusted` in `Reset`, the two readers in `RefValue` and `EvalCall`, the
memo rule in `CheckClaim`, the dependent hover text, and the header's
account of the verdict and the trust rule. No new abstract state, HIR form,
diagnostic, certificate field, interchange field or language construct.

Beside it: the tests (15 in tests/emission-claims.test: 14 `ec-provenance-*`
and `ec-callee-before-arguments`, and the changed hover text in
`ec-callee-service`), the mutants (18 added, 7 updated), the census record
(`audit/emission-dependencies/census/cases.txt` and its results), and
AGENTS.md's emission rules.

## 23. Remaining cases and limitations

* **Signature components (S1, S4b, S5b, S6b).** An unresolved parameter,
  result or error type is dropped to `{}`, exactly what an omitted one is,
  with a diagnostic on the function block that does not say which
  component. S5d is closed because its signature is met through a binding's
  initializer (`{f E}` with E itself a source); a claimed or called
  function's own unresolved parameter type (S1, S4b) would need a
  component-level record the HIR does not hold, and S5b and S6b's verdicts
  depend on how the signature is repaired. A captured parameter of an
  enclosing function whose type is its inferred contract is the same kind
  of fact (not tested).
* **A value call's `any` result (B2b).** The call's value is used, and it
  is a placeholder's; but asking at a value call typed `any` makes R2, whose
  value is unused, dependent too, and telling them apart needs to know
  whether the value is used: value provenance, which the brief rules out.
* **A native's result type (K1).** A coroutine construction's outward type
  flows through `coroutine#start`'s result, not through a binding or a
  value call.
* **Facts through types other than a call's own.** The question is asked at
  the readers that consume a fact of code the walk does not read: a
  non-local binding, and a value call's type. A structural function value
  flowing into a native whose result type is computed from it is not asked
  about; no native observed gives it a `never` (`std::mutable_array::
  generate` with V2's `f` is rejected, the walk going on past it), and the
  call reads the value itself, which is asked about when it is a non-local
  binding (observed).
* **The memo in rejected programs.** An untrusted compilation proves every
  claim again; an editor session with an unresolved name anywhere loses
  reuse for that revision (section 20).

## 24. Recommendation

RECOMMENDATION

## 25. Final evaluation questions

**1. Is the V2 recovery-derived `never` certificate hole closed?** Yes, in
every compilation history tested: V2 fresh, after V1, after V1 and the
memo kept across seven compiler-service revisions, through interchange
with the memo on and off. No tested history reuses a proof that relied on
incomplete callable provenance: the untrusted compilation reuses nothing,
and a fresh analysis asks (tested). The hole had four more forms (V3-V6),
closed by the same question.

**2. Does binding provenance follow the right dependencies?** It follows
what typed the facts -- defining code, the value bindings it names, the
bodies of functions that declare no result -- and stops at a declared
result, a parameter, a dead branch and an unrelated diagnostic (sections
8-13, each pinned by tests and killed mutants). It names bindings by
identity, so two scopes' `k`s are told apart.

**3. How conservative is the solution?** Three census cases (B3, B8b, G1)
become dependent although their certificates would hold under every
repair; they are rejected programs, the rule is the one a claim's own code
already gets, and telling them apart needs a counterfactual analysis
(section 14). The memo is declined for every claim of an untrusted
compilation, also an independent one (Z1): that costs a re-proof, never a
verdict.

**4. Are certificates trustworthy across edits?** Fingerprints catch what a
proof read of the code (exact values, type facts, reachability);
provenance, which no fingerprint records, makes a compilation untrusted,
and an untrusted compilation neither reuses nor stores. Valid programs and
programs whose only diagnostics are checks' keep ordinary reuse (tested).

**5. Were accepted programs preserved?** Yes: no accepted program asks a
question that searches, JSON's and CSV's certificates, the identity and
feasibility corrections, the census's accepted cases, the fuzzer, the loop
differential and the structural audit are unchanged (section 18, 19).

**6. Which cases remain open?** Signature-component provenance (S1, S4b,
S5b, S6b), an ordinary value call's `any` result (B2b), a native's result
type for coroutines (K1); no recovery-policy question beyond the three
conservative cases.

**7. Is more general provenance machinery warranted?** No. Every case
closed here was closed by asking where a fact read from unwalked code came
from, over the HIR's own references, with the existing taint flag; the
remaining ones need either a signature-component record (a HIR change for
four rejected-program verdicts) or value provenance (to separate B2b from
R2), and neither is demonstrated to protect a certificate: no remaining
case certifies anything.
