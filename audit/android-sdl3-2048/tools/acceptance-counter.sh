#!/usr/bin/env bash
# acceptance-counter.sh APK OUT -- the counter (examples/android-sdl3/counter)
# in an Android application process, on the running emulator or device adb
# sees (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, "Second
# application"; the milestone's first integration gate): SDLActivity starts
# SDLThread, the shim calls counter_main, the Botlish program initializes
# SDL, makes a window and a renderer, draws, counts taps, survives the
# background and exits cleanly with the back key. OUT receives the logs, the
# screenshots and summary.txt; exit status 1 on any FAIL.
set -uo pipefail
apk=$(realpath "$1")
OUT=$(realpath -m "$2")
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
SUMMARY="$OUT/summary.txt"
: >"$SUMMARY"
PKG=org.botlish.counter
TAG=BotlishCounter
. "$here/lib.sh"

note "device: $(shellp getprop ro.product.model) sdk $(shellp getprop ro.build.version.sdk) abilist $(shellp getprop ro.product.cpu.abilist) bridge $(shellp getprop ro.dalvik.vm.native.bridge) page $(shellp getconf PAGE_SIZE)"
# adb root (google_apis images allow it): the app process's maps are root's
# to read.
rooted=0
if adb root >/dev/null 2>&1; then
    adb wait-for-device
    sleep 2
    [[ $(shellp id -u) == 0 ]] && rooted=1
fi
note "  adb root: $rooted"
startCapture
adb uninstall "$PKG" >/dev/null 2>&1 || true
adb install -r "$apk" >"$OUT/install.txt" 2>&1 && pass "install" || { fail "install: $(cat "$OUT/install.txt")"; exit 1; }
adb logcat -c
shellp am start -W -n "$PKG/.MainActivity" >"$OUT/start.txt"
note "  launch: $(grep -E "TotalTime|WaitTime" "$OUT/start.txt" | tr -s ' \n' ' ')"
if waitFor start "$TAG.*counter: ready" 1 60; then
    pass "start: $(grep -o 'counter: ready.*' "$OUT/start.log" | head -1)"
fi
grep -o "environment api.*" "$OUT/start.log" | head -1 | sed 's/^/  /' | tee -a "$SUMMARY"
grep -o "entering counter_main.*" "$OUT/start.log" | head -1 | sed 's/^/  /' | tee -a "$SUMMARY"
grep -q "lib.*pinned yes" "$OUT/start.log" && note "  libcounter.so pinned (RTLD_NODELETE)"
pid=$(appPid)
note "  pid $pid"
# The program runs on SDLThread: the thread that logged the entry and the
# ready line (logcat's thread id), named SDLThread in the process.
tid=$(grep "counter: ready" "$OUT/start.log" | head -1 | awk '{print $4}')
tname=$(shellp cat "/proc/$pid/task/$tid/comm" 2>/dev/null)
[[ $tname == SDLThread ]] && pass "the program runs on SDLThread (tid $tid)" || fail "the program's thread $tid is \"$tname\", not SDLThread"
if (( rooted )); then
    shellp cat "/proc/$pid/maps" >"$OUT/maps.txt"
    note "  mapped: $(grep -o '[^ /]*\.so$' "$OUT/maps.txt" | grep -E 'libcounter|libSDL3|libmain|libndk_translation|libnb' | sort -u | tr '\n' ' ')"
    for lib in libcounter.so libSDL3.so libmain.so; do
        how=$(mapsLibrary "$pid" "$apk" "$lib") && pass "$lib is mapped in the application process, $how" || fail "$lib is not mapped"
    done
else
    note "  maps: not readable without adb root (the entry ran: counter_main's lines above)"
fi
screenshot first

read -r w h <<<"$(screenSize | tr x ' ')"
cx=$((w / 2)) cy=$((h / 2))
note "  screen ${w}x${h}"
shellp input tap $cx $cy
waitFor tap1 "$TAG.*counter: taps 1" 1 20 && pass "a tap counted once (taps 1)"
# The frame follows the log line: a few looks until it is on the screen.
for _ in 1 2 3 4 5 6; do
    sleep 0.5
    screenshot after-tap
    cmp -s "$OUT/first.png" "$OUT/after-tap.png" || break
