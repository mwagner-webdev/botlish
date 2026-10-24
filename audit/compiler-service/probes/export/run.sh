#!/bin/sh
# run.sh -- builds and runs the exported-function probe
# (COMPILER-SERVICE-CENSUS.md, "FFI and JSON feasibility";
# NATIVE-LIBRARY-MILESTONE-1.md).
#
#   sh audit/compiler-service/probes/export/run.sh TCL-INCLUDE-DIR TCL-STUB-LIB ?CALLS?
#
# TCL-INCLUDE-DIR holds tcl.h and TCL-STUB-LIB is libtclstub9.0.a (the
# tcl9.0-dev package's; extract them with dpkg -x rather than installing
# them). Needs the native backend built (its runtime archive) and GNU
# binutils and a C compiler. The library is the compiler's own output
# (main.tcl -emit-native-library); probe.c includes its bj.h and links its
# libbj.a. Builds into a temporary directory; changes nothing in the
# repository.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../../.." && pwd)
inc=$1
stub=$2
calls=${3:-20000}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$here/exports.bot" "$here/../json/json_tokens.bot" "$work/"
tclsh9.0 "$root/main.tcl" -warnings off -emit-native-library bj -out "$work/lib" "$work/exports.bot"
cc -O2 -fPIC -shared -DUSE_TCL_STUBS -I"$inc" -I"$work/lib" "$here/probe.c" \
    "$work/lib/libbj.a" "$stub" -lgcc_s -lutil -lrt -lpthread -lm -ldl -o "$work/libbjprobe.so"
tclsh9.0 "$here/probe.tcl" "$work/libbjprobe.so" "$calls"
echo "--- under BOTLISH_NATIVE_GC_STRESS=1"
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 "$here/probe.tcl" "$work/libbjprobe.so" "$calls"
