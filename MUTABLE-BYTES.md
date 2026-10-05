# `abi::bytes::MutableBytes`: a writable value, and `linux::read`

## Outcome

Botlish has a writable, owned, contiguous byte value, hands the machine address
of its payload to the kernel through its raw syscall path, and reads from a file
descriptor -- without libc, without a special `read` in the runtime, and without the
compiler knowing that syscall number 0 exists:

```botlish
import abi
import linux

buffer = abi::bytes::zeroed(abi::usize(4096))
result = linux::read(abi::i32(0), buffer)
...
```

```
stdin
  --kernel read(2)-----------------> bytes written through a WRITABLE machine address
local logical abi::bytes::MutableBytes      (linux::read's own detached copy of `buffer`)
  --linux::ReadResult--------------> raw ssize_t + the updated buffer
  --abi::bytes::freeze_prefix-------------> abi::bytes::Bytes of exactly the bytes read
  --linux::write-------------------> write(2) to descriptor 1
```

`examples/linux/read-stdin.bot`, as a standalone executable, fed
`printf 'hello from stdin\n'`, writes the line back. The kernel confirms where
every byte came from (`strace -f -k`):

```
[pid N] read(0, "hello from stdin\n", 4096) = 17
 > botlish_linux_x86_64_syscall+0x1f
 > rt_linux_x86_64_syscall+0x493
 > botlish_fn_14+0x113               <- linux::read
 > botlish_fn_0+0x78                 <- the program
[pid N] write(1, "hello from stdin\n", 17) = 17     <- the already implemented raw write
 > botlish_linux_x86_64_syscall+0x1f ...
[pid N] write(1, "17\n", 3)          <- the runner's own result line: libc __write
```

The first call originates from the Botlish raw syscall path; no libc frame is in
either call's user-space stack.

## The semantic rule this milestone establishes

> **Mutable storage does not imply reference semantics.**

A `MutableBytes` is a *value*. If a program logically copies it, the copies are
independent: mutating one never mutates another because the implementation happened
to hold both in one heap object. The heap pointer a native `MutableBytes` contains is
an implementation detail, not an identity. Things that *are* identities stay
identities: a raw address (the bits are the value), a file descriptor or other
handle (the token is the value: `fd2 = fd1` names the same kernel descriptor on
purpose), and the existing `MutableArray`.

### How the rule is implemented: published storage is never written

The census (below) showed that **no boundary in either backend copies anything**:
binding, argument, return, struct field, List element, closure capture, join, module
static and `any` transport are all pointer, handle or scalar-word copies, because
every existing value kind except `MutableArray` is immutable. Putting a copy at each of
those boundaries would mean touching every one of them (and every optimization that
scalar-replaces or elides them). The narrower rule that gives the same semantics is:

> A `MutableBytes` storage is written **only while it is private to the one operation
> that created it**. Every operation that changes contents allocates a **fresh**
> storage, fills it from its operand, and writes that; from the moment the operation
> returns, the new storage is, again, never written.

So a `MutableBytes` value is never observed to change. Copying it, passing it,
returning it and storing it are plain sharing, and *independence holds through every
route at once* -- including the ones nobody enumerated -- because there is nothing
that could write through a shared pointer. The update operations are:

* `abi::bytes::replace(data, i, b)`: a fresh storage equal to `data` with byte `i`
  replaced (`rt_mbytes_set`: allocate, copy, write one byte; `data` is never written).
* `linux::read(fd, data)`: starts with `local = abi::bytes::detach(data)` -- a
  fresh storage (`rt_mbytes_clone`) -- and the *kernel* writes into `local`; `local`
  is returned as `result.data`. The caller's `data` is untouched.

The initial implementation therefore copies eagerly, on every update. That is an
implementation choice, not part of the semantics: it is copy-on-write with the
"detach" taken every time (see "How COW would fit"). On the Tcl backends every value
is an immutable Tcl value, an update returns a new one, and no copy exists at all.

This is deliberately *not* a general `valuecopy` operation applied at boundaries. The
spec asked for a runtime-kind-aware copy mechanism "if it fits cleanly"; the census
says the boundaries are the wrong place for it in this architecture, and the
kind-checked clone (`rt_mbytes_clone`, which refuses anything that is not a writable
storage) is the one primitive such a mechanism would call. Nothing keys on the
spelling `abi::bytes::MutableBytes`: the runtime kind (`KIND_MUTBYTES` / `{mutbytes HEX}`)
is the discriminator.

## Source surface (lib/abi/bytes.bot, lib/linux.bot)

One module, `abi::bytes` (`lib/abi/bytes.bot`), owns **both** opaque types and holds
only the primitive operations -- every function that projects or constructs a
representation, and nothing else:

```botlish
opaque struct Bytes:
    storage: any
opaque struct MutableBytes:
    storage: any

fn from_list(values: List[Byte]) -> Bytes
fn length(data: Bytes) -> abi::Usize

fn zeroed(length: abi::Usize) -> MutableBytes
fn from_bytes(data: Bytes) -> MutableBytes
fn mutable_length(data: MutableBytes) -> abi::Usize
fn replace(data: MutableBytes, index: int, value: Byte) -> MutableBytes errors IndexNotFound
fn detach(data: MutableBytes) -> MutableBytes
fn freeze(data: MutableBytes) -> Bytes
fn freeze_prefix(data: MutableBytes, count: abi::Usize) -> Bytes errors UpperOverrun

abi::x86_64::from_mutable_bytes(data: abi::bytes::MutableBytes) -> abi::x86_64::Register64   # root native

# lib/linux.bot
struct ReadResult:
    result: int
    data: abi::bytes::MutableBytes

fn read(fd: abi::I32, data: abi::bytes::MutableBytes) -> ReadResult
```

