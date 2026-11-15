# The C backend's machine code against Cranelift, Rust and Go

This report compares the x86-64 machine code that five toolchains make of
the three benchmarks the C backend (`main.tcl -emit-c`,
C-COMPILE-FREESTANDING-MILESTONE-1.md) compiles today:
[`bench/fib.bot`](../bench/fib.bot),
[`bench/loop-count.bot`](../bench/loop-count.bot) and
[`bench/experimental/loop-count-fold.bot`](../bench/experimental/loop-count-fold.bot).
It sets the code each one makes beside its time and its exact instruction
count. The five are the generated C built by gcc and by clang, the native
backend (Cranelift), and `bench.tcl`'s Rust and Go reference programs. It
is diagnostic only: nothing in the compiler changed. Everything was
measured on 2026-11-15 at main's bcbc157f, on one shared Linux x86-64
container.

None of the other five standard benchmarks compiles to C yet, and neither
do the other three experimental ones. Each stops at a deliberate
`C UNSUPPORTED`: Strings, Lists of unknown length, functions used as
values, closures, ImmutableSet, `integer?`, and context structs that own
affine state.

## 1. Outcome

* **The C backend's code runs about twice as fast as Cranelift's on all
  three programs** (table 1). On `fib` it is behind Rust: 1.2x Rust's time
  with gcc, 1.6x with clang. On the two loop-count programs it runs at
  Rust's speed.
* **Both Botlish backends work from the same proofs.** `hir::range` proves
  that `fib`'s arithmetic fits 64 bits. So the C backend writes plain
  `int64_t` arithmetic, and native lowering writes raw NIR arithmetic
  (`riadd`, `risub`, `rilt`), neither with a tag or an overflow check. In
  loop-count, neither backend can bound the running total, so both keep it
  as an arbitrary-precision Int with an inline fast path. Every difference
  below is code generation, not knowledge.
* **The C backend's `fib` pays for its calling convention.** Every
  generated function returns a status and writes its result through a
  pointer (C-COMPILE-FREESTANDING-MILESTONE-1.md, section 4), so every call
  goes through memory. Rewriting `fib` by hand to return its `int64_t`
  halves the C time (section 4.5): gcc from 57 to 27 µs, faster than
  Rust's 47 µs; clang from about 78 to 32-39 µs. Clang then emits Rust's
  machine code for `fib` instruction for instruction. This is the largest
  single lever this comparison found.
* **Cranelift's code is held back by its calling convention and by what
  it does not do.**
  - Every call passes the Vm pointer.
  - Every call, base cases included, saves and restores three callee-saved
    registers in a frame-pointer frame.
  - Nothing is inlined, and no recursion is transformed.
  - In loop-count it keeps a call whose result it already knows, writes
    two GC root slots on every iteration whether or not the slow path
    runs, and tests overflow in three instructions where one would do.

  BENCHMARK-BIMODALITY.md found the same against Go and its instruction
  totals match these exactly (1,404,172 and 12,031).
* **The loop-count programs are too small for 8 and 11 instructions per
  iteration to differ in time.** Every C and Rust variant runs in about
  0.26 µs, half a nanosecond per iteration; Cranelift's 24 to 27 take
  about twice as long. At this size the instruction count is the better
  comparison.

## 2. Method

**Programs.** The C is `main.tcl -emit-c` output, unmodified (the opaque
check below aside). Cranelift's code is what `bench.tcl` runs: JIT code
compiled from the program's NIR. The Rust and Go programs are
`bench/equivalents/{rust,go}/{fib,loop_count}.*`, built as `bench.tcl`
builds them (`rustc -O --edition 2021`; `go build` with the shared timing
loop in `bench/equivalents/go/clock/`). `loop-count-fold` is a variant of
`loop-count`, so its Rust and Go columns are loop-count's programs.

**Toolchains.**

