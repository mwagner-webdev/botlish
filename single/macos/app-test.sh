#!/usr/bin/env bash
# single/macos/app-test.sh -- the macOS application's own acceptance
# (MACOS-AARCH64-MILESTONE-9.md): what Botlish.app must survive as an
# application -- its placement, its signature, its damage -- beyond what
# single/smoke-test.sh and single/ffi-smoke-test.sh check of any packaged
# compiler (this script runs the first on a read-only copy).
#
#   single/macos/app-test.sh APP
#
# Every check runs on private copies of APP (APP itself is never changed),
# in a fresh HOME, with PATH=/usr/bin:/bin (Apple's C compiler driver is the
# system linker's), never this checkout's tclsh, rustc or cargo: the
# checkout provides only this script, single/smoke-test.sh and examples/.
# Needs Apple's developer tools (cc, otool, lipo). The groups, each a line:
#
#   relocation    a copy in a path with spaces and non-ASCII characters, the
#                 same moved, a symbolic link to the launcher on PATH, a
#                 symbolic link to the bundle: each runs and verifies; a
#                 TCL_LIBRARY, a BOTLISH_NATIVE_BIN and a DYLD_FRAMEWORK_PATH
#                 (another Tcl.framework) in the environment change nothing
#   read-only     single/smoke-test.sh against a copy made read-only, the
#                 bundle's files unchanged after it, its signature intact
#   paths         an application in a directory with spaces and non-ASCII
#                 characters, given by absolute and relative paths from
#                 other directories; non-ASCII arguments through -argv and
#                 to an executable
#   processes     exit statuses; the native backend's path with spaces and
#                 non-ASCII characters passed as one argument; the
#                 environment the system linker's cc sees (LC_ALL as the
#                 user gave it, whatever Tcl started in); an interrupt
#                 (SIGINT to the process group, as a terminal's) of the
#                 language server leaves no process behind
#   concurrency   concurrent runs, links and language servers in one HOME
#   cache         the language server's copy of the standard library in
#                 ~/Library/Caches/botlish (a HOME with spaces and
#                 non-ASCII characters), BOTLISH_CACHE_DIR, reused when
#                 present, an unwritable cache, nothing written elsewhere
#   moved         the bundle moved while its language server runs
#   tamper        a changed sealed resource, driver, launcher or framework,
#                 an added resource: strict verification fails
#   damage        each missing or damaged part reported as the application's
#                 (exit status 2 before the compiler starts), never as a
#                 reason to install Tcl, Rust or Cargo
#   executables   a standalone Mach-O: arm64, LC_MAIN, only the system's
#                 libraries, no LC_RPATH, no reference to the application,
#                 run with the
#                 application gone, its arguments and status
#   darwin-io     examples/io/hello-darwin.bot: checked, its context selected
#                 statically (NIR), linked against libSystem, run
#
# A failure is "FAIL[GROUP]: ..." and exit 1.
set -euo pipefail

