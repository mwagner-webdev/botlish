# HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-MILESTONE-1.md

Can a Rust native library be built on macOS AArch64, localized into a
Mach-O static archive, packaged as a multi-target Botlish package and
linked into an independently compiled Botlish executable -- beside
Botlish's own Rust runtime -- without symbol collisions, duplicate Rust
runtimes, unresolved references or unintended exports? This milestone
answers that for a representative Rust fixture and checks the same
technique against the real `http` native unit. It is a feasibility and
correctness milestone, not the macOS HTTP port
(HTTP-MACOS-AND-SSE-ESTIMATE.md is the port's estimate).

Evidence is labelled throughout:

* **[inspection]** read from source or artifacts;
* **[executed]** run here, in this repository's Linux x86-64 container;
* **[CI]** observed in a named GitHub Actions run of this branch;
* **[inference]** reasoned from evidence, not run;
* **[unverified]** not established.

No Mac was used other than GitHub's `macos-15` arm64 runners. The work is
on the branch `claude/rust-macos-linking-feasibility-gk62wh`.

## Contents

1. Executive result and verdict
2. Starting revisions and environment
3. Relevant existing architecture
4. SQLite findings reused or independently reproduced
5. Native linkage and symbol-ownership model
6. Mach-O localization implementation
7. Weak-reference and callback findings
8. Package-manager findings and fixes
9. Fixture implementation and representativeness
10. Independent consumer acceptance
11. Linux/macOS parity
12. Negative tests and mutants
13. Reproducibility evidence
14. Actual HTTP native-unit feasibility
15. Rejected approaches and tradeoffs
16. Remaining gaps and risks
17. Changes made to the main repository
18. Implications for the next HTTP macOS milestone

## 1. Executive result and verdict

**Verdict: feasible, with the localization this milestone adds.** A Rust
native unit built on macOS AArch64, localized into a Mach-O static archive
by `tools/rust-unit.tcl`, packaged in one multi-target `.botpkg` with its
Linux build and installed by the package manager links into an
independently compiled Botlish executable beside the runtime's own Rust,
with both Botlish linkers, on both hosts [CI] (the clean-room consumer of
the packaged artifacts: Linux [CI]; macOS PENDING, section 10). The
executables hold one
global `rust_eh_personality` and allocator shim (the runtime's), the
unit's own as local symbols, no global symbol of the unit's standard
library, and nothing of it exported. The real http unit takes the same
path on macOS [CI]: it compiles with one portability change, localizes to
exactly its 20 C functions, and links and starts beside the runtime
wherever an event-loop provider is linked.

The findings that decide it:

1. **Localization is necessary, and on macOS nothing else warns.** An
   unlocalized unit on Linux either fails to link (duplicate definitions)
   or links with the runtime's allocations routed into the unit's
   allocator. On macOS Apple's ld never reports a duplicate: the same
   rustc gives a silently rebound allocator, another rustc a link that
   passes every check while one copy's personality routine serves both
   (section 5.2).
2. **Mach-O localization** is `ld -r -force_load` with an
   exported-symbols list and a platform load command, archived by
   `libtool -static -D`, checked by reading the result with nm (section 6).
   Its traps were in the tools, not the link: Apple's nm reads Rust's
   embedded bitcode and fails on a newer LLVM's (section 6.1); a private
   external is link-visible; `ld -r` writes no `LC_BUILD_VERSION` unless
   told (section 6.2).
3. **The integration point** `botlish_event_post2`: http's weak reference
   links on macOS only when a provider is linked (Apple's ld refuses an
   undefined weak import); a weak *definition* is the portable fallback,
   needing no linker flag (section 7). The ABI is kept.
4. **F-16 is fixed** (pm/binary.tcl reads Apple's BSD symbol index, every
   entry checked), and the package manager no longer takes a weak
   definition for a duplicate (section 8).
5. **Reproducible** [CI]: two independent runners per host build
   identical units, and the multi-target artifacts packed from each set
   are identical (section 13).

Section 16 lists what this does not establish.

## 2. Starting revisions and environment

| What | Value |
|---|---|
| Botlish base | `ae2cb861` (origin/main when the branch was cut; HTTP-MACOS-AND-SSE-ESTIMATE.md surveyed `400a7214`, an ancestor) |
| SQLite package repository | `mwagner-webdev/sqlite-botpkg` at `1848ad87` (2026-11-13 19:24 +0100), read only |
| Local host | Linux x86-64 container; rustc 1.97.0 (2d8144b78 2026-07-07) and 1.100.0 (0ef1bc386 2026-11-09); cc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0; GNU ld and objcopy 2.42; Tcl 9.0.1 |
| The unit's pinned toolchain | rustc 1.97.0, the pinned author image's (tools/package-build/Dockerfile) |
| CI runners | `ubuntu-24.04` (x86-64) and `macos-15` (arm64); the Botlish runtime there built by the runners' stable rustc, the unit by 1.97.0 |

**Main's CI when the branch was cut** [CI]. At `ae2cb861` the four test
workflows (tests, tests (linux arm64), tests (macos arm64), tests
(windows x86-64)) were in progress or pending. Their last completed runs,
at `ede621b1`, had failed on all four hosts; main's own record
(PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md, "(merge)") attributes those
failures to Rust 1.100.0's cargo layout, fixed at `ce54fead`, whose test
runs were superseded (cancelled). `ae2cb861`'s own test runs were
cancelled in turn when main moved to `14937461` (a merge keying the
native build caches by the Rust toolchain). At `14937461`, read
2026-11-13 22:00 UTC, the four test workflows were still queued (since
19:11 UTC); its `ci tools` run failed on a truncated API response
(`http.client.IncompleteRead` in tools/ci/history.py, run 43489783093), not
on a test. So main has no completed test run newer than `ede621b1`'s red
ones, and this branch's failures are compared with none: every failure
reported below was read and attributed one by one.

## 3. Relevant existing architecture

### 3.1 How a package's static archive reaches an executable [inspection]

A package declares its native unit in source: `extern c library "NAME"
static at "native/libNAME.a"` (packages/http/http.bot declares
`botlish_http` so). The package manager installs per-target files into a
target view (`.bot_modules/.targets/T/PKG/native/...`); the compiler
resolves the link plan from the source declarations
(`codegen::aot::resolve_link_plan`), checks each archive's format and
architecture (`check_static_archive`) and passes it to the platform
linker by its absolute path. Two linkers link an executable that calls C:

* **rustc** (the default): rustc links the startup crate, the runtime's
  rlibs and Rust's standard library, and receives the plan's archives as
  `-C link-arg=PATH` (`link_plan_args_for`). On Linux rustc 1.97's link
  goes through `cc` with rust-lld; on macOS through Apple clang and ld.
* **system** (the single executable's and Botlish.app's choice for a
  program that calls C): `cc` links the program object, then the plan's
  archives (on GNU ld inside one group), then the precompiled runtime
  archive `libbotlish_runtime.a`, then the system libraries
  (`system_link_args`). No Rust toolchain at link time.

Both mean two copies of Rust's standard library in one executable when
the package's unit is Rust: the runtime's and the unit's.

### 3.2 The http unit's localization on Linux [inspection]

tools/http-package.tcl builds `botlish_http` with cargo (link-only
BoringSSL, one codegen unit, remapped paths) and localizes it: `ld -r
--whole-archive` into one relocatable object, `objcopy --strip-debug
--keep-global-symbols=bh_*` with Rust's one COMDAT group
(`DW.ref.rust_eh_personality`) renamed `botlish_http.DW.ref...`
(HTTP-SHIPPING-CENSUS.md's B3), `ar rcsD`. Every step is GNU's; the
script refuses any host but Linux (`httppkg::Host`).

### 3.3 Dependency and responsibility map

| # | Party | Owns | Built by | Platform-specific parts |
|---|---|---|---|---|
| 1 | Botlish native runtime | its copy of std, the allocator shim (System allocator; no `#[global_allocator]`), `rust_eh_personality`, the GC, the callback transition | the consumer's compiler distribution, its rustc (CI: stable) | none for this question |
| 2 | Rust native unit | its own copy of std and its allocator shim, its own personality routine and unwind tables, its global allocator if it has one | the package author, pinned rustc (1.97.0) | archive and object format |
| 3 | Externally visible C symbols | the unit's C ABI (`bh_*`, `rl_*`), an interposable weak fallback if any | the unit | Mach-O's leading underscore |
| 4 | Internal Rust symbols | std/core/alloc (v0-mangled with a crate hash), the allocator shim `__rustc::__rust_alloc` (mangled, its hash toolchain-specific), `rust_eh_personality` (**unmangled**), ELF's `DW.ref.rust_eh_personality` COMDAT group, compiler-builtins (weak) | the unit | ELF COMDAT vs Mach-O (none) |
| 5 | Callbacks and notifications | `callback c fn` (synchronous, through the transition shim); `botlish_event_post2` from a foreign thread (the driver's) | Botlish / the driver's C adapter | weak references: ELF tolerates an undefined one, Mach-O (PENDING) |
| 6 | System libraries and frameworks | Linux: libc, libgcc_s (unwinding), libm, libstdc++ for BoringSSL; macOS: libSystem, libc++, libiconv | the platform | the C++ runtime's name; deployment target |
| 7 | Package metadata | `botlish.json` targets: bundled static libraries, their declared symbols, license; views; `static at` paths | the author (`native add`) | the archive index format (GNU `/` vs BSD `__.SYMDEF SORTED`) |
| 8 | Final executable link | archive order, which copy of a symbol wins, what the executable exports | the consumer's compiler | linker semantics (GNU ld, rust-lld, Apple ld) |

Portable: the cargo build and its flags, the C ABI, the Botlish binding,
the link plan, the package metadata. Platform-specific: the localization
commands, deterministic archiving, the archive index, symbol naming, the
C++ runtime, weak-reference semantics.

## 4. SQLite findings reused or independently reproduced

[inspection] of `sqlite-botpkg` at `1848ad87`
(SQLITE-BOTPKG-CAPABILITY-CENSUS.md, SQLITE-BOTPKG-LANGUAGE-FINDINGS.md,
.github/workflows/ci.yml, scripts/pack.sh, scripts/run_acceptance.sh,
native/build.sh) and of its public Actions page:

| Item | What SQLite shows | Status |
|---|---|---|
| macOS compiler from source in CI | `compiler-macos` builds Botlish.app from pinned `cdb751b` | executed in its run #1 (43470724971, success) [inspection of its Actions page] |
| Apple-clang C archives | `native-macos` builds `libbotsqlite3.a` | executed in run #1 [inspection] |
| Multi-target `.botpkg`, deterministic pack | `package` job, `scripts/pack.sh` packs twice and `cmp`s | implemented; **not completed in CI**: runs #2--#6 were cancelled by newer pushes, #7 was queued when read [inspection of its Actions page]; the census marks the pack's determinism [executed] locally on Linux |
| Independent consumer install on macOS | `macos-acceptance` | implemented, **never completed in CI** (same runs) |
| F-16 | `native add -symbol` reads Apple ar's `__.SYMDEF SORTED` as 0 names; observed on run #1's macOS archive inspected on Linux | **reproduced independently** here without a Mac, with llvm-ar's Darwin format and with byte-written archives (section 8), and fixed |

SQLite establishes nothing about two Rust runtimes in one executable,
Rust symbol localization in Mach-O or the http bridge: its native library
is C. Its `pack.sh` leaves macOS `-symbol` checks out because of F-16;
with the fix they are possible (section 8).

## 5. Native linkage and symbol-ownership model

### 5.1 What a raw Rust static library brings [executed]

The fixture's raw static library (`cargo build --release`, rustc 1.97.0)
defines **2,395 global symbols** (audit/rust-archive-link/results/
linux-x86_64-local-surfaces.txt): std, core, alloc and compiler-builtins,
among them the unmangled `rust_eh_personality` and the allocator shim
`_RNvCs9hJ03s5DiqP_7___rustc12___rust_alloc`. Since Rust 1.88 the shim is
mangled with the `__rustc` crate's hash, which differs between rustc
versions (1.100.0's is `Cs5WqGp7zLRnA`); `rust_eh_personality` is not.

### 5.2 Is localization necessary? The negative control [executed, CI]

The raw archive was linked in place of the localized one into both
consumer programs with both linkers, the unit built by the runtime's own
rustc and by another (audit/rust-archive-link/tools/experiments.tcl;
Linux locally, audit/rust-archive-link/results/
linux-x86_64-local-results.tsv, and in CI; macOS in CI, run 43516411953,
job `experiments (macos-aarch64)`; the runtime there is built by the
runner's rustc 1.100.0):

| Host | Unit's rustc vs runtime's | rustc linker | system linker |
|---|---|---|---|
| Linux x86-64 | the same | **link fails**: `rust-lld: error: duplicate symbol: __rustc::__rust_alloc` (and `__rust_dealloc`, `__rust_realloc`, `__rust_alloc_zeroed`) | **links and runs, wrongly**: the runtime's own allocations (40,047 in the consumer's Botlish work) go through the *unit's* counting allocator |
| Linux x86-64 | different | **link fails**: `duplicate symbol: rust_eh_personality` | **link fails**: GNU ld, multiple definition of `rust_eh_personality` |
| macOS arm64 | the same (1.100.0) | **links and runs, wrongly**: the unit's live-heap count drifts (-9,589 after 100 rounds where -1,389 is expected): its allocator calls are split between the two copies' allocator shims | **links and runs, wrongly**: the runtime's 40,047 allocations go through the unit's allocator, as on Linux |
| macOS arm64 | different (unit 1.97.0) | **links and passes every check** | **links and passes every check** |

Apple's ld reports no duplicate definition in any case: it loads archive
members lazily and takes the first definition it meets, so the second
copy's members that define the same names are never loaded. The last row
is the most instructive. Every check passes, yet the executable holds
**one** `rust_eh_personality` (`personality_global 1, personality_local
0`): the unit's standard library unwinds through the other rustc's
personality routine, and every other unmangled C-ABI symbol of std is
likewise taken from whichever copy came first. That it works is an
accident of compatible versions, and nothing in the build or the link
says so.

The collisions were not manufactured: the fixture defines nothing a real
unit would not (its counting allocator is the one botlish_http's test
unit has). The silent cases are the dangerous ones. The system linker
passes the program object, then the package archives, then the runtime
archive; the unit's std members are pulled first, and with one rustc
their symbol names are the runtime's own, so the runtime's references to
`__rust_alloc` resolve to the unit's shim, which calls the unit's
`#[global_allocator]`. Two Rust "runtimes" became one, chosen by archive
order. The consumer detects it only because its allocator counts.

With the localized archive every one of those combinations links and
passes, on both hosts, with one global `rust_eh_personality` and the
unit's own as a local symbol (sections 10 and 11). Localization is
necessary; on macOS it is the only thing standing between a Rust unit and
a silently merged runtime.

### 5.3 The ownership model the fixture enforces

* Everything the unit allocates it frees (its allocator; panics caught at
  every export, never unwinding into C or Botlish).
* Buffers it copies out are the caller's, lent for one call (`write
  noescape` exposures).
* One block it lends out (`rl_text_new`) is held by Botlish as an affine
  `std::ffi::c::Ptr` and given back (`rl_text_free`); a block given to
  libc's `free` instead is detected by the unit's live-byte count
  (mutant `block-freed-by-libc`, section 12), without a crash because the
  unit's allocator is `malloc` underneath.

## 6. Mach-O localization implementation

`tools/rust-unit.tcl` (new; tools/http-package.tcl now calls it for its
ELF step):

```
ld -r -arch arm64 -S -force_load RAW -o whole.o           # read the globals
ld -r -arch arm64 -S -force_load RAW -exported_symbols_list keep.txt -o unit.o
ZERO_AR_DATE=1 libtool -static -D -no_warning_for_no_symbols -o OUT unit.o
```

`keep.txt` lists the kept globals with their leading underscore. ld's
`-exported_symbols_list` makes every other global definition private
extern, and `ld -r` without `-keep_private_externs` turns private
externs into local symbols; `-S` leaves debug information out. Mach-O
has no COMDAT groups, so the ELF renaming step has no counterpart. The
tool computes nothing about binding or visibility itself: `rustunit::check`
reads the result with `nm -m` and requires the global definitions to be
exactly the kept ones.

### 6.1 Apple's nm and Rust's embedded bitcode [CI]

The first macOS runs failed before any link, in the tool's own reading of
symbols. Rust ships its standard library's objects with their LLVM
bitcode embedded (`__LLVM,__bitcode`, for LTO), and `ld -r` carries it
into the merged object. Xcode 16.4's `nm` (`LLVM APPLE_1_1700.0.13.5_0`)
reads an object's symbols *from that bitcode* when it has some, and cannot
read a newer LLVM's:

```
nm: error: .../librustlink.work/whole.o: Unknown attribute kind (102)
  (Producer: 'LLVM22.1.6-rust-1.97.0-stable' Reader: 'LLVM APPLE_1_1700.0.13.5_0')
```

(rustc 1.100.0's LLVM 23 likewise; runs 43506350396 and 43506350138, at
`f2e3dedf`). Worse, on the *raw* archive the same nm printed the other
members' symbols and exited non-zero, so a tool that tolerates a non-zero
exit after output -- as an earlier version of `rustunit::Nm` did, for
Apple's harmless "no symbols" warnings -- read a raw Rust library as
defining neither `rust_eh_personality` nor the allocator shim
(`ral-raw-surface`: `0 0 0`). Two changes:

* Every Mach-O read passes `--no-llvm-bc`, which makes nm read the Mach-O
  symbol table -- the table a link resolves against; a link that is no
  LTO link never reads the bitcode. An nm that refuses the option is asked
  without it.
* `rustunit::Nm` accepts a non-zero exit after output only when everything
  nm said is that some member has no symbols; anything else is an error,
  never a partial list.

Both are pinned on every host by stand-in nm commands
(`ral-nm-bitcode-reader-off`, `ral-nm-old-nm-fallback`,
`ral-nm-partial-refused`, `ral-nm-no-symbols-accepted`) and four mutants.
The localized archive still holds the concatenated bitcode section: inert
for Botlish's links, but a consumer that ran an LTO link over it, or any
tool that reads symbols through Apple's bitcode reader, would trip on it
(section 16).

### 6.2 What Apple's linker did [CI]

Run 43526167818 (`ca8e7b0b`), job `experiments (macos-aarch64)`, Xcode
16.4 (ld-1167.5), the unit by rustc 1.100.0 and by 1.97.0:

| Archive | Size | Global definitions | Undefined references |
|---|---:|---:|---:|
| raw (cargo's), rustc 1.100.0 | 19,011,152 | 2,345 | 441 |
| localized, weak fallback kept | 11,897,480 | 13: `rl_*` and `botlish_event_post2` | 199 |
| localized, http's weak reference | 11,897,440 | 12: `rl_*` | 200 (`botlish_event_post2` among them) |
| raw, rustc 1.97.0 | 17,750,432 | 2,202 | 407 |
| localized, rustc 1.97.0 | 11,011,040 | 13 | 194 |

* `ld -r -force_load RAW` took the archive the first time; the
  `-all_load` and extracted-members forms an earlier version tried after
  it were never needed (the first runs' "no symbols" was nm's bitcode
  failure, section 6.1) and were removed.
* The localized archive is libtool's: an `__.SYMDEF SORTED` index and one
  member, `librustlink.o`. About 9.8 MB of its 11.9 MB is the `__LLVM`
  segment, the standard library's bitcode concatenated by `ld -r`.
* Every program linked against it passes, with both linkers (section 11);
  the executables hold one global `rust_eh_personality` and the unit's as
  a local symbol.
* **A platform load command was missing** [CI]. Apple's ld -r writes no
  `LC_BUILD_VERSION` unless told one, and every final link warned:

  ```
  ld: warning: no platform load command found in
    '.../rustlink/native/librustlink.a[2](librustlink.o)', assuming: macOS
  ```

  Harmless for a macOS link, but an object that does not say which
  platform and deployment target it was built for is not a finished
  unit. `rustunit::localize` now passes `-platform_version macos MIN SDK`
  (MIN: `-macos`, else `MACOSX_DEPLOYMENT_TARGET`, else 11.0, rustc's for
  aarch64-apple-darwin; the SDK: `xcrun --show-sdk-version`) to both
  `ld -r` calls; `ral-localized-build-version` (macOS) requires
  `LC_BUILD_VERSION` platform macOS, minos 11.0, and the mutant
  `macho-no-platform` removes it. PENDING (CI): the run that shows it.

## 7. Weak-reference and callback findings

The event loop's integration point `botlish_event_post2` is called from a
thread of the unit (http: its resolver threads) and provided by the
driver's C adapter when the driver package is linked.

**http's weak reference** (packages/http/native/src/notify.c, `extern int
botlish_event_post2(...) __attribute__((weak))`, the null check before
the call) [executed, CI]:

| | Linux (GNU ld, rust-lld) | macOS (Apple ld) |
|---|---|---|
| provider linked | the post reaches the provider | the post reaches the provider |
| no provider | links; the reference is null; the unit reports -38 (`ral-weakref-without_provider-*`) | **link fails**: `Undefined symbols for architecture arm64: "_botlish_event_post2"` (both linkers, raw and localized; run 43516411953) |

A Mach-O weak reference is a weak *import*: the symbol may be missing at
run time from a dylib that exports it at link time, but a static link
must still find a definition. So http's integration ABI can stay as it is
on macOS only as long as every program linking the unit also links a
provider -- which is the case for any http program (the driver is its
dependency), but not for a program that links the unit without a driver,
and not for the fixture's "no provider" program.

**A portable fallback: a weak definition** [executed, CI]. The fixture's
default notification object (audit/rust-archive-link/unit/
notify-weakdef.c) *defines* `botlish_event_post2` weakly, returning -38;
the provider's strong definition overrides it. Kept global by the
localizer (`-keep {rl_* botlish_event_post2}`):

| | Linux | macOS |
|---|---|---|
| provider linked | the provider's definition wins (both linkers) | the provider's definition wins (both linkers) |
| no provider | the fallback answers -38 | the fallback answers -38 |
| fallback localized away (`-keep {rl_*}`) | **the provider is silently ignored**: -38 with the provider linked | the same |

The last row is why the localizer's keep list must name the weak
definition: localized, the fallback is a local symbol that the unit's own
call binds to at `ld -r` time, before the final link could offer the
provider (mutant `fallback-localized`). The weak definition needs no
consumer linker flag on either platform and keeps the integration ABI
(the same name, signature and meaning). Its cost: the package manager
must not take it for a duplicate of the provider's definition (section
8.2).

**Archive loading for a weak reference** [executed, CI]. The http probe
(section 14) declares the provider's archive without calling anything in
it. On Linux the provider's member is not loaded: the executable is byte
for byte the size of the one without a provider, and the weak reference
is null. On macOS Apple's ld loads the member for the weak reference
alone and the program links (run 43551304938). So on Mach-O a driver
package's archive satisfies http's weak reference merely by being in the
link; on ELF only the driver module's own calls bring its object in --
which they do in every real program.

**Callbacks** [executed, CI]. `rl_each` calls a Botlish `callback c fn`
synchronously, through the transition shim, from Rust code inside the
localized unit: the callback machinery is unaffected by localization (it
is the C ABI), and both programs check its result (`weight 44`) on both
hosts with both linkers.

## 8. Package-manager findings and fixes

### 8.1 F-16, reproduced and fixed [executed]

`pm::binary::Archive` recognized BSD index members (`__.SYMDEF`,
`__.SYMDEF SORTED`, `__.SYMDEF_64`) as `kind symbols` but never read
them, so an Apple-made archive's `index` was empty. Every declared
`-symbol` and every view's check of a macOS archive's declared symbols
therefore failed (or, with no declared symbols, verified nothing).
Reproduced on main's reader without a Mac by four tests
(`pn-index-bsd-forms`, `pn-index-bsd-symbols-checked`,
`pn-index-bsd-malformed`, `pn-index-llvm-darwin`), all four failing
against `ae2cb861`'s pm/binary.tcl and passing with the fix.

The fix (pm/binary.tcl, `BsdIndex`): the ranlib array is read in its
32-bit and 64-bit forms; every entry is checked -- the array a whole
number of pairs, the string table inside the member, the string offset
inside the table, the name terminated, the member offset the start of an
object member (never the index itself) -- and a malformed index is `{PM
BINARY}`, never fewer names. A name loses its leading underscore only
when the member it names is Mach-O (the GNU index of Mach-O members gets
the same rule); every other name is kept as written. The GNU index's
entries are now checked against member offsets too.

Tests: synthetic archives written byte by byte (no toolchain), llvm-ar's
Darwin output of clang Mach-O objects, and on macOS Apple's own `ar rcs`
and `libtool -static` compared with `nm` (`pn-index-apple`, PENDING in
CI). `native add -symbol` against the localized Rust archive, and its
refusal of a misspelled symbol, run on both hosts
(`ral-native-add-symbols`).

### 8.2 A weak definition was counted as a duplicate [executed]

The portable notification mechanism (section 7) is a weak definition in
the unit and a strong one in the driver. Both duplicate-symbol checks of
the package manager -- the pack-time audit (pm/author.tcl) and the
installation's native closure (pm/native.tcl) -- compared archive index
names, which do not say whether a definition is weak, and refused:

```
error: the native dependencies of the packages for linux-x86_64:
  the static libraries rustlink and rustlink_provider both define
  botlish_event_post2: linking both into one executable is a duplicate
  definition (PM NATIVE)
```

-- although the link takes the strong definition (both linkers, both
hosts: section 11). Note also that before F-16's fix a macOS archive's
index read as empty, so on macOS no duplicate was ever detected at all;
the fix would have made this false positive appear there too.

Fix: `pm::binary` records weak definitions from each member's own symbol
table -- ELF relocatable members' `.symtab` (`STB_WEAK`), Mach-O members'
`N_WEAK_DEF` -- and an archive's `weak` names (those every defining member
defines weakly); both checks skip them. Two strong definitions stay
refused. `pn-index-weak-elf` (cc and ar) and `pn-index-weak-macho`
(Apple's tools on macOS; clang and a versioned llvm-ar elsewhere) -- each
an archive of one weak definition, a mixed archive (a weak and a strong
definition of one name: not weak), and the installation check for
weak+strong and strong+strong -- and `ral-pack-weak-beside-strong` (the
audit) pin it.

### 8.3 A second underscore [inspection]

pm/author.tcl's audit stripped a leading underscore from Mach-O archive
index names itself (written when the index was always empty). With
pm::binary giving C names, that strip was a second one, over-lenient for
a C name that starts with an underscore; removed.

### 8.4 What is not verified on macOS [inspection]

The package manager reads bytes; a macOS archive's architecture, index,
weak definitions and member formats are verified on Linux as on macOS.
What remains "partially verified" off-host is system libraries
(dpkg/pkg-config metadata is Linux's); the fixture declares none.

## 9. Fixture implementation and representativeness

`audit/rust-archive-link/unit`, crate `botlish_rustlink`, std only (it
builds offline), built as botlish_http is: `crate-type = ["staticlib"]`,
`panic = "unwind"`, one codegen unit, `cargo --locked`, paths remapped.
Its C ABI (i64 handles in a generational slab, caller-lent buffers,
negative error codes, every export guarded) mirrors http's bridge:

| Characteristic | botlish_http | fixture |
|---|---|---|
| std, heap allocation | yes | `Vec`, `HashMap`, `String`, `format!` |
| a `#[global_allocator]` | test unit (counting) | counting, always (the observable of section 5.2) |
| unwinding caught at the C boundary | `bridge::ffi::guard` | `guard`: index-out-of-bounds and explicit panics, a panic hook recording the message |
| thread-locals, mutexes, `std::thread` | yes (resolver pool) | reentrancy flag, slab mutex, a notification thread |
| opaque state, explicit create/destroy | clients, exchanges (i64 handles) | stores (i64 handles, generations) |
| C object compiled into the unit | `notify.c` (cc crate) | the same `notify.c`, or its weak-definition variant (build.rs, no dependency) |
| foreign-thread notification | `botlish_event_post2` from resolver threads | the same, from a unit thread |
| Botlish callback | no | `rl_each` calls a `callback c fn` |
| link-only native dependency | BoringSSL | none (checked against the real unit in section 14) |
| a lent object | no | `rl_text_new`/`rl_text_free` |

The package (`audit/rust-archive-link/package/rustlink.bot`) is declared
as http.bot is (`static at "native/librustlink.a"`, private externs,
`write noescape` buffers, an owner resource with a cleanup); the provider
of `botlish_event_post2` is a package of its own
(`audit/rust-archive-link/provider`), as the event loop's driver is beside
http. The consumer (`audit/rust-archive-link/consumer`) is one source for
every target.

## 10. Independent consumer acceptance

`audit/rust-archive-link/cleanroom/consumer.sh` is the consumer: a fresh
project, the two artifacts added through the package manager (`add`,
`verify`, `native plan`: no `-L`, the archives found in the target view),
both programs compiled with `-warnings error` to native executables by
the packaged compiler's own linker choice, each run three times against
its expected value, and each executable inspected (format and
architecture, dynamic libraries, the shared Rust symbols, the export trie
on macOS). The CI jobs run it on a fresh runner that downloads only the
artifacts, the packaged compiler of the same commit and the consumer's
sources: no checkout, `~/.cargo` and `~/.rustup` moved away, `env -i` with
`PATH=/usr/bin:/bin` (macOS: `/usr/bin:/bin:/usr/sbin:/sbin`); the script
records that cargo, rustc and rustup are not on PATH.

**Linux x86-64** [CI] (run 43526167818, job `consumer, no checkout and no
Rust (linux-x86_64)`): the single-file compiler (runtime built by rustc
1.100.0) and the artifacts packed from the 1.97.0 units:

```
== add: rustlink 0.1.0 (sha256 a09f250934a6): installed
== add: rustlink_provider 0.1.0 (sha256 077bac1b97cc): installed
== native plan:   library rustlink: bundled static (instance rustlink)
== native plan:     an ar archive of 1 ELF x86-64 object; bundled file, sha256 a65bcc85ea7a
== native plan: link: ... no -L is needed for bundled libraries
PASS without_provider: toolchain rustc 1.97.0 (2d8144b78 2026-07-07)
== without_provider rust_eh_personality: 1 global, 1 local
== without_provider __rust_alloc: 1 global, 1 local
== without_provider: global symbols carrying the unit's crate hash: 0 (the runtime's: 5WqGp7zLRnA)
PASS with_provider: ...                   (the same facts)
CONSUMER OK
```

Dynamic libraries: libgcc_s, libm, libc only.

**macOS arm64** [CI]: PENDING (job `consumer, no checkout and no Rust
(macos-aarch64)`, Botlish.app of the same commit).

Locally [executed]: the same script with `PATH=/usr/bin:/bin`, a fresh
`HOME` and the checkout's compiler through a wrapper: `CONSUMER OK`.

## 11. Linux/macOS parity

| | Linux x86-64 | macOS arm64 |
|---|---|---|
| Unit build (cargo, pinned rustc 1.97.0) | same recipe | same recipe |
| Localization | `ld -r --whole-archive`, `objcopy --keep-global-symbols`, COMDAT renamed, `ar rcsD` | `ld -r -force_load -exported_symbols_list -platform_version`, `libtool -static -D` |
| Localized surface | the C ABI and the weak fallback (13) | the same 13 |
| Archive index the package manager reads | GNU `/` | `__.SYMDEF SORTED` (F-16, fixed) |
| `native add -symbol` of every declared C function | passes | passes |
| Fixture tests (`tests/rust-archive-link.test`) | all pass [executed, CI] | all pass [CI] |
| Localized unit, both programs, both linkers | pass | pass |
| Unlocalized, same rustc | rustc linker: link fails; system linker: silent rebinding (detected) | both linkers: silent (detected) |
| Unlocalized, other rustc | link fails | links and passes every check (one personality) |
| http's weak reference, no provider | null, -38 | link fails |
| weak fallback, provider linked | provider wins | provider wins |
| a weak reference pulls an archive member | no | yes |
| Real http unit: compiles | production code | one change (net.rs) |
| Real http unit: probe with provider | pass | pass |
| Reproducible build (two runners) | identical | identical |
| Clean consumer, no Rust, no checkout | `CONSUMER OK` [CI] | PENDING |
| Mutants of this host | all killed | all killed |

Differences that remain are the platforms' own: the localization
commands, the index format, weak-import semantics, Apple's ld's lack of
duplicate diagnostics, the C++ runtime's name. Nothing in the package,
the Botlish binding or the consumer's source differs by host.

## 12. Negative tests and mutants

**Negative tests** (each expects a failure, and says which):

| Test | What must fail, and how |
|---|---|
| `ral-raw-*-{rustc,system}` (4 per host) | the raw archive linked into each program: the link fails, or a check of the program fails -- never a pass |
| `ral-check-refuses-raw` | `rustunit::check` on the raw archive: "global definitions differ ... N more" |
| `ral-require-missing-export` | localizing with a required export the unit lacks: "does not define rl_absent" |
| `ral-kept-glob-misses` | a keep list missing an export: the consumer's link fails on it |
| `ral-native-add-symbols` | `native add -symbol` with a misspelled symbol: refused |
| `ral-native-add-wrong-target` | the host's archive declared for the other OS's target: refused, naming the members' format |
| `ral-weakdef-localized-away-*` | the fallback localized away: the program with the provider gets -38 |
| `ral-weakref-without_provider-*` | Mach-O: the link fails on the undefined weak import (ELF: null, -38) |
| `ral-nm-partial-refused` | an nm that fails after printing for any other reason than an empty member: an error |
| `pn-index-bsd-malformed` | three corrupt BSD indexes (pairs, string table, member offset): `{PM BINARY}` |
| `pn-index-bsd-symbols-checked` | `-symbol` naming a symbol the Apple index lacks: refused |
| `pn-index-weak-elf`, `pn-index-weak-macho-install` | two strong definitions in two packages: refused at installation |

**Mutants** (audit/rust-archive-link/tools/mutants.txt, 25; each must be
killed by a test its `!!` line names, the test that states the rule, run
by `mutate.tcl` on a private copy of the tree):

| Mutant | Breaks | Killed by | Linux [executed] | macOS [CI] |
|---|---|---|---|---|
| `elf-unlocalized` | objcopy without `--keep-global-symbols` | `ral-localized-*` | killed | not applicable |
| `elf-comdat-kept` | Rust's COMDAT group not renamed (B3) | `ral-localized-comdat` | killed | not applicable |
| `macho-unlocalized` | `ld -r` without the exported-symbols list | `ral-localized-*` | not applicable | killed (43516411953) |
| `keep-everything` | every global kept | `ral-localized-*` | killed | killed (43516411953) |
| `require-ignored` | a missing required export accepted | `ral-require-missing-export` | killed | killed (43516411953) |
| `check-lenient` | the surface check accepts anything | `ral-check-refuses-raw` | killed | killed (43516411953) |
| `fallback-localized` | the weak fallback localized | `ral-localized-surface`, `-with_provider-*` | killed | killed (43516411953) |
| `macho-bitcode-reader` | Mach-O read without `--no-llvm-bc` | `ral-nm-bitcode-reader-off` (stand-in); on macOS also `ral-raw-surface`, `ral-localized-surface` | killed | killed (43516411953) |
| `macho-private-extern-local` | private externals not counted | `ral-macho-private-extern` (stand-in); on macOS `ral-raw-surface` | killed | PENDING |
| `nm-no-fallback` | an nm without `--no-llvm-bc` is an error | `ral-nm-old-nm-fallback` | killed | killed (43516411953) |
| `nm-partial-accepted` | any failure after output accepted | `ral-nm-partial-refused` | killed | killed (43516411953) |
| `nm-no-symbols-refused` | Apple's empty-member warning refused | `ral-nm-no-symbols-accepted` | killed | killed (43516411953) |
| `bsd-index-ignored` | F-16 again | `pn-index-bsd-*`, `pn-index-apple`, `ral-native-add-symbols` | killed | killed (43516411953) |
| `underscore-kept` | Mach-O names keep `_` | the same | killed | killed (43516411953) |
| `underscore-always` | every name loses `_` | `pn-index-bsd-forms` | killed | killed (43516411953) |
| `offset-unchecked`, `pairs-unchecked`, `strtab-unchecked` | a malformed index read as fewer names | `pn-index-bsd-malformed` | killed | killed (43516411953) |
| `block-freed-by-libc` | the lent block given to libc's `free` | `ral-localized-*` (the unit's live heap) | killed | killed (43516411953) |
| `weak-elf-unread` | ELF weak definitions not read | `pn-index-weak-elf` | killed | not applicable |
| `weak-macho-unread` | `N_WEAK_DEF` not read | `pn-index-weak-macho` | killed (llvm-ar) | killed (43516411953) |
| `weak-any-member` | weak when any member is | `pn-index-weak-elf`, `pn-index-weak-macho` | killed | killed (43516411953) |
| `install-weak-counted` | the installation counts weak as duplicate | `pn-index-weak-elf`, `pn-index-weak-macho-install` | killed | PENDING (survived in 43516411953, before the macOS installation test existed) |
| `install-all-weak` | the installation exempts everything | the same, `pn-native-conflicts` | killed | PENDING (as above) |
| `audit-weak-counted` | the pack audit counts weak as duplicate | `ral-pack-weak-beside-strong` | killed | killed (43516411953) |

The first macOS mutant run is the reason two tests exist: three mutants
"survived" there only because the one test naming them was ELF-only and
skipped, which the harness rightly reports as a survivor.

## 13. Reproducibility evidence

Three claims, kept apart. The release recipe is
`audit/rust-archive-link/tools/release-unit.tcl` (rustc 1.97.0 pinned,
`cargo --locked`, one codegen unit, paths remapped, a fixed target
directory emptied first, `ar rcsD` on Linux, `ZERO_AR_DATE=1 libtool -static
-D` on macOS); the packing is `audit/rust-archive-link/tools/pack.sh`.

**A. Deterministic pack** [executed, CI]. The same native files packed
twice give byte-identical artifacts: pack.sh `cmp`s both packs of each
package, locally and in the `package` job.

**B. Reproducible native build** [executed, CI]. The release recipe run on
two different runners per host, each from nothing (run 43526167818,
`ca8e7b0b`, jobs `release unit (..., build a|b)`):

| Host | Runners (image) | raw archive | localized unit | provider |
|---|---|---|---|---|
| linux-x86_64 | `runnervm8axu0`, `ip-10-0-131-132` (ubuntu24 20261111.370.1 and .127.1) | `225f2061...4f1d` both | `a65bcc85...e6af` both | `a5dcfbd0...5324` both |
| macos-aarch64 | two hosts, `sat12-...` and `iad20-...` (macos15 20261104.0514.1; Xcode 16.4, SDK 15.5, ld-1167.5) | `6357502b...f0c9` both | `36890ca6...7c20` both | `dfd01591...47ba` both |

The Linux unit is also byte for byte the one this repository's container
builds locally (`a65bcc85...e6af`). What the claim does not cover: another
Xcode, SDK or macOS image, another GNU binutils, another rustc (the unit
depends on the toolchain by design: its symbols carry its standard
library's crate hash).

**C. Reproducible complete package** [CI]. Each runner pair's set of
native files packed into the two multi-target artifacts (Linux x86-64 and
macOS arm64 in one artifact each) gives the same artifacts from build a as
from build b: `rustlink-0.1.0.botpkg` `a09f2509...5917`,
`rustlink_provider-0.1.0.botpkg` `077bac1b...6dc8` (job `package`).

PENDING (CI): the same three claims at the final commit, whose macOS unit
differs (its `LC_BUILD_VERSION`, section 6.2).

## 14. Actual HTTP native-unit feasibility

`audit/rust-archive-link/tools/http-unit.tcl` builds the real
`botlish_http` unit, localizes it with `tools/rust-unit.tcl` and links it
into a Botlish probe beside the runtime: open the bridge, read the
BoringSSL provider's API version, make a client trusting the system
bundle (a BoringSSL `SSL_CTX` with its store loaded), read the 21
counters, release, close. The probe links three ways per linker: no
provider of `botlish_event_post2`; the fixture's C provider declared and
never called; and that provider called, as a driver's own calls into its
C adapter pull it in a real program. No event loop driver, no network: a
link and start-up feasibility check, not the port.

What each fact rests on:

| Fact | Linux x86-64 | macOS arm64 |
|---|---|---|
| Source | the **existing** http code, its production path (tools/http-package.tcl), unchanged | a **modified copy** of packages/http/native: net.rs's `SOCK_NONBLOCK \| SOCK_CLOEXEC` (Linux's) replaced by `fcntl` after `socket()`; nothing else |
| BoringSSL | the provider package's pinned 0.20261020.0, its own build | the same pin (tag object and commit checked), built by upstream's CMake for arm64, macOS 11.0, three archives (libcrypto, libssl, the identity object) |
| The unit builds | yes [executed, CI] | **yes**, cargo --locked, rustc 1.97.0, link-only BoringSSL; `MSG_NOSIGNAL` (bridge/io.rs) exists in the libc crate's Apple target and compiled [CI] |
| Localized surface | 20 global definitions = abi.rs's `bh_*` [executed, CI] | **20 = abi.rs's `bh_*`** (raw: 4,316); `LC_BUILD_VERSION` macOS 11.0 [CI] |
| Undefined references | 760 (BoringSSL, libc, libstdc++, `botlish_event_post2`) | 775 (BoringSSL, libSystem, libc++, `botlish_event_post2`) [CI] |
| Probe, provider called | links and runs: `0 -90003 1 1 168 0 0`, both linkers [executed] | **links and runs: `0 -90003 1 1 168 0 0`, both linkers**; one global and one local `rust_eh_personality`; 6.1 MB executables [CI, run 43551304938] |
| Probe, no provider | links and runs (the weak reference is null) [executed] | **link fails on exactly one symbol**, `_botlish_event_post2`, both linkers [CI, run 43526167818]: everything else -- BoringSSL, libc++, the identity, the unit's own Rust -- resolved |
| Probe, provider declared, not called | links; the executables are byte for byte the size of the no-provider ones: the weak reference did not pull the provider's member [executed] | **links and runs**: Apple's ld loaded the provider's member for the unit's weak reference alone (nothing else names it) [CI, run 43551304938] |

The Linux unit is byte for byte the production one (`6f1f0649...8784`):
the refactor of tools/http-package.tcl onto `rustunit::localize` changed
nothing, checked before and after and again from an empty cache after the
container's restart.

So on macOS the technique carries the real unit as far as a link can show
without a driver: it compiles with one portability change, localizes to
exactly its C ABI, and every reference but the event loop's integration
point resolves against BoringSSL and the system. The integration point is
the one ABI question (section 7): with a provider present it links on
both platforms; without one, Apple's ld refuses it.

## 15. Rejected approaches and tradeoffs

* **Shipping the raw cargo archive** (no localization). Rejected by
  evidence, not by assumption: section 5.2 -- duplicate definitions, or a
  link that succeeds and binds the runtime's allocator to the unit's.
* **Relying on "first archive wins".** With one rustc, the GNU system
  link succeeds by archive order -- which is exactly what silently
  rebinds the runtime's allocator shim. Order is not isolation.
* **Renaming or prefixing the unit's Rust symbols** (objcopy
  `--prefix-symbols`, a custom rustc `-C metadata`): changes nothing about
  `rust_eh_personality` and other unmangled C-ABI symbols of std, and
  would need a Mach-O renaming tool Apple does not ship. `ld -r` with an
  export list localizes everything at once on both formats.
* **Extracting members and `ld -r *.o`** instead of `-force_load` /
  `--whole-archive`: a Rust static library may hold two members of one
  name, which `ar x` silently merges. Rejected.
* **A hand-written visibility pass in Tcl** (reading symbol tables and
  deciding what to keep): the platform linker decides; the tool only
  checks the result with nm. Keeps the tool from encoding a symbol model
  of its own.
* **Keeping http's weak reference and passing `-U _botlish_event_post2`
  (Apple ld: allow it undefined)**: a consumer-specific linker flag, which
  this milestone and the package model forbid (metadata never injects a
  linker flag). The weak definition needs no flag on either platform.
* **A runtime registration of the post function** (the driver hands the
  unit a function pointer through `bh_set_notify`): portable, but changes
  the integration ABI, which the milestone keeps unless it cannot work;
  the weak definition works.
* **Teaching the package manager to trust a declared symbol on macOS**
  (SQLite's workaround, the other way round): F-16 is fixed by reading
  the index, every entry checked; nothing is trusted because of its
  target.
* **Keeping the duplicate-symbol checks as they were and putting the
  provider in another package**: the package split alone does not help --
  the installation check sees every package's archives -- so the
  package manager had to learn weak definitions (section 8.2).

## 16. Remaining gaps and risks

* **The localized object keeps Rust's bitcode** [inspection, CI]. `ld -r`
  concatenates the standard library's `__LLVM,__bitcode` sections into
  the one localized member. A non-LTO link ignores them (every link in
  this milestone is one); an LTO link of a consumer's own, or a tool
  reading symbols through Apple's bitcode reader, would meet bitcode of a
  newer LLVM than Xcode's. Dropping the section (a strip step of its own)
  was not needed for anything this milestone links and was not added.
* **Two copies of Rust's standard library remain** [executed, CI]. Each
  is complete and private to its owner: two allocators (the unit's
  counting one sits on `malloc`, as the runtime's does), two panic
  runtimes, two personality routines. That is the price of a prebuilt
  unit; the localization makes it correct, not small. A unit's panic is
  caught at its own C boundary; nothing unwinds from one copy into the
  other.
* **One unwinder per process** [inference]. Linux: libgcc_s for both
  copies; macOS: the system unwinder in libSystem for both (Rust's
  `unwind` crate links the system one on Apple targets). Each copy's
  personality routine reads its own unwind tables; a local
  `rust_eh_personality` is still referenced by the unit's FDEs/compact
  unwind entries, which the executables' `__unwind_info` and the caught
  panics exercise.
* **Deployment target** [inspection]. The unit is built for rustc's
  default macOS 11.0, its C object with `-mmacosx-version-min=11.0`, the
  runtime links with `-mmacosx-version-min=11.0.0`. A unit built for a
  newer target than the consumer's link makes Apple's ld warn; nothing
  checks it at packing.
* **Toolchain coverage** [CI]. The runtime is built by the runners'
  stable rustc (1.100.0 on 2026-11-13), the unit by 1.97.0 and by the
  stable one in the experiments; the same-toolchain case (the silent
  allocator rebinding when unlocalized) and the different-toolchain case
  are both covered on both hosts. One Xcode (16.4) and one macOS image.
* **Dead stripping** [inference]. `ld -r` merges the unit into one object;
  whether Apple's `-dead_strip` can still drop the unit's unused std code
  depends on the merged object keeping subsections via symbols. Size was
  not measured.
* **Only the fixture is packaged** [executed, CI]. No `http` release is
  made or implied; the real unit is built, localized and linked by a
  probe on both hosts (section 14), not packed, installed or exercised
  against a server on macOS.

PENDING (CI): the weak-reference finding on Apple's ld, anything the
macOS runs add.

## 17. Changes made to the main repository

Production and tooling:

| File | Change |
|---|---|
| `tools/rust-unit.tcl` | new: `rustunit::localize` (ELF: the sequence http used; Mach-O: `ld -r -exported_symbols_list`, `libtool -static -D`), `globals`, `undefined`, `check` |
| `tools/http-package.tcl` | its unit's ELF localization is `rustunit::localize` (byte-identical output, checked: `6f1f0649...8784` before and after) |
| `pm/binary.tcl` | Apple's BSD symbol index read and checked (F-16); index entries checked against member offsets; Mach-O underscore stripped per member; weak definitions recorded (ELF `.symtab` of relocatable members, Mach-O `N_WEAK_DEF`) and an archive's `weak` names |
| `pm/native.tcl` | the installation's native closure skips weak definitions in its duplicate check; archive facts carry `weak` |
| `pm/author.tcl` | the pack-time audit skips weak definitions; no second underscore strip |
| `.github/workflows/rust-archive-link.yml` | new (section 11) |
| `AGENTS.md` | "Rust native units (tools/rust-unit.tcl)": the rules and what to run |

Tests, fixture and evidence:

| Path | What |
|---|---|
| `tests/rust-archive-link.test` | 28 tests (section 12) |
| `tests/package-native.test` | `pn-index-*` (7 tests) |
| `audit/rust-archive-link/` | the fixture, packages, consumer, harness, scripts, mutants, results (its README) |
| `audit/golden/migration/census/`, `tcl-names.txt`, `tests/golden/manifest.tsv` | census rows for the new tests, the manifest regenerated by merge.tcl |
| `docs/INDEX.md` | this report's line |

Nothing changed in `packages/http` or `packages/boringssl` (no new
release is implied), in the compiler, the runtime or the standard
library.

## 18. Implications for the next HTTP macOS milestone

What this milestone settles, and what it leaves to the port
(HTTP-MACOS-AND-SSE-ESTIMATE.md):

1. **The native linkage model works on macOS** [CI]. A Rust unit
   localized by `rustunit::localize` links beside the Botlish runtime with
   both linkers, through the package manager, in a consumer without Rust.
   No new mechanism is needed: the port's release recipe calls the same
   procedure with `-format macho`.
2. **Localization is mandatory, and more so on macOS** [CI]. Apple's ld
   reports no duplicate definition at all; an unlocalized unit links
   silently with either a rebound allocator or a shared personality
   routine (section 5.2). The port must ship only the localized archive
   and keep `rustunit::check` in its recipe.
3. **tools/http-package.tcl needs a macOS branch** [inspection]. Today it
   refuses any host but Linux (`httppkg::Host`). The port adds: BoringSSL
   built by upstream's CMake for arm64 and macOS 11.0 (http-unit.tcl's
   recipe, which worked); the provider's identity object in an archive of
   its own or merged with `libtool -static` (not decided here: the probe
   linked three archives); the unit localized as above; and a macOS target
   in both packages' `botlish.json`, made by `native add` (F-16's fix makes
   its `-symbol` checks possible).
4. **One source change, so far** [CI]. net.rs's socket flags
   (`SOCK_NONBLOCK | SOCK_CLOEXEC`) are Linux's; setting them with `fcntl`
   after `socket()` is the portable spelling and changes nothing on Linux.
   That is the only change the unit needed to compile; what runs once a
   driver exists (readiness, timeouts, `MSG_NOSIGNAL` semantics against
   `SO_NOSIGPIPE`) was not exercised.
5. **The integration point stays as it is, with a condition** [CI]. http's
   weak reference to `botlish_event_post2` links on macOS whenever the
   driver (its provider) is linked, which every http program does; only a
   program that links the unit without a driver fails, at link time, on
   that one symbol. If the port wants the unit linkable without a driver
   (a test probe, a tool), notify.c becomes a weak *definition* (section
   7): the same ABI, no linker flag, both platforms -- and the package
   manager now accepts it beside the driver's strong one (section 8.2).
6. **The driver is the real work** [inference]. A kqueue (or
   CFRunLoop-integrated) driver package implementing the same integration
   ABI (`botlish_event_loop.h`, version 2) is out of scope here and
   untouched. Nothing found here constrains its design beyond providing
   `botlish_event_post2` strongly.
7. **Tooling hazards to carry over** [CI]. Read Mach-O symbols with
   `--no-llvm-bc`; give every `ld -r` output a platform load command;
   check the build version and the surface in the recipe; expect about
   80% of a localized unit to be the standard library's bitcode (strip it
   if size matters, after measuring that a link never reads it).
8. **Reproducibility carries over** [CI]. The fixture's macOS unit is
   reproducible across two runners of one image with one Xcode; the port
   should pin the Xcode version its releases are built with, as the
   author image pins Linux's tools, since Apple's ld and libtool versions
   are in the bytes.
