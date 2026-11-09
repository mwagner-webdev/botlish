#!/usr/bin/env bash
# single/smoke-test.sh -- checks a packaged Botlish compiler: the single-file
# compiler (SINGLE-EXECUTABLE.md) or the macOS application's
# (MACOS-AARCH64-MILESTONE-9.md).
#
#   single/smoke-test.sh BOTLISH
#
# BOTLISH is the executable single/build.sh built, or on macOS
# Botlish.app/Contents/MacOS/botlish (single/macos/build.sh). It runs the way
# a user without this checkout's toolchain would: in an empty environment (no
# PATH, so no tclsh, rustc, cc or ld, and no locale), with a fresh HOME. It
# needs this checkout's examples/ (the programs it compiles), and nothing
# else of it. .github/workflows/single-executable.yml runs it in a stock
# ubuntu:24.04 container, macos-arm64.yml's app jobs on the application.
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
# editor as files (LSP-MILESTONE-1.md); and the package commands pack, add
# and verify a package without installing the native backend
# (PACKAGE-MANAGER-MILESTONE-1.md).
#
# On macOS the program that prints is examples/io/hello-darwin.bot, whose
# Darwin IO calls libSystem: every executable is linked by the system
# linker, and a native backend links a program that calls C to run it, so
# those checks need Apple's C compiler driver -- with PATH=/usr/bin:/bin, its
# location on every Mac. Without the developer tools (the shim at
# /usr/bin/cc cannot run a compiler) they check the refusal instead
# (NATIVE LINK TOOLCHAIN), and everything else runs as before. The
# application installs nothing: no run creates a cache directory but the
# language server's copy of the standard library (~/Library/Caches/botlish).
set -euo pipefail

