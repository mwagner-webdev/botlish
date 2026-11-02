# EMISSION-CLAIMS-MILESTONE-1.md

Trusted analysis and production integration of emission claims: a function
declaration may state that its outward yield trace is one token of a
declared recognizer, and the compiler certifies the statement from the
declaration and the code alone -- or rejects the program.

> The compiler may certify what a function emits only from guarantees it
> can trust. Every reusable certificate must hold for all permitted callers,
> through all normal and failing control-flow paths, without introducing
> hidden runtime work.

This milestone follows DFA-COROUTINE-MILESTONE-2.md (declared recognizers),
EMITTER-COROUTINE-EXPLORATION.md (the exploratory checker, `audit/emitter/`)
and MODULAR-EMISSION-PROOFS-MILESTONE-1.md (the modular prototype,
`audit/emission-proofs/`), whose semantics and evidence it takes as the
baseline. Both prototypes are kept unchanged, as history.

## Contents

1. [Result and production status](#1-result-and-production-status)
2. [Final syntax](#2-final-syntax)
3. [The guarantee](#3-the-guarantee)
4. [Value facts and their soundness audit](#4-value-facts-and-their-soundness-audit)
5. [Native result sets](#5-native-result-sets)
6. [One DFA outcome model](#6-one-dfa-outcome-model)
7. [HIR representation and analysis placement](#7-hir-representation-and-analysis-placement)
8. [Summaries and recursion](#8-summaries-and-recursion)
9. [Failure paths and coroutine boundaries](#9-failure-paths-and-coroutine-boundaries)
10. [Guards and domains](#10-guards-and-domains)
11. [Certificates, trust and invalidation](#11-certificates-trust-and-invalidation)
12. [Diagnostics and Compilerpedia](#12-diagnostics-and-compilerpedia)
13. [The compiler service and the language server](#13-the-compiler-service-and-the-language-server)
14. [The independent library](#14-the-independent-library)
15. [Differential and generated-program evidence](#15-differential-and-generated-program-evidence)
16. [Mutation results](#16-mutation-results)
17. [Compilation and native performance](#17-compilation-and-native-performance)
18. [Compatibility and regression results](#18-compatibility-and-regression-results)
19. [Remaining precision limits](#19-remaining-precision-limits)
20. [Architectural implications and next steps](#20-architectural-implications-and-next-steps)

Appendix: [A. Changes from the modular prototype](#a-changes-from-the-modular-prototype),
[B. Files](#b-files).

## 1. Result and production status

**`emits R` is a supported clause of Botlish function declarations.** The
compiler certifies every claim of a program it compiles -- from the claimed
function's declared parameter types and the code every backend compiles,
never from its callers -- or reports why it cannot, and a program with a
claim it does not certify does not compile. Both prerequisites the modular
milestone set are done and separately evidenced:

* **Stage A -- trusted value facts.** The interval-set domain the prototype
  kept beside its checker is now `hir/intset.tcl`, the disjunctive
  completion of `hir::range`'s lattice, every transfer hir::range's own.
  hir::range gained the `mod` precision the prototype lacked
  (`hir::range::ModParts`: exact residues of exact or non-wrapping
  operands, and the two parts of a wrapping range) and native result *sets*
  (`-result-range {intervals ...}`, std::char::scalar_value's surrogate
  gap, `hir::range::RegisteredSet`). Each transfer the checker reads is held
  to concrete arbitrary-precision evaluation by `tests/interval-sets.test`
  and mutated as a soundness rule (section 4).
* **Stage B -- one outcome model.** What a recognizer's table code means is
  stated once, in `core/dfa.tcl` (`Outcome`, `RunResult`, `Resume`,
  `Unread`). surface/dfa.tcl's `Lower` generates each recognizer's code
  from it -- byte for byte the HIR it generated before (section 6) -- and
  the checker's step (`hir/emitdfa.tcl`) applies it to sets of symbols,
  both from the table the lowering attaches to the recognizer's function.
  Against the reference interpreter: 7,330 cases, 0 mismatches.
* **Stage C -- production claims.** The clause through the parser, the
  loader's qualified-reference walk, lowering, resolution, HIR text and
  interchange; `hir/emission.tcl` at the end of `hir::BuildFull`; 13
  diagnostic kinds with `std::compiler::DiagnosticCode` cases and
  Compilerpedia topics; certificates in the HIR, verified again whenever
  a HIR is read from text, reused within a process only after validation;
  hover, definition and references in the compiler service (and so the
  language server); the JSON emitters as examples (`examples/dfa/json`).

**Evidence** (sections 14-16): the prototype's 55 tests ported (with 28
integration tests: 83 in `tests/emission-claims.test`, 35 in
`tests/interval-sets.test`); the modular census -- every claim decided as
the prototype decided, no certified claim with a counterexample; the
exploratory census's 31 mistakes -- 31 of 31 decided as the exploratory
checker decided; 320 generated claims against 41,600 runs -- **0 false
proofs**, 224 certified, 3 precision losses (the prototype: 6); the five
callers of the independent library -- identical verdicts; 57 mutants of the
checker's rules, the outcome model, the value transfers and the trust
boundary -- all killed (the first run left 5 alive; each was a missing
test, now written, section 16).

**Cost** (section 17): 0.30 s for the 22 claims the prototype measured at
0.37 s (140 summaries computed, 60 reused, 44 rounds -- the prototype's
exact counts); 0.13 s for an imported library of 10 uncalled claims, 0.016 s
when a later compilation in the same process reuses their certificates.
**A certified emitter's native code is the code without its claim**: the
fused NIR is identical, no table, switch or `dfa#transition` remains, no
coroutine object is allocated.

**Production status: supported.** What remains experimental is named in
section 20 (separately compiled interface artifacts; an in-process memo
only).

## 2. Final syntax

```
fn json_string(text: str) -> unit errors IndexNotFound emits json_lex::json_string_strict:
    ...
fn string(text: str) -> unit errors IndexNotFound emits json_lex::json_string, json_lex::json_string_strict:
    ...
fn digit(d: DigitValue) -> unit emits digit_token:
    ...
```

```
function = { functionModifier } "fn" IDENT "(" [ paramList ] ")"
           [ "->" typeExpr ] [ proofClause ]
           [ "errors" errorName { "," errorName } ]
           [ "emits" recognizerName { "," recognizerName } ] ":" suite
recognizerName = [ "::" ] IDENT { "::" IDENT }
```

* `emits` is contextual -- recognized only in this one position, after
  `errors` and before the final `:` -- so it stays an ordinary name
  everywhere else (`emits = 2`, a parameter named `emits`). One clause per
  function, several recognizers in it; `errors` comes first (a misplaced or
  repeated clause is a syntax error that says so).
* A recognizer is named as any declaration: unqualified for one declared
  earlier in the same file (no forward reference), `ns::NAME` for an
  imported module's (the loader's ordinary rules: MISSING-IMPORT,
  UNKNOWN-NAMESPACE, privacy), rooted `::ns::NAME`. The loader's one
  qualified-reference walk records and rewrites the claim's namespace like
  every other qualified name (package instances included).
* It coexists with `private`, `nomethod`, `exported c`, a proof clause and
  `errors`; it changes none of them, nor the function's type, calls,
  result, errors or yields. There is no invocation-level form.

## 3. The guarantee

For every argument tuple F's declared parameter types permit:

1. every invocation of F that completes normally has an outward yield trace
   that is exactly one token of R, with nothing unread; and
2. every finite outward yield trace of an invocation -- before completion,
   at a failure, or when its consumer stops resuming it -- is a viable
   prefix of R's language.

The trace is F's own yields and those of the functions it calls by an
ordinary call (deep yields). A coroutine F constructs is another execution:
its yields are its own, and what F resumes from it is an ordinary value.
F's result is no symbol; a claimed function whose declared result is an Int
is a symbol source and must complete with -1 (EMIT-TERMINAL-VALUE). The
claim says nothing of termination, of the token's value (a valid number of
the wrong value is valid), of rollback after a failure, or of a document's
structure: `emits json_text` is the lexical stream -- valid tokens with valid
boundaries -- never matching brackets.

Several claims on one function each hold; the function's trace is in the
intersection of their languages, which a caller composing with it uses.

## 4. Value facts and their soundness audit

### What changed

| change | where | why |
|---|---|---|
| interval sets: finite unions of closed intervals, true infinities, arbitrary-precision bounds, empty set, normalization, hull past 48 components | `hir/intset.tcl` (moved from the prototype's `intset.tcl`) | the hole `x != K` and a scalar value's surrogate gap are sets no Range holds |
| every transfer lifted per component from hir::range's own: add, sub, mul, ModParts, BitOp, Narrowed, TypeFact, InductionBinding, RegisteredSet | `hir::intset::Lift1`, `Lift2`, `LiftMod`, `Narrow` | one statement of each operation's meaning, audited where it lives |
| the one rule only a set can state: `!=` (an `==` false) against a point removes it | `hir::intset::Narrow` | JSON escaping: `c == 34 or c == 92` false |
| exact `mod`: pairwise residues of exact operand and divisor sets; the residues of a finite range narrower than an exact divisor (one part, or two when it wraps past a multiple); a nonnegative range below every positive divisor is itself | `hir::range::ModParts` (`Mod` is its hull) | the prototype's six fuzzer precision losses were all `mod` |
| registered result sets | `-result-range {intervals ...}`, `hir::range::RegisteredSet` (`RegisteredRange` its hull) | section 5 |
| an order comparison's operands are Ints wherever it completes | the checker's `Facts` | an untyped value compared by `<` is narrowed on both paths (the native admits only Ints) |

Precision only grows: every existing consumer of `hir::range::Mod` gets the
tighter Range (two tests that pinned the looser one changed: `range-
lattice-8`'s operand below an exact divisor's magnitude is now itself, and
`nrb-mod-in-range-analysis`'s exact operands give exact residues). A zero
divisor still decides nothing: the call's ARITHMETIC failure stays a run's,
never a `never` that would make it a compile-time KNOWN-ERROR
(`mod-lowering-zero-divisor` caught the first draft).

A precision gain is not free of consequences, though: a fact the analysis
now proves can make a handled call a statically known failure (KNOWN-ERROR:
a handler does not make one legal). Tests that used `mod(500, 11)` to hand
a recursion an input known only as a range found it exact (5), and
`g(mod(500, 11) - 5)` became a KNOWN-ERROR. They hide the input with
`std::int::from_string` now, which is never folded
(`rec-error-path-value`, `rec-executable-error-path` and their golden
ports). A program in the wild that relied on `mod` of constants being
opaque would see the same rejection; it is the rule's ordinary behavior
for any proof the compiler learns, but it is a source-compatibility change
and is recorded as one (section 18).

### The soundness audit

A false narrowing -- excluding a value execution can produce -- is a false
certificate. `tests/interval-sets.test` holds every rule to concrete
evaluation (Tcl's bignums, the runtimes' Euclidean `mod` and shift bounds):

* for random sets (1-3 components, bounds from a palette of small values,
  edges of the recognizers' ranges, 2^62, 2^63, 10^21, 10^25 and both
  infinities) and every operator (`+ - * mod bit_and bit_or bit_xor
  shift_left shift_right`), every concrete result of every pair of members
  lies in the transfer's set; `mod` additionally by exact divisors of every
  magnitude over ranges narrower than them (the wrap rule);
* for every comparison (`< <= > >= == !=`), every member for which the
  comparison holds against some member of the other side survives the
  narrowing;
* every counted loop's counter lies in `InductionBinding`'s interval (up and
  down, `to` and `through`, starts and ends anywhere);
* exact expectations at every edge: holes at a component's edge and in a
  point component, empty sets through every transfer (no value, never the
  universe), huge values never dropped, negation, wrapping and negative
  `mod`, shifts of possibly negative values or amounts, the component
  budget (a hull, a superset), the registration's validation.

The mutation audit (section 16) mutates the hir::range transfers themselves
(`range-*`, `intset-*`): every one is killed by this file, the emission
tests, or both. hir::range's own test file passes unchanged but for the two
precision expectations above.

## 5. Native result sets

`std::char::scalar_value` is registered with
`-result-range {intervals {0 0xD7FF} {0xE000 0x10FFFF}}`: a Unicode scalar
value, never a surrogate. It replaces the prototype's trusted table beside
the checker.

* **One reading.** `core::native::ValidResultRange` accepts the canonical
  form only (at least two components, sorted, disjoint, not adjacent);
  `hir::range::RegisteredSet` reads its components, `RegisteredRange` (the
  range and completion analyses) their hull -- one fact at two precisions.
  Every other registration is one Range at both.
* **The contract behind it.** core/value.tcl's `isValidScalar` is the only
  constructor of a UnicodeChar in the Tcl runtimes; natively a UnicodeChar is
  a Rust `char` or a literal validated by `is_valid_scalar`. Neither admits
  a surrogate; `iset-scalar-value-contract` and `-native` hold both to it.
* **Unknown is unknown.** A native without a result range is every Int
  (`iset-registered-forms`); nothing is inferred from runs.
* **Invalidation.** A certificate records every registration its proof read;
  a different registration invalidates it (`ec-memo-registered`). No user
  mechanism asserts a native fact.

## 6. One DFA outcome model

core/dfa.tcl, beside `dfa#transition` (the runtime lookup), now states what
every code of a recognizer's table means:

| function | meaning |
|---|---|
| `Outcome LEAF` | `{consume N}`, `{complete CLASS}` (taken, current, `{more K}`), `{call KEY THEN}`, `{reject R S}` |
| `RunResult CLASS` | the run function's result: -2, the current symbol `c`, -2 - K |
| `ClassOf R` | its inverse |
| `Resume THEN CLASS` | what a caller does with a callee's completion: `propagate` (then accept), `{wait THEN}` (taken), `{reconsider THEN}` (current symbol or end), `reject` ({more K}: no row holds it; DFA-CALL-LOOKAHEAD forbids it) |
| `Unread CLASS AT-END` | the outermost recognizer's unread count |

`surface::dfa::Lower` builds every arm from these -- the return value of a
completion, the call's wait and reconsider branches, the recognizer
function's unread decoding -- and attaches the table it compiled to the
recognizer's function (`hir::syntax::withRecognizer`: key, qualified name,
alphabet, state numbers, leaves, rows, whether any transition suspends, the
states' origins). The checker steps the same table with the same functions
over sets (`hir::emission::StepBase`, `Complete`). The two
*representations* stay two -- code for one symbol, abstract steps over sets
-- but no transition rule is stated twice.

**The generated code is unchanged.** Every program of the DFA workloads and
the emitter workspace (11 programs: json, conformance, composition, yaml,
the JSON emitters' modules) compiled before and after the change gives the
same HIR text and the same expression nodes but for the new table field
(95,632 lines compared). tests/dfa.test (85 tests) and
tests/dfa-workloads.test (21) pass unchanged; the native table and switch
lowering is untouched.

**Conformance.** `audit/emission-claims/tools/conformance.tcl` reruns the
prototype's comparison through the production path -- every case
`dfatest::cases` makes for json_lex's eleven recognizers, json_grammar's
four and three written for what JSON lacks (`accept before 2`, a call `then
accept` passing two unread symbols on, a call `then STATE` whose callee
leaves its symbol to be reconsidered): **7,330 cases** (the prototype's
7,201 plus those of the workspace's extra cases), **0 mismatches**
(`results/conformance.md`; `ec-conformance` runs 12 walks of every
recognizer in the test suite). The mutants of `Resume`, `Unread` and
`Outcome` are killed by it.

## 7. HIR representation and analysis placement

| field | on | content |
|---|---|---|
| `emits` | a function's block | `{name origin binding}` per claim: the recognizer as written, where, and the function binding it resolved to |
| `recognizer` | a recognizer function's block | its table (section 6) |
| `emissions` | the HIR | one record per claim: block, function, recognizer, origin, verdict (`proven`, `rejected`, `not-proved`, `dependent`), and a proven claim's certificate |

**Resolution** (`hir::resolve::ResolveEmits`) resolves each name in the
scope the function is declared in; a name that denotes nothing is
EMIT-RECOGNIZER at the claim (with "declared later" for a forward
reference). Whether the binding is a recognizer -- its declaring block
carries a table -- is the checker's question; a rejected recognizer's stub
makes the claim dependent (its own diagnostics are the report).

**Placement.** `hir::emission::verify` runs at the end of `hir::BuildFull`,
after method-call decisions, the trait monomorphization and the
elaborations: on exactly the program every backend compiles. It reads the
HIR alone -- types, `MayYield`, the tables, registered metadata -- and no
whole-program range or specialization instance. A program without a claim
costs nothing (one scan for `emits`). HIR text (`hir::read::Program`) runs
it too: text carries no tables, so a claim read from text is EMIT-
UNSUPPORTED, never certified.

**Diagnostics' anchor.** Each claim's diagnostics anchor at the claimed
function (`expr`: its unit, for recovery and for static sites) and are
located at the yield or call (`origin`), possibly in a helper. A static
compile block holding a claimed function is decided by them like any
diagnostic (`ec-static-compile`).

**Traits.** A trait-polymorphic or context-trait function is compiled as
clones whose operations call the implementations *this program* selects;
the checker never follows a clone, a trait operation or a context-trait
implementation (EMIT-UNSUPPORTED): a certificate is a property of the
declaration, never of one program's selection.

## 8. Summaries and recursion

Ported unchanged in semantics from the prototype: a summary of `{function,
entry state, argument facts}` records exits, visits, failure states, the
result, the violations of its own yields, its children and the certificates
it composed with -- and, new, whether its code touched what another
diagnostic is about (`tainted`: section 12). Rounds to a checked fixpoint;
every value only grows; results widen to the declared type after 4
changes; 12 argument contexts per function, then its declared facts;
budgets of 60 rounds and 40,000 summaries (and 20,000 states of a
certificate's product with a caller), past which the claim is EMIT-BUDGET
and nothing it touched is final. A new rule: an analysis that hit its
budget reports only the budget -- what a non-converged round found is no
finding (`budget-certifies` mutant).

Summaries are shared by every claim of a compilation: the 22 JSON claims
compute 140 and reuse 60, the prototype's counts exactly; checked one claim
at a time from fresh state, 448 (section 17). Partial-token helpers need no
claim. Loops peel a counted domain's first iteration, unroll exactly
counted ones of at most 8, and otherwise iterate to a fixpoint;
recursion's second round is checked (`ec-recursion-same-context`).

## 9. Failure paths and coroutine boundaries

Failure points are exactly the prototype's: a `fail`, a native call whose
registration declares errors (or raises a callable's, or runs a coroutine),
a call of a function that declares errors or no signature, a call through a
value, a guard; each records the states at that moment, after every yield
before it. A `handle` starts its handlers from exactly the protected call's
failure states, with the environment from before the call, and passes them
on to enclosing failure points. The exploratory checker's two unsound rules
(a sentinel bound; handlers entered from before the last yield) stay
impossible: `ec-exploratory-false-proofs` and the census reproduce both
programs, and the compiler rejects them (with a concrete witness each).

A coroutine construction's thunk is not walked: its yields are its own; the
values F resumes from it are Ints of its type. A claim never passes through
a function value (a yielding function never becomes one). Coroutine fusion
and its fallback are untouched: claims change no code (section 17).

## 10. Guards and domains

**Guards.** A call of a recognizer none of whose transitions suspends,
whose argument is a binding, narrows that binding, on the call's normal
path only, to the symbols the recognizer's first step completes on (read
from its table). Not another binding, not a derived value, not in a handler
(`ec-guard-facts`; `handler-keeps-guard`, `guard-any-binding`).

**Domains.** A parameter of a declared integer domain enters with its
interval or values (`hir::range::TypeFact`). The certificate trusts that
every call's argument is in the domain, which the caller's own check
enforces: a call of `digit_of(12)` is the caller's TYPE error, certified
callee or not (`ec-domain-admission`); no certificate ever admits an
argument. Today that admission is checked over the whole program (hir::range's
VerifyCall may discharge it from caller-propagated facts); every program
that compiles satisfies it at every call. **What separate compilation will
need:** each call's domain obligation proved from its caller's declaration
and code alone, or a run-time check at the boundary of a separately
compiled library -- the one place a certificate trusts its callers. The
examples discharge every obligation locally (`emitlib::body_char` narrows
before calling `unicode_escape(c: CodeUnit)`).

**Undeclared parameters** enter with no fact: never the inferred contract
derived from the body (a weaker statement than a declaration). A yield of
one is EMIT-UNKNOWN-VALUE, or EMIT-REJECTED when its type is Int; an order
comparison narrows it (section 4), so `if c >= 48 and c <= 57: yield c` is
certified (`ec-undeclared-parameter`).

## 11. Certificates, trust and invalidation

A certificate records what a caller composes with -- function, recognizer
(and its alphabet), declared domain, exit states with their open boundary
obligations, visits, failure states, result, boundary summary -- and
everything its proof read: the front end's fingerprint (the checker is part
of it), every function whose body the proof analyzed by canonical
fingerprint, every certificate it composed with by statement digest, every
recognizer (and those it calls) by table fingerprint, every registered
result set. Its statement digest leaves out what it read, so a helper whose
code changes but whose statement does not leaves its callers' proofs valid.

**Fingerprints** are digests of a canonical text of a function's HIR: node
kinds, constants, natives, declared types -- and, new, each expression's
*type fact* (never, an integer type's facts, or unknown) and reachability,
and each outside binding's name, exact value and type fact. The prototype's
canonical text omitted types: a struct field's declared domain changed
from 0..9 to every Int left the function's fingerprint unchanged, so a
stored certificate would have been reused for a now-false claim
(`ec-memo-types`; the mutation audit found the missing test). Comments,
unrelated code and callers change nothing (`ec-fingerprint`).

**Trust.** A certificate is a proof only when this process derived it:

1. *The in-process memo* (`hir::emission::memo`): a certificate proved in
   an earlier compilation is reused only after `Valid` recomputes every
   dependency in the new HIR; reuse is process history and never enters the
   HIR (`stats reusedClaims` reports it). This is the compiler-controlled
   cache: the language server, the compiler service and static-compile
   rounds benefit from it.
2. *Text is never a proof.* `hir::interchange::decode` -- and so the
   front-end cache -- re-verifies the claims of every HIR it reads
   (`hir::emission::reverify`) and refuses text whose records or claim
   diagnostics differ from what this process derives (HIR INTERCHANGE
   EMISSION; a cache entry that differs is a miss, rebuilt). A forged
   verdict, an edited statement, removed diagnostics: each refused
   (`ec-interchange-forged`, `ec-cache`). A genuine HIR round-trips equal.
3. *HIR text* carries no recognizer table: its claims are not proved.

No signing, no package-level trust, no proof-carrying artifact: a separately
compiled library would need its certificates in an interface artifact the
compiler can authenticate or re-check (section 20).

**Invalidation, measured** (`ec-memo-invalidate`): a comment and a new
caller invalidate nothing; a helper's code (hex_digit's letters) re-proves
the one claim whose proof analyzed it -- not `member`, which composed with
that claim's unchanged statement; a recognizer's table (json_lex loses `\/`)
re-proves every claim reading it.

## 12. Diagnostics and Compilerpedia

| kind | outcome | meaning |
|---|---|---|
| EMIT-REJECTED | rejected | a yield may send a symbol the state does not take |
| EMIT-BEYOND-TOKEN | rejected | a symbol the token ends before (`accept before N`) |
| EMIT-AFTER-TOKEN | rejected | a symbol after the token is complete |
| EMIT-INCOMPLETE | rejected | a normal completion where the end is rejected |
| EMIT-END-SYMBOL | rejected | a yield that may send -1 |
| EMIT-BOUNDARY | rejected | a symbol that continues a helper's claimed token |
| EMIT-BYTE-CHARACTER | rejected | a character's scalar value sent to a bytes recognizer |
| EMIT-TERMINAL-VALUE | rejected | a symbol source completing with another value than -1 |
| EMIT-NOT-SYMBOL | not proved | a yield of a value that is no Int |
| EMIT-UNKNOWN-VALUE | not proved | a yield of a value of no known Int set |
| EMIT-UNSUPPORTED | not proved | code the checker does not follow |
| EMIT-BUDGET | not proved | the analysis' budget exhausted |
| EMIT-RECOGNIZER | -- | a claim naming no recognizer, or one twice |

**Three outcomes, kept apart.** *Proven*: a certificate. *Rejected*: the
analysis derived a trace the recognizer rejects from facts that may
over-approximate -- so the message says "may", names the claim, the yield,
the recognizer state (a note locates its declaration) and the symbols, and
never calls a precision limit a demonstrated bug. *Not proved*: the facts
are missing. A **disproof** needs a run: `audit/emission-claims/tools/
witness.tcl` runs the function (in a copy of its program with every claim
removed) on candidate arguments and reports the first invalid trace; it is
never part of compilation, and finding none proves nothing. The census
reports which rejections a run confirms (section 15).

**Recovery.** A claim whose analyzed code holds an expression another
diagnostic is about, poison or a syntax hole is `dependent`: no diagnostic,
no certificate (`ec-recovery-dependent`, `ec-syntax-recovery`); independent
claims are reported as before. A strict compilation raises the first
diagnostic with its location, its related location (the claim) and its
notes (`ec-strict-raises`).

**Static intrinsics.** Every kind has its `std::compiler::DiagnosticCode`
case (EmitRejected, ...; tests/static-compile.test's census and its
one-to-one check: 133 cases). Messages name functions by source name
(`hir::semantic::CallableName`), never an internal id.

**Compilerpedia** (`compilerpedia/topics/emission.topic`): the concept page
`concept.emission-claims` (the guarantee, deep yields, coroutine boundaries,
failures, boundaries, caller independence, guards and domains, lexical
versus structural validity, not proved versus disproven, runtime cost, an
accepted example) and one topic per kind, each with a rejected example
checked at its exact location; `error.hir-interchange-emission` for the
refusal of text. `tools/compilerpedia.tcl check`: 0 problems.

## 13. The compiler service and the language server

* **Hover** on a claimed function: its signature with the clause (`fn
  digit(d: DigitValue) -> unit emits digit_token`), then one line per
  claim -- the guarantee its certificate states ("certified to emit
  digit_token: every normal completion has yielded exactly one token,
  every prefix it yields is viable; its token completes on its own last
  symbol"), or why it has none.
* **Definition and references** on a claim's recognizer name: the construct
  `emits-claim`, the recognizer's binding, its declaration, and its
  references -- the claims among them, by resolved identity.
* The facts come from the HIR the revision built (`emissions`, the claims'
  `emits` sites), so a claim is shown whether or not anything calls its
  function, and a partial revision (syntax recovery) shows what is known.
  The language server consumes `service::at` and adds nothing
  (`ec-service`; tests/compiler-service.test and tests/lsp.test pass
  unchanged). Revisions re-analyze after edits; the memo validates.

## 14. The independent library

`examples/dfa/json/emitlib.bot` (from the prototype's library) claims a
strict JSON string for every `str` (with partial-token helpers that claim
nothing), a guarded digit, a domain-typed digit, an object member composed
from certified helpers, and coroutine roots. Its unguarded digit and glued
pair carry no claim in the shipped example (the compiler would reject them);
`ec-callers-stable` checks the library with all eight of the prototype's
claims from its five unrelated callers (`audit/emission-claims/callers/`:
safe values only, the whole domain, invalid values, compositions, no call):

| claim | every caller |
|---|---|
| `json_string` json_string_strict | proven |
| `json_string_source` json_string_strict | proven |
| `digit_checked` digit_symbol | proven |
| `digit_checked_source` digit_symbol | proven |
| `digit_of` digit_symbol | proven |
| `member` json_text | proven |
| `digit_unchecked` digit_symbol | rejected (witness d = -1) |
| `pair_glued` json_text | rejected (witness (0, 0)) |

and compose.bot's own two claims are certified through the library's
certificates. The strict string emitter's output for the milestone's texts
(empty, quotation marks, reverse solidi, every control, supplementary
characters, U+2028, 2,000 characters) is one strict token for the reference
interpreter and decodes in CPython to its text (`ec-library-json-string-
runs`).

## 15. Differential and generated-program evidence

* **The modular census** (`audit/emission-claims/census/cases.txt`, the
  prototype's 21 programs; `results/census.md`): 25 claims (the
  prototype's 23 and two helpers' own), each decided by the compiler and
  run for its concrete truth. Every claim decided as the prototype decided
  (its "disproven" and "not proved" are the compiler's "rejected"): 10
  certified, no counterexample; 14 rejected, each disproven by a run; 1
  rejected without a counterexample (`forward`, which forwards a value
  resumed from another coroutine). **No certified claim has a
  counterexample.**
* **The exploratory census's mistakes** (`census/mistakes.txt`, 31
  mutations of the JSON emitters applied alone, emit_probes.bot compiled):
  **31 of 31** decided as the exploratory checker decided -- including its
  precision limits (`utf8-by-length`, `strict-escape-unsplit`,
  `flat-serializer`: correct emitters, still rejected) and the mistakes
  outside the guarantee (a wrong value, a document's structure: accepted).
* **Generated emitters against exhaustive execution**
  (`tools/fuzz.tcl`, `results/fuzz.md`): 40 seeds of 8 claimed functions
  over one Int, every function run for every x in -6..120 and three huge
  values, every run judged by the reference interpreter:

  | | |
  |---|---:|
  | claims | 320 |
  | certified | 224 |
  | rejected | 96 |
  | of them confirmed by an invalid run | 93 |
  | precision losses (rejected, every run valid) | 3 |
  | **false proofs** | **0** |
  | runs | 41,600 |

  The prototype certified 221 and lost 6 to precision, all involving
  `mod`; the integrated `ModParts` recovers 3 (the remaining three are
  relations between two symbols, section 19).
* **Conformance** of the outcome model: 7,330 cases, 0 mismatches
  (section 6).
* **The examples run** on the Tcl compiler and on fused native code alike
  (`ec-examples-run`): emit_probes.bot's outputs are equal on both; its
  integers are one json_number each and its document one json_text for the
  reference interpreter; json.bot's own validator accepts the document and
  CPython reads it as the value it denotes.

## 16. Mutation results

`audit/emission-claims/tools/mutate.tcl` with `mutants.txt`: 57 mutants on a
private copy of the tree, each run against the tests its `match` names,
then both whole files when those pass.

* **The prototype's 34**, ported to the compiler's code (one, the observed
  model's `caller-facts-leak`, became `undeclared-as-nothing`: the
  production checker has no observed model to leak).
* **The integration's own 8**: re-verification of text, clones and trait
  operations followed, dependent claims reporting, a budget certifying,
  unknown values skipped, an unresolved claim dropped, type facts left out
  of fingerprints.
* **The shared value transfers, 12** (`range-*`, `intset-*`): addition,
  subtraction and multiplication bounds, `mod`'s wrap, sign and below-divisor
  rules, `shift_right`, `Narrowed`'s `<=` and `>`, the counted-loop
  interval, registered result sets, declared domains, the component budget
  and the hole.
* **The outcome model, 3+1**: `Unread`'s current and `more`, `Resume`'s
  reconsider, `Outcome`'s consume.

**First run: 52 of 57 killed.** The five survivors were each a test the
suite lacked, not a defect of the checker, and are recorded because a
mutation count alone says little:

| survivor | what it showed | the test now |
|---|---|---|
| `undeclared-as-nothing` | no claim had an untyped parameter | `ec-undeclared-parameter` |
| `negation-strict` | no test needed `x < K` false to keep K | `ec-negation-boundary` |
| `fingerprint-ignores-types` | a type change under unchanged code was untested -- and the prototype's fingerprint had no types at all | `ec-memo-types` |
| `range-mod-wrap` | every wrapping range tested was small enough for the exact path | `iset-mod-ranges`, the property test's palette divisors |
| `range-mod-below` | an operand equal to the least divisor was untested | `iset-mod-ranges` |

**Final run: 57 of 57 killed** (`results/mutants.md`).

## 17. Compilation and native performance

`audit/emission-claims/tools/bench.tcl` (`results/bench.md`), every scenario
a fresh process, the certificate memo off unless measured, on the 4-core
container of the other measurements (the prototype's figures from its
report, on the same machine type):

| workload | integrated | prototype |
|---|---:|---:|
| 22 claims (emit_probes.bot), summaries shared | 304 ms | 372 ms |
| of it: products with certificates' languages | 75 ms | 87 ms |
| of it: certificates (fingerprints, statements) | 40 ms | 32 ms |
| the 22 claims each checked alone, fresh state | 837 ms | 1,169 ms |
| summaries computed / reused | 140 / 60 | 140 / 60 |
| summaries computed, each claim alone | 448 | 348 |
| fixpoint rounds | 44 | 44 |
| emitlib from a program calling none of it, no memo | 127 ms | 127 ms |
| the same, a later compilation reusing the memo | 16 ms | 20 ms |
| of it: validation | 7 ms | 6 ms |
| after a helper's change: re-proof of its one claim | 49 ms | 59 ms |
| a rejected claim's diagnostics (invalid_emitter.bot) | 77 ms | -- |
| an imported, uncalled claim | 13 ms | -- |

* **Near the prototype** on every workload, without its whole-program
  specialization or range analysis. Certificates cost more (fingerprints
  now include every expression's type fact). Checking each claim alone
  computes more summaries than the prototype did (448 against 348: a
  function with two claims is checked whole for each, where the prototype
  ran one claim per process) and still takes less time, because a process
  here is not rebuilt per claim.
* **Front end.** A program without claims pays one scan of its expressions for
  an `emits` field; parsing and resolving claims is negligible. The whole
  compilation of emit_probes.bot took 3.82 s against 3.34 s with every
  claim removed (medians of three; an earlier run on the same machine,
  3.99 s against 3.66 s): the check measured inside it is 0.30-0.33 s, and
  the rest of the difference is within the 0.2 s that whole compilations
  of one program vary between runs.
* **Interchange.** The claims' records add 2.4% to emit_probes.bot's
  interchange text (1,914,947 bytes against 1,869,862); reading it back
  re-proves its 22 claims (0.37 s, the check again: text is no proof).
* **Native code.** A claim is erased: the fused NIR of a program driving
  `emitlib::json_string_source` is identical with and without the library's
  claims (so is its machine code); it holds no table load, no switch and no
  `dfa#transition`, and allocates no coroutine object (`ec-native-erasure`,
  bench `native`). The core IR of the JSON emitters with and without their
  claims is identical (`ec-claim-erased`). A guard is the run-time check the
  program asked for, nothing more.

## 18. Compatibility and regression results

**The whole local suite.** `tests/local.tcl` (255 Tcl test files on interp
and compile, golden duplicates skipped; 115 golden suites on all four
backends through the front-end cache; 90 minutes on 4 cores): 8,201 Tcl
tests passed on interp and 8,196 on compile, 5,510 golden tests on interp
and compile, 5,418 on cranelift-generic and 5,520 on cranelift, with four
failures -- each a consequence of this branch, each fixed:

| failure | cause | fix |
|---|---|---|
| `range-and-contract-values.bot`'s `rec-error-path-value/1`, `/3` (4 backends) | exact `mod`: `mod(500, 11)` was the suite's way to give a recursion an input known only as a range; it is 5 now, and `g(mod(500, 11) - 5)` a KNOWN-ERROR (section 4) | the input is `mod(k, 11)` with k from `std::int::from_string`, never folded; same in the Tcl original and `rec-executable-error-path`, the fragment and census rows, the manifest regenerated |
| `hir-closed-call-params.test`'s `closed-call-generic-interval-only` | the same idiom (`mod(999999, 1000000)`): exact, the narrowing gave the empty `[999999, 20]` the analysis has always given an exact value's unreachable branch (checked on the tree before this branch with a literal 999999) | input hidden the same way |
| `native-byte.test`'s `native-byte-high-nibble-nir-is-mask-not-branch` | the same idiom (`mod(200, 1000000)`): exact, the `iand` folded away | input hidden the same way |
| `golden-framework.test`'s `gf-code-name-complete` | `std::test::code_name` had no name for the 13 `Emit*` cases | the names added; the pinned count 120 -> 133 |

After the fixes: the 56 Tcl files that call `mod` or
`std::char::scalar_value` and `golden-framework.test`, every test
(duplicates included, as CI runs them): 2,488 passed on interp and on
compile, 0 failed; `range-and-contract-values.bot` 81/81 on all four
backends; `tests/golden.test` 9/9; the warning gate passes
(`stdlib/test.bot` is in its corpus).

**Run directly**, with private temporary directories: dfa (85),
dfa-workloads (21), static-compile (83, after the census's case count moved
120 -> 133), compilerpedia (42), hir-interchange (11), hir-cache (19),
compiler-service (55), lsp (71), syntax-recovery (33), diagnostic-recovery
(57), surface-modules (37), imports (104), bot-modules (56),
application-modules (21), main-cli (64), compilation-isolation (19),
static-economics (90), numeric-looking-names (5), coroutine-fusion (17),
hir-range (74), native-mod-lowering (17), native-result-bounds (12),
checked-domain-proof-provenance (18), byte-set (21), ascii (33): all pass.

* **Static decisions.** A claim reads its callees' code, so the site
  holding it depends on the sites in their bodies; the dependency graph's
  exact call edges already give that, and `se-equal-emission-callee`
  (`tests/static-economics.test`, 91 of 91) pins it: a claim certified only
  once its callee's site is rejected waits for that site in the batched
  order, and every scheduler decides it alike, in two builds.
* `tools/compilerpedia.tcl check`: 0 problems.
* The golden-migration census has rows for the two new test files
  (KEEP-INTERNAL: what a claim certifies is a compile-time record, not a
  value a program observes); the manifest is regenerated.
* Changed expectations, each a precision gain: `range-lattice-8`,
  `nrb-mod-in-range-analysis`; changed inputs, each a test that hid a value
  with `mod` of literals: the four rows above.
* **Source compatibility.** Exact `mod` can reject a program that compiled
  before, when a handled call's failure becomes statically known (section
  4); the tests above are the repository's every instance. Nothing else
  changes what a program without claims means or whether it compiles.
* **The static-decisions comparison** (CI only, by the repository's
  rules): the `static-decisions` workflow dispatched on the branch's head
  (8b74b4f, run 41418077590) compiled all 115 golden suites under the
  batched scheduler and the sequential reference -- mutable-array.bot in
  its own job (batched 5 rounds and 7 builds, sequential 69 and 205), the
  others in four shards -- and every suite agreed: no DISAGREE and no DOES
  NOT COMPILE.
* **Not run locally**, by the repository's rules: the GC-stress run (CI's
  `gc-stress`; no file of `native/` or `compiler/` changed: a claim is
  erased, and a tighter `mod` Range only feeds decisions native lowering
  already makes) and the macOS and Windows workflows, which run on main.

## 19. Remaining precision limits

Correct programs the analysis does not certify:

* **Relations between two symbols or between data and the grammar
  position** -- the second UTF-8 byte given the lead, the second hex digit
  given the first, the frame a flat serializer pops: the exploratory
  census's `utf8-by-length`, `strict-escape-unsplit`, `flat-serializer`
  and the fuzzer's three remaining losses. The facts are sets of single
  values; relational analysis was out of scope. The grammar-shaped
  versions are as readable and certified.
* **Values received from another coroutine** are values of their type,
  even when that coroutine is certified (`forwarded-values`): no handle is
  tracked.
* **Struct fields and List elements** are their declared types' facts.
* **Trait operations and context-trait implementations** are not followed
  (EMIT-UNSUPPORTED), deliberately (section 7).
* **Undeclared parameters** get no fact from their inferred contracts.
* **HIR text** carries no recognizer tables: its claims are not proved.
* **A callee that stops yielding because a `static compile:` block in it
  was rejected** is called as its declared result type: a function whose
  only yield follows its rejected block no longer yields, so its call
  completes, as far as the walk knows, with nothing yielded, and a claim
  that needs it to emit is EMIT-INCOMPLETE although the call always fails.
  This follows the compiler's rule for a rejected block's callers (they may
  complete normally: KNOWN-ERROR never treats a reified failure as proof
  that they cannot) rather than refining it; batched, sequential and
  legacy schedulers decide it alike (`se-equal-emission-callee`).

## 20. Architectural implications and next steps

* **Three analyses now share hir::range's transfers** -- representation
  (native lowering), completion proofs and emission certificates -- and the
  last makes each transfer a security rule. Their audit is a test file of
  properties against concrete evaluation and a mutation set, which any
  later change to a transfer runs (AGENTS.md, "Emission claims").
* **One outcome model, two representations**: a later recognizer feature
  (actions, pushdown structure) changes core/dfa.tcl's statement once.
* **Next: separately compiled artifacts.** Certificates are already the
  statement a caller needs; what is missing is an interface artifact the
  compiler trusts (signed by the toolchain, or re-checkable from a
  compact proof), and modular domain admission at its boundary (section
  10). Until then the trust boundary is the process.
* **Next: relational facts** would recover the remaining precision limits;
  **handle tracking** would let a consumer forward a certified producer's
  symbols.
* **Retirement.** The prototypes (`audit/emitter/`, `audit/emission-
  proofs/`) stay as the baseline and history; their evidence and tests are
  migrated (`tests/emission-claims.test`, `audit/emission-claims/`). Their
  directive (`#: emits`) has no meaning to the compiler.

## A. Changes from the modular prototype

| prototype | integrated | why |
|---|---|---|
| `#: emits R` directive, a tool reading HIR | the clause; a pass of `hir::BuildFull` | production |
| `intset.tcl` beside the checker | `hir/intset.tcl`, over hir::range | one value analysis |
| `mod` bounded by the divisor | `ModParts`: exact residues and wrap parts | the prototype's six precision losses |
| trusted table for scalar_value | `-result-range {intervals ...}` | facts are registrations |
| `dfasem::LeafMeaning`/`Complete` beside Lower | core/dfa.tcl's model, consumed by both | one statement |
| verdicts proven / disproven / not proved | proven / rejected / not-proved / dependent; disproven by the witness tool only | the compiler never runs code |
| observed facts, invocation-level checks | removed | measurement only; never a certificate |
| composition by body or by certificate (`-compose`) | by certificate when the helper has one, else by body | the prototype's default; both decided alike (its `ep-compose-modes`) |
| certificate store file | in-process memo; re-verification of text | a file is no proof |
| fingerprints without types | with every expression's type fact and outside bindings' facts | a stale reuse the mutation audit exposed |
| untyped operand never narrowed | narrowed by an order comparison | precision; sound by the native's contract |
| a budget-exhausted claim reports what it found | reports the budget only | a round's facts are no finding |
| -- | trait and context-trait clones unsupported | production programs are monomorphized |
| -- | dependent claims (recovery) | diagnostics never restate another |

## B. Files

* `hir/emission.tcl` -- the checker; `hir/emitdfa.tcl` -- recognizers over
  sets; `hir/intset.tcl` -- the value domain; `core/dfa.tcl` -- the outcome
  model; `hir/range.tcl` (`ModParts`, `RegisteredSet`), `core/native.tcl`
  (`intervals`), `core/unicodechar.tcl` (the registration).
* The clause: `surface/parser.tcl` (`EmitsName`), `surface/modules.tcl`
  (`Walk`, `RemapFile`), `surface/lower.tcl`, `hir/syntax.tcl`
  (`withEmits`, `withRecognizer`), `hir/resolve.tcl` (`ResolveEmits`),
  `hir/format.tcl`, `hir/read.tcl`, `hir/signatures.tcl`; `surface/dfa.tcl`
  (Lower from the model, the table on the recognizer).
* Trust: `hir/interchange.tcl` (`reverify` on decode); placement:
  `hir/hir.tcl`; codes: `hir/static.tcl`, `stdlib/compiler.bot`; service:
  `service/service.tcl`.
* `compilerpedia/topics/emission.topic`, `errors-runtime.topic`.
* `examples/dfa/json/`: `json_grammar.bot`, `number_emit.bot`,
  `string_emit.bot`, `value_emit.bot`, `emitlib.bot`, `sinks.bot`,
  `emit_probes.bot`, `emit_demo.bot`, `invalid_emitter.bot`.
* `tests/emission-claims.test`, `tests/interval-sets.test`,
  `tests/emission-support.tcl`.
* `audit/emission-claims/`: `tools/` (`witness.tcl`, `census.tcl`,
  `fuzz.tcl`, `conformance.tcl`, `mutate.tcl` with `mutants.txt`,
  `bench.tcl`), `census/` (`cases.txt`, `mistakes.txt`), `callers/`,
  `results/`.
