# C-FFI-ERROR-CAPTURE-MILESTONE-2.md

Foreign-result error-capture invariance: correctness independent of
optimization, escape and integer boxing.

> A foreign function's error state must not depend on how Botlish chooses
> to represent its return value. The compiler must preserve a C result and
> any updated borrowed storage without unnecessary error-clobbering work
> until the program has had the opportunity to inspect the result and
> capture the error state.

C-FFI-ERROR-CAPTURE-MILESTONE-1.md removed the eager write-back construction
from the common case by extending struct scalar replacement, and its own
report (section 29) named three boundaries it left open: with scalar
replacement off (`-struct-opt 0`) the write-back value was built right after
the call again; a value that escaped later (captured by a closure, used in a
deeper loop, passed to a function that reads its buffer) was built at the
call; and a 64-bit C result outside the small-Int range -- `(size_t)-1` of
`iconv(3)` -- was boxed as a BigInt by the call itself, an allocation before
the program could compare it. This milestone closes all three. The window
from a C function's return to the program's error-state read now holds the
keepalives (no machine code), the comparison of the result as the machine
word C returned, and the branch -- in every lowering mode, for every escape
shape, at every C integer width -- and the eager representation exists only
as a test-only fault injection, the detectors' positive control.

## Result

```botlish
fn large(failing: ffi::c::Int) -> list:
    r = ec::large_error(failing)          # size_t: (size_t)-1 and errno on failure
    if r == 18446744073709551615:
        failure = ec::errno()
        return [r, failure]
    [r, 0]
```

lowers, in every mode, to

```text
    %1 = foreigncall 1 %0                 ; %1 a u64 register: the word C returned
    %2 = cword 18446744073709551615       ; the sentinel, a u64 constant
    %3 = op cweq %1 %2                    ; one machine comparison
    br %3 L0 L1
  label L0
    %5 = call 5                           ; errno()
    %6 = op cwbox %1                      ; the Int 2^64 - 1, after errno()
```

where Milestone 1 had `foreigncall` (boxing 2^64 - 1 into a BigInt inside
the call: `rt_ffi_box_u64`, a `malloc`) and `ieq` against a BigInt constant
(`rt_int_cmp`, which copied both BigInts: two more allocations). With an
allocator that sets errno to 77 on every allocation, Milestone 1's `large`
reports errno 77; this milestone's reports the C function's own. The same
holds for the write-back value with scalar replacement off, and for one
captured by a closure after the read:

```text
-struct-opt 0, ec::fill (darwin::read's shape)   before: keepalive structnew structnew structget ilt
                                                  after:  keepalive cwlt
captured by a closure after the errno read        before: keepalive structnew structnew structget ilt
                                                  after:  keepalive cwlt
```

What changed:

* **native/src/nir.rs, codegen/clif.rs, runtime/ffi.rs, runtime/ops.rs**:
  two register kinds for a 64-bit C integer result held as its machine word,
  `i64` and `u64` (`i64regs=`, `u64regs=`); a `foreigncall` whose
  destination is one returns the word unconverted; `cword` constants; `op
  cwbox` (the Int: inline for a small Int, `rt_ffi_box_*` beyond); `op cwlt
  cwle cwgt cwge cweq` (exact comparisons of a word with a word of its kind
  or with a tagged Int, a BigInt operand through the new, allocation-free
  `rt_ffi_word_cmp`). `rt_int_cmp` and `rt_ffi_int_word` no longer copy a
  BigInt to compare or convert it (they allocated before: section 7).
* **native/lower.tcl**, a section "Foreign-result transport": C words
  (`AssignWord`, `WordTagged`, `WordComparison`, late boxing of an operand),
  pending objects (a closed write-back MutableBytes built at its first use,
  `PendingObject`, `TaggedField`), the mandatory deferral of a write-back
  value no analysis took (`MandatoryWriteBack`: bindings, aliases, direct
  projections, `if` joins, struct literal fields), word and storage joins
  (`JoinWordKinds`), loop-entry building (`HoistDeferredUses`), captures
  (`CaptureRegsOf`), and the test-only `-fault eager-foreign-result`.
