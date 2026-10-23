#!/bin/sh
# trace-compare.sh -- SDL call-trace equivalence of two Icy Tower executables
# (ICY-TOWER-CONTEXT-REFACTOR-CENSUS.md, "Behavior preserved").
#
#   sh audit/icy-tower/context-refactor/tools/trace-compare.sh BEFORE AFTER [ARGS...]
#
# Builds sdltrace.c (beside this script) into a private temporary directory,
# runs both executables on SDL's dummy video driver with the interposer
# preloaded and ARGS (default: --autopilot --fixed-step --frames 2400 --seed 7),
# and prints the two summaries, the size of each trace, the calls per SDL
# function and the diff of the traces. LD_LIBRARY_PATH must find libSDL3 (or
# SDL3_DIR names its directory: default tests/cffi/sdl3.tcl's).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../../.." && pwd)
before=$1
after=$2
shift 2
[ $# -gt 0 ] || set -- --autopilot --fixed-step --frames 2400 --seed 7
export LANG=C.utf8 LC_ALL=C.utf8
sdl=${SDL3_DIR:-$(tclsh9.0 "$root/tests/cffi/sdl3.tcl" | tail -n 1)}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cc -shared -fPIC -O1 -o "$work/sdltrace.so" "$here/sdltrace.c" -ldl
for side in before after; do
    exe=$before
    [ $side = after ] && exe=$after
    LD_LIBRARY_PATH=$sdl SDL_VIDEO_DRIVER=${SDL_VIDEO_DRIVER:-dummy} SDLTRACE=$work/$side.log \
        LD_PRELOAD=$work/sdltrace.so "$exe" "$@" || true
    touch "$work/$side.log"
done
wc -l "$work/before.log" "$work/after.log" | sed "s#$work/##"
echo "calls per SDL function (before):"
awk '{print $1}' "$work/before.log" | sort | uniq -c | sort -rn
echo "diff before after:"
diff "$work/before.log" "$work/after.log" && echo "(identical)" || true
