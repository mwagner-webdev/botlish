# Direct HIR -> NIR native path

## Outcome

```
source -> resolved + analyzed HIR -> NIR -> native JIT / object / standalone executable
```

Production native compilation starts from HIR and stays there. Nothing on the
native path lowers HIR to core IR, and nothing rebuilds HIR from core IR.
Deleted: `native::buildProgramHir` (the relift), `native::runProgram`,
`native::ExpandNativeBodies`/`ExpandNativeBodiesIn`, `native::ModuleNativeBridge`,
`native::runSequence`, the registered `cranelift`/`cranelift-generic` core IR
backends, `hir::ApplyNativeResultOverrides` and `hir::buildSyntax`'s
`-native-result-overrides` / `-module-native-targets` options (their only
caller). Core IR is untouched: it stays the Tcl reference interpreter's
representation and `hir::lower` stays its producer.

```
HIR      authoritative semantic program representation (facts, side tables)
Core IR  small executable/reference representation of the Tcl interpreter
NIR      production executable representation: native now, bytecode later
```

Headline results (fresh measurements, parent `9b2c712` vs this tree):

* Through the direct route the canonical corpus (17 programs) compiles to
  **byte-identical raw NIR for 13 of the 17 programs and identical canonical NIR
  for 14**; over the 30 audited programs (the 17 plus 13 probes) 25 are raw-identical
  (`@e` tags included) and 27 canonically identical. The other
  five differ for *classified* reasons, all of them information the relift
  destroyed; none is a direct-lowering bug (section "Pre-deletion differential").
* Because the direct route is better informed, it emits **234 functions instead
  of 247**, 64 guards instead of 69, 103,331 machine-code bytes instead of
  109,539, and finds 0 AOT-`open` regions instead of 4. One program got worse
  for a known, out-of-scope reason: `csv_geometric` gains the two
  `join(mutarray, MutableArray[T])` guards that the relift hid by erasing the
  applied type (`TYPED-MUTARRAY-BUILDER-REFACTOR.md`); not touched here.
* Direct lowering exposed three latent problems the relift had been hiding or
  that only multi-compilation processes hit; all fixed, each pinned:
  a `-strict 0` program that breaks a *declared* parameter contract segfaulted
  natively (fixed in `native::prepareHir`), `prepareHir` could leave a
  validator-predicate call without an implementation, and `native::lower`'s
  module-static slot table leaked between compilations in one process.
* The dead forward-reference cell machinery is gone from NIR and the Rust
  runtime.
* Test results: see "Full regression".

Not changed: the language, the canonical `.bot` sources, `hir::specialize::KeyType`,
the type algebra (the `MutableArray` join gap is still open), the optimizer,
Core IR semantics.

## Motivation

The strict-reference milestone (`STRICT-REFERENCE-DETERMINISM.md`) made HIR
carry no forward lexical references, so the round trip

```
HIR --hir::lower--> core IR --native::buildProgramHir--> HIR' --> NIR
```

no longer added information: HIR' was HIR again, rebuilt by name from a
representation that has no bindings, types, contracts, module scopes,
`errors` clauses, or source locations. Keeping it meant every native compile
re-ran the whole front-end analysis, paid for a second copy of the program, and
silently substituted HIR' facts (weaker) for HIR facts (authoritative).

## Architecture before

```
source ─surface─▶ HIR ──hir::lower──▶ core IR ─┬─▶ core::evalProgram (interp)
                   │                           ├─▶ Tcl compiler (GenerateUnit; builds its own HIR from the IR)
                   │                           └─▶ registered backend "cranelift":
                   │                                 native::runProgram
                   │                                   ExpandNativeBodies  (name-based IR rewrite)
                   │                                   ModuleNativeBridge  (prepend module sections)
                   │                                   hir::buildSyntax    (resolve + full analysis again)
                   │                                   native::lower::program ─▶ NIR ─▶ botlish-native
                   ├──native::evalHir / native::executable (already direct; evalHir still
                   │  called hir::lower + core::ir::check first, for nothing)
```

## Architecture after

```
source ─surface─▶ HIR (resolved; types, contracts, semantic instances, ranges of checks)
                   ├──hir::lower──▶ core IR ─▶ Tcl interpreter / Tcl compiler   (reference branch)
                   └──native::prepareHir──▶ HIR (natives attached; recovered)
                        └──native::lower::program──▶ NIR ─▶ botlish-native ─▶ JIT / object / executable
```

`native::lowered` is the one HIR->NIR entry point; `native::nir`, `evalHir`,
`clif`, `vcode`, `roots`, `measure`, `object`, `codeSize`,
`allocationReport`, `report` and `executable` all go through it (through
`native::nir`), so benchmarks, AOT, executables, audits and tests cannot
diverge.

## IR responsibility split

| | role | consumers |
|---|---|---|
| HIR | authoritative semantic program: binding identity, scopes, captures, exact call targets, types, declared/inferred contracts, semantic instances, refinements, error/completion facts, module identity; side tables | analyses (`hir::types`, `signatures`, `semantic`, `range`, `refine`, `callables`, `errorsets`, `modulebinding`), `hir::specialize`, `hir::aot`, native lowering, `hir::lower`, the Tcl compiler's facts |
| Core IR | small, name-based executable/reference language | Tcl interpreter (`core/`), Tcl compiler input, Core IR tests; produced by `hir::lower`; read by `hir::build` as an input notation |
| NIR | register-based executable representation with no names, types or traits | `botlish-native` (Cranelift JIT/object/executable); the future bytecode interpreter |

## Production entry-point census (before)

