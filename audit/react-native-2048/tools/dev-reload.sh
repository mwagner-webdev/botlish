#!/usr/bin/env bash
# dev-reload.sh DEBUG-APK APP OUT -- React Native's development reload of
# BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md ("Android execution"): the
# app's debug build, its JavaScript served by Metro from APP (an app
# directory with the generated packages installed), reloaded the way a
# developer does (the R key twice: React Native's DevSupport reload).
#
#   1. Metro started on this machine, the device's port 8081 reversed to it;
#   2. the debug APK started in self-test mode: the bundle from Metro, the
#      self-test passing;
#   3. two development reloads: each time the JavaScript runtime and its
#      TurboModules are made again, a new Botlish instance created, the old
#      one destroyed on its own thread, the self-test passing again.
#
# OUT receives Metro's log, each phase's app log and summary.txt; exit status
# 1 on any failure.
set -uo pipefail
apk=$(realpath "$1")
app=$(realpath "$2")
out=$(realpath -m "$3")
mkdir -p "$out"
summary="$out/summary.txt"
: >"$summary"
pkg=com.botlish2048
status=0
note() { echo "$*" | tee -a "$summary"; }
fail() { note "FAIL $*"; status=1; }
pass() { note "ok $*"; }
shellp() { adb shell "$@" | tr -d '\r'; }
appLog() { adb logcat -d -v tag -s ReactNativeJS:V BotlishRN:V AndroidRuntime:E DEBUG:V | tr -d '\r'; }
waitFor() { # NAME PATTERN LIMIT
    local name=$1 pattern=$2 limit=$3
    for _ in $(seq 1 "$limit"); do
        appLog | grep -q -E "$pattern" && break
        sleep 1
    done
    appLog >"$out/$name.log"
    grep -q -E "$pattern" "$out/$name.log" || { fail "$name: no \"$pattern\" within $limit s"; return 1; }
}

(cd "$app" && exec npx --no-install react-native start --port 8081 >"$out/metro.log" 2>&1) &
metro=$!
trap 'kill $metro 2>/dev/null; pkill -f "react-native start" 2>/dev/null' EXIT
for _ in $(seq 1 120); do
    [[ $(curl -s http://localhost:8081/status 2>/dev/null) == packager-status:running ]] && break
    sleep 1
done
[[ $(curl -s http://localhost:8081/status 2>/dev/null) == packager-status:running ]] && pass "Metro is serving the app" || { fail "Metro did not start"; tail -20 "$out/metro.log"; exit 1; }
adb reverse tcp:8081 tcp:8081
adb install -r "$apk" | tail -1 | tee -a "$summary"
shellp am force-stop $pkg
adb logcat -c
shellp am start -W -n $pkg/.MainActivity --es mode selftest | grep -E "TotalTime|Status" | tee -a "$summary"
if waitFor debug-start "selftest done" 600; then
    grep -q "selftest done failures=0" "$out/debug-start.log" && pass "debug build: the self-test passes with the bundle from Metro" ||
        fail "debug build: $(grep -o 'selftest done failures=[0-9]*' "$out/debug-start.log")"
    grep -q "env hermes=true" "$out/debug-start.log" && pass "debug build: Hermes" || fail "debug build: not Hermes"
fi
for round in 1 2; do
    adb logcat -c
    # React Native's development reload: R twice (DoubleTapReloadRecognizer).
    shellp input keyevent 46 46
    waitFor "dev-reload-$round" "selftest done" 600 || continue
    log="$out/dev-reload-$round.log"
    grep -q "selftest done failures=0" "$log" && pass "development reload $round: the self-test passes again" ||
        fail "development reload $round: $(grep -o 'selftest done failures=[0-9]*' "$log")"
    for lib in game textkit; do
        created=$(sed -n "s/.*BotlishRN: $lib: instance \([0-9]*\) created on thread \([0-9]*\).*/instance \1 on thread \2/p" "$log" | head -1)
        gone=$(grep -E "BotlishRN: $lib: instance [0-9]+ (destroyed|orphaned)" "$log" | sed 's/.*BotlishRN: //' | head -2 | tr '\n' ';')
        note "  $lib: new ${created:-none}; ${gone:-no destruction logged}"
        [[ -n $created ]] || fail "development reload $round: no new $lib instance"
        grep -E -q "BotlishRN: $lib: instance [0-9]+ destroyed on thread [0-9]+ \((its thread exits|its module was invalidated on its thread|its module went on another thread; reaped at this thread's next call)\): status 0" "$log" ||
            fail "development reload $round: the old $lib instance was not destroyed on its own thread"
    done
    grep -E -q "FATAL EXCEPTION|Fatal signal" "$log" && fail "development reload $round: a crash"
done
note "result: $([[ $status == 0 ]] && echo passed || echo FAILED)"
exit $status
