# Fuzzing JSON ingestion, AOT first (campaign 3)

The third campaign: **JSON ingestion** through Botlish's first real
input-consuming *example* -- `examples/dfa/json/conformance.bot`, the
RFC 8259 conformance driver over the DFA/coroutine recognizer stack
(`json.bot` + `json_lex.bot`, DFA-COROUTINE-MILESTONE-2.md) -- fuzzed
AOT-first like everything before it, plus the campaign's first
**cross-operating-system** replay (Linux fuzzing, Windows differential
replay through the new x86_64-pc-windows-msvc AOT path).

```
examples/dfa/json/conformance.bot  ->  AOT executable  ->  afl-fuzz (argv
vector: one JSON document per argument)  ->  crash/hang oracle
                     |                                                        |
                     +-- differential matrix (aot/cranelift/cranelift-generic
                         reports; interp/compile = designed NATIVE-ONLY)
                     +-- Windows replay (fuzz/windows/replay-json.ps1)
```

Campaign date: 2026-10-26. Base: main at `314605cd` (the merged
grammar-emission branch). Platform and toolchain unchanged (AFL++ 4.09c
QEMU mode; earlier reports have the details). Reproducible:
`bash fuzz/scripts/make-seeds.sh && bash fuzz/scripts/minimize-seeds.sh
&& CAMPAIGN_TARGETS=conformance bash fuzz/scripts/campaign.sh 1200`.

## 1. Inventory: the JSON surface

* **`conformance.bot`** is the campaign's target: it takes `argv()` (with
  the documented `InvalidArgumentEncoding` fallback), and for every
  argument prints one verdict line -- `json::validate_bytes` on the bytes
  as one chunk **and** cut into chunks of 1..7 (a chunk boundary must be
  invisible), plus the scalar-recognizer verdict for valid UTF-8 -- then
  ends with its value (`unit`). Total on every argv byte string: the
  ideal fuzz shape, again.
* `json.bot`, `json_lex.bot`, `by_hand.bot`, `composition.bot` are
  recognizer modules/programs without argv drivers (conformance imports
  the first two); fuzzing them directly is what conformance does.
* **Emission: infeasible today, recorded not built** -- the standard
  library has no JSON emitter (no `encode`/`to_json`/serializer exists;
  `decode_text`/`decode_bytes` are ingestion only). Writing one is a
  product milestone, not a fuzzing one (this campaign's own rule).
* Related existing work, deliberately not duplicated: the repository
  already differentials the DFA workloads against JSONTestSuite
  (`audit/dfa/tools/differential.tcl`, required to hold 0
  disagreements). This campaign is orthogonal: structure-blind mutation
  of the AOT executable with crash/hang oracles plus cross-vertical and
  cross-OS replay.

## 2. Harness, oracle modes, seeds, dictionary

* Harness: the argv-vector harness unchanged; conformance is a
  **multi-line report target** (`fuzz/lines-targets`): the whole stdout
  report is the oracle (`report|<lines joined>`), with the in-process
  framing stripped and the aot value line dropped, so all runnable
  verticals normalize identically.
* Seeds (`fuzz/seeds/conformance/`, committed, cmin-minimized 49 -> 10):
  the driver's arguments are **hex-encoded** case bytes (`str.unhex`;
  a leading `+` continues the previous case -- the program's own
  contract), so seeds carry the hex text of RFC 8259 valid shapes (all
  literal types, number extremes -- `-0`, `1e999`, `1E+5` -- escapes
  including the surrogate-pair halves, an astral literal, nesting to 16
  and 64, whitespace), classic malformations (trailing commas, single
  quotes, `NaN`, comments, `01`, `+1`, `.5`, `0x1`, unterminated
  strings, a lone high surrogate), the program's own limits probed
  (`TooDeep` at depth 500, long tokens at 5k and 40k symbols -- 40k,
  not 90k, because a 90k case hex-doubles past the kernel's 128 KiB
  per-argument limit), the continuation form (`5b` + `+315d`),
  multi-document vectors, and the structural set every target gets.
* `fuzz/dictionaries/json.dict`: RFC 8259's grammar tokens (structural
  pairs, literals, escape machinery with the surrogate boundary values,
  number grammar, whitespace, BOM), hand-written from the RFC.

## 3. Campaign parameters

Unchanged policy: `-Q`, `-m none`, `-G 100000`, `-t 200` (baseline
3-4 ms), budget 1200 s enforced by `-V`, snapshots every 300 s, signals-
only crash oracle, WSL environment variables.

## 4. Results

* Release pass: **567,472 executions in 1200 s (237/s), corpus 17,
  0 crashes, 0 hangs**, plateaued (65 queue cycles without finds;
  `fuzz/campaign-stats/2026-10-26/`).
* ASan pass: **15,782 executions in 600 s, corpus 17, 0 crashes,
  2 saved hangs** -- and one of those "hangs" is the campaign's finding:
  an ASan abort that triage's plain run at first missed (it reproduces
  20/20 with the right environment; see FZ-004).
* ASan pass: **22,760 executions in 600 s (38/s), corpus 17, 0 crashes,
  0 hangs** -- the sanitizer build adds no finding.* Differential matrix (1303 recorded runs, all targets; conformance's
  rows compared on the full report): **0 hard mismatches**; the
  native-only-refusal class now keys on the designed diagnostic itself
  (a program's module files can carry the native-only construct -- here
  `json.bot`'s machine-address use -- so the target's own source text
  does not decide it).
