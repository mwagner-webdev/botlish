# Raw 64-bit Int ABI

## Outcome

An exact, **closed** Botlish instance now transports an Int parameter, and its
successful Int result, as a **raw signed machine integer** (`RawInt`, a
two's-complement `i64` on the current native target) instead of a tagged
`Value`, whenever the instance's final Ranges prove the position fits the
tagged small-Int domain (`hir::range::fitsSmall`). It is a physical calling
convention only: the semantic type stays `Int`, arbitrary precision, and the
canonical tagged ABI is untouched everywhere the proof does not apply.

* `fib<int>` (`bench/fib.bot`) is physically `i64 fib(i64 n)`: `n` raw, the
  result raw, `n - 1` / `n - 2` passed raw, results added with the existing
  raw `riadd`, returned raw. **No `rbox`/`runbox` remains in the function**
  (before: 3 + 3). The program passes the literal `22` as a `rawint` and boxes
  the final result once.
* Dynamic instructions (callgrind, 21 runs, run 0 excluded): **1,547,454 →
  1,404,178 Ir/run (−9.3 %)**. All 286,561 Ir of retag/untag disappear; about
  half of that is given back by one extra callee-saved register the backend now
  keeps (see *Fib dynamic instructions*), which is backend territory and is
  recorded, not optimised.
* The plan is one authoritative `native::rawabi` result, computed once after the
  closedness and Range analyses and read by the callee's lowering and by every
  call site. NIR carries the physical signature in the function header
  (`rawparams="0 2" rawresult=1`); `native/src/nir.rs` re-validates caller/callee
  agreement and rejects a mismatch as a compiler bug.
* Errors are never encoded in the integer. A raw-result function that cannot
  fail returns the bare integer; one that can fail returns the integer plus a
  status word (second return register).
* Whole canonical corpus: machine code 101,963 → 101,662 bytes (−301), GC root
  candidates 1,283 → 1,238, 228 instances examined, 68 gain a raw position
  (56 raw parameters, 23 raw results, 4 both). Honest caveat: where an Int only
  flows through tagged consumers (hashtable, csv) the static conversion count
  went **up** (47 → 66 `rbox`, 47 → 48 `runbox`) and `hashtable` grew by 67
  bytes; see *Known limitations*.
* Full regression, differential fuzzing (3,300 random programs, 0
  disagreements), GC stress and standalone-executable parity pass (see the
  sections below).

Files: `native/rawabi.tcl` (planner, audit), `native/lower.tcl` (plan storage,
callee/caller lowering, raw `if` join, raw alias, option),
`native/src/nir.rs` (header attributes, validation, call-site effect rule, unit
tests), `native/src/codegen/clif.rs` (physical signature, prologue, call/ret,
generic-entry conversion), `native/explain-native.tcl` (`raw-int-abi.txt`),
`tests/raw-int-abi.test` (45 tests), `audit/raw-int-abi/`.

## Motivation

The previous milestone proved `fib<int>`'s argument and result are small Ints,
and made the arithmetic inside the function raw. Every recursive boundary still
did `raw n → rbox → tagged argument → call → tagged result → runbox → raw
arithmetic`, and the result was reboxed on the way out. That is representation
conversion that serves no semantic purpose: the theorem "this Int cannot become
a BigInt" was forgotten at the function boundary. The measured cost was 286,561
retag + untag Ir out of 1,547,454.

## Starting fib representation

```
func 1 "fib" params=1 ... rawregs="1 3 7 8 11 13 14 17 18"
    %1 = op runbox %0              ; n is tagged on entry, unboxed once
    ...
    %8 = op risub %1 %7
    %9 = op rbox %8                ; boxed again to cross the call
    %10 = call 1 %9
    %11 = op runbox %10            ; and unboxed again
    ... (same for n - 2)
    %18 = op riadd %11 %17
    %19 = op rbox %18              ; result boxed to return
    ret %19
```

## Semantic proof inputs

The planner reads exactly three things and invents no numeric fact:

1. `hir::specialize` — `closed` (`InstanceClosed`: every invocation of the
   instance is a direct exact call the analysis saw), the instance's key types
   and its result type.
2. `hir::range` — the instance's final **entry Range** per parameter, and its
   **successful-result Range**, through the same ordinary result query every
   consumer uses. The self-recursive result summary of the previous milestone
   arrives through that query; there is no `if function is recursive` logic in
   the planner (`raw-result-follows-the-ordinary-result-query` pins this:
   withdrawing the summary with `-recursive-result-range-opt 0` or a too-small
   `-recursive-range-limit` makes the *same* instance's result tagged again).
3. `hir::range::fitsSmall` — the one membership test.

## Why RawInt is signed i64

Small tagged Botlish Ints are `[-2^62, 2^62 - 1]`, so every value that passes
`fitsSmall` is exactly representable as a signed 64-bit machine integer. There
is no need to derive a narrower width: the decision is *tagged vs raw
machine-word*, not *which width*. The encoding is plain two's complement — no
tag bit, no bias, no pointer-like encoding. The physical register is `i64`, but
the admissible domain is still the small-Int domain, not all of `i64`
(`raw-outside-small-result`, `raw-outside-small-parameter`: a Range reaching
`2^62` fits a register but gets the tagged ABI, and `succ(2^62 - 1)` correctly
returns the BigInt `4611686018427387904`).

## Why there is no RawInt32 ABI

On the current 64-bit scalar call ABI, `i32` and `i64` both occupy one general
machine argument/result slot; a narrower width therefore does not reduce
transport width, while it would multiply ABI variants. Range may still record
that a value fits `i32` as metadata (it is not an ABI class), and local/backend
lowering may exploit narrower arithmetic later.

## Eligibility theorem

A parameter position (resp. the successful result) of instance `I` is RawInt iff

1. its semantic type is Int (key type `int`; the result type's kind is `int`),
2. `I` is closed (`InstanceClosed`), and
3. its final entry (resp. successful-result) Range satisfies `fitsSmall`.

*Why closed*: the Range is a statement about every invocation only if every
invocation is known; an open instance (its Block value escapes, or it has
unknown callers) has callers that would pass tagged Values, and a Block value
always enters the tagged generic entry. A bound derived from one known caller
is never used (`raw-open-instance-stays-tagged`). *Why `fitsSmall` and not
"finite"*: the raw/tagged conversions at the frontier are non-allocating only
inside the small domain; a finite Range reaching `2^62` may need a BigInt.
Negative ranges are eligible (`raw-negative-range`, `raw-small-domain-edges`).
Lowering also checks one non-analysis fact: with `-block-escape-opt 0` every
closure is materialized as a Block value whatever the proof says, so the planner
treats generic closure instances as open then (found by the existing
`blockescape-*` tests; `GenericRef` also asserts it).

## Authoritative ABI plan

`native::rawabi::plan` returns `InstanceId → {params {value|rawint…} result
value|rawint paramReasons resultReason closed}`. It is stored once in
`native::lower::abiPlan`. Callers and callees go through `AbiParams` /
`AbiResult`; nothing decides rawness at an individual call instruction. The
physical-kind vocabulary (`value`, `rawint`) is a seed for future scalar
representations; only `rawint` is implemented.

## Parameter raw masks, raw result planning

Each position is independent: `raw/tagged`, `tagged/raw` and `raw/raw` all occur,
and so do mixed parameter lists (`f(a, b, s)` → `raw, tagged, tagged`). One
plan exists per codegen instance — a mask over the declared parameters plus a
result flag — so there are no per-call-site variants. The plan is a function of
instance facts only; exact Range values never enter an instance key (two
instances `[0,22]` and `[0,1000]` would share one physical shape), and no new
semantic instance is ever created for an ABI difference. The physical identity
is the NIR function's header (`rawparams`, `rawresult`), one canonical function
per semantic instance, as for the other physical variants (companion, fields…).

Result eligibility is *not* derived from parameter eligibility
(`seven(v)` below has a tagged parameter and a raw result; `big(n)` a raw
parameter and a tagged result).

## Canonical tagged ABI

Unchanged for: open instances, generic entries, dynamic (`callvalue`) calls,
unproven or non-small Ranges, BigInt-capable paths, the program function,
companion / region / internal-capture / fields variants (they are separate NIR
functions with their own conventions), FFI/native boundaries, and every case the
budget or an analysis declines. `-raw-int-abi-opt 0` (or
`BOTLISH_NATIVE_RAW_INT_ABI_OPT=0`) restores it everywhere and reproduces the
parent's NIR for fib exactly (`raw-fib-disabled-is-the-tagged-abi`).

## Codegen-instance representation

A generic source function can have an open tagged instance and a closed raw
instance simultaneously (`raw-open-instance-stays-tagged`:
`open_one<generic>=val>val`, `open_one<int>=raw>raw`). An escaping function's
generic entry stays tagged; its closed exact direct callers use the separate
raw instance. Dynamic calls (`callvalue`) never see a raw function:
`nir.rs` rejects `fnvalue`/`closure` of a raw-ABI function, and the generic
`botlish_entry_N` wrapper of such a function converts defensively (untag
arguments, tag the result / status) even though it can never run.

## Planning order

`hir::specialize::analyze` (instances, the one closedness result) →
`hir::range::analyze` (entry Ranges, call results, bounded recursive result
summaries) → **`native::rawabi::plan`** → escape / string region / block escape /
traversal / construction analyses → NIR lowering → Cranelift. The planner runs
after the Range results are stable and strictly before any lowering. It is
downstream of the proof: raw selection removes boxing, never a check the proof
relied on, so it cannot feed back into Range.

## Exact-call interaction

A caller uses a raw position only when `fn targets` names the exact callee
instance and the call goes to that instance's **canonical** function (not a
companion/fields variant, not an inlined tiny leaf, not a virtualized
de-closure call). The callee's plan is authoritative. A call through an exact
callable parameter that resolves to a raw instance is an ordinary exact call
(`raw-exact-callable-target-is-raw`: `apply_dyn<block(e2), int>=val,raw>raw`,
zero `callvalue`). Constant arguments to raw parameters are emitted as a bare
`rawint` (no tagged constant built and unboxed).

## Recursive-call interaction

Self non-tail calls resolve to the same canonical function and signature, so the
plan is stable under recursion (fib; `raw-non-tail-recursion-with-allocation`).
Self tail calls stay `tail` back edges; a raw parameter is a `rawreg` local, so
`tail` already passes raw (`raw-tail-recursion-keeps-self-tail`). Mixed
signatures are preserved (`sum<int, int>=raw,val>val`). The plan is per
instance, so a parameter whose recursive calls pass an unbounded value falls
back to tagged for every call (`raw-recursive-mixed-bound`).

## Errors / completions

Only the *successful* payload becomes raw. A function that cannot fail
(`Function::may_error == false`, the settled closed-call summary) returns the
bare integer: that is the `i64 f(i64…)` shape. A function that can fail returns
`(value, status)`: status `1` on success, `0` with an error pending (the error
exit returns `(0, 0)`); the call site checks the status word, not the value. A
raw callee's call site follows the callee's own settled `may_error` even with
`-call-effects-opt 0` (which otherwise forces every site to check), because the
integer has no sentinel. `raw-error-capable-result` (`check<int>=raw>raw` with
`fail Negative`, handled and propagated), `raw-error-path-and-caller-handle`
and `raw-error-escapes-uncaught-as-an-error` pin success, failure and handler.
On x86-64/Linux a stack overflow is the guard page and never an error return;
the fallback depth-check path is unchanged and behaves as it did for any
`may_error=false` tagged function.

## GC / root semantics

A raw Int is a non-root scalar. Raw registers are declared in `rawregs`, and a
raw parameter is defined with `def_raw`, so `codegen::roots` (which filters
`raw_regs`) never treats it as a root and no stack-map entry is emitted for it;
nothing is special-cased per parameter. A raw value live across a safepoint is
just a scalar in a register or spill. Pinned by `raw-gc-raw-live-across-
allocation` (raw `n`, a String and a List live across allocations, GC stress),
`raw-gc-recursive-allocating-frames` (200 allocating recursive frames, GC
stress), the executable tests (GC stress, relocated), the focused GC-stress
suite below, and a 300-program GC-stress fuzz run. Corpus effect (`out/roots.txt`):
safepoints 595 → 595, root candidates 1,283 → 1,238, root slots 812 → 781.
The `rbox` root-store cleanup is deliberately not folded in.

## NIR representation

The smallest coherent extension of the existing raw-value discipline: two
optional header attributes, `rawparams="i j …"` (parameter positions whose
*physical* incoming argument is raw; each must also be in `rawregs`, and the
prologue does no unboxing for it) and `rawresult=1`. Raw versus tagged values
stay explicit through `rawregs`. Validation (`nir.rs`): call/callenv argument
`i` is raw iff the callee's parameter `i` is, the destination is raw iff the
callee's result is, `ret` is raw iff the function's result is, `fnvalue`/
`closure` of a raw-ABI function is rejected, the program function and
companions cannot be raw. No HIR change, no semantic RawInt type, no new raw
arithmetic opcodes: existing `riadd`/`risub`/`rimul`/raw compares consume the
values directly.

Lowering support: raw `if` joins in the tail position or `return` of a raw-
result function (`rawjoin` demand; sound because the value flows into the
proven-small result Range) and a statement-position local alias `y = x` of a raw
register stays raw (`raw-alias-stays-raw`, `raw-branch-merge-stays-raw`,
`raw-return-statement-is-raw`).

## Cranelift signature / lowering

Parameters are `i64` either way, so the parameter signature is unchanged; the
only signature change is a raw-result function that may fail, which returns two
`i64` (value, status). `Symbols::status_result` tells call sites which callee
convention to read. JIT, object emission and standalone executables share this
code path (`raw-executable-fib`, `raw-executable-mixed`).

## Boundary conversions, continuous raw regions, mixed frontiers

Conversions happen exactly at the frontier and are cached (`TaggedOf`/`RawOf`).
`f → g → h` all raw: one continuous raw region, zero `rbox`/`runbox` in any of
them (`raw-chain-one-continuous-region`). Mixed `raw bump → tagged-only seven →
raw bump`: exactly one `rbox` (before the tagged position) and none around the
raw ones (`raw-mixed-frontier-converts-exactly-at-the-boundary`). A branch join
of a tagged-only Int stays tagged (`raw-branch-join-of-a-tagged-only-int-stays-
tagged`). A proven-constant result is replaced by the constant, the call itself
still emitted for effects.

## fib before/after NIR

Before (`audit/raw-int-abi/out/fib/abi0.nir`) as above. After
(`abi1.nir`):

```
func 0 "<program>" ...
    %0 = rawint 22
    %1 = call 1 %0
    %2 = op rbox %1                 ; the single frontier conversion
    ret %2
func 1 "fib" params=1 ... rawregs="0 2 4 6 7 8 10 11 12 13" rawparams="0" rawresult=1
    %3 = op rilt %0 %2
    br %3 L0 L1
  label L0
    %4 = move %0                    ; raw join register
    jump L2
  label L1
    %7 = op risub %0 %6
    %8 = call 1 %7                  ; raw call, raw result
    %11 = op risub %0 %10
    %12 = call 1 %11
    %13 = op riadd %8 %12
    %4 = move %13
    jump L2
  label L2
    ret %4
```

Recursive-hot-path `rbox`: **0**; `runbox`: **0**. Outer program boundary: one
`rawint` argument, one `rbox` of the final result.

## fib before/after machine code

(`audit/raw-int-abi/out/fib/abi{0,1}.asm`, `asmcensus.txt`.) Raw compare,
subtraction, call and addition now read as plain machine instructions:

```
before (tagged ABI)                           after (RawInt ABI)
sar  rax,1            ; untag n                 cmp  rsi,2          ; n is raw
cmp  rax,2                                       jl   leaf
lea/shl/or            ; retag n-1               mov  rsi,r12 ; sub rsi,1   ; n-1 raw
call fib
sar  rax,1            ; untag result            call fib            ; result in rax
lea/shl/or            ; retag n-2               mov  r15,rax ; sub rsi,2
call fib
sar  rax,1                                      call fib
add  ...                                        add  rax,rcx        ; raw add
shl rax,1 ; or rax,1  ; retag result            ret                 ; raw result
```

Function bytes: `fib<int>` 131 → 114 (object text), 148 → 141 (`codeSize`, with
padding); instructions 38 → 32; tag/untag shifts 9 → 0; stack stores 2 → 3 (one
more callee-saved spill); calls unchanged (2); safepoints/root candidates/slots
0 before and after (already zero after the previous milestone). The dead generic
entry wrapper grows 17 → 27 bytes (it now converts), see *Known limitations*.

## fib dynamic instructions

callgrind steady state, the same methodology (`profile-nir.sh`, 21 runs, run 0
excluded; `audit/raw-int-abi/out/fib/profile-abi{0,1}/`):

| | before | after |
|---|---:|---:|
| Ir/run | **1,547,454** | **1,404,178** (−9.3 %) |
| instructions per internal call (28,656 calls) | 37 | 30 |
| instructions per leaf call (28,657 calls) | 17 | 19 |

(`28,656·30 + 28,657·19 = 1,404,163` plus 15 outside `fib`; `28,656·37 +
28,657·17 = 1,547,441` before.)

Classes, per run: retag 171,936 → 2, untag 114,625 → 0 (**all 286,561 boundary
conversion Ir removed**); prologue 286,567 → 343,880 (+57,313), epilogue
343,881 → 401,194 (+57,313), `mov reg-reg` 343,875 → 372,532 (+28,657);
arithmetic 85,968, compare 57,313, `jcc` 57,313, calls 57,313, `jmp` 28,656
unchanged. The conversions are gone but the register allocator now keeps three
callee-saved registers (`vm`, `n`, the first result across the second call)
instead of two, which costs one push/pop pair on every call, including the leaf
path (17 → 19). Net −143,276 Ir. The raw ABI recovers the whole conversion
class; half of it is paid back by frame traffic.

## Residual machine-code opportunities (not optimised here)

Largest remaining instruction classes in `fib` (per run, of 1,404,178):

1. **epilogue** 401,194 (28.6 %) and **prologue** 343,880 (24.5 %) — together
   53 %: `push rbp; mov rbp,rsp; sub rsp,0x20`, three callee-saved spills and
   reloads, `add rsp; mov rsp,rbp; pop rbp; ret`. The leaf path pays the full
   frame for `n < 2` (shrink-wrapping / a leaf fast path would remove it).
2. **`mov reg-reg`** 372,532 (26.5 %) — argument shuffling around the two
   calls and the `vm` pointer carried through every call in `rdi`.
3. arithmetic 85,968, compare/branch 114,626, calls 57,313.

These are the input to the later bottom-up machine-code audit: frame setup
(shrink-wrapping, frame-pointer elision), callee-saved pressure, and the `vm`
argument. No frame optimisation was attempted.

## General non-recursive cases

`tests/raw-int-abi.test`: `inc_bounded(n) = n + 1` under a closed caller →
`raw>raw` (leaf inlining disabled to keep the boundary; with inlining on the
helper has no function at all); raw param / tagged result (`big(n) = n *
3·10^18`); tagged param / raw result (`seven(v) = 7`, `v` unbounded); mixed
`f(a, b, s)` = `raw, tagged, tagged`; negative range; smallMin/smallMax
round-trip; alias, branch merge, early `return`, constant arguments,
comparisons consuming raw directly.

## Negative / out-of-small / open / dynamic controls

* `succ(2^62-1)`: `raw>val` (result `2^62`), value `4611686018427387904` agrees
  everywhere; `ident(2^62)`: `val>val`.
* `fib(100)`: parameter raw, result tagged (`unbounded-or-not-small`, the
  finite-but-large control).
* open generic instance: `not-int` / `open-instance`, tagged.
* a Block value called dynamically runs the tagged generic entry and agrees.
* exact callable specialization calls the raw instance directly; the generic
  instance of the same function stays tagged.

## ABI census

`audit/raw-int-abi/out/census.txt` (17 canonical programs: `bench/*.bot`,
`examples/stdlib/*.bot`): **228 instances examined; 56 raw parameter positions;
23 raw results; 4 instances with both; 68 instances with any raw ABI (22
recursive, 46 non-recursive); 160 tagged-only.** Only a minority benefits;
`source-checks`, `test-selection`, `string_replace` gain nothing (every
position is `not-int` or unproven). Rejection tags observed: `not-int`,
`open-instance`, `unbounded-or-not-small`, `unknown-range` (`dynamic-entry`
is the program; `disabled` is `-raw-int-abi-opt 0`; `unsupported-completion`
and `variant-budget` do not occur: errors are supported and there is no
per-call variant). The functions that gain raw positions are listed per program
in `census.txt` (`-detail`); notable ones: `fib<int>` (both), `loop-count`'s
`work` (both) and `drive` (param), `byte::nibble` (both), the `ascii::is_*`
predicates (param), `ht_*_state` constants and `ht_capacity` (result), the
`matmul` `dot`/`product_row`/`product_rows` (params).

Call edges (corpus, emitted NIR): off — tagged→tagged 309; on — raw→raw 24,
tagged→raw 48 (frontier conversions in the caller), raw→tagged 18,
tagged→tagged 219.

## Conversion census

Total NIR `rbox`/`runbox`: **47/47 → 66/48**. Classified call-boundary
conversions (an `rbox` feeding a call argument or `ret`; a `runbox` of a call
result or of a parameter): rbox 20 → 19, runbox 18 → 5. fib: 3/3 → 1/0.
`loop-count` 4/1 → 2/0, `matmul` 5/5 → 6/5 with call-boundary runbox 3 → 0.
The static total went up in programs where an Int is raw only to be consumed by
tagged operations (hashtable `ht_probe_*`/`ht_grow_or_clean`/`ht_alloc`,
csv_records) — see limitations.

## Code-size impact

`out/codesize.txt`: whole-corpus machine code **101,963 → 101,662 bytes
(−301, −0.3 %)**; the functions that gain a raw signature −62 bytes (callers
shrink more than callees). fib 181 → 181 whole (`fib` 148 → 141, the program
function +7 for the `rawint`/`rbox`); loop-count −6; sum-refined −9; matmul
−223 (−4.7 %); refined-checks −21; csv_records −41; **hashtable +67 (+0.5 %)**,
csv_geometric +19. No pathological growth, but the "proven ⇒ raw, no
profitability test" policy is not uniformly a win in size.

## Compile-time impact

COMPILETIME_PLACEHOLDER

## Controls

`out/controls.txt`: with the ABI on and off the struct/transport census text,
the allocation count and bytes of a run, the allocations by kind and the guard
count are **identical** for `test-selection` (struct storage), `refined-checks`
(String representation), `hashtable` and `csv_records`. The raw ABI changes
Int parameter/result transport only.

## GC stress

GCSTRESS_PLACEHOLDER

## Standalone parity

`raw-executable-fib` and `raw-executable-mixed` (raw, tagged and error-capable
instances in one program) compile to an ELF, move it, delete the source, run it
with an empty `PATH`, and again under `BOTLISH_NATIVE_GC_STRESS=1`; the value
agrees with interp, compile, `cranelift-generic` and `cranelift`.

## Differential testing

* `tests/raw-int-abi.test`: every behavioural test runs interp, compile,
  cranelift-generic, cranelift, and native with the ABI on/off × leaf inlining
  on/off.
* `raw-fuzz-random-closed-helpers` (40 programs) and
  `raw-fuzz-random-self-recursion` (25) in the suite.
* `tools/fuzz.tcl`: **1,500 + 1,500 random programs and 300 under GC stress, 0
  disagreements** (`out/fuzz*.txt`); every program uses a raw ABI, about half
  have a raw result, ~2 % end in an error outcome (a runtime `mod` by zero).

## Full regression

FULLREGRESSION_PLACEHOLDER

## Existing tests that changed (and why)

* `native.test`: `native-call-1` regex; `native-repr-1,4,6,9,18,20,21,22` pin
  the *tagged-ABI* boundary conversions and now pass `-raw-int-abi-opt 0`
  (their subject — a conversion at a call boundary — no longer exists under the
  raw ABI; `raw-int-abi.test` pins the new behaviour at the same boundaries).
* `native-root-liveness.test`: `fib` 20 → 14 NIR registers, `loop-count` 16/15 →
  14/14 (fewer conversions).
* `native-tiny-leaf-pressure.test`: the "inlining never grows code" audit is
  the tagged-ABI property (`-raw-int-abi-opt 0`); a new test pins the
  production behaviour: no growth for the 1-op and chain leaves, under 10 % for
  the fold-resistant 8-op horner leaf (a raw call is cheaper than a tagged one,
  so the inline/call break-even moved; retuning is future work).

## Known limitations

* **No profitability test**: an Int that is only passed to tagged consumers gets
  a pointless conversion pair (callee `rbox`/caller `runbox`, or a tagged native
  result `runbox`ed to return raw). Measured: hashtable +0.5 % bytes, corpus
  `rbox` +19. A demand-based refinement (keep tagged when every exact caller
  and the callee body only want tagged) is future work and was not added, per
  the brief.
* Raw ABI is for the **canonical** function only. Companion, region,
  internal-capture and fields variants, `callmulti` field transport, closures'
  captured storage, struct/List/MutableArray storage, FFI/native calls and the
  program function stay tagged.
* Parameter type is read from the instance key (`int`); a closed *generic*
  instance whose parameters the closed-caller theorem merely narrows is not
  raw.
* Entry Range is the ordinary final entry Range, e.g. `fn f(n): if n == 0 …
  f(n - 1)` has entry `[-∞, 30]` (no decreasing guard) and its `n` stays tagged
  although the *external* entry is `{30}`. No Range analysis was added.
* The tagged generic-entry wrapper of a raw function is retained (dead,
  17 → 27 bytes for fib) — wrapper elimination was not attempted.
* RawInt currently means signed `i64`; target-specific machine-word lowering is
  open but not claimed.
* Leaf-path cost can rise (17 → 19 instructions for fib's leaf) when the
  allocator needs one more callee-saved register; no shrink-wrapping here.

## Readiness for short-string frontier heuristics

The shared concept is *semantic value → proven representable scalar form →
physical call/frontier representation*. Reusable as is: the plan keyed by
codegen instance and consulted by callee and callers alike; the physical-kind
vocabulary; the `rawparams`/`rawresult` header idea and `nir.rs`'s call-site
agreement validation; the raw alias / join / frontier-conversion machinery
(`RawOf`/`TaggedOf`, which would become per-representation converters); the
2-word `(value, status)` completion convention. Specific to Int: `fitsSmall`,
the `rbox`/`runbox` pair and raw arithmetic. A one-character-String → `u32`
Char frontier would add a second `PhysicalParamKind`, its proof (length-1
String fact) and its own conversion pair, not a new framework.

## Architecture questions

1. **Where is the plan computed?** `native::rawabi::plan`, called once from
   `native::lower::program` after `hir::specialize::analyze` and
   `hir::range::analyze`, stored in `native::lower::abiPlan`.
2. **Facts consumed?** `closed`, instance key/result types, final entry Ranges,
   successful-result Ranges, `fitsSmall` (+ whether block-escape is enabled).
3. **Does HIR change?** No.
4. **Does semantic Int typing change?** No.
5. **Is RawInt a source type?** No.
6. **What does RawInt physically mean?** Signed `i64` on the current native
   target.

## Eligibility questions

7. A parameter is raw when it is Int, the instance is closed and its final entry
   Range is `fitsSmall`.
8. The result is raw under the same three conditions on the successful-result
   Range.
9. `InstanceClosed` is required so the Range covers every invocation and no
   dynamic/Block-value caller can pass a tagged Value to a raw entry.
10. `fitsSmall` rather than "finite": only inside the tagged small domain are
    the conversions non-allocating and lossless.
11. Can a negative Range use RawInt? **Yes.**
12. Can a finite Range reaching `2^62` use RawInt? **No.**

## ABI questions

13. Can parameter and result decisions differ? **Yes.**
14. Can only some Int parameters be raw? **Yes.**
15. Physical raw layouts per codegen instance: **one planned layout.**
16. Caller/callee agreement: one stored plan read by both, plus `nir.rs`
    validation of every call, `ret` and `tail` against the callee's physical
    signature (a mismatch is a compile error, not a fallback).
17. Open caller: the instance is open, so the canonical tagged ABI
    (`open-instance`).
18. `callvalue`: always the generic tagged entry; a raw function has no Block
    value (`fnvalue`/`closure` rejected).

## fib questions

19. Is `n` passed raw recursively? **Yes.** 20. Results raw? **Yes.**
21. `rbox` remaining in the recursive hot path: **0.** 22. `runbox`: **0.**
23. Outermost boundary: one `rawint` argument and one `rbox` of the result.
24. Ir/run: 1,547,454 → 1,404,178. 25. Internal-call instructions: 37 → 30.
26. Leaf-call instructions: 17 → 19. 27. Function bytes: 148 → 141
    (`codeSize`), 131 → 114 (object text).

## Representation questions

28. No RawInt32: on the current 64-bit scalar call ABI, `i32` and `i64` both
    occupy one general machine argument/result slot; narrower width therefore
    does not reduce transport width, while it would multiply ABI variants.
29. Range may still record that a value fits `i32`: yes, but it is not an ABI
    class here.
30. Local/backend lowering may exploit narrower arithmetic later: yes.

## GC questions

31. Is RawInt a GC root? **No.** 32. Can it live across a safepoint? **Yes, as a
    non-root scalar.** 33. Stack maps: raw registers are declared in `rawregs`
    and `def_raw` never stores them; `codegen::roots` excludes `raw_regs` from
    liveness-derived root sets. 34. Pinned by the GC-stress tests listed in *GC
    / root semantics* and *GC stress*.

## Corpus questions

35. Instances gaining raw parameters: 56 positions across the instances listed
    in `census.txt` (68 instances have any raw position). 36. Raw results: 23.
37. Both: 4. 38. `rbox`/`runbox`: call-boundary runbox 18 → 5, call-boundary
    rbox 20 → 19; total static `rbox` 47 → 66, `runbox` 47 → 48 (net up, see
    limitations). 39. Whole-corpus machine bytes: 101,963 → 101,662. 40.
    Non-numeric workloads: struct storage, String representation, allocation
    counts and guards are identical (`controls.txt`); only Int helper
    signatures inside `hashtable`/`csv_*`/`refined-checks`/`uri-steady` changed.

## Future-facing question

41. See *Readiness for short-string frontier heuristics*.
