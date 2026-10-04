# Proof/fact repairs: G3, G1 and range↔completions drift tests

The first three follow-ups of PROOF-FACT-CENSUS.md §K, in the order they were
done: **G3** (counted-loop intervals in completions), **G1** (proven bounds
checks consumed by code generation), and **drift tests** between the two
analyses' local transfer rules. A surgical post-census milestone: the
architecture the census found coherent is untouched.

```
range  (hir/range.tcl, rangerec, induction)
    closed-world, per specialization instance      -> representation, native lowering
completions  (hir/completions.tcl)
    open-world body legality + exact-call re-walks -> error obligations, KNOWN-ERROR
```

The two stay separate (they answer different questions), the soundness fixes
S1–S3 are the baseline, and nothing here reopens the proof architecture:
legality still never depends on closed-world specialization facts, and code
generation never re-runs the completion proof. The repair is the census's
own: *the producer already proves the fact; retain and consume it.*

## 1. G3: the counted-loop interval, one theorem

**Before.** `hir/range.tcl` seeded a counted loop's induction variable with
`[START.min, END.max - 1]` (and the three other forms); completions recorded
only the relation `0 ≤ i < FORM`, so `loop i from 0 to 256: abi::u8(i)` and
`list::at([10, 20, 30], i - 1)` over `1..4` needed handlers although range
knew `[0, 255]` / `[1, 3]`. Because completion strength decides which
`errors` clauses a program must write, this was source friction, not just
missed optimization.

**Now.** `hir::range::InductionBinding START END DIRECTION ENDKIND`
(`hir/range.tcl`) is the one definition: `InductionSeed`'s interval
intersected with the binding's `Int` type fact. Range's countloop and
lockloop cases now call it, and so do `EvalCountloop` and `EvalLockloop` in
completions, over the START/END Ranges each walk already computed. Nothing
was copied; there is no second reading of the loop syntax.

