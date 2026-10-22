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
917, 545 of them in glibc, its `malloc` (sections 4 and 13). With an allocator
that sets errno to 77 on every allocation, the old lowering's `read` reports
errno 77; the new one reports the call's own (sections 15 to 17).

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
* **tests/c-ffi-error-capture.test** (15 tests), tests/cffi/window.tcl (the
  NIR and machine-code window detectors), tests/cffi/window-trace.c (a
  ptrace single-stepper), tests/cffi/errno-clobber.c (an allocator that
  changes errno), four errno functions in tests/cffi/fixture.c,
  `cb-write-back-allocations`, `di-errno-allocator`, fourteen mutants (thirteen
  of the borrowing harness, one of Darwin IO's),
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
| `native/native.tcl` | the transport census prints a class's paths built at their use |
| `native/src/codegen/clif.rs`, `native/src/runtime/ops.rs`, `native/src/nir.rs` | `KeepAlive` emits nothing; `rt_keepalive` removed; the op's documentation |
| `tests/c-ffi-error-capture.test`, `tests/cffi/window.tcl`, `tests/cffi/window-trace.c`, `tests/cffi/errno-clobber.c`, `tests/cffi/fixture.c` | the evidence (section 14) |
| `tests/c-pointer-borrowing.test`, `tests/abi-bytes.test`, `tests/abi-mutable-bytes.test`, `tests/darwin-io.test` | the expectations that pinned the old window (`cb-nir-write`, `cb-exposure-after-arguments-nir`, `cb-allocations`, the four `*-keepalive-*` and machine-code tests, `di-errno-read-first`), `cb-write-back-allocations`, `di-errno-allocator` |
| `audit/c-pointer-borrowing/tools/` | thirteen mutants, the new test file as a detector |
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
parameter has its own copy, also of one value passed twice (`two(m, m, 6)`:
seeds 1 and 2 in two buffers; one binding passed twice, `bb-write-two-outputs`,
kills mutant `write-back-shared-copy`); a read and a
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
storage intact (`cb-liveness-reentrant`, which kills the mutant
`keepalive-not-a-use`: the root plan ignoring the keepalive's operand).

A virtual write-back value is no object and no root; its fields are
ordinary tagged registers, rooted by the same liveness as every register:
the copy's storage stays a root while `r.buf` may still be read, exactly as
the MutableBytes object holding it did. Nothing pins, nothing is
registered, no write barrier exists or was added. (Mutant
`write-back-copy-not-a-root`, the root plan never counting a write
exposure's copy as a managed register, is killed by seven GC-stress tests,
`ec-fixture-executable` among them.)

## 12. Before and after: NIR

(`tests/c-ffi-error-capture.test`'s shapes compiled for linux-x86_64; every
function's window from its C call to its call of `errno()`,
`window::nirWindows`, as op words; "before" is the commit before this
milestone, 8c29f7e, the same source through its compiler)

| shape | before | after |
|---|---|---|
| `ec::fill` (darwin::read's shape) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |
| status only (`r.result`, buffer unused) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |
| straight off the call (`f(...).result < 0`) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |
| two written parameters | `keepalive keepalive structnew structnew structnew structget ilt` | `keepalive keepalive ilt` |
| read and write exposure of one owner | `keepalive keepalive structnew structnew structget ilt` | `keepalive keepalive ilt` |
| held in a struct (`w = {r: f(...), tag: 1}`) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |
| `if` of two calls | `keepalive structnew structnew structget ilt` (each) | `keepalive ilt` (each) |
| in a loop | `keepalive structnew structnew structget ilt structget` | `keepalive ilt` |
| in a coroutine, before and after a `yield` | `keepalive structnew structnew structget ilt` (each) | `keepalive ilt` (each) |
| returned from `raw`: callee / caller | `keepalive structnew structnew` / `structget ilt` | `keepalive` / `ilt` |
| `darwin::read` (macos-aarch64) | `keepalive structnew structnew structget ilt` | `keepalive ilt` |

Before, the generic lowering (`-specialize 0`) had the same windows; after,
it has the "after" column too -- except the returned value, which the
generic lowering carries across no call as fields (section 29): there `raw`
builds it before its return, `keepalive structnew structnew`.
`window::nirHazards` (anything that may allocate, call or collect) finds
nothing in any window after, two to three per window before. `-struct-opt
0` (struct scalar replacement off) reproduces the old windows and is the
detectors' positive control.

## 13. Before and after: machine code

The object file (`native::object`), disassembled with its relocations
(`objdump -dr`): every call is named by the symbol its relocation names
(a direct call's own; an indirect call's -- a C function's through its GOT
entry, every runtime helper's on AArch64 -- through the register its GOT
load wrote; Mach-O's `_` dropped). `window::machineWindow` builds the
function's control-flow graph (every branch's successors) and lists the
calls on any path from the C call's return to the call of `errno()`,
through no other call of the same C function ("before": the same detector
on the object file of 8c29f7e's compiler, the calls in program order):

| shape | before | after |
|---|---|---|
| every shape (Linux x86-64; after: also AArch64, section 26) | `rt_ffi_box_i64 rt_keepalive rt_struct_new rt_struct_new rt_int_cmp` (one more `rt_keepalive` per further exposure, one more `rt_struct_new` per further object) | `rt_ffi_box_i64 rt_int_cmp` |
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
control, the `-struct-opt 0` executable, runs `rt_struct_new` there and
enters glibc's allocator, where its trace ends: `WINDOW_TRACE_UNTIL_LIBRARY`
stops at the first instruction of a shared library, since single-stepping a
lock's load- and store-exclusive pair on AArch64 clears the exclusive
monitor and never ends). The tracer is x86-64's and AArch64's; on AArch64
it reads the registers through glibc's `struct user_regs_struct` (until
2d64ae6 it named the kernel's `user_pt_regs`, did not build there, and
`ec-trace` was skipped on arm64 by its constraint).

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
| execution | ptrace single-stepping (`ec-trace`, Linux) | wrapper, errno(), `__errno_location` only | `rt_struct_new` executed, the C library's allocator entered |
| behavior | an allocator that sets errno on every allocation (`ec-fixture-executable`, `ec-real-read`, `di-errno-allocator`) | every errno right | errno 77 where the write-back was built (`ec-clobber-positive-control`, `di-errno-allocator`); a program that allocates there itself reads 77 too |

The behavioral evidence alone would not prove the property (an allocator
that leaves errno alone hides the window); the structural detectors do, and
each detector is shown to see what it is meant to.

## 15. Linux C fixture results

tests/cffi/fixture.c's errno functions -- `bcf_fill_errno` (fill a buffer
from a seed; fail with errno ERR, -1, after writing; or succeed, optionally
leaving a stale errno), `bcf_fill2_errno` (two buffers), `bcf_reverse_errno`
(read one buffer, write another), `bcf_tick` (a counter) -- set the standard
`errno` of the calling thread. The test's binding (`ec`) reads it through
glibc's `__errno_location()` and a native view of a one-field layout
(`__error()` on macOS): no new primitive.

`ec-fixture-shapes`, on cranelift and cranelift-generic (each a linked run
of the program), Linux x86-64 (this container): every shape's value is
the oracle's -- `fill(m, 1, 0, 0)` `{4, 0, 01264b70}`; `fill(m, 2, 13, 0)`
`{-1, 13, 02274c71}` (the failure after the write keeps the write);
`fill(m, 3, 0, 99)` `{4, 0, ...}` (a success reporting 0 although C left
errno 99); `ec::read(-1, m)` `{-1, EBADF, 00000000}`; then 4, 5, 6, 7, 8, 10,
11, 22, 33, 34 from the other shapes in succession, and the caller's buffer
`00000000` at the end. `ec-arguments-once`: the seed argument `tick()` is 1
and the next `tick()` after the call 2 -- one evaluation, in order.
`ec-fixture-executable`: the standalone executable prints the same, also
under GC stress and with the errno-changing allocator, also both at once.
On Linux AArch64 (CI, section 26) the same tests run on the arm64 runner's
own glibc, `__errno_location` and objects: every test of the file passed in
run 39690213504's interp, compile and GC-stress jobs, `ec-trace` skipped
there (the tracer did not build for AArch64 until 2d64ae6; section 13).
«arm64 trace»

## 16. macOS C fixture results

tests/c-ffi-error-capture.test on GitHub's macos-15 runners (Apple
Silicon; macOS arm64 CI, section 27): the fixture built by Apple clang, the
binding reading errno through libSystem's `__error()` (`ecErrnoSymbol`),
EBADF and EISDIR the SDK's own (`ecErrnoFacts`' C probe). Every test runs
there but `ec-trace` (ptrace: Linux only, constraint `ecTrace`):

