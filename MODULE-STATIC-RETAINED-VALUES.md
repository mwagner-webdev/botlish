# Module-static retained values (POST-R2.a.1)

## Outcome

`web::local_extra_chars` (and every other module-level immutable binding,
data or function) is now a **module-static reference**: a stable,
program-lifetime storage slot, resolved and rooted independently of any
particular function's lexical activation. Referencing one no longer makes
the referencing function acquire a closure environment.

Concretely, for the primary motivating source:

- `web::local_char?` (nested inside `web::emailish?`) is envless: `env=0
  captures=0`. It allocates **zero** Block values, on every one of the
  800 real `emailish?` calls `bench/refined-checks.ir` makes per run.
- `web::emailish?` itself is envless: its own dependency on
  `local_extra_chars` (through `local_char?`) never made it closure-valued
  to begin with, once the representation is corrected.
- `check` recovers its pre-R2.a.1 non-generic specialization,
  `check<int, int, str, str>`, and `check.n`'s entry range recovers to
  `[0, 400]`.
- `bench/refined-checks.ir`'s per-run Block allocation count drops from
  **803 to 0**; total allocations drop from 8823 to 8020 (measured, see
  "Deterministic structural census" and "Dynamic census" below).

All of this falls out of one representation change (HIR resolver +
capture analysis + three backends), plus one directly-related correctness
fix in per-instance type re-inference (below). No specialization policy,
range policy, StringRegion policy, or String/ImmutableSet representation
was touched.

## Why this prerequisite displaced finite callable-target provenance

The paused finite-target milestone's own research established that the
frozen workload represents module-retained immutable values through
ordinary lexical closure capture: `web::emailish?` (and, transitively,
`check`) became closure-valued purely because `local_extra_chars` was
treated as a captured free variable, not because of anything about the
*call graph* the finite-target theorem is actually about. Measuring
call-target exactness on top of that representation would have measured
an artifact of module-value storage, not of call-target uncertainty. This
milestone corrects the storage/reachability representation first, so the
next milestone measures the real graph.

## Current module-retention architecture (audited)

Module-level bindings already had a well-defined semantic contract before
this milestone (`hir/modulebinding.tcl`, `MODULE-BINDINGS.md`):

