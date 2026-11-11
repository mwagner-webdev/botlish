#!/bin/sh
# demo.sh -- the C backend's demonstrations, reproduced
# (C-COMPILE-FREESTANDING-MILESTONE-1.md, sections 11, 12 and 15).
#
#   examples/c-freestanding/demo.sh [OUT]       (from anywhere; OUT defaults
#                                                to a new temporary directory)
#
# 1. traffic.bot needs no runtime service: its C compiles freestanding, and
#    on Linux x86-64 links with no C library at all (harness/linux_start.c's
#    _start) and runs.
# 2. factorial.bot needs int.mul: its C compiles to objects without any
#    provider; linking them without one fails, the linker naming
#    botlish_rt_v1_int_mul, the service FILE.runtime.json lists.
# 3. with the reference provider (providers/botlish_rt_v1_int_arena.c)
#    linked in, it runs and prints 30!.
# 4. contexts (C-CONTEXTS-FREESTANDING-MILESTONE-1.md): the shop application
#    of contexts/, installed two ways (store_bench.bot, store_field.bot),
#    needs no runtime service; both configurations run interleaved in one
#    executable (harness/two_apps.c), on Linux x86-64 with no C library.
#
# Needs tclsh9.0 and a C compiler (CC, default cc). Nothing is installed or
# changed outside OUT.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
out=${1:-$(mktemp -d "${TMPDIR:-/tmp}/botlish-c-demo.XXXXXX")}
cc=${CC:-cc}
strict="-std=c11 -pedantic -Wall -Wextra -Werror"
mkdir -p "$out"
cp "$here/programs/traffic.bot" "$here/programs/factorial.bot" "$out/"

echo "== generating C (no C compiler runs)"
(cd "$root" && tclsh9.0 main.tcl -emit-c "$out/traffic.bot" "$out/factorial.bot")

echo
echo "== 1. traffic: no runtime service"
grep '"required_services": \[\]' "$out/traffic.runtime.json"
$cc $strict -O2 -ffreestanding -c "$out/traffic.c" -o "$out/traffic.o"
$cc $strict -O2 -ffreestanding -c "$out/traffic_display.c" -o "$out/traffic_display.o"
echo "undefined symbols of traffic.o and traffic_display.o: [$(nm -u "$out/traffic.o" "$out/traffic_display.o" | grep -v ':$' | awk 'NF { print $2 }' | tr '\n' ' ')]"
if [ "$(uname -s)-$(uname -m)" = Linux-x86_64 ]; then
    $cc $strict -O2 -ffreestanding -nostdlib -static -fno-stack-protector -fno-pie -no-pie \
        -DBOTLISH_PROGRAM=traffic -DBOTLISH_PROGRAM_HEADER='"traffic.h"' -I "$out" \
        "$here/harness/linux_start.c" "$out/traffic.c" "$out/traffic_display.c" -o "$out/traffic"
    echo "a static executable with no C library: $(file -b "$out/traffic" | cut -d, -f1-2,4)"
    "$out/traffic"
fi

echo
echo "== 2. factorial: needs int.mul, compiles without it"
grep -A1 '"service":' "$out/factorial.runtime.json" | grep -v -- --
$cc $strict -O0 -ffreestanding -c "$out/factorial.c" -o "$out/factorial.o"
echo "undefined symbols of factorial.o: $(nm -u "$out/factorial.o" | awk 'NF { print $2 }' | tr '\n' ' ')"
echo "linking without a provider:"
if $cc -std=c11 -DBOTLISH_PROGRAM=factorial -DBOTLISH_PROGRAM_HEADER='"factorial.h"' -I "$out" \
        "$here/harness/host_main.c" "$out/factorial.c" "$out/factorial_display.c" \
        -o "$out/factorial-unlinked" 2>"$out/link-error.txt"; then
    echo "unexpected: it linked" >&2
    exit 1
fi
sed 's/^/    /' "$out/link-error.txt"

echo
echo "== 3. factorial with the reference Int provider"
$cc $strict -O2 -DBOTLISH_PROGRAM=factorial -DBOTLISH_PROGRAM_HEADER='"factorial.h"' -I "$out" \
    "$here/harness/host_main.c" "$out/factorial.c" "$out/factorial_display.c" \
    "$here/providers/botlish_rt_v1_int_arena.c" -o "$out/factorial"
"$out/factorial"
echo
echo "== 4. contexts: one application, two configurations, one executable"
mkdir -p "$out/contexts"
cp "$here"/contexts/*.bot "$out/contexts/"
(cd "$root" && tclsh9.0 main.tcl -emit-c -out "$out/contexts" "$out/contexts/store_bench.bot" "$out/contexts/store_field.bot")
two="-DBOTLISH_PROGRAM_A=store_bench -DBOTLISH_PROGRAM_A_HEADER=\"store_bench.h\" -DBOTLISH_PROGRAM_B=store_field -DBOTLISH_PROGRAM_B_HEADER=\"store_field.h\""
units="$out/contexts/store_bench.c $out/contexts/store_bench_display.c $out/contexts/store_field.c $out/contexts/store_field_display.c"
echo "the functions of store_bench.c, each taking the contexts it requires:"
grep -h '^static.*ctx_.*);$' "$out/contexts/store_bench.c" | sed 's/^/    /'
if [ "$(uname -s)-$(uname -m)" = Linux-x86_64 ]; then
    # shellcheck disable=SC2086 # (two and units are word lists)
    $cc $strict -O2 -ffreestanding -nostdlib -static -fno-stack-protector -fno-pie -no-pie \
        -DBOTLISH_START_ENTRY=two_apps_main $two -I "$out/contexts" \
        "$here/harness/linux_start.c" "$here/harness/two_apps.c" $units -o "$out/two_apps"
    echo "a static executable with no C library: $(file -b "$out/two_apps" | cut -d, -f1-2,4)"
else
    # shellcheck disable=SC2086
    $cc $strict -O2 -DTWO_APPS_HOSTED $two -I "$out/contexts" "$here/harness/two_apps.c" $units -o "$out/two_apps"
fi
"$out/two_apps"

echo
echo "files: $out"
