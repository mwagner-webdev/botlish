# Scalar machine-code quality audit: bench/ + examples/stdlib/

A diagnostic-only audit of the native (Cranelift) backend's scalar code
quality, run across the entire existing corpus (every `bench/*.ir` program
and every `examples/stdlib/*.bot` program) after four prior optimization
milestones (F1 nonescaping-Block virtualization, F2 parameter-aware range
narrowing + caller-argument propagation, F3 safepoint-aware GC-root
liveness, F2b nested/semantic induction guard recognition). No source
program was changed, no optimization was implemented, and no new benchmark
programs were invented. SIMD/vectorization is out of scope entirely.

Full final x86-64 disassembly for every native-compilable program is
committed under `audit/native-scalar-asm/` (see that directory's
`README.md` for the file-by-file index, compiler revision, and the
regeneration command). This document is the analysis of that evidence.

## 1. Corpus summary

- `bench/` files attempted: 4 (`fib.ir`, `loop-count.ir`, `sum-refined.ir`,
  `refined-checks.ir`)
- `bench/` files native-supported: 3 (`refined-checks.ir` fails — see §7)
- `examples/stdlib/` files attempted: 9 (all of them: `ai_text_clean.bot`,
  `csv.bot`, `csv_chunked.bot`, `csv_geometric.bot`, `csv_records.bot`,
  `hashtable.bot`, `matmul.bot`, `string_replace.bot`, `string_reverse.bot`)
- `examples/stdlib/` files native-supported: **9 of 9** — every stdlib
  program compiles and runs correctly on the native backend today; there is
  no capability gap anywhere in `examples/stdlib/`, only in `bench/refined-checks.ir`
  (a library-native-predicate capability gap, already diagnosed in
  `NATIVE-AUDIT.md`, reconfirmed unchanged in §7)
