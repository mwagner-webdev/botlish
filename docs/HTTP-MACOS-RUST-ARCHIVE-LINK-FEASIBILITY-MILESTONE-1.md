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

PENDING (CI run 43494070779).

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
runs were superseded (cancelled). PENDING: the result of `ae2cb861`'s
runs.

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

### 5.2 Is localization necessary? The negative control [executed]

The raw archive was linked in place of the localized one into both
consumer programs with both linkers, the unit built by the runtime's own
rustc and by another (audit/rust-archive-link/results/
linux-x86_64-local-results.tsv; the same matrix runs in CI on both
hosts, section 11):

| Unit's rustc vs runtime's | rustc linker | system linker |
|---|---|---|
| the same (1.97.0 / 1.97.0) | **link fails**: `rust-lld: error: duplicate symbol: __rustc::__rust_alloc` (and `__rust_dealloc`, `__rust_realloc`, `__rust_alloc_zeroed`) | **links and runs, wrongly**: the runtime's own allocations (40,047 in the consumer's Botlish work) go through the *unit's* counting allocator |
| different (1.100.0 / 1.97.0) | **link fails**: `duplicate symbol: rust_eh_personality` | **link fails**: GNU ld, `in function 'rust_eh_personality'` (multiple definition) |

The collisions were not manufactured: the fixture defines nothing a real
unit would not (its counting allocator is the one botlish_http's test
unit has). The silent case is the dangerous one. The system linker passes
the program object, then the package archives, then the runtime archive;
the unit's std members are pulled first, and with one rustc their symbol
names are the runtime's own, so the runtime's references to
`__rust_alloc` resolve to the unit's shim, which calls the unit's
`#[global_allocator]`. Two Rust "runtimes" became one, chosen by archive
order. The consumer detects it only because its allocator counts.

With the localized archive every one of those combinations links and
passes (sections 10 and 11). Localization is necessary.

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

PENDING (CI): what Apple's ld accepted, the localized archive's `nm -m`
facts, the final executable's symbols and exports.

## 7. Weak-reference and callback findings

PENDING (CI).

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
refused. `pn-index-weak-definitions` (ELF via cc, Mach-O via clang and
llvm-ar; the installation check for weak+strong and strong+strong) and
`ral-pack-weak-beside-strong` (the audit) pin it.

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

PENDING (CI).

Locally [executed]: `audit/rust-archive-link/cleanroom/consumer.sh` with
`PATH=/usr/bin:/bin`, a fresh `HOME`, the checkout's compiler through a
wrapper and the system linker -- add, verify, native plan (no `-L`),
`-warnings error` builds, three runs of each program, symbol checks --
`CONSUMER OK`.

## 11. Linux/macOS parity

PENDING (CI).

## 12. Negative tests and mutants

PENDING (CI for the macOS mutant).

## 13. Reproducibility evidence

PENDING (CI).

Locally [executed]: two release builds of the fixture in fresh target
directories (rustc 1.97.0) wrote identical archives (unit
`a65bcc85...e6af`, provider `a5dcfbd0...5324`); two packs of each package
are byte-identical (pack.sh's `cmp`).

## 14. Actual HTTP native-unit feasibility

PENDING (CI).

Linux control [executed]: the production path (tools/http-package.tcl:
BoringSSL 0.20261020.0, the unit localized) -- its 20 global definitions
are exactly abi.rs's `bh_*`; a Botlish probe linked with both linkers
opens the bridge, reads the provider's API version, builds a client
trusting the system bundle (BoringSSL's `SSL_CTX` and store), reads the
21 counters, releases and closes: `0 -90003 1 1 168 0 0`, one global and
one local `rust_eh_personality`. The refactored localization leaves the
unit byte for byte as before: `6f1f0649...8784` before and after.

## 15. Rejected approaches and tradeoffs

PENDING.

## 16. Remaining gaps and risks

PENDING.

## 17. Changes made to the main repository

PENDING.

## 18. Implications for the next HTTP macOS milestone

PENDING.
