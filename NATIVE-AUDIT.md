# Native code-quality audit: fib, loop-count, refined-checks, sum-refined

A focused trace of four IR benchmarks from semantic facts to final x86-64
machine code, to explain where native (Cranelift) execution time goes and
name one general next optimization milestone. No source program was
changed. No broad optimization was implemented — this is diagnostic only.

Methodology, tooling, and full per-instruction evidence are in the
appendices at the end of this file. Read those before disputing a number
here.

## 1. Comparison table

Best-of-200 in-process runs, compile/JIT excluded, Botlish native (Cranelift)
backend; median in parentheses. Reference columns are the task's own
in-process numbers.

| benchmark | Botlish native (best / median) | Python in-process | Rust in-process | Botlish / Python | Botlish / Rust |
|---|---|---|---|---|---|
| `fib(18)` | 73.01us / 73.07us | 303.4us | 6.5us | **0.24x (4.2x faster)** | 11.2x slower |
| `loop-count.ir` = `drive(500,0)` | 5.95us / 5.97us | 164.0us | 0.18us | **0.036x (27.6x faster)** | 33.0x slower |
| `sum-refined.ir` = `sum(400,0)` | 22.60us / 22.82us | 200.8us | 0.11us | **0.11x (8.9x faster)** | 205.5x slower |
| `refined-checks(400)` | **cannot compile on the native backend** (see §5) | 697.6us | 116.3us | n/a | n/a |

Headline correction to the audit's own premise: on three of four benchmarks,
native Botlish is not "losing badly to CPython" — it beats Python
in-process by 4x–28x. The real gap the task should worry about is against
Rust (11x–205x), and that gap is *not* uniform: it is close to 1 order of
magnitude for ordinary recursion (`fib`) and loop overhead (`loop-count`),
and over 2 orders of magnitude for `sum-refined` specifically. That
concentration is itself the main finding (§7).

Semantic equivalence (Botlish IR vs. `bench/equivalents/{python,rust}`) was
verified by direct source comparison, not just matching output values: all
three runnable programs are structurally identical recursions across the
three languages (same base case, same step, same argument defaults), and
Python/Rust both use `black_box`/closures-over-locals specifically to block
constant-folding — confirmed by reading `bench/equivalents/rust/*.rs`. Values
checked: `fib(18)=2584`, `sum(400,0)=80200` (Gauss sum 1..400), `drive(500,0)=3500`
(`work(i)` is `i*3+7-i*3`, algebraically `7` for every `i`, so `drive` sums
`7` five hundred times — a property of the benchmark, not a bug: see §4).
All three match across Botlish/Python/Rust.

## 2. How to read the rest of this document

Every finding below is traced through six real, captured artifacts (not
inferred): HIR text (`hir::format`), per-expression range facts
(`hir::range::analyze`/`of`), specialization/AOT reports
(`hir::specialize::explain`, `hir::aot::explain`), NIR text
(`native::nir`), Cranelift IR text (`native::clif`), and disassembled x86-64
machine code (`botlish-native object` + `objdump -d`). §Appendix A explains
how to reproduce each. Numbered findings (F1–F7) are referenced from every
relevant section so the cross-program diagnosis in §7 can point back to
specific evidence instead of re-arguing it.

## 3. sum-refined.ir — audit (priority 1)

**Source shape:** `sum(n, acc)` tail-recurses; each step's accumulator
passes through a fresh closure `step = |x| x + n` created inline every call,
gated by a runtime `integer? acc` check the file's own comment says exists
because "the accumulator's type is only known through an integer?
refinement."

**1. Hot path.** A genuine machine-level loop (Cranelift `tail`
self-back-edge → a real `jmp` at the end of the compiled function, not
stack recursion) that, every iteration: re-evaluates `integer? acc`
(statically folded to `bool true` in NIR/CLIF, but verified **absent
entirely from the final machine code** — see F7), compares `n == 0`,
allocates a closure object for `step` via `rt_closure_new`, computes `n - 1`,
calls `step(acc)` as a real out-of-line function call, checks the call's
error sentinel, and jumps back.

**2. Raw vs. tagged.** Nothing in this hot path is raw. `n`'s HIR range is
`[-∞, 400]` (§Appendix B) — no lower bound — so `n == 0` and `n - 1` both
stay on the tagged fast/slow-split path (`op ieq`/`op isub`, not
`rieq`/`risub`). `acc`/`x` never get a static kind at all (`step`'s own
guard report: *"parameter x (no annotation, no call-site inference)"*), so
`step`'s `x + n` also stays tagged. Confirmed by NIR (`func 2 "step"`: no
`rawregs=` at all) — this is the one function of the twelve inspected
functions with zero raw registers.

**3. Runtime helpers per iteration.** `rt_closure_new` (unconditional,
allocates — see F1), plus, only on the (never-taken here) slow paths:
`rt_int_cmp` (n==0 fallback), `rt_int_sub` (n-1 overflow fallback),
`rt_int_add` (x+n overflow fallback), `rt_type_error` (x guard failure,
unreachable in this run). In the actually-executed path, exactly **one**
runtime call happens every iteration: `rt_closure_new`. `step` itself is
also a genuine, non-inlined function call (its own prologue/epilogue), so
there are two real `call` instructions per iteration total.

