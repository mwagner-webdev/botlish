# Post-M8.a cross-workload common-inefficiency census

Audit only. No production compiler, runtime or source change. Raw data,
tools and reproduction steps: [`audit/post-m8a-common-inefficiency/`](audit/post-m8a-common-inefficiency/README.md).

## Outcome

**The four canonical benchmarks pay almost nothing for allocation,
materialization or construction.** Three allocate zero objects per run; the
fourth allocates 20, all in one-time setup, none in its 800-iteration hot
loop, and no run triggers a collection. Every M8.a residual (one-character
producer Strings, `encode_utf8` Lists, `hex_pair` plans, listloop
accumulation, plans through product fields) is absent from every canonical
hot path. Producer fusion, listloop plans and structs have **no canonical
performance justification today**: their evidence lives entirely in the
supplemental string/CSV workloads.

What the canonical programs do pay for is **scalar and call-boundary work**.
It was measured with callgrind (deterministic instruction, branch and memory
counts), attributed by an audit-only JIT address map to every executed
machine instruction:

| share of executed instructions | fib | loop-count | sum-refined | refined-checks |
|---|---:|---:|---:|---:|
| generated code (rest: runtime helpers) | 100% | 100% | 100% | 33.5% |
| frame prologue/epilogue | 31.3% | 14.4% | 22.7% | 6.5% |
| register moves | 24.1% | 20.0% | 16.1% | 9.1% |
| tagged-Int work (tag tests, overflow checks, retag/untag) | 15.7% | 28.5% | 25.7% | 3.7% |
| compares materialized as Bool words, then re-tested | 7.2% | 11.4% | 0.0% | 2.6% |
| root-slot / stack traffic | 7.2% | 8.6% | 12.9% | 4.3% |
| string-region runtime helpers (inclusive) | -- | -- | -- | 66.0% |

Reduced to root causes (merged across workloads, not by helper name):