Qualified with the full path (`abi::bytes::zeroed(n)`), the way `abi::x86_64::from_i32` is; after
`import abi::bytes` the same functions are method candidates (`buffer.freeze_prefix(n)`). A struct
cannot be imported by short name (`import type` accepts `type` declarations only), so signatures
spell `abi::bytes::MutableBytes` in full.

### Why one module, and why these names

* **One owner for both types.** `opaque` gives a representation to exactly one module (the owner
  is the declaring namespace, compared exactly). `from_bytes` must read a `Bytes` and construct a
  `MutableBytes`, `freeze`/`freeze_prefix` the reverse, so a layout with a module per type needs
  public hooks that hand out or accept a raw storage as an `any`, and a layout that lets child
  namespaces reach the parent's opaque types would let any file at `abi/x.bot` into the privileged
  set. Neither was acceptable, so the module that owns the representations is one, and the
  single-owner rule is untouched. (A prototype confirmed that an opaque struct in a nested module
  works on every backend, and that a separate operations module cannot construct it:
  `OPAQUE-CONSTRUCTION`, naming the types module.)
* **Primitives only.** All nine functions are one native call plus a wrap. Two could be derived --
  `freeze` as `freeze_prefix(d, mutable_length(d))` (but `freeze_prefix` declares `UpperOverrun`
  and the compiler cannot prove it away, leaving a handler for an impossible error) and `detach`
  as `from_bytes(freeze(d))` (a second copy and wrapper in every `linux::read`, and `detach` is
  the one place a future copy-on-write hooks in) -- and were deliberately kept. Policy sits above:
  `linux::read`, `linux::write`.
* **Names follow the list API, not the spec's.** The spec named these before the rest of the
  library was in view (`mutable_bytes_set`, `mutable_bytes_copy`, ...). A namespace replaces the
  `mutable_bytes_` prefix; `replace` says the result is a different value (`set` implies mutation,
  and `with` is reserved for a future construct); `detach` names the purpose of the copy. One
  name still carries a prefix, `mutable_length`: a name denotes one function and both types need a
  length.
* **`import abi` stays small.** `Bytes` left `lib/abi.bot`, which keeps only the numeric domains;
  a program that imports only `abi` no longer loads `byte` and its global errors.

| | |
|---|---|
| constructor | `abi::bytes::zeroed(n)`: `n` **zero** bytes; nothing uninitialized is ever visible. A length beyond the collection ceiling (2^62 - 1) is the RANGE error every oversized collection is, and an allocation the machine cannot supply is reported as RANGE ("out of memory"), not an abort |
| `from_bytes` | an independent writable copy; changing it never changes the `Bytes` |
| length | `abi::bytes::mutable_length(data) -> abi::Usize`; fixed for the value's life; there is no capacity |
| update | `replace`: a **new value**; `data` is unchanged. `IndexNotFound` (the existing list/array convention) unless `0 <= index < length`; the value is a `byte::Byte` by typing |
| `detach` | semantically the identity (a logical copy is the same value), physically a fresh storage: the "detach" a writable foreign access needs (below). The one addition beyond the spec's list, needed so `linux::read` can be ordinary Botlish |
| `freeze` / `freeze_prefix` | immutable snapshots (a copy). `freeze_prefix` with `count > length` is `UpperOverrun` and reads nothing outside the payload; `count: Usize` already excludes negatives |
| not provided | slicing, indexing, concatenation, capacity, resizing, `Bytes` slicing, an address accessor, `CString` |

A `MutableBytes` is not a `Bytes`, `String`, `CString`, pointer, borrow, resource,
reference, resizable vector or iterator. The two storages are different runtime kinds
and different static types: nothing compares equal across them and nothing converts.

### Equality, hash, rendering

* **Equality** is by current contents, never by storage identity: independent values
  with equal contents are equal; `put(a, 1, x) == a` when `x` is already there.
* **Hash** is by current contents, consistent with equality: the byte count as 8
  little-endian bytes, then the bytes, under kind tag **10** (a `Bytes` is tag 9, so a
  `MutableBytes` and a `Bytes` of the same bytes hash differently). The hash *values*
  agree on all four backends (tested). A `MutableBytes` stored in a List, a struct or
  an `ImmutableSet` is its value at that moment; a later "mutation" of another copy
  is a new value, so it cannot corrupt the container's equality or hash invariants
  (tested). No collection semantics were redesigned.
* **Rendering** is the opaque-struct rule on every backend, alone or nested:
  `<opaque abi::bytes::MutableBytes>` -- no address, allocator id, payload or sharing. The
  explicit internal reveal shows `abi::bytes::MutableBytes {storage: <mutbytes 3: 4100ff>}`,
  which is how backends are compared byte for byte.

