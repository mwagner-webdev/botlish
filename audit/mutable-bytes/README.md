# audit/mutable-bytes

Tools and recorded results for `abi::bytes::MutableBytes` and `linux::read` (MUTABLE-BYTES.md).

* `tools/fuzz.tcl` -- differential fuzzer. `-mode pure` runs a random SCRIPT of
  value definitions (fresh values from random byte sequences, copies, updates at
  random valid and invalid indices, generic identity, List and struct storage,
  detaches, double updates, `freeze` snapshots and `freeze_prefix`) on every semantic
  backend and compares the contents of *every* variable and snapshot at the END
  (so an update that leaked into an earlier copy shows up) plus equality and hash
  between random pairs against an independent Tcl byte-list oracle. `-mode read`
  (native, Linux x86-64) makes several `linux::read` calls of random capacities into
  non-zero-filled buffers from one open file, and a single read from a real pipe, and
  checks every result (`min(capacity, remaining)`), the returned buffer (bytes read,
  then the untouched suffix), the caller's own buffer (unchanged) and the file's
  remaining input -- in a normal run and under GC stress. Never fuzzes a syscall number.
* `tools/mutate.tcl` -- mutation test of the boundary: eighteen mutants of the failures a
  writable-buffer value boundary is prone to (an aliasing detach, an in-place update, an
  uncopied argument, a zero-copy freeze, `from_bytes` sharing, a lossy detach, a late
  address, the readable bridge for the writable one, an off-by-one or unrelated count,
  no keepalive, a stale result buffer, syscall number 1, libc `read`, a doubled read,
  a suffix for a prefix, equality by identity, a hash ignoring the length). Run in a
  scratch copy of the tree; Rust mutants rebuild the native backend there.
* `fuzz-result.txt`, `mutate-result.txt` -- the recorded outputs of the final runs.

```
tclsh9.0 audit/mutable-bytes/tools/fuzz.tcl -mode both -n 60 -seed 1 -items 12
tclsh9.0 audit/mutable-bytes/tools/fuzz.tcl -mode read -n 60 -seed 5001 -gc-stress 1
tclsh9.0 audit/mutable-bytes/tools/mutate.tcl -fuzz 12
```
