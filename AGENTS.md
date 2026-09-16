# Notes for agents working in this repository

## Installing Tcl 9

This project's reference evaluator requires Tcl 9.x (`core/core.tcl` checks
this at load time and refuses to run under Tcl 8.x, since Botlish's String
semantics count Unicode scalar values, which Tcl 8.x cannot represent
correctly for astral characters). Ubuntu (including the `ubuntu-latest`
GitHub Actions runner and other Ubuntu-based sandboxes) ships only Tcl 8.6
in its normal package pool, with no `tcl9` package available.

Do **not** build Tcl 9 from source (slow, and easy to get subtly wrong).
Instead, install it exactly the way `.github/workflows/tests.yml` and
`.github/workflows/bench.yml` do: three `.deb` packages pulled straight from
Ubuntu 25.04 (plucky)'s universe pool, installed with `dpkg -i`:

```sh
set -eu
cd /tmp
base=http://archive.ubuntu.com/ubuntu/pool/universe
curl -fsSLO "$base/libt/libtommath/libtommath1_1.3.0-1_amd64.deb"
curl -fsSLO "$base/t/tcl9.0/libtcl9.0_9.0.1+dfsg-1_amd64.deb"
curl -fsSLO "$base/t/tcl9.0/tcl9.0_9.0.1+dfsg-1_amd64.deb"
sudo dpkg -i libtommath1_1.3.0-1_amd64.deb libtcl9.0_9.0.1+dfsg-1_amd64.deb tcl9.0_9.0.1+dfsg-1_amd64.deb
echo 'puts "Tcl [info patchlevel], tcltest [package require tcltest 2.5]"' | tclsh9.0
```

This installs the `tclsh9.0` binary (not `tclsh`). Use `tclsh9.0` to run
everything in this repo (`tests/all.tcl`, `main.tcl`, `bench/*.tcl`, etc.),
matching CI.

Also set `LANG=C.utf8 LC_ALL=C.utf8` (glibc ships `C.utf8` built in, no
`locale-gen` needed): Tcl 9's I/O encoding profile is strict by default,
unlike Tcl 8.6's lenient one, and with no locale the system encoding falls
back to `iso8859-1`, which makes writing non-ASCII/astral output fail
outright instead of being silently mangled.

## Building the native (Cranelift) backend

`cargo build --release --manifest-path native/Cargo.toml` needs a rustc new
enough for the pinned `cranelift-*`/`wasmtime-internal-*` crates (rustc
1.95+; the sandbox's preinstalled toolchain can be older and will fail with
"is not supported by the following packages"). Fix with:

```sh
rustup toolchain install stable --profile minimal
rustup default stable
```

then build as usual. Without this, `cranelift`/`cranelift-generic` tests
and benchmarks report `{error {NATIVE NOT-BUILT}}` instead of running.
