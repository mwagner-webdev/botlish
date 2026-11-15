# STORAGE-STATIC-REUSE-CENSUS-1: compiler-derived storage lifetimes, reusable memory and actor-specific storage configurations

A census of what Botlish's compiler, runtimes and libraries know and do
about storage, ownership, escape, lifetime, coroutine frames and actors, and
of what compiler-managed reusable storage would need. **No compiler,
runtime, standard-library, test or language behavior changed.** The probe
corpus, its tools and results are
[`../audit/storage-static-reuse/`](../audit/storage-static-reuse/).

The central question:

> Can the compiler derive a sufficient storage layout for an actor's
> steady-state execution, including persistent state, coroutine frames,
> temporary values, messages and outstanding operations, so memory can be
> reserved once and safely reused afterward?

The short answer is: **for one backend and one class of values it already
does; for the values a server or an actor actually spends its allocations
on, not yet, and the reasons are specific.** The sections below establish
which facts exist, which are missing, and what the smallest sound first
step is.

Evidence is tagged by kind:

* **[inspection]** -- established by reading source;
* **[probe]** -- established by compiling or running a program of the
  corpus (`audit/storage-static-reuse/cases/`, results in
  `results/probes.md` and `results/probes/CASE.txt`);
* **[measurement]** -- an observed count, size, time or generated
  representation (`results/measurements.md`, the probe records);
* **[inference]** -- a conclusion drawn from established facts;
* **[design]** -- a proposal; nothing of it is implemented.

Source locations are `file:line` at commit 3a819456 (main's head when this
census began). Toolchain: Tcl 9.0.1, rustc 1.100.0, gcc 13.3.0, clang 18.1.3,
Linux 6.18 x86-64, 4 processors.

## Contents

