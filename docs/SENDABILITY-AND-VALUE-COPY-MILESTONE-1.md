# SENDABILITY-AND-VALUE-COPY-MILESTONE-1.md

Static sendability, and independent value reconstruction across Botlish VMs:
M2 of THREAD-ACTOR-ARCHITECTURE-CENSUS.md.

> A Botlish value is sendable when an equivalent value can be reconstructed
> in another VM without retaining references to the sending VM's heap,
> runtime resources or execution environment. Sendability describes the
> portability of a value's meaning, not whether its current representation
> can be copied as machine words.

```botlish
import std::transfer
import std::abi::bytes
import std::mutable_map

struct Job:
    id: int
    tags: std::mutable_map::MutableMap[str, int]

data = std::transfer::encode(job)              # std::abi::bytes::Bytes
copy = std::transfer::decode[Job](data):       # a Job of this VM's own
    on TransferMalformed:
        ...
    on TransferTypeMismatch:
        ...
    # (and TransferVersion, TransferInvalidValue, TransferLimit)
```

```botlish
opaque struct Name:                            # the owner states it
    text: str
    size: int                                  # derived state
    sendable through(name_text, name_of) as str
```

This milestone adds a compiler-derived judgement of which types can cross
a VM boundary, the intrinsic trait `Sendable`, and a checked operation that
copies such a value into owned bytes and rebuilds it in another VM's heap.
It adds no threads and no cross-thread messaging: those are M3 and M4.

## Contents

1. Executive result
2. Starting state
3. The formal rule
4. Structural derivation
5. The owner's statement (opaque structs)
6. Diagnostics
7. The transfer representation
8. The native codec
9. The Tcl codec
10. Collection semantics
11. Program identity
12. Independent VMs
13. Actors
14. Context authority
15. Refusals
16. Mutation testing
17. Performance
18. Compatibility
19. Next milestones
20. Files, and what to run when changing this

---

## 1. Executive result

**Implemented**, with two limits stated in section 19: a body that is
generic in an *imprint variable* cannot transfer (TRANSFER-OPEN-TYPE), and
physical sharing inside a value is not preserved.

* **`Sendable`**, a third intrinsic trait beside `Hashable` and `Equatable`
  (`hir/traits.tcl`'s intrinsics, witness `hir::types::SendClass`). The
  compiler derives it from checked types: no per-type boilerplate for a
  transparent struct, an enum or a tree. A struct slot may require it
  (`struct Envelope[T satisfies Sendable]:`); a function may take a
  `Sendable` view (`fn seal(x: Sendable)`), which the trait monomorphization
  clones per witness.
* **The owner's statement.** An opaque struct is sendable only when its own
  module says how it is rebuilt, by a clause of its declaration:
  `sendable fields`, `sendable through(TO, FROM) as R`, or the standard
  library's `bytes(F)` / `mutable_bytes(F)` for its byte storage. The
  compiler checks every part of the statement; nothing outside the
  declaration can make a type sendable.
* **`std::transfer::encode(v)` and `std::transfer::decode[T](data)`.** After
  the checks each becomes a run-time operation carrying the schema of the
  value's static type (`hir::transfer::Elaborate`). Both runtimes read the
  same versioned, fingerprinted, names-based byte format: no address, no
  shape or enum number and no `Rc` backing is in the bytes. The receiver
  allocates every object with its own constructors. A map or set rebuilds
  its index and stored hashes under the receiver's own table-hash key.
* **Refusals, never trust.** Decoding checks every byte against the
  receiver's schema: integer domains, strict UTF-8, finite Float64, enum
  indices, stated List lengths, counts against the bytes left, a budget
  for elements of no size, no trailing bytes. A refusal is one of five
  declared errors, never a panic or NATIVE BUG.
* **Independent VMs.** Values cross between separate processes (separate
  VMs, heaps and table-hash keys, the sender exited first) on every pair
  of backends tested; between two native Vms of one process, the first
  dropped before the second decodes, under GC stress with poisoned frees;
  and between independently compiled programs that number their shapes and
  enums differently.
* **Evidence.** `tests/sendability.test` (82 tests) and
  `tests/value-transfer.test` (76 tests, all four backends) pass, and the
  codec's 8 Rust unit tests pass. The mutation harness kills MUTANT-COUNT of
  29 mutants. The format is the same on every backend: fixed byte vectors,
  hashes of encodings compared across backends, and bytes encoded on one
  backend decoded on another.

## 2. Starting state

* **Probe C** (`audit/thread-actor/tools/sendability.tcl`, census 5.2 and
  12.3) classified 29 field types of a matrix program from facts the checker
  already had: types, opacity, context-ness, owner, tree field, affinity.
  It found three counterexamples to a purely structural rule:
  * `std::event_loop::Reg` is two Ints, but they are an identity of one
    Loop;
  * `std::abi::bytes::Bytes` is `storage: any`;
  * `std::mutable_map::MutableMap` reaches an opaque table of stored keyed
    hashes.

  The prototype remains as evidence: the production judgement is
  `hir::types::SendClass`, and the audit's README now points to it.
* **Probe E** carried a nested value between two VMs of one library as
  *text*, which the consumer parsed. It showed two heaps and no shared
  pointers, but no typed format and no refusal of foreign or malformed
  input.
* **Representations, against the census.**
  * The census suggested reusing the canonical hash walk (`ops.rs`'s
    `CanonicalSink`). That walk is not reversible:
    * it folds a set's members into an XOR of sub-hashes;
    * a value's kind is a tag and its content a text, never a typed
      reconstruction.

    The codec is therefore a separate walk, `native/src/runtime/transfer.rs`.
    It shares the walk's discipline (iterative, no allocation while
    reading), not its sink.
  * Float64 has one zero on every backend, the native one included
    (checked: `0.0 * -1.0` and `0.0 - 0.0` encode as +0.0 on all four).
    The decoder can therefore refuse negative zero without refusing any
    value a program can make.
  * An `ImmutableSet` is an intrinsic runtime kind on both runtimes.
    MutableVector and MutableArray are headers over copy-on-write backings,
    as the census described.

