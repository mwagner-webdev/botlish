#!/usr/bin/env bash
# single/macos/sign.sh -- signs Botlish.app, inner code first
# (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, "Signing order").
#
#   single/macos/sign.sh --identity ID [--keychain PATH] [--timestamp]
#                        --tcl-framework DIR APP
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
#   3. Contents/Resources/botlish.zip written again (single/package.tcl
#      -archive, run by DIR's tclsh) only when its native-bin/ID no longer
#      names the driver as it is now signed (a signature changes the driver's
#      bytes): never a change of anything else in it;
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
while [[ $# -gt 1 ]]; do
  case $1 in
    --identity) identity=$2; shift 2 ;;
    --keychain) keychain=(--keychain "$2"); shift 2 ;;
    --timestamp) timestamp=--timestamp; shift ;;
    --tcl-framework) tcl_framework=$2; shift 2 ;;
    *) echo "single/macos/sign.sh: unknown argument: $1" >&2; exit 2 ;;
  esac
done
[[ $# -eq 1 && -n $identity && -n $tcl_framework ]] ||
  { echo "usage: single/macos/sign.sh --identity ID [--keychain PATH] [--timestamp] --tcl-framework DIR APP" >&2; exit 2; }
app=$(cd "$1" && pwd)
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
contents="$app/Contents"
identifier=io.github.mwagner-webdev.botlish
tcl_version=$(sed -n 's/^TCL_VERSION=\([0-9]*\.[0-9]*\).*/\1/p' "$root/single/build.sh")
fail() { echo "single/macos/sign.sh: $*" >&2; exit 1; }
[[ -f $tcl_framework/BUILD ]] || fail "no Tcl.framework build at $tcl_framework"
[[ $identity == - && $timestamp == --timestamp ]] && fail "an ad hoc signature has no secure timestamp"
tclsh() { TCL_LIBRARY="$tcl_framework/Tcl.framework/Versions/$tcl_version/Resources/Scripts" "$tcl_framework/tclsh$tcl_version" "$@"; }
sign() { codesign --force --sign "$identity" "${keychain[@]}" --options runtime "$timestamp" "$@"; }

sign "$contents/Frameworks/Tcl.framework/Versions/$tcl_version"
sign --identifier "$identifier.native" "$contents/MacOS/botlish-native"
# The compiler archive's native-bin/ID names the native files as the bundle
# holds them: written again for the driver as just signed.
crc() { printf '%08x-%s' "$(cksum -o 3 <"$1" | cut -d' ' -f1)" "$(wc -c <"$1" | tr -d ' ')"; }
want="$(crc "$contents/MacOS/botlish-native")-$(crc "$contents/Resources/libbotlish_runtime.a")"
got=$(unzip -p "$contents/Resources/botlish.zip" native-bin/ID 2>/dev/null | tr -d '\n' || true)
if [[ $got != "$want" ]]; then
  work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-app-sign.XXXXXX")
  trap 'rm -rf "$work"' EXIT
  cp "$contents/MacOS/botlish-native" "$contents/Resources/libbotlish_runtime.a" "$work/"
  tclsh "$root/single/package.tcl" -archive "$contents/Resources/botlish.zip" "$work" >/dev/null
  chmod 644 "$contents/Resources/botlish.zip"
  got=$(unzip -p "$contents/Resources/botlish.zip" native-bin/ID | tr -d '\n')
  [[ $got == "$want" ]] || fail "the compiler archive's native-bin/ID is $got after packing, not the driver's $want"
fi
sign "$app"
echo "signed $( [[ $identity == - ]] && echo 'ad hoc' || echo "with $identity" ) (hardened runtime, $( [[ $timestamp == --timestamp ]] && echo 'secure timestamp' || echo 'no timestamp' )): $app"
