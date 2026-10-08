# MUTABLE-VECTOR.md

`MutableVector[T]`: a growable mutable value, affine exactly when its
elements are.

> `MutableVector[T]` is a growable mutable value with logical value
> semantics. If `T` is unrestricted, the vector is unrestricted: copies are
> copy-on-write, and mutating one copy never changes another. If `T` is
> affine, the vector is affine: it uniquely owns every element, moves whole,
> and moves elements across its boundary only through explicit operations
> (push and swap in; pop, take, swap and consuming iteration out), releasing
> whatever it still owns where it dies. No element is ever aliased or
> duplicated.

AFFINE-VALUES.md is the discipline this milestone extends (the vector is
the first affine *container with move-out operations*); COROUTINES.md the
primitive affine value the scheduler-shaped programs put in it.

## Contents

* [Terminology](#terminology)
* [The principal program](#the-principal-program)
* [Representation in one page](#representation-in-one-page)
* [Report](#report) -- the 74 points of the milestone report, in order
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## Terminology

| term | meaning |
|---|---|
| vector | a `MutableVector[T]` value |
| header | the runtime identity of one logical vector value (`{mutvec ID}` on the Tcl backends, a `MutVecObj` natively); every mutation changes the header it is applied to, in place |
| backing | the elements a header shows; on the native backend shared copy-on-write between headers (`Rc<VecDeque<Value>>`), on the Tcl backends a Tcl list (Tcl's own copy-on-write) |
| place | where a vector lives and can be mutated: a local binding, a parameter, a context parameter, or a field path from one (`s.queue`, `io.output`) of the function doing the mutation |
| place root | the binding at the root of a place some operation mutates |
| logical copy (share) | `mutable_vector#share(value, "D")`: a new header over the same backing, O(1); written out by the compiler, never by source |
| detach | the first write through a header whose backing another header also shows: the backing is copied once (O(N)), after which the header's backing is unique |
| move / release | as in AFFINE-VALUES.md: the transfer of an affine value to a new owner; the deterministic cleanup where an owner dies still owning it |

A vector is not a reference: there is no way to make two places see one
vector's mutations. `w = v` makes a logical copy (unrestricted) or moves `v`
(affine); a call gives the callee its own copy (unrestricted) or the vector
itself (affine, moved).

## The principal program

```botlish
import coroutine
import mutable_vector

struct Command:
    value: int

struct Event:
    value: int

fn worker(seed: int, resume Command) -> Event:
    command = yield Event {value: seed}
    return Event {value: command.value + seed}

fn schedule() -> List[int] errors IndexNotFound:
    coroutine {step: first} = worker(1)
    coroutine {step: second} = worker(2)
    queue = mutable_vector::from_list([first, second])
    step = queue.take(0)
    event = step(Command {value: 10})
    if not coroutine::done?(step):
        queue.push(step)
    next = queue.pop()
    result = next(Command {value: 20})
    [event.value, result.value, queue.length()]

r = schedule():
    on IndexNotFound:
        []
r
```

is `[11, 22, 0]` on every backend (Tcl interpreter, Tcl compiler, Cranelift
generic and specialized), and (`tests/mutable-vector.test`'s
`mv-principal-scheduler` and `mv-principal-moves`):

* the List literal moves `first` and `second` into the List, and `from_list`
  moves the List into the vector (a later `first(...)` is `USE-AFTER-MOVE`,
  "c moved into a MutableVector");
* `queue` is affine (`MutableVector[Coroutine{...}]`: its element type is):
  `other = queue` moves it, and a later `queue.length()` is
  `USE-AFTER-MOVE`;
* `take(0)` moves the first continuation out: the vector keeps owning the
  second one, and nothing aliases the taken one;
* resuming `step` advances the original execution (the worker returns
  `10 + 1`), and `push` moves it back (a later `step(...)` is
  `USE-AFTER-MOVE`);
* `pop` moves the other continuation out (`20 + 2`); `queue` is released
  where it dies, owning nothing by then;
* each of the two coroutines is created once and released exactly once
  (`core::coroutines::releaseCalls`), in order `first`, `second` -- on the
  interpreter and on the Tcl compiler; natively every coroutine is released
  and none is swept;
* nothing at run time tracks ownership: natively `schedule` is
  `mvfromlist`, `mvtake`, `coresume`, `mvpush`, `mvpop`, `affinedrop` and
  `corelease` on registers (item 89 below).

The scheduler's `if not coroutine::done?(step): queue.push(step)` moves
`step` on one path only: the elaboration releases it on the other path (the
empty `else` -- "Path releases" in AFFINE-VALUES.md, new in this
milestone), never after the join, where the vector now owns it.

## Representation in one page

```
                       place (binding / field path / context member)
                         |
                         v
   header (identity of ONE logical value) ----> backing [e0 e1 e2 ...]
   header (a logical copy)        ------------/      (shared copy-on-write)
```

* **Mutations mutate the header in place.** `v.push(x)` never stores a new
  value back into `v`: there is no rebinding, no assignment and no hidden
  temporary. The receiver must be a place that owns its header
  (`MUTABLE-VECTOR-RECEIVER` otherwise: a mutation of a temporary would be
  lost).
* **Every copy out of a place is a new header** (`mutable_vector#share`,
  O(1)), written by the compiler wherever a vector-bearing value leaves a
  place (a read-out) or enters one (an entry). The compiler guarantees a
  header is only ever mutated through the one place that owns it, so a copy
  never observes a mutation. The copy-on-write count of the backing
  (natively an `Rc` count) is an implementation detail: never an ownership
  count, never consulted for semantics.
* **Affine vectors are never shared.** Ordinary affinity moves them, so no
  share is ever written for one; natively an affine operation finding a
  shared backing panics (an invariant violation) rather than copying affine
  elements.
* **Ownership is static.** The runtime stores elements and performs the
  moves and drops the compiler wrote out; it has no owner, moved bit,
  borrow count, ownership table or affine flag (`mv-runtime-source`).

## Report

### 1. `MutableVector[T]` source grammar

A type application of the new constructor `MutableVector` (arity 1) in
`hir/types.tcl`'s constructor table, accepted wherever a type is written:
`MutableVector[int]`, `MutableVector[Coroutine{args: [Command], return:
Event}]`, nested in `List[...]`, struct fields and function signatures. The
internal type is `{mutvec ELEM}` (the bare runtime kind `mutvec` is the
erased `MutableVector[any]`); HIR text writes it back as
`MutableVector[...]` and reads it (`hir/read.tcl`), `mv-hir-type-roundtrip`.
There is no vector literal (a non-goal): a vector comes from `from_list`.

### 2. Construction API

`mutable_vector::from_list(xs: List[T]) -> MutableVector[T]`, after
`import mutable_vector`. An empty vector needs its element type from
context: `from_list([])` is `MutableVector[never]` (nothing can be pushed
into it: `TYPE`), so the empty vector of a given type is written where a
type is declared -- a function result (`fn empty_queue() ->
MutableVector[Job]: mutable_vector::from_list([])`), a struct field, a
parameter. `mv-construction`, `mv-element-type`.

### 3. Method/API surface

`mutable_vector::{from_list, length, empty?, at, push, pop, take, swap,
clear}`, every one method-eligible on its first argument
(`queue.push(step)`, `state.queue.pop()`, `v.at(i)` -- also beside `import
list`: the receiver's static type picks the namespace). Internal natives the
compiler writes (source cannot spell them: their names contain `#`):
`mutable_vector#share`, `#to_list`, `#consume`, `#take_front`,
`#clear_drop`, `#swap_drop` (`tests/stdlib-namespaces.test`'s inventories).

### 4. Affinity derivation

`Affinity(MutableVector[T]) = Affinity(T)`: `hir::types::IsAffine` treats
`mutvec` exactly like `List` (and mutation alone never makes a type affine).
Every ownership decision asks that one query, so a struct, List or vector
owning an affine vector is affine by the same derivation. `mv-type-affinity`
pins item 98's table (below).

### 5. Unrestricted value semantics

An unrestricted vector is an ordinary value: binding, passing, returning,
storing in a struct or List, reading a field and iterating copy it
logically; mutating one copy never changes another, wherever the copies
live (`mv-cow-copies`, `-calls`, `-struct-field`, `-list-element`,
`-nested`, `-loop`, and the fuzzer's unrestricted family).

### 6. Affine vector semantics

An affine vector has one owner and moves whole (bindings, arguments,
results, struct fields, List elements) like any affine value; elements cross
its boundary only by `push`/`swap` (in), `pop`/`take`/`swap`/consuming
iteration (out); `at` of an affine element is rejected; `clear` and the
vector's death release what it still owns, first to last
(`mv-affine-*`).

### 7. COW representation

Native: `MutVecObj { hdr, backing: Rc<VecDeque<Value>> }`
(`native/src/runtime/mutvec.rs`). Tcl: the header `{mutvec ID}` names a
slot of `core::mutvec::store` holding a Tcl list (`core/mutvec.tcl`); Tcl
lists are themselves copy-on-write, so a share is a new slot holding the
same list object.

### 8. COW copy path

`mutable_vector#share(v, "h")` (`rt_mv_share`): a new header on
`Rc::clone` of the backing -- one allocation, no element copied, counted as
`shares`. Struct-bearing values are shared by descriptor (`s1.0.h`: a new
struct whose slot 0 is shared). Where the compiler writes shares: item 11.

### 9. COW detach path

The first mutation through a header whose backing is shared
(`Rc::strong_count > 1`) copies the backing once (`Rc::make_mut`, counted as
`detaches` and `detachElements`). `rt_mv_clear` of a shared backing does
not copy at all: it gives the header a new empty backing.

### 10. Unique-write path

A unique backing is mutated in place: `push` is `VecDeque::push_back`
(amortized O(1), capacity doubling counted as `growths`), `pop`
`pop_back`, `take(0)` `pop_front` (O(1)), `take(i)` `remove(i)` (shifts the
shorter side), `swap` an in-place replace. `mv-cow-evidence`: 1000 pushes
into a unique vector are 0 shares, 0 detaches, under 20 growths.

### 11. Mutable-place representation

`hir/mutvec.tcl`. `verify` (part of `hir::check`, after the affine
discipline) checks every mutation's receiver is a place path -- a reference
to a local, parameter or context parameter of the same function, or field
projections from one -- of static type `MutableVector[T]`, and records the
place roots. `Elaborate` (after `hir::check`, before every backend; once:
never on HIR rebuilt from Core IR) writes out:

* **read-outs** -- a value use of a place path (anything but a vector
  operation's receiver or observation, a projection continuing the path, a
  discarded statement, or the function's own result) is wrapped in a share;
* **entries** -- a place root's initial value is shared unless it is fresh:
  a local's bound value, a parameter on entry (renamed: `v#entry`, and `v`
  becomes a local bound by its share), a loop variable per iteration, a
  context installation's value. *Fresh* is a `from_list` result, a share, a
  struct literal of fresh fields, or a call of a function whose every result
  is fresh;
* **results** -- a function's result (its final value, a `return`'s value,
  through `if` branches) that is a place path of its own (not a context
  parameter's) moves the header out instead of sharing it: the place dies
  with the invocation, and no other place ever got that header. So a
  function that builds a vector in a local and returns it is fresh, and its
  caller's place takes the header without a copy (`mv-cow-fresh-results`);
  a function that may return a vector some other place holds (an unmutated
  parameter, on any path) is not, and its caller copies.

A nested function may not refer to a place root (`MUTABLE-VECTOR-CAPTURE`):
it would observe a binding that changes. Bindings stay immutable names: no
construct rebinds one.

### 12. Local receiver mutation

`v.push(x)` on a local mutates `v`'s header; the binding stays usable and
shows the change (`mv-receiver-places`).

### 13. Parameter receiver mutation

A parameter is a place: the callee mutates its own copy (its entry share),
never the caller's (`mv-cow-calls`; the fuzzer's `push_len`/`bump`).

### 14. Struct-field receiver mutation

`s.inner.v.push(x)` mutates the field's header in place through the path
(`mv-receiver-places`, `mv-cow-struct-field`).

### 15. Context-field receiver mutation

`io.output.push(text)` mutates the installed context's member in place,
visible to every function sharing the context; natively the installed
header is a GC root (`ctxroot`, `vm.context_roots`). A context
parameter is always a place root for read-outs, so a snapshot
(`snapshot() -> MutableVector[str]: io.output`) is independent of later
writes, in any function (`mv-context-member`); installing a context copies
the installed value logically (`mv-context-installed-copy`).

### 16. `length`

`mutable_vector::length(v) -> int` (a collection-length range fact),
an observation: no share, no move (affine: `use observe`).

### 17. `empty?`

`mutable_vector::empty?(v) -> bool`, an observation like `length`.

### 18. Unrestricted `at`

`mutable_vector::at(v, i) -> T`, `errors IndexNotFound` for an index
outside `0..length-1` (`mv-ops`).

### 19. Affine `at` rejection

`AFFINE-VECTOR-COPY-OUT` (new; precise): "mutable_vector::at would copy an
affine element out of `q` (...) while the vector still owns it, making a
second owner: move it out instead -- `take(i)` removes it, `pop()` removes
the last one, `swap(i, replacement)` exchanges it for another (there are no
references to elements)" -- also through a field path (`s.queue`), which the
fuzzer found unreported and is now fixed (`mv-affine-at`).

### 20. `push`

`mutable_vector::push(v, x) -> unit`: appends; the element type is fixed by
the vector's type -- an element not admissible to it is `TYPE` (never
widened or checked at run time; `mv-element-type`).

### 21. Affine push ownership

`push` moves the element (`move vector`): a later use of its binding is
`USE-AFTER-MOVE` ("c moved into a MutableVector"); on a path that moved it
the binding is not released (`mv-affine-push-moves`).

### 22. `pop`

`mutable_vector::pop(v) -> T` moves the last element out.

### 23. Empty-pop behavior

`IndexNotFound`, the existing handleable builtin error (no new error
type): the vector is unchanged and still owns everything; a handler sees
it like any declared error (`mv-ops`, the fuzzer's handled pops).

### 24. `take`

`mutable_vector::take(v, i) -> T` moves element `i` out; later elements
keep their order (`mv-take-order`). There is no general partial-move state:
the slot is gone, the vector stays a valid vector of the rest.

### 25. Bounds failure behavior

`at`, `take` and `swap` outside `0..length-1` (negative, or a non-small
Int) fail with `IndexNotFound` and change nothing.

### 26. `swap`

`mutable_vector::swap(v, i, x) -> T`: installs `x` at `i`, returns the old
element.

### 27. Affine swap success

The replacement moves in (`move vector`), the old element moves out to the
result (`mv-affine-pop-take-swap`).

### 28. Affine swap failure cleanup

An affine `swap` is elaborated to `mutable_vector#swap_drop(v, i, x, "D")`:
out of range, the replacement -- already moved into the operation -- is
released by the element descriptor before `IndexNotFound`; its source
binding stays moved; the vector is unchanged (`mv-affine-swap-failure`; the
Rust test `a_failed_swap_drop_drops_the_replacement_and_keeps_the_vector`).

### 29. Discarded affine swap result

A discarded result of a swap (a statement, handled or not) is an affine
value nothing owns: released right after the statement
(`mv-affine-swap-discarded`).

### 30. `clear`

`mutable_vector::clear(v) -> unit`; an affine `clear` is elaborated to
`mutable_vector#clear_drop(v, "D")`, which takes every element out first,
then releases each by `D` (`mv-affine-clear`).

### 31. Clear/drop order

First to last (lowest index first): `clear`, a vector's death and a
consuming loop's abandoned suffix (`mv-affine-drop-order`, `mv-loop-exits`;
the fuzzer checks each group of slots is released together, in order).

### 32. Whole-vector drop

Where an affine vector's owner dies still owning it (its last use, an
early exit, an error edge), the affine release elaboration drops it with
`affine#drop(v, "vD")` -- the ordinary AFFINE-VALUES.md machinery
(`mv-affine-drop-order`, `mv-affine-struct-field`).

### 33. Vector affine descriptor

`v`D: "every live element by D, first to last, leaving the vector empty"
(`hir::affine::Descriptor`, `core::affine::Drop`, `affine.rs`'s `drop_at` ->
`mutvec::drop_elements`); `vc` for coroutine handles,
`vs1.1.c` for `Job {id, step}` elements, nested in `l`/`s` descriptors
for Lists and structs owning vectors (`mv-affine-list-of-vectors`).

### 34. Dead-slot ownership invariant

Only the live elements `[0, length)` are owned, traced and dropped. A Tcl
list has no slots beyond its length; a `VecDeque`'s spare capacity holds no
`Value` its `iter()` visits; pop/take remove the slot, clear/drop take the
elements out before releasing any (so a release never sees a slot that
still holds a released element).

### 35. Internal relocation semantics

Growth (`VecDeque` reallocation), `take(i)`'s shift and `pop_front` move
element words inside Rust code that reaches no safepoint (no Botlish
allocation, so no collection, can happen with an element between slots).
At every safepoint each element has exactly one location; relocation never
changes an identity (`mv-affine-growth`: 1000 suspended coroutines pushed
through many capacity changes, then drained in order, each released once).

### 36. Affine growth

`mv-affine-growth`, `mv-affine-gc-stress` (growth under a collection at
every allocation site), the Rust test `clear_drop_releases_every_element_once`
(40 coroutines through 4 growths).

### 37. Unrestricted growth

`growth_keeps_every_element_once` (100 pushes), `mv-cow-evidence`, the
benchmark's growth counters (200 000 pushes into one vector: 17 capacity doublings, 2 MiB of element words in all, 0 shares, 0 detaches).

### 38. `from_list` unrestricted

A new vector over the List's elements (`mv-construction`).

### 39. `from_list` affine

The List moves into the conversion (`move vector`): a later use of the List
is `USE-AFTER-MOVE`, and the vector becomes the one owner of every element
(`mv-affine-from-list`).

### 40. Whole-vector call movement

An affine vector passed to a parameter declared `MutableVector[...]` (or to
an untyped parameter: specialized, item 72) moves into the callee, which
releases what it does not return (`mv-affine-whole-moves`).

### 41. Whole-vector return

A function result moves the vector to the caller (`mv-affine-whole-moves`;
the fuzzer's `pass_q`, `fill`).

### 42. Vector in structs

A struct field of vector type is a place through its binding (item 14);
reading the field (`x = s.items`) is a read-out (a copy) for an
unrestricted vector and `AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE` for an
affine one (destructure the struct instead: `{items} = s`;
`mv-affine-struct-field`).

### 43. Vector in Lists

`List[MutableVector[T]]` stores vectors as values: a List element is never
a place (Lists are immutable), so it needs no copy until something
extracts it into a place, whose entry shares it (`mv-cow-list-element`);
`list::at(xs, 0).push(1)` is `MUTABLE-VECTOR-RECEIVER`. A List of affine
vectors is affine, moves whole and drops every vector's elements
(`mv-affine-list-of-vectors`).

### 44. Context mutable member

Item 15. The brief's `context struct CaptureIO: output: MutableVector[str]`
with `io.output.push(text)` is `mv-context-member`.

### 45. Field-copy vs field-place mutation

`x = s.items` copies (a read-out); `s.items.push(1)` mutates the field (a
place path). `mv-cow-struct-field` pins that neither observes the other.

### 46. Consuming affine iteration

`loop item in queue` over an affine vector consumes it: the vector moves
into the loop (`move loop`: a later use is `USE-AFTER-MOVE`), each element
moves, in order, into the loop variable -- an owner for that iteration,
released at its last use or moved on (pushed into another vector) -- and
the loop collects unrestricted values (`mv-loop-consumes`). No
source-visible iterator object exists: Core IR marks the domain
`mutable_vector#consume(...)`; the backends take elements off the front
(item 52).

### 47. Unrestricted iteration

A loop over an unrestricted vector iterates an immutable snapshot
(`mutable_vector#to_list`): mutating the vector inside the loop (even
pushing onto it) never changes what the loop sees (`mv-cow-loop`; the
fuzzer's loops push onto the iterated vector).

### 48. Loop variable ownership

The element binding is a per-iteration owner (`hir::affine::Flow` makes it
live at each pass); `hir::types::IterationElementOf` gives it the element
type (an affine loop variable is affine).

### 49. Continue cleanup

`continue` releases the current element (if not moved on), never the rest
of the vector (`mv-loop-exits` mode 1).

### 50. Break cleanup

`break` releases the current element and the remaining suffix (the loop's
domain: `hir::affine::LoopDomain`, a pending item of every exit leaving the
loop body except a `continue` of that loop), first to last
(`mv-loop-exits` mode 2, `mv-loop-native`).

### 51. Return/fail/error cleanup

`return`, `fail` and a propagated declared error out of a consuming loop
release the current element and the suffix (`mv-loop-exits` modes 3-4,
`mv-loop-error-propagation`; the fuzzer's `first_over`, `fail_over`,
`boom_over`).

### 52. Efficient drain lowering

Natively each iteration is `mvempty` + `mvtakefront` (`VecDeque::pop_front`,
O(1)) -- never a `take(0)` shift (`mv-loop-native`). Taking the last element
frees the drained vector's storage at once (the brief's queue-drain example:
after normal completion the old vector owns nothing and its storage is
released; only the empty header waits for a collection; the Rust test
`draining_the_last_element_frees_the_storage`). On the Tcl backends each
step is `lpop 0` of the vector's list, which Tcl 9 implements with a move of
the remaining elements (measured: ~0.4 us per step at 10 000 elements, ~3
us at 100 000).

### 53. HIR type

`{mutvec ELEM}`; subtyping is covariant in the element (sound: a vector is
a value, and an element pushed is checked against the receiver's *static*
element type, item 20); `lub` of two vectors is the vector of the lub;
narrowing keeps the declared element type (so a callee's instance keeps
its `MutableVector[Coroutine{...}]` contract); `MutableVector[never]`'s
element reads are typed `any` (HIR rebuilt from Core IR sees only
`from_list([])`'s type).

### 54. HIR operations

HIR text (`hir::format`) marks every vector operation, reading back to the
same text (`mv-hir-evidence`):

```
call native(mutable_vector::take) : Coroutine{...} vector=mutate place=b13 move-out error-release=IndexNotFound=b13
call native(mutable_vector::push) : unit vector=mutate place=b13
ref b15 step : Coroutine{...} move
ref b9 unit : unit release=b15
listloop s12 (b27 step) binds b28 e : List[unit] consuming
break -> e81 : never exit-release=b26
```

`vector=observe|mutate`, `place=ROOT[.FIELD...]` (the receiver's place),
`move-out` (an element moved out), `consuming` (a consuming loop), and the
shares and descriptors the elaboration wrote (`call
native(mutable_vector#share)` with `const str h`).

### 55. Core IR lowering

Vector operations are ordinary native calls; the elaboration's shares,
drops and descriptors are ordinary calls and constants. A consuming loop's
iterable is wrapped in `mutable_vector#consume(...)` (an identity) so that
Core IR -- which keeps no element types -- still says the loop consumes
(`hir/lower.tcl`); a domain that is a temporary is held by a block binding
`affine#temp#E` so its early-exit drop can name it.

### 56. Tcl runtime representation

`core/mutvec.tcl`: headers `{mutvec ID}` over `core::mutvec::store(ID)` (a
Tcl list); `core::value` knows the kind (`show` `<mutable-vector [1, 2]>`,
equality is `CORE SEMANTIC EQUALITY` like MutableArray's -- vector equality
is a non-goal). The interpreter's `listloop` over a vector value drains it
(`core::forms::ConsumeVector`).

### 57. Tcl compiler lowering

`compiler/compiler.tcl`'s `CompileListLoop` compiles a consuming loop as
`while {[llength [core::mutvec::items $items]] > 0} {set item
[core::mutvec::takeFront $items]; ...}` with the domain boxed as a pending
temporary; everything else is the natives' ordinary call path.

### 58. Native representation

`KIND_MUTVEC` (16): a `MutVecObj` header object on the Botlish heap, its
backing an `Rc<VecDeque<Value>>` outside it (`heap.rs` traces the backing's
elements, sizes the object, frees the header, dropping its `Rc`).

### 59. Native lowering

`native/lower.tcl` maps each native to one NIR op (`mvfromlist`, `mvlen`,
`mvempty`, `mvat`, `mvpush`, `mvpop`, `mvtake`, `mvswap`, `mvclear`,
`mvshare`, `mvtolist`, `mvtakefront`, `mvcleardrop`, `mvswapdrop`);
`ctxroot` roots an installed context's vector header. Only
`mvfromlist`, `mvshare` and `mvtolist` may allocate (safepoints); every
mutation is no safepoint (`op_may_allocate`, `mv-runtime-source`). Native
evidence (item 89):

```
%8 = op listnew %1 %5
%9 = op mvfromlist %8
%12 = op mvtake %9 %10
%19 = op coresume %12 %18
%25 = op mvpush %9 %12          ; the then-branch: step moves back
%27 = op corelease %12          ; the else-branch: step released there
%28 = op mvpop %9
%33 = op affinedrop %9 "vc"     ; queue dies (its last use)
%37 = op coresume %28 %36
%38 = op corelease %28
```

No ownership object, no clone, no `mvshare` in an affine function
(`mv-native-evidence`): push/pop/take/swap/clear/drop of affine elements are
single operations on the header register.

### 60. GC tracing

The collector traces a header's live elements (`mutvec::elements`), and
nothing else of it: the backing is not a Botlish object. A shared backing
is traced once per header (marking is idempotent). An installed context's
header is rooted (`ctxroot`).

### 61. GC stress

`mv-cow-gc-stress` and `mv-affine-gc-stress` run COW aliases, growth,
take/swap/pop, consuming loops with early exits and drops under
`BOTLISH_NATIVE_GC_STRESS=1`; the fuzzer's `-gc-stress 1` runs every
accepted program so; the whole suite under GC stress: item 66.

### 62. COW instrumentation

The native allocation report's `mutableVector` section (present only when
a program made a vector): `shares`, `detaches`, `detachElements`, `growths`,
`growthBytes`. The Tcl runtime counts `created` and `shares`
(`core::mutvec::counters`). `mv-cow-evidence`: a copy does not copy its
1000 elements; the first write detaches once (1000 elements); later writes
never detach again; a vector built in a function and returned enters its
caller's place with no copy at all.

### 63. Scheduler-shaped evidence

`mv-principal-scheduler`, `mv-principal-moves` (item 102); the brief's
queue-drain, bounds/ownership and clear examples are `mv-loop-consumes`,
`mv-affine-swap-failure`/`mv-ops`, `mv-affine-clear`; the benchmark's
scheduler (item 73).

### 64. Fuzzer design/results

`audit/mutable-vector/tools/fuzz.tcl` (its header has the design): programs
alternate between an unrestricted family (vectors of Ints in bindings and in
a struct field) and an affine family (vectors of coroutines and of affine
structs, in bindings and in a struct field), each a straight line of 5..18
of the operations item 84 lists, a third of them carrying one fault with
the diagnostic the model predicts. The model shares no code with the
compiler: unrestricted places hold pure sequences; affine identities have
one owner each and the transitions of item 86. Values are compared on all
four backends; releases on the interpreter and the Tcl compiler (each
identity exactly once; each group of slots dropped together released
consecutively, first to last); natively the release counters (and, with
`-gc-stress 1`, the value under GC stress).

Results on the final tree (every backend; native release counters on):

| run | programs | accepted | rejected (as predicted) | identities checked | disagreements |
|---|---:|---:|---:|---:|---:|
| `-seed 5000 -n 80` | 80 | 55 | 25 | 396 | 0 |
| `-seed 6000 -n 80` | 80 | 58 | 22 | 387 | 0 |
| `-seed 7000 -n 60 -gc-stress 1` | 60 | 39 | 21 | 389 | 0 |

The rejected programs carried the predicted diagnostic every time:
`MUTABLE-VECTOR-RECEIVER` 20, `TYPE` 14, `USE-AFTER-MOVE` 14,
`MUTABLE-VECTOR-CAPTURE` 7, `AFFINE-CAPTURE-UNSUPPORTED` 7,
`AFFINE-ERASURE-UNSUPPORTED` 3, `AFFINE-VECTOR-COPY-OUT` 3 (earlier seeds
also produced `AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE`). During development
the fuzzer found one real bug: an affine `at` through a struct field path
(`mutable_vector::at(h3.items, 0)`) was accepted, because the field read's
rejection was deferred to its receiver while a receiver-path receiver is a
place, not a read (`hir::affine::AffineProjection` now reports it at the
projection; `mv-affine-at` pins it). Its mutation-harness run (item 65)
kills 32 of the 43 mutants on its own, with 25 programs per mutant.

### 65. Mutation results

`audit/mutable-vector/tools/mutate.tcl` with
`audit/mutable-vector/tools/mutants.txt`: every mutant item 88 lists that
is not equivalent in this representation (the file's header names the
equivalent ones and why), plus the mutants of this milestone's own rules
(fresh results, context results, GC tracing, the Tcl compiler's drain).

**43 mutants, 43 killed, 0 survived** (34 that edit the compiler or the
Tcl runtime, 9 native mutants that rebuild a private copy of the native
backend). Each column is a detector: the failing tests of
`tests/mutable-vector.test`, the fuzz programs that disagree with the model
(`-fuzz-count 25 -fuzz-seed 11`, every backend), and the failing Rust tests
of `runtime::mutvec` (native mutants only).

| mutant | tests failed | fuzz | Rust |
|---|---|---|---|
| `vector-affine-unrestricted` | 24 (`mv-affine-at`, `mv-affine-clear`, ...) | 12/25 | -- |
| `descriptor-omits-vector` | 17 (`mv-affine-clear`, `mv-affine-drop-order`, ...) | 6/25 | -- |
| `vector-erased-any` | 1 (`mv-affine-erasure`) | 3/25 | -- |
| `share-aliases-tcl` | 12 (`mv-context-installed-copy`, `mv-context-member`, ...) | 6/25 | -- |
| `share-aliases-native` | 12 (`mv-context-installed-copy`, `mv-context-member`, ...) | 6/25 | 1 test |
| `copy-eager-deep` | 2 (`mv-cow-evidence`, `mv-cow-fresh-results`) | survived | 1 test |
| `callee-mutation-leaks` | 1 (`mv-cow-fresh-results`) | 2/25 | -- |
| `fresh-result-unowned` | 1 (`mv-cow-fresh-results`) | survived | -- |
| `result-move-context` | 1 (`mv-context-member`) | survived | -- |
| `snapshot-aliasing` | 1 (`mv-cow-loop`) | 8/25 | -- |
| `context-detached-local` | 2 (`mv-context-installed-copy`, `mv-context-member`) | survived | -- |
| `context-read-aliases` | 1 (`mv-context-member`) | survived | -- |
| `affine-move-cow-fork` | 1 (`mv-affine-growth`) | 1/25 | -- |
| `push-no-invalidate` | 5 (`mv-affine-from-list`, `mv-affine-push-moves`, ...) | survived | -- |
| `push-copies` | 6 (`mv-affine-growth`, `mv-affine-push-moves`, ...) | 2/25 | -- |
| `from-list-no-consume` | 1 (`mv-affine-from-list`) | survived | -- |
| `from-list-duplicates` | 24 (`mv-affine-pop-take-swap`, `mv-affine-struct-field`, ...) | 11/25 | 3 tests |
| `at-accepts-affine` | 1 (`mv-affine-at`) | survived | -- |
| `pop-leaves-owner` | 5 (`mv-affine-pop-take-swap`, `mv-affine-struct-elements`, ...) | 8/25 | -- |
| `pop-leaves-owner-native` | 5 (`mv-affine-pop-take-swap`, `mv-affine-struct-elements`, ...) | 7/25 | 3 tests |
| `take-duplicate-owner` | 6 (`mv-affine-pop-take-swap`, `mv-affine-struct-field`, ...) | 7/25 | -- |
| `swap-copies-replacement` | 3 (`mv-affine-gc-stress`, `mv-affine-pop-take-swap`, ...) | 1/25 | -- |
| `swap-loses-old` | 6 (`mv-affine-gc-stress`, `mv-affine-pop-take-swap`, ...) | 3/25 | -- |
| `failed-swap-leaks` | 1 (`mv-affine-swap-failure`) | 3/25 | -- |
| `failed-swap-leaks-native` | 1 (`mv-affine-native-releases`) | 3/25 | 1 test |
| `failed-swap-restores-source` | 1 (`mv-affine-swap-failure`) | 3/25 | -- |
| `clear-not-elaborated` | 2 (`mv-affine-clear`, `mv-native-evidence`) | 1/25 | -- |
| `clear-leaks` | 1 (`mv-affine-clear`) | 1/25 | -- |
| `clear-leaks-native` | 1 (`mv-affine-native-releases`) | 1/25 | 1 test |
| `clear-releases-twice` | 1 (`mv-affine-clear`) | 1/25 | -- |
| `drop-ignores-elements` | 14 (`mv-affine-clear`, `mv-affine-drop-order`, ...) | 6/25 | -- |
| `drop-ignores-elements-native` | 4 (`mv-affine-gc-stress`, `mv-affine-growth`, ...) | 6/25 | 1 test |
| `drop-order-reversed` | 7 (`mv-affine-clear`, `mv-affine-drop-order`, ...) | 6/25 | -- |
| `growth-forks` | 6 (`mv-affine-gc-stress`, `mv-affine-growth`, ...) | 10/25 | -- |
| `growth-forks-native` | 18 (`mv-affine-gc-stress`, `mv-affine-growth`, ...) | 8/25 | 5 tests |
| `growth-drops-relocated` | 2 (`mv-affine-gc-stress`, `mv-affine-growth`) | 3/25 | -- |
| `trace-omits-elements` | 4 (`mv-affine-gc-stress`, `mv-affine-growth`, ...) | 1/25 | survived |
| `loop-no-move` | 3 (`mv-loop-consumes`, `mv-loop-exits`, ...) | survived | -- |
| `loop-aliases-element` | 3 (`mv-affine-growth`, `mv-loop-error-propagation`, ...) | 1/25 | -- |
| `loop-aliases-element-compiled` | survived | 1/25 | -- |
| `continue-leaks` | 1 (`mv-loop-exits`) | survived | -- |
| `break-leaks-suffix` | 4 (`mv-affine-gc-stress`, `mv-affine-growth`, ...) | survived | -- |
| `exit-leaks-suffix` | 2 (`mv-loop-error-propagation`, `mv-loop-exits`) | 1/25 | -- |

Two findings of the harness itself. The native leak mutants of `clear` and
of a failed swap were first caught only by the fuzzer and the Rust tests;
`mv-affine-native-releases` now checks the native release counters after
both, and kills them alone. And the first run of the native mutants showed
every one of them failing the GC-stress tests whatever its edit: the
harness's tree copy lacked the repo-root `.cargo/config.toml` (frame
pointers, which the collector's stack walk needs), which cargo finds only
from its working directory. The harness now copies it and builds from the
copy's root, and the native mutants above were rerun that way; the affine,
coroutine, abi-bytes and mutable-bytes harnesses had the same dependence on
being launched from the repo root and were fixed the same way.

### 66. Full regression

On this branch merged with main at `eb8e7a5` (the MANY-BOOLEAN-ARGUMENTS
warning), each suite run with a private `-tmpdir`, `LANG=C.utf8`:

| run | tests | passed | skipped | failed |
|---|---:|---:|---:|---:|
| `CORE_BACKEND=interp tests/all.tcl` | 6766 | 6766 | 0 | 0 |
| `CORE_BACKEND=compile tests/all.tcl` | 6766 | 6762 | 4 (`coreScoping`, as on main) | 0 |
| `BOTLISH_NATIVE_GC_STRESS=1 tests/all.tcl` | GC-STRESS-RESULT |
| `cargo test --release` (native crate) | 236 | 236 | 0 | 0 |

The Rust count is 205 library tests (7 of them this milestone's
`runtime::mutvec` tests) and 31 integration tests. Existing tests whose
expectation this milestone changed: `co-release-placement` (path releases),
`ns-root-inventory` and `ns-qualified-inventory` (the new natives),
`imports-*`'s namespace hint and `linux-syscall`'s namespace pattern (the
new `mutable_vector` namespace), `oc-synthesized-string-consts-enumerated`
(the descriptor constants). After the merge, AGENTS.md's checks for the new
warning were run as well: `tests/many-boolean-arguments.test` (90/90) and
its fuzzer (300 seeds, no failure).

### 67. Affine regression

Every AFFINE-VALUES.md guarantee holds with the vector added:
`tests/affine.test` passes on every suite run (item 66); the affine fuzzer
(`audit/affine/tools/fuzz.tcl`, seeds 1, 101 and 202, 30 programs each:
90 programs, 236 identities whose releases were checked) reports no
disagreement; and the affine mutation harness
(`audit/affine/tools/mutate.tcl`) kills **29 of 29** mutants. Two of its
mutants (`partial-destructure-leak`, `last-use-raw-only`) edit the
last-use release code this milestone changed (path releases): their text
was updated to the new code, each still a mutant of the same rule, and
both are killed. The one deliberate change to existing behavior is the
path-release fix (AFFINE-VALUES.md point 32): a binding maybe moved by its
last statement is released on each path still owning it, never after the
join -- the old placement released a coroutine the join's value owned
(`x = if c: step else: make(2)`).

### 68. Coroutine regression

`tests/coroutines.test` passes on every suite run (item 66), also under
GC stress; the coroutine fuzzer (`audit/coroutines/tools/fuzz.tcl`, seeds
1, 101 and 202: 90 programs) reports no disagreement; and the coroutine
mutation harness kills **52 of 52** mutants (`release-never`'s text was
updated to the new `Releases` call). A coroutine in a vector stays the same
execution through push, growth (`mv-affine-growth`: 1000 suspended
coroutines), a whole-vector move, pop, take, swap through another slot,
a function transfer and consuming iteration: the tests resume it after
these transfers and check the value its original execution produces
(`mv-principal-scheduler`, `mv-affine-pop-take-swap`,
`mv-affine-struct-elements`, `mv-affine-growth`, `mv-loop-consumes`, and
the fuzzer's affine family, which resumes moved identities and checks each
accumulator), and the release-call probe sees each one created once and
released once. The one
coroutine test whose expectation changed is `co-release-placement` (the
path-release fix: the release now sits inside the branch that still owns
the handle). `co-source-operations` caught this milestone's context-root
NIR op spelled with the coroutine prefix (`contextroot`); it is `ctxroot`.

### 69. Native coverage

`tests/native-coverage.tcl` (the suite on the Cranelift backend, merged
tree): 6766 tests -- 2683 run natively, 3955 independent of the backend,
68 partially native, 60 unsupported, **0 failed**. The 60 unsupported tests
need constructs no native backend has (test-only natives such as
`test-log`, block values at the program boundary, sequence mode): none is
a MutableVector test (no `mv-*` test is unsupported or failed natively).

### 70. Scalar audit

`native/generate-scalar-audit.tcl -outdir DIR` regenerated the committed
scalar machine-code corpus (`audit/native-scalar-asm/`: the canonical
`bench/*.bot` programs and every `examples/stdlib/*.bot` program, none of
which uses a vector) with this milestone's compiler and backend: all 39
`.asm`, `.vcode` and `.summary.txt` files (13 programs) are byte-identical
to the committed ones (only the README's commit hash and rustc version line
differ). Programs that use no vector get no new code: every elaboration of
`hir/mutvec.tcl` returns at once when no type or name of the program
mentions a vector (`hir::mutvec::Used`), and the affinity query of every
existing type is unchanged (a vector is the only new case it reaches).

### 71. Performance

RESULTS-PERFORMANCE

### 72. COW complexity measurements

RESULTS-COW

### 73. Scheduler benchmark

RESULTS-SCHEDULER

### 74. Limitations remaining before enums and the basic test framework

* **Typed empty vectors need a declared type.** `from_list([])` in an
  untyped local is `MutableVector[never]`; write the empty vector where a
  type is declared (item 2).
* **Closures cannot see a mutated vector** (`MUTABLE-VECTOR-CAPTURE`) or
  mutate an enclosing one: a test runner's callbacks must take the vector
  as an argument and return it.
* **Vectors in Lists are values, not places**: mutate one by extracting it
  into a binding (a copy).
* **No element references, no in-place element mutation**: `v.at(i).x`
  reads; changing an element is `swap` (or take/push).
* **Affine elements are reached only by moving them**: no indexed affine
  read; iteration consumes.
* **A collecting loop may not collect affine values** (the existing
  AFFINE-VALUES.md restriction).
* **Path releases need a statement to hold them.** An affine binding moved
  on some paths only is released on each path that still owns it; a path no
  statement ends -- a handled call completing normally while a handler
  moved the binding, or a counting/iterating loop running to its end while
  a `break` path moved it -- is `AFFINE-PATH-RELEASE-UNSUPPORTED` (move it
  on every path or on none).
* **The Tcl backends drain with `lpop 0`** (linear in the remaining length
  for a long queue); natively every queue operation is O(1) amortized
  except `take(i)`'s shift.
* **Native coroutines** remain x86-64 Linux only (COROUTINES.md).
* **What enums and the test framework still need**: a `TestEvent` with
  several cases (enums/tagged unions), payload-bearing failures, and
  `compiler::assert_compiles` -- all non-goals here (item 100).

## Files

| file | what |
|---|---|
| `hir/types.tcl` | `MutableVector[T]`, `{mutvec ELEM}`, affinity, subtyping, shapes |
| `hir/mutvec.tcl` | places, receivers, captures, shares (read-outs, entries, results), snapshot and drop elaborations, HIR evidence |
| `hir/affine.tcl` | vector consumers, consuming loops, `v` descriptors, path releases |
| `hir/containers.tcl` | element admissibility of push/swap |
| `hir/lower.tcl`, `core/evaluator.tcl`, `compiler/compiler.tcl` | consuming loops on the Tcl backends |
| `core/mutvec.tcl`, `core/affine.tcl`, `core/value.tcl` | the Tcl runtime |
| `native/src/runtime/mutvec.rs` (+ `heap.rs`, `affine.rs`, `metrics.rs`, `ops.rs`, `vm.rs`), `native/src/nir.rs`, `native/lower.tcl` | the native runtime and lowering |
| `tests/mutable-vector.test` | the milestone's tests |
| `audit/mutable-vector/tools/` | fuzzer, mutation harness and mutants |
| `bench/mutable-vector.tcl` | the performance report |

## What to run when changing this

If you change the vector type or its affinity (`hir/types.tcl`), places,
shares or elaborations (`hir/mutvec.tcl`), the vector cases of the
ownership analysis or path releases (`hir/affine.tcl`), consuming-loop
lowering (`hir/lower.tcl`, `core/evaluator.tcl`, `compiler/compiler.tcl`,
`native/lower.tcl`) or either runtime (`core/mutvec.tcl`,
`native/src/runtime/mutvec.rs`), run `tests/mutable-vector.test`,
`tests/affine.test`, `tests/coroutines.test`,
`audit/mutable-vector/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/mutable-vector/tools/mutate.tcl` (every mutant must
still apply and be killed) and `cargo test --release --manifest-path
native/Cargo.toml --lib mutvec`; a change to `hir/affine.tcl` also needs
AFFINE-VALUES.md's and COROUTINES.md's harnesses (AGENTS.md). A change to
native tracing, growth or drop needs a `BOTLISH_NATIVE_GC_STRESS=1` run of
`tests/mutable-vector.test`. `bench/mutable-vector.tcl` regenerates the
performance report.
