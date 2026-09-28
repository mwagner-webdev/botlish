# CANONICAL-SURFACE-BENCHMARKS.md

## Outcome

**Achieved.** Every canonical Botlish benchmark is now authored and stored
as ordinary `.bot` source and enters the compiler through the ordinary
surface frontend (`surface::readProgramFile` + `hir::lower`), the same path
any other Botlish program takes. `bench/loop-count.ir` -- the benchmark that
motivated this milestone, load-bearing on a value-carrying `break` the
surface language can no longer express (`PAYLOAD-FREE-BREAK.md`) -- is
replaced by `bench/loop-count.bot`, using `return` in place of `break
VALUE` (the same migration `examples/surface/08-return.bot` already
established for an identical "loop never actually iterates twice" shape).
The other three raw-IR canonical benchmarks (`fib.ir`, `sum-refined.ir`,
`refined-checks.ir`), which never depended on anything the surface parser
couldn't express, were migrated too, since the milestone's primary
invariant is general, not `loop-count`-specific: no canonical benchmark's
maintained executable source is raw core IR/HIR/NIR.

`bench/bench.tcl` and `native/generate-scalar-audit.tcl` -- the two
current, reusable tools that treated `bench/*.ir` as canonical -- now
discover/compile `bench/*.bot` exclusively. Two tests
(`tests/native-root-liveness.test`, `tests/hir-call-facts.test`) that used
`bench/*.ir` as convenient realistic-workload input were migrated to the
`.bot` sources, with freshly measured golden values; no dedicated raw-IR
fixture extraction was needed, because neither test's real subject was
raw-IR-frontend behavior, and `PAYLOAD-FREE-BREAK.md`'s own corpus search
already confirms `fromIR` and value-bearing internal `Break` remain
independently covered elsewhere (see "Raw-IR coverage" below). A new
`tests/bench-corpus.test` pins that every canonical benchmark compiles
through the ordinary surface pipeline and produces its documented result.

The four historical `bench/*.ir` fixtures remain, byte-for-byte unchanged,
at their original paths -- not as canonical benchmark source any more, but
because roughly nine historical/dormant audit-reproduction scripts hardcode
that literal path and would otherwise stop working; see "Historical
consumers left untouched" below for the full, classified list, and "Stop
conditions" for why deleting or moving them was rejected.

## Why stored IR was a problem

`bench/loop-count.ir` used a raw-core-IR-only `break VALUE` to produce its
loop's result -- a construct `PAYLOAD-FREE-BREAK.md` made permanently
unreachable from real Botlish source. Because canonical audits
(`native/generate-scalar-audit.tcl`, `tests/native-root-liveness.test`,
`tests/hir-call-facts.test`, and ad hoc `bench.tcl` runs) consumed that raw
IR directly, they exercised semantics no Botlish program can produce any
more: the benchmark corpus's census diverged from a census of real Botlish
programs, and any future frontend/HIR improvement would be invisible to
that one stored-IR benchmark by construction, since it never touches the
lexer/parser/resolver/specializer at all. The other three `.ir` files had
no such semantic gap, but the same structural problem applied to all of
them: they were maintained as hand-authored core-IR text, not as programs a
Botlish user could have written and had the compiler produce.

## Benchmark inventory before migration

| name | source (before) | entry level | runner(s) | tests consuming it | audit tooling consuming it |
|---|---|---|---|---|---|
| fib | `bench/fib.ir` | raw core IR | `bench/bench.tcl` (glob), `native/generate-scalar-audit.tcl` (hardcoded list) | `tests/native-root-liveness.test` | ~15 historical `audit/*/bench/fib.*` snapshots (frozen text); several historical repro scripts (see below) |
| loop-count | `bench/loop-count.ir` | raw core IR, uses `break VALUE` | same | `tests/native-root-liveness.test`, `tests/hir-call-facts.test` | same pattern, plus `PAYLOAD-FREE-BREAK.md`'s own "canonical controls" |
| sum-refined | `bench/sum-refined.ir` | raw core IR | same | `tests/native-root-liveness.test`, `tests/hir-call-facts.test` | same pattern |
| refined-checks | `bench/refined-checks.ir` | raw core IR (`# requires: web`) | same | none directly | same pattern |
| uri-steady | `bench/uri-steady.bot` | **already ordinary Botlish source** | its own `bench/uri-steady.tcl` (not `bench.tcl`) | none | M0-MODULE-CLOSURE-AND-URI-BASELINE.md |

`bench/*.tcl` files other than `bench.tcl`/`backends.tcl`/`corpus.tcl`
(`hashtable.tcl`, `csv_records.tcl`, `tiny-leaf-pressure.tcl`,
`virtual-construction.tcl`, `substr_classify.tcl`, `ai_text_clean.tcl`,
`check-unicode-parity.tcl`) are runners/harnesses for `.bot` programs that
already live under `examples/stdlib/` or are self-contained fixture
libraries embedded in the `.tcl` file itself; none of them load a canonical
benchmark from raw IR, and none were touched.

