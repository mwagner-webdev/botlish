# M7.a: instance-selection and theorem-semantics audit

Audit only. No production compiler, runtime, library, or frozen workload
file was changed by this milestone. Everything below was observed with
non-production tooling committed under
`audit/m7a-instance-selection/` (see "Audit tooling and artifacts" at the
end), or read directly from the current source.

## Outcome

1. **What an instance is today is small and precise.** An instance is
   `{block, one KeyType per parameter}`. A KeyType is the argument's
   runtime *kind*, plus a List's element kind (recursively, depth ≤ 3) and
   occasionally a positional shape. No value fact, range, exact set, named
   evidence, callable target, capture value, container content or
   completion fact is part of identity. There are three identity-policy
   rules on top of that: the per-block limit (8), self-tail widening, and
   *value-capturing closures with a non-Int capture are forced to the
   generic key*.

2. **Every current ConditionOutcome decision derives from entry, path,
   declared or evidence facts, never from instance identity.** Across the
   frozen corpus and 38 synthetic scenarios, the "identity" fact tier
   (what the key alone proves) decided zero conditions. KeyType erases all
   integer evidence, so identity only *partitions* callers. The facts
   come from the declared-parameter theorem (M1), RefineParams evidence,
   capture seed types, joined entry Ranges, native `-result-range`
   metadata, and path narrowing.

3. **RC1 / "family 1b" is not one problem.** Every remaining guard in
   `uri-steady` (14) and `refined-checks` (24) is a *kind* check on a
   parameter of a generic instance. None of them is a range guard. The
   kind fact they need *is* proven at every exact call site for 9 of 14
   (`uri-steady`) and 14 of 24 (`refined-checks`) guards directly, and
   for most of the rest one or two call levels up. It is lost to the
   following mechanisms, not to one:
   - (a) the closure KeyType policy;
   - (b) `OpenInstances` treating "materialized per `hir::aot`" as "open",
     even where `hir::blockescape` later proves no Block value exists at
     run time;
   - (c) cascades from generic callers;
   - (d) unknown callee *result* kinds;
   - (e) a dead materialized `fnvalue`.

   The old label "instance selection ignores proven parameter facts"
   should be retired.

4. **The obvious fix, making value-capturing closures specialize by
   argument kind (1b as originally proposed), is a measured regression.**
   Counterfactual measurement (in-process only):
   - `uri-steady`: +10 instances, +27% machine code, and Block allocations
     from 1 to **8001** per run.
   - `refined-checks`: +21 instances, +14.5% code, Block allocations 2 → 6.
   - Cause: `hir::blockescape::SingleInstance` declines de-closure
     conversion as soon as a nested closure has two non-generic
     instances, and the always-analyzed materialized generic enclosing
     instance creates exactly that.
   - This is an accidental dependency: block virtualization currently
     *relies on* the closure specialization policy.
   - **REJECT naive closure-kind identity.** Family 1b belongs to a
     dedicated later milestone built on a *closedness* theorem plus an
     *entry-kind* theorem (no identity growth), specified below.

5. **The M6 `Narrowed` mechanism encodes a real theorem, "this branch
   hypothesis is unsatisfiable", as an out-of-lattice Range value.** It
   is not read by one consumer (as M6 believed) but by two:
   `hir::range::ConditionOutcome` (codegen) and
   `hir::completions::FactsContradictory` (static legality, pre-M6).
   - The two consumers already disagree on `==`. For a `HighNibble` `h`,
     codegen proves `h == 17` impossible, while the legality layer still
     reports `effectiveErrors={Bad}` and rejects the program with
     UNHANDLED-ERROR.
   - The encoding also silently discards exact-set impossibility.
   - It stores genuinely empty Ranges into the per-instance table for
     dead-branch expressions. "Stored Ranges are never bottom" is false
     today.
   - An impossible `==` hypothesis stores a plausible-looking point that
     then *widens* post-`if` facts.
   - Recommendation: **REFINE**. Make satisfiability an explicit,
     strength-preserving query with one owner in M7.b. Defer every
     strength change (each one changes codegen facts or legality).