## 3. The formal rule

For a closed static type `T`, `Sendable(T)` holds when a valid value of `T`
can be reconstructed in an independent, compatible Botlish execution
environment with the same ordinary value semantics:

1. its content is read without violating ownership (encode observes);
2. no sender heap address or VM-relative state is in the bytes;
3. the receiver rebuilds it under its own ownership;
4. its type identity is valid in the receiver (canonical names, section 11);
5. the receiver gains no authority (section 14);
6. no foreign code runs, and no suspended computation moves;
7. the source is unchanged.

Sendability is not immutability, thread safety, shallow copyability,
affinity, GC sharing or a persistent format. The mechanism is copying.

## 4. Structural derivation

`hir::types::SendClass TYPE ?ASSUMED? ?SEEN?` (`hir/types.tcl`) returns
`{total|none|unknown WHY}`, Totality's three classes, WHY a reason path in
source terms:

| type | class |
|---|---|
| `unit`, `bool`, `int` (and integer domains: the receiver checks the range), `UnicodeChar`, `Float64`, `DecimalRounded{...}`, raw C floats, C floating types (their carrier), `str` | total |
| `List[T]`, `List[T]{length: N}`, `ImmutableSet[T]`, `MutableVector[T]`, `MutableArray[T]` | T's |
| anonymous struct, transparent named struct, application `Box[A]` | its fields', each with the application's arguments substituted |
| tree struct | its fields' (SEEN: the recursion adds nothing) |
| enum | total (cases are payload-free) |
| opaque struct with a clause | `fields`: its fields'; `through ... as R`: R's (substituted); `bytes`/`mutable_bytes`: total |
| opaque struct without a clause | none: "its owner ... does not declare it sendable" |
| context struct | none (authority) |
| `Fn{...}`, an exact function, a coroutine handle, a C pointer or function pointer, a native view or edit | none |
| a refinement (`refined type`) | none: its proof is this program's; the receiver does not run its predicates |
| `any`, an unconstrained imprint variable, a bare collection kind, a view of another trait | unknown |
| an imprint variable constrained by Sendable, a view of Sendable | total (the guarantee) |

