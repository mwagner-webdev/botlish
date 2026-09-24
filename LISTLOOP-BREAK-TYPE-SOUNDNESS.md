# LISTLOOP-BREAK-TYPE-SOUNDNESS.md

Adversarial soundness audit of `loop x in EXPR:` (`listloop`)'s interaction
between `break VALUE`, ordinary List-collecting completion, declared
function results, and static result inference — requested before proceeding
to ASCII work.

## Outcome

**A — already sound.** No production code was changed. Only
`tests/loop-in.test` (regression tests) and this report, plus the
regression-count section of `BYTE-SET.md`, were touched.

## Adversarial test added first

Eight tests were added to `tests/loop-in.test` (23 → 31 cases) before any
conclusion was drawn, and run before inspecting whether a fix was needed:

- `loop-in-break-scalar-declared-result-rejected` — the primary adversarial
  case: `fn f(xs: List[int]) -> List[int]: loop x in xs: if x == 0: break
  123 \n x`, called with `f([1, 2])` so the branch is genuinely reachable
  (no range analysis can prove `x == 0` impossible for a broad
  `List[int]`). Asserts `surface::compile` raises `{CORE SEMANTIC TYPE}`
  with a "does not prove declared type" message.
- `loop-in-break-scalar-declared-result-rejected-diagnostic` — the same
  case built non-strict (`-strict 0`), inspecting the kept `TYPE`
  diagnostic directly, to confirm the rejection is produced during ordinary
  semantic verification (`hir::range::verifyDeclaredResults`, called
  unconditionally from `hir::hir.tcl` before any backend is selected), not
  merely a thrown-error side effect.
- `loop-in-break-list-declared-result-accepted` — the direct contrast: the
  same shape but `break [1, 2]` (a `List[int]` payload compatible with the
  declared result). Zero diagnostics.
- `loop-in-break-list-runtime-returns-payload` — runtime coverage for the
  compatible case: `f([5, 0, 9])` returns `[1, 2]` (the break payload), not
  `[5]` (the accumulated prefix before the break).
- `loop-in-break-list-runtime-parity` — the same runtime rule agrees on all
  four backends (interp/compile/cranelift-generic/cranelift).
- `loop-in-break-bare-declared-result-rejected` — bare `break` (loop value
  `unit`) is likewise incompatible with a declared `List[int]` result.
- `loop-in-break-scalar-undeclared-inferred-type` — with no declared
  result, the same incompatible-scalar-break listloop must not be inferred
  as the falsely-precise `List[int]`. Directly inspects the listloop
  expression's own static type (not just the function-result contract).
- `loop-in-no-break-still-precise` — a listloop with no break at all keeps
  its precise `List[R]` typing (the shape `byte::set`'s own `bytes` binding
  relies on), unaffected by the break-payload join.

## Observed pre-fix (and, as it turned out, final) behavior

Running `tclsh9.0 tests/loop-in.test` before touching any production file:
**31/31 passing.** Every adversarial case already behaved correctly:

| Case | Observed |
|---|---|
| `break 123` vs declared `List[int]` | rejected — `TYPE` diagnostic, "function result does not prove declared type List[int]" |
| `break [1, 2]` vs declared `List[int]` | accepted — 0 diagnostics |
| `f([5, 0, 9])` with the compatible break | returns `[1, 2]`, not `[5]` |
| bare `break` vs declared `List[int]` | rejected — same diagnostic |
| `break 123`, no declared result | listloop's own static type is `any` (not `List[int]`) |
| no break at all | listloop's own static type stays exactly `List[int]` |

## Semantic successful exits of listloop

1. Normal exhaustion → `List[R]`, `R` the per-iteration body's own type.
2. `break VALUE` → `type(VALUE)`.
3. Bare `break` → `unit`.

(`return` and a propagating checked-construction error are *nonlocal*
completions — they leave the listloop's own successful-value type
altogether; see below.)

## How ordinary exhaustion and break payload types are combined

