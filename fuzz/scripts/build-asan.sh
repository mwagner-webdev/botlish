#!/usr/bin/env bash
# build-asan.sh -- an ASan-instrumented AOT toolchain and ASan builds of
# every fuzzable target, under fuzz/build/aot-asan/ (campaign brief #13:
# sanitizer reports upgrade crash quality; the normal release build stays
# the primary campaign).
#
# How, without touching the compiler: the native backend links standalone
# executables as `rustc startup.rs --extern botlish_native=<rlib>` (native/
# src/codegen/aot.rs), and it honors $RUSTC. So:
#
#   1. rebuild the runtime crate with nightly rustc -Zsanitizer=address
#      into a scratch target dir (faster filesystem than the checkout),
#   2. assemble a private toolchain dir with that driver + rlib + deps,
#   3. re-emit every target through the same NIR the normal build uses
#      (native::nir is pure Tcl), with $RUSTC pointed at a wrapper that
#      adds -Zsanitizer=address to the final link too.
#
# Nothing in native/ or the Tcl compiler changes. glibc ASan runtime is
# linked statically by rustc. Requires network once (nightly toolchain).
set -euo pipefail
export LANG=C.utf8 LC_ALL=C.utf8
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK="${BOTLISH_FUZZ_WORK:-/tmp/opencode/fuzz-setup}"
ASAN_TARGET="$WORK/asan-target"
TOOLCHAIN="$ROOT/fuzz/build/aot-asan-toolchain/release"
export PATH="$HOME/.cargo/bin:$PATH"

# 1. Nightly (-Zsanitizer is nightly-only) and the instrumented runtime.
#    cargo stays the stable one: nightly cargo (1.101+) uses the new
#    per-package target layout without release/deps, which the emitter's
#    `-L dependency=.../deps` link path expects; stable cargo driving the
#    nightly rustc as $RUSTC keeps the classic layout.
rustup toolchain install nightly --profile minimal >/dev/null 2>&1 || true
nightly="$(rustup which --toolchain nightly rustc | xargs dirname)"
echo "build-asan: nightly rustc: $("$nightly/rustc" --version)"
echo "build-asan: cargo:        $(cargo --version)"
rm -rf "$ASAN_TARGET"
(cd "$ROOT/native" && RUSTC="$nightly/rustc" RUSTFLAGS=-Zsanitizer=address \
    CARGO_TARGET_DIR="$ASAN_TARGET" cargo build --release >/dev/null)

# 2. The private toolchain dir (the driver locates its rlib next to itself).
rm -rf "$(dirname "$TOOLCHAIN")"
mkdir -p "$TOOLCHAIN"
cp "$ASAN_TARGET/release/botlish-native" "$TOOLCHAIN/"
cp "$ASAN_TARGET/release/libbotlish_native.rlib" "$TOOLCHAIN/"
cp -r "$ASAN_TARGET/release/deps" "$TOOLCHAIN/deps"

# 3. The rustc wrapper the emitter will use (adds ASan to the final link).
mkdir -p "$ROOT/fuzz/build/bin"
cat > "$ROOT/fuzz/build/bin/rustc-asan" <<EOF
#!/bin/sh
exec "$nightly/rustc" -Zsanitizer=address "\$@"
EOF
chmod +x "$ROOT/fuzz/build/bin/rustc-asan"

# 4. Re-emit every target from the same sources, same NIR, ASan runtime.
mkdir -p "$ROOT/fuzz/build/aot-asan"
emit="$(mktemp -d /tmp/opencode/asan-emit.XXXXXX)"
trap 'rm -rf "$emit"' EXIT
for src in "$ROOT"/fuzz/build/aot/*.bot "$ROOT"/fuzz/build/aot/*.hir; do
    name="$(basename "$src")"; base="${name%.*}"
    [[ -x "$ROOT/fuzz/build/aot/$base" ]] || continue   # only real targets
    echo "build-asan: $base"
    RUSTC="$ROOT/fuzz/build/bin/rustc-asan" \
        BOTLISH_ASAN_DRIVER="$TOOLCHAIN/botlish-native" \
        tclsh9.0 "$ROOT/fuzz/scripts/emit-via-driver.tcl" \
        "$src" "$ROOT/fuzz/build/aot-asan/$base" "$emit/$base.nir"
done
echo "build-asan: ASan executables under fuzz/build/aot-asan/"
