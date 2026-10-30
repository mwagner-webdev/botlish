#!/usr/bin/env bash
# build-macos.sh -- builds the Icy Tower vertical slice's macOS AArch64
# executable (ICY-TOWER-MACOS-MILESTONE-1.md) on an Apple Silicon Mac, from
# a clean checkout:
#
#   examples/games/icy-tower/build-macos.sh [OUTDIR]
#
# OUTDIR (default icy-tower-macos/ in the current directory) receives
# icy-tower: one Mach-O arm64 executable with SDL3 linked into it, which
# needs nothing but macOS's own libraries and frameworks to run -- no SDL3,
# no Botlish, no Tcl, no Rust. Steps:
#
#   1. Static SDL3: the release the binding profile pins (3.4.18), built
#      once by tests/platform/sdl3-static-macos.sh into ICY_TOWER_SDL3_PREFIX
#      (default: $BOTLISH_SDL3_STATIC_PREFIX, else
#      ~/Library/Caches/botlish-sdl3-static, the CI's cache), unless that
#      prefix already holds the pinned commit's build. Its libSDL3.a must
#      be an archive of Mach-O arm64 objects (ICY_TOWER_SDL3_ARCHIVE stages
#      another archive instead: the SDL call trace's probe build).
#   2. The dependencies: macos_link.bot declares the archive (`static at
#      "native/macos/libSDL3.a"`) and the frameworks and libraries SDL3's
#      sdl3.pc names; this step refuses to build when the file's list is not
#      exactly SDL3's own (sdl3-static-macos.sh link-interface).
#   3. The SDL3 binding of macos-aarch64: tools/c-bindgen.tcl generates it
#      from the same pinned headers with the macOS SDK's clang. None is
#      committed (it needs the SDK, which only a Mac has), so the build
#      generates it, into ICY_TOWER_BINDING when that is set (kept), else a
#      temporary directory; ICY_TOWER_BINDING_FROM names one generated
#      before (DIR/macos-aarch64/sdl3) to stage instead.
#   4. The application: the .bot files beside this script staged into one
#      application root with that binding installed as its package sdl3
#      (tools/c-bindgen.tcl stage -dir -package 1; BOT-MODULES-MILESTONE-1.md)
#      and the archive at native/macos/libSDL3.a inside it -- in
#      ICY_TOWER_STAGE when that is set (kept, so it can be moved and built
#      again), else a temporary directory.
#   5. The executable: main-macos.bot compiled under -warnings error with
#      -native-startup main-thread (Cocoa needs SDL's video on the process's
#      main thread: MAIN-THREAD-STARTUP-MILESTONE-1.md) by ICY_TOWER_BOTLISH
#      -- Botlish.app, or its Contents/MacOS/botlish -- else by this
#      checkout's main.tcl; linked by the system linker with the link plan
#      (BOTLISH_NATIVE_LINK_LOG is kept as OUTDIR/link.log). The build checks
#      the result -- Mach-O arm64, LC_MAIN's 512 MiB stack, no SDL3 and
#      nothing but /usr/lib and /System/Library among its dynamic libraries
#      -- and only then replaces OUTDIR/icy-tower: a failed build leaves a
#      previous one as it was.
#
# Steps 1 and 3 are the preparation and need this checkout, tclsh9.0,
# Apple's developer tools (clang, the SDK), git and CMake; step 5 with
# Botlish.app needs only the application and Apple's linker (no Rust, no
# checkout, no Tcl of the system's).
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
out=${1:-icy-tower-macos}
fail() { echo "build-macos.sh: $*" >&2; exit 1; }
seconds() { python3 -c 'import time; print("%.3f" % time.time())'; }
since() { python3 -c "import sys; print('%.1f' % (float(sys.argv[2]) - float(sys.argv[1])))" "$1" "$(seconds)"; }

[[ $(uname -s) == Darwin && $(uname -m) == arm64 ]] || fail "this builds the macOS AArch64 executable, on an Apple Silicon Mac"

# The compiler: Botlish.app's botlish, or the checkout's main.tcl.
botlish=()
if [[ -n ${ICY_TOWER_BOTLISH:-} ]]; then
    compiler=$ICY_TOWER_BOTLISH
    [[ -d $compiler && -x $compiler/Contents/MacOS/botlish ]] && compiler=$compiler/Contents/MacOS/botlish
    [[ -x $compiler ]] || fail "no compiler at $ICY_TOWER_BOTLISH"
    botlish=("$compiler")
else
    botlish=(tclsh9.0 "$root/main.tcl")
fi

work=$(mktemp -d "${TMPDIR:-/tmp}/icy-tower-macos.XXXXXX")
trap 'rm -rf "$work"' EXIT

# --- 1. static SDL3 -----------------------------------------------------------
prefix=${ICY_TOWER_SDL3_PREFIX:-${BOTLISH_SDL3_STATIC_PREFIX:-$HOME/Library/Caches/botlish-sdl3-static}}
echo "== SDL3, static ($prefix)"
t=$(seconds)
bash "$root/tests/platform/sdl3-static-macos.sh" build "$prefix" || fail "SDL3 did not build"
echo "   time: $(since "$t") s"
archive=${ICY_TOWER_SDL3_ARCHIVE:-$prefix/lib/libSDL3.a}
[[ -f $archive ]] || fail "no static archive $archive"
[[ $(lipo -archs "$archive" 2>/dev/null) == arm64 ]] || fail "$archive is not an arm64 archive ($(lipo -info "$archive" 2>&1))"
kind=$(file -b "$archive")
[[ $kind == *"ar archive"* ]] || fail "$archive is $kind, not a static archive"
echo "   staged archive: $archive"

