# audit/storage-static-reuse

The probe corpus and measurements of
[STORAGE-STATIC-REUSE-CENSUS-1.md](../../docs/STORAGE-STATIC-REUSE-CENSUS-1.md):
what the compiler and its backends do today with temporaries, coroutine
frames, actor messages, context-owned state and foreign buffers, recorded
without changing anything. This is a census: no compiler, runtime, standard
library or test file depends on it, and nothing here is run by
`tests/local.tcl` or CI.

## Layout

* `cases/` -- one Botlish program per probe (`p01` .. `p19`, and the
  variants `p07b`, `p10b`, `p16b`: 22 programs), each opening
  with a comment that states the storage question it asks. They are
  ordinary programs in today's syntax; a scenario the language cannot
  express is stated as such in the census (section 14), never approximated.
* `tools/probe.tcl` -- for every case: the outcome on interp, compile,
  cranelift and cranelift-unfused; HIR facts (the blocks that may yield, the
  affine release and exit tables); the native struct census and fold
  slots; the native allocation report (summary, per-site with source
  locations, and the reachable peak under `BOTLISH_NATIVE_GC_STRESS=1`);
  the C backend's result (C UNSUPPORTED with its diagnostics, or the
  generated program built with gcc -O2, run and compared, its
  `coroutine_frames` and each type's host `sizeof`/`_Alignof`). Writes
  `results/probes.md` and `results/probes/CASE.txt`.
* `tools/measure.tcl` -- four workloads at N = 1 .. 10000: allocations,
  bytes, peak live, collections, collection time, the reachable peak under
  GC stress, marginal allocations per unit and the best-of-R time per unit.
  Writes `results/measurements.md`.

## Reproduce

Tcl 9.0.1 and the native driver built with the pinned toolchain (AGENTS.md):

    export LANG=C.utf8 LC_ALL=C.utf8
    cargo build --release --manifest-path native/Cargo.toml
    tclsh9.0 audit/storage-static-reuse/tools/probe.tcl      # about 25 minutes
    tclsh9.0 audit/storage-static-reuse/tools/measure.tcl    # about 10 minutes

`probe.tcl -cases 'p07*'` narrows the corpus (and then writes a
`probes.md` of those cases only: pass `-out DIR` to keep the committed
one). The probe results are deterministic on one toolchain (no time, no
host path); `measurements.md`'s times and collection times vary run to run,
its counts do not.

The committed results were taken at commit 3a819456 with gcc 13.3.0, clang
18.1.3, rustc 1.100.0, Tcl 9.0.1, Linux 6.18 on x86-64 (4 processors).
