#!/usr/bin/env bash
# single/macos/build.sh -- builds the macOS distribution of the Botlish
# compiler, Botlish.app (MACOS-AARCH64-MILESTONE-9.md).
#
#   single/macos/build.sh [-o DIR] [--tcl-framework DIR] [--native-dir DIR] [--no-verify]
#
# Runs on Apple Silicon macOS with Apple's command-line tools. DIR (default
# single/out/macos) receives
#
#   Botlish.app/                      the application, ad-hoc signed
#   botlish-macos-aarch64.zip         the download: the application archived
#                                     by ditto (symbolic links and modes
#                                     kept; no extended attribute needed)
#   botlish-macos-aarch64.zip.sha256  its checksum
#
# The application is a command-line compiler: Contents/MacOS/botlish takes
# main.tcl's options and arguments (a symbolic link to it on PATH works).
#
#   Botlish.app/Contents/
#     Info.plist
#     MacOS/botlish                   the launcher (single/macos/launcher.c),
#                                     linked to the bundled Tcl.framework
#                                     through LC_RPATH
#                                     @executable_path/../Frameworks
#     MacOS/botlish-native            the native backend's driver
#     Frameworks/Tcl.framework/       Tcl 9 (single/macos/tcl-framework.sh)
#     Resources/botlish.zip           the compiler: single/package.tcl
#                                     -archive (single/main.tcl, main.tcl and
#                                     the compiler stack, stdlib/,
#                                     compilerpedia/), mounted read-only at
#                                     //zipfs:/app
#     Resources/libbotlish_runtime.a  the runtime archive the system linker
#                                     links executables with
#     _CodeSignature/CodeResources    the seal of everything above
#
# The steps:
#
#   1. Tcl.framework: --tcl-framework DIR (a tcl-framework.sh output), or
#      built once by tcl-framework.sh and cached in
#      ${BOTLISH_APP_CACHE:-~/Library/Caches/botlish-app}, keyed by its
#      recipe (that script, the Tcl pin, the deployment target).
#   2. The native backend: `cargo build --release` (the build the test suite
#      uses), its runtime archive's system libraries checked against rustc's
#      (native/runtime-archive/libraries.tcl) -- or --native-dir DIR's
#      botlish-native and libbotlish_runtime.a. Their debug symbols are
#      stripped (strip -S). No botlish-aot-stub: the stub linker is Linux
#      x86-64's; `auto` links every macOS executable with the system linker.
#   3. The launcher: clang, against the framework's headers, the framework
#      weakly linked (a missing or damaged one is the launcher's diagnostic).
#   4. Signing, ad hoc (codesign --sign -: no Developer ID, no hardened
#      runtime, no notarization), inner code first, never --deep: the
#      framework's version directory, the driver, then -- after the compiler
#      archive is written, whose native-bin/ID names the driver as signed --
#      the application: its main executable and the seal of its resources.
#      Nothing is changed after it is signed.
#   5. single/macos/verify.sh on the application (layout, architectures,
#      dynamic dependencies and load paths, signatures, archive contents
#      against this checkout), then the download archive, extracted again
#      and verified -- unless --no-verify (audit/macos-app/tools/mutate.tcl
#      runs the verification itself, as a detector).
#
# The deployment target is $MACOSX_DEPLOYMENT_TARGET, default 11.0: rustc's
# for aarch64-apple-darwin, which the driver and the runtime archive are
# built for (the system linker links executables for it too).
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
here="$root/single/macos"
output="$root/single/out/macos"
tcl_framework=""
native_dir=""
verify=1
while [[ $# -gt 0 ]]; do
  case $1 in
    -o) output=$2; shift 2 ;;
    --tcl-framework) tcl_framework=$2; shift 2 ;;
    --native-dir) native_dir=$2; shift 2 ;;
    --no-verify) verify=0; shift ;;
    -h|--help) sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//;$d'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
fail() { echo "single/macos/build.sh: $*" >&2; exit 1; }
[[ $(uname -s) == Darwin && $(uname -m) == arm64 ]] || fail "the macOS application is built on Apple Silicon macOS (not $(uname -s) $(uname -m))"
case $output in /*) ;; *) output="$PWD/$output" ;; esac
export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-11.0}
identifier=io.github.mwagner-webdev.botlish
tcl_version=$(sed -n 's/^TCL_VERSION=\([0-9]*\.[0-9]*\).*/\1/p' "$root/single/build.sh")

# --- 1. Tcl.framework ---------------------------------------------------------
if [[ -z $tcl_framework ]]; then
  key=$( { cat "$here/tcl-framework.sh"; grep -E '^TCL_(VERSION|SHA256)=' "$root/single/build.sh"; echo "$MACOSX_DEPLOYMENT_TARGET"; } | shasum -a 256 | cut -c1-16)
  cache=${BOTLISH_APP_CACHE:-$HOME/Library/Caches/botlish-app}
  tcl_framework="$cache/tcl-framework-$key"
  if [[ ! -f $tcl_framework/BUILD ]]; then
    echo "== building Tcl.framework (once; cached as $tcl_framework)"
    mkdir -p "$cache"
    rm -rf "$tcl_framework.partial.$$"
    "$here/tcl-framework.sh" "$tcl_framework.partial.$$"
    rm -rf "$tcl_framework"
    mv "$tcl_framework.partial.$$" "$tcl_framework"
  fi
