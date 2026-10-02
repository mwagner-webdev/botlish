#!/bin/sh
# fuzz.sh -- runs fuzz.tcl over a seed range in small slices (one Tcl process
# per slice: native evaluation keeps JIT memory for the life of the process,
# so a single process cannot run thousands of programs).
#
#   audit/collecting-loops/tools/fuzz.sh ?FIRST-SEED? ?COUNT? ?SLICE?
export LANG=C.utf8 LC_ALL=C.utf8
here=$(dirname "$0")
first=${1:-1}
count=${2:-400}
slice=${3:-20}
failed=0
seed=$first
end=$((first + count))
while [ "$seed" -lt "$end" ]; do
    n=$slice
    if [ $((seed + n)) -gt "$end" ]; then n=$((end - seed)); fi
    out=$(tclsh9.0 "$here/fuzz.tcl" -seed "$seed" -n "$n" 2>&1)
    status=$?
    echo "$out" | grep -E "^(programs|FAILURE)" 
    if [ $status -ne 0 ]; then
        failed=1
        echo "$out" | head -60
    fi
    seed=$((seed + n))
done
exit $failed
