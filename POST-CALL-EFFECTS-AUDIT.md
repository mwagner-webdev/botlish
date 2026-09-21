# Post-call-effects diagnostic closure audit

Audit date: 21 September 2026. Current source revision before diagnostic changes: `224222a`. Measurements were made on Ubuntu 24.04 under WSL, from the shared Windows checkout, with `LANG=C.utf8 LC_ALL=C.utf8`.

This audit makes strategic decision **B: scalar backend quality is mature enough for now; move deliberately to String / Bytes / construction.** No compiler optimization was implemented. The only code change is diagnostic tooling for settled exact-call effects and repeated native calls; generated evidence is under `audit/post-call-effects/`.

## Toolchains and methodology

- Tcl 9.0.1 (`tclsh9.0`)
- Python 3.12.3
- rustc 1.98.1 (48a229cea 2026-09-01), reference flag `-O`; assembly flag `-O --emit=asm`
- Go 1.22.2 linux/amd64, reference build `go build`; assembly flag `go build -gcflags=-S`
- Cranelift 0.135.2; regalloc2 0.15.2
- target: x86-64 System V, Linux ELF64
- canonical command: `tclsh9.0 bench/bench.tcl -runs 5 -markdown`
- native JIT compilation is excluded; each column uses one untimed warmup and best of five.
- repeated-call diagnostics execute 10,000 already-JIT-compiled program entries inside one `Instant` region. They are attribution data, not canonical headline timings.

The Rust/Go references use fixed-width signed 64-bit integers. They do not implement Botlish arbitrary-precision overflow, Error completion, managed-GC roots, or divergence contracts. Go also emits a growing-stack check. These are semantic caveats, not excuses for unexplained Botlish work.

## Current benchmark baseline

| Program | Tcl interp | Tcl compile | Cranelift | Python | Rust | Go | Value |
|---|---:|---:|---:|---:|---:|---:|---|
| fib(22) | 10099.2 ms | 65.7 ms | 146.71 us | 2.2 ms | 43.45 us | 84.58 us | 17711 |
| loop-count(500) | 263.9 ms | 1.6 ms | 1.31 us | 152.35 us | 0.61 us | 0.71 us | 3500 |
| sum-refined(400) | 143.1 ms | 20.1 ms | 0.91 us | 172.91 us | 0.70 us | 0.60 us | 80200 |
| refined-checks | 358.4 ms | 8.2 ms | 1.6 ms | 4.2 ms | 185.59 us | 142.79 us | [400, 0] |

Timing direction is favorable for the two tiny native cases and fib relative to the post-stack observation, but structural evidence remains primary. The sub-microsecond reference results and roughly one-microsecond native results are close to the measurement floor.

## Repeated-call tiny-benchmark diagnostics

| Program | Canonical Cranelift | 10,000-call samples, ns/call | Best amortized |
|---|---:|---|---:|
| loop-count | 1.31 us | 1708, 2139, 2596, 1575, 1466 | 1.466 us |
| sum-refined | 0.91 us | 1375, 980, 1047, 982, 978 | 0.978 us |

The batching does not reveal hidden process/JIT/timer overhead: amortized values remain near the canonical values (and are slightly slower in this noisy run). The residual gaps are real execution plus low-single-digit hundreds of nanoseconds, not a canonical-timer artifact. The diagnostic deliberately leaves the canonical harness unchanged.

## Complete 13-program census

The corpus remains 13 programs, 194 native functions, 57 generic and 137 specialized instances.