6. **Two latent correctness-adjacent defects were found in passing** (not
   fixed; out of M7.a scope):
   - `encode_utf8`'s typed result is the non-canonical static type
     `{list Byte}`. The declared `List[Byte]` resolves to
     `{list {refined int Byte}}`. List admissibility is string equality,
     so passing `encode_utf8(...)` to a `List[Byte]` parameter is rejected
     with a self-contradictory message ("cannot be proven to satisfy
     List[int[Byte]] (argument type: List[int[Byte]])").
   - Specialization *loses* a declared aggregate parameter's element
     evidence. `f(xs: List[Byte])` has view `List[int]` in `f<List[int]>`
     but `List[Byte]` in `f<generic>`, so the specialized instance knows
     less than the generic one. This is M1's theorem not reaching
     aggregate keys.

7. **Several existing tests observe rejected programs or are vacuous.**
   - M4's `setfromlist-empty-list-stays-generic`, M5's
     `checked-domain-shared-instance-byte-set` and M6's
     `condition-outcome-12` compile *illegal* programs with `-strict 0`.
   - M5's `funcHeaderCount` helper returns `llength` of a `regexp -all`
     count, so it always returns 1. Both "one shared header" assertions
     are vacuous. The `byte::set` fixture actually has two `byte::set`
     headers.
   - The `-from-int` fixture is legal, but its "genuinely dynamic"
     caller is `dyn(45)`, so the shared entry is just `{45}`.
   - The soundness conclusions those tests were meant to support still
     hold: a legal twin with a genuinely open caller (S03b) was
     constructed here and reproduces them.

8. **Recommended M7.b is small:**
   - formalize hypothesis satisfiability (strength-preserving);
   - transport the declared aggregate parameter theorem (zero instance
     growth, zero corpus delta, measured);
   - regression-pin the identity semantics this audit judged intentional,
     including the explicit rejections;
   - repair the illegal/vacuous fixtures;
   - pin the blockescape/closure-policy coupling;
   - re-run the census.

   Everything else is deferred or rejected, with reasons.

## Executive semantic model

The compiler has six places where a fact about a parameter can live.
Only the first is instance identity.

| layer | what it holds today | who owns it | example |
|---|---|---|---|
| **identity** (`hir::specialize` key) | argument kinds; List element kinds; rarely a positional shape | `hir::specialize::KeyType` + `Handle` policy | `f<int>`, `g<List[never]>`, `apply<block, int>` |
| **instance entry** (valid for every caller of one instance) | declared parameter type (M1); RefineParams named evidence; joined entry Range; captured-binding seed types | `hir::specialize::Analyze` (types), `hir::range::analyze` (ranges) | `ascii::is_digit<int>`'s `b : int[Byte]`, entry `[0,255]` |
| **path** (inside one branch of one instance) | ComparisonNarrowing facts; hir type-test refinements | `hir::range::If`/`ComparisonNarrowing`; `hir::types::If`/`hir::refine` | inside `x >= 0`, `x` is `[0,+∞]` |
| **call edge** (one invocation, not the shared body) | `effectiveErrors`, `mayReturnNormally`, `resultRangeFact`, literal-list contents | `hir/completions.tcl` (+ `hir/errorsets.tcl`) | `byte::from_int(45)`: `effectiveErrors={}`, `[45,45]` |
| **result** | instance result type (lub fixpoint); instance result Range summary; native result metadata | `hir::specialize` (types), `hir::range` (`calleeResults`), `core/native.tcl` | `char::codepoint` → `[0,+∞]` |
| **expression** | KnownOutcome; ConditionOutcome; equality-totality; raw-representation eligibility | `hir::types`, `hir::range`, `native::lower` | `h == 17` AlwaysFalse |

The distinction M7.a was asked to protect, "a fact is useful" versus "a
fact should select an instance", is already respected by the code for
every *value* fact. The layers that need work are *transport* between
entry/call-edge/result layers and one *identity policy* (closures).
There is no case for adding value facts to identity.

## Definition of an instance today

Traced from source (`hir/specialize.tcl`), not from earlier reports.

```text
HIR block B (ExprId), or "program"
    |
call site (in instance I): argument static types T1..Tn from I's region inference
    |
hir::specialize::Handle call:
    keyArgs = [KeyType Ti]                               -- identity candidate
    if B is not a static block (captures a value):
        if !callFactsOpt or some capture seed is not Int-kinded:
            keyArgs = [any ...]                          -- closure policy (forced generic)
    if B == I's block and the call is a self tail call:
        if every keyArg <: I's own key: target = I       -- stays a loop
        else keyArgs = pointwise KeyType(lub(key, own))  -- widening
    target = Instance(B, keyArgs):
        generic if all keys are any
        if new, non-generic and (instances >= 1000 or live specializations of B >= 8):
            keyArgs = [any ...]                          -- explosion control (order-sensitive)
        key {B keyArgs} -> InstanceId (cache; ids in discovery order)
    |
hir::specialize::Analyze I:
    types[captured b] = seeds[B][b]                      -- lub over every creation of B
    types[param p]    = keyArg_p, then
        if declared(p) and keyArg_p not IsSpecific:
            declared is IsSpecific ? declared : narrow(keyArg_p, declared)   -- M1
    RefineParams: types[p] ∪= evidence every syntactic exact call proves (key base must exist)
    region inference (hir::types::inferRegion) -> overlay, calls, creates, result
    result(I) = lub(old, inferred) (declared result wins)
    |
hir::range::analyze (per used instance):
    entry Range per param: induction lock | self feedback (widen) | join of exact callers' arg Ranges
        (none for OpenInstances: generic ∧ block materialized)
    every ref: binding Range ∩ TypeFact(view type)       -- declared/evidence domains enter here
    |
native::lower: one canonical NIR function per *emitted* used instance
    (+ representation variants of the same instance: internal / companion / region / fields)
```

Data that determines identity, exactly: the block ExprId; `[KeyType Ti]`
after the closure policy, self-tail widening and the limit fallback;
and, through the limit, discovery order. Nothing else.

Two facts that are *not* identity but are sometimes mistaken for it:

- **Emitted NIR functions ≠ used instances.** `uri-steady` has 19 used
  instances but 17 emitted functions: tiny-leaf inlining absorbs
  `byte::nibble<int>` and `byte::high_nibble<generic>`.
- **Representation variants are not instances.** `internal`, `companion`,
  `region`, `fields` and `fieldscompanion` are extra NIR functions of one
  instance with a different ABI. They share the instance's facts. They
  multiply code, not identity.

## Current instance-key construction

`hir::specialize::KeyType` (unchanged since before M1):

```tcl
proc hir::specialize::KeyType {type} {
    if {[hir::types::IsList $type]} {          ;# List: recurse into the element (and shape)
        ...MakeList [KeyType elem] ?[KeyType positions]?...
    }
    set kind [hir::types::kindOf $type]         ;# everything else: kind only
    return [expr {$type eq "never" ? "never" : $kind eq "" ? "any" : $kind}]
}
```

`hir::types::kindOf` returns the first word of a "specific" form
(`native`, `block`, `list`, `immutableSet`), the core base kind for a
core/refined type, and `""` for `any`/`never`.

## KeyType preservation/erasure table

Produced by `tools/keytype.tcl` (`artifacts/keytype.txt`). The last column
is what an instance's parameter seed becomes when the *same* type is also
the declared parameter type (M1's rule, observed read-only).

| input static type | KeyType | declared type restored after selection? | sharing consequence |
|---|---|---|---|
| `int` | `int` | n/a | all Int callers share `f<int>`, any literal/range |
| `Byte` (`int[Byte]`) | `int` | yes (`int[Byte]`) | Byte and plain-Int callers share `f<int>` |
| `Small = Int in 10..20` | `int` | yes | shares with every Int caller |
| `HighNibble` (16-element exact set) | `int` | yes, including the exact set | shares with every Int caller |
| `bool`, `str`, `unit`, `UnicodeChar`, `result`, `mutarray` | same kind | n/a | one instance per kind |
| `str[UriQueryValue]` (opaque evidence) | `str` | yes; also via RefineParams if every exact call proves it | shares with every Str caller |
| broad `list` | `list` | n/a | |
| `List[int]` | `List[int]` | n/a | element kind is identity |
| `List[Byte]` | `List[int]` | **no**: stays `List[int]` (key is IsSpecific) | `List[Byte]` and `List[int]` callers share; **element evidence lost in the specialized instance** (S05d) |
| `List[never]` (`[]`) | `List[never]` | no | an empty-list caller gets its own instance (S05c) |
| positional `list[int, str]` | `list[int, str]` | no | heterogeneous shapes are identity (bounded: ≤ 8 positions, depth ≤ 3) |
| `List[List[Byte]]` | `List[List[int]]` | no | nested evidence erased |
| broad `immutableSet` | `immutableSet` | n/a | |
| `ImmutableSet[Byte]` | `immutableSet` | yes (declared set adopted: key not IsSpecific) | **element type erased from identity**; an undeclared set param sees only `immutableSet` (S06b: `setcontains`, not `setcontainstotal`) |
| `ImmutableSet[never]` | `immutableSet` | yes | empty set shares with every set (unlike `List[never]`) |
| exact block `{block e 1 T}` | `block` | exact form kept only if declared (never: callables cannot be declared) | **callable identity erased**; every callable argument shares `apply<block,…>` |
| exact native `{native +}` | `native` | | same |
| `any` | `any` | declared adopted (M1) | generic |
| `never` | `never` | stays `never` | only for dead calls (never analyzed) |

Three observations:

- **The erasure is uniform for values and inconsistent for aggregates.**
  Named integer evidence is erased at top level *and* inside List
  elements. The declaration restores it at top level (M1) but not inside
  a List key. ImmutableSet element types are erased entirely, yet
  restored from a declaration because the key is not "specific".
  `List[never]` is kept; `ImmutableSet[never]` is not.
- **None of the three is a soundness problem.** Each is a precision or
  consistency issue.
- **Only the List case loses a theorem the program declared.** That is
  why it is an M7.b candidate (see "Candidate M7.b theorem changes").

## Theorem taxonomy

Definitions follow the spec. Each current fact is placed with its
owner, representation and transport.

| theorem | scope | canonical owner / producer | representation | transported to | consumers |
|---|---|---|---|---|---|
| argument kind (incl. List element kind) | **identity** | `KeyType` on region-inferred arg types | instance key | view (param binding types) | region inference, aot blockers → guards, raw eligibility, opcode choice |
| declared parameter type (scalar or aggregate) | **entry** (every instance; M1) | declaration; proven per call by `verifyDeclaredParams` + `hir::callables` | seed type in `Analyze` | view; `hir::range` via `TypeFact` on refs | guards, ranges, ConditionOutcome, equality-total opcodes |
| RefineParams named evidence | **entry** | `RefinementFacts` (intersection over *all syntactic* exact calls) | seed type union | view | same as above (S04b: `x > 255` decided "via view") |
| joined entry Range | **entry** | `hir::range::analyze` caller fold | `params` Range per instance | refs, then every derived expression | ConditionOutcome, raw repr, ClosedResult, induction |
| captured-binding seed type | **capture** (joined over creations) | `hir::specialize::Handle create` | `seeds` | view types of capture refs | same as entry types (S08c: captured `Byte` decides `n > 255`) |
| captured-binding *range/value* | **capture** | **none** (missing) | — | — | — (S08a: `n` known `[1,2]` in `mk`, unknown in `add`) |
| callable exact identity (alias / capture / call result) | **expression/capture** | `hir::types` binding types (`{block E …}`) | static type | call `target` field | `native::lower::Call` → `call`/`callenv` |
| callable identity through an ordinary parameter | erased at **identity** | — | kind `block` | — | `callvalue` |
| Bearing obligation (typed params / declared errors) | **global** (escape legality) | `hir::callables::verify` | diagnostic | — | makes erasure positions illegal; underwrites M1 and completions' exact-target assumption |
| comparison narrowing | **path** | `hir::range::ComparisonNarrowing` | branch-local binding Range | refs inside the branch; JoinBindings after | ConditionOutcome, raw repr, completions |
| hypothesis unsatisfiable | **expression** (per branch outcome) | `hir::range::Narrowed` (implicit) | Range with `min > max` (out of lattice) | read by `IsEmpty` / `RangeEmpty` | ConditionOutcome; `hir::completions::BranchOutcome` |
| KnownOutcome (syntactic/type) | **expression** | `hir::types::KnownOutcome` / `hir::refine::decideTypeTest` | `known` field | view overlay | `If` (types, range, lower), ConditionOutcome |
| ConditionOutcome | **expression** | `hir::range::ConditionOutcome` | query answer `1/0/""` | — | `native::lower::If` |
| instance result type | **result** | `hir::specialize` result fixpoint | instance `result` | call-site types | callers' region inference; aot `UnknownCallResultKind` |
| instance result Range | **result** | `hir::range` `calleeResults` (widen-only across rounds) | per-instance summary | call-site Range | callers; ClosedResult constants |
| native `-result-range` | **result** (global, per native) | `core/native.tcl` metadata | `nonneg`/`collection-length` | `hir::range::Call`, `SeedRange` (induction) | entry ranges (M6's `BelowRange` elimination) |
| native `-result-shape` | **result** | `core/native.tcl` metadata | list/set forms | types (hence List keys) | identity (List element kinds), admissibility |
| completion facts (`effectiveErrors`, `mayReturnNormally`, `resultRangeFact`) | **call edge** | `hir/completions.tcl` | fields stamped on call/handle nodes | **none** (read only by `hir/errorsets.tcl`) | static legality only |
| literal container contents | **call edge** | `hir/completions.tcl` `exactList` | walk-local | none | legality (`byte::set([...])` needs no handler) |
| equality-totality | **expression** | `hir::types::IsEqualityTotal` over view types | predicate | — | `setcontainstotal`/`setfromlisttotal` opcodes |
| `may_error`/`may_gc` per call | **global** (NIR fixed point) | Rust side, structural over NIR | per call edge | — | codegen check elision |
| closedness ("no dynamic caller") | **global** | only the approximation `OpenInstances` (= materialized); `hir::blockescape` proves non-materialization for local closures, per region, *after* specialization | — | — | entry-range fold only |
| expression removability, `not` composition, container-content propagation into instances | **missing** | — | — | — | — |

## Theorem producer inventory

| producer | produces | representation | scope |
|---|---|---|---|
| declared types (`hir::resolve` `declaredParamTypes`/`declaredResult`) | admissible values per parameter/result | core/applied type | entry (+ result contract) |
| source-defined domains (`hir/sourcetypes.tcl` → `core::type` `-integer-domain`) | interval / exact set per named Int type | `core::type::integerFacts` | read through `TypeFact` anywhere a type is known |
| `-result-shape` metadata | List/Set element types, positional shapes | static list/set forms | result (hence identity for Lists) |
| `-result-range` metadata | `nonneg`, `collection-length` | Range | result |
| call-site argument facts | types (region inference); Ranges (`hir::range` `Expr`) | static types; Ranges | call edge → identity (kinds) or entry (joined) |
| specialization joins | instance result types; capture seeds (lub over creations) | static types | result; capture |
| `RefinementFacts` | named evidence common to all syntactic exact calls | evidence sets | entry |
| `hir::range` fixpoint | entry Ranges, per-expression Ranges, result summaries | Range | entry, expression, result |
| `hir::induction` | monotone equality-termination guards; locked entry Ranges | Range + `monotone` | entry/path |
| path narrowing | branch-local Ranges; type refinements | Range; static type | path |
| exact capture identity | `{block E …}` static types through bind/capture/result | static type | capture/expression |
| `hir/completions.tcl` recursive analysis | per-call completions, per-call result Range, literal contents | node fields | call edge |
| module-retained exact types (`hir::modulebinding`) | exact applied type of retained values (e.g. `ImmutableSet[Byte]`) | static type (seed); immutability proof discarded | capture |
| `hir::callables` | escape legality of Bearing callables | diagnostics | global |
| `hir::blockescape` | non-materialization of local closures | per-instance virtual map | representation only (not fed back into openness) |

## Theorem consumer inventory

| consumer | theorem categories consumed |
|---|---|
| type checker / admissibility (`verifyDeclaredParams`, `verifyDeclaredResults`, `ProvesValueAcceptedBy`) | declared types; *local, non-interprocedural* Ranges and exact sets (never the instance fixpoint); invariant applied-type equality |
| `hir::callables::verify` | exact callable types (Bearing); join/return/argument positions |
| `hir::specialize` | kinds (identity); declared types; RefineParams evidence; capture seeds; result types |
| `hir::range` | view types (declared/evidence/capture seeds through `TypeFact`); exact-call edges; native result metadata; induction proofs; KnownOutcome |
| `hir::completions` | declared errors; Range primitives (its own local walk); literal contents; `Narrowed` emptiness; KnownOutcome; its own native result table |
| `hir::errorsets` | completion facts (effectiveErrors, mayReturnNormally) → UNHANDLED-ERROR / KNOWN-ERROR |
| `native::lower` representation decisions | per-instance Ranges (`fitsSmall`), view kinds (guards via aot blockers), escape/region/blockescape analyses |
| `native::lower::If` / ConditionOutcome | KnownOutcome; per-instance operand Ranges (entry + path + expression); `Narrowed` emptiness; exact sets |
| `native::lower` ClosedResult | per-instance call-site Range of a block call (single small point → constant) |
| native call opcode refinement | equality-totality of view types (`setcontainstotal`, `setfromlisttotal`); raw eligibility; FoldPureBitwise; tiny-leaf eligibility |
| NIR effect fixed point (Rust) | structural `fail`/raise reachability after lowering; nothing from `hir/completions.tcl` |

## Theorem-flow graph

Legend: **[G]** green = intentional working flow; **[Y]** yellow = the
fact exists but its semantics or ownership are unclear; **[R]** red =
lost or missing; **[B]** blue = intentionally siloed.

```text
declared param type ──[G]──> Analyze seed (scalars, sets, generic) ──> view ──> TypeFact ──> refs/ConditionOutcome
declared List[T]    ──[R]──> Analyze seed skipped when key is List[K]  (S05d: element domain lost)
RefineParams        ──[G]──> seed evidence (entry) ──> view ──> TypeFact (S04b)
call-site Range     ──[G]──> hir::range caller fold ──> entry Range (non-open instances)
call-site Range     ──[R]──> open generic instance: discarded (by design; closedness is approximated)
call-site kind      ──[G]──> KeyType ──> identity ──> view kind ──> no guard
call-site kind      ──[R]──> value-capturing closure: forced generic key ──> guard (family 1b)
call-site kind      ──[R]──> open generic instance: no entry-kind join exists at all
capture seed type   ──[G]──> view types in the closure instance (S08c)
capture Range/value ──[R]──> not seeded into hir::range (S08a)
native -result-range──[G]──> hir::range Call/SeedRange ──> entry (M6's BelowRange)
native result range ──[B]──> hir/completions.tcl own table ([0,1114111] vs hir::range [0,+∞]) (S14)
instance result Rng ──[Y]──> calleeResults locks the first concrete round's summary (S13 hysteresis)
path narrowing      ──[G]──> branch-local Range ──> ConditionOutcome / raw repr
Narrowed min>max    ──[Y]──> IsEmpty (ConditionOutcome) and RangeEmpty (completions): implicit encoding, two readers
Narrowed exact-empty──[R]──> fallback to non-empty interval: impossibility dropped (S12a)
== impossible (true)──[R]──> PointEqualityNarrow stores point(K): impossibility disguised as a value (S11, S12b)
completion facts    ──[B]──> hir/errorsets.tcl only (legality); never codegen (M5, intentional)
literal contents    ──[B]──> hir/completions.tcl exactList only (call edge)
blockescape proof   ──[Y]──> representation only; not fed into OpenInstances; depends on closure policy
KnownOutcome        ──[G]──> ConditionOutcome (composed first)
```

## Declared parameter theorem audit

**Is a declared type part of instance identity, an invariant applied
after selection, or both?** It is an *entry invariant applied after
identity selection*. It never enters the key. How it is applied depends
on the key's representation.

| key representation | what `Analyze` does with the declaration | observed |
|---|---|---|
| `any` (generic instance) | adopts the declared type outright (M1) | `web::is_unreserved<generic>`: `b : int[Byte]` |
| scalar kind (`int`, `str`, ...) | `narrow(key, declared)` = union of evidence (M1) | `ascii::is_digit<int>`: `int[Byte]` |
| bare `immutableSet` | not "specific", so the declared `ImmutableSet[T]` is adopted | S06a: `s : ImmutableSet[int[Byte]]`, `setcontainstotal` |
| `List[K]` / shaped list | **skipped**: key already "specific" | S05d: declared `List[Byte]`, view `List[int]`; `b > 255` Unknown in `f<List[int]>`, AlwaysFalse in `f<generic>` (S05e) |
| `List[never]` | skipped | exists only for *rejected* programs when the parameter is declared (S05a) |
| `block` / `native` | skipped | no declared callable types exist in the source language |

Then `RefineParams` unions in named evidence that *every syntactic exact
call* of the block proves. It is skipped for `any` keys and for specific
(aggregate/callable) keys.

What makes the declared theorem valid for every instance, including the
generic (possibly open) one:

- `hir::range::verifyDeclaredParams` proves admissibility at every
  direct call (local, non-interprocedural facts).
- `hir::callables::verify` rejects every position that would erase a
  Bearing callable's exact identity (S07c: passing a typed function as an
  argument is a TYPE error).

So a call that can reach a declared parameter is a checked exact call.
That is the "global theorem" M1 rests on (accidental-dependency #4
below). It holds today.

Relationship of the five facts at a parameter:

```text
call-site argument fact  --(kind)-------> KeyType            (identity)
                         --(Range)------> joined entry Range  (entry, hir::range; non-open only)
                         --(evidence)---> RefinementFacts ∩   (entry, all syntactic exact calls)
declared parameter type  --------------> Analyze seed         (entry; aggregates: gap)
                                     \--> verifyDeclaredParams (admissibility at every call)
refs of the parameter    = entry Range ∩ TypeFact(seed type)  (what ConditionOutcome sees)
```

The joined entry Range and the declared domain meet only at refs (both
`hir::range::Expr` and `hir/completions.tcl` intersect on every `ref`).
The instance's `params` entry Range itself never contains the declared
domain. `web::is_unreserved<generic>` has entry `[-∞,+∞]`, yet every
reference to `b` is `[0,255]`.

## Scalar refined-domain audit

S04 and S04b (`artifacts/scenarios.txt`):

| domain | KeyType | declared view | entry Range | exact set on refs | branch theorem |
|---|---|---|---|---|---|
| `Byte` (0..255) | `int` | `int[Byte]` | `[0,255]` | none (dense) | `b < 0` AlwaysFalse via *declared*; `b > 200` Unknown |
| `Small` (10..20) | `int` | `int[Small]` | `[15,15]` | point | `s < 10` AlwaysFalse via *declared* (the entry point would also decide) |
| `LowNibble` (0..15) | `int` | `int[LowNibble]` | `[0,15]` | none (dense) | `n > 15` AlwaysFalse via *declared* |
| `HighNibble` (16-element set) | `int` | `int[HighNibble]` | `[0,240]` + exact 16 | yes | `h == 17` AlwaysFalse via declared (exact-set membership, not the hull); `h < 16` Unknown (0 is a member) |
| undeclared, every caller passes `Byte` | `int` | `int[Byte]` via RefineParams | `[0,255]` | none | `x > 255` AlwaysFalse via *view* (evidence tier) |

Interval and finite domains do *not* behave identically, and correctly
so:

- Intervals flow through `min`/`max` arithmetic.
- Exact sets are carried as a separate, budgeted (32-value) addition. They
  are consulted by `CouldBeEqual` for `==` and by `Narrowed`'s filter.
  They are silently dropped when they would become empty (S12a,
  "Narrowed" below).

A dense exact set is never stored (`Normalize`). It is reconstructed on
demand by `ExactOf`.

No domain fact is identity. `Byte`, `Small` and plain-Int callers of an
undeclared parameter share one `f<int>`. The domain reaches the instance
only as an entry fact: declaration, RefineParams evidence, or the joined
Range.

## Applied List[T] audit

| case | legal? | instance key | seed/view | consequence |
|---|---|---|---|---|
| declared `List[int]`, arg `[1,2,3]` (S05b) | yes | `List[int]` | `List[int]` | ordinary |
| declared `List[int]`, arg `[]` (S05a) | **no**: TYPE "cannot be proven to satisfy List[int] (argument type: List[never])" | `List[never]` | `List[never]` (declared not applied) | exists only under `-strict 0` |
| undeclared, args `[]` and `[1,2]` (S05c) | yes | `List[never]` **and** `List[int]` | as keyed | two instances; in `g<List[never]>` the listloop body is statically dead (`unreachable` in NIR) and the result type is `List[never]` |
| declared `List[Byte]`, exact caller (S05d) | yes | `List[int]` | **`List[int]`** | declared element domain lost; `b > 255` Unknown |
| same, generic instance also used (S05e) | yes | `List[int]` + generic | `List[int]` vs `List[int[Byte]]` | the generic instance proves more than the specialized one |
| `encode_utf8(...)` to declared `List[Byte]` (S05f) | **no** (defect) | `List[int]` | — | raw type `{list Byte}` ≠ `{list {refined int Byte}}` |

**Identity** is the element *kind* (and depth ≤ 3 nesting, and
heterogeneous positional shapes). **Admissibility** is *invariant exact
equality* of the Unshaped semantic type against the declaration
(`ProvesValueAcceptedBy`). **Observed shape** is what specialization's
region inference sees: positional shapes and `never` elements, which
semantic inference never produces for parameters.

Today these are three different relations over one encoding (`{list
ELEM ?SHAPE?}`). For a declared List parameter they are consistent in
legal programs: admissibility forces the Unshaped argument type to equal
the declaration. A heterogeneous shape can never be admissible for a
single-kind `T`, so the key is always `{list KIND}`. For undeclared
parameters the key is pure observed shape.

## List[never] / empty-container semantics

15. **Why does an empty list call produce `List[never]`?**
    `hir::types::AggregateOfValue`/`MakeList` fold the element type
    starting from `never` over zero elements, and `KeyType` recurses into
    List element types and keeps `never`.

16. **Identity theorem, observed-shape theorem, or accidental
    conflation?** For an *undeclared* parameter it is an observed-shape
    theorem, "this call contributes no elements", promoted to identity.
    It is sound: every producer of `{list never}` types a provably empty
    list, so `g<List[never]>`'s dead loop body really is dead.

    For a *declared* `List[T]` parameter it is not a theorem of any legal
    program. `List[never]` is rejected by admissibility, and the instance
    appears only when a rejected program is analyzed non-strictly (M4's
    `setfromlist-empty-list-stays-generic` fixture is exactly this).

    So the representation conflates "empty list" (a value fact) with "no
    element type known" (an inference state). That is harmless today
    only because `ShapeResult`'s `element` case treats `never` as "no
    element information" rather than as an element type.

17. **How does a declared `List[Int]` parameter interact with that
    instance?** It does not. The call is rejected, and in non-strict
    analysis the declared type is not applied, because the key is
    "specific".

18. **Should M7.b preserve this exact representation?** Not as a
    *contract*. M7.b should pin the two semantically meaningful facts:
    - an empty list is inadmissible for a declared `List[T]` (current
      language rule, MINIMAL-APPLIED-LIST-TYPES.md);
    - an undeclared parameter's `[]` caller does not share the
      non-empty callers' instance (current identity behavior; bounded:
      one extra instance per block at most).

    It should *not* pin "the key text is `List[never]`". The observed
    code benefit is nil (the empty instance's loop body is dead but the
    function is also reached only for empty lists). The cost is one
    duplicated instance per block with an empty-literal caller. Whether
    empty-list identity should be kept or folded into the element-kind
    instance is a policy choice worth making deliberately later; DEFER.

19. **What regression test should M7.b write?** The two facts above,
    through the public behaviors:
    - the TYPE diagnostic for a declared parameter;
    - the instance *count* for the undeclared case.

    Plus a replacement for the M4 fixture that uses a legal program:
    `mk_int(empty_int_list())` via a function whose declared result is
    `List[int]` (or document the fixture as analysis of a rejected
    program).

## ImmutableSet[T] audit

| case | key | view | opcode |
|---|---|---|---|
| declared `ImmutableSet[Byte]` (S06a) | `immutableSet` | `ImmutableSet[int[Byte]]` (declared adopted) | `setcontainstotal` |
| undeclared, `byte::set([...])` and `immutable_set_from_list([])` callers (S06b) | `immutableSet` (both share) | `immutableSet` (element erased) | `setcontains` (not proven total) |
| module-retained set captured (S06c `member`, `web::is_unreserved`) | n/a (capture) | seed `ImmutableSet[int[Byte]]` | `setcontainstotal` |

A set's element type is *never* identity: the empty set and every other
set share one instance. It reaches an instance only through a
declaration (entry) or a capture seed (capture). Only the
equality-totality opcode consumer uses it; no range consumer reads set
members. The exact member *values* of a retained set (e.g. `{45, 46, 95,
126}`) are not represented anywhere after `hir::completions`' call-edge
walk. `hir::modulebinding` proves the binding immutable and discards the
proof.

## Callable identity audit

| provenance | exact target survives? | where represented | call form | identity? | classification |
|---|---|---|---|---|---|
| immutable alias `g = foo; g(x)` (S07b, M2) | yes | static type `{block E …}` of the binding | `call` | no | expression/capture theorem |
| captured exact callable (a nested function calling a sibling) | yes | capture seed type, lub over creations (same E, so exact) | `call`/`callenv`/internal variant | no | capture theorem |
| closure returned from a function (S07d) | yes | callee result type `block(e4)/1` | `callenv` to `add<int>` | no (the *returned* closure is specialized by argument kind) | result theorem |
| ordinary untyped parameter (S07a, M2) | **no** | KeyType reduces `{block E …}` to `block` | `callvalue` | erased *at identity* | identity erasure; callers keep it as a call-edge fact they cannot hand over |
| typed/Bearing callable as argument (S07c) | n/a | — | — | — | **illegal** (TYPE) |

20. **Why does an exact immutable callable capture preserve target
    identity?** Bindings are immutable and single-assignment. Capture
    seeds are the lub over creations of the *same* block expression, and
    `hir::types::lub` keeps `{block E …}` exact when both sides name the
    same E. So the static type proves one target.

21. **Why does an ordinary untyped parameter lose it?** KeyType reduces
    every callable to its kind. Two callers passing `foo` and `bar` share
    `apply<block, int>` (the M2 pin), and nothing below identity carries
    a callable fact. There is no "entry callable theorem" (e.g. "every
    caller passes `foo`").

22. **Required for soundness, explosion control, or policy?** Not
    required for soundness. A per-target instance would be sound, since
    each instance would be reached only by exact callers passing that
    target. It is explosion control and policy:
    - the number of distinct callable targets per higher-order parameter
      is unbounded by the key lattice's own height;
    - it is bounded in practice only by the per-block limit;
    - a closure's target block also says nothing about its environment.

    Note what makes it *legal* today: `hir::callables` guarantees no
    Bearing callable ever reaches an erased position. Erasure never
    drops an *obligation*, only a *target*.

23. **What would identity-preserving higher-order specialization cost?**
    One instance of the higher-order function per distinct target block
    per parameter, multiplicatively across callable parameters, capped by
    `limit`=8. Code growth is the HOF body size × targets. The benefit is
    confined to turning `callvalue` into `call`/`callenv` inside the HOF.
    The frozen corpus has **zero** `callvalue` sites (`uri-steady`:
    `callvalue=0`; `refined-checks`: `callvalue=0`), so there is no
    measured benefit on the fenced vertical.

24. **Should M7.b change it?** **No.** REJECT as instance identity for
    M7.b. The corpus shows no benefit, and the theorem that would
    actually help, "every caller of this closed instance passes target
    E", is an *entry* theorem that needs the same closedness proof as
    family 1b below. Revisit it together with that milestone, not as a
    key change.

## Typed-callable/Bearing audit

- **Which theorem enforces it:** `hir::callables::Bearing` + `verify`. A
  block with a declared parameter type or a declared error set is
  "Bearing". Every position that would erase its exact static type is a
  TYPE diagnostic:
  - call argument;
  - `if` join to a different type;
  - `break` join;
  - `return`/trailing value to a different function result type;
  - `ok`/`error` wrapper.
- **Where represented:** only as diagnostics. There is no stored fact.
- **Effect on identity:** none directly. It *removes* flows rather than
  selecting instances: a Bearing callable can never be an argument, so
  it can never meet KeyType's `block` erasure, and can never reach
  `callvalue`.
- **Rejecting vs selecting:** purely rejecting. It is the global theorem
  that makes three other mechanisms sound:
  - M1 seeding of generic instances;
  - `hir/completions.tcl`'s assumption that non-exact targets carry no
    declared errors;
  - `hir::types::Call`'s `calleeErrors` being empty for dynamic calls.

## Capture theorem audit

| captured value | exact identity/type that survives | enters identity? | NIR form | seen by `hir::range`? |
|---|---|---|---|---|
| exact callable (sibling nested function) | exact `{block E …}` | no | direct call / internal variant (blockescape) or `callenv` | n/a |
| `ImmutableSet[Byte]` (module-retained) | exact applied type | no | `capture I` (closure) or explicit param (internal variant) | no (not Int) |
| scalar Int (S08a: `n` of `mk(1)`/`mk(2)`) | kind `int` (seed) | **no**, but an Int-kinded capture *permits* the closure to specialize by argument kind | explicit param after blockescape | **type only**: `n > 100` Unknown although `mk`'s entry is `[1,2]` |
| declared `Byte` scalar (S08c) | `int[Byte]` (seed) | no | explicit param | via `TypeFact` of the seed: `n > 255` AlwaysFalse |
| `str` (S08b, and every StringRegion scanner's `v`) | `str` | forces the **generic key** for every exact call of the closure | `capture`/explicit param | n/a |

Capture *types* survive (lub over creations) and are consumed. Capture
*values and ranges* are never seeded into `hir::range`: `AnalyzeInstance`
seeds only parameters, and a captured binding's ref falls back to
`unknown ∩ TypeFact(seed)`. That is a missing capture theorem. It would
be a join over creation sites, exactly like the entry fold, and would
never be identity.

## Closure environment audit

**Is "same block + different environment values" one instance or
multiple?** One. S08a shows `mk(1)` and `mk(2)` share one `add<int>`,
because environment values are never in the key. The four notions are
separate today:

| notion | represented by | identity? |
|---|---|---|
| code identity | block ExprId | yes (first key component) |
| environment shape | `captures` list (structural) and, after blockescape, the flattened capture list | no (fixed per block) |
| environment value | runtime closure object, or explicit trailing params of an internal variant | no |
| captured theorem | capture seed *types*, lub over every creation (`Handle create`, requeues on growth) | no. One theorem, joined over all creations, so valid for every environment |

The only way the environment affects identity is the *policy* in
`Handle`: a closure whose captures are not all Int-kinded gets the
generic key for every exact call.

## Envless closures versus real closures

| kind | example | exact call form | specializes by argument kind? |
|---|---|---|---|
| envless static block | `fn foo(x)` at top level; module function capturing only static blocks | `call` | yes |
| static block with block-only captures | `ascii::is_alphanumeric` (captures `is_alphabetic`, `is_digit`) | `call` | yes |
| closure with Int captures only | `add` in S08a | `callenv` or internal variant `call` | yes (the scalar exception) |
| closure with any non-Int capture | `hex_pair` (captures `hex_digits`), `char_at` (captures `v`), `web::is_unreserved` (captures the set) | `callenv` or internal variant `call` | **no**: generic key |
| closure capturing a non-static closure | `esc_bytes` (captures `hex_pair`), `scan_local` (captures `char_at`) | same | **no**: a Block capture is not Int-kinded |
| dynamic callable | untyped parameter | `callvalue` | callee is always `<generic>` |

M2's observation stands: an exact target may still use `callenv`,
because dispatch identity (block) and environment value (closure object)
are independent. Specialization keys are orthogonal to both.

## Capture value specialization explosion risk

Keying instances by capture *values* would be unbounded:

- one block created in a loop, or by a factory called with N distinct
  values, yields N instances;
- nested factories multiply;
- the values are arbitrary-precision Ints, Strings, or other closures
  (whose own identity would recurse).

The per-block limit would cap the instance count at 8, but the choice of
*which* 8 values get specialized would depend on discovery order. That
gives no stable benefit.

**REJECT capture values as identity theorems.** The useful fact, "every
creation of this closure captures a value in R", is a *capture theorem*
joined over creations, with zero instance growth.

## OpenInstances audit

`hir::range::OpenInstances`: an instance is *open* iff it is
**generic**, is **not the program**, and its block is in the union of
`values` (`hir::aot::materializedBlocks`) over the used instances.

- **What causes an instance to become open?** The block's Block value is
  created, used or bound in value position anywhere in used code:
  - a closure bound by `fn` inside another function;
  - a module-level function bound as a value;
  - an alias `h = g` (S02f);
  - a function whose `fn` binding captures a value.

  Being *called dynamically* is not required. In both frozen workloads,
  every open instance is reached only by exact calls:
  - `uri-steady`: `callvalue=0`;
  - `refined-checks`: `callvalue=0`;
  - `hir::blockescape` virtualizes the nested closures so no Block object
    exists for them at run time.

  7 of 19 used instances are open in `uri-steady`, 20 of 39 in
  `refined-checks`.
- **What is discarded?** Only *entry-Range* propagation: the caller fold
  skips open targets. Identity is unaffected (identity is decided
  earlier, in `hir::specialize`). Type facts are unaffected too: the
  generic key already carries nothing, and M1 still adds the declared
  type.
- **Can later exact calls still benefit?** Not through the open generic
  instance. Exact calls that resolve to a *specialized* instance of the
  same block keep full entry facts. S02f: `h = g` makes `g<generic>`
  open, while `g<int>` (reached by `h(3)`) keeps `[3,3]` and `f<int>`
  keeps `[3,5]`. Specialized instances are never open.
- **Which consumers see the conservative result?** Every Range consumer
  of that instance: ConditionOutcome, raw representation, ClosedResult,
  and, transitively, every callee whose entry join includes the open
  instance's arguments (S02e, S03b).

## Entry-range construction audit

Order of contributions for parameter `p` of used instance `I`
(`hir::range::analyze`):

1. **Induction lock.** If `hir::induction` proved an equality-termination
   range for `p`, it is the entry and is never widened or joined (locked).
2. Otherwise the entry starts as `unknown`.
3. **Each round**, `SettleInstance` runs `I`'s own self-call feedback:
   join with the self-call argument Ranges and widen changed bounds to
   ∞, up to 4 passes. If self-feedback turns a concrete fact into
   `unknown`, `p` is **poisoned** (permanently unknown).
4. **Caller fold** (skipped entirely if `I` is open). Collect every exact
   call reached in this round's walk of every *other* used instance. The
   call must be reachable: an argument that is `never` makes the call
   contribute nothing. Join the argument Ranges per parameter.
   - locked: keep;
   - `I` not self-recursive: *replace* with this round's join
     (`never` → unknown);
   - poisoned: unknown;
   - self-recursive with an entry still unknown: adopt the join;
   - otherwise: `widen(old, join(old, contribution))`.
5. At every `ref` of `p`: `entry ∩ TypeFact(view type of the ref)`. This
   is where the declared domain, RefineParams evidence, type-test
   refinements and (for captures) seed types enter.
6. Branch narrowing replaces the binding's Range inside a branch;
   `JoinBindings` restores/joins it after.
7. Call results: native `-result-range` metadata, or `calleeResults` (the
   callee's result summary), each intersected with the call's own static
   type.

**Conflict resolution:**
- types *intersect* with Ranges (at refs);
- callers *join*;
- self-recursion *widens*;
- induction *wins*;
- open instances *ignore* callers.

The declared type is never in the stored entry Range. It is applied at
use sites.

**Result-summary hysteresis (S13).** `calleeResults` for an instance is
set from the first round's result. Once it is concrete it only widens
(`join(old, inferred)`). Round 1 runs every instance with `unknown`
entries, so a callee whose result is already concrete under unknown
entries keeps that coarse summary for good. This applies to any callee
with a declared result domain or a declared parameter.

`byte::from_int(7)`: the instance's own settled result is `[7,7]`, the
call-site Range seen by `fb` is `[0,255]`, and `hir/completions.tcl`'s
call-edge fact is `[7,7]`. This is sound, deterministic, and loses
precision. Entry facts of non-self-recursive instances are recomputed
fresh each round precisely to avoid this; result summaries are not. It
is a transport loss, not a missing theorem.

## Call-edge vs instance theorem audit

| fact | call-edge value | instance value | why it must stay edge-scoped |
|---|---|---|---|
| `effectiveErrors` of `byte::from_int(45)` vs `byte::from_int(m+0)` handled (S09) | `{}` and `{BelowRange AboveRange}` | one `from_int<int>` with entry `{45,1000}`: `BelowRange` decided, `AboveRange` kept | the body is shared; using the `{}` edge would delete a live `fail` for the `1000` caller |
| `resultRangeFact` of `f(1)` / `f(2)` (S01) | `[1,1]` each | `f<int>` result `[1,2]` | per-edge precision; the instance result is the join |
| literal container contents of `byte::set(['-','.','_','~'])` (S10) | every element in Byte (legality: no handler needed) | `from_int<int>` shared with the whole `byte::set` family: entry `[0,+∞]` | the shared inner instance also serves dynamic `byte::set` callers |
| literal `45` at a shared caller (M6 control, legal twin S03b) | `[45,45]` | `from_int<int>` entry `[-∞,+∞]` | an open caller joins in |

M5's completion proofs are the canonical call-edge theorems. They are
consumed only by legality (`hir/errorsets.tcl`). Nothing in the code
lets them prune a shared body (confirmed by S09 and S03b).

## M5/M6 byte::from_int shared-instance case

| shape | legal? | instances | entry | `value < 0` | `value > 255` |
|---|---|---|---|---|---|
| `byte::from_int(45)` only (S03a) | yes | `from_int<int>` | `{45}` | AlwaysFalse (entry) | AlwaysFalse (entry) |
| + legal open caller (S03b; handled, untyped `dyn` passed through `caller(g, v)`) | yes | same instance | `[-∞,+∞]` | Unknown | Unknown |
| M6's `condition-outcome-12` as written (S03c) | **no** (2 TYPE diagnostics: typed `dyn` passed as an argument; `caller`'s declared result unproven) | same instance | `[-∞,+∞]` | Unknown | Unknown |
| + `char::codepoint` metadata caller (S14, `byte::set`) | yes | same | `[0,+∞]` | AlwaysFalse (entry, via native metadata) | Unknown |

This case separates the three scopes cleanly:

- **instance identity:** `from_int<int>` in every row; identity never
  changes;
- **entry theorem:** the join over the instance's callers, which is what
  M6 consumes;
- **call-edge theorem:** each call's own `effectiveErrors`/
  `resultRangeFact`.

M6's soundness conclusion holds, but its adversarial fixture is an
illegal program. S03b is the legal twin M7.b should pin.

## Family 1b / RC1 reclassification

### Current guard census (post-M6)

`tools/corpus.tcl` (`artifacts/{uri-steady,refined-checks}/guards.txt`).
Every guard is a *kind* guard (`UnknownParameterKind`/
`UnknownCallResultKind`) in a generic instance. None is a Range guard.
NIR `guard` op totals equal the representation-blocker counts: 14 and
24.

**Mechanism key:**
- **(a)** closure KeyType policy: value-capturing closure → generic key;
- **(b)** open by materialization: no entry facts at all;
- **(c)** cascade: a caller passes an `any`-typed value;
- **(d)** unknown result kind of a generic callee;
- **(e)** only reached through a dead materialized Block value.

**`uri-steady`** (14 guards, 7055 machine-code bytes in total):

| instance (bytes) | param | key | declared | entry | open | kinds passed by exact callers | mechanism | theorem that removes it | identity? |
|---|---|---|---|---|---|---|---|---|---|
| `byte::high_nibble<generic>` (inlined into `high_nibble<generic>`, 214) | `b` | any | – | unknown | no | `high_nibble<generic>`: any | (c), 3rd order | entry kind of `high_nibble.b` | no |
| `hex_pair<generic>` (484) | `b` | any | – | unknown | yes | `esc_bytes<generic>`: any (`list_get(bytes, i)`) | (a)(b)(c), 2nd order | entry kind of `esc_bytes.bytes` (= `List[Byte]`) | no |
| `esc_bytes<generic>` (864) | `i` | any | – | unknown | yes | int, int, int | (a)(b) | entry-kind join | no |
| | `bytes` | any | – | unknown | yes | `List[int[Byte]]` ×2, self-forward | (a)(b) | entry-kind join | no |
| | `acc` | any | – | unknown | yes | str ×3 | (a)(b) | entry-kind join | no |
| `esc_char<generic>` (516) | `c` | any | – | unknown | yes | str (`substring`) | (a)(b) | entry-kind join | no |
| `esc_from<generic>` (1004) | `i` | any | – | unknown | yes | int, int | (a)(b) | entry-kind join | no |
| | `text` | any | – | unknown | yes | `uri_escape_text<generic>`: any; self-forward | (a)(b)(c) | entry kind of `uri_escape_text.s` (callers pass str) | no |
| | `acc` | any | – | unknown | yes | str, str | (a)(b) | entry-kind join | no |
| | (result of `esc_char`) | – | – | – | yes | – | (d) | result kind of `esc_char` (str, once `c` is known) | no |
| `repeat_uri<generic>` (1180) | `i` | any | – | unknown | yes | int, int | (a)(b) | entry-kind join | no |
| | `total` | any | – | unknown | yes | int, self-forward | (a)(b) | entry-kind join | no |
| | `acc` | any | – | unknown | yes | int, int | (a)(b) | entry-kind join | no |
| | (result of `uri_escape_text`) | – | – | – | yes | – | (d) | result kind of `uri_escape_text` | no |

**`refined-checks`** (24 guards, 16743 bytes): the same 10 URI-helper
guards (all rows above except the four `repeat_uri` rows), plus 7 per
`Emailish?` scanner copy × 2 copies (F14 duplication):

| instance (bytes, per copy) | param | exact callers pass | mechanism | removing theorem |
|---|---|---|---|---|
| anonymous `Emailish?` body `<generic>` (769) | `v` | **no exact caller** | (e) dead `fnvalue` in `check` (F14/RC5) | none needed: do not materialize a dead Block value |
| `char_at<generic>` (450; 2 guards) | `i` | int from 6 call sites | (a)(b): captures `v: str` | entry-kind join |
| `scan_local<generic>` (884) | `i` | int ×3 | (a)(b): captures `char_at` (non-static) | entry-kind join |
| `scan_label<generic>` (644) | `i` | int, `domain_loop<generic>`: any | (a)(b)(c) | entry kind of `domain_loop.i` |
| `scan_alpha<generic>` (540) | `i` | int, `tld_ok<generic>`: any | (a)(b)(c) | entry kind of `tld_ok.i` |
| `tld_ok<generic>` (540) | `i` | int | (a)(b) | entry-kind join |

Totals:

| class | `uri-steady` | `refined-checks` |
|---|---:|---:|
| decided by kinds that direct exact callers already pass | 9 | 14 |
| decidable one or two call levels up (cascade) | 3 | 7 |
| unknown callee result kind | 2 | 1 |
| no exact caller (dead materialized value) | 0 | 2 |
| **total** | **14** | **24** |

### Required family 1b answers

25. **How many residual guards post-M6?** 14 (`uri-steady`) and 24
    (`refined-checks`), unchanged by M6. M1 took `refined-checks` from 27
    to 24.
26. **Which functions contain them?**
    - `uri-steady`: `high_nibble` (inlined `byte::high_nibble`),
      `hex_pair`, `esc_bytes`, `esc_char`, `esc_from`, `repeat_uri`;
    - `refined-checks`: the five URI helpers, plus `char_at`,
      `scan_local`, `scan_label`, `scan_alpha`, `tld_ok` and the
      anonymous `Emailish?` body, each twice.
27. **Which theorem would remove each?** A **parameter-kind entry
    theorem**: "every caller of this instance passes a value of kind K".
    For 23 of 38 guards, that is the join of the kinds the direct exact
    callers already pass. For the cascades, it is the same theorem
    iterated to a fixpoint. The result-kind guards additionally need the
    callee's result type re-inferred under it. For the 2 dead-value
    guards, no theorem is needed: they need dead-`fnvalue` elimination.
28. **Is that theorem already proved somewhere?** Yes, in pieces:
    - every call site's argument *type* is computed by region
      inference (the "call-site arg types" column);
    - `RefinementFacts` already computes the analogous *intersection*
      for named evidence.

    What is not proved anywhere before specialization is the side
    condition: **closedness**, "no call other than these exact calls
    reaches this instance". `hir::blockescape` proves the local-closure
    part of it, but per region and only *after* specialization.
29. **Where is it lost or ignored?** In three places:
    - (a) `Handle` forces the generic key before any fact is consulted;
    - (b) `OpenInstances` equates materialized with dynamically callable;
    - `RefineParams`/M1 have no kind-join case for `any` keys (correctly,
      given (b)).
30. **If no single owner, who should own it?**
    - `hir::specialize` should own the entry-kind join, as a sibling of
      `RefinementFacts`/`RefineParams`: a seed-type join over exact
      callers, applied only to closed instances.
    - A pre-specialization escape analysis (the global/module
      "closedness" theorem) should be owned by `hir::aot` or a
      `hir::blockescape` pass hoisted before specialization. Its only
      output is "block B's Block value never reaches dynamic dispatch".
31. **Should the theorem affect identity?** **No.** The entry-kind
    theorem gives the generic instance the kinds without creating any
    instance. Identity would re-create family 1b's regression below.
32. **Would an entry theorem suffice instead?** Yes, for 36 of 38
    guards. The 2 dead-value guards need dead-value elimination instead.
    It suffices *only* together with the closedness theorem; without
    closedness it is unsound for genuinely open instances.
33. **Would improving *selection* increase instance count?** Yes, and it
    is counterproductive in the current pipeline. The naive
    identity-based 1b ("value-capturing closures keep argument-kind
    keys"), measured in-process with `tools/counterfactual.tcl
    closure-kind-identity`:

    | | `uri-steady` baseline | 1b-as-identity | `refined-checks` baseline | 1b-as-identity |
    |---|---:|---:|---:|---:|
    | used instances | 19 | **29** | 39 | **60** |
    | emitted NIR functions | 17 | 23 | 33 | 41 |
    | machine code bytes | 7055 | **8986 (+27.4%)** | 16743 | **19173 (+14.5%)** |
    | NIR `guard` ops | 14 | 9 | 24 | 12 |
    | `closure` ops / `callenv` | 1 / 1 | 5 / 11 | 2 / 2 | 10 / 14 |
    | Block allocations per run | **1** | **8001** | 2 | 6 |
    | allocated bytes per run | 2,544,568 | 2,944,568 | 1,085 | 1,285 |
    | program result | 29500 | 29500 | `[400, 0]` | `[400, 0]` |

    Cause, traced:
    - `web::uri_escape_text` is materialized, so its generic instance is
      always used.
    - Analyzing that generic instance calls `esc_from` with `(any, int,
      str)`, creating `esc_from<any, int, str>`, a second *non-generic*
      instance alongside `esc_from<str, int, str>`.
    - `hir::blockescape::SingleInstance` declines any candidate with more
      than one non-generic used instance.
    - So all four nested helpers become real heap closures, allocated on
      every `uri_escape_text` call: 4 × 2000 = 8000 extra Blocks.
34. **By how much on frozen workloads?**
    - The entry-kind approach: **0 instances** by construction (it seeds
      existing instances).
    - Naive identity: **+10 / +21 instances** (measured above).

**Reclassification.** RC1 "instance selection ignores proven parameter
facts" is five mechanisms:

- (a) closure KeyType policy;
- (b) materialization-as-openness;
- (c) cascade;
- (d) result-kind transport;
- (e) dead materialized values.

Plus one accidental dependency (F) that makes (a) unsafe to change alone:
blockescape's single-instance rule. None of them is "a proven *range*
fact is ignored". The facts at stake are kinds. They are proven at call
edges, and cannot soundly reach a generic instance without a closedness
theorem.

## Current frozen-corpus instance census

`tools/corpus.tcl` (`artifacts/*/instances.txt`, `conditions.txt`,
`functions.txt`, `summary.txt`).

| metric | `uri-steady` | `refined-checks` |
|---|---:|---:|
| used instances (program + generic + specialized) | 19 (1 + 9 + 9) | 39 (1 + 22 + 16) |
| open instances | 7 | 20 |
| emitted NIR functions | 17 | 33 |
| machine code bytes | 7055 | 16743 |
| representation guards (= NIR `guard` ops) | 14 | 24 |
| reachable `if`s in used instances | 19 | 68 |
| … decided AlwaysTrue/False | 1 (entry) | 2 (1 entry, 1 syntactic) |
| … Unknown comparisons | 11 | 45 |
| … not a comparison (predicate call / `and` / `or` / `not`) | 7 | 21 |
| `call` / `callenv` / `callvalue` / `callmulti` | 16 / 1 / 0 / 0 | 32 / 2 / 0 / 12 |
| Block allocations / total allocations per run | 1 / 61,510 | 2 / 23 |
| result | `int 29500` | `list {{int 400} {int 0}}` |

These equal M6's post-M6 figures (7055 and 16743 bytes, 17 and 33
functions): M6's delta is the last one on these workloads.

Per function (key excerpts from `instances.txt`):

| function/block | instances | key(s) | entry facts | open | dispatch into it | capture facts | candidate theorem | scope |
|---|---|---|---|---|---|---|---|---|
| `byte::from_int` | 1 | `<int>` | `[0,+∞]` (from `char::codepoint` metadata) | no | `call` | – | container contents for `AboveRange` | call edge (keep) |
| `char::codepoint` | 1 | `<UnicodeChar>` | declared | no | `call` | – | – | – |
| `byte::set` | 1 | `<List[UnicodeChar]>` | declared | no | `call` | exact callables | literal contents | call edge |
| `ascii::is_*` (5) | 1 each | `<int>` | `[0,255]`, `int[Byte]` | no | `call` | exact callables | none needed | – |
| `web::is_unreserved` | 1 | `<generic>` | declared `Byte`; entry unknown | yes | `callenv` | `ImmutableSet[Byte]` (type) | entry Range if closed | entry |
| `web::uri_escape_text` | 1 | `<generic>` | unknown | yes | `call` | `List[str]`, callables | closedness + entry kind | entry |
| `high_nibble`, `hex_pair`, `esc_*`, `repeat_uri` | 1 each | `<generic>` | unknown | mostly yes | internal-variant `call` | callables, `List[str]` | closedness + entry kind | entry |
| `check` (refined-checks) | 1 | `<int, int, str, str>` | `n ∈ [-∞,400]`, `acc ∈ [0,+∞]`, `q : str[UriQueryValue]` (RefineParams) | no | `call`/`tail` | – | threshold widening (existing 2d) | entry |
| `Emailish?` scanners | 2 copies each | `<generic>` (+ `<str>` for the body) | unknown | yes | internal / `callmulti` | `v : str`, `n : int`, callables | closedness + entry kind; dead-`fnvalue` removal | entry / global |

## Container-content theorem classification

The theorem: "every element a `listloop` visits comes from this literal
list", e.g. `['-','.','_','~']` in `byte::set`'s loop, so
`char::codepoint(c) ∈ {45,46,95,126}` and `AboveRange` is dead.

**It already exists, as a call-edge theorem**
(`hir/completions.tcl`: `exactList`, `LiteralListOf`, per-element
`EvalListloop`). That is why the module initializer needs no handler.

Candidate scopes:

| scope | verdict | reason |
|---|---|---|
| call edge (current) | **KEEP** | exactly true for one invocation; drives legality |
| instance identity (key `byte::set<List[...] with contents C>`) | **REJECT** | unbounded: every distinct literal list creates an instance. Unstable: the benefit disappears the moment a second caller passes other contents. And it would not even help `from_int`: the inner `from_int<int>` instance is shared with every other `byte::set` instance (S10 shows `byte::set<List[UnicodeChar]>` and `byte::set<generic>` both calling one `from_int<int>`) |
| entry theorem of `byte::set`'s instance (join of contents over callers) | DEFER | sound (a join) and bounded, but its only consumer would be `from_int<int>`'s entry, which it cannot reach. The inner call's argument is `char::codepoint(c)`, whose Range comes from the *callee result summary*, not from the loop element. It would need a per-element Range for listloop bindings (hir::range currently leaves the element binding unseeded: "the same answer a not-provably-int element would get anyway") *and* separate `from_int` instances to benefit, i.e. identity after all |
| loop/path theorem inside one instance | DEFER | the listloop element binding is a path fact of the loop body; with an entry-level content set it would be the natural carrier |

For `byte::set` punctuation versus a generic dynamic `byte::set` caller:
the literal's facts must not prune the shared `from_int<int>` body, and
they do not. The dynamic caller also routes through `byte::set<generic>`
(a second instance) into the same `from_int<int>`.

Conclusion: container contents is a call-edge theorem with value today
only for legality. Keep it siloed (**KEEP SILOED**). It is not a
candidate for M7.b.

## Condition-removability theorem classification

M6 left `op rilt`/`op rieq` computations whose results no branch reads
(S04: `fb<int>` still computes `b < 0`; S11 still computes three
comparisons).

- **Is "pure" the right theorem?** Too weak and too vague. The theorem a
  consumer needs is **removability**: "evaluating E produces no
  observable effect *and* cannot produce a non-value completion", i.e.
  E is total and effect-free, so it can be dropped when its value is
  unused. A comparison of two tagged Ints is total only if both operands
  are statically Ints; the same `<` on an unproven kind raises TYPE.
- **Allocation:** for this theorem, allocation should *not* count as
  observable. Botlish has no finalizers or identity-sensitive
  allocation. GC timing is not semantics, and the `native-alloc` tests
  pin *counts*, which a removal can only lower. Any future resource
  accounting that makes allocation observable would narrow the theorem;
  the owner should expose it as a parameter, not bake it in.
- **Context reads** (ambient bindings, a future effect context) are
  observable only if they can fail. A read of an immutable bound binding
  is removable.
- **Owner:** an expression-level summary next to
  `hir::types::KnownOutcome`, derived from native metadata (`-runtime`
  tags, the parameter kinds already proven by the view) plus the
  completion fact "cannot raise" for block calls
  (`hir/completions.tcl` already computes `effectiveErrors`/
  `mayReturnNormally` per call). The consumer would be
  `native::lower::If` and any dead-code pass.
- **Identity:** no. It is an expression theorem.
- **Recommendation:** **DEFER.** The corpus cost is a handful of dead
  register ops per decided branch; no measurable steady-state effect was
  found.

## `not` / `!=` theorem classification

`a != b`, `not c`, `a and b` and `a or b` all lower to `if` expressions
with Bool-constant arms (`surface/lower.tcl`). S11 (`x` is the point 5):

- `if x == 3` is decided (AlwaysFalse).
- `if x != 3` has a condition that is itself an `if` node. Its inner
  `==` is decided, but the outer `if` sees a condition that is not a
  comparison, so it is Unknown. The branch and the Bool materialization
  remain.
- `if not (x < 0)`: same shape; the inner comparison is decided, the
  outer `if` is not.

The missing theorem is **composition through Bool-valued `if`**. If an
`if`'s outcome is decided, its value is the decided arm's value, and if
that arm is a Bool constant the outer condition's outcome follows.

- **Owner:** `hir::range::ConditionOutcome` (or `KnownOutcome`), as an
  expression theorem. It is purely compositional and independent of
  instance selection.
- **Identity:** no.
- **Recommendation:** **DEFER** as a small, self-contained expression
  milestone. Corpus incidence is low (`web::is_unreserved`'s `or` has
  no decidable operand).

S11 also exposed a precision problem that belongs to the next section:
the `x == 3` *true* branch is impossible, yet it stored `x := 3`, so
after that `if` the join left `x ∈ {3,5}`. The *second* `x == 3` test in
the same function is therefore Unknown, although `x` is `{5}`.

## Narrowed / impossible-hypothesis semantic audit

**Current behavior, measured:**

| situation | what `Narrowed` / narrowing returns | consumers |
|---|---|---|
| interval hypothesis unsatisfiable (`b > 255`, `b : Byte`) | Range with `min > max` (e.g. `[256,255]`) | ConditionOutcome (`IsEmpty` → AlwaysFalse); `hir/completions.tcl` (`RangeEmpty` → infeasible branch → `effectiveErrors` shrink); `hir::range::If` *stores* it as the branch-local binding |
| exact-set filter empties but the interval does not (S12a: `x ∈ {255}` in `[101,255]`, test `x < 200`) | the non-empty interval `[101,199]`, with no exact set | nobody learns the branch is impossible: Unknown |
| `==` true hypothesis impossible (S11, S12b) | `point(K)`, a plausible value | ConditionOutcome decides `==` separately (`CouldBeEqual`: AlwaysFalse); completions sees a feasible branch (**divergence**); `hir::range::If` joins the fake point into later facts (S11) |
| `==` false hypothesis removes the last exact member | `""` (no information) | impossibility silently becomes "unknown" |
| no bound on the other side | `""` | "no information" |

And in the stored tables (S12d, `x ∈ [1,2]`, `if x < 0: x + 1000 else:
x`):
- `hir::range::of` returns `[1,-1]` for the `x` ref in the dead branch
  and `[1001,999]` for `x + 1000`;
- the instance's result Range is `[1,999]` instead of `[1,2]`, because
  the empty Range was joined.

40. **What semantic concept is represented by `min > max` today?** A
    verdict: "under the operand facts at this point, the hypothesis
    'condition = O' is unsatisfiable". That is the satisfiability of a
    branch, not a set of values. It is stored in the shape of a Range,
    where it also doubles as the branch-local binding fact and flows
    into ordinary arithmetic and joins.

41. **Intentional or accidental?** Accidental in origin: nothing guards
    the interval path of `Narrowed`, whereas its exact-set path
    deliberately refuses to go empty. It was adopted intentionally
    twice:
    - by `hir/completions.tcl` (STATIC-COMPLETION-PROOFS: "treating a
      narrowed branch fact that becomes an empty interval as a provably
      infeasible branch");
    - by M6's ConditionOutcome.

    M6's report says the value "sat unread … since before this
    milestone". That is not accurate: completions has read it since
    STATIC-COMPLETION-PROOFS. M6 added the codegen reader.

42. **Should live stored Range values continue forbidding bottom?** Yes.
    That invariant is what lets representation consumers (`fitsSmall`,
    raw eligibility, ClosedResult) skip a bottom case. But it does *not*
    hold today: dead-branch expressions store empty Ranges (S12d). It is
    harmless for codegen only because ConditionOutcome makes those
    branches unlowered by the *same* interval test. That is a coupling,
    not an invariant.

43. **Should hypothetical narrowing have explicit impossibility?** Yes. A
    narrowing query should answer one of `impossible`, `facts F` or `no
    information`. Unsatisfiability should never be encoded as a Range
    value.

44. **KEEP / REFINE / REPLACE / DEFER?** **REFINE**, in two steps:
    - **M7.b (strength-preserving):** introduce one canonical query in
      `hir/range.tcl` with an explicit `impossible` result, computed
      from exactly today's interval rule. Switch both readers
      (`ConditionOutcome`'s `IsEmpty` and completions'
      `FactsContradictory`/`RangeEmpty`) to it.
      - `hir::range::If`'s storing behavior stays bit-identical in
        M7.b, so no Range, codegen fact or legality result changes.
      - Result: one owner, one name, no consumer inspecting `min > max`.
    - **Deferred (strength-changing, each needs its own review):**
      - (i) exact-set emptiness as impossibility (S12a);
      - (ii) `==` impossibility in the shared query, which aligns
        completions with codegen (S12b). This **changes legality in both
        directions**: fewer UNHANDLED-ERROR diagnostics, but potentially
        new KNOWN-ERROR rejections when a normal completion becomes
        provably impossible;
      - (iii) `hir::range::If` treating an impossible branch as dead
        (`never`) instead of storing its facts. This makes question 42's
        invariant actually hold, removes S11/S12d-style widening, and
        changes codegen-facing Ranges.

    REPLACE was considered (rewrite narrowing around a real bottom
    element) and rejected for now. The lattice's "no bottom in live
    facts" design is sound and consumer-friendly; only the query
    interface is wrong.

45. **What tests should M7.b write after that decision?** Against the
    *query*, never against the encoding:
    - positive: interval impossibility → `impossible`;
    - negative: unbounded other side → `no information`; a satisfiable
      bound → facts;
    - adversarial: the shared-instance legal twin (S03b) stays Unknown;
    - agreement: ConditionOutcome and completions give the same verdict
      on every interval case (S12c);
    - documented-limitation tests that assert today's answers, labeled
      as such, for the deferred cases S12a, S12b and S11, so the future
      strengthening shows up as an intended diff.

    No test should assert that any Range has `min > max`.

## UNKNOWN vs IMPOSSIBLE vs never/bottom audit

| API / lattice | unknown | unrepresented | impossible | never | empty exact set | bottom |
|---|---|---|---|---|---|---|
| `hir::range` Range | `{-inf,+inf}` | `exact` absent = not tracked | Narrowed `min>max` (implicit); `point(K)` for impossible `==` (disguised); `""` for emptied `==`-false (disguised as no-info) | `never` = no value (dead expression) | never stored (falls back to interval) | not in the lattice, yet present in dead branches (S12d) |
| `hir::range::intersect` | – | – | an empty intersection returns the *old* fact `a` | `never` propagates | – | avoided |
| `hir::types` static type | `any` | – | – | `never` = no normal completion; also the element type of an empty list | – | `never` |
| `{list never}` | – | "no element known" (`ShapeResult` element read) | – | "provably empty list" (listloop body dead, admissibility) | – | **two meanings** |
| `ImmutableSet[never]` | – | – | – | – | erased by KeyType (shares with all sets) | – |
| specialize instance result | `any` (after passLimit) | – | – | `never` = optimistic "no completion known *yet*" during the fixpoint; "never completes" after it | – | **two meanings in time** |
| KnownOutcome / ConditionOutcome | `""` | – | – (a decided condition is 0/1) | – | – | – |
| completions | `unknown` Range | – | `RangeEmpty` (includes `never` and `min>max`) | `never` walk result | – | – |
| `effectiveErrors` | field absent = not stamped | – | `{}` = every declared error impossible | – | – | – |

Places where the conflation could become dangerous:

1. **`{list never}`.** Today, every producer types a provably empty
   list, and the element-read consumer treats `never` as "unknown". If
   any future `-result-shape` or inference rule typed a *possibly
   non-empty* list as `List[never]`, the `g<List[never]>` instance would
   mark reachable loop bodies dead, which is unsound. M7.b should pin
   the producer rule, not the key text.
2. **Impossible `==` stored as `point(K)`.** This is the only place an
   impossible hypothesis looks like a real, precise value. It is sound
   only because it happens in a dead branch, but it pollutes joins
   (S11). A future consumer that trusted "a point Range is a proven
   value" in a branch it believed live would be wrong.
3. **Narrowed `min>max` flowing into arithmetic** (`[1001,999]`).
   `fitsSmall` answers "yes" for such a Range. That is harmless while
   such branches are never lowered, and becomes wrong the day a
   consumer lowers a branch that ConditionOutcome did not decide but
   narrowing emptied. That already happens in principle for induction
   `==` guards (EqualityNarrowing uses `Narrowed` with `<`/`>` while
   ConditionOutcome uses `CouldBeEqual` for `==`); no corpus case was
   found.
4. **Specialize `never` result during the fixpoint.** This is the
   standard optimistic assumption, and `passLimit` bounds it. It is
   consistent at the fixpoint; no issue found.

## Instance stability under additional callers

What happens to each current theorem when a caller is added:

| theorem | new caller with the same kind | new caller with another kind | new dynamic reach (materialization) |
|---|---|---|---|
| identity (kind key) | reuses the instance | new instance (≤ limit, else generic; order-dependent) | reaches `<generic>` only |
| declared parameter (entry) | unchanged (the new call must itself be admissible, or the program is invalid) | same | unchanged (Bearing callables cannot escape) |
| RefineParams evidence | intersection may shrink (weaker) | same | not applied to `any` keys |
| joined entry Range | join grows (weaker), S02b→c→d, "adding a caller" ladder | lands in another instance | generic becomes open: its entry becomes unknown; specialized instances unaffected (S02f) |
| capture seed type | lub grows (requeues) | lub grows | – |
| instance result type/Range | lub/join grows | – | – |
| call-edge completion facts | unaffected (per edge) | unaffected | unaffected |
| ConditionOutcome decisions | may become Unknown (never flip to the other constant) | – | – |

Adding a *materialization* (an alias, a returned closure) never weakens
a specialized instance. It adds an open generic instance; S02f shows it
also adds its generic callees (`f<generic>` with a guard), which is
code-size cost only.

## Monotonicity audit

60. **Can adding a caller weaken facts?** Yes, conservatively.
    `tools/determinism.tcl` step 4:
    - `f(5)` gives `{5}`, and `x < 100` is AlwaysTrue;
    - `+f(9)` gives `{5,9}`, still AlwaysTrue;
    - `+f(500)` gives `{5,9,500}`, now Unknown;
    - `+g(length(s))` gives `[0, 2^62-1]`, Unknown.
61. **Can it ever strengthen a shared instance unsoundly?** No mechanism
    was found that does:
    - entry joins only grow;
    - RefineParams only intersects;
    - capture seeds and results only lub/join;
    - open instances ignore callers entirely.

    The one non-monotone *step*, the fresh per-round recomputation of a
    non-self-recursive instance's entry, is a recomputation from the
    current callers. At convergence each entry equals the join over its
    callers' converged argument Ranges, and the analysis throws rather
    than accepting a non-converged state. The one *precision* hysteresis
    (result summaries, S13) errs in the weak direction.

Fixpoint convergence:
- specialize: finite lattices, `passLimit` 16, a global analysis cap of
  64 × `instanceLimit`;
- range: `roundBudget = 4·|used| + 16`, widening to ∞, then a `HIR RANGE
  LIMIT` error.

Both are predictable and bounded.

## Determinism audit

`tools/determinism.tcl` (`artifacts/determinism.txt`):

58. **Can call discovery order affect instance identity today?** Yes,
    *only at the limit*. `f` with 10 distinct argument kinds:
    - in forward source order, `f([[1]])` and `f([unit])` fall back to
      `f<generic>`;
    - in reverse order, `f(1)` and `f("s")` do.

    It is deterministic for a given program (same source, same result;
    step 1), but a reordering of independent statements changes which
    call gets specialized code. InstanceIds are discovery-ordered; labels
    and entry facts are not order-sensitive below the limit (step 2).
59. **Can it affect entry facts?** Below the limit, no (step 2: identical
    labels and entries in both orders). At the limit, yes, indirectly:
    a displaced call joins the generic instance's facts instead. Result
    summaries depend on round order (S13) deterministically.

Dictionary ordering: Tcl dicts are insertion-ordered, and HIR node
insertion is deterministic, so every `dict for` over HIR is
deterministic. Worklist order: newest-first by InstanceId, deterministic.

62. **Would any proposed M7.b theorem threaten determinism or
    monotonicity?**
    - The declared-aggregate seed is a per-block constant, independent
      of callers and order.
    - The satisfiability query is a pure function.
    - The deferred closedness + entry-kind theorem must be computed
      *before* or *independently of* instance discovery. If computed
      inside `Handle`, it would inherit the limit's order sensitivity.

## Code-explosion analysis

53. **Current instance counts:** `uri-steady` 19 used / 17 emitted;
    `refined-checks` 39 used / 33 emitted.

| candidate identity theorem | worst-case growth per block | bounded by | measured / estimated corpus effect | verdict |
|---|---|---|---|---|
| argument kind (current) | kinds^params, capped at 8 per block, 1000 total | finite kind lattice + limit | baseline | keep |
| argument kind for value-capturing closures (naive 1b) | same cap | limit | **+10 / +21 instances**, +27% / +14.5% code, blockescape loss (8000 extra Block allocations) | **REJECT** in naive form |
| callable identity through parameters | targets^callable-params | limit only | 0 `callvalue` sites in the corpus; no benefit | REJECT (for now) |
| nominal refined type (evidence in key) | (kinds × evidence sets)^params | limit (evidence sets are finite per program but combinatorial) | the only corpus effect would be splitting `f<int>` callers that are already joined via declarations/RefineParams; the entry route already gets the benefit | REJECT: entry theorem suffices |
| container element type | already identity for Lists (depth ≤ 3, shape ≤ 8) | aggregate bounds | – | keep for Lists; do not extend to Set elements (use declarations) |
| range class | unbounded under arbitrary precision unless bucketed; the buckets would be arbitrary constants | would need a new bound | unstable: one new caller moves a call to another bucket and reshuffles code | REJECT |
| exact value / exact set | one instance per literal / per set | limit (then order-dependent) | would reproduce M6's single-caller benefit per literal and lose it at the limit | REJECT |
| capture value | one per closure creation value (loops, factories) | none structurally | – | REJECT |
| container contents | one per literal collection | none | would not reach the shared inner instance anyway (S10) | REJECT |
| completion/effect surface | one per `effectiveErrors` subset | 2^declared errors | would duplicate bodies to delete `fail` arms the edge already proves unreachable | REJECT |

55. **Unbounded value-specialization risk:** range classes, exact
    values, exact sets, capture values and container contents.
56. **Structurally bounded:** argument kinds, List element kinds (depth
    and shape bounds), named evidence (finite per program), callable
    targets (finite blocks), completion subsets (2^|declared errors|).
57. **Should be entry or call-edge instead:**
    - ranges, exact sets, named evidence and kinds of closed generic
      instances → **entry** (joined);
    - literal values, container contents and completion surfaces →
      **call edge**;
    - capture values/ranges → **capture** (joined over creations).

## Accidental dependency inventory

None of these was changed or pinned in M7.a.

1. **Two consumers read `Narrowed`'s `min > max`.** ConditionOutcome
   (M6) and `hir::completions::FactsContradictory` (pre-M6) both
   interpret an out-of-lattice Range as "impossible". They disagree on
   `==` (S12b).
2. **`hir::blockescape` relies on the closure specialization policy.**
   `SingleInstance` declines a candidate with more than one non-generic
   used instance. Keeping value-capturing closures on the generic key is
   what keeps nested helpers at one instance. Measured: relaxing the
   policy costs 8000 Block allocations in `uri-steady`. Only
   `refined-checks`' Block count (2) is pinned today
   (`blockescape-region-companion-refined-checks-1`); `uri-steady`'s
   steady state (1) is not.
3. **`OpenInstances` uses `hir::aot::materializedBlocks` as its
   definition of "dynamically callable".** This is sound (a superset),
   but it is computed from a structural rule that ignores the
   blockescape proof. 7 of 19 and 20 of 39 instances are open while no
   `callvalue` exists.
4. **M1 seeding of generic instances relies on `hir::callables`.** It is
   sound only because Bearing callables cannot escape. If a future
   feature added a new erasure position (e.g. storing a callable in a
   MutableArray) without extending `hir::callables`, M1 and completions
   would both become unsound. There is no single declaration of this
   dependency in code.
5. **RefineParams skips `any` keys (`core::type::base any` is `""`).**
   This is what keeps syntactic-call evidence out of open generic
   instances. That protection is implicit in a base-type check.
6. **`g<List[never]>`'s dead loop body relies on the producers of
   `{list never}`.** It holds because every producer only ever types a
   provably empty list.
7. **Range result summaries depend on round order** (S13 hysteresis).
   Deterministic, but precision depends on the first round seeing
   `unknown` entries.
8. **Declared parameter domains are applied at refs, not entries.** Any
   consumer reading `hir::range` `params` directly (e.g. a future
   entry-based optimization) sees `[-∞,+∞]` for `web::is_unreserved`'s
   `b` although every use is `[0,255]`.
9. **`hir/completions.tcl` keeps its own native result table.**
   `char::codepoint` is `[0,1114111]` there and `[0,+∞]` in `hir::range`
   (S14).
10. **Tests observing rejected programs**:
    - M4 `setfromlist-empty-list-stays-generic`;
    - M5 `checked-domain-shared-instance-byte-set`;
    - M6 `condition-outcome-12`.

    And one vacuous helper: M5's `funcHeaderCount` always returns 1, so
    both shared-instance assertions pass regardless of header count.
    M5's `-from-int` twin is legal, but its only "dynamic" caller passes
    the literal 45, so it does not exercise an unconstrained caller.
11. **`native::lower::If` depends on ConditionOutcome and
    `hir::range::If` using the same interval test.** It is safe to omit
    lowering a branch whose stored facts may be empty, because the same
    test decided it.

## Candidate M7.b theorem changes

### A. Hypothesis satisfiability (FORMALIZE EXISTING)

- **Name:** branch-hypothesis satisfiability query.
- **Theorem:** "given operand Ranges RA, RB at a program point, the
  hypothesis `A op B` (or its negation) is `impossible`, or holds with
  narrowing facts F, or yields no information".
- **Canonical owner:** `hir/range.tcl`.
- **Scope:** expression/path (per condition, per outcome, per instance).
- **Representation:** a tri-state query result (`impossible` / `facts
  DICT` / `none`). It is never stored as a Range.
- **Producer:** today's `Narrowed` interval arithmetic, unchanged in
  strength (interval emptiness only).
- **Transport:** a direct pure call; nothing stored.
- **Consumers:** `hir::range::ConditionOutcome`;
  `hir::completions::BranchOutcome` (replacing `FactsContradictory`'s
  `RangeEmpty`). `hir::range::If` keeps storing today's facts
  (bit-identical), so no stored Range changes.
- **Affects identity:** no.
- **Adversarial soundness case:** S03b (legal shared open caller) must
  stay Unknown; an unbounded operand must be `none`, not `impossible`.
- **Expected instance-count impact:** 0.
- **Frozen-corpus sites affected:** none (strength-preserving). The
  census must stay at 19/17/7055/14 and 39/33/16743/24.
- **Regression tests M7.b should add:** see "Testing recommendations".

### B. Declared aggregate parameter theorem (TRANSPORT EXISTING)

- **Name:** declared `List[T]` parameter seed in specialized instances.
- **Theorem:** "every value reaching parameter p satisfies p's declared
  `List[T]`". It is already proven at every call by
  `verifyDeclaredParams` (invariant admissibility) and `hir::callables`.
- **Canonical owner:** the declaration. `hir::specialize::Analyze`
  transports it (M1's rule).
- **Scope:** entry (every instance of the block).
- **Representation:** the parameter's seed type.
- **Producer:** `declaredParamTypes`.
- **Transport:** extend M1's seeding to keys of the same constructor
  (`List[K]`, K ≠ `never`). A legal caller's key is always unshaped
  `{list kind(T)}`, so the declared type is the exact meet.
  `ImmutableSet` already works, since its key is not "specific".
- **Consumers:** region inference (element reads, listloop element
  binding), `hir::range` `TypeFact`, ConditionOutcome, guards,
  equality-total opcodes.
- **Affects identity:** **no** (the key is unchanged).
- **Adversarial soundness cases:**
  - a `List[never]` key (illegal program only) must not be "restored" to
    `List[T]`;
  - nested `List[List[Byte]]`;
  - an undeclared list parameter must gain nothing;
  - `encode_utf8` → `List[Byte]` must remain as it is until the separate
    canonicalization defect is fixed (do not paper over it here).
- **Expected instance-count impact:** 0 (measured:
  `tools/counterfactual.tcl declared-aggregate-seed` gives identical
  census and allocations on both workloads).
- **Frozen-corpus sites affected:** none (measured). Synthetic S05d: `b >
  255` changes from Unknown to AlwaysFalse in `f<List[int]>`, matching
  `f<generic>`.
- **Regression tests:** S05d positive; S05e parity (the specialized and
  generic instances have the same element view); undeclared negative;
  nested; empty-list rejection unchanged.

### C. Identity-semantics pins (FORMALIZE EXISTING, tests only)

Pin as reviewed contracts what this audit judged intentional:

- **Scalar facts are not identity:**
  - literal values (S01);
  - Ranges and exact sets (S02b/c; HighNibble and plain Int callers
    share `f<int>`);
  - named evidence (Byte and Int callers share).
- **Environment values are not identity** (S08a: one `add<int>`).
- **Completion facts are not identity** (S09: two edges with different
  `effectiveErrors`, one `from_int<int>`).
- **Callable identity:**
  - exact through alias, capture and function result, giving
    `call`/`callenv` (S07b, S07d);
  - erased through untyped parameters, giving `callvalue` (S07a;
    already pinned by M2);
  - Bearing argument rejected (S07c; already pinned).
- **ImmutableSet element types are not identity; declarations restore
  them** (S06a/b).
- **Monotone widening under added callers** (the determinism step-4
  ladder), and order-independence of labels and entries below the limit
  (step 2).
- **The closure policy and its blockescape precondition:**
  `uri-steady` Block allocations = 1 per run. This is a pin of *current
  policy with its reason*, to be deliberately replaced by the family-1b
  milestone, not a permanent contract.

### D. Test hygiene (no production change)

- Fix `funcHeaderCount` to return the count, and correct its two
  assertions (the `byte::set` fixture has 2 headers).
- Add legal twins for:
  - M6 `condition-outcome-12` (S03b);
  - M5 shared-instance `byte::set` (a handled caller whose argument is
    *declared* `List[UnicodeChar]` but dynamic);
  - M4 empty-list (a declared-result `List[int]` producer).
- Replace M5's `-from-int` "dynamic" caller with a genuinely
  unconstrained one (S03b).
- Mark the originals as "non-strict analysis of a rejected program", or
  retire them.

## Rejected/deferred theorem ideas

| idea | decision | why |
|---|---|---|
| closure argument-kind identity (naive 1b) | **REJECT** (naive form) | measured regression; breaks blockescape |
| closedness theorem + entry-kind join for closed generic instances (the real family-1b fix) | **DEFER → dedicated milestone** | removes up to 36 of 38 corpus guards at 0 instance growth, but needs a pre-specialization escape analysis (new global theorem) and a reworked `OpenInstances`: larger than M7.b |
| dead materialized `fnvalue` (`Emailish?` generic copies: 2 guards, 2 × 769 B) | DEFER (RC5/F14 work) | not an instance-selection problem |
| callable identity through parameters | REJECT as identity; revisit as an entry theorem with closedness | no corpus benefit; bounded only by the limit |
| exact values, exact sets, range classes, capture values, container contents, completion surfaces in keys | **REJECT AS INSTANCE IDENTITY** | unbounded or unstable; each has a correct entry/call-edge home |
| feasibility-aware narrowing: exact-set emptiness, `==` impossibility in completions, `If` treating impossible branches as dead | DEFER (after A) | each changes codegen facts or **legality** (UNHANDLED/KNOWN-ERROR), so each needs its own review |
| result-summary hysteresis fix (recompute non-recursive instance results per round) | DEFER | transport precision; no corpus site found; touches the `hir::range` fixpoint |
| capture Range theorem (join creation-site Ranges into closure instances) | DEFER | missing, sound, zero identity cost; only synthetic evidence (S08a) |
| condition removability | DEFER | small codegen residue only |
| `not`/`!=`/`and`/`or` composition | DEFER | expression theorem; low corpus incidence |
| container-content propagation into instances | KEEP SILOED (call edge) | see above |
| `List[never]` empty-list identity | DEFER (policy question) | sound; one duplicate instance per affected block |
| unify completions' native result table with `hir::range`'s | DEFER | silo, no current disagreement that changes an answer |
| `encode_utf8` `{list Byte}` canonicalization | fix separately (bug) | admissibility defect, not a theorem-model question |

## Recommended M7.b scope

```text
M7.b
    1. FORMALIZE hypothesis satisfiability (A): one explicit tri-state
       query in hir/range.tcl, strength-preserving; ConditionOutcome and
       hir/completions.tcl consume it; nothing reads min > max any more.
    2. TRANSPORT the declared aggregate parameter theorem (B) into
       specialized instances. Entry theorem, zero identity change.
    3. PIN the reviewed identity semantics (C), including the explicit
       rejections (values/ranges/sets/evidence/env values/completion
       facts are not identity) and the closure-policy/blockescape
       precondition.
    4. REPAIR the illegal and vacuous fixtures (D).
    5. Add regression coverage: positive, negative, adversarial
       shared-instance, determinism, code-explosion bound.
    6. Re-run the frozen census (tools/corpus.tcl) and require it to be
       unchanged: uri-steady 19/17/7055 B/14 guards, refined-checks
       39/33/16743 B/24 guards.

    Everything else deferred.
```

Why this size: items 1 and 2 are the only changes that are *both* (a)
consistency repairs of theorems the compiler already proves, and (b)
neutral on identity and instance counts by construction, and measured
neutral on the frozen corpus. Item 2 does change codegen facts for
programs with declared `List[T]` parameters reached through a
specialized instance. That is its purpose (S05d).
Everything that would move the corpus changes either identity (rejected
above) or legality/codegen facts (needs a separate review). The item
with the largest corpus value, family 1b, needs a new global theorem
(closedness) and a pass-ordering change.

## Testing recommendations for M7.b

- **Satisfiability query:**
  - interval-impossible → `impossible` (`b > 255`, `b < 0` for Byte;
    `s < 10` for Small);
  - unbounded → `none`;
  - satisfiable → facts;
  - agreement between ConditionOutcome and completions on those cases;
  - S03b stays Unknown;
  - documented-limitation tests (asserting *today's* answers, labeled as
    such) for S12a, S12b and S11;
  - **no** test on `min > max`.
- **Declared aggregate seed:**
  - S05d: AlwaysFalse in `f<List[int]>`;
  - S05e: equal element views for the specialized and generic
    instances;
  - an undeclared list: no evidence;
  - nested `List[List[Byte]]`;
  - `f([])` for a declared `List[int]`: still the TYPE diagnostic;
  - census unchanged.
- **Identity pins:**
  - S01: one instance;
  - S02c: one instance, entry `{5,500}`;
  - HighNibble and Int callers share;
  - S08a: one `add<int>`;
  - S09: one `from_int<int>` with two distinct `effectiveErrors`;
  - S06b: one set instance;
  - S07b/S07d: `call`/`callenv`, no `callvalue`.
- **Determinism:** reordering independent calls keeps labels and entries
  identical; an identical re-run gives an identical table.
- **Code-explosion bound:**
  - `uri-steady` and `refined-checks` used-instance counts are ≤ today's
    (19, 39);
  - `uri-steady` Block allocations = 1 per run;
  - `refined-checks` = 2 (already pinned).
- **Hygiene:** a fixed `funcHeaderCount`, and legal twins.
- **GC stress:** M7.b items 1–4 touch no root, safepoint, GC, layout,
  closure-environment or stack-map code. Rely on CI `gc-stress`.

## GC-stress policy note

Local GC stress was not required or run. M7.a changed no GC-sensitive
production behavior; in fact it changed no production file at all.

CI GC-stress status: **success**. Workflow `tests`, run 109 on `main`
at `993c96a` (the commit M7.a builds on), job "tests (native
GC-stress)": completed, conclusion *success*.

## Tests run for M7.a

What was run, on this tree (`cb7f3a7` + this section; no production
file differs from `993c96a`):

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
    backend interp:  Total 2185  Passed 2185  Skipped 0  Failed 0
    backend compile: Total 2185  Passed 2185  Skipped 0  Failed 0
    (13m46s wall; 77 test files; the native backend was built with
    `cargo build --release`, so native-* tests exercised it)
```

The audit tools were run end to end (see "Audit tooling and
artifacts"). The census `baseline` variant reproduces M6's post-M6
figures exactly (7055 B / 17 functions and 16743 B / 33 functions), and
the natively-run program values (29500; `[400, 0]`) match
`bench/uri-steady.tcl`'s and `bench/bench.tcl`'s expectations.

Not run, deliberately:

- `cargo test`: no Rust file changed.
- Local `BOTLISH_NATIVE_GC_STRESS=1`: not required; see the GC-stress
  note.
- `tests/native-coverage.tcl` and the benchmark timing harnesses: no
  production behavior changed, so there is nothing to compare.

No test file was added or modified. Per spec #59/#60, this milestone
adds no contract tests; in particular there is no `Narrowed` invariant
test.

## Source-fence confirmation

- No `.bot`, `.ir` or `.hir` file changed; the frozen workloads
  (`bench/uri-steady.bot`, `bench/refined-checks.ir`, `lib/*.bot`,
  audit probes) are untouched.
- No file under `hir/`, `native/`, `core/`, `compiler/`, `surface/`,
  `lib/`, `bench/` or `tests/` changed.
- New files only: this report and `audit/m7a-instance-selection/`
  (non-production tools and their outputs).
- The counterfactual tool redefines one `hir::specialize` proc *inside
  its own audit process*, by checked textual substitution. A compiler
  process never sources it.
- KeyType, specialization policy, instance identity, callable escape
  rules, closure specialization, capture lowering, `hir::range`,
  `hir::completions`, native/branch lowering, Narrowed/empty-range
  semantics, inlining, ABI and source syntax are all unchanged.
- The FINAL SEMANTIC SOURCE FENCE remains intact.

## Required architecture questions

1. **What exact data determines instance identity today?** The block
   ExprId and one KeyType per parameter:
   - the kind, recursively for List element kinds, with rare positional
     shapes;
   - after the closure policy (non-Int-capturing closures → all `any`);
   - after self-tail widening (lub with the running instance's key);
   - after the per-block limit of 8 (→ generic, discovery-ordered).
2. **What facts refine an instance only after selection?**
   - the declared parameter type (M1);
   - RefineParams evidence;
   - capture seed types;
   - joined entry Ranges (non-open instances);
   - induction proofs;
   - callee result types and Ranges.
3. **What facts are retained only at a call edge?**
   - `effectiveErrors`, `mayReturnNormally` and `resultRangeFact`
     (`hir/completions.tcl`);
   - literal container contents;
   - literal argument values once joined;
   - a callable target passed through an untyped parameter.
4. **What facts are path-local?** Comparison narrowing (incl. exact-set
   filters and induction-proved `==` guards) and type-test refinements
   (`hir::refine`).
5. **What facts are capture-specific?** Capture seed *types* (lub over
   creations) and exact callable identity of captured functions.
   Capture values and Ranges are not tracked.
6. **What facts are currently missing entirely?**
   - closedness (pre-specialization);
   - entry-kind joins for closed generic instances;
   - capture Ranges;
   - explicit hypothesis impossibility (encoded implicitly);
   - exact-set and `==` impossibility in the legality layer;
   - condition removability;
   - Bool-`if` outcome composition;
   - a listloop element Range from container contents.
7. **Does KeyType encode scalar literal values?** No (S01).
8. **Does it encode ranges?** No (S02b/c).
9. **Does it encode exact finite sets?** No (HighNibble → `int`).
10. **Does it encode callable identity?**
    - Exact captures/aliases: not in the key. The identity survives as a
      static *type* (capture seed / binding type), so the call is direct.
    - Ordinary callable parameters: the key erases it to `block`.
11. **Does it encode container contents?** No.
12. **Does it encode container element type?** For Lists, yes: element
    kind, recursively (depth ≤ 3). For ImmutableSets, no.
13. **Does it encode nominal refined types?** No. Evidence is erased
    (top level and inside List elements).
14. **How does `never` participate?**
    - `List[never]` is kept (empty-list callers get their own instance);
    - `ImmutableSet[never]` erases to `immutableSet`;
    - a `never` argument type means a dead call, which is never keyed;
    - an instance result starts as `never`, the optimistic fixpoint
      bottom.

## Required List[never] questions

15–19: answered in "List[never] / empty-container semantics" above.

## Required callable questions

20–24: answered in "Callable identity audit" above. Summary: 20 exact
static types through immutable bindings; 21 KeyType erasure; 22 policy
and explosion control, not soundness (soundness of the erasure is
guaranteed by `hir::callables`); 23 targets × HOF body size, capped by
the limit, with no corpus benefit (0 `callvalue`); 24 no.

## Required family 1b questions

25–34: answered in "Family 1b / RC1 reclassification" above.

## Required M6-theorem questions

35. **Which ConditionOutcome inputs derive from instance identity?**
    None. The attribution tool's "identity" tier (TypeFact of the key
    type) decided 0 of 87 corpus conditions and 0 of the synthetic ones.
    KeyType carries no integer facts. Identity matters only indirectly:
    it partitions callers, and so decides *which* join an entry Range
    is.
36. **Which derive only from entry facts?**
    - the corpus: both corpus Range decisions (`byte::from_int`'s
      `BelowRange`, via `char::codepoint`'s native metadata joined into
      the entry);
    - synthetic: S01, S02a, S02b, S02f, S03a, S09, S10, S11, S12d, S13,
      S14, S15 (15 of the 25 synthetic decisions; the other 10 are
      `declared` 6, `view` 3, `full` 1).

    Declared-type decisions (S04: the `declared` tier) and RefineParams
    or capture-seed decisions (S04b, S08c: the `view` tier) are entry
    theorems too, applied at refs.
37. **Which derive from path narrowing?** The M6 nested `x >= 0` / `x <
    0` fixture, and locals derived from narrowed or declared values
    (S05e's `full` tier). No corpus decision needed path narrowing.

    Counter-example to "path facts only add": in S11 the *entry* fact
    decides the second `x == 3` (entry `{5}`), but the path-level fact at
    that point is `{3,5}`, because the preceding `if x == 3` stored the
    impossible `x := 3` in its dead branch and joined it. So the
    production answer is Unknown. The attribution tool reports this as
    `lost-after-entry`. It is the only such case among the 135 observed
    conditions (87 corpus, 48 synthetic).
38. **How much stronger would M6 become under each proposed M7.b
    theorem?**
    - A: not at all (strength-preserving, by design).
    - B: 0 corpus decisions (measured); +1 synthetic (S05d).
    - Deferred strengthenings: S12a/S11 in synthetic tests, 0 found in
      the corpus.
    - The deferred closedness + entry-kind theorem would mostly remove
      *guards*, not decide branches. The corpus's Unknown comparisons
      are genuinely unknown (Byte ASCII-class tests over `[0,255]`,
      scanner bounds against runtime lengths).
39. **Are there proposed identity changes whose only consumer would be
    ConditionOutcome?** Yes:
    - range-class keys;
    - exact-value keys;
    - exact-set keys;
    - container-content keys.

    Their only benefit is deciding comparisons inside a split instance.
    All are rejected above.

## Required Narrowed questions

40–45: answered in "Narrowed / impossible-hypothesis semantic audit"
above. Recommendation: **REFINE** (M7.b: explicit, strength-preserving
query; strengthening deferred).

## Required missing-theorem questions

| # | proposition (46) | owner (47) | scope (48) | producers (49) | consumers (50) | identity? (51) | why not in M7.a (52) |
|---|---|---|---|---|---|---|---|
| closedness | "block B's Block value never reaches a dynamic call" | pre-specialization escape analysis (`hir::aot` / hoisted `hir::blockescape`) | global | materialization + use analysis | `OpenInstances`, entry-kind join | no | new analysis + pass ordering; audit-only milestone |
| entry kind | "every caller of closed instance I passes kind K at p" | `hir::specialize` (sibling of RefineParams) | entry | call-site region types | region inference → guards, raw repr, result kinds | no | depends on closedness |
| capture Range | "every creation of closure C captures b ∈ R" | `hir::range` | capture | creation-site Ranges | refs of captured bindings | no | Range-analysis change (forbidden in M7.a) |
| explicit impossibility | "hypothesis H is unsatisfiable here" | `hir::range` | expression | narrowing arithmetic | ConditionOutcome, completions, `If` joins | no | M7.b item A |
| exact-set / `==` impossibility | same, using exact sets and point membership | `hir::range` | expression | exact sets | same | no | changes codegen facts / legality |
| removability | "E is total and effect-free" | expression summary next to KnownOutcome | expression | native metadata, completion facts | `native::lower::If`, DCE | no | purity analysis forbidden in M7.a |
| Bool-`if` composition | "if the decided arm is a Bool constant, the outer outcome is known" | ConditionOutcome / KnownOutcome | expression | KnownOutcome, ConditionOutcome | `If` | no | expression milestone |
| listloop element Range | "loop element ∈ R" from contents or entry | `hir::range` | path/entry | container contents (call edge) or entry joins | the loop body | no | container-content propagation forbidden |
| settled result summary | "result of I under converged entries" | `hir::range` | result | `SettleInstance` | callers, ClosedResult | no | fixpoint change forbidden |

## Required code-explosion questions

53–57: answered in "Code-explosion analysis" above.

## Required determinism questions

58–62: answered in "Determinism audit" and "Monotonicity audit" above.

## Recommendation table

| Candidate | Current state | Correct scope | Recommendation | M7.b? |
|---|---|---|---|---|
| callable identity through ordinary parameter | erased by KeyType → `callvalue` | entry (with closedness) if ever | REJECT AS INSTANCE IDENTITY; keep erasure | no |
| callable identity through alias/capture/result | preserved as static type → direct call | expression/capture | FORMALIZE EXISTING (pin) | yes (pins) |
| scanner / URI-helper index and parameter kinds (family 1b) | lost: closure policy + openness | entry (closed generic instances) | DEFER to a closedness + entry-kind milestone; REJECT naive identity | no (pin the precondition only) |
| scanner index range | unknown (open) | entry | DEFER (follows the kinds) | no |
| container literal contents | call edge (completions) | call edge | KEEP SILOED; REJECT AS IDENTITY | no |
| condition removability | missing | expression | DEFER | no |
| `not` outcome composition | missing | expression | DEFER | no |
| hypothetical narrowing impossibility | implicit `min > max`, two readers, inconsistent on `==`/exact sets | theorem query (expression) | FORMALIZE (REFINE, strength-preserving) now; strengthen later | yes (A) |
| List[never] observed shape | identity for undeclared params; only in rejected programs for declared ones | identity (undeclared) / admissibility | FORMALIZE EXISTING (pin the two behaviors, not the key text); DEFER the policy | yes (pins) |
| declared List[T] element evidence in specialized instances | lost (M1 gap) | entry | TRANSPORT EXISTING | yes (B) |
| ImmutableSet element type | erased from key, restored from declaration or capture | entry/capture | KEEP (pin) | yes (pins) |
| scalar literal values | not identity | call edge → joined entry | REJECT AS INSTANCE IDENTITY (pin) | yes (pins) |
| ranges / exact sets / nominal evidence | not identity | entry | REJECT AS INSTANCE IDENTITY (pin) | yes (pins) |
| closure environment values | not identity | capture | REJECT AS INSTANCE IDENTITY (pin) | yes (pins) |
| capture Ranges | missing | capture | DEFER (IMPLEMENT later) | no |
| completion/effect surfaces | call edge | call edge | KEEP SILOED; REJECT AS IDENTITY (pin) | yes (pins) |
| result-summary hysteresis | coarse (round-1 locked) | result | DEFER (TRANSPORT EXISTING later) | no |
| native result metadata silo (completions table) | duplicated | result (global) | DEFER | no |
| `encode_utf8` `{list Byte}` | non-canonical type; inadmissible for `List[Byte]` | – | fix as a bug, separately | no |
| dead materialized `fnvalue` (`Emailish?` copies) | 2 guards + 1538 B | global (RC5) | DEFER | no |
| illegal/vacuous test fixtures (M4/M5/M6) | observe rejected programs; `funcHeaderCount` vacuous | tests | REPAIR | yes (D) |

## Audit tooling and artifacts

All under `audit/m7a-instance-selection/`. Every tool is read-only with
respect to the compiler except `counterfactual.tcl`, which patches one
proc *in its own process* and says so.

| file | what it does |
|---|---|
| `tools/lib.tcl` | shared helpers: load a program (non-strict), run the analyses `native::lower::program` runs, print instance tables, ConditionOutcome with fact-tier attribution (cross-checked against the production query; mismatches are flagged), representation-blocker attribution with call-site argument kinds, NIR op counts, and the census |
| `tools/keytype.tcl` | the KeyType preservation/erasure table → `artifacts/keytype.txt` |
| `tools/scenarios.tcl` | 38 synthetic/adversarial scenarios (S01–S15) → `artifacts/scenarios.txt` |
| `tools/corpus.tcl` | frozen-corpus census → `artifacts/{uri-steady,refined-checks}/` |
| `tools/determinism.tcl` | re-run, reordering, limit and caller-ladder observations → `artifacts/determinism.txt` |
| `tools/counterfactual.tcl` | what-if variants `baseline`, `closure-kind-identity`, `declared-aggregate-seed` → `artifacts/cf-*/` |

Attribution tiers, as `m7a::conditionData` defines them. Each tier's
operand Range is used to recompute the M6 rule with the same pure
primitives, and the weakest tier that reproduces the production answer
is reported:

- `identity`: TypeFact of the instance key type;
- `declared`: the declared parameter type;
- `view`: the parameter ref's view type (declared + RefineParams +
  refinements; for captures, the seed type);
- `entry`: the stored entry Range ∩ view;
- `full`: `hir::range::of`, including path narrowing.

A tier that decides while production says Unknown is reported as
`lost-after-TIER`. A disagreement is reported as `CONTRADICTION` or
`TOOL-MISMATCH`; none occurred.

A tool limitation: the `file:line` column for a few call nodes inside
library `listloop`s prints the *program's* file name with the
*library's* line number (e.g. `probe8.bot:176` is `lib/byte.bot:176`,
the call inside `byte::set`'s loop). The ExprId is authoritative.

Reproduce (from the repository root, `LANG=C.utf8 LC_ALL=C.utf8`, native
backend built):

```sh
tclsh9.0 audit/m7a-instance-selection/tools/keytype.tcl
tclsh9.0 audit/m7a-instance-selection/tools/scenarios.tcl
tclsh9.0 audit/m7a-instance-selection/tools/corpus.tcl bench/uri-steady.bot audit/m7a-instance-selection/artifacts/uri-steady
tclsh9.0 audit/m7a-instance-selection/tools/corpus.tcl bench/refined-checks.ir audit/m7a-instance-selection/artifacts/refined-checks
tclsh9.0 audit/m7a-instance-selection/tools/determinism.tcl
tclsh9.0 audit/m7a-instance-selection/tools/counterfactual.tcl closure-kind-identity bench/uri-steady.bot OUTDIR
```
