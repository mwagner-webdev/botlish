# Fuzzing the example applications, AOT first

Botlish's first AFL-based fuzzing campaign over the **compiled example
applications** (not the compiler), with cross-vertical failure tracing:
every failure is replayed through every execution vertical
(`interp`, `compile`, `cranelift`, `cranelift-generic`) and the divergence
pattern names the buggy layer.

```
examples/  ->  AOT native executables  ->  afl-fuzz campaigns  ->  failure corpus
                                                              |
                                    replay every failure through the other verticals
                                    (interp, compile, cranelift, cranelift-generic)
                                                              |
                                    deduplicated, minimized, classified findings
```

Campaign date: 2026-10-03/04. Platform: x86_64 Linux (WSL2, Ubuntu 24.04,
12 cores, 15 GiB RAM). Toolchain: AFL++ **4.09c** (pinned upstream source,
built unprivileged under `fuzz/tools/afl` by `fuzz/scripts/setup-host.sh`,
including QEMU mode; qemuafl `a1321713c7502c152dd7527555e0f8a800d55225`).
Everything is reproducible from `bash fuzz/scripts/run-all.sh`
(see `fuzz/README.md`).

## 1. Inventory: what the examples actually read

`fuzz/scripts/inventory.tcl` states the mechanical facts per example
(committed as `fuzz/inventory.tsv`, 34 programs); the classification:

* 34 example programs: 9 `examples/stdlib/*.bot`, 14
  `examples/surface/*.bot`, 6 `examples/hir/*.hir`, 5 `examples/*.ir`
  (`corpus.tcl` and the empty `main.tcl` are tooling, not programs).
* **No example program reads any input.** Botlish's single external input
  channel is `argv()` (ARGV.md) and no example calls it (source scan;
  there is no other I/O in the language). Per the brief's classification
  (#5) every example is "reads nothing -> not fuzzable as-is" *at the
  language level*.
* Every **standalone AOT executable does consume its process argv at the
  runtime level** (`native/src/runtime/aot.rs`: `args_os()` bytes ->
  `Vm::set_argv` before program entry), whether or not the program
  observes it. That runtime snapshot path is the executables' one real
  input surface and is exactly the brief's "reads argv fields -> limited
  fuzzing; document what is reachable" case -- so the campaign fuzzes it,
  with the reachable surface documented: glibc/Rust argv plumbing plus the
  runtime's snapshot copy; **`rt_argv` (UTF-8 validation, String/List
  construction) is unreachable because no example calls `argv()`**.
* 21 of the 27 compilable programs (`.bot`/`.hir`) emit standalone
  executables (`fuzz/scripts/build-aot.sh`, the repository's own
  `main.tcl -emit-native-executable` path). The other 6 fail the AOT
  readiness gate exactly as designed (`NATIVE AOT NOT-READY`, guarded
  workloads; README §19): `csv_chunked`, `csv_geometric`, `csv_records`,
  `hashtable`, `03-closure.bot`, `02-closures.hir`. They still
  participate in the differential matrix on the four in-process
  verticals (nothing is silently ignored).
* Two surface examples are deliberate negative programs that fail
  compilation by design (`09-mutual-recursion.bot`,
  `10-duplicate-binding.bot`; both carry `expect-error:` headers). The
  five `.ir` examples are core-IR text, rejected by the AOT emitter **by
  design** (`NATIVE AOT INPUT`; the native path never starts from core
  IR -- DIRECT-HIR-NATIVE-PATH.md); they run the interp/compile pair in
  the differential matrix.

| group | programs | AOT executables (fuzz targets) | in-process only | negative (by design) | core-IR-only |
|---|---|---|---|---|---|
| stdlib | 9 | 5 | 4 | 0 | 0 |
| surface | 14 | 11 | 1 (`03-closure`) | 2 | 0 |
| hir | 6 | 5 | 1 (`02-closures`) | 0 | 0 |
| root `.ir` | 5 | 0 | 0 | 0 | 5 |
| **total** | **34** | **21** | **6** | **2** | **5** |

