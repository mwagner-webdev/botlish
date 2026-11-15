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
shellp cat "/proc/$pid/maps" | grep -o '[^ /]*\.so$' | grep -E 'libcounter|libSDL3|libmain|libndk_translation|libnb' | sort -u >"$OUT/maps.txt"
note "  mapped: $(tr '\n' ' ' <"$OUT/maps.txt")"
grep -q libcounter "$OUT/maps.txt" && pass "libcounter.so is mapped in the application process" || fail "libcounter.so is not mapped"
screenshot first

read -r w h <<<"$(screenSize | tr x ' ')"
cx=$((w / 2)) cy=$((h / 2))
note "  screen ${w}x${h}"
shellp input tap $cx $cy
waitFor tap1 "$TAG.*counter: taps 1" 1 20 && pass "a tap counted once (taps 1)"
screenshot after-tap
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
note "  background: $((t1 - t0)) clock ticks of CPU in 5 s"
(( t1 - t0 <= 25 )) && pass "the hidden app is idle ($((t1 - t0)) ticks in 5 s)" || fail "the hidden app used $((t1 - t0)) ticks in 5 s"
[[ $(appPid) == "$pid" ]] && pass "the process survives the background" || fail "the process changed in the background"
shellp am start -W -n "$PKG/.MainActivity" >"$OUT/resume.txt"
sleep 3
shellp input tap $cx $cy
waitFor tap2 "$TAG.*counter: taps 2" 1 20 && pass "back in the foreground: the count kept (taps 2)"
screenshot resumed
# Idle in the foreground: waits in SDL_WaitEventTimeout, no busy loop.
t0=$(cpuTicks "$pid")
sleep 5
t1=$(cpuTicks "$pid")
note "  foreground idle: $((t1 - t0)) clock ticks of CPU in 5 s"
(( t1 - t0 <= 50 )) && pass "the idle app does not spin ($((t1 - t0)) ticks in 5 s)" || fail "the idle app used $((t1 - t0)) ticks in 5 s"

# The back key finishes the Activity: SDL sends QUIT and TERMINATING, the
# program closes SDL and returns, counter_main drops the VM, SDLThread ends.
shellp input keyevent KEYCODE_BACK
waitFor exit "counter_main returned 0" 1 30 && pass "exit: $(grep -o 'counter: done.*' "$OUT/exit.log" | head -1); counter_main returned 0"
for _ in $(seq 1 20); do [[ -z $(appPid) ]] && break; sleep 1; done
[[ -z $(appPid) ]] && note "  the process ended" || note "  the process lives on after the Activity finished (Android keeps it cached)"
adb logcat -d >"$OUT/logcat-all.txt"
c=$(crashes "$OUT/logcat-all.txt")
[[ -z $c ]] && pass "no crash of $PKG" || fail "crash: $c"
o=$(otherCrashes "$OUT/logcat-all.txt")
[[ -z $o ]] || note "  (other processes' crash reports, not the application's: $(echo "$o" | head -3 | tr '\n' ';'))"
note "status $status"
exit $status
