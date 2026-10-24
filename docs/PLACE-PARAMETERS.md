# Place parameters

`place m: T` declares a parameter that is the caller's *place*, not a copy
of its value: a function that takes a collection (or a struct holding
collections) as a place parameter mutates the caller's own collection, in
place, exactly as the collection's own operations do. It is the one
language addition std::mutable_map and std::mutable_set needed
(ORDERED-MUTABLE-MAP-SET.md, "Compiler changes"): a collection written in
Botlish has operations that are ordinary functions, and an ordinary
function could not change its caller's collection.

```
fn push_twice(place v: MutableVector[int], x: int) -> unit:
    v.push(x)
    v.push(x)

v = std::mutable_vector::from_list([1])
push_twice(v, 7)
v.length()               # 3
```

## Why a new form

MutableVector and MutableArray are values (MUTABLE-VECTOR.md,
MUTABLE-ARRAY.md): a header over a copy-on-write backing, mutated in place
through *places* (a local, a parameter, a context parameter, a field path
from one), with the logical copies `hir::mutvec::Elaborate` writes out
wherever a value is read out of a place or enters one. Their mutating
operations (`push`, `swap`, `set`, ...) are natives whose receiver is a
place: `MUTABLE-PLACE-RECEIVER` holds the receiver to be one, and the
operation changes the caller's header.

An ordinary Botlish function has no such parameter. Its parameter is its
own value: on entry it is a logical copy of the argument (or the argument
itself, moved, at its last use), so `fn add(m, k)` that pushes into `m`
pushes into its own copy, and the caller's collection is unchanged. A
collection implemented in Botlish -- an ordered table over several vectors
-- therefore could not offer `m.set(k, v)`: every mutating operation would
have to return the new collection (`m = m.set(k, v)`), which is not
Botlish (bindings are immutable) and which the brief rules out as a public
API.

Two other designs were rejected:

* **Natives for the collection's operations** (a runtime-owned map): the
  milestone's point is that the table is ordinary Botlish.
* **References** (`&mut`, a ref type, a mutable cell): a reference is a
  value that aliases a place, which Botlish's collection model forbids
  everywhere (MUTABLE-VECTOR.md: no reference, no alias between places, no
  runtime ownership state). A place parameter is not a value: it cannot be
  stored, returned, captured or passed anywhere but to another place
  parameter or a mutating operation, and nothing of it exists at run time.

## The rule

A place parameter is a parameter of a function declaration, marked `place`
before its name, with a declared type that holds a mutable collection
(`hir::mutvec::PlaceParamProblem`, reported as TYPE at the parameter):

* a `MutableVector[T]` or `MutableArray[T]`, or
* a struct (named, parameterized or opaque) whose fields hold one at some
  depth -- the types `hir::mutvec::ShareDescriptor` gives a share
  descriptor -- like `std::mutable_map::MutableMap[K, V]`.

The type may not be affine (the caller would keep owning a value the
function could move out of it), may be imprinted (`place m:
MutableMap[K, V]` binds K and V from the argument as any parameter does),
and must be written (`place p` alone is a parse error naming the fix).

A call of such a function passes, for each place parameter, a place of the
caller (`hir::mutvec::PlaceArgumentProblem`, reported as
MUTABLE-PLACE-RECEIVER at the argument):

* a local, a parameter (a place parameter of the caller included) or a
  context parameter of the calling function, or a field path from one
  (`m.table`, `ctx.cache`) -- exactly the places a collection operation's
  receiver may be;
* not a temporary (`f(make())`: the update would be lost), not a module
  binding (shared by every user of the module), not a binding of an
  enclosing function (a nested function cannot update a place it
  captured), and statically of a type that holds a collection.

One call may not give two place parameters overlapping places (the same
binding, one path a prefix of the other: `f(a, a)`, `f(a, a.items)`):
each parameter would see the other's updates, as if one were a reference.

A function with a place parameter is only ever called: used as a value it
would be called through a function value, whose arguments no check sees as
the caller's places (MUTABLE-PLACE-RECEIVER at the reference). A nested
function may not capture a place parameter, nor a place its function gives
to one (MUTABLE-PLACE-CAPTURE). A trait requirement takes values: a
requirement may not declare a place parameter (a parse error), and a
function with one is no implementation of a requirement
(`hir::traits`, TRAIT-NOT-SATISFIED's reason).

## What it means

Inside the function, a place parameter is a place it does not own -- like
a context parameter:

* it is never copied on entry (no `EntryRename`), never moved out, never
  the function's result by move: reading it out (passing it to an ordinary
  parameter, returning it, storing it) is a logical copy, as for any place
  that may be mutated later;
* a mutating operation on it, or on a path of it, mutates the header the
  caller passed; so does a call passing it, or a path of it, on to another
  place parameter.

To the caller, the call is a mutation of the place it passed:

* the argument is handed over by reference, uncopied
  (`hir::mutvec::PlaceArgument`, `ByReference`);
* every *other* argument of the same call that reads an overlapping path
  is a copy (`PlaceOverlap`): `observe(out, m)` where `out` is a place
  parameter and `m.items` is `out` would otherwise observe the update; and
  a later argument that writes the place (a place call in an argument) is
  accounted for as for a collection operation (`WrittenLater`, which treats
  a place argument's whole path as written);
* index proofs over the place's vectors account for the call as a resize
  of every vector under the path (`hir::cardinality::ResizedPlaces`,
  `Mutated`: a vector whose place or an enclosing struct is given to a
  place parameter has no stable length).

Nothing changes at run time. A collection header was always passed by
reference (a header is one Value); the copies hir/mutvec.tcl writes are
what made a parameter the callee's own, and a place parameter is a
parameter they are not written for. No backend knows place parameters:
the Tcl backends, the interpreter and native lowering compile the
elaborated HIR, where a place parameter is an ordinary parameter. HIR
text records them on the block (` places (I ...)`, hir/format.tcl,
hir/read.tcl), so HIR interchange and the front-end cache carry them.

## Grammar

```
param   = ["place"] NAME [":" TYPE] ["=" DEFAULT]
```

`place` is a marker, not a keyword: it is a parameter's marker only when an
identifier follows it (`surface::parser::PlaceMarker`), so `place` remains
an ordinary name everywhere else (`fn f(place: int)` declares a parameter
named `place`). A place parameter may appear anywhere among the ordinary
parameters, any number of times; flags and variadic parameters are
unaffected.

## Tests

`tests/place-parameters.test` (28 tests): the syntax and its HIR text round
trip; that the caller sees the update through method syntax, recursion,
field paths, a parameter passed on as a place, a loop variable's place, a
context member, vectors, arrays and imprinted structs; that copies stay
independent (a callee's copy, its result, an argument overlapping the
place, a place written by a later argument); that the native backend
makes no logical copy for a place call; and every diagnostic above. The
mutants `place-param-entry-copy`, `place-overlap-unchecked`,
`place-module-binding`, `place-observer-uncopied` and
`places-not-printed` (audit/mutable-map/tools/mutants.txt) are killed by
it; std::mutable_map's and std::mutable_set's tests and fuzzer exercise
place calls throughout.

## Limitations

* An affine place parameter is refused (a future extension would need the
  ownership analysis to treat the call as a borrow of the caller's owner).
* A place parameter cannot be a function value's parameter type
  (`Fn{...}` has no place parameters): a function with one is called, never
  passed.
* The front end checks overlap syntactically (by path): two different
  bindings that happen to hold copies of one value never overlap, because
  copies are independent.
