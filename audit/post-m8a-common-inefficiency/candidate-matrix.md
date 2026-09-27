# Candidate matrix (POST-M8A-COMMON-INEFFICIENCY-CENSUS.md)

Every number is **executed instructions per run** (callgrind `Ir`, timed
runs only, divided back to one run; `profiles/*/cranelift/`), and a
percentage of that workload's total. An estimate counts only instructions
that disappear under the stated counterfactual; anything that would
plausibly remain (e.g. an overflow check on a genuinely unbounded
accumulator) is kept. Derivations reference the per-instruction listings
(`profiles/<w>/cranelift/instr.txt`), whose class labels come from
`tools/cgprof.py`.

Workload totals: fib 2,378,489 (57,313 calls: 28,656 internal + 28,657
leaves), loop-count 17,545 (500 iterations), sum-refined 12,437 (400
iterations), refined-checks 5,437,827 (800 `check` iterations, 1,200
`Emailish?` calls, 15,200 `char_at` calls).

## R1 -- Int facts lost at instance-entry boundaries (recommended M9)

Symptom: an Int that every incoming edge proves small (or that a narrowing
step would prove small) enters its function as
a tagged, possibly-BigInt word, so the body pays a tag test, a BigInt
slow-path compare whose result is joined into a Bool word, untag/retag and
root-slot stores.

| workload | first loss | what disappears (per unit) | estimate |
|---|---|---|---|
| fib | `n` entry range [-inf, 22]: `hir::range::widen` without narrowing | (a) facts only: entry `test rsi,1`+`jne` -> one `sar` (-1/call), Bool word `mov r10d,2`/`cmovl`/`cmp r10,6` (-3/call), internal `sar` (-1/internal) = 57,313 + 171,939 + 28,656 | **257,908 (10.8%)** |
| fib | + (c) raw-Int arguments to the closed exact instance | callee `sar` (57,313), caller `shl`+`or` x2 (114,624), root stores of n-1/n-2 (57,312), dead `mov r12,rsi` x2 (57,312) | **+286,561 -> 544,469 (22.9%)** |
| loop-count | `drive`'s `i` entry range [-inf, 500] (widening) | self-tail loop: raw params already flow raw across the back edge (sum-refined shows it): tag test 1,002 + Bool word 1,503 + `sar`/`shl`/`or` 1,500 + root store of i-1 500 | **4,505 (25.7%)** |
| sum-refined | captured `n` has range [1,400] at the capture site but [-inf,+inf] inside `step<int>` (captures unranged) | (b) facts only: joint tag test `mov`/`and` on x&n -> `test x` (-2/call); root store of n in `step` (-1/call) = 1,200 | **~800-1,200 (6-10%)** |
| sum-refined | + (c) raw capture argument | no `shl`/`or` retag in `sum` (800), no root store of n in `sum` (400) | **~2,000-2,400 (16-19%)** |
| refined-checks | `check`'s `n` [-inf, 400] (widening) | 7/iteration x 800 | 5,600 (0.1%) |
| refined-checks | scanners' `i`, captured `n = length(v)`: blocked by R2 (open generic predicate instance) | per scanner iteration ~14 (tag test, Bool word, overflow check on i+1, root stores) + per `char_at` ~8, minus retags the helper ABI would need (~4 per helper call) | **~240K (4.4%) only after R2** |

Consequences removed as a side effect: most Bool-word branches (R7), the
small-Int part of root publication (R6).

## R2 -- native-body bridge (`native::ExpandNativeBodies`, pre-HIR substitution)

| effect | evidence | estimate |
|---|---|---|
| refinement erased: inner `Emailish?(s)` sees `str`, not `str[Emailish]` (unexpanded HIR: `str[Emailish]`) | function 25 (the inner check) called 400x/run, inclusive 2,054,000 | **2,054,000 (37.8%)** |
| callee-position block literal materialized as a dead `fnvalue` -> open `block e332<generic>` instance -> the closed scanners are shared with it -> `<generic>`, entry facts unknown | `spec.txt`: `check ... materializes Block values: e332 e552`; InstanceClosed: `block e332<generic>` closed=0, scanners closed=1 but generic | enables R1's refined-checks part (~4.4%) and R3's `char_at` |
| dead `fnvalue` loads | 2 loads per predicate call | 2,400 (0.04%) |
| duplicate predicate chain (one expansion per call site) + two never-executed `<generic>` predicate instances | functions 25-32 = copies of 17-24; 18/26 unexecuted | static only: ~4.8 KB + 1.5 KB |

fib / loop-count / sum-refined: 0.

## R3 -- exact calls to tiny closed callees stay machine calls

