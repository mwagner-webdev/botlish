#!/usr/bin/env bash
# android-acceptance.sh APK EXPECTED OUT -- the Android acceptance run of
# BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md ("Android execution"), on
# the running emulator or device adb sees. EXPECTED is build.sh's output
# directory: the interpreter's oracles (oracle-42.txt for the self-test's
# 400 moves, play-oracle.txt for the played swipes, restart-oracle.txt for
# the next game). OUT receives the logs, screenshots, the view hierarchies
# and summary.txt.
#
#   1. selftest   the JavaScript self-test (src/SelfTest.tsx): failures=0;
#                 its 401 module snapshots and 401 hook states equal the
#                 interpreter's; Hermes; the Botlish instance owned by React
#                 Native's JavaScript thread (mqt_v_js); the libraries
#                 mapped from the APK
#   2. reload     React Native reloaded three times (ReactHost.reload): the
#                 runtime and its TurboModules destroyed and made again, a
#                 new instance each time, each old one destroyed on its own
#                 thread, the self-test passing each time
#   3. gc-stress  the self-test under BOTLISH_NATIVE_GC_STRESS=1: the same
#                 snapshots
#   4. play       the game played by swipes on the screen (input swipe),
#                 a rapid burst included, the app sent to the background and
#                 back, then New game: every swipe applied exactly once, every
#                 snapshot the interpreter's, no second instance
#   5. win, over  the game started one move from 2048 and one move from the
#                 end: the screen shows the win and the game over
#   6. exit       the activity finished with the back key, then the process
#                 stopped: no native crash anywhere in the run
#
# Exit status 1 on any failure (each is a FAIL line in summary.txt).
set -uo pipefail
apk=$(realpath "$1")
expected=$(realpath "$2")
out=$(realpath -m "$3")
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$out"
summary="$out/summary.txt"
: >"$summary"
pkg=com.botlish2048
activity=$pkg/.MainActivity
status=0
note() { echo "$*" | tee -a "$summary"; }
fail() { note "FAIL $*"; status=1; }
pass() { note "ok $*"; }
shellp() { adb shell "$@" | tr -d '\r'; }

# The app's lines since the last clear: the JavaScript console, the
# generated modules' lifecycle (BotlishRN), the activity's own, crashes.
appLog() {
    adb logcat -d -v tag -s ReactNativeJS:V BotlishRN:V Botlish2048:V AndroidRuntime:E DEBUG:V libc:F | tr -d '\r'
}

# Starts the activity with EXTRAS and waits (up to LIMIT s) until COUNT
# lines match PATTERN in the app's log; the log is kept as OUT/NAME.log.
launch() { # NAME PATTERN COUNT LIMIT EXTRAS...
    local name=$1 pattern=$2 count=$3 limit=$4
    shift 4
    adb logcat -c
    shellp am start -W -n "$activity" "$@" | tee "$out/$name.start" | grep -E "TotalTime|WaitTime|Status" || true
    waitFor "$name" "$pattern" "$count" "$limit"
}

waitFor() { # NAME PATTERN COUNT LIMIT
    local name=$1 pattern=$2 count=$3 limit=$4 seen=0
    for _ in $(seq 1 "$limit"); do
        seen=$(appLog | grep -c -E "$pattern" || true)
        (( seen >= count )) && break
        if appLog | grep -q -E "FATAL EXCEPTION|Fatal signal"; then break; fi
        sleep 1
    done
    appLog >"$out/$name.log"
    (( seen >= count )) || { fail "$name: $seen of $count lines matching \"$pattern\" within $limit s"; return 1; }
    return 0
}

crashes() { # LOG
    grep -E "FATAL EXCEPTION|Fatal signal|SIGSEGV|SIGABRT|backtrace:|Abort message" "$1" || true
}

# A swipe across the board (its centre CX, CY; a third of its width D)
# toward DIRECTION (0 left, 1 right, 2 up, 3 down).
cx=0 cy=0 d=0
swipe() { # DIRECTION
    case $1 in
        0) shellp input swipe $((cx + d)) $cy $((cx - d)) $cy 150 ;;
        1) shellp input swipe $((cx - d)) $cy $((cx + d)) $cy 150 ;;
        2) shellp input swipe $cx $((cy + d)) $cx $((cy - d)) 150 ;;
        3) shellp input swipe $cx $((cy - d)) $cx $((cy + d)) 150 ;;
    esac
}

# The snapshots of KIND lines (oracle, hook) of LOG, in their order.
snapshots() { # LOG KIND
    sed -n "s/.*BOTLISH_RN $2 \([0-9]*\) \(2048\/1 .*\)$/\1 \2/p" "$1" | sort -n -k1,1 | cut -d' ' -f2-
}

