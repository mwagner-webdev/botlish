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
  copy of the request-time HIR, which is discarded. What survives is its
  snapshot (`hir::semantic::Snapshot`), which kept the binding types of the
  region's `bind`s and now also its loop clause bindings'; its view
  (`hir::semantic::View`, what `hir::semantic::verify`'s instance checks and
  the trait plan read) installs them. So `first`'s instance for
  `List[int]` sees `x: int`, the one for `List[str]` sees `x: str`, and the
  program's HIR keeps `any`.
* **Region inference** (`hir::types::inferRegion`, hir/specialize.tcl's
  native instances) types a scratch copy too, of which only expressions'
  types reach its overlay (`hir::specialize::View`); a specialization's view
  keeps every local's and every clause binding's generic record, as before.
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
| hir/types.tcl | `RecordClause`, called by the `listloop`, `countloop` and `lockloop` cases beside the fact they set | the one missing write; `intern` of the type the walk already computed, no new walk |
| hir/hir.tcl | `hir::loopClauseBindings NODE`; the binding record's `type` documented for every kind of binding | one statement of which bindings are clause bindings, for the snapshot, HIR text and the tests |
| hir/semantic.tcl | `Snapshot` keeps the region's loop clause bindings' types | an instance's view sees its own type, as for its locals |
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

RESULTS-H

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

RESULTS-I

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

RESULTS-K

## L. Regression and mutation testing

RESULTS-L

## M. Performance

RESULTS-M

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
