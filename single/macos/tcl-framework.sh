#!/usr/bin/env bash
# single/macos/tcl-framework.sh -- builds the Tcl.framework that the macOS
# application bundles (MACOS-AARCH64-MILESTONE-9.md, "The bundled
# Tcl.framework").
#
#   single/macos/tcl-framework.sh OUTPUT
#
# Builds Tcl from the official source release single/build.sh pins (the
# same version and sha256: this repository's Tcl baseline, AGENTS.md) as a
# macOS framework, with Tcl's own macOS build (unix/configure
# --enable-framework, which macosx/GNUmakefile wraps), for arm64 and the
# deployment target $MACOSX_DEPLOYMENT_TARGET (default 11.0, rustc's for
# aarch64-apple-darwin, which the native backend and its runtime archive are
# built for). OUTPUT is a new directory; it receives
#
#   Tcl.framework/  the framework the application bundles, exactly what runs:
#                   Versions/9.0/Tcl (the library; install name
#                   @rpath/Tcl.framework/Versions/9.0/Tcl, so an executable
#                   finds it through its own LC_RPATH, wherever it is), its
#                   Resources (Info.plist, license.terms, Scripts -- Tcl's
#                   script library: a framework build attaches no zipfs
#                   library to the Tcl binary, configure sets ZIPFS_BUILD=0
#                   with --enable-framework -- and tcl9, its modules),
#                   Versions/Current and the top-level Tcl and Resources
#                   links; no headers, stub library or tclConfig.sh
#   sdk/            what building against it needs and the application
#                   leaves out: Headers/ (tcl.h ...), libtclstub.a,
#                   tclConfig.sh
#   tclsh9.0        Tcl's own shell, linked to Tcl.framework above (its
#                   LC_RPATH is @executable_path): the census's probes
#                   (audit/macos-app/tools/census.sh) and a Tcl 9 to run
#                   packaging scripts with; never bundled
#   BUILD           the recipe: version, sha256, configure arguments,
#                   deployment target, the install name
#
# Nothing is installed outside OUTPUT: the build runs in a private
# temporary directory and installs into a staging root (INSTALL_ROOT), never
# into /Library/Frameworks. It needs Apple's command-line tools (clang, make,
# install_name_tool, codesign), curl and shasum. $TCL_SOURCE_TARBALL names an
# already downloaded tarball instead of downloading it.
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
# The pin: single/build.sh's TCL_VERSION, TCL_SHA256 and TCL_URLS.
eval "$(sed -n -e '/^TCL_VERSION=/p' -e '/^TCL_SHA256=/p' -e '/^TCL_URLS=(/,/^)/p' "$root/single/build.sh")"

