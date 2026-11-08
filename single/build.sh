#!/usr/bin/env bash
# single/build.sh -- builds the single-file Botlish compiler (SINGLE-EXECUTABLE.md).
#
#   single/build.sh [-o OUTPUT] [--basekit PATH]
#
# OUTPUT (default single/out/botlish) is one Linux executable of the host's
# architecture -- x86-64, the published one; AArch64 builds too, without a
# stub linker (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md) -- that needs only
# glibc: a static Tcl 9 "zipkit" base with the compiler stack and the
# native backend packed into its attached zip archive (single/package.tcl,
# single/main.tcl). It takes main.tcl's options and arguments and runs every
# backend, -emit-native-executable included (through the toolchain-free `stub`
# linker, runtime/aotimage.rs, for a program that calls no C, and through the
# `system` linker -- the host's C compiler driver and the packed runtime
# archive, no Rust -- for one that does: SINGLE-EXECUTABLE-FFI-MILESTONE-1.md).
#
# The base kit is single/basekit.sh's: Tcl's static library, built once from
# the source release pinned below and cached, linked with single/basekit.c as its
# main program -- a tclsh that never runs a Tcl library TCL_LIBRARY names.
# --basekit PATH (or $BOTLISH_BASEKIT) uses a base kit single/basekit.sh
# linked before. Whichever it is, it is checked first: started with
# TCL_LIBRARY naming a decoy library, it must take its own and give its
# script the variable back. Any other Tcl (a stock tclsh, a prebuilt zipkit)
# runs the decoy's init.tcl, and is refused.
#
# The native backend is built with cargo (`cargo build --release`, the same
# build the test suite uses); its executables and the runtime archive are
# packed with their debug information stripped when `strip` is available.
# The runtime archive's system libraries, which the driver passes the linker
# after it, are checked against rustc's own account of them
# (`--print native-static-libs`; native/runtime-archive/libraries.tcl).
set -euo pipefail

# The Tcl release the base kit's Tcl is built from (single/basekit.sh;
# single/macos/tcl-framework.sh builds the macOS application's from it too).
TCL_VERSION=9.0.1
TCL_SHA256=a72b1607d7a399c75148c80fcdead88ed3371a29884181f200f2200cdee33bbc
TCL_URLS=(
  "https://downloads.sourceforge.net/project/tcl/Tcl/${TCL_VERSION}/tcl${TCL_VERSION}-src.tar.gz"
  "https://prdownloads.sourceforge.net/tcl/tcl${TCL_VERSION}-src.tar.gz"
)

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
output="$root/single/out/botlish"
basekit=${BOTLISH_BASEKIT:-}
while [[ $# -gt 0 ]]; do
  case $1 in
    -o) output=$2; shift 2 ;;
    --basekit) basekit=$2; shift 2 ;;
    -h|--help) sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//;$d'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
case $output in /*) ;; *) output="$PWD/$output" ;; esac

work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-single-build.XXXXXX")
trap 'rm -rf "$work"' EXIT

# --- the base kit -------------------------------------------------------------
if [[ -z $basekit ]]; then
  basekit="$work/basekit"
  "$root/single/basekit.sh" "$basekit"
fi
# Whatever the base kit, it starts with its own Tcl library and gives its
# script the TCL_LIBRARY the environment had: a decoy library's init.tcl,
# named by TCL_LIBRARY, never runs (single/basekit.c). (The compiler's own
# check is single/smoke-test.sh's, on the executable this builds.)
mkdir -p "$work/decoy"
printf 'puts stderr "a decoy init.tcl ran"\nexit 3\n' >"$work/decoy/init.tcl"
started=$(echo 'puts [info library]; puts $env(TCL_LIBRARY)' | TCL_LIBRARY="$work/decoy" "$basekit" 2>&1) || true
if [[ $started != "//zipfs:/app/tcl_library"$'\n'"$work/decoy" ]]; then
  echo "the base kit $basekit does not start with its own Tcl library under TCL_LIBRARY=$work/decoy:" >&2
  echo "$started" >&2
  echo "(a stock tclsh or zipkit runs the init.tcl TCL_LIBRARY names: leave out --basekit, and single/basekit.sh links one)" >&2
  exit 1
fi
echo "== base kit: $basekit (Tcl $(echo 'puts [info patchlevel]' | "$basekit"))"

# --- the native backend -------------------------------------------------------
echo "== building the native backend"
(cd "$root" && cargo build --release --manifest-path native/Cargo.toml)
"$basekit" "$root/native/runtime-archive/libraries.tcl"
mkdir -p "$work/native"
for name in botlish-native botlish-aot-stub libbotlish_runtime.a; do
  cp "$root/native/target/release/$name" "$work/native/$name"
  if command -v strip >/dev/null 2>&1; then
    strip --strip-debug "$work/native/$name"
  fi
done

# --- the single executable ----------------------------------------------------
mkdir -p "$(dirname "$output")"
"$basekit" "$root/single/package.tcl" "$output" "$work/native"