| Program | Functions | Current bytes | Exact calls | FF | FT | TF | TT |
|---|---:|---:|---:|---:|---:|---:|---:|
| fib | 2 | 394 | 3 | 0 | 3 | 0 | 0 |
| loop-count | 3 | 418 | 2 | 1 | 1 | 0 | 0 |
| sum-refined | 3 | 292 | 2 | 0 | 2 | 0 | 0 |
| refined-checks | 31 | 20,986 | 42 | 0 | 0 | 6 | 36 |
| ai_text_clean | 5 | 3,003 | 9 | 2 | 0 | 0 | 7 |
| csv | 11 | 4,731 | 16 | 0 | 0 | 0 | 16 |
| csv_chunked | 21 | 10,347 | 46 | 15 | 0 | 0 | 31 |
| csv_geometric | 15 | 5,333 | 21 | 0 | 1 | 0 | 20 |
| csv_records | 59 | 21,919 | 112 | 14 | 2 | 34 | 62 |
| hashtable | 30 | 13,166 | 82 | 14 | 0 | 37 | 31 |
| matmul | 7 | 4,160 | 8 | 0 | 0 | 0 | 8 |
| string_replace | 4 | 2,322 | 7 | 0 | 0 | 0 | 7 |
| string_reverse | 3 | 798 | 6 | 0 | 0 | 0 | 6 |
| **Total** | **194** | **87,869** | **356** | **46** | **9** | **77** | **224** |

FF/FT/TF/TT mean `may_error/may_gc` false/false, false/true, true/false, true/true. Thus 55 exact calls omit completion checks and 123 exact calls cease to be call safepoints. Outliers are `hashtable` (51 non-MayGc calls), `csv_records` (48), and `csv_chunked` (15). The pass is broad in bookkeeping benefit even though it does not imply broad remaining call overhead.

## Code-size and structural evolution

| Metric | Post-stack | Post-call-facts | Post-call-effects | Facts delta | Effects delta | Combined |
|---|---:|---:|---:|---:|---:|---:|
| machine-code bytes | 89,512 | 89,118 | 87,869 | -394 | -1,249 | -1,643 |
| NIR guards | 85 | 84 | 84 | -1 | 0 | -1 |
| tagged `iadd` | 106 | 104 | 104 | -2 | 0 | -2 |
| raw `riadd` | 11 | 13 | 13 | +2 | 0 | +2 |
| completion-checked exact calls | 356 | 356 | 301 | 0 | -55 | -55 |
| call safepoints | 356 | 356 | 233 | 0 | -123 | -123 |
| all safepoints | 607 | 605 | 482 | -2 | -123 | -125 |
| root candidates | 1,046 | 1,042 | 987 | -4 | -55 | -59 |
| physical root slots | 665 | 663 | 645 | -2 | -18 | -20 |
| entry-zero slots | 176 | 176 | 141 | 0 | -35 | -35 |
| functions | 194 | 194 | 194 | 0 | 0 | 0 |
| generic/specialized | 58/136 | 57/137 | 57/137 | -1/+1 | 0/0 | -1/+1 |

?Completion-checked exact calls? and ?call safepoints? use the conservative pre-effect state as 356; effect summaries remove the stated sites. The value pass did not reclassify calls. Its two safepoint removals came from representation/range lowering of arithmetic helpers, as documented by that milestone.

Effect-summary per-program byte changes from the facts snapshot: `csv_records` -403, `hashtable` -386, `csv_chunked` -169, `loop-count` -85, `fib` -69, `ai_text_clean` -53, `sum-refined` -52, `refined-checks` -16, `csv_geometric` -16; the other four are unchanged. No program grew.

Value facts separately changed 89,512 to 89,118 bytes, removed one guard and two tagged adds, added two raw adds, shifted one generic instance to specialized, and reduced candidates/slots by 4/2. Effect summaries then removed 55 checks and 123 call safepoints, reducing candidates/slots by another 55/18.

## True VCode and final assembly

The current `*.vcode` headers and content were regenerated through `native::vcode`. They contain Cranelift?s `vcode from lowering` after x86 machine lowering and before `regalloc2::run_with_ctx`: virtual registers such as `%v209` are visible, while allocator-created physical-register copies are not. These are not the older mislabeled CLIF construction logs.

Current true VCode and final unlinked x86-64 disassembly are in:

- `audit/post-call-effects/bench/{sum-refined,loop-count,fib,refined-checks}.{vcode,asm}`
- Rust and Go assembly is in `audit/post-call-effects/refs/`.

### sum-refined scalar microscope

The hot `sum<int,int>` loop is 131 bytes; `step<int>` is 98 bytes. Materially executing Botlish sequences absent from both Rust and Go are:

