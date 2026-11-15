#!/bin/bash
# wasi.sh SCRATCH: experiments W1-W4 (needs run-corpus.sh's modules).
#   W1 a persistent program waiting in the host: timers, then stdin readiness
#   W2 how each way a run ends looks to the host
#   W3 a request-invoked wasi:http component under `wasmtime serve`
#   W4 Botlish modules as WASI 0.2 components: the preview1 adapter, and a
#      direct wasm32-wasip2 link
source "$(dirname "$0")/common.sh"
OUT=$SCRATCH/wasi; mkdir -p "$OUT"; cd "$REPO"
rustc --edition=2024 --target wasm32-wasip1 -O "$AUDIT/wasi/wait.rs" -o "$OUT/wait.wasm"
echo "== W1"; (sleep 3; echo hello-from-host) | python3 -I "$AUDIT/tools/measure.py" "$WASMTIME" run "$OUT/wait.wasm"
rustc --edition=2024 --target wasm32-wasip1 -O -C panic=abort "$AUDIT/wasi/traps.rs" -o "$OUT/traps.wasm"
echo "== W2"
for m in ok exit3 stack oob unreachable oom spin; do
  out=$(timeout 60 "$WASMTIME" run -W max-memory-size=268435456 -W timeout=2s "$OUT/traps.wasm" $m 2>&1) && st=0 || st=$?
  echo "$m: status $st: $(echo "$out" | grep -E "exhausted|memory fault|unreachable|allocation|interrupt|^ok" | head -1)"
done
echo "== W3"
rm -rf "$OUT/httpc" && cp -r "$AUDIT/wasi/httpc" "$OUT/httpc"
(cd "$OUT/httpc" && cargo +1.100.0 build -q --release --target wasm32-wasip2)
H=$OUT/httpc/target/wasm32-wasip2/release/handler.wasm
for reuse in "" "--max-instance-reuse-count 10"; do
  "$WASMTIME" serve -S cli=y $reuse --addr 127.0.0.1:8099 "$H" > "$OUT/serve.log" 2>&1 & pid=$!
  sleep 4; echo "serve ${reuse:-(defaults)}:"; for i in 1 2 3; do curl -s --noproxy '*' http://127.0.0.1:8099/; done
  kill $pid; wait $pid 2>/dev/null || true
done
echo "== W4"
for name in e2-fib c2-nested c5-cancel; do
  m=$SCRATCH/corpus-run/wasm-$name/program.wasm
  "$WASM_TOOLS" component new "$m" --adapt wasi_snapshot_preview1="$SCRATCH/adapter/wasi_snapshot_preview1.command.wasm" -o "$OUT/$name.component.wasm"
  echo "$name component: $("$WASM_TOOLS" component wit "$OUT/$name.component.wasm" | grep -c import) imports, $("$WASM_TOOLS" component wit "$OUT/$name.component.wasm" | grep export | xargs); $("$WASMTIME" run "$OUT/$name.component.wasm" | head -1)"
done
"$AUDIT/tools/bot2wasm.sh" "$SCRATCH" "$SCRATCH/corpus-run/c2-nested.nir" "$OUT/p2-c2" wasm32-wasip2 > /dev/null
echo "c2-nested linked for wasm32-wasip2: $("$WASM_TOOLS" component wit "$OUT/p2-c2/program.wasm" | grep export | xargs); $("$WASMTIME" run "$OUT/p2-c2/program.wasm" | head -1)"
echo "== core stack switching"
"$WASM_TOOLS" parse "$AUDIT/stack-switching/gen.wat" -o "$OUT/gen.wasm"
"$WASMTIME" run "$OUT/gen.wasm" 2>&1 | grep -E "stack switching" | head -1 || true
"$WASMTIME" run -W stack-switching=y,function-references=y,exceptions=y "$OUT/gen.wasm"; echo
