# Raw result of a fallible function: what it costs, and why (future work)

**Status: future work for an experimental register allocator.** Nothing
here is to be changed in the current stack. The RawInt ABI for
de-closured functions (GENERIC-PREDICATE-PROOF-LOSS.md, loss point 5) does
what the compiler can do at the NIR level; the remaining loss is in register
allocation inside Cranelift, below everything the compiler controls.

## The question

Loss point 5 gave `refined-checks`' `scan_while<int, native(is_tcl_alpha)>`
a raw parameter and a raw result, and the function got slower: 99 → 108
Ir/call. GENERIC-PREDICATE-PROOF-LOSS.md ("Loss point 5", limitation 1)
attributes this to "a `mov` per iteration, plus the success flag". This
note splits the 9 instructions between the return convention itself and
register allocation, from the executed machine code.

## The return conventions

`native/src/codegen/clif.rs` (`physical_results`, `:133`; the status word,
`:375`) and `native/src/nir.rs` (`raw_result`, `:686`):

| result | registers | error |
|---|---|---|
| tagged, function may fail | `rax` = tagged value | `rax` = 0 (the tagged ABI's error sentinel) |
| raw, function may fail | `rax` = raw value, `rdx` = status word | status 0; nonzero = success |
| raw, function cannot fail | `rax` = raw value | — |

A raw integer has no spare value to mean "error", so a fallible function
needs a second word. `scan_while` is fallible: its loop calls `char_at`
(`substring`) and the predicate, both of which can fail.

## Measurement

`main` at `092537b`, `bench/refined-checks.bot`, NIR emitted with
`native::lower::rawInternalAbiOpt` 0 and 1 (point 5 off and on, point 4
on in both), profiled with
`audit/post-r2a-dynamic-census/tools/profile-nir.sh` (audit binary rebuilt
from that commit, 21 runs, run 0 excluded; per-instruction counts from its
`instr.txt`). Whole program: 5,346,740 → 5,345,918 Ir/run (−0.02%).

`scan_while<int, native(is_tcl_alpha)>` runs 400 times per run; per call,
its loop header executes 4 times and its body 3 times. Execution counts
below are per run.

Point 5 off (tagged result), 99.0 Ir/call:

```
  400  prologue: push rbp / mov rbp,rsp / sub rsp,0x50 / save rbx r12 r13 r14 r15
  400  mov r15,r8
  400  mov [rsp+0x10],rdi
  400  sar rsi,1                 untag start
  400  mov r12,rcx
  400  sar r12,1                 untag n (the loop bound)
  400  mov r14,rcx               keep tagged n for the exhaustion return
  400  mov rbx,rsi
1,600  cmp rbx,r12               loop header: i < n
1,600  jl  body
  400  mov rax,r14               return tagged n
  400  epilogue (9 instructions)
1,200  body: retag i, call char_at, test, call is_tcl_alpha, test,
       bool test, add rbx,0x1, jmp   (22 instructions)
```

Point 5 on (raw result + status word), 108.0 Ir/call:

```
  400  prologue: push rbp / mov rbp,rsp / sub rsp,0x30 / save rbx r12 r13 r14
  400  mov rbx,r8
  400  mov r12,rdi
  400  mov rax,rcx
  400  sar rax,1                 untag n (start arrives raw)
  400  mov r13,rax
  400  mov rax,rsi
  400  mov rcx,r13
1,600  cmp rax,rcx               loop header: i < n
1,600  mov r13,rcx               <- new: copy of the bound, every test
1,600  jl  body
  400  mov edx,0x1               <- new: the status word
  400  mov rax,r13               return raw n
  400  epilogue (8 instructions)
1,200  body: as above (24 instructions), plus
1,200  mov r14,rax               <- new: save i (now in rax) across the calls
1,200  mov rax,r14               <- new: restore it
1,200  mov rcx,r13               <- new: bound back into rcx for the back edge
       and minus one move when retagging i for char_at; one stack load of
       rdi becomes a register move
```

### Where the 9 instructions per call go

| part | Δ Ir/call | what |
|---|---:|---|
| status word | **+1** | `mov edx,1` on the success return: the only instruction the two-word convention adds |
| loop header (4×/call) | +4 | `mov r13,rcx`, a copy of the raw bound on every test |
| loop body (3×/call) | +6 | 2 net per iteration (22 → 24): the counter now lives in `rax` and is saved/restored around the calls, and the bound is copied back into `rcx` on the back edge (+3); retagging the counter takes one move fewer (−1) |
| frame | −2 | one fewer callee-saved register to save and restore |
| entry | 0 | no untag of the raw start, but more register shuffling |
| **total** | **+9** | 99 → 108 |

The caller pays nothing extra for the status word. `tld?` (31 → 29
Ir/call) checks for an error with `test rdx,rdx` / `jne` on the status word
instead of `test rax,rax` / `jne` on the tagged value, the same two
instructions; it saves the untag (`sar`) of the result and of its own raw
argument.

Compared with a raw result of a function that **cannot** fail, the status
convention costs 1 instruction in the callee (`mov edx,1`) plus the
caller's 2-instruction check, which every call of a fallible function pays
anyway, tagged or raw. **The flag is 1 of the 9; the other 8 are register
allocation.**

## Why the register allocation gets worse (interpretation, not tested)

The exhaustion path returns `n`, which is also the loop bound.

* Point 5 off: the function returns a *tagged* `n`, a separate value
  (`r14`), so the raw bound stays in a callee-saved register (`r12`) for the
  whole loop, and the counter in `rbx`; nothing moves around the calls.
* Point 5 on: the *raw* `n` is both the loop bound and the return value, and
  the loop counter flows into the same return path. Cranelift's allocator
  (regalloc2) then keeps the loop-carried bound and counter in `rcx`/`rax`,
  the registers the return and the calls use. Both are caller-saved, so each
  iteration copies them around the two calls and back for the next test.

This reading comes from the listings above; it was not confirmed by an
experiment (for example returning a fresh copy of `n` from the exit block,
or a variant that cannot fail).

## Why this is future work for a register allocator, not for this stack

* NIR already says the right thing: `n` is unboxed once, the loop compares
  and advances raw, the result is returned raw. The extra moves are
  Cranelift's placement of live ranges across calls, which NIR does not
  control.
* Working around it in lowering would mean emitting deliberately redundant
  NIR (a second copy of `n` for the return, say) and hoping the allocator
  splits the live ranges differently: fragile, allocator-version-specific,
  and for 8 Ir/call on 400 calls per run. Loss point 5's net effect on
  `refined-checks` is already −0.01%; the stack has done what it can here.
* A register allocator that splits live ranges at call boundaries with
  call-clobber costs in mind (keeping a loop-carried value in a
  callee-saved register even though it is also a return value) would remove
  the 8 instructions without any change to NIR, and would help every raw
  loop that calls out and returns its bound or counter, not only this one.

What an experimental allocator should be measured on:

* `scan_while<int, native(is_tcl_alpha)>` in `refined-checks`: target 99 →
  ~100 Ir/call with point 5 on (the status word remains).
* Every fallible raw-result function with a loop-carried value that is
  also returned, and every raw loop whose body contains calls.
* Reproduce with: `native::lower::rawInternalAbiOpt` 0 vs 1 on
  `bench/refined-checks.bot`, `profile-nir.sh` on both NIRs, and compare
  the `[15 scan_while` lines of each `instr.txt` (the function index may
  change if the program changes).

Not addressed here, and separate: the RawInt plan still has no cost model
for a raw result (GENERIC-PREDICATE-PROOF-LOSS.md, "Next steps"); with a
better allocator such a model would mostly need to price the status word.
