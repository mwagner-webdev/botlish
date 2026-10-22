# MACOS-AARCH64-MILESTONE-7.md

Milestone 7 of the macOS Apple Silicon port: C byte borrowing -- the
temporary exposure of `std::abi::bytes::Bytes` and `std::abi::bytes::MutableBytes`
storage to a C call (C-POINTER-BORROWING.md) -- accepted on `macos-aarch64`
through real C: the host compiler's fixture and the system C library.
Developed on Linux; every macOS fact below was observed on GitHub's
`macos-15` arm64 runners through `.github/workflows/macos-arm64.yml` (the
shared Apple Silicon development machine was not used). The audit it updates
is MACOS-AARCH64-PORT-AUDIT.md (its roadmap entry 8); the milestones before
it are MACOS-AARCH64-MILESTONE-1.md to -6.md.

> A borrowed byte pointer is never a first-class Botlish pointer: it is call
> argument transport plus a storage lifetime rule, and it ends when the call
> returns.

## Result

The borrowing implementation needed no change for macOS. Milestone 6 had
made C calls link and run there and had shown that c-ffi.test's few borrowing
cases pass; what this milestone adds is the evidence that the exposure model
holds on Apple's allocator, addresses and C library, and the tooling to keep
checking it there:

* **tests/c-byte-borrowing.test** (20 tests, new): read and write exposures
  through real C -- five new functions of the host-compiled fixture
  (tests/cffi/fixture.c) and the system C library's `memcmp`, `memcpy`,
  `memmove` and `memset` (libSystem on macOS, glibc on Linux) -- every value
  checked against an independent Tcl oracle, on both native backends and in
  standalone executables, under GC stress and inside coroutines; on macOS
  also under Guard Malloc, the system allocator's own out-of-bounds detector.
* **Constraints by capability, not by OS**: the 18 runtime tests whose
  `nativeLinux` predated the port (c-pointer-borrowing 4, native-view,
  native-edit, layout-arrays, layout-unions, binary-layout 2 each,
  abi-mutable-bytes 4) carry the capability they need (`nativeCoroutines`,
  `executableAot`) and run on macOS; their expectations are unchanged.
