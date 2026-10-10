# ERROR-IDENTITY-AND-COMPLETION-SOUNDNESS.md

Two narrow correctness repairs before `static compile` and the Botlish-native
golden test framework, on the payload-error milestone (ERROR-PAYLOADS.md) as
the semantic baseline:

1. **Completion analysis degrades conservatively.** Whenever effective
   completion analysis loses precision, the compiler conservatively retains
   the declared possible errors. It can never accept an unhandled error merely
   because a call passed through an untyped callable.
2. **Error identity is module-qualified.** A source-defined error's nominal
   identity is *(declaring module, declared error name)*, so two modules may
   expose the same short error name without collision or accidental handler
   interchangeability.

And together: even across specialization, generic helpers, untyped callable
parameters, propagation, handlers and payload transport, Botlish neither loses
a possible error identity nor confuses it with a same-named error owned by
another module.

Payload-bearing errors, handler semantics, affinity rules, error payload
transport and the native representation are unchanged; the one ownership
change is a bug fix of the same failure mode (point 1).

## Contents

* [Part A: completion precision](#part-a-completion-precision)
* [Part B: module-qualified error identity](#part-b-module-qualified-error-identity)
* [Part D: the census](#part-d-the-census)
* [Report](#report) -- the 36 points of the milestone report, in order
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## Part A: completion precision

The theorem (STATIC-COMPLETION-PROOFS.md, "Precision and the erased-callable
contract"):

> Effective completion analysis may narrow a declared error contract when it
> can prove a smaller set. If that analysis loses precision, it conservatively
> falls back to the declared contract; inability to prove an error impossible
> never means the error is absent.

A callable that declares errors reaches an untyped parameter through a
semantic instance -- the one erasure `hir/callables.tcl` accepts, because the
instance keeps the argument's exact type -- and from there an untyped call the
generic body cannot see through. The completion walker tracks a *callable
fact* per value and charges such a call by it: an exact callable is
*recovered* (analyzed as an exact call of it), a parameter or capture of the
body being checked is *clean* (charged where it was passed), anything else is
*unknown* and charged the program's *erased-callable contract* -- every
declared error of every callable the program passes into an untyped parameter
-- which makes the walk *incomplete*. An incomplete summary falls back to the
callee's declared contract at the function-instance boundary.

## Part B: module-qualified error identity

ERROR-PAYLOADS.md, "Module-qualified error identity":

> A source-defined error is nominally identified by its declaring module and
> declared name. Two modules may declare errors with the same short name; they
> remain distinct identities even when their payloads have identical
> structure.

Inside a module its own errors are named by their short names; outside, they
are qualified through the ordinary exact namespace imports. The entry
program's errors keep their bare names; the runtime's builtin errors stay root
identities.

## Part D: the census

### Error names before this milestone

Every site that held an error as a bare string, classified (after: the
canonical identity at every semantic site, the spelling only where it is
source text or a diagnostic's quotation of it):

| site | classification | after |
|---|---|---|
| `surface/parser.tcl` `fail`, `on`, `errors`, trait requirement `errors`, `Fn{errors: [...]}` | source spelling | `IDENT { "::" IDENT }` (`ErrorName`) |
| `surface/lower.tcl` `ErrorDeclOf`, `failNode`, `payloadOf`, handler names | source spelling (+ declaring namespace) | unchanged: the AST and syntax nodes keep spellings; HIR resolution makes identities |
| `surface/modules.tcl` `loadedErrors`, `QualifiedRefs` | per-module short names (already), qualified references | qualified error references authorized like every member |
| `hir/errordecls.tcl` `current`, `payloads` | **canonical semantic identity** (was the short name), **payload descriptor key** | canonical `NS::Name`; `resolve`, `shortName`, `namespaceOf` |
| `hir/resolve.tcl` `fail` name, `handlerNames`, `declaredErrors`, `payloadOf` | canonical semantic identity | resolved in the code's namespace |
| `hir/resolve.tcl` `ResolveTypeExpr` (`Fn`/`Coroutine` `errors`) | canonical semantic identity (contract) | resolved in the annotation's namespace |
| `hir/traits.tcl` requirement `errors` | canonical semantic identity (contract) | resolved in the trait's namespace |
| `hir/types.tcl` `calleeErrors`, `FnMismatch`'s error subset, `CoroutineErrors` | canonical identity, **contract subset key** | unchanged code, canonical data |
| `hir/completions.tcl` `ctx.errors`, `effectiveErrors`, `CheckCallLegality` | **completion-set key**; diagnostic display | unchanged code, canonical data; messages quote canonical names |
| `hir/affine.tcl` error edges, `hir/lower.tcl` `ReleasingOnError`, `compiler/compiler.tcl` release arms | canonical identity | unchanged code, canonical data |
| `hir/warnings.tcl` `FailSites`/`FailureGroups` | **warning key** | unchanged code, canonical data |
| `hir/format.tcl`, `hir/read.tcl` | HIR text | canonical names, round trip stable |
| `hir/lower.tcl` `(fail NAME ...)`, `(handle ... NAME BLOCK)` | **runtime transport** (Core IR) | canonical |
| `core/value.tcl` `errorId`, `core/evaluator.tcl` `op-handle`, `compiler/compiler.tcl` `CompileHandle` | **runtime transport**, dispatch | canonical (the compiler's `switch -exact` arms are the canonical names) |
| `core/coroutines.tcl` `failure` | **coroutine cache** | the cached `errorId` keeps the canonical name |
| `native/lower.tcl` `errorIds`, `ErrorId`, `faildeclared ID NAME`, `declarederroreq ID` | **native numeric-id map**; NAME for rendering | one id per canonical identity |
| `native/src/runtime` (`declared_error`, coroutine cache `(RtError, id, payload, shape)`) | numeric id; rendering string | unchanged |
| `core/native.tcl` `declareError`, `isBuiltinError` | builtin root identities | unchanged |
| diagnostics (`UNDECLARED-ERROR`, `UNHANDLED-ERROR`, `MISSING-ERROR-PAYLOAD`, ...) | display | canonical name for the identity, the spelling where it quotes source |

### Unknown precision encoded as an empty error set

Every branch of `hir/completions.tcl`'s walker (and the one outside it):

| site | before | after |
|---|---|---|
| `EvalCall`, callee neither an exact target nor `Fn`/`Coroutine` | unknown range, **no errors** | `IndirectFacts`: recovered / clean / unknown (erased-callable contract, incomplete) |
| `EvalCall`, `Fn`-typed callee | the contract's errors | the contract's errors, plus what the callee's fact adds (a transparent closure can hide errors behind a structural type) |
| `EvalHandle`, the `else` branch (an untyped handled call) | `normal 1`, **no errors** | `IndirectFacts`, as `EvalCall` |
| `EvalHandle`, structural callee | the contract | as `EvalCall` |
| `EvalCall`/`EvalHandle` natives | only natives with declared `-errors` analyzed | also `-errors-from` natives (a factory callable) |
| `NativeCallFacts`, `-errors-from` (`mutable_array::generate`) | the factory's type-level contract | plus its callable fact (a transparent closure factory) |
| `NativeCallFacts`, coroutine segments | the thunk's summary | the thunk's summary, its incompleteness propagated |
| `EffectiveFacts` recursion guard / budget / arity | the declared contract | the declared contract, plus what a transparent callee's callable inputs carry (`Fallback`) |
| `EffectiveFacts` after `analyzeBlock` | the walk's errors | the walk's errors; incomplete -> plus the declared contract |
| trait operations of a clone | the requirement's contract | plus the implementation's errors when incomplete |
| `block` (closure creation), `const`, `ref`, ... | no errors | unchanged: nothing runs |
| `hir/affine.tcl` error edges (`calleeErrors`) | **empty** for an untyped call or an exact call of a transparent function | plus the erased-callable contract (`mayLetErasedThrough`) |
| `hir/types.tcl` `calleeErrors` of an untyped callee | none | none at the type level (its comment no longer claims this is a proof) |

## Report

The 36 points, in the brief's order. "Before" is the payload-error
milestone's tree (`e238c61`), "after" this one; every reproducer was run on
both with this checkout's native build.

### 1. Root cause of the untyped-callable completion bug

A semantic instance (hir/semantic.tcl) lets a callable that declares errors
reach an untyped parameter: `hir/callables.tcl` accepts that one erasure
because the instance keeps the argument's exact type. Inside the generic
body the call `f(x)` has a callee that is neither an exact target nor a
`Fn`/`Coroutine`-typed value, and the completion walker's `EvalCall` (and
`EvalHandle`'s `else` branch) answered such a call with an unknown result
range and **no errors** -- "the walk cannot see an error here" became "there
is no error here". `call`'s summary was therefore `errors {}`, a caller of
`call(raise, 1)` needed no handler, any handler set was accepted, and the
error escaped at run time. The same empty answer reached `hir/types.tcl`'s
type-level `calleeErrors`, which `hir/affine.tcl` reads for error edges: an
affine value live across such a call was not released when the call failed
(a coroutine leaked: before, the Tcl backends left one alive and natively
one of two was never released; after, none alive, both released, none
swept -- `hoc-affine-error-edge`, `-native`). A second, smaller form: a
transparent closure called through a `Fn` type was charged only the type's
contract, which an untyped body inside it may exceed.

### 2. Completion-walker sites audited

Every branch of the walker and the one consumer outside it: the table "Unknown
precision encoded as an empty error set" above (`EvalCall`, `EvalHandle`,
natives with `-errors-from`, `NativeCallFacts` for factories and coroutine
segments, the recursion/budget/arity fallbacks, the post-analysis summary,
trait operations of a clone, value-only nodes, `hir/affine.tcl`'s error
edges, `hir/types.tcl`'s `calleeErrors`). Three encoded "unknown" as `{}`
(`EvalCall`, `EvalHandle`, the affine error edges); the others were already
conservative or analyzed nothing that can fail, and are documented as such.

### 3. Precise versus incomplete information

`analyzeBlock` returns `{normal errors result incomplete}` and the walk's
context carries `incomplete 0|1`. `errors {}` with `incomplete 0` is a
proof that no error escapes; with `incomplete 1` the walk charged at least
one call the program's *erased-callable contract* (`ErasedErrors`: every
declared error of every callable passed into an untyped parameter, read from
the instances' entry types with `hir::callables::CarriedErrors`) because it
could not tell which callable it was. Each value has a *callable fact*
(`CallableFact`): `{block B}` / `{native N}` (exactly that callable: the
call is recovered and analyzed exactly), `clean` (a parameter or capture of
the body being checked: charged where it was passed), or `unknown` (charged
the erased-callable contract; the walk becomes incomplete). Incompleteness
propagates to every enclosing summary (`IndirectFacts`, `EvalCall`,
`EvalHandle`, coroutine segments, trait calls). The facts are part of the
summary cache key, so a summary under precise facts is never reused under
unknown ones.

### 4. Where the declared-contract fallback occurs

At the function-instance boundary, `hir::completions::EffectiveFacts`: an
incomplete `analyzeBlock` result keeps every error the callee declares beside
what the walk found (`errors := walk ∪ declared`). The recursion guard, the
analysis budget and the arity mismatch already returned the declared
contract; they now go through `Fallback`, which adds what a transparent
callee's callable inputs carry (`Carried`). Trait operations of a clone add
the implementation's errors to the requirement's contract when incomplete
(`TraitCallErrors`). Nothing outside a declared contract is invented: the
erased-callable contract is itself a union of declared contracts.

### 5. Effective narrowing while analysis stays precise

A program that erases no error-bearing callable has an empty erased-callable
contract, and every new branch is gated on it (`IndirectFacts`, `Fallback`,
`Carried`, the affine edges): such a program is analyzed exactly as before.
That is checked, not argued: the NIR of all 41 example and benchmark
programs is identical to the tree before (modulo the rendered names of the
migrated stdlib errors), the scalar machine-code audit is byte-identical,
and every pre-existing narrowing test passes unchanged. With erasure, a walk
that never meets an unknown callable stays complete and keeps its narrowing
(`hoc-precise-with-erasure`, `hoc-fallback-not-without-loss`), and an exact
callable passed to a generic helper is *recovered* -- `call2(maybe, k, 1)`
is analyzed as `maybe(k, 1)` and narrows to `E1` alone
(`hoc-precise-recovery`, `hoc-precise-recovery-wrong-handler`). Soundness:
every charged set is a superset of what the run can raise -- exact calls by
the existing induction, recovered calls by the same analysis of the
recovered callee, clean values at the call that passed them (that call's
analysis saw their facts), unknown values by the erased-callable contract,
which covers every value that can reach an untyped parameter (only a
semantic instance puts it there, and its entry type is recorded), and a
transparent closure adds the erased contract itself.

### 6. KNOWN-ERROR

KNOWN-ERROR needs `normal 0`, a proof that a call cannot complete. Every new
fact is a may-fact: `Fallback` returns `normal 1`, an opaque call is never
charged a must-fact, and a recovered callable contributes its errors but
never its `normal` (`IndirectFacts` reads the recovered analysis's errors
only: the call `f(x)` in a generic body serves every caller, and one
caller's callable failing proves nothing about the others). So a fallback
never makes a call a known failure:
`hoc-known-error-direct` (an exact always-failing call is still
KNOWN-ERROR), `hoc-known-error-not-through-helper` (through a helper, a
handler runs), `hoc-known-error-fallback-not-definite` (an incomplete
summary does not make the success path dead).

### 7. The payload-free reproducer, before and after

```botlish
error E

fn raise(x: int) -> int errors E:
    if x > 0:
        fail E
    x

fn call(f, x):
    f(x)

call(raise, 1)
```

Before: accepted; at run time `CORE SEMANTIC UNCAUGHT-ERROR` (`<error E>`)
on interp, compile and Cranelift. After: rejected,
`11:1: this call may produce the declared error "E", which is neither handled
here nor admitted by the enclosing function's own "errors" declaration`
(UNHANDLED-ERROR). With `on Other:` as the only handler: before accepted and
escaped on all three backends, after UNHANDLED-ERROR for `E`.

### 8. The payload-bearing reproducer, before and after

The same with `error E:` / `code: int` and `fail E {code: x}`. Before:
accepted, escaping as `<error E {code: 1}>` on all three backends. After:
UNHANDLED-ERROR for `E`. `hoc-original-payload*` pin both versions, and
that handling every error is accepted and agrees on every backend.

### 9. The restored fuzzer path

`audit/error-payloads/tools/fuzz.tcl` draws the `unhandled` fault on every
operation path again (the payload-error milestone excluded `generic`), and
the summary now counts faults by path.
Two unaimed campaigns drew it once (`-seed 1001`: `unhandled/generic 1`,
beside `raise`, `mid`, `mid2`); a campaign aimed at it with the new
`-fault KIND` option draws it on every path: `-n 150 -seed 3001 -fault
unhandled` put it on `generic` 33 times (and on `raise` 46, `mid` 26, `mid2`
26, `partial` 12), `-n 40 -seed 6001 -fault unhandled -gc-stress 1` 5 times;
every one is rejected UNHANDLED-ERROR exactly as the model predicts, 0
disagreements. Before the fix the compiler accepted that shape (points 7
and 8), which is why the payload-error milestone had to exclude it; the
ERROR-PAYLOADS.md workaround note is gone.

### 10. Canonical error-identity representation

A string: `NS::Name` for a module's error (`abi::x86_64::Register64BelowRange`
for a nested module), the bare `Name` for the entry program's and for the
runtime's builtin errors. `hir::errordecls::canonical NS NAME`,
`shortName ID`, `namespaceOf ID` convert; the owner is recovered from the
string, never from load order. Unambiguous: a module namespace is never
empty, so a bare name is entry or builtin, and the two are disjoint (a
source error named like a builtin one is rejected).

### 11. Short-name versus canonical storage

Short names (spellings) live only in source and in the syntax a module
loader caches: the AST's `error` declarations, `fail`/`on`/`errors` nodes,
`payloadOf` before resolution, and diagnostics that quote source.
Everything from HIR resolution on holds the canonical identity: the
descriptor table (`hir::errordecls` `current`/`payloads`), `fail` and
handler names, `declaredErrors`, `Fn`/`Coroutine` contracts, trait
requirements, completion sets, warnings, HIR text, Core IR, `errorId`, the
native id table. The census above lists every site.

### 12. Entry-program errors

Unchanged spelling and identity: the entry program is no namespace, its
`error Failed` is `Failed`, named bare, and coexists with `a::Failed`
(`nerr-entry-beside-module`).

### 13. Defining-module short names

Inside its module an error is declared, failed, handled and named in
contracts by its short name, which resolves to the module's own identity
(`nerr-own-short-name`); `on Failed` and `on a::Failed` inside `a` are the
same identity (a second one is DUPLICATE, `nerr-duplicate-handlers`). A
module may also name its own errors qualified.

### 14. External qualified use

Outside its module an error is spelled `ns::Name` at every site -- `fail`
(constructing its payload under the ordinary checks,
`nerr-fail-outside-owner`), `errors`, `on`, `Fn{errors: [...]}`, trait
requirements -- and a module that imports another relays and handles its
errors the same way (`nerr-module-relays`). A bare spelling of a module's
error outside it is UNDECLARED-ERROR naming the qualified spellings
(`a::Failed, b::Failed`).

### 15. Import authorization

Exactly the ordinary rule for qualified members (`surface::modules`'
`QualifiedRefs`, `CollectAndLoad`): `import a` authorizes `a::Failed`;
no import, an import of a child (`a::sub`) or of another namespace does not
(MISSING-IMPORT); an unknown namespace is UNKNOWN-NAMESPACE; a namespace
without that error is UNKNOWN-SYMBOL listing the errors it declares
(`nerr-import-authorization`, `nerr-diagnostic-messages`). Imports stay
exact and non-transitive. There is no `import error` (`nerr-no-import-error`).

### 16. Builtin/root errors

The runtime's builtin errors (`InvalidArgumentEncoding`, `IndexNotFound`,
`LowerUnderrun`, `UpperOverrun`) stay root identities, named bare in the
entry program and in every module; a source error may not take one of their
names (`nerr-builtin-root`). They keep their fixed native ids.

### 17. Migrated stdlib identities

`io::WriteFailed`, `io::path::NotAPath`, `byte::BelowRange`,
`byte::AboveRange`, `list::NotFound`, `abi::AbiIntegerBelowRange`,
`abi::AbiIntegerAboveRange`, `abi::x86_64::Register64BelowRange`,
`abi::x86_64::Register64AboveRange` (`nerr-stdlib-identities`). Their owners
are unchanged; `lib/linux/io.bot`, `lib/linux/path.bot`, the examples,
benchmarks, audit probes and fuzzers, and the tests spell them qualified
(`nerr-stdlib-qualified-use`). No alias.

### 18. Payload descriptors

One descriptor per canonical identity, keyed by it and recording its
namespace and fields (the short name is the identity's own, `shortName`):
two same-shaped `Failed` are two descriptors with equal payload types
(`nerr-descriptors`). The payload is still the anonymous struct of the
declared fields; the identity is not in it.

### 19. `fail`

`fail SPELLING {...}` resolves the spelling in the namespace of the code
that writes it and constructs the payload of that identity's descriptor
with the unchanged checks (MISSING-/UNEXPECTED-ERROR-PAYLOAD,
MISSING-/UNKNOWN-/DUPLICATE-FIELD, TYPE). The fail node, Core IR and NIR
carry the canonical identity.

### 20. `errors` contracts

Function `errors` clauses, trait requirements and `Fn`/`Coroutine` types
resolve every spelling to its canonical identity in their own namespace;
subset checks (`FnMismatch`, conformance, coroutine contracts) compare
identities, never short names (`nerr-contracts`).

### 21. Handlers

`on SPELLING` resolves to an identity; selection is by identity alone, at
compile time and at run time: a handler for `a::Failed` never handles
`b::Failed`, statically (UNHANDLED-ERROR, `nerr-wrong-namespace-rejected`)
and dynamically on every backend with `-strict 0`
(`nerr-wrong-namespace-runtime`). Two handlers of one identity are
DUPLICATE; one handler per same-short-name identity is fine
(`nerr-both-handlers`). Destructuring is unchanged.

### 22. HIR text and round trip

HIR text states canonical identities (`error a::Failed`, `fail a::Failed`,
`handle ... a::Failed`, contracts); write -> read -> write is stable with
two same-short-name errors, and the read-back program still dispatches them
apart on every backend (`nerr-hir-text-round-trip`).

### 23. Tcl runtime representation

`core::value::errorId` carries the canonical identity; the evaluator's and
the compiler's handler comparisons are `eq` on it (the compiler's
`switch -exact` arms are canonical names), so a short-name match cannot
happen (`nerr-tcl-errorid`). No code in `core/` or `compiler/` changed.

### 24. Native id mapping

`native/lower.tcl` assigns one dense id per canonical identity of
`hir::errorDecls` (sorted, program-unique); `Inst::Fail` embeds it,
`declarederroreq` compares it, the name string is for rendering only.
`a::Failed` and `b::Failed` get two ids (`nerr-native-ids`). Builtins keep
their fixed ids. No code in `native/` changed: the table was always keyed
by the identity string, which is now canonical.

### 25. Coroutine cached errors

A coroutine's cached failure (Tcl: the `errorId`; native: `(RtError, id,
payload, shape)`) keeps the identity it failed with: a later resume raises
`a::Failed` again, never the entry program's `Failed`
(`nerr-coroutine-cached-identity`).

### 26. SAME-FAILURE

The warning's groups are keyed by the fail sites' canonical identities
(the code is unchanged; its data is canonical), so the program's `Invalid`
and module `m`'s `m::Invalid` never group, payload-free or with identical
payloads (`sf-same-short-name-never-grouped`), while a module's fail of its
own error and the program's fail of it are one identity
(`sf-module-failure-is-the-same-failure`, `sf-one-identity-is-one-declaration`).
The fuzzer's namespaced seeds (100 of 300) and the mutant
`same-short-name-grouped` (groups by short name; killed by the fuzzer)
check it too.

### 27. Same-short-name, same-shape cross-module regression

Modules `a` and `b` each declare `Failed {code: int}` and `Plain`:
both load, are distinguishable with one handler each and the same
destructuring on interp, compile, Cranelift and Cranelift without
specialization (`nerr-coexist`, `nerr-distinguishable`), a wrong-namespace
handler is rejected and escapes at run time (`nerr-wrong-namespace-*`), and
so on through points 12-25. The old global-collision rejection is now this
positive test; a duplicate within one module or the entry program is still
rejected (`nerr-same-module-duplicate`). The compiler-shaped fixture
(`compiler_fixture` with `CompilerError`, `Unbound`, `Type` beside a
`typesys` module declaring `Type` and `Unbound`) passes
(`nerr-compiler-fixture`).

### 28. Combined namespacing and untyped-callable regression

`nerr-combined-fallback`, `-generic`, `-accepted`: `a::Failed` and
`b::Failed` raised through an untyped helper, directly and through a
declaring function: a handler for `b::Failed` only is UNHANDLED-ERROR for
`a::Failed`, and the reverse; handling the identity that is passed is
accepted; with both erased, a closure that captured one of them is charged
both (the conservative cost of the erased-callable contract, pinned).

### 29. Fuzz results

`audit/error-payloads/tools/fuzz.tcl` on the final tree (ERROR-PAYLOADS.md,
point 51, has the table): `-n 200 -seed 1` and `-seed 1001` (4 backends),
`-n 60 -seed 5001 -gc-stress 1`, `-n 150 -seed 3001 -fault unhandled`,
`-n 40 -seed 6001 -fault unhandled -gc-stress 1` and `-n 90 -seed 4001
-fault wrong-namespace`: 740 programs, 247 of them namespaced (alpha::E,
beta::E, gamma::E and the entry program's E, identical, different, absent
and affine payloads, wrong-namespace handlers, the combined untyped path),
**0 disagreements**. `wrong-namespace` was rejected through `combined` 13,
`declaring` 10, `generic` 5 and `direct` 2 times.

`audit/same-failure/tools/fuzz.tcl 300 1`: 300 seeds, 100 of them
namespaced (a module's `Bad` beside the entry program's), 0 failures, 0
extra warnings. `audit/affine/tools/fuzz.tcl` seeds 1-4 and 1001, 30
programs each: 0 disagreements (79-84 identities' releases checked per
run). `audit/coroutines/tools/fuzz.tcl` seeds 1-3 and 1001, 50 programs
each: 0 disagreements (13-14 returns, 21-24 fails, 5 calls, 15-18 breaks,
12-16 continues releasing coroutines per run).

The fuzzers and scenario tools whose generated programs name a migrated
stdlib error or a module's error from outside it were updated and rerun:
`audit/context-traits` (30 programs: 0 disagreements -- its run before the
update rejected every program naming `fz::tr`'s `Fail` outside it, which is
the rule working), `abi-bytes` (both modes), `abi-numeric-domains`,
`imports`, `linux-x86-64-syscall`, `mutable-bytes` (both modes),
`m7a-instance-selection` scenarios, `refactor/tools/probe.tcl` (which now
hoists a driver's imports and reads a qualified error name), and
`proves-naming` (300 seeds): 0 failures each. The other module-writing
fuzzers (`contexts`, `elif`, `fixed-arity-list-return`, `method-sugar`,
`opaque-struct`, `refinement-values`, `short-string`, `stdlib-namespaces`,
`struct-destructuring`, `traits`), 20 programs each: 0 failures
(`short-string`'s 3 static rejections are the same on the tree before).

### 30. Mutation results

Every catalog's mutants still apply exactly once -- the context-traits
catalog needed two of its texts qualified (`lib/linux/io.bot` now fails
`io::WriteFailed`, and a replacement failing the bare name would have died
of an unknown error instead of the bug it stands for) -- and every one is
killed, on the final tree:

| harness | mutants | killed |
|---|---:|---:|
| `audit/error-payloads/tools/mutate.tcl` (24 earlier, 10 completion, 10 identity) | 44 | 44 |
| `audit/same-failure/tools/mutate.tcl` (14 earlier, `same-short-name-grouped`) | 15 | 15 |
| `audit/affine/tools/mutate.tcl` | 29 | 29 |
| `audit/coroutines/tools/mutate.tcl` (11 native, each rebuilt) | 52 | 52 |
| `audit/context-traits/tools/mutate.tcl` | 23 | 23 |
| `audit/traits/tools/mutate.tcl` | 18 | 18 |

The new error-payloads mutants and what killed them (tests failed among
`error-payloads.test`, `higher-order-completions.test` and
`namespaced-errors.test`; fuzz programs disagreeing of 25 unaimed and 25
aimed with `-fault unhandled`, the harness's new second fuzz detector):

| mutant | the brief's name | tests | fuzz | aimed |
|---|---|---:|---:|---:|
| `untyped-callable-reports-no-errors` | untyped callable reports no errors | 13 | 0 | 0 |
| `recovery-reports-no-errors` | the same, for a recovered exact callable | 32 | 0 | 2 |
| `precision-flag-dropped-on-return` | fallback flag dropped through a nested call | 3 | 0 | 0 |
| `nested-incompleteness-not-propagated-call` | (the same, exact call) | 1 | 0 | 0 |
| `nested-incompleteness-not-propagated-handle` | (the same, handled call) | 1 | 0 | 0 |
| `fallback-empty-effective-set` | fallback uses the empty set | 12 | 0 | 0 |
| `fallback-omits-declared-error` | fallback ignores one declared error | 2 | 0 | 0 |
| `fallback-definite-failure` | fallback marks declared errors a definite failure | 16 | 0 | 0 |
| `recursion-fallback-ignores-carried` | (a cycle's fallback drops what its callable input carries) | 4 | 0 | 0 |
| `affine-error-edge-ignores-erased` | (point 1's leak) | 2 | 0 | 0 |
| `descriptor-keyed-by-short-name` | descriptor keyed by short name | 74 | 22 | 10 |
| `handler-dispatch-short-name-tcl` | handler dispatch by short name | 3 | 5 | 0 |
| `handler-dispatch-short-name-compile` | (the same, Tcl compiler) | 3 | 5 | 0 |
| `contract-subset-short-name` | contract subset by short name | 1 | 0 | 0 |
| `tcl-errorid-strips-namespace` | Tcl errorId strips the namespace | 19 | 6 | 0 |
| `native-id-aliases-short-name` | native id aliasing | 4 | 5 | 0 |
| `coroutine-cache-short-name` | coroutine cache stores the short name | 1 | 0 | 0 |
| `hir-text-drops-namespace` | HIR round trip drops the namespace | 3 | 0 | 0 |
| `module-sees-short-name-everywhere` | (the flat namespace's lookup) | 2 | 0 | 0 |
| `qualified-error-unauthorized` | (a qualified error without its import) | 2 | 0 | 0 |

`same-short-name-grouped` (SAME-FAILURE groups by short name) is the
same-failure harness's, killed by its fuzzer (3 failures, 6 extra
warnings over 40 seeds).

The identity mutants that change run-time dispatch are killed by the
independent model too. The completion mutants are killed by the tests'
per-path wrong-handler, differential and fallback tests (`hoc-*-returned`,
`-structural`, `-recursion`, `hoc-fallback-declared-contract*`,
`hoc-summary-unknown`, `hoc-affine-error-edge*`); of them, only
`recovery-reports-no-errors` -- the original bug's own shape, an exact
callable through `call` -- is reachable by the fuzzer, and the aimed run
kills it. The others act on *unknown* callables (a returned closure, one
held in a structure, a recursion's carried input), which the fuzzer does
not generate. All 24 earlier mutants stay killed, by the same detectors as
before (ERROR-PAYLOADS.md, point 52).

### 31. Full regression

`tests/all.tcl` on both Tcl backends, every test file in its own process
with a private `-tmpdir`, on the final tree:

| backend | before (`e238c61`) | after |
|---|---|---|
| interp | 6944 passed, 0 failed | 7037 passed, 0 failed |
| compile | 6940 passed, 4 skipped, 0 failed | 7033 passed, 4 skipped, 0 failed |

That covers every suite the brief names: `error-payloads`, `errors`,
`same-failure`, `affine`, `coroutines`, `imports`, the completion suites
(`range-completions-crosscheck`, `proven-bounds`, `proof-loop-intervals`,
`checked-domain-proof-provenance`), the function-value suites
(`structural-fn-types`, `typed-callable-escape`, `hir-callable-target`,
`exact-callable-key`), the generic and specialization suites
(`semantic-instances`, `hir-specialize`, `blockescape-called-generic`),
the HIR text round-trip suites (`hir-syntax`, `hir-samples`,
`hir-lowering`), and `warning-gate` (the corpus is still
exactly its manifest: `audit/refactor/tools/gate.tcl` passes). The 93 new
tests are point 32's. Existing tests changed only where they named a
module's error from outside the module -- now qualified, with diagnostics
quoting the canonical name (`abi::AbiIntegerBelowRange`, `model::Bad`) --
and `ep-cross-module`, which now also declares the program's own
`NotThere` beside `eppage::NotThere`. `cargo test --release --manifest-path
native/Cargo.toml`: 219 + 31 passed, 0 failed (unchanged: no native code
changed).

### 32. Native coverage

`tests/native-coverage.tcl` (the whole suite on Cranelift, every test
classified) on the final tree; "before" is the payload-error milestone's
final tree (ERROR-PAYLOADS.md, point 59 -- `e238c61` only regenerated the
scalar audit after it):

| class | before | after |
|---|---:|---:|
| tests | 6944 | 7037 |
| native | 2791 | 2836 |
| independent | 4024 | 4072 |
| passed-partial | 69 | 69 |
| unsupported | 60 | 60 |
| failed | 0 | 0 |

The 93 new tests (`higher-order-completions.test` 61, `namespaced-errors.test`
31, `same-failure.test` 1) are 45 native and 48 independent (diagnostics:
the completion and identity rules are compile-time). The 60 unsupported
tests need what they needed before, in the same numbers (a Block value at
the program boundary 13, `test-log`/`test_log` 19, `test-tick`/`test_tick`
12, sequence mode 7, test validators and natives 7, a validator contract
2); none is a test of this milestone.

### 33. GC stress

`BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation
site) over the test files whose behavior this milestone touches or
neighbors, on the final tree:

| test file | tests | failed |
|---|---:|---:|
| `error-payloads.test` | 61 | 0 |
| `namespaced-errors.test` | 31 | 0 |
| `higher-order-completions.test` | 61 | 0 |
| `errors.test` | 40 | 0 |
| `affine.test` | 45 | 0 |
| `coroutines.test` | 79 | 0 |

and the error-payload fuzzer's GC-stress campaigns (`-seed 5001`, 60
programs, and `-seed 6001 -fault unhandled`, 40 programs): every accepted
program run natively again under GC stress, 0 disagreements. No native code
changed, so no stack-walking or root change is involved; the whole suite
under GC stress is the `gc-stress` CI job on `main`.

### 34. Scalar/codegen audit

`native/generate-scalar-audit.tcl` regenerated into a scratch directory:
every `.asm` and summary is byte-identical to the committed
`audit/native-scalar-asm/` (only the README's commit and toolchain lines
differ), so nothing is recommitted. The NIR of all 41 example and benchmark
programs is identical to the tree before except the rendered string of the
migrated stdlib errors' `faildeclared` (`"AboveRange"` ->
`"byte::AboveRange"`); the ids are the same.

### 35. Performance

**Run time: none.** No runtime file changed; the NIR of every example and
benchmark program is the tree before's modulo the rendered error-name
string, and the scalar machine code is byte-identical (point 34). Native
ids stay dense small integers, one per canonical identity (two
same-short-name errors take two ids, where the flat namespace could not
compile the program at all). The Tcl runtimes compare `errorId` strings
that are longer only for the migrated stdlib errors (`byte::AboveRange`).

**Compile time.** Measured with each tree's own compiler on an otherwise
idle machine, the two trees interleaved, twice:

| program | before | after |
|---|---:|---:|
| the 41 example and benchmark programs, best of 3 per file, summed | 7566 / 7385 ms | 7689 / 7571 ms |
| a synthetic erasure-heavy program: 40 handled calls of an error-bearing function through generic `call`/`twice`/`relay` helpers, best of 5 | 332 / 342 ms | 445 / 432 ms |

The corpus compiles about 2% slower, about the size of the run-to-run
variation: no program in it erases an error-bearing callable, so the
completion analysis is the old one (every new branch is gated on an empty
erased-callable contract), and what remains is name resolution through
`hir::errordecls::resolve` and the authorization of qualified error
references. The erasure-heavy program costs about 30% more, all of it in
the completion pass (`hir::errorsets::verify` 82 -> 183 ms per compile),
most of that the recovered analyses (`IndirectFacts`, 91 ms): each
`call(raise, k, i)` now analyzes `raise` under that call's facts, which is
what keeps such calls exactly as precise as a direct call (point 5) instead
of charging them the erased-callable contract.

### 36. Payload semantics, affinity and native transport

Unchanged: no file under `core/`, `compiler/`, `native/` or `hir/lower.tcl`
differs from the tree before; payload construction, destructuring,
ownership, coroutine caching and the field-wise native payload slots are
the same code, now fed canonical identities. The one ownership change is
the bug fix of point 1 (an affine value is released on the error edge of a
call an erased callable may fail through), which follows the existing
release-on-every-early-exit rule. Every pre-existing test of these
properties passes (point 31), and every pre-existing mutant is still killed
(point 30).

## Files

| file | what |
|---|---|
| `hir/completions.tcl` | callable facts, the erased-callable contract, `IndirectFacts`, `Fallback`, `Carried`, transparency, the incomplete flag and the declared-contract fallback |
| `hir/callables.tcl` | `CarriedErrors` (the error part of `Bearing`) |
| `hir/affine.tcl` | error edges through erased callables |
| `hir/errordecls.tcl` | canonical identities, `resolve`, `shortName`, `namespaceOf`, `unknownReason` |
| `hir/resolve.tcl`, `hir/traits.tcl` | resolution of every error spelling |
| `surface/parser.tcl` | `ErrorName` |
| `surface/modules.tcl` | qualified error references: collection and authorization |
| `lib/linux/io.bot`, `lib/linux/path.bot`, `lib/abi/x86_64.bot` | qualified external uses; a comment |
| `examples/`, `bench/`, `audit/*/probes/` | qualified external uses |
| `tests/higher-order-completions.test` | Part A |
| `tests/namespaced-errors.test` | Part B and Part C |
| `audit/error-payloads/tools/{fuzz.tcl,mutants.txt,mutate.tcl}` | the restored path, namespaced programs, `-fault KIND`, new mutants, the harness's aimed `-fault unhandled` fuzz detector |
| `audit/same-failure/tools/{fuzz.tcl,mutate.tcl}` | namespaced programs, a new mutant |
| `audit/context-traits/tools/{fuzz.tcl,mutants.txt}`, `audit/proves-naming/tools/fuzz.tcl`, `audit/{abi-bytes,abi-numeric-domains,imports,linux-x86-64-syscall,mutable-bytes}/tools/fuzz.tcl`, `audit/m7a-instance-selection/tools/scenarios.tcl`, `audit/refactor/tools/{probe.tcl,probes/linux-path.tcl}` | qualified spellings of errors used outside their modules (`probe.tcl` also hoists a driver's imports and reads a qualified error name) |

## What to run when changing this

AGENTS.md, "Error identity" and "Completion precision through untyped
callables".
