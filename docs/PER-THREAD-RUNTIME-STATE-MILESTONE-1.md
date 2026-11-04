# PER-THREAD-RUNTIME-STATE-MILESTONE-1.md

Independent Botlish VMs in one process: Vm-owned context areas and program
metadata, and per-thread stack-guard records. M3 of
THREAD-ACTOR-ARCHITECTURE-CENSUS.md (section 15), a completion report.

> A program defines which contexts exist and which implementations are
> selected. A VM owns the runtime instances of those contexts. A thread
> owns the execution stack and fault-handling state on which its VM runs.

Evidence labels, as the census's:

* **observed**: a run printed it (the command is given);
* **static**: read from the code, or checked by a test that reads it;
* **CI**: a GitHub Actions run on another host;
* **projected**: a design consequence, not built here.

Environment: branch `ccr-0580f5c2-4ea6ps` from `main` at `1faa9c9`, Linux
6.18.44 x86-64 (4 vCPUs, Intel Xeon @ 2.10 GHz, a shared container), Tcl
9.0.1 (`tclsh9.0`, the Ubuntu 25.04 packages), rustc 1.97.0. Every timed
number is from that one machine.

## Contents

1. [Executive result](#1-executive-result)
2. [Starting-state census](#2-starting-state-census)
3. [Resulting ownership model](#3-resulting-ownership-model)
4. [Context storage](#4-context-storage)
5. [Static selection](#5-static-selection)
6. [Program metadata](#6-program-metadata)
7. [Stack guards](#7-stack-guards)
8. [Coroutines and callbacks](#8-coroutines-and-callbacks)
9. [GC isolation](#9-gc-isolation)
10. [The concurrent-VM experiment](#10-the-concurrent-vm-experiment)
11. [Resource ownership](#11-resource-ownership)
12. [Backend and platform matrix](#12-backend-and-platform-matrix)
13. [Regression testing](#13-regression-testing)
14. [Mutation testing](#14-mutation-testing)
15. [Performance](#15-performance)
16. [Remaining limitations](#16-remaining-limitations)
17. [What M4 can rely on](#17-what-m4-can-rely-on)
18. [Reproducing](#18-reproducing)

---

## 1. Executive result

**Implemented.**

* **Vm-owned context areas.** The program keeps one context layout (the
  same slots, offsets and leaves, the same NIR); each Vm owns zeroed storage
  of it (`Vm::context_ptr`, `Vm::install_context_area`). Generated code loads
  the base from the Vm it was called with, then the slot's constant offset.
  The process-wide `botlish_context_area` data symbol, and the GOT
  relaxation it needed, are gone.
* **Vm-owned program metadata.** The thread-local `PROGRAM`, its per-call
  swap (`swap_current_program`) and the native library's `ProgramScope` are
  gone. Every runtime read of a shape, an enum, a native or a function's
  parameter names goes through the running Vm (`ops::program(p)`); every
  renderer takes the program as an argument (`show`, `tcl_value`,
  `RtError::message`). `ProgramInfo` and the frame map are `Arc`-shared by
  the Vms of one image, never copied.
* **Per-thread stack-guard records.** Up to 64 threads may be guarded at
  once, each with its own record in a fixed table of atomics
  (`runtime/platform/records.rs`). A thread publishes only into its own
  record. The POSIX signal handler and the Windows vectored handler find the
  faulting thread's record by its token. The process's handler is installed
  with the first guard and removed after the last. Overflow is still
  process-terminal.
* **The concurrent-VM harness.** `botlish-native vms N FILE.nir` compiles a
  program once (JIT) and runs it on N Vms at once, one per OS thread. It
  provides a rendezvous held at a collection until every Vm is mid-run, an
  ownership check in every collection, poisoning, rounds of construction and
  teardown, and labelled per-thread overflow reports. It is a test harness:
  no Botlish program can start a thread.

**Tested.**

* Two, four and eight Vms of one compiled program ran at once, with
  installed contexts (the event loop, the deterministic driver, the actors'
  context, an application context), context-owned collections, coroutines
  and actors, and frequent collection. Every Vm's result equals the
  single-Vm run of its own index. The Vms all met at the rendezvous, had
  distinct context areas and shared one program, and no root of one Vm
  reached another's heap (observed, `tests/concurrent-vms.test`).
* The same ran under GC stress (one collection per allocation, thousands
  per Vm) with poisoned frees and the ownership check on.
* Two programs' Vms alternated on one thread, made and dropped in either
  order, each reading its own metadata (observed, Rust).
* Multiple guarded threads: one thread's overflow is reported by its own
  record while others are guarded, after another thread's guard was
  dropped, from a coroutine stack, and after 16 threads churned 200 guards
  each. An unguarded thread's overflow beside a guarded one is never
  relabelled (observed, native/tests/native_stack.rs).
* 20 mutants of the new invariants, each with a named detector
  (section 14). Platform CI on macOS AArch64, Windows x86-64 and Linux
  AArch64 is covered in section 12.

**Deferred.** Everything the brief lists as a non-goal: Botlish-owned
threads (`std::thread`), cross-thread actors and transport, the event-loop
ABI v2 (the Linux adapter keeps its one process-wide loop), multi-entry
compilation, and any recovery from a stack overflow.

## 2. Starting-state census

Every process-global and thread-local item of the native runtime that
matters to concurrent Vms, at `1faa9c9`, with its semantic owner. The
census's section 2.5 and 10 named items 1-9; the rest were found by a scan
of every `static`, `thread_local!`, `OnceLock` and atomic in `native/src`
(static).

| item | where | before M3 | classified as | after M3 |
|---|---|---|---|---|
| context area | `codegen/clif.rs` `declare` | one writable linker-local data object per program image, `botlish_context_area`, addressed PC-relatively (AOT) or absolutely (JIT) | a single-VM assumption; the values are VM-owned | `Vm::context_ptr` and the Vm's own `context_table` |
| current program | `runtime/vm.rs` `PROGRAM` | thread-local `Rc<ProgramInfo>`, set by every `Vm::new` (the last made wins), swapped per call by `library.rs`'s `ProgramScope` | a single-VM assumption; the metadata is the program's, the reference the Vm's | removed; `Vm::info` (an `Arc`) read through the running Vm |
| program metadata | `ProgramInfo` | an `Rc` per Vm | immutable program-level data | an `Arc`: one per image in the JIT harness; a linked program decodes its descriptor per Vm, as before |
| frame map | `ProgramMap` | an `Rc` | immutable program-level data | an `Arc`, shared |
| program record, descriptor, code table | `program.rs` | read-only data, `Sync` | immutable program-level data | the descriptor carries the context area's size (format 4) |
| guard state | `platform/guard.rs` `GUARDED`, `SLOTS`, `SLOT`, `EXECUTABLE` | one guarded thread per process (a second install refused); publication did not check the publishing thread | a single-thread assumption; the state is the OS thread's | `records.rs`'s table, one record per guarded thread |
| Windows guard state | `platform/windows.rs` `GUARDED`, `SLOTS`, `SLOT`, `EXECUTABLE`, `DESTINATION` | the same | the same | the same records |
| previous dispositions, handler | `guard.rs` `PREVIOUS`; Windows' vectored handler | installed per guard | legitimately process-global (the OS's) | installed with the first guard, restored after the last (`INSTALLED`, a mutex of installation only) |
| result destination | `guard.rs` `RESULT_FD`, Windows `RESULT` | process-wide, read in the handler | legitimately process-global (the driver's `--result` file) | read at installation into each record |
| callback transition | `callback.rs` `ACTIVE` | thread-local Vm waiting in a transition | correctly OS-thread-owned | unchanged (a mutant shows it must be restored when a transition closes) |
| callback diagnosis | `callback.rs` `LAST_THREAD` | process-global atomic | process-global diagnostic only: with several VM threads it tells THREAD from INACTIVE heuristically; the refusal is the same | unchanged |
| coroutine stack pool | `coroutine.rs` `POOL` | thread-local pool of mapped stacks | correctly OS-thread-owned: a pooled stack holds no Vm (its first frame is written per start, `prepare`) | unchanged (a mutant shows a stale Vm would be caught) |
| coroutine stack size | `coroutine.rs` `stack_bytes` | `OnceLock` of the environment | process-global read-only configuration | unchanged |
| Windows fiber state | `coroutine/windows.rs` `THREAD_FIBER`, `START` | thread-local | correctly OS-thread-owned | unchanged |
| table-hash key | `ops.rs` `TABLE_HASH_KEY` | `OnceLock`, one per runtime copy | legitimately process-global and synchronized: Vms of a process share the key, but no stored hash crosses by pointer, and `std::transfer` recomputes under the receiver's key | unchanged |
| library registries | `library.rs` `INSTANCES`, `ERRORS`, `BUFFERS` | mutexes | legitimately process-global and synchronized | unchanged |
| unwind-check counters | `framewalk.rs` (Windows) | atomics | process-global diagnostics | unchanged |
| driver output | `main.rs` `RESULT` | `OnceLock<Mutex<File>>` | process-global, synchronized | unchanged; the harness emits after joining |
| heap, statics, constants' objects, roots, pending error and payload, stack bounds, transitions, coroutine chain, transfer plans, metrics, canonical empties | `Vm` | VM-owned | VM-owned | unchanged |
| Linux event-loop adapter | `packages/event_loop_linux/native/event_loop_linux.c` `E` | one loop per process | reserved for M4 (ABI v2) | unchanged, and unused by the harness (section 16) |

The context area and the current program were the two items that made a
second Vm of one program, on any thread, read or write the first's state.
The guard was the item that refused a second guarded thread outright.

## 3. Resulting ownership model

| owner | owns | shared how |
|---|---|---|
| compiled program image | machine code; the program record, descriptor and code table; `ProgramInfo` (shapes, enums, natives, functions, error identities); the frame map; the context **layout** (slots, offsets, leaves); the selected implementation of every context-trait requirement (compiled into the calls) | read-only, by every Vm made from it: `Arc`s and immutable data |
| Vm | its heap and collector; its constants' objects and canonical empties; its module statics; its **context area** (the installed values); its roots (`context_roots`, `temp_roots`, cleanups, the pending error and payload); its stack bounds and transitions; its coroutine chain; its transfer plans; its metrics | never: a Vm stays on the thread that made it |
| OS thread | its native stack; its **guard record** (published stack, mode, destination, label); its alternate signal stack; its callback transition (`ACTIVE`); its coroutine stack pool; on Windows its fiber state | never |
| process | the fault handler (installed while some thread is guarded) and the dispositions it replaced; the driver's result file; the table-hash key; the library registries | synchronized (a mutex for installation, `OnceLock`, atomics) |

## 4. Context storage

**Layout.** Unchanged and the program's. `native/lower.tcl`'s
`ContextSlots` assigns slots in installation order and `ContextLeaves`
flattens each one. NIR states the area's size in its header
(`contexts=BYTES`) and its slots in `context` lines. Only codegen and the
runtime changed. A NIR file means what it meant: the drivers before and
after this milestone read the same files (section 15 uses that).

**Storage.** `Vm::install_context_area(bytes)` gives the Vm a zeroed
`Vec<u64>` of the area's size and sets `context_ptr` to it (null for a
program without contexts). It is called once per Vm, with its constants:

* by `CompiledProgram::install_constants` (the JIT; through
  `ProgramImage::install`, the read-only image a harness thread installs
  from);
* by `program::instantiate` (every linked program: the rustc, stub and
  system linkers' executables and native libraries). The descriptor carries
  the size; its format is now 4.

The table is never resized, so `context_ptr` stays valid for the Vm's
lifetime. `Vm::reset` (a `bench` run's next run) zeroes it, since the next
run installs again. A new Vm never inherits a value, from a live Vm or a
dropped one (`each_vm_of_one_compiled_program_has_its_own_area`).

**Addressing.** `codegen::clif`'s `context_addr` reads the base from the Vm
argument at `VM_CONTEXT_OFFSET` (96), once per call: a function that reads
or writes the area loads it in its entry block (`context_base`), which
dominates every block (self tail calls included), and every access adds its
slot's constant offset. The load is `notrap aligned readonly`: a Vm's area
never moves once installed, and a `contextstore` writes into the area,
never the pointer.

It is deliberately not `can_move`. The first version was, and Cranelift
treated the movable load as pure and placed it at its uses, inside the
loops reading the context, one dependent load per iteration (found by the
benchmark: 1.38x the old time on a loop of context reads, section 15).
Without it, the load stays in the entry block and the loop reads straight
through the register.

`VM_CONTEXT_OFFSET` is in the runtime ABI fingerprint
(`aotimage::abi_words`), so a program object compiled for another layout
is refused before it runs.

Representative code, `std::linux::io::write` of
`examples/linux/context-hello.bot` (observed; tests/contexts.test's
`contexts-native-clif` and `contexts-native-machine-code` pin both):

```
CLIF (after):    block2(v0: i64, v1: i64):                    ; entry
                     v3 = load.i64 notrap aligned readonly v0+96   ; the Vm's area
                 block0:
                     v5 = load.i64 notrap aligned v3+8              ; stdout's descriptor
x86-64 (after):  mov    0x60(%rdi),%r8                       ; the Vm's area
                 mov    0x8(%r8),%rsi
x86-64 (before): lea    0x6655(%rip),%r9                     # <botlish_context_area>
                 mov    0x8(%r9),%rsi
```

The access is still two instructions per function (and one per further
access), with no helper call, no lookup, no lock and no extra argument.
The change is a load from the Vm, which is in a register at every Botlish
call, in place of a PC-relative address. The object has no context symbol
and no relocation against one (`contexts-native-object-relocation`,
`tests/platform/aot-facts.tcl`'s `object-symbols` and `object-relocations`,
on every host's object format).

**Rooting.** Unchanged. Every word of the area is a tagged immediate, a C
address word, or a MutableVector or MutableArray header. Installation also
registers every header in the Vm's own `context_roots` (`ctxroot`), so the
area itself is never scanned. Before this milestone the area was shared,
while the roots were already the Vm's: a second Vm's installation left the
first Vm reading headers rooted only by the second. Since the area is now
the Vm's, both agree.

**Teardown.** The table is the Vm's `Vec`, freed with it. No context value
is released at teardown: an installed context's members live as long as
its Vm (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md). The heap's objects are
freed by the heap's drop, as before.

## 5. Static selection

Nothing in `hir/`, `surface/`, `compiler/` or `core/` changed (static: the
branch's diff, `git diff 1faa9c9 -- hir surface compiler core` is empty).

* The context rules are untouched. Installation is still the entry
  program's top level only, with one selection per context trait per
  program, inferred requirements, restricted injection and the
  native-lowering eligibility of leaves.
* The NIR is byte-identical for the same HIR (`native/lower.tcl` changed
  only in comments). A context-trait operation is still a direct call of
  the selected implementation, compiled into the program, so every Vm of
  that program calls the same implementation.
* A Vm's construction makes no choice: it allocates storage of the
  program's layout and runs the program's own installation code.

In the harness every Vm installs the deterministic driver as the program's
`std::event_loop::Driver`, its own instance of the same selected
implementation. Its loop, timers and tasks are its own, which the per-index
results show (section 10). `tests/context-traits.test`,
`tests/restricted-injection.test`, `tests/actor.test` and
`tests/event-loop.test` pass unchanged (section 13).

## 6. Program metadata

**The old model's failure** (static, and shown by a test the old code
passed only by accident). `Vm::new` stored its program in the thread-local
`PROGRAM`, so on any thread the most recently made Vm's program was the
"current" one. A runtime operation of an older Vm on that thread read the
newer Vm's shapes and enums. A unit test in `ops.rs`
(`enum_hash_and_show_read_names_never_numbers`) made a second Vm and then
rendered a value of the first through `show`. It passed because the
rendering read the second Vm's table, where the case it looked up happened
to carry the expected name. With metadata read through the Vm, the test
names the Vm and now also checks that the first Vm still reads its own
case 2 ("Truck", not "Car") and its own hash.

**The new model.**

* `Vm::info` (an `Arc<ProgramInfo>`) is set once by `Vm::new`. It is the
  only program a Vm's operations read, through `ops::program(p)`:
  equality's tree, identity and opacity tests; the canonical walk's enum
  and struct names (both hashes); `std::tree::children`; NonFiniteFloat's
  payload tables.
* The renderers take the program as an argument: `show`, `show_fields`,
  `enum_names`, `tcl_value`. So does `RtError::message`, rendered at the
  program boundary with the Vm that recorded the error
  (`Vm::describe_error`).
* `ProgramInfo` is immutable and shared: the harness's Vms share one
  (`programs 1` in its summary), and nothing clones its tables per Vm.

**Native libraries.** An instance is a Vm of the library's program. It is
thread-affine (WRONG-THREAD) and one call at a time (REENTRANT-CALL), and
its calls no longer swap anything. Instances of different libraries on one
thread were already safe, since each library carries a private runtime copy
(NATIVE-LIBRARY-MILESTONE-1.md). Several instances of one library, and
nested calls into another library, now need no swap either. The
`nl-threads`, `nl-two-instances`, `nl-two-libraries` and
`nl-nested-libraries` tests pass (section 13). No export gained a context
or any other capability.

**Evidence of the new model.** Two programs whose enum 0 and shape 0 are
numbered alike but named differently, compiled once each in one runtime,
have their Vms made, run and dropped in turn on one thread, in both orders
(`codegen::program_metadata_tests`, observed):

* the hash of an enum case, computed by generated code, which reads the
  case's names, is each program's own in every interleaving;
* an equality refusal inside an opaque struct names that program's
  declaration, `<opaque geo::Token>` or `<opaque net::Handle>`.

**Remaining thread-local state.** Two thread-locals remain, and neither can
stand in for a Vm's metadata:

* the callback transition (`ACTIVE`, the Vm waiting in a C call that may
  call back) is how a callback C invokes finds its Vm. It is a pointer to
  a Vm, never to metadata, it is set only while that Vm is inside a
  transition on that thread, and it is restored when the transition closes;
* the coroutine stack pool holds mapped memory only.

## 7. Stack guards

**Records.** `runtime/platform/records.rs` holds 64 records in a static
table. Each record has:

* its owner: the thread's token (Linux's `gettid`, macOS's `pthread_self`,
  Windows' thread id), or free, or claiming;
* two slots of the stack the thread runs on now, and the one in use (the
  POSIX guard's [guard_low, low_bound), or Windows' reservation);
* the report's mode (the driver's or an executable's), its destination (a
  descriptor, or a handle) and a label of at most 48 bytes.

**Registration.** `OverflowGuard::install`, `install_executable` and
`install_labelled` claim a record for the calling thread:

* a record left by a dead thread of the same token, or else a free one,
  each taken with a compare-and-swap;
* the stack is published first and the owner stored last, so a handler
  never sees a half-claimed record;
* a thread-local index remembers the thread's record. A second claim on
  the same thread is refused (AlreadyExists), and claims on other threads
  are not.

Dropping the guard releases its record. A thread that ends holding one
releases it from the index's destructor, so a later thread that receives
the same token never inherits a record. The process's handler (POSIX
`sigaction` of SIGSEGV and SIGBUS with the saved previous dispositions, or
Windows' first vectored handler) is installed with the first guard and
restored after the last, under a mutex used only by installation and
removal.

**Publication.** `set_active_stack` writes into the calling thread's record
only, found through the thread-local index: a double buffer, then one
release store. A thread without a guard publishes nothing, and one thread
never overwrites another's published stack.

**Fault classification.**

* **The lookup.** The POSIX handler takes the faulting thread's token,
  scans the table for the record with that owner and compares the fault
  address with that record's published guard range. It uses atomic loads
  only: no thread-local access (which may allocate lazily in a shared
  object), no lock, no allocation. On a match it writes the record's label
  and `OVERFLOW_LINE` with write(2) to the record's destination, then
  `_exit`s. Otherwise it defers to the previous disposition, as before.
* **Windows.** It is the same with STATUS_STACK_OVERFLOW, the exception
  record's address, WriteFile and TerminateProcess.
* **What a test reads.** The label is empty except in the harness, so every
  existing report is byte-for-byte what it was. In the harness the line is
  `vm I error {NATIVE LIMIT STACK} {...}`, which names the overflowing
  thread.
* **Static checks.** `tests/concurrent-vms.test`'s `cv-source-guard-records`
  checks that the handlers look a record up by token, and that no
  process-wide published stack is left. A mutant that reads the record
  through a thread-local, and one that formats the report on the heap, are
  both killed by it (section 14).

**Terminal policy, unchanged.** A genuine overflow ends the process, in the
driver (exit status 0, the line its result) and in an executable (exit
status 1, the line on standard error), whichever thread overflowed. The
census suggested that VM isolation might make ending only that thread
safe. It does not. The faulting thread may hold a runtime or C library lock
(an allocator's), may be inside foreign code, or may be in the middle of a
publication. Ending it asynchronously could leave every other thread
deadlocked on that lock, or reading half-updated shared state. Nothing
establishes otherwise, so the milestone adds no thread-only termination.
A mutant that ends only the thread is a killed defect, not a candidate
design (section 14). The proactive, recoverable `NATIVE LIMIT STACK` check
of native libraries is unchanged (`Vm::stack_limit`, `nl-stack-safety`).

**Tests** (observed; native/tests/native_stack.rs's new `threads:*`
scenarios, each in a child process):

| check | scenario | result |
|---|---|---|
| threads second | A and B guarded, A publishing after B installed, B exhausts its stack | `vm 1 error {NATIVE LIMIT STACK} ...`, exit 0 |
| threads released | A's guard dropped and its thread joined, then B exhausts | `vm 1 ...` (B's record and the handler outlive A's), exit 0 |
| threads coroutine | B exhausts a coroutine stack (a Vm, rt_co_start) while A is guarded | `vm 1 ...`, exit 0: the switch published B's coroutine stack into B's record |
| threads churn | 16 threads install and drop guards 200 times each at once; then all records are free and one more thread exhausts | `vm 9 ...`, exit 0 |
| threads unguarded | A guarded, an unguarded B exhausts | killed by SIGABRT, exactly as with no guard anywhere: never relabelled |

`records_are_per_thread` and `a_reused_token_reclaims_a_stale_record`
(Rust) check that the records are per thread, that publication is
separated, that a second claim on one thread is refused, that the
destructor releases a record, and that a stale token is reclaimed. Every
existing check of native_stack.rs passes unchanged: every thread kind,
every mode, coroutine overflows, the faults a guard must not claim,
publication and the switch sweep. Windows has a test of two guarded
threads in `platform/windows.rs`.

## 8. Coroutines and callbacks

**Affinity is unchanged.** `Vm` is not `Send`, and no `Send` or `Sync` was
added to any Vm-owned structure. A coroutine runs only in the Vm that
created it, on that Vm's thread: its stack holds the Vm in its first frame
(`prepare`). Fusion, release, abandonment, cached errors and retained
providers are unchanged, and `tests/coroutines.test` and
`tests/coroutine-fusion.test` pass.

**The coroutine stack pool** is the thread's, and that is its proper owner:
a stack is an OS-thread resource, mapped memory with a guard. A pooled
stack carries no Vm. `prepare` writes the starting Vm into the new first
frame at every start. A mutant that keeps the first Vm that used the pool
is killed by `cv-rounds`, where each thread runs three Vms in turn
(section 14).

**Callbacks** still run only nested in the Vm waiting in a transition on the
same thread (`ACTIVE`). The transition's Vm is restored when it closes, so
no Vm pointer outlives a transition. A mutant that keeps it is killed by
`cb-refused-retained`. Removing the program swap changes nothing for
callbacks: a callback runs in the Vm it entered, whose own program its
operations read. `tests/c-callbacks.test` passes. Foreign threads still
cannot enter a Vm (THREAD).

## 9. GC isolation

The collector marks any word that looks like an object pointer. A pointer
into another Vm's heap would be followed, and its mark bit written from
another thread. Before this milestone, a shared context area made exactly
that possible: one Vm read a collection header installed by another. The
milestone removes the shared storage (section 4) and adds evidence that
no such pointer exists:

* **The ownership check** (`Heap::set_ownership_check`, a test hook the
  harness's `--check-heaps` turns on through `Vm::check_heap_ownership`).
  Every collection first builds the set of addresses it may follow: this
  heap's objects plus this Vm's static objects. Every root and every traced
  field is then looked up in it before its header is read. An address
  outside the set is counted in `foreign_pointers` and not followed: an
  object of another Vm, or freed memory. Every run of the harness reports
  the sum over all Vms: 0 in every test.
* **Poisoning** (`--poison`): every List and Struct a collection frees is
  overwritten, so a stale pointer reads poison.
* **GC stress**: a collection at every allocation of every Vm, concurrently.

`cv-gc-stress` (observed):

```
$ BOTLISH_NATIVE_GC_STRESS=1 botlish-native vms 4 --rendezvous 3 --check-heaps --poison workload.nir
vm 0 value {str {vm 0;deep 402;tree 2450;gen 30;churn ...}}
...
vms 4 rounds 1 rendezvous 4 areas 4 programs 1 guarded 4 overlap 1 foreign 0 collections {...}
```

That is four Vms, each its own oracle; each collected thousands of times
while the others ran, and none marked or followed a pointer outside its
own heap.

**Teardown.** Rounds of construction and teardown (`cv-rounds`,
`cv-gc-stress-rounds`) drop Vms while other threads' Vms run. A Vm's drop
frees its heap and statics and its context table. Nothing of it stays in
process-wide state: the program `Arc` it held is shared, and its guard
record belongs to its thread, not to it.

## 10. The concurrent-VM experiment

**What it exercises.** The brief's distinction is kept. Probe E of the
census used two instances of one native library, which have no contexts.
This experiment has one compiled code image, one immutable program
metadata, one context layout and one selection of every context-trait
requirement, and several independently initialized Vms with installed
contexts running at once on separate OS threads.

**The harness** (`native/src/main.rs`'s `concurrent_vms`):

```
botlish-native vms N FILE.nir [--rendezvous K] [--rounds R] [--check-heaps] [--poison]
```

It JIT-compiles FILE once and starts N threads, each with the driver's
stack size and a labelled guard (`vm I `). Each thread makes, runs and
drops R Vms in turn. Every Vm is made on its thread from the shared
`ProgramImage` (code entry, constants, generic entries, frame map, statics
count, context size) and the shared `ProgramInfo`. Its argument snapshot
ends in the thread's index I.

* `--rendezvous K` holds each first-round Vm at its K-th collection (a
  safepoint, mid-run, contexts installed) until every Vm has arrived or
  finished. "rendezvous N" therefore means all N were running at once,
  established by synchronization, not by elapsed time.
* While they wait, the harness records each Vm's context area address and
  program, and the number of guarded threads.
* A global sequence counter also records whether every Vm started before
  any ended ("overlap").

**The workload** (`tests/concurrent-vms/workload.bot`) installs four
contexts: `std::event_loop::create(64)`, `std::event_loop::deterministic::create()`
(the program's Driver selection), `std::actor::create()`, and the
application's `Node {id: I, log: MutableVector[str], tally: MutableArray[int]}`.
Then it:

* notes and counts into Node (context-owned collections mutated in place);
* recurses 400·(I+1) frames deep, each frame holding a List;
* builds a tree struct of 3·(50+10·min(I,3))+1 nodes;
* resumes a generator coroutine that requires Node;
* churns strings, Lists and a MutableMap for 400+100·I rounds;
* runs two actors' ping-pong for 20+5·I rounds on the loop. Their
  coroutines are owned by the Loop's vectors (context-owned affine state)
  and are suspended between turns.

Its result is a function of I alone. The oracle of Vm I is the same NIR run
alone by the driver's ordinary `run`, with argv `{botlish-runner I}`, and
`cv-oracle` checks that the oracle is also the outcome on interp, compile,
cranelift-generic and cranelift.

**Results** (observed, `tests/concurrent-vms.test`, all pass):

| test | run | every result its oracle | summary |
|---|---|---|---|
| cv-concurrent-2 | `vms 2 --rendezvous 2 --check-heaps`, GC_MIN 64 KiB | yes | rendezvous 2, areas 2, programs 1, guarded 2, overlap 1, foreign 0 |
| cv-concurrent-4 | `vms 4 --rendezvous 2 --check-heaps` | yes | rendezvous 4, areas 4, programs 1, guarded 4, overlap 1, foreign 0 |
| cv-concurrent-8 | `vms 8 --rendezvous 1 --check-heaps` | yes | rendezvous 8, areas 8, programs 1, guarded 8, overlap 1, foreign 0 |
| cv-rounds | `vms 4 --rounds 3 --check-heaps` | 12 of 12 | foreign 0 |
| cv-gc-stress | GC stress, `vms 4 --rendezvous 3 --check-heaps --poison` | yes | rendezvous 4, areas 4, programs 1, foreign 0; more than 1000 collections per Vm |
| cv-gc-stress-rounds | GC stress, `vms 2 --rounds 2 --check-heaps --poison` | 4 of 4 | foreign 0 |
| cv-overflow | `vms 4 --rendezvous 1` of `overflow.bot` (Vm 1 recurses forever, the others wait mid-run) | -- | the whole output is `vm 1 error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}`, exit 0 |

What the results establish:

* **Staggered termination.** Each index's workload is a different size, so
  the Vms end at different times; in the rounds tests, Vms are made while
  others run.
* **Independent state.** Each Vm's log length (7 + I) and its first and
  last entries (`vmI:start`, `vmI:end`) are its own. A shared Node would
  give one Vm's log another's entries and another's id. Each Vm's
  ping-pong total (40 + 10·I) is its own loop's.

A four-Vm run with the default collection threshold (observed, `vms 4
--rendezvous 2 --check-heaps`, GC_MIN 64 KiB):

```
vm 0 value {str {vm 0;deep 402;tree 2450;gen 30;churn 2032780;pingpong 40;log 7 vm0:start,vm0:gen 0,vm0:end;tally 2,4,2000}}
vm 1 value {str {vm 1;deep 802;tree 3661;gen 55;churn 3166530;pingpong 50;log 8 vm1:start,vm1:gen 0,vm1:end;tally 2,5,2500}}
vm 2 value {str {vm 2;deep 1202;tree 5112;gen 91;churn 4550280;pingpong 60;log 9 vm2:start,vm2:gen 0,vm2:end;tally 2,6,3000}}
vm 3 value {str {vm 3;deep 1602;tree 6803;gen 140;churn 6184030;pingpong 70;log 10 vm3:start,vm3:gen 0,vm3:end;tally 2,7,3500}}
vms 4 rounds 1 rendezvous 4 areas 4 programs 1 guarded 4 overlap 1 foreign 0 collections {6 7 8 8}
```

(This run used the workload's earlier churn size of 2000 + 500·I; the
committed workload uses 400 + 100·I, which keeps the interpreter's oracle
cheap.)

**The experiment catches the defects it is for** (section 14, observed).
Each of these defects was put back into the runtime as a mutant:

* **A shared context area.** With every Vm addressing the first Vm's area
  (`ctx-first-vm-area`), `cv-concurrent-2`, `-4` and `-8` fail: each Vm's
  installation overwrites the others' Node, so the results are no longer
  the oracles.
* **Roots in the wrong Vm.** With context collections rooted in the first
  Vm made (`ctx-roots-wrong-vm`), `cv-gc-stress` fails: the other Vms'
  collectors free their own context vectors while the Vms still use them.
* **A stale pooled stack.** With a pooled coroutine stack starting with the
  first Vm that used the pool (`pool-stale-vm`), `cv-rounds` fails: a
  thread's second Vm runs its coroutines against its dropped first Vm.

**Why not a library.** Library mode cannot hold this experiment: an export
may not require a context (EXPORT-ENVIRONMENT) and a library's entry file
holds declarations only (LIBRARY-TOP-LEVEL), so a library instance never
installs a context. The JIT harness is the repository-consistent mechanism
for running one program's Vms with contexts. It is the driver's, like
`bench` and `batch`, and adds nothing to Botlish.

## 11. Resource ownership

**Context-owned affine state.**

* Each harness Vm's Loop holds its tasks' coroutine handles in
  MutableVectors (affine, owned by the installed context). Its actors'
  coroutines are suspended there between turns.
* No other Vm can observe, copy or release them. Another Vm's code reads
  only its own area, and its collector follows only its own heap (foreign
  0 in every run). Its teardown frees only its own objects.
* The compiler's restrictions are unchanged: AFFINE-CONTEXT-COPY-OUT, place
  receivers, no capture. No source-level rule was added.

**Exclusive external resources.**

* A context whose construction acquires a native resource acquires it once
  per Vm that installs it, since every Vm runs its own installation.
* A resource that admits one owner reports busy to the second acquirer
  through its own acquisition contract. The second Vm never receives a copy
  of the first's handle, because there is no shared area to copy it through.
* The milestone adds no singleton or exclusive context, no process-wide
  context value, and no sharing.
* The broker pattern (an owner Vm serving typed requests from workers'
  broker contexts) is M4's, over its message transport (projected).

## 12. Backend and platform matrix

| target | context base from the Vm | program metadata through the Vm | per-thread guard records | concurrent Vms of one program | evidence |
|---|---|---|---|---|---|
| Linux x86-64 | yes | yes | yes | yes, 2-8 Vms, also under GC stress | observed (sections 7, 10, 13) |
| Linux AArch64 | yes (the same CLIF: an AArch64 `ldr` from the Vm) | yes | yes (guard.rs, shared) | the same tests | type-checked here (`cargo check --target aarch64-unknown-linux-gnu --lib --bins --tests`); @@CI-ARM64@@ |
| macOS AArch64 | yes | yes | yes (guard.rs, shared; macos.rs unchanged) | the same tests (the acceptance tier globs every test file) | type-checked here (`--target aarch64-apple-darwin`); @@CI-MACOS@@ |
| Windows x86-64 (MSVC) | yes | yes | yes (windows.rs over the same records) | the same tests | type-checked here (`--target x86_64-pc-windows-msvc`); @@CI-WINDOWS@@ |

* **macOS main-thread executables.** The startup is unchanged: the guard is
  installed on whichever thread runs the program, and the records do not
  care which thread that is (`tests/main-thread-startup.test`).
* **The fallback root plan** (`--features fallback-roots`) builds and its
  tests compile (`cargo check`); the Windows `roots` job runs them (CI).
* **The Tcl backends** are unchanged. They have no OS threads, and nothing
  simulates concurrent Vms in one interpreter. `cv-oracle` runs them only
  as the single-Vm oracle.

## 13. Regression testing

@@REGRESSION@@

## 14. Mutation testing

`audit/per-thread-runtime/tools/mutate.tcl`, mutants in its `mutants.txt`,
each naming (`!!`) the detectors meant to kill it.

* **Baseline.** A private copy of the tree first runs every named detector
  unmutated, and all must pass.
* **Per mutant.** The copy's native backend is rebuilt and only that
  mutant's own detectors run.
* **Kills.** A mutant is killed only when one of its own detectors fails or
  does not complete. A crash of an unrelated test is never counted.

Run on Linux x86-64 (observed). 20 mutants on the first run: 18 killed, 2
survived; the two survivors' detector was too weak and was strengthened,
and both were then killed (`mutate.tcl -only
guard-handler-thread-local,guard-handler-allocates`: 2 killed). 20 of 20.

| mutant | the defect | killed by |
|---|---|---|
| ctx-process-wide-area | the context area one process-wide object again | rust-bin `each_vm_of_one_compiled_program_has_its_own_area` |
| ctx-first-vm-area | every Vm addresses the first Vm's area | `cv-concurrent-2`, `-4`, `-8` (each Vm's result no longer its oracle) |
| ctx-recycled-uncleared | a new Vm takes a dropped Vm's area, uncleared | rust-bin `each_vm_of_one_compiled_program_has_its_own_area` |
| ctx-reset-keeps-installation | a reset keeps the previous run's installation | rust-bin `each_vm_of_one_compiled_program_has_its_own_area` |
| ctx-roots-wrong-vm | a context collection rooted in the first Vm, not its own | `cv-gc-stress` |
| ctx-wrong-slot | a context load reads the next word (the wrong layout) | contexts.test's `contexts-native-*` (eight tests) |
| prog-latest-vm | metadata read from the Vm made last on the thread (the old thread-local, restored) | rust-bin `two_programs_alternate_on_one_thread` |
| prog-first-process-wide | metadata read from one process-wide program, the first | rust-bin `two_programs_alternate_on_one_thread` |
| prog-show-first-process-wide | rendering reads the first program seen | rust-bin `a_refusal_names_its_own_programs_declaration` |
| guard-one-thread | one guarded thread per process | native_stack `threads second`, `released`, `coroutine`, `churn` |
| guard-publish-process-wide | every publication goes to the first record | native_stack `threads second`, `released`, `churn` |
| guard-wrong-thread | the handler takes the first record, whatever thread faulted | rust-lib `records_are_per_thread` |
| guard-release-other | a release frees the first record in use | native_stack `threads released` |
| guard-handler-removed-early | every drop restores the dispositions | native_stack `threads released` |
| guard-stale-after-exit | a thread that ends holding a record keeps it | rust-lib `records_are_per_thread` |
| guard-handler-thread-local | the POSIX handler reads the record through a thread-local (not async-signal-safe) | first run: SURVIVED; then `cv-source-guard-records` |
| guard-handler-allocates | the POSIX handler formats its report on the heap | first run: SURVIVED; then `cv-source-guard-records` |
| guard-thread-only-termination | an overflow ends only the faulting thread | native_stack `threads second`, `released`, `coroutine`, `churn` |
| pool-stale-vm | a pooled coroutine stack starts with the pool's first Vm | `cv-rounds` |
| callback-active-kept | a closed transition leaves its Vm waiting | c-callbacks.test `cb-refused-retained` |

**The two survivors.** Both are async-signal-safety defects, which no
dynamic test catches reliably: a thread-local read or a heap allocation in
a fault handler works until the faulting thread holds the allocator's lock,
or until its thread-locals are not yet allocated. Their detector,
`cv-source-guard-records`, matched `records::find(super::thread_token())`
anywhere in guard.rs; `report_fatal` holds that text too, so the check
never looked at the handler itself. It now extracts the handler's own
functions -- POSIX `fault_handler`, `is_overflow`, `report_overflow`,
`write_all` and `defer`; Windows `handler`, `is_overflow`, `write_all` and
`terminate`; the records' `find` -- and requires the token lookup there and
no thread-local, lock, allocation or formatting in any of them.

**Not mutated, with the reason** (mutants.txt's header): releasing another
Vm's context-owned affine resource (no runtime code releases context state:
only a shared area could reach another Vm's, which two mutants above are);
sharing a collection backing (only reachable through a shared area or a
stale root); an unsynchronized shared runtime cache (none exists); freeing
program metadata a Vm still uses (an `Arc`: no safe edit does it).

The harness ran on Linux x86-64 only. Mutants with a `%%` line run only
on the hosts it names (the POSIX handler's on Linux and macOS; the
thread-only termination's, a raw `SYS_exit`, on Linux), and the records'
mutants apply on every host, Windows' guard included. The native_stack
`threads` scenarios are POSIX-only; on Windows the records' unit tests and
`platform/windows.rs`'s two-thread test are the detectors. Running the
harness on the other hosts is not done here.

## 15. Performance

@@PERF@@

## 16. Remaining limitations

* **One event loop per process on Linux.** The Linux event-loop adapter is
  one static `E` (`packages/event_loop_linux/native/event_loop_linux.c`):
  one epoll, one eventfd, one endpoint table per process. The harness's
  workload uses the deterministic driver for that reason, and nothing in
  this milestone depends on the adapter. ABI v2, a loop handle with
  per-loop adapter state, is M4's.
* **No Botlish-owned threads.** No program can start a thread. The harness
  starts host threads to prove that Vms can run concurrently; it is not a
  thread API.
* **At most 64 guarded threads at once.** The guard's table is fixed so
  that the handlers can scan it in place. A 65th install is refused with
  an error naming the bound. M4 must size its thread pool under it, or
  make the table larger (a constant).
* **Each Vm of a linked program decodes its own descriptor.** A linked
  program (executables, libraries) decodes its descriptor's `ProgramInfo`
  once per Vm, as before; only the JIT harness shares one decoded
  `ProgramInfo` among its Vms. M4 can decode once per program and hand the
  `Arc` to each thread's Vm.
* **Overflow ends the process,** whichever thread overflows (section 7).
  Thread-only termination would need evidence that the faulting thread
  holds nothing the others need, which a native fault cannot give.
* **The THREAD/INACTIVE diagnosis is a heuristic.** `LAST_THREAD` tells a
  callback on a foreign thread (THREAD) from one outside a transition
  (INACTIVE) using the last thread that opened one, so with several VM
  threads it may name the wrong one. The refusal is the same either way.

## 17. What M4 can rely on

* **Per-thread Vms.** A thread can make a Vm of a compiled program and run
  it while other threads run other Vms of the same program. It installs the
  program the way the JIT harness does (`ProgramImage::install`, or a
  linked program's `program::instantiate`): its own constants, statics and
  context area, sharing the code and the `Arc<ProgramInfo>`. The context
  layout and every context-trait selection are the program's; a thread
  entry's installation code runs in its own Vm.
* **A guard per thread.** Install one with `OverflowGuard::install` (or
  `install_labelled` to name the thread in the report), at most 64 at once.
  It is released when it drops or when its thread ends.
* **No shared Vm state.** Shapes and enum numbers agree between Vms of one
  program, but no heap object, backing, context value or root crosses
  between Vms. Values cross by `std::transfer` (M2) or by copies a host
  makes. The collector of one Vm never follows a pointer into another's
  heap; the ownership check is there to prove it in M4's tests.
* **Thread affinity.** A Vm, its coroutines and their stacks stay on the
  thread that made them. A thread may make and drop Vms in turn; its
  coroutine pool and callback state hold no Vm across them.
* **What M4 still builds.** Thread lifecycle (`std::thread`, spawn, a stop
  and a bounded join), multi-entry compilation, the event-loop ABI v2 with
  a loop handle and payload records, the cross-thread address and the
  inbound bridge, and the Tcl backends' build-time refusal of threads.

## 18. Reproducing

Prerequisites: `tclsh9.0` (AGENTS.md, "Installing Tcl 9"), the native
backend (`cargo build --release --manifest-path native/Cargo.toml`) and
`LANG=C.utf8 LC_ALL=C.utf8`.

```sh
# The concurrent-VM experiment, the context and guard checks
tclsh9.0 tests/concurrent-vms.test
tclsh9.0 tests/contexts.test -match 'contexts-native-*'
tclsh9.0 tests/platform/aot-facts.tcl
cargo test --release --manifest-path native/Cargo.toml --lib --bins
cargo test --release --manifest-path native/Cargo.toml --test native_stack

# The harness by hand (WORKLOAD.nir: native::nir of tests/concurrent-vms/workload.bot)
BOTLISH_NATIVE_GC_MIN=65536 native/target/release/botlish-native vms 4 --rendezvous 2 --check-heaps WORKLOAD.nir
BOTLISH_NATIVE_GC_STRESS=1 native/target/release/botlish-native vms 4 --rendezvous 3 --check-heaps --poison WORKLOAD.nir

# Mutation testing, and the performance report against a driver built before the milestone
tclsh9.0 audit/per-thread-runtime/tools/mutate.tcl
tclsh9.0 bench/per-thread-runtime.tcl -baseline OLD/native/target/release/botlish-native
```
