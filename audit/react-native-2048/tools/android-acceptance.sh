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
#                 interpreter's (every run of them: its screen may mount
#                 more than once in one process; splitRuns); Hermes; the Botlish instance owned by React
#                 Native's JavaScript thread (mqt_v_js); the libraries
#                 mapped in the app process (extracted from the APK)
#   2. reload     React Native reloaded three times (ReactHost.reload): the
#                 runtime and its TurboModules destroyed and made again, a
#                 new instance each time, each old one destroyed on its own
#                 thread, the self-test passing each time
#   3. gc-stress  the self-test under BOTLISH_NATIVE_GC_STRESS=1: the same
#                 snapshots, and the C ABI at least twice as slow per call
#                 as without it (stress took effect in the library); NOT
#                 DEMONSTRATED, never passed, where the native bridge keeps
#                 the variable from the library
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
    shellp am start -W -n "$activity" "$@" >"$out/$name.start"
    note "  $name: launch $(grep -E "TotalTime|WaitTime" "$out/$name.start" | tr -s ' \n' ' ')"
    waitFor "$name" "$pattern" "$count" "$limit"
}

waitFor() { # NAME PATTERN COUNT LIMIT
    local name=$1 pattern=$2 count=$3 limit=$4 seen=0
    for _ in $(seq 1 "$limit"); do
        seen=$(appLog | grep -c -E "$pattern" || true)
        (( seen >= count )) && break
        [[ -n $(appLog | crashes) ]] && break
        sleep 1
    done
    appLog >"$out/$name.log"
    (( seen >= count )) || { fail "$name: $seen of $count lines matching \"$pattern\" within $limit s"; return 1; }
    return 0
}