botlish=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# (A real path: macOS's $TMPDIR is behind the /var symbolic link, and the
# compiler names files by their real paths.)
work=$(cd "$(mktemp -d "${TMPDIR:-/tmp}/botlish-smoke.XXXXXX")" && pwd -P)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/home" "$work/programs/samples"
# The programs CI's native job runs on every backend (.github/workflows/tests.yml).
cp "$root"/examples/surface/0[1-8]*.bot "$root"/examples/surface/1[1-3]*.bot \
   "$root"/examples/stdlib/*.bot "$root"/examples/hir/0[1-3]*.hir "$work/programs/samples/"
macos=0
[[ $(uname -s) == Darwin ]] && macos=1
if (( macos )); then
  cp "$root/examples/io/hello-darwin.bot" "$work/programs/hello.bot"
  target=macos-aarch64
else
  cp "$root/examples/io/hello.bot" "$root/examples/linux/context-hello.bot" "$work/programs/"
  target=linux-$(uname -m)
fi
cd "$work/programs"

fail() { echo "FAIL: $*" >&2; exit 1; }
# BOTLISH ARGS... in an empty environment with a fresh HOME.
run() { env -i HOME="$work/home" "$botlish" "$@"; }
# A check of a command's output captures the output, then matches it
# (`out=$(COMMAND) && grep -q PATTERN <<<"$out"`), never `COMMAND | grep -q
# PATTERN`: grep -q stops reading at its first match, and a command still
# writing then dies of the broken pipe (Tcl's `error writing "stdout"`),
# which pipefail makes the check's verdict (a failure, or in an `if` the
# silent pass of a check that should have failed).
# BOTLISH ARGS... where it links native executables: on macOS with the C
# compiler driver's PATH (toolchain: whether its developer tools exist).
toolchain=1
if (( macos )); then
  env -i PATH=/usr/bin:/bin /usr/bin/cc --version >/dev/null 2>&1 || toolchain=0
  linking() { env -i HOME="$work/home" PATH=/usr/bin:/bin "$botlish" "$@"; }
else
  linking() { run "$@"; }
fi

echo "== $botlish"
for tool in tclsh tclsh9.0 rustc cargo cc ld; do
  echo "   host $tool: $(command -v "$tool" || echo no)"
done

mkdir -p "$work/home-nolink"
if (( macos )); then
  # The application installs nothing: it runs and links its files where they
  # are, in the bundle.
  env -i HOME="$work/home-nolink" "$botlish" -backend cranelift -warnings off samples/01-arithmetic.bot >/dev/null ||
    fail "a native run"
  [[ -z $(ls -A "$work/home-nolink") ]] || fail "a run wrote into HOME: $(cd "$work/home-nolink" && find . | head -5)"
  echo "   installed: nothing (the application's driver runs where it is)"
else
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
fi

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
# (Standard output is the compiler's alone: nothing before its first line.)
[[ $(head -n 1 "$work/version.out") == "Botlish compiler "* ]] || fail "-version does not begin with its first line: $(head -n 1 "$work/version.out")"
grep -q '^source revision: ' "$work/version.out" || fail "-version names no source revision"
grep -q '^native backend: packaged' "$work/version.out" || fail "-version names no packaged native backend"

# The packaged compiler runs only its own Tcl library (single/basekit.c,
# single/main.tcl; on macOS the launcher): a decoy library named by
# TCL_LIBRARY, by TCLLIBPATH or by the Tcl module path never runs -- each of
# its init.tcl, tclIndex, pkgIndex.tcl files and modules ends the process --
# with no locale and in a UTF-8 one. On Linux the program the compiler runs
# also sees the three variables exactly as they were set (its
# /proc/self/environ, which it copies into a file); the directory's name
# holds a non-ASCII letter and, where a file name may (not macOS), a byte
# that is no UTF-8.
decoy="$work/décoy"
(( macos )) || decoy+=$'\xff'
mkdir -p "$decoy/lib/sub" "$decoy/tm"
for file in init.tcl lib/tclIndex lib/pkgIndex.tcl lib/sub/pkgIndex.tcl tm/msgcat-9.9.tm; do
  printf '# Tcl autoload index file, version 2.0\nputs stderr "a decoy %s ran"\nexit 9\n' "$file" >"$decoy/$file"
done
cat >environ.bot <<'EOF'
import std::io::fs
import std::io::path
import std::linux::fs

fn save() errors std::io::fs::FileError, std::io::path::NotAPath:
    std::linux::fs::from_text("child-environ").write_file(std::linux::fs::from_text("/proc/self/environ").read_file())

with context std::linux::fs::create()

save():
    on std::io::fs::FileError:
        unit
    on std::io::path::NotAPath:
        unit
EOF
# LOCALE ARGS...: BOTLISH ARGS... beside the decoy, in LOCALE ("": none).
decoyed() {
  local locale=$1; shift
  env -i HOME="$work/home" ${locale:+LANG=$locale} TCL_LIBRARY="$decoy" TCLLIBPATH="$decoy/lib" \
    TCL9.0_TM_PATH="$decoy/tm" TCL9_0_TM_PATH="$decoy/tm" "$botlish" "$@" 2>&1
}
for locale in "" C.UTF-8; do
  where="with a decoy Tcl library${locale:+ in $locale}"
  out=$(decoyed "$locale" -version) && [[ $out == "Botlish compiler "* ]] || fail "-version $where: $out"
  for backend in interp cranelift; do
    out=$(decoyed "$locale" -backend "$backend" samples/01-arithmetic.bot) && grep -qx '   value: 50' <<<"$out" ||
      fail "-backend $backend $where: $out"
  done
  if (( ! macos )); then
    rm -f child-environ
    out=$(decoyed "$locale" run -warnings off environ.bot) && [[ -f child-environ ]] || fail "run environ.bot $where: $out"
    for variable in TCL_LIBRARY="$decoy" TCLLIBPATH="$decoy/lib" TCL9.0_TM_PATH="$decoy/tm" TCL9_0_TM_PATH="$decoy/tm"; do
      if ! tr '\0' '\n' <child-environ | LC_ALL=C grep -qxF -- "$variable"; then
        name=${variable%%=*}
        got=$(tr '\0' '\n' <child-environ | LC_ALL=C awk -v name="$name" 'index($0, name "=") == 1' | od -An -c | tr -s ' \n' ' ')
        fail "the program the compiler runs $where has no $name as it was set (it has: ${got:-no $name})"
      fi
    done
  fi
done
echo "   a decoy TCL_LIBRARY, TCLLIBPATH and module path: never run$( (( macos )) || echo "; the program's environment as set")"

for option in -code -hir -ast -aot -aot-spec -contexts -traits -emit-nir -emit-clif; do
  run -backend compile -warnings off "$option" samples/01-arithmetic.bot >/dev/null || fail "option $option"
done
printf 'x = \n' >broken.bot
if run broken.bot >"$work/broken.out"; then fail "a broken program was accepted"; fi
grep -q 'SURFACE SYNTAX' "$work/broken.out" || fail "a broken program reported no syntax error"

# An executable writes what its program writes and nothing else: no value
# line after it (PROGRAM-OUTPUT-MILESTONE-1.md).
programs="hello context-hello"
(( macos )) && programs=hello
if (( toolchain )); then
  for name in $programs; do
    linking -warnings off -emit-native-executable "$name.bot" >/dev/null || fail "emit $name"
    [[ $(env -i "./$name") == "Hello, world!" ]] || fail "executable $name"
  done
  # run: the program as a command -- its output only, its arguments after
  # its file, its status.
  [[ $(linking run -warnings off hello.bot) == "Hello, world!" ]] || fail "run hello.bot"
  # hello.bot (the host's: Linux's or macOS's context) printing its
  # arguments instead of its greeting.
  awk '$0 == "    std::io::print_line(\"Hello, world!\")" {
         print "    words = argv():"; print "        on InvalidArgumentEncoding:"; print "            return unit"
         print "    loop w in words:"; print "        std::io::print_line(w)"; print "    unit"; next }
       { print }' hello.bot >show-args.bot
  [[ $(linking run -warnings off show-args.bot one 'ünï cödé' -v) == "show-args.bot"$'\n'"one"$'\n'"ünï cödé"$'\n'"-v" ]] ||
    fail "run passes no arguments: $(linking run -warnings off show-args.bot one 'ünï cödé' -v 2>&1)"
  if linking run -warnings off broken.bot >"$work/run-broken.out" 2>&1; then fail "run accepted a broken program"; fi
else
  # (macOS without the developer tools.)
  if linking -warnings off -emit-native-executable hello.bot >"$work/emit.out" 2>&1; then fail "linked without developer tools"; fi
  grep -q 'NATIVE LINK TOOLCHAIN' "$work/emit.out" || { cat "$work/emit.out" >&2; fail "a link without developer tools said no NATIVE LINK TOOLCHAIN"; }
  grep -q 'xcode-select --install' "$work/emit.out" || fail "a link without developer tools names no remedy"
  if grep -qi -e rustup -e cargo "$work/emit.out"; then fail "a link without developer tools suggests Rust"; fi
  echo "   no developer tools: -emit-native-executable refused (NATIVE LINK TOOLCHAIN, xcode-select --install)"
fi
# An application module beside its entry file, from another working
# directory (IMPORTS.md, "Application modules"), 3000 calls deep on every
# backend (the interpreter's recursion limit: core/core.tcl).
mkdir -p "$work/app"
printf 'fn count(k: int) -> int:\n    if k == 0:\n        return 0\n    1 + count(k - 1)\n' >"$work/app/counter.bot"
printf 'import counter\n\ncounter::count(3000)\n' >"$work/app/value.bot"
for backend in interp compile cranelift-generic cranelift; do
  out=$(cd / && run -backend "$backend" "$work/app/value.bot") && grep -qx '   value: 3000' <<<"$out" ||
    fail "an application module on $backend"
done
# Non-ASCII directory names and arguments with no locale at all: file names
# and arguments are UTF-8 bytes whatever the locale says.
mkdir -p "$work/ünï cödé"
printf 'fn count(k: int) -> int:\n    if k == 0:\n        return 0\n    1 + count(k - 1)\n' >"$work/ünï cödé/counter.bot"
printf 'import counter\n\ncounter::count(42)\n' >"$work/ünï cödé/answer.bot"
for backend in interp cranelift; do
  out=$(cd / && run -backend "$backend" "$work/ünï cödé/answer.bot") && grep -qx '   value: 42' <<<"$out" ||
    fail "a program in a non-ASCII directory, with no locale, on $backend"
done
printf 'argv():\n    on InvalidArgumentEncoding:\n        ["invalid"]\n' >"$work/ünï cödé/args.bot"
out=$(cd "$work/ünï cödé" && run -argv 'ünï cödé' args.bot) && grep -qxF '   value: ["ünï cödé"]' <<<"$out" ||
  fail "a non-ASCII argument with no locale"
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
  out=$(cd "$work/app" && run -backend "$backend" "$work/app/both.bot") && grep -qxF '   value: [99, 2]' <<<"$out" ||
    fail "a local list beside std::list on $backend"
done
printf 'import std::nosuch\n\n1\n' >"$work/app/nostd.bot"
if run "$work/app/nostd.bot" >"$work/nostd.out"; then fail "a missing standard namespace was accepted"; fi
grep -qF "no such module file //zipfs:/app/botlish/stdlib/nosuch.bot" "$work/nostd.out" ||
  fail "the standard library is not read from inside the executable"
# A native run shows the program's output, then its value (on macOS the
# program's Darwin IO is C: the backend links it to run it).
if (( toolchain )); then
  for backend in cranelift cranelift-generic; do
    [[ $(linking -backend "$backend" hello.bot) == "== hello.bot ($backend)"$'\n'"Hello, world!"$'\n'"   value: unit" ]] ||
      fail "-backend $backend shows no program output"
  done
fi
# Without HOME the native backend lives in a temporary directory for the run
# (the single executable's; the application needs none).
if (( toolchain )); then
  if (( macos )); then
    env -i PATH=/usr/bin:/bin "$botlish" -warnings off -emit-native-executable hello.bot >/dev/null || fail "emit without HOME"
  else
    env -i "$botlish" -warnings off -emit-native-executable hello.bot >/dev/null || fail "emit without HOME"
  fi
  [[ $(env -i ./hello) == 'Hello, world!' ]] || fail "executable built without HOME"
fi
env -i "$botlish" -backend cranelift samples/01-arithmetic.bot >"$work/nohome.out" || fail "cranelift without HOME"
grep -q 'value: 50' "$work/nohome.out" || fail "cranelift without HOME: wrong value"

# A program that calls C needs the host's C compiler driver (the system
# linker, SINGLE-EXECUTABLE-FFI-MILESTONE-1.md): without one -- this
# environment's -- its native link says so, and links nothing.
# single/ffi-smoke-test.sh checks the link where there is one.
printf 'import std::ffi::c\n\nextern c fn labs(x: std::ffi::c::Long) -> std::ffi::c::Long\n\nlabs(0 - 5)\n' >labs.bot
if run -warnings off -emit-native-executable labs.bot >"$work/labs.out" 2>&1; then fail "a C program linked without a C compiler"; fi
grep -q "needs a C compiler driver to link an executable for $target, and there is none: no cc on PATH.*(NATIVE LINK TOOLCHAIN)" "$work/labs.out" ||
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
# (Nothing but protocol messages on standard output: the first byte is a
# message's header's.)
[[ $(head -c 16 "$work/lsp.out") == "Content-Length: " ]] || fail "-lsp wrote something else than a message first: $(head -c 60 "$work/lsp.out")"
grep -qF '"id":2,"result":{"contents":{"kind":"plaintext","value":"fn shapes::area(w: int, h: int) -> int"}' "$work/lsp.out" ||
  fail "-lsp hover"
grep -qF 'unbound name \"nosuch\"' "$work/lsp.out" || fail "-lsp published no diagnostic"
definition=$(grep -oE '"id":3,"result":\{"uri":"file://[^"]*/list.bot"' "$work/lsp.out" | sed -E 's|.*"file://||; s|"$||')
[[ -n $definition && -f $definition && $definition != *zipfs* ]] || fail "-lsp definition into std:: ($definition)"
if (( macos )); then
  [[ $definition == "$work/home/Library/Caches/botlish/"* ]] || fail "-lsp copied the standard library outside ~/Library/Caches/botlish ($definition)"