## `linux::read`

```botlish
fn read(fd: abi::I32, data: abi::bytes::MutableBytes) -> ReadResult:
    local = abi::bytes::detach(data)
    result = abi::x86_64::to_int(
        linux::abi::syscall({
            rax: abi::x86_64::register64(0),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_mutable_bytes(local),
            rdx: abi::x86_64::from_usize(abi::bytes::mutable_length(local)),
        })
    )
    ReadResult {result: result, data: local}
```

* **Register mapping** (the existing generic Linux x86-64 convention, never the C
  calling convention): `rax = 0` (SYS_read), `rdi = fd`, `rsi = payload address`,
  `rdx = the buffer's length`, `r10 = r8 = r9 = 0`.
* **One buffer, one source of truth.** There is no `count` parameter: address and
  count both come from the same `local`. The raw syscall still receives them in
  separate registers.
* **Logical copy.** The caller's `data` is never changed; the kernel's bytes are in
  `result.data` only. Reading the same `original` twice gives two independent results
  (tested). If the compiler proves `data` dead it *may* write into its storage
  directly -- nobody could tell -- but nothing here does.
* **ONE syscall**: no retry, no loop, no filling. NIR has exactly one
  `syscall_linux_x86_64` op in `linux::read` and no branch, jump, label or tail call.
* **Result** is the kernel's raw signed `ssize_t` as an ordinary `Int`
  (`abi::x86_64::to_int`): `> 0` bytes read, `0` end of file, `< 0` the kernel's
  `-errno`, preserved exactly. No errno mapping, EOF is not an error, nothing is `null`.
* **Short reads.** A positive result smaller than the buffer is normal. Only
  `[0, result)` was written; the rest holds what it held before (tested with a real
  short read from a pipe and a file: `AA AA AA AA AA AA` + `01 02 03` becomes
  `01 02 03 AA AA AA`). Nothing is resized: the buffer keeps its length, and
  `abi::bytes::freeze_prefix(result.data, abi::usize(result.result))` yields the bytes read.
* **Errors.** A refused read returns its raw negative result with the buffer
  unchanged (`-9`, EBADF, for an invalid descriptor, tested).
* **No retained pointer.** The address is taken and consumed synchronously inside
  one function; a kernel API that keeps the pointer after returning belongs to a future
  resource design.

### Stdin example and language notes

`examples/linux/read-stdin.bot` does one `linux::read` of 4096 bytes from descriptor 0,
and if the result is positive freezes exactly the returned prefix and writes it to
descriptor 1; otherwise its value is the raw result (0 at EOF, `-errno` on error). It
needs two conversions the compiler cannot prove away -- `result` is an ordinary `Int`
-- so the example binds `n = result.result` (a refinement `if n > 0` applies to a local
binding, not to a field projection) and handles `AbiIntegerAboveRange` and
`UpperOverrun` with handlers that cannot run (handlers cover only the outermost call
of an expression, so each fallible call is bound on its own line).

## Native representation

| | |
|---|---|
| kind | `KIND_MUTBYTES = 14` (immutable `Bytes` is `KIND_BYTES = 13`): a different kind, never accepted for one another (`rt_bytes_len(mutable)` and `rt_mbytes_len(bytes)` are both TYPE errors) |
| layout | identical to `Bytes`: `hdr(8) \| len(8) \| payload`, one allocation, no pointer to a second block; no capacity, no trailing NUL |
| alignment | 16 bytes; the payload is at `object + 16`, O(1), no read |
| allocation size | `16 + len`, rounded up to 16 (`allocationReport`: a 4096-byte value is one 4112-byte object, reported under its own kind `MutableBytes`) |
| length | the 8-byte `len` field, `len <= 2^62 - 1` (checked before allocation); fits a small Int, hence an `abi::Usize` |
| GC tracing | none: the payload holds no Botlish reference; the collector marks the header and frees the block with the layout it was allocated with. Non-moving, so liveness is sufficient for an address |
| empty | a zero-length value is one shared static object (nothing in it can be written or observed); **every non-empty value is its own heap object, never a static constant** (no mutable native is context-free, so a compile-time-known mutable value cannot make two logical values share writable static storage) |
| payload address | `rt_mbytes_addr`: object + 16 (a small Int) |
| host value | `{mutbytes HEX}` -- the Tcl representation, the same lowercase hex text as `{bytestore HEX}` under its own kind |

NIR ops: `mbytesnew`, `mbytesfrom`, `mbyteslen`, `mbytesset`, `mbytesclone`,
`mbytesfreeze`, `mbytesfreezeprefix`, `mbytesaddr`. All but `mbyteslen`/`mbytesaddr`
allocate (GC safepoints); all are fallible only on a wrong-kind or out-of-range operand
that a checked program cannot produce (lib/abi/bytes.bot proves each before the call).

## The writable address bridge and liveness

`abi::x86_64::from_mutable_bytes(data) -> Register64` is the writable twin of
`from_bytes`: a root native (only module `abi::bytes` can project the storage), statically
requiring an `abi::bytes::MutableBytes` argument (`from_bytes(MutableBytes)`,
`from_mutable_bytes(Bytes)`, of an Int, a String, a raw storage or an `abi::U8` are all
compile-time `TYPE` errors; a `-strict 0` program replays the problem as a run-time
TYPE before anything is evaluated), callable only directly, native only (the Tcl
backends refuse it with `NATIVE-ONLY`). It knows no syscall, no argument number and no
libc. It does **not** copy.

