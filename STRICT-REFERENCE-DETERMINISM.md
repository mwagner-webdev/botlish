# Strict reference determinism

## Outcome

```
a lexical binding becomes visible when it is established
```

Ordinary forward references are now illegal, and resolution (not typing, not
the specializer) enforces it. Name resolution walks the source once, in
evaluation order, over scopes that start empty; a `bind` adds its binding
when the walk reaches it, after its value has been resolved. Nothing later in
a scope exists yet, so a reference's target, identity, environment and
contract are fixed by the source before it (plus the self-binding of a named
function). Nothing is hoisted, predeclared, sorted, repaired or patched.

Results on the canonical corpus (17 bench/stdlib programs, already written
callee-first): semantic instances, AOT classification, NIR and scalar
assembly are **byte-identical** to the parent commit. The incident shape
(`scan_record` before `scan_record_rest`) is rejected at the reference. The
full suite passes on both Tcl backends (interp 3249/3249, compile 3245 passed
+ 4 interpreter-only skips, 0 failures), and `bench/bench.tcl -runs 1` shows
backend agreement on every canonical program.

The only real-source casualty is `examples/surface/09-mutual-recursion.bot`,
a language *demonstration* of the removed behavior (not stdlib, not a
benchmark); it is now a rejection example. No canonical source used mutual
recursion or a forward reference (see the census), so there was nothing to
stop on under item 27. Two things are reported honestly rather than removed:
a semantic-instance retry path that is **not** forward-specific (see
"Semantic-instance simplification"), and the interpreter's own declare-on-entry
scoping, which Core IR keeps (see "Core IR boundary").

## Semantic rule

Bindings are visible from their definition onward. Named functions may call
themselves recursively. A function or value may not refer to a later binding
in the same lexical scope. Mutually recursive definitions require a future
explicit mechanism; ordinary bindings are not hoisted. (README §16 and §17
carry the same note.)

## Why forward references were removed

The CSV source draft that defined `scan_record` before its callee produced
drastically more retained generic instances, guards and emitted functions
than the callee-first order, with no difference in the semantic-instance
population. Later definitions were repairing information earlier stages did
not have. Measured on `csv_records.bot` (old compiler; see
`audit/strict-reference-determinism/out/definition-order-experiment.txt`):

| shape | rounds | codegen instances | emitted functions | AOT closed/guarded/open | guards |
|---|---|---|---|---|---|
| A callee-first (canonical) | 1 | 66 | 63 | 49/17/0 | 28 |
| B caller-before-callee | 2 | **90** | **85** | 56/**34**/0 | **56** |
| C alternative legal order | 1 | 66 | 63 | 49/17/0 | 28 |

The desired fix is not a smarter hoist; it is that later bindings do not
exist.

## Before architecture

* `hir::resolve` declared every name a scope binds *on entry* (a whole-scope
  symbol table, `Declare` over `scopeBindNames`), tracked a `bound` set, and
  gave each reference an `init` state: `yes`, `no` (used before its binding,
  a static error) or `deferred` (inside a closure: decided when it runs).
* A `deferred` reference to a later function typed as
  `hir::types::ForwardType` (`{block E ARITY any}`), `hir::callables`
  had a special check for the resulting erased alias, `hir::semantic` could
  decline an instance for lack of a creation environment ("no-env") and
  re-walk the whole program, `hir::aot` computed `unprovenReferences` /
  `InitProven` / *cells* / `init-check` facts, and native lowering,
  `hir::blockescape`, `hir::construction` and the Tcl compiler each carried
  cell / unproven handling.

## After architecture

```
source -> sequential lexical resolution -> resolved HIR (no forward refs)
       -> types / semantic analysis -> specialization -> NIR
```

