#!/usr/bin/env bash
# single/macos/compare.sh -- the macOS application's compiler against this
# checkout's (MACOS-AARCH64-MILESTONE-9.md, "The checkout and the
# application").
#
#   single/macos/compare.sh TCLSH APP
#
# Runs a fixed set of programs through this checkout's main.tcl (with TCLSH,
# a Tcl 9.0.1, and native/target/release's driver) and through APP's
# launcher, in the same directory and the same environment, and requires the
# same standard output, standard error and exit status from both, after one
# normalization: the compiler's own location (the checkout's directory, the
# application's //zipfs:/app/botlish) and invocation ("tclsh9.0 main.tcl",
# "botlish") are written alike -- and for Compilerpedia and the usage, whose
# text is wrapped to a width, line breaks and runs of spaces too. Compared:
#
#   * every backend's run of the sample programs (examples/surface,
#     examples/stdlib) and audit/macos-app/programs (coroutines, closures, a
#     context, a native stack overflow), the native ones also under
#     BOTLISH_NATIVE_GC_STRESS=1; the 2048 benchmark on cranelift;
#     examples/io/hello-darwin.bot (Darwin IO: a linked run) on both native
#     backends;
#   * diagnostics: a syntax error, a type error, a missing module, the
#     warnings a standard-library module reports in its own source, -check;
#   * -emit-nir of three programs; -help (Compilerpedia: its indices and
#     five pages) and the usage summary;
#   * standalone executables of four programs, linked by each (the system
#     linker): their output, status and startup report
#     (BOTLISH_NATIVE_STARTUP_REPORT), plainly and under GC stress.
#
# Needs Apple's C compiler driver (the system linker's) on /usr/bin.
set -euo pipefail

