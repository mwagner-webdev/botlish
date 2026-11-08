#!/usr/bin/env bash
# cleanroom.sh -- the clean-room acceptance of
# ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md: the distributed single-file
# compiler, the packed packages, a declared Android NDK and an Android
# userspace; nothing of this checkout.
#
#   audit/android-aarch64-target/cleanroom/cleanroom.sh BOTLISH REPO NDK ROOTS RESULTS
#
# BOTLISH is the single-file compiler (single/build.sh), REPO the packed
# artifacts (tools/package.sh OUT: botlish_target_android_aarch64 and
# game2048, the target support package built for BOTLISH's runtime ABI), NDK
# an Android NDK (ANDROID_NDK_ROOT inside the room), ROOTS the Android
# userspaces of tools/sysroot.sh (api-N/root). The room is a fresh directory
# holding a copy of BOTLISH, the artifacts and the experiment's own inputs
# (the 2048 wrapper engine.bot, the Android host's C source, the game's
# calls); the run has an empty environment (env -i: HOME and TMPDIR in the
# room, PATH=/usr/bin:/bin, ANDROID_NDK_ROOT=NDK) and works in the room.
# Under strace every file opened and every program started is recorded, and
# the run fails if any is in this checkout, or is a system Tcl: the compiler
# is the single file, the runtime the package's -- the room never builds
# the runtime.
#
#   A  the packages installed for android-aarch64 (the package manager's view)
#   B  the 2048 library built for android-aarch64 with -target-support: an
#      AArch64 ELF shared object, 16 KiB-aligned, needing Bionic's libraries,
#      its manifest the target's and bound to its files (the NDK's readelf
#      and the system's sha256sum)
#   C  the Android host built by the NDK and run by Android's linker64 and
#      Bionic of each API level of ROOTS (qemu-aarch64): 160 steps against
#      the single executable's interpreter, the declared errors, instances,
#      thread affinity
#   D  the target support package removed: a precise refusal, no library
#
# RESULTS gets each step's output, the trace and a summary; the exit status
# is 0 only when every check passed.
set -euo pipefail
if [[ $# -ne 5 ]]; then
    echo "usage: cleanroom.sh BOTLISH REPO NDK ROOTS RESULTS" >&2
    exit 2
fi
botlish=$(realpath "$1")
repo=$(realpath "$2")
ndk=$(realpath "$3")
roots=$(realpath "$4")
results=$(realpath -m "$5")
here=$(cd "$(dirname "$0")" && pwd)
experiment=$(dirname "$here")
checkout=$(cd "$experiment/../.." && pwd)
room=$(mktemp -d /tmp/botlish-android-cleanroom.XXXXXX)
mkdir -p "$results" "$room/bin" "$room/home" "$room/repo" "$room/app" "$room/inputs" "$room/tmp"
cp "$botlish" "$room/bin/botlish"
cp "$repo"/*.botpkg "$room/repo/"
cp "$checkout/audit/external-tools/2048/engine.bot" "$experiment/host/host2048.c" "$room/inputs/"

# The game: tests/external-tools.test's linear congruential steps, 160.
x=12345
steps=()
for ((i = 0; i < 160; i++)); do
    x=$(( (x * 1103515245 + 12345) % 2147483648 ))
    d=$(( (x >> 16) % 4 ))
    if (( ((x >> 8) % 10) == 0 )); then t=4; else t=2; fi
    steps+=("$d $t")
done
{
    printf 'new_game\nspawn_first\t@\t2\nspawn_first\t@\t4\n'
    for s in "${steps[@]}"; do
        printf 'move\t@\t%s\nspawn_first\t@\t%s\n' "${s% *}" "${s#* }"
    done
    printf 'move\tnot a state\t0\nmove\t@\t9\n'
    printf 'spawn\t0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\t0\t0\t2\nspawn\t0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\t0\t1\t3\n'
} >"$room/inputs/calls.txt"
literal=$(printf '[%s], ' "${steps[@]/ /, }")
literal="[${literal%, }]"
cat >"$room/inputs/oracle.bot" <<EOF
import std::list
import engine

fn play(state: str, steps: List[List[int]], i: int, states: List[str]) -> List[str] errors engine::InvalidState, engine::InvalidDirection, engine::InvalidSpawn:
    if i >= std::list::length(steps):
        return states
    step = std::list::get(steps, i, [0, 2])
    moved = engine::move(state, std::list::get(step, 0, 0))
    next = engine::spawn_first(moved, std::list::get(step, 1, 2))
    play(next, steps, i + 1, std::list::append(std::list::append(states, moved), next))

fn game(steps: List[List[int]]) -> List[str] errors engine::InvalidState, engine::InvalidDirection, engine::InvalidSpawn:
    start = engine::spawn_first(engine::spawn_first(engine::new_game(), 2), 4)
    play(start, steps, 0, [start])

states = game($literal):
    on engine::InvalidState:
        []
    on engine::InvalidDirection:
        []
    on engine::InvalidSpawn:
        []
states
EOF

cat >"$room/run.sh" <<'EOF'
set -euo pipefail
room=$1
roots=$2
cd "$room/app"
b="$room/bin/botlish"
bin="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin"
pass() { echo "PASS $*"; }
fail() { echo "FAIL $*"; exit 1; }
echo '{"schema": 1, "dependencies": {}}' >botlish.json

# A: the packages, for android-aarch64.
"$b" add "$room/repo/game2048-0.1.0.botpkg" -target android-aarch64 >"$room/out-A-add.txt"
"$b" add "$room/repo/botlish_target_android_aarch64-0.1.0.botpkg" -target android-aarch64 >>"$room/out-A-add.txt"
"$b" verify >>"$room/out-A-add.txt"
[[ -f .bot_modules/.targets/android-aarch64/botlish_target_android_aarch64/botlish-target-support.json ]] \
    && pass "A the packages installed for android-aarch64" || fail A

# B: the library.
cp "$room/inputs/engine.bot" engine.bot
"$b" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
    -emit-native-library game -out lib engine.bot >"$room/out-B-library.txt" 2>&1
grep -q "target support: botlish_target_android_aarch64 (android-aarch64, runtime $room/app/.bot_modules/.targets/android-aarch64/" "$room/out-B-library.txt" \
    && pass "B the library linked with the installed package's runtime" || fail "B library"
"$bin/llvm-readelf" -hldW --dyn-syms lib/libgame.so >"$room/out-B-readelf.txt"
grep -q 'Type: *DYN' "$room/out-B-readelf.txt" && grep -q 'Machine: *AArch64' "$room/out-B-readelf.txt" \
    && pass "B an AArch64 ELF shared object" || fail "B ELF type"
[[ -z $(grep ' LOAD ' "$room/out-B-readelf.txt" | awk '$NF != "0x4000"') ]] && pass "B every loadable segment 16 KiB-aligned" || fail "B alignment"
needed=$(grep NEEDED "$room/out-B-readelf.txt" | sed 's/.*\[\(.*\)\]/\1/' | sort | tr '\n' ' ')
[[ $needed == "libc.so libdl.so liblog.so libm.so " ]] && pass "B needs Bionic's libc, libdl, liblog and libm only" || fail "B needed: $needed"
! grep -q TEXTREL "$room/out-B-readelf.txt" && pass "B no text relocation" || fail "B TEXTREL"
manifest=lib/game.manifest.json
grep -q '"name": "android-aarch64"' $manifest && grep -q '"package": "botlish_target_android_aarch64"' $manifest \
    && grep -q "\"shared\": \"$(sha256sum lib/libgame.so | cut -d' ' -f1)\"" $manifest \
    && pass "B the manifest is android-aarch64's and binds the shared library" || fail "B manifest"

# C: the Android host, in an Android process of every API level.
"$bin/clang" --target=aarch64-linux-android21 -std=c11 -O2 -Wall -Wextra -Werror -I lib \
    -o lib/host2048 "$room/inputs/host2048.c" -ldl
cp "$room/inputs/oracle.bot" oracle.bot
"$b" -warnings off -backend interp -target android-aarch64 oracle.bot >"$room/out-C-oracle.txt"
grep -o '"[0-9 ]*"' "$room/out-C-oracle.txt" | tr -d '"' >"$room/oracle-states.txt"
[[ $(wc -l <"$room/oracle-states.txt") -eq 321 ]] || fail "C oracle states"
for root in "$roots"/api-*/root; do
    api=$(basename "$(dirname "$root")")
    LD_LIBRARY_PATH="$room/app/lib" qemu-aarch64 -L "$root" lib/host2048 lib/libgame.so play \
        <"$room/inputs/calls.txt" >"$room/out-C-$api-play.txt" 2>"$room/out-C-$api-stderr.txt"
    grep "^STATE" "$room/out-C-$api-play.txt" | cut -f2 | tail -n +3 | head -321 >"$room/host-$api-states.txt"
    cmp -s "$room/oracle-states.txt" "$room/host-$api-states.txt" && pass "C $api: 321 states as the interpreter's" || fail "C $api states"
    [[ $(grep '^ERROR' "$room/out-C-$api-play.txt" | cut -f3 | tr '\n' ' ') == "InvalidState InvalidDirection game2048::CellOccupied InvalidSpawn " ]] \
        && pass "C $api: the declared errors cross the C ABI" || fail "C $api errors"
    LD_LIBRARY_PATH="$room/app/lib" qemu-aarch64 -L "$root" lib/host2048 lib/libgame.so lifecycle 20 >"$room/out-C-$api-lifecycle.txt" 2>/dev/null
    LD_LIBRARY_PATH="$room/app/lib" qemu-aarch64 -L "$root" lib/host2048 lib/libgame.so thread >"$room/out-C-$api-thread.txt" 2>/dev/null
    grep -q 'INVALID-INSTANCE' "$room/out-C-$api-lifecycle.txt" && grep -q 'OTHER-THREAD.*WRONG-THREAD' "$room/out-C-$api-thread.txt" \
        && pass "C $api: instances and thread affinity" || fail "C $api lifecycle"
done

# D: without the target support package.
"$b" remove botlish_target_android_aarch64 -target android-aarch64 >"$room/out-D-remove.txt"
rm -rf lib
set +e
"$b" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
    -emit-native-library game -out lib engine.bot >"$room/out-D-missing.txt" 2>&1
status=$?
set -e
[[ $status == 1 && ! -e lib/libgame.so ]] && grep -q 'NATIVE TARGET-SUPPORT MISSING' "$room/out-D-missing.txt" \
    && pass "D a removed target support package is refused, precisely" || fail D
EOF

env_cmd=(env -i "HOME=$room/home" "PATH=/usr/bin:/bin" "LANG=C.UTF-8" "TMPDIR=$room/tmp" "ANDROID_NDK_ROOT=$ndk")
set +e
(cd "$room" && "${env_cmd[@]}" strace -f -qq -e trace=execve,open,openat,stat,newfstatat,access -o "$results/trace.txt" \
    /bin/bash "$room/run.sh" "$room" "$roots") | tee "$results/summary.txt"
status=${PIPESTATUS[0]}
set -e
cp "$room"/out-* "$results/" 2>/dev/null || true
if grep -F "$checkout" "$results/trace.txt" | grep -v ENOENT >"$results/checkout-access.txt"; then
    echo "FAIL the run reached this checkout ($(wc -l <"$results/checkout-access.txt") accesses: checkout-access.txt)" | tee -a "$results/summary.txt"
    status=1
else
    echo "PASS the run reached nothing of the checkout ($checkout)" | tee -a "$results/summary.txt"
fi
if grep -E '(/usr/(local/)?(lib|share)/(x86_64-linux-gnu/)?tcl[0-9]|/usr/share/tcltk|execve\("[^"]*tclsh)' "$results/trace.txt" \
        | grep -v ENOENT >"$results/system-tcl-access.txt"; then
    echo "FAIL the run used a system Tcl (system-tcl-access.txt)" | tee -a "$results/summary.txt"
    status=1
else
    echo "PASS the run used no Tcl but the single file's own" | tee -a "$results/summary.txt"
fi
if grep -E 'cargo|rustc' "$results/trace.txt" | grep execve | grep -v ENOENT >"$results/runtime-builds.txt"; then
    echo "FAIL the run built a runtime (runtime-builds.txt)" | tee -a "$results/summary.txt"
    status=1
else
    echo "PASS the run built no runtime (no cargo, no rustc)" | tee -a "$results/summary.txt"
fi
rm -rf "$room"
exit "$status"