* Scopes start empty (parameters, a loop's element/induction binding).
  `hir::resolve::Establish` adds a `bind`'s binding after resolving its
  value; a `bind` whose value is a block (a named function) is established
  *before* the block is resolved, so the body reaches the function through
  its own binding (direct self-recursion), and nothing else.
* An unresolvable name is `UNBOUND` at the reference: `binding` is empty, the
  reference is typed `never`, and no placeholder identity, type or patch
  exists.
* `init` is `yes` for every resolved reference, `deferred` only for an
  ambient (sequence-mode) binding.
* A strict build stops after resolution when it failed
  (`hir::buildSyntax`, `-strict 1`, and `-halt-on-resolution-errors` for the
  source frontend, which adds source locations): a program that does not
  resolve is never typed, analyzed, specialized or lowered.

## Binding visibility rules (audit, item 17)

| construct | its binding is visible |
|---|---|
| `x = e` | after `e` is resolved, for the rest of the scope and nested scopes |
| `fn f(...)` | before its own body is resolved (self-recursion); to later code after the declaration |
| parameters | from function-body entry |
| `loop x in xs` / `loop i from a to b` | element / induction binding from body entry; the header (iterable, bounds) resolves in the enclosing scope |
| `if` / `else`, `loop`, `handle ... on E` bodies | own scope; bindings made inside are sequential and do not escape |
| module top level | sequentially, like any scope; a module's section is resolved completely before any section or program naming it |
| `mod::name` (qualified) | always an already-established binding of another, already resolved unit |
| type declarations, `error` declarations | **not** value bindings: order-independent compile-time declarations registered before resolution (`hir::sourcetypes`, `hir::errordecls`); they have no binding identity and cannot affect reference resolution |
| module / namespace machinery | no hoisting route: sections are resolved dependencies-first, each in its own source order |

## Named self-recursion

`fn f` establishes `f` (a `bind` whose value node is a block literal) before
its block is resolved. The body's reference is the *same binding id* as the
declaration's (`tests/strict-references.test`, `sr-self-binding-identity`:
same binding, in the block's captures, call target `{block <this block>}`).
Inference gives the self-binding the block's own exact type under an assumed
result (`hir::types::Block`); nothing needs `ForwardType`. There is no
anonymous function expression in the surface language (`f = fn(x): ...` is a
syntax error), so a value never gains a self-binding merely because it is a
function.

## Mutual recursion

Not supported. One edge of any lexically mutually recursive pair points
forward, so the program is rejected (unbound name, "declared later"). No
`let rec`, prototypes, forward declarations, hoisted tables or SCC
declarations were added. Functions that reach each other *through arguments*
(`ping(pong, ...)`) are still legal and still form genuine instance cycles;
see "Semantic-instance simplification".

## Anonymous function initialization

Not expressible, as above. A bound value is not visible in its own
initializer (`x = x + 1` reads an outer `x` or fails).

## Closures / capture

A closure captures the environment that exists where it is created. Forward
capture is a resolution error before any type analysis; there is no
"captured as `any`, repaired later".

## Shadowing

A later same-named binding in a nested scope never changes an earlier
reference: the early use resolves to the already visible outer binding, the
late use to the new inner binding, for values and for closures (tests
`sr-shadow-*`). The lowered core IR is name-based and the interpreter's scopes
declare names on entry, so `hir::hygiene::ProtectEarlierRefs` renames the
*later* binding (`x#1`, source spelling kept) whenever a name-based lookup of
a reference would find something other than the binding HIR resolved. It
only fires for programs whose meaning changed, i.e. never for a program that
was legal before. A randomized test (120 fixed-seed programs with nested
scopes, shadowing and closures) checks the interpreter (lowered IR), the
compiler from lowered IR and the compiler from HIR agree.

## Module-scope semantics

Same rule as local scope: `a = b` then `b = 3` is rejected. There is no
module-value dependency sorting and no reordering by the compiler; source
order is the binding order.

## External module boundary

A qualified symbol resolves directly against another module's section scope.
That scope is complete because `surface/modules.tcl` resolves a module's
section fully, in its own source order, before any dependent section or
program. This is an established binding of another unit, not a lexical
forward reference, and module discovery is unchanged. Within a module,
definitions are sequential. A module cannot use its own qualified spelling as
an escape hatch: `m::helper` inside module `m` is already a `CYCLE` error
(`sr-module-own-qualified-name-is-no-escape`), so the rule cannot be bypassed
by spelling.

## Resolution implementation

`hir/resolve.tcl`: `Declare` and the `bound` table are gone; `Establish`,
sequential `Lookup`, `init` in `{yes, deferred}`. The diagnostic wording
("declared later; forward references are not allowed") comes from
`LaterNames`, a per-scope index of bind names, computed lazily and only when
an `UNBOUND` diagnostic is written, cached, scope-accurate, dropped before
resolution returns, and never consulted to resolve anything (`sr-decl-hint-*`).
A file with 400 illegal forward references resolves in normal time
(`sr-many-forward-references`). The parser is unchanged: the ban is semantic.

## HIR invariant

Successful HIR contains no reference to a binding established after it,
except a named function's reference to itself. It holds by construction (the
implementation invariant); `hir/refcheck.tcl` (`hir::refcheck::forwardRefs`)
is an independent, cheap post-hoc checker over the HIR's own walk order. It
is not on the compile path. `hir::read` uses it to reject HIR text that names
a binding before its declaration; tests use it as the invariant checker, and
the census used it on the old compiler. Consequence: intra-scope binding
dependencies form a DAG whose edges point backward in source order plus
explicit self-edges.

