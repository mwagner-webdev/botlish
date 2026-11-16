#!/bin/bash
# run-corpus.sh SCRATCH [PROGRAM ...]: the coroutine corpus (and the other
# probes of the corpus directory) on every configuration of the report's
# matrix:
#   interp      the reference interpreter (main.tcl -backend interp)
#   stackful    the stock native backend (stack switching, stack maps)
#   resumable   the prototype driver: fallback (shadow-stack) roots, no
#               stack switching, the resumable lowering; GC stress off, on
#   wasm        bot2wasm.sh's module under Wasmtime; GC stress off, on
# and says whether each value equals the interpreter's. Case 8 runs without
# GC stress only: a collection at every allocation over its 200,000 live
# Strings is quadratic (its point is the --alloc summary: run-precision).
source "$(dirname "$0")/common.sh"
cd "$REPO"
OUT=$SCRATCH/corpus-run; mkdir -p "$OUT"
value() { sed -n 's/^   value: //p; s/^value //p' | head -1; }
shift
progs=("$@"); [ ${#progs[@]} -gt 0 ] || progs=(c1-interleaved c2-nested c3-escape c4-gc c5-cancel/coro c6a-generator c6b-many c7-errors c8-precision e2-fib w32-index)
for prog in "${progs[@]}"; do
  name=${prog%%/*}; src=$AUDIT/corpus/$prog.bot
  "$AUDIT/tools/emit-nir.sh" "$SCRATCH" "$src" "$OUT/$name.nir"
  ref=$(timeout 900 tclsh9.0 main.tcl -backend interp "$src" 2>&1 | value)
  printf '%s\n  interp:              %s\n' "$name" "$ref"
  row() { local label=$1 got; got=$2; printf '  %-20s %s %s\n' "$label:" "$([ "$got" = "$ref" ] && echo same || echo DIFFERENT)" "$([ "$got" = "$ref" ] || echo "($got)")"; }
  row stackful "$(timeout 900 tclsh9.0 main.tcl -backend cranelift "$src" 2>&1 | value)"
  row resumable "$(BOTLISH_NATIVE_BIN=$PROTO_DRIVER timeout 900 tclsh9.0 main.tcl -backend cranelift "$src" 2>&1 | value)"
  stress=1; [ "$name" = c8-precision ] && stress=0
  [ $stress = 1 ] && row resumable+gcstress "$(BOTLISH_NATIVE_GC_STRESS=1 BOTLISH_NATIVE_BIN=$PROTO_DRIVER timeout 1800 tclsh9.0 main.tcl -backend cranelift "$src" 2>&1 | value)"
  if "$AUDIT/tools/bot2wasm.sh" "$SCRATCH" "$OUT/$name.nir" "$OUT/wasm-$name" > "$OUT/wasm-$name.log" 2>&1; then
    row wasm "$("$WASMTIME" run "$OUT/wasm-$name/program.wasm" 2>&1 | value)"
    [ $stress = 1 ] && row wasm+gcstress "$(timeout 1800 "$WASMTIME" run --env BOTLISH_NATIVE_GC_STRESS=1 "$OUT/wasm-$name/program.wasm" 2>&1 | value)"
  else
    printf '  %-20s %s\n' "wasm:" "NOT EMITTED ($(tail -1 "$OUT/wasm-$name.log"))"
  fi
done