* **tests/c-ffi-error-capture.test** (12 new tests; 6 updated),
  tests/cffi/window.tcl (`window::nirBoxedResults`, the C word ops),
  tests/cffi/fixture.c (`bcf_large_error`, `bcf_fill_size`,
  `bcf_unsigned_errno`, `bcf_signed_errno`), `cb-write-back-allocations`,
  `di-errno-read-first`, `di-errno-allocator`; 15 mutants (four of
  Milestone 1's retargeted, eleven new); Rust unit tests; the `errno` part
  of bench/c-ffi-error-capture.tcl.

No HIR node, HIR fact, syntax, type, interchange field or runtime object was
added; NIR gained two register kinds, one constant instruction and six
operations, all internal to one function (section 6).

## 1. Starting state

Milestone 1 established, for every write-exposing C call a struct scalar
replacement class keeps virtual (C-FFI-ERROR-CAPTURE-MILESTONE-1.md, section
14):

* the write-back value `{result: R, NAME: MutableBytes}` is fields -- the C
  result and each private copy's storage -- and its MutableBytes are built at
  the use that reads them whole, the struct where a use needs the object;
* `op keepalive` is no machine code; liveness keeps the exposed storage a
  root;
* the NIR window from `foreigncall` to `call errno` is `keepalive ilt`, the
  object file's has at most the BigInt paths of a 64-bit result, and the
  single-step trace runs only the wrapper, `errno()` and the C library's
  `__errno_location`;
* an allocator that changes errno on every allocation changes nothing the
  program reads.

Its section 29 listed what that did not cover. This milestone takes the
first three items -- the 64-bit boxing, the closed buffers, the comparative
policies -- and the generic lowering's local capture.

## 2. The three remaining boundaries

1. **Scalar replacement off.** The write-back value was a construction of
   struct scalar replacement (`hir::escape::WriteBackResult`, `StructEnabled`):
   `-struct-opt 0` (and `-escape-opt 0`) restored the eager lowering --
   `keepalive structnew structnew structget ilt` in every window -- and the
   legacy width policy and `-struct-nesting 0` kept every MutableBytes closed,
   built at the call (`keepalive structnew ilt`).
2. **Closed and escaping values.** A binding a closure captures was never
   virtual (built at the call), and a class that closed a MutableBytes -- a
   use in a deeper loop, a parameter that reads it, an intersection with a
   literal -- built it at the call.
3. **Large C integers.** `foreigncall` converted its 64-bit result as part of
   the call: tagged inline in the small range, `rt_ffi_box_i64`/`_u64` (a
   `malloc`) beyond it -- `(size_t)-1`, `ULONG_MAX`, `LONG_MIN` -- before the
   comparison; and the comparison of a BigInt (`rt_int_cmp`) copied its
   operands.

## 3. Baseline reproductions

The census (scratch tooling beside the tests: tests/c-ffi-error-capture.
test's Milestone 1 shapes plus thirteen new ones, every function's NIR
window from its C call to its `errno()` call, `window::nirOps` /
`window::nirHazards`), Linux x86-64, on the tree before this milestone
(e2ae884):

| shape | default | `-struct-opt 0` | `-specialize 0` | both | `-escape-opt 0` | legacy policy | `-struct-nesting 0` |
|---|---|---|---|---|---|---|---|
| Milestone 1's ten shapes (fill, read, status, direct, two, alias, chosen, looped, suspended, wrapped) | `keepalive ilt` | `keepalive structnew structnew structget ilt` (+1 `structnew` per further written parameter) | `keepalive ilt` | eager | eager | `keepalive structnew ilt` (the MutableBytes closed) | as legacy |
| captured by a closure after the read, on the success path only, on the failure path only, inside a nested function | `keepalive structnew structnew structget ilt` | eager | eager | eager | eager | eager | eager |
| stored in a List / a struct after the read, passed to a function | `keepalive ilt` | eager | `keepalive ilt` | eager | eager | `keepalive structnew ilt` | as legacy |
| read whole in a loop after the read (`loop_after`) | `keepalive structnew ilt` | eager | `keepalive structnew ilt` | eager | eager | `keepalive structnew ilt` | as legacy |
| passed to an exact function that reads its buffer (`consume(w) -> [w.result, w.out]`) | `keepalive structnew ilt` | eager | (no generic lowering of the callee) | -- | -- | -- | -- |
| `(size_t)-1` compared, `ULONG_MAX`, `LONG_MIN`, `-2^62 - 1` | `ieq`/`ilt` -- and the boxing inside `foreigncall`, which NIR does not show | same | same | same | same | same | same |

Behaviorally (the escapes program as a standalone executable with
tests/cffi/errno-clobber.c, errno 77 on every allocation; default lowering):
the four captured shapes, the loop, `(size_t)-1` (twice), `ULONG_MAX`, `2^62`,
`LONG_MIN`, `-2^62 - 1` and the coroutine's `(size_t)-1` read 77; with
`-struct-opt 0` every write-back shape did too. Only the small signed
results (-1, -2^62) read their own errno in every mode.

## 4. The chosen invariant

From a C function's return to the program's capture of its error state --
for errno, the return of `__errno_location()`/`__error()` and the load
through the native view -- the code the compiler emits runs only register
moves, constants, the comparison the program wrote (of the C result as the
word C returned, or of a tagged Int), branches, `keepalive` (nothing),
and the call of the program's errno function, whatever:

* the lowering mode (`-specialize 0`, `-struct-opt 0`, `-escape-opt 0`, the
  legacy width policy, `-struct-nesting 0`, any combination);
* where the value goes after the capture (a closure, a List, a struct, a
  function, a loop, a return, a coroutine frame);
* the result's value (a small Int, `(size_t)-1`, `LONG_MIN`, any 64-bit
  word).