- **Which bindings are retained.** Every top-level `bind` directly inside
  a namespace's own module section scope (`hir::resolve::ProgramSection`),
  whether its value is a function (`fn NAME(...): ...`, sugar for a plain
  bind of a Block literal) or ordinary data. The *entry program's* own
  top-level bindings are structurally identical (also a `program`-kind
  scope) but are **not** in this milestone's scope: `hir::modulebinding
  ::validate` itself only ever validates namespace module sections
  (`dict get $hir modules`), never `hir::top`, and this milestone preserves
  that existing boundary rather than widening it (see "Eligibility" below).
- **Which initializers are allowed.** `hir::modulebinding::ContextExpr`
  proves the initializer is *context-free*: literals, references, control
  flow and statically-resolved calls, walked by semantic identity;
  natives opt in via `core::native::register -context-free 1`. Function
  definitions are exempt (always allowed, cheap startup bindings).
- **What immutability guarantee is enforced.** `hir::modulebinding::
  ImmutableExpr` proves the retained value is *transitively immutable*:
  scalars, Strings, and structurally-proven Lists/ImmutableSets (List
  construction and `list_append` are walked element by element; a nested
  `MutableArray` is rejected, directly or through a List, with `CORE
  SEMANTIC MODULE-IMMUTABLE`).
- **Initialization order.** Module sections are loaded dependency-first
  (`surface::modules::LoadNamespace`) and placed into the ordinary program
  roots in that order, with source order preserved inside each module
  (`hir::resolve::ProgramSection`); a forward read within one module is
  the ordinary resolver's `UNBOUND` diagnostic (context-free and
  single-initialization by construction — nothing here is lazy).
- **How modules expose bindings.** A module section is a genuine `ScopeId`
  (`kind program`), a sibling of the referencing program's own top scope
  under the same root; `web::local_extra_chars` resolves through this
  scope and its stable `BindingId`, exactly like `web::emailish?` does.
  There is no namespace object or runtime name lookup.

This milestone did not weaken or extend any of these existing guarantees.
It changed exactly one thing: how a *reference* from outside the module
to one of these already-validated bindings is represented for capture and
storage purposes.

### What made a module-retained value behave like a capture

`hir::resolve::Capture` (called from both `ResolveRef`, for a same-module
unqualified reference, and `ResolveQualifiedRef`, for a `NAMESPACE::NAME`
reference) walked every enclosing block of a reference and added the
referenced binding to each one's `captures` list unless that block's own
body scope already contained the binding's scope
(`hir::scopeWithin`). A module section scope is never within any user
block — by construction, it is a sibling of the program's own top scope —
so this check always failed for a module binding, and every enclosing
block, all the way out, captured it. This was true regardless of whether
the module binding was data or a function, and regardless of whether the
function was itself otherwise environment-free. `hir::BridgeProvenance`
(the R2.a.1 `-module-fn` bridge's own provenance recorder) independently
reimplemented the identical walk for a bridged native reference's own
target.

## Chosen storage model

**Storage class: static initialized slot** (spec's Strategy B), not
embedded static data (Strategy A). A module-static binding's slot is
allocated once per compiled program, filled with a safe placeholder
(`UNIT`), and written exactly once by the same code that already computed
its value (the ordinary `bind` inside the program function's own
module-initialization sequence) — never constant-folded, never
interpreted at compile time. This is deliberately the minimal general
solution the milestone brief asks for (item 9); embedded static data for a
provably compile-time-constant initializer (`hex_digits`-style literal
tables) remains a distinct, separately-justified future optimization (the
existing `consts`/`ConstPool` mechanism in `native/src/runtime/vm.rs`
already does exactly that for literal Strings/BigInts/natives/environment-
free-function closures, and was deliberately left untouched: it only ever
holds compile-time-derivable data, and `immutable_set_from_list(...)`'s
runtime call is not that).

## Resolver representation: dedicated reference classification

No new HIR node kind, and no new `Binding.kind` value: a module-static
binding still has `kind local`, keeping every existing switch over binding
kind (`hir::aot.tcl`, `hir/types.tcl`, `hir/range.tcl`, `compiler.tcl`,
`native/lower.tcl`) unchanged for it, matching item 6's "do not weaken...
do not broaden" and avoiding blast-radius across every pass that already
special-cases `local`/`param`/`root`/`ambient`.

Instead, classification is structural and computed once, at resolve time,
never by string/name lookup:

- `hir::resolve::ProgramSection` (hir/resolve.tcl) records every module
  section's own `ScopeId` in a new `moduleScopeIds` set as it creates the
  scope.
- `hir::isModuleBinding {hir b}` / `hir::isModuleScope {hir s}` (hir/hir.tcl)
  are the one place that consults it: `O(1)`, keyed on the binding's own
  `scope` field (a stable structural fact set once at resolve time), never
  re-derived from a name or namespace string.
- `hir::resolve::Capture` (hir/resolve.tcl) checks `IsModuleScope` on the
  referenced binding's own scope *before* doing anything else: if true, it
  records the binding in every enclosing block's new `staticRefs` field
  instead of `captures`, and returns — the binding is never inserted into
  any block's capture set, at any nesting depth. `hir::BridgeProvenance`
  (hir/hir.tcl) does the identical check for a bridged native reference's
  own target.
- `hir::staticRefs {hir e}` reads a block's own recorded module-static
  dependencies (BindingId list), symmetric with the pre-existing
  `hir::captures`.
- `hir::externalRefs {hir e}` (hir/hir.tcl) is `captures` ∪ `staticRefs`:
  every binding a block reaches from outside its own body, whichever
  storage class serves it. This is the one new shared helper: it exists
  because three *virtualization-eligibility* analyses (hir/escape.tcl,
  hir/construction.tcl, hir/stringregion.tcl) need to know "does this
  literal make some binding's identity observable outside its own defining
  invocation" — true for a lexical capture and a module-static reference
  alike — while every *closure/environment-construction* site
  (hir/blockescape.tcl, hir/aot.tcl, native/lower.tcl's `CaptureList`,
  compiler.tcl) correctly keeps using `hir::captures` alone, since a
  module-static reference must never end up in a runtime closure
  environment. See "A correctness bug this surfaced" below for why the
  first group needed the union.

Every reference site (`format.tcl`/`read.tcl`) round-trips `staticRefs`
the same way it already round-trips `captures`, so HIR text
serialization stays lossless for tooling that dumps modular HIR directly
(most existing snapshot/differential tests instead round-trip through
`hir::lower`+rebuild, which already erases module structure entirely,
independent of this milestone — see "Debug/audit naming" below).

## Resolver invariant (pinned)

A reference from a function to a retained binding owned by module scope
resolves as `BindingId = module binding, storage = module-static`, and is
**never** inserted into the function's lexical capture set — pinned
directly in `hir::resolve::Capture`'s own control flow (an early return on
`IsModuleScope`, not a downstream filter), and covered by
`tests/module-static-values.test`'s direct HIR inspection tests
(`module-static-captures-empty-for-static-only`,
`module-static-real-capture-plus-static-coexist`,
`module-static-two-functions-share-slot`).

## Capture-analysis invariants (verified)

- `module_value = ...; fn f(): module_value` → `captures(f) = {}`,
  `staticRefs(f) = {module_value's BindingId}`.
- `fn outer(x): fn f(): x; module_value` → `captures(f) = {x}` only,
  `staticRefs(f) = {module_value's BindingId}` — coexisting, never merged.
- Two functions each referencing the same module value share one storage
  identity (one slot, one `staticset`), never duplicated.
- A genuine activation-dependent closure (`fn make(x): fn f(): x; f`)
  still captures and allocates exactly as before — a negative control,
  covered directly (`module-static-negative-control-real-closure`).
- An **entry-program** top-level binding (not inside any module) is
  explicitly out of this milestone's scope and still becomes an ordinary
  lexical capture, unchanged (`module-static-entry-toplevel-binding-still-
  captures`).

## Interpreter representation

Unchanged. The interpreter's environment model (`core/env.tcl`) is
already a flat append-only frame graph with stable frame identity; a
module section's own bindings already live in the *same* top-level
program frame as the entry program's own code (`hir::lower` erases
captures/binding identity entirely — the interpreter looks names up by
name in the current frame chain regardless of how HIR classified the
reference). No interpreter change was needed or made.

