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

# A continuous capture of the whole log from now on (OUT/logcat-all.txt),
# for crash detection across every phase (a phase clears the log to count
# its own lines). stopCapture ends it.
startCapture() {
    adb logcat -v threadtime >"$OUT/logcat-all.txt" 2>/dev/null &
    capture=$!
}
stopCapture() {
    sleep 1
    kill "$capture" 2>/dev/null || true
    wait "$capture" 2>/dev/null || true
}

# The threads of PID as "TID NAME TICKS" lines.
threads() { # PID
    local t
    for t in $(shellp ls "/proc/$1/task"); do
        echo "$t $(shellp cat "/proc/$1/task/$t/comm" 2>/dev/null | tr ' ' _) $(shellp cat "/proc/$1/task/$t/stat" 2>/dev/null | sed 's/^[0-9]* ([^)]*) //' | awk '{print $12 + $13}')"
    done
}
# The threads that used CPU between two samples, "NAME(TID)=TICKS".
busiest() { # BEFORE AFTER
    join <(sort "$1") <(sort "$2") | awk '{ d = $5 - $3; if (d > 0) printf "%s(%s)=%d ", $2, $1, d }'
}
# The ticks thread TID used between two samples.
threadDelta() { # BEFORE AFTER TID
    join <(sort "$1") <(sort "$2") | awk -v t="$3" '$1 == t { print $5 - $3 }'
}

screenshot() { # NAME
    adb exec-out screencap -p >"$OUT/$1.png" 2>/dev/null || true
}

# Whether Android's low-memory killer ended the application's process PID
# (lmkd's own log line, "Kill 'PKG' (PID)"): a background process Android
# may end whenever it needs the memory -- the emulator images with 16 KiB
# pages run under steady memory pressure. Prints lmkd's line.
lmkdKilled() { # PID (read from the continuous capture: a phase may clear logcat)
    { cat "$OUT/logcat-all.txt" 2>/dev/null; adb logcat -d -v threadtime; } | tr -d '\r' | grep -m1 "lowmemorykiller: Kill '$PKG' ($1)"
}

# The thread id of the application process PID's SDLThread ("" if none).
sdlThread() { # PID
    shellp sh -c "for t in /proc/$1/task/*; do [ \"\$(cat \$t/comm)\" = SDLThread ] && echo \${t##*/}; done" | head -1
}

# Whether the process PID maps the library NAME (lib/arm64-v8a/NAME) of the
# APK: a mapping of the file NAME, or -- a library stored uncompressed and
# loaded from the APK itself, as the generated project packages it -- a
# mapping of base.apk at exactly that entry's data offset (computed here
# from the APK's local header; the 16 KiB-aligned offset zipalign gave it).
# Prints how it is mapped; status 1 when it is not.
mapsLibrary() { # PID APK NAME
    local maps offset
    maps=$(shellp cat "/proc/$1/maps")
    if echo "$maps" | grep -q "/$3\$"; then
        echo "as the file $3"
        return 0
    fi
    offset=$(python3 -I - "$2" "lib/arm64-v8a/$3" <<'PY'
import struct, sys, zipfile
z = zipfile.ZipFile(sys.argv[1])
i = z.getinfo(sys.argv[2])
with open(sys.argv[1], "rb") as f:
    f.seek(i.header_offset)
    h = f.read(30)
    n, m = struct.unpack("<HH", h[26:30])
print("%08x" % (i.header_offset + 30 + n + m) if i.compress_type == 0 else "")
PY
)
    if [[ -n $offset ]] && echo "$maps" | awk -v o="$offset" '$NF ~ /base\.apk$/ && $3 == o { found = 1 } END { exit !found }'; then
        echo "from base.apk at offset 0x$offset (stored uncompressed, loaded in place)"
        return 0
    fi
    return 1
}

# Waits until the device has settled after its boot: boot completed and the
# SIM's state final (READY, LOADED or ABSENT; at most a minute), then ten
# quiet seconds. An emulator's SIM comes up well after the boot, and its
# carrier configuration changes the configuration's mcc and mnc, which
# SDLActivity's manifest does not handle: Android recreates the Activity,
# and SDL 3.4.18's default (recreation not allowed,
# SDL_HINT_ANDROID_ALLOW_RECREATE_ACTIVITY) ends the process ("activity
# finished", System.exit(0)) -- run 4 of the workflow lost its counter's
# start that way.
settle() {
    local s
    for _ in $(seq 1 120); do
        [[ $(shellp getprop sys.boot_completed) == 1 ]] && break
        sleep 1
    done
    for _ in $(seq 1 60); do
        s=$(shellp getprop gsm.sim.state)
        case $s in *READY*|*LOADED*|*ABSENT*) break ;; esac
        sleep 1
    done
    note "  settled: boot completed, SIM \"$(shellp getprop gsm.sim.state)\""
    sleep 10
}

# Whether SDL ended the process because the Activity was recreated while
# SDL_main had finished or was running (SDLActivity's onCreate: "activity
# finished"; the recreation's cause is the configuration change Android
# logs). Prints SDL's line.
recreationEnded() {
    appLog | grep -m1 -E " SDL +: activity finished"
}