| entry | route before | class |
|---|---|---|
| `core::useBackend cranelift` + `core::evalProgram` (`native::runProgram`, `runProgramWith`) | Core IR -> `buildProgramHir` -> NIR | raw core IR -> native; used by the test suite (`native-coverage`) and `main.tcl` on `.ir` |
| `native::evalHir` | HIR -> `hir::lower` + `core::ir::check` (discarded) -> `native::nir` | production JIT (direct, with a pointless lowering) |
| `native::executable` | HIR -> `native::nir` -> `Driver executable` | production standalone executable (direct) |
| `main.tcl -emit-native-executable X.bot/.hir` | direct HIR | production |
| `main.tcl -emit-native-executable X.ir` | `buildProgramHir` | raw core IR -> executable |
| `main.tcl -backend cranelift X.bot/.hir` | `native::evalHir` (direct) | production JIT |
| `bench/bench.tcl` (`bestNative`) | `hir::lower` -> `buildProgramHir` -> `native::measure` | JIT / benchmark |
| `bench/corpus.tcl`, `examples/stdlib/corpus.tcl` | `native::evalHir` (direct) | JIT / benchmark |
| `bench/uri-steady.tcl`, `bench/check-unicode-parity.tcl` | `buildProgramHir` / registered backend | JIT / benchmark |
| `native/generate-scalar-audit.tcl` (bench programs) | `hir::lower` -> `buildProgramHir` | audit tooling |
| `native/explain-native.tcl`, `generate-post-stack-details.tcl`, `native/tests/fixtures/generate_benchmark_nir.tcl` | `.ir` -> `buildProgramHir` | audit / fixture tooling |
| 30 `audit/*/tools` scripts | `buildProgramHir` (26 of them via `hir::lower` or `.ir`) | audit tooling |
| tests | 47 `buildProgramHir` sites in 14 files; 42 files run programs on `cranelift` through the registered backend, many of them `hir::lower`'d HIR | test-only HIR path and test-only raw core IR path |
| hybrid / compatibility packaging | **does not exist** (see "Hybrid executable decision") | -- |

## Core IR consumer census (before)

Tcl reference interpreter (`core::evalProgram` and friends); the Tcl compiler
(`compiler/`, which reads core IR and builds its own HIR); `hir::lower`
callers (main.tcl, bench, corpus, tests, `core::compiler::evalHir`); Core IR
tests (`acceptance`, `blocks`, `bindings`, `calls`, `control`, `loops`, ...,
including the `coreScoping` group that pins the interpreter's declare-on-entry
scoping); `hir::build`/`hir::read` (core IR text as an input notation); and the
native backend (registered backend, `native::evalHir`, tooling) -- the consumers
this milestone removed.

## Relift call-site census

| file | function | caller | why it existed |
|---|---|---|---|
| `native/native.tcl` | `native::buildProgramHir` (definition) | `runProgram`, main.tcl, bench, audits, tests | the native backend was defined as a core IR backend: raw IR needed HIR before lowering |
| `native/native.tcl` | `native::runProgram` | `core::registerBackend cranelift[-generic]` (`core::evalProgram`) | run core IR programs natively, cache NIR by IR text |
| `native/native.tcl` | `native::evalHir` (`hir::lower` + `core::ir::check`) | `main.tcl`, corpus, tests | leftover check of a lowering whose result was thrown away |
| `main.tcl` | `emitExecutable` `.ir` branch; `runFile` (always lowered) | CLI | `.ir` inputs; the interpreter branch's lowering |
| `bench/bench.tcl` | `bestNative` | `bench` loop | had only the lowered program at hand |
| `bench/uri-steady.tcl` | `valueUnder` | script | same |
| `native/generate-scalar-audit.tcl` | corpus loop (bench programs) | script | same |
| `native/explain-native.tcl`, `generate-post-stack-details.tcl`, `native/tests/fixtures/generate_benchmark_nir.tcl` | loaders | scripts | `.ir` fixtures |
| 30 `audit/*/tools` files | loaders | audits | "the production route" |
| tests (47 sites) | helpers | test files | Core IR text as the test language |

Indirect wrappers: `native::runProgramWith` (generic backend), the test
harness's `outcomeUnder`/`core::evalProgram` under `CORE_BACKEND=cranelift`.

## Direct HIR native entrypoint

`native::lowered HIR ?OPTIONS?` (repository naming; `native::nir` is its text).
Contract:

* **Input state**: program-mode HIR built by a front end
  (`surface::readProgramFile`, `surface::compile`, `hir::readFile`, or
  `hir::build` for a program written as core IR text) -- resolved, typed,
  contracts inferred, semantic instances computed, checks run.
* **Step 1, `native::prepareHir`**: attach the native implementations the
  program calls (module functions such as `uriEscape -> web::uri_escape_text`;
  validator bodies such as `emailish?`/`NonEmpty?`) by resolved binding
  identity, and recover statically-violated declared parameter contracts
  (below). No work and no re-analysis when nothing applies; otherwise one
  `hir::check`. Idempotent.
* **Step 2, `native::lower::program`**: specialization (`hir::specialize`), ranges
  (`hir::range::analyze`), escape / string-region / block-escape / traversal /
  construction analyses -- backend analyses over the given HIR, run once per
  compile -- then NIR.
* Output: `{text functions statistics}`.

## Analysis ownership

| analysis | owner | when |
|---|---|---|
| resolution, hygiene, binding identity, module identity | `hir::resolve`, `hir::hygiene` | front end (`hir::buildSyntax`) |
| types, refinements, intrinsic contract inference | `hir::types`, `hir::refine`, `hir::signatures::infer` | front end (`hir::check`) |
| semantic instances | `hir::semantic` (inside `hir::types::infer`; verified in `CheckOnce`) | front end |
| declared result/param verification, ranges of the checks | `hir::range::verify*` | front end |
| callable/bearing checks, error sets, module binding validation | `hir::callables`, `hir::errorsets`, `hir::modulebinding` | front end |
| native implementations, declared-contract recovery | `native::prepareHir` | native entry (re-check only when it changes the HIR) |
| specialization / AOT classification | `hir::specialize`, `hir::aot` | `native::lower::program`; `native::executable`'s readiness check |
| numeric ranges for representation, escape, string regions, block escape, traversal, construction | `hir::range::analyze`, `hir::escape`, ... | `native::lower::program`, once |

Nothing is recomputed after a core IR lowering because the native path no
longer has one. The one re-analysis left is `prepareHir`'s `hir::check`, which
runs only for a program that calls a native with a module implementation or
body (uriEscape, `emailish?`, validator predicates) or whose HIR carries a
violated declared contract -- 2 of the 30 audited programs (`refined-checks`,
`module-web`) -- against the relift's re-analysis of every program.

