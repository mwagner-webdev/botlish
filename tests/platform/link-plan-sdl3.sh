#!/usr/bin/env bash
# link-plan-sdl3.sh -- static SDL3, linked into an executable by the
# packaged macOS compiler (NATIVE-LINK-PLAN-MILESTONE-1.md, "Static SDL3").
#
#   tests/platform/link-plan-sdl3.sh BOTLISH.app [TCLSH]
#
# On an Apple Silicon Mac with Apple's developer tools, CMake and git:
#
#   1. builds SDL3 from the release the binding profile pins
#      (tools/c-bindgen/profiles/sdl3.tcl: its tag and commit) with CMake, as
#      a static archive and a shared library, arm64, deployment target 11.0
#      -- into $BOTLISH_SDL3_STATIC_PREFIX when that names a directory
#      holding a previous build of the same commit (CI caches it), else into
#      a private directory -- and records the version, the commit, the
#      flags, the SDK, the archive's architecture and checksum;
#   2. reads the Apple frameworks and system libraries the archive needs from
#      SDL3's own build metadata (its pkg-config file's Libs.private, which
#      SDL3's CMake writes from its targets' link interface), and writes an
#      application -- in a directory whose name holds a space and a
#      non-ASCII letter -- whose binding module declares them
#      (`extern c framework`, `extern c library`) beside `extern c library
#      "SDL3" static at "native/macos/libSDL3.a"`, the archive and the shared
#      library both in native/macos/;
#   3. compiles it with BOTLISH.app's compiler (Contents/MacOS/botlish),
#      from another working directory, and checks the executable: Mach-O
#      arm64, the archive the link plan's (BOTLISH_NATIVE_LINK_LOG), no SDL3
#      among its dynamic libraries (otool -L: libSystem and Apple's
#      frameworks only), its value [VERSION, true] (SDL_GetVersion, SDL_Init
#      of no subsystem, SDL_Quit), also under BOTLISH_NATIVE_GC_STRESS=1;
#   4. the collision: `extern c library "SDL3" static` with -L
#      native/macos, where libSDL3.a and libSDL3.dylib both are: the archive;
#      and the control, `extern c library "SDL3"` with the same -L: the
#      dylib, which otool -L shows (Apple's ld prefers it), and the size of
#      both executables;
#   5. that the frameworks are needed: the same program declaring none fails
#      to link (NATIVE LINK, Apple ld's undefined symbols);
#   6. the application moved (its archive with it) and compiled again, from
#      yet another directory: the same value;
#   7. with TCLSH (a tclsh9.0 that runs this checkout's main.tcl), the
#      checkout's compiler, with the system and the rustc linker: the same
#      value and no SDL3 dependency;
#   8. deletes SDL3's sources, its build, the prefix and the application's
#      native/ directory, then runs every static executable again.
#
# Every step prints its evidence; the script fails at the first check that
# does not hold. It never writes into the application bundle, and leaves
# nothing behind but the prefix it was given.
set -euo pipefail

app=$(cd "$1" && pwd)
tclsh=${2:-}
checkout=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
botlish="$app/Contents/MacOS/botlish"
[[ -x $botlish ]] || { echo "no compiler at $botlish" >&2; exit 2; }
[[ $(uname -s) == Darwin && $(uname -m) == arm64 ]] || { echo "this is macOS arm64's acceptance" >&2; exit 2; }
work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-sdl3-static.XXXXXX")
trap 'rm -rf "$work"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
step() { echo; echo "== $*"; }

