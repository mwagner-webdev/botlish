# Block escape analysis and virtualization (F1 follow-up to NATIVE-AUDIT.md)

This implements the optimization milestone NATIVE-AUDIT.md's §8 named as the
single most valuable next step: eliminate the per-iteration heap Block
(closure) allocation `sum-refined.ir`'s `step` pays for, by proving it never
escapes and lowering its one captured value (`n`) as an ordinary internal
call argument instead of a heap closure environment. `bench/sum-refined.ir`
is unmodified; the optimization is general (§"Anti-overfitting" below), not
keyed on this benchmark's names.

## 1. Summary of the change

A locally-bound Block value all of whose uses are statically known direct
calls (never returned, stored, passed to unknown code, or observed by
identity) is now represented, for native lowering, as **code identity +
ordinary capture values** instead of a canonical heap closure. Its direct
call sites call a *capture-explicit internal variant* of the callee
directly, with the captures appended as ordinary trailing arguments. No new
runtime object, no new NIR opcode, no new Cranelift/codegen mechanism: the
internal variant is lowered by the exact same function-lowering machinery as
an ordinary function, just with `env=0` and the capture bindings pre-bound
to trailing parameter registers instead of `capture I` loads out of a
closure environment.

For `sum-refined.ir`'s `sum(400, 0)`: **400 `step` heap-Block allocations
become 0**, `rt_closure_new` disappears from the compiled loop entirely, and
the benchmark's own in-process best/median time drops from **20.90us /
21.92us to 1.71us / 1.71us** (about 12.6x), with identical output
(`int 80200`) on both the optimized and canonical (`-block-escape-opt 0`)
path. `fib(18)` and `drive(500,0)` (`loop-count.ir`), which never build a
closure, are unaffected (differences are run-to-run noise, not a real
effect — see §8).

## 2. Files changed

- `hir/blockescape.tcl` (new) — the HIR-level escape analysis: which local
  Block bindings are provably nonescaping, and which callee instance each
  demands an internal variant for.
- `hir/hir.tcl` — registers the new module in the module load order (after
  `escape`, since its header explicitly says it may reuse `hir::escape`
  helpers, which it does: `hir::escape::TrailingPositions`).
- `native/lower.tcl` — the "Block virtualization" section (new, alongside
  the existing "Representation"/"Scalar replacement"/"String regions"
  sections): the `-block-escape-opt`/`BOTLISH_NATIVE_BLOCK_ESCAPE_OPT` flag,
  `InternalFunction` (the internal-variant lowering), `InternalRef`,
  `VirtualBlockCall`, `VirtualBlockCaptures`/`CaptureValues` (factored out of
  `Closure`, which now calls the same helper), and the two call sites that
  consult the analysis (`Bind`, `Call`).
- `tests/native-block-escape.test` (new) — 19 tests covering the criteria
  below.
- `tests/native.test` — one pre-existing test (`native-call-6`) updated: it
  asserted a captured-value closure's canonical (closure-taking) function is
  always emitted, which stopped being true now that a *fully* direct-called
  closure's canonical function is no longer needed at all (see §5's
  "canonical function becomes unreferenced" note). The fix adds a second,
  escaping reference so the binding keeps needing its canonical closure,
  preserving the test's original intent (documented inline).

No Rust code changed. No changes to `hir/range.tcl`, `hir/induction.tcl`, or
`hir/specialize.tcl` (see §9 and §11).

## 3. Nonescape criteria (`hir/blockescape.tcl`)

A local binding `b`, bound once (non-duplicate, kind `local`, never an
implicit return of its own scope, never itself captured by another block),
to a block literal `L`, is virtualized only if **all** hold:

1. `L` is not `envless` (a zero-capture block already takes the existing
   zero-allocation `fnvalue`/direct-`call` path — nothing for this analysis
   to add; see §7).
2. `L` needs no `self`: no binding `L` captures is itself bound (via
   `hir::aot::BoundBlock`) to `L` — i.e. `L` does not reference its own
   binding from inside its own body (no direct recursion; see §10).
3. `L` captures no binding `hir::aot::context`'s `cells` marks as a
   forward-reference cell (a captured *cell reference*, not an ordinary
   resolved value — out of scope for this first implementation; see §10).
