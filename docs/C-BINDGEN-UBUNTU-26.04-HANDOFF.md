# c-bindgen on Ubuntu 26.04: handoff

Status as of 2026-10-26. This is an interim checkpoint for completing the
toolchain migration in a fresh Codespace; it is not evidence that generated
bindings have been updated or that CI passes.

## Cause and changes so far

The report for main's failing c-bindgen workflow attributes the failure to
`ubuntu-latest` moving to Ubuntu 26.04. That image provides Clang 21.1.8 and
MinGW-w64 headers 13.0.0, whereas the committed bindings record Clang 18 and
the Win32 profile requires MinGW-w64 11.0.1.

The Codespace builds `.devcontainer/Dockerfile` from the official
`ubuntu:26.04` image. The first attempt used
`mcr.microsoft.com/devcontainers/base:ubuntu-26.04`, but Codespaces reported
that the tag had no manifest. The c-bindgen workflow uses the Ubuntu 26.04
runner. The shared toolchain install is isolated in
`.devcontainer/setup-c-toolchain.sh`, because `.devcontainer/setup.sh` is also
used by macOS and ARM64 workflows. The new script pins Clang/LLVM 21.1.8,
MinGW-w64 headers 13.0.0, its GCC cross compiler and binutils to the versions
available in the Resolute package index. The Win32 profile and its test
expectations now pin header macros 13.0.0.

The first Dockerfile build then failed because Ubuntu 26.04 already has a
group with GID 1000. The Dockerfile now reuses an existing group ID and
reuses/renames an existing UID 1000 account when present, creating the
`vscode` user only when needed.

## Still pending

The committed outputs under `generated/c/` still contain Clang 18 evidence
and MinGW-w64 11.0.1 metadata. Until every affected profile is regenerated
with the new toolchain and committed, the c-bindgen committed-binding check
is expected to fail. Regeneration may also change API reports, layout
manifests and the recorded census; review those changes rather than editing
generated files by hand.

In the new Codespace:

1. Run `.devcontainer/setup-c-toolchain.sh` and confirm its printed Clang and
   cross-compiler versions.
2. Fetch the pinned Tcl, BoringSSL and SDL3 sources using the c-bindgen
   workflow's fetch step.
3. Regenerate all committed profile/target bindings, then run
   `tools/c-bindgen.tcl check PROFILE -target committed` for fixture, tcl,
   tclstubs, boringssl, sdl3 and win32.
4. Review and commit the generated outputs and any documentation/census
   updates; run `tests/c-bindgen.test`, both c-bindgen fuzzers and the
   mutation checks described in `AGENTS.md`.

The prior container did not have Clang or MinGW installed, so its
`tests/c-bindgen.test` run skipped all 83 tests. It did not validate the new
toolchain or regenerated bindings.