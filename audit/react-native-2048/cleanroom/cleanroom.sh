#!/usr/bin/env bash
# cleanroom.sh -- the clean room of BOTLISH-REACT-NATIVE-2048-PACKAGE-
# MILESTONE-1.md ("Cleanroom reproduction"): the distributed single-file
# compiler and published packages only, at the React Native boundary.
#
#   audit/react-native-2048/cleanroom/cleanroom.sh BOTLISH REPO RESULTS
#
# BOTLISH is the single-file compiler (single/build.sh), REPO a directory of
# published .botpkg artifacts: the Android AArch64 target support package
# and game2048 (audit/android-aarch64-target/tools/package.sh) and
# botlish_react_native (integrations/react-native/package.sh), packed for
# the native build BOTLISH was built from. The room is a fresh directory
# holding a copy of BOTLISH, the artifacts, the application's own inputs --
# its Botlish source (examples/react-native/2048/game.bot) and the clean
# React Native app (examples/react-native/app, without node_modules) -- and
# nothing of this checkout besides.
#
#   1. Botlish (traced): the packages installed as ordinary dependencies,
#      the library built for android-aarch64, its manifest checked against
#      its files, the tool run explicitly -- by the single executable, with
#      an empty environment (HOME, TMPDIR and the caches in the room; PATH
#      the system's; ANDROID_NDK_ROOT). Under strace every file opened and
#      program started is recorded, and the run fails if any is in this
#      checkout or is a Tcl of the system.
#   2. npm and React Native: `npm pack` of the generated package; the app
#      copied, its locked dependencies installed (npm ci), the package from
#      its tarball (npm install), TypeScript, Jest, React Native's Codegen
#      and the Android release build (Gradle). External dependencies come
#      from npm, Google's Maven and Maven Central (network allowed: they are
#      the app's, not Botlish's); Node, Java and the Android SDK are the
#      environment's (NODE_DIR, JAVA_HOME, ANDROID_HOME). Nothing under
#      node_modules is edited.
#   3. The APK: arm64-v8a only; the library is the generated package's (as
#      the Android build strips it), 16 KiB-aligned, zip-aligned.
#
# RESULTS gets each step's output, the trace, the APK and summary.txt; exit
# status 0 only when every check passed. Running the APK on Android is
# android-acceptance.sh's (the CI's android job runs it on this APK).
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
: "${ANDROID_HOME:?set ANDROID_HOME (the Android SDK of the app's build)}"
: "${JAVA_HOME:?set JAVA_HOME (the app's Gradle build)}"
node_dir=${NODE_DIR:-$(dirname "$(command -v node)")}
room=$(mktemp -d /tmp/botlish-rn-cleanroom.XXXXXX)
mkdir -p "$results" "$room/bin" "$room/home" "$room/tmp" "$room/repo" "$room/project" "$room/out"
cp "$botlish" "$room/bin/botlish"
cp "$repo"/*.botpkg "$room/repo/"
cp "$checkout/examples/react-native/2048/game.bot" "$room/project/"
mkdir -p "$room/app"
(cd "$checkout/examples/react-native/app" && tar --exclude=node_modules --exclude=build --exclude=.gradle -cf - .) | (cd "$room/app" && tar -xf -)
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

# ------------------------------------------------------------- 1. Botlish
cat >"$room/botlish-steps.sh" <<'EOF'
set -eu
cd project
printf '{"schema": 1, "dependencies": {}}\n' >botlish.json
for package in game2048 botlish_target_android_aarch64; do
    ../bin/botlish add "$package" -repository ../repo -target android-aarch64
done
../bin/botlish add botlish_react_native -repository ../repo
../bin/botlish tools
../bin/botlish -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
    -emit-native-library game -out lib game.bot
# The manifest binds its files: each SHA-256 as it records it.
for pair in static:libgame.a shared:libgame.so header:game.h; do
    key=${pair%%:*} file=${pair#*:}
    recorded=$(tr -d '\n ' <lib/game.manifest.json | sed -n "s/.*\"sha256\":{[^}]*\"$key\":\"\([0-9a-f]*\)\".*/\1/p")
    actual=$(sha256sum "lib/$file" | cut -d' ' -f1)
    [ "$recorded" = "$actual" ] || { echo "manifest: $file is not the file it describes"; exit 1; }
    echo "manifest: $file $actual"