* **Forms:** ascending/descending × exclusive/inclusive, and a lockstep
  numeric domain (list domains' element bindings stay unseeded, as in range).
  The lockstep cardinality solver was not touched.
* **Scoping:** the binding is restored with the other body-scoped state, so
  the interval never outlives the loop, and nested loops do not see each
  other's. The relational scoping rules of the earlier fixes are unchanged.
* **Empty loops (`from 5 to 5`, `from 10 to 0`):** range's authoritative
  behaviour is that a contradictory seed is *dropped* by `intersect`, leaving
  the plain Int type fact; it does not mark the body unreachable. Completions
  inherits exactly that, so the body of a statically empty loop is judged
  without a loop fact (an unproven access in it stays obligated). That is
  conservative and the same in both analyses; making empty bodies unreachable
  would be a new, separate decision for both.
* **Not done (G4):** the *relation* `0 ≤ i < FORM` for descending loops
  (`loop i down from list::length(xs) - 1 through 0`) is still missing; only
  the interval half is here. A descending loop over a literal List now works
  because the interval alone proves it.

`tests/proof-loop-intervals.test` (13 tests): every positive has its
off-by-one neighbours (both endpoints, both end kinds, both directions),
including bounds from immutable bindings and arithmetic, `mutable_array::at`/
`set`, slice bounds, lockstep, scoping, nesting, empty loops, a value run on
all four backends and a direct check of the shared helper. On the pre-change
tree 9 of 13 fail.

## 2. G1: consume the proof, per check

### What completions retains

`effectiveErrors` alone is not enough: `mutable_array::copy` checks two
slices that raise the *same* two declared errors, and a flat set cannot say
which slice an error comes from. So each bounds-bearing native call now also
carries a **per-check verdict**, `boundsVerdicts`, with one element per
registered bounds check in registration order (one for `index`, one per
slice for `slices`), each the declared errors *that check* may still produce
(`{}` = proven never to fail). It comes out of the same
`NativeEffectiveFacts`/`SliceFacts` computation that already decides
legality, from the registered `-bounds` metadata; no native is named. An
unproven check keeps the native's declared errors. Accessors:
`hir::completions::BoundsVerdictsOf`, `BoundsProven` (every check `{}`).

Four properties were designed in, not assumed:

1. **On the native call node, not the `handle`.** A handled call's stamp
   used to live on the `handle` node; lowering needs the call. A handler's
   presence is never the proof either way.
2. **Joined across walks.** A literal-List loop walks its body once per
   element, each under that element's facts. The old `effectiveErrors` stamp
   was last-write-wins, which is fine for diagnostics but would have let a
   later element's proof overwrite an earlier element's unproven check.
   Verdicts accumulate per check as a union (`NoteBounds`) and are written
   once at the end of `checkBlock`.
3. **Rebuilt, never merged.** `errorsets::verify` clears every verdict before
   it runs, because native preparation re-checks HIR that gained code.
4. **Unreached ≠ proven.** A node the walk never reaches has no verdict, and
   no verdict reads as "checked".

The verdict is open-world (parameters unconstrained, no caller facts), so it
holds in every specialization instance and every lowering of the node.

### What lowering does

```
PROVEN SAFE (every check of the call)   -> check-free operation
UNKNOWN (any check unproven)            -> the checked operation, unchanged
PROVEN FAILURE                          -> KNOWN-ERROR at compile time (unchanged)
```

| operation | proven form |
|---|---|
| `list::at` | `op listgetproven`: bare element load (no tag test, no comparison, no slow path) |
| `mutable_array::at` / `set` | `mutarraygetproven` / `mutarraysetproven` |
| `str::substring` (materialized) | `substrproven` |
| `str::substring` as a String region / short slice | **no op**: the `regioncheck` is omitted (its result was unused), so both the region and the ShortString paths benefit |
| `mutable_array::freeze` / `copy` | `mutarrayfreezeproven` / `mutarraycopyproven` |

The `*proven` opcodes follow the `setcontainstotal` precedent: sibling
opcodes outside `op_may_error`, selected per call node (`NativeCallOp`), so
the enclosing function also stops being "may error" and its callers drop
their completion checks. They allocate exactly like their checked forms
(`op_may_allocate`), keep every non-bounds behaviour (kind guards, metrics,
copy semantics, GC). Their runtime helpers index through safe Rust (and the
bulk `copy` keeps one internal assertion before its memmove), so a future
proof bug is a Rust abort, never an out-of-bounds access; only the inline
`listgetproven` is a bare load.
`-proven-bounds-opt 0` / `BOTLISH_NATIVE_PROVEN_BOUNDS_OPT=0` restores the
checked lowering everywhere, for differential testing.

The **Tcl compiler** sends a proven bounds-bearing native through its direct
native call instead of `core::runtime::callValue` (`CompileNativeCall`); a
handled or declared-but-unproven call still takes `callValue`, which is what
turns the error into completion code 5. The **interpreter** remains fully
checked: it is the reference executor, and its outcomes are what the other
backends are compared with. Runtime outcomes are identical on all four.

### Decisions, and what was left alone

* **Whole calls, not partial slices.** The verdict structure distinguishes
  `LowerUnderrun` from `UpperOverrun` and one slice from the other, and the
  tests pin that (`copy` with only one slice proven stays fully checked, as
  does `substring` with only `LowerUnderrun` ruled out). Lowering consumes a
  call only when *all* its checks are proven. A partly checked variant would
  not change what matters: these are single helper calls with one error exit,
  so the function stays "may error" and the skipped comparison is a few
  instructions in an out-of-line helper. If an inline slice fast path is ever
  added, the per-check verdicts are already there to select it.
* **`list::get` / `mutable_array::get` are untouched.** Their inner `at` sees
  an unconstrained index inside `get`'s own body, so it stays checked: a
  recorded frontier (the caller-side decision of STDLIB-NAMESPACES.md §12), pinned
  by a test, with no special `get` lowering or opcode.
* **No new source API.** `list::at` is still `errors IndexNotFound`; the
  distinction lives only in NIR.
* **Interpreter unchanged** (above); **G2** (`loop x in xs` reads) and
  **G4/G5** are separate.

### Evidence

`tests/proven-bounds.test` (24 tests):

* the verdict structure per operation, the two-slice `copy` separation, the
  per-element union (both orders), unreached nodes, declared signature
  unchanged;
* NIR per operation, proven vs unknown vs handled vs `errors`-declared,
  `-proven-bounds-opt 0`, region and short-slice forms, the
  `bench/refined-checks.bot` call sites, `get` as ordinary Botlish, CLIF
  without the comparison, and the function-fallibility effect;
* the Tcl compiler's code (no `callValue` for proven, `callValue` otherwise);
* values on interp / compile / cranelift-generic / cranelift for proven,
  unknown (failing and passing, handled) and KNOWN-ERROR programs.

Rust: `proven_helpers_agree_with_checked_ones_on_valid_bounds` exercises every
valid index and slice against the checked helpers. Differential over the 33
example and benchmark `.bot` programs: native output with and without the
optimization is identical (7 of them contain proven operations).

`bench/refined-checks.bot`, generated NIR: `regioncheck` 1 → 0, `substr` 2 → 0
(2 `substrproven`), `listget` 5 → 1 (4 `listgetproven`).

**Benchmarks** (native, in-process bench mode, JIT excluded, 2,000 runs per
sample, 7 interleaved base/new samples per program in one container while a
test suite was also running, so read the relative numbers, not the absolute
ones; `value` identical in every sample):

| program | before (median) | after (median) | |
|---|---:|---:|---|
| `refined-checks` | 621.5 µs | 470.8 µs | **−24%** |
| `fib` | 137.9 µs | 136.8 µs | no residue: within noise |
| `loop-count` | 1.07 µs | 1.06 µs | within noise |
| `sum-refined` | 0.74 µs | 0.73 µs | within noise |

The census measured about −9% (612 → 558 µs) from deleting *only* the one
redundant `regioncheck` by hand. The generic consumer recovers that and more,
because the same proofs also remove the two materializing `substr` checks and
four `listget` bounds paths on that workload. The other three core workloads
had no proof residue on their hot paths (census §A), so nothing was expected
there and nothing moved. The implementation is not specialised to the
benchmark: it reads each call's stamped verdict.

## 3. Drift tests: `tests/range-completions-crosscheck.test`

Both analyses run on the same function body under the same seed Ranges
(`hir::range::AnalyzeInstance` in verification mode and
`hir::completions::analyzeBlock`/`exprRangesOf`, a small inspection accessor
sharing `analyzeBlock`'s walk). Their whole-program results are not compared;
only what both implement with the same local theorem:

* **Targeted rules,** each against a theorem stated in the test, not derived
  from either implementation: literal, bind/ref, `+ - *` and bit operations,
  all four ordering comparisons (one and two bindings), branch join and
  result Range with early `return`, a source-defined domain, a struct
  projection's declared domain, collection-length metadata, and every
  counted-loop form (bounds from facts, lockstep, body scoping).
* **Compatibility rule at every shared node.** Both are sound
  over-approximations of the same values, so their Ranges must intersect
  (`disjoint`/`crossing` fail), and the documented intentional differences
  (`mod`'s bounded divisor, `char::scalar_value`, `and`/`or` conjunct
  narrowing) are checked to make completions only *narrower*.
* **Corpus sweep** over every function of `examples/{surface,stdlib,abi}` and
  `bench` with unconstrained parameters: 3,150 shared nodes; 3,051 equal;
  98 where completions is narrower (call-specific walks of exact callees,
  `and`/`or` conjuncts, `mod`, `char::scalar_value` and arithmetic on them,
  all by design); **0 disjoint, 0 crossing;** and range strictly narrower at
  exactly one node: `b - a` with `b = a + K` in `bench/loop-count.bot`, the
  census's known `DifferenceOffset` rule (precision only, out of scope). That
  node is an explicit allowlist entry, so any *new* "range knows more" fails
  the test: that is the shape of S1, the projection gap and G3.

The harness was checked by mutation: removing the countloop seed, the
`return` join, or the projection domain from completions fails 4, 1 and 2
tests respectively.

## 4. Validation

* `tests/all.tcl` on both Tcl backends (interp, compile), and again with
  `BOTLISH_NATIVE_GC_STRESS=1` (the CI `gc-stress` configuration): all 5,209
  tests pass in each. The one existing expectation that changed is
  `dormant-refined-checks-char-at-nir`, which pinned `char_at`'s
  `regioncheck`/`substr`: exactly the census example, now `substrproven`
  with no `regioncheck`.
* `cargo test --release` (155 + 28 tests).
* Native output over the 33 example/benchmark programs with the optimization
  on vs off: identical.
* `native/generate-scalar-audit.tcl`'s committed corpus is regenerated by CI
  on `main` and is not part of this change; its snapshot will show the same
  NIR differences as above.

## 5. Not done here

G2 (`loop x in xs` reads), G4 (descending relation), G5 (struct field values),
G6/G7/G9/G10, G11 (`and`/`or` in range) and `DifferenceOffset` in completions
are as the census left them. Partial slice lowering and a special `get` are
deliberately not part of this milestone (§2).
