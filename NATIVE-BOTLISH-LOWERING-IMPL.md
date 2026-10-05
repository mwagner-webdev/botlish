# Native lowering in Botlish: what it would take

**Status: analysis and design notes, nothing implemented.**

The question: what would it take to implement `native/*.tcl` (HIR → NIR
lowering) in Botlish itself? The working assumptions:

* Basic I/O, external process execution and `context` are available.
* A Botlish test framework exists.
* Not much more.

This document collects the measurements, the interface and architecture
analysis, the language features the port needs, and the decisions reached
while discussing them. The mutual-recursion construct has its own design,
MUTUAL-RECURSION.md, and is only referenced here.

## Contents

1. Where compile time goes
2. Scope: two items
3. The interface: a "lowering input"
4. Architecture in Botlish
5. Mutual recursion in `native/lower.tcl`
6. Language features
7. DSLs
8. Library and runtime prerequisites
9. Bootstrap and migration
10. Open questions

## 1. Where compile time goes

### Method

* Commit `08b81e7`, Tcl 9.0.1, warm second run in the same process.
* Each analysis entry point was wrapped with a timer that calls the original
  through `uplevel 1`, because several of them `upvar` into their caller.
* Times are exclusive: a wrapped call's time excludes wrapped calls nested
  inside it.
* "lower.tcl proper" is `native::lowered` minus `prepareHir` and every
  wrapped analysis.

### Split by stage

| stage | csv_records.bot (532 lines) | matmul with 32×32 literal matrices |
|---|---|---|
| frontend: parse, resolve, type inference, checks | 833 ms (50%) | 1088 ms (43%) |
| `hir::` analyses called by `native::lowered` | 659 ms (40%) | 873 ms (35%) |
| `native/*.tcl`: lower.tcl proper + shortstring + rawabi | 136 ms (8%) | 551 ms (22%) |
| Cranelift (`native::measure` compile time) | 27 ms (2%) | not measured |

**Breakdown on csv_records.bot:**

* `native/*.tcl`:

  | part | ms |
  |---|---|
  | lower.tcl proper | 84 |
  | `native::shortstr::plan` | 42 |
  | `native::rawabi::plan` | 11 |

* Analyses:

  | analysis | ms |
  |---|---|
  | `hir::specialize::view` (851 calls) | 217 |
  | `hir::range::analyze` | 185 |
  | `hir::specialize::analyze` | 115 |
  | `hir::escape::analyze` | 58 |
  | `hir::stringregion::analyze` | 30 |
  | `hir::aot::analyzeRegion` | 25 |
  | `hir::blockescape::analyze` | 14 |
  | `hir::construction::analyze` | 12 |
  | `hir::traversal::analyze` | 3 |

* Frontend:

  | part | ms |
  |---|---|
  | `hir::signatures::infer` | 249 |
  | `hir::semantic::verify` | 180 |
  | the rest of `hir::check` | 133 |
  | `surface::parse` | 123 |
  | `hir::resolve::program` | 36 |
  | the rest | — |

The repository's own audit agrees on the split:
`audit/direct-hir-native-path/out/compiletime-after-direct.txt`, 17
programs:

| column | ms | share |
|---|---|---|
| frontend | 1979 | 41% |
| `prepareHir` | 225 | 5% |
| `lower::program`, i.e. analyses + lowering | 2423 | 51% |
| Cranelift | 142 | 3% |

### Scaling

The test programs are synthetic: N functions of about 10 lines each, where
`fi` calls `f(i-1)` in both branches of an `if`.

| N (lines) | frontend | `native::lowered` | `hir::range::analyze` | `hir::specialize::view` | lower.tcl proper |
|---|---|---|---|---|---|
| 50 (507) | 1.1 s | 2.1 s | 1.36 s | 0.27 s (774 calls) | 89 ms |
| 100 (1007) | 2.3 s | 7.9 s | 5.44 s | 1.06 s (1524 calls) | 206 ms |

* **lower.tcl proper scales roughly linearly.**
* **Range analysis and view construction grew about 4× per doubling** in
  these measurements, at `08b81e7`.
  * **Range analysis: fixed since then** (RANGE-FIXPOINT-SCALING.md).
    * The cause was confirmed as the whole-program round structure: a fact
      crosses one call edge per round, and every round re-walked every
      instance, in `Fixpoint` and in `NarrowRounds` alike.
    * Both now redo only the work whose inputs changed, with identical
      results.
    * Per that document, `native::lowered` on the 100-function chain is now
      2.77 s, 1.06 s of it in views. Its own timing section is still
      pending.
  * **Views: still open.**
    * `hir::specialize::view` copies the whole `exprs` table (and
      `bindings`) on every call. That is a Tcl copy-on-write of a shared
      dict.
    * About 26 static call sites build 15–25 views per instance per compile.
      None are shared between analyses.
    * RANGE-FIXPOINT-SCALING.md §5 breaks the calls down by caller. It
      concludes that a per-instance cache removes the factor of 15, but
      only an overlay representation removes the O(program) copy.
