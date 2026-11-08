#!/usr/bin/env bash
# build.sh -- BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md end to end,
# from a checkout to an Android APK: what the CI's build job runs, and what a
# local run reproduces.
#
#   audit/react-native-2048/tools/build.sh OUT
#
# Steps (each writes under OUT):
#
#   1. the packages, as their authors pack them: the Android AArch64 target
#      support package and the 2048 engine (audit/android-aarch64-target/
#      tools/package.sh; skipped when ANDROID_PACKAGES names a directory that
#      already holds them), and the tool package botlish_react_native
#      (integrations/react-native/package.sh)  -> OUT/repo
#   2. two Botlish projects, each with its packages installed as ordinary
#      dependencies, each library built for android-aarch64 and for the host
#      -> OUT/projects/{game,textkit}/{android,host}/lib
#   3. the tool, run explicitly by `botlish tool`, and `npm pack`
#      -> OUT/generated/*, OUT/npm/*.tgz
#   4. the host harnesses: the generated C++ core layers compiled unchanged
#      against the host libraries (harness/*.cpp) -> OUT/host
#   5. the interpreter's oracle for the self-test's game -> OUT/oracle-42.txt
#   6. the app: examples/react-native/app copied, its locked dependencies
#      (npm ci), the two packages installed from their tarballs, TypeScript,
#      Jest, the Android release build -> OUT/app, OUT/app-release.apk
#   7. what the APK holds -> OUT/apk-report.txt
#
# Environment: ANDROID_NDK_ROOT (an NDK of at least r28, for the Botlish
# libraries), ANDROID_HOME (the SDK the app's Gradle build uses), Node 22,
# Java 17+, a C and C++ compiler. BOTLISH (default: tclsh9.0 main.tcl of this
# checkout) is the compiler command; NATIVE_DIR (default native/target/release)
# the native build the target support package's runtime ABI is checked
# against.
set -euo pipefail
out=$(realpath -m "${1:?usage: build.sh OUT}")
here=$(cd "$(dirname "$0")" && pwd)
audit=$(dirname "$here")
root=$(cd "$audit/../.." && pwd)
read -r -a botlish <<<"${BOTLISH:-tclsh9.0 $root/main.tcl}"
export LANG=C.utf8 LC_ALL=C.utf8
: "${ANDROID_NDK_ROOT:?set ANDROID_NDK_ROOT to an Android NDK (r28 or later)}"
: "${ANDROID_HOME:?set ANDROID_HOME to the Android SDK}"
mkdir -p "$out/repo" "$out/npm"
step() { printf '\n== %s\n' "$*"; }