**4. Checks that execute.** `n == 0` (fast inline tag-check + compare, ~4
instructions, correctly predicted every time), `x`'s kind guard inside
`step` (a 3-tier inline check: small-int tag bit → heap-object kind-byte
fast mask → full byte compare; the common case is 1 test + 1 predicted
branch — see the disassembly in §Appendix C). Both are cheap in the observed
common case; neither is the dominant cost (see F1).

**5. Root/shadow-stack traffic.** `sum`'s frame has 13 slots (104 bytes),
zeroed once per *call* to `sum` (not per iteration, since the recursion is a
real loop) via 13 stores; every one of the ~9 tagged intermediate values
computed per iteration is additionally stored to its own permanent slot on
definition (F3). `step`'s frame has 3 slots, zeroed on every one of the 400
per-run calls into it (its own prologue), regardless of whether GC can occur
before its values die (it provably can, once, at the `rt_int_add` slow path
— but the store happens unconditionally either way, see F3).

**6. Stack traffic.** Beyond the shadow-stack root stores in (5): the
closure-construction call passes its one captured value through an
`explicit_slot` on `sum`'s native stack frame (a `stack_addr`+`store`+pass
pointer sequence) — real, per-iteration stack traffic that exists purely to
satisfy `rt_closure_new`'s C-ABI signature (an array-of-values pointer), not
because Botlish semantics require it.

**7. Facts known statically.** `sum<int,int>` is a fully specialized,
guard-free instance (`n:int, acc:int`, 0 guards) — the outer `integer? acc`
check folds to a compile-time constant. `step<generic>` never specializes:
`hir::specialize`'s own rule is *"Closures over values stay generic; their
captures' kinds would depend on the closure instance"* (`hir/specialize.tcl`
header) — `step` captures `n`, a value, so it is permanently generic
regardless of what any call site can prove (F2). `hir::range`'s
`ExternalSeeds` only seeds a parameter's range from a literal argument or a
`nonneg`/`collection-length` native result — never from a caller's own
already-bounded variable (F2) — so `x`'s range, and by the same mechanism
`acc`'s range across the self-tail loop (`hir::range::Call` returns
`unknown` for any call to a non-self block, `step` included), are `unknown`
end to end.

**8. Known facts that failed to affect codegen.** None, in the strict
sense — every fact that *was* proven (n:int, acc:int, the folded `integer?`
check) *did* remove real work. The gap is facts that were never derived in
the first place (item 7), not facts derived-and-ignored.

**9. Semantically necessary.** The `integer? acc` check's *presence in the
source* (it is what makes this benchmark test refinement-guarded recursion
at all) — though it costs nothing once compiled (F7). The arbitrary-precision
overflow fallback machinery on every arithmetic op (Botlish `Int` is
unbounded; F5). The error-sentinel check after `step`'s call (F6, ABI
requirement).

**10. Avoidable.** The closure allocation, if `step` could be proven
non-escaping (single call site, discarded immediately) and its addition
inlined (F1) — this is the single largest cost here (§Appendix D estimates
it against Rust, whose equivalent closure is fully stack-inlined, zero
allocation). The 13-slot-then-3-slot shadow-stack zeroing/storing that
exceeds what's simultaneously live (F3). The tagged (not raw) `n` arithmetic,
which a parameter-aware branch-narrowing pass could fix (F2).

## 4. loop-count.ir — audit (priority 2, baseline)

**Source shape:** `work(i)` is a native `loop` construct that always breaks
on its first pass (`i*3+7 >= 0` holds for every `i` in `[1,500]`, so the
`continue` arm is dead at these inputs — meaning `work`'s "loop" never
actually iterates more than once; all 500x repetition comes from `drive`'s
*outer* tail recursion calling `work` once per step). `work(i) = 7` for
every `i` algebraically (`(i*3+7)-(i*3)`), which is why the benchmark's
final value (3500) does not depend on which `i`s were summed — a property
of the benchmark's arithmetic, not a defect in it or in the compiler.

**1. Hot path.** `drive` compiles to a real machine loop (self-tail `jmp`
back-edge, confirmed in the disassembly). Each iteration: tagged `i <= 0`
compare, tagged `i - 1` subtract, a genuine (non-inlined) call into `work`,
a tagged `total + work(i)` add, jump back. `work` itself (called once per
`drive` iteration) does one pass of: tagged `i*3`, tagged `+7`, tagged
`>=0` compare, tagged `b-a` subtract, return.

**2. Raw vs. tagged.** **Nothing is raw**, in either function — this is the
"boring loop" the milestone asked for, and it is not boring. `work`'s own
parameter `i` has range `[-∞, +∞]` — *fully* unknown, strictly worse than
`sum-refined`'s `n`, because `work` is not self-recursive at all (no
induction/self-call feedback ever applies to it) and its one caller
(`drive`) passes `{ref i}`, a variable reference, which `hir::range`'s
`ExternalSeeds` does not treat as "syntactically evident" (F2). `drive`'s
own `i` has range `[-∞, 500]` — upper bound from the literal seed, no lower
bound, for the same parameter-narrowing gap as `fib` (F2, detailed there).