* **At N = 200 (2,000 lines) the frontend fails.**
  * It hits Tcl's `too many nested evaluations` in `hir::completions`. Each
    level of the static call chain costs about nine Tcl frames, so the
    threshold is about 110 levels.
  * Diagnosed, with a proposed fix, in RANGE-FIXPOINT-SCALING.md §6; not
    fixed yet.

### Consequences

* **Item A (`native/*.tcl`) alone moves 8–22% of compile time.** That is
  before serialization costs.
* **Item B (the analyses) is where the time is,** and the superlinear part is
  algorithmic. Porting a quadratic algorithm buys a constant factor.
* **Fix the remaining superlinear terms in Tcl first.** The range rounds are
  done. Still to do:
  * view copying: a per-instance cache, then an overlay representation;
  * the completions depth failure.

  This is cheaper than porting, needed for bootstrapping anyway (§9), and
  independent of the port.

## 2. Scope: two items

### Item A: `native/*.tcl`

| file | lines | code lines |
|---|---|---|
| `lower.tcl` | 8,624 | 5,347 (191 procs) |
| `shortstring.tcl` | 1,562 | 1,267 |
| `rawabi.tcl` | 895 | 652 |

`native.tcl` (the driver and reports) and `prepare.tcl` would stay in Tcl.
`prepare.tcl` re-enters the frontend: it attaches native implementations and
re-runs `hir::check`.

### Item B: the `hir::` analyses on the native path

* **Code size:**
  * The analyses themselves: specialize, range (with rangerec, induction,
    exactvalue, cardinality), escape (with transport), blockescape,
    stringregion, traversal, construction, aot. About 14.5k lines, 9.2k code.
  * The fact sources they lean on: completions, callables, and types'
    lattice and helpers. About 4.8k lines, 3.0k code.
* **Algorithmic shape:** nothing exotic.
  * Forward abstract-interpretation tree walks.
  * Bounded worklists and rounds.
  * Monotone set fixpoints (`while {$changed}`).
  * Union-find; an iterative Tarjan SCC (`transport.tcl`).
  * Budgets everywhere: specializer 8 instances per function and 1000 in
    total, range rounds 4·|used|+16, completions `maxAnalyses` 256, and so
    on.
  * No unification.
* **Arithmetic:**
  * Ranges are `{min max ?exact?}`, with bignum bounds and the string
    sentinels `-inf`/`+inf`. Bounds beyond i64 really occur: `U64Value`,
    products of 2^62 bounds, shifts up to 4096 bits.
  * Botlish's arbitrary-precision Int is an advantage here. There is no
    `incr` i64-wrap workaround and no custom comparator for 64-bit
    `lsort -integer`.
  * ±inf needs a tagged-union bound.
  * `transport.tcl`'s cost model uses floats (`argFactor 1.0`,
    `returnSpill 1.5`, `densityWeight 0.5`), and Botlish has none. All of
    them are dyadic fractions, so scaled integers reproduce every decision
    exactly.
* **The catch: specialization re-runs type inference per instance.** It
  calls `hir::types::inferRegion` through a callback that can re-enter
  `Analyze`.
  * Porting Item B therefore ports the inference walker and the type
    lattice: `lub`/`glb`/`subtype`, about 30 mutually recursive procs in
    `hir/types.tcl`.
  * The clean cut for Item B is right after `hir::check`: the input is
    checked, typed HIR.

The frontend proper (parse, resolve, semantic, signatures, warnings) is a
third item, outside this document.

## 3. The interface: a "lowering input"

### What lowering reads today

About 125 distinct `hir::`/`core::` procedures from about 600 call sites, in
three classes:

* **Plain accessors.**
  * Node, binding and symbol fields; `hir::typeOf`; children and roots.
  * Pure functions over type forms (`kindOf`, `IsEqualityTotal`,
    `StructLayout`, …).
  * Registry lookups: `core::native::metadata`, builtin errors, struct
    declarations.
  * Runtime-value decoding of constants: `core::value::*`, bignum constant
    folding through `core::scalarbits::shiftRight`.
* **Whole-program analyses.** All run by `native::lower::program` itself
  (`lower.tcl:1341–1399`) and kept in namespace variables, not in HIR.
