#!/usr/bin/env bash
# inside.sh -- what the clean-room consumer does (cleanroom.sh run), as the
# user dev in a container with no network, no Tcl, no Rust and no checkout:
# only ~/inputs/botlish (the single-file compiler), ~/inputs/repo (published
# .botpkg artifacts) and ~/inputs/src/main.bot (its program).
#
#   1. installs the two independently authored libraries and the driver
#      they share with `botlish add`, from the repository directory alone;
#   2. shows the resolved graph (`botlish package graph`) and verifies the
#      installation;
#   3. builds the program as a native executable and runs it: both
#      libraries' tasks under the one driver the program installs (the
#      executable prints nothing of its own: its value, the trace, is read
#      through the driver protocol, BOTLISH_NATIVE_RESULT;
#      PROGRAM-OUTPUT-MILESTONE-1.md);
#   4. adds `future`, which locks another release of the driver: a
#      DEPENDENCY-CONFLICT, and the installation unchanged.
#
# Writes ~/out/transcript.txt and ~/out/checks.txt; exit status 0 when every
# check passed.
set -uo pipefail
out=$HOME/out
mkdir -p "$out"
exec > >(tee "$out/transcript.txt") 2>&1
botlish=$HOME/inputs/botlish
repo=$HOME/inputs/repo
app=$HOME/app
failed=0
check() {
  local what=$1; shift
  if "$@"; then echo "PASS $what" >> "$out/checks.txt"; else echo "FAIL $what" >> "$out/checks.txt"; failed=1; fi
}
echo "== the clean room"
echo "tclsh: $(command -v tclsh tclsh9.0 || echo none); cargo: $(command -v cargo || echo none); rustc: $(command -v rustc || echo none)"
echo "network: $(cat /sys/class/net/*/operstate 2>/dev/null | tr '\n' ' ')"
ls "$repo"
mkdir -p "$app"
cp "$HOME/inputs/src/main.bot" "$app/"
cd "$app"
echo "== botlish add"
for name in beats probes event_loop_linux; do
  "$botlish" add "$name" -repository "$repo"; echo "status $?"
done
check "botlish.json has the three dependencies" grep -q '"probes": "1.0.0"' botlish.json
echo "== the installed graph"
cat .bot_modules/.targets/linux-x86_64/.graph
check "one driver instance, used by the application, beats and probes" \
  grep -qx 'application beats event_loop_linux probes' .bot_modules/.targets/linux-x86_64/.graph
check "no package holds a .bot_modules of its own" bash -c '! find .bot_modules -mindepth 2 -name .bot_modules | grep -q .'
echo "== botlish package graph"
"$botlish" package graph | tee "$out/graph.txt"
check "the graph shows the driver shared" grep -q 'shared: one instance, event_loop_linux, for the application, beats, probes' "$out/graph.txt"
echo "== botlish verify"
"$botlish" verify -repository "$repo"; check "verify is clean" test $? -eq 0
echo "== native executable"
"$botlish" -warnings error -emit-native-executable main.bot; check "the program builds as a native executable" test -x ./main
BOTLISH_NATIVE_RESULT="$out/result.txt" ./main
tr -d '\\{}' <"$out/result.txt" | tr -s ' \n' ' ' | sed 's/ $//' | tee "$out/run.txt"; echo
check "beats ran under the shared driver" grep -q 'beats: the driver.s clock never went back' "$out/run.txt"
check "probes ran under the shared driver" grep -q 'probes: every endpoint was empty, and closed' "$out/run.txt"
echo "== a library locking another release of the driver"
before=$(find .bot_modules -type f -exec sha256sum {} + | sort | sha256sum)
"$botlish" add future -repository "$repo" 2> "$out/conflict.txt"; status=$?
cat "$out/conflict.txt"
check "add future fails" test $status -eq 1
check "the failure is a DEPENDENCY-CONFLICT" grep -q '(PM DEPENDENCY-CONFLICT)' "$out/conflict.txt"
check "it names future's lock" grep -q 'future 1.0.0 locks event_loop_linux 0.6.0 (the project -> future 1.0.0)' "$out/conflict.txt"
after=$(find .bot_modules -type f -exec sha256sum {} + | sort | sha256sum)
check "the installation is unchanged" test "$before" = "$after"
echo "== checks"
cat "$out/checks.txt"
exit $failed
