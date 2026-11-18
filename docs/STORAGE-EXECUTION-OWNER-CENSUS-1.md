# STORAGE-EXECUTION-OWNER-CENSUS-1 -- persistent execution-owned storage, static capacity planning and configurable memory placement

A census, not an implementation milestone. It asks how Botlish could tie
compiler-managed storage to *execution owners*: coroutine instances,
actors, request scopes, thread entries, application instances. Such
storage would survive ordinary calls and coroutine suspension. It would
have a capacity the compiler derives, and a placement that configuration
chooses. Nothing in the compiler, the runtime, the standard library or the
language changed. The census adds a probe corpus and read-only tools
(`../audit/storage-execution-owner/`) and this report.

Evidence tags:

* **[inspection]** read in the implementation;
* **[test]** an automated assertion;
* **[probe]** a compiled or executed program;
* **[measurement]** an observed count, size or time;
* **[inference]** a conclusion from evidence;
* **[design]** proposed behavior, not implemented.

Commits: the census starts from `db473ee0` (main, 2026-11-17), on
`claude/focused-bohr-gmviky`. Main's latest runs at that point:
* single executable, icy-tower (Linux, macOS, Windows), c-bindgen, bench,
  static-decisions and scalar-asm-audit at `07dcb10f`: succeeded;
* tests.yml, tests-arm64.yml, macos-arm64.yml and windows-x86_64.yml at
  `07dcb10f`: in progress;
* nothing failing on main.

Toolchain: x86-64 Linux (Ubuntu 24.04, 4 cores), Tcl 9.0.1, rustc 1.100.0
(the repository's pin), gcc 13.3.0, clang 18.1.3, valgrind 3.22.0. Every
command runs from the checkout's root with `LANG=C.utf8 LC_ALL=C.utf8`,
after `cargo build --release --manifest-path native/Cargo.toml`.

Method: four read-only surveys covered actors and the event loop,
coroutines, the C backend, and threads, VMs and contexts. Their claims
were spot-checked against the source, and every claim this report relies
on cites the source directly. The probe corpus was then written and run,
along with the tools that read the analyses' facts.

## Contents

1. Executive findings
2. Current actor, coroutine and execution architecture
3. Existing lifetime and storage-plan facts
4. Execution ownership: definition and candidate representations
5. Actor-specific configuration
6. Relationship to contexts
7. Storage retention across suspension
8. Coroutine-frame and handle ownership
9. Hierarchical owners
10. Storage requirement composition
11. Static capacity derivation
12. Static layouts versus dynamic regions
13. The native provider and the NIR protocol
14. GC implications
15. Native and C backend placement
16. Static and embedded memory placement
17. HTTP workers and request lifetimes
18. Concurrency and backpressure bounds
19. Capacity exhaustion and error contracts
20. Allocation-free steady-state proof obligations
21. A storage-report proposal
22. Probe corpus and results
23. Quantitative measurements
24. Design alternatives and tradeoffs
25. Soundness hazard catalogue
26. The smallest coherent implementation boundary
27. Recommended milestone sequence
28. Unresolved language-design questions
29. Files, and how to reproduce

## 1. Executive findings

1. **Botlish already has one construct that is an execution owner: the
   coroutine instance.** [inspection]
   * A coroutine is constructed, started eagerly, suspended and resumed
     only by whoever holds its affine handle. It is released at the
     handle's last use, or abandoned, on every backend
     (surface/lower.tcl:745-803; hir/affine.tcl:1899, 2246).
   * Actors are coroutines (`stdlib/actor.bot:146-148`, 855-872).
   * A thread entry runs a VM of its own (native/src/runtime/thread.rs:
     410-438).
   * The program run, a native library instance and a `NAME_main` call
     each run one VM.
   * Nothing else in the language suspends and resumes independently.

   So the census proposes: **an execution owner is a coroutine instance, or
   the root owner of a VM**. A request, an actor's message and a loop
   iteration are *regions inside an owner*. An actor is the owner its
   coroutine is, so `std::actor` needs no compiler privilege (sections 4,
   5).

2. **The lifetime facts already separate the two kinds of storage an owner
   needs.** [probe]
   * `hir/lifetime.tcl` gives every producer a verdict for its innermost
     region and for its non-suspending segment.
   * An object confined to both is **segment** storage. It is dead at
     every suspension point.
   * An object confined to its region but live across a suspension is
     **persistent** storage.

   Over the 22 compiling probes, 14 String producers in suspending units
   are segment storage and 30 are persistent. Today's scratch storage
   serves only the 9 transient Strings of units that never suspend
   (`results/probes/summary.md`).

3. **Segment and persistent storage compose differently, and that decides
   the architecture.** [probe, inference]
   * Segment storage of all owners on one thread never runs at once. It
     composes by **max**, and it can stay on today's per-VM stack of
     regions, provided each region is left before every suspension.
   * Persistent storage of owners suspended at once composes by **sum**.
     It cannot live on a shared stack: an executable model finds the
     shared stack's bound exceeded in 185 of 400 random programs, while
     the per-owner rule is never exceeded and is reached in all 400
     (`models/composition.py`, section 10).
   * The genuinely new mechanism an owner needs is persistent storage per
     coroutine instance, released with the instance.

4. **On real actor programs the persistent objects are small structs, not
   Strings.** [probe]
   * The actor tests, the event-loop child example and p12 have 19
     persistent producers: 15 structs (11 actors' `Receiver`s from
     `listen`, 2 received messages, state such as `Count {total,
     handled}`, a kept `Reply`), 2 Lists, a MutableArray and a coroutine.
     None is a String
     (`results/applications/`).
   * Everything an actor sends escapes: 123 of 153 producers in
     `tests/actor/actors.bot`.
   * A p12 round trip still makes 12 managed-heap allocations (10
     protocol structs) and 22 system allocations
     (`results/measurements.md`).

   So owner storage for leaf Strings alone would place almost nothing in
   actor programs. Leaf structs are the smallest sound extension: structs
   whose fields are all immediate words, which the collector need not
   trace (section 14).

5. **Static capacity is derivable today for a measurable subset, and the
   missing facts are specific.** [probe, inference]
   * A model built only from existing facts (`tools/capacity.tcl`)
     derives a byte bound for 18 of 22 regions holding confined Strings.
     It uses the Int Ranges of `hir/range.tcl`, constant text, and
     concatenation sums.
   * Where every site allocates its own block, the bound equals the
     native provider's measured peak: p01 128 B, p14 72 B, E11 72 B.
   * No bound is below a measured peak.
   * The four unbounded regions lack exactly two facts:
     * a Range for a parameter or a resume message;
     * a size summary for a String a callee returns (p05, p13).
   * An overlay layout that reuses a dead String's bytes within one
     region would need 64 B for p01 instead of today's bump 128 B, and
     80 B for p03 instead of 152 B.

6. **Native stackful coroutines already give every owner storage, but at
   a page-and-stack granularity.** [measurement]
   * K = 4,096 simultaneously suspended request coroutines, each keeping
     one String of at most 40 bytes, map 4,096 stacks: 8 MiB plus a
     64 KiB guard of address space each (runtime/coroutine.rs:220-223).
   * Each touches 1.08 pages (about 4.3 KiB) and makes 5 managed-heap
     allocations, about 257 B (`results/stacks.md`).
   * Fused coroutines have no stack and no object; most probes are fused
     (0 stacks).

   An owner region would hold the persistent bytes exactly. The stack
   remains the owner's storage for registers and spilled locals.

7. **The C backend already realizes owner storage statically, for
   statically sized values, within one function's extent.** [probe]
   * Every construction site's storage is a fixed-size struct (`co<K>`).
     It is an automatic object of the constructing function, or a field
     of the constructing yielding function's frame. Sequential yielding
     calls share a union.
   * E15's three sites need 264 B on x86-64 and 160 B on AVR.
   * The kiosk needs 232/224/154/145 B (x86-64, Cortex-M0, MSP430, AVR),
     the C-coroutine-frames report's numbers reproduced.
   * Two boundaries matter for owners:
     * a function cannot return a handle it constructs (E15b, C
       UNSUPPORTED);
     * frames are not position-independent once constructed. E13b's
       parent frame holds a pointer to the child storage inside itself
       (`fr->v_step_10 = (&fr->co1.head)`), and contexts are pointers
       into `PREFIX_program`'s frame.

     Storage supplied by a caller must therefore be supplied before
     construction and never moved (sections 8, 16).
   * The C backend declares a writable static only for a top-level value
     a function reads (E16b: "Not reentrant"). Without one, independent
     runs are independent instances (E16).

8. **No quantity propagates through the call graph today, and contexts
   are the wrong vehicle for storage.** [inspection]
   * Context requirements are sets joined by union (hir/contexts.tcl:
     925-1050). Storage requirements need sum along chains, max over
     sequences and sum over simultaneously suspended owners.
   * A context type has one installed value per VM, so a per-actor
     policy written as a context would be one policy for all actors.
   * AGENTS.md forbids a storage context for scratch storage.
   * Configuration belongs to the owner's construction, or to a thread
     entry or the build, never to a context (section 6).

9. **Recommendation** [design]:
   **STORAGE-EXECUTION-OWNER-MILESTONE-1**, *coroutine-instance owner
   regions on the native backend*. It has five parts:
   * the storage plan gains persistent and segment regions in suspending
     units;
   * each coroutine instance has its own provider of regions, made at
     its first placement and switched in and out where the runtime
     already publishes the arriving stack (`segment`, `rt_co_yield`);
   * the provider is released at the coroutine's completion, failure,
     release or abandonment;
   * leaf Strings and leaf structs are placed;
   * fused sites carry the owner in the consumer's frame, or stay
     unfused.

   A backend-independent owner report states each owner's persistent and
   segment requirements, composed by the section 10 rules, in the
   exactness classes of section 11. No syntax and no policy knob are
   added: configuration, strict modes and the C backend's caller-provided
   storage follow it (section 27).

## 2. Current actor, coroutine and execution architecture

Established from the implementation [inspection; the surveys' citations
spot-checked]. For each candidate owner: who constructs it, when it
starts, whether it suspends, who resumes it, whether its work can overlap,
whether it has children, who ends it, what it retains, when that is
released, whether a bound exists, whether it migrates, and whether its
memory can be supplied in advance.

| | coroutine instance | actor | event-loop task | thread entry | VM (program run, library instance, NAME_main) |
|---|---|---|---|---|---|
| constructed by | `coroutine {step, first} = f(...)`: `coroutine#create` + `#start` (surface/lower.tcl:745-803) | the user's coroutine construction, moved into `Spawned` (actor.bot:146-148, 647-648) | `std::event_loop::adopt` of a handle | `std::thread::start` (thread.bot:213-226; thread.rs:286-359) | the runtime (aot.rs:262, library.rs:607, :668) |
| starts | eagerly, to its first yield (core/coroutines.tcl:21-25) | eagerly; its first request is served one turn after `start` (actor.bot:807-809) | it is a started coroutine | at spawn, on a new OS thread | at entry |
| suspends | at `yield` and at any call of a yielding function (deep; hir/coroutines.tcl:1678-1712) | at each request: `listen`, `receive`, `try_receive`, `send`, `deliver`, `pause`, `sleep` (actor.bot:294-355) | when its coroutine yields to the loop | never (THREAD-ENTRY-ENVIRONMENT, hir/threads.tcl:216-233) | never as a whole |
| resumed by | only the holder of the handle (a resume is a use, not a move) | only its host task (actor.bot:818) | only the Loop's dispatch (event_loop.bot:1548) | -- | -- |
| overlapping work in one owner | no: one continuation | no: one actor coroutine plus one host, one request in flight | no | the thread runs its VM; its coroutines interleave | its coroutines interleave on one thread |
| children | coroutines it constructs and holds | child coroutines; an actor holding `Loop` and `Actors` can start actors (tests/actor/authority.bot:153-170); no parent/child relation is recorded | as for coroutines | threads it starts (joined at its end: thread.rs:432-435) | threads, coroutines |
| ended by | completion, failure, release at the handle's last use, abandonment in an unwinding program (coroutine.rs:869-944) | its return or failure (retire), or loop shutdown and abandon (event_loop.bot:1778-1851); there is no kill | completion, failure, abandonment | its return; stop is cooperative (thread.rs:480-490) | the run's end, `NAME_destroy` |
| retains | its frames: locals live across suspension, held callee arguments | its coroutine's locals; queued messages live in the `Actors` pool (actor.bot:189-204) | -- | its own heap, statics, contexts | everything of its heap |
| storage released | natively: stack to a per-thread pool (32) or `munmap` at release; the object at the next sweep (coroutine.rs:365-389, 923-944) | with its coroutine, and the host's | with its coroutine | `drop(vm)` on the thread (thread.rs:436) | `Vm::reset`, drop (vm.rs:852-871) |
| bound on instances | none (only `mmap` failing); C: one slot per construction site | none (MutableVector rows) | none | 64 guard records per process (records.rs:38); a `Threads` limit of 1..4096 (thread.bot:106) | -- |
| migrates threads or VMs | no: a VM is never `Send`, the stack pool is thread-local, handles are not Sendable (hir/types.tcl:2902) | no (remote actors carry bytes) | no | -- | no |
| backing supplied in advance | no | no | no | a stack size (`start_sized`) | no (a library takes no storage from its caller: library.rs:476-573) |

Library guarantees, not language ones [inspection]:
* the host, its sequential serving, and FIFO order;
* mailbox capacity clamped to at least 1, with no maximum
  (actor.bot:387-393);
* `Full` when `count + reserved >= capacity` (actor.bot:511-524);
* every table a MutableVector that grows with no ceiling and never
  shrinks (`push_counted`, native/src/runtime/mutvec.rs:121-130).

"At most one message per actor per dispatch" holds only for the waiting
`receive` path (`if wait and xget(me, x_fresh) == 0`, actor.bot:726).
`try_receive` skips that check: a survey probe took two messages with two
`try_receive`s in one turn. The documentation states the guarantee more
broadly than the code. It does not affect storage, but it means the
compiler cannot derive per-dispatch bounds from the documented behavior.

Stale documentation found in passing [inspection]:
* COROUTINES.md:1270 says "handles live in local bindings only", and
  :1571 says "handles never leave their function". AFFINE-VALUES.md
  superseded both: handles move into fields, Lists, collections and
  results.
* COROUTINE-FUSION-MILESTONE-1.md §3.4 says Windows has no fusion, but
  `STACK_SWITCHING` now includes Windows MSVC (coroutine.rs:121-125).

## 3. Existing lifetime and storage-plan facts

[inspection]
* `hir::lifetime::analyze` runs per specialization instance (a *unit*).
  Per producer it computes:
  * a verdict for its activation, for each enclosing loop's iteration
    and for its non-suspending segment;
  * the objects that coexist with it.

  Per suspension point (a `coroutine#yield`, or a call of a block that
  may yield: hir/lifetime.tcl:785, 801) it computes:
  * the live bindings, pending operands, accumulators and loop positions;
  * what a suspended callee holds;
  * every object those reach.

  Interprocedural summaries make exact calls precise. Unresolved calls
  are `unknown`.
* `hir::storageplan::plan` reads those facts and asks, per String
  producer, whether placing it is semantically safe, representable and
  selected. A unit is blocked from having any region when:
  * it may suspend (hir/storageplan.tcl:82-83);
  * it is recursive (:84-85);
  * the backend excludes it (a self tail call).
* The plan is computed on demand while native lowering runs, and stored
  nowhere.

What the facts already say about owners [probe, `results/probes/`]:

* **p07b and E04 show the split this census rests on.**
  * In E04's `scan`, `name` (built before the first yield, read at the
    end) is *persistent*: activation confined, segment escapes for the
    reason `suspension`.
  * Each iteration's `piece` (its length yielded, then dead) is
    *segment* storage.
  * The plan rejects both: "it may suspend: a region is never live
    across a suspension".