* **Queries into analysis results,** keyed by instance, binding or
  expression:
  * `hir::range::of`/`fitsSmall`/`ConditionOutcome`;
  * `hir::escape::*`, `hir::stringregion::*`, `hir::blockescape::*`;
  * `hir::traversal::plan`, `hir::construction::*Family`.

### Why "every fact up front" does not describe today's HIR

HIR itself mostly is computed up front: resolution, types, and the stamps
the frontend writes onto nodes (`known`, `reachable`, `boundsVerdicts`, …).
What lowering reads beyond HIR is computed while lowering runs:

* **The native-path analyses are not part of HIR at all** (above).
* **Per-instance facts exist only as views built on demand.**
  * Every emitted function variant builds a fresh view of its instance and
    runs `hir::aot::analyzeRegion` on it (`lower.tcl:2097–2098`, repeated in
    six more builders).
  * Inlining does the same per call site (`:6221`, `:6381/6397`,
    `:6578/6593`).
* **Several facts are computed by running analysis code where they are
  used:**
  * `hir::exact::Of`/`IntOf`/`ListOf` (`:3889–3942`), a 64-step evaluator;
  * `hir::syscall::Problems` and `BytesProblems` (`:3665`, `:3969`);
  * `hir::stringregion::classify` (`:6016`);
  * `native::shortstr::tier` and `localVirtual` (`:2026`, `:4463`): lazy and
    memoized. The shortstring planner also calls back into lowering's own
    state through `native::lower::DemandCallTagged`.
  * `hir::induction::ClassifyArg` and `hir::escape::Exits`
    (`shortstring.tcl:1103`, `:911`).

Inside one Tcl process that laziness is fine, and often good design. Across
a language boundary, each such call must become either data in the input or
code that is ported. "Up front" means *nothing in the input needs a call
back into Tcl*. For some facts, porting the derivation is cheaper than
serializing it:

* `hir::aot::BlockName`;
* `ConditionOutcome`, which is `KnownOutcome` plus a comparison of two
  operand ranges.

### Why today's facts are not serializable as they are

* **`construction` embeds views.** On csv_records its string form is 41 MB,
  almost all of it the `regions` entry, which embeds per-instance HIR views.
  For comparison, the HIR itself is 684 KB as a raw dict string, 80 KB as
  `hir::format` text, written in about 10 ms.
* **View TypeIds are local to each view.** `intern` adds to the view's own
  `types` table.
* **Global registries live outside the HIR dict:** `core::type`,
  `hir::structs`, the native registry and the builtin errors.
* **`hir::format`/`hir::parse` are debugging formats.** They do not carry:
  * module sections (`modules`, `moduleScopeIds`);
  * `semantic`;
  * `moduleNativeTargets` or `bridge`;
  * `nativeResultOverride`;
  * `violatedDeclared`/`demotedContracts`;
  * the completions and lockstep stamps.

### Design of the input

* **Dense integer ids** for expressions, bindings, scopes, types, instances
  and functions. Most lookups on the Botlish side then become List or
  MutableArray indexing rather than hashing.
* **Base HIR tables plus sparse per-instance overlays** of type, known,
  reachable and call target. No materialized views, and one program-wide
  type table.
* **Every fact that needs Tcl code to compute,** precomputed per instance:
  * the region analysis's guards and known errors;
  * exact values and syscall problems where lowering asks for them;
  * region classification;
  * shortstring tiers and local virtuals;
  * induction classes;
  * escape exits.
* **The registries' relevant parts and the options.** There are about 33
  `BOTLISH_NATIVE_*` knobs, read today through `info exists ::env`.
* **Text first.** Binary only if parsing shows up in profiles.

**Validation:** make the Tcl lowerer read the deserialized input before any
porting. When it produces byte-identical NIR from the file across the suite
and the corpus, the format is complete. That byte-identical NIR then serves
as the oracle for the Botlish port.

## 4. Architecture in Botlish

