#!/usr/bin/env bash
# device-builds.sh DIR OUT -- the device builds of BOTLISH-REACT-NATIVE-2048-
# PACKAGE-MILESTONE-1.md ("Device builds"), on the running emulator or device
# adb sees, used as a person uses them: no launch extras. DIR is build.sh's
# output (app-device-plain.apk, app-device-gc-stress.apk); OUT receives the
# logs, screenshots, view hierarchies and summary.txt.
#
# For each build:
#
#   * the APK is the build it says: its package (com.botlish2048, and
#     com.botlish2048.gcstress for gc-stress, installed beside it) and its
#     label;
#   * launched from nothing, the game shows the build's line and the
#     Self-test button; the GC-stress build set BOTLISH_NATIVE_GC_STRESS=1 as
#     its process started (MainApplication);
#   * the button runs the self-test: failures=0 (its module snapshots equal
#     the interpreter's by digest, on the device itself), and the screen
#     says "passed" and whether GC stress is on;
#   * "Back to the game" returns to the board; no crash of the app.
#
# Then the GC-stress build's time per call in the C ABI against the plain
# build's: at least twice as slow is GC stress taking effect in the library.
# Through a native bridge (an x86_64 emulator) the libraries' libc does not
# see the variable, as in android-acceptance.sh's gc-stress phase: NOT
# DEMONSTRATED there, never passed. On a phone (adb over USB) the same
# script demonstrates it.
#
# Exit status 1 on any failure (each is a FAIL line in summary.txt).
set -uo pipefail
dir=$(realpath "$1")
out=$(realpath -m "$2")
mkdir -p "$out"
summary="$out/summary.txt"
: >"$summary"
status=0
note() { echo "$*" | tee -a "$summary"; }
fail() { note "FAIL $*"; status=1; }
pass() { note "ok $*"; }
shellp() { adb shell "$@" | tr -d '\r'; }
build_tools=$(ls -d "${ANDROID_HOME:?set ANDROID_HOME}"/build-tools/* | sort -V | tail -1)

# The app's log since the last clear (JavaScript, the activity, crashes).
appLog() {
    adb logcat -d -v tag -s ReactNativeJS:V BotlishRN:V Botlish2048:V AndroidRuntime:E DEBUG:V libc:F | tr -d '\r'
}
crashes() { # PKG [LOG]: the crash lines of PKG's process
    grep -E "Process: $1, PID|Fatal signal .*, pid [0-9]+ \(${1:0:15}\)|>>> $1 <<<" "${2:--}" || true
}
# The view hierarchy now, as OUT/NAME.xml.
ui() { # NAME
    shellp uiautomator dump /sdcard/ui.xml >/dev/null
    adb exec-out cat /sdcard/ui.xml >"$out/$1.xml"
}
# The text of the view labelled LABEL in OUT/NAME.xml.
textOf() { # NAME LABEL
    grep -o "<node [^>]*content-desc=\"$2\"[^>]*>" "$out/$1.xml" | head -1 | sed -n 's/.* text="\([^"]*\)".*/\1/p'
}
# Taps the centre of the view labelled LABEL in OUT/NAME.xml.
tap() { # NAME LABEL
    local b
    b=$(grep -o "<node [^>]*content-desc=\"$2\"[^>]*>" "$out/$1.xml" | head -1 | sed -n 's/.*bounds="\[\([0-9]*\),\([0-9]*\)\]\[\([0-9]*\),\([0-9]*\)\]".*/\1 \2 \3 \4/p')
    [[ -n $b ]] || return 1
    read -r x1 y1 x2 y2 <<<"$b"
    shellp input tap $(( (x1 + x2) / 2 )) $(( (y1 + y2) / 2 ))
}
# Waits (up to LIMIT s) until OUT/NAME.xml has a view labelled LABEL.
waitView() { # NAME LABEL LIMIT
    for _ in $(seq 1 "$3"); do
        ui "$1"
        grep -q "content-desc=\"$2\"" "$out/$1.xml" && return 0
        sleep 1
    done
    return 1
}
cabi() { # LOG: the game's C ABI microseconds per call in the self-test's timing
    sed -n 's/.*BOTLISH_RN timing game [0-9]* calls: [0-9.]* us per call from JavaScript, \([0-9.]*\) us of it in the C ABI.*/\1/p' "$1" | tail -1
}

