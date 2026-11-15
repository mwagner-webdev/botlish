#!/usr/bin/env bash
# acceptance-2048.sh BUILD OUT [APK] -- the Botlish SDL3 2048 application in
# an Android application process, on the running emulator or device adb
# sees (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, "Real Android
# application acceptance"). BUILD is build.sh's output (the APKs and the
# interpreter's oracles); APK defaults to BUILD/game-test.apk, the test
# configuration (generated -intent-arguments: its launching intent's
# arguments are the program's, here --seed 42 --fresh). OUT receives the
# logs, screenshots and summary.txt.
#
#   1. start      install, launch: SDLActivity, SDLThread, game_main, SDL's
#                 window and renderer; seed 42's new game, the interpreter's
#   2. play       24 swipes on the screen (input swipe): twelve, a rapid
#                 burst of eight, four after the background; every swipe
#                 applied exactly once, every snapshot the interpreter's;
#                 a short gesture ignored; screenshots checked cell by cell
#   3. lifecycle  the background (no drawing, idle, the game kept) and the
#                 foreground; per-thread CPU while idle
#   4. restart    the restart button: a new game
#   5. restore    the process killed (am force-stop) and started again: the
#                 saved game restored
#   6. win, over  a saved board one move from 2048 and one from the end
#                 (written into the app's storage: adb root), played: the
#                 interpreter's snapshots, the screen showing them
#   7. recreate   the Activity destroyed while the process lives ("don't
#                 keep activities"): the program saves and returns, a new
#                 Activity starts it again and it restores the game
#   8. exit       the back key: the program returns, game_main returns 0;
#                 no native crash anywhere in the run
#
# Exit status 1 on any FAIL (summary.txt).
set -uo pipefail
build=$(realpath "$1")
OUT=$(realpath -m "$2")
apk=$(realpath "${3:-$build/game-test.apk}")
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
SUMMARY="$OUT/summary.txt"
: >"$SUMMARY"
PKG=org.botlish.sdl2048.test
TAG=Botlish2048
. "$here/lib.sh"
activity="$PKG/.MainActivity"
oracle="$build/oracle-42.txt"
plays=$(cat "$build/play-directions.txt")

# The snapshots of the "2048: move D SNAPSHOT" lines of LOG.
moves() { grep -o "2048: move [0-3] .*" "$1" | cut -d' ' -f4- ; }
# The snapshot of the last "2048: KIND SNAPSHOT" line of LOG.
last() { grep -o "2048: $2 2048/1.*" "$1" | tail -1 | cut -d' ' -f3- ; }

note "device: $(shellp getprop ro.product.model) sdk $(shellp getprop ro.build.version.sdk) abilist $(shellp getprop ro.product.cpu.abilist) bridge $(shellp getprop ro.dalvik.vm.native.bridge) page $(shellp getconf PAGE_SIZE)"
rooted=0
if adb root >/dev/null 2>&1; then
    adb wait-for-device
    sleep 2
    [[ $(shellp id -u) == 0 ]] && rooted=1
fi
note "  adb root: $rooted"
startCapture

