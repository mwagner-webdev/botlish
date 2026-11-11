#!/usr/bin/env bash
# single/macos/sign.sh -- signs Botlish.app, inner code first
# (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, "Signing order").
#
#   single/macos/sign.sh --identity ID [--keychain PATH] [--timestamp]
#                        (--tcl-framework DIR | --tclsh TCLSH) APP
#
# ID "-" signs ad hoc (single/macos/build.sh); any other is a Developer ID
# Application identity (its SHA-1) in KEYCHAIN (the release's temporary
# keychain: tools/macos-release/release.py's sign stage), with Apple's secure
# timestamp when --timestamp is given (an ad hoc signature asks for none).
# Every signature has the hardened runtime (--options runtime) and no
# entitlement: the application's driver has no JIT (built without it), and
# nothing in the bundle makes executable memory. The signing units, in order:
#
#   1. Contents/Frameworks/Tcl.framework/Versions/9.0 -- the framework's
#      library and the seal of its resources (identifier com.tcltk.tcllibrary,
#      from its Info.plist);
#   2. Contents/MacOS/botlish-native, the native driver (identifier
#      io.github.mwagner-webdev.botlish.native);
#   3. Contents/Resources/botlish.zip written (single/package.tcl -archive,
#      run by DIR's tclsh or TCLSH, a zipfs-capable Tcl 9), so its
#      native-bin/ID names the driver as it is now signed (a signature
#      changes the driver's bytes) -- the rest of it is this checkout's
#      compiler, which single/macos/verify.sh --checkout compares file for
#      file;
#   4. the application -- its main executable Contents/MacOS/botlish and the
#      seal of every resource (the runtime archive and the compiler archive
#      included) -- identifier io.github.mwagner-webdev.botlish.
#
# Never --deep (each signing unit is signed once, by itself), nothing changed
# after its signature is made. Static archives (libbotlish_runtime.a) and
# the compiler archive are no code: they are sealed resources of step 4.
set -euo pipefail

identity=""
keychain=()
timestamp=--timestamp=none
tcl_framework=""
tcl_shell=""
while [[ $# -gt 1 ]]; do
  case $1 in
    --identity) identity=$2; shift 2 ;;
    --keychain) keychain=(--keychain "$2"); shift 2 ;;
    --timestamp) timestamp=--timestamp; shift ;;
    --tcl-framework) tcl_framework=$2; shift 2 ;;
    --tclsh) tcl_shell=$2; shift 2 ;;
    *) echo "single/macos/sign.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
[[ $# -eq 1 && -n $identity && ( -n $tcl_framework || -n $tcl_shell ) ]] ||
  { echo "usage: single/macos/sign.sh --identity ID [--keychain PATH] [--timestamp] (--tcl-framework DIR | --tclsh TCLSH) APP" >&2; exit 2; }
app=$(cd "$1" && pwd)
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
contents="$app/Contents"
identifier=io.github.mwagner-webdev.botlish
tcl_version=$(sed -n 's/^TCL_VERSION=\([0-9]*\.[0-9]*\).*/\1/p' "$root/single/build.sh")
fail() { echo "single/macos/sign.sh: $*" >&2; exit 1; }
[[ $identity == - && $timestamp == --timestamp ]] && fail "an ad hoc signature has no secure timestamp"
if [[ -n $tcl_framework ]]; then
  [[ -f $tcl_framework/BUILD ]] || fail "no Tcl.framework build at $tcl_framework"
  tclsh() { TCL_LIBRARY="$tcl_framework/Tcl.framework/Versions/$tcl_version/Resources/Scripts" "$tcl_framework/tclsh$tcl_version" "$@"; }
else
  tclsh() { "$tcl_shell" "$@"; }
fi
sign() { codesign --force --sign "$identity" ${keychain[@]+"${keychain[@]}"} --options runtime "$timestamp" "$@"; }

sign "$contents/Frameworks/Tcl.framework/Versions/$tcl_version"
sign --identifier "$identifier.native" "$contents/MacOS/botlish-native"
# The compiler archive: its native-bin/ID names the native files as the
# bundle holds them, the driver as just signed.
work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-app-sign.XXXXXX")
trap 'rm -rf "$work"' EXIT
cp "$contents/MacOS/botlish-native" "$contents/Resources/libbotlish_runtime.a" "$work/"
tclsh "$root/single/package.tcl" -archive "$contents/Resources/botlish.zip" "$work" >/dev/null
chmod 644 "$contents/Resources/botlish.zip"
sign "$app"
echo "signed $( [[ $identity == - ]] && echo 'ad hoc' || echo "with $identity" ) (hardened runtime, $( [[ $timestamp == --timestamp ]] && echo 'secure timestamp' || echo 'no timestamp' )): $app"