## Tcl compiler backend

The Tcl compiler (`compiler/compiler.tcl`) previously reached a module
value only by reconstructing the creating closure's own frame chain
(`CompileBlockBody`'s restore loop, walking `$captured` outward via
repeated `core::env::parent`) — the *same* mechanism a genuine lexical
closure needs, since module scope's own runtime frame ("base") happens to
be the outermost frame in that same chain. Making a function envless
skips that whole reconstruction, which would have made a would-be-envless
module-static reader unable to reach "base" at all.

The fix decouples the two: `core::compiler::ModuleBase`, a namespace
variable, is set once per **unit invocation** — the unit's own top-level
`proc unitN {base} {...}` now saves the caller's previous value in an
ordinary Tcl proc-local (so nested/re-entrant unit invocations, if any
ever occur, restore correctly) and sets `ModuleBase` to its own `base`
for its whole dynamic extent (`try`/`finally`, so every completion code —
value, error, `return`, `break`, `continue` — restores it correctly on
exit). `CompileRef` reads any module-static binding through
`core::env::lookupLocal $::core::compiler::ModuleBase ...` directly,
regardless of whether the current function is materialized/envless — never
through the function's own closure-captured frame chain.
`core::compiler::EnvlessBlocks` (the compiler's own, independently-derived
envless-block fixpoint) now treats a module-static reference exactly like
a root reference: never disqualifying, since it is reachable from any
invocation alike.

## Native (Cranelift) backend: static slot table

New, additive, and separate from the existing constant-table mechanism
(which only ever holds compile-time-derivable data):