fi
[[ -f $tcl_framework/BUILD && -d $tcl_framework/Tcl.framework ]] || fail "no Tcl.framework build at $tcl_framework"
# The framework's tclsh runs the packaging scripts, with its own script
# library named (never another installation's).
tclsh() { TCL_LIBRARY="$tcl_framework/Tcl.framework/Versions/$tcl_version/Resources/Scripts" "$tcl_framework/tclsh$tcl_version" "$@"; }
echo "== Tcl.framework: $tcl_framework ($(tr '\n' ';' <"$tcl_framework/BUILD"))"

work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-app-build.XXXXXX")
trap 'rm -rf "$work"' EXIT

# --- 2. the native backend ----------------------------------------------------
if [[ -z $native_dir ]]; then
  echo "== building the native backend"
  (cd "$root" && cargo build --release --manifest-path native/Cargo.toml)
  tclsh "$root/native/runtime-archive/libraries.tcl"
  native_dir="$root/native/target/release"
fi
mkdir -p "$work/native"
for name in botlish-native libbotlish_runtime.a; do
  [[ -f $native_dir/$name ]] || fail "missing $native_dir/$name: build the native backend first (cargo build --release --manifest-path native/Cargo.toml)"
  cp "$native_dir/$name" "$work/native/$name"
  strip -S "$work/native/$name"
done

# --- 3. the bundle, unsigned --------------------------------------------------
app="$output/Botlish.app"
contents="$app/Contents"
rm -rf "$app"
mkdir -p "$contents/MacOS" "$contents/Frameworks" "$contents/Resources"
revision=unknown
if commit=$(git -C "$root" rev-parse --short HEAD 2>/dev/null); then
  revision=$commit
  [[ -z $(git -C "$root" status --porcelain --untracked-files=no 2>/dev/null) ]] || revision="$commit (modified)"
fi
cat >"$contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>botlish</string>
	<key>CFBundleIdentifier</key>
	<string>$identifier</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Botlish</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>0.0</string>
	<key>CFBundleVersion</key>
	<string>0</string>
	<key>LSMinimumSystemVersion</key>
	<string>$MACOSX_DEPLOYMENT_TARGET</string>
	<key>LSBackgroundOnly</key>
	<true/>
	<key>BotlishSourceRevision</key>
	<string>$revision</string>
</dict>
</plist>
EOF
plutil -lint "$contents/Info.plist" >/dev/null
# (cp -R keeps the framework's symbolic links as links.)
cp -R "$tcl_framework/Tcl.framework" "$contents/Frameworks/Tcl.framework"
cp "$work/native/botlish-native" "$contents/MacOS/botlish-native"
cp "$work/native/libbotlish_runtime.a" "$contents/Resources/libbotlish_runtime.a"
chmod 755 "$contents/MacOS/botlish-native"
chmod 644 "$contents/Resources/libbotlish_runtime.a"
echo "== the launcher"
clang -O2 -arch arm64 -mmacosx-version-min="$MACOSX_DEPLOYMENT_TARGET" -Wall -Wextra \
  -I "$tcl_framework/sdk/Headers" -F "$tcl_framework" -weak_framework Tcl \
  -Wl,-rpath,@executable_path/../Frameworks \
  -o "$contents/MacOS/botlish" "$here/launcher.c"

# --- 4. signing, inner to outer -----------------------------------------------
echo "== signing (ad hoc)"
codesign --force --sign - "$contents/Frameworks/Tcl.framework/Versions/$tcl_version"
codesign --force --sign - --identifier "$identifier.native" "$contents/MacOS/botlish-native"
# The compiler archive; its native-bin/ID names the native files as the
# bundle holds them (the driver signed).
mkdir -p "$work/bundled-native"
cp "$contents/MacOS/botlish-native" "$contents/Resources/libbotlish_runtime.a" "$work/bundled-native/"
tclsh "$root/single/package.tcl" -archive "$contents/Resources/botlish.zip" "$work/bundled-native"
chmod 644 "$contents/Resources/botlish.zip"
codesign --force --sign - "$app"

# --- 5. verification and the download -----------------------------------------
(( verify )) && "$here/verify.sh" --checkout "$root" "$app"
archive="$output/botlish-macos-aarch64.zip"
rm -f "$archive" "$archive.sha256"
(cd "$output" && ditto -c -k --norsrc --noextattr --noacl --keepParent Botlish.app "$(basename "$archive")")
(cd "$output" && shasum -a 256 "$(basename "$archive")" >"$(basename "$archive").sha256")
if (( verify )); then
  mkdir -p "$work/extracted"
  (cd "$work/extracted" && unzip -q "$archive")
  "$here/verify.sh" --checkout "$root" "$work/extracted/Botlish.app"
fi
echo "== $app ($(du -sk "$app" | cut -f1) KiB), $archive ($(wc -c <"$archive" | tr -d ' ') bytes): $(cut -d' ' -f1 "$archive.sha256")"
