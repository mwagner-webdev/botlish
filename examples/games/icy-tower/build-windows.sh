#!/bin/sh
# build-windows.sh -- builds the Icy Tower vertical slice's Windows x86-64
# executable (ICY-TOWER-WINDOWS.md) on Windows, from a clean checkout, in Git
# for Windows' sh or bash:
#
#   examples/games/icy-tower/build-windows.sh [OUTDIR]
#
# OUTDIR (default icy-tower-windows/ in the current directory) receives
# icy-tower.exe and the SDL3.dll it loads, beside it: the game, as it is
# played and shipped. Steps:
#
#   1. SDL3.dll and its import library SDL3.lib: tests/cffi/sdl3.tcl builds
#      the SDL release the binding profile pins (3.4.18) once into Botlish's
#      cache with CMake and Visual Studio (x64, SDL_LIBC off: the DLL needs
#      no C runtime DLL), unless BOTLISH_SDL3_DIR names a directory that
#      holds them.
#   2. The SDL3 binding of windows-x86_64 (MSVC): tools/c-bindgen.tcl
#      generates it from the same pinned headers with clang's MSVC target,
#      which finds Visual Studio's and the Windows SDK's headers itself.
#      None is committed -- a Linux host has no MSVC headers to check one
#      against -- so the build generates it, into ICY_TOWER_BINDING when
#      that is set (kept) or a temporary directory.
#   3. The application: the .bot files beside this script and that binding
#      staged into one application root (tools/c-bindgen.tcl stage -dir).
#   4. The executable: main.tcl -emit-native-executable of main-windows.bot,
#      linked by rustc with link.exe and SDL3.lib (-L), the static C runtime
#      (WINDOWS-X86-64-MILESTONE-2.md); then icy-tower.exe and SDL3.dll in
#      OUTDIR.
#
# Needs tclsh9.0, the built native backend (cargo build --release
# --manifest-path native/Cargo.toml), rustc for x86_64-pc-windows-msvc,
# Visual Studio's C++ tools with the Windows SDK, clang, git and CMake.
set -eu
# Windows paths (D:/a/...) for the native programs below: MSYS's /d/a/...
# means nothing to tclsh9.0.
winpath() { (cd "$1" && { pwd -W 2>/dev/null || cygpath -m "$PWD"; }); }
here=$(winpath "$(dirname "$0")")
root=$(winpath "$here/../../..")
out=${1:-icy-tower-windows}
export LANG=C.utf8 LC_ALL=C.utf8

sdl=$(tclsh9.0 "$root/tests/cffi/sdl3.tcl" | tail -n 1)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
binding=${ICY_TOWER_BINDING:-$work/binding}
mkdir -p "$binding"
binding=$(winpath "$binding")
tclsh9.0 "$root/tools/c-bindgen.tcl" fetch sdl3 >/dev/null
tclsh9.0 "$root/tools/c-bindgen.tcl" generate sdl3 -target windows-x86_64 -out "$binding"
app=$(winpath "$work")/app
tclsh9.0 "$root/tools/c-bindgen.tcl" stage sdl3 -target windows-x86_64 -dir "$binding/windows-x86_64" \
    -app "$here" -into "$app" >/dev/null
tclsh9.0 "$root/main.tcl" -warnings error -emit-native-executable -L "$sdl" "$app/main-windows.bot"
mkdir -p "$out"
cp "$app/main-windows.exe" "$out/icy-tower.exe"
cp "$sdl/SDL3.dll" "$out/SDL3.dll"
echo "executable: $out/icy-tower.exe"
echo "SDL3.dll: $out/SDL3.dll (from $sdl)"
