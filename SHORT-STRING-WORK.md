# Short-String work: full account of the session

This document records everything done in one long working session on the
short-String representation of the Botlish native backend: what was asked,
what was built, how it was verified, what was measured, what went wrong and was
corrected, and what is left undecided. It supersedes nothing: the detailed
design reports remain `SHORT-STRING.md` (first milestone),
`SHORT-STRING-TIERS.md` (tiered regime, demand rule, cost breakdown) and
`ASCII-SUBSTRINGS-RECOMMENDATION.md`. This file is the narrative that ties them
together and the place to look first.

## 1. Where things stand

| item | state |
|---|---|
| ShortString1 (one `i64`: -1 Empty, else a Unicode scalar), first milestone | done, tested, measured; was pushed to `main` earlier in the session |
| First-character-recovered counterfactual (`short-first-recovered` cargo feature) | done, full suite passes in a clean worktree; off by default |
| Tiered regime: packed ASCII (<= 8 chars) / ShortString1 (<= 1 char) / tagged; **interned table removed** | done, tested, measured; default on |
| Demand rule (a position none of whose uses is free stays tagged) | done, tested, measured; default on |
| ASCII-substring milestone | analysed; recommendation written (do not do it next) |
| Known regression left in the default configuration | `string_replace` +85 % instructions (see 8) |
| Allocation-weighted cost model / small single-allocation Strings | not implemented; proposed |

Everything described here is on `main` as of the commit that adds this file.
The default configuration of the native compiler therefore includes the tiered
regime and the demand rule. Both have switches (section 9) and
`-short-string-opt 0` reproduces the tagged Strings exactly.

## 2. The requests, in order

1. **First milestone.** A 111-point specification: prove String length <= 1
   from *existing* facts, carry it as `ShortString1`, keep it virtual across
   aliases/joins/exact closed calls, materialize only at String-requiring
   frontiers, measure, and write `SHORT-STRING.md` answering ~72 questions.
2. "Push to main too", then a **counterfactual**: do not cache the first
   character in the String object, recover it from the instance; re-census and
   re-measure.
3. "Is there any Latin-1 representation left in the counterfactual?" (yes:
   the interned materialization table), and "what happens with a
   one-character emoji string?" (answers in section 8 of the first report and
   below).
4. **Tiered regime**: replace the interned table with *known ASCII <= 8 ->
   packed ASCII in an i64, unpacked with shifts/masks; known length <= 1 but
   possibly Unicode -> the scalar in an i64, converted back by UTF-8 encoding;
   otherwise String.* Mid-task addition: use the surplus ASCII high bits for the
   length or other metadata if that increases efficiency.
5. "Could the regressions be addressed by something like the struct
   opportunity-cost heuristic?" -> then **implement a use-based rule** that
   keeps a position tagged when all its uses materialize it, re-measure, and
   write a **recommendation on an ASCII-substring milestone**.
6. "Predict what a general UTF-8 string interning would do", "which of the
   remaining materializations would be pure ASCII / pure UTF-8 / single-
   character potential Unicode", "break the 315 instructions down exactly".
7. This document, and push everything to `main`.

Git rules that applied: the session's designated branch was
`claude/cool-allen-564579`; `AGENTS.md` says to push finished work to `main`
and not to open PRs. The first milestone and the counterfactual were pushed to
`main` when asked; work in progress went to the branch only; this final step
pushes the branch to `main` as asked. No pull request was opened.

## 3. First milestone: ShortString1

### Design decisions

* A Botlish character is a **Unicode scalar value** (the runtime's `StrObj::chars`
  counts scalars; Tcl 9 `string length` counts code points). Surrogates are not
  representable; the maximum scalar is U+10FFFF; U+0000 is `0`, never Empty.
* Representation: one signed `i64`, `-1` Empty, `0..0x10FFFF` the scalar. A
  distinct NIR kind (`shortregs=`, `shortparams=`, `shortresult=1`, `shortlit`,
  `strtoshort`, `shorttostr`, `shortlen`, `shorteq`, `strsliceshort`), distinct
  from tagged Values and from `RawInt` (RawInt was left frozen), never a GC
  root, never a source type.