**3. Runtime helpers per iteration.** None on the fast path in either
function — every arithmetic/comparison op is a guard-free, kind-proven
tagged op, and codegen already gives every such op an inline
tag-check-then-checked-op fast path (`band`+`icmp`+checked-arith+`seto`,
falling to `rt_int_*` only on tag mismatch or overflow — see §Appendix C).
This is the one place the current backend is already close to optimal for
what it knows; raw registers would only remove the (cheap, well-predicted)
tag check and the checked-overflow branch, not add a runtime call.

**4. Checks that execute.** Four inline tagged fast-paths per full
`drive`+`work` iteration (`i<=0`, `i-1`, `i*3`, `+7`, `>=0`, `b-a` — six,
not four; all six are tag-check+op, all six take the fast branch every
time).

**5. Root/shadow-stack traffic.** `work<int>`'s frame is **13 slots (104
bytes)** for a function whose body computes four scalar intermediates that
are never simultaneously live for more than two at a time (F3) — the
1-slot-per-NIR-register allocation policy (no reuse) accounts for the
mismatch. `drive<int,int>`'s frame is 11 slots. Both are zeroed in full on
every call (`work`: 500 times per outer run; `drive`: once, since it loops).

**6. Stack traffic.** No explicit stack slots beyond the shadow-stack
region (no closures, no multi-value calls here) — this benchmark has the
least stack traffic of the three runnable ones.

**7. Facts known statically.** Both `work<int>` and `drive<int,int>` are
fully kind-specialized (0 runtime kind guards in either) — every operation
is *semantically* closed. The only missing fact is *representation*
(range), not kind.

**8. Known facts that failed to affect codegen.** None new beyond §3's
general finding (F2): the gap is entirely "never derived," not
"derived-and-ignored."

**9. Semantically necessary.** The overflow-checked-arithmetic fallback
capability on every op (F5) — even though never taken here, Botlish `Int`
being unbounded means the *capability* must exist in the compiled code.

**10. Avoidable.** All six arithmetic/comparison ops could be raw if `i`
carried a bound from its caller (F2) — this benchmark is the cleanest
possible demonstration of that gap, because there is no closure, no
refinement, and no BigInt path to confound the picture: every remaining
instruction here is either the arithmetic itself or the tag-check overhead
that a proven bound would remove.

## 5. refined-checks.ir — audit (priority 3)

**Finding, not a performance result:** refined-checks.ir cannot be compiled
by the native (Cranelift) backend at all, today. This is the single most
important fact this audit produced about this benchmark, and it changes
what "audit its runtime cost" can mean here.

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
== refined-checks.ir (cranelift)
   error: ir {1 2}: e39: native lowering does not support native uriEscape:
   the native "uriEscape" has no native implementation
   (NATIVE UNSUPPORTED {native uriEscape})