adb wait-for-device
note "device $(shellp getprop ro.product.model) sdk $(shellp getprop ro.build.version.sdk) abilist $(shellp getprop ro.product.cpu.abilist) native.bridge $(shellp getprop ro.dalvik.vm.native.bridge) page-size $(shellp getconf PAGE_SIZE)"
declare -A wantPkg=([plain]=com.botlish2048 [gc-stress]=com.botlish2048.gcstress)
declare -A wantLabel=([plain]=Botlish2048 [gc-stress]="2048 GC stress")
declare -A wantLine=([plain]="Device build" [gc-stress]="GC-stress build")
declare -A wantStress=([plain]=off [gc-stress]=on)
for device in plain gc-stress; do
    apk="$dir/app-device-$device.apk"
    badging=$("$build_tools/aapt2" dump badging "$apk")
    pkg=$(sed -n "s/^package: name='\([^']*\)'.*/\1/p" <<<"$badging")
    label=$(sed -n "s/^application-label:'\(.*\)'$/\1/p" <<<"$badging")
    note "$device: apk $(sha256sum "$apk" | cut -d' ' -f1), package $pkg, label \"$label\""
    [[ $pkg == "${wantPkg[$device]}" && $label == "${wantLabel[$device]}" ]] && pass "$device: package and label" ||
        fail "$device: package $pkg label \"$label\", not ${wantPkg[$device]} \"${wantLabel[$device]}\""
    adb install -r "$apk" | tail -1 | tee -a "$summary"
    shellp am force-stop "$pkg"
    adb logcat -c
    shellp monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null
    if waitView "$device-game" self-test 300; then
        pass "$device: launched from nothing, the game shows the Self-test button"
    else
        fail "$device: no Self-test button within 300 s"
        appLog >"$out/$device.log"
        continue
    fi
    line=$(textOf "$device-game" "device build")
    [[ $line == "${wantLine[$device]}" ]] && pass "$device: the game says \"$line\"" || fail "$device: the game says \"$line\", not \"${wantLine[$device]}\""
    if [[ $device == gc-stress ]]; then
        appLog | grep -q "BOTLISH_NATIVE_GC_STRESS=1 (a GC-stress build)" &&
            pass "$device: BOTLISH_NATIVE_GC_STRESS=1 set as the process started" || fail "$device: the variable was not set at start"
    else
        appLog | grep -q "BOTLISH_NATIVE_GC_STRESS" && fail "$device: GC stress set in a plain build" || pass "$device: no GC stress"
    fi
    tap "$device-game" self-test || fail "$device: no Self-test button to tap"
    seen=0
    for _ in $(seq 1 1800); do
        seen=$(appLog | grep -c "selftest done" || true)
        (( seen >= 1 )) && break
        [[ -n $(appLog | crashes "$pkg") ]] && break
        sleep 1
    done
    sleep 2
    appLog >"$out/$device.log"
    (( seen >= 1 )) || fail "$device: the self-test did not finish within 1800 s"
    grep -q "selftest done failures=0" "$out/$device.log" && pass "$device: the self-test passes" ||
        fail "$device: $(grep -o 'selftest done failures=[0-9]*' "$out/$device.log") $(grep 'BOTLISH_RN FAIL' "$out/$device.log" | head -3)"
    grep -q "BOTLISH_RN ok module-matches-interpreter" "$out/$device.log" &&
        pass "$device: the module's snapshots are the interpreter's (digest $(sed -n 's/.*ok module-matches-interpreter digest \([0-9a-f]*\),.*/\1/p' "$out/$device.log"))" ||
        fail "$device: the module's snapshots are not the interpreter's"
    waitView "$device-selftest" back 60 || fail "$device: no way back on the self-test's screen"
    adb exec-out screencap -p >"$out/$device-selftest.png"
    result=$(textOf "$device-selftest" selftest) stress=$(textOf "$device-selftest" "gc stress")
    [[ $result == "Botlish self-test: passed" ]] && pass "$device: the screen says \"$result\"" || fail "$device: the screen says \"$result\""
    [[ $stress == "GC stress: ${wantStress[$device]} (this build)" ]] && pass "$device: the screen says \"$stress\"" || fail "$device: the screen says \"$stress\""
    tap "$device-selftest" back
    waitView "$device-back" board 60 && pass "$device: back to the game" || fail "$device: not back to the game"
    shellp am force-stop "$pkg"
    sleep 1
    appLog >"$out/$device-exit.log"
    [[ -z $(cat "$out/$device.log" "$out/$device-exit.log" | crashes "$pkg") ]] && pass "$device: no crash of the app" || fail "$device: a crash of the app"
done
installed=$(shellp pm list packages com.botlish2048 | sort | tr '\n' ' ')
[[ $installed == *"package:com.botlish2048 "*"package:com.botlish2048.gcstress "* ]] && pass "both builds installed side by side ($installed)" ||
    fail "the builds are not installed side by side ($installed)"

bridged=0
[[ $(shellp getprop ro.product.cpu.abi) != arm64-v8a ]] && bridge=$(shellp getprop ro.dalvik.vm.native.bridge) &&
    [[ -n $bridge && $bridge != 0 ]] && bridged=1
plain=$(cabi "$out/plain.log") stressed=$(cabi "$out/gc-stress.log") undemonstrated=""
if [[ -n $plain && -n $stressed ]]; then
    ratio=$(awk -v a="$stressed" -v b="$plain" 'BEGIN { printf "%.1f", a / b }')
    measured="$stressed us per call in the C ABI, ${ratio}x the plain build's $plain us"
    if awk -v r="$ratio" 'BEGIN { exit !(r >= 2) }'; then
        pass "gc-stress: stress took effect in the library ($measured)"
    elif (( bridged )); then
        undemonstrated="gc-stress"
        note "NOT DEMONSTRATED gc-stress: no sign of stress in the library ($measured): the app's arm64 code runs on the native bridge ($bridge), whose libc does not see the variable"
    else
        fail "gc-stress: no sign of stress in the library ($measured)"
    fi
else
    fail "gc-stress: no C ABI timing to compare (plain ${plain:-none}, gc-stress ${stressed:-none})"
fi
if [[ $status != 0 ]]; then
    note "result: FAILED"
elif [[ -n $undemonstrated ]]; then
    note "result: passed, but NOT DEMONSTRATED on this device: $undemonstrated"
else
    note "result: passed"
fi
exit $status
