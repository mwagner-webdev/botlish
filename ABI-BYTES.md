# `abi::bytes::Bytes`: the first owned ABI memory value, and `linux::write`

## Outcome

Botlish can build an immutable, owned, contiguous byte value, hand its machine
address and exact length to the kernel through its raw syscall path, and write
to a file descriptor -- without libc, without a special `write` in the runtime,
and without the compiler knowing what `write` is:

```botlish
import abi
import linux
import str

data = abi::bytes::from_list(str::encode_utf8("Hello from Botlish!\n"))
linux::write(abi::i32(1), data)
```

```
String
  --str::encode_utf8-----------> List of bytes                (existing encoder)
  --abi::bytes::from_list-----------------> abi::bytes::Bytes                    (ordinary Botlish, opaque struct)
                                   hidden field: owned byte storage
  --linux::write---------------> address + abi::Usize length    (both from THE SAME Bytes)
  --abi::x86_64::from_bytes----> Register64 (rsi)               (raw bridge: address bits)
  --abi::x86_64::from_usize----> Register64 (rdx)
  --linux::abi::syscall--------> the x86-64 `syscall` instruction, rax = 1
  --> kernel write(2) --> descriptor 1
```

The standalone executable of `examples/linux/write.bot` writes exactly
`Hello from Botlish!\n` to descriptor 1 (then, being a standalone Botlish
program, prints its own result -- the 20 bytes written -- as its last line).
The kernel confirms where it came from: `strace -k` shows the write issued from
`botlish_linux_x86_64_syscall`, called by `rt_linux_x86_64_syscall`, called by the
Botlish function, with no libc frame anywhere in that call's stack (see
"Evidence").

```
$ strace -f -qq -k -e trace=write ./write
write(1, "Hello from Botlish!\n", 20) = 20
 > write(botlish_linux_x86_64_syscall+0x1f)
 > write(rt_linux_x86_64_syscall+0x493)
 > write(botlish_fn_7+0xd1)              <- linux::write
 > write(botlish_fn_0+0x3d)              <- the program
 ...
write(1, "20\n", 3) = 3                  <- the runner's own result line: libc __write
```

That chain -- not a complete FFI system -- is the milestone.

## Source surface

### `abi::bytes::Bytes` (lib/abi.bot)

```botlish
opaque struct Bytes:
    storage: any

fn bytes(values: List[Byte]) -> Bytes:
    Bytes {storage: byte_store::from_list(values)}

fn bytes_length(data: Bytes) -> Usize:
    Usize {value: byte_store::byte_count(data.storage)}
```

(`Byte` is `byte::Byte` via `import type byte::Byte`.) `abi::bytes::Bytes` is an
**opaque struct** (OPAQUE-STRUCTS.md): its one hidden field is the owned byte
storage, and only module `abi` can construct or project it. Nothing new was
invented for privacy.

| | |
|---|---|
| creator | `abi::bytes::from_list(values: List[Byte]) -> abi::bytes::Bytes`: the empty List gives the empty Bytes |
| length | `abi::bytes::length(data: abi::bytes::Bytes) -> abi::Usize` (already a valid native buffer extent; no caller re-proves `0 <= n <= 2^64-1`) |
| accepted bytes | exactly `byte::Byte` (`Int in 0..255`), by the ordinary typing of the parameter |
| not provided | slicing, indexing, concatenation, capacity, mutation, an address, a pointer, `is_heap`, NUL termination |

A `Bytes` is not a String, a C string, a pointer, a borrow, a resource, a
mutable buffer, an iterator or a null-terminated value. NUL is an ordinary
byte; the length is explicit and authoritative.

**Typing note.** `List[T]` admissibility is invariant (MINIMAL-APPLIED-LIST-
TYPES.md), so a bare literal `[1, 2, 3]` (a `List[int]`) is not a `List[Byte]`:
`abi::bytes::from_list([1, 2, 3])` is a compile-time TYPE error, exactly as the spec asks
for any list not statically known to hold bytes -- nothing is truncated,
wrapped, signed-reinterpreted or coerced. A byte List is written with the
existing checked conversion (`[byte::from_int(65), byte::from_int(0)]`, which
needs no handler for a constant in range), produced by a typed loop
(`loop i from 0 to n: byte::from_int(mod(i, 256))`), or comes from
`str::encode_utf8`, whose result is already a `List[Byte]`.

### `abi::x86_64::from_bytes` (core/bytestore.tcl; hir/syscall.tcl)

```
abi::x86_64::from_bytes(data: abi::bytes::Bytes) -> abi::x86_64::Register64
```

The narrowest raw bridge: it knows only "produce the machine address of this
contiguous Bytes payload, as register contents". It does not know `write`, does
not know which syscall argument it will become, and is not a pointer type:
`abi::bytes::Bytes` itself exposes no address, and the result is the same transport
value as every other register word (`Register64`: no arithmetic, no ordering).
It is a **root native** registered under its qualified name (like
`linux::abi::syscall`), because only module `abi` may project the storage out
of a `Bytes`; the native's static contract (`hir::syscall::BytesProblems`) is
that it takes exactly one argument whose static type is `abi::bytes::Bytes` (ARITY /
TYPE otherwise, no run-time check ever inserted) and that it is only ever
*called* (a reference to it that is not a callee is TYPE). A raw storage
(`byte_store::from_list(...)`), an Int, a String, or an `abi::U8` is a
compile-time TYPE error.

