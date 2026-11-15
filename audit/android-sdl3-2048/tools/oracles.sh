#!/usr/bin/env bash
# oracles.sh OUT -- the interpreter's expectations of the 2048 acceptance
# (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md, "Deterministic 2048
# oracle"), from game2048_play (tools/oracle.tcl), into OUT:
#
#   play-directions.txt  the swipes the acceptance plays (0 left, 1 right,
#                        2 up, 3 down): twelve, a burst of eight, four after
#                        the background
#   oracle-42.txt        seed 42's new game and one snapshot per swipe
#   win-start.txt, win-oracle.txt    a board one move (left) from 2048
#   over-start.txt, over-oracle.txt  a board one move (right) from the end
#   selftest-oracle.txt  the React Native self-test's 401 snapshots (seed 42,
#                        its 400 moves): game2048_play's rules, unchanged
set -euo pipefail
out=$(realpath -m "${1:?usage: oracles.sh OUT}")
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
mkdir -p "$out"
plays=013201320231023102130213
printf '%s\n' "$plays" >"$out/play-directions.txt"
tclsh9.0 "$here/oracle.tcl" 42 "$plays" >"$out/oracle-42.txt"
win="2048/1 12345 0 0 0 0 0 1024 1024 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
over="2048/1 12345 1000 0 0 0 0 8 4 2 4 16 2 4 2 32 4 2 4 64 128 256 0"
printf '%s\n' "$win" >"$out/win-start.txt"
printf '%s\n' "$over" >"$out/over-start.txt"
tclsh9.0 "$here/oracle.tcl" -from "$win" 0 >"$out/win-oracle.txt"
tclsh9.0 "$here/oracle.tcl" -from "$over" 1 >"$out/over-oracle.txt"
directions=$(sed -n "s/^  '\([0-3]*\)';$/\1/p" "$root/examples/react-native/app/src/directions.ts")
tclsh9.0 "$here/oracle.tcl" 42 "$directions" >"$out/selftest-oracle.txt"
for f in oracle-42 win-oracle over-oracle selftest-oracle; do
    echo "$f: $(wc -l <"$out/$f.txt") snapshots, last $(tail -1 "$out/$f.txt")"
done