1. [Executive findings](#1-executive-findings)
2. [Current compiler and runtime architecture](#2-current-compiler-and-runtime-architecture)
3. [Existing ownership, escape and liveness facts](#3-existing-ownership-escape-and-liveness-facts)
4. [Storage ownership and lifetime taxonomy](#4-storage-ownership-and-lifetime-taxonomy)
5. [Coroutine-frame analysis](#5-coroutine-frame-analysis)
6. [Actor execution and message-storage analysis](#6-actor-execution-and-message-storage-analysis)
7. [Context and actor-configuration integration](#7-context-and-actor-configuration-integration)
8. [Storage interference and reuse opportunities](#8-storage-interference-and-reuse-opportunities)
9. [Collection and buffer representation](#9-collection-and-buffer-representation)
10. [Capacity and boundedness analysis](#10-capacity-and-boundedness-analysis)
11. [Suspension and asynchronous-operation lifetimes](#11-suspension-and-asynchronous-operation-lifetimes)
12. [Placement mechanisms by backend](#12-placement-mechanisms-by-backend)
13. [Potential storage-plan and accounting artifacts](#13-potential-storage-plan-and-accounting-artifacts)
14. [Probe corpus and reproducibility](#14-probe-corpus-and-reproducibility)
15. [Measurements and limitations](#15-measurements-and-limitations)
16. [Design alternatives and tradeoffs](#16-design-alternatives-and-tradeoffs)
17. [Soundness hazard catalogue](#17-soundness-hazard-catalogue)
18. [Smallest viable implementation boundary](#18-smallest-viable-implementation-boundary)
19. [Recommended milestone sequence](#19-recommended-milestone-sequence)
20. [Open questions requiring language-design decisions](#20-open-questions-requiring-language-design-decisions)
21. [Files, and how to reproduce](#21-files-and-how-to-reproduce)

## 1. Executive findings

1. **The C backend already plans storage statically -- for statically
   sized values only.** A generated C program allocates nothing after
   entry: every value is a C object of a fixed type, every coroutine
   construction a fixed-size slot of its constructing function's frame,
   every yielding function a frame struct holding the C variables the frame
   pass (`Persist`) finds live across a suspension, sequential yielding
   calls overlaid in a union (C-COROUTINE-FRAMES-MILESTONE-1.md, sections 6
   and 14) [inspection, probe: p07-p10, p17, p18]. But the C subset has no
   String, no List of unknown length, no mutable collection, no closure and
   no Float64. 15 of the corpus's 22 programs are C UNSUPPORTED: 13 for one
   of those values (or a context that owns one), p14 first for a handler
   that binds an error payload (it builds Strings too), and p10b for a
   returned coroutine handle; the front end rejects p16b [probe].

2. **No HIR analysis computes when an ordinary value's storage may be
   reused.** Liveness exists per class of value: affine values (per-path
   ownership states, a statement-granular last use in the binding's own
   sequence, every exit and error edge), mutable-collection places
   (`NoLaterUse`, operand-order precise), construction linearity (at most
   one use per path), and representation identity (`hir/escape.tcl`'s use
   verdict over literals and recognized constructions). None of them covers
   an arbitrary String, List or struct; none computes which bindings are
   live across a suspension; the only all-value liveness is NIR's register
   liveness in the native driver and the C backend's textual `Persist` over
   its own generated C [inspection].

3. **The native backend allocates every heap-kind temporary individually
   and reclaims it only by tracing.** A non-moving mark-and-sweep collector
   runs once the bytes allocated since the last collection exceed
   max(1 MB, 2 x live) (`native/src/runtime/heap.rs:1-9`, `:48`, `:277`).
   No stack allocation of a heap object, no arena or bump region, and no
   reuse of a dead object's memory exist; the coroutine-stack pool and
   in-place mutation of a unique collection backing are the only reuse
   [inspection]. The backend saves by *avoidance*: scalar-replaced structs
   and Lists, construction plans, immediate words, register-only string
   representations, coroutine fusion [inspection, probe].

4. **The steady-state opportunity is large, and measurable.** In every probe
   whose values die within their iteration, allocations grow linearly in N
   while what is reachable at the worst allocation point (measured under
   `BOTLISH_NATIVE_GC_STRESS=1`) stays constant [measurement]:

   | workload | allocations per unit | bytes per unit | reachable peak, any N |
   |---|---:|---:|---|
   | request handler (p13) | 9 | 423 | 6 objects, about 310 B |
   | actor round trip (p12) | 12 | 718 | 66 objects |
   | two sequential temporaries (p01) | 4 | 121 | 2 objects, about 60 B |
   | String across a fused suspension (p07b) | 5 | 156 | 3 objects, about 90 B |

   A request needs a few hundred bytes; the allocator is called per
   temporary and the collector cleans up per megabyte.

5. **The facts that reuse needs are only partly present.** Overwriting a
   temporary's backing is safe when (a) the value's identity is confined to
   a region (never stored, returned, captured, yielded across, sent,
   exposed), (b) the region's end is known on every exit, and (c) its size
   is bounded or a fallback exists. (b) exists, for affine values
   (`hir::affine::ExitReleases`). (a) exists only inside representation
   analyses (`hir/escape.tcl`, `hir/construction.tcl`) and never as a fact
   about non-affine values, whose identity Botlish shares freely by
   reference within a VM -- an actor message, for instance. (c) does not
   exist for Strings at all, and for Lists only through a declared
   `List[T]{length: N}` [inspection, probe].

6. **Actors are not a compiler concept.** `std::actor` is ordinary Botlish
   over `std::event_loop`: an actor is two coroutines (its own and a
   library host), messages are `any` values in a VM-wide pool, a mailbox's
   capacity is a run-time argument of `open`. The compiler sees coroutine
   constructions, affine moves, inject blocks and one internal identity
   function, `std::actor::recover` [inspection]. An actor-specific storage
   configuration therefore has no compiler anchor today. The compiler-visible
   execution owners are the **thread entry** (each runs a VM with its own
   heap already), the **coroutine construction site** (one slot in C) and
   the **program run** (C's `PREFIX_run`) [inspection, inference].

7. **Zero general-heap steady state is achieved today** in the C subset
   (structurally) and in native code whose values are all immediate,
   scalar-replaced or fused (p07-p10 fused: the program's result List is the
   only allocation). It is **not** achieved by any program that builds text
   (every `to_string`, `concat`, `substring` allocates), by actors (their
   protocol structs cross every suspension), or by runtime services that
   allocate (Float64 results, BigInt limbs). Asynchronous I/O that borrows
   Botlish storage is unrepresentable by design (FOREIGN-BORROW, p16b): a
   safety property to preserve, not a gap to paper over [probe, inspection].

8. **Recommendation.** Start with a preparatory milestone,
   **STORAGE-LIFETIME-FACTS-MILESTONE-1**, rather than a scratch allocator.
   It is one backend-independent HIR analysis of storage lifetimes per
   specialization instance: which values' identities stay inside a region
   (an activation, a loop iteration, the span between two suspensions), and
   which bindings and pending operands are live across each suspension. It
   would be reported as a storage plan and checked against the two oracles
   that exist (C's `Persist` must never keep less; native reachability
   under GC stress must never contradict a claim), changing no code
   generation. Then **STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1** on the
   native backend, for String and List temporaries confined to a loop
   iteration or an activation, with a heap fallback. Execution-owner
   configuration comes after both, anchored to thread entries and
   construction sites (sections 18 and 19).

## 2. Current compiler and runtime architecture

HIR (`hir/`) is the authoritative semantic representation; every analysis
fact lives in it or in its side tables. Three executable families compile
it [inspection, AGENTS.md "Compiler architecture"]:

* the reference interpreter and the Tcl compiler (`core/`, `compiler/`), on
  Tcl values;
* the native backend (`native/`): HIR is lowered to NIR, which Cranelift
  compiles; the runtime is Rust (`native/src/runtime/`);
* the C backend (`ccompile/ccompile.tcl`): HIR becomes freestanding C11.

Where storage lives in each:

| | interp, compile (Tcl) | native | C |
|---|---|---|---|
| ordinary values | tagged Tcl lists (`core/value.tcl:1-40`), reference-counted `Tcl_Obj`s, freed when the count drops to zero | immediate words (small Int, Bool, unit, UnicodeChar, payload-free enum cases, C addresses) or individually allocated GC objects (`runtime/value.rs:1-48`) | C objects of fixed types: automatic variables, frame fields, file-scope objects for top-level values |
| reclamation | reference counting, immediate | tracing, non-moving mark-and-sweep, threshold max(1 MB, 2 x live) (`heap.rs:1-9`, `:48`, `:277`) | none needed; a big Int lives in the runtime-service provider's storage |
| mutable collections | header `{mutvec ID}` over a Tcl list in `store(ID)`, Tcl's copy-on-write (`core/mutvec.tcl:1-20`) | GC header over `Rc<VecDeque<Value>>` / `Rc<[Value]>`, `Rc::make_mut` copy-on-write (`runtime/mutvec.rs:58-108`) | C UNSUPPORTED |
| coroutines | one Tcl coroutine and a store entry | a 96-byte `CoroutineObj` and a private 8 MiB stack (mmap, reserved, committed lazily; 64 KiB guard; a per-thread pool of 32: `runtime/coroutine.rs:218-226`); fused, registers of the consumer | a storage struct in the constructing function's frame |
| contexts | the run's dictionary | the VM's context area | objects of `PREFIX_program`'s frame (C-CONTEXTS-FREESTANDING-MILESTONE-1.md, section 9) |
| threads | refused (THREAD-UNAVAILABLE) | one VM per thread: its own heap, statics, context area (`runtime/thread.rs:286-439`) | none |

The native heap's facts that matter here [inspection, confirmed by the
background survey's reading]:

* every object is one Rust allocation (a String is one block of header and
  UTF-8; a List, Struct or closure a header box and a boxed slice), freed to
  the system allocator when swept;
* roots are precise: per-safepoint stack maps on every host with
  native-frame roots (`runtime/framewalk.rs:124-131`), suspended coroutine
  stacks walked when their handle is marked;
* a collection happens only inside an allocation; a started (unfused)
  coroutine adds 16 KiB of pressure toward the threshold although its stack
  is not heap memory (`runtime/coroutine.rs:674-676`) -- which is why p07b
  unfused collects 158 times at N = 10000 where the fused program collects
  once [measurement];
* `peakLiveBytes` counts every allocation as live until a collection proves
  otherwise (`runtime/metrics.rs`), so it measures residency including
  garbage. The census therefore reports, beside it, the peak under GC
  stress, where a collection precedes every allocation.

## 3. Existing ownership, escape and liveness facts

### What each analysis computes

| analysis | unit, precision | what it proves | kind | consumer |
|---|---|---|---|---|
| `hir::affine` ownership flow (`hir/affine.tcl:1164-1449`) | affine binding, per path; joins at `if`/handler/loop | live / moved / maybe-moved at every expression; USE-AFTER-MOVE | semantic | diagnostics, releases |
| `hir::affine::Scopes` last use (`hir/affine.tcl:1657-1726`) | affine binding -> the last statement *of its own sequence* containing a reference; a reference nested in a loop or `if` makes the whole statement the last use | where its release goes; resources and unwinding coroutines extended to the sequence end (`Scoped`, `:1732`) | semantic | `Releases` (`:1899`), `ExitReleases` (`:2246`) |
| `hir::affine::ExitReleases` (`hir/affine.tcl:2246-2365`) | every exit (`return`, `fail`, `break`, `continue`), every call's error edge per error name, pending temporaries | what a leaving path must release | semantic | every backend's release lowering |
| `hir::mutvec` copy convention (`hir/mutvec.tcl:788-996`, `NoLaterUse` `:1395`, `Moved` `:1599`) | place path (binding and field path) at one expression; later statements, later operands left to right, branches, handlers, later loop iterations | where a logical copy of a mutable collection is needed, and where a header may move instead | semantic (value semantics) and optimization | elaboration, `hir::discarded` |
| `hir::mutvec::ObservedOnly`/`Escapes` (`hir/mutvec.tcl:1979-2084`) | collection parameter or local | never stored, returned, captured or mutated: passed uncopied | optimization | elaboration |
| `hir::construction::Linear`/`FoldLinear` (`hir/construction.tcl:351`, `:396`) | String/List binding per instance | referenced at most once on every path | representation | native construction plans |
| `hir/escape.tcl` use verdict and slots (`:44-62`, `UseVerdict` `:2030-2131`) | literals and recognized constructions per instance; four slot kinds (locals, instance parameters, instance results, fold slots) | object identity never observed | representation, with width and transport *policy* ("Width is a policy, not a proof", `:58-59`) | native scalar replacement |
| `hir/transport.tcl` | exact-call forwarding graph | arithmetic over widths and budgets, "heuristic and dimensionless" | policy | escape.tcl |
| `hir/blockescape.tcl`, `hir/stringregion.tcl` | closures, substring regions | use classification | representation | native lowering |
| `hir::coroutines` (`hir/coroutines.tcl:1679-1715`) | block | `mayYield` (the deep yield effect over exact calls), `next` | semantic effect | every backend; C state machines |
| `hir::borrow` and foreign contracts (`hir/borrow.tcl:127-158`, `core/cabi.tcl:905-973`) | pointer parameter | byte storage exposed for exactly one call when the contract says noescape; `captures`/`unknown` refused (FOREIGN-BORROW) | semantic (declared contracts) | lowering of exposures |
| `hir::contexts` (`hir/contexts.tcl:43-50`, `ReleaseEdges` `:1058`) | block, program | installed set, transitive requirements, which regions may release a resource | semantic | every backend |
| `hir/range.tcl`, `hir/cardinality.tcl`, List length refinements | instance; declared across functions | integer ranges, exact List lengths, collecting-loop cardinality, MutableVector lengths (only while nothing resizes the chain) | semantic facts | unboxing, bounds proofs |
| NIR register liveness (`native/src/codegen/roots.rs:489`) | every NIR register | live-in/live-out per instruction | backend | stack maps, fusion (`fusion.rs:454`, `:555`) |
| C `Persist` (`ccompile/ccompile.tcl:1744-1902`) | C variable of a generated yielding function | persistent when a reference to it follows a resume label in its C block, or lies in a loop enclosing the label | backend, textual | C frame layout |

All in this table is [inspection]; the HIR rows were read by a background
survey and spot-checked: `Scopes` is affine-only and statement-granular
(`hir/affine.tcl:1666`, `:1698-1712`), and no file of `hir/` computes
liveness across a suspension (a search for it finds only NIR's
`live_at_many`).

### What none of them provides

* **G1. No liveness of ordinary values.** An immutable String, List or
  struct has no computed last use; natively its storage lives until a
  collection notices it is unreachable [inspection].
* **G2. Statement granularity.** Affine last use is the enclosing statement
  of the binding's own sequence: a handle read once early inside a long
  loop statement is live for the whole loop [inspection].
* **G3. No liveness across suspension in HIR.** The C backend decides it on
  generated C; native unfused coroutines keep the whole stack; fusion uses
  NIR liveness [inspection].
* **G4. Proof entangled with policy.** The analyses that do prove identity
  confinement (escape.tcl) also apply width ceilings and transport budgets,
  and their recognition depends on spelling: `fn f(i) -> P: return P {...}`
  allocates a Struct per call where `fn f(i) -> P: P {...}` allocates none
  (p17: 1000 Structs against 0) -- `Exits` sees the explicit `return` node
  and calls the result "mixed exits" [probe, inspection]. A storage planner
  reading these facts would inherit such differences.
* **G5. No identity-confinement fact for values that are not candidates.**
  `std::int::to_string`'s result, a `substring`, a `construct`ed String: no
  analysis says "this value never leaves this region" [inspection].
* **G6. No size bound for text.** No String length refinement exists; the
  bound of a to_string of a ranged Int is not derived [inspection].
* **G7. Facts cross functions narrowly.** List lengths only as declarations
  (`hir::types::ForgetInferred`), ranges per instance, escape slots across
  exact closed calls; a call through a function value carries nothing
  [inspection].

### Semantic, storage and observation lifetime

| | how long | what expresses it today |
|---|---|---|
| semantic lifetime | how long a value or resource must stay valid | affine ownership and releases; a resource's lexical scope (LEXICAL-RESOURCE-CLEANUP-EXPLORATION-MILESTONE-1.md); for everything else, "as long as a reference exists" |
| storage lifetime | how long the backing memory stays reserved | the collector (native), reference counts (Tcl), C automatic storage and frames (C); nothing the compiler decides for heap values |
| observation lifetime | how long another participant can read the storage | within a VM, any holder of a reference; C, exactly one call (noescape exposure); a context's members, in place through context places; an external party past a call: *not expressible* for Botlish storage (FOREIGN-BORROW) |

The distinction the brief's example draws -- a response buffer dead to the
handler but still read by an asynchronous send -- cannot arise today,
because no Botlish storage can be observed past a call by anyone outside
the VM [inspection, probe p16b]. Section 11 records what that costs.

## 4. Storage ownership and lifetime taxonomy

Two tables over the same nine categories. "Today" means the current
implementation; "proof" means a compiler fact.

| category | owner today | lifetime begins | lifetime ends | mutable |
|---|---|---|---|---|
| expression temporary | no owner: the collector (native), the reference count (Tcl), the C block (C) | construction | last use -- computed for none but affine and mutable collections | immutable values; collection headers through places |
| call-local scratch | not a concept: the activation's registers, Cranelift stack slots, C locals | call entry | segment or call end | n/a |
| coroutine frame | the handle (affine) owns the *execution*; storage is a `CoroutineObj` plus a stack (native), a storage struct of the constructing function's frame (C), the consumer's registers (fused) | construction (eager start) | release at the handle's last use or an exit (native: stack to the pool, object to the collector); C: the constructing function's return | yes, by its own code only |
| actor state | the actor coroutine's locals and fold intermediates, plus its host coroutine; rows in the VM-wide `Actors` context | `start` | the actor returns or fails (retire), or the loop abandons it and `reap` closes its mailboxes | yes |
| message payload | an ordinary value; between `send` and `take` a slot of the VM-wide `payloads: MutableVector[any]` pool | the send (a logical copy) | the receiver's last reference (collector) | immutable values; collections copy-on-write |
| outstanding I/O buffer | Botlish storage: one synchronous call (noescape exposure); C-owned memory: an affine `Ptr` with no drop descriptor; the Linux driver's rings: `calloc`ed once in C | the call / the C allocation | the call's return / C's own free | C's memory, yes |
| request-local storage | not a concept; implicitly one handler call, one fold iteration, one actor receive | -- | -- | -- |
| context-owned state | the installed context (CONTEXT-OWNED-AFFINE-STATE-MILESTONE-1.md) | `with context` | never released: the run's (or the VM's) end | yes, through context places |
| shared or externally owned storage | C (`Ptr`, native views and edits, non-owning); another VM never shares (bytes are copied) | foreign call | foreign contract | through native edits |

| category | transferable | observed elsewhere | may overlap another | reuse provable today |
|---|---|---|---|---|
| expression temporary | freely (immutable sharing) | by every holder of a reference | native: no; C: yes (the C compiler's slot reuse) | only where no storage exists at all (scalar replacement, plans, C automatic values) |
| call-local scratch | -- | -- | C: yes | C only |
| coroutine frame | the handle moves; storage never moves (C: pointer copies, `cc-co-storage-of-the-constructor`) | through the handle only | C: sequential yielding calls share a union (p09) | C: per construction site, yes; native: no |
| actor state | no (an `Address` is unsendable; the coroutine is adopted, an affine move) | through mailboxes | no | no |
| message payload | yes, within the VM (reference); across VMs only as transfer bytes (three copies and a decode) | sender and receiver may both hold it | no | no |
| outstanding I/O buffer | a C pointer, as an affine value | by C | -- | no Botlish storage can be one |
| request-local storage | -- | -- | -- | no construct to prove it against |
| context-owned state | never copied out when affine (AFFINE-CONTEXT-COPY-OUT) | by every function requiring the context | no | the capacity of a unique backing survives `clear` (p19) |
| shared / external | per contract | per contract | -- | -- |

Actor lifetime, coroutine lifetime, request lifetime and OS-thread lifetime
differ [inspection]: an actor is a coroutine plus a host coroutine plus
mailbox rows, ending at retire or reap; a coroutine ends at its handle's
release; a request has no representation; a thread's VM lives from
`std::thread::start` until its entry returns, and outlives every actor it
hosts. A value can look dead locally and still be live: a message queued in
a mailbox pool slot, a String held by a suspended coroutine's frame (p07b's
`kept`), a context member, a C buffer the driver's ring owns.

## 5. Coroutine-frame analysis

### How `Persist` decides

`ccompile::Persist` (`ccompile/ccompile.tcl:1764-1902`) reads the lines of
the C function the backend has just generated, with declarations, resume
labels and construction storage marked [inspection]:

* it records each C block's extent by its braces, each `for (;;) {` as a
  loop, each resume label's line, each declaration's line, and every
  identifier-shaped word of every line as a reference;
* a variable whose block holds a resume label after its declaration is
  persistent when any of its references lies after the label and before
  the block's end, or anywhere in a loop of the block that encloses the
  label; persistent variables become frame fields, every use rewritten to
  `fr->NAME` (`Fields`, `:1904-1914`);
* a variable with a label in its block but no such reference is hoisted to
  the function's top so the dispatch's `goto` skips no declaration;
* construction storage is always a field; parameters are always fields (the
  caller writes the arguments there).

This is a *line-order* approximation of reachability. It is conservative --
it may keep what a path-sensitive liveness would not -- never optimistic.

### What originates in HIR and what exists only in generated C

| fact | origin |
|---|---|
| which functions are state machines (`mayYield`), the thunks, handle types and protocols, instances and their calls, ranges, the thunk's required contexts, affinity, self tail calls | HIR and its analyses (C-COROUTINE-FRAMES-MILESTONE-1.md, section 3) |
| which variables survive a suspension | generated C only |
| join temporaries (`j1`), call results and statuses (`r1`, `st2`), message copies (`msg1`) | generated C only: lowering artifacts with no HIR binding |
| frame nesting and union members, the recursion refusal (`FrameCycles`) | the C backend's frame types |

### Precision, measured

p18 [probe, measurement]:

```botlish
fn worker(seed: int, flag: bool) -> int:
    x = seed * 3
    y = seed + 1
    if flag:
        yield y
        0
    else:
        x
```

The generated function reads `x` only in the `else` branch, which no path
from `resume_1` reaches -- and `x` is a frame field:

```c
    fr->v_x_5 = (fr->p_seed_2 * INT64_C(3));
    v_y_7 = (fr->p_seed_2 + INT64_C(1));
    fr->j1 = 0;
    if (fr->p_flag_3) {
        *yslot = p18_persist_precision_int_of_i64(v_y_7);
        fr->resume = 1;
        return p18_persist_precision_SUSPEND;
    resume_1:;
        fr->j1 = INT64_C(0);
    } else {
        fr->j1 = fr->v_x_5;
    }
```

The frame is 40 bytes on the x86-64 host (gcc 13.3): `resume`, `seed`,
`flag`, `x`, `j1`. `x` and `j1` (16 of the 40) are not live across the
suspension; the parameters are dead after their last read but stay because
the frame is also the calling convention. `y` stays a C local (its last
read precedes the yield) -- the rule works where line order and paths
agree [measurement].

Elsewhere the corpus agrees with the paths [probe]: p07's `worker` keeps
exactly `kept` (`dead` is read by the yield, `after` made after it; frame
24 bytes, storage 72); p08's counter keeps the fold's counter, bound and
intermediate (`hi2`, `acc3`, `i4`; frame 48, each of two storages 96); p10's
generator keeps `hi2` and `i3` (frame 32, storage 64).

### Nested yielding calls share storage

p09 calls the yielding `inner` twice in sequence from the yielding `outer`
[probe]:

```c
typedef struct p09_nested_yield_2_outer_frame {
    unsigned char resume;
    int64_t p_seed_7;
    int64_t v_first_8;
    union {
        p09_nested_yield_3_inner_frame c1;
        p09_nested_yield_3_inner_frame c2;
    } sub;
} p09_nested_yield_2_outer_frame;
```

The two calls never coexist, so their frames are one union -- an
interference-free overlay the backend derives from the structure of calls
(one yielding call in progress at a time), not from a liveness analysis
[inspection]. `first` survives the second call's suspensions and is a field.

### Construction sites and affine handles

* **One slot per site.** A construction executed again reuses its site's
  storage; the previous coroutine of the site is unreachable, because no
  state carried across iterations may hold a handle in the C subset
  (AFFINE-FOLD-UNSUPPORTED, no compiled collections, no `break` values)
  (C-COROUTINE-FRAMES-MILESTONE-1.md, section 14) [inspection].
* **Ownership is not storage.** A handle is an affine pointer to the
  storage; a move copies the pointer; no storage object is ever assigned
  from another. One frame per coroutine wherever its pointers go
  [inspection].
* **Why a constructed handle may not be returned (p10b).** Storage is an
  object of the constructing function's frame, which ends when it returns;
  the C backend refuses a constructing function whose result type is
  affine [probe: C UNSUPPORTED]. Natively the same program allocates a
  `CoroutineObj`, a closure and a List and keeps its own stack [probe].
* **Caller-provided storage** would need [inference]: the callee's
  construction storage type known at the call (an exact call to a closed
  instance), a return-slot parameter through which the caller passes it,
  and, for every call path to the construction, the same static type -- so
  a call through a function value cannot provide it unless the callable
  contract carries a storage requirement.
* **Abandonment.** In C a dropped suspended coroutine needs no code: frames
  own no resources (resources are C UNSUPPORTED). Natively release returns
  the stack to the pool and the collector sweeps the object; a program with
  resources unwinds a suspended coroutine (`coroutine#abandon`)
  [inspection].

### Could one backend-independent liveness serve frames and scratch?

[inference, design] Yes, if it is defined on HIR with operand order, and
it must be more than binding liveness:

* **Gained:** a per-suspension live set before any backend (frame sizes in a
  storage plan, p18's 16 bytes recovered by path sensitivity); the same
  intervals for scratch planning (section 8); a checkable fact (C's
  `Persist` must keep a superset of it; native fusion's NIR liveness must
  agree on the variables it maps).
* **Required:** pending operands across a yielding call (`a + inner()`
  keeps `a`), loop-carried values (a fold's counter, bound and
  intermediate, which p08 shows), handler bindings, and the protocol's
  message slot -- the walk `hir::mutvec::NoLaterUse` already performs for
  places (operand order, branches, handlers, later iterations) is the
  closest existing machinery.
* **Lost or unaffected:** lowering temporaries (`j1`, `st2`, `msg1`) stay
  the C backend's decision; it would keep `Persist` as the realization and
  check it against the HIR fact. Native fusion keeps NIR liveness.
  Moving `Persist` itself into HIR would not be desirable: what it decides
  is C's variables.

## 6. Actor execution and message-storage analysis

Read from `stdlib/actor.bot`, `stdlib/event_loop.bot`,
`stdlib/event_loop/deterministic.bot`, `stdlib/thread.bot`,
`native/src/runtime/thread.rs` and the scenario programs of
`tests/actor/` by a background survey; the claims used below were checked
against the source [inspection] and measured [measurement].

### What an actor is

* **An actor is one ordinary coroutine** of the protocol
  `Coroutine{args: [Answer], return: Exit, errors: [...]}` (the type of
  `Spawned.step`, `stdlib/actor.bot:146-148`). Its private state is its locals and fold
  intermediates (`tests/actor/actors.bot`'s counter keeps a `Count` fold
  intermediate).
* **`start` adds a host**: a second coroutine, `host(step, first, me, mg)`
  (`stdlib/actor.bot:806-835`), which owns the actor's handle and is
  adopted into the loop. So natively every actor is two coroutines, two
  8 MiB stacks unless fused; adoption into the loop's vectors is an affine
  move, which fusion's "handle never leaves the constructing function"
  excludes [inspection].
* **One request in flight.** The host serves one request at a time; while
  the actor is suspended mid-message (a `sleep`), the host waits on that
  request's registration and takes no other message; other actors proceed;
  senders still enqueue (`stdlib/actor.bot:775-833`; test
  `actor-probe-a-suspended-handler`) [inspection].
* **Several frames per actor can coexist**: the actor's, the host's, and
  any child coroutines the actor constructs and resumes [inspection; the
  survey ran a child forwarding requests on interp].
* **Ending.** Return or failure: the host retires the actor (closes its
  mailboxes, counts queued messages as undelivered). Abandonment: shutdown
  releases the host without running it; `reap` closes the mailboxes of
  actors whose task is gone (`stdlib/actor.bot:675-688`, `:874-900`)
  [inspection].

### Mailboxes and messages

* **Capacity is per mailbox, a run-time argument**, clamped to at least 1,
  with no default and no upper bound (`open_checked`,
  `stdlib/actor.bot:387-393`). Each mailbox has two event-loop channels
  (wake and room, Reliable, capacity 1) [inspection].
* **Messages are `any`** in one VM-wide pool shared by all mailboxes:
  `payloads: MutableVector[any]` and `links: MutableVector[int]` with a free
  list; a mailbox is a linked FIFO through it; `take` overwrites the slot
  with 0 and frees the node (`stdlib/actor.bot:541-553`) [inspection]. Pool
  nodes and rows are reused (free lists): the event-loop and mailbox tables
  allocate nothing per message once warm [measurement: no table site in the
  marginal allocations].
* **A send is a logical copy**: an immutable value is shared by reference;
  a mutable collection is shared copy-on-write by the sender's ordinary
  copy convention (the survey found the `mutable_vector#share` at the send
  site in HIR). The message's static type is recovered by
  `std::actor::recover[M]`, the identity, after the slot and generation are
  checked [inspection].
* **Full**: `send` answers `Full` (a value of the API) and drops nothing;
  `deliver` waits for room, first come first served [inspection].

### What a message costs, measured

p12, a client and a server exchanging N request/reply pairs [measurement]:

* **12 allocations and 718 bytes per round trip** at the margin (N = 1000 to
  10000): per round trip, the application's own `Req` and `Resp` structs, a
  `to_string` and a constructed String, and the library's protocol structs
  -- `Exit` from `request` (`stdlib/actor.bot:282`), the message-carrying
  `Answer` from `take` (`:553`) and the status `Answer` (`:556`). At
  N = 200: 805 `Exit`s, 400 message `Answer`s and 405 status `Answer`s, of
  the 2561 allocations. `Exit` and `Answer` carry `payload: any` and cross
  every yield and resume, so they are materialized.
* **Reachable peak 66 objects at every N**, but its bytes grow (5,117 at N = 1
  to 267,233 at N = 10000): the deterministic test driver appends every
  wait's deadline to `waits` (`stdlib/event_loop/deterministic.bot:257`), a
  log its tests read back. A simulation driver's log, not the actor
  library's: a steady-state configuration would have to exclude it.
* 3.3 microseconds per round trip natively (best of 5, N = 10000).

The scheduler's own claim, "Nothing is allocated per dispatch"
(`stdlib/event_loop.bot:38-43`, test `el-alloc-per-event`), holds in this
measurement [measurement].

### Threads

A thread entry runs in a VM made on its own thread (`runtime/thread.rs:
410-439`), with its own heap, statics and context area, a 64 MiB stack by
default (`stdlib/thread.bot:154-156`), at most 64 guarded threads per
process. Values cross as `std::transfer` bytes: the sender encodes, the
transport copies into an owned `Vec`, the receiver copies it into new Bytes
and decodes with its own constructors (`thread.rs:1259`, `:1332`) -- nothing
of one heap is reachable from another [inspection].

### Language guarantees and library details

| | status |
|---|---|
| affinity of `Inbox` and `Thread`, opacity of `Exit`/`Answer`/`Address`, no affine message (COROUTINE-CONTRACT), restricted injection (CONTEXT-NOT-INJECTED, CONTEXT-RETAINED-AUTHORITY), Sendable, thread-entry rules | compiler-enforced: generic features applied to library types |
| one host and two coroutines per actor, one request in flight, one message per dispatch, the pool layout, FIFO order, capacity clamping, retire and reap, the Reliable channels | library implementation (ordinary Botlish), pinned by tests and mutants, not by the compiler |
| `std::actor::recover` | the one compiler-side item (`core/actor.tcl:31-38`, lowered as `same`) |

### What an actor-specific storage configuration could control

[inference, design] Without changing actor semantics:

| knob | derivable by the compiler? | today |
|---|---|---|
| reserved persistent state (the actor coroutine's frame) | in the C subset, yes (frame types); natively no (stackful) | 8 MiB stack per coroutine, per-process `BOTLISH_NATIVE_COROUTINE_STACK_BYTES` |
| per-message scratch | only with storage-lifetime facts (section 18) | none |
| retained messages | no: a run-time capacity | `open[M](capacity)` per mailbox |
| coroutine frames (actor, host, children) | for non-recursive, environment-free chains, yes | heap object and stack each |
| outstanding operations (loop registrations) | no | unbounded tables, generation-checked reuse |
| placement, fallback, exhaustion policy | no: policy | none |

Most of these need no independent user limit: frame layouts are derivable,
and mailbox capacities are already explicit. What is left for configuration
is policy (where, what on exhaustion) and the bounds no analysis can find
(how many requests, how long a String) [inference].

## 7. Context and actor-configuration integration

### The mechanisms that exist

| mechanism | scope | how it is decided |
|---|---|---|
| context installation | one value per context type per program (per VM for a thread entry), from its `with context` line on (`hir/contexts.tcl:43-50`) | statically, at the entry's top level |
| context requirements | per block, transitive over exact call edges (`hir::contexts::Requirements`) | statically |
| injection | per inject block | a static proof (RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md) |
| actor authority | what the construction's inject block had | static |
| execution configuration | per executable (`-native-startup`), per thread (`start_sized`'s stack), per process (coroutine stack size, `BOTLISH_NATIVE_GC_MIN`) | build flags, run-time arguments, environment |
| target configuration | per compilation (`-target`, `core/cabi.tcl`'s table) | static |
| runtime resource configuration | per mailbox (`open` capacity), per loop (`create` budget), per VM (`Threads` limit) | run-time arguments |

### Where storage policy belongs

[inference] Contexts say *which capabilities and implementations* code may
use: they are values, installed once per VM, passed to exactly the
functions whose requirement names them (C-CONTEXTS-FREESTANDING-
MILESTONE-1.md, section 10: a function's C signature is its authority).
A storage policy is not called and is not a value: it constrains where the
execution state of some code may live. Two consequences follow:

* **A policy cannot be a context**: every actor of a VM shares the one
  installed value of a context type, so a per-actor policy written as a
  context would be one policy for all of them. A context *can* be an
  allocator (alternative A, section 16), but that is an explicit API, not a
  policy the compiler realizes.
* **They compose**: a request actor constructed under `inject context Clock,
  Network:` keeps exactly that authority, whatever storage policy governs
  its frames; storage placement adds no authority (a region pointer reaches
  no context).

### Can storage requirements be associated with owners like context requirements?

[inference] Partly, by a different algebra:

* context requirements compose by **union** over call edges (a callee's
  needs are its callers');
* storage composes like a stack: **sum** along a call chain, **max** over
  sequential calls, **sum** over concurrently live constructions -- which
  is exactly what the C frame layout already does for yielding chains (a
  frame holds its callees' frames in a union) and what C's own stack does
  for non-yielding calls.

It breaks where the call graph is open: recursion (C refuses recursive
yielding chains as unbounded storage), calls through function values (no
static target), and run-time-sized values. Specialization multiplies the
nodes but closes the graph (every instance has exact calls).

### Alternatives, without syntax

| alternative | anchor | strength | weakness |
|---|---|---|---|
| a storage context (an allocator value passed as a context) | the call graph | uses existing machinery; explicit | it is alternative A: the application manages reset points; one per VM |
| a declaration on a thread entry | the VM | the strongest isolation already exists (own heap, own thread); policy per VM | coarse: every actor of the VM shares it |
| a parameter of a coroutine construction or adoption | the construction site | per actor (an actor is a construction); C already sizes storage per site | the host coroutine and children are separate sites; adoption is library code |
| a compilation or target configuration | the program | no source change; natural for C targets ("no general heap") | one policy for the whole program |
| a type-level effect ("allocates") | every function | precise diagnostics | a new effect system; the brief excludes it for this census |

## 8. Storage interference and reuse opportunities

### By probe shape

| probe | shape | candidate reuse | safety condition | fact today |
|---|---|---|---|---|
| p01 | two sequential temporaries | `a` and `b` share one slot | `a`'s identity dies before `b` is made; the concat results die at `length` | none: Strings are not escape candidates; 4 allocations per call |
| p02 | two simultaneous | none between `a` and `b`; both reusable after the concat | both dead after the concat | none |
| p03 | exclusive branches | the two branch Strings share a slot | only one branch runs; the join result dies at `length` | construction plans already avoid the intermediate String in each branch, but still allocate a plan object (1000 StringPlans) |
| p04 | per-iteration temporary | one slot for 1000 iterations | `t` dies within the iteration | the struct `Pair` is scalar-replaced (0 Structs); the String is not (1000) |
| p05 | escape through a result | `make`'s scratch cannot hold its result; `use_it`'s can | the result is owned by the caller until the caller's last use | none crosses the call |
| p06 | retained in an aggregate | none | elements live until the vector dies | reachable peak 1001 objects: correctly retained |
| p07, p07b | across a suspension | `kept` in the frame; `gone` and the consumer's `noise` in scratch | `kept` survives every interleaving until resumed; `gone` dies before the yield | C: `Persist` keeps exactly `kept` (p07); natively the String lives on the coroutine's stack or in the consumer's registers (fused) |
| p08 | two independent frames | none between them | both live until released | C: two storage objects, one per construction site |
| p09 | nested yielding calls | the two `inner` frames | sequential calls never coexist | C: a union (two members, one storage) |
| p10, p10b | handle moved; handle returned | none (the frame is persistent) | storage must outlive every holder | C: fixed storage when moved down; refused when returned |
| p11, p19 | context-owned state | the backing across requests | unique backing; capacity kept by `clear` | runtime behavior of `clear` (p19: 4 growths for 32,000 pushes) |
| p12 | actor messages | per-message protocol structs | each `Exit`/`Answer` dies at the next resume | none: they cross the coroutine boundary |
| p13 | request handler | every per-request String and the `Request` struct | all die before the next request | none (9 allocations per request) |
| p14 | errors and early exits | `s`, `t` | free again on the `fail` path (the payload is a fresh Int) and the early `return` | exits are enumerated for affine values only |
| p15 | bounded vs unbounded Lists | the `fixed` List's 8 slots | exact length 8 is declared | the length is knowledge, not representation: each call still builds an empty List, a growable plan and the result |
| p17 | spelling | the result struct in registers | either spelling | recognized for one spelling only |

### Models compared

[inference, evaluated against the shapes above]

* **Interference graph** (register-allocation style): exact for fixed-size
  slots of known lifetimes; the C compiler already does this for C
  automatic values. For heap values of run-time size it needs sizes, which
  text lacks; and it would be per instance, with unknown cross-call
  pressure.
* **Intervals**: natural over Botlish's structured sequences; equivalent to
  the graph for straight-line code; loops and handlers need iteration and
  handler-entry edges, which `NoLaterUse` already models.
* **Region/scope-based reuse** (a region reset at the end of an activation,
  a loop iteration or a request): fits every steady-state shape above
  (p01, p03, p04, p13, p14) without sizes -- a region grows dynamically and
  resets -- and uses the exit enumeration `ExitReleases` already performs.
  It fails for values that leave the region (p05, p06, p12), which must be
  proven not to (G5).
* **Coroutine-state overlays**: exist in C (unions of sequential calls,
  `Persist`); they handle suspension but only for fixed-size values.
* **Actor execution phases** (state persistent across messages, scratch per
  message): a region per receive iteration; needs an anchor the compiler
  can see (section 7) and fails today on the protocol structs, which cross
  suspensions.
* **Hybrid** (static slots for fixed-size values, a dynamic region per
  scope for run-time-sized ones, frames for values crossing suspensions):
  covers every shape of the corpus; this is the shape sections 18 and 19
  build toward.

The first goal should be a *provably sufficient* assignment -- a region per
scope that is reset only where nothing in it is reachable -- not a minimal
packing. The measured reachable peaks (section 15) show that the minimal
packing would save little more: a request's reachable storage is a few
hundred bytes.

## 9. Collection and buffer representation

[inspection unless tagged]

* **Strings** are immutable, one block of header and UTF-8 per value.
  `rt_str_cat` always allocates its result (`runtime/ops.rs:2913-2922`), as
  do `to_string`, `substring` and `append_char`. There is no interning and
  no reuse beyond the one static empty String. Construction plans
  (`hir/construction.tcl`, `runtime/construct.rs`) replace a chain of
  concatenations by one growable plan object and one final copy; p13's
  responses are built so (600 materializations, 2400 pieces for 200
  requests) [probe]. Short strings live in registers only where a value
  never becomes a Botlish value.
* **Lists** are a header and a boxed slice; `rt_list_append` copies the
  whole list (`runtime/ops.rs:3305-3317`). A literal or recognized
  construction may be virtual (all-or-nothing). A List with a declared
  exact length is built like any other (p15) [probe].
* **MutableVector and MutableArray** are headers over `Rc` backings,
  mutated in place while unique. `clear` of a unique backing keeps its
  capacity (`runtime/mutvec.rs:219-226`): **p19's context-owned vector,
  cleared and refilled by 1000 requests of 32 elements, grew 4 times (256
  bytes) during the first request and never again; the run made 5 heap
  objects in all, at installation** [probe, measurement]. Growth is
  geometric (p15's `grow`: 9 growths for 1001 pushes) and counted outside
  the managed-heap figures (`mutableVector growthBytes`).
* **Maps and sets** are ordinary Botlish over MutableVectors
  (ORDERED-MUTABLE-MAP-SET.md).
* **Structs** are virtual where escape.tcl proves identity unobserved,
  otherwise one object; Float64 values and payload-bearing enum cases are
  always boxed.
* **Bytes and MutableBytes**: a write produces a fresh storage
  (MUTABLE-BYTES.md); `std::transfer::encode` builds Bytes.

### Could a compiler-managed region hold their backing?

[inference] Without changing value semantics, yes for a value whose
identity never leaves the region, because Botlish values have no identity
semantics: equality and hashing read contents, never addresses
(REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md). The obligations:

* **Shared immutable values**: an immutable binding does not make its
  backing private -- `kept = make(i)` in p05 is the same object `make`
  built. Storage reuse needs a confinement proof for the *object*, not for
  the binding.
* **Copy-on-write**: a mutable backing in a region must not be shared with a
  value outside it (a share is an `Rc` clone).
* **Growth**: a value that grows (a plan, a vector backing) cannot sit in a
  fixed slot unless its bound is known; a region must grow or fall back.
* **Values escaping into actor state, messages, contexts or other VMs** keep
  heap storage (messages are shared by reference within a VM; across VMs
  they are copied anyway).

Size categories of the corpus's values: exact (structs of scalars, coroutine
frames, `List[int]{length: 8}`), bounded but unstated (`to_string` of a
ranged Int, p01-p04, p13), run-time (p15's `dynamic`, any input text).

## 10. Capacity and boundedness analysis

[inspection]

| bound | exists? | crosses functions | note |
|---|---|---|---|
| integer ranges | yes (`hir/range.tcl`) | per instance | drives unboxing |
| exact List length | yes (`List[T]{length: N}`) | only as a declaration (`ForgetInferred`) | changes no representation (p15) |
| collecting-loop cardinality | yes (`hir/cardinality.tcl`) | locally | a `break` weakens exact to at most |
| MutableVector length | yes, while nothing resizes the copy chain | no | context members always fresh atoms |
| loop iteration count | for counted loops (ranges of their bounds) | -- | `loop:` is unbounded |
| recursion depth | **no** | -- | deliberately not a language limit (NATIVE LIMIT STACK, AGENTS.md "Depth-safe recursion" for the front end); C refuses only recursive *yielding* chains |
| live coroutine frames | C: one per construction site | -- | natively unbounded |
| retained messages | per mailbox, a run-time capacity | -- | the pool is shared and grows |
| outstanding operations | **no** | -- | registration tables grow, rows reused |
| String length | **no** | -- | |

The five categories, with corpus examples [inference]:

1. **statically sized**: structs of scalars, C frames (p07-p10);
2. **statically bounded**: a `to_string` of a ranged Int (p01's operands are
   below 2000 -- the bound exists in the range analysis, but no analysis
   turns it into a byte count), a declared List length;
3. **configuration bounded**: mailbox capacity, `open[M](4)`, already
   explicit;
4. **dynamically bounded**: the C Int provider's arena (`BOTLISH_RT_INT_
   ARENA_LIMBS`), a mailbox's `Full`;
5. **unbounded or unknown**: input text, recursion, loop registrations.

### Exhaustion

Existing behavior is consistent across backends [inspection]: running out
of storage is outside the language's semantics. The C runtime-service
contract turns a provider's `BOTLISH_RT_V1_LIMIT` into the terminal status
`C RUNTIME LIMIT`, "which no Botlish handler catches"
(`ccompile/botlish_rt_v1.h:28-35`; `ccompile/ccompile.tcl:769`;
Compilerpedia `error.c-runtime-limit`); natively a stack overflow is the
terminal `NATIVE LIMIT STACK`. The one recoverable capacity outcome, an
actor mailbox's `Full`, is a value the API declares.

So a bounded-storage configuration may [inference]: reject a program at
compile time (a diagnostic naming the unbounded requirement), fall back to
the general heap (no observable difference), end the run with a terminal
limit (as `C RUNTIME LIMIT` does), or use a capacity result an API already
declares. It may not invent a recoverable Botlish error that existing
signatures do not admit: a function's `errors` clause is its contract.

## 11. Suspension and asynchronous-operation lifetimes

[inspection, probe]

| a coroutine suspends while... | today |
|---|---|
| waiting for an external response | the event loop holds its registration; the coroutine's frame (C) or stack (native) holds everything live |
| holding partially constructed data | a plan or a value is a local of the suspended frame or stack (p07b's `kept`) |
| owning a message | an ordinary value in the frame |
| retaining a pointer into scratch | impossible: no pointer to Botlish storage exists outside one foreign call |
| waiting for another actor | as for an external response (a mailbox's wake channel) |
| an asynchronous write still uses its buffer | **not expressible** for Botlish storage |

The asynchronous case, precisely: a byte buffer is lent to C only for one
synchronous call whose contract says noescape (`hir/borrow.tcl:127-158`;
p16 runs `write(2)` that way, the Bytes exposed in place). A parameter that
may retain the pointer refuses Botlish storage (p16b, FOREIGN-BORROW: "a
pointer C keeps after the call needs storage that outlives the call, which
nothing provides yet"). C-owned memory is an affine `Ptr` the compiler never
releases (no drop descriptor). The Linux event-loop driver copies four
scalars per record and owns its rings in C (`packages/event_loop_linux/
native/event_loop_linux.c`). The HTTP package's I/O buffers belong to its
Rust unit.

The four contracts the brief lists differ as follows [inference]:

| contract | expressible today |
|---|---|
| copy synchronously | yes: exposure during the call, the driver's copies |
| borrow until completion | no |
| take ownership (and give back at completion) | for C-owned memory, as an affine value or an opaque resource; Botlish byte storage is a value (MutableBytes exposure is a private copy), not an owned buffer |
| transfer to another component | across VMs as transfer bytes (copied) |

The storage planner cannot take a call's return or a suspension as the end
of an external claim; today it never has to, because no external claim on
Botlish storage exists. **The smallest missing distinction** [inference]:
a lifetime that ends at an operation's *completion* -- neither a call's
return nor a scope's end -- for Botlish-owned byte storage. The language
has the parts (affine tokens, resources released at scope end,
generation-checked event-loop registrations, a non-moving native heap in
which pinning is free); it lacks a way for byte storage to be the payload
of such a token without a copy. Designing it is a language decision
(section 20).

## 12. Placement mechanisms by backend

[inspection; implementability is inference]

**Native.** Cranelift stack slots exist for argument arrays, scratch and
multi-result slots, never for a heap-kind object (`codegen/clif.rs`; NIR has
no stack-allocation instruction). The collector is non-moving and
precisely rooted, so an object outside `Heap::objects` is possible: marking
would set its header bits, sweeping would ignore it. What a region needs:
no live root into it when it resets (the proof obligation), its outgoing
pointers traced while it is live (or none), and the collector told nothing
else. Per-VM heaps already isolate threads; a region per VM, per coroutine
construction or per scope fits that structure.

**C.** Automatic storage (today, every value), frame fields (today),
caller-provided storage (C-COROUTINE-FRAMES-MILESTONE-1.md's recommended
next step), static duration (deliberately absent: no writable file-scope
object except top-level values, which make a run non-reentrant). Linker
sections and physical regions are outside portable C11 (`-pedantic-errors`
admits no section attribute): an embedding places the storage objects the
manifest names, the compiler describes them.

**Interpreter and Tcl compiler.** No control of storage (Tcl objects). They
can *check* a contract -- for instance poison a region's values at its
reset and fail on a later use -- but cannot offer a performance guarantee.
The same source configuration keeps its semantics there.

| strategy | compiler facts needed | target assumption | reentrancy / threads | build obligation | runtime service | implementable now |
|---|---|---|---|---|---|---|
| C automatic storage | fixed types | a C stack | per call | none | none | C (all values it compiles) |
| frame fields / union overlays | per-suspension liveness | none | per construction | none | none | C |
| caller-provided frames | static storage type of the callee's construction | none | per caller | none | none | C, after a milestone |
| per-scope dynamic region | identity confinement, every exit | memory for a region | per activation | none | region allocator | native, after a milestone |
| actor/VM-owned reserved memory | an owner anchor, bounds or fallback | reservation size | per VM | none | yes | native (per VM) |
| static `.bss` storage | exact sizes, no reentrancy | single instance | not reentrant | none | none | C (excluded today on purpose) |
| linker sections, physical regions | exact sizes | the embedding's memory map | per image | linker script | none | via the embedding only |

## 13. Potential storage-plan and accounting artifacts

The C backend's `coroutine_frames` manifest member (types, roles, `holds`,
`suspension_values`) and `examples/c-freestanding/frame-sizes.sh` (each
type's `sizeof` and `_Alignof` as a target's own compiler lays it out) are
the model to extend [inspection]: the compiler names types and relations,
a toolchain supplies bytes. The C milestone's measured kiosk -- 232 bytes for
a session's three coroutines on 64-bit targets, 145 on AVR -- is one
compiler's layout, not a property of the program.

The minimum a future storage plan needs [design]:

* **per execution owner** (a program run, a thread entry, a construction
  site): its persistent items (frames, context state) by type, and how many
  can coexist (one per site; a mailbox capacity; unbounded);
* **per region** (an activation, a loop iteration, a request): the items it
  holds, each with its size class (exact, bounded with the source of the
  bound, configuration-bounded, dynamic, unknown);
* **overlap groups** (union members, sequential scopes) with the fact that
  justifies each;
* **external obligations**: runtime services and their storage (the Int
  provider), C-owned memory, a target's toolchain functions;
* **whether general-heap allocation remains possible**, and at which sites;
* **the status of each figure**: proven, assumed by configuration,
  conservative, measured on a toolchain, unsupported.

Emitted first in units of types and counts by the compiler, completed with
bytes by a backend or a target's toolchain -- never architecture-independent
byte sizes for native layouts.

## 14. Probe corpus and reproducibility

`audit/storage-static-reuse/` (its README has the commands). Twenty-two
programs (`p01` .. `p19`, with three variants) in today's syntax:

| case | question |
|---|---|
| p01-sequential-temps | two bounded temporaries one after the other |
| p02-simultaneous-temps | two temporaries live at once |
| p03-exclusive-branches | mutually exclusive branches |
| p04-loop-reuse | a temporary per loop iteration, beside a scalar-replaced struct |
| p05-escape-result | a temporary escaping through a result |
| p06-retained-aggregate | temporaries retained in a MutableVector and a struct |
| p07-across-suspension | Int values around a suspension (C-compilable) |
| p07b-string-across-suspension | a String kept across a suspension, another dropped before it |
| p08-two-coroutines | two independently suspended coroutines of one function |
| p09-nested-yield | nested yielding calls (deep yields) |
| p10-handle-moved | a handle moved through a function |
| p10b-handle-returned | a function returning a handle it constructed |
| p11-context-state | context-owned mutable state |
| p12-actor-messages | actor messages and their ownership |
| p13-request-handler | parse, transform, respond, N times |
| p14-errors-early-exit | declared errors and early returns |
| p15-bounded-collections | a declared-length List, a run-time-length List, a growing vector |
| p16-foreign-noescape, p16b-foreign-captures | byte storage lent to C; C retaining it (refused) |
| p17-explicit-return | the same function in two spellings |
| p18-persist-precision | `Persist`'s line-order approximation |
| p19-context-scratch-vector | a context-owned vector cleared per request |

`tools/probe.tcl` records, per case, the outcome on interp, compile,
cranelift and cranelift-unfused; the HIR facts (blocks that may yield, the
affine release and exit tables); the native struct census; the native
allocation report (summary, per site with source location, and the
reachable peak under GC stress); and the C backend's result with its
frames and host sizes. Summary (`results/probes.md`) [probe, measurement]:

| case | backends | native allocations; reachable peak | C |
|---|---|---|---|
| p01 | agree | 4000 / 116,670 B; 2 / 60 B | UNSUPPORTED (String) |
| p02 | agree | 3000 / 91,670 B; 3 / 93 B | UNSUPPORTED |
| p03 | agree | 3000 / 175,170 B; 2 / 163 B | UNSUPPORTED |
| p04 | agree | 1000 / 28,445 B; 1 / 29 B | UNSUPPORTED |
| p05 | agree | 4000 / 121,566 B; 3 / 96 B | UNSUPPORTED |
| p06 | agree | 1003 / 27,986 B; 1001 / 36,098 B | UNSUPPORTED |
| p07 | agree | fused 1 / 48 B; unfused 3 / 184 B | frame keeps `kept`; storage 72 B |
| p07b | agree | fused 5000 / 150,400 B, peak 3; unfused 7000 / 294,400 B, peak 5 | UNSUPPORTED |
| p08 | agree | fused 1; unfused 7 | two storages of 96 B |
| p09 | agree | fused 1; unfused 2 | union of two `inner` frames; storage 72 B |
| p10 | agree | 2 | storage 64 B |
| p10b | agree | 3 | UNSUPPORTED (returned handle) |
| p11 | agree | 5 (installation only) | UNSUPPORTED (MutableVector field) |
| p12 | agree | 2561 / 149,650 B; 66 / 9,183 B | UNSUPPORTED |
| p13 | agree | 1800 / 81,885 B; 6 / 309 B | UNSUPPORTED |
| p14 | agree | 3666 / 110,912 B; 2 / 64 B | UNSUPPORTED |
| p15 | agree | 1195 / 99,712 B; 2 / 968 B | UNSUPPORTED |
| p16 | Tcl: NATIVE-ONLY (expected); native: 10 | -- (a linked run's counters start after its VM is built: `runtime/aot.rs:441-444`) | UNSUPPORTED |
| p16b | FOREIGN-BORROW | -- | -- |
| p17 | agree | 1001: 1000 Structs from `explicit`, 0 from `bare` | compiles both |
| p18 | agree | fused 1 | frame keeps `x` and `j1` needlessly (40 B) |
| p19 | agree | 5; 4 backing growths in all | UNSUPPORTED (MutableVector field) |

**Scenarios the language cannot express** (documented, not approximated)
[inspection]:

* a Botlish buffer borrowed by an asynchronous operation (p16b's refusal);
* a request scope (no construct marks a request's completion);
* a per-actor configuration (no compiler-visible actor);
* a String length bound (no refinement);
* a typed empty MutableVector: the probes write `from_list([0])` and
  `clear` (the 2048 workload's recorded workaround).

## 15. Measurements and limitations

`tools/measure.tcl`, four workloads at N = 1, 10, 100, 1000, 10000
(`results/measurements.md`) [measurement]:

| workload | marginal allocations / bytes per unit | reachable peak (GC stress), N = 1 .. 10000 | collections at N = 10000 (time in the instrumented run) | best time per unit (N = 10000, best of 5) |
|---|---|---|---|---|
| request (p13) | 9.00 / 422.7 | 6 objects, 299 .. 316 B | 4 (1.4 ms) | 0.502 us |
| actor round trip (p12) | 12.00 / 718.1 | 66 objects, 5.1 .. 267 KB (the test driver's log) | 7 (3.4 ms) | 3.316 us |
| sequential temporaries (p01) | 4.00 / 121.1 | 2 objects, 54 .. 62 B | 1 (0.5 ms) | 0.141 us |
| suspended String, fused (p07b) | 5.00 / 156.0 | 3 objects, 83 .. 93 B | 1 (0.5 ms) | 0.182 us |
| suspended String, unfused (p07b) | 7.00 / 300.0 | 5 objects, 227 .. 237 B | 158 (1.1 ms) | 0.446 us |

What the numbers are and are not:

* **Measured:** managed-heap allocation counts and registered bytes per run,
  collections and their time inside an instrumented run, the reachable peak
  under GC stress, best-of-5 wall times of uninstrumented runs, C type
  sizes on the host (gcc 13.3).
* **Not measured:** allocator (malloc) time separately; BigInt limb
  buffers, Rust `Vec` growth of collection backings (reported apart as
  growth counters), coroutine stacks, JIT memory; a linked (C-calling)
  program's dynamic allocations; anything on another host.
* **The collection times are not a share of the run times**: the
  instrumented run does more work per object than the timed runs. They are
  an upper estimate of what collection costs, not a measurement of it.
* **Estimated, not measured** [inference]: if a request's nine objects were
  placed in a region reset per request, the optimized path would make zero
  managed-heap allocations per request and the four collections at
  N = 10000 would not occur; whether the region's own bookkeeping is cheaper
  than nine allocations is unknown until built.
* Times are of a shared 4-processor container and vary run to run; counts
  do not.

## 16. Design alternatives and tradeoffs

| criterion | A. explicit allocator / arena API | B. compiler-managed, actor-configured | C. region or lifetime types in the language | D. hybrid |
|---|---|---|---|---|
| fit with the language's design (contexts for authority; ownership by affine values, never references) | an API is ordinary, but reset points are manual and unchecked unless typed | strong: the compiler derives facts | weak: the repository's rules exclude reference types, lifetimes and borrow systems without a design of their own (AGENTS.md, "Context-owned affine state" and "MutableVector") | strong where facts exist, explicit only at boundaries |
| application ergonomics | application code manages scopes | none in application code | annotations everywhere | none by default |
| static safety | unsafe without region typing | as safe as the facts | strong | as safe as the facts plus contracts |
| coroutines and actors | arenas cross suspensions unsafely | needs live-across-suspension facts and an owner anchor (missing) | expressible | frames for suspensions, regions for scratch |
| embedded feasibility | yes | yes for fixed-size values (C already); text needs bounds | yes | yes |
| native server performance | yes | yes, where confinement is proven | yes | yes |
| ownership and context semantics | an allocator context is authority, not policy | composes (section 7) | competes with affine ownership | composes |
| compiler complexity | low | high (a new analysis) | very high | medium: one analysis, explicit fallbacks |
| diagnostic quality | poor (runtime faults) | good if refusals name the fact missing | good but noisy | good |
| portability | per backend | backend-independent facts, per-backend placement | yes | yes |
| incremental cost | low | high up front | very high | stepwise |

The evidence favors **D** [inference]:

1. Where Botlish's structure gives the facts -- fixed-size values, frames,
   temporaries confined to a scope -- the compiler can derive storage (C
   already does; native scalar replacement and plans are avoidance of the
   same kind). B works there.
2. Where it cannot -- the length of text, a buffer an external operation
   holds, an actor the compiler does not see -- no analysis will find the
   fact, and B would have to guess or refuse.
3. The language already has explicit, value-semantic reusable storage: a
   context-owned MutableVector cleared per request reuses its backing
   (p19), and affine owned resources model external memory. Those are the
   explicit capabilities a hybrid needs at its boundaries, without a new
   allocator API.
4. Actors are library code; per-actor policy must attach to owners the
   compiler sees (thread entries, construction sites).

The actor should be the **default execution owner, not the exclusive one**:
a thread entry owns its VM's storage, a construction site owns its frame,
and a program run (C) owns everything below `PREFIX_run`.

## 17. Soundness hazard catalogue

| hazard | proof obligation | discharged today by | remaining gap |
|---|---|---|---|
| reuse while an alias is live | no reference to the object outside the region at its reset | affine values: one owner; collections: places and shares | immutable values are shared by reference: no fact (G5) |
| dangling reference after a suspension | everything read after a resume is in the frame | C: `Persist` (conservative); native: the whole stack | no HIR fact (G3) |
| reuse while an asynchronous operation holds the storage | no external claim at reset | FOREIGN-BORROW: no such claim can exist | a future borrow-until-completion must keep it |
| overlapping independently live frames | distinct construction sites distinct storage; a site's previous coroutine unreachable | C: one slot per site, no handle survives an iteration | caller-provided storage must preserve it |
| handle ownership confused with frame ownership | storage outlives every handle | C: a constructing function may not return a handle | moving that rule needs caller-provided storage |
| actor reentrancy, nested message processing | one request in flight per actor | the library's host (one request at a time) | library behavior, not a compiler guarantee |
| mutating a shared immutable value's backing | a region's mutable backing is never shared outside it | copy-on-write (`Rc` count, Tcl refcount) | a region allocator must respect it |
| premature or skipped cleanup | releases at last use and every exit; resources at scope end | `hir::affine` | a region reset is not a release: it must not run cleanups |
| reuse after error propagation | the region is reset on every error edge and exit | affine error edges per error name (`hir/affine.tcl:2311-2365`) | for non-affine values nothing enumerates them |
| recursive or unbounded simultaneous storage | a finite owner graph | C refuses recursive yielding chains | native has no bound by design |
| reentrancy of generated C entry points | no writable static storage | C writes none unless a function reads a top-level value | static placement would end reentrancy |
| hidden allocations in runtime services | every allocation site known | the allocation report's per-site attribution (JIT only) | Float64, BigInt, runtime helpers allocate |
| target alignment and layout differences | sizes from the target's compiler | `frame-sizes.sh`, the manifest | none for native layouts |
| exhaustion changing error semantics | exhaustion terminal or declared | `C RUNTIME LIMIT`, `NATIVE LIMIT STACK`, `Full` | a new policy must choose one of these |
| storage retained through contexts or foreign APIs | context state lives to the run's end; foreign retention refused | CONTEXT-OWNED-AFFINE-STATE rules, FOREIGN-BORROW | a region must never hold context state |

Affine ownership does not solve all of these [inference]: it governs values
of affine types only; it says who may *use* a value, not where its storage
lives (`hir/affine.tcl:71-72`: releases "change resource retention only");
and it is silent on immutable values, which are freely aliased.

## 18. Smallest viable implementation boundary

The brief's default candidate, a compiler-managed scratch milestone, cannot
be built soundly on today's facts: no analysis says that a `to_string`
result never leaves its scope (G5), and the facts that come closest are
representation analyses carrying width policies (G4). So the first step is
a prerequisite [inference]:

### STORAGE-LIFETIME-FACTS-MILESTONE-1 (prerequisite) [design]

* **What:** one backend-independent HIR analysis, per specialization
  instance, computing for every allocating expression whether the identity
  of its value is confined to a region -- the activation, a loop iteration,
  a fold iteration -- and where that region ends on every path (normal end,
  `return`, `fail`, error edges, `break`, `continue`); and, for every
  suspension point, the bindings and pending operands live across it.
* **Why a new analysis:** none of the existing ones can provide it without
  becoming it -- affine liveness is affine-only and statement-granular,
  `NoLaterUse` is place-only, `Linear` is a use count, escape.tcl is a
  candidate-only representation decision with policy. It should reuse
  `NoLaterUse`'s walk (operand order, branches, handlers, later
  iterations), `ExitReleases`' exit enumeration and escape.tcl's use
  classification rather than restate them.
* **What it changes:** nothing generated. It produces a storage plan
  (section 13) and, for C, a per-suspension live set.
* **Acceptance:** the C backend's `Persist` keeps a superset of the live
  set on every C-compiled program (p18 shows a strict superset); native
  runs under GC stress never find reachable an object the analysis called
  dead (an instrumented check); every corpus probe classified as section 8
  predicts; the fact is invariant under spelling (p17); compilation
  isolation, interchange and cache rules (the fact lives in the HIR or is
  recomputed, never process state).

### STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1 (first implementation) [design]

* **Backend: native.** It is the only backend with the run-time-sized values
  the opportunity is about; C has nothing heap-allocated to reuse, and the
  Tcl backends cannot place storage.
* **Values:** String and List temporaries (to_string, concat, substring,
  plan materializations) whose lifetime fact says "confined to this
  activation or loop iteration".
* **Representation:** a per-region bump region owned by the VM, reset at the
  region's end on every exit; objects in it are outside `Heap::objects`
  (marked, never swept); a region that outgrows its reservation falls back
  to the heap for the rest of the region (no new error, no diagnostic
  required). No configuration syntax.
* **Demonstrates:** genuine reuse (p01, p04, p13, p14: zero managed-heap
  allocations per iteration on the optimized path after the first); value
  semantics unchanged on all four backends; GC-stress runs clean; every
  exit (p14) resets; repeated requests make no backing allocation; a
  fallback when confinement fails (p05, p06, p12 keep the heap); the census's
  tools rerun as the before and after comparison.
* **Not in it:** actor configuration, coroutine-crossing values, C, Float64.

Actor-specific configuration does not belong in milestone 1: there is no
compiler-visible actor, and an actor's dominant per-message cost (its
protocol structs) crosses suspensions, which a scope region cannot hold
[inference].

## 19. Recommended milestone sequence

[design]

1. **STORAGE-LIFETIME-FACTS-MILESTONE-1** -- the analysis and the storage
   plan report (section 18).
2. **STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1** -- native scope regions
   for confined String and List temporaries, with heap fallback.
3. **C-BOUNDED-STORAGE-MILESTONE-1** -- caller-provided coroutine storage
   (C-COROUTINE-FRAMES-MILESTONE-1.md, section 23), with milestone 1's
   per-suspension live sets bounding `Persist`.
4. **STORAGE-EXECUTION-OWNER-MILESTONE-1** -- a storage policy per thread
   entry and per construction site (reserved region, fallback or terminal
   exhaustion, a report of every site that still reaches the general heap);
   the first point at which an actor -- a construction site -- gets a
   storage configuration.
5. **A language-design decision** on operation-completion lifetimes for
   byte storage (section 11), before any asynchronous I/O borrows Botlish
   buffers.

Independent of these, a small representation fix: escape.tcl's result
recognition of an explicit trailing `return` (p17) -- a representation
improvement for every backend that reads escape facts, no semantic change.

## 20. Open questions requiring language-design decisions

1. **What is a request?** A region boundary inferred from a loop or fold
   iteration, a handler call, an actor's receive -- or a construct?
2. **Is storage policy source or build configuration?** A declaration at a
   thread entry or construction site, or a target/build option?
3. **Which execution owner carries policy?** Thread entry (VM), construction
   site (frame), program run -- and should `std::actor` expose one?
4. **Exhaustion semantics per configuration:** compile-time refusal, heap
   fallback, terminal limit, or an API's declared capacity result -- and
   may a program choose?
5. **Bounds for text:** a String length refinement (like `List[T]{length:
   N}`), a bounded-text domain, or derived bounds from ranges
   (`to_string` of an Int in 0..9999 is at most 4 characters)?
6. **Asynchronous borrowing:** an affine pending-operation token over byte
   storage, or "external operations always copy or own"?
7. **Confinement as a property:** should some values be confined by type
   (a non-sendable, non-storable scratch String) rather than by analysis?
8. **Recursion under bounded storage:** reject recursion in a bounded
   owner's call graph (as C does for yielding chains), or bound its depth?
9. **Calls through function values:** must callable contracts carry storage
   requirements for bounded owners to call them?
10. **Reentrancy:** per run, per VM, per thread storage for C entry points
    that an embedding may call from an interrupt.

## 21. Files, and how to reproduce

* `audit/storage-static-reuse/cases/*.bot` -- the corpus;
* `audit/storage-static-reuse/tools/probe.tcl` -- per-probe records
  (about 25 minutes on 4 processors);
* `audit/storage-static-reuse/tools/measure.tcl` -- the scaling
  measurements (about 10 minutes);
* `audit/storage-static-reuse/results/` -- the committed results.

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 audit/storage-static-reuse/tools/probe.tcl
tclsh9.0 audit/storage-static-reuse/tools/measure.tcl
tclsh9.0 main.tcl -emit-c -out OUT audit/storage-static-reuse/cases/p18-persist-precision.bot
```

Nothing in `hir/`, `core/`, `surface/`, `compiler/`, `native/`,
`ccompile/`, `stdlib/`, `tests/` or `compilerpedia/` changed.