* **Proof** (`native/shortstring.tcl`): no new inference. The fact query
  composes literals, immutable alias chains, `hir::range` branch outcomes and
  reachability (dead branches contribute nothing), the existing induction width
  of `substring(t, i, i + K)`, `hir::exact` constants, closedness/call targets
  from `hir::specialize`, `hir::escape::Exits` for result exits, and
  `hir::construction` (plan positions are excluded). Parameters and results are
  least fixpoints over the call graph.
* **Selection categorical**: proven length <= 1 => ShortString1. No profit
  score, no use count, no demand suppression (this is what the later
  milestones revisit).
* **Authoritative ABI plan**, computed once per closed codegen instance,
  *after* the construction analysis (so plan positions can be excluded) and read
  by callee lowering and every exact caller. Open/dynamic boundaries,
  storage (List, MutableArray, struct fields, statics, captures, sets,
  ok/error payloads), hashing and FFI stay tagged.
* **Error-capable results** use the existing status-word convention (value plus
  status); Empty is a value, never the failure encoding.
* Lowering: a `want short` demand, conversions cached in the shared region
  cache (so branch scoping is inherited), `Bind` virtualizes statement-position
  locals, `if` joins in one short register, scalar `length` and `==`, a
  `substring` producer (`regioncheck` then an infallible `strsliceshort`), and a
  region-first precedence rule so the existing String-region virtualization
  always wins.
* Backend: kind-based NIR validation (a mismatch is a lowering bug, never a
  silent conversion), generic-entry wrappers that convert (never reachable from
  a Botlish program, exercised by Rust tests), a prologue that defines short
  parameters as scalars, inline `StrToShort` using a first-scalar field added
  to `StrObj` in what was padding (no growth), inline interned-table probe for
  `ShortToStr`, root analysis that excludes scalar registers.
* Switch: `-short-string-opt 0` / `BOTLISH_NATIVE_SHORT_STRING_OPT=0`.

### Verification and measurements (first milestone as shipped)

* 59 behavioral/NIR tests (`tests/short-string.test`), Rust tests, a bounded
  differential fuzz generator (1,471 + 491 GC-stress + 291 specialization-off
  programs, 0 disagreements), the full regression, GC stress, standalone
  executable parity.
