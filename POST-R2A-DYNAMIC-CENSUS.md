# Post-R2.a: frozen-baseline dynamic census

Audit only. No production compiler, runtime or `web::emailish?` source
change. Raw data, tools and reproduction steps:
[`audit/post-r2a-dynamic-census/`](audit/post-r2a-dynamic-census/README.md).

## Outcome

**Almost none of the cost is `callvalue` dispatch. Most of it is building
one-character Strings nobody keeps.** On the frozen `bench/refined-checks.ir`
(`[400, 0]`), one steady-state run executes **8,561,426 instructions**.
Only 15.8% of them are generated Botlish code. The largest items:

| rank | cost center | Ir/run | share |
|---:|---|---:|---:|
| 1 | one-character String materialization (`char_at` → `rt_substr`, 8,000 Strings) | 4,762,616 | **55.6%** |
| 2 | predicate work under `callvalue` (`local_char?` on a String, `is_tcl_alpha`) | 1,426,400 | 16.7% |
|   | … of which `immutable_set_contains` (1,200 calls, 632 Ir each) | 758,400 | 8.9% |
| 3 | direct-path StringRegion traversal (`domain?`, the `"@"` check) | 742,800 | 8.7% |
| 4 | `callvalue` dispatch itself (call site + `rt_call_value` + trampoline) | 506,000 | **5.9%** |
| 5 | UTF-8 re-seek from byte 0 (46,000 bytes walked) | ~500,000 | 5.8% |
| 6 | `local_char?` closure allocation (800 Blocks) | 283,500 | 3.3% |
| 7 | generic `check` (lost `n ∈ [0,400]`) | ≤21,622 | 0.25% |

The allocation cost continues after the run ends. The 8,823 objects a run
allocates are reclaimed by the between-run `Vm::reset`, which the standard
methodology (bench timing and the callgrind toggle alike) excludes. That
reclamation costs another **2,621,775 Ir per run: 297 Ir per object, +30.6%**.

