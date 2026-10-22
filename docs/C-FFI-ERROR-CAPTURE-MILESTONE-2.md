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
    %1 = foreigncall 2 %0                 ; %1 a u64 register: the word C returned
    %2 = cword 18446744073709551615       ; the sentinel, a u64 constant
    %3 = op cweq %1 %2                    ; one machine comparison
    br %3 L0 L1
  label L0
    %5 = call 5                           ; errno()
    %6 = op cwbox %1                      ; the Int 2^64 - 1, after errno()
    %7 = op listnew %6 %5
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
  `di-errno-read-first`, `di-errno-allocator`; 18 mutants (five of
  Milestone 1's retargeted, thirteen new); Rust unit tests; the `errno`
  part of bench/c-ffi-error-capture.tcl and its `allocations` part per
  lowering mode.

No HIR node, HIR fact, syntax, type, interchange field or runtime object was
added; NIR gained two register kinds, one constant instruction and six
operations, all internal to one function (section 6).

### Before and after

Each cell is what the detectors found -- the NIR window (section 15), the
object file's calls on any path of the window (section 16), and the
executables with the errno-changing allocator (section 18) -- on e2ae884
(Milestone 1) and on this milestone's tree, Linux x86-64; section 30 has
macOS and section 29 Linux AArch64, where the same tests run.

| case | Milestone 1 | Milestone 2 |
|---|---|---|
| small C `int` sentinel (`close(-1)`), any mode | safe | safe |
| small 64-bit sentinel (`long` -1), any mode | safe: the call's boxing path (`rt_ffi_box_i64`) and `rt_int_cmp` on paths -1 does not take | safe: no call on any path |
| write-back status (`darwin::read`'s shape), optimized | safe (the boxing path as above) | safe |
| write-back status, `-struct-opt 0`, `-escape-opt 0`, both flags | unsafe: struct and MutableBytes built at the call | safe |
| write-back status, legacy width policy, `-struct-nesting 0` | unsafe: the MutableBytes built at the call | safe |
| write-back status, generic lowering (`-specialize 0`) | safe | safe |
| later closure capture (any path, nested function), any mode | unsafe | safe |
| later aggregate escape (List, struct, an argument), optimized / `-specialize 0` | safe | safe |
| later aggregate escape, `-struct-opt 0` | unsafe | safe |
| later use in a deeper loop | unsafe: the MutableBytes built at the call | safe: built once at the loop's entry, after the read |
| returned by the function after the read, optimized / `-struct-opt 0` | safe / unsafe | safe / safe |
| large unsigned sentinel (`(size_t)-1`), any mode | unsafe: `rt_ffi_box_u64` and two BigInt copies before the comparison | safe |
| large signed results (`LONG_MIN`, below -2^62), any mode | unsafe | safe |
| large results read errno-first (2^62, 2^63, `ULONG_MAX`) | unsafe | safe |
| large sentinel in a coroutine, before and after a `yield` | unsafe | safe |
| generic lowering, error state read in the calling function | partially safe (a write-back value read locally safe; captured or looped values and large results not) | safe for immediate local capture |
| value returned *unread* to a caller that reads errno (`via_raw`), `-specialize 0` or `-struct-opt 0` | unsafe | unsafe: outside the guarantee (section 32) |
| the program's own struct literal around the value before the read (`wrapped`), `-struct-opt 0` | unsafe | unsafe: the program's construction (section 32) |

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
counts it: with `-struct-opt 0` the objects per call -- `1 0`, `1 0`, `1 1`,
`1 2`, `1 10` against the default's `1 0`, `1 0`, `1 1`, `1 1`, `1 1` --
differ only by the `abi::Usize` of each `mutable_length` call, an ordinary
struct, where Milestone 1 built two write-back objects at every call (`1
2`, `1 2`, `1 2`, `1 3`, `1 11`).

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
GC stress: section 28 (and section 30's macOS run); Windows' fallback root plan (shadow stack, no
frame walk) reads the same `scalar_regs`.

## 15. Before and after: NIR

Every window from a C call to its `errno()` call, as `window::nirOps`
prints it (the census tool beside the tests; the shapes are
tests/c-ffi-error-capture.test's, whose `ec-modes-nir-windows` checks the
after column for linux-x86_64 and macos-aarch64 alike). Before: e2ae884, whose `-specialize 0`
equals its default and `-escape-opt 0` and both flags its `-struct-opt 0`.
After: every mode -- default, `-struct-opt 0`, `-specialize 0`, both,
`-escape-opt 0`, the legacy width policy, `-struct-nesting 0` -- gives the
same window, except where noted.

| shape | before: default | before: `-struct-opt 0` | before: legacy, `-struct-nesting 0` | after: every mode |
|---|---|---|---|---|
| fill, read, status only, alias, an `if` of two calls, suspended (each window) | `keepalive ilt` | `keepalive structnew structnew structget ilt` | `keepalive structnew ilt` | `keepalive cwlt` |
| straight off the call | `keepalive ilt` | `keepalive structnew structnew structget ilt` | `keepalive ilt` | `keepalive cwlt` |
| two written parameters | `keepalive keepalive ilt` | `keepalive keepalive structnew structnew structnew structget ilt` | `keepalive keepalive structnew structnew ilt` | `keepalive keepalive cwlt` |
| in a loop | `keepalive ilt` | `keepalive structnew structnew structget ilt structget` | `keepalive structnew ilt` | `keepalive cwlt` |
| captured after the read, on the success path, on the failure path, nested | `keepalive structnew structnew structget ilt` | the same | the same | `keepalive cwlt` |
| stored in a List, in a struct, passed, returned | `keepalive ilt` | `keepalive structnew structnew structget ilt` | `keepalive structnew ilt` | `keepalive cwlt` |
| read whole in a loop after the read | `keepalive structnew ilt` | `keepalive structnew structnew structget ilt` | `keepalive structnew ilt` | `keepalive cwlt` |
| write-back value with a `size_t` result | `keepalive ieq` | `keepalive structnew structnew structget ieq` | `keepalive structnew ieq` | `keepalive cweq` |
| `(size_t)-1` bound, straight off the call, in a coroutine (two) | `ieq` | `ieq` | `ieq` | `cweq` |
| `long` compared (`signed_cmp`) | `ilt` | `ilt` | `ilt` | `cwlt` |
| errno read first (`unsigned_first`, `signed_first`: the test is of the parameter) | `runbox rieq` | the same | the same | `runbox rieq` |
| `close(-1)` (a C `int`) | `runbox rilt` | the same | the same | `runbox rilt` |
| `wrapped` (`w = {r: fill(...), tag: 1}`) | `keepalive ilt` | `keepalive structnew structnew structnew structget structget ilt` | `keepalive structnew structnew structget ilt` | `keepalive cwlt`; with `-struct-opt 0` or `-escape-opt 0`: `keepalive structnew cwbox structnew structnew structget structget ilt` (the program's literal, section 32) |

`ilt`/`ieq` in the "before" columns hide work NIR does not show: the
`foreigncall` itself converted its 64-bit result, `rt_ffi_box_*` beyond the
small range (`window::nirBoxedResults` makes that visible:
`ec-boxed-results`). With the fault the "after" tree reproduces the "before"
columns: `-fault eager-foreign-result -struct-opt 0` gives exactly the
`-struct-opt 0` column, write-back shapes and large results alike.

`returned` (the value returned by the function that read its errno):

```botlish
fn returned(data: abi::bytes::MutableBytes, err: ffi::c::Int):
    r = ec::fill_errno(data, ec::mlen(data), 11, err, 0)
    if r.result < 0:
        if ec::errno() != err:
            return ec::fill_errno(empty(), 0, 0, 0, 0)
    r
```

```text
-struct-opt 0, before (e2ae884):
    %10 = foreigncall 0 %9 %3 %4 %1 %6 exposed=0   ; tagged by the call (rt_ffi_box_i64 beyond the small range)
    %11 = op keepalive %8
    %12 = structnew 1 %8                          ; the MutableBytes
    %13 = structnew 2 %12 %10                     ; {out, result}
    %14 = structget 1 %13
    %15 = int 0
    %17 = op ilt %14 %15
    br %17 L0 L1
  label L0
    %20 = call 4                                  ; errno()
-struct-opt 0, after (i64regs="10 12 32"):
    %10 = foreigncall 0 %9 %3 %4 %1 %6 exposed=0   ; the long C returned
    %11 = op keepalive %8
    %12 = cword 0
    %13 = op cwlt %10 %12
    br %13 L0 L1
  label L0
    %16 = call 4                                  ; errno()
```

## 16. Before and after: machine code

The object file's calls on any path from a C call's return to the call of
`errno()` (`window::machineWindow`, objdump with relocations; Linux
x86-64 here; `ec-modes-machine-windows` runs the same check on every host
that runs the suite, section 29 and 30), every shape of section 15:

| | before (e2ae884) | after |
|---|---|---|
| every shape with a `long` result, default and `-specialize 0` | `rt_ffi_box_i64`, `rt_int_cmp` (the paths beyond the small range: -1 takes neither) | none |
| the same, `-struct-opt 0` (and wherever the value was built: captured, the loop, legacy) | `rt_ffi_box_i64`, `rt_int_cmp`, `rt_struct_new` | none |
| `(size_t)-1` and the other 64-bit sentinels | `rt_ffi_box_u64` (taken: (size_t)-1 is beyond the small range), `rt_int_cmp` | none |
| `close(-1)` | none | none |
| `wrapped`, `-struct-opt 0` | `rt_ffi_box_i64`, `rt_int_cmp`, `rt_struct_new` | the same (the program's literal) |
| any shape, the eager-foreign-result fault | -- | `rt_ffi_box_*`, `rt_int_cmp`, `rt_struct_new` (the before column) |

So every call the static CFG held in Milestone 1's windows is gone, not
only the ones the tested sentinel takes: the after windows have no call on
any path. The one helper a word comparison can still call,
`rt_ffi_word_cmp`, is on the path of a comparison with a BigInt that is no
constant -- none of the error-capture shapes has one (`ec-word-comparisons`
exercises it, outside any window).

`large` (the Result section's function), Linux x86-64, from the return of
`bcf_large_error` to the call of `errno()` (`botlish_fn_1`), default
lowering. Before:

```text
 197:  call   rax                                  ; bcf_large_error
 199:  cmp    rax,QWORD PTR [rip+0x140]            ; below 2^62?
 1a3:  jb     1b9
 1ac:  call   rt_ffi_box_u64                       ; (size_t)-1: a BigInt (malloc)
 1b4:  jmp    1c9
 1b9:  shl/or ...                                  ; small: tagged inline
 1c9:  ...                                         ; is either operand a BigInt?
 1f0:  call   rt_int_cmp                           ; yes: (size_t)-1 == 2^64-1
 ...
 220:  cmp    rcx,0x6                              ; the comparison's Bool
 224:  je     26f
 26f:  mov    r12,rax
 275:  call   botlish_fn_1                         ; errno()
```

After:

```text
 197:  call   rax                                  ; bcf_large_error
 199:  cmp    rax,0xffffffffffffffff               ; the u64 word against (size_t)-1
 19d:  je     219
 ...                                               ; success: cwbox, the List
 219:  mov    r12,rax
 21c:  mov    rdi,rbx
 21f:  call   botlish_fn_1                         ; errno()
```

The success path boxes the word (`rt_ffi_box_u64` only when it is beyond
the small range) and builds the List the function returns: after the
branch, on the path that reads no errno.

## 17. Dynamic trace

tests/cffi/window-trace.c single-steps the executable (ptrace) from the
instruction after the C call's return to the load of errno
(`rt_native_load`), and the tests name every function a step lands in
(Linux; x86-64 here, AArch64 in tests-arm64.yml, section 29):

| test | lowering | functions executed |
|---|---|---|
| `ec-trace` (`ec::fill`, darwin::read's shape) | default | `ec::fill`, `ec::errno`, `__errno_location`, `ec::errno` |
| `ec-trace-large-sentinel` (`(size_t)-1`) | default | `large`, `ec::errno`, `__errno_location`, `ec::errno` |
| | `-struct-opt 0 -specialize 0` | the same |
| | eager-foreign-result fault | `rt_ffi_box_u64`, then the C library's allocator (traced up to its entry) |
| `ec-trace-captured` (captured by a closure after the read) | default | `captured`, `ec::errno`, `__errno_location`, `ec::errno` |
| | `-struct-opt 0` | the same |
| | eager-foreign-result fault | `rt_struct_new`, then the C library's allocator |

No runtime helper, no allocator and no other C function runs between the C
function's return and the errno load; the faulty executables enter the
allocator there.

## 18. Adversarial errno-clobber tests

tests/cffi/errno-clobber.c (Milestone 1's: every successful `malloc`,
`calloc`, `realloc`, `posix_memalign` and `aligned_alloc` sets errno to
`BCF_ERRNO_CLOBBER`, 77; `LD_PRELOAD` on Linux, `DYLD_INSERT_LIBRARIES` and
`__DATA,__interpose` on macOS), loaded into the executables of two
programs:

* **the escapes program** (new): seventeen errno-reading functions --
  captured after the read, on the success path only (then the failure path
  too), on the failure path only (then the success path), inside a nested
  function; stored in a List, in a struct; passed to a function; read whole
  in a loop; returned by the function after the read (which, should it read
  a wrong errno, returns another value instead); a write-back value with a `size_t` result failing with
  `(size_t)-1` (and succeeding); `(size_t)-1` bound and compared, compared
  straight off the call; `ULONG_MAX`, 2^62 - 1, 2^62, 2^63 read errno-first;
  `LONG_MIN`, -1, `LONG_MAX`, -2^62 - 1, -2^62 compared; -2^62 - 1 and -2^62
  errno-first; a coroutine failing with `(size_t)-1` before and after a
  suspension; `close(-1)`, a C `int`. Errnos 41 to 61 and EBADF, distinct, in
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
`BOTLISH_NATIVE_FAULT`; test-only, never a program's option) re-creates the
eager representation -- what Milestone 1 emitted with scalar replacement
off and what every lowering emitted before Milestone 1: no C words (the call
converts its 64-bit result, `rt_ffi_box_*` beyond the small range), every
write-back MutableBytes and the write-back struct built right after the
call, no mandatory deferral. With `-struct-opt 0` it is Milestone 1's
`-struct-opt 0` lowering instruction for instruction (section 15). Every
detector sees it:

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

`ec-escapes-values` runs the escapes program (section 18) on both native
backends, linked with tests/cffi/fixture.c (the host's C compiler), and
compares it with the oracle; `ec-modes-executables` runs it in the four
modes, plain, under GC stress, with the allocator and with both. Linux
x86-64, every mode, every run:

| function | value |
|---|---|
| `captured_after(m, 41)` and the closure | `[41, 03284d72]` (the buffer C wrote, read through the closure) |
| `captured_success(m, 0)`, `(m, 42)` | `[0, 04294e73]`, `[42, (empty)]` |
| `captured_failure(m, 43)`, `(m, 0)` | `[43, 052a4f74]`, `[0, (empty)]` |
| `nested(m, 44)` | `[44, 062b5075]` |
| `stored_list`, `stored_struct`, `passed`, `loop_after` | errnos 45 to 48, each value `{out: ..., result: -1}` beside it |
| `returned(m, 61)`, `returned(m, 0)` | `{out: 0b30557a, result: -1}`, `{out: 0b30557a, result: 4}` (a wrong errno would return `{out: (empty), result: 0}`) |
| `write_back_large(m, 49)`, `(m, 0)` | `[18446744073709551615, 49, 0c31567b]`, `[4, 0, 0c31567b]` |
| `large(50)`, `large(0)`, `large_direct(51)`, `large_direct(0)` | `[18446744073709551615, 50]`, `[42, 0]`, `51`, `0` |
| `unsigned_first` (2^64 - 1, 2^62 - 1, 2^62, 2^63) | `[18446744073709551615, 52]`, `[4611686018427387903, 0]`, `[4611686018427387904, 53]`, `[9223372036854775808, 0]` |
| `signed_cmp` (`LONG_MIN`, -1, `LONG_MAX`, -2^62 - 1, -2^62) | errnos 54 to 57 beside each, 0 for `LONG_MAX` |
| `signed_first` (-2^62 - 1, -2^62) | `[-4611686018427387905, 58]`, `[-4611686018427387904, 0]` |
| `in_coroutine(59, 60)` | `[59, 59060]`: 59 before the `yield`, 60 after (+ 1000 x 59) |
| `int_sentinel()` (`close(-1)`) | `[-1, 9]` (EBADF, the host's own) |
| the caller's `m` | `00000000`: unchanged |

`ec-word-comparisons` compares every word of the fixture's two tables
(`bcf_unsigned_errno`: 0, 5, 2^62 - 1, 2^62, 2^63, 2^64 - 2, 2^64 - 1;
`bcf_signed_errno`: 0, -1, 2^62 - 1, 2^62, `LONG_MAX`, -2^62, -2^62 - 1,
`LONG_MIN`) against constants that fit the word and that do not, and
against BigInt values that are no constants, on both sides, with arithmetic
on the boxed values: equal to the interpreter's arithmetic on the same
numbers. tests/c-ffi.test (112 tests, its `cf-va-*` variadic calls and
pointer results among them), tests/c-byte-borrowing.test and
tests/c-pointer-borrowing.test pass unchanged but for
`cb-write-back-allocations`' `-struct-opt 0` row (section 26).

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

`audit/c-pointer-borrowing/tools/mutate.tcl` (each mutant a private copy of
the compiler and backend, a native one rebuilt; one that does not build is
NOT-BUILT, never killed; one whose text no longer occurs exactly once is
NOT-APPLIED) now carries 56 mutants: Milestone 1's 43, five of them
retargeted at the transport (`write-back-not-a-construction`,
`write-back-buffer-eager`, `allocation-after-c-call`,
`write-back-result-changed`, `write-back-buffer-built-per-iteration`), and
thirteen new. The brief's list, each as the mutant that realizes it and
the detectors that kill it -- structural ones for the window, semantic and
GC-stress ones for values, signedness and lifetimes:

| the brief's mutation | mutant | kind | killed by (Linux x86-64) |
|---|---|---|---|
| eager write-back construction only with `-struct-opt 0` | `transport-only-with-struct-opt` | window | 7 tests: `ec-modes-nir-windows`, `ec-modes-nir-no-hazard`, `ec-modes-machine-windows`, `ec-modes-executables` (the allocator), `ec-darwin-read-window`, `cb-write-back-allocations`, ... |
| eager construction for closure-captured values | `captured-write-back-eager` | window | 5: `ec-modes-nir-windows`, `ec-modes-nir-no-hazard`, `ec-modes-machine-windows`, `ec-modes-executables`, `ec-trace-captured` |
| eager construction for a returned write-back value | `returned-write-back-eager` | window | 4: `ec-modes-nir-windows`, `ec-modes-nir-no-hazard`, `ec-modes-machine-windows`, `ec-modes-executables` (with the allocator, `returned` hands back the other value) |
| eager construction in generic lowering | `transport-not-in-generic-lowering` | window | 5: `ec-modes-nir-windows`, `ec-modes-nir-no-hazard`, `ec-modes-machine-windows`, `ec-modes-executables`, `ec-darwin-read-window` |
| immediate `rt_ffi_box_u64` for a large sentinel | `large-unsigned-boxed-at-call` | window | 6: `ec-boxed-results`, `ec-large-sentinel-nir`, `ec-modes-nir-windows`, `ec-modes-machine-windows`, `ec-modes-executables`, `ec-trace-large-sentinel` |
| immediate `rt_ffi_box_i64` for a large signed result | `large-signed-boxed-at-call` | window | 14, among them `ec-boxed-results`, `ec-darwin-read-window`, `ec-fixture-executable`, `ec-interchange` |
| the sentinel compared with the wrong signedness | `word-compare-wrong-signedness` (codegen::clif) | value | 1: `ec-word-comparisons` (an unsigned word above 2^63 - 1 against 2^62 and a BigInt) |
| a raw 64-bit return truncated | `word-truncated` (codegen::clif) | value | 12, among them `bb-read-sizes`, `bb-read-zero-and-high-bytes`, `bb-read-address-above-4gib`, `bb-gc-stress` |
| the full value materialized before the sentinel comparison | `sentinel-boxed-before-compare` | window | 9, among them `ec-large-sentinel-nir`, `ec-modes-nir-windows`, `ec-modes-machine-windows`, `ec-modes-executables`, `ec-darwin-read-window` |
| a nested MutableBytes wrapper built before the errno read | `write-back-buffer-eager` (retargeted) | window | 17, among them `ec-darwin-read-window`, `ec-fixture-executable`, `ec-clobber-positive-control`, `cb-write-back-allocations` |
| a detached owner's GC root lost | `write-back-copy-not-a-root` (codegen::roots), `keepalive-not-a-use` | lifetime | 8 GC-stress tests, among them `bb-gc-stress`, `cb-failure-gc-stress`, `cb-gc-stress-programs`, `ec-fixture-executable`; 1: `cb-liveness-reentrant` |
| a required materialization after the errno read lost | `capture-materialization-lost` | value | 5: `ec-escapes-values`, `ec-modes-executables`, `ec-fixture-executable`, `ec-fixture-shapes`, `ec-clobber-positive-control` |
| the updated buffer materialized twice | `pending-object-built-per-use`, `write-back-buffer-built-per-iteration` (retargeted) | allocation | 1 each: `cb-write-back-allocations` (no value changes) |
| errno read before the C call | `darwin-errno-before-call` (audit/context-traits, lib/darwin.bot) | value (macOS) | the macOS run, section 30 (Milestone 1: `di-errno-allocator`, `di-errno-read-first`, `di-stdin`). A compiler never moves a call across another call; the order is the binding's, and the one binding that reads errno is Darwin's |
| errno read after an unrelated allocation | `allocation-after-c-call` (retargeted) | window | 23, among them `cb-nir-read`, `cb-nir-write`, `cb-allocations`, `cb-exposure-after-arguments-nir` |
| a large unsigned failure taken for a positive count | `large-unsigned-masked-positive` (codegen::clif) | value | 6: `ec-escapes-values`, `ec-word-comparisons`, `ec-modes-executables`, `ec-modes-positive-control`, `bb-read-sizes`, `bb-read-zero-and-high-bytes` |
| an untagged C scalar leaked into an ordinary value | `word-leaks-untagged` (codegen::clif) | value | 17, among them `bb-read-sizes`, `bb-read-address`, `bb-gc-stress`, `bb-coroutines` |

The window mutants survive the borrowing fuzzer, as they should: it
compares values and buffers, which those mutants leave as they are (they
only move allocations); the structural detectors and the errno-changing
allocator kill them.

The runs (Linux x86-64, this container, 9e38f24's tree; the borrowing
harness in lanes of a few mutants, each lane its own private trees; the
mutants that predate this milestone and mutate nothing it changed --
contracts, admission, the Tcl exposure model -- against
tests/c-pointer-borrowing.test and tests/c-byte-borrowing.test, the rest
against all three default detector files and the fuzzer):

| harness | mutants | killed | survived | skipped | not applied / not built |
|---|---:|---:|---:|---:|---:|
| `audit/c-pointer-borrowing/tools/mutate.tcl` (all) | 56 | 55 | 0 | 1 (`apple-exposure-tagged`: macos-aarch64 only) | 0 / 0 |
| `audit/c-ffi/tools/mutate.tcl`, the six of native/lower.tcl's foreign-call lowering | 6 | 6 | 0 | 0 | 0 / 0 |
| `audit/error-payloads/tools/mutate.tcl`, its six of native/lower.tcl (`PayloadFields` changed: `native-small-payload-boxes` retargeted) | 6 | 6 | 0 | 0 | 0 / 0 |
| `audit/abi-bytes/tools/mutate.tcl -only no-keepalive` | 1 | 1 (10 liveness tests) | 0 | 0 | 0 / 0 |
| `audit/mutable-bytes/tools/mutate.tcl -only no-keepalive` | 1 | 1 (10 liveness tests) | 0 | 0 | 0 / 0 |
| `audit/c-pointer-borrowing/tools/mutate.tcl` on macOS (`c-borrow-mutants=`: the four codegen word mutants and `apple-exposure-tagged`, run 39738749211; the other fourteen of this milestone's eighteen, run 39760256834) | 19 | 19 | 0 | 0 | 0 / 0 |
| `audit/context-traits/tools/mutate.tcl -only darwin-*` on macOS (`darwin-io-mutants`, run 39738749211) | 20 | 20 | 0 | 0 | 0 / 0 |

The fuzzers, on the unmutated tree: `audit/c-ffi/tools/fuzz.tcl` (random
C signatures with every C integer result class, `long` and `unsigned long`
among them, so random 64-bit words through the new C words; seeds 1, 2, 3
and 9 under GC stress, 10 programs and 120 functions each): 0
disagreements; `audit/c-pointer-borrowing/tools/fuzz.tcl` (seeds 1 and 2,
and 9 under GC stress, 15 programs each): 0 disagreements.

Every mutant of the other campaigns that mutates a file this milestone
changed (affine, binary-layout, bounds-proofs, branch-form-boolean,
c-abi-types, c-float-ffi, coroutines, enums, layout-arrays, layout-unions,
list-length-refinement, mutable-array, native-aot, native-edit,
native-view, target-model, type-predicates) still applies exactly once.

## 26. Allocation counts

Heap objects of one call, in process (bench/c-ffi-error-capture.tcl's
`allocations` part: the borrow fixture's write exposure, Bytes /
MutableBytes / Struct / List beside the loop without the call; the one
MutableBytes is the private copy, which the value semantics require):

| shape | default before -> after | `-struct-opt 0` before -> after | `-specialize 0` before -> after | both before -> after |
|---|---|---|---|---|
| discarded (`fill(m, 0, 0)` as a statement) | `0 1 0 0` -> `0 1 0 0` | `0 1 2 0` -> `0 1 0 0` | `0 1 0 0` -> `0 1 0 0` | `0 1 2 0` -> `0 1 0 0` |
| the C result alone | `0 1 0 0` -> `0 1 0 0` | `0 1 2 0` -> `0 1 0 0` | `0 1 0 0` -> `0 1 0 0` | `0 1 2 0` -> `0 1 0 0` |
| the result and the buffer | `0 1 1 0` -> `0 1 1 0` | `0 1 3 0` -> `0 1 2 0` | `0 1 2 0` -> `0 1 2 0` | `0 1 3 0` -> `0 1 2 0` |
| returned unread, its buffer read by the caller | `0 1 1 0` -> `0 1 1 0` | `0 1 3 0` -> `0 1 3 0` | `0 1 3 0` -> `0 1 3 0` | `0 1 3 0` -> `0 1 3 0` |
| detach of 64 KiB, discarded | `0 1 0 0` -> `0 1 0 0` | `0 1 2 0` -> `0 1 0 0` | `0 1 0 0` -> `0 1 0 0` | `0 1 2 0` -> `0 1 0 0` |

The remaining Structs are uses' own: the MutableBytes a use reads whole
(`mutable_length(r.output)`), `mutable_length`'s `abi::Usize` result, an
ordinary struct with scalar replacement off, and the return of a value
nobody read (outside the guarantee). `cb-write-back-allocations` pins the
same counts for its five shapes; before the protected window the counts are
zero in every mode (the NIR window holds no allocating instruction,
section 15, and the `errno` part's `before` column, section 27).

Per call, the executables of the `errno` part (real C) have, in the
wrapper, the allocating instructions its uses ask for after the read
(`sites`: `cwbox` of a large result returned in a List, the closure and the
value it captures, the List and the value stored in it) and none in the
window, in every mode; with the fault the write-back shapes' windows hold
two or three (the eager struct and MutableBytes), and the 64-bit results'
boxing is inside the call (the `helpers` column).

## 27. Performance

This is a correctness milestone; the measurements look for regressions.
bench/c-ffi-error-capture.tcl, both trees on one machine (`-baseline-rev
e2ae884` on macOS; `-root` a checkout of e2ae884 locally).

**Instructions per call** (`-instructions 1`: callgrind, 2000 calls minus
the empty loop; they repeat within about 1-2%, where a shared machine
scatters times by a factor of two). The `errno` part's executables -- real C (tests/cffi/fixture.c),
the wrapper, its C call, its errno read and the loop -- Linux x86-64,
e2ae884 -> this milestone:

| shape | default | `-struct-opt 0` | `-specialize 0` | both |
|---|---:|---:|---:|---:|
| small signed sentinel (`long` -1) | 283 -> 269 | 283 -> 271 | 283 -> 271 | 283 -> 271 |
| `(size_t)-1` | 913 -> 260 | 913 -> 262 | 913 -> 262 | 913 -> 262 |
| large successful result (2^64 - 1 kept) | 1824 -> 1674 | 1823 -> 1675 | 1823 -> 1675 | 1823 -> 1675 |
| write-back status only | 1254 -> 1240 | 4470 -> 2145 | 2156 -> 2145 | 4470 -> 2145 |
| write-back status and buffer | 2197 -> 2182 | 4913 -> 4504 | 4517 -> 4504 | 4913 -> 4504 |
| captured by a closure after the read | 4859 -> 4848 | 5754 -> 5743 | 5754 -> 5743 | 5754 -> 5743 |
| stored in a List after the read | 4473 -> 4464 | 4872 -> 4865 | 4873 -> 4865 | 4872 -> 4865 |

Every shape executes fewer instructions in every mode. `(size_t)-1` loses
the BigInt (`rt_ffi_box_u64`, its `malloc` and `free`) and the comparison's
two BigInt copies (the eager fault, which keeps the boxing but has the
copy-free `rt_int_cmp`, counts 834: the copies were about 80 of the 650); the large successful result keeps its BigInt (the List
needs the Int) but loses the copies. With scalar replacement off the
write-back value is no longer built at the call. The captured and stored
shapes do the same work as before -- the value is built for the closure or
the List -- after the read instead of before it.

The in-process shapes (the borrow fixture's write exposure, Milestone 1's
`shapes`; the driver's JIT run under callgrind):

| shape | default | `-struct-opt 0` | `-specialize 0` | both |
|---|---:|---:|---:|---:|
| discarded | 1142 -> 1142 | 3488 -> 1189 | 1183 -> 1188 | 3477 -> 1176 |
| the C result alone (`unsigned long`) | 1371 -> 1380 | 3824 -> 1380 | 1486 -> 1510 | 3818 -> 1376 |
| the result and the buffer | 3266 -> 3265 | 5788 -> 4530 | 4517 -> 4522 | 5748 -> 4527 |
| returned unread, read by the caller | 3010 -> 3012 | 5404 -> 5404 | 5390 -> 5397 | 5392 -> 5401 |

Where scalar replacement already applied the counts are equal within 2%,
which is also how much two counts of one tree differ between runs (this
tree's `result` counted 1380 here and 1372 in the benchmark's own
`-instructions 1` run); where it did not, a third
to two thirds fewer.

**Time per call.** The container's times scatter by a factor of up to two
between runs of the same tree (four runs of the `shapes` part gave
e2ae884's `discarded` 64.8, 38.2, 69.9 and 103.2 ns), so they are no
regression signal here; the counts above are. macOS (run 39738749211, one `macos-15` runner,
best of five processes of 100,000 calls, minus the empty loop), e2ae884 ->
this milestone, ns:

| shape | default | `-struct-opt 0` | `-specialize 0` | both |
|---|---:|---:|---:|---:|
| small signed sentinel | -1.9 -> 7.7 | 22.2 -> 12.4 | 23.4 -> 26.2 | 16.5 -> 49.3 |
| `(size_t)-1` | 50.1 -> 20.7 | 78.3 -> 7.5 | 73.5 -> 27.7 | 125.7 -> 32.6 |
| large successful result | 92.3 -> 149.5 | 94.0 -> 106.5 | 126.4 -> 120.6 | 133.6 -> 113.8 |
| write-back status only | 26.1 -> 72.0 | 202.9 -> 112.6 | 167.2 -> 112.2 | 232.2 -> 119.0 |
| status and buffer | 86.1 -> 146.1 | 292.4 -> 219.2 | 279.4 -> 236.0 | 354.9 -> 259.4 |
| captured after the read | 294.7 -> 304.9 | 375.8 -> 283.3 | 345.3 -> 325.3 | 440.3 -> 409.6 |
| stored in a List after the read | 221.2 -> 215.3 | 272.2 -> 239.1 | 291.6 -> 338.6 | 448.6 -> 251.9 |

These are differences of a few milliseconds per executable run, inside a
process start's own variance (the empty-loop subtraction makes one time
negative), and they go both ways: the default write-back status reads
26.1 -> 72.0 ns where its instruction count fell 1254 -> 1240, and the
eager fault on the same runner reads 9.5, 57.0, 101.4, 167.2, 285.0, 319.1
and 326.9 ns for the seven shapes. The in-process shapes on macOS: discarded 39.0 -> 37.3, result
28.5 -> 36.3, both 83.8 -> 102.2, returned 98.3 -> 87.8, detach of 64 KiB
1984 -> 2414 ns -- the detach being the private copy, which the milestone
does not touch, the scatter is the runner's. `read(2)`: 619.6 -> 588.2
(64 bytes), 314.9 -> 360.0 (EBADF), 5909 -> 6502 (64 KiB).

**Per shape and mode** (both machines, the `errno` part): the protected
window's hazards (`before`) and the calls on any path of its machine code
(`helpers`):

| | e2ae884 | this milestone | the fault |
|---|---|---|---|
| `before`, write-back shapes, default | 0, but 3 when captured | 0 | 2 or 3 |
| `before`, write-back shapes, `-struct-opt 0` / both | 3 | 0 | 2 or 3 |
| `helpers`, every shape, every mode | `rt_ffi_box_i64`/`_u64`, `rt_int_cmp` (+ `rt_struct_new`) | none | as e2ae884 |
| GC stress (the executable's output) | same | same | same |

The detached copy remains (one MutableBytes per call: section 26), and
large values are boxed whenever a use needs the Int: no BigInt work was
optimized away beyond the comparison's copies.

## 28. Linux x86-64 CI

Locally (Linux x86-64, a 4-core container):

* `tclsh9.0 tests/local.tcl` (every Tcl test file on interp and compile,
  every golden suite on all four backends through the front-end cache):
  6,668 and 6,607 tests passed, 1 failed on each Tcl backend --
  `tests/numeric-looking-names.test`'s source rule (two `expr {... ? ...
  : ...}` the new lowering had selected strings with; rewritten as `if`, the
  file passes) -- and all 101 golden suites passed on all four backends.
* Under `BOTLISH_NATIVE_GC_STRESS=1`: c-ffi-error-capture (27), c-pointer-
  borrowing (62), c-byte-borrowing (19 + 1 skipped: `guardMalloc` is
  macOS's), c-ffi (109 + 3 skipped: BoringSSL 2, `appleAvailability`),
  coroutines (81), affine (48), abi-bytes (73), abi-mutable-bytes (76),
  value-transport (64), struct-scalar-replacement (84), virtual-construction
  (51), struct-destructuring (263), c-float-ffi (37), variadics (58),
  native-view (39), native-edit (55): no failure.
* `cargo test --release --manifest-path native/Cargo.toml --lib`: 281
  passed, also under GC stress.
* Differential (the brief's "same programs, every policy"): every golden
  suite on cranelift and cranelift-generic with
  `BOTLISH_NATIVE_STRUCT_OPT=0`: 101 suites, 4,987 and 4,885 tests, no
  failure; with `BOTLISH_NATIVE_SPECIALIZE=0` and with both: 94 suites
  pass on both backends, and the 7 that exclude cranelift-generic for the
  generic lowering's known limit (NATIVE UNSUPPORTED struct-shape, STRUCTS.md
  "Known limitations": `destructuring-instances`, `methods-struct-instances`,
  ...) abort on cranelift the same way, as they do on e2ae884. Section 18's
  executables compare the four modes value for value.
* `tools/compilerpedia.tcl check`: 752 topics, 572 examples, no problem.

GitHub Actions, `.github/workflows/tests.yml` (dispatched on the branch):

| run | commit | result |
|---|---|---|
| [39736853106](https://github.com/mwagner-webdev/botlish/actions/runs/39736853106) | 188a58f | success: interp, compile, cranelift and cranelift-generic coverage, the native Rust unit tests, the stub-linked executables, golden shards 1-4, the warning gate, the method-call kind filter (the GC-stress job runs on pushes to main only; the GC-stress runs above cover it) |
| [39747067898](https://github.com/mwagner-webdev/botlish/actions/runs/39747067898) | 9e38f24 (the final code: later commits change the benchmark script and documents only) | success: the same jobs |

**Merged into main.** main moved twice while this ran, so the branch
merged it twice before going in: the Hashable trait (one conflict, nir.rs's
arity list, where its hash ops and `cwbox` are all one-operand ops) and
Windows x86-64 milestone 2 (two, AGENTS.md's run list and tier.tcl's check
list, both kept whole). On each merged tree: `tests/local.tcl`, every Tcl
test file on interp and compile and every golden suite on all four
backends, 0 failed; the Rust unit tests; the regenerated golden manifest
equal to the committed one; every mutant of every `mutants.txt` still
applying; `tools/compilerpedia.tcl check`. The transport changes the
committed Icy Tower executable (`audit/icy-tower/artifacts/icy-tower`,
rebuilt: 960,448 bytes on the final tree; main's own tree rebuilds the old
one byte for byte except its build ID), and with libSDL3.so present
tests/workload-icy-tower.test passes 15/15 with nothing skipped and the
oracle finds 0 differences. CI of the merges:

| run | commit | result |
|---|---|---|
| icy-tower [39768188992](https://github.com/mwagner-webdev/botlish/actions/runs/39768188992), [39777362200](https://github.com/mwagner-webdev/botlish/actions/runs/39777362200) | 68f19ef, 194d341 | success: build, tests, oracle, mutants, Xvfb |
| macOS [39769207256](https://github.com/mwagner-webdev/botlish/actions/runs/39769207256), [39777337389](https://github.com/mwagner-webdev/botlish/actions/runs/39777337389) | e23c4c5, 194d341 | success |
| Windows [39769207249](https://github.com/mwagner-webdev/botlish/actions/runs/39769207249), [39777337342](https://github.com/mwagner-webdev/botlish/actions/runs/39777337342) | e23c4c5, 194d341 | success |

## 29. Linux AArch64 CI

`.github/workflows/tests-arm64.yml` on GitHub's `ubuntu-24.04-arm` runners
(dispatched on the branch): the Tcl suite on interp and compile, its
cranelift and cranelift-generic coverage, the native Rust unit tests, the
golden suites in four shards and the GC-stress run.

| run | commit | result |
|---|---|---|
| [39736856392](https://github.com/mwagner-webdev/botlish/actions/runs/39736856392) | 188a58f | success, every job. The interp job: 8,839 tests, 8,718 passed, 121 skipped, 0 failed; no test skipped for `ecTrace`, `ecClobber`, `ecFixture` or `objdump`, so the AArch64 single-step traces (`ec-trace`, `ec-trace-large-sentinel`, `ec-trace-captured`), the errno-changing allocator over glibc (`ec-modes-executables`, `ec-modes-positive-control`), the object-file windows (`ec-modes-machine-windows` on AAPCS64 object code) and `ec-word-comparisons` (the unsigned conditions) ran and passed there |
| [39747072233](https://github.com/mwagner-webdev/botlish/actions/runs/39747072233) | 9e38f24 (the final code) | success, every job, the GC-stress run included (1 h 40 min) |

The AArch64 lowering adds nothing of its own: a word is an `i64`
Cranelift value whatever the ISA, the comparisons are Cranelift's
`icmp`, and AAPCS64's argument and return lowering is Cranelift's as
before (no Apple convention on Linux: `c_call_conv` is the triple's).

## 30. macOS AArch64 CI

GitHub's `macos-15` Apple Silicon runners, `.github/workflows/macos-arm64.yml`
(the shared development Mac was not used). The workflow cancels a branch's
running run when another starts, so the Tier C dispatches ran one after
another:

| run | commit | what | result |
|---|---|---|---|
| [39738749211](https://github.com/mwagner-webdev/botlish/actions/runs/39738749211) | 9e38f24 (dispatch) | smoke (the Rust unit tests, `c_word` and `ffi_word_cmp` among them); the acceptance tier's two shards (every test file, c-ffi-error-capture.test and darwin-io.test among them, and every golden suite on all four backends); Tier C: `c-borrow-mutants=` the four codegen word mutants and `apple-exposure-tagged`, `darwin-io-mutants`, `c-capture-bench` against e2ae884 | success: every job; mutants 5 of 5 and 20 of 20 killed (below); the benchmark in section 27 |
| [39752321962](https://github.com/mwagner-webdev/botlish/actions/runs/39752321962) | 4e15575 (dispatch) | Tier C under GC stress: c-ffi-error-capture.test, darwin-io.test, c-pointer-borrowing.test, c-byte-borrowing.test and coroutines.test on interp and compile (their native tests run the executables and the JIT with `BOTLISH_NATIVE_GC_STRESS=1`); smoke and acceptance again | Tier C: 218 tests per Tcl backend, 214 passed, 4 skipped (`ecTrace` 3: the ptrace traces are Linux's; `nativeLinux` 1), 0 failed -- so `ec-modes-executables`, `ec-modes-positive-control`, `ec-escapes-values`, `ec-modes-machine-windows`, `di-errno-allocator` (scalar replacement on and off, and the fault) and `bb-guard-malloc` passed under GC stress on Apple Silicon; smoke, both acceptance shards and the Linux control: success |
| [39760256834](https://github.com/mwagner-webdev/botlish/actions/runs/39760256834) | 84150f1 (dispatch; the code of 9e38f24) | Tier C: `c-borrow-mutants=` this milestone's fourteen Tcl-side mutants (the transport, captured, returned, generic and `-struct-opt 0` ones, the boxing and comparison ones, the pending-object and capture ones, and Milestone 1's five retargeted); smoke and acceptance again | success, every job: 14 of 14 killed on macos-aarch64 (1957 s), by the same detectors as on Linux (`ec-modes-nir-windows`, `ec-modes-machine-windows` on the Mach-O object, `ec-modes-executables` with the `DYLD_INSERT_LIBRARIES` allocator, `ec-boxed-results`, `cb-write-back-allocations`, ...) |

The mutants on macos-aarch64 (run 39738749211):

| mutant | killed by |
|---|---|
| `apple-exposure-tagged` | 26 tests, among them `bb-guard-malloc`, `bb-read-address-above-4gib` |
| `word-compare-wrong-signedness` | `ec-word-comparisons` |
| `word-truncated` | 13 tests, among them `bb-read-sizes`, `bb-guard-malloc` |
| `large-unsigned-masked-positive` | 6: `ec-escapes-values`, `ec-word-comparisons`, `ec-modes-executables`, `ec-modes-positive-control`, `bb-read-sizes`, `bb-read-zero-and-high-bytes` |
| `word-leaks-untagged` | 18 tests |
| the 20 `darwin-*` mutants of audit/context-traits | all killed; `darwin-errno-before-call` (errno read before the C call) by `di-errno-allocator`, `di-errno-read-first`, `di-stdin`; `darwin-errno-after-another-call` by 4 |

So on Apple Silicon: the new fixture's `(size_t)-1`, the signed and
unsigned word tables and the escapes program through Apple clang and
libSystem's errno (`__error`), the errno-changing `malloc` interposer,
`-struct-opt 0`, the generic lowering, the captured, escaping and nested
shapes, the Mach-O object windows (`ec-modes-machine-windows`), Darwin's
`read` with scalar replacement on and off and the fault, and Apple's
variadic and byte-borrowing behavior (c-ffi.test, c-byte-borrowing.test,
`apple-exposure-tagged`) all pass with the same `darwin::read` source.

## 31. Windows regression

The shared lowering is the same code on Windows. While this milestone was
developed, C calls were refused there (`C_CALLS`), so what Windows
validated was the shared compiler, never the foreign-error behavior;
WINDOWS-X86-64-MILESTONE-2.md, merged into main beside this milestone
(below), runs C calls on Windows:

* **Shared lowering, validated by the Windows tests**:
  `.github/workflows/windows-x86_64.yml` on the pushes of 9e38f24 --
  [39738732944](https://github.com/mwagner-webdev/botlish/actions/runs/39738732944)
  -- and 4e15575 --
  [39752302168](https://github.com/mwagner-webdev/botlish/actions/runs/39752302168):
  success, both, the smoke job (the Rust unit tests with the new `c_word` and
  `ffi_word_cmp` ones, native status, the COFF/PE facts, the GC workloads
  under GC stress with the fallback root plan, the 2048 executable) and the
  acceptance tier's four shards (every test file; c-ffi-error-capture.test's
  NIR tests compile their programs for linux-x86_64 and macos-aarch64 on
  the Windows host and pass; its executable tests need C calls and skip,
  and after the merge `posixErrno` too: the fixture runs POSIX's
  convention, which Windows' C runtime does not have).
  Words are `scalar_regs`, so the fallback root plan never shadows one.
* **C return-value transport, validated on Linux and macOS** (sections 28
  to 30).
* **Windows native foreign-error behavior: Windows milestone 2's.** On
  this branch no Windows program called C. WINDOWS-X86-64-MILESTONE-2.md's
  `windows::write_file` reads `GetLastError()` right after WriteFile with
  no new mechanism -- a `DWORD` is a 32-bit C scalar (no word) -- and
  `wi-last-error-read-first` pins its window; on the merged tree the
  Windows run below passes it. This milestone's own errno tests stay
  POSIX's (`posixErrno`).
* **The merged tree**: the Windows run of the merge with Windows milestone
  2, 194d341 --
  [39777337342](https://github.com/mwagner-webdev/botlish/actions/runs/39777337342):
  success, the smoke job (its Windows I/O step included) and the
  acceptance tier's four shards.

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
* **A loop's entry.** A deferred value a loop's body needs built is built
  once, at the loop's entry: a program whose loop body reads the errno of a
  C call made before the loop reads it after that build. Read the error
  state before the loop.
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
  call needed nothing more once C calls ran on Windows (Windows milestone
  2's `write_file` does it): the words, the deferral and the detectors are
  target-independent. A Windows `_errno()` binding and a Windows fixture
  for this milestone's tests remain undone.
* An inline `NativeView` load of a fixed-width field (no helper between
  `__errno_location` and the load).
