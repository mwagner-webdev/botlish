# C-FFI-ERROR-CAPTURE-MILESTONE-1.md

Deferred write-back materialization and allocation-free foreign error
capture: a C call's error state survives the representation of its result.

> A C call must not lose its error state because Botlish constructs a value
> representing the call's result. Keep the foreign result and updated
> borrowed storage available without heap materialization until the program
> actually needs their materialized representation.

MACOS-AARCH64-MILESTONE-8.md, section 7, found that `darwin::read` built its
write-back value -- two heap objects -- between `read(2)` returning -1 and
the read of `errno`, and relied on Apple's allocator leaving errno alone.
This milestone removes the dependency in the compiler, for every C call and
every platform: the write-back value is now fields, built only where a use
needs an object, and the `keepalive` after a C call is no machine code. No
syntax, type, NIR instruction, runtime object, errno knowledge or Darwin
rule was added.

## Result

```botlish
fn read(fd: ffi::c::Int, data: abi::bytes::MutableBytes) -> ReadResult:
    r = fd.c_read(data, abi::bytes::mutable_length(data).value)
    if r.result < 0:
        failure = errno()
        return ReadResult {count: r.result, errno: failure, data: r.buf}
    ReadResult {count: r.result, errno: 0, data: r.buf}
```

lowers, on both native lowerings, for every target, to

```text
    %3 = op mbytesclone %1          ; the detach: the private copy C writes
    %4 = op mbytesaddr %3
    %5 = foreigncall 0 %0 %4 %2 exposed=1
    %6 = op keepalive %3            ; no machine code
    %9 = op ilt %5 %7               ; r.result < 0
    br %9 L0 L1
  label L0
    %11 = call 4                    ; errno()
    %12 = structnew 0 %3            ; r.buf -- the MutableBytes, after errno
```

where it lowered to `foreigncall`, `keepalive` (a runtime call), `structnew`
(the MutableBytes), `structnew` (the `{buf, result}` struct), `structget`,
`ilt`, `call errno`. Single-stepping the Linux x86-64 executable from the C
call's return to the load of errno now executes 57 instructions -- the
wrapper's comparison and branch, `errno()`'s entry, glibc's
`__errno_location` and `errno()` again up to the load -- where it executed
917, 545 of them in glibc's `malloc` (section 13). With an allocator that sets
errno to 77 on every allocation, the old lowering's `read` reports errno 77;
the new one reports the call's own (section 22).

What changed:

