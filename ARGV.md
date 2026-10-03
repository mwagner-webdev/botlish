# `argv()`: the process argument vector

## Outcome

Botlish has its first real external-input channel, as an ordinary callable:

```botlish
args = argv():
    on InvalidArgumentEncoding:
        ["fallback"]
```

```
argv() -> List[String] errors InvalidArgumentEncoding
```

`argv` is a root native (`core/process.tcl`), registered through the same
registry as `length` or `list_get`, resolved by ordinary root-name resolution
(no keyword, no parser change), and declared with the repository's own error
machinery (`errors NAME`, `on NAME:`, EXPLICIT-ERROR-COMPLETIONS.md). It is
implemented identically on the interpreter, the Tcl compiler, the native
in-process backends (`cranelift`, `cranelift-generic`) and standalone AOT
executables. The pipeline, and the whole contract, is:

```
Linux argument bytes
    -> explicit strict-UTF-8 validation, at the call to argv()
    -> canonical Botlish Strings (the ordinary one-allocation constructor)
    -> ordinary immutable List[String]

invalid UTF-8 in any argument -> the declared error InvalidArgumentEncoding
```

Nothing about process startup bypasses normal language semantics: `argv()` is
an ordinary function whose input happens to come from the Linux process
boundary.

## Language-level contract (source-visible documentation)

> `argv()` returns the process argument vector, including element zero.
>
> On Linux each argument must be valid UTF-8. If any argument is invalid
> UTF-8, the call fails with the declared error `InvalidArgumentEncoding`.
>
> `argv()[0]` is the invocation name supplied by the launching process. It is
> **not** guaranteed to be a canonical or actual executable path.
>
> `argv` is a stable snapshot for one process invocation: repeated calls
> observe the same arguments. Object identity of the returned List is not
> promised.
>
> The current implementation is Linux-only and validates Linux argv bytes as
> UTF-8. It does not claim that arbitrary POSIX byte strings become valid
> Botlish Strings.

### Surface and error signature