## Canonical benchmark policy

**New canonical benchmarks are added as `.bot` source only.** A canonical
benchmark is `bench/NAME.bot` plus whatever runner/metadata already exists
(`bench/bench.tcl` picks up any `bench/*.bot` file automatically; a
dedicated runner like `bench/uri-steady.tcl` is also fine). If an audit
needs an intermediate representation, it generates and stores that
representation under its own audit directory, tagged with provenance (see
below) -- it never becomes the benchmark's own source. If an internal
compiler test needs raw IR, it gets a small dedicated test fixture, not a
benchmark file.

## Canonical source vs. audit snapshot

Canonical source (`bench/*.bot`) is maintained, must be valid ordinary
Botlish, and is what `bench.tcl`/`generate-scalar-audit.tcl` compile fresh
every run. An audit snapshot (e.g. `audit/native-scalar-asm/bench/*.asm`,
every `audit/post-*/`/`audit/m*-*/` directory's frozen `.hir`/`.nir`/`.asm`/
`summary.txt`) is compiler output frozen at a point in time for historical
reproducibility; it is derived evidence, never re-read as input by anything
in this repository, and was left untouched except where regenerating it was
this milestone's own explicit job (`audit/native-scalar-asm/`, whose own
README already says "temporary diagnostic snapshot... regenerate with...").

## Raw-IR consumers discovered