fi
grep -q 'analysis worker started' "$work/lsp.err" || fail "-lsp started no worker"
echo "   -lsp: hover, diagnostics, definition into $definition"

# The package manager (PACKAGE-MANAGER-MILESTONE-1.md): a pure-Botlish
# package packed, added from a local repository and verified with no
# toolchain, and no package command installs the native backend (it never
# compiles anything: single/main.tcl).
mkdir -p "$work/pkgsrc/geometry" "$work/pkgrepo" "$work/pkgapp"
printf '{"schema": 1, "name": "geometry", "version": "1.0.0"}\n' >"$work/pkgsrc/geometry/botlish.json"
printf 'fn area(w: int, h: int) -> int:\n    w * h\n' >"$work/pkgsrc/geometry/geometry.bot"
printf 'import geometry\n\ngeometry::area(6, 7)\n' >"$work/pkgapp/main.bot"
pm() { env -i HOME="$work/home-pm" "$botlish" "$@"; }
pm package pack "$work/pkgsrc/geometry" -out "$work/pkgrepo" >/dev/null || fail "package pack"
pm add geometry -project "$work/pkgapp" -repository "$work/pkgrepo" >/dev/null || fail "add"
pm verify -project "$work/pkgapp" -repository "$work/pkgrepo" >/dev/null || fail "verify"
[[ ! -e $work/home-pm/.cache ]] || fail "a package command installed the native backend ($(ls "$work/home-pm/.cache"))"
out=$(run -warnings off "$work/pkgapp/main.bot") && grep -qF 'value: 42' <<<"$out" || fail "a program over an installed package"
echo "   packages: pack, add, verify, with no native backend installed"