# ----------------------------------------------------------------- 1. start
adb uninstall "$PKG" >/dev/null 2>&1 || true
adb install -r "$apk" >"$OUT/install.txt" 2>&1 && pass "install $(basename "$apk")" || { fail "install: $(cat "$OUT/install.txt")"; exit 1; }
adb logcat -c
shellp am start -W -n "$activity" --esa org.botlish.android.ARGUMENTS --seed,42,--fresh >"$OUT/start.txt"
note "  launch: $(grep -E "TotalTime|WaitTime" "$OUT/start.txt" | tr -s ' \n' ' ')"
waitFor start "$TAG.*2048: ready" 1 90 && pass "start: $(grep -o '2048: ready.*' "$OUT/start.log" | head -1)"
grep -o "environment api.*" "$OUT/start.log" | head -1 | sed 's/^/  /' | tee -a "$SUMMARY"
grep -o "entering game_main.*" "$OUT/start.log" | head -1 | sed 's/^/  /' | tee -a "$SUMMARY"
grep -o "libgame.so pinned.*" "$OUT/start.log" | head -1 | sed 's/^/  /' | tee -a "$SUMMARY"
[[ $(last "$OUT/start.log" new) == "$(sed -n 1p "$oracle")" ]] && pass "seed 42's new game is the interpreter's" || fail "new game $(last "$OUT/start.log" new), the interpreter's $(sed -n 1p "$oracle")"
layout=$(grep -o "2048: layout.*" "$OUT/start.log" | tail -1)
note "  $layout"
read -r lw lh bx by bs gap rx ry rw rh <<<"$(echo "$layout" | sed -E 's/.*layout ([0-9]+)x([0-9]+) board (-?[0-9]+) (-?[0-9]+) ([0-9]+) gap ([0-9]+) restart (-?[0-9]+) (-?[0-9]+) ([0-9]+) ([0-9]+).*/\1 \2 \3 \4 \5 \6 \7 \8 \9 \10/')"
read -r sw sh <<<"$(screenSize | tr x ' ')"
offset=$(( sh - lh ))
(( offset < 0 )) && offset=0
note "  screen ${sw}x${sh}, window ${lw}x${lh}: the window starts $offset px down"
pid=$(appPid)
tid=$(grep "2048: ready" "$OUT/start.log" | head -1 | awk '{print $4}')
tname=$(shellp cat "/proc/$pid/task/$tid/comm" 2>/dev/null)
[[ $tname == SDLThread ]] && pass "the program runs on SDLThread (pid $pid, tid $tid)" || fail "the program's thread $tid is \"$tname\", not SDLThread"
if (( rooted )); then
    shellp cat "/proc/$pid/maps" >"$OUT/maps.txt"
    note "  mapped: $(grep -o '[^ /]*\.so$' "$OUT/maps.txt" | grep -E 'libgame|libSDL3|libmain|libndk_translation|libnb' | sort -u | tr '\n' ' ')"
    for lib in libgame.so libSDL3.so libmain.so; do
        how=$(mapsLibrary "$pid" "$apk" "$lib") && pass "$lib is mapped in the application process, $how" || fail "$lib is not mapped"
    done
fi
sleep 1
screenshot start
python3 -I "$here/screen.py" "$OUT/start.png" "$layout" "$(sed -n 1p "$oracle")" "$offset" >"$OUT/start-screen.txt" 2>&1 \
    && pass "the screen shows the new game ($(tail -1 "$OUT/start-screen.txt"))" || fail "the screen: $(tail -3 "$OUT/start-screen.txt" | tr '\n' ' ')"

# ------------------------------------------------------------------ 2. play
cx=$(( bx + bs / 2 )) cy=$(( by + bs / 2 + offset )) d=$(( bs / 3 ))
swipe() { # DIRECTION
    case $1 in
        0) shellp input swipe $((cx + d)) $cy $((cx - d)) $cy 150 ;;
        1) shellp input swipe $((cx - d)) $cy $((cx + d)) $cy 150 ;;
        2) shellp input swipe $cx $((cy + d)) $cx $((cy - d)) 150 ;;
        3) shellp input swipe $cx $((cy - d)) $cx $((cy + d)) 150 ;;
    esac
}
compare() { # NAME COUNT
    moves "$OUT/$1.log" >"$OUT/$1-moves.txt"
    sed -n "2,$(( $2 + 1 ))p" "$oracle" >"$OUT/$1-oracle.txt"
    if cmp -s "$OUT/$1-moves.txt" "$OUT/$1-oracle.txt"; then
        pass "$1: $2 swipes, each applied once, every snapshot the interpreter's"
    else
        fail "$1: the moves differ from the interpreter's ($(wc -l <"$OUT/$1-moves.txt") lines; diff in $1-diff.txt)"
        diff "$OUT/$1-moves.txt" "$OUT/$1-oracle.txt" >"$OUT/$1-diff.txt"
    fi
}
for i in $(seq 0 11); do
    swipe "${plays:$i:1}"
    waitFor "swipe$i" "2048: move" $((i + 1)) 20 >/dev/null || break
done
appLog >"$OUT/play12.log"
compare play12 12
screenshot play12
python3 -I "$here/screen.py" "$OUT/play12.png" "$layout" "$(sed -n 13p "$oracle")" "$offset" >"$OUT/play12-screen.txt" 2>&1 \
    && pass "the screen shows the twelfth state" || fail "the screen after twelve swipes: $(tail -3 "$OUT/play12-screen.txt" | tr '\n' ' ')"
