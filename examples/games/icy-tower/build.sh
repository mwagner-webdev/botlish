#!/bin/sh
# build.sh -- builds the Icy Tower vertical slice's Linux executable
# (ICY-TOWER-VERTICAL-SLICE-1.md) from a clean checkout:
#
#   examples/games/icy-tower/build.sh [OUT]
#
# OUT (default audit/icy-tower/artifacts/icy-tower) is the stripped
# executable. Steps:
#
#   1. libSDL3.so: tests/cffi/sdl3.tcl builds the SDL release the binding
#      profile pins (3.4.18) once into Botlish's cache, unless
#      BOTLISH_SDL3_DIR names a directory that holds one. Its default build
#      is headless (the dummy and offscreen drivers); for a window, build it
#      with your desktop's backends:
#        BOTLISH_SDL3_DIR=DIR BOTLISH_SDL3_CMAKE_FLAGS="" tclsh9.0 tests/cffi/sdl3.tcl
#      Any SDL 3.x libSDL3.so.0 does at run time (the binding uses no
#      function newer than 3.2's API).
#   2. The application: the .bot files beside this script and the committed
#      generated SDL3 binding (generated/c/sdl3/linux-x86_64/sdl3/, the
#      host's target's) staged
#      into one application root (tools/c-bindgen.tcl stage): an
#      application imports only the files beside it.
#   3. The executable: main.tcl -emit-native-executable, linked with
#      -lSDL3 from step 1's directory (Botlish adds no rpath), then strip.
#
# Needs tclsh9.0, the built native backend (cargo build --release
# --manifest-path native/Cargo.toml), rustc and cc; step 1 also git, cmake
# and ninja.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
out=${1:-$root/audit/icy-tower/artifacts/icy-tower}
export LANG=C.utf8 LC_ALL=C.utf8

sdl=$(tclsh9.0 "$root/tests/cffi/sdl3.tcl" | tail -n 1)
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
# The binding of this host's target (the slice targets Linux x86-64; the
# committed linux-aarch64 binding builds an arm64 executable, untested).
case $(uname -m) in
    aarch64|arm64) target=linux-aarch64 ;;
    *) target=linux-x86_64 ;;
esac
tclsh9.0 "$root/tools/c-bindgen.tcl" stage sdl3 -target "$target" -app "$here" -into "$stage/app" >/dev/null
tclsh9.0 "$root/main.tcl" -warnings error -emit-native-executable -L "$sdl" "$stage/app/main.bot"
mkdir -p "$(dirname "$out")"
cp "$stage/app/main" "$out"
strip "$out"
echo "executable: $out"
echo "libSDL3: $sdl (run with LD_LIBRARY_PATH=$sdl, or with SDL 3 installed)"
