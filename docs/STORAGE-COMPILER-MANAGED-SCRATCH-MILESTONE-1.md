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

«SEC1»

«SEC2»

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
  block (`str_layout`), allocated by `Vm::alloc_str` and nothing else; the
  collector never scans a String's text. Every String-producing helper the
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
  representable site; it blocks units that may suspend and units the
  backend excludes (a self tail call reuses its frame), and gives a
  recursive unit no destination.

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
every natively compiled program, exposed three defects in
`hir/lifetime.tcl`: two unsound facts, each a native use of released
memory under GC stress, and a summary fixpoint that never converged (a
compilation failure). Each is fixed in the analysis, not worked around in
the plan, and pinned by a test that fails without its fix:

| fact | defect | failure observed | fix | test |
|---|---|---|---|---|
| an error a call lets through | the payload of a declared error a callee may fail with (an argument the callee puts in the payload) was not an escape of the caller's unit | tests/error-payloads.test's `ep-gc-stress`: a payload String read after its region was reset | the call's let-through errors get an `error` sink (`perr`), and the callee's error may hold what its arguments reach | `sl-error-let-through` |
| a fresh result's contents | a callee's fresh result (a struct it builds) was taken to hold only objects of its own kind, not the parameter-reaching objects it stores | tests/golden-framework.test: EILSEQ and NATIVE BUG -- a String the caller placed, stored by a callee into the struct it returns, released with the caller's region while the struct lived on | `fresh` results contain what their result-reaching parameters reach (`Add contents`) | `sl-fresh-holds-parameter` |
| recursive reasons | a recursive component's escape reasons grew a step every round (the reason text named the previous round's), so the summaries never reached a fixpoint | tests/event-loop.test: "no summary fixpoint" | a summary keeps the first reasons found (`KeepReasons`) | `sl-recursive-reasons-converge` |

**[test]** `tests/storage-lifetime.test`: 66 tests (63 of milestone 1, the
three above), passing. The facts of milestone 1's corpus are otherwise
unchanged (section 19 reruns its oracle).

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

