# MODULAR-EMISSION-PROOFS-MILESTONE-1.md

Modular, sound verification of coroutine yield traces against declared
recognizers: can a claim that a function emits one token of a declared DFA
be certified from the function's declaration and implementation alone, so
that it holds for every caller, and be reused?

> A verified property of a library function must hold because of that
> function's declared interface and implementation, not because of the
> particular callers the compiler happened to observe.

The milestone is a census and a proof prototype, isolated in
`audit/emission-proofs/`: no file of `core/`, `hir/`, `surface/`,
`compiler/` or `native/` changed, the language gained no syntax, and the
exploratory checker of EMITTER-COROUTINE-EXPLORATION.md (`audit/emitter/`)
is kept unchanged as the baseline. Its answer is **yes**: definition-level
certification is practical, sound on every piece of evidence gathered, and
about ten times cheaper than the exploratory walk -- and the soundness audit
it required found that the exploratory checker's certificates were not
merely caller-dependent but in four cases false for the very programs it
checked.

## Contents

1. [Result](#1-result)
2. [Semantic guarantee](#2-semantic-guarantee)
3. [Certification scope](#3-certification-scope)
4. [Declared input domains](#4-declared-input-domains)
5. [The independent library](#5-the-independent-library)
6. [Modular function summaries](#6-modular-function-summaries)
7. [Control flow](#7-control-flow)
8. [Coroutine boundaries](#8-coroutine-boundaries)
9. [Guards](#9-guards)
10. [Value facts](#10-value-facts)
11. [DFA semantics](#11-dfa-semantics)
12. [Boundary composition](#12-boundary-composition)
13. [Proof artifacts](#13-proof-artifacts)
14. [Correctness evidence](#14-correctness-evidence)
15. [Mutation evidence](#15-mutation-evidence)
16. [Performance](#16-performance)
17. [Precision limitations](#17-precision-limitations)
18. [Language implications](#18-language-implications)
19. [Recommendation](#19-recommendation)
20. [Next milestone](#20-next-milestone)
21. [Final decision questions](#21-final-decision-questions)

Appendix: [A. Files](#a-files).

## 1. Result

**A function's emission guarantee can be certified as a property of its
declaration.** The modular checker (`audit/emission-proofs/tools/
modcheck.tcl`, with `intset.tcl` and `dfasem.tcl`) enters a claimed
function with its *declared* parameter domains -- an `int` is every Int, an
integer domain its interval, a `str` any text -- and never with what a
program passes. Everything else it knows comes from the function's own
code: its branches, loops, guards and handlers, and the helpers it calls,
each analyzed under the facts the function's own body establishes at the
call. It reads no whole-program range instance, no specialization, no
caller set. A function no program calls is certified or rejected like any
other; the exploratory checker's EMIT-UNUSED is gone.

* **The exploratory milestone's 22 claims** (`check_all.bot`: the JSON
  integer, string, byte and document emitters) are all certified from
  their declarations, in 0.3-0.4 s of checking against the exploratory
  walk's 1.6 s on the same machine -- and without the whole-program
  specialization and range analysis the exploratory walk needed first
  (section 16) -- and **the exploratory census's 31 cases** are
  decided alike: every one of its 24 rejected cases rejected, every one of
  its accepted cases accepted (section 14).
* **The independent library** (`lib/emitlib.bot`, section 5): a JSON string
  emitter for every `str` (strict grammar, partial-token helpers),
  certified; an unguarded digit emitter over `int`, **disproven** with the
  concrete counterexample `d = -1`; the same digit guarded by a recognizer
  declared from json_lex's `digit` class, certified (for every Int it fails
  `NotADigit` or emits a digit); the digit over a declared integer domain
  `DigitValue = Int in 0..9`, certified with no check at run time. Checked
  from five unrelated programs -- safe values only, the whole domain,
  invalid values, compositions, no call at all -- the library's verdicts are
  identical in all five; the exploratory checker's differ between programs
  for 7 of the 8 claims (proved, rejected, or unused, by caller; the eighth
  is unused in all five).
* **Certificates are reused across compilations** and invalidated exactly
  by what they depend on: a certificate store written by the first program
  is validated (not re-proved) by the other four; a comment or a new caller
  invalidates nothing; a helper's code invalidates its function's
  certificate and nothing composed on it; a recognizer's table invalidates
  every certificate that reads it (section 13).
* **Composition**: a caller composes with a certified helper through the
  certificate's *statement* -- its recognizer's language restricted to the
  states the certificate says the helper visits, fails in and ends in, and
  the boundary obligations still open at its exits -- never through the
  helper's body. Composing by bodies gives the same verdicts on every claim
  of check_all.bot and of the library (section 12).
* **Soundness evidence** (sections 14-15): the recognizer semantics the
  checker reads agree with the reference interpreter on 7,201 generated
  inputs over 18 recognizers; the modular census's 23 claims, each with
  its concrete truth from real runs; 320 generated claims checked against
  41,600 runs exhausting each function's behavior: 0 false proofs, 6
  correct claims not proved; 34 mutants of its proof rules, all killed; 55
  tests.
* **The exploratory checker's certificates were not all true.** Of the
  modular census's 23 claims, the exploratory checker proved 9 that are
  false for their declarations: 6 because its facts came from the callers
  (each caller passes only valid values -- the milestone's central
  concern, now measured), and **3 because of rules of its own that are
  unsound for the very programs checked**, whose callers pass the values
  that break them: a symbol of 10^23 vanished at its sentinel bound, and,
  twice, a handler that resumed emission after a failure was entered from
  the states before the failing helper's last symbol, not after it
  (section 14); the fuzzer found the second rule again on its own. Both
  are fixed by construction in the modular checker (true infinities;
  failure points); both would have been certified security claims.
* **No grammar at run time.** A certified emitter compiles to the code it
  would without the claim (the claim is a comment): the fused native code
  of `emitlib::json_string` holds no table load, switch or
  `dfa#transition` (`ep-native-erasure`). A guard is the one run-time cost
  the program asks for (section 9).

What remains experimental (section 19): the claim form (a directive
comment), the checker's place (an audit tool reading the HIR, not a
compiler pass), the certificate store (a file beside the program, not an
interface artifact), the one value rule hir::range lacks (a hole in an
interval), and the recognizer outcome semantics stated beside the
lowering, not by it.

## 2. Semantic guarantee

### Definitions

*Symbols.* An emitter yields Ints. A yield is the *outward* event of the
coroutine whose execution reaches it: a yield in F's own body, or in a
function F calls by an ordinary (exact) call -- a deep yield -- belongs to
the execution of F's call. A yield in a coroutine F *constructs* belongs
to that coroutine; constructing, resuming or abandoning it is ordinary code
of F, and the values F receives from it are ordinary values, not F's
symbols. A call through a function value never yields (COROUTINES.md: a
function that may yield never becomes a value).

*The outward yield trace* of one invocation of F is the sequence of symbols
yielded during that invocation, in order, by F and its ordinary callees,
up to the invocation's end: a normal completion (a return or the end of
the body), a failure (an error propagating out of F), or never (it runs
forever or is abandoned by its consumer). The terminal value of a coroutine
root is not a symbol; a helper's result is not a symbol.

*Recognition.* For a recognizer R (DFA-COROUTINE-MILESTONE-2.md), a trace
`w` is *exactly one token* of R when R, run on `w` and then the end of the
input, completes with nothing unread: it never rejects, never completes
before the last symbol of `w` (a completion that leaves symbols of `w`
unread, `accept before N` on a symbol of `w`, is a token shorter than `w`),
never completes on a symbol of `w` with symbols still to come, and at the
end completes with 0 unread (`accept before N` at the end leaves the last N
symbols outside the token). A trace `p` is a *viable prefix* of R when R,
run on `p` with no end, neither rejects nor completes before consuming all
of `p`.

### The guarantee

A function F is **certified to emit R** when, for every argument tuple F's
declaration permits:

1. every invocation of F that completes normally has an outward yield trace
   that is exactly one token of R; and
2. every finite outward trace of an invocation, at every moment -- before
   completion, at a failure, or when the consumer stops resuming -- is a
   viable prefix of R's language.

"Every argument tuple the declaration permits" is the set of values of the
declared parameter types: every Int for `int`, the declared interval for an
integer domain, every value of the type otherwise. It is never the set of
values the callers of some program pass.

### What it does not imply

Termination (an emitter that never completes satisfies 1 vacuously and 2
for every prefix); a returned value; semantic preservation (a valid token
of the wrong value: the exploratory census's `wrong-digit-value`); absence
of other effects; atomic output (a failure leaves a viable prefix in the
sink); validity of an enclosing document (a token, or json_text's lexical
stream, is not a document: JSON's nesting is not regular); reversibility;
any run-time validation. A failure after a valid prefix does not violate
the guarantee; a caller that catches it and goes on emitting is checked on
its own complete trace (`ep-fail-after-yield`, `caught-after-prefix`).

### Token boundaries

Calling two individually certified token emitters does not produce two
tokens: `12` then `34` is the number `1234`. The guarantee of a helper H
claimed for K therefore carries a **boundary obligation** in its callers:
when the caller's own parse delegates H's output to K -- a frame of K that
H entered (none was open when H was called) and that is still open when H
returns -- the next symbol the caller's execution yields must end that
frame. The obligation is discharged by the next symbol's step when the
frame completes during it, by the end of the input (K accepts the end in
every exit state of a certified H), and passes through returns unchanged.
It is checked against the caller's recognizer, so it constrains only what
the caller's grammar would read as one token (section 12).

## 3. Certification scope

Three ways to decide a claim, all on one engine (the same summaries, the
same value facts, the same recognizer semantics), differing only in the
facts the claimed function is entered with:

| scope | the claimed function is entered with | `modcheck.tcl` |
|---|---|---|
| **definition level** | its declared parameter domains | the default |
| **invocation level** | at one call site (or coroutine construction), what the caller's own body -- itself entered with *its* declared domains -- establishes there | `-invocation CALLER,CALLEE,R` |
| observed (for comparison) | what the program's calls pass: each reached function entered with its callers' facts, to a fixpoint from the top-level statements | `-facts observed` |

The third is the exploratory checker's model rebuilt on the modular engine
(its facts were hir::range's instances, seeded by the program's calls). It
is kept only to measure what the other two avoid.

**What each proves.** Definition level: the guarantee of section 2 for
every permitted argument -- a property of F, reusable anywhere. Invocation
level: the guarantee for the argument values reachable at one site of one
caller, given only that caller's declaration -- a property of the call,
reusable as long as the caller's code is unchanged, and itself modular
(it does not depend on the caller's callers). Observed: the guarantee for
the arguments one program happens to pass -- a property of the program,
which changes when a caller is added.

**Which correct programs each accepts** (the library, section 5, and the
census, section 14):

| | definition | invocation | observed |
|---|---|---|---|
| a guarded emitter (`digit_checked`) | proven | proven | proven where it is called, unused elsewhere |
| an emitter over a declared domain (`digit_of`) | proven | proven | as above |
| an unguarded emitter, valid only for some arguments (`digit_unchecked`) | disproven (`d = -1`) | proven at `src_unchecked` (3), not at `src_bad` (-1), not at `digit_unchecked_source` (every Int) | proven in safe.bot; not proved in full.bot and invalid.bot, whose calls pass invalid values; nothing to check in the other two |
| a function no program calls | decided | nothing to check | nothing to check |

**Composition across modules.** Only definition-level certificates compose
without re-analysis: a caller relies on the callee's certificate (its
statement), whatever calls the callee elsewhere. An invocation-level result
is a property of one site; it composes only inside the caller's own proof
(and is exactly what the caller's definition-level proof computes for that
call). Observed facts compose nowhere: adding a caller can invalidate them
(the library's observed column changes with every program).

**Syntax and types.** None of the three needs a new type. Definition level
needs a claim on the declaration (section 18); invocation level would need
a claim on a call or a coroutine construction, which is new syntax in an
expression position -- and its useful cases are already expressible: a
caller that wants the guarantee for its own call claims its *own* emission
(its definition-level proof checks the call with the call's facts), or
wraps the call in a function whose declared domain says what it passes.

**Cost** (section 16): definition level is the cheapest per claim once
helpers are shared, because its summaries are reusable by every claim and
every program; invocation level adds one walk of the caller per site;
observed facts need a fixpoint over the whole program's call graph before
any claim is checked.

**Stability.** Definition-level verdicts were identical across the five
library callers; observed verdicts differed between programs for 7 of the
8 claims, and the exploratory checker's for 7 of 8 too (the eighth was
unused everywhere).

**Conclusion.** Definition-level certification is practical enough to
justify a declaration: it accepts every correct emitter of the workload the
observed model accepted, except those whose correctness depends on what
callers pass -- which are exactly the claims that were never properties of
the function. Those have two honest repairs, both available today: a guard
(the claim then says "fails or emits a valid token") or a declared integer
domain (the callers must prove the value).

## 4. Declared input domains

`modcheck::Declared` gives each parameter of a claimed function the facts
of its declared type, through `hir::range::TypeFact` (the compiler's one
reading of an integer type's facts): `int` is `{-inf..+inf}`, `type Digit =
Int in 48..57` is `{48..57}`, a domain with exact values its points, and
any other type `*` (not an Int, or not known to be one: a yield of such a
value is not proved). A parameter with no declared type is `*`: the
inferred contract of an untyped parameter is not used (it is derived from
the body, which is sound in itself, but it is a weaker statement than a
declaration a caller can read; a claim on an undeclared parameter that
reaches a yield is not proved).

Nothing else enters: not `hir::range`'s instances (their parameter facts
are the joins of the program's call sites), not `hir::specialize`'s
instances (keyed by the program's argument types), not `inferredParamTypes`
or `checkedParamTypes`. `hir::exact` is used for constants and module
bindings only: it is a fact of the HIR (an immutable binding's one value),
the same in every program.

Within the proof, a helper is analyzed under the facts the claimed
function's own body establishes at the call -- its branches, guards,
arithmetic -- intersected with the helper's declared parameter types. Those
facts are properties of the implementation, not observations of callers:
`hex_digit(v.shift_right(12))` inside `unicode_escape` is analyzed with the
first nibble of the values `unicode_escape`'s own callers inside
`json_string` pass, and the whole chain starts from `json_string`'s
declared `str`.

**What a declared domain trusts.** A parameter of type `DigitValue` is
`0..9` in the proof because the compiler proves every call's argument in
the domain (hir::range's VerifyCall, CORE SEMANTIC TYPE). Today that
admission check is itself whole-program: a helper's domain obligation may
be discharged by hir::range's caller-propagated facts. That is sound for
every program that compiles -- the domain holds at every call that runs --
but a separately compiled library would need each call's obligation proved
from its caller's declaration. emitlib discharges every one locally
(`body_char(c: Scalar)` narrows `c` before it calls
`unicode_escape(c: CodeUnit)`). The exploratory checker read a value of an
integer domain as a non-symbol (EMIT-NOT-SYMBOL: it compared static types
with `int`), so it could not check this library's string emitter in any
program.

## 5. The independent library

`audit/emission-proofs/lib/emitlib.bot` exports:

| function | claim | what its proof needs |
|---|---|---|
| `json_string(text: str)` | json_lex::json_string_strict | the full domain of `str`: scalar values (trusted: never a surrogate), the escape policy's branches (`c == 34 or c == 92`: a hole in an interval), partial-token helpers `short_escape`, `unicode_escape(v: CodeUnit)`, `hex_digit(n: Nibble)`, `body_char(c: Scalar)` -- none of which has or needs a claim |
| `digit_unchecked(d: int)` | json_grammar::digit_symbol | nothing proves `48 + d` a digit for every Int: disproven, `d = -1` yields `/` |
| `digit_checked(d: int)` | json_grammar::digit_symbol | a guard (`json_grammar::digit_symbol(c)`, declared from json_lex's `digit` class) whose failure becomes `NotADigit` |
| `digit_of(d: DigitValue)` | json_grammar::digit_symbol | the declared domain `Int in 0..9` |
| `member(key: str, n: int)` | json_grammar::json_text | `json_string`'s and `number_emit::integer`'s certificates, a `:` between |
| `pair_glued(a: int, b: int)` | json_grammar::json_text | two integers back to back: disproven, `(0, 0)` gives `[00]` |

and two coroutine roots (`json_string_source`, `digit_checked_source`).

The five entry programs in `audit/emission-proofs/callers/`:

| program | what it does with the library |
|---|---|
| `safe.bot` | only values the exploratory checker infers as safe: `digit_unchecked(3)`, `digit_checked(4)`, `digit_of(5)`, `json_string("plain")` |
| `full.bot` | every Int in -20..20 and two huge ones through both digit emitters; texts of every character class through `json_string` |
| `invalid.bot` | invalid values: `digit_checked(42)` and `(-7)` (handled `NotADigit`), `digit_unchecked(-1)` (which then writes `/`: it is not certified) |
| `compose.bot` | larger streams: an object of members and a list of guarded digits, its own two claims certified through the library's certificates |
| `unused.bot` | imports the library and calls none of it |

`tools/library.tcl` (`results/library.md`) checks the library from each:

Modular checker (definition level, no certificate store):

| claim | safe | full | invalid | compose | unused |
|---|---|---|---|---|---|
| `emitlib::digit_checked` digit_symbol | proven | proven | proven | proven | proven |
| `emitlib::digit_checked_source` digit_symbol | proven | proven | proven | proven | proven |
| `emitlib::digit_of` digit_symbol | proven | proven | proven | proven | proven |
| `emitlib::digit_unchecked` digit_symbol | disproven | disproven | disproven | disproven | disproven |
| `emitlib::json_string` json_string_strict | proven | proven | proven | proven | proven |
| `emitlib::json_string_source` json_string_strict | proven | proven | proven | proven | proven |
| `emitlib::member` json_text | proven | proven | proven | proven | proven |
| `emitlib::pair_glued` json_text | disproven | disproven | disproven | disproven | disproven |

The same checker with observed facts (`-facts observed`: each claim entered with what the program's own calls pass -- the exploratory model, for comparison):

| claim | safe | full | invalid | compose | unused |
|---|---|---|---|---|---|
| `emitlib::digit_checked` digit_symbol | proven | proven | proven | not-proved | not-proved |
| `emitlib::digit_checked_source` digit_symbol | not-proved | proven | proven | not-proved | not-proved |
| `emitlib::digit_of` digit_symbol | proven | not-proved | not-proved | not-proved | not-proved |
| `emitlib::digit_unchecked` digit_symbol | proven | not-proved | not-proved | not-proved | not-proved |
| `emitlib::json_string` json_string_strict | proven | proven | not-proved | proven | not-proved |
| `emitlib::json_string_source` json_string_strict | not-proved | proven | not-proved | not-proved | not-proved |
| `emitlib::member` json_text | not-proved | not-proved | not-proved | proven | not-proved |
| `emitlib::pair_glued` json_text | not-proved | not-proved | not-proved | not-proved | not-proved |

Exploratory checker (EMITTER-COROUTINE-EXPLORATION.md: facts of the program's own calls):

| claim | safe | full | invalid | compose | unused |
|---|---|---|---|---|---|
| `emitlib::digit_checked` digit_symbol | proved | proved | proved | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::digit_checked_source` digit_symbol | EMIT-UNUSED | proved | proved | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::digit_of` digit_symbol | proved | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::digit_unchecked` digit_symbol | proved | EMIT-REJECTED | EMIT-REJECTED | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::json_string` json_string_strict | EMIT-NOT-SYMBOL | EMIT-NOT-SYMBOL | EMIT-UNUSED | EMIT-NOT-SYMBOL | EMIT-UNUSED |
| `emitlib::json_string_source` json_string_strict | EMIT-UNUSED | EMIT-NOT-SYMBOL | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED |
| `emitlib::member` json_text | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED | EMIT-NOT-SYMBOL | EMIT-UNUSED |
| `emitlib::pair_glued` json_text | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED | EMIT-UNUSED |

compose.bot's own claims (through the library's certificates): digits: proven, object: proven

The modular verdicts are the same in every column -- the library's
certification does not change with its callers. The observed model and the
exploratory checker change in nearly every row: `digit_unchecked` is
"proved" from safe.bot, whose only call passes 3.

**Separate compilation.** The toolchain has no separately compiled
artifacts (every compilation reads every module's source; the front-end
cache is per program file). The boundary is therefore demonstrated with a
certificate store: the first compilation proves the library's claims and
writes their certificates; each later compilation -- of a different
program, by a fresh front end -- validates each stored certificate against
its own HIR (fingerprints, section 13) and reuses it without walking the
function:

| caller | proved | reused | check ms |
|---|---:|---:|---:|
| safe | 10 | 0 | 98 |
| full | 0 | 10 | 20 |
| invalid | 0 | 10 | 20 |
| compose | 2 | 10 | 79 |
| unused | 0 | 10 | 18 |

This is a whole-program recompilation of the library's source each time,
with the *proof* reused -- not separate compilation, which would need the
certificates in an interface artifact the compiler reads instead of the
library's source (section 13).

**Invalidation** (store of B, each change checked from `unused.bot`, then
undone):

| change | re-proved | reused | not proven | check ms |
|---|---|---:|---|---:|
| a comment changed in emitlib.bot |  | 10 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 19 |
| a new, unrelated caller program |  | 10 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 40 |
| json_string's policy: '/' escaped as \/ | `emitlib::json_string` | 9 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 61 |
| a helper's code: hex_digit's letters uppercase | `emitlib::json_string` | 9 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 57 |
| the recognizer: json_lex's escapes lose `\/` | `emitlib::json_string`, `emitlib::member`, `emitlib::json_string_source` | 7 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 93 |
| number_emit's helper: magnitude's loop written another way | `number_emit::integer` | 9 | emitlib::digit_unchecked digit_symbol (not-proved), emitlib::pair_glued json_text (not-proved) | 38 |

A changed helper re-proves the function that analyzed it -- and nothing
that composed with that function's certificate, whose statement did not
change. A changed recognizer changes the statement of every certificate
reading it.

**Invocation level** for the unguarded digit, at each place it is called:

| program | caller | arguments there | verdict |
|---|---|---|---|
| safe.bot | `src_unchecked` | 3 | proven |
| invalid.bot | `src_bad` | -1 | not-proved |
| unused.bot | `emitlib::digit_unchecked_source` | -inf..+inf | not-proved |

## 6. Modular function summaries

A **summary** answers: what does a call of function B do from one composite
recognizer state C (section 11) with argument values ARGS? Its record:

| field | meaning |
|---|---|
| exits | the composite states its normal completions leave |
| visits | every state it is in between symbols (entry and after each yield) |
| fails | every state in which it may fail: at a `fail`, or at a call that may fail (a native with errors, a function with declared errors, a call through a value), and its callees' failure states |
| result | the Int values it may return |
| violations | the violations its own yields commit (kind, yield, state, symbols) |
| children | the summaries its calls used |

The key is `{B C ARGS}`: function identity, entry state, and the argument
facts -- the *minimum* that changes the result, since bindings are
immutable and a function's behavior depends on nothing else (captured
bindings are read through their types). A helper used from several
recognizer states or with several argument contexts has a summary per
pair; a helper whose summary in some context would be unsound in another
is never merged with it.

**Partial-token helpers need no claim.** `hex_digit` emits one hexadecimal
digit, `unicode_escape` six symbols of an escape, `body_char` one
character's representation: none is a token of anything, and each is
analyzed as a state transformer in the context its caller enters it.
Only functions whose whole output is meant to be a token carry a claim,
and only those carry boundary obligations.

**Computation.** A claim is solved in rounds (`modcheck::Solve`): each
round recomputes, from the previous round's values, every summary the root
reaches; a summary's values only grow (each round's record is united with
the previous one), and a round in which nothing changed ends the solve.
Every summary the solve touched is then **final** and reused by every
later claim of the run -- the summaries of `hex_digit` computed for
`json_string` serve `json_string_source`, `member`, and every caller.
Diagnostics are attached to summaries, so a reused summary carries its
violations into each claim that reaches it (the exploratory checker reset
its summaries per claim; a reuse without attached diagnostics would have
been a way to lose them).

*Termination.* Composite states are finite (calls between recognizers are
acyclic: DFA-RECURSIVE-CALL); exits, visits and fails only grow over a
finite set. Result sets could grow without bound (`f(n) = f(n-1) + 1`): a
result that changed more than 4 times is widened to its declared type's
facts. Argument contexts are bounded at 12 per function; a further call
uses the declared parameter facts (always sound: every argument value is in
its declared type). A solve that exceeds 60 rounds or 40,000 summaries
stops: the claim is EMIT-BUDGET, not proved, and nothing it touched is
final.

*Soundness of the fixpoint.* At convergence, each touched summary S
satisfies F(S) ⊆ S, F being one walk of its body with every callee read
at its converged value. By induction on the depth of an execution, every
terminating execution's exit state, failure state and result is in its
summary: an execution of depth k reads callees of depth < k, whose actual
outcomes are in their summaries; the walk of its body with those summaries
over-approximates its own path. "Cannot complete" facts (a branch whose
call never returns, so the other branch's negation holds after the `if`)
are sound by the same induction: a summary with no exit has no
terminating execution. The prefix property needs no termination: a symbol
an execution yields is reached by finitely many steps -- calls entered in
some state, each with its own summary -- and the same induction on those
steps puts its state, and so the yield's check, in the walk (a recursion
that never ends still has every yield on its way down checked).

**Language summaries.** Composing by a certificate (section 12) needs no
summary of the helper at all: `LangSummary` caches, per certificate
statement and caller state, the product of the certificate's language
with the caller's automaton -- shared by every helper certified with the
same statement and every caller in the same state.

**Reuse, measured** (section 16): on check_all.bot the 22 claims compute 140
summaries (and language products) and find one already made 60 times;
checked one claim per run from scratch, they compute 348 and take 3.1
times as long (1,169 ms against 372); `string_codes`' claims reuse the
`character` summaries `string`'s made, the `*_source` claims their
emitters' certificates. Per claim, the check takes 0.8 to 55 ms, 19 on
average.

## 7. Control flow

The walk (`modcheck::Eval`) interprets the function's HIR -- the one every
backend compiles -- over sets of composite states, threading an
environment of binding values.

* **Sequences** in order; a statement whose state set is empty ends the
  sequence (nothing after it is reachable).
* **`if`**: the condition evaluated, then each outcome whose path facts are
  feasible (hir::range::Paths decomposes `and`, `or`, `not`; each
  comparison of a binding with a value narrows it; hir::types::KnownOutcome
  decides constants) walked with them; the states united, the environments
  joined over the branches that complete. A branch that cannot complete
  leaves only the other's environment -- the negation of its condition --
  for what follows.
* **Loops** to a fixpoint over the state set (the environment of the
  loop's entry, plus the induction binding, in every iteration: bindings
  are immutable, so nothing an iteration binds survives it). A counted
  domain:
  * with an exact start is *peeled*: the first iteration with the counter
    at its start, the fixpoint of the later ones past it (`if i > 0:` the
    separator, the idiom of every list printer);
  * with an exact start and end and at most 8 iterations is *unrolled*:
    each iteration with its own counter value, no zero-iteration exit when
    it runs, no iteration past the last (`ep-loop-exact-count`: `from 0 to
    1` emits one digit, `from 0 to n` may emit none);
  * otherwise the induction binding is hir::range::InductionBinding's
    interval, and the loop may end before its first iteration.
* **`break`, `continue`, `return`** send their states to their targets
  (`return` of the function being walked only; a nested function is not
  walked where it is defined).
* **Recursion** through the rounds of section 6: `ones(n)` (`if n > 0:
  yield '1'; ones(n - 1)`) is disproven (its base case completes empty),
  `ones1` (a `'1'`, then `ones`) proven; `rec` (a recursive call, then an
  `x`) rejected in its second round, which a solve stopped after one round
  would have missed (`ep-recursion-second-round`, mutant
  `recursion-one-round`).
* **Functions that never return normally** have no exit; their claim is
  about their prefixes only (`ep-never-returns`: ones forever proven, a
  zero then ones rejected at its second symbol).
* **Early returns** contribute their states to the exits
  (`ep-early-return`: a return before the digit is EMIT-INCOMPLETE).
* **Exceptions.** A failure can occur only at a *failure point*: a `fail`,
  a native call with errors (or one raising a callable's), a call of a
  function that declares errors (or declares no signature), a call through
  a value, a coroutine operation, a guard. Each records the current states;
  a helper's failure states are its summary's `fails`. A `handle` walks its
  protected call collecting failure states, starts each handler from
  exactly those (with the environment from *before* the call: no fact the
  call established holds on its failure path), and also passes them on to
  the enclosing failure points (a handler catches only its errors). A call
  that cannot fail has unreachable handlers.

  The exploratory checker entered handlers from the states *before* each
  yield, never after the last one: a helper that wrote a closing quotation
  mark and then failed, caught by a handler writing another, was certified
  (census `fail-after-yield-handled`, `caught-after-prefix`). The modular
  checker's failure points include every state after a yield at which a
  failure can come, and none at which it cannot: `guarded`, whose guard
  fails before its symbol, composes into a handler that writes `0` instead
  (`caught-before-yield`, proven), which "every visited state" would have
  rejected.

**Path reachability.** A branch is excluded only when its condition is
infeasible under the declared parameter facts and the function's own
facts on the path (narrowing to an empty set, or a statically known
outcome). Nothing is excluded because no caller takes it: the observed
model's exclusions are the census's five caller-facts false proofs.

## 8. Coroutine boundaries

* `coroutine#yield` in the walked code is a symbol of the execution being
  checked; a call of a function that may yield (hir::coroutines::MayYield)
  contributes its summary -- its yields are the caller's (deep yields).
* `coroutine {step, first} = g(a)` constructs another execution: its thunk
  is a nested block, which the walk does not enter, so g's yields are g's.
  `first`, every `step()` and every `done?` are values: Ints of unknown
  value (`ep-separate-coroutine`: an emitter that constructs and resumes a
  coroutine of invalid symbols and then yields `'7'` is proven; one that
  forwards `first` is not proved -- even when the constructed emitter is
  itself certified (census `forwarded-values`): a value received from a
  coroutine is not covered by that coroutine's certificate, because the
  checker tracks no handle. A consumer that forwards symbols guards them.
* A coroutine's construction and resumption may fail (its root's errors):
  they are failure points.
* A call through a function value never yields (a function that may yield
  never becomes a value), so it changes no state; it may fail.
* A trait operation's implementation is chosen after this check
  (TRAITS.md): the checker does not follow it -- EMIT-UNSUPPORTED, not
  proved. So does any HIR form the walk does not model.
* A coroutine root's terminal value is not a symbol. A claimed function
  whose declared result is an Int is a *symbol source* (it may be a
  coroutine root whose stable final value a consumer reads after the end):
  its result must be exactly -1 (EMIT-TERMINAL-VALUE). This is a
  declaration-level rule: the exploratory checker applied it only to
  functions some program happened to construct a coroutine of.

## 9. Guards

A **guard** is a call of a recognizer none of whose transitions suspends
-- an ordinary function of one symbol -- with a binding as its argument
(`json_grammar::digit_symbol(c)`, declared `start: json_lex::digit ->
accept`: no class restated). Its normal completion proves the binding is
in the set of symbols on which the recognizer's first step *completes* --
read from the lowering's table (section 11), every completion counted,
whatever it leaves unread (the exploratory checker counted only completions
taking the symbol; a first-step `accept before` is ruled out by the DFA
checks, so the difference never arose, but the fact must be what a normal
completion proves).

* The fact holds on the paths where the call completed: after it in the
  sequence, never in its handlers (`ep-guard-facts` `absorbed`: a handler
  that absorbs the failure and goes on, then yields the binding, is
  rejected; mutant `handler-keeps-guard`).
* It is a fact of the binding, not of values computed from it
  (`derived`: `c + 1` after a guard of `c` is rejected) and not of another
  binding (`other`).
* Bindings are immutable, so the fact cannot be invalidated by a change of
  the value; a new value is a new binding, with its own facts.
* A guard is also a failure point (it fails where its argument is no
  symbol it takes): a handler of the guard starts in the states before it.

**The successful-completion guarantee with a guard is exactly the one
section 2 states**: `digit_checked` fails or completes having emitted a
digit, for every Int -- not "every Int is a digit".

**A guard or a domain?** emitlib has both: `digit_checked(d: int)` checks
at run time; `digit_of(d: DigitValue)` moves the check to every caller,
which must prove the value statically. The second costs nothing at run time
and nothing in the claim; it costs the callers a proof (`digit_of_source`
narrows its `int` with a branch before calling). The first is the right
form for data no caller can prove (a parsed text, `to_string`'s digits).

**Performance** (cranelift, fused, ns per emitted symbol; `results/
bench.md`; the formatting algorithm is separated from the verification by
comparing variants of the same emitter):

| workload | what | symbols | ns/symbol |
|---|---|---:|---:|
| `digits_domain` | digit_of: proved from the declared domain, no check | 20000 | 11.0 |
| `digits_guarded` | digit_checked: a guard per symbol | 20000 | 16.6 |
| `digits_unchecked` | digit_unchecked: no check, no certificate | 20000 | 10.4 |
| `digits_validated` | digit_unchecked fed to the recognizer as emitted | 20000 | 15.8 |
| `strings_static` | json_string: proved, no check | 52500 | 24.0 |
| `strings_validated` | json_string fed to json_string_strict as emitted | 52500 | 31.9 |

A certified emitter is its unchecked code: `digits_domain` (proved from
its declared domain) and `digits_unchecked` (no certificate) run the same,
about 11 ns per symbol. A check per symbol costs about 50% more for a
one-symbol token, wherever it is written: the guard in the emitter (16.6)
or the recognizer fed in the consumer (design A, 15.8). (Of two runs, the
other variants agreed within 7%; the guard's first measured 36.8.) For
strings, proved 24.0, validated as emitted 31.9 ns per symbol (the
exploration measured 24.7 and 29.3). And the slowest emitter of the
exploration, the arithmetic integer (4.4x `to_string`), is slow because
Botlish has no integer division, not because of its proof. Nothing in a
proof pressures an author toward a slower algorithm when a guard per
symbol, or a domain, says what the algorithm cannot.

## 10. Value facts

### The census of facts

Every fact the exploratory checker used, where the modular checker gets
it, and what it depends on:

| fact | exploratory source | modular source | caller-dependent? | valid for the declared domain? | invalidated by | tested by | consequence of a bug |
|---|---|---|---|---|---|---|---|
| exact constants | hir::exact::IntOf | the const node; hir::exact::BindingIntOf for module bindings | no | yes | a source change (the fingerprint) | every test | a wrong symbol certified |
| an expression's interval | hir::range::of, the union over the program's used instances | intset's lifting of hir::range's transfers from the declared parameter facts | **exploratory: yes** (instance facts are seeded by calls) | modular: yes | a callee's code, a declared type | `ep-declared-domain`, `ep-unused`, census | false certificate for unseen inputs |
| a parameter's values | hir::range seeding + the summary's caller-passed sets | declared type (claim root); the caller's in-proof facts (helpers) | **exploratory: yes** at the root | yes | a declared type change | `ep-domain-parameter`, mutant `declared-narrowed` | as above |
| branch narrowing by order | own `PairSet` | hir::range::Narrowed, per component | no | yes | -- | `ep-order-narrowing`, mutants `negation-strict`, `narrow-order-ignored` | a branch's symbol confined too much |
| `==` true | own `PairSet` | hir::range's point-equality rule (narrow to the point) | no | yes | -- | `ep-negation-holes` | as above |
| **`!=` (`==` false): a hole** | own `PairSet` | **intset::Narrow: the one rule not in hir::range** | no | yes | -- | `ep-negation-holes`, `ep-hole-edge`, mutants `minus-extra-point`, `negation-equality` | an excluded character certified (an unescaped `"`) |
| `+ - *` of sets | own `Arith` (+, - with a constant) | hir::range::add, sub, mul per component pair | no | yes | -- | `ep-arithmetic`, `ep-lift-components`, mutants `sub-as-add`, `lift-first-component` | an out-of-class symbol certified |
| `shift_right`, `mod` | own `Arith` (exact mod for a non-wrapping interval) | hir::range::BitOp, hir::range::Mod | no | yes | -- | `ep-arithmetic` | as above |
| a native's registered range | hir::range::RegisteredRange | the same (metadata: `-result-range`) | no | yes (a registration is a promise of the implementation) | the registration (recorded in the certificate) | `ep-trusted-scalar` | as above |
| a native's result *set* (scalar_value: no surrogate) | own table | the same, the trusted table, with its origin | no | yes, if the runtime upholds it | the table (recorded) | `ep-trusted-scalar`, `ep-surrogate-codes`, mutant `trusted-scalar-narrow` | a surrogate certified as a strict-JSON character |
| a binding's value | own recursion through `declaredBy` | the walk's environment (the value the bind computed on this path) | no | yes | -- | every test | -- |
| guard facts | own | recognizer completion set from dfasem (the lowering's table) | no | yes | the recognizer (deep fingerprint) | `ep-guard-facts`, mutants `handler-keeps-guard`, `guard-any-binding` | an unchecked symbol certified |
| induction values | hir::range per instance + own peel | hir::range::InductionBinding; own peel and unrolling | exploratory: through the bounds' facts | yes | -- | `ep-loop-*`, mutants `peel-later-is-first`, `unroll-short` | a later iteration's symbol unchecked |
| integer domain types | hir::typeOf (compared with `int`) | hir::range::TypeFact | no | yes, given admission at every call (section 4) | the declaration | `ep-domain-parameter` | -- |
| may yield | hir::coroutines::MayYield | the same | no | yes | -- | -- | a helper's yields ignored |
| may fail | -- (every visited state) | native error metadata, declared errors | no | yes | the registration | `ep-native-may-fail`, mutants `natives-never-fail`, `fail-not-a-failure-point` | a handler's symbols checked in the wrong states |

### One authority for the rules

`intset.tcl` is the *disjunctive completion* of hir::range's interval
lattice -- a value is a finite union of intervals -- not a second fact
system: every transfer is hir::range's own procedure applied to each
component (or pair of components) and the results united (`Lift1`,
`Lift2`), every comparison's narrowing is `hir::range::Narrowed`, every
type's facts `hir::range::TypeFact`, every counted loop's interval
`hir::range::InductionBinding`, every native's range
`hir::range::RegisteredRange`, every condition's paths `hir::range::Paths`.
The meaning of `+`, `mod`, `shift_right`, a comparison or a domain is
stated once, in hir/range.tcl, and audited there. The exploratory
checker's own arithmetic, comparison and binding-chain rules are gone.

What the derived domain adds is exactly one rule: `x != K` removes the
point K from the middle of a component, where hir::range can only filter an
exact set (`PointEqualityNarrow`). JSON's escaping needs it: `c == 34 or
c == 92` false must leave `0..33 35..91 93..`, and the scalar values'
surrogate gap is the same kind of set. The recommendation is to move it
into hir::range as interval-set Ranges (section 19) -- where it would also
serve dead-branch elimination -- rather than keep it here.

What the consolidation costs is precision where the exploratory checker's
private rules were stronger than hir::range's: `hir::range::Mod` bounds any
operand by the divisor (`[0, d-1]`), even an exact point or a
non-wrapping interval, where the exploration computed `[lo mod d, hi mod d]`.
emitlib's `unicode_escape` writes its first nibble as `v.shift_right(12)`
(a `CodeUnit` is below 2^16) rather than `.mod(16)`, which would read as
"possibly `d`" and start a surrogate escape in the strict grammar; and
all six of the fuzzer's precision losses involve `mod` (section 14). This is a known gap of hir::range, independent of emission;
it is recorded here, not patched in a second fact system.

### Arbitrary precision and bounds

IntSet bounds are true infinities and Tcl bignums: no value is ever
compared with a sentinel. The recognizer tables' bounds are finite
(-1..0x10FFFF); a value outside every row's segments takes the row's
default code -- what `dfa#transition` does with it (core/dfa.tcl clamps
any key past the table to a key no interval holds). The exploratory
checker intersected values with surface/dfa.tcl's sentinel range
`±10^21`, so 10^23 intersected to nothing, the yield's state set became
empty, and everything after it was unreachable: certified (census
`sentinel-overflow`). Arithmetic is hir::range's, which never assumes a
machine word; shifts of a possibly negative value are unknown
(`BitOp`); `mod` is Euclidean; negation is `0 - n`.

### Trusted facts

One: `std::char::scalar_value`'s result is a Unicode scalar value (never
0xD800..0xDFFF), stated in `modcheck::trusted` with its origin
(core/value.tcl's UnicodeChar invariant, native/src/runtime/value.rs's
surrogate exclusion) and its justification (every String operation makes
UnicodeChars only through those constructors). The registered
`-result-range {interval 0 0x10FFFF}` is the interval; the gap is the
trusted part. A certificate records every trusted fact and every
registered range its proof read, and is invalid when either changes. No
other native result is trusted, and nothing is inferred from observed
results: `std::int::to_string`'s text is canonical decimal by its
implementation (NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md), but no metadata says
so, and `integer_trusted` stays uncertifiable without guards.

### Consequences of an analysis bug

Until emission claims, a wrong Range miscompiled a representation or
eliminated a branch; with them a wrong Range, a wrong narrowing or a wrong
trusted fact certifies output that is not in the language -- an unescaped
quotation mark in a JSON string, an encoded surrogate in strict JSON, a
digit that is a letter. Every transfer the checker reads from hir::range
becomes a security-relevant rule. Before certificates are public, the
hir::range transfers the check reads (`add`, `sub`, `mul`, `Mod`, `BitOp`,
`Narrowed`, `InductionBinding`, `TypeFact`, `RegisteredRange`, `Paths`)
need their own mutation audit read as a soundness audit (section 19).

## 11. DFA semantics

### What the checker reads

The exploratory checker read surface/dfa.tcl's *effective table* (the
analysis) and stated the run semantics itself in `Step` and `Pop`. The
modular checker reads **surface::dfa::Codes** -- the table the lowering
compiles into each recognizer's single `dfa#transition` call (per state
number a row `{DEFAULT SEGS}`) and the *leaves* its codes stand for
(`taken`, `returnc`, `more K`, `call KEY THEN`, `reject R S`) -- and
partitions a symbol set exactly as the compiled dispatch does, the default
code for every value outside the row's segments included. Recognizer
fingerprints are digests of the same table and leaves: what runs, not what
was written.

### What it states

`dfasem::LeafMeaning` and `dfasem::Complete` (about 80 lines, each case
next to the comment naming the arm of `surface::dfa::Lower` that compiles
it) are the one place the prototype states run semantics:

| code | meaning | `Lower`'s arm |
|---|---|---|
| a state number | consume, continue there | `target = next` |
| `taken` | complete, nothing unread | `return -2` |
| `returnc` | complete, the current symbol (or the end) unread | `return c` |
| `more K` | complete, K unread | `return -2-K` |
| `call KEY THEN` | run KEY from its start on the symbol; on its result: `then accept` returns it; -2 continues in THEN waiting; c or -1 runs THEN on it (reconsiders); -2-K runs THEN on a key no row holds (its default: a rejection; DFA-CALL-LOOKAHEAD forbids it) | the call arm |
| `reject R S` | fail | the chain's tail |

and the outermost completion maps -2 and -1 to 0 unread, c ≥ 0 to 1,
-2-K to K (the recognizer function). Every case treats the end and a
symbol separately; the exploratory `Pop` decided "at the end" by comparing
the whole symbol set with `{-1}`, so a set mixing the end and symbols
would have been reconsidered as a symbol (it never happened, because Emit
removed the end first -- a fragility, not a defect).

**Bounded lookahead.** `accept before N` completing the outermost
recognizer on an emitted symbol, or at the end with N > 0, is
EMIT-BEYOND-TOKEN with its N: the token is shorter than the trace. It is
never read as `accept before 1`: `ep-dfa-lookahead-two` (a recognizer that
ends its token two symbols back: `abc` beyond, `ab` proven) and the
mutant `more-as-one`, killed by the conformance test, which compares
unread counts.

### Evidence that the two agree

`tools/conformance.tcl` (`results/conformance.md`) runs every case
`dfatest::cases` generates for a recognizer -- every interesting symbol,
the breadth-first frontier of its configurations followed by every
symbol and by the end, random walks -- through dfasem one symbol at a time
and compares its outcome (accepted with the same token length and unread
count; rejected by the same recognizer, in the same state, at the same
index; still waiting) with tests/dfa-support.tcl's reference interpreter,
which reads the declarations themselves. 18 recognizers -- json_lex's
eleven, json_grammar's four, and three written for the cases JSON lacks
(`accept before 2`, a call `then accept` passing two unread symbols on, a
call `then STATE` whose callee leaves its symbol for the caller to
reconsider) -- **7,201 cases, 0 mismatches**. tests/dfa.test holds the
compiled recognizers to the same reference, so the checker, the reference
and the generated code agree on every case either suite generates.

### One statement for production

What remains duplicated is the *interpretation* of the leaves: `Lower`
generates code for each arm; dfasem interprets each abstractly. Both read
the same Codes; neither restates a transition. A production version should
state the outcome once, as data both consume:

```
surface::dfa::Outcome LEAF            -> {consume STATE} | {complete taken|current|{more K}}
                                         | {call KEY THEN} | {reject R S}
surface::dfa::Resume THEN CLASS       -> {wait THEN} | {reconsider THEN} | propagate | reject
surface::dfa::Unread CLASS AT-END     -> 0 | 1 | K
```

`Lower` would generate each arm from `Outcome`/`Resume` (the generated code
unchanged: its shape is already a function of exactly these cases), and the
check would step from them. The duplication then shrinks to the two
*representations* of one rule -- generated code and abstract steps over
sets -- which is inherent (one executes a symbol, the other a set), and the
conformance check stays as the guard between them. This was not done in
the milestone: it changes surface/dfa.tcl, whose generated HIR every
recognizer test pins, for no gain until the check itself is in the
compiler.

## 12. Boundary composition

**The obligation** (section 2): a call of a helper H claimed for K, whose
exit leaves a frame of K that H entered still open, obliges the next
symbol to end that frame. `modcheck::Obligate` attaches `{DEPTH K H CALL}`
to the exit state; `dfasem::Step` checks it on the next symbol: the step
reports the shallowest frame depth still open while the symbol was
processed, and the obligation holds when its frame completed during the
step -- the symbol was then reconsidered by an outer frame, or ended the
token -- and is violated (EMIT-BOUNDARY) when the frame took the symbol.
A frame completed and re-entered in the same step (a new token of K right
after the old) discharges it; the exploratory checker compared frame keys
after the step and would have reported that as a violation.

A frame of K already open when H is called is the caller's own token (a
`json_text` frame around a recursive `value`); the caller's claim governs
it, and H's call adds no obligation.

**Test cases** (`ep-boundary-adjacent`, `ep-boundary-branch`,
`ep-dfa-accept-before`, `ep-dfa-continuations`, `ep-boundary-nested`,
`ep-fail-before-yield`, census `adjacent-numbers`, `caught-after-prefix`,
the exploratory census's `missing-separator`):

| composition | verdict |
|---|---|
| `[` integer integer `]` | EMIT-BOUNDARY (and REJECTED: `0` then a digit); disproven by `(0, 0)` |
| `[` integer `,` integer `]` | proven |
| a number then whitespace, then a number (json_text) | proven |
| a number then a string (`1"x"`): the string's quote ends the number in json_text | rejected by json_number, which takes no `"` (lexically invalid, not merely unseparated) |
| a string, then punctuation | proven: a string completes on its own quote, no obligation |
| a literal, then an invalid continuation (`nullx`) | rejected in json_literal's `word_end` |
| a helper that fails after a valid prefix, its caller catching and emitting | checked from the failure states: `caught-after-prefix` disproven (`null` + `l`), `caught-before-yield` proven |
| a number in one branch, nothing in the other, then a digit | EMIT-BOUNDARY from the branch that wrote the number only (`[5` from the other is valid); composed by `integer`'s certificate, also EMIT-REJECTED -- the certificate may end in `zero`, which the branch's `a > 0` excludes but the certificate cannot know; composed by body, the boundary alone |
| a member (string `:` number) then a digit, composed by member's certificate | EMIT-BOUNDARY on the number *inside* member's token |

**What a reusable certificate must expose.** A Boolean "valid token" is
not enough, for three reasons the cases show: a caller needs (1) where the
helper may end -- the certificate's **exit states** in K's automaton, which
determine where the caller's automaton continues (a number ends in
`zero`, `integer`, ... and may be continued by `.`; a string ends
complete); (2) where it may be between symbols and where it may fail --
**visits** and **fails**, which bound the product exploration and the
caller's handlers; and (3) which tokens inside it are still waiting for
the symbol that ends them -- the **open obligations at each exit**. The
last is what certificate composition would otherwise lose: `member`'s
certificate is for json_text, whose outermost frame never ends before the
end of the input, so its own boundary summary says nothing; the open
json_number frame inside it is what a following digit would corrupt.
`dfasem::Reattach` moves each obligation of an exit to the innermost frame
of the same recognizer in the caller's state -- and drops it when the
caller's parse has no such frame (its grammar does not read that output as
a token). The certificate also records a compact **follow set** (the
symbols every exit ends the token before, or "completes on its own last
symbol"): `integer` -- the end, or whitespace, `,`, `]`, `}`; json_string --
self-delimited; json_text -- the end only. It is a summary for readers and
diagnostics; the check itself uses the exits and their obligations.

**Composition by certificate.** `dfasem::LangApply` explores the product of
K's automaton -- restricted to the certificate's visits and exits -- with
the caller's: the caller's exit states (where K's state is a certificate
exit), visits, failure states (where K's state is a certificate failure
state), and every symbol of a K-token path the caller's state rejects
(reported at the call, as "a token of K that H may emit"). It reads only
the certificate, so a change to H's code that keeps its statement keeps its
callers' proofs. When H has several certificates (string_ascii is certified
for both json_string and json_string_strict), its trace is in the
intersection of their languages: exits, visits and failure states are
intersected, and a symbol is reported only if every certificate admits it.
`ep-compose-weaker-certificate`: a helper certified only for the permissive
string grammar, composed into a strict claim, is rejected (its tokens may
hold a lone surrogate escape), exactly as body composition rejects it.

**Body composition** (`-compose body`) analyzes the helper's body in the
caller's states, with the caller's argument facts: more precise when a
helper's language admits tokens its body never produces in that context
(`ep-boundary-branch`: a positive integer never ends in `zero`), and
dependent on the body. On the 22 claims of check_all.bot
(`ep-compose-modes`) and on the library's, from compose.bot and from
unused.bot, both modes give the same verdicts.

**Lexical versus structural.** json_text is the lexical stream: tokens and
boundaries. Separators, colons and bracket matching are structure, not a
regular language, and remain the integrated validator's and CPython's
business (the exploratory census's `missing-colon` and `unbalanced` are
accepted by both checkers, as their guarantee says). No delimiter is ever
inserted: the emitter chooses its output; the compiler verifies the
choices.

## 13. Proof artifacts

A certificate (`modcheck::Certificate`) holds:

| field | content |
|---|---|
| function | the function's identity (its qualified name) |
| recognizer | the claimed recognizer |
| domain | the declared parameter types the proof assumed |
| exits, visits, fails | the claim's composite states, with the exits' open obligations |
| follow | the boundary summary |
| result | the function's result values (a symbol source's must be -1) |
| depends | the checker's identity (a digest of its own sources, and the front end's fingerprint -- hir::interchange's, which covers the hir::range transfers the proof read); every function whose body the proof analyzed, with its fingerprint; every certificate it composed with, by statement digest; every recognizer it read, with its deep fingerprint (the recognizer and every recognizer it calls); every trusted native fact and registered range it read |
| digest, statement | the digest of the whole; the digest of what it *states* (function, recognizer fingerprint, domain, exits, visits, fails, result, follow) |

**Fingerprints.** A function's fingerprint is a digest of a canonical text
of its HIR (`modcheck::Canon`): node kinds, constants, natives, declared
types, the names of the functions it calls, module bindings with their
exact values, local bindings numbered by first occurrence -- never an
expression, binding, scope or type id, an origin or a comment. It is the
same in every compilation of the same code, whatever else the program
holds (`ep-fingerprint`: a comment and an unrelated function change
nothing; a constant changes it). A recognizer's fingerprint is a digest of
its compiled table and leaves.

**Validation.** A stored certificate is valid when every dependency still
holds: each function's fingerprint, each recognizer's deep fingerprint,
each trusted and registered fact, the checker's identity, and each
composed-with certificate's statement (recursively valid). The claims are
checked callees first, so a callee re-proved in this run is compared by its
new statement. Validating costs fingerprinting the functions the proof
read -- one canonical walk each -- far less than the proof (section 16).

**What a cached success flag would miss.** "This function was proved" is
not reusable: its validity depends on the helper bodies it analyzed, the
recognizers and trusted facts it read, and the checker. And a caller needs
more than the flag to compose: the exits, visits, fails and obligations of
section 12.

**Interaction with the front-end cache.** `surface::cache::Key` holds the
program's front-end inputs; a cache hit is a HIR equal to the build's
(HIR-INTERCHANGE.md). Certificates sit above it: they depend on
*functions'* code (a narrower unit than a program file), on the recognizer
tables (front-end output), on native metadata (front-end input) and on the
checker (not a front-end input). The prototype makes the whole front
end's fingerprint part of the checker's identity, so any change to
`core/`, `hir/` or `surface/` invalidates every certificate --
conservative, since the proof reads hir::range's transfers, the coroutine
analysis and the types. A permanent version would key the analyses a
proof reads more narrowly, beside the function fingerprints above, which
survive unrelated changes and catch every relevant one; the checker's
identity stays part of the key (a checker change is a proof change), and
the trusted-fact table is versioned with native metadata.

**Permanent reuse needs** an interface artifact: a module's certificates
written with its interchange text (section 18), read by a compilation
that does not re-read the module's source. Today every compilation reads
every module's source, so the store demonstrates the semantic boundary
only. No signing or distribution was built: a certificate is a statement
the compiler re-validates, not a credential.

## 14. Correctness evidence

### The modular census

`census/cases.txt`, `tools/census.tcl` (`results/census.md`): 21 programs,
23 claims, written to expose unsound or caller-dependent reasoning, each
checked by the modular checker, by the same engine with observed facts,
and by the exploratory checker, and each claim's **concrete truth**
searched for by running it (`tools/concrete.tcl`: the function called for
a bounded set of candidate arguments -- the Int constants of its code and
its callees and their neighbors, characteristic texts and lists -- inside a
coroutine root that catches its declared errors, on the Tcl compiler; each
complete run must be one token, each failed one a viable prefix, by the
reference interpreter). A proven claim with a counterexample would be a
false proof and fail the census; there is none.

| case | claim | modular | observed facts | exploratory | concrete truth | finding |
|---|---|---|---|---|---|---|
| `caller-only-safe-digit` | `digit` | disproven | proven | proved | false for (0) | exploratory false proof: caller facts |
| `caller-only-safe-arith` | `hexchar` | disproven | proven | proved | false for (-1) | exploratory false proof: caller facts |
| `unused-correct` | `digit_of_nibble` | proven | not-proved | unused | no counterexample found | exploratory had no facts |
| `unused-wrong` | `digit_wrong` | disproven | not-proved | unused | false for (10) | exploratory had no facts |
| `unrelated-helper-caller` | `emit_digit` | proven | proven | proved | no counterexample found | agree |
| `domain-parameter` | `digit_value` | proven | not-proved | unused | no counterexample found | exploratory had no facts |
| `fail-after-yield-handled` | `s` | disproven | not-proved | proved | false for (1) | exploratory false proof: unsound rule |
| `sentinel-overflow` | `big` | disproven | not-proved | proved | false for () | exploratory false proof: unsound rule |
| `guard-handler-continues` | `g` | disproven | proven | proved | false for (0) | exploratory false proof: caller facts |
| `guard-other-binding` | `g2` | disproven | proven | proved | false for (48, -2) | exploratory false proof: caller facts |
| `guard-derived-value` | `g3` | disproven | proven | proved | false for (57) | exploratory false proof: caller facts |
| `separate-coroutine-ignored` | `outer` | proven | proven | proved | no counterexample found | agree |
| `forwarded-values` | `forward` | not-proved | not-proved | rejected | no counterexample found | agree |
| `zero-iterations` | `digits` | disproven | proven | rejected | false for (0) | agree |
| `recursion-may-be-empty` | `ones` | disproven | not-proved | rejected | false for (0) | agree |
| `recursion-may-be-empty` | `ones1` | proven | proven | proved | no counterexample found | agree |
| `never-returns` | `forever` | proven | proven | proved | no counterexample found | agree |
| `adjacent-numbers` | `pair` | disproven | not-proved | rejected | false for (0, 0) | agree |
| `lookahead-two` | `abc` | disproven | not-proved | rejected | false for () | agree |
| `lookahead-two` | `ab_only` | proven | proven | proved | no counterexample found | agree |
| `caught-before-yield` | `safe` | proven | proven | proved | no counterexample found | agree |
| `caught-after-prefix` | `twice` | disproven | not-proved | proved | false for (1) | exploratory false proof: unsound rule |
| `end-yield-negative` | `m` | disproven | proven | proved | false for (0) | exploratory false proof: caller facts |

| finding | claims |
|---|---:|
| exploratory false proof: caller facts | 6 |
| exploratory had no facts | 3 |
| agree | 11 |
| exploratory false proof: unsound rule | 3 |

The exploratory checker's false proofs are classified by the observed
model: when the same engine with the program's own call facts also proves
the claim, the proof came from the callers; when it does not, from a rule
of the exploratory checker's own:

* *caller facts* (6): `digit` called with 48; `hexchar` called with 0..15
  through a loop and a coroutine; three guard cases whose callers pass a
  digit (so the guard was never exercised); `m` called with 1.
* *unsound rules* (3): `sentinel-overflow` (10^23 dropped at the
  sentinel), `fail-after-yield-handled` and `caught-after-prefix`
  (handlers entered from the states before the failing helper's last
  symbol), each with callers that pass the value that breaks it -- so no
  caller fact excuses the proof.

### The exploratory census under the modular checker

The exploratory milestone's 31 mutations of the JSON emitters, applied one
at a time, `check_all.bot` checked by the modular checker: **31 of 31
decided as the exploratory checker decided** -- its 24 rejected cases
rejected, its 7 accepted cases (a wrong value, two of a document's structure, a
non-terminating emitter, and the three whose failure is a run-time check or
an error) accepted. Every rejected case has a counterexample-backed `disproven` for
the directly mutated emitter where the bug is reachable with the
candidates (`plus-sign` by 1, `leading-zero` by -1, `raw-controls` by
`"\n"`, `surrogate-scalar` by `[55296]`, ...), and `not proved` where it is
latent (`leading-digit-latent`, `digit-overflow`, `weak-guard`,
`unguarded-text`) or a precision limit (`utf8-by-length`,
`strict-escape-unsplit`, `flat-serializer`).

### Generated emitters against exhaustive execution

`tools/fuzz.tcl` (`results/fuzz.md`) generates, per seed, a module of
emitting functions over one Int parameter -- sequences, branches on
comparisons with `and`/`or`/`not`, counted and unbounded loops with
separators and breaks, early returns, helpers that emit one symbol,
recursive helpers, helpers that fail before (or, a planted fault, after)
their symbol with handlers that emit instead, guards with failing or
absorbing handlers -- each claiming one of four small recognizers (one
symbol; a pair with an optional second; a word ending before its follower;
a bracketed list of words: a call, `then STATE`, `accept before`). Faults
are planted at the construct level (an off-by-one bound, a missing `else`,
a `mod` one too wide, a loop run zero or two times, a return before the
symbol, a failure after it, a guard's value yielded unconfined), most of
them wrong only for a few values. The checker decides each claim from
`x: int`; then every function runs for **every x of -6..120 and three huge
values** on the Tcl compiler, and the reference interpreter judges every
run. The generator's constants all lie inside the window and its `mod`s
are by 2..4, so every condition and every symbol is piecewise constant or
periodic outside it: the window is exhaustive for these programs.

| generated claims (40 seeds of 8 functions) | 320 |
|---|---:|
| proven | 221 |
| disproven (the checker's own counterexample; an invalid run in the window agrees) | 93 |
| not proved | 6 |
| **false proofs** (proven, an invalid run) | **0** |
| disproven with no invalid run in the window | 0 |
| precision losses (not proved, every run valid) | 6 |
| runs judged by the reference interpreter | 41,600 |
| the exploratory checker on the same functions: proved / of them false | 60 / 1 |

No proven claim has an invalid run; every counterexample the checker found
is matched by the exhaustive runs; the six claims not proved are all
correct, and all six involve `mod`: five a `mod` of an exact operand
(`97 + n.mod(3)` with `n = 0` reads as `'a'..'c'`: hir::range's transfer,
section 10), one a relation through it (a helper fails when `n mod 3 = 1`,
before the symbol `92 + n` that would be invalid for `n = 7` -- and
7 mod 3 = 1). The exploratory checker, given the same functions through a
driver whose arguments it cannot see, proved 60 claims, one of them false
(seed 11, `f9`: a helper that yields and then may fail, caught by a
handler that yields again -- the handler rule of section 7, found by the
generator independently of the census).

### Other evidence

* The conformance of section 11 (7,201 cases, 0 mismatches).
* The library's five callers run on the Tcl compiler and cranelift with the
  same values; `full.bot` drives both digit emitters over -20..20.
* 55 tests (`tests/emission-proofs.test`), each rule with its counter-case.

## 15. Mutation evidence

`tools/mutants.txt` holds 34 mutants, one per proof rule the milestone
introduced or changed, each a way a certificate could be false; `tools/
mutate.tcl` applies each to a private copy of the tools and runs the tests
named for it, then the whole test file when they all pass (a control run
of the unmutated copy must pass first). `results/mutants.md`:

**34 of 34 killed**, each by the tests named for it (none needed the whole
file):

| mutant | rule | result |
|---|---|---|
| `declared-narrowed` | parameter-domain initialization: an Int parameter enters as 0..9, not every Int | killed (match, 4 s): ep-declared-domain, ep-hole-edge, ep-unused |
| `caller-facts-leak` | call-site fact leakage: every claim entered with what the program's calls pass (the exploratory model) | killed (match, 2 s): ep-declared-domain, ep-unused |
| `negation-strict` | branch negation: `x < K` false read as `x > K` (K itself dropped) | killed (match, 14 s): ep-loop-later-iterations, ep-order-narrowing, ep-recursion-second-round |
| `negation-equality` | branch negation: `x == K` false read as true | killed (match, 3 s): ep-hole-edge, ep-lift-components |
| `minus-extra-point` | interval subtraction removes the point below the hole too | killed (match, 3 s): ep-hole-edge |
| `inter-wide` | interval intersection keeps the larger upper bound | killed (match, 8 s): ep-arithmetic, ep-dfa-accept-before, ep-dfa-after, ep-dfa-beyond, ep-dfa-continuations, ep-dfa-incomplete, ep-dfa-lookahead-two, ep-negation-holes, ep-order-narrowing |
| `sub-as-add` | arithmetic transfer: `-` computed as hir::range::add | killed (match, 3 s): ep-arithmetic, ep-context-sensitive |
| `lift-first-component` | a two-operand transfer reads only the first component of its left operand | killed (match, 2 s): ep-lift-components |
| `narrow-order-ignored` | an order comparison narrows to the other side's hull bound, off by one | killed (match, 2 s): ep-hole-edge, ep-order-narrowing |
| `handler-keeps-guard` | guard failure facts: a handler starts with the facts of the call's success | killed (match, 2 s): ep-guard-facts |
| `guard-any-binding` | guard success facts: the guard's set given to its argument even when the argument is no binding's reference (the next yield's binding) | killed (match, 1 s): ep-guard-facts |
| `fail-not-a-failure-point` | error-handler propagation: a `fail` records no failure state | killed (match, 4 s): ep-exploratory-false-proofs, ep-fail-after-yield |
| `natives-never-fail` | error-handler propagation: no native call may fail | killed (match, 1 s): ep-native-may-fail |
| `handlers-unreached` | error-handler propagation: a handler starts nowhere | killed (match, 5 s): ep-exploratory-false-proofs, ep-fail-after-yield, ep-native-may-fail |
| `loop-one-round` | loop fixed points: the loop body analyzed for one round only | killed (match, 6 s): ep-loop-second-iteration |
| `peel-later-is-first` | loop fixed points: a counted loop's later iterations read as its first | killed (match, 7 s): ep-loop-first-iteration, ep-loop-later-iterations |
| `unroll-short` | an exactly counted loop unrolled one iteration short | killed (match, 6 s): ep-loop-exact-count |
| `join-first-state` | function-summary joins: a call's exits from its first entry state only | killed (match, 17 s): ep-join-states |
| `recursion-one-round` | recursive helper summaries: the solve stops after one round | killed (match, 9 s): ep-recursion-same-context |
| `summary-context-free` | function summaries keyed without their arguments | killed (match, 3 s): ep-arithmetic, ep-context-sensitive |
| `accept-before-taken` | DFA acceptance: the outermost token ending before a symbol read as ending on it | killed (match, 8 s): ep-conformance, ep-dfa-beyond |
| `reconsider-dropped` | delegation return: a callee's unread symbol dropped instead of reconsidered by `then STATE` | killed (match, 8 s): ep-conformance, ep-dfa-accept-before |
| `more-as-one` | `accept before N` read as `accept before 1` | killed (match, 3 s): ep-conformance |
| `end-not-checked` | EOF: a completion never checked against the end | killed (match, 10 s): ep-dfa-incomplete, ep-early-return, ep-loop-exact-count, ep-recursion |
| `boundary-same-depth` | token boundary: an obligation discharged when its frame takes the symbol | killed (match, 6 s): ep-boundary-adjacent, ep-boundary-nested |
| `boundary-never` | token boundary: a helper's exit never carries its obligation | killed (match, 6 s): ep-boundary-adjacent, ep-boundary-nested |
| `reattach-dropped` | token boundary: a certificate's open obligations dropped at its caller | killed (match, 3 s): ep-boundary-nested |
| `certificate-violations-dropped` | certificate composition: symbols of the helper's language the caller rejects not reported | killed (match, 2 s): ep-compose-weaker-certificate |
| `valid-ignores-functions` | cached certificate invalidation: a stored certificate valid whatever its functions' code | killed (match, 19 s): ep-store-invalidate |
| `valid-ignores-recognizers` | cached certificate invalidation: a stored certificate valid whatever its recognizers | killed (match, 20 s): ep-store-invalidate |
| `fingerprint-ignores-constants` | a function's fingerprint without its constants | killed (match, 24 s): ep-fingerprint, ep-store-invalidate |
| `statement-without-exits` | a certificate's statement digest without its exits | killed (match, 0 s): ep-statement-digest |
| `trusted-scalar-narrow` | a trusted native fact narrower than the implementation: a scalar value is never a control | killed (match, 1 s): ep-trusted-scalar |
| `coroutine-yields-counted` | coroutine boundaries: a value resumed from another coroutine read as a digit | killed (match, 2 s): ep-separate-coroutine |

The first run (`results/mutants-first-run.md`) killed 30: four mutants
survived because the tests did not exercise what they broke --
`lift-first-component` (a hole was only ever on the *right* operand of an
addition), `loop-one-round` (every loop test was decided within the peeled
first iteration), `join-first-state` (no helper was called from two states
of which only the second goes wrong), `recursion-one-round` (every recursive
test changed its argument context, so the first round unrolled it). Each
asked for one test (`ep-lift-components`' left operand,
`ep-loop-second-iteration`'s `dotted`, `ep-join-states`,
`ep-recursion-same-context`); none was a defect of the checker.

The families the milestone names, with their mutants: parameter-domain
initialization (`declared-narrowed`); call-site fact leakage
(`caller-facts-leak`: every claim entered with observed facts); branch
negation (`negation-strict`, `negation-equality`); interval union and
subtraction (`minus-extra-point`, `inter-wide`); arithmetic transfers
(`sub-as-add`, `lift-first-component`, `narrow-order-ignored`); guard
success and failure facts (`guard-any-binding`, `handler-keeps-guard`);
error-handler propagation (`fail-not-a-failure-point`,
`natives-never-fail`, `handlers-unreached`); loop fixed points
(`loop-one-round`, `peel-later-is-first`, `unroll-short`); function-summary
joins (`join-first-state`, `summary-context-free`); recursive summaries
(`recursion-one-round`); DFA acceptance (`accept-before-taken`,
`more-as-one`); delegation return (`reconsider-dropped`); EOF and
boundaries (`end-not-checked`, `boundary-same-depth`, `boundary-never`,
`reattach-dropped`); composition (`certificate-violations-dropped`);
certificate invalidation (`valid-ignores-functions`,
`valid-ignores-recognizers`, `fingerprint-ignores-constants`,
`statement-without-exits`); trusted facts (`trusted-scalar-narrow`);
coroutine boundaries (`coroutine-yields-counted`).

**The trust boundary.** Every component whose wrong behavior could
produce a false certificate, and what stands behind it:

| component | established by tests here | inherited language invariant | trusted assumption |
|---|---|---|---|
| DFA declaration checking (surface/dfa.tcl's analysis: determinism, defined rejection, bounded lookahead, acyclic calls) | -- | the DFA milestone's checks, tests and mistake census | a recognizer of the wrong language makes every emitter proved against it wrong the same way |
| DFA transition semantics (Codes, dfasem's leaves) | conformance (7,201 cases), `ep-dfa-*`, mutants `accept-before-taken`, `reconsider-dropped`, `more-as-one` | tests/dfa.test holds the compiled recognizers to the same reference | the reference interpreter is right (it is independent of both) |
| hir::range transfers and type facts | `ep-arithmetic`, `ep-order-narrowing`, the fuzzer | hir::range's own fuzzers and mutants (written as a representation analysis) | each transfer is sound for arbitrary-precision Ints |
| exact values (constants, module bindings) | every test | bindings are immutable | -- |
| path-condition narrowing (Paths, Narrowed, the hole rule) | `ep-negation-holes`, `ep-hole-edge`, mutants `negation-*`, `minus-extra-point` | -- | hir::range::Paths' decomposition of `and`/`or`/`not` |
| abstract arithmetic (the lifting) | `ep-lift-components`, mutants `lift-first-component`, `inter-wide`, `sub-as-add` | -- | -- |
| guard facts | `ep-guard-facts`, `ep-fail-before-yield`, mutants `handler-keeps-guard`, `guard-any-binding` | a recognizer function's normal completion means its first step completed (the lowering) | -- |
| function and recursion summaries | `ep-context-sensitive`, `ep-recursion*`, the fuzzer, mutants `summary-context-free`, `recursion-one-round`, `join-first-state` | -- | the fixpoint argument of section 6 |
| error edges (failure points, handlers) | `ep-fail-after-yield`, `ep-native-may-fail`, census, the fuzzer, mutants `fail-not-a-failure-point`, `natives-never-fail`, `handlers-unreached` | every error a function propagates is declared (UNHANDLED-ERROR); a native's errors are its registration's | a native fails only with the errors its metadata declares |
| yields and coroutine boundaries | `ep-separate-coroutine`, census `forwarded-values`, mutant `coroutine-yields-counted` | hir::coroutines::MayYield; a yielding function never becomes a value; a thunk is the coroutine boundary | trait operations are not followed (not proved) |
| native result contracts | `ep-trusted-scalar`, `ep-surrogate-codes`, mutant `trusted-scalar-narrow` | -result-range metadata is a guarantee of the implementation | the scalar-value gap (the trusted table) |
| integer-domain parameters | `ep-domain-parameter` | every call's argument is proved in the domain (hir::range's VerifyCall) | admission stays sound when callers are compiled separately (section 4) |
| proof caching and invalidation | `ep-store-*`, `ep-fingerprint`, `ep-statement-digest`, library C, mutants `valid-ignores-*`, `fingerprint-ignores-constants`, `statement-without-exits` | -- | the canonical text includes everything a function's meaning depends on beside its callees (a HIR field it does not know is still included, raw) |

**Surviving risks** -- what a killed mutant does not show:

* The mutants are of the checker's own rules. The hir::range transfers it
  reads, the HIR it walks (`reachable`, types, `MayYield`), the
  recognizer analysis behind Codes, and the language invariants (bindings
  immutable, a yielding function never a value) are trusted here and
  audited by their own suites; a bug there is a false certificate here.
* A mutation census measures the tests' power over the mutations someone
  thought of, not soundness. The fuzzer's exhaustive comparison is the
  independent check, and its generator covers Int parameters, small
  recognizers and the constructs listed; Strings, Lists and structs are
  covered by the census and the library only.
* The counterexample search is bounded: `not proved` never claims the
  emitter is correct, and `disproven` is shown only with a real run.

## 16. Performance

`tools/bench.tcl` (`results/bench.md`), on the 4-core container of the
other measurements in this report; the exploratory checker re-measured on
the same machine (it measured 3,239 ms for its walk in its own report, 1,590
here).

**check_all.bot's 22 claims** (ms, median of 3):

| checker | front end | check | summaries computed | summaries reused | solve rounds | of the check: composing, certifying (ms) |
|---|---:|---:|---:|---:|---:|---|
| exploratory: whole run | 7663 (front end, specialization and range analysis) | 1590 | - | - | - | - |
| modular, certificates, summaries shared | 7177 | 372 | 140 | 60 | 44 | 87, 32 |
| modular, bodies, summaries shared | 7098 | 279 | 148 | 54 | 44 | 0, 31 |
| modular, every claim from scratch (one run per function) | - | 1169 | 348 | 0 | - | - |

Per claim (the default run, in order; a claim's summaries include those an earlier claim made final):

| claim | ms | summaries reachable | computed | reused |
|---|---:|---:|---:|---:|
| `number_emit::integer` json_number | 23.4 | 5 | 10 | 0 |
| `number_emit::integer_text` json_number | 7.0 | 1 | 2 | 0 |
| `string_emit::string` json_string | 15.4 | 5 | 10 | 0 |
| `string_emit::string` json_string_strict | 14.6 | 5 | 10 | 0 |
| `string_emit::string_ascii` json_string | 27.8 | 13 | 20 | 10 |
| `string_emit::string_ascii` json_string_strict | 32.8 | 17 | 28 | 6 |
| `string_emit::string_bytes` json_string_bytes | 37.0 | 6 | 12 | 0 |
| `string_emit::string_codes` json_string | 10.6 | 5 | 2 | 4 |
| `string_emit::string_codes` json_string_strict | 9.7 | 5 | 2 | 4 |
| `value_emit::literal_null` json_literal | 1.9 | 1 | 2 | 0 |
| `value_emit::literal_true` json_literal | 1.7 | 1 | 2 | 0 |
| `value_emit::literal_false` json_literal | 1.8 | 1 | 2 | 0 |
| `number_emit::integer_source` json_number | 5.3 | 1 | 3 | 1 |
| `number_emit::integer_text_source` json_number | 2.7 | 1 | 2 | 2 |
| `string_emit::string_source` json_string | 9.0 | 1 | 4 | 2 |
| `string_emit::string_ascii_source` json_string_strict | 15.3 | 1 | 4 | 2 |
| `string_emit::string_bytes_source` json_string_bytes | 6.6 | 1 | 3 | 1 |
| `string_emit::string_codes_source` json_string | 0.8 | 1 | 2 | 4 |
| `value_emit::value` json_text | 50.9 | 2 | 10 | 12 |
| `value_emit::value_stacked` json_text | 55.1 | 3 | 4 | 10 |
| `value_emit::text_source` json_text | 49.7 | 1 | 3 | 1 |
| `value_emit::stacked_source` json_text | 41.8 | 1 | 3 | 1 |

**The library** from a program that calls none of it (ms):

| run | front end | check |
|---|---:|---:|
| no store | 3278 | 127 |
| store, first compilation (proves, writes) | 3073 | 149 |
| store, next compilation (validates, reuses) | 2923 | 20 (validation 6) |
| with the counterexample search (2 claims disproven) | 2883 | 7800 |

* **The walk is cheap once it is modular.** The exploratory checker
  walked every claim from scratch, each helper per entry state and per
  caller context (72 ms a claim here); the modular checker shares every
  summary a claim made final with every later claim and every program
  (17-19 ms a claim; 53 ms from scratch). Composing by certificates costs a
  quarter of its check (87 ms: the product explorations, cached per
  certificate statement and caller state) and is a little slower than
  composing by bodies here, where every helper's body is small -- the
  certificate's value is that it does not read the body, not speed.
  Fingerprinting and writing certificates: 32 ms for 22 claims.
* **It needs no whole-program analysis.** The exploratory checker could
  not start before hir::specialize and hir::range had analyzed the whole
  program (1,973 ms in its own report); the modular checker reads
  neither. What remains is the front end both share (and the recognizer
  models the prototype re-expands: a production check would read them
  from the HIR).
* **Parameter facts, recursion and loops cost little.** Declared facts are
  one TypeFact per parameter; the 22 claims' solves take 44 rounds in all
  (most claims converge in their first or second; the recursive
  serializer and the loops' fixpoints take the rest).
* **A store makes re-checking a validation.** An unchanged library is
  validated in 20 ms (6 of them validation); after a change to one
  helper, 59 ms re-proves its function and validates the rest (library
  C); an unused library emitter costs what any other does -- it is
  checked, not skipped.
* **The counterexample search is the expensive part**: it compiles and runs
  a program per rejected claim. It is a diagnostic aid, run only for claims
  that failed, and never part of a certificate.
* **No run-time cost** for a certified emitter (section 9): the claim is
  erased; a guard costs what the program asked for.

## 17. Precision limitations

Correct programs the analysis does not certify:

* **The exploration's three** -- `utf8-by-length`, `strict-escape-unsplit`,
  `flat-serializer` -- are still rejected, for the same reason: their
  correctness is a relation between two symbols (the second UTF-8 byte
  given the lead; the second hex digit given the first) or between the
  grammar position and data (the frame popped), and the facts are sets of
  single values. Modularity neither helps nor hurts them: their proofs
  never depended on callers. Accepting them would need a relational domain
  in hir::range; the grammar-shaped versions are as readable and proved.
* **`mod` of exact or non-wrapping operands** (section 10): `97 + n.mod(3)`
  with `n = 0` reads as `'a'..'c'`; hir::range's transfer is the reason,
  and the remedy belongs in hir::range.
* **Values received from another coroutine** are unknown Ints, even when
  that coroutine is certified (`forwarded-values`). Forwarding needs a
  guard, or interprocedural tracking of handles the checker does not do.
* **A coroutine construction's arguments** reach the thunk as captures,
  which carry no range into it: `emitlib::digit_of_source(d: int)` narrows
  its `int` itself before calling `digit_of`. The same limit is
  hir::range's (the domain check of the call inside the thunk fails
  without it).
* **Struct fields and List elements** are their declared types' facts: a
  field's value is not tracked from its construction (the JSON value
  serializers need nothing more).
* **A trait operation** in an emitter is not followed (EMIT-UNSUPPORTED).
* **Observed facts are not used at all.** An emitter correct only for the
  values its callers pass is not certified (`digit_unchecked`); that is
  the design, and its repairs are a guard or a domain.

## 18. Language implications

**A function-level claim belongs on the declaration.** It is a property of
the function's interface and implementation (section 3), it is checked
where the function is written, and its certificate is what callers, other
modules and later compilations use. The natural form is a clause beside
`errors` and `proves`:

```
fn json_string(text: str) -> unit errors IndexNotFound emits json_lex::json_string_strict:
```

resolved like any qualified name (the recognizer must be imported:
MISSING-IMPORT), several allowed (string_ascii emits both string grammars).

**No new type, no effect system.** The claim needs no function type
change: a function that may yield never becomes a value, so no `Fn{...}`
type ever carries an emission. No effect polymorphism, no trace contracts,
no dependent types: the parameter facts are the declared types, and
integer domains are the parameter refinements the proofs need. The
milestone found no case that needed a refinement beyond them: string
policies are branches, digits are domains or guards. Proposing declared
predicates on `str` parameters ("no control characters") would add
expressiveness the workload never asked for.

**What the claim must export** for composition: its recognizer, exits,
visits, failure states, open obligations and result -- the certificate's
statement (section 13). It belongs in the module's interface (the HIR's
side tables, and interchange text), not in the function's type.

**Diagnostics** are ordinary located entries with related locations (the
yield, the recognizer state's declaration, the claim), each with a
Compilerpedia topic and a census row (tests/static-compile.test), and with
three outcomes the language must keep distinct: proven; disproven, with a
concrete argument (only when a run shows it); not proved, with the missing
fact named. A compiler must never word a precision limit as "this emitter
produces invalid output".

## 19. Recommendation

**Integrate, after two prerequisites; keep invocation-level checks and
observed facts out of the language.**

The milestone established the property the exploration could not: a
certificate that holds for every caller, decided from the declaration,
reusable across programs, invalidated by exactly its dependencies, cheap
to check, and erased from the program. It also showed what a certificate
claim costs when it is wrong -- the exploratory checker's two unsound
rules (a sentinel bound, the states a handler starts in) were each a
plausible implementation choice, and certified three false claims of the
census and one of the fuzzer -- so integration should not move faster than
the soundness work:

1. **Value facts in hir::range, audited as security rules.** Interval-set
   Ranges (the `!=` hole), exact `mod` of exact and non-wrapping operands,
   and native result *sets* as registration metadata (`-result-range
   {intervals {0 0xD7FF} {0xE000 0x10FFFF}}` for `std::char::scalar_value`)
   instead of a trusted table beside the check -- each with hir::range's
   usual fuzzers and mutants, and a mutation audit of the transfers the
   check reads, read as a soundness audit.
2. **One statement of recognizer outcomes** in surface/dfa.tcl (section
   11), consumed by `Lower` and by the check, with the conformance check of
   this milestone as a test.

Then the `emits` clause (next section). Invocation-level checking is not
worth syntax: a caller that needs a call's guarantee states its own claim,
or wraps the call in a function with a domain. The observed model was a
measurement; it must never certify anything.

## 20. Next milestone

**Emission claims, milestone 1** -- the smallest production integration:

* the `emits R` clause (parser, HIR field on the block, `hir::format`,
  `hir::read`, interchange), resolved and checked for existence;
* `hir/emission.tcl`: the check of this milestone, after resolution and
  typing, on declared domains only -- the summaries, the walk, the
  failure points, the boundary obligations, certificate composition --
  reading hir::range's transfers (prerequisite 1) and surface/dfa.tcl's
  outcomes (prerequisite 2), with no whole-program analysis;
* its diagnostics (EMIT-REJECTED, -BEYOND-TOKEN, -AFTER-TOKEN,
  -INCOMPLETE, -END-SYMBOL, -NOT-SYMBOL, -UNKNOWN-VALUE, -BYTE-CHARACTER,
  -TERMINAL-VALUE, -BOUNDARY, -UNSUPPORTED, -BUDGET; a claim naming no
  recognizer is an ordinary resolution error) through the compiler's channels, with
  Compilerpedia topics, negative tests and the static-compile census;
* certificates as a HIR side table (the statement and dependencies of
  section 13), carried by interchange and the front-end cache; reuse across
  compilations keyed by function fingerprints;
* the counterexample search as a tool (not a compiler pass), for
  `-check`'s and the language server's explanation of a rejected claim;
* this milestone's census, fuzzer, conformance check and mutants moved
  with it, plus a mutation audit of the hir::range transfers;
* JSON's emitters and emitlib beside json_lex.bot in examples/dfa/json.

Out of scope still: structure (a visibly pushdown grammar declaration),
relational facts, handle tracking for forwarded coroutine values,
separately compiled interface artifacts.

## 21. Final decision questions

**1. Is emission certification fundamentally a function property?**
Yes. A function's complete outward yield trace was certified for all
permitted inputs, without callers, for the exploration's 22 claims, the
library's six correct ones, the census's eight and 221 generated ones;
every emitter that is wrong for some permitted input was rejected, with a
concrete counterexample wherever the bounded search reached it (93 of the
generated, every reachable census and library case). The correct
emitters left unproved (6 generated, the exploration's three, a forwarded
coroutine value) are limits of the value facts, not of modularity: none
needed a caller. Callers were never needed; where they were used, they
produced false certificates (6 in the census).

**2. Do the existing parameter types and guards provide sufficient
expressiveness?** Yes, for this workload. Integer domains are declared
parameter refinements that callers prove (`digit_of`), and guards declared
from existing recognizers state run-time-checked facts without restating
a grammar (`digit_checked`). No case needed a refinement on `str` or a
relational parameter fact; the experiment establishes no need for new
refinement machinery. One caveat is the domains' admission: it is checked
whole-program today (section 4), which separate compilation would have to
make modular.

**3. Can partial-emission helpers be summarized modularly?** Yes. A
helper is a state transformer keyed by its entry state and argument
facts; partial-token helpers need no claim; summaries are final after one
solve and shared by every claim and program (section 6). Helpers are not
re-analyzed per syntactically identical call site, only per distinct
context, and the cost is a fraction of the front end's (section 16).

**4. Can the compiler trust the necessary value facts?** Only after
hir::range's transfers are audited as security rules. The facts the check
needs are hir::range's transfers, one interval-set rule, one trusted native
fact, the coroutine analysis' MayYield and the HIR's types (section 10).
Before certification is public: the hole rule and exact `mod` in
hir::range, native result sets as metadata, and a mutation audit of the
transfers read as a soundness audit; and integer-domain admission at calls
must stay sound (it is the one place a callee trusts its callers).

**5. Can emission and recognition share one authoritative DFA
semantics?** Largely yes, already: the checker reads the lowering's own
table and leaves (the exploration read the effective table and restated
the run semantics in `Step` and `Pop`). What remains duplicated is the
meaning of the leaves -- about 80 lines beside `Lower`'s arms -- which a
production version states once in surface/dfa.tcl for both (section 11).
The two representations (generated code, abstract steps over sets) stay
two because one executes a symbol and the other a set; the conformance
check guards them.

**6. Does a function-level claim belong in Botlish's source language?**
Yes: `emits R` on the function declaration, beside `errors` and `proves`,
in the integration milestone of section 20, after its two prerequisites.
An invocation-level check, a library facility or a run-time validator would
each give a narrower guarantee: the invocation level a property of one call
that callers already express through their own claims; a library
validator a property of one run, at a cost per symbol, with a bug found
only by the input that triggers it. The declaration-level claim is the one
that holds because of the function's declared interface and implementation
-- which is the guarantee worth a language feature.

## A. Files

* `audit/emission-proofs/tools/modcheck.tcl` -- the checker;
  `intset.tcl` -- the value domain; `dfasem.tcl` -- the recognizer
  semantics; `concrete.tcl` -- concrete runs and the counterexample search;
  `conformance.tcl`; `workspace.tcl`;
* `audit/emission-proofs/lib/emitlib.bot` -- the library;
  `lib/emitbench.bot` -- the run-time workloads;
  `audit/emission-proofs/callers/` -- the five programs;
* `audit/emission-proofs/tools/library.tcl`, `census.tcl` with
  `census/cases.txt`, `fuzz.tcl`, `mutate.tcl` with `mutants.txt`,
  `bench.tcl`;
* `audit/emission-proofs/tests/emission-proofs.test` -- the tests
  (`tclsh9.0 audit/emission-proofs/tests/emission-proofs.test`; not part of
  tests/local.tcl or CI);
* `audit/emission-proofs/results/` -- `library.md`, `census.md`,
  `conformance.md`, `fuzz.md`, `mutants.md`, `bench.md`.
