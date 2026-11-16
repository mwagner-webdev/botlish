#!/bin/bash
# fallback-leaf.sh SCRATCH: the fallback root plan's leaf publication and an
# op that runs Botlish code (corpus/leaf-reentry.bot): stock main's
# fallback-roots build against the stack-map build and the prototype's
# shadow-only storage, GC stress off and on, five runs each.
source "$(dirname "$0")/common.sh"
cd "$REPO"
cargo build --release --manifest-path native/Cargo.toml --features fallback-roots --target-dir "$SCRATCH/fallback-target" 2>&1 | tail -1
"$AUDIT/tools/emit-nir.sh" "$SCRATCH" "$AUDIT/corpus/leaf-reentry.bot" "$SCRATCH/leaf-reentry.nir"
for d in "stack-maps $STOCK_DRIVER" "stock-fallback-roots $SCRATCH/fallback-target/release/botlish-native" "prototype-shadow-only $PROTO_DRIVER"; do
  set -- $d
  echo "$1: $("$2" roots "$SCRATCH/leaf-reentry.nir" | grep -E 'storage' | xargs)"
  for st in 0 1; do for i in 1 2 3 4 5; do BOTLISH_NATIVE_GC_STRESS=$st "$2" run "$SCRATCH/leaf-reentry.nir" 2>&1 | head -1 || echo "(exit $?)"; done | sort | uniq -c | sed "s/^/   gc-stress=$st: /"; done
done
