# BINARY-LAYOUT.md

> Partially superseded by C-FLOAT-FFI-MILESTONE-1.md: a field may be
> `ffi::c::Float` (4 bytes) or `ffi::c::Double` (8), C's float and double,
> its copied value a Float64 -- a read of a NaN or an infinity, and a write
> of a Float64 too large for a float, are `NonFiniteFloat` (item 31's
> `float`/`double`).

> Partially superseded by FIXED-LAYOUT-ARRAYS.md: a field may be a fixed
> array (`field name: array N of E at OFFSET`), whose copied value is a List
> of exactly N elements -- items 32 and 66 and "The fixed-layout limitation"
> below describe the language before it.

> Partially superseded by LAYOUT-UNIONS.md: overlap is declared by a
> `union layout` (several interpretations of the same bytes, every
> alternative at the union's start, an explicit size and alignment) held by
> value in a field -- items 33 and 67 describe the language before it. A
> union has no copied value: `LayoutStruct`, `binary::parse`,
> `binary::emit` and `binary::load` of anything holding one are
> LAYOUT-UNION, and bytes are read one alternative at a time
> (`binary::read(data, L.u.alt)`). Overlap stays an error in an ordinary
> layout, and a union is no sum (item 67's plan is not what landed).

Fixed binary layouts: `layout` declarations, `LayoutStruct[L]`, imprinting
and emission.

> `LayoutStruct[T]` is a struct-like result of imprinting, not a general
> generic struct facility. `layout` owns representation; ordinary Botlish
> structs own domain meaning. Reading and writing are two directions of the
> same layout, and C FFI is merely the first demanding consumer of that
> mechanism.

```botlish
import abi::bytes
import binary

layout Header:
    size 8
    align 4
    field magic: binary::U32 at 0
    field count: binary::I16 at 4

h = binary::parse(Header, data)       # LayoutStruct[Header]: imprinting
h.magic                               # a binary::U32
back = binary::emit(h)                # an abi::bytes::Bytes of 8 bytes: emission
binary::layout_length(Header)         # 8, a compile-time constant
```

A layout describes a fixed number of physical bytes. The same layout
imprints bytes into a structural value and emits that value back into bytes;
consuming code sees the value as an ordinary immutable struct whose fields
are the layout's, and never sees offsets, padding or byte order.

## Contents

* [Guide](#guide)
  * [`layout` declarations](#layout-declarations)
  * [`LayoutStruct[L]`](#layoutstructl)
  * [Imprinting: `binary::parse`](#imprinting-binaryparse)
  * [Emission: `binary::emit`](#emission-binaryemit)
  * [Layout queries](#layout-queries)
  * [Padding](#padding)
  * [Nested layouts](#nested-layouts)
  * [The fixed-layout limitation](#the-fixed-layout-limitation)
  * [Modules](#modules)
  * [Not a streaming or transducer system](#not-a-streaming-or-transducer-system)
  * [C FFI is one consumer](#c-ffi-is-one-consumer)
  * [Imprinting is not mapping](#imprinting-is-not-mapping)
* [Implementation](#implementation)
* [Report](#report) -- the 74 points of the milestone report, in order
* [Files](#files)
* [What to run when changing this](#what-to-run-when-changing-this)

## Guide

### `layout` declarations

```botlish
layout SAMPLE:
    size 12
    align 4
    field tag: CUChar at 0
    field value: CInt at 4
    field flag: CUChar at 8
```

A `layout` is a top-level declaration of a module (or of the entry program)
with nominal identity, exactly like a named struct's: `SAMPLE` in the entry
program, `ffi::c::windows::SAMPLE` in module `ffi::c::windows`. Its body has
one `size N` line, one `align N` line and one `field NAME: TYPE at OFFSET`
line per field, in any order, one item per line. `layout`, `size`, `align`,
`field` and `at` are contextual words: `layout` declares only as the first
word of a top-level statement directly followed by a name, and the other four
are words of the layout body only, so every one of them stays an ordinary
name elsewhere (a field may be called `size`).

Everything is explicit, nothing is computed from an ABI: the size is a byte
count from 1, the alignment a power of two, every field states its byte
offset. Padding is derived -- the bytes no field covers -- and is never
declared. A field's type is either

* a **scalar**: an integer domain whose value set is *exactly* one
  fixed-width encoding's -- `0..2^(8k)-1` (unsigned) or
  `-2^(8k-1)..2^(8k-1)-1` (two's complement), k in 1, 2, 4, 8. The encoding
  follows from the interval alone, never from a name: `binary::U16`,
  `abi::U16Value`, `byte::Byte` and a program's own `Int in 0..65535` are
  all the same unsigned 16-bit scalar. Because the domain is exactly the
  encoding's value set, every bit pattern decodes to a value of the field's
  type (parse cannot fail on a field) and every value of the type encodes
  (emit cannot truncate). The byte order is the target's (little-endian);
  or
* a **nested layout**, by value: `field first: POINT at 0`.

`lib/binary.bot` names the eight scalar domains (`binary::U8` .. `U64`,
`binary::I8` .. `I64`) for convenience; nothing requires them.

A malformed declaration is a located error at the offending number, type or
name (the declaration stage, so a whole-program error -- never a `static
compile:` block's, since a layout is top level only):

| kind | when | located at |
|---|---|---|
| `LAYOUT-SIZE` | size 0 or beyond 2^31 - 1 | the size |
| `LAYOUT-ALIGNMENT` | not a power of two, or beyond 2^28 | the alignment |
| `DUPLICATE-FIELD` | two fields of one name | the second name |
| `LAYOUT-FIELD-TYPE` | `int`, a narrower or exact-set domain, a refinement, `str`, `bool`, a struct, `LayoutStruct[L]`, an unknown name | the type |
| `LAYOUT-FIELD-BOUNDS` | a field not inside `0..size` (the message names the bytes it would occupy) | the offset |
| `LAYOUT-FIELD-OVERLAP` | two fields sharing a byte (the later of the first pair located; the message names both byte ranges) | the offset |
| `LAYOUT-CYCLE` | a layout containing itself by value, directly or through others (the message names the chain) | the type |
| `TYPE` | a layout named like a struct, a domain, an enum, a trait or a built-in type (one type namespace) | the name |

There is deliberately no rule that a field's offset be aligned to its width
or that the size be a multiple of the alignment: the declared, resolved
layout is authoritative, so a packed (`#pragma pack(1)`) or vendor layout is
legal exactly as stated (`examples/binary/c-structs.bot`'s `PACKED_HEADER`).
`align` is the layout's own requirement for placement and storage; nothing in
this milestone places a layout in memory yet, and it is recorded and
reported (`binary::layout_alignment`) for the consumers that will.

### `LayoutStruct[L]`

`LayoutStruct[L]` is the type of the values imprinting with layout L
produces: one field per field of L, with its declared type (the integer
domain; `LayoutStruct[Inner]` for a nested layout), and nothing else -- no
offsets, no padding, no byte order, no retained bytes. To consuming code it
is an ordinary immutable named struct:

* projection `v.tag` has the field's precise type; an absent field (padding
  included) is `UNKNOWN-FIELD`, listing L's fields;
* destructuring (`{count: c, inner: {x: ix, y: iy}} = o`), equality by
  fields, hashing (an `ImmutableSet` member), a `List` element, a
  `MutableVector` or `MutableArray` element, a field of an ordinary struct or
  of a context struct, a function argument and result, a closure capture;
* it prints as `LayoutStruct[L] {tag: 7, value: -2, flag: 1}`.

It is built from its fields with the explicit applied construction

```botlish
LayoutStruct[RAWINPUTDEVICE] {usUsagePage: page, usUsage: usage, dwFlags: flags, hwndTarget: bits}
```

checked like any named construction: complete, exact, every field proven in
its domain (`MISSING-FIELD`, `UNKNOWN-FIELD`, `DUPLICATE-FIELD`, `TYPE`). A
value of a wider domain is not assignable merely because some of its values
fit (a `U32` into a `U16` field is `TYPE`), and an `Int` is admitted once a
comparison has proven it in range -- no implicit conversion, truncation or
runtime guard. This construction is the route to emission without parsing,
and it is general: nothing about it is C-specific.

Typing rules:

* the argument must name a layout: `LayoutStruct[int]`, `[SomeStruct]`,
  `[SomeEnum]`, `[SomeRefinement]`, `[List[int]]` are
  `LAYOUT-STRUCT-PARAMETER` (saying what the argument is instead), an
  unknown name `UNKNOWN-LAYOUT`, a bare `LayoutStruct` the arity error every
  type constructor gives -- each at the annotation;
* identity is nominal: two layouts with identical fields, offsets, size and
  alignment are distinct layouts, `LayoutStruct[A]` is never accepted for
  `LayoutStruct[B]` (either direction), and their values are never equal;
* a layout is not a type (`x: Header` is `LAYOUT-NOT-A-TYPE`: its values are
  `LayoutStruct[Header]`'s) and not a value (`x = Header`, `Header(...)`,
  `[Header]`, `Header.parse(d)` are `LAYOUT-NOT-A-VALUE`: no runtime layout
  object exists);
* a layout's own name constructs nothing (`Header {...}` is `UNKNOWN-STRUCT`
  with the hint `LayoutStruct[Header] {...}`), and of the applied types only
  `LayoutStruct[L]` has a construction;
* `LayoutStruct[L]` is a struct type, so like every struct it is not yet a
  refinement carrier (`REFINEMENT-CARRIER`).

There is no generic struct declaration of any kind: `struct Foo[T]:`,
`LayoutStruct Foo:` and `layout struct Foo:` are syntax errors.
`LayoutStruct` is a built-in applied type whose one argument is a layout, not
a type parameter.

### Imprinting: `binary::parse`

```botlish
v = binary::parse(L, data)      # LayoutStruct[L], errors LayoutLengthMismatch
```

L is static evidence written at the call: a layout name (qualified for a
module's layout), never a String, an expression or a value (`UNKNOWN-LAYOUT`
for an unknown name, `LAYOUT-OPERAND` otherwise). DATA is statically an
`abi::bytes::Bytes` (ABI-BYTES.md; `BINARY-OPERAND` otherwise). DATA must
have exactly L's size: fewer or more bytes is the builtin declared error
`LayoutLengthMismatch` -- an ordinary declared error, handled with `on
LayoutLengthMismatch:` or admitted by an `errors` clause, `UNHANDLED-ERROR`
otherwise. There is no prefix parse and no cursor. Nothing else can fail.

Every field is read at its offset in its encoding, a nested layout
recursively at the outer offset plus its own. Padding bytes are read by no
one: two inputs that differ only in their padding imprint equal values. The
value holds the fields only -- never the input, a view of it or a borrowed
buffer -- so `parse`, drop the bytes, use the struct is the natural pattern,
and foreign storage may disappear the moment the call returns.

`binary::parse` takes its layout first and is `nomethod`: `Header.parse(d)`
would make the layout a receiver value.

### Emission: `binary::emit`

```botlish
bytes = binary::emit(v)         # abi::bytes::Bytes of L's size; v.emit() too
```

L is read from the value's static type, which must be `LayoutStruct[L]`
(`BINARY-OPERAND` otherwise: an untyped value, an anonymous struct, an
ordinary struct). Emission writes every scalar field at its offset in its
encoding, recursively for nested layouts, into L's size zero bytes. It is
infallible (declares no error) and never truncates: a field's value is in
its domain by its type. Equal values emit equal bytes.

Neither operation is a function value (`e = binary::emit` is
`BINARY-OPERAND`): its layout is a static operand.

### Layout queries

`binary::layout_length(L)` and `binary::layout_alignment(L)` are
compile-time constants: resolution replaces the call by its value, so it is
usable wherever a proven Int is.

### Padding

Padding is physical, never a field. Imprinting ignores it; emission writes
zeros, so emitted bytes are deterministic and never expose uninitialized
memory. Consequently `emit(parse(L, b)) == b` holds exactly when b's padding
bytes are zero: emission canonicalizes padding.

The round-trip theorem: **`binary::parse(L, binary::emit(v)) == v` for every
value v of `LayoutStruct[L]`** -- each field is written and read at the same
offset with the same encoding, and the value holds nothing else.

### Nested layouts

A field may name another layout; it is held by value (its bytes inside the
outer layout's at the field's offset, its width the inner layout's size) and
its consumer type is `LayoutStruct[Inner]`, an ordinary value that can be
projected, compared, passed on and emitted by itself. A layout never contains
itself by value (`LAYOUT-CYCLE`): a reference to one is a pointer field, a
future scalar.

### The fixed-layout limitation

Every layout has a size known at compile time, and every field a fixed
offset and a fixed width. There is no repetition (arrays: since added,
FIXED-LAYOUT-ARRAYS.md), no union or
overlay (overlap is rejected), no bitfield, no conditional or
length-dependent field, no variable-length tail, no explicit byte order, no
floating-point scalar and no pointer scalar (pointer fields came later,
native-only: NATIVE-LAYOUT-VIEWS.md). Each is future work with a
place in this model (see [Report, items 65-74](#future-binary-work-65-74));
none is approximated.

### Modules

A layout is a member of its module like a struct: named qualified after the
module is imported (`LayoutStruct[geo::shapes::Point]`,
`binary::parse(geo::shapes::Box, data)`), bare inside its module, never
reachable through `import type` (a layout is not a type: `NOT-A-TYPE`) and
never a value of its module (`LAYOUT-NOT-A-VALUE`). Module functions take
and return its `LayoutStruct`s.

### Not a streaming or transducer system

This milestone consumes and produces finite byte values: one call, one
record, the whole input. There is no reader cursor, no buffered stream, no
incremental decoder, no partial or prefix parse and no lazy view. The future
binary system -- streaming, transducers, dependent lengths, cursors, views --
is a separate abstraction that will sit beside layouts (a stream of records
may well imprint each record with a layout); layouts do not grow into it.

### C FFI is one consumer

`layout` is not a C feature. It records physical facts that any binary format
has -- sizes, offsets, encodings -- and C FFI is one producer and consumer of
them. The future C-header plugin will generate *target-resolved* layouts from
headers: it asks its own C front end for each struct's resolved size,
alignment and field offsets on one target, maps each C scalar type to an
integer domain of that target's width (`unsigned long` is 32 bits on
Windows x86-64, 64 on Linux x86-64), and prints `layout` declarations. Botlish
never models C layout rules (natural alignment, packing pragmas,
`__declspec(align)`, bitfield allocation): it receives their results.
`examples/binary/c-structs.bot` is what such a plugin would emit for five
structs on Windows x86-64, written by hand.

### Imprinting is not mapping

Binary imprinting turns representation into structure. Mapping turns
structured values into other structured or domain values. A layout's struct
view is deliberately raw -- C names, C domains, a flag word as an integer --
and the application's own types (`RawInputDevice`, `WindowHandle`) carry
domain meaning without offsets. The conversions between them are ordinary
functions; there is no mapper syntax. The patterns those functions show are
recorded in [items 57-64](#mapper-evidence-57-64) as evidence for a future
mapper design.

## Implementation

```
layout declaration        surface/parser.tcl (layoutdecl), surface/lower.tcl (LayoutDeclOf)
      |
resolved static layout    hir/layouts.tcl: the registry, one entry per layout (validated)
      |
descriptor constant       hir/resolve.tcl (parse's operand), hir::layouts::Elaborate (emit's)
      |
imprinting / emission     core/binary.tcl (interp: reads the descriptor at run time)
                          compiler/compiler.tcl (one binary scan / binary format)
                          native/lower.tcl (one binload / binstore per scalar)
      |
LayoutStruct[L] / bytes
```

**The registry** (`hir/layouts.tcl`) is the one authoritative representation
of a resolved layout:

```
{id ID name NAME namespace NS size N align A span SPAN fields FIELDS}
FIELD = {name F offset O kind scalar width W signed 0|1 endian little type T}
      | {name F offset O kind layout layout INNER width W type T}
```

T is the field's consumer type, W its byte width (a nested layout's width is
its size); `endian` is recorded per field so an explicit big-endian encoding
is one more value, never a new representation. Nothing else records an
offset, a width or a size: `hir/structs.tcl`'s accessors answer for the
struct identity `LayoutStruct[ID]` from this registry (field names and
types), so `LayoutStruct[L]` is `{nstruct LayoutStruct[L]}` -- an ordinary
named-struct type to every analysis and backend -- without a second schema.
It is registered by `hir::sourcetypes::apply` after the integer domains its
fields name and before the structs whose fields may name `LayoutStruct[L]`.

**Static evidence.** Each binary operation is a root native whose
registration carries a layout role (`core/native.tcl`'s `-layout`: `operand
K`, `input K`, `query length|alignment`, `typed {AT FORM}`, `op parse|emit`),
read by every layer -- never a check keyed on a native's name. Resolution
turns parse's layout operand into the layout's **descriptor** constant and
folds the queries to Int constants; after the checks,
`hir::layouts::Elaborate` rewrites `binary::emit(v)` to the internal
`binary#emit(v, DESCRIPTOR)` from v's static type. The descriptor is the
self-contained static text of one layout:

```
{STRUCTID SIZE ALIGN {FIELD ...}}
FIELD = {NAME OFFSET u|i WIDTH ENDIAN} | {NAME OFFSET layout DESCRIPTOR}
```

so after elaboration no backend reads the registry for a binary operation.

**Backends.** The interpreter runs `core/binary.tcl`, the reference
implementation, reading the descriptor at run time. The Tcl compiler reads
it statically and emits one length check and one `binary scan` (parse) or
one `binary format` (emit) whose format string holds every scalar's absolute
offset and encoding, building the value in place. Native lowering reads it
statically and emits one `binload` (parse, after one `byteslen`/`ieq`/`br`
length check and `faildeclared`) or one `binstore` (emit, after one
`byteszeroed` of the size) per scalar field with constant offset and encoding
operands, and a `structnew` per (nested) LayoutStruct -- none when the value
is only read (escape analysis holds a parse result as fields:
`hir::escape::LayoutParseResult`) or when an emitted value is held as fields
or written as the argument. Two layouts lower differently only because their
offsets differ, exactly as `x.field` at two struct types does: there is no
instance machinery, no specialization key and no runtime schema walker in a
compiled backend. In machine code each `binload`/`binstore` is a call of a
small runtime helper (`rt_bin_load`/`rt_bin_store`: bounds, encoding, a
BigInt for an unsigned 64-bit value above i64::MAX).

**Tooling.** No new command: `main.tcl -ast FILE.bot` prints a layout
declaration as written, `-hir` prints each resolved layout's line (identity,
namespace, size, alignment, every field's type and offset) and every binary
operation with its descriptor constant, `-code` the Tcl compiler's
`binary scan`/`binary format`, and `-emit-nir` the `binload`/`binstore`
sequence. A malformed declaration's diagnostic names the bytes, fields and
types involved and is located at the offending number, type or name. A
`botlish layout NAME` query (a layout's resolved facts by name) would be a
convenience over `-hir`, not built.

**Compilation isolation and interchange.** The registry is one of the
declaration registries `hir::declarations::capture` / `Install` save with
every HIR and `hir::activate` reinstalls (COMPILATION-ISOLATION.md), and HIR
text prints each layout on one line (`layout ID ns NS size N align A fields
F: T at O, ...`, read back by `hir/read.tcl`), so HIR interchange
(HIR-INTERCHANGE.md) and the front-end cache carry layouts completely.

## Report

### Syntax and type system (1-12)

1. **Final `layout` syntax.** A top-level declaration
   `layout NAME:` followed by an indented block of exactly one `size N`, one
   `align N` and at least one `field NAME: TYPE at OFFSET` line, in any order
   ([Guide](#layout-declarations)). All five words are contextual. A
   malformed body is a located syntax error (`tests/binary-layout.test`'s
   `bl-syntax-errors`: missing size, align, `at` or fields; a repeated
   `size`; a nested declaration; items on the header line).
2. **Layout name resolution.** A layout's identity is its declaration
   identity (`Name` in the entry program, `ns::Name` in module `ns`); a bare
   spelling resolves in the code's own namespace, a qualified one to exactly
   that module's declaration after `import ns` (`MISSING-IMPORT` otherwise),
   with no `import type` (`NOT-A-TYPE`). Layouts share the one type
   namespace of structs, enums, traits and source types (`TYPE` on a
   collision). A layout name is accepted in exactly three places: the
   argument of `LayoutStruct[...]`, a layout field's type, and the layout
   operand of a binary operation; anywhere else it is `LAYOUT-NOT-A-TYPE`
   (a type position) or `LAYOUT-NOT-A-VALUE` (a value position).
3. **Internal resolved-layout representation.** One registry entry per
   layout in `hir/layouts.tcl` (`{id name namespace size align span
   fields}`, each field `{name offset kind scalar width signed endian type}`
   or `{name offset kind layout layout width type}`); everything else --
   the struct view's field names and types, the descriptor, HIR text, the
   checks -- is derived from it ([Implementation](#implementation)).
4. **`LayoutStruct[T]` typing rule.** `LayoutStruct[T]` is well formed iff T
   names a layout L visible where it is written; it then denotes the named
   struct type `{nstruct LayoutStruct[L]}` whose fields are L's, each with
   its declared consumer type (the scalar's integer domain, or
   `LayoutStruct[Inner]`). Subtyping is nominal: `LayoutStruct[A] <:
   LayoutStruct[B]` iff A and B are the same declaration.
5. **Why this is imprinting rather than generic specialization.** Nothing is
   parameterized: no struct body is written over a type variable and then
   instantiated. `LayoutStruct[L]` is a type *derived* from one declaration
   -- its field set is mechanically L's, recorded once -- the way a
   construction `Map[str, Reg] {...}` is justified by its explicit applied
   type (NATIVE-BOTLISH-LOWERING-IMPL.md, section 6.3). Parse and emit of two
   layouts lower differently only because two descriptors differ, exactly as
   `x.field` at two struct types does; there is no instance, no
   specialization key, no monomorphization and no generic-instance machinery
   (the semantic-instance and specialization layers never see a layout).
6. **How fields are derived.** From the registry, in declared order: a
   scalar field's consumer type is its declared integer domain (so
   `v.flags` has type `int[CULong]`), a nested field's is
   `LayoutStruct[Inner]`. Offsets, widths, padding and byte order are not
   fields and are not observable.
7. **Field-access behavior.** Ordinary named-struct projection with the
   precise field type; an absent name (a padding byte, a typo) is
   `UNKNOWN-FIELD` at the projection, listing L's fields.
8. **Destructuring behavior.** The ordinary struct destructuring, nested
   included (`{count: c, inner: {x: ix, y: iy}} = o`).
9. **Construction behavior.** `LayoutStruct[L] {field: value, ...}`, checked
   like any named construction: complete, exact, every value proven in its
   field's domain (no conversion, truncation or runtime guard; a wider
   domain is not assignable because some of its values fit). Only
   `LayoutStruct[L]` among the applied types has a construction
   (`UNKNOWN-STRUCT` for `List[int] {...}`), and a layout's own name
   constructs nothing (`UNKNOWN-STRUCT`, hinting `LayoutStruct[L] {...}`).
10. **Invalid-parameter diagnostics.** `LAYOUT-STRUCT-PARAMETER` names what
    the argument is instead ("int is a built-in type", "S is a struct",
    "R is a refinement type", "E is an enum", "D is a type", "List[int] is
    an applied or structural type"), `UNKNOWN-LAYOUT` an unknown name, the
    arity error a bare `LayoutStruct` -- each located at the annotation
    (`bl-type-invalid-parameter`, `bl-type-unapplied`; seven golden
    `rejects_at` tests).
11. **Interaction with ordinary, mutable and context structs.** A
    `LayoutStruct` is an ordinary immutable value: a field of an ordinary
    struct or of a context struct (installed with `with context`, read by a
    context parameter), an element of a `MutableVector` or a
    `MutableArray`, a List element, an `ImmutableSet` member, a closure
    capture, a function argument and result (`bl-consumer-struct-behavior`,
    `bl-consumer-containers`). Botlish has no mutable struct; a
    `LayoutStruct` is never mutated in place (build a new one). Like every
    struct type it is not yet a refinement carrier (`REFINEMENT-CARRIER`,
    `bl-type-refinement-carrier`), and a layout field cannot name a struct
    or a `LayoutStruct` (a nested layout field names the layout).
12. **No generic struct declaration syntax was added.** `struct Foo[T]:`,
    `LayoutStruct Foo:`, `layout struct Foo:` and `context struct Foo[T]:`
    are syntax errors (`bl-syntax-no-generic-struct-declarations`);
    `LayoutStruct` is a built-in applied type of arity one whose argument is
    a layout, never a type parameter.

### Binary semantics (13-25)

13. **Supported scalar representations.** The eight fixed-width integer
    encodings -- unsigned and two's-complement, 1, 2, 4 and 8 bytes --
    little-endian. A field's encoding is its domain's: any integer domain
    whose interval is exactly an encoding's value set qualifies
    (`binary::U16`, `abi::U16Value`, `byte::Byte`, `Int in -128..127`), and
    `int`, a narrower or exact-set domain, a refinement, `bool`, `str` do not
    (`LAYOUT-FIELD-TYPE`, with the reason). Unsigned 64-bit values above
    i64::MAX are ordinary Ints (BigInts natively).
14. **Size semantics.** The size is explicit, 1 to 2^31 - 1 bytes; every
    field must lie inside it (`LAYOUT-FIELD-BOUNDS`); bytes after the last
    field are trailing padding. Parse requires exactly the size; emit
    produces exactly the size.
15. **Alignment semantics.** The alignment is explicit, a power of two up to
    2^28, recorded and reported (`binary::layout_alignment`) but imposing no
    rule on offsets or on the size: a resolved foreign layout is
    authoritative, packed and over-aligned layouts included. Nothing places
    a layout in memory in this milestone, so nothing consumes it yet.
16. **Explicit offsets.** Every field states its byte offset; fields may be
    declared in any order, may leave gaps, may sit at any offset, and never
    share a byte (`LAYOUT-FIELD-OVERLAP`).
17. **Padding.** The bytes no field covers. Never a field, never observable
    in a value; ignored by parse; written as zero by emit.
18. **Nested layouts.** By value, at the field's offset, width the inner
    size; its value an ordinary `LayoutStruct[Inner]`; no cycles
    (`LAYOUT-CYCLE`).
19. **Parse semantics.** `binary::parse(L, data)`: data must be exactly L's
    size, then every scalar is read at its absolute offset in its encoding;
    the result holds the fields only, never the input.
20. **Emit semantics.** `binary::emit(v)`: L from v's static type; a fresh
    `abi::bytes::Bytes` of L's size, zero, with every scalar written at its
    absolute offset in its encoding. Infallible; never truncates.
21. **Error behavior.** Exactly one failure: the payload-free builtin
    declared error `LayoutLengthMismatch` (parse, wrong length), an ordinary
    declared error (handled, declared in `errors`, or `UNHANDLED-ERROR`).
    Emit declares none. Every misuse is static: `BINARY-OPERAND`,
    `LAYOUT-OPERAND`, `UNKNOWN-LAYOUT`, `LAYOUT-NOT-A-VALUE`,
    `LAYOUT-NOT-A-TYPE`, `LAYOUT-STRUCT-PARAMETER` -- each a
    `compiler::DiagnosticCode` case, so a `static compile:` block reifies it.
22. **Exact/prefix input rule.** Exact only: fewer and more bytes are both
    `LayoutLengthMismatch` (`bl-length-rule`); no prefix parse, no cursor,
    no remainder.
23. **Deterministic padding policy.** Emitted padding is always zero, so
    equal values emit equal bytes and no uninitialized memory is ever
    exposed (`bl-padding`, `bl-determinism`; the padding mutants of every
    backend are killed).
24. **Round-trip theorem.** `binary::parse(L, binary::emit(v)) == v` for
    every v (`bl-round-trip`, every fuzz program); `binary::emit(binary::
    parse(L, b)) == b` iff b's padding is zero (emission canonicalizes
    padding).
25. **Byte-level independent tests.** `bl-parse-explicit-bytes` and
    `bl-emit-explicit-bytes` state literal byte sequences in both directions
    -- every width's extremes, zero, all bits set, signed fields, padding,
    explicit offsets, nested layouts -- so a parser and an emitter sharing
    one wrong assumption fail; the fuzzer's oracle assembles and decodes the
    bytes itself, never reading a descriptor or generated code.

### C readiness (26-37)

26-29. **Examples.** `examples/binary/c-structs.bot` (on every backend,
    `bl-c-structs-example`): `RAWINPUTDEVICE` (16 bytes, naturally aligned,
    no padding, a pointer-width handle), `SAMPLE` (12 bytes, 3 of padding
    after each `unsigned char`), `POINTS` (two `POINT`s nested by value),
    and two unusual vendor-resolved layouts -- `PACKED_HEADER` (`#pragma
    pack(1)`: a `u32` at offset 1, size 7, alignment 1) and `ALIGNED`
    (`__declspec(align(32))`: 28 bytes of trailing padding) -- with
    `LayoutStruct[RAWINPUTDEVICE] <-> RawInputDevice` conversions both ways.
    (`tests/binary-layout.test`'s `Vendor` layout is a further one: a `u32`
    at offset 1, alignment 64, 49 bytes of trailing padding.)
30. **What an eventual C-header plugin would emit.** For one target: one
    integer domain per C scalar type at that target's width (`type CULong =
    Int in 0..4294967295` on Windows x86-64), and one `layout` per struct
    with the sizes, alignments and offsets its C front end resolved, nested
    structs as nested layouts, probably one module per header and target
    (`ffi::c::windows::RAWINPUTDEVICE`). Botlish needs no C rule to accept it.
31. **Remaining blockers for basic C structs.** Pointer fields (a stand-in
    domain gives the width only), fixed arrays (`char name[16]`), unions,
    bitfields, `float`/`double` (Botlish has no floating-point value), C
    `_Bool` (a 1-byte field whose domain `0..1` is not a full encoding: it
    must be a `U8` field converted by the wrapper), and anything
    variable-length. Calling C at all (the FFI milestone) is out of scope.
32. **Arrays.** Not supported: a field is a scalar or a nested layout. A
    fixed array is the first repetition construct (item 66; since added,
    FIXED-LAYOUT-ARRAYS.md).
33. **Unions.** Not supported: overlap is rejected, never implied. An
    overlay is a future explicit construct (item 67).
34. **Bitfields.** Not supported. A plugin can declare the storage unit as a
    scalar field and let the wrapper extract bits (as the example's flag
    word is split), which keeps the C compiler's bitfield allocation out of
    Botlish.
35. **Incomplete types.** Not representable: a layout has a fixed size.
    An incomplete struct is only ever behind a pointer, an opaque pointer
    scalar (item 36).
36. **Pointer-field readiness.** (Resolved by NATIVE-LAYOUT-VIEWS.md:
    `ffi::c::Ptr[T]`/`FnPtr[F]` fields of the target's width, read only
    through native views.) The width is representable (a 64-bit
    unsigned domain), the meaning is not: a pointer is not a number, so the
    example's `HandleBits` is explicitly a stand-in. What is missing is an
    opaque pointer-width scalar type (no arithmetic, no construction from an
    Int outside the FFI layer) that a layout field may have; the registry
    already records width, signedness and byte order per field, so it is
    one more scalar kind there.
37. **Target-specific layout story.** Layouts are target-resolved data: a
    plugin emits one set of domains and layouts per target, and the program
    imports the target's module. Botlish models no ABI. Byte order is the
    target's (little-endian, recorded per field so a big-endian target or
    format is a value of the registry, not a new representation).

### Implementation behavior (38-48)

38. **interp.** `core/binary.tcl` reads the descriptor at run time (the
    reference implementation).
39. **compile.** One length check plus one `binary scan` for parse, one
    `binary format` for emit, every offset and encoding in the format
    string; no `core::binary` call (`bl-tcl-generated-code`). For
    `SAMPLE`-like `Padded`: `binary scan $raw @0cu@4i@8cu t1 t2 t3` and
    `binary format @0c@4i@8c@12 ...`.
40. **Generic native (`-specialize 0`).** Exactly the same NIR as
    specialized for both operations (item 43's functions differ only in
    their `instance=` label): the lowering reads the descriptor, never a
    specialization.
41. **Specialized native.** As item 40; a parse result whose fields only are
    read is held as fields (no object), and an emitted value built locally
    or written as the argument is never built as an object.
42. **Representative HIR.** (`main.tcl -hir`)

    ```
    layout Sample ns - size 12 align 4 fields tag: binary::U8 at 0, value: binary::I32 at 4, flag: binary::U8 at 8
    e349 call native(binary::parse) : LayoutStruct[Sample]
        e350 ref b82 binary::parse : native binary::parse
        e351 const str {{LayoutStruct[Sample]} 12 4 {{tag 0 u 1 little} {value 4 i 4 little} {flag 8 u 1 little}}} : str
    e355 project value : int[binary::I32]
    e361 call native(binary#emit) : abi::bytes::Bytes
        e363 struct LayoutStruct[Sample] (tag, value, flag) : LayoutStruct[Sample]
        e379 const str {{LayoutStruct[Sample]} 12 4 {...}} : str
    ```

43. **Representative NIR.** (`main.tcl -emit-nir`; `read` returns
    `s.value + s.flag` of a parse, `write(v)` emits a construction)

    ```
    func 1 "read"                               func 2 "write"
        %1 = structget 0 %0                         %5 = int 12
        %2 = op byteslen %1                         %6 = op byteszeroed %5
        %3 = int 12                                 %7 = int 0
        %4 = op ieq %2 %3                           %8 = int 1
        br %4 L0 L1                                 %9 = op binstore %6 %7 %8 %1
      label L1                                      %10 = int 4
        faildeclared ... "LayoutLengthMismatch"     %11 = int 20
      label L0                                      %12 = op binstore %6 %10 %11 %0
        %5 = int 0                                  %13 = int 8
        %6 = int 1                                  %14 = int 1
        %7 = op binload %1 %5 %6                    %15 = op binstore %6 %13 %14 %3
        %8 = int 4                                  %16 = structnew 0 %6
        %9 = int 20                                 ret %16
        %10 = op binload %1 %8 %9
        %11 = int 8
        %12 = int 1
        %13 = op binload %1 %11 %12
        %14 = op runbox %10
        %15 = op runbox %13
        %16 = op riadd %14 %15
        %17 = op rbox %16
        ret %17
    ```

    The encoding word is the width plus 16 when signed (plus 32 for
    big-endian, unused). No `structnew` of the `LayoutStruct` in either.
44. **Allocation behavior.** Natively, parse-then-read allocates nothing
    per record; parse of a kept record allocates its struct (one per nested
    layout too); emit allocates the storage and its `abi::bytes::Bytes`
    (two per record), construct-then-emit the same two -- never the
    `LayoutStruct` (`bl-allocations`; the benchmark's allocation table).
45. **Compile-time layout validation.** Every rule of
    [the declaration table](#layout-declarations) at declaration time,
    located; the operand rules at resolution and in `hir::layouts::verify`.
    Two diagnostics were improved during the report: a struct named as a
    field type now says it is a struct (structs register after layouts), and
    `LayoutStruct[L]` as a refinement carrier is `REFINEMENT-CARRIER` like
    any struct instead of a misleading unknown layout.
46. **Compilation-isolation results.** The layout registry is captured
    with every HIR's declarations and reinstalled by `hir::activate`;
    nothing a backend reads about a layout comes from process state (the
    binary operations carry the descriptor). `bl-isolation`: two programs
    declaring a same-named layout with swapped offsets, compiled one after
    the other, each still emits its own bytes on every backend.
    `tests/compilation-isolation.test` passes (its inventory of captured
    registries now lists `layouts`), and
    `audit/compilation-isolation/tools/interleave.tcl`, whose default suites
    now include `binary-layout.bot`: 10 suites, 80 artifacts and outcomes
    compared after their own compilation and again after all the others, 0
    differ. `audit/compilation-isolation/tools/mutate.tcl`: 14 mutants, 14
    killed.
47. **Interchange results.** HIR text prints each layout on one line and
    reads it back (`bl-hir-text-roundtrip`: format, read, format again is
    identical, and the read HIR runs to the same value); the interchange
    format carries the layouts with the declarations (`bl-interchange`: a
    program written, then read back after another compilation that declares
    a same-named layout, runs to the same outcome on every backend).
    `tests/hir-interchange.test` and `tests/hir-cache.test` pass, and
    `audit/hir-interchange/tools/roundtrip.tcl` (default suites now with
    `binary-layout.bot`): `-via interchange`: 10 suites, 90 checksums (each
    suite's HIR, artifacts and outcomes) identical after a fresh process
    reads them back with no build; `-via cache`: 100 compared (with each
    suite also built alone), 0 differ.
    `audit/hir-interchange/tools/mutate.tcl`: 24 mutants, 24 killed.
48. **Mutation/fuzz results.** `audit/binary-layout/tools/mutate.tcl`: 39
    mutants (`mutants.txt`) -- the brief's ten bugs, each at every layer that
    implements the rule separately (ignored offsets in the interpreter's
    parse and native parse and nested emit; a prefix parse or unchecked length
    on each backend; emission one byte short or sized by its fields;
    sequential emission on each backend; a wrong width in the Tcl letters,
    native lowering, the Rust load and the declaration's encoding rule; a
    wrong byte order in the Tcl letters, native lowering, the Rust store and
    load; non-zero padding on each backend; a one-byte overlap accepted;
    structural compatibility of two layouts; skipped nested emission on each
    backend; `LayoutStruct[T]` of any T), 29 in all, and ten more (signedness on
    each layer, a field one byte past the size, a truncating native store,
    emission never elaborated, the operand check skipped, a layout as value
    reported as unbound, and two scalar-replacement regressions). **All 39
    are killed.** Per detector: the Tcl suite kills 38, the golden suite 33,
    the fuzzer 29, the Rust runtime tests all 6 native mutants. Only the Tcl
    suite sees the declaration checks (a layout is top level, so no golden
    `static compile:` block can declare one, and the fuzzer generates valid
    layouts) and the allocation regressions (NIR and allocation counts);
    only the Rust tests see the truncating store (no checked program can
    reach it). The first run left one survivor, a one-byte overlap at either
    end of a field, which `bl-declaration-overlap` did not cover; it now has
    those boundary cases and kills it.

    `audit/binary-layout/tools/fuzz.tcl` (random layouts of one to six
    scalars of every width and signedness at random gapped offsets, random
    alignment, sometimes a nested layout; values biased to every encoding's
    extremes; random input bytes, padding included; an independent byte
    model): seeds 1, 17, 41 and 99 at 40 programs each and seed 5 at 20
    programs under `BOTLISH_NATIVE_GC_STRESS=1`, every program on all four
    backends: no disagreement. One generator fix along the way: a one-byte
    layout's "one byte fewer" input is empty, and `bytes_of([])` hits a
    front-end limitation unrelated to layouts (an empty literal's
    `List[never]` instance of a loop-collecting function fails to type,
    reproduced on the commit before this work); the generator spelled it
    `abi::bytes::from_list([])` until that was fixed
    (M7AA-EMPTY-COLLECTION-AND-APPLIED-TYPE-SEMANTICS.md, "Addendum:
    collecting loops over an empty domain"), and spells it `bytes_of([])`
    again.

### Performance (49-56)

`bench/binary-layout.tcl` (4-core container, 2026-10-16; best of 5 runs;
n = 2000 records per program on the Tcl backends, 200,000 natively). Time
per record over the program's baseline, Cranelift specialized unless noted:

| operation | Tcl interp | Tcl compile | Cranelift `-specialize 0` | Cranelift |
|---|---:|---:|---:|---:|
| parse `Device` (16 bytes, 4 fields), record kept | 54 us | 1.3 us | 162 ns | 153 ns |
| parse `Device`, read two fields (record not kept) | 115 us | 7.5 us | 53 ns | 53 ns |
| emit `Device` | 69 us | 1.7 us | 139 ns | 121 ns |
| construct `Device`, then emit | 137 us | 11.7 us | 133 ns | 140 ns |
| round trip `parse(emit(v)) == v` | 150 us | 9.6 us | 347 ns | 340 ns |
| parse `Sample` (12 bytes, 3 fields, 6 padding) | 48 us | 1.8 us | 98 ns | 92 ns |
| emit `Sample` | 50 us | 2.0 us | 125 ns | 115 ns |
| parse `Segment` (two nested `Point`s) | 58 us | 4.3 us | 396 ns | 299 ns |
| round trip `emit(parse(d)) == d` of `Segment` | 150 us | 6.9 us | 553 ns | 533 ns |
| reference: an ordinary struct of the same 4 fields | 90 us | 6.5 us | 109 ns | 102 ns |
| reference: the same 16 bytes from a List (`abi::bytes::from_list`) | 116 us | 32.5 us | 117 ns | 116 ns |

Native heap allocations per record (Cranelift's counters): parse kept 1
(the struct; `Segment` 3, one per nested layout), parse then read 0, emit 2
(the storage and its `abi::bytes::Bytes`), construct then emit 2 (the
`LayoutStruct` is never built), the ordinary-struct reference 1, the
`from_list` reference 2.

49. **Parse benchmark.** Natively a 4-field record is imprinted and kept in
    153 ns, imprinted and read without being kept in 53 ns; a padded
    3-field record in 92 ns. On the Tcl compiler 1.3-1.8 us, on the
    interpreter about 50 us (the interpreter's cost per operation: an
    ordinary 4-field struct costs it 90 us).
50. **Emit benchmark.** Natively 121 ns for 4 fields, 115 ns for the padded
    3-field record, 140 ns when the value is constructed in place; Tcl
    compiler 1.7-2.0 us; interpreter about 50-70 us.
51. **Per-record approximate cost.** Natively about 10-13 ns per field read
    (a runtime helper call each) plus the struct allocation when the record
    is kept, and a fresh storage plus its `Bytes` wrapper per emission plus
    a helper call per field: parse and emit each cost about what building an
    ordinary struct of the same fields (102 ns) or the same 16 bytes from a
    List (116 ns) costs. Neither is a schema walk.
52. **Compiler/lowering cost.** A generated program of 200 layouts of eight
    scalar fields, each emitted, parsed and read once, against 200 ordinary
    structs of the same fields constructed and read: front end 17.8 ms per
    layout against 14.2 ms per struct (the layout program also does more:
    an emission and a parse per declaration), the Tcl compiler 1.0 against
    0.9 ms, native lowering to NIR 15.5 against 12.7 ms, Cranelift 0.97
    against 0.17 ms (sixteen helper calls per layout use against struct code
    that folds away). Validation and descriptors are a small part of the
    front end; nothing grows faster than the declarations at this size (only
    K = 200 was measured).
53. **Any gross allocation path.** None on the GC heap (the table above:
    nothing per record beyond the struct kept, the emitted storage and its
    wrapper). The benchmark did find one non-GC path: the native store
    range-checked each value by converting it to a heap BigInt (three small
    mallocs per field), which made emission four times a parse per field;
    it now checks as i128 with no allocation (emit 338 -> 121 ns per record,
    construct-then-emit 451 -> 140 ns, round trip 482 -> 340 ns).
    Remaining avoidable allocations: `emit(parse(d))` builds the parsed
    objects (a parse result passed straight to emit is not held as fields,
    and a nested `LayoutStruct` is always an object), 5 per `Segment` round
    trip.
54. **Generic versus specialized native behavior.** The binary operations
    lower to identical NIR with and without specialization (item 40); the
    differences in the table (at most a third, on the `Segment` parse) come
    from the surrounding loop and collection code, not from the layout
    operations.
55. **Whether fixed offsets become direct operations.** In NIR, yes: one
    `binload`/`binstore` per scalar field whose offset and encoding are
    constant operands, no descriptor or schema read at run time, one length
    check per parse. In machine code each is still a call of a small runtime
    helper (bounds, encoding dispatch, a BigInt for an unsigned 64-bit value
    above i64::MAX), not an inline load or store.
56. **Deferred optimization opportunities.** Inline little-endian loads and
    stores in Cranelift (the length check, together with the layout's
    validated bounds, already proves every field in range, so each field is
    a plain load with a sign or zero extension); dropping the loads of
    unread fields (a `binload` is marked fallible, so a parse whose record
    is only partly read still loads every field, though none can fail after
    the length check); holding a parse result passed straight to emit, and
    nested `LayoutStruct`s, as fields; not building the `abi::bytes::Bytes`
    wrapper of an emission consumed at once. None changes semantics.

### Mapper evidence (57-64)

From `examples/binary/c-structs.bot`'s `raw_input_device` and `to_raw`.

57. **Wrapper conversions written.** `LayoutStruct[RAWINPUTDEVICE] ->
    RawInputDevice` (fallible: `UnknownDeviceFlags {flags}`) and
    `RawInputDevice -> LayoutStruct[RAWINPUTDEVICE]` (fallible:
    `UsageOutOfRange`), plus the nested `POINTS` read as a value.
58. **Repeated field-rename patterns.** Every field is renamed one to one
    in both directions (`usUsagePage <-> usage_page`, `usUsage <-> usage`,
    `hwndTarget <-> target.bits`): a pure name mapping is the bulk of the
    text, and both directions repeat it.
59. **Repeated per-field converters.** Widening a domain field into `int` is
    free (subtyping); the reverse needs a range check with a failure
    (`page < 0 or page > 65535`), once per narrowed field. A flag word is
    split into Booleans by bit tests and repacked from them; a raw handle is
    wrapped in a newtype struct (`WindowHandle {bits: ...}`) and unwrapped.
60. **Nested conversion patterns.** The handle wrapper is a nested struct on
    the domain side for a scalar on the layout side; a nested layout
    (`POINTS`) is passed through as `LayoutStruct[POINT]` values, which a
    wrapper would convert field by field like the outer one.
61. **Ignored/defaulted fields.** None ignored: the application rejects
    unknown flag bits rather than dropping them, and the reverse direction
    writes every field (unused flag bits are zero by construction). A
    `reserved` field would be the first defaulted one.
62. **Error-producing conversions.** Both directions can fail with an
    application error -- unknown flags (with the offending word as payload),
    a usage out of its C domain -- and neither is a layout error: imprinting
    itself cannot fail on a field.
63. **Patterns general enough to inform a mapper design.** One-to-one field
    renames; domain widening (free) versus narrowing (a checked conversion
    with a declared error, per field); flag word <-> set of Booleans (a bit
    table); newtype wrap/unwrap; recursion into nested layouts. One friction
    point: a range proof does not cross a function returning a constant
    (`input_sink() + no_legacy()` is not proven inside `U32`), so the packed
    word uses literal branch values -- a mapper with declared bit tables
    would carry the facts itself.
64. **What remains ordinary application code.** The policy: whether unknown
    bits are an error or ignored, which error and payload, which C fields an
    application type exposes at all, and how a handle is represented.

### Future binary work (65-74)

65. **Repetition.** A field repeated a fixed number of times, the element a
    scalar or a layout, at a fixed stride: the registry gains a count and a
    stride per field, the consumer type a fixed-length `List` (or an array
    type), and both directions stay straight-line or one loop per field.
66. **Arrays.** The first repetition form (`char name[16]`, `POINT pts[4]`);
    the C plugin emits them directly. The open question is the consumer
    type: a `List[T]` of proven length versus a fixed-length array type.
    (Answered by FIXED-LAYOUT-ARRAYS.md: a List, whose length a whole-array
    write checks unless the compiler proves it.)
67. **Unions/overlays.** An explicit overlay construct whose alternatives
    share bytes; its value is a sum, so it waits for enums with payloads
    (ENUMS.md's planned extension) and a discriminant rule. Overlap stays an
    error everywhere else.
68. **Views.** (Native memory's came first: `NativeView[L]`,
    NATIVE-LAYOUT-VIEWS.md.) A zero-copy `View[L]` over borrowed storage reading fields
    lazily -- a separate abstraction with a lifetime, never what
    `LayoutStruct` silently becomes (it retains nothing by design).
69. **Mutable views.** (Native memory's came first: `NativeEdit[L]`, and
    field writes into a `MutableBytes`, NATIVE-LAYOUT-WRITES.md.) Writing fields into foreign or shared storage in
    place: needs the view and an ownership story for the storage
    (MutableBytes-like values, affinity), not a mutable `LayoutStruct`.
70. **Streaming.** Records imprinted one at a time from a byte stream: a
    reader that hands each record's bytes to a layout, beside layouts, not
    inside them.
71. **Transducers.** Composable byte-to-value stages (framing, decoding,
    validation) of the future binary system; a layout is a natural leaf
    stage.
72. **Dependent lengths.** A field whose size depends on an earlier field's
    value (a length-prefixed payload) leaves the fixed-layout subset: the
    descriptor stops being static, so it belongs to the streaming system,
    not to `layout`.
73. **Explicit endian formats.** The registry and descriptor already carry
    `endian` per field, and the native encoding word and the Tcl format
    letters already have big-endian forms; what is missing is syntax (a
    per-field or per-layout byte order) and tests.
74. **Parser/emitter cursor APIs.** Deliberately absent (exact length, whole
    values). A cursor API would be the streaming system's: a position, a
    remainder and a layout applied at the position.

## Files

| file | what |
|---|---|
| `surface/parser.tcl` | `layoutDecl`, `LayoutStruct[L] {...}` (a `namedstruct` with `typeArg`) |
| `surface/ast.tcl`, `surface/lower.tcl`, `surface/modules.tcl` | AST printing, `LayoutDeclOf`, module membership and references |
| `hir/layouts.tcl` | the registry, validation, the struct view, descriptors, roles, `verify`, `Elaborate` |
| `hir/sourcetypes.tcl`, `hir/structs.tcl`, `hir/declarations.tcl` | registration order, the struct accessors, isolation capture |
| `hir/types.tcl`, `hir/resolve.tcl` | `LayoutStruct[L]` typing, operand resolution, query folding, diagnostics |
| `hir/escape.tcl` | parse results and emitted values held as fields |
| `hir/format.tcl`, `hir/read.tcl` | HIR text of layouts |
| `hir/static.tcl`, `lib/compiler.bot`, `lib/test.bot` | the six new `compiler::DiagnosticCode` cases |
| `core/binary.tcl`, `core/native.tcl` | the reference implementation, registrations, the `-layout` role |
| `compiler/compiler.tcl` | `CompileLayoutOperation` |
| `native/lower.tcl` | `LayoutCall`, `LayoutDecode`, `LayoutEncode` |
| `native/src/nir.rs`, `native/src/runtime/ops.rs`, `native/src/codegen/clif.rs` | `binload`, `binstore`, `byteszeroed` |
| `lib/binary.bot` | the `binary` namespace and its scalar domains |
| `examples/binary/c-structs.bot` | C structs as layouts, with wrappers both ways |
| `tests/binary-layout.test` | the Tcl suite (authoritative) |
| `tests/golden/binary-layout.bot` | the golden suite |
| `audit/binary-layout/tools/fuzz.tcl` | random layouts against an independent byte model |
| `audit/binary-layout/tools/mutate.tcl`, `mutants.txt` | mutation testing |
| `bench/binary-layout.tcl` | the performance report |

## What to run when changing this

If you change the layout grammar, `hir/layouts.tcl`, the `LayoutStruct`
cases of `hir/types.tcl` or `hir/resolve.tcl`, the registration order in
`hir/sourcetypes.tcl`, the escape cases, the HIR text of layouts, the binary
operations' registrations or roles, `core/binary.tcl`, the Tcl compiler's or
native lowering's layout code, or the native ops, run
`tests/binary-layout.test`, its golden suite (`tclsh9.0 tests/local.tcl
tests/golden/binary-layout.bot`), `audit/binary-layout/tools/fuzz.tcl`
(several seeds, once with `-gc-stress 1`), `audit/binary-layout/tools/mutate.tcl`
(every mutant in `audit/binary-layout/tools/mutants.txt` must still apply and
be killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule) and `cargo test --release
--manifest-path native/Cargo.toml --lib bin_`. A change to what a layout
registers or to a diagnostic also needs the compilation-isolation and
interchange audits (AGENTS.md) and `tests/static-compile.test`.
`bench/binary-layout.tcl` regenerates the performance report.