adb wait-for-device
adb root >/dev/null 2>&1 && sleep 3 && adb wait-for-device
adb logcat -G 16M >/dev/null 2>&1 || true
note "device $(shellp getprop ro.product.model) sdk $(shellp getprop ro.build.version.sdk) abilist $(shellp getprop ro.product.cpu.abilist) native.bridge $(shellp getprop ro.dalvik.vm.native.bridge) page-size $(shellp getconf PAGE_SIZE)"
note "apk $(sha256sum "$apk" | cut -d' ' -f1)"
adb install -r "$apk" | tail -1 | tee -a "$summary"
shellp setprop debug.botlish.rn.trace 1
note "installed abi $(shellp dumpsys package $pkg | sed -n 's/ *primaryCpuAbi=//p' | head -1)"

# ---------------------------------------------------------------- selftest
launch selftest "selftest done" 1 600 --es mode selftest
log="$out/selftest.log"
grep -E "BOTLISH_RN (env|timing|FAIL)" "$log" | sed 's/^/  /' | tee -a "$summary"
if grep -q "selftest done failures=0" "$log"; then pass "selftest: failures=0"; else fail "selftest: $(grep -o 'selftest done failures=[0-9]*' "$log")"; fi
grep -q "env hermes=true" "$log" && pass "selftest: Hermes" || fail "selftest: not Hermes"
snapshots "$log" oracle >"$out/selftest-module.txt"
snapshots "$log" hook >"$out/selftest-hook.txt"
if cmp -s "$out/selftest-module.txt" "$expected/oracle-42.txt"; then
    pass "selftest: $(wc -l <"$out/selftest-module.txt") module snapshots equal the interpreter's"
else
    fail "selftest: the module's snapshots differ from the interpreter's ($(wc -l <"$out/selftest-module.txt") lines)"
    diff "$out/selftest-module.txt" "$expected/oracle-42.txt" | head -5 | tee -a "$summary"
fi
if cmp -s "$out/selftest-hook.txt" "$expected/oracle-42.txt"; then
    pass "selftest: $(wc -l <"$out/selftest-hook.txt") hook states equal the interpreter's"
else
    fail "selftest: the hook's states differ from the interpreter's ($(wc -l <"$out/selftest-hook.txt") lines)"
fi
pid=$(shellp pidof $pkg)
note "process $pid"
shellp ps -T -p "$pid" >"$out/threads.txt"
js=$(awk '$NF == "mqt_v_js" { print $3 }' "$out/threads.txt" | head -1)
for lib in game textkit; do
    owner=$(sed -n "s/.*BotlishRN: $lib: instance [0-9]* created on thread \([0-9]*\).*/\1/p" "$log" | head -1)
    if [[ -n $js && $owner == "$js" ]]; then
        pass "selftest: the $lib instance belongs to React Native's JavaScript thread mqt_v_js ($js)"
    else
        fail "selftest: the $lib instance was created on thread ${owner:-?}, the JavaScript thread is ${js:-?}"
    fi
    calls=$(grep -c "BotlishRN: $lib: [a-zA-Z]* on thread $js\$" "$log" || true)
    other=$(grep "BotlishRN: $lib: [a-zA-Z]* on thread " "$log" | grep -v -c "on thread $js\$" || true)
    note "  $lib: $calls traced calls on the JavaScript thread, $other on any other"
    (( other == 0 && calls > 0 )) || fail "selftest: $lib calls on another thread than the JavaScript thread"
done
shellp cat "/proc/$pid/maps" | grep -E "libgame|libtextkit|libhermes|libappmodules" | awk '{ print $NF }' | sort -u >"$out/maps.txt"
sed 's/^/  mapped /' "$out/maps.txt" | tee -a "$summary"
grep -q libgame "$out/maps.txt" && grep -q libtextkit "$out/maps.txt" && pass "selftest: both Botlish libraries are mapped in the app process" ||
    fail "selftest: a Botlish library is not mapped"
[[ -z $(crashes "$log") ]] || fail "selftest: a crash: $(crashes "$log" | head -3)"

