# NATIVE-LIBRARY-MILESTONE-1.md

First-class C exports and native-library artifacts.

> A Botlish function exported to C must be compiled for every value
> permitted by its declared contract, not merely for the values its
> existing Botlish callers happen to pass. A native library must remain
> correct when embedded in another process, when called repeatedly, and
> when linked beside another Botlish library.

The compiler builds native libraries. `exported c fn` declares a C export.
`native::library` (and `main.tcl -emit-native-library NAME`) compiles a
program into a static archive, a shared library, a C header and a JSON
manifest. A C host links them and calls the exports through an explicit
instance lifecycle and status-returning functions, with owned results and
structured errors.

Every export is its own compilation root, compiled under its declaration
only. The census's two optimizer defects are reproduced without any
`argv()` workaround, and they pass. Executables and libraries share one
startup data product, the program descriptor and the `LinkedProgram`
record, so nothing captures an executable's startup code any more. Two
libraries in one process share no symbol, no code and no state.

The JSON/Tcl probe and the React Native host probe both run on the
compiler's output; `audit/react-native/tools/libmode.tcl` is kept as
history only.

## Contents

1. Executive result
2. Starting state
3. Export-root semantics
4. Library architecture
5. Export syntax and API
6. The C ABI contract
7. Runtime lifecycle
8. Multiple-library correctness
9. Artifacts and public APIs
10. JSON/Tcl validation
11. React Native compatibility
12. Performance and size
13. Limitations
14. Next milestone
15. Validation: tests, probes, mutation results
16. What to run when changing this

## 1. Executive result

**Implemented on Linux x86-64 (glibc).** Every completion criterion of the
brief holds there, observed rather than predicted:

| Criterion | Evidence |
|---|---|
| Exports compiled under their declared contracts | `hir/specialize.tcl:1896` `ProgramValues`; `nl-export-root-checked`, `-token-count`, `-no-caller`, `-internal-stays-optimized` |
| `checked(-5)` and the long-input JSON regression pass with no workaround | `nl-export-root-checked` (`Rejected code=-5`), `nl-export-root-token-count` (321 tokens, equal to the reference interpreter's count); the probe's `exports.bot` has no `argv()` and no top level |
| The compiler produces a static library, header and manifest | `native/library.tcl:80` `native::library`, `main.tcl -emit-native-library`; `nl-main-cli`, `nl-manifest` |
| Startup needs no captured executable code | `native/src/runtime/program.rs` (descriptor, record, `instantiate`); the startup crate is a constant (`native/src/codegen/aot.rs:89`); `tests/native-executable.test` 18/18, `tests/aot-stub-linker.test` 6/6 |
| Defined ownership and release of results | `owned_buffer` and `botlish_library_bytes_release` (`native/src/runtime/library.rs:393`, `:575`); `nl-abi-types`, `nl-abi-results-survive` |
| Declared errors keep their identities as data | the NIR error table (`native/lower.tcl:1670`), `botlish_error` (`library.rs:260`); every `report` line of the tests reads identity and fields through accessors, never a message |
| Two libraries in one binary, correct under GC stress | `nl-two-libraries`, `nl-two-libraries-shared`, `nl-nested-libraries`, each run with and without `BOTLISH_NATIVE_GC_STRESS=1` |
| Two instances of one library isolated | `nl-two-instances`, `nl-lifecycle`, `nl-threads` |
| The Tcl JSON probe runs on the new facility | `audit/compiler-service/probes/export/` (section 10), under GC stress too |
| The React Native host probe consumes the new artifact | `audit/react-native/tools/host-spike.tcl` (section 11), under GC stress and a 512 KiB stack |
| Executables still correct | the suites of section 15 |

**Verified in CI: Linux AArch64.** The library path holds no x86-64 code:

* The trampolines are Cranelift IR over the host ISA.
* The record and forwarders are target-independent.
* `codegen::library::SUPPORTED` (`native/src/codegen/library.rs:40`) and
  `native/native.tcl`'s `libraries` capability both name `linux-aarch64`.

This container had no AArch64 machine, cross toolchain or qemu, so the
evidence is CI's. `tests-arm64.yml`, dispatched on this branch (run
40026035898, ubuntu-24.04-arm), passed every job:

* the Tcl suite on interp (9,295 tests, 0 failed) and on compile, with no
  test skipped for `nativeLibraries` or `nm`, so `tests/native-library.test`
  ran in full on AArch64;
* the whole suite under GC stress;
* the Rust unit tests, also under GC stress, the golden suites and both
  native coverage jobs.

**Not supported: macOS, Windows and mobile targets.**

* `native::library` refuses them before lowering (`NATIVE UNSUPPORTED
  library`, from `native::hostSupports libraries`).
* The driver refuses its `library` command on them too (`SUPPORTED`).
* Mobile cross-compilation was outside the brief.

**Stack safety, for Botlish recursion.** Botlish code runs on the
caller's stack with no guard, so a library's functions check their stack
pointer (added after the milestone: section 7, "Stack safety"). Recursion
that would exhaust the caller's stack, or a coroutine's, fails the call
with NATIVE LIMIT STACK and the instance goes on. A C function or the
runtime exhausting the stack still ends the process; the header, the
Compilerpedia topics and section 13 say so.

Tested platform: Ubuntu 24.04.5 LTS container, Linux 6.18 x86-64, glibc
2.39; rustc 1.97.0, cranelift-codegen 0.135.2; GNU binutils 2.42 (ld,
objcopy, ar, nm); gcc 13.3.0 (`cc`); clang 18.1.3 (the React Native
harness); Tcl 9.0.1; Hermes `hermes-v260318099.0.4`, React Native 0.88.0.

## 2. Starting state

Two experiments had shown the pieces. Both used one stand-in,
`audit/react-native/tools/libmode.tcl` (REACT-NATIVE-TARGET-CENSUS.md,
"Library mode").

* **The stand-in itself** built the library by capturing an executable link.
  * A pass-through `RUSTC` copied the generated startup crate (`startup.rs`)
    and `program.o`.
  * It cut the startup's `ProgramInfo`, constant pool and stack maps out of
    `fn main`.
  * It wrapped chosen functions' generic entries (`botlish_entry_N`) in C
    functions with statuses.
  * Each thread got one `Vm`, created on first use.
  * A `str` result was a pointer into the Botlish heap, valid "until this
    thread's next call".
* **The compiler-service JSON probe** (COMPILER-SERVICE-CENSUS.md, section
  8.2) loaded such a library into `tclsh9.0` and ran the real tokenizer
  (`json_tokens.bot`) at 36 µs per call.
  * Its first version returned `-10` for `checked(-5)` and miscounted every
    input longer than six characters. The exported instances were the ones
    specialized for the program's own constant calls.
  * Making every top-level argument depend on `argv()` hid the defect.
* **The React Native census** (REACT-NATIVE-TARGET-CENSUS.md, sections 7 and
  9) put the library behind a generated Pure C++ TurboModule and called it
  from Hermes.
  * It ran on an Android emulator and an iOS simulator through
    `react-native-probe.yml`.
  * Two such libraries linked into one binary returned
    `other_twice(21) = 140538536848112`. Both defined `botlish_fn_0` and the
    same `rt_*` runtime symbols, so the second library's wrappers ran the
    first library's code.

The census listed the capability the stand-in lacked: export roots in
native lowering. The rest of library mode, it argued, follows from that.

## 3. Export-root semantics

### Where an export's identity lives

An export is a resolved block, and that block's identity is the export:

* **HIR.** `exported c fn` sets the declaring block's `exported` field to
  `c` (`hir/syntax.tcl` `withExported`, `hir/resolve.tcl` copies it, and HIR
  text prints it: section 5).