# --- 1. SDL3, static and shared, from the pinned release ---------------------
profile="$checkout/tools/c-bindgen/profiles/sdl3.tcl"
read -r url tag commit < <(sed -n 's/.*source {url \([^ ]*\) tag \([^ ]*\) commit \([0-9a-f]\{40\}\)}.*/\1 \2 \3/p' "$profile" | head -n 1)
[[ -n ${commit:-} ]] || fail "no pinned SDL3 source in $profile"
version=${tag#release-}
IFS=. read -r major minor patch <<<"$version"
expected_version=$((major * 1000000 + minor * 1000 + patch))
prefix=${BOTLISH_SDL3_STATIC_PREFIX:-$work/prefix}
flags=(-DCMAKE_BUILD_TYPE=Release -DSDL_STATIC=ON -DSDL_SHARED=ON -DSDL_TEST_LIBRARY=OFF -DSDL_TESTS=OFF
  -DSDL_EXAMPLES=OFF -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0)
step "SDL3 $version ($commit), static and shared"
echo "   source: $url, tag $tag"
echo "   macOS $(sw_vers -productVersion), SDK $(xcrun --show-sdk-version), $(cc --version | head -n 1)"
echo "   CMake flags: ${flags[*]}"
if [[ -f $prefix/lib/libSDL3.a && $(cat "$prefix/COMMIT" 2>/dev/null) == "$commit" ]]; then
  echo "   (reusing the build in $prefix)"
else
  rm -rf "$prefix"
  git clone --quiet --depth 1 --branch "$tag" "$url" "$work/SDL"
  got=$(git -C "$work/SDL" rev-parse HEAD)
  [[ $got == "$commit" ]] || fail "tag $tag is commit $got, not the pinned $commit"
  started=$(date +%s)
  cmake -S "$work/SDL" -B "$work/build" -DCMAKE_INSTALL_PREFIX="$prefix" "${flags[@]}" >"$work/cmake.log"
  cmake --build "$work/build" --parallel "$(sysctl -n hw.ncpu)" >"$work/build.log" || { tail -n 40 "$work/build.log"; fail "SDL3 did not build"; }
  cmake --install "$work/build" >"$work/install.log"
  echo "$commit" >"$prefix/COMMIT"
  echo "   built in $(( $(date +%s) - started )) s"
fi
static=$prefix/lib/libSDL3.a
shared=$(cd "$prefix/lib" && ls libSDL3.*.dylib | head -n 1)
[[ -f $static && -n $shared ]] || fail "no libSDL3.a and libSDL3.dylib in $prefix/lib"
echo "   archive: $(lipo -info "$static")"
echo "   archive: $(wc -c <"$static" | tr -d ' ') bytes, sha256 $(shasum -a 256 "$static" | cut -d' ' -f1)"
echo "   shared:  $prefix/lib/$shared"

# --- 2. the dependencies, from SDL3's own metadata ---------------------------
pc="$prefix/lib/pkgconfig/sdl3.pc"
[[ -f $pc ]] || fail "no pkg-config file $pc"
private=$(sed -n 's/^Libs.private: *//p' "$pc")
step "SDL3's static link interface (sdl3.pc Libs.private)"
echo "   $private"
frameworks=()
libraries=()
for word in $private; do
  case $word in
    -Wl,-framework,*) frameworks+=("${word#-Wl,-framework,}") ;;
    -Wl,-weak_framework,*) frameworks+=("${word#-Wl,-weak_framework,}") ;;
    -l*) libraries+=("${word#-l}") ;;
    *) fail "an entry of SDL3's link interface this acceptance does not translate: $word" ;;
  esac