```

**Root cause (verified, isolated, and general — not specific to this
benchmark, per the milestone's rule against benchmark-specific findings):**
`native/lower.tcl`'s `natives` dict is a fixed, hardcoded whitelist of
built-in operators (`+ - * < <= ... integer? string? list? ok? error? ...`).
Any native registered by a *library* via `core::type::definePredicate` /
`core::native::register` (`lib/web.tcl`'s `Emailish?`, `UriQueryValue?`,
`uriEscape`) is entirely absent from that whitelist. `NativeCall`
(`native/lower.tcl:2183`) checks `![dict exists $natives $name]` and raises
`NATIVE UNSUPPORTED` **before** it ever checks whether HIR already proved
the call's outcome statically (`[dict get $node known]` is checked *after*
the whitelist check, not before). I confirmed this in isolation: a two-line
program calling only `Emailish?` (no `uriEscape` at all) fails the same way
(`e4: native lowering does not support native Emailish?`). So even the
benchmark's *"statically redundant" re-check* — the one the file's own
comment says HIR should be able to prove away — cannot currently be lowered
at all, proven-constant or not.

Concretely: **there is no Cranelift IR and no machine code for this
benchmark to inspect.** `uriEscape` blocks the top-level `bind q` (which
runs once, outside the hot loop) before native lowering ever reaches
`check`'s own body; and even if it didn't, `check`'s own `Emailish?(s)` call
would independently fail the same whitelist check.

**What is available instead.** The only Botlish numbers that exist today
for this program come from the **`compile`** backend (Tcl-generated code —
a different pipeline entirely: no Cranelift, no shadow stack, no machine
code) and the **`interp`** backend, both of which do support library
natives:

```
program              interp     compile     python      rust    speedup
refined-checks.ir   413.7ms      10.5ms   762.32us   191.48us    39.6x
```

These are best-of-2 subprocess-wall numbers from the stock `bench/bench.tcl`
(itself never exercising Cranelift by default — see §Appendix E), not
in-process, and not from the audited backend; they are reported here only
for completeness, not as evidence about native code quality.

**What the architecture predicts for the loop mechanics, by inspection
(not measured, since it cannot be compiled):** `check`'s own recursion has
the identical shape as `drive`'s (`if n<=0: return acc else: recurse(n-1,
acc+hit)`, a self-tail call on a parameter compared against a literal) — so
by §4's finding (F2), `n`'s comparison and decrement would also stay tagged
for the same parameter-narrowing reason, and `acc + hit` would stay tagged
because `hit`'s value flows out of the (currently unsupported) predicate
calls. No closure is created per iteration here (unlike `sum-refined`), so
whatever cost this benchmark would show is structurally closer to
`loop-count`'s than to `sum-refined`'s — modulo whatever cost the
predicate-evidence checks themselves would add once implemented, which
cannot be estimated without building that support.

**Rust context (§Appendix F):** Rust's reference is 116.3us in-process —
far above `fib`/`loop-count`/`sum-refined`'s Rust numbers (6.5us/0.18us/0.11us),
because `Emailish?` there is a real hand-rolled scanner over the string's
characters (`bench/equivalents/rust/refined_checks.rs`), not a
constant-foldable arithmetic loop. This is exactly the milestone's own
prediction (item 16): "the fact that Rust remains much slower here...
suggests real unavoidable work" — confirmed. This benchmark is not
comparable to the other three's near-machine-limit Rust baselines; whatever
gap Botlish eventually shows here should be judged against a
hundred-microsecond floor, not a sub-microsecond one.

## 6. fib.ir — audit (priority 4, call/recursion mechanics)

**Source shape:** naive non-tail recursive Fibonacci, `fib(n) = n if n<2
else fib(n-1)+fib(n-2)`.

**1. Hot path.** Genuine non-tail recursion — every call is a real x86
`call` instruction with a full prologue/epilogue (this is the intended
audit target: ordinary call overhead, not loop overhead). Per call:
prologue (frame-bump + stack-overflow check, 14 shadow-stack slots zeroed —
14 stores), tagged `n < 2` compare, two tagged `n-1`/`n-2` subtractions each
guarding a real recursive `call`, a tagged `+` combining both results,
epilogue (restore 4 callee-saved registers, pop frame).

**2. Raw vs. tagged.** Nothing raw. `n`'s range is `[-∞, 18]` (upper bound
only, from the literal seed 18) — and, distinct from `sum-refined`/`loop-count`,
this is architecturally *unfixable by the same mechanism* that would fix
those: `fib` is not self-tail-recursive (its recursive calls feed a `+`,
not a direct return), so neither `hir::induction`'s equality-termination
proof nor the self-call range-feedback fixpoint in `hir::range::analyze`
ever runs on it at all — both are gated on `HasSelfTailCall`/self-tail-loop
shape. The one gap that *would* help fib regardless (parameter-aware branch
narrowing on `n < 2`, F2) is the same gap identified for the other three.

**3. Runtime helpers per call.** None on the fast path (same
inline-fast-path pattern as `loop-count`, confirmed in disassembly): `n<2`,
`n-1`, `n-2`, and the final `+` are all guard-free tagged ops with inline
fast paths; `rt_int_cmp`/`rt_int_sub`(x2)/`rt_int_add` are only reachable on
tag-mismatch or overflow, never taken here.

**4. Checks that execute.** The four fast-path checks above, per call.

**5. Root/shadow-stack traffic.** `fib<int>`'s frame is **14 slots (112
bytes)**, zeroed on every one of the ~8,361 calls `fib(18)` makes
(`2*fib(19)-1`; standard non-memoized fib call count). 14 registers for a
one-parameter function whose peak simultaneous liveness is far smaller is
the same F3 pattern as `loop-count`'s `work`, here paid ~8,361 times instead
of 500 — this benchmark's call volume makes F3's cost the most repeated of
the four.

**6. Stack traffic.** Standard native call/return stack traffic
(return address, 4 callee-saved register spills/reloads per call from the
System V ABI prologue/epilogue) — nothing Botlish-specific beyond the
shadow-stack slots already counted in (5).

**7. Facts known statically.** `fib<int>` is fully specialized (`n:int`, 0
guards) via the literal-seeded call site (`{const 18}`) — this is
`hir::specialize`'s ordinary literal-argument case, and it works correctly
here (contrast `step`'s permanently-generic closure case in §3).

**8. Known facts that failed to affect codegen.** None beyond F2 (n's
range is simply never derived past its upper bound).

**9. Semantically necessary.** Two real recursive calls per invocation
(non-tail, by construction — this is what the benchmark exists to measure);
the arbitrary-precision overflow fallback on every arithmetic op (F5); the
error-sentinel check after each recursive call (F6).

**10. Avoidable.** The 14-vs-actual-liveness shadow-stack over-provisioning
(F3) — repeated more times here (8,361 calls) than in any other benchmark,
making it the single highest-frequency instance of F3 in this corpus. The
tagged (not raw) `n` comparison/arithmetic (F2), which would remove the tag
checks but not the two calls themselves (those are semantically required).

## 7. Cross-program diagnosis

Seven findings, each traced through source in §Appendices B–D; the letter
prefix is the classification from item 9 of the task (A–F).

- **F1 — No escape analysis for closures over captured values (class D,
  compiler artifact).** `hir/escape.tcl` scalar-replaces fixed-shape
  *List* constructions whose identity is proven never observed, but there
  is no equivalent analysis for *Block* (closure) values. `step` in
  `sum-refined` is created fresh, captured by a caller that immediately and
  exclusively calls it once, and discarded — a textbook non-escaping
  closure — yet is unconditionally heap-allocated via `rt_closure_new`
  every iteration. Compounding this, `heap.rs`'s own header documents the
  allocator as "Temporary memory-management strategy for the first native
  backend... every heap object is an individually allocated Rust box" (not
  a bump/nursery allocator) — so each of these 400 allocations is a real
  `malloc`-class call plus a `Vec` registration, not a cheap pointer bump.
  **This is specific to closures-over-values; it is the dominant cost of
  `sum-refined` and the primary reason its Botlish/Rust ratio (205x) is
  roughly 20x worse than the other two runnable benchmarks' ratios
  (11x, 33x) — Rust's equivalent closure is fully stack-inlined by LLVM
  with zero allocation, which is the single largest semantic-capability gap
  this audit found.**

- **F2 — Range/induction proofs never reach a function parameter through
  an ordinary comparison guard, and the induction pass only scans a
  function's top-level body (class D, compiler artifact — proof not
  strong enough, not a missing lowering step).** Two compounding, precisely
  located gaps:
  - `hir::range::ComparisonNarrowing`'s `Narrowed`-writing step
    (`RefBinding`, `hir/range.tcl`) explicitly requires
    `[dict get [hir::binding $hir $b] kind] eq "local"`. A function
    **parameter**'s binding kind is `param`, not `local` (`hir/hir.tcl`'s
    own binding-kind enumeration: `root | ambient | param | local`) — so
    the general `< <= > >=` branch-narrowing machinery, which the module's
    own comment claims "already handles every `< <= > >=` guard soundly and
    generally," structurally cannot narrow a parameter's own range, ever.
    Verified empirically: `work`'s local `b` (from `bind b`) *is* narrowed
    by its own `>= 0` guard (range `[0,+∞]`, confirmed in the dump); `fib`'s
    parameter `n` is *not* narrowed by the structurally identical `n < 2`
    guard on its own parameter (range stays `[-∞,18]` inside the recursive
    branch, confirmed in the dump).
  - `hir::induction`'s equality-termination proof (the mechanism that
    *does* reach parameters, and is exactly the shape `sum-refined`'s
    `n == 0` recursion needs) only scans "the instance's own top-level body
    list" (module header, and `TerminatingBranch`/`Guard`'s implementation).
    `sum-refined`'s `n == 0` check is nested one level inside the
    (semantically necessary) outer `integer? acc` guard, so the pattern
    never matches, despite being the textbook shape the module exists for.
  - **This single pair of gaps is why every comparison/subtraction on a
    loop or recursion counter in all three runnable benchmarks (`fib`'s
    `n`, `loop-count`'s `i` in both `work` and `drive`, `sum-refined`'s `n`)
    stays on the tagged fast-path instead of becoming a bare machine
    integer — it is the most general finding in this audit, appearing in
    every benchmark, entirely independent of closures, refinements, or
    recursion shape.**

- **F3 — Shadow-stack GC roots are allocated one-per-NIR-virtual-register
  for the whole function, never based on liveness (class C/D boundary:
  documented design, not a bug, but demonstrably more conservative than
  necessary).** `native/src/codegen/clif.rs`'s own header: *"the prologue
  reserves one shadow-stack slot per register... every definition of a
  register is stored to its slot."* `def()` (line 354) stores
  unconditionally on every register definition, with no lifetime/liveness
  analysis. Frame sizes measured: `fib<int>` 14 slots for ~2 peak-live
  values, `work<int>` 13 slots for ~4, `sum<int,int>` 13 then `step` 3.
  Every one of these slots is zeroed in the prologue and re-written on
  every definition, whether or not a GC-triggering call can occur between
  that definition and its last use. This appears in **every** compiled
  function, independent of loop/recursion/closure shape, making it the
  single most repeated inefficiency by raw instruction count across the
  whole corpus (most acute in `fib`, at ~8,361 calls).

- **F4 — Cranelift-level waste does not always survive to machine code (a
  methodological caveat, not a defect).** `sum-refined`'s folded-but-still-
  branching `integer? acc == true` check is a real conditional branch in
  the Cranelift IR text dump, but **is completely absent from the
  disassembled machine code** — Cranelift's own optimizer removes it. This
  was verified by direct objdump inspection (§Appendix C), not assumed.
  Lesson for future audits of this kind: NIR/CLIF-level "redundant work" is
  not always real; always confirm against actual disassembly before
  attributing cost to it.

- **F5 — Arbitrary-precision Int semantics (class B, genuinely necessary).**
  Every arithmetic/comparison op pays for a checked-overflow fast path plus
  a `rt_int_*`/BigInt-capable slow path, in every benchmark, because
  Botlish `Int` is unbounded. This is real, required cost, but it is
  *cheap* in the observed common case (inline tag-check + hardware
  overflow-flag instruction + correctly-predicted branch, confirmed in
  disassembly) — it is not the dominant cost anywhere in this corpus; F1–F3
  dominate it by a wide margin wherever they apply.

- **F6 — Per-call error-sentinel checks and shadow-frame push/pop (class
  C, ABI/runtime requirement).** Every call checks its `0`-sentinel return
  for an error and every function's prologue/epilogue manages its shadow
  frame — necessary given the completion-code-via-return-value calling
  convention and precise (non-conservative) GC rooting; not a target for
  this milestone.

- **F7 — refined-checks.ir cannot run on the native backend at all (class
  D, compiler artifact — missing feature, not a performance issue).**
  `native/lower.tcl`'s native whitelist has no entry for library-registered
  refined-type predicates, and the unsupported-native check runs before
  the statically-known-outcome check, so not even a provably-constant call
  to such a predicate can lower. This is orthogonal to F1–F3 (a capability
  gap, not a code-quality gap) but blocks this audit from measuring
  refinement-check elimination at all on the intended backend.

**Cross-cutting answers the task asked for directly:**

- *Which inefficiency appears in all four?* F2 (parameter range-narrowing)
  and F3 (per-register shadow-stack slots) — both are structural, both are
  independent of what the benchmark computes.
- *Specific to reductions?* F1 (closure allocation) — only `sum-refined`
  creates a closure per step; this is why it is the outlier at 205x vs.
  Rust instead of ~10–33x.
- *Specific to refined values?* F7 — the only benchmark using
  library-registered refined-type predicates is also the only one that
  cannot compile at all.
- *Specific to ordinary calls/recursion?* F3 is paid most frequently here
  (8,361 calls for `fib(18)`), though it is not unique to recursion.
- *From arbitrary-precision Int semantics?* F5 — real, but consistently
  minor next to F1–F3 in this corpus.
- *From GC?* F1's allocation cost (a real `malloc`+registration per
  closure, not a bump allocation — `heap.rs`'s own documented "temporary"
  design) and F3's conservative rooting.
- *Cranelift/backend artifacts rather than Botlish IR problems?* None
  found that cost real cycles — F4 shows Cranelift's own optimizer removing
  IR-visible waste; the inline tag-check/overflow fast paths codegen
  already generates for guard-free tagged ops (§4.3, §6.3) are close to
  what a hand-tuned dynamic-language backend would produce. Every
  identified cost traces to the Tcl-side analysis/lowering layer
  (`hir/range.tcl`, `hir/induction.tcl`, `hir/specialize.tcl`,
  `native/lower.tcl`) or to the documented-as-temporary heap allocator, not
  to Cranelift or `codegen/clif.rs`'s instruction selection.

## 8. What single general optimization milestone should come next?

**Closure escape analysis for non-escaping Block values captured over a
local, with inline (register-only) evaluation of the closure body at its
one call site when it doesn't escape — the `sum-refined` case (F1).**

Support, weighed against the alternative candidates (F2, F3):

- **Machine-code evidence.** F1 is the only finding whose absence produces
  a qualitatively different *kind* of cost (a real heap allocation +
  out-of-line call) rather than a quantitatively larger version of an
  already-cheap inline sequence. F2 and F3 both cost a handful of extra
  instructions per site, well within normal dynamic-language overhead; F1
  costs a `malloc`-class runtime call every single iteration.
  §7's Rust comparison makes this precise: `sum-refined` is the *only*
  benchmark of the three runnable ones whose Botlish/Rust ratio (205x) is
  an order of magnitude worse than the others' (11x, 33x) — and the
  difference is exactly this allocation, confirmed by disassembly, not
  inferred from timing alone.
- **Generality.** Closures captured over a local and called at a single,
  statically known site are a common pattern in idiomatic Botlish (any
  helper function bound with `bind` inside a loop body or recursive step),
  not specific to this one benchmark — `hir/escape.tcl` already proves the
  discipline works for List aggregates for exactly this reason; extending
  it to Block values is architecturally the same shape of analysis
  (`hir::escape::Classify`'s `local`/`remote` cases), reusing a pattern the
  codebase has already validated once.
- **Benchmark impact.** Directly responsible for the largest single
  Botlish/Rust gap measured in this audit (205x vs. 11x–33x for the other
  two runnable benchmarks).
- **Implementation complexity.** Larger than F2 (a scope-restriction lift
  on an existing analysis) but the escape-analysis machinery, companion-
  function calling convention (`callmulti`/`retmulti`), and "ask for the
  representation actually wanted" discipline this would extend already
  exist and are documented and tested for the List case — this is not a
  new analysis framework, it is a new `Classify` case in an existing one.
- **Semantic risk.** Low if scoped to the same soundness discipline
  `hir/escape.tcl` already uses (single, statically-provable non-escaping
  use) — GC rooting needs no new mechanism either, by the same reasoning
  `hir/escape.tcl`'s header already gives for List scalar replacement
  ("every field register is an ordinary tagged NIR register... rooted
  exactly as it was before").

F2 (parameter-aware range narrowing) is a legitimate, cheap, high-generality
second candidate — it is genuinely the *most general* finding (appears in
literally every benchmark, unconditionally), and lifting the
`kind eq "local"` restriction in `RefBinding` plus letting
`hir::induction::Guard` look one level past a non-terminating sibling `if`
would likely unlock raw representation broadly with low implementation
risk. It is not ranked first only because its per-site cost (a tag check
plus a correctly-predicted branch) is already small in absolute terms next
to F1's real allocation — but it should be the milestone immediately after
this one, precisely because of how general and low-risk it is.

F3 (per-register shadow-stack slots → liveness-based slot reuse) is
real and the single most *frequently repeated* inefficiency by instruction
count, but touches GC-rooting correctness directly (item 17's explicit
warning: "do not weaken GC correctness") and would need its own careful
liveness analysis to be done safely — higher risk, and the milestone
description explicitly excludes "new register allocator"/GC-adjacent
redesign from this round. Worth its own dedicated, carefully-scoped
follow-up, not bundled into the F1 milestone.

---

# Appendices

## Appendix A — Reproducing this audit

Build: `cargo build --release --manifest-path native/Cargo.toml` (rustc
1.95+; AGENTS.md documents the rustup steps) and install Tcl 9
(AGENTS.md). `native/explain-native.tcl` (added by this audit; see below)
dumps HIR, NIR, Cranelift IR, and per-expression range facts for any `.ir`
bench file:

```sh
tclsh9.0 native/explain-native.tcl bench/sum-refined.ir /tmp/out
```

writes `hir.txt`, `nir.txt`, `clif.txt`, `aot.txt`, `aot-spec.txt`,
`range-params.txt`, `range-exprs.txt`, and `program.nir` (feedable straight
to the Rust driver). Machine code and in-process timing:

```sh
./native/target/release/botlish-native object /tmp/out.o /tmp/out/program.nir
objdump -d --no-show-raw-insn -M intel /tmp/out.o
./native/target/release/botlish-native bench 200 /tmp/out/program.nir
```

`bench`'s existing `timing COMPILE_US BEST_US RUNS COLLECTIONS` line already
excludes JIT compilation from the timed region (`Instant::now()` starts
after `backend.compile()` returns); this audit's one Rust-side change adds
a `times T1 T2 ... TN` line (raw per-run nanoseconds) alongside it, purely
additive, so a median/distribution can be computed without changing the
existing contract (see `native/src/main.rs`'s diff). This is the "minimal
diagnostic tooling" the milestone brief permits (item 8) — it does not
implement or ship any optimization.

## Appendix B — Range facts (raw dumps)

```
fib<int>:      param 0 (n)     range [-∞, 18]
work<int>:     param 0 (i)     range [-∞, +∞]
drive<int,int>: param 0 (i)    range [-∞, 500]
                param 1 (total) range [-∞, +∞]
