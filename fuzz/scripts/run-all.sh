#!/usr/bin/env bash
# run-all.sh -- the whole campaign, in order (campaign brief #15: every
# step reproducible from a committed script; no manual snowflake steps).
#
#   bash fuzz/scripts/run-all.sh              # everything, campaign budget 1200s/target
#   bash fuzz/scripts/run-all.sh 300          # everything, shorter campaign (smoke)
#
# Steps:
#   0. host setup (AFL++ 4.09c + QEMU mode from pinned sources, harness)
#   1. AOT build of every example           (build-aot.sh)
#   2. inventory                            (inventory.tcl -> fuzz/inventory.tsv)
#   3. seed corpus + minimization           (make-seeds.sh, minimize-seeds.sh)
#   4. baselines                            (baseline.sh -> fuzz/baselines/)
#   5. differential matrix over seeds       (differential.sh)
#   6. the AFL++ campaign                   (campaign.sh, budget = $1)
#   7. triage of raw findings               (triage.sh -> fuzz/triage/candidates/)
#   8. stats archive                        (archive-stats.sh -> fuzz/campaign-stats/)
#   9. known-failure replay self-test       (replay-known-failures.tcl --selftest)
#
# ASan builds (build-asan.sh) are a deliberate separate step (#13: second
# pass), not part of the default run.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUDGET="${1:-1200}"
cd "$ROOT"
export LANG=C.utf8 LC_ALL=C.utf8

echo "== 0. host setup";    bash fuzz/scripts/setup-host.sh
echo "== 1. AOT build";     bash fuzz/scripts/build-aot.sh
echo "== 2. inventory";     tclsh9.0 fuzz/scripts/inventory.tcl > fuzz/inventory.tsv
echo "== 3. seeds";         bash fuzz/scripts/make-seeds.sh && bash fuzz/scripts/minimize-seeds.sh
echo "== 4. baselines";     bash fuzz/scripts/baseline.sh
echo "== 5. differential";  bash fuzz/scripts/differential.sh
echo "== 6. campaign (${BUDGET}s/target)"; bash fuzz/scripts/campaign.sh "$BUDGET"
echo "== 7. triage";        bash fuzz/scripts/triage.sh
echo "== 8. stats archive"; bash fuzz/scripts/archive-stats.sh
echo "== 9. known-failure suite self-test"
tclsh9.0 fuzz/scripts/replay-known-failures.tcl --selftest
echo "== done. Report: FUZZING-EXAMPLES-AOT.md"