4. `b` itself is not such a cell.
5. Every reference to `b` in the same region is exactly the callee of a
   `call` expression whose HIR-resolved target is `L`, with matching arity,
   and whose `hir::specialize` instance (the same `instance.calls` map
   `hir::escape.tcl`'s "remote" List case already consults) resolves to one
   single instance across every such call site.

Any other use at all — a return, a store into an aggregate, an argument to
an unrelated function, a comparison, a dynamic dispatch — means the binding
is declined *entirely* (mixed direct-call-plus-escaping use is not
partially optimized; see the `blockescape-stored-1` test), mirroring the
first StringRegion mixed-use policy.

This is deliberately narrower than general escape analysis: no
interprocedural propagation (a Block passed through another function and
proven not to escape there is out of scope), no "used once" restriction
(multiple direct calls of the same binding are fine, §6), and no attempt at
general higher-order reasoning.

## 4. Internal representation

There is no new runtime object and no new semantic HIR node. The facts live
entirely in the analysis and in lowering state:

- `hir::blockescape::analyze` returns `{virtual wants}`: `virtual` is
  `InstanceId -> BindingId -> calleeInstanceId`; `wants` is the set of
  callee instances some binding demands an internal variant for.
- During lowering, a virtualized binding's local value is
  `{virtualblock calleeInstance captures}` (`native::lower::Bind`), where
  `captures` is the list of *already-evaluated registers* — exactly the
  same `Access`-driven evaluation `Closure` performs for a real closure's
  environment (`CaptureValues`, factored out so both share one code path).
  This is the closest thing to the milestone's own `VirtualBlock
  {implementation, captures, origin}` sketch: `calleeInstance` is the
  implementation identity, `captures` the capture values, and the binding
  and its `bind`/`block` HIR expressions are the provenance (still
  reachable from `fn locals`/HIR for diagnostics).
- `Call`'s `VirtualBlockCall` intercepts a direct call of such a binding
  before the callee expression is ever evaluated (there is no Block value
  to evaluate to) and calls the callee's internal variant directly.

## 5. Internal calling convention

`InternalFunction` lowers the *same instance and body* as the callee's
ordinary (`Function`) lowering, except:

- `env=0` in the NIR header (no environment argument at all).
- The capture bindings (`native::lower::captureLists`, the same list
  `Closure` already computes) become ordinary trailing parameters, appended
  after the block's own declared parameters — pre-populated into `fn
  locals` before the body is lowered, so `Access` finds them there directly
  and never emits a `capture I` load.
- Everything else — guards, known-error checks, GC rooting, completion-code
  handling, the raw/tagged representation machinery — is *exactly* the same
  `Function` code path, unmodified, because Cranelift and the runtime see an
  entirely ordinary function (no `env=1`, no `results=`).

A direct call site (`VirtualBlockCall`) evaluates the ordinary call
arguments, appends the recorded capture registers, and emits one plain
`call InternalVariantId arg... capture...` — never a code-pointer load out
of a Block (there is no Block), and the captures are invisible ABI details
never exposed to Botlish source (canonical Block signatures are unchanged).

The internal variant is built at most once per callee instance (via the
existing `pending`/`Placeholder` work-list, the same mechanism
`CompanionFunction`/`RegionCompanionFunction` already use) and shared by
every call site that demands it — `blockescape-multi-call-1` and
`blockescape-conditional-1` confirm multiple/conditional direct calls of
the same binding share one internal variant with zero Block allocations.

## 6. Canonical fallback behavior

The callee's ordinary, closure-taking function is still lowered exactly as
before whenever anything actually needs it: `hir::blockescape.tcl` declines
outright (never partially virtualizes) any binding with an escaping use,
and a *different* binding of the same source block that does escape (a
`return`, a stored reference, an argument to open code) still builds a real
heap closure and dispatches through the ordinary `closure`/`callenv`
machinery, completely unaffected by this analysis (`blockescape-escaping-
return-1`, `blockescape-stored-1`, `blockescape-open-call-1`).

One consequence worth naming: if literally *every* reference to a captured
block's binding is virtualized, nothing ever calls `FunctionRef` for its
canonical (closure-taking) function, so — consistent with the existing
"only instances lowered code refers to are emitted" architecture — that
canonical function is not emitted into NIR at all (confirmed by
`sum-refined`'s own NIR: only `step`'s internal variant, `params=2 env=0`,
appears — see §8's NIR dump). This is intended: nothing needs the canonical
closure form there. `tests/native.test`'s `native-call-6` needed one added
escaping reference to keep testing what it originally intended (§2).

## 7. Zero-capture Blocks (item 17)

Already optimal before this change: `native::lower::Closure` has always
special-cased `envless` blocks to a constant `fnvalue` plus a plain `call`,
with zero allocation. `hir::blockescape.tcl` explicitly excludes `envless`
blocks from its candidate set — nothing for it to add — and
`blockescape-zero-capture-1` confirms zero Block allocations either way.

## 8. `sum-refined.ir`: before/after evidence

### Allocation counts (`native::allocationReport`, `sum(400, 0)`)

| | Block allocations | total allocations | total bytes | GC cycles |
|---|---|---|---|---|
| before (`-block-escape-opt 0`) | 400 | 400 | 19.2 KB | 0 |
| after (default) | **0** | **0** | **0 B** | 0 |

(GC cycles are 0 in both cases at this scale — 19.2 KB never crosses the
heap's collection threshold — so this benchmark alone does not exercise a
GC-time improvement; see the GC-stress test in §"unsupported patterns" for
the correctness side of GC interaction instead.)

### In-process timing (`botlish-native bench 200`, best/median of 200 runs,
compile/JIT excluded, same methodology as NATIVE-AUDIT.md §1)

| | best | median |
|---|---|---|
| before | 20.90us | 21.92us |
| after | **1.71us** | **1.71us** |

≈12.2x (best) / 12.8x (median) faster. `fib(18)` and `drive(500,0)`, which
build no closures, are unaffected by the flag (measured both ways; the ~1-3%
run-to-run difference is ordinary noise, not attributable to this change):

| | before best/median | after best/median |
|---|---|---|
| `fib(18)` | 51.73us / 56.14us | 44.40us / 52.92us |
| `drive(500,0)` | 4.18us / 4.19us | 4.03us / 4.04us |

### Scaling (`sum(n, 0)`, Block allocations and best time)

| n | Block allocations | best time |
|---|---|---|
| 100 | 0 | 0.41us |
| 400 | 0 | 1.71us |
| 1000 | 0 | 3.86us |
| 5000 | 0 | 19.15us |

Zero Block allocations at every size; time scales linearly with `n` (no
allocation-driven step function), correct output at every size
(5050/80200/500500/12502500 respectively, the Gauss-sum closed forms).

### NIR before/after

Before (`-block-escape-opt 0`, abbreviated):
```
func 2 "step" params=1 env=1 regs=3 pnames="x" captures=1 instance="generic" @e14
    ...
    %2 = capture 0              ; load n out of the closure environment
    %3 = op iadd %0 %2 @e15
    ret %3
end
```
and in `sum`: `%c = closure step_id %n_reg @e16` (an `rt_closure_new` call,
via one capture-array stack slot) then `%r = callenv step_id %c %acc @e25`.

After (default; this is the literal NIR `sum-refined.ir` lowers to today):
```
func 1 "sum" params=2 env=0 regs=12 pnames="n acc" captures=0 instance="int, int" rawregs="5 9" @e2
    ...
  label L4
    %8 = int 1 @e24
    %9 = rawint 1
    %10 = op isub %0 %8 @e21
    %11 = call 2 %1 %0 @e25      ; direct call: step_internal(acc, n) -- no closure, no callenv
    tail %10 %11 @e19
  ...
end

func 2 "step" params=2 env=0 regs=3 pnames="x n" captures=0 instance="generic" @e14
    guard int %0 "+" @e15        ; x's kind guard: unchanged (see §9)
    %2 = op iadd %0 %1 @e15      ; n arrives as an ordinary parameter register
    ret %2
end
```

`step`'s canonical (closure-taking, `env=1`) function is not emitted at all
(§6): nothing calls `FunctionRef` for it, since every reference to `step` is
virtualized.

### Annotated machine-code hot path

Before (`objdump -d`, canonical path — reproducing NATIVE-AUDIT.md's own
Appendix C in this environment):
```
 21a: lea    r8,[rsp]                 ; &capture array               [capture-array setup]
 221: mov    [rsp],rsi                ; store n as the one capture
 22a: mov    rdx,[rip+...]            ; step's code address
 236: mov    r9,[rip+...]             ; rt_closure_new
 240: call   r9                       ; REAL HEAP ALLOCATION, every iteration
 246: mov    [r12+0x40],rbx           ; root-store the new closure
 ...
 2a7: mov    rdx,r15 ; mov rsi,rbx ; mov rdi,r13
 2b0: call   step                     ; callenv: passes the closure as an argument
```
and, inside `step`'s own canonical body:
```
 3d3: mov    rax,[rsi+0x20]           ; load the closure's env record
 3d7: mov    rax,[rax]                ; load captured n out of it     [env load]
```

After (this branch's disassembly of `sum-refined.ir` as it stands today):
```
 19d: mov    QWORD PTR [r12+0x10],0x6      ; (unrelated: folded integer? bookkeeping)
 205: mov    QWORD PTR [r12+0x40],0x3
 20e: test   rbx,0x1                       ; n's tag check
 21b: sub    rcx,0x3 ; seto sil            ; checked n-1
 233: mov    edx,0x3 ; call r8              ; (slow-path fallback, not taken)
 24d: mov    rsi,r14 ; mov rdx,rbx         ; acc, n -- ordinary registers
 256: mov    rdi,r13
 259: call   259 <botlish_fn_1+0x176>      ; DIRECT call, step's internal variant
 25e: test   rax,rax ; jne 28c             ; error-sentinel check (unchanged, see §9)
```
and `step`'s entire compiled body (`botlish_fn_2`, 41 bytes of real logic):
```
0000000000000325 <botlish_fn_2>:            ; rdi=vm, rsi=x, rdx=n -- ordinary params
 336: mov  rbx,[rdi] ; ... (shadow-frame bump, unrelated)
 36f: mov  ecx,0x1                          ; x's guard: tag bit / kind-byte / full compare
 374: test rsi,0x1 ; jne 399                ;   (3-tier check, unchanged from before)
 399: test cl,cl ; jne 3d3
 3d3: mov  rax,rsi ; and rax,rdx ; test rax,0x1 ; je 3fd   ; x+n tag check
 3e8: lea  rcx,[rdx-0x1] ; add rax,rcx ; seto cl            ; checked add
 409: mov  [rbx+0x10],rax ; ret
```
No `lea r8,[rsp]`/capture-array store, no `rt_closure_new` call, no
`[rsi+0x20]`-then-deref environment load anywhere in this function. Object
code size: `sum` 693B -> 581B (-16%), `step` 347B -> 319B (-8%).

## 9. Interaction with specialization (item 18/19)

`step<generic>` **remains generic** after this change — the `guard int %0
"+" @e15` check on `x` is still there in the internal variant, exactly as
before (`aot-spec.txt`: `step<generic>: guarded [UnknownParameterKind 2]`,
unchanged). This is because `hir::specialize::analyze` runs *before*
`hir::blockescape::analyze` and chooses instances purely from a block's own
declared-parameter types at its call sites; it never looks at capture kinds
at all (its own header rule, quoted in NATIVE-AUDIT.md's F2: "closures over
captured values stay generic"). Making captures explicit internal-call
arguments does not, by itself, feed anything into that decision — the
internal variant is a *lowering-time* artifact built after specialization
has already run and already fixed `step`'s one (generic) instance.

Reaching a specialized `step<int,int>` (using `sum<int,int>`'s own proven
`acc:int` and `n:int`) would require teaching `hir::specialize.tcl` to key
a block's instance on its *captures'* kinds too, not just its parameters' —
a real extension of that module's instantiation model, not something the
existing machinery already does when asked differently. That is explicitly
out of this milestone's stated scope ("do not create a second
specialization system"; "prefer reusing current instance/companion
concepts rather than mutating canonical HIR semantics"), so it was not
attempted here. **Nothing specialization-relevant improved naturally** —
this is worth stating plainly rather than implying a benefit that did not
materialize (see Q3/Q10 below).

## 10. Unsupported Block patterns (documented, not attempted)

- **Recursive Blocks** (`blockescape-recursive-1`): a block that captures
  itself (directly calls its own binding from inside its own body) is
  declined via the `NeedsSelf` check — there is no environment argument in
  the internal-variant ABI for "self" to mean anything. Still correct (it
  falls back to the canonical closure path, or, if it captures nothing
  else, the pre-existing `envless` self-tail-call path — no closure of any
  kind, since a purely self-referential block needs no environment at all).
- **Forward-reference (cell) captures**: a block capturing a binding
  `hir::aot::context` marks as needing a cell (mutual/forward recursion) is
  declined (`NeedsCell`) — such a capture is the cell's own reference, not
  an ordinary resolved value, and handling it correctly was judged out of
  scope for this first, conservative implementation.
- **Mixed direct-call + escaping use** (`blockescape-stored-1`,
  `blockescape-open-call-1`): declined entirely, never partially
  virtualized — mirrors the first StringRegion mixed-use policy.
- **Interprocedural propagation**: a Block passed through another (possibly
  closed) function and proven not to escape there is out of scope; passing
  a Block as an argument at all is treated as escaping.

## 11. Feature flag

`-block-escape-opt 1|0` / `BOTLISH_NATIVE_BLOCK_ESCAPE_OPT=0` (independent
of `-escape-opt`, matching the milestone's preference for independently
toggleable flags for clearer differential testing) — default on. Every new
test differentially compares both settings for value parity; the full
existing Tcl test suite (40 files) and `cargo test --release` both pass
unchanged with the flag at its default.

## 12. GC/rooting behavior

No new mechanism. A captured value that used to live in a closure's
environment array is now an ordinary NIR register — of the internal
variant's own parameter, in exactly the representation any other parameter
has — so it is rooted by the existing per-register shadow-stack discipline
(`codegen/clif.rs`'s `def`, unconditional on every register definition,
completely unaware of whether a register happens to be a former capture).
`blockescape-gc-stress-1` exercises this directly: a captured `String` is
carried across a self-tail loop and an allocating `concat` call under
`BOTLISH_NATIVE_GC_STRESS=1` (forces a GC attempt at every allocation site)
for 2000 iterations, and produces the correct result with no crash — i.e.
the captured value survives every stress-forced collection while live.

## Answers to the audit's questions

1. **Did the Block object disappear entirely from the optimized path?**
   Yes. Zero `rt_closure_new` calls, zero Block allocations, and `step`'s
   canonical (closure-taking) function is not even emitted into NIR, since
   nothing references it (§6, §8).
2. **Are captures now ordinary internal values?** Yes: `n` arrives in
   `step`'s internal variant as parameter register `%1`, in exactly the
   same representation any other parameter has, rooted by the same
   unconditional per-register shadow-stack mechanism (§5, §12).
3. **Did `step` become more specialized using existing machinery?** No.
   `step<generic>` is unchanged (still one guard on `x`'s kind) — see §9 for
   exactly why, and why fixing that is out of this milestone's scope.
4. **Which generic guards disappeared naturally?** None beyond what was
   already gone before this change (the `integer? acc` check was already
   folded/removed by Cranelift's own optimizer per NATIVE-AUDIT.md's F4).
   `step`'s own `x` guard (its only one) is unchanged, per Q3.
5. **Is the remaining direct call itself now a meaningful cost?** It is the
   dominant *remaining* cost (an ordinary non-inlined call: prologue,
   parameter guard, checked add, epilogue — §8's "after" disassembly is
   `step`'s entire body, 41 bytes of logic), but it is now comparable in
   kind to `fib`'s or `loop-count`'s ordinary call overhead, not a
   qualitatively different heap-allocation cost. No inlining was attempted
   (out of scope, item 57) or observed to happen on its own.
6. **How much of `sum-refined`'s previous runtime was attributable to
   closure allocation vs. the remaining arithmetic/call/rooting work?**
   About 92%: 20.90us before, 1.71us after (§8) — the remaining ~1.71us is
   the arithmetic, the direct call, the shadow-stack rooting, and the tag
   checks, none of which this milestone touched.
7. **Did any escaping Block unexpectedly block optimization?** No — every
   synthetic test with a genuinely escaping Block (`blockescape-escaping-
   return-1`, `blockescape-stored-1`, `blockescape-open-call-1`) behaves
   exactly as the analysis's stated criteria predict; nothing was
   surprising during implementation once the "any escaping use declines the
   whole binding" rule (§3, §6) was applied consistently.
8. **Did any GC/lifetime issue arise with captured managed values?** No —
   the GC-stress test (§12) passed on the first correctly-scoped
   implementation, because captures were always ordinary already-rooted
   values (`Access`'s existing per-register mechanism), never a new kind of
   reference needing new rooting logic.
9. **Does the mechanism generalize cleanly to multiple direct calls?** Yes,
   with no extra mechanism: the internal variant is built once per callee
   instance (the same `pending`/`Placeholder` machinery
   `CompanionFunction` already uses) and every direct-call site simply
   calls it (`blockescape-multi-call-1`, `blockescape-conditional-1`).
10. **What exact evidence remains for F2 as the next optimization target?**
    Exactly the same evidence NATIVE-AUDIT.md already gave, undiminished:
    `step`'s parameter `x` still carries no static kind (`aot-spec.txt`:
    `UnknownParameterKind`), and reaching one would need `hir/range.tcl`'s
    `RefBinding` to stop requiring `kind eq "local"` and/or
    `hir/induction.tcl`'s guard-scanning to look past a non-terminating
    sibling `if` — neither of which this milestone touched, per its own
    explicit scope limits (item 19). This milestone's captures-as-arguments
    change does not, on its own, change that picture (§9): F2 is still a
    fully open, separately valuable next step.
