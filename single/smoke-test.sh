#!/usr/bin/env bash
# single/smoke-test.sh -- checks a single-file Botlish compiler (SINGLE-EXECUTABLE.md).
#
#   single/smoke-test.sh BOTLISH
#
# Runs BOTLISH, the executable single/build.sh built, the way a user without
# this checkout's toolchain would: in an empty environment (no PATH, so no
# tclsh, rustc, cc or ld, and no locale), with a fresh HOME. It needs this
# checkout's examples/ (the programs it compiles), and nothing else of it.
# .github/workflows/single-executable.yml runs it in a stock ubuntu:24.04
# container.
#
# Checked: every backend runs the sample programs to the same values; the
# no-argument usage summary (no program runs); -help (the packed Compilerpedia)
# and -version; the inspection options; a rejected program fails;
# -emit-native-executable produces executables that run without anything
# else; a program that calls C refused (NATIVE LINK TOOLCHAIN: no C compiler
# here; single/ffi-smoke-test.sh links them where there is one); an
# application of two files (a module beside its entry file) with a
# recursion deeper than tclsh's default limit allows on the interpreter; a
# native run shows what the program prints; the native backend still
# works with no cache directory at all (no HOME); and the language server
# (-lsp) answers a scripted editor session, its analysis worker started
# from the executable itself and the standard library's source given to the
# editor as files (LSP-MILESTONE-1.md).
set -euo pipefail