* **E01**: one worker serves 1,000 jobs. Per job, `scratch` is segment
  storage and `label` is persistent within the job's iteration. Both are
  confined to the iteration, so an owner region per iteration would be
  reused for every job.
* **E13**: the parent's own String, and the child's construction (its
  closure and handle), are persistent in the parent. The child's handle,
  and with it the child, is part of the parent's retained state.
* **E05**: the actors' per-message `note` and `mark` Strings are
  persistent. Every message sent (`body`, `Req`, `Resp`) escapes with the
  reason `inherited`, from the yield to the host.

The facts do not count instances. A producer in a loop that is live
across iterations "coexists with itself" (STORAGE-LIFETIME-FACTS-
MILESTONE-1.md, section 6), but no fact says how many instances coexist.
Section 18 states what that leaves open.

## 4. Execution ownership: definition and candidate representations

**Definition** [design]. An *execution owner* is a dynamic execution
whose storage must stay valid while other executions run, and which some
existing construct ends. Its storage is what it must keep across its own
suspensions. The census separates three things:

* **ownership**: whose lifetime governs release. The owner's end releases
  its storage; nothing else does;
* **location**: where the bytes are. This may be inside a parent's
  storage, in a VM's chunk pool, in caller-provided memory, or in static
  memory. Location never implies ownership: a coroutine's region may sit
  physically inside its actor's allocation and still belong to the
  coroutine;
* **policy**: capacity, growth, fallback and placement (sections 18-20).

**The owners Botlish already has** [inspection, inference]:

| owner | begins | ends | identity at run time | statically nameable |
|---|---|---|---|---|
| root owner of a VM: program run, thread entry, library instance, `NAME_main` call | VM made (vm.rs:380-441) | VM reset or dropped | the `*mut Vm`, first argument of all generated code | per thread entry: the entry index K (ThreadDispatch, native/lower.tcl:10999-11057); per library: its exports |
| coroutine instance | its construction (`coroutine#create`) | completion, failure, release at its handle's last use, abandonment | native: the `CoroutineObj` address, stable (non-moving heap) until swept; Tcl: a process-unique ID; C: its construction storage `co<K>`; fused: none (the site's registers in the consumer's frame) | its construction site (one HIR expression; one `co<K>` type in C) |
| region inside an owner: activation, loop iteration, segment | entry, iteration start, resumption | each exit, iteration end, suspension | a mark (native) | the storage plan's regions per unit (hir/storageplan.tcl:15-24) |

**Candidate representations**, judged against the language's own rules:

| | anchor | fits the rules | weakness |
|---|---|---|---|
| A. a specialized execution instance | a unit of the specialization analysis | the plan's regions already are this | one instance runs in many owners: a yielding function called from two coroutines runs in both. An instance is a *code* identity, not an execution |
| B. construction-bound owner | a coroutine construction site; each run of it makes one owner; ownership follows the affine handle | exact: construction, start, resumption, release and abandonment already exist on every backend, and affinity already guarantees one holder | a fused site has no object, and needs an owner of its own (section 13) |
| C. lexically scoped configuration | a block a caller marks | none needed: lexical regions already exist (activation, iteration) | a scope is not an owner. It ends while a suspended execution it started is still alive (E08, E18) |
| D. explicit storage capability | a value or context passed to functions | contradicts AGENTS.md ("no allocator API, region type, reset operation, storage context") and per-VM context singularity | turns compiler-planned storage into an API |
| E. hybrid | construction is the owner (B); a scope or the owner's construction supplies policy; a parent or caller supplies the backing | yes | policy needs a language-design decision (section 28) |

**Recommended** [inference]: B for ownership, E for policy and backing.
* The owner is the coroutine instance, from construction to its end, and
  the VM's root owner for everything outside any coroutine.
* Requests, messages and iterations are regions inside an owner. A
  request becomes an owner only by being a coroutine that suspends
  independently of its siblings (E08).
* A segment is a region every owner already has between two suspension
  points.

This needs no new construct and no recognition of `std::actor`.

## 5. Actor-specific configuration

An actor is one coroutine of the protocol `Coroutine{args: [Answer],
return: Exit, ...}`, constructed by the user, typically inside an inject
block. `std::actor::start` adds a host coroutine that owns the actor's
handle as a parameter (actor.bot:806), and adopts the host into the Loop
(actor.bot:855-872) [inspection]. Under section 4 an actor is therefore
**two owners**: its coroutine, which holds its state and its
per-message work, and its host, which is library code. Whatever is
configured for the actor's construction is configured for the first of
these.

What an actor's storage consists of [probe: E05, E06, the actor tests]:

| storage | owner today | could the compiler derive it? |
|---|---|---|
| state between messages (`rx`, a fold's `k`, `Count`) | the actor coroutine's locals: persistent across every request | yes: persistent producers of its units (E05, actors.bot) |
| per-message temporaries kept across a request (`note`, `mark`) | the actor coroutine: persistent within the iteration | yes: confined to the message's iteration |
| per-message temporaries dead before the next request | the actor coroutine: segment storage | yes |
| messages queued in a mailbox | the `Actors` pool, a VM-wide `MutableVector[any]` in an installed context (actor.bot:189-204) | no: they escape to a context. Their count is a run-time capacity |
| a message a `deliver` waits to put | the parked host's frame (`deliver_for`, actor.bot:745-761) | no: library code |
| protocol records (`Exit`, `Answer`) | built per request, escape through the yield | no today: they cross every suspension (10 of p12's 12 allocations per round trip) |
| child coroutines | the actor coroutine | per site, yes |

A configuration in the brief's illustrative vocabulary (`planning:
compiler-managed`, `capacity: inferred or bounded`, `growth: forbidden`,
`heap-fallback: forbidden`, `placement: owner-provided`) maps onto the
section 4 model without making `std::actor` a primitive [design]:

* *planning* is the storage plan's regions in the actor coroutine's
  units: persistent and segment;
* *capacity* is the owner's composed requirement (section 10), where its
  exactness class allows (section 11). Where it does not, the
  configuration must supply a bound or the plan must reject it;
* *growth* and *fallback* are the provider's policy for that owner;
* *placement* is where the owner's backing comes from: a VM pool, a
  parent's slot, caller-provided or static memory.

What the configuration must be attached to is the actor's **coroutine
construction**: the expression `coroutine {step, first} = server(...)`
inside the inject block. A library cannot install a context, and only an
entry program may (hir/contexts.tcl:65-70). The construction is the one
place where per-actor identity exists statically.

Three facts limit what such a configuration can promise today
[inference]:
* most of an actor's per-message allocation is protocol structs and
  messages, which escape;
* mailbox capacity is a run-time argument (`open(4)`), so retained
  messages are bounded at run time, not at compile time;
* an actor's host is a second owner the user does not construct.

A strict actor configuration would therefore have to cover the host (by
`start` propagating it) and accept the mailbox's run-time capacity as a
configuration bound (section 18).

## 6. Relationship to contexts

| | context injection | execution storage configuration |
|---|---|---|
| decides | which capabilities and implementations code may use | how and where execution state is stored, under which bounds |
| value? | yes: one installed value per context type per VM (hir/contexts.tcl:43-50) | no: a property of an owner's storage |
| installed where | the entry program's top level, or a thread entry's statements (hir/contexts.tcl:65-70, 873-877) | at an owner's construction, a thread entry or the build [design] |
| propagation | a set, by union over exact call edges (`Requirements`, hir/contexts.tcl:925-1050), restricted by inject blocks | a quantity: sum along a chain of live calls, max over sequential calls and exclusive branches, sum over owners suspended at once (section 10) |
| lifetime | the VM's: no release, no lifecycle (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md) | the owner's: released at its end |
| static result | a requirement every caller must cover | a capacity every provider must supply |

[inspection, inference] The mechanism contexts use is a least fixpoint
over call edges, with reasons. It is the right *shape* of machinery for
storage requirements: an interprocedural summary per unit, recorded with
provenance. But the algebra differs:
* storage requirements of two sequential calls share storage (max);
* those of two suspended owners never do (sum);
* a set union cannot express either.

No quantity propagates through the call graph anywhere in the compiler
today. The closest is the storage plan's one-bit destination
(hir/storageplan.tcl:39-54).

Storage placement adds no authority. An actor constructed under `inject
no context:` keeps exactly that authority (E05), whatever its storage
policy is. E06 shows the two side by side [probe]:
* the `Journal` context owns its vector for the VM's lifetime;
* the counting actor, constructed under `inject context Journal:`, may
  push into it;
* the actor's own `banner` String and its loop state are storage of the
  actor's coroutine.

The two kinds of ownership never coincide, so a storage configuration
must not be expressed as a context. A context is one value per VM. AGENTS.md
forbids a storage context for scratch storage, and a context can neither
make two actors' policies differ nor release anything at an actor's end.

## 7. Storage retention across suspension

The scenario of brief section 6: A begins a request, builds data and
suspends; B runs and completes; A resumes and reads its data. The native
provider today is one bump position per VM, with regions nested strictly
(scratch.rs:17-25) [inspection]. If A's region stayed open across its
suspension, B's regions would be above it, which is fine. But a third
owner C, suspended *before* A with its own region below A's, resets to
its own mark when resumed and releases A's bytes. Interleaving breaks
the stack discipline. This is why the plan blocks suspending units
entirely [inspection: hir/storageplan.tcl:82-83], and why the composition
model's shared-stack rule fails (section 10).

The lifetime facts already distinguish the two cases [probe]:

* **Segment storage** (14 String producers in the corpus) is dead at
  every suspension point.
  * A region opened after each resumption and reset before each
    suspension point would hold it on the existing per-VM stack: the
    stack is balanced again at every switch.
  * A yielding call is itself a suspension point, so the caller's region
    is reset before the call. The objects it passes are "held by the
    suspended callee" and are never segment-confined
    (STORAGE-LIFETIME-FACTS-MILESTONE-1.md, section 7).
  * This is an extension of the existing scratch storage, not
    ownership.
* **Persistent storage** (30 String producers, 5 structs, 2 closures, 2
  coroutines) must survive while other owners run, so it needs storage
  per owner.

Representations of persistent storage, compared [inspection, inference]:

| representation | ownership transfer | at suspension | at resumption | another OS thread | nested calls | early abandonment | errors | runtime discovers the owner? |
|---|---|---|---|---|---|---|---|---|
| regions embedded in the coroutine frame (C) | the handle points at the storage; a move copies the pointer | nothing: the frame persists | nothing | not applicable: one thread per run | a yielding callee's frame is a union member of its caller's | release emits nothing in C | a status | no: static |
| a region descriptor in the coroutine object (native) | follows the handle (affine) | the Vm's current provider switches to the resumer's | switches back | never: a VM and its coroutines stay on one thread | non-suspending callees use the current provider's stack | released with the coroutine (`rt_co_release`, `rt_co_abandon`) | released when the cached failure is recorded, which holds only what escapes (`error`) | yes, at each switch: one pointer swap |
| a region supplied by the constructing actor | as the parent's slot | -- | -- | -- | -- | must outlive the child: the parent's storage contains the child's | -- | no |
| a slot of a parent's fixed pool | the slot index travels with the handle | -- | -- | -- | -- | slot returned at release | -- | partly: a pool lookup |
| a persistent owner identity selecting storage at resumption | -- | -- | a lookup by identity | -- | -- | -- | -- | yes, at every operation |
| hybrid: segment storage on the per-VM stack, persistent on the owner | follows the handle | the segment region is already reset; the owner's persists | a new segment region | -- | as above | as above | as above | only for persistent storage |

The natural native hook exists: `segment` (coroutine.rs:750-760) and
`rt_co_yield` (:832-848) already publish the arriving stack for the stack
guard at exactly the points where the current owner changes. Switching a
"current provider" pointer there is one store per switch [inspection,
inference]. Nested resumers are already a chain (`co_current`,
`resumer`), so the provider chain follows it. A coroutine never resumes
on another thread, because a VM is never `Send` and its stack pool is
thread-local [inspection], so an owner's provider need not be thread-safe.

Two realizations follow, and the census recommends them in this order
[inference]:

* **First: one current provider per execution.** While a coroutine runs,
  its own provider is current, and it holds that coroutine's segment and
  persistent regions alike. A segment region is reset before every
  suspension point; a persistent region stays open across it. Code a
  coroutine calls that never suspends opens its frames on the same
  current provider, as it does on the VM's today.
  * Each request and destination keeps addressing exactly one provider,
    so the protocol is unchanged.
  * The cost: a suspended owner keeps the capacity its segments needed
    reserved, though occupied only up to its persistent part.
* **Then, measured: the hybrid.** Segment regions go on the thread's
  root provider, persistent ones on the owner's. This realizes the
  composition model's shared max for segment storage (section 10) and
  saves each suspended owner's segment capacity. It needs a second lane
  in the protocol: each mark, reset and request names its provider,
  chosen statically from the facts.

Either way a suspension needs no reset beyond those the compiler emits,
and a resumption needs no lookup: the switched pointer is the lookup.

## 8. Coroutine-frame and handle ownership

C and native represent the same ownership differently [inspection,
probe]:

| | C backend | native backend |
|---|---|---|
| frame | a struct per yielding instance holding what `Persist` finds live after a resume label, its yielding calls' frames in a union (ccompile/ccompile.tcl:1616-1655, 1764-1902) | the coroutine's own stack (8 MiB reserve, pooled) |
| construction storage | one `co<K>` struct per site (`CoKind`, :1394-1426): the handle target, context pointers, the body frame; hoisted to the constructing function's top, or a field of its frame if it yields (`Create`, :1430-1463) | a 96-byte heap `CoroutineObj` (coroutine.rs:160-187) plus a stack attached at start |
| handle | a pointer to `&co.head`; a move copies the pointer | a pointer to the object |
| returned from its constructor | C UNSUPPORTED (ccompile.tcl:2280; E15b) | allowed when the result type is affine (hir/affine.tcl:578-588) |
| in a struct, List or collection | C UNSUPPORTED (`StorageRepr`, :545-551) | allowed (move positions; E08, E18) |
| several instances of one site at once | one slot per site per activation: sound because no handle crosses an iteration in C; a recursive non-yielding constructor gets one slot per activation | unbounded |
| recursive yielding chain | C UNSUPPORTED (`FrameCycles`, :1663-1700) | allowed: stackful (E14's `walk`) |
| released | nothing emitted | stack to the pool or `munmap`; object at the next sweep |
| relocatable after construction | no: E13b's frame points into itself; contexts are pointers into `PREFIX_program`'s frame | not applicable |

The C-coroutine-frames report calls frames "position-independent"
(C-COROUTINE-FRAMES-MILESTONE-1.md, around line 640). That is true of
their contents' meaning, but not of their bytes once constructed: a
yielding parent stores its child's handle as a pointer into its own frame
(E13b: `fr->v_step_10 = (&fr->co1.head)`) [probe]. Caller-provided
storage must therefore be provided *before* construction and stay where
it is. A memcpy of a live owner is not a supported operation.

What both backends share [inference] is the ownership fact itself: one
holder, a static construction site, release at the handle's last use or
abandonment. They also share the lifetime facts' persistent sets per
suspension point; persist.tcl checks that C's `Persist` never keeps less
(audit/storage-lifetime/results/persist.txt: 15 frames, 0 violations).

An owner model built on construction sites and handles needs no C-only
semantics. What differs is location:
* C places owner storage in the constructor's frame and cannot outlive
  it. Caller-provided storage is the extension
  (C-COROUTINE-FRAMES-MILESTONE-1.md, section 23).
* Native places it on the heap and the stack, and can outlive anything.

## 9. Hierarchical owners

E13 (native) and E13b (C) construct a child inside a suspending parent
[probe]:
* The child's handle, and its closure, are persistent producers of the
  parent.
* In C, the child's 56-byte storage is a field of the parent's 80-byte
  frame, inside the parent's 112-byte construction storage
  (`results/cframes.md`).
* Natively, the child's stack and object are separate allocations,
  released at the handle's last use inside the parent.

So a child owner's storage is **contained in its parent's retained
state** whenever the parent holds its handle, and released no later than
the parent [inspection]. The rules for hierarchical owners [design]:

* **Parent and child storage are disjoint while both are live.** A child
  may suspend while its parent runs, and the reverse.
* **They may overlap when their lives do not.** A child released before
  a later sibling is made may reuse its slot, as C's one slot per site
  per activation already does: no handle crosses an iteration there.
* **A parent's capacity includes its children's**, for the children
  whose handles it holds across its own suspensions. Children it
  constructs and finishes within one segment are segment storage of the
  parent.
* **A bounded parent needs a bound on simultaneously held children.**
  Natively, handles can enter a MutableVector, with no bound (E08 with a
  constant K, E18 with a run-time count).

No parent/child relation exists in the runtime or the libraries
[inspection: actor rows hold gen/state/task/mailbox/fresh/used,
actor.bot:206-213]. None is needed. The containment is the static fact
"the parent's activation keeps the child's handle", which the lifetime
facts already report (`sl-child-handle`).

## 10. Storage requirement composition

This is the census's principal model [design; checked as modeling].

**Per owner, two numbers.**
* `P`: the most bytes live across any one of its suspension points (its
  persistent requirement).
* `S`: the most bytes live during any one of its segments, persistent
  objects included.

Both come from the owner's units:
* the facts' per-suspension `objects kept`, for `P`;
* coexistence at each producer, for `S`;
* sizes from section 11.

**Composition rules.**

| relation | rule | why |
|---|---|---|
| sequential operations of one owner (E01's jobs) | max | the earlier operation's storage is dead before the later one's |
| a caller's values live across a non-suspending callee (E02 `outer`/`inner`) | sum along the live chain (a stack) | the callee's region is above the caller's |
| a caller's values live across a yielding callee (E02 `outer_y`/`inner_y`) | sum, all persistent | both survive the suspension |
| mutually exclusive branches (p03) | max | never both made: the facts say they never coexist |
| a loop's iteration (p04) | the iteration's own requirement, reset per iteration; loop-carried values counted outside it | `next` and `continue` are the iteration's exits |
| independently suspended owners on one thread (E03, E08) | `max over j of (S_j + sum over i != j of P_i)` | while one runs, every other is suspended holding at most its `P` |
| segment storage of every owner of one thread | one max | segments never run at once |
| K concurrent instances of one shape (E08) | K x `P` + `S` | as above |
| recursion (E14) | depth x per-level | finite only with a depth bound |
| an unresolved call, an unknown count | unknown | no static shape |

**The model and its check.** `models/composition.py` (no Botlish code)
generates owners as sequences of segments with objects that live within a
segment or across suspensions. It then simulates up to 200 interleavings
per program and compares the real peak with the bound:

```
python3 -I audit/storage-execution-owner/models/composition.py check 400 4
composition: 400 programs, no interleaving above the bound; the bound reached
in 400; the broken rule (one shared stack) exceeded in 185
```

[measurement of the model] Three results follow:
* The bound is sound: no interleaving exceeds it.
* It is tight under an adversarial scheduler: an interleaving that stops
  every other owner at its heaviest suspension point always exists.
* The rule a single shared stack would need (`max over j of S_j`,
  ignoring the others' persistent storage) is wrong in 185 of 400
  programs.

The selftest pins E03's shape: two workers, each keeping 40 bytes across
the suspension and using 72 in a segment, need 112 bytes, not 72.

**What a storage-requirement algebra must carry** [inference]:
* a persistent part and a segment part;
* sizes in an exactness class (section 11);
* counts of simultaneous instances (exact, bounded, configured,
  unknown);
* alternatives (max), sequences (max), live chains (sum), suspended
  owners (sum of persistent parts);
* "unknown" with the reason, which absorbs everything it meets.

Optimal packing is not required. A conservative sufficient layout is,
and the model shows that the per-owner sum is both conservative and
achievable.

## 11. Static capacity derivation

What the compiler knows today, per quantity [inspection]:

| quantity | fact | crosses functions | exactness class today |
|---|---|---|---|
| Int ranges | `hir/range.tcl`, per instance | yes, within the instance analysis | exact or bounded |
| a String's length | none: no length family for Strings (`-measures` is registered only for Lists: core/lists.tcl:80) | no | unknown |
| a String's UTF-8 bytes | none | no | unknown |
| `std::int::to_string`'s text | none registered (core/inttext.tcl:77-79); its operand's Range exists | -- | bounded, if derived from the Range [inference] |
| List cardinality | `List[T]{length: N}`, collecting-loop cardinality (hir/cardinality.tcl) | only as a declaration (`ForgetInferred`) | exact or bounded, locally |
| MutableVector capacity | length proofs while nothing resizes the copy chain | no | mostly unknown |
| struct layouts | native: `StructObj` header plus a separate field block (vm.rs:1155-1161); C: a fixed struct | -- | exact per kind |
| enum payloads | a boxed `EnumCaseObj` natively; payload-free cases are immediate words | -- | exact per case |
| coroutine frames | C: a fixed struct per site (`sizeof`); native: a stack of a fixed reserve | -- | exact (C); a fixed reserve (native) |
| live coroutine instances | C: one per site per activation; native: none | -- | exact (C); unknown (native), unless the handle is confined (section 18) |
| message sizes and mailbox occupancy | a run-time capacity per mailbox (actor.bot:387-393) | -- | configuration-bounded |
| active requests | none | -- | unknown |
| loop iteration counts | counted loops with ranged bounds | -- | exact or bounded |
| recursion depth | none, deliberately (AGENTS.md, "Depth-safe recursion"; NATIVE LIMIT STACK) | -- | unknown |
| external I/O buffers | Botlish storage is lent only for one synchronous noescape call (hir/borrow.tcl) | -- | exact per call |

The five classes the brief names map onto these: exact, proven upper
bound, configuration bound, runtime-enforced finite capacity, unknown. An
owner report can carry them per requirement without any language-visible
size type [inference]: they are facts with provenance, like the lifetime
verdicts.

**Byte-level correctness** [inspection]. A native String block is
`STR_TEXT_OFFSET` (25) + UTF-8 bytes, rounded to `STR_ALIGN` (8)
(native/src/runtime/strobj.rs:85-122). A Unicode scalar takes 1 to 4
bytes, so a length in characters bounds the bytes only times 4. ASCII
text, such as decimal digits, is 1 byte per character. Capacity
arithmetic must be checked: `str_layout` already uses `checked_add`
(strobj.rs:119). A formatting operation's own temporaries do not count:
every placed helper allocates at most one String, its result
(STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1.md, section 3). A C target
has no String: its sizes are `sizeof` of fixed structs.

**The `0..9999` example, derived and checked** [probe, inference]. In
E11, `i` comes from `fold i from 0 to 10000`, and the range analysis
proves `[0, 9999]` for `std::int::to_string(i)`'s operand. The model
(`tools/capacity.tcl`) derives:
* `to_string` gives at most 4 ASCII bytes, a 32-byte block;
* `digits.concat(" items")` gives at most 10 bytes, a 40-byte block;
* the activation region holds 72 bytes.

The native provider's measured peak is 72 B. No String-length
annotation was needed: the facts that exist suffice. The missing step is
an analysis that turns a Range into a byte count.

**The model over the corpus** (`results/capacity.md`) [probe, inference].
Over 22 regions holding confined Strings, 18 have a finite derived
capacity:

| program | region | bump capacity (model) | overlay capacity (model) | measured peak |
|---|---|---:|---:|---:|
| p01 | `label` activation | 128 B | 64 B | 128 B |
| p14 | `check` activation | 72 B | 72 B | 72 B |
| E11 | `label` activation | 72 B | 72 B | 72 B |
| p02 | `label` activation | 168 B | 168 B | 104 B (two of five sites fused into one construction) |
| p03 | `label` activation | 152 B | 80 B | 32 B (the join's constructions are not placed) |
| p07b | `worker` (suspends): one owner region | 144 B | 144 B | -- (not placed today) |
| E04 | `scan` (suspends): activation and iteration regions | 72 B + 72 B | 72 B + 72 B | -- |
| E03 | `worker` (suspends), per instance | 104 B | 104 B | -- |
| E13 | `child` and `parent` (suspend) | 72 B each | 72 B each | -- |

No derived bound is below a measured peak. The four unbounded regions
lack exactly:
* the Range of a parameter: p04's `work(n)`, and E01's resume message
  `job.id`;
* the size of a String returned by a call: p05's `make`, p13's `raw`
  and `respond`.

The first needs callers' facts, which a generic instance does not have,
or a declared domain. The second needs a result-size summary per unit, a
new interprocedural fact of the same shape as the lifetime summaries.

## 12. Static layouts versus dynamic regions

| strategy | predictability | runtime bookkeeping | fragmentation | suspension | nested calls | concurrency | errors | reuse | freestanding C | native server | collector |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A. fixed slots, overlaid when lifetimes are disjoint | exact | none | padding per slot | slots of persistent values are the owner's | slot offsets per caller, as C frames | one set per owner | nothing to undo | slot reuse | natural (C structs and unions) | needs bounded sizes | none for leaves |
| B. compiler-planned packed region (offsets) | exact | none: offsets are constants | minimal | as A | a callee's region at its caller's end offset (C's union composition) | per owner | nothing to undo | overlay by lifetime | natural | needs bounded sizes | none for leaves |
| C. bump region (today's provider) | the peak is not proven | a mark per region and two runtime calls; about 11 ns per framed activation (the scratch milestone's cost probe) | none within a region; nothing overlaid | needs a per-owner stack for persistent storage | nests naturally | per owner | reset on every exit (already done) | per region instance | needs a bound to size the region | fits today | none for leaves |
| D. fixed-capacity slot pool | bounded by the pool | a free list | per slot | one slot per suspended child | -- | the pool size is the bound | a full pool needs an admission policy | slot reuse | natural for bounded children | natural for request pools | as A |
| E. hybrid: fixed offsets for bounded values plus a bump subregion | bounded part exact | only for the subregion | small | as A and C | as A and C | per owner | as C | both | the bounded part | yes | as A |

The finding that matters [probe]: today's provider reuses a region
*across* activations and iterations, but never overlays two objects
*inside* one active region. p01's four Strings occupy four bump blocks
(128 B), though the facts say the first concatenation chain is dead
before the second begins. An overlaid layout needs 64 B. p03's two
exclusive branches occupy 152 B by the bump bound, and 80 B overlaid.

A measured peak of bump occupancy is therefore neither a minimum nor a
proof:
* it is what one input's run reached under one layout;
* the overlay capacity is what a layout respecting coexistence would
  need;
* the bump capacity is what today's layout would need in the worst run.

Fixed offsets also remove bookkeeping [inference]. With a static layout
a region needs no mark, so no runtime call and no frame word: a site's
address is the owner's base plus a constant. This is exactly how C's
frames already compose. It requires a byte bound for every site the
layout holds. Sites without a bound fall back to a bump subregion (E).
Under a strict policy they are rejected (section 19).

## 13. The native provider and the NIR protocol

The protocol today [inspection]:

| operation | meaning | lowered to |
|---|---|---|
| `scratchmark` | a region's entry: the position as a small Int, `(chunk << 32) \| offset` (scratch.rs:138-142) | `rt_scratch_mark` |
| `scratchreset M` | back to mark M: a loop's head and exit | `rt_scratch_reset` |
| `scratchexit M D` | a framed function's exits: reset unless destination D is set (scratch.rs:365-370) | `rt_scratch_exit` |
| `scratchreq` | the next String helper places its result | two stores around the helper call |
| `scratchdest` | the next direct call may place its result-only Strings in the caller's region | a store before the call, one after |
| `scratchtake` | a callee reads and clears the destination | a load and a store |

`validate_scratch` (native/src/nir.rs:3489) checks the shapes. No
register defined only by `scratchmark` or `scratchtake` is a root
(native/src/codegen/roots.rs:525).

What carries over to owners [inference]:

* **The requests and destinations carry over unchanged.** They live one
  instruction or one call, and never cross a suspension: a capable unit
  never suspends, and a destination is taken by the callee's first
  instruction.
* **Marks, resets and exits carry over**, if they address "the current
  provider" instead of `vm.heap.scratch`. A region opened in a
  suspending unit's persistent part lives on its owner's provider, which
  is switched with the coroutine. The protocol's one invariant, "regions
  nest strictly", then holds *per owner* instead of per VM.
* **A new operation is needed: an owner's end.** Release, abandonment,
  completion and failure must release the owner's provider. This can be
  runtime-side (`rt_co_release`, coroutine.rs:923-944; `rt_co_abandon`,
  :869) with no NIR change.
* **Segment regions in suspending units** need only the existing
  operations. Lowering places a mark after each resumption point and a
  reset before each suspension point, a yielding call included.

Per-owner providers rather than one provider per actor [inference]. The
number of actors and coroutines is dynamic: thousands per VM in E18 and
`results/stacks.md`. So an owner's provider should be cheap to make:
* made lazily at its first placement, as the VM's is;
* its chunks drawn from a per-VM free list, as the coroutine stack pool
  does (`POOL_LIMIT` 32, coroutine.rs:221);
* chunks returned at the owner's end.

The VM provider's first chunk is 16 KiB (scratch.rs:65). The same size
per owner would reserve 64 MiB for E18's shape at K = 4,096, for owners
that each keep at most 40 bytes. An owner's first chunk must therefore be
sized from its derived capacity where one exists (section 11: 72 to
144 B per owner in the probes), and be small and growing where none does.

The collector's check, `Scratch::contains`, would then range over every
live owner's chunks. A per-VM table of chunk address ranges keeps that a
bounds test plus a lookup (heap.rs:194-203 asks it per popped pointer
today).

**Recursion and frame cost.** The scratch report suggests moving marks
into a provider-held stack, so that a region costs no frame word and
recursive units can have regions (STORAGE-COMPILER-MANAGED-SCRATCH-
MILESTONE-1.md, sections 25-26). For storage accounting [inference]:
* such a stack consumes one word per open region in the provider,
  instead of one word per activation on the native stack;
* its depth is still the recursion's depth;
* it is unbounded in exactly the cases the native stack is: it moves
  the requirement, it does not remove it;
* it must be per owner (a coroutine's marks are its own);
* every exit, exceptional ones included, must pop it, as resets already
  do;
* a lookup costs no more than today's mark in a register.

With a static layout (section 12) there is no mark at all. That, not a
mark stack, removes the bookkeeping, and only where sizes are bounded
and the call graph is acyclic.

**Fusion is a soundness hazard for owner storage** [inspection,
inference]. A fused coroutine has no object and no stack: its template
runs in the consumer's frame, and its persistent values are the
consumer's registers (fusion.rs:42-80). Its persistent heap objects
cannot use the consumer's regions. E01's single worker lives across the
consumer's every iteration, and a `label` it made in iteration k would be
released by the consumer's iteration reset while the worker still holds
it. A fused site therefore needs either:
* an owner provider of its own, a frame-local record of the consumer,
  switched by the fused code at its dispatch;
* or to stay unfused when its chain places persistent storage.

Most probes are fused today (0 stacks mapped in E01, E03, E04, E09,
E13), so the choice matters.

## 14. GC implications

The current invariant [inspection]:
* only flat Strings are placed;
* a String holds no reference;
* the collector skips every scratch address before reading it, counting
  a root into released storage (`stale_roots`, heap.rs:194-203);
* a heap object may point at a scratch String of the same region; the
  confinement proof says it does not outlive it.

What owner storage would hold, and what each strategy requires:

| strategy | trace and mark | cross-region references | heap objects into owner storage | owner end and reset | collection during suspension | native coroutine stacks | affine cleanup | the compiler can discharge it? |
|---|---|---|---|---|---|---|---|---|
| A. fully traced owner storage | the collector scans live objects of every live owner region | allowed | allowed | must know each region's live extent | the region of a suspended owner is a root set | already walked (vm.rs:769-800) | unchanged | yes: no proof needed beyond confinement |
| B. a proven closed graph | none | only to the same region or static values | confinement proves the holder dies first | none | none | -- | -- | needs a "reaches only region or static" fact, which is not computed today |
| C. rooted owner descriptors | trace from each owner's descriptor | allowed | allowed | the descriptor dies with the owner | the descriptor is a root | -- | -- | runtime-only |
| D. restricted placement: leaves | none | none | allowed, as today | none | none | -- | -- | yes: a kind fact |
| E. hybrid by representation class | per class | -- | -- | -- | -- | -- | -- | -- |

The smallest sound expansion beyond leaf Strings is **leaf structs**: a
struct all of whose fields are, at run time, immediate words [inference].
The persistent objects of the actor programs are exactly such structs
[probe; section 1, finding 4]:
* `Receiver[M] {slot: int, gen: int}` (actor.bot:119-121);
* `Count {total: int, handled: int}` and `Reply {req: int, value: int}`
  (tests/actor/actors.bot:31-41).

An `int` field, however, may hold a BigInt pointer unless its value is
proven small. This is the same criterion that makes native context slots
refuse an unbounded `int` field (E16's first version:
CONTEXT-NATIVE-LOWERING-UNSUPPORTED, "a big integer in fixed program
data would have no GC root"). A leaf struct is placeable when every
field is proven small, by a Range or a domain, or when a run-time check
at construction falls back to the heap if any field is a pointer.

Two more facts constrain this [inspection]:
* A native struct today is two blocks, a header and a separate field
  array (vm.rs:1155-1161). A placed struct would carry its fields inline,
  and every reader goes through `ptr`, so that is a representation
  change.
* Composite placement beyond leaves needs A or B. B needs a new fact,
  and A changes the collector's cost model. Neither is the first step.

Affine values are never leaves: a coroutine handle, a resource. They keep
their own releases, and owner storage never runs Botlish code.

## 15. Native and C backend placement

| placement | native today | native, possible | C today | C, possible |
|---|---|---|---|---|
| per-VM reserved memory | the scratch provider: 16 KiB first chunk, doubling, 64 KiB object limit, 64 MiB total (scratch.rs:65-69), lazily | a reserve made at VM creation from a configured capacity | -- | -- |
| per-owner persistent buffers | none | a provider per coroutine instance (section 13) | construction storage `co<K>` | caller-provided `co<K>` [design] |
| stack storage | registers and spill slots; a coroutine's own stack | unchanged | automatic objects | unchanged |
| fixed slots | -- | static layouts for bounded sites (section 12) | every value | unchanged |
| heap-backed one-time reservations | chunks kept until `Vm::reset`; a library instance keeps its chunks across export calls until destroy (vm.rs:852-871; library.rs:607, 734) | per owner, from a pool | -- | -- |
| static-duration objects | constants (never collected) | -- | only a top-level value a function reads (`StaticBindings`, ccompile.tcl:454-475; E16b), and const tables | none, by construction [design] |
| `.bss`, linker sections, memory-mapped regions | -- | -- | the embedding's choice (examples/c-freestanding) | the embedding declares the owner struct where it wants it (section 16) |

**Interpreter and Tcl compiler** [inference]. They can honor an owner
configuration's *semantics*: the same values, errors, releases and
static validation (a rejected configuration is rejected on every
backend). They cannot honor a *physical* guarantee, because Tcl allocates
for every value. A strict configuration therefore has three options:
* be a static validation everywhere, plus a physical guarantee only on
  backends that state one (the honest split);
* refuse unsupported backends;
* run with a weaker documented interpretation.

The first matches how the compiler already treats backends: the C
backend states "no allocation" in its manifest, and native lowering's
scratch storage is an optimization the Tcl backends do not perform.
Claiming an allocation-free guarantee for the interpreter would be false.

## 16. Static and embedded memory placement

What the C backend can emit today [probe: `results/cframes.md`]. E15's
coroutine storage on four targets, as each target's compiler lays it out:

| type | x86-64 | thumbv6m | msp430 | avr |
|---|---:|---:|---:|---:|
| `co1` (counter, site 1) | 96 | 96 | 62 | 60 |
| `co2` (counter, site 2) | 96 | 96 | 62 | 60 |
| `co3` (outer, its two inner calls in one union) | 72 | 72 | 44 | 40 |
| all three | 264 | 264 | 168 | 160 |

Writable file-scope objects: none. Transient C stack, as gcc
-fstack-usage measures at -O2 on the host: `program` 768 B, the rest 48 B
or less. For the kiosk: `session` 672 B, `run` 192 B.

A conceptual owner struct an embedding could place [design, conceptual
C, no ABI]:

```c
typedef struct {
    app_co1 worker;        /* a construction site's storage (frames, head) */
    app_co2 requests[8];   /* a bounded pool of request owners             */
    unsigned char scratch[APP_SCRATCH_BYTES]; /* a derived reusable region */
} app_storage;
```

Placements, portable or not [inference]:

| placement | portability |
|---|---|
| a statically allocated instance in `.bss` (`static app_storage s;` in the embedding) | portable C11: the embedding writes it, never the generated code |
| an instance supplied by a caller (`app_run(&s, &value)`) | portable C11 |
| several independent instances | portable, if the generated C declares no writable static (E16: none; E16b: one, "Not reentrant") and the runtime provider's storage is also per instance (today's reference Int provider keeps static arenas and serves one thread: examples/c-freestanding/providers/botlish_rt_v1_int_arena.c) |
| a linker-defined section, a fixed address | compiler and linker extensions: the embedding's, never Botlish semantics |

What a compiler and linker together could guarantee for an embedded
owner [inference]:
* **no general allocation**: the C subset already has none, and its
  services are the only allocation;
* **a fixed total reservation**: `sizeof(app_storage)`, if every site
  and pool is bounded;
* **stable addresses**: required anyway, since frames are not
  relocatable (section 8);
* **alignment**: the struct's;
* **no hidden coroutine stack**: true in C;
* **bounded pending operations**: only with bounded pools.

Two limits remain:
* **transient C stack** is separate from the owner's static RAM, and is
  bounded only without recursion. Ordinary C recursion is allowed and
  unprotected (C-COMPILE-FREESTANDING-MILESTONE-1.md); a static stack
  bound needs a call graph without cycles, as gcc's `-fstack-usage`
  per-function numbers only compose then;
* **the reference provider's static arenas**, which are per process.

## 17. HTTP workers and request lifetimes

p13 handles a request with a function call. E07 puts p13's handler inside
a persistent worker coroutine. It parses a request line given on
resumption, suspends once more for the body, then builds the response
from the parsed path (kept across that suspension) and the body
[probe, measurement]:

| | p13 (a call per request) | E07 (a worker, a suspension per request) |
|---|---|---|
| managed-heap allocations per request | 1.00 (the `Request` struct; 8 Strings placed) | 9.00 (8 Strings, 1 struct) |
| system allocations per request | 2.00 | 10.00 |
| Strings placed in scratch storage | 8 | 0: the worker's units suspend |
| owner classes in the worker | -- | transient 1, segment 1, persistent 1, result 14, escapes 4 |

The same work loses every placement once it runs inside a suspending
owner. That is the measured cost of having no owner storage.
* The worker's parse results are *result*-class Strings of `parse`
  (substrings), placed by destination into a region of the caller's.
* The caller is now the worker, a suspending unit, so the destination
  has nowhere to go.

Under section 7's first realization, the worker's own provider would
hold the request's persistent part (`r` and its fields, and the
substrings by destination) in a per-request iteration region, and
`respond`'s temporaries in segment regions. One reservation would then
serve every request: reuse across sequential requests, for the 9 objects
per request E07 measures.

What must not be assumed [inference, probe: E17]:

* **A handler's return does not end its output's life.** In E17 the
  handler yields each response, and the consumer queues it and flushes
  every fourth. The facts classify the response as escaping (`yield`),
  so no region of the handler may hold it.
* **A network layer that sends later needs an ownership contract.**
  Botlish has three foreign-call contracts for byte storage:

  | contract | expressible today | storage consequence |
  |---|---|---|
  | copy synchronously | yes: a `read noescape` exposure for one C call (the census's p16) | the buffer may be reused after the call returns |
  | borrow until completion | no: a parameter that may keep the pointer refuses Botlish storage (E17b: FOREIGN-BORROW) | -- |
  | transfer ownership | for C-owned memory, as an affine `Ptr` or a resource; across VMs, as bytes copied by `std::transfer` | the receiver owns a copy |

  Compiler-managed reuse is safe today because no external party can hold
  Botlish storage past a call. An asynchronous send that borrowed a
  response buffer would need a lifetime ending at the operation's
  *completion*: neither a call's return nor a scope's end, and not a
  suspension either. That is a language decision (section 28). The
  network interface must expose copy, borrow-until-completion or
  transfer explicitly for owner reuse to stay safe.

Cancellation, errors, partial responses and backpressure end a request's
region the way any exit ends a region:
* an early `return`, a `fail` or a handled error exits the iteration
  (STORAGE-LIFETIME-FACTS-MILESTONE-1.md, section 8);
* a worker's termination is its owner's end;
* a cancelled request that is a coroutine is released or abandoned
  (E09, E09b).

## 18. Concurrency and backpressure bounds

What Botlish represents today [inspection]:

| quantity | represented | enforced | static? |
|---|---|---|---|
| mailbox capacity | `open[M](capacity)`, at least 1, no maximum (actor.bot:387-393) | `Full` / `deliver` waits for room (actor.bot:511-552) | configuration-bounded, at run time |
| senders waiting for room | a count per mailbox | unbounded | no |
| pending messages in transit | at most one per actor (`Exit.payload`), one per waiting sender (in host frames) | by protocol | per actor: yes |
| coroutine instances | none | none (only `mmap` failing) | C: one per site per activation; native: no |
| event-loop tasks, registrations, timers | MutableVector rows, never shrinking | none | no |
| a registration's record capacity | `r_cap` per registration (event_loop.bot:1159-1166) | Reliable policy holds, Lossy drops by policy | at run time |
| outstanding requests | none | none | no |
| threads | 64 guard records per process; a `Threads` limit of 1..4096 | `ThreadLimit` | configuration-bounded |
| outcome records | 4,096 | capped | yes |

**How a compiler could count simultaneous instances** [probe, inference].
A construction site whose handle is confined to its innermost region (the
`coroutine#create` producer's verdict) has at most one live instance per
instance of that region. That is C's one-slot rule, derivable natively
from the facts:
* 19 of the corpus's 28 coroutine constructions are transient (confined);
* 6 escape: into a vector in E08 and E18, into the event loop in E05
  and E06;
* 2 are persistent, held across the constructing coroutine's
  suspensions (E13);
* 1 is returned (E15b).

An escaping handle needs either a collection bound (E08: K = 8 by
construction, but MutableVector lengths are not tracked across resizes)
or a configured bound (E18: the count comes from the program's
arguments).

The four classes, and what applies [inference]:

| class | example | an owner's storage |
|---|---|---|
| compile-time fixed concurrency | E03 (two workers), E08 (K = 8, if the vector's length were proven) | K x `P` + `S`, exact |
| configuration-bounded | a mailbox's capacity; a worker pool of 8 | the configuration's count times the per-instance requirement |
| runtime capacity checked at admission | `Full` today; a pool slot | the reserved pool; admission refuses beyond it |
| unbounded | E18; the event loop's tables | no finite reservation: reject, configure a bound, or fall back |

The census adds no default ceiling (brief section 17). A full pool must
never drop a message or overwrite a live request. The existing semantics
that apply are `Full`, an API's declared capacity result, and a waiting
`deliver`. Admission is where a bound belongs, before a request's owner
exists, not inside its operations (section 19).

## 19. Capacity exhaustion and error contracts

Existing behavior is consistent across backends [inspection]: running
out of storage is outside the language's semantics.
* C turns a provider's `BOTLISH_RT_V1_LIMIT` into the terminal status
  C RUNTIME LIMIT, "which no Botlish handler catches"
  (ccompile/botlish_rt_v1.h:26-36).
* Natively a stack overflow is terminal (NATIVE LIMIT STACK), and the
  scratch provider falls back to the heap (`fallbackLarge`,
  `fallbackCapacity`).
* The one recoverable capacity outcome is a value an API declares: a
  mailbox's `Full`, a thread start's `ThreadLimit`.

| option | when | effect on contracts |
|---|---|---|
| A. compile-time rejection | a strict owner whose requirement is not finite, or not within its configured capacity | none at run time: a diagnostic naming the unbounded producer and its reason (section 11's "why") |
| B. admission backpressure | a configured pool of child owners | the API's existing result (`Full`) or a wait; no new error inside the work |
| C. a declared capacity error | an operation whose signature already declares one | only where declared; never added implicitly |
| D. configured fallback | an opportunistic owner (today's scratch policy) | none: a fallback changes no value or error |
| E. an unrecoverable target limit | a constrained target | terminal, like C RUNTIME LIMIT |

A strict no-allocation policy must not change a function's result or
its declared errors [inference]. A String concatenation that declared no
error cannot start failing because a region is full: a function's
`errors` clause is its contract, and the completion analysis proves
handlers against it. So the policy must make capacity an *admission*
question (B) or a *compile-time* one (A). A strict owner is admitted only
when its whole requirement fits, so nothing inside it can run out. What
cannot be proven falls back (D) or ends the run (E), by the owner's
configuration. Capacity policy and semantic errors stay separate: a
policy chooses among A, B, D and E, and never invents C.

## 20. Allocation-free steady-state proof obligations

Seven guarantees, different in kind [inference]:

| guarantee | what must be proven or measured | today |
|---|---|---|
| 1. no managed-heap allocation | every producer an owner runs is placed or immediate | p01, p04, p05, p14, E11: 0 per unit; p13: 1 (a struct); every suspending probe: all of them (`results/measurements.md`) |
| 2. no system-allocator call | 1, plus every runtime helper's own temporaries | p01, p04: 0 per unit; p13: 2; p14: 2 per declared failure (`rt_fail_declared_payload`); E10: 6.63 per unit with failures and a cached coroutine failure (`cofailed` allocates a stackless failure object) |
| 3. no backing growth | a reservation sized by the owner's proven capacity | today: lazily reserved, doubling chunks |
| 4. no allocation in runtime helpers | each helper's own behavior | true of the placed String helpers (at most one String, their result); false of the declared-failure path |
| 5. no allocation in external libraries or platform services | the foreign functions' contracts | not stated anywhere today |
| 6. no unbounded implicit stack growth | recursion depth and coroutine stacks | native: an 8 MiB stack per unfused coroutine (each touches a page), recursion unbounded by design |
| 7. no unbounded retained state | every owner's persistent requirement and count finite | requires section 18's bounds |

An owner report must identify every remaining allocation source by site
and kind, not just count them. The native allocation report already does
this per site (`native::allocationReport HIR sites 1`), and DHAT named
p13's struct and p14's failure path in the scratch milestone. Initial,
one-time and lazy allocations, such as the first chunk, a coroutine stack
taken from the pool or a lazily built table, are separated from
per-operation ones by measuring at two sizes, as every measurement tool
here does. A program is not allocation-free because its application
Strings use scratch storage: E05 places nothing and allocates 26 system
blocks per round trip, and p13 still allocates its struct.

## 21. A storage-report proposal

A backend-independent owner report, of which today's facts can already
produce most [design; the fields marked * need a new analysis]:

```text
owner: the coroutine of worker constructed at e04-resumption.bot:20:9
  instances: at most 1 per iteration of the fold at :19:5 (handle confined)
  persistent:
    activation region: name = to_string(seed).concat(" name")
      bytes <= 8 (to_string of [0, 999]: 3 digits)        [bounded, range]*
      block 40 B                                           [native layout]*
  segment:
    iteration region of the fold at :12:13: piece ...     [bounded, range]*
  composed: P = 72 B, S = 144 B                            [section 10]*
  placement: owner provider (native) | frame field (C)     [backend]
  unresolved: none
  still allocating: the coroutine object, its stack        [allocation report]
```

The fields, and where each comes from [inference]:

| field | source | exists today |
|---|---|---|
| owner identity and construction site | the specialization analysis's thunk units ("the coroutine of worker constructed at ...") | yes |
| instance count | the construction producer's verdict | yes, as a verdict; the count rule is new |
| persistent and segment sets per region | the lifetime facts | yes |
| per-site byte bounds and exactness | ranges, constant text, a result-size summary | ranges yes; byte bounds and result summaries no |
| block sizes and alignment per target | the backend's layout (native: strobj.rs; C: `sizeof`) | yes per backend |
| overlap (coexistence) | the lifetime facts | yes |
| composition | section 10 | no |
| policy assumptions and fallback | the configuration | no |
| external obligations (foreign calls, borrowed buffers) | the C FFI contracts | yes per call |
| proof provenance | the facts' reasons | yes |
| measured peak, observed reservation | the allocation report's `scratch` section | yes, kept apart from proven numbers |

The report keeps apart, as the scratch report already does per site:
exact object size, exact physical layout, proven sufficient capacity,
conservative estimate, measured peak, observed reservation and unknown.
It never calls a conservative layout minimal, or a measured peak
(p13's 400 B) a capacity.

## 22. Probe corpus and results

`audit/storage-execution-owner/probes/` holds 23 programs: E01-E18 and
the b variants E09b, E13b, E15b, E16b, E17b. All are real Botlish; no
scenario needed invented syntax. `tools/probe.tcl` writes one report per
program and `results/probes/summary.md`. Every compiling probe gives the
same value on the interpreter and natively [probe]. E17b is rejected
(FOREIGN-BORROW) as intended.

| probe | units (suspending) | suspension points | transient | segment | persistent | result | escapes | placed today | heap allocations, scratch on (off) | stacks mapped / reused | what it establishes |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| E01 sequential owner | 4 (2) | 3 | 1 | 2 | 2 | 0 | 2 | 0 | 4000 (4000) | 0 / 0 (fused) | one worker's jobs reuse one iteration region; `label` persists across a resumption |
| E02 nested calls | 7 (3) | 3 | 6 | 3 | 2 | 0 | 0 | 4 | 5000 (9000) | 0 / 0 | the non-suspending chain is placed today (frames nest); the suspending one is not |
| E03 independent coroutines | 5 (3) | 4 | 4 | 0 | 3 | 0 | 0 | 0 | 6000 (6000) | 0 / 0 | two instances of one site, persistent storage distinct (P sums) |
| E04 resumption | 4 (2) | 2 | 2 | 2 | 2 | 0 | 0 | 0 | 10000 (10000) | 0 / 0 | `piece` is segment storage, `name` persistent |
| E05 actor messages | 6 (4) | 8 | 0 | 1 | 6 | 10 | 26 | 0 | 3361 (3361) | 4 / 0 | per-message `note`, `mark` persist; messages escape |
| E06 actor with a context | 7 (4) | 5 | 1 | 1 | 3 | 10 | 22 | 0 | 956 (956) | 4 / 0 | context-owned state vs the actor's own; authority by inject block |
| E07 HTTP worker | 7 (2) | 3 | 1 | 1 | 1 | 14 | 4 | 0 | 9000 (9000) | 0 / 0 | p13's placements lost inside a suspending owner |
| E08 concurrent requests | 5 (2) | 2 | 1 | 3 | 2 | 2 | 2 | 0 | 5000 (5000) | 8 / 792 | K = 8 request states coexist; handles escape into a vector |
| E09 abandonment | 4 (2) | 3 | 2 | 0 | 3 | 0 | 0 | 0 | 3000 (3000) | 0 / 0 | a suspended coroutine released at its handle's last use |
| E09b abandonment with a resource | 4 (2) | 3 | 2 | 0 | 3 | 0 | 0 | 0 | 5000 (5000) | 1 / 999 (unwinding: never fused) | abandonment runs the cleanup once per instance |
| E10 declared failure | 5 (2) | 2 | 3 | 0 | 2 | 0 | 6 | 0 | 4334 (4334) | 0 / 0 | a payload String escapes (`error`); failure paths allocate |
| E11 bounded String | 2 (0) | 0 | 2 | 0 | 0 | 0 | 0 | 2 | 0 (20000) | 0 / 0 | Range `[0, 9999]` gives 72 B, the measured peak |
| E12 unbounded String | 2 (0) | 0 | 2 | 0 | 0 | 0 | 2 | 0 | 1014 (1014) | 0 / 0 | a run-time count: no bound on the loop or the text |
| E13 nested owners | 6 (4) | 6 | 2 | 0 | 6 | 0 | 0 | 0 | 4000 (4000) | 0 / 0 | the child's handle persists in the parent |
| E13b C nested owners | 5 (4) | 6 | 1 | 0 | 2 | 0 | 0 | 0 | 0 (0) | 0 / 0 | in C the child's storage is a field of the parent's frame; a self-pointer |
| E14 recursion | 5 (2) | 3 | 7 | 0 | 0 | 0 | 0 | 0 | 403 (403) | 1 / 0 | `nest` is recursive: no region; `walk` a recursive yielding chain (C refuses) |
| E15 C frames | 7 (6) | 8 | 6 | 0 | 0 | 0 | 0 | 0 | 0 (0) | 0 / 0 | 264 B of coroutine storage on x86-64, 160 B on AVR |
| E15b returned handle | 4 (2) | 2 | 1 | 0 | 0 | 2 | 0 | 0 | 2 (2) | 1 / 0 | runs natively; C UNSUPPORTED |
| E16 static instances | 4 (2) | 2 | 1 | 0 | 0 | 0 | 1 | 0 | 0 (0) | 0 / 0 | C: no writable static; a bounded context field (native slots need small Ints) |
| E16b static binding | 4 (3) | 3 | 3 | 0 | 0 | 0 | 0 | 0 | 3 (3) | 1 / 0 | C: one writable static, "Not reentrant" |
| E17 output retention | 5 (2) | 2 | 3 | 2 | 0 | 3 | 4 | 0 | 4002 (4002) | 0 / 0 | a queued response escapes its handler |
| E17b borrowed send | rejected: FOREIGN-BORROW | | | | | | | | | | borrow-until-completion is not expressible |
| E18 dynamic concurrency | 5 (2) | 2 | 3 | 1 | 2 | 2 | 2 | 0 | 164 (164) | 32 / 0 | a run-time count of suspended coroutines |

Producers by owner class and kind over the corpus
(`results/probes/summary.md`):

| class | String | struct | coroutine | closure | list | other |
|---|---:|---:|---:|---:|---:|---:|
| transient | 9 | 4 | 19 | 14 | 4 | 4 |
| segment | 14 | 1 | 0 | 0 | 0 | 1 |
| persistent | 30 | 5 | 2 | 2 | 0 | 0 |
| result | 14 | 10 | 1 | 1 | 14 | 3 |
| escapes | 12 | 38 | 6 | 6 | 3 | 6 |

The same classification over larger programs (`-native 0 -scope app`,
`results/applications/`):

| program | producers | transient | segment | persistent | result | escapes |
|---|---:|---:|---:|---:|---:|---:|
| tests/actor/actors.bot | 153 | 0 | 2 | 10 | 18 | 123 |
| tests/actor/lifecycle.bot | 119 | 0 | 4 | 5 | 22 | 88 |
| examples/event-loop/03-child.bot | 23 | 0 | 0 | 2 | 5 | 16 |
| examples/dfa/csv/export.bot (and its modules) | 65 | 28 | 1 | 0 | 11 | 25 |
| examples/games/2048/demo.bot (and its modules; no coroutine) | 124 | 33 | 0 | 0 | 69 | 22 |
| the census's p12 | 39 | 0 | 1 | 2 | 10 | 26 |

The persistent producers there are 15 structs (11 `Receiver`s from
`listen`, 2 received messages kept across a later request, `Count` and
`Reply`), 2 Lists, a MutableArray and a coroutine; no String. The CSV application's coroutine sources keep nothing across
their suspensions.

## 23. Quantitative measurements

**Per unit of work** (`tools/measure.tcl`, N = 500 and 1,000, scratch
storage on, fusion on; valgrind 3.22.0) [measurement]:

| workload | unit | managed-heap allocations | by kind | scratch placements | system allocations |
|---|---|---:|---|---:|---:|
| p01 | call (four temporaries) | 0.00 | -- | 4.00 | 0.00 |
| p04 | iteration | 0.00 | -- | 1.00 | 0.00 |
| p13 | request (a call) | 1.00 | Struct 1.00 | 8.00 | 2.00 |
| p14 | unit (failures only past 900) | 0.00 | -- | 3.67 | 0.41 |
| p12 | actor round trip | 12.00 | String 2, Struct 10 | 0.00 | 22.00 |
| E01 | job (two resumptions) | 4.00 | String 4 | 0.00 | 4.00 |
| E03 | pair of coroutines | 6.00 | String 6 | 0.00 | 6.00 |
| E04 | coroutine (five segments) | 10.00 | String 10 | 0.00 | 10.00 |
| E05 | actor round trip | 16.00 | String 6, Struct 10 | 0.00 | 26.00 |
| E07 | request to a worker | 9.00 | String 8, Struct 1 | 0.00 | 10.00 |
| E09 | abandoned coroutine | 3.00 | String 3 | 0.00 | 3.00 |
| E10 | check and job, some failing | 4.33 | String 4, Coroutine 0.33 | 0.00 | 6.63 |
| E13 | parent with a child | 4.00 | String 4 | 0.00 | 4.00 |

The scratch milestone's numbers reproduce at this commit: p01 and p04 at
zero, p13 at one struct, p12 unchanged. Every suspending probe allocates
every String it builds. E04's ten Strings per coroutine are two
persistent ones (`name` and its `to_string` piece, made once) and eight
segment ones (`piece` and its piece, in each of four iterations): exactly
the storage section 7's owner regions would place.

**Suspended native coroutines** (`tools/stacks.tcl`) [measurement]. K
request coroutines, all suspended at once, each keeping one String of at
most 40 bytes:

| K | stacks mapped | managed-heap allocations | heap bytes | minor page faults |
|---:|---:|---:|---:|---:|
| 1 | 1 | 7 | 289 | 133 |
| 256 | 256 | 1,282 | 64,990 | 414 |
| 1,024 | 1,024 | 5,122 | 260,902 | 1,253 |
| 4,096 | 4,096 | 20,482 | 1,053,478 | 4,577 |

Per suspended coroutine:
* 1.08 pages first touched (about 4.3 KiB on this host);
* 5 managed-heap allocations, about 257 B: the 96-byte coroutine
  object, a 48-byte thunk block and three Strings (the `to_string` piece
  and `head` before the suspension, one after it; byKind at K = 256 and
  512);
* 8 MiB plus 64 KiB of reserved address space (33 GiB of reservations
  at K = 4,096, `MAP_NORESERVE`).

What it keeps across its suspension is at most 40 bytes. The peak
resident set is reported but unreliable here: Linux syncs a thread's
resident-page counters in batches, and the program runs on a worker
thread. Page faults are the measure.

**C coroutine storage** (`tools/cframes.tcl`) [measurement]:
* the kiosk 232 / 224 / 154 / 145 B (x86-64, thumbv6m, msp430, avr),
  equal to C-COROUTINE-FRAMES-MILESTONE-1.md's table;
* E15 264 / 264 / 168 / 160 B;
* E13b's parent 112 B, its child's 56 B inside it;
* E16 88 B, E16b 80 B plus one static.

**Costs that bear on the design** (from the scratch milestone, not
remeasured) [measurement]:
* an empty framed region costs about 11 ns: five runtime calls;
* a placed String saves 15-23 ns;
* the first chunk is 16 KiB.

These bear on the design in two ways [inference]:
* An owner provider switched at every coroutine switch is one store per
  switch. A p12 round trip is about 3.3 us, so the switch cost is
  negligible beside it.
* Owner regions save allocations only where persistent and segment
  producers are representable. In actor programs that is leaf structs
  as much as Strings.

Static layouts would remove the mark and reset calls entirely where
sizes are bounded. Fewer allocations does not automatically mean lower
latency: p04's single small String per iteration paid more in region
bookkeeping than it saved at sizes where the heap never collects
(scratch report, section 22).

## 24. Design alternatives and tradeoffs

Six architectures, rated per criterion: + good, o neutral or partial,
- poor [inference].

| criterion | A. per-VM storage, owner switching | B. coroutine-owned storage | C. hierarchical, supplied at construction | D. static owner layout | E. storage capability or context | F. hybrid: plan + configuration + backend realization |
|---|---|---|---|---|---|---|
| existing semantics | + no change | + the handle already governs | o needs a parent's storage named at construction | o needs bounded sizes | - an allocator API, which AGENTS.md excludes | + |
| actor ergonomics | o | + an actor is its coroutine | + pools of children | - needs bounds | - explicit calls | + |
| context integration | + orthogonal | + orthogonal | + orthogonal | + orthogonal | - one per VM | + orthogonal |
| coroutine suspension | + a switch per resumption | + by construction | + | + (C frames) | o application-managed | + |
| native web servers | + | + per request coroutine | + bounded request pools | o where bounded | o | + |
| freestanding C | - no runtime switch exists | + frame fields | + caller-provided slots | + exact | - | + |
| dynamic actor creation | + | + | o needs a pool bound | - | o | + |
| nested ownership | o | + containment by handle | + | + unions and fields | o | + |
| bounded concurrency | - | o counts unknown natively | + pool size | + | o | + |
| error propagation | + nothing new | + | o a full pool needs admission | + | o | + |
| GC safety | o a chunk registry over owners | o the same | o | + leaves only | o | o leaves first |
| zero-allocation guarantees | - opportunistic | o per owner, after sizes | + per pool | + | o | + per configuration |
| code-generation complexity | + small: the protocol is unchanged | o owner end and fusion | o | - per-site offsets | o | o |
| runtime overhead | + one store per switch | + | o slot management | + none | o calls | + |
| cross-backend portability | o native only | + the same ownership in C and native | + | o C natural, native needs bounds | - | + |
| incremental cost | + | + | o | - | o | + in stages |

F is the recommendation, built from the others' parts rather than chosen
because it resembles the motivating sketch. The evidence for each part:

* **The owner is B** (the coroutine instance). It is the only construct
  that suspends independently (section 2). Its handle already enforces
  one holder, and both backends already end it at known points. The
  probes' persistent producers are all inside coroutine units
  (sections 3, 22).
* **The native realization is A + B**: a provider per coroutine instance
  made current at its switches. The switch points already exist
  (section 7). The protocol is unchanged per owner (section 13). The
  composition model shows a shared stack is unsound for persistent
  storage, and a per-owner one is sound (section 10).
* **The C realization is B + C + D**: frames are owner storage already,
  and caller-provided slots are the missing piece (section 16).
* **Configuration (policy) comes last.** Nothing configurable has a
  compiler anchor until owners exist, and the capacity it would bound
  is not computed until sizes are (section 11).
* **E is excluded**: it converts compiler planning into an API, and
  contexts cannot carry per-owner policy (section 6).

A and D remain useful as backend strategies. A serves owners whose
sizes are unknown (bump regions per owner). D serves owners whose sites
are all bounded (fixed offsets, no marks).

## 25. Soundness hazard catalogue

For each hazard: the invariant, the compiler's obligation, the runtime's
obligation, whether today's implementation provides it, and a detector
that would catch a violation [inference; "today" from inspection and
tests].

| # | hazard | invariant | compiler obligation | runtime / backend obligation | today | detector |
|---|---|---|---|---|---|---|
| 1 | two live owners share writable storage | per-owner disjointness while both live | persistent storage only in its owner's regions | providers never share a chunk | n/a (no owners) | E03 and E08 under GC stress with poisoning; the composition model |
| 2 | a suspended coroutine reads storage another execution reset | persistent objects never in the per-VM stack | the plan places persistent sites only on owner providers | the switch makes the right provider current | provided negatively: suspending units get no region (hir/storageplan.tcl:82-83) | a mutant placing a persistent site on the VM stack; E04 poisoned |
| 3 | a parent resets storage a child still owns | a child's storage is its own owner's, not a parent region's | a child's handle is persistent in its parent (facts) | a child's provider released only at the child's end | n/a | E13 with poisoning; a mutant releasing a child's provider at the parent's region reset |
| 4 | a child outlives its parent's backing | containment (parent-provided placement) | parent-provided placement only when the handle is confined to the parent's activation | -- | n/a | a returned-handle variant of E13 (native), E15b's rule (C) |
| 5 | a returned value points into released storage | result-only sites follow a destination | `result` reasons only (`plan-result-any-reason`) | `scratchexit` keeps the region when given a destination | provided (scratch milestone tests) | `ss-run-dest-stale`, its mutants |
| 6 | a retained message references recycled bytes | messages escape | sends are escapes (yield, context) | -- | provided: E05, E06 (`inherited`) | E05 poisoned with owner regions on |
| 7 | a network operation reads an overwritten send buffer | no Botlish storage outlives a foreign call | FOREIGN-BORROW | exposure ends at the call | provided: E17b rejected | E17b; FOREIGN-BORROW tests |
| 8 | actor reentrancy breaks an assumed sequential lifetime | per-owner sequential execution | none: an actor is one coroutine, one continuation | the host serves one request at a time (library) | provided by construction | a probe with two `try_receive`s per dispatch (section 2) |
| 9 | independent coroutines share one fixed slot | one slot per site per activation only when handles cannot cross an iteration | the slot rule only for confined handles | -- | C: provided; native: no slots | E08-shaped programs in C (rejected: handles in a vector) |
| 10 | unbounded recursion in a fixed region | no static capacity for recursive units | recursive units get no region, or a depth bound | -- | provided: recursive units blocked (:84-85) | E14; `ss-plan-recursive` |
| 11 | a GC root into released owner storage | no live reference into a released owner | confinement | `contains` covers every live owner's chunks; `stale_roots` counted per owner | per-VM only | GC stress with poisoning; `staleRoots` 0 |
| 12 | a composite placed object keeps a heap object the collector misses | only leaves placed, or a closed graph, or traced regions | kind facts: leaf = every field immediate | the collector skips placed objects | provided: Strings only | a mutant placing a struct with a heap field; GC stress |
| 13 | cleanup skipped during early abandonment | an owner's storage released on every end | -- | `rt_co_release` and `rt_co_abandon` release the provider | n/a | E09, E09b: owner occupancy 0 after the run |
| 14 | cleanup run twice | one owner per storage | ownership follows the handle | the provider is released once, idempotently (releases already are) | releases idempotent | a mutant releasing at both release and sweep |
| 15 | capacity overflow or misalignment | checked arithmetic; 16-byte chunks; 8-byte blocks | byte bounds with checked sums | `str_layout`'s `checked_add` | provided for blocks | Rust tests of the provider |
| 16 | hidden runtime allocations break a strict policy | every allocation source reported | -- | the allocation report per site; system allocations measured | reported, not enforced | `tools/measure.tcl`; DHAT |
| 17 | fallback silently weakens a guarantee | strict owners have no fallback | -- | fallbacks counted (`fallbackLarge`, `fallbackCapacity`) | counted | a strict-mode test failing on any fallback |
| 18 | OS-thread migration selects the wrong backing | no migration | -- | a VM is never `Send` | provided | `ss-run-vms`; thread tests |
| 19 | static storage shared between instances | no writable static state in an instance | C: no `StaticBindings` for strict instances | providers per VM | C: E16b declares one ("Not reentrant") | `ccFileScopeObjects` (tests/c-compile.test:1746-1753); E16, E16b |
| 20 | context retention outlives its provider | contexts live as long as their VM | -- | -- | provided: contexts have no lifecycle | -- |
| 21 | an imprecise summary calls an escaping object confined | facts sound | the lifetime facts | -- | four defects found and fixed by the scratch milestone's GC-stress runs | the lifetime oracle, its fuzzer, GC-stress reachability, the scratch fuzzer |
| 22 | a fused coroutine's persistent objects in the consumer's iteration region | a fused site's persistent storage belongs to the site, not the consumer | the plan cannot see fusion | fusion gives the site an owner record, or stays unfused | n/a | E01 fused, poisoned, with owner regions |
| 23 | a C owner storage moved after construction | frames are not relocatable | caller-provided storage before construction | never memcpy a live owner | n/a | E13b (a self-pointer) |

The scratch milestone's experience applies: its implementation exposed
four unsound lifetime facts that the analysis's own tests had not, all
through GC stress with poisoned storage. Owners need the same
adversarial instruments, applied before anything is placed across a
suspension.

## 26. The smallest coherent implementation boundary

**STORAGE-EXECUTION-OWNER-MILESTONE-1: coroutine-instance owner regions
on the native backend** [design].

Scope:

1. **The plan.** `hir/storageplan.tcl` gives a unit that may suspend two
   kinds of region, both on the running owner's provider (section 7's
   first realization):
   * *segment regions*, for producers confined to their segment. They are
     marked after each resumption point and reset before each suspension
     point; a yielding call is one.
   * *owner regions* (activation and iteration), for producers confined
     to their region but live across a suspension.

   The hybrid, with segment storage on the thread's root provider, is a
   later refinement measured against this.

   Recursive and excluded units stay blocked. The plan's three questions
   stay apart; a new reason names the owner.
2. **The owner.** Each native coroutine instance gets a provider of
   regions, made at its first placement, with chunks from a per-VM pool,
   its first chunk sized from its derived capacity where it has one
   (section 13):
   * made current at the points that already publish the arriving stack
     (`segment`, `rt_co_yield`; coroutine.rs:750-760, 832-848);
   * released at completion, failure, release and abandonment
     (coroutine.rs:869-944);
   * the VM's own provider remains the root owner.
3. **The protocol.** `scratchmark`, `scratchreset` and `scratchexit`
   address the current provider. Requests and destinations are
   unchanged. `validate_scratch` keeps its shapes.
4. **The collector.** It recognizes every live owner's chunks by address
   (a per-VM range table) and counts stale roots per owner. Only leaf
   Strings are placed, so nothing is traced.
5. **Fusion.** The milestone measures and picks one:
   * a per-site owner record in the consumer's frame (at most one live
     coroutine per fused site);
   * or fusion keeping unfused any site whose template holds owner-region
     operations, reported `kept` with its reason.

   The sound minimum is the second.
6. **The owner report.** A backend-independent text, from the plan and
   the facts:
   * per construction site: its persistent and segment requirements per
     region, and the instance count when the handle is confined;
   * per site: a byte bound by local rules only (constants, `to_string`
     of a finite Range, concatenation sums, `append_char`, `substring`;
     `tools/capacity.tcl`'s rules), in an exactness class;
   * per owner: the section 10 composition.

   Unbounded sites say why (a parameter, a call's result).

Not in scope: configuration syntax, strict modes, structs, C, actors as
anything but coroutines, interprocedural size summaries, external
storage.

Why native, not C, first [inference]:
* **The gap is native.** C already keeps statically sized persistent
  values in frames (`Persist`: 15 frames, 0 violations). Native has
  nowhere to keep a dynamically sized object across a suspension
  without the heap (E07: p13's eight placements lost).
* **The owner boundary is the same in C**, and the owner report covers
  both. C's missing piece, caller-provided storage, is about *location*
  (outliving the constructor), not about surviving suspension. It
  becomes its own milestone.
* **Native exercises the hard invariants**: GC, interleaving, release
  and abandonment, fusion. C's frames already satisfy them by
  construction.

Answers to the brief's open choices:
* the anchor is the coroutine construction (section 4);
* no actor syntax is needed (section 5);
* owners come before strict sizes, which a strict policy needs anyway
  (section 11);
* C is not the simpler proof of persistence across suspension
  (above);
* native persistent regions need no new GC contract for leaves, only
  coverage of every owner's chunks (section 14);
* no externally driven instance API is needed for this step;
* there is no strict mode yet. A test instrument may reserve an owner's
  derived capacity at creation and count any growth or fallback, to show
  the bounded subset (E04, E03, E13, p07b's shapes) needs neither
  (section 11's table).

Acceptance would require [design]:
* E01, E03, E04, E07, E09, E10 and E13 place their persistent and
  segment Strings, with values equal on the interpreter, the Tcl
  compiler and native with owner regions on and off;
* plain runs and runs under `BOTLISH_NATIVE_GC_STRESS=1` with released
  storage poisoned;
* zero stale roots and zero protocol errors;
* no owner storage left after the run;
* per unit, no reservation in the steady state;
* two simultaneously suspended owners never overlap (E03, E08);
* abandonment and failure release (E09b, E10);
* mutants for hazards 1, 2, 3, 11, 13, 14 and 22, each killed by a
  detector of behavior;
* the scratch milestone's fuzzer extended with yields inside its
  generated helpers.

## 27. Recommended milestone sequence

The brief's section 26 asks for each improvement STORAGE-COMPILER-
MANAGED-SCRATCH-MILESTONE-2 proposed to be judged on its own:

| proposal | kind | prerequisite of execution ownership? |
|---|---|---|
| 1. inline mark and reset | local optimization (the position as Vm words) | no; it composes: an owner switch makes "current provider" one more inline load |
| 2. less per-activation frame overhead | local optimization | no |
| 3. recursion handling (marks in the provider) | moves the mark's word off the native stack; no accounting gain (section 13) | no; bounded owners exclude recursion anyway |
| 4. companion and internal variants | lowering coverage | no |
| 5. deferred constructions at joins (p03) | lowering coverage | no |
| 6. confined structs | a GC-relevant representation change (inline fields; leaves first) | not for the owner boundary, but for its payoff in actors: their persistent objects are leaf structs (section 1, finding 4) |
| 7. loop-built results through destinations | plan coverage | no |

The sequence [design], by dependency:

1. **STORAGE-EXECUTION-OWNER-MILESTONE-1** (section 26): coroutine-
   instance owners on native, segment and owner regions, the owner
   report with local byte bounds. Prerequisite: the scratch milestone
   only.
2. **STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-2, part 1: leaf
   structs**, placed in any region (VM or owner): structs whose fields
   are immediate words, proven small or checked at construction with
   heap fallback. This is the step that makes owners pay off in actor
   programs. Parts 1-5 and 7 above are independent and can be
   scheduled by measurement.
3. **STORAGE-SIZE-BOUNDS-MILESTONE-1**: byte bounds as facts with
   provenance, including result-size summaries across calls (p05, p13),
   ranges from declared domains for parameters, and instance counts for
   confined handles. Then **static layouts** (fixed offsets, overlay
   by coexistence) for owners whose sites are all bounded, removing
   marks there (p01: 64 B instead of 128).
4. **C-BOUNDED-STORAGE-MILESTONE-1**: caller-provided construction
   storage (handles returned from their constructor, E15b), an
   application-instance boundary (create, step, destroy over
   caller-provided owner structs), and the same owner report with exact
   `sizeof`s. A provider of runtime services per instance, not static
   arenas. Independent of 2 and 3; useful to embedded targets
   immediately.
5. **A language-design decision on owner configuration** (section 28),
   then **STORAGE-OWNER-POLICY-MILESTONE-1**: per-owner reservation,
   growth, fallback and placement; admission bounds for pools of child
   owners; compile-time rejection of an unbounded strict owner;
   exhaustion by the section 19 options.
6. **Composite placement**: a closed-graph proof or traced owner
   regions, for messages and protocol structs. This is the remaining 10
   structs of every actor round trip.
7. **A language-design decision on operation-completion lifetimes** for
   byte storage lent to asynchronous I/O (section 17), before any
   network layer reuses owner buffers.

## 28. Unresolved language-design questions

1. **Where is an owner's configuration written?** At the coroutine
   construction (an actor's is the user's construction), at a thread
   entry (per VM), in the build or target configuration, or in several
   with a precedence. The census found no compiler anchor finer than a
   construction site.
2. **Does configuration propagate?**
   * Does `std::actor::start`'s host inherit the actor's policy?
   * Do children inherit their parent's policy, or does a strict parent
     require strict children?
3. **Exhaustion semantics.** Which of section 19's options may a program
   choose: compile-time rejection, admission backpressure, fallback, a
   terminal limit? And may it choose per owner?
4. **Bounds for text.** A String length refinement (like `List[T]{length:
   N}`), a bounded-text domain, or only derived bounds (E11's `0..9999`
   gives 4 bytes)? Derived bounds cover the census's bounded regions; a
   declared one would cover parameters (p04) and messages (E01).
5. **Recursion under a bounded owner.** Reject it (as C rejects
   recursive yielding chains), or accept a declared depth bound?
6. **Calls through function values.** Must callable contracts carry
   storage requirements for a bounded owner to call them? Today a generic
   instance places nothing.
7. **Requests.** Is "a request" ever a construct, or always an iteration
   or a coroutine? The census found the latter sufficient.
8. **Parent-provided placement.** May a construction name its parent's
   storage as its location, for pools of children? This needs a way to
   speak about storage the language has deliberately avoided.
9. **Backends without physical guarantees.** Does a strict owner reject
   the interpreter, or validate statically and run unguaranteed?
10. **Fusion versus owner storage.** Is losing fusion for a site whose
    coroutine owns storage acceptable, or must fusion always win?
11. **Asynchronous borrowing.** An affine pending-operation token over
    byte storage, or "external operations always copy or own"?
12. **Reentrancy of C entry points.** Per-run, per-instance or static
    storage for embeddings that call from an interrupt (inherited from
    the static-reuse census).

## 29. Files, and how to reproduce

The census changed nothing in `core/`, `hir/`, `surface/`, `compiler/`,
`native/`, `ccompile/`, `stdlib/` or any package. New files:

* `docs/STORAGE-EXECUTION-OWNER-CENSUS-1.md` (this report) and its line
  in `docs/INDEX.md`;
* `audit/storage-execution-owner/README.md`;
* `audit/storage-execution-owner/probes/`: the 23 probes and the module
  E09b imports;
* `audit/storage-execution-owner/tools/`: `probe.tcl`, `capacity.tcl`,
  `measure.tcl`, `stacks.tcl`, `cframes.tcl`;
* `audit/storage-execution-owner/models/composition.py`;
* `audit/storage-execution-owner/results/`: every result this report
  cites.

Reproduce (after the native build; `LANG=C.utf8 LC_ALL=C.utf8`):

```bash
tclsh9.0 audit/storage-execution-owner/tools/probe.tcl
```

```bash
tclsh9.0 audit/storage-execution-owner/tools/probe.tcl -native 0 -scope app -out audit/storage-execution-owner/results/applications tests/actor/actors.bot tests/actor/lifecycle.bot examples/event-loop/03-child.bot examples/dfa/csv/export.bot examples/games/2048/demo.bot audit/storage-static-reuse/cases/p12-actor-messages.bot
```

```bash
tclsh9.0 audit/storage-execution-owner/tools/capacity.tcl
```

```bash
tclsh9.0 audit/storage-execution-owner/tools/measure.tcl
```

```bash
tclsh9.0 audit/storage-execution-owner/tools/stacks.tcl
```

```bash
tclsh9.0 audit/storage-execution-owner/tools/cframes.tcl
```

```bash
python3 -I audit/storage-execution-owner/models/composition.py check 400 4
```

Run times on the census's container: `probe.tcl` about 5 minutes (the
actor probes' lowering dominates); the application census about 4;
`measure.tcl` about 6 (valgrind); the rest under a minute each.