# A rapid burst: eight swipes, no wait between them.
for i in $(seq 12 19); do swipe "${plays:$i:1}"; done
waitFor burst "2048: move" 20 40 && compare burst 20
# A short gesture on the board (a tap, under the swipe threshold): nothing.
shellp input swipe $cx $cy $((cx + 2)) $cy 100
sleep 2
appLog >"$OUT/short.log"
(( $(moves "$OUT/short.log" | wc -l) == 20 )) && pass "a short gesture moves nothing" || fail "a short gesture moved"

# ------------------------------------------------------------- 3. lifecycle
shellp input keyevent KEYCODE_HOME
waitFor background "2048: background" 1 20 && pass "background: the program saw WillEnterBackground (SDL_ANDROID_BLOCK_ON_PAUSE 0)"
sleep 3
threads "$pid" >"$OUT/bg-threads-0.txt"
t0=$(cpuTicks "$pid"); sleep 5; t1=$(cpuTicks "$pid")
threads "$pid" >"$OUT/bg-threads-1.txt"
if [[ $(appPid) == "$pid" ]]; then
    note "  background: $((t1 - t0)) clock ticks of CPU in 5 s; threads: $(busiest "$OUT/bg-threads-0.txt" "$OUT/bg-threads-1.txt")"
    (( t1 - t0 <= 25 )) && pass "the hidden app is idle ($((t1 - t0)) ticks in 5 s)" || fail "the hidden app used $((t1 - t0)) ticks in 5 s"
fi
shellp am start -W -n "$activity" >"$OUT/resume.txt"
if [[ $(appPid) == "$pid" ]]; then
    waitFor foreground "2048: foreground" 1 20 && pass "foreground: the program saw DidEnterForeground"
    pass "the same process, the same game"
elif lmkd=$(lmkdKilled "$pid"); then
    # Android may end a hidden process: the game saved when it was hidden
    # (WillEnterBackground) is what a new process starts from.
    note "  the system's low-memory killer ended the hidden process: ${lmkd#*lowmemorykiller: }"
    if waitFor restored "2048: restored" 1 60; then
        r=$(last "$OUT/restored.log" restored)
        [[ $r == "$(sed -n 21p "$oracle")" ]] && pass "a new process restored the game saved when it was hidden (the 20th state)" ||
            fail "the new process restored \"$r\", not the 20th state"
    fi
    pid=$(appPid)
    tid=$(sdlThread "$pid")
else
    fail "the process changed in the background (not by the low-memory killer)"
fi
sleep 2
for i in $(seq 20 23); do
    swipe "${plays:$i:1}"
    waitFor "swipe$i" "2048: move" $((i + 1)) 20 >/dev/null || break
done
appLog >"$OUT/play24.log"
compare play24 24
screenshot play24
python3 -I "$here/screen.py" "$OUT/play24.png" "$layout" "$(sed -n 25p "$oracle")" "$offset" >"$OUT/play24-screen.txt" 2>&1 \
    && pass "the screen shows the 24th state after the foreground" || fail "the screen after the foreground: $(tail -3 "$OUT/play24-screen.txt" | tr '\n' ' ')"
sleep 5
threads "$pid" >"$OUT/fg-threads-0.txt"
t0=$(cpuTicks "$pid"); sleep 5; t1=$(cpuTicks "$pid")
threads "$pid" >"$OUT/fg-threads-1.txt"
note "  foreground idle: $((t1 - t0)) clock ticks of CPU in 5 s; threads: $(busiest "$OUT/fg-threads-0.txt" "$OUT/fg-threads-1.txt")"
sdl=$(threadDelta "$OUT/fg-threads-0.txt" "$OUT/fg-threads-1.txt" "$tid")
(( ${sdl:-999} <= 25 )) && pass "the idle program does not spin (SDLThread: ${sdl:-?} ticks in 5 s)" || fail "the idle program's thread used ${sdl:-?} ticks in 5 s"

# --------------------------------------------------------------- 4. restart
shellp input tap $(( rx + rw / 2 )) $(( ry + rh / 2 + offset ))
waitFor restart "2048: restart" 1 20
restarted=$(last "$OUT/restart.log" restart)
python3 -I - "$restarted" <<'PY' && pass "restart: a new game ($restarted)" || fail "restart: \"$restarted\" is no new game"
import sys
f = sys.argv[1].split()
cells = [int(v) for v in f[7:]]
sys.exit(0 if len(f) == 23 and f[0] == "2048/1" and f[2] == "0" and f[3] == "0" and sum(1 for c in cells if c) == 2 and all(c in (0, 2, 4) for c in cells) else 1)
PY