- **NIR** (`native/src/nir.rs`): two new instructions, `StaticGet { dst,
  index }` and `StaticSet { index, value }`, and a `Program`-level
  `statics: u32` (the header's own `statics=N`), bounds-checked at parse
  time exactly like `Capture`'s `index` is bounds-checked against a
  function's own `captures` count. Every exhaustiveness site the Rust
  compiler flagged (`validate`, `summarize_call_effects`,
  `codegen::roots::def_use`, `codegen::clif`'s translator) was updated;
  `cargo test` (69 tests) passes unchanged.
- **VM** (`native/src/runtime/vm.rs`): `Vm` gains `statics_ptr: *mut Value`
  (a fixed offset, `VM_STATICS_OFFSET`, read/written by generated code
  exactly like `consts`/`VM_CONSTS_OFFSET`, except mutable) and
  `statics_table: Vec<Value>` (the Vm-owned backing storage).
  `Vm::install_statics(count)` sizes it once, pre-filled with `UNIT` (a
  harmless non-pointer placeholder no reference can observe before
  generated code overwrites it), called from `CompiledProgram::
  install_constants` alongside the existing constant-table installation —
  both are program-lifetime storage, installed together, once, before any
  generated code runs.
- **Codegen** (`native/src/codegen/clif.rs`): `StaticGet`/`StaticSet` load/
  store `vm->statics_ptr[index]`, the identical two-instruction pattern
  `Const`'s own load of `vm->consts[index]` already uses.
- **Native lowering** (`native/lower.tcl`): `native::lower::StaticSlot {b}`
  assigns each module-static binding a stable index on first reference (a
  program-level namespace variable, `staticSlots`, mirroring `ConstPool`'s
  own first-use assignment discipline — BindingId identity, never name
  text, decides slot identity, so a qualified and an unqualified reference
  to the same binding always share one slot). `Access` (the function that
  decides how any binding is reached from the current function) checks
  `hir::isModuleBinding` **after** its existing `fnvalue`/`self`
  classification: an envless module *function* (every module-level
  function, unconditionally, after this milestone — see below) still
  resolves for free through the existing constant-pool `fnvalue`
  mechanism, exactly as an envless function anywhere already did; only a
  module *data* binding (or the rare case the existing classification
  does not otherwise resolve) takes the new `static` path. `Bind` emits
  `staticset SLOT VALUE` immediately after computing a module binding's own
  value — in the exact same place, in the exact same function (the program
  function's own module-initialization sequence), that already computed
  it. `ModuleBridgeBinding`'s own access switch (the `-module-fn` bridge)
  gained the matching `static` case.

## GC rooting and lifetime

`statics_table: Vec<Value>` is scanned unconditionally by
`Vm::collect_with`, chained alongside `temp_roots` and every other root
source — the same "one more root-source iterator" pattern already used
throughout that function, never a parallel or divergent mechanism.

**Lifetime across `Vm::reset`:** deliberately *not* cleared by `reset()`.
Module initialization is not process-lifetime-memoized in this
architecture on any backend — the interpreter and Tcl compiler both
already re-run every module `bind` fresh on every program execution (a
fresh root/program environment each time), and the native backend's own
"program" function already re-executes its own module-initialization
code on every invocation the same way. Since a module binding's own
initializer always runs, in source/dependency order, strictly before any
code that could possibly reference it (module forward-reference
rejection, preserved unchanged), the current run's own code always
overwrites a static slot before anything in that run could read a stale
value from it. A previous run's now-unreferenced object is retained as an
ordinary (harmless) GC root a little longer than the strict minimum —
until the current run's own `staticset` overwrites the slot and a later
allocation triggers collection — exactly the same "deferred reclamation"
character every other root source in this collector already has.
Verified directly: 6-8 in-process runs under `BOTLISH_NATIVE_GC_STRESS=1`
(`tests/module-static-values.test`'s
`module-static-repeated-runs-reset`, and a standalone probe against the
real `uriEscape`/`web` fixture) show the previous run's `ImmutableSet`
allocations reclaimed by a stress cycle triggered by the *current* run's
own subsequent allocations, never before, and never a double-free or
use-after-free.

## Module initialization order, forward references, cycles

Unchanged, and not re-implemented: this milestone's static slot is
populated at the exact point in program order the value was already
computed at (a `Bind` in the program function's own body, in the same
dependency-first, source-ordered sequence `hir::resolve::program`/
`ProgramSection` already establish); forward references remain the
resolver's ordinary `UNBOUND` diagnostic (proven at HIR-build time, before
any storage decision); cycles remain impossible by the same construction
(an initializer may only read an already-bound, earlier name in the same
module — there is no lazy/deferred initialization path to create one).

## Cross-module references, private bindings, aliases

Verified directly (`tests/module-static-values.test`'s
`module-static-cross-module-reference`): module B's function reaching
module A's own retained value is a direct static reference, not a
capture, on every backend — the mechanism is BindingId-keyed, not
same-module-restricted. Visibility (public/qualified vs. any future
private binding) is a name-resolution concern, entirely orthogonal to
storage class, and untouched. A binding's `BindingId` is its storage
identity; nothing in this milestone introduces a second name for one slot
or a second slot for one name.

## Scalar, composite and function-valued module statics

All representation-agnostic, by construction (the slot always holds an
ordinary `Value`, and `StaticSet`/`StaticGet` never inspect its runtime
kind): Int, Bool, String, List, ImmutableSet, and an ordinary module
function definition (itself just a binding whose value happens to be a
Block) are all covered directly in `tests/module-static-values.test`
(`module-static-scalar-int`, `module-static-scalar-bool`,
`module-static-function-valued-binding`, and the primary `web.bot`-derived
tests for String/List/ImmutableSet). A module function binding is not a
new case at all: it is the *same* module-static binding this milestone
already generalizes over, whose value happens to be a Block — see
"Module functions are ordinary functions" below for why it does not, in
practice, usually take the static-slot path at all.

## Module functions remain ordinary functions

A module-level function is not automatically a closure merely because it
lives in a module (item 49). After this milestone, every module-level
function's only *possible* external references are root natives (never
captured) and other module-static bindings (now never captured either) —
there is no third kind of external reference a top-level module binding
could have, since its enclosing scope is never an activation. So every
module-level function is now envless, unconditionally, and is reached
everywhere via the existing constant-pool `fnvalue` mechanism (the
identical path an ordinary envless top-level function already used) —
never via the new static-slot path, and never via a closure. This is why
`native::lower::Bind`'s pre-existing "bound in statement position, value
materialized on demand" fast path for an envless function needed no
change: it already defers to exactly this mechanism.

## The `-module-fn` bridge (R2.a.1) is preserved, not redesigned

`hir::BridgeProvenance`'s own provenance recording (`bridge`: the module
function's BindingId, recorded on the bridged reference) is byte-for-byte
unchanged — still resolved once, by BindingId, right after resolution and
hygiene, never by basename/string lookup. Only the *storage class* that
provenance feeds changed: previously it forced a capture (mirroring an
ordinary qualified reference, at the time correct); now it mirrors the
*corrected* ordinary qualified-reference behavior and routes to
`staticRefs` instead, exactly when the ordinary resolver would have.
`tests/module-fn-bridge-reachability.test`'s full 74-test suite (rewritten
where its own assertions encoded the old capture chain, never where they
verified reachability/identity/no-`NATIVE BUG`) still passes.

