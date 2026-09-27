#!/usr/bin/env bash
# profile-all.sh -- every callgrind profile POST-R2A-DYNAMIC-CENSUS.md
# reports. Observation only; run from the repository root of the frozen tree.
#
#   bash audit/post-r2a-dynamic-census/tools/profile-all.sh AUDIT-BIN OUTDIR [WORKTREES-DIR]
#
# AUDIT-BIN: audit/post-r2a-dynamic-census/tools/build-audit-native.sh's
# binary. Every profile runs RUNS=21 and collects runs 1..20 (steady state).
# native/src is byte-identical from R2 (e7d53b6) through the frozen
# tree (and since M8.a, e84f102), so this one binary also profiles the
# historical trees' NIR: only the Tcl-side lowering differs between them.
# WORKTREES-DIR (optional): creates detached worktrees of the historical
# commits there (pre-R2 0c2dead, R2 e7d53b6, R2.a 63b2199, R2.a.2 b472022)
# and profiles each one's own NIR for bench/refined-checks.ir.
set -eu
bin=${1:?usage}; out=${2:?usage}; wt=${3:-}
export LANG=C.utf8 LC_ALL=C.utf8
root=$(pwd)
tools="$root/audit/post-r2a-dynamic-census/tools"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
emit() { (cd "$1" && tclsh9.0 "$tools/emit-nir.tcl" "$2") > "$3"; }

# frozen tree: the benchmark, and its reproducibility/run-count controls
emit "$root" bench/refined-checks.ir "$tmp/frozen.nir"
bash "$tools/profile-nir.sh" "$bin" "$tmp/frozen.nir" 21 "$out/frozen/refined-checks"
for r in 1 2; do
    bash "$tools/profile-nir.sh" "$bin" "$tmp/frozen.nir" 21 "$tmp/repeat-$r" > /dev/null
    grep '^total Ir/run' "$tmp/repeat-$r/census.txt" | sed "s/^/repeat $r (20 collected runs): /"
done
for n in 11 41; do
    bash "$tools/profile-nir.sh" "$bin" "$tmp/frozen.nir" $n "$tmp/runs-$n" > /dev/null
    grep '^total Ir/run' "$tmp/runs-$n/census.txt" | sed "s/^/$n runs ($((n - 1)) collected): /"
done
# diagnostic input controls (frozen tree)
for p in unicode-only ascii-only invalid-only early-invalid; do
    emit "$root" "audit/post-r2a-dynamic-census/probes/$p.ir" "$tmp/$p.nir"
    bash "$tools/profile-nir.sh" "$bin" "$tmp/$p.nir" 21 "$out/probes/$p"
done
emit "$root" audit/post-m8a-common-inefficiency/probes/refined-checks-ascii.ir "$tmp/full-ascii.nir"
bash "$tools/profile-nir.sh" "$bin" "$tmp/full-ascii.nir" 21 "$out/probes/refined-checks-ascii"
# historical trees
if [ -n "$wt" ]; then
    for c in pre-r2:0c2dead r2:e7d53b6 r2a:63b2199 r2a2:b472022; do
        n=${c%%:*}; h=${c##*:}
        [ -d "$wt/$n" ] || git worktree add -f --detach "$wt/$n" "$h" > /dev/null
        git diff --quiet "$h" HEAD -- native/src native/Cargo.toml native/Cargo.lock \
            || { echo "native crate differs at $h: not comparable" >&2; exit 1; }
        emit "$wt/$n" bench/refined-checks.ir "$tmp/$n.nir"
        bash "$tools/profile-nir.sh" "$bin" "$tmp/$n.nir" 21 "$out/history/$n"
    done
fi