* Corpus (17 programs, 233 functions): machine code 101,879 -> 102,423 bytes
  (+0.53 %); instruction counts `uri-steady` -16.6 %, `ai_text_clean` -64.5 %,
  `source-checks` -10.3 %, `refined-checks` +1.7 % (the mixed-use frontier the
  milestone exists to expose plus the runtime's new per-String field), others
  within +/- 0.8 %; the five programs without Strings unchanged.
* `SHORT-STRING.md` answers all required questions and holds the censuses
  (conversion, virtualization, materialization classes).

### Problems found and fixed while building it

* A plan-result/short-result conflict (INVALID-NIR) fixed by passing the
  construction analysis into the planner and excluding plan positions.
* A hashtable allocation regression fixed by interning the Latin-1 static
  Strings (the table this session later removed).
* String-region NIR tests broke because both virtualizations claimed one
  position; fixed by the region-first rule.
* `refined-checks` +6 % reduced to +1 % by implementing the two conversions
  inline rather than as helper calls.
* The fuzz generator initially did not terminate (a tail style missing a
  `return`); the census undercounted locals in the seven lowering variants until
  every variant's info carried the short counters.
* One failure of the native-coverage run (`refined-5`) is pre-existing: it
  fails identically at the parent commit and with the optimization off.
* Existing representation pins (five test files) were adapted with
  `-short-string-opt 0`, following the RawInt precedent.

## 4. The counterfactual: first character recovered, not cached

The cargo feature `short-first-recovered` (off by default) removes
`StrObj::first`. `StrToShort` then loads the `ASCII` flag, returns the first
text byte for ASCII Strings (one load through the `Box<str>` data pointer, whose
offset is measured at startup because Rust does not guarantee the fat-pointer
field order) and calls `rt_str_to_short` for non-ASCII ones.
`BOTLISH_NATIVE_BIN` selects an alternative driver without replacing the shipped
one; `BOTLISH_AUDIT_FEATURES` builds the audit binary with a feature.

Results: the census is byte-identical (the planner sits above this choice); the
off configuration returns exactly to baseline (the shipped +0.73 % in
`refined-checks` was the per-String store); the conversion costs about 5.7
instructions more per `strtoshort`; net `refined-checks` +1.74 % versus +1.70 %;
`uri-steady` 0.2 % better; machine code +88 bytes; compile time and wall-clock
within noise. Full suite in a clean worktree: 3,792/3,792 and 3,788 + 4 skipped.

Mistake corrected: the first full run of this counterfactual was invalid (it
ran while the working tree was being edited) and a second attempt failed
because executables need the runtime library next to the binary; the third run,
in a clean worktree built with the feature, is the one reported.

## 5. The tiered regime (and the table's removal)

### Layout of packed ASCII

```
byte i (bits 8i..8i+7) = 0x80 | c   for the character c at index i
absent bytes           = 0
```

The spare high bit of each ASCII byte is a presence flag, so the eight flags are
a thermometer code for the length: no length field is needed. Length is
`(71 - clz(w)) >> 3`, equality is word equality (the form is canonical), the
empty String is `0`, NUL is a present `0x80`, unpacking to String bytes is one
AND with `0x7F7F7F7F7F7F7F7F` and one 8-byte store. Alternatives considered for
the spare bits: 7-bit packing plus a 4-bit length (one-shift length, but
per-character shifts to unpack, or `pdep`, not baseline), and a separate length
field (impossible at 8 characters). SIMD was not used: the unpack is already a
single scalar AND and store.

### What changed

* Planner facts became `{lo hi asc known}` (a character-count range and an ASCII
  bit); join is the least upper bound; a tier is `ascii` (ASCII and hi <= 8),
  else `short` (hi <= 1), else none. ASCII-ness has one source, a literal.
* A third NIR kind: `asciiregs=`, `asciiparams=`, `asciiresult=1`, `asciilit`,
  ops `strtoascii`, `asciitostr`, `asciilen`, `asciieq`, `asciitoshort`,
  `asciishorteq`; validator, generic-entry wrappers, status words, roots.
* Cross-tier handling: a packed value in a ShortString1 position widens with
  `asciitoshort`; equality of the two tiers uses a sentinel so a scalar above 0x7F
  or a longer word is simply unequal.
* **The interned table is gone** (`Vm.short_cache`, 257 interned objects, the
  inline probe). `shorttostr` and `asciitostr` allocate; a statically known
  literal materializes to a `str` constant.
* Switches: `-ascii-pack-opt` (`BOTLISH_NATIVE_ASCII_PACK_OPT=0`) turns tier A
  off alone.

### Verification

* `tests/packed-ascii.test` (47 tests), `tests/short-string.test` (59, now with
  the ASCII tier off), Rust tests (104 + 28; new packed-layout, kind-validation
  and generic-entry tests), the fuzz generator extended with ASCII 2..8
  characters, NUL/DEL inside, the 8/9-character boundary and a non-ASCII
  multi-character control: 1,471 + 491 + 291 programs, 0 disagreements.
* Full suite: the same 9 tests failed in both passes (six `ht-alloc-*`, two
  `csv-records-alloc-readback-*` allocation counts and one NIR shape pin): real
  consequences of the regime, left failing deliberately instead of being
  adapted away.

### Result (instruction counts versus the pre-milestone commit)

Removing the table cost about 315 instructions per runtime materialization:
`refined-checks` +1.7 % -> +42.8 %, `source-checks` -10 % -> +36 %, `uri-steady`
-16.5 % -> -2.6 %, `ai_text_clean` -64.5 % -> -54 %. Packing literal-fed
parameters added materializations per call (per iteration in a loop):
`hashtable` +71 %, `string_replace` +99 %, `csv_records` +6 %. Code +1.05 %,
compile time about +5 %, wall-clock agreeing in direction.

## 6. The demand rule

The struct scalar-replacement precedent applied to String positions
(`-short-demand-opt`, default on): a parameter, result or local that has a tier
stays virtual only if it has a **free use** (a scalar `length`/`==` consumer, or
a flow into another position that is itself virtual and useful). Usefulness is
the least fixpoint of "has a free use", so forwarding cycles never justify
themselves, and anything the walk does not understand is not free: the rule can
only turn a position tagged. Two lowering facts are folded in so the rule matches
the code generator: a call lowered as a String-region companion (tagged
arguments) is not a flow, and a local kept as a region is not a candidate
(the first version missed the companion case and still re-materialized a packed
text parameter every loop iteration).

Results (instruction counts, `out/ir-demand.txt`): `refined-checks` +42.8 % ->
+0.7 %, `source-checks` +37 % -> +0.5 %, `hashtable` +71.6 % -> +0.1 %,
`csv_records` +6.1 % -> -0.1 %, `ai_text_clean` -54 % kept, `uri-steady` -2.6 %
-> +0.3 % (the small gain was a producer allocation, which a use count cannot
see), **`string_replace` +99 % -> +85 %** (its packed parameters each have a
scalar `length` use but are materialized 35 times at about 290 instructions
each). `tests/short-demand.test` (17 tests); the representation pins run with
the rule off and every parity test covers both settings; full suite 3,855/3,856
and 3,851 + 4 skipped, the one failing pin (a count of `op strlen`, now
`asciilen`) adapted with the switch off; fuzz with the rule varied: 0
disagreements over the same 2,253 programs.

## 7. Analyses and answers produced along the way

* **Latin-1 left in the counterfactual**: only the interned materialization
  table (it is independent of the first-character field); strings are UTF-8
  `Box<str>`, and non-ASCII extraction takes the helper.
* **A one-character emoji**: one scalar (e.g. `0x1F600`); virtual with no
  storage; extraction from a String takes the cached first scalar (shipped) or
  the decode helper (counterfactual); materialization always allocated for
  scalars above U+00FF; multi-scalar sequences (ZWJ, flags, skin tones) are
  longer than one character and stay tagged.
* **The struct opportunity-cost heuristic**: yes for the regressions that are
  "materialization-dominated positions"; needs an allocation-weighted model
  (producer allocation avoided + scalar consumer savings versus runtime
  materializations, literals free) and an interprocedural fixpoint; implemented
  only in its first, use-based form (section 6).
* **General UTF-8 interning (prediction)**: a small direct-mapped cache keyed by
  the virtual value (a packed word or scalar is a perfect key; structural
  equality means it need not be canonical) would likely restore the first
  milestone's gains and cut `string_replace` to roughly +5-10 %; interning every
  String would likely be a net loss (hash + probe + insert on every
  construction, a weak table in a precise GC, equality only ~6 % of one
  profile). Not built.
* **What still materializes at run time** (counters in a scratch build, one run
  per program): 75 proven-ASCII packed materializations (`string_replace` 35,
  `hashtable` 22, `csv_records` 15, `refined-checks` 3) and 20,935 ShortString1
  ones, of which 19,023 (91 %) turned out to be ASCII, 912 Latin-1 non-ASCII,
  1,000 BMP, 0 astral; none statically known non-ASCII.
* **Cost of a materialization**: 311.6 instructions on the allocation side
  (glibc `malloc` x2 140.2, runtime code 126.7 of which `Vm::alloc` 40.5,
  `short_to_string` 32.7, `new_str_known` 32.2, `rt_short_to_str` 11.3, other
  10.0; Rust allocator shims 25.5; `memcpy` 12.1; GC bookkeeping 4.5; other
  2.6), and about 862 over the whole life cycle in a churn heap (about 500
  allocation + about 360 free). The earlier "315" omitted the free side because
  the measured windows run no collection.
* **ASCII substrings** (`ASCII-SUBSTRINGS-RECOMMENDATION.md`): not as the next
  milestone. 15 live `substring` sites; ASCII-provable bases in 4 today, 8 with
  ASCII kept for any length; 0 multi-character constant-width ASCII slices;
  25,200 of 25,240 dynamic slices are width 1 and about half have a non-ASCII
  base. A proof does not make materialization cheaper (still allocates); it only
  enables virtualizing multi-character ASCII slices, which the corpus lacks.
  Do a measurement-only step first; prefer making materialization cheaper.

## 8. Mistakes, corrections and caveats

* The invalid counterfactual regression runs described in section 4.
* Two `pkill -f` calls matched my own shell or sibling test runs; later waits
  used until-loops on pid/cwd checks.
* The wall-clock figures for tiny kernels are noisy and were never used as the
  figure of record; instruction counts are. Baseline counts of the ~100k
  instruction programs move by up to ~0.9 % between runs.
* A scratch copy of the crate built outside the repository checkout panics in
  `rt_construct` on allocation-heavy programs because it lacks the repo-root
  `.cargo/config.toml` that forces frame pointers for the native stack-map GC
  walker. All measured binaries were built from inside a checkout.
* A mis-ordered attribution: the "315 instructions" figure was a whole-program
  delta without the free side (section 7).
* A claim in an early draft that module-level literal bindings stay tagged was
  wrong (they are virtualized in the program function and passed as the
  constant); the test was rewritten to assert what actually happens.
* The `string_replace` regression in the default configuration is known and
  documented; the allocation-weighted model that would remove it was not built.
* The first-milestone full regression and the later full regressions ran
  against snapshots of the working tree (a copy with the built runtime library)
  so that edits during a multi-hour run could not contaminate them.

## 9. Switches and environment variables

| switch | env var | effect |
|---|---|---|
| `-short-string-opt 0` | `BOTLISH_NATIVE_SHORT_STRING_OPT=0` | no short Strings at all (tagged Strings as before) |
| `-ascii-pack-opt 0` | `BOTLISH_NATIVE_ASCII_PACK_OPT=0` | no packed ASCII tier (ShortString1 only) |
| `-short-demand-opt 0` | `BOTLISH_NATIVE_SHORT_DEMAND_OPT=0` | categorical selection (no demand rule) |
| cargo `--features short-first-recovered` | | counterfactual runtime/codegen (no cached first scalar) |
| | `BOTLISH_NATIVE_BIN` | use another driver binary (audit/measurement) |
| | `BOTLISH_AUDIT_FEATURES` | cargo features for the audit build script |

## 10. Files

* Planner and lowering: `native/shortstring.tcl` (new), `native/lower.tcl`,
  `native/native.tcl`, `native/explain-native.tcl`.
* Rust: `native/src/nir.rs` (kinds, header attributes, ops, validation),
  `codegen/clif.rs` and `codegen/roots.rs` (lowering, wrappers, roots),
  `codegen/mod.rs` (generic-entry tests), `runtime/{ops,vm,value,heap}.rs`
  (helpers, packing, the `first` field), `Cargo.toml` (feature).
* Tests: `tests/short-string.test` (59), `tests/packed-ascii.test` (47),
  `tests/short-demand.test` (17); adapted: `tests/native.test`,
  `native-string-region.test`, `native-string-view.test`,
  `native-block-escape.test`, `virtual-construction.test`,
  `native-validator-predicate.test`.
* Audit tooling: `audit/short-string/` (corpus, census, explain, codesize,
  roots, compiletime, nativebench, ir/ir2, fuzz, emit-base-nir,
  `materialize-cost/`), with measured output in `out/`; the callgrind helper
  script `audit/post-r2a-dynamic-census/tools/build-audit-native.sh` gained
  `BOTLISH_AUDIT_FEATURES`.
* Reports: `SHORT-STRING.md`, `SHORT-STRING-TIERS.md`,
  `ASCII-SUBSTRINGS-RECOMMENDATION.md`, this file.

## 11. Open decisions

1. Accept `string_replace` +85 %, or build the allocation-weighted model
   (needs the per-position benefit/cost walk, an interprocedural suppress-and-
   iterate pass, and a cost of about 300-860 instructions per runtime
   materialization).
2. Make materialization cheap: a direct-mapped cache keyed by the virtual
   value (cheap prototype, predicted to restore the first milestone's gains) or
   a single-allocation small String in `StrObj` (a storage milestone; about 70 %
   of the life-cycle cost is the two allocations and their free).
3. Keep the tiered regime default-on or revert to ShortString1 only
   (`-ascii-pack-opt 0` default).
4. ASCII provenance only after a measurement-only step on a real text-
   processing workload.

## 12. Reproducing

```
cargo build --release --manifest-path native/Cargo.toml
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 tests/short-string.test; tclsh9.0 tests/packed-ascii.test; tclsh9.0 tests/short-demand.test
tclsh9.0 tests/all.tcl                         # full regression (two passes)
tclsh9.0 audit/short-string/tools/corpus.tcl   # values and static counts
tclsh9.0 audit/short-string/tools/census.tcl
tclsh9.0 audit/short-string/tools/ir2.tcl BIN BASE-BIN BASE-NIR-DIR M1-BIN M1-NIR-DIR OUTDIR
tclsh9.0 audit/short-string/tools/fuzz.tcl -n 1500 -seed 1
```

Audit builds must be made from inside a repository checkout (root `.cargo`
config, frame pointers); see `audit/short-string/README.md`.
