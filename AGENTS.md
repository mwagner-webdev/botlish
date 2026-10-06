# Notes for agents working in this repository

## Git workflow

Push finished work directly to `main`. This project does not use a
feature-branch-plus-pull-request review cycle: don't open a PR unless
explicitly asked to.

## Compiler architecture (three representations)

* **HIR** (`hir/`) is the authoritative semantic representation; every analysis
  fact lives in it or in its side tables.
* **Core IR** (`core/`) is the small executable representation of the Tcl
  reference interpreter (and the Tcl compiler's input). HIR lowers to it
  (`hir::lower`); it is not on the native path.
* **NIR** (`native/`) is the production executable representation. Native
  compilation starts from resolved, analyzed HIR (`native::lowered`,
  `native::evalHir`, `native::executable`, ...) and never goes through Core IR:
  do not add a native entry point that accepts Core IR, and do not lower HIR to
  Core IR and rebuild HIR from it (`tests/direct-hir-native.test` guards this).
  `DIRECT-HIR-NATIVE-PATH.md` has the details. Tests that run Core-IR-text
  programs on `cranelift` do so through a harness backend in `tests/helpers.tcl`
  that hands native the HIR the program was lowered from (or reads hand-written
  IR text into HIR); it is not a production entry point.

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

## Running tests concurrently

Two test runs that share a working directory or a checkout interfere, and the
failures look like real bugs (`couldn't open ".../contexts-scratch/p79.bot":
no such file or directory`, `no such module file .../lib/X.bot`). This covers
an agent parallelizing its own runs, two sessions in one checkout, and a
Windows run beside a WSL run (same tree, above). What is shared
(TEST-SUITE-COST.md section 4 has the measurements):

* **tcltest's temporary directory is the current working directory** unless
  `-tmpdir` is given. Test files create fixed-name scratch directories in it
  (`abi-bytes-scratch`, `argv-aot`, `contexts-scratch`, ...) and delete or
  sweep them, so two runs of the *same* test file with one temporary directory
  delete each other's files. Pass a private absolute directory:
  `tclsh9.0 tests/all.tcl -tmpdir /tmp/run-A ...` (tcltest forwards it to
  every per-file child process). *Different* test files sharing one
  temporary directory, two or three at a time, ran the whole suite cleanly.
* **The real `lib/` and the repository root.** Some tests write fixed-name
  modules into `lib/` itself (TEST-SUITE-COST.md lists them), and
  `stdlib-namespaces.test`'s fuzz smoke uses a fixed `.fuzz-stdlib-namespaces`
  directory in the repository root. `-tmpdir` does not isolate these: two
  concurrent runs that include those files need separate trees.
* **`tests/native-coverage.tcl`** writes (and first deletes)
  `native-coverage.log` in the current directory and passes no options to
  `all.tcl`: start each coverage run from its own empty directory.
* **`native/target/release`.** Every native test runs `botlish-native` from
  there, and the executable (AOT) tests link `libbotlish_native.rlib` at test
  time. A `cargo build` during a run swaps them under it. A copied tree needs
  all of `native/target` (a symlink to the original works); a copy with only
  the binary fails every AOT test with `runtime library missing`.

So for concurrent runs: one tree per run (for example `tar
--exclude=./native/target --exclude=./.git` into a scratch directory plus a
`native/target` symlink), each started from its own working directory or with
its own `-tmpdir`, and no native rebuild until they finish. A run started from
the repository root and interrupted leaves its scratch directories in the
working tree: check `git status` before committing. New tests and tools
should not add to the list: use `file tempdir` (or a name with `[pid]`) for
scratch space, never a fixed name in the working directory or the repository.

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

## Compiler warnings

Warnings (`hir/warnings.tcl`, WARNINGS-SAME-RETURN.md) are on by default and
have exactly one global policy per compilation: `-warnings default|off|error`
(`surface::compile`/`readProgramFile`, `main.tcl`). There are deliberately no
`-Wfoo` switches, groups, levels or source suppression: don't add them, and
don't add a warning that is not backed by a compiler proof. The test harness
(`tests/helpers.tcl`) sets `BOTLISH_WARNINGS=off` as the process default,
because tcltest counts stderr output as a test-file error; `tests/warnings.test`
passes its policy explicitly on every compile. Benchmark and analysis scripts
that compile corpus sources pass `-warnings off` themselves.

`METHOD-ELIGIBLE` (WARNINGS-METHOD-ELIGIBLE.md) is backed by a checked proof,
the round-trip law: the sugared spelling of every call it reports must parse,
resolve to the same callee and compile to the same program. If you change
method sugar, the resolver's candidate gathering or what the frontend records
in a call's `written` marker, run `tests/method-eligible.test` and
`audit/method-eligible/tools/fuzz.tcl`. `nomethod fn` is a declaration by the
function's author that method syntax to it is an error; it is not a warning
suppression, and there is still no call-site suppression to add.

`FIXED-ARITY-LIST-RETURN` (WARNINGS-FIXED-ARITY-LIST-RETURN.md) reads the
frontend's `written {form list}` provenance, milestone 1's exit enumeration
(`Exits`/`Leaves`) and completion walk, `hir::exact::AliasRoot`,
`hir::resolve::CandidateIdentity` and the block's `declaredResult`. If you change
any of those, or how a list literal, an else-less `if` or a result annotation
lowers, run `tests/fixed-arity-list-return.test` and
`audit/fixed-arity-list-return/tools/fuzz.tcl`. A list-typed result annotation
(`-> list`, `-> List[T]`) is a real type the checker proves, not a suppression;
do not add another opt-out (MULTI-VALUE-RESULTS.md). Library
modules' own findings print for every program that loads them (the corpus is
frozen), so tests that import `lib/*.bot` and assert on a complete warning set
filter by code or file.
