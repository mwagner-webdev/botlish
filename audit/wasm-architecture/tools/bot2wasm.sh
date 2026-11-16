#!/bin/bash
# bot2wasm.sh SCRATCH FILE.nir OUTDIR [wasm32-wasip1|wasm32-wasip2]: experiment
# E2's pipeline. The prototype driver loads FILE (the real parse, call-effect
# settlement and -- no stack switching -- the resumable lowering) and writes
# OUTDIR/program.s (wasm assembly), descriptor.bin (the encoded
# ProgramDescriptor) and startup.rs; llvm-mc assembles the relocatable
# object; rustc links it with the runtime built for the target (rust-lld).
source "$(dirname "$0")/common.sh"
NIR=$2; OUT=$3; TARGET=${4:-wasm32-wasip1}
RT=$PROTO/target/$TARGET/release
mkdir -p "$OUT"
"$PROTO_DRIVER" wasm-asm "$OUT" "$NIR"
llvm-mc -triple=wasm32-wasi -filetype=obj "$OUT/program.s" -o "$OUT/program.o"
cd "$REPO"
# Cargo 1.100's build directory keeps each dependency's rlib in build/*/*/out.
rustc --edition=2024 --crate-name=botlish_program --crate-type bin --target "$TARGET" \
  -C opt-level=2 -C panic=abort -C link-arg=--fatal-warnings -C link-arg="$OUT/program.o" \
  --extern botlish_native="$RT/libbotlish_native.rlib" $(for d in "$RT"/build/*/*/out; do printf -- '-L dependency=%s ' "$d"; done) \
  -A warnings -o "$OUT/program.wasm" "$OUT/startup.rs"
ls -l "$OUT/program.wasm"
