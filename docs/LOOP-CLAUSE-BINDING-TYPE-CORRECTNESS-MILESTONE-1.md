# Loop clause binding types: the record the checker already knows (milestone 1)

M1 of [TEXT-AND-COLLECTION-PRECISION-CENSUS.md](TEXT-AND-COLLECTION-PRECISION-CENSUS.md):
HIR's binding table now records every loop clause binding -- a listloop's
element, a countloop's counter, each lockstep clause's element or counter --
with the type the checker gives its references, as it already recorded a
local's, a fold intermediate's and a handler payload's. Nothing else about
iteration changes: the checker, the element-type rule, the loop's result
type, lowering and every backend's output are what they were.

Measured on `main` at `88ca1e4` (the census was taken at `f2787af`; every
observation it states was reproduced at `88ca1e4` first, section B).

## A. Result

| observable | before | after |
|---|---|---|
| hover at `b` in `loop b in bs` (`bs: List[int[std::byte::Byte]]`) | `b: any` | `b: int[std::byte::Byte]` |
| hover at its reference `need_byte(b)` | `b: int[std::byte::Byte]` | unchanged |
| `hir::bindingType` of a listloop element | `any` | its element type |
| ... of a countloop counter | `any` | `int` |
| ... of each lockstep clause | `any` | that clause's element type, or `int` |
| a generic function's element (`fn first(xs): loop x in xs`) | `any` | `any` (its generic walk's), each semantic instance's own type in that instance's snapshot |
| loop clause records `any` over the corpus (138 programs, 4,473 loop clause bindings with their standard-library modules) | 4,408 | 710, each one a genuinely unknown element (section G) |
| references more precise than their record | 3,571 bindings | 5, each a guard's narrowing on the reference's path |
| references contradicting their record | 0 | 0 |

The declaration, its references, the HIR record, the compiler service, the
language server (both schedulers), HIR interchange, HIR text and the
front-end cache now agree. A generic function keeps one stable record, its
generic walk's, which no semantic instance overwrites.

## B. Reproducer

The census's program (probe `c1`; `tests/loop-clause-binding-types.test`'s
`lcb-reproducer`):

```botlish
import std::str
import std::list
import std::byte

fn need_byte(b: std::byte::Byte) -> int:
    b

fn example(s: str):
    bs = s.encode_utf8()
    loop b in bs:
        need_byte(b)

example("é")
```

Through the compiler service (`service::at`, what `main.tcl -lsp` shows) and
`hir::bindingType`, at `88ca1e4` and after:

```
before                                         after
10:10 declaration: hover {b: any}              10:10 declaration: hover {b: int[std::byte::Byte]}
11:19 ref: hover {b: int[std::byte::Byte]}     11:19 ref: hover {b: int[std::byte::Byte]}
hir::bindingType b58 = any                     hir::bindingType b58 = int[std::byte::Byte]
```

Probe `c6` (a fold over a counter, a lockstep fold, a destructuring), its
`binding:` expectations before and after:

| binding | before | after |
|---|---|---|
| `bs` (local) | `List[int[std::byte::Byte]]` | unchanged |
| `i` (countloop counter) | `any` | `int` |
| `acc` (fold intermediates) | `int` | unchanged |
| `b` (lockstep element) | `any` | `int[std::byte::Byte]` |
| `j` (lockstep counter) | `any` | `int` |
| `first`, `rest` (destructured fields) | `int[std::byte::Byte]`, `List[int[std::byte::Byte]]` | unchanged |

The other sixteen probes are unchanged, the `encode_utf8()` probes `c3`-`c5`
among them: whether `std::byte` is loaded still decides that element type
(M3).

## C. Root cause

`hir::types::Expr`'s typing walk (hir/types.tcl) gives every binding its
type in two places: the walk's flow facts (`ctx facts`, which every `ref`
reads through `hir::types::BindingType`) and HIR's binding table
(`dict set hir bindings $b type ...`, which `hir::bindingType` reads). A
`bind` writes both (`Bind`), a fold's intermediate both (`FoldBody`: "The
intermediate's one type, for the analyses that read a binding's
(hir::bindingType)"), a handled call's payload both (`Handle`). The three
loop cases wrote only the fact:

* `listloop`: `dict set ctx facts [dict get $node elementBinding] $elemType`
* `countloop`: `dict set ctx facts [dict get $node countBinding] int`
* `lockloop`: `dict set ctx facts $binding $type` for each domain

so the checker typed every reference precisely and the table held nothing
(`hir::bindingType`: "any if not inferred"). The service's `BindingType`
takes its parameter branch only for a function's own parameters -- a loop
clause binding is a `param` of the loop's body scope, whose owner is the
loop node -- and fell through to `hir::bindingType`. The census's list of
loop kinds is complete: HIR has four loop node kinds (hir/hir.tcl), and a
plain `loop` declares no clause binding. A loop over a collection struct
(MutableMap, MutableSet, ImmutableMap) is elaborated after the checks into a
countloop whose source variable is a local `bind` (`kv = iteration_at(...)`),
which was recorded before and still is; its counter, a hidden
`kv#positionN`, is now recorded `int`.

## D. Binding invariant

A loop clause binding's recorded type is the fact the walk gives it at the
loop's entry, which every reference starts from (hir/types.tcl's
`RecordClause`, hir/hir.tcl's binding documentation):

| clause | recorded type |
|---|---|
| listloop element | the loop's element rule, `hir::iteration::ElementOf` of the iterable's type: a List's element, a MutableVector's or MutableArray's, a collection struct's protocol result; refinements and nominal identity kept (`List[int]{length: 2}`, `int[Small]`, `Holder`, an enum); `any` where the rule knows none; `never` for a poisoned iterable (the binding is poison, as a poisoned bind's) and for a `List[never]`'s element (the body never runs) |
| countloop counter | `int` (exactly what the checker assigns; no index refinement is invented) |
| lockstep clause | that clause's own: its element by the listloop rule, or `int` for a counter; never another clause's, never a join of the clauses |

A reference may be narrower than the record only where a guard narrowed the
binding on its path -- the corpus has five: an argument narrowed by a
native's parameter type (`std::str::concat(x, tag)` makes `x` a `str`
after it), an operator's (`x > limit`), a validator's refinement
(`str[Mail]`) -- which is a property of the path, never of the declaration.
A genuinely unknown element stays `any`: an untyped parameter's in its
generic walk, a bare `list`'s, `encode_utf8()`'s without `std::byte`
loaded.

## E. Semantic instances

Three walks type HIR, and each records into the HIR it types:

* **The generic walk** (`hir::types::Walk`) types the program's own HIR. Its
  record is the program's: for `fn first(xs): loop x in xs`, `x` is `any`,
  because the generic walk enters `first` with its untyped parameter. Within
  one walk the last walk of a loop is the one its references are typed by
  (a recursive block's or a fold's fixpoint walks a body again; each walk
  rewrites the references and the record together), and every walk of the
  rounds starts from the same base, so nothing accumulates across walks.
* **A semantic instance's walk** (`hir::semantic::Walk`) types a scratch
  copy of the request-time HIR, which is discarded. It records its loop
  clause bindings in a table of the copy's own (`instanceClauses`), never
  in the copy's binding table: the copy shares the program's binding
  table, and its first write there would copy every binding of the program
  for each instance walk (section M). What survives is its snapshot
  (`hir::semantic::Snapshot`), which kept the binding types of the region's
  `bind`s and now also its loop clause bindings'; its view
  (`hir::semantic::View`, what `hir::semantic::verify`'s instance checks and
  the trait plan read) installs them. So `first`'s instance for
  `List[int]` sees `x: int`, the one for `List[str]` sees `x: str`, and the
  program's HIR keeps `any`.
* **Region inference** (`hir::types::inferRegion`, hir/specialize.tcl's
  native instances) types a scratch copy too, of which only expressions'
  types reach its overlay (`hir::specialize::View`), so it records no loop
  clause binding; a specialization's view keeps every local's and every
  clause binding's generic record, as before.
  The one reader that needs an instance's element type there, the ownership
  analysis's `hir::affine::BindingType` (a consuming loop's element, whose
  drop the native lowering emits), keeps deriving a listloop element from
  the iterable's type as the view types it, ahead of the record: in the
  program's HIR and in a semantic instance's view that is exactly the
  record (`RecordClause` records `ElementOf` of the same type), in a
  specialization's view the instance's own.

