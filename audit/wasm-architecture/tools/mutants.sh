#!/bin/bash
# mutants.sh SCRATCH: two mutants of the resumable prototype's GC invariants
# (the report's I3 and I4), each built into a copy of SCRATCH/proto and run
# against the corpus programs that must kill it, under GC stress (needs
# run-corpus.sh's NIR files).
source "$(dirname "$0")/common.sh"
M=$SCRATCH/mutant/native
rm -rf "$SCRATCH/mutant" && mkdir -p "$M" && (cd "$PROTO" && tar cf - --exclude=./target .) | (cd "$M" && tar xf -)
cp -r "$REPO/.cargo" "$SCRATCH/mutant/"; cp "$REPO/rust-toolchain.toml" "$SCRATCH/mutant/"
cd "$M"
cp src/runtime/heap.rs heap.rs.orig; cp src/codegen/resumable.rs resumable.rs.orig
run() {
  cargo build --release --features fallback-roots > "$SCRATCH/mutant-$1.build" 2>&1 || { echo "$1: NOT BUILT"; return; }
  for c in c2-nested c4-gc c5-cancel c6b-many; do
    out=$(BOTLISH_NATIVE_GC_STRESS=1 timeout 900 target/release/botlish-native run "$SCRATCH/corpus-run/$c.nir" 2>&1) && st=0 || st=$?
    got=$(printf '%s\n' "$out" | grep -E '^value|^error' | head -1) || true
    echo "$1 $c: exit $st ${got:0:160}"
  done
}
# I3: a frame traces its tagged slots. M1 traces none.
python3 -c "
p='src/runtime/heap.rs'; s=open(p).read()
s=s.replace('stack.extend_from_slice(&f.tagged[..f.ntagged as usize]);','let _ = &f.tagged; // MUTANT M1'); open(p,'w').write(s)"
run M1-untraced-slots
cp heap.rs.orig src/runtime/heap.rs
# I4: every register live after a suspension point is saved. M2 drops one.
python3 -c "
p='src/codegen/resumable.rs'; s=open(p).read()
old='            saved.push((tagged, scalar));'; assert old in s
s=s.replace(old,'            if !tagged.is_empty() { tagged.pop(); } // MUTANT M2\n'+old); open(p,'w').write(s)"
run M2-incomplete-save
cp resumable.rs.orig src/codegen/resumable.rs
