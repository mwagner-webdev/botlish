#!/usr/bin/env bash
# run-all.sh -- reproduces every artifact of
# POST-MODULE-STATIC-EXACT-TARGET-CENSUS.md. Observation only: the audit
# patch is applied to a scratch copy of native/, every counterfactual lives
# in a scratch git worktree, and nothing in the tree's own production
# sources is touched.
#
#   bash audit/post-module-static-exact-target-census/tools/run-all.sh SCRATCH-DIR
#
# Run from the repository root (Linux, Tcl 9.0.1, rustc >= 1.95, valgrind,
# python3, binutils addr2line). Reuses the post-R2.a census tools
# (audit/post-r2a-dynamic-census/tools: build-audit-native.sh,
# audit-native.patch, validate-audit.sh, emit-nir.tcl, profile-nir.sh,
# cgcensus.py, intclasses.py, reclaim.sh, wallclock.py) and the post-M8.a
# cgprof.py/moves.py, all unchanged; this census's own tools are next to
# this script.
set -eu
scratch=${1:?usage: run-all.sh SCRATCH-DIR}
export LANG=C.utf8 LC_ALL=C.utf8 PYTHONDONTWRITEBYTECODE=1
root=$(pwd)
N=audit/post-module-static-exact-target-census
R=audit/post-r2a-dynamic-census/tools
B=$N/baseline/nir
PB=native/target/release/botlish-native

cargo build --release --quiet --manifest-path native/Cargo.toml
AB=$(bash $R/build-audit-native.sh "$scratch/auditbuild" | tail -1)

# Scratch counterfactual worktrees (never the tree's own lib/web.bot).
declare -A diff=([exact]=exact-target [local-only]=local-only [alpha-only]=alpha-only)
for v in exact local-only alpha-only; do
    wt="$scratch/wt/cf-$v"
    [ -d "$wt" ] || git worktree add -f --detach "$wt" HEAD > /dev/null
    (cd "$wt" && git checkout -q -- lib/web.bot && git apply "$root/$N/counterfactual/${diff[$v]}.diff")
    mkdir -p "$wt/native"; ln -sfn "$root/native/target" "$wt/native/target"
done

# NIR: production, the three counterfactuals, StringRegion-off controls, the
# pre-module-static frozen tree and its counterfactual (committed by the
# post-R2.a census), and the four single-input probes.
mkdir -p $B/probes
tclsh9.0 $R/emit-nir.tcl bench/refined-checks.ir > $B/prod.nir
tclsh9.0 $R/emit-nir.tcl bench/refined-checks.ir -string-region-opt 0 > $B/prod-noregion.nir
for v in exact local-only alpha-only; do
    (cd "$scratch/wt/cf-$v" && tclsh9.0 "$root/$R/emit-nir.tcl" bench/refined-checks.ir) > $B/cf-$v.nir
done
(cd "$scratch/wt/cf-exact" && tclsh9.0 "$root/$R/emit-nir.tcl" bench/refined-checks.ir -string-region-opt 0) > $B/cf-exact-noregion.nir
cp audit/post-r2a-dynamic-census/baseline/nir/frozen.nir $B/hist-frozen-r2a3.nir
cp audit/post-r2a-dynamic-census/baseline/nir/cf-exact.nir $B/hist-cf-exact-r2a3.nir
for pr in unicode-only ascii-only invalid-only early-invalid; do
    tclsh9.0 $R/emit-nir.tcl audit/post-r2a-dynamic-census/probes/$pr.ir > $B/probes/prod-$pr.nir
    (cd "$scratch/wt/cf-exact" && tclsh9.0 "$root/$R/emit-nir.tcl" "$root/audit/post-r2a-dynamic-census/probes/$pr.ir") > $B/probes/cf-exact-$pr.nir
done

# Deterministic structure: baseline, target graph, StringRegion verdicts.
tclsh9.0 $N/tools/baseline.tcl bench/refined-checks.ir $N/baseline/prod.txt
tclsh9.0 $N/tools/targetgraph.tcl bench/refined-checks.ir $N/baseline/targetgraph-prod.txt
tclsh9.0 $N/tools/regionprobe.tcl bench/refined-checks.ir $N/baseline/stringregion-prod.txt
for v in exact local-only alpha-only; do
    (cd "$scratch/wt/cf-$v" && tclsh9.0 "$root/$N/tools/baseline.tcl" bench/refined-checks.ir "$root/$N/baseline/cf-$v.txt")
done
(cd "$scratch/wt/cf-exact" && tclsh9.0 "$root/$N/tools/targetgraph.tcl" bench/refined-checks.ir "$root/$N/baseline/targetgraph-cf-exact-scan_local.txt" scan_local)
(cd "$scratch/wt/cf-exact" && tclsh9.0 "$root/$N/tools/targetgraph.tcl" bench/refined-checks.ir "$root/$N/baseline/targetgraph-cf-exact-scan_alpha.txt" scan_alpha)
(cd "$scratch/wt/cf-exact" && tclsh9.0 "$root/$N/tools/regionprobe.tcl" bench/refined-checks.ir "$root/$N/baseline/stringregion-cf-exact.txt")