| toolchain | version | flags |
|---|---|---|
| gcc | Ubuntu 13.3.0-6ubuntu2~24.04.1 | `-O2` and the strict flags of `tests/c-compile.test`; Ubuntu's defaults add `-fstack-protector-strong` and `-fcf-protection=full` |
| clang | Ubuntu 18.1.3 | `-O2` and the same strict flags |
| Cranelift | 0.135.2, `native/` at bcbc157f | the JIT's ISA (the host's CPU features, not position-independent) |
| rustc | 1.100.0 (the pinned toolchain) | `-O --edition 2021` |
| go | 1.24.7 | `go build` |

**Timing.** Each cell is a single call, the best of 2000, the range over
three rounds. Cranelift, Rust and Go came from `bench.tcl -runs 2000
-budget 0 -columns "native rust go"`. `bench.tcl` has no C column, so the
C programs ran in a harness with the same protocol (section 7): one
untimed `PREFIX_run` call, then timed calls, best reported. The machine is
a shared 4-core VM reported as "Intel Xeon Processor @ 2.10GHz" (AVX-512
and AMX, a Sapphire Rapids-class part) running Linux 6.18. Its times
scatter by up to 20% between rounds (Cranelift's `fib`: 104-125 µs).

**Instruction counts** are exact and do not scatter. They come from
valgrind 3.22's callgrind, as the inclusive cost of the call edge into the
benchmarked function, divided by its call count:

* `main` to `PREFIX_run` (C);
* `main` to `fib::fib` and to `loop_count::drive` (Rust);
* the timed closure to `main.fib` and to `main.drive` (Go);
* the driver's timed loop to the JIT's entry address (Cranelift).

The Go, clang and Cranelift `fib` totals and the Go `drive` total were
checked against a hand count of each listing. Per call of `fib`:

| toolchain | non-base call | base call | total per run |
|---|---:|---:|---|
| Cranelift | 30 | 19 | 28,656 × 30 + 28,657 × 19 + 9 = 1,404,172 |
| clang | 22 | 11 | 28,656 × 22 + 28,657 × 11 + 12 = 945,671 |
| Go | 19 | 10 | 28,656 × 19 + 28,657 × 10 = 831,034 |

Go's `drive` is 18 instructions per level of recursion and 11 at the
bottom: 500 × 18 + 11 = 9,011.

**Cranelift's code** was taken from the JIT itself: gdb stopped the driver
at the `mprotect` that makes its code executable and dumped the region
(section 7). The `object` command emits the same functions, from the same
NIR, with the target's baseline ISA and position-independent code. The
two listings agree instruction for instruction, except that the JIT calls
a runtime helper as `movabs rax, ADDRESS; call rax` where the object calls
it directly. Only the never-taken `rt_int_add` slow path calls one here.
The listings below are the object's, in Intel syntax.

**Constant inputs.** The C program has its inputs (22, 500) written into
its code, while the Rust and Go programs read theirs from the command line
behind `black_box`. A copy of each generated C file whose program function
reads them from `volatile` globals instead timed the same, and the
listings show no precomputed result. gcc's `loop_count_run` keeps its 500
iterations (`mov ebx, 0x1f4`).

## 3. Results

Table 1: per run (one call of the program), best of 2000.

| program | | C (gcc) | C (clang) | Cranelift | Rust | Go |
|---|---|---:|---:|---:|---:|---:|
| `fib` | time (µs) | 57-64 | 76-81 | 104-125 | 47-48 | 71-80 |
| | instructions | 949,567 | 945,671 | 1,404,172 | 562,187 | 831,034 |
| | calls of `fib` | 25,871 | 57,313 | 57,313 | 28,657 | 57,313 |
| `loop-count` | time (µs) | 0.26-0.28 | 0.25-0.26 | 0.55-0.58 | 0.27-0.30 | 0.87-0.91 |
| | instructions | 5,026 | 5,522 | 12,031 | 4,016 | 9,011 |
| | per iteration | 10 | 11 | 24 | 8 | 18 (a frame each) |
| `loop-count-fold` | time (µs) | 0.26-0.27 | 0.24-0.27 | 0.64-0.65 | (0.26-0.33) | (0.89-0.93) |
| | instructions | 4,026 | 4,522 | 13,526 | (4,016) | (9,011) |
| | per iteration | 8 | 9 | 27 | (8) | (18) |

Parenthesized cells are loop-count's programs (`bench-variant-of`). Every
cell produced the expected value (17711, 3500, 3500).

## 4. fib

`fib(n)` is the naive doubly recursive Fibonacci, run on n = 22: 57,313
calls when every call is real, 28,656 of them non-base.

### 4.1 What both Botlish backends know

The `int` instance of `fib` is proven raw. NIR has `rawparams="0"
rawresult=1`, and its arithmetic is `rilt`, `risub` and `riadd`, which
native lowering emits only on a range proof (`native/lower.tcl`'s
`rawEligible`). The C backend makes the same decision from the same proof
(C-COMPILE-FREESTANDING-MILESTONE-1.md, section 8): `n` and the result
are `int64_t`, the sum is `(r2 + r4)`, and the program needs no runtime
service (`fib.runtime.json`: none). Neither backend's code has a tag, a
boxing step or an overflow check in `fib`.

### 4.2 The C backend: a status and an out-pointer per call

The generated function:

```c
static fib_status fib_1_fib(int64_t p_n_2, int64_t *out)
{
    int64_t j1 = 0;
    if (p_n_2 < INT64_C(2)) {
        j1 = p_n_2;
    } else {
        int64_t r2;
        fib_status st3 = fib_1_fib((p_n_2 - INT64_C(1)), &r2);
        if (st3 != fib_OK) {
            return st3;
        }
        int64_t r4;
        fib_status st5 = fib_1_fib((p_n_2 - INT64_C(2)), &r4);
        if (st5 != fib_OK) {
            return st5;
        }
        j1 = (r2 + r4);
    }
    *out = j1;
    return fib_OK;
}
```

`fib` cannot fail, but its result still makes a round trip through memory
on every call. The caller passes a stack slot's address, the callee stores
into it, and the caller loads it back after the return. The load waits for
the store, on the path from one call's result to its caller's sum.

clang (22 instructions per non-base call, 11 per base call) proves that
`fib_1_fib` always returns `fib_OK` and deletes every status test. It
keeps the store and the two loads:

```
fib_1_fib:
  push r14; push rbx; sub rsp,0x18
  mov rbx,rsi                     ; out
  cmp rdi,0x2; jl base
  lea rax,[rdi-0x1]; lea rsi,[rsp+0x10]; mov r14,rdi; mov rdi,rax
  call fib_1_fib                  ; fib(n-1) -> [rsp+0x10]
  add r14,-2; lea rsi,[rsp+0x8]; mov rdi,r14
  call fib_1_fib                  ; fib(n-2) -> [rsp+0x8]
  mov rdi,[rsp+0x8]; add rdi,[rsp+0x10]
base:
  mov [rbx],rdi                   ; *out = ...
  add rsp,0x18; pop rbx; pop r14; ret
```

gcc keeps a `test eax,eax; jne` after every call. It also inlines
`fib_1_fib` into itself: its listing has six recursive calls, of n-3 and
n-4, and special cases for n <= 1, n = 2 and n = 3. That cuts the calls to
25,871 per run (gcc's `fib_run` starts the unrolling at 18 and 17) and is
why gcc is faster than clang with the same instruction count. Ubuntu's
`-fstack-protector-strong` adds a canary to every call, because every
call takes a local's address. That costs 155,240 instructions per run (a
build without it: 794,327) and no measurable time (49-56 µs against
51-57 µs in the same rounds). The canary is the embedder's build choice,
not the backend's.

### 4.3 Cranelift: 30 instructions per non-base call

```
botlish_fn_1:                     ; fib
  push rbp; mov rbp,rsp; sub rsp,0x20
  mov [rsp],r12; mov [rsp+0x8],r13; mov [rsp+0x10],r15   ; saved on every call
  mov r13,rdi                     ; the Vm pointer
  cmp rsi,0x2; mov r12,rsi; jl base
  mov rax,r12; mov rsi,rax; sub rsi,0x1; mov rdi,r13
  call botlish_fn_1
  mov rsi,r12; mov r15,rax; sub rsi,0x2; mov rdi,r13
  call botlish_fn_1
  mov rcx,r15; add rax,rcx
  jmp done
base:
  mov rsi,r12; mov rax,rsi
done:
  mov r12,[rsp]; mov r13,[rsp+0x8]; mov r15,[rsp+0x10]
  add rsp,0x20; mov rsp,rbp; pop rbp; ret
```

The result comes back in `rax`, so there is no memory round trip, but:

* every call passes the Vm pointer in `rdi`;
* the prologue saves three callee-saved registers before the `n < 2` test
  (Cranelift does not shrink-wrap), so the 28,657 base calls pay for six
  memory operations they do not need;
* the frame pointer is kept on every call (the frame walker needs it);
* the register allocator adds two moves (`mov rax,r12; mov rsi,rax`,
  `mov rcx,r15; add rax,rcx`) and a `jmp` into the shared epilogue.

That is 30 instructions per non-base call and 19 per base call.
BENCHMARK-BIMODALITY.md's `fib` section reads the same listing against
Go's and counts 25 per non-base call. Counting every instruction on the
path, prologue to `ret`, gives 30, and only the full count reproduces the
measured total.

### 4.4 Rust and Go

Rust (LLVM) turns the second recursive call into a loop that accumulates
into `rbx`, so it makes one call per level: 28,657 calls, 562,187
instructions. The result is in `rax`, and the frame is three pushes:

```
fib::fib:
  push r14; push rbx; push rax
  xor ebx,ebx; cmp rdi,0x2; jl done
loop:
  mov r14,rdi; dec rdi
  call fib::fib                   ; fib(n-1)
  lea rdi,[r14-0x2]; add rbx,rax  ; continue with n-2
  cmp r14,0x3; ja loop
done:
  add rbx,rdi; mov rax,rbx
  add rsp,0x8; pop rbx; pop r14; ret
```

Go transforms nothing (57,313 calls). Its register ABI has no
callee-saved registers, so a base case is 10 instructions: the stack-bound
check (`cmp rsp,[r14+0x10]; jbe`), the frame and the test. A non-base
call spills `n` once around the first recursive call: 19 instructions.

### 4.5 Experiment: the C function returning its value

`fib.c` was edited by hand so that `fib_1_fib` is `static int64_t
fib_1_fib(int64_t p_n_2)`, returning `(r2 + r4)` with no status. The
program function's call became `*out = fib_1_fib(INT64_C(22));`. Nothing
else changed; this is not generated code.

Table 2: `fib`, generated against hand-edited C; three rounds, best of
2000.

| build | time (µs) | instructions per run | calls of `fib` per run |
|---|---:|---:|---:|
| gcc, generated | 51-57 | 949,567 | 25,871 |
| gcc, generated, `-fno-stack-protector` | 49-56 | 794,327 | 25,871 |
| gcc, direct return | 25-27 | 553,376 | 3,034 |
| clang, generated | 66-80 | 945,671 | 57,313 |
| clang, direct return | 32-39 | 579,906 | 28,657 |
| Rust (for reference) | 47-48 | 562,187 | 28,657 |

With the value in `rax`, clang's `fib_1_fib` is Rust's `fib::fib`: the
same three-push frame, the same loop for the second call, the same 28,657
calls, with `lea rdi,[r14-0x1]` where Rust has `dec rdi`. gcc unrolls the
recursion further, down to 3,034 calls, and beats Rust. So the gap
between the C backend and Rust on `fib` is entirely the status and
out-pointer convention. A function whose C translation has no failure
path does not need it: clang deduced that from the generated C itself.

## 5. loop-count and loop-count-fold

`work(i)` is a `loop:` computing `a = i * 3` and `b = a + 7`, returning
`b - a` once `b >= 0`. `drive` adds `work(i)` for i = 500 down to 1:
`loop-count` by a self tail call, `loop-count-fold` by a fold
(FOLD-LOOPS-MILESTONE-1.md) over the same values.

### 5.1 What each front end and compiler removed

* **Botlish's front end** proves that `work`'s loop leaves on its first
  iteration, and knows the call's result is 7. Native lowering uses both:
  `work`'s NIR has no loop, and `drive`'s adds the constant
  (`%11 = int 7`, `%13 = op iadd %1 %11`). But it still calls `work` and
  drops the result (`%10 = call 1 %0`). Cranelift simplifies `work` to
  `mov eax,0xf` (a tagged 7) and keeps the call.
* **The C backend** emits `work` with its loop and adds `work`'s result
  `r1`, not the constant. gcc and clang inline `work` and fold the loop
  and its result to 7 (`mov edx,0x7`, `add rdi,0x7`). The fold relies on
  C's rule that signed arithmetic does not overflow. Here that rule states
  a proven fact: the backend writes signed C arithmetic only where
  `hir::range` proves it cannot overflow.
* **Rust** keeps the 500 calls of `work`. In a release build `i * 3`
  wraps, so `b >= 0` can fail and `work` might never return. LLVM computes
  the total in closed form after the loop (`lea rbx,[rbx+r14*8]; sub
  rbx,r14`: total + 7n). Since nothing reads `work`'s result, `work` only
  tests the sign of `3i + 7`: `lea rax,[rdi+rdi*2]; add rax,7; js spin;
  ret`.
* **Go** inlines `work`, keeping its loop's test (`LEAQ`, `LEAQ 7`,
  `TESTQ`, `JL`), but has no tail calls. Its `drive` is 500 real frames,
  each with a stack-bound check: 18 instructions per level.

