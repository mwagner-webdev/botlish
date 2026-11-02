#!/bin/bash
# run-desktop-test.sh -- Tasks as a real desktop window, on a virtual X11
# display (Xvfb: there is no monitor here), checked two ways:
#
#  1. test_desktop.bot: the scripted check of tasks_check.bot on Raven's
#     desktop configuration (X11 window, Vulkan renderer through Mesa's
#     software driver), synthetic input injected through Raven, plus the
#     rendered frames read back (window.capture).
#  2. From outside, as a person would use it: main.bot -- the application
#     itself -- is started, xdrive.py finds its top-level X11 window by its
#     title "Tasks", types and clicks with real X11 input events (XTEST),
#     takes screenshots (evidence/*.png, and a text rendering on stdout),
#     and closes the window the way a window manager's close button does
#     (WM_DELETE_WINDOW). The program must then end by itself, with exit
#     status 0 and the value the inputs lead to.
#
#   ./run-desktop-test.sh            starts its own Xvfb on :97
#   DISPLAY=:99 ./run-desktop-test.sh -use-display   uses an existing display
set -u
cd "$(dirname "$0")"
BOTLISH="${BOTLISH:-$HOME/inputs/botlish}"
failures=0
note() { printf '%s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*"; failures=$((failures + 1)); }

xvfb_pid=""
if [ "${1:-}" != "-use-display" ]; then
    export DISPLAY=:97
    Xvfb "$DISPLAY" -screen 0 1024x768x24 > /tmp/tasks-xvfb.log 2>&1 &
    xvfb_pid=$!
    trap '[ -n "$xvfb_pid" ] && kill "$xvfb_pid" 2>/dev/null' EXIT
    for _ in $(seq 50); do [ -S /tmp/.X11-unix/X97 ] && break; sleep 0.1; done
fi
note "display: $DISPLAY"
mkdir -p evidence

note "== 1. test_desktop.bot (in-process checks on the desktop configuration)"
out="$("$BOTLISH" -backend cranelift test_desktop.bot 2>&1)"
printf '%s\n' "$out"
printf '%s\n' "$out" | grep -q '^   value: "TEST PASS: ' || fail "test_desktop.bot did not pass"

note "== 2. main.bot driven from outside with real X11 input"
probe="$("$BOTLISH" -backend cranelift layout_probe.bot 2>&1)"
printf '%s\n' "$probe"
at() { printf '%s\n' "$probe" | awk -v n="$1" '$1 == n { print $2, $3 }'; }
input=$(at input); add=$(at add); clear2=$(at clear2); box1=$(at box1)
[ -n "$input" ] && [ -n "$add" ] && [ -n "$clear2" ] && [ -n "$box1" ] || { fail "layout_probe.bot gave no coordinates"; exit 1; }

"$BOTLISH" -backend cranelift main.bot > evidence/main-run.log 2>&1 &
app=$!
python3 -I xdrive.py wait Tasks 120 || fail "no window titled Tasks appeared"
python3 -I xdrive.py list
sleep 1
python3 -I xdrive.py shot Tasks evidence/0-empty.png
note "-- click the input, type 'Buy milk'"
python3 -I xdrive.py click Tasks $input; python3 -I xdrive.py type "Buy milk"; sleep 1
python3 -I xdrive.py shot Tasks evidence/1-typed.png
note "-- click Add"
python3 -I xdrive.py click Tasks $add; sleep 1
python3 -I xdrive.py shot Tasks evidence/2-added.png
note "-- click Add with the input empty (adds nothing)"
python3 -I xdrive.py click Tasks $add; sleep 1
note "-- type 'Write report', press Enter; check 'Buy milk'"
python3 -I xdrive.py click Tasks $input; python3 -I xdrive.py type "Write report"
python3 -I xdrive.py type $'\n'; sleep 1
python3 -I xdrive.py click Tasks $box1; sleep 1
python3 -I xdrive.py shot Tasks evidence/3-two-one-done.png
note "-- click Clear done"
python3 -I xdrive.py click Tasks $clear2; sleep 1
python3 -I xdrive.py shot Tasks evidence/4-cleared.png
note "-- close the window (WM_DELETE_WINDOW)"
python3 -I xdrive.py close Tasks
for _ in $(seq 100); do kill -0 "$app" 2>/dev/null || break; sleep 0.1; done
if kill -0 "$app" 2>/dev/null; then
    fail "main.bot still runs 10 s after its window was closed"
    kill "$app"
fi
wait "$app"; status=$?
note "main.bot exited with status $status; its output:"
cat evidence/main-run.log
[ "$status" -eq 0 ] || fail "main.bot exit status $status"
grep -q '^   value: "closed with 1 tasks, 0 done"$' evidence/main-run.log \
    && note "PASS main.bot ended with the state the inputs lead to: 1 tasks, 0 done" \
    || fail "main.bot did not end with \"closed with 1 tasks, 0 done\""

if [ "$failures" -eq 0 ]; then note "DESKTOP TEST PASS"; exit 0; fi
note "DESKTOP TEST FAIL: $failures"
exit 1
