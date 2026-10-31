# UTF16-BYTE-STORAGE-MILESTONE-1.md

UTF-16LE conversion through the byte storage, and Windows native paths held
as UTF-16LE bytes. A performance and correctness milestone on the design
WINDOWS-X86-64-MILESTONE-7.md settled -- textual paths are refinements of
`str`, native paths keep the operating system's own representation -- which
it optimizes and does not change.

> UTF-16 encoding and decoding are operations on Unicode values and
> contiguous byte storage. A native filename remains a sequence of code
> units, a Botlish String remains Unicode text, and the conversion between
> them is explicit, strict when it is asked to be, and one runtime operation.

Evidence is marked by kind:

* **code inspection**: what the code does, read;
* **local experiment**: run on purpose in this repository's Linux x86-64
  development container (4 cores; ext4). The Windows path module's own code
  runs here natively as a *local experiment*: a program that imports
  std::windows and calls no C (its NIR holds no `foreign` declaration) is
  compiled for windows-x86_64 and its NIR run by the Linux driver with the
  host's target line -- the same Botlish code and the same Cranelift
  lowering, under the Linux calling convention (`bench/utf16-bytes.tcl`,
  `tests/filesystem.test`'s `fs-windows-native-runtime`,
  `audit/filesystem/tools/fuzz.tcl`'s windows part);
* **compile only**: compiled for a target this host cannot run;
* **real platform**: observed on a GitHub Actions runner -- `windows-2025`
  (NTFS), `macos-15` (APFS, arm64), `ubuntu-latest` (x86-64) and
  `ubuntu-24.04-arm` -- run named.

The work was developed on Linux, on the branch `ccr-3b394343-oobbuq`.

## Contents

1. Result
2. Starting implementation
3. Encoding contract
4. Decoding contract
5. Backend implementation
6. Windows path integration
7. Representation choices
8. Win32 call buffers
9. Correctness tests
10. Fuzzing and mutants
11. Performance
12. Regression coverage
13. Remaining limitations
14. Files changed and commands to rerun

(The sections follow once the real-platform runs are in: this commit is the implementation.)
