# c-bindgen on Ubuntu 26.04

Status as of 2026-10-27: done. The c-bindgen workflow runs on Ubuntu 26.04
with a pinned toolchain, and every committed binding is regenerated with it.
This started as an interim handoff (2026-10-26); the sections below keep its
account of the cause and record how the migration was finished.

## Cause

`ubuntu-latest` moved to Ubuntu 26.04, which provides Clang 21.1.8 and
MinGW-w64 headers 13.0.0. The committed bindings recorded Clang 18.1.3, and
the Win32 profile pinned MinGW-w64 11.0.1, so the committed-binding check
failed on main.

## Workflow and Codespace

* `.github/workflows/c-bindgen.yml` runs on `ubuntu-26.04` and installs the C
  toolchain with `.devcontainer/setup-c-toolchain.sh`, which pins Clang/LLVM
  21.1.8, MinGW-w64 headers 13.0.0, MinGW-w64's GCC and binutils to the
  versions in the Resolute package index. The script is separate from
  `.devcontainer/setup.sh` because the macOS and ARM64 workflows also run
  that one.
* The Codespace builds `.devcontainer/Dockerfile` from the official
  `ubuntu:26.04` image. `mcr.microsoft.com/devcontainers/base:ubuntu-26.04`
  had no manifest when this was written. Ubuntu 26.04 already has a group
  with GID 1000, so the Dockerfile reuses an existing group ID, reuses or
  renames an existing UID 1000 account, and creates `vscode` only when it
  has to.
* The Win32 profile, `tests/c-bindgen.test`'s Win32 expectations, AGENTS.md
  and C-BINDGEN-LAYOUTS.md pin and name MinGW-w64 13.0.0.

## The generator change

LLVM 21 spells `nocapture` as `captures(none)`. The evidence probe
(`tools/c-bindgen/probe.tcl`) already read both, but appended the LLVM 21
spelling after the other attributes. So the compiler evidence a manifest
records changed order from `{nocapture readonly}` to `{readonly nocapture}`,
and so did the `cb-policy-conflict` message. The probe now keeps the
attributes in the generator's order, whatever order the IR spells them in.
The recorded evidence is therefore the same under Clang 18 and Clang 21.

## Regenerated bindings

Every committed profile and target was regenerated with the pinned toolchain
(`generate PROFILE -target committed` for fixture, tcl, tclstubs, boringssl,
sdl3 and win32), and the diff was reviewed:

* Fixture, Tcl, Tcl stubs, BoringSSL and SDL3 change only in the
  toolchain's identity (`toolchain_version`, `evidence llvm`, `layout_abi`,
  the first line of `layouts.tsv`) and their preprocessed token counts
  (glibc 2.43's and Clang 21's own headers). In Tcl and Tcl stubs the thunk
  Clang rejects (`Tcl_DumpActiveMemory`) is now reported under Clang 21's
  warning name, `-Wreturn-mismatch`, instead of `-Wreturn-type`. No
  declaration, layout or contract changes.
* Win32 changes because MinGW-w64 13's headers do:
  * 3,775 API names instead of 3,754, and 3,337 bound instead of 3,307.
    `no-import-library` covers 93 names instead of 103: user32's import
    library now defines nine of its DPI-awareness functions
    (`GetSystemDpiForProcess`, `SetThreadDpiHostingBehavior`, ...), and the
    `PrefetchForWrite` macro names a builtin (`_m_prefetchw`) under the
    new headers, so it is `no-link-symbol` instead.
  * 15,708 constants instead of 15,309.
  * 1,203 public records instead of 1,171, and 1,041 layouts instead of
    1,015.
  * MinGW-w64 13 split `wincon.h` like the Windows SDK, so the binding has
    the new modules `consoleapi`, `consoleapi2`, `consoleapi3` and
    `wincontypes`, and `wincon` keeps what is left.
  * Several modules (`winreg`, `libloaderapi`, ...) only reorder their
    declarations, because the headers do.

Nothing in the repository imports a changed Win32 module (only
`tests/c-bindgen.test` uses `win32::layouts`).

## How it was regenerated outside Codespaces

A Claude Code cloud container is Ubuntu 24.04 (glibc 2.39, Clang 18), so
its `check` reports every committed binding as changed. The regeneration
ran in an Ubuntu 26.04 chroot on such a container:

1. Unpack `ubuntu-base-26.04-base-amd64.tar.gz` (cdimage.ubuntu.com, checked
   against its SHA256SUMS).
2. Bind-mount `/proc`, `/sys`, `/dev` and the checkout at the same path.
3. Inside the chroot, install `tzdata`, `build-essential` and `git`. The
   runner image has them, but the base image does not, and the Tcl 9 package
   needs `tzdata`.
4. Run `.devcontainer/setup.sh` and `.devcontainer/setup-c-toolchain.sh`,
   then the workflow's steps.

Only Clang's version string and the system headers decide the token counts,
so the outputs equal the runner's as long as the chroot's glibc headers
match the runner image's.

## Verification

All of this ran in the Ubuntu 26.04 chroot, with the workflow's toolchain:

* `tools/c-bindgen.tcl check PROFILE -target committed` reports every
  target of every profile as current.
* `tests/c-bindgen.test` has 84 tests: 84 passed, 0 skipped, 0 failed. The
  Tcl, BoringSSL, SDL3 and Win32 acceptance tests ran.
* `audit/c-bindgen/tools/fuzz.tcl -n 8` (seeds 1-3) found 0
  disagreements.
* `audit/c-bindgen/tools/layout-fuzz.tcl -n 4 -records 24` (seeds 1-2) on
  linux-x86_64, linux-aarch64, windows-x86_64-gnu and macos-aarch64 found 0
  disagreements.
* `audit/c-bindgen/tools/mutate.tcl` ran every mutant in its `mutants.txt`.
