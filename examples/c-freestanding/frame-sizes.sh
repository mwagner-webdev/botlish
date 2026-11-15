#!/bin/sh
# frame-sizes.sh -- the size and alignment of every coroutine type of a
# program the C backend generated (C-COROUTINE-FRAMES-MILESTONE-1.md,
# "Storage accounting"), as a target's C compiler lays them out.
#
#   examples/c-freestanding/frame-sizes.sh DIR PREFIX [TARGET...]
#
# DIR holds PREFIX.h and PREFIX.runtime.json (main.tcl -emit-c -out DIR);
# the manifest's "coroutine_frames" names the types. With no TARGET the
# host's C compiler (CC, default cc) lays them out: it builds a small hosted
# probe that prints each type's sizeof and _Alignof, and runs it. Each
# TARGET is a clang target triple of an ELF target (avr is compiled for
# -mmcu=atmega328p), measured without running anything: each type's sizeof
# and _Alignof become the sizes of two objects of a probe object file, which
# llvm-nm reads. Prints one line per target and type:
#
#     TARGET TYPE SIZE ALIGN
#
# These are measurements of one compiler for one target, not properties of
# the program: C does not fix a struct's layout.
set -eu
dir=$1
p=$2
shift 2
manifest="$dir/$p.runtime.json"
types=$(grep -o '"type": "[^"]*"' "$manifest" | sed 's/.*: "//; s/"$//')
if [ -z "$types" ]; then
    echo "frame-sizes.sh: $manifest lists no coroutine type" >&2
    exit 1
fi
work=$(mktemp -d "${TMPDIR:-/tmp}/frame-sizes.XXXXXX")
trap 'rm -rf "$work"' EXIT
# The host: a hosted probe, run. (nm cannot read an object's sizes on every
# host: Apple's reports every Mach-O symbol's size as zero.)
if [ $# -eq 0 ]; then
    {
        echo "#include <stdio.h>"
        echo "#include \"$p.h\""
        echo "int main(void)"
        echo "{"
        for t in $types; do
            printf '    printf("host %s %%zu %%zu\\n", sizeof(%s), _Alignof(%s));\n' "$t" "$t" "$t"
        done
        echo "    return 0;"
        echo "}"
    } > "$work/probe.c"
    ${CC:-cc} -std=c11 -I "$dir" "$work/probe.c" -o "$work/probe"
    "$work/probe"
fi
# A cross target: object sizes, read by llvm-nm (ELF).
{
    echo "#include \"$p.h\""
    for t in $types; do
        echo "char size_$t[sizeof($t)];"
        echo "char align_$t[_Alignof($t)];"
    done
} > "$work/objects.c"
for target in "$@"; do
    case $target in
        avr*) flags="--target=avr -mmcu=atmega328p" ;;
        *) flags="--target=$target" ;;
    esac
    # shellcheck disable=SC2086 # (flags is a word list)
    clang $flags -std=c11 -ffreestanding -fno-common -O0 -I "$dir" -c "$work/objects.c" -o "$work/objects.o"
    llvm-nm -S "$work/objects.o" > "$work/symbols"
    for t in $types; do
        size=$(awk -v s="size_$t" '$NF == s { print $2 }' "$work/symbols")
        align=$(awk -v s="align_$t" '$NF == s { print $2 }' "$work/symbols")
        echo "$target $t $(printf '%d' "0x$size") $(printf '%d' "0x$align")"
    done
done
