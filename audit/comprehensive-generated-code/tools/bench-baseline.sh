#!/usr/bin/env bash
# bench-baseline.sh -- COMPREHENSIVE-GENERATED-CODE-AUDIT.md's benchmark
# baseline: the repository-standard commands, repeated to expose variance.
#
#   bash audit/comprehensive-generated-code/tools/bench-baseline.sh OUTDIR [SESSIONS]
#
# SESSIONS (default 5) independent runs of `tclsh9.0 bench/bench.tcl -runs 5
# -markdown` (the CI/bench.yml methodology: best of 5 runs per program and
# backend, JIT compile excluded), then one `tclsh9.0 bench/corpus.tcl` over
# the native backends (code size, NIR function count, guards, allocations,
# timing of the algorithm corpus). Run on an otherwise idle machine.
set -eu
out=${1:?usage: bench-baseline.sh OUTDIR [SESSIONS]}
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
tclsh9.0 bench/corpus.tcl -backends "cranelift cranelift-generic" > "$out/corpus-native.txt"