`hir::semantic`'s results reach lowering through the HIR the caller passes:
`hir::specialize` calls `hir::semantic::GenericResult` (never less precise than
the semantic HIR) and `hir::range`/`hir::callables` call
`hir::semantic::InstanceOf`/`EntryTypes`; `native/lower.tcl` itself reads none
of it directly and contains no raw `dict get $hir` (it uses the named queries
`hir::get`, `hir::typeOf`, `hir::binding`, `hir::specialize::view/instance`,
`hir::range::of`, `hir::escape::*`, `hir::aot::analyzeRegion`, ... -- the
boundary API of items 36/37).

## HIR side-table ownership

Carried by the HIR dict itself, so no copy exists: `semantic` (instances,
keys, calls, envs, census counters), `intrinsicBlocks` (container rule per
block; gone since MUTABLE-ARRAY.md made the array constructors registered
natives), `modules`/`moduleScopeIds` (module identity), `moduleNativeTargets`,
`errorDecls`, `sourceTypes`, per-expression `nativeResultOverride`, per-block
`declaredParamTypes`/`inferredParamTypes`/`checkedParamTypes`, `violatedDeclared`,
`demotedContracts`, per-node `origin` (source spans), `known`,
`resultRangeFact`, `effectiveErrors`. `hir::aot::context` (walk positions,
static blocks, envless blocks, ...) is derived from HIR structure on demand.
None is serialized through, or rebuilt from, core IR.

## Hidden core IR normalizations audited

What `hir::lower` + rebuild did, and where each lives now:

| transformation | needed by native? | disposition |
|---|---|---|
| bindings become names; hygiene renames (`x#1`, `mod::name`) keep name lookup faithful | no: native uses BindingIds | retained only for core IR (see hygiene boundary) |
| types, captures, refinements, call targets, `known` erased then recomputed | no: recomputation is what lost facts | not needed; HIR facts read directly |
| module scopes flattened to `ns::name` top-level binds | no; harmful | not needed: module identity, statics, `intrinsicBlocks` come from HIR |
| declared parameter/result types, `errors` clauses, `error` declarations, source types erased | no; harmful | not needed: read from HIR |
| source origins replaced by `{ir PATH}` | no; harmful (diagnostics, allocation-site locations) | not needed |
| native call shape (a native call is one `call`) | no | already present independently in HIR (`target {native SYMBOL}`) |
| `-native-body` substitution before resolution, name-based | yes (implementation, not normalization) | moved to explicit `native::prepareHir` on resolved HIR, by binding identity |
| module-native bridge prepended module sections | yes | same, `prepareHir` |
| completions (`fail`/`handle`), loops (`loop`/`listloop`/`countloop`), multi-results, closures, block representation, call shape | no normalization happened: same node kinds | already present independently; lowering consumes HIR forms |
| block representation, closure/env materialization, completion lowering, guards, parameter aggregation, native op selection | native executable normalization | already HIR -> NIR (`native/lower.tcl`); nothing was copied from `hir::lower` |

Hidden dependencies found by direct lowering (all resolved): (1) a
statically-violated *declared* parameter type -- core IR has no declared types,
so the relift's callee always guarded its own uses; direct native trusted the
declaration and read a non-list as a list (`mutarray-sem-10` segfaulted) --
fixed in `prepareHir`; (2) `prepareHir` skipped attaching a validator body to a
call HIR had proved redundant, then its own re-check dropped the proof and the
call had no implementation (`native-validator-predicate-*`) -- it now attaches to
every call, as the old pre-HIR substitution did; (3) `staticSlots` was reset
without a `variable` declaration, so slot numbers and `statics=N` leaked between
compilations in one process (only the audit and test processes compile several
programs) -- fixed. Nothing else.

## HIR hygiene boundary

`hir::hygiene` remains, unchanged in behaviour. Uses (audit):

* `hir::buildSyntax` runs `hir::hygiene::apply` once per build. Root-reference
  and later-binding renames (`NAME#N`, original in `spelling`) exist because
  core IR, the interpreter's scopes, the Tcl compiler's frames and HIR text are
  name-based; that is the HIR -> core IR / reference branch.
* `qualifyModules` gives every module binding its canonical `ns::name`
  spelling; that is HIR-level identity too (`hir::containers`, module native
  targets, diagnostics) and stays.
* `native::prepareHir` calls `RenameTo` + `apply` again only to reconcile module
  spellings when it adds module sections.

The native branch does not read renamed spellings for anything but labels.
Pinned by `direct-hir-native-independent-of-hygiene`: the shadowing program's
HIR with every rename undone (two bindings both named `x`) lowers to the same
NIR modulo function/parameter name labels, and to the same value.
Moving the renames physically out of the shared HIR build and into
`hir::lower` was considered and not done: the Tcl compiler and HIR text need
the *same* names on both sides, so it would need a paired "HIR + names" lowering
result and touch the compiler for no native benefit.

## Binding identity in native lowering

Native lowering keys everything on BindingId/ExprId (`hir::get`, `hir::binding`,
capture lists, static slots by binding, exact call targets `{block E}`).
`direct-hir-shadowing-three-way` and `direct-hir-hygiene-source-three-way`
(earlier outer reference + later inner shadow, closures before and after) agree
across the interpreter (core IR, through hygiene), direct native and a
standalone executable. `direct-hir-shadowed-native-name` shows a local `fn
uriEscape` is not the native. Self recursion lowers from the exact
self-binding (`self-recursion` probe, `fact`/`fib` executables); legal
argument-passing cycles (`arg-cycle` probe) still lower, guarded, with
`callvalue`.

## Module identity preservation

The relift flattened modules and lost `moduleScopeIds`, so container
intrinsics (`mutarray::create/from_list`, keyed by the resolved module binding),
module-static classification and module functions' declared/refined signatures
all disappeared. Direct lowering keeps them: `direct-hir-module-identity-in-native-hir`,
`direct-hir-container-call-result-is-semantic-type` (`MutableArray[int]`).

## Semantic-instance integration

Semantic-instance results are consumed as the front end produced them
(`direct-hir-semantic-instances-not-recomputed`; the census below): no
instance is requested, walked or re-keyed after the HIR is handed to native.

