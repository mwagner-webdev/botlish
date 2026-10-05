# audit/abi-bytes

Tools and recorded results for `abi::bytes::Bytes` and `linux::write` (ABI-BYTES.md).

* `tools/fuzz.tcl` -- differential fuzzer. `-mode pure` checks construction, length,
  contents, equality, hash consistency and aliasing on every semantic backend
  against an independent Tcl byte-sequence oracle; `-mode write` (native, Linux
  x86-64) writes generated payloads to a temp file and to a pipe the harness
  reads and compares the bytes the kernel received, in a normal run and under
  GC stress. Never fuzzes a syscall number.
* `tools/mutate.tcl` -- mutation test of the boundary: twelve mutants of the
  failures a memory-moving syscall wrapper is prone to (off-by-one length, NUL as
  a terminator, payload pointer off by one, bytes masked, count truncated, backing
  not kept alive, address in the wrong register, libc `write` instead of the
  instruction, a doubled syscall, equality by identity, hash ignoring the length, a
  static constant encoded as ASCII). Run in a scratch copy of the tree; Rust mutants
  rebuild the native backend there.
* `fuzz-result.txt`, `mutate-result.txt` -- the recorded outputs of the final runs.

```
tclsh9.0 audit/abi-bytes/tools/fuzz.tcl -mode both -n 40 -seed 1 -items 8
tclsh9.0 audit/abi-bytes/tools/fuzz.tcl -mode write -n 20 -seed 5001 -gc-stress 1 -backends "cranelift-generic cranelift"
tclsh9.0 audit/abi-bytes/tools/mutate.tcl
```
