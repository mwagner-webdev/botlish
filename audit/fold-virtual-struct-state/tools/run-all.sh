#!/bin/bash
# run-all.sh -- regenerates FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md's
# results/: the semantic probes (probes.tcl), the measurements of Probes
# A, B and C (measure.tcl, callgrind's instructions per run included) and
# the compile cost (economics.tcl, backend-time.tcl: run "e" on a quiet
# machine, its times are wall-clock). Needs the release native backend,
# valgrind and python3; takes about an hour, most of it the eager rows at
# n = 16384 under callgrind. (Run a copy of this script if you edit it
# while it runs: bash reads a script as it goes.)
#
#   bash audit/fold-virtual-struct-state/tools/run-all.sh ?probes|a|w|b|c|e|all?
set -eu
here=$(cd "$(dirname "$0")" && pwd)
audit=$(cd "$here/.." && pwd)
root=$(cd "$here/../../.." && pwd)
part=${1:-all}
export LANG=C.utf8 LC_ALL=C.utf8
unset BOTLISH_HIR_CACHE
cd "$root"
W=audit/fold-virtual-struct-state/workloads
F=audit/fold-loops/workloads
V=audit/fold-virtual-construction/workloads
measure() {
    tclsh9.0 "$here/measure.tcl" -instructions 1 "$@"
}

if [ "$part" = probes ] || [ "$part" = all ]; then
    tclsh9.0 "$here/probes.tcl" $W/d-*.bot $W/e-positions.bot > "$audit/results/probes.txt"
fi

if [ "$part" = a ] || [ "$part" = all ]; then
    rows=()
    for w in 2 4; do
        rows+=("scan$w-fold $W/a-scan$w-fold.bot"
               "scan$w-fold+fields $W/a-scan$w-fold.bot -sra {-functions {scan number_at} -return-fields number_at:1}"
               "scan$w-recursive $W/a-scan$w-recursive.bot"
               "scan$w-cells $W/a-scan$w-cells.bot")
    done
    rows+=("scan6-fold $F/scanner-fold.bot"
           "scan6-fold+fields(scan) $F/scanner-fold.bot -sra {-functions scan}"
           "scan6-fold+fields(both) $F/scanner-fold.bot -sra {-functions {scan number_at}}"
           "scan6-fold+fields+ret $F/scanner-fold.bot -sra {-functions {scan number_at} -return-fields number_at:1}"
           "scan6-recursive $F/scanner-recursive.bot"
           "scan6-cells $F/scanner-cells.bot")
    measure "${rows[@]}" > "$audit/results/probe-a.txt"
fi

if [ "$part" = w ] || [ "$part" = all ]; then
    rows=()
    for w in 2 4 8 16 32 64; do
        rows+=("spill-$w-fold audit/fold-virtual-struct-state/economics/spill-$w.bot"
               "spill-$w-fold+fields audit/fold-virtual-struct-state/economics/spill-$w.bot -sra {-functions f}")
    done
    measure "${rows[@]}" > "$audit/results/probe-a-width.txt"
fi

if [ "$part" = b ] || [ "$part" = all ]; then
    rows=()
    for n in 128 1024 4096 16384; do
        rows+=("chunks-fold $F/chunks-fold.bot -n $n"
               "chunks-fold+fields $F/chunks-fold.bot -n $n -sra {-functions chunks}"
               "chunks-fold+fields+plan(done) $F/chunks-fold.bot -n $n -sra {-functions chunks -plan-field 0.0}"
               "chunks-recursive $F/chunks-recursive.bot -n $n"
               "chunks-vector $F/chunks-vector.bot -n $n"
               "wrap-fold $W/b-wrap-fold.bot -n $n"
               "wrap-fold+fields $W/b-wrap-fold.bot -n $n -sra {-functions build}"
               "wrap-fold+fields+plan(items) $W/b-wrap-fold.bot -n $n -sra {-functions build -plan-field 0.0}"
               "list-fold(direct) $V/list-fold.bot -n $n"
               "list-recursive $V/list-recursive.bot -n $n"
               "counted-fold $W/b-counted-fold.bot -n $n"
               "counted-fold+fields $W/b-counted-fold.bot -n $n -sra {-functions build}"
               "counted-fold+fields+plan(items) $W/b-counted-fold.bot -n $n -sra {-functions build -plan-field 0.0}"
               "counted-recursive $W/b-counted-recursive.bot -n $n")
    done
    measure "${rows[@]}" > "$audit/results/probe-b.txt"
fi

if [ "$part" = c ] || [ "$part" = all ]; then
    rows=()
    for n in 1024 16384; do
        for p in c-vec-literal c-vec-self c-two-vecs c-mixed c-vec-continue; do
            rows+=("$p $W/$p.bot -n $n"
                   "$p(copying) $W/$p.bot -n $n -consumed 0"
                   "$p+fields $W/$p.bot -n $n -sra {-functions build}")
        done
        rows+=("c-mixed+fields+plan(log) $W/c-mixed.bot -n $n -sra {-functions build -plan-field 0.0}")
    done
    measure "${rows[@]}" > "$audit/results/probe-c.txt"
fi

if [ "$part" = e ] || [ "$part" = all ]; then
    E=audit/fold-virtual-struct-state/economics
    tclsh9.0 "$here/gen-economics.tcl"
    tclsh9.0 "$here/economics.tcl" -runs 5 $E/width-{2,4,8,16,32,64}.bot $E/nested-{1,2,3,4,5}.bot \
        $E/many-{10,20,40,80}.bot $E/locals-{10,20,40,80}.bot \
        $F/scanner-fold.bot $F/chunks-fold.bot tests/golden/fold-loops.bot > "$audit/results/economics.txt"
    tclsh9.0 "$here/backend-time.tcl" -runs 5 $E/width-2.bot $E/width-16.bot $E/width-64.bot \
        $E/nested-5.bot $E/many-10.bot $E/many-80.bot $F/scanner-fold.bot $F/chunks-fold.bot \
        tests/golden/fold-loops.bot > "$audit/results/backend-time.txt"
fi