sum<int,int>:  param 0 (n)     range [-∞, 400]
               param 1 (acc)   range [-∞, +∞]
step<generic>: param 0 (x)     range [-∞, +∞]
```

Per-expression evidence for F2's parameter-narrowing gap (fib, instance
i1; `e6` is the condition's own read of `n`, `e15`/`e21` are `n` read
*inside the recursive (n≥2) branch*, where a working narrowing pass would
show `[2, 18]`):

```
e6:  [-∞, 18]     (n, in the `n < 2` condition)
e15: [-∞, 18]     (n, inside `n - 1`, else branch)
e21: [-∞, 18]     (n, inside `n - 2`, else branch)
```

Contrast, `loop-count` instance i2 (`work`): `e22` is `ref b` (a *local*,
`bind b`) inside the *true* branch of `if b >= 0`, correctly narrowed:

```
e22: [0, +∞]      (b, inside `b - a`, true branch of `b >= 0`)
```

confirming the gap is specific to parameter bindings, not a general failure
of branch narrowing.

## Appendix C — Disassembly excerpts (annotated)

`sum-refined`'s compiled loop body (`botlish_fn_1`, the `sum` function;
`0x1ac` is the loop head, reached both on function entry and via the
back-edge at `0x2fd`):

```asm
 1ac: mov QWORD PTR [r12+0x10], 0x6      ; root-store the folded `integer? acc`==true
                                          ; result -- but note: no branch on it at all here
 1be: mov rsi, r14                       ; n
 1c1: test rsi, 0x1                      ; small-int tag check  [F5: cheap, required]
 1c8: jne 1f7                            ; tag valid -> fast path (taken every time here)
 1f7: mov ecx, 0x2                       ; false tag
      cmp rsi, 0x1                       ; n == tagged(0) ?           [n == 0, tagged compare]
      cmove rcx, [rip+...]               ; -> true tag if equal
 210: cmp rcx, 0x6
 214: je 302                             ; n==0 -> return acc (not taken in steady state)
 21a: lea r8, [rsp]                      ; &captured-value array       [F1: closure alloc setup]
      mov [rsp], rsi                     ; store n as the one capture
      mov rdx, [rip+...]                 ; step's code address
      mov r9, [rip+...]                  ; rt_closure_new
      call r9                            ; REAL HEAP ALLOCATION, every iteration  [F1]
 246: mov [r12+0x40], rbx                ; root-store the new closure
 254: test rsi, 0x1                      ; n's tag again               [F5]
      sub r10, 0x3 ; seto al             ; checked n-1 fast path
 288: (slow path: call rt_int_sub, not taken here)
 2a7: mov rdx, r15  ; mov rsi, rbx  ; mov rdi, r13
 2b0: call step                          ; REAL, NON-INLINED CALL       [F1: not inlinable
                                          ; because step is permanently generic]
 2b5: test rax, rax ; jne 2e9            ; error-sentinel check         [F6]
 2e9: ... ; jmp 1ac                      ; real backward jump: confirmed a hardware loop