* Spelling: `argv()`: a call of the root name `argv`, no arguments.
* Error name: **`InvalidArgumentEncoding`**. It matches the existing
  nomenclature (`BelowRange`, `AboveRange`: a noun phrase naming the failed
  condition), and says what failed (an *argument's encoding*) without
  mentioning "process" or "startup". It is a **builtin** error
  (`core::native::declareError`): visible in every program exactly like a root
  native, without an `error` declaration, never part of a program's own
  `errorDecls`, and not redeclarable (`error InvalidArgumentEncoding` is
  rejected as already declared). It carries no payload: the repository's
  errors are payload-free, and correct recoverable failure matters more than
  diagnostics (the offending index and bytes are deliberately not exposed).
* The error is declared with the repository's machinery, not a side channel:
  a native may now list `-errors {NAME...}` in its registry entry
  (`core/native.tcl`). `hir::types::Call` charges `calleeErrors` from that
  list exactly as it does from a block's `errors` clause, and the same
  legality rule applies (`hir/completions.tcl`):
  `calleeErrors(call) - handled(call) ⊆ enclosingDeclaredErrors`. So an
  unhandled `args = argv()` at top level is the ordinary `UNHANDLED-ERROR`
  diagnostic, a function may forward the error with
  `fn f() -> list errors InvalidArgumentEncoding:`, and a structural function
  type carries it (`Fn{args: [], return: list, errors: [InvalidArgumentEncoding]}`).
* A bound or passed `argv` is an *error-bearing callable*: the typed-callable
  escape audit (`hir::callables::Bearing`) treats it like a block with a
  declared error set, so `apply0(argv)` into an untyped parameter is rejected
  rather than silently dropping the obligation, while a parameter typed with
  the right `Fn{...errors...}` accepts it.
* Result type: `List[str]` (`-result-shape {element-type str}`): the element
  type is known statically (a `List[int]` consumer is a `TYPE` diagnostic),
  nothing else is.
* A program that never calls `argv()` acquires **no** error requirement:
  the error exists only at call sites of `argv`. There is no hidden startup
  error edge and no `main(args)` convention.

### Required answers: language semantics

1. **Source spelling?** `argv()`.
2. **A magic variable?** No: the bare name `argv` is the native callable
   (`[argv]` shows `[<native argv>]`), shadowable by ordinary bindings
   (`argv = [1, 2]`, `fn argv() -> int: 7` behave as usual).
3. **A special `main` parameter?** No. Entry/top-level semantics are unchanged.
4. **Includes argument zero?** Yes, never stripped.
5. **What does argument zero mean?** The invocation argument the launching
   process supplied, verbatim: not `realpath`, not absolute, not
   `/proc/self/exe`, not normalized, and not necessarily the executable's
   path. Botlish does not reconstruct it; a separate process intrinsic would
   be needed for the real executable path (deliberately not added).
6. **Ordinary `List[String]`?** Yes.
7. **Canonical ordinary Strings?** Yes (see "Strings and the List").

### Required answers: encoding

8. **Encoding required on Linux?** Valid UTF-8 (strict: no overlong forms, no
   surrogates, nothing above U+10FFFF, no truncated or stray bytes -- exactly
   what Rust's `std::str::from_utf8` accepts).
9. **One argument invalid?** `argv()` completes with the declared
   `InvalidArgumentEncoding`.
10. **Lossy replacement?** Never: no U+FFFD, no Latin-1, no locale conversion.
11. **Handled by ordinary error handling?** Yes (`on InvalidArgumentEncoding:`).
12. **Does invalid argv fail the program before Botlish code runs?** No.
13. **A program that never calls `argv()` under invalid host argv?** Runs
    normally (tested in-process and as a standalone executable).
14. **Partial result if argument N is invalid?** No: the whole call errors.

### Required answers: AOT / runtime

15. **Does AOT capture the compiler process's argv?** No. The compiler's own
    arguments are never read; the build embeds no argument (tested).
16. **Does a standalone executable observe arguments supplied at execution
    time?** Yes.
17. **Can one compiled executable run repeatedly with different argv values?**
    Yes (`argv-standalone-reads-run-time-arguments`: one build, four different
    runs, executable untouched).
18. **Does standalone mode use the real Linux process argv?** Yes
    (`std::env::args_os()` raw bytes of the `argc`/`argv` the process was
    started with).
19. **Do in-process backends use an injected payload rather than the test
    runner's ambient argv?** Yes (`core::process::withArgv`, default
    `botlish-runner`).
20. **Can the injection layer represent invalid UTF-8?** Yes: it is a list of
    byte strings.
21. **Is argv stable throughout one execution?** Yes: one snapshot per run.

### Required answers: architecture

22. **An argv-specific String type?** No: ordinary `String`s from the
    canonical constructor.
23. **An argv-specific List type?** No: an ordinary immutable `List`.
24. **Does the compiler know concrete argv contents?** No.
25. **Can it know the result element type?** Yes: `String` (`List[str]`).
26. **Can it assume a fixed argv length?** No.
27. **Does invalid UTF-8 ever cause a Rust panic?** No: it is validated with
    `std::str::from_utf8`'s `Result`, and every path from a failed validation
    ends in the declared error (unit-tested, fuzzed, run standalone with
    `0xFF` and truncated sequences).
28. **Does the native runtime preserve raw bytes long enough to validate
    explicitly?** Yes: `Vec<Vec<u8>>` from `args_os()`, decoded only inside
    `rt_argv`.
29. **Does `argv()` participate in normal call/error analysis?** Yes
    (`calleeErrors`, legality, handlers, escape audit, `Fn` types, effects,
    AOT readiness).
30. **Does a program that never calls argv acquire a new error requirement?**
    No.

## Linux byte semantics

A Linux argument is a NUL-terminated byte string, so no argument contains NUL
(no `EmbeddedNulArgument` error exists, nothing handles the impossible case;
the in-process injection layer simply rejects a NUL byte as a harness bug).
Empty arguments are preserved (`./program ""` is `["./program", ""]`).
Valid non-ASCII UTF-8 round-trips exactly, with **no Unicode normalization**:
NFC `é` (1 scalar) and NFD `e` + U+0301 (2 scalars) are different Strings.

Validation happens **when `argv()` is called** and is attributable to that
call, so ordinary Botlish handling observes it. It is never done at startup:
a malformed argument cannot affect a program that never asks.

### `argc == 0`

If the runtime is given an empty argument vector, `argv()` is `[]`: no
synthetic executable name is invented at the semantic boundary
(`ops.rs`'s `rt_argv`, `core::process::argvImpl`; unit-tested and tested
in-process on every backend). Note that Linux >= 5.18 never actually starts a
program with `argc == 0`: `execve` rewrites the empty vector to one empty
argument (the pwnkit mitigation), so on such a kernel a standalone executable
launched with no arguments legitimately sees `[""]`
(`argv-standalone-argc-zero` accepts either).

## Runtime snapshot

One run has one argument snapshot, captured as raw bytes and never decoded
until `argv()` runs. The Rust runtime keeps it in the `Vm` (the execution
context -- not a global), so several programs with different snapshots in one
host process never interfere. `Vm::set_argv` copies the bytes in; the C
startup array is never retained. The first `argv()` computes and caches only
the index of the first malformed argument (`Vm::argv_status`, a plain index,
never a GC root); a valid List is rebuilt on each call, which the contract
allows (equal values, no identity promise). A failed call changes nothing: the
next call fails the same way.

## In-process injection (tests and embedders)

In-process execution never reads the test runner's ambient argv. The snapshot
is injected explicitly:

```tcl
core::process::withArgv $argv {
    core::evalProgram ...        ;# interp / compile
    native::evalHir $hir         ;# cranelift / cranelift-generic
}
```

* `ARGV` is a Tcl list of **byte strings**: each element is a string whose
  characters are all in `1..255`, one character per argument byte (what
  `encoding convertto utf-8` and `binary format`/`binary decode hex` produce;
  `core::process::bytesOfText TEXT` encodes text). Bytes, not text, so invalid
  UTF-8 is expressible: this is the representation that makes the invalid-
  encoding path testable, and it is the same vector all four in-process
  backends read.
* The snapshot is dynamically scoped and restored however the script ends;
  nothing outside `withArgv`'s duration observes it, and Tcl threads/interps
  never share it.
* **Default**: with no injection the snapshot is the single synthetic
  argument `botlish-runner` (`core::process::defaultArgv`; the same constant in
  `native/src/runtime/vm.rs`): stable, documented, never `tests/all.tcl`'s own
  argv.
* The Tcl backends read the snapshot through `core::process::argvImpl`
  (`core::native::invoke` turns its `failDeclared` signal into the ordinary
  `propagate-error` completion; the compiler routes errored natives through
  `core::runtime::callValue`, which re-signals it as Tcl completion code 5 --
  the path every declared error already takes). Validation is
  `encoding convertfrom -profile strict utf-8`.
* The native in-process backends pass the same snapshot to the driver as
  `botlish-native run --argv-file PATH` (`native::Driver`): one
  `x<hex>` word per argument, comma separated; `x` alone is the empty
  argument, an empty file is zero arguments. A file, because Linux caps a
  single command-line argument at 128 KiB and a large vector is a test case
  (`--argv ARGS` takes the same syntax inline). Malformed `--argv` is a usage
  error, never a panic.
* `main.tcl` accepts `-argv TEXT` (repeatable), `-argv-hex HEX` (repeatable)
  and `-argv-none` to run a program with a chosen vector on any backend.

Everything after acquisition goes through the same conversion/validation
path per runtime (Tcl: `core::process::argvImpl`; Rust: `rt_argv`): the two
differ only in where the bytes came from.

## Standalone AOT startup path

`native::executable` links a standalone ELF (`native/src/codegen/aot.rs`
generates a small Rust `startup.rs`). The generated `main` now does:

```rust
use std::os::unix::ffi::OsStringExt;
let argv: Vec<Vec<u8>> = std::env::args_os().map(|a| a.into_vec()).collect();
std::process::exit(aot::run(argv, || { ... }))
```

* Source of the bytes: Rust's runtime keeps the `argc`/`argv` glibc passes at
  process start and `args_os()` returns them as raw `OsString`s -- the exact
  bytes, never decoded and never panicking on invalid UTF-8 (unlike
  `std::env::args()`, which is not used). `into_vec` is the lossless Linux
  conversion.
* Ownership: the bytes are copied into one owned `Vec<Vec<u8>>` that moves
  into the worker thread and into the `Vm` (`aot::run` calls
  `vm.set_argv`) before the program entry runs; nothing points at the C
  startup array.
* Nothing is validated at startup (`runtime/aot.rs` documents the ABI).
* The executable is built once and observes the arguments of *each run*:
  nothing about `argv` is a constant of the build, and the compiler's own
  arguments are never read (the build embeds no argument; tested by compiling
  from a process whose argv carries a marker, and under an injected argv, and
  searching the binary).

Differences between the two sources are exactly: in-process = injected
payload; standalone = the real Linux process vector.

## Strings and the List

`rt_argv` (`native/src/runtime/ops.rs`) validates the whole snapshot first
(all or nothing), then builds each String with the canonical one-allocation
constructor (`Vm::new_str`) straight from the validated bytes -- no
argv-specific String type, no interning, no borrowed process string, no
`OsString`, no extra temporary buffer beyond the one `&str` copy -- and builds
the ordinary immutable `ListObj` with `Vm::new_list`. There is no argv-specific
List or collection type. Once constructed, an argument is just a `String`
(character count, ASCII flag and every other String invariant), and the
compiler keeps no "came from argv" taint: no argv-specific ShortString/ASCII
rules, no specialization on contents, no exact length.

## GC ownership

Each argument String is pushed on `Vm::temp_roots` immediately after it is
allocated and kept there until the List exists (`new_list` collects, if due,
*before* it allocates, with every String rooted), after which the temporary
roots are released. The failure path never allocates before validation fails,
so there is nothing to unroot and no partial object ever escapes. The raw
`Vec<Vec<u8>>` snapshot is not a heap object. Allocation failure follows the
runtime's existing policy (an oversized collection is the usual `RANGE`); there
is no argv-specific OOM semantics.

## What the compiler knows (and refuses to know)

* Known: the call returns `List[str]` or completes with
  `InvalidArgumentEncoding`; only a call to `argv` introduces that error.
* Unknown by design: length, contents, argument zero. The call is not
  context-free, so it cannot be a constant, a folded exact value, or a module
  binding's initializer (`MODULE-CONTEXT: ... native operation "argv" is not
  classified context-free`).
* NIR: `%d = op argv` (arity 0, `strutf8bytes`'s allocation class, fallible),
  with the builtin error's **fixed** NIR id `0x40000000` -- far above a
  program's dense 1-based declared-error ids (`BUILTIN_ERROR_ID_BASE` in
  `runtime/error.rs`, `native::lower::ErrorId`) -- so the runtime raises the
  declared error with no per-program table. On failure `rt_argv` sets
  `Vm::declared_error` to that id and returns `NO_VALUE`, exactly what
  `faildeclared` does, so an enclosing `handle`'s `declarederroreq` dispatch
  matches it like any `fail`.
* AOT readiness is ordinary: `argv` is a root native with runtime tags
  `string-alloc list-alloc process-argv`.

## Unhandled failures

An unhandled `argv()` is rejected *statically* (`UNHANDLED-ERROR`) in a checked
program -- the same rule every declared error follows -- so a built standalone
executable never has one. For an unchecked (`-strict 0`) program the failure
is the ordinary uncaught-error completion on every backend: error code
`CORE SEMANTIC UNCAUGHT-ERROR`, message `uncaught propagated error: <error
InvalidArgumentEncoding>` (tested to agree across all four in-process
backends). No Rust panic, no abort, no special exit code, no stderr message
produced at startup.

## Tests

`tests/argv.test` (65 tests) and `native/src/runtime/ops.rs`'s unit tests:

* signature / registry / diagnostics: arity 0, declared builtin error,
  not context-free, no redeclaration, `UNHANDLED-ERROR` unhandled, forwarding
  through `errors`, escape audit, structural `Fn` types, `List[str]` result,
  shadowing, bare-name-is-callable, module-binding rejection, no other process
  natives were added;
* semantics on interp, compile, `cranelift-generic` and `cranelift`: argument
  zero verbatim, empty vector, empty arguments, non-ASCII round trip and no
  normalization, ordinary String operations on elements, the strict UTF-8
  boundary (20 malformed forms and the valid extremes), no partial List,
  ignoring argv under invalid host argv, work-before-argv ordering, stable
  snapshot, repeated failure, per-run snapshots from one compiled program,
  runtime uncaught errors;
* the injection layer: default argv, nesting/restoration, bytes-not-text,
  invalid UTF-8 expressible, per-run isolation, driver syntax and malformed
  `--argv`;
* no compile-time capture: the injected argv appears in no NIR (specialized
  or generic), core IR, generated Tcl code, or HIR text; no static length or
  element facts; NIR uses the plain op and the fixed builtin id;
* GC: stress mode over a 40-argument vector with allocation between two calls,
  the error path under stress, a 2500-argument/hundreds-of-KB vector with and
  without stress, and Rust unit tests that force a collection at every
  allocation inside `rt_argv`;
* standalone executables (one build, many runs, through a bash launcher that
  `exec -a`s exact raw bytes -- the only way to pass invalid UTF-8 and a chosen
  `argv[0]` to a child): different arguments per run without recompilation,
  custom `argv[0]` preserved, path spellings, non-ASCII round trip, invalid
  UTF-8 handled, program ignoring argv under invalid argv, work before
  `argv()`, compile-host leakage (marker in the compiler's argv and in an
  injected argv, searched in the binary), a 600-argument vector (also under
  GC stress), the error path under GC stress, `argc == 0`, parity with the
  in-process value, and a standalone fuzz round.

### Focused fuzzing

Two seeded generators (`srand`) in `tests/argv.test` feed the same vector to
all four in-process backends, and the standalone fuzz test feeds one built
executable:

* **valid vectors**: zero arguments, empty strings, ASCII, multi-byte and
  astral scalars, long arguments (thousands of characters), hundreds of
  arguments, repeated values, embedded whitespace, quotes/backslashes/Tcl
  metacharacters as literal content. Oracle: the injected vector itself (the
  program echoes `args` and `lens`, compared to the Tcl-side expectation); a
  `lowercase`d transform is compared across backends;
* **raw byte vectors**: structured valid/overlong/surrogate/out-of-range/
  truncated pieces plus raw noise. Oracle: an independent RFC 3629 validator
  written in the test from the specification; every backend must return the
  fallback exactly when an argument is malformed, and the decoded vector
  otherwise.

This is the focused argv fuzzing only; the broad argv-driven differential
campaign is the next milestone.

## Verification

Measured on the sandbox (Linux x86_64, Tcl 9.0.1, rustc 1.97):

31. **Did all in-process backends agree on injected valid argv?** Yes:
    interp, compile, `cranelift-generic` and `cranelift` return identical
    values for every injected vector in `tests/argv.test`, including 40
    random valid vectors (up to hundreds of arguments and thousands of
    characters each) and a 2,500-argument vector.
32. **Did standalone AOT observe runtime argv rather than build-time argv?**
    Yes: one executable, built once (its mtime unchanged), printed four
    different vectors for four runs; a build whose compiler process carried a
    marker argument and an injected argv embeds neither.
33. **Was `argv[0]` preserved?** Yes: through `exec -a` with arbitrary
    strings (`CUSTOM-ARGUMENT-ZERO`, `../not/the/./real/path/..//program`, the
    empty string) and for plain relative/absolute invocations.
