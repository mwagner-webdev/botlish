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
#
# An executable prints no value of its own (PROGRAM-OUTPUT-MILESTONE-1.md):
# the stdout column is what the program writes, and the value column is the
# driver protocol's (a second run with BOTLISH_NATIVE_RESULT=FILE: the words
# of its "value V" line, V's quoting removed). The committed baselines were
# recorded while executables printed their value as the last stdout line,
# before the value column.
set -u
export LANG=C.utf8 LC_ALL=C.utf8
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/fuzz/baselines"
mkdir -p "$OUT"

# The value a run of COMMAND... reports through the driver protocol: the
# words of its result file's "value V" line, V's quoting (braces,
# backslashes) removed; empty when it reports none.
value_words() {
    local result
    result=$(mktemp)
    BOTLISH_NATIVE_RESULT="$result" "$@" >/dev/null 2>&1
    sed -n 's/^value //p' "$result" | tr -d '\\{}' | tr -s ' \n' ' ' | sed 's/ $//'
    rm -f "$result"
}

for target_dir in "$ROOT"/fuzz/seeds/*/; do
    target="$(basename "$target_dir")"
    binary="$ROOT/fuzz/build/aot/$target"
    [[ -x "$binary" ]] || continue
    tsv="$OUT/$target.tsv"
    printf 'seed\texit\twall_ms\tstdout\tstderr-first-line\tvalue\n' > "$tsv"
    # A plain no-harness run first: the program with no arguments at all
    # (stdin targets get an empty stdin instead).
    start=${EPOCHREALTIME/./}
    if grep -qx "$target" "$ROOT/fuzz/stdin-targets" 2>/dev/null; then
        out="$("$binary" </dev/null 2>/tmp/baseline-err.$$)"; code=$?
    else
        out="$("$binary" 2>/tmp/baseline-err.$$)"; code=$?
    fi
    end=${EPOCHREALTIME/./}
    err="$(head -1 /tmp/baseline-err.$$ 2>/dev/null || true)"; rm -f /tmp/baseline-err.$$
    if grep -qx "$target" "$ROOT/fuzz/stdin-targets" 2>/dev/null; then
        value=$(value_words "$binary" </dev/null)
    else
        value=$(value_words "$binary")
    fi
    printf '%s\t%d\t%d\t%s\t%s\t%s\n' "plain" "$code" "$(((end - start) / 1000))" "${out//$'\n'/ }" "$err" "$value" >> "$tsv"
    for seed in "$target_dir"/*; do
        [[ -f "$seed" ]] || continue
        start=${EPOCHREALTIME/./}
        if grep -qx "$target" "$ROOT/fuzz/stdin-targets" 2>/dev/null; then
            out="$("$binary" <"$seed" 2>/tmp/baseline-err.$$)"; code=$?
        else
            out="$("$ROOT/fuzz/harness/argv-file" "$binary" "$seed" 2>/tmp/baseline-err.$$)"; code=$?
        fi
        end=${EPOCHREALTIME/./}
        err="$(head -1 /tmp/baseline-err.$$ 2>/dev/null || true)"; rm -f /tmp/baseline-err.$$
        if grep -qx "$target" "$ROOT/fuzz/stdin-targets" 2>/dev/null; then
            value=$(value_words "$binary" <"$seed")
        else
            value=$(value_words "$ROOT/fuzz/harness/argv-file" "$binary" "$seed")
        fi
        printf '%s\t%d\t%d\t%s\t%s\t%s\n' "$(basename "$seed")" "$code" "$(((end - start) / 1000))" "${out//$'\n'/ }" "$err" "$value" >> "$tsv"
    done
    echo "baseline: $target ($(grep -c '' "$tsv") rows incl. plain)"
done
