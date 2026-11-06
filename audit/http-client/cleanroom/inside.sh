#!/usr/bin/env bash
# inside.sh -- what the clean-room consumer does (cleanroom.sh run), as the
# user dev in a container holding no Tcl, Rust, Cargo, CMake, Botlish
# checkout or BoringSSL source: only ~/inputs/botlish (the single-file
# compiler), ~/inputs/repo (published .botpkg artifacts and their
# provenance records), ~/inputs/src/main.bot (its program),
# ~/inputs/test-ca.pem (its own trust anchor for the local peers) and
# ~/inputs/peers.env (where the peers listen).
#
#   1. installs http, the driver and feeds with `botlish add`, from the
#      repository directory alone; shows and checks the graph (one instance
#      of each package) and verifies the installation and the artifacts'
#      provenance records;
#   2. builds the program as a native executable (the system linker) and
#      checks it holds one copy of the HTTP unit and one BoringSSL provider;
#   3. runs workloads A-E (app/main.bot) and checks what each reports;
#   4. adds oldtls, which locks another BoringSSL release: a
#      DEPENDENCY-CONFLICT, and the installation unchanged.
#
# Writes ~/out/transcript.txt, ~/out/checks.txt and ~/out/facts.txt; exit
# status 0 when every check passed.
set -uo pipefail
out=$HOME/out
mkdir -p "$out"
exec > >(tee "$out/transcript.txt") 2>&1
botlish=$HOME/inputs/botlish
repo=$HOME/inputs/repo
app=$HOME/app
ca=$HOME/inputs/test-ca.pem
# shellcheck disable=SC1091
source "$HOME/inputs/peers.env"
failed=0
check() {
  local what=$1; shift
  if "$@"; then echo "PASS $what" >> "$out/checks.txt"; else echo "FAIL $what" >> "$out/checks.txt"; failed=1; fi
}
has() { grep -qF -- "$2" "$1"; }
fact() { echo "$*" >> "$out/facts.txt"; }

echo "== the clean room"
for tool in tclsh tclsh9.0 cargo rustc cmake ninja python3 git; do
  echo "$tool: $(command -v $tool || echo none)"
