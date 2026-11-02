# THREAD-ACTOR-ARCHITECTURE-CENSUS.md

Isolated threads, actors and message passing: a census of what Botlish's
coroutines, affine values, contexts, `std::event_loop`, GC and native
libraries already provide, six small probes, and a dependency-ordered
roadmap. This is a census and exploratory milestone. It implements nothing:
no file in `core/`, `hir/`, `surface/`, `compiler/`, `native/`, `stdlib/` or
`packages/` changed. The probes are in `audit/thread-actor/` and are
disposable.

Evidence labels used throughout:

* **observed**: a probe ran and printed it (the outputs are in
  `audit/thread-actor/results/`);
* **compiled**: the compiler accepted or rejected a program as stated;
* **inferred**: read from the code at the cited lines, not exercised;
* **projected**: a design consequence, not yet built.

Environment: commit `666b6f8e828c12b3e759c79d6688ff40b3aa7ac7`, Linux
6.18.44 x86-64 (4 vCPUs, Intel Xeon @ 2.10 GHz, a shared container), Tcl
9.0.1 (`tclsh9.0`, the Ubuntu 25.04 packages), rustc 1.97.0, cc 13.3.0. Every
measured number is from that one machine, and run-to-run spreads are
quoted.

## Contents

1. [Executive conclusion](#1-executive-conclusion)
2. [Existing capability census](#2-existing-capability-census)
3. [Recommended architecture](#3-recommended-architecture)
4. [Ownership model](#4-ownership-model)
5. [Message and sendability model](#5-message-and-sendability-model)
6. [Actor identity and lifetime](#6-actor-identity-and-lifetime)
7. [Scheduler integration](#7-scheduler-integration)
8. [Context and authority integration](#8-context-and-authority-integration)
9. [Errors, cancellation and shutdown](#9-errors-cancellation-and-shutdown)
10. [Native runtime and GC requirements](#10-native-runtime-and-gc-requirements)
11. [Platform and backend matrix](#11-platform-and-backend-matrix)
12. [Exploratory results](#12-exploratory-results)
13. [Competing designs](#13-competing-designs)
14. [Proposed public API](#14-proposed-public-api)
15. [Implementation roadmap](#15-implementation-roadmap)
16. [Explicitly deferred work](#16-explicitly-deferred-work)
17. [Reproducing](#17-reproducing)

---

## 1. Executive conclusion

**Yes.** A thread/actor architecture built mainly over the existing
coroutines and `std::event_loop` is viable. The evidence splits the problem
in two.

**Same-thread actors need no new compiler or runtime facility.**
* Probe A builds typed, independently addressable actors in ordinary
  Botlish: an actor is an event-loop task, its mailbox a slot of a typed
  `Postbox[M]`, and its address a generation-checked opaque value.
* The probe covers private state, request/reply, a handler that suspends
  while other actors progress, backpressure, stale addresses, shutdown and
  failure.
* It runs on all four backends with one identical trace, also under native
  GC stress (observed).
* Two things in it are conventions, not guarantees: that a receive right has
  one holder, and that the mailbox of a failed actor gets closed. Each has a
  small, named fix (section 6).

**Cross-thread actors need runtime work, but not a second scheduler.** The
runtime must own:
* OS threads;
* the per-thread state the runtime keeps process-wide today (the overflow
  guard, the native context area);
* a loop identity in the native integration ABI;
* a copy-in message transport that never shares heap pointers.

Everything an actor *does* stays in Botlish over `std::event_loop`:
dispatch, mailboxes, request/reply, lifecycle. This is the hybrid
architecture C of section 13. The probes also exclude the alternatives:
* No requirement surfaced that the existing turn cannot meet (section 7),
  so a native actor scheduler (B) has nothing to buy.
* One VM per actor on one thread (the model of COROUTINE-PREREQUISITES.md
  §6, "An actor is a `Vm`") buys nothing in-thread that the language does
  not already guarantee.

**The central design decision is "a thread is a VM; an actor is a task".**
* Inside one VM, Botlish has no references. MutableVector, MutableArray and
  MutableMap are values: a message is a logical copy. Probe C's runtime half
  shows the sender's later mutation never reaching the receiver, on all four
  backends.
* The only shared mutable state inside a VM is the installed contexts, which
  are static, program-wide and explicitly required.
* So isolation between actors on one thread is a language property already.
  Heap isolation is needed only where parallelism is, between threads.
* There, every message is a deep copy, made by the receiving thread into its
  own heap. Probes B and E did exactly that with today's FFI and library
  mode, and survived GC stress.

**A thread's entry point is an entry program.** Contexts are installed only
at an entry program's top level (`hir/contexts.tcl:702-718`).
* So the smallest coherent rule is that every Botlish thread runs an entry
  program of its own, with its own static installation: its loop, its
  driver, its mailboxes, its authority.
* The context rule does not change. Authority differs between threads
  exactly as their entry programs say, and a message carries data, never
  authority.

**The first milestone** is same-thread actors, as a standard-library module
over `std::event_loop` (M1, section 15).
* It needs no compiler change, beyond perhaps an internal affine token of
  the kind `std::io::fs::Owner` already is.
* Its addresses are opaque, so under the sendability rule of M2 they stay
  thread-local by default. That is why M1 can ship before M2 without
  misleading types.
* M2 (sendability and the copy operation) and M3 (per-thread runtime state)
  are independent of M1 and of each other. M4 (Botlish-owned threads) needs
  all three.

## 2. Existing capability census

Each row is what the code does today, with its evidence. The subsystem
reports are COROUTINES.md, AFFINE-VALUES.md, COROUTINE-FUSION-MILESTONE-1.md,
EVENT-LOOP-MILESTONE-1.md, CONTEXTS.md, CONTEXT-TRAITS.md,
CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md, DIRECT-MODULES.md,
MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md, NATIVE-LIBRARY-MILESTONE-1.md,
C-CALLBACK-MILESTONE-1.md and REACT-NATIVE-TARGET-CENSUS.md.

### 2.1 Coroutines

| guarantee | what it is | evidence |
|---|---|---|
| eager construction | `coroutine {step, first} = f(a)`: arguments evaluated into temporaries, `coroutine#create` runs nothing, `coroutine#start` runs the body to its first yield, return or unhandled failure; a failure there reaches the constructor | `surface/lower.tcl:590-680`; `core/coroutines.tcl:107-116` |
| handle type | `Coroutine{args: [M] or [], return: R, errors: [...]}`: one outward type for yields and the result; no equality, no hash | `hir/types.tcl:615-648`; COROUTINES.md:422-431, 536-538 |
| deep yield | a static effect over the exact call graph; any function a coroutine runs may yield at any depth; a construction stops the effect; a yielding function cannot be a value, and top-level code cannot reach one | `hir/coroutines.tcl:28-54, 1679-1765` |
| resume protocol | one protocol per yielding chain (`none < {unit, T} < conflict`); `resume T` names a struct; a wrong message is a static TYPE | `hir/coroutines.tcl:55-77`; COROUTINES.md:303-361 |
| completion | resuming a completed coroutine returns its cached result; resuming a failed one raises its cached error again | `core/coroutines.tcl:151-162`; `native/src/runtime/coroutine.rs:711-747` |
| contract | the outward type, the resume message and error payloads must be unrestricted (COROUTINE-CONTRACT); affine values enter at construction | `hir/coroutines.tcl:1850-1889` |
| contexts | fixed at construction; a resume selects nothing, so a handle constructed under the installed contexts can be resumed from code with no context requirement | COROUTINES.md:645-664; contexts census probe `p7` (observed) |
| release | after the handle's last use and on every early exit; runs no Botlish code; no `finally` | `hir/affine.tcl:1599-1645, 1934`; COROUTINES.md:1381-1386 |
| native stacks | one mmap'd stack per coroutine (`MAP_NORESERVE`, 8 MiB default, `BOTLISH_NATIVE_COROUTINE_STACK_BYTES`), a 64 KiB `PROT_NONE` guard, a thread-local pool of 32; Windows fibers | `coroutine.rs:220-355`; `coroutine/windows.rs:1-66` |
| GC | running coroutines and resumer stacks are roots; a suspended coroutine is walked when its handle is marked | `vm.rs:620-650`; `heap.rs:175-187` |
| fusion | only a handle that never leaves its constructing function; an event-loop task (handed to `adopt`) is never fused | `codegen/fusion.rs:349-457` (inferred for tasks) |

### 2.2 Affine values

* **What is affine.** A coroutine handle and a C address (`cptr`, `cfnptr`)
  are the primitive affine roots. A struct, List, MutableVector or
  MutableArray holding one is affine too (`hir/types.tcl:718-800`).
  AFFINE-VALUES.md:278-282 still says the coroutine handle is the only
  root; the code says otherwise.
* **Where affine values may go.** They move through bindings, arguments,
  results, struct fields and collection elements (`hir/affine.tcl:466-752`).
* **What is rejected.** Capture by a closure (AFFINE-CAPTURE-UNSUPPORTED),
  erasure to `any`, equality, and copying out of a context place
  (AFFINE-CONTEXT-COPY-OUT, `hir/affine.tcl:306-316`).
* **Nothing at run time.** There is no moved flag and no reference count
  (`hir/affine.tcl:56-58`).
* **The event loop as precedent.** `std::event_loop` keeps its tasks in a
  context this way: the `Loop` holds `MutableVector[Coroutine{...}]`
  fields; `adopt` moves a handle in, and the turn pops, resumes and pushes
  it back (`stdlib/event_loop.bot:372-392, 1269-1272`).

### 2.3 `std::event_loop`

Production code, unchanged by this census (EVENT-LOOP-MILESTONE-1.md):

* **One thread-local scheduler** in ordinary Botlish (`stdlib/event_loop.bot:1`).
* **A frozen four-phase turn:** wait, collect, dispatch, observe.
* **Fairness:** FIFO dispatch of exactly the tasks ready at the start of
  the phase, and round-robin across sources.
* **Liveness:** channels never keep the loop alive.
* **Delivery policies:** Lossy, Coalesce and Reliable. Reliable never drops;
  its backpressure reaches the native producer.
* **Revocation:** generation-checked.
* **Fault channels:** a task's failure is its outcome; `SchedulerFault`
  means a scheduler bug.
* **Drivers:** the application chooses the driver as a context trait
  (`Driver`, `stdlib/event_loop.bot:232-240`).
* **Producer threads** only post four copied scalars
  (`packages/event_loop_linux/native/botlish_event_loop.h:76`) and never
  run Botlish code.

**Limits that matter here:**
* A Botlish `post(reg, a, b)` carries two Ints (`stdlib/event_loop.bot:1068`).
* The Linux adapter is one loop per process: one static `E` with one epoll
  instance, one eventfd and one endpoint table
  (`packages/event_loop_linux/native/event_loop_linux.c:110-127`;
  EVENT-LOOP-MILESTONE-1.md:1056-1058, "one driver per process").

### 2.4 Contexts and authority

* **Installation.** Only the entry program installs a context, at its top
  level, unconditionally, once per type:
  * inside a function: CONTEXT-INSTALLATION-UNSUPPORTED,
    `hir/contexts.tcl:702-706`;
  * not a root statement, or not the top scope: `:712-718`;
  * in a module: `surface/modules.tcl:1595-1600`.
* **Requirements** are inferred transitively and checked at top-level calls
  (`hir/contexts.tcl:789-870, 707-745`).
* **No function values.** A function with a requirement can never become a
  value (CONTEXT-FUNCTION-VALUE, `hir/contexts.tcl:1090-1125`). Context
  requirements are not part of function types (CONTEXTS.md:313).
* **Context traits:** exactly one selection per trait per program
  (`hir/contexts.tcl:735-742, 949-971`).
* **Native representation:** one process-wide data symbol
  `botlish_context_area` per program. It is "not thread-local: process-wide
  storage of the main execution domain" (`native/src/codegen/clif.rs:526-539`).
  CONTEXTS.md:826-827 records "no TLS or actor-local base", and :958-960
  plans one ("a lowering change only; no source change").
* **Leaves:** the area's leaves are small-domain Ints, bools, enums, C words
  and collection headers. Anything else is CONTEXT-NATIVE-LOWERING-UNSUPPORTED
  (`native/lower.tcl:4568-4603`; Probe A met it, section 12.1).
* **Direct modules:** raw authority is mediated only by a context the
  calling module declares (`hir/direct.tcl:269-290`).
* **Opacity:** opaque structs cannot be built or projected outside their
  module (`hir/resolve.tcl:2020`).
* **Native libraries:** an export may not require a context
  (EXPORT-ENVIRONMENT, `hir/exports.tcl:206-213`).

### 2.5 Native runtime, GC and library mode

Most of a VM's state is per VM already: the heap, statics, constants,
roots, the pending error, stack bounds, transition segments and the
coroutine chain (`native/src/runtime/vm.rs:151-305`). What is not:

* **Thread-local**:
  * `PROGRAM`, the current program's metadata (`vm.rs:127-129`). Last
    writer wins per thread; the library's `ProgramScope` swaps it per call
    (`library.rs:228-240`).
  * The callback transition `ACTIVE` (`callback.rs:74-78`).
  * The coroutine stack `POOL` (`coroutine.rs:225-227`).
* **Process-global**:
  * The overflow guard: one guarded thread per process
    (`platform/guard.rs:39-42, 55-76`), and publication does not check
    which thread publishes (`:92-104`).
  * The table-hash key (`ops.rs:1645`, per runtime copy).
  * The context area (above).
* **Tied to its creating thread.**
  * `Vm::new` records the creating thread's stack, and the collector's walk
    is bounded by it (`vm.rs:324-330, 630-641`).
  * Every coroutine stack holds the Vm pointer in its initial frame
    (`coroutine.rs:618-629`).
  * MutableVector and MutableArray backings are non-atomic `Rc`
    (`mutvec.rs:59-62`, `value.rs:350-356`).
  * So a VM never moves between threads, and a value graph is never shared
    by pointer.
* **No ownership check in the collector.** Any non-null word with the low
  three bits clear is an object (`value.rs:877-879`). Marking writes the
  mark bit into whatever object the word points to (`heap.rs:143-146`).
  A pointer into another VM's heap would be followed, and would leave a
  stray mark. That is risk R9 of COROUTINE-PREREQUISITES.md:810.
* **Library mode.**
  * Instances are thread-affine (WRONG-THREAD, `library.rs:204-205`), one
    call at a time (REENTRANT-CALL, `:207-208`).
  * Instances on different threads run concurrently
    (NATIVE-LIBRARY-MILESTONE-1.md:545-547).
  * Each library has a private runtime copy (symbols localized,
    `native/library.tcl:181`).
  * Arguments are converted into the instance's own heap and rooted in
    `temp_roots` (`library.rs:336-347`). A str result is a malloc'd copy
    (`library.rs:399`).
  * Botlish recursion is bounded proactively (`nir.rs:2367-2386`;
    `native_stack.rs:42-45`).
  * An entry file holds declarations only (LIBRARY-TOP-LEVEL).
* **Startup.** Executables run the program on a worker thread with a 1 GiB
  stack (`BOTLISH_NATIVE_STACK_BYTES`, `aot.rs:327-332`), or, on macOS
  AArch64 only, on the main thread (`aot.rs:230`).
* **Overflow** is terminal for executables, by design (`guard.rs:17-18`;
  NATIVE-STACK-OVERFLOW.md:40-44).

### 2.6 C callbacks

A synchronous `callback c fn` runs nested in the waiting VM. It is only
admitted during a noescape C call on the same thread, and only on the
running stack. Otherwise it is THREAD, INACTIVE or STACK, each fatal
(`callback.rs:296-325`). It is not an entry point for a foreign thread, and
C-CALLBACK-MILESTONE-1.md:331-345 and 905-907 leave worker-thread entry to
this design.

### 2.7 What earlier documents decided

* **COROUTINE-PREREQUISITES.md §1 and §6** (lines 120-160, 859-902) laid
  out "thread → actors → coroutines", with "an actor is a `Vm`". Its
  invariants C3 (one coroutine at a time per actor) and C4 (a handle never
  leaves its actor) hold today. The "actor is a Vm" choice is revisited in
  section 13.2.
* **NATIVE-LIBRARY-MILESTONE-1.md:1030-1031** says recovering from an
  overflow in C or the runtime "belongs to the thread/actor milestone".
  **:557-560** says an actor-aware layer can own instances without changing
  the C signature.
* **REACT-NATIVE-TARGET-CENSUS.md:83-87** says Botlish must run on a thread
  of its own with a large stack, since a JS thread has 512 KiB to 1 MiB.
  **:689-711** gives an asynchronous variant (one worker with a 256 MiB
  stack). **:1166-1168** says Botlish-side actors are "a language and
  runtime design of their own".
* **MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md:909-913** names its cross-thread
  request queue "exactly the cross-thread messaging the actor model is to
  design".

## 3. Recommended architecture

```
 process
 ┌──────────────────────────────────────────────────────────────────────────┐
 │ program image (read-only, shared): machine code, LinkedProgram record,   │
 │ shape/enum/error tables                                                  │
 │                                                                          │
 │  Botlish thread T0 (entry program main.bot)   Botlish thread T1 (worker.bot)
 │  ┌──────────────────────────────────┐        ┌──────────────────────────┐ │
 │  │ OS thread, runtime-owned stack   │        │ OS thread, own stack     │ │
 │  │ VM: heap + GC, statics, roots    │        │ VM: heap + GC, ...       │ │
 │  │ contexts installed by main.bot:  │        │ contexts installed by    │ │
 │  │   Loop, Driver, Mail, IO, ...    │        │   worker.bot: Loop,      │ │
 │  │   (its own context area)         │        │   Driver, Mail, ...      │ │
 │  │ std::event_loop turn             │        │ std::event_loop turn     │ │
 │  │  ├ root actor (top-level code)   │        │  ├ root actor            │ │
 │  │  ├ actor a: task + mailbox slot  │        │  ├ actor x               │ │
 │  │  └ actor b: task + mailbox slot  │        │  └ actor y               │ │
 │  │ inbound bridge task  <───────────┼── copy ┼── outbound send          │ │
 │  └──────────────▲───────────────────┘ bytes  └──────────────────────────┘ │
 │                 │ post(loop, endpoint, record + copied payload)           │
 │  runtime transport (C/Rust): per-loop endpoints, wakeup fd, payload       │
 │  buffers owned by the transport, never by a heap                          │
 │                 ▲                                                         │
 │  foreign host thread (JS, GUI, C): botlish_thread_post(...) / completion  │
 └──────────────────────────────────────────────────────────────────────────┘
```

* **A Botlish thread** is an OS thread with a runtime-owned stack, one VM
  (heap and collector), one program instance and its own context area.
  Its entry program's installation runs on that thread.
* **The event loop.** One `std::event_loop` per Botlish thread, driven by
  the driver that thread's entry installs.
* **An actor** is an event-loop task (a coroutine), a mailbox slot in a
  typed `Postbox[M]` owned by a context of its thread, and an opaque,
  generation-checked address.
* **The root actor** is the entry program's top-level code, which installs
  the contexts, starts the actors and runs the loop.
* **Same-thread messages** are ordinary Botlish values: a logical copy, with
  no runtime involvement beyond the loop.
* **Cross-thread messages** are serialized by the sending VM into
  transport-owned bytes, posted to the receiving thread's loop, and rebuilt
  by the receiving VM in its own heap during its own turn.
* **A foreign host** posts into a Botlish thread's transport and receives
  completions from it. It never calls into a VM.

## 4. Ownership model

Ownership is stated per owner. "Where machine code runs" is a different
question, answered at the bottom of the table.

| owner | owns | why there |
|---|---|---|
| **program** (image, shared, read-only) | machine code, the `LinkedProgram` record (`unsafe impl Sync`, `program.rs:126-128`), shape, enum and error tables, stack maps, module static *definitions* | never written after load; two VMs of one program agree on every shape and enum number, which is what makes a copy between them cheap |
| **thread = VM** | the heap and its collector, module static *instances* (`statics_table`), constants and canonical empties, roots, the pending error and payload, the native stack's bounds, the coroutine chain and stack pool, callback transitions, the installed contexts (their values and their context area), the event loop and its driver, the transport endpoints it reads | one collector per OS thread is the only arrangement the runtime supports: a VM records its creating thread's stack (`vm.rs:324-330`), `Rc` backings are non-atomic, and frames hold the VM pointer (`coroutine.rs:618-629`) |
| **actor** (an event-loop task) | its coroutine (moved into the Loop by `adopt`), its private state (the coroutine's locals and fold intermediates: no other code can name them), the coroutines it constructs and resumes itself, its receive right | an actor is a computation, not a memory region: its state is unreachable from other actors by construction, without a heap of its own |
| **mailbox** (a slot of a `Postbox[M]`) | queued messages, their generation, the wake channel | the postbox is a field of an application context of the thread, so the thread owns the storage and the actor owns the right to drain it |
| **transport** (runtime) | message bytes in flight between threads, endpoint rings, the wakeup descriptor | C or Rust memory that no collector traces (Probe B's payload table, Probe E's queue) |

**Pending coroutines when their actor terminates.** The coroutines an actor
constructed are its values. They are released when the actor's coroutine is
released or completes, by the ordinary affine release, which runs no
Botlish code.

**Moving an actor to another thread** is not worth allowing.
* A suspended native coroutine holds its VM in registers and spill slots
  (risk R10).
* Its object graph lives in its VM's heap.
* A move would mean copying the graph and relocating frames, which
  COROUTINE-PREREQUISITES.md §6 already rejects as future work.
* A frameless actor (not yet started) is a closure plus arguments, both
  values. "Migrating" one is the same as starting it elsewhere with copied
  arguments, which a cross-thread start request already expresses.

**Several native libraries in one process** each carry a private runtime
copy (NATIVE-LIBRARY-MILESTONE-1.md:650). They are different programs. A
message between them crosses a program boundary as well as a VM boundary,
so it must be copied by names, not shape numbers (section 5.4).

**Where machine code runs.**
* An actor's handler runs on its coroutine's stack (8 MiB by default).
* The root actor and the loop run on the thread's own stack.
* Fused coroutines run on their consumer's stack.

## 5. Message and sendability model

### 5.1 In one thread: the language already isolates

Probe C's runtime half (`audit/thread-actor/probe-a/sendvalues.bot`, all
four backends, also under GC stress; observed):

* **The send.** A sender puts a `Parcel` holding a MutableVector, a
  MutableArray and a `MutableMap[str, int]` into a mailbox, then mutates
  its own (`push(4)`, `set(0, 70)`, `set("k", 2)`).
* **The receive.** The receiver gets the parcel as it was at the send:
  `nums.length=3 grid[0]=7 table[k]=1`.
* **The reply.** The receiver mutates its copy and sends it back. The
  sender's own parcel is unchanged by that (`grid[0]=70 table[k]=2`).

This is MUTABLE-VECTOR.md's value model: a read-out of a place is a logical
copy (`hir::mutvec::Elaborate`).

So on one thread no message can create an alias. The only memory two actors
can both change is an installed context they both require. That sharing is
static, explicit in every function's signature, and visible to the context
analysis: it is the deliberate mechanism the brief asks for, not an
accident.

### 5.2 Across threads: the matrix

The analysis prototype (`audit/thread-actor/tools/sendability.tcl`, Probe C)
classifies the *checked* type of each field of
`audit/thread-actor/probe-c/matrix.bot`.
* It uses only facts the checker already has: types, the struct registry's
  opacity, context-ness, owner and tree field, and the affinity query.
* Its output is `audit/thread-actor/results/probe-c-classified.txt`
  (observed).
* The verdicts, strongest first: **reject** (cannot cross), **local**
  (only its owner can say), **unknown** (the static type does not say),
  **move** (affine bits, behind an authority), **copy** (a deep copy means
  exactly the value).

| value | verdict | copy | move | share | what must be proven | runtime operation |
|---|---|---|---|---|---|---|
| `int` (small and big), `bool`, `unit`, `UnicodeChar`, `Float64`, `DecimalRounded`, raw C floats | copy | yes, exact (immediates, `BigIntObj`, `FloatObj`: no pointers out) | n/a | n/a | the static type | rebuild in the receiver's heap |
| `str`, `Bytes`, `MutableBytes` | copy | yes; strings are one block (`strobj.rs:1-11`), constants are per-VM statics, so always copy, never share | no (the sending VM frees its statics when it drops) | no | the static type; Bytes is `opaque struct Bytes: storage: any` (`stdlib/abi/bytes.bot:97-101`), so only its owner can say it is one block | one allocation per string or byte block |
| `List[T]`, `ImmutableSet[T]`, transparent structs, enums, tree structs, `ImmutableMap[K, V]` | copy if every component is | yes | no (see 5.3) | not by default (5.3) | structural, from field types; a tree skips its child field | the canonical walk (`ops.rs:1483`); struct shapes and enum numbers are program-relative (same program: kept; another program: by name) |
| `MutableVector[T]`, `MutableArray[T]`, `MutableMap`, `MutableSet` | copy if elements are | yes: a deep copy *is* the value semantics; the backing's `Rc` must never cross | no | no | element types; the collections' opaque tables are the standard library's statement (below) | deep copy; keyed hashes are valid under the same `TABLE_HASH_KEY` (one runtime copy), else recomputed |
| an opaque user struct (`Token`), `std::event_loop::Reg`, an actor `Address` | **local** | its bits copy, but its meaning may not: a `Reg` is a slot and generation of *this thread's* Loop, and copied to another thread it would address that thread's slot | n/a | n/a | the owning module's statement that a copy means the same elsewhere | none, until stated |
| a context struct value (`Settings`) | **reject** | no: an installed context is authority, selected per thread entry | no | no | static: `isContext` | none |
| `Fn{...}`, closures, a struct holding one | **reject** | no: `ClosureObj` holds a function id and a code address (`value.rs:828-836`); a closure's captures are not visible in its type | no | no | static (`IsFn`) | none |
| `Coroutine{...}` | **reject** (affine) | no: its frames hold its VM (`coroutine.rs:618-629`) | no (R10) | no | static | none |
| `std::ffi::c::Ptr[T]`, `FnPtr`, a struct holding one | **move** (affine) | the word copies exactly, but the pointee is native memory whose thread safety only an authority knows | yes: affine, so the sender loses it statically, and the word is not a GC pointer (`value.rs:32-41`) | no | static affinity, plus an explicit authority (a direct module's context) to send | the word |
| `NativeView[L]`, `NativeEdit[L]` | **reject** | no: access to native memory, not a value | no | no | static | none |
| `any`, an imprint variable, a trait view | **unknown** | maybe | — | — | nothing statically; reject, or check the value's kinds when it is copied | a dynamic refusal in the copy walk (the canonical walk refuses Block, Native, MutArray, Coroutine, MutVec and CPtr, `ops.rs:1254`) |
| error payloads | as their declared fields | an error's identity is a name; its payload a struct | — | — | the payload's field types | as structs; identities are canonical names (ERROR-PAYLOADS.md) |

### 5.3 Copy, move or share

* **Copy is the default and the only general mechanism.** The receiving
  thread allocates. The sender serializes on its own thread into
  transport-owned bytes, which the collectors never trace. Probes B and E do
  exactly this, with a C payload table and with library-call conversion.
* **Moving heap objects between heaps is not sound in general,** even though
  objects are individual `Box` allocations that could be re-registered
  (`heap.rs:50-58`).
  * Botlish shares immutable subgraphs freely and invisibly. A List sent
    away may share elements with a List the sender keeps, and nothing proves
    exclusivity.
  * Affinity proves that an affine *root* has one owner. It does not prove
    that the root's immutable components are unshared.
  * So a move is sound only for what the transport can copy anyway (small
    values) or for bits that are not GC objects (C words). That is the
    `move` row.
* **Explicit sharing** (an immutable region both VMs can read, or
  synchronized storage) is deferred. Values have no identity, and a copy of
  an immutable value is observably the same value. So sharing is an
  optimization, never a semantic need.
  * Its cost: a shared, immortal or reference-counted region, the collector
    taught never to mark it, and atomic counts.
  * It should come only with measurements showing copy costs to be the
    bottleneck. Probe B moved 4 KiB payloads at 655-783 MB/s (section 12.2).

### 5.4 Sendability: derived, with one owner statement

* **Botlish should have a static notion of sendable, derived structurally**
  from what the checker already knows, the way `Hashable`'s witnesses are
  derived from totality (`hir::types::Totality`).
  * The prototype shows the derivation needs no new fact except for opaque
    types.
  * Unlike Rust's `Send`/`Sync`, there is nothing to say about shared
    mutable access: Botlish never shares mutable state between VMs.
    Sendable means only "a copy means the same in another VM".
* **The exception is opaque structs.**
  * The checker can see an opaque struct's fields, but not what they mean.
    `Reg {slot, gen}` is two Ints, so structurally it is copyable, but its
    meaning is thread-relative.
  * `Bytes` is `storage: any`, which the checker cannot see into at all.
  * So an opaque struct is sendable only when its owning module states it.
    The standard library would state it for its byte storage and its
    collections (the prototype's two tables).
  * A user module would need a declaration-level word on the opaque struct.
    The spelling is open (section 14), and it may be decided in M2.
  * This is the one place the rule cannot be inferred. That is deliberate:
    it is the owner's representation, as opacity already says.
* **What is static and what is runtime.**
  * Every verdict above except `unknown` is decidable statically, at the
    send call: a SEND-NOT-SENDABLE diagnostic, with a reason path like
    Hashable's "field f of S: ...".
  * `unknown` (`any`) is either rejected statically, as the default, or
    checked during the copy walk. The walk already refuses the
    non-copyable kinds.
* **Across programs** (two native libraries, or one library and an
  executable), shape and enum numbers differ. A copy between programs must
  serialize by canonical names: module identity, struct name, field names
  and enum case names. That is the canonical walk's text, not a word copy.
  Within one program, word-level shape numbers stay valid.

## 6. Actor identity and lifetime

From Probe A (`audit/thread-actor/probe-a/actor.bot`, `actors.bot`,
`failure.bot`; observed on all four backends unless marked):

* **An address is an unrestricted opaque value,** `Address[M] {box, slot,
  gen}` (`actor.bot:37-40`). It grants exactly one thing: sending an `M` to
  that mailbox.
  * Many senders may hold copies.
  * A wrong message type is a static IMPRINT error (`reject-wrong-type.bot`,
    compiled).
  * Forging an address is OPAQUE-CONSTRUCTION (`reject-forge-address.bot`,
    compiled).
  * Reading another actor's queue through the postbox is
    OPAQUE-REPRESENTATION (`reject-read-mailbox.bot`, compiled).
* **The message type is statically fixed per postbox.** A context struct
  takes no type slots (`hir/structs.tcl:1290`, "a context is installed and
  required by its exact struct type"). So no library can own typed
  mailboxes itself. The application declares one context with one
  `Postbox[M]` field per message type (`actors.bot:38-41`). This is a
  feature of the model, not a workaround:
  * the set of message types a thread uses is a static, inspectable
    declaration of its entry program;
  * a library that defines actors exposes their message types, and the
    application wires the postboxes.
* **Stale addresses cannot reach a replacement.**
  * Closing a mailbox keeps its slot's generation, so a send through an
    old address is `Closed`.
  * Reopening the slot bumps the generation, so the old address is then
    `Stale` (trace: "send to a closed mailbox: Closed", "same slot reused:
    new generation", "send to the old address: Stale").
  * Addresses carry the postbox id, so an address of another postbox is
    `Stale` too.
  * Identities are scoped to a postbox of one thread's context, never
    process-global.
* **No discovery.** An actor can only be addressed by receiving its address.
  There is no registry and no name lookup.
* **Creating an actor requires the thread's Loop and the context holding
  the postbox,** both static requirements. So creation is mediated by
  installed authority, which the entry program grants.
* **Sending is not resuming.**
  * An actor's coroutine belongs to the Loop after `adopt`. Resuming it or
    adopting it again is USE-AFTER-MOVE (`reject-share-task.bot`, compiled).
  * A handler cannot be a registered callback, because a function that
    requires a context cannot be a value (CONTEXT-FUNCTION-VALUE,
    `reject-handler-value.bot`, compiled).
  * So the public reference is never the coroutine handle. It is the
    address, and the mailbox decouples the two.
* **Lifetime.**
  * An actor lives until its coroutine returns, fails or is abandoned by
    the loop's shutdown.
  * An idle actor does not keep its thread's loop alive: channels never do
    (EVENT-LOOP-MILESTONE-1.md §5.4). `run()` returns when nothing is in
    flight. The probe's main sends a Stop afterwards.
  * An actor that serves external input waits on a `:keep_alive` source.

**Two conventions of the prototype, and their fixes:**

1. **The receive right `Inbox[M]` is not unique** (`actor.bot:41-49`).
   * A library cannot mint an affine token of its own. The only affine
     roots are coroutine handles and C addresses (section 2.2).
   * The fix for `std::actor`: an internal affine token minted only by the
     standard library, as `std::io::fs::Owner` already is (AGENTS.md,
     "Paths and the synchronous filesystem"). The inbox then moves into the
     actor at construction, which affine values may do.
2. **A failed actor's mailbox stays open** (`failure.bot`). The actor's own
   `close` never ran. Later sends are `Delivered` into a mailbox nobody
   reads until it is `Full`.
   * The fix is reaping. The library that started the task (`adopt`
     returns its id) closes the inboxes of ended tasks from
     `take_outcomes()`.
   * After reaping, the probe shows "reaped: undelivered 3" and later sends
     `Closed`.
   * A generic wrapper body cannot do this instead: it would have to call
     the actor's function as a value, which CONTEXT-FUNCTION-VALUE forbids.

## 7. Scheduler integration

**What `std::event_loop` expresses as it is** (Probe A, no change to it):
* an actor as a task;
* a mailbox's wakeup as a Reliable channel, one event per queued message
  (`actor.bot:166`), with the payload in the postbox;
* receive as `wait`;
* fairness between actors and with timers and native sources, as the
  turn's;
* actor shutdown as `revoke` and `shutdown`;
* actor failure as the task's recorded outcome.

**Handler suspension: one message at a time, deliberately.** An actor is one
coroutine, so a handler that suspends suspends the actor. Probe A's `c1`:
* begins a slow add at turn 1, sleeps 500 µs of driver time and ends at
  turn 501;
* in the meantime, ping and pong exchanged 20 messages each (turns 1-40),
  the quiet actor handled its message in turn 3, and the clients' adds
  queued behind;
* then processed the queued messages in FIFO order.

No two logical operations overlap on one actor's state, and no lock or
reentrancy rule is needed. That keeps COROUTINE-PREREQUISITES.md's C3. An
actor that wants concurrency inside itself owns child coroutines (03-child)
or delegates to helper actors.

**Ordering.** FIFO per sender and receiver pair, since one postbox slot is
one FIFO. Messages from different senders interleave in dispatch order,
which the deterministic driver makes reproducible. Natively: per-producer
FIFO across threads in Probe B (`out of order 0` for every producer,
observed).

**Fairness.**
* **Between busy actors:** a quiet actor's message, sent in turn 2 beside a
  continuous ping-pong, was handled in turn 3.
* **Between actors and sources:** round-robin, as the driver's.
* **Batch size:** `receive` waits once per message, a turn per message. A
  `try_receive` (try_take) variant would let an actor drain its batch
  inside one dispatch, at fairness's expense. It is the application's
  choice, as it is for channels.

**Bounded mailboxes and backpressure.**
* A full mailbox answers `Sent::Full`. Nothing is dropped silently
  (flooder: "Full at message 3", then "delivered after retries").
* For actor messages, Reliable is the only appropriate policy. Lossy and
  Coalesce are a source's semantics, not a mailbox's.

**Missing pieces, both small and both Botlish:**
* **A "room" notification** for a sender waiting on `Full`. The prototype
  polls with `sleep(50)`. A second channel per mailbox, posted by `receive`
  when the count drops below capacity, would make it a wait.
* **Cross-thread delivery into a postbox:** the inbound bridge task of
  section 3, which needs M4's transport.

**Requirements the existing turn cannot meet:** none were found.
* Priority between actors, preemption and per-actor time slices are not
  promised by the event loop, and should not be by actors.
* A long synchronous handler holds its thread. That is the cooperative
  contract (`stdlib/event_loop.bot:69-70`).

## 8. Context and authority integration

| question | answer | evidence |
|---|---|---|
| How does a root actor obtain its contexts? | its thread's entry program installs them at top level; the root actor *is* that top-level code | `hir/contexts.tcl:702-718` |
| Do child actors inherit contexts? | yes, statically: a task constructed after an installation is checked at its construction and keeps those providers; a resume selects nothing | COROUTINES.md:645-664; contexts census probes `p7`/`p8` (observed) |
| Inherited, passed or selected? | selected statically per thread entry, never passed (a context cannot be passed as authority: a copied context value grants none of the functions that require it) | CONTEXTS.md:178-180; probe `p12` (compiled) |
| Different authority for different actors on one thread? | only through which functions they call: every installed context is thread-wide, and any module may require a public context; finer grain is opaque tokens passed as values, or a separate thread. (Since RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md: a spawner constructs each actor inside `inject context ...:` with exactly the contexts it grants, statically checked transitively and across coroutine handles.) | contexts census probe `p19` (observed) |
| Different implementations of a context trait for two actors? | no: one selection per trait per program, so per thread entry | `hir/contexts.tcl:735-742`; probe `p15` (compiled) |
| Actors in different threads sharing an installed context? | no: each thread's entry installs its own; a context value is not sendable (section 5) | projected |
| What does an actor reference permit? | sending one message type to one mailbox, nothing else; the receiver acts with its own thread's authority on the sender's data (the confused-deputy question is the receiver's, as in any actor system) | Probe A |
| Does creating an actor need authority? | yes: the Loop (thread-local scheduler) and the context holding the postbox; creating a *thread* should need an installed context as well (std::thread's, a direct module), so who may spawn OS threads is visible in signatures | projected (M4) |
| Do direct operations stay behind airlocks? | unchanged: an actor's code is ordinary code; a send carries no context, and an opaque handle that holds raw authority is `local` (not sendable) | DIRECT-MODULES.md; section 5 |

**Thread entries and the installation rule.** The rule "only an entry
program installs, at its top level" is kept by making every Botlish thread
run an entry program of its own.

* **Two compilation shapes are possible.**
  * **(a) Separate programs.** Available today as separate native-library
    instances (Probes D and E). Messages must be copied by names, since the
    programs' numberings differ.
  * **(b) One program with several entries.** One shape table, so copies by
    word.
* **Recommendation.** M4 should take (b): a compilation that builds a main
  entry and the thread entries it starts, sharing modules and type
  identities.
* **The cost.** Each entry has its own installation and its own context
  area. That is CONTEXTS.md item 55's "actor-local base", here a per-VM
  base.
* **What this avoids.** No dynamic installation is introduced. Scoped,
  per-actor installation would break the fact that makes handles safe to
  resume anywhere: installation is global and never revoked (contexts
  census, "constraints" 4).

## 9. Errors, cancellation and shutdown

**Errors.**
* **A handler's declared error** ends its actor's task. The loop records
  it (`Ending::Failed`, `failure.bot`) and nothing else is affected:
  EVENT-LOOP-MILESTONE-1.md §5.6 unchanged.
* **A failure in an actor's first segment** reaches its creator, because
  construction is eager (`failure.bot`'s main declares `TaskFailed` for
  this).
* **A reply-able error** is a reply message. The request carries the reply
  address (`actors.bot`'s `Op.reply`), and the reply type is the
  application's: a struct with an outcome field. No error crosses as a
  Botlish error from one actor into another's code: an actor's errors are
  its own completion.
* **An error with no waiting sender** is the task's outcome, observed by
  whoever reaps.
* **A failed actor's mailbox** is closed by reaping (section 6). Senders
  see `Closed` with the undelivered count.
* **A crashed thread** (the whole VM ending) closes that thread's inbound
  endpoint. Later cross-thread sends are `Closed`: Probe B's `-EPIPE`, with
  the producer stopping and its payloads freed.
* **Runtime corruption is not a recoverable error.**
  * `SchedulerFault` (the scheduler's own invariant), `NATIVE BUG`, a
    stray-mark heap, a guard-page fault: the thread cannot be trusted, and
    nothing in it continues.
  * For a Botlish-owned thread: its VM ends and its spawner learns it
    (projected, M4). In-process, the policy is "end that thread", not
    "exit the process", only when the thread's state is provably isolated:
    its own VM, its own guard record (M3).
  * Until M3, an overflow anywhere stays process-terminal, as today.
* **No implicit process exit** for an ordinary Botlish error in an actor,
  as today.

**Cancellation is cooperative.**
* A Cancel or Stop message, closing the inbox (the receiver's `receive`
  then fails `MailboxClosed`), or the loop's `shutdown`, which revokes
  every registration.
* Releasing a coroutine runs no code (no `finally`), so a cancelled actor
  gets no cleanup unless it gets a turn.
* Asynchronous interruption of running Botlish code is excluded. It would
  have to stop a segment at an arbitrary instruction while the
  ownership, release and GC invariants are mid-update, and nothing in the
  runtime gives such points.

**Shutdown sequences** (observed where marked):
1. **One actor.** Its owner sends Stop (or the actor decides) and the actor
   closes its inbox. Queued messages are dropped *and counted* (c1:
   "undelivered 1" for the Add sent after Stop, observed). Later sends are
   `Closed`, then `Stale` once the slot is reused.
2. **One thread with several actors.**
   * `shutdown(rounds)` revokes every registration, so every waiting
     `receive` fails `MailboxClosed`.
   * The actors run their exit code for up to `rounds` turns. The logger in
     `actors.bot` logged "closed, undelivered 0" and returned (observed).
   * The rest is abandoned: released without running.
   * Cross-thread senders see their endpoint closed. The transport frees
     the payloads it holds. Probe B: "records discarded 65", "stopped at
     seq 227", "payloads left in table, freed 127" (observed, one run).
3. **The whole environment.**
   * The main thread asks each Botlish thread's root actor to stop, joins
     them with a bound, then ends.
   * A thread that does not finish within the bound is reported, not
     waited for.
   * Projected (M4).
4. **Embedded in a foreign host** (Probe D, observed):
   * requests queued before the stop are served;
   * later ones complete as refused without touching the instance;
   * the instance is destroyed on its own thread ("pending served 0 0 0,
     late request status -1").

**Out of scope:** supervision trees, restart strategies and distributed
fault handling. A supervisor can be written later as an ordinary actor over
the outcomes.

## 10. Native runtime and GC requirements

Exactly what real OS-thread execution and cross-thread transport need. Each
item is one runtime change with its own acceptance test.

1. **A per-thread overflow guard** (`platform/guard.rs`,
   `platform/windows.rs`).
   * Today: one guarded thread per process (`:39-42`). A second install is
     refused (`:254-255`), and `aot.rs:306` `.expect`s it. Publication does
     not check the publishing thread (`:92-104`).
   * Needed: a guard record per Botlish thread (thread token, published
     stack slots), found from the faulting thread by an async-signal-safe
     lookup, such as a fixed table indexed by a thread-local slot number.
     Publication limited to the record's own thread.
   * Keep the handler's contract: classify, report and terminate. Change
     only *what* is reported, naming the thread, and, once the VM is
     isolated, whether "terminate" means the process or the thread.
   * Recovery stays excluded (NATIVE-STACK-OVERFLOW.md:40-44).
2. **A per-VM context area.**
   * Today: `botlish_context_area` is one process-wide symbol per program
     (`clif.rs:526-539`).
   * Needed: the same layout addressed from a base the VM owns (a register
     loaded from the Vm, or TLS). CONTEXTS.md item 55 already plans it as a
     lowering change only.
   * Without it, two VMs of one program, even on one thread, overwrite each
     other's installed contexts. Their collection headers would point into
     the other VM's heap: the R9 hazard.
3. **`PROGRAM` into the Vm.** It is per thread (`vm.rs:127-129`), which is
   enough for one VM per thread. Moving it into the Vm, as
   COROUTINE-PREREQUISITES.md:652-657 proposes, makes two programs on one
   thread (a host calling two libraries) correct without swaps.
4. **Botlish-owned thread creation.** A runtime operation that:
   * spawns an OS thread with a stack size from the request;
   * instantiates the program's VM *on that thread* (`program::instantiate`
     already takes the thread it runs on: `aot.rs:277,287`);
   * runs the thread entry's installation and root actor;
   * reports its end, with a value or an error.

   The thread's stack is the root actor's and the loop's; actors run on
   their coroutine stacks.
5. **A loop identity in the integration ABI.**
   * ABI v1 addresses an endpoint of *the* loop
     (`botlish_event_post(endpoint, slot, gen, a, b)`; one static `E`).
   * Version 2: a loop handle (`botlish_event_post2(loop, endpoint, ...)`,
     or endpoint ids scoped by loop) and per-loop adapter state (epoll,
     eventfd, rings, rotation). The driver context then holds its loop's
     handle.
   * This is the exact operation Probe B needed and ABI v1 cannot express
     for more than one Botlish thread.
6. **A payload-carrying record.**
   * Today, records are four scalars. Probe B carried payloads in its own
     table and copied them in through a `write noescape` exposure: a
     MutableBytes allocated by the receiving VM, written by C, frozen
     (`probe-b/xp.bot:48-59`; `native/lower.tcl:5815-5850`).
   * The transport should offer the same, owned by the runtime: a post with
     a byte payload, and a take that copies it into a fresh Bytes of the
     taking VM.
7. **The copy operation** (serialize, then rebuild).
   * A sink for the canonical walk (`ops.rs:1483`, `CanonicalSink`
     `:1254`): it already visits every kind, refuses the non-copyable ones
     and walks trees without host recursion. It would write a plain buffer
     on the sender, with a rebuild on the receiver through `new_str`,
     `new_list`, `new_struct` and the collection constructors.
   * The same operation in the Tcl runtime (`core::value`).
   * Both are tested as a round trip inside one VM before any thread exists
     (M2).
8. **Rooting of what arrives.** A rebuilt value is rooted while it is
   delivered (`temp_roots`, as library calls do, `library.rs:347`) and then
   owned by the postbox's vector, a context root (`ctxroot`, `ops.rs:3087-3093`).

**Explicitly not needed:**
* `Arc` for VM structures, or `Send` for Vm: VMs never move.
* A shared heap, and collector changes beyond (2), because no foreign
  pointer ever reaches a heap.
* Changes to coroutine switching, fusion or release.

**GC isolation, traced, not assumed.**
* **Probe B:** payloads live in a C table; the receiving VM allocates the
  MutableBytes (`std::abi::bytes::zeroed`) and C writes into its exposed
  private copy.
* **Probes D and E:** str arguments are converted into the instance's own
  heap at the call (`library.rs:336-347`), and str results are malloc'd
  copies (`library.rs:399`).
* In none of the probes does a word of one VM's heap reach another's.
  Under `BOTLISH_NATIVE_GC_STRESS=1`, which collects at every allocation of
  both VMs while the other runs, all checks still pass (section 12.5).
* The stray-mark failure the census would otherwise risk (`heap.rs:143-146`)
  has no path to happen in these designs.

## 11. Platform and backend matrix

Status terms: **working**; **experimentally demonstrated** (this census or
a cited one); **compile-only**; **small missing feature**; **blocked**;
**absent**; **not investigated**. Linux evidence is not taken for Android,
nor macOS for iOS.

| target | native codegen | runtime | Botlish-owned OS threads | stack guarantees | coroutines | thread wakeups | event-loop drivers | cross-thread transport | multi-VM GC safety | native library | foreign-host embedding |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Linux x86-64 | working | working | absent (C-made threads only; library instances on them: experimentally demonstrated, Probes D, E) | working (guard, terminal; library proactive check: Probe D) | working | working (eventfd adapter) | working (Linux package, deterministic) | experimentally demonstrated (Probe B, beside ABI v1) | experimentally demonstrated for library instances (Probe E); blocked for one program's executables (guard, context area) | working | experimentally demonstrated (Probe D) |
| Linux AArch64 | working (tests-arm64.yml) | working | absent | working | working | not investigated (same adapter source) | not investigated (driver package not run on arm64 here) | not investigated | not investigated | working (`native::capabilities`, `native/native.tcl:252`) | not investigated |
| macOS AArch64 | working | working | absent | working (worker or main thread, MAIN-THREAD-STARTUP-MILESTONE-1.md) | working | absent (no driver) | deterministic only: no kqueue driver | absent | not investigated | blocked (`codegen/library.rs:40`: Linux glibc only) | blocked (no library mode) |
| Windows x86-64 | working | working | absent | working (vectored handler) | working (fibers) | absent | deterministic only | absent | not investigated | blocked | blocked |
| Android x86-64 | no target row (`core/cabi.tcl:161-168`) | compile-only (REACT-NATIVE-TARGET-CENSUS.md §5: builds unchanged) | blocked | blocked (fallback host, no guard: RN census) | blocked (`coroutine.rs:106,255` cfgs exclude android) | absent | absent | absent | not investigated | blocked | experimentally demonstrated by the RN census as a stand-in (emulator, CI) |
| Android AArch64 | no target row | small missing feature (the RN census's one-line cfg patch) | blocked | blocked | blocked | absent | absent | absent | not investigated | blocked | links, not run (RN census) |
| iOS AArch64 device | no target row | small missing feature (cfg) | blocked | blocked | blocked | absent | absent | absent | not investigated | blocked | not investigated (no device run) |
| iOS simulator | no target row | small missing feature | blocked | blocked | blocked | absent | absent | absent | not investigated | blocked | experimentally demonstrated as a stand-in (RN census: retagged Mac object) |

**Backends.**

| backend | same-thread actors | deterministic driver | real OS threads | cross-thread messages |
|---|---|---|---|---|
| interp | working (Probe A, identical trace) | working | absent: the canonical baseline has no Thread package (`package require Thread` fails under the pinned tclsh9.0), and coroutine and context state is interpreter-wide (`core/coroutines.tcl:69-82`, `core/contexts.tcl:41`) | recommendation: an explicit refusal (`NATIVE-ONLY`, as C calls are), never a silent sequential substitute |
| compile | working (Probe A) | working | absent (same) | same |
| cranelift-generic, cranelift | working (Probe A, also under GC stress) | working | M4 | M4 |

**On the Tcl backends**, a program that starts a Botlish thread should be
refused when it is built, not run sequentially. An actor *state machine*
needs no threads to be tested: its mailboxes, ordering and errors are the
same under the deterministic driver on every backend (Probe A).

A deterministic multi-thread simulation is possible later, with several
thread entries' loops stepped in one process in a fixed order:
* Every such schedule is one of the parallel program's permitted
  executions, since only per-sender FIFO is promised.
* It would be a test driver, not a backend semantics.

## 12. Exploratory results

All probes are in `audit/thread-actor/` with a README there. Their outputs
are in `audit/thread-actor/results/`.

### 12.1 Probe A: several actors, one event loop

`probe-a/actor.bot` (the prototype library: `Postbox`, `Address`, `Inbox`,
`open`, `send`, `receive`, `close`) and `probe-a/actors.bot` (the
scenario), under the deterministic driver.

* **Agreement.** All four backends give one identical trace: every
  scheduling decision (`create(64, :trace)`) plus the actors' own lines
  (`tools/run.tcl`: AGREE; the actors' lines are in
  `results/probe-a-actors.txt`). They agree again with
  `BOTLISH_NATIVE_GC_STRESS=1` for the native backends against the
  unstressed Tcl backends (`results/probe-a-gcstress.txt`).
* **Private state.** Each counter's state is a fold intermediate,
  `Count {total, handled}`, in its own body (`actors.bot:82-103`). Nothing
  else can name it.
* **Distinct mailboxes.** Three typed postboxes (`Op`, `Reply`, `str`) in
  the application's `Mail` context.
* **Ordering, request/reply and correlation.** Two clients send adds and a
  Get with a correlation id and their own reply address to one counter.
  * Each receives only its own reply: "clientA: reply for my request,
    value 1007" and "clientB: ... value 1009" (the Gets are served in
    arrival order).
  * c1 ends with "total 1009 handled 8 undelivered 1": the slow add's 1000,
    clientA's 1+2+3 and clientB's 1+2 (8 messages with the two Gets).
  * The Add main sent after Stop is counted as undelivered at close.
* **A suspended handler while others progress.** Section 7.
* **Fairness.** The quiet actor beside ping-pong (section 7).
* **Backpressure.** A mailbox of capacity 3 answers `Full`; the flooder and
  the clients wait and retry; nothing is dropped.
* **Stale addresses.** Section 6.
* **Shutdown.** After `run()` quiesces, Stop is sent, then `shutdown(4)`
  revokes and the logger ends. Outcomes are recorded for all ten tasks.
* **No additional native scheduler.** The probe uses only `std::event_loop`
  and MutableVectors.
* **Rejections** (compiled; `results/probe-a-rejections.txt`):
  * wrong message type: IMPRINT;
  * forged address: OPAQUE-CONSTRUCTION;
  * reading another's queue: OPAQUE-REPRESENTATION;
  * a handler as a callback: CONTEXT-FUNCTION-VALUE;
  * resuming an adopted task: USE-AFTER-MOVE;
  * an affine message type: TYPE ("a type slot takes an unrestricted
    type", `hir/resolve.tcl:855`).
* **`failure.bot`** (section 6) shows the open-mailbox gap and reaping.

**What is convention, and what is enforced:**

| property | enforced by | convention |
|---|---|---|
| actor state is private | the language (coroutine locals) | |
| send-only rights, correct message type | opacity, imprinting | |
| one receiver per mailbox | | yes (an unrestricted `Inbox`; fix: an affine std token) |
| a failed actor's mailbox closes | | yes (fix: reaping in `std::actor`) |
| no shared mutable state between actors | value semantics; contexts are explicit | sharing a context is possible and visible |
| messages are copies | value semantics (Probe C runtime half) | |

**A native-lowering limit met on the way.** The postbox's `id: int` and
`capacity: int` fields made the `Mail` context
CONTEXT-NATIVE-LOWERING-UNSUPPORTED on the native backends. An installed
context's leaves must be small-domain Ints or collection headers
(`native/lower.tcl:4568-4603`). Observed with an `id: int` field: 'field
"id" is an Int (int) whose declared domain does not fit the small-Int
representation'. The probe keeps them in a MutableArray. A `std::actor`
postbox would do the same, or declare small domains.

### 12.2 Probe B: cross-thread transport

`probe-b/xport.c`, `xp.bot` and `main.bot` run on the Linux driver,
natively (`tools/native-app.tcl`).
* Producer threads never run Botlish code and never touch a heap. They
  copy each payload into a C table and post a four-scalar record through
  ABI v1, naming the table slot.
* The loop's consumer actor copies the payload into a MutableBytes its own
  VM allocated, through `xp_take`'s `write noescape` exposure, then checks
  it.

| phase | producers × messages | wall (3 runs) | rate | correctness |
|---|---|---|---|---|
| scalar records | 2 × 20,000 | 46.8, 56.5, 76.4 ms | 0.52-0.85 M msg/s | out of order 0, wrong producer 0 |
| text payloads, 64 B | 4 × 5,000 | 52.0, 55.9, 72.2 ms | 0.28-0.38 M msg/s | bad content 0 |
| byte payloads, 4 KiB | 2 × 2,000 | 20.9, 22.6, 25.1 ms | 160-191 k msg/s, 655-783 MB/s | bad content 0 |
| wakeups: 200 messages 1 ms apart, loop asleep between | 1 × 200 | 221-225 ms | mean latency 68-79 µs, max 224-745 µs | every message woke the loop |
| shutdown: a 1,000,000-message producer, consumer stops after 100 | 1 | <1 ms | — | endpoint closed (records discarded 65), producer sees `-EPIPE` and stops (seq 227), payloads freed 127: posted = received + discarded in the source + discarded at the endpoint, with no leak (one run) |

* **Backpressure.** Producers saw 550-580 refused posts each (endpoint
  full) in the text phase and 144-169 in the bytes phase. They retried;
  nothing was lost.
* **GC stress.** With `BOTLISH_NATIVE_GC_STRESS=1` all 30 order, content
  and producer checks are zero (`results/probe-b-gcstress.txt`). The text
  phase slows to 1.06 s.
* **What ABI v1 cannot express:**
  * a second Botlish thread's loop (one static adapter state per process);
  * a payload (four scalars).

  Both are named in section 10, items 5 and 6. Everything else, including
  backpressure, wakeup and fairness, was reused unchanged.

### 12.3 Probe C: sendability and ownership

* **The classifier** (`tools/sendability.tcl` over `probe-c/matrix.bot`,
  29 value classes; `results/probe-c-classified.txt`). Section 5.2's matrix
  is its output, plus the projected operations.
* **The runtime half** (`probe-a/sendvalues.bot`, all four backends, also
  under GC stress) is section 5.1.
* **Counterexamples the classifier exposed:**
  * `std::event_loop::Reg` (two Ints, structurally copyable) is an identity
    of one Loop: it must not cross.
  * `std::abi::bytes::Bytes` hides `storage: any`, so the checker cannot
    see byte storage at all.
  * `std::mutable_map::MutableMap` reaches the opaque
    `std::ordered_table::Table`.

  All three are why opaque structs need their owner's statement.
* **Affine messages** cannot pass through a library-written generic
  mailbox, since type slots take unrestricted types. Affine values enter an
  actor at construction, which works today. A future affine mailbox is a
  MutableVector the application writes, as the Loop's task vectors are.

### 12.4 Probe D: native-library and foreign-host boundary

`probe-d/actorlib.bot` is a library with three exports: a deep recursion,
a str result, and a declared error with a payload. `probe-d/host.c` is a C
host where only a Botlish-owned thread (256 MiB pthread) creates, calls and
destroys the instance. Host threads with 512 KiB stacks queue requests and
wait for completions, like promises (`results/probe-d.txt`, observed):

* **Deep recursion.** `depth(1000000)`: status 0 on the Botlish thread.
  The same on the host's own 512 KiB thread with its own instance: status 2
  `NATIVE LIMIT STACK` (the library's proactive check), and that instance
  then answers `depth(100)` = 5050.
* **Results and errors.** `greet` returns `"hello, host"` (a malloc'd
  copy). `checked(-5)` gives status 1 `Refused field -5` (an owned error
  object).
* **Thread affinity.** A direct call from a host thread is status 4
  `WRONG-THREAD`, so the host *cannot* break affinity by accident.
* **Round trips** (submit, condition variable, serve, complete):
  * 1 host thread: mean 13.7 µs, 37.3 k requests/s;
  * 4 host threads: mean 21.7 µs, 118.9 k requests/s;
  * under GC stress: 13.9 and 31.0 µs.
* **Shutdown.** Section 9.
* **What library mode cannot do: keep actor state between requests**
  (`results/probe-d-rejections.txt`, compiled):
  * a module binding in the entry file is LIBRARY-TOP-LEVEL;
  * an export that needs the Loop (where a mailbox would live) is
    CONTEXT-FUNCTION-VALUE, EXPORT-SIGNATURE and EXPORT-ENVIRONMENT.

  So the request path works today, but only for stateless functions. An
  actor-owned Botlish thread needs M5: the library starts a Botlish thread
  running a thread entry (contexts, loop, actors), and C requests become
  messages to its actors.

**What each layer supplies on the path host → C ABI → message → mailbox →
turn → reply → completion:**

| step | supplied by | status |
|---|---|---|
| host → C ABI | library mode (header, statuses, owned results and errors) | working |
| run on a Botlish-owned thread | the host (Probe D's pthread); a runtime option (`botlish_thread_start`) | stand-in / M5 |
| C request → message | transport post with payload | Probe B's table / M4 |
| message → actor mailbox | inbound bridge task in `std::actor` | M1 + M4 |
| normal turn | `std::event_loop` | working |
| reply → completion | transport out (C queue or callback on the host's thread, the host's choice) | Probe D's condvar / M5 |

### 12.5 Probe E: GC and isolation

`probe-e/twovm.bot` and `host.c`: two instances of one library, so two
VMs and two heaps in one runtime copy, on two OS threads.
* The producer VM builds a nested value (`List[Item]` with strings and tag
  lists) and renders it as text. C copies the text into a queue entry, and
  the library's buffer is released on its own thread.
* The consumer VM converts the text into its own heap at the call,
  rebuilds a character List and hashes it.
* Each side hashes in its own VM, and the host compares.

Results (`results/probe-e.txt`, observed):

| run | messages | checksum mismatches | failed calls |
|---|---|---|---|
| plain, 5 runs | 4,000 consumed each | 0 | 0 |
| `BOTLISH_NATIVE_GC_STRESS=1`, 3 runs | 300 each | 0 | 0 |
| GC stress | 1,500 | 0 | 0 (7.7 s) |

* **Teardown with messages pending.** The consumer stopped early. 16
  entries were still queued after both instances were destroyed, and were
  freed as C memory: no VM was alive to own them, and none needed to.
* **What this does not show.** It does not show two VMs *of one program
  with installed contexts* on two threads. That is blocked by the
  process-wide guard and context area (section 10, items 1-2), and is M3's
  acceptance test.
* **No reentrant callbacks.** Library mode forbids calling an instance from
  its own C callee (REENTRANT-CALL), so the probe makes none.

### 12.6 Probe F: performance

`probe-f/main.bot` on the Linux driver, native, three runs. Time is wall,
and wall equals CPU within a few percent (one thread)
(`results/probe-f-run*.txt`):

| measurement | ops | total (3 runs) | per op |
|---|---|---|---|
| raw channel ping-pong (two tasks, ints) | 40,000 hops | 58.5-68.1 ms | 1.46-1.70 µs |
| `Postbox[int]` ping-pong | 40,000 messages | 88.3-97.7 ms | 2.21-2.44 µs |
| `Postbox[Msg]` (64-char str, a fresh 8-element List per message) | 40,000 | 87.5-103.3 ms | 2.19-2.58 µs |
| ring of 100 actors | 20,000 hops | 35.6-61.1 ms | 1.78-3.05 µs |
| create an idle actor (open + construct + adopt) | 2,000 | 26.5-99.5 ms | 13-50 µs |
| stop it (one message, run to completion, close) | 2,000 | 18.6-69.2 ms | 9-35 µs |
| memory of 2,000 idle actors | — | RSS +8,488 KiB, virtual +16,248,324 KiB | 4.2 KiB resident, about 8 MiB reserved each (the coroutine stack, `MAP_NORESERVE`) |
| after stopping them | — | RSS +1,404 KiB, virtual +516 KiB | stacks returned |

Cross-thread figures are in sections 12.2 (Probe B) and 12.4 (Probe D).

**Reading.**
* **The mailbox costs about 0.7 µs per message over the bare channel.**
  That is the Botlish-written postbox: a few checked vector operations per
  send and receive. It is well inside what an actor needs, so there is no
  case for a native mailbox.
* **The dominant cost of an idle actor is address space, not memory:** one
  8 MiB coroutine stack reservation per actor.
  * Harmless on 64-bit Linux.
  * Relevant to mobile targets and to a thread with very many actors.
  * The size is a process-wide knob today
    (`BOTLISH_NATIVE_COROUTINE_STACK_BYTES`). A per-thread size is a later
    one.
* **Creation and destruction costs** vary by 4x between runs on this
  shared machine. They are dominated by stack mapping (the pool keeps 32).
* **For comparison**, EVENT-LOOP-MILESTONE-1.md §11 measured 0.76 µs per
  ping-pong dispatch with its own benchmark. The 1.46-1.70 µs per hop here
  includes a wait, a post and a turn per hop. Use this table for relative
  costs only.

## 13. Competing designs

### 13.1 The three architectures

| | A. actors as event-loop tasks only | B. a native actor runtime | **C. hybrid (recommended)** |
|---|---|---|---|
| in Botlish | everything, including cross-thread, which it cannot reach | almost nothing: an API over natives | actor dispatch, mailboxes, addresses, request/reply, lifecycle, reaping, the inbound bridge |
| in native code | nothing new | actors, mailboxes, a scheduler, delivery, lifecycle | threads, per-thread guard and context base, loop identity in the ABI, payload records, the copy walk |
| compiler | nothing | an actor kind, its typing, its GC roots | sendability (M2), several entries per compilation (M4) |
| host-specific | the driver | the scheduler's waiting, on every OS | the driver and the transport's wakeup (eventfd, kqueue, IOCP), as today |
| portability | as the event loop | a second scheduler per OS | as the event loop, plus one transport per OS |
| ownership and lifecycle soundness | in-thread: proven by the probes | a second ownership model beside the affine one | the affine model in-thread; copies between threads |
| performance | measured (12.6) | possibly faster dispatch; nothing measured needs it | measured: in-thread as A; cross-thread at copy cost (Probes B, E) |
| effect on the event loop | none | bypassed or duplicated | none, apart from a driver that knows its loop handle |
| maintenance | lowest | highest: two schedulers, two fairness contracts, GC integration in Rust | moderate: small runtime pieces, each with its own tests |

* **A is C without the cross-thread half.** It is exactly M1, but it cannot
  provide parallelism: the event loop is thread-local, and nothing in
  Botlish starts a thread.
* **B is rejected.** No requirement surfaced that `std::event_loop` cannot
  meet: fairness, ordering, backpressure, suspension and shutdown are
  already its, and are measured.
  * B would duplicate the turn contract that EVENT-LOOP-MILESTONE-1.md
    froze, its mutation-tested fairness and its revocation rules.
  * It would also move ownership into Rust, where the affine model does not
    reach.

### 13.2 One VM per actor (COROUTINE-PREREQUISITES.md §6), rejected for in-thread actors

That document made "an actor is a `Vm`" the model, to get heap isolation per
actor. The census rejects it *inside a thread*:

* **It buys no isolation the language lacks.** Section 5.1: no references,
  value semantics for every mutable collection, and contexts as the only
  shared state, explicitly.
* **It costs a heap per actor and a deep copy per same-thread message.**
  Probe C shows messages are logical copies already, at the cost of a
  share, not a walk.
* **It needs everything section 10 lists, multiplied per actor on one
  thread:**
  * PROGRAM swaps;
  * a context base per actor, so contexts would no longer be thread-wide;
  * and above all actor-owned stacks for *every* activation, root included.
    Otherwise one stack walk cannot tell two actors' frames apart: R9.
* **Its precondition does not hold.** The model also assumed actors would
  get their own installed contexts, which the static installation rule does
  not allow (section 8).

The model survives where isolation must be physical: **between threads, a
VM per thread.**

### 13.3 Other rejected alternatives

* **The coroutine handle as the actor reference.** It is affine, single
  owner, resumable only by its owner, and frame-bound to its VM. Many
  senders cannot share it, and it cannot cross threads (sections 6, 5.2).
* **Callbacks as handlers** (an actor as a registered `Fn`).
  CONTEXT-FUNCTION-VALUE forbids it for any handler that touches its
  context, which is every useful one (`reject-handler-value.bot`).
* **Context structs with type slots,** for a generic mailbox context.
  Rejected by design (`hir/structs.tcl:1290`). The application-declared
  context of postboxes is more inspectable.
* **Dynamic or scoped context installation per actor or thread.** It breaks
  "a handle resumed anywhere keeps its providers" and the static selection
  of context traits. Thread entries as entry programs (section 8) keep the
  rule.
* **Moving heap objects between VMs.** Unsound without exclusivity proofs
  (section 5.3).
* **Shared immutable memory by default.** An optimization with
  collector-wide costs and no semantic need (section 5.3).
* **A VM behind a mutex, called from many threads.** It would break the
  creating-thread stack bound of the collector's walk (`vm.rs:630-641`),
  the guard and the thread-local pool. It would also make the
  foreign-thread callback problem everyone's problem.

## 14. Proposed public API

Spellings are exploratory; only ordinary functions, types, contexts and
modules are used. Each example says what works today.

**Example 1: two actors on one thread.** This works today. It is Probe A's
code with `actor` renamed to `std::actor` (M1).

```
import std::actor
import std::event_loop
import std::event_loop::deterministic

struct Order:
    item: str
    reply: std::actor::Address[Receipt]

struct Receipt:
    item: str
    accepted: bool

# The application's mailboxes: one Postbox per message type.
context struct Mail:
    orders: std::actor::Postbox[Order]
    receipts: std::actor::Postbox[Receipt]

fn shop(inbox: std::actor::Inbox[Order], context ev: std::event_loop::Loop, mail: Mail) -> int errors ...:
    fold with intermediate sold 0:
        o = std::actor::receive(mail.orders, inbox):
            on std::actor::Closed:
                break
        std::actor::send(mail.receipts, o.reply, Receipt {item: o.item, accepted: true})
        sold + 1

fn main(context ev: std::event_loop::Loop, d: std::event_loop::Driver, mail: Mail) -> ... :
    s = std::actor::open(mail.orders)
    c = std::actor::open(mail.receipts)
    coroutine {step, first} = shop(s.inbox)          # the inbox moves in (affine, M1)
    std::actor::start(mail.orders, s, step, first)   # adopt + record for reaping
    std::actor::send(mail.orders, s.to, Order {item: "tea", reply: c.to})
    std::event_loop::run()
    ...

with context std::event_loop::create(64)
with context std::event_loop::deterministic::create()
with context Mail {orders: std::actor::postbox[Order](16), receipts: std::actor::postbox[Receipt](16)}
main()
```

What M1 adds beyond the prototype:
* `start` (adopt plus registration for reaping) and `reap()`;
* an affine `Inbox`;
* `try_receive`;
* a room wait for `Full`;
* `std::actor::Closed` as the module's error.

**Example 2: two threads communicating by typed messages.** Pseudocode. The
missing facilities are named.

```
# worker.bot -- a thread entry: an entry program of its own (M4)
import std::actor
import std::actor::remote                      # MISSING (M4): the inbound bridge
import std::event_loop
import event_loop_linux

struct Job:                                    # sendable: transparent, str and int fields (M2's check)
    id: int
    text: str

context struct Mail:
    jobs: std::actor::Postbox[Job]

with context std::event_loop::create(64)
with context event_loop_linux::create()        # this thread's own driver (ABI v2 loop handle: M4)
with context Mail {jobs: std::actor::postbox[Job](64)}
std::actor::remote::serve(mail.jobs)           # MISSING (M4): delivers copied Jobs into the postbox, runs the loop
```

```
# main.bot -- the main thread's entry
import std::thread                             # MISSING (M4): a direct module; its context is the authority to spawn
...
with context std::thread::threads()            # MISSING (M4)
w = std::thread::start[Job]("worker.bot", 64 * 1024 * 1024)   # MISSING: compiled with this program (several entries, M4)
std::actor::remote::send(w, Job {id: 1, text: "hello"})       # MISSING: M2's SEND-NOT-SENDABLE check, M4's copy and post
```

How a program names its thread entries (a string, as here, or a module-like
reference) is the open spelling question for M4. The requirement is that
the compilation knows the set, so that shapes are shared and every entry is
checked.

**Example 3: a foreign host sends a request and receives a result.** The C
side; pseudocode for M5. Probe D shows the stateless version working today.

```c
/* today (Probe D): the host owns the Botlish thread and the queue */
actorlib_instance *in;  actorlib_create(&in, &e);   /* on the host-made Botlish thread */
actorlib_checked(in, 21, &result, &e);              /* served from the host's queue */

/* M5: the runtime owns the thread; requests are messages to an actor */
botlish_thread *t;
shop_thread_start(&t, 256u << 20, &e);              /* MISSING: starts the library's thread entry */
shop_post_order(t, "tea", 3, on_receipt, user);     /* MISSING: copies in, posts to the thread's loop */
/* on_receipt(user, result, error) is called on a host-chosen thread, or polled */
shop_thread_stop(t);                                /* MISSING: Stop to the root actor, join */
```

**Not proposed:** an `actor` keyword, actor declarations or classes, a
global registry, futures or promises as language values (a promise is the
host's adapter over a reply message), selective receive, and actor
inheritance.

## 15. Implementation roadmap

Strict dependencies are marked **needs**. Everything else can proceed in
parallel:

```
M1 same-thread actors ─────────────────────────┐
M2 sendability + copy operation ───────────────┼──> M4 Botlish-owned threads ──> M5 actor-aware embedding ──> M6 mobile
M3 per-thread runtime state (guard, context base, PROGRAM) ┘                      (M6a drivers for macOS/Windows: after M1, any time)
```

### M1. Same-thread actors (`std::actor`)

* **Scope.** An ordinary standard-library module over `std::event_loop`:
  * `Postbox[M]`, `Address[M]`, an affine `Inbox[M]` (a standard-library
    token, like `std::io::fs::Owner`);
  * `open`, `start` (adopt plus registration), `send`, `receive`,
    `try_receive`, `close`, `reap`, room waiting.
  * No compiler change. No native, NIR instruction or runtime object
    (rule: as `std::event_loop`'s).
* **Acceptance.** Probe A's and `failure.bot`'s scenarios become tests on
  all four backends, one trace each:
  * typed delivery;
  * FIFO per pair;
  * a suspended handler beside progressing actors;
  * quiet-actor fairness;
  * Full and room wakeup;
  * Closed and Stale addresses;
  * reaping of failed actors (later sends Closed, undelivered counted);
  * shutdown accounting.
* **Negative tests (compiled):** wrong type, forged address, queue access,
  handler as value, resumed task, affine message, a second holder of an
  inbox (USE-AFTER-MOVE).
* **Checks.** Mutants of every rule, the warning gate, Compilerpedia notes,
  a performance report against Probe F's numbers.
* **Why first.** It is independent. Its addresses are opaque, so they stay
  local under M2's rule. It gives M4 its delivery target.

### M2. Sendability and the copy operation

* **Scope.**
  * A static `sendable` judgement, derived structurally (section 5.4):
    * diagnostics at a send site, with reason paths;
    * an owner statement for opaque structs (spelling decided here), and
      the standard library's statements for its byte storage and
      collections;
    * `any` rejected by default.
  * The copy operation in both runtimes: serialize into an owned buffer,
    rebuild in a VM. A walk sink in `ops.rs`, and `core::value` for Tcl.
  * No threads yet.
* **Acceptance.**
  * The Probe C matrix as tests: every row's verdict, with the
    counterexamples `Reg`, `Bytes` and `MutableMap`.
  * Round trip equality for every copyable kind, nested and large (trees
    without host recursion), on all four backends and under GC stress.
  * Refusals for every non-copyable kind, statically and in the walk for
    `any`.
  * Names-based round trip between two programs, when M4 needs it.

### M3. Per-thread runtime state

* **Scope.** Section 10, items 1-3: per-thread guard records, a per-VM
  context base (CONTEXTS.md item 55), `PROGRAM` in the Vm. Runtime and
  lowering only; no language change.
* **Acceptance.**
  * N VMs of one program, *with installed contexts*, on N threads of one
    process, under GC stress, each with its own context values.
  * A stack overflow on each thread reported as `NATIVE LIMIT STACK` naming
    that thread, with every other thread's published stacks untouched.
  * Two programs on one thread without swaps.
  * The stack-guard and native-AOT mutation harnesses
    (`audit/native-stack/`, `audit/native-aot/`).

### M4. Botlish-owned threads (Linux first)

* **Needs** M1, M2 and M3.
* **Scope.**
  * Thread entries as entry programs compiled with their starter.
  * `std::thread` (a direct module) with an installed context as spawning
    authority, a stack size per thread, start, stop and join with a bound.
  * The integration ABI v2: a loop handle and payload records.
  * The cross-thread address (thread, generation, local address) and the
    inbound bridge.
  * The Tcl backends refuse at build time.
* **Acceptance.** Probe B's measurements and correctness checks with
  Botlish producers instead of C, and Probe E's with one program:
  * per-sender FIFO;
  * nothing lost under backpressure;
  * wakeup latency;
  * `Closed` after a thread ends;
  * payload accounting at shutdown;
  * GC stress;
  * the stray-mark negative: no word of one heap in another.
* **Negative tests:** a non-sendable message across threads, a context
  value, a `Reg`, a coroutine; and a thread start from a backend without
  threads.

### M5. Actor-aware native embedding

* **Needs** M4 and native-library mode.
* **Scope.**
  * A library starts its thread entry on a runtime-owned thread.
  * The C ABI posts copied requests and delivers completions: polled, or
    on a callback the host names, run on a host thread, never a VM's.
  * A stop and join that drains or refuses, like Probe D's shutdown.
  * The policy for an overflow inside an embedded thread: that thread ends
    and the host gets an error, once M3 isolates it.
* **Acceptance.** Probe D rebuilt on the library's own thread, with
  persistent actor state across requests; a host thread with a 512 KiB
  stack driving 1,000,000-deep requests; WRONG-THREAD impossible by
  construction; a React Native-shaped host (REACT-NATIVE-TARGET-CENSUS.md's
  probes).

### M6. Platforms

* **M6a** (after M1, independent): event-loop drivers and transports for
  macOS (kqueue) and Windows (IOCP or an event object). Each is a package
  like `event_loop_linux`, and the scheduler is unchanged.
* **M6b** (after M5): library mode on macOS, Windows and the mobile
  targets. That means the target rows and coroutine cfgs the RN census
  lists, then the React Native plugin.

## 16. Explicitly deferred work

* **Richer messaging.** Selective receive, priorities, broadcast and
  publish/subscribe, typed channels as first-class values, streams.
* **Affine messages** between actors or threads: moving coroutines, C
  pointers or other resources. In-thread this needs an affine mailbox over
  a MutableVector the application writes; across threads, an authority for
  C words.
* **Explicit sharing.** Shared immutable regions, synchronized storage,
  atomics.
* **Actor migration** and transfer of suspended coroutines (R10).
* **Supervision, restart strategies,** distributed actors, remote
  messaging, persistence.
* **Preemption** or time slicing; asynchronous cancellation.
* **A thread pool,** or work stealing across Botlish threads.
* **A deterministic multi-thread simulation driver** for the Tcl backends
  (section 11).
* **Per-actor coroutine stack sizes,** and lazily committed or segmented
  stacks for very many idle actors.
* **Foreign threads running Botlish code directly,** and worker-thread C
  callbacks. These stay messages to a Botlish thread (C-CALLBACK-MILESTONE-1.md:905-907).
* **Mobile** targets, the React Native package generator, JavaScript
  promises: after M5 (REACT-NATIVE-TARGET-CENSUS.md).

## 17. Reproducing

Prerequisites: `tclsh9.0` (AGENTS.md, "Installing Tcl 9"), the native
backend (`cargo build --release --manifest-path native/Cargo.toml`), `cc`,
and `LANG=C.utf8 LC_ALL=C.utf8`.

```sh
# Probe A and the runtime half of Probe C: every backend, one outcome
tclsh9.0 audit/thread-actor/tools/run.tcl -show 1 audit/thread-actor/probe-a/actors.bot
tclsh9.0 audit/thread-actor/tools/run.tcl -show 1 audit/thread-actor/probe-a/sendvalues.bot audit/thread-actor/probe-a/failure.bot
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 audit/thread-actor/tools/run.tcl audit/thread-actor/probe-a/actors.bot
for f in audit/thread-actor/probe-a/reject-*.bot; do tclsh9.0 main.tcl -check $f; done   # each must be rejected

# Probe B (Linux; installs the event-loop package into a temporary application)
tclsh9.0 audit/thread-actor/tools/native-app.tcl audit/thread-actor/probe-b
tclsh9.0 audit/thread-actor/tools/native-app.tcl audit/thread-actor/probe-b -gc-stress 1

# Probe C's classifier
tclsh9.0 audit/thread-actor/tools/sendability.tcl

# Probes D and E (a library and a C host)
tclsh9.0 main.tcl -emit-native-library actorlib -out OUT/lib audit/thread-actor/probe-d/actorlib.bot
cc -O1 -Wall -Werror -I OUT/lib audit/thread-actor/probe-d/host.c OUT/lib/libactorlib.a \
   -lgcc_s -lutil -lrt -lpthread -lm -ldl -lc -o OUT/host && OUT/host
tclsh9.0 main.tcl -emit-native-library twovm -out OUT2/lib audit/thread-actor/probe-e/twovm.bot
cc -O1 -Wall -Werror -I OUT2/lib audit/thread-actor/probe-e/host.c OUT2/lib/libtwovm.a \
   -lgcc_s -lutil -lrt -lpthread -lm -ldl -lc -o OUT2/host && OUT2/host 5000 4000
BOTLISH_NATIVE_GC_STRESS=1 OUT2/host

# Probe F
tclsh9.0 audit/thread-actor/tools/native-app.tcl audit/thread-actor/probe-f -also audit/thread-actor/probe-a/actor.bot
```