Native only: the address of a machine object exists only on the native
backend. The Tcl backends raise `NATIVE-ONLY` exactly as they do for
`linux::abi::syscall`, and nothing imitates an address.

### `byte_store::from_list` / `byte_store::byte_count` (core/bytestore.tcl)

The two natives that make and measure the storage value. `byte_store` is the
family namespace of the storage kind (as `immutable_set` is for
`ImmutableSet`). They do not give out a `Bytes` (constructing one outside
module `abi` is `OPAQUE-CONSTRUCTION`) and a raw storage yields no address, so
neither can manufacture a pointer. There is deliberately no operation that
reads, slices or iterates the bytes. (`byte_count` rather than `length`: a
member named `length` would make every `xs.length()` method-sugar hint also
suggest `import byte_store`.)

### `linux::write` (lib/linux.bot)

```botlish
import abi
import abi::x86_64
import linux::abi

fn write(fd: abi::I32, data: abi::bytes::Bytes) -> int:
    abi::x86_64::to_int(
        linux::abi::syscall({
            rax: abi::x86_64::register64(1),
            rdi: abi::x86_64::from_i32(fd),
            rsi: abi::x86_64::from_bytes(data),
            rdx: abi::x86_64::from_usize(abi::bytes::length(data)),
        })
    )
```

* **One `Bytes`, one source of truth.** There is no `count` parameter: a
  separate count could disagree with the buffer, and `write(fd, bytes, count)`
  is exactly the pointer/length mismatch a safe wrapper exists to rule out.
  The raw syscall still receives address and count in separate registers
  (machine reality); the Botlish function keeps the two facts coupled.
* **Register mapping** (the existing generic Linux x86-64 convention, never the C
  calling convention): `rax = 1` (SYS_write), `rdi = fd`, `rsi = the address of
  data's payload`, `rdx = data's byte count`; `r10 r8 r9 = 0`.
* **Result.** The kernel's raw signed `ssize_t` as an ordinary Botlish `Int`
  (`abi::x86_64::to_int`): `>= 0` is the number of bytes written; `< 0` is the
  kernel's `-errno`, preserved exactly (never reread as unsigned, never `-1`).
  An invalid descriptor is `-9` (EBADF). No errno mapping exists yet: this is the
  thin syscall-level wrapper, and a later wrapper can translate negative
  results into Botlish errors.
* **One write call.** A successful `write` may write fewer bytes than the Bytes
  holds (a pipe, a signal, a full disk). The wrapper makes exactly one syscall
  and returns exactly the kernel's result; it never loops or retries. Completion
  is a policy for a higher I/O abstraction. (NIR: exactly one
  `syscall_linux_x86_64` op, no branch, no loop; and a test provokes a **real**
  short write -- a non-blocking pipe filled to the point where the kernel accepts
  only part of an 81920-byte payload: `linux::write` returns exactly that short
  count, the pipe holds exactly the bytes the kernel took, and the next write
  returns the raw `-11` (EAGAIN).)
* **No retained pointer.** The address is taken and consumed synchronously by
  the syscall in the same function; the wrapper does not return, store or retain
  it. A kernel or library API that keeps the pointer after returning, a callback
  that uses it later, or a foreign thread that retains it are not supported here
  and belong to a future `opaque resource struct` with ownership anchoring --
  nothing of that was started.

## Semantics

* **Owned, eager.** `abi::bytes::from_list(values)` converts the List into storage the
  resulting `Bytes` owns, immediately. The List (or the String it was encoded
  from) is irrelevant afterwards; the Bytes is not a view of it and does not
  retain it. Even when the source is already an immutable List the model is
  eager conversion into ABI-compatible contiguous storage; a later optimization
  may reuse compatible storage without changing semantics. Once `abi::bytes::from_list`
  returns, the value independently provides the contiguous extent the ABI needs.
* **A value, not a pointer.** The semantic value is the bytes themselves.
  Backing address, inline-versus-heap representation, buffer identity,
  allocation identity and sharing identity are not observable. `b = a` is
  ordinary value use (`Bytes` is not affine or move-only); `[a, a]` is fine; the
  implementation may copy or share. There are no reference counts.
* **Equality and hash are by the bytes.** `abi::bytes::from_list([a, b]) == abi::bytes::from_list([a,
  b])` is `true`; `[a, c]` is `false`; a prefix, a longer Bytes, the empty Bytes
  and a NUL-padded Bytes are all unequal. Two storages never compare by
  identity or address. `hash` is consistent with it, and the *values* of the
  hash (not just their consistency) agree on all four backends: the byte count
  as 8 little-endian bytes, then every byte, under kind tag 9. A `Bytes` in a
  `List` or an `ImmutableSet` deduplicates and compares by the same rule. This
  needed no custom operator overloading: opaque structs compare structurally by
  their fields, and the one field is a *byte storage value*, a runtime kind whose
  generic equality/hash is value-oriented (below).