| Tcl today | Botlish shape |
|---|---|
| About 40 namespace variables set once per program (analysis results, options) | One immutable `Cx` struct as the first parameter; method sugar reads well (`cx.range_of(e)`) |
| Program-wide accumulators: `usedNatives`, `shapeIds`/`shapeList`, `staticSlots`, `errorIds`, the `pending` worklist, the leaf-inline memo, `parents` | Each function's lowering returns what it used. A final pure *link* step assigns numbers in lowering order. This generalizes today's placeholder step: function ids are emitted as `\x01id.mode\x02` (`Placeholder`, `:1839`) and replaced by `string map` over every function's text and info (`:1460`). |
| The `fn` builder dict, passed by `upvar` (106 procs) | Split it, see below |
| `specialize::view`: copy the HIR, then overlay | `View {base, overlay}`, looking up the overlay first. Immutability makes the cheap design the obvious one; in Tcl, copy-on-write made the copy the obvious one. |
| String-encoded tags | Tagged unions (§6.2) |
| `"never"` checked 96 times | A declared error (`fail Abrupt`), which propagates through `errors` clauses, or a union result |
| NIR built by interpolation (94 `Emit`, 96 `Assign*`, 43 `Quote`) | Structured instruction values, printed once at the end |
| 11 regexps over text just emitted | Structural queries |
| `throw {NATIVE BUG}` (about 60) | An abort primitive |
| `{NATIVE UNSUPPORTED}` with location and message | A declared error. Botlish errors carry no payload, so the message is recorded in the emitter first. |
| `dict`/`lsearch` lookups keyed by id | List/MutableArray indexing with dense ids. A typed map (§8) for the rest: type forms, `{expr operand}` guard keys. |
| `lsort -integer -index` chains (`:1457`) | A stable library sort with a key |

**String-encoded tags today:**

* 10 access kinds (`reg`, `rawreg`, `shortreg`, `region`, `fnvalue`, `self`,
  `virtual`, `pieces`, `plan`, `static`);
* 6 representation requests (`tagged`, `raw`, `rawjoin`, `short`, `ascii`,
  `region`);
* 7 function modes;
* about 20 HIR kinds;
* the NIR ops;
* range bounds.

**The regexps over emitted text:**

* counting `tail` lines in each of the 7 function builders (`:2221`, …);
* `AddressFlowAcrossCall` re-parsing the last 16 lines (`:5170`, `:5178`);
* `KeepAddrFlow` splitting the instruction text (`:2936`);
* parsing the `unproven` stamp (`:7943`).

### Splitting the `fn` builder dict

* **Scoped state becomes an immutable `Scope` passed downward.** This is the
  locals map and the raw cache. `Bind` returns the extended scope to the
  sequence that threads it. The 25 save/restore sites (`set saved …`, then
  `dict set fn locals $saved`, in `If` and the loops) disappear.
* **Monotone state goes into one mutable `Emitter` handle.** This is emitted
  code, register and label counters, statistics, `rawRegs`/`shortRegs`,
  `keepAddr`, `calls`, loop labels. MutableArray-backed, as
  `examples/stdlib/hashtable.bot` builds a mutable record.

A purely functional emitter is the more Botlish-like end state:

* Fragments are returned as values.
* Registers are named by HIR expression and renumbered at link time.

It cannot, however, reproduce Tcl's register numbering, which follows
allocation order (an `If` allocates its join register before lowering its
branches). A byte-identical port needs that numbering. So: a mutable emitter
for the port, a functional one possibly afterwards.

### Determinism the port must reproduce

Tcl dicts iterate in insertion order, and lowering relies on that:

* the `pending` FIFO and the `functions` dict (`:1426`);
* capture lists built from `dict keys` of `context exprs` (`:1406`);
* iteration over the `guards` keys;
* `foreach {e target}` over a call map;
* first-use numbering of shapes and static slots;
* the specializer's instance ids, assigned in discovery order.

There are also explicit sorts:

* three chained stable `lsort`s for function order (`:1457`);
* `lsort` of array names in `rawabi.tcl`;
* `lsort -command` in `shortstring.tcl`.

## 5. Mutual recursion in `native/lower.tcl`

Static call graph of `native/lower.tcl` at commit `9d61c19` (comment lines
excluded, edges checked by hand):

* **One strongly connected component of 36 of the 191 procs.** The rest are
  acyclic or call only themselves.
* **Eight procs call themselves,** which Botlish already allows:
  * `Expr`, `StructFields`, `BuildStruct`;
  * `EmitRegionConsumerBody`, `LeafExprStructural`, `LeafExprEligible`;
  * `ConstantIntValue`, `PureIntOperand`.

**The hub is `Expr` (`:3224`).** It dispatches to:

* `Bind` `:3250`, `Call` `:3252`, `If` `:3254`;
* `Loop`/`ListLoop`/`CountLoop`/`LockLoop` `:3262–3265`;
* `Struct` `:3266`, `Project` `:3267`;
* `VirtualValue` `:3277`, `SequenceTo` `:3297`, `Handle` `:3361`.

Nearly everything calls back into `Expr` directly or through `Sequence`
(`:3216`):

