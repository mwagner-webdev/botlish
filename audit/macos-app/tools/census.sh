#!/usr/bin/env bash
# audit/macos-app/tools/census.sh -- the macOS packaging census of
# MACOS-AARCH64-MILESTONE-9.md (section 3): small probes, on an Apple
# Silicon runner, of the questions the application's design answers.
#
#   audit/macos-app/tools/census.sh FRAMEWORK-BUILD APP
#
# FRAMEWORK-BUILD is a single/macos/tcl-framework.sh output (Tcl.framework,
# tclsh9.0 linked to it, sdk/), APP a Botlish.app from single/macos/build.sh.
# Each probe prints its commands and what they printed under a
# "######## C<N> TITLE" header; probes record facts, expected refusals
# included, and never stop the script (it exits 0 unless its inputs are
# missing). The probes:
#
#   C1  the framework Tcl's own macOS build makes: layout, install name,
#       architectures, dependencies, whether a zipfs library is attached
#   C2  how an executable linked to it finds Tcl's script library, and that
#       $TCL_LIBRARY comes first in Tcl's own search
#   C3  TclZipfs_AppHook and a separate ZIP file: what a stock tclsh does
#       with one, `zipfs mount` of one, its paths, and its writes
#   C4  a Linux-style zipkit (`zipfs mkimg`: the ZIP appended to the Mach-O)
#       and code signing: signing after appending, appending after signing,
#       strict verification, running
#   C5  the separate-resource application: relocation and invocation through
#       a symbolic link, its signature after a move
#   C6  the native JIT and the signature: the bundle's ad-hoc signed driver,
#       and the same driver under the hardened runtime (what a Developer ID
#       build would need: recorded, not adopted)
set -uo pipefail

