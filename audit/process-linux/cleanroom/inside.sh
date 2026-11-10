#!/usr/bin/env bash
# inside.sh -- what the clean-room consumer does (cleanroom.sh run), as the
# user dev in a container with no network, holding no Tcl, Botlish checkout
# or adapter source: only ~/inputs/botlish (the single-file compiler),
# ~/inputs/repo (published .botpkg artifacts and their provenance records),
# ~/inputs/src (its program: main.bot, fdcount.bot) and ~/inputs/child (a
# deterministic helper executable).
#
#   1. installs process_linux, the driver and ticker with `botlish add`,
#      from the repository directory alone; checks the graph (one instance
#      of the driver, shared) and verifies the installation and the
#      artifacts' provenance records; a target the package does not name is
#      UNSUPPORTED;
#   2. builds the program as a native executable (the system linker,
#      -warnings error) and checks it holds the released adapter (no test
#      probe);
#   3. runs the workload and the failure cases (app/main.bot) and checks
#      what each reports, and from outside that every process it started is
#      gone.
#
# Writes ~/out/transcript.txt, ~/out/checks.txt and ~/out/facts.txt; exit
# status 0 when every check passed.
set -uo pipefail
out=$HOME/out
mkdir -p "$out"
exec > >(tee "$out/transcript.txt") 2>&1
botlish=$HOME/inputs/botlish
repo=$HOME/inputs/repo
helper=$HOME/inputs/child
app=$HOME/app
failed=0
check() {
  local what=$1; shift
  if "$@"; then echo "PASS $what" >> "$out/checks.txt"; else echo "FAIL $what" >> "$out/checks.txt"; failed=1; fi
}
has() { grep -qF -- "$2" "$1"; }
fact() { echo "$*" >> "$out/facts.txt"; }
# A process is gone when /proc has no entry, or a zombie no one reaps (the
# container's PID 1 is this script's shell).
gone() { [[ ! -e /proc/$1 ]] || [[ $(awk '{print $3}' "/proc/$1/stat" 2>/dev/null) == Z ]]; }

echo "== the clean room"
for tool in tclsh tclsh9.0 cargo rustc python3 git curl; do
  echo "$tool: $(command -v $tool || echo none)"
