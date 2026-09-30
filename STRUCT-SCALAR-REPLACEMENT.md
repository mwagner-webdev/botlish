# Struct-aware scalar replacement: local and one-hop cases

This milestone removes the physical `StructObj` of an immutable struct value
when the value is built and consumed locally, or crosses one statically known
call or return boundary and is immediately decomposed. It is the first
representation optimization after structs, and it is deliberately *not* the
general distance x width x direction x nesting transport optimizer: it
establishes the representation and the correctness mechanisms that optimizer
will build on, measures the obvious cases, and records the data the next
milestone needs.

Every number below is measured, with the tools in
`audit/struct-scalar-replacement/` (run against three trees: the pre-struct
parent `84f4d68`, the structs milestone `46d658d` -- "structs" or "base" below
-- and this tree, "after"). Nothing is derived from an expected count.

## Outcome

* **The scan-result and rehash-grouping structs are scalar-replaced again, with
  the structs kept.** The CSV scan results cross one exact return as
  `retmulti`/`callmulti` fields, the hashtable rehash groupings cross their
  exact calls as fields, and a struct built and only projected locally is never
  allocated. `structnew` now counts materializations: the canonical corpus goes
  from 39 `structnew`/52 `structget` to 15/2 (the 15 are the genuine `Test`
  values of `test-selection`, stored in Lists -- the control).
* **The struct milestone's regression is fully recovered, to the object.** On
  all eleven workloads the allocation count, allocated bytes and GC cycles of
  this tree equal the pre-struct parent's (for example `csv_geometric_10000`:
  298937 allocations, 13653895 bytes, 7 GC cycles, against 348951 /
  16054567 / 8 for the structs milestone), `Struct` allocations are **0**
  (were 514 to 60030), and the List/MutableArray/String/StringPlan counts are
  unchanged. Machine code returns to the parent's bytes (`csv_geometric` 7625 B,
  `hashtable` 9587 B) or below (`csv_records` 23335 B against 23748 B).
* **Runtime recovers to the parent's level.** Best-of-15 per round, three
  interleaved rounds, minimum over rounds: 6.6% to 27.4% faster than the structs
  milestone on the CSV workloads (`csv_geometric_10000` -20.0%,
  `csv_records_1000x5` -24.2%, `csv_records_10000x5` -27.4%), within +1% to
  +7% of the pre-struct parent on the `csv_geometric` and `csv_records_1000x*`
  workloads and 5.6% to 5.7% *faster* than the parent on
  `csv_records_presized_1000x20` and `csv_records_10000x5` (the machine's
  same-tree noise is 5-15%, so read differences under ~10% as unresolved).
* **One analysis, no second optimizer, no new NIR opcode, no new runtime
  object, no HIR change.** `hir/escape.tcl`'s fixed-shape aggregate analysis
  (written for positional Lists) now carries a second aggregate kind, structs;
  `native/lower.tcl` reuses its `retmulti`/`callmulti` companions, its
  `fields` parameter variants and its virtual-field locals. The only additions
  to lowering are struct-shaped: slot-ordered literals, field projection from
  virtual fields, lazy single materialization, struct aliases and field-wise
  `if` joins.
* **Materialization is lazy and single**, preserving named/anonymous shape
  identity: a struct both projected and stored is projected directly before,
  built once at the first physical use, and every later physical use of it (or
  of an alias) in that scope reuses the one object.
* **Semantics did not move.** Source (`.bot`), HIR, Core IR, types, equality,
  hashing, printing and the reference interpreter are unchanged. The
  interpreter, native with the optimization and native with `-struct-opt 0`
  agree on every focused test, on 300 + 100 fuzzed programs and on the whole
  suite.
* **Regression:** `tclsh9.0 tests/all.tcl`: interp 3487 passed, 0 failed; compile 3483 passed, 4 skipped, 0 failed (the same 4 `coreScoping` skips as the parent). The 84 new tests are `tests/struct-scalar-replacement.test`; native coverage, Rust tests, GC stress and benchmark parity below.

## Motivation

Before structs, the scan results were positional Lists (`[field, index]`,
`[fields, stop]`) and the rehash groupings were `[controls, keys, values]`
triples. The existing List scalar-replacement and parameter-aggregate machinery
(`hir/escape.tcl`, `native/lower.tcl`) carried them as registers: no List
allocation, `callmulti`/`retmulti` at the returns, `fields` variants at the
calls. The struct milestone replaced them with structs, which is semantically
far better (typed fields, nominal identity, no positional `list_get`), and
measured the price: every such product became a real heap object
(`csv_geometric_10000`: +50014 allocations, +17.6% bytes, +23.7% time;
`csv_records`: +43% to +48% allocations, +8% to +41% time). The machinery did
not know structs, so a semantically superior value paid for a representation
that had nothing to do with its semantics.

The principle of this milestone: **a struct is a semantic value, a physical
`StructObj` is only one possible representation of it.** If the compiler can
carry the fields independently without changing observable behavior, it does.

## Baseline from the struct milestone

Captured fresh from `46d658d` (`git archive` into a scratch tree,
`native/target` shared), with the tools of `audit/struct-scalar-replacement/`.

Canonical corpus (17 programs; `audit/structs/tools/niropcensus.py`):

| | structs milestone | pre-struct parent |
|---|---:|---:|
| `structnew` | 39 | 0 |
| `structget` | 52 | 0 |
| `call` | 328 | 303 |
| `callmulti` | 29 | 57 |
| `retmulti` | 18 | 50 |
| functions | 231 | 234 |
| guards | 59 | 64 |
| NIR lines | 6160 | 6104 |

The structs milestone's own census reproduces (39/52/29/18). The fresh
regression of the unmodified structs tree: interp 3403 passed, 0 failed;
compile 3399 passed, 4 skipped, 0 failed.