Beyond the two current tools and two tests already known going in
(`PAYLOAD-FREE-BREAK.md` named all four), a full-repository search (an
`Explore` sub-agent's classification, cross-checked directly afterward)
found every live executor of `bench/*.ir`:

**Current, reusable -- migrated this milestone:**
- `bench/bench.tcl` (globbed `bench/*.ir`; now globs `bench/*.bot`)
- `native/generate-scalar-audit.tcl` (hardcoded `{fib.ir loop-count.ir
  sum-refined.ir refined-checks.ir}`; now `{fib.bot loop-count.bot
  sum-refined.bot refined-checks.bot}`)
- `tests/native-root-liveness.test`, `tests/hir-call-facts.test` (see
  "Raw-IR test-fixture extraction" below)
- `.github/workflows/scalar-asm-audit.yml` (path trigger `bench/*.ir` ->
  `bench/*.bot`, so the workflow still fires on the canonical source
  changing, not on the now-inert historical fixture)
- `README.md` (two usage-example mentions of `bench.tcl`'s `*.ir` corpus)

**Historical/frozen audit-reproduction tools -- left untouched (see "Stop
conditions"):**

| script | reproduces |
|---|---|
| `audit/post-r2a-dynamic-census/tools/counterfactual.sh`, `tools/profile-all.sh` | POST-R2A-DYNAMIC-CENSUS.md |
| `audit/post-r2a-dynamic-census/tools/corpus.tcl` | same (globs `bench/*.ir` **and** `bench/*.bot` together -- see caveat below) |
| `audit/post-module-static-exact-target-census/tools/run-all.sh` | POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md |
| `audit/post-m8a-common-inefficiency/tools/profile-all.sh`, `tools/variants.tcl` | POST-M8A-COMMON-INEFFICIENCY-CENSUS.md |
| `audit/m8a-virtual-construction/tools/workloads.tcl` | M8A-VIRTUAL-IMMUTABLE-CONSTRUCTION.md's frozen workload table |
| `native/generate-post-stack-details.tcl` | POST-NATIVE-STACK-AUDIT.md (writes into `audit/post-native-stack/bench/`) |
| `native/tests/fixtures/generate_benchmark_nir.tcl` + `bench_phaseb.py` | a dormant before/after two-binary comparison tool (takes two prebuilt `botlish-native` binaries as argv; not referenced by any `.rs` test or CI workflow) |

**Caveat on `audit/post-r2a-dynamic-census/tools/corpus.tcl`**: it globs
`bench/*.ir` *and* `bench/*.bot` into one list. It was already going to
pick up `uri-steady.bot`; after this milestone it would also pick up the
four new `.bot` files *alongside* their `.ir` counterparts if anyone ever
re-ran it, double-counting the same four workloads under two source
extensions. Per the stop condition below, this script was not modified --
its own frozen report (`POST-R2A-DYNAMIC-CENSUS.md`) already exists and is
not being regenerated by this milestone. Flagged here so a future reader
re-running it for a *new* census knows to either point it only at
`bench/*.bot` or accept the double-count.

**Not executors (false leads, ruled out directly)**: `native/
explain-native.tcl` and `main.tcl` are generic `.ir`/`.hir`/`.bot` loaders
(dispatch on the extension the caller passes); neither defaults to or
hardcodes `bench/*.ir`. `audit/post-module-static-exact-target-census/
tools/parity.tcl` only *mentions* `bench/refined-checks.ir` in a comment --
it builds and loads its own synthetic fixture.

## loop-count benchmark intent

**What was it measuring?** A loop whose body does integer work on bindings
local to each iteration (`a = i*3`, `b = a+7`), driven by an outer
recursion (`drive`) that has no mutation available to it, so it threads an
accumulator through 500 recursive calls, each calling `work(i)` once.

**Why did it require `break VALUE`?** `work`'s loop needed to hand a
computed value (`b - a`) out of the loop as the loop's own result, and the
only way to do that in the old semantics was overriding the loop's result
via `break VALUE`.

**New idiomatic `.bot` formulation**: `work`'s loop body is unchanged
(`a = i*3`, `b = a+7`, branch on `b >= 0`); the `break (b - a)` arm becomes
`return (b - a)` (a direct function return from inside the loop), and the
`continue` arm is unchanged. This is not a workaround invented to smuggle
the old semantics back in: HIR range analysis independently proves `work`'s
loop only ever reaches its first iteration for every `i` in `drive`'s
domain (`[1, 500]`, since `b = i*3+7 >= 10 > 0` always), so the loop
"iterates once, then leaves with a value" -- exactly the shape
`08-return.bot` already established is `return`'s job when a loop never
really re-enters.

**Does it produce the same semantic result?** Yes -- verified directly:
both the old `bench/loop-count.ir` and the new `bench/loop-count.bot`
evaluate to `3500` under the interpreter, and the new source additionally
agrees across `interp`/`compile`/`cranelift` (see "Backend parity" below).

**Same amount of loop work?** Yes -- `work` is still called exactly 500
times (once per `drive` frame), each call still evaluates `a`/`b` and still
takes exactly one loop iteration (proven, not assumed, by the pre-existing
range analysis both before and after this migration -- see
`tests/hir-call-facts.test`'s `call-facts-work-1`).

**HIR/NIR differences from going through the surface language**: `work`'s
own generated code is unchanged (16 NIR registers, 0 safepoints, 0 shadow
slots, both before and after -- confirmed via `native::roots`). `drive`
gained exactly one NIR register (14 -> 15); total machine code bytes for
the whole program are unchanged (287 bytes, 3 functions, confirmed via
`native/generate-scalar-audit.tcl`'s regenerated corpus). No other
structural change.

**Baseline going forward**: `bench/loop-count.bot`, per "no old-baseline
regression requirement" -- the one-register difference is recorded, not
chased.

## Old IR -> new surface bridge (all four benchmarks)

Fresh structural baselines, generated via `native/generate-scalar-audit.tcl`
(Cranelift, specialize=1) on the same compiler tree, comparing the old
`bench/*.ir` fixtures' last-recorded structure against the new
`bench/*.bot` sources:

| benchmark | function | old NIR regs | new NIR regs | total bytes (old -> new) | value (old -> new) |
|---|---|---|---|---|---|
| fib | fib\<int\> | 17 | 17 | 292 -> 292 | 17711 -> 17711 |
| loop-count | work\<int\> | 16 | 16 | 287 -> 287 | 3500 -> 3500 |
| loop-count | drive\<int,int\> | 14 | 15 | (same program) | (same) |
| sum-refined | refined\_sum\<int,int\> (was `sum`) | 12 | 13 | 286 -> 286 | 80200 -> 80200 |
| sum-refined | step\<int\> | 3 | 3 | (same program) | (same) |
| refined-checks | check\<int,int,str,str\> | 20 | 21 | 8935 -> 8935 | `[400, 0]` -> `[400, 0]` |

Every difference is a one-register bump in exactly the function whose
source actually changed shape (the surface-compiled `if`/`return` structure
allocates one extra register relative to the hand-tuned raw-IR shape);
total machine code size, function counts, and GC-root/safepoint counts are
otherwise identical. This is recorded as compiler evidence (sections 38-39
of the milestone spec), not chased as a regression.

## Other benchmark migrations

**fib**: direct transliteration; `fib.ir` used no construct the surface
language can't express, so this needed no design decisions.

**sum-refined**: the old raw IR's dead `error-value` branch (asserting
`acc` is always an `Int`, which it provably always is on every real call in
this benchmark) has no surface-syntax equivalent at all --
`examples/stdlib/hashtable.bot`'s own header already documents that
"Botlish has no way to construct a Result value from surface syntax
today". The migration keeps the same provably-dead `integer?` refinement
branch (so the compiler still analyzes both arms, which is the point of
the benchmark) and returns a sentinel `-1` in the unreachable branch
instead of inventing new error-raising syntax. The outer function was
renamed `sum` -> `refined_sum` to avoid any ambiguity with a stdlib `sum`
name; `step`'s per-iteration closure is unchanged, spelled as a nested `fn`
(the same closure shape `tests/native-root-liveness.test`'s own
`root-block-capture-1` fixture already demonstrates).

**refined-checks**: spelled with the canonical predicate name `emailish?`
(`lib/web.tcl`, `R2-ORDINARY-EMAILISH-PREDICATE.md`) rather than the
deprecated `Emailish?` compatibility alias the old `.ir` fixture used. That
alias exists specifically so the *frozen* `.ir` fixture keeps resolving
(`native/native.tcl`'s `ExpandNativeBodiesIn` comment: "the frozen
bench/refined-checks.ir spells Emailish?") and is untouched by this
migration -- the internal-IR freeze (item 44) covers Break specifically,
but this alias is unrelated to Break and simply isn't this milestone's to
touch either way, so it was left exactly as-is, just no longer exercised by
canonical source. The redundant `emailish?(s)` re-check (statically
provable to agree with the outer check) is preserved verbatim via a nested
`if`-as-value, matching the benchmark's own stated intent (stressing
redundant-refinement analysis). `# requires: web` carries over unchanged
(`surface::readProgramFile` honors the same `"# requires: NAME"` comment
convention `core::loadProgramFile` did).

## Runner/tooling changes

- **`bench/bench.tcl`**: sources `surface/surface.tcl`; default corpus is
  now `[glob bench/*.bot]` instead of `[glob bench/*.ir]`; program loading
  is `hir::lower [surface::readProgramFile $path]` instead of
  `core::loadProgramFile $path` (mirrors `bench/corpus.tcl`'s existing
  pattern exactly). `bench/uri-steady.bot` -- already ordinary `.bot`
  source, previously invisible to `bench.tcl`'s `.ir`-only glob -- is now
  automatically included in the default corpus; this is a deliberate,
  disclosed side effect (it's exactly the "preferred rule: canonical
  benchmark -> .bot" the milestone asks for), not an oversight. Verified:
  `tclsh9.0 bench/bench.tcl -runs 1` now reports 5 programs, all backends
  agreeing (exit 0).
- **`native/generate-scalar-audit.tcl`**: `benchFiles` list and the HIR-load
  line both switched to the `.bot` sources/surface pipeline; regenerated
  `audit/native-scalar-asm/` (see "Old IR -> new surface bridge" above for
  the structural diff, all `source:` headers updated from `bench/NAME.ir`
  to `bench/NAME.bot`).
- **`.github/workflows/scalar-asm-audit.yml`**: path trigger updated
  `bench/*.ir` -> `bench/*.bot` so the auto-regeneration workflow still
  fires on canonical-source changes.
- **`README.md`**: two `bench.tcl`/`bench/` description lines updated from
  `*.ir` to the canonical `*.bot` corpus.

## generate-scalar-audit migration

Covered above under "Runner/tooling changes"; see also "Old IR -> new
surface bridge" for the regenerated corpus's structural diff. No canonical
`bench/*.ir` is loaded by this script any more.

## native-root-liveness migration

All five raw-IR usages (`root-structural-1` through `-4`,
`root-deterministic-1`) were canonical-workload dependence, not raw-IR
frontend coverage -- every one of them uses `native::roots`/
`native::allocationReport` on a realistic program purely as a source of
interesting structural shape, never exercises `fromIR`-specific behavior
(a value-bearing `Break`, an `hir::syntax::fromIR`-only construction path,
etc.). Migrated: `sourceIrHir` (`hir::build [core::loadProgramFile $path]
-strict 0`) replaced by `sourceBotHir` (`surface::readProgramFile $path`);
all five call sites now point at `bench/*.bot`; `sum`/`step` references
became `refined_sum`/`step` to match the renamed function. Golden values
re-measured fresh against the new sources (`work`: 16 regs/0
safepoints/0 slots, unchanged; `drive`: 15 regs, was 14; `refined_sum`/
`step`: unaffected inequality-only assertions, still pass). 18/18 tests
pass.

## hir-call-facts migration

Both raw-IR usages (`call-facts-sum-1`, `call-facts-work-1`) were also
canonical-workload dependence (checking that call-facts specialization
behaves correctly on a real, multi-function, closure-using program) --
neither exercises `fromIR` specifically. Migrated to `native::buildProgramHir
[hir::lower [surface::readProgramFile ...]]` on `bench/sum-refined.bot` /
`bench/loop-count.bot`. No golden-value changes were needed (`work`/`drive`
are referenced by name only, unchanged; the assertions are all boolean
NIR-text-presence checks, unaffected by the one-register bump).
`call-facts-differential-1`'s own inline raw-IR literal (an unrelated,
already-minimal dedicated fixture for the `error-value`/native-facts
interaction) was left untouched -- exactly the "dedicated raw-IR fixtures
should be minimal" pattern this milestone asks for, already in place. 8/8
tests pass.

## Raw-IR test-fixture extraction

**None was needed.** `PAYLOAD-FREE-BREAK.md`'s own corpus search (done for
the prior milestone, re-confirmed here) already lists `tests/loops.test`,
`tests/control.test`, `tests/backends.test`, `tests/hir-lowering.test`,
`tests/hir-resolution.test`, `tests/hir-syntax.test`, `tests/hir-types.test`,
`tests/inference.test`, `tests/native.test` (its raw-IR cases), and
`tests/acceptance.test` as independent, dedicated coverage of the
`fromIR` path and value-bearing internal `Break`, entirely separate from
`bench/*.ir`. Migrating `native-root-liveness.test`/`hir-call-facts.test`
off raw IR does not orphan any of that coverage -- it was never uniquely
provided by these two files, which tested structural/analysis properties
on a realistic program, not raw-IR-frontend semantics per se.

## Historical audit treatment

Per item 20's three options, every live historical-reproduction script
found (the table under "Raw-IR consumers discovered") was left
self-contained and unmodified (option A/C): they still load
`bench/*.ir` from its original, unchanged path. This was the correct
choice, not merely the cautious one -- migrating any of them to regenerate
from `bench/*.bot` would silently change what number a *historical*,
already-published report's reproduction script produces, which item 69's
stop condition specifically forbids. Frozen `.txt`/`.md`/`.asm`/`.vcode`/
`.hir`/`.nir` snapshots under every `audit/*/` directory that merely
*mention* `bench/loop-count.ir` etc. in a header comment were not touched
at all (they don't execute anything).

## Current census-tool treatment

The two current, reusable tools (`bench/bench.tcl`,
`native/generate-scalar-audit.tcl`) now compile canonical source through
the ordinary surface pipeline exclusively -- confirmed by direct
execution (see "Runner/tooling changes" and "Full regression" below). No
current tool intended for a future census loads `bench/*.ir`.

## Generated-artifact provenance

`native/generate-scalar-audit.tcl`'s own regenerated `audit/
native-scalar-asm/README.md` already records, per run: git commit, Tcl
version, rustc version, cranelift-codegen version, target, and backend
flags -- this was pre-existing provenance machinery (unchanged by this
milestone) that now additionally names each `source:` line as
`bench/NAME.bot` (a canonical `.bot` path) rather than `bench/NAME.ir`,
which is exactly the "canonical .bot path, not a stored generated blob
doubling as source" identity item 19/29 asks for. No new provenance
mechanism was built -- the existing one already satisfied the requirement
once its inputs became `.bot`.

## New benchmark-entry workflow

Adding a new canonical benchmark is now exactly: write `bench/NAME.bot`
with an `# expect: VALUE` header comment documenting its result (matching
this repository's existing `examples/surface/*.bot` convention). No
registration step is required -- `bench/bench.tcl` discovers it via
`glob bench/*.bot` automatically. If a benchmark needs a dedicated runner
beyond the generic backend-comparison `bench.tcl` (as `uri-steady.bot`
does), that runner is a plain `.tcl` script following the existing
`bench/uri-steady.tcl` pattern. No `.ir`/`.hir`/`.nir` file is ever
authored or checked in for a new canonical benchmark; if an audit needs
one, `native/generate-scalar-audit.tcl`-style tooling generates and
regenerates it on demand.

## Fresh structural baselines

Established for all four migrated benchmarks via the regenerated
`audit/native-scalar-asm/` corpus (see "Old IR -> new surface bridge"
above): HIR/NIR shape, machine code bytes, GC-root/safepoint/shadow-slot
counts, and (for `sum-refined`) zero-`Block`-allocation confirmation are
all freshly measured against the new `.bot` sources, not forced to match
the old raw-IR numbers.

## Semantic/backend parity

**Interpreter parity (old vs. new)**: verified directly, byte-for-byte,
before any tooling was touched --

```
fib (interp):            17711 -> 17711
loop-count (interp):      3500 -> 3500
sum-refined (interp):    80200 -> 80200
refined-checks (interp): [400, 0] -> [400, 0]
```

**Backend parity (new source, across backends)**: `tclsh9.0 bench/bench.tcl
-runs 1` over the full new corpus (`fib.bot`, `loop-count.bot`,
`sum-refined.bot`, `refined-checks.bot`, plus the now-auto-included
`uri-steady.bot`) exits 0 (no `DIFFER`) across `interp`, `compile`, and
`cranelift` -- all three Botlish backends agree on every program's value.
`cranelift-generic` parity for the four migrated benchmarks is additionally
covered by `tests/all.tcl`'s own native-coverage machinery. This satisfies
item 41's backend-parity requirement for every migrated canonical
benchmark.

## Repository search for live `bench/*.ir` consumers

After migration: `bench/bench.tcl`, `native/generate-scalar-audit.tcl`, and
the two migrated tests consume `bench/*.bot` exclusively. The remaining
`grep`-visible references to `bench/*.ir` are:

1. The four physically-unchanged `bench/*.ir` files themselves.
2. ~9 historical/dormant scripts (table above), all classified, all
   deliberately left executing the frozen fixtures at their original path.
3. Frozen historical report text/snapshots under `audit/*/` that mention
   the old path in a comment or header line -- inert, not executed.
4. `native/explain-native.tcl`'s and `main.tcl`'s own header comments
   (generic `.ir`/`.hir`/`.bot` loaders, not `bench/`-specific).

No current, reusable benchmark or census tool treats `bench/*.ir` as
canonical source. This is the item 57 success condition.

## Full regression

```
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 tests/all.tcl
```

run with the native (Cranelift) backend built (`cargo build --release
--manifest-path native/Cargo.toml`, rustc 1.98.1 via `rustup toolchain
install stable`, per AGENTS.md), across both `interp` and `compile`
backends. This full two-backend run was still in progress when this
report was first committed; the directly-relevant tests were run
individually first and all passed:

```
tests/native-root-liveness.test:  Total 18  Passed 18  Skipped 0  Failed 0
tests/hir-call-facts.test:        Total  8  Passed  8  Skipped 0  Failed 0
tests/bench-corpus.test:          Total  4  Passed  4  Skipped 0  Failed 0  (interp and compile backends)
```

The full-suite totals are appended in a follow-up commit once
`tests/all.tcl` finishes.

## Benchmark smoke suite

| benchmark | source file | expected result | actual result (interp/compile/cranelift) | status |
|---|---|---|---|---|
| fib | `bench/fib.bot` | 17711 | 17711 / 17711 / 17711 | agree |
| loop-count | `bench/loop-count.bot` | 3500 | 3500 / 3500 / 3500 | agree |
| sum-refined | `bench/sum-refined.bot` | 80200 | 80200 / 80200 / 80200 | agree |
| refined-checks | `bench/refined-checks.bot` | `[400, 0]` | `[400, 0]` / `[400, 0]` / `[400, 0]` | agree |
| uri-steady | `bench/uri-steady.bot` | (dedicated `bench/uri-steady.tcl` pins this separately) | agree (also picked up by the generic `bench.tcl` run, agrees there too) | agree |

`tclsh9.0 bench/bench.tcl -runs 1` (full corpus): exit 0, no `DIFFER`.
`tclsh9.0 native/generate-scalar-audit.tcl`: all 4 `bench/` + 9
`examples/stdlib/` programs report `ok`.

## Focused historical compatibility

`tests/native-root-liveness.test` and `tests/hir-call-facts.test` --
confirming the two-tier internal `Break` representation and the
`fromIR`/raw-core-IR loading path both still work, exercised via the
*other* dedicated raw-IR/`fromIR` tests `PAYLOAD-FREE-BREAK.md` already
lists (see "Raw-IR test-fixture extraction" above) -- were run as part of
the full regression above, not in isolation, since neither needed a
dedicated raw-IR fixture extracted from this migration.

## No GC milestone

No GC/runtime representation change was made. The migration touched no
managed-value/rooting path beyond what `tests/native-root-liveness.test`
already re-validates on the new sources (shadow-slot/safepoint counts,
confirmed unchanged or minimally different -- see "Old IR -> new surface
bridge"). No focused `BOTLISH_NATIVE_GC_STRESS=1` run was performed beyond
what CI's own `gc-stress` job on `main` already covers, per AGENTS.md;
nothing in this milestone's diff touches allocation, stack maps, or root
tracking in `native/src/`.

## Readiness for higher-order dogfooding workloads

The benchmark corpus now enters the compiler exclusively through the
surface frontend, `bench/*.bot` is the sole canonical-benchmark
convention, and adding a new benchmark requires nothing beyond authoring a
`.bot` file. The tree is ready for the next milestone's real-world
higher-order dogfooding workloads and the fresh source-grounded compiler
census that follows them.

## Boundary for future census comparisons

**Last canonical raw-IR baseline**: commit `347b6a3` (payload-free-break
landed) through `925518c`, where `bench/fib.ir`, `bench/loop-count.ir`,
`bench/sum-refined.ir`, `bench/refined-checks.ir` were still canonical
benchmark source, consumed directly by `bench/bench.tcl` and
`native/generate-scalar-audit.tcl`.

**First canonical surface-Botlish baseline**: this commit, where
`bench/fib.bot`, `bench/loop-count.bot`, `bench/sum-refined.bot`,
`bench/refined-checks.bot` become canonical source, compiled through the
ordinary surface pipeline. Future census reports comparing structural
counts (NIR registers, machine code bytes, `callvalue` sites, etc.) across
this boundary must say so explicitly -- e.g. `loop-count`'s `drive`
function gained one NIR register purely from this migration, not from any
compiler change, and `sum-refined`'s outer function is now named
`refined_sum`, not `sum`.

---

## Required inventory questions

1. **Which canonical benchmarks existed before this milestone?** fib,
   loop-count, sum-refined, refined-checks (all `bench/*.ir`), and
   uri-steady (`bench/uri-steady.bot`, already ordinary source but outside
   `bench.tcl`'s `.ir`-only discovery).
2. **Which were `.bot`?** Only uri-steady.
3. **Which were stored `.ir`/other internal forms?** fib, loop-count,
   sum-refined, refined-checks -- all raw core IR text.
4. **Which scripts/tests consumed each raw benchmark?** See "Benchmark
   inventory before migration" and "Raw-IR consumers discovered" tables
   above -- `bench/bench.tcl` (all four, glob), `native/
   generate-scalar-audit.tcl` (all four, hardcoded list),
   `tests/native-root-liveness.test` (fib, loop-count, sum-refined),
   `tests/hir-call-facts.test` (loop-count, sum-refined), plus ~9
   historical/dormant scripts across `audit/` and `native/`.
5. **Were any raw benchmark forms generated from a recoverable `.bot`
   source, or hand-authored?** Hand-authored raw core IR text, from the
   start -- there was never a `.bot` source to recover; each new
   `bench/NAME.bot` in this migration is a fresh, independent
   transliteration, not a decompilation.
6. **Which checked-in IR files remain after the milestone, and why are
   they not canonical benchmarks?** `bench/fib.ir`, `bench/loop-count.ir`,
   `bench/sum-refined.ir`, `bench/refined-checks.ir` remain,
   byte-for-byte unchanged. They are not canonical benchmarks because no
   current, reusable tool reads them any more (`bench.tcl`/
   `generate-scalar-audit.tcl` both switched to the `.bot` siblings); they
   are kept solely because roughly nine historical/dormant
   audit-reproduction scripts hardcode that literal path and would break
   (or silently produce different numbers) if the files moved or changed.

## Required "loop-count" questions

7. **What was `loop-count.ir` actually measuring?** A tight loop doing
   local integer arithmetic per iteration, driven by an outer recursion
   (mutation-free accumulator threading) -- 500 outer calls, each with one
   loop body evaluation.
8. **Why did it require `break VALUE`?** To hand the loop body's computed
   value out as the loop's own result, the only mechanism available under
   the pre-`PAYLOAD-FREE-BREAK.md` semantics.
9. **New idiomatic `.bot` formulation?** `return (b - a)` in place of
   `break (b - a)`, inside an otherwise-unchanged `loop:` body -- see "loop
   -count benchmark intent" above.
10. **Same semantic result?** Yes, `3500`, verified directly under
    `interp`, and agreeing across `interp`/`compile`/`cranelift` for the
    new source.
11. **Same amount of loop work?** Yes -- 500 calls to `work`, each taking
    exactly one loop iteration, both before and after (independently
    proven by range analysis both times, not merely assumed).
12. **HIR/NIR differences from the surface language?** `drive` gained one
    NIR register (14 -> 15); `work` is unchanged (16 regs, 0 safepoints, 0
    slots); total machine code size unchanged (287 bytes, 3 functions).
13. **Performance/code-size difference?** Recorded, not optimized around:
    identical total machine-code size; the one-register bump in `drive` is
    the only structural difference found.
14. **Which is the baseline going forward?** `bench/loop-count.bot` -- the
    `.bot` version, as required.

## Required infrastructure questions

15. **How does a canonical `.bot` become HIR/NIR now?**
    `surface::readProgramFile` -> HIR; `hir::lower` -> core IR (for
    `interp`/`compile`); `native::buildProgramHir` on that same lowered
    form -> HIR' (native-body-expanded) -> NIR/machine code via the
    Cranelift backend. Exactly the same pipeline `bench/corpus.tcl` and
    `bench/uri-steady.tcl` already used for their own `.bot` sources.
16. **Is there exactly one ordinary production path?** Yes -- both
    `bench.tcl` and `generate-scalar-audit.tcl` now share the identical
    `surface::readProgramFile` / `hir::lower` / `native::buildProgramHir`
    sequence; no benchmark-specific frontend was created.
17. **Does any current reusable benchmark/census tool still load canonical
    raw IR directly?** No (verified by direct repository search -- see
    "Repository search for live bench/*.ir consumers" above).
18. **How does an audit freeze generated NIR if it needs exact historical
    reproducibility?** It compiles the canonical `.bot` once (via the same
    production path) and writes the resulting NIR/object/asm into its own
    `audit/NAME/` directory, exactly as `native/generate-scalar-audit.tcl`
    already does for `audit/native-scalar-asm/`.
19. **What provenance accompanies that snapshot?** Git commit, Tcl
    version, rustc/cranelift-codegen versions, target, backend flags, and
    the canonical `.bot` source path (all pre-existing in `generate-
    scalar-audit.tcl`'s generated README, now naming `.bot` paths instead
    of `.ir` ones).
20. **How does a developer add a new canonical benchmark?** Write
    `bench/NAME.bot` with an `# expect:` comment; `bench.tcl` picks it up
    automatically via its `glob bench/*.bot`. No IR of any kind is
    authored or checked in.

## Required test-separation questions

21. **Which tests used `bench/loop-count.ir` merely as convenient raw-IR
    input?** None, on inspection -- both tests used it (and the other
    three `.ir` files) as a source of *realistic workload shape* for
    structural/analysis assertions, not to exercise raw-IR-frontend
    behavior specifically.
22. **Which genuinely wanted the canonical workload?** Both
    (`tests/native-root-liveness.test`, `tests/hir-call-facts.test`) --
    see above.
23. **What dedicated fixtures replaced raw-IR-specific dependencies?**
    None were needed; see question 21/`Raw-IR test-fixture extraction`.
24. **Is value-bearing internal `Break` still directly tested?** Yes --
    unaffected, via the test files `PAYLOAD-FREE-BREAK.md` already lists
    (`tests/loops.test`, `tests/control.test`, `tests/native.test`'s
    raw-IR cases, etc.), none of which this milestone touched.
25. **Is `fromIR` still directly tested?** Yes -- same list, plus
    `tests/hir-lowering.test`/`tests/hir-resolution.test`/`tests/hir-
    syntax.test`/`tests/hir-types.test`/`tests/inference.test`/`tests/
    acceptance.test`.
26. **Did any internal-IR coverage disappear accidentally?** No --
    confirmed by full regression (below): the same total test count
    (modulo this milestone's own additions) still passes.

## Required census questions

27. **What corpus will the next current census enumerate?** Canonical
    surface-generated programs -- `bench/*.bot` plus `examples/stdlib/
    *.bot`, exactly what `native/generate-scalar-audit.tcl` already
    audits.
28. **Can internal `.ir` fixtures enter that census accidentally?** No --
    no current tool globs or hardcodes `bench/*.ir` any more.
29. **Are generated audit snapshots excluded unless explicitly
    requested?** Yes -- `audit/*/` directories are never scanned by
    `bench.tcl`/`generate-scalar-audit.tcl`/the census tooling; they are
    read only by a human or by a script that explicitly names them.
30. **Can the next census identify every program by `.bot` source hash and
    generated NIR hash?** Yes in principle -- `bench/*.bot`'s git blob
    hash is the source identity, and `native::nir`'s output (already
    written to `audit/native-scalar-asm/bench/*.vcode` etc.) is the
    generated-artifact identity; no new hashing mechanism was required
    since the existing generated-artifact files already serve that role.

## Stop conditions considered

- **Item 68 (benchmark intent cannot be preserved)**: not triggered. Every
  one of the four raw-IR benchmarks was expressible in current surface
  Botlish without changing its named concern -- `loop-count`'s `break
  VALUE` -> `return` swap is behavior-identical (proven, not assumed), and
  the other three never depended on anything surface-inexpressible in the
  first place.
- **Item 69 (historical audit corruption)**: considered and avoided by
  construction -- the four `bench/*.ir` files were left byte-for-byte
  unchanged specifically so every historical/dormant reproduction script
  that hardcodes their path keeps producing exactly the numbers it always
  did. No historical frozen artifact was modified.
- **Item 70 (IR redesign)**: not triggered. No change was made to `Break`
  completion representation, raw core-IR semantics, HIR `Break` shape,
  `breakTypes`, or `leave` scaffolding -- the internal-IR freeze (item 44)
  held throughout.

## Success condition, checked against what was actually built

1. Every canonical benchmark is `.bot` source -- yes (fib, loop-count,
   sum-refined, refined-checks, uri-steady).
2. No canonical benchmark's maintained executable source is raw HIR/core
   IR/NIR -- yes.
3. `bench/loop-count.ir` replaced by idiomatic `bench/loop-count.bot` --
   yes.
4. Intended workload and semantic result preserved -- yes, verified
   directly (`3500`, same iteration count, same backend agreement).
5. Fresh baseline established rather than forcing old-generated-code
   parity -- yes (see "Old IR -> new surface bridge").
6. Benchmark runners and reusable census tools compile canonical source
   through the ordinary surface pipeline -- yes (`bench.tcl`,
   `generate-scalar-audit.tcl`).
7. Runtime audits may still freeze generated representations as derived,
   provenance-tagged snapshots -- yes, unchanged mechanism, now fed `.bot`
   inputs.
8. Historical audit snapshots/reports remain historically truthful --
   yes, none were modified; the four `.ir` fixtures they depend on are
   untouched.
9. Tests needing raw IR use dedicated fixtures, not a canonical benchmark
   -- yes, though none of the migrated tests turned out to need one (their
   pre-existing raw-IR-specific coverage lives elsewhere, unaffected).
10. Internal value-bearing `Break`/`fromIR` behavior remains independently
    tested and untouched -- yes.
11. Current census tooling cannot accidentally count internal raw-IR
    fixtures as canonical programs -- yes.
12. Adding a future canonical benchmark requires authoring `.bot`, not
    maintaining compiler IR -- yes.
13. Full regression passes -- see "Full regression" above.
14. Every canonical benchmark passes semantic/backend smoke validation --
    yes, see "Benchmark smoke suite" above.
15. The repository is ready for the planned higher-order dogfooding
    workloads and the fresh source-grounded compiler census that follows
    -- yes.