No heap allocation, allocator call, GC safepoint that can collect, unrelated
C call, coroutine switch or runtime helper runs there -- on any path of the
comparison against a constant; against a BigInt that is no constant, the
comparison's one helper, `rt_ffi_word_cmp`, allocates nothing and touches no
errno. The guarantee is the compiler's own work: the program's own
operations between the call and its read are the program's (section 32).

## 5. Existing native value representations

A NIR register holds a tagged Value (a small Int `(n << 1) | 1`, a heap
pointer, an immediate) unless the function header declares it otherwise:

| kind | holds | defined by | read by |
|---|---|---|---|
| tagged | a Value; a GC root when live across a safepoint | everything | everything |
| raw (`rawregs=`) | an Int proven in the small range, untagged | `runbox`, raw arithmetic, `rawint` | raw ops, `rbox` (no check: the range is proven) |
| short, ascii | a String of at most one / eight characters | their ops | their ops |
| plan | a virtual construction | `construct` | its consumers |

A struct scalar-replacement virtual value is no kind: its fields are tagged
registers in the lowering's `fn locals` -- "raw registers are never stored
in fn locals" (native/lower.tcl's "Representation"), the rule Milestone 1
cited for keeping the 64-bit boxing. A raw register could not hold a C
result either: its contract is the small range, and an unsigned word
needs unsigned comparisons.

## 6. The mandatory foreign-result transport

