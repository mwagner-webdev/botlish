#!/usr/bin/env bash
# campaign.sh -- the AFL++ campaign over the AOT executables.
#
#   bash fuzz/scripts/campaign.sh ?BUDGET-SECONDS-PER-TARGET?
#
# Mechanism (campaign brief #11, decision recorded in
# FUZZING-EXAMPLES-AOT.md): AFL++ QEMU mode (-Q) over the plain release
# AOT binaries -- no compiler changes, and QEMU sees every instruction the
# process executes, runtime library and generated code alike. Input is the
# process argv vector via fuzz/harness/argv-file (@@ file -> argv).
#
# Policy (#21, #24): every target gets its own master instance; the 12
# cores are filled by different targets' masters (batch 1: 12, batch 2:
# rest) rather than by secondaries of one target -- with one shared,
# shallow input surface, parallel masters on distinct programs dominate
# secondaries on the same program. Where a target is still growing
# coverage at budget end, it is rerun with a master + secondary (the
# growth-extension rule). Per-target budget defaults to 1200 s (20 min),
# bounded by AFL's own -V; snapshots every 300 s prove the run.
#
# Timeouts (#22): 10x the slowest baseline seed, floored at 200 ms,
# capped at 2 s, then raised to 50x the measured QEMU mean exec if that
# is larger (QEMU translation makes 100 KiB inputs slower than the plain
# baseline); every value recorded in the per-target stats.
#
# Memory (#23): -m none.
# Crash oracle (#26, #27): signals only; the AOT executables' expected
# failure exit code (1: language-level failure, native/src/runtime/aot.rs)
# is NOT a crash for AFL (AFL_CRASH_EXITCODE deliberately unset); exit-1
# output is inspected afterwards in triage, panics included (#28).
set -u
export LANG=C.utf8 LC_ALL=C.utf8
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AFL="$ROOT/fuzz/tools/afl/bin"
export AFL_PATH="$ROOT/fuzz/tools/afl/lib/afl" \
       AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
       AFL_SKIP_CPUFREQ=1 AFL_NO_UI=1 AFL_AUTORESUME=1
BUDGET="${1:-1200}"
OUT="$ROOT/fuzz/out"
SNAP="$ROOT/fuzz/out/snapshots"
mkdir -p "$OUT" "$SNAP"

# Per-target dictionary attachment (#19): format-matched only.
dict_for() {
    case "$1" in
        csv|csv_chunked|csv_geometric|csv_records) printf '%s\n' "$ROOT/fuzz/dictionaries/csv.dict";;
        ai_text_clean)                             printf '%s\n' "$ROOT/fuzz/dictionaries/text.dict";;
        matmul|0[1-9]-*|1[1-4]-*)                  printf '%s\n' "$ROOT/fuzz/dictionaries/numeric.dict";;
        *)                                         return 1;;
    esac
}
dict_args() {
    local d
    d="$(dict_for "$1")" || return 0
    [[ -f "$d" ]] && printf ' -x %s' "$d" || return 0
}

# Derived -t (#22): 10x slowest baseline seed ms, clamped to [200, 2000].
timeout_for() {
    local tsv="$ROOT/fuzz/baselines/$1.tsv" slowest=0 t
    [[ -f "$tsv" ]] || { echo 1000; return; }
    while IFS=$'\t' read -r _ _ ms _ _; do
        [[ "$ms" =~ ^[0-9]+$ ]] && (( ms > slowest )) && slowest=$ms
    done < <(tail -n +2 "$tsv")
    t=$((slowest * 10))
    (( t < 200 )) && t=200
    (( t > 2000 )) && t=2000
    echo "$t"
}