### 5.2 Two representations of an unbounded Int

The total has no range bound in either backend.

* **C** holds it as `botlish_rt_v1_int {int64_t small; void *big;}`
  (`botlish_rt_v1.h`). The fast path tests `big == NULL` and
  `small <= INT64_MAX - 7` (`movabs rbp,0x7ffffffffffffff8` hoisted out
  of the loop), then adds 7. Otherwise it calls the
  `botlish_rt_v1_int_add` service, which the manifest lists with
  `int.to_decimal`.
* **Cranelift** holds a tagged word: a small Int is `2v + 1`. The fast
  path tests the tag bit, adds 14 and tests overflow; otherwise it calls
  `rt_int_add`.

### 5.3 The loops, one iteration's path

gcc, `loop-count` (10 instructions; the struct `n3` is stored because the
slow path passes its address):

```
.next:  sub rbx,1; je .done
        test rsi,rsi; jne .slow        ; big != NULL
        cmp rdi,rbp; jle .fast         ; small <= INT64_MAX - 7
.fast:  mov QWORD PTR [rsp+0x8],0      ; n3.big = NULL
        add rdi,7
        mov [rsp],rdi                  ; n3.small
        jmp .next
```

gcc, `loop-count-fold` (8 instructions): the same tests and add with no
stores. The fold's `for` loop keeps the accumulator in registers.