| Sequence | Classification | Evidence |
|---|---|---|
| tag `n` with `shl/or` for step argument | generic Botlish call ABI / lowering deficiency, but narrow | present in VCode and final asm |
| publish tagged argument and accumulator roots | required Botlish semantics | step is false/true; checked addition can allocate |
| real exact `call step<int>` | source/compiler difference; possible narrow inlining opportunity | Rust/Go inline; Botlish call remains |
| step frame setup/teardown | call/ABI overhead | required by current frame-pointer convention, absent after reference inlining |
| tagged-kind fast test plus overflow test in `iadd` | required Botlish semantics under current proof | accumulator range is unknown |
| cold `rt_int_add` fallback | required Botlish semantics | reachable BigInt result is not disproved |
| loop-carried physical copies | partly regalloc2 #265 | some block-parameter flow is in VCode; extra physical copy shapes appear only after allocation |

The removed type guard and completion check are genuinely gone. There is no `NO_VALUE` test after the step call. Root publication remains because the call is MayGc.

The caller range is genuinely insufficient. The exact instance knows Int kind, but the accumulator?s magnitude remains unbounded under the current recursive/entry proof. The captured `n` kind does not bound `acc+n`. Therefore the checked add, fallback, and the MayGc dependency are semantic, not a lost already-existing interval fact.

The call?s remaining common-path cost is argument tagging, two root stores, one direct call/return, callee frame setup/teardown, checked tagged addition, and loop-carried moves. Against current references, the whole residual gap is only 0.21?0.31 us for 400 steps (roughly 0.5?0.8 ns/step, before semantic attribution). That cannot justify a generic inliner. Static frequency also argues caution: only 46/356 exact calls are false/false; many are cold helpers or nullary constants, and the important sum call is MayGc and retains semantic work even if inlined.

The ordinary return ABI is not the dominant sum issue because the caller consumes the returned accumulator. A non-erroring ABI could omit only a convention-level possibility, not the tag/overflow/GC semantics. No new ABI is justified.

### loop-count minimality and known result

`work<int>` remains a compact 54-byte leaf: frame pointer, raw unbox, `3*i+7`, divergence branch, tagged 7 return. `drive<int,int>` is 301 bytes. Its exact call has no completion check and is not a safepoint.

Remaining hot work:

- termination comparison, including a cold BigInt comparison path: required for arbitrary-precision input;
- decrement/retag of `i`: current generic function ABI;
- one direct call plus leaf prologue/epilogue: real but small;
- tagged accumulation, overflow test, and cold `rt_int_add`: required because total is not proven small;
- root stores for the remaining possible allocating add, not for `work`;
- loop-carried physical copies, with allocator contribution.

There is a distinct known-result ABI inefficiency: `work` executes `mov eax,0xf` and returns it, while the caller ignores `rax` and materializes/stores tagged 7 from the successful-result fact. The call cannot be deleted because the negative path can diverge. This is a narrow ?execute for effects/divergence, ignore known result? lowering opportunity, worth recording but not a broad milestone.

The residual native gap is 0.60?0.70 us over 500 iterations (about 1.2?1.4 ns/iteration, including tagged accumulation and semantic fallbacks). Repeated-call timing does not magnify it. An inliner would mostly address this deliberately non-inlined source shape, not a demonstrated corpus-wide bottleneck.

### fib recursive audit

The current `fib<int>` body is 345 bytes. Its fast recursive path contains:

1. frame setup: `push rbp; mov rbp,rsp; sub rsp,0x30`, three callee-save stores;
2. one entry-zero root slot;
3. tagged/raw input test and comparison, with cold BigInt comparison;
4. raw decrements and retagging for `n-1` and `n-2`;
5. root publication and two direct recursive calls;
6. no recursive completion tests;
7. tag/overflow checked result addition and cold `rt_int_add`;
8. allocator-created physical copy chain around second-argument retagging;
9. callee-save restoration and epilogue.

For 57,313 invocations, the current sanity-scale gaps are:

- Botlish minus Rust: (146.71 - 43.45) us / 57,313 = approximately **1.80 ns/invocation**.
- Botlish minus Go: (146.71 - 84.58) us / 57,313 = approximately **1.08 ns/invocation**.

