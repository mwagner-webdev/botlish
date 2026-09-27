#!/usr/bin/env bash
# profile.sh -- callgrind profile of one canonical benchmark's timed native
# runs (POST-M8A-COMMON-INEFFICIENCY-CENSUS.md). Observation only.
#
#   bash audit/post-m8a-common-inefficiency/tools/profile.sh AUDIT-BINARY PROGRAM.ir RUNS OUTDIR ?LOWER-OPTIONS...?
#
# PROGRAM may also be supplemental:NAME (tools/emit-supplemental-nir.tcl).
# AUDIT-BINARY is botlish-native built with tools/audit-native.patch
# (tools/build-audit-native.sh): identical code generation and runtime, plus
# (a) a named botlish_audit_run frame around each timed run, so
# --toggle-collect excludes JIT compilation and between-run Vm::reset, and
# (b) BOTLISH_AUDIT_JITMAP, which names JIT code ranges for attribution.
# Writes OUTDIR/{program.nir, jitmap.txt, callgrind.out, profile.txt,
# instr.txt, mix.txt}.
set -eu
bin=${1:?usage}; prog=${2:?usage}; runs=${3:?usage}; out=${4:?usage}
shift 4
export LANG=C.utf8 LC_ALL=C.utf8
root=$(cd "$(dirname "$0")/../../.." && pwd)
mkdir -p "$out"
case "$prog" in
    supplemental:*) tclsh9.0 "$root/audit/post-m8a-common-inefficiency/tools/emit-supplemental-nir.tcl" "${prog#supplemental:}" "$out/program.nir" ;;
    *) tclsh9.0 "$root/audit/post-m8a-common-inefficiency/tools/emit-nir.tcl" "$prog" "$out/program.nir" "$@" ;;
esac
BOTLISH_NATIVE_STACK_BYTES=$((64 << 20)) BOTLISH_AUDIT_JITMAP="$out/jitmap.txt" \
    valgrind --tool=callgrind --dump-instr=yes --dump-line=no \
        --compress-strings=no --compress-pos=no \
        --cache-sim=yes --branch-sim=yes \
        --toggle-collect=botlish_audit_run \
        --callgrind-out-file="$out/callgrind.out" \
        "$bin" bench "$runs" "$out/program.nir" > "$out/run-output.txt" 2> "$out/valgrind.log"
python3 "$root/audit/post-m8a-common-inefficiency/tools/cgprof.py" \
    "$out/callgrind.out" "$out/jitmap.txt" "$runs" "$out"
