#!/bin/bash
# golden-sweep.sh SCRATCH [SUITE.bot ...]: every golden suite (or the ones
# named) on the native backend through the prototype driver -- coroutines by
# the resumable lowering on the fallback root plan; each suite's own runner
# (stdlib/test.bot) is a coroutine. BOTLISH_NATIVE_GC_STRESS=1 in the
# environment runs them under GC stress.
source "$(dirname "$0")/common.sh"
cd "$REPO"
shift
suites=("$@"); [ ${#suites[@]} -gt 0 ] || suites=(tests/golden/*.bot)
OUT=$SCRATCH/golden-sweep; mkdir -p "$OUT"
for f in "${suites[@]}"; do
  n=$(basename "$f" .bot)
  BOTLISH_NATIVE_BIN=$PROTO_DRIVER timeout 3600 tclsh9.0 tests/golden/run.tcl -backends cranelift "$f" > "$OUT/$n.out" 2>&1 || true
  echo "$n: $(grep -E '^[0-9]+ passed, [0-9]+ failed|ABORTED' "$OUT/$n.out" | tail -1)"
done | tee "$OUT/SUMMARY"
grep -h -E '^[0-9]+ passed, [0-9]+ failed' "$OUT"/*.out | awk '{p+=$1; f+=$3} END {print "suites with reports:", NR, "tests passed:", p, "failed:", f}' | tee -a "$OUT/SUMMARY"