Required Botlish differences are root publication, tag/raw conversions, arbitrary-precision comparison/addition checks, and possible BigInt allocation. The recursive callee is MayGc because its reachable result add can allocate; that summary propagates around the recursive SCC. Consequently callers must publish live roots around recursive calls. Ultimately the recursive root obligation and the local checked-add fallback have the same transitive BigInt source.

Rust/Go independently reduce the mathematical fast path to raw fixed-width recursive calls and raw addition; Botlish?s additional operations all map to the semantic list above or to regalloc2 copies. There is no new unexplained Botlish-specific fib sequence.

## regalloc2 #265 and other upstream behavior

True VCode has virtual destructive chains for fib retagging, for example `subq -> shlq -> orq`. Final assembly introduces repeated physical transfers through `r12/rsi` around the second recursive argument. The analogous block-parameter/copy pattern remains in `sum-refined` and `loop-count`, but fib is the only primary workload where it is recurrent enough to be material because it executes per recursive invocation. The estimate is a low-single-digit extra move count per non-leaf fib invocation, not a separately measurable whole benchmark percentage.

This is absent as the same physical copy sequence pre-regalloc, so it remains regalloc2 #265, not a Botlish pass candidate. No additional important inefficiency was isolated to Cranelift itself. Direct runtime-helper calls that appear indirect in VCode resolve to direct relocations in final objects and are not hot indirect-call defects.

## refined-checks allocation refresh

One current native run reports:

| Class | Objects | Managed bytes |
|---|---:|---:|
| String | 13,609 | 566.8 KB |
| Block | 7,205 | 413.0 KB |
| List | 5 | 288 B |
| **Total** | **20,819** | **980.1 KB** |

Peak live equals 20,819 objects / 980.1 KB; no collection occurred. String copying is 22.4 KB and List copying is 21 elements.

Top sites:

- `char_at` substring: 9,200 allocations / 381.6 KB;
- second `char_at` substring family: 4,400 / 184.8 KB;
- recurrent nested closure sites: six sites at 800 allocations each (38.4?57.6 KB each);
- recurrent nested closure sites: six sites at 400 allocations each (19.2?28.8 KB each);
- `web.bot:31` List construction: one / 152 B;
- `web.bot:145` immutable concat and substring: three each / 130 B and 123 B;
- `web.bot:132` `encode_utf8`: three List-producing allocations / 96 B, plus 21 copied List elements overall.

Thus 13,600 of 13,609 Strings are the two dominant `char_at` families, while 7,200 of 7,205 Blocks are recurrent nested closures. Immutable concatenation and UTF-8 List intermediates are small in this exact input but architecturally relevant construction mechanisms. The prior dominant picture is unchanged. Low-level instruction tuning of refined-checks is not warranted; it is String/Bytes/construction work.

## Prior-finding closure

- **Nullary constants:** `chunk_size()` and `ht_empty_state()` remain tiny framed literal-return helpers with real direct calls. They are repeated in builders/hash paths, but are source-level immutable module-binding cleanup, not a compiler milestone.
- **Cross-call strlen/bounds:** bounds and length guards remain visible in String scanner families, but current allocation and construction traffic dominates and no widespread independent hot redundant pair was established. Close as a possible String-summary fact, not a scalar milestone.
- **CSV OR-of-disequalities/induction:** the theoretical induction limitation remains, but current final code does not establish material executing overhead broad enough to promote. Close for this cycle.
- **Wide aggregate virtualization:** `geo_append`, four `chunked_append` instances, `ht_rehash_scan`, and `ht_rehash_insert` have large frames and stack traffic. VCode already contains wide values, required root stores, and ABI argument pressure; final assembly adds some allocation copies, but no recurrent Botlish-controlled spill pattern attributable solely to aggregate width was isolated. No arbitrary width policy is justified.
- **Windows stress crash:** previously reproduced even with `call-effects-opt=0`; record as a separate platform-specific native stack/frame-walking defect. It is not attributed to effect summaries and was not investigated here.
- **libc/pthread stack bounds:** accepted and out of scope.

## Strategic decision

**B. Scalar backend quality is mature enough for now; move to String / Bytes / construction.**

