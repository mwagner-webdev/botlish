#!/usr/bin/env bash
# counterfactual.sh -- the two measured counterfactual ceilings of
# POST-R2A-DYNAMIC-CENSUS.md. Observation only; run from the repository root
# of the frozen tree. NEITHER is a proposed change:
#
#   exact-target       a scratch worktree of HEAD with
#                      counterfactual/exact-target.diff applied to ITS OWN
#                      lib/web.bot (never the tree's): scan_while(start,
#                      predicate) hand-split into the two per-target loops an
#                      exact-target specialization would produce
#                      (scan_local -> local_char?, scan_alpha ->
#                      is_tcl_alpha), everything else byte-identical. The
#                      UNMODIFIED compiler's response to that shape is the
#                      measured ceiling of "exact predicate targets +
#                      existing downstream machinery" (StringRegion,
#                      blockescape, tiny-leaf inlining, specialization).
#   string-region-off  the frozen tree's own NIR under -string-region-opt 0:
#                      the positive control for how much StringRegion
#                      already saves on the direct (known-consumer) paths.
#
#   bash audit/post-r2a-dynamic-census/tools/counterfactual.sh AUDIT-BIN OUTDIR WORKTREE-DIR
set -eu
bin=${1:?usage}; out=${2:?usage}; wt=${3:?usage}
export LANG=C.utf8 LC_ALL=C.utf8
root=$(pwd)
tools="$root/audit/post-r2a-dynamic-census/tools"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
[ -d "$wt/cf-exact" ] || git worktree add -f --detach "$wt/cf-exact" HEAD > /dev/null
(cd "$wt/cf-exact" && git checkout -q -- lib/web.bot && git apply "$root/audit/post-r2a-dynamic-census/counterfactual/exact-target.diff")
mkdir -p "$wt/cf-exact/native"; ln -sfn "$root/native/target" "$wt/cf-exact/native/target"
(cd "$wt/cf-exact" && tclsh9.0 "$tools/emit-nir.tcl" bench/refined-checks.ir) > "$tmp/cf-exact.nir"
mkdir -p "$out/exact-target"
(cd "$wt/cf-exact" && tclsh9.0 "$tools/baseline.tcl" bench/refined-checks.ir "$out/exact-target/baseline.txt")
bash "$tools/profile-nir.sh" "$bin" "$tmp/cf-exact.nir" 21 "$out/exact-target"
tclsh9.0 "$tools/emit-nir.tcl" bench/refined-checks.ir -string-region-opt 0 > "$tmp/sr-off.nir"
bash "$tools/profile-nir.sh" "$bin" "$tmp/sr-off.nir" 21 "$out/string-region-off"
