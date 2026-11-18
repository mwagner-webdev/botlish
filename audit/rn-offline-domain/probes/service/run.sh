#!/bin/sh
# run.sh -- builds and runs probe E of RN-OFFLINE-DOMAIN-ARCHITECTURE-
# CENSUS-MILESTONE-1.md (Linux x86-64 or AArch64, a C compiler, a built
# native backend): `audit/rn-offline-domain/probes/service/run.sh` from the
# repository root. Everything is built in a fresh temporary directory, which
# is removed afterwards; the run is repeated under BOTLISH_NATIVE_GC_STRESS=1.
set -eu
export LANG=C.utf8 LC_ALL=C.utf8
here=audit/rn-offline-domain/probes/service
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/native"
cp "$here/service.bot" "$work/"
tclsh9.0 tools/event-loop-linux.tcl install "$work" > /dev/null
cc -O2 -fPIC -Wall -Werror -Ipackages/event_loop_linux/native \
    -c "$here/native/probe_bridge.c" -o "$work/native/probe_bridge.o"
ar rcs "$work/native/libprobe_bridge.a" "$work/native/probe_bridge.o"
tclsh9.0 main.tcl -warnings error -emit-native-library svc -application -out "$work/lib" "$work/service.bot" > /dev/null
# The shared library: it links the program's link plan (the bridge and the
# driver's archives); the static one would leave them to the host.
cc -O1 -Wall -Werror -I"$work/lib" "$here/host.c" -L"$work/lib" -lsvc -Wl,-rpath,"$work/lib" -lpthread -o "$work/host"
echo "== plain"
"$work/host"
echo "== BOTLISH_NATIVE_GC_STRESS=1"
BOTLISH_NATIVE_GC_STRESS=1 "$work/host"
