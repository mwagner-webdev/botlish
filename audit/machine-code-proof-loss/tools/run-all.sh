#!/usr/bin/env bash
# run-all.sh -- reproduces every artifact under audit/machine-code-proof-loss/out/
# (MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md). Observation only: nothing in the
# tree is modified. Run from the repository root of the frozen tree, with the
# release native backend built (cargo build --release --manifest-path
# native/Cargo.toml), Tcl 9.0.1, valgrind and python3 on PATH.
#
#   bash audit/machine-code-proof-loss/tools/run-all.sh SCRATCH
#
# SCRATCH receives the audit-instrumented native binary (built from a copy of
# native/, never the tree's own), the regenerated assembly corpus, the scratch
# worktree of the exact-target counterfactual and full callgrind outputs.
# The callgrind configuration, the audit patch and the per-function census
# are the post-R2.a census's tools, reused unchanged
# (audit/post-r2a-dynamic-census/tools/{build-audit-native,profile-nir}.sh).
set -eu
scratch=${1:?usage: run-all.sh SCRATCH}
export LANG=C.utf8 LC_ALL=C.utf8 PYTHONDONTWRITEBYTECODE=1
root=$(pwd)
D=audit/machine-code-proof-loss
out=$D/out
mkdir -p "$scratch" "$out"/{facts,asm-history,nir,profiles}

# 1. Current assembly: regenerate the committed scalar corpus into SCRATCH and
#    compare it with audit/native-scalar-asm/ (the CI-committed artifact).
tclsh9.0 native/generate-scalar-audit.tcl -outdir "$scratch/current-asm" > /dev/null
{
    echo "regenerated: tclsh9.0 native/generate-scalar-audit.tcl -outdir SCRATCH/current-asm"
    echo "tree: $(git rev-parse HEAD)"
    echo "diff -r against audit/native-scalar-asm/ (differences listed; README.md records the generating commit):"
    diff -r -q "$scratch/current-asm" audit/native-scalar-asm | sed "s|$scratch|SCRATCH|g" || true
    diff "$scratch/current-asm/README.md" audit/native-scalar-asm/README.md || true
} > "$out/regen-identity.txt"

# 2. Committed-history evidence (git archaeology; nothing rebuilt).
python3 $D/tools/fnhist.py audit/native-scalar-asm/bench/fib.asm 'fib' > "$out/asm-history/fib.txt"
python3 $D/tools/fnhist.py audit/native-scalar-asm/bench/loop-count.asm '.' > "$out/asm-history/loop-count.txt"
python3 $D/tools/fnhist.py audit/native-scalar-asm/bench/sum-refined.asm '.' > "$out/asm-history/sum-refined.txt"
python3 $D/tools/fnhist.py audit/native-scalar-asm/bench/refined-checks.asm 'check|emailish|scan|char_at|tld|domain|local' > "$out/asm-history/refined-checks.txt"
python3 $D/tools/fnhist.py audit/native-scalar-asm/examples-stdlib/matmul.asm 'dot|product_row' > "$out/asm-history/matmul.txt"
python3 $D/tools/fnhist.py audit/native-scalar-asm/examples-stdlib/csv.asm 'scan_(quoted|unquoted|field)' > "$out/asm-history/csv-scanners.txt"
python3 $D/tools/fnsizes.py 0c2dead 924482b 45f29dc 84f4d68 46d658d b370d52 c251e7c > "$out/asm-history/per-function-m9-to-now.txt"