* **The export records.** `hir::exports::of` (`hir/exports.tcl:70`) lists
  the program's exports as records `{name module block params result errors
  origin}`. Each record is keyed by that block, never by a name found in
  generated text.
* **The explicit list.** `native::library -exports NAMES` resolves names to
  the same records (`hir::exports::select`, `:98`).

### How an export is compiled

Specialization (`hir/specialize.tcl`) already distinguishes two kinds of
instance. A *closed* instance is one whose every caller is known, so it may
take its callers' facts (a Range, a raw or short ABI, a constant-folded
branch). An *open* instance's block is materialized as a value that unknown
code may call, so it takes only its declared contract.

A foreign host holding an export is exactly that unknown code. So
`hir::specialize::analyze -exports BLOCKS` makes the program region
"materialize" every export (`ProgramValues`, `:1896`). As a result:

* The export's generic instance is used (an edge of the program and a root
  of lowering). That covers an export with no Botlish caller, and its
  transitive callees.
* That instance is open (`InstanceClosed`), so no caller's fact reaches it.
  Its body is typed by its declared parameter types alone.
* Calls of the function from Botlish code still select their own
  specialized instances, closed and optimized as before.

Native lowering writes one NIR line per export:

```text
export "chk_checked" func=3 params="int" result=int
```

`func` names the generic instance (`native/lower.tcl:1612`). The driver
compiles that function as an ordinary function, and the library calls its
generic entry. Tiny-leaf inlining stays on (`-tiny-leaf-inline-opt` is
untouched). Inlining a tiny export into its Botlish callers removes nothing,
because the export root is a separate instance with its own symbol.

### Evidence the defects are gone

`tests/native-library.test` reproduces both census programs with constant
Botlish callers and no `argv()`.

**`checked`, `nl-export-root-checked`.** `internal()` calls `checked(1)`.
The library is called through C with -5, 8 and 21, with and without GC
stress:

```text
internal() = 2
checked: status 1 Rejected code=-5
checked(8) = 16
checked(21) = 42
```

**`token_count`, `nl-export-root-token-count`.** The only Botlish caller,
`sample()`, tokenizes a six-character constant. From C, a 1,120-byte input
gives 321 tokens, the reference interpreter's count of the same input, and
`"abcdefghij"` gives 1.

**The reverse direction, `nl-export-root-internal-stays-optimized`.** The
test reads the NIR.

* The export root of `checked` is `instance="generic"` and contains the
  `faildeclared` of its `n < 0` branch.
* The Botlish caller `internal` has no `faildeclared` at all. With tiny-leaf
  inlining on, `checked(1)` was inlined and folded.
* With inlining off, `internal` calls `checked`'s own `instance="int"`
  instance, which also has no `faildeclared`: the closed instance is
  specialized as before.

**Tiny and uncalled exports, `nl-export-root-no-caller`.**

* `lonely(a, b)` has no Botlish caller and works.
* `add1(n)` is a one-line function Botlish calls with constants. It returns
  correct results from C, including `RESULT-OUT-OF-RANGE` for
  `add1(INT64_MAX)`.

**The mutant `export-root-specialized` (section 15).** It returns
`ProgramValues` to its old behavior, so the export becomes whatever
instance Botlish code specialized. It reproduces `checked(-5) = -10` and
fails 18 tests (the final run, section 15).

### Checks

`hir::exports::verify` (`hir/exports.tcl:50`) runs in every compilation
(`hir::CheckOnce`, after `hir::semantic::verify`), not only in library
builds. A malformed `exported c fn` is a diagnostic wherever it is
compiled. Section 5 lists the four kinds.

## 4. Library architecture

```text
Botlish source
  -> front end (HIR; hir::exports::of: the export records)
  -> native::nir -exports           NIR + `export` and `error` lines
  -> botlish-native library         one ELF object (Cranelift):
                                      program code (local symbols),
                                      descriptor + LinkedProgram record (local),
                                      one trampoline per export (global),
                                      the C API forwarders (global)
  -> ld -r  with libbotlish_native.a      one relocatable object
  -> objcopy --keep-global-symbols  only the public C names stay global
  -> ar rcs                        libNAME.a
  -> cc -shared -Wl,--gc-sections  libNAME.so
  -> Tcl (the export records)      NAME.h, NAME.manifest.json
```

**One code generator.** `codegen::emit_object_with`
(`native/src/codegen/mod.rs:425`) is the executable path's object writer.
A library adds two things to it:

* the record's local linkage;
* `codegen::library::define` (`native/src/codegen/library.rs:67`), which
  emits the trampolines and forwarders.

**One startup data product.** `runtime::program` is what executables and
libraries share:

* `ProgramDescriptor` (`program.rs:70`) holds the program's metadata,
  constants, statics, per-function stack maps and code sizes, its exports
  and its error table. It is encoded by `encode` (`:190`) and checked by
  `decode` (`:294`).
* `LinkedProgram` (`:46`) is the record the object exports to its own
  runtime: magic `BOTLPRG1`, the runtime's ABI fingerprint, the descriptor's
  bytes, and the code table of each function's direct and generic entry,
  relocated by the link.
* `instantiate` (`:387`) builds a Vm from them. It is the only code that
  installs constants and stack maps.

Three consumers read the record:

* the rustc-linked executable's startup, now constant text
  (`native/src/codegen/aot.rs:89`):
  `aot::run(argv, || program::instantiate_linked(&botlish_program))`;
* the stub linker's image (`runtime/aotimage.rs`: the record in the
  appended image);
* each library instance (`runtime/library.rs` `botlish_library_create`).

Before this milestone the startup crate was generated per program. It was
the only place the program's metadata existed, which is why the stand-in
had to capture it.

**The public ABI boundary** holds C types only. A trampoline (Cranelift,
`codegen/library.rs`) takes the C signature, stores the argument words in a
stack slot and calls `botlish_library_call(record, instance, index, words,
out, error)`. The runtime then:

* checks the instance out (`checkout`);
* converts each argument (`argument`, `library.rs:309`);
* calls the export root's generic entry;
* converts the result (`result`, `:346`) or the error (`botlish_error`,
  `:260`);
* returns an `int32_t` status.

No `Value`, Vm, Rust type or layout crosses. A Botlish failure is a return
value, never an unwinding. A Rust panic is caught at every entry point
(`guarded`, `:185`) and becomes `STATUS_INTERNAL` "NATIVE BUG". The
release profile unwinds on panic (no `panic = "abort"`), so the catch is
real.

**The internal Botlish convention is unchanged.** Botlish callers of an
exported function call its direct code (or inline it). Only C goes
through the trampoline.

## 5. Export syntax and API

### `exported c fn`

```botlish
error Rejected:
    code: int

exported c fn checked(n: int) -> int errors Rejected:
    if n < 0:
        fail Rejected {code: n}
    n * 2
