# C-POINTER-BORROWING.md

Minimal C pointer borrowing: the substrate that lets the next milestone call
real Tcl and BoringSSL functions with ordinary Botlish byte storage.

> Existing Botlish byte storage may be exposed temporarily to C as a
> pointer when, and only when, the call contract says the pointer does not
> escape the call. The Linux syscall path's byte-exposure mechanism is
> reused wherever it is general; C semantics are exposed through `std::ffi::c`,
> never through the syscall ABI.

```
existing std::abi::bytes::Bytes / std::abi::bytes::MutableBytes
          |
          | temporary exposure, for one call
          v
shared byte exposure (native/lower.tcl: StorageOf, ExposeStorage,
          |           KeepExposedAlive; ops bytesaddr / mbytesaddr /
          |           keepalive; the non-moving collector)
         / \
        /   \
Linux syscall ABI              C call boundary
std::abi::x86_64::from_bytes,       a foreign call contract per parameter
std::linux::abi::x86_64::syscall            (access read|write, escape noescape|...),
(Register64 words, policy      hir/borrow.tcl's admission, std::ffi::c's
 in stdlib/linux.bot)             vocabulary; the test fixture's operations
```

> Continued by C-FFI.md: `extern c fn` and `extern c library` attach this
> contract to real C functions, call them natively and link them (section
> 14's hook, filled; SHA256's result is now a truthful pointer, declared
> `alias out`, C-FFI.md section 7).

There is no C call yet, and no `extern c fn`. What exists is the contract
the next milestone attaches to a C parameter, the compiler's decision and
transport for it, and a synthetic, test-only foreign call boundary (the
*borrow fixture*) that reads and writes real storage through the exposed
address on the native backend:

```botlish
import std::abi
import std::abi::bytes
import std::ffi::c
import ffi_fixture                 # a test process's own namespace

fn len(data: std::abi::bytes::Bytes) -> std::ffi::c::ULong:
    std::abi::bytes::length(data).value

# SHA256's shape: input read/noescape, output write/noescape, a C count.
fn digest_like(input: std::abi::bytes::Bytes) -> std::abi::bytes::MutableBytes:
    out = std::abi::bytes::zeroed(std::abi::usize(32))
    state = std::ffi::c::null[std::ffi::c::Void]()        # a userdata pointer it may keep
    r = ffi_fixture::mixed(input, state, out, len(input))
    r.output                                    # the bytes C wrote

# Tcl_Eval's shape: a script read/noescape, as Ptr[Char].
fn script_like(script: std::abi::bytes::Bytes) -> List[int]:
    ffi_fixture::read[std::ffi::c::Char](script, len(script))
```

Both run on all four backends; natively `script_like` is

```
func 6 "script_like" params=1 ... pnames="script.0" instance="std::abi::bytes::Bytes"
    %1 = call 4 %0               ; len(script): the count, a separate C scalar
    %2 = op bytesaddr %0         ; the payload address of script's storage
    %3 = op ffifixtureread %2 %1 ; the foreign operation, given THAT address
    %4 = op keepalive %0         ; the storage is live until it has returned
    ret %3
```

-- no copy, no allocation, no pointer value: the exposure is the call's
argument transport and nothing else.

## Contents