## Specialization integration

`hir::specialize::analyze` runs once, in `native::lower::program`, on the HIR
the front end (and `prepareHir`) produced; `KeyType` is untouched
(semantic precision is still not codegen specialization). The "never less
precise than the semantic HIR" rule reads the front end's call results.

## AOT integration

`hir::specialize::regions`/`hir::aot` classify the same HIR the lowerer
compiles (and `native::executable`'s readiness check). `hir::aot::context`'s
`positions` is kept: it is the deterministic walk order `hir::specialize::Order`
uses for instance order (an analysis concern, not relift scaffolding), and
lowering reads it only to order emitted functions.

## NIR lowering responsibilities

Unchanged: CFG/control and completion lowering, closure/environment
materialization, representation guards, parameter aggregation, virtual
construction, native operation selection are all in `native/lower.tcl`; none of
it existed in `hir::lower`. `hir::lower` erased and the relift then guessed;
lowering now has nothing to guess.

## Raw Core IR native compilation decision

It existed as (a) `core::useBackend cranelift`, documented in the README, and
(b) `main.tcl` on `.ir`. It was never needed for production source, only as the
test suite's language (Core IR text) and for two frozen bench IR files.
Decision: **removed as a production feature.** `main.tcl -backend cranelift`,
`-emit-nir`, `-emit-clif` and `-emit-native-executable` reject `.ir`
(`NATIVE AOT INPUT`; `.hir` fixtures replace it, and CI's cranelift example run
uses `examples/hir/0[1-3]*.hir`); `native/` registers no backend
(`direct-hir-no-production-native-backend`); `hir::build` still reads core IR
text into HIR for tests and tooling (an input notation, like `.hir`).

## Core IR test migration

* Core IR semantics tests (`acceptance`, `blocks`, `bindings`, ..., the
  `coreScoping` group) are untouched and keep running on the interpreter.
* Tests written as core IR text still run on `cranelift` for coverage through a
  **test-only harness backend** (`tests/helpers.tcl`): a program that
  `hir::lower` produced is compiled from the very HIR it was lowered from (the
  harness remembers it; native never sees core IR), a hand-written program is
  read into HIR with `hir::build`. It is not a production entry point and
  cannot round-trip.
* The 47 `buildProgramHir` sites became `nativeHirOfIR` (hand-written IR text
  and the frozen `bench/*.ir`: `native::prepareHir [hir::build ...]`) or plain
  HIR (`native::prepareHir <HIR>`, where they had relifted HIR).
  `native-executable`, `mutable-array-type`, `mutarray-construction` and
  `module-fn-bridge-reachability` now pass HIR to `outcomeUnderHir`.
* `tests/native-root-*` used the `cell` NIR op as a no-operand allocator; they
  use `op listnew`.
* New `tests/direct-hir-native.test` (33 tests): architecture guards, hygiene
  independence, shadowing/module/closure/error/loop/MutableArray parity, the
  declared-contract recovery, and executables.

## Hybrid executable decision

There is no hybrid executable in this repository: no Core IR serialization, no
embedded interpreter, no `hybrid` mechanism (the strict-reference report lists
it under "not done, by instruction"). Answer to "did it depend on Core IR":
n/a; nothing was retired, demoted or replaced. The only executable creation is
`native::executable HIR PATH` (`botlish-native executable`: object code, the
constant initializer, static link against the runtime `rlib` with `rustc`);
it never embedded core IR or Tcl. Tests run the produced binaries with an empty
`PATH`, relocated, and under GC stress.

## Native executable creation integration

`native::executable` is authoritative and is the same
`native::nir`-> `Driver executable` path the JIT uses; its readiness check
(`hir::specialize::analyze` + `regions`) reads the same HIR. Executables built
and run in this milestone (all match the interpreter and in-process native):
scalar and Unicode program; `fact`/`fib` self recursion; closure
(`make_adder`); module call (`mathish::inc`), module native bridge
(`uriEscape`, `emailish?`); MutableArray (`mutarray::create`,
`from_list`, freeze); shadowing (both probes); declared-error handling; the CSV
corpus program (`csv.bot`) and `string_reverse`, `string_replace`; plus the
existing `native-executable` tests (see "Standalone executable tests"). 18 of the 30 audited programs are
AOT-ready; each was built, run with an empty `PATH`, and matched the interpreter
(`out/executables.txt`; the other 12 are refused by the readiness check, as before).

## Standalone executable tests

Built with `native::executable` (the CLI path is `main.tcl
-emit-native-executable`, exercised by `native-executable.test`), run without
Tcl (`PATH=` empty), and compared with the interpreter and in-process native:
9 new tests in `tests/direct-hir-native.test` (scalar/Unicode, `fact` self
recursion, closure, module call, MutableArray, shadowing x3, declared errors,
`csv.bot`, `string_reverse`, `string_replace`, module native bridge with
validator body) plus the 14 existing `native-executable` tests (relocated
binaries, GC stress, roots, closures, modules, errors, stack overflow); and the
18 executables of `out/executables.txt`.

## `native::buildProgramHir` disposition

**Deleted** (not retained anywhere, not even for legacy tooling: the tools that
compared it are marked LEGACY and run only against a pre-milestone tree; no
caller exists). It reconstructed HIR from core IR by resolving names again,
typing again, re-running contract inference and semantic instancing, and
prepending modules for natives it found syntactically. It could not
reconstruct: source locations, declared parameter/result types, `errors`
clauses and error declarations, module scopes and identity, container
intrinsic identity, applied `MutableArray[T]` types, module-static provenance,
the front end's semantic-instance table (it recomputed a weaker one), the
declared-contract violation record. Now consumed directly: all of those.
No reconstruction logic was retained: `prepareHir`'s only core-IR-shaped input
is a *native's registered body* (`hir::syntax::fromIR` of the registry's
`-native-body`, data that defines that native, never the user's program), it
resolves on the given HIR by binding identity, and rebuilds nothing.

## `hir::lower` disposition

Retained, for the interpreter, the Tcl compiler, Core IR tests and reference
tooling. Native never calls it: `direct-hir-native-namespace-static-scan`
(no proc in `::native` mentions `hir::lower`, `buildProgramHir`,
`core::ir::check`, `core::evalProgram`, `core::compiler::`) and the two dynamic
guards (`direct-hir-native-entry-points-never-call-core-ir`,
`direct-hir-native-executable-never-calls-core-ir`: execution traces on
`hir::lower`, `hir::build`, `hir::buildSyntax`, `core::evalProgram`, ... while
`prepareHir`, `nir`, `evalHir`, `codeSize`, `measure`, `object`,
`allocationReport` and `executable` run a module/native-heavy program).

## Dead cell / NIR cleanup

`cell`, `cellset`, `cellget`, `cellcheck` are no longer producible (removed
from `native/lower.tcl` by the strict-reference milestone); now removed:

* NIR: `Inst::Cell/CellSet/CellGet/CellCheck`, their parser cases, use/def
  tables, safepoint and roots handling (`nir.rs`, `roots.rs`), CLIF lowering
  (`clif.rs`);
* runtime: `CellObj`, `KIND_CELL` (heap kind 7 is not reused), `rt_cell_new`,
  `rt_unbound` (its only caller was `cellcheck`), the `UNBOUND` immediate value
  tag, the heap trace/size/free cases, the `Cell` allocation kind in
  `Metrics` and `native::allocationText`;
* tests: five NIR literals that used `cell` as an allocating op now use
  `op listnew` (Rust and Tcl); `UNBOUND` as an *error kind* stays (`raise
  UNBOUND` for an unresolved name).

Core IR's interpreter scoping (declare-on-entry, `coreScoping` tests) is a
separate Tcl mechanism and is untouched.

## Pre-deletion relift-vs-direct differential

Tool: `audit/direct-hir-native-path/tools/differential.{tcl,sh}`, one process
per program, run in a worktree of the parent commit (`-mode relift` is the
parent's production route, `-mode direct` its already existing direct route),
over the 17 canonical programs plus 13 focused probes
(`audit/direct-hir-native-path/probes/`: shadowing, module call, container
intrinsics, module native bridge, closures, self recursion, argument-passing
cycle, errors, loops, semantic instances, exact callables, typed
MutableArray). Data: `out/summary-parent-{relift,direct}.txt`.

Compared per program: the semantic-instance census, used codegen instances,
AOT region census, full NIR, canonical NIR (`@eN` tags dropped, function ids
replaced by name+instance, declared-error ids replaced by names, function
bodies sorted), scalar assembly, and the interpreter-vs-native value.

Result: **the values agree on all 30 programs on both routes.** Canonical NIR is
equal for 27 of 30 (raw NIR byte-equal for 25: the other two, `refined-checks`
and `module-web`, differ only in `@e` tags and declared-error numbering because
the relift's HIR carried fewer `error` declarations). Assembly is equal for 25
of 30. The differing rows, each classified (STOP rule: none is a direct-lowering
bug; every one is relift information loss or a numbering artifact):

| program | difference (relift -> direct) | class |
|---|---|---|
| `uri-steady` | 26 -> 19 codegen instances, 24 -> 17 functions, guards 5 -> 0, bytes 11,353 -> 5,674, AOT 19/5/2 -> 19/0/0; `web::` functions specialized (`int`, `str`) instead of generic | module information loss: declared/refined module-function signatures (`web::is_unreserved(b: Byte)`, ...) are not in core IR |
| `csv_records` | 66 -> 60 codegen, 63 -> 57 functions, guards 28 -> 26, bytes 24,333 -> 23,650, AOT 49/17/0 -> 45/15/0; `ht_*` instances keyed `mutarray` instead of `any`, generic `ht_*` gone | module/container identity loss: `mutarray::create/from_list` typed by resolved identity |
| `csv_geometric` | guards 0 -> 2 (`guard mutarray` before `mutable_array_set` in `geo_append`, two instances), bytes 7,424 -> 7,578, AOT 19/0/0 -> 17/2/0 | relift loses the applied `MutableArray[T]`; direct exposes the documented `join(mutarray, MutableArray[T])` gap (not fixed, item 22) |
| `refined-checks`, `module-web` | `faildeclared`/`declarederroreq` ids and `@e` tags | different but equivalent normalization / unstable ids (`errorDecls` lost by the relift); canonical NIR equal once ids are named |
| `errors`, `semantic-instances`, `source-checks`, `test-selection` | NIR identical; AOT status: relift reports `open` (false `UNHANDLED-ERROR`: `fail NotFound` "not admitted") | Core IR information loss: `errors E` clauses do not exist in core IR, so the relift's HIR rejects legal programs for AOT (`native::executable` would refuse them) |
| `module-container`, `mutarray-typed` | semantic instances 2 -> 0 and 3 -> 0 (NIR identical) | module identity: the container intrinsic types the call directly, no instance is requested |

Nothing was resolved by "choosing the direct output": the direct route is the
authoritative HIR analysis, and each difference above has the relift's specific
missing fact as its cause.

## NIR before / after (17 canonical programs)

Before = parent relifted production route; after = this tree (direct).
`out/tabulate-before-after.txt`, `out/nir-ops-*.txt`.

| | before | after |
|---|---|---|
| NIR functions (emitted) | 247 | 234 |
| generic / specialized functions | 62 / 185 | 38 / 196 |
| NIR lines | 6,381 | 6,087 |
| guards | 69 | 64 |
| direct `call` | 309 | 303 |
| `callenv` / `callmulti` / `callvalue` | 5 / 61 / 9 | 4 / 57 / 8 |
| `closure` / `capture` | 8 / 8 | 5 / 5 |
| `retmulti` | 51 | 50 |
| `op iadd` / `op ilt` / `op mutarrayget` / `op regioneq` | 123 / 33 / 36 / 66 | 113 / 31 / 32 / 62 |
| `op rbox` / `op runbox` | 39 / 36 | 42 / 41 |
| scalar code bytes (`native::codeSize`) | 109,539 | 103,331 |

`callvalue` 9 -> 8: the one that changed is in `uri-steady`, where the
specialized `web::` instances resolve a callee the generic instance did not
know; nothing about exact-callable identity or the dynamic dispatch policy
changed (`{block E}` and `{native NAME}` targets are read from HIR; structural
`Fn` boundaries are unchanged: `exact-callables` probe, identical NIR).

## Semantic-instance census

| | relift's re-analysis (before, native side) | front end (what native now consumes, plus `prepareHir` re-check) |
|---|---|---|
| requests / trivial / hits | 1,808 / 610 / 913 | 1,825 / 605 / 935 |
| instances = used | 285 / 285 | 285 / 285 |
| body walks / rounds | 379 / 17 | 383 / 17 |

The front end itself is untouched: its census on unprepared HIR reproduces the
strict-reference fence exactly (requests 1,715, trivial 578, hits 869,
instances 268, walks 363, rounds 17, recursive participants 95, no-env and
budget declines 0, retained state 462,726 bytes). The extra 17 instances and
20 walks in the "after" column are `refined-checks` (its `emailish?` module
implementation, added by `prepareHir` and analyzed by its one re-check; the
relift analyzed the same program). Semantic instancing is not repeated: the
relift recomputed the table for a weaker HIR (the small request/hit differences
are that recomputation), the direct route reads the front end's.

## Specialization and AOT census

| | before | after |
|---|---|---|
| used codegen instances | 258 | 245 |
| emitted functions | 247 | 234 |
| generic / specialized emitted | 62 / 185 | 38 / 196 |
| guards | 69 | 64 |
| AOT closed / guarded / open (used instances) | 213 / 41 / 4 | 207 / 38 / 0 |

No instance was created mechanically by the cleanup; every change is a row of
the table above.

## Machine code

Scalar assembly for the four `bench` programs of the committed audit corpus:
`fib`, `loop-count`, `sum-refined` byte-identical to the parent fence;
`refined-checks` differs only in the declared-error id immediates (the same
class as its NIR difference). The nine `examples/stdlib` programs come from
the direct route in both (the audit script already compiled them from HIR):
byte-identical. `audit/native-scalar-asm/` was regenerated through the direct
route and compared with the parent fence with `git diff`: 12 of the 13
programs are byte-identical; `refined-checks.asm`/`.vcode` differ in one
immediate (`mov esi,0x2` -> `0x1`, the declared-error id), nothing else.

## Compile-time impact

`tools/compiletime.tcl`, median of 5 runs, milliseconds, sum over the 17
programs (`out/compiletime-*.txt`); the parent measured through
`-mode relift`, this tree through `-mode direct`:

| step | before | after |
|---|---|---|
| front-end HIR analysis (`surface::readProgramFile`) | 2,149 | 1,979 |
| relift (`hir::lower` + `buildProgramHir`) / `prepareHir` | 1,607 | 225 |
| NIR lowering (`native::lower::program`) | 2,725 | 2,423 |
| Cranelift JIT compile | 154 | 142 |
| total | 6,635 | 4,769 |

The front end is byte-for-byte the same code in both trees, so its 8% spread is
the measurement's noise floor. Removing the relift saves about 1.4 s over the
corpus (a fifth of the whole native preparation path); 214 ms of the 225 ms left
is `refined-checks`, the one canonical program whose `prepareHir` really does
attach an implementation and re-check. NIR lowering also got faster because
the direct HIR has fewer generic instances to lower. The direct total is 28%
lower; about 1.4 s of that is the round trip itself.

## Memory impact

`tools/memory.tcl` (string sizes of Tcl values, not allocator bytes): for the 17
programs the relift route held, in addition to the front end's 2.33 MB HIR, the
core IR text (70 KB) and a reconstructed HIR of 1.90 MB (81% of the front-end
HIR; `csv_records` alone 413 KB, of which the recomputed semantic table is 133
KB) for the duration of every native compile. The direct route holds neither.
Only the two programs `prepareHir` re-checks hold a second HIR while it runs.

## Runtime and allocation parity

Allocation reports (`native::allocationReport` summary, `out/alloc-*.txt`):
16 of 17 canonical programs are **identical** to the relifted route -- the
MutableArray workloads (`csv_chunked`, `csv_geometric`, `csv_records`,
`hashtable`), the CSV, string (`string_replace`, `string_reverse`,
`ai_text_clean`, `lex-strategy`), closure (`source-checks`, `test-selection`)
and scalar programs alike, including `csv_geometric`/`csv_records`, whose
machine code changed (the changes are guards and generic instances, which
allocate nothing). The exception is `uri-steady`: 38,513 -> 38,511
allocations, 2 `Block` objects fewer, because its `web::` functions specialize.
Against the parent's *existing* direct route this tree is byte-identical in
allocation and NIR for all 30 programs.

Runtime (`tools/runtime.tcl`, best of 30, us; `out/runtime-*.txt`), before ->
after: `fib` 155.5 -> 155.5, `loop-count` 1.68 -> 1.62, `uri-steady` 4,996 ->
4,751 (-5%, 5 guards and 7 functions fewer), `refined-checks` 790 -> 791,
`csv_records` 9.42 -> 9.33, `csv_geometric` 1.78 -> 1.74 (the two extra
guards are off the timed path), `hashtable` 1.42 -> 1.01, `matmul` 1.55 ->
1.67, `string_reverse` 1.60 -> 0.85. Programs with identical NIR time
identically up to noise; no runtime regression.

## Full regression

Tcl 9.0.1, Rust stable, `LANG=C.utf8`.

| | parent | after |
|---|---|---|
| `tests/all.tcl`, interp | 3,249 / 3,249 | **3,282 / 3,282**, 0 failed |
| `tests/all.tcl`, compile | 3,245 passed + 4 skipped, 0 failed | **3,278 passed + 4 skipped, 0 failed** |
| `tests/native-coverage.tcl` (cranelift over the suite) | 3,282 tests: native 1,226, independent 1,998, passed-partial 8, unsupported 49, failed 1 (`refined-5`) | **3,315 tests: native 1,250, independent 2,007, passed-partial 8, unsupported 49, failed 1 (`refined-5`)** |
| `cargo test --release` | -- | 22 passed |

The 33 new tests are `tests/direct-hir-native.test`. The four skipped
compile-round tests are the interpreter-only `coreScoping` group (true Core IR
scoping tests stay interpreter-only; native was not asked to support raw Core IR
behaviour). The unsupported set is *identical* to the parent's, class by class
and member by member (`out/coverage-after.txt`, `out/coverage-parent.txt`);
`refined-5` fails in the parent too (pre-existing). GC stress
(`BOTLISH_NATIVE_GC_STRESS=1`) over `native-*`, `module-*`, `mutarray-*`,
`virtual-construction` and `direct-hir-native` tests: 782 / 782.
`gc-stress` on CI runs the whole suite; the changed native areas are the NIR
cell ops (roots) and nothing else.

## Benchmark and corpus parity

`bench/bench.tcl -runs 1` (`out/bench-after-runs1.txt`): all eight canonical
programs agree across interp, compile and Cranelift (no `VALUES DIFFER`, exit
0). `bench/corpus.tcl -runs 1` (`out/corpus-after-runs1.txt`): all 19 rows
`agree` on all four backends. `tests/bench-corpus.test`, `bench-backends.test`,
`stdlib.test` are in the suite.

## Core IR interpreter parity

Nothing on the interpreter branch was changed. The full suite passes on interp
and compile; every one of the 30 audited programs gives the same value on the
interpreter (`hir::lower` -> `core::evalProgram`) and on direct native
(`out/summary-after-direct.txt`, interp and native digests equal on every row);
`main.tcl -backend interp` and `-backend compile` run every `examples/*.ir`;
the `direct-hir-differential-*` tests compare `source -> HIR -> core IR ->
Tcl` with `source -> HIR -> NIR -> native` (specialized and generic) for ten
programs and, in `direct-hir-differential-corpus`, for the whole canonical
corpus. CI's cranelift example step was corrected to use `examples/hir/*.hir`
instead of `examples/*.ir`, and to skip `examples/surface/09` (a rejection
example since strict references).

## Remaining Core IR consumers

* the Tcl reference interpreter (`core/`, `core::evalProgram`, `core::eval*`);
* the Tcl compiler (`compiler/`): `core::compiler::runProgram` compiles core IR
  (building its own HIR for facts), `core::compiler::evalHir` lowers HIR with
  `hir::lower` for its own use -- a Tcl backend, not native;
* `hir::lower` callers: `main.tcl` (interp, `-code`), `bench/bench.tcl`,
  `bench/corpus.tcl`, `bench/uri-steady.tcl`, `examples/stdlib/corpus.tcl`
  (Tcl backends), tests (reference branch of the differentials);
* Core IR text as an *input notation*: `hir::build` (examples/*.ir, bench/*.ir,
  tests, `native/explain-native.tcl`, the fixture generators);
* Core IR tests (`acceptance`, `blocks`, `bindings`, `calls`, `control`,
  `loops`, ... and the `coreScoping` group);
* debugging/printing: `hir::format`/`hir::read` round trips, `core::compiler::generatedCode`;
* **native-adjacent, justified**: `native::prepareHir` reads a native's
  registered `-native-body` (core IR *data* that defines that native) through
  `hir::syntax::fromIR`; and the test harness's `cranelift` adapter (test-only).

## Architecture guard tests

`tests/direct-hir-native.test`: `direct-hir-relift-machinery-removed`,
`direct-hir-no-production-native-backend` (fresh process: `core::backends` is
`compile interp`), `direct-hir-native-namespace-static-scan` (procs of
`::native` never mention `hir::lower`, `buildProgramHir`, `core::ir::check`,
`core::evalProgram`, `core::compiler::`),
`direct-hir-native-entry-points-never-call-core-ir` and
`direct-hir-native-executable-never-calls-core-ir` (execution traces),
`direct-hir-main-rejects-core-ir-for-native`.

## Known limitations

* `csv_geometric` keeps two `guard mutarray` (the `join(mutarray,
  MutableArray[T])` gap); the relift hid it. Not fixed.
* `prepareHir` still attaches a native body by replacing a call's callee, which
  removes that call as a refinement source (a redundant second validator call
  is a real call: `native-validator-predicate-known-result-nir-shape` pins 4
  `op strlen`). Same as before; a side-table body instead of a callee swap
  would fix it and is out of scope.
* `prepareHir`'s re-check re-runs the full front-end analysis for a program that
  calls such a native (2 of 30 audited programs). Loading the implementation
  modules in the front end would remove it.
* The test harness backend remembers the HIR of every program `hir::lower`
  produced (memory grows with a test file's size).
* Frozen `audit/*/tools` scripts that compared the relifted pipeline
  (`typed-mutarray-builder-refactor/relift.tcl`, the opportunistic census's
  "native" HIR, `structural-function-types/typecensus.tcl`,
  `strict-reference-determinism/experiment/measure.tcl`) are marked LEGACY and
  run only against a pre-milestone tree; the other audit scripts that used
  `buildProgramHir` now call `native::prepareHir` on the front-end HIR (or
  `hir::build` for `.ir` fixtures). `audit/mutarray-construction/tools/probe-typing.tcl`
  and `audit/post-module-static-exact-target-census/tools/parity.tcl` still
  call `core::useBackend $backend` and do not select `cranelift` any more.

## Readiness for NIR -> bytecode

The NIR API is clean enough: a bytecode consumer takes HIR through
`native::lowered` (or `native::nir`) and reads the NIR text; it needs nothing
from Core IR and nothing from the Rust runtime's Cranelift half. What it would
share: `native::prepareHir`, the HIR analyses and the NIR grammar
(`native/lower.tcl` header, `native/src/nir.rs`). No HIR or Core IR change is
needed. Cell ops no longer have to be implemented.

## Required architecture questions

1. HIR. 2. The Tcl reference interpreter's small executable representation (and the
Tcl compiler's input). 3. Production executable lowering (native now, bytecode
later). 4. No. 5. No.

## Required path questions

6. `surface::readProgramFile` (parse, resolve, hygiene, `hir::check`) ->
`native::evalHir` = `native::nir` -> `native::lowered` -> `native::prepareHir`
-> `native::lower::program` -> NIR -> `botlish-native run`.
7. The same up to `native::lowered`; `native::executable` first checks readiness
(`hir::specialize::analyze` + `regions`, must be all `closed`), then `nir`, then
`botlish-native executable` (object + `rustc` link against the runtime).
8. `surface::readProgramFile` -> `hir::lower` -> `core::evalProgram`.
9. `native::lowered` (through `native::nir`) -> `native::lower::program`.
10. No (deleted).

## Required analysis questions

11. `hir::signatures::infer`, in `hir::check` from `hir::buildSyntax` (front end).
12. `hir::semantic`, inside the front end's typing (`hir::types::infer`), verified
in `hir::check`.
13. Refinements: `hir::types`/`hir::refine` (front end). Declared range
verification: `hir::range::verify*` (front end). Representation ranges:
`hir::range::analyze`, run by `native::lower::program`.
14. `hir::specialize` (and `hir::aot` classification), run by
`native::lower::program` and `native::executable`'s readiness check.
15. No, because production native no longer goes through Core IR.
16. `hir::specialize` calls `hir::semantic::GenericResult` on the HIR it is
given; `hir::range` and `hir::callables` call `InstanceOf`/`EntryTypes`; the
lowerer reads results through those, never from core IR.

## Required Core IR questions

17. The list above. 18. The registered `cranelift`/`cranelift-generic` backends,
`native::runProgram`, `buildProgramHir`, `ExpandNativeBodies`,
`ModuleNativeBridge`, `main.tcl`'s `.ir` native paths and `native::evalHir`'s
lowering. 19. Yes, by the Tcl reference interpreter. 20. Not as a production
feature: `main.tcl` rejects it, `native/` has no entry for it; a test harness
adapter (`tests/helpers.tcl`) reads core IR text into HIR for coverage. 21. No.

## Required hygiene questions

22. Yes. 23. HIR construction applies it once for every consumer; its purpose is
the HIR -> Core IR/reference branch (`qualifyModules` is also HIR-level module
identity). 24. No. 25. Resolved HIR binding identity (BindingId/ExprId).

## Required relift questions

26. Resolved names again, typed, inferred contracts, ran semantic instancing and
every check on a rebuilt HIR, after `ExpandNativeBodies` substituted native
bodies by name and `ModuleNativeBridge` prepended module sections.
27. Source locations, declared parameter/result types, `errors` clauses and
declarations, source types, module scopes/identity, container intrinsic
identity, applied `MutableArray[T]`, module-static provenance, the front end's
semantic table, contract-violation records.
28. All of them, straight from HIR.
29. No relift logic; `prepareHir` keeps the *attachment* of native
implementations (needed, resolved-HIR based). 30. It reads the registry's
native body data and the module sections by resolved binding identity and
never builds HIR from the program's own core IR.

## Required hidden-normalization questions

31-32. See "Hidden core IR normalizations audited": binding-name renames and
type/capture/target recomputation: not needed by native (retained only for core
IR / already present in HIR); module flattening and erased declarations:
harmful, not needed; native-body substitution and module bridge: moved to
`prepareHir`; completions, loops, closures, call shape: already present
independently. 33. Yes, three (declared-contract violation, `known` validator
call, `staticSlots` leak); dispositions in the same section.

## Required hybrid questions

34. There is no hybrid executable; nothing depended on Core IR. 35. n/a (none
existed). 36. No supported native executable operation embeds Core IR.

## Required native executable questions

37. `native::executable HIR PATH` (CLI: `main.tcl -emit-native-executable
FILE.bot|FILE.hir`). 38. Yes, the same `native::nir` -> Driver route. 39. See
"Native executable creation integration" and `out/executables.txt`.
40. Yes; every built executable's output equalled the interpreter and in-process
native values.

## Required cell cleanup questions

41. No. 42. Yes, `Inst::Cell*` and the parser cases are deleted. 43. Not
after this change. 44. Yes, `CellObj`, `KIND_CELL`, `rt_cell_new`, `rt_unbound`,
the `UNBOUND` tag, the heap cases, the `Cell` metrics kind. 45. Nothing remains.

## Required differential questions

46. No: 25 of 30 programs raw-identical, 27 of 30 canonically identical (13 of
17 canonical programs raw-identical, 14 canonically); the rest classified. 47. Assembly equal
for 25 of 30 (same programs). 48. `csv_geometric`, `csv_records`,
`uri-steady`, `refined-checks`, `module-web` (and AOT status only: `errors`,
`semantic-instances`, `source-checks`, `test-selection`; semantic census only:
`module-container`, `mutarray-typed`). 49. Yes: `uri-steady`, `csv_records`,
`module-container`, and the applied-type loss behind `csv_geometric`. 50.
Classification, then verification that every difference is a missing relift
fact and that values agree; the relift was deleted only after that.

## Required census questions

51-60: see the tables (semantic instances 285 -> 285 on the compiled HIR, front
end unchanged at 268; body walks 379 -> 383; used codegen 258 -> 245; emitted
247 -> 234; AOT 213/41/4 -> 207/38/0; guards 69 -> 64; calls 309 -> 303,
callvalue 9 -> 8; NIR 6,381 -> 6,087 lines; code bytes 109,539 -> 103,331;
compile time in "Compile-time impact").

## Required test questions

61. interp 3,282/3,282; compile 3,278 + 4 skipped; coverage 3,315 tests (native
1,250, independent 2,007, passed-partial 8, unsupported 49, failed 1 =
pre-existing `refined-5`); Rust unit tests 22/22. 62. The four `coreScoping`
tests (Core IR declare-on-entry), interpreter-only by design. 63. As above;
the unsupported set equals the parent's. 64. All eight programs agree
(`bench.tcl -runs 1`). 65. 19/19 corpus rows agree; canonical corpus values equal
across interpreter and direct native. 66. 18 executables built and run, all equal;
plus the 14 `native-executable` tests and 9 new executable tests. 67. Shadowing:
`direct-hir-shadowing-three-way`, `direct-hir-hygiene-source-three-way`,
executables for both probes. 68. Modules: `module-call`, `module-container`,
`module-web` probes (differential and executables), `direct-hir-module-identity-in-native-hir`.
69. Closures: `closures` probe, `direct-hir-differential-closures`,
`make_adder` executable, `native-executable-closure`.