# The app's own crash lines, from LOG or standard input. A crash of another
# process on the device is not the app's (run 11: Google Play services
# crashed on the API 35 16 KiB image, pid 2216, and was counted as the
# app's). Each kind of report names its process: AndroidRuntime's
# "Process: PACKAGE, PID", libc's fatal signal line "pid N (PACKAGE)" (the
# 15 characters of the process name: the whole of com.botlish2048) and
# debuggerd's ">>> PACKAGE <<<".
crashes() { # [LOG]
    grep -E "Process: $pkg, PID|Fatal signal .*, pid [0-9]+ \($pkg\)|>>> $pkg <<<" "${1:--}" || true
}
# Other processes' crash reports (for the record): AndroidRuntime's and
# libc's lines that name a process other than the app.
otherCrashes() { # [LOG]
    grep -E "Process: [^,]+, PID|Fatal signal .*, pid [0-9]+ \(" "${1:--}" |
        grep -v -E "Process: $pkg, PID|\($pkg\)$" || true
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

# The self-test logs one run of KIND lines (oracle, hook: "BOTLISH_RN KIND
# INDEX SNAPSHOT", INDEX from 0) each time its screen mounts, and the screen
# can mount more than once in one JavaScript runtime: on main's f06de8e6 the
# first launch after installation ran it twice in one process, the second
# run beginning before the first had finished (as when Android creates the
# activity again). So the lines are split into runs, each line to the run
# whose next index it is (two mounted screens may log at once), and every
# run is held to the interpreter's game. Writes PREFIX.N for run N (and
# PREFIX.stray for a line no run expects); prints the number of runs and of
# stray lines.
splitRuns() { # LOG KIND PREFIX
    sed -n "s/.*BOTLISH_RN $2 \([0-9]*\) \(2048\/1 .*\)$/\1 \2/p" "$1" | awk -v p="$3" '
        { idx = $1 + 0; s = $0; sub(/^[0-9]+ /, "", s); r = 0
          if (idx == 0) { n++; r = n } else for (k = n; k >= 1; k--) if (want[k] == idx) { r = k; break }
          if (r == 0) { stray++; print s > (p ".stray"); next }
          print s > (p "." r); want[r]++ }
        END { print n + 0, stray + 0 }'
}

# Whether every run of KIND in LOG is the interpreter's game as far as it got
# (a prefix of the oracle: a run whose screen went away stops early), with no
# stray line and at least one run of the whole game. Prints what it found.
oracleRuns() { # LOG KIND PREFIX
    local n stray i lines whole=0 bad=0 total
    total=$(wc -l <"$expected/oracle-42.txt")
    read -r n stray < <(splitRuns "$1" "$2" "$3")
    for i in $(seq 1 "$n"); do
        lines=$(wc -l <"$3.$i")
        head -n "$lines" "$expected/oracle-42.txt" | cmp -s - "$3.$i" || bad=$((bad + 1))
        (( lines == total )) && whole=$((whole + 1))
    done
    echo "$n run(s) of $total, $whole complete, $bad differing, $stray stray line(s)"
    (( n > 0 && whole > 0 && bad == 0 && stray == 0 ))
}

# Whether every self-test run in LOG that finished passed, at least one did,
# and the last run started finished (its "selftest done" after its "env").
selfTestsPassed() { # LOG
    local finished
    finished=$(grep -c "BOTLISH_RN selftest done" "$1" || true)
    (( finished > 0 )) && ! grep "BOTLISH_RN selftest done" "$1" | grep -qv "failures=0$" && lastRunDone "$1"
}
lastRunDone() { # LOG
    awk '/BOTLISH_RN env hermes=/ { e = NR } /BOTLISH_RN selftest done/ { d = NR } END { exit !(e > 0 && d > e) }' "$1"
}

# After the first run finished: if another started meanwhile, wait (up to
# LIMIT s) until the last run started has finished too, and keep the log as
# OUT/NAME.log.
settleRuns() { # NAME LIMIT
    local started
    started=$(appLog | grep -c "BOTLISH_RN env hermes=" || true)
    (( started > 1 )) || return 0
    note "  $1: the self-test started $started times in one process (its screen mounted again); every run is checked"
    for _ in $(seq 1 "$2"); do
        appLog >"$out/$1.log"
        lastRunDone "$out/$1.log" && break
        [[ -n $(crashes "$out/$1.log") ]] && break
        sleep 1
    done
    appLog >"$out/$1.log"
    # What started the activity: kept for the record.
    adb logcat -d -v tag -s ActivityTaskManager:I ActivityManager:I | tr -d '\r' | grep -F "$pkg" >"$out/$1-activity.log" || true
}

adb wait-for-device
adb root >/dev/null 2>&1 && sleep 3 && adb wait-for-device
adb logcat -G 16M >/dev/null 2>&1 || true
note "device $(shellp getprop ro.product.model) sdk $(shellp getprop ro.build.version.sdk) abilist $(shellp getprop ro.product.cpu.abilist) native.bridge $(shellp getprop ro.dalvik.vm.native.bridge) page-size $(shellp getconf PAGE_SIZE)"
note "apk $(sha256sum "$apk" | cut -d' ' -f1)"
adb install -r "$apk" | tail -1 | tee -a "$summary"
# Every call's thread is traced in the played phase only (debug.botlish.rn.
# trace, read once per process): the self-test's timings stay untraced.
shellp setprop debug.botlish.rn.trace 0
note "installed abi $(shellp dumpsys package $pkg | sed -n 's/ *primaryCpuAbi=//p' | head -1)"

# ---------------------------------------------------------------- selftest
launch selftest "selftest done" 1 600 --es mode selftest
settleRuns selftest 600
log="$out/selftest.log"
grep -E "BOTLISH_RN (env|timing|FAIL)" "$log" | sed 's/^/  /' | tee -a "$summary"
if selfTestsPassed "$log"; then pass "selftest: failures=0"; else fail "selftest: $(grep -o 'selftest done failures=[0-9]*' "$log" | tr '\n' ' ')(the last run finished: $(lastRunDone "$log" && echo yes || echo no))"; fi
grep -q "env hermes=true" "$log" && pass "selftest: Hermes" || fail "selftest: not Hermes"
if runs=$(oracleRuns "$log" oracle "$out/selftest-module"); then
    pass "selftest: the module's snapshots equal the interpreter's ($runs)"
else
    fail "selftest: the module's snapshots differ from the interpreter's ($runs)"
    [[ -f $out/selftest-module.1 ]] && diff "$out/selftest-module.1" "$expected/oracle-42.txt" | head -5 | tee -a "$summary"
fi
if runs=$(oracleRuns "$log" hook "$out/selftest-hook"); then
    pass "selftest: the hook's states equal the interpreter's ($runs)"
else
    fail "selftest: the hook's states differ from the interpreter's ($runs)"
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
    diag=$(sed -n "s/.*BOTLISH_RN diagnostics $lib //p" "$log" | tail -1)
    caller=$(echo "$diag" | sed -n 's/^{"library": *"[a-z]*", *"thread": *\([0-9]*\),.*/\1/p')
    calls=$(echo "$diag" | sed -n 's/.*"module": *{[^}]*"calls": *\([0-9]*\)}.*/\1/p')
    note "  $lib: the module's $calls calls made on thread ${caller:-?}"
    [[ -n $js && $caller == "$js" ]] || fail "selftest: $lib was called on thread ${caller:-?}, not the JavaScript thread ${js:-?}"
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
    settleRuns "reload-$round" 600
    log="$out/reload-$round.log"
    selfTestsPassed "$log" && pass "reload $round: the self-test passes again" || fail "reload $round: $(grep -o 'selftest done failures=[0-9]*' "$log" | tr '\n' ' ')"
    runs=$(oracleRuns "$log" oracle "$out/reload-$round-module") && pass "reload $round: the interpreter's snapshots ($runs)" || fail "reload $round: snapshots differ ($runs)"
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
# The Botlish runtime reads BOTLISH_NATIVE_GC_STRESS with getenv when it makes
# an instance's heap; the activity sets it with Os.setenv (gcStress) before
# React Native starts. Whether stress took effect is measured, not assumed: a
# collection before every allocation makes a move several times slower in the
# C ABI (6.2x on the host), so the phase requires at least twice the
# self-test's C ABI time per call.
#
# On a device that runs the arm64 app through Android's native bridge (an
# x86_64 emulator), Os.setenv changes the environment of the libc Java runs
# on, not of the bridge's own arm64 libc the library runs on: run 9 of the
# workflow measured no slowdown at all. The other way to set it, the
# wrap.PACKAGE property, starts the process through a wrapper without the
# native bridge, and the app cannot load its arm64 libraries (run 10:
# "libc++_shared.so is for EM_AARCH64 (183) instead of EM_X86_64 (62)"). So
# there the phase is NOT DEMONSTRATED, said so in the summary and the result,
# never passed: a device that runs arm64 code natively checks it.
bridged=0
[[ $(shellp getprop ro.product.cpu.abi) != arm64-v8a ]] && bridge=$(shellp getprop ro.dalvik.vm.native.bridge) &&
    [[ -n $bridge && $bridge != 0 ]] && bridged=1
shellp am force-stop $pkg
launch gc-stress "selftest done" 1 1800 --es mode selftest --ez gcStress true
settleRuns gc-stress 1800
log="$out/gc-stress.log"
grep -q "BOTLISH_NATIVE_GC_STRESS=1" "$log" && note "  BOTLISH_NATIVE_GC_STRESS=1 set in the app process (Os.setenv)"
grep -E "BOTLISH_RN timing" "$log" | sed 's/^/  gc-stress /' | tee -a "$summary"
selfTestsPassed "$log" && pass "gc-stress: the self-test passes" || fail "gc-stress: $(grep -o 'selftest done failures=[0-9]*' "$log" | tr '\n' ' ')"
runs=$(oracleRuns "$log" oracle "$out/gc-stress-module") && pass "gc-stress: the interpreter's snapshots ($runs)" || fail "gc-stress: snapshots differ ($runs)"
[[ -z $(crashes "$log") ]] || fail "gc-stress: a crash"
cabi() { # LOG: the game's C ABI microseconds per call in the self-test's timing
    sed -n 's/.*BOTLISH_RN timing game [0-9]* calls: [0-9.]* us per call from JavaScript, \([0-9.]*\) us of it in the C ABI.*/\1/p' "$1" | tail -1
}
plain=$(cabi "$out/selftest.log") stressed=$(cabi "$log") undemonstrated=""
if [[ -n $plain && -n $stressed ]]; then
    ratio=$(awk -v a="$stressed" -v b="$plain" 'BEGIN { printf "%.1f", a / b }')
    measured="$stressed us per call in the C ABI, ${ratio}x the self-test's $plain us"
    if awk -v r="$ratio" 'BEGIN { exit !(r >= 2) }'; then
        pass "gc-stress: stress took effect in the library ($measured)"
    elif (( bridged )); then
        undemonstrated="gc-stress"
        note "NOT DEMONSTRATED gc-stress: no sign of stress in the library ($measured): the app's arm64 code runs on the native bridge ($bridge), whose libc does not see the activity's Os.setenv"
    else
        fail "gc-stress: no sign of stress in the library ($measured)"
    fi
else
    fail "gc-stress: no C ABI timing to compare (self-test ${plain:-none}, gc-stress ${stressed:-none})"
fi

# -------------------------------------------------------------------- play
shellp am force-stop $pkg
shellp setprop debug.botlish.rn.trace 1
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
    playPid=$(shellp pidof $pkg)
    playJs=$(shellp ps -T -p "$playPid" | awk '$NF == "mqt_v_js" { print $3 }' | head -1)
    traced=$(grep -c "BotlishRN: game: [a-zA-Z]* on thread $playJs\$" "$log" || true)
    elsewhere=$(grep "BotlishRN: game: [a-zA-Z]* on thread " "$log" | grep -v -c "on thread $playJs\$" || true)
    note "  play: $traced traced calls on the JavaScript thread mqt_v_js ($playJs), $elsewhere on any other"
    (( traced > 0 && elsewhere == 0 )) && pass "play: every call on React Native's JavaScript thread" || fail "play: calls on another thread"
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
shellp setprop debug.botlish.rn.trace 0
adb logcat -c
shellp input keyevent KEYCODE_BACK
sleep 3
shellp am force-stop $pkg
sleep 1
appLog >"$out/exit.log"
[[ -z $(crashes "$out/exit.log") ]] && pass "exit: no crash" || fail "exit: a crash"
all=$(cat "$out"/*.log | crashes | wc -l)
others=$(cat "$out"/*.log | otherCrashes | wc -l)
[[ $all == 0 ]] && pass "no native crash and no fatal exception of the app in any phase" || fail "$all crash lines of the app across the run"
(( others > 0 )) && note "  $others crash lines of other processes on the device (not the app's)"
shellp ls /data/tombstones 2>/dev/null | sed 's/^/  tombstone (any process) /' | tee -a "$summary"
if [[ $status != 0 ]]; then
    note "result: FAILED"
elif [[ -n $undemonstrated ]]; then
    note "result: passed, but NOT DEMONSTRATED on this device: $undemonstrated"
else
    note "result: passed"
fi
exit $status
