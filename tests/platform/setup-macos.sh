#!/usr/bin/env bash
# tests/platform/setup-macos.sh -- the macOS prerequisites of this checkout
# (MACOS-AARCH64-PORT-AUDIT.md, section 16): what .devcontainer/setup.sh
# installs on Linux, for a macOS host.
#
#   tests/platform/setup-macos.sh ?GITHUB_PATH-FILE?
#
# Tcl: this repository's baseline, Tcl 9.0.1 (AGENTS.md), built once from
# the source release single/build.sh pins (the same version and sha256)
# into $BOTLISH_TCL_PREFIX (default ~/.cache/botlish/tcl-9.0.1; CI caches
# it), then first on PATH. Not Homebrew's tcl-tk: it ships a newer 9.0.x
# whose Unicode 17 case tables make the Tcl backends' std::str::lowercase and
# uppercase disagree with Botlish's Unicode 16 semantics, which the native
# runtime keeps (native/src/runtime/ops.rs, `rt_str_lower`) -- the census
# found tests/native-tcl-unicode.test failing that way. The build needs the
# Xcode command-line tools, curl and shasum, which macOS has.
# Rust: the stable toolchain, as on Linux (the pinned cranelift crates need
# a recent rustc). With a file argument (a workflow's $GITHUB_PATH) the Tcl
# and Cargo bin directories are appended to it for later steps.
set -euo pipefail

[ "$(uname -s)" = Darwin ] || { echo "setup-macos.sh: not a macOS host" >&2; exit 1; }

TCL_VERSION=9.0.1
TCL_SHA256=a72b1607d7a399c75148c80fcdead88ed3371a29884181f200f2200cdee33bbc
TCL_URLS="https://downloads.sourceforge.net/project/tcl/Tcl/${TCL_VERSION}/tcl${TCL_VERSION}-src.tar.gz
https://prdownloads.sourceforge.net/tcl/tcl${TCL_VERSION}-src.tar.gz"
prefix=${BOTLISH_TCL_PREFIX:-$HOME/.cache/botlish/tcl-$TCL_VERSION}

if [ ! -x "$prefix/bin/tclsh9.0" ]; then
  echo "== building Tcl $TCL_VERSION into $prefix (once)"
  work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-tcl.XXXXXX")
  trap 'rm -rf "$work"' EXIT
  tarball="$work/tcl$TCL_VERSION-src.tar.gz"
  for url in $TCL_URLS; do
    if curl -fsSL --retry 3 -o "$tarball" "$url"; then break; fi
  done
  [ -f "$tarball" ] || { echo "setup-macos.sh: cannot download the Tcl $TCL_VERSION source" >&2; exit 1; }
  echo "$TCL_SHA256  $tarball" | shasum -a 256 -c - || {
    echo "setup-macos.sh: $tarball is not the Tcl $TCL_VERSION source release (sha256 mismatch)" >&2
    exit 1
  }
  tar -xzf "$tarball" -C "$work"
  mkdir -p "$work/build"
  # (set -e does not apply inside a subshell on the left of ||: chain.)
  ( cd "$work/build" &&
    "$work/tcl$TCL_VERSION/unix/configure" --prefix="$prefix" >configure.log &&
    make -j"$(sysctl -n hw.ncpu)" >make.log &&
    make install >install.log ) || {
    for log in configure make install; do
      if [ -f "$work/build/$log.log" ]; then
        echo "== $log.log (last lines)" >&2
        tail -30 "$work/build/$log.log" >&2
      fi
    done
    echo "setup-macos.sh: the Tcl $TCL_VERSION build failed" >&2
    exit 1
  }
  rm -rf "$work"
  trap - EXIT
fi
export PATH="$prefix/bin:$PATH"
if [ $# -ge 1 ]; then
  echo "$prefix/bin" >> "$1"
fi

if ! command -v rustup >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain none
  export PATH="$HOME/.cargo/bin:$PATH"
  if [ $# -ge 1 ]; then
    echo "$HOME/.cargo/bin" >> "$1"
  fi
fi
# The pinned toolchain (rust-toolchain.toml), installed and made the default.
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/tools/rust-toolchain.sh" install

tclsh9.0 <<EOF
puts "Tcl [info patchlevel] ([info nameofexecutable]), tcltest [package require tcltest 2.5]"
if {[info patchlevel] ne "$TCL_VERSION"} {
    puts stderr "setup-macos.sh: Tcl $TCL_VERSION is required, found [info patchlevel]"
    exit 1
}
EOF
rustc --version
cargo --version
