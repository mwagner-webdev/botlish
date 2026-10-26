#!/usr/bin/env bash
# export-json-expectations.sh -- write the Linux AOT reports for the
# conformance seed corpus to fuzz/windows/expected-conformance.tsv, the
# file fuzz/windows/replay-json.ps1 replays the Windows executable
# against (same input, same report, across operating systems).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/fuzz/windows/expected-conformance.tsv"
: > "$OUT"
for seed in "$ROOT"/fuzz/seeds/conformance/*; do
    report="$(tclsh9.0 "$ROOT/fuzz/scripts/replay.tcl" aot conformance "$seed" | head -1)"
    printf '%s\t%s\n' "$(basename "$seed")" "$report" >> "$OUT"
done
echo "wrote $(grep -c '' "$OUT") expectations to $OUT"