| workload | callee | first loss | estimate |
|---|---|---|---|
| fib | (recursive) | n/a | 0 |
| loop-count | `work<int>` compiled to `mov eax,0xf; ret`, result already replaced by the constant 7 in `drive`, call kept (`may_error=false may_gc=false`, but termination is not an effect fact; tiny-leaf inliner requires a straight-line HIR body) | callee 3,000 + call site (`mov rsi`, `mov rdi`, `call`, root store of 0xf) 2,000 | **5,000 (28.5%)** |
| sum-refined | `step<int>` (M7.c closed closure; tiny-leaf inliner requires env-free) | callee 7,600 -> inline residue ~10/iter (4,000) ; call site ~4/iter (1,600) | **~5,200 (42%)** |
| refined-checks | `char_at` (closed closure; env-free rule, `regioncheck` not in the safe-op family, shared with R2's open instance) | 15,200 x 46 = 699,200 exclusive -> residue ~14/call (212,800); call-site out-param slot traffic ~5/call (76,000) | **~562K (10.3%)** |

## R4 -- per-character String operations through out-of-line helpers over char-indexed regions

refined-checks only among the canonical four:

| part | evidence | estimate |
|---|---|---|
| all region helpers (inclusive of their own callees; they never call each other, so the sum is not double-counted) | `rt_str_region_eq` 10,400 calls x 119 (22.8%), `rt_str_region_is_tcl_alnum` 11,200 x 108 (22.3%), `rt_str_region_check` 15,200 x 38 (10.6%), `rt_str_region_is_tcl_alpha` 2,400 x 233 (10.3%) | **3,591,200 (66.0%)**; ASCII probe: 52.5% |
| non-ASCII representation path (O(i) re-seek from byte 0 per access, re-decoding, Unicode tables) | ASCII probe (`probes/refined-checks-ascii.ir`, identical control flow): 3,884,225 vs 5,437,827; `utf8SeekBytes` 112,000/run vs 0 | **1,553,602 (28.6%)** upper bound; >= ~0.75M (13.9%) is pure seek/re-decode in `rt_str_region_eq` |
| ASCII-path helper overhead | even ASCII: 53 Ir per 1-byte `region_eq` (incl. a `memcmp` call), 67 Ir per ASCII class test (`get_general_category` table search) | ~1.3M in ASCII-equivalent terms (overlaps the row above) |

Supplemental (supporting only): `ai_text_clean` 10K ASCII -- `rt_str_region_eq`
57.3% of all instructions (191,014 calls, every one through the non-ASCII
`Take<Chars>` path because the base is the non-ASCII literal); `csv` 1000
rows -- region ops ~9%.

## R5 -- frame / calling-convention overhead (backend + ABI)

| workload | part | estimate |
|---|---|---|
| fib | leaf calls execute the full frame (3 callee-saved stores/restores, `sub`/`add rsp`, zero slot) -- no shrink-wrapping | 28,657 x 9 = **257,913 (10.8%)** |
| fib | VM pointer passed as an argument: `mov rbx,rdi` per call, `mov rdi,rbx` per call made, rbx save/restore | **~172K (7.2%)** |
| loop-count / sum-refined | `mov rdi,r13` per call; callee frames (subsumed by R3) | 500 (2.9%) / 400 (3.2%) |
| refined-checks | VM-pointer moves 61,258; frames mostly `char_at` (subsumed by R3) | ~1-3% |

## R6 -- root-slot publication (after R1)

| workload | residual root traffic | estimate |
|---|---|---|
| fib | entry root-slot zeroing | 57,313 (2.4%) |
| loop-count | root store of the constant 7 (`0xf`) and of `total` (only live across the cold `rt_int_add` path) | 1,000 (5.7%) |
| sum-refined | `step` stores `x` (only live across the cold `rt_int_add` path) | 400 (3.2%) |
| refined-checks | loop-invariant `v`/`n` re-stored per scanner iteration, tagged constant 1 stored as a root, region start/end copied into root slots | ~60-100K (1.1-1.8%) |

## R7 -- Bool-word branches (materialized compare results)

fib 171,939 (7.2%), loop-count 1,503 (8.6%), sum-refined 0 (its compare is
raw), refined-checks 2.6% (1.2% from tagged compares, the rest from Bool
words returned by helpers or joined across `or`-chains). The tagged-compare
part exists only where the compare has a BigInt slow path, i.e. it is a
consequence of R1 and disappears with it.

## Explicitly zero or negligible in the canonical four

| mechanism | fib | loop-count | sum-refined | refined-checks |
|---|---:|---:|---:|---:|
| heap allocations per run | 0 | 0 | 0 | 20 (startup only; 18 semantic + 2 private plans) |
| GC collections during a run | 0 | 0 | 0 | 0 |
| M8.a `rt_construct` calls / Ir | 0 | 0 | 0 | 6 / 4,031 (0.07%) |
| product-shaped Lists | none | none | none | none |
| dynamic `callvalue` | 0 | 0 | 0 | 0 |
| `callenv` | 0 | 0 | 0 | 4 (startup) |
| NIR `guard` executions in hot code | 0 | 0 | 0 | 0 (3 static sites, all cold) |
| completion checks | 0 | 0 | 0 | 63,262 + callmulti tests (1.2-1.8%; tied to R3/`i < length(v)`) |
| dead `fnvalue` loads | 0 | 0 | 0 | 2,400 (0.04%) |
