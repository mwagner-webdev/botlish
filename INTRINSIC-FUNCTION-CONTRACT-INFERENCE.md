# Intrinsic function contract inference

## Outcome

An untyped parameter is no longer permanently `any`. Every function now has
one authoritative **intrinsic signature** (`hir/signatures.tcl`), computed
from its own declaration and body alone -- never from its callers -- in which
each untyped parameter carries the contract its body's uses prove:

```
uses of a parameter (and of its immutable aliases)
        |  the admissibility metadata ordinary checking already uses
requirements imposed on that value
        |  meet (glb; FnGlb for two function contracts)
intrinsic inferred parameter contract   (fixed point over ordinary calls)
```

Headline results on the canonical corpus (all measured, see
`audit/intrinsic-function-contracts/`):

- **`scan_while`'s `predicate`** goes from `any` to the ordinary structural
  function type **`Fn{args: [str], return: bool, errors: []}`**, derived from
  `predicate(char_at(i))` alone: the argument is `str` (`char_at`'s result),
  the result is an `if` condition (`bool`), and the call sits in an
  error-free function with no handler (`errors: []`). `predicate(char_at(i))`
  is now typed `bool` in both the source and the used instance view. The
  call stays `callvalue` (no target is inferred), but the instance
  `scan_while<generic>` goes from AOT **open to closed**, and its callers
  `tld?`, `domain?` and `web::emailish?<str>` from transitively open to
  transitively closed.
- **`local_char?(c)` and `label_char?(c)`** infer `c : str` from
  `is_tcl_alnum(c)`; set membership and `==` impose nothing.
- **Corpus census**: 363 untyped parameters inspected across all 31 canonical
  source programs and the library modules they load; **314 narrowed** (313 to
  a scalar/aggregate contract, 1 to a structural `Fn`), 44 genuinely
  unconstrained, 5 callable parameters left untyped because their argument
  relationship needs a type variable, **0 conflicts**, every canonical program
  still valid.
- **Callable-site census** (the nine canonical `callvalue` sites): structural
  `Fn` **2 -> 4**, bare block/native 5 -> 5, `any` **2 -> 0**. Static
  `callvalue` count unchanged (9, identical sites).
- **Instance result precision fixed**: created Blocks no longer default to
  `return: any` in specialization views. `lex-strategy`'s `classify<str,
  bool>` classifier and `source-checks`' `classify_leading<generic>` check
  element are `Fn{args: [any], return: bool, errors: []}` in the instance
  view too (was `return: any`), and their call results are `bool`.
- **Deliberate semantic strengthening** (pinned): `fn wrapper(x):
  length(x)` then `wrapper(123)` is now a compile-time error at the call
  (was the native's run-time `TYPE` error inside `wrapper`).
- Full regression **2779/2779 on interp and 2779/2779 on compile** (94 test
  files; baseline 2718/2718, 93 files). Benchmark parity: `bench/bench.tcl
  -runs 1` exits 0 with no disagreement on any of the 8 programs.
- Generated code changed only by **removing redundant `guardbool`
  instructions** that the new static types prove unnecessary (scan_while's
  `if predicate(...)`, and three `list_get(flags, ...)` conditions whose
  lists are now `List[bool]` in instance views). The scalar-assembly audit
  corpus is byte-identical except `bench/refined-checks.asm`'s
  `scan_while` (-32 bytes, one `rt_not_boolean` guard fewer). No runtime,
  representation, root or allocation code changed.

One part of the brief could not be implemented as literally written without
rejecting canonical programs; the section "Trusted and checked
requirements (the one deliberate deviation)" explains the decision and the
measured evidence. In short: a requirement the body *assumes* (a callable
parameter's contract, a requirement forwarded to a declared-typed callee)
is treated exactly like a declaration; a requirement the body *re-checks at
run time anyway* (a native's `-param-types`) rejects every statically known
incompatible argument at compile time but, like the native itself, does not
reject an argument of static type `any`, and is not part of the structural
`Fn` contract. Treating the latter like a declaration rejects 10 of the 31
canonical programs -- every failure at the generics / untyped-aggregate
boundary, none a real type error.

## Motivation

`STRUCTURAL-FUNCTION-TYPES.md` left the two scanner `callvalue` sites (96%
of all dynamic indirect calls in the corpus) typed `any`, and
`local_char?`'s parameter `any`, although both bodies say exactly what
they need. Botlish inferred what an expression *produces*; it never
inferred what a function *requires*. This milestone applies the same
philosophy in the other direction: a parameter's uses tell the compiler
what the function requires, and the programmer should not have to write a
type the compiler can derive from the program they already wrote.

## Previous untyped-parameter semantics

**Q1. Where were untyped parameters assigned `any` before?** In four places,
all of which now read the intrinsic signature instead:

- `hir::types::Block` seeded only *declared* parameter types into the body's
  typing context; an untyped parameter had no `ctx types` entry, so
  `BindingType` fell through to `ForwardType`, which answers `any` for a
  parameter binding.
- `hir::types::BlockContract` built an exact Block's contract from
  `declaredParamTypes` alone (untyped -> `any`), so `structuralOf` exposed
  `Fn{args: [any, ...]}`.
- `hir::range::VerifyCall` skipped every parameter with an empty declared
  type: an untyped parameter was never checked at a call.
- `hir::specialize::Analyze`/`Reanalyze` adopted only declared types as an
  instance's entry seed (the M1 path); an untyped parameter got its
  `KeyType` (`any`, `block`, `native`, ...) and nothing else.

## Intrinsic contract definition

The intrinsic contract of an untyped parameter is the meet of every
requirement its function's own body imposes on it, where a *requirement*
is a reachable use of the parameter (or of an immutable alias of it) in a
position with a statically known admissibility domain, not already proven
at that position, and not control-dependent on a type test of the parameter
itself. It is derivable from the declaration and body alone: adding a new
compatible caller can never invalidate it (no caller-ingress fact is used,
no call site of the function is ever read to compute it). Genuinely
unconstrained parameters remain `any`.

**Q2. At what compiler stage are intrinsic body requirements now
collected?** In `hir::buildSyntax`'s (and `native::prepareHir`'s) new shared
tail `hir::check`, which replaces the single `hir::types::infer` call:
`hir::signatures::infer` types the program with `hir::types::infer`,
collects requirements from that typed HIR, solves them, and re-types when a
trusted contract changed -- all before `verifyDeclaredResults`,
`verifyDeclaredParams`, the callable escape audit and error-set
verification, which therefore see and enforce the final contracts.

**Q3. Per function, per instance, or split?** Split. The intrinsic contract
is computed once per function on the whole-program semantic HIR,
independently of specialization; it never depends on the caller population.
Specialization instances then adopt the *trusted* part as an entry seed
exactly as they adopt a declared type (M1), so it cannot disappear because
`KeyType` projects an argument to `any`/`block`/`native` (item 63).

## Explicit annotation boundary

**Q9. Are explicit annotations narrowed? No.** A declared parameter type is
never touched: inference applies only to parameters whose
`declaredParamTypes` entry is empty, and a declared type is always the
entry type (`hir::signatures::entryTypes`). A body whose use needs more than
the declaration admits is invalid exactly as before
(`ic-explicit-broad-not-narrowed`: `fn broad(x: int): take_byte(x)` is
rejected, not turned into `x: Byte`), unless an existing refinement proves
the use (`ic-explicit-refinement-proves`). An exact annotation that
satisfies every use is simply valid (`ic-explicit-declared-kept`), and the
signature reports it as `declared`.

**API stability (item 44).** Because an unannotated function's contract is
derived from its implementation, changing the implementation can change the
contract. That is acceptable for an unannotated function; an explicit
parameter annotation is the mechanism for pinning a stable public contract.
`hir::moduleSignatures` now reports each exported parameter's intrinsic
contract with its source (`declared` / `inferred` / `none`): exported
functions are not exempt from inference (item 45), and a declared public
parameter type remains the API boundary even where the body could prove
more.

## Requirement collection

`hir::signatures::Collect` walks every region top-down in evaluation order
with a *sink* for each value position -- what the value flows into:

| sink | meaning |
|---|---|
| `drop` | a statement's discarded value |
| `alias` | bound to a local (its own uses are this value's uses) |
| `flow` | somewhere not followed (a List element, an untyped native argument, a returned value, ...) |
| `{type T K}` | a position requiring `T`, kind trusted or checked |
| `{param B I}` | parameter `I` of block `B` (an edge to its contract) |
| `{pcallarg P I}` | argument `I` of a call of untyped parameter `P` |

Nested functions are walked where they are created, inheriting the
path-dependence of their creation point. A requirement is recorded with its
provenance (expression, what imposed it, the type), which is what every
diagnostic and the audit report print (item 46):

```
scan_while
    start <- checked: the start of a counted loop requires int (at 127:21)
    predicate <- trusted: calling it as a function (call at 128:16 passes arg 1
        str (128:26); its result is required by the condition of an if (or
        not/and/or) requires bool (at 128:16); its call sites admit errors [])
        requires Fn{args: [str], return: bool, errors: []} (at 128:16)
local_char?
    c <- checked: argument 1 of native is_tcl_alnum requires str (at 100:22)
```

## Call-argument requirements

For `g(x)` with a directly known target, the requirement comes from the
same place `hir::range::VerifyCall` gets its proof obligation:

- `g`'s parameter is **declared** `T`: `x` requires `T` (trusted). Before
  this milestone the forwarding body itself was a static error (`x : any`
  cannot be proven `T`); it is now valid, and its own callers are held to `T`
  (`ic-trusted-forwarder-now-valid`, `callable-escape-capture-untyped-
  wrapper-rejected`, `fn-accept-untyped-forwarder`).
- `g`'s parameter is **untyped**: an edge -- `x` requires whatever `g`'s
  parameter's intrinsic contract turns out to be (trusted part trusted,
  checked part checked), solved to a fixed point.
- a call through a structural `Fn`: the contract's argument type (trusted,
  `VerifyStructuralCall`'s obligation).
- a declared result position (`fn f(x) -> Byte: x`, or `return x` in it):
  the declared type (trusted, `verifyDeclaredResults`'s obligation).

The same `ProvesValueAcceptedBy` admissibility decides whether a use site
already proves a requirement and whether a caller's argument satisfies an
inferred contract; no second notion of compatibility exists.

## Native admissibility requirements

**Q10. Which native metadata supplies body-use requirements?**
`core::native::metadata NAME`'s `paramTypes` -- the registry's `-param-types`,
"types the implementation *requires*" (core/native.tcl).

**Q11. Is that the same source normal checking uses? Yes.** It is the very
field `hir::types::Call` narrows an argument with after a native call
returns, `hir::specialize` reads to decide a call "always raises TYPE", and
the reference runtime asserts after every call. Nothing in the inference
names a native: `is_tcl_alnum -> str`, `immutable_set_contains ->
{immutableSet any}`, `== -> {any any}` are all read from the registry.

**Q12. Did exact Native structural `Fn` signatures change? No.** A native's
structural arguments are still `any` (`fn-law-native-structural-signature`
passes unchanged).

**Q13. Does wrapping a runtime-type-checking native in an untyped function
now infer a static wrapper precondition? Yes** -- a *checked* one: every
argument of statically known type that is not admissible is rejected at
compile time; see the next sections for why an argument of static type
`any` is not.

**Q14. Is this semantic change tested? Yes**: `ic-native-wrapper-static`,
`ic-native-wrapper-known-kind`, `ic-native-wrapper-before`,
`ic-native-wrapper-any-argument`, `ic-native-direct-unchanged`, and the
updated `stdlib-string_reverse-not-a-string` / new
`stdlib-string_reverse-not-a-string-static`.

## Operator requirements

Operators are natives (`+ - * < <= > >= mod bit_*` require `int`, `concat`
and `length` `str`, `==` nothing), so they participate through the same
registry rows (`ic-operators`). Three non-call constructs have run-time
checks of their own and are the only hand-listed positions, each mirroring
its evaluator check: an `if` condition requires `bool` (`NOT-BOOLEAN`;
`not`/`and`/`or` lower to `if`), a `loop x in xs` iterable `list`
(`core::value::expect list`), and a counted loop's bounds `int`.

## Immutable alias propagation

**Q4. How are simple aliases traced?** `Collect` records every non-duplicate
`bind y (ref x)` of a local as `alias[y] = x`, and every `bind y (call p
...)` whose callee is a reference with no exact target as
`resultOf[y] = p`. `Root` follows alias chains (cycle-guarded) to an untyped
parameter, or to "the result of calling parameter `p`". Any requirement on
`y` is therefore a requirement on `x` (`ic-alias`, `ic-alias-chain`), and
any requirement on a call's bound result is a requirement on `p`'s return
(`alias-call` in the edge-case probe). Single assignment is what makes this
sound without any flow analysis.

**Destructuring/extraction (item 13)**: not propagated. A requirement on
`list_get(xs, i)` or a loop element is not pushed back into `xs`'s element
type: `List[T]` parameters are invariant, so "every element is `T`" is a
stronger contract than the body's use proves. Documented limitation.

## Meet / conflicting constraints

**Q5. How are multiple requirements combined?** By meet:
`hir::types::glb` (admissibility order plus same-base evidence union), and a
new `hir::types::FnGlb` for two function contracts (arguments joined --
contravariant --, returns met, errors intersected). The trusted part is the
meet of trusted requirements; the checked part the meet of all of them.
`fn both(x): y = x + 1; take_byte(x)` infers `x : Byte` (`ic-meet`).

**Q6. What happens when there is no representable meet?** A compile-time
`TYPE` error naming the parameter and both uses -- never `any`, never an
intersection type (`ic-conflict`, `opt-tail-7-static`):

```
cannot infer a sound type for parameter "n" of f: argument 1 of native -
requires int (at 4:7), but argument 2 of native concat requires str
(at 4:26), and no type satisfies both
```

The conflicting parameter is then treated as unconstrained for propagation,
so one conflict produces one diagnostic, not a cascade. A callable
parameter whose result is required as two incompatible types is the same
error (`ic-conflict-callable-result`). The corpus has **no** conflicts.

## Control-flow/refinement interaction

Existing facts count (item 11). A use is not a requirement when:

- **the use site already proves it** -- the use-site type, excluding the
  parameter's own seed, admits the requirement: a branch refinement
  (`if string?(x): length(x)`), or a flow fact from an earlier native call
  (`length(x); concat(x, "!")` records `str` once);
- **it is unreachable** under the existing reachability (`ic-unreachable-
  ignored`, `ic-unreachable-call-ignored`: a call in a statically dead
  branch infers neither a contract nor an error requirement -- items 59-60);
- **it is control-dependent on a type test of the parameter** -- inside
  either branch of an `if` whose condition refines it. `fn either(x): if
  integer?(x): x + 1 else: length(x)` accepts both kinds, and with no union
  type to say so, neither branch constrains `x`
  (`ic-conflict-path-dependent`).

No existing path-sensitive check was changed.

## Callable-parameter inference

**Q15. Can calling an untyped parameter infer that it is callable? Yes. Q16.
Arity? Yes** (every call site must agree; otherwise no contract,
`ic-callable-arity`). **Q17. Argument types from actual call arguments?
Yes**, when concrete. **Q18. Result type from result consumption? Yes. Q19.
Allowed errors from the surrounding error context? Yes. Q20. Does any of
this infer a code target? No** -- the result is an ordinary structural `Fn`,
the call keeps no `target` and stays `callvalue` (`ic-callable-no-target`),
and nothing records which callables reach the parameter.

The contract is inferred only when the parameter does not **escape**: every
use is as a callee, an alias, or an argument to a position whose own
contract is a function type (a declared `Fn` parameter, or another untyped
parameter that itself ends up with an inferred `Fn` -- decided
optimistically, so mutually recursive higher-order functions infer each
other's contracts, `ic-mutual-recursion-callable`, then retracted where the
target did not end up with one). A parameter that flows into a List, a
native, an untyped position or a return value may be called by an unknown
party with unknown arguments, so it keeps `any` (`ic-callable-escape`).

The inferred type is **trusted**: the body's calls through it are typed
from it (result type, declared errors), so it is seeded, part of the
exact Block's structural contract, precondition-bearing for the escape
audit (`ic-trusted-bearing`), and every caller must prove it -- an `any`
argument included (`ic-callable-unknown-rejected`).

### Callable argument requirements

The contract's `args` are the static types of the actual arguments, joined
over call sites: the body promises the callable nothing but those values.
Variance is the existing structural rule (item 18): a candidate is
compatible when *its* parameter admits the contract's argument -- a native
(arguments `any`), an untyped Block, a `str`-declared Block and a capturing
closure all satisfy `Fn{args: [str], ...}` (`ic-callable-accepts`), an
`int`-declared Block does not (`ic-callable-variance`). `pred_use(p): if
p("x")` infers `Fn{args: [str], return: bool, errors: []}`
(`ic-callable-parameter`).

### Callable return requirements

The meet of every requirement on the call's result: an `if` condition
(`bool`, the ordinary condition rule), an argument position, a declared
result, or an alias's uses. Unconstrained results leave `return: any`
(`ic-callable-return-unconstrained`). A candidate returning a non-`bool`
into `if p(...)` is rejected statically (`ic-callable-return`).

### Callable error requirements

`errors` is the intersection over call sites of what each context admits:
the `on` handlers of a `handle` directly around the call plus the enclosing
function's own declared errors -- never what current arguments happen to
declare (item 22). It is an upper bound (item 21): a callable raising fewer
errors is compatible.

- error-free context -> `errors: []`; a `NotFound`-declaring callable is
  rejected (`ic-callable-errors-empty`);
- inside `fn use(p) -> int errors NotFound` -> `errors: [NotFound]`; a
  `NotFound` callable is accepted and its error propagates to the caller's
  handler on every backend (`ic-callable-errors-declared`);
- a `handle` with `on NotFound` around the call admits `NotFound`
  (`ic-callable-errors-handled`);
- a callable declaring `NotFound, PermissionDenied` into a context admitting
  `[NotFound]` is rejected (`ic-callable-errors-extra-rejected`);
- two call sites admitting different sets meet by intersection
  (`ic-callable-errors-meet`).

Static error checking is not weakened: the charged `calleeErrors` of a
call through the parameter are exactly the inferred errors, checked by the
existing `hir::errorsets`/`hir::completions` passes.

## Relational/generic constraints

**The stop rule (items 27-29, 88).** `predicate(x)` imposes "`predicate`
accepts `x`". When `x`'s type is concrete (a scalar, refined or named type,
or a `List`/`ImmutableSet` of one), that is an argument type. When it is
`any` -- or an aggregate or callable with unknown parts -- the relationship
is **relational**: `x`'s real type depends on the caller (the element type
of a caller-supplied List, a caller-supplied accumulator), and no current
type can express it. The implementation then infers **no `Fn` at all**, even
when the result requirement is known: no `Fn{args: [any], ...}` (which would
reject a valid `str -> bool` predicate for a `List[str]`), and no half-`Fn`.
The parameter keeps `any`, and the reason is recorded
(`paramNotes`: `relational`).

**Q36. Does the unknown element type mean "literally any possible value" or
"a relational type variable"?** In these helpers, the latter. The current
language cannot tell the two apart from the type alone (both are `any`), so
**Q37** -- the implementation never treats an `any` argument as a concrete
argument type: every `any` is conservatively relational. It can miss an
inference where `any` genuinely meant "any value"; it can never mis-type a
generic helper.

## Why list helpers remain partly untyped

**Q34. What does body inference discover about `list::all?`'s predicate?**
Everything except its argument type: it is called with one argument, its
result is an `if` condition (`bool`), the call admits no errors, and it
does not escape. `xs` itself infers `list` (the loop iterable, checked).

**Q35. Why can't it produce a complete structural `Fn`?** The argument is
`x`, the element of `xs`, whose type is the caller's List element type:
`predicate : Fn{args: [T], return: bool}` with `T = element(xs)` needs a type
variable. That is the item-88 stop condition; no type variable was
invented.

**Q38. Which helpers remain untyped for this reason?** `list::any?`,
`list::all?`, `list::none?`, `list::find` (predicate relational, `xs :
list`), and `hashtable.bot`'s `ht_fold(combine)` (called with the
caller-supplied accumulator and table values). Checked-only predicates
still pass through them: `list::all?(["a", "b"], one?)` with `one?(c):
length(c) == 1` is valid (`ic-checked-not-bearing`).

**`scan_while` vs `list::all?` (item 57).** `scan_while` calls its predicate
with `char_at(i)`, whose type is intrinsic -- `char_at`'s result is
`substring`'s registered `-result-type` `str`, whatever the caller passes --
so its contract is concrete and complete. `list::all?` calls its predicate
with an element of its own parameter `xs`, whose element type exists only at
each call site. This is the boundary of the current non-generic type
system: a body can fix its callable's argument types only when it
manufactures the arguments itself.

## Fixed-point algorithm

`hir::signatures::Solve` treats the collected requirements as a system of
inequalities over parameter contracts: constant requirements, edges
(`x ⊑ contract(g.i)`), and callable constraints. Every parameter starts
unconstrained (top); each sweep recomputes every contract, in sorted
`BindingId` order, as the meet of its requirements under the current
contracts of the others, until nothing changes -- the greatest solution,
which is unique, so the result does not depend on definition or traversal
order (`ic-order-independent`, `ic-deterministic`; `h(z)/g(y)/f(x)` defined
forwards and backwards give identical signatures, all `str`,
`ic-multi-hop`).

Trusted contracts change the body's typing (they are seeded), so an outer
loop re-types (`hir::types::infer`) and re-collects whenever a trusted
contract changed, meeting each round's trusted contracts with the previous
round's. In the corpus, every program with no trusted contract converges in
one typing round, and the ones with one (`scan_while`, through
`uri-steady`'s module load or the native backend's `emailish?` bridge) in
two.

**Q7. How is recursion handled?** Self- and mutual recursion are ordinary
edges between parameters in the same system; the fixed point starts at
top, so an SCC with no concrete requirement stays `any`
(`ic-recursive-scc-unconstrained`), and a requirement entering it
propagates around it (`ic-mutual-recursion`: `even?`/`odd?` both infer `n :
int`).

## Termination / monotonicity

**Q8. Why does the algorithm terminate?** Every requirement type is drawn
from a finite set -- declared types, native parameter types, `bool`/`list`/
`int`, and first-order `Fn` types over concrete argument types (a callable
argument is never itself concrete, which bounds `Fn` nesting; returns are
cut by the existing aggregate depth bound). Every constraint is monotone in
the contracts it reads and a contract only ever moves down by meet, so the
inner sweeps reach a fixed point after finitely many descents. The
optimistic callable-escape candidate set only shrinks. The outer rounds are
monotone by construction (each round's trusted contracts are met with the
previous round's). Both loops have hard guards (`maxSweeps`, `maxRounds`)
that raise a compiler error rather than widen silently; no program in the
test suite or corpus approaches them. No widening beyond the existing
aggregate bound was needed.

Parameter contracts only move from less to more constrained (item 33).

## Intrinsic signature representation

One authoritative object per block (item 35), recorded on the block node by
`hir::signatures::Install` and read through three queries:

| field / query | content |
|---|---|
| `declaredParamTypes` (unchanged) | explicit annotations |
| `inferredParamTypes` | trusted inferred contract per parameter (`""` if none) |
| `checkedParamTypes` | full inferred requirement per parameter (`""` if none beyond the trusted part) |
| `paramRequirements` | provenance records per parameter |
| `paramNotes` | why a called parameter got no `Fn` (relational / escapes / arity) |
| `hir::signatures::entryTypes` | declared, else trusted inferred, else `""`: what the body is entered with and every call must prove |
| `hir::signatures::of` | the whole signature: params (declared / trusted / checked / source / why), result, declared errors |

Every consumer that used to read `declaredParamTypes` for these semantics
now reads `entryTypes`: `hir::types::Block` (seeding), `BlockContract`
(exact Block contract, hence `structuralOf`), `hir::range::VerifyCall`,
`hir::callables` (`Bearing`, `ArgContexts`), `hir::specialize` (`Analyze`,
`Reanalyze`), `hir::moduleSignatures`. No second signature is computed
anywhere.

**Future `context` (item 65).** A context requirement would be one more
sink/constraint kind in `Collect` and one more field in `Contract`/`Add`,
beside args/return/errors, and one more named field in `MakeFn`, exactly as
`STRUCTURAL-FUNCTION-TYPES.md` already planned -- no restructuring.

## Trusted and checked requirements (the one deliberate deviation)

The brief asks for two things that, together with "canonical sources
unchanged" and "full regression passes", cannot all hold in the current
non-generic type system:

- item 71: an argument of static type `any` passed to an inferred contract
  must be a compile-time error;
- item 36: `local_char?`'s exact Block must expose `Fn{args: [str], ...}`.

Both were implemented as variants and measured
(`audit/intrinsic-function-contracts/out/variant-*.{patch,txt}`):

- **every inferred requirement treated exactly like a declaration** (seeded,
  structural, bearing, `any` rejected): **10 of 31 canonical programs are
  rejected, including 4 of the 8 canonical benchmarks**: `lex-strategy`
  (`classifier(c)` and `valid_chars(list_get(tokens, i), ...)`),
  `source-checks` (`list::find(candidates, invalid_name?)` is an erasure of
  a now-bearing callable into a relational helper), `test-selection` (four
  sites, e.g. `test_name(found)` with `found` from `list::find`),
  `uri-steady` (`hex_pair(list_get(bytes, i))`), and `csv*`, `hashtable`,
  `matmul`. Not one is a real type error (every such program runs correctly
  on every backend); every one is an argument of static type `any` because
  it comes out of an untyped aggregate (a List element, a positional
  `[a, b]` record, a MutableArray slot) or a generic helper's result, or a
  callable erased into a helper whose predicate type needs a type variable:
  the generics boundary.
- **only exposing checked requirements in exact Block `Fn` types**: exactly
  one rejection, `bench/lex-strategy.bot:57:20` `classifier(c)`:
  `is_tcl_alnum ⊔ lenient_ident_char?` becomes `Fn{args: [str], ...}`, and
  `c` is an element of `chars_of(...)`'s result, which returns its caller's
  accumulator -- a relational type.

Rejecting these would mean "rejecting a program whose only fault is a
missing type variable", which the stop conditions (items 88-90) direct not
to solve here. So requirements are classified by what the body does with
them:

| | TRUSTED | CHECKED |
|---|---|---|
| sources | declared callee parameters, `Fn` arguments, declared result positions, a called parameter's own `Fn` contract | native `-param-types`, `if` conditions, loop iterables/bounds (all re-validated at run time) |
| body seeded with it | yes (like a declaration) | no (the body keeps the native's own check) |
| part of the exact Block's structural `Fn` | yes | no -- exactly like a native's own `-param-types` |
| precondition-bearing (escape audit) | yes | no |
| caller with argument of known inadmissible type | compile-time error | compile-time error |
| caller with argument of static type `any` | compile-time error (item 71 holds) | accepted; reaches the native's own run-time check (no guard inserted) |

This is the smallest existing conservative behavior (item 89): the
wrapper inherits exactly the status its native already has in
`STRUCTURAL-FUNCTION-TYPES.md` ("a native's -param-types are run-time-checked
requirements, never static proof obligations"), plus the new static
rejection of every provably wrong argument. It is sound by construction: a
checked requirement is never assumed by any compiled body, and a trusted one
is enforced wherever a declaration would be. Consequences:

- `local_char?`'s exact Block keeps the canonical structural supertype
  `Fn{args: [any], return: bool, errors: []}` -- and is, by contravariance,
  also a subtype of `Fn{args: [str], return: bool, errors: []}`, which is
  exactly what `scan_while`'s inferred predicate contract requires of it.
- `-strict 0` builds (the core-IR compile path, whose diagnostics become AOT
  blockers rather than errors) must not compile a body assuming a trusted
  contract its own program violates: `hir::check` re-types with violated
  trusted inferred contracts demoted to checked-only, keeping the original
  diagnostics, so interp and compile still agree
  (`ic-strict0-recovery`).

## Exact Block integration

`BlockContract` builds the exact Block's fifth element from `entryTypes`, so
a function with a *trusted* inferred contract carries it in its exact type,
like a declared one: `scan_while`'s exact type is `block(e211)/2 -> int` with
structural supertype `Fn{args: [any, Fn{args: [str], return: bool, errors:
[]}], return: int, errors: []}` (was `Fn{args: [any, any], ...}`), and a
forwarder to `take_byte(b: Byte)` exposes `Fn{args: [int[Byte]], ...}`
(`ic-exact-block-trusted-contract`). Exact Block code identity is unchanged
(`show` never prints the contract). A checked-only contract does not enter
the exact type (see above).

## Structural Fn integration

The end product of callable inference is an ordinary `MakeFn` value; no new
callable-contract format exists (item 64). `FnLub`, `FnSubtype`,
`explainMismatch`, `VerifyStructuralCall` and the escape audit apply to it
unchanged. The scanner's two actual predicates, `local_char?` (Block) and
`is_tcl_alpha` (native), both expose `Fn{args: [any], return: bool, errors:
[]}` and both satisfy `scan_while`'s inferred `Fn{args: [str], return: bool,
errors: []}` (item 37); their join would be `Fn{args: [any], return: bool,
errors: []}`.

## Result-type precision

**Q39. Why did created Blocks become `return: any` in used instance
views?** Not for the reason item 34 suspected (intrinsic parameter contracts
were not involved): `hir::types::Block`'s region-inference branch -- the
one specialization uses whenever an instance creates a Block -- returned
`blockType $hir $e $arity any` unconditionally, discarding the result type
semantic inference had already proven for that block. Calls of an exact
Block ask the specialization handler for their instance result anyway, so
this only mattered where the exact type was *joined* (`FnLub`'s return) or
reached a structural view -- exactly the `lex-strategy`/`source-checks`
sites.

**Q40. Is that fixed? Yes.** The branch now returns the block's own
intrinsic result contract (its declared result, else its semantic
`resultType`): a sound upper bound for every instance, because the
semantic body was typed under the creation's source-level facts, of which
every instance's are a narrowing.

**Q41. Does `lex-strategy`'s instance-level classifier contract retain
`bool`? Yes**: `choose_classifier<bool>`'s result and `classify<str,
bool>`'s callee are `Fn{args: [any], return: bool, errors: []}` (was
`return: any`); `classifier(c)` is `bool` there (was `any`), and
`classify<str, bool>`'s result is `List[bool]` (was `list`).

**Q42. Does `source-checks` retain `bool` in its used structural callable
view? Yes**: `classify_leading<generic>`'s `check` is `Fn{args: [any],
return: bool, errors: []}` and `check(c)` is `bool` (was `return: any` /
`any`); the instance result is `List[bool]` (was `list`).
`test-selection`'s `make_changed?<List[str]>` result is `block(e55)/1 ->
bool` (was `-> any`).

`ic-result-bool-preserved` pins all four views for a body-inferred `bool`:
exact Block type, `structuralOf`, the join in the used instance, and the
call result there.

## scan_while before/after

Source (unchanged, `lib/web.bot:126`):

```
fn scan_while(start, predicate):
    loop i from start to n:
        if predicate(char_at(i)):
            continue
        return i
    n
```

| | before | after |
|---|---|---|
| `start` | `any` | `int` (checked) -- the counted loop's start, 127:21 |
| `predicate` (Q21/Q22) | `any` | `Fn{args: [str], return: bool, errors: []}` (trusted) |
| `predicate(char_at(i))` result (Q24) | `any` | `bool` (source and instance) |
| call error contract | none (untyped: charged nothing) | `[]` (charged `[]`) |
| call form (Q25) | `callvalue` | `callvalue` |
| instance `scan_while<generic>` AOT (Q26) | **open**: `DynamicCall`, `UnknownCallResultKind` | **closed** |
| `tld?`, `domain?`, `web::emailish?<str>` | closed, transitively open | closed, transitively closed |
| instance label | `scan_while<generic>` | `scan_while<generic>` |
| generated code | `guardbool` on the call's result | no guard: the result is proven `bool` (-32 bytes) |

**Q23. Which body expressions caused each part?** `args: [str]`: the single
call `predicate(char_at(i))` at 128:16 passes `char_at(i)` (128:26), whose
type is `str` because `char_at`'s own body returns `substring(...)`
(registered `-result-type str`) -- not because of any caller. `return:
bool`: that call is the condition of the `if` at 128:13. `errors: []`:
`scan_while` declares no errors and no `handle` surrounds the call. The
parameter has no other use, so it does not escape. **Q27. Does any
target identity enter the function type? No** -- the callers
(`local_char?`, `is_tcl_alpha`) were never consulted; they are only
*checked* against the contract (both pass, and every existing caller of every
inferred function in the corpus does -- item 41: no newly exposed static
error and no inference bug surfaced).

Source/intrinsic, instance and use-site views agree (item 39): intrinsic
`predicate : Fn{args: [str], return: bool, errors: []}`; the instance region
reports its *key* types (`start : any, predicate : any`, the unchanged
`KeyType` projection), while the instance body is entered with the trusted
contract (M1), so the callee expression at the use is `Fn{args: [str],
return: bool, errors: []}` in both refined-checks and uri-steady.

## local_char? before/after

```
fn local_char?(c):
    is_tcl_alnum(c) or immutable_set_contains(local_extra_chars, c)
```

| | before | after |
|---|---|---|
| `c` (Q28) | `any` | `str` (checked) |
| requirement from `is_tcl_alnum(c)` (Q29) | -- | `str` (registry `-param-types str`, 100:22) |
| requirement from set membership (Q30) | -- | none: `immutable_set_contains` is `{immutableSet any}`, and after `is_tcl_alnum(c)` returned, `c` is already `str` by flow |
| meet (Q31) | -- | `str` |
| return | `bool` | `bool` |
| exact Block structural supertype (Q32) | `Fn{args: [any], return: bool, errors: []}` | unchanged: `str` is checked (re-validated by `is_tcl_alnum`), so it stays out of the structural type like the native's own `-param-types`; the Block is a subtype of `Fn{args: [str], return: bool, errors: []}` by contravariance |
| instance | `local_char?<generic>`, guarded | unchanged (the checked contract is not seeded; its `is_tcl_alnum` guard remains -- the caller-ingress milestone's job) |

The result is the plain `str` domain, not a one-scalar refinement:
`is_tcl_alnum` requires `str`, and nothing in its metadata says "one
scalar". The source was not changed to `Char`.

## is_label_char? before/after

The real source spells it `label_char?` (R2.a.2 renamed the helpers):

```
fn label_char?(c):
    is_tcl_alnum(c) or c == "-"
```

(Q33) Before `any`, after `str` (checked) from `is_tcl_alnum(c)` (108:22);
`==` requires nothing (`{any any}`); meet `str`; return `bool`; exact Block
structural supertype unchanged `Fn{args: [any], return: bool, errors: []}`;
instance `label_char?<str>` closed before and after.

## Corpus-wide inferred-parameter census

`audit/intrinsic-function-contracts/out/census.txt` (totals) and
`params.txt` (every parameter with its contract and provenance): 31
canonical programs, 201 distinct function definitions, 372 parameters, of
which 9 declared and **363 untyped and inspected (Q43)**.

| outcome | count |
|---|---:|
| narrowed, checked (Q44) | 313 |
| narrowed, structural `Fn` (Q46) | 1 (`scan_while`'s predicate) |
| narrowed, trusted non-`Fn` | 0 |
| **any**: no requirement (Q45) | 44 |
| **any**: relational callable constraint (Q47) | 5 (`list::any?/all?/none?/find`'s predicate, `ht_fold`'s `combine`) |
| conflicting requirements (Q48) | 0 |

So **314 of 363 narrowed (86.5%)** and 49 remain `any`. By type: `int` 136,
`str` 69, `list` 54, `mutarray` 45, `bool` 9, `Fn{args: [str], return:
bool, errors: []}` 1. The 44 unconstrained parameters are values only
compared with `==`, tested for set membership, stored, or returned
(`is_underscore?`, `changed?`, hash-table keys and values, accumulators).
Before this milestone every one of the 363 was `any`.

**Q49. Which real functions gained the most useful precision?**
`scan_while` (its predicate contract types the corpus's hottest indirect
call and closes its AOT region), `web::emailish?(v)` and its helpers
(`char_at(i)`, `tld?(i)`, `domain?(start)`: `str`/`int`), the CSV and
hash-table helpers (`table : mutarray`, indices `int`, fields `str`), and
`choose_classifier(strict_mode) : bool`.

## Any/bare/Fn callable-site census before/after

`out/callsites-{before,after}.txt`, relifted pipeline, callee type in the
used instance (Q50):

| site | before | after |
|---|---|---|
| `list::all?@e18` (lex-strategy) | bare native | bare native |
| `classify@e119` (lex-strategy) | Fn (return any) | Fn (return **bool**) |
| `scan_while@e216` (refined-checks) | **any** | **Fn{args: [str], return: bool, errors: []}** |
| `list::find@e42` (source-checks) | bare block | bare block |
| `classify_leading@e91` (source-checks) | Fn (return any) | Fn (return **bool**) |
| `list::any?@e6` (test-selection) | bare block | bare block |
| `list::none?@e31` (test-selection) | bare block | bare block |
| `list::find@e42` (test-selection) | bare block | bare block |
| `scan_while@e216` (uri-steady) | **any** | **Fn{args: [str], return: bool, errors: []}** |
| **totals** | Fn 2, bare 5, any 2 | **Fn 4, bare 5, any 0** |

**Q51. Do the two scanner sites remain `any`? No.** **Q52. Does the static
`callvalue` count change? No**: 9 before, 9 after, the identical sites
(item 50: the scanner call, the List element call, the if-selected
classifier and the generic helpers all remain `callvalue`). No incidental
exact call appeared (item 51). **Q53. Does dynamic behavior change?** Only
for programs that were statically violating a newly inferred contract,
which are now rejected at compile time; every canonical program computes
the same values on every backend.

## Diagnostics

Conflicts (item 47) name the parameter, both requirements and both source
uses (see "Meet"). Newly rejected callers (item 48) use the ordinary
argument diagnostic, extended with the inferred contract and its
provenance:

```
t.bot:6:9: argument for parameter "x" is statically incompatible with str,
the parameter type inferred from the function body (argument type: int,
facts: [123, 123] {123}); inferred from the function body: argument 1 of
native length requires str (at 5:12)

t.bot:4:3: argument for parameter "x" cannot be proven to satisfy int[Byte],
the parameter type inferred from the function body (argument type: int,
facts: [700, 700] {700}); inferred from the function body: the declared
result type of f requires int[Byte] (at 3:5)
```

A rejected callable argument keeps `explainMismatch`'s clause ("argument 1
is incompatible: the callable's parameter requires int, but callers of the
function type may pass any str", "return incompatible: ...", "error set
incompatible: ...").

## Semantic strengthening for native wrappers

```
fn wrapper(x):
    length(x)
wrapper(123)
```

- **before**: accepted; `wrapper` runs, and `length` raises its run-time
  `TYPE` error (`length: expected str, got 123`);
- **after**: rejected at compile time at the call (the first diagnostic
  above). This is intentional body-derived contract inference: `wrapper`'s
  body proves it can only ever succeed on a `str`.

Direct native calls are unchanged (`length(123)` is still the run-time
error, `ic-native-direct-unchanged`), and so is a wrapper call whose
argument's static type is `any` (it reaches `length`'s own check,
`ic-native-wrapper-any-argument`). Where no strict HIR build runs (core IR
on interp; the compile backend's `-strict 0`), the old run-time behavior is
what still happens, identically on both (`ic-native-wrapper-before`).
Updated existing expectations: `stdlib-string_reverse-not-a-string`
(`reverse_chars(12)` is now static; the run-time case is kept with an
argument of unknown type), `opt-tail-7` (its `concat(acc, n)` with `n : int`
is now a static conflict, `opt-tail-7-static`; the run-time error path is
kept through an opaque Int).

## Specialization-key invariance

`KeyType` is unchanged, and no inferred type, contract or callable identity
enters a key (item 62). Used instance labels of all 8 canonical benchmarks
are identical before and after except one: `lex-strategy`'s
`count_true<list, int, int>` is now `count_true<List[bool], int, int>`.
That is the result-precision fix, not a contract: `classify<str, bool>`'s
instance result is now `List[bool]` (was `list`), and the unchanged
`KeyType` projects that argument as it always projected a `List[bool]`. The
instance count is unchanged (11), and the key never names a callable.
`ic-keys-unchanged` pins that a scanner called with a native and with a
Block keeps its two kind-keyed instances (`scan<native, int>`,
`scan<block, int>`), both of whose bodies see the inferred `Fn` contract.

## Generated code

Generated code changed only where the new types unlock an existing
optimization -- no target form changed, no devirtualization (item 76):

| program | change | cause |
|---|---|---|
| refined-checks, uri-steady | `guardbool` at `@e215` removed (scan_while's `if predicate(...)`) | trusted contract: the call result is `bool` |
| lex-strategy | `guardbool` at `@e134` removed (`count_true`'s `if list_get(flags, i)`); key above | instance result precision (`List[bool]`) |
| source-checks | `guardbool` at `@e100`, `@e106` removed (`valid_start?`'s `list_get(flags, 0) or list_get(flags, 2)`) | instance result precision (`List[bool]`) |

The focused machine audit (`native/generate-scalar-audit.tcl` regenerated
and diffed against the committed corpus): every `.asm`/`.vcode`/summary is
byte-identical except `bench/refined-checks`: `scan_while`
(`botlish_fn_13`) shrinks from 528 to 496 bytes (8935 -> 8903 for the
program), `rt_*` helper calls 44 -> 43, guards 2 -> 1 -- the removed
`rt_not_boolean` check and its failure path. In the natural refined-checks
run that guard executed once per predicate call: 8,000 times
(POST-STRUCTURAL-FN-DYNAMIC-CENSUS.md's S3). The committed corpus is not
edited here: `.github/workflows/scalar-asm-audit.yml` regenerates it when
this lands on `main`, and it will record exactly this diff. No runtime,
representation, root or allocation code changed, so GC stress was not
required (item 77).

## Full regression

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
```

with the native backend built (`cargo build --release`, rustc 1.98.1):

- before (parent commit `67380f4`): interp **2718/2718**, compile
  **2718/2718**, 93 test files;
- after: interp **Total 2779, Passed 2779, Skipped 0, Failed 0**, compile
  **Total 2779, Passed 2779, Skipped 0, Failed 0**, **94** test files: the new
  `tests/intrinsic-contracts.test` (58 cases) plus `opt-tail-7-static`,
  `fn-accept-untyped-forwarder` and `stdlib-string_reverse-not-a-string-
  static`.

Four pre-existing expectations changed on purpose, each still pinning its
original concern alongside the new behavior: `opt-tail-7`,
`fn-reject-any-is-not-fn` (an `any` value is still not callable; the
forwarder case is now `fn-accept-untyped-forwarder`),
`callable-escape-capture-untyped-wrapper-rejected` (the wrapper is now
valid exactly when its callers prove `Byte`), and
`stdlib-string_reverse-not-a-string`.

Compile time (item 61; `out/compiletime-*.txt`, median of 7, front end
only): 977 ms -> 1121 ms total over the 17 canonical benchmark and stdlib
programs (+15%): one requirement walk and solve per build, and a second
typing round only where a trusted contract exists.

## Benchmark parity

`tclsh9.0 bench/bench.tcl -runs 1` with the native backend available: exit
0, no `VALUES DIFFER` on any of the 8 canonical programs (interp, compile
and Cranelift agree). Canonical sources are unchanged, and
`web::emailish?` was not refactored.

## Known limitations

- **Checked requirements accept `any` arguments** (see the deviation
  section): the strict reading of item 71 needs type variables to be
  compatible with the canonical corpus. Every known-typed incompatible
  argument is rejected.
- **Checked requirements are not structural and not seeded**: `local_char?`
  keeps `Fn{args: [any], ...}` and its instance keeps the `is_tcl_alnum`
  argument guard. Removing that guard needs either a trusted contract
  (generics, to keep the corpus valid) or caller-ingress facts.
- **Relational callable parameters stay `any`**: the list helpers and
  `ht_fold` (item 88's stop condition, deliberately not solved).
- **No union types**: two uses separated by a type test of the parameter
  constrain nothing; two incompatible uses otherwise are a conflict error,
  even when an unrelated flag keeps them on different paths.
- **No aggregate provenance**: requirements on `list_get(xs, i)` or on loop
  elements are not pushed back into `xs`.
- **Escaping callables get no contract**: a parameter both called and
  stored/returned/passed to an untyped position keeps `any`.
- **Arity**: calls with two different arities infer nothing.
- **HIR text**: `hir::format` does not print inferred contracts; `hir::read`
  keeps every expression's printed type but recovers an exact Block's
  contract from declarations only.
- **Backend-specific bridge HIR**: on the native backend a module-bridged
  native (`emailish?` -> `web::emailish?`) is typed as its module function,
  so its inferred contract, not the native's `-param-types`, constrains its
  callers there; both say `str` for every canonical case.

## Remaining need for caller-ingress refinement

The remaining callable opacity now divides cleanly (item 92.20):

1. **Intrinsic contract known** -- this milestone: `scan_while`'s
   predicate, every checked parameter contract.
2. **Caller/instance refinement still missing**: `local_char?(c)`'s body
   still guards `is_tcl_alnum(c)` although every caller passes a `str`;
   `list::all?`'s instance still sees a bare `native`/`block` predicate
   although each instance's callers pass one exact callable; checked
   contracts are not seeded because only callers can prove them. That is
   the next milestone's caller-ingress refinement, which can now start from
   the intrinsic contract instead of from `any`.
3. **Code target identity still missing** -- below.

## Remaining need for finite codeTargets

No call became direct: all 9 canonical `callvalue` sites remain, now with
known contracts at the scanner and join sites. Which of `{local_char?,
is_tcl_alpha}` a `scan_while` call dispatches to is a code-target fact,
deliberately not tracked (item 91). The contract fixes what every target
must satisfy; a finite target set would refine it without changing any
static check, exactly as `STRUCTURAL-FUNCTION-TYPES.md`'s readiness section
anticipated.

## Required question index

Architecture Q1-Q9: "Previous untyped-parameter semantics", "Intrinsic
contract definition", "Explicit annotation boundary", "Immutable alias
propagation", "Meet", "Fixed-point algorithm", "Termination". Native Q10-Q14:
"Native admissibility requirements". Callable Q15-Q20: "Callable-parameter
inference". Scanner Q21-Q27: "scan_while before/after". Local predicates
Q28-Q33: "local_char?" / "is_label_char?". Generic helpers Q34-Q38:
"Relational/generic constraints", "Why list helpers remain partly untyped".
Result inference Q39-Q42: "Result-type precision". Corpus Q43-Q49:
"Corpus-wide inferred-parameter census". Callable census Q50-Q53: "Any/bare/Fn
callable-site census".
