#!/usr/bin/env bash
# build-android.sh -- the Icy Tower APK for Android (arm64-v8a)
# (ICY-TOWER-ANDROID.md): the game built as an application library for
# android-aarch64 and wrapped in an SDLActivity project by integrations/
# android's tool, as RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md
# builds the 2048 application.
#
#   examples/games/icy-tower/build-android.sh OUTDIR
#
# Steps (each writes under OUTDIR):
#
#   1. The packages, as their authors pack them -> OUTDIR/repo:
#      botlish_target_android_aarch64 (audit/android-aarch64-target/tools/
#      package.sh: Botlish's runtime built for aarch64-linux-android), sdl3
#      (its android-aarch64 view: the committed generated binding,
#      libSDL3.so and SDL's Java classes) and android_io
#      (tools/package-repository.tcl), botlish_android (integrations/
#      android/package.sh). PACKAGES, when set, names a directory already
#      holding them (audit/android-sdl3-2048/tools/build.sh's OUT/repo).
#   2. The project -> OUTDIR/project: the game's modules (the shared ones,
#      touch.bot, touchpad.bot and the entry main-android.bot), the
#      packages installed for android-aarch64, main-android.bot compiled
#      under -warnings error as the application library icytower.
#   3. The Android project -> OUTDIR/android (made afresh): `botlish tool
#      ... android generate`, then `android build` (Gradle) ->
#      OUTDIR/icy-tower.apk,
#      signed with the debug key (a sideloadable build, not a store
#      release).
#
# Environment: ANDROID_NDK_ROOT (NDK r29), ANDROID_HOME (the SDK: platform
# 35, build tools 35, CMake 3.22.1), Java 17+, and for step 1 cmake, ninja,
# clang and the arm64 GNU cross C library (sdl3's linux-aarch64 thunks).
# BOTLISH (default: tclsh9.0 main.tcl of this checkout) is the compiler
# command.
set -euo pipefail
out=$(realpath -m "${1:?usage: build-android.sh OUTDIR}")
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
read -r -a botlish <<<"${BOTLISH:-tclsh9.0 $root/main.tcl}"
export LANG=C.utf8 LC_ALL=C.utf8
: "${ANDROID_NDK_ROOT:?set ANDROID_NDK_ROOT to the Android NDK (r29)}"
: "${ANDROID_HOME:?set ANDROID_HOME to the Android SDK}"
step() { printf '\n== %s\n' "$*"; }

step "1. packages"
mkdir -p "$out/repo"
if [[ -n ${PACKAGES:-} ]]; then
    cp "$PACKAGES"/*.botpkg "$out/repo/"
else
    "$root/audit/android-aarch64-target/tools/package.sh" "$out/android-packages" "${botlish[@]}"
    cp "$out/android-packages/repo"/botlish_target_android_aarch64-*.botpkg "$out/repo/"
    rm -rf "$out/official"
    tclsh9.0 "$root/tools/package-repository.tcl" -force "$out/official" sdl3 android_io
    cp "$out/official"/*.botpkg "$out/repo/"
    "$root/integrations/android/package.sh" "$out/tool" "${botlish[@]}"
    cp "$out/tool/repo"/*.botpkg "$out/repo/"
fi
ls -l "$out/repo"

step "2. the project"
project="$out/project"
rm -rf "$project"
mkdir -p "$project"
printf '{"schema": 1, "dependencies": {}}\n' >"$project/botlish.json"
for module in tower hud options controls keyboard touchpad touch sdl render game main-android; do
    cp "$here/$module.bot" "$project/"
done
for package in sdl3 android_io botlish_target_android_aarch64; do
    (cd "$project" && "${botlish[@]}" add "$package" -repository "$out/repo" -target android-aarch64)
done
(cd "$project" && "${botlish[@]}" add botlish_android -repository "$out/repo")
(cd "$project" && "${botlish[@]}" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
    -emit-native-library icytower -application -out lib main-android.bot)

step "3. the APK"
rm -rf "${out:?}/android"
(cd "$project" && "${botlish[@]}" tool -out "$out/android" -artifact lib/icytower.manifest.json \
    -target android-aarch64 -report "$out/tool-report.json" \
    android generate -application-id org.botlish.icytower -name "Icy Tower" -version-name 1.0)
(cd "$project" && "${botlish[@]}" tool -out "$out/android" -artifact lib/icytower.manifest.json \
    -target android-aarch64 android build)
rm -f "$out/icy-tower.apk"
cp "$out/android/app/build/outputs/apk/release/app-release.apk" "$out/icy-tower.apk"
ls -l "$out/icy-tower.apk"