# 3. NIR of the frozen tree vs the committed pre-struct (84f4d68) and
#    post-struct-scalar-replacement snapshots.
{
    echo "program | changed NIR lines vs structs/out/nir-before (84f4d68) | vs struct-scalar-replacement/out/nir-before (structs) | vs struct-scalar-replacement/out/nir-after (90e9e97)"
    for f in audit/structs/out/nir-before/*.nir; do
        b=$(basename "$f" .nir)
        if [ -f "bench/$b.bot" ]; then p=bench/$b.bot; else p=examples/stdlib/$b.bot; fi
        tclsh9.0 $D/tools/emit-nir.tcl "$p" > "$scratch/$b.nir"
        c() { diff <(grep -v '^# ' "$1") "$scratch/$b.nir" | grep -c '^[<>]' || true; }
        echo "$b | $(c "$f") | $(c audit/struct-scalar-replacement/out/nir-before/$b.nir) | $(c audit/struct-scalar-replacement/out/nir-after/$b.nir)"
    done
    echo "(1 = only the committed snapshot's trailing blank line)"
} > "$out/nir-identity.txt"
for p in fib loop-count sum-refined refined-checks; do
    tclsh9.0 $D/tools/emit-nir.tcl bench/$p.bot > "$out/nir/$p.bot.nir"
done
tclsh9.0 $D/tools/emit-nir.tcl bench/refined-checks.ir > "$out/nir/refined-checks.ir.nir"

# 4. Facts per layer (semantic instances, codegen keys, closed-caller
#    theorems, entry/result Ranges), openness, and prepareHir's census.
for p in fib loop-count sum-refined refined-checks; do
    tclsh9.0 $D/tools/facts.tcl bench/$p.bot > "$out/facts/$p.txt"
done
for p in $D/probes/*.bot; do
    n=$(basename "$p" .bot)
    { tclsh9.0 main.tcl -backend cranelift "$p" | tail -1
      tclsh9.0 $D/tools/facts.tcl "$p"
      echo; echo "== NIR functions and call forms"
      tclsh9.0 $D/tools/emit-nir.tcl "$p" | grep -E '^func|callvalue|= call |substr ' ; } > "$out/facts/probe-$n.txt"
done
tclsh9.0 $D/tools/openness.tcl bench/refined-checks.bot > "$out/facts/openness-refined-checks.txt"
tclsh9.0 $D/tools/openness.tcl bench/sum-refined.bot > "$out/facts/openness-sum-refined.txt"
tclsh9.0 $D/tools/prepare-census.tcl bench/refined-checks.bot > "$out/facts/prepare-census-refined-checks.txt"

# 5. Dynamic counts (callgrind, steady state): the frozen tree, the
#    committed historical refined-checks NIR re-run on the SAME (current)
#    runtime, and the exact-target counterfactual (scratch worktree only).
bin=$(bash audit/post-r2a-dynamic-census/tools/build-audit-native.sh "$scratch/auditbuild" | tail -1)
prof() { bash audit/post-r2a-dynamic-census/tools/profile-nir.sh "$bin" "$1" "$2" "$scratch/prof/$3" > /dev/null
         mkdir -p "$out/profiles/$3"
         cp "$scratch/prof/$3"/{census.txt,mix.txt,profile.txt,run-output.txt} "$out/profiles/$3/"; }
prof "$out/nir/fib.bot.nir" 21 fib.bot
prof "$out/nir/refined-checks.bot.nir" 21 refined-checks.bot
prof "$out/nir/refined-checks.ir.nir" 21 refined-checks.ir
prof "$out/nir/loop-count.bot.nir" 2001 loop-count.bot
prof "$out/nir/sum-refined.bot.nir" 2001 sum-refined.bot
for h in pre-r2 r2 r2a r2a2; do
    prof audit/post-r2a-dynamic-census/profiles/history/$h/program.nir 21 hist-$h
done
prof audit/post-module-static-exact-target-census/profiles/hist-frozen-r2a3/program.nir 21 hist-r2a3
prof audit/post-module-static-exact-target-census/profiles/prod/program.nir 21 hist-modstatic
wt="$scratch/wt-cf"
[ -d "$wt" ] || git worktree add -f --detach "$wt" HEAD > /dev/null
(cd "$wt" && git checkout -q -- lib/web.bot \
    && git apply "$root/audit/post-module-static-exact-target-census/counterfactual/exact-target.diff" \
    && mkdir -p native/target/release && cp "$root/native/target/release/botlish-native" native/target/release/ \
    && tclsh9.0 "$root/$D/tools/emit-nir.tcl" bench/refined-checks.bot) > "$out/nir/cf-exact.bot.nir"
prof "$out/nir/cf-exact.bot.nir" 21 cf-exact
grep -H '^total Ir/run' "$out"/profiles/*/census.txt | sed "s|$out/profiles/||; s|/census.txt:| |" > "$out/ir-series.txt"

# 6. Per-case excerpts (cases/): committed old-good and current machine code
#    by function, and the matching NIR.
C=$D/cases
mkdir -p "$C/fib" "$C/refined-checks"
ext() { # COMMIT FILE LABEL-REGEX OUT
    { echo "; extracted from: git show $1:$2"
      echo "; compiler revision (that regeneration's README.md): $(git show "$1":audit/native-scalar-asm/README.md | grep -m1 'git commit' | sed 's/.*: //')"
      echo
      git show "$1":"$2" | awk -v pat="$3" '/^[0-9a-f]+ <botlish_(fn|entry)_[0-9]+: /{p = ($0 ~ pat)} p'; } > "$4"; }
F=audit/native-scalar-asm/bench/fib.asm
R=audit/native-scalar-asm/bench/refined-checks.asm
ext caf8ca7 $F 'fib<int>' "$C/fib/pre-m9-caf8ca7.asm"
ext 0c2dead $F 'fib<int>' "$C/fib/old-good-m9-0c2dead.asm"
ext c251e7c $F 'fib<int>' "$C/fib/current-c251e7c.asm"
ext 844c37e $R 'char_at|scan_local|scan_alpha' "$C/refined-checks/old-good-r2-844c37e-scanners.asm"
ext c251e7c $R 'char_at|local_char|scan_while|tld' "$C/refined-checks/current-c251e7c-scanners.asm"
ext 0c2dead $R 'check<' "$C/refined-checks/check-m9-0c2dead.asm"
ext bf40b58 $R 'check<' "$C/refined-checks/check-generic-r2a1-bf40b58.asm"
ext c251e7c $R 'check<' "$C/refined-checks/check-current-c251e7c.asm"
awk '/^func 1 /,/^end/' "$out/nir/fib.bot.nir" > "$C/fib/current.nir"
N=audit/post-r2a-dynamic-census/profiles/history/r2/program.nir
{ echo "# from $N (committed in 2b82c5b; emitted from worktree e7d53b6 = R2)"
  awk '/^func (10|11|13) /,/^end/' "$N"; } > "$C/refined-checks/old-good-r2-scanners.nir"
{ echo "# current frozen tree c251e7c, bench/refined-checks.bot"
  awk '/^func (10|11|12|13|14) /,/^end/' "$out/nir/refined-checks.bot.nir"; } > "$C/refined-checks/current-scanners.nir"
{ echo "# exact-target counterfactual (scratch worktree only), bench/refined-checks.bot"
  awk '/^func (11|12|13|14) /,/^end/' "$out/nir/cf-exact.bot.nir"; } > "$C/refined-checks/cf-exact-scanners.nir"
git worktree remove --force "$wt" 2> /dev/null || true
