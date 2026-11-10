# WINDOWS-X86-64-MILESTONE-8.md

Milestone 8 of the Windows x86-64 port: native libraries as Windows DLLs.
A Botlish program compiled by `native::library` (`main.tcl
-emit-native-library NAME`) becomes, on Windows x86-64 with MSVC's
toolchain, a DLL and its import library that an ordinary C or C++ program
loads with `LoadLibraryW` and `GetProcAddress` or links through the import
library -- with the C ABI, the lifecycle, the errors and the ownership
rules of NATIVE-LIBRARY-MILESTONE-1.md unchanged. The milestones before it
are WINDOWS-X86-64-MILESTONE-1.md (the driver, executables) to
WINDOWS-X86-64-MILESTONE-7.md (paths and files); the native library facility
it extends is NATIVE-LIBRARY-MILESTONE-1.md's. The work was developed on
Linux.

> A Botlish library can enter a Windows process it does not own, execute
> under its declared contract, maintain its own runtime and resources, and
> leave the host's execution environment intact.

Evidence is marked by kind throughout:

* **real Windows**: observed on a `windows-2025` runner (Visual Studio 2022's
  x64 tools, link.exe, cl, dumpbin) through
  `.github/workflows/windows-library-probe.yml` (the COFF/linker census) or
  `.github/workflows/windows-x86_64.yml` (the production path and its
  tests), run named;
* **real Linux**: observed in this repository's Linux x86-64 container and in
  Linux CI;
* **cross-built**: a Windows object or the Windows runtime archive built on
  Linux (Cranelift's `--target x86_64-pc-windows-msvc`; `cargo build
  --target x86_64-pc-windows-msvc -p botlish-runtime`, which links nothing)
  and read with LLVM's tools -- never run;
* **code inspection**: what the code does, read, not run.

No Wine and no WSL were used. Commits are on the branch
`ccr-1df6df44-mpq9ii`, where every CI run below ran.

## Contents

1. Result
2. Starting state
3. The COFF/linker census
4. Artifacts
5. The C ABI
6. Export roots
7. Initialization and the loader lock
8. The runtime boundary: threads, reentrancy, stacks
9. GC and unwinding
10. Coroutines inside exported calls
11. The C runtime, ownership and unloading
12. Several libraries in one process
13. Static COFF libraries: why none is shipped
14. Toolchain and diagnostics
15. Tests, fuzzing, mutation testing
16. Performance and size
17. CI
18. Remaining limitations
19. Files changed, and what to run

PENDING-SECTIONS
