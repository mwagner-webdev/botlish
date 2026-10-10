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

Two test runs that share a working directory or a checkout interfere unless
each has its own tcltest temporary directory, and the failures look like real
bugs (`couldn't open ".../contexts-scratch/p79.bot": no such file or
directory`). This covers an agent parallelizing its own runs, two sessions in
one checkout, and a Windows run beside a WSL run (same tree, above). What is
shared (TEST-SUITE-COST.md section 4 has the measurements):

* **tcltest's temporary directory is the current working directory** unless
  `-tmpdir` is given. Test files create fixed-name scratch directories in it
  (`abi-bytes-scratch`, `argv-aot`, `contexts-scratch`, ...) and delete or
  sweep them, so two runs of the *same* test file with one temporary directory
  delete each other's files. Pass a private absolute directory:
  `tclsh9.0 tests/all.tcl -tmpdir /tmp/run-A ...` (tcltest forwards it to
  every per-file child process). *Different* test files sharing one
  temporary directory, two or three at a time, ran the whole suite cleanly.
  `tests/native-coverage.tcl` gives the suite it runs a private `-tmpdir` (and
  keeps its log there) by itself.
* **`native/target/release`.** Every native test runs `botlish-native` from
  there, and the executable (AOT) tests link `libbotlish_native.rlib` at test
  time. A `cargo build` during a run swaps them under it. A copied tree needs
  all of `native/target` (a symlink to the original works); a copy with only
  the binary fails every AOT test with `runtime library missing`.

So for concurrent runs in one checkout: one `-tmpdir` per run, and no native
rebuild until they finish:

```sh
export LANG=C.utf8 LC_ALL=C.utf8
CORE_BACKEND=interp tclsh9.0 tests/all.tcl -tmpdir "$(mktemp -d)" &
CORE_BACKEND=compile tclsh9.0 tests/all.tcl -tmpdir "$(mktemp -d)" &
wait
```

A run started from the repository root without `-tmpdir` and interrupted
leaves its scratch directories in the working tree: check `git status` before
committing.

Outside its tcltest temporary directory, nothing a test does may use a fixed
name; new tests and tools must keep it that way:

* A test that needs a throwaway module next to the standard ones wraps its
  body in `withPrivateLibrary` (`tests/helpers.tcl`), which points
  `$::core::libraryDir` at a per-process copy of `lib/` in the tcltest
  temporary directory. Never write into the real `lib/`.
* A script or audit tool keeps its scratch files in a `file tempdir` directory
  (or under a name with `[pid]`) and removes it when it finishes, never under a
  fixed name in the working directory or the repository; one that runs a test
  file passes it a private `-tmpdir`.

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
modules' own findings print for every program that loads them, so tests that
import `lib/*.bot` and assert on a complete warning set filter by code or file.
Since the warning-driven refactor (next section) only three modules carry any,
all `ONE-CHAR-STRING-LITERAL` and all listed in `audit/refactor/manifest.txt`:
`lib/web.bot` 23 (its hex-digit table, `"%"`, and the local-part and label
classes), `lib/io.bot` 2 (`"\n"`) and `lib/linux/path.bot` 2 (`"/"`). Every
other module is warning-clean.

