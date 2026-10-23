#!/usr/bin/env bash
# single/ffi-smoke-test.sh -- checks that a single-file Botlish compiler links
# programs that call C (SINGLE-EXECUTABLE-FFI-MILESTONE-1.md).
#
#   single/ffi-smoke-test.sh BOTLISH [FIXTURE.c]
#
# Runs BOTLISH, the executable single/build.sh built, as a user with a C
# toolchain but no Rust and no Botlish checkout would: from a private
# directory holding only the compiler, the applications' sources and the C
# library they declare, with PATH holding the host's C compiler driver (cc)
# and its linker, and no rustc or cargo reachable (checked: the script fails
# if PATH has either). FIXTURE.c defaults to this checkout's
# tests/cffi/fixture.c; copy it beside the script to run with no checkout at
# all (.github/workflows/single-executable.yml runs it so, in a stock
# ubuntu:24.04 container with gcc installed, the checkout deleted first).
#
# The applications, each built with the packed compiler
# (-emit-native-executable, which picks the system linker for a program that
# calls C and the stub for any other):
#
#   A  a system C library's function (libc's labs)
#   B  a static C library (the fixture, libbotlish_cffi_fixture.a, through -L)
#      and a second one depending on it, declared in the order that needs
#      GNU ld's group
#   C  borrowed Bytes and MutableBytes (bcf_sum reads, bcf_fill writes)
#   D  errno read right after a failed call, and the (size_t)-1 sentinel
#   E  portable IO that calls no C: still the stub linker, built with no C
#      compiler on PATH at all -- on x86-64, where the stub runs; on AArch64,
#      which has no stub, the system linker (auto's choice there)
#
# Checked for each: the build needs no rustc (nothing on PATH, no Rust
# process started: strace when present), the executable runs -- also under
# GC stress, also with the compiler, its cache and the C libraries deleted --
# with the expected output and status, names no Botlish or fixture library
# among its dynamic dependencies, and no temporary directory is left behind.
# Then the failures: no C compiler driver, a missing library, an undefined
# symbol (each NATIVE LINK, saying what is missing), and a failed link
# keeping the previous executable.
set -euo pipefail

source_botlish=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fixture=${2:-$root/tests/cffi/fixture.c}
[[ -f $fixture ]] || { echo "no C fixture at $fixture" >&2; exit 2; }
work=$(mktemp -d "${TMPDIR:-/tmp}/botlish-ffi-smoke.XXXXXX")
trap 'rm -rf "$work"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

# The compiler is copied in: it is deleted before the executables run.
mkdir -p "$work/bin" "$work/home" "$work/lib" "$work/app"
cp "$source_botlish" "$work/bin/botlish"
botlish=$work/bin/botlish

# PATH: the C toolchain the system linker runs, nothing of Rust's.
cc_path=$(command -v cc) || fail "no cc on PATH: this smoke test needs a C toolchain"
path=$(dirname "$cc_path")
for tool in ld readelf strace; do
  if found=$(command -v "$tool"); then
    case ":$path:" in *":$(dirname "$found"):"*) ;; *) path=$path:$(dirname "$found") ;; esac
  fi
done
for tool in rustc cargo; do
  if PATH=$path command -v "$tool" >/dev/null 2>&1; then
    fail "$tool is on the test's PATH ($path): this smoke test proves the link needs no Rust"
  fi
done
echo "== $source_botlish"
echo "   PATH=$path"
echo "   cc: $(cc --version | head -n 1)"

# BOTLISH ARGS... in an environment of the C toolchain's PATH and a fresh HOME.
run() { env -i HOME="$work/home" PATH="$path" "$botlish" "$@"; }

# The C libraries, built here with the host's cc.
cp "$fixture" "$work/lib/fixture.c"
printf 'int bcf_add(int a, int b);\nint bcf_add_twice(int a, int b) { return 2 * bcf_add(a, b); }\n' >"$work/lib/dependent.c"
(cd "$work/lib" && cc -O2 -fPIC -c fixture.c && cc -O2 -fPIC -c dependent.c &&
  ar rcs libbotlish_cffi_fixture.a fixture.o && ar rcs libbotlish_cffi_dependent.a dependent.o)

cd "$work/app"
cat >acc.bot <<'EOF'
direct module
import std::abi
import std::abi::bytes
import std::binary
import std::binary::native
import std::ffi::c

extern c library "botlish_cffi_dependent"
extern c library "botlish_cffi_fixture"