[[ $# -eq 1 && -d $1/Contents ]] || { echo "usage: single/macos/app-test.sh APP" >&2; exit 2; }
source_app=$(cd "$1" && pwd -P)
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
work=$(cd "$(mktemp -d "${TMPDIR:-/tmp}/botlish-app-test.XXXXXX")" && pwd -P)
cleanup() { chmod -R u+w "$work" 2>/dev/null || true; rm -rf "$work"; }
trap cleanup EXIT
group=setup
fail() { echo "FAIL[$group]: $*" >&2; exit 1; }
section() { group=$1; echo "== $1"; }
# A private copy of the application in DIR (created), as its path.
copy_app() { mkdir -p "$1"; cp -R "$source_app" "$1/"; echo "$1/Botlish.app"; }
# APP's launcher with ARGS..., in an environment of HOME (default
# $work/home), PATH=/usr/bin:/bin and nothing else.
home="$work/home"
mkdir -p "$home"
bl() { local app=$1; shift; env -i HOME="$home" PATH=/usr/bin:/bin "$app/Contents/MacOS/botlish" "$@"; }
verify() { codesign --verify --deep --strict "$1" 2>"$work/verify.err" || { cat "$work/verify.err" >&2; fail "$1 does not verify"; }; }
mkdir -p "$work/p"
cp "$root/examples/surface/01-arithmetic.bot" "$root/examples/io/hello-darwin.bot" "$root/audit/macos-app/programs/"*.bot "$work/p/"
cd "$work/p"

# --- relocation -----------------------------------------------------------------
section relocation
copied=$(copy_app "$work/A dir with spaces/Ünïcödé")
[[ $(bl "$copied" -backend cranelift 01-arithmetic.bot) == *"value: 50" ]] || fail "the copy in a non-ASCII path does not run"
# (Without a locale, as above, and in the C locale: the launcher starts Tcl
# in a UTF-8 locale, which Tcl 9.0.1 needs in a non-ASCII path.)
[[ $(env -i HOME="$home" PATH=/usr/bin:/bin LC_ALL=C "$copied/Contents/MacOS/botlish" -backend cranelift 01-arithmetic.bot) == *"value: 50" ]] ||
  fail "the copy in a non-ASCII path does not run with LC_ALL=C"
verify "$copied"
mkdir -p "$work/moved"
mv "$copied" "$work/moved/"
moved="$work/moved/Botlish.app"
[[ $(bl "$moved" -backend cranelift 01-arithmetic.bot) == *"value: 50" ]] || fail "the moved copy does not run"
verify "$moved"
mkdir -p "$work/bin"
ln -s "$moved/Contents/MacOS/botlish" "$work/bin/botlish"
version=$(cd / && env -i HOME="$home" PATH="$work/bin:/usr/bin:/bin" botlish -version)
grep -qx 'invocation: botlish' <<<"$version" || fail "through a symbolic link on PATH: $version"
grep -q '^native backend: packaged' <<<"$version" || fail "through a symbolic link on PATH: $version"
[[ $(cd / && env -i HOME="$home" PATH="$work/bin:/usr/bin:/bin" botlish -backend cranelift "$work/p/01-arithmetic.bot") == *"value: 50" ]] ||
  fail "a native run through a symbolic link on PATH"
# The environment cannot substitute another Tcl script library or another
# build's driver: the application's own are used.
mkdir -p "$work/decoy"
echo 'puts stderr "DECOY TCL LIBRARY"' >"$work/decoy/init.tcl"
decoyed=$(env -i HOME="$home" PATH=/usr/bin:/bin TCL_LIBRARY="$work/decoy" BOTLISH_NATIVE_BIN=/nonexistent/botlish-native \
  "$moved/Contents/MacOS/botlish" -backend cranelift 01-arithmetic.bot 2>&1)
[[ $decoyed == *"value: 50" && $decoyed != *DECOY* ]] || fail "TCL_LIBRARY and BOTLISH_NATIVE_BIN in the environment: $decoyed"
# Nor another Tcl.framework through dyld's DYLD_FRAMEWORK_PATH (a copy whose
# script library announces itself): the launcher refuses a Tcl that is not
# the bundle's, or dyld loads the bundle's.
mkdir -p "$work/decoy-frameworks"
cp -R "$moved/Contents/Frameworks/Tcl.framework" "$work/decoy-frameworks/"
echo 'puts stderr "DECOY TCL FRAMEWORK"' >>"$work/decoy-frameworks/Tcl.framework/Versions/9.0/Resources/Scripts/init.tcl"
status=0
env -i HOME="$home" PATH=/usr/bin:/bin DYLD_FRAMEWORK_PATH="$work/decoy-frameworks" "$moved/Contents/MacOS/botlish" -version >"$work/dyld.out" 2>&1 || status=$?
if grep -q DECOY "$work/dyld.out"; then fail "DYLD_FRAMEWORK_PATH's Tcl ran the compiler"; fi
if (( status != 0 )); then
  grep -q "not this application's own" "$work/dyld.out" || fail "DYLD_FRAMEWORK_PATH: status $status, $(cat "$work/dyld.out")"
  dyld_outcome="refused (status $status)"
else
  dyld_outcome="the bundle's Tcl loaded"
fi
ln -s "$moved" "$work/Linked.app"
[[ $(bl "$work/Linked.app" -backend cranelift 01-arithmetic.bot) == *"value: 50" ]] || fail "through a symbolic link to the bundle"
echo "   copied, moved, linked; TCL_LIBRARY and BOTLISH_NATIVE_BIN ignored; DYLD_FRAMEWORK_PATH's Tcl: $dyld_outcome"

# --- read-only ------------------------------------------------------------------
section read-only
ro=$(copy_app "$work/ro")
tree() { (cd "$1" && find . -print0 | LC_ALL=C sort -z | xargs -0 stat -f '%N %p %z %m' && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 shasum) ; }
chmod -R a-w "$ro"
before=$(tree "$ro")
if touch "$ro/Contents/Resources/probe" 2>/dev/null; then fail "the copy is writable"; fi
bash "$root/single/smoke-test.sh" "$ro/Contents/MacOS/botlish" >"$work/smoke.log" 2>&1 || { tail -30 "$work/smoke.log" >&2; fail "single/smoke-test.sh on the read-only application"; }
# (Writing into the archive is refused, not done in memory.)
if bl "$ro" -warnings off -emit-hir-interchange //zipfs:/app/botlish/stdlib/ascii.bot >"$work/zipwrite.out" 2>&1; then fail "a write into the archive succeeded"; fi
grep -q 'writes not permitted' "$work/zipwrite.out" || fail "a write into the archive: $(cat "$work/zipwrite.out")"
[[ $(tree "$ro") == "$before" ]] || fail "the application's files changed while it ran"
verify "$ro"
echo "   single/smoke-test.sh on a read-only copy: $(grep -c '^   ' "$work/smoke.log") checks; the bundle unchanged and verifying"

# --- paths ----------------------------------------------------------------------
section paths
app=$moved
src="$work/sources dir/ünï cödé"
mkdir -p "$src"
printf 'fn triple(n: int) -> int:\n    3 * n\n' >"$src/helper.bot"
printf 'import helper\n\nhelper::triple(14)\n' >"$src/main.bot"
cp args.bot "$src/args.bot"
for backend in interp compile cranelift cranelift-generic; do
  [[ $(cd / && bl "$app" -backend "$backend" "$src/main.bot") == *'value: 42' ]] || fail "an absolute path on $backend"
done
[[ $(cd "$work/sources dir" && bl "$app" -backend cranelift "./ünï cödé/main.bot") == *'value: 42' ]] || fail "a relative path"
[[ $(cd "$src" && bl "$app" -backend cranelift -argv 'ü' -argv 'two words' args.bot) == *'value: ["ü", "two words"]' ]] || fail "-argv with non-ASCII text"
(cd "$src" && bl "$app" -warnings off -emit-native-executable args.bot >/dev/null) || fail "an executable in the non-ASCII directory"
[[ $(cd / && "$src/args" 'ü' 'two words') == '['*'"ü", "two words"]' ]] || fail "the executable's non-ASCII arguments: $("$src/args" 'ü' 'two words')"
echo "   spaces and non-ASCII characters in sources, arguments and executables: ok"

# --- processes ------------------------------------------------------------------
section processes
status=0; bl "$app" -no-such-option >/dev/null 2>&1 || status=$?
[[ $status == 2 ]] || fail "a usage error exits $status, not 2"
printf 'x = \n' >broken.bot
status=0; bl "$app" broken.bot >/dev/null 2>&1 || status=$?
[[ $status == 1 ]] || fail "a rejected program exits $status, not 1"
status=0; bl "$app" -backend cranelift overflow.bot >"$work/overflow.out" 2>&1 || status=$?
[[ $status == 1 ]] && grep -q 'NATIVE LIMIT STACK' "$work/overflow.out" || fail "a native stack overflow: status $status, $(cat "$work/overflow.out")"
# The driver's path (the bundle's) with spaces and non-ASCII characters: one argument.
[[ $(bl "$work/moved/Botlish.app" -backend cranelift coroutine.bot) == *'value: [0, 1, 4, -1]' ]] || fail "the driver's path as one argument"
# The environment reaches what the compiler runs as the user gave it (the
# UTF-8 locale Tcl starts in is put back): a C compiler driver first on PATH
# that records its environment, then links with Apple's.
mkdir -p "$work/ccshim"
printf '#!/bin/sh\nenv >"$CC_ENV_LOG"\nexec /usr/bin/cc "$@"\n' >"$work/ccshim/cc"
chmod +x "$work/ccshim/cc"
for locale in "" C en_US.UTF-8; do
  rm -f "$work/cc.env"
  env -i HOME="$home" PATH="$work/ccshim:/usr/bin:/bin" CC_ENV_LOG="$work/cc.env" ${locale:+LC_ALL=$locale} \
    "$app/Contents/MacOS/botlish" -warnings off -emit-native-executable hello-darwin.bot >/dev/null 2>"$work/cc.err" ||
    fail "a link through a recording cc (LC_ALL ${locale:-unset}): $(cat "$work/cc.err")"
  [[ -s $work/cc.env ]] || fail "the system linker did not run the cc on PATH (LC_ALL ${locale:-unset})"
  seen=$(sed -n 's/^LC_ALL=//p' "$work/cc.env")
  [[ $seen == "$locale" ]] || fail "the linker ran with LC_ALL '$seen'; the environment gave '${locale}'"
done
# An interrupt of the language server and its analysis worker, as a
# terminal sends it: to the process group.
mkfifo "$work/lsp.in"
set -m
bl "$app" -lsp <"$work/lsp.in" >"$work/lsp.out" 2>"$work/lsp.err" &
server=$!
set +m
exec 3>"$work/lsp.in"
frame() { printf 'Content-Length: %d\r\n\r\n%s' "$(printf %s "$1" | LC_ALL=C wc -c | tr -d ' ')" "$1"; }
frame '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}' >&3
frame '{"jsonrpc":"2.0","method":"initialized","params":{}}' >&3
frame "{\"jsonrpc\":\"2.0\",\"method\":\"textDocument/didOpen\",\"params\":{\"textDocument\":{\"uri\":\"file://$work/p/coroutine.bot\",\"languageId\":\"botlish\",\"version\":1,\"text\":\"1 + 1\\n\"}}}" >&3
for _ in $(seq 60); do grep -q 'publishDiagnostics' "$work/lsp.out" 2>/dev/null && break; sleep 1; done
grep -q 'publishDiagnostics' "$work/lsp.out" || fail "the language server published nothing"
worker=$(pgrep -f -- "-lsp-worker" | tr '\n' ' ' || true)
kill -INT -- "-$server"
exec 3>&-
wait "$server" 2>/dev/null || true
sleep 1
for pid in $server $worker; do
  if kill -0 "$pid" 2>/dev/null; then fail "process $pid outlived the interrupt"; fi
done
echo "   statuses 0/1/2, an overflow, the environment passed on (LC_ALL unset, C, en_US.UTF-8), an interrupted language server (worker $worker): ok"

# --- concurrency ----------------------------------------------------------------
section concurrency
pids=""
for i in 1 2 3 4; do
  mkdir -p "$work/c$i"
  cp coroutine.bot hello-darwin.bot "$work/c$i/"
  (cd "$work/c$i" && bl "$app" -backend cranelift coroutine.bot >run.out 2>&1 &&
     bl "$app" -warnings off -emit-native-executable hello-darwin.bot >emit.out 2>&1) &
  pids="$pids $!"
done
for pid in $pids; do wait "$pid" || fail "a concurrent run failed"; done
for i in 1 2 3 4; do
  grep -q 'value: \[0, 1, 4, -1\]' "$work/c$i/run.out" || fail "concurrent run $i: $(cat "$work/c$i/run.out")"
  [[ $(env -i "$work/c$i/hello-darwin") == $'Hello, world!\nunit' ]] || fail "concurrent link $i"
done
echo "   four concurrent native runs and links: ok"

# --- cache ----------------------------------------------------------------------
section cache
# A scripted session asking for std::list::get's definition; prints its file.
definition_of() { # HOME [ENV...]
  local h=$1; shift
  local uri="file://$work/p/def.bot" text='import std::list\n\nstd::list::get([1, 2], 5, 0)\n'
  {
    frame '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}'
    frame '{"jsonrpc":"2.0","method":"initialized","params":{}}'
    frame "{\"jsonrpc\":\"2.0\",\"method\":\"textDocument/didOpen\",\"params\":{\"textDocument\":{\"uri\":\"$uri\",\"languageId\":\"botlish\",\"version\":1,\"text\":\"$text\"}}}"
    frame "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"textDocument/definition\",\"params\":{\"textDocument\":{\"uri\":\"$uri\"},\"position\":{\"line\":2,\"character\":12}}}"
    sleep 15
    frame '{"jsonrpc":"2.0","id":3,"method":"shutdown"}'
    frame '{"jsonrpc":"2.0","method":"exit"}'
  } | env -i HOME="$h" PATH=/usr/bin:/bin "$@" "$app/Contents/MacOS/botlish" -lsp 2>"$work/def.err" |
    grep -oE '"id":2,"result":\{"uri":"file://[^"]*"' | sed -E 's|.*"file://||; s|"$||' | decode
}
# A file: URI's path, its percent escapes decoded (as UTF-8 bytes).
decode() { local line; while IFS= read -r line; do printf '%b\n' "$(sed 's/%/\\x/g' <<<"$line")"; done; }
uhome="$work/hömé dir"
mkdir -p "$uhome"
first=$(definition_of "$uhome")
[[ $first == "$uhome/Library/Caches/botlish/stdlib-"*/list.bot && -f $first ]] || fail "the standard library's copy is not in ~/Library/Caches/botlish: '$first' ($(cat "$work/def.err" | tail -3))"
[[ $(ls -A "$uhome") == Library && $(ls -A "$uhome/Library") == Caches ]] || fail "the language server wrote into HOME outside Library/Caches: $(cd "$uhome" && find . -maxdepth 3)"
stamp=$(stat -f %m "$first")
sleep 1
second=$(definition_of "$uhome")
[[ $second == "$first" && $(stat -f %m "$first") == "$stamp" ]] || fail "the copy is not reused"
override=$(definition_of "$work/home2" BOTLISH_CACHE_DIR="$work/cache dir")
[[ $override == "$work/cache dir/stdlib-"*/list.bot ]] || fail "BOTLISH_CACHE_DIR is not the cache: '$override'"
mkdir -p "$work/locked"
chmod a-w "$work/locked"
none=$(definition_of "$work/locked")
grep -q 'cannot be copied out of the executable' "$work/def.err" || fail "an unwritable cache: $(tail -3 "$work/def.err")"
chmod u+w "$work/locked"
[[ -z $(ls -A "$work/locked") ]] || fail "something was written into an unwritable HOME"
# Two servers copying the library into one fresh cache at once.
(definition_of "$work/home3" >"$work/def1") & a=$!
(definition_of "$work/home3" >"$work/def2") & b=$!
wait $a; wait $b
copied_library=$(dirname "$(cat "$work/def1")")
[[ -n $copied_library && $(cat "$work/def1") == "$(cat "$work/def2")" ]] || fail "concurrent copies differ"
entries=$(unzip -Z1 "$app/Contents/Resources/botlish.zip" | grep '^botlish/stdlib/.*\.bot$' | sed 's|^botlish/stdlib/||' | LC_ALL=C sort)
[[ $(cd "$copied_library" && find . -name '*.bot' | sed 's|^\./||' | LC_ALL=C sort) == "$entries" ]] || fail "the copied library is not the packed one"
while read -r entry; do
  cmp -s <(unzip -p "$app/Contents/Resources/botlish.zip" "botlish/stdlib/$entry") "$copied_library/$entry" || fail "copied $entry differs from the packed one"
done <<<"$entries"
echo "   ~/Library/Caches/botlish (non-ASCII HOME), reuse, BOTLISH_CACHE_DIR, unwritable, concurrent copies: ok"

# --- moved ----------------------------------------------------------------------
section moved
runner=$(copy_app "$work/running")
rm -f "$work/lsp.in"; mkfifo "$work/lsp.in"
bl "$runner" -lsp <"$work/lsp.in" >"$work/moved.out" 2>"$work/moved.err" &
server=$!
exec 3>"$work/lsp.in"
uri="file://$work/p/shapes.bot"
frame '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}' >&3
frame '{"jsonrpc":"2.0","method":"initialized","params":{}}' >&3
frame "{\"jsonrpc\":\"2.0\",\"method\":\"textDocument/didOpen\",\"params\":{\"textDocument\":{\"uri\":\"$uri\",\"languageId\":\"botlish\",\"version\":1,\"text\":\"fn area(w: int, h: int) -> int:\\n    w * h\\n\\narea(3, 4)\\n\"}}}" >&3
for _ in $(seq 60); do grep -q 'publishDiagnostics' "$work/moved.out" 2>/dev/null && break; sleep 1; done
mkdir -p "$work/elsewhere"
mv "$runner" "$work/elsewhere/"
frame "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"textDocument/hover\",\"params\":{\"textDocument\":{\"uri\":\"$uri\"},\"position\":{\"line\":3,\"character\":1}}}" >&3
sleep 3
frame '{"jsonrpc":"2.0","id":3,"method":"shutdown"}' >&3
frame '{"jsonrpc":"2.0","method":"exit"}' >&3
exec 3>&-
status=0; wait "$server" || status=$?
grep -qF '"id":2,"result":{"contents":{"kind":"plaintext","value":"fn area(w: int, h: int) -> int"}' "$work/moved.out" ||
  fail "after the move the server did not answer: $(tail -c 400 "$work/moved.out"; tail -3 "$work/moved.err")"
[[ $status == 0 ]] || fail "the moved server exited $status"
verify "$work/elsewhere/Botlish.app"
echo "   a language server answers after its bundle moved: ok"

# --- tamper ---------------------------------------------------------------------
section tamper
flip() { # FILE OFFSET: one byte changed in place
  printf '\377' | dd of="$1" bs=1 seek="$2" count=1 conv=notrunc 2>/dev/null
}
rejected() { # APP WHAT
  if codesign --verify --deep --strict "$1" 2>"$work/tamper.err"; then fail "$2: still verifies"; fi
  echo "   $2: $(tr '\n' ' ' <"$work/tamper.err" | cut -c1-160)"
}
t=$(copy_app "$work/t1"); flip "$t/Contents/Resources/botlish.zip" 100; rejected "$t" "a changed botlish.zip"
t=$(copy_app "$work/t2"); flip "$t/Contents/MacOS/botlish-native" 20000; rejected "$t" "a changed driver"
# (Running it: the kernel validates a signed page as it is paged in; what
# a change does depends on whether the run touches its page. Recorded.)
status=0; bl "$t" -backend cranelift 01-arithmetic.bot >"$work/t2.out" 2>&1 || status=$?
echo "     (a native run with it: status $status, $(tr '\n' ' ' <"$work/t2.out" | cut -c1-140))"
t=$(copy_app "$work/t3"); flip "$t/Contents/MacOS/botlish" 20000; rejected "$t" "a changed launcher"
status=0; bl "$t" -version >"$work/t3.out" 2>&1 || status=$?
echo "     (running it: status $status, $(tr '\n' ' ' <"$work/t3.out" | cut -c1-140))"
t=$(copy_app "$work/t4"); flip "$t/Contents/Frameworks/Tcl.framework/Versions/9.0/Tcl" 20000; rejected "$t" "a changed Tcl.framework"
t=$(copy_app "$work/t5"); echo extra >"$t/Contents/Resources/extra.txt"; rejected "$t" "an added resource"
t=$(copy_app "$work/t6"); flip "$t/Contents/Frameworks/Tcl.framework/Versions/9.0/Resources/Scripts/init.tcl" 10; rejected "$t" "a changed framework script"
t="$work/t7/Botlish.app"; mkdir -p "$work/t7"; cp -RL "$source_app" "$t"; rejected "$t" "the framework's links copied as files"

# --- damage ---------------------------------------------------------------------
section damage
damaged() { # APP PATTERN WHAT [ARGS...]
  local a=$1 pattern=$2 what=$3
  shift 3
  [[ $# -gt 0 ]] || set -- -version
  local status=0
  bl "$a" "$@" >"$work/d.out" 2>"$work/d.err" || status=$?
  [[ $status != 0 ]] || fail "$what: exit status 0"
  grep -q -- "$pattern" "$work/d.err" "$work/d.out" || { cat "$work/d.out" "$work/d.err" >&2; fail "$what: no '$pattern'"; }
  if grep -qi -e rustup -e cargo -e 'install tcl' -e homebrew "$work/d.err" "$work/d.out"; then fail "$what: suggests installing a toolchain"; fi
  echo "   $what: status $status, $(grep -h -m1 -- "$pattern" "$work/d.err" "$work/d.out" | cut -c1-150)"
}
# (Before the compiler starts: the launcher's status 2, on standard error only.)
early() { damaged "$@"; [[ ! -s $work/d.out ]] || fail "$3: wrote to standard output"; grep -q '^botlish: ' "$work/d.err" || fail "$3: not the launcher's diagnostic"; }
d=$(copy_app "$work/d1"); rm -rf "$d/Contents/Frameworks/Tcl.framework"; early "$d" 'cannot load Tcl' "Tcl.framework missing"
d=$(copy_app "$work/d2"); printf 'int botlish_fake_tcl;\n' >"$work/fake.c"
clang -arch x86_64 -dynamiclib -install_name @rpath/Tcl.framework/Versions/9.0/Tcl -o "$d/Contents/Frameworks/Tcl.framework/Versions/9.0/Tcl" "$work/fake.c"
early "$d" 'cannot load Tcl' "Tcl.framework for x86_64"
d=$(copy_app "$work/d3"); head -c 4096 "$source_app/Contents/Frameworks/Tcl.framework/Versions/9.0/Tcl" >"$d/Contents/Frameworks/Tcl.framework/Versions/9.0/Tcl"
early "$d" 'cannot load Tcl' "Tcl.framework truncated"
d=$(copy_app "$work/d4"); rm "$d/Contents/Resources/botlish.zip"; early "$d" 'compiler archive .* is missing' "botlish.zip missing"
d=$(copy_app "$work/d5"); head -c 100000 "$source_app/Contents/Resources/botlish.zip" >"$d/Contents/Resources/botlish.zip"
early "$d" 'cannot mount the compiler archive' "botlish.zip truncated"
d=$(copy_app "$work/d6"); (cd "$d/Contents/Resources" && zip -q -d botlish.zip main.tcl); early "$d" 'holds no main.tcl' "botlish.zip without main.tcl"
d=$(copy_app "$work/d7"); rm "$d/Contents/MacOS/botlish-native"
damaged "$d" "native backend is missing: $d/Contents/MacOS/botlish-native" "the driver missing" -backend cranelift 01-arithmetic.bot
grep -q 'reinstall' "$work/d.out" "$work/d.err" || fail "the driver missing: no remedy"
tcl_run=$(bl "$d" -backend compile 01-arithmetic.bot 2>&1) || true
[[ $tcl_run == *"value: 50"* ]] || fail "without the driver the Tcl backends stop working: $tcl_run"
d=$(copy_app "$work/d8"); chmod 644 "$d/Contents/MacOS/botlish-native"
damaged "$d" 'error' "the driver not executable" -backend cranelift 01-arithmetic.bot
d=$(copy_app "$work/d9"); printf 'int main(void) { return 0; }\n' >"$work/x86.c"
clang -arch x86_64 -o "$d/Contents/MacOS/botlish-native" "$work/x86.c"
damaged "$d" 'error' "the driver for x86_64" -backend cranelift 01-arithmetic.bot
d=$(copy_app "$work/d10"); rm "$d/Contents/Resources/libbotlish_runtime.a"
damaged "$d" "the runtime archive is missing: $d/Contents/Resources/libbotlish_runtime.a" "the runtime archive missing" -warnings off -emit-native-executable hello-darwin.bot
d=$(copy_app "$work/d11"); clang -arch x86_64 -c -o "$work/x86.o" "$work/x86.c" && rm -f "$work/x86.a" && ar rcs "$work/x86.a" "$work/x86.o"
cp "$work/x86.a" "$d/Contents/Resources/libbotlish_runtime.a"
damaged "$d" "not this driver's macos-aarch64" "the runtime archive for x86_64" -warnings off -emit-native-executable hello-darwin.bot
# (Simulated: a C compiler driver that does not exist. The real absence of
# the developer tools is the clean job's: macos-arm64.yml.)
d=$(copy_app "$work/d12")
status=0; env -i HOME="$home" PATH=/usr/bin:/bin BOTLISH_NATIVE_SYSTEM_LINKER=/nonexistent/cc "$d/Contents/MacOS/botlish" \
  -warnings off -emit-native-executable hello-darwin.bot >"$work/d.out" 2>&1 || status=$?
grep -q 'NATIVE LINK TOOLCHAIN' "$work/d.out" && grep -q 'xcode-select --install' "$work/d.out" || fail "no C compiler driver: $(cat "$work/d.out")"
if grep -qi -e rustup -e cargo "$work/d.out"; then fail "no C compiler driver: suggests Rust"; fi
echo "   no C compiler driver (BOTLISH_NATIVE_SYSTEM_LINKER=/nonexistent/cc): NATIVE LINK TOOLCHAIN, xcode-select --install"

# --- executables ----------------------------------------------------------------
section executables
builder=$(copy_app "$work/builder")
mkdir -p "$work/exe"
cp coroutine.bot context.bot overflow.bot args.bot "$work/exe/"
for program in coroutine context overflow args; do
  (cd "$work/exe" && bl "$builder" -warnings off -emit-native-executable "$program.bot" >/dev/null) || fail "emit $program"
done
for program in coroutine context overflow args; do
  exe="$work/exe/$program"
  file "$exe" | grep -q 'Mach-O 64-bit executable arm64' || fail "$program: $(file "$exe")"
  otool -l "$exe" | grep -q 'cmd LC_MAIN' || fail "$program has no LC_MAIN entry point"
  for library in $(otool -L "$exe" | tail -n +2 | awk '{print $1}'); do
    case $library in /usr/lib/*|/System/Library/*) ;; *) fail "$program needs $library" ;; esac
  done
  if strings -a "$exe" | grep -q -e 'Botlish.app' -e "$work/builder"; then fail "$program names the application"; fi
  if otool -l "$exe" | grep -q 'cmd LC_RPATH'; then fail "$program has an LC_RPATH"; fi
done
rm -rf "$work/builder"
cd /
[[ $(env -i "$work/exe/coroutine") == '[0, 1, 4, -1]' ]] || fail "coroutine: $(env -i "$work/exe/coroutine")"
[[ $(env -i BOTLISH_NATIVE_GC_STRESS=1 "$work/exe/coroutine") == '[0, 1, 4, -1]' ]] || fail "coroutine under GC stress"
[[ $(env -i "$work/exe/context") == '[3, 42, -6]' ]] || fail "context: $(env -i "$work/exe/context")"
[[ $(env -i "$work/exe/args" a 'b c' ü) == *'"a", "b c", "ü"]' ]] || fail "args: $(env -i "$work/exe/args" a 'b c' ü)"
status=0; env -i "$work/exe/overflow" >"$work/exe.out" 2>&1 || status=$?
[[ $status == 1 ]] && grep -q 'NATIVE LIMIT STACK' "$work/exe.out" || fail "overflow: status $status, $(cat "$work/exe.out")"
cd "$work/p"
echo "   arm64 Mach-O, LC_MAIN, system libraries only, run with the application deleted (also under GC stress), arguments, statuses: ok"

# --- darwin-io ------------------------------------------------------------------
section darwin-io
bl "$app" -check hello-darwin.bot >"$work/check.out" 2>&1 || fail "-check: $(cat "$work/check.out")"
bl "$app" -emit-nir -backend interp hello-darwin.bot >"$work/nir.out" 2>&1 || true
line=$(grep -E '^func [0-9]+ "std::io::print_line<std::io::IO=std::darwin::io::DarwinIO>"' "$work/nir.out") ||
  fail "no print_line specialized for DarwinIO in the NIR"
write_text=$(sed -nE 's/^func ([0-9]+) "std::darwin::io::write_text".*/\1/p' "$work/nir.out")
[[ -n $write_text ]] && awk -v want="call $write_text" '/^func/{inside = ($0 ~ /print_line<std::io::IO=std::darwin::io::DarwinIO>/)} inside && index($0, want) {found = 1} END {exit !found}' "$work/nir.out" ||
  fail "print_line does not call std::darwin::io::write_text directly"
bl "$app" -warnings off -emit-native-executable hello-darwin.bot >/dev/null || fail "emit hello-darwin"
otool -L hello-darwin | grep -q '/usr/lib/libSystem.B.dylib' || fail "hello-darwin does not link libSystem"
[[ $(env -i ./hello-darwin) == $'Hello, world!\nunit' ]] || fail "hello-darwin: $(env -i ./hello-darwin)"
echo "   checked, std::io::IO selected statically (print_line<...DarwinIO> calls write_text), libSystem, run: ok"

echo "== app-test passed"
