#!/usr/bin/env bash
# baseline.sh -- POST-M8A-COMMON-INEFFICIENCY-CENSUS.md's timing baseline.
# Observation only.
#
#   bash audit/post-m8a-common-inefficiency/tools/baseline.sh OUTDIR [SESSIONS]
#
# 1. SESSIONS (default 5) independent runs of the repository's canonical
#    benchmark command, `tclsh9.0 bench/bench.tcl -runs 5 -markdown`
#    (bench.yml: best of 5 runs per program and backend after one untimed
#    warm-up, Cranelift JIT compile excluded) -- the same procedure as
#    COMPREHENSIVE-GENERATED-CODE-AUDIT.md's tools/bench-baseline.sh.
# 2. Native-only configurations of the same four programs (variants.tcl):
#    cranelift (M8.a on, the default), cranelift with
#    -virtual-construction-opt 0 (historical comparison only), and
#    cranelift-generic (-specialize 0), each SESSIONS x best of RUNS.
# Run on an otherwise idle machine.
set -eu
out=${1:?usage: baseline.sh OUTDIR [SESSIONS]}
sessions=${2:-5}
mkdir -p "$out"
export LANG=C.utf8 LC_ALL=C.utf8
root=$(cd "$(dirname "$0")/../../.." && pwd)
cd "$root"
{
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "commit: $(git rev-parse HEAD)"
    echo "tcl: $(echo 'puts [info patchlevel]' | tclsh9.0)"
    echo "rustc: $(rustc --version)"
    echo "go: $(go version 2>/dev/null || echo n/a)"
    echo "python: $(python3 --version 2>&1)"
    echo "cpu: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ //')"
    echo "nproc: $(nproc)"
    echo "kernel: $(uname -r)"
} > "$out/environment.txt"
for i in $(seq 1 "$sessions"); do
    tclsh9.0 bench/bench.tcl -runs 5 -markdown > "$out/bench-session-$i.md"
done
tclsh9.0 audit/post-m8a-common-inefficiency/tools/variants.tcl "$sessions" > "$out/variants.txt"
