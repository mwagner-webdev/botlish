# STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-1 -- compiler-directed reuse of temporary String storage in the native backend

Completion report. The milestone turns the confinement facts of
STORAGE-LIFETIME-FACTS-MILESTONE-1.md into reused memory: the native
backend places confined temporary Strings in compiler-managed scratch
storage instead of the managed heap, and resets that storage at boundaries
the compiler proves. The source program stays ordinary Botlish: no syntax,
no allocator API, no region type.

Evidence tags: **[inspection]** observed in the implementation;
**[test]** asserted by an automated test; **[probe]** observed in a
compiled or executed program; **[measurement]** a measured count, size or
time; **[inference]** a conclusion from evidence; **[design]** intended
future behavior, not implemented.

Commits: the work branches from `d6b0161c` (main, 2026-11-16) on
`claude/gracious-hopper-zg4doz`; the commits are listed in section 24.
Toolchain: x86-64 Linux (Ubuntu 24.04), Tcl 9.0.1, rustc 1.100.0 (the
repository's pin), cranelift-codegen 0.135.2. Every command below runs
from the checkout's root with `LANG=C.utf8 LC_ALL=C.utf8`, after
`cargo build --release --manifest-path native/Cargo.toml`.

## 1. Executive outcome and acceptance status

**[measurement]** The native backend now places confined temporary Strings
in compiler-managed scratch storage. On the census's positive workloads,
at N = 10,000, scratch storage off and on:

| workload | heap allocations off / on | heap bytes off / on | collections off / on | scratch reservations | peak in use | time on/off (best) |
|---|---:|---:|---:|---:|---:|---:|
| p01 sequential temporaries | 40,000 / 0 | 1,206,670 / 0 | 1 / 0 | 1 (16 KiB) | 128 B | 0.47 |
| p04 loop-local temporary | 10,000 / 0 | 294,445 / 0 | 0 / 0 | 1 | 32 B | 1.25 (0.73 in three other runs; section 22) |
| p13 request handler | 90,000 / 10,000 | 4,217,785 / 560,000 | 4 / 0 | 1 | 400 B | 0.56 |
| p14 errors and early exits | 36,666 / 0 | 1,145,912 / 0 | 1 / 0 | 1 | 72 B | 0.61 |
| p05 returned result | 40,000 / 0 | 1,255,568 / 0 | 1 / 0 | 1 | 144 B | 0.53 |
| p12 actor messages (control) | 120,161 / 120,161 | 7,185,650 / 7,185,650 | 7 / 7 | 0 | -- | 1.01 |

p13's remaining heap allocation is its `Request` struct, one per request;
every String of a request is placed. Counting the system allocator too
(section 21): p01, p04 and p05 allocate nothing per unit with scratch
storage, p13 exactly its struct's two blocks, and p14 two blocks per
declared failure that the runtime's failure path allocates with or without
scratch storage -- so "no heap allocation" here means the managed heap. p12 places nothing: every actor unit
suspends (section 18). One 16 KiB chunk is reserved at the first placement
and reused for every later one: no reservation and no growth after the
first region, at every N.

**[test]** Every census program gives the same outcome with and without
scratch storage and on the interpreter, plain and under GC stress with
released storage poisoned, with no root into released storage and no
protocol error (`tests/scratch-storage.test`'s `ss-run-census`; the
positive workloads also on the Tcl compiler, `ss-run-tcl-backends`; 40
tests in all), and 240 generated programs agree on the interpreter, the
Tcl compiler and four native configurations (section 19).
Three defects of the lifetime facts the integration exposed were fixed
in `hir/lifetime.tcl` (section 5).

Acceptance criteria (brief section 25):

| # | criterion | status | where |
|---|---|---|---|
| 1 | a storage-use plan consumes the HIR lifetime facts | met | section 4 |
| 2 | semantic eligibility, representability and policy kept apart | met | sections 4, 15 |
| 3 | a meaningful subset of confined temporary Strings placed natively | met | sections 6, 17 |
| 4 | backing storage genuinely reused | met: one chunk, every later placement in reused bytes | sections 17, 23 |
| 5 | fewer heap allocations on p01 and p04 | met: to zero | section 21 |
| 6 | p13 reduced, remaining sites identified | met: 9 to 1 per request, the `Request` struct | section 17 |
| 7 | sound across nested calls and overlapping values | met | sections 7, 13, 18 |
| 8 | normal, early and exceptional exits | met | section 8 |
| 9 | no premature reuse across suspension | met: suspending units get no region | sections 7, 18 |
| 10 | GC tracing, marking and sweeping correct | met | sections 11, 20 |
| 11 | aggressive GC stress passes | met | section 20 |
| 12 | escaping values, aliases, aggregates, contexts, messages, foreign calls safe | met | section 18 |
| 13 | growth and fallback never invalidate live objects | met | section 10 |
| 14 | backing reservations measured apart from suballocations | met | sections 17, 23 |
| 15 | value, error, ownership and context semantics unchanged | met: no front-end decision changes; outcomes equal | sections 14, 18, 19 |
| 16 | interp, Tcl compiler, unoptimized and optimized native agree | met | sections 18, 19 |
| 17 | independent tests and mutants detect unsafe reuse | met: 25 mutants killed, 240 fuzzed programs in five modes | section 19 |
| 18 | compatible with strict bounded storage and execution owners | met by design: policy and placement are the provider's, regions are the plan's | sections 10, 26 |
| 19 | no backend or language behavior weakened | met | sections 14, 24 |
| 20 | regression and CI checks pass | pending: CI of `1d26dc9b`; local runs pass | section 24 |

## 2. Baseline allocation evidence

**[measurement]** The baseline is rerun at the integration commit, as the
brief asks: `audit/storage-scratch/tools/measure.tcl`'s "off" columns are the
same programs with `-scratch-opt 0`, which compiles exactly as before this
milestone (frames, requests and destinations are emitted only with scratch
storage on). Per unit, between N = 1,000 and 10,000:

| workload | census (STORAGE-STATIC-REUSE-CENSUS-1.md) | rerun, scratch off | rerun, scratch on |
|---|---:|---:|---:|
| p13 request handler | 9.00 allocations, 422.7 bytes | 9.00 allocations, 422.7 bytes | 1.00 allocation, 56.0 bytes |
| p01 sequential temporaries | 4.00 allocations, 121.1 bytes | 4.00 allocations, 121.1 bytes | 0 |
| p04 loop-local temporary | 1 allocation, about 28 bytes | 1.00 allocation, 29.6 bytes | 0 |
| p12 actor round trip | 12.00 allocations, 718.1 bytes | 12.00 allocations, 718.1 bytes | 12.00, 718.1 bytes |

The census's numbers reproduce exactly with scratch storage off. Its
measurement tool (`audit/storage-static-reuse/tools/measure.tcl`) is a
record of the census and is not changed; run today it measures the default,
scratch storage on.

## 3. Current native allocation and GC architecture

**[inspection]** What the milestone builds on, unchanged by it:

* The native heap (`native/src/runtime/heap.rs`) holds individually
  allocated objects (system allocator), registered in a list and collected
  by a non-moving mark-and-sweep collector. A collection runs only inside an
  allocation, when the bytes allocated since the last one pass the
  threshold (twice the live bytes after the last collection, at least 1 MB,
  `MIN_THRESHOLD`), or at every allocation under
  `BOTLISH_NATIVE_GC_STRESS=1`.
* Roots are the Vm's statics, constants, context area, pending error and
  payload slots, and the native frames' stack-map slots
  (runtime/framewalk.rs; Windows' unwinder on Windows). Every object is
  found from a root by pointer.
* Strings are flat leaves: `strobj.rs`'s header and UTF-8 text in one
  block (`str_layout`); every String made at run time is allocated by
  `Vm::alloc_str`; the collector never scans a String's text (no String
  holds a reference). Every String-producing helper the
  plan targets (`inttostr`, `strcat`, `construct str flat`, `substr`,
  `substrproven`, `strappendchar`) allocates at most one String, its result,
  through `alloc_str`.
* What already avoids the heap before this milestone: scalar replacement
  of structs (hir/escape.tcl), construction plans that defer and fuse
  String and List construction (M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md),
  substring regions and views, coroutine fusion, and the coroutine-stack
  pool. None of them reuses the storage of a dead object.
* The allocation report (`native::allocationReport`, runtime/metrics.rs)
  counts managed-heap allocations per site and kind; this milestone adds a
  `scratch` section and per-site scratch counters beside it, never inside
  the heap counts.

## 4. Storage-plan architecture

Four parts, each with one job (AGENTS.md, "Compiler-managed scratch
storage"):

| part | file | decides |
|---|---|---|
| lifetime facts | `hir/lifetime.tcl` (milestone 1, three fixes: section 5) | when an object may be observed: per producer, `confined`, `escapes` or `unknown` for its activation, each enclosing iteration and its non-suspending segment |
| storage-use plan | `hir/storageplan.tcl` (new) | which sites are placed, in which region, and why the others are not |
| backend realization | `native/lower.tcl`, "Scratch storage" (new); `nir.rs`, `codegen/clif.rs` | the frames, loop regions, requests and destinations it can represent |
| storage provider | `native/src/runtime/scratch.rs` (new); `heap.rs`, `vm.rs` | where the bytes are, and their reuse |

**[inspection]** `hir::storageplan::plan HIR FACTS SPEC ?-natives NAMES?
?-excluded {UNIT REASON ...}?` takes the facts of `hir::lifetime::analyze`
under the specialization analysis native lowering uses (its units and call
identities are that analysis's instances) and returns, per unit (one
specialization instance), whether it may have regions at all, its regions
(an activation region, a region per iteration of each loop holding a
selected site), whether it takes a destination from its callers, and per
producer the three separate questions:

* *semantic eligibility* -- `confined` when the facts confine the object
  to its innermost region (and to its segment), `result` when it escapes
  its activation only through the unit's value, else `no`;
* *backend representability* -- a String result of one of the natives the
  backend can place (`std::int::to_string`, `std::str::concat`,
  `std::str::substring`, `std::str::append_char`), or a direct call of a
  unit that takes a destination; every other producer (a struct, a List, a
  call through a function value, a native the backend does not place) is
  representable "no", with the reason;
* *policy* -- this milestone's policy selects every eligible,
  representable site; it blocks units that may suspend, units the backend
  excludes (a self tail call reuses its frame) and recursive units (a
  region's mark is a word of every activation's frame: section 15).

`hir::storageplan::report` prints all three per site
(section 15; `audit/storage-scratch/tools/plan.tcl` over the census).

**[inspection]** Determinism: the plan is a function of the HIR, its
facts and the specialization analysis; it is computed on demand while
native lowering runs, stored nowhere, and reads no process state.
**[test]** `ss-plan-deterministic`: two lowerings, with another program
compiled between them, give the same plan, emitted record and NIR.

**[inspection]** Backend independence: the plan names regions
(`activation`, `{iteration LOOP}`, `caller`) and sites by HIR expression; it
reads no NIR, register or helper. The one backend fact it takes is the list
of representable natives (`-natives`) and the excluded units (`-excluded`),
both passed in by native lowering. A C or Wasm backend can call the same
plan with its own list (section 21 of the brief; section 26 here).

## 5. Compiler eligibility decisions

**[inspection]** A site is placed only in its *innermost* region -- its
innermost loop's iteration, else its activation -- and only where the facts
say `confined` to that region and to its non-suspending segment. The
innermost region bounds occupancy: a region holds at most one execution of
each of its sites, and every iteration's objects are released at the next
iteration's start. A site whose object outlives its innermost region is not
placed in an outer one (no object of a loop is held by an enclosing region
until that one ends).

**[inspection]** A unit gets no region at all when it may suspend (its
facts list a suspension point, its own yields or a callee's): no region is
ever live across a suspension, so the scratch stack is balanced at every
coroutine switch (section 7). The segment verdict therefore equals the
activation verdict wherever a region exists.

**[inspection]** Placing objects for real, and running the analysis on
every natively compiled program, exposed four defects in
`hir/lifetime.tcl`: three unsound facts, each a native use of released
memory under GC stress, and a summary fixpoint that never converged (a
compilation failure). Each is fixed in the analysis, not worked around in
the plan, and pinned by a test that fails without its fix (the fourth was
found by CI after the frame-cost fix, section 24):

| fact | defect | failure observed | fix | test |
|---|---|---|---|---|
| an error a call lets through | the payload of a declared error a callee may fail with (an argument the callee puts in the payload) was not an escape of the caller's unit | tests/error-payloads.test's `ep-gc-stress`: a payload String read after its region was reset | the call's let-through errors get an `error` sink (`perr`), and the callee's error may hold what its arguments reach | `sl-error-let-through` |
| a fresh result's contents | a callee's fresh result (a struct it builds) was taken to hold only objects of its own kind, not the parameter-reaching objects it stores | tests/golden-framework.test: EILSEQ and NATIVE BUG -- a String the caller placed, stored by a callee into the struct it returns, released with the caller's region while the struct lived on | `fresh` results contain what their result-reaching parameters reach (`Add contents`) | `sl-fresh-holds-parameter` |
| recursive reasons | a recursive component's escape reasons grew a step every round (the reason text named the previous round's), so the summaries never reached a fixpoint | tests/event-loop.test: "no summary fixpoint" | a summary keeps the first reasons found (`KeepReasons`) | `sl-recursive-reasons-converge` |
| a fresh part's kinds | a call's fresh part (every object the callee made, nested ones too: it contains itself) kept its result's kind, so a value of another kind was never taken to be it -- the String a callee put in the struct it returns, projected by a function returning `str` (`label(make(i))`), lost its way to the caller's escape | tests-arm64.yml's GC-stress job (traits.test's `trait-future-path-shape`, compilation-isolation.test's `ci-golden-pair`): cranelift-generic placed the kept String in the caller's region, "not a program value" | an object that contains itself has a fixed kind only as a String, whose pieces are Strings (`Solve`'s `nested`) | `sl-fresh-nested-kinds`, `ss-run-fresh-nested` |

**[test]** `tests/storage-lifetime.test`: 67 tests (63 of milestone 1, the
four above), passing. The facts of milestone 1's corpus are otherwise
unchanged, except where the fourth fix corrects them: p12's actor
coroutines and their closures, moved into `std::actor::start` and kept in
the event loop's installed context, escape `main`'s activation (they were
taken as confined; coroutines are never placed), and p13's `respond`
coexists with `raw` (section 19 reruns its oracle).

## 6. Supported and excluded String operations

**[inspection]** Placed (representable), each lowered to helpers that
allocate at most one String, their result:

| native | NIR operations matched | notes |
|---|---|---|
| `std::int::to_string` | `inttostr` | any Int (a BigInt's text too) |
| `std::str::concat` | `strcat`, `construct str flat` | a fused concatenation chain is one `construct`: the chain's inner sites are reported "no instruction of its own" and the outer one is placed |
| `std::str::substring` | `substr`, `substrproven` | a flat copy; a substring region (a view) is no `alloc_str` and is never placed |
| `std::str::append_char` | `strappendchar`, `construct str flat` | |
| a direct call of a unit that takes a destination | `call` (canonical function only) | the callee's result-only sites follow the caller's region (section 13) |

**[inspection]** Not placed, with the plan's reason: every non-String
producer (structs, Lists, MutableVector headers and backings, enum payloads,
closures, coroutines, Bytes), every other String native
(`std::str::lowercase`, `decode_utf8`, `std::list::...` results, ...), a
call through a function value, a construction plan's own `StringPlan`
object (a plan result), a String a companion, region, `fields` or internal
variant builds (those variants have no frame), and every site of a unit
that may suspend or makes a self tail call. **[probe]** A deferred
construction materialized at an `if` join (p03's two branches' concats) has
an instruction whose origin is the join, not either site: not matched, the
String stays on the heap (the plan report says "no instruction of its
own").

**[inspection]** No unnecessary materialization: a request is attached to
the instruction lowering already emits; a virtual or fused String gets
none. **[test]** `ss-run-request-cleared`: a selected helper that returns
an existing String (the canonical empty String, an empty substring)
allocates nothing, and its request does not leak to the next String.

## 7. Region ownership and nesting

**[inspection]** A region is a mark on one per-Vm stack of positions. The
compiler opens and closes regions only in strictly nested pairs:

* A *frame* (an activation region) is opened in the prologue of a unit's
  canonical function (`%m = op scratchmark`) and closed at each of its
  exits.
* A *loop region* is opened after the loop's operands, its accumulator and
  anything hoisted out of its body, immediately before the jump to its head
  (`%l = op scratchmark`), and reset at its head (each iteration starts
  empty) and at its exit.

A callee's frame is above its caller's, an inner loop's region above its
enclosing loop's; a reset to a region's mark releases exactly that region's
objects and those of regions entered above it. **[test]**
`ss-run-inner-region`: a String of an outer loop's region read in every
iteration of an inner loop with its own region stays intact, poisoned and
under GC stress; the mutant that resets an inner loop to its enclosing
loop's mark gives a wrong value (section 19).

**[inspection]** Recursion: a unit in a recursive component of the direct
call graph (calls of exact function values included: the specialization
analysis resolves them) gets no region and takes no destination; its
temporaries keep their heap allocation (`ss-plan-recursive`). This is a
policy of cost, not of soundness: a region's mark is held for the whole
activation, so every activation of a recursion pays a callee-saved register,
16 bytes of its frame once the frame is aligned, and the stack a recursion
needs grows with it (**[measurement]** section 24: a recursion an 8 MiB
stack held about 104,600 deep held about 87,100 with its frame). A
recursion's leftovers would also pile up in the outermost caller's region,
which is why it never took a destination. Regions still nest across a
recursion the call graph does not see -- a call through a function value
held in a struct field: `ss-run-nested`'s `hidden` and `via` frame each
level, each releasing only its own storage, poisoned and under GC stress --
and a non-recursive callee of a recursion opens and closes its region in
each activation.

**[inspection]** Coroutines: a unit that may suspend gets no region, so no
region is open on a coroutine's stack when it yields; a non-suspending unit
called from a coroutine body opens and closes its regions within that call.
The scratch stack is therefore the same before and after every switch, and
a consumer's region survives the coroutines it resumes. **[test]**
`ss-plan-p07b-suspension`, `ss-run-coroutines` (fused and unfused, under GC
stress).

**[inspection]** Threads and Vms: the provider lives in the Vm's heap, one
per Vm; a Vm stays on the thread that made it. **[test]** `ss-run-vms`:
several Vms of one program at once, each on its own thread.

## 8. Normal and exceptional reset semantics

**[inspection]** Every way out of a region resets it:

| exit | what runs |
|---|---|
| a loop iteration's end, `continue` | the reset at the loop's head |
| the loop's exhaustion, `break` | the reset after the loop's exit label |
| `return` (also from inside loops) | the frame's exit before the `ret`: a reset to the frame's mark, below every loop region of the function |
| an error leaving the function (a `fail`, an unhandled call error, a propagated one) | the frame's error exit (`pusherrorexit L` in the prologue; `label L`, `poperrorexit`, the exit, `reraise`) |
| a handled error | handlers attach to calls, so a handled error never leaves the loop iteration or the function that holds the call: the regions stay open and are reset by the ordinary boundaries |

A unit given a destination (section 13) exits with `op scratchexit %m %d`,
which resets unless the destination is set: what it placed then stays in
the caller's region, which the caller resets.

**[inspection]** A frame is kept even for a unit whose only placed sites
are in loops: a loop's exit reset does not run when an error leaves the
loop, and the frame's error exit releases that loop's region. A function
with nothing emitted and no destination gets no frame (its loop marks are
removed too), so its NIR is unchanged.

**[inspection]** Region reset is not cleanup: it runs no Botlish code and
releases only bytes the compiler proved dead; resources keep their own
lexical cleanup (Resources, AGENTS.md), affine values their releases.

**[test]** `ss-run-exits` (break, continue, early return, handled and
propagated failure in a loop region: unchanged outcomes, poisoned and under
GC stress, no occupancy left after the run), `ss-run-error-steady` (a framed
function failing on every other call: the storage in use is the same at
N = 40 and N = 400), `ss-run-census` on p14 (normal, early, declared,
handled and propagated exits).

## 9. Storage provider and backing representation

**[inspection]** `native/src/runtime/scratch.rs`'s `Scratch`, one per Vm
(a field of `Heap`): a list of chunks (system allocations, 16-byte
aligned), a current chunk and position, the bytes below the current chunk
(`base`), and the address bounds of every chunk for the collector's quick
rejection.

* *Mark*: the position as a small Int, `chunk << 32 | offset`; never a
  pointer, so the register or stack slot holding it is nothing to the
  collector.
* *Allocation*: bump the position by the String's block size (`str_layout`,
  a multiple of 8); a block entirely below the chunk's high-water mark is
  counted as `reused`.
* *Reset*: move the position back to a mark; a mark above the position or
  naming no chunk is a protocol error (counted, never acted on).
* *Requests*: `Vm::scratch_request` (set by generated code immediately
  before a selected helper and cleared immediately after it, before the
  error check) is consumed by `alloc_str` for the first String the helper
  allocates; `Vm::scratch_dest` is stored before a call that passes a
  destination, read and cleared by the callee's first instruction
  (`scratchtake`), and cleared by the caller after the call. Both are Vm
  fields at fixed offsets (`VM_SCRATCH_REQUEST_OFFSET`,
  `VM_SCRATCH_DEST_OFFSET`), read and written inline.
* *NIR*: six operations, `scratchtake`, `scratchmark`, `scratchreset`,
  `scratchexit`, `scratchreq`, `scratchdest`. `nir.rs`'s `validate_scratch`
  checks the protocol structurally: `scratchtake` only as a function's first
  instruction, and never in the program function; `scratchreq` only
  immediately before an operation `scratch_request_target` names;
  `scratchdest` only immediately before a call whose callee begins with
  `scratchtake`. **[test]** `ss-nir-validator`; the Rust tests
  `scratch_tests`.

**[inspection]** No user-visible allocator: nothing in the language, the
standard library or a program names any of it. **[inspection]** No hidden
dynamic planning: the provider never decides a placement, a lifetime or a
reset; it stores where the compiler says and resets when the compiler says.

**[inspection]** Initial reservation: none until the first placement; the
first chunk is 16 KiB (`FIRST_CHUNK`), each later one double the current
(or the String's size, if larger). Chunks are kept for reuse until the run
ends (`Vm::reset` releases them all, and a dropped Vm frees them).

## 10. Growth and fallback behavior

**[inspection]** Growth never moves a live object: when the current chunk
cannot hold a block, the position moves to the next chunk -- an existing
one large enough, a larger one in place of a chunk *above* the position
(which holds nothing live), or a new reservation. Chunks below the position
are never replaced. Fallback is to the managed heap, as an ordinary
collected String, counted per reason:

* `fallbackLarge`: a String block larger than `MAX_OBJECT` (64 KiB);
* `fallbackCapacity`: a reservation that would take the Vm's scratch total
  past `MAX_TOTAL` (64 MiB).

`BOTLISH_NATIVE_SCRATCH_CHUNK`, `_MAX_OBJECT` and `_MAX_TOTAL` override the
three sizes (test instruments; no program can name them). **[test]**
`ss-run-growth` (40-byte chunks: many growths, a later region reuses them,
outcome unchanged, also under GC stress), `ss-run-fallback-large`,
`ss-run-fallback-capacity`; the Rust tests
`growth_never_moves_a_live_object`,
`a_too_small_chunk_above_the_position_is_replaced`,
`policy_falls_back_for_large_objects_and_at_the_limit`.

**[design]** A strict bounded mode (no growth, no fallback, an exhaustion
behavior of its own) is a later milestone's: the provider's policy is three
numbers and two fallback paths, all in one place (`Scratch::alloc`,
`reserve_at`), and the compiler's protocol does not depend on them.

## 11. GC marking, tracing, sweeping and root invariants

**[inspection]** The invariants and where they hold:

* *Recognition by address.* The collector's mark loop asks
  `Scratch::contains` before it reads anything an address points at; a
  scratch address is skipped. A scratch String is never marked and never
  swept, and is not in the heap's object list.
* *Nothing to trace.* A placed object is always a flat String (only
  `alloc_str` honors a request), and a String holds no reference. No heap
  object is kept alive by a scratch object.
* *Heap objects pointing into scratch.* A heap object may hold a scratch
  String while both are live (a struct of the same region); the collector
  skips that field. The confinement proof says the holder does not outlive
  the region.
* *Roots.* A register or stack-map slot holding a scratch String is an
  ordinary root slot; the collector skips it. A root into *released*
  scratch storage is counted (`staleRoots`); the confinement proof says
  there is none, and every test and audit run requires 0.
* *Safepoints.* A scratch placement never collects (it is no heap
  allocation), except under GC stress, where it collects first exactly as a
  heap allocation does, so a stress run still collects at every allocation
  point and checks every root live across a placed String operation.
  **[test]** `ss-run-stress-collects`: a stress run collects as often with
  scratch storage as without (p01, p13, p14).

**[test]** The Rust tests
`a_request_places_exactly_the_next_string_and_the_collector_never_touches_it`,
`a_root_into_released_storage_is_counted_and_never_read`,
`a_run_ends_with_its_storage_released`.

## 12. Stale-reference prevention

**[inspection]** Three layers, in order of authority:

1. The proof: a site is placed only where the facts confine its object to
   the region being reset, and the requests and destinations of a region
   are emitted only for its own sites (an instruction matched through a
   use of a binding must run in the site's own innermost region).
2. The protocol: a request is one instruction's (cleared after the helper,
   before the error check); a destination is one call's (taken and cleared
   by the callee's first instruction, cleared by the caller after the
   call); `validate_scratch` rejects any other shape.
3. The instruments: under GC stress and with
   `BOTLISH_NATIVE_SCRATCH_POISON=1`, every reset overwrites the released
   bytes with `0xDB`, so a read of a released String reads garbage (and,
   for a construction, a heap kind the runtime refuses: "NATIVE BUG"), never
   its old text; the collector counts roots into released storage.

**[probe]** The instruments detect a premature reset: each of the two
unsound lifetime facts of section 5, reintroduced, gives a NATIVE BUG or
EILSEQ under poisoning in 8 of 8 generated programs (the fuzzer's positive
control). **[test]** The mutants of section 19 that release a live String
(`plan-any-verdict`, `lower-dest-as-one`, `lower-inner-reset-outer-mark`,
`rt-exit-ignores-dest`, `lifetime-error-let-through`,
`lifetime-fresh-holds-nothing`) are killed by exactly this: a wrong value in
a plain run, a NATIVE BUG or EILSEQ in a poisoned one.

## 13. Cross-function placement findings

**[inspection]** A unit's site that escapes its activation only through the
unit's own value (every escape reason `result`), at no loop of the unit,
can be placed in its *caller's* region when the caller says so:

* The caller's call is itself a producer in the facts (the fresh part of
  the call's result). Where that is confined to the call's innermost
  region, the caller passes the destination 1 (`%d = op scratchdest %one`
  before the call); where it escapes the caller only through the caller's
  own result and the caller itself received a destination, the caller
  passes its own on (a chain).
* The callee takes it (`%d = op scratchtake`, its first instruction), places
  its result-only sites with `scratchreq %d` (nothing, when %d is 0), and
  exits with `scratchexit %m %d`, which leaves what it placed in the
  caller's region when %d is set.
* A unit takes a destination only when it never suspends, is not excluded,
  is not the program, is in no recursive component of the call graph, and
  some caller passes it one (a least fixpoint). Only a direct `call` of the
  canonical function passes one; a call through a function value reaches a
  generic instance, which has no frame.

**[probe]** p13: `raw`, `parse` and `respond` take a destination;
`handle` passes 1 to each, so every String of a request lands in
`handle`'s activation region and is released when it returns. p05: `make`
takes one from `use_it`.

**[test]** `ss-plan-p13`, `ss-plan-p05-returned`, `ss-nir-dest`,
`ss-run-nested` (a destination chain), `ss-run-dest-stale` (a direct call
whose result escapes passes none, and the same instance then builds that
result on the heap), `ss-run-context-escape` (a String a callee both
returns and stores into a context escapes through the context: no
destination).

## 14. Specialization and compilation isolation

**[inspection]** The plan's units are the specialization analysis's
instances: two instances of one function (two argument types) have separate
plans, each from its own facts, and a frame is emitted only in an
instance's canonical function. A companion (a fused or region variant), a
`fields` variant or an internal variant never gets a frame, never takes a
destination and never places a String, so a caller that reaches one through
another path sees the heap. Calls through function values go to the
generic instance, which is never given a destination.

**[inspection]** Isolation: the plan reads only the HIR it is given (and
its facts), computed while that HIR is lowered (`native::lowered` activates
the HIR first, COMPILATION-ISOLATION.md); it registers nothing and is
stored nowhere. HIR, HIR interchange text and the front-end cache are
unchanged: no HIR field, side table or cache key holds a plan.

## 15. Plan report examples

**[probe]** `tclsh9.0 audit/storage-scratch/tools/plan.tcl` writes the
census's plans (`audit/storage-scratch/results/plans/`). p13, abridged:

```
unit raw<int> -- takes a destination from its callers
  call of std::int::to_string (str) at p13-request-handler.bot:16:26: selected -- in the caller's region when the caller gives a destination
    semantic: escapes to activation (result: the unit's value (at p13-request-handler.bot:15:7))
unit parse<str, int> -- takes a destination from its callers
  call of std::str::substring (str) at p13-request-handler.bot:22:12: selected -- in the caller's region when the caller gives a destination
  Request {verb, path, id} (struct) at p13-request-handler.bot:32:5: rejected -- not representable: a struct (only Strings are placed)
unit handle<int> -- an activation region
  call of raw (str) at p13-request-handler.bot:39:15: selected -- its callee's result in activation
    semantic: confined to activation
  call of parse (struct) at p13-request-handler.bot:39:9: selected -- its callee's result in activation
  call of respond (str) at p13-request-handler.bot:42:22: selected -- its callee's result in activation

# What lowering emitted, and what ran
  raw<int>: call of std::int::to_string at p13-request-handler.bot:16:26: emitted (1 instruction(s))
    released by: its caller's region: the function exits with scratchexit, which leaves it there when the caller gave a destination; the caller's own boundaries release it
    size: dynamic (the object's own size at run time); may still use the general allocator: yes, the fallback (above the object limit, 64 KiB, or past the reservation limit, 64 MiB per Vm)
    ran: 200 in scratch storage, 0 fell back to the heap, 0 on the heap
  raw<int>: call of std::str::concat at p13-request-handler.bot:16:5: not emitted -- no instruction of its own (virtual, inlined or a companion call)
  ...
  handle<int>: call of raw at p13-request-handler.bot:39:15: emitted (1 instruction(s))
    released by: its function's exits: the reset before every ret, and on the error exit
    ...
    ran: its callee placed what it returns (the callee's sites count it)
```

Each emitted site states the boundary actions that release it, its size
class (dynamic: a String's size is its own, at run time) and its fallback;
the run (the native allocation report's sites, scratch storage on) says how
many times it executed through its region, through the fallback, or on the
heap. The report keeps apart, per site, the brief's six stages:
semantically eligible (`semantic:`), backend-representable
(`representable:`), selected (`selected`/`rejected`), emitted (`emitted` or
why not), executed through the region and executed through the fallback
(`ran:`).

The census summary (`results/plans/summary.md`):

| program | units | framed | sites | selected | emitted | not emitted | rejected: not confined | rejected: unit has no region | rejected: not representable | ran in scratch storage | ran through the fallback |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| p01-sequential-temps | 2 | 1 | 4 | 4 | 4 | 0 | 0 | 0 | 0 | 4000 | 0 |
| p02-simultaneous-temps | 2 | 1 | 5 | 5 | 3 | 2 | 0 | 0 | 0 | 3000 | 0 |
| p03-exclusive-branches | 2 | 1 | 4 | 4 | 2 | 2 | 0 | 0 | 0 | 1000 | 0 |
| p04-loop-reuse | 2 | 1 | 2 | 1 | 1 | 0 | 0 | 0 | 1 | 1000 | 0 |
| p05-escape-result | 3 | 2 | 4 | 4 | 4 | 0 | 0 | 0 | 0 | 4000 | 0 |
| p06-retained-aggregate | 2 | 0 | 6 | 0 | 0 | 0 | 2 | 0 | 4 | 0 | 0 |
| p07-across-suspension | 3 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 3 | 0 | 0 |
| p07b-string-across-suspension | 4 | 1 | 7 | 1 | 1 | 0 | 0 | 4 | 2 | 1000 | 0 |
| p08-two-coroutines | 4 | 0 | 7 | 0 | 0 | 0 | 0 | 0 | 7 | 0 | 0 |
| p09-nested-yield | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 2 | 0 | 0 |
| p10-handle-moved | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 2 | 0 | 0 |
| p10b-handle-returned | 4 | 0 | 4 | 0 | 0 | 0 | 1 | 0 | 3 | 0 | 0 |
| p11-context-state | 4 | 0 | 4 | 0 | 0 | 0 | 0 | 0 | 4 | 0 | 0 |
| p12-actor-messages | 178 | 0 | 249 | 0 | 0 | 0 | 137 | 44 | 68 | 0 | 0 |
| p13-request-handler | 5 | 4 | 18 | 17 | 11 | 6 | 0 | 0 | 1 | 1600 | 0 |
| p14-errors-early-exit | 3 | 2 | 6 | 4 | 4 | 0 | 1 | 0 | 1 | 3666 | 0 |
| p15-bounded-collections | 4 | 0 | 7 | 0 | 0 | 0 | 2 | 0 | 5 | 0 | 0 |
| p16-foreign-noescape | 2 | 0 | 4 | 0 | 0 | 0 | 1 | 0 | 3 | 0 | 0 |
| p16b-foreign-captures | rejected by the compiler | | | | | | | | | | |
| p17-explicit-return | 3 | 0 | 5 | 0 | 0 | 0 | 2 | 0 | 3 | 0 | 0 |
| p18-persist-precision | 4 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 3 | 0 | 0 |
| p19-context-scratch-vector | 2 | 0 | 4 | 0 | 0 | 0 | 0 | 0 | 4 | 0 | 0 |

A blocked unit's report says why (p07b: `unit worker<int> -- no region:
it may suspend: a region is never live across a suspension`).

## 16. Generated NIR examples

**[probe]** `native::nir` of p01's `label` (scratch on). One frame, four
requests, the reset before the `ret` and on the error exit:

```
func 1 "label" params=1 env=0 regs=26 pnames="i" captures=0 instance="int" rawregs="5 7 8" @e81
    %15 = op scratchmark
    pusherrorexit L0
    %16 = int 1
    %17 = op scratchreq %16
    %1 = op inttostr %0 @e85
    %2 = str "-a" @e88
    %18 = int 1
    %19 = op scratchreq %18
    %3 = op strcat %1 %2 @e92
    %4 = op strlen %3 @e90
    ...
    %20 = int 1
    %21 = op scratchreq %20
    %10 = op inttostr %9 @e96
    %11 = str "-b" @e102
    %22 = int 1
    %23 = op scratchreq %22
    %12 = op strcat %10 %11 @e108
    %13 = op strlen %12 @e106
    %14 = op iadd %4 %13 @e103
    %24 = op scratchreset %15
    ret %14
  label L0
    poperrorexit
    %25 = op scratchreset %15
    reraise
end
```

p01's `a` and `b` are bump-allocated side by side in one activation
(they are distinct objects of one region, never overlaid); the bytes are
reused by every later activation (section 17).

p04's `work`: a loop region marked before the head, reset at the head and
at the exit; the frame's error exit releases the loop's region when an
error leaves the loop:

```
    %23 = op scratchmark
    pusherrorexit L5
    ...
    %8 = op scratchmark @e82
    jump L0 @e82
  label L0
    %9 = op scratchreset %8 @e82
    %10 = op rilt %3 %0 @e82
    br %10 L1 L3 @e82
  label L1
    ...
    %24 = int 1
    %25 = op scratchreq %24
    %17 = op inttostr %16 @e94
    %18 = op strlen %17 @e105
    ...
  label L4
    %22 = op scratchreset %8 @e82
    %26 = op scratchreset %23
    ret %4
  label L5
    poperrorexit
    %27 = op scratchreset %23
    reraise
```

p13: `handle` passes a destination to each callee; `raw` takes it and
exits with `scratchexit`; the early `return 0` of the BadRequest handler
resets too:

```
func 1 "raw" params=1 env=0 regs=11 pnames="i" captures=0 instance="int" @e81
    %5 = op scratchtake
    %6 = op scratchmark
    pusherrorexit L0
    %1 = str "GET /items/" @e86
    %7 = op scratchreq %5
    %2 = op inttostr %0 @e87
    %3 = str " HTTP/1.1" @e90
    %8 = op scratchreq %5
    %4 = construct str flat %1 %2 %3 @e82
    %9 = op scratchexit %6 %5
    ret %4
  ...
func 4 "handle" params=1 env=0 regs=19 pnames="i" captures=0 instance="int" rawregs="6" @e166
    %9 = op scratchmark
    pusherrorexit L4
    pusherrorexit L0 @e168
    %10 = int 1
    %11 = op scratchdest %10
    %2 = call 1 %0 @e171
    %12 = int 1
    %13 = op scratchdest %12
    %3 = call 2 %2 %0 @e169
    ...
  label L2
    cleardeclarederror @e168
    %5 = int 0 @e176
    %6 = rawint 0
    %14 = op scratchreset %9
    ret %5 @e175
  ...
  label L1
    %15 = int 1
    %16 = op scratchdest %15
    %7 = call 3 %1 @e179
    %8 = op strlen %7 @e177
    %17 = op scratchreset %9
    ret %8
  label L4
    poperrorexit
    %18 = op scratchreset %9
    reraise
end
```

**[inspection]** Machine code: `scratchreq` and `scratchdest` emit no
instruction of their own; the request is two stores around the helper call
(`codegen::clif`'s `call_allocating`: the 32-bit request word set before the
call, cleared after it), the destination a store before `Inst::Call` and one
after. `scratchtake` is a load, a store of 0 and a tag. `scratchmark`,
`scratchreset` and `scratchexit` are runtime calls (`rt_scratch_mark`,
`rt_scratch_reset`, `rt_scratch_exit`).

**[inspection]** Frame cost: a mark (and a destination flag) is live for its
whole region, across every call in it; nothing else of the protocol is. The
constant 1 a request passes is defined right before it, so it is dead before
the next safepoint, and the root plan counts no register defined only by
`scratchmark` or `scratchtake` as a root (`codegen::roots`: like a context
leaf, a small Int that is never a heap pointer). So a framed function's
activation pays one callee-saved register (or spill slot) for its mark, and
no root slot. An earlier version defined the constant once at entry and
rooted the mark: two root slots per activation, found by CI (section 24).

## 17. Positive-workload results

Reproduce: `tclsh9.0 audit/storage-scratch/tools/measure.tcl`
(`results/measurements.md`, every N); per-site reports with
`native::allocationReport HIR sites 1 ?-scratch-opt 0?`.

**A. p01, sequential temporaries.** **[probe]** `label` has one activation
region and four placed sites (two `to_string`s and two concatenations;
section 16). **[measurement]** 4 heap allocations per call without scratch
storage, 0 with it; 4 Strings placed per call, every one after the first
call in reused bytes (39,996 of 40,000 at N = 10,000); one reservation; the
peak in use 128 bytes at every N (a call's four Strings, side by side, then
released at its exit). **[test]** `ss-plan-p01`, `ss-nir-frame`,
`ss-run-heap-reduction`, `ss-run-steady-state` (the same reservation and peak
at N = 10 and N = 2,000), `ss-run-census` (the value, also under GC stress).

**B. p04, loop-local temporary.** **[probe]** `work`'s fold has a loop
region (marked before its head, reset at its head and exit) and the frame's
error exit releases it if an error leaves the loop. **[measurement]** 1 heap
allocation per iteration without, 0 with; 2 regions per run (the frame and
the loop) whatever N; 9,999 of 10,000 placements in reused bytes; peak in
use 32 bytes at every N. The `Pair` struct beside the String is
scalar-replaced, as before.

**C. p13, request handler.** **[measurement]** Per request, without and with
scratch storage (each site 200 times at N = 200; `allocationReport sites`):

| site | operation | heap (off) | with scratch storage |
|---|---|---:|---|
| `raw`: `std::int::to_string(i)` (16:26) | `inttostr` | 27 B | placed, caller's region |
| `raw`: the request line, `"GET /items/".concat(...).concat(" HTTP/1.1")` (16:5) | `construct str flat` (one fused chain) | 47 B | placed, caller's region |
| `parse`: `substring(line, 0, 3)` (22:12) | `substr` | 28 B | placed, caller's region |
| `parse`: `substring(line, 4, n - 9)` (27:12) | `substr` | 34 B | placed, caller's region |
| `parse`: `Request {verb, path, id}` (32:5) | `structnew` | 56 B | **heap**: a struct (not representable; its `verb` and `path` fields hold placed Strings, which the confinement proof says it does not outlive) |
| `respond`: `std::int::to_string(r.id * 2)` (35:77) | `inttostr` | 28 B | placed, caller's region |
| `respond`: the body, a fused chain of four concatenations (35:12) | `construct str flat` | 61 B | placed, caller's region |
| `respond`: `std::int::to_string(length(body))` (36:50) | `inttostr` | 27 B | placed, caller's region |
| `respond`: the response, a fused chain (36:5) | `construct str flat` | 100 B | placed, caller's region |

Every String is placed through a destination: `handle` confines each
callee's result to its activation and passes 1, so a request's eight Strings
(and its `Request`'s fields) live in `handle`'s region and are released when
it returns, including the early `return 0` of the BadRequest handler. The
remaining allocation per request is the struct: **not representable** (only
Strings are placed). None remains because of an interprocedural return
(every returned String is placed in the caller's region), an unsupported
String operation, a construction plan (each fused chain is one placed
`construct`), an unknown size (sizes are the provider's, at run time) or
another backend limitation. Peak in use: 384 bytes per request (400 at
N = 10,000, whose Strings have more digits); one reservation at every N;
79,990 of 80,000 placements in reused bytes. **[inference]** A zero-heap
steady state for p13 needs structs placed (section 26); this milestone does
not claim one.

**D. p14, errors and early exits.** **[measurement]** 3.67 managed-heap
allocations per unit without, 0 with (the declared failures' own two system
blocks each remain, section 21); 2 regions per unit (the frames of `check` and
`early`), peak in use 72 bytes at every N. **[test]** p14 covers normal
return, early `return`, a declared failure carrying a payload computed from
a placed String (`fail TooBig {limit: std::str::length(s)}`: the payload is
an Int, so the String dies at the `fail`) and its handling in the caller;
`ss-run-exits` adds `break`, `continue` and a propagated failure, and
`ss-run-error-steady` shows no storage left occupied after failing calls
(the same peak at N = 40 and N = 400). A payload String that a handler
needs is never placed in the failing unit's region: an error a call lets
through escapes the unit (section 5's first fix, `sl-error-let-through`).

## 18. Negative-workload results

**[test]** `tests/scratch-storage.test` holds the census's negative cases
and the brief's additional ones; **[measurement]** the census rows below are
heap allocations without and with scratch storage at the cases' own sizes,
Strings placed, and the stale roots and protocol errors of a GC-stress run
(`ss-run-census` asserts the zeros and that every outcome equals interp's
and the native run without scratch storage, plain and under GC stress):

| case | required behavior | how it holds | heap off / on | placed | stale / protocol |
|---|---|---|---:|---:|---:|
| p02 simultaneous temporaries | never overlay live storage | both selected for one activation region: bump allocation gives each its own bytes (`ss-plan-p02-simultaneous`) | 3,000 / 0 | 3,000 | 0 / 0 |
| p05 returned result | never reset the callee's storage while the caller needs it | `make` places its result in `use_it`'s region through a destination; `make`'s exit leaves it there (`ss-plan-p05-returned`) | 4,000 / 0 | 4,000 | 0 / 0 |
| p06 retained aggregate | never recycle what the vector holds | the pushed Strings escape the loop: rejected (`ss-plan-p06-retained`) | 1,003 / 1,003 | 0 | 0 / 0 |
| p07b suspended String | never reset a value needed after resumption | the worker may suspend: no region at all; the driver's own loop keeps its region (`ss-plan-p07b-suspension`) | 5,000 / 4,000 | 1,000 | 0 / 0 |
| p08 independent coroutines | never overlap persistent state | both coroutines' units suspend: no region; nothing placed | 1 / 1 | 0 | 0 / 0 |
| p11, p19 context-owned state | context data is never scratch | nothing reaching an installed context is selected (`ss-plan-p11-p19-context`) | 5 / 5, 5 / 5 | 0 | 0 / 0 |
| p12 actor messages | never recycle what a mailbox or host retains | every actor unit suspends; no message is selected (`ss-plan-p12-actors`) | 2,561 / 2,561 | 0 | 0 / 0 |
| p16 foreign noescape | keep the noescape contract | the bytes lent to C are byte storage, never placed (the plan: "not representable"); the exposure is the C FFI's, unchanged; outcome unchanged on both native runs (interp refuses the C call) | 0 / 0 | 0 | 0 / 0 |
| p16b foreign captures | FOREIGN-BORROW stays a rejection | still rejected by the compiler, with the same diagnostic (no plan) | -- | -- | -- |
| p03 exclusive branches | (positive in the census; a limitation here) | the branches' concatenations are materialized at the join: not matched (section 25) | 3,000 / 2,000 | 1,000 | 0 / 0 |

p07, p09, p10, p10b, p15, p17 and p18 place nothing and agree likewise.

**[test]** The brief's additional negative cases:

| case | test |
|---|---|
| immutable aliases | `ss-run-nested` (an outer String bound twice, read after the callees' resets), `ss-plan-program-mutations` |
| nested regions | `ss-run-inner-region`, `ss-run-nested-loops-steady` |
| recursive calls | `ss-plan-recursive`, `ss-run-nested` |
| closure captures | `ss-run-closures`, `ss-plan-escapes`, `ss-plan-program-mutations` (`closure`) |
| unknown function values | `ss-plan-escapes`, `ss-plan-program-mutations` (`unresolved`), `ss-run-dest-stale` |
| a returned String that shares or retains an operand | `ss-plan-program-mutations` (`retained`: a callee that may return its argument) |
| an outer region surviving an inner failure | `ss-run-exits`, `ss-run-error-steady`, `ss-run-stress-variety` |
| a String read after a collection | every GC-stress run (a collection before every allocation, placements included: `ss-run-stress-collects`) |
| repeated grow and fallback cycles | `ss-run-growth`, `ss-run-fallback-large`, `ss-run-fallback-capacity`, `ss-run-stress-variety` |
| several native threads with separate Vms | `ss-run-vms` |
| suspension | `ss-run-coroutines`, `ss-plan-p07b-suspension` |
| a standalone executable | `ss-run-executable` |

**[test]** Allocation-path mutations (brief section 17): `ss-plan-program-mutations`
takes one placed String (`t = std::int::to_string(k).concat("x")` in a
fold) and changes only how it is used. The plan's decision and verdict for
the concatenation, and the agreement of every run:

| mutation | decision | verdict |
|---|---|---|
| (the base) | selected, its iteration's region | confined |
| returned through the fold | rejected | escapes |
| pushed into a vector that outlives the loop | rejected | escapes |
| captured by a closure the fold carries out | rejected | unknown |
| retained through a call that may return it | rejected | escapes |
| read after a yield | rejected (the unit may suspend) | confined |
| beside a second String | both selected, one region | confined |
| passed to a function value | rejected | unknown |
| stored into a context | rejected | escapes |

Every one of the nine programs gives the same value natively with and
without scratch storage and on interp. Nothing that does not compile
compiles, or the reverse: scratch storage is a lowering of an accepted
program only.

## 19. Independent and mutation-testing evidence

**The differential fuzzer** (`audit/storage-scratch/tools/fuzz.tcl`): its
own generator (no compiler code) writes programs whose helpers build,
return, box, list, fail with, relay, recurse over and pass Strings through
function values, with loops left by `continue`, nested loops, handled and
let-through failures, closures, and Strings kept in vectors that outlive
their loops, and Strings read back out of a helper's struct through a
function that projects them (`label(b: Box) -> str`); every kept String is
folded into the value. Each runs on interp (the oracle), on the Tcl
compiler and natively in five modes: scratch storage on, under GC stress
(released storage poisoned), with 48-byte chunks (growth on every path),
with scratch storage off, and on cranelift-generic under GC stress, whose
canonical functions return structs (the specialized backend keeps a struct
result in registers, a companion with no frame).
**[measurement]** `tclsh9.0 audit/storage-scratch/tools/fuzz.tcl -seeds 1-40 -count 6`
(`results/fuzz.txt`, at `1d26dc9b`): 240 programs, 0 failures, 0 that do
not compile -- every outcome equal to interp's on the Tcl compiler and in
all five native modes, no stale root and no protocol error. The plan
selected 4,181 sites; the specialized lowering placed 1,403 of them (30,128
Strings in scratch storage over the runs, 163,382 heap allocations instead
of 193,510); 1,148 had no instruction of their own and 1,630 were in
instances that have no canonical function there (section 25). Before
section 24's fixes the same seeds, without the projection and the generic
mode, gave 3,563 sites, 1,374 placed and 27,731 Strings; the frame-cost
fix (`e18e11de`, recursive units without regions) left those counts
unchanged.

**[probe]** Positive control: with each of the first two unsound lifetime
facts of section 5 reintroduced, 8 of 8 generated programs fail (NATIVE BUG
or EILSEQ under poisoning); with the third (a fresh part's kinds), 6 of 6
fail in the generic mode (`-seeds 1-2 -count 3`). Before the fuzzer called
a helper through a function value no specialization makes exact, it missed
the fresh-result defect (the companion and exact-callable specialization
hid it); before it ran cranelift-generic and projected a helper's String
through a function, it missed the fresh-part defect, which CI found
(section 24). Both shapes are now in every generated program.

**The mutants** (`audit/storage-scratch/tools/mutate.tcl`,
`tools/mutants.txt`): each breaks one rule in a private copy of the tree
(the native ones rebuilt), and must be killed by a detector its `!!` line
names -- a test of behavior, a GC-stress or poisoned run, an instrumented
count, the fuzzer or a Rust test, never a comparison of generated text.
**[test]** `tclsh9.0 audit/storage-scratch/tools/mutate.tcl` (`results/mutants.md`):
the unmutated copy passes every detector, and all 25 mutants apply, build
and are killed by a detector their line names (the record run of 22, and
the reruns of the mutants section 24's fixes touched or added):

| mutant | the broken rule | killed by |
|---|---|---|
| plan-any-verdict | every site taken as confined, whatever its verdict | ss-plan-escapes, ss-run-dest-stale, the fuzzer |
| plan-result-any-reason | any escape taken as an escape through the result | ss-run-context-escape |
| plan-outermost-region | a site placed in its outermost loop's region | ss-run-nested-loops-steady |
| plan-suspending-unit | a unit that may suspend gets regions | ss-plan-p07b-suspension |
| plan-recursive-region | a recursive unit gets regions (and may take a destination) | ss-plan-recursive |
| lower-no-exit-reset | a frame's `ret` keeps its region | ss-nir-frame, ss-run-steady-state |
| lower-no-error-exit-reset | a frame's error exit keeps its region | ss-run-error-steady |
| lower-no-head-reset | a loop's head does not reset its region | ss-nir-loop, ss-run-steady-state, ss-run-nested-loops-steady |
| lower-inner-reset-outer-mark | an inner loop resets to its enclosing loop's mark | ss-run-inner-region |
| lower-dest-as-one | a result-only site always placed, destination or not | ss-run-dest-stale |
| lower-request-constant-at-entry | a request's constant defined at the function's entry, live across every call | ss-nir-frame-roots |
| rt-reset-ignored | a reset moves the position nowhere | ss-run-steady-state, six Rust tests |
| rt-bump-no-advance | an allocation does not advance the position | ss-run-census, ss-run-heap-reduction, six Rust tests |
| rt-exit-ignores-dest | a frame's exit resets even with a destination | ss-run-census, ss-run-nested, the fuzzer |
| rt-grow-replaces-live | a growth replaces the chunk holding live objects | two Rust tests |
| rt-stress-no-collect | a placement under GC stress does not collect | ss-run-stress-collects |
| rt-collector-reads-scratch | the collector marks scratch objects as heap ones | two Rust tests |
| clif-request-not-cleared | a request outlives its helper | ss-run-request-cleared |
| clif-dest-not-cleared | a destination outlives its call | ss-run-dest-stale |
| roots-mark-rooted | a region's mark and a destination flag are GC roots | ss-nir-frame-roots |
| nir-protocol-unchecked | the NIR validator accepts any request or destination | ss-nir-validator, a Rust test |
| lifetime-error-let-through | an error a call lets through carries nothing out | sl-error-let-through, the fuzzer |
| lifetime-fresh-holds-nothing | a callee's fresh result holds nothing it was given | sl-fresh-holds-parameter, the fuzzer |
| lifetime-fresh-one-kind | a call's fresh part keeps its result's kind | sl-fresh-nested-kinds, ss-run-fresh-nested |
| lifetime-reasons-grow | a recursive component's reasons are the latest found | sl-recursive-reasons-converge |

The brief's runtime mutants map onto these: reset one region too early
(`lower-inner-reset-outer-mark`: an inner loop resets its enclosing loop's
region; `plan-any-verdict`: a String released with a region it outlives),
omit a reset on an error edge
(`lower-no-error-exit-reset`), reuse an overlapping region
(`rt-bump-no-advance`), free backing during a live alias
(`plan-any-verdict`, `lower-dest-as-one`, `rt-exit-ignores-dest`), permit
relocation of live backing (`rt-grow-replaces-live`), miscount active region
ownership (`rt-exit-ignores-dest`, `clif-dest-not-cleared`), suppress
collection at an optimized site (`rt-stress-no-collect`). "Fail to trace an
outgoing pointer" has no counterpart: a placed object is a String, which
has none; the collector's own scratch rule is `rt-collector-reads-scratch`.

**[inspection]** One mutant considered is not in the catalog, because no
program we could write kills it: taking an instruction matched through a
binding's use as the site's even where the use runs in a deeper loop.
Lowering materializes a binding that a deeper loop reads before that loop (eagerly,
at the binding: **[probe]** the NIR of a binding read only inside an inner
loop with its own region has the concatenation before the inner loop's
mark), so the check never rejects an instruction today; it stays as a guard
for a lowering that would defer across a loop.

**The lifetime oracle** is not an oracle of the storage mechanism, but the
fixes of section 5 changed the analysis, so its checks were rerun.
**[measurement]** Every result matches the committed record of
STORAGE-LIFETIME-FACTS-MILESTONE-1 (`audit/storage-lifetime/results/`):
`oracle.py selftest` passes; `fuzz.tcl -seeds 1-12 -count 40` gives 480
programs, 1,087 suspensions and 6,061 verdicts, every one precise and none
unsound; `-strings 0` gives 240 programs, 240 C frames and no violation;
`persist.tcl` over the census, the audit's cases and the kiosk gives 15 frames
and no violation; `reachability.tcl` (run with scratch storage off, since it
checks the facts against the heap's own reachability: `-scratch-opt 0` is
its one change) gives the same twelve shapes and no contradiction; and
`mutate.tcl` kills all 26 of its mutants of `hir/lifetime.tcl`, each by the
same tests as before. The fixes therefore changed no verdict of the
oracle's corpus; they change what the corpus did not reach (a let-through
error's payload, a fresh result holding a parameter, a recursive
component's reasons, a fresh part's kinds -- the oracle's programs build no
struct), which the four new tests pin. After the fourth fix the oracle's
selftest, `fuzz.tcl -seeds 1-5` (200 programs, 0 unsound, every verdict
precise), `-seeds 6-8 -strings 0` (0 violations), `persist.tcl` (identical
to its record) and `reachability.tcl` (0 contradictions) were rerun, and
the mutants beside the changed rule (`caller-object-empty`,
`result-params-ignored`) are killed by the same tests as before
(`kind-filter-off`'s rerun is pending).

## 20. GC-stress results

**[test]** Under `BOTLISH_NATIVE_GC_STRESS=1` (a collection before every
allocation, scratch placements included; released scratch storage
poisoned): every census program (`ss-run-census`), the exits
(`ss-run-exits`), nested regions and destinations (`ss-run-nested`,
`ss-run-inner-region`, `ss-run-dest-stale`, `ss-run-context-escape`),
closures, coroutines (fused and unfused), growth, and a long mixed run
(`ss-run-stress-variety`: short Strings and Strings over a 32-byte object
limit alternating, so every other one falls back; empty Strings; heap
Strings kept across the loop between placed ones; nested calls; a failure
handled every fifth call; 64-byte chunks) -- every outcome equal to interp's,
no stale root, no protocol error, and the storage reserved (2 chunks, 192
bytes) and in use (128 bytes) the same at N = 60 and N = 240.
`ss-run-stress-collects`: a stress run collects as often with scratch
storage as without (p01: 4,000 collections both ways; p13: 1,800; p14:
3,666). The fuzzer's stress mode ran every generated program the same way.

**[probe]** Memory-safety instrumentation, kept apart from the functional
evidence: valgrind 3.22's memcheck on standalone executables of p01, p04,
p05, p13 and p14, plain and under GC stress
(`audit/storage-scratch/tools/memcheck.tcl`,
`results/memcheck.txt`): no error, every run status 0. Memcheck sees a
swept heap object read through a lost root, or an invalid free, as an
error; it cannot see a read of released scratch storage (chunks are
ordinary allocated memory to it), which is what the poisoning instruments.

**[measurement]** No permanent growth when the workload is bounded: one
reservation (16 KiB) and the same peak in use at every N for every positive
workload (section 23); 2 reservations under 64-byte chunks at N = 60 and
240 alike. No retention of dead heap objects: a placed String is a leaf, so
nothing in scratch storage keeps a heap object alive; GC-stress peaks of the
lifetime audit's reachability shapes are unchanged
(`audit/storage-lifetime/tools/reachability.tcl`, run with scratch storage
off, since it checks the facts against the heap).

## 21. Allocation-count comparisons

**[measurement]** Heap allocations without and with scratch storage
(`results/measurements.md`; `results/plans/summary.md` for what the plan
selected; census cases at their own sizes, section 18):

| workload | N = 1 | N = 10 | N = 100 | N = 1,000 | N = 10,000 |
|---|---:|---:|---:|---:|---:|
| p01 | 4 / 0 | 40 / 0 | 400 / 0 | 4,000 / 0 | 40,000 / 0 |
| p04 | 1 / 0 | 10 / 0 | 100 / 0 | 1,000 / 0 | 10,000 / 0 |
| p13 | 9 / 1 | 90 / 10 | 900 / 100 | 9,000 / 1,000 | 90,000 / 10,000 |
| p14 | 3 / 0 | 36 / 0 | 366 / 0 | 3,666 / 0 | 36,666 / 0 |
| p05 | 4 / 0 | 40 / 0 | 400 / 0 | 4,000 / 0 | 40,000 / 0 |
| p12 | 173 / 173 | 281 / 281 | 1,361 / 1,361 | 12,161 / 12,161 | 120,161 / 120,161 |

The heap counts are the Botlish managed heap's, every runtime helper's
allocations included (they all allocate through the Vm's heap); scratch
reservations are the provider's system allocations, counted apart (one per
run here). Scratch placements are not heap allocations: they are counted
as `scratch allocations` (the same number as the heap allocations they
replace, in p01, p04, p05 and p14).

**[measurement]** The fuzzer's corpus (240 programs, section 19): 141,059 managed-heap allocations without scratch storage, 113,328 with it (27,731 Strings placed).

**[measurement]** Every system allocation, not only the managed heap's
(`tools/sysalloc.tcl`, `results/sysalloc.md`: valgrind's total heap usage of
a standalone executable at N = 1,000 and 2,000, per unit):

| workload | system allocations per unit, off / on | managed-heap allocations per unit, off / on |
|---|---:|---:|
| p01 | 4.00 / 0.00 | 4.00 / 0.00 |
| p04 | 1.00 / 0.00 | 1.00 / 0.00 |
| p13 | 10.00 / 2.00 | 9.00 / 1.00 |
| p14 | 5.67 / 2.00 | 3.67 / 0.00 |
| p05 | 4.00 / 0.00 | 4.00 / 0.00 |

**[probe]** Valgrind's DHAT names the rest: p13's two blocks per request are
its `Request` struct (`Vm::new_struct`: the object, and its fields'
`to_vec`); p14's two per unit (every unit between N = 1,000 and 2,000 fails,
`i > 900`) are `rt_fail_declared_payload`'s, which allocates the payload's
slots and formats a message for every declared failure (ops.rs, lines 445
and 451), with scratch storage off and on alike. **[inference]** So p01,
p04 and p05 reach a zero-allocation steady state, the runtime helpers
included (one 16 KiB chunk at the first placement); p13 and p14 do not, and
what remains is identified: a struct, and the declared-failure path.

**[inference]** What the counts do not include: the 16 KiB chunk per Vm
(reserved once, kept until the run ends), the frames' register and the two
32-bit Vm words. A program that places nothing reserves nothing.

## 22. Performance and latency measurements

**[measurement]** Times are the native driver's `bench` (the program
JIT-compiled once, then run R times in one process; compile time excluded),
at N = 10,000, R = 7, on a 4-core x86-64 container with nothing else
running (other jobs were paused for the timed runs: an earlier run beside
a mutation harness gave p04 and p14 times 25% and 3% worse with scratch
storage, and the reruns below did not reproduce either). Best and median
per run, and per unit (`results/measurements.md`):

| workload | off: best / median, us | on: best / median, us | per unit off / on, ns (best) | on/off (best) | on/off (median) |
|---|---:|---:|---:|---:|---:|
| p01 | 1,415 / 1,500 | 667 / 691 | 141 / 67 | 0.47 | 0.46 |
| p04 | 275 / 307 | 344 / 354 | 28 / 34 | 1.25 | 1.15 |
| p13 | 5,086 / 5,150 | 2,873 / 2,936 | 509 / 287 | 0.56 | 0.57 |
| p14 | 1,939 / 2,016 | 1,191 / 1,228 | 194 / 119 | 0.61 | 0.61 |
| p05 | 1,418 / 1,523 | 750 / 766 | 142 / 75 | 0.53 | 0.50 |
| p12 (nothing placed) | 33,104 / 33,552 | 33,305 / 33,550 | 3,310 / 3,330 | 1.01 | 1.00 |

**[measurement]** p04 at N = 10,000 runs for about 0.3 ms, too short to
time reliably here: three other measurements of the same program at the
same size (two runs of the cost probe and a separate one, best of 9 or 11)
gave 0.73, 0.73 and 0.74 (on/off, best); the table's run gave 1.25.
At sizes long enough to time (`results/costs.md`):

| p04, N | collections (off) | per iteration off / on, ns (best of 9) |
|---:|---:|---:|
| 10,000 | 0 | 28.7 / 21.0 |
| 100,000 | 2 | 37.8 / 21.3 |
| 1,000,000 | 29 | 42.7 / 22.0 |

**Where the time goes.** **[measurement]** The cost probe
(`tools/costs.tcl`: one function called 100,000 times, placing K Strings per
call):

| K | collections (off) | (on - off) per call, ns (best of 9) | saved per placed String, ns |
|---:|---:|---:|---:|
| 0 (a frame and an empty loop region, nothing placed) | 0 | +11.4 | -- |
| 1 | 2 | -15.2 | 15.2 |
| 2 | 5 | -41.3 | 20.7 |
| 4 | 11 | -87.3 | 21.8 |
| 8 | 22 | -181.1 | 22.6 |

**[inference]** From these:

* *Region bookkeeping* is the cost: a frame is a mark, a reset (two
  runtime calls) and the error exit's registration; a loop region a mark
  and a reset per iteration. About 11 ns for the five runtime calls of
  K = 0, about 2 ns each. They are calls into `rt_scratch_mark`,
  `rt_scratch_reset` and `rt_scratch_exit`, not inline code: inlining the
  position's load and store (the Vm word is at a fixed offset, as the
  request and destination already are) is the obvious next step.
* *The saving* per placed String is the heap path's cost -- the system
  allocator, the heap's object list, its share of every collection's mark
  and sweep -- against a bump of a position. It is 15 to 23 ns here, and
  grows with the heap side's collections (the K = 1 row's two collections
  against the K = 8 row's 22).
* So one placed String already pays for its frame, and a function with
  several placed Strings per region gains most (p01: four per frame, 0.47;
  p13: eight per request region, 0.56 including its remaining struct
  allocation).
* *GC integration* costs nothing outside GC stress: a placement never
  collects, and the collector's address check is two comparisons per
  pointer it pops (`contains`'s bounds first). *Root management* is
  unchanged: no root is added (a mark is a small Int), and the stack maps
  are the same. *Lost native optimizations*: none observed (the functions
  that get frames already call runtime helpers). *Placement*: the innermost-region rule puts a reset at every
  loop iteration even when the loop places one small String, which is
  p04's whole cost at sizes where its heap side never collects.

**Latency.** **[measurement]** The harness times whole runs, not single
requests: the spread of R runs (best to worst) is the distribution it can
measure reliably. With scratch storage on, the spreads are narrower (p01:
667-733 us against 1,415-2,434; p13: 2,873-3,166 against 5,086-5,822),
which **[inference]** is the collections the heap side runs in some runs and
not others (p13 off: 4 collections per run at N = 10,000, on: none). A
per-request latency distribution needs a per-request clock in the program,
which Botlish does not offer (no clock without a context); it is not
measured.

**Compile time.** **[measurement]** Native lowering of an already-built
HIR, scratch storage off and on, best of 3 (`tools/compile-cost.tcl`,
`results/compile-cost.md`): p01 7 and 9 ms; p13 16 and 22 ms; the 2048
demo 431 and 519 ms (+20%); the CSV export application 1,284 and 1,417 ms
(+10%); p12 and the event loop's fairness program (4.9 s and 4.4 s
lowerings) within their noise. **[inference]** The added time is
`hir::lifetime::analyze` and the plan, which run for every native lowering
with scratch storage on; it is a small part of the larger programs'
lowering, and the facts are computed once per lowering, stored nowhere.

## 23. Memory-use measurements

**[measurement]** Scratch storage per run (`results/measurements.md`):

| workload | reservations | peak reserved | peak in use, N = 1 | peak in use, N = 10,000 | growths | fallbacks |
|---|---:|---:|---:|---:|---:|---:|
| p01 | 1 | 16,384 B | 128 B | 128 B | 0 | 0 |
| p04 | 1 | 16,384 B | 32 B | 32 B | 0 | 0 |
| p13 | 1 | 16,384 B | 384 B | 400 B | 0 | 0 |
| p14 | 1 | 16,384 B | 72 B | 72 B | 0 | 0 |
| p05 | 1 | 16,384 B | 128 B | 144 B | 0 | 0 |

The peak in use depends on the Strings' lengths (more digits at larger N),
never on the number of iterations or requests: no permanent growth.

**[measurement]** Whole-process memory, the peak resident set of a
standalone executable at N = 10,000 (python3's `resource.getrusage` of the
child): p01 12,912 KB off and 12,916 KB on; p13 12,952 and 12,912; p14
12,948 and 12,924; p12 12,924 and 12,928. **[inference]** The difference is
within the measurement's noise: the process's footprint is the runtime's
and the heap's 1 MB collection threshold, and these workloads' heaps never
grow past it far enough for the avoided allocations to show in the resident
set. A workload with a larger live heap per request would show the
difference the collection counts already do.

## 24. Existing regression and CI results

**main before the branch.** **[test]** main's latest runs at `d6b0161c`,
the commit the work branches from: tests.yml (run 43925972736),
tests-arm64.yml (43925973016), macos-arm64.yml (43925972712) and
windows-x86_64.yml (43925972651) all succeeded. Nothing failing on main was
built on.

**Local, on this container** (x86-64 Linux, rustc 1.100.0, Tcl 9.0.1):

| check | result |
|---|---|
| `tclsh9.0 tests/local.tcl -jobs 3` (every Tcl test file on interp and compile, minus golden duplicates; every golden suite on all four backends through the front-end cache) | 720 of 720 passed, exit 0 |
| `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/local.tcl -all 1 -parts tcl` over the 18 files most sensitive to the collector and to String storage (scratch-storage, storage-lifetime, error-payloads, golden-framework, event-loop, string-allocation, virtual-construction, native-string-region, native-string-view, coroutines, affine, resources, fold-virtual-construction, actor, concurrent-vms, c-ffi-error-capture, native-library, c-callbacks) | 36 of 36 passed (both passes) |
| `tests/scratch-storage.test` with `BOTLISH_NATIVE_LINKER=stub`, with `system`, and under `BOTLISH_NATIVE_GC_STRESS=1` | 40 of 40 each |
| `cargo test --release --manifest-path native/Cargo.toml --lib --bins` | 374 and 137 passed |
| `tests/canary.test` | 20 of 20 |
| `tclsh9.0 tools/mutant-catalogs.tcl` | 117 catalogs, 3,953 mutants, 0 problems |
| `tclsh9.0 tools/compilerpedia.tcl check` | 1,306 topics, 789 examples, 0 problems |
| `tclsh9.0 audit/refactor/tools/gate.tcl` (the warning gate) | passed |
| `tests/numeric-looking-names.test -match nl-no-string-ternary*` | passed |
| the lifetime audit (oracle, fuzzer, persist, reachability, mutants) | as committed (section 19) |

Earlier in the work, the first full local run failed `c-ffi.test` and
`external-tools.test` because rustup's default toolchain was stable 1.97
while the checkout pins 1.100 (AGENTS.md, "Building the native (Cranelift)
backend"); `bash tools/rust-toolchain.sh install` made the pin the default,
and both pass in the run above.

Five test files pinned another optimization's heap evidence (allocation
counts that scratch storage would now take off the heap):
`tests/native-string-region.test`, `tests/native-string-view.test`,
`tests/string-allocation.test`, `tests/virtual-construction.test` and
`tests/portable-io.test` measure with `-scratch-opt 0`, as AGENTS.md's
section now says a test of another optimization's heap evidence does. No
other existing test changed; `tests/storage-lifetime.test` gained the three
tests of section 5, and `tests/scratch-storage.test` is new (40 tests).

**Commits** (on `claude/gracious-hopper-zg4doz`, from `d6b0161c`):

| commit | |
|---|---|
| `fafbd2c5` | the plan, its lowering, the provider, the NIR protocol, the three lifetime fixes, the tests |
| `20b3ec89` | audit tools, the tests of program mutations, inner regions and GC-stress collection, AGENTS.md |
| `d145e1c4` | stronger detectors, the cost probe, memcheck, measurements |
| `cbcd0c5c` | compile cost, quiet-machine measurements, the report's draft |
| `813e0cba` | system allocations per unit, the final fuzz run |
| `d8e3057e` | plan reports with boundary actions, fallback and what ran |
| `dbf9817e` | AGENTS.md: the tools and the fuzzer's comparisons |
| `7c0e237a` | the mutant catalog's record run |
| `ee71d90a` | the report: the lifetime audit's rerun |
| `00646ca2` | `ss-run-census`: p16 only where a C call links (the CI finding) |
| `4a4a1426` | the report: regression results and commits |
| `e18e11de` | a region costs its frame only the mark; no region in a recursion (the macOS finding) |
| `0a7a21eb` | the report: the fuzzer's run after the frame-cost fix |
| `1d26dc9b` | lifetime facts: a call's fresh part may be a String the caller reads (the arm64 finding) |

**CI on the branch.** **[test]**

* `static-decisions.yml` at `dbf9817e` (run 43958814881, whose front end
  is the tip's): succeeded -- the batched and sequential schedulers agree on
  every golden suite.
* `tests.yml` at `dbf9817e` (43958793520): the canary, the four golden
  shards and the native Rust unit tests succeeded; **the stub-linked
  executables job failed** -- `ss-run-census` ran p16, a C call, natively
  under `BOTLISH_NATIVE_LINKER=stub`, which links no C. Fixed in `00646ca2`
  (p16 runs only where `cLinker` holds, the rule of every executable test);
  the run was superseded before its other jobs finished.
* At `00646ca2`: every finished job of all four workflows succeeded --
  tests.yml's canary, golden shards, Rust unit tests, method-call decision,
  stub-linked and system-linked executables (also under GC stress);
  tests-arm64.yml's canary, golden shards, Rust unit tests (also under GC
  stress) and system-linked executables; macos-arm64.yml's smoke, its Linux
  control, the six acceptance shards, the system linker and the
  application's jobs; windows-x86_64.yml's canary, smoke, root plans,
  system linker and its first acceptance shards -- except one: **macOS's
  main-thread startup job failed** (run 43974508542). Its graphical census
  (`audit/macos-graphical-main-thread/tools/census.py --strict`) runs the
  recursion shapes of `programs/depth.bot` on an 8 MiB main-thread stack as
  a control, and predicts that `keep` -- a String held across the
  recursive call -- finishes 100,000 deep; it ended in NATIVE LIMIT STACK.
  The jobs still running (the Tcl suites and the native coverage on both
  Linux hosts, arm64's GC stress, two Windows acceptance shards) were
  superseded by the fix below.

**The frame-cost finding.** **[measurement]** `keep` was framed: its
String is confined to its activation, so its function marked a region at
entry and reset it at every exit. Two registers of the protocol were live
across its recursive call: the mark, and the constant 1 the request passes,
which the lowering defined once at entry. Both were small Ints, but the
root plan counted them as managed registers, so each took a root slot
(`native::roots`: 6 slots where the function without scratch storage has
4). On x86-64 the frame grew from 80 to 112 bytes, and an 8 MiB stack held
`keep` about 74,600 deep instead of about 104,600 (`depth.bot keep N` with
`BOTLISH_NATIVE_STACK_BYTES=8388608`, the largest N that completes, to
within 500). Three changes fix it:

* the constant is defined right before each request, so it is dead before
  the next safepoint (native/lower.tcl's `ScratchFrameFinish`);
* the root plan counts no register defined only by `scratchmark` or
  `scratchtake` as a root (`codegen::roots`, beside the context leaves);
  with these two, `keep` needs its 4 root slots again, but its mark still
  takes a callee-saved register, saved in the prologue: 96 bytes with
  alignment, about 87,100 deep;
* so a unit in a recursive component of the direct call graph gets no
  region (hir/storageplan.tcl; section 15): every activation of a
  recursion would pay for its mark, which a recursion multiplies by its
  depth. `keep` is then compiled exactly as without scratch storage
  (`depth.bot`'s NIR is byte-identical with and without), and holds about
  104,600 deep again.

No census program has a placed site in a recursive unit: the plans of
`results/plans/` are unchanged, and so are the heap and scratch counts of
sections 17, 21 and 23. The times of section 22 were measured before the
fix; it removes root slots and their spills from framed functions and
changes nothing else they run. New detectors: `ss-nir-frame-roots` (p01's
`label` and p13's `raw` need the root slots they need without scratch
storage), the Rust test `scratch_mark_and_take_are_not_roots`, and the
mutants `lower-request-constant-at-entry` and `roots-mark-rooted`; the
mutant of recursive units now targets their region
(`plan-recursive-region`), and `ss-run-nested` adds a recursion through a
function value held in a struct field, which the direct call graph does
not see, so its frames nest level by level. After the fix, on this
container: `tests/scratch-storage.test` 41 of 41 on interp and compile and
under `BOTLISH_NATIVE_GC_STRESS=1`; `tools/mutant-catalogs.tcl` 117
catalogs, 3,955 mutants, 0 problems; the fuzzer's 240 programs (seeds
1-40, 6 each) 0 failures, its counts unchanged; `tests/local.tcl` every
golden suite (122) on all four backends and every Tcl test file (299) on
interp and compile, 598 runs and 20,088 tests passed, 0 failures (taken
in four parts: the container restarted twice).

**CI of the fix.** **[test]** At `e18e11de`: tests.yml (run 43992559792),
macos-arm64.yml (43992569633, its main-thread startup job included: the
census's 8 MiB control holds `keep` 100,000 deep again),
windows-x86_64.yml (43992574209) and static-decisions.yml (43992578232)
succeeded; tests-arm64.yml (43992564924) failed in its two GC-stress jobs
only, every other arm64 job succeeding. Both failed in traits.test's
`trait-future-path-shape` and compilation-isolation.test's `ci-golden-pair`
(the same program, `traits-path.bot`): cranelift-generic panicked, "not a
program value". It reproduced on x86-64 under GC stress, and not with
`-scratch-opt 0`.

**The fresh-part finding.** **[probe]** The program builds a struct around
a String in a callee and reads the String back out through a function
returning `str` (`somewhere(w).parent().render()`), into its result. With
`-specialize 0` the callee chain is canonical functions, framed: the
program passed its destination down, the String was placed in the
program's region, and the program read it after the region's reset. The
fact was wrong whatever the backend: a call's fresh part is one abstract
object standing for every object the callee made (it contains itself), but
the solver gave it the result's kind, so render's String was never taken
to be it and its way into the result was lost. The fix and its detectors
are section 5's fourth row: an object that contains itself has a fixed
kind only as a String. The specialized backend never placed this String
(the struct result stays in registers, a companion with no frame), which
is why the census and the fuzzer, both specialized, missed it: the fuzzer
now keeps a String through a projecting function in every program and
runs cranelift-generic under GC stress (`generic`), and fails every program
without the fix. The census plans and its heap and scratch counts are
unchanged; the corpus's facts change only where the fix corrects them
(section 5). After the fix: the two failing tests pass under GC stress on
interp and compile; `tests/storage-lifetime.test` and
`tests/scratch-storage.test` pass; the lifetime oracle's selftest, its
fuzzer (200 programs, 0 unsound, every verdict precise), its C differential
(0 violations), the persistence check (identical to its record) and the
native reachability check (0 contradictions) pass.

**CI of the second fix.** **[test]** At `1d26dc9b`, dispatched: tests.yml
(run 44027592974), tests-arm64.yml (44027595731), macos-arm64.yml
(44027598498), windows-x86_64.yml (44027601055) and static-decisions.yml
(44027603637) -- pending.

## 25. Known limitations

* **Only flat Strings are placed.** Structs (p13's `Request`, 200 of its
  per-run heap allocations), Lists, MutableVector headers and backings,
  closures, coroutine objects and Bytes stay on the heap even where the
  facts confine them. Placing an object with outgoing references needs the
  collector to trace scratch objects (or a proof that what they reference
  is itself placed or static): a later milestone's design, not a flag.
  **[inference]**
* **A deferred construction materialized at a join is not matched.** p03:
  each branch's concatenation is materialized after the `if`, by an
  instruction whose origin is the join; the plan selects both sites but
  neither has an instruction of its own, so those Strings stay on the heap
  (p03: 3,000 heap allocations without scratch storage, 2,000 with).
  **[probe]**
* **Units that may suspend get no region.** A coroutine body's own
  temporaries (p07b's `gone`, p08, p12's actors) stay on the heap. A region
  live across a suspension would need storage owned by the coroutine, not
  the Vm's stack of regions: the execution-owner milestones' subject.
  **[design]**
* **Recursive units and units with a self tail call get no region.** A
  recursion's temporaries stay on the heap (`ss-plan-recursive`); a
  self-tail-calling loop's too (`ss-plan-self-tail`). A region's mark lives
  in the frame for the whole activation; storing marks in the provider
  instead (a stack of its own, pushed at a region's entry and popped at
  its exits) would make a region cost no frame space, and lift this
  restriction (section 26). **[design]**
* **Companion, region, `fields` and internal variants have no frame.** A
  String such a variant builds stays on the heap, and a call through a
  function value reaches the generic instance, which takes no destination.
  **[measurement]** In the fuzzer's corpus this is the largest gap: of
  3,563 sites the plan selected, 1,250 are in instances lowered only
  as a companion (a struct result returned in registers) or an internal
  variant (a closure's captures passed as parameters), and 939
  have no instruction of their own (the inner sites of a fused
  concatenation, whose one `construct` is placed, and virtual Strings).
* **Construction plans' own objects.** A unit whose result is a String
  plan (`StringPlan`) returns a heap object; its pieces may be placed, the
  plan object is not.
* **Destinations only for sites outside the callee's loops.** A callee's
  String built in a loop and returned is not placed in the caller's region
  (each iteration's would accumulate there).
* **Block sizes.** A placed String's block is its `str_layout` size,
  rounded to 8; the heap's byte counters count the exact size. Scratch
  bytes are therefore somewhat larger than the heap bytes they replace
  (p13's `inttostr`: 32 bytes per String in scratch against 27.45 on the
  heap). **[measurement]**
* **The fallback is opportunistic.** A String over 64 KiB, or past 64 MiB
  of reservations per Vm, goes to the heap; there is no bounded mode and no
  exhaustion behavior (brief section 9, kept for later).
* **One equivalent mutant.** The lowering's check that an instruction
  matched through a binding's use runs in the site's own innermost region
  (`ScratchLoopOf`) never rejects anything today (lowering materializes a
  binding a deeper loop reads before that loop): it is a guard, and its
  mutant is equivalent (section 19).

## 26. Recommended next milestone

**[inference]** The measurements (sections 17, 21-23) say compiler-managed
reuse is worth having where temporaries are many and short-lived: a placed
String saves 15 to 23 ns of heap allocation and collection, a frame costs
about 11 ns of runtime calls, and the steady state needs one chunk. The
remaining heap traffic of the positive workloads is not Strings but structs
(p13's `Request`) and what coroutine bodies build (p07b, p12); in generated
programs, Strings in companion and internal variants. In that light:

1. **STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-2** first: inline the
   mark and reset (the position as Vm words at fixed offsets, as the
   request and destination already are), keep marks in the provider (a
   stack of its own, pushed at a region's entry and popped at its exits,
   so that a region costs no frame space and recursive units can have
   regions again: section 25), frame companion and internal variants, place confined structs whose fields are Ints or placed
   Strings (the collector already
   skips scratch addresses; a placed struct with a heap reference needs a
   trace of scratch objects, or the restriction that every reference it
   holds is itself placed or static), match deferred constructions at
   joins (p03), and let a callee's loop-built result follow a destination
   where the caller's region is the loop's. Measure the 2048 and Icy Tower
   workloads, not only the census.
2. **STORAGE-EXECUTION-OWNER-CENSUS-1** next: where a coroutine
   construction, a thread entry or a request scope would own a region, and
   how the per-Vm stack of regions becomes per owner (a suspended
   coroutine's region cannot live on the Vm's stack). The provider's API
   (mark, reset, alloc with a policy) is the seam: nothing in the compiler's
   protocol assumes one stack per thread beyond "regions nest within a
   non-suspending segment".
3. The execution-owner configuration and the C backend's bounded storage
   after those, as the brief's sequence has them: the plan already names
   regions and sites backend-independently, so a C backend can read it for
   fixed scratch arrays and caller-provided storage.

**[design]** None of these is implemented here.