extern c fn labs(x: std::ffi::c::Long) -> std::ffi::c::Long
extern c fn add named "bcf_add"(a: std::ffi::c::Int, b: std::ffi::c::Int) -> std::ffi::c::Int
extern c fn add_twice named "bcf_add_twice"(a: std::ffi::c::Int, b: std::ffi::c::Int) -> std::ffi::c::Int
extern c fn sum named "bcf_sum"(data: std::ffi::c::Ptr[std::ffi::c::UChar] read noescape, count: std::ffi::c::ULong) -> std::ffi::c::ULong
extern c fn fill named "bcf_fill"(out: std::ffi::c::Ptr[std::ffi::c::UChar] write noescape, count: std::ffi::c::ULong, seed: std::ffi::c::UChar) -> unit
extern c fn fill_errno named "bcf_fill_errno"(out: std::ffi::c::Ptr[std::ffi::c::UChar] write noescape, count: std::ffi::c::ULong, seed: std::ffi::c::UChar, err: std::ffi::c::Int, stale: std::ffi::c::Int) -> std::ffi::c::Long
extern c fn large_error named "bcf_large_error"(failing: std::ffi::c::Int) -> std::ffi::c::ULong
extern c fn vsum named "bcf_vsum"(count: std::ffi::c::Int, variadic) -> std::ffi::c::LongLong
extern c fn c_errno_location named "__errno_location"() -> std::ffi::c::Ptr[std::ffi::c::Int] independent

layout ErrnoCell:
    size 4
    align 4
    field value: std::ffi::c::Int at 0

fn errno() -> int:
    location = c_errno_location()
    cell = std::binary::native::view(ErrnoCell, location):
        on NativeViewNull:
            return 0
    cell.value

fn c_int(x: std::ffi::c::Int) -> std::ffi::c::Int:
    x

fn length(d: std::abi::bytes::Bytes) -> std::ffi::c::ULong:
    std::abi::bytes::length(d).value

fn mlength(d: std::abi::bytes::MutableBytes) -> std::ffi::c::ULong:
    std::abi::bytes::mutable_length(d).value

fn checksum(d: std::abi::bytes::MutableBytes) -> std::ffi::c::ULong:
    frozen = std::abi::bytes::freeze(d)
    sum(frozen, length(frozen))

fn fill_or_errno(data: std::abi::bytes::MutableBytes, err: std::ffi::c::Int) -> list:
    r = fill_errno(data, mlength(data), 7, err, 0)
    if r.result < 0:
        failure = errno()
        return [r.result, failure, checksum(r.out)]
    [r.result, 0, checksum(r.out)]

fn large(failing: std::ffi::c::Int) -> list:
    r = large_error(failing)
    if r == 18446744073709551615:
        failure = errno()
        return [r, failure]
    [r, 0]
EOF
prelude='direct module
import std::abi
import std::abi::bytes
import std::byte
import std::ffi::c
import acc

fn pattern(n: int):
    loop i from 0 to n:
        std::byte::from_int(mod(i * 7 + 3, 256))
'
printf '%s\nacc::labs(0 - 42)\n' "$prelude" >a.bot
printf '%s\n[acc::add(40, 2), acc::add_twice(20, 1), acc::vsum(3, acc::c_int(1), acc::c_int(20), acc::c_int(300))]\n' "$prelude" >b.bot
printf '%s\ndata = std::abi::bytes::from_list(pattern(300))\nout = std::abi::bytes::from_bytes(std::abi::bytes::from_list(pattern(16)))\nfilled = acc::fill(out, acc::mlength(out), 9)\n[acc::sum(data, acc::length(data)), acc::checksum(filled.out), acc::checksum(out)]\n' "$prelude" >c.bot
printf '%s\nout = std::abi::bytes::from_bytes(std::abi::bytes::from_list(pattern(16)))\n[acc::fill_or_errno(out, 0), acc::fill_or_errno(out, 34), acc::large(5), acc::large(0)]\n' "$prelude" >d.bot
cat >e.bot <<'EOF'
import std::io
import std::linux::io

fn hello() errors std::io::WriteFailed:
    std::io::print_line("Hello from the stub linker")

with context std::linux::io::create()

hello():
    on std::io::WriteFailed:
        unit
EOF
# The expected outputs: the C fixture's own arithmetic (tests/cffi/fixture.c).
declare -A expected=(
  [a]=42
  [b]='[42, 42, 321]'
  [c]='[37602, 1768, 888]'
  [d]='[[16, 0, 1736], [-1, 34, 1736], [18446744073709551615, 5], [42, 0]]'
  [e]=$'Hello from the stub linker\nunit'
)

for name in a b c d; do
  if [[ -n $(command -v strace) ]]; then
    env -i HOME="$work/home" PATH="$path" strace -f -qq -e trace=execve -o "$work/$name.trace" \
      "$botlish" -warnings off -L "$work/lib" -emit-native-executable "$name.bot" >/dev/null || fail "build $name"
    if grep -E 'execve\("[^"]*/(rustc|cargo)"' "$work/$name.trace"; then fail "building $name ran Rust"; fi
    grep -q 'execve("[^"]*/cc"' "$work/$name.trace" || fail "building $name ran no cc (not the system linker?)"
  else
    run -warnings off -L "$work/lib" -emit-native-executable "$name.bot" >/dev/null || fail "build $name"
  fi
  if tail -c 8 "$name" | grep -q BOTLIMG1; then fail "$name was stub-linked"; fi
  echo "   built $name ($(stat -c %s "$name") bytes)"