* `ec-fixture-shapes`, `ec-arguments-once`: the values of section 15, on
  both native backends -- the same buffers, the same errnos in succession,
  0 after a success that left a stale errno;
* `ec-nir-windows`, `ec-nir-no-hazard`, `ec-nir-no-write-back-object`,
  `ec-darwin-read-window`, and their positive control: `keepalive ilt`;
* `ec-machine-window` on the Mach-O object (`objdump -dr`: each call named
  by its Mach-O ARM64 relocation, the `_` prefix dropped): the windows hold
  the BigInt paths at most, and
  `errno()` calls only `__error` and then `rt_native_load`;
  `ec-machine-positive-control` finds `rt_struct_new` in the `-struct-opt 0`
  object;
* `ec-fixture-executable`, `ec-real-read`, `ec-clobber-positive-control`:
  the standalone executable with tests/cffi/errno-clobber.c inserted by
  `DYLD_INSERT_LIBRARIES` (libSystem's allocator interposed through
  `__DATA,__interpose`, setting errno to 77 after every allocation) prints
  every errno right, also under GC stress; the `-struct-opt 0` executable
  reads 77.

Run 39690463966 (87e5d87, Tier C under `BOTLISH_NATIVE_GC_STRESS=1`, the
test file hosted by interp and by compile): 14 passed, 1 skipped
(`ecTrace`), 0 failed, both times; the acceptance tier of the same run
(no GC stress) passed it too.

