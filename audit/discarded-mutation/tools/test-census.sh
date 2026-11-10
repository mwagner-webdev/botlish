#!/bin/sh
# test-census.sh -- test-census.tcl over every Tcl test file, in parallel,
# on the interp core backend, the golden duplicates skipped (their programs
# are the golden suites', which census.tcl reads as files):
#
#   sh audit/discarded-mutation/tools/test-census.sh OUTDIR ?JOBS?
#
# Each test file runs in its own process with a private -tmpdir; its
# findings land in OUTDIR/NAME.tsv and its output in OUTDIR/NAME.log (whose
# last tcltest line is the file's own result).
set -eu
out=$1
jobs=${2:-4}
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
mkdir -p "$out"
export LANG=C.utf8 LC_ALL=C.utf8 CORE_BACKEND=interp BOTLISH_SKIP_GOLDEN_DUPLICATES=1
unset BOTLISH_HIR_CACHE || true
cd "$root"
ls tests/*.test | xargs -P "$jobs" -I{} sh -c '
    name=$(basename "$1" .test)
    tmp=$(mktemp -d)
    timeout 3600 tclsh9.0 "$2/test-census.tcl" "$3/$name.tsv" "$1" -tmpdir "$tmp" > "$3/$name.log" 2>&1 || echo "exit $?" >> "$3/$name.log"
    rm -rf "$tmp"
' _ {} "$here" "$out"
