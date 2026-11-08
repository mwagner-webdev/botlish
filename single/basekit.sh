#!/usr/bin/env bash
# single/basekit.sh -- links the single-file compiler's base kit
# (SINGLE-EXECUTABLE.md, "How it is built").
#
#   single/basekit.sh OUTPUT
#
# OUTPUT is a static, zipfs-capable tclsh whose main program is
# single/basekit.c (beside this script) instead of Tcl's unix/tclAppInit.c:
# a tclsh that never runs a Tcl library TCL_LIBRARY names. Tcl's script
# library is attached as a zip archive. It is linked, in a second, from
# Tcl's static build: the static library with the bundled zlib and
# libtommath, its script library's zip, its public headers and its
# tclConfig.sh. That build is made once from the official source release
# single/build.sh pins (TCL_VERSION, checked against TCL_SHA256) and
# cached, never changed,
# in ${BOTLISH_BASEKIT_CACHE:-~/.cache/botlish-single}/tclVERSION-static.
# Making it needs a C compiler, make and curl. $TCL_SOURCE_TARBALL names an
# already downloaded tarball instead of downloading it.
#
# single/build.sh runs this, then checks the base kit (a decoy TCL_LIBRARY
# never runs); audit/single-executable/tools/mutate.tcl runs it for its
# mutants of single/basekit.c, which the smoke tests judge.
set -euo pipefail

[[ $# -eq 1 ]] || { echo "usage: single/basekit.sh OUTPUT" >&2; exit 2; }
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# The pin: single/build.sh's TCL_VERSION, TCL_SHA256 and TCL_URLS (as
# single/macos/tcl-framework.sh reads it).
eval "$(sed -n -e '/^TCL_VERSION=/p' -e '/^TCL_SHA256=/p' -e '/^TCL_URLS=(/,/^)/p' "$here/build.sh")"
output=$1
case $output in /*) ;; *) output="$PWD/$output" ;; esac

work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-basekit.XXXXXX")
trap 'rm -rf "$work"' EXIT

cache=${BOTLISH_BASEKIT_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/botlish-single}
tcl="$cache/tcl${TCL_VERSION}-static"
if [[ ! -f $tcl/tclConfig.sh ]]; then
  echo "== building Tcl ${TCL_VERSION}'s static library (once; cached in $tcl)"
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
  mkdir -p "$work/tcl-src" "$work/tcl-build" "$work/tcl/include"
  tar -xzf "$tarball" -C "$work/tcl-src"
  (
    cd "$work/tcl-build"
    # Static libtcl with zipfs, its script library as a zip, Tcl's own
    # copies of libtommath and zlib: a program linked with it links only
    # libc and libm. (make's tclsh target builds the library and the zip;
    # its tclsh, Tcl's unix/tclAppInit.c, is not the base kit.)
    ac_cv_header_zlib_h=no "$work/tcl-src/tcl${TCL_VERSION}/unix/configure" \
      --disable-shared --enable-zipfs --with-system-libtommath=no >configure.log
    make -j"$(nproc)" tclsh >make.log
    make install-headers INCLUDE_INSTALL_DIR="$work/tcl/include" >>make.log
    . ./tclConfig.sh
    cp tclConfig.sh "$TCL_LIB_FILE" "$TCL_ZIP_FILE" "$work/tcl/"
  )
  # Into place whole, under its final name only once complete; a concurrent
  # build that got there first keeps its own.
  mkdir -p "$cache"
  cp -R "$work/tcl" "$tcl.partial.$$"
  mv -T "$tcl.partial.$$" "$tcl" 2>/dev/null || rm -rf "$tcl.partial.$$"
fi

# single/basekit.c linked the way unix/Makefile links tclsh, and Tcl's script
# library appended (its ZIPFS_BUILD=2 rule).
(
  . "$tcl/tclConfig.sh"
  # (Word splitting intended: each of these variables holds flags.)
  # shellcheck disable=SC2086
  $TCL_CC $TCL_CFLAGS_OPTIMIZE $TCL_EXTRA_CFLAGS $TCL_CFLAGS_WARNING -I"$tcl/include" \
    -c "$here/basekit.c" -o "$work/basekit.o"
  # shellcheck disable=SC2086
  $TCL_CC $TCL_CFLAGS_OPTIMIZE $TCL_LD_FLAGS "$work/basekit.o" "$tcl/$TCL_LIB_FILE" $TCL_LIBS -o "$work/basekit"
  cat "$tcl/$TCL_ZIP_FILE" >>"$work/basekit"
)
mkdir -p "$(dirname "$output")"
mv "$work/basekit" "$output"