clang, `loop-count` (11, the same two stores); clang, `loop-count-fold`
(9, no stores).

Cranelift, `loop-count` (24, the call to `work` included):

```
loop:   test r15,r15; jle done
        mov rsi,r15; mov rdi,rbx
        call botlish_fn_1              ; work: push rbp; mov rbp,rsp; mov eax,0xf; mov rsp,rbp; pop rbp; ret
        mov QWORD PTR [rsp+0x8],0xf    ; root slot: the constant 7
        mov rsi,r12
        test rsi,1; je slow            ; tag
        mov rax,rsi; add rax,0xe       ; + tagged 7
        seto cl; test cl,cl; je fast   ; overflow
slow:   mov edx,0xf; mov rdi,rbx; call rt_int_add
fast:   mov [rsp],rax                  ; root slot: the total
        sub r15,1; mov r12,rax
        jmp loop
```

The CLIF shows where the two stores come from. The slow-path call is
`call fn1(v0, v23, v21), stack_map=[i64 @ ss0+0, i64 @ ss0+8]`, so both
of its operands live in GC root slots. Both are written on the fast path,
before the tag test decides whether that call runs. One of the two values
is the constant 15, written on every iteration. The overflow test is
`sadd_overflow` followed by a `brif` on its flag, which Cranelift 0.135.2
lowers to `seto; test; je` rather than `jo`. `work`'s call, the stores and
the `seto` round trip are about 13 of the 24 instructions.

