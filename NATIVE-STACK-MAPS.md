# Native stack maps and native frame walking for GC

Second step of the native-stack-authoritative roadmap. The first step
(commit `c8be6d1`, `RootStorage::NativeFrame`) moved a *no-call* function's
root slots into its own Cranelift-managed native frame, published as a
single flat block (`Vm::native_roots_ptr`/`_len`) the collector could scan
directly. It deliberately left every calling/recursive function (including
`fib<int>`) on `RootStorage::RuntimeStack`, because nothing yet let the
collector discover a native frame's roots once another call nested on top
of it.

This step removes that restriction. On the primary (x86-64) path, **every**
function — called or not, recursive or not — now stores its GC roots in its
own native frame slots, discovered by the collector walking the machine
call stack and consulting a compact, PC-indexed stack-map table Cranelift
itself builds. `RuntimeStack` keeps exactly one job: a minimal, decoupled
one-slot recursion-depth bound for a function that can recurse, unrelated
to where its roots actually live. Nothing about stack-overflow protection
changes in this step.

No source-language semantics changed. `bench/*.ir`, `examples/stdlib/*.bot`,
and the whole existing test suite (1429 tests, both `interp`/`compile`
backend configurations) pass unmodified in outcome; the full suite also
passes under `BOTLISH_NATIVE_GC_STRESS=1` (1439 tests, including this
step's own additions).

## 1. Stack-map representation

`native/src/runtime/framemap.rs`:

```rust
pub struct FunctionMap {
    pub code_start: usize,          // absolute, JIT-only (see §2)
    pub code_end: usize,
    pub safepoints: Vec<(u32, Vec<u32>)>,  // (pc_offset, root byte offsets), sorted by pc_offset
}

pub struct ProgramMap {
    functions: Vec<FunctionMap>,    // sorted by code_start, binary-searched
}
```

Each `safepoints` entry is one Cranelift `call` the compiler proved is a GC
safepoint (`codegen::roots::is_safepoint`): `pc_offset` is a *function*-
relative return-address offset, and each root offset is a *frame*-relative
byte offset from that safepoint's own stack pointer. Nothing here is an
absolute process address, and nothing here is x86-64-specific — see §12 for
why that separation matters. `FunctionMap`/`ProgramMap` deliberately live in
`runtime/`, not `codegen/`: they're runtime-consumed metadata the compiler
produces, matching the codebase's existing dependency direction
(`codegen` → `runtime`, never the reverse; `runtime/mod.rs`'s own doc:
"Independent of Cranelift").

This is compact by construction: a function with zero root candidates
contributes zero safepoint entries at all (never "0 roots, still present" —
see `codegen::clif::Translator::mark_safepoint`'s guard), and a safepoint's
own entry lists only the physical slots F3's own greedy coloring says are
live *there* (`codegen::roots::RootPlan::safepoint_slots`), not every slot
the function ever uses.

## 2. PC-to-safepoint mapping

Cranelift 0.135.2 (this repo's pin) has a built-in, low-level mechanism for
exactly this: `ir::DataFlowGraph::append_user_stack_map_entry` lets a CLIF
producer attach `UserStackMapEntry{ty, slot, offset}` records to a specific
`call` instruction; the backend coalesces them per instruction into an
`ir::UserStackMap`, and (verified against `cranelift-codegen-0.135.2`'s
`machinst/buffer.rs`) the emitted PC recorded for it is **the return
address** — "the PC for the instruction just *after* this stack map's
associated instruction" (`MachBuffer::push_user_stack_map`'s own doc) —
exactly the convention `runtime::framewalk`'s frame-pointer-chain walk
needs (§5). A call with zero attached entries produces no stack-map record
at all: absence at a real return address means "zero live roots there," not
"unknown."

`codegen::clif::Translator::mark_safepoint(call: ir::Inst)` is the one
place these get attached: it looks up `self.current_index` (the NIR
instruction currently being translated) in `RootPlan::safepoint_slots` and,
if present, appends one entry per live physical slot to `call`. It is
reached from a single low-level choke point (`call_helper`, which every
allocating/runtime-helper call — direct or through `call_allocating` —
already passes through) plus the two direct-Botlish-call sites that bypass
it (`Inst::Call`/`Inst::CallEnv`, and `call_multi` for
`CallMulti`/`CallEnvMulti`). `self.current_index` is set to `usize::MAX`
outside `f.body` translation (i.e. during prologue codegen), so a
`prologue_depth_token` overflow's own `rt_stack_overflow` call can never be
mistaken for a real instruction's safepoint.

After compilation, `codegen::clif::define` pulls each function's stack maps
out of `ctx.compiled_code().unwrap().buffer.user_stack_maps()` (a
`&[(CodeOffset, span, ir::UserStackMap)]`) before `clear_context` drops
them, converting each `UserStackMap` via its own `entries()` iterator into
plain `(u32, Vec<u32>)` pairs — already fully resolved, SP-relative byte
offsets (Cranelift's own per-callsite `sp_to_sized_stack_slots` accounting,
so this needs no interpretation of frame layout on the compiler side at
all). `codegen::CraneliftJit::compile_actual` turns these into absolute
`FunctionMap`s once `finalize_definitions` makes real code addresses
available — the only point they exist for a JIT.

## 3. Frame-relative root locations from Cranelift

Unchanged from step 1: `codegen::clif::Translator::prologue_native_frame`
still allocates one Cranelift explicit stack slot per function
(`self.root_slot`) sized to `RootPlan::num_slots`, and `def`/`def_raw` still
store every rooted register's value there, at `slot*8`, on every
definition. What's new is that the *raw* `ir::StackSlot` handle is now kept
(not just its address, `self.base`) so `mark_safepoint` can describe it to
Cranelift; Cranelift's own `UserStackMap::entries()` then reports each
root's location as a byte offset from that safepoint's stack pointer,
already resolved through Cranelift's internal stack-slot layout — this
step never computes a stack-slot offset itself.

## 4. Current and caller frames: how they're walked

**Investigation, verified against generated code, not assumed:**

- Cranelift's x86-64 SysV backend unconditionally opens a function's frame
  with `push rbp; mov rbp, rsp` (`isa::x64::abi::X64ABIMachSpec::
  gen_prologue_frame_setup`, cranelift-codegen 0.135.2) whenever it emits a
  frame at all, which is every function with any safepoint (a safepoint
  always implies a `call`). Confirmed directly in this repo's own
  disassembly (`audit/native-scalar-asm/bench/fib.asm`): `botlish_fn_1`
  (`fib<int>`) begins `push rbp / mov rbp,rsp / sub rsp,0x30`, with nothing
  before the `push`.
- Rust code does **not** get this for free: `rt_cell_new` (a representative
  runtime helper) disassembles with no `push rbp` at all in a plain release
  build. `.cargo/config.toml` adds `-C force-frame-pointers=yes` for
  this crate's own build; the same helper then disassembles with the
  identical `push rbp; mov rbp,rsp` shape, confirmed by disassembling this
  crate's own release binary both ways.
- Given that shape, for any `call` from frame `A` into frame `B`:
  `[rbp_B + 0] == rbp_A`, `[rbp_B + 8] == A`'s own return address (a
  safepoint PC), and — since `call` plus `B`'s own `push rbp` together drop
  SP by exactly 16 bytes before `mov rbp,rsp` — `rbp_B + 16 == A`'s own SP
  at the moment of that call, which is exactly the SP `UserStackMap::
  entries()`'s offsets are relative to (no stack-passed call arguments are
  ever used here, so SP is unchanged across the call/return pair).

`runtime::framewalk::walk` (x86-64 only) reads the current `rbp` via
`core::arch::asm!` and ascends: at each step it treats `[rbp+8]` as a
return address, looks it up in `ProgramMap` (`roots_at`), reports
`rbp+16+offset` for every entry found, then moves to `[rbp+0]` and repeats.
GC only ever runs from `Vm::alloc`, reached only through a runtime-helper
call some Botlish frame itself made, so "the current frame" at the moment
of a collection is always some number of this crate's own Rust frames deep
inside a suspended Botlish call chain — the walk climbs through those first
(finding no roots there, since their return addresses are never in
`ProgramMap`) exactly as uniformly as it climbs through Botlish frames.

## 5. Botlish/native boundary termination

The walk does **not** stop at the first non-Botlish return address. A
`CallValue` dispatch (`rt_call_value` → `botlish_entry_N` → `botlish_fn_N`)
nests a genuinely foreign frame *between* two Botlish frames; stopping
there would find zero roots beneath it — silently losing every enclosing
caller's roots, not a safe conservative choice. Both a NIR function's
direct entry point and its generic entry trampoline are registered in
`ProgramMap` (the latter with an empty safepoint table: it roots nothing of
its own, but the walker must still recognize it as Botlish code and keep
climbing through it, not treat it as the boundary). The walk instead
terminates only at its own defensive backstops: `rbp == 0`, misalignment,
non-monotonic ascent (`saved_rbp <= rbp`, given the stack grows down), or a
hard `MAX_FRAMES` cap — reaching the true bottom of the native call stack
(the non-Botlish driver in `main.rs` that first called into compiled code)
in the well-formed case. `tests/native-stack-map.test`'s
`stack-map-callvalue-boundary-1`/`-2` exercise this directly.

## 6. GC updates roots in place

`runtime::framewalk::walk(map, visit: impl FnMut(*mut Value))` hands its
caller each live root's **address**, not just its value — `Vm::
collect_with` currently only reads through it (`unsafe { *addr }`, feeding
the same `Iterator<Item = Value>` every other root source already uses),
because `runtime::heap`'s collector is still non-moving (unchanged by this
step: "Objects never move" is its own module doc). Nothing about that read
prevents a future moving collector from instead writing an updated pointer
back through the same address as part of tracing — the mechanism is
already address-based, not value-based, precisely so relocation support
does not require touching this walk again.

## 7. Decoupling root storage from recursion-depth accounting

`codegen::roots::RootPlan` now carries two independent facts where it used
to carry one combined decision:

- `storage: RootStorage` — where this function's *root values* live.
  `plan(f, native_frame_supported)`: on the stack-map path
  (`native_frame_supported = true`, x86-64), **always** `NativeFrame`,
  regardless of `f`'s own calls; on the fallback path (no frame-walker),
  unchanged from step 1 — `NativeFrame` only for a function with no
  Botlish call, `RuntimeStack` otherwise (byte-for-byte the original rule,
  a deliberate safety net for a host this milestone doesn't implement the
  walker for).
- `depth_reservation: bool` — exactly `has_botlish_call(f)` (the same
  predicate step 1 used for eligibility, now repurposed): whether this
  function still reserves the shared shadow array's one-slot recursion-
  depth bound, **independent of `storage`**.

`codegen::clif::Translator::prologue_root_frame` reflects the split
directly: it runs `prologue_depth_token` (bump/check/zero/restore one
`RuntimeStack` slot, storing no Value) when `depth_reservation` is set,
*and, separately*, `prologue_native_frame` (allocate this function's own
root slots) when `storage == NativeFrame` — both, either, or neither can
apply to the same function. `restore_root_frame` restores each
independently. `fib<int>` is the flagship instance: `storage ==
NativeFrame` (its two cross-call roots move to native slots) *and*
`depth_reservation == true` (it can still recurse, so it still needs the
bound) — see `tests/native-stack-map.test`'s `stack-map-fib-1`.

The depth token itself is still zeroed at reservation (never left holding
stale bytes `is_pointer` could misinterpret as a root — `runtime::value::
is_pointer(0) == false` is the same safe sentinel `entry_zero`'s own root
slots already rely on), so it coexists with the ordinary shadow-stack scan
(`runtime::heap::collect_with`'s `stack` source) without ever contributing
a spurious root — see §11 on "no double-scanning."

## 8. `fib<int>`: before/after assembly

Full excerpts: `audit/native-scalar-asm/bench/fib.asm`
(`git diff audit/native-scalar-asm/bench/fib.asm` against this commit's
parent shows the whole thing). The load-bearing lines:

**Before** (RuntimeStack storage: `rbx` = this frame's base in the shared
shadow array, bumped by `0x10` = 2 slots for the 2 cross-call roots, no
separate depth accounting):

```asm
mov    rbx,QWORD PTR [rdi]        ; rbx = vm.ss_top
lea    rcx,[rbx+0x10]             ; +2 slots (roots AND depth, combined)
...
mov    QWORD PTR [rbx],rsi        ; root store: first call's argument
...
mov    QWORD PTR [rbx+0x8],rax    ; root store: first call's result
...
mov    QWORD PTR [rdi],rbx        ; restore vm.ss_top (pops both)
```

**After** (NativeFrame storage + a separate, minimal depth token):

```asm
mov    rbx,QWORD PTR [rdi]        ; rbx = vm.ss_top -- depth token ONLY now
lea    rcx,[rbx+0x8]              ; +1 slot: depth token alone
...
mov    QWORD PTR [rbx],0x0        ; the depth token is zeroed, never a root
...
mov    QWORD PTR [rsp],rsi        ; root store: now a Cranelift native slot
...
mov    QWORD PTR [rsp],rax        ; root store: same native slot, reused
...
mov    QWORD PTR [rsp+0x8],rsi    ; root store: second native slot
...
mov    QWORD PTR [rdi],rbx        ; restore vm.ss_top (pops the depth token only)
```

`rt_stack_overflow` is still imported and called on the overflow path in
both versions (`usesHelper`/`stack-map-fib-2`). No `Vm::native_roots_ptr`/
`_len` traffic appears anywhere in the new version — the stack-map path
never touches those fields at all (§9). Per-function machine-code size
(`fib.summary.txt`, per-function byte counts): `<program entry>` grew from
175 to 187 bytes, `fib<int>` itself from 505 to 513 bytes (program total:
680 → 700) — the depth-token bookkeeping and the extra callee-saved-spill
bytes from widening the frame by one word, not new hot-path work per call
(§11's benchmarks confirm no steady-state slowdown).

## 9. Root storage and recursion-depth decoupling: mechanism recap

See §7. One clarifying point: on the stack-map path, `RootStorage::
NativeFrame` no longer touches `Vm::native_roots_ptr`/`_len` **at all**,
for any function (called or not) — that publish/restore mechanism was
step 1's own discovery method for a no-call function; the frame-walker
subsumes it entirely (it can find a leaf function's roots through its own
stack map exactly as it finds a recursive function's). Those two `Vm`
fields, and the code path that writes them, are now exercised only on the
fallback (non-x86-64) path — see `codegen::clif::Translator::stack_maps`
and `prologue_native_frame`'s own doc.

## 10. Tests

`tests/native-stack-map.test` (new, 10 tests) plus updates to
`tests/native-root-storage.test` (2 result assertions changed from "stays
on RuntimeStack" to "now uses NativeFrame," reflecting this step's own
change; a third test's description updated to explain why its assertion
value, `rt_stack_overflow` present, is unchanged for a different reason
now). On the Rust side: all 22 of `native/src/codegen/roots.rs`'s
existing unit tests now exercise `plan`'s new `native_frame_supported`
parameter (most pinned to `true`, the primary path; two rewritten outright
to assert the new default explicitly against the old fallback behavior,
side by side), plus 5 new unit tests in `native/src/runtime/framemap.rs`
(3) and `native/src/runtime/framewalk.rs` (2). Covering the milestone's own list:

1. no-root function — `native-root-storage.test`'s `storage-no-roots-*`
   (native frame, zero slots, no `rt_stack_overflow`).
2. one native root at a safepoint — `storage-one-root-*`.
3. multiple roots — `storage-multi-root-*`.
4. slot coloring/reuse across different safepoints —
   `native-root-liveness.test`'s existing coverage (coloring itself is
   untouched by this step) plus `stack-map-slot-reuse-1` (two sequential,
   non-overlapping cross-call roots sharing one native slot, both correct
   under GC stress).
5. root live across a Botlish call — `storage-call-crossing-1`.
6. recursive `fib<int>` — `stack-map-fib-1..4` (storage, depth
   reservation, `rt_stack_overflow` retained, correct with and without GC
   stress).
7. allocating function under forced GC stress — `stack-map-deep-1..3`.
8. nested Botlish calls where GC occurs several frames deep —
   `stack-map-deep-2`/`-3` (recursion depth 40 and 200; every `concat`
   allocation at every level, both descending and returning, forces a real
   collection while that many frames are genuinely suspended).
9. moving/updating a rooted value in an older caller frame — the same
   `stack-map-deep-*` tests: each ancestor frame's own `prefix` string (a
   real heap object, never static, so it is genuinely collectible if
   un-rooted) must survive every descendant's allocations. The collector
   is non-moving today, so this demonstrates *preservation*, not
   relocation — see §6 for why the mechanism is relocation-ready anyway.
10. correct termination at a runtime/foreign boundary —
    `stack-map-callvalue-boundary-1`/`-2` (§5).
11. no double-scanning when native maps and legacy RuntimeStack coexist —
    verified by construction (§7's zeroed, root-free depth token; disjoint
    physical memory for native slots vs. the shadow array vs. `Vm::
    native_roots_ptr`) and by every correctness test above continuing to
    pass; a non-moving mark collector cannot behaviorally distinguish "a
    root was marked once" from "marked twice" (marking is idempotent), so
    this is not independently visible from program output the way 1-10
    are.

**Results:** `tests/all.tcl` (both `interp`/`compile` matrix
configurations): 1429/1429 before this file existed, 1439/1439 after
adding it, unchanged under `BOTLISH_NATIVE_GC_STRESS=1` (1439/1439, both
configurations).

## 11. Benchmarks

Best-of-N, JIT compile time excluded (`native::measure`); "before" =
`c8be6d1`/this commit's parent (rebuilt fresh in a separate worktree, same
Cranelift pin, same rustc), "after" = this commit. `.cargo/config.toml`
(force-frame-pointers) applies to both the runtime helpers *and* is a
build-time-only cost — it does not add instructions to any Botlish call.

| benchmark | before (native) | after (native) | delta |
|---|---:|---:|---:|
| `fib.ir` = `fib(22)` (best of 30) | 223.48 us | 168.43 us | -25% |
| `loop-count.ir` (best of 30) | 1.24 us | 1.40 us | +13% |
| `sum-refined.ir` (best of 30) | 1.32 us | 1.04 us | -21% |
| `build(400)` (recursive, allocating; best of 20; no GC stress) | 60.87 us | 52.45 us | -14% |
| `build(400)` under `BOTLISH_NATIVE_GC_STRESS=1` (best of 20; 16019 collections both runs) | 837.12 us | 3460.69 us | +313% |

`fib`/`sum-refined` recurse through real Botlish calls (`depth_reservation
== true`) and are non-allocating for these inputs (every arithmetic op
stays on its fast, non-call path), so they isolate the depth-token
mechanism and ordinary call/return shape from the collector; neither
regresses (both single best-of-30 samples land faster than before, well
outside plausible noise for a repeated pattern like this). `loop-count.ir`
is a *self* tail loop (`Inst::Tail`, a CFG back edge — codegen::clif's own
doc), never a real Botlish call, so `has_botlish_call` is false for it and
none of this milestone's codegen changes apply to it at all; its +13% is a
single best-of-30 sample's run-to-run noise, not a regression to explain.

`build(400)` isolates the collector itself: outside GC stress, the new
version is not slower (plausibly faster: one native-slot store plus a
1-slot depth check, versus the old combined 2-slot RuntimeStack
bump/store/store/restore) — steady-state, non-collecting execution is not
regressed, matching this milestone's own primary performance requirement.
*Under* forced GC stress, collection itself is markedly slower: each of the
16019 collections now performs a real rbp-chain walk (up to 400 frames
deep, this benchmark's own recursion depth) instead of scanning one flat,
contiguous shadow-array region. This is an honest, expected cost of moving
root discovery from an O(1)-region scan to an O(depth) frame walk, not a
steady-state per-call regression — no instruction was added to any
ordinary, non-colliding call — but it is a real trade-off worth flagging
for whoever picks up the next milestone (see §12).

## 12. Remaining `RuntimeStack` use, and what's left before removing it

`RuntimeStack` (the shared `Vm::shadow` array) still serves two roles:

1. **Root storage on the fallback path** (`codegen::roots::plan`'s
   `native_frame_supported = false`) — any host without
   `runtime::framewalk`'s x86-64 walker implemented. Nothing in this
   milestone runs that path today (this container, and the pinned
   Cranelift ISA selection, are x86-64), so it is exercised only by the
   Rust unit tests that pass `false` explicitly.
2. **The recursion-depth token** (`RootPlan::depth_reservation`) — for
   *every* function that contains a Botlish call, on *every* path,
   deliberately unchanged by this milestone ("do not solve or remove (3)
   yet").

What remains before (2) can be removed:

- A real stack-overflow/guard-page mechanism to replace the shadow array's
  bounds check — this milestone does not attempt it (`RuntimeStack`'s own
  `SHADOW_STACK_SLOTS` bound is still what protects native recursion depth
  for every calling function, `fib<int>` included).
- Once that exists, `depth_reservation`'s own one-slot
  bump/check/zero/restore sequence can be deleted from `codegen::clif`
  outright — nothing else depends on it: `storage`/`safepoint_slots` are
  already fully independent of it (§7), so this is a pure deletion, not a
  redesign, when it happens.

What (1) — the fallback path — would need to go away entirely: a verified
frame-pointer-chain argument (§4) for a second architecture (aarch64's own
frame-pointer register, `x29`, plus its own ABI's callee/caller-SP
relationship), or a DWARF/CFI-based walker if frame pointers are ever
omitted (see `runtime::framewalk`'s own doc on why that was not chosen for
this milestone, and why the compile-time metadata format does not
foreclose it: §1's `FunctionMap` mentions no register, x86-64 or
otherwise).

## Addendum: CI failure and fix (config-file discovery is CWD-based)

The first push of this milestone (commit `43aa3a1`) passed the full suite,
including under `BOTLISH_NATIVE_GC_STRESS=1`, in this session's own sandbox
— but failed CI with 39 test failures, many crashing with `child killed:
segmentation violation`, the rest producing corrupted values (e.g.
`root-retention-1` under-collecting, `stack-map-slot-reuse-1` reading one
root's slot into another's result). All were GC-stress/allocation-heavy
scenarios — exactly the ones that actually exercise `runtime::framewalk`.

Root cause: this session always built with `cd native && cargo build
--release`, so `native/.cargo/config.toml` was always discovered (CWD was
`native/`). CI, and this repo's own documented build command (`AGENTS.md`),
instead run `cargo build --release --manifest-path native/Cargo.toml` from
the **repo root**. Cargo's `.cargo/config.toml` discovery walks up from the
current *working directory* at invocation time — never from
`--manifest-path`'s directory — so that invocation never found the config
file at all, and `-C force-frame-pointers=yes` silently never applied.
Every runtime-helper frame the walker climbs through then lacked a
frame-pointer chain, so `runtime::framewalk::walk` read garbage at
`[rbp+0]`/`[rbp+8]` partway up the ascent: sometimes a wild pointer
(segfault), sometimes plausible-looking garbage misread as a root address
(silent corruption) — matching every observed symptom.

Confirmed empirically, not just reasoned about: with the config file still
at `native/.cargo/config.toml`, a *full, from-scratch* rebuild (every
dependency recompiled, cache eliminated as a variable) via `cargo build
--release --manifest-path native/Cargo.toml` run **from the repo root**
still disassembled `rt_cell_new` with no `push rbp` at all — proving this
was a config-discovery bug, not a stale-cache artifact.

Fix: moved the file to the repo root (`.cargo/config.toml`) — an ancestor
of both `native/` (so `cd native && cargo build` still finds it) and the
repo root itself (so `--manifest-path native/Cargo.toml` invoked from
there, matching CI and `AGENTS.md`, finds it too). Re-verified the same
way: a from-scratch build via the exact CI invocation now disassembles
`rt_cell_new` with `push rbp; mov rbp,rsp`, and the full suite (interp/
compile backends) plus every previously-failing GC-stress test passes
against a binary built that way.

## Files changed

- `.cargo/config.toml` (new; at the repo root, not `native/.cargo/`, for
  the reason in the addendum above): forces frame pointers for `native/`'s
  build.
- `native/src/runtime/framemap.rs` (new): the stack-map table (§1).
- `native/src/runtime/framewalk.rs` (new): the x86-64 frame walker (§4-5).
- `native/src/codegen/roots.rs`: `plan`'s `native_frame_supported`
  parameter, `RootPlan::depth_reservation`/`safepoint_slots` (§7).
- `native/src/codegen/clif.rs`: `mark_safepoint`, the depth-token prologue,
  `stack_maps`/`root_slot` fields, `DefineResult` (§2-3, §7).
- `native/src/codegen/mod.rs`: builds `ProgramMap` after
  `finalize_definitions` (§2).
- `native/src/runtime/vm.rs`: `Vm::framemap`/`set_framemap`,
  `collect_with`'s fifth root source (§6, §9).
- `native/src/runtime/heap.rs`: module doc update (five root sources, not
  four).
- `native/src/main.rs`: wires `compiled.framemap` into the `Vm`.
- `tests/native-stack-map.test` (new), `tests/native-root-storage.test`
  (updated for this step's own storage change).
- `audit/native-scalar-asm/`: regenerated (every program's machine code
  changed shape; see §8 for `fib<int>` specifically).
