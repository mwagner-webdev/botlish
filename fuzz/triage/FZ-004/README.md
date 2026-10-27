# FZ-004 — the collector frees a live String object (heap-use-after-free)

Filed: 2026-10-26 (campaign 3, FUZZING-JSON.md)
Target: `conformance` (examples/dfa/json/conformance.bot, ASan AOT build)
Reproducer: `input` (~2.5 KiB argv vector; the raw AFL artifact is kept as
`raw-afl-artifact`). **Deterministic: 20/20 reproductions.**

## Signature

```
==ERROR: AddressSanitizer: heap-use-after-free, READ of size 8
  #0 StrObj::wide            native/src/runtime/strobj.rs:139
  #1..#4 botlish_fn_43/55    (generated code)
freed by:
  #0 Heap::collect ... free_object   native/src/runtime/heap.rs:227
```

The garbage collector frees a String object that generated code still
reads: a **live object was collected** -- a root-tracking hole (the object
was not a root, nor reachable from one, at the collection point, while
machine code still held a reference to it).

## Trigger shape

~500 small hex arguments (the driver's per-case loop): high allocation
churn across many cases grows the heap until a collection lands in the
window where the (unrooted) String is still live for `StrObj::wide`.
The volume is part of the trigger -- greedy argument-dropping minimization
stalls around 470+ cases, because fewer cases do not reach the collection.

## Vertical matrix (manually reproduced)

| vertical          | behavior                                                  |
|-------------------|-----------------------------------------------------------|
| aot (release)     | correct report, identical across repeats and to in-process (latent: same runtime code, but the freed read hits recycled memory that still holds the right bytes) |
| aot + GC-stress   | correct report on this input                               |
| interp / compile  | designed NATIVE-ONLY refusal                               |
| cranelift / cranelift-generic | correct report, identical to aot               |
| aot-asan          | **SIGABRT, the ASan report above (20/20)**                 |

## Classification

**Runtime layer -- GC root tracking** (`native/src/runtime/heap.rs`'s
collector against this program's live Strings; `strobj.rs` is the victim,
not the culprit). Shared by every native vertical (same heap code); the
ASan build makes it observable, the release build is currently latent on
this input. Not fixed, per campaign policy -- this is the finding the
downstream fixing milestone takes first. Suggested starting point: the
collection point at heap.rs:227 and which value `StrObj::wide`'s caller
(botlish_fn_43) holds -- a missing stack-map root or temp-root window for
a String kept live across a call in the case loop.

## Reproduce by hand

```sh
ASAN_OPTIONS=abort_on_error=1:detect_leaks=0 \
  fuzz/harness/argv-file fuzz/build/aot-asan/conformance fuzz/triage/FZ-004/input
# release (latent, correct output today):
fuzz/harness/argv-file fuzz/build/aot/conformance fuzz/triage/FZ-004/input
```

Suite: `tclsh9.0 fuzz/scripts/replay-known-failures.tcl` (expected.tsv;
the aot/cranelift rows compare the full report, the aot-asan row expects
the abort).
