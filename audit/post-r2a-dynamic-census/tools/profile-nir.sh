#!/usr/bin/env bash
# profile-nir.sh -- callgrind profile of RUNS timed native runs of an
# already-emitted NIR program (POST-R2A-DYNAMIC-CENSUS.md). Observation only.
#
#   bash audit/post-r2a-dynamic-census/tools/profile-nir.sh AUDIT-BIN PROGRAM.nir RUNS OUTDIR
#
# Same valgrind configuration as audit/post-m8a-common-inefficiency/tools/
# profile.sh (--toggle-collect=botlish_audit_run: JIT compilation and
# between-run Vm::reset excluded; --dump-instr for per-instruction JIT
# attribution through BOTLISH_AUDIT_JITMAP), plus BOTLISH_AUDIT_SKIP_FIRST
# (this census's audit-native.patch): run 0 executes outside the collected
# region, so the RUNS-1 collected runs are all steady-state (each preceded
# by Vm::reset, reusing the malloc arena run 0 grew; the first run's
# cold-arena surcharge is excluded -- see the report's methodology). All
# per-run figures are divided by RUNS-1. It takes the NIR text as
# input instead of emitting it, so one audit binary can profile NIR emitted
# by any tree (the historical R2 / R2.a.2 worktrees included: native/src is
# byte-identical from R2 through the frozen tree). Then runs the post-M8.a
# cgprof.py (profile.txt / instr.txt / mix.txt) and this census's own
# cgcensus.py (census.txt: self/inclusive per function, per-site helper
# costs, callvalue dispatch decomposition).
set -eu
bin=${1:?usage}; nir=${2:?usage}; runs=${3:?usage}; out=${4:?usage}
export LANG=C.utf8 LC_ALL=C.utf8
root=$(cd "$(dirname "$0")/../../.." && pwd)
mkdir -p "$out"
cp "$nir" "$out/program.nir"
collected=$((runs - 1))
BOTLISH_AUDIT_SKIP_FIRST=1 BOTLISH_NATIVE_STACK_BYTES=$((64 << 20)) BOTLISH_AUDIT_JITMAP="$out/jitmap.txt" \
    valgrind --tool=callgrind --dump-instr=yes --dump-line=no \
        --compress-strings=no --compress-pos=no \
        --cache-sim=yes --branch-sim=yes \
        --toggle-collect=botlish_audit_run \
        --callgrind-out-file="$out/callgrind.out" \
        "$bin" bench "$runs" "$out/program.nir" > "$out/run-output.txt" 2> "$out/valgrind.log"
python3 "$root/audit/post-m8a-common-inefficiency/tools/cgprof.py" \
    "$out/callgrind.out" "$out/jitmap.txt" "$collected" "$out"
python3 "$root/audit/post-r2a-dynamic-census/tools/cgcensus.py" \
    "$out/callgrind.out" "$out/jitmap.txt" "$collected" "$out" "$bin"
