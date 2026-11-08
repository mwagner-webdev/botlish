# Construct-binding mutation census 1

Mutation of loop variables, fold intermediates, handler payloads and other
construct-local bindings: when it is intentional local state, when it is a
silently discarded write, and whether Botlish's rules make the difference
clear. A census: no language rule, runtime semantics, HIR form or backend
changed. The material is `audit/construct-binding-mutation/`: the reproducer
corpus (`corpus/`, 41 programs), its runner (`tools/run.tcl`), the
repository census (`tools/census.tcl`, `tools/test-census.tcl`,
`tools/test-census.sh`), a textual cross-check (`tools/textscan.py`) and the
fold cost measurement (`tools/fold-cost.tcl`).

Throughout, *implementation fact* means something read from the compiler or
runtime code, *observation* something a run or a diagnostic showed, and
*judgment* a design conclusion this report argues for.

## 1. Executive conclusion

* **Yes, Botlish permits construct-local mutation that is easy to mistake
  for an externally visible change.** Every loop variable, lockstep
  variable, fold intermediate and handler payload that holds a
  MutableVector, MutableArray, MutableMap or MutableSet is a *place of its
  construct*: mutating it compiles and changes that construct's own logical
  copy. *Observation:* 14 reproducers -- 13 discarded writes and one
  ambiguous destructive read -- compile without a diagnostic and run
  identically on interp, compile, cranelift-generic and cranelift
  (section 12). The canonical one is the shape a Python, Java or
  JavaScript programmer -- or a code generator trained on them -- writes
  first: `loop row in rows: row.push(42)`, after which `rows` is unchanged.
* **The hazard is real but, today, unexercised.** *Observation:* the
  repository's 1,051 programs (every tracked `.bot` file but the generated
  bindings, and a loader per standard-library module) hold 1,689 distinct
  mutation sites; 12 are rooted in a construct binding, all 12 in golden
  test suites written to pin the copy semantics, none of the
  discarded-write class. `stdlib/`, `examples/`, `packages/` and `bench/`
  hold none. The Tcl test files' own programs add 6 more, the same kind of
  test (section 11.3). There is no incident comparable to the SimCity report
  behind NONPLACE-PARAMETER-MUTATION.
