#!/usr/bin/env bash
# build-aot.sh -- compile every example that can be AOT-compiled into a
# standalone executable, under fuzz/build/aot/ (gitignored).
#
# The repository's normal AOT path is used unchanged:
#
#   tclsh9.0 main.tcl -emit-native-executable FILE
#
# Sources are COPIED into fuzz/build/aot first, because the emitter writes
# the executable beside its input file; the copies keep examples/ free of
# build products (no example is modified -- same bytes, new location).
# "# requires:" library comments still resolve, because libraries load
# from the repository root (core::loadLibrary), not from the file's
# directory.
#
# Warnings policy: the repository default (#54 of the campaign brief: do
# not suppress or interact). A SAME-RETURN-VALUE warning goes to this
# script's log and changes nothing about the binaries.
#
# Output: fuzz/build/aot/<name> executables + manifest.tsv (one line per
# example: name, source, ok|fail, exit code, note). Exit status is 0 even
# with failures: a failed AOT build of a guarded/open workload is the
# readiness gate working (NATIVE AOT NOT-READY), not an error of this
# script; the campaign report owns that classification.
set -u
export LANG=C.utf8 LC_ALL=C.utf8
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

OUT="$ROOT/fuzz/build/aot"
mkdir -p "$OUT"
MANIFEST="$OUT/manifest.tsv"
printf 'name\tsource\tresult\tnote\n' > "$MANIFEST"

# Every example program, in a stable order. The classifier (inventory.tcl,
# FUZZING-EXAMPLES-AOT.md) explains what each row is; here we only record
# what the emitter does with it.
SOURCES="$(ls examples/stdlib/*.bot examples/abi/*.bot examples/linux/*.bot examples/surface/*.bot examples/hir/*.hir examples/*.ir 2>/dev/null | sort)"

for src in $SOURCES; do
    name="$(basename "$src")"
    base="${name%.*}"
    case "$name" in corpus.tcl|main.tcl) continue;; esac
    cp "$src" "$OUT/$name"
    if log="$(tclsh9.0 main.tcl -emit-native-executable "$OUT/$name" 2>&1)"; then
        printf '%s\t%s\tok\t\n' "$base" "$src" >> "$MANIFEST"
    else
        code="$(printf '%s' "$log" | grep -oE '\((NATIVE [A-Z -]+|[A-Z ]+)\)$' | tail -1 | tr -d '()')"
        printf '%s\t%s\tfail\t%s\n' "$base" "$src" "${code:-unknown}" >> "$MANIFEST"
        printf '%s\n' "$log" > "$OUT/$base.emit-fail.txt"
    fi
done

ok="$(awk -F'\t' '$3=="ok"' "$MANIFEST" | wc -l)"
fail="$(awk -F'\t' '$3=="fail"' "$MANIFEST" | wc -l)"
printf 'AOT build: %d ok, %d failed (see %s)\n' "$ok" "$fail" "$MANIFEST"