Cranelift, `loop-count-fold` (27): the same work, plus two
register-shuffling moves and a `jmp` around the join of the fold's carried
value. That is 12% more instructions than the tail-call form, the gap
`loop-count-fold.bot`'s header tracks.

Rust (8: `mov rdi,r15; call work` (4 inside), `sub r15,1; ja`) and Go
(18 per frame, section 5.1) complete the table.

### 5.4 Instructions against time

At about half a nanosecond per iteration, 8, 9, 10 and 11 instructions
take the same time on this machine (0.24-0.33 µs for 500 iterations), and
Rust's call per iteration costs nothing visible either. Cranelift's 24
and 27 take about 1.1-1.3 ns per iteration, and Go's frames 1.8 ns.
These loops are short and carry one dependency each, so their times say
little beyond that ordering. The instruction counts are the stable
measure.

## 6. Follow-ups (not done here)

**C backend.** The finding with a measurement behind it: a function whose
C translation has no failure path could return its value directly, with
the status kept for functions that can fail (declared errors, runtime
services, run-time checks). On `fib` that is a 2x speedup with both
compilers, putting the C backend at or ahead of Rust. It changes neither
the backend's rule that errors are statuses, nor the program-level entry
points (`PREFIX_run` and the manifest): only the signatures of the
program's internal functions would change.

