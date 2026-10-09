# MUTABLE-ARRAY.md

Unify mutable collection value semantics: `MutableArray[T]` becomes a
copy-on-write value, affine exactly when its element type is.

> Botlish collection semantics are determined by logical value behavior and
> element ownership, not by implementation history. Immutable collections
> are values; mutable ordinary collections are copy-on-write values;
> collections owning affine elements become affine and move as ownership
> trees. No ordinary collection exposes implicit shared mutable aliasing.
> Repeated-value construction duplicates only unrestricted values, while
> affine-safe population is expressed by factories that produce one owned
> value per element.

MUTABLE-VECTOR.md is the model this milestone extends to the fixed-length
array (header, backing, place, logical copy, detach, consuming iteration);
AFFINE-VALUES.md the ownership discipline; COROUTINES.md the affine element
the scheduler-shaped programs put in it. This report uses MUTABLE-VECTOR.md's
terminology (header, backing, place, place root, logical copy, detach, move,
release).

## Contents

* [The principal program](#the-principal-program)
* [What changed, in one page](#what-changed-in-one-page)
* [Report](#report) -- the 67 points of the milestone report, in order
* [Ownership roles: the audit](#ownership-roles-the-audit)
* [Compatibility](#compatibility)
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## The principal program

```botlish
import coroutine
import mutable_array
import mutable_vector

struct Command:
    value: int

struct Event:
    value: int

fn worker(seed: int, resume Command) -> Event:
    command = yield Event {value: seed}
    return Event {value: command.value + seed}

fn make(seed: int) -> Coroutine{args: [Command], return: Event}:
    coroutine {step} = worker(seed)
    step

fn f() -> List[List[int]] errors IndexNotFound:
    a = mutable_array::create(3, 0)
    b = a
    old = b.swap(0, 9)
    [a.freeze(3), b.freeze(3), [old]]      # [[0, 0, 0], [9, 0, 0], [0]]

fn run() -> List[int] errors IndexNotFound:
    workers = mutable_array::generate(2, make)  # MutableArray[Coroutine{...}]: affine
    first = workers.swap(0, make(10))           # the replacement moves in, the old one out
    a = first(Command {value: 100})
    moved = workers                             # a whole move
    results = loop w in moved:                  # consumes the array, slot by slot
        w(Command {value: 1}).value
    list::append(results, a.value)              # [11, 2, 100]
```

`mutable_array::create(2, make(1))` is `AFFINE-DUPLICATION-UNSUPPORTED` (it
would place one coroutine in two slots), and
`mutable_vector::from_list([mutable_array::create(2, 0)])` is a
`MutableVector[MutableArray[int]]` whose extracted arrays are independent
values. `tests/mutable-array.test`'s `ma-principal-*` tests pin all four on
every backend: natively the copy is one share, the write one detach of three
elements; every coroutine of `run` (the replacement included) is released
exactly once, none swept, also under GC stress.

## What changed, in one page

| | before | after |
|---|---|---|
| `b = a` | one array, two names: `b.set(0, 9)` changed `a` | two logical arrays sharing a backing until the first write |
| `f(a)` mutating its parameter | changed the caller's array | changes the callee's copy |
| a List / struct / vector element | an alias of the array put in | a logical copy (or a move, at a last use) |
| a context member | an alias | a place every function sharing the context mutates; a read-out is a snapshot |
| `MutableArray[Coroutine{...}]` | `AFFINE-CONTAINER-UNSUPPORTED` | an affine array |
| `create(n, affine)` | accepted: one coroutine in N slots | `AFFINE-DUPLICATION-UNSUPPORTED` |
| one value per slot | -- | `mutable_array::generate(n, factory)` |
| `create`, `from_list` | library functions typed by a precomputed container rule | registered intrinsics with ownership roles |
| variance | invariant; typed -> raw/`any` erasure rejected | covariant like MutableVector; erasure holds a copy |
| receivers | any array value | places (`MUTABLE-PLACE-RECEIVER`, `MUTABLE-PLACE-CAPTURE`) |
| runtime | one shared slot vector per array | header over a copy-on-write backing (both runtimes) |

## Report

### 1. Old MutableArray semantics

Reference semantics. A MutableArray value was a handle to one runtime slot
vector (`core::mutarray::store(ID)`; natively `MutArrayObj { slots }`): every
binding, parameter, List element, struct field or context member holding
"the array" held the same object, and `mutable_array::set` through any of
them was seen through all of them. `create` and `from_list` were ordinary
functions of `lib/mutable_array.bot` whose call sites a precomputed
container rule typed (`hir/containers.tcl`, `intrinsicBlocks`), with the
consequence the milestone names: their bodies were never seen by the
ownership discipline, so `create(2, make_coroutine())` compiled and stored
one coroutine in two slots. `MutableArray[T]` was invariant and every
erasure of a typed array was rejected (PARAMETERIZED-MUTABLEARRAY.md): an
erased alias could have stored a value the original's contract excluded. A
MutableArray of affine elements was `AFFINE-CONTAINER-UNSUPPORTED`.

### 2. New MutableArray theorem

A `MutableArray[T]` is a fixed-length mutable VALUE. Copies of an
unrestricted one are logical (copy-on-write): mutating one never changes
another. An array of affine elements is affine: it uniquely owns every
element, moves whole, moves elements across its boundary only through
explicit operations (swap and set in; swap and consuming iteration out; a
factory's results at construction), and releases what it still owns where
it dies. Its length never changes.

### 3. Affinity rule

`Affinity(MutableArray[T]) = Affinity(T)` -- `hir::types::IsAffine`'s
`immutableSet - mutarray - mutvec` case, through every nesting
(`MutableArray[MutableVector[Coroutine]]`, `MutableVector[MutableArray[Coroutine]]`,
`List[MutableArray[Coroutine]]`, a struct field). Mutation alone makes
nothing affine. Pinned: `ma-type-affinity` (eleven types), `ma-nested-affine`.

### 4. COW representation

The MutableVector model, fixed length. A *header* is the identity of one
logical array: on the Tcl backends `{mutarray ID}` over
`core::mutarray::store(ID)`, a Tcl list (Tcl's own copy-on-write); natively
`MutArrayObj { hdr, start, backing: Rc<[Value]> }` (`runtime/value.rs`): the
length never changes, so the backing is one allocation (its count and its
slots), and the array's elements are its slots from `start` on (0 but in an
affine array a consuming loop drains, 22). A copy is a new header over the
same backing; the first write through a header whose backing is shared
detaches it. No runtime ownership state exists (no owner, moved bit or
affine flag); the `Rc` count is copy-on-write bookkeeping only.

### 5. Copy path

The compiler writes every logical copy out (`hir::mutvec::Elaborate`, the
MutableVector pass, now kind-generic): a read-out of a place, the entry of a
value into a place, a consumed parameter's argument -- each
`mutable_vector#share(value, "h")` (`d` inside a generic body, whose
static types are too imprecise to say: a copy of whatever the value is at
run time). Tcl: `core::mutvec::Share` hands an array header to
`core::mutarray::Share` (a new ID over the same Tcl list object). Native:
`mvshare` -> `share_by` -> `ops::share_array`: `Rc::clone` of the backing
and a new header, O(1), counted (`mutableArray shares`).

### 6. Detach path

Native: `ops::array_writable` -- every write -- checks the backing's `Rc`
count; when another header shares it, the header's elements are copied once
into a new backing of their length (one allocation; counted: `detaches`,
`detachElements`), and the old backing stays the other headers'. Tcl:
`lset` on a shared Tcl list duplicates it (Tcl's copy-on-write).
`ma-cow-counters`: one share whatever the length; the first write detaches
once, copying 10 or 1000 elements.

### 7. Unique-write path

A write through a header whose backing is unique mutates in place: no
detach, no allocation (`ma-cow-counters`: three writes, one detach;
`mutarray_copy_shares_and_only_the_first_write_detaches` in
`runtime/ops.rs`).

### 8. Place semantics

MutableVector's (`hir::mutvec::verify`): a mutating operation's receiver
(its registration's `place` role) must be a place -- a local, parameter or
context parameter of the same function, or a field path from one. A
temporary or a value of a known non-array type is
`MUTABLE-PLACE-RECEIVER`; a nested function mutating or capturing an array
its function mutates is `MUTABLE-PLACE-RECEIVER` / `MUTABLE-PLACE-CAPTURE`
(the diagnostics were `MUTABLE-VECTOR-*` and are shared now). An untyped
generic parameter may be a place: its argument is copied for it (by the
caller when the parameter is consumed); inside a generic body, where the
static type is too imprecise to say, a binding or struct field taking the
parameter copies it dynamically (`d`). `ma-place-receiver`,
`ma-generic-place`, `ma-cow-extraction` (its last two routes are the ones
that reach `d`; the mutation harness's `generic-identity-aliases` needs
them).

### 9. Parameter semantics

Unrestricted: the callee owns a logical copy -- made on entry, or by the
caller for a *consumed* parameter (a directly called function that needs an
exclusive header), or not at all for an *observed-only* parameter (the
callee only reads while the caller waits): hir/mutvec.tcl's "Last uses and
consumed parameters". A builder threaded through calls is mutated in place:
`hashtable.bot`'s updates and `csv_chunked.bot`'s appends make no share and
no detach (`paramagg-hashtable-2`, native counters). Affine: the array moves
into the callee. `ma-cow-routes` (route 2), `ma-affine-whole-moves`.

### 10. Return semantics

A result is a value: a function returning its own place's header moves it
out; anything else read out of a place is a copy unless it is the place's
last use. Affine: the result moves to the caller. `ma-cow-routes` (route 3),
`ma-cow-surviving-result` (a result returned while another copy survives).

### 11. Generic-call semantics

A copy inside a generic (untyped) body is dynamic (`d`: whatever the value
is at run time); a semantic instance analyzes the body at the argument's
type; an affine argument
specializes the function (AFFINE-VALUES.md's monomorphization). The
identity and wrapper regressions MUTABLE-VECTOR.md found are pinned for
arrays from a fresh, never-mutated source: `ma-cow-routes` routes 4 and 5
(`same(x)`, `wrap(x)` = `{data: x}`), and the fuzzer's copy routes draw a
fresh source half the time.

### 12. Struct-field semantics

A struct literal holds a copy of the array put in (descriptor `s`N...); a
field path (`b.values`) is a place; a projection read out of it is a copy;
a destructured binding is a copy (`destructure-bound-mutable-value-is-the-same-value`
now pins independence). An affine array makes its struct affine.
`ma-cow-routes` route 6 (`Box {values: a}`); `ma-cow-extraction` (a
projection, a destructure, an anonymous struct's field and a struct
parameter's field, each mutated while the struct is read afterwards).

### 13. List-element semantics

`[a]` holds a copy (a move at `a`'s last use); `list::at(xs, 0)` bound to a
place is a copy: mutating it changes neither the List nor `a`
(`ma-cow-routes` route 7). A List of affine arrays is affine (moves whole;
element-wise reads are rejected as for every affine List).

### 14. MutableVector-element semantics

`mutable_vector::from_list([a])` holds a copy; `v.at(0)` read into a place
is a copy (route 8, `ma-principal-vector-of-arrays`). Affine: `at` is
`AFFINE-ELEMENT-COPY-OUT`; push/pop/take/swap move whole arrays
(`ma-nested-affine`, `ma-affine-whole-releases`).

### 15. Context-field semantics

`context struct C: values: MutableArray[int]` -- `c.values.set(...)`
mutates the context member place; `snapshot = c.values` is an independent
copy (`ma-context-member`). Natively the member's header is a permanent GC
root installed with the context (`ctxroot`, now for arrays as for vectors;
before, an array member was `CONTEXT-NATIVE-LOWERING-UNSUPPORTED`).

### 16. Unrestricted indexed read

`mutable_array::at(a, i)` returns the element (a value; a collection element
read into a place is copied like any read-out). `ma-ops`.

### 17. Affine indexed-read rejection

`at`, `freeze`, `#to_list` and a `copy`'s source have the `copy-out` role:
for an affine array they are `AFFINE-ELEMENT-COPY-OUT` (MutableVector's
`AFFINE-VECTOR-COPY-OUT`, renamed for both), naming swap and consuming
iteration as the moves. `mutable_array::get` (library) inherits it through
its call of `at`. `ma-affine-at`.

### 18. Fixed-size replacement/swap semantics

`old = a.swap(i, x)`: X moves into slot I, the old element out to the
result; the length is unchanged. Out of range: IndexNotFound, nothing
changes. `set(i, x)` is the swap whose old element is discarded. No `take`,
`pop`, holes or optional slots exist. `ma-ops`, `ma-affine-swap`.

### 19. Affine swap ownership

The replacement's source binding is moved (role `move`); the result owns
the displaced element; a discarded result is released right after its
statement (`ma-affine-swap`: release order `2 1 4 3` -- the displaced
element at its last use, the discarded one after the swap, then the loop's
two). An affine `swap`/`set` is elaborated to `#swap_drop`/`#set_drop`
carrying the element's drop descriptor (`set` releases what it displaces).

### 20. Failed affine swap cleanup

`#swap_drop` with no slot at I releases the replacement it already owns,
leaves the array unchanged and propagates IndexNotFound; the source binding
stays moved (`USE-AFTER-MOVE`). No transactional rollback.
`ma-affine-swap-failure` (order `3 1 2`: the replacement, then the array the
callee owned as the error leaves it).

### 21. Unrestricted iteration

`loop x in a` over an unrestricted array iterates a snapshot
(`mutable_array#to_list`): mutating the array or another copy inside the
loop changes neither the domain nor the copy (`ma-cow-loop`).

### 22. Affine consuming iteration

The loop consumes the array: the binding is moved at loop entry and each
iteration moves the next element (lowest index first) into the loop
variable (`mutable_array#take_front`; natively `mutarrayempty` /
`mutarraytakefront` on the header register).

### 23. Exit cleanup

`continue`, `break`, `return`, `fail` and a propagated declared error
release the current element (if still owned) and every element not yet
taken, first to last -- hir/affine.tcl's loop domain, kind-generic --
on every backend (`ma-consuming-exits`: five exits, order `1 2 3 4`, four
releases natively, none swept). The fuzzer found this broken natively for a
loop in a callee: the specialization key erased an affine array to the raw
kind, so the instance saw an unrestricted array and dropped nothing; the key
now keeps an affine array's element (`hir::specialize::ElementKeyType`),
and an instance's entry combines the declared element contract with it
(`hir::types::narrow`).

### 24. Drop order

Lowest index to highest (`core::mutarray::DropElements`,
`ops::drop_array_elements`, descriptor `a`D): `ma-drop-order` (also inside a
struct), and the fuzzer's release-group check.

### 25. Repeated-value constructor

`mutable_array::create(n, x)`: N slots holding X -- one value logically
placed N times, still O(n) slot writes and no element copy. For an
unrestricted X that is itself a collection, the slots are N logical copies:
mutating one slot's vector changes neither the others nor X
(`ma-cow-repeated-copy`).

### 26. Affine rejection for repeated-value constructor

X has the `repeat` role: an affine X -- a coroutine, an affine struct, a
vector of coroutines -- is `AFFINE-DUPLICATION-UNSUPPORTED`, wherever it
reaches `create`, also through a user's generic or typed wrapper
(`ma-principal-create-rejects`, `ma-duplication-generic`).

### 27. Factory constructor

`mutable_array::generate(n, factory)`: slot I holds `factory(I)`, I from 0
to N - 1, in order (`ma-ops`: `generate(3, tens)` is `[0, 10, 20]`). The
factory is an ordinary named function (no lambda syntax was added).

### 28. Factory callable contract

The factory is called with one Int: its contract must take exactly one
parameter admitting every Int (`hir::containers::VerifyFactory`; a
refinement parameter, two parameters or a coroutine handle are `TYPE`). Its
declared errors are the call's (`-errors-from`, a `-completion` native):
handled or declared by the caller like any call's (`UNHANDLED-ERROR`
otherwise). `ma-generate-contract`, `ma-generate-failure`.

### 29. Factory affine results

Each result moves into its slot (`ma-principal-generate`: two distinct
coroutines). The factory itself has the `factory` role: only called, never
stored; an affine callable as factory would be rejected (no affine callable
takes an Int today: a coroutine's resume message is a struct).

### 30. Partial factory failure cleanup

The first failing call ends the construction: the elements already made are
released, first to last, and its error propagates; no array exists
(`mutable_array#generate_drop`, the dropping form an affine `generate` is
elaborated to; Tcl `core::mutarray::Generate`, native `ops::generate`, the
array under construction rooted across calls). `ma-generate-failure`:
two releases in order on both Tcl backends, natively and under GC stress.

### 31. Stdlib/native ownership metadata

`-ownership` (core/native.tcl): one role per parameter of a native, read by
the ownership discipline (`hir::affine::NativeConsumer`) instead of any
name. The roles: `observe`, `place`, `move`, `element`, `repeat`, `factory`,
`copy-out`, `equality`, `resume`, `message`, `release`, `erase` (the
default). Beside it, the registration carries what the passes used to key on
names: `-drop-form` (the element-dropping variant), `-result-length` (a
constructor's length for hir/cardinality.tcl), `-errors-from`, and the
receiver role that makes a native a collection operation
(`hir::mutvec::OpKind`).

### 32. Ownership-role representation

A list of role words per registration (`-ownership {place observe move}`);
for an arity-`*` native the last role repeats. `core::native::ownershipRole
NAME INDEX` answers for one argument. Compile-time semantics only: no
runtime check, flag or dispatch exists.

### 33. Library-signature ownership fix

The constructors whose bodies the discipline never saw became intrinsics
with roles (`create` repeat, `from_list` move, `generate` factory); the
container rules (hir/containers.tcl) are type rules only now. A library
*function* (`mutable_array::get`) is ordinary Botlish whose body the
discipline analyzes like the program's. No check is keyed on a name:
`mat-id-4` fences `hir/`, `compiler/` and `surface/`, and the roles,
drop forms and lengths moved into the registrations to satisfy it. The
theorem -- no library primitive can do what equivalent user code could not --
holds because a primitive's only ownership behavior is its roles, and the
roles say exactly what its implementation does.

### 34. Audited primitives

See [Ownership roles: the audit](#ownership-roles-the-audit) (pinned by
`ma-roles-audit`).

### 35. Remaining intentionally unsupported primitive patterns

* `ImmutableSet[affine]` stays `AFFINE-CONTAINER-UNSUPPORTED`: a set
  compares and hashes its members.
* A List has no element-wise move-out (its affine reads stay rejected).
* An affine callable as a factory: rejected by role, unreachable today.
* The byte stores take only Bytes (role default `erase`, which an
  unrestricted argument never triggers).
* `mutable_vector#share` is compiler-written and never given an affine
  value.

### 36. MutableArray in MutableVector

`MutableVector[MutableArray[T]]`: unrestricted when T is; an extracted
array is an independent value (`ma-principal-vector-of-arrays`, route 8);
affine when T is, with push/pop/take/swap moving whole arrays
(`ma-nested-affine`). Written as a type, either nesting is legal
(`ma-type-syntax`, which the mutant `vector-of-arrays-rejected` needs: the
other tests only build the nesting by inference).

### 37. MutableArray in List

`List[MutableArray[T]]` keeps working, now with value semantics: route 7
regresses the old aliasing (the List element and the extracted copy are
independent).

### 38. MutableVector in MutableArray

`MutableArray[MutableVector[int]]` by `create(3, vector)` holds three
logical copies (`ma-cow-repeated-copy`); `MutableArray[MutableVector[Coroutine]]`
by a factory is affine and releases every coroutine once
(`ma-nested-affine`).

### 39. Nested affinity derivation

Compositional, by `hir::types::IsAffine` alone (`ma-type-affinity`); the
mutant `nested-affinity-shallow` is killed.

### 40. Equality/hash interaction

Unchanged: `==` of two arrays is the run-time EQUALITY error it always was
(no header or backing identity reaches equality); `hash` is undefined for
them; affine arrays are `AFFINE-EQUALITY-UNSUPPORTED` (`ma-equality`).

### 41. Bounds-error behavior

Unchanged: `IndexNotFound` for an index that designates no slot (at, set,
swap -- handleable, nothing changes), `LowerUnderrun`/`UpperOverrun` for a
bad slice (freeze, copy), `RANGE` for a negative capacity (`ma-ops`). A
statically known failure is still the compile-time `KNOWN-ERROR`.

### 42. HIR type

`{mutarray T}`, shown `MutableArray[T]`; the raw kind `mutarray` is
MutableArray[any]. Subtyping is covariant like MutableVector's (a copy never
writes through), lub joins elements, and a typed parameter admits exactly
its contract (`hir::range::AggregateAdmits`, as for List and MutableVector).
A typed array bears only what its elements bear
(`hir::callables::Bearing`): erasing one into `any`, the raw kind or an
untyped aggregate is accepted and holds a copy (`mat-atk-*`, rewritten).

### 43. HIR ownership evidence

`hir::format` shows the dropping forms (`mutable_array#generate_drop`,
`#swap_drop`) with their descriptor constant (`c`), the consuming loop
(`listloop ... consuming`), the copy (`mutable_vector#share` with `h`), the
mutated places (`place=`) and the release items (`release=`,
`release=IndexNotFound=` for an error exit): `ma-hir-evidence`.

### 44. Core IR lowering

`hir/lower.tcl`: shares, drops and dropping forms are ordinary native calls;
a consuming loop over an array lowers through `ConsumeNativeOf` /
`ConsumedKind` to `mutable_array#consume` and the drain (`#take_front`); the
releases are the AFFINE-VALUES.md machinery.

### 45. Tcl interpreter representation

`core/mutarray.tcl`: `{mutarray ID}` headers over `store(ID)`; `Share`
(a new ID over the same Tcl list), `DropElements` (first to last, emptying
the dying array first), `Generate` (factory calls through
`core::callable::invoke`, dropping what it made on failure), `swapDrop`,
`setDrop`, `takeFront`; counters (`created`, `shares`) for tests. The
consuming loop (`core::forms::ConsumeVector`) drains a vector or an array
(`core::mutvec::remaining`/`drainFront`).

### 46. Tcl compiler lowering

`compiler/compiler.tcl`'s consuming listloop emits the same drain
(`remaining`/`drainFront`) for either collection.

### 47. Native representation

`MutArrayObj { hdr, start, backing: Rc<[Value]> }` (4); `mutarray_of`,
`array_writable` (detaching), `array_owned` (an affine array's backing,
never shared: a panic would be an ownership invariant violation, never
reached), `share_array` (the header's `start` with the backing),
`drop_array_elements` (the elements leave the dying array by its `start`
moving past them), `array_elements` (trace: the slots from `start`). The
consuming loop's `mutarraytakefront` advances `start` past the element it
moves out: it never writes the backing, so it never detaches; the drained
slots are freed with the header.
The host round trip carries an array as `mutarrayitems` (an array can be a
program's result now) and show prints its elements (`<mutable-array [...]>`,
as a vector's).

### 48. Native lowering

`native/lower.tcl`'s natives table maps every array operation to one NIR op
(`mutarraycreate`, `mutarrayfromlist`, `mutarraygenerate`,
`mutarraygeneratedrop`, `mutarrayswap`, `mutarrayswapdrop`,
`mutarraysetdrop`, `mutarraytolist`, `mutarrayempty`, `mutarraytakefront`,
plus the existing get/set/copy/freeze and their proven forms); the copy is
`mvshare` (kind-dispatched); the consuming loop drains by `mutarrayempty` /
`mutarraytakefront`; drops are `affinedrop` by `a`D; a context member gets
`ctxroot`. `ma-native-evidence` pins the ops of an affine and an
unrestricted function. The fuzzer found the virtualized-struct drop path
(`DescriptorSkip`) not skipping `a`: fixed.

### 49. GC tracing

The collector traces every header's backing elements (`heap.rs`,
`KIND_MUTARRAY`); a shared backing is traced through each header (marking,
not ownership); `array_object_size` charges each header its share of the
backing. A context member's header is a permanent root.

### 50. GC stress

`BOTLISH_NATIVE_GC_STRESS=1`: the principal program, factory failure and
nested affine collections (`ma-principal-generate-native`,
`ma-generate-failure`, `ma-nested-affine`), the hashtable and csv suites,
`mutarray_operations_survive_a_collection_at_every_allocation` (Rust), the
fuzzer with `-gc-stress 1`, and the full suite (see 56).

### 51. COW instrumentation

Native `mutableArray` report section: `reads`, `writes` (as before) and now
`shares`, `detaches`, `detachElements` (one section: a first version shadowed
the read/write counters with a second section of the same name; fixed).
Tcl: `core::mutarray::counters` (`created`, `shares`). `ma-cow-counters`,
`ma-principal-copy`, `mutarray-builder-scaling-1` (no detach).

### 52. Aliasing regression tests

`ma-cow-routes` (binding, parameter, result, identity, generic identity and
wrapper, struct field, List element, vector element, nested aggregate),
`ma-cow-surviving-result`, `ma-cow-extraction`, `ma-cow-loop`,
`ma-cow-repeated-copy`, `ma-context-member`, `mat-run-4/6/8`, `mutarray-sem-4/7`,
`tmb-alias-2`, `destructure-bound-mutable-value-is-the-same-value`: each
used to pin aliasing (or would have observed it) and now pins independence.

### 53. Generic-function regression tests

`ma-cow-routes` routes 4 and 5 from a fresh, never-mutated array (the class
of MutableVector's bug: a generic function's result treated as fresh),
`ma-generic-place`, `mat-atk-12`, `si-run-1`; the fuzzer's `ident`, `same`,
`wrap`, `either` routes with a fresh source half the time.

### 54. Fuzzer design/results

`audit/mutable-array/tools/fuzz.tcl`: two families (unrestricted and
affine) against an independent model (pure sequences per place; one owner
per coroutine identity), every backend, Tcl release obligations (each
identity exactly once; every group dropped together first to last), native
release counters, optionally GC stress. See the file's header for the
operation list (it covers every item of the brief's list, nested vectors
included); every index is `I + zero` with `zero` unknown statically (an
array's length often is known: a known failure is a compile-time error).
Results (every backend: interpreter, Tcl compiler, `cranelift-generic`,
`cranelift`; native release counters on):

| seed | programs | accepted | identities checked | disagreements |
|---|---|---|---|---|
| 1 | 40 | 25 | 175 | 0 |
| 2 | 40 | 25 | 168 | 0 |
| 3 | 40 | 26 | 168 | 0 |
| 4, `-gc-stress 1` | 25 | 16 | 107 | 0 |

The rejected programs are the injected faults, each with its predicted
diagnostic (seeds 1-4: `MUTABLE-PLACE-CAPTURE` 16, `MUTABLE-PLACE-RECEIVER`
15, `TYPE` 8, `AFFINE-DUPLICATION-UNSUPPORTED` 7,
`AFFINE-ERASURE-UNSUPPORTED` 4, `AFFINE-ELEMENT-COPY-OUT` 3). While it was being written the fuzzer found the two native drop
bugs of 23 and 48. The mutation harness (55) then showed it missing four
copy routes -- a List element read into the driver's own binding, a struct
field projected out or returned from a struct parameter, and a generic
body's dynamic copy -- which it now generates.

### 55. Mutation results

`audit/mutable-array/tools/mutate.tcl` with `mutants.txt` (the brief's list,
item 57, mapped to this representation; the two with no separate
non-equivalent mutant are explained in the file).

**31 mutants, 31 killed.** The first run (against the tests of the time)
killed 28; three survived (`generic-identity-aliases` and its native
twin, `struct-extraction-aliases`: no test copied an array inside a
generic body or out of a struct field into a mutated binding), and
`vector-of-arrays-rejected` was killed by the fuzzer alone (no test wrote
the nested type). `ma-cow-extraction` and the nested cases of
`ma-type-syntax` were added; a re-run of those four killed all four by
tests. Per mutant (first run, plus the re-run for those four):

| mutant | tests failed | fuzz (seed 11) | Rust |
|---|---|---|---|
| `copy-aliases-tcl` | 7 (`ma-context-member`, ...) | 4/25 | -- |
| `param-mutation-leaks` | 3 (`ma-cow-routes`, ...) | 2/25 | -- |
| `result-aliases-surviving` | 1 (`ma-context-member`) | survived | -- |
| `generic-identity-aliases` | 1 (`ma-cow-extraction`) | survived | -- |
| `list-extraction-aliases` | 1 (`ma-cow-routes`) | survived | -- |
| `struct-extraction-aliases` | 1 (`ma-cow-extraction`) | survived | -- |
| `context-snapshot-aliases` | 1 (`ma-context-member`) | survived | -- |
| `array-always-affine` | 16 (`ma-context-member`, ...) | 25/25 | -- |
| `affine-array-unrestricted` | 13 (`ma-affine-at`, ...) | 12/25 | -- |
| `nested-affinity-shallow` | 2 (`ma-nested-affine`, `ma-type-affinity`) | 5/25 | -- |
| `vector-of-arrays-rejected` | 1 (`ma-type-syntax`) | 25/25 | -- |
| `affine-at-accepted` | 2 (`ma-affine-at`, `ma-roles-audit`) | 2/25 | -- |
| `swap-duplicates-replacement` | 8 (`ma-affine-swap`, ...) | 25/25 | -- |
| `failed-swap-keeps-replacement` | 1 (`ma-affine-swap-failure`) | 2/25 | -- |
| `drop-leaks-elements` | 5 (`ma-affine-swap-failure`, ...) | 8/25 | -- |
| `drop-order-reversed` | 5 (`ma-affine-swap-failure`, ...) | 7/25 | -- |
| `loop-aliases-element` | 3 (`ma-consuming-exits`, ...) | 2/25 | -- |
| `loop-leaks-suffix` | 1 (`ma-consuming-exits`) | 2/25 | -- |
| `instance-key-erases-affine-array` | 2 (`ma-affine-swap-failure`, `ma-consuming-exits`) | 1/25 | -- |
| `create-accepts-affine` | 3 (`ma-duplication-generic`, ...) | survived | -- |
| `signature-ignores-repeat` | 2 (`ma-duplication-generic`, `ma-principal-create-rejects`) | survived | -- |
| `factory-result-duplicated` | 10 (`ma-affine-swap`, ...) | 10/25 | -- |
| `factory-failure-leaks` | 1 (`ma-generate-failure`) | 3/25 | -- |
| `factory-not-dropping-form` | 3 (`ma-generate-failure`, ...) | 3/25 | -- |
| `virtual-struct-drop-truncated` | 1 (`ma-drop-order`) | 1/25 | -- |
| `copy-aliases-native` | 8 (`ma-context-member`, ...) | 4/25 | 3 Rust tests |
| `copy-eager-deep-native` | 2 (`ma-cow-counters`, `ma-principal-copy`) | survived | 2 Rust tests |
| `generic-identity-aliases-native` | 1 (`ma-cow-extraction`) | survived | survived |
| `failed-swap-keeps-replacement-native` | 1 (`ma-affine-swap-failure`) | 2/25 | survived |
| `drop-leaks-elements-native` | 5 (`ma-affine-swap-failure`, ...) | 8/25 | survived |
| `factory-failure-leaks-native` | 1 (`ma-generate-failure`) | 3/25 | survived |

The fuzz column is the fuzzer as the first run had it (25 programs, seed
11). What it missed it now generates: the copy routes of 54, and its
`create`-repeats-a-handle fault (`AFFINE-DUPLICATION-UNSUPPORTED`, which
kills `create-accepts-affine` and `signature-ignores-repeat`) used to need
a live handle binding, rare by the time faults are drawn, so no run drew
it; it makes one now. `copy-eager-deep-native` is a cost, not a value: the
copy counters of the tests and the Rust tests see it, no program's result
can.

### 56. Full regression

On the final tree (159 test files; `tests/mutable-array.test` has 32 tests,
`tests/mutable-vector.test` 53):

| run | total | passed | skipped | failed |
|---|---|---|---|---|
| `BOTLISH_NATIVE_GC_STRESS=1 CORE_BACKEND=interp tclsh9.0 tests/all.tcl` | 6801 | 6801 | 0 | 0 |
| `CORE_BACKEND=compile tclsh9.0 tests/all.tcl` | 6801 | 6797 | 4 (`coreScoping`) | 0 |
| `BOTLISH_NATIVE_GC_STRESS=1 cargo test --release` (native) | 240 | 240 | 0 | 0 |

Both suite runs were repeated after the last code change (`Captured`,
csv_chunked's typed builder parameters), with the same numbers. The
GC-stress run is the CI `gc-stress` job's (both its steps). The runs
before them, on an earlier tree, failed four tests -- two corpus counts
already updated, `paramagg-chunked-2` and `mat-fence-1`, both pinning the
old `csv_chunked.bot` (Compatibility) -- and are what those updates fixed.

### 57. Affine regression

`tests/affine.test` (one expectation changed: a MutableArray of affine
elements is legal now), `audit/affine/tools/fuzz.tcl`,
`audit/affine/tools/mutate.tcl` (one mutant re-pointed: `list-no-consume`).
Fuzzer: seeds 1 and 2, 30 programs each (23 accepted, 91 and 92 identities
whose releases were checked), 0 disagreements. Mutation: **29 mutants, 29
killed** (`list-no-consume` by 4 tests and 3 of 25 fuzz programs).
`tests/affine.test`: see 56.

### 58. Coroutine regression

`tests/coroutines.test` (three programs observed effects through an aliased
array argument; they use a context member now),
`audit/coroutines/tools/fuzz.tcl` (its checksum log likewise),
`audit/coroutines/tools/mutate.tcl` (two mutants re-pointed:
`step-call-moves`, `done-consumes` -- the latter is a role change now).
Fuzzer: seeds 1 and 2, 50 programs each (36 accepted; early exits releasing
coroutines: 74 and 69), 0 disagreements. Mutation: **52 mutants, 52
killed** (`step-call-moves` by 33 tests, `done-consumes` -- `observe`
turned into `move` -- by 8). `tests/coroutines.test`: see 56.

### 59. Mutable-vector regression

`tests/mutable-vector.test` (diagnostic codes renamed; one program and its
expected copy counts), `audit/mutable-vector/tools/fuzz.tcl`,
`audit/mutable-vector/tools/mutate.tcl` (thirteen mutants re-pointed at the
metadata-driven code: roles, drop forms, the kind-generic snapshot and
drain). Fuzzer: seeds 1 and 2, 40 programs each (25 accepted, 222 and 213
identities checked), and seed 3 with `-gc-stress 1` (25 programs, 188
identities), 0 disagreements.

Mutation: **45 mutants, 45 killed** -- after one fix. The first run killed
42; `callee-mutation-leaks`, `fresh-result-unowned` and
`affine-move-cow-fork` survived, all three killed by tests before this
milestone. The cause is this milestone's copy convention ("Last uses and
consumed parameters" in hir/mutvec.tcl): a directly called function's
parameter is now copied (or moved) by its caller, so the callee's entry
copy, the fresh-result rule and the affine check of a share are reached
only by a function that is also used as a value and called indirectly --
and no test did that. `mv-cow-indirect-callee` does it for each (a
mutating callee passed to a higher-order function, a function returning
its unmutated parameter also passed as a value, an affine vector entering
an indirectly called function: natively 0 shares and 0 detaches, against 1
and 1 under `affine-move-cow-fork`); a re-run killed all three by it.
`ma-cow-routes` gained the array route.

### 60. Native coverage

`tests/native-coverage.tcl` (the suite on the Cranelift backend, final
tree): 6801 tests -- 2713 run natively, 3959 independent of the backend, 69
partially native, 60 unsupported, **0 failed** (MUTABLE-VECTOR.md: 6766 --
2683, 3955, 68, 60, 0). The 60 unsupported tests need exactly what
README.md's coverage table lists, in the same numbers (a Block value at the
program boundary 13, `test-log`/`test_log` 19, `test-tick`/`test_tick` 12,
sequence mode 7, test validators and natives 7, a validator contract 2);
none is an array or vector test. 64 of the 69 partially native tests pass
natively specialized and compare an unspecialized (`cranelift-generic`)
build that a struct projection on an untyped receiver makes unsupported
(`struct-shape`): the HashTable and csv_records programs -- generically
unsupported before this milestone too -- and struct tests; no `ma-`, `mv-`
or `mat-` test is among them. A run before `csv_chunked.bot`'s builder
functions declared their parameter's type counted 94: its 26 corpus and
growth tests had joined them (66).

### 61. Scalar audit

`native/generate-scalar-audit.tcl` regenerated `audit/native-scalar-asm/`
(committed). Every program that uses no array is byte-identical to the
previous corpus (the four `bench/` programs, `ai_text_clean`, `csv`,
`matmul`, `string_replace`, `string_reverse`: `.asm`, `.vcode` and summary
unchanged). The four that use arrays changed because their sources did
(`csv_chunked`, `csv_records`, `hashtable` were rewritten to stop relying on
aliasing; `csv_geometric` lost the generic `mutable_array::create` wrapper
instances): 194 → 177 functions, 83843 → 74702 machine-code bytes in total
(`csv_chunked` 10219 → 7334, `csv_geometric` 7877 → 6849, `csv_records`
23429 → 20163, `hashtable` 12845 → 10883). Their scalar helpers (`peek`,
`scan_quoted`, `scan_unquoted`, `scan_field`, ...) compile to the same
instruction streams; with addresses normalized the only difference is one
load's static-table offset in `csv_records` (`[rax+X]` → `[rax]`: fewer
statics precede it), plus the constant pool's alignment padding.

### 62. Performance

`tclsh9.0 bench/mutable-array.tcl` (n = 2000 operations per program on the
Tcl backends, 200 000 natively, coroutine programs natively at most 20 000;
best of 5; the machine otherwise idle -- a first run beside a test suite
measured the native affine construction at 57.6 us per slot, an artifact of
the load). Per operation; in parentheses the whole program per operation;
a baseline's own cost is subtracted, so a difference within the noise can
come out negative.

| operation | Tcl interp | Tcl compile | Cranelift |
|---|---:|---:|---:|
| List construction (collecting loop), per element, for comparison | 26167 ns | 1342 ns | 40 ns |
| `create(n, 0)`, per slot | 644 ns | 482 ns | 0 ns |
| `from_list`, per element over building the List | -942 ns | 193 ns | -5 ns |
| `generate(n, tens)`, per slot (one factory call each) | 61634 ns | 9206 ns | 13 ns |
| `at` | 62011 ns | 6122 ns | 40 ns |
| `set` on a unique array (no detach) | 76344 ns | 6456 ns | 45 ns |
| `swap` (unrestricted) | 73452 ns | 6659 ns | 41 ns |
| iterate an unrestricted array (snapshot), per element | 22216 ns | 1268 ns | 51 ns |
| MutableVector `at` / `swap`, for comparison | 68280 / 76592 ns | 13855 / 15324 ns | 73 / 38 ns |
| MutableBytes `replace` on a unique store, for comparison | 257276 ns | 24084 ns | 94 ns |
| create and release a coroutine (no array) | 417880 ns | 97912 ns | 935 ns |
| `generate(n, make)`, per slot, the array dropped whole | 415566 ns | 148417 ns | 35814 ns |
| swap a coroutine in, the displaced one released (over create and release) | 124747 ns | 28010 ns | -19 ns |
| consume an affine array in a loop, per element (over generate and drop) | 127805 ns | 10314 ns | -74 ns |
| `MutableVector[MutableArray[int]]`: push a 2-slot array, pop it | 227056 ns | 26112 ns | 194 ns |
| `MutableVector[MutableArray[int]]`: copy an element out, write it | 246000 ns | 42814 ns | 254 ns |
| `MutableVector[MutableArray[Coroutine]]`: push a generated 2-slot array, pop it | 1082606 ns | 267283 ns | 2079 ns |

Natively every unrestricted operation is one runtime call with its bounds
check (40-45 ns), of the order of the vector's; `create` fills its slots
with one repeated value (no per-slot work worth measuring); `generate`
costs a direct call per slot. For coroutines the array adds nothing
measurable: swapping one in and consuming the array cost what creating,
releasing and dropping them do, within the noise. What does cost is
holding N coroutines suspended at once: about 36 us each natively, which is
mapping N native stacks (the pool keeps 32), not the array -- a vector
holding N coroutines measured 39.6 us each in a run right after
(MUTABLE-VECTOR.md's 21 us was measured on another machine).

**Copy-on-write complexity** (K = 200 copies of an S-element array per
program; per copy, Cranelift):

| S | copy | copy, then its first write | elements copied by detaches (counter) |
|---:|---:|---:|---:|
| 10 | 48 ns | 48 ns | 2 000 |
| 1 000 | 96 ns | 2 073 ns | 200 000 |
| 10 000 | 46 ns | 25 995 ns | 2 000 000 |

Every program makes exactly 200 shares; the copy costs the same at every S
(O(1): a new header over the shared backing); the first write through a
copy detaches once, copying its S elements (about 2-2.6 ns per element);
200 000 writes to one unique array make no share and no detach. The vector
rows have the same shape (each copied vector also holds the element its
program pushes: 2 200, 200 200, 2 000 200). On the Tcl backends a copy is
O(1) as well (a shared Tcl list); the first write's O(S) shows on the Tcl
compiler (20 us at S = 10, 75 us at S = 10 000); the interpreter's own cost
per operation buries it.

**Scheduler-shaped construction** (`sched-8`: N workers from
`generate(n, worker)`, 8 rounds over the array -- swap a worker out, resume
it, swap it back -- then a consuming loop): 8.9 us per resume step natively
(185 us Tcl compile, 1.1 ms Tcl interp); N = 2000: 2001 stacks mapped,
15 999 reused, 18 000 released, none swept; no array share or detach (an
affine array is never shared). Of the 8.9 us, about 4.5 us is the 2000
workers' stack mappings spread over the 16 000 steps, and about 0.9 us the
placeholder each step swaps in to take a worker out (`q.swap(i, make(0))`:
a slot cannot be empty, so the step creates and releases one coroutine --
the 15 999 reused stacks). With an `Option` element (67) a step would swap
`None` in instead.

**The corpus, before and after** (the commit before this milestone, its
native backend built from that tree, against this one; the same machine,
otherwise idle; native times are best of many runs and still vary by up to
+-40% at the largest sizes, so only differences that repeat are stated):

* *Compile time* (frontend and native lowering of every corpus program, best
  of 3, second of two rounds): within -19 % .. +9 % of before, most
  programs faster; `csv_chunked` +9 % (its source changed). A generated
  800-statement function compiled 3x slower at first -- the convention's
  `Eligible` rescanned the program for every binding on every pass -- and
  is now within 15 % of before (8.7 s against 7.6 s; `Captured` computes the
  set once).
* *HashTable* (`bench/hashtable.tcl`, which had stopped running before this
  milestone: a quoting slip, and programs that discarded every update's
  result; fixed). Operations still allocate nothing (alloc/op 0 for hit,
  miss, replace at every size). A presized table is 5 objects instead of 4
  (the struct replaces the outer array; the counts get their own array); a
  resize allocates 5 instead of 3 (four arrays and the struct). Creating
  1000 tables: 287 us against 265 us; filling 1000 presized 7-entry tables:
  1.10 ms against 1.18 ms; 1000 default tables (one resize each): 2.03 ms
  against 1.86 ms. Operation times on small and medium tables are equal or
  lower in both rounds; at 100 000 entries the runs vary more than the
  trees differ (identical GC cycles and peak).
* *csv_geometric*: the same allocations (2.7 % fewer bytes), 2 fewer
  guards; times within the noise.
* *csv_chunked*: one more allocation per builder (its `filled` counter is a
  one-slot array, where the List-shaped builder kept an Int its native
  lowering scalar-replaced): 319 564 against 299 240 objects at 10 000
  rows, 7-24 % slower at 1 000 and 10 000 rows. An Int field rebuilt by
  every append was tried and is worse (a struct per append: 359 260
  objects, no faster).
* *csv_records* (realistic schema, 1000 rows, best of 28 runs each):
  parsing alone 3.73-3.82 ms against 3.51-3.66 (+5 %), default row tables
  6.62-6.68 against 5.73-5.78 (+16 %), presized 5.78-5.82 against
  5.23-5.26 (+11 %). It executes fewer instructions (callgrind: 182.9 M
  against 192.9 M, compilation included) but 13 500 more `malloc` calls
  (103 017 against 89 492): every array is now a header and an
  `Rc`-counted backing -- one more allocation per array, the
  representation MutableVector has had since its milestone -- plus the
  HashTable structs. A fixed-length array could keep its backing in one
  allocation (`Rc<[Value]>`: it never grows); that was left to a
  follow-up, now made (next paragraph).

**One-allocation backing** (the follow-up: `Rc<VecDeque<Value>>` became
`Rc<[Value]>` and the header's `start`, 4 and 47). An array is now its
header and one backing allocation, the backing's counts and slots together,
for every constructor; a copy allocates its header only, the first write
through it the detached backing only, and later writes, a bulk copy and a
consuming loop's step nothing (`mutarray_is_a_header_and_one_backing_allocation`
in `runtime/ops.rs` counts the allocator calls). Measured against the
commit before it, both native builds on the same machine, otherwise idle:

* *csv_records* (realistic schema, 1000 rows; callgrind, compilation
  included):

  | program | arrays | `malloc` calls | instructions |
  |---|---:|---:|---:|
  | parsing alone | 4 015 | 37 093 against 44 121 | 87.2 M against 89.7 M |
  | default row tables | 12 026 | 87 955 against 103 004 | 177.6 M against 182.9 M |
  | presized row tables | 8 026 | 77 955 against 89 004 | 167.3 M against 171.6 M |

  The difference is exactly one call per array and one per
  `mutable_array::copy` between two arrays (3 013, 3 023 and 3 023 of
  them: the copy no longer gathers the source's words into a scratch
  `Vec` -- once the destination is writable its backing is its own, so
  the source's is read in place). The default row tables now make fewer
  `malloc` calls than before this milestone (87 955 against 89 492; this
  machine measured 103 004 where the list above says 103 017). Times,
  best of 28 in-process runs, ten rounds alternating the two builds
  (range of the rounds, median in parentheses): parsing alone 3.47-3.73 ms
  (3.60) against 3.74-3.97 (3.77), -5 %; default row tables 6.05-6.61
  (6.16) against 6.44-7.54 (7.08), -13 %; presized 4.75-5.18 (4.89)
  against 5.72-6.24 (5.82), -16 %. Before this milestone the list above
  has 3.51-3.66, 5.73-5.78 and 5.23-5.26 (measured in an earlier session,
  so only roughly comparable): parsing and the presized tables are back,
  the default tables still about 6 % slower.
* *Copy-on-write* (`bench/mutable-array.tcl`): every counter of the table
  above is unchanged (200 shares per program; 200 detaches copying 2 000,
  200 000 and 2 000 000 elements; none for 200 000 writes to a unique array;
  `sched-8`: no share or detach). A detach is one allocation where it was
  two: the copy-then-write program (K = 200, best of 50 runs, eight rounds)
  takes 21.5-22.3 us against 27.4-27.8 at S = 10 (-22 %), 390-407 us against
  400-414 at S = 1000 (each build also had a few rounds near 650 us), and
  4.84-4.93 ms against 4.88-5.07 at S = 10 000. A first version copied the
  detached elements with one `memcpy` (`Rc::from`) and was 12 % slower at
  S = 10 000 (5.39-5.54 ms): on this x86-64 (ERMS without FSRM) glibc copies
  an 80 KB block with `rep movsb`, slower than the element loop the old
  `VecDeque` clone compiled to (with
  `GLIBC_TUNABLES=glibc.cpu.x86_rep_movsb_threshold` set above it, 4.65-4.77
  ms). A backing is therefore built by collecting an exact-length iterator
  (`ops::backing_of`), which is still one allocation and compiles to that
  loop.
* *Mutation*: `drop-leaks-elements-native`, which only the Tcl-level tests
  and the fuzzer killed before (55), is now also killed by a Rust test
  (`a_mutarray_drop_releases_the_elements_left_once`, `runtime/affine.rs`).
  The three native mutants that edit the changed code
  (`copy-aliases-native`, `copy-eager-deep-native`,
  `drop-leaks-elements-native`) were re-pointed at it; all 31 are killed.

### 63. Backwards-compatibility findings

See [Compatibility](#compatibility).

### 64. Remaining source-visible reference-semantic values

None among ordinary values: Strings, Lists, structs and ImmutableSets are
immutable; MutableBytes, MutableVector and MutableArray are copy-on-write
values; a coroutine handle is affine (moved, never shared); closures capture
values. The one deliberate shared state is a context: an installed
context's members are places every function sharing it mutates (a read-out
of one is a copy).

### 65. Constructor naming

`create(n, x)` -- one value repeated (the existing name, kept); `generate(n,
f)` -- a factory called once per element (new; "generate" says the elements
are produced, not copied, and no other collection had a factory name to
match); `from_list(xs)` -- the List's elements moved in (shared by
MutableVector and ImmutableSet); `allocate(n)` -- the raw unit-filled array
of the substrate. No synonyms (`repeat`, `filled`, `init`, `from_factory`)
were added.

### 66. Remaining collection inconsistencies

* MutableVector has no `create`/`generate` (only `from_list` and push);
  adding them is a natural follow-up with the same roles.
* MutableBytes mutates functionally (`replace` returns the store) where the
  others mutate a place.
* A List of affine values moves whole only (no move-out operations).
* ImmutableSet admits no affine members (by element-operation
  requirements).
* An array has no clear/take/pop: by shape (no empty slot), not history.
* Natively, a struct of arrays projected through untyped parameters
  compiles only specialized (native code needs a projection's slot
  statically: `-specialize 0` is unsupported) -- the HashTable, as before
  this milestone (hashtable and csv_records were unsupported generically
  then too). `csv_chunked.bot`'s ChunkedBuilder functions declare their
  parameter's type, so its generic build works as it did (30 blockers and
  20 guards, against 38 and 26 before); left untyped, its 26 corpus and
  growth tests ran natively only specialized (`native-coverage.tcl`'s
  passed-partial class).

### 67. Limitations before enums/test framework

* No Option: a factory or swap failure is a declared error, handled where
  a fallback value is needed (`spare()` in the fuzzer); a "hole" cannot be
  expressed and is not.
* No partial moves of named arrays and no element borrowing: reading an
  affine element in place is impossible; swap it out and back.
* Factories are named functions (no `fn (i): ...` sugar yet); a factory
  closure capturing locals works but is not exercised as stateful.
* Payload-free errors: a failing factory cannot say which slot failed.
* The scheduler-shaped construction works (`ma-principal-generate`,
  `bench/mutable-array.tcl`'s `sched-8`), but a test runner over arrays of
  workers would want enums for results and a framework for reporting.

## Ownership roles: the audit

Every collection primitive, by parameter (items 21, 34, 53, 54). "Affine?"
says whether an affine argument is allowed there; "moves" whether it moves
in; "duplicates" whether the operation would duplicate it; "result owns"
whether the result owns a transferred value.

| primitive | parameter | role | affine? | moves | duplicates | result owns |
|---|---|---|---|---|---|---|
| `mutable_array::create` | n | observe | -- | no | no | |
| | x | repeat | **rejected** (`AFFINE-DUPLICATION-UNSUPPORTED`) | -- | yes (N logical copies) | the array owns the copies |
| `mutable_array::generate` | n | observe | -- | no | no | |
| | factory | factory | an affine callable rejected | no (only called) | no | each slot owns one result |
| `mutable_array::from_list` | xs | move | yes | yes | no | the array owns the List's elements |
| `mutable_array::allocate` | n | observe | -- | no | no | |
| `mutable_array::at` | a | copy-out | **rejected** (`AFFINE-ELEMENT-COPY-OUT`) | no | would | -- |
| | i | observe | | | | |
| `mutable_array::set` | a | place | yes (receiver) | no | no | |
| | x | move | yes | yes | no | the slot (displaced element released: `#set_drop`) |
| `mutable_array::swap` | a | place | yes | no | no | |
| | x | move | yes | yes | no | yes: the displaced element |
| `mutable_array::copy` | dst | place | | | | |
| | src | copy-out | **rejected** | no | would | |
| `mutable_array::freeze` | a | copy-out | **rejected** | no | would | |
| `mutable_array::capacity` | a | observe | yes | no | no | |
| `mutable_array#to_list` (snapshot) | a | copy-out | rejected (an affine loop consumes instead) | | | |
| `mutable_array#consume`, `#take_front` | a | move, place | yes | yes / -- | no | yes: the taken element |
| `mutable_array#swap_drop`, `#set_drop`, `#generate_drop` | | as swap/set/generate, plus the descriptor | | | | |
| `mutable_vector::from_list` | xs | move | yes | yes | no | yes |
| `mutable_vector::push` | v, x | place, move | yes | x moves | no | |
| `mutable_vector::pop`, `take` | v | place | yes | | no | yes |
| `mutable_vector::swap` | v, i, x | place, observe, move | yes | x moves | no | yes |
| `mutable_vector::at` | v | copy-out | **rejected** | | would | |
| `mutable_vector::length`, `empty?` | v | observe | yes | | | |
| `mutable_vector::clear` | v | place | yes (elements released: `#clear_drop`) | | | |
| `list` (literal) | elements | element | yes, into an affine List | yes | no | yes |
| `list::at`, `list::append` | | copy-out | **rejected** for an affine List | | would | |
| `list::length` | xs | observe | yes | | | |
| `immutable_set::from_list`, `contains` | | equality | **rejected** (`ImmutableSet[affine]` is not a type) | | | |
| byte stores (`byte_store::*`, `mutable_byte_store::*`) | | erase (default) | -- (Bytes only) | | | |

Issues the audit found: `create` (fixed: `repeat`), `from_list` and
`generate` (new roles), every array operation's ownership (it had none: the
array could not hold affine values), and three name-keyed tables in
`hir/mutvec.tcl` and `hir/cardinality.tcl` (moved into the registrations).
No vector, List, set or byte-store primitive needed a change.

## Compatibility

Every behavior change, classified (item 61). Each existing test or corpus
program that relied on the old behavior was updated, never kept on
reference semantics:

* **Independent logical copies (was: aliasing).** Corpus:
  `examples/stdlib/hashtable.bot` (the table is a `HashTable` struct of four
  arrays every update returns: `t2 = ht_set(t1, k, v)`; `t1` is unchanged),
  `csv_records.bot` (its copy of the table; `build_rows` threads its outer
  array), `csv_chunked.bot` (a `ChunkedBuilder` struct, its functions declaring the
  builder parameter's type; `chunked_copy_chunks`
  returns the array it fills -- with aliasing it filled the caller's through
  its parameter, and its 100-row case lost every completed chunk under value
  semantics until rewritten). Tests that observed evaluation order or effects
  through an array passed as an argument now log through a context member
  (`elif`, `flags`, `method-sugar`, `coroutines`, `refinement-values`,
  `struct-destructuring`, `structs`, `struct-scalar-replacement`,
  `native-tiny-leaf-inline`, `stdlib-namespaces` and the elif, flags,
  method-sugar, coroutine, stdlib-namespaces and struct-destructuring
  fuzzers). Tests that pinned aliasing now pin independence (see 52).
  `native-hashtable.test` and the escape/param-aggregate/value-transport
  drivers thread the table.
* **Moves (T affine).** New: no existing program held affine elements in an
  array (it was rejected).
* **Repeated constructor rejects affine T.** New rejection; nothing relied
  on it.
* **Factory constructor.** New; no previous pattern to replace.
* **Nested collections accepted.** `MutableArray[affine]` (was
  `AFFINE-CONTAINER-UNSUPPORTED`); `MutableVector[MutableArray[T]]` was
  already a type.
* **Typing.** Covariance and accepted erasures (PARAMETERIZED-MUTABLEARRAY.md's
  invariance and `mat-atk-*` rejections, `si-brg-*`'s typed-array probe,
  `opaque-construct-bearing-*`, `struct-bearing-*` now use a typed function
  as the contract-bearing probe). A declared raw parameter that writes is a
  place of the declared type (`MentionsMutable`: arrays now, like vectors).
* **Run-time argument checks.** `create`/`from_list` are intrinsics: a
  statically wrong argument kind (`from_list(123)`) is the run-time TYPE
  error every intrinsic gives (`list::length(5)` does the same), no longer a
  compile-time one.
* **Rendering.** An array prints its elements (`<mutable-array [unit,
  unit]>`, was `<mutable-array capacity=2>`), and the native backend can
  return one to the host.
* **Receivers.** Mutating a temporary or a captured array is
  `MUTABLE-PLACE-RECEIVER` (was allowed: it mutated the shared object).
* **Diagnostic codes.** `MUTABLE-VECTOR-RECEIVER`, `MUTABLE-VECTOR-CAPTURE`,
  `AFFINE-VECTOR-COPY-OUT` are `MUTABLE-PLACE-RECEIVER`,
  `MUTABLE-PLACE-CAPTURE`, `AFFINE-ELEMENT-COPY-OUT` for both collections.
* **Measured counts.** Corpus blocker/guard/instance counts and struct
  censuses of hashtable, csv_records, csv_chunked and csv_geometric changed
  with their rewrites and the intrinsics (each test's comment attributes
  them); `lib/mutable_array.bot` no longer imports `list`, so a program
  importing only `mutable_array` no longer loads `lib/list.bot`.
  `mat-fence-1` (the typed-API fence of TYPED-MUTARRAY-BUILDER-REFACTOR.md)
  admits `hashtable.bot` and `csv_chunked.bot`: their builders became
  structs of typed arrays.
  `paramagg-chunked-2` pinned the List-shaped builder's three-result unpack;
  it pins the struct builder's in-place append now (no copy, the builder
  parameter returned as is).

## Files

| file | role |
|---|---|
| `core/mutarray.tcl` | Tcl runtime: headers over shared Tcl lists, operations, registrations with roles |
| `core/native.tcl` | `-ownership`, `-errors-from`, `-result-length`, `-drop-form`; the role vocabulary |
| `core/mutvec.tcl`, `core/affine.tcl` | shares (`h` for arrays, `d` dynamic), the `a` drop, the kind-generic drain |
| `lib/mutable_array.bot` | `get` only |
| `hir/types.tcl` | affinity, covariant subtype, lub, narrow, `MentionsMutable` |
| `hir/range.tcl` | exact parameter admission (`AggregateAdmits`) |
| `hir/containers.tcl` | type rules of the container natives, `VerifyFactory` |
| `hir/affine.tcl` | `NativeConsumer` (roles), consuming loops over arrays |
| `hir/mutvec.tcl` | places, copies, copy elision, dropping forms -- kind-generic, metadata-driven |
| `hir/specialize.tcl`, `hir/semantic.tcl` | affine array keys; declared mutable parameters |
| `hir/cardinality.tcl` | constructor lengths from `-result-length` |
| `native/src/runtime/{value,ops,mutvec,affine,heap,metrics,show}.rs` | native runtime |
| `native/lower.tcl`, `native/src/nir.rs`, `native/src/codegen/clif.rs` | native lowering |
| `tests/mutable-array.test` | this milestone's tests |
| `audit/mutable-array/tools/{fuzz,mutate}.tcl`, `mutants.txt` | fuzzer, mutation harness |
| `bench/mutable-array.tcl` | performance report |

## What to run when changing this

AGENTS.md's "MutableArray" section.