# Shared dependencies (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md): two
# packages locking the same geometry share one instance -- a Point one makes
# is the Point the other takes -- and package graph says so; a third
# locking another release is a DEPENDENCY-CONFLICT.
mkdir -p "$work/pkgsrc/geometry2" "$work/pkgsrc/shapes" "$work/pkgsrc/tiles" "$work/pkgsrc/clash" "$work/pkgapp3"
printf '{"schema": 1, "name": "geometry", "version": "2.0.0"}\n' >"$work/pkgsrc/geometry2/botlish.json"
printf 'fn area(w: int, h: int) -> int:\n    0\n' >"$work/pkgsrc/geometry2/geometry.bot"
printf 'struct P:\n    x: int\n' >>"$work/pkgsrc/geometry/geometry.bot"
pm package pack "$work/pkgsrc/geometry" -out "$work/pkgrepo" -force >/dev/null || fail "package pack (geometry with P)"
pm package pack "$work/pkgsrc/geometry2" -out "$work/pkgrepo" >/dev/null || fail "package pack (geometry 2.0.0)"
for p in shapes:'import geometry\n\nfn make(n: int) -> geometry::P:\n    geometry::P {x: n}\n' tiles:'import geometry\n\nfn read(p: geometry::P) -> int:\n    p.x * 2\n'; do
  name=${p%%:*}
  printf '{"schema": 1, "name": "%s", "version": "1.0.0", "dependencies": {"geometry": "1.0"}, "lock": {"geometry": "1.0.0"}}\n' "$name" >"$work/pkgsrc/$name/botlish.json"
  printf "${p#*:}" >"$work/pkgsrc/$name/$name.bot"
  pm package pack "$work/pkgsrc/$name" -out "$work/pkgrepo" >/dev/null || fail "package pack ($name)"