done
# E: no C compiler at all on PATH, and still an executable (the stub, on
# x86-64); on AArch64 the system linker links it.
if [[ $(uname -m) == x86_64 ]]; then
  env -i HOME="$work/home" PATH=/nonexistent "$botlish" -warnings off -emit-native-executable e.bot >/dev/null || fail "build e without a C compiler"
  [[ $(tail -c 8 e) == BOTLIMG1 ]] || fail "e was not stub-linked"
  echo "   built e ($(stat -c %s e) bytes, stub-linked, no C compiler on PATH)"
else
  run -warnings off -emit-native-executable e.bot >/dev/null || fail "build e"
  if tail -c 8 e | grep -q BOTLIMG1; then fail "e was stub-linked on $(uname -m)"; fi
  echo "   built e ($(stat -c %s e) bytes, system-linked: no stub on $(uname -m))"
fi

# No temporary directory left beside the outputs.
if compgen -G '.botlish-aot-*' >/dev/null; then fail "a link left its work directory"; fi

# The executables need nothing of the compiler: delete it, its cache and the
# C libraries, then run them, plainly and under GC stress.
rm -rf "$work/bin" "$work/home"/.cache "$work/lib"
for name in a b c d e; do
  got=$(env -i "./$name") || fail "executable $name failed"
  want=${expected[$name]}
  [[ $got == "$want" ]] || fail "executable $name printed '$got', not '$want'"
  stressed=$(env -i BOTLISH_NATIVE_GC_STRESS=1 "./$name") || fail "executable $name failed under GC stress"
  [[ $stressed == "$got" ]] || fail "executable $name under GC stress printed '$stressed'"
  if command -v readelf >/dev/null; then
    needed=$(readelf -d "$name" | sed -n 's/.*(NEEDED).*\[\(.*\)\]/\1/p' | tr '\n' ' ')
    if [[ $needed == *botlish* || $needed == *cffi* ]]; then fail "executable $name needs $needed"; fi
    echo "   ran $name: ${got//$'\n'/ | }  (needs: $needed)"
  else
    echo "   ran $name: ${got//$'\n'/ | }"
  fi
done

# Failures, with a compiler again.
cp "$source_botlish" "$work/botlish2"
botlish=$work/botlish2
mkdir -p "$work/lib"
cp "$fixture" "$work/lib/fixture.c"
printf 'int bcf_add(int a, int b);\nint bcf_add_twice(int a, int b) { return 2 * bcf_add(a, b); }\n' >"$work/lib/dependent.c"
(cd "$work/lib" && cc -O2 -fPIC -c fixture.c && cc -O2 -fPIC -c dependent.c &&
  ar rcs libbotlish_cffi_fixture.a fixture.o && ar rcs libbotlish_cffi_dependent.a dependent.o)
cp a a.previous
expect_failure() { # NAME PATTERN ARGS...
  local name=$1 pattern=$2
  shift 2
  if "$@" >"$work/out" 2>&1; then fail "$name: accepted"; fi
  grep -q -- "$pattern" "$work/out" || { cat "$work/out" >&2; fail "$name: no '$pattern'"; }
  echo "   refused $name: $(grep -m1 -o -- "$pattern" "$work/out")"
}
expect_failure "no C compiler" "NATIVE LINK TOOLCHAIN" \
  env -i HOME="$work/home" PATH=/nonexistent "$botlish" -warnings off -L "$work/lib" -emit-native-executable a.bot
cmp -s a a.previous || fail "a failed link replaced the previous executable"
printf 'extern c library "definitely_missing_botlish_lib"\n1 + 1\n' >missing.bot
expect_failure "a missing library" "definitely_missing_botlish_lib" \
  env -i HOME="$work/home" PATH="$path" "$botlish" -warnings off -emit-native-executable missing.bot
printf 'import std::ffi::c\n\nextern c library "botlish_cffi_fixture"\nextern c fn nope named "botlish_no_such_symbol"(x: std::ffi::c::Int) -> std::ffi::c::Int\n\nnope(1)\n' >undefined.bot
expect_failure "an undefined symbol" "botlish_no_such_symbol" \
  env -i HOME="$work/home" PATH="$path" "$botlish" -warnings off -L "$work/lib" -emit-native-executable undefined.bot
# A native backend's run of a program that calls C, with a cache this run
# fills itself: the runtime archive installed for it, the program linked,
# then run.
[[ $(env -i HOME="$work/home-run" PATH="$path" "$botlish" -backend cranelift -warnings off -L "$work/lib" b.bot) == \
   "== b.bot (cranelift)"$'\n'"   value: ${expected[b]}" ]] || fail "-backend cranelift of b"
echo "   ran b on -backend cranelift"
# An explicit linker is the user's: BOTLISH_NATIVE_LINKER=stub refuses C.
expect_failure "the stub linker, chosen" "the stub linker (BOTLISH_NATIVE_LINKER=stub) links no native library" \
  env -i HOME="$work/home" PATH="$path" BOTLISH_NATIVE_LINKER=stub "$botlish" -warnings off -L "$work/lib" -emit-native-executable a.bot
if compgen -G '.botlish-aot-*' >/dev/null; then fail "a failed link left its work directory"; fi
echo "ok"
