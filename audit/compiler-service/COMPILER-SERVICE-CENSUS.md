# Compiler service census

Compiler service, semantic queries, incremental analysis and shared CLI/LSP
infrastructure: the smallest sound architecture for making Botlish's compiler
reusable, responsive and queryable, measured on the compiler as it is.

State: `main` at `c7e4d4fd` (2026-10-22). The canonical `std::` namespace
milestone (`origin/claude/botlish-std-namespace-milestone-rjfef8`, merge-base
`c7e4d4fd`) was inspected but not touched; where it matters it is named.
Everything this census added is under `audit/compiler-service/`: probes,
a benchmark harness and their results. No compiler file was changed.

## Contents

1. [Result](#1-result)
2. [Current-state inventory](#2-current-state-inventory)
3. [State and lifetime model](#3-state-and-lifetime-model)
4. [Query capability matrix](#4-query-capability-matrix)
5. [Source-overlay and revision model](#5-source-overlay-and-revision-model)
6. [Incrementality alternatives](#6-incrementality-alternatives)
7. [Performance results](#7-performance-results)
8. [FFI and JSON feasibility](#8-ffi-and-json-feasibility)
9. [Platform requirements](#9-platform-requirements)
10. [Proposed service contract](#10-proposed-service-contract)
11. [Recommended milestone sequence](#11-recommended-milestone-sequence)
12. [Rejected approaches](#12-rejected-approaches)
13. [Open questions](#13-open-questions)
14. [Reproducing the evidence](#14-reproducing-the-evidence)

## 1. Result

**The compiler is ready for a minimal shared service, in process, over its
existing whole-program analysis.** A lenient build already returns, for any
program without a syntax or loader error, a complete HIR:

* every expression with a source *range* and an edit-stable AST node id;
* every reference resolved to a binding identity;
* every expression typed;
* every independent semantic error as structured data.

Activation makes a retained HIR safe to query after other programs are
analyzed. The census measured this, with a positive control. Source
acquisition is exactly two primitives, so unsaved editor text needs a seam,
not a redesign. A service is new Tcl code over existing functions, plus two
small core changes.

**What prevents a basic LSP today**, each measured:

1. **No source seam, and two definitions of "the text".** The loader reads
   the disk directly. A CRLF or lone-CR document analyzes differently as a
   buffer than as a file: different offsets, or syntax errors (§4.4).
2. **Loader and syntax diagnostics are not data.** Their location exists
   only inside the message text. Syntax diagnostics have no end position.
   No diagnostic has a severity (§2.5).
3. **No query layer.** There is no position lookup or index. Type text
   leaks internal ids (`block(e8)/2 -> int`). Definition ranges are whole
   statements: the AST's `nameSpan` is needed (§4.2).
4. **One syntax or loader error anywhere removes all semantic facts for the
   whole program** (§4.1). An editor must answer from the last successful
   revision, marked stale.
5. **Type printing reads process-wide registries.** Queries must activate
   the revision first. Without that, a retained HIR's hover crashed or
   silently read another program's declaration (§3.2).
6. **No transport.** No stdio framing, no JSON (pinned Tcl has no `json`
   package), no UTF-16 conversion. The compiler counts Unicode scalars
   (§4.4).

**Incremental compilation is not required for version 1.** Re-analysis after
an edit takes 0.2-1.3 s for the repository's applications and 7-8 s for its
largest single program. Hover and definition read the last revision in
0.03-7 ms unindexed (§7). The measured bottleneck is the whole-program HIR
build multiplied by decision builds, not parsing, activation or start-up.
Module-granular reuse keyed by interface text would be unsound: a body edit
with an unchanged signature flips an importer's diagnostics (§6.1).

**A persistent daemon is not justified by the evidence.** Tcl starts in
7 ms. Loading the compiler costs 80 ms. The existing front-end cache already
makes an unchanged program's whole CLI run take 92-266 ms. For an editor,
the stdio LSP process is the persistent process: it keeps the compiler
loaded, the bytecode compiled, the parse cache warm and the last revision in
memory. A separate daemon adds lifecycle, IPC and security work for no
measured gain (§7.7).

**Prerequisites that can proceed independently** (§11):

* P1: structured front-end diagnostics.
* P2: the source-provider seam, after the `std::` milestone merges.
* P3: `char::from_scalar`.
* P4: library mode with export roots, for `exported c fn`.
* P5: library-module analysis reuse, worth up to 5-35% of an analysis.

### The ten decisions

1. **The smallest service to implement next.** An in-process Tcl layer:
   * a workspace with overlays;
   * immutable revisions (a provider snapshot plus the lenient analysis);
   * the CLI's diagnostics as structured records;
   * one position query: construct, type, definition, references within the
     revision, diagnostics and Compilerpedia topics there;
   * `main.tcl -check`.

   Milestone S1 in §11; §10 has the contract.
2. **Can the first LSP use whole-program analysis without unacceptable
   latency?** Yes, for diagnostics after a debounce or on save, and for
   queries served from the last revision (§7.2, §7.5). Per-keystroke
   re-analysis is not possible on the larger programs, and version 1 does
   not need it.
3. **Unsaved source, revisions, HIR and module identity.** One normalized
   text per location. A revision records every location it read or probed,
   with its text or its absence, which is the cache's dependency model. A
   HIR belongs to exactly one revision. Module identity stays the canonical
   namespace; the path is derived from it, and the text is per revision
   (§5.3, §5.4).
4. **Which queries exist and what is missing.**
   * Present: resolution, types, binding origins and diagnostics, as data;
     in-revision references by walking the HIR.
   * Missing: position lookup, presentable type text, name ranges,
     structured loader diagnostics, any semantics while a syntax error
     exists, and identity across revisions. The last is solvable with
     {module, AST node id}, measured stable (§4).
5. **Can CLI and LSP share analysis without a daemon?** Yes. They call the
   same in-process function. The on-disk front-end cache is already shared
   across processes and validated by content (§5.4 rule 6).
6. **Where Tcl ends and Botlish begins.** For version 1, Tcl owns transport,
   JSON and JSON-RPC. Botlish-implemented protocol code needs native speed
   (9.7 µs per message, against 17.5 ms on the in-process Tcl backend), and
   that needs library mode. The boundary then becomes "UTF-8 bytes in, bytes
   or a packed table out" (§8.5).
7. **What `exported c fn` must provide.**
   * Export roots compiled under the declared contract only. The stand-in's
     call-site specialization silently produced wrong results (§8.2).
   * C-ABI trampolines with statuses.
   * Byte-buffer results with explicit ownership and release.
   * Errors as identity plus structured payload.
   * An explicit Vm handle with no `_exit`, a GC walk bounded at the export,
     and a stack policy.
   * Several libraries per process, and a loadable artifact (§8.6).
8. **Stdlib prerequisites for the first vertical slice.** None: a stdio LSP
   in Tcl needs no Botlish sockets, files, watchers or time (§9.1).
   * A Botlish JSON library later needs `char::from_scalar`.
   * Sockets, watchers and time matter only for a daemon, which the evidence
     does not justify.
9. **Which bottleneck justifies persistence or incrementality.** Persistence
   is justified exactly at the LSP process, by the measured 80 ms load,
   30-260 ms of bytecode recompilation (§14) and up to 318 ms of module
   parsing. The
   front-end cache covers the CLI. Incrementality is justified by nothing
   measured yet. If version 1's latency must improve, library reuse (P5)
   comes first: a sound, bounded step.
10. **The next milestone and what it leaves alone.** S1. It leaves alone the
    loader's resolution rules, the HIR, the registries, activation, the cache
    format, the backends and Compilerpedia's catalogue. It adds no daemon,
    socket, watcher, JSON, UTF-16 or incremental mechanism (§11).

### What the census added

`audit/compiler-service/`:

| Path | What |
|---|---|
| `probes/lib.tcl` | the probe library: lenient analysis with structured diagnostics, an overlay, a position query |
| `probes/isolation.tcl` | multi-program isolation, two disciplines, positive control |
| `probes/queries.tcl` | the capability matrix and the stable symbol key |
| `probes/coords.tcl` | coordinate conventions, line endings |
| `probes/overlay.tcl` | unsaved buffers, in-memory workspaces, created and deleted files |
| `probes/deps.tcl`, `probes/bodyfacts.tcl` | edit consequences, cross-module body facts |
| `probes/longrun.tcl` | memory in a long-running process |
| `probes/json/` | a Botlish JSON tokenizer, its cases, throughput, in-process calls |
| `probes/export/` | Tcl calling native Botlish through the library-mode stand-in |
| `bench/service-bench.tcl`, `bench/twice.tcl`, `bench/library-share.tcl`, `bench/wrapcost.tcl` | the benchmark harness |
| `results/` | every probe's and benchmark's output, as cited |

No compiler, library, test or document outside `audit/compiler-service/`
was changed.

## 2. Current-state inventory

What exists, read from the code. "Implemented" means exercised by the
census's probes or the repository's tests; "partial" means present but not
usable as a service needs it; "documented intent" means described in a design
document with no code; "missing" means neither.

### 2.1 The command line

| Component | Entry points | Inputs → outputs | State | Status |
|---|---|---|---|---|
| CLI dispatch | `main.tcl:233` `parseCommandLine`; `main.tcl:335-343` (usage, `-help`); `main.tcl:693-703` (one `runFile`/`emitExecutable`/`emitInterchange` per input file) | argv → printed output, exit status | `hintsShown` (`main.tcl:377`), option globals | implemented |
| Compilerpedia from the CLI | `main.tcl:339-342`: `-help` sources only `compilerpedia/compilerpedia.tcl`, never the compiler | query words → page | the catalogue cache | implemented, offline |
| Compile and run a file | `main.tcl:431` `runFile`: a recovering parse of the entry (`main.tcl:439`), then `surface::readProgramFile` (`main.tcl:459`), which reads and parses the entry again (`surface/modules.tcl:1665`, `:1684`) | `.bot`/`.hir`/`.hirx`/`.ir` → value, diagnostics | none of its own | implemented |
| Help lines under diagnostics | `main.tcl:359` `printError`, `:378` `helpHint`, `:394` `warningHints` → `compilerpedia::topicForDiagnostic` | printed code + message → topic id | `hintsShown` | implemented (presentation only, by design: AGENTS.md "Compilerpedia") |
| Analysis without running | none: every `.bot` input is run unless `-emit-hir-interchange` or `-emit-native-executable` is given (`main.tcl:694-701`) | — | — | **missing** (no `-check`) |

A CLI process compiles several files in sequence (`main.tcl:694`), so
repeated compilation in one Tcl process is already a supported use, not a
new one.

### 2.2 Front end: lexing, parsing, recovery, positions

| Component | Entry points | Notes | Status |
|---|---|---|---|
| Lexer | `surface/lexer.tcl:103` `surface::lexer::tokenize`, `:95` `surface::lex` | Never stops at an error; records diagnostics and recovers locally (`lexer.tcl:44-78`). Positions are Tcl string indices: Unicode scalar values (`lexer.tcl:450-453`, `Span`). `\r\n` is accepted, a lone `\r` is an error (`lexer.tcl:193-198`). Identifiers are ASCII (`lexer.tcl:9`). | implemented |
| Parser | `surface/parser.tcl:396` `surface::parse SOURCE ?FILE? ?-recover 1?` | With `-recover 1` returns an AST whose `diagnostics` lists every syntax error; without, raises the first (`{SURFACE SYNTAX DICT}`) | implemented |
| AST node ids | `surface/ast.tcl:248-267` | Structural, position-free ids (`add()`, `x=`, `make_adder()/add()/binary`), designed to survive edits elsewhere ("for tooling and incremental use") | implemented |
| AST spans | `surface/ast.tcl:8-13` | Every node: `{file start end line column endLine endColumn}`; declarations also carry `nameSpan` (functions, bindings, struct declarations; census probe) | implemented |
| Syntax diagnostics | `surface/ast.tcl:306` `surface::diagnostic` | `{file line column start end message}`: no `endLine`/`endColumn`, no severity, no code beyond `SURFACE SYNTAX` | partial |
| Lowering to HIR syntax | `surface/lower.tcl:148` `surface::lowerToHir`; `:377` `Origin` | Raises the AST's syntax diagnostics first (`lower.tcl:167-171`): **a recovered AST is never lowered** | implemented (strict) |

### 2.3 Modules: discovery, imports, dependencies

| Component | Entry points | Notes | Status |
|---|---|---|---|
| Program-file entry | `surface/surface.tcl:52` `surface::readProgramFile` → `surface/modules.tcl:1656` `compileProgramFile` | Reads the entry (`modules.tcl:1665`), consults the front-end cache (`:1678`), parses **without** recovery (`:1684`), builds, finishes, stores (`:1686`) | implemented |
| Program-text entry | `surface/surface.tcl:39` `surface::compile`; `modules.tcl:1608` `BuildProgram AST STRICT TARGET ROOT` | Takes an AST the caller produced from any text: the entry's source need not be a file | implemented |
| Module resolution | `modules.tcl:260` `ResolveModule`, `:425` `ModuleFile`, `:248` `ApplicationFile` | Search-free: a namespace maps to one standard path or one application path (root = entry file's directory). Probes the filesystem with `file exists`/`file isfile` (`:250`, `:390`, `:400`, `:406`, `:428`, `:839`) | implemented |
| Module loading | `modules.tcl:825` `LoadNamespace`, `:1174` `CollectAndLoad` | Recursive over imports, cycle detection, one FileId per file (`:872`, `f1` the entry). Loader errors raise at once, except qualified-reference errors, which accumulate (`:1196-1201`, `:1563`) | implemented |
| Module parse cache | `modules.tcl:171` `parsed`, `:180` `ParseModule` | ASTs by `{PATH TEXT}`: a module whose text is unchanged is not re-parsed in the same process; cleared whole past 64 entries (`:190`) | implemented |
| Dependency graph | `NewState`'s `imports` (`modules.tcl:1546`), kept in the HIR as `declarations imports` | Per file: its import environment. **No reverse index, no per-file semantic result** | partial |
| Compilation unit | `modules.tcl:1633-1639` | Every loaded module's statements are lowered into **one** `hir::buildSyntax` call with the entry program: one whole-program HIR | implemented (by design) |

### 2.4 HIR: construction, analysis, activation, serialization, caching

| Component | Entry points | Notes | Status |
|---|---|---|---|
| Build | `hir/hir.tcl:489` `hir::buildSyntax` → `:536` `BuildFull` → `:610` `BuildOnce` | One compilation is one or more whole-program builds (method-call trial builds, static-decision rounds, trait monomorphization: the counters at `hir/hir.tcl:243-256`). Measured: 1-3 builds for the census's workloads | implemented |
| Data model | `hir/hir.tcl:36-232` | Flat tables: `exprs`, `scopes`, `bindings`, `types`, `files`, `modules`, `diagnostics`, side tables. Ids per build, deterministic (`hir.tcl:93-97`, `:351` `NewId`) | implemented |
| Origins | `hir/hir.tcl:103-108` | Every expression: `{file fN node AST-ID start end line column endLine endColumn}` — a range plus the AST node id | implemented |
| Name resolution | `hir/resolve.tcl:96` `program`, `:2296` `ResolveRef`, `:2009` `ResolveQualifiedRef` | Every `ref` carries its `binding` (`""` if unresolved); every binding its `origin` and `declaredBy` | implemented |
| Types | `hir/hir.tcl:1446` `hir::typeOf`, `hir/types.tcl:2520` `hir::types::show` | Every expression typed; `show` reads the process-wide type registry for refined/domain types (census isolation probe) | implemented |
| Lenient builds | `hir/hir.tcl:400-402`, `surface/lower.tcl:352` `Finish` | `-strict 0` keeps the HIR and its diagnostics; `hir::recovery::reported` (`hir/recovery.tcl:59`) narrows to what a strict build reports | implemented |
| Activation | `hir/declarations.tcl:97` `hir::activate`, `:49` `capture`, `:109` `Install` | A HIR's `declarations` side table restores the registries (COMPILATION-ISOLATION.md) | implemented |
| Interchange | `hir/interchange.tcl:132` `decode`, `encode`; `:61` `fingerprint` (computed once per process) | A HIR as text, readable in any process with the same front end | implemented |
| Front-end cache | `surface/cache.tcl:171` `lookup`, `:229` `store`, `:90` `Key`, `:132` `Dependencies` | Whole-program, keyed by the entry's path and **text**; validated by re-reading every dependency's text (`cache.tcl:191-197`); opt-in (`BOTLISH_HIR_CACHE`) | implemented |
| Position lookup | `hir/hir.tcl:1675` `hir::exprsAt` (by exact origin, linear); `surface/lower.tcl:365` `surface::hirExprs` (by AST id, linear) | No file+line+column lookup, no index | **missing** |

### 2.5 Diagnostics and Compilerpedia

| Component | Entry points | Notes | Status |
|---|---|---|---|
| Semantic diagnostics | `hir/hir.tcl:362` `hir::Diagnose` | `{kind message expr ?origin? ?related?}`: structured, located through `expr` or `origin` | implemented |
| Strict raise | `hir/recovery.tcl:196` `raise` → `core/errors.tcl:62` `core::raiseDiagnostics` | Flattens each to `{errorcode message}` with "FILE:LINE:COL: " in the text: the expr, the range and `related` are dropped | partial |
| Loader diagnostics | `surface/modules.tcl:450` `Error` | `{SURFACE MODULE KIND}`; location only in the message text | partial |
| Warnings | `hir/warnings.tcl:128` `run`, `:78` `of` | `{code message primary secondary data}` with origins; computed only for a HIR with no error (`warnings.tcl:132`) | implemented |
| Severity | — | No diagnostic shape has a severity; errors and warnings travel separately | missing (derivable) |
| Compilerpedia | `compilerpedia/compilerpedia.tcl:525` `topicForDiagnostic CODE MESSAGE`, `:564` `lookup`, `:281` `reset`, `:1065` `main` | Catalogue only: 13 hand-written topic files plus `generated/stdlib.topic`; never compiles (`compilerpedia.tcl:21-25`). Header scan for help lines (`:292`), full parse for searches (`:258`) | implemented |
| Type or declaration explanations | — | No API takes a type or a declaration; `lookup` accepts a stdlib name string | missing |

### 2.6 Backends and foreign boundaries

| Component | Entry points | Notes | Status |
|---|---|---|---|
| Interpreter | `hir::lower` → `core::evalProgram` | In process | implemented |
| Tcl compiler | `compiler/compiler.tcl:206` `compileHir`, `:238` `evalUnit`, `:227` `evalHir` | In process; code cache never evicted (`compiler.tcl:89`; COMPILATION-ISOLATION.md "Never reclaimed") | implemented |
| Native | `native/native.tcl:377` `native::evalHir`, `:221` `native::nir`, `:412` `native::executable` | NIR lowered in Tcl, then **one `botlish-native` process per run** (`native/native.tcl:29-33`, `:256` `RunDriver`) | implemented |
| C calls out | `extern c fn`, `extern c library` (C-FFI.md) | Native only; Tcl backends refuse (`NATIVE-ONLY`) | implemented |
| Botlish called from C | `exported c fn` | Grammar, lowering and library output absent (§8) | documented intent (C-ABI-TYPES.md:42, :686-693) |
| Library mode | `audit/react-native/tools/libmode.tcl` | An audit stand-in: static library over a captured executable startup | partial (audit only) |
| Botlish called from Tcl in process | `core::callable::invoke` (`core/callable.tcl:9`) on a block value a Tcl-backend program returned | Works today on interp and compile (§8.1) | implemented, unused |

### 2.7 Standard-library facilities the bridge would use

| Facility | Where | Status |
|---|---|---|
| JSON | — | missing |
| String scanning | `str::length`, `str::char_at`, `str::substring`, `str::append_char`, `char::scalar_value` (`core/strings.tcl:114-129`, `core/unicodechar.tcl:29`) | implemented (all backends) |
| Int → UnicodeChar | — | **missing**: `char::scalar_value` is the only character primitive |
| Bytes | `abi::bytes` (`lib/abi/bytes.bot`): construct, length, replace, freeze | partial: no byte read, no UTF-8 decode |
| Binary layouts | `binary::parse` (BINARY-LAYOUT.md) | implemented, fixed-size only ("no prefix parse and no cursor", BINARY-LAYOUT.md:197-214) |
| Files | Linux `read`/`write` on a descriptor; macOS `open`/`read`/`write`/`close` (`lib/darwin.bot`); native only | partial |
| Directory listing, stat, sockets, polling, file notifications, time | — | missing |

## 3. State and lifetime model

### 3.1 What a compilation leaves in the process

| State | Owner | Lifetime | Reset by | Captured in the HIR |
|---|---|---|---|---|
| Declaration registries: source entries of `core::type::registry`, `hir::structs`, `hir::enums`, `hir::layouts`, `hir::errordecls` (current, payloads), `hir::traits` (registry, impls, unitNames), `hir::imports::table`, `hir::foreign` | the last build | until the next build or activation | `hir::BuildOnce` (`hir/hir.tcl:617` invalidates), `hir::declarations::Install` | yes (`declarations`, `hir/declarations.tcl:49-65`) |
| Derived caches: `hir::structs::affinity`, `hir::traits::cache`, `hir::contexts::traitCache` | the registries | until the registries change | `Install` (`declarations.tcl:123`, `:131-132`) | no (derived) |
| Analysis scratch and memo state: `hir::completions::*`, `hir::affine::*`, `hir::cardinality::cache`, `hir::semantic::state`, `hir::specialize::memo*`, `hir::read::last*`, ... (148 namespace variables with initial values in `hir/`) | the analysis that last ran | until the next | each analysis, at its start | no |
| Module ASTs (`surface::modules::parsed`) | the loader | process; at most 64 entries | cleared past 64 (`surface/modules.tcl:190`) | no |
| Module texts read (`surface::modules::reads`) | the last `compileProgramFile` | until the next | `compileProgramFile` (`modules.tcl:1683`) | no |
| Front-end fingerprint | `hir::interchange` | process | never | — |
| Tcl compiler code cache and unit procedures | `core::compiler` | **process, never reclaimed** | never | no |
| Vector, array and byte stores of Tcl-backend runs | `core` | process, never reclaimed (COMPILATION-ISOLATION.md "Defects found") | never | no |
| Compilerpedia catalogue | `compilerpedia` | process | `compilerpedia::reset` | — |
| Tcl libraries loaded by `# requires:` | `core::loadLibrary` (`core/core.tcl:60`) | process, irreversible | never | in the cache key only (no `lib/*.tcl` exists today) |
| Native runtime | a `botlish-native` process per run | the run | process exit | — |

### 3.2 What a HIR snapshot guarantees — measured, not inferred

`audit/compiler-service/probes/isolation.tcl` analyzes seven programs (three
applications sharing module and declaration names with different
definitions — two versions of a module `geo`, one with a transitive
dependency — and four failing programs: a semantic error, an invalid
declaration that fails while the registries are being written, a syntax
error, an unknown import). Each program's facts are first computed alone in a
fresh process (the baseline); then in one process sequentially, retained and
queried again in reverse order, alternated with rebuilds and Compilerpedia
lookups in between, interleaved without rebuilds, and around every failure.
Facts: status, structured diagnostics, position queries (kind, type,
definition, references, diagnostics, topic), `hir::format` text, core IR,
interp and compile outcomes, and the interchange encoding.

| Discipline | Checks | Differences from the baseline |
|---|---:|---:|
| Activate the HIR before querying it | 43 | **0** |
| Query a retained HIR as it is | 43 | **4** |
| Positive control: `hir::activate` disabled | 86 | 9 |

The four differences are one defect seen four times. A hover on an
expression whose type is a source-defined refined type (`geo::Small`) of a
retained HIR fails with `core::type: unknown type "geo::Small"` once another
program has been analyzed: `hir::types::show` normalizes a refined type
through the process-wide registry, and it is not among the entry points that
activate (COMPILATION-ISOLATION.md lists `hir::lower`, `hir::format`, the
specializer, the AOT analysis, the Tcl compiler and native preparation).
After a program that declares a different `geo::Small` (appB's
`100..200`), the same read succeeds. It normalizes through whatever the
registry then holds under that name. The printed name is the same, so the
probe cannot see the difference, but the read is not reading its own
revision.

So, for the questions the census was asked:

* **Sufficient to reconstruct semantic facts?** Yes, with activation: every
  fact the probe reads comes from the HIR plus its `declarations`.
* **Suitable as a long-lived revision?** Yes: a retained HIR answered
  identically after six other analyses, failed ones included.
* **Cheap to activate?** Yes: see §7.4.
* **Safe to retain alongside others?** Yes, as long as every reader
  activates. That is a rule for the service's query layer.
* **Independent of mutable registries after construction?** **No.** It is
  independent *once activated*. Type printing — the core of hover — reads the
  registries.

What the probe does not show: that the 148 analysis-state variables can never
leak. It shows that they did not leak for these programs and orders.
COMPILER-BOTTLENECKS.md §3.10 records the same caution about reusing an
older build: "A build leaves state in namespace variables besides the
registries `hir::activate` restores". The census's design therefore reuses
whole HIRs, never parts of an analysis.

### 3.3 Ownership in a long-running process

`audit/compiler-service/probes/longrun.tcl` analyzes the 2048 demo again and
again in one process. Each round edits `game2048.bot` differently in a buffer
and keeps only the latest analysis, as a service holding one revision per
document would. Every 10 rounds it reports the resident set and every
process-wide compiler variable that grew (`results/longrun.txt`,
`results/longrun-run.txt`):

| Rounds | Analysis only | Analysis, then a compile-backend run of each revision |
|---|---|---|
| 1 | 68 MiB | 68 MiB |
| 40 | 184 MiB; grown: the parse cache, 11 → 50 ASTs | 207 MiB; the parse cache, and 4,200 unit procedures (from 105) |
| 60 | 220 MiB; the parse cache cleared at 64 entries | 251 MiB; 6,300 procedures |
| 80 | 220 MiB | 254 MiB; 8,400 procedures |
| 120 | 220 MiB | — |

* **Analysis alone is bounded.** The one thing that grows is the loader's
  parse cache: one AST per new text (about 2.5 MiB for `game2048.bot`), up
  to 64, then cleared whole. Tcl reuses the memory after that. Nothing the
  analyses keep in namespace variables grows with the number of analyses.
* **Running programs in process is not.** The Tcl compiler's code is never
  reclaimed: 105 procedures per revision, and RSS creeps. That is the gap
  COMPILATION-ISOLATION.md lists as "never reclaimed, but correct". It does
  not matter to a process that only answers queries. It does matter to a
  long-lived process that runs programs (a daemon serving `main.tcl`'s run).
* **The parse cache's bound is the wrong shape for an editor.** 64 entries
  hold 64 superseded versions of one file while it is being typed. A service
  should keep the ASTs of the texts its live revisions read and drop the
  rest.
* **Native code in a host process**: the export probe (§8.2) made 20,000
  calls with RSS 14 → 19 MiB, and 200 allocation-heavy calls with RSS flat.
  The Vm's heap is reused. Destroying it is another matter (§8.6).

Rules that follow: a revision owns its HIR and its ASTs and nothing else; no
query path runs code; a process that runs Botlish code on the Tcl backends
either accepts unbounded growth or restarts, until unit reclamation exists;
temporary state is never left to process exit.

### 3.4 Determinism

Building the same program text twice gives the same ids (`hir/hir.tcl:93-97`)
and, per the isolation probe, the same interchange encoding regardless of
what was built before. One input outside the source affects a build without
being in the HIR: the static scheduler (`BOTLISH_STATIC_SCHEDULER`), which
the cache key already includes (`surface/cache.tcl:102`). The probe library
reads no environment variable.

## 4. Query capability matrix

### 4.1 By program state

`audit/compiler-service/probes/queries.tcl` analyzes eight small two-file
applications and queries a marked position of `main.bot`:

| State | Analysis | Construct | Resolution | Type | Definition | References | Diagnostics (here / all) | Topic |
|---|---|---|---|---|---|---|---|---|
| valid | ok | yes | yes | yes | yes | yes | 0 / 0 | — |
| unfinished expression | syntax | AST only | — | — | — | — | 0 / 1 | — |
| unfinished declaration | syntax | AST only | — | — | — | — | 0 / 1 | — |
| unresolved import | loader | AST only | — | — | — | — | 0 / 1 | — |
| unknown identifier (elsewhere) | semantic | yes | yes | yes | yes | yes | 0 / 1 | — |
| type mismatch (at the position) | semantic | yes | (a literal) | yes | — | — | 1 / 1 | yes |
| multiple independent errors | semantic | yes | yes | yes | yes | yes | 0 / 2 | — |
| edited declaration, dependents unchanged | semantic | yes | yes | yes | yes | yes | 0 / 1 | — |

"Multiple independent errors" writes three errors and gets two. The lenient
HIR holds four diagnostics. `util::f("two")`'s `TYPE` and a `KNOWN-ERROR`
belong to the unit `x = add(...)`, which depends on `add`, whose body failed
resolution. `hir::recovery::reported` withholds them as dependent
(DIAGNOSTIC-RECOVERY.md). The service must report through the same filter,
or the editor would show diagnostics the CLI never prints.

Two thresholds decide what survives:

1. **Semantic errors keep everything.** A lenient build returns a complete,
   typed, resolved HIR with every independent diagnostic. An unbound name
   becomes a `ref` with `binding ""` and type `never`. Everything else is
   answered as for a valid program. The "edited declaration" case shows the
   dependent call site getting its new diagnostic from a whole-program
   re-analysis. Its own text did not change.
2. **A syntax error or a loader error in any file loses all semantic facts
   for the whole program.** `lowerToHir` raises a recovered AST's
   diagnostics before lowering (`surface/lower.tcl:167-171`). The loader
   parses modules without recovery (`surface/modules.tcl:189`) and raises
   at the first unresolved import (`modules.tcl:450-455`). Only the
   recovered AST of the entry file remains. What the census measured as "AST
   only" is syntactic structure: no types, no resolution, no cross-file
   facts. The overlay and dependency probes confirm the module case: a
   syntax error in `util.bot` leaves `main.bot` with no analysis at all.

For an editor this is the most consequential limitation. Typing passes
through syntax errors constantly, and each one blanks hover and definition
for the whole program unless the service keeps the last successful revision.
The census does not propose to manufacture facts. It proposes to answer from
the last revision that had them, explicitly marked stale (§10).

### 4.2 By query

| Query | Today | Prerequisite for a service |
|---|---|---|
| Syntactic construct at a position | partial: AST and HIR have ranges; no lookup by position (`hir::exprsAt` matches exact origins, linearly) | a position index per file (service code; the census's linear scan, §7.5, is enough to start) |
| Declaration an identifier resolves to | supported for value references (`ref.binding`) | — |
| Type of an expression | supported (`hir::typeOf`); presentation leaks internal ids: a function's type prints as `block(e8)/2 -> int` | activation before `hir::types::show`; a signature printer (`hir::signatures::of` exists) |
| Where the declaration is | supported: the binding's `origin` (a parameter's is its name; a function's or a binding's is **the whole statement**) | the AST's `nameSpan` (present for functions, bindings, struct declarations) joined by the origin's node id |
| Ranges referring to the same declaration | supported within one analysis by walking the HIR (no reverse index); across programs not at all | an index per revision; a stable key across revisions (§4.3) |
| Diagnostics that apply | supported for semantic diagnostics (structured); loader and strict-boundary diagnostics are located only in message text; syntax diagnostics have no end position | structured loader diagnostics; end positions; a severity at the service layer |
| Compilerpedia topics | supported: `compilerpedia::topicForDiagnostic CODE MESSAGE`, the CLI's lookup | — |
| Type or declaration positions (`T` in an annotation, a struct field name) | partial: type positions are not HIR expressions; the struct registry keeps AST spans | AST-side lookup (later) |
| References across entry programs, rename | missing | workspace-wide program set; stable keys; out of scope for v1 |

### 4.3 Symbol identity

Within a revision the identity is the `BindingId`. It never confuses two
declarations: spelling is not identity, and hygiene renames collisions
(`hir/hir.tcl:99-100`). BindingIds are not stable across revisions. The
dependency probe shows every `ExprId` of `main.bot` changing when a module it
imports gains one function. Module sections are built before the entry
program, and ids are allocated per build.

The candidate stable key is **{module, AST node id of the declaration}**:
the canonical namespace, or the entry program, plus the binding origin's
`node`. Measured (`queries.tcl`): 10 source bindings give 10 distinct keys.
The same name in two modules (`f` and `util::f`) and in two functions
(`f()/x=` and `h()/x=`) gives distinct keys. After moving every declaration
and inserting a function before them in a dependency, all 10 keys survive
while all 10 BindingIds change.

Limits, stated rather than solved:

* The key is only as stable as AST ids. A statement's id is
  `PARENT/KEY#N` for the N-th sibling with the same key
  (`surface/ast.tcl:254-265`). Named declarations (`f()`, `x=`) are stable.
  Type declarations are keyed by kind (`structdecl`, `structdecl#2`), so
  inserting a struct before another renumbers it.
* "The entry program" is per entry file. Two entry programs in one directory
  are two programs that share modules. A module declaration has the same key
  in both. An entry program's declarations do not.
* With the `std::` milestone the module part becomes the canonical name
  (`std::list` versus an application `list`), which makes the key less
  ambiguous, not more. Nothing else in the key changes.

Rename and cross-program references need this key plus an index over every
program that loads a module. They are later work (§11).

### 4.4 Source coordinates

`audit/compiler-service/probes/coords.tcl` places text before a queried
identifier on the same line and compares the compiler's column with three
conventions:

| Text before the identifier | Compiler column | UTF-8 byte column | UTF-16 column | Scalar column |
|---|---:|---:|---:|---:|
| ASCII | 12 | 12 | 12 | 12 |
| `"éé"` (BMP) | 12 | 14 | 12 | 12 |
| `"😀"` (astral) | 11 | 14 | 12 | 11 |
| `"é"` as `e` + U+0301 | 12 | 13 | 12 | 12 |

The compiler's coordinates are: 1-based line, 1-based column and 0-based
offsets, all in **Unicode scalar values**, over the text **after line-ending
translation**. That is neither LSP's UTF-16 default nor bytes. The two agree
except for astral characters, one column per astral character before the
position. Identifiers are ASCII, so non-ASCII text appears only in strings,
character literals and comments. That is still before many positions on a
line.

The probe also found a correctness hazard in the definition of the text
itself. `core::ReadFile` reads with Tcl's default `auto` translation
(`core/programfile.tcl:16-25`), so a file on disk is analyzed as its text
with every `\r\n` and lone `\r` turned into `\n`. The same text handed over
as a buffer is lexed as it is:

| Same content | From disk | As a buffer |
|---|---|---|
| CRLF line endings | ok; `target` at offset 16 | ok; `target` at offset **17** |
| lone CR line endings | ok | **syntax error** ×3 ("unexpected carriage return") |

So one document could have two analyses, depending on whether the editor had
it open. Rule (§5): the service normalizes every text exactly as
`core::ReadFile` does, once, before anything else sees it. The offsets an
editor needs are then computed against that normalized text. One conversion
boundary, at the transport, maps (line, UTF-16 column) to (line, scalar
column) over the revision's normalized text, never over the current buffer.

## 5. Source-overlay and revision model

### 5.1 Where source enters the compiler

Every acquisition of program text in the front end goes through two
primitives:

* `core::ReadFile` (`core/programfile.tcl:16`): the entry
  (`surface/modules.tcl:1665`; `main.tcl:439`; `core::programFileRequires`,
  `core/programfile.tcl:42`) and every module (`modules.tcl:183`), plus the
  cache's dependency check (`surface/cache.tcl:115`).
* `file exists`/`file isfile`: which candidate module files exist
  (`modules.tcl:250`, `:390`, `:400`, `:406`, `:428`, `:839`;
  `surface/cache.tcl:113`).

`file normalize` and `file dirname` compute paths only. The `std::` branch
keeps exactly these two primitives at the same kind of sites
(`surface/modules.tcl:206`, `:312`, `:402`, `:510`, `:522`, `:530`, `:553`,
`:969`, `:1815` there), so the seam survives that refactor. Its location
moves, and the change should land after it.

### 5.2 The overlay, demonstrated

`audit/compiler-service/probes/overlay.tcl` substitutes both primitives with
a path → text map for one analysis (`lib.tcl`'s `cs::withOverlay`). The
loader is not changed. All 17 checks pass:

* **A workspace that exists only in memory** (a directory never written)
  analyzes exactly like the same files on disk: same status, diagnostics and
  value. Nothing is created on disk. This is the evidence that the two
  primitives are the whole seam.
* An unsaved fix of an entry that has an error on disk is analyzed clean.
* An imported module's unsaved buffer changes its interface. The dependent
  gets the new `TYPE` diagnostic, and the disk analysis is unchanged
  afterwards.
* Versions of one module alternated v1, v2, v1 give v1, v2, v1. The loader's
  parse cache is keyed by text, so it cannot serve a stale AST.
* A module that exists only as a buffer resolves. A module deleted in the
  editor but present on disk is `UNKNOWN-NAMESPACE`. An unsaved application
  file named like a standard namespace is `MODULE-COLLISION`, as on disk.
* A standard-library module's buffer is honored like any other.
* A syntax error inside an imported module's buffer is a loader failure:
  no HIR (§4.1).

### 5.3 Identities

| Identity | What it is | Today |
|---|---|---|
| **Canonical module identity** | The namespace, or "the entry program" | The namespace string; standard versus application decided by resolution (`ResolveModule`). With `std::`, decided by the first segment |
| **Source location** | The path a namespace denotes | A function of (namespace, library directory, target architecture, application root) only: no search (`surface/cache.tcl:37-40`) |
| **Source contents** | The normalized text at that location in one snapshot | Read by `core::ReadFile`; nothing records a version |
| **Workspace revision** | The set of (location → contents or absent) an analysis observed | Exactly the cache entry's `dependencies` (`surface/cache.tcl:120-166`): every candidate path with its text, or its absence |
| **Analysis snapshot** | The HIR (or the syntax/loader outcome) of one entry program at one workspace revision, for one target, warning mode and front end | A HIR value; its identity is the cache key plus the dependency texts |

Path identity and content identity are not interchangeable. The same path
holds different texts across revisions. The same text at two paths is two
modules, or the same module under two application roots. Absence is a fact
of a revision: a file appearing at a candidate path changes resolution
(MODULE-COLLISION). The cache already treats it that way (`Contents` with
`exists 0`).

### 5.4 Recommended rules

1. **One text, one analysis.** A source provider returns normalized text
   (`\r\n` and `\r` → `\n`, UTF-8 decoded) for disk and buffers alike. It
   is the only way source enters the front end.
2. **A revision is a value.** It is the entry path; the provider snapshot of
   every location the analysis read or probed; the target, warning mode,
   scheduler and front-end fingerprint; and the result (HIR or syntax/loader
   outcome, structured diagnostics, ASTs). It never changes. Answers are
   functions of one revision.
3. **Every reader activates.** Any query that may read a registry (type
   printing does) activates the revision's HIR first.
4. **Positions belong to a revision.** A position is interpreted against the
   revision's normalized text. A query for a document version other than the
   revision's is answered as stale (with the revision's version) or
   re-analyzed, never silently mapped.
5. **Buffers are versions, the disk is a fallback.** An open document's
   buffer wins over its file. A closed document is read from disk at
   analysis time. Deletion and creation in the editor are overlay entries
   (absent / present).
6. **Persistent caching is keyed by contents, not by "is it a buffer".** The
   front-end cache already validates by text. An entry built from buffers is
   valid exactly when the same texts are on disk later. Writing entries for
   transient buffer states is wasteful, though, so a service writes the
   persistent cache only for revisions whose texts all came from disk.
7. **The `std::` milestone changes none of these rules.** It changes how a
   namespace maps to a location and makes the module identity canonical. The
   provider sits below that mapping.

## 6. Incrementality alternatives

### 6.1 What the compiler knows about dependencies

`audit/compiler-service/probes/deps.tcl` analyzes a four-file application
(`main` imports `a` and `b`; both import `c`; `main` imports `list`). It then
applies eight edits as buffers in a warm process and reports what was
re-parsed, what the front-end cache did, which files' diagnostics or
per-AST-node types changed, and whether `main.bot`'s HIR ids survived:

| Edit | Re-parsed | Front-end cache | Changed facts | `main` ids kept |
|---|---|---|---|---|
| body of `a::fa`, signature unchanged | a, main | stale | none (value 36 → 37) | 20/20 |
| `c::base`'s parameter type | c, main | stale | a, b, c (`TYPE` in a and b) | 0/20 |
| body of `c::base` (used by a and b) | c, main | stale | none (value → 39) | 20/20 |
| `main` drops `import b` | main | miss | everything (no HIR: `MISSING-IMPORT`) | — |
| `c` gains an unused function | c, main | stale | c only | **0/20** |
| a comment in `lib/list.bot` | list, main | **stale** | none | 20/20 |
| syntax error in `a.bot` | a, main | stale | everything (no HIR) | — |
| a line added at the top of `main` | main | miss | none | 20/20 |

What this establishes:

* **Parsing is already incremental per file in process.** Only the edited
  file and the entry are parsed again. The loader's parse cache does that.
* **Everything after parsing is whole-program.** Any change to any file
  invalidates the front-end cache entry (`stale`), including a comment in a
  standard-library module, because dependencies are compared by text.
* **HIR ids are build-local**, and **AST node ids are the edit-stable
  coordinates**. Hence the stable symbol key of §4.3.

The decisive observation is about interfaces. `deps.tcl`'s first edit happens
to change no type or diagnostic, but that is a property of the edit, not a
rule. `audit/compiler-service/probes/bodyfacts.tcl` changes only a module
function's **body**:

| Module `c` (signature unchanged within a group) | Importer's diagnostics |
|---|---|
| `fn pick() -> int:` body `2`; importer `list::at([10, 20, 30], c::pick())` | none: proven in bounds |
| the same, body `7` | **`KNOWN-ERROR`**: the call "can never complete normally" |
| `fn pick(n: int) -> int errors Boom:` failing when `n > 1`; importer `c::pick(1)` | none: the body proves this call cannot fail |
| the same, failing when `n > 0` | **`KNOWN-ERROR`** |
| `fn pick():` (unannotated) body `2`, passed to `fn use(n: int)` | none |
| the same, body `"s"` | **`TYPE`** |

Facts derived from bodies cross module boundaries: exact values and ranges
of results, statically known completions, and inferred contracts of
unannotated parameters (`hir/hir.tcl:1462-1476`, `hir::moduleSignatures`: "An unannotated export's
contract can therefore change when its implementation does"). The
declared signature is not the interface the analysis depends on.

### 6.2 The three strategies

**A. Whole-program analysis snapshots.** Re-analyze the entry program on
every change, reusing the per-file parse cache in process and the
front-end cache across processes; keep the last revision for queries.

* Reuses: everything — `BuildProgram`, lenient builds, `reported`,
  activation, the parse cache, the front-end cache, interchange.
* Redesign needed: none. It needs a source provider (§5) and the query
  layer.
* Correctness risk: lowest. A revision is exactly what the CLI would
  compute. The isolation probe's activate-first discipline shows no leakage.
* Memory: one HIR per open entry program (0.04-2 MiB of HIR text measured,
  §7.6) plus ASTs.
* Benefit: CLI unchanged; the editor gets correct results at whole-program
  latency (§7).
* Evidence that would retire it: re-analysis latency above an interactive
  budget for programs people actually edit. The measured worst case is
  §7.2's 2048-golden.

**B. Module-granular semantic caching.** Reuse unaffected modules' analysis
inside a build or across builds.

* Reuses: the module boundary in the loader, `declarations`, interchange.
* Redesign needed: the HIR is one table per program. Modules are sections of
  one `hir::buildSyntax` (`surface/modules.tcl:1633-1639`). Ids, types and
  scopes are allocated per build. A module's analysis would have to become a
  value that can be spliced into a later build. The registries would have to
  be partitioned by owner namespace (COMPILER-BOTTLENECKS.md §3.10).
* Correctness risk: high, and demonstrated. Reusing an importer's analysis
  when an imported module's *interface text* is unchanged is unsound
  (§6.1's `KNOWN-ERROR` flip). Sound reuse needs fact-level dependencies,
  which `hir/staticdeps.tcl` models only for static decisions.
* The sound subset is narrower: **analysis of a module that depends on
  nothing that changed**, typically the standard library, which no
  application edit can change. That is COMPILER-BOTTLENECKS.md item 10:
  library modules re-analyzed in every build (about 0.5 s per build for 1,450
  library expressions, corpus-wide 165 s).
* Benefit: bounded by the library's share of a build (§7.3).
* Evidence that would justify it: that share, multiplied by builds per
  compilation, exceeding the interactive budget on real programs.

**C. Incremental semantic query database.** Model facts and their
dependencies as invalidatable queries.

* Reuses: little. Resolution, typing, completions and the range analyses are
  whole-program passes over tables with fixpoints (signatures, demotion
  re-checks). Static decisions and method-call decisions are defined by
  whole-program trial builds (STATIC-COMPILE.md, METHOD-SUGAR.md).
* Redesign needed: essentially every analysis, and the definition of static
  decisions in terms of builds.
* Correctness risk: very high. The language's decision rules are
  whole-program by specification. The one dependency model that exists, for
  static decisions (`hir/staticdeps.tcl`), already needs a mispredicted-build
  detector and a CI comparison against the sequential order to stay exact
  (AGENTS.md, "Static intrinsics"; STATIC-DECISION-ECONOMICS.md).
* Benefit: per-keystroke latency independent of program size, in theory.
* Evidence that would justify it: strategy A and B's measured latency
  failing an editor budget on real programs after B's library reuse, and a
  proof that the decision rules can be localized (COMPILER-BOTTLENECKS.md
  §3.10's "locality theorem"), which does not exist.

### 6.3 Verdict

**Strategy A for version 1.** It is the only strategy that needs no change to
the compiler's semantics. Its measured latency (§7) is 0.2-1.3 s per
re-analysis for the applications in the repository and 7-8 s for the largest
single program. That is acceptable for diagnostics published after a
debounce or on save, with hover and definition served from the last revision
in milliseconds.

Incremental compilation is not required for version 1. If S2's measured
latency on real applications demands more, the first step is B's sound
subset: library-module analysis reuse within a compilation (P5, at most
5-35% of an analysis by §7.3). C waits for evidence that A and that step
both fail, and for a locality theorem that does not exist.

Source snapshots (§5) and incremental compilation are different things. A
snapshot fixes what an analysis read. Incrementality decides what an
analysis may skip. Version 1 needs the first and not the second.

## 7. Performance results

All figures are from `audit/compiler-service/results/bench.md` (the
harness's output, reproduced by §14's commands) unless another file is named.
The machine: 4 × Intel Xeon @ 2.10 GHz, 15 GiB, Linux 6.18 x86-64, Tcl
9.0.1, rustc 1.97.0, `main` at `c7e4d4fd`, `BOTLISH_HIR_CACHE` unset unless
stated, warnings off for the CLI rows, the default (batched) static
scheduler. Medians of 5 runs unless stated. The runs were sequential, with
nothing else running.

Workloads, all from the repository:

| Name | Entry | Files (with library modules) | HIR expressions | Builds |
|---|---|---:|---:|---:|
| arith | `examples/surface/01-arithmetic.bot` | 1 | 11 | 1 |
| csv | `examples/stdlib/csv.bot` | 2 | 322 | 1 |
| 2048 | `examples/games/2048/demo.bot` | 12 | 1,777 | 2 |
| icy | `examples/games/icy-tower/headless.bot` | 5 | 1,558 | 1 |
| 2048-golden | `examples/games/2048/golden.bot` (a test suite) | 5 | 5,374 | 3 |

### 7.1 Fresh processes (what the CLI pays)

| Process | Median ms |
|---|---:|
| `tclsh9.0` with an empty script | 6.8 |
| Load the compiler (what `main.tcl` sources) | 80 |
| `main.tcl -help cli.options` (Compilerpedia, no compiler) | 191 |
| `main.tcl -help "bounds proof"` (a search) | 161 |

| Workload | `-emit-hir-interchange`, no cache | the same, cache hit |
|---|---:|---:|
| arith | 127 | 99 |
| csv | 337 | 92 |
| 2048 | 1,486 | 142 |
| icy | 1,069 | 266 |
| 2048-golden | 5,998 | 198 |

`main.tcl` has no analysis-only mode. `-emit-hir-interchange` is the
nearest: the front end plus encoding and writing the HIR.

### 7.2 Analysis in a warm process

Lenient analysis as a service would run it (`cs::analyze`), the edited
file's cached AST dropped before each edit so its text is new to the loader:

| Workload | First (parse cache empty) | Unchanged, again | Implementation edit | Interface edit | Semantic error | Syntax error |
|---|---:|---:|---:|---:|---:|---:|
| arith | 42 | 4.5 | 5.2 | — | 4.4 | 1.3 |
| csv | 208 | 208 | 165 | 169 | 171 | 31 |
| 2048 | 1,276 | 1,250 | 1,233 | 1,287 | 847 | 99 |
| icy | 1,006 | 785 | 1,006 | 1,014 | 904 | 172 |
| 2048-golden | 6,223 | 6,994 | 7,441 | 7,870 | 4,793 | 644 |

Phases of the first analysis (inclusive; module loading includes parsing
the modules):

| Workload | Parse, all files | of which modules | Module loading | HIR build | Finish (warnings) |
|---|---:|---:|---:|---:|---:|
| csv | 41 | 10 | 16 | 150 | 7.5 |
| 2048 | 319 | 318 | 386 | 847 | 35 |
| icy | 221 | 218 | 285 | 677 | 34 |
| 2048-golden | 898 | 423 | 556 | 5,013 | 113 |

Observations:

* **The HIR build is the cost**: 66-81% of a first analysis, every one of
  them whole-program builds (2048: 2; 2048-golden: 3). Parsing is 14-25%.
  The loader's parse cache removes the modules' share for every later
  analysis in the process. That is clearest in fresh processes
  (`twice.tcl`, in `bench.md`): 2048's second analysis takes 1,101 ms,
  against 1,512 ms with the parse cache emptied again. In the warm-process
  table above the single "first" sample and the spread of the repeats
  (1,017-1,363 ms) blur it.
* **An edit costs a whole analysis**, plus re-parsing the edited file.
  Implementation and interface edits cost the same as each other. Both cost
  an unchanged re-analysis plus the edited module's parse (icy: 785 ms
  unchanged, about 1,010 ms after either edit; 2048-golden: 7.0 s against
  7.4-7.9 s). Nothing in the build distinguishes the kinds of edit.
* A semantic error makes analysis cheaper: 2048 takes 847 ms against
  1,250 ms. That is consistent with the front end skipping decision work
  for a program with diagnostics ("`hir::BuildFull` runs the plan only on a
  program with no diagnostic", AGENTS.md "Traits"). A syntax error ends the
  analysis at the parser or the loader: 1-644 ms, and no HIR.
* **Repeated analyses of 2048-golden slow down**: 6.2 s first, 7.0-7.9 s
  later. The same holds in fresh processes (`twice.tcl`: 5.8 s, then
  6.2 s). The census did not isolate the cause (§13, question 5).

### 7.3 What existing caching saves

| Workload | Front-end cache miss (build and store), ms | Hit (read, check every dependency, decode), ms | Entry, KiB |
|---|---:|---:|---:|
| arith | 7.6 | 0.94 | 44 |
| csv | 209 | 8.0 | 211 |
| 2048 | 1,439 | 73 | 1,662 |
| icy | 913 | 209 | 630 |
| 2048-golden | 7,716 | 181 | 2,093 |

A hit costs 2-23% of a build. For an unchanged program the existing cache
already delivers what a daemon would, and it is shared across processes.
`icy`'s hit is slower per KiB than the others'. Its HIR holds DecimalRounded
constants, whose representations are chosen again at decode
(HIR-INTERCHANGE.md). The census did not investigate it further.

The standard library's share (`results/library-share.md`), i.e. the most
that reusing the library's analysis per build could save (§6, strategy B's
sound subset):

| Workload | Expressions from `lib/` | Builds | Analysis, ms | Library floor per build, ms | Share |
|---|---:|---:|---:|---:|---:|
| csv | 57 (18%) | 1 | 171 | 16 | 10% |
| 2048 | 702 (40%) | 2 | 1,129 | 200 | 35% |
| icy | 101 (6%) | 1 | 776 | 40 | 5% |
| 2048-golden | 1,490 (28%) | 3 | 6,470 | 699 | 32% |

### 7.4 Activation

| Pair | Switch, µs | Already active, µs |
|---|---:|---:|
| arith / csv | 10 | 1 |
| csv / 2048 | 17 | 1 |
| 2048 / icy | 27 | 1 |
| icy / 2048-golden | 11 | 1 |

(Medians of 200.) COMPILATION-ISOLATION.md measured 64 µs between two golden
suites. Activation is negligible next to any query that needs it.

### 7.5 Queries after analysis

The probe library's position query at 200 positions of each entry file,
activation included. Each query scans the HIR's expressions linearly, then
every expression again for references. No index exists.

| Workload | Expressions | Median µs | p90 µs | Max µs |
|---|---:|---:|---:|---:|
| arith | 11 | 27 | 58 | 926 |
| csv | 322 | 664 | 988 | 3,798 |
| 2048 | 1,777 | 1,209 | 1,851 | 15,967 |
| icy | 1,558 | 1,214 | 2,197 | 13,523 |
| 2048-golden | 5,374 | 7,188 | 11,062 | 54,474 |

Unindexed queries are already interactive at the sizes measured. An index,
a sort of each file's origins once per revision, would make them
independent of program size.

Compilerpedia in process: the first help-line lookup 53 ms (a header scan of
the catalogue), later ones 0.01 ms; the first search 182 ms (every topic
parsed), later ones 0.01 ms.

### 7.6 Code generation, memory

| Workload | NIR lowering (Tcl), ms | `native::evalHir` (lower, JIT in `botlish-native`, run), ms |
|---|---:|---:|
| arith | 3.5 | 8.5 |
| csv | 96 | 102 |
| 2048 | 634 | 753 |
| icy | 576 | 692 |
| 2048-golden | 4,205 | 4,331 |

None of this is on a query's path (§10.3 invariant 8).

HIR size: 44 KiB (arith) to 2.0 MiB (2048-golden) of text. The process
holding everything above ended at 499 MiB resident. §3.3 separates what is
retained from what is reused.

### 7.7 Answers

* **Is starting Tcl a meaningful part of CLI latency?** No: 7 ms.
  **Loading the compiler is**: 80 ms. That is 30-87% of a CLI run that hits
  the cache, and 1-63% of one that does not.
* **How much does existing caching already save?** A hit replaces a build of
  up to 7.7 s with 1-209 ms. For unchanged programs it is the persistence a
  daemon would offer, already shared across processes.
* **Is repeatedly rebuilding HIR acceptable for interactive diagnostics?**
  For diagnostics after a debounced edit or a save, yes for the
  applications measured: 0.2-1.3 s. For a large test-suite-sized program,
  7-8 s is slow but tolerable for diagnostics on save. Per keystroke, no.
  Hover and definition need no rebuild: they read the last revision in 0.03-7
  ms.
* **Does HIR activation present a meaningful cost?** No: 10-27 µs.
* **What is the likely minimum useful persistence boundary?** The process
  that owns the editor session, i.e. the stdio LSP server itself. It keeps
  the compiler loaded (80 ms), the bytecode compiled (§14's measurement of
  recompilation: 30-50 ms on a one-line program, 160-260 ms on 2048), the
  parse cache warm (318 ms of
  2048's 1,276), and the last revision for queries. A separate daemon would
  add nothing the LSP process does not already have. For the CLI, the
  existing on-disk front-end cache is the boundary.
* **Which measured bottleneck should be addressed first?** The whole-program
  HIR build, multiplied by decision builds (2-3 per compilation in these
  workloads). Library reuse can remove up to a third (P5). After that come
  COMPILER-BOTTLENECKS.md's ranked items. **Not** process start-up, parsing,
  activation or queries.

## 8. FFI and JSON feasibility

### 8.1 What exists

* **Botlish → C**: implemented. `extern c fn` and `extern c library`, native
  only (C-FFI.md).
* **C → Botlish**: `exported c fn` is documented intent
  (C-ABI-TYPES.md:42, :686-693). The parser has no such form. Native
  lowering roots compilation at the program alone, and the only artifact
  is an executable (`native/src/codegen/aot.rs:253` `emit_executable`).
  Runtime tables exist only in the generated startup crate.
* **Tcl → native Botlish**: through a subprocess per run only
  (`native/native.tcl:29-33`, `:256` `RunDriver`).
* **Tcl → Botlish in process**: works today on the Tcl backends. A program
  whose value is a function hands Tcl a block value, and
  `core::callable::invoke` (`core/callable.tcl:9`) calls it with any
  arguments. `probes/json/inproc.tcl` does this with the JSON tokenizer:
  93 tokens back as a Botlish list, and a declared error back as a
  `propagate-error` completion carrying `json_tokens::Malformed {at: 6}`.
* **A library-mode stand-in**: `audit/react-native/tools/libmode.tcl`
  (REACT-NATIVE-TARGET-CENSUS.md "Library mode"). It captures an
  executable's startup crate and object and wraps chosen top-level functions
  as C functions with statuses, a thread-local Vm and a borrowed `str`
  result.

### 8.2 The exported-function probe: possible today, with one silent defect

`probes/export/` builds that stand-in's static library from
`probes/export/exports.bot`, links it with a ~100-line C shim (`probe.c`)
into a Tcl 9 extension, and `load`s it into `tclsh9.0`
(`results/export-probe.txt`):

| Check | Result |
|---|---|
| UTF-8 bytes in (`Tcl_GetBytesFromObj` → `ptr, len`), Int out | `token_count` returns the expected counts (`[1, 2]` → 5, `[1, 2, 3, 4, 5, 6]` → 13, `[true, false, null]` → 7, a malformed input → its offset) |
| str out | `shout(café)` → `café!`; the shim copies at once (the stand-in lends the bytes "until this thread's next call") |
| A declared error | `checked(-5)` → a Tcl error, errorcode `{BOTLISH Rejected}`, message `<error Rejected {code: -5}>` (the payload as text) |
| Invalid UTF-8 in | refused, status 3 |
| Repeated calls | 20,000 × `token_count` on a 193-byte message: 36 µs per call, RSS 14 → 19 MiB |
| Collection with Tcl's frames below | 200 × `churn(10000)`: RSS flat |
| A result kept across collecting calls | intact (it was copied) |
| All of the above under `BOTLISH_NATIVE_GC_STRESS=1` | identical results; 111 µs per call |

**The silent defect.** The stand-in exports the native instance specialized
for the program's own calls. In the probe's first version the top level
called `token_count("[1, 2]")` and `checked(1)`. The exported `token_count`
then returned wrong counts for every input longer than six characters
(`[1, 2, 3]` → 6, `"abcdefghij"` → "malformed at 8"). `checked(-5)` returned
`-10` instead of failing: the `n < 0` branch had been proven dead for the
only call site. Making every top-level argument depend on `argv()` fixed
both. The committed probe does that and records the failure mode in its
comment. A Botlish function compiled for its known call sites is not a
function callable with arbitrary arguments of its declared types.

**Answer to "is a minimal exported-function probe possible?"** Yes, through
the audit stand-in, for int, str and bool parameters, on the calling thread,
with the defect above, and with nothing to bound or survive stack depth. The
exact blocking compiler capability is **export roots in native lowering**:
compiling a function as externally callable under only its declared contract
(no call-site facts, no tiny-leaf inlining away, a symbol of its own). The
rest of library mode follows from it, as REACT-NATIVE-TARGET-CENSUS.md
:487-510 lists.

### 8.3 JSON in Botlish

**Not the binary DSL.** Layouts are fixed-size: "There is no prefix parse and
no cursor" (BINARY-LAYOUT.md:197-214). Streaming "is a separate abstraction
that will sit beside layouts ... layouts do not grow into it" (:283-290).
JSON is delimiter-driven, variable-length and nested. Tokenizing it needs a
cursor over text, which the layout model excludes by design.

**Ordinary Botlish can tokenize it today.** `probes/json/json_tokens.bot`
(about 190 lines) covers RFC 8259's lexical grammar with tokens as
`{kind, start, end}` offsets into the input, so no token text is copied.
Results (`results/json-probe.txt`, cranelift):

* A 530-character `didChange`-like message gives 93 tokens.
* Each of nine malformed inputs fails `Malformed` at the right offset:
  unterminated string, raw newline in a string, bad escape, short `\u`,
  lone minus, `1.`, `1e+`, `tru`, a stray `@`.
* A token bound fails `TooManyTokens`.
* `01` lexes as two numbers. Rejecting adjacent values is the parser's job:
  **tokenization is not parsing**, and nothing here parses.

Two gaps are precise:

* **`\uXXXX`, `\b` and `\f` cannot be decoded into a `str`.**
  `char::scalar_value` is the only character primitive
  (`core/unicodechar.tcl:29`); there is no Int → UnicodeChar. The tokenizer
  computes the scalar (`NoScalarConstructor {scalar: 233}` for `\u00e9`),
  and nothing can produce the character. U+0008 and U+000C cannot even be
  written: the lexer's escapes are `\\ \" \n \r \t` (`surface/lexer.tcl:16-17`).
  Milestone P3 (`char::from_scalar`) closes it, with surrogate pairs on top.
* **Bytes cannot be read**, so input must arrive as a `str`. `abi::bytes`
  has no byte access and no UTF-8 decode (`lib/abi/bytes.bot:108-170`).
  Over the stand-in's ABI that is fine: the C side passes UTF-8 and the
  runtime validates it (status 3).

Throughput (`results/json-throughput.txt`; per 530-character message,
compilation excluded, input varied per iteration so nothing folds it):

| Backend | Per message |
|---|---:|
| cranelift (native) | 9.7 µs |
| compile (Tcl) | 17.5 ms |
| interp | 627 ms |

Native Botlish is fast enough for JSON-RPC: about 50 MB/s on this machine,
including the copy that varies the input.
The in-process Tcl backends are three to five orders of magnitude slower. A
`didOpen` carrying a 50 KiB document would take about 1.7 s on the compile
backend. **So a Botlish-implemented protocol layer needs native code in the
Tcl process, i.e. library mode, before it is usable.** The in-process
Tcl-backend path of §8.1 is a correctness harness, not a transport.

### 8.4 Copies at the boundary

| Step | Copy? | Why |
|---|---|---|
| Tcl string → UTF-8 bytes (`encoding convertto`) | yes, unless the text is already a byte array | Tcl 9's internal string form is not standard UTF-8 |
| bytes → Botlish `str` (`vm.new_str`) | yes | the Botlish heap owns its strings; borrowing caller memory into a str is not a facility Botlish has, by design (C-POINTER-BORROWING.md: exposure only for one call, never a pointer value) |
| tokens | none | offsets into the input |
| decoded string values | materialization is semantically necessary (escapes) | unavoidable |
| result → Tcl | yes, now | the stand-in lends result storage until the next call; a Tcl object must outlive it |

Where copies can be avoided: tokens as offsets (done), and a structured
result returned as one packed buffer (kinds and offsets) instead of a Botlish
list materialized as Tcl objects one by one. That needs a byte-buffer
result, which the ABI below provides.

### 8.5 Where Tcl ends and Botlish begins

For the first vertical slice, **Tcl owns everything protocol-related**:
framing, JSON, JSON-RPC dispatch, URI ↔ path, UTF-16 ↔ scalar columns. The
service it calls is Tcl too. The evidence: native Botlish needs library mode
(§8.2), and the Tcl backends are too slow for transport (§8.3). Pinned Tcl
has no `json` package, so a small Tcl JSON reader and writer would be
needed. That is ordinary Tcl string work on messages of a few KiB, at native
string speed. It sits behind one Tcl interface, so a Botlish library can
replace it later without touching the service.

Botlish takes over the protocol layer when P3 and P4 exist. The boundary
then sits at "bytes in, bytes or a packed structure out": Tcl hands a whole
message's UTF-8 to an exported function and gets back either a re-encoded
message or a packed token/value table. The compiler service stays Tcl. It
calls the compiler, which is Tcl.

### 8.6 What `exported c fn` must provide for the JSON/JSON-RPC bridge

From the probe and REACT-NATIVE-TARGET-CENSUS.md's capability rows, the
minimum, in the order the bridge needs it:

1. **Export roots.** Each exported function is compiled under its declared
   contract only, as a separate root: no call-site facts, never inlined
   away, one symbol per export (§8.2's defect).
2. **A C-ABI trampoline per export** over the generic entry. It takes C
   scalars, `(const uint8_t *ptr, size_t len)` byte or UTF-8 inputs, and an
   out-parameter result, and returns an `int32_t` status.
3. **Byte-buffer results with explicit ownership.** Either the callee
   allocates a buffer the caller frees with an exported release function,
   or the caller passes a buffer and its capacity (with a "too small, need
   N" status). Never a pointer into the Botlish heap that lives "until the
   next call". The stand-in's borrowed `BotlishStr` is the case to remove.
4. **Errors as data.** A status plus a retrievable error identity (the
   declared error's canonical name) and its payload as structured bytes,
   not only as text. The stand-in already returns the identity and message.
5. **An explicit runtime handle.** `create` and `destroy` of a Vm, per
   library and per thread, with every call naming it. No thread-local
   created on first use, no reliance on process exit for cleanup, no
   `_exit` (`native/src/runtime/platform/guard.rs:38`, `:157`), and the
   GC frame walk stopping at the export's frame
   (`native/src/runtime/framewalk.rs:195-204` climbs to the outermost
   caller today).
6. **Stack policy.** The runtime's own thread with a configured stack, or a
   documented maximum depth on the caller's. The probe ran on Tcl's main
   thread, whose stack is the process's (8 MiB by default on Linux), with no
   guard. Deep recursion there would end the editor's server without a
   diagnostic. REACT-NATIVE-TARGET-CENSUS.md:83-87 measured exactly that on
   512 KiB-1 MiB host stacks.
7. **Several libraries per process**: per-compilation symbol names and a
   per-program context area. REACT-NATIVE-TARGET-CENSUS.md:706-720 shows two
   libraries linking silently and computing a wrong answer.
8. **A shared-library or Tcl-loadable artifact.** The probe linked the
   static library into a `.so` by hand, which worked on Linux x86-64 (the
   stand-in compiles PIC). A supported mode should produce it.

The JSON library itself additionally needs P3. The JSON-RPC layer above it
needs nothing new from the language.

## 9. Platform requirements

### 9.1 What each deployment needs

| Need | Stdio LSP (one process per editor session) | In-process service client (CLI, Compilerpedia, tests) | Persistent local daemon | Multi-client daemon | External file change detection |
|---|---|---|---|---|---|
| Transport | the process's stdin/stdout, Tcl channels in binary mode, `Content-Length` framing | Tcl procedure calls | IPC: TCP on localhost, since Tcl 9.0's `socket` is TCP only (no Unix-domain sockets or named pipes in core) | the same, plus authentication and a session per client | — |
| Event loop | Tcl's (`chan event` on stdin, `after` for debouncing) | none | Tcl's | Tcl's, plus concurrency | — |
| Concurrency | none required; analyses of 0.2-8 s block the loop (§7), so cancellation is "supersede the queued request", not "interrupt the running build" | none | worker processes: the pinned Tcl has no `Thread` package (census check: `package require Thread` fails) | worker processes, request isolation | — |
| Process lifetime | the editor's | the caller's | its own: start, discovery, versioning against the front end, idle exit, crash recovery | the same | — |
| Botlish stdlib sockets | not used | not used | not used if the daemon is Tcl | not used if Tcl | — |
| File notifications | not needed: open documents arrive as `didOpen`/`didChange`; closed files are read at analysis time, and the text-equality check of §5.4 rule 6 decides validity | not needed | needed only to re-analyze proactively | the same | the LSP client's `workspace/didChangeWatchedFiles` delivers them to a stdio server |

The first vertical slice needs the first two columns only. Neither needs a
standard-library facility Botlish lacks. Sockets, file notifications and
process facilities are needed by the daemon columns, and §7 gives no
evidence for a daemon.

### 9.2 Watching files without trusting the watcher

A watcher is an optimization. A revision is valid exactly when every
location it read still has the text it read and every location it found
empty is still empty. That is the front-end cache's existing check
(`surface/cache.tcl:191-197`), and it costs the dependency re-reads measured
in §7.3. The correctness-preserving rule for any later watcher: a
notification (native, client-sent or polled) only schedules a re-validation;
it never patches a revision. Polling is the fallback with no platform code,
and its cost is that same check.

### 9.3 Linux, macOS, Windows

The service, the CLI and a stdio LSP are Tcl code over Tcl channels. They
need nothing platform-specific beyond what `main.tcl` already runs on: Linux,
macOS, and Windows, where `tclsh9.0 main.tcl` and `tests/local.tcl` run
(WINDOWS-X86-64-MILESTONE-1.md:750, :763). Two points need care:

* **Windows line endings.** Stdin must be configured
  `-translation binary` for framing. Document text must go through the same
  normalization as disk text (§5.4 rule 1). Windows editors routinely send
  CRLF, which is §4.4's hazard.
* **Native code generation is not on the query path.** Hover, definition and
  diagnostics never start `botlish-native` (§10.3). Its per-platform
  linking (rustc, the stub linker, Apple's ld, link.exe: AGENTS.md "The
  single-file compiler and the stub linker") stays a CLI concern.

## 10. Proposed service contract

### 10.1 Layers

| Layer | Owns | Never owns |
|---|---|---|
| **Compiler core** (`surface/`, `hir/`, `core/`, `compiler/`, `native/`) | parsing, resolution, types, HIR, diagnostics, code generation | positions in any convention but its own, documents, versions, JSON, URIs |
| **Compiler service** (new, Tcl, in process) | source providers and overlays, workspace revisions, the analysis call, structured diagnostics, position index, semantic queries, Compilerpedia associations, revision release | protocol framing, UTF-16, request ids, process lifetime |
| **Transport/server** (new, Tcl) | stdio framing, JSON, request dispatch, document versions, URI ↔ path, UTF-16 ↔ scalar columns, debouncing, cancellation by supersession | semantics: it calls the service and presents what the service returns |

### 10.2 Operations

Candidate capabilities, not API names:

| Capability | Contract |
|---|---|
| open a workspace | `{root target warnings provider}`; the provider defaults to the disk |
| set or clear a document | an overlay entry: path → normalized text and an opaque version, or "deleted" |
| analyze | entry path → **revision**: the entry, the provider snapshot of every location read or probed, the front-end fingerprint, target, warning mode, scheduler, and the outcome (`ok`/`semantic` with a HIR, `syntax` with ASTs, `loader` with no HIR), structured diagnostics, ASTs by file |
| diagnostics | revision → `{severity code message file line column endLine endColumn related}` for every reported error and warning: exactly the CLI's set (`hir::recovery::reported`, then the warnings) |
| at | revision, path, line, column (compiler coordinates) → the innermost construct, its type, the binding it resolves to, the binding's definition (name range), references within the revision, the diagnostics there and their Compilerpedia topics |
| explain | a diagnostic → its Compilerpedia topic (`compilerpedia::topicForDiagnostic`, unchanged) |
| compile or run | an `ok` revision's HIR → the existing backends, unchanged |
| release | drop a revision; nothing else is held |

### 10.3 Invariants

1. **The compiler is the authority.** The service adds no diagnostic, never
   suppresses one, and computes types, resolution and topics only through
   the compiler's own functions. LSP diagnostics are the CLI's diagnostics
   re-encoded.
2. **One text, one analysis** (§5.4 rule 1).
3. **Revisions are immutable values** and every answer is a function of
   exactly one revision (§5.4 rule 2). Diagnostics and queries of a revision
   come from the same HIR.
4. **Activate before reading** (§3.2). Every query that can reach a registry
   activates the revision first. Activation costs microseconds (§7.4).
5. **Determinism.** A revision's result is a function of the cache key plus
   the provider snapshot. The CLI, the service and the persistent cache
   agree by construction, and that is testable by building one program
   through all three.
6. **Positions are the compiler's** inside the service (§4.4). Conversion is
   the transport's, against the revision's text.
7. **Stale is explicit.** A query names the document version it is about. A
   revision of another version answers as stale or not at all.
8. **No code generation on the query path**, and no daemon on the
   correctness path: the CLI analyzes in process as it does today.
9. **Resource ownership.** A revision owns its HIR and ASTs; releasing it
   frees them. Process-wide caches that grow with use — the parse cache, the
   Tcl compiler's code cache, Tcl-backend stores — are either bounded (the
   parse cache's 64 entries) or never used by the analysis path (the code
   cache and stores grow only when programs run). §3.3 measures that.

### 10.4 In process first

The service is a Tcl API in the compiler's process. The CLI calls it
directly. A stdio LSP is one Tcl process that loads the compiler and calls
it. Compilerpedia stays a separate, compiler-free load (`main.tcl:339-342`):
offline by construction. A daemon could be put behind the same API later.
Nothing in the contract assumes or prevents one, and §7.7 says what it would
save.

## 11. Recommended milestone sequence

Each milestone states its acceptance criterion. The first group has no
dependency on the architecture choice and can proceed in parallel.

### Independent prerequisites

**P1. Structured front-end diagnostics** (small; core). Loader errors carry
their span as data: `surface::modules::Error` puts the span in the error's
options, and deferred reference errors keep it. Syntax diagnostics carry
`endLine`/`endColumn`. The strict boundaries keep a diagnostic's origin
beside the text they build. Messages and CLI output stay byte-identical.
*Accept:* every diagnostic of the diagnostic-recovery corpus
(`audit/diagnostic-recovery/`) and of `tests/static-compile.test`'s census
has a structured location equal to the one in its text;
`tests/diagnostic-recovery.test` and `tests/main-cli.test` unchanged.

**P2. Source provider seam** (small; core; **after the `std::` milestone
merges**). The loader's two primitives (§5.1) go through one provider with a
disk default, and the newline normalization of `core::ReadFile` becomes the
provider's, applied to every text. *Accept:* `overlay.tcl` passes with a
provider instead of wrapping `file`; every golden suite's HIR is identical
(`audit/hir-interchange/tools/roundtrip.tcl`); the cache's dependencies
record the provider's texts.

**P3. `char::from_scalar`** (small; language library). An Int → UnicodeChar
conversion that fails on a non-scalar. It unblocks decoding `\uXXXX`, `\b`
and `\f` in Botlish (§8.3). *Accept:* the JSON probe's decode cases succeed
on every backend.

**P4. Library mode and `exported c fn`** (large; the React Native census's
slices 2-3). Independent of the service. Only the Botlish-implemented
transport waits for it (§8).

**P5. Library-module analysis reuse within a compilation** (medium;
performance; COMPILER-BOTTLENECKS.md §3.10). Worth doing if §7.3's library
share justifies it. Independent of the service.

### Dependent on the chosen architecture (strategy A)

**S1. Compiler service v0, in process** (medium; new `service` layer;
depends on P1, P2). Workspace, overlay, revision, analyze, diagnostics, a
position index, the `at` query with hover text (a callable printed as its
signature, never `block(eN)`), definition by `nameSpan`, in-revision
references, Compilerpedia topics, release. Plus `main.tcl -check FILE`:
analysis and diagnostics without running, through the service.
*Accept:* `isolation.tcl` (activate-first) 0 differences, with the query
probes rebuilt on the service API; `queries.tcl`'s matrix unchanged or
better; `-check` diagnostics byte-identical to today's run diagnostics on the
diagnostic-recovery corpus; a position query ≤ 5 ms at 2048-golden size;
`tests/main-cli.test` updated for the new option (`cliOptions`, the
`cli.options` topic).

**S2. Stdio LSP vertical slice** (medium; Tcl; depends on S1). `initialize`,
`didOpen`/`didChange`/`didSave`/`didClose`, debounced
`publishDiagnostics`, `hover`, `definition`. UTF-16 conversion at the
transport. The last successful revision serves queries during syntax errors,
marked stale. JSON in Tcl (§8.5). *Accept:* a scripted session over pipes
(open, edit with a syntax error, fix, hover, definition, non-ASCII before the
cursor, CRLF buffer) whose responses are checked against the CLI's
diagnostics; latency per request recorded on the §7 workloads.

**S3. Faster re-analysis, only if S2's recorded latency demands it.** P5
first, then the next item of COMPILER-BOTTLENECKS.md. Not a query database.

**Later:** references across programs and rename (the stable key of §4.3
plus a workspace program set); syntax-error-tolerant analysis of modules
(§13); a Botlish JSON/JSON-RPC library behind `exported c fn` once P3 and P4
exist.

### What the next milestone leaves alone

S1 does not touch the loader's resolution rules, the HIR, the registries,
activation, the cache format, the backends or Compilerpedia's catalogue. It
adds no daemon, socket, watcher, JSON, UTF-16 or protocol code, and no
incremental mechanism.

## 12. Rejected approaches

| Approach | Rejected because |
|---|---|
| A persistent daemon now | §7.7: a fresh CLI process spends ~5 ms starting Tcl and ~65-90 ms loading the compiler. With the front-end cache warm, a whole CLI run is 90-285 ms for the measured workloads. A daemon could remove the load and the parse cache's share. Every cost is not removable: the whole-program build dominates. It adds lifecycle, staleness, IPC and security work, plus Windows IPC that pinned Tcl does not have |
| Module-granular reuse keyed by interface text | Unsound: a body edit with an unchanged signature changes importers' diagnostics (`bodyfacts.tcl`, §6.1) |
| An incremental query database now | The decision rules are whole-program by specification (static decisions, method trials, demotion re-checks); no locality theorem exists (COMPILER-BOTTLENECKS.md §3.10); strategy A has not failed a measured budget |
| A compilation context passed through every lookup | Already rejected by COMPILATION-ISOLATION.md (259 procedures, ~1,400 call sites); activation costs microseconds (§7.4) |
| A child interpreter per analysis | COMPILATION-ISOLATION.md measured 130-180 ms plus re-parsing the library per compilation, against microseconds for activation; HIRs would cross as text |
| Extending the binary layout DSL to tokenize JSON | Layouts are fixed-size by design: "no prefix parse and no cursor" (BINARY-LAYOUT.md:197-214), "Not a streaming or transducer system ... layouts do not grow into it" (:283-290). JSON needs delimiter-driven, variable-length, nested scanning (§8.3) |
| Wrapping or renaming compiler commands at run time | Measured: renaming a compiled-inline command costs the next build its bytecode: 30-50 ms on a one-line program and 160-260 ms on the 2048 demo (`bench/wrapcost.tcl`, two runs). The census's own first benchmark run was distorted by exactly this. A service must install hooks once or, better, have a real seam (P2) |
| Implementing sockets or file notifications for version 1 | Not needed by a stdio LSP (§9.1); the client delivers changes |
| A second diagnostic model for the editor | The service re-encodes the compiler's diagnostics (§10.3 invariant 1); P1 makes them structured at the source |

## 13. Open questions

Only questions the census could not settle, each with the evidence that would.

1. **Is whole-program re-analysis fast enough on the programs people will
   actually edit?** The largest multi-module application in the repository
   is 12 files. The large single programs are golden test suites (5-8 s).
   *Evidence:* S2's recorded per-request latency on a real application of
   several thousand lines across many modules, under an editor's change
   rate.
2. **Can a module with a syntax error still contribute its declarations?**
   Today it blanks the program (§4.1). Options are the module's last good
   AST, or lowering the recovered AST's well-formed statements.
   *Evidence:* a prototype measured on the diagnostic-recovery corpus for
   whether it ever produces a diagnostic a clean build would not (a fidelity
   regression).
3. **How should a long analysis coexist with an event loop without
   threads?** *Evidence:* an S2 experiment comparing (a) blocking with
   supersession, (b) a worker `tclsh` per analysis returning diagnostics
   (no HIR crosses), on queue latency for hover during a 1-7 s analysis.
4. **Does activation cost grow with registry size?** Measured 6-15 µs
   between the census's workloads and 64 µs in COMPILATION-ISOLATION.md.
   *Evidence:* the activation table of `service-bench.tcl` over the golden
   corpus.
5. **Why do repeated analyses of a large program slow down?** 2048-golden
   took 5.8-6.2 s the first time and 7.0-7.9 s later, in one process and
   in fresh ones (§7.2). *Evidence:* the phase profiler
   (`bench/phase-profile.tcl`) over five consecutive analyses, comparing
   per-phase self time and resident set between the first and the fifth.
6. **What exactly may a Tcl caller hold from a Botlish result?** The
   library-mode stand-in lends a str result "until this thread's next call".
   *Evidence:* the exported-function probe of §8.2, run under
   `BOTLISH_NATIVE_GC_STRESS=1`, with a result retained across calls.

## 14. Reproducing the evidence

Set-up, as AGENTS.md prescribes: Tcl 9.0.1 from the Ubuntu `.deb`s,
`LANG=C.utf8 LC_ALL=C.utf8`, and `cargo build --release --manifest-path
native/Cargo.toml` (rustc 1.95+). Every script cleans up after itself and
writes nothing into the repository except where `-out` says.

```sh
export LANG=C.utf8 LC_ALL=C.utf8
P=audit/compiler-service/probes B=audit/compiler-service/bench

# §3.2 isolation (exit 0 when activate-first agrees with every baseline)
tclsh9.0 $P/isolation.tcl
tclsh9.0 $P/isolation.tcl -control noactivate      # the positive control: differences expected

# §4 queries and symbol keys; §4.4 coordinates
tclsh9.0 $P/queries.tcl
tclsh9.0 $P/coords.tcl

# §5 overlays (exit 0 when all 17 checks pass)
tclsh9.0 $P/overlay.tcl

# §6 edit consequences and cross-module body facts
tclsh9.0 $P/deps.tcl
tclsh9.0 $P/bodyfacts.tcl

# §3.3 long-running memory
tclsh9.0 $P/longrun.tcl -rounds 120
tclsh9.0 $P/longrun.tcl -rounds 80 -run 1

# §7 benchmarks (the full harness takes about 25 minutes on 4 cores)
tclsh9.0 $B/service-bench.tcl -repeat 5 -native 1 -out /tmp/bench.md
tclsh9.0 $B/library-share.tcl -repeat 3
tclsh9.0 $B/wrapcost.tcl

# §8.3 JSON
tclsh9.0 main.tcl -warnings off -backend cranelift $P/json/json_probe.bot
tclsh9.0 $P/json/throughput.tcl
tclsh9.0 $P/json/inproc.tcl

# §8.2 the exported-function probe: needs tcl.h and libtclstub9.0.a, e.g.
# from tcl9.0-dev_9.0.1+dfsg-1_amd64.deb extracted with `dpkg -x DEB DIR`
sh $P/export/run.sh DIR/usr/include/tcl9.0 DIR/usr/lib/x86_64-linux-gnu/libtclstub9.0.a
```

The outputs the report cites are in `audit/compiler-service/results/`:
`bench.md`, `library-share.md`, `isolation.txt`, `isolation-control.txt`,
`queries.txt`, `coords.txt`, `overlay.txt`, `deps.txt`, `bodyfacts.txt`,
`longrun.txt`, `longrun-run.txt`, `wrapcost.txt`, `json-probe.txt`,
`json-throughput.txt`, `json-inproc.txt`, `export-probe.txt`.

### A measurement artifact the census found in itself

The first version of `probes/lib.tcl` installed its overlay by renaming
`file` and `core::ReadFile` around every analysis. Renaming a command Tcl
compiles inline invalidates every compiled procedure. Every in-process
analysis after it recompiled the compiler's procedures it ran, which added
30-50 ms to a one-line program and 160-260 ms to the 2048 demo
(`bench/wrapcost.tcl`; two runs measured 47 and 258 ms, then 32 and 163 ms;
`results/wrapcost.txt` holds the second). The first benchmark run was discarded. The library
now installs its hooks once and passes through while no overlay is set.
Every in-process figure in §7 is from the corrected run. The fresh-process
figures did not depend on the library and were unchanged between the runs.
The lesson for the service: its seam must be a real one (P2), not run-time
wrapping.