No new listloop-specific mechanism exists, and none was needed. The
pre-existing `breakTypes`/`lub` machinery that a bare `loop:` already uses
for its own `break VALUE` typing is directly reused
(`hir/types.tcl`'s `Expr` proc, `listloop` case):

```tcl
dict set ctx breakTypes $e never
set bodyType [Sequence hir ctx [dict get $node body]]
set type [lub [dict get $ctx breakTypes $e] [MakeList $bodyType]]
```

Every reachable `break VALUE` inside the loop already lubs its payload's
type into `ctx breakTypes $e` (the `break` case of the same `Expr` proc,
shared verbatim with bare `loop:`). The only change a `listloop` needs
beyond bare `loop:`'s existing break-typing is seeding that same join with
one extra contribution: `MakeList($bodyType)`, the `List[R]` of the normal
per-iteration collection. Both contributions go through the identical
general-purpose `hir::types::lub` (the same join used for `if`/`else`
branches, block bodies, etc.) — no separate union type was invented.

For the incompatible case, `lub(int, List[int])` widens all the way to
`any`: `hir::types::lub` falls through its list-vs-list, set-vs-set, and
`IsSpecific` cases (an `int` and a `{list int}` don't share a kind) to
`core::type::lub`, whose `base(a) ne base(b) -> any` rule fires. That `any`
then fails `hir::range::verifyDeclaredResults`'s check against the declared
`List[int]` (`ProvesValueAcceptedBy` requires *exact* structural equality —
after `Unshaped` — for a declared List/Set type, and `any != {list int}`),
producing the `TYPE` diagnostic. For the compatible case,
`lub({list int {int int}}, {list int})` (the shaped break-literal type and
the plain collected-list type) unifies cleanly back to `{list int}`,
matching the declared type exactly.

## Incompatible scalar break case

`break 123` inside a `List[int]`-declared listloop, with the branch
reachable from a broad `List[int]` parameter (no range analysis trivializes
it away): **rejected at compile time**, before backend selection, as
`{CORE SEMANTIC TYPE}` / "function result does not prove declared type
List[int]".

## Compatible List break case

`break [1, 2]` inside the same shape: **accepted**, and at runtime
(`f([5, 0, 9])`) returns the break payload `[1, 2]` — not `[5]` — matching
the documented "break VALUE overrides the whole loop's result, discarding
the accumulator" rule. Parity-checked across all four backends.

## Bare break behavior

Bare `break` makes the loop's value `unit` (the pre-existing bare-`loop:`
rule, unchanged and unaudited-away here). A bare `break` reachable inside a
`List[int]`-declared listloop is therefore rejected exactly like the scalar
case, via the same mechanism.

## continue / return / error distinction

- `continue`'s `Expr` case always returns `never` and never touches
  `breakTypes` or feeds the body's `Sequence` result — an iteration it
  applies to contributes nothing, exactly as before this audit. (Existing
  `loop-in-continue-skips`/`loop-in-continue-parity` already pin this at
  the runtime level; unchanged.)
- `return`'s `Expr` case also always yields `never` for the return
  expression itself; its value instead accumulates separately into `ctx
  returnType` (the enclosing function's own return-based result), entirely
  disjoint from a listloop's `breakTypes`. `ok`/`error` similarly produce a
  `result` type, never folded into `breakTypes`.

Neither is part of the successful-value type join computed for a listloop.

## byte::set regression

`lib/byte.bot` was not touched. `byte::set` contains no `break` anywhere in
its `bytes = loop c in chars: Byte(char::codepoint(c))`, so `ctx
breakTypes` for that loop stays `never` throughout, and `lub(never,
List[Byte])` returns `List[Byte]` unchanged (the `$a eq "never"` fast path
in `hir::types::lub`) — exactly as before this audit. Pinned generically by
the new `loop-in-no-break-still-precise` regression (same no-break shape,
without depending on `byte::set` itself).

## Backend parity

No production code changed, so no backend-parity risk was introduced. The
one new runtime-behavior case (compatible List break payload) was still
parity-checked across all four backends
(`loop-in-break-list-runtime-parity`) for direct confidence, alongside the
pre-existing `loop-in-break-parity` (scalar break) already covering the
override-and-discard runtime rule generically.

## Full regression / GC stress

```
tclsh9.0 tests/all.tcl                                (interp + compile)
cargo test --release --manifest-path native/Cargo.toml
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl
```

- `tclsh9.0 tests/all.tcl`: **2016/2016 passing, 0 failed** on each backend
  (69 test files, 0 skipped) — the pre-existing 2008 (`BYTE-SET.md`'s own
  prior final count) + 8 new adversarial tests added here.
- `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passing**, unchanged (no Rust source touched).
- `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **2016/2016 passing,
  0 failed** on each backend, run in isolation (a prior concurrent run
  alongside the ordinary suite produced two spurious, CPU-contention-caused
  failures in unrelated exhaustive native-byte tests, `native-byte-
  normalization-exhaustive`/`native-byte-complement-exhaustive`; re-run
  alone, both pass, confirming the earlier failures were resource
  contention, not a regression) — no rooting/allocation-behavior regression
  from these tests.

## Production diff

None. `tests/loop-in.test` (+8 tests), `BYTE-SET.md` (regression-count
update), and this report are the only changes.

## Architecture questions

1. **Before any production change, did the adversarial scalar-break test
   pass or fail?** It passed — the compiler already rejects
   `break 123` against a declared `List[int]` result.
2. **What static type did the listloop receive before the fix, if there
   was a bug?** No bug existed. For the record, the incompatible case's
   listloop is statically typed `any` (verified directly by
   `loop-in-break-scalar-undeclared-inferred-type`) — conservative, not
   falsely precise.
3. **All successful value-producing exits from listloop:** normal
   exhaustion (`List[R]`), `break VALUE` (`type(VALUE)`), bare `break`
   (`unit`).
4. **How are ordinary exhaustion and break payload types combined?** Via
   the pre-existing `hir::types::lub` join, seeded with both
   `MakeList(bodyType)` and the loop's accumulated `breakTypes` — the same
   join bare `loop:` already used for its own break typing; no new
   union-type mechanism.
5. **Does `continue` contribute a value?** No.
6. **Are `return` and Error part of the successful-value type join?** No.
7. **Does a loop with no break retain precise `List[R]` typing?** Yes.
8. **Does `byte::set` remain unchanged and still infer `List[Byte]` for
   `bytes`?** Yes.
