#!/bin/sh
# run-knob.sh -- the census of a knob-guarded change (GENERIC-PREDICATE-
# PROOF-LOSS.md, loss points 2 and 1), from the repository root:
#
#   sh audit/generic-predicate-proof-loss/tools/run-knob.sh BASE_REV SCRATCH KNOB OUTNAME CENSUS ?WORKTREE?
#
# Like run.sh, with KNOB as the knob (AUDIT_KNOB; loss point 2:
# hir::specialize::dormantOpt, loss point 1: hir::specialize::closureIntKeyOpt):
# collect.tcl with the knob 0 and 1 on this tree and with its own defaults
# on a temporary worktree of BASE_REV (the parent commit), then the census
# (CENSUS: `census` = census.tcl, instance by instance; `blocks` =
# census-blocks.tcl, function by function, for a change of instance keys)
# knob 0 vs 1, and equivalence-off.tcl (BASE_REV vs knob 0, every dump
# byte-identical). Writes audit/generic-predicate-proof-loss/out/OUTNAME.
# With AUDIT_BIN set, every corpus program whose NIR changed is profiled
# (profile-nir.sh, 21 runs), knob 0 vs 1.
set -eu
base=$1
scratch=$2
knob=$3
outname=$4
censusKind=$5
root=$(pwd)
tools=$root/audit/generic-predicate-proof-loss/tools
out=$root/audit/generic-predicate-proof-loss/out
export LANG=C.utf8 LC_ALL=C.utf8 AUDIT_KNOB=$knob
main=$(ls bench/*.bot examples/stdlib/*.bot examples/surface/*.bot)
extra=$(ls bench/*.ir examples/*.ir examples/hir/*.ir)
wt=${6:-$scratch/base-wt}
mkdir -p "$scratch" "$out"
tclsh9.0 "$tools/census.tcl" -selftest
rm -rf "$scratch/dump0" "$scratch/dump1" "$scratch/dumpbase" \
    "$scratch/xdump0" "$scratch/xdump1" "$scratch/xdumpbase"
git worktree add --detach "$wt" "$base"
ln -s "$root/native/target" "$wt/native/target"
trap 'git -C "$root" worktree remove --force "$wt"; git -C "$root" worktree prune' EXIT

tclsh9.0 "$tools/collect.tcl" "$root" 0 "$scratch/dump0" $main > "$scratch/collect0.log" 2>&1 &
tclsh9.0 "$tools/collect.tcl" "$root" 1 "$scratch/dump1" $main > "$scratch/collect1.log" 2>&1 &
(cd "$wt" && tclsh9.0 "$tools/collect.tcl" "$wt" - "$scratch/dumpbase" $main > "$scratch/collectbase.log" 2>&1) &
wait
tclsh9.0 "$tools/collect.tcl" "$root" 0 "$scratch/xdump0" $extra > "$scratch/xcollect0.log" 2>&1 &
tclsh9.0 "$tools/collect.tcl" "$root" 1 "$scratch/xdump1" $extra > "$scratch/xcollect1.log" 2>&1 &
(cd "$wt" && tclsh9.0 "$tools/collect.tcl" "$wt" - "$scratch/xdumpbase" $extra > "$scratch/xcollectbase.log" 2>&1) &
wait

if [ "$censusKind" = blocks ]; then census=census-blocks.tcl; else census=census.tcl; fi
tclsh9.0 "$tools/$census" "$scratch/dump0" "$scratch/dump1" "$scratch/census-main.txt" $main
tclsh9.0 "$tools/equivalence-off.tcl" "$scratch/dumpbase" "$scratch/dump0" "$scratch/equiv-main.txt" $main
tclsh9.0 "$tools/$census" "$scratch/xdump0" "$scratch/xdump1" "$scratch/census-extra.txt" $extra
tclsh9.0 "$tools/equivalence-off.tcl" "$scratch/xdumpbase" "$scratch/xdump0" "$scratch/equiv-extra.txt" $extra
{
    cat "$scratch/census-main.txt"
    echo
    echo "Knob-off equivalence (corpus above), base $(git rev-parse --short "$base")"
    echo "==================================================================="
    cat "$scratch/equiv-main.txt"
    echo
    echo
    echo "OPTIONAL EXTRA CORPUS: Core-IR-text programs (bench/*.ir examples/*.ir examples/hir/*.ir)"
    echo "#########################################################################################"
    echo
    cat "$scratch/census-extra.txt"
    echo
    echo "Knob-off equivalence (extra corpus), base $(git rev-parse --short "$base")"
    echo "==================================================================="
    cat "$scratch/equiv-extra.txt"
    if [ -n "${AUDIT_BIN:-}" ]; then
        echo
        echo
        echo "Dynamic check (callgrind, profile-nir.sh, 21 runs, 20 collected; programs whose NIR changed)"
        echo "============================================================================================="
        for p in $main; do
            stem=$(echo "${p%.*}" | sed 's|/|__|g')
            [ -f "$scratch/dump0/$stem/nir.txt" ] || continue
            cmp -s "$scratch/dump0/$stem/nir.txt" "$scratch/dump1/$stem/nir.txt" && continue
            for k in 0 1; do
                bash "$root/audit/post-r2a-dynamic-census/tools/profile-nir.sh" "$AUDIT_BIN" \
                    "$scratch/dump$k/$stem/nir.txt" 21 "$scratch/prof/$stem-$k" > "$scratch/prof-$stem-$k.log" 2>&1
            done
            python3 "$tools/profile-diff.py" "${p%.*}" "$scratch/prof/$stem-0" "$scratch/prof/$stem-1"
        done
    fi
} > "$out/$outname"
echo "wrote $out/$outname"