* **Provenance is generalized, not duplicated.** The existing `keepAddr` map (a register
  -> the byte storages whose payload address it may hold) is created by both bridges
  (`bytesaddr` / `mbytesaddr`) and flows through the same routes (register struct,
  `structget`, List, `if` merge, calls to Botlish functions that take or return an
  address); `AddressFlowAcrossCall` recognizes both `Bytes` and `MutableBytes`
  arguments. `SyscallCall` emits `op keepalive` of the exact storage after the
  syscall. The writable case needs no extra marking: the only extra fact -- the
  contents may change across the foreign call -- already holds, because every read of a
  storage is a runtime helper call that Cranelift treats as reading and writing all
  memory and can neither cache nor reorder across the syscall.
* **Mutation barrier unchanged.** `linux::abi::syscall` stays generic (it does not know
  syscall 0 writes memory); its strong memory/effect barrier is the one that matters.
* **Verified.** Six routes by which a writable address reaches a syscall (inline,
  locals, register struct, helper, `if` merge, callee) run under GC stress with a second
  same-sized allocation after the address is taken; the kernel receives the first
  storage's bytes every time; the same program with the `keepalive` deleted from its NIR
  is a mutant the test fails.
* **The raw layer is sharp, on purpose.** Because the bridge does not detach, a raw
  program that hands a syscall the address of a value other values share writes through
  all of them (a test pins this: `a = ...; b = a; raw read into from_mutable_bytes(a)`
  changes `b` too). The safe theorem belongs to `linux::read`, which detaches first.
  Future `direct`/raw-ABI restrictions may make the operation unavailable to ordinary
  application code; that policy is not implemented here.

## Census of value-copy boundaries (before coding)

Read-only audit of both backends (the report is summarized; every claim was checked
against the code):

| boundary | native | Tcl |
|---|---|---|
| binding / rebinding | SSA register alias (`Bind`); rebinding in a scope is `DUPLICATE` | `env::define` of a Tcl value |
| function arguments | tagged Value words in registers; structs/Lists may travel as scalar fields | `env::define` per parameter |
| returns | `ret` / `retmulti` of registers | Tcl values |
| struct fields | `rt_struct_new` copies the field *words*; `structget` reads one; scalar replacement keeps fields in registers | `structNew` / `project` |
| List elements | `rt_list_new` / `rt_list_append` copy element words (shallow), `rt_list_get` returns the stored word | `lappend`, Tcl copy-on-write |
| closure captures | `rt_closure_new` copies capture words | a closure pins the frame |
| generic / `any` | a tagged Value word | a plain Tcl value |
| branch joins | `move` into a join register | variable assignment |
| module statics | one word store/load; initializers must be context-free and transitively immutable (a `mutarray` is rejected) | `env::define` in the base frame |
| coroutine / actor / thread transfer | **none exists** (`NativeStack` reserves a `Suspended` state; `std::thread` only gives the whole program a big stack) | none |
| `ImmutableSet` | dedup by `equal`, keeps the same item words | `Dedup` |

**Nothing at any boundary clones a heap object.** The only element-wise copies are
shallow word copies when a *new* collection is built.

**MutableArray** is reference semantics: `{mutarray ID}` (a handle into a global store)
in Tcl, a `MutArrayObj` with `slots` natively; every boundary above duplicates the
handle, so every alias sees mutation (PARAMETERIZED-MUTABLEARRAY.md). `freeze` copies
shallowly; `set`/`copy` write in place; `equal`/`hash` raise EQUALITY. **It was not
changed by this milestone** (`core/mutarray.tcl` and its runtime ops are untouched and
their tests pass). It is the only existing in-place mutation. A future separate design
may revisit it.

**Reusable mechanisms:** nothing existing copies, so the reusable pieces are the
opaque-struct privacy rule, the byte-storage object layout, the `keepAddr`
provenance and `keepalive`, and the kind-checked runtime ops. **A new logical-copy
mechanism is required at exactly the operations that write**, which is what
"published storage is never written" provides.

**Transforms that could merge or drop allocating calls:** none exist. There is no CSE,
GVN, hoisting or dead-call removal in HIR or NIR; Cranelift treats every runtime
helper as an opaque call; no registration flag (`-context-free`, `-runtime`, ...)
controls deduplication. The one allocation elision is static byte-constant folding for
`abi::bytes::from_list` of a compile-time-known sequence, which is sound only because `Bytes` is
immutable; it is **not** applied to `MutableBytes` (none of its natives is
`-context-free`). Tests assert that two `zeroed(n)` calls, and two `from_bytes` of the same
constant, are four separate heap storages (while two constant `Bytes` are static, 0 allocations).

## Value-copy behaviour, route by route

All tested on `interp`, `compile`, `cranelift-generic` and `cranelift` (each route
creates a copy, mutates one copy to get a new value, and checks every other copy and
the original unchanged):

