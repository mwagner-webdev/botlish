#!/usr/bin/env bash
# package.sh -- the author's side of the Android AArch64 target support
# package (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, "Target support
# package"): builds Botlish's native runtime for aarch64-linux-android with
# the NDK and packs it, as its author would, beside the 2048 engine package
# the experiments use.
#
#   ANDROID_NDK_ROOT=NDK audit/android-aarch64-target/tools/package.sh OUT BOTLISH...
#
# BOTLISH... is the compiler command that packs the packages (`tclsh9.0
# main.tcl` in a checkout, or the single-file compiler) and whose native
# driver states the runtime ABI the archive must have (`botlish-native
# runtime-abi` beside it: the checkout's native/target/release, or
# BOTLISH_NATIVE_BIN). Writes
#
#   OUT/repo/botlish_target_android_aarch64-0.1.0.botpkg
#       the runtime archive (native/runtime-archive built with cargo for
#       aarch64-linux-android: rustc's own Android standard library, the
#       NDK's clang as the target C compiler) and its schema 2 descriptor
#   OUT/repo/game2048-0.1.0.botpkg
#       examples/games/2048/game2048.bot, unchanged
#   OUT/build.txt
#       the inputs: rustc, cargo, the NDK's revision, the Rust target, the
#       API level, the runtime ABI and the archive's SHA-256
#
# The archive is built from this checkout's source into
# native/target/aarch64-linux-android (cargo's own directory for the target):
# a consumer of the package never builds it. Its identity record (the
# archive's TARGET and the runtime ABI fingerprint) must agree with the
# driver's before anything is packed.
set -euo pipefail
out=$(realpath -m "${1:?usage: package.sh OUT BOTLISH...}")
shift
botlish=("$@")
[[ ${#botlish[@]} -gt 0 ]] || { echo "usage: package.sh OUT BOTLISH..." >&2; exit 2; }
here=$(cd "$(dirname "$0")" && pwd)
experiment=$(dirname "$here")
root=$(cd "$experiment/../.." && pwd)
api=21
ndk=${ANDROID_NDK_ROOT:?package.sh: set ANDROID_NDK_ROOT to the Android NDK}
bin="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin"
[[ -x $bin/clang ]] || { echo "package.sh: $bin/clang is missing: ANDROID_NDK_ROOT is no NDK for linux-x86_64" >&2; exit 1; }
revision=$(sed -n 's/^Pkg.Revision *= *//p' "$ndk/source.properties")
driver=${BOTLISH_NATIVE_BIN:-$root/native/target/release/botlish-native}
abi=$("$driver" runtime-abi | awk '$1 == "runtime-abi" { print $2 }')
[[ $abi =~ ^[0-9a-f]{16}$ ]] || { echo "package.sh: the driver states no runtime ABI" >&2; exit 1; }

rustup target add aarch64-linux-android >/dev/null 2>&1 || true
CC_aarch64_linux_android="$bin/aarch64-linux-android$api-clang" \
AR_aarch64_linux_android="$bin/llvm-ar" \
CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="$bin/aarch64-linux-android$api-clang" \
    cargo build --release --locked --target aarch64-linux-android -p botlish-runtime --manifest-path "$root/native/Cargo.toml"
archive="$root/native/target/aarch64-linux-android/release/libbotlish_runtime.a"
record=$(grep -a -o 'BOTLISH-RUNTIME-IDENTITY v1 [a-z0-9_-]* [0-9a-f]*' "$archive" | sort -u)
[[ $record == "BOTLISH-RUNTIME-IDENTITY v1 aarch64-linux-android $abi" ]] || {
    echo "package.sh: the archive's identity record is \"$record\", not aarch64-linux-android $abi: it is another build's runtime" >&2; exit 1; }

stage="$out/stage"
repo="$out/repo"
rm -rf "$stage"
mkdir -p "$stage" "$repo"
cp -r "$experiment/package/botlish_target_android_aarch64" "$stage/"
view="$stage/botlish_target_android_aarch64/targets/android-aarch64"
mkdir -p "$view/runtime"
cp "$archive" "$view/runtime/libbotlish_runtime.a"
cat >"$view/botlish-target-support.json" <<JSON
{
  "schema": 2,
  "kind": "botlish-target-support",
  "target": "android-aarch64",
  "triple": "aarch64-linux-android",
  "artifacts": ["native-library"],
  "platform": {"minimumApi": $api},
  "runtime": {
    "archive": "runtime/libbotlish_runtime.a",
    "abi": "$abi",
    "relocation": "pic"
  },
  "systemLibraries": ["-ldl", "-llog", "-lunwind", "-ldl", "-lm", "-lc"],
  "toolchain": {
    "name": "Android NDK",
    "root": "ANDROID_NDK_ROOT",
    "revision": {"file": "source.properties", "key": "Pkg.Revision", "minimum": "28.0"},
    "hosts": {"linux-x86_64": "toolchains/llvm/prebuilt/linux-x86_64"},
    "tools": {"cc": "bin/clang", "ld": "bin/ld.lld", "objcopy": "bin/llvm-objcopy", "ar": "bin/llvm-ar"},
    "platformLibraries": "sysroot/usr/lib/aarch64-linux-android/{api}"
  }
}
JSON
mkdir -p "$stage/game2048"
cp "$root/audit/external-tools/packages/game2048/botlish.json" "$stage/game2048/"
cp "$root/examples/games/2048/game2048.bot" "$stage/game2048/"
for package in botlish_target_android_aarch64 game2048; do
    "${botlish[@]}" package pack "$stage/$package" -out "$repo" -force
done
{
    echo "rustc $(rustc --version)"
    echo "cargo $(cargo --version)"
    echo "rust-target aarch64-linux-android"
    echo "ndk $revision"
    echo "api $api"
    echo "runtime-abi $abi"
    echo "archive-sha256 $(sha256sum "$archive" | cut -d' ' -f1)"
} >"$out/build.txt"
cat "$out/build.txt"
