#!/usr/bin/env bash
# run-all.sh -- reproduces the measured artifacts under audit/exact-callable/out/
# (EXACT-CALLABLE-CLOSED-CALLER.md). Observation only. Run from the repository
# root of THIS tree with the release native backend built, Tcl 9.0.1,
# valgrind, objdump and python3 on PATH. BASE is a checkout of the frozen
# parent fence (64af2fe, the tree before this milestone) with
# native/target linked to this tree's, used only for the "before" columns:
#
#   git worktree add -f /tmp/base 64af2fe && ln -s $PWD/native/target /tmp/base/native/target
#   bash audit/exact-callable/tools/run-all.sh /tmp/base /tmp/exact-callable-scratch
set -eu
base=${1:?usage: run-all.sh BASE-TREE SCRATCH}
scratch=${2:?usage: run-all.sh BASE-TREE SCRATCH}
export LANG=C.utf8 LC_ALL=C.utf8 PYTHONDONTWRITEBYTECODE=1
root=$(pwd)
D=audit/exact-callable
out=$D/out
mkdir -p "$scratch" "$out"
PROGS="bench/fib.bot bench/lex-strategy.bot bench/loop-count.bot bench/refined-checks.bot bench/source-checks.bot bench/sum-refined.bot bench/test-selection.bot bench/uri-steady.bot examples/stdlib/ai_text_clean.bot examples/stdlib/csv.bot examples/stdlib/csv_chunked.bot examples/stdlib/csv_geometric.bot examples/stdlib/csv_records.bot examples/stdlib/hashtable.bot examples/stdlib/matmul.bot examples/stdlib/string_replace.bot examples/stdlib/string_reverse.bot"

# 1. Instance / callvalue / code-size census, before and after.
(cd "$base" && tclsh9.0 "$root/$D/tools/census.tcl" $PROGS) > "$out/census-before.txt"
tclsh9.0 $D/tools/census.tcl $PROGS > "$out/census-after.txt"

# 2. NIR identity (which programs' NIR changed) and the HOF diffs.
mkdir -p "$scratch/nir-before" "$scratch/nir-after"
for p in $PROGS; do
    n=$(basename "$p" .bot)
    (cd "$base" && tclsh9.0 "$root/audit/machine-code-proof-loss/tools/emit-nir.tcl" "$p") > "$scratch/nir-before/$n.nir"
    tclsh9.0 audit/machine-code-proof-loss/tools/emit-nir.tcl "$p" > "$scratch/nir-after/$n.nir"
done
{
    for p in $PROGS; do
        n=$(basename "$p" .bot)
        if cmp -s "$scratch/nir-before/$n.nir" "$scratch/nir-after/$n.nir"; then echo "identical  $n"
        else echo "changed    $n  ($(diff "$scratch/nir-before/$n.nir" "$scratch/nir-after/$n.nir" | grep -c '^[<>]') lines)"; fi
    done
} > "$out/nir-identity.txt"
for n in lex-strategy source-checks test-selection uri-steady; do
    diff "$scratch/nir-before/$n.nir" "$scratch/nir-after/$n.nir" > "$out/nir-diff-$n.txt" || true
done
cp "$scratch/nir-before/refined-checks.nir" "$out/refined-checks-before.nir"
cp "$scratch/nir-after/refined-checks.nir" "$out/refined-checks-after.nir"

# 3. Machine code: the scalar-assembly corpus before/after, sizes by function.
(cd "$base" && tclsh9.0 native/generate-scalar-audit.tcl -outdir "$scratch/asm-before" > /dev/null)
tclsh9.0 native/generate-scalar-audit.tcl -outdir "$scratch/asm-after" > /dev/null
python3 $D/tools/codesize.py "$scratch/asm-before" "$scratch/asm-after" > "$out/codesize.md"

# 4. Ranges and closedness.
for w in before after; do
    d=$root; [ $w = before ] && d=$base
    (cd "$d" && tclsh9.0 "$root/$D/tools/ranges.tcl" bench/refined-checks.bot scan_while:start scan_while:i char_at:i 'tld?:i' 'domain?:j' 'domain?:start') > "$out/ranges-refined-checks-$w.txt"
done
tclsh9.0 $D/tools/closedness.tcl bench/refined-checks.bot bench/test-selection.bot bench/lex-strategy.bot bench/source-checks.bot bench/sum-refined.bot > "$out/closedness-after.txt"

# 4b. Per-function op counts of the changed scanner functions.
python3 $D/tools/opcounts.py "$scratch/nir-before/refined-checks.nir" "$scratch/nir-after/refined-checks.nir" '^(char_at|domain\?|local_char\?|scan_while|tld\?|web::emailish\?)<' > "$out/opcounts-refined-checks.txt"
python3 $D/tools/opcounts.py "$scratch/nir-before/uri-steady.nir" "$scratch/nir-after/uri-steady.nir" '^repeat_uri<' > "$out/opcounts-uri-steady.txt"

# 4c. The specialization-budget probe (median of 5 lowering times per row).
{
    echo "# budget.tcl N LIMIT: median of 5 runs (individual lowering times in brackets); bytes/instances/functions are deterministic"
    for cfg in "16 0" "16 1" "16 2" "16 4" "16 8" "1 8" "2 8" "4 8" "8 8"; do
        set -- $cfg
        for r in 1 2 3 4 5; do tclsh9.0 $D/tools/budget.tcl $1 $2; done | python3 -c '
import sys, re, statistics
lines = sys.stdin.read().strip().split("\n")
ms = sorted(int(re.search(r"lower_ms=(\d+)", l).group(1)) for l in lines)
print(re.sub(r"lower_ms=\d+", "lower_ms=%d" % statistics.median(ms), lines[0]), " (runs: %s)" % ms)'
    done
} > "$out/budget.txt"

# 5. Compile time (median of 5; the machine should be otherwise idle).
(cd "$base" && tclsh9.0 "$root/$D/tools/compiletime.tcl" bench/refined-checks.bot bench/test-selection.bot bench/lex-strategy.bot examples/stdlib/csv_records.bot examples/stdlib/hashtable.bot) > "$out/compiletime-before.txt"
tclsh9.0 $D/tools/compiletime.tcl bench/refined-checks.bot bench/test-selection.bot bench/lex-strategy.bot examples/stdlib/csv_records.bot examples/stdlib/hashtable.bot > "$out/compiletime-after.txt"

# 6. Dynamic counts (callgrind, steady state) on ONE runtime binary.
bin=$(bash audit/post-r2a-dynamic-census/tools/build-audit-native.sh "$scratch/auditbuild" | tail -1)
for p in refined-checks test-selection lex-strategy source-checks uri-steady; do
    for w in before after; do
        bash audit/post-r2a-dynamic-census/tools/profile-nir.sh "$bin" "$scratch/nir-$w/$p.nir" 21 "$scratch/prof/$p-$w" > /dev/null
        mkdir -p "$out/profiles/$p-$w"
        cp "$scratch/prof/$p-$w"/{census.txt,mix.txt,profile.txt} "$out/profiles/$p-$w/"
    done
done
grep -H '^total Ir/run' "$out"/profiles/*/census.txt | sed "s|$out/profiles/||; s|/census.txt:| |" > "$out/ir-series.txt"
