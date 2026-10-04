#!/usr/bin/env bash
# archive-stats.sh -- copy the campaign's proof (final per-target
# fuzzer_stats, snapshot history, whatsup summaries) from the gitignored
# AFL out tree into fuzz/campaign-stats/ (committed, small text files).
#
#   bash fuzz/scripts/archive-stats.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AFL="$ROOT/fuzz/tools/afl/bin"
OUT="$ROOT/fuzz/out"
ARCHIVE="$ROOT/fuzz/campaign-stats/$(date -u +%Y-%m-%d)"
mkdir -p "$ARCHIVE"

for target in $(ls "$OUT" 2>/dev/null); do
    [[ -d "$OUT/$target" ]] || continue
    mkdir -p "$ARCHIVE/$target"
    for fuzzer in "$OUT/$target"/*/; do
        name="$(basename "$fuzzer")"
        [[ -f "$fuzzer/fuzzer_stats" ]] && cp "$fuzzer/fuzzer_stats" "$ARCHIVE/$target/$name.fuzzer_stats"
        [[ -f "$fuzzer/plot_data" ]] && cp "$fuzzer/plot_data" "$ARCHIVE/$target/$name.plot_data"
    done
    if [[ -d "$OUT/snapshots" ]]; then
        cp "$OUT/snapshots/$target."*.stats "$ARCHIVE/$target/" 2>/dev/null || true
        cp "$OUT/snapshots/$target.whatsup.log" "$ARCHIVE/$target/" 2>/dev/null || true
    fi
done
echo "archived campaign stats under $ARCHIVE"