```

`step`'s own compiled body (`botlish_fn_2`) — the closure-call target:

```asm
 38d: push rbp ; mov rbp,rsp ; sub rsp,0x10   ; prologue
 39e: ... ; lea rcx,[rbx+0x18] ; cmp rcx,rax ; ja <overflow>  ; frame-bump + stack-check [F6]
 3b9/3c0/3c8: mov QWORD PTR [rbx+N], 0x0       ; zero 3 shadow-stack slots  [F3: 3 slots
                                                 ; for a function with 1 param + 1 temp]
 3d3: mov rax,[rsi+0x20] ; mov rax,[rax]       ; load captured `n` out of the closure env
 3e6: test rdx,0x1 ; je 3fb                    ; guard x: small-int tag fast path
 3fb: test rdx,0x7 ; je 412                    ; else: heap-object kind-byte fast mask
 412: movzx rax,[rdx] ; cmp al,0x1             ; else: full kind-byte compare (rare path)
 41e: test cl,cl ; jne 458                     ; guard passed -> proceed
 426: (guard failed -> call rt_type_error, unreachable in this run)
 458: and rax,rdx ; test rax,0x1 ; je 485      ; x+n: tag check
      lea rcx,[rdx-1] ; add rax,rcx ; seto cl  ; checked add, fast path
 491: mov [rbx+0x10],rax                       ; root-store result
      ... ; ret                                ; epilogue
