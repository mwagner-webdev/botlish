# lib.sh -- shared helpers of the Android acceptance scripts
# (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, "Real Android
# application acceptance"), sourced with PKG (the application ID), TAG (the
# application's log tag), OUT and SUMMARY set. Crash detection names the
# application's own process only (as the React Native acceptance learned:
# another process's crash is recorded, never counted as the application's).
status=0
note() { echo "$*" | tee -a "$SUMMARY"; }
fail() { note "FAIL $*"; status=1; }
pass() { note "ok $*"; }
shellp() { adb shell "$@" | tr -d '\r'; }

# The application's lines since the last clear: its own tag, the generated
# shim's (botlish-android), SDL's, and crash reports.
appLog() {
    adb logcat -d -v threadtime -s "$TAG:V" botlish-android:V SDL:V SDL/APP:V AndroidRuntime:E DEBUG:V libc:F | tr -d '\r'
}
crashes() { # [LOG]
    grep -E "Process: $PKG, PID|Fatal signal .*, pid [0-9]+ \($PKG\)|>>> $PKG <<<|FATAL EXCEPTION.*$PKG" "${1:--}" || true
}
otherCrashes() { # [LOG]
    grep -E "Process: [^,]+, PID|Fatal signal .*, pid [0-9]+ \(" "${1:--}" | grep -v -E "Process: $PKG, PID|\($PKG\)$" || true
}

# Waits up to LIMIT seconds until COUNT lines match PATTERN in the app's
# log (a crash ends the wait); the log is kept as OUT/NAME.log.
waitFor() { # NAME PATTERN COUNT LIMIT
    local name=$1 pattern=$2 count=$3 limit=$4 seen=0
    for _ in $(seq 1 "$limit"); do
        seen=$(appLog | grep -c -E "$pattern" || true)
        (( seen >= count )) && break
        [[ -n $(appLog | crashes) ]] && break
        sleep 1
    done
    appLog >"$OUT/$name.log"
    (( seen >= count )) || { fail "$name: $seen of $count lines matching \"$pattern\" within $limit s"; return 1; }
    return 0
}

# The application's process id ("" when it is not running).
appPid() { shellp pidof "$PKG" | awk '{print $1}'; }

# The CPU time (user + system, clock ticks) the process PID has used.
cpuTicks() { shellp cat "/proc/$1/stat" 2>/dev/null | awk '{print $14 + $15}'; }

# The screen's size in pixels (wm size: its override, else its physical).
screenSize() {
    local size
    size=$(shellp wm size | awk -F': ' '/Override size/ {print $2}')
    [[ -n $size ]] || size=$(shellp wm size | awk -F': ' '/Physical size/ {print $2}')
    echo "$size"
}

screenshot() { # NAME
    adb exec-out screencap -p >"$OUT/$1.png" 2>/dev/null || true
}