**Cranelift.** BENCHMARK-BIMODALITY.md names the calling-convention costs
(the Vm pointer, unconditional callee-saved spills, register-allocator
moves) and the dead call of a function whose value is known. This report
adds two smaller items from loop-count:

* the root-slot stores of the slow path's operands sit on the fast path;
* the overflow branch is `seto; test; jcc` where a `jo` would do.

**Build flags.** An embedder building the generated C with Ubuntu's gcc
gets `-fstack-protector-strong`'s canary in every function that takes a
local's address, which is every function that calls another. Here it cost
16% of `fib`'s instructions and no measurable time.

## 7. Reproducing

```bash
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
OUT=$(mktemp -d)

# The C programs, and the Cranelift, Rust and Go columns.
for p in fib loop-count; do tclsh9.0 main.tcl -emit-c -out "$OUT/$p" bench/$p.bot; done
mkdir -p "$OUT/stage" && cp bench/experimental/loop-count-fold.bot "$OUT/stage/"
(cd "$OUT/stage" && tclsh9.0 "$OLDPWD/main.tcl" -emit-c -out "$OUT/loop-count-fold" loop-count-fold.bot)
tclsh9.0 bench/bench.tcl -runs 2000 -budget 0 -columns "native rust go" \
    bench/fib.bot bench/loop-count.bot bench/experimental/loop-count-fold.bot
```

The C timing harness, `bench_main.c` (`bench.tcl`'s reference-program
protocol: an untimed call, then `--runs N` timed calls, the best
printed):

```c
#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include BOTLISH_PROGRAM_HEADER
#define CAT2(a, b) a##b
#define CAT(a, b) CAT2(a, b)
#define P(name) CAT(BOTLISH_PROGRAM, name)

static double now_us(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1e6 + (double)ts.tv_nsec / 1e3;
}

int main(int argc, char **argv)
{
    long runs = 5;
    P(_value) value;
    double best = -1.0;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--runs") == 0 && i + 1 < argc) {
            runs = strtol(argv[++i], NULL, 10);
        }
    }
    if (P(_run)(&value) != P(_OK)) {
        return 1;
    }
    for (long r = 0; r < runs; r++) {
        double t0 = now_us();
        P(_status) status = P(_run)(&value);
        double us = now_us() - t0;
        if (status != P(_OK)) {
            return 1;
        }
        if (best < 0 || us < best) {
            best = us;
        }
    }
    size_t length = P(_show)(&value, NULL, 0);
    char *text = malloc(length + 1);
    if (text == NULL) {
        return 2;
    }
    P(_show)(&value, text, length);
    printf("value: %.*s\nbest_us: %.3f\n", (int)length, text, best);
    free(text);
    return 0;
}
```