# --- 2. the dependencies: macos_link.bot against SDL3's own metadata --------------
echo "== Native dependencies (macos_link.bot against sdl3.pc)"
bash "$root/tests/platform/sdl3-static-macos.sh" link-interface "$prefix" >"$work/interface.txt" \
    || fail "SDL3's link interface"
sed -n 's/^extern c framework "\([^"]*\)".*/framework \1/p; s/^extern c library "\([^"]*\)"$/library \1/p' \
    "$here/macos_link.bot" >"$work/declared.txt"
if ! diff -u "$work/interface.txt" "$work/declared.txt" >"$work/interface.diff"; then
    cat "$work/interface.diff" >&2
    fail "macos_link.bot does not declare exactly the frameworks and libraries SDL3's sdl3.pc names (the diff above: - is SDL3's, + the file's)"
fi
grep -qx 'extern c library "SDL3" static at "native/macos/libSDL3.a"' "$here/macos_link.bot" \
    || fail "macos_link.bot does not declare the staged archive native/macos/libSDL3.a"
echo "   $(grep -c '^framework' "$work/interface.txt") frameworks, $(grep -c '^library' "$work/interface.txt") libraries: as SDL3's sdl3.pc"

# --- 3. the macos-aarch64 SDL3 binding --------------------------------------------
if [[ -n ${ICY_TOWER_BINDING_FROM:-} ]]; then
    binding=$ICY_TOWER_BINDING_FROM
    [[ -d $binding/macos-aarch64/sdl3 ]] || fail "no generated binding in $binding/macos-aarch64"
    echo "== SDL3 binding: generated before, in $binding/macos-aarch64"
else
    binding=${ICY_TOWER_BINDING:-$work/binding}
    mkdir -p "$binding"
    binding=$(cd "$binding" && pwd)
    echo "== SDL3 binding (tools/c-bindgen.tcl generate sdl3 -target macos-aarch64)"
    t=$(seconds)
    tclsh9.0 "$root/tools/c-bindgen.tcl" fetch sdl3 >/dev/null
    tclsh9.0 "$root/tools/c-bindgen.tcl" generate sdl3 -target macos-aarch64 -out "$binding"
    echo "   time: $(since "$t") s"
fi
grep -qx 'target macos-aarch64' "$binding/macos-aarch64/manifest.txt" || fail "$binding/macos-aarch64 is not a macos-aarch64 binding"

# --- 4. the application root -----------------------------------------------------------
# A kept stage is replaced only when it is one this script made (its marker
# file): never a directory of someone's own, the game's sources least of all.
app=${ICY_TOWER_STAGE:-$work/app}
if [[ -e $app ]]; then
    [[ -f $app/.icy-tower-stage ]] || fail "$app exists and is no stage of this script's: not replacing it"
    rm -rf "$app"
fi
mkdir -p "$(dirname "$app")"
tclsh9.0 "$root/tools/c-bindgen.tcl" stage sdl3 -target macos-aarch64 -dir "$binding/macos-aarch64" \
    -app "$here" -into "$app" -package 1 >/dev/null
app=$(cd "$app" && pwd)
: >"$app/.icy-tower-stage"
mkdir -p "$app/native/macos"
cp "$archive" "$app/native/macos/libSDL3.a"
echo "== Application root: $app"

# --- 5. the executable ------------------------------------------------------------------
echo "== Compile and link: ${botlish[*]} -warnings error -native-startup main-thread -emit-native-executable main-macos.bot"
mkdir -p "$out"
out=$(cd "$out" && pwd)
rm -f "$work/link.log"
t=$(seconds)
(cd "$work" && BOTLISH_NATIVE_LINK_LOG="$work/link.log" "${botlish[@]}" -warnings error -native-startup main-thread \
    -emit-native-executable "$app/main-macos.bot") || fail "the compilation failed (OUTDIR is unchanged)"
echo "   time: $(since "$t") s"
exe=$app/main-macos
[[ -x $exe ]] || fail "no executable $exe"
grep '^link plan: ' "$work/link.log" | sed 's/^/   /'
grep -q '^link plan: static SDL3: .*/native/macos/libSDL3.a (declared at "native/macos/libSDL3.a")' "$work/link.log" \
    || fail "the link plan does not name the staged archive"
# (Each tool's output is read whole before it is searched: grep -q ending a
# pipeline early would fail it under pipefail.)
kind=$(file -b "$exe")
[[ $kind == *"Mach-O 64-bit executable arm64"* ]] || fail "$exe is $kind"
loads=$(otool -l "$exe")
[[ $(grep -A4 'cmd LC_MAIN' <<<"$loads") == *"stacksize 536870912"* ]] || fail "$exe has no 512 MiB LC_MAIN stack: not a main-thread executable"
libs=$(otool -L "$exe" | tail -n +2 | awk '{print $1}')
if grep -qi sdl <<<"$libs"; then fail "$exe depends on a dynamic SDL3: $libs"; fi
while read -r lib; do
    case $lib in /usr/lib/*|/System/Library/*) ;; *) fail "$exe needs $lib, no system library" ;; esac
done <<<"$libs"
cp "$exe" "$out/icy-tower.new"
mv -f "$out/icy-tower.new" "$out/icy-tower"
cp "$work/link.log" "$out/link.log"
echo "executable: $out/icy-tower ($(wc -c <"$out/icy-tower" | tr -d ' ') bytes; $(wc -l <<<"$libs" | tr -d ' ') dynamic libraries, all the system's)"