```

* **Grammar.** `exported` is a function modifier beside `nomethod`
  (`surface/parser.tcl:410`), and it names its foreign ABI. `exported fn`
  is a syntax error ("an exported function names its foreign ABI: write
  `exported c fn NAME(...) -> T:`", `:2679`). Elsewhere `exported` stays an
  ordinary name (`nl-front-end-syntax`). No attribute system was added.
* **HIR.** The block field `exported c` (`hir/hir.tcl`'s field doc), printed
  in HIR text (`hir/format.tcl`: `block s3 (b2 n:int) captures () exported
  c declares int`) and read back by `hir/read.tcl`. Interchange carries it
  (`nl-front-end-hir-text`).
* **Meaning to Botlish.** None: an ordinary function to every backend
  (`nl-front-end-runs-everywhere` runs one on interp, compile, cranelift and
  cranelift-generic). Only a library makes a C symbol of it.

### The rules (`hir::exports::Problems`, `hir/exports.tcl:146`)

* **EXPORT-SIGNATURE.**
  * Every parameter is declared `int`, `bool`, `Float64` or `str`, and the
    result is one of those or `unit`, declared.
  * There is no flag section, context parameter, variadic parameter or
    resume clause.
  * The C ABI is read from the declaration alone, never from how callers
    use the function.
* **EXPORT-PLACEMENT.** The function is top-level in the entry program or
  in a module.
* **EXPORT-NAME.** The name is a C identifier, since it is the suffix of the
  C symbol `LIB_name`.
* **EXPORT-ENVIRONMENT.** The function is environment-free:
  * it captures no value (calling other top-level functions is not
    capturing: `hir::aot::StaticBlocks`);
  * it requires no context;
  * it never suspends (`hir::coroutines::MayYield`).

Each kind has a `std::compiler::DiagnosticCode` case (`ExportEnvironment`,
`ExportName`, `ExportPlacement`, `ExportSignature`; `stdlib/compiler.bot`,
`hir::static::codes`) and a Compilerpedia topic (`error.export-*`).
`nl-front-end-diagnostics` checks all four, ten findings in one program.

### The explicit list

`native::library HIR -exports {f g}` (CLI: `-export f -export g`) exports
top-level functions of the entry program by name. It exists for programs
written before the declaration. `hir::exports::select` resolves each name to
its declaring block and builds the same record, checked by the same rules,
so both forms reach lowering identically (`nl-library-export-list`).

### Public, exported and foreign are three things

These were documented in `hir/exports.tcl`'s header and Compilerpedia's
`backend.native-library` ("THREE DIFFERENT THINGS"):

* A module's top-level functions are visible to every importer (unless
  declared `private`, which came later:
  MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md, Compilerpedia's
  `concept.private`; there are no export lists). That reach is
  Botlish-to-Botlish and makes no C symbol: a `private exported c fn` is
  still a C export.
* `extern c fn` declares a C function Botlish calls: a foreign *import*
  (C-FFI.md).
* `exported c fn` gives a Botlish function a C entry point: a foreign
  *export*.

### Library-level checks (`native/library.tcl`)

These raise `NATIVE LIBRARY KIND` with location data:

* LIBRARY-TOP-LEVEL: the entry file holds declarations only.
* LIBRARY-NO-EXPORTS.
* LIBRARY-SYMBOL: a C name that is reserved (`create`, `destroy`,
  `error_*`, ...) or duplicate.
* The options are checked too (`NAME`, `OUT`, `TOOL`).

All are tested by `nl-library-checks`.

## 6. The C ABI contract

The header (`native/library.tcl:302` `Header`) states the contract in its
comment block. It says everything below.

### Types

| Botlish | C parameter | C result (out-parameter) | Rule |
|---|---|---|---|
| `int` | `int64_t` | `int64_t *` | Every `int64_t` enters exactly. An Int result outside `int64_t` is `STATUS_BOUNDARY` `RESULT-OUT-OF-RANGE`, never wrapped or clamped. |
| `bool` | `bool` | `bool *` | |
| `Float64` | `double` | `double *` | NaN and ±infinity are `BOUNDARY` `ARGUMENT-NOT-FINITE`. -0.0 enters as 0.0, because Float64 has no negative zero (FLOAT64-MILESTONE-1.md). |
| `str` | `const uint8_t *, size_t` | `NAME_bytes *` (`{uint8_t *ptr; size_t len}`) | Validated as UTF-8 (`ARGUMENT-NOT-UTF8`), then copied. NULL is allowed for length 0 (`ARGUMENT-NULL` otherwise). Embedded NULs are allowed. |
| `unit` result | | none | |

Every export is `int32_t NAME_FN(NAME_instance *, PARAMS..., [RESULT *out,]
NAME_error **error)`. The JavaScript safe-integer limit is the React Native
adapter's policy (section 11), not the ABI's.

### Statuses (`runtime/library.rs:76-90`)

| Status | Value | Meaning | Identity |
|---|---|---|---|
| `NAME_STATUS_OK` | 0 | success | |
| `NAME_STATUS_DECLARED` | 1 | a declared Botlish error | its canonical name: `Rejected`, `json_tokens::Malformed`, a builtin such as `IndexNotFound` |
| `NAME_STATUS_RUNTIME` | 2 | a runtime error | its code: `CORE SEMANTIC RANGE` |
| `NAME_STATUS_BOUNDARY` | 3 | an argument or result C cannot carry | `ARGUMENT-NOT-UTF8`, `ARGUMENT-NULL`, `ARGUMENT-NOT-FINITE`, `RESULT-OUT-OF-RANGE` |
| `NAME_STATUS_INVOCATION` | 4 | a call the lifecycle forbids | `INVALID-INSTANCE`, `WRONG-THREAD`, `REENTRANT-CALL`, `NULL-POINTER` |
| `NAME_STATUS_INTERNAL` | 5 | a runtime defect | `NATIVE BUG` |

### Errors as data

On failure, a non-NULL `error` receives a `NAME_error *` the caller owns,
read through accessors:

* `NAME_error_status`;
* `NAME_error_identity` and `NAME_error_message` (bytes and a length);
* `NAME_error_field_count`;
* `NAME_error_field_name` and `NAME_error_field_type` (`NAME_FIELD_INT`,
  `BOOL`, `FLOAT64`, `STR`, `OTHER`);
* `NAME_error_field_int`, `_bool`, `_float64` and `_str`.

A boundary error's argument errors carry an `argument` field (its index).

The identity is data from the compiler, never parsed from a message.

* **Declared errors.** Native lowering writes the program's error table
  into the NIR (`error ID "NAME"`, `native/lower.tcl:1670`): every declared
  error of the program plus the runtime's builtins. The descriptor carries
  it (`ProgramInfo::errors`). `botlish_error` maps the Vm's declared-error
  id to the name, and reads the payload's fields from the Vm's payload slots
  and the payload shape's field names (`library.rs:260`).
* **Payload fields.** Field values are copied out of the heap.
  * An Int beyond `int64_t` is `FIELD_INT`, whose accessor answers
    `BOUNDARY`.
  * A List, a struct or anything else is `FIELD_OTHER`. The identity, the
    other fields and the message remain, and no object protocol was built.
* **The message** is the Vm's description (`uncaught propagated error:
  <error Rejected {code: -5}>`): for people only.

`nl-abi-types` shows the full form: `odd(3): status 1 Odd count=3
flag=true items=(other) note="odd ä" ratio=0.5`.

### Ownership and release

* **A `str` result** is a `malloc`ed copy of the String's UTF-8, with a NUL
  after its `len` bytes (`owned_buffer`, `library.rs:393`). It holds no
  pointer into the Botlish heap.
  * It stays valid until `NAME_bytes_release`, across later calls,
    collections, the instance's destruction and other libraries
    (`nl-abi-results-survive`, `nl-two-libraries`).
  * `NAME_bytes_release(&b)` frees the buffer and clears `b`. Releasing a
    cleared struct, or NULL, is a no-op.
  * A buffer this library never handed out (another library's, or a
    literal) is refused with `INVOCATION` and left alone. Each library
    keeps a live set (`BUFFERS`).
* **An error** has the same rules through `NAME_error_release(&e)`, which
  clears `e`. Its live set is `ERRORS`. An error survives later calls and
  destruction (`nl-abi-results-survive` reports an error kept across 2,000
  calls and the instance's destruction).
* **GC roots.** Converted arguments are rooted (`Vm::temp_roots`) until the
  call returns. Results and errors are copied out before the call returns,
  so nothing a caller holds is a GC object.

## 7. Runtime lifecycle

```c
int32_t NAME_create(NAME_instance **instance, NAME_error **error);
int32_t NAME_destroy(NAME_instance *instance);
```

### Initialization

`NAME_create` reads the library's record, checked by `read_linked`:

* the magic;
* the runtime's ABI fingerprint, so a program object never runs on another
  runtime build;
* that the code table matches the descriptor.

It builds a Vm (`instantiate`) and runs the program function, which is the
modules' static initialization only. A library's entry file holds
declarations only (LIBRARY-TOP-LEVEL), so no entry script runs. `argv()`
is the empty list.

* **Failed initialization** (a module static's error) returns its status
  and error, frees the half-made instance and leaves `*instance` NULL.
* **Repeated initialization** is ordinary: every `create` makes an
  independent instance and runs the initialization again. There is no
  process-wide "initialized" state.

### Destruction

`NAME_destroy` frees the instance's Vm and its whole heap. Results and
errors it handed out stay valid.

### Handles

An instance handle is an 8-byte ticket the library allocates and never
frees (8 bytes per instance ever made), never a pointer the library
dereferences unchecked. Every call looks it up in the library's registry
(`INSTANCES`, `library.rs:157`) first. A destroyed, foreign, NULL or
garbage handle is `INVALID-INSTANCE` (`nl-lifecycle` covers destroyed,
destroyed twice, NULL and the address of a stack variable). Tickets are
never reused, so a stale handle never names a newer instance.

### Thread affinity

An instance records the thread that created it.

* A call or `destroy` from another thread is `WRONG-THREAD`, and nothing
  runs.
* A call from inside one of the instance's own calls, through a C function
  Botlish called, is `REENTRANT-CALL`. Another instance may be called
  there (`nl-reentrant`, `nl-nested-libraries`). This is unchanged by
  C-CALLBACK-MILESTONE-1.md: a host entering an instance through its
  export trampoline is a new call of the library's C API, refused while the
  instance runs one. A `callback c fn` of the library's program that a C
  function the instance called calls back is another operation -- it runs
  nested in the instance's waiting call, through the callback's own entry
  point and the call's foreign transition, never through
  `botlish_library_call` (C-CALLBACK-MILESTONE-1.md, "Relationship to
  exported c fn").
* Instances on different threads run concurrently (`nl-threads`: four at
  once, with allocation). Each has its own heap, and the registry's mutex is
  held only for the lookup.

### Identity

The program and the instance are separate identities, and neither is the
thread.

* **The program** is the library's `LinkedProgram` record. Each
  trampoline and forwarder passes its own record's address, so an instance
  of library A given to library B's function is `INVALID-INSTANCE`.
* **The instance** is its handle.
* **The thread** is a property the instance checks, recorded at creation.
  A later actor-aware layer can own instances, move the creation onto its
  threads, or replace the check, without changing the C signature.

### Stack safety

Added after the milestone. A library runs on its caller's stack and
installs no stack guard there: the executable's guard is a process-wide
signal handler that ends the process, which a library must never do to
its host. Before this, recursion that exhausted the caller's stack ended
the process with SIGSEGV (the table in section 13). Now a library's code
bounds its own recursion.

* **The check.** The driver emits a library's program through
  `nir::check_stack_limit`. Every function that makes a Botlish call
  compares its stack pointer with `Vm::stack_limit` in its prologue
  (`codegen::clif`'s `prologue_stack_limit`, planned by `codegen::roots`'s
  `stack_check`): one load, one compare and a branch to a cold block that
  fails with NATIVE LIMIT STACK. The call-effect summaries make those
  functions fallible, so their callers check for the error, as on the
  fallback plan. Executables and the driver's JIT are unchanged: their
  code has no check and their calls stay infallible, bounded by the
  guard.
* **The limit** is the running stack's low bound plus a reserve of an
  eighth of its size, at least 64 KiB and at most 1 MiB
  (`NativeStack::stack_limit`). The reserve is for what runs below the
  last checked frame: Botlish functions that make no Botlish call, the
  runtime's helpers, C functions Botlish code calls, and the failure's
  way back to the host.
* **Which stack.** `NAME_create` turns the check on with the creating
  thread's stack (`Vm::check_stack_limit`). Every call takes the limit of
  the stack it enters on (`enter`, `Vm::stack_limit_at`): the thread's,
  or none on a stack the instance did not make (a host's own coroutine
  or fiber), never another stack's limit. Every coroutine switch
  publishes the stack it arrives on (`Vm::publish_active_stack`), which
  now sets the limit too, so a coroutine's body is bounded by its own
  stack.
* **After a failure** the call returns `NAME_STATUS_RUNTIME` with the
  identity `NATIVE LIMIT STACK`, and the instance answers the next call.

Not covered: a C function or a runtime helper that exhausts the reserve
by itself, and recursion on a stack the instance did not make. Both still
end the process: there is no guard to catch them. A library-owned stack
(section 14) would cover them.

Measured with `depth(n)` (n nested Botlish calls), searching for the
largest n that returns, on a plain C caller's threads (x86-64):

| Caller's stack | Largest depth that returns | First refused (NATIVE LIMIT STACK) | Before (section 13) |
|---|---|---|---|
| 512 KiB | 9,434 | 9,435 | 10,000 returned, 20,000 crashed |
| 1 MiB | 18,992 | 18,993 | 20,000 returned, 30,000 crashed |
| 8 MiB | 152,794 | 152,795 | 150,000 returned, 200,000 crashed |

After each refusal `depth(1000)` returned on the same instance.

The cost, against the same library built by main's driver without the
check, on `fib(32)` (2.2 million calls, each a function with a Botlish
call: the worst case), twelve interleaved runs of the best of seven calls
each: minimum 26.5 ms against 24.3 ms, median 27.0 ms against 25.2 ms,
about 8%. The shared library's text grew by 1.4 KB (625,676 bytes against
624,296). Executables and the JIT emit no check and are unchanged.

The tests are `nl-stack-safety` (the main thread, a 512 KiB and a 1 MiB
thread), `nl-stack-safety-coroutine` (a coroutine's 8 MiB stack bounds
recursion that the 512 KiB thread's could not hold, and a fused
coroutine runs on the thread's) and `nl-stack-safety-foreign-stack` (a
call on a host-made `ucontext` stack is not checked against the thread's
limit, and the thread's is back for the next call). All run plainly and
under GC stress.

**Found on the way: fusion dropped exports.** `codegen::fusion`'s
`drop_unreferenced` empties every function nothing reaches from the
program function. A library's exports are reached from C only, so in a
library with a fused coroutine every export no other function called
lost its body, and calling it reported `NATIVE BUG: native code reached a
point HIR proved unreachable`. The walk now starts at the exports too
(`a_library_export_keeps_its_code_when_a_coroutine_is_fused`, and
`nl-stack-safety-coroutine`'s `depth`).

## 8. Multiple-library correctness

### Symbols

The library's object is `ld -r` of the program object and the runtime
archive. `objcopy --keep-global-symbols` then leaves exactly the public C
functions global (`native/library.tcl:160-164`; the list is
`PublicNames`). Every runtime function, `botlish_fn_N`, the record and the
descriptor are local symbols of that one object.

Two libraries therefore carry two private runtime copies:

* They share no code, no static data and no thread-local.
* Their names collide only if their public names do, which is a user's
  choice of `NAME` (a prefix). The library's own duplicate check covers its
  exports (LIBRARY-SYMBOL).
* A shared library exports exactly the same names.
* `nl-symbols` reads `nm`: the archive's global defined symbols equal the
  header's functions, with no `botlish_`, `rt_` or Rust symbol among them.

### Runtime metadata

Each Vm holds its own `Rc<ProgramInfo>`, constants, statics, frame map and
heap.

* **The active-program thread-local.** The runtime's one thread-local
  "program" (`vm.rs:101`), which display and hashing read, is set for each
  call (`ProgramScope`, `library.rs:226`; `vm::swap_current_program`).
  * Each library has its own copy of that thread-local, as of every runtime
    static, because its runtime is private.
  * So a library called from inside another library's call cannot change
    the outer call's program. `nl-nested-libraries` shows an enum in the
    outer error's message (`Color::Green`) after the inner library, whose
    enum table differs, ran inside the call.
  * The scope also restores the previous program after the call. That
    matters only where programs share one runtime (the driver's JIT), never
    in a library, so the mutant that drops the restore is equivalent
    (section 15).
* **Other process-wide state** was examined in the runtime:
  * the coroutine stack pool (per thread, memory only, per library copy);
  * the table-hash key (per library copy);
  * the overflow guard's statics, which a library never installs.

  None of it is shared between libraries, because each library has its own
  copy of all of it.

### GC

Every call sets `Vm::stack_ceiling` to the frame record of the runtime's
non-inlined `enter` (`library.rs:250`; `framewalk::frame_record`). The
collector's walk of the current stack, and of a coroutine's resumer, stops
there (`vm.rs:494-506`). Host frames above the call (C, Tcl, Hermes) are
never read as Botlish frames.

* `nl-coroutine-inside` runs an export that drives a recursive yielding
  function on the general coroutine runtime. Fusion keeps it ("its handle
  reaches a call fusion does not follow"). That is 201 calls, allocating on
  both stacks, under GC stress.
* `nl-walk-boundary` makes the boundary observable.
  * Instance `first` holds a MutableVector across a C call (a safepoint).
    The C callback, compiled with frame pointers, runs instance `second` of
    the same library, which collects.
  * The collector marks objects with a header bit and assumes every bit is
    clear when a collection starts. A walk that climbed past `second`'s
    call would mark `first`'s vector in `first`'s heap.
  * `first` would then push into the vector and, at its next collection,
    skip the marked vector and free the new elements.
  * With the ceiling, `outer` returns 28 three times. The mutant without
    the ceiling (section 15) shows the difference.

### Results

Each of these tests runs its C program twice, plainly and under
`BOTLISH_NATIVE_GC_STRESS=1`, and requires identical output (`nlRunBoth`).

* **`nl-two-libraries`.** Two libraries from different sources, both
  defining an error `Negative` with different payloads and both exporting
  `twice` and `tag`. 300 alternating rounds, with allocating String
  results, gave the right values; each library's error has its own payload.
  One library's buffer released through the other is refused (status 4).
* **`nl-two-libraries-shared`.** The same as shared libraries, linked
  `-lone -ltwo`: `42 63`.
* **`nl-two-instances`.** Two instances of one library alternate 300
  calls. One is destroyed and recreated mid-way, and the other and the
  first's earlier result are unaffected.
* **`nl-nested-libraries`.** As described under runtime metadata.
* **`nl-threads`.** Four instances on four threads. WRONG-THREAD for a
  foreign thread's call and destroy.

For contrast, the census's two libraries linked "with no diagnostic" and
returned a garbage value.

## 9. Artifacts and public APIs

### The Tcl API (`native/library.tcl:80`)

```tcl
native::library HIR -name NAME -out DIR ?-exports NAMES? ?-shared 0|1? ?-target T? ?LOWERING OPTIONS?
# -> {static DIR/libNAME.a shared DIR/libNAME.so header DIR/NAME.h
#     manifest DIR/NAME.manifest.json exports RECORDS}
```

The program's and the library's problems are raised through
`core::raiseDiagnostics` with the errorcode `{NATIVE LIBRARY KIND}`, each
with a location. `-target` accepts the host's target only: any other, or a
program built for another, is `NATIVE TARGET`, and a host that builds no
libraries is `NATIVE UNSUPPORTED library`.

### The command line

```sh
tclsh9.0 main.tcl -emit-native-library NAME [-export FUNCTION ...] [-out DIR] FILE.bot
```

This prints one line per artifact (`static:`, `shared:`, `header:`,
`manifest:`). `cliOptions`, the `cli.options` topic and main.tcl's header
document it (`nl-main-cli`, `tests/main-cli.test`).

### Files

| File | Contents |
|---|---|
| `libNAME.a` | one object: the program and a private runtime; the public C names global |
| `libNAME.so` | the same object linked `cc -shared -Wl,-z,defs -Wl,--gc-sections`; soname `libNAME.so` |
| `NAME.h` | the C interface: lifecycle, statuses, field types, error accessors, `NAME_bytes`, one prototype per export with its Botlish signature as a comment, and the contract of section 6 in prose |
| `NAME.manifest.json` | the same interface as data |

A static library's consumer links it with the system libraries the
manifest's `link` lists: `-lgcc_s -lutil -lrt -lpthread -lm -ldl -lc`, the
Rust standard library's on glibc.

### A representative C caller

The pattern of every test and of the JSON probe:

```c
#include "chk.h"