Building and running one program (PREFIX `fib`, `loop_count` or
`loop_count_fold`, its directory under `$OUT`):

```bash
STRICT="-std=c11 -pedantic-errors -Wall -Wextra -Werror -Wshadow -Wstrict-prototypes
  -Wmissing-prototypes -Wconversion -Wsign-conversion -Wcast-qual -Wundef"
for cc in gcc clang; do
  $cc $STRICT -O2 -DBOTLISH_PROGRAM=fib '-DBOTLISH_PROGRAM_HEADER="fib.h"' -I "$OUT/fib" \
      -c "$OUT/fib/fib.c" -o "$OUT/fib.$cc.o"
  $cc -O2 -DBOTLISH_PROGRAM=fib '-DBOTLISH_PROGRAM_HEADER="fib.h"' -I "$OUT/fib" -I ccompile \
      bench_main.c "$OUT/fib.$cc.o" "$OUT/fib/fib_display.c" \
      examples/c-freestanding/providers/botlish_rt_v1_int_arena.c -o "$OUT/fib.$cc"
  "$OUT/fib.$cc" --runs 2000
done
objdump -d -M intel --no-show-raw-insn "$OUT/fib.gcc.o"
```

Cranelift's object, NIR and pre-regalloc VCode (`cranelift.tcl ROOT OUT
FILE.bot ...`, run from the checkout):

```tcl
lassign $argv root out
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
foreach file [lrange $argv 2 end] {
    set name [file rootname [file tail $file]]
    set hir [surface::readProgramFile $file -warnings off]
    set f [open [file join $out $name.nir] w]; puts $f [native::nir $hir]; close $f
    native::object $hir [file join $out $name.o]
    set f [open [file join $out $name.vcode] w]; puts $f [native::vcode $hir]; close $f
}
```

`native/target/release/botlish-native clif FILE.nir` prints the CLIF.
The JIT's own code, dumped by gdb (`jitdump.py`; run `gdb -q -batch -x
jitdump.py --args native/target/release/botlish-native run FILE.nir`,
then `objdump -D -b binary -m i386:x86-64 -M intel jit-0.bin`):

```python
import gdb
gdb.execute("set pagination off")
gdb.execute("catch syscall mprotect")
gdb.execute("run")
n, pending = 0, None
while True:
    try:
        gdb.selected_frame()
    except gdb.error:
        break
    rdi = int(gdb.parse_and_eval("$rdi")) & 0xffffffffffffffff
    rsi = int(gdb.parse_and_eval("$rsi"))
    rdx = int(gdb.parse_and_eval("$rdx"))
    if rdx & 4 and pending is None:          # entering mprotect(..., PROT_EXEC)
        pending = (rdi, rsi)
    elif pending is not None:                # returning from it
        addr, size = pending
        pending = None
        gdb.execute("dump binary memory jit-%d.bin %d %d" % (n, addr, addr + size))
        n += 1
    try:
        gdb.execute("continue")
    except gdb.error:
        break
```

Instruction counts, for example gcc's `fib` and the JIT's:

```bash
valgrind --tool=callgrind --callgrind-out-file=c.out "$OUT/fib.gcc" --runs 10
callgrind_annotate --inclusive=yes --tree=calling --threshold=100 c.out | grep '> .*fib_run ('
valgrind --tool=callgrind --callgrind-out-file=jit.out \
    native/target/release/botlish-native bench 10 FILE.nir
callgrind_annotate --inclusive=yes --tree=calling --threshold=100 jit.out | grep -m1 '(10x)'
```

Rust and Go: `rustc -O --edition 2021 bench/equivalents/rust/fib.rs`;
for Go, copy `bench/equivalents/go/fib.go`, `clock/best.go` and
`clock/clock_other.go` into one directory and `go build -o fib fib.go
best.go clock_other.go`. Their listings are `objdump -d -M intel -C`
(`fib::fib`, `loop_count::work`, `loop_count::drive`) and `go tool
objdump -s 'main\.(fib|drive)$'`.
