#!/usr/bin/env bash
# package-macos.sh -- assembles "Icy Tower.app" (ICY-TOWER-MACOS-APP-
# MILESTONE-1.md, "Bundle construction") from the macOS executable
# build-macos.sh built:
#
#   examples/games/icy-tower/package-macos.sh EXECUTABLE OUTDIR \
#       --bundle-id ID --version X.Y.Z --build B --sdl3-license FILE
#
# OUTDIR receives "Icy Tower.app":
#
#   Icy Tower.app/Contents/Info.plist              (macos/bundle.py: plistlib)
#   Icy Tower.app/Contents/MacOS/icy-tower         EXECUTABLE, byte for byte
#   Icy Tower.app/Contents/Resources/LICENSE-Botlish.txt
#   Icy Tower.app/Contents/Resources/LICENSE-SDL3.txt
#
# It assembles; it never compiles, links, signs, notarizes or publishes. The
# executable is checked first (macos/bundle.py check-executable reads its
# Mach-O header and load commands: thin arm64, an executable, LC_MAIN's
# 512 MiB stack of the main-thread startup, a macOS LC_BUILD_VERSION no
# later than the bundle's minimum, system libraries only and none SDL3's),
# then copied as it is -- it keeps the linker's ad hoc signature until a
# trust path signs the whole bundle (macos/release.py sign: ad hoc in
# ordinary CI, Developer ID in a release). The Info.plist's values are
# checked before it is written (the identifier reverse-DNS, the versions one
# to three integers), the assembled bundle checked as a whole (bundle.py
# check: layout, metadata, executable, resources, nothing else), and only
# then does it replace OUTDIR's "Icy Tower.app": a refused bundle leaves an
# earlier one as it was.
#
# On macOS Apple's own tools must agree with bundle.py's reading: lipo -archs
# is arm64, otool -l's LC_MAIN stacksize is 536870912, otool -L lists only
# /usr/lib and /System/Library, plutil -lint accepts the Info.plist and
# plutil reads back the identifier. Anywhere else (Linux: the negative
# controls of audit/macos-release/) the Python checks alone run.
#
# The bundle identifier is the game's stable application identity: a
# release takes it from the repository's MACOS_BUNDLE_ID variable
# (docs/ICY-TOWER-MACOS-APP-MILESTONE-1.md, "Configuration"), ordinary CI
# from the workflow's fixed CI identifier; the version and build are the
# release's (X.Y.Z from the tag) or CI's 0.0.0.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
fail() { echo "package-macos.sh: $*" >&2; exit 1; }

[[ $# -ge 2 ]] || fail "usage: package-macos.sh EXECUTABLE OUTDIR --bundle-id ID --version X.Y.Z --build B --sdl3-license FILE"
exe=$1
out=$2
shift 2
bundle_id="" version="" build="" sdl_license=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --bundle-id) bundle_id=$2; shift 2 ;;
        --version) version=$2; shift 2 ;;
        --build) build=$2; shift 2 ;;
        --sdl3-license) sdl_license=$2; shift 2 ;;
        *) fail "unknown option $1" ;;
    esac
done
[[ -n $bundle_id && -n $version && -n $build && -n $sdl_license ]] || fail "--bundle-id, --version, --build and --sdl3-license are required"
[[ -f $sdl_license ]] || fail "no SDL3 license file $sdl_license"
bundle=(python3 -I "$here/macos/bundle.py")
darwin=0
[[ $(uname -s) == Darwin ]] && darwin=1

# --- 1. the executable -------------------------------------------------------
echo "== The executable: $exe"
"${bundle[@]}" check-executable "$exe" || fail "the executable is not the macOS game build-macos.sh builds (above)"
if (( darwin )); then
    archs=$(lipo -archs "$exe" 2>&1) || fail "lipo cannot read $exe: $archs"
    [[ $archs == arm64 ]] || fail "lipo -archs says $archs, not arm64"
    loads=$(otool -l "$exe")
    [[ $(grep -A4 'cmd LC_MAIN' <<<"$loads") == *"stacksize 536870912"* ]] || fail "otool -l: no 512 MiB LC_MAIN stack"
    libs=$(otool -L "$exe" | tail -n +2 | awk '{print $1}')
    while read -r lib; do
        case $lib in /usr/lib/*|/System/Library/*) ;; *) fail "otool -L: $exe needs $lib, no system library" ;; esac
    done <<<"$libs"
    echo "   lipo: $archs; otool: LC_MAIN 536870912, $(wc -l <<<"$libs" | tr -d ' ') system libraries"
fi

# --- 2. the bundle, assembled beside OUTDIR -----------------------------------
mkdir -p "$out"
out=$(cd "$out" && pwd)
work=$(mktemp -d "$out/.icy-tower-app.XXXXXX")
trap 'rm -rf "$work"' EXIT
umask 022
app="$work/Icy Tower.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
echo "== Info.plist: $bundle_id $version ($build)"
"${bundle[@]}" plist --bundle-id "$bundle_id" --version "$version" --build "$build" "$app/Contents/Info.plist" \
    || fail "the bundle's metadata was refused (above): nothing was assembled"
# (cp -X: no extended attribute of the build's copy -- a quarantine or a
# Finder flag -- comes into the bundle; plain cp elsewhere.)
if (( darwin )); then
    cp -X "$exe" "$app/Contents/MacOS/icy-tower"
else
    cp "$exe" "$app/Contents/MacOS/icy-tower"
fi
chmod 0755 "$app/Contents/MacOS/icy-tower"
cmp -s "$exe" "$app/Contents/MacOS/icy-tower" || fail "the bundled executable differs from $exe"
cp "$root/LICENSE" "$app/Contents/Resources/LICENSE-Botlish.txt"
cp "$sdl_license" "$app/Contents/Resources/LICENSE-SDL3.txt"
chmod 0644 "$app/Contents/Info.plist" "$app/Contents/Resources/"*
if (( darwin )); then
    xattr -cr "$app" 2>/dev/null || true
fi

# --- 3. the bundle, checked as a whole ------------------------------------------
echo "== The bundle"
"${bundle[@]}" check "$app" --bundle-id "$bundle_id" --version "$version" --build "$build" \
    || fail "the assembled bundle was refused (above): OUTDIR is unchanged"
if (( darwin )); then
    plutil -lint "$app/Contents/Info.plist" >/dev/null || fail "plutil -lint refuses the Info.plist"
    read_id=$(plutil -extract CFBundleIdentifier raw -o - "$app/Contents/Info.plist")
    [[ $read_id == "$bundle_id" ]] || fail "plutil reads the identifier as $read_id, not $bundle_id"
    read_exe=$(plutil -extract CFBundleExecutable raw -o - "$app/Contents/Info.plist")
    [[ -x "$app/Contents/MacOS/$read_exe" ]] || fail "plutil's CFBundleExecutable $read_exe is no executable of the bundle"
    echo "   plutil: the Info.plist is valid; CFBundleIdentifier $read_id, CFBundleExecutable $read_exe"
fi

# --- 4. in place ------------------------------------------------------------------
final="$out/Icy Tower.app"
if [[ -e $final ]]; then
    mv "$final" "$work/previous.app"
fi
mv "$app" "$final"
(cd "$final" && find . -print | LC_ALL=C sort | sed 's/^/   /')
size=$(du -sk "$final" | awk '{print $1}')
echo "bundle: $final (${size} KiB; executable $(wc -c <"$final/Contents/MacOS/icy-tower" | tr -d ' ') bytes)"