[[ $# -eq 2 && -d $1/Tcl.framework && -d $2/Contents ]] ||
  { echo "usage: audit/macos-app/tools/census.sh FRAMEWORK-BUILD APP" >&2; exit 2; }
fwb=$(cd "$1" && pwd)
app=$(cd "$2" && pwd)
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
v=9.0
tclsh="$fwb/tclsh$v"
work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-census.XXXXXX")
trap 'rm -rf "$work"' EXIT
probe() { echo; echo "######## $*"; }
run() { echo "\$ $*"; "$@" 2>&1; echo "[status $?]"; }
shell() { echo "\$ $1"; bash -c "$1" 2>&1; echo "[status $?]"; }

probe C1 the framework Tcl builds
run cat "$fwb/BUILD"
shell "cd '$fwb' && find Tcl.framework -maxdepth 4 \\( -type l -o -type f \\) -not -path '*/Scripts/*' -not -path '*/tcl9/*' | sort"
shell "cd '$fwb' && ls -l Tcl.framework Tcl.framework/Versions"
run file "$fwb/Tcl.framework/Versions/$v/Tcl"
run otool -D "$fwb/Tcl.framework/Versions/$v/Tcl"
run otool -L "$fwb/Tcl.framework/Versions/$v/Tcl"
run codesign -dv "$fwb/Tcl.framework/Versions/$v/Tcl"
echo "# A zipfs library attached to the binary? (unzip finds no archive in it: configure sets ZIPFS_BUILD=0 for --enable-framework)"
run unzip -l "$fwb/Tcl.framework/Versions/$v/Tcl"
shell "du -sk '$fwb/Tcl.framework' '$fwb/Tcl.framework/Versions/$v/Tcl' '$fwb/Tcl.framework/Versions/$v/Resources/Scripts'"

probe C2 how an executable linked to the framework finds the script library
run otool -L "$tclsh"
run otool -l "$tclsh" | grep -A2 LC_RPATH
shell "echo 'puts \"info library: [info library]\"; puts \"tclDefaultLibrary: [expr {[info exists tclDefaultLibrary] ? \$tclDefaultLibrary : {(unset)}}]\"; puts \"nameofexecutable: [info nameofexecutable]\"; puts \"encoding system: [encoding system]\"' | env -i '$tclsh'"
mkdir -p "$work/decoy"
echo 'puts stderr "DECOY init.tcl sourced from [info script]"' >"$work/decoy/init.tcl"
echo "# The same, with TCL_LIBRARY naming another script library: Tcl's search tries it first."
shell "echo 'puts \"info library: [info library]\"' | env -i TCL_LIBRARY='$work/decoy' '$tclsh'"

probe C3 TclZipfs_AppHook and a separate ZIP file
mkdir -p "$work/stage/botlish"
printf 'puts "main.tcl of the archive: argv0=$argv0 argv=$argv nameofexecutable=[info nameofexecutable]"\n' >"$work/stage/main.tcl"
echo "inside" >"$work/stage/botlish/file.txt"
shell "cd '$work' && echo 'zipfs mkzip app.zip stage stage' | '$tclsh' && unzip -l app.zip"
echo "# A stock tclsh (tclAppInit.c calls TclZipfs_AppHook): an archive argument is a script file, not mounted (SUPPORT_BUILTIN_ZIP_INSTALL is not defined)."
run "$tclsh" "$work/app.zip" one two
echo "# zipfs mount of a separate file, its paths, and writes (in memory up to ::tcl::zipfs::wrmax; refused with 0)."
cat >"$work/mount.tcl" <<'EOF'
zipfs mount [lindex $argv 0] //zipfs:/app
puts "mounts: [zipfs mount]"
puts "glob: [lsort [glob //zipfs:/app/*]]"
puts "normalize: [file normalize //zipfs:/app/botlish/../botlish/file.txt]"
puts "dirname of main.tcl: [file dirname [file normalize //zipfs:/app/main.tcl]]"
puts "read: [string trim [read [set f [open //zipfs:/app/botlish/file.txt]]]]"; close $f
puts "writable: [file writable //zipfs:/app/botlish/file.txt] wrmax: $::tcl::zipfs::wrmax"
puts "write, default wrmax: [catch {set f [open //zipfs:/app/botlish/new.txt w]; puts $f x; close $f} m] $m"
set ::tcl::zipfs::wrmax 0
puts "write, wrmax 0: [catch {open //zipfs:/app/botlish/other.txt w} m] $m"
puts "the archive file unchanged: [file size [lindex $argv 0]] bytes"
EOF
run "$tclsh" "$work/mount.tcl" "$work/app.zip"
run ls -l "$work/app.zip"

probe C4 a zipkit: the ZIP appended to the Mach-O, and code signing
cp "$work/stage/main.tcl" "$work/stage/main.tcl.keep"
cp -R "$fwb/Tcl.framework" "$work/Tcl.framework"
shell "cd '$work' && echo 'zipfs mkimg kit stage stage {} [info nameofexecutable]' | '$tclsh' && ls -l kit"
echo "# The base kit's signature (the linker's, ad hoc) after zipfs mkimg appended the archive:"
run codesign -dv "$work/kit"
run codesign --verify --strict --verbose=2 "$work/kit"
echo "# Running it unsigned-again (the appended zip mounted by TclZipfs_AppHook):"
run "$work/kit" a b
echo "# Signing after appending:"
cp "$work/kit" "$work/kit-signed"
run codesign --force --sign - "$work/kit-signed"
run codesign --verify --strict --verbose=2 "$work/kit-signed"
run "$work/kit-signed" a b
echo "# Appending after signing: sign the base, then append the archive."
cp "$tclsh" "$work/base"
run codesign --force --sign - "$work/base"
shell "cd '$work' && cat base app.zip >appended && chmod +x appended && ls -l base appended"
run codesign --verify --strict --verbose=2 "$work/appended"
run "$work/appended" a b
echo "# Inside an application bundle (the kit as its main executable), signed and strictly verified:"
mkdir -p "$work/Kit.app/Contents/MacOS" "$work/Kit.app/Contents/Frameworks"
cp "$work/kit" "$work/Kit.app/Contents/MacOS/kit"
cp -R "$fwb/Tcl.framework" "$work/Kit.app/Contents/Frameworks/"
install_name_tool -add_rpath @executable_path/../Frameworks "$work/Kit.app/Contents/MacOS/kit" 2>&1
printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict><key>CFBundleExecutable</key><string>kit</string><key>CFBundleIdentifier</key><string>census.kit</string><key>CFBundlePackageType</key><string>APPL</string></dict></plist>\n' >"$work/Kit.app/Contents/Info.plist"
run codesign --force --sign - "$work/Kit.app/Contents/Frameworks/Tcl.framework/Versions/$v"
run codesign --force --sign - "$work/Kit.app"
run codesign --verify --deep --strict --verbose=2 "$work/Kit.app"
run "$work/Kit.app/Contents/MacOS/kit" a b

probe C5 the separate-resource application: relocation, symbolic links
run codesign --verify --deep --strict --verbose=2 "$app"
moved="$work/moved place/ü"
mkdir -p "$moved"
cp -R "$app" "$moved/"
run "$moved/Botlish.app/Contents/MacOS/botlish" -version
run codesign --verify --deep --strict --verbose=2 "$moved/Botlish.app"
ln -s "$moved/Botlish.app/Contents/MacOS/botlish" "$work/botlish-link"
run "$work/botlish-link" -version
run otool -L "$app/Contents/MacOS/botlish"
run otool -l "$app/Contents/MacOS/botlish" | grep -A2 LC_RPATH
echo "# The libraries dyld loads for the launcher (DYLD_PRINT_LIBRARIES):"
shell "env -i DYLD_PRINT_LIBRARIES=1 '$moved/Botlish.app/Contents/MacOS/botlish' -version 2>&1 >/dev/null | grep -v -e '/usr/lib/' -e '/System/Library/' ; true"

probe C6 the native JIT and the signature
printf '1 + 41\n' >"$work/jit.bot"
run codesign -dv --entitlements - "$app/Contents/MacOS/botlish-native"
run "$app/Contents/MacOS/botlish" -backend cranelift "$work/jit.bot"
echo "# The same driver signed with the hardened runtime and no entitlement (as a Developer ID build would be):"
cp "$app/Contents/MacOS/botlish-native" "$work/hardened-native"
run codesign --force --sign - --options runtime "$work/hardened-native"
shell "cd '$root' && BOTLISH_NATIVE_BIN='$work/hardened-native' '$tclsh' main.tcl -backend cranelift '$work/jit.bot'"
echo "# ... and with com.apple.security.cs.allow-jit (the entitlement for MAP_JIT memory):"
printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict><key>com.apple.security.cs.allow-jit</key><true/></dict></plist>\n' >"$work/jit.entitlements"
run codesign --force --sign - --options runtime --entitlements "$work/jit.entitlements" "$work/hardened-native"
shell "cd '$root' && BOTLISH_NATIVE_BIN='$work/hardened-native' '$tclsh' main.tcl -backend cranelift '$work/jit.bot'"
echo "# ... and with com.apple.security.cs.allow-unsigned-executable-memory:"
printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict><key>com.apple.security.cs.allow-unsigned-executable-memory</key><true/></dict></plist>\n' >"$work/unsigned.entitlements"
run codesign --force --sign - --options runtime --entitlements "$work/unsigned.entitlements" "$work/hardened-native"
shell "cd '$root' && BOTLISH_NATIVE_BIN='$work/hardened-native' '$tclsh' main.tcl -backend cranelift '$work/jit.bot'"
echo "# Gatekeeper's assessment of the ad-hoc signed application (not notarized):"
run spctl --assess --type execute --verbose=4 "$app"
echo
echo "######## census done"