* **hir/escape.tcl**: a foreign call with a write exposure is a recognized
  construction of its write-back struct (`WriteBackResult`), like a struct
  literal or a syscall's Register64; its MutableBytes fields are nested
  values (`WriteBackTree`, also as a literal's field: `LiteralTree`) that a
  representation class opens even where a use reads them whole, provided
  that use runs as often as the binding (`NestingPlan`'s lazy paths); a
  write-back read straight off its call opens them too (`WriteBackCut`).
* **native/lower.tcl**: `BorrowCall` hands the write-back back as fields
  (the C result, each opened MutableBytes' storage) when its consumer wants
  it virtual; a field read whole that the cut opened is built at that use
  (`FieldValue`, `OpenedFieldObject`, cached per dominating scope and reused
  by a later materialization of the whole); an opened buffer handed to
  another foreign call is read for its storage alone (`OpenedOwnerStorage`);
  `Call`, `CallInner`, `VirtualValue` and `TryFields` carry the cut to the
  call.
* **native/src/codegen/clif.rs**: `op keepalive` emits nothing; the root
  plan's liveness (unchanged: the NIR use) keeps the storage a root. The
  helper `rt_keepalive` is gone.
* **tests/c-ffi-error-capture.test** (16 tests), tests/cffi/window.tcl (the
  NIR and machine-code window detectors), tests/cffi/window-trace.c (a
  ptrace single-stepper), tests/cffi/errno-clobber.c (an allocator that
  changes errno), four errno functions in tests/cffi/fixture.c,
  `cb-write-back-allocations`, `di-errno-allocator`, ten mutants,
  bench/c-ffi-error-capture.tcl.

## 1. Initial compiler behavior

A call of a C function with a `write noescape` byte parameter
(C-POINTER-BORROWING.md, section 6) detaches the caller's MutableBytes into
a private copy, exposes the copy's address, calls C, keeps the exposed
storages alive and evaluates to the write-back struct

```
{result: R, NAME: abi::bytes::MutableBytes, ...}
```

`native::lower::BorrowCall` built that struct right after the call, always
(unless the call was a statement): one `structnew` per written parameter's
MutableBytes over its copy, one for the struct. Escape analysis
(`hir::escape::Classify`) did not recognize the call as a construction, so
no consumer could take the value as fields; a projection `r.result` read it
back with `structget`. And `op keepalive` was a call of the runtime helper
`rt_keepalive` (a `black_box` of its operand), there so that "a real call is
never removed".

The machine code of the window, in order: the C call, the boxing of its
64-bit result (inline for a small Int, `rt_ffi_box_i64` otherwise), the call
of `rt_keepalive`, two calls of `rt_struct_new` -- each through Rust's
global allocator into the system `malloc`, and a GC safepoint (a collection
attempt under `BOTLISH_NATIVE_GC_STRESS=1`, whose frees ran there too) --
then the comparison and the branch to `errno()`.

## 2. The reproducer

`darwin::read` (lib/darwin.bot, MACOS-AARCH64-MILESTONE-8.md, section 6), above,
compiled for macos-aarch64 from Linux (`native::nir`), and its exact twin
over glibc's `read` and `__errno_location` compiled for linux-x86_64 and run
as an executable: the binding `ec` of tests/c-ffi-error-capture.test
(`ec::read`), whose own NIR is the same instruction for instruction.

## 3. The original optimized NIR

darwin::read, specialized (cranelift), before:

```text
func 5 "darwin::read" params=2 ... pnames="fd data.0" results=3
    %2 = callmulti 3 %1             ; abi::bytes::mutable_length(data)
    %3 = op mbytesclone %1
    %4 = op mbytesaddr %3
    %5 = foreigncall 0 %0 %4 %2 exposed=1
    %6 = op keepalive %3
    %7 = structnew 0 %3             ; MutableBytes over the copy
    %8 = structnew 1 %7 %5          ; {buf, result}
    %9 = structget 1 %8             ; r.result
    %10 = int 0
    %12 = op ilt %9 %10
    br %12 L0 L1
  label L0
    %14 = call 4                    ; errno()
    %15 = structget 1 %8
    %16 = structget 0 %8
    retmulti %15 %14 %16
```

The generic lowering (`-specialize 0`, cranelift-generic) had the same
`keepalive structnew structnew structget ilt` between the call and
`errno()`.

The answers the brief asked for, from that NIR, the machine code (section
13) and the trace:

1. Materialized: both the MutableBytes and the `{buf, result}` struct, on
   every path, before the comparison.
2. Unavoidable: the detach (`mbytesclone`, before the call: value semantics,
   MUTABLE-BYTES.md). Compiler artifacts: both `structnew`s, and the
   `rt_keepalive` call.
3. Both native lowerings: yes, the same window.
4. Allocator and runtime calls between the C call and errno: `rt_keepalive`
   (no allocation, but a call), `rt_struct_new` twice, each reaching
   `malloc` (executed on the -1 path: the trace).
5. GC safepoints in the interval: both `structnew`s (a collection may run
   there, and its frees).
6. The escape classifier did not see the write-back as scalar-replaceable
   (`Classify` returned "" for a foreign call).
7. Multiple writable parameters: one more `structnew` per parameter.
8. A caller inspecting only the C result and discarding the buffer
   (`r.result` alone): still both objects (only a call in statement
   position skipped them).

## 4. The original machine-code call sequence

The executable of `ec::read`'s program (Linux x86-64, Intel syntax; the
window from `read`'s return to the call of `errno()`, abridged to its calls
and branches):

```text
   96faf: call   r8                          ; read(2), through the GOT
   96fc6: je     96fe1                       ; result fits a small Int?
   96fd2: call   rt_ffi_box_i64              ;   no: box it (a BigInt)
   96ffc: call   rt_keepalive                ; the keepalive: a real call
   9701a: call   rt_struct_new               ; MutableBytes {storage: copy}
   97043: call   rt_struct_new               ; {buf, result}
   9705e: jne    97086                       ; r.result a small Int?
   9706c: call   rt_int_cmp                  ;   no: compare BigInts
   9709a: je     970de                       ; r.result < 0?
   970e4: call   botlish_fn_4                ; errno()
```

and the instructions it executes, by ptrace single-stepping from the
instruction after `call r8` to `rt_native_load` (the load of errno), one
line per run of consecutive instructions in one function:

```text
15 botlish_fn_5 (read)          7 rt_keepalive        7 botlish_fn_5
24 rt_struct_new                4 __rust_no_alloc_shim_is_unstable_v2
 4 rt_struct_new                4 __rust_alloc         9 __rdl_alloc
42 libc.so.6 (malloc)          14 rt_struct_new       15 libc.so.6
 5 rt_struct_new               23 Vm::new_struct       4 __rust_no_alloc...
 3 Vm::new_struct               4 __rust_alloc         9 __rdl_alloc
213 libc.so.6 (malloc)         30 Vm::new_struct       8 rt_struct_new
 9 botlish_fn_5                24 rt_struct_new        ... the second
                                                       object, the same
14 botlish_fn_5                10 botlish_fn_4 (errno) ...
```

917 instructions, 545 of them in glibc.

## 5. Existing scalar replacement and escape analysis

What was there (STRUCT-SCALAR-REPLACEMENT.md, VALUE-TRANSPORT-
MATERIALIZATION.md):

* `hir::escape::Classify` recognizes the constructions native lowering can
  hand back as fields: struct literals, `[e0, ...]` Lists, exact calls with
  a recognized result, `if`s of those, and four natives whose struct result
  lowering builds from registers it already has (a syscall's Register64, the
  address bridge's, `binary::parse`'s LayoutStruct, a layout write's
  MutableBytes).
* A local bound to one, every use of which is a projection or a lazily
  materializable use in its own loop, is a virtual struct (`{virtual FIELDS
  SHAPE ROOT MAT CUT}` in `fn locals`); exact returns carry fields
  (`retmulti`/`callmulti`), exact calls take them (`fields` variants), `if`s
  join them field-wise.
* A nested inline literal may be opened into its parent's fields by the
  class's *cut* (`NestingPlan`), unless some use reads it whole
  (independent use): then it stays one field, built with the parent.
* Materialization (`MaterializeVirtual`) is lazy and single, at the first
  use that needs the object.
* GC roots: every register live across a safepoint gets a root slot,
  written at its definition; the stack map of each safepoint lists the slots
  live there (codegen::roots, from NIR liveness).

## 6. The chosen change

The smallest extension of that machinery:

1. **The write-back value is a construction.** `Classify` asks
   `WriteBackResult`: a foreign call whose transport has a write exposure,
   not refused, typed as its anonymous write-back struct, is `{local {N {""
   LAYOUT}} {}}`, exactly as a struct literal of the same shape. Every
   consumer escape analysis knows -- a local, a return, an argument, an `if`
   join, a direct projection -- now takes it as fields.
2. **Its MutableBytes are opened, lazily.** The write-back's tree
   (`WriteBackTree`) has a child per written parameter, the MutableBytes
   shape with its one field, the storage -- which exists the moment C
   returns. `NestingPlan` opens such a child (width +0: it costs nothing)
   even past an independent use `r.buf`, provided every such use runs as
   often as the binding: the same innermost loop for a local, never for a
   parameter; a call's direct projection always. The use builds the
   MutableBytes, once per dominating scope. Otherwise the child stays closed
   and the call builds it, as before.
3. **The keepalive is no machine code.** What `op keepalive` guarantees is
   that the exposed storage is a root at every safepoint up to the
   operation's own; that is the NIR use's effect on the root plan, which
   does not need a call to exist.

Considered and not taken: a raw (untagged) C result held in the virtual
fields until a tagged use, to remove the BigInt slow paths of a 64-bit
result from the window too -- raw registers are never stored in `fn
locals`, a rule every consumer of virtual fields relies on (section 29). A
new aggregate type, tuples, a foreign-call-specific optimizer, an errno
intrinsic, a Darwin rule, and a new allocation strategy for ordinary
structs were out of scope by the brief and not needed.

## 7. Files and subsystems changed

| file | what |
|---|---|
| `hir/escape.tcl` | `WriteBackResult`, `WrittenNames`, `IsWriteBack`, `WriteBackTree`, `WriteBackPaths`, `WriteBackCut`; `Classify`'s borrow case; `LiteralTree`'s write-back children; `Origins`' `{wb ID E}`; `NestingPlan`'s lazy paths and its `writebacks`/`lazy` record fields; `DirectProjections`' write-back cut |
| `native/lower.tcl` | `BorrowCall` (fields per cut), `FieldValue`, `OpenedFieldObject`, `OpenedOwnerStorage`, `BuildStruct`'s reuse of built inner objects, `Project`/`ProjectChain` (an opened field read whole), `StorageOf` (an opened owner), `StructFields` (an opened write-back call), `Call`/`CallInner`/`VirtualValue`/`TryFields` (the cut) |
| `native/src/codegen/clif.rs`, `native/src/runtime/ops.rs`, `native/src/nir.rs` | `KeepAlive` emits nothing; `rt_keepalive` removed; the op's documentation |
| `tests/c-ffi-error-capture.test`, `tests/cffi/window.tcl`, `tests/cffi/window-trace.c`, `tests/cffi/errno-clobber.c`, `tests/cffi/fixture.c` | the evidence (section 14) |
| `tests/c-pointer-borrowing.test`, `tests/abi-bytes.test`, `tests/abi-mutable-bytes.test`, `tests/darwin-io.test` | the expectations that pinned the old window (`cb-nir-write`, `cb-exposure-after-arguments-nir`, `cb-allocations`, the four `*-keepalive-*` and machine-code tests, `di-errno-read-first`), `cb-write-back-allocations`, `di-errno-allocator` |
| `audit/c-pointer-borrowing/tools/` | ten mutants, the new test file as a detector |
| `audit/context-traits/tools/mutants.txt` | `darwin-errno-before-call` |
| `audit/golden/migration/`, `tests/golden/manifest.tsv` | census rows of the new tests |
| `bench/c-ffi-error-capture.tcl` | section 24 |
| `lib/darwin.bot` | its comment on read's errno window (no code) |
| docs | this report; C-POINTER-BORROWING.md, C-FFI.md, STRUCT-SCALAR-REPLACEMENT.md, VALUE-TRANSPORT-MATERIALIZATION.md, MACOS-AARCH64-MILESTONE-8.md (follow-up notes), AGENTS.md, INDEX.md |

No HIR node, HIR fact, NIR instruction, runtime object, interchange field,
type or syntax was added.

## 8. The raw C result

`foreigncall`'s destination is the C result, converted at the boundary as
before (C-FFI.md, section 8: a small Int inline, a BigInt by
`rt_ffi_box_i64` beyond the small-Int range; a `Ptr` its address word). It
becomes the write-back value's `result` field register and is read from
there by every projection: `r.result < 0` is one `ilt` of that register, no
`structget`. Nothing copies, re-boxes or re-reads it (mutant
`write-back-result-changed`: a field that is not that register is killed by
the fixture's sentinel tests).

## 9. The detached storage

The detach is unchanged: `op mbytesclone` of the owner's storage, after every
argument, before every address (C-POINTER-BORROWING.md). The copy's register
is exposed, kept alive by the keepalive, and is the write-back value's
`NAME` field -- opened, it *is* the field; there is no second copy and no
copy back. C's writes stay in it whatever the C result says: a failure
after a partial write keeps the partial write (`ec-fixture-shapes`'s
`fill(m, 2, 13, 0)`: errno 13, the four bytes written). Each written
parameter has its own copy, also of one owner passed twice (`two(m, m, 6)`:
seeds 1 and 2 in two buffers; mutant `write-back-shared-copy`); a read and a
write exposure of one owner see the original and write the copy
(`alias`); the caller's MutableBytes never changes (the shapes' last
value: `00000000`).

## 10. Nested write-back structures, materialized

* `r.buf` read whole (bound, returned, stored, passed to an ordinary
  function, compared, printed) builds the MutableBytes at that use from the
  copy's register: `structnew 0 %copy` (`OpenedFieldObject`), recorded in
  the root's entry so that the uses it dominates reuse it; a branch or loop
  restores `fn locals`, so one built in a branch is not reused after it.
* The whole struct, when a use needs it (an open call, storage in a List,
  equality, a capture's materialization), is built by `MaterializeVirtual`
  from its fields, its MutableBytes first -- the one already built for an
  earlier `r.buf` reused (`BuildStruct`'s BUILT).
* A write-back passed to another foreign call (`c_read(r.buf, ...)`) is
  read for its storage alone (`OpenedOwnerStorage`): nothing is built.
* A write-back held in a literal's field (`{r: c_call(...), tag: 1}`)
  opens into the literal's fields (`LiteralTree`), `w.r.result` one
  register.
* Where the class cannot keep it open -- a use inside a loop deeper than the
  binding, a parameter's use in its callee, a class shared with a literal
  whose field is no inline MutableBytes -- the MutableBytes is closed and
  built at the call, once, as before (`cb-write-back-allocations`' loop row:
  one MutableBytes for ten reads; mutant `write-back-buffer-built-per-iteration`).
* Returned from a function, the value is carried home as fields by the
  existing return transport (`raw`'s `retmulti %copy %result`, the caller's
  `callmulti`): `via_raw` compares and reads errno with nothing built.

## 11. keepalive and GC roots

`KeepExposedAlive` is unchanged: one `op keepalive %storage` after the
operation for every exposed storage. In codegen it is now no machine code:
the register it defines is the constant unit.

What the keepalive guarantees never depended on the call. The root plan
(codegen::roots) computes NIR liveness; the keepalive's operand is a use,
so the storage is live across the foreign call, gets a root slot (written at
its definition) and is in the stack map of every safepoint up to the
keepalive -- the C call's own included -- and its slot is not reused before.
`abi-bytes-clif-keepalive-and-stack-map` and its mutable-bytes twin check
that stack map entry in the CLIF of the syscall path (`ss0+8` in the
syscall helper's `call`, on nativeFrameRoots hosts), and the borrow
fixture's `read_reentrant`, which collects during the call, still reads its
storage intact (`cb-liveness-reentrant`); the mutant
`keepalive-not-a-use` (the root plan ignoring the keepalive's operand) is
killed by them.

A virtual write-back value is no object and no root; its fields are
ordinary tagged registers, rooted by the same liveness as every register:
the copy's storage stays a root while `r.buf` may still be read, exactly as
the MutableBytes object holding it did. Nothing pins, nothing is
registered, no write barrier exists or was added.

## 12. Before and after: NIR

(`tests/c-ffi-error-capture.test`'s shapes; every function's window from its
C call to its call of `errno()`, `window::nirWindows`, as op words)

| shape | before (`-struct-opt 0` reproduces it) | after |
|---|---|---|
| `ec::fill` (darwin::read's shape) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |
| status only (`r.result`, buffer unused) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |
| straight off the call (`f(...).result < 0`) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |
| two written parameters | `keepalive keepalive structnew structnew structnew structget ilt` | `keepalive keepalive ilt` |
| read and write exposure of one owner | `keepalive keepalive structnew structnew structget ilt` | `keepalive keepalive ilt` |
| held in a struct (`w = {r: f(...), tag: 1}`) | `keepalive structnew structnew structnew structget structget ilt` | `keepalive ilt` |
| `if` of two calls | `keepalive structnew structnew structget ilt` (each) | `keepalive ilt` (each) |
| in a loop | `keepalive structnew structnew structget ilt` | `keepalive ilt` |
| in a coroutine, before and after a `yield` | the same | `keepalive ilt` (each) |
| returned from `raw`: callee / caller | `keepalive structnew structnew` / `structget ilt` | `keepalive` / `ilt` |
| `darwin::read` (macos-aarch64) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |

The same on the specializing and the generic lowering, for linux-x86_64 and
macos-aarch64 -- except the returned value on the generic lowering, which
carries no struct across a call as fields (section 29). `window::nirHazards`
(anything that may allocate, call or collect) finds nothing in any window
after, three to five per window before.

## 13. Before and after: machine code

The object file (`native::object`), disassembled with its relocations
(`objdump -dr`): every call is named by the symbol its relocation names
(a direct call's own; an indirect call's -- a C function's through its GOT
entry, every runtime helper's on AArch64 -- through the register its GOT
load wrote; Mach-O's `_` dropped). `window::machineWindow` builds the
function's control-flow graph (every branch's successors) and lists the
calls on any path from the C call's return to the call of `errno()`,
through no other call of the same C function:

| shape | before | after |
|---|---|---|
| every shape (Linux x86-64 and AArch64) | `rt_ffi_box_i64 rt_struct_new rt_struct_new rt_int_cmp` (one more `rt_struct_new` per further object) | `rt_ffi_box_i64 rt_int_cmp` |
| `errno()`: entry to `__errno_location` / `__error` | -- | none |
| `errno()`: `__errno_location` to the load (`rt_native_load`) | -- | none |

`rt_ffi_box_i64` and `rt_int_cmp` are the BigInt paths of a 64-bit result:
`foreigncall` tags its result inline when it fits the small-Int range and
calls `rt_ffi_box_i64` otherwise; `ilt` compares two small Ints inline and
calls `rt_int_cmp` otherwise. For a small result -- the -1 sentinel, every
count -- neither runs: the trace shows it.

The instructions executed after (section 4's trace, the new executable):

```text
23 botlish_fn_5 (ec::read)   ; read's return: tag, compare, branch to errno()
10 botlish_fn_4 (errno)      ; its entry: frame, root slots
 4 libc.so.6 +2a6e0..2a6f4   ; __errno_location
20 botlish_fn_4 (errno)      ; the null check, the view's operands
                             ; -> rt_native_load: the load itself
```

57 instructions, no other function (`ec-trace` pins the sequence of
functions: `ec::fill ec::errno __errno_location ec::errno`; its positive
control, the `-struct-opt 0` executable, runs `rt_struct_new` and glibc's
allocator there).

On AArch64 the same detector, run on objects from the aarch64 driver under
qemu-user during development, reads the GOT-load-and-`blr` helper calls and
gives the same windows; CI's arm64 and macOS jobs run it on their own
objects (sections 26, 27).

## 14. The critical-window invariant

From the C function's return to the moment the program holds its error
state in an ordinary value -- for errno, the return of `__errno_location()`
/ `__error()` and the load of the `int` it points to (`rt_native_load`, whose
code before the load checks its operands and calls nothing) -- the code the
compiler emits runs only:

* register moves and constants;
* the conversion of the C result to a Botlish value: inline for a small
  Int; `rt_ffi_box_i64`/`_u64` (an allocation) only for a 64-bit result
  outside the small-Int range;
* the program's own comparison: inline for small Ints; `rt_int_cmp` (no
  allocation) only for a BigInt operand;
* branches;
* `keepalive`: nothing;
* the call of the program's errno function, its prologue (frame and root
  slot initialization, no call), the C call of the errno location, the null
  check of the view, and the load.

No heap allocation, allocator call, GC safepoint that can collect,
unrelated C call, coroutine switch or runtime helper runs there on any path
a small-Int result takes. The guarantee is the compiler's own work: it does
not cover what a program writes between the call and its errno read (an
allocation the program asks for is the program's).

The evidence, at three levels, each with its positive control:

| level | detector | after | positive control (`-struct-opt 0`, the old window) |
|---|---|---|---|
| NIR | `window::nirWindows`/`nirHazards` (`ec-nir-windows`, `ec-nir-no-hazard`, `ec-darwin-read-window`, `di-errno-read-first`) | `keepalive ilt`, no hazard | `structnew` found (`ec-nir-positive-control`) |
| machine code | `window::machineWindow` on the object file (`ec-machine-window`) | at most the BigInt paths | `rt_struct_new` found on every shape (`ec-machine-positive-control`) |
| execution | ptrace single-stepping (`ec-trace`, Linux) | wrapper, errno(), `__errno_location` only | `rt_struct_new` and libc's allocator executed |
| behavior | an allocator that sets errno on every allocation (`ec-fixture-executable`, `ec-real-read`, `di-errno-allocator`) | every errno right | errno 77 where the write-back was built (`ec-clobber-positive-control`, `di-errno-allocator`); a program that allocates there itself reads 77 too |

The behavioral evidence alone would not prove the property (an allocator
that leaves errno alone hides the window); the structural detectors do, and
each detector is shown to see what it is meant to.