done
printf '{"schema": 1, "name": "clash", "version": "1.0.0", "dependencies": {"geometry": "2.0"}, "lock": {"geometry": "2.0.0"}}\n' >"$work/pkgsrc/clash/botlish.json"
printf 'fn c() -> int:\n    1\n' >"$work/pkgsrc/clash/clash.bot"
pm package pack "$work/pkgsrc/clash" -out "$work/pkgrepo" >/dev/null || fail "package pack (clash)"
printf 'import shapes\nimport tiles\n\ntiles::read(shapes::make(21))\n' >"$work/pkgapp3/main.bot"
pm add shapes -project "$work/pkgapp3" -repository "$work/pkgrepo" >/dev/null || fail "add shapes"
pm add tiles -project "$work/pkgapp3" -repository "$work/pkgrepo" >/dev/null || fail "add tiles"
out=$(pm package graph -project "$work/pkgapp3") && grep -qF 'shared: one instance, geometry, for shapes, tiles' <<<"$out" || fail "package graph shows the shared geometry"
out=$(run -warnings off "$work/pkgapp3/main.bot") && grep -qF 'value: 42' <<<"$out" || fail "a program over two packages sharing geometry"
if pm add clash -project "$work/pkgapp3" -repository "$work/pkgrepo" 2>"$work/clash.err" >/dev/null; then fail "add clash succeeded"; fi
grep -qF '(PM DEPENDENCY-CONFLICT)' "$work/clash.err" || fail "add clash is no DEPENDENCY-CONFLICT ($(cat "$work/clash.err"))"
[[ ! -e $work/home-pm/.cache ]] || fail "a package command installed the native backend ($(ls "$work/home-pm/.cache"))"
echo "   packages: two packages sharing one geometry; a conflicting lock refused"

