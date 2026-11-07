#!/usr/bin/env bash
# packages.sh -- the author's side of the external-tools experiments
# (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md): builds the
# experiment's packages and packs them, as their authors would.
#
#   audit/external-tools/tools/packages.sh OUT NATIVE-DIR BOTLISH...
#
# BOTLISH... is the compiler command that packs them (`tclsh9.0 main.tcl` in
# a checkout, or the single-file compiler: `botlish package pack` either
# way), NATIVE-DIR a native build (native/target/release, or the directory
# of the driver and runtime archive the single executable was built from).
# Writes OUT/repo/NAME-VERSION.botpkg for
#
#   abi_tools             the emit-caller tool (src/emit-caller.c)
#   hostgen               the host-module tool (src/hostgen.c)
#   game2048              examples/games/2048/game2048.bot, unchanged, as an
#                         ordinary pure-Botlish package
#   botlish_target_linux  a target support package for linux-x86_64: the
#                         runtime archive of NATIVE-DIR and its descriptor,
#                         with that build's runtime ABI and the system
#                         linker's libraries (botlish-native runtime-abi,
#                         system-linker)
#
# and OUT/stage (the package directories). The tools are compiled with the
# host's cc for linux-x86_64, the one host their packages name. Nothing is
# downloaded.
set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "usage: packages.sh OUT NATIVE-DIR BOTLISH..." >&2
    exit 2
fi
out=$(realpath -m "$1")
native=$(realpath "$2")
shift 2
botlish=("$@")
here=$(cd "$(dirname "$0")" && pwd)
experiment=$(dirname "$here")
root=$(cd "$experiment/../.." && pwd)
stage="$out/stage"
repo="$out/repo"
rm -rf "$stage"
mkdir -p "$stage" "$repo"

for file in "$native/botlish-native" "$native/libbotlish_runtime.a"; do
    [[ -f $file ]] || { echo "packages.sh: $file is missing: build the native backend" >&2; exit 1; }
done

# The tools, compiled and stripped by their author (no host path in what
# ships).
build_tool() {
    local package=$1 tool=$2 source=$3
    cp -r "$experiment/packages/$package" "$stage/$package"
    mkdir -p "$stage/$package/tools/linux-x86_64"
    cc -std=c99 -O2 -Wall -Wextra -Werror -o "$stage/$package/tools/linux-x86_64/$tool" "$experiment/src/$source"
    strip "$stage/$package/tools/linux-x86_64/$tool" 2>/dev/null || true
}
build_tool abi_tools emit-caller emit-caller.c
build_tool hostgen host-module hostgen.c

# The engine, unchanged.
cp -r "$experiment/packages/game2048" "$stage/game2048"
cp "$root/examples/games/2048/game2048.bot" "$stage/game2048/game2048.bot"

# The target support package of linux-x86_64.
abi=$("$native/botlish-native" runtime-abi | awk '$1 == "runtime-abi" { print $2 }')
libraries=$("$native/botlish-native" system-linker | awk '$1 == "libraries" { $1 = ""; print }')
[[ $abi =~ ^[0-9a-f]{16}$ ]] || { echo "packages.sh: the driver states no runtime ABI" >&2; exit 1; }
cp -r "$experiment/packages/botlish_target_linux" "$stage/botlish_target_linux"
view="$stage/botlish_target_linux/targets/linux-x86_64"
mkdir -p "$view/runtime"
cp "$native/libbotlish_runtime.a" "$view/runtime/libbotlish_runtime.a"
list=""
for library in $libraries; do
    list="${list:+$list, }\"$library\""
done
cat >"$view/botlish-target-support.json" <<EOF
{
  "schema": 1,
  "kind": "botlish-target-support",
  "target": "linux-x86_64",
  "triple": "x86_64-unknown-linux-gnu",
  "linker": "system",
  "runtime": {
    "archive": "runtime/libbotlish_runtime.a",
    "abi": "$abi"
  },
  "systemLibraries": [$list]
}
EOF

for package in abi_tools hostgen game2048 botlish_target_linux; do
    "${botlish[@]}" package pack "$stage/$package" -out "$repo" -force
done
