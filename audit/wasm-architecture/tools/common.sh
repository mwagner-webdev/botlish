# Shared by the tools of audit/wasm-architecture (sourced): the repository
# root, the scratch directory every product goes to, and the tools the
# experiments use. Nothing is written into the repository.
set -euo pipefail
REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
AUDIT=$REPO/audit/wasm-architecture
SCRATCH=${1:?usage: $0 SCRATCH-DIRECTORY [...]}
mkdir -p "$SCRATCH"
SCRATCH=$(cd "$SCRATCH" && pwd)
export LANG=C.utf8 LC_ALL=C.utf8
WASMTIME=$SCRATCH/tools/bin/wasmtime
WASM_TOOLS=$SCRATCH/tools/bin/wasm-tools
WASM_OPT="node $SCRATCH/npm/node_modules/binaryen/bin/wasm-opt"
PROTO=$SCRATCH/proto/native           # the patched copy (resumable-and-wasm-prototype.patch)
PROTO_DRIVER=$PROTO/target/release/botlish-native
STOCK_DRIVER=$REPO/native/target/release/botlish-native