* Generics. An application is judged with its own arguments
  (`AppliedFieldTypes`, `AppliedRepresentation`), so one declaration never
  makes every instantiation sendable: `Box[int]` is, `Box[Fn{...}]` is not.
  The owner's `sendable fields` over a slot is checked once at its
  declaration, slots taken as sendable (ASSUMED), and judged per
  application wherever it is used.
* Recursion. SEEN holds the named struct types being walked: a finite tree
  (`kids: List[Node]`) is sendable exactly when its other fields are. A
  tree with a function field is not, with the path to it.
* Affinity is not sendability. A coroutine handle is affine and not
  sendable; so is a resource (opaque, no clause, and no clause allowed). An
  affine aggregate reaches one of these, so the walk refuses it without
  asking about affinity.

## 5. The owner's statement (opaque structs)

A clause of the struct's own declaration, parsed by
`surface::parser::SendableClause` and validated by
`hir::structs::ValidateSendable` and `ValidateSendableParts`:

| form | meaning | checked |
|---|---|---|
| `sendable fields` | a field-wise copy is the value | every field is sendable whatever the slots are (a field of `any` is refused: the statement would be a marker on a representation the copy cannot rebuild) |
| `sendable through(TO, FROM) as R` | TO projects the value to R; R is copied; FROM rebuilds it in the receiver | R is sendable; TO and FROM are top-level functions of the struct's own module, of exactly the types `(Self) -> R` and `(R) -> Self`, with no declared error, no context requirement, no yield and no flag (`hir::transfer::verifyDeclarations`) |
| `sendable bytes(F)` / `mutable_bytes(F)` | the byte storage of its one field is the value | F is the struct's only field, and the struct is the standard library's (only `std::abi::bytes` makes byte storage) |

* **Only an opaque struct** may state one. A transparent struct's fields are
  its public meaning, so the compiler derives its sendability. A context
  struct and a resource struct may never state one.
* **The standard library's statements:**

  | type | clause |
  |---|---|
  | `Bytes`, `MutableBytes` | `bytes(storage)`, `mutable_bytes(storage)` |
  | `MutableMap[K, V]` | `through(transfer_out, transfer_in) as List[MutableMapEntry[K, V]]` |
  | `MutableSet[T]` | `through(...) as List[T]` |
  | `ImmutableMap[K, V]` | `through(...) as List[ImmutableMapEntry[K, V]]` |

  The owner functions are internal members (`core/transfer.tcl`). Rebuilds
  of forged bytes that name a key twice keep the first place and the last
  value.
* **`Reg`, `Loop`, an actor's `Address`, `Inbox` and `Receiver` state
  nothing**, and so are not sendable (`sd-stdlib-statements`).
* **The trust boundary.** The clause is the owner's statement, not a proof.
  The compiler checks that its parts are portable and its functions
  well-typed and total. It trusts the owner that what the clause names is
  the value's meaning: the trust opacity already places in the owner.
* **Why `through`.** Each of the alternatives fails one of the requirements:
  * A list of content fields copies stored hashes, which another process's
    key invalidates.
  * A generic serialization trait would let any module make any type
    sendable.
  * Compiler-generated per-type code is a second elaboration of every type.

  `through` is two ordinary functions of the owner, called by the codec in
  the middle of its walk. Natively they run through `rt_call_value`, with
  everything the walk holds rooted.

## 6. Diagnostics

| kind | when | `std::compiler::DiagnosticCode` |
|---|---|---|
| NOT-SENDABLE | a transfer's static type is statically not sendable, or does not say | `NotSendable` |
| TRANSFER-OPEN-TYPE | a transfer's type mentions an imprint variable, or decode's is a trait view | `TransferOpenType` |
| SENDABLE-DECLARATION | a malformed or unsound clause | `SendableDeclaration` |
| TRAIT-NOT-SATISFIED | an application of a `satisfies Sendable` slot with a non-sendable argument (the ordinary intrinsic-trait diagnostic) | (existing) |

The message carries the reason path, for example:

```
the argument of std::transfer::encode is not sendable: Batch cannot be reconstructed in another VM
field "jobs" of Batch (List[Job]): its elements (Job): field "run" of Job (Fn{args: [int], return: int, errors: []}): a function or closure is code of this program and the environment it captured: neither is a value another VM can rebuild
```

Inherently non-sendable kinds, opaque structs without a statement,
components and unresolved types (`unknown`, "does not say what its values
are") each have their own wording (`hir::types::NoSending`, `SendStruct`).
Admission is registration metadata, `-sending K|result`
(`core/native.tcl`), checked by `hir::range::VerifySending` inside the
call's own check. A sent argument is read at its own type by the erasure
check (`hir::callables::ArgContexts`), so NOT-SENDABLE is not restated as a
contract erasure. Every kind has a Compilerpedia topic
(`compilerpedia/topics/transfer.topic`) with a rejected example, and is
classified in `tests/static-compile.test`'s census.

## 7. The transfer representation

### The schema

`hir::transfer::Schema TYPE` builds a list of nodes, node 0 the root; nodes
refer to each other by index, so a recursive type is a finite graph. The
node forms are in `hir/transfer.tcl`'s header:

* scalars: `unit`, `bool`, `char`, `float64`, `raw32`, `raw64`, `str`;
  `int DOMAINS`; `decimal FACTS`;
* collections: `list E LENGTH`, `set E`, `vector E`, `array E`;
* `struct ID SLOTS WIRE`, `enum ID CASES`;
* opaque statements: `bytes ID F`, `mutbytes ID F`, `through ID R K`.

**Canonical text.** Fields and cases are sorted, nodes are numbered in the
order a walk in that order meets them, and owner functions are named by
qualified name. The text's 64-bit FNV-1a is the *fingerprint*.

* **Checked, not compared.** An Int's integer domains and a List's stated
  length are left out of the text: a value of `std::byte::Byte` is an Int,
  and the receiver checks the range. A List literal's bytes therefore
  decode as `List[int]`, and an Int's as a `Byte` when it is one
  (`vt-refinements-checked`).
* **Kept.** A DecimalRounded value's facts stay in the text: its guarantee
  is no property the receiver can check.
* **Positional shapes** (a literal's per-position types) are knowledge
  about one value, not type identity, and are never part of a schema.

### The bytes (format version 1)

| part | encoding |
|---|---|
| header | `BOTX`, version byte 1, fingerprint (8 bytes LE) |
| varuint | unsigned LEB128, minimal, at most 10 bytes, below 2^62 |
| unit | nothing |
| bool | one byte, 0 or 1 |
| int | varuint byte count, then the minimal two's complement LE (0 is no bytes); arbitrary size |
| char | varuint scalar value |
| float64 / decimal | the 8 bytes of the binary64 |
| raw32 / raw64 | the 4 / 8 bytes of the bit pattern |
| str | varuint byte count, strict UTF-8 |
| list / set / vector / array | varuint count, elements |
| struct | fields in wire (sorted) order |
| enum | varuint index among the sorted case names |
| bytes / mutbytes | varuint count, the bytes |
| through | the representation's encoding |

The root value ends the bytes. Fixed vectors pin the format
(`vt-bytes-*`); `vt-bytes-agree` compares the hashes of encodings across all
four backends.

### Errors

The five refusals are builtin errors 14 to 18 (`core::native::declareError`;
`native/src/runtime/error.rs`), declared by `std::transfer::decode`:

| error | meaning |
|---|---|
| TransferMalformed | no header; cut short; a count larger than the bytes left; a varuint that is not minimal or too long; bytes after the value |
| TransferVersion | another format version |
| TransferTypeMismatch | another fingerprint |
| TransferInvalidValue | a value outside its type |
| TransferLimit | an Int of more than 2^20 bytes; more than 2^24 elements of no size; a varuint at or above 2^62 |

encode declares no error. The owner projections it may call are total.

## 8. The native codec

* **Lowering** (`native/lower.tcl`'s `TransferPlanConst`, `TransferPlan`).
  The schema constant is resolved at compile time into a *plan*:
  * every struct ID becomes its dense shape number (`ShapeIndex`), every
    enum its enum number and each sorted case its declaration position
    (`EnumIndex`);
  * every node carries its minimum byte size;
  * the result Bytes struct's shape is in the plan.

  Every shape and enum the plan names is declared in the NIR even when the
  program never builds it. The ops are `transferencode` and
  `transferdecode` (`nir.rs`, `codegen/clif.rs`: fallible, allocating,
  safepoints). Parsed plans are cached in the Vm by the constant's address.
  A plan that disagrees with the program's tables is NATIVE BUG: a compiler
  error, never input.
* **Encoding** (`rt_transfer_encode`).
  * The function list, the root and every value still waiting to be written
    stay on `vm.temp_roots`; node indices sit in a parallel Rust vector.
  * A `through` projection runs with its operand rooted in place, and its
    result replaces it.
  * Output goes to a Rust `Vec<u8>`, outside the collector. Only at the end
    is the byte storage allocated, then wrapped in the Bytes struct.
* **Decoding** (`rt_transfer_decode`).
  * The data and the function list are rooted for the whole decode; the
    payload is read in place (objects never move).
  * The values made so far form a stack on `temp_roots`. A composite is
    built while its K parts are still rooted, then replaces them.
  * A rebuild call keeps its argument rooted.
  * Every object is made by the receiving Vm's own constructors: strings,
    BigInts, Lists, structs, sets through the runtime's own set
    construction (`new_set_of`, its equality), vectors (`new_vector_of`),
    arrays, byte storage.
* **Both walks are iterative** (a 100,000-deep tree in the unit tests).
  They use bounded reads and checked arithmetic, and refuse with the
  declared errors.

## 9. The Tcl codec

`core/transfer.tcl` is the reference implementation, shared by `interp` and
`compile` through `-completion` natives.

* Encode is a work stack of {node, value}. Decode is a stack machine of
  instructions (`decode N`, `repeat N COUNT`, `build N K`, `rebuild N`)
  over a value stack. Neither recurses with the value's depth: Tcl's
  recursion limit never applies.
* Values are built by `core::value`'s constructors, ImmutableSets by
  `core::immutableset::Dedup`, vectors and arrays as fresh store entries.
* It writes the same bytes as the native codec: the same fixed vectors on
  every backend, and bytes written by one backend decoded by every other
  (`vt-process-*`).

## 10. Collection semantics

* **Mutable values.** A decoded MutableVector, MutableArray, MutableMap or
  MutableSet is a new value. Mutating it leaves the source unchanged, and
  mutating the source leaves the copy unchanged (`vt-mutable-independent`).
  Encoding a vector straight from its place copies it: the source keeps its
  elements, and a later mutation of the source never reaches the bytes
  (`vt-vector-place`). Two decodes of the same bytes are two values
  (`vt-decode-twice`).
* **Maps and sets** never carry stored hashes, an index or dead entries:
  * the projection is their live entries in their order;
  * the rebuild inserts them under the receiver's own table-hash key.

  Order is observable and preserved, the effect of a removal and of a
  reorder included (`vt-map-order-and-lookup`). An ImmutableMap's copy is
  equal to it, hashes like it, and finds every key through its own index
  (`vt-immutable-map`). Across processes, whose keys differ, every lookup
  of a received map succeeds (`vt-process-*`). The `map-table-copied`
  mutant shows the failure this prevents: sending the table's stored hashes
  fails exactly those lookups.
* **ImmutableSet.** An ImmutableSet is rebuilt by the receiver's set
  construction. Forged bytes naming a member twice decode to the set of one
  (`vt-set-rebuilt`).
* **Shared immutable subgraphs** are reconstructed as separate storage:
  equivalent, never aliased. The cost is linear in the encoding's size
  (section 17).

## 11. Program identity

* **One mechanism for both cases.** The bytes name types by canonical
  identity (module-qualified declaration names, field and case names, the
  owner functions' names) through the fingerprint. They never hold a
  program-relative number. So the same-program case (two VMs of one
  compiled program, M4's) and the cross-program case are the same
  mechanism, and neither needs a program identity.
* **Same declarations, another program.** A value made by one program is
  rebuilt by another compiled independently, with its declarations in
  another order and other structs and enums before them, so with other
  shape and enum numbers (`vt-program-names`; natively,
  `transfer_rich_value_between_independent_vms`).
* **Another layout, another module, another application.**
  * A same-named struct whose layout differs is TransferTypeMismatch
    (`vt-program-layout`, `vt-refuse-same-name-layout`).
  * A struct of the same name in another module is another identity
    (`vt-program-module`).
  * `Box[int]`'s bytes are refused as `Box[str]`
    (`vt-refuse-instantiation`).
* **What a match means.** The fingerprint is a check of intent, not of
  soundness. The decoder validates every value against the receiver's own
  schema, so bytes that forged a fingerprint still decode only into a valid
  value of the receiver's type.
* **Format compatibility.** The format's version is the compiler's. It is
  not a storage format, and no schema evolution is attempted.

## 12. Independent VMs

* **Separate processes** (`tests/value-transfer.test`'s `vt-process-*`).
  * A sender and a receiver each run in a `tclsh` driver process of its
    own; natively, each also has its own `botlish-native` process.
  * The sender's program value is the encoded Bytes, which its driver
    writes to a file and exits. The receiver's program holds the bytes as
    a literal, so it holds nothing else of the sender.
  * Separate processes are separate VMs, heaps and table-hash keys, with
    the sender gone before the receiver decodes.
  * The pairs: interp→compile, compile→interp, interp→cranelift,
    cranelift→interp, cranelift-generic→cranelift,
    cranelift→cranelift-generic. The message is a MutableMap with removals,
    a MutableSet, an enum-bearing tree and a 330-bit Int; the receiver
    looks up all 60 keys, inserts and removes.
* **Two Vms of one process**
  (`transfer_rich_value_between_independent_vms`):
  * the sender's Vm encodes and is dropped, every object with it;
  * a receiver Vm with other shape and enum numbers decodes twice, under GC
    stress with poisoned frees, and collects;
  * mutating one decoded vector or array leaves the other copy unchanged;
  * re-encoding the received value gives the sender's bytes.
* **GC stress.** `vt-gc-stress` runs a map of trees through both native
  backends under `BOTLISH_NATIVE_GC_STRESS=1`; the agent's runs repeated
  the round-trip programs under it.
* **Not covered.** Two VMs of one program *with installed contexts*
  running concurrently: that is M3's acceptance (the process-wide context
  area and guard).

## 13. Actors

* `std::actor` is unchanged: `send`, `deliver` and `receive` carry ordinary
  values of one VM, and nothing requires `Sendable` of them.
* `Address[M]`, `Inbox[M]` and `Receiver[M]` are opaque and state nothing:
  not sendable (`sd-matrix-not-sendable-9`, `-10`; the `address-stated`
  mutant). A remote address is M4's own type.
* `std::actor::recover` is not used. A decoded value's type comes from the
  receiver's schema and validation, never from an unchecked conversion.

## 14. Context authority

* **Contexts are not sendable.** A context struct is installed authority
  (`sd-matrix-not-sendable-6`).
* **No transfer operation requires or installs a context.** encode and
  decode are root natives with no context requirement.
* **Owner functions run without authority.** A projection or rebuild must
  be context-free (SENDABLE-DECLARATION otherwise), so the codec never runs
  code holding authority.
* **A decoded value is data.** The receiver's authority is its own
  installation, as before.
* **VM-relative identities stay non-sendable** (`Reg`, actor addresses, an
  opaque wrapper of any handle), however few Ints they hold.

## 15. Refusals

* **Static.** Every non-sendable row of the matrix
  (`sd-matrix-not-sendable-*`): functions, a struct and a List of structs
  with a function field, a tree with one, a C pointer, a context,
  opaque `Token`, `Reg`, `Address`, `Receiver`, a generic application with
  a function argument, a MutableMap of functions, a List of coroutines, a
  refinement. Also `any` (`sd-any-not-sendable`), decode's type
  (`sd-decode-not-sendable`), open types, malformed clauses
  (`sd-clause-*`, `sd-through-*`).
* **Dynamic.** `vt-refuse-*`, on every backend:
  * truncated header, bad magic, version, fingerprint, another type;
  * truncated payload, trailing byte;
  * Bool byte 2, invalid UTF-8, an encoded surrogate, +Infinity, negative
    zero, enum index 7;
  * non-minimal Int, zero as a one-byte Int, a Byte of 300, a surrogate
    UnicodeChar;
  * an oversized count, a non-minimal varuint, an eleven-byte varuint, a
    List[unit] of 2^25, an Int of 2^20 + 1 bytes;
  * a stated length violated, another application, a same-named struct of
    another layout.

  The native unit tests add 20,000 random mutations of valid encodings,
  each giving a value or a declared error, and refusals at every truncation
  prefix.

## 16. Mutation testing

`audit/value-transfer/tools/mutate.tcl` with `mutants.txt` (29 mutants).
A mutant names its detectors: tests of the two files, or `rust:transfer`.
A Rust mutant rebuilds a private copy of the native backend.

MUTATION-TABLE

## 17. Performance

`bench/value-transfer.tcl` (`-runs 3`, cranelift and compile). Per
operation = (time(K) − time(0)) / K, the value built once outside the loop.
Natively the time is native::measure's best of three in one process,
compilation excluded; allocations are native::allocationReport's
difference for one decode. On the Tcl compiler the program is compiled
once (`core::compiler::compileHir`) and the best of three runs of the unit
is kept. A shared 4-core container: compare rows, never absolutes.

BENCH-TABLE

BENCH-NOTES

## 18. Compatibility

* **Front-end tests.** `tests/sendability.test` (82) and
  `tests/value-transfer.test` (76, all four backends) pass; so do
  `tests/hashable.test` (48), `tests/immutable-map.test` (26),
  `tests/mutable-set.test` (12), `tests/structs.test` (89) and
  `tests/tree-struct.test` (45).
* **The native agent's runs** (the cross-backend scripts aside):
  * `cargo test --lib`: 331 tests; `--bin botlish-native`: 119;
  * `tests/mutable-map.test` (28), `tests/enums.test` (66).
* **Updated enumerations:**
  * `tests/linux-syscall.test`'s qualified-native inventory;
  * `tests/stdlib-namespaces.test`'s builtin errors and root `#` natives.
* **Checks that pass:**
  * Compilerpedia (`tools/compilerpedia.tcl check`, 0 problems);
  * the warning gate (`stdlib/transfer.bot` listed);
  * `tests/static-compile.test`'s census.
* **HIR text and interchange carry the clause:**
  * `hir/format.tcl` prints it on the struct line, `hir/read.tcl` reads it
    (`sd-hir-text-roundtrip`);
  * a program round-trips through `hir::interchange` with its clauses and
    its elaborated transfers, and runs the same.
* **An ordering bug the suites caught.** A collection's `transfer_out`
  loops over the collection, which the loop protocol writes out as calls of
  its `iteration_*` functions. Placed before them, it was a forward
  reference in HIR text (`tree-struct.test`'s `ts-hir-text`). The
  functions now follow the protocol in all three modules.
* **Other updates:**
  * the golden migration census and `tests/golden/manifest.tsv` list the
    157 new Tcl tests;
  * `audit/stdlib-census/after.tsv` is regenerated (it was also stale from
    earlier milestones).
* **Not run locally:**
  * the whole `tests/local.tcl`;
  * the static-decisions comparison (CI's);
  * macOS and Windows, whose workflows run on the branch push. The codec
    is portable Rust; its plan is the target's own NIR.
* **Not rebuilt.** The committed Icy Tower executable
  (`audit/icy-tower/artifacts/icy-tower`), which AGENTS.md asks to rebuild
  with a runtime change. It is self-contained and its game uses neither
  new helper; rebuilding it needs the package-owned SDL3, which this
  container does not have built.

## 19. Next milestones

* **M3 (per-thread runtime state)** is unchanged by this milestone: the
  guard, the context area and `PROGRAM` per VM.
* **M4 (Botlish-owned threads)** sends with this operation:
  * The sender encodes on its thread into a Bytes; the transport moves the
    payload (C memory, as Probe B); the receiver's bridge decodes on its
    own thread, with its own constructors and key.
  * A library's `send` may take a `Sendable` view (`fn send(x: Sendable)`):
    each call site's clone carries its schema.
  * A body generic in an *imprint variable* (`Envelope[T]` with
    `T satisfies Sendable`) cannot transfer yet (TRANSFER-OPEN-TYPE). Two
    ways to remove that:
    * make Sendable constraints select a specialization per binding, as a
      source trait's do (`hir::traits::SelectingBinding`);
    * or pass schemas as hidden arguments.

    The first fits the existing plan.
* **Further work found here:**
  * Physical sharing is not preserved. A value whose logical size is
    exponential in its physical size (a List holding itself twice, nested)
    costs its logical size. Back-references by object identity in the
    native encoder are the concrete optimization, if a workload needs it.
  * encode builds its output in a Rust `Vec<u8>` and then copies it into
    the byte storage: one copy that a sized allocation would avoid.
  * An anonymous struct type has no spelling, so `decode[T]` cannot name an
    error payload's type: a declared struct carries such data.
  * Explicit, authorized transfer of affine native resources (a C
    pointer's ownership) is a separate capability, not `Sendable`.

## 20. Files, and what to run when changing this

**Language and front end**
* `surface/parser.tcl` (`SendableClause`), `surface/lower.tcl`,
  `surface/modules.tcl` (the representation type in `Walk`),
  `surface/ast.tcl`.
* `hir/types.tcl` (`SendClass`, `SendStruct`, `SendComponents`,
  `NoSending`, `IsSendable`, `IsClosedType`).
* `hir/structs.tcl` (`sendableForms`, `ValidateSendable`,
  `ValidateSendableParts`, `sendableOf`, `AppliedRepresentation`).
* `hir/traits.tcl` (the intrinsic `Sendable`), `hir/range.tcl`
  (`VerifySending`), `hir/callables.tcl` (sent arguments' contexts).
* `hir/transfer.tcl` (schema, fingerprint, `verifyDeclarations`,
  `Elaborate`), `hir/hir.tcl` (the pass order), `hir/format.tcl`,
  `hir/read.tcl`, `hir/static.tcl` and `stdlib/compiler.bot` (codes).

**Runtimes**
* `core/native.tcl` (`-sending`), `core/transfer.tcl` (the Tcl codec,
  registrations, builtin errors).
* `native/lower.tcl` (`TransferPlan*`), `native/src/runtime/transfer.rs`,
  `nir.rs`, `codegen/clif.rs`, `runtime/ops.rs`, `runtime/mutvec.rs`,
  `runtime/vm.rs`, `runtime/error.rs`.

**Standard library**
* `stdlib/transfer.bot`, `stdlib/abi/bytes.bot`, `stdlib/mutable_map.bot`,
  `stdlib/mutable_set.bot`, `stdlib/immutable_map.bot`.

**Tests, tools, documentation**
* `tests/sendability.test`, `tests/value-transfer.test`.
* `audit/value-transfer/tools/mutate.tcl` and `mutants.txt`,
  `bench/value-transfer.tcl`.
* `compilerpedia/topics/transfer.topic`, `compilerpedia/notes/stdlib.notes`
  (regenerate `generated/stdlib.topic`), AGENTS.md ("Sendability and the
  cross-VM value transfer").

**What to run.** For a change to any of the above:

```sh
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/sendability.test -tmpdir "$(mktemp -d)"
tclsh9.0 tests/value-transfer.test -tmpdir "$(mktemp -d)"
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/value-transfer.test -tmpdir "$(mktemp -d)"
cargo test --release --manifest-path native/Cargo.toml --lib transfer
tclsh9.0 tools/compilerpedia.tcl check
tclsh9.0 audit/value-transfer/tools/mutate.tcl
tclsh9.0 audit/refactor/tools/gate.tcl        # for a change to stdlib/
tclsh9.0 bench/value-transfer.tcl -backends "cranelift compile"
```

Also run the trait, Hashable and collection harnesses for a change to code
they share. Every mutant in `mutants.txt` must still apply and be killed by
a detector its `!!` line names: update a mutant's text when you change the
code it mutates, keeping it a mutant of the same rule.
