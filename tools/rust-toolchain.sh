#!/usr/bin/env bash
# rust-toolchain.sh -- the repository's pinned Rust toolchain
# (rust-toolchain.toml's channel).
#
#   tools/rust-toolchain.sh                    print its version
#   tools/rust-toolchain.sh install [TRIPLE]   install it (minimal profile),
#                                              TRIPLE's build if given, and
#                                              make it rustup's default
#
# The default matters as much as the file: the file applies to commands run
# inside the checkout, and the rustc linker compiles each executable's
# startup crate in a temporary directory, where only the default does
# (rust-toolchain.toml). Every setup (.devcontainer/setup.sh,
# tests/platform/setup-macos.sh, the workflows that install Rust) calls
# `install`; tests/platform/setup-windows.ps1 reads the same file.
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
channel=$(sed -n 's/^channel[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$root/rust-toolchain.toml")
if [[ -z $channel ]]; then
  echo "rust-toolchain.sh: no channel in $root/rust-toolchain.toml" >&2
  exit 1
fi

case ${1:-} in
  "")
    echo "$channel"
    ;;
  install)
    toolchain=$channel${2:+-$2}
    rustup toolchain install "$toolchain" --profile minimal
    rustup default "$toolchain"
    rustc +"$toolchain" --version
    ;;
  *)
    echo "usage: tools/rust-toolchain.sh [install [TRIPLE]]" >&2
    exit 2
    ;;
esac
