#!/usr/bin/env bash
# build.sh -- RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md end to end,
# from a checkout to Android APKs: what the CI's build job runs, and what a
# local run reproduces.
#
#   audit/android-sdl3-2048/tools/build.sh OUT
#
# Steps (each writes under OUT):
#
#   1. the packages, as their authors pack them -> OUT/repo:
#        botlish_target_android_aarch64, game2048, game2048_play
#          (audit/android-aarch64-target/tools/package.sh)
#        sdl3 (its android-aarch64 view), android_io, sdlscreen
#          (tools/package-repository.tcl: the repository's own recipes)
#        botlish_android (integrations/android/package.sh)
#      PACKAGES, when set, names a directory already holding them all.
#   2. the applications, each an ordinary Botlish project with its packages
#      installed as dependencies for android-aarch64, its entry program
#      built as an application library, then the tool run explicitly
#      (`botlish tool ... android generate`) and its project built
#      (`botlish tool ... android build`):
#        counter (examples/android-sdl3/counter: no game, its own names)
#        game    (examples/android-sdl3/2048: the 2048 application)
#        game-test (the same library, generated -intent-arguments: the
#                   acceptance's test configuration)
#      -> OUT/projects/NAME, OUT/android/NAME, OUT/NAME.apk
#   3. what each APK holds (inspect-apk.sh) -> OUT/NAME-apk.txt
#   4. the interpreter's oracles of the acceptance's games -> OUT/oracle-*.txt
#
# Environment: ANDROID_NDK_ROOT (NDK r29), ANDROID_HOME (the SDK: platform
# 35, build tools 35, CMake 3.22.1), Java 17+, cmake, ninja, clang, the arm64
# GNU cross C library (sdl3's linux-aarch64 thunks). BOTLISH (default:
# tclsh9.0 main.tcl of this checkout) is the compiler command.
set -euo pipefail
out=$(realpath -m "${1:?usage: build.sh OUT}")
here=$(cd "$(dirname "$0")" && pwd)
audit=$(dirname "$here")
root=$(cd "$audit/../.." && pwd)
read -r -a botlish <<<"${BOTLISH:-tclsh9.0 $root/main.tcl}"
export LANG=C.utf8 LC_ALL=C.utf8
: "${ANDROID_NDK_ROOT:?set ANDROID_NDK_ROOT to the Android NDK (r29)}"
: "${ANDROID_HOME:?set ANDROID_HOME to the Android SDK}"
mkdir -p "$out/repo"
step() { printf '\n== %s\n' "$*"; }

step "1. packages"
if [[ -n ${PACKAGES:-} ]]; then
    cp "$PACKAGES"/*.botpkg "$out/repo/"
else
    "$root/audit/android-aarch64-target/tools/package.sh" "$out/android-packages" "${botlish[@]}"
    cp "$out/android-packages/repo"/*.botpkg "$out/repo/"
    rm -rf "$out/official"
    tclsh9.0 "$root/tools/package-repository.tcl" -force "$out/official" sdl3 android_io sdlscreen
    cp "$out/official"/*.botpkg "$out/repo/"
    "$root/integrations/android/package.sh" "$out/tool" "${botlish[@]}"
    cp "$out/tool/repo"/*.botpkg "$out/repo/"
fi
ls -l "$out/repo"
(cd "$out/repo" && sha256sum ./*.botpkg) >"$out/packages.txt"

step "2. the applications"
# app NAME SOURCE-DIR LIBRARY APPLICATION-ID DISPLAY-NAME [GENERATE-OPTION...]
# The project's packages: the application's own (sdlscreen and android_io,
# and for the game game2048_play), the target support package and the
# tool. The library is built from SOURCE-DIR/main.bot.
app() {
    local name=$1 source=$2 library=$3 id=$4 display=$5
    shift 5
    local dir="$out/projects/$name"
    rm -rf "$dir"
    mkdir -p "$dir"
    printf '{"schema": 1, "dependencies": {}}\n' >"$dir/botlish.json"
    find "$source" -maxdepth 1 -name '*.bot' ! -name 'main-linux.bot' -exec cp {} "$dir/" \;
    local packages=(sdlscreen android_io)
    [[ $name == game* ]] && packages+=(game2048_play)
    for package in "${packages[@]}" botlish_target_android_aarch64; do
        (cd "$dir" && "${botlish[@]}" add "$package" -repository "$out/repo" -target android-aarch64)
    done
    (cd "$dir" && "${botlish[@]}" add botlish_android -repository "$out/repo")
    (cd "$dir" && "${botlish[@]}" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
        -emit-native-library "$library" -application -out lib main.bot)
    (cd "$dir" && "${botlish[@]}" tools)
    (cd "$dir" && "${botlish[@]}" tool -out "$out/android/$name" -artifact "lib/$library.manifest.json" \
        -target android-aarch64 -report "$out/tool-report-$name.json" \
        android generate -application-id "$id" -name "$display" -replace "$@")
    (cd "$dir" && "${botlish[@]}" tool -out "$out/android/$name" -artifact "lib/$library.manifest.json" \
        -target android-aarch64 android build)
    cp "$out/android/$name/app/build/outputs/apk/release/app-release.apk" "$out/$name.apk"
}
app counter "$root/examples/android-sdl3/counter" counter org.botlish.counter "Botlish Counter"
if [[ -f $root/examples/android-sdl3/2048/main.bot ]]; then
    app game "$root/examples/android-sdl3/2048" game org.botlish.sdl2048 "Botlish 2048"
    app game-test "$root/examples/android-sdl3/2048" game org.botlish.sdl2048.test "Botlish 2048 (test)" -intent-arguments
fi
# The generated projects are deterministic: generating again gives the same
# files, byte for byte.
(cd "$out/projects/counter" && "${botlish[@]}" tool -out "$out/regenerated-counter" \
    -artifact lib/counter.manifest.json -target android-aarch64 \
    android generate -application-id org.botlish.counter -name "Botlish Counter")
python3 -I - "$out/android/counter" "$out/regenerated-counter" <<'PY'
import hashlib, json, sys
a, b = sys.argv[1], sys.argv[2]
files = json.load(open(a + "/botlish-android.json"))["files"] + ["botlish-android.json"]
assert files == json.load(open(b + "/botlish-android.json"))["files"] + ["botlish-android.json"], "file lists differ"
for f in files:
    x = hashlib.sha256(open(a + "/" + f, "rb").read()).hexdigest()
    y = hashlib.sha256(open(b + "/" + f, "rb").read()).hexdigest()
    assert x == y, f + " differs"
print("regeneration: identical (%d files)" % len(files))
PY

step "3. the APKs"
for name in counter game game-test; do
    [[ -f $out/$name.apk ]] || continue
    library=$( [[ $name == counter ]] && echo counter || echo game )
    "$here/inspect-apk.sh" "$out/$name.apk" "$out/projects/$name/lib/$library.manifest.json" \
        "$out/projects/$name/.bot_modules/.targets/android-aarch64/sdl3/android/sdl3-android.json" | tee "$out/$name-apk.txt"
done

step "4. the oracles"
if [[ -f $root/examples/android-sdl3/2048/main.bot ]]; then
    "$here/oracles.sh" "$out"
fi
