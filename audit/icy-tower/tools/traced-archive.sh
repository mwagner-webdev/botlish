#!/usr/bin/env bash
# traced-archive.sh -- SDL3's static archive with the SDL call trace's
# link-time wrappers in it (ICY-TOWER-MACOS-MILESTONE-1.md, "SDL call
# trace"): the probe build's archive.
#
#   audit/icy-tower/tools/traced-archive.sh IN.a OUT.a
#
# SDL3 linked into the executable as a static archive (the macOS game) has
# no call to interpose at run time: the program's calls are direct
# branches into the image. So the probe is made at link time instead, and
# the game's source is not touched: every function sdltrace.c wraps (the
# real_SDL_* prototypes of its SDLTRACE_LINKED section are the list) is
# renamed in a copy of the archive, NAME to real_NAME, definitions and
# references alike (llvm-objcopy --redefine-sym; Mach-O's names carry a
# leading "_"), and sdltrace.c compiled with -DSDLTRACE_LINKED -- wrappers
# named NAME that log the call and call real_NAME -- is added to it. A
# program linked against OUT.a instead of IN.a then makes the same calls,
# each written to $SDLTRACE as the Linux interposer writes it. SDL's own
# calls between its functions go through SDL's internal names (its
# dynamic-API layer's *_REAL functions) and are not traced, as on Linux.
#
# The renaming tool is BOTLISH_OBJCOPY, else llvm-objcopy on PATH, in
# Homebrew's LLVM or in the Rust toolchain's llvm-tools (rustup component
# add llvm-tools), else GNU objcopy on Linux. Writes nothing but OUT.a.
set -euo pipefail

in=$1
outfile=$2
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source=$here/../context-refactor/tools/sdltrace.c
fail() { echo "traced-archive.sh: $*" >&2; exit 1; }
[[ -f $in ]] || fail "no archive $in"

names=$(sed -n '/^#ifdef SDLTRACE_LINKED/,/^#define REAL/s/^[^ ].*[ *]real_\(SDL_[A-Za-z]*\)(.*);$/\1/p' "$source" | sort -u)
[[ $(wc -l <<<"$names") -ge 20 ]] || fail "found only $(wc -l <<<"$names") wrapped functions in $source"
case $(uname -s) in
    Darwin) label=_ ;;
    *) label= ;;
esac

objcopy=${BOTLISH_OBJCOPY:-}
if [[ -z $objcopy ]]; then
    for candidate in llvm-objcopy; do
        command -v "$candidate" >/dev/null 2>&1 && objcopy=$(command -v "$candidate") && break
    done
fi
if [[ -z $objcopy ]] && command -v brew >/dev/null 2>&1; then
    for formula in llvm llvm@20 llvm@19 llvm@18 llvm@17 llvm@16 llvm@15; do
        p=$(brew --prefix "$formula" 2>/dev/null || true)
        if [[ -n $p && -x $p/bin/llvm-objcopy ]]; then objcopy=$p/bin/llvm-objcopy; break; fi
    done
fi
if [[ -z $objcopy ]] && command -v rustc >/dev/null 2>&1; then
    for p in "$(rustc --print sysroot)"/lib/rustlib/*/bin/llvm-objcopy; do
        if [[ -x $p ]]; then objcopy=$p; break; fi
    done
fi
if [[ -z $objcopy && $(uname -s) != Darwin ]] && command -v objcopy >/dev/null 2>&1; then
    objcopy=$(command -v objcopy)
fi
[[ -n $objcopy ]] || fail "no llvm-objcopy (set BOTLISH_OBJCOPY, install Homebrew's llvm, or rustup component add llvm-tools)"

work=$(mktemp -d "${TMPDIR:-/tmp}/traced-archive.XXXXXX")
trap 'rm -rf "$work"' EXIT
args=()
while read -r name; do
    args+=(--redefine-sym "$label$name=${label}real_$name")
done <<<"$names"
"$objcopy" "${args[@]}" "$in" "$work/renamed.a"
target=()
[[ $(uname -s) == Darwin ]] && target=(-arch arm64 -mmacosx-version-min=11.0)  # the archive's: SDL3's deployment target
cc ${target[@]+"${target[@]}"} -c -O1 -DSDLTRACE_LINKED -o "$work/sdltrace.o" "$source"
mkdir -p "$(dirname "$outfile")"
rm -f "$outfile"
if [[ $(uname -s) == Darwin ]]; then
    libtool -static -o "$outfile" "$work/renamed.a" "$work/sdltrace.o" 2>"$work/libtool.log" \
        || { cat "$work/libtool.log" >&2; fail "libtool failed"; }
else
    cp "$work/renamed.a" "$outfile"
    ar rs "$outfile" "$work/sdltrace.o" 2>/dev/null
fi

# Each wrapped function is defined once (the wrapper) and its real_ name
# once (SDL's, renamed): never a function left unrenamed beside a wrapper.
defined=$(nm -g "$outfile" 2>/dev/null | awk '$2 ~ /^[TtDdSs]$/ {print $3}')
while read -r name; do
    w=$(grep -cx "$label$name" <<<"$defined" || true)
    r=$(grep -cx "${label}real_$name" <<<"$defined" || true)
    [[ $w == 1 && $r == 1 ]] || fail "$name is defined $w times and real_$name $r times in $outfile"
done <<<"$names"
echo "traced archive: $outfile ($(wc -l <<<"$names" | tr -d ' ') functions wrapped by $(basename "$objcopy"))"
