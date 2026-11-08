#!/usr/bin/env bash
# single/macos/acceptance.sh -- the compiler's acceptance of a Botlish.app, as
# a release records it (MACOS-BOTLISH-DISTRIBUTION-MILESTONE-1.md, "Compiler
# functional acceptance under the hardened runtime").
#
#   single/macos/acceptance.sh APP OUT [--only CASE,...]
#
# Runs each case against APP and writes OUT/results.json -- a list of
# {"name": CASE, "class": "EXECUTED" | "FAILED", "detail": TEXT} -- which
# tools/macos-release/release.py's record stage reads, and OUT/CASE.log for
# each. The release runs it on the Developer ID-signed bundle before
# notarization (record --label hardened-runtime) and on the bundle extracted,
# quarantined, from the final ZIP (record --label final-artifact). A case
# FAILED fails the record; nothing here is ever ENVIRONMENT-BLOCKED: every
# case runs on any Apple Silicon Mac with the Command Line Tools. The cases:
#
#   version        -version names the packaged backend and no JIT
#   interpreter    a program's value on the interpreter (-backend interp)
#   check          -check of a program and of a rejected one
#   jit-refused    -backend cranelift and run -backend cranelift refused
#                  (NATIVE UNSUPPORTED jit), naming -aot-run
#   aot-run        -aot-run: Darwin IO's output, arguments after --, a C
#                  exit's status, a runtime error's status, a rejected
#                  program never run
#   executable     -emit-native-executable: a Mach-O that runs alone
#   ffi            single/ffi-smoke-test.sh (static C libraries, borrowing,
#                  error capture, variadics, Darwin IO)
#   cocoa-canary   AppKit and Metal through -aot-run -native-startup
#                  main-thread, on the process's main thread
#   smoke          single/smoke-test.sh (every checkout-free check of a
#                  packaged compiler)
#   app            single/macos/app-test.sh (relocation, read-only, paths,
#                  processes, concurrency, cache, tamper, damage,
#                  executables, Darwin IO, the JIT's absence)
#   finder-launch  the bundle opened by LaunchServices (open -W): it exits
#                  without crashing (a command-line compiler shows nothing)
#   signature      the bundle verifies strictly after every run: nothing
#                  wrote into it
set -uo pipefail