fail() { echo "tcl-framework.sh: $*" >&2; exit 1; }
[[ $# -eq 1 ]] || { echo "usage: single/macos/tcl-framework.sh OUTPUT" >&2; exit 2; }
[[ $(uname -s) == Darwin && $(uname -m) == arm64 ]] || fail "this builds an arm64 macOS framework: run it on Apple Silicon macOS (not $(uname -s) $(uname -m))"
output=$1
case $output in /*) ;; *) output="$PWD/$output" ;; esac
[[ ! -e $output ]] || fail "$output exists"

version=${TCL_VERSION%.*}
install_name_dir="@rpath/Tcl.framework/Versions/$version"
export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-11.0}
configure_args=(--enable-framework --libdir=/Frameworks --prefix=/usr/local --disable-zipfs)
cflags="-O2 -arch arm64"

work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-tcl-framework.XXXXXX")
trap 'rm -rf "$work"' EXIT

tarball=${TCL_SOURCE_TARBALL:-}
if [[ -z $tarball ]]; then
  tarball="$work/tcl${TCL_VERSION}-src.tar.gz"
  for url in "${TCL_URLS[@]}"; do
    if curl -fsSL --retry 3 -o "$tarball" "$url"; then break; fi
    rm -f "$tarball"
  done
  [[ -f $tarball ]] || fail "cannot download the Tcl $TCL_VERSION source"
fi
echo "${TCL_SHA256}  $tarball" | shasum -a 256 -c --quiet - ||
  fail "$tarball is not the Tcl $TCL_VERSION source release (sha256 mismatch)"
tar -xzf "$tarball" -C "$work"
src="$work/tcl$TCL_VERSION"
mkdir -p "$work/build" "$work/root"

logs() {
  for log in configure make install; do
    if [[ -f $work/build/$log.log ]]; then
      echo "== $log.log (last lines)" >&2
      tail -40 "$work/build/$log.log" >&2
    fi
  done
}
echo "== configuring Tcl $TCL_VERSION as a framework (${configure_args[*]}; macOS $MACOSX_DEPLOYMENT_TARGET)"
( cd "$work/build" && CFLAGS="$cflags" "$src/unix/configure" "${configure_args[@]}" >configure.log 2>&1 ) ||
  { logs; fail "configure failed"; }
echo "== building"
( cd "$work/build" && make -j"$(sysctl -n hw.ncpu)" DYLIB_INSTALL_DIR="$install_name_dir" binaries >make.log 2>&1 ) ||
  { logs; fail "the build failed"; }
# Tcl's base installation (its install-binaries, install-libraries and
# install-msgs), with the headers for the launcher's build, into the
# staging root: $work/root/Frameworks/Tcl.framework.
( cd "$work/build" && make DYLIB_INSTALL_DIR="$install_name_dir" INSTALL_ROOT="$work/root" \
    install-binaries install-libraries install-msgs install-headers >install.log 2>&1 ) ||
  { logs; fail "the staging install failed"; }

staged="$work/root/Frameworks/Tcl.framework"
versioned="$staged/Versions/$version"
[[ -f $versioned/Tcl && -f $versioned/Resources/Scripts/init.tcl ]] ||
  { ls -lR "$work/root" >&2 || true; fail "the staged framework has no Versions/$version/Tcl or Resources/Scripts/init.tcl"; }
id=$(otool -D "$versioned/Tcl" | sed -n 2p)
[[ $id == "$install_name_dir/Tcl" ]] || fail "the library's install name is $id, not $install_name_dir/Tcl"

mkdir -p "$output/sdk"
# What only building against Tcl needs.
cp -R "$versioned/Headers" "$output/sdk/Headers"
cp "$versioned/libtclstub.a" "$versioned/tclConfig.sh" "$output/sdk/"
# The framework as it runs: the library and its Resources, the standard
# framework links (Versions/Current, Tcl, Resources), nothing else.
fw="$output/Tcl.framework"
mkdir -p "$fw/Versions/$version"
cp -p "$versioned/Tcl" "$fw/Versions/$version/Tcl"
cp -R "$versioned/Resources" "$fw/Versions/$version/Resources"
ln -s "$version" "$fw/Versions/Current"
ln -s Versions/Current/Tcl "$fw/Tcl"
ln -s Versions/Current/Resources "$fw/Resources"
chmod 755 "$fw/Versions/$version/Tcl"

# Tcl's shell, linked to this framework, beside it.
cp -p "$work/build/tclsh" "$output/tclsh$version"
install_name_tool -add_rpath @executable_path "$output/tclsh$version"
codesign --force --sign - "$output/tclsh$version"
probe=$(echo 'puts "[info patchlevel] [info library]"' | "$output/tclsh$version") ||
  fail "the framework's tclsh does not run"
[[ $probe == "$TCL_VERSION "* ]] || fail "the framework's tclsh reports $probe"

{
  echo "tcl $TCL_VERSION"
  echo "sha256 $TCL_SHA256"
  echo "configure ${configure_args[*]} CFLAGS=$cflags"
  echo "deployment-target $MACOSX_DEPLOYMENT_TARGET"
  echo "install-name $install_name_dir/Tcl"
} >"$output/BUILD"
echo "== Tcl.framework: $fw ($(du -sk "$fw" | cut -f1) KiB; $(lipo -archs "$fw/Versions/$version/Tcl"); tclsh: $probe)"