chk_instance *in; chk_error *e = NULL; int64_t r;
if (chk_create(&in, &e) != chk_STATUS_OK) { /* read e, chk_error_release(&e) */ }
if (chk_checked(in, -5, &r, &e) == chk_STATUS_DECLARED) {
    const uint8_t *id; size_t len; int64_t code;
    chk_error_identity(e, &id, &len);                    /* "Rejected" */
    chk_error_field_int(e, 0, &code);                    /* -5 */
    chk_error_release(&e);
}
chk_destroy(in);
```

### The manifest

`library::Manifest`, `native/library.tcl:429`. It is generated from the
export records and the compiler's tables, never from symbols or source.
Its keys are written in a fixed order.

```json
{
  "schema": 1, "kind": "botlish-native-library", "library": "rnprobe", "abi": 1,
  "target": {"name": "linux-x86_64", "triple": "x86_64-unknown-linux-gnu"},
  "artifacts": {"static": "librnprobe.a", "shared": "librnprobe.so", "header": "rnprobe.h"},
  "link": ["-lgcc_s", "-lutil", "-lrt", "-lpthread", "-lm", "-ldl", "-lc"],
  "threading": "thread-affine",
  "statuses": {"ok": 0, "declared": 1, "runtime": 2, "boundary": 3, "invocation": 4, "internal": 5},
  "fieldTypes": {"int": 1, "bool": 2, "float64": 3, "str": 4, "other": 5},
  "types": {"int": {"c": "int64_t", "rule": "..."}, "str": {"c": "const uint8_t *, size_t", "result": "rnprobe_bytes", "rule": "..."}, ...},
  "lifecycle": {"create": "rnprobe_create", "destroy": "rnprobe_destroy", "initialization": "..."},
  "api": ["rnprobe_create", ...],
  "exports": [
    {"name": "require_positive", "module": "", "symbol": "rnprobe_require_positive",
     "botlish": "require_positive(n: int) -> int errors NotPositive",
     "params": [{"name": "n", "type": "int", "c": ["int64_t"]}],
     "result": {"type": "int", "c": "int64_t *"},
     "errors": [{"name": "NotPositive", "fields": []}]}
  ]
}
```

It has no package-manager, React Native or plugin field. `nl-manifest`
reads it with `lsp/json.tcl`'s parser and checks its facts against the
header. `rnpackage.tcl` reads it the same way.

## 10. JSON/Tcl validation

`audit/compiler-service/probes/export/` was migrated.

* **`exports.bot`.** Its functions are `exported c fn`s over the unchanged
  `json_tokens.bot`: `token_count`, `token_table`, `shout`, `checked`,
  `churn` and `sample`. The file holds no top level and no `argv()`.
* **`run.sh`.** Builds `bj` with `main.tcl -emit-native-library bj`.
* **`probe.c`.** The hand-written Tcl adapter includes only `bj.h` and links
  only `libbj.a`. Its `Init` creates the instance; the interpreter's
  deletion, or `bj::reset` (which then creates a new one), destroys it. A failed call becomes a Tcl error whose errorcode
  is `{BOTLISH STATUS IDENTITY FIELDS}`, read from the error accessors.
* **`probe.tcl`** covers the brief's list:
  * counts, short and long (10,000-character) input, malformed input, a
    raw newline, UTF-8 (`"ä😀"`), invalid UTF-8;
  * string results, an empty one, and one with a NUL inside;
  * declared errors with payloads, and an out-of-range result;
  * 20,000 repeated calls and allocation pressure (`churn`);
  * results and errors kept across collecting calls;
  * destroy and re-create.

Full output: `audit/compiler-service/results/export-probe-library.txt`.

| Check | Census (stand-in, `results/export-probe.txt`) | Now (`results/export-probe-library.txt`) |
|---|---|---|
| `[1, 2, 3]` | 6 (defect) under the first version, 7 with `argv()` | 7, no workaround |
| `"abcdefghij"` | "malformed at 8" (defect) | 1 |
| long input (10,000 chars) | not tested | 3001 |
| malformed at 6 | `-7` (an in-band integer) | `DECLARED json_tokens::Malformed {at 6}`: identity and field as data |
| invalid UTF-8 | status 3 | `BOUNDARY ARGUMENT-NOT-UTF8 {argument 0}` |
| `checked(-5)` | `-10` (defect); then errorcode `{BOTLISH Rejected}` and the payload only as text | `DECLARED Rejected {code -5}` |
| `checked(2**62)` | not tested | `BOUNDARY RESULT-OUT-OF-RANGE` |
| `shout` with a NUL inside | not tested | 4 bytes |
| an error kept across collections | not possible (thread-local last error) | intact |
| destroy and create | not possible (one Vm per thread, never freed) | works |
| 20,000 × `token_count` (193 bytes) | 35.8 µs per call, RSS 14 → 19 MiB | 37.4 µs per call, RSS 14 → 15 MiB |
| the same under GC stress | 111.3 µs | 85.0 µs |
| everything under GC stress | identical | identical |

## 11. React Native compatibility

### Reused unchanged in role

* the package generator (`audit/react-native/tools/rnpackage.tcl`);
* Codegen;
* React Native's own `TurboModule`, `TurboModuleBinding`,
  `LongLivedObject` and `jsi-utils` sources;
* Hermes at React Native 0.88's pin;
* the harnesses `host/host_main.cpp` (unchanged) and `host/probe.js` and
  `host/async.js` (unchanged).

### Mechanical updates

* **`probe/rnprobe.bot`.** `exported c fn` `add`, `reverse`,
  `require_positive`, `same`, `pick`, `depth`. No top level.
* **`rnpackage.tcl`.** Reads `-manifest NAME.manifest.json` (with
  `lsp/json.tcl`) instead of libmode's `.exports`. Library and link names
  come from the manifest. The generated adapter now:
  * creates its instance lazily on the JS thread and destroys it in the
    module's destructor;
  * passes the instance to every call;
  * releases `str` results after copying them;
  * builds a JS `Error` whose `code` is the library's identity and whose
    `fields` object holds the payload. BOUNDARY becomes `RangeError` or
    `TypeError`.

  The adapter keeps its own JavaScript safe-integer checks: that is
  adapter policy. Its "unavailable" C stubs, used for an ABI without a
  library, implement the new API. Android CMake and the iOS podspec name
  `libNAME.a`.
* **`tools/host-spike.tcl`.** Builds the library with `main.tcl
  -emit-native-library rnprobe` and links the archive with the manifest's
  `link` libraries.
* **`host/host_async.cpp`.** The Promise module's worker thread creates its
  own instance when it starts, passes it to each job and destroys it when it
  stops. This is the thread rule: the instance belongs to the worker. The
  async harness's errors are read from error objects.

### Run on this container

React Native 0.88.0 library project, Hermes `hermes-v260318099.0.4`
(Release), folly v2024.11.18.00 headers, clang 18:

```text
add(2, 3) => 5
add(-7, 2**52) => 4503599627370489
add(2**53 - 1, 1) threw RangeError BOTLISH_INT_RANGE "add: the result is not a safe integer"
add(1.5, 1) threw TypeError BOTLISH_ARGUMENT "add: argument 0 must be a safe integer"
add(NaN, 1) threw TypeError BOTLISH_ARGUMENT "add: argument 0 must be a safe integer"
add("2", 1) threw Error undefined "Exception in HostFunction: Value is a string, expected a number"
add(1) threw Error undefined "Expected argument in position 1 to be passed"
reverse("héllo, wörld") => "dlröw ,olléh"
reverse("a😀b") => "b😀a"
reverse("\ud800") => "�"
reverse("") => ""
requirePositive(5) => 5
requirePositive(-1) threw Error NotPositive "requirePositive: uncaught propagated error: <error NotPositive>"
depth(1000) => 1000
same("añb", "añb") => true
same("a", "b") => false
pick(true, "left", "right") => "left"
pick(false, "left", "right") => "right"
pick(1, "left", "right") threw Error undefined "Exception in HostFunction: Value is a number, expected a boolean"
100000 reverse calls, last => "y99999x" in 94 ms
depth(1000000) returned a [object Object] after 0 ms
depth(1000000) => 1000000 after 85 ms
reverse("héllo, wörld") => "dlröw ,olléh"
1000 queued reverse calls, last => "é999x"
tearing down with 1 JS task(s) unrun
runtime, module and Botlish worker torn down
```

* The output is line for line the census's (REACT-NATIVE-TARGET-CENSUS.md,
  section 9), except the timings.
* It ran with `-stack-kib 512` (the JS thread's stack of an iOS release
  build), and again with `-gc-stress 1`: the same lines, the 100,000 calls
  in 343 ms.

The pipeline the brief names now holds end to end on the host:

```text
Botlish source -> -emit-native-library -> archive + header + manifest
  -> rnpackage.tcl -> Codegen and the C++ adapter -> Hermes -> Botlish