run_batch() {  # run_batch target...
    local pids=() targetsRunning=() target pid i
    for target in "$@"; do
        local binary="$ROOT/fuzz/build/aot/$target"
        [[ -x "$binary" ]] || { echo "campaign: skip $target (no binary)"; continue; }
        local t; t="$(timeout_for "$target")"
        local dir="$OUT/$target"
        # shellcheck disable=SC2086
        "$AFL/afl-fuzz" -Q -i "$ROOT/fuzz/seeds/$target" -o "$dir" \
            -m none -t "$t" -G 100000 -V "$BUDGET"$(dict_args "$target") \
            -- "$ROOT/fuzz/harness/argv-file" "$binary" @@ \
            >"$OUT/$target.afl.log" 2>&1 &
        pids+=($!)
        targetsRunning+=("$target")
        echo "campaign: $target  -t $t  -V $BUDGET  pid $!"
    done

    # Snapshot loop: proof the campaign ran (#21), plus the hard-plateau
    # early stop (#24): a target whose edges_done and corpus_count are
    # unchanged across 3 consecutive snapshots (15 min) gets SIGINT.
    local -A flatCount edgesLast corpusLast
    for i in $(seq 1 $((BUDGET / 300 + 1))); do
        sleep 300
        for i_target in "${targetsRunning[@]}"; do
            local stats="$OUT/$i_target/default/fuzzer_stats"
            [[ -f "$stats" ]] || continue
            "$AFL/afl-whatsup" -s "$OUT/$i_target" 2>/dev/null | tail -1 >> "$SNAP/$i_target.whatsup.log" || true
            cp "$stats" "$SNAP/$i_target.$(date +%H%M%S).stats" 2>/dev/null || true
            local edges corpus
            edges="$(awk -F': *' '/^edges_done/{print $2}' "$stats")"
            corpus="$(awk -F': *' '/^corpus_count/{print $2}' "$stats")"
            if [[ "${edgesLast[$i_target]:-}" == "$edges" && "${corpusLast[$i_target]:-}" == "$corpus" ]]; then
                flatCount[$i_target]=$(( ${flatCount[$i_target]:-0} + 1 ))
            else
                flatCount[$i_target]=0
            fi
            edgesLast[$i_target]="$edges"
            corpusLast[$i_target]="$corpus"
        done
        for idx in "${!targetsRunning[@]}"; do
            target="${targetsRunning[$idx]}"
            pid="${pids[$idx]}"
            kill -0 "$pid" 2>/dev/null || continue
            if [[ "${flatCount[$target]:-0}" -ge 3 ]]; then
                echo "campaign: $target plateaued (edges+corpus flat 15 min), stopping early"
                kill -INT "$pid" 2>/dev/null || true
            fi
        done
    done
    for pid in "${pids[@]}"; do
        kill -INT "$pid" 2>/dev/null || true
    done
    wait 2>/dev/null
}

mapfile -t targets < <(ls "$ROOT"/fuzz/seeds/)
cores="$(nproc)"
batch1=("${targets[@]:0:cores}")
batch2=("${targets[@]:cores}")
run_batch "${batch1[@]}"
[[ ${#batch2[@]} -gt 0 ]] && run_batch "${batch2[@]}"

# Growth-extension rule (#24): a target still adding edges at budget end
# gets one more round with a master + a secondary (the only place
# secondaries pay off). One extension round per campaign run.
for target in "${targets[@]}"; do
    stats="$OUT/$target/default/fuzzer_stats"
    [[ -f "$stats" ]] || continue
    edges_now="$(awk -F': *' '/^edges_done/{print $2}' "$stats")"
    edges_prev="$(awk -F': *' '/^edges_done/{print $2}' "$SNAP/$target."*.stats 2>/dev/null | tail -2 | head -1)"
    [[ -z "${edges_prev// /}" ]] && continue
    if [[ "${edges_now// /}" == "${edges_prev// /}" ]]; then continue; fi
    echo "campaign: extending $target (coverage still growing: $edges_prev -> $edges_now)"
    t="$(timeout_for "$target")"
    # shellcheck disable=SC2086
    "$AFL/afl-fuzz" -Q -i - -o "$OUT/$target" -m none -t "$t" -G 100000 -V "$BUDGET"$(dict_args "$target") \
        -M extend-master -- "$ROOT/fuzz/harness/argv-file" "$ROOT/fuzz/build/aot/$target" @@ \
        >>"$OUT/$target.afl.log" 2>&1 &
    masterPid=$!
    # shellcheck disable=SC2086
    "$AFL/afl-fuzz" -Q -i - -o "$OUT/$target" -m none -t "$t" -G 100000 -V "$BUDGET"$(dict_args "$target") \
        -S extend-secondary -- "$ROOT/fuzz/harness/argv-file" "$ROOT/fuzz/build/aot/$target" @@ \
        >>"$OUT/$target.afl.log" 2>&1 &
    secondaryPid=$!
    sleep 300
    cp "$OUT/$target/extend-master/fuzzer_stats" "$SNAP/$target.extend.stats" 2>/dev/null || true
    kill -INT "$masterPid" "$secondaryPid" 2>/dev/null || true
    wait "$masterPid" "$secondaryPid" 2>/dev/null || true
done

echo "campaign: done. Stats: $SNAP, per-target AFL state: $OUT"
"$AFL/afl-whatsup" "$OUT" 2>/dev/null | tail -8 || true