* **The tools run on macOS**: audit/c-pointer-borrowing/tools/mutate.tcl no
  longer needs GNU `timeout(1)`, knows per-host mutants (`%% TARGET`) and
  reports SKIPPED, NOT-APPLIED and NOT-BUILT apart from KILLED; it gained
  eight mutants (the brief's address, keepalive, copy and owner mutants) and
  c-byte-borrowing.test as a detector. tier.tcl runs the fuzzer, the mutants
  and the benchmark on macOS (`c-borrow-fuzz`, `c-borrow-mutants`,
  `c-borrow-bench`), and native-status records the capability
  (`c-byte-borrow`).
* **Three defects in bb-guard-malloc's positive control, fixed on the way**
  (section 8): Guard Malloc writes a banner to standard error, which Tcl's
  `exec` took for a failure (commit ec7cae8: runs are now judged by exit
  status, a fault by the signal that killed the process); exposed by that
  stricter check, the over-reading program had never compiled (`len(d) + 1`
  is not provably a `size_t`), which the old `catch` had also counted as a
  fault; and once it compiled, Guard Malloc did not catch its one-byte
  over-read of a 4080-byte storage, so the good run of those storages had
  shown nothing. The test now exposes 16-byte storages, whose one-byte
  overruns it shows faulting, with one control per kind of exposure.

## 1. The initial census

Before any change, a macOS dispatch of the borrowing-related files on main
at 6828d12 (run [39574475382](https://github.com/mwagner-webdev/botlish/actions/runs/39574475382),
`tier.tcl` with c-pointer-borrowing, c-ffi, native-view, native-edit,
layout-arrays, layout-unions, binary-layout, abi-bytes, abi-mutable-bytes,
portable-io and context-traits on interp and compile):

```text
all.tcl:  Total 617  Passed 526  Skipped 91  Failed 0
Number of tests skipped for each constraint:
     2  boringssl
    28  linuxX86_64
    60  nativeLinux
     1  tclLibrary
```

Nothing failed; 91 tests did not run. The constraints, file by file (tests
declaring each; one test may declare several), on main (the run's commit,
6828d12, and this milestone's base, 22b0005, alike) and after this
milestone:

| file | tests | `nativeLinux` before | after | what replaced it |
|---|---:|---:|---:|---|
| c-pointer-borrowing.test | 61 | 4 | 0 | `nativeCoroutines` 3, `executableAot` 1 |
| c-byte-borrowing.test (new) | 20 | -- | 0 | `bbFixture` 20 (the fixture built: C calls link), `nativeCoroutines` 1, `guardMalloc` 1 |
| c-ffi.test | 107 | 0 | 0 | (milestone 6) |
| native-view.test | 39 | 2 | 0 | `nativeCoroutines` 2 |
| native-edit.test | 55 | 2 | 0 | `nativeCoroutines` 2 |
| layout-arrays.test | 53 | 2 | 0 | `nativeCoroutines` 2 |
| layout-unions.test | 43 | 2 | 0 | `nativeCoroutines` 2 |
| binary-layout.test | 51 | 2 | 0 | `nativeCoroutines` 2 |
| abi-mutable-bytes.test | 57 | 16 | 12 | `nativeCoroutines` 4 |
| abi-bytes.test | 67 | 23 | 23 | -- |

(The CI's 60 also counts portable-io's 5 and context-traits' 2, which run
Linux IO: milestone 8's subject.)

Each restricted test, classified by the brief's categories:

1. **Ordinary semantic tests on every backend**: c-pointer-borrowing's
   contract, admission, refusal and Tcl-exposure-model tests, the
   front-end tests of the layout files: unrestricted before and after.
2. **Synthetic foreign-boundary tests**: c-pointer-borrowing's fixture
   (`ffi_fixture::`, runtime/ffifixture.rs), which is Botlish's own Rust
   code -- not evidence of an Apple C call, and not counted as such here.
   Its four `nativeLinux` tests (`cb-exposure-after-arguments`,
   `cb-failure-gc-stress`, `cb-allocations`, `cb-executable`) need
   coroutines or GC stress or an executable, none of them Linux.
3. **Real native C calls**: c-ffi.test's borrowing cases (milestone 6) and
   all of c-byte-borrowing.test.
4. **Architecture-specific tests**: abi-bytes' and abi-mutable-bytes'
   `linuxX86_64` ones (the x86-64 transport and its bridges' machine code):
   stay, they are x86-64's.
5. **GC-stress tests**: nv-gc-stress, ne-gc-stress, la-gc-stress,
   lu-gc-stress, bl-gc-stress, cb-failure-gc-stress,
   abi-mutable-bytes-gc-stress-pure-values -- `nativeLinux` only because GC
   stress used to be validated on Linux alone; milestone 3 validated the
   collector's roots (suspended stacks included) under GC stress on macOS
   (MACOS-AARCH64-MILESTONE-3.md, section 14).
6. **Mutation campaigns** and 7. **fuzzing campaigns**: the tools, section 10.
8. **Linux syscall tests with no Darwin counterpart yet**: abi-bytes' 23 and
   abi-mutable-bytes' 12 remaining `nativeLinux` tests write and read through
   `std::linux::write`/`std::linux::read` (the examples, short reads, EOF, the raw
   negative result, strace evidence, the allocation tables of programs that
   import `linux`). They are Linux's raw syscall layer and stay; milestone 8's
   darwin-io.test is their macOS counterpart at the libSystem layer.

The brief's six tests (nv-allocations, nv-gc-stress, ne-allocations,
ne-gc-stress, la-native-allocations, la-gc-stress), inspected one by one:
each compiles a program that calls no OS facility and either counts its
heap allocations (native::allocationReport, in-process) or runs it under
`BOTLISH_NATIVE_GC_STRESS=1`. Neither is Linux-specific: the allocation
counters are the runtime's own, and stress collections need only the native
runtime's stack maps, which macOS has had since milestone 3.
`nativeCoroutines` is the capability that names exactly that runtime
(tests/helpers.tcl: Linux x86-64 and AArch64, macOS AArch64). The same holds
for layout-unions' and binary-layout's two each, and for four of
abi-mutable-bytes' tests that build MutableBytes values without a syscall --
those now compile on the file's pure prelude (`$::pure`, no `linux` import)
rather than the Linux one, which their programs never used; the expected
allocation counts are exactly the ones they had.

## 2. Pointer and byte-storage facts

The exposure path, read for this milestone (no change was needed):

* **Payload address, not an object word.** `rt_bytes_addr` and
  `rt_mbytes_addr` (runtime/ops.rs) return `BytesObj::payload_address(v)` --
  the object's address plus `BYTES_PAYLOAD_OFFSET` (16) -- as a small Int;
  `bytesobj.rs` allocates every storage with `Layout::from_size_align(16 +
  n, BYTES_ALIGN = 16)`, so the payload is 16-byte aligned. The foreign call
  (codegen/clif.rs) untags the small Int into the machine pointer.
* **Every bit survives.** The small-Int range is ±2^62; an address outside
  it is a RANGE failure, never truncated or masked. Linux x86-64 user space
  is 47 bits, Linux AArch64's 48 (52 with large virtual addresses), macOS
  AArch64's 47 -- all inside. The comment that named only Linux x86-64's 47
  bits now states this for every host (runtime/ops.rs, commit ec7cae8).
* **No ASLR assumption.** No test requires an address; bb-read-address
  compares the address C receives with the one the runtime's raw address
  bridge reports for the same storage (all 64 bits), and checks alignment.
  On macOS the heap is above 4 GiB (Apple's arm64 processes have a 4 GiB
  zero page), so bb-read-address-above-4gib asserts there that both a heap
  storage's and a constant storage's address exceed 2^32 and still equal the
  bridge's -- a transport keeping only the low 32 bits fails it (mutant
  `exposure-address-truncated`). Above 4 GiB is checked as a fact of Apple's
  layout, never taken as proof of correctness.
* **Liveness.** Native lowering (native/lower.tcl's `BorrowCall`) evaluates
  every argument, then makes the exposures (each write exposure's private
  copy, then every address), calls, then `op keepalive` of every exposed
  storage: a GC root through every safepoint up to and including the call.
  The collector never moves objects, so nothing is pinned. Verified on macOS
  under a collection at every allocation site (bb-gc-stress, section 7).
* **No escape.** An exposure exists only as an operand of the one call;
  admission refuses every parameter that could keep it (section 6).

## 3. Files changed

| file | change |
|---|---|
| tests/c-byte-borrowing.test | new: 20 tests (sections 4-8) |
| tests/cffi/fixture.c | `bcf_checksum` (plain sum in the low 32 bits, position-weighted sum in the high 32: order- and value-sensitive), `bcf_address_of`, `bcf_fill_range`, `bcf_split` (a pattern and its complement into two outputs), `bcf_fill_upto` (writes up to a limit, then reports -1) |
| tests/c-pointer-borrowing.test, native-view.test, native-edit.test, layout-arrays.test, layout-unions.test, binary-layout.test, abi-mutable-bytes.test | `nativeLinux` replaced by the capability each test needs (section 1) |
| audit/c-pointer-borrowing/tools/mutate.tcl, mutants.txt | portable timeout, per-host mutants, statuses, eight mutants (section 10) |
| tests/platform/tier.tcl, .github/workflows/macos-arm64.yml | items `c-borrow-fuzz`, `c-borrow-mutants[=NAMES]`, `c-borrow-bench` |
| tests/platform/native-status.tcl | probe `c-byte-borrow` (libSystem's `memcmp` and `memset` on exposures), expected on Linux and macOS, NATIVE LINK on Windows |
| audit/golden/migration/census/c-byte-borrowing.tsv, tcl-names.txt, tests/golden/manifest.tsv | the new file's 20 rows (KEEP-NOT-EXPRESSIBLE: a golden suite cannot build or link a C library) |
| native/src/runtime/ops.rs | a comment (section 2) |

No compiler, runtime or library code changed.

## 4. Read borrowing through real C

| test | what it shows |
|---|---|
| bb-read-sizes | a Bytes and a MutableBytes at a `read noescape` parameter, sizes 0, 1, 15, 16, 17, 255, 992, 1008, 1024, 4096, 16368, 16384, 65536, 131072 and 1048576 (the allocator's size classes and page boundaries, 16 KiB pages on macOS): C's checksum equals the oracle's for every one |
| bb-read-zero-and-high-bytes | all-zero storage, all-0xff, and 0x00/0x7f/0x80/0xff: C reads unsigned bytes exactly |
| bb-read-address | the address C receives is the storage's payload address (the bridge's), 16-aligned; every read exposure of one owner -- again, through a List or a struct holding it, a MutableBytes as it is -- is that storage, no copy; a write exposure is another storage (the detach), the one the write-back value holds |
| bb-read-address-above-4gib | (macOS) the heap and constant storages' addresses are above 4 GiB and still exactly the bridge's |
| bb-read-repeated-nested | one owner exposed a thousand times while a List, a struct and a closure hold it, and at every level of a hundred nested calls each exposing its own owner and its caller's |

A read exposure makes no copy on macOS either: the address equality above is
the structural evidence, and the benchmark (section 13) shows the read cost
flat in the size.

## 5. Write borrowing and the detach

| test | what it shows |
|---|---|
| bb-write-shapes | a `write noescape` parameter writes a private copy, returned as the call's value: an empty buffer, a full overwrite, a prefix, a suffix and a middle range, every unwritten byte kept; the caller's value and a copy of it never change |
| bb-write-large | 1 MiB written, read back by C through a read exposure of the write-back value; the caller's zeroed value still all zeros |
| bb-write-two-outputs | two write exposures are two private copies, each its own field of the write-back struct; the same owner given twice is still two copies, neither seeing the other's writes |
| bb-read-write-one-owner | one owner exposed for reading and for writing in one call: C reads the owner and writes a copy, so reversing a buffer onto itself gives its reverse in the write-back and leaves the owner |
| bb-write-chain | each write-back value exposed to the next call, which writes its own copy: the last holds every write, each earlier one only its own and its predecessors' |
| bb-write-retained-references | managed values held across a write call (the owner in a List and a struct, a String, other storage) are intact after it |
| bb-write-failure-sentinel | C writes part of its output, then returns -1: the write-back holds exactly the bytes C wrote (the contract publishes the private copy whatever C's result says; no rollback), the caller's value is unchanged; a Botlish wrapper turning the sentinel into a declared error leaves its handler the untouched original |

The write-back value is exactly C-POINTER-BORROWING.md's `{result: R, NAME:
MutableBytes}`; nothing mutates in place.

## 6. Lifetime and refusals

bb-refusals compiles fourteen programs for each of linux-x86_64,
linux-aarch64 and macos-aarch64 and requires the same diagnostic kind and
message for all three targets: a parameter that may retain the pointer
(`captures`, or no escape fact: unknown), one whose access nobody declared,
an immutable Bytes for writing, a pointee that is not byte-sized (Int, a
pointer), a trailing argument of a variadic call (no contract), a pointer
result of unknown provenance beside an exposure (FOREIGN-BORROW); an
ordinary `Ptr` parameter, a returned `Ptr`, a struct field, a List element,
a closure's result and `clone` (TYPE). None compiles into an unchecked
pointer. bb-strict0-replay: under `-strict 0` both native backends evaluate
the arguments and raise the refusal instead of calling C (the C call before
it ran, the one after it never does). c-pointer-borrowing.test's refusal
tests run on every host as before.

## 7. GC, coroutines and error paths

* **bb-gc-stress**: under `BOTLISH_NATIVE_GC_STRESS=1` (a collection attempt
  at every allocation site), read and write exposures through real C stay
  exact on both backends and in a standalone executable -- owners allocated
  before the exposures and inline among the call's arguments (collections
  during argument preparation), several values live across each call,
  garbage after.
* **bb-coroutines**: exposures inside coroutine bodies -- before the first
  yield, after a resume, from owners held across two suspensions -- with
  three coroutines suspended at once holding byte storage, resumed out of
  order, under GC stress, on both backends and in an executable.
* **bb-write-failure-sentinel** and c-pointer-borrowing's
  `cb-failure-gc-stress`: borrowing followed by a declared error and by
  ordinary completion.
* The lowering order was read, not assumed (section 2): exposures are made
  after every argument, so an argument's allocation or yield never runs
  while an exposure is open (`cb-exposure-after-arguments`, now on macOS).

Whole files under GC stress on macOS: Tier C of macOS run
[39585147611](https://github.com/mwagner-webdev/botlish/actions/runs/39585147611)
(at b08ac4c, before the last test fixes) ran fourteen files with
`BOTLISH_NATIVE_GC_STRESS=1` for the whole process, on interp and compile --
darwin-io, c-byte-borrowing, c-pointer-borrowing, workload-2048,
context-traits, portable-io, target-model, c-ffi, native-view, native-edit,
layout-arrays, layout-unions, binary-layout and abi-mutable-bytes -- and the
borrowing fuzzer's seeds 1, 2 and 9 (no disagreement). Each pass: 626
tests, 584 passed, 40 skipped (2 boringssl, 16 linuxX86_64, 21 nativeLinux,
1 tclLibrary) and 2 failed, both test defects fixed since and neither a
matter of the collector: bb-guard-malloc's control (section 8) and
di-stderr-failure, which compared the streams' undecoded bytes with text
(7bdd5e2).

## 8. Real-library acceptance

**libSystem.** bb-system-library calls the system C library's own `memcmp`,
`memcpy`, `memmove` and `memset` through wrappers whose counts come from the
storage (`std::abi::bytes::length` as a `size_t`): comparisons of unsigned bytes,
a shared prefix and the empty buffer; a 1 MiB comparison and copy; a fill;
a move whose source and destination are one owner (a read exposure of it and
a write exposure of its copy). Every value is the oracle's;
bb-system-library-gc-stress repeats it under GC stress on both backends and
in an executable. bb-system-symbols reads the executable's symbol table
(`nm -m` on macOS, `nm -D` on Linux): all four are undefined there and bound
to the system library, so the calls are libSystem's own code.

**Guard Malloc** (macOS): bb-guard-malloc runs an executable of read and
write exposures of 16-byte storages (a 16-byte header plus 16 bytes is a
32-byte block) -- the fixture's read and write, libSystem's `memcpy` and
`memcmp` -- under `/usr/lib/libgmalloc.dylib`, which puts every block on
pages of its own, its end against the page after it: it runs to the oracle's
value, so no C call reads or writes past those exposed storages. Three
positive controls, one per kind of exposure -- the fixture's read one byte
too long, its write one byte too long into the detach copy, and `memcpy` one
byte too long -- must each be killed by a signal under libgmalloc, and the
read must not be without it; a C probe (`guardMallocWorks`) shows the
detector faults on this host before the test is enabled.

The control took three macOS rounds to be real. First, libgmalloc's banner
on standard error made `exec` report every guarded run as failed -- the good
executable's correct value included -- so both the probe's and the test's
fault checks passed without a fault; both now read the exit status and
require `CHILDKILLED`. Second, with that check in place, the bad executable
"did not fault": it had never been built, because the mutated count
`len(d) + 1` is not provably an `std::ffi::c::ULong` (a compile-time TYPE error
the old `catch` had counted as the fault). Third, with a literal count, the
one-byte over-read of the 4080-byte storages the test then used (4096-byte
blocks, made by `bytesfromlist` at run time: heap allocations, not static
storages) ran to a value under libgmalloc. A branch-only diagnostic on the
runners (macOS run
[39616115189](https://github.com/mwagner-webdev/botlish/actions/runs/39616115189),
at 905cb6e, never on main) separated the detector from the borrowing:

| under libgmalloc | one byte past the end |
|---|---|
| a C `malloc` block of 16, 32, 4096 or 4112 bytes | SIGSEGV |
| a 16-byte Botlish storage (a 32-byte block) | SIGSEGV |
| a 4080-byte Botlish storage (a 4096-byte block) | no fault: the byte read as 0 |
| the same storage read 40 000 bytes far | SIGSEGV |

libgmalloc was loaded into the executable (its banner; `DYLD_PRINT_LIBRARIES`
names it) and placed both storages' blocks to end exactly on a 16 KiB page
boundary (their payload addresses were 16368 and 12304 modulo 16384), so
each exposure was the block libgmalloc made; but the page after the 4096-byte
block was mapped. Why it was was not established. What it means is that the
4080-byte good run had never shown what it claimed; the test now claims what
its controls show, for the storages it exposes.

**BoringSSL.** Not run on macOS. The SHA-256 acceptance needs the
package-owned static BoringSSL (tests/cffi/boringssl.tcl) and links
`extern c library "stdc++"` (examples/ffi/sha256/boringssl.bot), which is
GNU libstdc++; macOS's C++ runtime is libc++ (`-lc++`), and the language has
no per-platform `extern c library` (a language question: port audit,
section 10, roadmap entry 10). Building BoringSSL in the macOS workflow and
choosing the C++ runtime per target is infrastructure this milestone does
not add; its tests stay skipped there by the `boringssl` constraint.
libSystem is the real-library acceptance.

## 9. The six generic byte tests

| test | dependency found | now |
|---|---|---|
| nv-allocations | native::allocationReport of in-process programs reading views of the test process's own fixture memory (`ffi_fixture::memory`, the runtime's, no C) | `nativeBuilt nativeCoroutines` |
| nv-gc-stress | stress collections over the same programs | same |
| ne-allocations | as nv-allocations, for edits | same |
| ne-gc-stress | as nv-gc-stress, for edits | same |
| la-native-allocations | allocation counts of array element reads and stores | same |
| la-gc-stress | stress collections over live arrays | same |

plus lu-native-allocations/lu-gc-stress, bl-allocations/bl-gc-stress, the four
abi-mutable-bytes pure-value tests and c-pointer-borrowing's four (section
1). No allocation expectation changed: the counters are the runtime's own
and count the same objects on every host.

## 10. Tools on macOS

**audit/c-pointer-borrowing/tools/mutate.tcl**

* **No `timeout(1)`.** Every command runs under the script's own timeout
  (a pipe read through `fileevent` while an `after` timer runs; on expiry
  the pipe's processes are killed): macOS has no GNU coreutils.
* **Per-host mutants.** A `%% TARGET ...` line after a mutant's header
  restricts it to hosts that compile the mutated code differently
  (`apple-exposure-tagged`: Apple's C convention only); elsewhere it is
  SKIPPED, never counted as killed.
* **Statuses.** KILLED (a detector failed), SURVIVED, SKIPPED, NOT-APPLIED
  (the text no longer occurs exactly once) and NOT-BUILT (a native mutant
  that does not compile); the last two fail the run and are never counted
  as killed. Each mutant is applied in a private copy of the tree; only a
  native mutant rebuilds (the copy's native directory, never the
  checkout's).
* **Detectors**: c-pointer-borrowing.test (the Botlish fixture),
  c-byte-borrowing.test (real C; skipped where no C call links) and the
  fuzzer, each with a private `-tmpdir`.

**New mutants** (the brief's list, those it did not have yet):

| mutant | the bug | killed on Linux by |
|---|---|---|
| `exposure-is-object-word` | a read exposure hands C the storage object's address (its header), not the payload's | 19 tests, fuzzer |
| `exposure-address-truncated` | C receives only the low 32 bits of the address | 17 tests (on Linux the heap is above 4 GiB too) |
| `apple-exposure-tagged` (`%% macos-aarch64`) | under Apple's C convention the address is passed as its tagged small-Int word | SKIPPED on Linux; macOS: section 11 |
| `keepalive-first-only` | a call with several exposures keeps only the first storage alive | `cb-exposure-after-arguments-nir` |
| `detach-copy-short` | the write exposure's private copy is one byte short | 23 tests, fuzzer |
| `read-exposure-copied` | a MutableBytes read exposure is copied first (a size-linear copy no read needs) | `bb-read-address`, `cb-allocations`, `cb-nir-read-mutable` (structural: an address and an allocation count, not wall-clock time) |
| `exposure-wrong-owner` | every exposure of a call is its first exposed argument's storage | 11 tests |
| `variadic-byte-argument-admitted` | byte storage accepted as a variadic call's trailing argument | `bb-refusals` |

The brief's other mutants were already there: omitting `keepalive`
(`owner-liveness-dropped`), removing the detach
(`mutable-exclusivity-dropped`), returning the original
(`copy-back-omitted`), dropping the write-back field
(`write-back-without-writes`), retained-pointer borrowing
(`capturing-parameter-accepts-borrow`, `unknown-implies-noescape`), writing
immutable Bytes (`immutable-bytes-satisfy-write`).

**The fuzzer** (audit/c-pointer-borrowing/tools/fuzz.tcl) needed no change:
it uses the Botlish fixture, which runs on every native host. No
macOS-specific seed was added: no platform property needs one (the address
facts are the tests', which run on every host).

## 11. Mutation results

**On Linux x86-64** (`tclsh9.0 audit/c-pointer-borrowing/tools/mutate.tcl`,
on the tree merged with main, in parallel `-only` groups): 30 mutants, **29
killed, 1 skipped (`apple-exposure-tagged`, Apple's convention only), 0
survived**; every mutant's text still applies. The eight new ones:

| mutant | killed by |
|---|---|
| `exposure-is-object-word` | 19 tests (bb-read-*, bb-system-library, bb-gc-stress, bb-coroutines, ...), the fuzzer |
| `exposure-address-truncated` | 17 tests, among them bb-read-address and bb-read-address-above-4gib |
| `keepalive-first-only` | `cb-exposure-after-arguments-nir` (structural: the call's keepalives) |
| `detach-copy-short` | 23 tests, the fuzzer |
| `read-exposure-copied` | `bb-read-address`, `cb-allocations`, `cb-nir-read-mutable` (structural: an address and an allocation count, not a timing) |
| `exposure-wrong-owner` | 11 tests (bb-write-two-outputs, bb-read-write-one-owner, bb-system-library, ...) |
| `variadic-byte-argument-admitted` | `bb-refusals` |
| `apple-exposure-tagged` | SKIPPED on Linux; macOS below |

`keepalive-first-only` is caught by the NIR test only, and that is the
right detector: a missing keepalive is observable only if a collection runs
while C holds the address, and these synchronous calls neither allocate nor
call back. c-byte-borrowing.test also joined the kills of the older mutants
that change what C sees (`mutable-exclusivity-dropped`, `copy-back-omitted`,
`read-write-roles-swapped`, `write-back-without-writes`,
`capturing-parameter-accepts-borrow`, `ptr-int-from-byte-storage`,
`unknown-access-admitted`, `strict0-not-replayed`, ...).

**On macOS arm64** (the tier item `c-borrow-mutants` with the eight new
mutants, the dispatch
[39603460215](https://github.com/mwagner-webdev/botlish/actions/runs/39603460215),
543.8 s): **8 mutants, 8 killed, 0 survived, 0 skipped** --
`apple-exposure-tagged` among them, the one Linux cannot run:

| mutant | killed by (failed tests; the fuzzer) |
|---|---|
| `apple-exposure-tagged` | 18 tests (bb-coroutines, bb-gc-stress, bb-read-address, bb-read-address-above-4gib, bb-read-repeated-nested, ...) |
| `exposure-is-object-word` | 20 tests (bb-read-address, bb-read-sizes, bb-read-zero-and-high-bytes, ...); the fuzzer, 18 disagreements in 15 programs |
| `exposure-address-truncated` | 18 tests (bb-read-address-above-4gib among them) |
| `keepalive-first-only` | `cb-exposure-after-arguments-nir` |
| `detach-copy-short` | 25 tests; the fuzzer, 20 disagreements in 15 programs |
| `read-exposure-copied` | `bb-read-address`, `cb-allocations`, `cb-nir-read-mutable` |
| `exposure-wrong-owner` | 12 tests (bb-read-write-one-owner, bb-system-library, bb-system-library-gc-stress, ...) |
| `variadic-byte-argument-admitted` | `bb-refusals` |

Every kill list also names bb-guard-malloc, which failed on that tree
unmutated (section 8): no kill rests on it, since every mutant fails at
least one other test.

## 12. Fuzzing results

`audit/c-pointer-borrowing/tools/fuzz.tcl -n 10` (ten programs of eight
cases each, every case predicted by the fuzzer's own model and run on all
four backends -- the fixture's natives have a Tcl side -- and, with
`-gc-stress 1`, on both native backends again under GC stress; a refused
case is compiled alone and must name the model's reason).

**On Linux x86-64**, on this milestone's tree:

| seed | cases | refused | disagreements |
|---|---:|---:|---:|
| 1 | 80 | 33 | 0 |
| 2 | 80 | 37 | 0 |
| 3 | 80 | 46 | 0 |
| 4, `-gc-stress 1` | 80 | 41 | 0 |

**On macOS arm64** (the tier item `c-borrow-fuzz`, the dispatch
[39603460215](https://github.com/mwagner-webdev/botlish/actions/runs/39603460215)):

| seed | cases | refused | disagreements |
|---|---:|---:|---:|
| 1 | 80 | 33 | 0 |
| 2 | 80 | 37 | 0 |
| 9, GC stress | 80 | 48 | 0 |

Seeds 1 and 2 are the Linux table's (the same 33 and 37 refusals, the
same programs), and both hosts run them without a disagreement. The
C FFI fuzzer (`c-ffi-fuzz`, which drives real C callees, variadic calls
among them, through Apple's convention) ran beside it: seeds 1, 2 and 9
(GC stress), 120 functions each (43, 32 and 33 variadic; 211, 107 and 143
trailing arguments), 0 disagreements.

## 13. Performance

`bench/c-pointer-borrowing.tcl` (tier item `c-borrow-bench` on macOS). On
Linux x86-64, on this milestone's tree (4-core container, 2026-10-21, best of
5 runs of 20 000 calls, the empty loop subtracted, ns per call):

| owner of S bytes | 0 | 64 | 4096 | 65536 |
|---|---:|---:|---:|---:|
| raw (a null `Ptr`: the operation alone) | 52.9 | 50.2 | 33.8 | 44.1 |
| read exposure of a Bytes | 38.0 | 31.0 | 62.6 | -31.3 |
| read exposure of a MutableBytes | 34.3 | 33.5 | 34.0 | 27.3 |
| write exposure, result discarded | 5.3 | 53.4 | 287.8 | 2867.7 |
| write exposure, result used | 161.5 | 374.6 | 588.4 | 3284.3 |
| `std::linux::read(-1, m)` | 422.6 | 327.1 | 655.2 | 3268.3 |

Allocations of one call at S = 64 are unchanged from C-POINTER-BORROWING.md
section 18: a read exposure allocates nothing, a write exposure one
MutableBytes storage (the detach), and two small structs when the
write-back value is used. Read stays flat in the size (the differences are
the method's noise, tens of ns either way, as the negative entry shows);
write grows by the detach's copy, about 0.04 ns per byte at 64 KiB.

**On macOS arm64** (the tier item `c-borrow-bench`, a GitHub `macos-15`
runner, the dispatch
[39603460215](https://github.com/mwagner-webdev/botlish/actions/runs/39603460215);
the same method; ns per call):

| owner of S bytes | 0 | 64 | 4096 | 65536 |
|---|---:|---:|---:|---:|
| raw (a null `Ptr`: the operation alone) | 14.3 | 13.9 | 12.4 | 14.3 |
| read exposure of a Bytes | 11.7 | 11.5 | 13.0 | 32.2 |
| read exposure of a MutableBytes | 12.0 | 13.4 | 12.4 | 24.8 |
| write exposure, result discarded | 6.4 | 34.1 | 181.2 | 1581.5 |
| write exposure, result used | 72.4 | 97.9 | 266.9 | 1642.2 |

Allocations of one call at S = 64, beside the program without it
(`{Bytes MutableBytes Struct List}`): raw, read and read m `0 0 0 1` (the
loop's own list, as without the call), write `0 1 0 0`, write+r `0 1 2 0` --
exactly Linux's: a read exposure allocates nothing, a write exposure the one
MutableBytes of its detach, and the two small structs of the write-back
value when it is used. The shape is Linux's too: write grows by the detach's copy
(about 0.024 ns per byte at 64 KiB), and read is flat up to 4 KiB. Its
64 KiB entries are 10-20 ns above the others, which no per-byte work
explains (the operation reads no byte, and the exposure reads none either);
Linux's same column moved by 30 ns either way.

## 14. macOS GitHub Actions runs

Every macOS fact in this report is from these runs of
`.github/workflows/macos-arm64.yml` on GitHub's `macos-15` arm64 runners
(the shared development Mac was not used). A run on the branch was
cancelled whenever a later push to the branch superseded it; its finished
jobs' results stand.

| run | commit | what it ran | result |
|---|---|---|---|
| [39574475382](https://github.com/mwagner-webdev/botlish/actions/runs/39574475382) | 6828d12 | the census baseline, before milestone 7 | the census of section 1 |
| [39577805370](https://github.com/mwagner-webdev/botlish/actions/runs/39577805370) | 3587425 | milestone 7; Tier C under GC stress | smoke passed; acceptance 2/2 failed on c-byte-borrowing.test alone (bb-guard-malloc's banner defect); cancelled by the next push |
| [39585147611](https://github.com/mwagner-webdev/botlish/actions/runs/39585147611) | b08ac4c | milestones 7 and 8; Tier C: fourteen files and the borrowing fuzzer under GC stress | smoke passed; Tier C: two test defects, bb-guard-malloc and di-stderr-failure, everything else passed under stress; cancelled by the next push |
| [39593142355](https://github.com/mwagner-webdev/botlish/actions/runs/39593142355) | 7bdd5e2 | the fixes of those defects | smoke and acceptance 1/2 passed (darwin-io.test 27 of 27); cancelled at 12:54 by the branch push of the merge |
| [39603310734](https://github.com/mwagner-webdev/botlish/actions/runs/39603310734) | d598dba (main) | the milestones merged into main | smoke and acceptance 1/2 passed, acceptance 2/2 failed on bb-guard-malloc alone (its 4080-byte control); workload-2048.test, context-traits.test passed |
| [39603460215](https://github.com/mwagner-webdev/botlish/actions/runs/39603460215) | d598dba (dispatch) | Tier C: the mutants, the benchmarks, the fuzzers | 19 of 19 Darwin IO and 8 of 8 borrowing mutants killed; both fuzzers no disagreement; c-borrow-bench; darwin-io-bench's part 2 failed (the bench's `env` clash); acceptance as on main |
| [39616115189](https://github.com/mwagner-webdev/botlish/actions/runs/39616115189) | 905cb6e (branch only) | the Guard Malloc diagnostic | its facts (section 8); the bench failed again (the interposer reached the linker); cancelled once Tier C had run |
| [39624150692](https://github.com/mwagner-webdev/botlish/actions/runs/39624150692) | b5d07f5 | the reworked bb-guard-malloc, the bench's fix | **every job passed**: smoke, both acceptance shards, and Tier C (c-byte-borrowing.test 20 of 20 on interp and compile, darwin-io-bench all three parts) |

## 15. Linux regressions

**Linux x86-64.** tests.yml on milestone 7's own commit (3587425,
dispatched on the branch), run
[39577813683](https://github.com/mwagner-webdev/botlish/actions/runs/39577813683): every job
passed (its native GC-stress job runs on pushes to main only). tests.yml on
main at d598dba, run
[39603310748](https://github.com/mwagner-webdev/botlish/actions/runs/39603310748): all thirteen
jobs passed: the Tcl suite on interp and on compile, cranelift and
cranelift-generic coverage, the four golden shards (every suite beside its
Tcl originals), the stub-linked executables, the warning gate, the
method-call kind filter's audit, the native Rust unit tests, and the whole
suite under GC stress.

**Linux AArch64.** tests-arm64.yml at 3587425, run
[39577817112](https://github.com/mwagner-webdev/botlish/actions/runs/39577817112): all ten
jobs passed, the whole suite under GC stress among them (1 h 37 min).
tests-arm64.yml on main at d598dba (milestones 7 and 8 merged), run
[39603310756](https://github.com/mwagner-webdev/botlish/actions/runs/39603310756): all ten jobs passed -- the Tcl suite on interp (8747
tests: 8637 passed, 110 skipped, 0 failed) and on compile (8632 passed, 115
skipped, 0 failed), cranelift and cranelift-generic coverage, the four
golden shards, the native Rust unit tests (also under GC stress) and the
whole suite under GC stress (1 h 49 min).

static-decisions at d598dba (the front end changed: core/cabi.tcl and
stdlib/), run [39603310752](https://github.com/mwagner-webdev/botlish/actions/runs/39603310752): the batched and the sequential scheduler
agree on every golden suite (no DISAGREE, no DOES NOT COMPILE;
`mutable-array.bot: batched 5/7 35.2s sequential 69/205 1229.9s`), as they
did on the branch at b08ac4c ([39585334356](https://github.com/mwagner-webdev/botlish/actions/runs/39585334356)). windows-x86_64.yml at
d598dba, run [39603310730](https://github.com/mwagner-webdev/botlish/actions/runs/39603310730): the smoke job and the four acceptance
shards passed (Tcl 9.0.1 from the workflow's cache).

## 16. Remaining limitations

* **abi-bytes' and abi-mutable-bytes' syscall tests stay Linux's** (35
  tests): they test `std::linux::write`/`std::linux::read` and their transports. The
  macOS counterparts at the libSystem layer are milestone 8's.
* **BoringSSL's SHA-256 acceptance is not run on macOS** (section 8): the
  package-owned build is not in the macOS workflow, and the binding names
  GNU libstdc++.
* **Guard Malloc is a sampling detector**: it catches an access past the end
  of a block whose size is a multiple of 16 only when the page after the
  block is unmapped, and on the runners it was not after a 4096-byte storage
  made after a 4080-element list (section 8). bb-guard-malloc therefore
  exposes only storages whose one-byte overruns its controls show faulting
  (16 bytes); for larger exposures the evidence of bounds is the tests'
  counts (each exposure's own length) and their content checks, not a
  detector.
* **The Botlish fixture is not C**: c-pointer-borrowing.test's fixture is the
  runtime's own Rust code. Only c-byte-borrowing.test and c-ffi.test count as
  evidence of Apple C calls.

## 17. What milestone 8 builds on

Darwin IO calls libSystem's `write(2)` with a `read noescape` buffer and
`read(2)` with a `write noescape` one: exactly the two exposures this
milestone accepted on macOS, through the same lowering, with the write-back
value as `read`'s result. The `__error()` pointer it reads errno through is
an ordinary C pointer result read through a native layout view (milestone 6
accepted pointer results; NATIVE-LAYOUT-VIEWS.md).
