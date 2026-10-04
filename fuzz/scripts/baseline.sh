#!/usr/bin/env bash
# baseline.sh -- record, for every target x committed seed: stdout, stderr,
# exit code, wall time (campaign brief #8). Stored under fuzz/baselines/
# (committed): these power later differential judgments and the regression
# check "every example still compiles AOT and matches its recorded baseline
# on seeds".
#
# The baseline runs the AOT executable through the campaign's own harness
# (fuzz/harness/argv-file), so the baseline exercises exactly the path the
# fuzzer drives.
set -u
export LANG=C.utf8 LC_ALL=C.utf8
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/fuzz/baselines"
mkdir -p "$OUT"

for target_dir in "$ROOT"/fuzz/seeds/*/; do
    target="$(basename "$target_dir")"
    binary="$ROOT/fuzz/build/aot/$target"
    [[ -x "$binary" ]] || continue
    tsv="$OUT/$target.tsv"
    printf 'seed\texit\twall_ms\tstdout\tstderr-first-line\n' > "$tsv"
    # A plain no-harness run first: the program with no arguments at all.
    start=${EPOCHREALTIME/./}
    out="$("$binary" 2>/tmp/baseline-err.$$)"; code=$?
    end=${EPOCHREALTIME/./}
    err="$(head -1 /tmp/baseline-err.$$ 2>/dev/null || true)"; rm -f /tmp/baseline-err.$$
    printf '%s\t%d\t%d\t%s\t%s\n' "plain" "$code" "$(((end - start) / 1000))" "$out" "$err" >> "$tsv"
    for seed in "$target_dir"/*; do
        [[ -f "$seed" ]] || continue
        start=${EPOCHREALTIME/./}
        out="$("$ROOT/fuzz/harness/argv-file" "$binary" "$seed" 2>/tmp/baseline-err.$$)"; code=$?
        end=${EPOCHREALTIME/./}
        err="$(head -1 /tmp/baseline-err.$$ 2>/dev/null || true)"; rm -f /tmp/baseline-err.$$
        printf '%s\t%d\t%d\t%s\t%s\n' "$(basename "$seed")" "$code" "$(((end - start) / 1000))" "$out" "$err" >> "$tsv"
    done
    echo "baseline: $target ($(grep -c '' "$tsv") rows incl. plain)"
done
