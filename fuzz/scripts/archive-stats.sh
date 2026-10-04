#!/usr/bin/env bash
# archive-stats.sh -- copy the campaign's proof (final per-target
# fuzzer_stats, snapshot history, whatsup summaries) from the gitignored
# AFL out trees (release + ASan) into fuzz/campaign-stats/ (committed,
# small text files).
#
#   bash fuzz/scripts/archive-stats.sh
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARCHIVE="$ROOT/fuzz/campaign-stats/$(date -u +%Y-%m-%d)"
mkdir -p "$ARCHIVE"

archive_tree() {  # archive_tree AFL-OUT-TREE ARCHIVE-SUBDIR
    local out="$1" name="$2" target fuzzer fname
    for target in $(ls "$out" 2>/dev/null); do
        [[ -d "$out/$target" ]] || continue
        mkdir -p "$ARCHIVE/$name/$target"
        for fuzzer in "$out/$target"/*/; do
            fname="$(basename "$fuzzer")"
            [[ -f "$fuzzer/fuzzer_stats" ]] && cp "$fuzzer/fuzzer_stats" "$ARCHIVE/$name/$target/$fname.fuzzer_stats"
            [[ -f "$fuzzer/plot_data" ]] && cp "$fuzzer/plot_data" "$ARCHIVE/$name/$target/$fname.plot_data"
        done
        if [[ -d "$out/snapshots" ]]; then
            cp "$out/snapshots/$target."*.stats "$ARCHIVE/$name/$target/" 2>/dev/null || true
            cp "$out/snapshots/$target.whatsup.log" "$ARCHIVE/$name/$target/" 2>/dev/null || true
        fi
    done
}
archive_tree "$ROOT/fuzz/out" release
archive_tree "$ROOT/fuzz/out-asan" asan
echo "archived campaign stats under $ARCHIVE"