| route | result |
|---|---|
| direct binding `b = a` | independent |
| ordinary function parameter, called with a copy that survives | independent |
| identity function result `b = id(a)` | independent |
| result of a function while another copy survives | independent |
| List element (`[a]`, then update `a`) | the list still holds the original |
| struct field (`Holder {data: a}`) and a copied struct | independent |
| generic function (`fn same(x): x`) | independent (specialization may remove a physical copy; there is none to remove) |
| `any` / erased (`fn through(x: any)`, a re-erased parameter) | independent: the runtime kind, not the static spelling, is what is shared |
| closure capture (`a` captured, updated through `bump()`) | the captured value never changes |
| `ImmutableSet` | membership and equality unaffected by later updates of other copies |
| `loop` producing many updates of one source | the source and every result independent |
| `if` join | independent |
| `linux::ReadResult` copies (`r2 = r1`, `bump(r1)`, `[r1, r3]`) | the buffer in one is never the other (natively, with a real read) |

**Coroutine/actor/thread transfer:** no such operation exists, so nothing was built.
When one does, the receiver must get an independent logical value: a physical move is
allowed when the sender can no longer observe the source; physical sharing would need
COW before either side writes.

## Physical copies: what happens, and what is not optimized

Allocation counts (`native::allocationReport`, in-process; columns total /
`MutableBytes` / `Bytes` / `Struct` / `List`; the only List in these programs is the
test's own tuple):

| program | total | MutableBytes | Bytes | Struct | List |
|---|---|---|---|---|---|
| `abi::bytes::zeroed(abi::usize(0))` | 0 | 0 | 0 | 0 | 0 |
| `abi::bytes::zeroed(abi::usize(16))` (also 4096: one 4112-byte object) | 1 | 1 | 0 | 0 | 0 |
| `b = m; c = b; [len(c), len(m)]` (copy by binding) | 2 | 1 | 0 | 0 | 1 |
| `id(id(m))` (copy through a function) | 2 | 1 | 0 | 1 | 0 |
| `[m, m]` / `[m, put(m, ..)]` (into a List) | MutableBytes column 1 / 2 | | | | |
| `put(m, 0, b)` (`replace`) | 4 | 2 | 0 | 2 | 0 |
| `abi::bytes::freeze(m)` | 2 | 1 | 1 | 0 | 0 |
| `rd(1000, m)` (`linux::read`, original + detach clone, + the returned wrapper) | 3 | 2 | 0 | 1 | 0 |

Reading: a binding, a List element and a function pass-and-return copy **no storage**;
a function that carries the value across a call materializes the one-field wrapper
`Struct` (existing behaviour: ABI-BYTES.md). An update costs one copy of the bytes (and
a wrapper). A `linux::read` costs the detach clone beside the caller's buffer, plus the
wrapper for the returned buffer. These are the eager copies this milestone accepts;
none is hidden.

**Copy elision obtained for free:** the wrapper `Struct` is scalar-replaced inside a
function (`abi::bytes::mutable_length(local)` is one `op mbyteslen` on the storage
register); `linux::read`'s returned buffer is the same register the kernel wrote
(`structnew` over the one storage) -- no second copy at the return. **Not done** (and
not attempted): eliding the detach when `data` is a fresh temporary or dead after the
call, returning the storage without the wrapper, in-place update of a dead value, and
zero-copy `freeze`. Each is legal under the semantics and none is needed for them.

## How copy-on-write would fit (not implemented)

No reference counts, shared flags or detach-on-write exist; the one operation
`detach`/`rt_mbytes_clone` is the detach. A future COW would:

| operation | would |
|---|---|
| logical copy | share the physical backing (increment a count, or not at all) |
| read-only operation (`length`, `==`, `hash`, `freeze` inspection) | keep sharing |
| `replace` | detach first if shared, then write in place |
| `from_mutable_bytes` / writable foreign access | detach first if shared (what `detach` does unconditionally today), then hand out the address |
| `freeze` | share only if the mutable backing can never be written again (uniqueness/deadness) |

The hook is `rt_mbytes_set` / `rt_mbytes_clone`: replace "always allocate" with "allocate
unless unique". Source semantics do not change.

## Evidence

* **NIR of `linux::read`** (the canonical one, from `-emit-nir`):

```
func 14 "linux::read" params=2 ... pnames="fd.0 data.0" instance="abi::I32, abi::bytes::MutableBytes" results=2
    %2 = callmulti 7 %1          ; abi::bytes::detach(data): the detached local storage
    %5 = callmulti 9 %3          ; abi::x86_64::register64(0)
    %6 = callmulti 11 %0         ; abi::x86_64::from_i32(fd)
    %7 = op mbytesaddr %2        ; the WRITABLE address of THAT storage: rsi
    %8 = callmulti 6 %2          ; abi::bytes::mutable_length(local)
    %9 = callmulti 12 %8         ; abi::x86_64::from_usize(length): rdx
    %11 = op syscall_linux_x86_64 %5 %6 %7 %9 %10 %10 %10   ; rax rdi rsi rdx r10 r8 r9 -- the ONE syscall
    %12 = op keepalive %2        ; the storage stays live across the syscall
    %13 = call 10 %11            ; abi::x86_64::to_int
    %14 = structnew 1 %2         ; the returned buffer: the SAME register the kernel wrote
    retmulti %13 %14
```

  No loop, no retry. A test checks the operand identities register by register (the
  address op's operand, the length call's operand, the keepalive's operand, the
  `ReadResult`'s data and the detach result are one register).
* **Machine code** (`objdump` of the standalone executable's `linux::read`): `call
  botlish_fn_7` (the detach, whose own body is one `call rt_mbytes_clone`), then
  `call rt_mbytes_addr`, then `call rt_linux_x86_64_syscall`, then `call rt_keepalive`
  with `rsi` the same register as the address helper's, then `to_int` and `call
  rt_struct_new` for the returned wrapper. **No call to libc `read`, `recv`, `pread`
  or `syscall(3)` is in it.** libc is present elsewhere in the executable (Rust's
  runner prints the result line with it), so the precise statement is: the Botlish
  read path never reaches it, and the whole executable still has exactly one `syscall`
  instruction (in `botlish_linux_x86_64_syscall`).
* **Kernel evidence** (`strace`, tested when available): the stdin example's chain
  above; a binary read `read(0, "\0\200\377\1\0\0\376", 16) = 7` (a real short read: 7 < 16, NUL
  and high bytes intact); end of file `read(0, "", 16) = 0`; an invalid descriptor
  `read(1000, 0x..., 8) = -1 EBADF` -- in every case exactly one read, issued from
  `botlish_linux_x86_64_syscall`, with no libc frame.
* **CLIF**: `rt_mbytes_addr`, then the syscall helper, then `rt_keepalive`, the
  keepalive's operand the very value `rt_mbytes_addr` took, and the syscall's stack map
  naming the slot holding that storage (a GC root at the syscall's own safepoint).

## Tests

`tests/abi-mutable-bytes.test` (76 tests; all green in a normal run, under
`BOTLISH_NATIVE_GC_STRESS=1` and under `CORE_BACKEND=compile`):

* registration (eight natives, none context-free, none knowing a syscall), the
  declaration, the API surface;
* **every backend**: zero-filled fixed length, `Usize`, UTF-8 bytes-not-scalars,
  oversize RANGE, `set` (new value, `IndexNotFound`, byte typing), `freeze` and
  `freeze_prefix` snapshots, `from_bytes` independence, equality, not-a-`Bytes`, hash
  values agreeing, collections, rendering, the internal reveal;
* **the theorem**, thirteen routes (binding, parameter, identity, result with another
  copy, List, struct, struct copy, generic, `any`, closure, `ImmutableSet`, loop,
  join), each on all four backends;
* opacity diagnostics, both bridges' static contracts (never mixed), `-strict 0`
  replay, `NATIVE-ONLY` on the Tcl backends, no fake read;
* **native** (standalone executables; descriptor 0 a file or a real pipe; descriptors
  3 and 4 files): the stdin example (text, EOF, binary), a real short read with the
  untouched suffix, the issue's `AA..` + `01 02 03` example, EOF, the raw `-9`, a
  larger input than the buffer (one chunk read; the rest still available to a `cat`
  sharing the file offset), the caller's buffer unchanged and two reads of one
  original independent, `ReadResult` copies, a wrapper that never writes through
  shared values, the documented raw-layer sharp edge, and the memory barrier (a
  freeze before a raw read shows the old bytes, one after shows the kernel's);
* **GC stress**: forty reads reassemble a file exactly; in-process pure values
  identical with and without stress; the six liveness routes; the keepalive mutant
  is detected;
* NIR / CLIF / machine-code / `strace` / allocation / object-layout evidence.

Rust unit tests (`cargo test --release`: 183 + 28, nine new): layout and zero fill,
the length ceiling and out-of-memory as errors, update-by-copy never writing its
operand (every index, several sizes), refusal of bad index/value/operand, clone /
freeze / prefix and the two kinds never mixing, the writable address (a write through
it lands in the payload), equality / hash (tag 10) / rendering, collection, and
operations under a collection at every allocation.

## Limitations discovered

* **Every update copies the whole buffer.** A loop of *n* `replace` calls is
  O(n·length); there is no in-place path for a dead value. Correct, deliberately
  conservative, and measured above rather than hidden.
* **`linux::read` allocates two storages and a wrapper** (the caller's, the detach,
  the returned wrapper); a fresh temporary buffer is not elided.
* **The raw writable bridge does not detach** (sharp edge, tested). It is raw-machine
  territory like `from_bytes`; the safe theorem is `linux::read`'s.
* **`replace` needs an `IndexNotFound` handler** at each call: the static
  completion proofs have no bounds family for it (adding one would touch
  hir/completions.tcl for little). A refinement `if n > 0` also does not apply to a
  field projection, and a handler covers only the outermost call of an expression,
  which is why the example binds intermediate values.
* **Tcl backends build the hex text of a whole buffer**: a `MutableBytes` above 1 GiB is
  refused there (RANGE); natively the ceiling is 2^62 - 1 and exhaustion is reported
  as RANGE.
* **No actor/thread transfer exists** to verify the receiver rule against.
* **`abi::bytes::detach` is a public function.** It is semantically the identity;
  it exists because `linux` cannot touch the storage of an opaque struct, and a
  future compiler that proves deadness could make it free.

## What remains before ...

* **COW**: a uniqueness or reference-count bit on the storage and the two hooks above;
  then `freeze` and `from_bytes` become zero-copy where provable.
* **Dead-value reuse / return transfer**: deadness facts across `linux::read`'s call
  boundary (the escape machinery does not span it today; ABI-BYTES.md had the same
  frontier) to elide the detach and the wrapper.
* **Long-lived retained writable pointers / resources**: ownership anchoring, a
  lifetime beyond one synchronous call, destructors, and the `direct`/raw-ABI
  restrictions on the operations that expose addresses -- none started; the storage
  never moves, so only liveness is needed.
* **`MutableArray`**: still a reference; whether it should become a value too is a
  separate design.

## Fuzz results

`audit/mutable-bytes/tools/fuzz.tcl`, recorded in `audit/mutable-bytes/fuzz-result.txt` (re-run on the final
`abi::bytes` layout). Each program is seeded individually (a failure replays with `-seed S -n 1`); the oracle is
an independent Tcl byte-list model that never reads what the program computes.

| run | what | result |
|---|---|---|
| `-mode both -n 60 -seed 1 -items 12` | pure scripts on interp, compile, cranelift-generic and cranelift **and** native read programs, normal and under GC stress | 60 programs, 787 values, **0 failures** |
| `-mode pure -n 40 -seed 9001 -items 14` | the same pure checks, a second seed range | 40 programs, 441 values, **0 failures** |
| `-mode read -n 60 -seed 5001 -gc-stress 1` | sequential file reads and a pipe read, whole process under GC stress | 60 programs, 240 values, **0 failures** |
| `-mode read -n 80 -seed 12001` | the same, a larger run | 80 programs, 320 values, **0 failures** |

The earlier `Bytes` fuzzer (`audit/abi-bytes/tools/fuzz.tcl -mode both -n 40 -seed 1 -items 8`) also passes on
the new layout: 40 programs, 320 payloads, 0 failures.

The pure scripts check the contents of every variable and snapshot *at the end*, so an update that leaked into an
earlier copy through any route (binding, generic identity, List, struct, detach, double update) would show. The
read mode checks every result (`min(capacity, remaining)`), the returned buffer (bytes read then the untouched
suffix), the caller's own buffer, and the file's remaining input.

## Mutation results

`audit/mutable-bytes/tools/mutate.tcl`, recorded in `audit/mutable-bytes/mutate-result.txt`: eighteen mutants run in
a scratch copy of the tree (Rust mutants rebuild the native backend there) against `tests/abi-mutable-bytes.test`
and the read fuzzer: **18 killed, 0 survivors**, in one pass on the final layout.

| mutant | killed by |
|---|---|
| `clone-aliases` (the detach returns its operand) | 6 tests, fuzzer |
| `set-aliases` (an update writes its operand in place) | 24 tests |
| `read-does-not-detach` (the kernel writes the caller's storage) | 10 tests |
| `freeze-shares` (zero-copy freeze: flips the object into a Bytes) | 22 tests |
| `from-bytes-shares` (`from_bytes` reuses the Bytes' storage) | 2 tests |
| `clone-zeroes` (the detach loses contents; suffix would read zeros) | 5 tests |
| `address-one-late` (writable bridge + 1) | 18 tests |
| `read-uses-bytes-bridge` (readable address op for the writable bridge) | 28 tests |
| `count-off-by-one` (rdx = length + 1) | 5 tests |
| `count-unrelated` (rdx = constant 1) | 13 tests |
| `no-keepalive` | 11 tests (liveness routes, CLIF stack map, the detector) |
| `result-is-the-original` (read returns the pre-syscall buffer) | 13 tests |
| `rax-is-write` (syscall number 1) | 12 tests |
| `libc-read` (libc `read` for rax = 0) | 3 tests: raw negative result (libc gives -1, not -9), the strace stack |
| `read-twice` | 15 tests |
| `prefix-is-suffix` | 6 tests |
| `equality-by-identity` | 8 tests |
| `hash-ignores-length` | 1 test (the one comparing hash *values* across backends) |

The earlier `Bytes` suite (`audit/abi-bytes/tools/mutate.tcl`, twelve mutants) was re-run on the new layout too:
**12 killed, 0 survivors** (`audit/abi-bytes/mutate-result-after-abi-bytes-layout.txt`), so the immutable
guarantees did not regress.

Honest notes. During development two mutants were refused by this tool's own guard (a run-time TYPE kill misread
as a compile error; a helper function appended after its use); the tool was fixed and the final run above has no
such case. A "list/struct copy aliases" mutant is not expressible as such: no boundary copies anything, so the
aliasing mutants are the two write paths (`clone-aliases`, `set-aliases`), which the List, struct, generic, `any`
and closure routes of the theorem tests then catch. And `hash-ignores-length` is, as for `Bytes`, caught by one
test only, since equal values still hash equal without the count.

## Regression

Every run below is the whole suite on the final tree (the `abi::bytes` layout, with `main`'s newest commits
merged in: the `METHOD-ELIGIBLE` warning), native backend built from it, under `LANG=C.utf8 LC_ALL=C.utf8`.

| run | command | result |
|---|---|---|
| interpreter | `CORE_BACKEND=interp tclsh9.0 tests/all.tcl` | 5766 tests, **5766 passed**, 0 failed |
| Tcl compiler | `CORE_BACKEND=compile tclsh9.0 tests/all.tcl` | 5766 tests, **5762 passed**, 4 skipped (the `coreScoping` constraint, as for every compile run), 0 failed |
| native/cranelift coverage | `tclsh9.0 tests/native-coverage.tcl` | 5800 tests: 2432 ran native, 3238 independent of the backend, 70 passed-partial, 60 unsupported (constructs native does not run, as in the baseline), **0 failed** |
| GC-stress suite | `BOTLISH_NATIVE_GC_STRESS=1 CORE_BACKEND=interp tclsh9.0 tests/all.tcl` | 5766 tests, **5766 passed**, 0 failed |
| Rust | `cargo test --release --manifest-path native/Cargo.toml` | **183 + 28 passed**, 0 failed |

`tests/abi-mutable-bytes.test` (76) and `tests/abi-bytes.test` (73) are part of those runs and also pass on their own.
Tests that pin the exact set of native names, or that read the library source, had to follow the rename (the
`abi-numeric`, `linux-syscall` and `stdlib-namespaces` inventories; the two declaration/surface tests of
`abi-bytes`); nothing else in an existing test changed, and `Bytes` is still physically shareable and never subjected
to any `MutableBytes` copy behaviour.

## Milestone report (the 48 items)

1. **Declaration:** `opaque struct MutableBytes: storage: any` (lib/abi/bytes.bot, module `abi::bytes`, beside `Bytes`).
2. **Constructor:** `abi::bytes::zeroed(length: abi::Usize)`, zero-filled.
3. **`abi::bytes::from_bytes(data: Bytes)`:** an independent writable copy.
4. **Length:** `abi::bytes::mutable_length(data) -> abi::Usize`.
5. **Update:** `abi::bytes::replace(data, index, value) -> MutableBytes errors IndexNotFound`; a new value.
6. **Freeze:** `abi::bytes::freeze(data) -> Bytes`, a copying snapshot.
7. **Freeze prefix:** `abi::bytes::freeze_prefix(data, count: Usize) -> Bytes errors UpperOverrun`.
8. **Native layout:** `KIND_MUTBYTES = 14`, `hdr(8) | len(8) | payload`, one allocation, 16-aligned, payload at +16, no tracing.
9. **Tcl representation:** `{mutbytes HEX}`, a value kind of its own.
10. **Equality:** by current contents.
11. **Hash:** by current contents, kind tag 10; values agree on all backends.
12. **Logical copy:** any second observable use of the value (binding, argument, result, field, element, capture, erased transport); independent by construction.
13. **Boundaries audited:** the census table above.
14. **Copy mechanism:** "published storage is never written": updates and the kernel's write go to a fresh copy (`rt_mbytes_set`, `rt_mbytes_clone`).
15. **Through `any`:** independent (tested).
16. **Through generics:** independent (tested).
17. **List:** independent; storing copies nothing.
18. **Struct:** independent.
19. **Closure:** a captured value never changes.
20. **`MutableArray`:** unchanged (reference semantics, noted).
21. **Eager-copy strategy:** every update copies the whole buffer; measured in the allocation table.
22. **Copy elision for free:** wrapper scalar replacement; the returned buffer is the register the kernel wrote.
23. **Future COW:** the hook table above (`rt_mbytes_set` / `rt_mbytes_clone`).
24. **Writable bridge:** `abi::x86_64::from_mutable_bytes(data) -> Register64`.
25. **Provenance:** the existing `keepAddr`, generalized to both bridges, not duplicated.
26. **GC keepalive:** `op keepalive` of the exact storage after the syscall; six routes, mutant detected.
27. **`linux::ReadResult`:** `struct ReadResult: result: int; data: abi::bytes::MutableBytes`.
28. **`linux::read` source:** above.
29. **Register mapping:** `rax = 0, rdi = fd, rsi = payload address, rdx = length, r10 = r8 = r9 = 0`.
30. **Caller's buffer:** unchanged (tested, incl. two reads of one original).
31. **Short reads:** the raw positive count; only the prefix is written.
32. **EOF:** the raw 0, buffer unchanged.
33. **Negative errno:** the raw value (-9), buffer unchanged.
34. **Untouched suffix:** `01 02 03 AA AA AA` test.
35. **Stdin example:** `examples/linux/read-stdin.bot`.
36. **Binary stdin test:** NUL, 0x80, 0xff, multi-byte UTF-8, through the example.
37. **NIR evidence:** above.
38. **Machine-code evidence:** above.
39. **strace evidence:** above (stdin read, binary short read, EOF, bad fd).
40. **libc `read` is not the wrapper path:** no libc read call in `linux::read`; no libc frame in the kernel's stack; one `syscall` instruction in the whole executable.
41. **Allocation measurements:** the table above.
42. **GC-stress results:** suite 5766/5766; new suite 76/76; forty-read reassembly exact.
43. **Fuzz results:** the table above.
44. **Mutation results:** 18 of 18 killed.
45. **Full regression:** the table above.
46. **Limitations:** listed above.
47. **Before COW:** a uniqueness/count bit and the two hooks.
48. **Before retained writable pointers/resources:** ownership anchoring, lifetimes beyond one synchronous call, destructors, `direct`/raw-ABI restrictions.