done
../bin/botlish tool -out ../out/react-native-botlish-game -artifact lib/game.manifest.json -target android-aarch64 \
    -report ../out/tool-report.json react-native generate -name react-native-botlish-game
EOF
env_cmd=(env -i "HOME=$room/home" "PATH=/usr/bin:/bin" "LANG=C.UTF-8" "TMPDIR=$room/tmp" "ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT")
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
    grep -o 'execve("[^"]*"' "$results/trace.txt" | sort | uniq -c | sort -rn | head -20 >"$results/programs.txt"
else
    (cd "$room" && "${env_cmd[@]}" /bin/sh botlish-steps.sh) >"$results/botlish.txt" 2>&1 || { note "FAIL botlish steps"; status=1; }
    note "note strace is not installed: nothing traced"
fi
grep -E "^(manifest:|react-native:|botlish_react_native:)" "$results/botlish.txt" | sed 's/^/  /' | tee -a "$summary"
package="$room/out/react-native-botlish-game"
check "the tool wrote the package" test -f "$package/botlish-react-native.json"
[[ $status == 0 ]] || { note "result: FAILED"; exit 1; }

# ------------------------------------------------ 2. npm and React Native
rn_env=(env -i "HOME=$room/home" "PATH=$node_dir:$JAVA_HOME/bin:/usr/bin:/bin" "LANG=C.UTF-8" "TMPDIR=$room/tmp"
    "JAVA_HOME=$JAVA_HOME" "ANDROID_HOME=$ANDROID_HOME" "ANDROID_SDK_ROOT=$ANDROID_HOME" "GRADLE_USER_HOME=$room/home/.gradle"
    "npm_config_cache=$room/home/.npm")
# A proxy the environment needs to reach npm and Maven (never a Botlish
# input): its variables pass, and a Gradle properties file given as
# GRADLE_PROPERTIES is the room's.
for name in HTTPS_PROXY https_proxy HTTP_PROXY http_proxy NO_PROXY no_proxy NODE_EXTRA_CA_CERTS SSL_CERT_FILE JAVA_TOOL_OPTIONS; do
    [[ -n ${!name:-} ]] && rn_env+=("$name=${!name}")
done
if [[ -n ${GRADLE_PROPERTIES:-} ]]; then
    mkdir -p "$room/home/.gradle" && cp "$GRADLE_PROPERTIES" "$room/home/.gradle/gradle.properties"
    [[ -d ${GRADLE_INIT_DIR:-/nonexistent} ]] && cp -r "$GRADLE_INIT_DIR" "$room/home/.gradle/init.d"
fi
rn() { (cd "$1" && shift && "${rn_env[@]}" "$@"); }
rn "$package" npm pack --pack-destination "$room/out" >"$results/npm-pack.txt" 2>&1 && note "ok npm pack: $(ls "$room/out"/*.tgz | xargs -n1 basename)" || { note "FAIL npm pack"; status=1; }
rn "$room/app" npm ci --no-audit --no-fund >"$results/npm-ci.txt" 2>&1 && note "ok npm ci (the app's locked dependencies)" || { note "FAIL npm ci"; status=1; }
rn "$room/app" npm install --no-audit --no-fund "$room/out/react-native-botlish-game-0.1.0.tgz" >"$results/npm-install.txt" 2>&1 &&
    note "ok npm install of the generated package's tarball" || { note "FAIL npm install"; status=1; }
