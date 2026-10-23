#!/bin/sh
# run.sh -- builds and runs the exported-function probe
# (COMPILER-SERVICE-CENSUS.md, "FFI and JSON feasibility";
# NATIVE-LIBRARY-MILESTONE-1.md, "JSON/Tcl validation").
#
#   sh audit/compiler-service/probes/export/run.sh TCL-INCLUDE-DIR TCL-STUB-LIB
#
# TCL-INCLUDE-DIR holds tcl.h and TCL-STUB-LIB is libtclstub9.0.a (the
# tcl9.0-dev package's; extracted with `dpkg -x DEB DIR`, nothing installed).
# Needs the native backend built (its runtime library included), GNU
# binutils and a C compiler. The library is the compiler's own product:
# main.tcl -emit-native-library bj compiles exports.bot (and the unchanged
# json_tokens.bot it imports) into libbj.a, libbj.so, bj.h and bj.json, and
# probe.c, which includes only bj.h, links into a Tcl extension. Builds into
# a temporary directory whose path has a space; changes nothing in the
# repository.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../../.." && pwd)
inc=$1
stub=$2
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/src dir" "$work/lib dir"
cp "$here/exports.bot" "$here/../json/json_tokens.bot" "$work/src dir/"
tclsh9.0 "$root/main.tcl" -warnings off -emit-native-library bj -library-dir "$work/lib dir" "$work/src dir/exports.bot"
# The extension links the static library into itself (one object, every
# symbol but bj's API local), with the system libraries bj.json lists.
cc -O2 -fPIC -shared -DUSE_TCL_STUBS -I"$inc" -I"$work/lib dir" "$here/probe.c" \
    "$work/lib dir/libbj.a" "$stub" -lgcc_s -lutil -lrt -lpthread -lm -ldl -o "$work/libbjprobe.so"
tclsh9.0 "$here/probe.tcl" "$work/libbjprobe.so"
echo "--- under BOTLISH_NATIVE_GC_STRESS=1"
BOTLISH_NATIVE_GC_STRESS=1 tclsh9.0 "$here/probe.tcl" "$work/libbjprobe.so" -quick