# Audit-build validation (value, size, object, vcode, alloc, sites, jitmap).
for n in prod cf-exact cf-local-only cf-alpha-only prod-noregion cf-exact-noregion hist-frozen-r2a3 hist-cf-exact-r2a3; do
    echo "== $n"; bash $R/validate-audit.sh $PB "$AB" $B/$n.nir
done > $N/dynamic/validate-audit.txt
for f in $B/probes/*.nir; do
    echo "== probes/$(basename "$f" .nir)"; bash $R/validate-audit.sh $PB "$AB" "$f"
done >> $N/dynamic/validate-audit.txt
# Static slots / reset under GC stress: identical values and collection counts.
for bin in "$PB" "$AB"; do for n in prod cf-exact; do
    echo "$(basename "$(dirname "$(dirname "$(dirname "$bin")")")") $n: $(BOTLISH_NATIVE_GC_STRESS=1 "$bin" bench 8 $B/$n.nir | grep -v '^times' | tr '\n' ' ')"
done; done > $N/dynamic/gc-stress-reset.txt

# Semantic parity (95 addresses, 4 backends, module + root paths).
tclsh9.0 $N/tools/parity.tcl $N/tools/corpus.txt $N/dynamic/parity-prod.txt
for v in exact local-only alpha-only; do
    (cd "$scratch/wt/cf-$v" && tclsh9.0 "$root/$N/tools/parity.tcl" "$root/$N/tools/corpus.txt" "$root/$N/dynamic/parity-cf-$v.txt")
done

# Allocation sites (production binary).
for n in prod cf-exact cf-local-only cf-alpha-only; do
    $PB run $B/$n.nir --alloc sites > $N/dynamic/alloc-sites-$n.txt
done

# Callgrind profiles (bench 21, run 0 excluded, 20 collected runs).
for n in prod cf-exact cf-local-only cf-alpha-only prod-noregion cf-exact-noregion hist-frozen-r2a3 hist-cf-exact-r2a3; do
    bash $R/profile-nir.sh "$AB" $B/$n.nir 21 $N/profiles/$n
done
for pr in unicode-only ascii-only invalid-only early-invalid; do
    for t in prod cf-exact; do bash $R/profile-nir.sh "$AB" $B/probes/$t-$pr.nir 21 $N/profiles/probes/$t-$pr; done
done
for p in prod cf-exact; do
    python3 $R/intclasses.py $N/profiles/$p > $N/profiles/$p/intclasses.md
    python3 audit/post-m8a-common-inefficiency/tools/moves.py $N/profiles/$p > /dev/null
done

# Repeatability: a second 20-run profile, and 10 / 40 collected runs.
for spec in prod:21:r2 prod:11:n10 prod:41:n40 cf-exact:21:r2 cf-exact:11:n10 cf-exact:41:n40; do
    IFS=: read -r p runs tag <<< "$spec"
    bash $R/profile-nir.sh "$AB" $B/$p.nir "$runs" "$scratch/rep/$p-$tag"
done

# Deltas, UTF-8 seek attribution, deferred reclamation, wall clock.
P=$N/profiles
python3 $N/tools/cfdelta.py prod=$P/prod cf-exact=$P/cf-exact cf-local-only=$P/cf-local-only cf-alpha-only=$P/cf-alpha-only > $N/dynamic/delta-prod-vs-cf.md
python3 $N/tools/cfdelta.py hist-frozen-r2a3=$P/hist-frozen-r2a3 prod=$P/prod hist-cf-exact-r2a3=$P/hist-cf-exact-r2a3 cf-exact=$P/cf-exact > $N/dynamic/delta-historical.md
python3 $N/tools/cfdelta.py prod-noregion=$P/prod-noregion cf-exact-noregion=$P/cf-exact-noregion prod=$P/prod > $N/dynamic/delta-noregion.md
python3 $N/tools/seek.py "$AB" prod=$P/prod cf-exact=$P/cf-exact cf-local-only=$P/cf-local-only cf-alpha-only=$P/cf-alpha-only \
    hist-frozen-r2a3=$P/hist-frozen-r2a3 hist-cf-exact-r2a3=$P/hist-cf-exact-r2a3 > $N/dynamic/utf8-seek.md
bash $R/reclaim.sh "$AB" $PB prod=$B/prod.nir cf-exact=$B/cf-exact.nir cf-local-only=$B/cf-local-only.nir \
    cf-alpha-only=$B/cf-alpha-only.nir hist-frozen-r2a3=$B/hist-frozen-r2a3.nir hist-cf-exact-r2a3=$B/hist-cf-exact-r2a3.nir \
    prod-noregion=$B/prod-noregion.nir cf-exact-noregion=$B/cf-exact-noregion.nir > $N/dynamic/reclamation.md
for s in 7 15; do
    python3 $R/wallclock.py $PB $s 200 prod=$B/prod.nir cf-exact=$B/cf-exact.nir cf-local-only=$B/cf-local-only.nir \
        cf-alpha-only=$B/cf-alpha-only.nir hist-frozen-r2a3=$B/hist-frozen-r2a3.nir hist-cf-exact-r2a3=$B/hist-cf-exact-r2a3.nir \
        > $N/dynamic/wallclock-${s}x200.md
done