# The app's self-test also reads the second library's package: generated
# here the same way (a second project, the same tool).
mkdir -p "$room/project2"
cp "$checkout/examples/react-native/textkit/textkit.bot" "$room/project2/"
(cd "$room/project2" && "${env_cmd[@]}" /bin/sh -c '
    set -eu
    printf "{\"schema\": 1, \"dependencies\": {}}\n" >botlish.json
    ../bin/botlish add botlish_target_android_aarch64 -repository ../repo -target android-aarch64
    ../bin/botlish add botlish_react_native -repository ../repo
    ../bin/botlish -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 -emit-native-library textkit -out lib textkit.bot
    ../bin/botlish tool -out ../out/react-native-botlish-textkit -artifact lib/textkit.manifest.json -target android-aarch64 react-native generate') \
    >"$results/textkit.txt" 2>&1 && rn "$room/out/react-native-botlish-textkit" npm pack --pack-destination "$room/out" >>"$results/textkit.txt" 2>&1 &&
    rn "$room/app" npm install --no-audit --no-fund "$room/out/react-native-botlish-textkit-0.1.0.tgz" >>"$results/textkit.txt" 2>&1 &&
    note "ok the second library's package generated and installed" || { note "FAIL the second library"; status=1; }
rn "$room/app" npx --no-install tsc --noEmit >"$results/tsc.txt" 2>&1 && note "ok TypeScript" || { note "FAIL TypeScript"; status=1; }
rn "$room/app" npx --no-install jest --ci >"$results/jest.txt" 2>&1 && note "ok Jest: $(grep -o 'Tests: .*' "$results/jest.txt")" || { note "FAIL Jest"; status=1; }
rn "$room/app/android" ./gradlew --no-daemon --console=plain assembleRelease >"$results/gradle.txt" 2>&1 &&
    note "ok the Android release build ($(grep -o 'BUILD SUCCESSFUL in .*' "$results/gradle.txt"))" || { note "FAIL the Android release build"; tail -30 "$results/gradle.txt"; status=1; }
grep -E "Task :app:generate.*Codegen" "$results/gradle.txt" | sed 's/^/  /' | tee -a "$summary"
if grep -rl --include=*.gradle --include=*.kt --include=*.json --include=*.txt -F "$checkout" "$room/app" "$room/out" 2>/dev/null \
    | grep -v '/node_modules/\.cache/' >"$results/checkout-paths.txt"; then
    note "FAIL the app or the packages name this checkout: $(head -3 "$results/checkout-paths.txt" | tr '\n' ' ')"
    status=1
else
    note "ok neither the app nor the packages name this checkout"
fi

# ---------------------------------------------------------------- 3. APK
apk="$room/app/android/app/build/outputs/apk/release/app-release.apk"
if [[ -f $apk ]]; then
    cp "$apk" "$results/app-release.apk"
    note "apk $(stat -c %s "$apk") bytes sha256 $(sha256sum "$apk" | cut -d' ' -f1)"
    # The NDK the app's build used (its ndkVersion): its llvm-strip's
    # output is what the APK holds.
    ndkVersion=$(sed -n 's/^ *ndkVersion *= *"\(.*\)"/\1/p' "$room/app/android/build.gradle")
    ndk="$ANDROID_HOME/ndk/$ndkVersion"
    bin="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin"
    mkdir -p "$room/apk" && (cd "$room/apk" && unzip -q "$apk" 'lib/*')
    check "the APK holds arm64-v8a only" test "$(ls "$room/apk/lib")" = arm64-v8a
    "$bin/llvm-strip" --strip-unneeded -o "$room/stripped.so" "$package/native/android/arm64-v8a/libgame.so"
    check "libgame.so is the generated package's library, as the Android build strips it" cmp "$room/stripped.so" "$room/apk/lib/arm64-v8a/libgame.so"
    for so in "$room"/apk/lib/arm64-v8a/*.so; do
        for a in $("$bin/llvm-readelf" -l "$so" | awk '$1 == "LOAD" { print $NF }'); do
            (( a >= 16384 )) || { note "FAIL $(basename "$so") has a segment aligned to $a"; status=1; }
        done
    done
    note "ok every shared object's segments are 16 KiB-aligned"
    tools=$(ls -d "$ANDROID_HOME"/build-tools/* | sort -V | tail -1)
    check "zipalign -c -P 16" "$tools/zipalign" -c -P 16 4 "$apk"
fi
rm -rf "$room"
note "result: $([[ $status == 0 ]] && echo passed || echo FAILED)"
exit $status