1. **Int facts lost at instance-entry boundaries (C4 as a symptom; C3
   unblocked).** An Int that every incoming edge proves small still enters
   its function as a tagged, possibly-BigInt word. That costs a tag test, a
   BigInt slow-path compare whose result is joined into a Bool word,
   untag/retag and root stores. The first losses are all in
   `hir/range.tcl`'s instance-entry facts:
   * self-recursive / self-tail parameters are widened to infinity with no
     narrowing step (fib `n` [-inf, 22]; loop-count `drive`'s `i` [-inf,
     500]; refined-checks `check`'s `n` [-inf, 400]);
   * captured Ints have no range inside a closed closure (sum-refined:
     `step`'s `n` is [1, 400] at the capture site and [-inf, +inf] inside);
   * in refined-checks the scanners are additionally blocked by (2).

   Estimated removable: fib 11-23%, loop-count 26%, sum-refined 6-19%,
   refined-checks 0.1% (about 4% once (2) is fixed).
2. **The native-body bridge (C1, refined-checks only; the largest single
   item in the suite).** `native::ExpandNativeBodies` substitutes a
   predicate's native body before HIR exists. That (a) erases the predicate's
   refinement, so the benchmark's own "statically redundant" inner
   `Emailish?(s)` runs anyway: **37.8%** of refined-checks' instructions,
   26% of the whole canonical suite's. It also (b) leaves a dead
   callee-position `fnvalue` whose open generic instance shares, and so
   poisons, the closed scanner closures' entry facts.
3. **Exact calls to tiny closed callees stay machine calls (C3).**
   * loop-count's `work<int>` compiles to `mov eax,0xf; ret`, but is still
     called 500 times, because termination is not an effect fact (28.5%).
   * sum-refined's closed closure `step` is not inlined, because the
     tiny-leaf inliner requires an environment-free callee (~42%).
   * refined-checks' `char_at` region producer is a real call per character
     (~10%).
4. **Per-character String work through out-of-line helpers over
   character-indexed regions (C1 canonical; recurs in the supplemental
   string workloads).**
   * 66.0% of refined-checks runs inside four region helpers.
   * 28.6% is the non-ASCII path, which re-seeks from byte 0 on every
     access: 112,000 UTF-8 bytes walked per run.
   * Even on ASCII input, a 1-byte compare against a 1-character literal
     costs 53 instructions.
5. **Frame and calling-convention cost (C4, backend/ABI territory).**
   * There is no shrink-wrapping: fib's 28,657 leaf calls per run execute
     the full callee-saved save/restore (10.8%).
   * The VM pointer travels as an ordinary argument, staged through a
     callee-saved register (fib 7.2%).

Register-allocator waste is not a finding: block-locally dead or redundant
moves are 0-2.4% of executed instructions, and the rest of the move traffic
serves the calling convention.

Naming: **R1-R7** are the root mechanisms (candidates); **C1-C4** are the
spec's commonality classes (present in 1-4 canonical workloads).

**Recommendation: one clear, if moderate, winner.** The next milestone is
**M9: instance-entry Int facts**. It adds a narrowing step for
self-recursive/self-tail parameter ranges, and transports captured-binding
ranges into closed closures, both in `hir/range.tcl`. Of the mechanisms
found, it is the only one that:

* is measured in all four workloads without being backend/ABI territory
  (R5) or a small, GC-sensitive residue (R6);
* reduces to one analysis layer;
* already has its consumers (raw parameters, raw compares, M6 branch
  lowering: sum-refined's own `n` shows the finished shape);
* changes no runtime representation, type, ABI or source.

Its expected size is moderate: 6-26% of executed instructions per scalar
workload, as upper bounds, with smaller wall-time gains. The native-body
bridge (2) is the strongest isolated finding: larger in absolute terms,
cheap, and a prerequisite for M9 to reach refined-checks' scanners. It is
ranked second only because exactly one predicate in one benchmark exercises
it. Details, scorecards and the choice between the two are in
[Recommended next milestone](#recommended-next-milestone).

## Canonical benchmark set

The repository's canonical benchmark set is **`bench/*.ir`**. It is the
default input of `bench/bench.tcl`, the only programs CI's
`.github/workflows/bench.yml` times, and the set `NATIVE-AUDIT.md` ("four IR
benchmarks"), `POST-NATIVE-STACK-AUDIT.md` ("the four benchmarks"),
`POST-CALL-EFFECTS-AUDIT.md` and `COMPREHENSIVE-GENERATED-CODE-AUDIT.md`
§8 baseline. The M8.a concat-heavy workloads (`ai_text_clean`,
`string_reverse`, `string_replace`, `csv*`, `matmul`) and `uri-steady` are
**not** canonical. They appear below only as labelled supporting evidence.

| benchmark | input / workload | backend | expected value | canonical timing methodology |
|---|---|---|---|---|
| `bench/fib.ir` | naive recursive `fib(22)`: 57,313 calls | Cranelift, specialized (default: M8.a on, tiny-leaf inlining on, M7.c.1 fence) | `17711` | `tclsh9.0 bench/bench.tcl -runs 5 -markdown`: one untimed warm-up, best of 5 runs, JIT compile excluded (`native::measure`), in one subprocess |
| `bench/loop-count.ir` | `drive(500, 0)`: 500 iterations, each calling `work(i)` (a loop that breaks on its first pass) | same | `3500` | same |
| `bench/sum-refined.ir` | `sum(400, 0)`: self-tail loop over an `integer?`-refined accumulator, a closure `step` created and called per iteration | same | `80200` | same |
| `bench/refined-checks.ir` | `check(400, …)` twice: `Emailish?` on `"café@例え.テスト"` (outer and a statically redundant inner re-check) and on `"not-an-email"`; `UriQueryValue?` on `uriEscape("a b")` | same (not lowerable with `-specialize 0`: `UriQueryValue?` has no native implementation unless specialization decides it) | `[400, 0]` | same |

## Methodology

* **Tree:** `67fcc57`, M8.a default on, M7.c.1 fence active, frozen
  sources.
* **Environment:** Tcl 9.0.1, rustc 1.98.1 (release `native/`, `debug = 1`),
  valgrind 3.22, Go 1.24.7, Python 3.11.15. The host is a shared 4-vCPU
  Intel Xeon container (`baseline/environment.txt`).
* **Timing:** the canonical command, repeated in **5 independent sessions**
  (`tools/baseline.sh`, the same procedure as the comprehensive audit's
  `bench-baseline.sh`), with the median reported. Native-only variants use
  `tools/variants.tcl`: M8.a on, `-virtual-construction-opt 0`
  (historical), and `-specialize 0` (= `cranelift-generic`); each is 5
  sessions × best of 5 and of 200 runs, with JIT excluded.
* **Causal evidence is callgrind, not time.**
  * `tools/audit-native.patch` is applied to a scratch copy of `native/`,
    never to the tree. It adds two things only:
    * a named `botlish_audit_run` frame around each timed run, so
      `--toggle-collect` counts exactly program execution, excluding JIT
      compilation and between-run `Vm::reset`;
    * an env-gated, compile-time-only dump of every JIT function's address
      range and bytes.
  * The generated machine code is **identical** to production: per-function
    sizes and program values were checked for all four programs.
  * `tools/cgprof.py` attributes every executed instruction to a Botlish
    function (direct entry or generic entry) or a named runtime/libc
    function. It counts calls and inclusive helper costs, and classifies
    every executed JIT instruction by role: frame, tag test, overflow check,
    Bool word, retag/untag, completion check, stack traffic, moves, calls,
    and so on. Patterns are documented in the tool.
  * `tools/moves.py` separates block-local dead/redundant moves from moves
    that serve the calling convention.
  * Profiles collect 20 runs (fib, refined-checks) or 2,000 runs (the
    microsecond-scale programs), divided back to one run.
  * callgrind counts are exactly reproducible.
* **Deterministic counters** come from `native::allocationReport`
  (allocations by kind/site, GC, copies, UTF-8 seek bytes, M8.a construction
  counters).
* **Static data** come from the existing tools, unchanged, on the current
  tree: `comprehensive-generated-code/tools/probe.tcl` and `census.tcl`, and
  `m8a-virtual-construction/tools/census.tcl`.
* **Counterfactuals** are instruction counts that would disappear under a
  stated change, derived per instruction (`candidate-matrix.md`). One
  counterfactual was *measured* rather than derived: the non-ASCII cost of
  refined-checks, via `probes/refined-checks-ascii.ir`, a copy of the
  benchmark under `audit/` whose one non-ASCII address is replaced by an
  ASCII address of identical per-character control flow. Call counts are
  identical in the two profiles. The benchmark itself is unmodified.
* **Correctness controls:** interpreter and Tcl-compile timings are shown
  only as controls; every session agreed on every value across all backends.

## Current baseline timings

Canonical command, 5 sessions × best of 5 (`baseline/summary.md`); median
[min-max]:

| program | Cranelift | Rust | Go | Python | Tcl compile | Tcl interp |
|---|---:|---:|---:|---:|---:|---:|
| `fib.ir` | **138.13 µs** [136.31-181.72] | 39.35 µs | 75.39 µs | 1.9 ms | 58.5 ms | 8.08 s |
| `loop-count.ir` | **1.05 µs** [1.01-1.60] | 0.29 µs | 0.89 µs | 92.53 µs | 1.5 ms | 214.4 ms |
| `refined-checks.ir` | **317.11 µs** [258.46-442.79] | 115.45 µs | 147.99 µs | 2.0 ms | 7.2 ms | 274.8 ms |
| `sum-refined.ir` | **0.56 µs** [0.56-0.77] | 0.99 µs | 0.71 µs | 129.84 µs | 19.8 ms | 128.6 ms |

Native variants, 5 sessions × best of 200 (`baseline/variants.txt`),
median, alongside the deterministic instruction counts:

| program | M8.a on | M8.a off | cranelift-generic | Ir/run on | Ir/run off | Ir/run generic |
|---|---:|---:|---:|---:|---:|---:|
| fib | 135.37 µs | 112.85 µs | 176.06 µs | 2,378,489 | 2,378,489 | 2,808,336 (+18.1%) |
| loop-count | 1.01 µs | 1.06 µs | 1.32 µs | 17,545 | 17,545 | 29,555 (+68.5%) |
| sum-refined | 0.56 µs | 0.56 µs | 1.58 µs | 12,437 | 12,437 | 28,058 (+125.6%) |
| refined-checks | 316.93 µs | 328.26 µs | unsupported | 5,437,827 | 5,436,164 | -- |

The host is noisy: session spreads reach 33-71%, and fib's M8.a on/off
difference, 135 vs 113 µs, comes from **byte-identical NIR and identical
instruction counts**. Timings here are sanity checks only; every causal
statement below rests on counts.

## Static corpus anatomy

| | fib | loop-count | sum-refined | refined-checks |
|---|---:|---:|---:|---:|
| used instances / NIR functions | 2 / 2 | 3 / 3 | 4 / 3 | 39 / 33 |
| generic functions (excl. `<program>`) | 0 | 0 | 0 | 21 |
| machine-code bytes (M8.a off → on) | 394 → 394 | 395 → 395 | 286 → 286 | 14,898 → 15,289 |
| static instructions (direct entries) | 93 | 86 | 62 | 3,268 |
| of which frame / tagged-Int / Bool word / stack / completion / moves | 20/12/5/6/0/23 | 27/10/6/6/0/14 | 25/9/0/7/0/9 | 683/200/233/390/82/689 |
| NIR `guard` sites | 0 | 0 | 0 | 3 (all in cold generic entries) |
| allocation sites that execute | 0 | 0 | 0 | 13 (all startup) |
| helper-op sites | 0 | 0 | 0 | ~50 (18 `regioneq`, 6 region class, 2 `regioncheck`, 5 `strlen`, 5 `listget`, …) |
| `call` / `callenv` / `callmulti` / `callvalue` / `tail` | 3/0/0/0/0 | 2/0/0/0/1 | 2/0/0/0/1 | 32/2/12/0/11 |
| exact calls (with a `may_error` check) | 3 (0) | 2 (0) | 2 (0) | 46 (38) |
| safepoints / root slots / entry-zero slots | 4/3/1 | 2/5/0 | 3/6/0 | 74/112/19 |

Sources: `static/*/probe/summary.txt`, `effects.txt`, `roots.txt`;
`static/*/construction/functions.txt`; `profiles/*/cranelift/static-mix.txt`.

About 6 KB of refined-checks' 15 KB is static code that never runs hot.
The two copies of the `Emailish?` chain (functions 17-24 and 25-32, one
per expanded call site) and two never-executed `<generic>` predicate
instances (18, 26: 752 B each) account for most of it.

## Dynamic corpus anatomy

Per run (`profiles/*/cranelift/profile.txt`, `dynamic/alloc-*.txt`):

| | fib | loop-count | sum-refined | refined-checks |
|---|---:|---:|---:|---:|
| executed instructions (Ir) | 2,378,489 | 17,545 | 12,437 | 5,437,827 |
| per unit of work | 41.5 / call | 35.1 / iteration | 31.1 / iteration | 4,489 / predicate call; 467 / char (café), 266 / char (ASCII) |
| data reads / writes | 343,881 / 458,505 | 1,510 / 2,511 | 807 / 2,409 | 900,098 / 704,717 |
| conditional branches (mispredicted) | 171,938 (20,297: the data-dependent `n < 2`) | 2,002 (1) | 1,201 (1) | 847,271 (57,750) |
| L1 data misses | ~0 | 0 | 0 | ~10 |
| Botlish → Botlish calls | 57,313 | 501 | 401 | 20,835 (15,200 `callmulti` to `char_at`) |
| `callenv` / `callvalue` executed | 0 / 0 | 0 / 0 | 0 / 0 | 4 / 0 (startup) |
| runtime-helper calls | 0 | 0 | 0 | 41,243 (39,200 string-region, 1,210 `strlen`) |
| NIR guards executed | 0 | 0 | 0 | 0 |
| bounds/range checks | 0 | 0 | 0 | 15,200 `rt_str_region_check` |
| heap allocations (semantic + private plans) | 0 | 0 | 0 | 20 (18 + 2), startup only |
| allocated bytes | 0 | 0 | 0 | 1,064 |
| GC collections in a run | 0 | 0 | 0 | 0 |
| String bytes / List elements copied | 0 / 0 | 0 / 0 | 0 / 0 | 16 / 35 |
| UTF-8 seek bytes | 0 | 0 | 0 | 112,000 |
| M8.a: plans created / extensions / merges / growths / materializations | 0 | 0 | 0 | 2 / 3 / 2 / 0 / 1 |

Executed-instruction classes, all workloads (`dynamic/class-matrix.md`; the
supplemental columns are supporting evidence):

| class (% of all executed instructions) | fib | loop-count | sum-refined | refined-checks | ASCII probe | *uri-steady* | *ai_text_clean 10K* | *csv 1000* |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| instructions per run | 2,378,489 | 17,545 | 12,437 | 5,437,827 | 3,884,225 | 44.1 M | 36.8 M | 45.2 M |
| **generated code, total** | **100%** | **100%** | **100%** | **33.5%** | **46.9%** | **10.2%** | **10.0%** | **11.7%** |
| frame (prologue/epilogue/zero slots) | 31.3 | 14.4 | 22.7 | 6.5 | 9.1 | 2.4 | 0.6 | 1.9 |
| register moves | 24.1 | 20.0 | 16.1 | 9.1 | 12.8 | 2.2 | 1.8 | 2.6 |
| tagged Int (tag test, overflow, retag, untag) | 15.7 | 28.5 | 25.7 | 3.7 | 5.2 | 0.9 | 0.4 | 1.2 |
| Bool word (materialize + test) | 7.2 | 11.4 | 0.0 | 2.6 | 3.6 | 0.6 | 2.0 | 0.9 |
| stack traffic (root publish, spills, out-params) | 7.2 | 8.6 | 12.9 | 4.3 | 6.0 | 1.6 | 0.7 | 2.1 |
| completion checks | 0 | 0 | 0 | 1.2 | 1.6 | 0.4 | 0.1 | 0.5 |
| call instructions | 2.4 | 2.9 | 3.2 | 1.1 | 1.6 | 0.5 | 0.7 | 0.6 |
| other generated code (arith, cmp, jcc, jmp, imm, lea, memory) | 12.0 | 14.3 | 19.3 | 5.1 | 7.1 | 1.8 | 3.8 | 2.0 |
| **runtime helpers (exclusive)** | 0 | 0 | 0 | **61.4** | **50.3** | **40.6** | **44.3** | **39.8** |
| Rust std inlined out of helpers | 0 | 0 | 0 | 4.2 | 0 | 6.5 | 28.2 | 2.5 |
| **libc (malloc/free/memcpy/memcmp)** | 0 | 0 | 0 | 0.8 | 2.8 | **42.6** | **17.4** | **46.0** |

The canonical set and the supplemental set sit in different regimes. The
canonical four are generated-code and helper bound, with **zero** allocator
cost. The supplemental workloads spend 17-46% in libc allocation and
copying. The allocation story of M8.a is real, but it is a supplemental-set
story.

## Allocation census

| kind | site | count/run | avg bytes | producer | consumer | necessary? |
|---|---|---:|---:|---|---|---|
| List | `web.bot:63` `hex_digits` literal | 1 | 152 | module init | `hex_pair` | persistent semantic (module value) |
| List | `web.bot:65`, `<program>` list literals | 2 | 48 | module init / program | `byte::set`, program result | persistent / final observable |
| Block | `web.bot:67`, `web.bot:70` | 2 | 52 | module closures (`is_unreserved`, `uri_escape_text`) | `callenv` | persistent semantic |
| List | `byte.bot:175` `listnew` + 4 `listappend` | 5 | 40 | collecting `listloop` in `byte::set` | `immutable_set_from_list` | temporary semantic (M8.b "collecting listloop" residual) |
| ImmutableSet | `byte.bot:177` | 1 | 56 | `byte::set` | `is_unreserved` | persistent semantic |
| StringPlan | `web.bot:76`, `web.bot:99` | 2 | 96 | `hex_pair` plan result, `esc_from` accumulator | construct | compiler-private temporary (M8.a) |
| String | `web.bot:99` `substring` | 3 | 41 | `esc_from` per character | `encode_utf8` | temporary semantic (one-character producer String residual) |
| List | `web.bot:85` `encode_utf8` | 3 | 32 | `esc_char` | `list_get`/`list_length` | temporary semantic (`encode_utf8` tiny List residual) |
| String | `web.bot:97` construct flat | 1 | 45 | `esc_from` exit | `q` | final value (the one required materialization) |

That is every allocation of every canonical workload, from
`dynamic/alloc-refined-checks.txt`. fib, loop-count and sum-refined allocate
nothing, and neither does sum-refined with `-specialize 0`. The canonical
totals are:

* 18 semantic + 2 private + 0 unknown objects, 1,064 bytes, all executed
  once per run before the first `check`;
* 0.22% of refined-checks' instructions (`uri_escape_text` 7,544 Ir,
  `byte::set` 2,746 Ir, program setup);
* no allocation in the 800-iteration hot loop.

The scanners' one-character `substring(v, i, i + 1)` calls never allocate:
`char_at` returns a validated StringRegion as three words.

Lifetime: all 20 objects live until the end of the run. The first
collection in any run is the explicit between-run `Vm::reset`, which
reclaims all 20. No canonical object dies young, because none is created
per iteration.

Necessary vs avoidable (spec item 44):

* final observable result: 2 (the escaped `q`, the program's result
  List);
* persistent semantic data: 4 (`hex_digits`, two module Blocks, the
  reserved-byte set);
* temporary semantic: 12 (the `byte::set` input literal and its
  collecting-`listloop` Lists, 3 one-character substrings, 3 `encode_utf8`
  Lists);
* compiler-private temporary: 2 (plans);
* unknown: 0;
* likely-eliminable representation objects: 8 (2 plans + 3 one-character
  Strings + 3 `encode_utf8` Lists) per run in setup, worth about 0.1% of
  instructions.

## Small-object census

Every canonical allocation is small: ≤ 4 elements or ≤ 64 bytes, except the
16-element `hex_digits` List. Bucketed by payload:

| bucket | objects/run | kinds |
|---|---:|---|
| empty | 1 | the `listnew` a collecting `listloop` starts from |
| 1 element / 1 character | 7 | 3 one-character Strings, 3 one-byte `encode_utf8` Lists, a 1-element append result |
| 2-4 | 8 | appends, 2 Block captures, the 4-element set, the 2-element program List |
| 5-16 | 4 | the 16-element `hex_digits`, the 5-character result, 2 plans (8-byte buffers) |
| larger | 0 | |

As a fraction of allocations, tiny temporaries are 14 of 20 (12 temporary
semantic + 2 private plans). As a fraction of runtime they are ≈ 0: they
occur once per run.

In the supplemental set tiny objects dominate:

* `ai_text_clean`: one one-character String per input character
  (`rt_str_decode_char_at`, 595 Ir/call including malloc), 16.2% of its
  instructions;
* `uri-steady`: 14,000 one-character Strings + 14,000 `encode_utf8` Lists
  per 2,000 calls.

There, **allocation count, not bytes, predicts cost**: libc
malloc+free+calloc+realloc is about 34% of `uri-steady`'s instructions,
about 390 instructions per object including its free.

## Runtime-helper census

Canonical, per run, calls from generated code with inclusive cost
(`profiles/refined-checks/cranelift/profile.txt`). fib, loop-count and
sum-refined call **no** helper at all: every `rt_int_add`/`rt_int_cmp`
fallback stays cold.

| helper | mechanism group | calls | Ir/call | inclusive share | input → output | substantial or plumbing? |
|---|---|---:|---:|---:|---|---|
| `rt_str_region_eq` | String traversal / equality | 10,400 | 119.3 (ASCII probe: 53.0) | 22.8% | region (base, char start, char end) + literal → Bool word | mostly plumbing: 1-character region vs a 1-character literal; the non-ASCII path seeks from byte 0 (`char_indices().nth(from)`) and compares via `Take<Chars>` (4.2% alone) |
| `rt_str_region_is_tcl_alnum` | String traversal / classification | 11,200 | 108.4 (66.8) | 22.3% | region → Bool word | half semantic (Unicode category), half plumbing: non-ASCII seek; no ASCII fast path, `get_general_category` is searched even for ASCII |
| `rt_str_region_check` | bounds check | 15,200 | 38.0 | 10.6% | base, i, i+1 → UNIT / RANGE error | plumbing: statically redundant under the scanners' own `i < n` with `n = length(v)` (relational fact), and it makes `char_at` `may_error` |
| `rt_str_region_is_tcl_alpha` | String traversal / classification | 2,400 | 233.0 (67.0) | 10.3% | region → Bool word | same as alnum; the 6 non-ASCII letters take the Unicode-table path |
| `rt_str_len` | String length | 1,210 | 11.0 | 0.24% | String → Int | semantic, once per predicate call |
| `rt_construct` (M8.a) | construction | 6 | 672 | 0.07% | pieces → plan/flat | startup only |
| allocation/list/set/closure helpers | allocation | ~20 | 260-680 | 0.15% | | startup only |

By mechanism: String equality and classification 55.4%, bounds checking
10.6% (together the 66.0% total), allocation 0.15%, tagging
fallbacks 0 (cold), equality on values 0, sets 0.005%.

**66.0% of refined-checks runs inside four region helpers that never call
each other; in the ASCII probe the figure is 52.5%.**

## Representation-transition census

Only transitions actually observed on hot paths:

| transition | where (dynamic count/run) | cost |
|---|---|---|
| raw Int → tagged Int (rbox/`shl`+`or`) → callee re-tests tag → untag (`sar`) | fib: n-1, n-2 for every internal call (57,312); sum-refined: `n` → `step` (400); loop-count: `drive`'s `i` across its own back edge (500); `char_at`'s i+1 (15,200) | 4-6 instructions each + a root store |
| compare (fast path) / `rt_int_cmp` (slow path) → Bool word (`mov r,2` + `cmovCC r,[rip+TRUE]`) → `cmp r,6` → branch | fib (57,313), loop-count (501), refined-checks `check` (802) and the scanners' `i >= n` (~21,200) | 3 extra instructions + 1 constant-pool load each |
| helper result → Bool word → `cmp rax,6` → branch | every Bool-returning region helper call (24,000) | 2 instructions |
| region (base, start, end) → returned through stack out-parameter slots → reloaded → copied into root slots → passed as tagged words to the next helper | `char_at` → scanners (15,200) | ~6 memory ops per character |
| literal String → two dependent loads through the VM constant table (`[vm+0x10]` then `[table+k]`) | each region equality against a literal (10,400) | 2 loads |
| non-ASCII String + char index → UTF-8 re-seek from byte 0 | every region op on the café base (112,000 bytes/run) | O(i) per access |
| String → StringRegion → String / String → UTF-8 List / flat → plan → flat | startup only (3 / 3 / 2 per run) | negligible |

**One representation transition appears under four different source
idioms: "proven-small Int → tagged word → re-tested/untagged on the other
side of an instance-entry boundary".** The idioms are a recursive call
argument (fib), a self-tail loop-carried counter (`drive`, `check`,
scanners), a closure capture (`step`'s `n`) and a region producer's
multi-value result (`char_at`). The compare → Bool word → branch transition
is its companion: it appears exactly where that tagged Int is compared.

No heap temporary pattern exists in the canonical set (Q13). The only
"temporary aggregate" is the register-level region triple.

### Scalar boxing/tagging (spec item 21)

Not negligible, as measured:

* tagged-Int classes are 15.7% / 28.5% / 25.7% of fib / loop-count /
  sum-refined, and 11.0% of refined-checks' generated code;
* Bool words add another 7.2% / 11.4% / 0% / 7.7%.

The first-loss points are:

* **fib `n`** entry range [-inf, 22]: widened, and not narrowed by `n ≥ 2`
  on the recursive edges.
* **loop-count `drive` `i`** [-inf, 500], and **refined-checks `check` `n`**
  [-inf, 400]: the same widening.
* **sum-refined `step`'s captured `n`**: [-inf, +inf] inside, [1, 400] at
  the capture site.
* **refined-checks scanners' `i`, `n`**: [-inf, +inf], because the shared
  closed instances are also called from the open generic predicate instance
  (R2). `n = length(v)` would otherwise carry `collectionLength` [0, 2^62-1].
* The accumulators (fib's result, `total`, `acc`/`x`) are **genuinely
  unbounded** to an interval analysis. Their overflow checks are
  semantically required and stay.

Positive control: `sum`'s own `n` has entry range [0, 400]. It is untagged
once at entry (`rawregs="0 …"`) and runs raw across its loop
(`sub r14,1`, `test r14,r14; je`): 12 instructions per iteration, against
`drive`'s 29 for the same shape with a widened range.

## String traversal census

refined-checks only; the other three have no String operations.

* **Traversal work:** 1,200 predicate calls per run, 11-12 characters each.
  That is 15,200 region productions (`char_at`), 15,200 bounds checks,
  13,600 class tests and 10,400 literal comparisons: up to **7 separate
  re-locations of the same character position** per character.
* **Seek work:** 112,000 UTF-8 bytes walked per run (`utf8SeekBytes`),
  entirely on the non-ASCII base. The ASCII probe walks 0.
* **Decode work:** Unicode general-category lookups for class tests, even
  for ASCII.
* **Allocation:** zero one-character Strings, zero substrings in the hot
  path (regions are never materialized).
* **Length queries:** 1 per predicate call.
* **Repeated prefix scans:** yes. Every non-ASCII region access is O(i),
  and the redundant inner `Emailish?` re-scans the whole string.

Split of the traversal cost:

* ordinary linear traversal, one pass per predicate call: semantic;
* the second pass (R2): artifact, 37.8%;
* algorithmic rescan (O(i) seek per access): artifact, at least 13.9% and
  at most 28.6% together with non-ASCII decoding;
* representation allocation: none;
* decoding for classification: semantic for the 6 non-ASCII letters,
  artifact for ASCII (a table search where a byte test suffices).

The String traversal optimization (`hir/traversal.tcl`, byte offsets
carried across a monotonic scan) does not apply. The scan index flows
through a helper closure (`char_at`) and self-tail recursion of closures,
not a recognized single-function scan, so every consumer re-derives the
byte position from a character index.

## List/aggregate census

* **Lists on hot paths:** none in any canonical workload. The 5 static
  `listget` sites (`hex_pair`, `esc_bytes`, `esc_char`) run 1-4 times per
  run at startup.
* **Product-shaped Lists** (`static/*/construction/products.txt`): **none**
  in any canonical workload. No fixed-index `list_get` remains hot, no
  element-type broadening reaches a hot operation, and no product List is
  allocated.

**The planned struct refactor is not a performance lever for the canonical
set.** For the supplemental csv family it would be semantic cleanliness
first: its product Lists are already scalar-replaced by `hir/escape.tcl`,
per M8.a.

## Call-boundary census

Hot functions (`profiles/*/cranelift/mix.txt`, per call or per iteration):

| function | instance | call form | args in / result out | work inside | boundary-only work |
|---|---|---|---|---|---|
| `fib` | `fib<int>`, closed, recursive | `call`, 57,313 | tagged n (range [-inf, 22]) / tagged Int | compare, 2 subtractions, 1 overflow-checked tagged add | full frame (13/call), VM-pointer staging, entry tag test, Bool word, retag of both arguments, 2 root stores of provably small arguments, 2 root stores of results |
| `drive` | `drive<int,int>`, self-tail loop | 1 `call` + 500 back edges | tagged i ([-inf, 500]), tagged total | compare, subtract, add 7 | tag test, Bool word, untag/retag of i-1, root store of i-1 and of the constant 7 |
| `work` | `work<int>`, closed | `call`, 500 | tagged i / tagged 7 | none: body is `mov eax,0xf` | the whole call (6 instructions + 4 at the call site) |
| `sum` | `sum<int,int>`, self-tail loop | 400 back edges | raw n, tagged acc | compare, decrement | retag of `n` for `step` and a root store |
| `step` | `step<int>`, M7.c closed closure | `call`, 400 | tagged x, tagged captured n / tagged Int | 1 overflow-checked tagged add | frame (7/call), root stores of x and n, joint tag test of n |
| `char_at` | `char_at<generic>`, closed but shared with an open instance | `callmulti`, 15,200 | tagged i, v / region via stack out-params | i+1 and a bounds-check helper | frame (17 of 46), 5 callee-saved spills, VM pointer, out-param stores, completion check |
| `scan_local` etc. | `<generic>`, closed, self-tail | loops, 800 entries | tagged i, n, v | per character: 1 class helper + up to 5 equality helpers | tag tests, Bool words, loop-invariant `v`/`n` re-stored as roots, region triple reloads, 2-load literal fetch |

The only boundary-crossing costs in the canonical set are **scalar
representation and frame/ABI**:

* no materialization of a heap value at any exact call;
* no boxing of a non-Int;
* no unknown result kinds;
* no generic-ABI fallback at a hot site;
* completion checks only where `may_error` is real at the type level (the
  region check).

Function boundaries are still a barrier for **Int facts** (entry ranges)
and for **call overhead** (frames, VM pointer, callee-saved spills). They
are no longer a barrier for heap construction: M8.a took care of that.

**Closures and callables (spec item 28):**

* the only Block allocations are 2 at startup;
* `callenv` runs 4 times per run, at startup;
* 0 `callvalue`;
* dead materialized `fnvalue`s: 2 loads per predicate call (2,400 Ir/run,
  0.04%). Their *cost* is negligible; their *effect* on facts is not (R2).

First-class callable representation is not a common runtime cost.

**Error/completion machinery (spec item 29):**

* fib, loop-count, sum-refined: 0 completion checks executed, since every
  exact call is proven error-free;
* refined-checks: 63,262 completion-check instructions + ~30K `test`/`jcc`
  after `callmulti` (1.2-1.8%). All of it follows from the region check's
  RANGE path, which the scanners' guard already excludes;
* Return/Break/Continue and declared error sets: no executed cost.

## Generic/open-call census

* **Open dispatch:** 0 `callvalue` executed in all four; 4 `callenv` per run
  in refined-checks, at startup. Not worth a milestone.
* **Generic instances:** fib, loop-count and sum-refined have none hot.
  refined-checks' hot generic functions (`char_at`, the scanners,
  `domain_loop`, `tld_ok`) show:
  * no executed guards, no dynamic dispatch, no unknown result kinds;
  * their residual costs are unknown Int ranges (tagged i/n) and helper
    calls.

  They are `<generic>` (key `{any}`) because the M7.c-closed scanner
  instances are shared by the specialized predicate instance
  (`block e332<str>`) and an **open** generic one (`block e332<generic>`,
  InstanceClosed = 0). That open instance exists only because the expanded
  native body sits in callee position and is materialized as a dead
  `fnvalue` (`check`: "materializes Block values: e332 e552").
  `<generic>` itself costs nothing here. The loss of entry facts through the
  open instance does.
* **Specialized vs `cranelift-generic`** (spec item 48): specialization is
  worth +18% instructions on fib, +68% on loop-count and +126% on
  sum-refined. The generic code adds tag guards, completion checks (fib
  generic: 114,626 completion-check instructions), an unfolded `work`
  (7,500 vs 3,000) and an unspecialized `step`. What specialization does
  **not** provide is Int *ranges*: the specialized code's remaining
  tagged-Int work is a range problem, not a kind problem.

## Backend/machine-code census

Hot functions, executed instructions per run by class (`mix.txt`), and
static size (`static-mix.txt`):

| function | bytes | executed/run | frame | moves | tagged Int | Bool word | stack | completion | calls |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `fib` | 328 | 2,378,473 | 745,069 | 573,124 | 372,529 | 171,939 | 171,937 | 0 | 57,312 |
| `drive` | 280 | 14,527 | 15 | 3,504 | 5,002 | 2,004 | 1,501 | 0 | 500 |
| `work` | 14 | 3,000 | 2,500 | 0 | 0 | 0 | 0 | 0 | 0 |
| `sum` | 104 | 4,819 | 11 | 1,204 | 801 | 0 | 801 | 0 | 400 |
| `step` | 77 | 7,600 | 2,800 | 800 | 2,400 | 0 | 800 | 0 | 0 |
| `scan_local` (fn 20) | 776 | 450,000 | 14,400 | 123,600 | 46,400 | 58,400 | 87,600 | 13,600 | 19,600 |
| `char_at` (fn 19) | 256 | 460,000 | 170,000 | 130,000 | 50,000 | 0 | 30,000 | 20,000 | 10,000 |
| `scan_label` / `scan_alpha` / `domain_loop` / predicate body | 536 / 440 / 616 / 664 | 71,200 / 70,400 / 37,200 / 58,800 | | | | | | | |

Patterns shared by the hot functions of 3-4 workloads (Q43):

1. **Full frame on every call**, including leaf paths.
   * `push rbp; mov rbp,rsp; sub rsp,N`, every callee-saved register the
     function uses stored and restored, and entry root-slot zeroing.
   * Cranelift has no shrink-wrapping: fib's 28,657 leaf calls execute 9
     frame instructions they do not need (10.8% of fib).
   * The frame pointer itself is required by the native frame walker.
2. **VM pointer as an ordinary argument.**
   * It arrives in `rdi`, is parked in a callee-saved register (`mov
     rbx,rdi`, with that register saved and restored), and is moved back
     into `rdi` before every call.
   * It accounts for 10-20% of all moves, 2.4-3.4% of generated-code
     instructions.
3. **Tagged counter with a BigInt slow path.**
   * `test r,1; jne`, then `mov r,2; cmp; cmovCC r,[rip+TRUE]; cmp r,6;
     je`.
   * On arithmetic: `sar`, raw op, `shl`, `or`, or `add; seto; test; jcc`.
4. **Root stores at definitions.**
   * They include provably small Ints (fib's n-1/n-2, the constant 7,
     tagged 1) and loop-invariant values re-stored each iteration.
   * They also include values that are only live across a *cold*
     slow-path safepoint (`step`'s x, `drive`'s total).

Register moves (Q40), from `profiles/*/cranelift/moves.txt`:

* Moves are 16-27% of executed generated code.
* Block-locally dead or redundant moves are only fib 2.4% (two dead `mov
  r12,rsi` per internal call in the retag sequence), refined-checks 0.2%,
  and 0 elsewhere.
* The rest serve the calling convention:
  * incoming arguments into callee-saved registers: 40% of fib's moves,
    22% of refined-checks';
  * argument setup: up to 21%;
  * VM pointer: 10-20%;
  * results in `rax`: 10-40%;
  * join/loop-carried copies before `jmp`: 12-29%.

Not register-allocator sloppiness; call-boundary and block-parameter
traffic.

**Memory traffic (spec item 30).** fib's 458,505 data writes per run are
100% frame/ABI/root: prologue saves, root stores, return addresses. Its
343,881 reads are 100% epilogue restores and constant-pool `cmov` loads.
There are no heap loads or stores at all, and L1 misses are ~0.
refined-checks' traffic is dominated by the helpers (577K of 900K reads).
Its generated code adds 158K root/stack stores and 70K reloads (the region
out-parameter round trip).

**Other backend-quality items**, each small:

* `add; seto; test; jcc` instead of `add; jo`: 2 extra per checked add;
* `cmovCC` from a constant pool instead of an immediate `setcc`/`lea`;
* helpers called via `movabs r11, imm64; call r11`;
* slow-path argument shuffles scheduled on the fast path: fib's `mov
  rdx,r13; mov rsi,rax; mov rax,rdx` around the add, 3.6%.

**Guards and bounds (spec item 22).**

* Representation guards executed: 0 in all four.
* Declared-contract checks: 0.
* Bounds checks: 15,200 region checks per run in refined-checks. They are
  *statically redundant* (the scanner has just tested `i < n`, `n =
  length(v)`), but not provable with intervals alone, since that needs the
  relational fact `i < length(v)`.
* Guard count is correctly *not* the metric any more. The residual checks
  are implicit tag tests inside tagged operations, which the table above
  counts.

**Code size vs runtime (spec item 31).**

* fib, loop-count and sum-refined: 286-395 bytes, all hot.
* refined-checks: 15.3 KB, about 4.5 KB of it hot (scanners, `char_at`,
  predicate bodies). About 6 KB is cold duplication (R2) and about 5 KB
  URI/`byte::set` startup code. I-cache misses: 218 per run.
* No candidate below is ranked by bytes.

## Construction plans after M8.a

In the canonical set, per run:

* 2 plans created, 3 extensions, 2 merges, 0 growths, 1 materialization;
* 8 bytes moved into plans, 0 bytes moved by growth;
* `rt_construct` 6 calls, 4,031 Ir (0.07% of refined-checks).

M8.a's NIR is **identical** on and off for fib, loop-count and sum-refined.
On refined-checks it adds 391 bytes (+2.6%) of startup-only code and 1,663
instructions per run (+0.03%): building a plan for a 5-character result
costs slightly more than two eager `strcat`s. **Plans are not significant in
any canonical workload.** The code-size growth is harmless and does not
motivate profitability heuristics (Q38-39).

Supplemental, as an isolated finding: `ai_text_clean` 10K spends 15.5%
inclusive in `rt_construct`. That is **341 exclusive instructions per
1-byte extension**, including 2 indirect branches for piece decoding. Plan
management is cheap relative to the quadratic copying it replaced, but not
cheap per piece. Record it for whoever next touches `construct.rs`.

## Per-workload top findings

"Waste" = potentially avoidable representation/compiler work, not the
semantic workload. Estimates are upper bounds on executed instructions per
run (`candidate-matrix.md`). Confidence reflects how directly the
instruction accounting supports the estimate.

### fib (2,378,489 Ir; 57,313 calls)

| # | mechanism | dynamic evidence | static evidence | root cause | confidence |
|---:|---|---|---|---|---|
| 1 | leaf calls run the full frame (callee-saved save/restore, `sub`/`add rsp`, zero slot) | 257,913 (10.8%) | 20 of 93 instructions are frame | Cranelift: no shrink-wrapping (backend) | high |
| 2 | Bool word for `n < 2` | 171,939 (7.2%) | `cmovl r10,[rip+…]; cmp r10,6` | tagged compare with slow path (R1: range lost) | high |
| 3 | VM pointer staging (`mov rbx,rdi`, `mov rdi,rbx`, rbx save/restore) | ~172K (7.2%) | every call | Botlish ABI: VM pointer as an argument (backend/ABI) | high |
| 4 | untag/retag around n-1, n-2 for tagged call arguments | 143,280 (6.0%) | `sar; sub; shl; or` | tagged-only exact-call ABI + range lost (R1) | high |
| 5 | entry tag test on n | 114,626 (4.8%) | `test rsi,1; jne` | n's entry range [-inf, 22]: `widen` without narrowing (R1) | high |
| 6 | slow-path argument shuffles on the fast path of the result add | 85,968 (3.6%) | `mov rdx,r13; mov rsi,rax; mov rax,rdx` | codegen fast/slow layout (backend) | medium |
| 7 | root stores of provably small arguments n-1, n-2 | 57,312 (2.4%) | 2 stores per internal call | `roots.rs` ignores smallness of `rbox` results (R6), and R1 | high |
| 8 | dead moves in the retag sequence | 57,312 (2.4%) | 2 dead `mov r12,rsi` | regalloc (backend) | high |
| 9 | entry root-slot zeroing | 57,313 (2.4%) | 1 entry-zero slot | GC slot protocol (R6) | medium (may be required by the slot layout) |
| 10 | `seto/test/jcc` instead of `jo` on the result add | 57,312 (2.4%) | 3 vs 1 instruction | backend | high |

Not waste: the result add's overflow check itself (arbitrary precision,
unbounded), the recursion, and the data-dependent branch mispredicts
(20,297/run).

### loop-count (17,545 Ir; 500 iterations)

| # | mechanism | dynamic evidence | static evidence | root cause | confidence |
|---:|---|---|---|---|---|
| 1 | call to `work<int>`, whose body is `return 7` and whose result is already replaced by the constant 7 | 5,000 (28.5%) | `%11 = call 1 %0` (result unused), `%12 = int 7` | R3: no termination fact / inliner decides on the pre-simplification HIR shape | high |
| 2 | loop-carried `i` tagged: tag test, untag/retag, root store of i-1 | 3,002 (17.1%) | `drive` not `rawregs` 0 | R1: entry range [-inf, 500] from `widen` | high |
| 3 | Bool word for `i <= 0` | 1,503 (8.6%) | `cmovle rcx,[rip+…]` | R1 (slow-path join) | high |
| 4 | loop-carried register copies before `jmp` | 1,000-1,500 (6-9%) | `mov rbx,r12; mov r14,rax` | block parameters (backend) | medium |
| 5 | root stores of the constant 7 and of `total` (live only across the cold `rt_int_add`) | 1,000 (5.7%) | `mov [rsp+0x10],0xf` | R6 | high |
| 6 | `seto/test/jcc` on the `total` add | 1,000 (5.7%) | | backend | high |
| 7 | tag test on `total` (range [0, +inf]; really ≤ 3,500) | 1,000 (5.7%) | | needs trip-count/induction reasoning (not R1) | low value |
| 8 | VM pointer `mov rdi,r13` per `work` call | 500 (2.9%) | | ABI | high |

Items 9-10: nothing else above 1%.

### sum-refined (12,437 Ir; 400 iterations)

| # | mechanism | dynamic evidence | static evidence | root cause | confidence |
|---:|---|---|---|---|---|
| 1 | call to the closed closure `step<int>` per iteration | ~5,200 (42%) | 77-byte callee, 7 frame instructions per call | R3: tiny-leaf inliner requires an environment-free callee | high |
| 2 | captured `n` tagged across the closure boundary: retag in `sum`, root stores in `sum` and `step`, joint tag test | 2,000-2,400 (16-19%) | `step` has no `rawregs` | R1: capture ranges not transported (+ tagged-only ABI) | high |
| 3 | `step`'s frame (7 per call) | 2,800 (22.5%) (inside #1) | | R3 / R5 | high |
| 4 | root stores of `x` in `step` (live only across the cold `rt_int_add`) | 400 (3.2%) | | R6 | medium |
| 5 | `seto/test/jcc` | 800 (6.4%) | | backend | high |
| 6 | loop-carried copies | 800 (6.4%) | | backend | medium |
| 7 | VM pointer per call | 400 (3.2%) | | ABI | high |

Not waste: the `acc + n` overflow check and tag test on `acc`, which is
genuinely unbounded. The `integer? acc` refinement check is already gone.

### refined-checks (5,437,827 Ir; 1,200 predicate calls)

| # | mechanism | dynamic evidence | static evidence | root cause | confidence |
|---:|---|---|---|---|---|
| 1 | the benchmark's "statically redundant" inner `Emailish?(s)` is executed | 2,054,000 (37.8%) | call arg typed `str`; unexpanded HIR types it `str[Emailish]` | R2a: refinement erased by pre-HIR native-body expansion | high |
| 2 | non-ASCII representation path: O(i) re-seek from byte 0 per region access, re-decode, Unicode tables | 1,553,602 (28.6%) upper bound, ≥ ~0.75M pure re-seek | 112,000 seek bytes/run; ASCII probe identical control flow | R4: StringRegion carries char indices; traversal byte offsets not carried through closures | high (measured) |
| 3 | 1-character literal comparisons through `rt_str_region_eq` | 10,400 calls, 22.8% inclusive (ASCII: 53 Ir per 1-byte compare incl. a `memcmp` call) | 18 static `regioneq` sites | R4: helper-only region equality, no inline/literal fast path | high |
| 4 | class tests through `rt_str_region_is_tcl_alnum/alpha` | 13,600 calls, 32.6% inclusive (ASCII: 67 Ir, a Unicode table search) | | R4: no ASCII fast path | high |
| 5 | `char_at` is a real `callmulti` per character | ~562K (10.3%) | 256 bytes, 17 frame instructions per call | R3 (closed-closure inlining) + R2b (shared with the open instance) | high |
| 6 | region bounds check the scanner has already implied | 577,600 (10.6%) + completion checks | 15,200 `rt_str_region_check` | relational `i < length(v)` not tracked | high |
| 7 | scanners' tagged `i`, `n`: tag tests, Bool words, overflow checks on i+1 | ~240-330K (4.4-6.1%) | `<generic>` scanners, ranges [-inf, +inf] | R1 blocked by R2b | medium |
| 8 | scanner root/stack traffic (loop-invariant `v`/`n` re-stored, constant 1 stored, region triple via out-param slots) | ~228K stack instructions (4.2%), ~60-100K avoidable | 390 static stack instructions | R6 + multi-value return ABI | medium |
| 9 | completion checks after helpers and `char_at` | ~93K (1.7%) | 38 of 46 exact calls `may_error` | follows from #6 | high |
| 10 | Bool words from helpers and `or`-chain joins | ~110K (2%) | | helper ABI returns Bool words; join lowering | medium |

Static-only: a duplicated predicate chain (~4.8 KB) and two never-executed
generic predicate instances (1.5 KB), both R2; dead `fnvalue` loads (0.04%).
Rows 1-10 overlap: the redundant check (#1) contains its share of #2-#10.
After #1, the others apply to the remaining 62%.

## Cross-workload root-cause matrix

Merged by root mechanism. Percentages are estimated avoidable executed
instructions.

| root mechanism | fib | loop-count | sum-refined | refined-checks | commonality | estimated significance |
|---|---:|---:|---:|---:|---|---|
| **R1** Int facts lost at instance-entry boundaries (recursive widening w/o narrowing; captures unranged) → tagged counters, Bool words, retag, small-Int roots | 11-23% | 26% | 6-19% | 0.1% now; ~4% after R2 | **C4** symptom, **C3** unblocked | moderate everywhere; the only mechanism common to all four with one analysis layer |
| **R2** native-body bridge: (a) refinement erased, (b) dead callee-position `fnvalue` → open generic instance poisons shared closed callees | -- | -- | -- | 37.8% (+ unblocks R1/R3 there) | **C1** (one predicate) | largest single item in the suite (26% of all canonical instructions) |
| **R3** exact calls to tiny closed callees stay calls (inliner: env-free, straight-line, safe-op rules; no termination fact) | 0 (recursive) | 28.5% | ~42% | ~10% | **C3** | large in the µs-scale programs; moderate in refined-checks |
| **R4** per-character String work in out-of-line helpers over char-indexed regions (+ O(i) re-seek) | -- | -- | -- | 40-50% (overlaps R2) | **C1** canonical (recurs in all supplemental string workloads) | dominant in refined-checks and in supplemental text workloads |
| **R5** frame / calling convention (no shrink-wrapping, VM pointer argument, frame pointer, callee-saved staging) | ~18% | ~3% (+ `work`'s frame in R3) | ~3% (+ `step`'s frame in R3) | ~1-3% | **C4** | backend/ABI territory |
| **R6** root publication (zero slots, constants, cold-only safepoints, loop invariants; small Ints beyond R1) | 2.4% | 5.7% | 3.2% | 1-2% | **C4** | small; GC-sensitive |
| **R7** Bool-word branches | 7.2% (in R1) | 8.6% (in R1) | 0 | ~2% | C3 (mostly a consequence of R1) | disappears with R1 |
| backend micro-quality (`seto`, constant-pool `cmov`, fast-path shuffles, dead moves) | ~8% | ~6% | ~6% | small | C4 | backend territory |
| allocation / materialization / M8.a plans | 0 | 0 | 0 | 0.2% (startup) | none | **not a canonical cost** |

### Commonality classes (spec item 34)

* **C4 (all four):**
  * the tagged-Int-at-boundary *symptom* (R1);
  * frame/calling convention (R5);
  * root publication (R6);
  * backend micro-quality;
  * register-move traffic (a symptom of R5/R3).
* **C3:** exact calls to tiny closed callees (R3: loop-count, sum-refined,
  refined-checks); R1's currently-unblocked benefit (fib, loop-count,
  sum-refined); Bool words (fib, loop-count, refined-checks).
* **C2 dominating its two:** none. Every two-workload mechanism is also
  present in a third.
* **C1:** native-body bridge (refined-checks); per-character region
  helpers (refined-checks among canonical; all supplemental text
  workloads); a missing termination fact (loop-count's `work`).

### Root-cause classes the data support (spec item 35)

* **Lost scalar/range fact:** R1, and the relational `i < length(v)`.
* **Lost semantic fact at a pre-HIR rewrite:** R2a.
* **Call-boundary representation loss:** R1's tagged ABI part; the
  region triple via stack out-params.
* **Unnecessary call:** R3.
* **Runtime-helper abstraction cost:** R4.
* **Repeated traversal:** R4's re-seek, R2a's second scan.
* **GC/root overhead:** R6.
* **Backend/register movement:** R5, backend micro-quality.

Premature materialization, unnecessary allocation, unnecessary copying and
dynamic dispatch are **not supported** by canonical data.

## First-loss analysis

**R1 -- Int facts at instance entry.** The work becomes inevitable when
`hir/range.tcl` computes an instance's entry range. There are three first
losses:

* `hir::range::widen` (line 352) pushes any bound that moved to infinity
  across self-recursive feedback, and no narrowing pass re-applies the
  body's branch narrowing afterwards. `n ≥ 2` on fib's recursive edges, and
  `i > 0` on `drive`'s and `check`'s, would give [0, 22], [0, 500] and
  [0, 400].
* A captured binding has no range inside a closed closure (`step<int>`'s
  `n`).
* For refined-checks, the open generic instance of R2b joins unknown facts
  into the closed scanners.

Downstream consumers already act on proven ranges: the raw-parameter choice
(`rawregs`), raw compares that fuse with the branch, M6 range-decided
branches, and `roots.rs` never rooting raw registers. Their positive control
is sum-refined's `n`. The fix belongs in the analysis, not the backend. A
second, optional stage is a raw-Int calling convention for closed exact
instances: M8.a's plan-parameter pattern, applied to proven-small Ints. It
would remove the remaining retag at callers and untag at callees
(fib: +12%).

**R2 -- native-body bridge.** The loss becomes inevitable at
`native::ExpandNativeBodies` (`native/native.tcl`). It rewrites `(call (ref
Emailish?) s)` into `(call (block (v) …) s)` before `hir::build`, so:

* the predicate's identity is gone before refinement analysis runs. The
  unexpanded HIR types the inner argument `str[Emailish]` (verified); the
  expanded HIR types it `str`;
* the block literal in callee position is materialized as a Block value
  (`check` "materializes Block values: e332 e552"), creating an open
  `<generic>` instance whose never-executed calls reach the same closed
  scanner instances.

That file's own header already names the fix direction: expand after
`hir::build`'s resolution, keyed on a call's resolved target.

**R3 -- tiny closed callees.** The losses are in `native/lower.tcl`'s
`LeafInlineEligible`: environment-free, straight-line HIR body, safe-op
family only.

* `step` is an M7.c closed closure, whose capture is already passed as an
  ordinary argument, but it is not environment-free.
* `char_at` is a closed closure containing `regioncheck` (not a safe op),
  shared with R2's open instance.
* `work`'s HIR body has a `loop`, although its lowered body is `return 7`.
  Its call site already consumes the result fact, `{7}`. The call itself
  stays because the effect summary has `may_error=false may_gc=false` but
  no termination fact.

**R4 -- per-character String work.** There are two first losses:

* `hir/stringregion.tcl`'s StringRegion is `(base, char start, char end)`.
  Character indices, not byte offsets, cross every region consumer, so each
  non-ASCII consumer re-seeks. Byte offsets are carried only by
  `hir/traversal.tcl`'s recognized single-function monotonic scans.
* Region operations exist only as runtime helpers (`native/lower.tcl`
  emits `op regioneq`/`strregiontclalnum` → `rt_*` calls), with no inline
  fast path for a 1-character ASCII literal or an ASCII class.

**R5 -- frame/calling convention.** The losses are in the backend and ABI:

* Cranelift has no shrink-wrapping;
* the frame pointer is required by the native frame walker;
* the VM pointer is an ordinary first argument, not a pinned register
  (Cranelift supports a pinned register).

**R6 -- root publication.** The loss is in `native/src/codegen/roots.rs`:

* root candidacy is by register kind ("managed-capable"), not by range, so
  an `rbox` of a proven-small raw Int is rooted;
* publication happens at definition, not at the (possibly cold) safepoint;
* loop-invariant values are re-published at every back edge.

## Candidate dependency graph

```
native::ExpandNativeBodies (pre-HIR substitution)            [R2]
 ├─► predicate identity lost ─► refinement lost ─► redundant inner Emailish? (37.8% of refined-checks)
 └─► callee-position block → dead fnvalue → open generic instance
       └─► closed scanners/char_at shared with it ─► <generic>, entry facts unknown ─┐
hir::range::widen without narrowing (fib n, drive i, check n)       [R1]              │
captured bindings unranged in closed closures (step n, scanner n)   [R1]              │
                                                                                      ▼
            tagged counters: entry tag tests; BigInt slow-path compares ─► Bool words [R7]
                             untag/retag; overflow checks on counters
                             root stores of small Ints ───────────────────► part of [R6]
tagged-only exact-call ABI (optional R1 stage) ─► caller retag + root, callee untag
i < length(v) not relational ─► rt_str_region_check (10.6%) ─► char_at may_error
                                                  ─► completion checks up the chain
                                                  ─► regioncheck blocks inlining ─► [R3]
inliner: env-free / straight-line / safe-op; no termination fact ─► step, char_at, work stay calls [R3]
                                   └─► frames, VM staging, argument retag/roots at call sites (part of [R5]/[R6])
char-indexed StringRegion + helper-only region ops ─► per-character helper calls, O(i) re-seek [R4]
Cranelift/ABI: no shrink-wrap, VM pointer argument, frame pointer ─► frames + moves in all four [R5]
```

**No double counting:**

* R7 is inside R1's estimates.
* R3's `work`/`step`/`char_at` frames are inside R3, not R5.
* R1's small-Int roots are inside R1, not R6.
* In refined-checks, R2a's 37.8% contains its own share of R1/R3/R4. Those
  percentages are over the whole run, so after R2 they apply to the
  remaining ~62%.

## Estimated maximum wins

| candidate | fib | loop-count | sum-refined | refined-checks | canonical suite total (7.85 M Ir) | upper bound on the *time* win |
|---|---:|---:|---:|---:|---:|---|
| R1 facts only (narrowing + captures) | 10.8% | 25.7% | 6-10% | 0.1% (4.4% after R2) | 3.5% | smaller than instruction share: removed instructions are cheap, well-predicted ALU/branches plus some stores |
| R1 + raw-Int ABI stage | 22.9% | 25.7% | 16-19% | same | 7.1% | |
| R2 native-body bridge | -- | -- | -- | 37.8% (+ unblocks ~4-10%) | 26.2% | close to proportional: removes whole helper-heavy predicate executions |
| R3 tiny closed callees | 0 | 28.5% | ~42% | ~10.3% | 7.2% | proportional minus inlined residue |
| R4 per-character String work | -- | -- | -- | 40-50% (overlaps R2; ~25-30% after it) | 28-35% | proportional (helper calls and seeks) |
| R5 frame/ABI (backend) | ~18% | ~3% | ~3% | ~1-3% | ~7% | memory-op heavy; possibly larger than the instruction share |
| R6 root publication beyond R1 | 2.4% | 5.7% | 3.2% | ~1.5% | ~1.8% | stores |
| allocation / plans / fusion / structs | 0 | 0 | 0 | ≤ 0.2% | ≤ 0.2% | none |

No candidate has a trivial ceiling, but only R2 and R4 have a large one on
the canonical *suite total*, and both come from one benchmark. The
cross-workload candidates (R1, R3, R5) are each worth 10-40% of the small
scalar programs.

## Candidate scorecards (top five)

**R1 -- instance-entry Int facts**

* Root cause and first loss: `hir/range.tcl` entry ranges. `widen` has no
  narrowing, and captured ranges are not transported into closed closures.
* Workloads: fib, loop-count, sum-refined now; refined-checks after R2.
* Dynamic cost: tag tests, Bool words, retag/untag and small-Int roots,
  6-26% per scalar workload.
* Allocation/copy: none. Code size: shrinks slightly (slow paths vanish).
* Estimated maximum win: 6-26% of executed instructions per scalar
  workload (23% on fib with the ABI stage).
* Implementation scope: small to moderate. It is analysis only; the
  consumers exist.
* Semantic risk: range soundness (narrowing from a post-fixpoint is
  standard). It is testable with the existing `hir-range*` suites and
  differential backends.
* Runtime/GC risk: low. Raw registers are never roots already, but the root
  sets change, so GC-stress applies.
* Obsoleted by source changes: no. Structs: composes, independent.
* Needs producer fusion: no. Type-system change: no (range facts are not
  types). Runtime representation change: no. The optional ABI stage is a
  private representation contract like M8.a's.
* Confidence: high on existence and first loss; medium on the realized
  time gain.

**R2 -- native-body bridge**

* Root cause and first loss: `native::ExpandNativeBodies`, pre-HIR
  substitution.
* Workloads: refined-checks only; one predicate in the repository has a
  `-native-body`.
* Dynamic cost: 37.8%, plus it blocks R1 and R3 there.
* Code size: -6 KB (duplicates and generic entries).
* Estimated maximum win: 38-45% of refined-checks, 26% of the canonical
  suite.
* Implementation scope: small to moderate. Expand after resolution, keyed
  on the resolved target; keep predicate identity for refinement; no dead
  callee-position `fnvalue`.
* Semantic risk: low to moderate. The evidence attached by trusted natives
  must stay exact (NATIVE-OPAQUE-REFINEMENT).
* Runtime/GC risk: low. Obsoleted by source changes: no. Structs:
  independent. Fusion, type-system or representation change: none.
* Confidence: high.

**R3 -- tiny closed callees remain calls**

* Root cause and first loss: `LeafInlineEligible`'s env-free,
  straight-line and safe-op rules, plus a missing termination effect.
* Workloads: loop-count, sum-refined, refined-checks.
* Dynamic cost: 28.5% / ~42% / ~10%.
* Code size: small growth at few sites.
* Estimated maximum win: as listed. `char_at` needs R2b first, and either
  the relational bound or error-propagating ops accepted by the inliner.
* Implementation scope: moderate. This is "more inlining".
* Semantic risk: moderate (evaluation order, error completions).
* GC risk: moderate (roots across inlined bodies).
* Obsoleted by source changes: partly. `work` and `step` are benchmark
  idioms, but closed closures are the idiomatic Botlish helper form.
* Structs: independent. Fusion: no.
* Confidence: high on the cost, medium on how general the fix is.

**R4 -- per-character String work through region helpers**

* Root cause and first loss: StringRegion carries character indices;
  region ops are helper-only.
* Workloads: refined-checks (canonical), `ai_text_clean` and `csv`
  (supplemental).
* Dynamic cost: 66% inside helpers; 28.6% is the non-ASCII overhead.
* Estimated maximum win: 40-50% of refined-checks (25-30% after R2);
  larger on `ai_text_clean`.
* Implementation scope: large. It needs byte-offset regions or inline ASCII
  fast paths, and it touches the region representation.
* Semantic risk: moderate (Unicode scalar semantics, Tcl-compatible
  classes).
* GC risk: low. Obsoleted by source changes: no. Structs: independent.
* Needs producer fusion: no. Type-system change: no. Runtime
  representation change: yes (region carries byte offsets).
* Confidence: high on the cost, medium on the design.

**R5 -- frame and calling convention**

* Root cause and first loss: Cranelift lacks shrink-wrapping; the VM
  pointer is an ordinary argument.
* Workloads: all four.
* Dynamic cost: fib ~18%, others 1-3% beyond R3.
* Estimated maximum win: ~18% of fib; a pinned VM register saves 2-4
  instructions per call everywhere.
* Implementation scope: backend project. Semantic risk: none.
* Runtime/GC risk: the frame walker and stack maps depend on the frame
  layout.
* Obsoleted by source changes: no. Structs: independent.
* Confidence: high on the cost; the fix is backend territory.

## Isolated but interesting findings

**Large but benchmark-specific.**

* R2's redundant predicate is 37.8% of refined-checks.
* The non-ASCII re-seek is 28.6% of refined-checks.
* loop-count's `work<int>` call is a function compiled to a constant,
  called anyway (28.5%); it needs a termination fact.

**Small but ubiquitous.**

* `seto; test; jcc` instead of `jo`.
* `cmovCC` from the constant pool.
* Fast-path scheduling of slow-path argument moves.
* Entry root-slot zeroing (2.4% of fib).
* Loop-invariant root re-publication.

**Architecturally interesting but currently cheap.**

* Dead `fnvalue` loads (0.04%). Their fact-poisoning effect is not cheap:
  see R2b.
* `callenv` (startup).
* 38 of 46 exact calls in refined-checks carry a completion check, all
  traceable to one unproven region check.

**Likely solved later by structs.** Nothing in the canonical set.

**Likely producer-fusion territory.** Supplemental only:

* `ai_text_clean`'s one-character Strings (16.2% of its instructions) and
  per-piece plan extension (341 exclusive instructions per 1-byte piece);
* `uri-steady`'s `hex_pair` plans and `encode_utf8` Lists.

**Likely backend territory.** R5 as a whole: shrink-wrapping, a pinned VM
register, the frame pointer.

## Things explicitly NOT worth optimizing (for the canonical set, now)

| mechanism | measured canonical cost |
|---|---|
| **Allocation and materialization**, producer fusion, `encode_utf8` Lists, one-character producer Strings, `hex_pair` plans, listloop plans, plans through product fields | ≤ 0.2% of refined-checks' instructions, 0 elsewhere; no hot-path allocation anywhere |
| M8.a plan management, growth and merge copies | 0.07% |
| Product-shaped Lists / structs as a performance measure | no product Lists exist in any canonical workload |
| Open/dynamic dispatch (`callvalue`) | 0 executions |
| `<generic>` specialization identity as such | no residual guard, dispatch or unknown kind in any hot generic function |
| GC collection work, malloc/free | 0 collections, 0 hot allocations |
| Block/closure allocation | 2 per run, startup |
| Guard count | 0 executed guards |
| List indexing/traversal | none hot |
| Register allocation as such | locally dead/redundant moves are 0-2.4% |
| M8.a code-size growth | +2.6% on refined-checks, startup-only; harmless |

## Recommended next milestone

**M9: instance-entry Int facts.** Transport proven Int ranges across the
two boundaries where `hir/range.tcl` currently drops them:

1. **Narrowing after widening** for self-recursive and self-tail parameter
   entry ranges. After the widened post-fixpoint, re-evaluate the recursive
   feedback once with the widened entry and intersect. This recovers fib's
   `n` [0, 22], `drive`'s `i` [0, 500] and `check`'s `n` [0, 400].
2. **Captured-binding ranges into closed closures.** M7.c's `InstanceClosed`
   already proves every runtime route in; each capture's range at its
   capture sites becomes the closure's entry fact (`step`'s `n` [1, 400]).

Consumers stay unchanged. Acceptance should be counted with this audit's own
tools, not wall time: `tools/profile-all.sh` plus `class-matrix.py` on the
four canonical workloads, with the tagged-Int, Bool-word and root-store
classes as the targets, alongside the full suite, GC-stress, and
`hir-range*` soundness tests.

Why this is the winner under the census's own rules (spec items 7 and 70):

* it is the only mechanism with measured cost in all four workloads that
  is neither backend/ABI territory (R5) nor a ~2%, GC-sensitive residue
  (R6);
* it has one coherent root cause at one first-loss layer;
* its consumers already exist and are proven by a positive control
  (sum-refined's `n`);
* it needs no source change, no type or representation change and no
  fusion;
* its correctness surface is an analysis-soundness surface that the
  existing test infrastructure already exercises.

What it is **not**: large. The expected instruction win is 6-26% on the
three scalar programs, which run in 0.5-140 µs, and it cannot move
refined-checks until R2 lands. An optional stage 3 (raw-Int calling
convention for closed exact instances, the M8.a plan-parameter pattern for
Ints) should be decided from the measured residual after stages 1-2, not
up front.

**On choosing R2 instead.** If the priority is the largest absolute
reduction on the most expensive canonical workload, the native-body bridge
(R2) is larger (26% of all canonical instructions), cheap, and also a
prerequisite for M9 to reach refined-checks. It ranks second only because
of the census's commonality rule: one predicate, one benchmark. It is small
enough to schedule independently, before or right after M9, without
competing for the milestone slot. Either order is defensible from this
data. No further measurement is needed to make that choice; it is a
priority call.

## Possible later milestones

In suggested order, each gated on re-measuring after its predecessor:

1. **R2: native-body bridge.** Expand after resolution, keep predicate
   identity for refinement, and emit no callee-position `fnvalue`. Also
   unlocks R1 and R3 inside `Emailish?`.
2. **Relational length bound** (`i < length(v)` ⇒ region valid).
   Discharges `rt_str_region_check` (10.6%) and the completion-check chain
   it causes, and makes `char_at` error-free. It is the relational
   extension `hir/range.tcl`'s header explicitly defers.
3. **R3: closed-closure leaf inlining** (M7.c closed closures treated as
   environment-free, eligibility on post-simplification shape), and a
   termination effect for callees whose lowered body cannot diverge.
4. **R4: String region representation.** Byte-offset-carrying regions
   and/or inline ASCII fast paths for 1-character literal equality and class
   tests. Supported by refined-checks and by every supplemental text
   workload; the largest String-side item after M8.a.
5. **R5: backend.** A pinned VM register, and shrink-wrapping (a Cranelift
   limitation; possibly an out-of-line leaf-path split in lowering).
6. **R6: roots.** Range-aware root candidacy and lazy publication at cold
   slow-path safepoints. Do it only after R1 has removed most of the
   small-Int roots, since the remaining win is ~2-6%.
7. **Supplemental-only, not yet justified by canonical data:** producer
   fusion, collecting-listloop plans, per-piece plan-extension cost.

## Source-fence / regression confirmation

* **No production change.** `git status` shows only new files:
  `POST-M8A-COMMON-INEFFICIENCY-CENSUS.md` and
  `audit/post-m8a-common-inefficiency/`.
* **Untouched:** `bench/*.bot`, `bench/*.ir`, `lib/*.bot`, `native/`,
  `hir/`, `core/`, `compiler/`, `surface/`, and the M7/M8 audit artifacts.
  The ASCII probe is a new file under `audit/`; the benchmark it copies is
  unmodified.
* **Instrumentation** is fully external. `tools/audit-native.patch` is
  applied by `tools/build-audit-native.sh` to a scratch copy of `native/`
  with its own target directory. Its binary produces machine code of
  identical size per function, and identical values, for all four
  canonical programs.
* **Focused validation run** (instrumentation is external and read-only,
  per spec item 72):
  * `tclsh9.0 bench/bench.tcl -runs 5 -markdown` × 5 sessions: every value
    agrees across interp, compile and Cranelift in every session;
  * `tclsh9.0 tests/all.tcl -file "virtual-construction.test
    bench-backends.test native-string-region.test native-uri-escape.test
    hir-range.test closed-closure-entry-facts.test
    native-tiny-leaf-inline.test"`: 7 files, **176/176 passed** in both
    harness phases (interp, compile), 0 skipped, 0 failed.
  * The full suite and GC-stress were not rerun, since no production file
    changed.

## Required questions

**Baseline.**

1. **Canonical four?** `bench/fib.ir`, `bench/loop-count.ir`,
   `bench/sum-refined.ir`, `bench/refined-checks.ir` (see [Canonical
   benchmark set](#canonical-benchmark-set)).
2. **Default-on M8.a timings?** fib 138.13 µs, loop-count 1.05 µs,
   refined-checks 317.11 µs, sum-refined 0.56 µs (median of 5 × best of 5).
3. **Changed meaningfully under M8.a?** None. Instruction counts are
   identical for three, and refined-checks is +0.03%.
4. **Essentially flat?** All four.
5. **Allocations/bytes?** 0 / 0 / 0 / 20 objects (1,064 bytes; 18 semantic +
   2 private), all startup.
6. **Dominant object kinds?** refined-checks: List (11), String (4),
   StringPlan (2), Block (2), ImmutableSet (1). The others have none.
7. **Dominant consumers?**
   * fib, loop-count, sum-refined: 100% generated code, where frame,
     moves, tagged-Int work and Bool words dominate.
   * refined-checks: `rt_str_region_eq`, `rt_str_region_is_tcl_alnum`,
     `rt_str_region_check`, `rt_str_region_is_tcl_alpha` (66.0%), then
     `char_at` and `scan_local`.

**Commonality.**

8. **In all four?** The tagged-Int-at-entry-boundary symptom (R1), frame
   and calling convention (R5), root publication (R6), and backend
   micro-quality.
9. **In three?** Tiny closed callees remain calls (R3); R1's unblocked
   benefit; Bool-word branches.
10. **In two, dominating them?** None.
11. **Benchmark-specific previous residuals?** All five M8.a residuals.
    None occurs in a canonical hot path; they live in `uri-steady`,
    `ai_text_clean` and the csv family.
12. **One transition under several idioms?** Yes: proven-small Int →
    tagged word → re-tested/untagged across an instance-entry boundary. It
    appears as a recursive argument, a self-tail loop-carried counter, a
    closure capture and a region result.
13. **One temporary pattern across object types?** No heap temporaries in
    the canonical set. The common temporaries are register-level: tagged
    Ints and Bool words materialized for the next operation.

**Allocation.**

14. **Fraction tiny temporary?** 14 of 20 canonical allocations; ≈ 0% of
    runtime.
15. **Which sites?** `web.bot:99` (substrings), `web.bot:85`
    (`encode_utf8`), `web.bot:76`/`99` (plans), `byte.bot:175` (listloop).
16. **Final/persistent?** The escaped `q`, the program List, `hex_digits`,
    the reserved set, and the two module Blocks.
17. **Eliminable?** 8 objects: 2 plans, 3 one-character Strings, 3
    one-byte Lists (~0.1% of instructions).
18. **Counts or bytes more predictive?** Neither for the canonical set. In
    the supplemental set, counts (~390 instructions per object including
    free).
19. **Is malloc/free/GC/rooting a common hot cost?** malloc/free and GC:
    no. Rooting (root-slot stores): yes but moderate, 4-13% of instructions
    in all four.

**Calls.**

20. **Hot-path work in runtime helpers?** 0% / 0% / 0% / 66.4%.
21. **In generated code?** 100% / 100% / 100% / 33.5%.
22. **Dynamic/open calls executed?** 0 `callvalue`; 4 `callenv`, at
    refined-checks' startup.
23. **Exact calls forcing representation materialization?**
    * No heap materialization at any exact call.
    * Scalar retag + root publication at: 57,312 fib arguments/run, 400
      `step` captures, 500 `work` arguments.
    * 15,200 `char_at` region triples through stack out-parameter slots.
24. **Function boundaries still a common barrier?** Yes, for Int facts
    and call overhead; no longer for heap construction.

**Types/facts.**

25. **Do generic instances cost at runtime?** Not as such. Hot generic
    functions carry no guards or dispatch; their cost is unknown ranges
    inherited through R2b.
26. **Where do facts become too broad?**
    * recursive entry ranges (`widen`);
    * captured bindings inside closed closures;
    * the pre-HIR native-body expansion (refinement and closedness);
    * `i < length(v)` (relational).
27. **Dynamic work or uglier HIR?** Dynamic work, measured per mechanism
    above.
28. **Product Lists measurable before structs?** No: none exist in the
    canonical set.
29. **Fixed-index Lists as a source of generic ops?** No.

**Traversal.**

30. **Is repeated decoding/seeking common across workloads?** Only
    refined-checks among the canonical four (112,000 seek bytes/run). It
    is common across the supplemental text workloads.
31. **One-character or tiny substrings common?** Not in the canonical
    set (3 per run, startup). They are in `ai_text_clean` and
    `uri-steady`.
32. **Re-traversed prefixes?** Yes, in refined-checks: O(i) re-seek per
    non-ASCII access, up to 7 re-locations per character, and a whole
    second predicate pass.
33. **List traversal similarly repetitive?** No List traversal is hot.
34. **Semantic vs artifact?**
    * Semantic: one scan per predicate call; Unicode lookups for 6
      non-ASCII letters.
    * Artifact: the second scan, re-seeks, per-consumer re-location,
      out-of-line 1-byte compares, the redundant bounds check.

**M8.a.**

35. **Are plans materially expensive?** No (0.07%).
36. **Are growth/merge copies significant?** No (0 growths, 8 bytes).
37. **Are materializations required or avoidable?** The one canonical
    materialization (the escaped `q`) is required.
38. **Code-size growth without benefit?** refined-checks +391 bytes
    (+2.6%), startup-only.
39. **Enough to motivate heuristics?** No, it is harmless now.

**Backend.**

40. **Redundant moves common?** No. Moves are 16-27% of generated code,
    but only 0-2.4% are locally dead or redundant; the rest are
    calling-convention and loop-carried traffic.
41. **Tag/untag common?** Yes: 16-29% of the scalar programs' instructions,
    11% of refined-checks' generated code.
42. **Loads/stores or helper calls larger?** Scalar programs: frame and
    root-slot memory ops; there is no heap traffic. refined-checks: helper
    calls.
43. **Pattern shared by hot functions?** Yes:
    * a full frame with VM-pointer staging;
    * a tagged counter with a BigInt slow-path compare joined into a Bool
      word;
    * root stores at definitions.
44. **Front-end deficiency or backend issue?** Both. The tagged-Int, Bool
    word, redundant check and helper items are front-end (lost facts,
    inliner and bridge first losses). Frames, VM pointer and `seto`/`cmov`
    are backend/ABI.

**Candidate selection.**

45. **Top 5?** R1 instance-entry Int facts; R2 native-body bridge; R3 tiny
    closed callees; R4 per-character String work in region helpers; R5
    frame/calling convention.
46. **How many workloads each?**
    * R1: 4 as a symptom, 3 unblocked now.
    * R2: 1.
    * R3: 3.
    * R4: 1 canonical, plus the supplemental text workloads.
    * R5: 4.
47. **Measured work eliminable?**
    * R1: 6-26% per scalar workload (up to 23% on fib with the raw-Int ABI stage).
    * R2: 37.8% of refined-checks.
    * R3: 28.5% / ~42% / ~10%.
    * R4: 40-50% of refined-checks.
    * R5: ~18% of fib.
48. **Earliest correct layer?**
    * R1: `hir/range.tcl`.
    * R2: `native::ExpandNativeBodies` (move after resolution).
    * R3: `native/lower.tcl` inliner eligibility, plus a termination
      effect.
    * R4: `hir/stringregion.tcl` representation, with `native/lower.tcl`
      region lowering.
    * R5: Cranelift configuration/ABI (`native/src/codegen`).
49. **Would structs/source refactoring obsolete them?** None.
50. **Would they need producer fusion?** None.
51. **Would they need semantic/type-system changes?** None. R2 must
    preserve refinement semantics exactly as the interpreter already does.
52. **Would they change runtime representation?** R4 (regions carrying
    byte offsets). The optional R1 stage 3 is a private calling convention.
    R5 changes the ABI. R1 stages 1-2, R2 and R3 do not.

## Historical note

The M-series (M1-M7.c.1) improved fact and guard quality. Guards on these
programs went to 0 and code shrank, but the canonical programs barely
moved. M8.a removed construction and materialization costs, which the
canonical four never had. This census finds what remains in them:

* scalar facts lost at instance-entry boundaries;
* one lost refinement at the native-body bridge;
* tiny closed calls;
* char-indexed region helpers;
* frame and calling-convention costs.

None of it is allocation.