# PM-2 (PACKAGE-MANAGER-MILESTONE-2.md): a target-aware package -- one
# release for two targets -- packed, added, a second target's view
# prepared, each target's program compiled from its own view, and a native
# file inspected, still with no native backend installed.
mkdir -p "$work/pkgsrc/geo/targets/linux-x86_64/geo" "$work/pkgsrc/geo/targets/linux-aarch64/geo" "$work/pkgapp2"
printf '{"schema": 2, "name": "geo", "version": "1.0.0", "targets": {"linux-x86_64": {"files": "targets/linux-x86_64"}, "linux-aarch64": {"files": "targets/linux-aarch64"}}}\n' >"$work/pkgsrc/geo/botlish.json"
printf 'import geo::arch\n\nfn which() -> str:\n    geo::arch::name()\n' >"$work/pkgsrc/geo/geo.bot"
printf 'fn name() -> str:\n    "x86-64"\n' >"$work/pkgsrc/geo/targets/linux-x86_64/geo/arch.bot"
printf 'fn name() -> str:\n    "aarch64"\n' >"$work/pkgsrc/geo/targets/linux-aarch64/geo/arch.bot"
printf 'import geo\n\ngeo::which()\n' >"$work/pkgapp2/main.bot"
pm package pack "$work/pkgsrc/geo" -out "$work/pkgrepo" >/dev/null || fail "package pack (schema 2)"
pm add geo -project "$work/pkgapp2" -repository "$work/pkgrepo" -target linux-x86_64 -target linux-aarch64 >/dev/null || fail "add -target"
pm verify -project "$work/pkgapp2" -target linux-x86_64 >/dev/null || fail "verify -target"
pm native inspect "$botlish" >/dev/null || fail "native inspect"
[[ ! -e $work/home-pm/.cache ]] || fail "a package command installed the native backend ($(ls "$work/home-pm/.cache"))"
out=$(run -warnings off -target linux-x86_64 "$work/pkgapp2/main.bot") && grep -qF 'value: "x86-64"' <<<"$out" || fail "the linux-x86_64 view"
out=$(run -warnings off -target linux-aarch64 "$work/pkgapp2/main.bot") && grep -qF 'value: "aarch64"' <<<"$out" || fail "the linux-aarch64 view"
echo "   packages: a two-target release, its views and native inspect, with no native backend installed"

# PM-3 (PACKAGE-MANAGER-MILESTONE-3.md): authoring a native package -- a
# built library imported (here the system's own zlib, copied: a real ELF
# file, its facts read from it), the package audited, packed with a
# provenance record and the record checked against the artifact -- with no
# C compiler and still no native backend installed (Linux: the library is
# an ELF file of this host's target).
if [[ $(uname -s) == Linux ]]; then
  case $(uname -m) in x86_64) ztarget=linux-x86_64 ;; aarch64) ztarget=linux-aarch64 ;; *) ztarget="" ;; esac
  # This host's own zlib, the first candidate that exists (a loop, not
  # `ls A B | head -1`: ls fails when either is missing, and set -e then
  # ended the script without a word).
  libz=""
  for candidate in "/lib/$(uname -m)-linux-gnu/libz.so.1" "/usr/lib/$(uname -m)-linux-gnu/libz.so.1"; do
    if [[ -e $candidate ]]; then libz=$candidate; break; fi
  done
  if [[ -n $ztarget && -n $libz ]]; then
    mkdir -p "$work/pkgsrc/zpkg" "$work/zbuild"
    cp -L "$libz" "$work/zbuild/libz.so.1"
    printf '{"schema": 1, "name": "zpkg", "version": "1.0.0"}\n' >"$work/pkgsrc/zpkg/botlish.json"
    printf 'extern c library "z"\n\nfn n() -> int:\n    1\n' >"$work/pkgsrc/zpkg/zpkg.bot"
    printf '{"evidence": 1, "builds": [{"name": "zlib", "outputs": ["targets/%s/native/libz.so.1"], "notes": "the system zlib, copied"}]}\n' "$ztarget" >"$work/zbuild/evidence.json"
    pm native add "$work/zbuild/libz.so.1" -target "$ztarget" -name z -symbol inflate -license Zlib -package "$work/pkgsrc/zpkg" >/dev/null || fail "native add"
    out=$(pm native audit "$work/pkgsrc/zpkg") && grep -q "target $ztarget: complete" <<<"$out" || fail "native audit"
    pm package pack "$work/pkgsrc/zpkg" -out "$work/pkgrepo" -evidence "$work/zbuild/evidence.json" >/dev/null || fail "package pack -evidence"
    out=$(pm package inspect "$work/pkgrepo/zpkg-1.0.0.botpkg" -provenance "$work/pkgrepo/zpkg-1.0.0.provenance.json") && grep -q "describes this artifact" <<<"$out" || fail "package inspect -provenance"
    [[ ! -e $work/home-pm/.cache ]] || fail "an authoring command installed the native backend ($(ls "$work/home-pm/.cache"))"
    echo "   packages: native add, audit, pack -evidence, inspect -provenance, with no compiler or native backend"
  else
    echo "   packages: native authoring not checked (no zlib of this host's target, $(uname -m))"
  fi
fi

echo "== smoke test passed"