# ------------------------------------------------------------------ reload
for round in 1 2 3; do
    adb logcat -c
    shellp am start -n "$activity" --ez reload true >/dev/null
    waitFor "reload-$round" "selftest done" 1 600 || continue
    log="$out/reload-$round.log"
    grep -q "selftest done failures=0" "$log" && pass "reload $round: the self-test passes again" || fail "reload $round: $(grep -o 'selftest done failures=[0-9]*' "$log")"
    snapshots "$log" oracle | cmp -s - "$expected/oracle-42.txt" && pass "reload $round: the interpreter's snapshots" || fail "reload $round: snapshots differ"
    for lib in game textkit; do
        created=$(sed -n "s/.*BotlishRN: $lib: instance \([0-9]*\) created on thread \([0-9]*\).*/\1 \2/p" "$log" | head -1)
        gone=$(grep -E "BotlishRN: $lib: instance [0-9]+ (destroyed|orphaned)" "$log" | head -2 | sed 's/.*BotlishRN: //')
        note "  $lib: new instance ${created:-none}; ${gone:-no destruction logged}"
        [[ -n $created ]] || fail "reload $round: no new $lib instance"
        grep -q "BotlishRN: $lib: instance [0-9]* destroyed on thread [0-9]* (its thread exits): status 0\|BotlishRN: $lib: instance [0-9]* destroyed on thread [0-9]* (its module was invalidated on its thread): status 0\|BotlishRN: $lib: instance [0-9]* destroyed on thread [0-9]* (its module went on another thread; reaped at this thread's next call): status 0" "$log" ||
            fail "reload $round: the old $lib instance was not destroyed on its own thread"
        grep -q "BotlishRN: $lib: instance .* status [1-9]" "$log" && fail "reload $round: a $lib destruction failed"
    done
    [[ -z $(crashes "$log") ]] || fail "reload $round: a crash"
done
grep -h "BOTLISH_RN diagnostics" "$out"/reload-3.log | sed 's/^/  /' | tee -a "$summary"

# --------------------------------------------------------------- gc stress
shellp am force-stop $pkg
launch gc-stress "selftest done" 1 1800 --es mode selftest --ez gcStress true
log="$out/gc-stress.log"
grep -q "BOTLISH_NATIVE_GC_STRESS=1" "$log" && note "  BOTLISH_NATIVE_GC_STRESS=1 set in the app process"
grep -E "BOTLISH_RN timing" "$log" | sed 's/^/  gc-stress /' | tee -a "$summary"
grep -q "selftest done failures=0" "$log" && pass "gc-stress: the self-test passes" || fail "gc-stress: $(grep -o 'selftest done failures=[0-9]*' "$log")"
snapshots "$log" oracle | cmp -s - "$expected/oracle-42.txt" && pass "gc-stress: the interpreter's snapshots" || fail "gc-stress: snapshots differ"
[[ -z $(crashes "$log") ]] || fail "gc-stress: a crash"

# -------------------------------------------------------------------- play
shellp am force-stop $pkg
launch play "snapshot restart 42" 1 120
shellp uiautomator dump /sdcard/ui.xml >/dev/null
adb pull /sdcard/ui.xml "$out/play-start.xml" >/dev/null
bounds=$(grep -o 'content-desc="board"[^>]*bounds="[^"]*"' "$out/play-start.xml" | sed 's/.*bounds="\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]"/\1 \2 \3 \4/')
read -r x1 y1 x2 y2 <<<"$bounds"
if [[ -z ${y2:-} ]]; then
    fail "play: no board on the screen"
