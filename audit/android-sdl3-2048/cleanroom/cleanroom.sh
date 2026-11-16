#!/usr/bin/env bash
# cleanroom.sh -- the clean room of RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-
# MILESTONE-1.md ("Cleanroom reproduction"): the distributed single-file
# compiler and published packages only, from Botlish source to an APK.
#
#   audit/android-sdl3-2048/cleanroom/cleanroom.sh BOTLISH REPO RESULTS
#
# BOTLISH is the single-file compiler (single/build.sh), REPO a directory of
# published .botpkg artifacts: botlish_target_android_aarch64, game2048 and
# game2048_play (audit/android-aarch64-target/tools/package.sh), sdl3,
# android_io and sdlscreen (tools/package-repository.tcl) and botlish_android
# (integrations/android/package.sh), packed for the native build BOTLISH was
# built from. The room is a fresh directory holding a copy of BOTLISH, the
# artifacts and the application's own Botlish source
# (examples/android-sdl3/2048, its Linux entry left out) -- nothing of this
# checkout besides.
#
#   1. Botlish (traced): the packages installed as ordinary dependencies for
#      android-aarch64, the entry program built as an application library,
#      its manifest checked against its files, the tool run explicitly to
#      generate the Gradle project -- by the single executable, with an
#      empty environment (HOME, TMPDIR and the caches in the room; PATH the
#      system's; ANDROID_NDK_ROOT, ANDROID_HOME). Under strace every file
#      opened and program started is recorded, and the run fails if any is
#      in this checkout or is a Tcl of the system.
#   2. Gradle: the tool's `android build` (the generated project's wrapper,
#      the Android Gradle plugin from Google's Maven: network allowed, they
#      are the project's, not Botlish's; Java and the Android SDK are the
#      environment's, JAVA_HOME and ANDROID_HOME). The generated project
#      must name nothing of this checkout.
#   3. The APK: inspect-apk.sh's facts (arm64-v8a only; libSDL3.so the sdl3
#      package's, the application library the build's, both 16 KiB-aligned
#      and stored for mapping; SDL's Activity), read from its bytes.
#   4. The acceptance's configuration of the same library: generated again
#      with -intent-arguments (another application ID), built, inspected
#      -> RESULTS/game-test.apk.
#
# RESULTS gets each step's output, the trace, the APKs (app-release.apk,
# game-test.apk) and summary.txt; exit status 0 only when every check
# passed. Running the APK on Android is the acceptance's
# (audit/android-sdl3-2048/tools/acceptance-2048.sh RESULTS/..
# RESULTS/game-test.apk; the CI's emulator jobs run it).
set -euo pipefail
if [[ $# -ne 3 ]]; then
    echo "usage: cleanroom.sh BOTLISH REPO RESULTS" >&2
    exit 2
fi
botlish=$(realpath "$1")
repo=$(realpath "$2")
results=$(realpath -m "$3")
here=$(cd "$(dirname "$0")" && pwd)
checkout=$(cd "$here/../../.." && pwd)
: "${ANDROID_NDK_ROOT:?set ANDROID_NDK_ROOT (the NDK the target support package links with)}"
: "${ANDROID_HOME:?set ANDROID_HOME (the Android SDK of the Gradle build)}"
: "${JAVA_HOME:?set JAVA_HOME (the Gradle build)}"
room=$(mktemp -d /tmp/botlish-sdl3-cleanroom.XXXXXX)
mkdir -p "$results" "$room/bin" "$room/home" "$room/tmp" "$room/repo" "$room/project" "$room/out"
cp "$botlish" "$room/bin/botlish"
cp "$repo"/*.botpkg "$room/repo/"
for f in "$checkout"/examples/android-sdl3/2048/*.bot; do
    [[ $(basename "$f") == main-linux.bot ]] || cp "$f" "$room/project/"
done
summary="$results/summary.txt"
: >"$summary"
status=0
note() { echo "$*" | tee -a "$summary"; }
check() { # NAME COMMAND...
    local name=$1
    shift
    if "$@" >>"$results/checks.txt" 2>&1; then note "ok $name"; else note "FAIL $name"; status=1; fi
}
note "room $room"
note "botlish $(sha256sum "$botlish" | cut -d' ' -f1)"
for f in "$room"/repo/*.botpkg; do note "package $(basename "$f") $(sha256sum "$f" | cut -d' ' -f1)"; done
note "sources $(cd "$room/project" && ls | tr '\n' ' ')"

# ------------------------------------------------------------- 1. Botlish
cat >"$room/botlish-steps.sh" <<'EOF'
set -eu
cd project
printf '{"schema": 1, "dependencies": {}}\n' >botlish.json
for package in sdlscreen android_io game2048 game2048_play botlish_target_android_aarch64; do
    ../bin/botlish add "$package" -repository ../repo -target android-aarch64
done
../bin/botlish add botlish_android -repository ../repo
../bin/botlish tools
../bin/botlish -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
    -emit-native-library game -application -out lib main.bot
# The manifest binds its files: each SHA-256 as it records it.
for pair in static:libgame.a shared:libgame.so header:game.h; do
    key=${pair%%:*} file=${pair#*:}
    recorded=$(tr -d '\n ' <lib/game.manifest.json | sed -n "s/.*\"sha256\":{[^}]*\"$key\":\"\([0-9a-f]*\)\".*/\1/p")
    actual=$(sha256sum "lib/$file" | cut -d' ' -f1)
    [ "$recorded" = "$actual" ] || { echo "manifest: $file is not the file it describes"; exit 1; }
    echo "manifest: $file $actual"
done
grep -q '"application"' lib/game.manifest.json && echo "manifest: an application library (schema 3)"
../bin/botlish tool -out ../out/android -artifact lib/game.manifest.json -target android-aarch64 \
    -report ../out/tool-report.json android generate -application-id org.botlish.sdl2048 -name "Botlish 2048"
EOF
env_cmd=(env -i "HOME=$room/home" "PATH=/usr/bin:/bin" "LANG=C.UTF-8" "TMPDIR=$room/tmp"
    "ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT" "ANDROID_HOME=$ANDROID_HOME")
if command -v strace >/dev/null 2>&1; then
    (cd "$room" && "${env_cmd[@]}" strace -f -qq -e trace=execve,open,openat,stat,newfstatat,access \
        -o "$results/trace.txt" /bin/sh botlish-steps.sh) >"$results/botlish.txt" 2>&1 || { note "FAIL botlish steps"; status=1; }
    if grep -F "$checkout" "$results/trace.txt" | grep -v ENOENT >"$results/checkout-access.txt"; then
        note "FAIL the Botlish steps touched this checkout ($(wc -l <"$results/checkout-access.txt") lines)"
        status=1
    else
        note "ok the Botlish steps touched nothing of this checkout"
    fi
    if grep -E '(/usr/(local/)?(lib|share)/(x86_64-linux-gnu/)?tcl[0-9]|/usr/share/tcltk|execve\("[^"]*tclsh)' "$results/trace.txt" \
        | grep -v ENOENT >"$results/system-tcl.txt"; then
        note "FAIL the Botlish steps used a Tcl of the system"
        status=1
    else
        note "ok no Tcl of the system: the compiler is the single file"
    fi
    # Installing and importing packages runs nothing of theirs: the only
    # programs a step starts are the single executable's own, the shell's,
    # the NDK's toolchain (the library's link) and the tool, which the
    # explicit `botlish tool` runs.
    grep -o 'execve("[^"]*"' "$results/trace.txt" | sort | uniq -c | sort -rn >"$results/programs.txt"
else
    (cd "$room" && "${env_cmd[@]}" /bin/sh botlish-steps.sh) >"$results/botlish.txt" 2>&1 || { note "FAIL botlish steps"; status=1; }
    note "note strace is not installed: nothing traced"
fi
grep -E "^(manifest:|android:)" "$results/botlish.txt" | sed 's/^/  /' | tee -a "$summary"
project="$room/out/android"
check "the tool wrote the project" test -f "$project/botlish-android.json"
[[ $status == 0 ]] || { note "result: FAILED"; exit 1; }

# -------------------------------------------------------------- 2. Gradle
gradle_env=(env -i "HOME=$room/home" "PATH=$JAVA_HOME/bin:/usr/bin:/bin" "LANG=C.UTF-8" "TMPDIR=$room/tmp"
    "JAVA_HOME=$JAVA_HOME" "ANDROID_HOME=$ANDROID_HOME" "ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT"
    "GRADLE_USER_HOME=$room/home/.gradle")
# A proxy the environment needs to reach Google's Maven and Gradle's
# distribution (never a Botlish input): its variables pass, and a Gradle
# properties file given as GRADLE_PROPERTIES is the room's.
for name in HTTPS_PROXY https_proxy HTTP_PROXY http_proxy NO_PROXY no_proxy SSL_CERT_FILE JAVA_TOOL_OPTIONS; do
    [[ -n ${!name:-} ]] && gradle_env+=("$name=${!name}")
done
if [[ -n ${GRADLE_PROPERTIES:-} ]]; then
    mkdir -p "$room/home/.gradle" && cp "$GRADLE_PROPERTIES" "$room/home/.gradle/gradle.properties"
    [[ -d ${GRADLE_INIT_DIR:-/nonexistent} ]] && cp -r "$GRADLE_INIT_DIR" "$room/home/.gradle/init.d"
fi
(cd "$room/project" && "${gradle_env[@]}" ../bin/botlish tool -out ../out/android -artifact lib/game.manifest.json \
    -target android-aarch64 android build) >"$results/gradle.txt" 2>&1 &&
    note "ok the tool's Gradle build ($(grep -o 'BUILD SUCCESSFUL in .*' "$results/gradle.txt" | tail -1))" ||
    { note "FAIL the tool's Gradle build"; tail -30 "$results/gradle.txt"; status=1; }
if grep -rl -F "$checkout" "$project" --exclude-dir=build --exclude-dir=.gradle --exclude-dir=.cxx >"$results/checkout-paths.txt" 2>/dev/null; then
    note "FAIL the generated project names this checkout: $(head -3 "$results/checkout-paths.txt" | tr '\n' ' ')"
    status=1
else
    note "ok the generated project names nothing of this checkout"
fi

# ---------------------------------------------------------------- 3. APK
apk="$project/app/build/outputs/apk/release/app-release.apk"
if [[ -f $apk ]]; then
    cp "$apk" "$results/app-release.apk"
    note "apk $(stat -c %s "$apk") bytes sha256 $(sha256sum "$apk" | cut -d' ' -f1)"
    if "$checkout/audit/android-sdl3-2048/tools/inspect-apk.sh" "$apk" "$room/project/lib/game.manifest.json" \
        "$room/project/.bot_modules/.targets/android-aarch64/sdl3/android/sdl3-android.json" >"$results/apk.txt" 2>&1; then
        note "ok the APK's facts ($(grep -c '^ok' "$results/apk.txt") checked)"
    else
        note "FAIL the APK's facts: $(grep '^FAIL' "$results/apk.txt" | head -3 | tr '\n' ' ')"
        status=1
    fi
else
    note "FAIL no APK"
    status=1
fi

# ------------------------------------------- 4. the acceptance configuration
test_project="$room/out/android-test"
(cd "$room/project" && "${env_cmd[@]}" ../bin/botlish tool -out ../out/android-test -artifact lib/game.manifest.json \
    -target android-aarch64 android generate -application-id org.botlish.sdl2048.test -name "Botlish 2048 (test)" -intent-arguments) \
    >"$results/generate-test.txt" 2>&1 && (cd "$room/project" && "${gradle_env[@]}" ../bin/botlish tool -out ../out/android-test \
    -artifact lib/game.manifest.json -target android-aarch64 android build) >"$results/gradle-test.txt" 2>&1 &&
    cp "$test_project/app/build/outputs/apk/release/app-release.apk" "$results/game-test.apk" &&
    "$checkout/audit/android-sdl3-2048/tools/inspect-apk.sh" "$results/game-test.apk" "$room/project/lib/game.manifest.json" \
        "$room/project/.bot_modules/.targets/android-aarch64/sdl3/android/sdl3-android.json" >"$results/apk-test.txt" 2>&1 &&
    note "ok the acceptance's configuration: game-test.apk ($(grep -c '^ok' "$results/apk-test.txt") facts)" ||
    { note "FAIL the acceptance's configuration"; status=1; }
rm -rf "$room"
note "result: $([[ $status == 0 ]] && echo passed || echo FAILED)"
exit $status
