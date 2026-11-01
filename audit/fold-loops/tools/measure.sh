#!/bin/bash
# measure.sh -- FOLD-LOOPS-MILESTONE-1.md's workload measurements: the
# best-of-RUNS native time (audit/bench-bimodality/tools/measure.tcl: one
# driver process, JIT compilation excluded) and the instructions per run by
# category (audit/bench-bimodality/tools/profile.sh: callgrind, the
# difference of a 4- and a 24-run profile) of every program named, and of
# the chunk workloads at each size in SIZES (their `n = ...` line rewritten
# in a private copy).
#
#   bash audit/fold-loops/tools/measure.sh ?-runs N? ?-sizes "128 1024"? FILE.bot ...
#
# Needs the release native backend and valgrind. Removes its directory.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
runs=60
sizes=""
files=()
while [ $# -gt 0 ]; do
    case "$1" in
        -runs) runs=$2; shift 2 ;;
        -sizes) sizes=$2; shift 2 ;;
        *) files+=("$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"); shift ;;
    esac
done
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export LANG=C.utf8 LC_ALL=C.utf8
programs=()
for f in "${files[@]}"; do
    if [ -n "$sizes" ] && grep -q '^n = [0-9]*$' "$f"; then
        for n in $sizes; do
            mkdir -p "$work/n$n"
            sed "s/^n = [0-9]*\$/n = $n/" "$f" > "$work/n$n/$(basename "$f")"
            programs+=("$work/n$n/$(basename "$f")")
        done
    else
        programs+=("$f")
    fi
done
echo "== time (best of $runs, microseconds)"
(cd "$root" && tclsh9.0 audit/bench-bimodality/tools/measure.tcl -runs "$runs" "${programs[@]}")
echo "== instructions per run"
for p in "${programs[@]}"; do
    label="$(basename "$(dirname "$p")")/$(basename "$p")"
    bash "$root/audit/bench-bimodality/tools/profile.sh" "$p" 4 24 2>&1 \
        | grep -E 'instructions per run|generated code|runtime helpers|allocator|collector|mem\*' \
        | tr -s ' ' | paste -sd ' ' | sed "s|^|$label: |"
done