* [1. The audit of the Linux syscall byte machinery](#1-the-audit-of-the-linux-syscall-byte-machinery)
* [2. Three categories of foreign pointer](#2-three-categories-of-foreign-pointer)
* [3. The contract](#3-the-contract)
* [4. Admission](#4-admission)
* [5. No pointer value](#5-no-pointer-value)
* [6. Write exposure and MutableBytes' value semantics](#6-write-exposure-and-mutablebytes-value-semantics)
* [7. Transport, per backend](#7-transport-per-backend)
* [8. Storage semantics, per backend](#8-storage-semantics-per-backend)
* [9. Synchronous, failure, liveness](#9-synchronous-failure-liveness)
* [10. The HIR carries the transport](#10-the-hir-carries-the-transport)
* [11. What was reused](#11-what-was-reused)
* [12. direct](#12-direct)
* [13. What a borrow grants](#13-what-a-borrow-grants)
* [14. The extern c fn hook](#14-the-extern-c-fn-hook)
* [15. Retained pointers: the remaining blocker](#15-retained-pointers-the-remaining-blocker)
* [16. The fixture](#16-the-fixture)
* [17. Evidence](#17-evidence)
* [18. Performance](#18-performance)
* [19. Tests, mutants, fuzzing](#19-tests-mutants-fuzzing)
* [20. Regression](#20-regression)
* [21. Not here](#21-not-here)
* [22. What to run when changing this](#22-what-to-run-when-changing-this)
* [23. Files](#23-files)
* [24. Hosts and real C](#24-hosts-and-real-c)

## 1. The audit of the Linux syscall byte machinery

Before anything was designed, the existing path was read end to end
(ABI-BYTES.md, MUTABLE-BYTES.md, LINUX-X86-64-SYSCALL.md, and their code):

| question | what the syscall path does |
|---|---|
| how `Bytes` reaches a pointer argument | `std::abi::x86_64::from_bytes(data)` (a root native, hir/syscall.tcl's `BytesProblems` holds its argument to `std::abi::bytes::Bytes`) lowers to `StorageOf` (the opaque struct's one `storage` field: a virtual field register, else `structget`) and `op bytesaddr %s` (`rt_bytes_addr`: object + 16, as a small Int). The word is a `Register64`'s; `std::linux::abi::x86_64::syscall` unboxes it (`register_word`) into rsi |
| how writable storage reaches a writing syscall | the same with `from_mutable_bytes` and `op mbytesaddr` (`rt_mbytes_addr`), the writable kind's op: the two ops are two run-time kind checks, never interchanged |
| pinned, stable, copied? | stable: the collector never moves an object, so an address is valid exactly while its storage is live. Nothing is pinned or copied by the bridge |
| what keeps it alive | `fn keepAddr` (address register -> storages) and `op keepalive %s` after the syscall (`SyscallCall`), also after a call that takes an address-carrying operand (`AddressFlowAcrossCall`); the keepalive is a use of the storage in NIR, so the root plan keeps the storage a root in the stack map of every safepoint up to the syscall's own (it was a call of the helper `rt_keepalive` until C-FFI-ERROR-CAPTURE-MILESTONE-1.md made it no machine code) |
| a Botlish Ptr-like value? | no: the address is a `Register64` word (an Int). It *can* leave the function (returned, stored), which is the raw layer's documented sharp edge; provenance is tracked through structs, Lists, `if` joins and calls, not through module statics or closures |
| HIR/NIR representation | HIR: an ordinary call of the bridge native, an ordinary `struct` literal for the registers; NIR: `bytesaddr`/`mbytesaddr`, `syscall_linux_x86_64`, `keepalive` |
| read vs write distinguished? | by the owner type (two bridges, two ops); the syscall itself does not know which register points at what |
| mutable storage afterwards | the raw bridge does **not** detach (a raw program writing through a shared storage writes through all its aliases: pinned by a test). `std::linux::read`, the safe wrapper, detaches first (`std::abi::bytes::detach`, `rt_mbytes_clone`), lets the kernel write the private copy, and returns it in `ReadResult.data`: MutableBytes is a value, "published storage is never written" |
| native and Tcl backends | native: the above. Tcl: `NATIVE-ONLY` (no addresses; nothing imitates one) |
| generic | storage projection (`StorageOf`), the two address ops, the non-moving liveness rule, `keepalive` after the consumer, the detach-then-expose discipline for writes |
| Linux-syscall policy | `Register64` as the carrier, the register-struct contract (hir/syscall.tcl), the syscall op and its asm boundary, `stdlib/linux.bot`'s choice of registers and numbers |

`direct` was audited too: **it does not exist** anywhere in the compiler,
the runtime or the libraries. It is a planned policy named in four places
(ABI-BYTES.md, MUTABLE-BYTES.md, CONTEXTS.md item 59: "a policy layer that
lets application code prefer contextual APIs and restricts raw operations
to designated modules"), with no syntax, effect, check or fact behind it.
Section 12 says what this milestone adds for it instead.

## 2. Three categories of foreign pointer

| | what | lifetime | here |
|---|---|---|---|
| 1. an ordinary `std::ffi::c::Ptr[T]` | an independently usable raw foreign pointer (C-ABI-TYPES.md): affine, explicitly cloneable, nullable | unknown: nothing about ownership or lifetime | unchanged; passed to any pointer parameter as a raw pointer |
| 2. temporary Botlish-storage exposure | existing `Bytes` / `MutableBytes` storage, its address handed to **one** call whose parameter contract says noescape | exactly that call: no pointer value exists before or after | **this milestone** |
| 3. stable foreign/native storage | memory C may keep a pointer to after the call returns | as long as C holds it: needs an owner-backed resource | **not implemented**: section 15 |

The distinction matters more than any syntax: category 2 is not a weaker
category 1 (it never becomes a value), and it is not a first step toward
category 3 (it can never serve a pointer-retaining API).

## 3. The contract

A foreign call contract (`core/native.tcl`'s `-foreign`, normalized by
`core::cabi::NormalizeForeign`) is a C signature whose pointer parameters
carry two facts:

```
{vars {T...} params {P...} result R}
P = {name N type T}                                 a C value (a scalar)
  | {name N type T access A escape E}                a C pointer (Ptr or FnPtr)
A = read | write | unknown        what C may do through it during the call
E = proven-noescape | declared-noescape | captures | unknown
                                  whether C may keep pointer provenance
```

* **`const` and noescape are different facts.** `access read` is C const: C
  may not modify through the pointer. `escape` says whether C may retain the
  pointer. Neither implies the other: a `const char *` may be stored (Tcl's
  `Tcl_SetResult` of a static string, BoringSSL's `BIO_new_mem_buf`); a
  writable pointer may be perfectly safe to expose for one synchronous call
  (`SHA256`'s output). The fixture has `read_retained`, a read parameter
  that captures: it refuses byte storage (`cb-refuse-const-is-not-noescape`;
  mutant `const-implies-noescape`).
* **Unknown means retaining.** A pointer parameter with no escape fact is
  `unknown`, and `unknown` never admits a temporary exposure
  (`cb-refuse-unknown-escape`; mutant `unknown-implies-noescape`). The same
  for an absent access: `unknown` (`read_unknown_access`).
* **Evidence is recorded, semantics are one.** `proven-noescape` (a tool
  showed it from C source: the header archaeology's toolchain, an LLVM
  `nocapture`) and `declared-noescape` (the binding's author stated it) are
  the same fact for borrowing (`cb-read-evidence-equivalent`; mutant
  `evidence-changes-semantics`). The compiler needs only the trusted
  contract; how a binding author obtained it is not its business, and no
  capture analysis of C exists in the compiler.
* **No heuristics.** Nothing reads a fact from a C type (`const char *`,
  `void const *`), a `const`, a parameter name (`data`, `buf`, `input`), a
  function name or a namespace: the contract says it, or it is unknown.
  `hir/borrow.tcl` reads only the contract's facts and the argument's static
  type; the C type's pointee width comes from its registry metadata
  (`core::type::cabiScalar`), never from a name.
* **Per pointer parameter.** The facts are a parameter's, never a
  function's: `mixed(input: read noescape, state: captures, output: write
  noescape, count)` exposes `input` and `output` and refuses byte storage
  for `state` (`cb-mixed-parameters`).
* **The contract is the signature.** A `-foreign` native's static parameter
  and result types are the contract's (its imprint signature, when it has
  variables, is derived from it; a separate `-imprint` is refused), and its
  arguments are held to them by the one admissibility proof
  (`hir::range::ProvesValueAcceptedBy`): a raw pointer by its exact pointer
  type, a C scalar by its range.

## 4. Admission

`hir::borrow::Decide` decides each argument at a data pointer parameter
whose static type is a *byte owner*:

| argument | parameter | transport |
|---|---|---|
| `std::abi::bytes::Bytes` | read, noescape, byte pointee | **read**: its storage, exposed as it is |
| `std::abi::bytes::MutableBytes` | read, noescape, byte pointee | **read**: its storage, exposed as it is (no copy) |
| `std::abi::bytes::MutableBytes` | write, noescape, byte pointee | **write**: a private copy, exposed writable; the call returns it |
| an `std::ffi::c::Ptr[P]` of the parameter's type | any | a raw pointer (no exposure, nothing about lifetime) |
| anything else | | the ordinary TYPE mismatch |

A byte pointee is `std::ffi::c::Char`, `std::ffi::c::SChar`, `std::ffi::c::UChar` (a C
integer scalar whose metadata says 8 bits) or `std::ffi::c::Void`. A byte owner
the parameter refuses is `FOREIGN-BORROW`, a new diagnostic kind
(`std::compiler::DiagnosticCode::ForeignBorrow`, recoverable in `static
compile:`), with one reason, the first of:

1. the parameter may retain the pointer (escape `captures` or `unknown`) --
   the central rule;
2. its access is `unknown`;
3. an immutable `Bytes` where C may write (`access write`: a semantic rule,
   whatever memory the storage happens to be in);
4. its pointee is not byte-sized: `Ptr[Int]`, `Ptr[Short]`, `Ptr[Long]`,
   `Ptr[ULongLong]`, `Ptr[Ptr[UChar]]`, a pointer to an opaque struct. Byte
   storage promises byte alignment only and no element layout; typed views
   are later work.

```
argument 1 of ffi_fixture::read_retained: byte storage (std::abi::bytes::Bytes) is
exposed to C only for a call that cannot keep the pointer, but parameter
"data" may retain it (escape captures): a pointer C keeps after the call needs
storage that outlives the call, which nothing provides yet, and only a
contract that says noescape -- never a const, a name or a guess -- admits
temporary exposure
```

A byte owner establishes no pointee imprint (it is not a pointer): the
pointee comes from an explicit imprint, `read[std::ffi::c::Char](data, n)`, or
from a raw pointer argument (`cb-imprint-owner-establishes-nothing`).

**Offsets.** None: an exposure is the start of the owner's storage. A
standalone sub-buffer is an ordinary value (`std::abi::bytes::freeze_prefix`)
and is exposed like any other; no slice, offset or arithmetic exists.

**Length.** None is added. The count is a separate argument, a C integer
scalar admitted by its proven range (`len(data)` above is
`std::abi::bytes::length(data).value`, an `std::abi::Usize`'s Int, which fits
`std::ffi::c::ULong` on LP64; on windows-x86_64, where `unsigned long` is 32 bits,
it needs a check: `cb-length-separate`). The exposure carries no bounds into
C: the caller passes the right count to a function whose contract respects
it (`cb-read-prefix`).

**NUL termination, encoding, Strings.** None: the exposure is the bytes, no
terminator is added and none is promised. A Tcl script ends with an
explicit `0` byte its builder put there (`script_like` above); a `String` is
never exposed (`std::str::encode_utf8` then `std::abi::bytes::from_list` makes the
bytes explicit).

## 5. No pointer value

The exposure exists only as one call's argument transport, so there is no
value of it to bind, store, return, capture, clone, erase or retype --
nothing to forbid one operation at a time. What a program could try instead
is a byte owner where a pointer value is expected, and every such path is a
compile-time error (`cb-no-pointer-value`):

| attempt | outcome |
|---|---|
| `keep(data)` with `fn keep(p: std::ffi::c::Ptr[std::ffi::c::UChar])` | TYPE, with the clause "byte storage is never a pointer value: ... exposed to C only as the argument of a foreign call whose parameter's contract admits it" |
| `fn leak(d: Bytes) -> std::ffi::c::Ptr[UChar]: d` | TYPE (the result does not prove its type) |
| a struct field or a `List[Ptr[UChar]]` element | TYPE |
| `std::ffi::c::clone(data)`, `std::ffi::c::null?(data)` | TYPE at compile time (hir::borrow's `VerifyPointerKinds`: a byte owner where a native's run-time kind is `cptr`; before this milestone a run-time TYPE) |
| `std::ffi::c::erase(data)`, `std::ffi::c::retype[T](data)` | IMPRINT / TYPE (their imprinted `Ptr` types) |
| `f = ffi_fixture::copy` (a foreign operation as a value) | TYPE (IMPRINT for an imprinted one): a call through a value would have no contract |

And the registry pins that no operation makes a pointer of anything but a
pointer or an Int (the test fixture's `address[T](n)`):
`cb-no-pointer-producing-native` checks every native whose result is a C
address. So the negative success criterion holds: **there is no way for
ordinary Botlish code to obtain and retain a C pointer into Botlish-owned
byte storage.**

## 6. Write exposure and MutableBytes' value semantics

`std::abi::bytes::MutableBytes` is a *value* (MUTABLE-BYTES.md: "mutable storage
does not imply reference semantics"; no update ever writes storage another
value can observe). A foreign write therefore cannot change the caller's own
binding -- Botlish has no assignment and MutableBytes has no header to
mutate in place (MutableVector's places do; MutableBytes predates them). The
existing syscall machinery already answers how a foreign write reaches a
value: `std::linux::read` detaches, lets the kernel write the private copy, and
returns it. A write exposure does exactly that, generally:

* the argument's storage is copied (the detach, `op mbytesclone`), the copy
  is exposed writable, C writes it;
* the call returns the copy as the parameter's updated value: a call with a
  write exposure evaluates to the anonymous struct

  ```
  {result: R, NAME: std::abi::bytes::MutableBytes, ...}
  ```

  R the contract's C result, NAME each written parameter's name (the write
  parameter's name is never `result`; fields sorted, as every anonymous
  struct's are); a call without one evaluates to R;
* the caller's value, and every copy of it, is unchanged
  (`cb-write-value-semantics`), and usable again at once
  (`cb-write-owner-usable-again`).

This is the one place where the brief's wording ("the original MutableBytes
sees the writes afterward") is not what the current type allows: the
original cannot see anything, because it is a value; the *result* is the
MutableBytes with C's writes visible, an ordinary MutableBytes the program
reads normally. Making the caller's binding itself change would need
MutableBytes to become a place-mutated header value like MutableVector -- a
redesign of MUTABLE-BYTES.md this milestone does not make. If that happens,
only *where the private copy goes* changes; the transport (copy, expose,
keepalive) stays.

* **Exclusivity** is by construction: the exposed storage is private to the
  call (nothing else can name it before the call returns), so no Botlish
  path can read, write or move it meanwhile, whatever else the program does
  -- even the same owner exposed for reading in the same call
  (`cb-read-write-one-owner`: `copy(m, m, n)`, C reads `m`'s storage and
  writes its own copy). Nothing else is needed: no lock, no borrow state,
  no affinity.
* **Write includes read.** C sees the owner's current bytes in the copy
  (nothing in a MutableBytes is uninitialized), so a partial write keeps
  the untouched suffix (`cb-write-sees-current-bytes`): `write` is
  read-and-modify, and no third mode (`inout`) is needed. Two modes, read and
  write, is what real current use requires.
* **Copy cost**, measured (section 18): one fresh storage of the owner's
  length and one copy of its bytes per write exposure, beside one small
  object, the copy's MutableBytes, when the updated buffer is read whole;
  the write-back struct is never built when its fields are read
  (C-FFI-ERROR-CAPTURE-MILESTONE-1.md; it was built at every call, with the
  MutableBytes, before). A fresh owner
  (`std::abi::bytes::zeroed(...)` written inline) is copied all the same, as
  `std::linux::read` copies a fresh buffer: eliding it needs uniqueness or
  deadness facts the compiler does not have (MUTABLE-BYTES.md, "How
  copy-on-write would fit").

## 7. Transport, per backend

**Native** (`native/lower.tcl`'s `BorrowCall`, reached for every call whose
HIR node has `borrows`):

1. every argument is evaluated, in written order -- an exposed one only to
   its owner's storage register (`StorageOf`: a virtual field register, or
   `structget` of the object);
2. then the exposures are made, after **every** argument: each write
   exposure's private copy (`op mbytesclone`, the only allocation), then
   every address (`ExposeStorage`: `op bytesaddr` for an immutable storage,
   `op mbytesaddr` for a writable one -- by the storage's kind, so a
   MutableBytes read exposure also uses `mbytesaddr`);
3. the operation, given the addresses (here the fixture's `op ffifixture*`;
   the next milestone's C call);
4. `KeepExposedAlive`: `op keepalive` of every exposed storage -- a use
   of it in NIR, no machine code (the root plan's liveness is what keeps the
   storage a root through the operation's safepoint);
5. with a write exposure, the write-back value: as fields where escape
   analysis made it a virtual value -- the C result's register and, for
   each written parameter, the copy's storage register (its MutableBytes
   opened) -- built only where a use needs an object (below); as the
   struct (`structnew` of the copy's MutableBytes, then of the anonymous
   struct) only where the value must be one at the call, and not at all
   when the call is a statement.

**The write-back value** (C-FFI-ERROR-CAPTURE-MILESTONE-1.md). Nothing is
built between the operation and the code that reads its result: escape
analysis recognizes the call as a construction of its anonymous struct
(`hir::escape::WriteBackResult`, like a struct literal or a syscall's
Register64), and the representation class it reaches opens each
MutableBytes field (`WriteBackTree`) -- also where a use reads it whole
(`r.buf`), as long as that use runs as often as the binding (the same
innermost loop; a parameter's never): the MutableBytes is built there, at
the use, once per scope (`native::lower::OpenedFieldObject`). An exposed
`r.buf` handed to another foreign call is read for its storage alone
(`OpenedOwnerStorage`). So a C function that fails with a sentinel and
leaves its reason in errno has its errno read before anything allocates or
calls the runtime: read(2) through `std::darwin::read` is `foreigncall`,
`keepalive`, the comparison, `call errno` (`di-errno-read-first`,
`tests/c-ffi-error-capture.test`).

Since C-FFI-ERROR-CAPTURE-MILESTONE-2.md that holds whatever escape analysis
decides and whatever the optimization flags: the write-back value's
transport is a correctness rule of native lowering ("Foreign-result
transport"), not part of struct scalar replacement. A write-back value the
analysis leaves alone -- `-struct-opt 0`, a binding a closure captures, an
`if` of two calls with scalar replacement off -- is held as fields all the
same (`MandatoryWriteBack`); a MutableBytes its representation keeps closed
(a use in a deeper loop, a parameter's) is a pending object, built at its
first use that needs it, never at the call (a loop's at the loop's entry,
`HoistDeferredUses`); and the C result, when it is a 64-bit integer, is the
word C returned (`cwlt` against the sentinel: read(2)'s `ssize_t` is
`foreigncall`, `keepalive`, `cwlt`, `call errno`). `cb-write-back-
allocations` counts the same objects with `-struct-opt 0` as without, but
for `std::abi::bytes::mutable_length`'s own `std::abi::Usize`, an ordinary struct.

The address is a tagged small Int (`bytesaddr`'s result: what the syscall
path's register words are too), never a `cptr` word: "Bytes -> backing
storage address -> raw machine pointer argument", the unboxing being the
call helper's -- `rt_ffi_fixture_*` untags it into a `*const u8`, as
`rt_linux_x86_64_syscall` untags a register word. No `std::ffi::c::Ptr` is ever
constructed for an exposure, not even internally.

**Escape analysis** (`hir/escape.tcl`): an exposed argument is read only for
its storage field, like the address bridge's argument (`wordUse`), so a
Bytes or MutableBytes held in a binding stays scalar-replaced: no wrapper
object is built for the call (mutant `owner-built-for-exposure`; an owner
written *inline* as the argument is built first, the bridge's existing
`StorageOf` frontier).

**Tcl backends** (`core::cabi::ForeignBoundary`, the entry of every
`-foreign` native's implementation): there are no machine addresses, so an
exposure is `{exposure ID}`, a handle into the call's own table of exposed
bytes (the owner's hex), which the implementation reads
(`core::cabi::ExposedBytes`) and, for a write exposure only, writes
(`StoreExposed`; a write through a read exposure is an internal error -- C
writing through a const pointer, ruled out by the contract and seen here).
After the call the table entry is gone: a handle the operation kept past the
call reaches nothing (`cb-tcl-exposure-ends`). A write exposure's bytes after
a normal return become the write-back value. A raw C address reaches no
memory on the Tcl backends: a zero-byte access works, any other is
`NATIVE-ONLY`. Nothing fabricates an address. The next milestone's
interpreter-to-C bridge replaces exactly this model (a copy into a C buffer
for the call, a copy back for a write).

## 8. Storage semantics, per backend

| | native (cranelift, cranelift-generic, executables) | Tcl backends (interp, compile) |
|---|---|---|
| **Bytes** stable how? | the collector never moves objects: the payload address (object + 16) is valid while the storage is live | no address: the exposure is the storage's hex, a Tcl value, in the call's exposure table |
| copied? | no | no (an immutable Tcl value is shared) |
| owner keepalive | `op keepalive %storage` after the operation: a GC root in the stack map of every safepoint up to and including the operation's own | the argument value is held by the call's frame; the table entry is closed when the call ends |
| **MutableBytes, read** | its own storage, exposed as it is (`mbytesaddr`), no copy, kept alive the same way | its hex, no copy |
| **MutableBytes, write** stable how? | a private copy (`rt_mbytes_clone`: a fresh `16 + n`-byte object), non-moving, kept alive by the keepalive (and afterwards by the write-back value's field register, or its object, while the result is used) | the exposure's own hex, rewritten by `StoreExposed` |
| copied? | yes: the detach, one copy of n bytes | the hex is a copy by nature (Tcl values are immutable) |
| copy back? | none: the copy C wrote *is* the result's MutableBytes (no second copy) | none: the final hex becomes the result's `{mutbytes HEX}` |
| exclusivity | by construction: the copy is private to the call | likewise: the exposure entry belongs to the call |
| failure | the copy is unreachable and collected; the caller's value never changed | the entry is closed; nothing is published |

## 9. Synchronous, failure, liveness

**Synchronous.** An exposure is made after all of its call's arguments are
evaluated (step 2 above) and ends when the operation returns: no argument's
code -- a call, an allocation, a coroutine `yield` -- comes between them
(`cb-exposure-after-arguments`: an argument that yields deep inside a
coroutine, then the resumed call, on every backend;
`cb-exposure-after-arguments-nir` pins the order; mutant
`borrow-allowed-across-yield`). There is no `defer`, no thread handoff, no
promise and no event loop in Botlish, and the operation itself is one
synchronous call, so nothing can hold an exposure across a suspension. The
foreign operation is a GC safepoint (a foreign call may run Botlish code:
later, callbacks), which is exactly why the keepalive matters.

**Failure.** An operation that fails -- here `fill_checked`, which writes
part of its output and then fails with the declared `UpperOverrun` -- ends
its exposures like a normal return: the handler runs, the partial writes
went to the private copy and are discarded with it, and the caller's value
never changed (`cb-failure-publishes-nothing`, also under GC stress). This
is the natural behavior of the syscall path's detach; no rollback exists
because none is needed. On success the writes are the result.

**Liveness.** The owner must stay live while C uses its storage, even when
nothing else references it and even though the storage never moves. The
test makes that observable: `read_reentrant` stands for foreign code that
runs Botlish code mid-call -- it forces a collection and allocates
storages of the exposed size, filled with `0xee`, until one reuses the
exposed block (at most 256: which free block malloc returns first is not
predictable, and four were enough on one build only), before it reads. A
storage only the exposure references survives it and is read intact
(`cb-liveness-reentrant`, with and without `BOTLISH_NATIVE_GC_STRESS=1`);
the same program with the keepalive deleted from its NIR reads `238, 238,
...` -- the canary in the reclaimed block (`cb-liveness-mutant-detected`;
mutant `owner-liveness-dropped`). No GC stress is needed to see it, so the
theorem is pinned in every run.

## 10. The HIR carries the transport

* **`borrows`** on a call node: `{INDEX ACCESS NAME}` per exposed argument
  (`{{0 read input} {2 write output}}` for `mixed`), recorded by the call's
  typing (`hir::types::Call` -> `hir::borrow::Type`), which also gives the
  call its type (R or the write-back struct). Every backend lowers the call
  from this field and the call's static type alone: native lowering never
  consults the contract or a name to lower a call
  (`cb-native-lowering-reads-the-node`), and the Tcl boundary decides by the
  run-time value and the contract it is registered with -- the same
  decision for a checked program.
* **Interchange** (HIR-INTERCHANGE.md) is the HIR dict, so it carries
  `borrows`: written, read back after another compilation, the HIR lowers to
  the identical NIR and runs identically (`cb-interchange`). The backend
  needs no header, archaeology IR, C compiler or name knowledge. (HIR *text*
  cannot round-trip a program that imports modules at all -- a pre-existing
  limit of `hir::read`, unrelated to this.)
* **Compilation isolation.** No registry was added: a native's contract is
  front-end state registered with the native (fixed per process, like every
  `-ownership` role), and a call's decision lives on its own HIR node. A
  future `extern c fn`'s contract will be a program declaration, carried by
  the HIR that declares it (section 14); "SHA256 argument 1 is noescape" is
  never process-global.
* **Unchecked programs** (`-strict 0`). A refused exposure also marks its
  call (`borrowRefused`), and every backend evaluates the arguments and
  then raises the refusal (TYPE, the diagnostic's message) instead of the
  call (`cb-strict0-replay`, identical on all four): no backend ever exposes
  storage to a parameter that refused it. (`hir::lower` lowers it to the
  internal native `foreign#refused`, the Tcl compiler and native lowering
  emit the error themselves; the precedent is lockstep loops' `unproven`.)

## 11. What was reused

| | |
|---|---|
| **existed** | the byte storages (`KIND_BYTES`/`KIND_MUTBYTES`, one allocation, payload at +16, non-moving), `StorageOf`, the ops `bytesaddr`/`mbytesaddr`/`keepalive`/`mbytesclone` and their runtime helpers, `keepAddr` provenance, `SyscallCall`'s keepalive loop, the detach-then-expose discipline of `std::linux::read`, escape analysis's one-field `wordUse` |
| **reused unchanged** | the storage objects and their helpers (`rt_bytes_addr`, `rt_mbytes_addr`, `rt_mbytes_clone`, `rt_keepalive`), `StorageOf`, the non-moving liveness rule, `keepAddr`; the C ABI types (`Ptr[T]`, the scalars, imprinting) |
| **generalized** | the address op choice and its provenance record became `ExposeStorage`, and the keepalive loop `KeepExposedAlive` (native/lower.tcl): the syscall bridge (`BytesAddrCall`), the syscall (`SyscallCall`), a call that may make one (`AddressFlowAcrossCall`) and the foreign call (`BorrowCall`) are their four callers, and no other code emits an address op or a keepalive (`cb-shared-mechanism`); `wordUse` gained exposed arguments; `hir::imprint::Bind` skips an argument type `""` (a byte owner establishes nothing) |
| **syscall-specific, unchanged** | `std::abi::x86_64::from_bytes`/`from_mutable_bytes` and their `Register64` result, `std::linux::abi::x86_64::syscall`, hir/syscall.tcl, `SyscallCall`'s register assembly, `stdlib/linux.bot`. Their NIR is unchanged: `std::linux::write` is one `bytesaddr`, one syscall and one `keepalive` of the same storage, `std::linux::read` one detach, one `mbytesaddr`, one syscall and one `keepalive` of the detached storage, with no new copy or allocation (`cb-syscall-nir-unchanged`, against the NIR ABI-BYTES.md and MUTABLE-BYTES.md show) -- and the whole `-emit-nir` output of `examples/linux/write.bot`, `read-stdin.bot` and `context-hello.bot` is byte-identical before and after this milestone; `abi-bytes`, `abi-mutable-bytes` and `linux-syscall` pass unchanged |
| **C-specific, added** | the contract vocabulary and its normalization (`core/cabi.tcl`), `-foreign` (`core/native.tcl`), the admission and the write-back type (`hir/borrow.tcl`), `FOREIGN-BORROW`, `BorrowCall`, the Tcl exposure model (`ForeignBoundary`), the `foreign#refused` replay, the fixture and its runtime (`runtime/ffifixture.rs`, six NIR ops) |

**Namespaces stay apart** (`cb-namespace-separation`): no syscall wrapper
mentions `std::ffi::c`, and no C-side code (`stdlib/ffi/c.bot`, `hir/borrow.tcl`,
`core/cabi.tcl`, the fixture runtime) names a Linux, syscall, register or
x86-64 identifier; a borrow program imports neither `linux` nor
`std::abi::x86_64` and calls no syscall native, and a syscall program's calls
carry no exposures. The shared internals are named for what they are
(storage, address, exposure, keepalive), never `linux` or `syscall`; the
C ABI is not a pretend syscall ABI, and the syscall ABI does not depend on
C (mutant `c-borrowing-uses-syscall-namespace`).

## 12. direct

(Since DIRECT-MODULES.md, `direct` exists, module-granular: `direct
module`, the intrinsic metadata of the syscall transports and mediation by
module-owned contexts. Its section 9 names where the retaining facts below attach.)

`direct` does not exist yet (section 1), so there was no machinery to
reuse, and none was invented: no second unsafety concept, no C-specific
effect. What the next milestone needs from this one is the fact it will
derive `direct` from, and that fact is per parameter and recorded:

* **The hook:** `core::cabi::RetainingParameters CONTRACT` and, for a call,
  `hir::borrow::retaining HIR E`: the pointer parameters whose escape is
  `captures` or `unknown`, as `{INDEX NAME ESCAPE}` (`cb-direct-hook`).
  `mixed`'s is `{1 state captures}`; `read`'s and `fill`'s are empty.
* **The rule to attach:** a raw foreign call that may retain pointer
  authority beyond the lexical call is `direct` -- a non-empty
  `retaining` list. That covers a stored data pointer, a stored userdata
  (`Ptr[Void]` captured), a stored callback (a `FnPtr` parameter's escape
  is the same fact: a function pointer parameter that captures is retained
  authority) and authority handed to another thread (the contract says
  `captures`), and an unknown one (no fact is `unknown`, which retains).
* **Per parameter, then per call.** The borrowing facts stay parameter-local
  (exposure is decided per argument); `direct` may be the operation's
  (`mixed` is direct because of `state`, though `input` and `output` are
  exposed for the call).
* **Foreign is not direct.** A synchronous call whose pointer parameters
  are all noescape -- `SHA256`, `Tcl_Eval` with its contract -- need not be
  `direct`: what makes a raw call capability-escaping is exported
  authority, not being foreign. Temporary byte exposure is the
  capability-safe path for synchronous C operations.
* **The narrow deficiency:** `direct` itself -- its syntax, which code may
  call a direct operation, how a wrapper removes the burden by owning the
  lifetime -- is the next milestone's (or a policy milestone's) to build.
  Nothing here needs it: a retaining parameter already refuses exposure,
  so the borrow rule does not depend on `direct`.

## 13. What a borrow grants

* A **read exposure** grants C read authority over this byte region, for
  this call. A **write exposure** grants read and write authority over a
  private copy of it, for this call. Neither grants authority after the
  call: the contract promises C does not retain pointer provenance, and
  Botlish keeps its side -- no pointer value exists, the storage is kept
  live exactly for the call, and a write cannot reach any other value.
* A **capturing** call is different in kind: it exports continuing
  authority, which is why it never consumes a temporary exposure.
* **A false contract.** Botlish cannot stop native code from storing a
  pointer it promised not to keep, or writing through a pointer it promised
  only to read. A false noescape (or access) declaration is like any false
  FFI ABI contract: foreign code can corrupt memory or crash the process
  (on the Tcl backends the model can see a kept handle or a const write and
  stops it; natively it is undefined). The contract's value is that wrapper
  authors can verify it, compiler tooling can sometimes prove it
  (`proven-noescape`), Botlish enforces its own side once it is trusted, and
  ordinary application code carries no raw lifetime machinery. No stronger
  isolation is claimed than a native-process FFI can provide.

## 14. The extern c fn hook

The next milestone attaches, per parameter of an `extern c fn`
declaration, exactly the contract entry a `-foreign` native has today --
whatever its source syntax becomes:

```
extern C parameter metadata:
    name                 the parameter's name (the write-back field)
    type                 the C type: a scalar, std::ffi::c::Ptr[T], std::ffi::c::FnPtr[F]
    access               read | write | unknown          (data pointers)
    escape               proven-noescape | declared-noescape | captures | unknown
result:                  the C result type, or unit
```

and gets, unchanged: the admission (`hir::borrow::Decide`), the call's type
(R, or `{result: R, NAME: MutableBytes}`), the recorded transport
(`borrows`), the lowering up to the operation (`BorrowCall`: the C call's
lowering replaces `op ffifixture*`), the keepalives, the write-back, the
`-strict 0` replay, the `direct` hook. `hir::borrow::Contract` is the one
place that finds a call's contract (a native's registry entry today; the
declaration's HIR node then). What the C-call lowering adds is the ABI:
the tagged address word unboxed into a register, the scalars by their
metadata's width and signedness (C-ABI-TYPES.md, "Remaining blockers").

The three immediate consumers:

```
Tcl_Eval(Tcl_Interp *interp, const char *script) -> int
    interp   Ptr[Tcl_Interp]   escape as the binding author      (a raw pointer: the
                               states it                         interpreter object itself,
                                                                 unrelated to byte borrowing;
                                                                 its escape fact decides only
                                                                 whether the call is direct)
    script   Ptr[Char]         access read   escape declared-noescape
                                                                 (Tcl_Eval copies the script
                                                                 into its own objects: the
                                                                 wrapper author states it)
    result   Int
  call:  r = Tcl_Eval(interp, script_bytes)        script_bytes: Bytes with a trailing 0

SHA256(const uint8_t *data, size_t len, uint8_t out[32]) -> uint8_t *
    data     Ptr[UChar]        access read   escape declared-noescape
    len      ULong             (size_t on LP64; the generator's alias)
    out      Ptr[UChar]        access write  escape declared-noescape
    result   unit              (SHA256 returns OUT: declaring it a Ptr would
                                hand Botlish a pointer derived from an exposure --
                                exactly what noescape rules out -- so the binding
                                declares the result void and C's rax is ignored)
  call:  r = SHA256(input, len(input), std::abi::bytes::zeroed(std::abi::usize(32)))
         digest = std::abi::bytes::freeze(r.out)
```

Two policy examples, illustrative only (no name is known to the compiler):

* **`BIO_new_mem_buf(const void *buf, ossl_ssize_t len)`**: `buf` is read
  (const) but retained by the BIO it returns: `escape captures` -- not
  eligible merely because it is const; the raw call is `direct`, and stable
  storage is required (section 15).
* **Callback registration** (`Tcl_CreateObjCommand(interp, name, proc,
  clientData, deleteProc)`): `proc`, `clientData` and `deleteProc` are
  retained: `escape captures` for each; `direct`; the natural candidate for
  a context wrapper.

## 15. Retained pointers: the remaining blocker

APIs that retain caller memory still need a future owner-backed
stable-storage resource mechanism. That is not unfinished borrowing: it is a
different abstraction (category 3 of section 2), with a lifetime longer
than any call, an owner that outlives the foreign holder, and release
ordered against the foreign side's destruction. Temporary noescape exposure
is for now; stable retained native memory is later.

**Contexts are the natural wrapper boundary** for it (CONTEXTS.md):

```
raw C API:  create object, install callback, store userdata,
            retain buffer, destroy object
        |  wrapped by
Botlish context:  owns the continuing C relationship, keeps backing
                  resources alive, controls registration /
                  unregistration / destruction order
        |  exposes
ordinary capability-safe Botlish API
```

None of that is implemented: no ownership policy is encoded into
`std::ffi::c::Ptr[T]`, and borrowing knows nothing of C objects.

## 16. The fixture

`core::cabi::installBorrowFixture` (a test process calls it; nothing in the
compiler, the libraries or main.tcl does: `cb-fixture-private`) registers,
under `ffi_fixture` (C-ABI-TYPES.md's precedent), synchronous foreign
operations whose contracts cover every access x escape combination a
decision reads:

| native | contract | does |
|---|---|---|
| `read[T](data, count) -> List[int]` | data: read, declared-noescape; count: ULong | the COUNT bytes at DATA |
| `read_proven[T]`, `read_reentrant[T]` | read, proven-noescape / declared-noescape | the same (`read_reentrant`: after a collection and same-sized allocations) |
| `read_retained[T]`, `read_unknown[T]`, `read_unspecified[T]`, `read_unknown_access[T]` | read+captures, read+unknown, no facts, unknown access+noescape | the same -- reachable with raw pointers only |
| `fill[T](out, count, seed: UChar) -> unit` (and `fill_proven`, `fill_retained`, `fill_unknown`) | out: write, ... | byte i = (seed + 37 i) mod 256 |
| `fill_checked(out, count, limit) -> unit errors UpperOverrun` | out: write, declared-noescape | min(count, limit) bytes, then fails if count > limit |
| `copy(dst, src, count)` | dst write, src read, both noescape | DST[i] = SRC[i] |
| `mixed(input, state, output, count) -> ULong` | input read noescape, state `Ptr[Void]` captures, output write noescape | OUTPUT reversed INPUT; the sum |

Natively each is one NIR op (`ffifixtureread`, `ffifixturereadreentrant`,
`ffifixturefill`, `ffifixturefillchecked`, `ffifixturecopy`,
`ffifixturemixed`) over a helper of `runtime/ffifixture.rs` that loads and
stores through the address with raw `ptr::read`/`ptr::write`, trusting the
count as C does; only these natives lower to them. On the Tcl backends the
same behaviors are `core::cabi::FixtureImpl` over the exposure model.

## 17. Evidence

* **NIR of a write exposure** (`digest_like` above):

  ```
  %4 = callmulti 3 %3          ; std::abi::bytes::zeroed(32): out, a virtual field
  %5 = op cptrnull             ; state, a raw pointer
  %6 = call 4 %0               ; len(input)
  %7 = op mbytesclone %4       ; the private copy of out's storage (the detach)
  %8 = op bytesaddr %0         ; input's payload address
  %9 = op mbytesaddr %7        ; the COPY's payload address
  %10 = op ffifixturemixed %8 %5 %9 %6
  %11 = op keepalive %0        ; input live until the operation returned
  %12 = op keepalive %7        ; the copy too
  %13 = structnew 0 %7         ; the write-back value: MutableBytes over the copy
  %14 = structnew 1 %13 %10    ; {output, result}
  %15 = structget 0 %14        ; r.output
  ```

  pinned by `cb-nir-read`, `cb-nir-read-mutable` and `cb-nir-write`
  (operand identities checked register by register: the operation's
  address is the address op's result, the keepalive's operand the exposed
  storage, the copy's operand the owner's storage). Since
  C-FFI-ERROR-CAPTURE-MILESTONE-1.md the two `structnew`s are gone: `r` is
  fields (`%7` and `%10`), and `r.output` read whole is one `structnew 0
  %7` at that use.
* **Allocations** (`cb-allocations`; what the exposure itself costs beside
  the same program without the call, natively, {Bytes MutableBytes Struct
  List}): a read exposure of a Bytes or a MutableBytes held in a binding:
  `0 0 0 1` (the List is the operation's result); of a Bytes written inline
  as the argument: `0 0 1 1` (its one-field wrapper, the bridge's existing
  frontier); a write exposure whose updated buffer is used: `0 1 1 0`
  (the copy and its MutableBytes; `0 1 2 0`, the write-back struct too,
  before C-FFI-ERROR-CAPTURE-MILESTONE-1.md); as a statement: `0 1 0 0`.
  `cb-write-back-allocations` pins the shapes: a write-back value bound but
  unread or discarded costs the copy alone, its buffer read whole the copy
  and one MutableBytes, once per scope however often it is read, and once
  at the call when a loop deeper than the binding reads it.
* **Executables**: a standalone executable (rustc linker, and the stub
  linker) of a program with read and write exposures prints what every
  in-process backend computes (`cb-executable`).

## 18. Performance

`bench/c-pointer-borrowing.tcl` (natively, specialized; per call, the
empty loop subtracted; a count of 0, so the operation touches no byte and
the numbers are the exposure's; best of 5 runs of 20 000 calls, 2026-10-17,
a quiet 4-core container):

| ns per call, owner of S bytes | 0 | 64 | 4096 | 65536 |
|---|---:|---:|---:|---:|
| raw (a null `Ptr`: the operation alone) | 58.7 | 22.9 | 33.1 | 87.6 |
| read exposure of a Bytes | 81.3 | 21.3 | 30.4 | 12.0 |
| read exposure of a MutableBytes | 74.9 | 33.1 | 103.8 | 2.4 |
| write exposure, result discarded | -16.9 | 61.9 | 366.6 | 3714.1 |
| write exposure, result used | 194.4 | 256.5 | 615.9 | 4307.0 |
| `std::linux::read(-1, m)` (EBADF: the syscall path's own detach) | 263.3 | 304.4 | 647.6 | 4326.6 |

| allocations of one call (S = 64) | Bytes | MutableBytes | Struct | List |
|---|---:|---:|---:|---:|
| raw, read, read of a MutableBytes | 0 | 0 | 0 | 1 (the operation's result) |
| write, discarded | 0 | 1 | 0 | 0 |
| write, result used | 0 | 1 | 2 | 0 |
| `std::linux::read` | 0 | 1 | 1 | 0 |

* **Read exposure: fixed cost, no allocation, no copy.** Two helper calls
  (`rt_bytes_addr`/`rt_mbytes_addr`, `rt_keepalive`; one since
  C-FFI-ERROR-CAPTURE-MILESTONE-1.md, where the keepalive is no call) beside the operation,
  independent of the size: the read rows do not grow with S, and their
  differences from the raw row are within this method's noise (the
  subtracted baseline is a different program; tens of ns either way).
* **Write exposure: linear in the size, the detach.** One fresh storage and
  one copy of S bytes: about 0.06 ns per byte at 64 KiB (3.7 us), and two
  small objects (~200 ns) when the write-back result is used (one since
  C-FFI-ERROR-CAPTURE-MILESTONE-1.md, which measures the difference) -- exactly
  `std::linux::read`'s detach cost, which the syscall row shows beside its
  syscall (~260 ns for EBADF). Pinning is never needed (the collector does
  not move objects), and nothing is materialized but the copy.
* The operation's own work (C touching the bytes) is not the exposure's and
  is excluded (a count of 0).

## 19. Tests, mutants, fuzzing

`tests/c-pointer-borrowing.test` (61 tests; four backends wherever a
program runs): the contract (normalization, validation, the signature,
the `direct` hook, the fixture's privacy); read exposure (bytes with
embedded and leading and trailing zeros, 0xff and the high half, 1 byte,
the empty Bytes with count 0, 5000 bytes, every byte pointee, MutableBytes
read without a copy, no mutation, evidence equivalence, a prefix count, a
raw pointer); write exposure (the write-back struct, value semantics, the
owner usable again, the current bytes visible to C, two independent
exposures, every byte pointee, 5000 bytes, empty, discarded, one owner read
and written in one call, Bytes to MutableBytes, the result type); mixed
parameters and the recorded transport; every refusal and its order;
non-owners; no pointer value; the registry pin; foreign operations only
called; imprinting; the separate length on two targets; synchronous
exposure (a yielding argument, the NIR order); the Tcl exposure model
(ends with its call, no write through a read exposure, no raw memory, the
boundary's own recheck); failure (and under GC stress); liveness (the
reentrant operation, normal and GC stress, and the keepalive mutant
detected); GC stress of the main programs; NIR and allocation evidence; the
syscall wrappers' NIR unchanged; the shared mechanism; namespace
separation; interchange; lowering from the node; the `-strict 0` replay;
an executable. Green normally, under `BOTLISH_NATIVE_GC_STRESS=1` and under
`CORE_BACKEND=compile`.

**Mutants.** `audit/c-pointer-borrowing/tools/mutate.tcl` applies the
mutants of `audit/c-pointer-borrowing/tools/mutants.txt` one at a time in a
private copy of the tree and runs the test file and the fuzzer against
each (recorded in `audit/c-pointer-borrowing/mutate-result.txt`): **22
killed, 0 survivors**.

| mutant | killed by |
|---|---|
| `const-implies-noescape` (a read parameter admits whatever its escape) | 5 tests, fuzzer |
| `unknown-implies-noescape` | 2 tests, fuzzer |
| `read-borrow-allows-write` (the Tcl model lets a read exposure be written) | `cb-tcl-read-exposure-not-writable` |
| `immutable-bytes-satisfy-write` | 4 tests, fuzzer |
| `borrow-produces-first-class-ptr` (byte storage admitted where a `Ptr` is declared) | `cb-no-pointer-value` |
| `borrow-address-can-clone` (clone/null? accept byte storage) | `cb-no-pointer-value` |
| `owner-liveness-dropped` (no keepalive after the operation) | 7 tests (the liveness ones, the NIR ones) |
| `mutable-exclusivity-dropped` (the owner's own storage exposed writable) | 9 tests, fuzzer |
| `borrow-allowed-across-yield` (a read exposure made at its argument) | `cb-exposure-after-arguments-nir` |
| `capturing-parameter-accepts-borrow` | 4 tests, fuzzer |
| `ptr-int-from-byte-storage` (any scalar of at least 8 bits) | 2 tests, fuzzer |
| `c-borrowing-uses-syscall-namespace` (exposure needs the Linux register type loaded) | 46 tests, fuzzer |
| `read-write-roles-swapped` | 10 tests, fuzzer |
| `copy-back-omitted` (the owner's storage returned as the written value) | 13 tests, fuzzer |
| `copy-back-omitted-tcl` | 11 tests, fuzzer |
| `evidence-changes-semantics` (proven noescape refused) | 2 tests, fuzzer |
| `unknown-access-admitted` | 1 test, fuzzer |
| `exposure-outlives-call-tcl` | 2 tests |
| `foreign-operation-as-value` | 1 test |
| `strict0-not-replayed` | `cb-strict0-replay` |
| `owner-built-for-exposure` (escape analysis builds the wrapper) | `cb-allocations` |
| `write-back-without-writes` (no write-back struct) | 22 tests, fuzzer |

One caveat: the first version of `borrow-produces-first-class-ptr` edited a
line C pointer admission never reaches (`ProvesValueAcceptedBy` returns
earlier for a C address type), so it was vacuous and survived; it was
retargeted at the branch that admits C pointers. Mutants only the tests see
(the fuzzer checks admission and bytes, not NIR, liveness, the Tcl model's
internals or `-strict 0`) are expected.

**Fuzzing.** `audit/c-pointer-borrowing/tools/fuzz.tcl`: each program draws
K cases -- an owner (Bytes, MutableBytes, rarely a null raw pointer) of
closed-form random bytes over lengths biased to 0, 1, 8, 16, 32 and a few
hundred; an operation from the access x escape grid; a byte or a wider
pointee; a count and a seed -- and an independent model (its own copy of
the grid, its own admission rule and reason order, its own byte arithmetic)
predicts the outcome: every refused case must fail to compile with
FOREIGN-BORROW naming the model's reason, the admitted cases run together on
every backend (and natively under GC stress with `-gc-stress 1`) and must
print the model's values, MutableBytes observed through the harness's
internal reveal (never through the fixture). Recorded in
`audit/c-pointer-borrowing/fuzz-result.txt`:

| run | result |
|---|---|
| `-n 40 -seed 1` | 320 cases, 148 refused, **0 disagreements** |
| `-n 40 -seed 17` | 320 cases, 156 refused, **0 disagreements** |
| `-n 40 -seed 41` | 320 cases, 175 refused, **0 disagreements** |
| `-n 25 -seed 5001 -gc-stress 1` | 200 cases, 103 refused, **0 disagreements** |

145 programs, 1160 cases: 582 refusals each with the model's reason, 578
exposures each with the model's bytes on four backends. The disagreements
met while building the fuzzer were all the fuzzer's own (a `loop` written as
an argument, an `options` variable a `catch` overwrote, and a hex string
`expr` read as a number, which dropped a leading `00`).

## 20. Regression

On the final tree, Linux x86-64, Tcl 9.0.1, rustc 1.97, a 4-core container:

| run | result |
|---|---|
| `tclsh9.0 tests/local.tcl` (every Tcl test file on interp and compile, golden duplicates skipped; every golden suite on all four backends, through the front-end cache, empty at the start) | Tcl tests on interp 5589 passed, 0 failed; on compile 5585 passed, 0 failed, 4 skipped (the `coreScoping` constraint, as for every compile run); 91 golden suites, 0 failed: interp 4697/4697, compile 4697/4697, cranelift-generic 4604/4604, cranelift 4706/4706 (39 min) |
| `tests/c-pointer-borrowing.test` | 61/61 normally, 61/61 under `BOTLISH_NATIVE_GC_STRESS=1`, 61/61 under `CORE_BACKEND=compile` |
| `cargo test --release --manifest-path native/Cargo.toml` | 232 + 32 passed, 0 failed (seven new: the fixture's reads and writes through a real storage address, a null pointer with no bytes never dereferenced, the declared failure after a partial write, a rooted exposure surviving the reentrant collection, `mixed`, a non-address operand) |
| `-emit-nir` of `examples/linux/{write,read-stdin,context-hello}.bot` | byte-identical to the tree before this milestone |
| `audit/hir-interchange/tools/roundtrip.tcl -via interchange` and `-via cache` | 10 suites, 90 and 100 artifacts and outcomes compared, 0 differ |
| `audit/hir-interchange/tools/mutate.tcl` | 25 mutants, 25 killed |

Tests outside this milestone's file that changed: `tests/static-compile.test`
and `tests/golden-framework.test` (the `DiagnosticCode` case count, 94 to
95), `tests/stdlib-namespaces.test` (the root inventory gains the internal
`foreign#refused`). The golden manifest gained the new file's 61 rows
(`audit/golden/migration/census/c-pointer-borrowing.tsv`, regenerated by
`merge.tcl`; no other row changed). The two mutants of other areas whose
code moved into the shared helpers still apply and are killed:
MUTABLE-BYTES.md's `read-uses-bytes-bridge` (retargeted at `BytesAddrCall`'s
`ExposeStorage` call, the same rule) and `no-keepalive` (its text is now
`KeepExposedAlive`'s, so it removes the keepalive after every consumer),
and ABI-BYTES.md's `no-keepalive`: killed by 28, 12 and 12 tests
respectively (their own tools, `-only NAME`). Every other area's
`mutants.txt` still applies (checked by text, against this tree).

## 21. Not here

`extern c fn`, `exported c fn`, actual Tcl or BoringSSL calls, C linking,
symbol resolution, calling conventions, C source capture analysis, LLVM
capture import, binding generation, Ptr ownership, stable native buffers,
`PinnedBytes`, `std::ffi::c::Bytes`, `std::ffi::c::MutableBytes`, `CBytes`, general
views, `View[L]`, mutable foreign-memory views, pointer dereference,
arithmetic or slicing, `String -> char *`, C strings, automatic NUL
termination, array or struct reinterpretation, async foreign borrowing,
callbacks and their retention, resource or context wrappers, and the
`direct` policy itself. No FFI-specific byte-buffer type and no
`BorrowedPtr[T]` exist: the exposure is call argument transport plus a
storage lifetime rule.

## 22. What to run when changing this

If you change `hir/borrow.tcl`, the contract vocabulary, `ForeignBoundary` or
the fixture (`core/cabi.tcl`), `-foreign` (`core/native.tcl`), the
`-foreign` cases of `hir/types.tcl`'s `Call` or `hir/range.tcl`'s
`VerifyCall`, the shared exposure lowering (`native/lower.tcl`'s
`ExposeStorage`, `KeepExposedAlive`, `BorrowCall`), the exposed-argument
case of `hir/escape.tcl`, the write-back value's representation
(`hir/escape.tcl`'s `WriteBackResult`, `WriteBackTree`, the write-back cases
of `NestingPlan`; `native/lower.tcl`'s `FieldValue`, `OpenedFieldObject`,
`OpenedOwnerStorage`), the keepalive's codegen, the `borrowRefused` replay
(`hir/lower.tcl`, `compiler/compiler.tcl`) or `runtime/ffifixture.rs`, run
`tests/c-pointer-borrowing.test`, `tests/c-byte-borrowing.test` and
`tests/c-ffi-error-capture.test` (all also under
`BOTLISH_NATIVE_GC_STRESS=1`),
`audit/c-pointer-borrowing/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`) and `audit/c-pointer-borrowing/tools/mutate.tcl` (every
mutant in its `mutants.txt` that applies to the host must still apply and
be killed; on macOS the tier item `c-borrow-mutants`), plus
`tests/abi-bytes.test`, `tests/abi-mutable-bytes.test`,
`tests/linux-syscall.test` and the abi-bytes and mutable-bytes mutation
tools for a change to the shared mechanism, and `tests/c-abi-types.test` for
one to imprinting or admission. `bench/c-pointer-borrowing.tcl` regenerates
the performance table.

## 23. Files

| file | what |
|---|---|
| `core/cabi.tcl` | the contract vocabulary and normalization, `RetainingParameters`, `ForeignBoundary` and the exposure model, `foreign#refused`, the borrow fixture's table, registration and Tcl behaviors |
| `core/native.tcl` | `-foreign` |
| `hir/borrow.tcl` | admission, the transport on the call, the write-back type, `FOREIGN-BORROW`, pointer-kind checks, foreign operations only called, the `direct` hook |
| `hir/types.tcl`, `hir/range.tcl`, `hir/imprint.tcl`, `hir/escape.tcl`, `hir/hir.tcl`, `hir/static.tcl`, `hir/lower.tcl` | typing, verification, imprint establishment, scalar replacement, the check order, the diagnostic code, the replay |
| `stdlib/compiler.bot`, `stdlib/test.bot`, `stdlib/ffi/c.bot` | `DiagnosticCode::ForeignBorrow` and its name; the namespace's documentation |
| `compiler/compiler.tcl` | the replay |
| `native/lower.tcl` | `ExposeStorage`, `KeepExposedAlive`, `BorrowCall`, the fixture ops |
| `native/src/runtime/ffifixture.rs`, `nir.rs`, `ops.rs`, `vm.rs`, `codegen/clif.rs` | the fixture's foreign operations, their ops and helpers, the on-demand collection |
| `tests/c-pointer-borrowing.test` | the tests |
| `tests/c-byte-borrowing.test`, `tests/cffi/fixture.c` | the exposures through real C: the host compiler's fixture and the system C library (section 24) |
| `audit/c-pointer-borrowing/tools/` | the mutants and the fuzzer |
| `bench/c-pointer-borrowing.tcl` | the performance table |

## 24. Hosts and real C

The exposure model is the same on every host that calls C: Linux x86-64 and
AArch64 and macOS AArch64 (MACOS-AARCH64-MILESTONE-7.md, which accepted it
on macOS with no change to this machinery). What a C function sees:

* **read** (`read noescape`): the payload address of the owner's own storage
  (`BytesObj` + 16, 16-byte aligned), every bit of it -- a heap address above
  4 GiB on macOS, as on Linux -- for the duration of the call; no copy,
  whether the owner is a Bytes or a MutableBytes.
* **write** (`write noescape`): the payload address of a private copy of the
  owner (the detach). After the call the copy is the write-back value's
  field, `{result: R, NAME: MutableBytes}`, whatever C's result says: a
  function that writes part of its output and then reports failure has its
  partial write in the field (no rollback), and the caller's value is never
  changed. Two write parameters are two copies, even of one owner.
* **refused**, with the same diagnostic on every target: a parameter that may
  retain the pointer (`captures`, or no escape fact), one whose access nobody
  declared, an immutable Bytes for writing, a pointee that is not byte-sized,
  a variadic call's trailing argument (it has no contract), and every way of
  making byte storage a pointer value.

`tests/c-byte-borrowing.test` checks this through real C -- the host
compiler's fixture (`bcf_checksum`, `bcf_address_of`, `bcf_fill_range`,
`bcf_split`, `bcf_fill_upto` in tests/cffi/fixture.c) and the system C
library's `memcmp`, `memcpy`, `memmove` and `memset` -- against a Tcl
oracle: sizes from 0 to 1 MiB, addresses, write shapes, failure sentinels,
refusals for three targets, `-strict 0`, GC stress, coroutines, executables
and, on macOS, Guard Malloc. c-pointer-borrowing.test's fixture is the
runtime's own Rust code: evidence of the model, not of a C call. On macOS
the tier items `c-borrow-fuzz`, `c-borrow-mutants` and `c-borrow-bench`
(tests/platform/tier.tcl) run the tools.