```

`loop-count`'s `work<int>` fast path (representative of the "already
close to optimal" tagged-arithmetic pattern, F5) — every op here is
tag-check + hardware checked-op + correctly-predicted branch, no calls:

```asm
 ...: band vN, tagmask ; icmp ne ; brif -> fast/slow    ; per-op tag check
 ...: sshr/smul_overflow/sadd_overflow/ssub_overflow ... ; hardware checked op
 ...: brif overflow -> rt_int_{mul,add,sub,cmp} (never taken in this benchmark)
```

Object/function sizes (`botlish-native size`), machine-code bytes:

| program | `<program>` | fn A | fn B |
|---|---|---|---|
| `sum-refined` | 230B | `sum` 693B | `step` 347B |
| `loop-count` | 230B | `work` 641B | `drive` 637B |
| `fib` | 203B | `fib` 761B | — |

## Appendix D — Rust comparison, why the closure case differs

`bench/equivalents/rust/sum_refined.rs`'s `step` closure captures `n: i64`
by value, is never returned or stored (used exactly once, at its creation
site), and is therefore inlined by LLVM into a bare register add with zero
heap allocation — verified by the reference timing itself (0.11us for 400
steps ≈ 0.28ns/step, consistent with one inlined `add` plus loop overhead,
not consistent with any allocation). The Rust source's own comment
confirms the semantic simplification this permits: *"Rust's static typing
makes the integer? refinement check trivially true for an i64 accumulator;
it is omitted rather than faked as a runtime check."* This is the
"aggressively optimized native implementation of the same benchmark shape"
item 29 asks Rust to demonstrate — and it demonstrates precisely the
capability (non-escaping closure inlining) F1 recommends as the next
milestone.

## Appendix E — bench.tcl / CI does not exercise the native backend today

`bench/bench.tcl` sources only `compiler/compiler.tcl` (the Tcl-codegen
backend), not `native/native.tcl` — so `core::backends` never includes
`cranelift`/`cranelift-generic` in its default run, and
`.github/workflows/bench.yml` never builds the Rust backend
(`cargo build` does not appear in that workflow at all). This means the
task's own framing — "recent performance comparisons suggest... native
Botlish code is still substantially slower than expected" — was evidently
based on ad hoc/manual runs, not CI, and no routine Botlish-native-in-process
number existed anywhere in the repository before this audit (acceptance
criterion #1 was, accordingly, not previously satisfied). This audit's
in-process numbers (§1) are the first such measurement on record.

## Appendix F — Native backend diagnostic script

Added by this audit, `native/explain-native.tcl`: a thin, read-only script
over existing, tested infrastructure (`hir::format`, `hir::range::analyze`,
`hir::specialize::explain`, `hir::aot::explain`, `native::nir`,
`native::clif`) with no knowledge of any specific benchmark by name (per
item 33) — it takes any `.ir` file and an output directory and works
structurally. It performs no analysis of its own and changes no compiler
behavior.
