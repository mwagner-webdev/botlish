#!/bin/sh
# regioncheck-experiment.sh -- what the one proven-redundant run-time check
# on refined-checks' hot path costs (PROOF-FACT-CENSUS.md, performance
# context). Observation only: the compiler is not changed. It emits the
# benchmark's NIR (native/explain-native.tcl's standalone program.nir),
# deletes the single `op regioncheck` line -- in lib/web.bot's char_at,
# whose str::substring the completion proof already proves in range (its
# result register is never read) -- and times both NIR files in-process
# with the native driver's own bench mode (JIT excluded).
#
#   sh audit/proof-census/tools/regioncheck-experiment.sh [RUNS]
set -eu
runs=${1:-3000}
out=$(mktemp -d)
export LANG=C.utf8 LC_ALL=C.utf8
tclsh9.0 native/explain-native.tcl bench/refined-checks.bot "$out/x" >/dev/null </dev/null
cp "$out/x/program.nir" "$out/base.nir"
line=$(grep -n 'op regioncheck' "$out/base.nir" | cut -d: -f1)
[ "$(echo "$line" | wc -w)" = 1 ] || { echo "expected exactly one regioncheck, got: $line"; exit 1; }
grep -n 'op regioncheck' "$out/base.nir"
sed "${line}d" "$out/base.nir" > "$out/noregion.nir"
driver=native/target/release/botlish-native
for f in base noregion base noregion; do
    printf '%s: ' "$f"
    "$driver" run "$out/$f.nir" | tr '\n' ' '
    "$driver" bench "$runs" "$out/$f.nir" | grep '^times' | python3 -c '
import sys, statistics
t = [int(x) for x in sys.stdin.read().split()[1:]][1:]
print("median_us=%.1f best_us=%.1f" % (statistics.median(t) / 1000, min(t) / 1000))'
done
rm -rf "$out"