## A correctness bug this surfaced (not a specialization policy change)

Before fixing three HIR passes, `bench/uri-steady.bot`'s own
`web::is_unreserved(b: Byte)` regressed from `op setcontainstotal`
(non-erroring) back to plain `op setcontains` (fallible) once its own
module dependency stopped being a capture. Root cause, isolated
precisely: `hir::escape.tcl`/`hir::construction.tcl`/`hir::stringregion
.tcl`'s own per-instance "does this literal make binding B observable
outside its own invocation" analyses each independently scanned
`hir::captures` alone to build their own `captured` set — exactly
correct before this milestone (every non-local reference was a capture),
and silently blind to a module-static reference after it, wrongly
concluding a module value's own local bind (e.g. `web::hex_digits`, or a
`digits`-style module List) was newly eligible for scalar-replacement/
virtual-construction virtualization, which requires a single materialized
Value to not exist at all. Fixed by introducing `hir::externalRefs` (=
`captures` ∪ `staticRefs`) and using it at exactly those three sites
(never at the four genuinely capture-only sites in hir/blockescape.tcl or
the three in hir/aot.tcl, which are correctly unaffected — see "Resolver
representation" above).

A second, deeper bug of the identical shape lived in `hir/types.tcl`'s
`BindingType`: a specialized instance's own per-region re-inference
(`hir::specialize`'s `Reanalyze`/`inferRegion`) seeds only a region's
*parameter and captured* bindings' types (`ctx types`) — correct, since
those are the only instance-varying facts. Any other non-root "local"
reference fell through to `ForwardType`, whose whole job is recovering a
*forward reference to a not-yet-bound closure*'s type — `any` for
anything else. Before this milestone every module reference was seeded as
a capture, so this path was never exercised for one; after, a module
*data* reference (never itself a Block, so `ForwardType` always answers
`any` for it) silently widened to `any` inside every specialized
instance's own re-inference, discarding `additional_unreserved_chars`'s
already-known `ImmutableSet[Byte]` type and losing the `setcontainstotal`
proof. Fixed with one new branch in `BindingType`, mirroring the existing
`root`-binding branch: a module-static binding's type is never instance-
varying (there is exactly one program-lifetime value, typed once by the
ordinary semantic pass), so it returns `hir::bindingType` directly instead
of falling through to `ForwardType`. This is squarely the kind of
"correctness bug directly tied to module-static classification" spec item
24 permits fixing — no `KeyType`, range, or specialization *policy* line
was touched; `hir::specialize::Handle`'s own decision of which calls may
specialize (unaffected: it already scanned `hir::get $hir $block
captures` directly, and a now-empty capture list there is exactly the
correct new input, not a bug) is what actually recovers `check<int, int,
str, str>` and every downstream un-forced specialization documented below.
Both fixes were validated with `cargo test`'s 69 Rust tests (unaffected —
neither touches Rust) and the full Tcl regression (below).

## Primary transformations, before/after

| | before | after |
|---|---|---|
| `web::local_extra_chars` reference | lexical capture, through every enclosing block | module-static reference (`staticget`) |
| `local_char?` | closure-valued (`env=1 captures=1`), one Block allocation per `emailish?` call | envless (`env=0 captures=0`), zero allocations |
| `web::emailish?` | closure-valued (captures its own startup closure) | envless |
| `check` | `check<generic>`, entry `n`: `[-∞, +∞]` | `check<int, int, str, str>`, entry `n`: `[0, 400]` |
| `web::uri_escape_text` | `env=1 captures=2` (hex_digits, is_unreserved) | `env=0 captures=0` |
| `web::is_unreserved` | closure-valued, `<generic>` | envless, `<int>`, `op setcontainstotal` (not `setcontains`) |
| `esc_char`/`esc_bytes`/`esc_from`/`hex_pair` | forced `<generic>` (transitively closure-valued) | specialize on real argument types |

## Specialization / InstanceClosed / OpenInstances / blockescape census

- `check`: `generic 1 specializations 0` → `generic 0 specializations 1`
  (`hir::specialize::summary`).
- `web::is_unreserved`: `<generic>` → `<int>`; its own declared `Byte`
  parameter view is preserved either way (`int[Byte]`).
- `bridgefix::two_deps`/`one_dep`/`is_marked` (synthetic bridge fixture):
  every one of six caller shapes (root, top-level function, nested
  non-capturing, nested capturing, branch, returned closure) now has
  exactly one used instance, `<int>`, and **no** generic instance exists
  anywhere for them — before, every shape *also* carried a shared generic
  instance regardless of that shape's own argument facts, an artifact of
  the closure representation, not a fact about any call's own arguments.
- `esc_bytes`/`esc_char`/`hex_pair`/`esc_from` (real `uri-steady.bot`):
  `<generic>` for all four → `esc_bytes<List[int], int, str>`,
  `esc_char<str>`, `hex_pair<int>`, `esc_from<str, int, str>`.
- `hir::blockescape` candidacy: a module-level function is never a
  candidate any more (it is never captured in the first place, so it is
  never eligible for "de-closure conversion" — there is no closure to
  convert). `local_char?`-shaped nested closures are unaffected by this
  milestone's own change to blockescape.tcl (none was needed): their own
  candidacy already depended on their own (now correctly shrunk)
  `hir::captures`, which flows through unchanged.

## Range / M9 facts

`check.n`: `[-∞, +∞]` → `[0, 400]` (recovered, `tests/emailish-predicate
.test`'s `emailish-predicate-check-n-control`). No range-analysis policy
change: this is `hir::range::analyze`'s own existing entry-fact machinery,
applied to the naturally-recovered non-generic instance.

## NIR / code-size census (`bench/refined-checks.ir`, deterministic)

One consistent counting method (`emit-nir.tcl`'s own loader,
`native::buildProgramHir [core::loadProgramFile ...]`, default options):

| | before | after |
|---|---:|---:|
| NIR lines | 688 | 695 |
| compiled functions | 24 | 24 |
| envless functions | 20 / 24 | 24 / 24 |
| `call` | 21 | 24 |
| `callenv` | 3 | 0 |
| `callmulti` | 4 | 4 |
| `callvalue` | 1 | 1 |
| `tail` | 3 | 3 |
| `tailenv` | 0 | 0 |
| `closure` | 4 | 0 |
| `capture` | 5 | 0 |
| `fnvalue` | 0 | 1 |
| `guard` | 3 | 6 |
| `guardbool` | 1 | 1 |
| `staticget` | 0 | 4 |
| `staticset` | 0 | 3 |
| NIR header | `call-effects=1` | `call-effects=1 statics=3` |

`callvalue` is unchanged at 1 (`scan_while`'s own `predicate` parameter):
exact callable identity is still lost through that generic parameter, as
expected (item 26) — this milestone does not touch it. The `guard` count
rose because envless functions now called directly, rather than reached
generically through a closure, need their own operand-kind guards where a
generic call's own boundary previously absorbed that check; this is
`native/lower.tcl`'s existing, unmodified guard-emission logic reacting to
the new (correct) call shape, not a change to guard policy.

## Allocation census (`bench/refined-checks.ir`, one run, no stress)

| | before | after |
|---|---:|---:|
| total allocations | 8823 | 8020 |
| total bytes | 370440 | 331888 |
| Block allocations | **803** | **0** |
| String allocations | 8004 | 8004 |
| List allocations | 12 | 12 |
| ImmutableSet allocations | 2 | 2 |

String/List/ImmutableSet are exactly unchanged (spec items 28-29: no
StringRegion, ImmutableSet, or value-construction change of any kind).
Block drops by exactly 803 — every one of the frozen baseline's own
per-call `local_char?` closures, plus its 3 startup closures.

## Dynamic census

The post-R2.a dynamic census's own perf/instruction-sampling methodology
(`audit/post-r2a-dynamic-census/tools/cgcensus.py` and friends) requires
`perf`, unavailable in this environment (`perf: command not found`,
`/proc/sys/kernel/perf_event_paranoid` unreadable for sampling). The
allocation/GC-cycle instrumentation above (`native::allocationReport`,
`runtime::metrics.rs`) is used instead as the dynamic evidence: it is
real, measured, per-run data, not a substitute derivation of the
perf-based Ir counts. Wall-clock (`native::measure`, 200 runs,
`bench/refined-checks.ir`, default options):

| | before | after |
|---|---:|---:|
| best-of-200 wall time (µs) | 703.858 | 635.091 |
| lower/compile time (µs, one-time) | 142892 / 10742 | 132786 / 10200 |

A ~9.8% best-of-200 wall-clock improvement, measured directly, on this one
benchmark. This is *validation*, not the goal (spec item 3): the milestone
is justified by the representation correction regardless of the magnitude
here. The prior census's own "~3.6% foreground ceiling" estimate for
module-static values specifically was explicitly historical context, not
a target to reproduce or force; this fresh number stands on its own.

## Deferred reclamation

Removing 803 Block allocations per run also removes their eventual
reclamation: `gc.reclaimedObjects` (20 in-process runs, no stress) drops
from 8823 to 8020 in lock-step with the allocation count, confirming the
saving is real foreground *and* real deferred-reclamation work, not a
foreground-only accounting artifact.

## Focused GC stress (all pass, `BOTLISH_NATIVE_GC_STRESS=1`)

- A module-static managed value (List) read repeatedly from an envless
  function, across hundreds of intervening allocations
  (`module-static-gc-stress-envless-reader`).
- A module-static reference and a genuine activation-local capture
  coexisting inside one real closure, both correct under stress
  (`module-static-gc-stress-mixed-closure`).
- The same compiled program run repeatedly in one process
  (`Vm::reset` between runs, matching the benchmark harness exactly) under
  stress, confirmed to re-initialize and correctly re-read its own module
  statics every run (`module-static-repeated-runs-reset`, and the
  standalone `uriEscape`/`web` 6-8-run probe in "GC rooting and lifetime"
  above).

## Full regression

`LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl`:

```
all.tcl:  Total 2562  Passed 2562  Skipped 0  Failed 0
```

(per backend, `interp` and `compile`, run separately by `tests/all.tcl`
itself; 87 test files sourced, including the 18 new tests in
`tests/module-static-values.test`.) Every
test file this milestone's own representation change touched
(`tests/surface-modules.test`, `tests/emailish-predicate.test`,
`tests/hir-callable-target.test`, `tests/hir-specialize.test`,
`tests/module-fn-bridge-reachability.test`, `tests/native-block-escape
.test`, `tests/native-refinement-propagation.test`, `tests/setcontains-
equality-total.test`, `tests/virtual-construction.test`) had only its
*structural* assertions updated (a shape that genuinely encoded the old
capture representation — a capture-set literal, a `<generic>` label, an
`env=1`/`callenv` regex); every semantic assertion (a computed value, a
diagnostic code, a cross-backend parity check) is untouched and still
passes verbatim. `tests/setfromlist-equality-total.test` needed **no**
change at all — its own assertions were already representation-agnostic,
and the `BindingType` fix made them pass for the right reason.

`cargo test --release --manifest-path native/Cargo.toml`: 69 passed, 0
failed (native/src's own unit tests; none needed a change, since none
exercises static slots directly yet beyond the new NIR
parse/validate/codegen path exercised transitively by every Tcl-level
native test above).

## Post-module-static `scan_while` target shape

`scan_while`'s own `predicate` parameter is still lowered as `callvalue`
(1 static site, still executed once per scanned character — the flagship
higher-order call this milestone deliberately leaves alone). What reaches
it, concretely, is now:

- `local_char?`: an **envless Block**, reached as a plain `fnvalue`
  constant (no capture, no closure allocation) — not a closure-valued
  Block capturing the module set, as under the frozen baseline.
- `is_tcl_alpha` (the other predicate `scan_while` is called with,
  `label_char?`'s own path): unchanged, a **Native** value, exactly as
  before.

This is the changed target graph the next milestone (finite callable-
target provenance) should be redesigned against: `{envless Block
(local_char?), Native (is_tcl_alpha)}`, not `{closure-valued Block
(local_char?, env=...), Native (is_tcl_alpha)}`. The 8,000 hot
one-character String materializations are unaffected (`callvalue`
remains, so this milestone does not, and was never meant to, touch
`String`/`StringRegion` behavior around it).

## Required questions, answered directly

**Architecture (items 94, 1-12).**
1. What made a module-retained value behave like a capture? Every
   enclosing block of a reference unconditionally captured it, because a
   module section scope is never "within" any user block
   (`hir::scopeWithin`), regardless of whether the value was data or a
   function, or whether that function was otherwise environment-free.
2. Which stage decided that? `hir::resolve::Capture`/
   `hir::BridgeProvenance` (hir/resolve.tcl, hir/hir.tcl), at HIR-build
   time.
3. What new representation distinguishes a module-static reference?
   `hir::isModuleBinding`/`hir::isModuleScope` (a binding's own `scope`
   field, checked against a set recorded once at resolve time), plus a
   dedicated `staticRefs` field on every block, disjoint from `captures`.
4. Does a module-static binding appear in a function's capture list?
   **No** — required, and pinned directly in `Capture`'s own control flow.
5. How does native code load the value? `staticget SLOT` — a fixed-offset
   pointer load (`vm->statics_ptr[SLOT]`), the same two-instruction shape
   `Const`'s own constant-table load already uses.
6. Where is it rooted for GC? `Vm::statics_table: Vec<Value>`, scanned
   unconditionally in `collect_with`, alongside every other root source.
7. When is its slot initialized? At the exact point in program order its
   value was already computed — an ordinary `bind`, inside the program
   function's own module-initialization sequence, unchanged from before
   this milestone.
8. Exactly once? Yes, per run — the module-initialization discipline
   (context-free, single-bind, no forward reads) is unchanged; nothing new
   enforces this beyond what already did.
9. Across `Vm::reset`? The slot table itself is not cleared (program-
   lifetime storage); each run's own module-initialization code overwrites
   every slot before anything in that run could read it, so a stale
   previous-run value is retained only as a harmless GC root a little
   longer, never observed. Verified under GC stress across repeated runs.
10. Cross-module references? BindingId-keyed, not same-module-restricted;
    verified directly (`module-static-cross-module-reference`).
11. Aliases/re-exports? One storage identity per BindingId; nothing in
    this milestone introduces a second name for one slot.
12. Forward references? Unchanged — the resolver's ordinary `UNBOUND`
    diagnostic, proven before any storage decision exists.

**Closures (items 95, 13-16).**
13. Does a function referencing only module statics remain envless?
    **Yes** — required, and the primary effect this milestone produces.
14. Does a function with one lexical local and one module static capture
    only the local? **Yes** — verified directly
    (`module-static-real-capture-plus-static-coexist`).
15. Do genuine activation-dependent closures behave exactly as before?
    **Yes** — negative control passes unchanged.
16. Can an envless function still be a first-class callable? **Yes** —
    unchanged (`fnvalue`/constant-pool mechanism, or a real Block value
    when actually materialized; `scan_while`'s own `callvalue` site is the
    live proof).

**Primary workload (items 96, 17-25).** See "Primary transformations"
above for 17-22 (`local_char?`/`web::emailish?` envless, `check`
recovers `check<int, int, str, str>` and `check.n = [0, 400]`) and
"Post-module-static `scan_while` target shape" for 24-25 (envless Block +
Native reach `predicate`; `scan_while` still contains one `callvalue`).

**Deterministic/dynamic census (items 97-98, 26-46).** See "NIR / code-size
census", "Allocation census" and "Dynamic census" above for the full
measured tables (allocations, Block allocations, machine/NIR structure,
`call`/`callenv`/`callvalue`, `closure`/`fnvalue`/`capture`, guards, wall
clock). Item 46 (percentage of the old ~3.6% ceiling recovered): not
computed as a percentage of that historical estimate, deliberately (item
69 — fresh measurement wins); the fresh, self-contained numbers are
reported instead.

**Future target (items 99, 47-53).** See "Recommended next milestone" and
"Post-module-static `scan_while` target shape" above: finite
callable-target provenance remains the strongest next milestone, but its
ceiling must be re-measured fresh against this tree (the old −19.7%
already included this milestone's own Block-allocation saving); the
exact-target set it would reason about is materially simpler now
(`{envless Block, Native}`, never a closure environment).

## Recommended next milestone

Finite callable-target provenance remains the strongest next compiler
milestone, but its ceiling must be re-measured, not assumed, against this
new tree: the old −19.7% figure included eliminating the very closure
allocation this milestone already independently removed. A fresh
exact-target counterfactual (the same scratch-counterfactual methodology
the paused research used: make `scan_while`'s predicate targets
syntactically exact, leave the production compiler otherwise unchanged,
measure Ir/allocations/deferred reclamation/wall clock) is the right way
to establish the *new* ceiling before committing to that design. The
target set it would need to reason about is materially simpler now
(`{envless Block, Native}`, never a closure environment), which is exactly
the simplification this milestone was undertaken to produce.