`SAME-FAILURE` (WARNINGS-SAME-FAILURE.md) reads the `fail` sites of a function's
own body (milestone 1's `BodyExprs`, which never enters a nested function), each
`fail` node's `name` and `reachable` flag, the block's resolved `declaredErrors`,
the canonical module-qualified error identities (`hir/errordecls.tcl`) and the
completion walk (`hir::completions::reachedExprs`, which records `fail` sites
and never enters a nested function either). If you change any of those, or how
`fail`, `errors` or an on-handler body lowers or resolves, run
`tests/same-failure.test` and `audit/same-failure/tools/fuzz.tcl`.

`PROVES-NAMING` (WARNINGS-PROVES-NAMING.md) reads, per function declaration, the
block's resolved proof contract (`proofs`, `hir/resolve.tcl`'s
`ResolveProofs`), its `params` minus its `flags`, its `declaredResult`, and the
declaring binding's written name (hygiene's recorded `spelling`, else the name
without a `#N` suffix, then `hir::warnings::MemberName` for a module's
qualified spelling). It runs no walk and reads no reachability. If you change
the proof-clause grammar or validation, how a declared result or the flag
section is recorded, hygiene's renames (`hir/hygiene.tcl`: `spelling`,
`qualifyModules`), or the naming convention in REFINEMENT-VALUES.md ("Naming"),
run `tests/proves-naming.test` and `audit/proves-naming/tools/fuzz.tcl`. The
response to this warning is a rename; do not add an opt-out, a reverse rule
(`?` implies bool) or a check on functions without `proves`.

`ONE-CHAR-STRING-LITERAL` (WARNINGS-ONE-CHAR-STRING-LITERAL.md) reads, per
`const` node, its exact value (`hir::exact::Of`: exact String values) and
measures it with the reference `str::length` (`core::strings::length`); the one
String const the frontend synthesizes, a context parameter's
`context#load("ID")` key, is recognized by `hir::contexts::isLoad` and never
reported. If you change how a String or character literal lexes, lowers or reads
back from HIR text, the exact value of a constant, `str::length`, or build a
String const anywhere in the frontend (`tests/one-char-string-literal.test`'s
`oc-synthesized-string-consts-enumerated` lists every place that does), run
`tests/one-char-string-literal.test` and
`audit/one-char-string-literal/tools/fuzz.tcl`. The warning is context-blind and
not autofixable on purpose: do not add a context gate, an opt-out, the
character spelling to its message or data, or a fixit.

`MANY-BOOLEAN-ARGUMENTS` (WARNINGS-MANY-BOOLEAN-ARGUMENTS.md) reads, per call,
the frontend's `written` provenance (`function`/`method` only), the call's
`reachable` flag and `args`, the callee reference resolved through aliases by
`hir::resolve::CandidateIdentity` to a declaring `bind` of a block (or a root
native and its registry `paramTypes`), the block's `params` minus its `flags`,
and the parameter types the checker proves (`hir::signatures::entryTypes`:
declared, else the TRUSTED inferred contract -- never a CHECKED one). Its
evidence is an argument that is a reference to the root `true` or `false`,
which is how the frontend lowers those keywords; flag arguments are the
trailing `bool` constants hir/flags.tcl appends and are never read. If you
change call provenance, how `true`/`false` or a call's arguments lower, the
flag transport (`hir::flags::ResolveCall`), alias resolution, the trusted /
checked split of `hir/signatures.tcl`, or a native's parameter types, run
`tests/many-boolean-arguments.test` and
`audit/many-boolean-arguments/tools/fuzz.tcl`. The warning counts literals
only and is not autofixable on purpose: do not count flags, bindings or
computed bools, follow exact values, group per callee, warn on a declaration
without call evidence, print a flag spelling, or add a fixit or an opt-out
(FLAGS.md, "Boolean arguments", records the graduation criteria).

## The warning gate

The shipped stdlib, libraries, examples and benchmarks compile clean under
Botlish's own warnings, except exactly the findings `audit/refactor/manifest.txt`
lists, each with the obstruction that keeps it open (REFACTOR-WARNINGS-CLEAN.md).
`audit/refactor/tools/gate.tcl` checks it -- every corpus program and a one-line
loader per library module, the observed warnings equal to the manifest (code
and location), and every program and loader without an entry compiling under
`-warnings error` -- and the `warning-gate` job of `.github/workflows/tests.yml`
runs it on every push and pull request (`tests/warning-gate.test` pins that it
passes and that it fails on a planted warning).

If you add or change a program in `examples/`, `bench/` or `lib/`, run
`tclsh9.0 audit/refactor/tools/gate.tcl`:

* A new warning is answered in the code -- convert it, annotate the result
  type, merge the exits or guards, or mark the callee `nomethod` for a stated
  reason -- never by adding a manifest entry. The manifest grows only at a
  re-audit that names an obstruction no mechanism of the language closes, per
  finding.
* An entry leaves the manifest when its finding closes, with the closing
  verified: `audit/refactor/tools/probe.tcl` (behavior probes against the tree
  before the change, every backend) and `audit/refactor/tools/expect.tcl`
  (every `# expect:` value, every backend).
* A manifested literal that moves (a line added above it) is a location drift
  the gate reports: update its line and column in the manifest.
* A new corpus program must be listed (with its entries, if any).
* Do not edit `audit/refactor/kickoff-corpus/`: it is the frozen,
  warning-bearing fixture the backend-independence CLI tests (and one
  String-region test of the `peek()` idiom) read, not corpus.

## Refinement values

`refined type NAME = CARRIER` and `proves PARAM: NAME` (REFINEMENT-VALUES.md)
are generic: no compiler or runtime file may name a corpus refinement or its
predicate (`tests/refinement-values.test` greps for `Emailish`,
`UriQueryValue`, `emailish?`, `uri_query_value?`), and a refined value has
exactly its carrier's representation -- never add a runtime tag, wrapper or
check to recover one. If you change the proof contract resolution
(`hir/resolve.tcl`'s `ResolveProofs`), implications, call keys or a
validator's completion facts (`hir/refine.tcl`), the `if` join, the
decided-call rule or how a call's completion facts flow and a handled call
joins its handlers (`hir/types.tcl`'s `Call` and `Handle`), repeatability
(`hir/repeatable.tcl`), a native's `-context-free` classification, or how
`-> unit` and a proof clause parse, run `tests/refinement-values.test`,
`tests/refinement-validators.test`, `tests/emailish-predicate.test` and
`audit/refinement-values/tools/fuzz.tcl` (validators are on by default;
`-validators 0` reproduces the predicate-only generator's runs).

## Traits

Traits (TRAITS.md) are eager, one-way, entirely static views: a trait-typed
value is its concrete witness's value, and every backend compiles a
monomorphized program with no trait type, no trait operation and no
trait-polymorphic function (`hir::traits::monomorphize`). Never add trait
knowledge below HIR: no runtime trait value, wrapper, tag, vtable,
dictionary, witness argument or indirect call for a trait operation, and no
trait code in `core/`, `compiler/`, `native/` (`tests/traits.test`'s
`trait-source-audit`, `-principal-nir`, `-machine-code-direct`,
`-allocation-free` and `-code-quality-identical` pin this). Conformance reads
only the witness's owner namespace's own declarations: never the call
site's imports or another namespace.

If you change conformance (`hir::traits::satisfies` and what it reads), trait
views in inference (`hir/types.tcl`'s subtype/lub/narrow of views,
`hir::traits::Accept`/`EntryView`/`ViewResult`/`TypeCall`), the semantic
instance key of a trait parameter (`hir/semantic.tcl`), the plan or build 2
(`hir::traits::Plan`, hir/resolve.tcl's clone/planned-call resolution), run
`tests/traits.test`, `audit/traits/tools/fuzz.tcl` and
`audit/traits/tools/mutate.tcl` (which needs every mutant in
`audit/traits/tools/mutants.txt` to still apply: update a mutant's text when
you change the code it mutates, and keep it a mutant of the same rule).
`audit/traits/tools/evidence.tcl` regenerates `audit/traits/principal/`.

## Context traits

Context traits (CONTEXT-TRAITS.md) are environment abstractions resolved
entirely before any backend runs: a `context trait` has no value, slot, tag,
table or runtime representation; the one installed context implementing it
is selected statically at each top-level call (exactly one, never ranked);
every function whose requirement includes a context trait is cloned for the
selection by the trait monomorphization (`hir::traits::Plan`), and every
operation becomes a direct call of the selected context's implementation.
Never add a runtime provider lookup, a context-trait slot in the native
context area, a hidden context or dictionary argument, or context-trait code
in `core/`, `compiler/` or `native/` (the one exception is the dead-code
placeholder `context#unreachable`, which never runs). Satisfaction reads only
the concrete context's owner namespace (`hir::contexts::satisfiesTrait`).

If you change satisfaction (`hir::contexts::satisfiesTrait`,
`TraitImplementation`), selection (`hir::contexts::Obligations`), the binding
check (`CheckTraitBindings`), context-trait typing (`hir::traits::TypeCall`,
`hir::types::ShapeResult`'s context-trait case), the plan's context-trait
actions or the planned-call resolution (`hir/resolve.tcl`'s
`ResolvePlannedCall`), or lib/io.bot, lib/linux/io.bot, lib/linux/path.bot,
run `tests/context-traits.test`, `tests/portable-io.test`,
`tests/linux-path.test`, `audit/context-traits/tools/fuzz.tcl` and
`audit/context-traits/tools/mutate.tcl` (every mutant in
`audit/context-traits/tools/mutants.txt` must still apply: update a mutant's
text when you change the code it mutates, keeping it a mutant of the same
rule). Changing `hir::traits::Plan` also means re-checking the trait mutants
(`audit/traits/tools/mutants.txt`).

## Coroutines

Coroutines (COROUTINES.md) are eagerly started, affine resumable
computations: `yield` is a statically tracked deep control effect, and every
coroutine operation is an internal root native (`coroutine#create`,
`#start`, `#resume`, `#yield`, `#release`, and `coroutine::done?`).
Ownership is entirely static: there is no runtime moved state, no copy, fork
or clone operation, no iterator protocol, no exhaustion error and no
resumable error -- don't add any (`tests/coroutines.test`'s `co-source-*` tests pin this). A handle is an
affine value (next section): where it may live is decided by
`hir::affine::Consumer` for every affine value alike, and a new place (a
closure capture, an erasing argument, a mutable container) is a deliberate
extension of that discipline, never a side effect.
Contexts and context traits stay static: a coroutine's providers are the
ones selected at its construction, and suspension adds no context or trait
machinery to either runtime.

A coroutine is released right after its handle's last use
(`hir::affine::Releases`, COROUTINES.md "Release at the last use"):
every backend emits the release after that statement (`hir/lower.tcl`'s
`Seq`, the Tcl compiler's `CompileSequence`, `native/lower.tcl`'s `Sequence`)
and keeps the statement's value. An exit that leaves the handle's scope
first -- a `return`, `fail`, `break` or `continue`, or a call propagating a
declared error -- releases it there (`hir::affine::ExitReleases`,
COROUTINES.md "Release on every early exit"): before the exit (after its
value, for a handle the value uses), and on a call's error edge through a
handler-shaped catch that releases and propagates the same error on
(`hir/lower.tcl`'s `ReleasingOnError`, the Tcl compiler's
`ReleasingOnError`/`CompileHandle`, `native/lower.tcl`'s `Call`/`Handle`
pads). An error edge uses the call's type-level `calleeErrors`, never the
completion proofs. A release must stay unobservable -- it never runs
Botlish code (a released suspended Tcl coroutine is unwound by an error no
handler catches) and never changes a value -- and must never release a
coroutine some live binding still owns. The affine-values milestone
extended it to every affine value, keeping both properties.

If you change the coroutine grammar (`yield`, the coroutine binding, the
resume clause), `hir/coroutines.tcl` (protocols, the yield effect),
`hir/affine.tcl` (the ownership analysis), how a construction lowers (`surface/lower.tcl`'s
`CoroutineBind`) or resolves (`hir/resolve.tcl`'s `CoroutineResume`), a
segment's error facts (`hir/completions.tcl`'s `NativeCallFacts`), where
releases go or how they lower, the Tcl runtime (`core/coroutines.tcl`) or the
native one
(`native/src/runtime/coroutine.rs`, the GC's walk of suspended and resumer
stacks in `heap.rs`/`vm.rs`), run `tests/coroutines.test`,
`audit/coroutines/tools/fuzz.tcl` (several seeds) and
`audit/coroutines/tools/mutate.tcl` (every mutant in
`audit/coroutines/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of
the same rule; native mutants rebuild a private copy of `native/`, never this
checkout's). A change to native stack switching or its GC walk also needs a
`BOTLISH_NATIVE_GC_STRESS=1` run of `tests/coroutines.test` and
`cargo test --release --manifest-path native/Cargo.toml --lib coroutine`.
`bench/coroutines.tcl` regenerates the performance report.

Native coroutines switch stacks with hand-written x86-64 assembly and exist
on x86-64 Linux only; elsewhere the native backend reports them unsupported
(the Tcl backends run them everywhere).

## Affine values

Affinity (AFFINE-VALUES.md) is a compositional property of a value's type:
the coroutine handle is the one primitive affine root, and a struct,
anonymous struct or List that owns an affine value is affine too
(`hir::types::Affinity`/`IsAffine`, the one query every ownership decision
asks). An affine value has one usable owner and moves through bindings,
arguments, results, struct fields and List elements; it is released where
its owner dies, by its type's static drop descriptor (`coroutine#release`,
or `affine#drop`/`affinedrop` for an aggregate). `Fn{...}` and
`Coroutine{...}` share one callable contract (args, return, errors) and stay
distinct callable kinds: never add an implicit conversion between them, a
runtime callable-kind dispatch, or runtime ownership state (a moved flag, a
reference count, an ownership object): `tests/affine.test`'s
`af-native-runtime-source`, `af-generic-dual` and `af-native-evidence` pin
this. An exact function value stays unrestricted. A generic (untyped)
function given an affine argument is specialized for it by the trait
monomorphization (`hir::traits::NeedsAffinePlan`, `AffineWitnesses`), never
dispatched at run time; `hir/affine.tcl` must never ask whether a value is a
coroutine, only whether its type is affine. The terms are unrestricted,
affine, move, release/drop, callable contract and callable kind; an affine
value is not a reference, a borrow or a linear value, and may be dropped
unused.

If you change the affinity query (`hir/types.tcl`, `hir/structs.tcl`),
`hir/affine.tcl`, contract-based call typing of `Fn`/`Coroutine` callees
(`hir/types.tcl`'s `Call`, `hir/range.tcl`'s `VerifyStructuralCall`,
`hir/completions.tcl`), `hir::coroutines::ElaborateResumes`, the affine
specialization (`hir/traits.tcl`, `hir/semantic.tcl`'s affine instances,
`hir::signatures::CallableAdmits`), release or pending-temporary lowering in
any backend, or the drop runtimes (`core/affine.tcl`,
`native/src/runtime/affine.rs`), run `tests/affine.test`,
`tests/coroutines.test`, `audit/affine/tools/fuzz.tcl` (several seeds),
`audit/affine/tools/mutate.tcl` and `audit/coroutines/tools/mutate.tcl`
(every mutant in both `mutants.txt` files must still apply and be killed;
the coroutine mutants of ownership and release edit `hir/affine.tcl` too).
A change to `hir::traits::Plan` for affine witnesses also means re-checking
the trait and context-trait mutants. A change to native drop or release
lowering also needs a `BOTLISH_NATIVE_GC_STRESS=1` run of
`tests/affine.test` and `cargo test --release --manifest-path
native/Cargo.toml --lib affine`. `bench/affine.tcl` regenerates the
performance report.

## Enums

Enums (ENUMS.md) are named, closed, nominal sums of payload-free cases:
`enum Name:` declares one type `{enum ID}` (ID the declaration identity, a
module's `ns::Name`) and its cases; `Name::Case` resolves, as a *type*
qualifier (never a namespace), to a `const` node of the value `{enum ID
CASE}`. A case's identity is (enum identity, case name): never a spelling
alone, never a position. Never add an ordinal, integer or String conversion,
an ordering, a reflection operation (`cases`, `case_count`, `case_name`), an
anonymous enum, a case alias or value, or a global case namespace (a bare
case name must stay unbound); no semantic check may read a case's position
(`hir::enums::cases` keeps declaration order for diagnostics and future
exhaustiveness only). Native case words carry an enum number and a case
number that are representation only: printing and hashing read the names from
the program's enum table. Affinity is derived from the case descriptors'
payloads (`hir::enums::IsAffine`), never decided by being an enum.

If you change the enum grammar (`surface/parser.tcl`'s `EnumDecl`),
`hir/enums.tcl`, the `{enum ID}` cases of `hir/types.tcl`, case resolution
(`hir/resolve.tcl`'s `ResolveEnumCase`, `surface/modules.tcl`'s
`EnumQualifier`), the HIR text of enums (`hir/format.tcl`, `hir/read.tcl`), the
Tcl runtime's enum value, equality or hashing (`core/value.tcl`,
`core/hashing.tcl`), or the native word, enum table, `enumeq` or `rt_hash`
case (`native/lower.tcl`, `native/src/runtime/{value,ops,show}.rs`), run
`tests/enums.test`, `audit/enums/tools/fuzz.tcl` (several seeds, once with
`-gc-stress 1`), `audit/enums/tools/mutate.tcl` (every mutant in
`audit/enums/tools/mutants.txt` must still apply and be killed: update a
mutant's text when you change the code it mutates, keeping it a mutant of the
same rule) and `cargo test --release --manifest-path native/Cargo.toml --lib
enum`. `bench/enums.tcl` regenerates the performance report.

## Error payloads

An error is a nominal identity that may carry a statically known named-field
payload (ERROR-PAYLOADS.md): `error NAME:` and `field: Type` lines, `fail NAME
{field: value}`, `on NAME:` / `on NAME details:` / `on NAME {a, b: c}:`. `on`
discriminates the identity only: never add value patterns, guards, payload-
or shape-driven handler selection, a handler-specific destructuring rule, an
implicit `message`/`code` field, a key/value payload access or a
`Result`/`Error[E]` encoding. The payload is the anonymous struct of the
declared fields (`hir::errordecls::payloadType`), checked like a named
construction (`hir/resolve.tcl`'s `ResolveStruct` with `payloadOf`,
`hir::range::VerifyPayload`); handler destructuring is the ordinary
destructuring expansion over the handler's payload binding
(`surface/lower.tcl`'s `Handlers`). A payload-free error keeps its
one-word representation everywhere (Tcl `{errorId NAME}`, native
`faildeclared ID NAME` with no payload slots): never make every error carry a
payload object. Natively a payload travels field-wise in the Vm's payload
slots (`Vm::declared_payload`, a GC root) -- never box it to transport it.
A coroutine may not fail with an error whose payload is affine
(`hir::coroutines::AffineProtocol`): its cached failure is raised again.

If you change the error declaration or payload grammar, `hir/errordecls.tcl`,
the `fail`/`handle` resolution, typing, affine flow or lowering in any
backend, `errorId` (`core/value.tcl`), the native payload slots
(`native/src/runtime/{vm,ops,coroutine}.rs`, `Inst::Fail`/`DeclaredPayload`)
or `hir::warnings::FailSites`, run `tests/error-payloads.test`,
`tests/errors.test`, `tests/same-failure.test`, `tests/affine.test`,
`tests/coroutines.test`, `audit/error-payloads/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/error-payloads/tools/mutate.tcl`
(every mutant in `audit/error-payloads/tools/mutants.txt` must still apply
and be killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule), `audit/same-failure/tools/mutate.tcl`
and `cargo test --release --manifest-path native/Cargo.toml --lib
error_payload`. `bench/error-payloads.tcl` regenerates the performance
report.


### Error identity

A source-defined error's identity is canonical and module-qualified
(ERROR-PAYLOADS.md, "Module-qualified error identity"): `NS::Name` for module
NS's `error Name`, the bare `Name` for the entry program's and for the
runtime's builtin errors. Every spelling (`fail`, `on`, `errors` clauses, a
function type's `errors` list) is resolved once, in the namespace of the code
that writes it (`hir::errordecls::resolve`), and everything downstream --
HIR, contracts, completion sets, Core IR, `errorId`, native ids, rendering,
`SAME-FAILURE` -- holds the canonical string. Never key, compare or dispatch
by a short name, never add an `import error` form, an alias or a
compatibility spelling, and never let a module see the entry program's
errors. If you change error-name resolution or authorization
(`hir/errordecls.tcl`, `surface/modules.tcl`'s error references,
`surface::parser::ErrorName`), run `tests/namespaced-errors.test`,
`tests/imports.test`, `tests/same-failure.test` and
`audit/error-payloads/tools/fuzz.tcl` (its namespaced programs).

### Completion precision through untyped callables

The completion analysis never turns lost precision into "no errors"
(STATIC-COMPLETION-PROOFS.md, "Precision and the erased-callable contract"):
an untyped or structural call is charged by its callee's callable fact
(`hir::completions::CallableFact`: exact, clean or unknown), an unknown one
the erased-callable contract, and an incomplete summary falls back to the
callee's declared contract (`EffectiveFacts`, `Fallback`). Fallbacks are
may-sets only (never a KNOWN-ERROR). If you change the walker's call, handle
or bind cases, `EffectiveFacts`/`Fallback`/`IndirectFacts`, the erased-callable
contract (`erasedErrorsOf`, `hir::callables::CarriedErrors`) or
`hir/affine.tcl`'s error edges, run `tests/higher-order-completions.test`,
`tests/error-payloads.test` and `audit/error-payloads/tools/mutate.tcl` (its
completion mutants).
## MutableVector

`MutableVector[T]` (MUTABLE-VECTOR.md) is a growable mutable VALUE: a
runtime *header* (the identity of one logical value, mutated in place) over
a copy-on-write *backing*. A mutation never rebinds anything: its receiver
must be a *place* (a local, parameter or context parameter of the same
function, or a field path from one), checked by `hir::mutvec::verify`
(`MUTABLE-PLACE-RECEIVER`, `MUTABLE-PLACE-CAPTURE`). Value semantics come
from the logical copies `hir::mutvec::Elaborate` writes out
(`mutable_vector#share`: read-outs of a place, entries into one; a
function's own place returned moves its header out instead). Never add a
reference, an alias between places, a rebinding, an assignment, or runtime
ownership state (an owner, a moved bit, an affine flag: `mv-runtime-source`
pins this); the backing's `Rc` count is copy-on-write bookkeeping only.

Affinity is the element's (`hir::types::IsAffine`): an affine vector is
never shared, moves whole, and moves elements only through push/swap in and
pop/take/swap/consuming iteration out; `at` of an affine element is
`AFFINE-ELEMENT-COPY-OUT`; clear, a failed swap and a dying vector release
by the static descriptor (`v`D), first to last.

If you change the vector type, `hir/mutvec.tcl`, the vector cases of
`hir/affine.tcl` (consumers, consuming loops, `LoopDomain`, path releases),
consuming-loop lowering (`hir/lower.tcl`, `core/evaluator.tcl`,
`compiler/compiler.tcl`, `native/lower.tcl`) or either runtime
(`core/mutvec.tcl`, `native/src/runtime/mutvec.rs`), run
`tests/mutable-vector.test`, `audit/mutable-vector/tools/fuzz.tcl` (several
seeds, once with `-gc-stress 1`), `audit/mutable-vector/tools/mutate.tcl`
(every mutant in `audit/mutable-vector/tools/mutants.txt` must still apply
and be killed: update a mutant's text when you change the code it mutates,
keeping it a mutant of the same rule) and `cargo test --release
--manifest-path native/Cargo.toml --lib mutvec`, plus the affine and
coroutine harnesses for any change to `hir/affine.tcl` (above). A change to
native tracing, growth or drops also needs a `BOTLISH_NATIVE_GC_STRESS=1`
run of `tests/mutable-vector.test`. `bench/mutable-vector.tcl` regenerates
the performance report.

## MutableArray

`MutableArray[T]` (MUTABLE-ARRAY.md) is MutableVector's fixed-length
sibling and follows the same model: a VALUE, a header over a copy-on-write
backing (Tcl: a `{mutarray ID}` over the shared Tcl list in
`core::mutarray::store`; native: `MutArrayObj` over an `Rc<[Value]>`), its
mutations made through places (`MUTABLE-PLACE-RECEIVER`,
`MUTABLE-PLACE-CAPTURE`), its logical copies written out by
`hir::mutvec::Elaborate` (`mutable_vector#share`, descriptor `h`; `d`, a
copy of whatever the value is at run time, inside a generic body whose
static type is too imprecise to say). It used to have reference semantics: never
reintroduce an alias between two arrays, a reference, or runtime ownership
state. Like a vector it is covariant (MutableArray[S] <: MutableArray[T]
when S <: T; the raw kind `mutarray` is MutableArray[any]) while a typed
parameter admits exactly its contract (`hir::range::AggregateAdmits`); an
erased array holds a copy, so no erasure check guards it (only the
callable contracts of its elements, `hir::callables::Bearing`).

Affinity is the element's: an affine array moves whole, is never shared,
and moves elements only through swap/set in and swap/consuming iteration
out (there is no take, pop or clear: a fixed-size array has no empty slot);
`at`, `freeze` and a copy's source of an affine element are
`AFFINE-ELEMENT-COPY-OUT`; a failed swap, a displaced `set` element, a
failing factory's earlier results and a dying array release by the static
descriptor (`a`D), first to last. The specialization key keeps an affine
array's element (`hir::specialize::ElementKeyType`): erased, an instance
would see an unrestricted array and drop nothing.

Every collection operation's ownership behavior is registration metadata,
never a name: `-ownership` roles (core/native.tcl: `repeat` for create's
value -- an affine one is `AFFINE-DUPLICATION-UNSUPPORTED` --, `factory`
for generate's, `move`, `place`, `copy-out`, ...), `-drop-form` (the
dropping variant hir/mutvec.tcl retargets an affine operation to),
`-result-length` (hir/cardinality.tcl) and the receiver role
(`hir::mutvec::OpKind`). Do not add a check keyed on a native's name
(`mat-id-4` fences `hir/`, `compiler/` and `surface/`); register a role.
`mutable_array::generate(n, f)` calls F once per slot, in index order, under
the callable-contract model (`hir::containers::VerifyFactory`, `-errors-from`).

If you change the array runtime (`core/mutarray.tcl`, the array section of
`native/src/runtime/ops.rs`), its registrations or roles, the array cases of
`hir/types.tcl` (affinity, subtype, lub, narrow), `hir/range.tcl`'s
admission, `hir/containers.tcl`, `hir/mutvec.tcl`, `hir/affine.tcl`'s
`NativeConsumer`, consuming-loop lowering or `hir/specialize.tcl`'s key, run
`tests/mutable-array.test`, `tests/mutable-vector.test`,
`tests/mutable-array-type.test`, `audit/mutable-array/tools/fuzz.tcl`
(several seeds, once with `-gc-stress 1`), `audit/mutable-array/tools/mutate.tcl`
(every mutant in `audit/mutable-array/tools/mutants.txt` must still apply
and be killed) and `cargo test --release --manifest-path native/Cargo.toml
--lib mutarray`, plus the vector, affine and coroutine harnesses above for
any change they name. A change to native tracing or drops also needs a
`BOTLISH_NATIVE_GC_STRESS=1` run of `tests/mutable-array.test`.
`bench/mutable-array.tcl` regenerates the performance report.
