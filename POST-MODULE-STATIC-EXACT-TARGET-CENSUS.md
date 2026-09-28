# Post-module-statics: exact-target counterfactual census

Audit only. No production compiler, runtime or library change. The
counterfactual exists only in scratch git worktrees. Raw data, tools and
reproduction steps:
[`audit/post-module-static-exact-target-census/`](audit/post-module-static-exact-target-census/README.md).

## Outcome

**Exact predicate targets still buy −17.2% foreground Ir on the
module-static tree**: 8,191,901 → 6,786,030 per steady-state run of
`bench/refined-checks.ir` (`[400, 0]`). Measured the way the old −19.7% was:
the *unmodified* compiler, fed a scratch `lib/web.bot` whose two `scan_while`
call sites are syntactically exact.

| | Ir/run | vs production | share of the ceiling |
|---|---:|---:|---:|
| **exact-target ceiling, foreground** | **−1,405,871** | **−17.16%** | 100% |
| … StringRegion exposure (TLD path, existing machinery) | −907,618 | −11.08% | 64.6% |
| … dispatch removal + exact-callee facts (both paths) | −498,253 | −6.08% | 35.4% |
| deferred `Vm::reset` reclamation | −356,400 | −14.95% of reclamation | |
| **lifecycle (foreground + deferred)** | **−1,762,271** | **−16.66%** | |
| wall-clock, median session-best (15 × 200 runs) | 524.2 → 439.5 µs | −16.2% | |

**By target** (two partial counterfactuals, each making one site exact; they
sum to the full ceiling within 4 Ir):

| target | chars/run | Ir saved | Strings removed | what the saving is |
|---|---:|---:|---:|---|
| `is_tcl_alpha` (TLD) | 1,200 | −1,040,654 (−12.70%) | **1,200** | the existing StringRegion keeps all 1,200 as regions, plus native dispatch |
| `local_char?` (local part) | 6,800 | −365,213 (−4.46%) | **0** | dispatch, the generic-entry trampoline and `guard str`. Nothing else |

What the fresh measurements establish:

1. **Nothing is double-counted.** Block allocations are 0 in production and
   0 in the counterfactual; `rt_closure_new` runs 0 times in both. The only
   Block-related difference is a program-lifetime constant (`local_char?`'s
   `fnvalue`), never a per-run object.
2. **Exact identity alone does not make `local_char?` region-consuming.**
   StringRegion's own `ConsumingShape` rejects `local_char?<str>` at
   `immutable_set_contains` (`e190`). In production it was blocked twice
   (opaque behind `callvalue`, and generic). Exact targets remove one of the
   two blockers.
3. **After exact targets, the local-part scan is 79.1% of the program**
   (5,368,990 of 6,786,030). Its 6,800 one-character Strings cost 3.80M
   in-run plus 2.02M deferred, and set membership costs another 0.76M.
4. **Two thirds of the ceiling needs HIR-level exactness.** 64.6% of the
   ceiling (the TLD regions) and the `guard str` removal exist only because
   `hir::stringregion` and `hir::specialize` see an exact call. A
   devirtualization done only in native lowering would cap at the
   dispatch share: ≈0.50M, 6.1%.
5. **Generality narrowed further.** The whole corpus now has exactly one
   `callvalue` site, in one program. `uri-steady` no longer compiles
   `emailish?` at all.

**Recommendation:** finite callable-target provenance remains the strongest
next **compiler** milestone. Its measured 17.2% is 4–5× the next compiler
candidate (R3 `char_at`, ~3.4–4.3%). It is also architecturally simpler
than when it was paused: the target set is two program constants, `{envless
Block e183, Native is_tcl_alpha}`, reaching an instance that is already
`InstanceClosed`.

It should be re-scoped in two ways:
* It must deliver exactness to the HIR-level passes, not only to native
  lowering.
* Its generality case is weaker than before, and the report says so.