* **Rendering** follows the opaque-struct rule on every backend, alone or nested:
  `<opaque abi::bytes::Bytes>` -- no address, allocator metadata, heap id or storage
  bytes. The explicit internal reveal (the test harness's differential printer)
  shows `abi::bytes::Bytes {storage: <bytes 3: 4100ff>}`, which is how backends are
  compared byte for byte.
* **Length.** One exact byte count. UTF-8: `abi::bytes::length(abi::bytes::from_list(
  str::encode_utf8("héllo ☃ \U0001f600")))` is `15`, the encoded byte
  count, while `str::length` of the String is `9`.
* **Empty.** `abi::bytes::from_list([])` has length 0. The representation does not promise a
  null address and `null` has no semantic significance (Botlish still has no
  `null`); a zero-count write is tested not to depend on what address a
  zero-length payload happens to have (it is a valid one-past address; a
  zero-length write to an invalid descriptor still returns EBADF, proving the
  syscall happens).
* **Not C strings.** `41 00 42` has length 3 and writes exactly `'A', NUL, 'B'`
  (checked on the kernel side with `strace`, which prints `write(3, "A\0B", 3)`);
  nothing scans for a terminator. `CString` is a future, distinct abstraction.

## Representation

### Layers

```
HIR / semantic        abi::bytes::Bytes: opaque struct {storage: any}   (a one-field struct)
Tcl backends          {struct {abi::bytes::Bytes storage} {{bytestore HEX}}}
                      the storage is a distinct value kind {bytestore HEX}: lowercase
                      hexadecimal text, two digits per byte (the empty storage is
                      {bytestore {}}); equality = string equality of the hex; hash as above
native NIR            one-field struct, scalar-replaced (below); the field is a Value
                      pointing at a KIND_BYTES heap object (or a static constant)
```

The field is typed `any` because no source type spells the storage; every native
that accepts one checks its kind at run time (`rt_bytes_len`, `rt_bytes_addr`
refuse anything else with TYPE), and the only way a storage reaches a `Bytes`
field is `abi::bytes::from_list` itself (an opaque construction nobody else may write).

### Native heap object (runtime/bytesobj.rs)

```
offset  size  field
     0     8  hdr      Header { kind = KIND_BYTES (13), marked, is_static, pad }
     8     8  len      exact byte count
    16     n  payload  the bytes, no trailing NUL
```

* **One allocation** holding header + length + payload: `object -> pointer ->
  second allocation` does not occur. Size `16 + len` rounded up to 16.
* **Length representation:** the 8-byte `len` field; `len <= MAX_COLLECTION_LENGTH`
  (2^62 - 1, checked before allocation: RANGE), so the length always fits a small
  Int and hence an `abi::Usize`; `-result-range collection-length` is therefore a
  real checked fact, which is why `Usize {value: byte_count(...)}` needs no
  proof obligation from callers.
* **Payload alignment:** 16 bytes (the allocation is 16-aligned and the payload
  starts at +16). The payload address is `object address + 16` whatever the
  length: O(1), with no read of the payload.
* **GC tracing:** none. The payload contains no Botlish references; the collector
  marks the object (header only) and frees it with the layout it was allocated
  with (`bytes_layout`). It never scans the payload. The collector is non-moving, so
  an address taken from a live storage stays valid for as long as the object is
  live.
* **No List retained.** The conversion copies the values into the payload; the
  object holds nothing else, so the source List is garbage immediately.
* **No threshold, no capacity.** There is no inline-versus-heap frontier visible
  anywhere in the semantics (`is_heap`, `capacity`, `address` do not exist), and
  no spare capacity.

### What is optimized, and what is not (measured)

Allocation counts (`native::allocationReport`, in-process, specialized backend;
"List" is the *source* byte List, garbage after construction):

| program | Bytes storage | wrapper (Struct) | List | notes |
|---|---|---|---|---|
| `out(3, abi::bytes::from_list([]))` | 0 | 0 | 0 | the shared **static** empty storage; total allocations 0 |
| `out(3, abi::bytes::from_list(str::encode_utf8("hello\n")))` | 0 | 0 | 0 | a **static constant** (`bytes "68656c6c6f0a"`): no List, no String, no heap buffer; total 0 |
| `out(3, abi::bytes::from_list([byte::from_int(1), byte::from_int(2)]))` | 0 | 0 | 0 | a static constant as well |
| `out(3, mk("hello\n"))` (dynamic) | 1 | 0 | 1 | the Bytes wrapper is scalar-replaced; writing allocates nothing more |
| same, 5120 and 163840 bytes | 1 | 0 | 1 | one object of `16 + n` bytes, whatever n |
| `a = mk(..); b = a; out(a); out(b); out(a)` | 1 | 0 | 1 | aliasing allocates nothing |
| `a` stored in a List and written | 1 | 1 | (loop) | the one case that builds the one-field wrapper |
| unspecialized (`-specialize 0`) | 1 | >0 | | the generic baseline materializes the wrapper (and the Register64 transport) where it carries values across calls; the storage is still one allocation |

* **Optimized:** (1) the wrapper `Bytes` struct disappears under the existing
  struct scalar replacement: `abi::bytes::from_list` returns the storage as its one field,
  `abi::bytes::length(data.0)` is one `op byteslen`, a Bytes passed to
  `linux::write` is a virtual parameter. (2) The empty Bytes is one shared
  static object. (3) **Static constants:** `abi::bytes::from_list` of a compile-time-known byte
  sequence (`str::encode_utf8` of an exactly known String of any length -- empty
  or non-ASCII included -- or an exactly known List of constant bytes
  / `byte::from_int` of a constant) lowers to `%b = bytes "HEX"`, a program-lifetime
  object installed at startup: **no heap buffer, no List, no run-time conversion**.
  Source semantics are unchanged (a Bytes has no identity), and the AOT
  executable embeds the bytes as a `\xNN` byte-string literal.
* **Not optimized (reported, not hidden):** a *dynamic* small Bytes is a heap
  object (there is no stack/scratch/inline form for it: the existing escape machinery
  does not span the `linux::write` call boundary, and building that was out of
  scope); conversion from a List is an eager copy (the source List is built first:
  one List + one Bytes); a `Bytes` stored in a List or a module static binding
  materializes its one-field wrapper; and `abi::bytes::from_list` of a List that is not
  statically known (a parameter, a loop result) is the generic runtime
  conversion. (Collecting loops build their result List with one allocation
  per iteration in the native backend -- `pattern(n)` allocated n+1 Lists --
  which is existing behavior, unrelated to this change, and why the large-payload
  tests build big Bytes from a doubled String instead.)
* **Compiler facts.** Within one expression the length range is
  `[0, 2^62-1]` (`collection-length`). The *exact* length of `abi::bytes::from_list([b1, b2,
  b3])` is not propagated to `abi::bytes::length(data)` across the function
  boundary: that would be a field fact about an opaque struct crossing an
  interprocedural boundary (G5), which this milestone does not build.

## The raw address bridge and liveness across the syscall

When the raw address of a payload is passed to `linux::abi::syscall`, the
backing storage must stay valid and unmoved until the syscall returns, under GC
stress, allocation immediately before the syscall, specialization, generic
lowering, inlining and scalar replacement. This is **explicit in the lowering
(native/lower.tcl), not an accident of the register allocator or of a variable's
lexical lifetime**:

* The collector never moves objects, so *validity* only requires liveness.
* `abi::x86_64::from_bytes(d)` lowers to `%b = <the storage of d>; %a = op
  bytesaddr %b` (`BytesAddrCall`). `%a` is the Register64's one word.
* The lowering records that `%a` points into `%b` (`fn keepAddr`, a map from a
  register to the storages whose address it may hold). That provenance flows,
  within one function, through everything that carries an address: a Register64
  object (`structnew`), a register struct bound to a local, a field read back
  (`structget`), a List holding one, an `if` merge (`JoinKeepAddr`), and calls to
  ordinary Botlish functions -- a call returning a Register64 from a `Bytes`
  argument tags its result with that argument (a helper such as `fn
  addr_of(d): from_bytes(d)`), and a call that *takes* an address keeps the
  storages alive until it returns, since the callee may make the syscall.
* `SyscallCall` then emits **`op keepalive %b` after the syscall** for every
  storage carried by any of its operands. `keepalive` is a real helper call
  (never removed, never moved by Cranelift: a side-effecting call), so `%b` is a
  live GC root from its definition through every safepoint -- including the
  syscall's own -- until the kernel has returned. The wrapper function
  `linux::write` has one `keepalive`, the same register `bytesaddr` took.

```
func 7 "linux::write" params=2 ...                  ; data is the virtual field data.0 = %1
    %4 = callmulti 3 %2          ; abi::x86_64::register64(1)
    %5 = callmulti 5 %0          ; abi::x86_64::from_i32(fd)
    %6 = op bytesaddr %1         ; the address: rsi
    %7 = callmulti 2 %1          ; abi::bytes::length(data)
    %8 = callmulti 6 %7          ; abi::x86_64::from_usize(length): rdx
    %9 = int 0
    %10 = op syscall_linux_x86_64 %4 %5 %6 %8 %9 %9 %9      ; rax rdi rsi rdx r10 r8 r9
    %11 = op keepalive %1        ; the storage stays live across the syscall
    %12 = call 4 %10             ; abi::x86_64::to_int
    ret %12
```

* **Verified, not argued:** a test builds the raw layer directly -- the address of
  a `Bytes` nothing else references, evaluated one register *before* another
  register word that allocates a same-sized Bytes -- and runs it 30 times under
  `BOTLISH_NATIVE_GC_STRESS=1`, in six routes by which the address can reach the
  syscall (inline, bound locals, a register struct bound to a local, a helper
  function's result, an `if` merge, a callee that makes the syscall). The same
  program with the `keepalive` deleted from its NIR is a *mutant the test fails*:
  the freed first storage's block is reused by the second, and the kernel
  receives the second's bytes. Without the new provenance rules the register
  struct and helper routes also corrupted (observed before they were added).
* **Classification of the address as it escapes.** The address is raw-machine
  territory analogous to `Register64`: it is an `Int` word in a register. It *can*
  leave the function (returned, stored in a List or a module binding); the
  lowering tracks provenance through the routes above, **not** through a value
  stored in a module static or captured by a closure, nor merged by anything but
  `if`. That is the raw layer's sharp edge, deliberately: the safe wrapper
  theorem is that `linux::write(fd, data)` takes the address from `data`, makes
  the syscall synchronously while `data` is live, and neither exposes nor retains
  the address. Raw `Register64` programs are not made memory-safe in general; keep
  `from_bytes` and the syscall in one function and the guarantee is exact.
  Future `direct`/raw-ABI restrictions may narrow these operations further; that
  policy is not implemented here.
* **Not a lifetime or borrow system.** There is no lifetime syntax, no affine
  value, no borrow checker: `keepalive` is an internal NIR operation, and the
  language has no way to spell it.

### Effects (unchanged)

`linux::abi::syscall` stays generic: seven registers in, the `syscall`
instruction, raw rax out; the compiler still knows no syscall number
(`write` is `rax: register64(1)`, ordinary data in `lib/linux.bot`). Its strong
memory/effect barrier is preserved and matters more now that the kernel reads
Botlish-owned memory: it is a real helper call (Cranelift treats it as reading
and writing all memory, never merges, hoists, reorders or deletes it) and a
GC safepoint; the payload is fully written before the address is taken because
the storage is created by `abi::bytes::from_list` before any use (`bytesfromlist` or a
static constant precedes `bytesaddr` in dependence order), and nothing can reuse
scratch storage because there is none. `byte_store::from_list` is
`-context-free 1`, so a module binding may be initialized with a Bytes;
`abi::x86_64::from_bytes` is not context-free (an address is a property of one
run) and `linux::write` is never foldable.

## Backend support

| | interp | compile | cranelift-generic | cranelift / standalone |
|---|---|---|---|---|
| `abi::bytes::from_list`, `abi::bytes::length`, `==`, `hash`, rendering, aliasing, collections | yes | yes | yes | yes |
| `abi::x86_64::from_bytes` | `NATIVE-ONLY` | `NATIVE-ONLY` | yes (Linux x86-64) | yes (Linux x86-64) |
| `linux::write` | `NATIVE-ONLY` | `NATIVE-ONLY` | yes | yes |

Nothing fakes `write` on the Tcl backends with `puts`, a Tcl channel or libc
(a test greps `core/` and `lib/` for exactly that). Only the *call* is refused,
when it runs: a program that defines `emit()` calling `linux::write` but never
calls it runs everywhere.

## Evidence

All of it is run, not asserted from source.

* **NIR** for the canonical write path (above): `bytesfromlist`/`byteslen` in
  their instances, `bytesaddr` over the storage, the `from_i32`/`from_usize`
  encodings, exactly **one** `syscall_linux_x86_64` op taking
  `rax = register64(1) word, rdi = fd word, rsi = THE bytesaddr result, rdx = length
  word, 0 0 0` (checked register by register), a `keepalive` of `bytesaddr`'s own
  operand, then `to_int`. For a constant, one `bytes "68656c6c6f0a"` and no
  `bytesfromlist`.
* **Machine code** (`objdump` of the standalone executable's `linux::write`):
  `call rt_bytes_addr` with rsi = r12 (the storage), then `call
  rt_linux_x86_64_syscall`, then `call rt_keepalive` with rsi = r12 again; no call to
  libc `write`, `send` or `syscall(3)` in it. `rt_linux_x86_64_syscall` reaches
  `botlish_linux_x86_64_syscall`, whose register routing (earlier milestone) puts
  `rax rdi rsi rdx r10 r8 r9` where the kernel wants them; the whole executable
  still has exactly one `syscall` instruction.
* **The kernel's own view** (`strace`, optional in the suite): `write(1, "Hello
  from Botlish!\n", 20) = 20` (rdi = 1, the payload's actual bytes at rsi -- strace
  decodes them from the pointer -- and rdx = 20) with the user-space stack
  `botlish_linux_x86_64_syscall <- rt_linux_x86_64_syscall <- botlish_fn <- botlish_fn`,
  no libc `__write`; `write(3, "A\0B", 3) = 3` for the NUL payload; `write(3,
  "\xc3\xa9\xe2\x98\x83", 5) = 5` for a two-scalar String (count = encoded bytes).
  The only libc write in the process is the runner's own result line.
* **Libc is not the implementation path:** Rust std imports libc's `write` for the
  runner's own printing, so "`write` is not an imported symbol" would be false; the
  evidence above (call targets of the Botlish function, the stack in the kernel's
  record) is the precise statement.

## Tests and fuzzing

`tests/abi-bytes.test` (73 tests, all green in a normal run, under
`BOTLISH_NATIVE_GC_STRESS=1` and under `CORE_BACKEND=compile`):

* registration (three natives, no write/keepalive/pointer native), the declaration;
* **every backend**: length (empty, NUL anywhere, UTF-8 bytes-not-scalars),
  `abi::Usize`, equality by bytes, hash consistency *and hash values agreeing*,
  aliasing, collections (`List`, `ImmutableSet`), eager independence of the source,
  large values, rendering, the internal reveal, opaque construction/projection/
  destructuring diagnostics, no accessor surface, typing (non-byte lists rejected
  statically, an untyped parameter rejected, `-strict 0` still TYPE at run time);
* the bridge's static contract, its `-strict 0` replay, NATIVE-ONLY on the Tcl
  backends, no fake write;
* **native** (standalone executables with descriptors 3/4 redirected by the shell,
  read back as binary): the example's stdout; static and dynamic writes; the empty
  write (and its EBADF twin); embedded NUL (start, middle, end); UTF-8; an 81920-byte
  heap payload; every byte value; a write to a real pipe (163840 bytes, exceeding
  the pipe buffer); repeated and aliased writes; the raw negative result (-9);
  exactly one syscall;
* a real short write (above) and the raw -EAGAIN;
* **GC stress**: 40 rounds of mixed writes exact; in-process runs identical with and
  without stress; the six liveness routes; the keepalive mutant is detected;
* NIR/allocation/object-layout/machine-code/`strace` evidence as above.

Rust unit tests (`cargo test --release`: 174 + 28): the object layout and
alignment, payload round trip with NUL and high bytes, the empty storage, partial
publication refused, `rt_bytes_from_list` exactness and its TYPE errors (a
256, -1, 2^40, a String, a BigInt), length/address refusing a non-storage, the
address = object + 16, equality by bytes (never identity), the documented hash,
rendering and host value, collection, the oversize RANGE error.

`audit/abi-bytes/tools/fuzz.tcl` (differential, against an independent Tcl
byte-sequence oracle): see "Fuzz results". `audit/abi-bytes/tools/mutate.tcl`:
twelve mutants of exactly the failures this boundary is prone to -- see
"Mutation results".

## Limitations discovered

* **No dynamic small-`Bytes` fast path** (stack/scratch/inline): see above.
* **Literal byte Lists** need `byte::from_int` per element (invariant `List[T]`).
  Observed (an existing limit, unrelated to `abi::bytes::from_list`): past roughly 1,500-2,000
  constant `byte::from_int(N)` calls in *one program*, later calls lose their
  call-specific completion proof (`this call may produce the declared error
  "AboveRange"` for a literal 67): four 256-element literals compile, eight do not.
  The fuzzer's generated programs therefore build their Lists with closed-form
  loops instead of per-byte literals.
* **`import abi` now loads `byte`** (for `Byte` in `abi::bytes::from_list`'s signature): the
  `byte::` types and the global errors `BelowRange`/`AboveRange` are part of every
  program that imports `abi`, so such a program cannot declare its own `error
  BelowRange` (error names are global). `abi`'s numeric domains themselves are
  unchanged.
* **A module-level binding cannot hold a `Bytes`**: module binding initializers
  must be context-free scalars/Lists (an existing rule: a struct is not an
  accepted initializer), so `payload = abi::bytes::from_list(...)` in a library module is
  rejected (`module binding initializer must be context-free`). A Bytes lives in
  entry-program bindings, arguments, closures and Lists (all tested).
* **Collecting loops allocate a List per iteration natively** (existing), so a
  loop-built 70000-byte List takes seconds; not caused by this change.
* **Exact length is not propagated across `abi::bytes::length`.**
* **Provenance is intra-function** (above): an address merged by anything but `if`,
  stored in a module static or captured by a closure loses its keepalive.
* **The standalone runner always prints its result**, so the example's stdout is
  the message then `20`.
* **Truncation of a Usize count to U32** could only be observed with a 4 GiB payload;
  the mutation test uses 2^16 (the smallest truncation the tests' payloads reach).

## What remains before ...

* **`MutableBytes`** (done: see MUTABLE-BYTES.md; the text below is the plan this milestone was written against): a writable storage kind (the byte storage here is immutable by
  construction, and `Bytes` equality/hash rely on that); `read(2)` needs a pointer
  the kernel *writes* through, so the same address bridge needs a writable variant, a
  mutation API on an opaque owner, and a decision about aliasing a mutable value
  (this milestone's "aliasing is legal" rests on immutability). The byte-storage
  object, its liveness story and the syscall effect barrier carry over.
* **`CString`**: a distinct opaque value built on this storage (an extra trailing
  NUL the storage does not have today, embedded-NUL validation, `strlen`
  conversions); the object layout has room for it (payload length vs. content
  length), nothing was added.
* **Retained-pointer `opaque resource struct` APIs**: ownership anchoring (`with`,
  mutable context storage), a lifetime longer than one synchronous call, a way for the
  collector to keep storage alive while foreign code holds the pointer (pinning is
  free here: the collector never moves objects, only liveness is needed), destructors,
  and the future `direct`/raw-ABI restrictions on the operations that expose
  addresses.

## Milestone report

1. **`abi::bytes::Bytes` declaration:** `opaque struct Bytes:` with the one hidden field
   `storage: any` (lib/abi.bot).
2. **Creator:** `abi::bytes::from_list(values: List[Byte]) -> abi::bytes::Bytes`.
3. **Accepted source bytes:** exactly `byte::Byte` (0..255), by the parameter's
   `List[Byte]` typing; ordinary diagnostics otherwise.
4. **Eager conversion:** `byte_store::from_list` copies into an owned storage when
   `abi::bytes::from_list` is called; no view, no retention (or a static constant for a
   compile-time-known sequence).
5. **Equality/hash:** by the bytes; hash = byte count (LE u64) then the bytes under
   kind tag 9; identical values on all four backends.
6. **Length:** `abi::bytes::length(data) -> abi::Usize`.
7. **Hidden representation:** an opaque one-field struct over a `bytestore` value
   (`{bytestore HEX}` in Tcl; a `KIND_BYTES` object natively).
8. **Inline/stack/static:** static constants (compile-time-known bytes) and the shared
   static empty storage; no stack/scratch/inline form for dynamic values.
9. **Heap representation:** one contiguous allocation (16-byte header + payload).
10. **Threshold/frontier:** none; static vs heap is a lowering fact only.
11. **Aliasing:** ordinary value copy of the (scalar-replaced) field or the one
    pointer; no copy of the payload, no identity.
12. **Empty representation:** the shared static empty object; the payload address
    is one-past-the-header, legal for count 0; no null.
13. **Heap object layout:** `hdr(8) | len(8) | payload`, payload at +16, 16-aligned;
    one allocation; length is the stored `len`; no tracing of the payload.
14. **GC tracing/liveness:** marks only (no children); non-moving collector;
    liveness through the syscall by `keepalive` (above).
15. **Raw bridge:** `abi::x86_64::from_bytes(data) -> Register64` (native
    `bytesaddr`).
16. **Why the backing stays valid:** non-moving collector + a `keepalive` of the
    storage after every syscall that takes an address derived from it, tracked in
    the lowering (six routes tested, mutant detected).
17. **Does the address escape:** it is a Register64 word and may leave the
    function; provenance is tracked through the listed routes, not through module
    statics/closures; classified as raw-machine territory, documented.
18. **`linux::write`:** as above.
19. **`lib/linux.bot` imports:** `abi`, `abi::x86_64`, `linux::abi`.
20. **Register mapping:** `rax=1, rdi=fd, rsi=address, rdx=count, r10=r8=r9=0`.
21. **Return value:** the kernel's raw signed result as an Int (`to_int`).
22. **Short writes:** one syscall, the kernel's result returned unchanged.
23. **Stdout example:** `examples/linux/write.bot`.
24. **Embedded NUL:** tested at the file and `strace` levels (`41 00 42`, 3 bytes).
25. **UTF-8:** count = encoded bytes (`15` for the 9-scalar example; `5` for two scalars
    on the wire).
26. **Empty write:** result 0, no output; EBADF for a bad fd.
27. **Large heap-backed write:** 81920 bytes to a file, 163840 bytes to a pipe, all
    bytes verified.
28. **Repeated/aliased writes:** identical bytes every time.
29. **Invalid-fd result:** `-9` (EBADF), preserved negative.
30. **NIR evidence:** above (one syscall op; operand order checked).
31. **Machine-code evidence:** above (calls, rsi source, no libc call; one `syscall`).
32. **libc `write` not used:** the Botlish write has no libc frame (strace stack) and no
    libc call in its machine code; Rust's runner prints its result line with libc.
33. **Allocation counts:** the table above.
34. **GC-stress results:** see "Regression".
35. **Pure fuzz:** see "Fuzz results".
36. **Syscall fuzz:** see "Fuzz results".
37. **Full regression:** see "Regression".
38. **Optimization limitations:** above.
39. **Before `MutableBytes`:** above.
40. **Before `CString`:** above.
41. **Before retained-pointer `resource struct`:** above.

## Fuzz results

`audit/abi-bytes/tools/fuzz.tcl`, recorded in `audit/abi-bytes/fuzz-result.txt`.
Each program is seeded individually (a failure replays with `-seed S -n 1`) and
draws random byte sequences biased toward the shapes that matter: empty, one
byte, the sizes around 7/8/9, 15/16/17 and 31/32/33 (where a small inline
representation would end and a heap buffer begin), embedded zeros, `0xff` and
the high half, ASCII, arbitrary 8-bit data, UTF-8 text, and buffers up to a few
thousand bytes.  The oracle is an independent Tcl byte-sequence model; it never
reads what the program computes.

| run | what | result |
|---|---|---|
| `-mode both -n 40 -seed 1 -items 8` | pure on interp, compile, cranelift-generic and cranelift (length, every byte in order, equality/hash consistency, up to four mutants per sequence against the oracle's own verdict, aliasing; the shown result identical on all four) **and** one standalone write program per seed run normally and under GC stress, file and pipe contents byte-exact and every returned count exact | 40 programs, 320 payloads, **0 failures** |
| `-mode pure -n 30 -seed 9001 -items 8` | the same pure checks, a second seed range | 30 programs, 240 payloads, **0 failures** |
| `-mode write -n 20 -seed 5001 -gc-stress 1` | writes under GC stress for the whole process | 20 programs, 160 payloads, **0 failures** |
| `-mode write -n 80 -seed 9001 -items 10 -gc-stress 1` | the same, a larger run | 80 programs, 800 payloads, **0 failures** |

Totals: 190 programs, 1520 payloads, 0 failures.  The only syscall is `write(2)`
to a temporary file and to a pipe the harness reads; no syscall number is ever
generated.

Failures met while building the fuzzer were all in the fuzzer, none in the
product (a differential test is only as good as its oracle): a literal writer
using an escape Botlish strings do not have; a mutant index drawn with `rand()`
for the program and again for the oracle, so the two compared different bytes
(seed 9023 failed identically on all four backends, which is what pointed at the
oracle); and a first generator that hit the compiler's existing proof budget at
about 1500-2000 constant `byte::from_int` calls, so the generators are
closed-form (one call per sequence).

## Mutation results

`audit/abi-bytes/tools/mutate.tcl`, recorded in
`audit/abi-bytes/mutate-result.txt`.  Twelve mutants, each breaking one thing a
memory-moving syscall wrapper is prone to get wrong, run in a scratch copy of
the tree (Rust mutants rebuild the native backend there) against
`tests/abi-bytes.test` and the write fuzzer: **12 killed, 0 survivors**.

| mutant | killed by |
|---|---|
| `length-off-by-one` (length accessor + 1) | 31 tests, fuzzer |
| `nul-as-terminator` (creation stops at the first zero) | 7 tests, fuzzer |
| `payload-offset-by-one` (bridge returns address + 1) | 22 tests, fuzzer |
| `byte-masked-to-7-bits` (creation stores `b & 0x7f`) | 8 tests, fuzzer |
| `count-truncated` (count register carries `length mod 2^16`) | 4 tests (large heap write, short write, pipe, NIR) |
| `no-keepalive` (no keepalive after the syscall) | 11 tests (all liveness shapes, CLIF stack map, the mutant detector) |
| `address-in-rdx` (address and count registers swapped) | 17 tests, fuzzer |
| `libc-write` (boundary calls libc `write` for `rax = 1`) | 6 tests: the raw-negative-result tests (libc returns `-1`) and the strace stack test |
| `write-twice` (wrapper makes the syscall twice) | 18 tests, fuzzer |
| `equality-by-identity` (native equality compares objects) | 7 tests |
| `hash-ignores-length` (native hash omits the count) | 1 test (the one comparing the hash *value* with the documented one) |
| `static-constant-ascii` (static constants encoded as ASCII) | 3 tests (length is bytes, NIR static forms, UTF-8 write) |

Two honest caveats.  `count-truncated` is a 2^16 truncation, because the
real bug it stands for (a `Usize` count squeezed through `U32`) is only
observable at 4 GiB, which no test writes.  And `hash-ignores-length` is caught
by one test only: equal values still hash equal without the length, so only a
test pinning the hash value can see it.

The tool is itself guarded: it refuses a Tcl-side mutant whose example does not
compile (an earlier `count-truncated` was such a vacuous kill and was rewritten)
and runs each mutant from inside its own copy of the tree, because tcltest
keeps its scratch directories in the working directory.

## Regression

Every run below is the whole suite in a clone of the tree at the named commit,
with the native backend rebuilt there (`cargo build --release`), under
`LANG=C.utf8 LC_ALL=C.utf8`.

| run | command | result |
|---|---|---|
| interpreter | `CORE_BACKEND=interp tclsh9.0 tests/all.tcl` (33990d5) | 5545 tests, **5545 passed**, 0 failed |
| Tcl compiler | `CORE_BACKEND=compile tclsh9.0 tests/all.tcl` (f79effc) | 5545 tests, **5541 passed**, 4 skipped (the `coreScoping` constraint, as for every run on that backend), 0 failed |
| native/cranelift coverage | `tclsh9.0 tests/native-coverage.tcl` (33990d5) | 5579 tests: 2362 ran native, 3087 independent of the backend, 70 passed-partial, 60 unsupported (needing constructs native does not run, none of them abi-bytes), **0 failed** |
| GC-stress suite | `BOTLISH_NATIVE_GC_STRESS=1 CORE_BACKEND=interp tclsh9.0 tests/all.tcl` (f79effc) | 5545 tests, **5545 passed**, 0 failed |
| Rust | `cargo test --release --manifest-path native/Cargo.toml` (f79effc) | **174 + 28 passed**, 0 failed |

The named areas, each file on its own (33990d5): `opaque-struct` 142/142,
`imports` 102/102, `abi-numeric` 41/41, `linux-syscall` 37/37,
`stdlib-namespaces` 74/74, `proven-bounds` 24/24, `proof-loop-intervals` 13/13,
`checked-domain-proof-provenance` 18/18, `hir-range` 60/60, and
`abi-bytes` 73/73 in a normal run, 73/73 under `BOTLISH_NATIVE_GC_STRESS=1` and
73/73 under `CORE_BACKEND=compile`.

Two commits appear because the first complete pass found one failure, in this
milestone's own test: `abi-bytes-short-write-is-reported-not-completed` read
the pipe it was testing while the program was still writing to it, so under
load the harness drained the pipe, the second write fitted entirely (65536) and
the "the kernel can only partly accept it" premise failed (the interpreter run
and the native-coverage run failed that one test; the compile and GC-stress runs
passed it by timing).  It was a race in the test, not in the product; the test
now waits for the program's result line before reading, failed 2 of 6 runs in
the old form under CPU load and passes 16 of 16 in the new one.  Commit
33990d5 changed that one test (and a description) and nothing else, so the runs
that had passed (compile, GC stress, `cargo test`) were not repeated; the two
that had failed were repeated in full and are green.

The standing GC-stress job of `.github/workflows/tests.yml` runs the suite
the same way on every push to `main`.  `abi-bytes.test` itself contains the
stress runs that matter for this milestone: 40 rounds of mixed writes exact,
the six liveness shapes under stress, and the deliberately keepalive-less
mutant detected (a mutant the mutation run also kills).

The scalar assembly audit corpus (`audit/native-scalar-asm/`) is regenerated by
its own workflow on every push to `main` that touches the compiler or the
runtime; it was not regenerated by hand here.
