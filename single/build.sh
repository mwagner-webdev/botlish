#!/usr/bin/env bash
# single/build.sh -- builds the single-file Botlish compiler (SINGLE-EXECUTABLE.md).
#
#   single/build.sh [-o OUTPUT] [--basekit PATH]
#
# OUTPUT (default single/out/botlish) is one Linux x86-64 executable that needs
# only glibc: a static Tcl 9 "zipkit" base with the compiler stack and the
# native backend packed into its attached zip archive (single/package.tcl,
# single/main.tcl). It takes main.tcl's options and arguments and runs every
# backend, -emit-native-executable included (through the toolchain-free `stub`
# linker, runtime/aotimage.rs, for a program that calls no C, and through the
# `system` linker -- the host's C compiler driver and the packed runtime
# archive, no Rust -- for one that does: SINGLE-EXECUTABLE-FFI-MILESTONE-1.md).
#
# The base kit is --basekit PATH (or $BOTLISH_BASEKIT) if given: any
# zipfs-capable Tcl 9 executable with Tcl linked statically, such as a
# prebuilt zipkit. Otherwise this script builds one, once, from the official
# Tcl source release (TCL_VERSION below, checked against TCL_SHA256): a
# static tclsh with the bundled zlib and libtommath, cached in
# ${BOTLISH_BASEKIT_CACHE:-~/.cache/botlish-single}. Building it needs a C
# compiler, make and curl; $TCL_SOURCE_TARBALL names an already downloaded
# tarball instead of downloading it.
#
# The native backend is built with cargo (`cargo build --release`, the same
# build the test suite uses); its executables and the runtime archive are
# packed with their debug information stripped when `strip` is available.
# The runtime archive's system libraries, which the driver passes the linker
# after it, are checked against rustc's own account of them
# (`--print native-static-libs`).
set -euo pipefail

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
  cache=${BOTLISH_BASEKIT_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/botlish-single}
  basekit="$cache/tclsh${TCL_VERSION}-static"
  if [[ ! -x $basekit ]]; then
    echo "== building a static Tcl ${TCL_VERSION} base kit (once; cached as $basekit)"
    tarball=${TCL_SOURCE_TARBALL:-}
    if [[ -z $tarball ]]; then
      tarball="$work/tcl${TCL_VERSION}-src.tar.gz"
      for url in "${TCL_URLS[@]}"; do
        if curl -fsSL --retry 3 -o "$tarball" "$url"; then break; fi
        rm -f "$tarball"
      done
      [[ -f $tarball ]] || { echo "cannot download the Tcl ${TCL_VERSION} source" >&2; exit 1; }
    fi
    echo "${TCL_SHA256}  $tarball" | sha256sum -c --quiet - || {
      echo "$tarball is not the Tcl ${TCL_VERSION} source release (sha256 mismatch)" >&2
      exit 1
    }
    mkdir -p "$work/tcl-src" "$work/tcl-build"
    tar -xzf "$tarball" -C "$work/tcl-src"
    (
      cd "$work/tcl-build"
      # Static libtcl with zipfs (the tclsh gets the Tcl library zip
      # appended), Tcl's own copies of libtommath and zlib: the result links
      # only libc and libm.
      ac_cv_header_zlib_h=no "$work/tcl-src/tcl${TCL_VERSION}/unix/configure" \
        --disable-shared --enable-zipfs --with-system-libtommath=no >configure.log
      make -j"$(nproc)" tclsh >make.log
    )
    mkdir -p "$cache"
    cp "$work/tcl-build/tclsh" "$basekit.partial"
    mv "$basekit.partial" "$basekit"
  fi
fi
echo "== base kit: $basekit (Tcl $(echo 'puts [info patchlevel]' | "$basekit"))"

# --- the native backend -------------------------------------------------------
echo "== building the native backend"
(cd "$root" && cargo build --release --manifest-path native/Cargo.toml)
expected=$(cd "$root" && cargo rustc --release --manifest-path native/Cargo.toml -p botlish-runtime -- --print native-static-libs 2>&1 |
  sed -n 's/^note: native-static-libs: //p' | tail -n 1)
actual=$("$root/native/target/release/botlish-native" system-linker | sed -n 's/^libraries //p')
if [[ $expected != "$actual" ]]; then
  echo "the runtime archive's system libraries changed: rustc says '$expected', the driver passes '$actual' (codegen/aot.rs's runtime_system_libraries)" >&2
  exit 1
fi
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