Three distinctions the lowering now keeps (native/lower.tcl, "Foreign-
result transport"):

* **receiving** a C result: `foreigncall` defines the word C returned,
  unconverted, for a 64-bit integer class (`i64`, `u64`); narrower classes,
  pointers and `_Bool` keep their inline conversion (no allocation, no call:
  sign/zero extension and a tag, a range check that fails, a byte check that
  fails);
* **using** it where its machine representation is known: a comparison
  reads the word (`WordComparison`); a pending field or word flows into the
  places that know it -- a virtual local's own fields, the projection that
  reads one, an `if` join of two of one kind -- and nowhere else;
* **materializing** the Botlish value: the first use that needs an Int boxes
  the word (`WordTagged`, once per dominating scope), the first use that
  needs a MutableBytes builds it (`TaggedField` of a pending object, or
  `OpenedFieldObject` of an opened one), the first use that needs the
  write-back struct builds it (`MaterializeVirtual`) -- an operand of an
  operation after every operand of that operation is evaluated, a closure's
  capture at the capture, a loop body's use at the loop's entry.

The one necessary NIR change is the word kinds. The existing mechanisms
could not express a value that is no Value and needs no small-range proof:
a tagged register must always hold a Value (the root plan stores it to the
shadow stack), and a raw one a small Int. Nothing else was needed: the
write-back fields, the lazy materialization, the dominance scoping and the
`if` joins are Milestone 1's and struct scalar replacement's own, now also
applied where the analysis is off or declined.

The words are internal to one function (nir.rs's validate): never a
parameter, a result (`ret`, `retmulti`), an argument, a capture, a `move`
into another kind, the operand of any other op. So no function ever
receives an untyped machine register, and every consumer that expects a
Value still gets one: `TaggedFields` sits at every place field registers
leave the deferred representation (a struct built from them, a `retmulti`,
a callee's fields, a join, an error payload, a context's leaves).

The mandatory deferral covers what a function can do with a write-back
value before reading errno in its own body: bind it (or an alias), project
a field straight off the call, join two calls in an `if`, hold it in a
struct literal kept as fields. It is applied after escape analysis declined
(`MandatoryWriteBack` in `Bind`, `Project` and `StructFields`), with every
MutableBytes opened (`WriteBackCut`: nothing to build at the call). What
escape analysis does take keeps its own cut; only where a closed child is
built moved -- from the call to its first use (a pending object).

## 7. Raw C integer handling

| C result class | before | after |
|---|---|---|
| `int`, `unsigned int`, narrower | sign/zero-extended, tagged inline | unchanged (always small: no allocation) |
| `long`, `long long`, `ssize_t` (`i64`) | tagged inline when small, else `rt_ffi_box_i64` | the `i64` word; `cwbox` at its first Int use |
| `unsigned long`, `unsigned long long`, `size_t` (`u64`) | tagged inline below 2^62, else `rt_ffi_box_u64` | the `u64` word; `cwbox` at its first Int use |
| `_Bool` | the byte checked and made a bool | unchanged |
| pointer (null included) | the C address word, range-checked | unchanged |
| `float`, `double` | checked finite, then `rt_float_new` (an allocation) | unchanged: a limit (section 32) |
| `void`, an aliasing pointer discarded | unit | unchanged |

`cwbox` is `box_word` -- the code `foreign_result` used to run inside the
call -- moved to the use. Two BigInt helpers allocated where they should
not: `rt_int_cmp` compared two Ints by converting both to owned BigInts (a
small Int too: `BigInt::from`, a heap digit vector) and `rt_ffi_int_word`
copied its BigInt; both now read the BigInt in place (`big_of`), so no
comparison of Ints allocates anywhere (Milestone 1 listed `rt_int_cmp` among
the window's acceptable paths as allocation-free; it was not).

## 8. Signedness and width

The word's kind is its signedness, decided once, from the declaration's ABI
class (`ForeignWordKind`: `i64` or `u64` of the HIR's `foreign` table), and
validated against it (`foreigncall`'s destination must be a word of the
result class's own signedness). Every consumer reads it: `cwbox` boxes an
`i64` as signed and a `u64` as unsigned (`2^64 - 1`, never `-1`), the
comparisons use signed or unsigned machine conditions, and a tagged operand
is compared exactly -- a negative small Int is below every unsigned word, a
BigInt beyond the word's range above or below every word by its sign.
Nothing narrows or widens: `ec-word-comparisons` compares every boundary of
the small-Int range (2^62 - 1, 2^62, -2^62, -2^62 - 1) and the 64-bit
extremes, signed and unsigned, against constants that fit the word, that do
not (`-1` against an unsigned word, `2^64 - 1` against a signed one), and
against BigInt values that are no constants, with the word on either side,
and does arithmetic on the boxed results (`(2^64 - 1) + 1`).

## 9. Large C sentinel handling

`(size_t)-1` is compared as a `u64` word against a `cword
18446744073709551615` of the same kind: one `cmp`/`cmn` and a branch. The
constant is known at compile time, so the comparison has no BigInt path at
all (ec-modes-machine-windows: no call on any path of `large`'s window).
Comparing against a BigInt *variable* instead takes `rt_ffi_word_cmp` on
the path where that operand is a BigInt -- exact, and allocation-free.
After the capture the full value is materializable: `cwbox` makes the Int
2^64 - 1 (a BigInt), which the program then stores, prints and computes
with (`ec-escapes-values`, `ec-word-comparisons`). The fixture's
`bcf_large_error` is `iconv(3)`'s convention; the binding's `size_t` is the
host C compiler's answer (`ecSizeType`: `ffi::c::ULong` where `size_t` is as
wide as `unsigned long`, else `ffi::c::ULongLong`).

## 10. Write-back semantics with scalar replacement off

`-struct-opt 0` turns off struct scalar replacement: ordinary struct
literals are objects, nothing crosses a call as fields, `abi::Usize` results
are built. It no longer turns off the write-back value's transport: a
binding of a write-back call, an alias of one, a projection off one and an
`if` of two are held as fields by `MandatoryWriteBack` whatever the
analysis said; the discarded call builds nothing (the `discarded` rule was
gated on `structOpt` and is not any more). `cb-write-back-allocations`
counts it: with `-struct-opt 0` the objects per call are the same as
without -- `1 0`, `1 0`, `1 1`, `1 2`, `1 10` against `1 0`, `1 0`, `1 1`,
`1 1`, `1 1`; the difference is the extra `abi::Usize` of each
`mutable_length` call, an ordinary struct -- where Milestone 1 built two
write-back objects at every call (`1 2`, `1 2`, `1 2`, `1 3`, `1 11`).

## 11. Closed and captured write-back handling

* A closed MutableBytes is a **pending object**: its field register is a
  fresh register no instruction defines, standing for `structnew
  MutableBytes STORAGE` over the private copy (the lowering records it; an
  unforced one leaking into an instruction would be an undefined register,
  which validation rejects). The first use that needs the object builds it
  (`TaggedField`, cached for the dominating scope); a use that needs only
  the storage -- another foreign call's exposure -- reads the storage
  (`OpenedOwnerStorage`); a projection chain through one reads its fields
  (`ProjectChain`).
* A binding a closure captures is held as fields (the mandatory deferral);
  `CaptureRegsOf` builds the whole value at the closure's creation -- after
  the errno read in every captured shape (on every path, the success path
  only, the failure path only, a nested function: ec-modes-nir-windows,
  ec-trace-captured).
* A loop: `HoistDeferredUses` scans the body (`DeferredNeeds`) for what it
  needs built of a deferred value bound outside it -- a word used other than
  in a comparison, a pending or opened MutableBytes read whole, a mandatory
  value used whole or captured -- and builds it once at the loop's entry,
  where the body's scope finds it (`cb-write-back-allocations`' loop row: one
  MutableBytes for ten reads, with and without scalar replacement).
* A value stored in a List or a struct, passed to a function or returned
  after the read is built at that operation.

## 12. Generic lowering

`-specialize 0` lowers generic instances only; escape analysis still runs on
them, and the transport applies in every instance alike. A function that
makes the call and reads errno in its own body has a clean window there in
every shape (`ec-modes-nir-windows`, `-specialize 0` and both flags; `ec-
modes-executables`). What the generic lowering does not do is carry a
struct across a call as fields (STRUCTS.md, "Known limitations"): a write-
back value returned from the function that made the call is built before
that function returns. Such a function has not read errno; whatever runs in
its caller -- this return's construction included -- may change it. That is
the boundary of the guarantee (section 32): the function that makes a C
call reads its error state, as `darwin::read` and every binding here do.

## 13. `retmulti` and `callmulti`

A C word never crosses a call: `retmulti`'s operands are tagged (nir.rs's
validate), so a companion function returning a write-back value as fields
boxes its word for the return (`raw`'s window: `keepalive cwbox`: inline for
a small result) and the caller receives tagged fields (`callmulti`), as
before. A pending MutableBytes of a returned class is built at the return
the same way. Words staying in their function is what keeps every function
ABI, every block value and the raw/short/ascii ABIs unchanged.

## 14. Detached storage and GC rooting

The private copy's register is a tagged Value -- a storage object -- and,
held in fields, an ordinary root like any register live across a safepoint
(codegen::roots: NIR liveness). A pending object extends the copy's live
range to the use that builds it (one more register live across the
safepoints in between: the copy, which was the object's only field anyway).
A C word is in `scalar_regs` (never a root, never stored to the shadow
stack: the collector would misread `0xffff...` as a pointer). A hoisted
build at a loop's entry is a tagged register live through the loop. The
collector's ownership and pinning model is unchanged; nothing is pinned.
GC stress: section 20 and 26; Windows' fallback root plan (shadow stack, no
frame walk) reads the same `scalar_regs`.

## 15. Before and after: NIR

(tests/c-ffi-error-capture.test's shapes compiled for linux-x86_64 and
macos-aarch64 alike; "before" is e2ae884 or, for the eager representation,
`-fault eager-foreign-result`)

<<NIR-TABLE>>

## 16. Before and after: machine code

<<MACHINE>>

## 17. Dynamic trace

<<TRACE>>

## 18. Adversarial errno-clobber tests

tests/cffi/errno-clobber.c (Milestone 1's: every successful `malloc`,
`calloc`, `realloc`, `posix_memalign` and `aligned_alloc` sets errno to
`BCF_ERRNO_CLOBBER`, 77; `LD_PRELOAD` on Linux, `DYLD_INSERT_LIBRARIES` and
`__DATA,__interpose` on macOS), loaded into the executables of two
programs:

* **the escapes program** (new): sixteen errno-reading functions --
  captured after the read, on the success path only (then the failure path
  too), on the failure path only (then the success path), inside a nested
  function; stored in a List, in a struct; passed to a function; read whole
  in a loop; a write-back value with a `size_t` result failing with
  `(size_t)-1` (and succeeding); `(size_t)-1` bound and compared, compared
  straight off the call; `ULONG_MAX`, 2^62 - 1, 2^62, 2^63 read errno-first;
  `LONG_MIN`, -1, `LONG_MAX`, -2^62 - 1, -2^62 compared; -2^62 - 1 and -2^62
  errno-first; a coroutine failing with `(size_t)-1` before and after a
  suspension; `close(-1)`, a C `int`. Errnos 41 to 60 and EBADF, distinct, in
  succession, successes between them reporting 0.
* **Milestone 1's shapes**: bound, status only, straight off the call, two
  written parameters (one owner passed twice), a read and a write exposure
  of one owner, held in a struct, an `if` of two calls, in a loop, in a
  coroutine, returned from a function.

`ec-modes-executables` runs both in all four modes (default, `-struct-opt
0`, `-specialize 0`, both), each plain, under GC stress, with the
allocator, and with both: every errno is the C call's own, every value the
oracle's -- but for the two Milestone 1 shapes outside the guarantee by
construction (section 32): `via_raw` (whose callee returns its C call's
write-back value unread: built for the return under `-specialize 0` and
`-struct-opt 0`) and `wrapped` (a struct literal holding the value, built
with `-struct-opt 0`), which read 77 there and nowhere else.

## 19. Positive control

`-fault eager-foreign-result` (native/lower.tcl's `fault`, also
`BOTLISH_NATIVE_FAULT`; test-only, never a program's option) re-creates
Milestone 1's representation and the pre-Milestone-1 one with it: no C
words (the call converts its 64-bit result, `rt_ffi_box_*` beyond the small
range), every write-back MutableBytes and the write-back struct built right
after the call, no mandatory deferral. Every detector sees it:

| detector | with the fault |
|---|---|
| NIR window (`ec-nir-positive-control`, `ec-darwin-read-window`, with `-struct-opt 0`) | `keepalive structnew structnew structget ilt` -- Milestone 1's "before", instruction for instruction |
| `window::nirBoxedResults` (`ec-boxed-results`) | every 64-bit `foreigncall` of the escapes program converted by the call |
| object file (`ec-machine-positive-control`, `ec-modes-machine-windows`) | `rt_struct_new` on every write-back shape's path, `rt_ffi_box_u64` on `(size_t)-1`'s |
| single-step trace (`ec-trace`, `ec-trace-large-sentinel`, `ec-trace-captured`) | `rt_struct_new` / `rt_ffi_box_u64` executed and the C library's allocator entered |
| errno-changing allocator (`ec-clobber-positive-control`, `ec-modes-positive-control`, `di-errno-allocator`) | 77 for every write-back shape and every 64-bit result outside the small range; results and buffers unchanged |

The allocator itself is shown to act (`ec-clobber-positive-control`: a
program that builds a String between the call and its read reads 77).

## 20. Linux C fixture results

<<LINUX-FIXTURE>>

## 21. Darwin IO results

`darwin::read` is unchanged source. Its `ssize_t` result is now an `i64`
word: `di-errno-read-first` (any host, macos-aarch64 NIR) reads
`{keepalive cwlt} {keepalive cwlt} {keepalive runbox rilt} {keepalive
runbox rilt} {runbox rilt}` for write, read, open (both forms) and close --
write and read compare their word, open and close their `int` -- and
`di-errno-allocator` (macOS) runs the errno program with the errno-changing
allocator three ways: as compiled (every errno right), with `-struct-opt 0`
(every errno right: new), and with `-struct-opt 0 -fault eager-foreign-
result` (read's errno 77, and only read's). Section 30 has the run.

## 22. Escaping and captured values

| the write-back value after the read | how it is held until then | built |
|---|---|---|
| captured by a closure (any path, nested) | fields (mandatory deferral) | at the closure's creation |
| stored in a List, in a struct | fields | at the List / struct |
| passed to a function | fields | at the call (the argument) |
| passed to an exact function as fields | fields; a closed MutableBytes pending | the callee's use, or the call |
| read whole in a deeper loop | fields; the MutableBytes pending or opened | once, at the loop's entry |
| returned | fields across `retmulti` where the return transports them, else built at the return | -- |
| held across a suspension | fields in the coroutine's frame | at its use after the resume |
| `if` of two calls | joined field-wise: the storages, the words of one kind | at the use |

## 23. Interpreter and Tcl compiler

No file of `core/` or `compiler/` changed; the Tcl backends refuse a C call
(NATIVE-ONLY) as before (`ec-tcl-backends`). The local run (section 28)
runs every Tcl test file on interp and compile.

## 24. HIR interchange

The representation is a lowering decision over the HIR's existing facts
(the call's `borrows`, the `foreign` table's ABI classes): `ec-modes-
interchange` writes the escapes program as interchange text, reads it back
after another compilation and gets identical NIR in all four modes. The
format, the front-end cache and their keys are unchanged.

## 25. Mutation results

<<MUTANTS>>

## 26. Allocation counts

<<ALLOCATIONS>>

## 27. Performance

<<PERFORMANCE>>

## 28. Linux x86-64 CI

<<CI-LINUX>>

## 29. Linux AArch64 CI

<<CI-ARM64>>

## 30. macOS AArch64 CI

<<CI-MACOS>>

## 31. Windows regression

<<CI-WINDOWS>>

## 32. Remaining limits of the guarantee

* **The program's own operations.** What the program writes between the
  call and its read runs there: an allocation it asks for, a struct literal
  it builds around the value (with scalar replacement off, `{r: c(...), tag:
  1}` is an object: `wrapped`), a `yield`, another call. The transport defers
  the compiler's work, not the program's.
* **A value returned unread.** A function that returns its C call's result
  without reading errno leaves the error state to whatever runs next -- its
  own return's construction included, where the return carries no fields
  (the generic lowering; scalar replacement off; a 64-bit word is boxed for
  any return). Read the error state in the function that made the call
  (MACOS-AARCH64-MILESTONE-8.md's rule).
* **C `float` and `double` results.** A Float64 is a heap object: a C
  double result is checked finite and boxed by the call (`rt_float_new`, an
  allocation), as before. A binding that reads errno after a floating
  result (`strtod`'s ERANGE) can see it changed. A deferred floating word
  -- the same transport with an `f64` kind -- is follow-on work (section
  33); none of the libraries does this today.
* **A loop's entry.** A deferred value a loop needs built is built at the
  loop's entry, once: a program that reads, inside that loop, the errno of
  a call made before it, after the loop started, reads it after that build.
* **A word comparison against a BigInt that is no constant** takes
  `rt_ffi_word_cmp` (no allocation, no errno) on the path where the operand
  is a BigInt: a call, though not an error-clobbering one.
* **Errno itself** is still read by a Botlish function and `rt_native_load`
  (Milestone 1, section 29), and is one thread's.
* **Evidence per host.** The single-step trace is Linux's (x86-64 and
  AArch64); macOS's evidence is the NIR and object-file detectors and the
  errno-changing allocator.

## 33. Follow-on ideas, deferred

* A deferred floating result (an `f64` word kind, `cfbox`, floating word
  comparisons), for `strtod`-style APIs.
* Words across exact calls (a raw-ABI result of a C word) -- unneeded while
  the function that calls C reads its error state.
* Windows: `GetLastError()` read through an `extern c fn` right after the
  call needs nothing more once C calls run on Windows (`C_CALLS`): the words,
  the deferral and the detectors are target-independent.
* An inline `NativeView` load of a fixed-width field (no helper between
  `__errno_location` and the load).