done
check "no Tcl, Rust, Python or Git in the clean room" bash -c '! command -v tclsh tclsh9.0 cargo rustc python3 git >/dev/null'
check "no Botlish checkout or adapter source in the clean room" bash -c '! find / -xdev \( -name main.tcl -o -name process_linux.c -o -name event_loop_linux.c \) 2>/dev/null | grep -q .'
check "no network" bash -c '! (exec 3<>/dev/tcp/1.1.1.1/443) 2>/dev/null'
"$botlish" -version | tee "$out/version.txt"
fact "compiler $(sha256sum "$botlish" | cut -d' ' -f1) $(stat -c %s "$botlish") bytes"
(cd "$repo" && sha256sum ./*.botpkg) | tee -a "$out/facts.txt"
fact "cc: $(cc --version | head -1)"
fact "kernel: $(uname -r)"
fact "glibc: $(ldd --version | head -1)"

mkdir -p "$app" "$app/a" "$app/b"
cp "$HOME"/inputs/src/*.bot "$app/"
cd "$app"
echo "== botlish add"
for name in process_linux event_loop_linux ticker; do
  "$botlish" add "$name" -repository "$repo" -target linux-x86_64; echo "status $?"
done
check "botlish.json requests process_linux, the driver and ticker" bash -c 'grep -q "\"process_linux\": \"0.1\"" botlish.json && grep -q "\"event_loop_linux\": \"0.5\"" botlish.json && grep -q "\"ticker\": \"1.0\"" botlish.json'
echo "== the installed graph"
graph=.bot_modules/.targets/linux-x86_64/.graph
cat "$graph"
check "the application uses one instance each of the driver, process_linux and ticker" grep -qx 'application event_loop_linux process_linux ticker' "$graph"
check "process_linux uses the application's driver" grep -qx 'package process_linux event_loop_linux' "$graph"
check "ticker uses the same driver" grep -qx 'package ticker event_loop_linux' "$graph"
check "every package is installed once, none holds a .bot_modules of its own" bash -c 'test "$(ls .bot_modules/.targets/linux-x86_64 | sort | tr "\n" " ")" = "event_loop_linux process_linux ticker " && ! find .bot_modules -mindepth 2 -name .bot_modules | grep -q .'
"$botlish" package graph | tee "$out/graph.txt"
check "the graph reports the driver shared" grep -q 'shared: one instance, event_loop_linux' "$out/graph.txt"
echo "== botlish verify"
"$botlish" verify -repository "$repo"; check "verify is clean" test $? -eq 0
echo "== provenance records"
for f in process_linux-0.1.0 event_loop_linux-0.5.0; do
  if [[ -f $repo/$f.provenance.json ]]; then
    "$botlish" package inspect "$repo/$f.botpkg" -provenance "$repo/$f.provenance.json" > "$out/provenance-$f.txt" 2>&1
    check "the provenance record of $f matches its artifact" test $? -eq 0
  fi
done
echo "== a target the package does not support"
mkdir -p "$HOME/other" && cd "$HOME/other"
"$botlish" add process_linux -repository "$repo" -target linux-aarch64 > "$out/unsupported.txt" 2>&1; status=$?
cat "$out/unsupported.txt"
check "process_linux for linux-aarch64 is refused as unsupported, nothing installed" bash -c "test $status -ne 0 && grep -q UNSUPPORTED '$out/unsupported.txt' && test ! -d .bot_modules/process_linux"
cd "$app"

echo "== native executable"
start=$(date +%s.%N)
"$botlish" -warnings error -emit-native-executable main.bot; status=$?
end=$(date +%s.%N)
check "the program builds as a native executable, warning-free" test $status -eq 0 -a -x ./main
fact "build: $(awk "BEGIN {print $end - $start}") s, executable $(stat -c %s main) bytes"
check "the executable holds the adapter once" test "$(nm main | grep -c ' T pl_spawn$')" = 1
check "the executable holds no test probe (the released adapter)" bash -c '! nm main | grep -q " T pl_t_"'
check "the executable depends on the C library only" bash -c '! (ldd ./main | grep -Ev "linux-vdso|libc.so|libm.so|libgcc_s|ld-linux|libpthread|libdl|librt|libutil" | grep -q .)'
ldd main | tee "$out/ldd.txt"

echo "== the workload"
./main "$helper" "$app/a" "$app/b" > "$out/workload.txt" 2>&1; echo "exit $?" >> "$out/workload.txt"
cat "$out/workload.txt"
w=$out/workload.txt
check "workload: A and B started without a shell" has "$w" "spawned A and B without a shell"
check "workload: A ran in its own working directory" has "$w" "A stdout chunk: cwd $app/a"
check "workload: B ran in another, with its own environment" bash -c "grep -qF 'cwd $app/b' '$w' && grep -qF 'env CLEANROOM_JOB=job-b' '$w'"
check "workload: stdout and stderr streamed concurrently" bash -c "grep -qF 'A stderr chunk: warning from A' '$w' && grep -qF 'A stdout bytes 103, stderr bytes 15' '$w'"
check "workload: stdin written incrementally and closed" has "$w" "A's stdin: 3 lines written, closed"
check "workload: A ended normally" has "$w" "A ended exited 0"
check "workload: B terminated gracefully, escalated to SIGKILL at its grace period" bash -c "grep -qF 'B ended signal 9' '$w' && grep -qF 'B escalated at the grace period: yes' '$w'"
check "workload: B's stream ended once its group was killed" grep -Eq '^B stdout chunks [0-9]+, its end of file once the group was killed$' "$w"
check "workload: the identity is stale after release" has "$w" "A's identity after release: stale"
check "workload: ticker's task (another library, the same loop) kept time" bash -c "grep -Eq '^ticker ticks ([1-9][0-9]+)$' '$w' && grep -qF 'ticker kept time (no tick 40 ms late): yes' '$w'"
check "workload: exact arguments (empty, spaces, \$HOME and *.txt unexpanded, UTF-8)" bash -c "grep -qx 'arg 2 -' '$w' && grep -qx 'arg 3 74776f20776f726473' '$w' && grep -qx 'arg 4 24484f4d45' '$w' && grep -qx 'arg 5 2a2e747874' '$w' && grep -qx 'arg 6 68c3a96c6c6f' '$w'"
check "workload: nothing supervised, watched, unreaped or held at the end" has "$w" "end: owned 0, dying 0, watches 0, children 0, adapter descriptors 0"
check "workload: no descriptor or registration left" has "$w" "end: descriptors delta 0, registrations delta 0"
check "workload: one escalation, three releases" has "$w" "end: escalations 1, released 3"
check "workload: the program ended normally" has "$w" "exit 0"
bpid=$(sed -n 's/^B pid \([0-9]*\)$/\1/p' "$w")
desc=$(sed -n 's/^desc \([0-9]*\)$/\1/p' "$w" | head -1)
fact "workload: B pid $bpid, its descendant $desc"
check "workload: B is gone" gone "$bpid"
check "workload: B's descendant (in its group, ignoring SIGTERM) is gone" gone "$desc"

echo "== the failure cases"
./main "$helper" "$app/a" "$app/b" failures > "$out/failures.txt" 2>&1; echo "exit $?" >> "$out/failures.txt"
cat "$out/failures.txt"
f=$out/failures.txt
check "failures: a missing executable fails at exec (ENOENT)" bash -c "sed -n 1p '$f' | grep -qx 'launch failed at exec: errno 2'"
check "failures: a missing working directory fails in the parent (ENOENT)" has "$f" "launch failed at working directory: errno 2"
check "failures: a non-executable file fails at exec (EACCES)" has "$f" "launch failed at exec: errno 13"
check "failures: an invalid environment name is refused before starting" has "$f" "refused before starting: environment name: contains '='"
check "failures: a nonzero exit is an outcome" has "$f" "a failing child is an outcome, not an error: exited 5"
check "failures: a released identity is stale for wait and signal" bash -c "grep -qF 'wait through a released identity: stale' '$f' && grep -qF 'signal through a released identity: stale' '$f'"
check "failures: the old identity never reaches the slot's new child" bash -c "grep -qF 'the old identity does not reach the new child: stale' '$f' && grep -qF 'the new child unaffected: yes' '$f'"
check "failures: nothing left" bash -c "grep -qF 'end: owned 0, dying 0, watches 0, children 0, adapter descriptors 0' '$f' && grep -qF 'end: descriptors delta 0, registrations delta 0' '$f'"

echo "== checks"
cat "$out/checks.txt"
echo "passed $(grep -c '^PASS' "$out/checks.txt"), failed $(grep -c '^FAIL' "$out/checks.txt")"
exit $failed