No instance writes the program's record, so the order in which calls
request instances cannot change it (`lcb-generic-record` compiles both call
orders and compares; mutants `lcb-first-instance-global` and
`lcb-later-instance-overwrites` store the first or the last instance's type
in the program's record and are killed). The compiler service presents the
generic record: a hover at a generic function's loop variable says `x:
any`, which is true of the declaration for every caller, never one
instance's type.

## F. Implementation

| file | change | why |
|---|---|---|
| hir/types.tcl | `RecordClause HIR CTX B TYPE`, called by the `listloop`, `countloop` and `lockloop` cases beside the fact they set: the generic walk writes the binding table (only a changed record), a semantic instance's walk its copy's `instanceClauses`, region inference nothing | the one missing write; `intern` of the type the walk already computed, no new walk, and no copy of the program's binding table per instance walk |
| hir/hir.tcl | `hir::loopClauseBindings NODE`; the binding record's `type` documented for every kind of binding | one statement of which bindings are clause bindings, for the snapshot, HIR text and the tests |
| hir/semantic.tcl | `Snapshot` keeps the region's loop clause bindings' types (from the walk's `instanceClauses`) | an instance's view sees its own type, as for its locals |
| hir/affine.tcl | `BindingType` derives a listloop element before reading the record | keeps the per-specialization precision the derivation gave (section E); no ownership decision changes |
| hir/read.tcl | `ClauseTypes`: HIR text's reader records clause bindings as the walk does | HIR text prints no binding record and its reader rebuilds a local's and a payload's; now a clause binding's too, so a `.hir` file's HIR agrees with the HIR it was printed from |

Nothing changes in `hir::types::IterationElementOf`, `hir::iteration`,
collecting-loop or fold typing and lowering, the standard library or any
backend. Integration point with the parallel fold construction work: the
three `RecordClause` calls sit beside the `dict set ctx facts` lines of the
loop cases, and `FoldBody` is untouched; a change to fold intermediate
typing does not touch them.

## G. Binding-table consumers

`hir::bindingType` has 26 call sites at `88ca1e4` (the census counted 24 at
`f2787af`). Which read a loop clause binding, and what changes:

| call site | reads | before (a clause binding) | after |
|---|---|---|---|
| `hir::methods::DefinedType` | the type a receiver binding was defined with: the method decision's stand-in guess for a reference's receiver | `any` (no kind proof) | the element type: the stand-in proposes the candidate the reference's own type selects. Certification still judges every candidate by the call's own checks (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md); the corpus's decisions and choices are identical |
| `hir::completions::BindingFact` | a captured binding's callable fact (a closure created here) | `any`: unknown, else what the walk recorded | the type's fact: an exact callable's identity, a structural Fn's contract, `clean` for a value that cannot be a callable -- what a reference to it is charged already |
| `hir::completions::CleanInput` | whether a block parameter or capture is uncontracted (a captured loop element) | `any`: clean, and `top` in `PossibleOf` | uncontracted only when its type is |
| `hir::staticdeps::Ownership` | erasure consumers: references to a binding whose type is affine or mentions `any`, while the program has an `AFFINE-ERASURE-UNSUPPORTED` | every reference to a loop variable | only those of affine or `any`-mentioning type; a loop variable is never moved, so these consumers produced no edge (section H) |
| `hir::staticdeps::ScopedBy` | a moved binding's scoping | (loop clause bindings are not moved) | unchanged |
| `hir::staticdeps::BindingSuccessors` | `shared`: a binding of affine or mutable type mentioned from another region | no edge (`any` is neither) | an edge for a MutableVector or MutableArray element a nested function mentions: a dependency the `any` record left out (section H) |
| `hir::emission::CanonBinding` | a claimed function's outer binding: its type's fact in the canonical text | the top fact | the element's facts; every verdict over the corpus and `tests/emission-claims.test` is unchanged |
| `hir::affine::BindingType` | ownership of a binding | listloop element: derived; counter, lockstep clause: `any` | listloop element: derived (as before); counter, lockstep clause: the record. A lockstep clause over an affine List is AFFINE-LIST-OPERATION-UNSUPPORTED at its iterable whatever the binding's type, and an `int` or any other unrestricted type gives the same descriptor, release and diagnostics as `any` |
| `service::BindingType` | the hover's declaration type | `any` | the record |
| `hir::types::BindingType` | module bindings only | -- | unchanged |
| `hir::cardinality::DefinedLength` | fold intermediates only; a loop element's length is derived from its iterable | -- | unchanged |
| `hir::callables::WalkFold`, `hir::completions::Positions`, `SubsumeCollected`, `FoldEntry`, `EvalListloop`, `hir::emission::EvalLoop` | fold intermediates only | -- | unchanged |
| `hir::staticdeps::UnwindWitnesses`, `PossibleUnit`, `hir::contexts::ReleaseEdges`, `hir::completions::ValueCarriesStatic`, `hir::aot::analyzeRegion`, `ccompile::Params` | a block's parameters only | -- | unchanged |
| `hir::privacy::CheckBinding` | a `bind`'s binding only | -- | unchanged |
| `core::compiler::GenerateUnit` | the program scope's bindings (loop clause bindings belong to their loop's scope) | -- | unchanged |
| `ccompile::BindingTypeOf` | nothing calls it | -- | -- |

Every consumer that changes now reads what the checker already gives the
binding's references, so none can become unsound by it: a reference typed
`int` was already checked as one, a callable element already charged by its
type's fact. The conservative answers it replaces were less precise, never
more correct.

## H. Static decisions and proofs

`audit/loop-binding-types/tools/compare.tcl` compiles every golden suite,
the two workloads' suites and the census's probes (138 programs) with the
front end of a checkout -- each in a fresh process, -strict 0, no cache --
and records the method-call decisions and choices, every static site's
outcome, acceptance, the HIR text (`hir::format`: every expression's type,
outcome, target and flags), the reported diagnostics, every emission
claim's verdict, the static-decision dependency analyses it ran
(`hir::staticdeps::Deps`: graph nodes, labelled edges, site dependencies),
the build counters and the loop clause records. Before (`88ca1e4`) against
after:

| over the 138 programs (two rejected before HIR: probes `e2`, `f1`) | before | after |
|---|---:|---:|
| method-call decisions and choices | -- | identical |
| static sites' outcomes and reified codes | -- | identical |
| acceptance; reported diagnostics (20, kind and location) | -- | identical |
| HIR text of every program | -- | identical (*) |
| emission claims' verdicts | -- | identical |
| whole-program builds / method trials / deviations / finals / reused | 413 / 68 / 13 / 3 / 50 | 413 / 68 / 13 / 3 / 50 |
| dependency analyses run / graph nodes / labelled edges / site dependencies | 95 / 61,879 / 219,660 / 1,874 | 95 / 61,879 / 219,660 / 1,874 |
| loop clause bindings (with their standard-library modules) | 4,473 | 4,473 |
| ... recorded `any` | 4,408 | 710 |
| ... a reference finer than the record | 3,571 | 5 |
| ... a reference contradicting the record | 0 | 0 |
| ... entries in semantic instances' snapshots | 0 | 951 |
| front-end time, total | 1,048.6 s | 966.9 s |

(*) One probe's text differs, `c6`, whose comments this change edits: the
same file compiled by both front ends gives byte-identical HIR text. The
"after" column is the final version (section E); the first version, which
recorded an instance walk's clauses in its copy's binding table, gave every
row the same values but the time (1,043.6 s).

So over the corpus no decision, outcome, diagnostic, certificate, build or
dependency edge changes: the conservative readers' more precise inputs
(section G) never reached a decision there. The 710 records left `any`
are genuinely unknown elements (generic walks of untyped parameters, bare
`list`s); the five finer references are a guard's narrowing (section D).

`audit/static-decisions/tools/fuzz.tcl` (seeds 17 and 41: 40 programs,
1,048 sites, four layouts each, batched against sequential): 0 failures.
Seed 41 reports two layout pairs taking a different number of rounds, an
economy and no failure, which the tree before the change reports
identically.

Two targeted programs measure what the corpus does not exercise
(`tests/loop-clause-binding-types.test`'s `lcb-staticdeps-*`):

* **A loop over MutableVectors whose element a nested function mentions**,
  in a static site: the dependency graph gains one edge (25 to 26), the
  `shared` edge `hir::staticdeps::BindingSuccessors` gives a mutable binding
  mentioned from another region -- one the `any` record left out (`any` is
  neither affine nor mutable). It changes no decision: the batched
  scheduler decides both sites exactly as the sequential order does
  (`lcb-staticdeps-decisions`), both rejected for their own TYPE failures.
  Every edge the record adds is one the binding's type calls for; one it
  removes (an erasure consumer of an `int` loop variable) was a reference
  of a binding nothing moves, which produced no edge.
* **An affine erasure beside folds and nested loops over Ints**: the
  references to the loop variables leave the erasure consumers; the graph
  is identical (61 edges), as no join moves a loop variable.

Unresolved names, forward references and `never` results: a record is
written by the same walk that types the references, so a poisoned or
unresolved iterable records its element `never` and poison exactly as its
references are poison (`lcb-poisoned-iterable`), and no diagnostic of an
unresolved name is hidden (the reported diagnostics of every rejected
corpus program are identical). Emission certificates read the record only
for an outer binding of a claimed function (`CanonBinding`); no verdict
changed, and the in-process memo's fingerprints change only for such a
claim.

## I. Compiler service and LSP

`service::BindingType` reads the record through `hir::bindingType` as
before; no special case was added to the service or the server. Hover
parity (`lcb-service-declaration-reference`,
`cs-hover-loop-variable`, `lsp-lang-loop-variable-worker` and `-sync`),
each declaration and a reference:

| binding | declaration | reference |
|---|---|---|
| `b` in `loop b in bs` (the reproducer) | `b: int[std::byte::Byte]` | `b: int[std::byte::Byte]` |
| a counter `i` | `i: int` | `i: int` |
| lockstep `x` (List[int]) and `w` (List[str]) | `x: int`, `w: str` | `x: int`, `w: str` |
| a nested loop's `cell` | `cell: int` | `cell: int` |
| a struct element `h` | `h: Holder` | `h: Holder` |
| csProgram's `loop x in xs` | `x: int` | `x: int` |
| a lockstep counter (LSP) | `i: int` | `i: int` |
| a generic function's `x` (LSP, `lcb-service-generic`) | `x: any` | `x: any` |

Negative controls (`lcb-unknown-elements`): an untyped parameter's element
`x: any`, a bare `list`'s `y: any`, `encode_utf8()`'s without `std::byte`
`b: any`, an empty List's `z: never`. Refinements are kept
(`lcb-refinements`: `p: List[int]{length: 2}`, `q: int[Small]`).

The census's matrix (`audit/text-collection-precision/tools/matrix.py`)
gained two columns -- a refined `List[int]{length: 2}` element and the
unknown element -- and a second table, the binding table's record of every
loop clause binding of its programs, each checked against the service's
presentation, its references' types and the first table's loop element
type (a counter against `int`):

| loop clause bindings: recorded type | Byte | UnicodeChar | Small | int | Holder | str | List[int]{length: 2} | unknown |
|---|---|---|---|---|---|---|---|---|
| loop element | x: `int[std::byte::Byte]` | x: `UnicodeChar` | x: `int[Small]` | x: `int` | x: `Holder` | x: `str` | x: `List[int]{length: 2}` | x: `any` |
| collecting loop, element | x: `int[std::byte::Byte]` | x: `UnicodeChar` | x: `int[Small]` | x: `int` | x: `Holder` | x: `str` | x: `List[int]{length: 2}` | x: `any` |
| collecting loop, result | x: `int[std::byte::Byte]` | x: `UnicodeChar` | x: `int[Small]` | x: `int` | x: `Holder` | x: `str` | x: `List[int]{length: 2}` | x: `any` |
| fold intermediate | x: `int[std::byte::Byte]` | x: `UnicodeChar` | x: `int[Small]` | x: `int` | x: `Holder` | x: `str` | x: `List[int]{length: 2}` | x: `any` |
| lockstep loop element | x: `int[std::byte::Byte]`, i: `int` | x: `UnicodeChar`, i: `int` | x: `int[Small]`, i: `int` | x: `int`, i: `int` | x: `Holder`, i: `int` | x: `str`, i: `int` | x: `List[int]{length: 2}`, i: `int` | x: `any`, i: `int` |

Every cell equals the service's presentation and its references' types
(exit status 0). The checker's own table (the first) is unchanged from the
census for the six original types; its new columns give `List[int]` (a
TYPE diagnostic prints a List without its length) and `any` -- the record
keeps the refinement the diagnostic does not print. The collection or
result types of the first table (`collecting loop, result`,
`List[int[std::byte::Byte]]`, ...) are unchanged.

## J. HIR and caches

* **HIR interchange** carries the HIR dict, binding records included:
  `lcb-interchange` decodes exactly the records the build made (12 clause
  bindings). The instance snapshots now hold loop clause entries too (951
  over the corpus), which interchange carries with the rest of the
  semantic side table (sizes in section M). The format and its version are
  unchanged; the front end's fingerprint changes, as with every front-end
  change.
* **HIR text** prints no binding record; `hir::read` now rebuilds each loop
  clause binding's as the walk records it (`lcb-hir-text`: every record of
  a twelve-clause program equal after `hir::parse [hir::format $hir]`; the
  round trip of a program over Lists, a counter, a lockstep loop and a
  MutableMap agrees on all 34 loops, the standard library's included).
* **The front-end cache** stores interchange text: a hit in the same
  process and one in a fresh process have exactly the build's records
  (`lcb-cache`; mutant `lcb-cache-strengthens`, a hit that makes an `any`
  record precise, is killed).
* **Isolation**: compiling programs whose loops have other element types in
  turn and again in one process gives each its own records
  (`lcb-repeated-compilation`); records are per HIR, and no registry is
  involved.

## K. Backend parity

The records change no lowering: the HIR text of every accepted corpus
program is identical before and after (section H), the C backend reads
binding types only for a function's parameters, and `main.tcl -emit-c` over
C-COMPILE-FREESTANDING-MILESTONE-1.md's corpus (33 programs) writes
byte-identical files (45 files of the 11 programs it compiles; the same 20
C UNSUPPORTED and 2 front-end rejections) -- M1 changes nothing for C.

Executed, through `tests/local.tcl` (every golden suite on all four
backends, through the front-end cache): interp 5,637 of 5,637 golden tests,
compile 5,637 of 5,637, cranelift-generic 5,545 of 5,545, cranelift 5,647
of 5,647 (the counts differ by the suites' declared exclusions). The census
probes run every accepted probe on the four backends
(`audit/text-collection-precision/tools/probes.tcl`: 18 of 18 as
expected), and `lcb-backends` runs a program with every loop kind on the
four with one outcome (`value 20`).

## L. Regression and mutation testing

| command | result |
|---|---|
| `tclsh9.0 tests/loop-clause-binding-types.test` (interp and compile passes) | 18 of 18 |
| `tests/compiler-service.test` (new `cs-hover-loop-variable`) | 57 of 57 on both passes |
| `tests/lsp.test` (new `lsp-lang-loop-variable-worker`, `-sync`) | 79 of 79 on both passes |
| `tclsh9.0 tests/local.tcl` (275 Tcl test files on interp and compile, 118 golden suites on four backends; the first version) | 17,934 Tcl tests passed, 1 failed: `sh-grammar-vim-corpus` of `tests/syntax-highlighting.test` on the compile pass, `vim` exiting with status 1 under the run's four-way load (the lexer, the grammars and the two files it reads are unchanged); the file's rerun command passed (26 of 26, 1 skipped by `nodeTextMate`), as its interp pass did in the run itself. Golden: every test of every suite on every backend (section K) |
| `tclsh9.0 tests/local.tcl -parts tcl` over the 31 files the final version's recording touches (the new file, semantic instances, affine and its applications, coroutines, static economics and static compile, emission claims, interchange, cache, isolation, compiler service, LSP, folds and loops, MutableVector and MutableArray, method resolution and filter, completions, context affine state, resources, traits, CSV emission, DFAs) | 1,199 of 1,199 on interp, 1,199 of 1,199 on compile |
| `audit/text-collection-precision/tools/probes.tcl` | 18 probes as expected (`c1`, `c6` flipped) |
| `python3 -I audit/text-collection-precision/tools/matrix.py` | exit 0 (section I) |
| `audit/loop-binding-types/tools/mutate.tcl` | 14 of 14 killed by the tests their `!!` lines name (below) |
| `tclsh9.0 tools/mutant-catalogs.tcl` | 91 catalogs, 3,191 mutants, 0 problems |
| `audit/static-decisions/tools/fuzz.tcl -seed 17`, `-seed 41` | 0 failures (section H) |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange` / `-via cache` | 12 suites, 108 / 120 artifacts and outcomes, 0 differ |
| `audit/hir-interchange/tools/mutate.tcl` | 28 of 28 killed |
| `audit/affine/tools/fuzz.tcl -seed 1`, `7`, `23` | 270 programs, 0 disagreements |
| `audit/affine/tools/mutate.tcl -only exit-raw-only,last-use-raw-only,partial-destructure-leak`; `audit/context-affine/tools/mutate.tcl -only context-binding-owns` | 4 of 4 killed (by tests and by the fuzzer) |
| `tclsh9.0 tools/compilerpedia.tcl check` | 1,290 topics, 758 examples, 0 problems |
| `main.tcl -emit-c` over the C corpus | byte-identical (section K) |
| `audit/loop-binding-types/tools/compare.tcl` before / after | section H |

The affine and coroutine catalogs were not run in full (121 mutants, hours
here): no mutant of either edits the lines this change touches
(`hir::affine::BindingType`'s order of cases), `tools/mutant-catalogs.tcl`
shows every one still applies, and the four whose kill depends on what
`BindingType` answers -- three affine, one context-affine -- were run and
killed. The method-resolution oracle was not run: nothing of the decision
changed, and its decisions over the corpus are identical (section H).

The mutants (`audit/loop-binding-types/tools/mutants.txt`):

| mutant | breaks | killed by |
|---|---|---|
| `lcb-element-unrecorded` | no listloop record | `lcb-reproducer`, `lcb-every-kind`, `lcb-service-declaration-reference`, `cs-hover-loop-variable`, `lsp-lang-loop-variable-worker`, `-sync` |
| `lcb-counter-unrecorded` | no countloop record | `lcb-every-kind`, `lcb-generic-record`, `lcb-service-declaration-reference` |
| `lcb-lockstep-unrecorded` | no lockstep record | `lcb-every-kind`, `lcb-service-declaration-reference`, both LSP tests |
| `lcb-lockstep-first-clause` | every clause gets the first clause's type | `lcb-every-kind`, `lcb-service-declaration-reference` |
| `lcb-poison-recorded-any` | a poisoned element recorded `any` | `lcb-poisoned-iterable` |
| `lcb-refinement-forgotten` | a refined element recorded as its base | `lcb-refinements` |
| `lcb-domain-carrier` | a domain element recorded as its carrier | `lcb-refinements`, `lcb-reproducer`, `lcb-service-declaration-reference`, both LSP tests |
| `lcb-first-instance-global` | the first instance's type stored as the program's record | `lcb-generic-record`, `lcb-service-generic`, both LSP tests |
| `lcb-later-instance-overwrites` | every instance overwrites the program's record | `lcb-generic-record`, `lcb-service-generic`, both LSP tests |
| `lcb-snapshot-omits-clauses` | an instance's snapshot keeps no loop clause | `lcb-generic-record`, `lcb-instance-view` |
| `lcb-service-declaration-any` | the service presents a declaration as `any`, references intact | `lcb-service-declaration-reference`, `cs-hover-loop-variable`, both LSP tests |
| `lcb-interchange-loses` | decoding interchange forgets the records | `lcb-interchange`, `lcb-cache`, `lsp-lang-loop-variable-worker` |
| `lcb-cache-strengthens` | a cache hit makes an `any` record precise | `lcb-cache` |
| `lcb-hir-text-unrebuilt` | reading HIR text leaves the records out | `lcb-hir-text` |

CI on the branch (`cad6bb7`): `icy-tower (windows x86-64)` and the `tests (linux arm64)` canary passed; `tests (macos arm64)`, `tests (windows x86-64)`, `icy-tower (macos arm64)` and the dispatched `tests`, `tests (linux arm64)` and `static-decisions` runs are pending (queued), not passed.

## M. Performance

`audit/loop-binding-types/tools/bench.tcl` (each run a fresh process, -strict 0, no
cache; medians of five; front-end time, the HIR interchange text's size,
the bindings with a record, the semantic instances and their snapshots'
loop clause entries, a cache hit in a fresh process), on this container (4
cores, nothing else running), before (`88ca1e4`) and after:

| workload | front end before / after (ms) | interchange before / after (bytes) | recorded bindings | instances | snapshot loop entries | cache hit before / after (ms) |
|---|---:|---:|---:|---:|---:|---:|
| 100 list loops | 683 / 619 | 644,107 / 644,138 | 206 / 310 | 0 | 0 / 0 | 30 / 29 |
| 100 x 3 nested loops | 1,061 / 991 | 961,176 / 961,407 | 206 / 510 | 0 | 0 / 0 | 51 / 42 |
| 100 counted loops | 551 / 525 | 572,357 / 572,388 | 206 / 310 | 0 | 0 / 0 | 28 / 28 |
| 100 lockstep loops, 3 clauses | 1,556 / 1,468 | 1,150,762 / 1,151,093 | 306 / 710 | 0 | 0 / 0 | 53 / 50 |
| 100 generic loops x 4 instances | 1,507 / 1,560 (+3.5%) * | 1,357,507 / 1,362,538 | 506 / 610 | 400 / 400 | 0 / 400 | 55 / 55 |

The four single-kind workloads run within noise or faster (all before-runs
came first; the differences are the machine's, not the change's: the
recording adds an `intern` and a compare per clause, which no measurement
here can tell apart).
The interchange text grows by tens of bytes per hundred records, and by
about 12 bytes per snapshot entry.

(*) Interleaved runs (before, after, before, ...; seven each). The first
version of the change recorded an instance walk's clause bindings in its
scratch copy's binding table: +8.8% here, every after-run slower than every
before-run, because that copy shares the program's binding table and its
first write copied all of it for every instance walk (the functions here
have no local of their own, whose bind paid that copy before). Recording in
the walk's own table (section E) took it to +3.5%. What is left is the
snapshot's entry being installed in each instance's view
(`hir::semantic::View`, during `hir::semantic::verify`): measured with the
snapshot's loop entries disabled, the cost is -0.3%. That copy is the one
any instance with a local already pays, so it is new only for an instance
whose body binds no local; it is linear in the instances verified.

The repository's iteration-heavy programs, interleaved (five each; the
first version of the change, which did the extra copy above, so an upper
bound):

| program | front end before (ms) | after (ms) | |
|---|---:|---:|---:|
| the 2048 engine's suite | 5,524 | 5,493 | -0.6% |
| Icy Tower's suite | 35,563 | 36,088 | +1.5% |
| collection-iteration.bot | 8,869 | 8,850 | -0.2% |
| fold-loops.bot | 14,884 | 14,816 | -0.5% |
| mutable-vector.bot | 14,105 | 14,491 | +2.7% |

all within the runs' spread (Icy Tower's before runs span 34.8-36.6 s).
The corpus as a whole (section H's 138 compilations, four at a time) took
1,048.6 s before, 1,043.6 s with the first version and 966.9 s with the
final one. The number of semantic instances
analyzed is unchanged everywhere; the static-decision dependency counts are
section H's (identical); a cache hit is unchanged.

## N. Remaining limitations

* **Fold intermediates in instance views.** A semantic instance's snapshot
  keeps its locals' and now its loop clause bindings' types, but not a
  fold intermediate's: an instance's view sees the generic walk's
  intermediate type. Fold typing is outside this milestone (and the
  parallel fold construction work's); the snapshot's `recorded` list is
  where it would go.
* **Specializations' views** (hir/specialize.tcl) overlay expression types
  only: every local's and every clause binding's record there is the
  generic walk's (section E). The ownership analysis derives a listloop
  element from the view; no other reader of a specialization's view reads
  a loop clause binding.
* **A generic declaration's hover** says `any` for an element its generic
  walk does not know, however precise every instance is; the service has
  no presentation of per-instance types.
* M2-M8 of the census are untouched: `encode_utf8()`'s element type still
  depends on `std::byte` being loaded (M3; probes `c3`-`c5` unchanged).