* `Bind` `:4443`; `If` `:7487`;
* the loop forms: `ListLoop` `:7649`, `CountLoop` `:7830`, `LockLoop`
  `:7968`, `Handle` `:8133`;
* `StructFields` `:3455`, `Project` `:3627`;
* `CallInner` `:5364…`, `CallArgs` `:4829`;
* `TryShortStringOp` `:5815`, `TryStringRegionOp` `:6073`, `TraversalAccess`
  `:5966`;
* `SyscallWords` `:3758`, `RegisterWordOf` `:3800`, `StorageOf` `:4036`;
* `InlineLeafCall` → `Sequence` `:6609`; `InlineRegionConsumerCall` `:6217`;
* `SequenceTo`/`Raw`/`Short`/`Virtual`.

**Three loops bypass `Expr`.** Removing `Expr` still leaves a 15-proc cycle:

1. **Virtual values:**
   * `VirtualValue` `:4583` → `If` `:4606` → `SequenceVirtual` `:7509` →
     `VirtualValue` `:8517`.
   * `VirtualValue` → `Call` `:4615` → `CallInner` → `CallArgs` `:5617` →
     `TryFields` `:4808` → `VirtualValue` `:4763`.
2. **Call arguments in field form:** `Call` → `CallInner` → `CallArgs` →
   `TryFields` → `Call` `:4767`. `FlattenedVirtualCall` and
   `FlattenedVirtualRegionCall` re-enter `CallArgs` (`:4915`, `:4977`).
3. **Virtual construction pieces:**
   * `PlanPieces` `:8358` ↔ `ConstructPieces` `:8372`/`:8437`.
   * `PlanPieces` → `If` `:8410` / `Call` `:8383` → … → `SequenceTo` →
     `PlanPieces` `:8565`.
   * `CallArgs` → `PlanPieces` `:4802`.

These come from demand-driven lowering: "lower this as fields / a plan / a
region" recurses through `if` and calls in the same mode.

**Mutual recursion elsewhere:**

* `native/rawabi.tcl`: `Walk`/`Seq`/`CountBounds`.
* `native/shortstring.tcl`: `Fact`/`FactUncached`/`LastFact` and
  `DemandBody`/`DemandWalk`.
* In `hir/`:

  | file | procs in cycles |
  |---|---|
  | `hir/types.tcl` | about 30 |
  | `hir/completions.tcl` | 12 |
  | `hir/exactvalue.tcl` | 7 |
  | `hir/cardinality.tcl` | 5 |
  | `hir/range.tcl` | 4 |

* `compiler/compiler.tcl` has 15. `surface/parser.tcl` and
  `core/evaluator.tcl` recurse mutually too, but through procedure names
  held in variables, which a static scan misses.

**Passing the recursion in as a parameter does not scale.** Every cycle must
be cut, so about four entry points (`expr`, `call`, `virtual_value`,
`plan_pieces`) would be threaded through about 36 functions. The recursive
calls stay direct only if specialization can follow function values held in
struct fields. Hence MUTUAL-RECURSION.md.

## 6. Language features

### 6.1 Ranking

**Hard prerequisites:**

1. **Mutual recursion:** `mutual:` groups (MUTUAL-RECURSION.md).
2. **Tagged unions** (§6.2).
3. **Int ↔ decimal string conversion.** There is no `/` operator, so it
   cannot be written efficiently in Botlish.
4. **A typed map, a real set, sorting with a key, and string join or a
   string builder** (§8).

**Strongly helpful:**

