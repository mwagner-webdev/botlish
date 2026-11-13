#!/usr/bin/env bash
set -euxo pipefail

export LANG=C.utf8
export LC_ALL=C.utf8

if [[ ${EUID} -eq 0 ]]; then
  SUDO=""
else
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required for the package-management steps in this setup script." >&2
    exit 1
  fi
  SUDO="sudo -n"
fi

if ! command -v tclsh9.0 >/dev/null 2>&1; then
  $SUDO apt-get update
  $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl

  # The same three packages for either architecture: amd64 from the main
  # archive, arm64 (the arm64 CI runners) from Ubuntu's ports archive.
  cd /tmp
  arch=$(dpkg --print-architecture)
  case $arch in
    amd64) base=http://archive.ubuntu.com/ubuntu/pool/universe ;;
    arm64) base=http://ports.ubuntu.com/ubuntu-ports/pool/universe ;;
    *) echo "no Tcl 9 packages configured for architecture $arch" >&2; exit 1 ;;
  esac
  # A download that fails is tried again, whatever the failure: the arm64
  # runners lost ports.ubuntu.com twice in a week (a connection reset at
  # 46ab0919, a name not resolved at eeaf1e3e), each time failing every job
  # of main's tests-arm64.yml run before it tested anything
  # (MAIN-CI-FAILURES-2026-11-13.md).
  fetch() { curl -fsSLO --retry 5 --retry-all-errors --retry-delay 10 --connect-timeout 30 "$1"; }
  fetch "$base/libt/libtommath/libtommath1_1.3.0-1_${arch}.deb"
  fetch "$base/t/tcl9.0/libtcl9.0_9.0.1+dfsg-1_${arch}.deb"
  fetch "$base/t/tcl9.0/tcl9.0_9.0.1+dfsg-1_${arch}.deb"
  $SUDO dpkg -i "libtommath1_1.3.0-1_${arch}.deb" "libtcl9.0_9.0.1+dfsg-1_${arch}.deb" "tcl9.0_9.0.1+dfsg-1_${arch}.deb"
fi

export PATH="$HOME/.cargo/bin:$PATH"
if ! command -v rustc >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable
fi

if ! command -v python3 >/dev/null 2>&1; then
  $SUDO apt-get update
  $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3
fi

rustup toolchain install stable --profile minimal
rustup default stable

if ! command -v go >/dev/null 2>&1; then
  $SUDO apt-get update
  $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends golang-go
fi

printf 'Tcl %s, tcltest %s\n' "$(tclsh9.0 <<< 'puts [info patchlevel]' 2>/dev/null)" "$(tclsh9.0 <<< 'package require tcltest 2.5; puts [package require tcltest]' 2>/dev/null)"

python3 --version
cargo --version
rustc --version
go version
