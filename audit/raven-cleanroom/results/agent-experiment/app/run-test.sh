#!/bin/sh
# run-test.sh -- the headless test of Tasks (test.bot), with an exit status:
# 0 when the program's verdict is "TEST PASS: ...", 1 otherwise.
# (A Botlish program cannot choose its own exit status, so the verdict is
# the program's value, which this script reads.)
#
#   ./run-test.sh            uses ~/inputs/botlish, or $BOTLISH
set -u
cd "$(dirname "$0")"
BOTLISH="${BOTLISH:-$HOME/inputs/botlish}"
out="$("$BOTLISH" -backend cranelift test.bot 2>&1)"
status=$?
printf '%s\n' "$out"
if [ $status -ne 0 ]; then
    echo "run-test.sh: botlish exited with status $status" >&2
    exit 1
fi
if printf '%s\n' "$out" | grep -q '^   value: "TEST PASS: '; then
    exit 0
fi
echo "run-test.sh: the test did not pass" >&2
exit 1