No one scalar candidate meets all required criteria:

- general inlining is not supported by corpus frequency or timing; the visible helper shapes are narrow and much surviving call-adjacent work is semantic;
- known-result call lowering is principled but demonstrated materially only by `drive -> work`, where it removes a return-value materialization rather than the mandatory divergent call;
- a non-erroring or non-GC ABI would not eliminate the dominant tagged arithmetic/BigInt/root obligations and would add ABI complexity;
- further result/range propagation has no existing proof for sum?s accumulator or recursive fib result;
- cross-call bounds/length and CSV induction are not currently material;
- wide aggregate pressure is not cleanly upstream of allocation;
- the most visible remaining copies are regalloc2 #265.

Remaining scalar differences are predominantly required arbitrary-precision/Error/GC/divergence semantics, measurement-floor effects, upstream allocator behavior, or narrow/local source shapes. The next major milestone should target String / Bytes / construction, carrying forward: `char_at` substring elimination/regions, recurrent nested closure allocation, UTF-8 byte/List intermediates, and immutable concatenation/building.

## Explicit answers

1. Current benchmark numbers are the six-backend table above.
2. Repeated calls give best amortized 1.466 us for loop-count and 0.978 us for sum-refined; they confirm rather than erase the canonical gap.
3. Current 13-program machine code is **87,869 bytes**.
4. Value facts removed **394 bytes**, one guard, two tagged adds, two safepoints, four root candidates, and two physical slots; they added two raw adds and changed one generic instance to specialized.
5. Effect summaries removed **1,249 bytes**, 55 completion checks, 123 call safepoints, 55 root candidates, 18 slots, and 35 entry zeroes.
6. Exact-call matrix: **46 FF, 9 FT, 77 TF, 224 TT** (356 total).
7. **55** completion checks disappeared corpus-wide.
8. **123** call safepoints disappeared.
9. From post-facts, root candidates fell **1,042 -> 987 (-55)** and slots **663 -> 645 (-18)**; combined from post-stack, -59/-20.
10. Sum retains tagging, root publication, a real call/frame, checked tagged add/BigInt fallback, and some loop copies absent from both references.
11. Required semantics: roots at the MayGc step, checked arbitrary-precision addition/fallback, and the call?s execution/divergence behavior.
12. The extra physical loop/retag copy shapes absent from VCode are attributable to regalloc2 #265.
13. The real step call is measurable only at a sub-nanosecond-per-step residual scale mixed with semantic work; it is not independently a meaningful bottleneck.
14. An inliner would mainly solve this source shape, not a demonstrated broad corpus problem.
15. Yes. `work` still materializes tagged 7 in `rax`; the caller substitutes known 7 and ignores that machine result.
16. Loop-count?s non-semantic remainder is the exact call/frame, argument retagging under the current ABI, narrow known-result return traffic, and allocator copies.
17. Fib?s approximate gap is **1.80 ns/invocation to Rust** and **1.08 ns/invocation to Go**.
18. Root publication, tagged/raw conversion, checked result addition, and the fallback?s transitive MayGc summary are required by BigInt/GC semantics under current proof.
19. No new unexplained Botlish-specific fib sequence was found.
20. Yes; refined-checks remains dominated by String/Block/construction allocation.
21. Top classes/sites are 13,609 Strings, 7,205 Blocks, five Lists; the two `char_at` families contribute 9,200 and 4,400 allocations.
22. No; nullary helpers are source-level module-binding cleanup.
23. No current evidence makes cross-call strlen/bounds broad or material enough for a scalar milestone.
24. No current evidence makes the CSV induction limitation broad or material enough.
25. No demonstrated broad aggregate-width spill problem was isolated.
26. Beyond regalloc2 #265, no important final-code inefficiency was proved primarily upstream.
27. **No**, one more broad scalar milestone is not justified.
28. Not applicable.
29. Whole-corpus shrinkage plus current VCode/assembly show remaining costs are semantic, allocator-owned, narrow, or at the timing floor; no candidate meets the breadth/ownership/impact test.
30. **Yes. The next major milestone should be String / Bytes / construction.**