done
(( ${#frameworks[@]} > 0 )) || fail "SDL3's metadata names no framework"
echo "   frameworks: ${frameworks[*]}"
echo "   libraries:  ${libraries[*]:-none}"

# The binding module, its library declared by $1, its dependencies by $2
# (1: declared, 0: not).
binding() {
  echo "import std::ffi::c"
  echo
  echo "$1"
  if [[ $2 == 1 ]]; then
    for f in "${frameworks[@]}"; do echo "extern c framework \"$f\""; done
    for l in "${libraries[@]}"; do echo "extern c library \"$l\""; done
  fi
  cat <<'BOT'

extern c fn get_version named "SDL_GetVersion"() -> std::ffi::c::Int
extern c fn init named "SDL_Init"(flags: std::ffi::c::UInt) -> std::ffi::c::Bool
extern c fn quit named "SDL_Quit"() -> unit
BOT
}
main_bot='import sdl

version = sdl::get_version()
ready = sdl::init(0)
sdl::quit()
[version, ready]
'
application="$work/My Gäme"
mkdir -p "$application/native/macos" "$work/elsewhere" "$work/out"
cp "$static" "$application/native/macos/libSDL3.a"
cp "$prefix/lib/$shared" "$application/native/macos/libSDL3.dylib"
printf '%s' "$main_bot" >"$application/main.bot"
binding 'extern c library "SDL3" static at "native/macos/libSDL3.a"' 1 >"$application/sdl.bot"
want="[$expected_version, true]"

# --- 3. the packaged compiler, from another directory ------------------------
# The executable APPLICATION/main, built by the compiler $1 with ARGS..., moved to OUT/$2.
build() {
  local compiler=$1 name=$2
  shift 2
  rm -f "$work/link.log"
  local started=$(date +%s)
  (cd "$work/elsewhere" && BOTLISH_NATIVE_LINK_LOG="$work/link.log" "$compiler" -warnings off "$@" -emit-native-executable "$application/main.bot" >/dev/null) \
    || fail "build $name"
  echo "   built $name in $(( $(date +%s) - started )) s: $(wc -c <"$application/main" | tr -d ' ') bytes"
  mv "$application/main" "$work/out/$name"
}
# Checks executable OUT/$1: Mach-O arm64, no SDL3 among its libraries, value
# $want, also under GC stress.
check_static() {
  local exe="$work/out/$1"
  file "$exe" | grep -q 'Mach-O 64-bit executable arm64' || fail "$1 is $(file "$exe")"
  local libs
  libs=$(otool -L "$exe" | tail -n +2 | awk '{print $1}')
  if grep -qi sdl <<<"$libs"; then fail "$1 depends on SDL3: $libs"; fi
  while read -r lib; do
    case $lib in /usr/lib/*|/System/Library/*) ;; *) fail "$1 needs $lib, no system library" ;; esac
  done <<<"$libs"
  local got stressed
  got=$(env -i "$exe") || fail "$1 failed"
  [[ $got == "$want" ]] || fail "$1 printed $got, not $want"
  stressed=$(env -i BOTLISH_NATIVE_GC_STRESS=1 "$exe") || fail "$1 failed under GC stress"
  [[ $stressed == "$want" ]] || fail "$1 printed $stressed under GC stress"
  echo "   ran $1: $got (GC stress: $stressed); $(wc -l <<<"$libs" | tr -d ' ') dynamic libraries, none SDL3's"
}
step "Static SDL3 through $botlish"
build "$botlish" static-at
grep '^link plan: ' "$work/link.log" | sed 's/^/   /'
grep -q '^link plan: static SDL3: .*/My Gäme/native/macos/libSDL3.a (declared at "native/macos/libSDL3.a")' "$work/link.log" \
  || fail "the link plan does not name the declared archive"
grep -q '^system linker: ' "$work/link.log" || fail "not linked by the system linker"
grep '^system linker: ' "$work/link.log" | sed 's/^/   /' | cut -c 1-2000
otool -L "$work/out/static-at" | sed 's/^/   /'
check_static static-at

# --- 4. the collision, and the dynamic control ------------------------------
step "libSDL3.a and libSDL3.dylib in one -L directory"
binding 'extern c library "SDL3" static' 1 >"$application/sdl.bot"
build "$botlish" static-searched -L "$application/native/macos"
grep '^link plan: static SDL3' "$work/link.log" | sed 's/^/   /'
check_static static-searched
binding 'extern c library "SDL3"' 1 >"$application/sdl.bot"
build "$botlish" dynamic -L "$application/native/macos"
otool -L "$work/out/dynamic" | sed 's/^/   /'
otool -L "$work/out/dynamic" | grep -q 'libSDL3' || fail "the control (an ordinary declaration) did not link the dylib"
got=$(DYLD_LIBRARY_PATH="$application/native/macos" "$work/out/dynamic") || fail "the dynamic control failed"
[[ $got == "$want" ]] || fail "the dynamic control printed $got"
echo "   the control, an ordinary declaration, links the dylib (Apple ld's choice) and prints $got"
echo "   sizes: static $(wc -c <"$work/out/static-at" | tr -d ' ') bytes, dynamic $(wc -c <"$work/out/dynamic" | tr -d ' ') bytes"

# --- 5. the frameworks are needed --------------------------------------------
step "The archive without its frameworks"
binding 'extern c library "SDL3" static at "native/macos/libSDL3.a"' 0 >"$application/sdl.bot"
if (cd "$work/elsewhere" && "$botlish" -warnings off -emit-native-executable "$application/main.bot") >"$work/no-frameworks.out" 2>&1; then
  fail "linked without SDL3's frameworks"
fi
grep -q 'NATIVE LINK' "$work/no-frameworks.out" || { cat "$work/no-frameworks.out"; fail "no NATIVE LINK"; }
grep -q 'Undefined symbols' "$work/no-frameworks.out" || { cat "$work/no-frameworks.out"; fail "no undefined symbols"; }
echo "   refused (NATIVE LINK): $(grep -c '", referenced from' "$work/no-frameworks.out") undefined symbols, e.g. $(grep -m1 -o '"_[A-Za-z0-9_$]*"' "$work/no-frameworks.out")"
binding 'extern c library "SDL3" static at "native/macos/libSDL3.a"' 1 >"$application/sdl.bot"

# --- 6. moved ----------------------------------------------------------------
step "The application moved, compiled from another directory"
mv "$application" "$work/Möved Gäme"
application="$work/Möved Gäme"
mkdir -p "$work/elsewhere2"
rm -f "$work/link.log"
(cd "$work/elsewhere2" && BOTLISH_NATIVE_LINK_LOG="$work/link.log" "$botlish" -warnings off -emit-native-executable "$application/main.bot" >/dev/null) || fail "build moved"
grep '^link plan: static SDL3' "$work/link.log" | sed 's/^/   /'
mv "$application/main" "$work/out/moved"
check_static moved

# --- 7. the checkout's compiler -----------------------------------------------
if [[ -n $tclsh ]]; then
  step "The checkout's compiler ($checkout), both linkers"
  for linker in system rustc; do
    rm -f "$work/link.log"
    (cd "$work/elsewhere" && BOTLISH_NATIVE_LINKER=$linker "$tclsh" "$checkout/main.tcl" -warnings off -emit-native-executable "$application/main.bot" >/dev/null) \
      || fail "the checkout's $linker link"
    mv "$application/main" "$work/out/checkout-$linker"
    check_static "checkout-$linker"
  done
fi

# --- 8. without SDL3 anywhere ------------------------------------------------
step "SDL3's sources, build and archives deleted"
rm -rf "$work/SDL" "$work/build" "$application/native"
if [[ -z ${BOTLISH_SDL3_STATIC_PREFIX:-} ]]; then rm -rf "$prefix"; fi
for exe in "$work"/out/*; do
  name=$(basename "$exe")
  [[ $name == dynamic ]] && continue
  check_static "$name"
done
if "$work/out/dynamic" >/dev/null 2>&1; then fail "the dynamic control ran without its dylib"; fi
echo "   (the dynamic control no longer starts: it needs libSDL3's dylib)"
echo
echo "static SDL3 $version: ok"