A runtime one-character-String milestone is not a compiler task. It
competes on generality, and it attacks the cost that stays dominant after
exact targets. See
[Updated finite-target recommendation](#updated-finite-target-recommendation).

## Baseline identity

| | |
|---|---|
| tree | `924482b9774589a55612ffcec5f394e11b3d6db4`: the module-static milestone `f037c7d` plus one audit-corpus regeneration touching no compiler, runtime or library file. Clean working tree |
| `lib/web.bot` | blob `0d038f0`. **Algorithmically unchanged**: identical to the post-R2.a census (`2b82c5b`), and comment-only different from the R2.a.3 freeze (`4ef02f4`) |
| benchmark | `bench/refined-checks.ir`, unmodified. `[400, 0]` (`value {list {{int 400} {int 0}}}`) from production, audit binary and every counterfactual |
| native build | `cargo build --release` (`[profile.release] debug = 1`), unmodified `native/` (tree `1c9efed`) |
| audit patch | the post-R2.a census's `audit-native.patch`, **unchanged** (sha256 `f956e9e4…`). It applies to the module-static `native/src` with a 9-line offset, and touches only `main.rs` and `codegen/mod.rs` |
| host | Intel Xeon @ 2.10 GHz, 4 vCPU shared cloud container, Linux 6.18, glibc 2.39 |
| tools | Tcl 9.0.1, rustc/cargo 1.98.1, valgrind 3.22.0, Python 3.11.15, binutils 2.42 (`baseline/environment.txt`) |

## Module-static architecture recap

As landed in `f037c7d`, verified here from HIR and NIR, not assumed:

* A module-retained immutable binding, data or function, becomes a
  `staticRefs` entry, never a lexical capture. It is stored in a
  program-lifetime slot (`statics=3`: `local_extra_chars`, `hex_digits`,
  `additional_unreserved_chars`). The program function writes it with
  `staticset`, and readers load it with `staticget`.
* Every module function is envless and reached as a constant-pool
  `fnvalue`.
* On this benchmark:
  * `local_char?`: `env=0 captures=0`, `staticRefs={web::local_extra_chars}`;
  * `web::emailish?<str>`: envless;
  * `check<int, int, str, str>`, with `check.n = [0, 400]`;
  * **0 Block allocations per run** (was 803).
* Two report-table figures of the module-static report do not reproduce.
  See [Corrections to earlier reports](#corrections-to-earlier-reports).
  They change no conclusion.

## Audit tooling validation

The post-R2.a audit path was re-validated against the module-static
runtime, not assumed:

| check | result |
|---|---|
| same program value | `[400, 0]` on production and audit binaries, for every one of the 16 profiled programs |
| generated code unchanged | `size`, relocatable `object`, VCode, allocation counters and allocation sites are identical between the binaries on all 16 programs. **112 of 112 checks OK** (`dynamic/validate-audit.txt`) |
| JIT map coverage | complete: direct + generic-entry sizes equal `size` per function, for all 16 programs |
| first-run exclusion | still correct. Production gives 8,191,901 (20 collected runs), 8,192,004 (repeat), 8,192,008 (10 runs), 8,191,917 (40 runs): spread **107 Ir**. The counterfactual's spread is **324 Ir** (0.005%) |
| reset region separated | `botlish_audit_reset` is measured on its own (`--toggle-collect=botlish_audit_reset`). The foreground frame `botlish_audit_run` contains no reset work: its own self cost is 6 Ir/run |
| GC | 0 in-run collections in every profile. The only collections are the between-run resets |

**Static-slot interaction (item 40).** The audit build does not perturb:
* **Static slot address.** The patch does not touch `runtime/vm.rs`:
  `statics_ptr`, `VM_STATICS_OFFSET`, `install_statics`, `reset` and
  `collect_with`'s root chain are byte-identical source. The generated
  object code is byte-identical too, so every `staticget`/`staticset`
  displacement is the same.
* **Root lifetime.** `BOTLISH_NATIVE_GC_STRESS=1 bench 8` (a collection at
  every allocation site, `Vm::reset` between 8 in-process runs) gives
  identical values and identical collection counts on both binaries:
  64,167 for production NIR, 54,567 for counterfactual NIR
  (`dynamic/gc-stress-reset.txt`).
* **Reset behavior.** `botlish_audit_reset` wraps the same `vm.reset()`,
  which deliberately leaves the static table alone. Reclamation per object
  is 297.3 Ir in every program.

**One runtime-layout effect, measured and excluded.** The same pre-static
frozen NIR costs 8,561,426 on the old census binary and 8,535,738 on
today's. The whole −25,688 is in `Vm::alloc<T>`'s own code: −3 Ir per
allocated object (8,004 Strings: 424,212 → 400,200; the Blocks: −1,606). The
module-static milestone added `Vm` fields, and that changed the function's
codegen. It is not a compiler effect. The historical bridge below therefore
uses **same-binary** figures only.

## Production target graph

`baseline/targetgraph-prod.txt` (`tools/targetgraph.tcl`) and
`baseline/prod.txt`:

```
scan_while: 1 semantic block (e211), 1 used instance: scan_while<generic>
  generic: 1   InstanceClosed: 1   range OPEN: 1   blockescape-flattened captures=[n, v]
  closedCallerTheorem (KeyType join per parameter): int any
  call site e298 in web::emailish?<str>
      start     <- const                        : int
      predicate <- ref local_char? (local)      : block e183 1 any
                   -> Block e183: ENVLESS captures=[] staticRefs=[web::local_extra_chars]
  call site e228 in tld?<generic>
      start     <- ref i (param)                : int
      predicate <- ref is_tcl_alpha (root)      : native is_tcl_alpha
                   -> Native is_tcl_alpha
NIR
  in web::emailish?: %4 = fnvalue 12          (constant-pool Block, no closure)
  func 13 "scan_while" params=4 env=0 pnames="start predicate n v" instance="generic"
    %8 = callvalue %1 %7
  in tld?:           %3 = native "is_tcl_alpha"
  callvalue instructions in the whole program: 1
```

| question | answer |
|---|---|
| `scan_while` semantic instances | **one**, `scan_while<generic>` |
| `InstanceClosed(scan_while)` | **true** (M7.c: blockescape's call-only proof) |
| `callvalue` in it | **one**, `%8 = callvalue %1 %7`, executed 8,000 times per run |
| forms reaching `predicate` | **exactly two**: an **envless Block** (`local_char?`, block e183: no captures, one module-static ref) and a **Native** (`is_tcl_alpha`, a root binding) |
| `local_char?` | envless: `func 12 … env=0 captures=0`; its set is `staticget 0` |
| `is_tcl_alpha` | native (`native "is_tcl_alpha" … impl=strtclalpha`) |
| any closure environment on the `local_char?` target | **none**: `closure` 0, `capture` 0, `callenv` 0, Block allocations 0 |

Why the old research had to be refreshed:
* The target set is now `{envless Block, Native}`, two program constants.
  It is no longer `{closure over local_extra_chars, Native}`.
* The closed-caller theorem machinery already reaches `scan_while`. It
  returns `{int, any}` for `{start, predicate}` only because `KeyType`
  reduces both callables to their kind and `lub` joins them to `any`.
* `local_char?<generic>` is itself `not-closed` and OPEN: it is materialized
  as a value.

## Production dynamic baseline

Reproduced fresh on the module-static tree. No pre-static number is reused.

| metric | production (module-static) |
|---|---:|
| foreground Ir/run | **8,191,901** (±107) |
| deferred `Vm::reset` Ir/run | **2,384,313** (8,020 objects × 297.3) |
| lifecycle Ir/run | 10,576,214 |
| wall-clock, 15 × 200: median session-best / best / median of all runs | 524.2 / 493.7 / 664.4 µs |
| allocations total / String / Block | 8,020 / 8,004 / **0** |
| `rt_call_value` calls, self, inclusive | 8,000 · 360,000 · 1,784,000 |
| `rt_substr` calls, self, inclusive | 8,003 · 837,439 · 4,739,388 |
| `rt_set_contains` calls, inclusive | 1,201 · 758,659 |
| `rt_closure_new` | **0** calls |
| machine bytes / NIR lines / functions / used instances | 8,943 / 690 / 24 / 26 |
| call / callenv / callmulti / callvalue | 24 / 0 / 4 / 1 |
| closure / fnvalue / capture | 0 / 1 / 0 |
| guard / guardbool / staticget / staticset | 1 / 1 / 4 / 3 |
| `check` self Ir | 25,258 (R2's figure: `check` is fixed) |
| `scan_while` self / inclusive | 423,200 / 7,217,665 |
| `web::emailish?` self / inclusive | 56,400 / 8,153,665 |
| UTF-8 seek Ir (bytes walked) | 503,600 (46,000) |

## Counterfactual construction

`counterfactual/exact-target.diff`, applied only in a scratch worktree. Its
hunks are byte-identical to the post-R2.a census's counterfactual, since
`lib/web.bot` has not changed since. `scan_while(start, predicate)` is
hand-split into:

```
fn scan_local(start):                       fn scan_alpha(start):
    loop i from start to n:                     loop i from start to n:
        if local_char?(char_at(i)):                 if is_tcl_alpha(char_at(i)):
            continue                                    continue
        return i                                    return i
    n                                           n
```

`emailish?` calls `scan_local(0)` and `tld?` calls `scan_alpha(i)`. Nothing
else changes:
* **Same everywhere:** module statics, `local_extra_chars` (still one
  module-static set, `staticget 0`), `char_at`, the traversal, the domain
  algorithm, the corpus.
* **Same toolchain:** compiler, runtime, StringRegion, blockescape, tiny-leaf
  inliner, range analysis, native lowering.
* **Nothing reintroduced:** no per-call set construction, no module capture,
  no closure.

Two partial variants, for per-target attribution:
* `counterfactual/local-only.diff`: only the `emailish?` site is exact;
  `tld?` still calls the generic `scan_while`.
* `counterfactual/alpha-only.diff`: only the `tld?` site is exact.

What the unmodified compiler makes of the exact shape (NIR):

```
func 12 "local_char?" … instance="str"      ; was "generic": guard str gone
func 13 "scan_local"  …                     ; %6 = call 11 %3 %2   (materializing char_at)
                                            ; %7 = call 12 %6      (direct call, no callvalue)
func 14 "scan_alpha"  …                     ; %6 %7 %8 = callmulti 10 %3 %2   (region companion)
                                            ; %9 = op strregiontclalpha %6 %7 %8  (region consumer)
```

This is a **measurement device**, not a production design. The eventual
compiler need not create two semantic `scan_while` instances. A finite
target theorem, internal lowering variants, a pre-loop mode branch or an
exact finite dispatch are all open. **The future compiler architecture
remains undecided.**

A side observation, from `local-only`: `scan_while` then receives only the
native `is_tcl_alpha`, and it *still* stays `<generic>` with a `callvalue`.
Today's instance key keeps only the callable's kind, even for a singleton
target set.

## Counterfactual semantic validation

**Production result == counterfactual result, on the whole Emailish corpus**
(`dynamic/parity-*.txt`, `tools/parity.tcl`):
* 95 addresses:
  * the valid/invalid corpus of `tests/emailish-predicate.test`;
  * every email literal harvested from the native/Unicode test files;
  * generated grammar edges: every local-part punctuation character,
    non-ASCII and astral characters in each part, empty/leading/trailing
    labels, consecutive dots and dashes, TLD length/digit/Unicode cases,
    whitespace.
* 36 accepted, 59 rejected.
* Each address runs on 4 backends (interp, compile, cranelift-generic,
  cranelift), through 2 paths:
  * `web::emailish?` called directly from a `.bot` program: the rewritten
    source itself, on every backend;
  * root `emailish?` from a `.ir` program: the benchmark's own `-module-fn`
    path natively, and the Tcl validator on interp/compile.
* Every address reaches the predicate as a runtime value (a data List
  walked recursively).

| tree | disagreements across backends/paths | disagreements with the Tcl-validator oracle | identical to production |
|---|---:|---:|---|
| production | 0 | 0 | |
| `cf-exact` | 0 | 0 | **yes, every row** |
| `cf-local-only` | 0 | 0 | **yes, every row** |
| `cf-alpha-only` | 0 | 0 | **yes, every row** |

The counterfactual worktrees really ran their rewritten source: their
`lib/web.bot` diffs are 39, 27 and 21 lines.

**Structural comparison** (`baseline/prod.txt` vs `baseline/cf-exact.txt`;
`dynamic/alloc-sites-*.txt`):

| | production | counterfactual | |
|---|---|---|---|
| module initialization (`<program>` NIR) | — | identical except renumbered callee ids (`call 17`→`18`, `call 23`→`24`) | ✓ |
| module-static slots | `statics=3`, 4 `staticget`, 3 `staticset` | same | ✓ |
| allocation sites unrelated to the predicate | 13 sites | identical counts and bytes | ✓ |
| `char_at` `substr` site | 8,000 Strings, 330,800 B | **6,800**, 279,200 B | intended |
| range facts | all entry/induction Ranges | identical (renamed scanners carry `scan_while`'s Ranges) | ✓ |
| `check` | `check<int, int, str, str>`, `n=[0, 400]`, self 25,258 | same | ✓ |
| predicate identity | `callvalue` at `scan_while` | direct `call 12` / inline `strregiontclalpha` | **the one intended difference** |

Three downstream consequences of that one difference are expected, not
separate changes:
* `local_char?` becomes `<str>`: its `guard` is gone and it is no longer
  materialized;
* the `fnvalue` and `native` value loads disappear;
* the static constant pool loses three program-lifetime constants: the
  `fnvalue` Block (40 B), the `is_tcl_alpha` Native (12 B), and the
  `guard`'s context String `"is_tcl_alnum"`.

## callvalue before/after

| | production | counterfactual |
|---|---:|---:|
| static `callvalue` sites | 1 | **0** |
| dynamic `rt_call_value` executions | 8,000 (6,800 → `local_char?`, 1,200 → `is_tcl_alpha`) | **0** |
| `rt_call_value` self / inclusive Ir | 360,000 / 1,784,000 | **0 / 0** |

**Gross dispatch in production**, per run:

| component | Ir/run | how measured |
|---|---:|---|
| `callvalue` call site in `scan_while`: root store, argument array (`lea` + store), argc, helper address, callee/VM moves, indirect `call`, completion check, `guardbool`'s kind check (`mov`/`or`/`mov`/`cmp`/`je`), result branch: 17 instructions × 8,000, plus the root-slot clear on the backedge (7,600) | 143,600 | per-instruction JIT listing |
| `rt_call_value` common dispatch (heap-kind test, closure arity, entry call) | 262,800 | addr2line inline chains |
| native dispatch (`invoke_native` arity/kind checks, `apply_op` match), `is_tcl_alpha` only | 75,600 | same |
| `local_char?` generic-entry trampoline (7 × 6,800) | 47,600 | JIT map (generic entry) |
| **gross dispatch** | **529,600 (6.46%)** | |
| guard/check work that exists only because the callee is generic: `local_char?`'s `guard str` (6 × 6,800) | 40,800 | per-instruction |

**Direct-call replacement cost:**
* `local_char?`: the exact call is 7 instructions (argument move, VM move,
  `call`, completion `test`/`jne`, result `cmp`/`je`) × 6,800 = **47,600**.
* `is_tcl_alpha`, without StringRegion: the helper call `rt_is_tcl_alpha`
  costs **+14,400** more than the classification `rt_call_value` had
  inlined.

**Measured net removal**, with StringRegion *off* in both trees, so that
only dispatch and exact-callee facts differ: **−498,253 (−6.08%)**.
Reconciled to the instruction class:
* **Runtime −324,000:**
  * `rt_call_value` self −360,000;
  * its `one_scalar` −46,800;
  * the direct `rt_is_tcl_alpha` +82,800.
* **Generated code −174,400:**
  * `local_char?` −88,400: trampoline −47,600, `guard` −40,800;
  * scanner call sites −83,600;
  * `fnvalue`/`native` value loads −2,400.

**Callee work retained** (moved from under `rt_call_value` to a direct
call): `local_char?`'s body is 160,400 self, and its
`rt_is_tcl_alnum` + `rt_set_contains` are 370,000 + 758,400. None of it
changes.

## Target-specific cost decomposition

### `local_char?` branch (6,800 characters per run)

Production vs. counterfactual. The partial counterfactual `local-only`
measures the net: **−365,213**.

| component | production | counterfactual | Δ |
|---|---:|---:|---:|
| call overhead: `callvalue` site (17 instr/char) → direct call (7) | 115,600 | 47,600 | −68,000 |
| `rt_call_value` common dispatch (30/call) | 204,000 | 0 | −204,000 |
| generic-entry trampoline | 47,600 | 0 | −47,600 |
| `guard str` (generic callee) | 40,800 | 0 | −40,800 |
| `local_char?` body (frame, branches, `staticget`) | 160,400 | 160,400 | 0 |
| `is_tcl_alnum` (`rt_is_tcl_alnum` incl. `one_scalar`, 54/call) | 370,000 | 370,000 | 0 |
| `immutable_set_contains` (`rt_set_contains`, 1,200 calls × 632) | 758,400 | 758,400 | 0 |
| `char_at` materialization (`char_at` self + `rt_substr`) | 3,761,652 | 3,802,190 | +40,538 (allocator state, below) |
| … of which UTF-8 seek | 83,200 | 83,200 | 0 |
| deferred reclamation (6,800 × 297.3) | 2,021,640 | 2,021,640 | 0 |

The dispatch rows sum to −360,400. The rest of the measured −365,213 is
the `fnvalue` load (−1,600) and loop register and root-slot differences
(≈ −3,200).

The materialization row's +40,538 is not part of that delta. It appears
only in the full counterfactual, as a side effect of removing the TLD
Strings (the allocator interaction below). `local-only` leaves
materialization unchanged.

### `is_tcl_alpha` branch (1,200 characters per run)

The partial counterfactual `alpha-only` measures the net: **−1,040,654**.

| component | production | counterfactual | Δ |
|---|---:|---:|---:|
| call overhead: `rt_call_value` common (49/call) + native dispatch (63/call) | 134,400 | 0 | −134,400 |
| native classification (inlined 21,600 + `one_scalar` 46,800) | 68,400 | — | |
| region classification `rt_str_region_is_tcl_alpha` (233/char) | — | 279,600 | net +211,200 vs the String classification |
| `char_at` materialization (`char_at` self + `rt_substr`, 1,041/char) | 1,248,800 | 0 | −1,248,800 |
| `char_at` region companion (`callmulti` + `rt_str_region_check`, 84/char) | 0 | 100,800 | +100,800 |
| scanner call site (`callvalue` site → `callmulti` + helper call) | (in `scan_while`) | (in `scan_alpha`) | −8,800 |
| `tld?` native value load | 1,200 | 0 | −1,200 |
| UTF-8 seek | 176,400 (in `rt_substr`) | 171,600 (in `region_one_scalar`) | −4,800 |
| deferred reclamation | 356,400 | 0 | −356,400 |
| allocator-state interaction: the local-part Strings get dearer once the TLD Strings are gone | | | +40,546 |

The in-run rows sum exactly to −1,040,654. Two rows are not added:
* UTF-8 seek, which is already inside the materialization and
  classification figures;
* deferred reclamation, which is outside the foreground.

**Allocator interaction.** `scan_local`'s inclusive cost is +40,538 higher
in `cf-exact` than in `cf-local-only`, identically in every repeat. The
only difference between those two programs is whether the 1,200 TLD
Strings are allocated. Their malloc/realloc traffic leaves the arena in a
state the next call's local-part allocations reuse cheaply (~6 Ir per
String). The same effect moves ~40K between the two arcs into the shared
`scan_while` in the same-binary historical comparison.

This is why every per-target figure in this report comes from the
partial-counterfactual *totals*, which are exact and additive, never from a
split of `scan_while`'s two caller arcs.

## String allocation before/after

| site | kind | production | counterfactual | Δ | bytes | foreground construction Ir | deferred reclamation Ir |
|---|---|---:|---:|---:|---:|---:|---:|
| `char_at` `web.bot:97` `substr`, TLD (`tld?` → scan → `is_tcl_alpha`) | String | 1,200 | **0** | **−1,200** | −51,600 (43 B each) | −1,248,800 gross (1,041 each; −1,208,254 net of the allocator interaction) | −356,400 |
| `char_at` `web.bot:97` `substr`, local part (→ `local_char?`) | String | 6,800 | 6,800 | 0 | 279,200 | 3,761,652 → 3,802,190 | 2,021,640 (unchanged) |
| `esc_from` `substr` / `construct` (startup) | String | 4 | 4 | 0 | 168 | ~1K | ~1K |
| module init + `byte::set` + `uriEscape` (List, ImmutableSet, StringPlan) | | 16 | 16 | 0 | 920 | ~7K | ~5K |
| **Block (any site)** | Block | **0** | **0** | 0 | | | |
| **total** | | **8,020** | **6,820** | **−1,200** | 331,888 → 280,288 | | 2,384,313 → 2,027,913 |

Also, but not per run: the static constant pool shrinks by three
program-lifetime objects, the `fnvalue` Block, the Native and one
guard-context String, created once by `install_constants`.

**No closure benefit is double-counted (item 12).** Does the exact-target
counterfactual remove any per-`emailish?` Block allocation that module
statics did not already remove? **No.** Both trees allocate 0 Blocks per
run, and `rt_closure_new` executes 0 times in both. Every other allocation
site is identical except the TLD `substr`. The old counterfactual's
closure saving (−271,918 in-run, 800 objects deferred) belongs entirely to
module statics now. See [Historical](#historical-old-vs-new-exact-target-ceiling).

## StringRegion consequences

**Measured fresh:**

| path | production Strings | counterfactual Strings | region after exact target? |
|---|---:|---:|---|
| `is_tcl_alpha` (TLD) | 1,200 | **0** | **yes**: `callmulti 10` + `strregiontclalpha` |
| `local_char?` (local part) | 6,800 | **6,800** | **no** |

The counts equal the old architecture's (1,200 / 6,800), now re-measured on
the module-static tree.

**Why, from StringRegion's own verdicts** (`baseline/stringregion-*.txt`,
`tools/regionprobe.tcl`, calling `hir::stringregion::ConsumingShape`
unmodified):

```
production      local_char?<generic>: consumingParams={}
                    generic instance: never a ConsumingParams candidate
counterfactual  local_char?<str>:     consumingParams={}
                    ConsumingShape rejects: e190: native `immutable_set_contains`
                    is not a supported region consumer (supported: ==, length,
                    is_tcl_alpha, is_tcl_alnum)
both            label_char?<str>:     consumingParams={0}  (ConsumingShape accepts)
```

* **`local_char?`** was blocked twice in production: its only caller was an
  opaque `callvalue`, and its instance was generic. Exact targets turn it
  into `local_char?<str>`, which removes the second blocker. The shape check
  then rejects it for exactly one node: `immutable_set_contains`.
  `is_tcl_alnum(c)` alone would qualify.
* **`is_tcl_alpha`** is a `ConsumingNative`. Once the call is syntactically
  `is_tcl_alpha(char_at(i))` with an exact native callee, it is an inline
  region-consuming operand. `char_at`'s region companion (function 10)
  already exists for `domain?`, so no new machinery is involved.

**Size of the StringRegion share.** With StringRegion turned off in both
trees (`-string-region-opt 0`):
* production costs 10,144,330 and the counterfactual 9,646,077, a
  difference of −498,253;
* with StringRegion on, the difference is −1,405,871;
* so StringRegion's contribution to the exact-target ceiling is
  **−907,618 (11.08% of production, 64.6% of the ceiling)**.

StringRegion saves 1,952,429 on production's direct paths already (the
2,800 `domain?`/`"@"` characters). The counterfactual adds 907,618 on top
of that.

**Positive control, per character, in-run:**

| path | consumer | chars/run | Strings | char access Ir | consumer Ir | total Ir/char | deferred/char |
|---|---|---:|---:|---:|---:|---:|---:|
| `domain?` direct `char_at` (known consumer) | `== "."` region eq (191.5) / `label_char?` folded region alnum (176) | 2,400 | 0 | 84 | 186 avg | **270** | 0 |
| `emailish?` `char_at(local_end) == "@"` | region eq | 400 | 0 | 84 | 151 | 235 | 0 |
| **exact `is_tcl_alpha`** (`scan_alpha`) | `rt_str_region_is_tcl_alpha` | 1,200 | 0 | 84 | 233 | **317** | 0 |
| **exact `local_char?`** (`scan_local`) | `local_char?<str>` on a String | 6,800 | 6,800 | 559 | 189.5 | **749** | 297 |
| opaque `is_tcl_alpha` (production) | `callvalue` → native | 1,200 | 1,200 | 1,041 | 57 + 129 dispatch | 1,227 | 297 |
| opaque `local_char?` (production) | `callvalue` → generic `local_char?` | 6,800 | 6,800 | 553 | 202.5 + 47 dispatch | 803 | 297 |

The exact `is_tcl_alpha` path behaves like the direct `domain?` control:
0 Strings and about the same per-character cost. Its consumer costs more
(233 vs. 176–191), because a region classifier re-seeks deep into a
non-ASCII base, which the TLD is. The exact `local_char?` path stays in the
materializing regime: 2.8× the control per character, plus deferred
reclamation.

## `local_char?` residual path

After the exact-target counterfactual, per run:

| | Ir/run | share of counterfactual |
|---|---:|---:|
| `scan_local` inclusive (the whole local-part scan) | **5,368,990** | **79.1%** |
| remaining local-part String materializations | **6,800** (279,200 B) | |
| … `char_at` → `rt_substr` (construction + seek) | 3,570,990 | 52.6% |
| … `char_at` own frame/call (34/char) | 231,200 | 3.4% |
| … UTF-8 seek inside `rt_substr` | 83,200 | 1.2% |
| `local_char?` inclusive | 1,288,800 | 19.0% |
| … `rt_set_contains` (1,200 calls: `equal` × 5 per miss) | 758,400 | 11.2% |
| … `rt_is_tcl_alnum` | 370,000 | 5.5% |
| … own body | 160,400 | 2.4% |
| `scan_local` loop control | 278,000 | 4.1% |
| deferred reclamation of the 6,800 Strings | 2,021,640 | +29.8% on top |

The local-part scan with its reclamation is 7.39M of the counterfactual's
8.81M lifecycle Ir (83.9%). This is the next post-devirtualization problem.
It was not optimized here.

## `is_tcl_alpha` path

Counterfactual, per run: `scan_alpha` inclusive **445,600 (6.6%)**, down
from ≈1.47M of alpha-path cost in production. It breaks down as:
* 1,200 region `char_at` calls: 100,800;
* 1,200 region classifications: 279,600, of which 171,600 is the UTF-8
  re-seek from byte 0;
* loop control: 65,200;
* **0 Strings, 0 dispatch, 0 deferred reclamation.**

What remains there is region-consumer seek cost, not a visibility problem.
`hir/traversal.tcl`'s monotone-scan optimization would be the tool for it,
but it does not apply: `char_at` is a separate instance and the scan is
generic.

## Allocation/reclamation lifecycle cost

Deferred reclamation is measured on its own (`dynamic/reclamation.md`):

| program | objects reclaimed per reset | Ir per reset | Ir/object |
|---|---:|---:|---:|
| production | 8,020 | 2,384,313 | 297.3 |
| counterfactual `exact` | 6,820 | 2,027,913 | 297.3 |
| `local-only` | 8,020 | 2,384,313 | 297.3 |
| `alpha-only` | 6,820 | 2,027,913 | 297.3 |
| production, StringRegion off | 10,820 | 3,215,913 | 297.2 |
| counterfactual, StringRegion off | 10,820 | 3,215,913 | 297.2 |
| pre-static frozen R2.a.3 (same binary) | 8,823 | 2,622,018 | 297.2 |
| pre-static counterfactual (same binary) | 6,823 | 2,027,220 | 297.1 |

| | foreground | deferred | lifecycle |
|---|---:|---:|---:|
| production | 8,191,901 | 2,384,313 | 10,576,214 |
| counterfactual | 6,786,030 | 2,027,913 | 8,813,943 |
| **Δ** | **−1,405,871 (−17.16%)** | **−356,400 (−14.95%)** | **−1,762,271 (−16.66%)** |

The deferred saving is now exactly the 1,200 TLD Strings (1,200 × 297.0).
No closure reclamation is in it. With StringRegion off, both trees reclaim
the same 10,820 objects. Every object the counterfactual removes is removed
by StringRegion.

## Machine/code-size delta

| | production | counterfactual | Δ |
|---|---:|---:|---:|
| machine bytes (total) | 8,943 | 9,217 | **+274 (+3.06%)** |
| NIR lines | 690 | 717 | +27 (+3.9%) |
| compiled functions | 24 | 25 | +1 |
| used instances | 26 | 27 | +1 |
| scanner(s): `scan_while` → `scan_local` + `scan_alpha` | 528 | 436 + 452 = 888 | **+360** |
| `local_char?` (`guard` gone; generic entry kept) | 238 | 176 | −62 |
| `tld?` (`native` value load gone) | 468 | 452 | −16 |
| `web::emailish?` (`fnvalue` gone) | 601 | 593 | −8 |

Partial variants: `local-only` 9,309 B, `alpha-only` 9,379 B. Each keeps
the generic `scan_while` and adds one exact scanner.

So the runtime benefit of an exact-path representation is −1.41M Ir/run,
and its approximate duplication cost is +274 machine bytes (a second
~440-byte loop, partly offset by callee simplification). Source duplication
here is a measurement device. A production lowering need not duplicate
source or semantic instances.

## Generated/runtime share

Exclusive Ir by code kind:

| | production | counterfactual | Δ |
|---|---:|---:|---:|
| generated Botlish code | 1,283,896 (15.7%) | 1,127,096 (16.6%) | −156,800 |
| runtime helpers | 3,715,615 (45.4%) | 3,222,415 (47.5%) | −493,200 |
| libc (malloc/realloc/memcpy/memcmp) | 2,170,491 (26.5%) | 1,745,820 (25.7%) | −424,671 |
| inlined Rust std (allocation shims, `from_iter`, `RawVec`) | 1,021,899 (12.5%) | 690,699 (10.2%) | −331,200 |
| allocation machinery (libc + Rust std) | 3,192,390 (39.0%) | 2,436,519 (35.9%) | −755,871 |

The exact-target counterfactual does **not** shift cost toward generated
code. Generated code *shrinks* (−156,800):
* removed: the `callvalue` site, `local_char?`'s trampoline and `guard`;
* added: the region companion's +55,200.

Its share rises only because everything else falls faster. More than half
the saving (−755,871) is allocation machinery: the 1,200 TLD Strings.

## Dynamic call graph

Invocations are exact entry-instruction counts per run.

| function / helper | production calls | self | inclusive | counterfactual calls | self | inclusive |
|---|---:|---:|---:|---:|---:|---:|
| `scan_while` | 1,200 | 423,200 | 7,217,665 | — | | |
| `scan_local` | — | | | 800 | 278,000 | 5,368,990 |
| `scan_alpha` | — | | | 400 | 65,200 | 445,600 |
| `char_at` materializing (fn 11) | 8,000 | 272,000 | 5,010,465 | 6,800 | 231,200 | 3,802,190 |
| `char_at` region (fn 10) | 2,800 | 128,800 | 235,200 | 4,000 | 184,000 | 336,000 |
| `local_char?` | 6,800 (all via generic entry) | 201,200 + 47,600 entry | 1,377,200 | 6,800 (direct) | 160,400 | 1,288,800 |
| `is_tcl_alpha` | 1,200 (native, via `rt_call_value`) | 21,600 inlined | 68,400 + 134,400 dispatch | 1,200 as `rt_str_region_is_tcl_alpha` | 38,400 | 279,600 |
| `rt_call_value` | 8,000 | 360,000 | 1,784,000 | **0** | 0 | 0 |
| `rt_substr` | 8,003 | 837,439 | 4,739,388 | 6,803 | 589,039 | 3,571,913 |
| `rt_set_contains` | 1,201 | 86,463 | 758,659 | 1,201 | 86,463 | 758,659 |
| `web::emailish?` | 800 | 56,400 | 8,153,665 | 800 | 54,800 | 6,747,790 |
| `domain?` | 400 | 103,200 | 2,302,400 | 400 | 103,200 | 1,221,200 |
| `tld?` | 400 | 24,800 | 1,550,400 | 400 | 23,600 | 469,200 |
| `check` | 2 (802 self-tail iterations) | 25,258 | 8,178,923 | 2 | 25,258 | 6,773,048 |

Hot edges:
* **production:**
  * `scan_while` → `char_at` (materializing), 8,000;
  * `scan_while` → `rt_call_value`, 8,000, fanning out to `local_char?`'s
    generic entry (6,800) and to `one_scalar` via the native path (1,200);
* **counterfactual:**
  * `scan_local` → `char_at` (materializing), 6,800;
  * `scan_local` → `local_char?`, 6,800 (direct `call`);
  * `scan_alpha` → `char_at` (region `callmulti`), 1,200;
  * `scan_alpha` → `rt_str_region_is_tcl_alpha`, 1,200.

## Input dependence (probes)

The post-R2.a census's single-input probes (`bench/refined-checks.ir`'s own
`check`/`q`, one address each, 400 iterations), emitted by each tree:

| probe | production Ir | counterfactual Ir | Δ | Strings | why |
|---|---:|---:|---:|---|---|
| `unicode-only` `café@例え.テスト` | 4,698,424 | 3,549,402 | **−24.5%** | 3,204 → 2,004 | reaches the TLD scan: 3 TLD Strings per call become regions |
| `ascii-only` `cafe@ab.xyz` | 2,857,655 | 2,205,055 | **−22.8%** | 3,204 → 2,004 | same control flow on an ASCII base |
| `invalid-only` `not-an-email` | 3,506,238 | 3,249,433 | −7.3% | 4,804 → 4,804 | no TLD scan: dispatch removal only |
| `early-invalid` `@example.com` | 553,578 | 530,041 | −4.3% | 404 → 404 | one local character per call |

The ceiling depends on how far inputs get. Only addresses that reach a TLD
scan collect the StringRegion share; invalid local parts collect only the
≈54 Ir per character of dispatch.

## Wall-clock control

Production binary, `tools/wallclock.py` (the prior census's protocol:
interleaved sessions of 200 runs, JIT excluded). Timings in µs:

| program | sessions | median session-best | best | median of all runs | Ir/run |
|---|---:|---:|---:|---:|---:|
| production | 15 | **524.2** | 493.7 | 664.4 | 8,191,901 |
| counterfactual `exact` | 15 | **439.5** | 418.5 | 559.7 | 6,786,030 |
| `local-only` | 15 | 539.7 | 476.4 | 690.5 | 7,826,688 |
| `alpha-only` | 15 | 443.8 | 430.5 | 576.8 | 7,151,247 |
| pre-static frozen R2.a.3 | 15 | 581.8 | 559.8 | 747.7 | 8,535,738 |
| pre-static counterfactual | 15 | 569.0 | 445.3 | 606.3 | 6,850,118 |

Production → counterfactual:
* **−84.7 µs (−16.2%)** median session-best;
* −75.2 µs (−15.2%) best;
* −104.7 µs (−15.8%) median of all runs.

This is consistent with −17.2% Ir. The first 7-session run
(`dynamic/wallclock-7x200.md`) was noisier: 525.8 → 499.0 median
session-best, but 499.4 → 418.7 best and 658.7 → 590.7 median of all runs.

The `local-only` variant (−4.5% Ir) is inside this host's ±15–25% session
noise. So is the pre-static counterfactual's session-best median. Nothing
rests on a timing difference. Ir is the primary metric.

## Historical old-vs-new exact-target ceiling

All four programs on **today's audit binary**, same method. The pre-static
NIRs are the post-R2.a census's committed `frozen.nir` and `cf-exact.nir`.

```
                         pre-module-static          post-module-static
                         (frozen R2.a.3 NIR)        (this tree)
production               8,535,738  ── −343,837 ──▶  8,191,901     module statics (−4.03%)
                            │                            │
exact-target Δ         −1,685,620 (−19.75%)        −1,405,871 (−17.16%)
                            ▼                            ▼
exact-target CF          6,850,118  ──  −64,088 ──▶  6,786,030     module statics, independent of exact targets
```

For reference, the old report's own figures, taken on the older binary,
were 8,561,426 → 6,870,845, i.e. −1,690,581 (−19.7%). The same NIRs
re-measured on today's binary give −1,685,620. The whole difference is
`Vm::alloc`'s −3 Ir/object, a runtime layout effect.

**Bridge (in-run Ir, same binary):**

```
old pre-module-static exact-target counterfactual:   −1,685,620   (−19.75% of 8,535,738)
module-static milestone recovered independently:        −279,749   of that ceiling (16.6% of it)
                                     plus, outside it:   −64,088   (check, emailish?, local_char?, scan param)
new post-module-static exact-target counterfactual:  −1,405,871   (−17.16% of 8,191,901; 83.4% of the old ceiling)
```

**What moved from the future callable-target bucket into the landed
module-static bucket.** This is the component-wise difference (old
counterfactual delta − new counterfactual delta), by function/helper:

| component | old CF Δ | new CF Δ | absorbed by module statics |
|---|---:|---:|---:|
| per-call `local_char?` closure allocation (`rt_closure_new`, 800/run, incl. `Vm::alloc<ClosureObj>` and the capture-array malloc) | −271,918 | 0 | **−271,918** |
| closure-creation site in `web::emailish?` | −10,000 | −1,600 | −8,400 |
| closure-environment access inside `local_char?` | −97,600 | −88,400 | −9,200 |
| old counterfactual's own flattened-closure parameter traffic in `scan_local` (it had to pass the closure) | +288,000 self | +278,000 self | +10,000 |
| **net absorbed** | **−1,685,620** | **−1,405,871** | **−279,749** (≈ −279,518 itemized; 231 Ir allocator residual) |

Deferred reclamation:
* the old ceiling was −594,798 (the 1,200 TLD Strings plus 800 closures);
* the new one is −356,400;
* **−238,398 was absorbed** (the 800 closures).

Lifecycle: the old ceiling was −2,280,418 (−20.44%) and the new one is
−1,762,271 (−16.66%), **77.3% of the old**.

Module statics' other −64,088 is **independent** of exact targets:
* `check<int, int, str, str>`: −21,622;
* `emailish?`'s `guard str` and capture load: −12,000;
* `local_char?`'s `staticget` in place of its environment: −19,200;
* `scan_local`'s flattened closure parameter: −10,000;
* startup: −1,266.

The historical percentages above are not added across methodologies. Every
row is one binary, one method.

## Compiler candidate comparison

Post-module-static numbers only. Production = 8,191,901.

| candidate | ceiling | how measured | changed since the post-R2.a census | overlap / dependency |
|---|---:|---|---|---|
| **A. finite callable-target provenance** | **1,405,871 (17.16%)** + 356,400 deferred | **measured**: counterfactual, unmodified compiler | −279,749: the closure share moved to module statics | 64.6% of it needs StringRegion to see the exact call |
| … A-dispatch only (a native-lowering devirtualization) | 498,253 (6.08%) | measured: StringRegion-off pair | — | subset of A |
| **R3 `char_at` direct-call work** (10,800 tiny exact calls) | ~0.28–0.35M (3.4–4.3%) | frame, move, call and caller-setup instruction counts (fn 11: 34 instr/call, of which ~25 boundary; fn 10: 46) | unchanged in shape | under A, 1,200 calls move from fn 11 to fn 10. Overlaps C on tag/overflow |
| **range↔blockescape** | ≤165,200 (≤2.02%), upper bound | raw-Int removable instructions in the OPEN-but-CLOSED instances (`scan_while` 90,800, `char_at` 40,000 + 14,000, `domain?` 15,600, `tld?` 4,800) | `check` left the population (fixed by module statics). Population is now 4 instances in `refined-checks` + 1 in `uri-steady` (was 9 / 10) | **independent of A**: the counterfactual's raw-Int bound is the identical 179,279 total |
| **frame / calling convention** | ~565K (6.90%), diffuse | frame 306,379 + convention moves 200,999 + calls 58,079 | unchanged in character | spread over every call. Not one milestone |
| **Bool control lowering** (compare → Bool word → re-test) | ≤50,444 (0.62%) | `mov R,2`/`cmov` + `cmp R,6; jcc` on branch-only compare results | — | the same instructions are inside C's raw-Int bound. Helper-returned Bools (59,234) are genuine values crossing the ABI. `guardbool` (8,000) goes away with A |

Ranking by measured or bounded payoff:
1. A;
2. R3;
3. C;
4. Bool control lowering.

F (frame/ABI) is larger than R3 but is not a milestone-shaped item.

## Runtime / StringRegion / data-structure opportunities (kept separate)

These are not compiler candidates. They are listed so the compiler ranking
is not mistaken for the whole picture:

| opportunity | kind | cost pool (post-static) | relation to A |
|---|---|---:|---|
| expose exact predicate identity | **compiler** | A above: 1.41M (17.2%) | — |
| make one-character String cheap (e.g. a one-scalar fast path) | **runtime** | production 5.01M in-run materialization (8,000 Strings: 3.76M local + 1.25M TLD) + 2.38M deferred. After A: 3.80M + 2.02M | independent. After A it still owns the dominant local path. Most general: one-character String production also appears in the csv family and `ai_text_clean` (the post-M8.a census measured 16.2% of `ai_text_clean`) |
| make `immutable_set_contains` a StringRegion consumer | **StringRegion** | the local path's 6,800 materializations: 3.80M in-run + 2.02M deferred, minus region-consumer costs (~270–320 Ir/char on the controls above). Very rough: ~2.9M in-run + 2.0M deferred | **requires A first** here: `local_char?` must be an exact, non-generic callee before `ConsumingShape` even examines it |
| make tiny `ImmutableSet` membership cheap (5 generic `equal`s per miss, 632 Ir/call) | **data structure** | 758,400 (9.26%) | independent of A (identical in both trees) |

Pool figures are measured cost *pools*, not achievable savings. Only A's
row is a measured counterfactual.

## Branch-once lowering estimate

Not implemented. The question: lower `predicate ∈ {local_char?,
is_tcl_alpha}` as one test before the loop, with a local path and an alpha
path, instead of a runtime callable dispatch on every character.

| | per-run cost | code size |
|---|---:|---|
| current: `callvalue` per character | 8,000 dispatches. Net dispatch 498,253 Ir (62/char). With StringRegion exposure, the ceiling is 1,405,871 (176/char) | one 528 B loop |
| **branch once per `scan_while` invocation**: compare `predicate` against one program constant (`fnvalue 12` or the Native), then jump to a specialized loop | 1,200 invocations × ~3 instructions (constant load, `cmp`, `jcc`) ≈ **3,600 Ir (0.04%)** | two loop bodies: **+360 B**, measured as `scan_local` + `scan_alpha` vs `scan_while`, + ~16 B for the test. **≈ +290 B net** after the callee `guard` (−62) and value loads (−24); ≈ +820 B if a generic fallback loop is kept |
| exact two-way dispatch per character, no loop duplication | ~3 instructions × 8,000 ≈ 24,000 Ir (0.3%) | +~60 B (the region consumer form inside the one loop) |

So branch-once would capture ≈ **1.40M of the 1.41M ceiling**: all of it
minus ~3.6K Ir of mode tests, at ≈ +3.3% machine code. It is attractive.

It carries one design condition the numbers make explicit. The two loop
variants must be visible as **exact calls to the HIR-level analyses**:
* `hir::specialize`, so `local_char?` becomes `<str>` (its `guard` goes and
  it stops being materialized);
* `hir::stringregion`, so the alpha variant's `is_tcl_alpha(char_at(i))`
  becomes a region consumer.

A branch introduced only in `native/lower.tcl`, after those analyses ran,
would keep the materializing `char_at` in the alpha variant. It would save
roughly the dispatch-only 0.50M (the trampoline and the native dispatch),
not 1.40M.

## Updated finite-target recommendation

**Is finite callable-target provenance still clearly worth implementing?**
Judged on each requested axis:

| axis | finding |
|---|---|
| new measured ceiling | **−17.16% foreground, −16.66% lifecycle.** Smaller than −19.7%, by exactly the closure share module statics claimed. Still 4–5× the next compiler candidate |
| architectural simplicity after module statics | **Much simpler.** The target set is two *program constants*: an envless constant-pool Block and a root Native. The old one included a per-call closure with an environment. The receiving instance is already `InstanceClosed`. `ClosedCallerFacts` already visits both call sites and already computes the join. It currently throws the identities away (`KeyType` → kind, then `lub` → `any`). A finite-set join in place of that `lub` is the core of the theorem. No new escape analysis, no environment threading, no closure elision |
| code-size impact | +274 B (+3.1%) measured for the source-level split. ≈ +290 B estimated for a branch-once lowering |
| generality | **Weak, and weaker than before.** One `callvalue` site in one program in the whole corpus. `uri-steady` no longer compiles `emailish?` at all |
| dependency on future StringRegion work | **None for the measured 17.2%**, which uses existing StringRegion only. But the dominant remaining cost, the 6,800 local-part Strings (3.80M + 2.02M deferred), needs a *further* StringRegion set-membership consumer, and that consumer needs A first |

**Answer:** yes, as the next **compiler** milestone. It has the largest
measured compiler ceiling by a wide margin, its precondition is already
proven, and it is the gateway to the one cost larger than itself. It is not
"clear" on generality. Two scoping conditions follow from the data:

1. **Deliver exactness at HIR level.** 64.6% of the ceiling is StringRegion
   exposure, and the `guard` removal comes from specialization. Both happen
   only if `hir::specialize` and `hir::stringregion` see an exact call. A
   lowering-only devirtualization caps at ≈6.1%.
2. **Keep it minimal.** A closed instance, a finite set of program-constant
   callables, and a join in the existing closed-caller pass. The eventual
   lowering (branch-once, internal variants, exact two-way dispatch) is
   open. The counterfactual's source duplication is a measurement device,
   not the design.

If the roadmap weights corpus generality over this workload, the fresh data
favor the runtime one-character-String work instead. It is not a compiler
milestone, and its payoff is an unmeasured fraction of a 5.0M-in-run cost
pool.

## Corrections to earlier reports

Measured here, not silently used. No report text was edited, since this
milestone's brief does not ask for it.

1. **`MODULE-STATIC-RETAINED-VALUES.md`, NIR table: `guard` 3 → 6** does
   not reproduce. The tree has `guard` 3 → **1** (`local_char?`'s `guard
   str` remains; `web::emailish?`'s and `esc_from`'s `guard str … "length"`
   are gone, since both were generic before and are now `<str>` and
   `<str, int, str>`), with `guardbool` 1 → 1. The same report's explanation ("guard
   count rose because envless functions … need their own operand-kind
   guards") therefore does not hold for this benchmark: guards *fell*.
2. **Same table: NIR lines 688 → 695.** The tree gives **690**, counted
   the same way (`llength [split $nir \n]`, emit-nir's loader; `wc -l`
   689). Every other row of that table reproduces exactly: functions 24,
   `call` 24, `callenv` 0, `callmulti` 4, `callvalue` 1, `closure` 0,
   `capture` 0, `fnvalue` 1, `staticget` 4, `staticset` 3, `statics=3`.
3. **Same report, "Post-module-static `scan_while` target shape":**
   `is_tcl_alpha` is "`label_char?`'s own path". It is `tld?`'s path:
   `label_char?` has not flowed through `scan_while` since R2.a.3.
4. **Same report, "Dynamic census":** it states the census methodology
   "requires `perf`". It requires valgrind/callgrind, which works here. The
   fresh same-binary effect of module statics on this benchmark is
   **−343,837 Ir/run (−4.03%)** in-run and −237,705 deferred. The report's
   "~9.8% best-of-200 wall-clock" was a single-session timing.

## Validation and regression

* **No production file changed.** `git status` shows only the new
  `audit/post-module-static-exact-target-census/` directory and this
  report. `hir/`, `native/`, `core/`, `compiler/`, `surface/`,
  `lib/web.bot`, `bench/` and `tests/` are untouched. The audit patch was
  applied only to a scratch copy of `native/`, and every counterfactual
  lived only in scratch git worktrees.
* **Semantic parity:** 95 addresses × 4 backends × 2 paths. Production and
  all three counterfactuals are row-for-row identical, with 0 oracle
  disagreements.
* **Focused tests:** `tclsh9.0 tests/all.tcl -file "emailish-predicate.test
  module-static-values.test"` passed: interp **Total 47 Passed 47 Failed
  0**, compile **Total 47 Passed 47 Failed 0**. Both files also check the
  native backends through four-way parity.
* **Full regression:** not run. No production source changed, and no test
  uses the audit tooling; `tests/` mentions `audit/` only in two comments.
* **GC stress:** no full local run, per item 41. No root or representation
  code changed. The audit build's static-slot and reset behavior was
  checked under `BOTLISH_NATIVE_GC_STRESS=1` (above).
* **Stop conditions:** none triggered.
  * Reset/reclamation is cleanly separated.
  * The counterfactual changes neither module initialization nor
    semantics.
  * No production compiler change was needed.
  * The module-static baseline reproduces. Two NIR-table figures of its
    report do not; they are recorded above.
  * The target graph is exactly `{envless Block, Native}`.

## Required questions

**Baseline**

1. **Module-static tree measured:**
   `924482b9774589a55612ffcec5f394e11b3d6db4`, i.e. `f037c7d` plus one
   audit-corpus regeneration. Clean working tree.
2. **Is `lib/web.bot` algorithmically unchanged?** **Yes.** It is
   byte-identical to the post-R2.a census tree, and comment-only different
   from the R2.a.3 freeze.
3. **Is `local_char?` envless?** **Yes**: `env=0 captures=0`,
   `staticRefs={web::local_extra_chars}`.
4. **Is `web::emailish?` envless?** **Yes**: `web::emailish?<str>`,
   `env=0 captures=0`.
5. **Is `check` specialized again?** **Yes**: `check<int, int, str, str>`.
6. **`check.n`:** `[0, 400]`.
7. **Is `scan_while` still one generic semantic instance?** **Yes**: one
   block (e211), one used instance, `scan_while<generic>`.
8. **Is it `InstanceClosed`?** **Yes** (`hir::specialize::closed` = 1).
   `hir::range` still flags it OPEN.
9. **Does it still contain one `callvalue`?** **Yes**: `%8 = callvalue %1
   %7`, the only `callvalue` in the program.
10. **Forms reaching `predicate`:** exactly **envless `Block(local_char?)`**
    (block e183, a constant-pool `fnvalue 12`) and **`Native(is_tcl_alpha)`**.

**Counterfactual**

11. **How predicate opacity was removed:** scratch-only
    `counterfactual/exact-target.diff` splits `scan_while` into
    `scan_local` (calls `local_char?`) and `scan_alpha` (calls
    `is_tcl_alpha`), each called from its one site. The hunks are
    byte-identical to the post-R2.a census's.
12. **Production compiler code changed:** **none.**
13. **Is semantic output unchanged?** **Yes**: `[400, 0]`, and 95/95
    addresses identical on 4 backends × 2 paths.
14. **Does `rt_call_value` go to zero?** **Yes**: 8,000 → 0.
15. **Do any Block allocations disappear?** **No.** Blocks are 0 → 0; module
    statics already removed them.
16. **Do TLD Strings disappear?** **Yes**: all 1,200.
17. **Do local-part Strings disappear?** **No**: 6,800 → 6,800.

**Performance**

18. **Foreground Ir before/after:** 8,191,901 → 6,786,030.
19. **Percentage delta:** −1,405,871, **−17.16%**.
20. **Deferred reclamation before/after:** 2,384,313 → 2,027,913
    (−356,400, −14.95%).
21. **Lifecycle Ir delta:** 10,576,214 → 8,813,943, **−1,762,271
    (−16.66%)**.
22. **Wall-clock before/after:** 524.2 → 439.5 µs median session-best
    (−16.2%). Best 493.7 → 418.5 µs; median of all runs 664.4 → 559.7 µs
    (15 × 200).
23. **Machine bytes:** 8,943 → 9,217 (+274, +3.06%).
24. **NIR lines:** 690 → 717 (+27).
25. **`rt_call_value` Ir:** 1,784,000 inclusive (360,000 self) → **0**.
26. **`rt_substr` Ir:** 4,739,388 → 3,571,913 inclusive (−1,167,475); self
    837,439 → 589,039.
27. **`rt_set_contains` Ir:** 758,659 → 758,659 (unchanged).
28. **`rt_closure_new` Ir:** 0 → 0 (0 calls in both).
29. **UTF-8 seek Ir:** 503,600 → 498,800 (−4,800). The TLD seek moves from
    `rt_substr` (−176,400) into the region consumer's `region_one_scalar`
    (+171,600); `utf8SeekBytes` is 46,000 in both.

**Target-specific**

30. **Dynamic `local_char?` invocations:** 6,800 per run, in both trees.
31. **Dynamic `is_tcl_alpha` invocations:** 1,200 per run. Via
    `rt_call_value` → native in production; as `rt_str_region_is_tcl_alpha`
    in the counterfactual.
32. **Dispatch cost attributable to each:**
    * `local_char?`: gross 408,000 (call site 115,600, common dispatch
      204,000, trampoline 47,600, `guard` 40,800). Measured net removal
      **365,213**.
    * `is_tcl_alpha`: gross 154,800 (call site 20,400, common 58,800,
      native dispatch 75,600). Measured net removal with StringRegion off
      **133,040**.
33. **String materialization attributable to each:**
    * `local_char?`: 6,800 Strings, 3,761,652 in-run + 2,021,640 deferred.
    * `is_tcl_alpha`: 1,200 Strings, 1,248,800 in-run + 356,400 deferred.
34. **Existing StringRegion benefit attributable to each:**
    * `local_char?`: **0**.
    * `is_tcl_alpha`: **−907,618** in-run, net of its dispatch share, plus
      −356,400 deferred. The gross is −1,248,800 of materialization,
      replaced by +380,400 of region access and classification.
35. **Why exact `local_char?` still materializes:** StringRegion's
    `ConsumingShape` rejects `local_char?<str>` at `e190`:
    `immutable_set_contains` is not a supported region consumer. That is
    the only disqualifying node; `is_tcl_alnum(c)` alone would qualify. In
    production it was also generic, which excludes it before the shape
    check.
36. **Why exact `is_tcl_alpha` becomes region-friendly:** it is a
    `ConsumingNative`. `is_tcl_alpha(char_at(i))` with an exact native
    callee is an inline region-consuming operand. `char_at`'s existing
    region companion supplies (base, start, end), and lowering emits
    `callmulti 10` + `strregiontclalpha`, with no new machinery.

**Historical**

37. **Old pre-module-static exact-target benefit:** −19.7% as reported
    (−1,690,581, older binary). Same NIRs on today's binary: −1,685,620
    (−19.75%) in-run; lifecycle −2,280,418 (−20.44%).
38. **New post-module-static exact-target benefit:** −1,405,871 (−17.16%)
    in-run; lifecycle −1,762,271 (−16.66%).
39. **Old benefit already absorbed by module statics:** −279,749 in-run:
    * the 800 per-call closure allocations, −271,918;
    * their creation site in `emailish?`, −8,400;
    * closure-environment access in `local_char?`, −9,200;
    * net of the old counterfactual's flattened-closure parameter
      traffic, +10,000.

    Plus −238,398 deferred (the 800 closures).
40. **How much of the old −19.7% remains:** **83.4%** in-run (1,405,871 of
    1,685,620) and 77.3% over the lifecycle.
41. **Old complexity that disappeared because the target is envless:**
    * a closure-valued target with a per-call identity and an environment;
    * threading or flattening that environment through the scanner, which
      the old counterfactual's `scan_local` paid 10,000 Ir/run for;
    * closure-allocation elision as part of the theorem;
    * callable identity for per-call closure objects.

    Now both targets are program constants, one constant-pool `fnvalue`
    and one root Native.

**Prioritization**

42. **Is finite callable-target provenance still the strongest next
    compiler milestone?** **Yes, by measured ceiling:** 17.16%, vs. R3
    ~3.4–4.3%, range↔blockescape ≤2.02%, Bool control ≤0.62%, and a
    diffuse frame/ABI 6.9%. It is not clearly so on generality (one site).
43. **New measured ceiling:** −1,405,871 Ir/run (−17.16%) foreground,
    −356,400 deferred, −1,762,271 (−16.66%) lifecycle.
44. **Is the ceiling mostly dispatch removal, StringRegion exposure or
    other?** Mostly **StringRegion exposure**: 907,618 (64.6%).
    * Dispatch removal and exact-callee facts are 498,253 (35.4%): pure
      dispatch ≈ 407K, plus `guard` 40,800 and trampoline 47,600.
    * Other consequences are ≈ 2,400 (value loads), and the allocator
      interaction is +40,546.
45. **What would remain dominant afterward:** the local-part scan, at
    79.1% of the counterfactual:
    * 6,800 one-character Strings: 3.80M in-run + 2.02M deferred;
    * `rt_set_contains`: 0.76M;
    * `rt_is_tcl_alnum`: 0.37M.
46. **Does branch-once-before-loop lowering look attractive?** **Yes.** It
    captures ≈1.40M of the 1.41M ceiling for ~3,600 Ir of mode tests,
    provided the variants are visible to `hir::specialize` and
    `hir::stringregion`. As a native-lowering-only transform it would cap
    at ≈0.50M.
47. **Approximate code-size cost:** ≈ +290 B net (+3.3%): two loop bodies
    (+360 B measured) + a ~16 B test − 86 B of callee and value-load
    savings. About +820 B if a generic fallback loop is kept.
48. **Next milestone:** transport the finite target theorem, scoped to
    HIR-level exactness for a closed instance's finite set of
    program-constant callables. The fresh data do not favor another
    *compiler* task. A runtime one-character-String task competes only on
    generality grounds, and is outside the compiler ranking.
