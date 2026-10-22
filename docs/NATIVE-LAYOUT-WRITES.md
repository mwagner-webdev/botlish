# NATIVE-LAYOUT-WRITES.md

> Partially superseded by C-FLOAT-FFI-MILESTONE-1.md: a store or a write
> of a C float field rounds the Float64 to nearest, ties to even, and an
> overflow is `NonFiniteFloat` before a byte is written; a C double field is
> stored exactly (the "Botlish has no float" item of section 22).

> Partially superseded by FIXED-LAYOUT-ARRAYS.md: designators name array
> elements statically (`L.pts[2].x`), `std::binary::store_element` writes one
> element of a live array at a dynamic index, and a whole array is written
> from a List (section 22's "Fixed arrays" item).

> Partially superseded by LAYOUT-UNIONS.md: an edit writes a union one
> alternative at a time (`std::binary::store(e, L.u.alt, v)`, through
> `NativeEdit[U]`), touching exactly that alternative's bytes; a designator
> names an alternative, never a union, and byte storage is written the same
> way (`std::binary::write`, `std::binary::write_foreign` through a pointer
> alternative).

Native layout writes: the write half of the native-layout model. Live native
memory is written through a writable native capability, `NativeEdit[L]`
(`std::binary::native::edit`, `std::binary::store`); byte storage the program owns is
written a field at a time through the same layouts (`std::binary::write`), and an
existing C pointer is encoded into a pointer field of it only by an explicit
foreign write (`std::binary::write_foreign`).

> The layout determines where the bits are. The backing decides what those
> bits are allowed to mean. A `NativeEdit` grants live write authority; it
> does not grant ownership. `MutableBytes` is storage, not a native Botlish
> object. Foreign authority may be encoded from an authority the program
> already has; arbitrary bytes may not conjure authority by decoding.

```botlish
direct module                                  # making an edit is raw authority

import std::abi
import std::abi::bytes
import std::binary
import std::binary::native
import std::ffi::c

opaque struct Node:
    tag: unit

layout POINT:
    size 4
    align 2
    field x: std::binary::I16 at 0
    field y: std::binary::U16 at 2

layout RECORD:
    size 24
    align 8
    field count: std::ffi::c::UInt at 0
    field origin: POINT at 4
    field next: std::ffi::c::Ptr[Node] at 8
    field callback: std::ffi::c::FnPtr[Fn{args: [std::ffi::c::Int], return: std::ffi::c::Int}] at 16

# Live memory foreign code handed out: read and written in place.
fn reset(p: std::ffi::c::Ptr[Node], q: std::ffi::c::Ptr[Node]) -> int errors NativeEditNull:
    e = std::binary::native::edit(RECORD, p)        # NativeEdit[RECORD]: p observed, nothing touched
    std::binary::store(e, RECORD.count, 0)          # one 4-byte store at offset 0
    std::binary::store(e, RECORD.origin.x, -1)      # a path: one store at offset 4
    o = e.origin                               # NativeEdit[POINT]: the subrecord, no read
    std::binary::store(o, POINT.y, 7)               # one store at offset 6
    std::binary::store(e, RECORD.next, q)           # q's address bits; q observed, still q's
    e.count + o.y                              # reads, exactly a view's

# A record built in byte storage the program owns, for a C call.
fn build(q: std::ffi::c::Ptr[Node]) -> std::abi::bytes::MutableBytes errors LayoutLengthMismatch:
    d0 = std::abi::bytes::zeroed(std::abi::usize(std::binary::layout_length(RECORD)))
    d1 = std::binary::write(d0, RECORD.count, 3)    # a new MutableBytes: d0 unchanged
    d2 = std::binary::write(d1, RECORD.origin.y, 9)
    std::binary::write_foreign(d2, RECORD.next, q)  # the explicit foreign encoding
```

The record `build` returns is handed to C by the existing borrowing contract
(C-POINTER-BORROWING.md): `extern c fn use_record(r: std::ffi::c::Ptr[std::ffi::c::UChar]
read noescape) -> ...` exposes its storage for the one call.

## Contents

1. [The model](#1-the-model)
2. [Source surface](#2-source-surface)
3. [Field designators](#3-field-designators)
4. [NativeEdit: the type, its reads, its subrecords](#4-nativeedit-the-type-its-reads-its-subrecords)
5. [Authority: direct modules](#5-authority-direct-modules)
6. [Unrestricted, and what that does and does not prove](#6-unrestricted-and-what-that-does-and-does-not-prove)
7. [Scalar stores](#7-scalar-stores)
8. [Pointer and FnPtr stores; source-pointer ownership](#8-pointer-and-fnptr-stores-source-pointer-ownership)
9. [MutableBytes: ordinary layout writes](#9-mutablebytes-ordinary-layout-writes)
10. [The explicit foreign write](#10-the-explicit-foreign-write)
11. [Padding and adjacent bytes](#11-padding-and-adjacent-bytes)
12. [Diagnostics and failures](#12-diagnostics-and-failures)
13. [Bounds and validity](#13-bounds-and-validity)
14. [Representation and lowering](#14-representation-and-lowering)
15. [The Tcl backends](#15-the-tcl-backends)
16. [HIR, interchange, cache, isolation](#16-hir-interchange-cache-isolation)
17. [Targets](#17-targets)
18. [Performance](#18-performance)
19. [Tests, the oracles, fuzzing, mutants](#19-tests-the-oracles-fuzzing-mutants)
20. [Regression and CI](#20-regression-and-ci)
21. [The read milestone's questions, answered](#21-the-read-milestones-questions-answered)
22. [Pressure on generated native layouts](#22-pressure-on-generated-native-layouts)
23. [Not here](#23-not-here)
24. [What to run when changing this](#24-what-to-run-when-changing-this)
25. [Files](#25-files)

## 1. The model

```
                             layout                 one description: size,
                               |                    alignment, offsets,
                               |                    encodings, pointer fields
        +---------------+------+-------+------------------+
        |               |              |                  |
   byte storage     byte storage   native memory     native memory
     (read)          (write)          (read)            (write)
 std::binary::parse    std::binary::write   std::binary::native::  std::binary::native::edit
 LayoutStruct[L]  write_foreign      view(L, p)      (L, p): NativeEdit[L]
  (a copy)        (a new value)   NativeView[L]      std::binary::store
```

The two write mechanisms are deliberately asymmetric, because their backings
are:

| | `LayoutStruct[L]` | `std::abi::bytes::MutableBytes` | `NativeView[L]` | `NativeEdit[L]` |
|---|---|---|---|---|
| what it is | an immutable value: a copy of the fields | byte storage the program owns: a value | a window onto live native memory | write authority over live native memory |
| made by | `std::binary::parse`, construction | `std::abi::bytes::zeroed`, `from_bytes`, a write | `std::binary::native::view(L, p)` | `std::binary::native::edit(L, p)` |
| holds | the field values | the bytes | the address | the address |
| read | a field | `std::binary::parse` of a frozen copy | `v.f`, `std::binary::load` | `e.f`, `std::binary::load` (a view's reads) |
| written | never (build a new one) | `std::binary::write`, `std::binary::write_foreign`: a **new** value | never | `std::binary::store`: **in place** |
| a pointer field | read from native memory only | written only by `write_foreign`, never parsed | read | read and stored |
| authority | none | none | direct to make, ordinary to read | direct to make, ordinary to use |
| ownership | its own | its own | none | none |
| affinity | its fields' | unrestricted | unrestricted | unrestricted |
| backends | all four | all four | native | native |

A `NativeEdit[L]` is not a `NativeView[L]` with a flag, not a `MutableBytes`,
not a pointer, not a Botlish struct, not an owner of the memory and not proof
of exclusive access to it. `MutableBytes` gains no reference semantics and no
persistent editor wrapper: a layout write is an operation on a value. No
ordinary Botlish value gains a representation: a `struct` still has no
address, no stable offset and no pinning; a caller-constructed native record
is bytes the program owns, filled through a layout and exposed for a call.

## 2. Source surface

| form | what |
|---|---|
| `NativeEdit[L]` | the type of a native edit of layout L: a built-in applied type like `NativeView[L]`; its argument names a layout |
| `std::binary::native::edit(L, p)` | `NativeEdit[L]` of the memory the data pointer `p` addresses: L a layout name (static), `p` statically an `std::ffi::c::Ptr[T]`, observed; `errors NativeEditNull` |
| `e.f`, `{a: x} = e`, `std::binary::load(e)` | reads, exactly a view's; a nested layout's field is a `NativeEdit[Inner]` |
| `std::binary::store(e, L.f, v)` | `v` written into field f of the memory `e` addresses; `e` statically `NativeEdit[L]`; returns unit; declares nothing |
| `std::binary::write(d, L.f, v)` | the `std::abi::bytes::MutableBytes` d with ordinary field f written: a new value; `errors LayoutLengthMismatch` unless `d` has exactly L's size |
| `std::binary::write_foreign(d, L.p, q)` | the same for a C pointer field p and an existing pointer `q` of exactly its type, observed |
| `NativeEditNull` | the builtin declared error of an edit of the null pointer (beside `NativeViewNull`, `LayoutLengthMismatch`) |
| `LAYOUT-FOREIGN-WRITE` | the diagnostic of a foreign write of a field that is no pointer field (`std::compiler::DiagnosticCode::LayoutForeignWrite`) |

`std::binary::native` keeps being the one namespace of native-memory authority and
now has two members, `view` and `edit`; `std::binary::store`, `std::binary::write` and
`std::binary::write_foreign` are `binary`'s. All four are `nomethod` (each takes
a static operand -- the edit its layout, the others a field designator --
that is never a receiver value); none is context-free (a write is an
effect: never folded, merged or dropped). No
statement, keyword, operator or assignment form was added: Botlish has no
general assignment, and a write is an operation with operands, as everything
else in `binary` is.

Naming. `store` beside `load` (native memory), `write` beside `parse`/`emit`
(bytes): the pairs say which backing a name touches. `write` returns a new
value -- MutableBytes' `replace` convention in effect -- and `store` returns
unit, mutating memory in place: the two directions differ exactly where their
backings do. `write_foreign` says in the source that a pointer is being
encoded; it is never what ordinary serialization does.

## 3. Field designators

A write names its field statically: `LAYOUT.FIELD`, or a path through nested
layouts, `LAYOUT.FIELD.FIELD...` (`RECORD.origin.x`), qualified for another
module's layout (`geo::Box.width`). The designator is a static operand, like
a layout operand: the root is a layout name, never a value, and the
projections never run. Resolution (`hir/resolve.tcl`'s `FieldPathOperand`)
turns it into one constant,

```
{STRUCTID SIZE PATH FIELD}       e.g. {{LayoutStruct[RECORD]} 24 origin.x {x 4 i 2 little}}
```

the root layout's struct identity and size, the path as written and the
leaf's descriptor entry with its offset made **absolute** (`{NAME OFFSET u|i
WIDTH ENDIAN}`, or `{NAME OFFSET ptr WIDTH ENDIAN}` for a pointer). That is
everything a backend needs: one store of WIDTH bytes at OFFSET from the
record's start. The field's semantic type, which the value is held to, is
read from the registry along the path (`hir::layouts::PathField`).

A designator names a leaf: a scalar or a pointer field. A nested layout is
written through its fields (`RECORD.origin` alone is `LAYOUT-OPERAND`), and a
whole pointer-free record is still emitted by `std::binary::emit`. No runtime string
names a field; a String-literal spelling was rejected because it would look
like one (and one-letter field names would warn, ONE-CHAR-STRING-LITERAL).

A store's designator must be rooted at its edit's own layout
(`LAYOUT-OPERAND` otherwise): `std::binary::store(e, RECORD.origin.x, v)` and
`std::binary::store(e.origin, POINT.x, v)` write the same bytes.

## 4. NativeEdit: the type, its reads, its subrecords

**The type** is `{nedit L}` (hir/types.tcl): nominal, unrestricted, runtime
kind `cptr` (the word is its pointer's address word), printed
`NativeEdit[L]` and read back by `hir::read::ParseType`. `NativeEdit[int]`,
`[S]`, `[List[int]]` are `LAYOUT-STRUCT-PARAMETER`, `NativeEdit[Nope]`
`UNKNOWN-LAYOUT`, a bare `NativeEdit` the arity error -- `NativeView`'s
diagnostics.

**Distinctness.** `NativeEdit[L]` and `NativeView[L]` are not subtypes of each
other in either direction (`ne-type-distinct`): read authority never becomes
write authority implicitly, and an edit is not silently narrowed into a view
either. Their join is `any`, which can do neither (a store needs a static
`NativeEdit`). No explicit reduction from edit to view was added: nothing
needed one, and the architecture offers no trivial one that is not a
subtyping rule. An edit is never a pointer: `null?`, `clone`, `erase`, a C
pointer parameter, a view's or an edit's construction refuse it (`TYPE`,
`IMPRINT`, `BINARY-OPERAND`), so no route leads from an edit back to a pointer
or from a view to an edit.

**Reads.** Every read a view supports reads the same through an edit of the
same memory (`ne-read-parity`): scalar fields, a u64 BigInt, nested fields at
any depth, destructuring, `std::binary::load` of the record and of a subrecord,
pointer fields (a fresh affine pointer, exactly as through a view). A read
never returns a writable reference to a field: field values are ordinary
values.

**Subrecords.** A nested layout read through `NativeEdit[Outer]` is
`NativeEdit[Inner]` (through `NativeView[Outer]` it stays `NativeView[Inner]`):
the outer address plus the field's offset, nothing read or copied. Chains
fold: `std::binary::store(e.outer.inner, Inner.y, v)` is one store at the absolute
offset (no intermediate address computation, native lowering's `ViewBase`),
exactly as a chained read is one load. There is no parent/subview borrow
rule: both are raw windows onto one piece of foreign memory.

## 5. Authority: direct modules

Writing live process memory is raw authority, at least as much as reading it.
`std::binary::native::edit` is a member of `std::binary::native`, which is designated
direct (`core::native::declareDirectNamespace std::binary::native`), so making an
edit is a direct edge of the calling module: `DIRECT` unless the module is
`direct module` or mediates the call through a context it declares itself
(`ne-direct`). Using an edit someone else made -- storing through it,
reading it -- is ordinary: the edit is the authority, already granted, like
a view handed out (`ne-direct-modules`: a direct module makes edits and hands
them out, an ordinary module writes through them and stays ordinary, the
program calling the direct module mediates that call). A module that only
stores through received edits and is marked `direct module` is
`STALE-DIRECT-MODULE`. Byte writes, foreign ones included, are ordinary:
encoding a pointer the program has into bytes reads and writes no foreign
memory; exposing the bytes to C is governed by the call's contract. A layout
declaration stays ordinary. No `unsafe`, no per-store marker, no new
designation mechanism.

## 6. Unrestricted, and what that does and does not prove

`NativeEdit[L]`, like `NativeView[L]`, is **unrestricted**: it can be copied,
passed, stored in a List or a struct, captured. That is the honest stance for
non-owning authority over an address: foreign code may hold aliases to the
same memory, another thread may know the address, another API may write it.
An affine edit would prove only that the program holds one *Botlish* handle,
not that the memory has no other writer, and it would have been presented as
more. So nothing about an edit claims exclusive access, and two edits of one
pointer, a copy of an edit and a view of the same address all alias it: a
store through one is what the others read next (`ne-edits-alias`). There is
no borrow checker, pinning, lifetime region, uniqueness proof or ownership
graph. The pointer an edit is made from is only observed and stays its
owner's; an edit keeps nothing alive.

## 7. Scalar stores

`std::binary::store(e, L.f, v)` for every scalar encoding a view reads (the eight
fixed-width encodings, the target's C scalars `std::ffi::c::UInt`, `Long`, `ULong`,
...): the value is written at the base address plus the constant absolute
offset, in exactly the field's width and encoding, little-endian, aligned or
not (packed layouts: `ne-packed-stores`), as one unaligned store. Never a
truncation, a wrap, a widened store, a write of the enclosing record, its
padding or a neighbouring field (`ne-scalar-stores`, `ne-store-touches-only-
its-bytes`).

The value is held to the field's type by the proof a construction's field
values are held to (`hir::range::ProvesValueAcceptedBy`, from
`hir::layouts::VerifyWriteValue`): a literal or a value of the domain, or an
Int a comparison bounded; -1 and 65536 for a U16 field are `TYPE`, and so is
an unbounded Int (`ne-store-value-types`). C scalar fields keep Botlish's
exact-domain semantics for the compilation's target: `4294967296` is no
`std::ffi::c::UInt`, `18446744073709551615` is an `std::ffi::c::ULong` on LP64. No C
conversion rule exists. The runtime encoder still range-checks (a value no
checked program can produce: a `-strict 0` program's), and fails *before
anything is written* (`nedit_store_refuses_out_of_range_values_before_writing`,
`ne-unchecked-replay`'s RANGE).

## 8. Pointer and FnPtr stores; source-pointer ownership

A pointer field (`std::ffi::c::Ptr[T]`, `std::ffi::c::FnPtr[F]`) is stored from an
existing pointer of exactly its declared type: the same pointee identity or
signature (no `Ptr[Other]`, no implicit erasure to `Ptr[Void]`, no function
pointer for a data pointer, no Int: `TYPE`, with the reason). The store writes
the pointer's address bits in the target's pointer width; null writes the
target's null representation, all zero bytes (`ne-pointer-stores`). Read back
through the edit, or a view, it is the same pointer.

The stored pointer is **observed** (`-ownership {observe observe observe}`),
as a C call's pointer argument is: the store copies its address
representation, like C pointer assignment, and moves nothing. The binding
stays usable -- tested, compared, stored again, moved on to a function that
owns it -- and is never implicitly cloned; a pointer read back is a fresh
affine value of its own (two reads, two owners); an observed temporary needs
an owner first (`AFFINE-TEMPORARY-UNSUPPORTED`, the ordinary rule), and a
moved pointer cannot be stored (`USE-AFTER-MOVE`; `ne-pointer-store-observes`).

What a store does **not** mean: that the memory owns the pointee, keeps it
alive, knows when foreign code stops using it, or makes the pointer
"retained" in the C-FFI sense. Botlish cannot infer any of that from a
representation, so the store records none of it -- no hidden dependency, no
lifetime edge. If a foreign API keeps a pointer it found in a record, a
wrapper that knows that protocol owns the pointee (and, for a callback, its
userdata and registration) together. The low-level facility preserves the
facts Botlish knows; protocol facts are the wrapper's.

## 9. MutableBytes: ordinary layout writes

`std::binary::write(d, L.f, v)` encodes `v` into field f's bytes of the
`std::abi::bytes::MutableBytes` d according to L and returns the result as a new
value; every byte the field does not own is d's (`ne-write-value-semantics`:
d, a copy held in a List and a struct field, and a second write from d all
keep their own bytes). This is MUTABLE-BYTES.md's rule unchanged -- published
storage is never written -- so each write allocates one fresh storage and
copies the record into it (32 bytes: about 100 ns; section 18). Incremental
building is a chain of writes, each binding a new value
(`ne-write-builds-a-record`); inside a function the `MutableBytes` wrapper of
an intermediate value is never built (hir/escape.tcl recognizes a write's
result as a construction of the one-field struct; the storage register is
the value). Copy-on-write or a deadness analysis could make a dead operand's
storage the result; neither exists, and the semantics do not need one.

The storage must be exactly L's size: fewer or more bytes is the declared
`LayoutLengthMismatch`, before anything is written (`ne-write-length`) -- the
exact-length rule of `std::binary::parse`, no prefix write, no cursor. Botlish
knows a `MutableBytes`' length, so this is checked at run time; the front end
does not track the length statically, so every call handles or admits the
error (a builder function with one `errors LayoutLengthMismatch` clause covers
all its writes). The value is held to its field's type exactly as a store's.
Byte writes run on every backend.

## 10. The explicit foreign write

`std::binary::write_foreign(d, L.p, q)` is the one operation that puts a pointer's
representation into bytes, and it is legal only when

1. L statically has the field the designator names;
2. that field is a C pointer field (`LAYOUT-FOREIGN-WRITE` otherwise: an
   ordinary field is written by `std::binary::write`);
3. `q` is statically a pointer of exactly the field's type (`TYPE`: an Int
   is never encoded into a pointer field);
4. the field lies inside the layout and `d` has exactly the layout's size
   (`LayoutLengthMismatch`);
5. `d` is an `std::abi::bytes::MutableBytes` (`BINARY-OPERAND` otherwise).

It encodes `q`'s address bits, little-endian, in the target's pointer width;
null as zero bytes (`ne-write-foreign`). `q` is observed: the bytes do not own
it, keep it alive or carry any dependency on it (`ne-write-foreign-observes`).
An ordinary `std::binary::write` of a pointer field stays `LAYOUT-NATIVE-ONLY`
(ordinary byte serialization never encodes a pointer), and so does
`std::binary::emit` of a pointer-bearing `LayoutStruct` (`ne-ordinary-serialization-
unchanged`). No whole-record foreign emission was added: the field write is
the smaller surface.

**Why it permits no forging.** The law is one-way: foreign authority may be
encoded from an authority the program already has; arbitrary bytes may not
conjure authority by decoding. After a foreign write the bytes hold a
pointer's bits, and

```
existing Ptr[T]  -> std::binary::write_foreign into MutableBytes      YES
those bytes      -> C observes the pointer (noescape exposure)    YES   ne-c-oracle-built
those bytes      -> std::binary::parse as Ptr[T]                       NO    LAYOUT-NATIVE-ONLY
native memory holding those bits -> NativeView / NativeEdit read  YES   ne-foreign-encoding-asymmetry
```

`std::binary::parse` of a pointer layout is rejected whatever the bytes came from;
a layout declaring the word as an integer (a bits twin) reads it as an inert
Int, as it always could read native memory's bits, with no pointer operation;
and the only way back to a pointer is native memory, through a view or an
edit -- memory a test or foreign code put there, never a value Botlish
decoded. `Ptr -> Int` and `Ptr -> Bytes` remain absent as conversions: the
encoding is layout-directed into a statically compatible pointer field only.

**Native memory is raw, and that is why an edit is direct.** The no-forging
law is byte storage's: Botlish's own values never decode into a pointer.
Native memory is not Botlish's value, and nothing ties an address to one
layout: a module holding write authority over memory can store an
integer's bits through one layout (a U64 field) and read the same bytes back
through another layout's view as a pointer -- type punning, exactly as C
permits (`ne-native-memory-is-raw`). The read milestone's premise, that a
pointer in native memory is one foreign code put there, now reads "one that
foreign code or a holder of write authority put there". Preventing the pun
would need an ownership or typing model of foreign memory (which layouts may
alias an address), which this milestone deliberately does not invent. What
keeps it honest is the authority boundary: making an edit is a direct edge
(DIRECT unless the module is `direct module` or mediates it with its own
context), so every forged pointer traces back to a module that acknowledged
raw authority -- as a raw syscall that writes memory already could. A wrapper
that hands out edits of a record whose pointer fields matter should hand out
only the scalar subrecords, or keep the edit private.

**The caller-constructed record** -- the Win32 shape
(`x.cbSize = sizeof x; x.handle = h; x.callback = cb; SomeApi(&x)`) -- is
`std::abi::bytes::zeroed(std::abi::usize(std::binary::layout_length(L)))`, `std::binary::write`
for the ordinary fields, `std::binary::write_foreign` for the pointer, handle and
callback fields, and the existing exposure of the storage to the call. The
borrowing semantics are unchanged: the outer storage is exposed only to a
`noescape` parameter of known access, and nothing inspects the pointer fields
inside the record (C-POINTER-BORROWING.md section 15's retained-pointer
problem is the wrapper's). `ne-c-oracle-built` is this milestone's stand-in
for that workload.

## 11. Padding and adjacent bytes

A write modifies exactly the bytes of its field, on both backings: in
native memory every other byte -- padding between fields, tail padding,
neighbouring fields, the bytes of nested layouts -- keeps whatever it held
(sentinel bytes in every test: `ne-store-touches-only-its-bytes`,
`ne-nested-stores`, the C oracle's padding check, every fuzz program's model);
in byte storage every other byte keeps the operand's (`ne-write-value-
semantics`, `ne-write-every-encoding`). Nothing zeroes or normalizes padding
on a write (emission's zero padding is emission's). This matters for
generated layouts, whose padding is a compiler fact, not Botlish storage.

## 12. Diagnostics and failures

| situation | kind |
|---|---|
| `NativeEdit[int]`, `[S]`, `[List[int]]`; `NativeEdit[Nope]`; bare `NativeEdit` | `LAYOUT-STRUCT-PARAMETER`, `UNKNOWN-LAYOUT`, the arity `TYPE` |
| the edit's layout operand not a layout; its pointer an Int, a function pointer, byte storage, a view, an edit | `UNKNOWN-LAYOUT`, `LAYOUT-OPERAND`; `BINARY-OPERAND` |
| a store through a `NativeView` (or anything not statically a `NativeEdit`) | `BINARY-OPERAND` ("a native view, which is read-only") |
| a byte write into anything not statically a `MutableBytes` | `BINARY-OPERAND` |
| a designator that is no `LAYOUT.FIELD` chain, or rooted at a value | `LAYOUT-OPERAND` |
| a designator's unknown root layout | `UNKNOWN-LAYOUT` |
| an absent field; a name after a scalar or pointer field | `UNKNOWN-FIELD` (listing the layout's fields) |
| a designator ending at a nested layout | `LAYOUT-OPERAND` |
| a store's field of another layout than its edit's | `LAYOUT-OPERAND` |
| a value not proven in its field's type (an out-of-range Int, another pointee, an Int for a pointer) | `TYPE` (at the value, naming the field and the facts) |
| an ordinary `std::binary::write` of a pointer field | `LAYOUT-NATIVE-ONLY` |
| a `std::binary::write_foreign` of an ordinary field | `LAYOUT-FOREIGN-WRITE` (new) |
| a byte write into storage of another size | the declared `LayoutLengthMismatch` |
| an edit of the null pointer | the declared `NativeEditNull` (not `NativeViewNull`: the access named is write) |
| an edit of a non-null pointer on interp / compile | the run-time `NATIVE-ONLY` |
| a write operation used as a value | `BINARY-OPERAND` |
| a store through an edit whose type is not static (an untyped parameter) | `BINARY-OPERAND`; a read of one in an instance, `TYPE` at the call |
| a `-strict 0` program's rejected write | its diagnostic replayed when the call runs, before anything is written (`BINARY-OPERAND`, `LAYOUT-NATIVE-ONLY`, `LAYOUT-FOREIGN-WRITE`, `LAYOUT-OPERAND` joined the native runtime's kinds); an unproven scalar the encoder's `RANGE` |

`LAYOUT-FOREIGN-WRITE` is classified in `tests/static-compile.test`'s census
(a `static compile:` block can produce it: its case is
`std::compiler::DiagnosticCode::LayoutForeignWrite`) and documented in
Compilerpedia (`error.layout-foreign-write`). An edit of the null pointer has
its own error rather than `NativeViewNull` because the diagnostic names the
operation that failed, and a view's name would say read access.

## 13. Bounds and validity

What Botlish knows, it enforces statically: the field lies inside the
declared layout, at a valid offset and width (the layout's validation); a
nested subrecord lies inside its outer layout; the edit's constructor
rejected null, so no store checks again. A `MutableBytes`' length is checked
against the layout's size at run time (exactly equal).

What only the foreign interface knows -- that the address is a live,
writable allocation of at least the layout's size, that no other thread frees
or revokes it while the edit is used, that the operating system will not
unmap it -- Botlish does not pretend to check: no allocation registry, no
memory validation. A bad address faults natively like the C it stands for.

A store is an ordinary native store: not volatile, not atomic, no memory
ordering, no fence, no device-register semantics. `NativeEdit` is for
ordinary memory whose synchronization protocol is handled externally. Every
store and every read is a runtime helper call that the code generator treats
as reading and writing all memory, so none is merged, cached, forwarded or
reordered (`ne-no-caching`: two stores of one value are two stores, a read
after a store is a load). A device or shared-memory workload would need
distinct operations; none exists.

## 14. Representation and lowering

**HIR.** `NativeEdit[L]` is `{nedit L}`. `std::binary::native::edit(L, p)` is a
call of its root native whose layout operand resolution turns into L's
descriptor constant; its result shape `{native-edit 0}` types it. Reads
elaborate exactly as a view's (`hir::layouts::Elaborate`: `e.f` becomes
`binary#view_field(e, FIELD)`, `std::binary::load(e)` becomes `binary#load(e,
DESCRIPTOR)`); `binary#view_field`'s result shape `{view-field 0 1}` gives a
nested layout read through an edit the type `NativeEdit[Inner]` when
specialization re-infers a function (`ne-specialization`). The writes need no
elaboration: their designator is already the constant a backend reads. The
`-layout` roles gained `edited K`, `output K`, `path K`, `value K` and the ops
`edit`, `store`, `write`, `write_foreign` (core/native.tcl; read by every
layer, never a name).

**Native.** An edit is its pointer's C address word, like a view: an
immediate, never a GC root, never allocated. NIR gained four ops (and the
fixture's fifth; native/src/nir.rs, runtime/nview.rs), and lowering emits one
per write (native/lower.tcl's `LayoutWrite`):

```
std::binary::native::edit(L, p)       %n = op cptrisnull %p ; br %n L1 L0 ; L1: faildeclared NativeEditNull ; L0: (the edit is %p)
std::binary::store(e, L.f, v)         op nativestore %e %OFFSET %ENCODING %v       (binstore's encoding word)
std::binary::store(e, L.p, q)         op nativestoreptr %e %OFFSET %WIDTH %q
std::binary::store(e.a.b, B.f, v)     one nativestore at the absolute offset       (ViewBase folds the subrecords)
std::binary::write(d, L.f, v)         op mbyteslen / ieq / br / faildeclared LayoutLengthMismatch ;
                                 %s = op mbyteswrite %storage %OFFSET %ENCODING %v   (a fresh storage)
std::binary::write_foreign(d, L.p, q) ... ; %s = op mbyteswriteptr %storage %OFFSET %WIDTH %q
```

Each op is a runtime helper call: `nativestore` encodes the value with the
encoder `binstore` uses (ops.rs's `bin_encode`, factored out of `rt_bin_store`
for both backings: one width/signedness/range rule), then copies exactly
WIDTH bytes to the address with one unaligned `copy_nonoverlapping` (no
Rust reference to a possibly unaligned foreign field is ever formed);
`nativestoreptr` copies the pointer's address bits (a narrower width must
hold the address: `RANGE`, never a truncation). `mbyteswrite` and
`mbyteswriteptr` encode first, then allocate the fresh storage, copy the
operand into it and write the field: the operand is never written. Nothing
reads the record, copies it through bytes, builds a `LayoutStruct` or walks
the layout at run time (`ne-nir`; the mutant `copy-per-store` is killed by
the NIR and allocation tests).

`main.tcl -emit-nir` of three writes (`put` stores through an edit of
`Deep`: `std::binary::store(e, Deep.head, 7)`, `std::binary::store(e.outer.inner,
Inner.y, 513)`, `std::binary::store(e, Deep.outer.inner.x, -2)`; `link` stores a
pointer; `build` makes a record in bytes):

```
func 3 "put" params=1 ... pnames="e" instance="cptr"
    %1 = int 7
    %3 = int 0                            ; Deep.head: offset 0
    %4 = int 1                            ; u8
    %5 = op nativestore %0 %3 %4 %1
    %6 = int 513
    %8 = int 10                           ; e.outer.inner then .y: 4 + 4 + 2, folded (no cptroffset)
    %9 = int 2                            ; u16
    %10 = op nativestore %0 %8 %9 %6
    ...
    %17 = int 8                           ; Deep.outer.inner.x
    %18 = int 18                          ; i16 (width 2 + 16)
    %19 = op nativestore %0 %17 %18 %16
    ret %19
end

func 4 "link" params=2 ... pnames="e q"
    %2 = int 8                            ; Linked.next: offset 8
    %3 = int 8                            ; the target's pointer width
    %4 = op nativestoreptr %0 %2 %3 %1
    ret %4
end

func 5 "build" params=1 ... pnames="q" results=1
    %3 = callmulti 1 %1                   ; std::abi::bytes::zeroed(std::abi::usize(16))
    %4 = call 2 %3
    %5 = structget 0 %4                   ; its storage
    %8 = op mbyteslen %5                  ; exactly the layout's size, or LayoutLengthMismatch
    %10 = op ieq %8 %9
    br %10 L0 L1
  label L1
    faildeclared 1073741829 "LayoutLengthMismatch"
  label L0
    %13 = op mbyteswrite %5 %11 %12 %6    ; a fresh storage; %5 never written
    ...                                   ; (the second write's length check)
    %19 = op mbyteswriteptr %13 %17 %18 %0
    retmulti %19                          ; the MutableBytes returned as its storage: no wrapper built
end
```

**The fixture.** `core::cabi::installTestFixture` also registers
`ffi_fixture::memory_bytes(p, n)`: natively the N bytes at the C address P
as a List of Ints (`op cptrfixturebytes`), copied with no layout and no
view -- the oracle of a native write. Only a test process can name it; the
Tcl backends refuse it (`NATIVE-ONLY`).

## 15. The Tcl backends

They have no native memory, so they keep the honest capability boundary of
the read milestone: `std::binary::native::edit` is `NativeEditNull` for a null
pointer and the run-time refusal `NATIVE-ONLY` ("reads and writes live
native process memory ...") for any other; an edit can therefore never exist
there, and `std::binary::store` refuses too (core/binary.tcl). Byte storage is
theirs: `std::binary::write` and `std::binary::write_foreign` run on interp and
compile exactly as natively (core/binary.tcl's reference implementation,
sharing `ScalarPiece`, the scalar encoder `std::binary::emit` now uses too); a C
pointer value has its address there as well (the fixture's addresses, null),
so the foreign write encodes it -- nothing is fabricated (`ne-tcl-backends`,
`ne-write-foreign` on all four backends). The Tcl compiler compiles every
write as a generic call of the reference implementation. Static checking and
diagnostics are the same on every backend: they are the front end's.

## 16. HIR, interchange, cache, isolation

No new registry: everything a backend reads about a write is in the HIR --
the designator constant carries the absolute offset and the encoding, the
descriptor constant an edit's layout. `NativeEdit[L]` prints and reads back as
HIR text (`ne-hir-text-roundtrip`: format, read, format is identical and the
read HIR runs; HIR text of a program importing a library module did not
round trip then -- `std::binary::store` needs `import std::binary` -- so the writes
are carried by interchange. HIR text has module sections since:
HIR-INTERCHANGE.md). `hir/interchange.tcl` carries the HIR
dict: a program written as `.hirx` and read back after another compilation
declaring a same-named layout with other offsets writes through its own
layout, natively and on the Tcl backends (`ne-interchange`); `main.tcl
-emit-hir-interchange` and a fresh process running the `.hirx` on every
backend write the bytes the source does (`ne-interchange-fresh-process`); two
compilations of a same-named layout with swapped offsets keep their own
writes (`ne-isolation`); the front-end cache stores and reads back a program
of stores and writes (`ne-cache`). The pointer width comes from the target
the program's `std::ffi::c` scalars were declared for, already in the cache key.

## 17. Targets

Nothing is x86-64-specific. A pointer field's width is the compilation's C
target's (core/cabi.tcl's table, through `hir::cabi::CompilationTarget`: 8 on
every target there); a C scalar's domain is the target's
(`ne-store-value-types`: `UInt`, `Long`, `ULong` on the host's linux-x86_64);
a layout's offsets are explicit and never recomputed. The runtime helpers
are architecture-neutral Rust (unaligned `copy_nonoverlapping`), the stores
little-endian like every layout field. CI runs `tests/native-edit.test` on
Linux x86-64, on Linux AArch64 (`tests-arm64.yml`) and on macOS arm64
(Tier B), where its allocation counts, GC stress, executable and C oracle
skip by their capability constraints, as every other file's do there.

## 18. Performance

`bench/native-edit.tcl -runs 5 -n 200000` (4-core container, 2026-10-18,
idle; three runs, the range shown): programs that repeat one operation
200,000 times in a collecting loop, the time per operation over the loop's
baseline (about 50 ns an iteration: the collecting loop itself), natively.
The record is the views benchmark's 32 bytes: a u8, a nested `Outer` (u32, a
nested `Inner`, u8), a u32 and a pointer; `Big` is 4,096 bytes with a field
at each end.

| operation | Cranelift `-specialize 0` | Cranelift |
|---|---:|---:|
| edit: one scalar store (`Rec.word`) | noise-23 ns | 18-46 ns |
| edit: eight scalar stores | 136-143 ns | 143-147 ns |
| edit: a store two layouts deep, by path (`Rec.outer.inner.x`) | 2-19 ns | 14-22 ns |
| edit: the same store through the subrecord `e.outer.inner` | noise-16 ns | 15-24 ns |
| edit: a pointer store (`Rec.next`) | 12-14 ns | 10-15 ns |
| edit: make an edit (`std::binary::native::edit`: a null test) | about 0-3 ns | about 1-5 ns (one outlier, 48) |
| edit: a store, then a read of the field | 32-36 ns | 34-36 ns |
| edit: one scalar store into a 4,096-byte record | noise-22 ns | 16-20 ns |
| bytes: one `std::binary::write` (32 bytes) | 436-451 ns | 98-119 ns |
| bytes: three `std::binary::write`s in a chain | 647-678 ns | 334-367 ns |
| bytes: one `std::binary::write_foreign` (a pointer field) | 420-452 ns | 92-99 ns |
| bytes: one `std::binary::write` into a 4,096-byte record | 1,099-1,166 ns | 677-752 ns |
| reference: `std::abi::bytes::replace` of one byte (32 bytes) | 394-442 ns | 249-253 ns |

("noise": a negative difference in one of the runs; the single-store rows
are within the loop's jitter, and the eight-store row is the measurement.)

Heap allocations per operation (Cranelift's counters, specialized): every
store -- scalar, nested by path or through a subrecord, pointer, into the
4,096-byte record -- and making an edit **0**, the program's allocations
exactly its baseline's; one `std::binary::write` or `std::binary::write_foreign` **1**
(its fresh `MutableBytes` storage, no struct: the wrapper of a write's result
is never built when the result is consumed in place), three chained writes
**3** (three storages, still no wrapper), `std::abi::bytes::replace` 2 (its storage
and its wrapper). With specialization off, a write allocates its storage and
two structs -- the `MutableBytes` wrapper and the benchmark's
`std::abi::bytes::mutable_length` result -- exactly as `replace` does there; a
chain still builds no intermediate wrapper.

* **A store is about 17-18 ns** (eight of them: 136-147 ns): one runtime
  helper call -- the value's encoding check, one unaligned copy of the
  field's width -- the cost a `binload` or view read has. It is a fixed cost
  per store, never per record: the 4,096-byte record's store costs the 32-byte
  record's, there is no copy, no allocation and no layout walk, and a path or
  a subrecord folds to one store at the absolute offset. Making an edit costs
  its null test. A store then a read is two calls (34-36 ns): nothing is
  forwarded or cached.
* **A byte write is about 100 ns for 32 bytes, specialized**: one allocation
  and one copy of the record, then the field. Its cost grows with the record
  (677-752 ns for 4,096 bytes), which is value semantics (section 9), not a
  surprise: a program that builds a large record field by field pays one copy
  per field. A write is cheaper than the existing per-byte
  `std::abi::bytes::replace` (249-253 ns), which also builds its wrapper.
* **Surprising fixed overhead**: none in the operations themselves. The
  unspecialized byte rows are 3-4x the specialized ones because of the two
  wrapper structs above, the same overhead every `MutableBytes` operation has
  there. The deferred optimizations are the ones the read report names --
  an inline store with the offset and encoding as NIR immediates -- and,
  for bytes, reusing a dead operand's storage (copy-on-write or a deadness
  analysis), which neither exists nor is needed for the semantics.

## 19. Tests, the oracles, fuzzing, mutants

**`tests/native-edit.test`** (55 tests, the authoritative suite; about a
minute): the NativeEdit type, its argument diagnostics, distinctness from
views (both directions, joins), not a pointer, the edit's operands and its
declared null error, the field types read through an edit; field
designators and their diagnostics, a store's own layout, a view's
read-only-ness, the value admission of every field kind (twenty cases:
domains, C scalars, pointees, signatures), the byte writes' diagnostics;
native stores into the fixture's memory -- every encoding's extremes and
zero, written out by hand byte for byte and by the test's own model, padding
and neighbours untouched, packed and unaligned fields, nested subrecords and
paths, C scalars, pointer and function pointer stores (exact address bits,
null as zeros), the stored pointer's ownership, aliasing edits, read parity
with views; byte writes on every backend -- a record built a field at a time,
every encoding, value semantics, the exact-length rule, foreign writes, the
encoding asymmetry, ordinary serialization unchanged; the Tcl backends, the
`-strict 0` replays; NIR shape, no caching, allocations; HIR text,
interchange (in process and a fresh process through `main.tcl`), isolation,
the cache, specialization; directness within and across modules, the
registrations, the plain-memory audit; a standalone executable; GC stress;
and the C oracle.

**The synthetic native oracle.** Native memory is the test fixture's
`ffi_fixture::memory[T](bytes)`, initialized to sentinel bytes (0xA5) the
test states; after the writes, `ffi_fixture::memory_bytes(p, n)` copies the
memory back -- with no layout and no view -- and the test compares every byte
with its own expectation: written out by hand (`ne-scalar-stores-literal`,
`ne-store-touches-only-its-bytes`, `ne-packed-stores`, `ne-nested-stores`,
`ne-c-scalar-stores`) or computed by the test's little-endian model
(`neBytes`), never by Botlish. Reading the fields back through the edit and
through a view of the same memory is a secondary check only.

**The C oracle** (`tests/cffi/nedit-fixture.c`): a C struct of every width,
a nested struct, a C `long`, a data pointer, a function pointer and a tail
byte, its every offset, the size (72) and the alignment pinned by static
assertions; padding at 26-27, 36-39 and 65-71.

* *Native edits* (`ne-c-oracle-edit`, `ne-c-oracle-edit-bytes`): C resets
  its record to 0xA5 and hands out its address; Botlish writes it through
  `std::binary::native::edit`; C checks every field with its own typed reads
  (`bne_check_live`, a mask of mismatching fields), the data pointer against
  the object it handed out and the function pointer against its own
  function, every padding byte against the sentinel. Case 0 writes every
  width's minimum (or all-ones), `LONG_MAX`, both pointers; case 1 the other
  extremes and null pointers (C's null function pointer: Botlish has no way
  to make one); case 2 two fields only, and C finds every other byte's
  sentinel intact. All three: mask 0. The record's bytes, copied out by C,
  are the test's model of every scalar.
* *The caller-constructed record* (`ne-c-oracle-built`): Botlish builds the
  same record in byte storage it owns -- `std::abi::bytes::zeroed`, sixteen
  `std::binary::write`s, two `std::binary::write_foreign`s (C's pointer and function
  pointer, or null ones) -- and passes it to `bne_check_built(bytes: Ptr[UChar]
  read noescape, n, which)`, the existing borrowing contract; C copies the
  bytes into its struct and finds every field, both pointers identical to its
  own, NULL as NULL, the padding zero and the size exactly `sizeof`: mask 0
  for both cases, nonzero for the wrong one; the source pointers are still
  C's own afterwards (`bne_is_target`, `bne_is_callback`).
* *The asymmetry against C* (`ne-c-oracle-asymmetry`): those bytes, copied
  into native memory, read back through a view as exactly C's pointers.

**Rust unit tests** (`cargo test --release --lib nview`, 8 new beside the
view's 5): every encoding stored with neighbours checked, a u64 BigInt and
`i64::MIN`, out-of-range values refused with the memory unchanged, null and
non-address operands refused, pointer stores (bits, null, read back), a
4-byte pointer field refusing a wider address, an Int refused as a pointer,
a byte write's fresh storage (the operand unchanged), the fixture copy.

**Fuzzing** (`audit/native-edit/tools/fuzz.tcl`). Each program is a chain
of random layouts (one to six scalars of every width and signedness at
random gapped offsets, random alignment, sometimes a layout nested by value
two or three levels deep, and in the outermost zero to three pointer fields
-- data and function pointers, aligned or not), a random initial record
(every byte random: padding, fields, pointer words) and one to eight writes
to random leaves, scalar or pointer, some through a nested edit
(`std::binary::store(e.f2, INNER.f0, v)`), the others by a path from the root,
fields sometimes written twice; values biased to each encoding's extremes
and zero, a pointer null, the run-time address of a fixture record, or a
function's address. The fuzzer applies the writes to the initial bytes
itself (little-endian, two's complement, a pointer's address bits: its own
model, never a descriptor or generated code), and each program performs
them twice: through `std::binary::native::edit` into fixture memory, returning
the memory's bytes (`ffi_fixture::memory_bytes`), every written field read
back and every written pointer's address; and into a `MutableBytes` of the
same initial bytes (`std::binary::write`, `std::binary::write_foreign`), returning the
result's bytes and the operand's (unchanged). Both byte lists must equal the
model's exactly. Seeds 17, 41 and 99 at 40 programs each, seed 3 at 20 on
all four backends (interp and compile run the byte half and must refuse the
edit with `NATIVE-ONLY`), seed 5 at 20 under `BOTLISH_NATIVE_GC_STRESS=1`:
**160 programs, no disagreement**. Running it found no defect in the write
code; every fix it needed while it was written was its own (making a null
function pointer, the imprint syntax, the `direct module` marker, quoting).
The read milestone's fuzzer, rerun because views now share their types and
descriptors with edits (seeds 1, 17, 41 at 40, seed 5 at 20 under GC
stress): no disagreement.

**Mutants** (`audit/native-edit/tools/mutate.tcl`). `mutants.txt` holds 40
deliberate bugs, each applied alone to a private copy of the tree (the 8
native ones rebuilding its native backend), with three detectors: the Tcl
suite (`tests/native-edit.test`, the C oracle included), the fuzzer (20
programs, seed 7, on all four backends) and, for native mutants, the Rust
unit tests (`--lib nview`). **All 40 are killed** (2026-10-18):

| defect | mutants | killed by |
|---|---|---|
| field offset ignored / written at offset zero | `offset-ignored-lowering`, `-interp`, `offset-zero-runtime` | tests, fuzzer (18-20/20), Rust |
| width widened / narrowed (padding or a neighbour written) | `width-narrowed-lowering`, `width-widened-runtime`, `width-widened-byte-write`, `padding-overwritten-runtime` | tests, fuzzer (10-17/20), Rust |
| signedness lost | `signed-as-unsigned-lowering`, `-interp` | tests, fuzzer (12/20) |
| a value outside the field's type accepted | `value-unchecked-static` (static), `range-unchecked-runtime` (the encoder truncates) | tests (the static one; the encoder's by the `-strict 0` replay), Rust |
| nested base offset lost | `nested-base-dropped-store` (a subrecord's), `-path` (a designator's) | tests, fuzzer (8-11/20) |
| unrelated bytes lost by a byte write | `unrelated-bytes-lost-interp`, `-byte-write` (the copy starts from zeros) | tests, fuzzer (18-20/20), Rust |
| pointer width or type wrong | `pointer-width-wrong` (always four bytes), `pointer-retyped` (any pointee admitted) | tests (and the fuzzer for the width) |
| null encoded wrong | `null-encoded-nonzero-interp`, `null-stored-nonzero` | tests, fuzzer (3/20), Rust |
| read authority writes / authorities confused | `view-writable`, `edit-is-a-view`, `view-upgrades-to-edit`, `edit-nested-is-a-view` | tests (and the fuzzer for the nested edit) |
| an edit needs no authority | `edit-not-direct` | tests, fuzzer (its programs' marker turns stale) |
| bytes conjure or ordinary serialization encodes a pointer | `foreign-write-takes-an-int`, `ordinary-write-of-pointer`, `foreign-write-of-scalar`, `written-pointer-bytes-parse` | tests |
| a stored or encoded pointer moved | `store-moves-pointer`, `foreign-write-moves-pointer` | tests |
| MutableBytes written in place (value semantics lost) | `byte-write-in-place` | tests, fuzzer (20/20), Rust |
| length not checked / a prefix written | `length-check-missing-native`, `length-prefix-interp` | tests |
| a store copies the record (copy-modify-copy) | `copy-per-store` | tests (NIR, allocations) |
| the null edit unchecked or undeclared | `edit-null-check-inverted`, `edit-null-not-declared-tcl` | tests (and the fuzzer for the native one) |
| specialization, HIR text, designators | `edit-field-shape-lost`, `hir-text-edit-read-as-view`, `designator-through-scalar`, `designator-of-another-layout` | tests (and the fuzzer for the shape) |

Per detector: the Tcl suite kills all 40, the fuzzer 21 (it generates valid
programs only and always writes storage of the layout's size, so the
static-check, ownership, length and allocation mutants are invisible to it),
the Rust tests all 8 native mutants. None survived the first run.

## 20. Regression and CI

Run in a 4-core container on 2026-10-18 (Linux x86-64), after the change:

* **`tclsh9.0 tests/local.tcl -jobs 2`** (every Tcl test file on interp and
  compile, every golden suite on all four backends through the front-end
  cache; two jobs, beside a mutation run): 482 entries, 5,629 s. All 94
  golden suites passed on every backend. Two entries failed, one test on
  both Tcl backends: `abi-bytes-natives-registered`, an inventory pinning
  that no native is named for writing (its regexp
  `write|keepalive|pointer|ptr`), which `std::binary::write` and
  `std::binary::write_foreign` now are -- each returns a new `MutableBytes` and
  writes through no address. The test now expects exactly those two, and
  abi-bytes.test passes whole (73/73). The other inventories this milestone
  grows were updated as it was written and pass whole:
  stdlib-namespaces.test (74/74: `NativeEditNull`, the seventh builtin
  error), linux-syscall.test (37/37: the four natives),
  method-eligible.test (153/153: four more `-nomethod` natives),
  golden-framework.test (42/42) and static-compile.test (83/83: 99
  diagnostic codes, `LayoutForeignWrite`), compilerpedia.test (34/34).
* **The neighbouring suites**, whole: native-view.test 39/39 (three of its
  tests name the edit now: `nv-read-only`, `nv-load-operand`,
  `nv-untyped-receiver`), binary-layout.test 51/51, c-abi-types.test 73/73,
  c-pointer-borrowing.test 61/61, direct-modules.test 55 (1 skipped),
  c-ffi.test 59 (2 skipped), abi-mutable-bytes.test 76/76, affine.test
  48/48, compilation-isolation.test 19/19, hir-interchange.test 11/11,
  hir-cache.test 17/17.
* **`cargo test --release --lib`**: 250 passed, the eight `nedit_` tests
  included; under `BOTLISH_NATIVE_GC_STRESS=1` 250 too (after the fix
  below).
* **Stub linker** (`BOTLISH_NATIVE_LINKER=stub`): `tests/native-edit.test`
  50 passed, 4 skipped -- the C-oracle tests (`neCFixture`): a program that
  calls C links with the system linker, which the stub linker refuses
  (C-FFI.md).
* **GC stress** (`BOTLISH_NATIVE_GC_STRESS=1`): `tests/native-edit.test`
  55/55; `tests/native-view.test` 39/39; the fuzzers, seed 5
  × 20 programs each, 0 disagreements.
* **The neighbouring fuzzers**: native-view seeds 1, 17, 41 (× 40) and 5
  (× 20, GC stress); binary-layout seeds 1, 17, 41 (× 30) and 5 (× 15, GC
  stress); c-abi-types seeds 1, 17, 41 (× 40); direct-modules seeds 1, 17,
  41 (× 60); affine seeds 1, 17, 41 (× 30): 0 disagreements.
* **Isolation, interchange, cache** (their default suites):
  `audit/compilation-isolation/tools/interleave.tcl`, 80 artifacts and
  outcomes, 0 differ; `audit/hir-interchange/tools/roundtrip.tcl -via
  interchange`, 90 compared, 0 differ; `-via cache`, 100, 0 differ.
  native-edit.test's own `ne-isolation`, `ne-interchange`,
  `ne-interchange-fresh-process`, `ne-cache` and `ne-hir-text-roundtrip`
  cover programs that write.
* **The neighbouring mutation harnesses**, every mutant killed: native views
  29/29, binary layout 39/39, C ABI types 26/26, direct modules 18/18,
  compilation isolation 14/14, HIR interchange 27/27, affine values 29/29,
  coroutines 52/52. A static check of every audit's `mutants.txt` applies all
  755 mutants of the 26 harnesses to the tree.
* **Mutants this milestone moved.** Ten mutants of other areas no longer
  applied, because the code they mutate had moved or grown:
  - binary-layout `byte-order-rust-store` and `store-truncates-rust`:
    binstore's encoding is now `bin_encode`, shared with the native store
    and the byte writes (and names its caller in its message);
  - c-abi-types `implicit-ptr-conversion`, enums `cross-enum-parameter`
    and traits `witness-leaks-into-applicability`: the identity-only
    admission and the subtype rule ask `IsNativeMemory` (a view or an edit)
    where they asked `IsNativeView`;
  - native-view `null-check-inverted-native` (the view's null test sits
    beside the edit's), `views-structural` and `view-is-a-pointer` (the
    rule and the not-a-pointer check cover both kinds),
    `view-field-shape-lost` (`OfNativeType`) and
    `pointer-field-read-unowned` (a read through an edit is a load too).

  Each text was updated to keep the same rule, and each mutant is killed
  again, by its harness's tests and its fuzzer (and, for the two Rust ones,
  the Rust tests).
* **CI, first run** (`4e94962`, every workflow dispatched on the branch):
  `static-decisions` green -- every suite's batched decisions agree with
  the sequential reference. Everything else failed on exactly two causes:
  the abi-bytes inventory above (the Linux `tests (interp)` and
  `tests (compile)` jobs, 8,144 tests, 1 failed; both coverage jobs; the
  stub-linked executables; arm64 interp, compile, coverage and the whole
  suite under GC stress; macOS Tier B shard 2) and, on arm64 only,
  `nedit_byte_writes_make_a_fresh_storage` under GC stress: the test held
  its operand storage only in a Rust local, so the stress collection freed
  it and the write's fresh storage took its address. The runtime was
  right (compiled code roots an allocating op's operands); the test now
  roots every heap value it makes in `temp_roots`, as the other runtime
  tests do, and fails without that on x86-64 too. The golden shards (both
  architectures), the Rust unit tests without stress, the warning gate,
  macOS Tier A, Tier B shard 1 and the ubuntu control were green.
* **CI after the fixes** (`6e8ccc2`), every workflow on the branch green:
  - `tests`: interp, compile, cranelift and cranelift-generic coverage, the
    four golden shards beside their Tcl originals, the native Rust unit
    tests, the stub-linked executables and the warning gate.
  - `tests (linux arm64)` on ubuntu-24.04-arm: interp, compile, cranelift
    and cranelift-generic coverage, the four golden shards, the native Rust
    unit tests (also under GC stress), and the whole Tcl suite under GC
    stress (`BOTLISH_NATIVE_GC_STRESS=1`, 79 minutes) -- native-edit.test's
    stores, byte writes and executable included.
  - `tests (macos arm64)`: Tier A and both Tier B shards.
  - `static-decisions` (`4e94962`; the later commits change no front-end
    file): every suite's batched decisions agree with the sequential
    reference.

## 21. The read milestone's questions, answered

NATIVE-LAYOUT-VIEWS.md section 16 listed what writes would have to decide:

1. **Pointer encoding into bytes.** Yes, by the explicit
   `std::binary::write_foreign` only; ordinary `std::binary::emit` and `std::binary::write`
   never encode one; bytes are never re-materialized as a pointer except by
   copying them into native memory and reading that memory through a view or
   an edit (section 10).
2. **Write authority.** One namespace, `std::binary::native`, with a read and a
   write constructor; a view never upgrades, and an edit is made from a
   pointer separately (sections 4, 5).
3. **Affinity of a writable view.** Unrestricted, not affine: affinity would
   prove one Botlish handle, not exclusive access to foreign memory, and
   would be presented as more (section 6). A view does not gain `clone`.
4. **Subviews of writable views.** `NativeEdit[Inner]` at the outer offset;
   raw aliasing between a parent and its subrecords is accepted, no
   borrow-like rule (section 4).
5. **Storing pointers.** Observed, not moved; a store records no
   dependency and is not a "retaining" C call -- it writes Botlish-reachable
   memory a program already had authority over, and what foreign code later
   does with that memory is a protocol fact (section 8).
6. **Native records.** Not here: a caller-constructed record is
   `MutableBytes` plus the borrowing machinery (section 10); a Botlish-owned
   native allocation waits for a workload that retains one (section 22).
7. **`MutableBytes` foreign writes through a layout.** Exactly that,
   field-wise (sections 9, 10).
8. **Bitfields and unions.** Still absent; their writes wait for the
   representation (section 22).
9. **`std::ffi::c::Bool` fields.** Still not a layout field: no generic write
   encoder needed one (section 22).
10. **Volatile / concurrent memory.** Plain stores, in program order, never
    cached; no volatile, atomic or fenced operation (section 13).
11. **The Tcl backends.** Edits refused (`NATIVE-ONLY`); byte writes run;
    native evidence comes from real native memory (section 15).

## 22. Pressure on generated native layouts

What the completed read/write machinery now requires from a future layout
producer (the C binding generator, C-BINDGEN.md, which this milestone did not
touch), as input to the C-bindgen layout milestone:

* **Explicit size, alignment and offsets, every one.** Reads and writes use
  the declared offsets and nothing else; Botlish computes no layout, so the
  producer must emit the C compiler's resolved values (from `offsetof`,
  `sizeof`, `_Alignof` probes, as the fixtures' static assertions do), and
  the size must include tail padding: a byte write requires storage of
  exactly the size, so a record built in bytes is exactly `sizeof(T)`.
* **Padding is the gaps.** A write never touches padding, so a generated
  layout need not (and cannot) declare it; but a caller-constructed record's
  padding is whatever its storage held (zero from `std::abi::bytes::zeroed`):
  APIs that compare whole structs (`memcmp`) or hash them see that.
* **Pointer and function pointer fields** with their exact pointee identity
  (an opaque struct per C struct type, `std::ffi::c::Void` for `void *`) and
  signature: stores and foreign writes admit only the exact type, so a
  generator that erases pointees to `Void` forces every caller through
  `std::ffi::c::erase`/`retype`. Handles typed as pointers (`HWND`, `HANDLE`) need
  the same.
* **Fixed arrays** (`char name[16]`, `POINT pts[4]`, `WCHAR szDevice[32]`):
  not representable. A designator names a leaf; an array would need an
  element designator with a static index (`L.pts[2].x`) or a repetition
  descriptor -- and their writes (store one element, a whole array from a
  List). Until then a generator can only emit arrays of bytes as runs of U8
  fields or skip the struct. (Done in FIXED-LAYOUT-ARRAYS.md: static element
  designators, std::binary::store_element, whole-array writes from a List.)
* **Bitfields** (`unsigned flags : 3`): not representable. A write of one is
  a read-modify-write of its storage unit, which a store is not; the
  generator must at least emit the storage unit as a scalar field (the
  wrapper extracts bits) and the bit allocation the compiler chose, which is
  ABI-specific.
* **Unions and overlapping alternatives** (`union { ... }`, anonymous unions
  in Win32 structs): overlap is rejected; writing one alternative changes
  every other's reading, so the representation needs an explicit overlay
  first. A generator could emit one layout per alternative over the same
  bytes, each written separately.
* **`std::ffi::c::Bool` fields** (SDL3): not a layout field yet. A write would be
  one byte, 0 or 1; a read of any other byte must be the `NATIVE BOOL`
  failure a C result has. Today a generator must use `std::binary::U8`.
* **Compiler-specific packing and alignment** (`#pragma pack`,
  `__declspec(align)`, `__attribute__((packed, aligned))`): already
  representable as explicit offsets and an explicit alignment; nothing
  consumes `align` yet (no native allocation places a layout), so a
  generator should still emit it truthfully for the allocation milestone.
* **`cbSize`-style self-describing fields** need `std::binary::layout_length(L)`,
  a compile-time constant that fits any U32/U16 field.
* **Facts no layout states.** Endianness (big-endian network structs:
  recorded per field in the registry, but no syntax), floating-point fields
  (Botlish has no float), flexible array members and variable-length tails,
  `const` fields (C's `const` is no fact a layout keeps), volatile fields,
  and per-field ownership of a stored pointer (whether an API takes it, keeps
  it or borrows it) -- the last is a wrapper's protocol, never the layout's.

## 23. Not here

No native record allocation (`std::binary::native::allocate`, `NativeRecord[L]`,
malloc-backed layouts, Botlish-owned stable addresses, free or destructor
semantics); no C bindgen change, C header struct probing or `extern c
struct`; no layout guarantee, `repr(C)` or pinning for an ordinary Botlish
value; no ownership or lifetime tracking of foreign memory, no hidden pointer
dependency, no borrow checking; no aggregate C ABI (records by value),
callbacks into Botlish, floating point, arrays, unions, bitfields, dynamic or
trailing extents, `std::ffi::c::Bool` fields, volatile or atomic memory; no pointer
arithmetic, `Ptr <-> Int` or `Ptr -> Bytes` conversion, and no decoding of a
pointer from bytes. No edit-to-view reduction, no whole-record foreign
emission, no method syntax for the writes.

## 24. What to run when changing this

If you change field designators (`hir/layouts.tcl`'s `FieldPath`,
`PathField`, `hir/resolve.tcl`'s `FieldPathOperand`), the NativeEdit type (the
`nedit` cases of hir/types.tcl, hir/read.tcl, hir/resolve.tcl, hir/structs.tcl,
hir/affine.tcl, hir/cabi.tcl, hir/range.tcl), the write checks
(`hir::layouts::Problems`, `VerifyWriteValue`), the write operations'
registrations or roles (core/binary.tcl, core/native.tcl), the reference
implementation (core/binary.tcl's `write`, `writeForeign`, `ScalarPiece`),
escape's recognition of a write's result (hir/escape.tcl), native lowering
(`LayoutWrite`, the `edit` case of `LayoutCall`, `ViewBase`) or the runtime
(runtime/nview.rs's store and write helpers, ops.rs's `bin_encode`, the ops in
nir.rs and codegen/clif.rs), run `tests/native-edit.test` (its C oracle needs
`cc`), `tests/native-view.test`, `tests/binary-layout.test`,
`tests/c-abi-types.test`, `tests/c-pointer-borrowing.test`,
`tests/direct-modules.test`, `audit/native-edit/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`, once with `-backends "interp compile
cranelift-generic cranelift"`), `audit/native-edit/tools/mutate.tcl` (every
mutant in its `mutants.txt` must still apply and be killed: update a mutant's
text when you change the code it mutates, keeping it a mutant of the same
rule) and `cargo test --release --manifest-path native/Cargo.toml --lib
nview`; plus the native-view and binary-layout harnesses (their mutants
share this code: `bin_encode`, `ViewBase`, the subtype rule).
`bench/native-edit.tcl` regenerates the performance report.

## 25. Files

| file | what |
|---|---|
| `hir/layouts.tcl` | `editType`, `OfEditType`, `OfNativeType`, `NativeFieldType`, field designators (`FieldPath`, `PathLayout`, `PathField`), `ResolveNativeEdit`, the roles, the write checks in `Problems`, `VerifyWriteValue`, the edit cases of `Elaborate` and `verifyInstance` |
| `hir/types.tcl` | `{nedit L}`: `IsNativeEdit`, `IsNativeMemory`, resolution, subtyping, joins, projection, the `native-edit` and `view-field` result shapes |
| `hir/resolve.tcl` | `FieldPathOperand`; `NativeEdit[L]` |
| `hir/range.tcl`, `hir/structs.tcl`, `hir/affine.tcl`, `hir/cabi.tcl`, `hir/read.tcl`, `hir/escape.tcl` | admission, projection check, ownership of reads, not-a-pointer, HIR text, a write's result held as its storage |
| `hir/static.tcl`, `stdlib/compiler.bot`, `stdlib/test.bot` | `LAYOUT-FOREIGN-WRITE` |
| `core/binary.tcl`, `core/native.tcl`, `core/cabi.tcl` | the operations and their reference implementation, the roles and shapes, `NativeEditNull`, the byte fixture |
| `native/lower.tcl` | `LayoutWrite`, `LayoutCall`'s `edit` |
| `native/src/runtime/nview.rs`, `ops.rs`, `nir.rs`, `codegen/clif.rs`, `runtime/error.rs` | `nativestore`, `nativestoreptr`, `mbyteswrite`, `mbyteswriteptr`, `cptrfixturebytes`; `bin_encode`; the replay kinds |
| `tests/native-edit.test`, `tests/cffi/nedit-fixture.c` | the suite and the C oracle |
| `audit/native-edit/tools/` | the fuzzer and the mutants |
| `bench/native-edit.tcl` | the performance report |
| `compilerpedia/` | `stdlib.std::binary::native::edit`, `::store`, `::write`, `::write_foreign`, `error.layout-foreign-write` |
