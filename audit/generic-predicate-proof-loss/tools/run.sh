#!/bin/sh
# run.sh -- the whole result-narrowing census (GENERIC-PREDICATE-PROOF-LOSS.md,
# fix 3), from the repository root:
#
#   sh audit/generic-predicate-proof-loss/tools/run.sh BASE_REV SCRATCH ?WORKTREE?
#
# BASE_REV is the pre-change commit (the tree without the result-narrowing
# pass), SCRATCH a scratch directory for dumps, WORKTREE (default
# SCRATCH/base-wt) where a temporary detached worktree of BASE_REV is
# created (native/target symlinked to this tree's) and removed again at the
# end. Writes
# audit/generic-predicate-proof-loss/out/census.txt.
#
# With AUDIT_BIN set to an audit-patched botlish-native (see
# audit/post-r2a-dynamic-census/tools/build-audit-native.sh), every corpus
# program whose NIR changed is also profiled under callgrind, knob 0 vs 1
# (profile-nir.sh, 21 runs), and the Ir/run differences are appended.
#
# Corpus: bench/*.bot examples/stdlib/*.bot examples/surface/*.bot; extra
# (optional) corpus: the Core-IR-text programs bench/*.ir examples/*.ir
# examples/hir/*.ir, read into HIR the way native/explain-native.tcl does.
set -eu
base=$1
scratch=$2
root=$(pwd)
tools=$root/audit/generic-predicate-proof-loss/tools
out=$root/audit/generic-predicate-proof-loss/out
export LANG=C.utf8 LC_ALL=C.utf8
main=$(ls bench/*.bot examples/stdlib/*.bot examples/surface/*.bot)
extra=$(ls bench/*.ir examples/*.ir examples/hir/*.ir)
wt=${3:-$scratch/base-wt}
mkdir -p "$scratch" "$out"
tclsh9.0 "$tools/census.tcl" -selftest
rm -rf "$scratch/dump0" "$scratch/dump1" "$scratch/dumpbase" \
    "$scratch/xdump0" "$scratch/xdump1" "$scratch/xdumpbase"
git worktree add --detach "$wt" "$base"
ln -s "$root/native/target" "$wt/native/target"
trap 'git -C "$root" worktree remove --force "$wt"; git -C "$root" worktree prune' EXIT

# Changed tree, knob 0 and 1; base tree with its own defaults ("-").
tclsh9.0 "$tools/collect.tcl" "$root" 0 "$scratch/dump0" $main > "$scratch/collect0.log" 2>&1 &
tclsh9.0 "$tools/collect.tcl" "$root" 1 "$scratch/dump1" $main > "$scratch/collect1.log" 2>&1 &
(cd "$wt" && tclsh9.0 "$tools/collect.tcl" "$wt" - "$scratch/dumpbase" $main > "$scratch/collectbase.log" 2>&1) &
wait
tclsh9.0 "$tools/collect.tcl" "$root" 0 "$scratch/xdump0" $extra > "$scratch/xcollect0.log" 2>&1 &
tclsh9.0 "$tools/collect.tcl" "$root" 1 "$scratch/xdump1" $extra > "$scratch/xcollect1.log" 2>&1 &
(cd "$wt" && tclsh9.0 "$tools/collect.tcl" "$wt" - "$scratch/xdumpbase" $extra > "$scratch/xcollectbase.log" 2>&1) &
wait

tclsh9.0 "$tools/census.tcl" "$scratch/dump0" "$scratch/dump1" "$scratch/census-main.txt" $main
tclsh9.0 "$tools/equivalence.tcl" "$scratch/dumpbase" "$scratch/dump0" "$scratch/dump1" "$scratch/equiv-main.txt" $main
tclsh9.0 "$tools/census.tcl" "$scratch/xdump0" "$scratch/xdump1" "$scratch/census-extra.txt" $extra
tclsh9.0 "$tools/equivalence.tcl" "$scratch/xdumpbase" "$scratch/xdump0" "$scratch/xdump1" "$scratch/equiv-extra.txt" $extra
{
    cat "$scratch/census-main.txt"
    echo
    echo "Refactor equivalence (corpus above), base $(git rev-parse --short "$base")"
    echo "==================================================================="
    cat "$scratch/equiv-main.txt"
    echo
    echo
    echo "OPTIONAL EXTRA CORPUS: Core-IR-text programs (bench/*.ir examples/*.ir examples/hir/*.ir)"
    echo "#########################################################################################"
    echo
    cat "$scratch/census-extra.txt"
    echo
    echo "Refactor equivalence (extra corpus), base $(git rev-parse --short "$base")"
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
} > "$out/census.txt"
echo "wrote $out/census.txt"
