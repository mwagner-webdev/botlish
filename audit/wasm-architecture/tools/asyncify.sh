#!/bin/bash
# asyncify.sh SCRATCH: experiment C-A. Builds asyncify/co.rs (a minimal
# runtime keeping the invariants Asyncify would ask of Botlish's) for
# wasm32-wasip1, instruments it with Binaryen 132 three ways, and runs the
# cases under Wasmtime with no JavaScript host.
source "$(dirname "$0")/common.sh"
OUT=$SCRATCH/asyncify; mkdir -p "$OUT"; cd "$OUT"
cp "$AUDIT/asyncify/co.rs" "$AUDIT/asyncify/sp.s" .
llvm-mc -triple=wasm32-wasi -filetype=obj sp.s -o sp.o
(cd "$REPO" && rustc --edition=2024 --target wasm32-wasip1 -C opt-level=2 -C panic=abort "$OUT/co.rs" -C link-arg="$OUT/sp.o" -o "$OUT/co.wasm")
Y=counter,leaf,middle,down,down_thunk,driver,ticker,keeper,holder,inner_wait,deep_waiter,generator,small_holder,later,recurse_thunk
$WASM_OPT co.wasm -O2 -o co-base.wasm
$WASM_OPT co.wasm -O2 --asyncify --pass-arg=asyncify-ignore-imports --pass-arg=asyncify-removelist@segment -o co-whole.wasm
$WASM_OPT co.wasm -O2 --asyncify --pass-arg=asyncify-onlylist@$Y -o co-only-yielding.wasm
$WASM_OPT co.wasm -O2 --asyncify --pass-arg=asyncify-onlylist@$Y,co_yield -o co-only.wasm
for f in co-base co-whole co-only; do "$WASM_TOOLS" strip $f.wasm -o s.wasm; echo "$f.wasm: $(wc -c < s.wasm) bytes stripped"; done
echo "== onlylist without co_yield (case 1):"; "$WASMTIME" run co-only-yielding.wasm 1 2>&1 | grep -E "^\[|trap|Error" | head -2 || true
for t in 1 2 3 4 5 7; do
  echo "case $t: $("$WASMTIME" run co-only.wasm $t 2>&1 | head -1)"
  echo "case $t, GC stress: $("$WASMTIME" run --env GC_STRESS=1 co-only.wasm $t 2>&1 | head -1)"
done
for t in 6a 6b; do echo "case $t: $(python3 -I "$AUDIT/tools/measure.py" "$WASMTIME" run co-only.wasm $t | tr '\n' ' ')"; done
echo "case 8 (a coroutine's linear stack overflows):"; "$WASMTIME" run co-only.wasm 8 2>&1 | head -6 || true
echo "case 9 (the same recursion on the main stack):"; for n in 2000 20000; do "$WASMTIME" run co-only.wasm 9 $n 2>&1 | grep -E "recurse|exhausted" | head -1 || true; done
