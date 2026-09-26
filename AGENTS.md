# Notes for agents working in this repository

## Git workflow

Push finished work directly to `main`. This project does not use a
feature-branch-plus-pull-request review cycle: don't open a PR unless
explicitly asked to.

## Installing Tcl 9

This project's reference evaluator requires Tcl 9.x (`core/core.tcl` checks
this at load time and refuses to run under older Tcl versions, since
Botlish's String semantics count Unicode scalar values, and older Tcl builds
cannot represent astral characters correctly). The canonical baseline for
this repo is `tclsh9.0`.

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

This installs the `tclsh9.0` binary and it is the canonical baseline for
this repo. Use `tclsh9.0` to run everything in this repo (`tests/all.tcl`,
`main.tcl`, `bench/*.tcl`, etc.), matching CI.

Also set `LANG=C.utf8 LC_ALL=C.utf8` (glibc ships `C.utf8` built in, no
`locale-gen` needed): Tcl 9's I/O encoding profile is strict by default,
and with no locale the system encoding falls back to `iso8859-1`, which
makes writing non-ASCII/astral output fail outright instead of being
silently mangled.

### Known Tcl core bug: compiled `incr` wraps instead of promoting at the i64 boundary

Confirmed directly (BYTE-NIBBLE-BIT-ARITHMETIC.md's own account has the full
trace) and **still present as of Tcl 9.0.4 and the 9.1a1 alpha** -- not
fixed upstream, so there is currently no newer version to pin instead.
A minimal standalone reproduction, for filing an upstream bug report, is
committed at `tcl-incr-i64-wrap-bug.tcl` (run with `tclsh9.0
tcl-incr-i64-wrap-bug.tcl`):

```tcl
proc p {} { set v 9223372036854775807; incr v; return $v }
puts [p]   ;# -9223372036854775808 -- WRONG (silently wraps)

set v 9223372036854775807
incr v
puts $v    ;# 9223372036854775808  -- correct (typed at tclsh's own top level, not compiled)
```

`incr` as it runs inside a compiled `proc` (`generic/tclExecute.c`'s
`INST_INCR_SCALAR1_IMM`/`INST_INCR_SCALAR_IMM` handler) computes the
overflow-detecting sum correctly, but on the *overflow* branch re-derives
the result via plain `Tcl_WideInt` addition (`TclNewIntObj`/`TclSetIntObj`
with `w + increment`) instead of promoting to a bignum -- the exact
computation that just overflowed, repeated, then stored as if it hadn't.
Verified via direct source diff across `core-9-0-1`, `core-9-0-2`,
`core-9-0-3`, `core-9-0-4` and `core-9-1-a1` (github.com/tcltk/tcl): the
relevant lines are byte-for-byte identical in every one of them; none of
their release notes mention it. `incr` typed directly at tclsh's
interactive top level (uncompiled) is unaffected -- only code inside a
`proc`, where bytecode compilation applies, hits this.

**Practical consequence for any code in this repo**: never use `incr` in a
loop whose counter could plausibly reach `i64::MAX`/`i64::MIN`
(9223372036854775807 / -9223372036854775808) -- use
`set v [expr {$v + 1}]` instead, which correctly uses Tcl 9's ordinary
arbitrary-precision `expr` arithmetic. Botlish's own `Int` is
arbitrary-precision (this project's whole point), so any Tcl-side loop that
iterates over or reconstructs a range of Botlish Int values is a candidate
for this -- `hir/range.tcl`'s `ExactOf` hit it exactly this way; see that
file's own comment.

**Do not "fix" this by pinning a newer Tcl 9**: no released or alpha
version fixes it (checked above), and the Ubuntu packages newer than
`9.0.1+dfsg-1` (`9.0.2`, `9.0.3`, `9.0.4`, all still in the same `universe`
pool path) require `glibc >= 2.42`, which this sandbox's (and, as of this
writing, GitHub Actions' `ubuntu-latest`) base image does not have --
installing one over `9.0.1` breaks `tclsh9.0` outright (`GLIBC_2.42' not
found`) until it's downgraded back. `9.0.1` remains the correct pin for
both this reason and because it is not actually behind on this specific
bug.

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

## Running Linux tests from Windows with WSL

The Windows development machine has an Ubuntu 24.04 WSL distribution with
the repository toolchain already installed. Run Linux-native validation from
PowerShell through that distribution, using the mounted Windows checkout:

```powershell
wsl.exe -d Ubuntu-24.04 -- bash -lc 'cd /mnt/c/Users/MarkusWagner/dev/botlish && export LANG=C.utf8 LC_ALL=C.utf8 && tclsh9.0 tests/all.tcl'
```

The WSL checkout is the same working tree as the Windows checkout, not a
separate clone. Check `git status` before running tests and do not stash or
discard changes merely to switch environments.

## Native GC-stress validation

`BOTLISH_NATIVE_GC_STRESS=1` forces a GC attempt at every allocation site,
which is how native stack-walking/root-tracking bugs get caught. This used
to be a manual step agents were required to run locally on every relevant
change; it is no longer mandatory by hand. It now runs automatically in CI
on every push to `main`, as the `gc-stress` job in
`.github/workflows/tests.yml`.

Before touching anything in `native/` that affects stack walking, roots, or
allocation (GC, stack maps, escape analysis, block/root storage), check
whether the most recent `gc-stress` run on `main` passed. A prior failure
there is a standing signal worth reproducing and fixing, not something to
work around.

Agents are not restricted from running GC-stress locally as well, on top of
what CI covers — do so whenever it's diagnostically useful (e.g. to
reproduce a CI failure, or to validate a stack-walking change before
pushing). To run it locally on Linux, build the release backend and run the
suite with stress enabled:

```sh
export LANG=C.utf8 LC_ALL=C.utf8 BOTLISH_NATIVE_GC_STRESS=1
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 tests/all.tcl
```

From Windows, run the same thing inside WSL for Linux GC-stress results
when validating native stack walking (Windows-native execution exercises a
different stack/guard implementation):

```powershell
wsl.exe -d Ubuntu-24.04 -- bash -lc 'cd /mnt/c/Users/MarkusWagner/dev/botlish && export LANG=C.utf8 LC_ALL=C.utf8 BOTLISH_NATIVE_GC_STRESS=1 && cargo build --release --manifest-path native/Cargo.toml && tclsh9.0 tests/all.tcl'
```