* Findings: **one real bug, filed** -- plus one input-contract correction
  of the campaign's own corpus:

  * **FZ-004** (`fuzz/triage/FZ-004/`): **the collector frees a live
    String object** -- `heap-use-after-free`, READ in `StrObj::wide`
    (strobj.rs:139) of an object freed by `Heap::collect`'s
    `free_object` (heap.rs:227): a GC root-tracking hole in the native
    runtime, shared by every native vertical. Deterministic **20/20** in
    the ASan build; the release build is latent on this input (correct
    report, identical across repeats and to in-process; the same heap
    code -- the freed read hits recycled memory that still holds the
    right bytes). Trigger: ~500 small hex cases' allocation churn grows
    the heap until a collection lands while generated code still holds
    the unrooted String. Not fixed, per campaign policy; the first
    runtime-layer finding of any campaign, and exactly what the ASan
    second pass exists for.
  * Corpus correction: the driver's arguments are **hex-encoded** case
    bytes (`str.unhex`, `+` continues a case) -- the campaign's first
    corpus pass fed raw JSON text and unknowingly fuzzed hex-garbled
    space (nothing found there either); the committed corpus, dictionary
    and all numbers above are the corrected hex-text ones.
  * FZ-001 stays fixed; string-reverse's O(n^2) on ~100 KiB inputs
    reappeared once more under triage (same known performance
    observation, recorded under its newest candidate id, not a bug).

## 5. Windows replay (the cross-operating-system oracle)

AFL++ has no Windows port, so Windows cannot run a coverage-feedback
campaign; what it *can* do -- and now does, scripted -- is emit the same
target for `x86_64-pc-windows-msvc` (the host-native AOT path,
WINDOWS-X86_64-MILESTONE-1) and replay the identical committed corpus,
comparing each full report against the Linux AOT expectations
(`fuzz/windows/expected-conformance.tsv`, exported by
`fuzz/scripts/export-json-expectations.sh`). The script
(`fuzz/windows/replay-json.ps1`) needs only what this machine already
has: Tcl 9.0 (`%LOCALAPPDATA%\Apps\Tcl90`), cargo, and the Windows SDK
link that rustc finds by itself; it builds nothing of the compiler.

Result: **Windows support is insufficient for this target -- skipped,
per the campaign's own rule** (do not implement anything to close the
gap). The replay script runs end to end (toolchain checks, driver
build, emission) and the Windows executable reports the platform's own
clean refusal: *native coroutines need stack switching, implemented for
Linux x86-64 and AArch64 and macOS AArch64 only* (`NATIVE UNSUPPORTED
value`) -- the JSON recognizer stack is coroutine-built throughout, and
the coroutines milestone has not reached windows-x86_64. The script and
expectations stay committed and ready: the moment native coroutines
land on Windows, `fuzz\windows\replay-json.ps1` is the cross-OS oracle.

## 6. Required questions

1. 59 example programs on this base + 4 argv programs + conformance
   (the fuzzed JSON target); every one inventoried or out of scope with
   reasons (games need SDL, ffi needs C fixtures).
2. Fuzzable: conformance (argv, input-driven). Emission: infeasible, no
   emitter exists (§1).
3. QEMU mode unchanged; blind spots as before (campaign 1 §2).
4. Compiler changes: **no**.
5. 1200 s release / 600 s ASan for conformance, `-t 200`, `-m none`.
6. Seeds minimized and dictionaries checked in: **yes** (59 -> 11).
7-11. Oracle, dedup, matrix replay, manual reproduction: as before; zero
   findings to replay this campaign.
12-16. Raw: 0 crashes + 2 saved hangs (one is FZ-004's ASan abort);
   1 deduplicated signature; 1 confirmed bug (FZ-004, runtime GC
   root-tracking, filed with the vertical matrix and 20/20
   reproduction); classification: runtime 1, everything else 0; no new
   differential mismatch classes (one normalization gap fixed in
   lines-mode: zero-line reports and refusal retention); the two
   differential "hangs" classes of earlier campaigns: none here; GC
   stress on the release build of FZ-004's input: correct report (the
   finding is ASan-build-visible today).
17. Full regression on this base (`tests/local.tcl`, the parallel local
   runner): **234 Tcl test files -- interp 7302 passed / 0 failed,
   compile 7297 passed / 0 failed -- and 108 golden suites on all four
   backends, 0 failed** (interp 5180/5180, compile 5180/5180,
   cranelift-generic 5088/5088, cranelift 5190/5190), 41 min wall on 12
   jobs.
18. All targets still compile AOT (38 ok on this base; the same designed
    gates) and match recorded baselines.
19. Every step reproducible from committed scripts: **yes** (plus the
    Windows replay script).
20. Known-failure replay suite: still green, still covering FZ-001.

## 7. Limitations and future work

* No JSON emitter exists; emission fuzzing waits for one (a product
  decision, not recorded here as a gap of the campaign).
* The Windows side is replay-only **and currently refused by the
  platform** (no native coroutines on windows-x86_64 yet); the script
  stands ready for when they land. A coverage-feedback Windows fuzzer
  would additionally need an instrumentation story there (out of scope).
* by_hand/composition recognizers are reachable only through their own
  golden suites; argv drivers for them would be new fuzz programs
  (future work, same pattern as fuzz/programs/).
