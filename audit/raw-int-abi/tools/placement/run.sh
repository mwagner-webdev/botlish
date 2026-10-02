#!/bin/bash
# run.sh -- RAW-INT-ABI.md "Wall-clock": standalone placement sweep of the loop-count machine code.
# gen.py emits the JIT'd `work` + `drive` of bench/loop-count.bot for the tagged ABI (A), the
# eligibility-only plan (B) and the production plan (D), instruction for instruction (the listings
# `asm.tcl` prints), each placed at every offset 0..63 bytes from a 64-byte boundary with the JIT's
# relative layout; main.c times 500-iteration calls (best of 9 x 20000 reps) and checks the result.
#
#   bash audit/raw-int-abi/tools/placement/run.sh > sweep.txt
set -eu
cd "$(dirname "$0")"
work=$(mktemp -d)
python3 gen.py "$(seq -s, 0 63)" && mv mb.S "$work/mb.S"
gcc -O2 -o "$work/mb" main.c "$work/mb.S" 2>/dev/null
"$work/mb"
rm -rf "$work"
