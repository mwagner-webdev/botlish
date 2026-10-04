#!/usr/bin/env bash
# minimize-seeds.sh -- afl-cmin over every target's seed sources
# (fuzz/seeds-src/<target>/), producing the committed, minimized corpus
# fuzz/seeds/<target>/ (campaign brief #18: the minimized set is what gets
# committed).
#
#   bash fuzz/scripts/minimize-seeds.sh
#
# Requires: the toolchain (setup-host.sh), emitted AOT binaries
# (build-aot.sh), seed sources (make-seeds.sh). QEMU mode with -m none;
# the timeout is generous because cmin runs every seed once under QEMU.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AFL="$ROOT/fuzz/tools/afl/bin"
export AFL_PATH="$ROOT/fuzz/tools/afl/lib/afl" \
       AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 AFL_SKIP_CPUFREQ=1

SEEDS="$ROOT/fuzz/seeds"
SRC="$ROOT/fuzz/seeds-src"
rm -rf "$SEEDS"; mkdir -p "$SEEDS"

for target in $(ls "$SRC"); do
    binary="$ROOT/fuzz/build/aot/$target"
    [[ -x "$binary" ]] || { echo "minimize-seeds: no binary for $target, skipping"; continue; }
    "$AFL/afl-cmin" -Q -m none -t 2000 -i "$SRC/$target" -o "$SEEDS/$target" -- \
        "$ROOT/fuzz/harness/argv-file" "$binary" @@ >/dev/null 2>&1
    printf '%-22s %2d -> %2d seeds\n' "$target" \
        "$(ls "$SRC/$target" | wc -l)" "$(ls "$SEEDS/$target" | wc -l)"
done
