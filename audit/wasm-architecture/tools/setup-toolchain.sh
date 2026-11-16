#!/bin/bash
# setup-toolchain.sh SCRATCH: the tools the experiments ran with, built into
# SCRATCH (rustup's wasm32 targets for the repository's pinned rustc;
# Wasmtime 50.0.1 and wasm-tools 1.263.0 from crates.io; Binaryen 132 from
# npm, the JavaScript build of wasm-opt; the WASI preview1 adapter of
# Wasmtime 50.0.1 from its crate). GitHub release downloads were refused by
# the session's network policy, so nothing comes from there.
source "$(dirname "$0")/common.sh"
cd "$REPO"
rustup target add wasm32-wasip1 wasm32-wasip2 wasm32-unknown-unknown
cargo +1.100.0 install wasmtime-cli --version 50.0.1 --locked --root "$SCRATCH/tools"
cargo +1.100.0 install wasm-tools --version 1.263.0 --locked --root "$SCRATCH/tools"
mkdir -p "$SCRATCH/npm" && (cd "$SCRATCH/npm" && npm init -y >/dev/null && npm install binaryen@132.0.0)
mkdir -p "$SCRATCH/adapter" && cp -r "$AUDIT/wasi/adapter/." "$SCRATCH/adapter/"
(cd "$SCRATCH/adapter" && cargo +1.100.0 run -q)
"$WASMTIME" --version; "$WASM_TOOLS" --version; $WASM_OPT --version; llvm-mc --version | head -2
