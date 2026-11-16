#!/bin/bash
# dfa-tail.sh SCRATCH: corpus/dfa-tail.bot (a yielding function that loops by
# a self tail call, one iteration per symbol) on the prototype (resumable
# lowering), stock main fused and stock main unfused: allocations by kind,
# collections, time (tools/allocsum.py). Needs make-prototype.sh.
source "$(dirname "$0")/common.sh"
"$AUDIT/tools/emit-nir.sh" "$SCRATCH" "$AUDIT/corpus/dfa-tail.bot" "$SCRATCH/dfa-tail.nir"
for d in "resumable - $PROTO_DRIVER" "stackful-fused - $STOCK_DRIVER" "stackful-unfused BOTLISH_NATIVE_COROUTINE_FUSION=0 $STOCK_DRIVER"; do
  set -- $d
  echo "== $1"
  python3 -I "$AUDIT/tools/allocsum.py" "$2" "$3" run --alloc summary "$SCRATCH/dfa-tail.nir"
done
