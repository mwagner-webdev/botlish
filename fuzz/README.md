# fuzz/ -- the AFL++ fuzzing campaign over the AOT example executables

Status, decisions, inventory, per-target statistics and findings live in
`FUZZING-EXAMPLES-AOT.md` at the repository root. This file is the
operator's map: layout, and how to rebuild, rerun, and triage.

## Layout

```
fuzz/
  harness/argv-file.c     the campaign harness: a file's bytes -> the target's
                          argv (NUL-separated), then exec. Compiled by
                          setup-host.sh.
  scripts/                every campaign step, runnable standalone (see
                          run-all.sh for the order and what each does)
  seeds/<target>/         minimized seed corpora (afl-cmin), committed
  seeds-src/              generated seed sources (make-seeds.sh); regenerated,
                          not committed
  dictionaries/           per-format AFL dictionaries, committed
  baselines/              per-target seed baselines (stdout/exit/time), committed
  inventory.tsv           generated example inventory (inventory.tcl)
  build/                  AOT binaries + copied sources (gitignored)
  out/                    AFL session state + snapshots (gitignored)
  campaign-stats/         archived fuzzer_stats + snapshots (committed proof)
  triage/                 FZ-NNN/ filed findings (committed);
                          candidates/ (auto-generated, pre-confirmation)
  tools/                  the AFL++ toolchain built from pinned sources
                          (gitignored; setup-host.sh rebuilds it)
```

## One-time host setup

`bash fuzz/scripts/setup-host.sh` builds AFL++ 4.09c (including QEMU mode,
which the Ubuntu package lacks) from pinned upstream sources under
`fuzz/tools/afl`, entirely unprivileged, and smoke-tests QEMU mode.
Network is needed for setup only; campaigns run offline.

## Rebuild the AOT binaries

```sh
cargo build --release --manifest-path native/Cargo.toml   # the backend
bash fuzz/scripts/build-aot.sh    # -> fuzz/build/aot/<name>, manifest.tsv
```

## Run the campaign

```sh
bash fuzz/scripts/run-all.sh            # full pipeline, 1200 s/target
bash fuzz/scripts/campaign.sh 600       # just the AFL part, 600 s/target
```

## Triage

`bash fuzz/scripts/triage.sh` collects raw crashes/hangs from `fuzz/out`,
minimizes (afl-tmin), deduplicates by signature, replays each candidate
across all verticals (`replay.tcl`), and writes machine-classified
packages under `fuzz/triage/candidates/`. Promoting a candidate to a filed
finding is manual: confirm by hand, then move it to `fuzz/triage/FZ-NNN/`
with `input`, `target`, `expected.tsv`.

Single replays, any vertical:

```sh
tclsh9.0 fuzz/scripts/replay.tcl cranelift csv fuzz/seeds/csv/three-args
tclsh9.0 fuzz/scripts/replay.tcl aot csv crashfile --gc-stress
tclsh9.0 fuzz/scripts/replay.tcl aot csv crashfile --valgrind
```

## Replay known failures

```sh
tclsh9.0 fuzz/scripts/replay-known-failures.tcl            # filed findings
tclsh9.0 fuzz/scripts/replay-known-failures.tcl --selftest # machinery check
```

## Differential check (no fuzzer needed)

```sh
bash fuzz/scripts/differential.sh    # seeds x {aot,interp,compile,cranelift,
                                      # cranelift-generic}, mismatch-reporting
```

## ASan second pass

`bash fuzz/scripts/build-asan.sh` rebuilds the native runtime with
nightly `-Zsanitizer=address` (no compiler changes: it drives the same
emission through a private toolchain dir) and links ASan executables
under `fuzz/build/aot-asan/`. Replay vertical: `aot-asan`.
