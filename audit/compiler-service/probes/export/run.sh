#!/bin/sh
# run.sh -- builds and runs the exported-function probe
# (COMPILER-SERVICE-CENSUS.md, "FFI and JSON feasibility").
#
#   sh audit/compiler-service/probes/export/run.sh TCL-INCLUDE-DIR TCL-STUB-LIB
#
# TCL-INCLUDE-DIR holds tcl.h and TCL-STUB-LIB is libtclstub9.0.a (the
# tcl9.0-dev package's; the census extracted them with dpkg -x rather than
# installing them). Needs the native backend built and rustc. Builds into a
# temporary directory; changes nothing in the repository.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../../.." && pwd)
inc=$1
stub=$2
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$here/exports.bot" "$here/../json/json_tokens.bot" "$work/"
tclsh9.0 "$root/audit/react-native/tools/libmode.tcl" -o "$work/lib" -prefix bj "$work/exports.bot" \
    token_count shout checked churn
cc -O2 -fPIC -shared -DUSE_TCL_STUBS -I"$inc" -I"$work/lib" "$here/probe.c" \
    "$work/lib/libbj_botlish.a" "$stub" -lpthread -ldl -lm -o "$work/libbjprobe.so"
tclsh9.0 "$here/probe.tcl" "$work/libbjprobe.so"
echo "--- under BOTLISH_NATIVE_GC_STRESS=1"
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 "$here/probe.tcl" "$work/libbjprobe.so"