**Callvalue does block StringRegion, but only for one of the two predicates.**
The frozen tree was compiled with the predicate target made statically exact,
by hand, in a scratch worktree (never the tree's source). The *unmodified*
compiler then:
* keeps the 1,200 `is_tcl_alpha` characters as regions (`is_tcl_alpha` is an
  existing region consumer);
* flattens `local_char?`'s capture, so all 800 closure allocations disappear;
* still materializes all **6,800** `local_char?` characters.

`local_char?` calls `immutable_set_contains` on a captured set, and set
membership is not a StringRegion consumer. So exact-target knowledge alone
cannot reach the largest cost. Measured result of that counterfactual:
**8,561,426 → 6,870,845 Ir (−19.7%)** and 660 → 522 µs wall-clock
(median).

Every other candidate's measured ceiling is small:

| candidate | measured ceiling |
|---|---:|
| static module values | 3.6%, of which 3.3% overlaps the exact-target counterfactual |
| range↔blockescape | ≤ 2.1% (upper bound) |
| R3 tiny `char_at` calls | ~3–4% |
| tagged Int in generated code, total | 1.7% |
| completion checks | 0.8% |
| frame / calling convention, in generated code | ~6.9%, diffuse over every call |

**Recommended next milestone: higher-order exact-target
provenance.** It is a finite callable-target theorem for `scan_while`'s
`predicate`, and it is the only compiler candidate with a large *measured*
ceiling using existing machinery (19.7%). It is also the prerequisite for
the one remaining cost larger than itself: the 6,800 local-part
materializations (44.7%). They become reachable only once the consumer is
visible; a follow-up that teaches StringRegion set membership, or a runtime
one-scalar String fast path, then needs that visibility. Its precondition
already exists: `scan_while` is **already proven closed** by M7.c's
`InstanceClosed` (blockescape's call-only proof). The honest weakness is
generality: this is the corpus's only `callvalue` site. See
[Recommended next milestone](#recommended-next-milestone).

Four statements in earlier reports were checked against measurements and
**are wrong**; they are recorded here, not silently used. Only the first
two are corrected in the R2.a.3 report itself, as this milestone
requested:
1. R2.a.3 said `label_char?` still flows through `scan_while` (corrected).
2. R2.a.3 said `scan_while.start`/`domain?.start` are the induction
   variables (corrected).
3. `label_char?` is **not** folded into `domain?` by the tiny exact-leaf
   inliner, as both R2.a.3 and this milestone's brief state. It is folded by
   StringRegion's region-consumer lowering (`EmitRegionConsumerBody`):
   `-tiny-leaf-inline-opt 0` leaves it folded, while `-string-region-opt 0`
   brings it back as `func "label_char?" instance="str"`.
4. R2.a.3's NIR table reports `callmulti` 2 → 0 and `guard` 5 → 3. The NIR
   says 2 → **4**: `domain?` gained three region-companion calls to
   `char_at`. The `guard` figure mixed counting methods: like for like it is
   5 → 4 (guard + guardbool).

## Frozen baseline identity

| | |
|---|---|
| tree | `6dbcfdb3d62e7870363d2af4fe0dfab7e58ad80c`: the R2.a.3 source freeze `05ae3d8`/`c4024de`, plus two audit-corpus regenerations that touch no compiler, runtime or library file |
| `lib/web.bot` | algorithm and code unchanged. The only diff is the item-2-permitted comment correction below; NIR is byte-identical before and after |
| benchmark | `bench/refined-checks.ir`, unmodified; result `[400, 0]` (`value {list {{int 400} {int 0}}}`) on every backend |
| host | Intel Xeon @ 2.10 GHz, 4 vCPU shared cloud container, Linux 6.18, glibc 2.39 |
| tools | Tcl 9.0.1, rustc/cargo 1.98.1, valgrind 3.22.0, Python 3.11.15, binutils 2.42 |
| native build | `cargo build --release` (`[profile.release] debug = 1`), unmodified `native/` |

## Drive-by R2.a.3 corrections

Both requested corrections were made in `R2A3-COUNTED-LOOPS-FINAL-SOURCE.md`.
Each mistaken statement appears there twice, once in the body and once in
the required-question answers, and both occurrences were corrected:

1. *"`local_char?`/`label_char?`/`is_tcl_alpha` still flow through it"*
   ("Post-freeze compiler findings"), and the same claim in "`scan_while`
   rewrite" (*"all flow through it exactly as before"*), now read:
   `local_char?` and `is_tcl_alpha` flow through it; `label_char?` no longer
   does.
2. *"`scan_while.start`'s and `domain?.start`'s own induction variables
   (`i`/`j`)"* ("Range facts before/after"), and the same wording in answer
   41, now read: `scan_while`'s `i` and `domain?`'s `j` induction bindings.
   These are countloop-local bindings, distinct from the `start` parameters.

No measured result or Range fact was changed.

`lib/web.bot`'s own `scan_while` comment reproduced correction 1's mistake:
it listed `local_char?/label_char?/is_tcl_alpha` as the predicates passed to
`PREDICATE`. As item 2 explicitly permits, that comment now names
`local_char?` and `is_tcl_alpha`. It is a comment-only, four-line,
line-count-preserving change. The following are byte-identical before and
after:
* NIR, for the benchmark and all four probes;
* the deterministic baseline;
* the allocation-site table (source line numbers included).

No other report text was changed. Findings 3 and 4 in the Outcome are
recorded here instead, per items 48–49.

## Audit tooling architecture

The post-M8.a path was audited against the current tree rather than
assumed:

* `native/src` is **byte-identical** from M8.a (`e84f102`) through the
  frozen tree (`git diff --quiet`). The post-M8.a patch still applies
  cleanly, and one audit binary can profile the NIR of every historical
  tree from R2 on.
* JIT code has no symbols. `BOTLISH_AUDIT_JITMAP` (unchanged patch) dumps
  every NIR function's direct and generic-entry address ranges and bytes.
  Callgrind's `--dump-instr=yes` addresses are mapped onto them per
  instruction.
* The measured region is delimited by `--toggle-collect=botlish_audit_run`,
  a named, never-inlined frame around each timed program run (unchanged
  patch). It excludes JIT compilation and the between-run `Vm::reset`.

Audit-tool changes, all in `audit/post-r2a-dynamic-census/tools/`; the
post-M8.a tools themselves are unchanged:

| change | why |
|---|---|
| `audit-native.patch` = the post-M8.a patch plus `BOTLISH_AUDIT_SKIP_FIRST` | run 0 is not representative: per-run Ir fell with the run count (10 runs 8.78M, 40 runs 8.62M). The data fit a one-off ~2.17M-Ir first-run surcharge, most likely the first run allocating from a fresh malloc arena where later runs reuse chunks freed by `Vm::reset`. With run 0 outside the frame, 10, 20 and 40 collected runs agree to within 350 Ir |
| `audit-native.patch`: `botlish_audit_reset` frame around the between-run `Vm::reset` | measures deferred reclamation on its own |
| `cgcensus.py` (new) | exact in-region call counts, self/inclusive per function, per-caller helper cost, the `callvalue` split, addr2line inline attribution. See the next row for the call-count issue |
| call counting | callgrind gates *costs* by the toggle but **not the `calls=` counters**, which are process-wide. For example, `__rust_dealloc → free` shows ~19,700 "calls" per run at a total of 4,330 Ir: those are `Vm::reset`'s frees. `cgcensus.py` therefore counts each call arc by the in-region execution count of its call instruction, and each function by that of its entry instruction |
| `profile-nir.sh`, `emit-nir.tcl`, `baseline.tcl` | take NIR / run from the current directory, so one tool serves the frozen tree, the probes, the historical worktrees and the counterfactual alike |

## Audit build validation

`tools/validate-audit.sh` compares the production and audit binaries on
**every profiled program**: frozen, four historical trees, five probes and
two counterfactuals. All of the following are identical on all of them:

| check | frozen | all others |
|---|---|---|
| program value | `[400, 0]` identical | identical |
| `size` (total + per-function bytes) | 10,258 identical | identical |
| relocatable object file (`object`) | byte-identical | byte-identical |
| VCode | identical | identical |
| allocation counters (`--alloc summary`) | identical | identical |
| allocation site table (`--alloc sites`) | identical | identical |
| JIT map covers every byte `size` counts (direct + entry per function) | yes | yes |

* **Generated code is unchanged.** The patch touches only the bench harness
  and a post-finalization read of JIT memory, never code generation or a
  runtime helper.
* **The collected region is exactly the program run.** Collected Ir outside
  Botlish-reachable code is 6 Ir/run (the frame itself), and no Cranelift
  function has any cost.
* **Attribution is complete.** Unattributed JIT code is 0: kind `other` is
  1 Ir per run. The two `char_at` companion variants are separate NIR
  functions (10: region companion, `results=3`; 11: materializing) and are
  attributed separately.
* **Repeatability.** Six frozen profiles give 8,561,426 / 8,561,152 /
  8,561,151 / 8,561,488 (10 collected runs) / 8,561,144 (40 collected runs)
  / 8,561,139 (after the reset-frame rebuild), all within 350 Ir (0.004%). All
  call, allocation and site counts are exact.
* **Consistency with the earlier census.** The pre-R2 tree reproduces the
  post-M8.a census's own figure within 0.14% (5,430,486 vs 5,437,827, which
  included run 0).

GC: in-run collections are 0 in every profile, with or without the
instrumentation (`timing … 0`). The only collections are the between-run
resets.

## Measurement methodology

* **Primary metric:** callgrind Ir per steady-state run. `bench 21` runs 21
  times and collects runs 1–20 (`BOTLISH_AUDIT_SKIP_FIRST`); every figure is
  divided by 20. Simulation: `--cache-sim=yes --branch-sim=yes`.
* **Attribution:**
  * Generated code is attributed by JIT map, per function and per
    instruction.
  * Rust helpers by symbol, with helper self cost split by inlined source
    line (addr2line `-i`). This is how the UTF-8 seek, the substring copy
    and the `rt_call_value` dispatch layers were separated.
  * Generated-code instruction classes use post-M8.a's classifier,
    unchanged: frame, tag test, overflow check, Bool word, completion check,
    stack store, moves, calls and so on.
* **Deferred reclamation** is measured separately (`botlish_audit_reset`)
  and never mixed into the primary column.
* **Controls:** four single-input probes (`probes/*.ir`), the post-M8.a ASCII
  probe, four historical trees and two counterfactuals, all through the same
  binary and method.
* **Wall-clock** is a sanity control only: production binary, 7 interleaved
  sessions × 200 runs, JIT excluded, plus three canonical `bench.tcl`
  sessions.

## Deterministic baseline reproduction

`audit/post-r2a-dynamic-census/baseline/frozen-r2a3.txt`, fresh on the frozen
tree:

| | R2.a.3 report | measured | |
|---|---:|---:|---|
| used instances | 26 | 26 | ✓ |
| compiled functions | 24 | 24 | ✓ |
| machine bytes | 10,258 | 10,258 | ✓ (per function identical to the committed asm audit) |
| NIR lines | 688 | 688 | ✓ (`llength [split $nir \n]`; `wc -l` gives 687) |
| call / callenv / callvalue / tail / tailenv | 21 / 3 / 1 / 3 / 0 | 21 / 3 / 1 / 3 / 0 | ✓ |
| callmulti | 0 | **4** | ✗: four `%a %b %c = callmulti 10 …` region-companion calls (`emailish?` ×1, `domain?` ×3). R2.a.2 had 2 |
| guard | 3 | 3 guard + 1 guardbool | the report counted guardbool at R2.a.2 (5 = 4 + 1) but not at R2.a.3 |
| closure / capture / fnvalue | 4 / 5 / 0 | 4 / 5 / 0 | ✓ |
| allocations | 8,823 | 8,823 | ✓ |
| String / Block / List / ImmutableSet / StringPlan | 8,004 / 803 / 12 / 2 / 2 | 8,004 / 803 / 12 / 2 / 2 | ✓ |
| UTF-8 seek bytes | (not reported) | 46,000 | |
| OpenInstances | web::emailish? region all open | 13 open, 9 of them blockescape-flattened | |
| `check.n` | `[-∞, +∞]` | `[-∞, +∞]` | ✓ |
| `scan_while` `i`, `domain?` `j` | max bounded | `[-∞, 4611686018427387902]` both | ✓ |

The historical trees reproduce their own reports too:
* pre-R2: 15,187 B, 33 functions, 20 allocations;
* R2: 9,868 B, 24 functions, 20 allocations, 56,000 seek bytes;
* R2.a: 9,490 B, 11,620 allocations;
* R2.a.2: 10,027 B, 10,023 allocations.

## Wall-clock control

Production binary; median of 7 session-bests of 200 runs each (µs, JIT
excluded; `baseline/wallclock.md`):

| program | median session-best | best | median of all runs | Ir/run |
|---|---:|---:|---:|---:|
| pre-R2 | 305.2 | 249.7 | 327.7 | 5,430,486 |
| R2 | 205.3 | 167.7 | 220.2 | 3,461,691 |
| R2.a | 727.3 | 705.4 | 929.8 | 10,967,390 |
| R2.a.2 | 726.0 | 613.0 | 788.0 | 9,375,454 |
| **R2.a.3 frozen** | **660.3** | 552.3 | 729.3 | **8,561,426** |
| counterfactual: exact target | 521.8 | 445.3 | 575.2 | 6,870,845 |
| counterfactual: StringRegion off | 812.1 | 672.2 | 896.5 | 10,522,019 |

Canonical `bench.tcl -runs 5`, three sessions: Cranelift 559.5 / 770.5 /
707.2 µs, with every backend returning `[400, 0]`. Session spread is
±15–25% on this shared host. The ordering matches Ir in every row, but
frozen runs slower per instruction (77 ns/kIr) than R2 (59). That is
consistent with its malloc-heavy profile (94% of its L1 data misses are in
`_int_malloc`). Nothing below rests on a timing difference.

## Total Callgrind Ir

**8,561,426 Ir per steady-state run** (±350). Other events per run: 1.80M
data reads, 1.39M data writes, 1.28M conditional branches (46K
mispredicted), 92.6K indirect branches, 9.7K L1d read misses (9.2K of them
in `_int_malloc`).

Deferred, outside that figure: **2,621,775 Ir** of reclamation per run.

## Generated vs runtime share

| code kind (exclusive) | Ir/run | share |
|---|---:|---:|
| generated Botlish code (JIT) | 1,354,535 | **15.8%** |
| runtime helpers (`botlish_native::runtime`) | 3,826,384 | 44.7% |
| libc (malloc/realloc/memcpy/memcmp) | 2,331,306 | 27.2% |
| Rust std inlined out of helpers (allocation shims, `String::from_iter`, `RawVec` growth) | 1,049,201 | 12.3% |
| audit harness inside the region | 6 | 0.0% |

## Per-function dynamic attribution

Invocations are exact entry-instruction counts. Self Ir is the function's
own instructions (direct body + generic entry). Inclusive Ir is self plus
everything it calls.

| function | invocations | self Ir | inclusive Ir | incl % | notes |
|---|---:|---:|---:|---:|---|
| `check` | 2 (802 self-tail iterations) | 46,880 | 8,547,004 | 99.83 | `check<generic>` |
| `web::emailish?` | 800 | 76,800 | 8,500,124 | 99.28 | via `callenv` |
| `scan_while` | 1,200 (8,800 loop headers, 8,000 bodies) | 423,200 | 7,270,216 | 84.92 | 800 from `emailish?` (incl 5,781,566), 400 from `tld?` (incl 1,488,650) |
| `char_at` (fn 11, materializing) | 8,000 | 272,000 | 5,034,616 | 58.81 | only caller: `scan_while` |
| `domain?` | 400 | 103,200 | 2,265,450 | 26.46 | 752,000 excluding `tld?` |
| `tld?` | 400 | 24,800 | 1,513,450 | 17.68 | |
| `local_char?` | 6,800 (all through `rt_call_value` → generic entry) | 229,600 + 47,600 (entry) | 1,405,600 | 16.42 | |
| `char_at` (fn 10, region companion) | 2,800 | 128,800 | 235,200 | 2.75 | callers `domain?` 2,400, `emailish?` 400 |
| `label_char?` | 0 calls, 800 folded evaluations | (in `domain?`) | (in `domain?`) | | folded by StringRegion's region-consumer lowering, not the tiny-leaf inliner |
| `is_tcl_alpha` (native) | 1,200 (through `rt_call_value`) | 21,600 inlined into `rt_call_value` | 68,400 | 0.80 | plus 75,600 native dispatch |
| `web::uri_escape_text` + helpers | 1 | 24 | 7,358 | 0.09 | startup |
| `web::is_unreserved` | 3 | 76 | 549 | 0.01 | startup |
| `byte::set` | 1 | 276 | 2,713 | 0.03 | startup |

Attribution is ambiguous in three places, and each was resolved as follows:
* `label_char?` has no frame of its own, so its cost is inside `domain?`.
* `is_tcl_alpha`'s classification is inlined into `rt_call_value`. It is
  separated by addr2line inline chains: 21,600 Ir of work vs. 338,400 Ir of
  dispatch.
* `rt_substr` inlines `to_string` and the UTF-8 seek, and was split by
  source line.

## Runtime-helper attribution

Calls from generated code, ranked by inclusive Ir:

| helper | mechanism | calls | Ir/call | inclusive Ir | share |
|---|---|---:|---:|---:|---:|
| `rt_substr` | one-char String materialization (8,000 hot + 3 startup) | 8,003 | 595.2 | 4,763,548 | 55.6% |
| `rt_call_value` | `callvalue` dispatch (+ callee work beneath) | 8,000 | 226.6 | 1,812,400 | 21.2% |
| `rt_set_contains` | set membership: linear scan, generic `equal` ×5 | 1,201 | 631.7 | 758,659 | 8.9% |
| `rt_is_tcl_alnum` | String classification (`one_scalar` + Unicode table) | 6,800 | 54.4 | 370,000 | 4.3% |
| `rt_str_region_eq` | region equality (non-ASCII seek + char compare) | 2,000 | 183.4 | 366,800 | 4.3% |
| `rt_closure_new` | closure allocation | 803 | 342.5 | 275,037 | 3.2% |
| `rt_str_region_is_tcl_alnum` | region classification | 800 | 176.0 | 140,800 | 1.6% |
| `rt_str_region_check` | region bounds check | 2,800 | 38.0 | 106,400 | 1.2% |
| `rt_str_len` | length | 810 | 11.0 | 8,910 | 0.1% |
| startup (`rt_construct`, `rt_set_from_list`, `rt_list_new`, …) | module init / `uriEscape("a b")` | ~20 | | ~11K | 0.1% |

The same Ir regrouped by mechanism (inclusive; the groups do not overlap):
* **String materialization:** 4,762,616. Beneath it:
  * `Vm::alloc<StrObj>` 1,321,460 (Box + heap registration + malloc);
  * ASCII `to_string` malloc 502,981;
  * non-ASCII `String::from_iter` 878,800;
  * `str_object`'s shrinking `realloc` 617,600;
  * UTF-8 seek 256,000;
  * `rt_substr`'s own bounds/copy logic.
* **UTF-8 seeking**, all helpers: ~500,000.
* **callvalue dispatch:** 338,400 (`rt_call_value` self, excluding inlined
  callee work).
* **Closure allocation:** 275,037.
* **Set membership:** 758,659.
* **Region/String equality:** 366,800 on regions. Materialized
  `rt_str_eq` has 0 hot calls.
* **Tagged-Int fallback helpers (`rt_int_*`):** 0 hot calls; the only one
  is `rt_int_mod`, once, at startup.
* **Type guards/errors:** `guard str` inside `local_char?`/`emailish?`,
  and `guardbool` after `callvalue`. No error path executes.
* **Allocation helpers:** listed above.
* **Root/GC helpers:** 0 in-run.

No helper's cost can be inferred from allocation counts. The most expensive
per call is `rt_set_contains`, which allocates nothing.

## Hot call graph

| callee | call form | dynamic calls/run | caller(s) | inclusive Ir |
|---|---|---:|---|---:|
| `check` | `call` | 2 | `<program>` | 8,547,004 |
| `web::emailish?` | `callenv` | 800 | `check` | 8,500,124 |
| `scan_while` | `call` | 800 / 400 | `emailish?` / `tld?` | 5,781,566 / 1,488,650 |
| `char_at` (materializing) | `call` | 8,000 | `scan_while` | 5,034,616 |
| **`predicate(…)`** | **`callvalue`** (`rt_call_value`) | **8,000** | **`scan_while`** | **1,812,400** |
| ↳ `local_char?` | generic entry, from `rt_call_value` | 6,800 | — | 1,405,600 |
| ↳ `is_tcl_alpha` | native, through `invoke_native`/`apply_op` | 1,200 | — | 68,400 work + 75,600 dispatch |
| `domain?` | `call` | 400 | `emailish?` | 2,265,450 |
| `tld?` | `call` | 400 | `domain?` | 1,513,450 |
| `char_at` (region companion) | `callmulti` | 2,400 / 400 | `domain?` / `emailish?` | 201,600 / 33,600 |
| `web::uri_escape_text` | `callenv` | 1 | `<program>` | 7,358 |

The one `callvalue` site executes 8,000 times per run; every other hot edge
is an exact `call`/`callenv`/`callmulti`.

## callvalue target distribution

| target | how it arrives | dynamic calls | per input |
|---|---|---:|---|
| `local_char?` (closure, block e183) | `rt_call_value` → closure path → generic-entry trampoline → direct body | 6,800 | café: 5 (c a f é @) × 400; not-an-email: 12 × 400 |
| `is_tcl_alpha` (native) | `rt_call_value` → `invoke_native` → `apply_op` → `rt_is_tcl_alpha` (inlined) | 1,200 | café's TLD テ ス ト: 3 × 400 |
| anything else | — | **0** | |

`rt_call_value` has exactly these two outgoing arcs: into `local_char?`'s
generic entry (6,800) and into `one_scalar` via the native path (1,200).
Their sum equals the 8,000 executions.

Statically, the generic `scan_while` instance has exactly two call sites:
* `emailish?` passes `local_char?`;
* `tld?` passes `is_tcl_alpha`.

`scan_while` is never referenced as a value: blockescape proves it
call-only, and M7.c's `hir::specialize::InstanceClosed` reports it
**closed**. No other target can reach it.

## callvalue dispatch vs callee work

Per run, `callvalue` inclusive (1,812,400) decomposes as follows.

**Dispatch only:**
* call site in `scan_while`: 120,000 (15 instructions × 8,000). That is the
  argument-array store, helper address, argument moves, `call`, the
  completion check and the `guardbool` Bool-kind check.
* `rt_call_value` common dispatch: 262,800 (32.9/call: heap-kind test,
  closure arity check, entry call).
* native dispatch: 75,600 (63/call × 1,200: `invoke_native` arity and
  parameter-kind checks, the `apply_op` match).
* `local_char?` generic-entry trampoline: 47,600 (7/call × 6,800).
* **Total 506,000 (5.9%).** Net of the ~5 instructions a direct call would
  still need: ≈ 466,000 (5.4%).

**Callee work beneath it:**
* `local_char?`: 1,358,000. Of that, `rt_set_contains` is 758,400 and
  `rt_is_tcl_alnum` 370,000.
* `is_tcl_alpha`: 68,400.
* **Total 1,426,400 (16.7%).**

Predicate work is 2.8× the dispatch that reaches it, and more than half of
it is set membership.

## String materialization attribution

| site | object | count | bytes | construction Ir (in-run) | reclamation Ir (deferred) | consumed by |
|---|---|---:|---:|---:|---:|---|
| `char_at` `web.bot:97` `substr`, called from `scan_while` (local part) | String | 6,800 | ~279K | ≈3.79–3.82M (≈560/String) | ≈2.02M | `local_char?`, 1,358,000 Ir |
| same site, called from `scan_while` (TLD) | String | 1,200 | ~52K | ≈1.21–1.24M (≈1,010/String: deep non-ASCII seek) | ≈0.36M | `is_tcl_alpha`, 68,400 Ir |
| `esc_from` `web.bot:221` `substr` (startup) | String | 3 | 123 | 979 | | `encode_utf8` |
| `esc_from` `web.bot:219` construct (startup) | String | 1 | 45 | | | `q` |

`domain?`'s and `emailish?`'s own `char_at` calls materialize nothing
(2,800 regions per run).

How the local/TLD split was derived:
* The TLD figure is `tld? → scan_while` inclusive minus its dispatch, work
  and loop share.
* The local figure is the exact-target counterfactual's `scan_local →
  char_at` (3,822,749). The same calls, computed as `emailish? →
  scan_while` minus dispatch, work and loop, give 3,792,866, within 0.8%.

Per-String cost, from the single-input probes:
* **411 Ir** on an ASCII base (`ascii-only`, `invalid-only`);
* **871 Ir** on the café base (`unicode-only`), which adds the UTF-8 seek,
  `from_iter`, a char count and a shrinking `realloc`;
* plus `char_at`'s own 34 Ir;
* plus **297 Ir** of reclamation per object.

`rt_substr`'s own 837,439 Ir split by source line:

| component | Ir | per call |
|---|---:|---:|
| entry / bounds (lines 536–540) | 208,078 | 26 |
| ASCII copy (lines 548–552) | 216,128 | 45 × 4,803 |
| **non-ASCII UTF-8 seek** (lines 562–564) | 256,000 | 80 × 3,200 |
| non-ASCII collect (565–568) | 62,400 | |
| return / other | 94,833 | |

## StringRegion: known vs opaque consumer

Same language, same String representation, same benchmark and compiler. The
only difference between these paths is consumer visibility:

| path | raw `char_at` | materialized | kept as region | Ir/run | Ir/char | why |
|---|---:|---:|---:|---:|---:|---|
| `scan_while` → `callvalue` → `local_char?` | 6,800 | **6,800** | 0 | ≈3.8M production + 1.36M consumption | ~760 | opaque consumer. **Even with an exact target** `local_char?` is not region-consuming: `immutable_set_contains` is not a supported consumer, the set is captured, and the instance is generic |
| `scan_while` → `callvalue` → `is_tcl_alpha` | 1,200 | **1,200** | 0 | ≈1.21M + 68K + dispatch | ~1,240 | opaque consumer only: the counterfactual keeps all 1,200 as regions |
| `domain?` → `== "."` / `label_char?` (direct) | 2,400 | 0 | **2,400** | 648,800 incl. consumption | 270 | known consumers: `==` literal, region-consuming `label_char?` |
| `emailish?` → `char_at(local_end) == "@"` | 400 | 0 | **400** | 94,000 | 235 | direct `==` operand |

**Positive control** (`profiles/counterfactual/string-region-off`): the
frozen tree under `-string-region-opt 0` materializes those 2,800 too
(11,623 allocations) and costs **10,522,019 Ir (+1,960,593, +22.9%)**. On
the direct path, the saving is about 615 Ir per character, on this non-ASCII
base.

Region *consumers* are not free. `rt_str_region_eq` (191) and
`rt_str_region_is_tcl_alnum` (176) each re-seek from byte 0, and cost more
than their materialized counterparts (`rt_str_eq` 11, `rt_is_tcl_alnum`
54). Materialization dominates regardless.

**Hypothesis test** ("callvalue blocks StringRegion, so one-character Strings
materialize"):
* **True for 1,200 of the 8,000.** With exact targets the unmodified
  compiler keeps the `is_tcl_alpha` path as regions: 0 Strings, `char_at`
  region 84 + `rt_str_region_is_tcl_alpha` 233 per character.
* **False for the other 6,800.** They are blocked by callvalue *and* by
  set membership. The counterfactual still materializes them (String 8,004
  → 6,804).
* **Ceiling:** existing StringRegion reasoning, behind exact target
  knowledge, plausibly removes ≈ **0.91M Ir (10.6%)** of in-run cost, plus
  ≈ 0.36M deferred. That is the TLD path saving net of its dispatch.
  **Upper bound, not a promise.**

**Is `domain?` a convincing positive control?** Yes. It is the same
benchmark, compiler and String representation, and its 2,400 `char_at`
calls produce 0 Strings. The only difference is consumer visibility.

## local_char? closure cost

* **800** per run (exactly one per real `emailish?` call), 38,400 bytes
  (48 B each).
* **In-run cost:**
  * `rt_closure_new` (inclusive, from `emailish?`): 273,508 (342/closure);
  * of which `Vm::alloc<ClosureObj>` 130,437 (Box + heap registration) and
    the capture-array malloc 84,377;
  * closure-creation call-site setup and rooting in `emailish?`:
    ≈ 10,400.
  * **≈ 283,500 (3.3%)**, which matches the exact-target counterfactual's
    measured −283,508.
* **Deferred reclamation:** ≈ 237,600 (297/object).
* **GC/rooting inside the run:** 0 collections. Two root-slot stores per
  call are already included above.
* **Relative weight:** 3.3% of the benchmark, but **19.1%** of the
  `early-invalid` probe, where it is a fixed per-call cost against almost
  no scanning.

## Module-closure / callenv cost

* **Module initialization:** `web::emailish?`, `is_unreserved` and
  `uri_escape_text` closures plus `local_extra_chars` (list + set). One-time
  cost: 1,521 Ir of `rt_closure_new` + 1,560 `rt_set_from_list` + ~1K list
  construction, **< 0.05%**. Negligible, as expected.
* **`callenv` vs a direct call:**
  * `check`'s call site is 3 moves + `call` + 2 completion instructions,
    the same instruction count as R2's plain `call`.
  * The closure is a flattened extra parameter, so its cost is root-slot
    and tail-argument traffic: counted in the next section.
* **Capture loads inside `emailish?`:** `local_extra_chars` is two
  dependent loads per call, **1,600 Ir/run**.
* **Generic `emailish?` instance:** `guard str` on `v` costs ~7
  instructions × 800 ≈ 5,600. R2's `emailish?<str>` had none.

## Generic-keying / lost-M9-fact cost

**Mechanism.** Since R2.a.1, `local_extra_chars` is module-retained, so
`web::emailish?` captures it and becomes a closure. `check` captures that
closure, a value-capturing closure's key is forced generic, and the result
is `check<generic>`. `hir::range` also flags `check` open, because it is
materialized in `<program>` even though blockescape flattens it. So `n`
enters as `[-∞, +∞]`, whereas R2 and R2.a had `[0, 400]`.

**Local, function-level comparison** (the historical control flow differs,
so only `check`'s own instructions are compared):

| | R2, R2.a (`n ∈ [0,400]`) | R2.a.2, R2.a.3 (generic) |
|---|---:|---:|
| `check` self Ir/run | **25,258** | **46,880** |
| per iteration | 31.5 | 58.5 |

Per iteration, what differs:

| operation | R2 | frozen | removable with the range fact? |
|---|---|---|---|
| `n <= 0` | `test r12,r12; jle` (2) | tag test (3) + `mov ecx,2` + `cmov` + `cmp rcx,6; je` (6) | yes: ~7 |
| `n - 1` | `sub r12,1` (1) | tag test + moves + `sub` + `seto`/`test`/`jne` + `lea` + moves + `jmp` (12) | yes: ~11 |
| `acc + hit` overflow-checked add | yes | yes, plus 2 reloads from root slots | no: `acc` is unbounded in both |
| root-slot stores | 3 | 6–8 | partly: `n` needs no slot if raw; the closure param and reloaded `hit`/`acc` stay |

**Ceiling:**
* full difference vs R2: **21,622 Ir/run (0.25%)**;
* conservative removable by an `n ∈ [0,400]` fact alone: **≈ 14,400 (0.17%)**.

This cost is **reachable by two candidates**: static module values (`check`
stops being generic) or range↔blockescape (`check` stops being open).

## Range↔blockescape dynamic consequences

The mismatch **still exists**. Nine instances are M7.c-closed (blockescape's
`RefsAsCalls` proof, already trusted by `hir::specialize::InstanceClosed`)
yet flagged open by `hir::range::OpenInstances`:
* `char_at`, `scan_while`, `tld?`, `domain?`, `check`;
* and `uri_escape_text`'s `hex_pair`, `esc_bytes`, `esc_char`, `esc_from`.

Because they are open, no caller-propagated entry fact reaches them:
* `scan_while` `start`, `domain?` `start` and `tld?` `i` stay `[-∞, +∞]`;
* so `i`/`j` get `min = -∞` and stay tagged, even though every caller passes
  a non-negative Int.

Dynamic consequence, per function: everything a proven small-Int
representation could remove (tag tests, overflow checks, and the
`mov R,2`/`cmov`/`cmp R,6` of each compare turned into a Bool word).
`tools/intclasses.py`:

| instance | tag | ovf | Bool word (compare-derived) | raw-Int removable (upper bound) |
|---|---:|---:|---:|---:|
| `scan_while` | 41,600 | 22,800 | 35,200 | 90,800 |
| `char_at` (materializing) | 16,000 | 24,000 | 0 | 40,000 |
| `char_at` (region) | 5,600 | 8,400 | 0 | 14,000 |
| `domain?` | 6,800 | 4,000 | 6,400 | 15,600 |
| `check` | 4,802 | 3,200 | 3,208 | 10,408 (class-based; the listing-based estimate above, which also counts the moves and jumps a raw decrement drops, is ≈14.4K) |
| `tld?` | 3,200 | 400 | 2,400 | 4,800 |
| **total** | | | | **≈175,600 (2.05%)** |

**Ceiling:** ≤ 2.1%, an upper bound that assumes every tagged op in these
functions becomes raw.

It is **independent of A.** In the exact-target counterfactual, `scan_local`
and `scan_alpha` are still `<generic>` and open, and still 42 Ir/iteration.
It **overlaps B** only on `check`. Its population is broader than A's: it
covers `uri_escape_text`'s helpers too.

## Frame / calling-convention cost

Generated code, per run (`mix.txt`, `moves.txt`):

| class | Ir/run | share of total |
|---|---:|---:|
| frame prologue + epilogue (callee-saved save/restore, `rsp`) | 321,186 | 3.75% |
| root-slot zeroing at entry | 413 | 0.00% |
| register moves: call-argument setup | 72,062 | 0.84% |
| incoming arguments staged into callee-saved registers | 70,488 | 0.82% |
| VM pointer into `rdi` for a call | 36,858 | 0.43% |
| result into / out of `rax` | 42,021 | 0.49% |
| join / loop-carried copies | 22,012 | 0.26% |
| other moves | 72,486 | 0.85% |
| `call` instructions (Botlish + helper) | 52,081 | 0.61% |
| **frame + convention moves + calls** | **~595K** | **~6.9%** |

* **Where it goes:**
  * `local_char?`: 18 frame instructions per call × 6,800 = 122,400, plus
    7 in the generic entry;
  * `char_at` fn 11: 104,000;
  * `char_at` fn 10: 47,600.
* **Waste is low.** Block-locally dead or redundant moves are 1,227 (0.4%
  of moves).
* **Taxonomy note.** Closure/env argument handling is part of the rows
  above: the generic-entry trampoline, and `check`'s flattened closure
  parameter. Rust helpers' own prologues are counted inside their helpers,
  not here.

## Root publication cost

* **Stack stores into `[rsp+N]`:** 102,237 Ir/run (1.19%), plus stack loads
  8,034 and root-slot zeroing 413.
* **What they include:** root-slot publication, plus two things that are
  not root publication: `callvalue`'s argument array (8,000) and
  `char_at`'s region out-parameters. So **≤1.2%** is an upper bound.
* **Largest users:**
  * `scan_while`: 37,200. The `char_at` result is rooted across the
    `callvalue`, and `i` is republished on every backedge.
  * `char_at` fn 11: 32,000.
* **In-run GC work:** none.

## Tagged-Int cost

| | Ir/run | share |
|---|---:|---:|
| tag tests (small-Int check; the BigInt fallback gate) | 82,874 | 0.97% |
| overflow checks | 64,033 | 0.75% |
| untag / retag | 19 | 0.00% |
| **total tagged-Int** | **146,926** | **1.72%** |
| `rt_int_*` BigInt fallback helper calls | 0 hot | |

Where it goes:
* `scan_while`'s counted induction: 64,400;
* `char_at`'s `i + 1`: 54,000;
* `domain?` induction and `j ± 1`: 10,800;
* `check`: 8,002;
* `emailish?`: 6,000.

The counted loop's Range fact did **not** make the induction raw. `min` is
`-∞`, so `i` is tagged, tag-tested and overflow-checked every iteration, and
its slow paths never execute (0 mispredictions). No boxing/unboxing churn
remains: `i` stays tagged throughout.

## Bool / completion cost

**Bool words:**
* Compare → Bool word → re-test: `mov R,2` + `cmov` + `cmp R,6; jcc`,
  27,242 + 26,434 = **53,676 (0.63%)**. **All are branch-only transients**:
  loop headers, `check`'s `n <= 0`, `emailish?`'s and `tld?`'s compares.
  None escapes as a value, so every one could stay in flags.
* Tests of Bool words returned by helpers or calls (predicate results,
  region classifications): **59,234 (0.69%)**. These are genuine language
  Bools crossing the helper ABI.
* 4,800 instructions in `domain?` materialize and re-test folded
  *constant* Bool words (`label_char?`'s `or`/`not` after region-consumer
  folding: `mov esi,6; cmp rsi,6; je`, `mov eax,2; cmp rax,6; jne`). 3,200 of
  them are in the 59,234 above.
* `guardbool`'s Bool-kind check after `callvalue`: 8,000 (plus its `cmp`),
  attributable to dispatch.

**Completion checks** (`test rax,rax; jcc` after a fallible call): **72,064
(0.84%)**:

| where | Ir/run | cause |
|---|---:|---|
| `scan_while` | 32,000 | 16,000 after the `char_at` call, 16,000 after `callvalue` |
| `char_at` (after `rt_substr`) | 16,000 | |
| `local_char?` | 13,600 | |
| region `char_at` | 5,600 | |
| `domain?` | 2,400 | |
| `check` | 1,600 | |
| `emailish?` | 800 | |

No return/break/continue normalization or completion tagging executes. A
counted-loop `continue` is a `jmp`, and `return i` is a direct `ret`.

## Counted-loop cost

Executed loop-control instructions (header + backedge), frozen vs. the
R2.a.2 self-tail-recursive `scan_while`:

| | header × executions | backedge × executions | total | per iteration |
|---|---|---|---:|---:|
| R2.a.2 `scan_while` (self-tail) | 11 × 10,000 | 21 × 8,400 (re-roots all 4 params) | 286,400 | 32 |
| **frozen `scan_while` (countloop)** | 11 × 8,800 | 14 × 7,600 | **203,200 (2.37%)** | **25** |
| frozen `domain?` (countloop) | 12 × 1,200 | 17 × 800 | 28,000 (0.33%) | ~29 |

How the 25 per iteration break down:
* 5 tag-test instructions;
* 3 overflow-check instructions;
* 4 for the Bool word (`mov ecx,2`, `cmov`, `cmp rcx,6`, `je`);
* 2 root-slot stores;
* about 8 moves;
* 1 `jmp`, plus the compare, add and `jcc`.

Findings:
* A raw induction would need about 4 per iteration (`cmp`/`jge`,
  `add`/`jmp`).
* **The counted loop is cheaper than the recursion it replaced (25 vs 32)
  and adds no completion overhead.** Its residual cost is tagged-Int
  representation, which is the range↔blockescape item above.
* No correctness problem was found.

## UTF-8 traversal cost

**What is walked:**
* `utf8SeekBytes` **46,000** per run: 23,600 in `rt_substr` (café's local
  part and TLD) and 22,400 in region helpers (`domain?`, `"@"`).
* Every access re-decodes from byte 0. The traversal optimization
  (`hir/traversal.tcl`) does not apply: `char_at` is a separate closure
  instance, and the scans are generic.

**What the seeking costs**, from source-line attribution:

| component | Ir/run |
|---|---:|
| `rt_substr` seek | 256,000 |
| `rt_str_region_eq` seek | ~175,200 |
| `region_one_scalar` seek | ~68,800 |
| **total** | **≈500,000 (5.84%)**, ≈10.9 Ir per byte |

**The full non-ASCII surcharge** = frozen − ASCII probe = **1,841,056 Ir
(21.5%)**. The same figure appears as unicode-only − ascii-only (1,840,780).
It covers the seek, plus:
* the non-ASCII materialization path (`from_iter`, char count, shrinking
  `realloc`);
* Unicode category lookups;
* character-wise region compares.

| separation | Ir/run | share |
|---|---:|---:|
| character-index seeking | ≈500K | 5.8% |
| substring construction (excluding seek) | ≈4.51M | 52.6% |
| predicate/classification (String + region classification, set membership) | ≈1.27M | 14.8% |

## ASCII vs Unicode vs early-invalid controls

| probe (400 `check` iterations, one input) | Ir/run | Ir per `emailish?` | Strings | `rt_substr` Ir/call | callvalue | dominant cost |
|---|---:|---:|---:|---:|---:|---|
| `unicode-only` `café@例え.テスト` | 4,875,357 | 12,094 | 3,200 | 871 | 3,200 | materialization 57%; region traversal 13% |
| `ascii-only` `cafe@ab.xyz` (same control flow) | 3,034,577 | 7,492 | 3,200 | 411 | 3,200 | materialization 43%; dispatch + predicate 23% |
| `invalid-only` `not-an-email` | 3,699,970 | 9,155 | 4,800 | 411 | 4,800 | materialization 53%; dispatch + predicate 30% |
| `early-invalid` `@example.com` | 716,092 | 1,695 | 400 | 409 | 400 | set membership 35%; closure alloc 19%; materialization 23% |

**Higher-order overhead is not a UTF-8 effect.** `rt_call_value` costs
215–222 Ir/call on both bases.

**UTF-8 roughly doubles materialization per character.** Early-failing
inputs are dominated by fixed per-call costs: the closure and one set
membership.

## Allocation attribution

`native::allocationReport` (`dynamic/alloc-refined-checks.txt`), reconciled
with the profile:

| site | kind | count | bytes | in-run Ir | reclamation Ir | reason it exists |
|---|---|---:|---:|---:|---:|---|
| `char_at` `web.bot:97` `substr` | String | 8,000 | 330,800 | 4,762,616 (595 each) | ≈2.38M | `predicate(char_at(i))`: consumer behind `callvalue` (and set membership on 6,800) |
| `web::emailish?` `web.bot:99` `closure` | Block | 800 | 38,400 | 283,500 (354 each) | ≈0.24M | `local_char?` captures module-retained `local_extra_chars` and escapes as a value |
| module init (`web.bot:90/92/185/187/189/192`, `byte.bot:175/177`, program list) | List, ImmutableSet, Block | 14 | 784 | ~7K | | module-retained values, closures, result list |
| `uriEscape("a b")` (`web.bot:198/207/219/221`) | String, List, StringPlan | 9 | 456 | ~7K | | startup |
| **total** | | **8,823** | **370,440** | **≈5.06M (59%)** | **2,621,775** | |

Other allocation facts:
* In-run GC cycles: **0**.
* Peak live: all 8,823 objects, because nothing is collected until the
  reset.
* String bytes copied: 10,816.

Classification:
* **High count, high cost:** the 8,000 Strings, at 595 Ir in-run + 297
  deferred each.
* **Moderate count, moderate cost:** the 800 closures, at 354 + 297 each:
  3.3% in-run, but 19% of `early-invalid`.
* **Low count, high cost:** `rt_set_contains` (1,200 calls, 632 Ir each,
  8.9%, zero allocations), and region equality on a non-ASCII base.
* **High count, low cost:** none in this workload.

## Historical decomposition

Same binary (`native/src` identical), same method, one session:

| | pre-R2 `0c2dead` | R2 `e7d53b6` | R2.a `63b2199` | R2.a.2 `b472022` | **R2.a.3 frozen** |
|---|---:|---:|---:|---:|---:|
| Ir/run (in-run) | 5,430,486 | **3,461,691** | 10,967,390 | 9,375,454 | **8,561,426** |
| reclamation Ir per run | 6,866 | 6,797 | 3,452,481 | 2,978,175 | 2,621,775 |
| allocations | 20 | 20 | 11,620 | 10,023 | 8,823 |
| String allocations | 4 | 4 | 9,204 | 9,204 | 8,004 |
| Block allocations | 2 | 2 | 802 | 803 | 803 |
| callvalue executions | 0 | 0 | 9,200 | 9,200 | 8,000 |
| machine bytes | 15,187 | 9,868 | 9,490 | 10,027 | 10,258 |
| generated-code share | 33.4% | 37.2% | 12.7% | 14.9% | 15.8% |
| `rt_substr` inclusive | 0 | 0 | 5,807,741 | 5,887,533 | 4,763,548 |
| `rt_call_value` inclusive | 0 | 0 | 1,992,400 | 1,992,400 | 1,812,400 |
| region helpers inclusive | 3,591,200 | 2,153,200 | 191,600 | 191,600 | 614,000 |
| `check` self | 31,256 | 25,258 | 25,258 | 46,880 | 46,880 |
| wall-clock (median, µs) | 305 | 205 | 727 | 726 | 660 |

Causally, step by step:

* **pre-R2 → R2 (−1.97M).** The duplicate native-body pass is gone (R2's
  own finding). R2 materializes **nothing**: every scanner calls its
  predicate directly and every predicate was region-consumable. R2's
  3.46M is essentially region traversal (2.15M), `char_at` calls and
  tagged scanner loops.
* **R2 → R2.a (+7.51M).** The predicate-passing normalization.
  * Every scanned character is now materialized (`rt_substr` +5.81M) and
    dispatched (`rt_call_value` +1.99M).
  * `local_extra_chars` is built per call (+1.60M: `rt_set_from_list` +
    `rt_list_new`), and the closure is allocated per call (+0.31M).
  * Set membership replaces the equality ladder (`rt_set_contains` +0.76M,
    on 1,200 of the characters).
  * Offset: region helpers −1.96M. Plus 3.45M of deferred reclamation.
* **R2.a → R2.a.2 (−1.59M).** R2.a.1's module retention removes exactly the
  per-call set construction (−1.60M). It also makes `check` generic
  (+21.6K).
* **R2.a.2 → R2.a.3 (−0.81M).**
  * The label scan leaves `scan_while`: 1,200 fewer Strings and 1,200 fewer
    `callvalue`s.
  * `domain?` reads characters directly, and existing StringRegion keeps
    them as regions (region helpers +0.42M; label path net −0.71M).
  * The counted loop costs 7 fewer control instructions per iteration than
    the self-tail recursion.

**Which costs existed already at R2:**
* region traversal and its UTF-8 re-seek;
* `char_at`'s call boundary (10,000 region calls, 840K);
* tagged scanner induction in open instances;
* frame/ABI costs.

**New consequences of the intended idiomatic source:**
* one-character String materialization;
* `callvalue` dispatch;
* per-call closure allocation;
* generic-equality set membership;
* deferred reclamation;
* `check`'s generic keying.

Of the frozen program's 5.10M excess over R2, the exact-target
counterfactual recovers 1.69M with existing machinery. Most of the remaining
3.41M is the local-part materialization plus set-membership work: the
counterfactual's local-part scan costs 3.25M more than R2's `scan_local`.

## Optimization overlap / dependency graph

```
A  exact predicate target at scan_while  (finite theorem: predicate ∈ {local_char?, is_tcl_alpha})
│   precondition already proven: scan_while is M7.c-closed (blockescape call-only)
├── A1 callvalue dispatch removed ........................ 0.47–0.51M  (5.4–5.9%)
├── A2 exact callee facts: local_char?'s `guard str` gone .. ~0.05M     (0.6%)
├── A3 is_tcl_alpha path: EXISTING StringRegion sees the native consumer
│     └── 1,200 TLD Strings become regions ............... ~0.91M     (10.6%)  [+0.36M deferred]
├── A4 local_char? stops being a value ─┐
│     └── blockescape flattens its capture: 800 closures gone .. 0.28M (3.3%)  ◄── same Ir as B1
├── measured together (counterfactual, unmodified compiler) ... 1.69M (19.7%)  [+0.59M deferred]
└── A5 local_char? path (6,800 Strings) still materializes
      └── needs: StringRegion region set-membership consumer (+ non-generic local_char?)
            └── rough upper bound, anchored on R2's own 319 Ir/char region scan .. ~3.2M (38%)
                 [NOT existing machinery; a follow-on; only possible after A]

B  static module-retained values (local_extra_chars, web::emailish?)
├── B1 local_char? envless → no per-call closure ......... 0.28M (3.3%)  ◄── same Ir as A4
├── B2 web::emailish? envless → emailish?<str>, no guard .. ~0.006M
├── B3 check non-generic → n ∈ [0,400] ..................... ≤0.022M (0.25%) ◄── same Ir as C2
└── does NOT remove callvalue, NOT make local_char? region-consuming
    total ≈0.31M (3.6%); ≈0.02–0.03M of it independent of A

C  range ↔ blockescape (hir::range trusts M7.c's InstanceClosed)
├── C1 raw induction / index in scan_while, char_at ×2, domain?, tld? .. ≤0.165M (1.9%)
└── C2 check n ∈ [0,400] ................................................ ≤0.010–0.022M ◄── same as B3
    total ≤0.18M (2.1%); independent of A (the counterfactual's scanners stay open)

D  R3 tiny exact calls (char_at ×2: 10,800 calls)
└── call boundary (frame, moves, call/ret, caller setup) .. ~0.27–0.35M (3–4%)
    overlaps: A3 turns 1,200 fn-11 calls into fn-10 calls; C (tag/ovf counted there)

E  runtime (not compiler) costs, measured, independent of visibility
├── E1 one-char String construction itself (411–1,010 Ir each) .. 4.51M (52.6%), shrinking with A3/A5
├── E2 rt_set_contains: generic `equal` × 5 per miss ............. 0.76M (8.9%), unaffected by A/B/C
├── E3 UTF-8 re-seek from byte 0 ................................. 0.50M (5.8%), mostly unaffected by A
└── E4 reclamation of materialized objects ....................... 2.62M deferred

F  frame / calling convention, diffuse ........................... ~0.60M (6.9%)
```

Do not add these up. Most importantly:
* A's measured 1.69M already **includes** B1 (0.28M) and A3's
  materialization removal.
* B's 0.31M is ~90% the same Ir as A4.
* C2 and B3 are the same 0.02M.
* E1 is the *mechanism* A3/A5 avoid, not an independent opportunity.

## Candidate ceilings

In-run Ir; frozen = 8,561,426.

| candidate | measured / derived ceiling | how measured | overlap |
|---|---:|---|---|
| **A** exact-target propagation, existing downstream machinery | **1.69M (19.7%)**, plus 0.59M deferred | **measured**: counterfactual profile, unmodified compiler | includes B1 |
| A1 dispatch only | 0.47–0.51M (5.4–5.9%) | per-instruction + inline-chain attribution | part of A |
| A3 StringRegion through the predicate (existing machinery) | ~0.91M (10.6%) | counterfactual TLD path minus its dispatch | part of A |
| A + StringRegion set membership (follow-on) | + ~3.2M (≈38%) | rough: counterfactual 797 Ir/char vs R2's measured 319 Ir/char region scan | requires A first |
| **B** static module values | ~0.31M (3.6%) | closure + guard + `check` difference | 0.28M = A4 |
| **C** range↔blockescape | ≤0.18M (≤2.1%) | raw-Int upper bound per instruction | `check` shared with B |
| **D** R3 `char_at` | ~0.27–0.35M (3–4%) | frame/move/call instruction counts | shifts under A3 |
| **E** String traversal / materialization runtime | E1 4.51M, E2 0.76M, E3 0.50M | measured | E1 is what A3/A5 avoid |
| `check` generic (lost M9) | ≤0.022M (0.25%) | local comparison with R2 | B and C |
| **F** frame / ABI | ~0.59M (6.9%) | instruction classes | diffuse |

## Corpus generality check

`static/corpus-generality.md` (`tools/corpus.tcl`), the whole repository
corpus: `bench/*.ir`, `bench/*.bot`, `examples/stdlib/*.bot`,
`examples/surface/*.bot`:

| pattern | where it occurs |
|---|---|
| `callvalue` (higher-order predicate call) | **only** `lib/web.bot`'s `scan_while` (via `refined-checks` and `uri-steady`, which compiles the same module) |
| per-call closure allocation | `local_char?` (same two programs), plus `examples/surface/03-closure.bot` |
| module values reaching functions as flattened captures | only `web` (7 in `refined-checks`, 10 in `uri-steady`) |
| open-but-blockescape-flattened instances (C's population) | only `web`: 9 / 10 instances, covering `uri_escape_text`'s `esc_from`/`esc_char`/`esc_bytes`/`hex_pair` **as well as** `emailish?`'s helpers |
| materializing `substr` | `web` (2 sites) and the csv family (2 each); region ops widespread (ai_text_clean 19, csv 11, csv_* 9–11, string_replace 4) |
| `immutable_set_contains` | only `web` (`local_char?`, `is_unreserved`) |

Every compiler candidate (A, B, C) is today a `lib/web.bot`-only pattern:
* **A is the narrowest:** one site.
* **B and C are broader:** both web functions.
* **The runtime materialization costs (E1/E3) are the most general.** The
  post-M8.a census already measured one-character String production at
  16.2% of `ai_text_clean` and 14,000 per 2,000 calls in `uri-steady`.

## Recommended next milestone

**Higher-order exact-target provenance for `scan_while`'s `predicate`: a
finite callable-target theorem.**

Why this one, from the measurements:

1. **It has the largest measured ceiling of any compiler candidate: −19.7%
   in-run Ir and −21% median wall-clock.** It was measured, not estimated,
   by running the unmodified compiler on the exact-target shape. The next
   largest compiler items are R3 at 3–4%, B at 3.6% (of which 3.3% is the
   same Ir as A) and C at ≤2.1%.
2. **It is the gateway to the largest remaining cost.** The 6,800 local-part
   materializations (44.7%) sit behind `callvalue`. No StringRegion
   extension, runtime fast path or inlining can act on them while the
   consumer is invisible. A makes the consumer visible; a follow-on
   (StringRegion set membership) then has a measured target.
3. **Its precondition is already proven by shipped machinery.** `scan_while`
   is closed under M7.c's `InstanceClosed`, using blockescape's call-only
   proof. The theorem extends the existing closed-caller *kind* facts to an
   exact callable *identity set*. It needs no new escape analysis and no
   change to callable identity.
4. **It subsumes most of B for this workload.** Once `local_char?` is not
   passed as a value, the 800 closures vanish (measured).

Against it, and stated plainly:
* Generality is the weakest of the candidates: one `callvalue` site in the
  corpus.
* C has the smallest architectural risk: `hir::range` would consult the
  already-shipped `InstanceClosed` instead of its own materialization test.
  It is also more general (both web functions). But its whole ceiling is
  ≤2.1%.
* If the project were choosing a *runtime* milestone, a one-scalar String
  fast path (E1) or a cheaper set membership (E2) would compete. E1 is
  larger and more general, but it is not a compiler deficiency and is
  outside this question.

### The exact theorem needed

* `scan_while<generic>` currently sees `predicate` as an arbitrary callable.
  Its key reduces a Block argument to the bare kind `block`, and the
  closed-caller kind join over {closure, native} is `any`.
* In this closed program, the M7.c closed-caller set of `scan_while` is
  exactly two exact call sites:
  * `emailish?`: `scan_while(0, local_char?)`, a closure over block e183
    capturing `local_extra_chars`;
  * `tld?`: `scan_while(i, is_tcl_alpha)`, the native `is_tcl_alpha`.
* `scan_while` never escapes as a value. So at every execution,
  `predicate ∈ {closure of block e183, native is_tcl_alpha}`.
* A future pass could retain that **finite callable-target set** as an
  entry theorem. It could then split `scan_while` per target, or lower the
  `callvalue` to a two-way exact dispatch, without changing:
  * callable identity (the closure value still exists wherever it is
    otherwise observable);
  * error semantics (`rt_call_value`'s arity/kind checks are statically
    discharged by the theorem, not skipped);
  * source.
* Existing downstream machinery would then, as measured:
  * keep the `is_tcl_alpha` path as regions;
  * flatten `local_char?`'s capture;
  * drop the `guard str`.

Not designed further here, and not implemented.

### What the evidence does not support

Choosing A does **not** claim:
* that dispatch is the main cost (it is 5.9%);
* that StringRegion will then remove the local-part Strings (it will not,
  without a set-membership consumer).

## Validation and regression

* **Full regression** (a comment in `lib/web.bot`, a file normal tests load,
  changed): `LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl`, on the final
  tree:
  * `interp` pass: **Total 2544, Passed 2544, Skipped 0, Failed 0**;
  * `compile` pass: **Total 2544, Passed 2544, Skipped 0, Failed 0**;
  * 86 test files each, 11 m 32 s. The tests also exercise
    `cranelift`/`cranelift-generic` directly (`native*.test`,
    `stdlib.test`).
* **Compiled-program identity after the comment edit:** byte-identical NIR
  (benchmark and probes), an identical deterministic baseline and identical
  allocation sites.
* **No production file changed** other than that comment and the R2.a.3
  report. `native/`, `hir/`, `compiler/`, `core/`, `surface/`, `bench/` and
  `tests/` are untouched. The audit patch was only ever applied in a scratch
  copy. The counterfactual lived only in scratch worktrees.
* **GC stress:** not run locally, per item 30. No root or representation
  code changed, and CI's `gc-stress` job owns that check.
* **Stop conditions:** none triggered.
  * JIT attribution is complete and validated.
  * The instrumentation does not change generated code.
  * No correctness bug was found.
  * Every contradiction with earlier static claims (`label_char?`'s folding
    mechanism, the `callmulti`/`guard` counts) was investigated and
    reported above.

## Required questions

**Measurement validity**

1. **Frozen baseline tree:** `6dbcfdb3d62e7870363d2af4fe0dfab7e58ad80c` (R2.a.3
   freeze `05ae3d8`/`c4024de`, plus audit-corpus regenerations only).
2. **Is `lib/web.bot` unchanged?** **Yes.** Its code and algorithm are
   byte-for-byte unchanged, and it compiles to byte-identical NIR. The one
   diff is the item-2-permitted correction of a comment that reproduced
   R2.a.3's `label_char?` mistake.
3. **Audit binary/configuration:**
   * `tools/build-audit-native.sh`: release build, same toolchain, the
     post-M8.a patch plus two harness-only hooks;
   * callgrind with `--dump-instr --cache-sim --branch-sim
     --toggle-collect=botlish_audit_run`, `BOTLISH_AUDIT_SKIP_FIRST=1`,
     `bench 21` (20 collected steady-state runs).
4. **How JIT code is mapped to symbols:** the `BOTLISH_AUDIT_JITMAP` dump of
   every NIR function's direct and generic-entry ranges and bytes, matched
   by address to callgrind's per-instruction costs. Coverage equals `size`
   for every function.
5. **How the benchmarked region is delimited:** the `botlish_audit_run`
   frame around each timed run. Run 0 and every `Vm::reset` are outside it.
6. **Same value as production?** **Yes**: `[400, 0]`. The object file, VCode
   and allocation counters are identical too.
7. **Reproducible?** Yes: within 350 Ir (0.004%) across six profiles and
   three run counts. Call, allocation and site counts are exact.
8. **Total Ir/run:** 8,561,426, plus 2,621,775 deferred reclamation.
9. **Generated vs runtime share:** 15.8% generated code; 84.2% runtime
   (44.7% runtime helpers, 27.2% libc, 12.3% inlined Rust std).

**Higher order**

10. **Dynamic `callvalue` executions:** 8,000 per run.
11. **Targets:** `local_char?` 6,800 and `is_tcl_alpha` 1,200. Nothing else.
12. **Dispatch-only cost:** 506,000 Ir (5.9%) gross; ≈466,000 (5.4%) net of
    a direct call.
13. **Inclusive cost beneath them:** 1,812,400 (21.2%) including dispatch.
    Callee work alone is 1,426,400 (16.7%).
14. **`char_at` materializations on the opaque path:** 8,000, i.e. all of
    them.
15. **Ir spent materializing them:** 4,762,616 in-run (55.6%), plus ≈2.38M
    deferred reclamation.
16. **How much existing StringRegion could plausibly eliminate if the target
    were known:** ~0.91M Ir (10.6%), the 1,200 `is_tcl_alpha` characters
    only, measured by counterfactual. The 6,800 `local_char?` characters are
    not region-consumable (set membership). Upper bound, not a promise.
17. **Does `domain?` provide a convincing positive control?** Yes. It makes
    2,400 direct `char_at` calls and 0 Strings (270 Ir/char vs ~760–1,240 on
    the opaque path), and turning StringRegion off costs +22.9%.

**Module values**

18. **Cost of the 800 `local_char?` closures:** ≈283,500 Ir in-run (3.3%;
    342 per closure, plus call-site setup), plus ≈237,600 deferred. 0 GC
    cycles.
19. **Cost of calling closure-valued `web::emailish?` via `callenv`:** about
    nothing at the call site, which has the same instruction count as a
    `call`. Inside it, 1,600 Ir of capture loads plus ~5,600 of `guard str`
    from the generic instance.
20. **Generic `check` vs the M9 facts it lost:** 46,880 vs R2's 25,258 Ir/run.
    That is +21,622 (0.25%), or +27 instructions per iteration.
21. **Guards/tag operations attributable to that loss:**
    * the `n <= 0` tag test and Bool-word compare (~7/iteration);
    * the tagged, overflow-checked `n - 1` (~11/iteration);
    * extra root-slot traffic.

    About 14.4K of the difference is removable by the range fact.
22. **Combined conservative ceiling for static/stable module values:**
    ≈0.31M (3.6%). ≈0.28M of it is the same Ir the exact-target change also
    removes, so only ≈0.02–0.03M is B's alone.

**Remaining backend costs**

23. **UTF-8 traversal:** 5.8% for the seek alone (46,000 bytes). The whole
    non-ASCII surcharge is 21.5%.
24. **Substring construction:** 52.6% excluding the seek; 55.6% including
    it.
25. **Tagged-Int machinery:** 1.7% (tag tests 0.97%, overflow checks 0.75%).
26. **Frame/call convention:** ~6.9% in generated code (frames 3.75%,
    convention moves ~2.6%, calls 0.6%).
27. **Root publication:** ≤1.2% (stack stores, which also include argument
    arrays and out-parameters).
28. **Completion/error machinery:** 0.84% (completion checks). No error path
    executes.
29. **Counted-loop induction/control:** 2.7% (`scan_while` 2.37% +
    `domain?` 0.33%). This is cheaper than the recursion it replaced.
30. **Are any unexpectedly dominant?** Yes:
    * **one-character String construction** (52.6%);
    * its **deferred reclamation** (+30.6%, invisible to the standard
      methodology);
    * **`immutable_set_contains`** (8.9% from 1,200 calls: a linear scan of
      generic `equal`, 632 Ir per call).

    None of the backend classes dominate.

**Prioritization**

31. **Top remaining compiler opportunities by measured ceiling:**
    1. A, exact-target (19.7%, measured);
    2. R3 `char_at` (~3–4%);
    3. B, static module values (3.6%, mostly shared with A);
    4. C, range↔blockescape (≤2.1%);
    5. `check`'s lost M9 fact (0.25%).

    The largest *potential* item, the local-part materializations (~38%),
    needs A plus a StringRegion set-membership consumer.
32. **Which overlap:**
    * A4 and B1: the closure allocation, the same 0.28M;
    * B3 and C2: `check`'s `n`;
    * A3 and E1: the TLD materializations;
    * D shifts under A3, and C absorbs D's tag/overflow share.
33. **Most general across the corpus:** among compiler candidates, C and B
    (both web functions, 9–10 instances). A is one site. The runtime
    String-materialization costs are the most general overall.
34. **Smallest architectural risk for its likely payoff:** C in absolute
    risk, since it reuses the shipped `InstanceClosed`, but its payoff is
    ≤2.1%. For payoff per unit of risk, A: its closedness precondition is
    already proven, and its measured ceiling is ~10× larger.
35. **Which milestone next:** higher-order exact-target provenance, a finite
    callable-target theorem for `scan_while`'s `predicate`.
36. **The empirical evidence for that choice:**
    * the exact-target counterfactual: −1,690,581 Ir (−19.7%), 660 → 522 µs,
      measured on the unmodified compiler;
    * the dispatch split: 5.9% dispatch vs 16.7% callee work;
    * the StringRegion test: 1,200 of 8,000 materializations removable, and
      the other 6,800 blocked by set membership, which only becomes
      addressable once the consumer is visible;
    * `InstanceClosed(scan_while) = 1` under M7.c;
    * ceilings: B 3.6% (0.28M of it shared with A), C ≤2.1%, R3 3–4%.