step "1. packages"
if [[ -n ${ANDROID_PACKAGES:-} ]]; then
    cp "$ANDROID_PACKAGES"/*.botpkg "$out/repo/"
else
    "$root/audit/android-aarch64-target/tools/package.sh" "$out/android-packages" "${botlish[@]}"
    cp "$out/android-packages/repo"/*.botpkg "$out/repo/"
fi
"$root/integrations/react-native/package.sh" "$out/tool" "${botlish[@]}"
cp "$out/tool/repo"/*.botpkg "$out/repo/"
ls -l "$out/repo"

step "2. the Botlish libraries"
# A library's two projects: android (its packages installed for
# android-aarch64, the target support package and the tool among them; the
# library built for Android into lib/) and host (its packages for the host;
# the host library the harnesses link, into host/).
project() { # NAME SOURCE PACKAGE...
    local name=$1 source=$2
    shift 2
    local dir="$out/projects/$name"
    rm -rf "$dir"
    mkdir -p "$dir/android" "$dir/host"
    for side in android host; do
        printf '{"schema": 1, "dependencies": {}}\n' >"$dir/$side/botlish.json"
        cp "$source" "$dir/$side/"
    done
    for package in "$@" botlish_target_android_aarch64; do
        (cd "$dir/android" && "${botlish[@]}" add "$package" -repository "$out/repo" -target android-aarch64)
    done
    (cd "$dir/android" && "${botlish[@]}" add botlish_react_native -repository "$out/repo")
    (cd "$dir/android" && "${botlish[@]}" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
        -emit-native-library "$name" -out lib "$(basename "$source")")
    for package in "$@"; do
        (cd "$dir/host" && "${botlish[@]}" add "$package" -repository "$out/repo")
    done
    (cd "$dir/host" && "${botlish[@]}" -warnings error -emit-native-library "$name" -out lib "$(basename "$source")")
    cmp "$dir/android/lib/$name.h" "$dir/host/lib/$name.h"
}
project game "$root/examples/react-native/2048/game.bot" game2048
project textkit "$root/examples/react-native/textkit/textkit.bot"

step "3. the tool, run explicitly"
(cd "$out/projects/game/android" && "${botlish[@]}" tools)
(cd "$out/projects/game/android" && "${botlish[@]}" tool -out "$out/generated/react-native-botlish-game" \
    -artifact lib/game.manifest.json -target android-aarch64 -report "$out/tool-report-game.json" \
    react-native generate -name react-native-botlish-game -replace)
(cd "$out/projects/textkit/android" && "${botlish[@]}" tool -out "$out/generated/react-native-botlish-textkit" \
    -artifact lib/textkit.manifest.json -target android-aarch64 -report "$out/tool-report-textkit.json" \
    react-native generate -replace)
rm -f "$out/npm"/*.tgz
for package in react-native-botlish-game react-native-botlish-textkit; do
    (cd "$out/generated/$package" && npm pack --pack-destination "$out/npm" --silent)
done
ls -l "$out/npm"

step "4. the host harnesses"
mkdir -p "$out/host"
game="$out/generated/react-native-botlish-game/cpp"
text="$out/generated/react-native-botlish-textkit/cpp"
glib="$out/projects/game/host/lib"
tlib="$out/projects/textkit/host/lib"
c++ -std=c++20 -O1 -g -Wall -Wextra -Werror -I"$game" -I"$glib" -o "$out/host/game_core" \
    "$audit/harness/game_core.cpp" "$game/BotlishGameCore.cpp" -L"$glib" -lgame -Wl,-rpath,"$glib" -pthread
c++ -std=c++20 -O1 -g -Wall -Wextra -Werror -DWITH_GAME -I"$text" -I"$game" -I"$tlib" -I"$glib" -o "$out/host/textkit_core" \
    "$audit/harness/textkit_core.cpp" "$text/BotlishTextkitCore.cpp" "$game/BotlishGameCore.cpp" \
    -L"$tlib" -L"$glib" -ltextkit -lgame -Wl,-rpath,"$tlib:$glib" -pthread
"$out/host/game_core" checks | tee "$out/host/game-checks.txt"
"$out/host/textkit_core" | tee "$out/host/textkit-checks.txt"
"$out/host/game_core" stress 20 >"$out/host/stress.txt"
BOTLISH_NATIVE_GC_STRESS=1 "$out/host/game_core" stress 20 >"$out/host/stress-gc.txt"
diff <(grep -v '^diagnostics' "$out/host/stress.txt") <(grep -v '^diagnostics' "$out/host/stress-gc.txt")
tail -1 "$out/host/stress-gc.txt"

step "5. the oracle"
directions=$(sed -n "s/^  '\([0-3]*\)';$/\1/p" "$root/examples/react-native/app/src/directions.ts")
seed=$(sed -n 's/^export const seed = \([0-9]*\);$/\1/p' "$root/examples/react-native/app/src/directions.ts")
[[ ${#directions} -eq 400 && -n $seed ]] || { echo "build.sh: cannot read the self-test's directions" >&2; exit 1; }
printf '%s\n' "$directions" >"$out/directions.txt"
tclsh9.0 "$here/oracle.tcl" "$seed" "$directions" >"$out/oracle-$seed.txt"
"$out/host/game_core" play "$seed" "$directions" >"$out/host/play-$seed.txt"
cmp "$out/oracle-$seed.txt" "$out/host/play-$seed.txt"
echo "the host library through the generated core: $(wc -l <"$out/oracle-$seed.txt") snapshots, the interpreter's"
# The Android run's played swipes (android-acceptance.sh: twelve, a burst of
# eight, then four after the app returns from the background), and New game.
plays=013201320231023102130213
printf '%s\n' "$plays" >"$out/play-directions.txt"
tclsh9.0 "$here/oracle.tcl" 42 "$plays" >"$out/play-oracle.txt"
tclsh9.0 "$here/oracle.tcl" 43 "" >"$out/restart-oracle.txt"

step "6. the app"
rm -rf "$out/app"
cp -a "$root/examples/react-native/app" "$out/app"
cd "$out/app"
npm ci --no-audit --no-fund
npm install --no-audit --no-fund "$out/npm/react-native-botlish-game-0.1.0.tgz" "$out/npm/react-native-botlish-textkit-0.1.0.tgz"
npx --no-install react-native config >"$out/react-native-config.json"
npx --no-install tsc --noEmit
npx --no-install jest --ci 2>&1 | tee "$out/jest.txt"
(cd android && ./gradlew --no-daemon --console=plain assembleRelease)
cp android/app/build/outputs/apk/release/app-release.apk "$out/app-release.apk"

step "7. the APK"
"$here/inspect-apk.sh" "$out/app-release.apk" "$out" | tee "$out/apk-report.txt"