Workloads, structs milestone (deterministic counts reproduce
`STRUCTS.md`'s): `csv_geometric_100/1000/10000` 3342/33946/348951 allocations
(514/5014/50014 Struct); `csv_records_1000x5/1000x20/presized/10000x5`
20137/62169/52169/200145 (6030/25045/21045/60030 Struct); a hashtable build
of 1000/10000/50000 int keys 44/59/74 (16/22/28 Struct).

## Terminology

| term | meaning |
|---|---|
| **virtual struct** | a semantic struct whose fields exist independently, as compiler values/registers, and for which no `StructObj` currently exists |
| **materialized struct** | a physical runtime `StructObj` |
| **scalar replacement** | representing the struct through its fields instead of the physical object |
| **materialization** | creating a `StructObj` from virtual fields when an operation actually needs one |
| **descriptor** | `{N SHAPE}`: field count and shape (`{ID LAYOUT}`: named identity or `""`, slot-order field names; `""` for a List), the representation fact the analysis carries |
| **one hop** | one exact call or return boundary |

Scalar replacement is *representation only*: nothing here describes or changes
struct semantics.

## Architecture

The three-representation architecture is unchanged:

```
surface -> HIR -> Core IR -> reference interpreter / Tcl compiler   (no change)

surface -> HIR -> [hir::escape aggregate analysis] -> NIR -> native
                     virtuality lives here        structnew = materialization
```

`hir/escape.tcl` answers "may this value stay virtual, and of what descriptor?"
per semantic instance; `native/lower.tcl` turns the answer into registers.
HIR keeps saying `struct` and `project`; the decision is in analysis and
lowering, never a typing or HIR flag. Native compilation still starts from
resolved, analyzed HIR and never goes through Core IR (`tests/direct-hir-native.test`
still passes).

## Existing List aggregate machinery, audited

Audit of what recognized a positional List as virtual and how:

| question | answer |
|---|---|
| which analysis recognized the List as virtual | `hir/escape.tcl`: `Classify` (a `[e0..en-1]` literal, or an exact call to an instance whose every exit classifies to one arity), `RawLocalArities`/`RawParamArities` (which slots provably carry a fixed shape), `Eligible` (which of those have only structural uses) |
| how virtual fields were represented | a `fn locals` entry `{virtual FIELDS}` in `native/lower.tcl`: one ordinary tagged register per element |
| how projections consumed them | the `list_get(ref, constant)` interception in `Call`: read the field register, no `listget` |
| how `callmulti`/`retmulti` were generated | `Arities` marks an instance's result recognized; `CompanionFunction` ends every exit in `retmulti` of `VirtualValue` fields; `Call` with `wantVirtual` emits `callmulti` |
| where materialization happened | *nowhere*: a List was virtual only if **every** use was a constant-index read or an unchanged forward; otherwise the analysis gave the binding up entirely and it was built at construction |

## Existing parameter-aggregate machinery, audited

`RawParamArities` (a parameter's shape is a caller-proven value fact: every
exact call site must classify the argument to the same arity; a self-forward
is skipped), `Eligible` (greatest fixpoint over candidates; a forward is a
supported use only into another candidate of the same arity), `SetupFieldParams`
(a `fields` variant receives N registers per virtual parameter),
`CanSupplyFields`/`TryFields`/`CallArgs` (the per-call-site decision and field
evaluation), and the always-emitted canonical function that open callers keep
using. Key answer: **yes, a struct became another aggregate kind the existing
field/slot transport machinery understands.**

| piece | verdict |
|---|---|
| `hir::escape` `Classify`/`Arities`/`RawLocalArities`/`RawParamArities`/`Eligible` | **generalized** (descriptor `{N SHAPE}` instead of `N`; struct literals, struct `if` joins; struct aliases; struct uses) |
| `hir::escape` `CallSites`, `Propagate`, `Exits`, `TrailingPositions`, `SelfTailExit` | reused unchanged |
| construction analysis (`hir/construction.tcl`) | not relevant (String/List plans); it consults `virtualArity`/`wants`/`paramWants`, which keep their meaning |
| traversal analysis (`hir/traversal.tcl`) | not relevant; it excludes instances with a scalar companion, now including struct ones -- as it did for the pair Lists before structs |
| block escape (`hir/blockescape.tcl`) | not relevant (Blocks) |
| `native/lower.tcl`: `CompanionFunction`, `FieldsFunction`, `FieldsCompanionFunction`, `SetupFieldParams`, `CallArgs`, `CanSupplyFields`, `TryFields`, `Call` (`callmulti` emission), `Bind`, `Ref`, `If` | **generalized** (struct kinds, struct-shaped entries, `If` with N result registers) |
| `retmulti`/`callmulti`/`results=N` in NIR and Cranelift | reused unchanged |

## Representation analysis

`hir::escape::analyze HIR SPEC ?paramOpt? ?structOpts?`. Algorithmic shape:

* **per-expression use scan** -- `RegionInfo` scans each used instance's region
  once (bindings, references, argument positions, projections, alias binds) and
  one iterative parent/innermost-loop walk (`ParentsAndLoops`);
* **per-function aggregate planning** -- `Arities` (instance results),
  `RawLocalArities` (locals and struct aliases), `Eligible` (the use verdicts);
* **call-edge inspection** -- `CallSites`/`RawParamArities` (exact call sites
  only), forwarding through `ForwardTarget`.

There is **no new whole-program fixed point**: `Arities`, `RawParamArities`
(monotone growth) and `Eligible` (monotone shrink) are the pre-existing ones;
struct descriptors ride in them. Because growth is followed by shrink over a
fixed candidate set, representation planning cannot oscillate.

## Virtual struct model

* The analysis' fact is a descriptor `{N SHAPE}`; SHAPE is `{ID LAYOUT}` --
  exactly what `ShapeIndex` interns runtime shapes by -- so named identity
  (the declaration identity) and the canonical anonymous field set are compiler
  metadata that survive even when no object is created. Struct field identity
  is *shape + slot*, never a dynamic index.
* In lowering a virtual struct is a `fn locals` entry
  `{virtual FIELDS SHAPE ROOT MAT}`: FIELDS in slot order (one ordinary tagged
  register each), SHAPE the descriptor shape, ROOT the binding whose entry
  records the materialization, MAT its register once it exists.
* `CanKeepVirtual` is `UseVerdict` (`hir/escape.tcl`), centralized: one
  procedure classifies every reference of a candidate as free, materializing or
  blocking.
* **Aliases** (`b = a`) are candidates carrying their source's descriptor;
  identity is by binding, not syntactic adjacency; source and alias are kept or
  dropped together, and share one root for materialization.
* **Direct projections**: `{...}.f` and `call(...).f` read the field of a
  recognized construction without a binding.

## Materialization model

*Lazy and single.* A virtual struct stays virtual until the first use that
needs the physical object; there it is built once from fields that all already
exist (`structnew SHAPE f0 f1 ...`, never a partially initialized object), with
the exact named or canonical anonymous shape. The register is recorded in the
root's `locals` entry, so later uses this scope dominates reuse it. `If`,
loops, `handle` and every other branching construct restore `fn locals` on the
way out, so a materialization that does not dominate what follows is never
reused there (the protected call of a `handle` needed the same treatment: what
it builds must not be reused on the handler's path). Materialization is not an
all-or-nothing classification: a struct can be virtual across a call, projected
freely, and materialized later.

## Safe uses

References that cost nothing and keep the struct virtual (`UseVerdict`):
a field projection; an alias; an argument forwarded unchanged to an exact
closed callee whose parameter is itself a candidate of the same descriptor; a
return (as an exit of a recognized instance); a branch value of an `if` whose
every value-producing branch is the same shape (field-wise join).

## Materializing uses

Explicit list (census reason tags): storage into a List, MutableArray or Set
(`storage`); equality (`equality`); hashing (`hash`); any other native call
(`native call`); an unknown/value call (`open call`); an exact call whose
parameter is not virtualizable (`call param`); closure capture (`capture`);
being the program's value (`result`); being returned without a virtual
consumer (`return`); being a field of another struct (`nested field`); an
`if`/`handle` value that cannot join (`control`); a physical use inside a loop
the binding is not in (`loop`, to keep one allocation per binding and not one
per iteration); a struct too wide for its boundary (`width`). Native calls are
never given scalar arguments: the audit found no native taking a struct
operand beyond those above, and each materializes first.

A struct *parameter* never materializes inside its callee: its callers hand it
over as fields, so a use needing the object would allocate once per call. Such
a parameter is simply not virtualized, and its callers keep passing the object.
A local all of whose uses materialize it is not virtualized either (it would
only move the allocation).

## Width policy

Initial, deliberately simple, measured (see "Width experiments"):

| boundary | cap (fields) | why |
|---|---:|---|
| local value | 16 | no ABI cost; code bytes and stack operands at 16 are within 1% / 3% of physical |
| one exact return | 8 | return transport is nearly free up to 8 (code within +1%, at most +6 stack operands); at 16 it still beats the object in code and stack |
| one exact call | 4 | argument transport is copied at every hop: neutral up to 6 fields at distance 0, +59 B / +11 stack operands at 8 and +605 B / +78 at 16, and the penalty compounds with distance (8 fields at distance 1: 3x the stack operands); 4 is the conservative cap, 5-6 are neutral at distance 0 but were not measured at distance |

`N = 0` is virtual locally and physical across a boundary (nothing to
transport). The caps are options (`-struct-local-width`, `-struct-return-width`,
`-struct-arg-width`, or the `BOTLISH_NATIVE_STRUCT_*_WIDTH` environment
variables); the two-field scan results and the three-field rehash groupings are
far inside them.

## Return policy

An instance's result is recognized when every reachable exit (explicit
`return`, trailing value, trailing `if` branches) is a struct literal of one
descriptor, or an exact forwarding call to an instance recognized the same way;
a self-tail exit is a backedge and contributes nothing. Its companion function
returns `retmulti` of the fields (`results=N`); the caller reads them from
`callmulti`. The instance's canonical struct-returning function is still
emitted whenever an open caller needs it. Exits of different field sets (or
one of a different named identity) are *not* one result: they materialize
(census `mixed exits`).

## Argument policy

A parameter is virtual when every exact call site proves the same descriptor
(a literal, a recognized call result, or a reference to a virtual binding) and
every use in the callee is free. The callee's `fields` variant receives one
register per field (`pnames="src.0 src.1 src.2 ..."`); the canonical function
keeps receiving the object for open callers. Calling convention agreement is
planned before any call site is emitted: the decision to use the `fields`
variant is per call site (`CanSupplyFields`), and a site that cannot supply the
fields calls the canonical function with a materialized struct, so no site ever
passes fields to a callee expecting a pointer or the reverse. One-hop argument
transport **shares the machinery cleanly with returns** (the same analysis, the
same `fields` variants), so it is implemented, not deferred.

## Nesting policy

Nested structs are not recursively exploded. The outer struct is virtualized; a
nested struct is **one field value**: an ordinary expression value, which is a
materialized struct (or a register holding one). The transported width of
`{position: {line, column}, token}` is 2 (`position`, `token`), not 3. What
prevents width explosion is that only a struct *literal's own fields* (and a
returned/passed struct's own descriptor) are fields; a field is never itself
recursively opened, and the width caps apply to the outer descriptor.
(See "Nesting experiments": for a nested literal that is only projected,
not opening the inner one costs an allocation; that is the frontier the next
milestone should decide.)

## Recursion/SCC policy

A recursive instance's result is recognized only with a base-case exit
(self-tail exits are loop backedges and are skipped; a non-tail self-forward
never bootstraps). Parameters are proven from *exact* call sites only, with a
self-forward skipped, so a struct threaded through a self-tail loop or a
non-tail self-recursion crosses as fields and the `fields` variant carries them
through the backedge. Cycles through higher-order calls (`f(f, ...)`) are
resolved as open calls and materialize there. No special SCC handling is needed
because the analysis is monotone (growth, then shrink over a fixed candidate
set): it cannot oscillate, and a cycle with no proof simply keeps the
materialized representation. Pinned by `sr-argument-self-recursion`,
`sr-return-recursive` and `sr-recursion-higher-order-cycle`.

## HIR responsibility

Unchanged: `struct`/`project` nodes, typing, instances, semantics. No HIR file
was modified. `hir/escape.tcl` *reads* HIR; nothing mutates it into scalar
variables. Virtuality is not in source typing.

## NIR representation

Strategy **A/C**: virtual structs exist only as compiler bookkeeping over field
registers during HIR->NIR lowering; the existing `callmulti`/`retmulti` and
`fields` variants are the physical transport. NIR contains no explicit virtual
struct and no `virtualstructnew`-like opcode. `structnew` now means a
materialization really occurs here; `structget` remains only for projections
from a materialized struct. A struct with no `structnew` at all is possible
(and is the common case in the corpus). The runtime `StructObj { hdr, shape,
len, ptr }` and the shape table are untouched; there is no new aggregate
runtime object.

## GC/root handling

A virtual struct is not a heap object and so is not a root. Each field is an
ordinary tagged NIR register, rooted by the same safepoint liveness that roots
every register (codegen stores a register to its shadow-stack slot at
definition; stack maps use liveness), each live exactly until its own last use
-- a projection or the materialization -- so a field that dies before a sibling
is not kept alive by the sibling. Across calls the fields are arguments or
`callmulti` results (ordinary registers); `retmulti` returns them; a
materialization after a safepoint reads registers that stayed live, and the
allocation of the object itself is a safepoint with its operands live. Pinned
under GC stress (a collection attempted at every allocation site) by
`sr-gc-strings` (two Strings), `sr-gc-list-string` (List + String),
`sr-gc-mutarray-string` (MutableArray + String), `sr-gc-nested`,
`sr-gc-across-call`, `sr-gc-across-return`, `sr-gc-materialize-after-safepoint`,
and as standalone executables with an empty PATH (`sr-executable-parity`); the
whole suite also passes under GC stress (below).

## Local scalar replacement

Construct -> project, several projections, alias -> project, branch-local
projections, loop-body-local values, nested local, empty, one-field and
four-field structs, direct `{...}.f`, discarded literals (fields evaluated for
effect, nothing built) all compile with no `structnew`/`structget`
(`sr-local-*`, `sr-nested-*`, `sr-branch-*`). Field evaluation order (written
order, errors and effects) is preserved (`sr-local-evaluation-order`,
`sr-local-field-error`, `sr-local-discarded`). Branch merging is implemented:
an `if` whose branches all end in one struct shape joins field-wise, one move
per field, in a value position (`sr-branch-join-*`).

## One-hop return scalar replacement

```
callee scan_unquoted (NIR):                 caller (scan_field):
    %23 = op substr %0 %1 %2                   %3 %4 = callmulti 3 %0 %1 %2
    retmulti %23 %2                            ... %3 is r.field, %4 is r.index
```

Anonymous and named two-field returns, return -> alias -> project, one
projected field, both fields, direct projection of a call, multiple exits of
one shape, recursion and nested fields (`sr-return-*`). Exits of different
shapes, a result wider than the return cap, and a struct also stored or
compared at the caller materialize at the caller, once (`sr-return-different-shapes`,
`sr-materialize-wide-return`, `sr-mixed-use-returned`).

## One-hop argument scalar replacement

```
callee (NIR header):   func 18 "ht_rehash_scan" params=9 pnames="src.0 src.1 src.2 i oldCapacity dest.0 dest.1 dest.2 newCapacity"
```

Construct -> exact callee -> projection, named and anonymous instance-proven
parameters, two and four fields, forwarding chains, self-recursion, several
callers (`sr-argument-*`). The callee that needs the object, an open caller and
a cycle through a function value keep passing the object.

## CSV scan results

(`examples/stdlib/csv*.bot`, unmodified; census of `scan_unquoted`,
`scan_quoted`, `scan_field`, `scan_record`, `scan_record_rest`.)

| program | semantic constructions (instances x sites) | virtual across return | physical `structnew` | structnew before -> after | structget | callmulti | retmulti |
|---|---:|---:|---:|---|---|---|---|
| `csv` | 6 (4 source sites) | 6 | 0 | 6 -> 0 | 8 -> 0 | 5 -> 12 | 2 -> 11 |
| `csv_chunked` | 6 (4) | 6 | 0 | 6 -> 0 | 8 -> 0 | 12 -> 19 | 11 -> 20 |
| `csv_geometric` | 4 (4) | 4 | 0 | 4 -> 0 | 8 -> 0 | 4 -> 11 | 2 -> 9 |
| `csv_records` | 6 (6; 4 scan + 2 rehash) | 4 (+2 across a call) | 0 | 6 -> 0 | 17 -> 0 | 4 -> 11 | 2 -> 9 |

Answers: many semantic struct values, **zero** physical scan-result objects on
the normal parse paths; `scan_unquoted` ends in `retmulti %field %index` again
(machine code: the two values in `rax`/`rdx`, no `rt_struct_new`); caller
projections are direct field values (`structget` 0); none materialize.
`scan_quoted`'s `String` accumulator (a virtual construction plan) still works
through the `field` field: the struct literal holds the materialized String
exactly as before.

## Hashtable rehash results

`ht_rehash`'s `src` and `dest` (`{controls, keys, values}`) are local literals
forwarded unchanged through `ht_rehash_scan` and `ht_rehash_insert` and only
projected there: they cross both calls as three fields each, the two physical
structs per rehash are gone, and the raw MutableArrays are exactly as before
(counts identical to the pre-struct parent: 28/37/46 MutableArrays for 1000/10000/50000
inserts; Struct 16/22/28 -> 0). `ht_rehash_scan` takes 9 parameters
(`src.0 src.1 src.2 ... dest.0 dest.1 dest.2`), `ht_rehash_insert` 6. With
`-param-aggregate-opt 0` the two are built once each at the call (they stay
virtual locals until that non-projecting use): the only use that would force a
wrapper object is a callee that cannot receive fields.

## Test-selection control

`bench/test-selection.bot` keeps its 15 genuine `Test` values physical: the
census says `materialized: storage` for 14 (elements of the `List[Test]`) and
`control` for the `NotFound` handler's value; `structnew` 15 -> 15, `structget`
2 -> 2. `List[Test]` still holds materialized struct values -- the optimization
is use-sensitive, and this milestone is not inline list-element storage.
Equality and hash semantics are unchanged (`sr-materialize-equality`,
`sr-materialize-hash`).

## Materialization census

`native::structCensus HIR ?OPTIONS?` / `native::structCensusText` (audit only,
not a language feature): one record per struct construction (semantic instance
x source site): class (`local`, `call`, `return`, `materialized`), width,
materialization reason, and the uses that materialize a virtual one later.
Corpus (`out/census.txt`), 39 constructions (= the 39 `structnew` of the
structs milestone, one for one):

| class | count | detail |
|---|---:|---|
| virtual across return | 20 | all CSV scan results |
| virtual across call | 4 | the rehash `src`/`dest` (2 programs x 2) |
| virtual local | 0 | (no canonical program builds and only projects a struct locally; the focused tests do) |
| materialized | 15 | `storage` 14, `control` 1: all `test-selection` |

Fields transported virtually: 20 x 2 + 4 x 3 = 52. Focused materialization
reasons pinned by tests: `storage`, `equality`, `hash`, `open call`,
`call param`, `capture`, `result`, `width`, `loop`, `mixed exits`,
`nested field`, `control`.

## NIR before/after

Whole corpus (`out/niropcensus.txt`; structs-milestone NIR from the scratch
tree vs this tree):

| | before | after |
|---|---:|---:|
| `structnew` | 39 | **15** |
| `structget` | 52 | **2** |
| `call` | 328 | 300 |
| `callmulti` | 29 | 57 |
| `retmulti` | 18 | 50 |
| functions | 231 | 231 |
| guards | 59 | 59 |
| NIR lines | 6160 | 6076 |

`callmulti`/`retmulti` return to the pre-struct parent's 57/50 exactly.

| program | structnew | structget | call | callmulti | retmulti | funcs | guards | lines |
|---|---|---|---|---|---|---|---|---|
| `csv` | 6 -> 0 | 8 -> 0 | 11 -> 4 | 5 -> 12 | 2 -> 11 | 11 | 0 | 312 -> 296 |
| `csv_chunked` | 6 -> 0 | 8 -> 0 | 19 -> 12 | 12 -> 19 | 11 -> 20 | 20 | 1 | 530 -> 514 |
| `csv_geometric` | 4 -> 0 | 8 -> 0 | 25 -> 18 | 4 -> 11 | 2 -> 9 | 20 | 2 | 431 -> 417 |
| `csv_records` | 6 -> 0 | 17 -> 0 | 103 -> 96 | 4 -> 11 | 2 -> 9 | 56 | 23 | 1241 -> 1215 |
| `hashtable` | 2 -> 0 | 9 -> 0 | 68 -> 68 | 0 | 0 | 26 | 25 | 645 -> 633 |
| `test-selection` (control) | 15 -> 15 | 2 -> 2 | 12 | 0 | 0 | 12 | 3 | 312 |

There are no virtual projections left as `structget` (questions 39).

## Allocation before/after

`workloads.tcl` (`out/workloads-compare.txt`): total allocations / Struct
allocations / bytes / GC cycles, per tree.

| workload | pre-struct parent | structs milestone | after |
|---|---|---|---|
| `csv_geometric_100` | 2828 / 0 / 128635 / 0 | 3342 / 514 / 153307 / 0 | **2828 / 0 / 128635 / 0** |
| `csv_geometric_1000` | 28932 / 0 / 1312985 / 1 | 33946 / 5014 / 1553657 / 1 | **28932 / 0 / 1312985 / 1** |
| `csv_geometric_10000` | 298937 / 0 / 13653895 / 7 | 348951 / 50014 / 16054567 / 8 | **298937 / 0 / 13653895 / 7** |
| `csv_records_1000x5` | 14107 / 0 / 891117 / 0 | 20137 / 6030 / 1180557 / 1 | **14107 / 0 / 891117 / 0** |
| `csv_records_1000x20` | 37124 / 0 / 3438734 / 2 | 62169 / 25045 / 4672894 / 3 | **37124 / 0 / 3438734 / 2** |
| `csv_records_presized_1000x20` | 31124 / 0 / 2718734 / 2 | 52169 / 21045 / 3728894 / 2 | **31124 / 0 / 2718734 / 2** |
| `csv_records_10000x5` | 140115 / 0 / 9113829 / 3 | 200145 / 60030 / 11995269 / 5 | **140115 / 0 / 9113829 / 3** |
| `csv_records_sample` | 146 / 0 / 7632 / 0 | 194 / 48 / 9936 / 0 | **146 / 0 / 7632 / 0** |
| `hashtable_build_1000` | 28 / 0 / 98824 / 0 | 44 / 16 / 99720 / 0 | **28 / 0 / 98824 / 0** |
| `hashtable_build_10000` | 37 / 0 / 787168 / 0 | 59 / 22 / 788400 / 0 | **37 / 0 / 787168 / 0** |
| `hashtable_build_50000` | 46 / 0 / 6292408 / 2 | 74 / 28 / 6293976 / 2 | **46 / 0 / 6292408 / 2** |

By kind (unchanged List/MutableArray/String/StringPlan, for example
`csv_geometric_10000`: List 10006, MutableArray 30027, String 248904,
StringPlan 10000 in all three trees; Struct 0 / 50014 / 0). No List, String or
MutableArray behavior was altered to get these numbers.

## Comparison with the pre-struct parent

**Yes: the typed struct program recovers the old positional-product allocation
behavior exactly** (every count above), with real structs, typed fields and
nominal identity kept. Code: `csv` 5723 B (parent 5723), `csv_chunked` 10168
(10168), `csv_geometric` 7578 (7578), `hashtable` 12732 (12732), `csv_records`
23245 B against 23650 B (smaller, from the removed `listget` range checks and
kind guards the struct refactor already saved). Whole corpus machine code: 103751 B (structs)
to 102412 B (-1.3%).

## Machine code

Annotated (`audit/struct-scalar-replacement/out/asm/`, `objdump -dr`, Intel
syntax):

`scan_unquoted` before (`-struct-opt 0`), the return path:

```
mov  QWORD PTR [rsp+0x30],rax     ; field  -> a 2-slot array on the stack
mov  rsi,QWORD PTR [rsp+0x48]
mov  QWORD PTR [rsp+0x38],rsi     ; index
mov  esi,0x1 ; mov edx,0x2        ; shape 1, 2 fields
mov  rdi,r14
call rt_struct_new                ; one heap allocation per result
... epilogue, ret                 ; returns the object pointer
```

after:

```
mov  rdx,QWORD PTR [rsp+0x38]     ; second value in rdx, first already in rax
... epilogue, ret                 ; no rt_struct_new, no allocation
```

| function (csv_records) | `rt_struct_new` before -> after | `structget` | instructions before -> after |
|---|---|---|---|
| `scan_unquoted` | 1 -> 0 | 0 | 140 -> 124 |
| `scan_field` | 0 -> 0 (forwards two results) | 0 | 91 -> 87 |
| `scan_record_rest` | 2 -> 0 | 2 -> 0 | 202 -> 171 |
| `ht_rehash` | 2 -> 0 | 3 -> 0 | 165 -> 149 |
| `ht_rehash_insert` | 0 | 3 -> 0 | 98 -> 100 |
| `ht_rehash_scan` | 0 | 3 -> 0 | 167 -> 196 (3 more parameters per struct) |

## Width experiments

`audit/struct-scalar-replacement/tools/probes.tcl` (`out/probes-width.txt`):
a counted loop of 200000 iterations builds one struct of W fields and consumes
every field, in three directions; tiny-leaf inlining is off so the boundary
stays a call. p / v / d = physical (`-struct-opt 0`) / virtual with every cap
raised to 32 / the shipped policy. "fn code" is the bytes of the two functions
under test, "stack ops" counts `[rsp+..]`/`[rbp-..]` operands in their machine
code (a mechanical spill indicator).

| probe | struct allocs p/v/d | fn code bytes p/v/d | stack ops p/v/d | ns/iter p/v/d |
|---|---|---|---|---|
| width-0 return | 200000/200000/200000 | 207/207/207 | 8/8/8 | 42.1/42.5/42.3 |
| width-0 argument | 200000/200000/200000 | 303/303/303 | 10/10/10 | 42.6/43.0/42.5 |
| width-0 local | 200000/0/0 | 160/77/77 | 6/0/0 | 38.6/0.6/0.6 |
| width-1 return | 200000/0/0 | 302/263/263 | 12/9/9 | 80.8/1.9/1.9 |
| width-1 argument | 200000/0/0 | 418/341/341 | 20/12/12 | 80.9/2.7/2.7 |
| width-1 local | 200000/0/0 | 268/200/200 | 14/7/7 | 82.0/1.2/1.2 |
| width-2 return | 200000/0/0 | 444/351/351 | 19/12/12 | 82.4/2.9/2.8 |
| width-2 argument | 200000/0/0 | 550/483/483 | 27/18/18 | 83.3/4.2/4.2 |
| width-2 local | 200000/0/0 | 389/319/319 | 20/12/12 | 84.0/2.1/2.1 |
| width-3 return | 200000/0/0 | 541/472/472 | 22/18/18 | 82.5/4.1/4.2 |
| width-3 argument | 200000/0/0 | 666/595/595 | 32/22/22 | 83.0/5.3/5.3 |
| width-3 local | 200000/0/0 | 476/424/424 | 23/17/17 | 82.7/3.5/3.4 |
| width-4 return | 200000/0/0 | 644/604/604 | 25/29/29 | 81.1/5.2/5.2 |
| width-4 argument | 200000/0/0 | 785/724/724 | 36/26/26 | 84.0/6.6/6.6 |
| width-4 local | 200000/0/0 | 588/516/516 | 26/25/25 | 81.6/4.2/4.1 |
| width-6 return | 200000/0/0 | 833/835/835 | 31/37/37 | 89.0/7.6/7.6 |
| width-6 argument | 200000/0/200000 | 1010/984/1010 | 44/42/44 | 89.4/9.1/89.0 |
| width-6 local | 200000/0/0 | 813/774/774 | 32/39/39 | 90.4/6.3/6.3 |
| width-8 return | 200000/0/0 | 1070/1080/1080 | 39/45/45 | 90.1/9.5/9.4 |
| width-8 argument | 200000/0/200000 | 1206/1265/1206 | 52/63/52 | 90.0/11.2/92.8 |
| width-8 local | 200000/0/0 | 1028/1022/1022 | 38/55/55 | 89.9/8.7/8.7 |
| width-16 return | 200000/0/200000 | 2049/2006/2049 | 81/77/81 | 105.7/20.5/108.4 |
| width-16 argument | 200000/0/200000 | 2184/2789/2184 | 105/183/105 | 112.3/24.1/111.1 |
| width-16 local | 200000/0/0 | 2058/2064/2064 | 96/99/99 | 108.8/17.8/17.5 |

Reading: transport by fields is far cheaper than the object at every width in
this runtime (the allocation costs ~80-110 ns here; GC included), so runtime
alone would argue for uncapped virtualization. The code and stack columns are
what the caps are about. Returns: fewer stack operands than physical up to 3
fields, +4 at 4, +6 at 6 and 8, and fewer again at 16 (77 against 81), code
within +-1%. Arguments: fewer code bytes and stack operands up to 6 fields, then
8 fields cost +59 B (+4.9%) and 52 -> 63 stack operands and 16 cost +605 B
(+27.7%) and 105 -> 183. Locals are flat up to 16 (+0.3% code, +3 stack
operands). The initial policy is (local 16, return 8, argument 4); it is not
tuned to the microbenchmark, whose winner is always the virtual form.

## Distance experiments

Non-optimizing probes (`out/probes-distance.txt`): a struct built at the top
and projected after D forwarding calls, narrow (2 fields) and wide (8), in both
directions. The implementation is only required to optimize distance 0/1; the
forwarding machinery carries narrow structs through longer chains
incidentally.

| probe | struct allocs p/v/d | fn code bytes p/v/d | stack ops p/v/d | ns/iter p/v/d |
|---|---|---|---|---|
| distance-0 width-2 return | 200000/0/0 | 99/36/36 | 4/0/0 | 84.4/2.9/2.9 |
| distance-0 width-2 argument | 200000/0/0 | 226/225/225 | 7/6/6 | 83.1/4.2/4.1 |
| distance-1 width-2 return | 200000/0/0 | 142/56/56 | 4/0/0 | 85.3/3.4/3.4 |
| distance-1 width-2 argument | 200000/0/0 | 278/289/289 | 8/8/8 | 84.0/5.1/5.1 |
| distance-2 width-2 return | 200000/0/0 | 185/76/76 | 4/0/0 | 85.0/3.9/3.9 |
| distance-2 width-2 argument | 200000/0/0 | 330/353/353 | 9/10/10 | 86.1/7.4/7.5 |
| distance-4 width-2 return | 200000/0/0 | 271/116/116 | 4/0/0 | 88.5/5.7/5.7 |
| distance-4 width-2 argument | 200000/0/0 | 434/481/481 | 11/14/14 | 87.7/12.0/12.1 |
| distance-8 width-2 return | 200000/0/0 | 443/196/196 | 4/0/0 | 95.2/10.1/10.2 |
| distance-8 width-2 argument | 200000/0/0 | 642/737/737 | 15/22/22 | 94.6/21.4/21.2 |
| distance-0 width-8 return | 200000/0/0 | 266/135/135 | 18/0/0 | 93.2/9.4/9.5 |
| distance-0 width-8 argument | 200000/0/200000 | 708/871/708 | 20/40/20 | 92.2/11.2/94.8 |
| distance-1 width-8 return | 200000/0/0 | 309/244/244 | 18/8/8 | 96.6/11.5/11.7 |
| distance-1 width-8 argument | 200000/0/200000 | 760/1078/760 | 21/63/21 | 92.3/13.6/90.1 |
| distance-2 width-8 return | 200000/0/0 | 352/353/353 | 18/16/16 | 93.0/14.1/20.4 |
| distance-2 width-8 argument | 200000/0/200000 | 812/1285/812 | 22/86/22 | 93.6/16.8/102.5 |
| distance-4 width-8 return | 200000/0/0 | 438/571/571 | 18/32/32 | 99.3/19.7/19.9 |
| distance-4 width-8 argument | 200000/0/200000 | 916/1699/916 | 24/132/24 | 95.0/24.8/96.5 |
| distance-8 width-8 return | 200000/0/0 | 610/1007/1007 | 18/64/64 | 105.1/31.9/31.6 |
| distance-8 width-8 argument | 200000/0/200000 | 1124/2527/1124 | 28/224/28 | 103.5/42.8/104.7 |

Reading for the next milestone: for a narrow struct, transport by fields wins
at every distance in both directions and its code cost is small (argument
chains: +3% bytes, 15 -> 22 stack operands at D=8). For a wide struct,
returns are cheap (D=8: +36% bytes, 18 -> 64 stack operands, still 3x faster)
but argument transport compounds: 8 fields at D=8 costs +76% bytes and 28 ->
224 stack operands for a 2.4x speedup. The per-hop cost is proportional to
width in both directions (every hop re-passes every field), while the physical
object costs one pointer per hop plus one allocation: the break-even depends
on the allocation cost (here large) against width x distance. The shipped caps
keep a struct wider than its boundary's cap (arguments > 4, returns > 8)
physical at every distance, so a wide struct never pays per-hop field copies;
the wide cases are the ones that can regress under a cheaper allocator.

## Nesting experiments

`out/probes-nesting.txt`: flat 4 fields; `{a, b, inner: {c, d}}`;
`{left: {a, b}, right: {c, d}}`.

| probe | struct allocs p/v/d | fn code bytes p/v/d | stack ops p/v/d | ns/iter p/v/d |
|---|---|---|---|---|
| nesting-flat4 return | 200000/0/0 | 640/600/600 | 25/29/29 | 80.3/5.1/5.2 |
| nesting-flat4 argument | 200000/0/0 | 780/719/719 | 35/25/25 | 81.3/6.6/6.7 |
| nesting-flat4 local | 200000/0/0 | 588/516/516 | 26/25/25 | 83.0/4.2/4.2 |
| nesting-inner1 return | 400000/200000/200000 | 771/703/703 | 38/42/42 | 176.8/86.9/88.2 |
| nesting-inner1 argument | 400000/200000/200000 | 909/782/782 | 53/34/34 | 165.7/87.2/85.1 |
| nesting-inner1 local | 400000/200000/200000 | 740/608/608 | 46/39/39 | 165.6/83.1/82.9 |
| nesting-inner2 return | 600000/400000/400000 | 837/763/763 | 41/41/41 | 252.2/164.1/168.5 |
| nesting-inner2 argument | 600000/400000/400000 | 1022/947/947 | 63/56/56 | 247.2/171.5/162.7 |
| nesting-inner2 local | 600000/400000/400000 | 810/721/721 | 53/47/47 | 242.8/165.9/163.7 |

One-hop virtualization opens the outer struct only: `inner1` allocates 1
struct per iteration instead of 2, `inner2` 2 instead of 3, while the flat
4-field form allocates 0. Recursive flattening would transport 4 fields in all
three (the same width as the flat struct, *not* a larger width: here each
inner struct is only projected) and would remove the remaining allocations (86
ns -> 5 ns per iteration for `inner1`); it would also transport every nested
struct's fields at every boundary regardless of use, which is the width
explosion the nesting rule forbids. The general nesting frontier (open an
inner literal when it is only projected; keep it when it flows elsewhere) is
left to the next milestone.

## Compile-time impact

`audit/struct-scalar-replacement/tools/compile-split.tcl`, median of 3
interleaved rounds x 7 runs, the structs tree ("before") against this tree,
whole canonical corpus, milliseconds:

| stage | before | after | change |
|---|---:|---:|---:|
| specialization (`hir::specialize::analyze`) | 471.7 | 475.3 | +1% |
| **representation analysis** (`hir::escape::analyze`) | 222.0 | 275.4 | +24% |
| NIR lowering end to end (`native::lower::program`, includes both above) | 1981.9 | 2058.5 | +4% |
| Cranelift JIT | 131.1 | 130.5 | -0% |

The representation analysis grows +53 ms over 17 programs (`csv_geometric`
8.2 -> 16.4 ms, `csv_records` 109.7 -> 125.2 ms, `hashtable` 47.4 -> 49.3 ms;
the struct-free programs +0.1 to +1 ms), about 3% of native compile time
overall. There is no new global fixed point: per-expression scans, per-function
planning and exact call-edge inspection only.

## Runtime impact

Best of 15 per round, three interleaved rounds (parent / structs / after in
turn), minimum and median over the rounds, microseconds
(`out/workloads-compare.txt`):

| workload | parent min / med | structs min / med | after min / med | after vs structs (min / med) | after vs parent (min / med) |
|---|---|---|---|---|---|
| `csv_geometric_100` | 298.7 / 302.0 | 324.8 / 329.5 | 301.7 / 304.5 | -7.1% / -7.6% | +1.0% / +0.8% |
| `csv_geometric_1000` | 4285.2 / 4330.6 | 4696.2 / 4702.4 | 4385.9 / 4464.7 | -6.6% / -5.1% | +2.3% / +3.1% |
| `csv_geometric_10000` | 57963.1 / 62538.6 | 75185.0 / 77382.9 | 60129.5 / 65608.4 | -20.0% / -15.2% | +3.7% / +4.9% |
| `csv_records_1000x5` | 2863.2 / 2903.8 | 3875.3 / 3924.0 | 2938.9 / 3039.2 | -24.2% / -22.5% | +2.6% / +4.7% |
| `csv_records_1000x20` | 13541.1 / 14335.2 | 17202.2 / 17211.1 | 14534.2 / 14936.5 | -15.5% / -13.2% | +7.3% / +4.2% |
| `csv_records_presized_1000x20` | 12305.6 / 12348.3 | 13978.4 / 15493.5 | 11616.7 / 11703.2 | -16.9% / -24.5% | -5.6% / -5.2% |
| `csv_records_10000x5` | 40436.5 / 41837.9 | 52511.1 / 56648.6 | 38131.6 / 38733.4 | -27.4% / -31.6% | -5.7% / -7.4% |
| `csv_records_sample` | 19.4 / 19.5 | 21.8 / 21.9 | 19.5 / 19.6 | -10.8% / -10.5% | +0.3% / +0.3% |
| `hashtable_build_1000` | 283.3 / 283.6 | 281.9 / 286.1 | 282.6 / 283.1 | +0.2% / -1.0% | -0.3% / -0.2% |
| `hashtable_build_10000` | 3085.9 / 3145.4 | 3097.3 / 3105.5 | 3081.9 / 3083.9 | -0.5% / -0.7% | -0.1% / -2.0% |
| `hashtable_build_50000` | 24039.4 / 25467.6 | 23898.2 / 24261.4 | 23246.9 / 25020.4 | -2.7% / +3.1% | -3.3% / -1.8% |

The workloads that regressed from struct allocation recover: -6.6% to -27.4% against
the structs milestone on every CSV workload, and within noise of (or below) the
pre-struct parent. The hashtable workloads are unchanged (two structs per
rehash were never a measurable cost; Struct 28 -> 0 at 50000 inserts).

## GC stress

Whole suite with `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempted at every
allocation site), on the final tree (`out/gc-stress.txt`): interp **3487 passed,
0 failed**; compile **3483 passed, 4 skipped, 0 failed**. This includes the new
`sr-gc-*` tests (pointer-bearing fields: `String`, `List`, `MutableArray`,
nested struct, across an exact call, across an exact return, materialization
after a safepoint) and the real CSV, HashTable and test-selection workloads in
their scalar-replaced form. The differential fuzzer (`tools/fuzz.py`, `fuzz.tcl`:
random programs that build, alias, project, merge with `if`, pass, return and
store structs of 1-4 fields, named and anonymous, with side effects) agreed
on all 291 compilable programs of a plain run (interpreter, native optimized,
native `-struct-opt 0`; 225 of them with fewer `structnew`) and all 98 of a run
under GC stress: 0 mismatches.

## Standalone executable parity

`sr-executable-parity`: five optimized programs (strings, across-return,
across-call, materialize-after-safepoint, nested) are linked as real
executables (`native::executable`), run with an empty PATH, plainly and with
`BOTLISH_NATIVE_GC_STRESS=1`, and compared with the interpreter's value:
identical. The pre-existing `struct-executable-*` tests pass.

## Full regression

Final tree (`out/regression-after.txt`; the parent fence is the structs
milestone, 3403 / 3399+4 skipped):

| | structs milestone | after |
|---|---:|---:|
| interp | 3403 passed, 0 failed | **3487 passed, 0 failed** |
| compile | 3399 passed, 4 skipped, 0 failed | **3483 passed, 4 skipped, 0 failed** |
| GC stress interp / compile | 3403 / 3399 (+4 skipped), 0 failed | **3487 / 3483 (+4 skipped), 0 failed** |

+84 tests (`struct-scalar-replacement.test`); three existing tests were
repinned because they pinned the *old* behavior this milestone changes
(`escape-csv-3`, `paramagg-hashtable-2`, and the three NIR-shape tests in
`structs.test` now lower with `-struct-opt 0` to keep testing shapes; the
stdlib/parity tests are untouched).

**Native coverage** (`tests/native-coverage.tcl`, `out/native-coverage-after.txt`):

| class | structs milestone | after |
|---|---:|---:|
| native | 1264 | 1334 |
| independent | 2082 | 2095 |
| passed-partial | 40 | 41 |
| unsupported | 49 | 49 |
| failed | 1 | 1 |
| tests | 3436 | 3520 |

The `unsupported` set is the same 49 tests for the same constructs, and the one
`failed` is the same pre-existing `refined-5`.

**Rust** (`cargo test --release --manifest-path native/Cargo.toml`,
`out/cargo-test.txt`): 56 + 22 = 78 passed, 0 failed (no Rust code changed).

## Benchmark/corpus parity

`tclsh9.0 bench/bench.tcl -runs 1` (`out/bench-runs1-after.txt`) runs the
eight canonical programs on every backend and aborts on a value disagreement: it
completed. `tclsh9.0 bench/corpus.tcl -runs 1` (`out/corpus-runs1-after.txt`):
every algorithm/input row reports `agree` across interp, compile,
cranelift-generic and cranelift (18 of 18). Performance conclusions in this
report come from the dedicated workload harness, not these runs.

## Known limitations

* Zero-field structs are virtual locally but materialize across a boundary.
* Equality, hashing and printing of a struct materialize it. Investigated:
  struct equality is slot-by-slot short-circuiting `equal` with a shape check
  (`runtime/ops.rs`), so two virtual structs of one statically known shape
  *could* compare field-wise with the existing `veq` and a short-circuit chain
  with identical semantics (errors included); not implemented (nice to have;
  the corpus has no such site).
* A call wrapped in a `handle` (`r = f(): on E: ...`) is not recognized as a
  virtual producer (the bound value is the handle), nor is a struct literal in
  a handler body.
* A struct *parameter* with a physical use inside its callee is not virtualized
  (its callers keep passing the object): a per-call re-allocation would
  otherwise move the cost.
* A nested struct is one field value (see "Nesting experiments"): an inner
  literal that is only projected is still built.
* Virtual across a call only for exact closed callees; `callvalue`, unknown
  targets and natives materialize first (no native ABI changed).
* No inline List/MutableArray element layout, no loop-carried aggregate
  scalarization beyond what the self-tail `fields` variant already threads
  through the backedge (a struct rebuilt each step of a self-tail loop crosses
  as fields: `sr-argument-self-recursion`).
* `cranelift-generic` (`-specialize 0`): **unchanged**. Its known limitation
  (a projection proven only by a semantic instance is not compiled) remains;
  to keep that, no struct crosses a boundary as fields in a generic
  instance (`hir::escape` refuses generic instances for struct results and
  parameters; locals are virtual in both modes, as they project a statically
  known struct in both). `struct-native-unknown-shape-unsupported` still passes.
* The width caps are a static policy, not a cost model; distance is not
  measured by the analysis.
* The Core IR interpreter and the Tcl compiler still materialize every struct
  (by design: representation differs, values agree).

## Readiness for the transport/materialization cost model

What exists: a descriptor per value (`{N SHAPE}`) that survives as metadata
without an object; a per-use classification (`UseVerdict`: free, materializing,
blocking; with a reason tag) in one place; lazy single materialization with
dominance-correct reuse; `fields` variants and `retmulti` companions that
already compose over chains; per-boundary width caps as options; the census
(which constructions were virtualized, across what, materialized for which
reason); the probes and their data.

What the next optimizer should consume: the transport-distance data above
(narrow structs win at every distance; wide argument transport compounds
linearly in width x distance while the object costs one pointer per hop), the
return/argument asymmetry (returns are cheap in code and stack at widths where
arguments are not), the nesting data (flat transport of a projected-only inner
struct removes the remaining allocations), and the census' reason histogram for
deciding where the cheapest place to stop being virtual is.

## Answers to the required questions

**Architecture.**
1. *Where is struct virtuality represented?* In `hir::escape`'s analysis
   (descriptors `{N SHAPE}` per binding, parameter and instance result) and,
   during lowering, as `{virtual FIELDS SHAPE ROOT MAT}` entries in
   `native/lower.tcl`'s `fn locals`.
2. *Does HIR change?* No. No HIR file was touched; `struct`/`project` remain.
3. *Does NIR contain explicit virtual structs?* No; only field registers,
   `callmulti`/`retmulti` and `fields` variant signatures.
4. *What does `structnew` mean now?* An actual physical materialization.
5. *Can a semantic struct exist without any `structnew`?* Yes.

**Analysis.**
6. *How is it decided a struct may stay virtual?* `UseVerdict` over every
   reference: projections, aliases, exact forwards and branch/return joins are
   free; other uses materialize lazily (locals only) or block (parameters),
   subject to the width caps and the loop rule.
7. *Aliases:* by binding identity; source and alias share one root entry and one
   materialization, and stand or fall together.
8. *What forces materialization?* See "Materializing uses".
9. *Can materialization be later than construction?* Yes, at the first use that
   needs the object.
10. *Is materialization reused?* Yes, in every scope the first materialization
    dominates; branches/loops/protected calls never leak one to a path it does
    not dominate.

**Calls.**
11. *Can a two-field struct cross one exact return boundary without allocation?*
    Yes (`sr-return-anonymous`, CSV).
12. *Physical return representation:* `results=N` companion, `retmulti` of the
    fields, read through `callmulti`; in machine code the values in `rax`/`rdx`
    (and further return registers).
13. *Can it cross one exact forward-call boundary without allocation?* Yes
    (`sr-argument-anonymous`, rehash `src`/`dest`); chains of exact calls incidentally.
14. *Width cap/policy:* local 16, return 8, argument 4 (options).
15. *Unknown/dynamic calls:* materialize first (`sr-argument-open-call-materializes`).

**Nesting.**
16. *Recursively exploded?* No.
17. *What is one transported field?* A nested struct (an ordinary value).
18. *What prevents width explosion?* Only the outer descriptor's fields are
    transported, the caps apply to it, and nested structs are never opened.

**GC.**
19. *How are pointer-bearing fields rooted?* As ordinary registers, by the
    existing liveness (each field independently).
20. *Across safepoints?* Each field is live until its last use (a projection or
    the materialization); the non-existent object plays no part.
21. *Materialization after a safepoint:* `structnew` reads the registers that
    stayed live; its own allocation is a safepoint with those operands live.
22. *Tests:* the `sr-gc-*` set under GC stress, `sr-executable-parity`, the fuzz
    runs under stress, and the whole suite under GC stress.

**CSV.**
23. *Scan-result structs semantically:* 6/6/4/4 per program (instances x sites,
    4/4/4/4 source sites for the scan results).
24. *Physical Struct allocations:* 0 on every workload.
25. *Multi-value return again?* Yes: `callmulti` 57, `retmulti` 50 corpus-wide.
26. *Caller projections direct?* Yes (`structget` 0).
27. *Large allocation regressions:* fully recovered; counts equal the parent's.
28. *Runtime:* -6.6% to -27.4% against the structs milestone; within noise of the
    parent.

**Hashtable.**
29. *Do `src`/`dest` still allocate wrappers during rehash?* No.
30. *(If yes, what forces them:)* with `-param-aggregate-opt 0` the call to
    `ht_rehash_scan` (its parameter cannot receive fields).
31. *How are the three fields transported?* As 3 parameters each of
    `ht_rehash_scan` and `ht_rehash_insert` (`src.0 src.1 src.2`, `dest.0 ...`).

**Control.**
32. *Does `List[Test]` still hold materialized struct values?* Yes (15/15).
33. *Why is that appropriate?* They are genuine stored domain values; storage
    into a List is a materialization boundary this milestone (no inline element
    layout).
34. *Did equality/hash change?* No.

**NIR.**
35. `structnew` 39 -> 15. 36. `structget` 52 -> 2. 37. `callmulti` 29 -> 57.
38. `retmulti` 18 -> 50. 39. Virtual projections are absent as `structget`:
yes. 40. New aggregate runtime object: no.

**Performance.**
41. *Struct allocations:* 514..60030 -> 0 on every workload (parent: 0).
42. *Total bytes:* e.g. `csv_geometric_10000` 16054567 -> 13653895 (= parent).
43. *GC cycles:* 8 -> 7, 1 -> 0, 3 -> 2, 5 -> 3 (= parent).
44. *Code size:* parent's bytes or below (see above); whole corpus -1.3%.
45. *Runtime on large CSV workloads:* see the runtime table.
46. *New spills in wider-return probes?* Slightly: stack operands of the two
    functions are 25 -> 29 at 4 fields, 31 -> 37 at 6, 39 -> 45 at 8 (code
    within +-1%), and fewer at 16 (81 -> 77). The argument direction spills more
    from 8 fields (52 -> 63; 16: 105 -> 183).
47. *Evidence for the next optimizer:* see "Readiness".

## Files

`hir/escape.tcl` (generalized analysis, census), `native/lower.tcl`
(lowering, options), `native/native.tcl` (`structCensus`, `structCensusText`),
`tests/struct-scalar-replacement.test` (84 tests), repinned
`tests/structs.test`, `tests/native-escape.test`,
`tests/native-param-aggregate.test`, and `audit/struct-scalar-replacement/`
(tools and measured outputs). No `.bot` source, typing, HIR, Core IR, runtime
or Cranelift code changed.