* **The categories differ, and one rule cannot treat them alike**
  (section 3's table). A loop element is a copy of an element the program
  still holds; a fold intermediate is state the fold *means* to carry (its
  push-and-return idiom is documented and tested); a handler payload is a
  value the handler may legitimately transform; destructured fields and a
  coroutine binding's `first` are ordinary locals, the very idiom the
  previous milestone recommends; counted-loop variables are Ints and never
  places. A restriction by category rejects legitimate code and still does
  not stop the mistake, because the recommended rewrite (`w = row`,
  mutate `w`) can be discarded just the same (corpus c14).
* **What the compiler can tell, it can tell exactly.** Two shapes are
  decidable without guessing intent:
  1. *A dead mutation*: a mutating operation whose destination's state no
     code can read afterwards, on any path (the copy convention's own
     last-use analysis, `hir::mutvec::NoLaterUse`, proves it). It catches
     seven of the fourteen reproducers -- the canonical loop shape among
     them -- and the trap the previous milestone's second fix opens
     (copying a parameter into a local and never using the copy). Over the
     repository it fires on no production site once restricted to
     operations whose only effect is the mutation (section 16).
  2. *A fold exit after a mutation of the intermediate*: a `continue` or
     bare `break` of a fold that can run after the iteration mutated its
     intermediate carries the iteration's *starting* intermediate, so the
     mutation is discarded on that path (FOLD-LOOPS-MILESTONE-1.md, rules 5
     and 6; corpus c08, c09).

  A third shape -- the loop variable mutated, then read in the same
  iteration, while the iterated collection is used afterwards (c03, c04,
  c11) -- is indistinguishable from legitimate scratch computation without
  reading intent, and is left to documentation.
* **Recommendation (judgment, section 17):** no new error. (1) Document
  construct bindings as places of their construct where Compilerpedia lists
  the places a mutation may name, which it does not today (only
  MUTABLE-VECTOR.md's design section mentions them). (2) Add
  one warning, `DISCARDED-MUTATION`, for the two decidable shapes above. (3)
  Separately, remove the fold intermediate's per-iteration copy where no
  exit can observe it: today a fold that pushes onto a MutableVector
  intermediate copies the whole vector every iteration (1,000 pushes copy
  499,500 elements; 32,000 pushes take 31 times as long as the same pushes
  into an outer local), which steers users toward the very idioms that keep
  state outside the construct.

At a glance (*observations*; every backend agrees on every row):

| category | mutation compiles | reaches storage outside the construct | discarded-write reproducers | legitimate reproducers | repository sites (section 11; every construct-binding one is a test's) |
|---|---|---|---|---|---|
| loop element (List, MutableVector, MutableArray, MutableMap/MutableSet entries) | yes | never: a per-iteration copy | c01-c05, c07, c11-c13 | a01, a12, p03 | 2 |
| lockstep element | yes | never | c06 | -- | 0 |
| consuming-loop element (affine) | yes | the collection is consumed (USE-AFTER-MOVE after) | none possible (r02) | a08 | 0 |
| counted variable | no: an Int is never a place (r03) | -- | -- | -- | 0 |
| fold intermediate | yes | carried to the next iteration by a normal completion; dropped by `continue`/`break` | c08, c09 | a02, a05, a06 | 1 |
| handler payload | yes | never: a copy (a move when affine) | c10 | a13, a14, a15 | 2 |
| handler pattern field, destructured field | yes (an ordinary local) | never | as any local (c14) | a09, a10, a16 | 7 |
| coroutine binding's `first` | yes (an ordinary local) | never | as any local | a11 | 0 |
| local of a function or body (for contrast) | yes | never | c14 | a03, a04, a07 | 1,200 |
| context parameter, place parameter (for contrast) | yes | yes, by declaration | -- | -- | 477 |

## 2. Scope and implementation census

Read before any experiment (*implementation facts*):

| subsystem | where | what matters here |
|---|---|---|
| bindings and scopes | hir/resolve.tcl (`NewBinding`, the `listloop`, `countloop`, `lockloop`, `loop`, `handle` cases, `BindFold`) | a loop element, count, lockstep variable and fold intermediate are bindings of kind `param` of the loop's iteration scope; a handler payload is a `param` of the handler's branch scope; function parameters are `param` of a function block's scope |
| destructuring | surface/lower.tcl (`Destructure`, `Handlers`, `Projections`) | `{a, b} = s` and `on E {a, b}:` lower to a hygienic temporary (`destructure#N`) and one ordinary `local` per field, bound to a projection of it |
| place roots | hir/mutvec.tcl (`ReceiverProblem`, `PlaceArgumentProblem`, `verify`) | any binding of kind `local` or `param` of the same invocation whose static type holds a collection may be a receiver path's root; a value parameter is then NONPLACE-PARAMETER-MUTATION (`IsValueParam`: a `param` of a *function block*), a module binding, a temporary, an enclosing function's binding, a destructuring temporary MUTABLE-PLACE-RECEIVER |
| copies | hir/mutvec.tcl (`Elaborate`, `EntryRename`, `Moved`, `NoLaterUse`) | a place root's entry is a logical copy (`mutable_vector#share`) unless fresh or moved; a `param` root of a function, listloop, lockloop, fold or handler is renamed `NAME#entry` and rebound by `NAME = share(NAME#entry)` as its body's first statement |
| loops over collections | hir/mutvec.tcl (snapshot), hir/iteration.tcl (loop protocol) | a loop over an unrestricted MutableVector or MutableArray iterates `#to_list`, an immutable snapshot; a loop over a MutableMap, MutableSet or ImmutableMap is elaborated after the checks into a counted loop whose variable is a local bound to `iteration_at(...)` |
| consuming loops | hir/affine.tcl, hir/mutvec.tcl (`ConsumedKind`) | a loop over an affine collection consumes it: the domain moves into the loop, each element moves into the variable (`#take_front`), no copy |
| folds | hir/fold.tcl, FOLD-LOOPS-MILESTONE-1.md | the intermediate is "fresh and immutable" per iteration (no rebinding); a normal completion is the next one; `continue` keeps and a bare `break` yields the iteration's starting one; an affine intermediate is AFFINE-FOLD-UNSUPPORTED |
| captures | hir/mutvec.tcl (`verify`) | a nested function referring to a place root is MUTABLE-PLACE-CAPTURE; one mutating an enclosing function's binding is MUTABLE-PLACE-RECEIVER |
| place parameters | PLACE-PARAMETERS.md, hir/mutvec.tcl (`PlaceIndices`) | a place argument may be any place of the caller, a construct binding included |
| contexts | CONTEXTS.md, `IsContextParam` | a context parameter is a `local` bound to `context#load`: the installed context's storage, never copied |
| affinity | hir/affine.tcl | an affine element, payload or destructured field moves; never shared |
| proofs | hir/cardinality.tcl (`VectorLength`), hir/range.tcl, hir/induction.tcl | a vector place that is resized anywhere has no stable length; an array's capacity is stable; induction treats a parameter passed to a self call as stable |

What is language semantics and what is implementation: that a construct
binding is a logical copy whose mutations nothing else sees is semantics
(MUTABLE-VECTOR.md, section 11's entries and sections 47-48;
FOLD-LOOPS-MILESTONE-1.md, rules 3 to 6; the tests `pp-loop-variable`, `mv-payload-entry-copy`,
`npm-construct-bindings`, `fold-loops-mutable-vector`,
`fold-loops-break-discards-next` pin it). How the copy is made -- an O(1)
header share at the entry, a detach of the backing at the first write, a
move where the header is provably exclusive -- is implementation.

## 3. Binding categories and place-root semantics

| category | binding (scope owner) | a place root? | entry | lifetime | how its value can become observable | existing diagnostics |
|---|---|---|---|---|---|---|
| loop element, `loop x in L` (List) | `param` (listloop) | yes, if its type holds a collection | share per iteration (`x = share(x#entry)`) | one iteration | the iteration's value (collected), a fold's next intermediate, a place it is pushed into, a struct literal, a place argument's callee's result | capture rules |
| loop element over a MutableVector or MutableArray | `param`; the iterable is a snapshot | yes | share of the snapshot's element | one iteration | same | same |
| loop element over a MutableMap, MutableSet, ImmutableMap | written: `param`; elaborated: a `local` bound to `iteration_at` | yes (an entry's fields) | share of the entry's collection fields | one iteration | same | same |
| loop element of a consuming loop (affine collection) | `param`; the domain is moved | yes | move (`#take_front`) | one iteration, released at last use | same; the domain is gone (USE-AFTER-MOVE) | USE-AFTER-MOVE, affine rules |
| lockstep element, `loop a in A and b in B` | `param` per domain | yes, for a List domain | share | one iteration | same | same |
| counted variable (`from ... to`, a lockstep counted domain) | `param`, an Int | never | -- | -- | -- | TYPE and MUTABLE-PLACE-RECEIVER (corpus r03) |
| fold intermediate, `with intermediate acc INIT` (any loop kind) | `param` (the loop, `foldBinding`) | yes | share of the carried value (`acc = share(acc#entry)`) | one iteration | the body's normal completion is the next intermediate, the last one the fold's value; `continue`/`break` carry the iteration's starting value | AFFINE-FOLD-UNSUPPORTED, FOLD-INTERMEDIATE-TYPE |
| handler payload, `on E details:` | `param` (the handler's branch) | yes | share, or move for an affine payload | the handler body | the handler's value, a new error's payload, a place argument, a result | -- |
| handler pattern, `on E {a, b}:` | a `param` temporary (never a receiver) and one `local` per field | the fields | share of the projection, or move | the handler body | as a local | MUTABLE-PLACE-RECEIVER for the temporary |
| statement destructuring, `{a, b} = s` | a `local` temporary and one `local` per field | the fields | share of the projection, or move (an affine field moves out: the one way to take it) | the enclosing sequence | as a local | same |
| coroutine binding, `coroutine {step, first} = f()` | `local`s | `first`, if it holds a collection | as a local | the sequence | as a local | affine rules for `step` |
| local of a loop, fold or handler body | `local` | yes | share unless fresh or moved | the body (an iteration) | as a local | -- |
| context parameter (for contrast) | `local` bound to `context#load` | yes | none: the installed storage | the installation | persistent: every function sharing the context sees it | AFFINE-CONTEXT-COPY-OUT |
| place parameter (for contrast) | `param`, in `places` | yes | none: the caller's place | the call | the caller's place | MUTABLE-PLACE-RECEIVER for its argument |
| value parameter (for contrast) | `param` of a function block | rejected | -- | -- | -- | NONPLACE-PARAMETER-MUTATION |

*Implementation fact:* no construct creates a writable alias. Every
construct binding listed is an independent logical copy (or the moved
owner) of the value it was bound to; the only bindings whose mutation
reaches storage outside their own scope are context parameters and place
parameters, and both say so in their declaration. The alias census of
NONPLACE-PARAMETER-MUTATION-CORRECTNESS-MILESTONE-1.md, section 6, holds for
construct bindings unchanged.

## 4. Mutation mechanisms

*Implementation fact:* the previous milestone's two mechanisms are still
exhaustive. Read from the registry (`hir::mutvec::NativeOpKind` over every
registered native), the natives whose receiver role is `place` are the 8
public operations -- std::mutable_vector's push, pop, take, swap, clear and
std::mutable_array's set, swap, copy -- and 6 internal forms only the
elaboration writes (`#set_drop`, `#swap_drop`, `#clear_drop`,
`#take_front` of each kind). Every other mutation is a call giving an
argument to a function's `place` parameter: std::mutable_map's set,
remove, clear, reorder and std::mutable_set's add, remove, clear, reorder
are ordinary Botlish over place parameters (std::ordered_table's 15 are
internal). Element places (`-element-place`) exist only for an installed
context's members. MutableBytes writes return new storage and NativeEdit
writes native memory; neither mutates a binding's storage.

*Observation,* for every category of section 3:

* **Both call spellings** mean the same: `row.push(1)` and
  `std::mutable_vector::push(row, 2)` on a loop variable both mutate its
  copy (probe, `[2, 2]` on every backend).
* **Nested field paths** are the root's: `s.points.push(0)` on a loop
  element (c02), `row.cells.push(k)` from an inner loop (c11), `e.value.push(1)`
  on a MutableMap entry (c04), `details.pending.clear()` on a payload (c10).
* **Place parameters** accept a construct binding as their argument and
  update it, i.e. its copy (c03; std::mutable_set::add, c12).
* **Generic and imprinted functions:** an untyped function's loop variable
  is a place in each specialization (a12).
* **Across modules:** an application module's place function given the
  entry program's loop variable updates the copy, exactly as c03 (probe:
  `[[2, 2], [1, 1]]` on every backend).
* **Nested functions:** a nested function cannot capture a mutated loop
  variable (MUTABLE-PLACE-CAPTURE, r01) and cannot mutate one
  (MUTABLE-PLACE-RECEIVER, r05).
* **Context-backed state:** a context member is a persistent place, but a
  *loop over* it iterates a snapshot whose elements are copies (c07).
* **Affine values:** an affine element or payload is moved, not copied
  (a08, a14); its collection is consumed, so the code that would observe a
  lost write is rejected (USE-AFTER-MOVE, r02).

## 5. Collecting loops

*Observation* (corpus, every backend agreeing):

* **Visible in the collected element:** yes. `updated = loop row in rows:
  row.push(42); row` collects the pushed rows (a01, c01-fixed, c02-fixed).
* **Affects the input collection:** never (c01, c02, c05; c07 for a
  MutableVector iterated through a context).
* **Affects later iterations:** never: each iteration binds a fresh copy of
  its own element; a loop over a MutableVector iterates a snapshot taken
  before the first iteration.
* **Discarded when the collected expression does not use it:** yes,
  silently. c01 collects the units of `row.push(42)`, which nobody reads;
  c03 and c11 collect lengths read from the mutated copies, so the program
  even "confirms" the write it lost.
* **Struct elements holding collections** (c02, c11), **MutableArray
  elements** (c05) and **MutableMap entries** (c04) behave the same.
* **Copies:** a mutated element is shared once at the iteration's entry and
  detached at its first write; the input List still holds the element, so
  both are necessary (a01: 3 rows, 6 shares and 6 detaches for the two
  spellings together). Mutating the loop variable directly and through an
  explicit `w = row` costs exactly the same.

## 6. Folding loops

*Implementation fact:* the intermediate is a `param` of the iteration
scope; the elaboration renames it (`acc#entry`) and binds `acc =
mutable_vector#share(acc#entry)` first in the body. The body's final `acc`
moves its header out (its path's last use), so the next intermediate is
the mutated value. `continue` and a bare `break` carry the binding the loop
holds, `acc#entry`: the value the iteration started with.

*Observation:*

* **Mutate and return** is the idiom and works (a02; the test
  `fold-loops-mutable-vector`): the fold's value is the pushed vector, the
  initial value's vector keeps its own length.
* **Several pieces of state** in a struct intermediate (a05: two vectors)
  and **nested folds** carrying the outer intermediate (a06) work.
* **Mutation versus rebinding:** the intermediate cannot be rebound in its
  body (DUPLICATE); a body may complete with another value (the next
  intermediate is whatever it completes with: a probe completing with a
  fresh vector on one branch discards that iteration's push, by design).
* **A superficially similar expression that discards the update:**
  `continue` or `break` after the push. c08 (`acc.push(x); if x < 0:
  continue; acc`) loses the negative values; c09 (`acc.push(x); if x == 0:
  break; acc`) loses the sentinel. For an immutable intermediate the rule
  reads naturally (the body computed `acc + x` but did not complete with
  it); for a mutated one the name `acc` denotes the mutated value right up
  to the `continue`, and the exit silently goes back to the starting value.
* **Cost:** every iteration's entry is a logical copy of the carried value,
  so every iteration's first write detaches the whole vector: a02's 1,000
  pushes make 1,000 shares, 1,000 detaches and copy 499,500 elements;
  a05's 200 iterations copy 9,900 (section 15).
* **Proofs:** the intermediate is a join over iterations, so facts the
  initial value had are not known of it: zeroing a MutableArray
  intermediate below `a.capacity()` leaves `acc.set(i, 0)` unproven
  (UNHANDLED-ERROR, p01), while the same loop over a local copy (p02) or a
  loop variable (p03) is proven in bounds.

## 7. Counted and consuming loops

* **Counted loops.** *Implementation fact:* a counted variable (and a
  lockstep counted domain's) is an Int: it is never a place. *Observation:*
  passing it to a place parameter is TYPE and MUTABLE-PLACE-RECEIVER (r03).
  A counted loop's mutations are therefore of an outer local (the efficient
  idiom, a03) or of a fold intermediate (section 6).
* **Consuming loops.** *Observation:* over an affine vector of affine
  vectors, each inner vector moves into the loop variable; pushing onto it
  and measuring it costs no copy (a08: 0 shares, 0 detaches) and releases it
  at its last use. Reading the consumed collection afterwards -- the only way
  to expect the pushes to have landed there -- is USE-AFTER-MOVE (r02). This
  is an ownership transfer, not a discarded write: affinity already makes
  the loss impossible to miss.

## 8. Nested loops

*Observation:*

* **An outer local mutated from an inner body** (a03; a probe pushing from
  the inner loop of two nested loops: 0 shares, 0 detaches) is the
  function's own place, the same invocation: productive, no copy.
* **An outer loop's variable mutated from an inner loop** (c11) is the outer
  iteration's copy: the outer loop collects the copies' lengths, the grid is
  unchanged. No capture rule applies (loops are not functions).
* **A helper with a place parameter** given a loop variable (c03) updates the
  copy.
* **A binding of an enclosing function or construct mutated from a nested
  function** is MUTABLE-PLACE-RECEIVER (r05); one merely read there after a
  mutation is MUTABLE-PLACE-CAPTURE (r01).

## 9. Handler payloads

*Implementation fact:* a named payload is a `param` of the handler's
branch scope, entered by a share (`mv-payload-entry-copy`); an affine one
is moved; a pattern's fields are locals.

*Observation:*

* The payload is an independent logical value: mutating `details.items`
  never changes the vector the raiser put in the payload, which may still be
  its caller's place (a13: the handler's result 0, the caller's log still 2).
* Mutable fields can be modified and the result returned (a13, the tests
  `ep-mutable-collection-fields/*`), or carried into another error
  (a15: `fail Worse {items: details.items}` after two pushes; the outer
  handler sees 3).
* An affine payload moves into the handler (a14: 0 shares, 0 detaches).
* **The discarded shape** needs a misconception about where the payload came
  from: c10's handler clears the payload's buffer and retries the place call
  with it, believing it repairs the caller's buffer; the retry succeeds on
  the copy and the caller's buffer keeps its two elements. The handler's
  mutations are read afterwards, so nothing in the code says they were meant
  for elsewhere.

No handler pattern found in the repository mutates a payload and discards
it (section 11). Transforming a payload is a legitimate use; nothing here
argues for restricting it.

## 10. Destructuring and patterns

*Implementation fact:* destructuring is not field access with a different
spelling. `{items} = b` binds a temporary to `b` and `items` to the
projection `tmp.items`: an ordinary local whose entry is a share of the
field (or a move at its path's last use; an affine field moves, which is the
one way to take an affine field out of a struct). The temporary is never a
receiver (`IsDestructureTemp`). A handler pattern is the same over the
payload's temporary.

*Observation:* a destructured field is an independent writable local
(a10: `[2, 1]`; golden `destructuring.bot`, `collections.bot`); an affine
field destructured, mutated and returned is a transfer (a16: 0 shares); a
handler pattern's field likewise (a09; golden `declared-errors.bot`). This
is precisely the explicit-local idiom NONPLACE-PARAMETER-MUTATION
recommends: a destructured field is a working copy by construction, so it
can be wrong only in the way any local can (section 16, the dead-mutation
shape).

## 11. Repository-wide usage census

### 11.1 Method

`tools/census.tcl` compiles every tracked `.bot` file except the generated
bindings (`generated/`, the binding generator's fixture output) and this
census's own corpus, plus a
one-line loader `import std::NAME` for each of the 44 standard-library
modules: 1,051 programs. For each compiled program it takes the checked HIR
right before the loop protocol's elaboration (the program as written, every
check run) and enumerates the mutations exactly as `hir::mutvec::verify`
judges them: by the registry's receiver roles and the callee's `places`,
never by a name. Each site records the root binding's category (section
3), whether the mutated path's state is read again (`dead`:
`hir::mutvec::NoLaterUse` of the destination), whether the call's own
value is used, whether a reference to the root is its construct's result,
and, for a fold intermediate, whether a `continue`/`break` of the fold can
follow (`exit`). A site in a module several programs load is counted once.

641 programs compiled. The 410 that did not are, by their first diagnostic:
diagnostic-recovery, equality, proof and syntax-recovery corpora that are
rejected by design; modules compiled outside their entry
(UNKNOWN-NAMESPACE 139, MISSING-IMPORT 25: their entries load them, and
their sites are counted there); programs that need a package staged at test
time (Icy Tower's SDL3 binding, the event-loop and Raven packages); Windows
and macOS modules (UNSUPPORTED-PLATFORM 15); superseded prototypes
(CONTEXT-FUNCTION-VALUE 51, in `audit/event-loop/src` and its copies); and
the two research corpora NONPLACE-PARAMETER-MUTATION left unmigrated (15).

`tools/textscan.py` is an independent cross-check that needs no compiler:
for every name a construct binds (loop and lockstep variables, fold
intermediates, payloads, pattern and destructuring fields) it reports each
line of that construct's block where the name is a mutation's destination
(an operation, the `std::` spelling, or an argument of any function the
repository declares with a `place` parameter). Over all 1,051 files it
reports 46 lines: the 12 sites of section 11.2, and 34 false positives of
its own (a construct's name passed to a local function `f`, `g`, `add`,
`send`, `parse` that shares its name with a place function declared in
another file; `data` and `find` beside the place argument `out` in
`stdlib/windows/fs.bot` and its experiment). It therefore also covers the files the HIR census
could not compile -- packages, the Windows and macOS modules, Icy Tower --
and finds no construct-binding mutation in any of them. Two of them were
also staged and compiled the way their builds do, to give them HIR
coverage: Icy Tower with its SDL3 binding as a package (2 sites, both
through its `Sdl` context parameter) and the event-loop native example with
`packages/event_loop_linux` installed (89 sites: 87 context parameter, 2
local). Neither has a construct-binding site.

### 11.2 Results

1,689 distinct mutation sites:

| area | local | context parameter | place parameter | construct binding |
|---|---:|---:|---:|---:|
| `stdlib/` | 39 | 111 | 63 | 0 |
| `examples/` | 300 | 0 | 1 | 0 |
| `packages/`, `bench/` (their mutating files need staged packages: text scan only) | -- | -- | -- | 0 |
| `tests/golden/` | 629 | 18 | 54 | 12 |
| other test programs (`tests/*/`) | 41 | 26 | 0 | 0 |
| `audit/` | 191 | 153 | 51 | 0 |

The 12 construct-binding sites, each read:

| site | category | what it does | class |
|---|---|---|---|
| `tests/golden/fold-loops.bot:782` | fold intermediate | `acc.push(x * 10); acc` (`fold-loops-mutable-vector`) | A |
| `tests/golden/nonplace-parameter-mutation.bot:537` | loop element | `v.push(2); v.length()` (`npm-construct-bindings`, pinning the copy) | B, by design |
| `tests/golden/nonplace-parameter-mutation.bot:541` | handler payload | `details.items.push(2); details.items.length()` (same test) | B, by design |
| `tests/golden/place-parameters.bot:230` | loop element | `add(c, 5); c.items.length()` (`pp-loop-variable`) | B, by design |
| `tests/golden/declared-errors.bot:827` | handler pattern field | `items.push(99); return [items.length(), size]` | A |
| `tests/golden/declared-errors.bot:843` | handler payload | `details.items.push(7); return [details.items.length()]` | A |
| `tests/golden/destructuring.bot:1191`, `:3196` | destructured field | `set(items, 0, 5)`, then both names read: independence | B |
| `tests/golden/collections.bot:574` | destructured field | `data.set(0, 9); [p.data.at(0), data.at(0)]`: independence | B |
| `tests/golden/mutable-vector.bot:922` | destructured affine field | `first = queue.take(0)`: a move out of the field | A (transfer) |
| `tests/golden/nonplace-parameter-mutation.bot:478`, `:479` | destructured field | pushes, then read (`npm-destructured-local`) | B |

Every one is a test program whose point is the copy semantics or the
transform of a payload; none is ambiguous, none discards a write by
mistake. One local of a loop body exists outside the tests
(`audit/event-loop/src/gameserver.bot:175`, a one-slot MutableArray counter
read after the loop: the pre-fold idiom, productive).

### 11.3 The Tcl test files' programs

`tools/test-census.sh` runs every Tcl test file under `tools/test-census.tcl`,
which analyzes each program the file compiles (a source string, a file it
writes) right after its checks, on the interp core backend with the golden
duplicates skipped (their programs are the golden suites', counted above).
Programs a test runs in a child process (main.tcl, an executable) are not
seen.

*Observation:* all 270 test files ran under the census (11,527 tests:
8,824 passed, 2,703 skipped -- the golden duplicates and host
constraints -- 0 failed, the same counts as an ordinary interp run). Their
programs, apart from the repository files `census.tcl` already counted
(2,556 rows), hold 2,607 distinct sites (per test file: location, category,
root, mechanism, flags):

| category | sites |
|---|---:|
| local of a function | 2,267 |
| local of the top level | 141 |
| local of a loop body | 1 |
| context parameter | 132 |
| place parameter | 57 |
| construct binding | 6 |
| value parameter | 3 |

* The 6 construct-binding sites are `mv-payload-entry-copy`'s handlers
  (mutable-vector.test: three payload pushes and a pattern field's push, each
  read afterwards; an affine field destructured and `take`n, a transfer) and
  its MutableArray twin (mutable-array.test: `details.items.set(0, 9)` then
  read). All pin the copy semantics; none is a discarded write.
* The 3 value-parameter sites are `npm-check-load-bearing`, which replaces
  `hir::mutvec::IsValueParam` by `return 0` to show the rejected programs
  compiling: no bypass of NONPLACE-PARAMETER-MUTATION.
* Dead writes in the B1 sense (section 16): 35 native operations in 8 files
  -- proven-bounds.test 19 (its programs exist to prove a `set` in bounds),
  mutable-vector.test 7, nonplace-parameter-mutation.test 3, mutable-array-
  type.test 2, and mutable-array, native-mutarray, refinement-values and
  stdlib-namespaces one each -- and 4 place calls: programs whose only
  point is the call's proof or a copy's independence. No fold exit after a
  mutation of the intermediate (B2) occurs anywhere.

## 12. Confirmed silent-write hazards

*Observation:* each program compiles with no diagnostic, and interp,
compile, cranelift-generic and cranelift print the value in its `# expect:`
line (`tools/run.tcl`).

| program | category | mechanism | intended | actual | caught by the dead-mutation shape? |
|---|---|---|---|---|---|
| c01 | loop element (List) | push | rows grow | unchanged | yes |
| c02 | loop element, field path | push | shapes closed (4 points) | 2 points | yes |
| c03 | loop element | place argument | rows grow | copies grow, read, rows unchanged | no: the copy is read |
| c04 | MutableMap entry, field path | push | map's vectors grow | unchanged | no: the copy is read |
| c05 | loop element (MutableArray) | set | cells set | unchanged | yes |
| c06 | lockstep element | push | grow | unchanged | yes |
| c07 | element of a context member's snapshot | push | context's rows grow | unchanged | yes |
| c08 | fold intermediate | push, then `continue` | every value recorded | negatives lost | yes: the fold-exit shape |
| c09 | fold intermediate | push, then `break` | sentinel recorded | lost | yes: the fold-exit shape |
| c10 | handler payload | clear, place argument | caller's buffer repaired | the copy repaired | no: the copy is read |
| c11 | outer loop element from an inner loop | push | cells grow | copies grow, read | no: the copy is read |
| c12 | loop element (MutableSet) | place argument (std::mutable_set::add) | sets filled | empty | yes |
| c13 | loop element | pop, value used | ambiguous: shorten the queues? | copies shortened | no (the value is used); ambiguous |
| c14 | the working copy NONPLACE-PARAMETER-MUTATION suggests, never returned | set | tile zoned | not | yes |

Corrections: c01, c02 and c08 have `-fixed` versions: collect the updated
value and continue with the collected List, or complete the iteration with
the mutated intermediate.

Two consequences are worth stating apart:

* **c14 shows the hazard is not about constructs.** The previous milestone's
  diagnostic proposes `working = tiles` and "mutate the copy"; mutating the
  copy without returning it compiles and loses the write exactly as the
  rejected program did. The npm-simcity tests' "copied" variants pin that
  behavior as the old program's. A construct-specific rule would not catch
  it; a dead-mutation rule does.
* **The hazard compiles identically everywhere.** No backend disagrees, so no
  differential test can notice it: the loss is the semantics.

## 13. Legitimate local-mutation idioms

*Observation* (every backend):

| program | idiom | class | copies |
|---|---|---|---|
| a01 | mutate the loop variable and collect it; the same through `w = row` | A | 1 share and 1 detach per element, both spellings |
| a02 | fold: push and carry | A | a full copy per iteration (section 15) |
| a03 | an outer local pushed from a counted loop | A | none |
| a04 | a value parameter's working copy threaded through a self call | A | none |
| a05 | a fold carrying a struct of two vectors | A | both shared, the pushed one detached, per iteration |
| a06 | nested folds carrying one vector | A | per iteration |
| a07 | a scratch vector built in each iteration, only its length kept | B | none |
| a08 | a consuming loop's moved element pushed and measured | A (transfer) | none |
| a09 | a handler pattern's field pushed, its length the handler's value | A | -- |
| a10 | a destructured field, independent of its struct | B | 1 share, 1 detach |
| a11 | a coroutine binding's `first`, the consumer's own copy | B | -- |
| a12 | an untyped function mutating each loop variable | B | -- |
| a13 | a payload cleared, its length the handler's value | A | -- |
| a14 | an affine payload moved into the handler and pushed | A (transfer) | none |
| a15 | a payload mutated and re-raised as another error's | A | -- |
| a16 | an affine field destructured, pushed, returned | A (transfer) | none |

Direct mutation of a loop variable followed by returning it (a01's
`direct`) is as clear and as cheap as the explicit working local
(`working`): both make the one copy the input List forces.

## 14. Backend observations

* Every corpus program gives the same value on interp, compile,
  cranelift-generic and cranelift, and every rejected one the same
  diagnostics before any backend runs (the rules are front-end checks).
* The native allocation report (`native::allocationReport`) is the only
  backend-specific evidence, and only of cost: shares, detaches and copied
  elements per program (`# alloc:` lines, checked by `tools/run.tcl`).
* The Tcl backends make the same logical copies (the elaboration writes them
  into the HIR every backend compiles), so their observable results cannot
  differ from the native ones.

## 15. Proof and performance interactions

**Performance.** `tools/fold-cost.tcl`, n pushes natively (best of 3 runs
of the native driver, its process start -- about 9 ms -- included; a 4-core
container running one other test process). The share, detach and element
counts are exact and the same on every run:

| idiom | n | best (ms) | shares | detaches | elements copied |
|---|---:|---:|---:|---:|---:|
| fold intermediate (a02) | 1,000 | 11.6 | 1,000 | 1,000 | 499,500 |
| | 4,000 | 14.3 | 4,000 | 4,000 | 7,998,000 |
| | 16,000 | 83.0 | 16,000 | 16,000 | 127,992,000 |
| | 32,000 | 359.3 | 32,000 | 32,000 | 511,984,000 |
| outer local (a03) | 1,000 | 8.9 | 0 | 0 | 0 |
| | 4,000 | 9.3 | 0 | 0 | 0 |
| | 16,000 | 9.6 | 0 | 0 | 0 |
| | 32,000 | 11.4 | 0 | 0 | 0 |
| threaded working copy (a04) | 1,000 | 13.3 | 0 | 0 | 0 |
| | 4,000 | 12.8 | 0 | 0 | 0 |
| | 16,000 | 13.1 | 0 | 0 | 0 |
| | 32,000 | 13.1 | 0 | 0 | 0 |

The fold copies n(n-1)/2 elements for n pushes: quadratic, 31 times the
outer local's time at 32,000 pushes (start-up included in both).

* *Implementation fact:* the fold's copy is the entry share
  (`acc = mutable_vector#share(acc#entry)`, visible in `main.tcl -hir`). The
  carried value's header is held only by `acc#entry`, but that binding is
  what a `continue` or bare `break` carries, so the share is what keeps the
  iteration's starting value for an exit: the cost and rules 5 and 6 are the
  same mechanism.
* *Judgment:* where no `continue` or bare `break` of the fold can run in an
  iteration (or none after the first mutation), `acc#entry` is never read
  after the entry, and the entry could move the header instead of sharing
  it -- the fold analogue of the copy convention's consumed parameters
  (hir/mutvec.tcl, "Last uses and consumed parameters"). That would make
  a02's 1,000 pushes copy nothing, like a03 and a04. It is an optimization
  with no semantic change, a separate milestone (section 18).
* A loop element's share and detach are necessary: the iterated List still
  holds the element. The explicit working local costs the same (a01).
* The idioms that are cheap today -- an outer local (a03), a threaded working
  copy (a04) -- keep the state *outside* any construct, so they are also the
  idioms the hazard of section 12 does not touch.

**Proofs.**

* *Vector lengths:* a vector place that is resized anywhere has no stable
  length (`hir::cardinality::VectorLength`), whatever its binding: a loop
  variable pushed and then read with `at(0)` needs a handler exactly as a
  pushed local does (probes); an unresized loop variable's length guard is
  proven as a local's. Moving a mutation between a construct binding and a
  local changes nothing here.
* *Array capacities:* a loop variable's and a local's capacity are stable
  (p02, p03 proven in bounds); a fold intermediate's is not (p01): the
  intermediate is the join of the initial value and every completion, and no
  analysis carries "the same capacity as `a`" through it. A fold
  intermediate therefore *loses* an invariant that an explicit local keeps --
  the opposite of the induction case the previous milestone recorded, where
  a parameter passed to a self call is stable and a local copy is not.
* *Induction:* hir/induction.tcl's stability rule is about a self call's
  parameter. Loops have their own counted-variable facts, unaffected by any
  mutation (an Int is never a place). No construct binding is recognized
  specially by induction or refinement analysis.
* *Consequence for a restriction:* rejecting mutation of fold intermediates
  would push programs to outer locals, which are cheaper and better proven
  today; rejecting mutation of loop variables would force `w = row`, which
  costs and proves the same. Neither restriction makes a program less
  provable; neither makes one more correct either (c14).

## 16. Design alternatives

The candidates were evaluated against the corpus (section 12 and 13) and
the census (section 11). "Repository sites rejected or flagged" counts the
production code (`stdlib/`, `examples/`, `packages/`, `bench/`) and, after
the slash, the test programs.

| option | bugs caught (of 14) | legitimate programs rejected or flagged (corpus) | repository sites | complexity | judgment |
|---|---:|---|---|---|---|
| A. documentation only | 0 statically | none | 0 / 0 | none | necessary, not sufficient |
| B1. dead mutation, any dying place, native operations and effect-free place calls | 7 (c01, c02, c05, c06, c07, c12, c14) | none | 0 / 33 deliberate dead writes in golden suites | low: an existing analysis | recommended, as a warning |
| B2. fold exit after a mutation of the intermediate | 2 (c08, c09) | none; a deliberate "roll back this iteration's push" (not found anywhere) | 0 / 0 | low: a walk of the iteration's sequences | recommended, as a warning |
| B3. loop element mutated but not part of the iteration's value | 10 (c01-c07, c11-c13) | a12; any loop pushing the mutated element into an outer place; a07-like scratch use | 0 / 2 (the tests pinning the semantics) | medium: must follow every way a value leaves | rejected: intent, false positives |
| C. reject mutation of loop elements | 10 (c01-c07, c11-c13) | a01, a12, p03, c01-fixed, c02-fixed (and a08 unless consuming loops are exempt) | 0 / 2 | low | rejected: forces `w = row`, which is the same and is discardable the same way |
| C'. reject mutation of fold intermediates | 2 (c08, c09) | a02, a05, a06, c08-fixed (the documented idiom) | 0 / 1 | low | rejected now; reconsider only if the copy cost cannot be removed |
| C''. reject mutation of handler payloads | 1 (c10) | a13, a14, a15 | 0 / 2 | low | rejected: transforming a payload is legitimate |
| D. require an explicit working binding for construct bindings | 0 | every productive mutation needs one more line | 0 / 5 | low | rejected: boilerplate that prevents nothing (c14) |
| E. iterated collection read after a loop that mutated its elements | 10 (c01-c07, c11-c13) | a12; loops whose elements are mutated as scratch while the collection is read later for another purpose | 0 / 2 | medium, not construct-local | rejected: reads intent from unrelated code |

Detail on the two recommended shapes:

* **B1, dead mutation.** A mutation is dead when the destination path's
  state cannot be read again on any path after it: the receiver (or place
  argument) is the path's last use by `hir::mutvec::NoLaterUse`, the very
  proof the copy convention already relies on to move headers (the
  elaboration computes the use map; the check is a walk up the parent chain
  per mutation). The destination must be a place that dies with its scope:
  never a place parameter or a context parameter, whose state outlives the
  call. Three restrictions keep it a proof of "no effect", each forced by a
  repository site:
  - *the call's value is discarded*: `x = q.pop()` and `first =
    queue.take(0)` are destructive reads (10 such dead-but-used sites, among
    them `stdlib/test.bot:183`). A value collected by a loop whose List is
    itself discarded counts as discarded: c12's `s.add(5)` is its loop
    body's last statement, and the loop is a statement;
  - *the operation has no other effect*: a native mutating operation, or a
    place call whose callee needs no context, makes no direct edge and does
    not yield. `examples/dfa/csv/export.bot:80`'s final `path.flush(chunk)`
    leaves `chunk` dead but writes a file (its callee requires
    std::linux::fs's context); std::mutable_set::add requires nothing;
  - *no release runs code*: clearing or overwriting an affine collection
    whose elements are resources runs their cleanups now rather than at
    scope end (`tests/resources/fds.bot:66`'s `v.clear()` closes
    descriptors, and its result says so): an affine element type is exempt.

  With those restrictions the repository's production code has no site; the
  golden suites have 33 (20 operations and 13 place calls, all of
  std::mutable_map's and std::mutable_set's operations but one test
  helper; deliberate: static-compile tests of proofs whose
  program's only point is the call, e.g. `ns-slice-proofs/copy-within-
  capacities`, and value-semantics tests mutating a copy to show the
  original unchanged). Being a proof, B1 cannot fire on a mutation whose
  state is read, so it needs no suppression; a program with a deliberate
  dead write can remove it (or use the value) without changing its meaning,
  except for the operation's own possible failure, which `at` checks as
  well.
* **B2, fold exit.** For a mutation whose root is a fold's intermediate: a
  `continue` or bare `break` targeting that fold, in a statement after the
  mutation's in any enclosing sequence up to the fold's body, means the
  mutation is discarded on that path (`tools/census.tcl`'s `FoldExitAfter`
  is the prototype; it flags c08 and c09 and nothing else in the corpus or
  the repository). The message can say exactly what happens: the exit
  carries the intermediate the iteration started with.

Both are local to one function, deterministic, cheap, independent of the
backend, and read no name. Neither changes what any program means.

## 17. Recommended rule

*Judgment:*

1. **No new error, and no restriction by binding category.** A construct
   binding is a copy on purpose, the productive uses (sections 6, 9, 13) are
   real and documented, and every category-based restriction rejects them
   while leaving the same mistake one rewrite away (c14). Unlike
   NONPLACE-PARAMETER-MUTATION, no declaration states a contract the
   mutation contradicts, and no incident shows the hazard in use.
2. **One warning, `DISCARDED-MUTATION`**, backed by the compiler's proof, with
   two cases:
   - *dead*: a mutation of a place that dies before anything reads its new
     state (B1, with its three restrictions), for every dying place -- a
     local, a loop or lockstep element, a fold intermediate, a payload, a
     destructured field;
   - *fold exit*: a `continue` or bare `break` of a fold that can run after a
     mutation of its intermediate in the same iteration (B2).
   It fits WARNINGS-*'s model (one global policy, no suppression, no
   opt-out): it is proven, it never fires where the mutated state is read,
   and the response is always a rewrite with the same meaning (drop the
   write, use its value, complete the iteration with the mutated
   intermediate).
3. **Why a warning and not an error.** An error is justified when the
   operation has no useful or unambiguous legitimate interpretation. A dead
   mutation is useless but not meaningless (its failure is still observable:
   `set` past the end fails), and a fold exit after a mutation has one exact,
   documented meaning (roll the iteration back). Botlish rejects no other
   proven no-op (an unused binding is legal). What would change this: real
   programs, or generated code, shown to make the mistake -- the evidence
   NONPLACE-PARAMETER-MUTATION had and this census did not find.
4. **Documentation, regardless.** Compilerpedia's concept.values,
   concept.mutable-vector and error.mutable-place-receiver list the places a
   mutation may name as "a local, a place parameter, a context parameter or
   a field path from one"; the loop variable, the fold intermediate and the
   payload are missing (only MUTABLE-VECTOR.md, section 11, names them, as
   entries that copy), and folds.topic calls the intermediate "immutable"
   while the language lets it be mutated. Each
   should say that a construct binding is a place of its construct, holding
   a logical copy, with c01 and c01-fixed as the rejected-intent and
   accepted examples, and folds.topic that `continue` and `break` carry the
   unmutated intermediate.
5. **Do not reuse NONPLACE-PARAMETER-MUTATION.** Its meaning is a contract
   violation at a parameter; the dead-mutation warning is a proven absence
   of effect. One code for both would merge two rules with different
   evidence, scope and severity.

## 18. Proposed implementation milestones

1. **Documentation of construct-binding places** (no compiler change):
   MUTABLE-VECTOR.md, MUTABLE-ARRAY.md, FOLD-LOOPS-MILESTONE-1.md and
   Compilerpedia (concept.values, concept.loops, concept.folds,
   concept.mutable-vector, concept.mutable-array,
   error.mutable-place-receiver) state where construct
   bindings are places and what `continue`/`break` carry, with examples
   from the corpus checked by `tools/compilerpedia.tcl check`.
2. **`DISCARDED-MUTATION`** (WARNINGS-DISCARDED-MUTATION.md): hir/warnings.tcl
   reading `NoLaterUse` and the iteration walk, after `hir::mutvec::verify`;
   the corpus's c01-c14 and a01-a16 as its first tests (fires exactly on c01,
   c02, c05-c09, c12, c14); the census's 33 golden-suite sites as its
   precision evidence; a fuzzer derived from the mutable-vector and mutable-array
   fuzzers' place programs with an independent model of "read after"; the
   warning gate (production is already clean); Compilerpedia's five-section
   topic. The graduation question to settle there: whether the place-call
   case's "no other effect" reads the context requirement analysis
   (`hir::contexts::Requirements`) or is limited to the standard library's
   collection operations by their registration.
3. **Consumed fold intermediates** (an optimization; MUTABLE-VECTOR.md's copy
   convention): move the carried header into the intermediate when no exit
   of the fold can read `acc#entry`; `tools/fold-cost.tcl` and a02's
   `# alloc:` line as the acceptance (0 shares, 0 detaches); the
   mutable-vector, mutable-array and fold-loops harnesses and GC stress. A
   fold with an exit keeps its copy, which its semantics require.
4. **(Optional) array capacity through a fold intermediate**: carry the
   initial value's capacity through the intermediate's join when every
   completion is the intermediate itself (p01). Lower priority: the local
   idiom (p02) is proven today.

## 19. Remaining uncertainties

* **Intent cannot be read.** c03, c04, c10 and c11 read the mutated copy, so
  their code is identical to a legitimate scratch use; no rule here catches
  them, and only documentation addresses them. How often programmers (or
  generators) write them is unknown: the repository, written against these
  semantics, contains none.
* **The census sees what compiles.** 410 programs were not compiled
  standalone; the text scan covers their construct bindings, but its
  reach is textual (a mutation through a re-bound alias inside the block, or
  through a place function declared in a binding generated at build time,
  would escape it). Programs run by tests in child processes were not
  analyzed.
* **B1 has false negatives by construction.** `NoLaterUse` counts the next
  iteration of a loop as a later use of a binding declared outside it, so a
  local pushed in every iteration and never read after the loop is not dead
  for it (probe: `acc.push(i)` in a counted loop, then `n` returned). It
  proves only what it proves; a write it cannot see as dead stays silent.
* **B1's place-call case** depends on what "no other effect" means; the
  census used the categories of section 16 by reading each site, not an
  implementation of the context-requirement test.
* **The cost figures** are one machine's; the element counts are exact and
  host-independent.
* **The fold copy's removal** (section 18, item 3) is argued from the
  elaboration's rules, not implemented or measured.

## 20. Reproduction commands and evidence

Tcl 9.0.1, `LANG=C.utf8 LC_ALL=C.utf8`, the native backend built
(`cargo build --release --manifest-path native/Cargo.toml`):

```
tclsh9.0 audit/construct-binding-mutation/tools/run.tcl
tclsh9.0 audit/construct-binding-mutation/tools/census.tcl -out census.tsv [-shard I/N]
sh audit/construct-binding-mutation/tools/test-census.sh OUTDIR 4
python3 -I audit/construct-binding-mutation/tools/textscan.py
tclsh9.0 audit/construct-binding-mutation/tools/fold-cost.tcl
tclsh9.0 main.tcl -hir audit/construct-binding-mutation/corpus/a02-fold-push-return.bot
```

*Observations* on this branch (main at 5416c85):

* `tools/run.tcl`: 41 programs, 0 failures: every `# expect:` value on all
  four backends, every `# expect-diagnostics:` list, every `# alloc:` count.
* `tools/census.tcl` (4 shards): 1,051 programs, 641 compiled, 1,689
  distinct sites, 12 rooted in a construct binding (section 11.2).
* `tools/textscan.py`: 1,051 files, 61 place functions, 46 lines, of which
  the 12 HIR sites and 34 textual false positives.
* `tools/test-census.sh` (4 jobs, 48 minutes): 270 test files, 11,527
  tests, 0 failed; 2,607 sites outside the repository's files, 6 rooted in
  a construct binding (section 11.3).
* `tools/fold-cost.tcl`: section 15's table.

Re-checked after merging main at 715ce1e (76 commits, 66 compiler files
changed, threads and remote actors among them): `tools/run.tcl` still 41
programs, 0 failures, on all four backends; `tools/census.tcl` classifies
the reproducers exactly as before; `tools/textscan.py` over the 1,089 files
now tracked reports the same 46 lines in the same files, none in the 38
`.bot` files main added; and the census of the new production modules
(std::thread, std::actor::remote, examples/c-freestanding) finds 90
mutation sites, all through context parameters.
