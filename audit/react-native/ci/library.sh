#!/usr/bin/env bash
# library.sh RUST-TARGET OUT-DIR ?patch? -- HISTORY: the census's step,
# run by .github/workflows/react-native-probe.yml from the census's tree
# (its CENSUS_REF; libmode.tcl no longer runs against this one:
# NATIVE-LIBRARY-MILESTONE-1.md). The probe's Botlish library
# (audit/react-native/tools/libmode.tcl) for a mobile Rust target
# (REACT-NATIVE-TARGET-CENSUS.md, "Empirical results"). Run from a checkout
# whose host native backend is built. "patch" first applies
# audit/react-native/patches/runtime-aarch64-cfg.patch, without which the
# runtime does not compile for AArch64 Android or iOS. The runtime is built
# with frame pointers: .cargo/config.toml forces them for the four existing
# targets only, and the GC's root walker needs them in the runtime's frames.
set -euo pipefail
target=$1
out=$2
patch=${3:-}
root=$(cd "$(dirname "$0")/../../.." && pwd)
cd "$root"
if [ "$patch" = patch ]; then
  git apply audit/react-native/patches/runtime-aarch64-cfg.patch
fi
rustup target add "$target"
case "$target" in
  *-apple-ios*) export IPHONEOS_DEPLOYMENT_TARGET=15.1 ;;
esac
RUSTFLAGS="-C force-frame-pointers=yes" cargo build --release --manifest-path native/Cargo.toml --target "$target" --lib
tclsh9.0 audit/react-native/tools/libmode.tcl -o "$out" -prefix rnprobe -rust-target "$target" \
  -runtime "native/target/$target/release" audit/react-native/probe/rnprobe.bot add reverse require_positive depth same pick
ls -l "$out"
