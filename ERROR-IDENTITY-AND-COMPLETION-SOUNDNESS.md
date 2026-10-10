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
change is a bug fix of the same failure mode (point 2).

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

<!-- REPORT -->

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
| `audit/error-payloads/tools/{fuzz.tcl,mutants.txt,mutate.tcl}` | the restored path, namespaced programs, new mutants |
| `audit/same-failure/tools/{fuzz.tcl,mutate.tcl}` | namespaced programs, a new mutant |

## What to run when changing this

AGENTS.md, "Error identity" and "Completion precision through untyped
callables".