**[inspection]** Recursion: a recursive unit's activation-confined
temporaries are placed in its own frame, released at each activation's exit
(`ss-plan-recursive`, `ss-run-nested`'s recursion); a recursive unit never
takes a destination, since a recursion's leftovers would pile up in the
outermost caller's region.

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

**[probe]** The instruments detect a premature reset: each of the
lifetime defects of section 5, reintroduced, gives a NATIVE BUG or EILSEQ
under poisoning in 8 of 8 generated programs (the fuzzer's positive
control); every surviving-candidate mutant of section 19 that releases a
live String fails a test this way.

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

# What lowering emitted
  raw<int>: call of std::int::to_string at p13-request-handler.bot:16:26: emitted (1 instruction(s))
  raw<int>: call of std::str::concat at p13-request-handler.bot:16:5: not emitted -- no instruction of its own (virtual, inlined or a companion call)
  raw<int>: call of std::str::concat at p13-request-handler.bot:16:5: emitted (1 instruction(s))
  handle<int>: call of raw at p13-request-handler.bot:39:15: emitted (1 instruction(s))
```

The census summary (`results/plans/summary.md`):

| program | units | framed | String sites | selected | emitted | not emitted | rejected: not confined | rejected: unit has no region | rejected: not representable |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| p01-sequential-temps | 2 | 1 | 4 | 4 | 4 | 0 | 0 | 0 | 0 |
| p02-simultaneous-temps | 2 | 1 | 5 | 5 | 3 | 2 | 0 | 0 | 0 |
| p03-exclusive-branches | 2 | 1 | 4 | 4 | 2 | 2 | 0 | 0 | 0 |
| p04-loop-reuse | 2 | 1 | 2 | 1 | 1 | 0 | 0 | 0 | 1 |
| p05-escape-result | 3 | 2 | 4 | 4 | 4 | 0 | 0 | 0 | 0 |
| p06-retained-aggregate | 2 | 0 | 6 | 0 | 0 | 0 | 2 | 0 | 4 |
| p07-across-suspension | 3 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 3 |
| p07b-string-across-suspension | 4 | 1 | 7 | 1 | 1 | 0 | 0 | 4 | 2 |
| p08-two-coroutines | 4 | 0 | 7 | 0 | 0 | 0 | 0 | 0 | 7 |
| p09-nested-yield | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 2 |
| p10-handle-moved | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 2 |
| p10b-handle-returned | 4 | 0 | 4 | 0 | 0 | 0 | 1 | 0 | 3 |
| p11-context-state | 4 | 0 | 4 | 0 | 0 | 0 | 0 | 0 | 4 |
| p12-actor-messages | 178 | 0 | 249 | 0 | 0 | 0 | 137 | 44 | 68 |
| p13-request-handler | 5 | 4 | 18 | 17 | 11 | 6 | 0 | 0 | 1 |
| p14-errors-early-exit | 3 | 2 | 6 | 4 | 4 | 0 | 1 | 0 | 1 |
| p15-bounded-collections | 4 | 0 | 7 | 0 | 0 | 0 | 2 | 0 | 5 |
| p16-foreign-noescape | 2 | 0 | 4 | 0 | 0 | 0 | 1 | 0 | 3 |
| p16b-foreign-captures | rejected by the compiler | | | | | | | | |
| p17-explicit-return | 3 | 0 | 5 | 0 | 0 | 0 | 2 | 0 | 3 |
| p18-persist-precision | 4 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 3 |
| p19-context-scratch-vector | 2 | 0 | 4 | 0 | 0 | 0 | 0 | 0 | 4 |

A blocked unit's report says why (p07b: `unit worker<int> -- no region:
it may suspend: a region is never live across a suspension`).

## 16. Generated NIR examples

**[probe]** `native::nir` of p01's `label` (scratch on). One frame, four
requests, the reset before the `ret` and on the error exit:

```
func 1 "label" params=1 env=0 regs=23 pnames="i" captures=0 instance="int" rawregs="5 7 8" @e81
    %16 = op scratchmark
    %15 = int 1
    pusherrorexit L0
    %17 = op scratchreq %15
    %1 = op inttostr %0 @e85
    %2 = str "-a" @e88
    %18 = op scratchreq %15
    %3 = op strcat %1 %2 @e92
    %4 = op strlen %3 @e90
    ...
    %19 = op scratchreq %15
    %10 = op inttostr %9 @e96
    %11 = str "-b" @e102
    %20 = op scratchreq %15
    %12 = op strcat %10 %11 @e108
    %13 = op strlen %12 @e106
    %14 = op iadd %4 %13 @e103
    %21 = op scratchreset %16
    ret %14
  label L0
    poperrorexit
    %22 = op scratchreset %16
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
    %24 = op scratchmark
    %23 = int 1
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
    %25 = op scratchreq %23
    %17 = op inttostr %16 @e94
    %18 = op strlen %17 @e105
    ...
  label L4
    %22 = op scratchreset %8 @e82
    %26 = op scratchreset %24
    ret %4
  label L5
    poperrorexit
    %27 = op scratchreset %24
    reraise
```

p13: `handle` passes a destination to each callee; `raw` takes it and
exits with `scratchexit`; the early `return 0` of the BadRequest handler
resets too:

```
func 1 "raw" params=1 env=0 regs=12 pnames="i" captures=0 instance="int" @e81
    %6 = op scratchtake
    %7 = op scratchmark
    %5 = int 1
    pusherrorexit L0
    %1 = str "GET /items/" @e86
    %8 = op scratchreq %6
    %2 = op inttostr %0 @e87
    %3 = str " HTTP/1.1" @e90
    %9 = op scratchreq %6
    %4 = construct str flat %1 %2 %3 @e82
    %10 = op scratchexit %7 %6
    ret %4
  ...
func 4 "handle" params=1 env=0 regs=17 pnames="i" captures=0 instance="int" rawregs="6" @e166
    %10 = op scratchmark
    %9 = int 1
    pusherrorexit L4
    pusherrorexit L0 @e168
    %11 = op scratchdest %9
    %2 = call 1 %0 @e171
    %12 = op scratchdest %9
    %3 = call 2 %2 %0 @e169
    ...
  label L2
    cleardeclarederror @e168
    %5 = int 0 @e176
    %6 = rawint 0
    %13 = op scratchreset %10
    ret %5 @e175
  ...
  label L1
    %14 = op scratchdest %9
    %7 = call 3 %1 @e179
    %8 = op strlen %7 @e177
    %15 = op scratchreset %10
    ret %8
```

**[inspection]** Machine code: `scratchreq` and `scratchdest` emit no
instruction of their own; the request is two stores around the helper call
(`codegen::clif`'s `call_allocating`: the 32-bit request word set before the
call, cleared after it), the destination a store before `Inst::Call` and one
after. `scratchtake` is a load, a store of 0 and a tag. `scratchmark`,
`scratchreset` and `scratchexit` are runtime calls (`rt_scratch_mark`,
`rt_scratch_reset`, `rt_scratch_exit`).

«SEC17-24»

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
* **Recursive units take no destination; units with a self tail call get
  no frame.** A recursion's result-only Strings stay on the heap; a
  self-tail-calling loop's temporaries too (`ss-plan-self-tail`).
* **Companion, region, `fields` and internal variants have no frame.** A
  String such a variant builds stays on the heap, and a call through a
  function value reaches the generic instance, which takes no destination.
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
reuse is worth having where temporaries are many and short-lived: it
removes allocations and collections without measurable cost per placed
String, and the steady state needs one chunk. The remaining heap traffic of
the positive workloads is not Strings but structs (p13's `Request`) and
what coroutine bodies build (p07b, p12). In that light:

1. **STORAGE-COMPILER-MANAGED-SCRATCH-MILESTONE-2** first: place confined
   structs whose fields are Ints or placed Strings (the collector already
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