Expected failure exit code of an AOT executable: **1** -- a language-level
failure prints `MESSAGE (ERRORCODE)` to stderr and exits 1
(`native/src/runtime/aot.rs`); success prints the value to stdout, exit 0.
A runtime panic also exits 1 but carries a `NATIVE BUG` marker (#28:
panics are crash candidates, distinguished by text, not exit code).

Unfuzzable-as-targets, one line each (#6):

* the 6 NOT-READY programs: no standalone binary exists to fuzz (the
  readiness gate is the designed boundary; in-process verticals still
  cover them differentially);
* the 2 negative examples: they do not compile, by construction;
* the 5 `.ir` examples: the AOT path starts from HIR by design, so there
  is nothing to emit;
* `examples/surface/main.tcl` (empty) and `examples/stdlib/corpus.tcl`:
  tooling, not programs.

`bench/*.bot` are benchmarks, not example applications, and share the
same no-input property; they are out of this campaign's scope by the
brief ("fuzz the example applications") and noted here so the boundary is
explicit.

## 2. Instrumentation decision and blind spots

Chosen: **AFL++ QEMU mode (`-Q`) over the plain release AOT binaries**
(the brief's option 2; option 1 -- existing instrumented-AOT support --
does not exist in the repository).

* Ubuntu's `afl++` package ships neither `afl-qemu-trace` nor Frida
  support, so "install the distro package" was never a QEMU/Frida option;
  QEMU mode was the cheaper of the two to **build** unprivileged from the
  pinned AFL++ source (configure+make with a handful of `.deb`-extracted
  build dependencies; Frida mode additionally requires the frida-gum
  devkit). Ubuntu 25.04's and Debian's packages were spot-checked: same
  packaging, no QEMU binaries.
* It requires **no compiler or runtime changes** (#14: default "no";
  escape hatch not exercised).
* QEMU mode sees every instruction the process executes -- Rust runtime,
  generated program code and glibc alike -- so it has no generated-code
  blind spot (the reason runtime-only instrumentation, option 4, ranks
  below it).
* ASan builds (see §6) are the sanitizer second pass, not the primary.

Blind spots, stated plainly (#12):

* Kernel-side work (the exec-time argv copy) is invisible; only its
  userspace effects are measured.
* The decisive limitation is structural, not instrumentation: **none of
  the 21 programs' behavior depends on the input**. Coverage is a
  function of the harness/glibc/runtime argv plumbing only, saturates at
  16-22 corpus entries per target, and every target then plateaus (last
  new find within the first ~1 min of each 20 min run; 54 of 55 queue
  cycles without finds on `csv`, representative for all). The campaign
  measures this and says so; it does not pad it.
* Display-level oracle limits: the differential comparison must ignore
  Tcl-side `#{Type}` refinement annotations (documented runner behavior;
  see §5), which caps what stdout comparison can see for refined values.

## 3. Harness, seeds, dictionaries

* Harness (`fuzz/harness/argv-file.c`, compiled by `setup-host.sh`): the
  input file *is* the argv vector -- NUL-separated byte sequences become
  `argv[1..]`, a trailing NUL terminates without adding an empty
  argument, an empty file is the bare invocation. This is the brief's
  sanctioned wrapper shape (#5, #10: "a wrapper script in the fuzz tree
  that supplies fixed argv plus an `@@` file"). `E2BIG` (argument above
  the kernel's 128 KiB per-arg limit) exits 126: harness behavior, not a
  target crash. No example was modified.
* Seeds (`fuzz/seeds/<target>/`, committed): derived from each example's
  own material -- the CSV subset `csv.bot` documents, ai_text_clean's
  code points, the string examples' driver strings, i64 boundary strings
  (SOURCE-DEFINED-INTEGER-DOMAINS.md) -- plus the structural checklist
  for every target: empty vector, one empty argument, NUL-separated
  multi-argument vectors, invalid UTF-8 bytes, a ~100 KiB argument, 500
  small arguments. `afl-cmin` (QEMU mode) minimized 8-18 per target down
  to 7-9 distinct-coverage seeds (#18); a fresh regeneration reproduces
  the committed sets byte-for-byte (verified).
* Dictionaries (`fuzz/dictionaries/`, committed, one-line rationale in
  each): `csv.dict` (csv family), `text.dict` (ai_text_clean's
  punctuation/emoji), `numeric.dict` (integer edges; arithmetic-flavored
  targets). Attached only to format-matching targets. AFL's own bundled
  dictionaries have no CSV/UTF-8-cleaning format that matches, hence
  hand-built from the examples' own documented tokens.

## 4. Campaign parameters per target

All 21 targets, release build and ASan pass alike: `-Q` (QEMU mode),
`-m none`, `-G 100000` (input cap just under the kernel's 128 KiB
per-argument limit), input as the argv vector through the harness,
crash oracle = signals only.

* Timeout `-t 200` for every target: 10x the slowest baseline seed
  (baselines are 2-25 ms per run; `fuzz/baselines/*.tsv`), floored at
  the brief's 200 ms -- the floor governs everywhere. QEMU mean exec
  (~2.5 ms) is far below it; `slowest_exec_ms` stayed 0 in every
  fuzzer_stats -- no run approached the timeout.
* Budget: 1200 s (20 min) per release target, one master each, 12 cores
  filled by parallel masters of *different* targets (two batches of 12
  and 9). With one shared, shallow input surface, parallel masters on
  distinct programs dominate secondaries on the same program; the brief's
  secondary pattern is reserved for the growth-extension rule, which no
  target triggered (all plateaued). Total: 21 x 1200 s = **7.0 CPU-hours,
  8,411,896 executions**. Recorded before the run, enforced by AFL's own
  `-V`, proven by 5-minute snapshot intervals (`fuzz/campaign-stats/`).
* Memory: `-m none`, recorded, mandatory with the ASan pass.
* Crash-exitcode: `AFL_CRASH_EXITCODE` deliberately unset -- expected
  failure exit 1 must not count as a crash (#27). Exit-1 outputs are
  inspected in triage (none occurred: every executed input in every
  campaign run exited 0).
* Environment (scripted in `setup-host.sh` and `campaign.sh`):
  `AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1` (WSL routes core dumps to a
  pipe handler; without root, `core_pattern` cannot be changed --
  reported, not hidden), `AFL_SKIP_CPUFREQ=1` (no governor interface in
  WSL). Host: 12 cores, `/proc/sys/kernel/core_pattern` = WSL's
  `|/wsl-capture-crash`.

## 5. Differential matrix (input replayed across verticals)

`fuzz/scripts/differential.sh` + `fuzz/scripts/replay.tcl`: every target
x committed seed x {aot, interp, compile, cranelift, cranelift-generic}
plus the 6 in-process-only programs x their seed sources x the four
in-process verticals, and the 5 `.ir` programs x an empty vector on
interp/compile -- 1044 recorded runs. Normalization extracts the value
(or language error code) and exit status per vertical.

Result: **1011 compared runs, 0 hard mismatches.** Two documented exception classes are
recorded as data, not findings:

* `known-limitation` (17 rows): `cranelift-generic` cannot run
  `csv_records` (`NATIVE UNSUPPORTED struct-shape`) -- the repository's
  own documented baseline gap with the cranelift stand-in policy
  (`examples/stdlib/corpus.tcl`, `tests/helpers.tcl`).
* `display-divergence` (16 rows): `06-refined-strings` on `interp` and
  `compile` shows `ok("a%40b.io"#{UriQueryValue})` where the native
  verticals print `ok("a%40b.io")`. The `#{Type}` suffix is main.tcl's
  documented "runtime evidence" annotation (Tcl-side show); the value
  itself, the error channel and the exit status are identical. This is a
  display-layer difference between the runners, not a semantic
  divergence; the comparison strips `#{...}` annotations before judging
  and any other difference would still count as a mismatch.

Nondeterminism probe (#30): every replayed (vertical, input) pair was
stable (the matrix itself is a repeat; spot-checked repeats identical;
AFL `stability` 100.00% on all 21 targets).

## 6. Campaign statistics

Release pass (QEMU mode, 1200 s/target; full tables and snapshot history
committed under `fuzz/campaign-stats/2026-10-04/release/`):

| target | execs | execs/s | bitmap_cvg | corpus (found) | crashes | hangs | cycles w/o finds |
|---|---|---|---|---|---|---|---|
| 01-arithmetic | 350050 | 292 | 0.09% | 19 | 0 | 0 | 42 |
| 01-scopes | 342765 | 286 | 0.09% | 18 | 0 | 0 | 18 |
| 02-recursion | 357361 | 298 | 0.09% | 19 | 0 | 0 | 35 |
| 03-recursion | 350409 | 292 | 0.09% | 17 | 0 | 0 | 38 |
| 04-branch-value | 358707 | 299 | 0.09% | 19 | 0 | 0 | 35 |
| 04-refinement | 346788 | 289 | 0.09% | 19 | 0 | 0 | 33 |
| 05-control | 342018 | 285 | 0.09% | 19 | 0 | 0 | 42 |
| 05-shadowing | 331072 | 276 | 0.09% | 17 | 0 | 0 | 35 |
| 06-list | 326353 | 272 | 0.09% | 21 | 0 | 0 | 26 |
| 06-refined-strings | 331288 | 276 | 0.09% | 20 | 0 | 0 | 35 |
| 07-loop-break | 327978 | 273 | 0.09% | 16 | 0 | 0 | 32 |
| 08-return | 345852 | 288 | 0.09% | 18 | 0 | 0 | 33 |
| 11-boolean-operators | 485347 | 404 | 0.09% | 20 | 0 | 0 | 45 |
| 12-if-value | 489425 | 408 | 0.09% | 22 | 0 | 0 | 42 |
| 13-hygiene | 484631 | 404 | 0.09% | 20 | 0 | 0 | 56 |
| 14-modules | 489217 | 408 | 0.09% | 19 | 0 | 0 | 66 |
| ai_text_clean | 473443 | 395 | 0.09% | 18 | 0 | 0 | 44 |
| csv | 484876 | 404 | 0.09% | 17 | 0 | 0 | 54 |
| matmul | 485381 | 404 | 0.09% | 19 | 0 | 0 | 48 |
| string_replace | 443893 | 370 | 0.09% | 19 | 0 | 0 | 23 |
| string_reverse | 465042 | 388 | 0.09% | 21 | 0 | 0 | 39 |
| **total** | **8411896** | | | | **0** | **0** | |

(bitmap_cvg is relative to AFL's 65536-slot map; absolute edge counts are
~50-60 tuples per target, matching the shallow reachable surface.
Snapshot files every 300 s plus per-run `plot_data` are committed.)

ASan pass (`campaign-asan.sh`, 600 s/target over the ASan-instrumented
executables of `build-asan.sh`, same harness and QEMU mode,
`ASAN_OPTIONS=abort_on_error=1:detect_leaks=0`; snapshots committed under
`fuzz/campaign-stats/2026-10-04/asan/`):

| target | execs | execs/s | corpus | crashes | hangs |
|---|---|---|---|---|---|
| 01-arithmetic | 65000 | 108 | 18 | 0 | 0 |
| 01-scopes | 32200 | 54 | 18 | 0 | 0 |
| 02-recursion | 64731 | 108 | 20 | 0 | 0 |
| 03-recursion | 32000 | 53 | 17 | 0 | 0 |
| 04-branch-value | 32038 | 53 | 17 | 0 | 0 |
| 04-refinement | 64112 | 107 | 23 | 0 | 0 |
| 05-control | 32231 | 54 | 20 | 0 | 0 |
| 05-shadowing | 64544 | 108 | 19 | 0 | 0 |
| 06-list | 62263 | 104 | 18 | 0 | 0 |
| 06-refined-strings | 54051 | 90 | 18 | 0 | 0 |
| 07-loop-break | 64895 | 108 | 19 | 0 | 0 |
| 08-return | 63705 | 106 | 20 | 0 | 0 |
| 11-boolean-operators | 38844 | 65 | 19 | 0 | 0 |
| 12-if-value | 39350 | 66 | 24 | 0 | 0 |
| 13-hygiene | 80566 | 134 | 18 | 0 | 0 |
| 14-modules | 36949 | 62 | 18 | 0 | 0 |
| ai_text_clean | 36998 | 62 | 19 | 0 | 0 |
| csv | 36577 | 61 | 20 | 0 | 0 |
| matmul | 77128 | 129 | 19 | 0 | 0 |
| string_replace | 36633 | 61 | 20 | 0 | 0 |
| string_reverse | 76472 | 127 | 19 | 0 | 0 |
| **total** | **1091287** | | | **0** | **0** |

Combined campaign total: **9,503,183 executions** (8.41M release + 1.09M
ASan), zero crashes, zero hangs, zero sanitizer reports.

## 7. Findings

**Zero confirmed bugs.** Raw crash count: 0 (release pass) + 0 (ASan pass)
placeholder (ASan pass). Hangs: 0. Deduplicated/minimized findings: none
to deduplicate (`fuzz/scripts/triage.sh` reports "no raw crashes or hangs
found"). No bug was fixed in this milestone (nothing to fix); no example
was modified; the compiler and runtime are untouched (see §10).

The zero is *explained*, not luck-shaped: the fuzzed surface is the
executable boundary (argv bytes -> runtime snapshot), every target's
behavior is input-independent, and 8.4M executions across it found
nothing. The layers behind that boundary were still exercised
cross-vertically by the differential matrix over all 34 programs (§5),
which is where a miscompile would have shown -- also zero (modulo the two
documented display/baseline exceptions).

## 8. Pre-fuzzing findings

None. Every one of the 21 targets built AOT cleanly on its first
post-setup emission, and every target x seed baseline run exits 0 with
exactly the documented `expect:` value (`fuzz/baselines/*.tsv`,
regenerated and identical across two machines/filesystems). The 13
non-emitting examples fail only through designed gates (§1).

## 9. Performance observations (#52)

* QEMU-mode throughput: 272-408 execs/s per target (2.5-3.7 ms/exec
  including fork+exec of the harness and target); the same binaries run
  natively in ~2 ms. QEMU + fork overhead is the campaign's own cost, not
  a program observation.
* `max-arg` (~100 KiB single argument) runs stay within a few ms natively
  and well under `-t` under QEMU; nothing slow was discovered relative to
  the baselines.
* GC-stress replay (`--gc-stress`) of representative inputs runs in
  milliseconds-to-seconds: no pathological allocation behavior observed.

## 10. Verification: the repository is unchanged where it must be

* Full regression (`tclsh9.0 tests/all.tcl`) passes unchanged with the
  fuzz tree present: **4852 total, 4848 passed, 4 skipped
  (pre-existing `coreScoping` constraint), 0 failed** -- byte-identical
  to the pre-campaign baseline run.
* Every example still compiles AOT (`build-aot.sh`: 21 ok / 13 by-design
  failures, identical to the pre-campaign state) and matches its recorded
  baseline on seeds (baseline stdout columns identical before/after).
* The campaign required no compiler or runtime semantic changes; the only
  tracked files this milestone adds live under `fuzz/` plus this report
  and the `.gitignore` entries.
* Every campaign step is a committed script (`fuzz/scripts/run-all.sh`
  runs the whole thing; `fuzz/README.md` documents each entry point).
* Known-failure replay suite: `fuzz/scripts/replay-known-failures.tcl`
  covers every filed finding (currently zero, so it reports that) and has
  a `--selftest` that packages a synthetic finding, replays it across all
  five verticals and compares -- run as part of `run-all.sh`, keeping the
  machinery continuously exercised and CI-able (non-gating, optional #47).
* GC-stress / sanitizer / valgrind replay was used where cheap: GC-stress
  on AOT replays (§9), the ASan pass (§6), valgrind spot replays via
  `replay.tcl --valgrind` (clean on `csv`).

## 11. Required questions (brief §62-§65)

Campaign setup:

1. 34 example programs (inventory in §1 / `fuzz/inventory.tsv`); none
   reads any input at the language level; every AOT executable consumes
   its process argv at the runtime level.
2. Fuzzable: 21 (AOT executables, runtime-argv surface). Not fuzzable:
   6 (AOT gate NOT-READY, by design), 2 (negative examples), 5 (core-IR
   inputs, excluded from the AOT path by design) -- each recorded with
   its reason, none hidden, and the 6+5 still covered by the differential
   matrix where their verticals exist.
3. AFL++ QEMU mode (`-Q`), built unprivileged from pinned source 4.09c;
   blind spots in §2 (the structural one dominates: input-independent
   programs).
4. Compiler changes required: **no** (the #14 escape hatch was not
   exercised).
5. Budget 1200 s/target (7.0 CPU-hours total), `-t 200` everywhere
   (baseline-derived, floor-governed), `-m none`; recorded per target in
   §4/§6 and in the archived stats.
6. Seeds minimized via `afl-cmin` and committed with dictionaries: **yes**
   (§3).

Oracle and triage:

7. A bug is: a crash signal (SIGSEGV/SIGBUS/SIGILL/SIGABRT, sanitizer
   abort), a runtime panic marker (`NATIVE BUG`, panicked-at), an
   unexpected exit (exit 1 without a language-level error code), a
   differential mismatch beyond the two documented exception classes, or
   nondeterminism. Counts this campaign: 0 / 0 / 0 / 0 / 0.
8. Expected failure exit code 1 excluded from crash counts: **yes**
   (oracle is signals-only; `AFL_CRASH_EXITCODE` unset; exit-1 outputs
   triaged by hand -- none occurred).
9. Every reported bug deduplicated and minimized: **yes** vacuously (zero
   findings; the triage pipeline that would do it is committed and was
   exercised end-to-end on the empty set plus the selftest).
10. Every reported bug replayed across
    interp/compile/cranelift/cranelift-generic: **yes** vacuously (the
    replay matrix itself ran for all 21 targets x seeds, §5).
11. Every reported bug manually reproduced: **yes** vacuously.

Findings:

12. Raw crashes: 0 (release) + 0 (ASan pass); deduplicated: 0; confirmed
    bugs: 0.
13. Classification distribution: empty (shared / native-only /
    single-backend / interp-only / divergence: all zero).
14. Differential mismatches without crashes: none beyond the two
    documented display/baseline classes (§5).
15. Hangs: none (0 collected; the hang classifier is committed and
    exercised on the empty set).
16. GC-stress contribution: no findings; the vertical ran clean on AOT
    replays.

Verification:

17. Full regression passes: **yes** (4852 total, 0 failed, unchanged from
    the pre-campaign run; §10).
18. All examples compile AOT and match recorded baselines: **yes** (§10).
19. Every step reproducible from committed scripts: **yes**
    (`run-all.sh`; the toolchain build is scripted and idempotent).
20. Known-failure replay suite covering every filed bug: **yes** (zero
    filed; `--selftest` keeps the machinery proven, §10).

## 12. Limitations

* The campaign's reach is bounded by the examples themselves: without a
  program that calls `argv()`, the deep input path (`rt_argv`: strict
  UTF-8 validation, String/List construction, the declared
  `InvalidArgumentEncoding` error) is never executed. Fuzzing the same
  executables cannot change that; only an input-consuming example can
  (out of scope: "no new example programs").
* WSL specifics: pipe `core_pattern` (core files unavailable; crash
  detection is signal-based, unaffected), no CPU governor, and one 9p
  filesystem crash early on (recovered; the campaign was moved to a
  WSL-local clone, which is why all heavy state lives on ext4).
* No persistent-mode harness (future work), so per-exec cost includes
  fork+exec; fine at these program sizes.

## 13. Future work (recorded, not built)

* An input-consuming example application (e.g. a CSV filter reading
  `argv()`), which would unlock the real `rt_argv`/String/List path for
  fuzzing -- the single highest-value next step this campaign identified.
* Persistent-mode harnesses for throughput.
* Compiler-side fuzz instrumentation as a supported (opt-in, default-off)
  mode, if QEMU mode ever becomes unavailable.
* Grammar-aware/structure-aware seed mutation for CSV once a parser is
  reachable.
* In-CI mini-campaigns (minutes, bounded corpus) as a non-gating report.
* Reconciling this campaign's techniques with the existing compiler
  fuzzing effort (shared seeds/dictionaries where formats overlap).
