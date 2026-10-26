#!/usr/bin/env bash
set -euxo pipefail

if [[ ${EUID} -eq 0 ]]; then
  SUDO=()
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required for installing the C toolchain." >&2
    exit 1
  fi
  SUDO=(sudo -n)
fi

"${SUDO[@]}" apt-get update
"${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  clang=1:21.1.6-71 clang-21=1:21.1.8-6ubuntu1 \
  llvm=1:21.1.6-71 llvm-21=1:21.1.8-6ubuntu1 \
  gcc-aarch64-linux-gnu libc6-dev-arm64-cross cmake ninja-build \
  mingw-w64-x86-64-dev=13.0.0-2ubuntu1 \
  gcc-mingw-w64-x86-64=13.2.0-6ubuntu1+26.1 \
  binutils-mingw-w64-x86-64=2.45.90.20260125-1ubuntu1+13.3

clang --version
clang --target=aarch64-linux-gnu -E -v -x c /dev/null -o /dev/null 2>&1 | sed -n '/search starts here/,/End of search/p'
clang --target=x86_64-w64-mingw32 -E -v -x c /dev/null -o /dev/null 2>&1 | sed -n '/search starts here/,/End of search/p'
x86_64-w64-mingw32-gcc --version | sed -n '1p'