done
cmp -s "$OUT/first.png" "$OUT/after-tap.png" && fail "the screen did not change after the tap" || pass "the screen changed after the tap"
shellp input swipe $((cx - w / 4)) $cy $((cx + w / 4)) $cy 200
sleep 2
appLog >"$OUT/swipe.log"
(( $(grep -c "counter: taps" "$OUT/swipe.log") == 1 )) && pass "a swipe is no tap" || fail "a swipe counted as a tap"

# The background: the program is told (SDL_ANDROID_BLOCK_ON_PAUSE 0), stops
# drawing and waits in SDL: no CPU while hidden.
shellp input keyevent KEYCODE_HOME
sleep 3
t0=$(cpuTicks "$pid")
sleep 5
t1=$(cpuTicks "$pid")
killed=0
if [[ $(appPid) == "$pid" ]]; then
    note "  background: $((t1 - t0)) clock ticks of CPU in 5 s"
    (( t1 - t0 <= 25 )) && pass "the hidden app is idle ($((t1 - t0)) ticks in 5 s)" || fail "the hidden app used $((t1 - t0)) ticks in 5 s"
    pass "the process survives the background"
elif lmkd=$(lmkdKilled "$pid"); then
    # Android may end a hidden process; the counter keeps no state, so its
    # count starts again in the new process (the 2048 game's save is what
    # survives this: acceptance-2048.sh).
    killed=1
    note "  the system's low-memory killer ended the hidden process: ${lmkd#*lowmemorykiller: }"
else
    fail "the process changed in the background (not by the low-memory killer)"
fi
shellp am start -W -n "$PKG/.MainActivity" >"$OUT/resume.txt"
sleep 3
shellp input tap $cx $cy
if (( killed )); then
    waitFor tap2 "$TAG.*counter: taps 1" 1 30 && pass "a new process after the kill: a tap counted (taps 1)"
    pid=$(appPid)
    tid=$(sdlThread "$pid")
else
    waitFor tap2 "$TAG.*counter: taps 2" 1 20 && pass "back in the foreground: the count kept (taps 2)"
fi
screenshot resumed
# Idle in the foreground: the program waits in SDL_WaitEventTimeout, no
# busy loop (its thread, SDLThread, is measured; the process's other
# threads -- ART's, the renderer's, the native bridge's -- are recorded).
sleep 5
threads "$pid" >"$OUT/fg-threads-0.txt"
t0=$(cpuTicks "$pid")
sleep 5
t1=$(cpuTicks "$pid")
threads "$pid" >"$OUT/fg-threads-1.txt"
sdl=$(threadDelta "$OUT/fg-threads-0.txt" "$OUT/fg-threads-1.txt" "$tid")
note "  foreground idle: $((t1 - t0)) clock ticks of CPU in 5 s; threads: $(busiest "$OUT/fg-threads-0.txt" "$OUT/fg-threads-1.txt")"
(( ${sdl:-999} <= 25 )) && pass "the idle program does not spin (SDLThread: ${sdl:-?} ticks in 5 s)" || fail "the idle program's thread used ${sdl:-?} ticks in 5 s"

# The back key: SDL3 leaves it to the program (SDLK_AC_BACK), which ends its
# loop, closes SDL and returns; counter_main drops the VM, and SDLActivity
# finishes the Activity when SDL_main returns.
shellp input keyevent KEYCODE_BACK
waitFor exit "counter_main returned 0" 1 30 && pass "exit: $(grep -o 'counter: back' "$OUT/exit.log" | head -1); $(grep -o 'counter: done.*' "$OUT/exit.log" | head -1); counter_main returned 0"
for _ in $(seq 1 20); do [[ -z $(appPid) ]] && break; sleep 1; done
[[ -z $(appPid) ]] && note "  the process ended" || note "  the process lives on after the Activity finished (Android keeps it cached)"
stopCapture
c=$(crashes "$OUT/logcat-all.txt")
[[ -z $c ]] && pass "no crash of $PKG" || fail "crash: $c"
o=$(otherCrashes "$OUT/logcat-all.txt")
[[ -z $o ]] || note "  (other processes' crash reports, not the application's: $(echo "$o" | head -3 | tr '\n' ';'))"
note "status $status"
exit $status