```

### Pending

The mobile runs. `.github/workflows/react-native-probe.yml` built its
Android and iOS libraries with `libmode.tcl`, which no longer runs against
the tree: the shared startup removed the generated startup it captured.

* Native libraries build for Linux glibc hosts only.
* A mobile library needs the runtime built for an Android or iOS target,
  the NDK's or Apple's link, and on iOS a Mach-O object. That is outside
  this milestone.
* The workflow is therefore history:
  * it now runs only by hand;
  * every job checks out the census's tree (`CENSUS_REF`, the commit before
    this milestone);
  * the census's mobile evidence stays reproducible.
* `libmode.tcl`, `probe/standin.c` and `ci/` are marked as history, and
  `audit/react-native/README.md` says which file is which.

## 12. Performance and size

All figures are single runs on a shared 4-core container. Treat
differences under about 20% as noise.

| Measure | Census (stand-in) | Now |
|---|---|---|
| Building the probe library (`rnprobe.bot`, six exports) | 1.5 s | 0.75 s wall (`main.tcl -emit-native-library`) |
| JSON `token_count`, 193 bytes | 35.8 µs per call | 37.4 µs |
| JSON `token_count`, GC stress | 111.3 µs | 85.0 µs |
| 100,000 `reverse` calls from Hermes | 77 ms (77 to 125 ms across runs) | 94 ms |
| the same under GC stress | | 343 ms |

The library call adds work the stand-in skipped:

* two registry lock operations (check-out, check-in);
* the scoped program swap;
* a `malloc`ed result copy and its release.

That is about 0.2 µs per `reverse` call against the census's best run, and
is within its range across runs. Nothing was optimized for this
milestone.

Sizes, x86-64, for `rnprobe.bot`:

| Artifact | Census | Now |
|---|---|---|
| static archive | 34.9 MB (with debug info), 15.6 MB stripped | 13.3 MB (debug info stripped by the build), 4.5 MB gzipped |
| shared library | | 1.17 MB file, 924 KB text |
| C program calling every export, stripped | about 525 KB text (with that day's runtime) | 1.94 MB text as linked; 923 KB with `-Wl,--gc-sections` in the consumer's link |
| today's executable of the same functions (rustc-linked) | | 936 KB text |

* With section collection, a library's footprint is the executable's.
  Without it, a consumer links the whole runtime.
* The build cannot collect sections for the consumer. GNU ld 2.42's
  `ld -r --gc-sections` (rooted at the public names) turned the Rust
  standard library's weak references (`posix_spawn_file_actions_addchdir`,
  which glibc 2.39 lacks) into strong ones, and the consumer's link failed.
* The shared library is linked with `--gc-sections`. For a static
  archive, a consumer may pass `-Wl,--gc-sections` to its own link
  (`native/library.tcl`'s comment says so).

## 13. Limitations

* **Stack safety: Botlish recursion only.**
  * Botlish code runs on the caller's thread and stack, with no guard: a
    library installs no signal handler and never calls `_exit`, and the
    executable's guard is not used.
  * Botlish recursion is bounded by a check in its functions (section 7,
    "Stack safety"): exhausting the stack that way is NATIVE LIMIT STACK,
    and the instance goes on.
  * A C function or a runtime helper that exhausts the check's reserve by
    itself, or recursion on a stack the instance did not make, still ends
    the process with SIGSEGV. There is no status and no recovery there.
  * Before the check, measured with `rnprobe_depth` (non-tail recursion)
    from a plain C caller, with the census's figures unchanged (section 7
    has the figures with it):

    | Caller's stack | Largest depth that returned | First that crashed |
    |---|---|---|
    | 512 KiB | 10,000 | 20,000 |
    | 1 MiB | 20,000 | 30,000 |
    | 8 MiB | 150,000 | 200,000 |

  * A caller that needs deep recursion still gives the call a large
    stack, as `host_async.cpp` does with a 256 MiB worker that owns its
    instance: the check refuses deep recursion, it does not make room
    for it.
  * Recovering from an overflow in C or the runtime (a library-owned
    stack or a guard per instance) belongs to the thread/actor milestone.
* **Hosts.** Linux glibc only: x86-64 tested here, AArch64 in CI
  (section 1). No macOS, Windows, musl or mobile libraries.
* **Values.** Only int, bool, Float64, str and unit cross. No Lists,
  structs, maps, bytes buffers, callbacks or handles to Botlish objects.
  A payload field of another type is `FIELD_OTHER`.
* **Calls.**
  * Synchronous only.
  * One call at a time per instance, on its creating thread.
  * Reentry into the same instance is refused rather than supported.
* **Exports.**
  * Environment-free top-level functions only: no captures, contexts or
    coroutine suspension across the boundary. A coroutine inside a call is
    fine (`nl-coroutine-inside`).
  * Every boundary type is declared. Library modules' exports are
    exported by every library that imports them (`nl-export-imported-module`);
    there is no per-library selection of module exports beyond `-exports`
    for the entry program.
* **Size.** Each library carries its own runtime copy (section 12). Many
  Botlish libraries in one process pay for several runtimes, which is the
  price of their isolation.
* **Panics.** A runtime panic inside a call becomes `STATUS_INTERNAL`, but
  the instance's state after it is not guaranteed. Destroy it.
* **The ABI fingerprint** ties a library's program object to the exact
  runtime build it was linked with. That is right for a static archive.
  It means a library must be rebuilt with its runtime, never relinked
  against another.

## 14. Next milestone

The minimum for actor-aware embedding:

1. **An owner for instances other than the creating thread.** An actor's
   event loop that creates, calls and destroys its instance. The C
   signatures need no change: the thread check becomes the owner check.
2. **A library-owned stack per instance or per owner,** with the overflow
   guard on that stack and an embedded policy: report a status and poison
   the instance, never `_exit` or abort the host. Botlish recursion is
   bounded already (section 7, "Stack safety"); this gives deep recursion
   room on small host threads and covers an overflow in C or the runtime.
3. **Asynchronous calls.** Post a call to the owner, and complete it
   through a callback or a polled completion: what `host_async.cpp`
   hand-builds today.
4. **Byte-buffer and packed-table results.** For the JSON bridge's token
   tables: one more boundary type, `bytes`, with the same ownership rules.

For mobile targets, after that:

1. The runtime built for the Android and iOS Rust targets. The census's
   one-line cfg patch is still needed.
2. A library link for each: the NDK's lld for Android, ELF like Linux, so
   `ld -r` and `objcopy` carry over. Apple's ld for iOS needs a Mach-O
   object, an `-exported_symbols_list` in place of `objcopy`, and the
   platform tag the census rewrote.
3. Then `react-native-probe.yml` back on the current tree, running the
   compiler's libraries in place of the census's stand-in.

## 15. Validation: tests, probes, mutation results

### New: `tests/native-library.test` (28 tests)

Every behavior test compiles real C with `cc -Wall -Werror` against the
generated header and archive only, in a directory whose path contains a
space. It runs the program twice, plainly and under GC stress, and requires
the same output (all but `nl-walk-boundary`, below).

* **Export roots.**
  * `nl-export-root-checked`, `-token-count` (with an interpreter oracle),
    `-no-caller`, `-internal-stays-optimized`;
  * `nl-export-imported-module` (a module's export with a namespaced error,
    `greeting::TooLong length=11`).
* **ABI.** `nl-abi-types`, `nl-abi-results-survive`.
* **Lifecycle and threads.** `nl-lifecycle`, `nl-threads`, `nl-reentrant`,
  `nl-coroutine-inside`, `nl-walk-boundary` (run plainly only: its
  collections need real heap growth, and GC stress clears the marks before
  any push).
* **Stack safety** (added after the milestone, section 7).
  `nl-stack-safety`, `nl-stack-safety-coroutine`,
  `nl-stack-safety-foreign-stack`.
* **Composition.** `nl-two-libraries`, `nl-two-instances`,
  `nl-two-libraries-shared`, `nl-nested-libraries`, `nl-symbols` (`nm`).
* **Front end and tools.**
  * `nl-front-end-diagnostics`, `-syntax`, `-runs-everywhere`, `-hir-text`;
  * `nl-library-checks`, `nl-library-export-list`, `nl-manifest`,
    `nl-main-cli`.

All 25 milestone tests passed on Linux x86-64; the whole file took 13 s.
With the three stack-safety tests, all 28 pass.

### Existing suites run after the change

All pass.

* **Native and executables.**
  * `native-executable.test` 18/18, `aot-stub-linker.test` 6/6, both also
    under GC stress;
  * the Rust unit tests: `cargo test --release --lib` 299, `--bin
    botlish-native` 79.
* **Front end and interchange.** `hir-interchange` 11, `hir-cache` 17,
  `syntax-recovery` 33, `diagnostic-recovery` 51, `hir-syntax` 12,
  `hir-specialize` 31, `hir-aot` 33.
* **Surface.** `surface-parser` 139, `surface-lowering` 98,
  `surface-modules` 37.
* **Static and golden.** `static-economics` 87, `static-compile` (its
  census: 111 DiagnosticCode cases), `golden` 9, `golden-framework` 42.
* **Command line and reference.** `main-cli`, `compilerpedia` (`check`:
  793 topics, 593 examples, 0 problems).
* **The warning gate** (`audit/refactor/tools/gate.tcl`: passed).
* **C calls and linked runs**, which go through the shared startup:
  `c-ffi` 115 (5 skipped by constraint), `c-ffi-error-capture` 27,
  `c-pointer-borrowing` 62, `c-byte-borrowing` 19 (1 skipped), `argv` 71
  (6 skipped), `native-program-output` 11; `tests/platform/aot-facts.tcl`:
  every fact as recorded.
* **The compiler service and the language server**, which report the new
  diagnostics: `compiler-service` 54, `lsp` 70.
* **HIR interchange** (the block field `exported c` is new HIR text):
  * `audit/hir-interchange/tools/roundtrip.tcl -via interchange`: 12
    suites, 108 artifacts and outcomes, 0 differ;
  * `-via cache`: 120, 0 differ;
  * `audit/hir-interchange/tools/mutate.tcl`: 27 mutants, 27 killed.

### CI on the branch

Dispatched or triggered on `ccr-2d88975d-17ru75`, at its first commit
(f1033617):

| Workflow (run) | Result |
|---|---|
| `tests.yml` (40026039279), Linux x86-64 | compile, cranelift and cranelift-generic coverage, Rust unit tests, stub-linked executables, warning gate, method-filter audit, golden shards 1-4: success. interp: success (9,295 tests, 0 failed; none skipped for `nativeLibraries` or `nm`). Every job: success. (Its GC-stress job runs on pushes to main only.) |
| `tests-arm64.yml` (40026035898), Linux AArch64 | every job success (section 1) |
| `macos-arm64.yml` (40026023595) | success: the driver and runtime with this milestone's code build, and their tests pass, on macOS AArch64 (where libraries are not offered) |
| `windows-x86_64.yml` (40026023638) | smoke, root plans and acceptance shards 1, 3 and 4: success. Shard 2 failed in `tests/coroutine-fusion.test` (`cf-executable` and the fusion-site tests), which expect native coroutines Windows lacks; main's own run 40009251881 fails identically, so it is not this milestone's |

### CI on main

The milestone merged with main (the collections, place parameters, the
method filter and the coroutine-fusion constraints) reached main as
5cc188e4. Every workflow the push started passed:

| Workflow (run) | Result |
|---|---|
| `tests.yml` (40078033458), Linux x86-64 | every job success, the GC-stress job (pushes to main only: the Rust tests and the whole suite with `BOTLISH_NATIVE_GC_STRESS=1`, `tests/native-library.test` among them) included |
| `tests-arm64.yml` (40078033418), Linux AArch64 | every job success, its GC-stress job included |
| `macos-arm64.yml` (40078033514) | success |
| `windows-x86_64.yml` (40078033431) | success: with main's constraints `tests/coroutine-fusion.test` passes, so the shard that failed on the branch passes |
| `static-decisions.yml` (40078033539) | every job success: batched and sequential agree on every golden suite (`compare.tcl` exits 1 on a DISAGREE or a DOES NOT COMPILE) |
| `single-executable.yml`, `icy-tower.yml`, `c-bindgen.yml`, `bench.yml`, `scalar-asm-audit.yml` | success |

### Probes

* the JSON/Tcl probe (section 10), plainly and under GC stress;
* the React Native host spike (section 11), plainly and under GC stress,
  on a 512 KiB stack;
* the stack-depth measurements (section 13).

### Mutation results

`audit/native-library/tools/mutate.tcl` holds 26 mutants (`mutants.txt`;
20 from the milestone, six from stack safety, section 7),
each a deliberate bug of one rule. Each runs in a private tree with its
own native build. The detectors are:

* `cargo test --lib program`;
* `tests/native-library.test`;
* `tests/aot-stub-linker.test`.

| Mutant | The bug | Killed by |
|---|---|---|
| export-root-specialized | an export is the instance its call sites specialized (`checked(-5) = -10`) | 18 tests, `nl-export-root-checked` among them |
| export-context-accepted | an export requiring a context is accepted | `nl-front-end-diagnostics` |
| library-top-level-accepted | an entry file may hold statements | `nl-library-checks` |
| symbols-global | runtime and program symbols stay global | `nl-symbols`, `nl-two-libraries`, `nl-nested-libraries` |
| error-table-unwritten | no NIR error table: identities become numbers | 7 tests |
| float-argument-converted | a `double` argument converted to an integer | `nl-abi-types` |
| utf8-unchecked | a `str` argument is not validated | `nl-abi-types` |
| nonfinite-admitted | NaN and infinities enter | `nl-abi-types` |
| int-result-wrapped | an out-of-range Int result becomes -1 | `nl-abi-types`, `nl-export-root-no-caller` |
| arguments-unrooted | a converted argument is no root while the next allocates | `nl-abi-types` (three `str` arguments, GC stress) |
| declared-identity-numeric | a declared error's identity is its number | 7 tests |
| payload-dropped | a declared error carries no fields | 7 tests |
| released-buffer-kept | release leaves the struct pointing at freed memory | `nl-abi-types` |
| foreign-buffer-freed | a buffer the library never made is freed | `nl-abi-types`, `nl-two-libraries` |
| wrong-thread-accepted | another thread's call runs | `nl-threads` |
| reentrant-accepted | a call from inside a call runs | `nl-reentrant` |
| destroyed-handle-live | a destroyed instance stays registered | `nl-lifecycle` |
| stack-ceiling-unset | the walk climbs into the host's frames | `nl-walk-boundary` |
| stack-limit-never-set | an instance checks against a zero limit | `nl-stack-safety`, `-coroutine`, `-foreign-stack` |
| stack-check-not-emitted | the driver emits no prologue check | the same three |
| stack-check-callers-unchecked | a call that can fail for the stack is proven infallible | the same three |
| stack-limit-not-followed | a coroutine is checked against the thread's limit | `nl-stack-safety-coroutine` |
| stack-limit-foreign-stack | a call on a host-made stack is checked against the thread's limit | `nl-stack-safety-foreign-stack` |
| export-dropped-by-fusion | fusion empties an export only C calls | `nl-stack-safety-coroutine` |
| descriptor-errors-dropped | the descriptor's error table read as empty | `program_descriptor_round_trips`, 7 tests |
| fingerprint-unchecked | a record of another runtime build accepted | `linked_program_refuses_a_foreign_record` |

The first run, against the test file as it then was, left four
survivors.

* **`export-context-accepted`.** The diagnostics test had no export that
  requires a context. It gained one.
* **`arguments-unrooted`.** No export took two `str` arguments, so no
  conversion allocated while an earlier argument was unrooted.
  `nl-abi-types` gained `joined(a, b, c)`.
* **`stack-ceiling-unset`.**
  * No test had a collection while another instance's Botlish frames sat
    above the call. `nl-walk-boundary` (section 8) was written for it.
  * With frame pointers in the callback (the test compiles it so), the
    walk reaches the outer instance's frame, marks its objects, and the
    mutant's `outer` returns the wrong value.
  * Analysis, not measured: a callback without frame pointers hides the
    outer frame's return address from the walk, so the defect would stay
    latent.
* **`program-scope-not-restored`** (ProgramScope's drop not restoring the
  previous program) is equivalent.
  * A library's runtime is a private copy with its own thread-local, so no
    other program ever shares it.
  * It was removed from `mutants.txt`, whose header records why.

The final run, all 20 mutants against the final tests (the table's
column): 20 killed, 0 survived.

Stack safety (section 7) added the six mutants after `stack-ceiling-unset`
in the table and moved `stack-ceiling-unset` to the new code of `enter`.
Run with `-only` against the final tests: 7 killed, 0 survived. The
milestone's other 19 were not rerun: neither the code they mutate nor the
tests that killed them changed (the test file only gained three tests),
and every one still applies. It also
changed the call-effect summary that two mutants of
`audit/native-stack/tools/mutants.txt` edit: `effects-fallible-again` and
`effects-infallible-on-fallback` now mutate the summary with the
library's term in it, keeping their rules, and were rerun: both killed
(the `nir::effect_tests`).

The existing harnesses' mutants were checked against the changed files.
Two no longer applied and were updated to the code they mutate, keeping
their rule:

* `audit/native-aot/tools/mutants.txt`'s `startup-no-stack-maps` now
  removes the stack maps from `program::instantiate`, which both startups
  and libraries share. The harness's whole run after the change: 20
  mutants on linux-x86_64, 16 killed, 0 survived, 4 skipped (other hosts'
  code), `startup-no-stack-maps` among the killed.
* `audit/target-model/tools/mutants.txt`'s `driver-runs-any-target`
  includes `library` among the commands that check the target; run with
  `-only`: killed (`tm-main-native-target`, `tm-native-driver-boundary`,
  `tm-native-refuses-another-target`).

`audit/native-stack/tools/mutants.txt`'s `gc-walk-half-stack` follows the
walk's new `main_stack` bound and was rerun: killed.

## 16. What to run when changing this

The files:

* the export rules: `hir/exports.tcl`;
* `exported` in `surface/parser.tcl`, `surface/recover.tcl`,
  `surface/lower.tcl`, `hir/syntax.tcl`, `hir/resolve.tcl`,
  `hir/format.tcl`, `hir/read.tcl`;
* export roots: `hir/specialize.tcl`'s `ProgramValues`;
* lowering: `native/lower.tcl`'s `export` and `error` lines;
* the library build: `native/library.tcl`;
* the driver: `native/src/nir.rs` (`Boundary`, `ExportDecl`),
  `native/src/codegen/library.rs`, `native/src/codegen/mod.rs`'s
  `emit_object_with` and `define_program_record`, `native/src/main.rs`'s
  `library` command;
* the runtime: `native/src/runtime/program.rs`,
  `native/src/runtime/library.rs`, `Vm::stack_ceiling` and the walk's bound
  in `native/src/runtime/vm.rs`;
* stack safety (section 7): `nir::check_stack_limit` and the call-effect
  summary in `native/src/nir.rs`, `codegen::roots`'s `stack_check`,
  `codegen::clif`'s `prologue_stack_limit`, `NativeStack::stack_limit`,
  `Vm::stack_limit`, `check_stack_limit`, `stack_limit_at` and
  `publish_active_stack`, `enter` and `create` in
  `native/src/runtime/library.rs`;
* `codegen::fusion`'s `drop_unreferenced` (its roots: the program
  function and the exports).

What to run:

* `tests/native-library.test`;
* `tests/native-executable.test` and `tests/aot-stub-linker.test` (the
  shared startup), also under `BOTLISH_NATIVE_GC_STRESS=1`;
* `cargo test --release --manifest-path native/Cargo.toml --lib program`;
* `audit/native-library/tools/mutate.tcl`: every mutant in its
  `mutants.txt` must still apply and be killed. Update a mutant's text when
  you change the code it mutates, keeping it a mutant of the same rule.
* For a change to the startup: `audit/native-aot/tools/mutate.tcl` too.
* For a change to the call-effect summary: `audit/native-stack/tools/mutate.tcl`
  (its `effects-*` mutants) too; for one to fusion, what AGENTS.md lists
  for coroutine fusion.
* For the probes: `audit/compiler-service/probes/export/run.sh` and
  `audit/react-native/tools/host-spike.tcl` (section 16 of
  REACT-NATIVE-TARGET-CENSUS.md has the latter's prerequisites).