## 17. Darwin read errno results

`darwin::read` is lib/darwin.bot's own code (section 2's reproducer),
called through libSystem's `read(2)` on macOS. darwin-io.test:

* `di-errno-read-first` (any host: macos-aarch64 NIR compiled on Linux, and
  on macOS): the windows from each wrapper's `foreigncall` to its call of
  `errno()` -- `darwin::write`, `read`, `open_with`, `open_mode` (behind
  `create`, the variadic call) and `close` -- are `{keepalive ilt}
  {keepalive ilt} {keepalive runbox rilt} {keepalive runbox rilt} {runbox
  rilt}`; only read's changed (it held `structnew structnew structget`
  before); `errno()` is one `foreigncall` of `__error` and one `op
  nativeload`;
* `di-errno` (Milestone 8's): ENOENT 2, EBADF 9, EEXIST 17, EISDIR 21 in
  succession, successes between them reporting 0, twenty rounds, inside a
  coroutine before and after a suspension, under GC stress, in the
  executable and on both native backends -- `read(9999, ...)`'s errno is
  `9`;
* `di-errno-allocator` (new, macOS): the same program with the
  errno-changing allocator interposed prints the same, also under GC
  stress; the `-struct-opt 0` executable -- read's write-back value built
  right after the call, the lowering before this milestone -- prints
  `-1, 77` for that read, and only for read (`write`, `open` and `close`
  never allocated there).

Run 39690463966: darwin-io.test passed under GC stress on interp and
compile (both its Tcl-hosted halves), and in the same run's acceptance
tier.

## 18. Multiple writable parameters and aliasing

`two(m, m, 6)`: one owner passed to both written parameters of
`bcf_fill2_errno` is two private copies -- C fills one from seed 1 and the
other from seed 2 (`01264b70`, `02274c71`), and the call fails with errno 6
after writing both; the window holds two keepalives and the comparison.
(`two` receives one value as two parameters, two registers. One binding
passed twice -- one register -- is c-byte-borrowing.test's
`bb-write-two-outputs`, `split(d, 8, m, m)`: two copies, neither seeing the
other's writes; it kills the mutant that shares one copy per register,
`write-back-shared-copy`.) `alias(...)`: `bcf_reverse_errno(freeze(m),
n, m, 7)` reads the original `abcd` and writes the reversal into the copy:
`dcba` in the write-back value, `abcd` still in `m`, errno 7. Write exposures
are made after every argument, each with its own `mbytesclone`, and the
read exposure of the same owner is its own storage (C-POINTER-BORROWING.md,
`cb-read-write-one-owner`).

## 19. Escaping write-back values

Each of these keeps its value and its errno (`ec-fixture-shapes`, both
native backends, the executable, GC stress):

| the write-back value | how it is represented | result |
|---|---|---|
| returned from a function (`raw`) and read by its caller | fields across the return (`retmulti`/`callmulti`) | `[-1, 8, 092e5378]` |
| held in a struct (`w = {r: ..., tag: 1}`) | opened into `w`'s fields | `[-1, 10, 072c5176, 1]` |
| its buffer stored in a List | the MutableBytes built at the List's construction, after errno() | every list above |
| its buffer captured by a closure (`captured`) | the binding is captured, so not virtual: the value is built at the call (as before), the closure returns `03284d72` | `f()` |
| held across a coroutine suspension (`suspended`) | fields in the coroutine's frame, live across the `yield` | `[33, 4034]`: errno 33 before the yield, 34 after, and the first buffer's length (4) read after the resume |
| in a loop | fields per iteration | `[[4, 0, ...], [-1, 22, ...], [4, 0, ...]]` |
| passed to another foreign call (`fill(r.out, ...)`) | the storage register, nothing built | c-pointer-borrowing.test's `cb-write-owner-usable-again` |

## 20. Coroutines and GC stress

Coroutines: the `suspended` shape holds a write-back value's fields in a
coroutine frame across a `yield` and reads its buffer after the resume
(`[33, 4034]`); c-byte-borrowing.test's `bb-coroutines` and
c-pointer-borrowing.test's coroutine programs make exposures inside
coroutine bodies. Root plans are NIR liveness and unchanged: a suspended frame's
fields are roots like any register's.

`BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt at every allocation
site), Linux x86-64, each file on its own (`-tmpdir` private):

| test file | total | passed | skipped | failed |
|---|---:|---:|---:|---:|
| c-ffi-error-capture.test | 15 | 15 | 0 | 0 |
| c-pointer-borrowing.test | 62 | 62 | 0 | 0 |
| c-byte-borrowing.test | 20 | 19 | 1 (`guardMalloc`, macOS) | 0 |
| c-ffi.test | 112 | 109 | 3 (`boringssl` 2, `appleAvailability` 1) | 0 |
| coroutines.test | 81 | 81 | 0 | 0 |
| affine.test | 48 | 48 | 0 | 0 |
| abi-bytes.test | 73 | 73 | 0 | 0 |
| abi-mutable-bytes.test | 76 | 76 | 0 | 0 |
| value-transport.test | 64 | 64 | 0 | 0 |
| struct-scalar-replacement.test | 84 | 84 | 0 | 0 |

`cargo test --release --manifest-path native/Cargo.toml --lib`: 278 passed, 0
failed, also under GC stress. The executables
under GC stress: `ec-fixture-executable` (also with the errno-changing
allocator at once), `di-errno`, `di-errno-allocator`, `bb-gc-stress`,
`bb-system-library-gc-stress`. On macOS, run 39690463966 ran
c-ffi-error-capture, darwin-io, c-byte-borrowing, c-pointer-borrowing,
c-ffi, coroutines, affine, abi-mutable-bytes and workload-2048 under GC
stress, hosted by interp and by compile: 452 tests each, 418 passed, 34
skipped (host constraints: `linuxX86_64` 15, `nativeLinux` 15, `boringssl`
2, `ecTrace` 1, `tclLibrary` 1), 0 failed.

## 21. HIR interchange and native backend regression

`ec-interchange`: the shapes program written as HIR interchange text and
read back after another compilation lowers to the identical NIR -- the
representation is a lowering decision over the call's existing `borrows`,
no HIR fact; the interchange format and the front-end cache are unchanged.
`ec-tcl-backends`: the Tcl backends run the binding to its first C call and
refuse it (NATIVE-ONLY), as before.

`tests/local.tcl` (every Tcl test file on interp and compile, minus the
golden duplicates; every golden suite on interp, compile, cranelift-generic
and cranelift), Linux x86-64, 4 jobs, 1936 s: Tcl tests 6601 passed on
interp and 6596 on compile, 0 failed; golden suites 101 run, 0 failed --
interp 4977/4977, compile 4977/4977, cranelift-generic 4885/4885, cranelift
4987/4987. The Tcl backends' code is untouched (no file of `core/` or
`compiler/` changed); the struct scalar-replacement and value-transport
suites (struct-scalar-replacement.test, value-transport.test,
virtual-construction.test, struct-destructuring.test, the golden
struct-representation.bot and compiled-values.bot) pass unchanged: the new
construction is a new member of the existing machinery, and every other
construction's plan is the same.

## 22. Mutation results

`audit/c-pointer-borrowing/tools/mutate.tcl` (its detectors: c-pointer-
borrowing.test, c-byte-borrowing.test, c-ffi-error-capture.test, each with a
private `-tmpdir`, and the borrowing fuzzer; a native mutant rebuilds a
private copy of the backend, and one that does not build counts as
NOT-BUILT, never as killed) and `audit/context-traits/tools/mutate.tcl` for
lib/darwin.bot. The brief's mutant list, each as the mutant that realizes
it and the detector that kills it -- structural detectors for the window,
semantic and GC-stress ones for values and lifetimes:

| the brief's mutation | mutant | kind | killed by |
|---|---|---|---|
| eager outer write-back `structnew` | `write-back-not-a-construction` | window | 13 tests, among them `ec-darwin-read-window`, `ec-clobber-positive-control` (the allocator), `cb-nir-write`, `cb-allocations`, `cb-write-back-allocations`, `cb-exposure-after-arguments-nir` |
| eager inner MutableBytes wrapper | `write-back-buffer-eager` | window | 10 tests, among them `ec-nir-no-hazard`, `ec-darwin-read-window`, `ec-machine-window`, `ec-fixture-executable`, `ec-clobber-positive-control`, `cb-write-back-allocations` |
| an allocator or runtime helper after the C call, before the capture | `allocation-after-c-call`, `keepalive-is-a-call` | window | 15 tests, among them `cb-nir-read`, `cb-nir-write`, `cb-allocations`, `cb-exposure-after-arguments-nir`; and 2 (`ec-machine-window`, `ec-trace`: the call is invisible in NIR, where `keepalive` is unchanged) |
| only the success path materialized lazily, the failure path eager | `write-back-failure-path-eager` (new) | window | 9 tests, among them `ec-nir-no-hazard`, `ec-nir-no-write-back-object`, `ec-darwin-read-window`, `ec-machine-window`, `ec-fixture-executable`, `ec-clobber-positive-control` |
| a detached buffer dropped from the scalar result | `opened-buffer-not-built` (handed on as storage, never built) | value | 21 tests, among them `bb-read-write-one-owner`, `bb-write-chain`, `bb-write-failure-sentinel`, `bb-gc-stress` |
| the original owner returned instead of the detached one | `copy-back-omitted` (existing) | value | 28 tests |
| one detached owner reused for two written parameters | `write-back-shared-copy` | value | 1 test: `bb-write-two-outputs` (one binding passed twice) |
| a required keepalive dropped | `owner-liveness-dropped`, `keepalive-first-only` (existing), `keepalive-not-a-use` | lifetime | 10, 3 (`ec-nir-windows`, `ec-nir-positive-control`, `cb-exposure-after-arguments-nir`) and 1 (`cb-liveness-reentrant`) tests |
| a managed root lost when the aggregate is scalarized | `write-back-copy-not-a-root` (new) | lifetime | 7 tests, among them the GC-stress ones: `bb-gc-stress`, `bb-system-library-gc-stress`, `cb-failure-gc-stress`, `cb-gc-stress-programs`, `ec-fixture-executable` |
| materialization omitted where the value escapes | `opened-buffer-not-built` | value | 21 tests, among them `bb-read-write-one-owner`, `bb-write-chain`, `bb-write-failure-sentinel`, `bb-gc-stress` |
| the raw C failure result changed while unboxing | `write-back-result-changed` | value | 43 tests |
| errno read before the C call | `darwin-errno-before-call` (context-traits) | value (macOS) | «k11» |
| errno read after an unrelated call | `darwin-errno-after-another-call` (existing), `allocation-after-c-call` | value, window | «k12» (macOS); 15 tests |
| an argument evaluated twice | `write-back-argument-twice` | value | 3 tests: `ec-arguments-once`, `cb-exposure-after-arguments`, `cb-exposure-after-arguments-nir` |
| the foreign call reordered with the program's own operations | `detach-before-later-arguments` (new) | order | 1 test: `cb-exposure-after-arguments-nir` (no value changes: arguments cannot reach the owner, a value) |
| (performance) a buffer built once per iteration | `write-back-buffer-built-per-iteration` | allocation | 1 test: `cb-write-back-allocations` (no value changes) |

The runs (Linux x86-64, this container, d152dfe's tree):

| harness | mutants | killed | survived | skipped |
|---|---:|---:|---:|---:|
| `audit/c-pointer-borrowing/tools/mutate.tcl` (all) | 43 | 42 | 0 | 1 (`apple-exposure-tagged`: macos-aarch64 only, section 27) |
| `audit/c-ffi/tools/mutate.tcl`, the six of `native/lower.tcl`'s foreign-call lowering (`argument-after-exposure`, `keepalive-dropped`, `original-mutablebytes-mutated`, `read-bytes-copied`, `botlish-name-as-symbol`, `va-trailing-classes-reversed`) | 6 | 6 | 0 | 0 |
| `audit/abi-bytes/tools/mutate.tcl -only no-keepalive` | 1 | 1 (10 liveness tests) | 0 | 0 |
| `audit/mutable-bytes/tools/mutate.tcl -only no-keepalive` | 1 | 1 (10 liveness tests) | 0 | 0 |
| `audit/context-traits/tools/mutate.tcl -only darwin-*` (macOS, tier item `darwin-io-mutants`) | «darwin mutants» | | | |

The borrowing harness's 30 earlier mutants still apply to the changed code;
the 29 this host runs are still killed (the 30th is `apple-exposure-tagged`).
(The harness names at most six of a mutant's failing tests; "among them"
lists those.) No native mutant failed to build. The
borrowing fuzzer (15 programs of every owner, contract and pointee kind on
every backend) killed none of the new mutants: its programs read no errno
and compare values, which every window mutant keeps; the structural
detectors kill them.

The fuzzers on their own, against the changed lowering:
`audit/c-pointer-borrowing/tools/fuzz.tcl` -n 20, seeds 1, 2 and 3 (160
cases each; 72, 85 and 84 refused by the model and the compiler alike), and
-n 15 -seed 9 under GC stress: 0 disagreements;
`audit/c-ffi/tools/fuzz.tcl` -n 10, seeds 1 and 2 (120 functions each, 43
and 32 variadic), and -n 8 -seed 5 under GC stress: 0 disagreements.

Correctness and optimization mutants are kept apart. The window mutants
(`write-back-not-a-construction`, `write-back-buffer-eager`,
`allocation-after-c-call`, `keepalive-is-a-call`,
`write-back-failure-path-eager`) change no value: only the structural
detectors -- NIR, machine code, the single-step trace -- and the
errno-changing allocator see them, and the allocator turns each into a
wrong errno, a correctness failure. `write-back-buffer-built-per-iteration`
is an optimization mutant (an allocation per iteration, no value or window
change); `cb-write-back-allocations` kills it. `detach-before-later-
arguments` is an ordering mutant with no value change either (arguments
cannot reach an owner, which is a value); `cb-exposure-after-arguments-nir`
kills it. No mutant was found equivalent.

## 23. Allocation counts

`cb-write-back-allocations` (the borrow fixture's `fill`, natively, the heap
objects beside the same program without the call, {MutableBytes Struct}):

| shape | before (`-struct-opt 0`) | after |
|---|---|---|
| bound, never read | 1 2 | 1 0 |
| discarded (a statement) | 1 2 | 1 0 |
| its buffer read whole once | 1 2 | 1 1 |
| its buffer read whole twice | 1 3 | 1 1 |
| its buffer read whole in a 10-iteration loop | 1 11 | 1 1 |

The MutableBytes column is the detach (the private copy), the one allocation
value semantics requires. (With struct scalar replacement off, every
`abi::bytes::mutable_length` call also builds its `abi::Usize` result: the
last two rows' extra objects.) Before this milestone the specialized
lowering built two objects whenever the value was used (`cb-allocations`:
`0 1 2 0`, now `0 1 1 0`).

## 24. Performance

The milestone is about correctness; this is what the representation change
costs or saves. `bench/c-ffi-error-capture.tcl` (tier item
`c-capture-bench` on macOS), run on this tree (87e5d87) and, with `-root`,
on a checkout of 8c29f7e (the commit before the milestone) with its own
native build; the same programs, one after the other on an otherwise idle
4-core Linux x86-64 container. Times are the best of 5 runs (in-process:
20000 calls; executables: 5 processes of 100000 iterations), minus the same
loop without the call.

In process, cranelift, the borrow fixture's write exposure of a 64-byte
buffer:

| shape | before, ns | after, ns | heap objects per call before {MutableBytes Struct} | after |
|---|---:|---:|---|---|
| discarded (a statement) | 49.4 | 56.9 | 1 0 | 1 0 |
| the C result alone (`mixed(...).result`) | 218.3 | 37.5 | 1 2 | 1 0 |
| the result and the buffer read whole | 293.8 | 135.7 | 1 2 | 1 1 |
| returned from a function, the buffer read by the caller | 207.5 | 130.2 | 1 2 | 1 1 |
| detach of a 64 KiB buffer, discarded | 2334.5 | 2258.6 | 1 0 | 1 0 |

The MutableBytes column is the detach, the private copy value semantics
requires; it stays, and dominates a large buffer (the last row: the copy is
the cost, before and after). The Struct column is the write-back struct and
the MutableBytes wrapper of the written copy: two objects before whenever
the value was used, now none for the status alone and one -- the wrapper,
at the use that reads the buffer whole -- otherwise. The discarded call
built nothing before either (`discarded` lowering); its difference is
noise.

A standalone executable looping over the C library's `read(2)` through a
write exposure and an errno read on failure (`darwin::read`'s shape over
glibc), per iteration:

| | before, ns | after, ns |
|---|---:|---:|
| 64 bytes from /dev/zero | 516.0 | 312.6 |
| EBADF (a closed descriptor), 64-byte buffer | 464.0 | 262.2 |
| 64 KiB from /dev/zero | 7285.3 | 7004.2 |

About 200 ns per call less wherever the value was used: two allocations
(each a `malloc`, a GC accounting step and a safepoint) and the
`rt_keepalive` call. (Compile time was not measured separately; the
analysis adds one construction kind to escape analysis's existing classes.)

«macOS bench»

## 25. Linux x86-64 CI

Dispatched runs of `.github/workflows/tests.yml` on the branch (its GC-stress
job runs only on pushes to main; sections 20 and 21 have the local GC-stress
runs it stands for):

| run | commit | result |
|---|---|---|
| [39690210610](https://github.com/mwagner-webdev/botlish/actions/runs/39690210610) | d152dfe (the compiler as merged) | every job passed: interp (8827 tests: 8759 passed, 68 skipped, 0 failed), compile (8754 passed, 73 skipped, 0 failed), cranelift and cranelift-generic coverage, the four golden shards beside their Tcl originals, the native Rust unit tests, the stub-linked executables, the warning gate, the method-call filter audit |
| [39699274358](https://github.com/mwagner-webdev/botlish/actions/runs/39699274358) | 2d64ae6 (the tracer's AArch64 fix, test code only) | «x86 2d64ae6» |

## 26. Linux AArch64 CI

Dispatched runs of `.github/workflows/tests-arm64.yml` (ubuntu-24.04-arm):

| run | commit | result |
|---|---|---|
| [39690213504](https://github.com/mwagner-webdev/botlish/actions/runs/39690213504) | d152dfe | every job passed: interp (8827 tests: 8705 passed, 122 skipped, 0 failed), compile (8700 passed, 127 skipped), the whole suite under `BOTLISH_NATIVE_GC_STRESS=1` (8698 passed, 129 skipped, 0 failed), cranelift and cranelift-generic coverage, the four golden shards, the native Rust unit tests also under GC stress. c-ffi-error-capture.test ran its NIR, object-file (AArch64 ELF: GOT loads and `blr`), fixture, executable and errno-changing-allocator tests; `ec-trace` was skipped (`ecTrace`: the tracer did not build) |
| [39699271553](https://github.com/mwagner-webdev/botlish/actions/runs/39699271553) | 2d64ae6 | «arm64 2d64ae6» |

## 27. macOS AArch64 CI

`.github/workflows/macos-arm64.yml` on GitHub's macos-15 runners (Apple
Silicon); the shared development Mac was not used:

| run | commit | result |
|---|---|---|
| [39690463966](https://github.com/mwagner-webdev/botlish/actions/runs/39690463966) | 87e5d87 (dispatch, Tier C under GC stress) | every job passed: smoke (Tier A: the native build and its Rust unit tests, native-status, the Mach-O object and executable checks, the smoke tier), the acceptance tier in two shards (shard 1: 105 Tcl test files on interp and 51 golden suites on all four backends, 0 failed; shard 2 passed), the Linux control, and Tier C: c-ffi-error-capture, darwin-io, c-byte-borrowing, c-pointer-borrowing, c-ffi, coroutines, affine, abi-mutable-bytes and workload-2048 under GC stress, hosted by interp and by compile (452 tests each: 418 passed, 34 skipped, 0 failed) |
| [39699340246](https://github.com/mwagner-webdev/botlish/actions/runs/39699340246) | 2d64ae6 (dispatch, Tier C: the macOS mutants and benchmarks) | «macOS 2d64ae6» |

## 28. Windows

C calls are refused on Windows (`C_CALLS`, WINDOWS-X86-64-MILESTONE-1.md),
so the fixture tests skip there (`ecFixture`, `bbFixture` need
`nativeCCalls`); every test file still runs in Windows' acceptance tier
(its `notYetByHost` list is empty). What this milestone changes on Windows
is shared code: the escape analysis and lowering of every write exposure,
`op keepalive`'s codegen, and the root plan's use of it under Windows'
fallback root plan (shadow stack, no frame walk).

[39690455043](https://github.com/mwagner-webdev/botlish/actions/runs/39690455043)
(87e5d87, push; windows-2025, MSVC): every job passed -- smoke (the native
Rust unit tests, native-status, the COFF/PE checks, the GC workloads and
the census's programs under GC stress, the 2048 executable, dumpbin, the
smoke tier and the Windows-relevant test files) and the acceptance tier in
four shards.

## 29. Known limits of the guarantee

* **A 64-bit result outside the small-Int range is boxed first.** A C
  `long` or `unsigned long` result that does not fit a tagged small Int
  (|v| >= 2^62) is boxed by `rt_ffi_box_i64`/`_u64` -- an allocation -- as
  part of the call, before the comparison. Every small sentinel (-1, 0, a
  count, a null pointer) takes the inline path; a sentinel like
  `(size_t)-1` of `iconv(3)` or `mbstowcs(3)`, declared `ffi::c::ULong`, does
  not. Keeping the result raw until a tagged use would close it, but raw
  registers never live in virtual fields today (every consumer of virtual
  fields relies on that); section 30.
* **The generic lowering returns objects.** `-specialize 0`
  (cranelift-generic) carries no struct across a call boundary as fields
  (STRUCTS.md's known limitation), so a write-back value *returned from a
  function* is built before that function returns. Locals, `if` joins,
  direct projections and literals are fields there too.
* **Closed buffers are built at the call.** A buffer read whole inside a
  loop deeper than its binding, a parameter that receives the value and
  reads its buffer whole, a class shared with a literal whose field is no
  inline MutableBytes, and a binding a closure captures keep the
  MutableBytes (or the whole value) closed: it is built at the call, once,
  as before -- the trade the analysis makes against an allocation per
  iteration or per call. The rule for a binding stays MACOS-AARCH64-
  MILESTONE-8.md's: read the error state in the function that made the
  call, before handing the value on.
* **The comparative policies.** `-struct-opt 0`, the legacy width policy and
  `nesting 0` (the differential-testing oracles) build the write-back as
  before.
* **errno() itself.** The errno function is a Botlish function call (its
  prologue stores nothing but its own frame), and the load is
  `rt_native_load`, a runtime helper whose code before the read checks its
  operands and calls nothing; on the error paths of a null or unrepresentable
  address it raises instead of loading.
* **The program's own code is the program's.** An allocation, a call or a
  `yield` the program writes between the C call and its errno read runs
  there: the guarantee covers the compiler's work.
* **Evidence per host.** The single-step trace runs on Linux (ptrace); on
  macOS the evidence is the NIR and object-file detectors and the
  errno-changing allocator.
* **One thread** (MACOS-AARCH64-MILESTONE-8.md, section 7): errno is the
  program's one native thread's.

## 30. Follow-on issues

* A raw C integer result kept unboxed until its first tagged use (and a raw
  comparison of it), closing the BigInt boxing of large sentinels and
  removing the BigInt paths from the window.
* `NativeView` loads of a fixed-width integer field inlined (a machine load,
  no helper) -- not needed for errno, a smaller window.
* Callee-side lazy materialization for parameters, with an interprocedural
  account of the loops that call them.
* The generic lowering's return transport for structs.
* Windows: `GetLastError()` read through an `extern c fn` right after the
  call will have the same window once C calls run on Windows (`C_CALLS`); the
  representation needs nothing more.
* A macOS dynamic trace (an lldb script) beside the Linux one.
