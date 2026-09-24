# UnicodeChar module retention: closing the ImmutableSet[T] integration gap

## Outcome

`hir::modulebinding::ImmutableExpr`'s `const` case now recognizes
`UnicodeChar` as an immutable scalar leaf, alongside the existing `int`,
`str`, `bool`, and `unit` literal kinds. This closes the one integration
gap MINIMAL-IMMUTABLE-SET.md's own report left behind: a module-scope
`List[UnicodeChar]` literal, and any `ImmutableSet[UnicodeChar]` built from
it via `immutable_set_from_list`, can now be retained as a module value the
same way the equivalent `int`/`str`/`bool` constructions already were. The
canonical target shape from the milestone brief,

```botlish
additional_unreserved_chars =
    byte::set(['-', '.', '_', '~'])
```

is no longer blocked on the UnicodeChar side of this gap (`byte::set`
itself remains a later milestone).

## Root cause of the retention gap

1. **Why did UnicodeChar previously fail module-retention proof?**
   `hir::modulebinding::ImmutableExpr`'s `const` case matched
   `core::value::kind` against an explicit whitelist, `{int str bool
   unit}`. A `UnicodeChar` literal's runtime kind is the distinct string
   `UnicodeChar` (`core/value.tcl`'s `kinds` list), which was never in that
   whitelist, so every `const UnicodeChar ...` HIR node fell through to the
   `default` branch and failed with `"literal value kind UnicodeChar"`.
2. **What exact code path was missing UnicodeChar?** `hir/modulebinding.tcl`,
   `ImmutableExpr`'s `const` case (previously lines 168-174). Nothing else:
   `ContextExpr` (the separate context-freedom proof) already accepts any
   `const` node unconditionally, and `List`/`ImmutableSet` construction
   proofs (`ImmutableNative`'s `list` and `immutable_set_from_list` cases)
   already forward whatever per-element proof their arguments produced --
   they never special-cased which scalar kinds were legal, only whether an
   argument's proof succeeded at all.
3. **Is UnicodeChar now handled as its own immutable scalar kind?** Yes --
   `{int str bool unit UnicodeChar}`, one added kind name, same structural
   proof shape (`{scalar UnicodeChar}`) as the other four.
4. **Was UnicodeChar converted/reinterpreted as Int or String for
   retention?** No. The proof records `[list scalar $kind]` where `$kind`
   is `core::value::kind`'s own answer (`UnicodeChar`, verbatim) -- never
   coerced to `int` or `str`.
5. **Did List[UnicodeChar] require any List-specific change?** No.
   `ImmutableNative`'s `list` case already just collects whatever proof
   each element expression produced; once a `const UnicodeChar` element
   proves immutable on its own, the containing `list(...)` call does too,
   with zero additional code.
6. **Did ImmutableSet[UnicodeChar] require any set-specific change beyond
   the already-existing generic proof?** No. `immutable_set_from_list`'s
   proof (added by the ImmutableSet milestone) only requires its source
   List argument to have structurally proven as `list`; it forwards that
   List's element proofs unchanged. It needed no UnicodeChar-awareness of
   its own.

## The one-line fix

```diff
         const {
             set kind [core::value::kind [dict get $node value]]
-            if {$kind in {int str bool unit}} {
+            if {$kind in {int str bool unit UnicodeChar}} {
                 return [list ok [list scalar $kind]]
             }
             return [list bad unknown "literal value kind $kind"]
         }
```

### Audit: could the whitelist be replaced by a generic query instead?

Per the brief's item 4, the full set of `core::value::kind` answers
(`core/value.tcl`'s `kinds` variable) was audited before making this
change: `int str bool unit list result block native mutarray UnicodeChar
immutableSet`. Cross-checked against `surface/lower.tcl`, the only kinds
that a HIR `const` node's `value` payload can ever actually hold are `int`,
`str`, `bool`, and `UnicodeChar` (literal syntax productions), plus `unit`
(synthesized by other HIR-building code, e.g. for an empty block result).
The other five kinds (`list`, `result`, `block`, `native`, `mutarray`,
`immutableSet`) are never literal payloads -- they only ever arise from
runtime construction, which `const` nodes do not represent. So a generic
"is this literal kind immutable" query would, for `const` nodes
specifically, evaluate to exactly the same five-kind whitelist this fix
already uses; replacing the explicit list with a lookup table keyed the
same way is not meaningfully smaller, and invites exactly the "broaden
acceptance to a kind with reference semantics" risk the brief warns
against (`mutarray` in particular has reference semantics and must never
be treated as an immutable leaf, whether or not it could reach a `const`
node in practice). The one-line whitelist addition was kept as the
minimal, auditable change.

## Direct UnicodeChar retention

```botlish
dash = '-'

fn get_dash() -> UnicodeChar:
    dash
```

`dash` now passes both of `hir::modulebinding::validate`'s proofs
(context-free, structurally immutable) and is retained as a module value;
`get_dash()` returns the same retained value on every call, never
reconstructing it (a UnicodeChar literal is already immediate/non-
allocating, so "retained" here means the module-initialization value slot
holds it once, not that any new allocation is avoided that wasn't already
avoided).

Pinned: `set-module-retained-value-unicodechar-direct`
(`tests/immutable-set.test`) -- zero diagnostics, `get_dash()` returns
`'-'`.

## List[UnicodeChar] retention

```botlish
chars = ['-', '.', '_', '~']

fn first() -> UnicodeChar:
    list_get(chars, 0)
```

`chars` infers `List[UnicodeChar]` (unchanged List inference) and is now
retained as a module value, exactly as `set-module-retained-value`'s
existing `int`-element List already was. No List-specific code changed;
this fell out once `const UnicodeChar` proves immutable, because
`ImmutableNative`'s `list` case was already generic over its elements'
proofs.

Pinned: `set-module-retained-value-unicodechar-list`
(`tests/immutable-set.test`) -- one `listnew` op in the lowered NIR, one
allocation-report site under the module file, `first()` returns `'-'`.

## ImmutableSet[UnicodeChar] retention

```botlish
chars =
    immutable_set_from_list(['-', '.', '_', '~'])

fn has_dash() -> Bool:
    immutable_set_contains(chars, '-')
```

`chars` infers `ImmutableSet[UnicodeChar]` and is now retained as a module
value through the existing (unmodified) `immutable_set_from_list`
modulebinding proof from the ImmutableSet milestone, since that proof only
required its source List argument to be structurally known -- which it now
is.

Pinned: `set-module-retained-value-unicodechar`
(`tests/immutable-set.test`) -- one `setfromlist` op in the lowered NIR,
one allocation-report site under the module file, `has_dash()` returns
`true` on repeated calls (`[constants::has_dash(), constants::has_dash()]`
-> `[true, true]`).

## Allocation/reuse evidence

All three payloads above use the same methodology as the pre-existing
`set-module-retained-value` test: lower the program to native IR, count
`op listnew`/`op setfromlist` occurrences in the emitted text (proving the
construction is emitted exactly once, at module scope, not once per call
site), and separately confirm via `native::allocationReport`'s per-site
`allocations` count, filtered to sites whose source location is the module
file, that exactly one construction actually runs. For the
`ImmutableSet[UnicodeChar]` case, calling `has_dash()` twice from `main.bot`
and observing a single `setfromlist` site with `allocations` = 1 is direct
evidence the set is built once at module startup and reused thereafter,
not reconstructed per call.

## Why no runtime changes were needed

`UnicodeChar`'s native representation (`(codepoint << 3) | 0b100`,
immediate, non-GC), `ImmutableSet`'s runtime representation, and List's
runtime representation are all unchanged and untouched by this milestone.
This was purely a static-analysis gap in one HIR pass
(`hir::modulebinding::ImmutableExpr`): the runtime already correctly
constructs and retains any List/ImmutableSet once module initialization
code actually executes it exactly once; the pass just refused to *permit*
module-scope UnicodeChar-involving code to be treated as safe to retain
in the first place. No `core/*.tcl`, `native/src/**`, `native/lower.tcl`,
`surface/parser.tcl`, or `surface/lexer.tcl` file changed.

## ImmutableSet membership contract correction

`MINIMAL-IMMUTABLE-SET.md` previously described `immutable_set_contains`
in several places as "total membership... never an Error completion" and
"an ordinary total `Bool` query." That overstated the actual contract:
construction and membership both dedup/compare via ordinary Botlish value
equality (`core::value::equal`/`rt_value_eq`), and that equality relation
is itself undefined for some runtime kinds (Block, Native, MutableArray;
already pinned unmodified by `set-shallow-immutability-multi-block-
members-equality-undefined`). When determining membership actually
requires comparing against one of those kinds, the pre-existing `EQUALITY`
failure propagates -- it does not turn into `false`, and it is not a new
failure mode invented for this milestone.

The corrected rule, now reflected in the report's wording (no runtime
behavior changed):

- For an equality-comparable value, membership returns `Bool`.
- For an absent equality-comparable value, membership returns `false`.
- If ordinary Botlish equality is itself undefined for a comparison
  membership actually requires, the existing `EQUALITY` failure
  propagates.

Cross-kind comparisons (e.g. `contains({'A'}, 65)`, a UnicodeChar set
queried with an Int) remain ordinary `false`, not `TYPE` or `EQUALITY` --
UnicodeChar and Int are both ordinarily comparable kinds that are simply
never equal to each other. This was already correctly implemented and
tested; only the report's wording overstated unconditional totality.

Three sentences in `MINIMAL-IMMUTABLE-SET.md` were corrected in place (the
`Outcome` summary, the "Membership semantics" section's opening sentence,
and the "Stop condition" section's closing summary) to state the
equality-undefined exception explicitly rather than claiming unconditional
totality. No other wording in that report changed, since the "Membership
semantics" section's later paragraphs already documented the
Block/Native/MutableArray exception correctly -- only the oversimplified
summary sentences needed fixing.

## Tests

`tests/immutable-set.test` (extended, no other test file touched):

- `set-module-retained-value-unicodechar-direct` -- direct `dash = '-'`
  module retention (spec item 24).
- `set-module-retained-value-unicodechar-list` -- `List[UnicodeChar]`
  module retention with allocation-site evidence (spec item 25).
- `set-module-retained-value-unicodechar` -- `ImmutableSet[UnicodeChar]`
  module retention with allocation-site evidence, replacing the old
  `set-module-retained-value-unicodechar-limitation` fixture that pinned
  this exact gap as an expected-to-change limitation (spec item 26).

The following pre-existing tests already cover the remaining required
cases and needed no change:

- `set-membership-char-absent` -- `contains({'A','B'}, 'C')` -> `false`.
- `set-equality-char-vs-int` -- `set(['A']) == set([65])` -> `false`
  (distinct comparable kinds).
- `set-shallow-immutability-multi-block-members-equality-undefined` --
  membership/construction propagates the pre-existing `EQUALITY` failure
  when a required comparison is undefined.
- `surface-modules-context-dependent-initializer-rejected-transitively` /
  `surface-modules-mutable-retained-values-rejected` -- the required
  negative context-free/mutability regression fixtures; unaffected by this
  change (their rejected constructs involve native calls and
  `MutableArray`, never a `const` node).

## Full regression / GC stress

- `tclsh9.0 tests/all.tcl`: **1962/1962 passing**, 67 test files, 0
  skipped, 0 failed.
- `cargo test --release --manifest-path native/Cargo.toml`: **60/60
  passing**.
- `BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 tests/all.tcl`: **1962/1962
  passing**, 67 test files, 0 skipped, 0 failed -- exactly matching the
  ordinary run.

## Production diff

```
hir/modulebinding.tcl     | 2 +-
tests/immutable-set.test  | ~100 lines (three new tests replacing one)
MINIMAL-IMMUTABLE-SET.md  | wording corrections only, no semantic change
```

No changes to `native/**`, `core/immutableset.tcl`, `core/unicodechar.tcl`,
`core/value.tcl`, `hir/types.tcl`, `native/lower.tcl`, `surface/**`. The
diff is exactly as narrow as the milestone brief expects.

## Deferred (unchanged scope)

`byte::set`, checked `UnicodeChar -> Byte` conversion, ASCII
classification (`ascii::is_digit`/etc.), and URI/`web::is_unreserved`
changes were **not** started here. This milestone only removes the
UnicodeChar module-retention blocker so that `byte::set`'s own future
canonical module-level use case will be retainable immediately once that
native lands.

## Acceptance table

| Expression / condition | Result |
|---|---|
| `module dash = '-'` | retained |
| `module chars = ['-', '.', '_', '~']` | retained `List[UnicodeChar]` |
| `module chars = immutable_set_from_list(['-', '.', '_', '~'])` | retained `ImmutableSet[UnicodeChar]` |
| repeated read of retained set (`has_dash()` called twice) | no repeated `setfromlist` construction |
| `contains(set(['A']), 'B')` | `false` |
| `contains(set(['A']), 65)` | `false` |
| membership requiring undefined ordinary equality (Block/Native/MutableArray) | existing `EQUALITY` failure propagates |
| effectful/context-dependent module expression (e.g. `mutable_array_capacity(...)`) | still not retainable (`MODULE-CONTEXT`) |
| module `MutableArray` value, direct or nested in a List | still not retainable (`MODULE-IMMUTABLE`) |

## Required architecture/equality/scope questions

See "Root cause of the retention gap" above for questions 1-8 (all
answered as expected by the brief: UnicodeChar handled as its own scalar
kind, not coerced to Int/String; no List- or set-specific change; built
once and reused; no runtime representation change).

9. **Is ImmutableSet membership literally total over every Botlish
   value?** No -- ordinary equality itself is undefined for some kinds
   (Block/Native/MutableArray).
10. **What happens for an absent ordinary comparable value?** `false`.
11. **What happens when determining membership requires an undefined
    ordinary equality comparison?** The pre-existing `EQUALITY` failure
    propagates.
12. **Was set-specific equality invented?** No.
13. **Was an Eq/typeclass/capability system added?** No.
14. **Were Blocks/Native/MutableArray statically forbidden as set
    elements?** No.
15. **Was `byte::set` added?** No.
16. **Was Byte conversion added?** No.
17. **Was ASCII added?** No.
18. **Was URI logic changed?** No.
19. **Was hashing added?** No.
20. **Was a bitmap added?** No.
21. **Was perfect hashing added?** No.
22. **Was compile-time set lowering added?** No.
23. **Was predicate refinement added?** No.
24. **Was equality redesigned?** No.

## Stop condition

1. UnicodeChar constants participate in module structural-immutability
   proofs exactly like the other immutable scalar literal kinds. ✓
2. `List[UnicodeChar]` built entirely from literals can be retained at
   module scope through existing generic List proof machinery. ✓
3. `ImmutableSet[UnicodeChar]` built from such a List can be retained
   through the already-existing `immutable_set_from_list` proof. ✓
4. The intended shape (`additional_unreserved_chars = <future
   byte::set>(['-', '.', '_', '~'])`) is no longer blocked by UnicodeChar
   module-retention semantics. ✓
5. ImmutableSet documentation no longer falsely claims unconditional
   membership totality. ✓
6. No runtime representation, set representation, hashing, Byte
   conversion, ASCII, or URI work was added. ✓