# --------------------------------------------------------------- 5. restore
sleep 1
shellp am force-stop "$PKG"
adb logcat -c
shellp am start -W -n "$activity" >"$OUT/restore.txt"
waitFor restore "2048: ready" 1 60
[[ $(last "$OUT/restore.log" restored) == "$restarted" ]] && pass "after the process was killed, the saved game is restored" || fail "restored \"$(last "$OUT/restore.log" restored)\", not \"$restarted\""
storage=$(grep -o "2048: storage .*" "$OUT/restore.log" | tail -1 | cut -d' ' -f3)
note "  storage $storage"

# ------------------------------------------------------------ 6. win, over
play_saved() { # NAME START ORACLE DIRECTION
    local name=$1 start=$2 expected=$3 direction=$4
    shellp am force-stop "$PKG"
    printf '%s' "$start" | adb shell "cat > '$storage'"
    owner=$(shellp stat -c %u "$(dirname "$storage")")
    shellp chown "$owner:$owner" "$storage"
    adb logcat -c
    shellp am start -W -n "$activity" >"$OUT/$name.txt"
    waitFor "$name" "2048: ready" 1 60 || return
    [[ $(last "$OUT/$name.log" restored) == "$start" ]] || { fail "$name: the written save was not restored"; return; }
    sleep 1
    swipe "$direction"
    waitFor "$name" "2048: move" 1 20 || return
    got=$(moves "$OUT/$name.log" | tail -1)
    [[ $got == "$expected" ]] && pass "$name: $got, the interpreter's" || fail "$name: $got, the interpreter's $expected"
    sleep 1
    screenshot "$name"
    python3 -I "$here/screen.py" "$OUT/$name.png" "$layout" "$expected" "$offset" >"$OUT/$name-screen.txt" 2>&1 \
        && pass "$name: the screen shows it" || fail "$name: the screen: $(tail -3 "$OUT/$name-screen.txt" | tr '\n' ' ')"
}
if (( rooted )) && [[ -n $storage ]]; then
    play_saved win "$(cat "$build/win-start.txt")" "$(sed -n 2p "$build/win-oracle.txt")" 0
    play_saved over "$(cat "$build/over-start.txt")" "$(sed -n 2p "$build/over-oracle.txt")" 1
else
    note "  win, over: NOT DEMONSTRATED (no adb root to write the save into the app's storage)"
fi

# --------------------------------------------------------------- 7. recreate
shellp settings put global always_finish_activities 1
adb logcat -c
pid=$(appPid)
shellp input keyevent KEYCODE_HOME
waitFor destroy "game_main returned 0" 1 30 && pass "the Activity destroyed: the program saved and returned ($(grep -o '2048: \(quit\|terminating\)' "$OUT/destroy.log" | head -1))"
shellp am start -W -n "$activity" >"$OUT/recreate.txt"
waitFor recreate "2048: ready" 1 60 && pass "a new Activity: $(grep -c 'entering game_main' "$OUT/recreate.log") new entry, $( [[ $(appPid) == "$pid" ]] && echo "the same process" || echo "a new process"), $(grep -o '2048: restored' "$OUT/recreate.log" | head -1 || echo 'no restore')"
grep -q "2048: restored" "$OUT/recreate.log" || fail "recreate: the game was not restored"
shellp settings put global always_finish_activities 0

# ------------------------------------------------------------------ 8. exit
sleep 1
adb logcat -c
shellp input keyevent KEYCODE_BACK
waitFor exit "game_main returned 0" 1 30 && pass "exit: the back key -- $(grep -o '2048: back' "$OUT/exit.log" | head -1); $(grep -o '2048: done.*' "$OUT/exit.log" | head -1 | cut -c1-40)...; game_main returned 0"
stopCapture
c=$(crashes "$OUT/logcat-all.txt")
[[ -z $c ]] && pass "no crash of $PKG" || fail "crash: $c"
o=$(otherCrashes "$OUT/logcat-all.txt")
[[ -z $o ]] || note "  (other processes' crash reports, not the application's: $(echo "$o" | head -3 | tr '\n' ';'))"
note "status $status"
exit $status