botlish=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-smoke.XXXXXX")
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/home" "$work/programs/samples"
# The programs CI's native job runs on every backend (.github/workflows/tests.yml).
cp "$root"/examples/surface/0[1-8]*.bot "$root"/examples/surface/1[1-3]*.bot \
   "$root"/examples/stdlib/*.bot "$root"/examples/hir/0[1-3]*.hir "$work/programs/samples/"
cp "$root/examples/io/hello.bot" "$root/examples/linux/context-hello.bot" "$work/programs/"
cd "$work/programs"

fail() { echo "FAIL: $*" >&2; exit 1; }
# BOTLISH ARGS... in an empty environment with a fresh HOME.
run() { env -i HOME="$work/home" "$botlish" "$@"; }

echo "== $botlish"
for tool in tclsh tclsh9.0 rustc cargo cc ld; do
  echo "   host $tool: $(command -v "$tool" || echo no)"
done

# A run that cannot link installs the native executables and not the runtime
# archive, which only a run that may link gets (SINGLE-EXECUTABLE-FFI-
# MILESTONE-1.md); the cache directory is named by all three, the archive's
# size among them.
env -i HOME="$work/home-nolink" "$botlish" -backend compile -warnings off samples/01-arithmetic.bot >/dev/null ||
  fail "a compile run"
installed=$(ls -d "$work/home-nolink"/.cache/botlish/native-* 2>/dev/null) || fail "a compile run installed nothing"
[[ -x $installed/botlish-native && ! -e $installed/libbotlish_runtime.a ]] ||
  fail "a run that links nothing installed the runtime archive (or no driver): $(ls "$installed")"
env -i HOME="$work/home-nolink" "$botlish" -warnings off -emit-native-executable hello.bot >/dev/null || fail "emit hello"
archive_size=$(wc -c <"$installed/libbotlish_runtime.a") || fail "-emit-native-executable installed no runtime archive"
# Exact modes (a test run as root reads and runs files whatever their mode).
modes=$(stat -c %a "$installed/botlish-native" "$installed/botlish-aot-stub" "$installed/libbotlish_runtime.a" | tr '\n' ' ')
[[ $modes == "755 755 644 " ]] || fail "installed with modes $modes (want 755 755 644)"
[[ $(basename "$installed") == *-"$archive_size" || $(basename "$installed") == *-"$archive_size"-* ]] ||
  fail "the cache directory $(basename "$installed") is not named by the runtime archive ($archive_size bytes)"
echo "   installed: the driver and the stub for any run, the runtime archive for one that may link"

for backend in interp compile cranelift; do
  run -backend "$backend" -warnings off samples/* >"$work/$backend.out" ||
    fail "backend $backend"
  grep -E '^(==|   value:)' "$work/$backend.out" | sed "s/ ($backend)\$//" >"$work/$backend.values"
  echo "   $backend: $(grep -c '^   value:' "$work/$backend.values") values"
done
for backend in compile cranelift; do
  cmp -s "$work/interp.values" "$work/$backend.values" ||
    { diff "$work/interp.values" "$work/$backend.values" >&2; fail "$backend disagrees with interp"; }
done
# (The unspecialized baseline does not compile every corpus program.)
run -backend cranelift-generic -warnings off samples/0*.bot >"$work/generic.out" || fail "backend cranelift-generic"

# Without arguments: the usage summary, and no program runs.
run >"$work/default.out" || fail "the no-argument run (usage)"
grep -q '^usage: ' "$work/default.out" || fail "the no-argument run printed no usage"
if grep -q -e '^== ' -e '^   value:' "$work/default.out"; then fail "the no-argument run ran a program"; fi
# Compilerpedia, packed (no source tree here: the archive's topics).
run -help >"$work/help.out" || fail "-help"
grep -q '^Compilerpedia' "$work/help.out" || fail "-help printed no overview"
# QUERY=FIRST: the query, and how its page starts.
for pair in warnings=WARNINGS METHOD-ELIGIBLE=warning.method-eligible std::list::at=stdlib.std::list::at "bounds proof=proof.list-bounds" "best practices=principle.idiomatic-botlish"; do
  query=${pair%%=*} first=${pair#*=}
  run -help "$query" >"$work/help-query.out" || fail "-help $query"
  if grep -q -e '^== ' -e '^   value:' "$work/help-query.out"; then fail "-help $query ran a program"; fi
  [[ $(head -n 1 "$work/help-query.out") == "$first"* ]] || fail "-help $query does not show $first"
done
if run -help no-such-topic-anywhere >/dev/null 2>&1; then fail "-help of an unknown topic succeeded"; fi
run -version >"$work/version.out" || fail "-version"
grep -q '^source revision: ' "$work/version.out" || fail "-version names no source revision"
grep -q '^native backend: packaged' "$work/version.out" || fail "-version names no packaged native backend"

for option in -code -hir -ast -aot -aot-spec -contexts -traits -emit-nir -emit-clif; do
  run -backend compile -warnings off "$option" samples/01-arithmetic.bot >/dev/null || fail "option $option"
done
printf 'x = \n' >broken.bot
if run broken.bot >"$work/broken.out"; then fail "a broken program was accepted"; fi
grep -q 'SURFACE SYNTAX' "$work/broken.out" || fail "a broken program reported no syntax error"

for program in hello:unit context-hello:14; do
  name=${program%%:*}
  run -warnings off -emit-native-executable "$name.bot" >/dev/null || fail "emit $name"
  [[ $(env -i "./$name") == "Hello, world!"$'\n'"${program#*:}" ]] || fail "executable $name"
done
# An application module beside its entry file, from another working
# directory (IMPORTS.md, "Application modules"), 3000 calls deep on every
# backend (the interpreter's recursion limit: core/core.tcl).
mkdir -p "$work/app"
printf 'fn count(k: int) -> int:\n    if k == 0:\n        return 0\n    1 + count(k - 1)\n' >"$work/app/counter.bot"
printf 'import counter\n\ncounter::count(3000)\n' >"$work/app/value.bot"
for backend in interp compile cranelift-generic cranelift; do
  (cd / && run -backend "$backend" "$work/app/value.bot") | grep -qx '   value: 3000' ||
    fail "an application module on $backend"
done
printf 'import nosuch\n\n1\n' >"$work/app/missing.bot"
if run "$work/app/missing.bot" >"$work/missing.out"; then fail "a missing module was accepted"; fi
grep -qF "no such module file $work/app/nosuch.bot" "$work/missing.out" ||
  fail "a missing module's diagnostic names no application path"
# A local module named like a standard one beside the standard namespace
# itself (STD-NAMESPACE.md): `list` is the application's, `::std::list` the
# standard library's, read from inside the executable whatever the working
# directory holds.
printf 'fn length(xs) -> int:\n    99\n' >"$work/app/list.bot"
printf 'import list\nimport ::std::list\n\n[list::length([1]), ::std::list::length([1, 2])]\n' >"$work/app/both.bot"
for backend in interp cranelift; do
  (cd "$work/app" && run -backend "$backend" "$work/app/both.bot") | grep -qxF '   value: [99, 2]' ||
    fail "a local list beside std::list on $backend"
done
printf 'import std::nosuch\n\n1\n' >"$work/app/nostd.bot"
if run "$work/app/nostd.bot" >"$work/nostd.out"; then fail "a missing standard namespace was accepted"; fi
grep -qF "no such module file //zipfs:/app/botlish/stdlib/nosuch.bot" "$work/nostd.out" ||
  fail "the standard library is not read from inside the executable"
# A native run shows the program's output, then its value.
for backend in cranelift cranelift-generic; do
  [[ $(run -backend "$backend" hello.bot) == "== hello.bot ($backend)"$'\n'"Hello, world!"$'\n'"   value: unit" ]] ||
    fail "-backend $backend shows no program output"
done
# Without HOME the native backend lives in a temporary directory for the run.
env -i "$botlish" -warnings off -emit-native-executable hello.bot >/dev/null || fail "emit without HOME"
[[ $(env -i ./hello) == $'Hello, world!\nunit' ]] || fail "executable built without HOME"
env -i "$botlish" -backend cranelift samples/01-arithmetic.bot >"$work/nohome.out" || fail "cranelift without HOME"
grep -q 'value: 50' "$work/nohome.out" || fail "cranelift without HOME: wrong value"

# A program that calls C needs the host's C compiler driver (the system
# linker, SINGLE-EXECUTABLE-FFI-MILESTONE-1.md): without one -- this
# environment's -- its native link says so, and links nothing.
# single/ffi-smoke-test.sh checks the link where there is one.
printf 'import std::ffi::c\n\nextern c fn labs(x: std::ffi::c::Long) -> std::ffi::c::Long\n\nlabs(0 - 5)\n' >labs.bot
if run -warnings off -emit-native-executable labs.bot >"$work/labs.out" 2>&1; then fail "a C program linked without a C compiler"; fi
grep -q 'needs a C compiler driver to link an executable for linux-x86_64, and there is none: no cc on PATH.*(NATIVE LINK TOOLCHAIN)' "$work/labs.out" ||
  { cat "$work/labs.out" >&2; fail "a C program's link without a C compiler said no NATIVE LINK TOOLCHAIN"; }
[[ ! -e labs ]] || fail "a refused link left an executable"
echo "   a C program without a C compiler: NATIVE LINK TOOLCHAIN"

# The language server: an editor's session, framed by hand. The hover and
# the definition are asked before the analysis is done and answered when it
# is; the definition of std::list::get is a file the editor can open (the
# standard library copied out of the archive).
mkdir -p "$work/lspapp"
printf 'fn area(w: int, h: int) -> int:\n    w * h\n' >"$work/lspapp/shapes.bot"
uri="file://$work/lspapp/main.bot"
text='import shapes\nimport std::list\n\na = shapes::area(3, 4)\nb = std::list::get([1, 2], 5, 0)\na + b + nosuch\n'
frame() { printf 'Content-Length: %d\r\n\r\n%s' "$(printf %s "$1" | LC_ALL=C wc -c)" "$1"; }
at() { printf '{"jsonrpc":"2.0","id":%s,"method":"textDocument/%s","params":{"textDocument":{"uri":"%s"},"position":{"line":%s,"character":%s}}}' "$1" "$2" "$uri" "$3" "$4"; }
{
  frame '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}'
  frame '{"jsonrpc":"2.0","method":"initialized","params":{}}'
  frame "{\"jsonrpc\":\"2.0\",\"method\":\"textDocument/didOpen\",\"params\":{\"textDocument\":{\"uri\":\"$uri\",\"languageId\":\"botlish\",\"version\":1,\"text\":\"$text\"}}}"
  frame "$(at 2 hover 3 6)"
  frame "$(at 3 definition 4 17)"
  sleep 20
  frame '{"jsonrpc":"2.0","id":4,"method":"shutdown"}'
  frame '{"jsonrpc":"2.0","method":"exit"}'
} | run -lsp >"$work/lsp.out" 2>"$work/lsp.err" || { cat "$work/lsp.err" >&2; fail "-lsp did not exit in order"; }
grep -qF '"id":2,"result":{"contents":{"kind":"plaintext","value":"fn shapes::area(w: int, h: int) -> int"}' "$work/lsp.out" ||
  fail "-lsp hover"
grep -qF 'unbound name \"nosuch\"' "$work/lsp.out" || fail "-lsp published no diagnostic"
definition=$(grep -oE '"id":3,"result":\{"uri":"file://[^"]*/list.bot"' "$work/lsp.out" | sed -E 's|.*"file://||; s|"$||')
[[ -n $definition && -f $definition && $definition != *zipfs* ]] || fail "-lsp definition into std:: ($definition)"
grep -q 'analysis worker started' "$work/lsp.err" || fail "-lsp started no worker"
echo "   -lsp: hover, diagnostics, definition into $definition"

echo "== smoke test passed"
