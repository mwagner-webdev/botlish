#!/usr/bin/env bash
# campaign-asan.sh -- the sanitizer second pass (#13): the same QEMU-mode
# campaign over the ASan-instrumented AOT executables
# (fuzz/build/aot-asan/, built by build-asan.sh). ASAN_OPTIONS makes ASan
# abort (SIGABRT = a crash signal for AFL) and skips leak reports (the
# runtime's steady state is not a leak finding); -m none is mandatory
# with sanitizers.
#
#   bash fuzz/scripts/campaign-asan.sh ?BUDGET?   (default 600 s/target)
set -u
export LANG=C.utf8 LC_ALL=C.utf8
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AFL="$ROOT/fuzz/tools/afl/bin"
export AFL_PATH="$ROOT/fuzz/tools/afl/lib/afl" \
       AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
       AFL_SKIP_CPUFREQ=1 AFL_NO_UI=1
export ASAN_OPTIONS=abort_on_error=1:detect_leaks=0:symbolize=0
BUDGET="${1:-600}"
OUT="$ROOT/fuzz/out-asan"
SNAP="$OUT/snapshots"
mkdir -p "$OUT" "$SNAP"

run_batch() {
    local pids=() targets=() target pid
    for target in "$@"; do
        local binary="$ROOT/fuzz/build/aot-asan/$target"
        [[ -x "$binary" ]] || { echo "campaign-asan: skip $target"; continue; }
        # shellcheck disable=SC2086
        "$AFL/afl-fuzz" -Q -i "$ROOT/fuzz/seeds/$target" -o "$OUT/$target" \
            -m none -t 2000 -G 100000 -V "$BUDGET" \
            -- "$ROOT/fuzz/harness/argv-file" "$binary" @@ \
            >"$OUT/$target.afl.log" 2>&1 &
        pids+=($!); targets+=("$target")
        echo "campaign-asan: $target (pid $!)"
    done
    sleep "$BUDGET"
    for pid in "${pids[@]}"; do kill -INT "$pid" 2>/dev/null || true; done
    wait 2>/dev/null
    for target in "${targets[@]}"; do
        [[ -f "$OUT/$target/default/fuzzer_stats" ]] && \
            cp "$OUT/$target/default/fuzzer_stats" "$SNAP/$target.final.stats"
    done
}

mapfile -t all < <(ls "$ROOT"/fuzz/build/aot-asan/)
cores="$(nproc)"
run_batch "${all[@]:0:cores}"
[[ ${#all[@]} -gt $cores ]] && run_batch "${all[@]:cores}"
echo "campaign-asan: done. State under $OUT"