34. **Did valid non-ASCII UTF-8 round-trip exactly?** Yes, in-process and
    standalone, with no normalization (NFC vs NFD stay distinct).
35. **Did invalid UTF-8 produce the declared Botlish error?** Yes, on every
    backend and standalone, for 20 malformed forms and 60 random raw-byte
    vectors judged by an independent RFC 3629 oracle.
36. **Could that error be handled normally?** Yes (`on InvalidArgumentEncoding:`,
    forwarding through `errors`, through a structural `Fn` type).
37. **Did a program ignoring argv still run under invalid host argv?** Yes,
    in-process and as a standalone executable.
38. **Did invalid argv avoid host-language panic/abort?** Yes: no panic in
    any test; an unhandled failure of an unchecked program is the ordinary
    `CORE SEMANTIC UNCAUGHT-ERROR` on every backend.
39. **Did GC stress pass for argv materialization?** Yes: Rust unit tests that
    collect at every allocation inside `rt_argv`, the in-process and
    standalone stress tests above, and the whole suite under
    `BOTLISH_NATIVE_GC_STRESS=1` (interp 4731/4731, compile 4727 passed + 4
    skipped, 0 failed).
40. **Did focused argv fuzzing find any backend disagreement?** No. (While
    writing it, the only findings were mistakes in the test's own oracles and
    expectations, fixed there.)
41. **Did the full regression pass?** Yes: `tclsh9.0 tests/all.tcl` --
    interp 4730/4730, compile 4727 passed + 4 skipped (the Core-IR-scoping
    tests, which run on the interpreter only), 0 failed; `tests/native-coverage.tcl`
    exits 0; the example runs (`main.tcl` on interp, compile and cranelift) have
    no errors; `cargo test` passes.

## Known limitations

* Linux only: no Windows UTF-16 argv, no macOS APIs, no OS-string type, no
  portable byte-string abstraction. Future ports adapt the intrinsic behind
  the same Botlish semantics.
* `argv()[0]` is not an executable-path API. A separate intrinsic would be
  needed; deliberately not added.
* No environment variables, working directory, stdin/stdout, process id,
  `main(args)` convention or magic global.
* The error has no payload (no index, no byte offset).
* A valid List is rebuilt per call (cheap, contract-permitted); no caching of
  the List itself (a cached List would need a GC root; the validation result is
  cached).
* The standalone `argc == 0` case cannot be exercised on kernels >= 5.18 (see
  above); it is covered by unit and in-process tests.
* `tests/argv.test`'s standalone tests need `bash` (for `exec -a`) and, for the
  `argc == 0` check, `python3`; they are constraint-guarded.