## ForwardType removal / simplification

`hir::types::ForwardType` is deleted. The one thing it served besides
forward references was the default `any` for a binding with no type on the
path (an untyped parameter, a local whose initializer never completes); that
is now the explicit final `return any` of `BindingType`. A named function's
own binding type in creation environments (region seeds, `RecordEnv`) is
supplied explicitly (`Block`'s `selfType`).

## Semantic-instance simplification

Kept, on evidence: the `no-env` decline and the whole-program re-walk
(`hir::types::infer`, `hir::semantic::WantsRerun`). They are **not** only for
forward references. A recursive function whose *declared result type* makes
its recursive call answerable at once requests an instance of itself while
its own generic walk has not yet reached a nested closure it creates:

```
fn f(n) -> int:
    if n == 0: return 0
    r = f(n - 1)
    fn g(x): x + n
    g(1) + r
```

walks twice (test `si-dyn-5`). The old compiler does the same, so this was
never definition-order sensitivity. The comments now say so. Definition order
alone can no longer cause a decline: a call always follows the binding, and
the binding's walk, of what it calls. The environment-*revision* path
(`RecordEnv` re-queuing instances when an enclosing recursive function's later
attempt types a captured binding differently) also belongs to recursion
fixpoints, not forward references, and stays.

Also kept, and why: the SCC / worklist machinery of `hir::semantic`,
`hir::specialize`, `hir::signatures`, `hir::escape`, `hir::stringregion` still
has legal work. Instance cycles arise without any lexical forward reference
from self recursion across different keys (`depth([x], n - 1)`) and from
functions passing each other as arguments (`ping(pong, ...)`; test
`si-rec-2b` proves a real reader cycle). Lexical mutual recursion, the
part that is gone, was one *source* of such cycles, not the only one.

Capture-environment information can no longer be revised because a later
lexical binding appeared: environments only gain entries through establishing
binds that precede the creation site.

## Whole-program walk simplification

Corpus census: 17 walks, 1 per program, no no-env declines, unchanged from
before (the corpus was callee-first). The retry loop stays for the recursive
case above and is bounded by `maxRounds`.

## Specializer implications

Nothing was added to retain future declarations. The specializer now only
receives resolved HIR whose exact references target established bindings. The
forward-only pieces around it were deleted (cells/unproven, `NeedsCell`, the
cell case of construction eligibility, `MaterializedByRef`'s cell test). The
old instance-explosion behavior for caller-before-callee (90 vs 66 codegen
instances) is unreachable: that program is rejected.

## Forward-reference census

Before (pre-change compiler; `audit/strict-reference-determinism/out/`):

| source area | accepted forward references |
|---|---|
| stdlib (`lib/`) | 0 |
| canonical corpus (`examples/stdlib/`, 9 programs) | 0 |
| benchmarks (`bench/*.bot`, `bench/*.ir`) | 0 |
| language demonstrations (`examples/surface/`) | 1 (`09-mutual-recursion.bot`, mutual recursion) |
| HIR fixtures (`examples/hir/07-use-before-binding.hir`) | 2, both already static or deferred errors by design |
| **tests** (whole suite, both backends, distinct references) | **71**, of which **60 accepted** |

Test shapes (distinct): later-sibling-function 16 (accepted), mutual-recursion
32 (accepted), closure-capture-later-binding 16 (12 accepted, 4 were already
static errors), forward-local-value 6 (already static errors),
forward-module-binding 1 (already a static error); no "other". Files: 19
(`compiler-opt`, `native`, `semantic-instances`, `intrinsic-contracts`,
`mutable-array-type`, `hir-*`, `surface-*`, ...).

After: canonical source 0 accepted; corpus census reports `0 forward
reference(s)` for every program, with one `UNBOUND` diagnostic in total (the
deliberate `09` rejection example). Tests contain deliberate rejected
examples only.

## Source migrations (fence amendment)

Dependency-order reordering required: **0 definitions, 0 files** (the corpus
was already callee-first). Changes to source files:

* `examples/surface/09-mutual-recursion.bot`: rewritten as a rejection example
  (`# expect-error: CORE SEMANTIC UNBOUND`, same definitions, explanatory
  header). It is the language demo of the removed behavior, not canonical
  source; report only.
* `examples/stdlib/csv_records.bot`, `csv_geometric.bot`: **comment only** (the
  "definition-order sensitivity" note now says the caller-first order is
  rejected). No function body changed; NIR, asm and AOT digests are identical
  before and after (see below).
* `examples/hir/07-use-before-binding.{hir,ir}` removed (a fixture of the
  removed state; its intent is covered by `hir-resolve-10*` and
  `sr-invariant-checker-finds-violations`); `examples/hir/01..05*.hir`
  regenerated from their `.ir` (binding numbering and the dropped `deferred`
  flag only).

No semantic restructuring was needed; no real mutual recursion appeared. The
source fence for this milestone is this commit; unrelated cleanup was not
combined.

## Definition-order CSV regression

`audit/strict-reference-determinism/experiment/`: A is the current callee-first
`csv_records.bot`, B the caller-first draft, C an alternative legal order of
independent helpers (`scan_quoted` before `scan_unquoted`).

| | old compiler | new compiler |
|---|---|---|
| A | 66 codegen, 63 emitted, 49/17/0, 28 guards, digest `9e68dff7` | same |
| B | 90 codegen, 85 emitted, 56/34/0, 56 guards | **rejected**: `unbound name "scan_record_rest": "scan_record_rest" is declared later; forward references are not allowed` at the call; no semantic analysis, specialization or NIR |
| C | same as A | same as A (digest `9e68dff7`) |

## Legal topological-order determinism

Independent helpers swapped (test `si-det-1`, `ic-order-independent`, and the
C experiment): identical semantic-instance tables, signatures, AOT
classification and canonical NIR (function ids, registers, `@e` tags erased,
callees named). The B order never reaches NIR.

## Semantic-instance census (before = after)

requests 1715, trivial 578, hits 869, created/used 268, recursive 95, body
walks 363, max passes 2, walk rounds 17 (1 per program), no-env declines 0,
budget declines 0, environment revisions unchanged; retained state differs by
262 bytes only because binding ids are numbered differently
(`stateBytes 462464 -> 462726`).

## Specialization / AOT census (before = after)

Used codegen instances 258, emitted functions 247, instances with codegen 193,
AOT closed/guarded/open unchanged (`out/aot-{before,after}.txt` identical),
NIR files identical (`out/nir-digests-*`), scalar assembly corpus
`diff -r` empty.

## NIR effects

For every successful program NIR only reflects already determined references.
Forward-only NIR machinery was deleted: `cell`, `cellset`, `cellget`,
`cellcheck` are no longer emitted by `native/lower.tcl`
(`EnterScope`, `BindingAccess`'s cell, `Ref`'s cellcheck, `Bind`'s cellset,
the cell case of callee/captures). The Rust runtime's cell heap kind and NIR
ops are now unused and left for the native cleanup: this milestone does not
touch Rust or the hybrid/native executable architecture.

## Compile-time effects

Front-end harness (`compiletime.tcl 5`, 3 alternating runs, ms, total over
the 17 programs): before 1733 / 1744 / 1869, after 1920 / 1650 / 1866: no
measurable change, as expected for a corpus that was already callee-first (no
speedup claimed). On the forward-heavy fixture: old compiler compiles B in
751 ms (non-strict front end); the new compiler rejects it in 206 ms in the
default strict mode (parse plus resolution, typing skipped).

## Diagnostics

Primary diagnostic at the illegal reference (`t.bot:2:5`), one
`UNBOUND` and no derivative type noise (`sr-no-derivative-diagnostics`),
optional wording "declared later" only when the same spelling is bound later
in an enclosing scope's own body; an unrelated same-named binding elsewhere
does not trigger it.

## Full regression

`tests/all.tcl`: interp 3249 passed, 0 failed; compile 3245 passed, 4 skipped
(the interpreter-only Core IR scoping tests), 0 failed. Parent commit: 3184 /
3184 on each backend. `tests/native-coverage.tcl` (cranelift over the whole suite):
before 3217 tests (native 1213, independent 1946, passed-partial 8,
unsupported 49, failed 1: `refined-5`), after 3282 tests (native 1226,
independent 1998, passed-partial 8, unsupported 49, failed 1: the same
pre-existing `refined-5`); unsupported classes unchanged
(`out/coverage-{before,after}.txt`). `bench/corpus.tcl` reports `agree` on every
row (`out/corpus-after.txt`). New file: `tests/strict-references.test`
(63 tests: rejections in every scope kind, module boundary, shadowing,
closures, self-recursion identity, `hir::refcheck`, no typing after a strict
resolution failure, randomized agreement). About 45 existing tests that pinned
forward acceptance were replaced by rejection tests or rewritten with legal
equivalents (self recursion, argument-passing cycles, callee-first order).

## Benchmark parity

`bench/bench.tcl -runs 1` completes with all backends agreeing on all eight
canonical programs (`out/bench-after-runs1.txt`, `bench-before-runs1.txt`).

## Compiler complexity removed

Approximately 458 lines deleted and 515 added in `hir/ compiler/ native/
surface/` (167 of the additions are the standalone `hir/refcheck.tcl`, 54 the
hygiene check, ~150 net resolver); the numbers include comments. What
disappeared, functionally:

* `hir::types::ForwardType`; `init no`; the `Declare` / `bound` machinery.
* `hir::callables::CheckReference` and its forward-alias soundness case.
* `hir::aot`: `unprovenReferences`, `InitProven`, `cells`, the `init-check`
  fact and requirement tag.
* `hir::blockescape::NeedsCell`, the cell case of `hir::construction`.
* `native/lower.tcl`: `unproven`, `cells`, `EnterScope` and its 13 callers,
  cell access, `cellset/cellget/cellcheck` emission.
* `compiler/compiler.tcl`: `unproven` and the `init no` branch.
* Tests of forward acceptance (about 45 replaced).

Semantic states now impossible:

| state | possible? |
|---|---|
| a reference has a binding identity but the binding is not yet established | no |
| a reference typed `any` because its declaration is later | no |
| exact block target known but creation environment missing solely due to source order | no |
| semantic instance declined solely because the callee's environment has not been seen | no (the remaining `no-env` is the declared-result recursion case above) |
| a full analysis walk required solely because a forward definition appears later | no |
| specializer retains a generic instance because the direct callee was defined later | no |

## Core IR boundary and known limitations

* Core IR is unchanged. The interpreter's scopes still declare every name on
  entry (README §2), so raw Core IR that relies on forward closure references
  or use-before-binding stays valid for the interpreter only. HIR-based
  backends resolve sequentially and treat such a reference as an unbound name
  (they raise `UNBOUND` where it is evaluated instead of miscompiling: the
  compiler backend's `CompileRef` for an unresolved name now raises
  unconditionally). Tests of those Core IR behaviors carry the
  `coreScoping` constraint (`tests/helpers.tcl`) and run on the interpreter;
  `scope-hir-*` pin the HIR contract for the same programs.
* Lowering HIR to core IR renames a later shadowing binding when needed, so a
  program HIR accepts means the same thing in every backend.
* The Rust runtime still contains the cell object and NIR cell ops (unused).
* Type and error declarations remain order-independent (they are not value
  bindings; see the visibility table).
* Mutual recursion needs a future explicit construct; the census found no
  real source that needs it.
* Not done, by instruction: Core IR / HIR re-lifting removal, hybrid
  executable, structs, MutableArray join gap, generic-function contracts.

## Readiness for Core IR removal from the AOT/native path

The relift (`hir::lower` then `native::buildProgramHir`) is now a pure
round trip of a strictly resolved program: hygiene keeps names faithful, so
the relifted HIR resolves identically (proved by identical NIR/asm above).
The next milestone can hand native lowering the resolved, analyzed HIR
directly. Opportunities observed and *not* acted on: (1) `hir::hygiene`
renames exist only to keep name-based core IR faithful, and disappear with the
relift; (2) the dead Rust cell ops; (3) `hir::aot`'s `positions` can move
out of the context once native lowering owns walk order.

## Required questions

1. *At what point does an ordinary binding become visible?* After its value is resolved (after the `bind` completes in walk order).
2. *A named function's own binding?* Before its block is resolved.
3. *Direct self-recursion legal?* Yes.
4. *Ordinary mutual recursion legal?* No.
5. *Can a closure capture a later binding?* No.
6. *Can runtime order make a forward reference legal?* No.
7. *Unreachable branch?* No, it may not contain one.
8. *Unused function?* No.
9. *Does successful HIR contain unresolved/future bindings?* No.
10. *Is a later declaration entered into the active environment early?* No.
11. *Are function declarations predeclared?* No.
12. *Any two-pass semantic hoisting table?* No (only the diagnostic-only `LaterNames` index, never consulted for resolution).
13. *Can a diagnostic's knowledge of a later declaration affect resolution?* No.
14. *Earlier reference to an outer name later shadowed in a nested scope?* The already-visible outer binding.
15. *Can the later shadow change it retroactively?* No.
16. *Later reference after the shadow?* The new inner binding.
17. *Self-binding representation?* An ordinary local binding, established before the block, captured by the block; the reference has the same binding id.
18. *Does self-recursion need ForwardType?* No.
19-20. *Remaining recursion/SCC machinery, and why?* Semantic-instance fixpoint and worklist (self recursion, type-changing recursion across keys, argument-passing cycles), the specializer's result fixpoint, contract-inference solve, escape/string-region demand propagation: all still have legal cycles to solve; only lexical mutual recursion, one source of them, was removed. The `no-env` retry remains for declared-result recursion.
21. *Can an instance request fail `no-env` solely because its callee appears later?* No.
22. *Whole-program walk repeated solely to discover a later closure environment?* No (only for the declared-result recursion case).
23. *Capture environment revised because a later lexical binding appeared?* No.
24. *Environment-revision paths removed?* None needed removal: the remaining path is recursion-attempt revision.
25. *Previously problematic CSV draft?* Rejected before specialization.
26. *Specialization shape of the legal callee-first source?* Unchanged: 66 codegen instances, 63 emitted, 49 closed / 17 guarded / 0 open, 28 guards.
27. *Independent reorder alters specialization?* No.
28. *Can illegal dependency orders affect NIR?* No, they never reach NIR.
29. *Accepted forward references in canonical source before?* 0 (1 in a language demo).
30. *In tests?* 60 accepted (71 distinct including already-static errors).
31. *By kind:* function 16, mutual recursion 32, closure capture 12, value 0 accepted (6 forward local values and 1 module value were already static errors), other 0.
32. *Source definitions reordered?* 0.
33. *Restructuring needed?* No.
34. *Real mutual recursion?* Only the demonstration example.
35. *Forward-specific functions/branches deleted?* See "Compiler complexity removed".
36. *Did ForwardType survive?* No.
37. *`no-env` survive?* Yes, for a non-forward use (declared-result recursion).
38. *Forward-induced walk retries?* No; the retry that remains is recursion-induced.
39. *Code/test complexity gone?* About 458 production lines (with comments), about 45 tests replaced.
40. *States now impossible?* See the table above.
41-50. *Measurements:* semantic instances 268 -> 268; body walks 363 -> 363; walk rounds 17 -> 17; codegen instances 258 -> 258; emitted 247 -> 247; AOT closed/guarded/open unchanged; NIR delta none; scalar assembly delta none; front-end time unchanged within noise; full regression 3184+3184 -> 3249 + 3245 (+4 interpreter-only skips), 0 failures.