[[ $# -eq 2 ]] || { echo "usage: single/macos/compare.sh TCLSH APP" >&2; exit 2; }
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
tclsh=$1
botlish=$(cd "$2" && pwd -P)/Contents/MacOS/botlish
[[ -x $botlish ]] || { echo "no launcher at $botlish" >&2; exit 2; }
work=$(cd "$(mktemp -d "${TMPDIR:-/tmp}/botlish-compare.XXXXXX")" && pwd -P)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/home" "$work/p"
cp "$root"/examples/surface/*.bot "$root"/examples/stdlib/*.bot "$root"/audit/macos-app/programs/*.bot "$work/p/"
cp "$root/examples/io/hello-darwin.bot" "$root/examples/games/2048/bench.bot" "$root/examples/games/2048/game2048.bot" "$work/p/"
printf 'x = \n' >"$work/p/syntax-error.bot"
printf 'fn f(n: int) -> str:\n    n + 1\n\nf(2)\n' >"$work/p/type-error.bot"
printf 'import nosuch\n\n1\n' >"$work/p/missing-module.bot"
printf 'import std::web\n\n1\n' >"$work/p/library-warnings.bot"
cd "$work/p"

fail() { echo "FAIL[compare]: $*" >&2; exit 1; }
compared=0
reflowed=0
# The checkout's and the application's run of ARGS..., compared. With
# GC=1 under GC stress. Each run's environment: a fresh HOME, PATH with the
# C compiler driver, a UTF-8 locale, the system linker (the application's
# auto is the system linker on macOS; the checkout's default is rustc).
both() {
  local gc=$1 label=$2
  shift 2
  local env=(env -i HOME="$work/home" PATH=/usr/bin:/bin LANG=en_US.UTF-8 BOTLISH_NATIVE_LINKER=system)
  (( gc )) && env+=(BOTLISH_NATIVE_GC_STRESS=1)
  local status
  status=0; "${env[@]}" "$tclsh" "$root/main.tcl" "$@" >"$work/c.out" 2>"$work/c.err" || status=$?
  echo "status $status" >>"$work/c.out"
  status=0; "${env[@]}" "$botlish" "$@" >"$work/a.out" 2>"$work/a.err" || status=$?
  echo "status $status" >>"$work/a.out"
  for stream in out err; do
    sed -e "s|$root/|//zipfs:/app/botlish/|g" -e 's|tclsh9.0 main.tcl|botlish|g' "$work/c.$stream" >"$work/c.$stream.n"
    # (Both sides: Compilerpedia's text names both invocations itself.)
    sed -e 's|tclsh9.0 main.tcl|botlish|g' "$work/a.$stream" >"$work/a.$stream.n"
    if (( reflowed )); then
      # (Text wrapped to a width: the invocation's length moves the breaks.)
      for which in c a; do tr -s ' \n' '  ' <"$work/$which.$stream.n" >"$work/$which.$stream.f" && mv "$work/$which.$stream.f" "$work/$which.$stream.n"; done
    fi
    if ! cmp -s "$work/c.$stream.n" "$work/a.$stream.n"; then
      diff "$work/c.$stream.n" "$work/a.$stream.n" | head -20 >&2
      fail "$label: the application's std$stream differs from the checkout's (above: < checkout, > application)"
    fi
  done
  compared=$((compared + 1))
}

samples=$(ls [01]*.bot csv*.bot ai_text_clean.bot hashtable.bot matmul.bot string_*.bot)
for backend in interp compile cranelift cranelift-generic; do
  for program in $samples; do
    both 0 "$program on $backend" -backend "$backend" "$program"
  done
done
echo "   the samples on every backend: $compared runs alike"
for program in coroutine.bot closures.bot context.bot overflow.bot; do
  for backend in interp compile cranelift cranelift-generic; do
    [[ $program == overflow.bot && $backend != cranelift* ]] && continue
    both 0 "$program on $backend" -backend "$backend" "$program"
  done
  for backend in cranelift cranelift-generic; do
    both 1 "$program on $backend under GC stress" -backend "$backend" "$program"
  done
done
for backend in interp cranelift; do
  both 0 "args.bot on $backend" -backend "$backend" -argv 'ünï cödé' -argv '' -argv-hex 41ff args.bot
done
both 0 "the 2048 benchmark" -backend cranelift bench.bot
for backend in cranelift cranelift-generic; do
  both 0 "hello-darwin.bot on $backend" -backend "$backend" hello-darwin.bot
  both 1 "hello-darwin.bot on $backend under GC stress" -backend "$backend" hello-darwin.bot
done
echo "   the acceptance programs, natively also under GC stress: $compared runs alike"
for program in syntax-error.bot type-error.bot missing-module.bot library-warnings.bot; do
  both 0 "the diagnostics of $program" "$program"
  both 0 "-check of $program" -check "$program"
done
# (The library's own warnings are located in the packed library.)
grep -q '//zipfs:/app/botlish/stdlib/web.bot' "$work/a.out" "$work/a.err" ||
  fail "std::web's warnings are not located in the application's standard library"
both 0 "-check of the samples" -check $samples
for program in coroutine.bot context.bot hello-darwin.bot; do
  both 0 "-emit-nir of $program" -emit-nir -backend interp "$program"
done
reflowed=1
for query in "" warnings cli.options std::list::at KNOWN-ERROR "bounds proof"; do
  if [[ -z $query ]]; then both 0 "-help" -help; else both 0 "-help $query" -help "$query"; fi
done
both 0 "the usage summary"
reflowed=0
echo "   diagnostics, -check, NIR, Compilerpedia and the usage: $compared runs alike"

# Executables: each compiler links its own; outputs, statuses and startup
# reports must agree.
for program in coroutine.bot context.bot hello-darwin.bot overflow.bot; do
  name=${program%.bot}
  env -i HOME="$work/home" PATH=/usr/bin:/bin LANG=en_US.UTF-8 BOTLISH_NATIVE_LINKER=system \
    "$tclsh" "$root/main.tcl" -warnings off -emit-native-executable "$program" >/dev/null || fail "the checkout cannot link $program"
  mv "$name" "$name.checkout"
  env -i HOME="$work/home" PATH=/usr/bin:/bin "$botlish" -warnings off -emit-native-executable "$program" >/dev/null ||
    fail "the application cannot link $program"
  mv "$name" "$name.app"
  for gc in 0 1; do
    for which in checkout app; do
      status=0
      rm -f "$work/$which.report"
      env -i BOTLISH_NATIVE_GC_STRESS=$gc BOTLISH_NATIVE_STARTUP_REPORT="$work/$which.report" "./$name.$which" one "two words" \
        >"$work/$which.out" 2>"$work/$which.err" || status=$?
      echo "status $status" >>"$work/$which.out"
    done
    [[ -s $work/app.report ]] || fail "$name's executable wrote no startup report"
    for stream in out err report; do
      cmp -s "$work/checkout.$stream" "$work/app.$stream" ||
        { diff "$work/checkout.$stream" "$work/app.$stream" | head -20 >&2; fail "$name's executables differ (std$stream, GC stress $gc)"; }
    done
  done
  compared=$((compared + 1))
done
echo "   standalone executables (output, status, startup report, GC stress): alike"
echo "== compare: $compared comparisons, the application and the checkout alike"
