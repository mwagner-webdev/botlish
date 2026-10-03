# Generic predicate proof loss: audit tools and artifacts

Report: `/GENERIC-PREDICATE-PROOF-LOSS.md`. Observation only; nothing here
changes the compiler. Run from the repository root with Tcl 9.0.1 and the
release native backend built (`cargo build --release --manifest-path
native/Cargo.toml`); `LANG=C.utf8 LC_ALL=C.utf8`. The tools toggle fix 3's
result-narrowing pass through the test/audit knob
`hir::range::resultNarrowOpt` (0 = pass skipped, 1 = default); for loss
points 2 and 1 the knob is named by `AUDIT_KNOB` / `-knob`
(`hir::specialize::dormantOpt`, `hir::specialize::closureIntKeyOpt`).

| tool | purpose |
|---|---|
| `tools/run.sh BASE_REV SCRATCH` | the whole census: `collect.tcl` with the knob 0 and 1 on this tree and on a temporary worktree of `BASE_REV` (fix 3's parent), then `census.tcl` and `equivalence.tcl`; writes `out/census.txt`. With `AUDIT_BIN` set it also profiles programs whose NIR changed |
| `tools/collect.tcl TREE KNOB OUTDIR PROGRAM...` | dumps what the census compares: analysis, every `Fixpoint` state, RawInt plan, NIR |
| `tools/census.tcl DUMP0 DUMP1 OUT PROGRAM...` | knob 0 vs 1, fact by fact (entries, summaries, results, expressions, captures; narrower / wider / incomparable), NIR op deltas, RawInt plan changes |
| `tools/equivalence.tcl DUMPBASE DUMP0 DUMP1 OUT PROGRAM...` | the parent commit vs this tree with the pass off: must be byte-identical |
| `tools/emit-nir.tcl 0\|1 PROGRAM OUTFILE` | NIR with the knob set (input for `profile-nir.sh` and `botlish-native`) |
| `tools/profile-diff.py LABEL DIR0 DIR1` | compares two `profile-nir.sh` census outputs |
| `tools/run-knob.sh BASE_REV SCRATCH KNOB OUTNAME CENSUS` | loss points 2 and 1: the same collection with `AUDIT_KNOB=KNOB`, then the census knob 0 vs 1 (`CENSUS` `census` = `census.tcl`; `blocks` = `census-blocks.tcl`) and `equivalence-off.tcl`; writes `out/OUTNAME` (`census-dormant.txt`, `census-intkeys.txt`) |
| `tools/census-blocks.tcl DUMP0 DUMP1 OUT PROGRAM...` | function-level census for a change of instance keys (loss point 1): per function, the join over its live (non-dormant) instances of entry, result and expression Ranges; NIR compared modulo instance labels |
| `tools/equivalence-off.tcl DUMPBASE DUMP0 OUT PROGRAM...` | the parent commit vs this tree with a knob off: every dump file byte-identical (loss points 1 and 2) |
| `tools/compiletime.tcl` | analysis / lowering wall time, rounds and `AnalyzeInstance` calls, knob 0 vs 1 |
| `tools/fuzz.tcl ?-n N? ?-seed "S..."? ?-roundlimit L? ?-mutate 1\|2\|4\|5? ?-knob VAR? ?-nativeopts OPT=V,...?` | randomized soundness check: interp = compile = cranelift, top-level call Ranges and a runtime trace against every entry, result, summary and capture Range (joined over a block's non-dormant instances); `-mutate 1` / `-mutate 2` are oracle self-tests (a deliberately unsound result narrowing / dormant set that must be caught); `-knob` names the knob the "off" side turns off (default `hir::range::resultNarrowOpt`) |

Loss points 2 and 1: `out/census-dormant.txt`, `out/fuzz-dormant.txt`,
`out/ir-dormant.txt` (point 2) and `out/census-intkeys.txt`,
`out/fuzz-intkeys.txt` (point 1).

Loss point 4 (raw counted loops): the knob is the lowering knob
`native::lower::rawCountLoopOpt`; `run-knob.sh … native::lower::rawCountLoopOpt
census-rawloops.txt census` with `AUDIT_BIN` set gives `out/census-rawloops.txt`
(the Range census finds nothing by construction; the NIR changes, the RawInt
plan diff, knob-off equivalence and the callgrind comparison are the
evidence), and `fuzz.tcl -knob native::lower::rawCountLoopOpt` gives
`out/fuzz-rawloops.txt`. For a knob in `native::lower` the fuzzer counts the
programs whose NIR the knob changes; `-mutate 4` is the oracle self-test (a
raw induction register whatever the bounds' Ranges), and the generator also
builds numeric lockstep loops.

Loss point 5 (the RawInt ABI for de-closured functions): the lowering knob
`native::lower::rawInternalAbiOpt`, the same way: `out/census-rawinternal.txt`
(`run-knob.sh … native::lower::rawInternalAbiOpt census-rawinternal.txt
census`, `AUDIT_BIN` set) and `out/fuzz-rawinternal.txt`. `-mutate 5` is its
oracle self-test (internal variants also take raw the positions the plan
rejected as `unbounded-or-not-small`); the generator also builds
self-recursive de-closured closures (`recclosure`).

`out/` holds the committed results of fix 3: `census.txt` (base `584de41`, fix 3's
parent on `main` at `07b373c`),
`ir.txt` (callgrind, `audit/post-r2a-dynamic-census/tools/profile-nir.sh`,
21 runs, run 0 excluded), `compiletime.txt` and `fuzz.txt`. The headers of
`ir.txt` and `compiletime.txt` explain why figures measured on `e1ce1a3` +
fix 3 carry over to the final tree.