else
    cx=$(( (x1 + x2) / 2 )) cy=$(( (y1 + y2) / 2 )) d=$(( (x2 - x1) / 3 ))
    plays=$(cat "$expected/play-directions.txt")
    first=${plays:0:12} burst=${plays:12:8} last=${plays:20}
    for (( i = 0; i < ${#first}; i++ )); do swipe "${first:i:1}"; sleep 0.6; done
    for (( i = 0; i < ${#burst}; i++ )); do swipe "${burst:i:1}"; done
    sleep 2
    shellp input keyevent KEYCODE_HOME
    sleep 3
    shellp am start -n "$activity" >/dev/null
    sleep 3
    for (( i = 0; i < ${#last}; i++ )); do swipe "${last:i:1}"; sleep 0.6; done
    sleep 1
    adb exec-out screencap -p >"$out/play.png"
    shellp uiautomator dump /sdcard/ui.xml >/dev/null
    adb pull /sdcard/ui.xml "$out/play-end.xml" >/dev/null
    restart=$(grep -o 'content-desc="restart"[^>]*bounds="[^"]*"' "$out/play-end.xml" | sed 's/.*bounds="\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]"/\1 \2 \3 \4/')
    read -r r1 r2 r3 r4 <<<"$restart"
    shellp input tap $(( (r1 + r3) / 2 )) $(( (r2 + r4) / 2 ))
    waitFor play "snapshot restart 43" 1 30
    log="$out/play.log"
    inputs=$(sed -n 's/.*BOTLISH_RN input \([a-z]*\)$/\1/p' "$log" | tr '\n' ' ')
    applied=$(sed -n 's/.*BOTLISH_RN snapshot move \([a-z]*\) 2048.*/\1/p' "$log" | tr '\n' ' ')
    sent=$(echo "$plays" | sed 's/./& /g' | sed 's/0/left/g; s/1/right/g; s/2/up/g; s/3/down/g')
    note "  swipes sent:   $sent"
    note "  inputs read:   $inputs"
    note "  moves applied: $applied"
    [[ "$inputs" == "$sent" ]] && pass "play: every swipe read once, in order (${#plays} swipes, ${#burst} of them in a burst)" || fail "play: the swipes read are not the swipes sent"
    [[ "$applied" == "$inputs" ]] && pass "play: every input applied exactly once" || fail "play: inputs and applied moves differ"
    sed -n 's/.*BOTLISH_RN snapshot \(restart 42\|move [a-z]*\) \(2048\/1 .*\)$/\2/p' "$log" >"$out/play-snapshots.txt"
    cmp -s "$out/play-snapshots.txt" "$expected/play-oracle.txt" && pass "play: $(wc -l <"$out/play-snapshots.txt") snapshots equal the interpreter's" ||
        { fail "play: the snapshots differ from the interpreter's"; diff "$out/play-snapshots.txt" "$expected/play-oracle.txt" | head -4 | tee -a "$summary"; }
    restarted=$(sed -n 's/.*BOTLISH_RN snapshot restart 43 \(2048\/1 .*\)$/\1/p' "$log")
    [[ "$restarted" == "$(cat "$expected/restart-oracle.txt")" ]] && pass "play: New game made the interpreter's game of seed 43" || fail "play: New game"
    created=$(grep -c "BotlishRN: game: instance [0-9]* created" "$log" || true)
    [[ $created == 1 ]] && pass "play: one instance across background and foreground" || fail "play: $created instances created"
    grep -E "BOTLISH_RN latency" "$log" | awk '{ s += $(NF-1); n++ } END { if (n) printf "  input to render: %d swipes, mean %.2f ms\n", n, s / n }' | tee -a "$summary"
    grep -o 'content-desc="score"[^>]*' "$out/play-end.xml" | head -1 | sed 's/^/  /' | tee -a "$summary"
    [[ -z $(crashes "$log") ]] || fail "play: a crash"
fi

# --------------------------------------------------------------- win, over
for case in win over; do
    if [[ $case == win ]]; then
        start="2048/1 0 0 0 0 0 0 1024 1024 0 0 0 0 0 0 0 0 0 0 0 0 0 0" direction=0 label=won
    else
        start="2048/1 7 100 10 1 0 0 2 4 2 4 4 2 4 2 8 16 8 16 32 16 8 0" direction=1 label="game over"
    fi
    shellp am force-stop $pkg
    launch "$case" "snapshot start" 1 120 --es start "'$start'"
    shellp uiautomator dump /sdcard/ui.xml >/dev/null
    adb pull /sdcard/ui.xml "$out/$case-start.xml" >/dev/null
    read -r x1 y1 x2 y2 <<<"$(grep -o 'content-desc="board"[^>]*bounds="[^"]*"' "$out/$case-start.xml" | sed 's/.*bounds="\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]"/\1 \2 \3 \4/')"
    cx=$(( (x1 + x2) / 2 )) cy=$(( (y1 + y2) / 2 )) d=$(( (x2 - x1) / 3 ))
    swipe "$direction"
    waitFor "$case" "snapshot move" 1 30
    sleep 1
    adb exec-out screencap -p >"$out/$case.png"
    shellp uiautomator dump /sdcard/ui.xml >/dev/null
    adb pull /sdcard/ui.xml "$out/$case-end.xml" >/dev/null
    grep -q "content-desc=\"$label\"" "$out/$case-end.xml" && pass "$case: the screen shows \"$label\"" || fail "$case: no \"$label\" on the screen"
    grep -h "BOTLISH_RN snapshot move" "$out/$case.log" | sed 's/.*BOTLISH_RN /  /' | tee -a "$summary"
done

# -------------------------------------------------------------------- exit
adb logcat -c
shellp input keyevent KEYCODE_BACK
sleep 3
shellp am force-stop $pkg
sleep 1
appLog >"$out/exit.log"
[[ -z $(crashes "$out/exit.log") ]] && pass "exit: no crash" || fail "exit: a crash"
all=$(cat "$out"/*.log | grep -c -E "FATAL EXCEPTION|Fatal signal" || true)
[[ $all == 0 ]] && pass "no native crash and no fatal exception in any phase" || fail "$all crash lines across the run"
shellp ls /data/tombstones 2>/dev/null | sed 's/^/  tombstone /' | tee -a "$summary"
note "result: $([[ $status == 0 ]] && echo passed || echo FAILED)"
exit $status