5. **The planned switch expression (C#-like).**
   * Exhaustiveness relative to the static type.
   * Positional deconstruction of union cases.
   * Tuple patterns, e.g. `(access, want)`. Expr's tail already dispatches
     on `want` × `repr`.
   * `when` guards.
   * Usable as an operand or argument, which `if` is not.
   * It replaces the 44 `switch --` statements and the if-chains on kinds.
6. **The bare `reduce:`** (§6.4).
7. **Struct update** (`s with {nreg: s.nreg + 1}`). STRUCTS.md lists it as
   nonexistent, and any immutable state record needs it.
8. **Propagating "never" without syntax:** a declared error `Abrupt`. It
   propagates through `errors` clauses and removes the 96 `eq "never"`
   checks.
9. **Format strings.**
   * The NIR printer: about 60 instruction cases once NIR is structured.
   * Diagnostics.
   * A custom spec for NIR quoting (`Quote`).
   * Needs the int formatting primitive from item 3.

### 6.2 Tagged unions

The tag is an explicit language feature, as in Rust enums or ML datatypes,
not a convention on a field as in TypeScript. The properties the lowerer
needs:

* **Each tag carries its own payload, or none.** For example `Reg(r)`,
  `RawReg(r)`, `Static(slot)`, `Self`; `Want` is tags only.
* **The tag set is closed by the declaration,** so a switch can be checked
  for exhaustiveness.
* **A payload is accessible only after matching its tag, checked
  statically.** This is Botlish's existing "a projection must be proven"
  rule.
* **Values are ordinary immutable values with `==` and `hash`,** usable as
  map keys.
* **Unions may be recursive,** through `List[...]` as structs already are.

The C-style alternative (one struct with a `kind` field plus every case's
fields) does not suffice. It loses payload checking and needs dummy values
for fields that do not apply.

**Typing decisions:**

* **A case constructor produces the union's type,** as in Rust. Branches that
  build different cases join to the union, not to `any`.
* **Case subsets.** The type of a union value is a finite set of cases.
  * A subset is a subtype of the union and is assignable with no check. A
    function declared `-> U` may return a value known to be `A | B`.
  * **Callers see the declaration,** as today: a declared result replaces the
    inferred one (`hir::types::Block`). Module boundaries and the `mutual:`
    determinism argument depend on the declaration being the interface.
  * **An undeclared function exposes its inferred subset.**
  * **Native code may still exploit a narrower fact** (dead switch arms),
    as it already uses range facts below a declared `int`.
* **Exhaustiveness is relative to the static type at the switch.** A value
  known to be `A | B` needs only those two arms: no `default`, no runtime
  check.
* **Anonymous unions formed by inference,** without a declaration. Allowed
  under one rule: **every member carries a runtime tag the language already
  owns.** Recovering the type is then the switch itself, one tag comparison
  per arm, never an extra check.
  * **Members with such a tag:**
    * declared union cases;
    * nominal structs (shape id at runtime);
    * base kinds (`int`, `str`, `bool`, `list`, …; the tag is in the value
      word).
  * **No tag, so today's joins in `hir::types::lub` (types.tcl:883) stay:**
    * anonymous structs, whose shape is only their field names, so
      `{a: int}` and `{a: str}` are indistinguishable at runtime;
    * callables, which keep their structural join;
    * `any`.
  * **Existing variance carries over:**
    * Lists are covariant: `List[P] ⊔ List[Q] = List[P | Q]`, never
      `List[P] | List[Q]`.
    * MutableArray stays invariant and joins to `any`, because a
      `MutableArray[P | Q]` would allow writing a `Q` into a `P` array.
  * **Fixpoints still terminate.** Members come from the program's finite
    set of declarations, so the lattice gets taller but stays finite.
    Specialization keys grow, bounded by the existing per-function instance
    cap.
* **Declared unions and nominal structs converge.**
  * A case with a payload is a nominal struct.
  * A declared union is a named, closed set of cases: it gives a name for
    signatures and messages, and a closed set for exhaustiveness.
  * An anonymous union is the same set without the name.
  * This is roughly sealed types with case classes (Kotlin, Scala).
* **Trade-off: an inferred union can grow by accident.** A bug adds a case to
  a join, and the error surfaces at a distant switch. Declaring the result
  type moves the error back to the `return`. That is the expected norm for
  module functions; `mutual:` already requires it.

### 6.3 Generics: parameterized types, no declared generic functions

**Decision:** no syntactic generic *functions*, because their type
parameters spread through every caller. Generic *types* exist already
(`List[T]`, `MutableArray[T]`, `ImmutableSet[T]`). User struct declarations
gain type parameters whose arguments are **imprinted** at the construction
from the field values:

```botlish
struct Map[K, V]:
    keys: MutableArray[K]
    vals: MutableArray[V]

m = Map {keys: ks, vals: vs}     # ks: MutableArray[str], vs: MutableArray[Reg]  =>  Map[str, Reg]
```

`fn get(m, k)` declares nothing. It is checked per call-site instance, as
every untyped function already is (semantic instances). What mints the type
is the construction expression, so any function can mint `Map[str, Reg]`:
the type argument follows the data.

**Existing precedents:**

* `mutarray::from_list` (`List[T]` → `MutableArray[T]`) and
  `mutarray::create(capacity, default)` (`T` from the default) already
  imprint (PARAMETERIZED-MUTABLEARRAY.md).
* That document also names the gap: "the one-builder-for-three-element-types
  generic relation".
* Crystal works this way: declared generic types, methods never declare type
  parameters, `[] of Int32` for an empty array.

**Conditions for soundness:**

1. **Type arguments come only from the construction's field values,** by
   matching each declared field type against the value's type. Nothing is
   inferred from later uses.
2. **Empty containers:**
   * An empty *immutable* position gets `T = never`, the existing rule for
     empty lists (M7AA-EMPTY-COLLECTION-AND-APPLIED-TYPE-SEMANTICS.md), and
     is widened by covariant joins.
   * An empty *mutable* position needs `T` fixed at construction: by a
     witness value (like `create`'s default) or an explicit `Map[str, Reg]
     {…}`. Inferring it from later writes is ML's `ref []` problem: two
     aliases could write different types.
   * That annotation sits on an expression, not on a signature, so it does
     not spread.
3. **Variance per parameter is derived from the fields,** with no
   annotations:
   * Only covariant uses (`List`, `ImmutableSet`, plain immutable fields)
     make it covariant: `Box[A] ⊔ Box[B] = Box[A ⊔ B]`.
   * Any `MutableArray[T]` field, or a function-argument position, makes it
     invariant: it joins only when equal, otherwise to `any`.
4. **Non-erasure extends to these types.** A value of an invariant
   parameterized struct may not round-trip through `any` and come back with
   a different `T`. This generalizes the existing `hir/callables.tcl`
   contract-bearing rule, which closed the two soundness holes found when
   `MutableArray[T]` shipped.
5. **Type arguments are erased at runtime,** as `MutableArray[T]`'s are.
   * A switch or type test sees `Map`, never `Map[str, Reg]`.
   * For unions: `Box[A]` and `Box[B]` are never two separate members. They
     join through variance, or not at all.

**What this gives up, compared with declared generic functions:**

* **Errors surface inside the library body,** at the instance a caller
  created, as with C++ templates. The message should name the call chain.
* **Instance counts grow with element types.** The budgets are 16 per
  function and 2000 total for semantic instances, and 8 per function and
  1000 total for the specializer. The superlinear analyses get more
  expensive too.
* **Polymorphism does not survive becoming a value.** Passing `get` as a
  callback fixes one instance. Exact-callable provenance helps when the
  target is statically known.
* **There is no parametricity guarantee.** That is fine for Botlish.

### 6.4 The bare `reduce:`

Under consideration: a "procedural reduce", a hybrid of JS `reduce` and Tcl
`lmap` with loop syntax.

* The body's value becomes the next accumulator.
* `continue` keeps the accumulator unchanged (agreed).
* `break` ends with the current accumulator.
* `leave value` ends with `value`.

**Why it matters: Botlish loops cannot carry state.** Each iteration is a new
scope, and bindings are immutable. A bare `loop:` with `return`, `break` or
`leave` can exit early, but iteration n+1 cannot see what iteration n
computed unless it lives in mutable storage. The accumulator is exactly that
missing piece. A **bare `reduce:`**, with no iteration clause, is an elegant
form: the accumulator decides when to `leave`.

**Loop census:**

| loop shape | `native/*.tcl` | native-path analyses |
|---|---|---|
| over a known collection (`foreach`, `dict for`, `for`) | 206 | 435 |
| collecting (`lmap`; collecting loops cover these) | 63 | 44 |
| `while` | 6 | 30 |

* A reduce over a collection handles the first row.
* The `while` loops are the central algorithms:
  * 9 worklists (`pending`, `queue`, `work`, `todo`, `stack`);
  * 13 `while {$changed}` fixpoints;
  * 7 chain walks (project chains, parent links, union-find roots);
  * a few numeric loops and `while 1`.
* The bare `reduce:` covers all of them.
* Without it, they are either:
  * self-tail-recursive local functions (`fn fix(s): …; fix(next)`), which
    native code already turns into loops; or
  * a bare `loop:` over mutable state that the step updates in place,
    returning when nothing changed.

  Both work today.

**Design points:**

* **Several accumulators.** Most loops update two or three variables. Use a
  struct accumulator with destructuring; struct update syntax helps.
* **Typing of `leave`.** The result is the join of the final accumulator and
  every `leave` value. With anonymous unions (§6.2) a `Scope` accumulator and
  `leave Abrupt` infer `Scope | Abrupt`, with no declaration.
* **Performance.** A struct accumulator should stay unallocated (kept in
  registers) across the back edge in native code, or every iteration
  allocates.
* **The planned `list::append` fix** must cover an accumulator carried from
  one iteration to the next, since that is where most appends will live.

## 7. DSLs

* **DFA/DAFSA: medium value.** Two uses here:
  * the lexer for the lowering input (§3);
  * static string tables: the `natives` table (about 50 name → op entries)
    and the scattered `eq "list::at"`-style comparisons on native names.

  A DAFSA-backed constant map literal fits the second. Its big payoff would
  be a self-hosted frontend lexer.
* **Binary DSL: barely matters.** The only use would be a binary interchange
  format, if text parsing ever shows up in profiles.
* **Regexes: not needed.** Every regexp in `lower.tcl` parses text the
  lowerer itself produced, and they disappear with structured NIR.
* **Format strings and the switch expression:** §6.1.

## 8. Library and runtime prerequisites

**A hash table.** Rebuilt from the `examples/stdlib/hashtable.bot` prototype,
it needs:

* **Typed values.** Values currently come back as `any`, so fields read from
  them cannot be projected. With §6.3, this is `Map[K, V]` imprinted from its
  storage. Without it, either one declared map per value type (a
  `struct PMap: vals: MutableArray[P]` with declared parameter types keeps
  `P`) or a built-in type constructor.
* **Insertion-order iteration.** §4's determinism list depends on it. An
  open-addressing table iterates in hash order unless it also keeps an
  insertion-order key array.
* **An absent-key result that is not `unit` typed `any`.** A declared error,
  or a tagged union.
* **A snapshot or persistent variant** for value-semantics uses. The
  immutable `Scope` (§4) removes most of them.
* **A real set.** `ImmutableSet` lookup is a linear scan and building it is
  O(n²) (MINIMAL-IMMUTABLE-SET.md).

**`list::append` copies today.** A fix is planned; see §6.4 for
loop-carried accumulators.

**`str::concat` copies.** This matters for NIR text, unless NIR is emitted
as structured values and printed once.

**Small natives:** int ↔ string conversion, a stable sort with a key, and
string join.

## 9. Bootstrap and migration

**Order:**

1. **Fix the remaining superlinear terms in Tcl** (§1): view copying and
   the completions depth failure. The range rounds are already done.
2. **Language:** `mutual:`, tagged unions with the switch expression, the
   bare `reduce:`, struct update, imprinted generic types, int ↔ string, the
   map/set/sort/join library.
3. **The lowering input (§3).** The Tcl lowerer reads it with byte-identical
   NIR.
4. **Port Item A** against byte-identical NIR across the suite and the
   corpus.
5. **Port Item B,** cutting after `hir::check`, including the inference
   walker and lattice that specialization re-runs.

**Bootstrapping:**

* **Stage 1:** the Tcl pipeline compiles the Botlish lowerer into a native
  executable. Every used instance must be closed, or the build fails with
  `NATIVE AOT NOT-READY`. Higher-order workarounds put that at risk.
* **Stage 2:** the stage-1 binary lowers its own successor. Reusing the
  binary saves the lowering, but only that.
  * The frontend (and Item B, until ported) still runs in Tcl on every
    rebuild.
  * During the language survey, parse + checks took 62 s for a 7.2k-line
    program and grew faster than linearly. A 6.8k-line call-chain program
    took 94 s, plus 266 s for lowering, Tcl compile and run.
  * The edit-compile loop for a 10k-line lowerer is bounded by the Tcl
    frontend until that improves.
* **Keep the Tcl lowerer as the reference.** Both lowerers must produce
  identical NIR for the corpus and for the lowerer's own source, so a
  miscompile cannot silently carry into the next version.

**Limits a 10k-line Botlish program can hit:**

* Specializer: 8 instances per function, 1000 total (`HIR SPECIALIZE
  LIMIT`).
* Semantic instances: 16 per function, 2000 total, depth 24. Untyped code
  that compiles only thanks to per-call-site types can break as the program
  grows.
* Recursive result types fall back to `any` after 3 passes.
* Deep static call chains overflow Tcl's nesting limit in
  `hir::completions`, at about 110 levels (§1; RANGE-FIXPOINT-SCALING.md
  §6).
* elif chains are limited to a few hundred clauses.

**Runtime.** Botlish's runtime is not automatically faster than Tcl for this
workload until the hash table and the `list::append` fix exist. The GC is a
plain mark-sweep with a shadow stack (README §20).

## 10. Open questions

* Should `reduce:` accept an iteration clause and the bare form with the
  same keyword (`reduce x in xs:` / `reduce:`)? And how is the initial
  accumulator written?
* Should an inferred anonymous union be allowed in a module function's
  public result, or must exported functions declare their result type?
* Should `Map[K, V]`/`Set[T]` be imprinted user types in a Botlish library,
  or built-in type constructors with a runtime implementation?
* Exact format of the lowering input, and which derivations (`BlockName`,
  `ConditionOutcome`, exact constants) move into Botlish rather than being
  serialized.
