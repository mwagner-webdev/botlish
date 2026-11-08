# Emission identity and feasibility correctness, milestone 1

Corrects the two accepted-program soundness failures
EMISSION-BINDING-AND-SIGNATURE-DEPENDENCY-CENSUS-MILESTONE-1.md found in the
emission checker (`hir/emission.tcl`): a function identified by its bare
binding name in the certificate memo, the certificate table and a
certificate's dependencies; and a feasible branch through an empty
environment taken for an infeasible one. Both let the compiler accept a
program whose certified emitter yields a symbol its recognizer rejects, on
every backend.

The milestone changes one production file, adds no HIR field, language
construct, diagnostic, certificate format or dependency structure, and
defers the census's binding and signature provenance (its section 21.3).

Evidence is labelled throughout:

* **observed** -- seen in a running accepted program (its claims erased,
  its trace judged by the reference interpreter, tests/dfa-support.tcl);
* **inspection** -- established by reading the code;
* **tested** -- pinned by a regression test of tests/emission-claims.test;
* **inferred** -- follows from the design, not run;
* **not tested** -- said, not checked.

1. [Result](#1-result)
2. [The original accepted-program false certifications](#2-the-original-accepted-program-false-certifications)
3. [Function identity in HIR and the emission verifier](#3-function-identity-in-hir-and-the-emission-verifier)
4. [Memo and certificate lookup defects](#4-memo-and-certificate-lookup-defects)
5. [The corrected ambiguous-name handling](#5-the-corrected-ambiguous-name-handling)
6. [Certificate composition and validation](#6-certificate-composition-and-validation)
7. [Empty environment versus infeasible branch](#7-empty-environment-versus-infeasible-branch)
8. [The corrected Facts and EvalIf behavior](#8-the-corrected-facts-and-evalif-behavior)
9. [Parameterless and nested-helper regressions](#9-parameterless-and-nested-helper-regressions)
10. [Memo-history independence](#10-memo-history-independence)
11. [Compiler-service revisions](#11-compiler-service-revisions)
12. [HIR interchange and forged certificates](#12-hir-interchange-and-forged-certificates)
13. [Differential and structural fuzzing](#13-differential-and-structural-fuzzing)
14. [Mutation evidence](#14-mutation-evidence)
15. [JSON and CSV preservation](#15-json-and-csv-preservation)
16. [Native-code erasure](#16-native-code-erasure)
17. [Compilation performance](#17-compilation-performance)
18. [Production files changed](#18-production-files-changed)
19. [Remaining limitations and the shortcut audit](#19-remaining-limitations-and-the-shortcut-audit)
20. [Recommendation](#20-recommendation)
21. [Final evaluation questions](#21-final-evaluation-questions)

## 1. Result

Both defects are corrected, and a third, smaller one the census's prototype
left in its identity correction is closed with them:

* **Identity.** A name bound by more than one function block of a
  compilation now identifies neither: no memo entry is reused or stored for
  a claim of such a name, no certificate is published under it, composed
  with through it or validated through it, and -- the rule the census's
  prototype lacked -- no proof that *read* a function of such a name is
  memoized. Each falls back to walking the code the claim or call actually
  names.
* **Feasibility.** `hir::emission::Facts` answers `{FEASIBLE ENVIRONMENT}`;
  `EvalIf` tests the flag. An environment with no binding is a feasible
  path's environment.

What the record shows:

| | before | after |
|---|---:|---:|
| false certificates, the census corpus (`audit/emission-dependencies/tools/census.tcl`) | 4 | 0 |
| false certificates, the milestone's own N6 sequence | 1 (on the parent and under the census's prototype) | 0 |
| false certificates, the structural audit, 40 seeds | 43 (and 10 programs whose verdicts depend on history) | 0 (0) |
| JSON workload claims certified | 22 of 22 | 22 of 22, certificates identical but for the front-end fingerprint |
| CSV workload claims certified | 52 of 52 | 52 of 52, likewise |
| emission tests (tests/emission-claims.test) | 110 | 123, all passing |
| emission mutants (audit/emission-claims/tools/mutants.txt) | 86 | 101, every one killed (the whole catalog run) |

The census's other cases are unchanged: the 20 open ones that remain are
its class A and undecided binding and signature cases, which this milestone
defers (section 19).

## 2. The original accepted-program false certifications

Reproduced on the milestone's parent (53a0d1b) by
`audit/emission-identity/tools/repro.tcl`
(`results/repro-before.md`) and the census tool. Every run below is of the
program with its claims erased (`emit::strip`), on interp, compile,
cranelift-generic and cranelift, one trace on all four:

| case | shape | verdict | strict | trace | judged | evidence |
|---|---|---|---|---|---|---|
| N1 | `outer1.inner` (yields '1') and `outer2.inner` (yields 'A'), both claimed | proven, proven | accepted | -- | (no run) | observed (compilation), tested |
| N2 | a top-level `emitter` ('1') and `outer.emitter` ('A') | proven, proven | accepted | `[65]` | invalid | observed |
| N3 | `outer.inner` and `outer.if.inner`, shadowing | proven, proven | accepted | -- | (no run) | observed (compilation), tested |
| N4b after N4a | an edit of `outer2.helper` ('1' to 'A'), compiled after the unedited program, the memo kept | proven, reused | accepted (fresh: EMIT-REJECTED) | `[65]` | invalid | observed |
| N6b after N6a | the milestone's own (section 4): a proof that read the nested and the top-level `step`, then the nested one removed; false on the parent and under the census's prototype | proven, reused | accepted (fresh: EMIT-REJECTED) | `[65, 65]` | invalid | observed |
| F1 | `if flip(): yield 65 else: yield 66`, no parameters | proven | accepted | `[65]` | invalid | observed |
| F2 | `yield 49` then `if true: yield 65` | proven | accepted | -- | (no run) | observed (compilation), tested |
| F3 | a caller of the parameterless helper `if true: yield 65` | proven | accepted | `[65]` | invalid | observed |

What the checker decided on the way (`results/repro-before.md`):

* **N1, N2, N3.** Both claims have the memo and certificate key `{inner
  digit_token}` (`{emitter digit_token}`). `byName(inner)` is the first
  block (`e40`). The second claim finds the first's certificate in the
  memo, and `Valid` compares the fingerprint the certificate recorded
  (`daeb37952ee62ae2`, the first block's) with the fingerprint of
  `byName(inner)` -- the first block again -- never with its own
  (`f3ccd56d2ea42ae0`). It is certified from the first's result, never
  analyzed. With the memo off, it is analyzed and rejected.
* **N4a then N4b.** N4a's certificate depends on `emitter` and `helper`,
  the helper's fingerprint `9addd5a2a5042bd1` (outer2's helper, yielding
  '1'). In N4b the name `helper` has two blocks: outer1's, still
  `9addd5a2a5042bd1`, and outer2's, now `b3fa375aa4c22bcf`. `Valid` looks
  `helper` up in `byName`, gets outer1's, finds it unchanged, and reuses
  the certificate.
* **F1 to F3.** Every `Facts` call ran in an environment of 0 bindings and
  returned the empty string, with hir::range's paths `{e43=1 (unknown)}` and `{e43=0
  (unknown)}` (F1) or the known outcome of `true` (F2, F3). `EvalIf` read
  `""` as "no path is feasible" on both outcomes and returned no states:
  the walk ended at the `if`, every certificate stating `exits {}` ("never
  completes normally"). Three of the milestone's own programs show the same
  (P1: `if false: yield 65 else: yield 49`; P2: digits on both branches;
  P3: `if flip(): yield 49` with no else): all three certified with `exits
  {}`, vacuously -- their runs are valid (`[49]`), so they are no false
  certificates in the running sense, but no proof either.

## 3. Function identity in HIR and the emission verifier

**HIR (inspection).** A function is a `block` expression; its identity is
its ExprId (`e40`). It is declared by a `bind` whose binding
(`bindings BID {kind local name NAME scope SID declaredBy EID}`) gives it
its name, in the scope of the enclosing block, branch or loop. Module
functions' names are qualified (`a::emitter`); a function nested in a
function, or declared in an `if` or loop of one, has its bare name, and
hygiene renames none of them. So one file can bind one name to several
blocks: a top-level and a nested function, two nested ones, one shadowing
another.

**The verifier (inspection).** Everything a single compilation's analysis
keys is keyed by block: summaries (`{BLOCK STATE ARGS}`), fingerprints,
argument contexts, guards, the claims of a block, a callee's target. What
crosses a compilation is keyed by *name*, because ids are not stable
across builds: `names` (block to name, from the declaring bind), `byName`
(name to the first block of it), the memo (`{NAME RECOGNIZER}`), the
compilation's certificate table `certs` (the same key), a certificate's
`depends functions` (name to fingerprint), its certificate dependencies
(`{NAME RECOGNIZER STATEMENT}`), and the canonical text, which records a
callee or a nested function as `fn NAME`.

A name is a sound key exactly when it identifies one block in the
compilation that writes the key and in the one that reads it. Nothing
checked that.

## 4. Memo and certificate lookup defects

Every use of `names`, `byName`, `FunctionName`, `certs` and `memo` in
`hir/emission.tcl`, and of `hir::emission::` elsewhere (the compiler
service, interchange, `hir::BuildFull`; the audit tools only read), was
read (inspection). The name-keyed uses, and what each did with a name of
two blocks:

| where | use | defect | case |
|---|---|---|---|
| `Reset` | `byName` keeps a name's first block | the second block is unreachable by name, and nothing knows | all |
| `CheckClaim`, reuse | the memo looked up by `{NAME RECOGNIZER}` | another block's certificate found | N1, N2, N3 |
| `CheckClaim`, storage | `certs` and the memo written by `{NAME RECOGNIZER}` | one block's certificate published for every block of the name | N1 (in-compilation) |
| `UsableCertificates` | a callee's certificate found in `certs` by its name | composition with another block's certificate | the `ec-identity-composition` program (`b`, section 6) |
| `Certificate` | `depends functions` keyed by name | two blocks of the name in one read set leave one fingerprint | N5, N6 |
| `Valid`, functions | a dependency's fingerprint compared with `byName(NAME)`'s | validated against the first block of the name | N1, N4b |
| `Valid`, certificates | a certificate dependency looked up in `certs` by name | validated against whichever block published | `ec-identity-certificate-dependency` |
| memo storage | a proof stored whatever its read set | N6: a proof that read two blocks of a name is validated, later, against the one block the name then has | N6b |

The census named four loss points (its section 13.3) and judged N5
harmless, because "the identity correction refuses to validate an ambiguous
name". The last row shows why that is not enough. The census's prototype
(its section 21.1) refused validation by an ambiguous name *in the
validating compilation*; but a certificate whose read set had two blocks of
a name was still memoized, its `functions` dict holding one fingerprint for
both. In a later compilation the name may identify one block -- the other
removed -- and the claimed function's own text be unchanged (a call is
`fn step` in its canonical text). The prototype then validates against the
fingerprint it happened to record:

```botlish
fn step() -> unit:        # the top-level step: a letter
    yield 65
    unit

fn g() -> unit:
    step()
    unit

fn outer() -> List[int]:
    fn step() -> unit:    # N6a only: the nested step, a digit
        yield 49
        unit
    fn emitter() -> int emits pair_token:
        step()
        g()
        0
    ...
```

N6a is certified (its run yields `49 65`, a digit then a letter: ok). Its
certificate depends on `emitter`, `g` and `step` -- one fingerprint for
`step`, the top-level one's (`f3ccd56d2ea42ae0`, the last written). N6b
removes the nested `step`: `emitter`'s fingerprint is the same, `step` now
names the top-level block alone, whose fingerprint is the one recorded.
Under the prototype, N6b reuses the certificate and is accepted; its run
yields `65 65` (observed, on interp and cranelift, with the prototype's
21.1 and 21.2 applied to a copy of the tree). The original compiler does
the same. The correction does not memoize N6a's proof (section 5); N6b is
proved again and rejected (tested: `ec-identity-read-set`; the census's new
sequence `identity-read`).

No other name-keyed use exists (inspection): recognizers are top-level
declarations (`dfa` is refused elsewhere by the parser) with module-
qualified keys; guards, claims of a block, summaries, contexts and
fingerprints are keyed by block; a function without a name (none can carry
a claim: `emits` is parsed only on a named `fn`) has the name "", which
`Valid` always reported "gone".

## 5. The corrected ambiguous-name handling

`Reset` records every name two function blocks share (`ambiguous`), and one
predicate decides what a name may do:

```tcl
proc hir::emission::Identified {b} {
    variable ambiguous
    set name [FunctionName $b]
    return [expr {$name ne "" && ![dict exists $ambiguous $name]}]
}
```

| decision | rule |
|---|---|
| memo reuse of claim B | only when `Identified B` |
| publishing B's certificate in `certs` | only when `Identified B` (the record holds it either way) |
| memoizing B's certificate | only when `Identified B` and every function of its read set is identified (`ReadsIdentified`) |
| composing with callee T's certificate | only when `Identified T`; otherwise T's body is walked |
| `Valid`: a function dependency | refused when its name is ambiguous here |
| `Valid`: a certificate dependency | refused when its function's name is ambiguous here |

So a claim of an ambiguous name is always proved from its own code, and a
valid one is still certified (N1's first claim, both of
`ec-identity-memo-history`'s accepted program's): only the reuse is
declined. Uniquely named claims keep every reuse they had, also in a
program with duplicate names elsewhere (tested: `ec-identity-qualified-
reuse`'s `dup.bot`; `ec-identity-service`'s `good`), and module-qualified
names (`a::emitter` beside `b::emitter`) are identified, memoized and
reused as before (tested).

A stable lexical identity for nested functions -- one surviving edits and
compiler-service revisions -- would keep the declined reuses. The HIR has
none, and none is needed for soundness; it is not introduced (the brief's
section 3).

## 6. Certificate composition and validation

**Composition.** `Apply` asks `UsableCertificates T` for the target block
the call names; for an ambiguous T it answers none, and T's body is walked
from each entry state, exactly as for a helper without a claim. In
`ec-identity-composition`'s program four functions are named `h` (a
top-level one yielding '1', outer1's '2', outer2's 'A', outer4's '2'), each
claiming `digit_token`:

| claim | calls | before | after |
|---|---|---|---|
| outer2's `h` | -- | proven (the memo: the first `h`'s certificate) | rejected |
| outer2's `b` | outer2's `h` | proven (composed with the first `h`'s certificate) | rejected |
| outer4's `both` (two digits) | outer4's `h`, then g, which calls the top-level `h` | proven | proven (both bodies walked), not memoized |
| `e` | the top-level `stop`, which never returns | proven | proven, not memoized (its proof read `stop`, a name of two functions) |
| outer5's `d` | outer5's `stop`, which returns | rejected | rejected |
| `solo` | nothing | proven, memoized | proven, memoized |

The walk itself was never confused about which block a call means (its
target is the block; inspection): only the name-keyed tables were. That is
why the never-returning `stop` and its returning namesake were decided
right before the correction too (`e`, `d`).

**Validation.** `Valid` refuses a function or certificate dependency whose
name is ambiguous in the validating compilation; `ReadsIdentified` keeps a
certificate whose read set was ambiguous in the proving compilation out of
the memo. Together: a memoized certificate's names each identified one
block when it was proved, and each identifies one block where it is
reused, so its fingerprints compare the code its proof read with the code
the name now means (inferred from the two rules; tested by
`ec-identity-memo-sequence`, `-read-set`, `-certificate-dependency`).

**Defence in depth (inspection, and the mutants of section 14).** Two
pairs of guards are each redundant on their own: an ambiguous name never
publishes a certificate *and* composition and certificate dependencies
refuse it; an ambiguous claim is never looked up in the memo *and* `Valid`
refuses it (a certificate always depends on its own function's name). Each
pair's mutant removes both guards.

## 7. Empty environment versus infeasible branch

The walk's environment is a dict from the bindings the walk itself bound --
parameters, locals, loop variables -- to their value sets. A function
without parameters starts with `[dict create]`, whose text is "". `Facts`
answered the environment on the feasible paths and "" when none was
feasible, so it answered "" both for "infeasible" and for "feasible, with
nothing bound yet" (inspection). The two are different facts: the first
says no execution reaches the branch, the second says nothing about the
values and everything about reachability.

## 8. The corrected Facts and EvalIf behavior

```tcl
    set result ""
    set feasibleAny 0
    foreach path [hir::range::Paths $hir $condition $outcome] {
        ...                       ;# each path narrowed, or found infeasible
        if {!$feasible} continue
        if {!$feasibleAny} {
            set result $penv
            set feasibleAny 1
        } else {
            set result [JoinEnv $result $penv]
        }
    }
    return [list $feasibleAny $result]
...
        lassign [Facts $cond $outcome] feasible facts
        if {!$feasible} continue
```

The path machinery is unchanged: hir::range's `Paths`, `KnownOutcome` and
the walk's own narrowing (`hir::intset::Narrow`) still decide each path,
and the join of several feasible paths is still `JoinEnv`. What
`ec-feasibility-flag` pins of `Facts` directly (tested):

| condition, environment | outcome 1 | outcome 0 |
|---|---|---|
| `flip()`, empty | `1 {}` | `1 {}` |
| `true`, empty | `1 {}` | `0 ...` |
| `d < 0`, d in 0..20 | `0 ...` | `1 {d {{0 20}}}` |
| `d < 3 or d > 12`, d in 0..20 | `1 {d {{0 2} {13 20}}}` (both paths joined) | `1 {d {{3 12}}}` |
| `d < 0`, d with no value | `0 ...` | `0 ...` (no completion manufactured) |

`EvalIf` is `Facts`'s only caller (inspection; `audit/emission-
dependencies/tools/counts.tcl` wraps it and forwards the result). The other
places where an empty value could be read as an absence were read too
(section 19.1); none decides feasibility.

## 9. Parameterless and nested-helper regressions

Run against a copy of the tree with the parent's `hir/emission.tcl`, 11
of the milestone's 13 new tests fail; the two that pass there,
`ec-identity-qualified-reuse` and `ec-identity-native-erasure`, pin what
must not change. All 13 pass on the milestone. The feasibility ones:

* `ec-feasibility-empty-environment`: F1 (EMIT-REJECTED), F2
  (EMIT-AFTER-TOKEN), F3 (through its caller, EMIT-REJECTED) rejected, F4
  unchanged; a parameterless claim decided false, or with a digit on both
  branches, certified with `exits done` (it was `exits {}`); F1's and F3's
  runs are `[65]`, invalid.
* `ec-feasibility-shapes` (22 claims, each in an empty environment unless
  named otherwise): an `if` decided true (with and without a dead `else`)
  or false (with and without an `else`) certified; unknown with a letter on
  one branch rejected; unknown with no else EMIT-INCOMPLETE; nested valid
  and invalid; one branch failing (certified) or failing after a letter
  (rejected); one returning (certified) or returning before any symbol
  (EMIT-INCOMPLETE); an `if` followed by a letter; an `if` after the token;
  a parameterless helper with a digit on both branches (its caller
  certified) and with a letter on one (rejected); an `if` after a handled
  call's join and after another `if`'s join, both leaving the environment
  empty (rejected); a local bound before the `if` (`x = pick()`, certified,
  and `48 + x` with x in {7, 70}, rejected) and a parameter (certified),
  as before; an `or`'s two feasible paths, the out-of-range symbols on the
  first or the second (both rejected).
* `ec-feasibility-flag`: the table of section 8.

On the parent every claim of `ec-feasibility-shapes` is certified, valid
or not. One of them shows a third route of the defect: `local_unbounded`'s
`pick()` is a parameterless helper whose `if` killed its walk, so its
result was the empty set, `x` had no value, both outcomes of `x > 5` were
infeasible, and the claim was certified vacuously.

## 10. Memo-history independence

`ec-identity-memo-history` compiles three final programs -- a rejected one
(outer1's and outer2's `emitter`, the second yielding 'A', beside a
uniquely named `good`), its accepted version, and N4b -- each after six
histories: a fresh process (a child tclsh), an empty memo, a program whose
unique top-level `emitter` has the code of the first of the two, one whose
`emitter` is nested in another scope with other code, the program's
earlier version, a version whose code differs elsewhere (`good`'s body, or
N4a with a helper renamed), and the unrelated JSON library. For each it
compares every claim record (verdict, certificate), every diagnostic
(kind, origin, message) and the strict outcome with the empty memo's, and
runs the program:

| final program | fresh / unique / another scope / earlier / changed / unrelated: equal to the empty memo's | verdicts | strict | run |
|---|---|---|---|---|
| rejected | 1 1 1 1 1 1 | proven, proven, rejected | EMIT-REJECTED | `[65]` invalid |
| accepted | 1 1 1 1 1 1 | proven, proven, proven | accepted | `[50]` ok |
| N4b | 1 1 1 1 1 1 | rejected | EMIT-REJECTED | `[65]` invalid |

On the parent the last row is `1 1 1 0 0 1`: N4b is certified after N4a
and after N4a with unique helper names, rejected otherwise (tested; the
first two rows are wrong there under every history -- the defect is within
the compilation). Memo hit counts are not compared: whether a certificate
is reused is the optimization's business (the accepted program's `good` is
reused after the `unique` history, and its record is the same).

The memo is the checker's only state that survives a compilation (`Reset`
clears the rest; inspection), so a fresh process and an empty memo are the
same starting point for it; the test runs both anyway.

## 11. Compiler-service revisions

`ec-identity-service` drives `service::workspace`, `setDocument`,
`analyze`, `diagnostics` and `at` (hover) through seven revisions, the
process's memo kept: two valid same-named emitters beside `good`; one made
invalid; repaired; the other edited; a third of the name added in another
scope, invalid; the ambiguity removed (one renamed, the third gone); an
unrelated edit. At each revision every claimed function's hover says what a
fresh compilation (memo off) of the revision's text decides; the invalid
revisions report EMIT-REJECTED and show "rejected" on the invalid emitter
only; `good` is certified throughout and reused from the second revision
on; nothing of the ambiguous name is reused until the ambiguity is gone,
when the two now-unique emitters are proved fresh once and reused in the
next revision (tested). On the parent, revisions 2 and 5 show "certified"
for the invalid emitter and no diagnostic. No service code changed: the
hover reads the revision's records, which the checker now derives
correctly.

## 12. HIR interchange and forged certificates

`hir::emission::reverify` re-runs the checker on the decoded HIR, in the
reading process, with its memo. `ec-identity-interchange` writes N2, a
pair of parameterless conditional emitters (F1's invalid one and a valid
one) and N4b as interchange text and reads each back:

| program | read, memo on | read, memo off | read by another process | a forged certificate, memo on / off |
|---|---|---|---|---|
| N2 | kept | kept | proven, rejected | refused / refused |
| F1 and a valid one | kept | kept | rejected, proven | refused / refused |
| N4b | kept | kept | rejected | refused / refused (N4a's stale certificate) |

The forged text marks every unproven claim proven with a proven claim's
certificate (for N4b, the certificate N4a was given). "kept" means the
decoded HIR equals the encoded one. On the parent (tested against a copy of the tree), N2 read with the memo
on repeated the false certificate, with it off refused the text, a fresh
process derived "proven, proven" (its own memo reusing within the
compilation), and the forged version was accepted with the memo on; F1's
two claims were both certified, vacuously, so its text had nothing to
forge and every reader accepted it; N4b, compiled without history, was
rejected there too. The
certificate format is unchanged: no certificate text is ever believed, and
the reader's derivation is now independent of its memo (tested).

## 13. Differential and structural fuzzing

**The structural audit** (`audit/emission-identity/tools/structure.tcl`)
generates the shapes the existing fuzzers never made (EMISSION-BINDING-
AND-SIGNATURE-DEPENDENCY-CENSUS-MILESTONE-1.md, section 1): functions at
the top level and nested in two or three outer functions, drawn from a
pool of four names, so names are shared across scopes and shadow; claims
with zero, one or two Bit parameters, most beginning with an `if` before
any binding; conditions known, switched (`s1()`, an unknown call whose
body the run assigns) or on a parameter; token-shaped bodies (a digit; a
digit then a letter) built from yields, nested `if`s and helpers of known
kinds, with and without claims of their own, a third of the claims with
one injected fault. Each program and an edited version (a helper's symbol
changed, or a nested helper that shadows a top-level one removed: the N6
shape) is decided under four switch assignments with a fresh memo, with
the memo off, and after the other version (the memo kept, both directions,
two rounds); every claimed emitter of both is run, inside its own scope,
for every argument tuple of every assignment (interp), and judged.

Forty seeds (`results/structure.md`, `structure-before.md`,
`structure-prototype.md`):

| | the parent | the census prototype (21.1 + 21.2) | this milestone |
|---|---:|---:|---:|
| programs (one discarded: its edited version's erased form does not type-check) | 39 | 39 | 39 |
| claims (both versions) | 330 | 330 | 330 |
| parameterless claims | 178 | 178 | 178 |
| claims whose name is shared | 294 | 294 | 294 |
| runs | 2,604 | 2,604 | 2,604 |
| certified / rejected | 267 / 63 | 222 / 108 | 222 / 108 |
| **false certificates** (claims with an invalid run) | **43** | 0 | **0** |
| **programs whose verdicts depend on history** | **10** | 0 | **0** |
| rejected, an invalid run confirms | 63 | 106 | 106 |
| precision losses (rejected, every run valid) | 0 | 2 | 2 |

The 45 claims the parent certified and this milestone rejects are its 43
false certificates and two precision losses -- one claim, counted in the
program and its edited version (seed 9, outer2's `e`). Its body is `if not
s2(): if s2(): yield 50; yield 66 else: yield 49 else: g()`: the inner
`s2()` repeats the outer call, so no run takes the two-symbol path, but the
checker gives two calls' outcomes no relation and rejects it (observed: the
program in `-keep`; an abstraction limit the brief keeps, not a defect).
The parent certified it by reusing the certificate of another function
named `e`. The audit found nothing beyond the two
defect families: every one of the parent's false certificates and history
differences disappears with them. It did not find the prototype's gap
either: the read-set shape needs a proof that reads both functions of a
name, then an edit that removes one, and the generator did not produce it
in these seeds; the targeted test and the census sequence do (section 4).

**The existing differentials** (run on this milestone, compared with their
committed results):

| tool | result |
|---|---|
| `audit/emission-dependencies/tools/census.tcl` | 0 false certificates (4 before); 0 differences from the updated record; 20 open cases (26 before: N1, N2, N3, F1, F2, F3 closed) |
| `audit/emission-claims/tools/census.tcl -part all` | every row identical to the committed `results/census.md` (no false proof; 31 of 31 mistakes decided as the exploratory checker did); only the committed file's hand-written last sentence differs |
| `audit/emission-claims/tools/fuzz.tcl -seeds 1-40` | byte-identical to the committed `results/fuzz.md`: 320 claims, 41,600 runs, 0 false proofs |
| `audit/emission-claims/tools/loops.tcl -count 150 -seed 11 -cross 10` | the committed seed-11 summary exactly: 150 cases, proven 32, 25,350 runs, 0 false certificates, 0 regressions, 4 precision limits, 45 cross-backend checks agreeing |
| `audit/csv-emission/tools/differential.tcl -part all` | identical to the committed `results/differential.md` but for its timings: every part, 0 backend disagreements, 0 recognizer rejections, 0 failures |
| `audit/csv-emission/tools/census.tcl` | byte-identical to the committed `results/census.md`: 26 mutants, 26 as stated |

## 14. Mutation evidence

Fifteen mutants were added to `audit/emission-claims/tools/mutants.txt`,
each a way a certificate could be false again (the brief's section 13):

| mutant | what it does | killed by |
|---|---|---|
| `ambiguous-first-only` | no name is recorded ambiguous | every `ec-identity-*` test it ran |
| `ambiguous-reused` | the memo looked up for an ambiguous claim, and `Valid` taking the name's first block | `ec-identity-memo-history` |
| `ambiguous-stored` | every proven claim memoized | `-read-set`, `-composition`, `-memo-sequence` |
| `memo-read-set-unchecked` | the prototype's rule: a proof that read an ambiguous name memoized when its own name is unique | `-read-set`, `-composition`, `-memo-sequence` |
| `ambiguous-validated` | `Valid` takes an ambiguous dependency's first block | `-memo-sequence`, `-memo-history` |
| `ambiguous-composed` | composition through the name, and publication under it | `-composition` |
| `ambiguous-certificate-validated` | a certificate dependency validated through an ambiguous name, and publication under it | `-certificate-dependency` |
| `facts-env-as-feasibility` | the census's defect | `ec-feasibility-empty-environment`, `-shapes` |
| `facts-empty-skipped` | a feasible path with an empty environment dropped | `-empty-environment`, `-flag`, `-shapes` |
| `facts-empty-feasible` | every empty-environment path feasible | `-empty-environment`, `-flag`, `-shapes` |
| `facts-infeasible-explored` | every outcome feasible | `-empty-environment`, `-flag`, `-shapes` |
| `facts-known-ignored` | a known comparison does not decide its path | `-empty-environment`, `-flag`, `-shapes` |
| `facts-first-path-only` | only the first feasible path's environment kept | `-flag`, `-shapes` |
| `facts-last-path-only` | the last feasible path's environment replaces the others' | `-flag`, `-shapes` |
| `facts-helper-exits-dropped` | in a function without a claim, a feasible empty-environment branch skipped (F3) | `-empty-environment`, `-shapes` |

Three guards are redundant in pairs (section 6), and a mutant of one guard
alone is equivalent: the first version of `ambiguous-reused`, which removed
only the memo's guard, survived both test files whole, because `Valid`
refused the reused certificate through its own function's ambiguous name.
The catalog keeps the pair mutants. No mutant that only changes a reuse
count is listed.

The whole catalog, run by `audit/emission-claims/tools/mutate.tcl` on this milestone: 101 mutants, 101 killed, 0 survived (`audit/emission-claims/results/mutants.md`). `tools/mutant-catalogs.tcl`: 90 catalogs,
3,192 mutants, every one applying.

## 15. JSON and CSV preservation

`examples/dfa/json/emit_probes.bot`'s 22 claims and
`examples/dfa/csv/probes.bot`'s 52 (and `export.bot`'s, the same 52) are
certified before and after. Every certificate is the same dict but for
`depends checker`, the front end's fingerprint (`hir::interchange::
fingerprint`, which covers `hir/emission.tcl` itself): with that field
blanked, the 74 certificates are byte-identical (observed). The summary
counts are identical too: JSON 140 computed, 60 reused, 44 rounds; CSV
207, 121, 104 (section 17). Neither workload has a duplicate function name
or reaches an `if` in an empty environment (the census's section 23), and
so neither runs a line of the correction beyond a dictionary lookup.
`tests/csv-emission.test`: 36 of 36.

## 16. Native-code erasure

A claim changes no code. `ec-native-erasure` (the JSON emitters) and the
new `ec-identity-native-erasure` (N4a; two same-named nested emitters
beside a unique claim; parameterless claims beginning with an `if`)
compare `native::fusedNir` of each program with and without its claims:
identical, with no `dfa#transition` (tested). The correction is in the
checker, which no backend reads; no runtime check, coroutine object or
identity guard is added (inspection).

## 17. Compilation performance

`audit/emission-identity/tools/bench.tcl` (`results/bench.md`,
`bench-before.md`): the checker's own time, five fresh processes per
program, medians (ms), on a 4-core container with nothing else running:

| program | the parent: median (range) | this milestone: median (range) | summaries computed / reused, rounds (both) |
|---|---|---|---|
| JSON, 22 claims | 218 (205-311) | 230 (220-307) | 140 / 60, 44 |
| CSV, 52 claims | 549 (505-629) | 582 (539-674) | 207 / 121, 104 |

Compiled twice in one process, the memo kept (checker ms, first / second;
claims the second compilation reused):

| program | the parent | this milestone |
|---|---|---|
| JSON | 210 / 30; 22 of 22 | 293 / 31; 22 of 22 |
| CSV | 658 / 40; 52 of 52 | 545 / 39; 52 of 52 |
| 12 outer functions, each a nested `emitter` and `helper` (every name shared) | 10 / 2; 12 of 12 | 27 / 18; 0 of 12 |
| the same, names of their own | 14 / 3; 12 of 12 | 27 / 5; 12 of 12 |

The generated programs' emitters begin with `if true:` and take no
parameters, so on the parent their walks stopped at the `if` (vacuous
proofs, cheaper), and the shared-name program's reuse there is the
identity defect itself.

* The JSON and CSV costs are within the measurement's spread; their
  summary counts are identical (section 15).
* Programs without claims run nothing of the checker (`verify` returns at
  once; unchanged).
* The ambiguous-name fallback costs the reuse: a second compilation of a
  program whose claims all share names proves them again (0 of 12 reused),
  where the same program with names of their own reuses all 12. That is
  the whole price, and it is paid only by programs with duplicate names.
* Tagged feasibility adds one integer per `Facts` call; no new abstract
  state or summary.

## 18. Production files changed

One: `hir/emission.tcl`, 45 changed lines that are neither comments nor
blank (39 added, 6 removed; the census estimated 33 for its two
corrections, without the read-set rule): one variable (`ambiguous`), two
procedures (`Identified`, `ReadsIdentified`), the identity checks in
`Reset`, `UsableCertificates`, `Valid` and `CheckClaim`, and the
feasibility flag in `Facts` and `EvalIf`. No new abstract state, HIR form,
diagnostic, certificate field or language construct.

Beside it: the tests (13 in tests/emission-claims.test), the mutants (15),
the census record (`audit/emission-dependencies/census/cases.txt`: the
corrected observations, N6a, N6b, the `identity-read` sequence), the new
audit (`audit/emission-identity/`), and AGENTS.md's emission rules.

## 19. Remaining limitations and the shortcut audit

### 19.1 The shortcut audit (the brief's section 17)

Every decision of the checker that drops a path, ends a walk or
substitutes a stored result for an analysis (inspection):

| shortcut | what justifies it | can its representation also mean a feasible execution or another function? | trusted, inferred or recovery-derived? | recorded in the certificate? | regression |
|---|---|---|---|---|---|
| a call that never returns (`TypeOf $e eq never`) | the call's static type; for a block target the callee's code (`Read`) | an unresolved name's `never` (recovery): tainted (the previous milestone); a structural `Fn`'s joined `never` (V2): rejected programs only, deferred | inferred, or recovery-derived (rejected programs) | the callee's fingerprint (`reads`) for a block target; nothing for a value target (V1/V2) | `ec-callee-*`; `ec-identity-composition`'s `e`/`d` |
| an infeasible branch | `KnownOutcome`, the walk's narrowing over its own facts | was: an empty environment (corrected) | inferred | through the code's fingerprints (type facts, reachability) | `ec-feasibility-*` |
| a counted loop's zero-iteration exit | `hir::range::DomainEntered` on the bounds' facts | no: `*` and `{}` prove nothing (`Entered`) | inferred | the code's fingerprints | `ec-loop-entered-*` |
| a summary reused | its key `{BLOCK STATE ARGS}`, final after a converged solve | no: keyed by block | derived in this compilation | its code's fingerprint | `ec-callee-independent`, `reuse-drops-taint` |
| a certificate reused (memo) | `Valid`: every dependency unchanged | was: a name of two blocks (corrected) | derived in this process | its own `depends` | `ec-memo-*`, `ec-identity-*` |
| composition with a helper's certificate | its statement | was: a name of two blocks (corrected) | derived in this compilation | the statement digest | `ec-identity-composition`, `ec-compose-*` |
| a dependency validated by name | the name identifies one block in both compilations | was: no check (corrected) | -- | -- | `ec-identity-memo-*`, `-read-set`, `-certificate-dependency` |
| an empty state set | no execution reaches the point | no: states are recognizer states, never "" | inferred | -- | the existing suite |
| a walk ending without completion (`return`, `fail`, `break`, `continue`, a budget) | the construct; a budget is EMIT-BUDGET, never a proof | no | -- | -- | `ec-budget`, `ec-early-return` |

Three more places read an empty value as an absence. None decides
feasibility, and none is a false certificate:

* **`Apply`, certificate composition** -- `if {$exits eq ""}` tells "no
  certificate read yet" from "the first certificate's exits are none" by
  the value. When a helper claims two recognizers and the first
  certificate says it never completes, the second's exits, visits and
  failure states are taken instead of the intersection: a superset, so
  more states are checked (precision only; inspection, not tested -- no
  program in the suite has a two-claim helper that never completes). Not
  corrected here: no false certificate can come of it, and the brief keeps
  this milestone to the two defect families.
* **`Peel`, counted loops** -- `$first eq ""` tells an inexact start from
  an exact start outside the induction set. The second happens only when
  the induction set is empty, where the body never runs; the loop is then
  walked with every value of an empty set, which yields nothing
  (inspection).
* **`Summary`'s first round** -- `result eq {} && exits eq {}` detects a
  record not yet computed; a genuine empty result joins to the same value
  (inspection).

### 19.2 Deferred and found

* **Binding and signature provenance** (the census's section 21.3, class A
  and undecided, rejected programs only): R1, B3, B3c, B6, D1, D2, G1, B8,
  B8b, B8f, X2, SC1, B2b, V2, S1, S4b, S5b, S5d, S6b, K1 -- the census's 20
  open cases, unchanged. V2's certificate in a rejected program (the
  structural `Fn` whose `never` is a placeholder's) and its memo
  transition (`callable` sequence) remain.
* **Declined reuse.** A claim or proof that touches a name of two functions
  is proved again in every compilation. A lexical identity that survives
  edits would keep the reuse; none exists in the HIR, and none is added.
* **The memo is never pruned.** An entry whose function is gone or changed
  stays until a proof of the same key replaces it (as before); `Valid`
  refuses it, so this costs memory, not soundness (inspection).
* **Found on the way, outside the checker**: a call that passes a constant
  to a domain-typed parameter inside an `if false:` branch is rejected
  (TYPE: "cannot be proven to satisfy int[Bit] (argument type: int, facts:
  [-∞, +∞])"), because unreachable code has no range facts. A wrong
  rejection by the range analysis, not an emission matter and no false
  acceptance (observed with `main.tcl`; not corrected; the structural audit
  avoids it by giving helpers Int parameters).
* **Not tested**: a Neovim or VS Code session over the language server (the
  compiler service's revision loop is, section 11); macOS and Windows
  hosts beyond CI (section 20).

## 20. Recommendation

Merge. The two class C defects and the read-set gap are closed by
conservative rules that decline reuse and composition, never prove anything
new, and cost nothing on the workloads; every claim of the suites, the
workloads and the census whose certificate was true keeps its verdict and
its certificate, and only the false and the vacuous ones change.
The next emission milestone should be the census's binding provenance
(21.3), with the V2 structural-`never` case first: it is the only one in
which a certificate (in a rejected program) still rests on a placeholder.

**What was run, locally** (a 4-core container, the native backend built):

* `tests/local.tcl -jobs 3`, the whole local suite: every Tcl test file on
  interp (8,962 passed, 0 failed, 214 skipped) and compile (8,957 passed,
  0 failed, 219 skipped), 2,493 golden duplicates skipped on each; all 118
  golden suites on interp, compile, cranelift-generic and cranelift, 0
  failed;
* each file the brief names, run on its own: tests/emission-claims.test
  (123 of 123), csv-emission (36), dfa (85), dfa-workloads (21),
  interval-sets (37), hir-range (74), diagnostic-recovery (57),
  syntax-recovery (33), static-compile (83),
  static-compile-expected-diagnostics (21), compiler-service (56),
  hir-interchange (11), hir-cache (19), coroutine-fusion (17), lsp (77),
  main-cli (72): every test passed;
* the audits of section 13, the mutation catalog of section 14,
  `tools/mutant-catalogs.tcl` (90 catalogs, 3,192 mutants, 0 problems) and
  `tools/compilerpedia.tcl check` (1,290 topics, 758 examples, 0 problems).

**Not run**: `tests/lsp-neovim.test` with a real Neovim (it is skipped
without one; CI's tests.yml installs one); the GC-stress runs (CI's); the
static-decisions comparison (it runs on main for a front-end change; this
change moves no static decision of the golden suites -- the one suite with
a claim, static-compile-expected-diagnostics.bot, passes on all four
backends -- and was not dispatched on the branch).

**CI on the branch** (64611f8): the canaries of tests.yml (dispatched),
tests-arm64.yml (dispatched) and windows-x86_64.yml, and macos-arm64.yml's
smoke job (Tier A, with its canary) and Linux control, passed. Every other
job of the four workflows, and both Icy Tower workflows, was still queued
behind the shared runner pool when this report was written: pending, not
passed. `main` moved on from the branch's base while it ran (53a0d1b to
d74d5ef); its latest tests run (d2421af) is queued, the earlier ones
superseded, none failed.

## 21. Final evaluation questions

**1. Are both demonstrated soundness failures eliminated?** Yes. N1, N2,
N3, N4b, F1, F2 and F3 compile to rejections (EMIT-REJECTED, F2
EMIT-AFTER-TOKEN) under every history `ec-identity-memo-history` and the
census tool exercise -- a fresh process, an empty memo, a populated one,
the memo off, interchange with the memo on and off -- and the runs of N2,
N4b, F1 and F3 still yield the same invalid traces (observed, tested).

**2. Is function identity sound?** No certificate or dependency can now be
selected by a name two function blocks share: every name-keyed lookup of
section 4 asks `Identified` first, and a proof that read such a name is
not memoized, so its one-fingerprint-per-name record is never validated
(inspection; tested by seven `ec-identity-*` tests and seven mutants).

**3. Is branch feasibility sound?** An empty but feasible environment
cannot discard a path: feasibility is `Facts`'s flag, and nothing else
reads it from a value (inspection, section 19.1; tested by three
`ec-feasibility-*` tests and eight mutants).

**4. Is proof correctness independent of process history?** Yes, in every
history tested: fresh compilation, memo reuse after six kinds of earlier
compilation, seven compiler-service revisions and interchange read with
the memo on, off and in another process derive the same verdicts,
certificates and diagnostics (tested; the structural audit's history
checks: 0 differences in 39 programs, where the parent had 10).

**5. Were accepted programs preserved?** Every valid claim of the JSON (22)
and CSV (52) workloads, the emission and CSV test files, the census's
accepted cases and the existing differentials keeps its verdict and its
certificate. The precision lost is only what was never proved: claims
the parent certified vacuously, because the walk stopped at an `if` (P3),
or through another function's certificate (the structural audit's one
claim, whose rejection is a correlation of two calls the abstraction does
not see), now rejected for paths the abstraction cannot exclude; and reuse
declined for names of several functions.

**6. What did structural fuzzing reveal?** Only the two defect families:
43 false certificates and 10 history-dependent programs on the parent, 0
and 0 with the correction, over 330 claims and 2,604 runs. It did not
reproduce the prototype's read-set gap, which the targeted test does.

**7. What remains to be done?** The census's binding and signature
provenance (section 19.2: 20 open rejected-program cases, V2's certificate
first); the composition precision issue of section 19.1, if a two-claim
never-completing helper ever matters; and, outside the checker, the range
analysis's rejection of domain admissions in code an `if false:` makes
unreachable.
