# BENCHMARK-BIMODALITY.md

Audit only: no compiler, runtime or library change. Tools and the variant
programs are in [`audit/bench-bimodality/`](../audit/bench-bimodality/README.md).

The question: on `bench/bench.tcl`'s ten programs the native (Cranelift)
column is either close to Go -- once ahead of it -- or close to Python,
rarely in between. Why, benchmark by benchmark, in terms of the language
features each program uses, the ones added since it was written that it does
not use, and the ones that are missing, followed from source through HIR,
NIR and CLIF to machine code? The Tcl backends are left out. The native AOT
executables are compared where they can be built.

## Outcome

**The split is mechanical. It is decided by whether the hot loop's
operations lower to machine instructions or to calls of runtime helpers.**
Native lowering turns Ints, comparisons, branches, direct calls, self tail
calls, struct projections and MutableArray slots into inline machine code. On
those, Botlish is within 1.4x of Go and beats it where a self tail call
becomes a jump. Every operation on a String, a List, a construction plan, an
ImmutableSet, a MutableVector, a callable value or an untyped equality is an
out-of-line call of a generic Rust helper, and many of them allocate a
`malloc`ed object: 24 instructions for a MutableVector read, 300-650 for a
one-character String or an append. That is what an interpreter pays per
operation too, so where those operations dominate, Botlish lands next to
CPython, whose own string and list operations are C code with a small-object
allocator and cached one-character strings.

One number sorts the corpus: the share of a run's executed instructions that
are in generated code (callgrind, one timed run, below).

| program | generated code | Botlish / Go | Python / Botlish | position (0 = Go, 1 = Python) |
|---|---:|---:|---:|---:|
| loop-count | 100% | 0.66 | 112 | -0.10 |
| sum-refined | 100% | 0.92 | 115 | -0.02 |
| fib | 100% | 1.41 | 16.1 | 0.11 |
| refined-checks | 17% | 2.65 | 4.6 | 0.39 |
| test-selection | 19% | 2.62 | 4.4 | 0.39 |
| json-parse | 17% | 11.1 | 5.0 | 0.60 |
| game-server | 35% | 5.26 | 2.1 | 0.69 |
| uri-steady | 12% | 11.2 | 1.2 | 0.93 |
| lex-strategy | 10% | 14.2 | 0.99 | 1.00 |
| source-checks | 12% | 13.7 | 0.85 | 1.07 |

*Position* is `ln(Botlish/Go) / ln(Python/Go)`: where Botlish sits on the
log scale between the Go and the Python reference program (CI's numbers give
the same clusters, two neighbours swapped within each; Measurements). The
three programs at 100% are integer and call code, and they sit at Go. Every
other program spends 65-90% of its instructions outside generated code. Its
ratio to Go is then roughly the ratio of a helper call to the Go operation
it replaces.

Each slow program has one or two identifiable dominant costs. Several are
language-design choices, not code-generation quality. Removing one per
program in source alone, with the value unchanged, measured
(`audit/bench-bimodality/variants/`):

| program | the one change | native time | Go |
|---|---|---:|---:|
| game-server | one `continue` in `simdrv::release_due` (the function's last loop stops collecting a List no caller reads) | 2209 -> 1299 us (-41%) | 418 us |
| json-parse | the document's one literal `é` made `e` (every chunk ASCII: `char_at` stops decoding from byte 0) | 314 -> 74 us (-76%) | 29 us |
| lex-strategy | walk the token by index instead of materializing a List of one-character Strings | 24 -> 12.5 us (-48%) | 1.7 us |
| refined-checks | an ASCII email of the same length | 372 -> 327 us (-12%) | 140 us |
| uri-steady | escaping with `std::str::char_at`, `append_char` and character literals | 1824 -> 1835 us (no change) | 169 us |
| lex-strategy, source-checks | declared parameter types (no generic, guarded instance; lex-strategy becomes AOT-ready) | no change | |

The AOT executables run the same Cranelift code as the JIT and measure the
same, at parity to 10% slower (AOT, below). Two programs cannot be built as
executables at all: lex-strategy and source-checks have *generic*,
kind-guarded instances, which a closed program refuses.

## Measurements

### Method

* **Timings**: `tclsh9.0 bench/bench.tcl -runs 20 -budget 30 -columns
  "native python rust go"` on this container (Linux x86-64, 4 cores, Tcl
  9.0.1, rustc 1.97.0, Go 1.24.7, Python 3.13.17), best of 20, JIT
  compilation excluded (native::measure), and CI's `bench (linux-x86_64)`
  job of run 40829546108 (commit 02d765b9, the first run with every reference
  program), best of 5. The two agree within runner noise; the position
  column uses the local ones.
* **AOT**: each program's standalone executable (`native::executable`, the
  rustc linker), run with `BOTLISH_NATIVE_RESULT=FILE BOTLISH_NATIVE_RUNS=20`.
  That is the driver protocol of `native/src/runtime/aot.rs`. The executable
  then times its own runs, as `botlish-native bench` does, best of 20.
