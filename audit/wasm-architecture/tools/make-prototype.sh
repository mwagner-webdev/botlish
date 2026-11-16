#!/bin/bash
# make-prototype.sh SCRATCH: experiment E1 (the runtime for three wasm32
# targets, before and after the five throwaway patches) and the prototype
# copy SCRATCH/proto: native/ with resumable-and-wasm-prototype.patch, built
# as a fallback-roots driver (no stack switching: resumable coroutines) and
# as the wasm32-wasip1 and wasm32-wasip2 runtime the emitted objects link.
source "$(dirname "$0")/common.sh"
copy() { rm -rf "$1"; mkdir -p "$1/native"; (cd "$REPO/native" && tar cf - --exclude=./target .) | (cd "$1/native" && tar xf -); cp "$REPO/rust-toolchain.toml" "$1/"; cp -r "$REPO/.cargo" "$1/"; }
# E1: the stock runtime, target-gated only, then with the five patches.
copy "$SCRATCH/e1"
cd "$SCRATCH/e1"
python3 - <<'PY'
import re
s = open('native/Cargo.toml').read()
deps = s[s.index('[dependencies]'):s.index("[target.'cfg(windows)'.dependencies]")]
keep, gated = [], []
for line in deps.splitlines()[1:]:
    (gated if re.match(r'^(cranelift|target-lexicon|log)\b', line) else keep).append(line)
s = s.replace(deps, '[dependencies]\n' + '\n'.join(keep) + "\n[target.'cfg(not(target_family = \"wasm\"))'.dependencies]\n" + '\n'.join(gated) + '\n\n')
s = s.replace('members = [".", "runtime-archive"]\ndefault-members = [".", "runtime-archive"]', 'members = ["."]\ndefault-members = ["."]').replace('default = ["jit"]', 'default = []')
open('native/Cargo.toml', 'w').write(s)
PY
for t in wasm32-unknown-unknown wasm32-wasip1 wasm32-wasip2; do
  echo "== E1 before the patches: $t"
  (cd native && cargo check --release --lib --target $t 2>&1 | grep -E "^error" -A4 | grep -E -- "^error|-->" | sort | uniq -c) || true
done
cd "$SCRATCH" && rm -rf e1 && copy "$SCRATCH/e1" && (cd "$SCRATCH/e1" && patch -s -p1 < "$AUDIT/patches/e1-runtime-wasm32.patch")
for t in wasm32-unknown-unknown wasm32-wasip1 wasm32-wasip2; do
  echo "== E1 after the patches: $t"; (cd "$SCRATCH/e1/native" && cargo build --release --lib --target $t 2>&1 | tail -1)
done
# The prototype.
copy "$SCRATCH/proto"
(cd "$SCRATCH/proto" && patch -s -p1 < "$AUDIT/patches/resumable-and-wasm-prototype.patch")
cd "$PROTO"
cargo build --release --features fallback-roots 2>&1 | tail -1
for t in wasm32-wasip1 wasm32-wasip2; do
  cargo build --release --lib -p botlish-native --no-default-features --target $t 2>&1 | tail -1
done
