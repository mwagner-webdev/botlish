#!/usr/bin/env bash
set -euxo pipefail

export LANG=C.utf8
export LC_ALL=C.utf8

if ! command -v tclsh9.0 >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl

  cd /tmp
  base=http://archive.ubuntu.com/ubuntu/pool/universe
  curl -fsSLO "$base/libt/libtommath/libtommath1_1.3.0-1_amd64.deb"
  curl -fsSLO "$base/t/tcl9.0/libtcl9.0_9.0.1+dfsg-1_amd64.deb"
  curl -fsSLO "$base/t/tcl9.0/tcl9.0_9.0.1+dfsg-1_amd64.deb"
  dpkg -i libtommath1_1.3.0-1_amd64.deb libtcl9.0_9.0.1+dfsg-1_amd64.deb tcl9.0_9.0.1+dfsg-1_amd64.deb
fi

export PATH="$HOME/.cargo/bin:$PATH"
if ! command -v rustc >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable
fi

rustup toolchain install stable --profile minimal
rustup default stable

printf 'Tcl %s, tcltest %s\n' "$(tclsh9.0 <<< 'puts [info patchlevel]' 2>/dev/null)" "$(tclsh9.0 <<< 'package require tcltest 2.5; puts [package require tcltest]' 2>/dev/null)"

cargo --version
rustc --version