* **Where the instructions go**: callgrind. For an executable, collection is
  toggled on only inside `botlish_fn_0`, the program function the timed
  runs call (`--toggle-collect=botlish_fn_0`), so startup and the untimed
  `Vm::reset` between runs are out. For the two JIT-only programs it is
  toggled on the JIT entry's address. For game-server, whose coroutine stack
  switches confuse callgrind's toggle, the profile is the difference of a 2-
  and a 12-run profile. Categories: *generated* (Botlish functions),
  *helpers* (the `rt_*` runtime and its callees), *allocator* (glibc
  `malloc`/`free` and the runtime's allocation wrappers), *mem\** (`memcpy`
  and friends). `audit/bench-bimodality/tools/profile.sh` reproduces them
  (difference mode only).
* **Per-operation costs**: callgrind's inclusive cost of a helper divided by
  its call count.
* **IR**: `native::nir`, `native::fusedNir`, `native::clif`, `native::object`
  plus `objdump -d`, `hir::format` (dumps regenerated by
  `audit/bench-bimodality/README.md`'s commands).

### Timings (microseconds, best run)

| program | written | native (local) | native AOT (local) | Go | Rust | Python | native (CI) | Go (CI) | Python (CI) |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| fib | 09-13 | 111.9 | 120.6 | 79.6 | 46.3 | 1,800 | 141.9 | 102.9 | 2,100 |
| loop-count | 09-13 | 0.59 | 0.59 | 0.89 | 0.28 | 66.3 | 1.25 | 1.12 | 112.5 |
| sum-refined | 09-13 | 0.65 | 0.56 | 0.71 | 0.59 | 75.0 | 1.01 | 0.77 | 135.1 |
| refined-checks | 09-13 | 371.1 | 361.4 | 139.9 | 108.6 | 1,700 | 477.1 | 169.3 | 2,100 |
| test-selection | 09-28 | 2.73 | 2.90 | 1.04 | 1.79 | 12.1 | 3.44 | 1.30 | 24.5 |
| uri-steady | 09-25 | 1,900 | 1,957 | 169.1 | 97.6 | 2,300 | 2,000 | 202.2 | 3,300 |
| lex-strategy | 09-28 | 24.7 | not AOT-ready | 1.74 | 1.94 | 24.6 | 29.1 | 1.70 | 39.9 |
| source-checks | 09-28 | 8.93 | not AOT-ready | 0.65 | 0.45 | 7.58 | 9.13 | 0.81 | 11.3 |
| game-server | 10-29 | 2,200 | 2,405 | 417.9 | 121.6 | 4,600 | 2,400 | 408.9 | 4,800 |
| json-parse | 10-29 | 319.3 | 302.6 | 28.8 | 17.1 | 1,600 | 435.0 | 37.4 | 1,200 |

"Written" is the date the program entered `bench/`: the four oldest as
`bench/*.ir`, migrated to `.bot` by CANONICAL-SURFACE-BENCHMARKS.md. The
experimental two (bench/experimental/) were added on 10-29, over modules
of 10-27 and 10-28.

### Where the instructions go (one timed run)

| program | instructions | generated | helpers | allocator | mem* | dominant helpers |
|---|---:|---:|---:|---:|---:|---|
| fib | 1,404,172 | 100% | 0 | 0 | 0 | -- |
| loop-count | 12,031 | 100% | 0 | 0 | 0 | -- |
| sum-refined | 12,429 | 100% | 0 | 0 | 0 | -- |
| test-selection | 38,738 | 19% | 54% | 24% | 3% | `kind_of` 20%, `equal` 11%, `rt_set_contains` 6% |
| refined-checks | 5,410,734 | 17% | 55% | 25% | 3% | String allocation path 35%, `kind_of`+`equal` 16% |
| json-parse | 6,082,417 | 17% | 83% | 0 | 0 | `char_at_index` 80% |
| game-server | 25,957,084 | 35% | 47% | 9% | 8% | `rt_construct` 31%, `rt_mv_*` 15% |
| uri-steady | 23,975,288 | 12% | 53% | 22% | 14% | `rt_construct` 46% |
| source-checks | 93,378 | 12% | 57% | 22% | 9% | `rt_construct` 31% |
| lex-strategy | 310,555 | 10% | 50% | 31% | 9% | `rt_construct` 32% |

The collector itself is under 1% everywhere. A collection runs only after
1 MB of allocation (`native/src/runtime/heap.rs`), and the heap is released
between runs, untimed. What allocation costs is `malloc` and `free` per
object. Nothing has a nursery or bump allocation, so short-lived garbage is
not reused until a collection, and only `malloc` reuses it then.

### What one operation costs (instructions per call, inclusive)

| operation (helper) | cost | measured in | what Go does instead |
|---|---:|---|---|
| a one-character String, `s.substring(i, i + 1)` materialized (`rt_substr_proven`) | 318-357 | lex-strategy, refined-checks | a `rune`, a register |
| one construction-plan step: a List or String append (`rt_construct`) | 489-660 | lex-strategy, uri-steady, game-server | `append`: amortized store into a slice / Builder |
| a call through a callable value (`rt_call_value`: kind dispatch, arity, the native's kind checks, `apply_op`) | 172, the callee's own work included | lex-strategy | an indirect call |
| `std::str::is_tcl_alnum` on a one-character String (`rt_is_tcl_alnum`) | 53 | lex-strategy, refined-checks | `unicode.IsLetter` (an inline ASCII fast path) |
| ImmutableSet membership (`rt_set_contains`: a linear scan, type-blind `equal` per element) | 264 (2 elements) - 857 (5) | test-selection, refined-checks | a map probe |
| `std::str::char_at` in ASCII text (`rt_str_char_at_proven`) | 74-116 | uri-steady, refined-checks | `s[i]` |
| `std::str::char_at` in non-ASCII text (decodes from byte 0) | 1,222 on average | json-parse | `for _, r := range s` |
| `std::mutable_vector::at` (`rt_mv_at`) | 24 | game-server | a bounds check and a load |
| `push` / `swap` on a MutableVector | 63-96 / 64 | game-server, json-parse | a store |

Everything in this table is a call. No helper is inlined into generated code,
and the AOT link cannot change that: the runtime is a separately compiled Rust
library and nothing performs cross-language LTO.

## The two regimes, from the compiler's side

**What becomes machine code.** The HIR front end specializes every function
per call-site argument types (`instance="int, int"` in NIR). Range analysis
proves Int ranges, and an Int whose range fits 64 bits is a *raw* register
(`rawint`, `riadd`, `rilt`: RAW-INT-ABI.md) with no tag and no overflow
check. Other Ints are tagged words (`2n + 1`), added with a tag test and
`seto` and a call to the BigInt slow path that never runs here. Comparisons
in an `if` lower as branches (BRANCH-FORM-BOOLEAN-LOWERING.md; Cranelift folds
the residual `select 6, 2` / `icmp eq 6` pair into one `cmp`/`jcc`). A call
of a known function is a direct `call`, and a call in tail position of itself
is a jump (NIR `tail`). An exact callable passed as a value becomes a direct
call in the instance that receives it (`call 12` for `scan_while`'s
predicate in refined-checks; `callenv 5` for test-selection's `changed?`). A
closure whose environment is known is lambda-lifted: sum-refined's `step`
takes `n` as a parameter and allocates nothing. Struct field projection and
MutableArray `at`/`set` are loads and stores.

**What stays a call.** Every value of a heap type is a pointer to an
individually `malloc`ed object (STRING-ALLOCATION.md's one-block String,
List, ImmutableSet, MutableVector header plus `Rc<VecDeque>` backing,
construction plans). Every operation on one is an `extern "C"` helper taking
the Vm pointer: `substrproven`, `strtclalnum`, `setcontains`, `mvat`,
`construct list plan`, `callvalue`. Building a String or List in a loop or a
recursion uses a *construction plan*
(M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md), which makes accumulation linear
instead of quadratic. Each step is still one generic `rt_construct` call
that decodes a tagged piece array from a stack slot, updates the metrics
counters, and grows a `Vec`. Around every call that may allocate, live GC
references are stored to stack-map slots (NATIVE-STACK-MAPS.md). A value
whose kind the specializer cannot know runs in a *generic* instance with
`guard` kind checks, and a call through a value of a joined callable kind
goes through `rt_call_value`.

**Why that lands at Python.** CPython executes each of these operations as
a bytecode dispatch plus a C call on a heap object. That is the same order of
work: a few hundred instructions. In integer code CPython also pays boxing
and dispatch per `n - 1`, while Botlish pays one instruction. Hence two
clusters 15-100x apart (fib, loop-count, sum-refined) and a cluster at parity
(the rest). CPython even has a few advantages Botlish lacks: one-character
Latin-1 strings are cached singletons (lex-strategy's and source-checks'
characters allocate nothing in Python), `pymalloc` is a small-object
allocator, and reference counting reuses a freed block immediately.

## The programs

### loop-count: ahead of Go (0.66x)

*Source.* `work(i)` is a `loop:` computing `a = i * 3`, `b = a + 7` and
returning `b - a`. `drive(i, total)` recurses 500 times, adding `work(i)`.

*HIR to NIR.* Range analysis proves `work`'s loop leaves on its first
iteration (M6-RANGE-DECIDED-BRANCH-LOWERING.md), and the exact-value facts
know the call's result is 7. `drive`'s NIR keeps the call but adds the
constant: `%10 = call 1 %0` (result unused) and `%13 = op iadd %1 %11`
with `%11 = int 7`. The recursion is `tail %9 %13`, a jump. `work` is raw
arithmetic (`rimul`, `riadd`, `risub`), and Cranelift's mid-end simplifies
`(3i + 7) - 3i` to 7.

*Machine code.* `work` is `push rbp; mov rbp,rsp; mov eax,0xf; ...; ret`
(0xf is the tagged 7). `drive` is a loop: `test`/`jle`, a `call` to that
function, the tagged add of 7 (`add rax,0xe; seto cl`, with a never-taken
slow-path call), `sub r15,1`, `jmp` back. That is about 24 instructions per
iteration, 12,031 per run.

*Against Go.* Go inlines `work` and folds `b - a` to `ADDQ $7`, but keeps the
loop's exit test (`LEAQ (AX)(AX*2)`, `TESTQ`, `JLT`). More importantly, it
recurses: `drive` is 500 real frames, each with a stack-bound check, a frame
and a `CALL`. Botlish's self tail call is a jump. That alone accounts for the
lead. Go is better at inlining, and Botlish keeps a dead call of a function
whose result it already knows.

*Features.* Used: recursion, `loop` with `return`, range-decided branches,
raw Ints. Added since and unused: counted loops (`loop i from 1 to 501`) and
MutableArray as an accumulator. Neither would help here: the header's "the
language has no mutation" is out of date, but the recursion compiles to the
loop anyway. Missing: dead-call elimination of a pure call whose value is
known, and inlining of a known-constant function. Both are worth a few
instructions per iteration.

### sum-refined: at Go (0.92x)

*HIR.* In the `(int, int)` instance `integer?(acc)` is decided true and the
`else` branch is dead. The closure `step` captures `n`. *NIR.* `step` is a
function with two parameters (`x n`), called directly: `call 2 %1 %11`, no
closure object. `n == 0` is a raw compare, and the recursion is `tail`. The
accumulator's range is not bounded, so `acc + n` is a tagged add with an
overflow check. 12,429 instructions per run, all generated.

*Against Go.* The same shape as loop-count: Go inlines the closure but
recurses 400 frames deep, Botlish loops. Rust is at 0.59 us.

*Features.* Added since and unused: declared errors and `fail`
(ERROR-PAYLOADS.md). The header explains that the dead branch returns the
sentinel -1 because no error could be raised from source when the program
was migrated; a `fail` would state the intent and cost nothing (the branch
is dead). Nothing missing for its speed.

### fib: near Go (1.41x)

*HIR to NIR.* The `int` instance proves `n` and the result raw (`rawparams`,
`rawresult`): `rilt`, `risub`, `riadd`, no tag or overflow work at all.

*Machine code* (25 instructions per non-base call):

```
push rbp; mov rbp,rsp; sub rsp,0x20
mov [rsp],r12; mov [rsp+8],r13; mov [rsp+0x10],r15   ; spills before the test
mov r13,rdi                                           ; the Vm pointer, every call
cmp rsi,2; mov r12,rsi; jl base
mov rax,r12; mov rsi,rax; sub rsi,1; mov rdi,r13; call fib
mov rsi,r12; mov r15,rax; sub rsi,2; mov rdi,r13; call fib
mov rcx,r15; add rax,rcx; ...restore r12,r13,r15; ret
```

Go's `fib` checks the stack bound and sets up its frame, but saves no
register before comparing `n < 2`. Half of all calls are base cases, which
return in 10 instructions in Go and 19 in Botlish. Go's register ABI has no
callee-saved registers, so it spills `n` once around the first call.
Botlish's prologue saves three callee-saved registers unconditionally
(Cranelift has no shrink-wrapping) and restores them on every return, and
it threads the Vm pointer in `rdi` through every call. The allocator adds two redundant
moves. The 1.4x is calling convention and register allocation, not language
semantics. Rust (LLVM) is at 46 us. Nothing to add at the language level.

### refined-checks: in between (2.65x Go)

*Source.* 800 calls of `check`: `std::web::emailish?(s)` on the Unicode
email or `"not-an-email"`, a second `emailish?(s)` on the same path, and
`std::web::uri_query_value?(q)` on the 400 true paths.

*HIR.* The second `emailish?` is decided, not run. The function is proven
repeatable (hir/repeatable.tcl), so the program does half the email work the
Go port does: Go runs `emailish` twice. `scan_while`'s predicate parameter
`Fn{args: [str], return: bool}` has exact targets, so after specialization
`scan_while` calls `local_char?` directly (`call 12`). Nothing in this program
is a generic instance or a callable-value call.

*NIR.* Per character of the email: `char_at(i)` is `substrproven`, a
materialized one-character String (6,800 per run, 357 instructions each). It
must be a String because the value crosses calls typed `str`: `local_char?`,
`std::str::is_tcl_alnum` and `std::str::is_tcl_alpha` take one-scalar Strings.
Then `strtclalnum`, which decodes it again and looks up its Unicode category
(53 instructions), and for the local part's punctuation `setcontainstotal` on
`local_extra_chars`, a five-element ImmutableSet scanned with type-blind
`equal` (857 instructions per lookup). `char_is?` uses `strcharatproven`
plus `chareq`, no allocation, because `std::str::char_at` (10-06) returns a
`UnicodeChar`.

*Profile.* 5.4M instructions per run: 17% generated, 35% the
one-character-String path (`substr_range`, `alloc_str`, `new_str_pieces`,
`malloc`), 16% `kind_of` and `equal`, 4% `char_at_index`. The ASCII variant
saves 12%, the seeks. The rest is objects per character. Go converts to
`[]rune` once per call (on the stack, for a string this short) and
classifies runes in registers, so a Go `emailish` call costs about a fifth
of a Botlish one even though Go makes twice as many.

*History.* POST-M8A-COMMON-INEFFICIENCY-CENSUS.md measured this program at
20 allocations per run, none in the hot loop, and 33.5% generated code (66%
in string-region helpers); it found no one-character producer Strings in any
canonical hot path. Today it is 6,815 allocations per run and 17%
generated. Since that census `emailish?` became an ordinary source
predicate with a typed `Fn{args: [str]}` parameter (REFINEMENT-VALUES.md,
10-06). The characters it reads now cross typed call boundaries as Strings.
I did not bisect the change. It is the likeliest place the regions were
lost.

*Features.* Used: refinement predicates, repeatability, structural function
types, ImmutableSet, counted loops. Added since and unused: `std::str::char_at`
for the classified characters, which the classifiers cannot take: they need
`str`; MutableSet (ORDERED-MUTABLE-MAP-SET.md), a keyed hash table, pointless
for five one-character elements. Missing: Unicode classification of a
`UnicodeChar` (`is_tcl_alnum(c)` on a char is a TYPE error). With it, the scan
would allocate nothing. Also a character cursor, and a small-set membership
that is not a type-blind scan.

### test-selection: in between (2.62x Go)

*NIR.* Mostly as Go would do it: `Test` field projections are loads, the
predicate closures are direct `callenv` calls to known code, and
`select_affected` is a list plan. Each run builds the 14 `Test` structs and
their Lists (`structnew` 305, `listnew` 316 instructions) and two closures
with their sets. `changed?`'s membership is `setcontains` (a typed set's is
`setcontainstotal`, which only drops the error edge: both call
`rt_set_contains`): 55 lookups per run, each a linear scan calling `equal`,
which calls `kind_of` on both operands of every comparison. That is 31% of
the run.

*Against Go.* Go builds the same data per run, but its allocator's fast path
is a few instructions (per-size-class spans, no `free`), escape analysis
keeps some of it on the stack, and its `map[string]struct{}` lookups are
hashed. 38,738 instructions per run, 19% generated, 24% allocator. Nothing
here is per-character, which is why it stays in the middle.

*Features.* Added since and unused: MutableSet with the keyed hash, which
for one- and two-element sets would cost more than the scan. Missing: an
ImmutableSet membership that compares by the element type (a String compare,
not `equal`'s kind dispatch), and a bump allocator or nursery, the cost
behind every `structnew`.

### json-parse: closer to Python (11.1x Go), and only because of one character

*Source.* The newest program: declared DFA recognizers
(DFA-COROUTINE-MILESTONE-2.md), lowered before HIR to coroutines over a
constant transition table. A `scalars` coroutine feeds Unicode scalar values,
a `structure` coroutine checks the grammar, and a MutableArray `cursor` holds
the driver's four mutable variables.

*NIR.* Coroutine fusion (COROUTINE-FUSION-MILESTONE-1.md) inlines all three
coroutines into `validate_text`: no stack switch, no coroutine object. The
recognizers' transitions are `switch`/table loads. The generated code is
good, 14% of the run.

*The cost.* `scalars` reads `chunk.char_at(i)` for `i` from 0 to the chunk's
length. The chunk contains `é`, so the String is not ASCII and
`char_at_index` decodes UTF-8 from byte 0 to find character `i`
(`native/src/runtime/ops.rs`). That makes reading a chunk quadratic: 3,981
calls per run at 1,222 instructions each, 80% of the run. With the `é` made
`e`, the same document validates in 74 us instead of 314, 2.6x Go, which
moves the program into the middle cluster.

*Features.* Used: everything new: DFAs, coroutines and their fusion,
MutableArray, declared errors with payloads. Unused: `validate_bytes`
over `std::str::encode_utf8`'s bytes, which exists in json.bot. It cannot
be used from a typed program: `encode_utf8`'s result type is the raw kind
`list`, and neither a call site nor a declared `-> List[int]` result can prove
it `List[int]` ("function result does not prove declared type List[int]").
Missing: iterating a String (`loop c in s` is a TYPE error: "loop iterable:
expected list"), a character cursor or byte offset into a String, an O(1)
character index for non-ASCII Strings, and a precise type for `encode_utf8`.
Any of the first three removes the 80%; the fourth would let the program
validate bytes instead (a different count of symbols).

### game-server: closer to Python (5.3x Go), 41% of it from one loop's value

*Source.* The event-loop exploration's scheduler (audit/event-loop/src/,
10-28) over its simulated driver: contexts, coroutines, MutableVectors of
integer rows, MutableArrays as mutable variables.

*The cost.* `simdrv::release_due`'s body ends in `loop i from 0 to ...:`.
A loop is an expression whose value is the List of its bodies' last values,
so the function's result is that List: here a List of `unit`s, one element
per scripted record. NIR builds it with a plan step per iteration
(`construct list plan %11 elem %13`) and flattens it at the end. Its caller
`block_checked` discards it. That is 28,000 `rt_construct` calls per run and
38% of all instructions with their allocation and copying. The non-tail
`loop k from 1 to 5` inside it is a statement and builds nothing: only a
loop in result position collects. json.bot's `scalars` carries a `continue`
with a comment for exactly this reason. One `continue` at the end of
`release_due`'s body takes the program from 2,209 to 1,299 us. The value is
identical.

*What remains* (15.4M instructions per run, 55% generated): the linear scans
of the script that `release_due` and `next_due` do on every block. Go does
the same scans, and they are generated code. Then `rt_mv_at`, 15%: every
`s.script.at(i * 6 + 5)` is an out-of-line call (24 instructions; the
backing is a `VecDeque`), while Go indexes a slice of structs inline. The
index arithmetic `i * 6 + k` is tagged with overflow checks, because `i`'s
bound is a value read from a MutableArray, which range analysis cannot
know. Module constants (`c_now`, `c_scripted`) are loaded at run time
(`staticget`, then `mutarrayget`). Coroutine switching is 0.5%: two of seven
construction sites are fused, and the scheduler's tasks are not, because their
handles reach the scheduler, which fusion does not follow.

*Features.* Used: contexts, context traits, coroutines with deep yield,
MutableVector, MutableArray, counted loops, declared errors. Added since and
unused: the production `std::event_loop` (EVENT-LOOP-MILESTONE-1.md), since the
benchmark runs the exploration's prototype, and enums for the row kinds.
Missing: a non-collecting loop in result position, or not building a result
no caller reads (a function whose every call discards its value). Also
inline MutableVector access; vectors of records instead of `i * 6 + k`
integer rows; mutable local variables, for which the program uses one-slot
MutableArrays (`checksum`'s `h`, `periods_due`'s `hi`, json's `cursor`) with
`on IndexNotFound` handlers for indexes that cannot fail; and integer
division: `periods_due` computes `1 + (now - deadline) / period` by doubling
and binary search, cheap here because it is rare.

### uri-steady: at Python (11.2x Go)

*Source.* 2,000 calls of `std::web::uri_escape_text` on four short strings,
two of them non-ASCII.

*NIR.* `esc_from` is a self tail call (a loop) that extends a String plan
per character. For every escaped byte, `pct(b)` builds a plan from `"%"` and
`hex_pair(b)`, which builds a plan from two `hex_digits.at(...)` Strings.
Each plan is an object with a separate byte buffer (`calloc`), and each step
is one `rt_construct`: 30,505 per run at 646 instructions each, 82% of the
run with the allocation and copying under it (46% in `rt_construct` itself).
`std::web::is_unreserved` is an ASCII test plus membership in
`additional_unreserved_chars`, a four-byte ImmutableSet scanned per call
(363 instructions). Characters are read with `std::str::char_at` (since
10-06, no one-character String), but on the non-ASCII inputs each read seeks
from byte 0.

*Against Go.* One `strings.Builder` buffer per call, a byte table and a
`switch`: 85 ns a call against Botlish's 950.

*The variant.* Rewritten with `std::str::char_at`, `std::str::append_char`
(10-17), character literals for the hex digits, a counted loop and a
one-slot MutableArray accumulator, it is no faster (1,835 against 1,824 us).
There is no mutable string builder: every `append_char` of a String held in a
MutableArray slot copies the text so far. The plan machinery only applies
while the accumulator is a register. Missing: an in-place builder of a String,
or a String from a MutableVector of bytes or characters; byte-level reading
of a String; a hashed or bitset membership for a constant set of bytes.

### lex-strategy: at Python (14.2x Go)

*Source.* Classify each character of eight tokens with a classifier chosen
at an `if` join (`std::str::is_tcl_alnum`, a native, or `lenient_ident_char?`,
a Botlish function), count the `true`s, and find the fully alphanumeric
tokens. `chars_of` turns a String into a List of one-character Strings by
recursion and `std::list::append`, because, as its header says, the language
has no String-to-characters conversion.

*HIR.* `classifier` is a join of two callable kinds, so `classify` calls it
with `callvalue`. `lenient_ident_char?` has an undeclared parameter and is
reached only as a value, so its instance is *generic*: `guard str %0` before
`strtclalnum`. That also makes the program not AOT-ready ("parameter c (no
annotation, no call-site inference) has no static kind").

*NIR and CLIF* (`chars_of`, the self-tail-called instance; abridged):

```
v49 = call fn1(v0, v48, v40, v47)        ; rt_substr_proven: a new 1-char String
store v49, ss0+16                         ; GC root slot
store 0, ss2; store v51, ss2+8; store 2, ss2+16; store v49, ss2+24
v60 = call fn0(v0, 3, 4, ss2)             ; rt_construct: list plan, 4 words
```

Per character: one `malloc`ed String (318 instructions), one plan step to
collect it (489), a `rt_call_value` for the classifier (172, with an `Rc`
clone of the program info and the native's kind checks), the Unicode lookup
(53), and another plan step for `classify`'s collected `List[bool]`. The run
is 310,555 instructions, 10% generated, 31% allocator.

*Variants.* Declaring `c: str` on `lenient_ident_char?` removes the guard and
makes the program AOT-ready: 24 us, no change. The guards are not the cost.
Walking the token by index (`loop i from 0 to std::str::length(token)`,
counted loops since 09-27, the day before the benchmark) instead of building
`chars_of`'s List halves it, to 12.5 us. What remains is the one-character
Strings, the `callvalue` and the collected `List[bool]`.

*Against Python.* CPython's `list(token)` of ASCII or Latin-1 characters
allocates nothing per character (cached singletons), and `c.isalpha()` is a
C call. The two implementations do comparable work per character, and they
time the same.

*Features.* Added since and unused: `std::str::char_at` and character
literals. The classifier interface is `str`, so they cannot be used without
an `std::str::of_char` per character, another allocation. Also unused:
MutableVector, as a builder of the flags. Missing: Unicode classification of a `UnicodeChar`, String
iteration, a `filter`/`count` over a List (no `std::list::filter`; the
program collects and counts), and a non-allocating call through a joined
callable value.

### source-checks: at Python (13.7x Go)

The same mechanism on a smaller scale. A heterogeneous List of four
classifiers (`std::str::is_tcl_alpha`, `std::str::is_tcl_alnum` and two
Botlish functions) is applied to each candidate's first character with
`loop check in checks: check(c)`. Each of the four is a `callvalue` through
the List (the module binding is a capture of `classify_leading`). The loop's
value is a collected `List[bool]` (a plan step per check). The character is a
`substring(0, 1)` String. `classify_leading` is a generic instance, because
`invalid_name?` reaches it as `std::list::find`'s predicate, and the program
is not AOT-ready. Typing the five functions changes nothing (6.8 us). 93,378
instructions per run, 12% generated, `rt_construct` 31%. Python is as
fast: 7.6 against 8.9 us here, 11.3 against 9.1 on CI.

*Features.* As lex-strategy. Also missing: `std::list::filter`, which the
header notes. `invalid_names` is a collecting loop with `continue`, which is
already its linear form.

## AOT

Every program that can be built as a closed executable runs at the JIT's
speed or slightly below it. The code is the same Cranelift output; only the call of a runtime helper differs: a direct `call rel32`
(`R_X86_64_PLT32`, `direct_helpers`) instead of the JIT's `movabs` plus an
indirect call. Interleaved runs (three each, best of 20):

| program | JIT | AOT |
|---|---:|---:|
| fib | 100-116 us | 108-121 us |
| refined-checks | 333-366 us | 361-364 us |
| game-server | 2,100-2,171 us | 2,284-2,394 us |
| json-parse | 261-320 us | 286-393 us |

fib and game-server are reproducibly 5-10% slower as executables. Their
function entries are not aligned: in the AOT image functions follow one
another byte-packed (fib's `botlish_fn_1` is at the odd address `0xa072f`;
21 of game-server's 102 functions start on a 16-byte boundary). This is the
likely cause; I did not prove it. A glibc trim-threshold experiment changed
nothing. AOT cannot narrow the gap to Go, because the cost is in helpers the
generated code calls and no link step inlines them. lex-strategy and
source-checks are refused ("program is not AOT-ready") because of their
generic instances. With declared parameter types lex-strategy builds and
runs, at the same speed.

## The language features behind it

| feature | state | where it costs (measured) |
|---|---|---|
| raw Ints from range analysis; tail calls as jumps; exact callables; lambda-lifted closures; branch-form conditions | present, used | why fib, loop-count and sum-refined are at Go, and loop-count ahead |
| a loop is an expression that collects its bodies' values | present (design) | game-server: 41% of the run, a List nobody reads; json.bot's `scalars` ends its loop with `continue` to avoid it |
| String = UTF-8 with Unicode-scalar indexing, no index for non-ASCII text | present (representation) | json-parse: 76%; refined-checks: 12%; uri-steady: its non-ASCII inputs |
| Unicode classification takes a one-scalar `str`, not a `UnicodeChar` | present (API) | the 318-357-instruction String per classified character in refined-checks, lex-strategy, source-checks |
| iteration over a String's characters | **missing** | lex-strategy's `chars_of` List (48%), json-parse's `char_at` loop |
| a mutable String builder (or a String from bytes or characters) | **missing** | uri-steady: plan objects per escaped byte; the `append_char` rewrite copies the text per append |
| a precise result type for `std::str::encode_utf8` | **missing** | json-parse cannot use `validate_bytes` |
| inline fast paths for MutableVector, List and plan operations | missing (backend) | game-server: `rt_mv_at` 15%; every program's `rt_construct` |
| a nursery or bump allocator | missing (runtime) | 9-31% of every slow program in `malloc`/`free` |
| hashed or typed small-set membership for ImmutableSet | missing | test-selection 31%, refined-checks 16% (`kind_of`+`equal`) |
| a cheap call through a joined callable value | missing (backend) | lex-strategy, source-checks: 172 instructions per call |
| mutable local variables | missing | one-slot MutableArrays with impossible `IndexNotFound` handlers (game-server, json-parse) |
| integer division | missing | game-server's `periods_due` by doubling and search (cheap here) |
| `std::list::filter` / count | missing | lex-strategy, source-checks collect and then count |
| dead-call elimination / inlining of small known functions | missing (compiler) | loop-count keeps a call whose value it knows |
| declared parameter types (no generic instance) | present, unused by lex-strategy and source-checks | AOT readiness only: no speed change |
| `std::str::char_at`, `append_char`, character literals (10-06, 10-17) | present, unused by the 09-xx programs | usable only where nothing then needs a `str`; no gain without a builder |
| MutableVector, MutableArray, MutableMap/Set (10-08 .. 10-23) | present, unused by the 09-xx programs | no gain on these sizes; MutableVector access is itself a helper call |
| coroutine fusion (10-23) | present, used | json-parse: all three coroutines fused; game-server: switching 0.5% |
| declared errors and `fail` (10-10) | present, unused by sum-refined | its dead sentinel branch; no cost |

Three of the missing items are language-design decisions rather than
implementation work, and on its benchmark each is worth more than anything
this audit found in the generated code:

* what a loop in result position means,
* what a String's characters are to code that walks them (an index into
  UTF-8, or a cursor/iterator),
* whether character classification needs a String.

The others are runtime and backend work: inline fast paths for the helpers
above, an allocator for short-lived objects, hashed small sets. None of it
makes the integer programs faster. They are already at Go. What separates
fib from Go, and all three from Rust, is the calling convention: the Vm
pointer argument, unconditional callee-saved spills and Cranelift's register
allocation.

## Reproducing

```bash
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 bench/bench.tcl -runs 20 -budget 30 -columns "native python rust go"
tclsh9.0 audit/bench-bimodality/tools/measure.tcl -runs 30 bench/experimental/game-server.bot audit/bench-bimodality/variants/game-server-continue/game-server.bot
audit/bench-bimodality/tools/profile.sh bench/lex-strategy.bot 10 60
```

`audit/bench-bimodality/README.md` lists every variant and the dumps.