[[ $# -ge 2 && -d $1/Contents ]] || { echo "usage: single/macos/acceptance.sh APP OUT [--only CASE,...]" >&2; exit 2; }
app=$(cd "$1" && pwd -P)
mkdir -p "$2"
out=$(cd "$2" && pwd -P)
only=""
[[ ${3:-} == --only ]] && only=",${4:-},"
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
work=$(cd "$(mktemp -d "${TMPDIR:-/tmp}/botlish-acceptance.XXXXXX")" && pwd -P)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/home" "$work/p"
cp "$root/examples/surface/01-arithmetic.bot" "$root/examples/io/hello-darwin.bot" "$root/audit/macos-app/programs/overflow.bot" "$work/p/"
bl() { env -i HOME="$work/home" PATH=/usr/bin:/bin "$app/Contents/MacOS/botlish" "$@"; }
results=()
record() { # CASE CLASS DETAIL
  local detail=${3//\\/\\\\}
  detail=${detail//\"/\\\"}
  detail=$(tr '\n\t' '  ' <<<"$detail" | cut -c1-300)
  results+=("{\"name\": \"$1\", \"class\": \"$2\", \"detail\": \"$detail\"}")
  echo "$1: $2${3:+ ($3)}"
}
case_run() { # CASE: runs case_CASE, logging it, recording EXECUTED or FAILED
  local name=$1 fn=case_${1//-/_}
  [[ -z $only || $only == *",$1,"* ]] || return 0
  if (cd "$work/p" && "$fn") >"$out/$name.log" 2>&1; then
    record "$name" EXECUTED ""
  else
    record "$name" FAILED "$(tail -n 3 "$out/$name.log")"
  fi
}

case_version() {
  v=$(bl -version) || return 1
  grep -q '^native backend: packaged' <<<"$v" && grep -qx 'native JIT: unavailable (programs run natively as executables: -aot-run)' <<<"$v"
}
case_interpreter() {
  [[ $(bl -backend interp 01-arithmetic.bot) == *'value: 50' ]]
}
case_check() {
  bl -check 01-arithmetic.bot >/dev/null || return 1
  printf 'x = \n' >broken.bot
  ! bl -check broken.bot >/dev/null
}
case_jit_refused() {
  for invocation in "-backend cranelift" "run -backend cranelift"; do
    status=0
    # shellcheck disable=SC2086
    bl $invocation 01-arithmetic.bot >jit.out 2>&1 || status=$?
    [[ $status == 1 ]] && grep -q 'NATIVE UNSUPPORTED jit' jit.out && grep -q -e '-aot-run' jit.out || { cat jit.out; return 1; }
  done
}
case_aot_run() {
  [[ $(bl -warnings off -aot-run hello-darwin.bot) == 'Hello, world!' ]] || return 1
  awk '$0 == "    std::io::print_line(\"Hello, world!\")" {
         print "    words = argv():"; print "        on InvalidArgumentEncoding:"; print "            return unit"
         print "    loop w in words:"; print "        std::io::print_line(w)"; print "    unit"; next }
       { print }' hello-darwin.bot >show-args.bot
  [[ $(bl -warnings off -aot-run show-args.bot -- one '' 'ünï cödé' -v) == "show-args.bot"$'\n'"one"$'\n\n'"ünï cödé"$'\n'"-v" ]] || return 1
  printf 'import std::ffi::c\n\nextern c fn exit(status: std::ffi::c::Int) -> unit\n\nexit(7)\nunit\n' >exit7.bot
  status=0; bl -warnings off -aot-run exit7.bot || status=$?
  [[ $status == 7 ]] || { echo "exit status $status, not 7"; return 1; }
  status=0; bl -warnings off -aot-run overflow.bot >overflow.out 2>&1 || status=$?
  [[ $status == 1 ]] && grep -q 'NATIVE LIMIT STACK' overflow.out || { cat overflow.out; return 1; }
  printf 'x = 1 + "two"\n' >typed.bot
  status=0; bl -warnings off -aot-run typed.bot >typed.stdout 2>typed.stderr || status=$?
  [[ $status == 1 && ! -s typed.stdout ]] && grep -q 'typed.bot: ' typed.stderr || { cat typed.stdout typed.stderr; return 1; }
}
case_executable() {
  bl -warnings off -emit-native-executable hello-darwin.bot >/dev/null || return 1
  [[ $(env -i ./hello-darwin) == 'Hello, world!' ]]
}
case_ffi() {
  bash "$root/single/ffi-smoke-test.sh" "$app/Contents/MacOS/botlish"
}
case_cocoa_canary() {
  cat >canary.bot <<'CANARY'
import std::ffi::c

extern c framework "AppKit"
extern c framework "Metal"
extern c fn pthread_main_np() -> std::ffi::c::Int
extern c fn NSApplicationLoad() -> std::ffi::c::Bool
extern c fn MTLCreateSystemDefaultDevice() -> std::ffi::c::Ptr[std::ffi::c::Void]
extern c fn exit(status: std::ffi::c::Int) -> unit

if pthread_main_np() != 1:
    exit(3)
if not NSApplicationLoad():
    exit(4)
device = MTLCreateSystemDefaultDevice()
if std::ffi::c::null?(device):
    exit(5)
unit
CANARY
  bl -warnings off -aot-run -native-startup main-thread canary.bot
}
case_smoke() {
  bash "$root/single/smoke-test.sh" "$app/Contents/MacOS/botlish"
}
case_app() {
  bash "$root/single/macos/app-test.sh" "$app"
}
case_finder_launch() {
  before=$(ls ~/Library/Logs/DiagnosticReports 2>/dev/null | grep -ci botlish || true)
  open -W -n "$app" || return 1
  after=$(ls ~/Library/Logs/DiagnosticReports 2>/dev/null | grep -ci botlish || true)
  [[ $after == "$before" ]] || { echo "a crash report appeared"; return 1; }
}
case_signature() {
  codesign --verify --deep --strict --verbose=2 "$app"
}

for c in version interpreter check jit-refused aot-run executable ffi cocoa-canary smoke app finder-launch signature; do
  case_run "$c"
done
{
  echo "["
  for i in "${!results[@]}"; do
    printf '  %s%s\n' "${results[$i]}" "$( (( i + 1 < ${#results[@]} )) && echo ,)"
  done
  echo "]"
} >"$out/results.json"
failed=$(grep -c '"class": "FAILED"' "$out/results.json" || true)
echo "== acceptance: ${#results[@]} cases, $failed failed ($out/results.json)"
(( failed == 0 ))
