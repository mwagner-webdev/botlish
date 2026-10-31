#!/usr/bin/env bash
# sdl3-static-macos.sh -- the pinned SDL3, static, for macOS arm64: the one
# recipe the static-SDL3 acceptance (tests/platform/link-plan-sdl3.sh,
# NATIVE-LINK-PLAN-MILESTONE-1.md) and the macOS Icy Tower build
# (examples/games/icy-tower/build-macos.sh, ICY-TOWER-MACOS-MILESTONE-1.md)
# both use.
#
#   tests/platform/sdl3-static-macos.sh build PREFIX
#       builds SDL3 from the release the binding profile pins
#       (tools/c-bindgen/profiles/sdl3.tcl: its tag and commit, the commit
#       verified after the clone) with CMake, as a static archive and a
#       shared library, arm64, deployment target 11.0, and installs it into
#       PREFIX -- unless PREFIX already holds a build of the same commit
#       (PREFIX/COMMIT; CI caches the prefix) -- then prints the evidence:
#       the version, the commit, the flags, the SDK, the archive's
#       architecture, size and SHA-256
#   tests/platform/sdl3-static-macos.sh link-interface PREFIX
#       prints the Apple frameworks and system libraries the archive needs,
#       one "framework NAME" or "library NAME" line each, in first-mention
#       order, read from SDL3's own build metadata: the installed sdl3.pc's
#       Libs.private, which SDL3's CMake writes from its targets' link
#       interface. -Wl,-framework,X and -Wl,-weak_framework,X (and the
#       two-word spellings) are frameworks -- a weak one is linked strongly,
#       Botlish has no weak form (NATIVE-LINK-PLAN-MILESTONE-1.md, section
#       23) -- and -lNAME a library; -pthread is libSystem's. Any other entry
#       is an error: never guessed.
#
# Needs Apple's developer tools, CMake and git (build); nothing (link-
# interface). Fails at the first check that does not hold; leaves nothing
# behind but PREFIX.
set -euo pipefail

mode=${1:-}
prefix=${2:-}
[[ ($mode == build || $mode == link-interface) && -n $prefix ]] || {
  echo "usage: $0 build|link-interface PREFIX" >&2
  exit 2
}
checkout=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
fail() { echo "FAIL: $*" >&2; exit 1; }

if [[ $mode == link-interface ]]; then
  pc="$prefix/lib/pkgconfig/sdl3.pc"
  [[ -f $pc ]] || fail "no pkg-config file $pc"
  private=$(sed -n 's/^Libs.private: *//p' "$pc")
  seen=" "
  emit() {
    case $seen in *" $1:$2 "*) ;; *) seen="$seen$1:$2 "; echo "$1 $2" ;; esac
  }
  next=""
  for word in $private; do
    if [[ -n $next ]]; then emit framework "$word"; next=""; continue; fi
    case $word in
      -Wl,-framework,*) emit framework "${word#-Wl,-framework,}" ;;
      -Wl,-weak_framework,*) emit framework "${word#-Wl,-weak_framework,}" ;;
      -framework|-weak_framework) next=1 ;;
      -l*) emit library "${word#-l}" ;;
      -pthread) ;;  # libSystem's on macOS: nothing to link
      *) fail "an entry of SDL3's link interface no rule translates: $word" ;;
    esac
  done
  exit 0
fi

[[ $(uname -s) == Darwin && $(uname -m) == arm64 ]] || fail "this builds SDL3 for macOS arm64, on macOS arm64"
profile="$checkout/tools/c-bindgen/profiles/sdl3.tcl"
read -r url tag commit < <(sed -n 's/.*source {url \([^ ]*\) tag \([^ ]*\) commit \([0-9a-f]\{40\}\)}.*/\1 \2 \3/p' "$profile" | head -n 1)
[[ -n ${commit:-} ]] || fail "no pinned SDL3 source in $profile"
version=${tag#release-}
flags=(-DCMAKE_BUILD_TYPE=Release -DSDL_STATIC=ON -DSDL_SHARED=ON -DSDL_TEST_LIBRARY=OFF -DSDL_TESTS=OFF
  -DSDL_EXAMPLES=OFF -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0)
echo "   source: $url, tag $tag"
echo "   macOS $(sw_vers -productVersion), SDK $(xcrun --show-sdk-version), $(cc --version | head -n 1)"
echo "   CMake flags: ${flags[*]}"
if [[ -f $prefix/lib/libSDL3.a && $(cat "$prefix/COMMIT" 2>/dev/null) == "$commit" ]]; then
  echo "   (reusing the build in $prefix)"
else
  work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-sdl3-build.XXXXXX")
  trap 'rm -rf "$work"' EXIT
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
[[ -f $static ]] || fail "no libSDL3.a in $prefix/lib"
[[ -f $prefix/lib/pkgconfig/sdl3.pc ]] || fail "no sdl3.pc in $prefix/lib/pkgconfig"
echo "   SDL3 $version ($commit)"
echo "   archive: $(lipo -info "$static")"
echo "   archive: $(wc -c <"$static" | tr -d ' ') bytes, sha256 $(shasum -a 256 "$static" | cut -d' ' -f1)"
