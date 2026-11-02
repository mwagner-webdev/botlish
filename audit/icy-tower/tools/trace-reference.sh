#!/bin/sh
# trace-reference.sh -- the SDL call trace reference of the Icy Tower
# executable (ICY-TOWER-MACOS-MILESTONE-1.md, "SDL call trace"):
# audit/icy-tower/trace-reference.txt, the Linux executable's normalized
# trace, frame by frame (audit/icy-tower/tools/sdl-trace.py), which the
# macOS executable's trace -- on SDL's dummy driver and in a Cocoa window --
# is compared with.
#
#   sh audit/icy-tower/tools/trace-reference.sh EXECUTABLE check
#   sh audit/icy-tower/tools/trace-reference.sh EXECUTABLE write
#
# On Linux: builds the LD_PRELOAD interposer (context-refactor/tools/
# sdltrace.c) into a private temporary directory, runs EXECUTABLE (the Linux
# game, build.sh's) on SDL's dummy video driver with the reference's
# arguments (--autopilot --fixed-step --frames 600 --seed 7: the
# deterministic run, whose every frame is the same on every platform) and
# either compares its trace with the committed reference (check; exit 1 on
# a difference) or rewrites the reference (write: after a change to the
# game's drawing, its SDL calls or the interposer). LD_LIBRARY_PATH must find
# libSDL3 (or SDL3_DIR names its directory: default tests/cffi/sdl3.tcl's).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
exe=$1
mode=$2
reference=$root/audit/icy-tower/trace-reference.txt
export LANG=C.utf8 LC_ALL=C.utf8
sdl=${SDL3_DIR:-$(tclsh9.0 "$root/tests/cffi/sdl3.tcl" | tail -n 1)}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cc -shared -fPIC -O1 -o "$work/sdltrace.so" "$root/audit/icy-tower/context-refactor/tools/sdltrace.c" -ldl
set -- --autopilot --fixed-step --frames 600 --seed 7
LD_LIBRARY_PATH=$sdl SDL_VIDEO_DRIVER=dummy SDLTRACE=$work/trace LD_PRELOAD=$work/sdltrace.so "$exe" "$@" >"$work/summary"
cat "$work/summary"
case $mode in
    check) python3 -I "$here/sdl-trace.py" compare "$work/trace" "$reference" ;;
    write) python3 -I "$here/sdl-trace.py" digest "$work/trace" "$@" >"$reference"; echo "wrote $reference" ;;
    *) echo "usage: trace-reference.sh EXECUTABLE check|write" >&2; exit 2 ;;
esac