- total native functions inspected: 163 (8 in `bench/`, 155 in
  `examples/stdlib/`; every `botlish_fn_N`/`botlish_entry_N` symbol in each
  program's object, not just entry points)
- total committed disassembly: ~950 KB across 12 `.asm` files (reviewable
  directly on GitHub; see `audit/native-scalar-asm/README.md`)

Regenerate everything with `tclsh9.0 native/generate-scalar-audit.tcl`
(re-run twice during this audit; byte-identical output both times).

## 2. Headline verdict

**Mostly B: scalar code is broadly healthy, but one clear, well-evidenced,
cross-corpus compiler defect dominates the findings and should be fixed
before `refined-checks.ir` capability work.**

The bench corpus (`fib`, `loop-count`, `sum-refined`) now looks
dramatically better than `NATIVE-AUDIT.md`'s original description: F1+F2+F3+F2b
together have already fixed almost everything that audit flagged (see
§4 — `sum-refined`'s hot loop is now essentially a single genuine call per
iteration with zero `rt_closure_new`, zero checked-arithmetic calls, and a
tight 2-slot shadow frame; `loop-count`'s `work<int>` is fully raw scalar
code). This is a real, verified improvement, not an assumption.

But the `examples/stdlib/` corpus — deliberately not audited before this
milestone — surfaces a new, general, high-frequency finding that recurs
across the majority of its non-trivial programs: **a fixed-shape `List`
value used purely as an ad hoc record (a stdlib idiom that exists because
Botlish has no record/struct type) is never scalar-replaced when it arrives
as a function *parameter*, so every "field access" is a real out-of-line
runtime call** (§3, Finding 1). This is architecturally the exact same
shape of gap F2 already fixed once for range narrowing (extending an
analysis from "local bindings only" to "parameters too") — just for List
scalar replacement instead of range facts.

## 3. Finding table

| # | Finding | Severity | Files/functions affected | Layer | Hot/common path? | General or isolated? |
|---|---|---|---|---|---|---|
| 1 | Fixed-shape "record-as-List" **parameters** never scalar-replaced: every constant-index field read is a real `rt_list_get` call | **High** | `hashtable.bot` (table, all ops), `csv_chunked.bot` (builder), `csv_geometric.bot` (builder), `csv_records.bot` (reuses both) — 4 of 9 stdlib files directly, a 5th (`csv_records`) by composition | D (compiler artifact — `hir/escape.tcl`'s `Classify` only recognizes `local`/`remote` shapes, not `param`) | Yes — probing/append hot loops | **General**: recurs identically in every builder/record-like abstraction in the corpus |
| 2 | Builder "fast path" re-boxes its whole state tuple via `rt_list_new` on every append, on top of Finding 1's unpacking calls | Medium | `csv_chunked.bot`, `csv_geometric.bot` | D (same root cause as #1) | Yes | General to both builders (not `csv.bot`, which has no state tuple) |
| 3 | Trivial nullary constant-returning functions (`ht_empty_state()`, `chunk_size()`, etc.) are never inlined: a full call+prologue+shadow-stack-check+epilogue to fetch a literal | Medium–High | `hashtable.bot` (16+ hot-loop call sites), `csv_chunked.bot` (`chunk_size()`, several sites) | D/E (no small-pure-leaf-function inlining pass exists) | Yes — inside the probe loop and every append | General: identical idiom, independently found in both files by separate reviewers |
| 4 | `list_get` has **no inline bounds-check+load fast path at all** (unlike arithmetic, which gets inline tag-check+raw-op); always a real call, even on a genuinely variable index | Medium | `matmul.bot`'s `dot` (3 calls/iteration on the hottest loop in the corpus), plus every file in Finding 1 | D/E (codegen op table: `ListGet` unconditionally maps to a helper call) | Yes | General (9 of 9 stdlib files that use `List` at all touch this to some degree; matmul is the clearest pure case) |
| 5 | `index`'s range/bound is never proven in the CSV scanners (`scan_unquoted`/`scan_quoted`/`peek`), because the loop's termination test is a 3-way OR-of-disequalities, a shape neither `ComparisonNarrowing` nor F2b's guard recognizer handles | Medium | `csv.bot`, `csv_chunked.bot`, `csv_geometric.bot` (identical shared scanner) | D (induction/range-analysis capability gap, distinct from F2b's nested-guard fix) | Yes — every character of every field | General across all 3 CSV variants (shared source) |
| 6 | Redundant length/bounds recomputation across an un-inlined, single-call-site helper (caller already proved the fact) | Medium | `ai_text_clean.bot`'s `clean_from`/`peek` (2x `rt_str_len`+bounds check per character); `string_replace.bot`'s `replace_from`/`matches_at` (2x `rt_str_len` per position) | D (no inlining / no cross-call redundant-check elimination) | Yes | Isolated to these 2 files (each a different call pair, same root cause) |
| 7 | `csv_records.bot` has a narrow specialization duplication: an `<any,...>` family of HashTable accessors exists alongside the `<mutarray,str,...>` hot-path family, traced to `list_get` on a heterogeneous row `List` erasing element kind | Low | `csv_records.bot` only (cold verification path, `sample()`'s post-hoc lookups) | D (List-element-kind erasure — the same underlying "List forgets what's inside it" theme as #1/#4) | **No** — cold/verification path only | Isolated |
| 8 | `bench/refined-checks.ir` still cannot compile natively | Finding, not perf | `bench/refined-checks.ir` only | Missing native capability (library-registered predicates, `native/lower.tcl`'s fixed whitelist) | n/a | Isolated, already known (F7, `NATIVE-AUDIT.md` §5), reconfirmed unchanged |

Everything else inspected (see §5) is **clean**: F1/F2/F2b's fixes hold up
in the `bench/` corpus's final disassembly, GC shadow-slot sizing (F3) is
tight everywhere in both corpora with no outliers, StringRegion comparisons
are allocation-free exactly where they should be, resize/grow code is
correctly cold-branched, BigInt fallbacks are correctly cheap and
correctly cold, and HashTable's generic key dispatch is the semantically
right choice (not a missed specialization).

## 4. `bench/` corpus: confirmed post-F1/F2/F3/F2b state

Re-verified directly in `audit/native-scalar-asm/bench/*.asm`, not assumed
from the prior report:

- **`fib<int>`** (`bench/fib.asm`): both subtractions are raw
  (`sar`/`sub`/`shl`/`or` retagging, no call) thanks to F2's `[2,18]`
  parameter narrowing; shadow frame is 2 slots (was 14 pre-F3); the final
  `+` still goes through the checked tagged path with a real `rt_int_add`
  fallback, because its operands are two **recursive call results**, whose
  range this analysis has never tracked (the known, documented,
  not-yet-fixed "call-result range propagation" gap — see §6, Q12).
- **`loop-count`'s `work<int>`** (`bench/loop-count.asm`): fully raw scalar
  code (`sar`/`imul`/`add`/`test`), zero `rt_int_*` calls on the executed
  path, 1 shadow slot. Cranelift's own optimizer additionally folds
  `(i*3+7)-(i*3)` straight to the constant `7` in machine code — a healthy
  backend-side simplification, not a defect.
- **`sum-refined`** (`bench/sum-refined.asm`): dramatically improved from
  `NATIVE-AUDIT.md`'s description. `sum<int,int>`'s loop is now: `test
  rbx,rbx` / `je`, `sub rbx,0x1`, one real `call step<generic>`, `jmp` back
  — that is the **entire** loop body. Zero `rt_closure_new` (F1 holds),
  zero `integer? acc` check anywhere in machine code (folds away, matching
  the original F4 finding), zero checked-arithmetic calls on `n` (F2b's
  nested-induction fix reached `n`'s `[0,400]` range, confirmed in
  `range-params.txt`). The **only** remaining per-iteration cost is the
  genuine call into `step` — unavoidable without a general inliner (out of
  scope for this milestone; `step` has exactly one call site, so this is
  the same "tiny function, real call" tax as Finding 3, just semantically
  necessary here since the recursion is intentionally structured around a
  first-class function value).
- Smoke-tested end to end (`bench/bench.tcl -runs 3`, `LANG=C.utf8`):
  `fib(18)` 30us, `loop-count` 1us, `sum-refined` 1us best-of-3 Cranelift —
  consistent with the disassembly (a real loop with a handful of raw ops
  and, for `sum-refined`, one real call per iteration).

## 5. `examples/stdlib/` corpus: per-file findings

### `ai_text_clean.bot`
Clean: the sequential UTF-8 scan carries a raw byte offset forward through
every recursive step (confirmed: `rt_str_decode_char_at` is called with a
threaded offset argument, never re-deriving position from byte 0); the
self-tail recursion compiles to a real loop (`jmp` back-edge, no
call/frame growth per character); GC roots are tight (6/6, 4/4); no stray
`rt_closure_new`. The documented O(n²) string-concat behavior (repeated
`rt_str_cat`) is a **source/algorithm** property (class F), not added to by
codegen. One real defect: `clean_from`'s own loop guard and its inlined
`peek()` call both independently compute `rt_str_len(text)` and the same
`index >= length` bounds check — two real calls per character where one
would do, because the callee re-derives a fact its only caller already
established (Finding 6; `induction.txt` confirms this isn't a case of "fact
proven but ignored" — the index range genuinely isn't proven here).

### `string_reverse.bot`
The cleanest file in the corpus: exactly one `strlen`/`substr`/`strcat`/
compare per iteration, no duplicate calls, GC roots exact (4/4, 3/3), tail
recursion compiled to a loop. Entirely algorithm-bound (documented O(n²)
concat); nothing here for the compiler to improve.

### `string_replace.bot`
`matches_at` (single call site) is not inlined into its only caller
`replace_from`, so it re-derives both operands' lengths and the same
bounds check the caller just proved (Finding 6) — 2 extra calls + a branch
per haystack position scanned. Otherwise clean: both self-tail recursions
compile to loops, GC roots track max-live exactly (7/7) despite the
highest safepoint count in the corpus (9, proportional to its 9 call
sites, not shadow-stack bloat), no stray closures.

### `csv.bot`, `csv_chunked.bot`, `csv_geometric.bot`
All three share `scan_unquoted`/`scan_quoted`/`scan_field`/`scan_record`/
`peek` byte-for-byte. StringRegion is working exactly as intended: every
`peek(...) == ","`/`"\n"`/`""`/`"\""` comparison lowers to `regioneq`/
`rt_str_region_eq` with **no allocation**; a String is only materialized
once, at the point an unquoted field's value actually escapes into the
result — not per character. No reseek-from-byte-0 anywhere. Quoted-field
decoding (`scan_quoted`'s one-character-at-a-time `rt_str_cat`) is
correctly identified by the file's own header as O(n²) by construction —
class F, identical and unavoidable in all three variants, not a codegen
issue.

The scanners' shared `index` parameter never gets a proven range (Finding
5): `induction.txt` reports `"not proven (unsupported relational form)"`
for all three programs, because the loop exits on a disjunction of
disequalities (`== "" or == "," or == "\n"`), a shape outside both
`ComparisonNarrowing` and F2b's nested-guard recognizer. In the observed
common case this stays cheap (tag-check + inline raw op, falling to
`rt_int_add`/`rt_int_cmp` only if the fast tag test fails — never taken
here), so this is Medium, not High, severity — but it is the single
hottest loop in every CSV file, unconditionally.

Comparing the three builder strategies directly (this is the corpus's own
built-in test of "does an ordinary Botlish abstraction compile down
cleanly"): `csv_chunked.bot` and `csv_geometric.bot` both correctly avoid
`csv.bot`'s O(n) copy-the-whole-list-per-append baseline (`rt_list_append`
memmoves the entire backing array every call) — the intended asymptotic
win is real. But neither reaches "just a store + increment" for its
non-growing fast path: both pay Finding 1's unpack tax (2–3 `rt_list_get`
calls to read `[storage,length]`/`[completed,current,filled]`) **and**
Finding 2's re-box tax (a fresh `rt_list_new` every append to return the
updated state tuple), plus (`csv_chunked.bot` only) Finding 3's uninlined
`chunk_size()` call. At the tiny input sizes this audit's corpus actually
compiles, this bookkeeping tax makes the "smarter" builders look more
expensive in raw call count than `csv.bot`'s one `rt_list_append` call —
even though they are the asymptotically correct choice at real scale. The
shortfall is compiler-representation overhead (record-as-List boxing, one
uninlined constant function), not an algorithmic defect in the builder
code itself.

### `hashtable.bot`
The probing/resize algorithm, bounds checks, and key-equality dispatch are
all sound (see §5's "clean" list below) — this file's scalar code is
dominated by **codegen quality issues**, specifically Finding 1 and Finding
3, not by algorithm or layout cost. The table's identity is one 5-element
List used as an ad hoc mutable record (`[controls, keys, values, size,
capacity]`, per the file's own header — a direct consequence of Botlish
having no record type: item 33's exact target pattern). Because `table`
arrives as a parameter everywhere, every one of its "field reads"
(`ht_controls`, `ht_keys`, `ht_values`, `ht_capacity`, …) is a real
`rt_list_get` call, confirmed executing inside the hottest loop in the
file (probing: `ht_find_get`/`ht_find_insert`/`ht_rehash_probe`). On top of
that, `ht_probe_next` recomputes `ht_capacity(table)` (itself
`ht_controls(table)` + `rt_mutarray_capacity`) **fresh on every probe
step**, re-deriving a pointer the same iteration's own loop body already
fetched once — the table's field 0 provably cannot change mid-lookup, but
nothing merges the two reads. Separately, `ht_empty_state()`/
`ht_occupied_state()`/`ht_tombstone_state()` (each `fn ht_x(): N` — pure,
zero-argument, single-literal-body) are called for real, with full
prologue/shadow-stack-check/epilogue overhead, at 16+ sites inside this
same probe loop (Finding 3).

None of this is a wrong-algorithm or wrong-layout problem: bounds checks in
the probe loop are genuinely necessary (probe count isn't statically
bounded — a correctly-not-flagged non-finding); resize is correctly cold-
branched (one predicted compare separates the hot no-resize insert path
from `ht_grow_or_clean`); key-equality dispatch is correctly generic
(the table is documented to accept Int/Str/Bool/Unit/List/Result keys, so
a monomorphic compare can't be hoisted); GC shadow-slot counts equal
max-live-roots exactly in every one of its 30 functions, no outliers.

### `csv_records.bot`
Composes the CSV scanner with the HashTable, and inherits both files'
findings (Finding 1/3/5) without adding a new class of defect. `sample()`'s
`ht_get(first, "name")` calls (`first = list_get(rows, 0)`) lose the
concrete `mutarray` table kind through the row `List`, producing a second,
`<any,...>`-parameterized family of HashTable accessor instances alongside
the hot-path `<mutarray,str,...>` family (Finding 7) — this is real but
narrow: it's confined to the cold post-parse verification path in
`sample()`, each duplicate instance is 180–360 bytes, and the actual
per-row/per-field construction path (`ht_set`/`ht_find_insert`/`ht_place`)
stays a single specialized instance throughout. The file's own documented
"repeated header hashing across rows" (no cached hash, by design, to keep
the workload measuring real hash cost) is confirmed present and is
explicitly corpus-authored/deliberate (class F), not a missed
memoization the compiler failed to do. 59 total functions / 49 unique
names — checked directly against nir.txt: the ~2-3x duplication that
exists (`geo_append` x3, several `ht_*` accessors x2) is genuine call-site
kind diversity (three real element kinds reused across field/record/row
builders), not specialization explosion.

### `matmul.bot`
The clearest pure demonstration of Finding 4: `dot`'s inner loop
(`list_get(a_row,k) * list_get(list_get(b,k),column)`) makes **3 real
`rt_list_get` calls per iteration** on a genuinely variable index — this is
the single most call-heavy per-element hot loop in the whole corpus (34
total non-arithmetic runtime helper calls across 7 small functions). The
multiplication and addition themselves are properly optimized (inline
raw-multiply with `imul`+`seto` overflow check, falling to `rt_int_mul`
only on the never-taken overflow path) — the cost here is specifically
`list_get`'s lack of any inline bounds-check+load path, not the arithmetic.
This is algorithmically appropriate given Botlish `List` element kinds
aren't tracked past a `list_get` (matrix entries are arbitrary-precision
Ints by design, per the file's own header) — the finding is about the
*call*, not the *check* the call performs.

## 6. Known-question checklist

1. **Common cases of unnecessary heap allocation?** One clear one:
   `csv_chunked.bot`/`csv_geometric.bot`'s per-append `rt_list_new`
   re-boxing of their 2-/3-element state tuple (Finding 2) — a real,
   avoidable heap allocation on every append, on top of Finding 1's calls.
   Nothing else in the corpus showed an unexpected allocation on a common
   path; `rt_closure_new` does not appear anywhere in the committed corpus
   (F1 holds everywhere it's exercised).
2. **Are exact calls routinely lowering directly?** Yes, everywhere
   checked — every Botlish-to-Botlish call inspected (recursive helpers,
   `step`, HashTable operations from `csv_records.bot`) is a direct
   `botlish_fn_N` call, never an indirect/dynamic dispatch, including
   across the CSV+HashTable composition.
3. **Are bounded scalar integers routinely staying raw?** Where a bound is
   actually proven, yes (`fib`, `loop-count`, `sum-refined`'s `n` post-F2/
   F2b). Where it isn't (CSV scanner indices, Finding 5; matrix/hash
   entries, genuinely unbounded by design), arithmetic correctly stays
   tagged but cheap (inline tag-check, real calls only on the untaken slow
   path).
4. **Common box/unbox cycles that survive to machine code?** No — every
   `rbox`/`runbox` occurrence checked resolves to a cheap inline shift/or
   retag, never a redundant round-trip. This is not where this audit's
   cost is.
5. **Are GC shadow frames now proportional to actual root demand?** Yes,
   with no exceptions found: every function in every `.summary.txt`
   (163 functions total) has shadow-slot count equal to its own
   max-live-roots, including the largest functions in the corpus
   (`csv_records.bot`'s `sample`: 38 NIR regs, 8 shadow slots = 8 max
   live). F3 is holding up well after this milestone's added stdlib
   coverage.
6. **Repeated guards existing facts should remove?** Finding 6
   (`ai_text_clean`/`string_replace`'s redundant length/bounds
   recomputation) is the concrete case — but it's a missing-inlining gap,
   not a case of a proven fact being ignored (`induction.txt`/
   `range-params.txt` confirm the facts genuinely aren't proven in a form
   the caller could hand the callee).
7. **BigInt slow paths present only where proof-wise required?** Yes in
   every case inspected — every `rt_int_*` call site checked is a real
   cold fallback (never executed on the corpus's actual inputs), correctly
   isolated behind an inline tag/overflow test.
8. **Bounds checks obviously repeated despite induction facts?** The
   HashTable probe-loop bounds check is *not* redundant (probe count isn't
   statically bounded — correctly re-checked every step). The one genuine
   repeated-check case found is Finding 6 (cross-call, not intra-loop).
9. **Helper calls occurring on hot paths unexpectedly?** Yes — this is the
   audit's main result: Findings 1, 3, and 4 are all real, unconditional
   helper calls on hot/common paths, not cold fallbacks.
10. **Tiny helper functions paying disproportionate call/ABI overhead?**
    Yes, concretely quantified: `ht_empty_state()` compiles to ~20
    instructions of prologue/shadow-stack-check/epilogue to return one
    tagged literal, called for real at 16+ sites in the hottest loop in
    `hashtable.bot`; `chunk_size()` shows the identical pattern in
    `csv_chunked.bot`.
11. **Is missing inlining visibly a broad problem?** Yes — it's the
    through-line connecting Findings 3 and 6, and adjacent to 1/2 (whose
    fix is scalar replacement, not inlining, but addresses the same
    symptom class).
12. **Is call-result range propagation visibly needed across real stdlib
    code?** No — mostly a microbenchmark artifact, as
    `NATIVE-AUDIT.md` §9 already suspected. `fib`'s `fib(n-1)+fib(n-2)` is
    the clean example (still tagged, confirmed in `bench/fib.asm`). In
    `examples/stdlib`, recursive-accumulator results either flow into
    domains with no useful integer bound by design (`matmul`'s matrix
    entries, `hashtable`'s hash values — arbitrary precision is the
    correct semantics, not a missed proof) or are already seeded through
    the existing native-result mechanism (`list_length`/collection-length
    results). No stdlib case resembling `fib`'s "two bounded recursive
    results feed arithmetic" shape was found.
13. **Are String-heavy examples slow primarily because of algorithms
    rather than poor instruction selection?** Yes for `ai_text_clean.bot`
    and `string_reverse.bot` (documented O(n²) concat, confirmed as the
    dominant cost, codegen otherwise clean or near-clean); `string_replace.bot`
    is algorithm-bound overall with one isolated codegen redundancy
    (Finding 6) on top.
14. **Are mutable-array/builder abstractions compiling to reasonably
    direct loops?** The control flow is reasonably direct (capacity check
    → occasional grow → set → thread state, correctly cold-branched); the
    *data threading* between calls is not (Findings 1/2) — see §5's
    three-way builder comparison.
15. **Suspicious Cranelift codegen artifacts that don't trace to Botlish
    IR?** None found. Every finding in this audit traces to a Tcl-side
    analysis/lowering gap (`hir/escape.tcl`'s `Classify` scope,
    `hir/induction.tcl`'s recognized guard shapes) or to a fixed
    op-to-helper-call lowering table (`native/src/codegen/clif.rs`'s
    `ListGet` entry) — never to Cranelift's own instruction selection or
    optimizer. Where Cranelift's optimizer acts on its own (`loop-count`'s
    `(i*3+7)-(i*3)` folding to `7`), the result is a correct simplification,
    not an artifact.
16. **Which examples/stdlib programs cannot compile natively, and why?**
    None — all 9 compile and run correctly.
17. **What surface-language workarounds appear repeatedly in
    examples/stdlib?** Two, both confirmed with concrete call-site counts:
    (a) zero-argument, single-literal-body functions standing in for a
    module-level constant binding (`ht_min_capacity()`/`ht_empty_state()`/
    `ht_occupied_state()`/`ht_tombstone_state()` — 21 call sites;
    `chunk_size()` — 8 call sites); (b) a fixed-shape `List` used as an ad
    hoc record for multi-field state, since Botlish has no record/struct
    type (`hashtable.bot`'s table, `csv_chunked.bot`/`csv_geometric.bot`'s
    builder state). Unlike (a), which is purely a style/codegen question,
    (b) is also the direct cause of Finding 1's real runtime cost. No
    ambient-capability/module-mutable-state pattern (Clock/Random/DB/
    FileSystem) was found anywhere in this corpus — these are pure
    algorithm libraries with no such need.
18. **Is the scalar backend good enough that the next milestone should be
    native support for `refined-checks.ir`?** Not quite yet — see §8's
    recommendation. This audit found scalar code broadly healthy but also
    found one concrete, general, well-evidenced compiler defect (Finding
    1, with Findings 2–4 as closely related siblings) that recurs across
    the majority of the corpus's non-trivial stdlib programs and looks
    higher-value to fix first.

## 7. `bench/refined-checks.ir`: blocker reconfirmed unchanged

Reconfirmed today, byte-for-byte the same failure `NATIVE-AUDIT.md` §5
already diagnosed: `native/lower.tcl`'s `natives` dict is a fixed whitelist
of built-in operators; a library-registered native
(`core::type::definePredicate`/`core::native::register` — `lib/web.tcl`'s
`Emailish?`/`uriEscape`) is entirely absent from it, and `NativeCall`
raises `NATIVE UNSUPPORTED` before ever checking whether HIR already proved
the call's outcome statically.

```
$ tclsh9.0 main.tcl -backend cranelift bench/refined-checks.ir
   error: ir {1 2}: e39: native lowering does not support native uriEscape:
   the native "uriEscape" has no native implementation
   (NATIVE UNSUPPORTED {native uriEscape})
```

No fix attempted (out of scope for this diagnostic milestone).

## 8. Recommendation

**Outcome B: one clear cross-corpus compiler defect dominates — recommend a
single targeted milestone before `refined-checks.ir` capability work.**

Extend `hir/escape.tcl`'s existing List scalar-replacement `Classify` (§21
of the task, already proven for `local`-bound and `remote`-returned
fixed-shape Lists) to also recognize a third shape: a fixed-shape List
**parameter** every one of whose uses, within the function it's passed
into, is a `list_get` at a compile-time-constant index. This is
architecturally the same move F2 already made once (extending range
narrowing from `local` bindings to `param` bindings) — not a new analysis
framework, a scope extension of an existing, validated one — and it
directly removes Finding 1 (and much of Finding 2's re-boxing cost, since a
scalar-replaced builder state would thread through registers/stack slots
like `sum-refined`'s `step` closure already does post-F1, not through a
heap List) from every affected file: `hashtable.bot`'s entire hot probing
loop, and both `csv_chunked.bot`'s and `csv_geometric.bot`'s builder append
paths.

Why this over the alternatives, using this audit's own evidence:

- **Machine-code evidence.** Like F1's original justification, this is a
  *qualitative* cost (a real call, with its own prologue, shadow-stack
  overflow check, and epilogue) standing in for what should be a handful
  of register moves — not a quantitatively-larger version of an
  already-cheap inline sequence (contrast Finding 5, which stays cheap in
  the observed common case).
- **Generality.** Confirmed independently three times in this audit (by
  hand, and by two separately-briefed subagents auditing different file
  pairs) across `hashtable.bot`, `csv_chunked.bot`, `csv_geometric.bot`,
  and (by composition) `csv_records.bot` — 4 of 9 stdlib files directly,
  more than any other finding in this report.
- **Semantic risk.** Low, by the same reasoning `hir/escape.tcl`'s header
  already gives for its existing `local`/`remote` cases: every scalar-
  replaced field stays an ordinary tagged NIR register, rooted exactly as
  before.
- **Implementation complexity.** Bounded: it's a new `Classify` case in an
  existing, tested analysis, reusing the same intraprocedural mechanism the
  `local` case already uses, extended across one more kind of value flow
  (parameter passing) the same way F2 already extended a *different*
  analysis across that exact same boundary.

Findings 3 (uninlined constant functions) and 6 (uninlined single-call-site
helpers re-deriving a caller-proven fact) are both real but are instances
of "Botlish has no inliner yet" (explicitly out of scope for this
milestone to fix) rather than a scope gap in an existing analysis; they are
worth keeping in mind as supporting evidence for when a general inliner
milestone is eventually considered, but do not change this recommendation.
Finding 5 (CSV scanner index range) is real and general but stays cheap in
the observed common case, so it is lower priority than Finding 1.

Once Finding 1's scalar-replacement extension lands, this audit's
recommendation is unchanged from `NATIVE-AUDIT.md`'s: proceed to native
support for `refined-checks.ir` (§7), auditing that workload with the same
layered methodology this milestone used.

## 9. Regression status

- `cargo test --release` (native backend): 29 passed, 0 failed.
- `tclsh9.0 tests/all.tcl` (full Tcl suite, both interpreter and compiler
  backends, 41 test files): 1253 passed, 0 failed, 0 skipped.
- `tests/native*.test` re-run under `BOTLISH_NATIVE_GC_STRESS=1`: passing
  (GC-stress coverage for the native backend, unchanged from the ordinary
  run).
- `bench/bench.tcl -runs 3` smoke test (`fib.ir`/`loop-count.ir`/
  `sum-refined.ir`, Cranelift, `LANG=C.utf8`): ran correctly, timings
  consistent with the disassembly in §4.
- No compiler, runtime, or stdlib source file was modified by this
  milestone. Changed/added: `native/generate-scalar-audit.tcl` (new
  tooling), a two-line extension to `native/explain-native.tcl` to also
  accept `.bot` files (needed to inspect stdlib programs with the existing
  diagnostic dumps; no behavior change for its existing `.ir` use), the
  `audit/native-scalar-asm/` corpus, and this report.