done
check "no Tcl, Rust, Cargo, CMake or Ninja in the clean room" bash -c '! command -v tclsh tclsh9.0 cargo rustc cmake ninja >/dev/null'
check "no Botlish checkout or BoringSSL source in the clean room" bash -c '! find / -xdev \( -name main.tcl -o -name ssl_lib.cc -o -name Cargo.toml \) 2>/dev/null | grep -q .'
cat "$HOME/inputs/system-ca.txt" 2>/dev/null || echo "operator CA: none"
"$botlish" -version | tee "$out/version.txt"
fact "compiler $(sha256sum "$botlish" | cut -d' ' -f1) $(stat -c %s "$botlish") bytes"
(cd "$repo" && sha256sum ./*.botpkg) | tee -a "$out/facts.txt"
cc --version | head -1
fact "cc: $(cc --version | head -1)"
fact "libstdc++: $(ls /usr/lib/x86_64-linux-gnu/libstdc++.so* 2>/dev/null | tr '\n' ' ')"

mkdir -p "$app"
cp "$HOME/inputs/src/main.bot" "$app/"
cd "$app"
echo "== botlish add"
for name in http event_loop_linux feeds; do
  "$botlish" add "$name" -repository "$repo" -target linux-x86_64; echo "status $?"
done
check "botlish.json requests http, the driver and feeds" bash -c 'grep -q "\"http\": \"0.1\"" botlish.json && grep -q "\"event_loop_linux\": \"0.3\"" botlish.json && grep -q "\"feeds\": \"1.0\"" botlish.json'
echo "== the installed graph"
graph=.bot_modules/.targets/linux-x86_64/.graph
cat "$graph"
check "the application uses one instance each of the driver, feeds and http" grep -qx 'application event_loop_linux feeds http' "$graph"
check "feeds uses the application's driver and http" grep -qx 'package feeds event_loop_linux http' "$graph"
check "http uses the one driver and the one BoringSSL provider" grep -qx 'package http boringssl event_loop_linux' "$graph"
check "every package is installed once, no package holds a .bot_modules of its own" bash -c 'test "$(ls .bot_modules/.targets/linux-x86_64 | sort | tr "\n" " ")" = "boringssl event_loop_linux feeds http " && ! find .bot_modules -mindepth 2 -name .bot_modules | grep -q .'
"$botlish" package graph | tee "$out/graph.txt"
check "the graph reports the driver shared" grep -q 'shared: one instance, event_loop_linux' "$out/graph.txt"
echo "== botlish verify"
"$botlish" verify -repository "$repo"; check "verify is clean" test $? -eq 0
echo "== provenance records"
for f in boringssl-0.20261020.0 http-0.1.0; do
  if [[ -f $repo/$f.provenance.json ]]; then
    "$botlish" package inspect "$repo/$f.botpkg" -provenance "$repo/$f.provenance.json" > "$out/provenance-$f.txt" 2>&1
    check "the provenance record of $f matches its artifact" test $? -eq 0
  fi
done

echo "== native executable"
start=$(date +%s.%N)
"$botlish" -warnings error -emit-native-executable main.bot; status=$?
end=$(date +%s.%N)
check "the program builds as a native executable, warning-free" test $status -eq 0 -a -x ./main
fact "build: $(echo "$end - $start" | bc 2>/dev/null || awk "BEGIN {print $end - $start}") s, executable $(stat -c %s main) bytes"
check "the executable holds the HTTP unit once" test "$(nm main | grep -c ' T bh_open$')" = 1
check "the executable holds one BoringSSL provider, the one http locks" test "$(nm main | grep -c ' [A-Z] botlish_boringssl_0_20261020_0_')" = 1
check "the executable holds one SSL_CTX_new" test "$(nm main | grep -c ' T SSL_CTX_new$')" = 1
check "the executable depends on no shared BoringSSL or OpenSSL" bash -c '! (ldd ./main | grep -Eq "libssl|libcrypto")'
ldd main | tee "$out/ldd.txt"

run() { local name=$1; shift; echo "-- ./main $*"; ./main "$@" > "$out/$name.txt" 2>&1; echo "exit $?" >> "$out/$name.txt"; cat "$out/$name.txt"; }

echo "== A: a public HTTPS URL"
run a public "$PUBLIC"
check "A: the public URL answers 200" has "$out/a.txt" "public: status 200, "
check "A: the body arrives" grep -Eq '^public: [1-9][0-9]* bytes$' "$out/a.txt"
check "A: no exchange or client is left" has "$out/a.txt" "end: clients 0, exchanges 0, panics 0"

echo "== B: JSON over HTTPS, the program's own anchor"
run b post "$BASE" "$ca"
check "B: 200 over HTTP/2" has "$out/b.txt" "post: status 200, HTTP/2"
check "B: the peer saw the method and headers" has "$out/b.txt" "post: the peer saw method POST, content-type application/json, authorization Bearer cleanroom-token"
check "B: the body round-trips" has "$out/b.txt" "post: the echoed body is the body sent: yes: {\"input\": \"héllo ✓\", \"stream\": false}"
check "B: no exchange or client is left" has "$out/b.txt" "end: clients 0, exchanges 0, panics 0"

echo "== C: streaming, bounded memory, UTF-8 across chunks, a streamed upload"
run c stream "$BASE" "$ca"
check "C: 64 MiB arrive chunk by chunk" grep -Eq '^stream: 67108864 bytes in [0-9]+ chunks over HTTP/2, the largest ([1-9][0-9]{0,3}|1[0-5][0-9]{3}|16[0-2][0-9]{2}|163[0-7][0-9]|1638[0-4])$' "$out/c.txt"
check "C: at most one chunk held natively" grep -Eq '^stream: at most ([0-9]{1,4}|1[0-5][0-9]{3}|16[0-2][0-9]{2}|163[0-7][0-9]|1638[0-4]) bytes held natively' "$out/c.txt"
check "C: peak memory bounded" grep -q 'passed through: bounded yes$' "$out/c.txt"
check "C: UTF-8 text split across chunks decodes" grep -Eq '^stream: utf-8 text in ([2-9]|[1-9][0-9]+) chunks: héllo wörld ✓ 😀 end$' "$out/c.txt"
check "C: the streamed upload arrives whole" has "$out/c.txt" "the peer saw content-length 4194304 and echoed 4194304"
check "C: no exchange or client is left" has "$out/c.txt" "end: clients 0, exchanges 0, panics 0"

echo "== D: a separately authored library under the same driver and runtime"
run d shared "$BASE" "$ca"
for i in 1 2 3; do check "D: feeds poll $i answered" has "$out/d.txt" "feeds: poll $i: status 200, 6 bytes"; done
for i in 1 2 3 4; do check "D: the application's request $i answered" has "$out/d.txt" "app: request $i: status 200, HTTP/2, 6 bytes"; done
check "D: feeds' timer paced its polls" has "$out/d.txt" "feeds: 3 polls, each followed by its pause: yes"
check "D: when the application's task ended, feeds' client was still open (the two ran concurrently)" grep -Eq '^end: clients 1, exchanges [01], panics 0$' "$out/d.txt"
check "D: no exchange or client is left once feeds is done" has "$out/d.txt" "feeds task done: clients 0, exchanges 0, panics 0"

echo "== E: failures"
run e failures "$BASE" "$ca" "$UNTRUSTED" "$CLOSED"
check "E: an unknown host is ResolveFailed" has "$out/e.txt" "failures: name resolution: error ResolveFailed no-such-host.invalid: "
check "E: an untrusted certificate is TlsVerifyFailed" has "$out/e.txt" "failures: untrusted certificate: error TlsVerifyFailed localhost: "
check "E: a refused connection is ConnectFailed" grep -Eq '^failures: refused: error ConnectFailed 127.0.0.1 port [0-9]+: ' "$out/e.txt"
check "E: a deadline is Timeout deadline" has "$out/e.txt" "failures: deadline: error Timeout deadline: "
check "E: an idle body is Timeout idle" has "$out/e.txt" "failures: idle body: body error Timeout idle: "
check "E: cancellation is Cancelled" has "$out/e.txt" "failures: cancelled: error Cancelled"
check "E: an early release drops the exchange" grep -Eq '^failures: early release: first chunk [1-9][0-9]*, a read after release: released, exchanges left 0$' "$out/e.txt"
check "E: the client works after it" has "$out/e.txt" "failures: the client after it: status 200, HTTP/2, 6 bytes"
check "E: no exchange or client is left" has "$out/e.txt" "end: clients 0, exchanges 0, panics 0"

echo "== a library locking another BoringSSL release"
before=$(find .bot_modules -type f -exec sha256sum {} + | sort | sha256sum)
"$botlish" add oldtls -repository "$repo" -target linux-x86_64 2> "$out/conflict.txt"; status=$?
cat "$out/conflict.txt"
check "add oldtls fails" test $status -eq 1
check "the failure is a DEPENDENCY-CONFLICT naming both locks" bash -c "grep -q '(PM DEPENDENCY-CONFLICT)' '$out/conflict.txt' && grep -q 'oldtls 1.0.0 locks boringssl 0.20250101.0' '$out/conflict.txt' && grep -q 'http 0.1.0 locks boringssl 0.20261020.0' '$out/conflict.txt'"
after=$(find .bot_modules -type f -exec sha256sum {} + | sort | sha256sum)
check "the installation is unchanged" test "$before" = "$after"

echo "== checks"
cat "$out/checks.txt"
echo "== facts"
cat "$out/facts.txt"
exit $failed
