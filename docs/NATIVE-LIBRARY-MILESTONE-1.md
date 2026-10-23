# NATIVE-LIBRARY-MILESTONE-1.md

Native libraries: Botlish functions a C program calls. `exported c fn`
declares a function's C entry point; `main.tcl -emit-native-library NAME`
(`native::library`) compiles a program into a static library, a shared
library, a C header and a JSON manifest. Each export is compiled as an
independent root under its declared contract; executables and libraries
start from one program descriptor; libraries and their instances share
nothing in one process.

> The rule this milestone keeps: **exporting a function adds a foreign entry
> point and changes nothing else.** Its Botlish callers, every analysis and
> every backend still see an ordinary function. The boundary exposes only
> the ABI it states: int64_t, bool, finite double, UTF-8 bytes, a status, and
> objects the caller owns.

```
exported c fn checked(n: int) -> int errors Rejected:     # calc.bot
    if n < 0:
        fail Rejected {code: n}
    n * 2

$ botlish -emit-native-library calc -library-dir out calc.bot
archive: out/libcalc.a        one object: program, descriptor, C API, runtime
shared: out/libcalc.so        the same object as a shared library
header: out/calc.h            the C interface
manifest: out/calc.json       the machine-readable interface
```

## Contents

1. [Executive result](#1-executive-result)
2. [Starting state](#2-starting-state)
3. [Export-root semantics](#3-export-root-semantics)
4. [Library architecture](#4-library-architecture)
5. [Export syntax and API](#5-export-syntax-and-api)
6. [The C ABI contract](#6-the-c-abi-contract)
7. [Runtime lifecycle](#7-runtime-lifecycle)
8. [Multiple-library correctness](#8-multiple-library-correctness)
9. [Artifacts and public APIs](#9-artifacts-and-public-apis)
10. [JSON/Tcl validation](#10-jsontcl-validation)
11. [React Native compatibility](#11-react-native-compatibility)
12. [Performance and size](#12-performance-and-size)
13. [Limitations](#13-limitations)
14. [Next milestone](#14-next-milestone)
15. [What to run when changing this](#15-what-to-run-when-changing-this)

Tested on: Linux 6.18 x86_64 (a 4-core container), Ubuntu 24.04's glibc
2.39, GNU binutils 2.42 (`ld`, `objcopy`, `ar`), gcc 13.3.0 (`cc`), clang
18.1.3 (the React Native host probe), rustc 1.97.0, cranelift-codegen
0.135.2, Tcl 9.0.1. Linux AArch64 is in the `libraries` capability and its
code paths are the same, but nothing in this report was run on it: that is
CI's arm64 workflow's to show (section 13).

## 1. Executive result

**Implemented**, on Linux glibc. Every completion criterion is met on
linux-x86_64, observed:

* Exports are compiled as independent roots under their declared contracts
  (section 3): the census's two silent defects -- `checked(-5)` returning
  -10 and `token_count` miscounting every input longer than the one its
  top level passed -- are gone, without any call-site workaround. The JSON
  probe's root file has no top level at all.
* The compiler produces the static library, the shared library, the header
  and the manifest itself (`native::library`, `-emit-native-library`).
* Executables and libraries start from one program descriptor; nothing
  captures or edits a generated startup any more (section 4).
* Every C-visible result has stated ownership and release (section 6);
  declared errors keep their canonical identities and payloads as data.
* Two independently compiled libraries in one C executable, alternating
  allocating calls, compute correct results, statically and dynamically
  linked, and under `BOTLISH_NATIVE_GC_STRESS=1` (section 8); two instances
  of one library keep their state apart.
* The JSON/Tcl probe builds with the new facility and runs as a Tcl 9
  extension, also under GC stress (section 10).
* The React Native host probe consumes the new artifact: section 11 has its
  result.
* Executables are unchanged in behavior: the native, executable, stub-linker
  and platform-fact tests pass, and the full local suite (section 15).
* No worker thread, scheduler or implicit concurrency was added: an
  instance belongs to its creating thread, and the library refuses
  everything else (section 7).

**Not done, by scope**: mobile targets (the React Native mobile workflow
now runs, by hand, at the census's revision: section 11), callbacks,
collections or structs at the boundary, asynchronous exports, macOS and
Windows libraries.

## 2. Starting state

Two experiments called Botlish from outside before this milestone:

* **The React Native census's stand-in** (`audit/react-native/tools/
  libmode.tcl`, REACT-NATIVE-TARGET-CENSUS.md "Library mode"). It linked an
  ordinary executable through a pass-through `RUSTC`, captured the
  generated startup crate (the only place ProgramInfo, the constant pool and
  the stack maps existed, spelled out as Rust source), cut its closure body
  out as `new_vm`, and wrapped chosen functions' generic entries
  `botlish_entry_N` in C functions with statuses, a thread-local Vm per
  thread and a `str` result borrowed until the thread's next call. Native
  lowering compiles only what a program reaches, so the file's top level
  had to call every export with its declared types, and the export was the
  instance those calls made; tiny-leaf inlining was turned off so one-line
  functions kept bodies.
* **The compiler service census's export probe** (`audit/compiler-service/
  probes/export/`, COMPILER-SERVICE-CENSUS.md section 8.2): that stand-in's
  library over the JSON tokenizer, linked into a Tcl 9 extension.

What they established: the boundary types (int, str, bool) worked; a
declared error came back as identity and text; GC stress passed with Tcl's
frames below the call; 36 µs per `token_count` call. And one silent defect
(COMPILER-SERVICE-CENSUS.md section 8.2): the exported instance was the one
specialized for the program's own calls. With the top level calling
`token_count("[1, 2]")` and `checked(1)`, the export returned `[1, 2, 3]` ->
6 and `"abcdefghij"` -> "malformed at 8", and `checked(-5)` returned -10,
because `n < 0` had been proven dead for the only call site. The committed
probe worked around it by making every top-level argument depend on
`argv()`. The census named the missing capability: export roots.

Also missing, per the React Native census: a stack bound on a host thread
(`depth(20000)` killed the process on a 512 KiB JS thread, section "Stack
depth"), any isolation between two libraries, an instance lifecycle, and
owned results.

## 3. Export-root semantics

### The rule

An export is called by code no analysis sees, with any value its declared
types admit. `hir::specialize::analyze -roots BLOCKS` (hir/specialize.tcl,
"Export roots" above `ExportRoots`) takes the library's exported blocks and
treats each exactly as a Block value the program hands to an unknown
caller: it is added to the program instance's `values` (the
materialized-block set, hir/specialize.tcl in `Analyze`). Everything else
follows from rules the analyses already had for a materialized Block:

* its **generic instance** is used and lowered whatever its Botlish callers
  do, none at all included, and tiny-leaf inlining into callers never
  removes it (a materialized Block keeps a generic entry);
* that instance is **open** (`InstanceClosed`): no closed-caller theorem
  refines it, and the range analysis folds no caller's argument into its
  entry (`hir::range::OpenInstances`): its parameters assume exactly their
  declared types and full ranges;
* **named-refinement facts** of its block are not derived from its Botlish
  calls (`RefinementFacts` skips roots), since those are not all its calls.

Internal callers are untouched: a Botlish call with keyed arguments still
selects and optimizes its own specialized instance, which nothing foreign
calls. Native lowering passes the roots only for a library
(`native::lower::program -library NAME -exports ...`, native/lower.tcl);
an executable of the same program lowers exactly as before. Exports are
found by resolved block identity (`hir::exports::of`, hir/exports.tcl) and
reach NIR as `export K "SYMBOL" func=F ...` lines naming the root's
function index (native/lower.tcl; `nir::ExportDecl`, native/src/nir.rs),
never by a name in NIR text.

### Evidence the defects are gone

Observed (tests/native-library.test, all passing):

* `nl-root-keeps-the-error-branch`: alpha.bot's `checked` has only the
  Botlish caller `checked(1)`. In the library's NIR the root
  `checked<generic>` keeps the `faildeclared` of `Rejected`; the internal
  instance `checked<int>` the constant caller uses has none (its `n < 0`
  branch is proven dead, as before).
* `nl-root-specialization-unchanged`: the executable of the same program
  lowers its internal calls exactly as before (same instances).
* `nl-root-open-in-range-analysis`, `nl-root-refinement-facts`: the root is
  in the range analysis's open set, and its refinement facts are not its
  callers'.
* The C conformance suite's `roots` section (tests/native-library/
  conformance.c, 16 checks, run statically, shared and under GC stress):
  `checked(-5)` fails with `Rejected {code: -5}`; `checked(21)` = 42;
  `commas` (whose only Botlish caller passes the 6-character `"[1, 2]"`)
  counts `"[1, 2, 3]"`, 20 commas and `""` correctly; `orphan` has no
  Botlish caller and works; `inc`, a tiny leaf inlined into its Botlish
  callers, keeps its entry; an export of an imported module
  (`alpha_util.bot`'s `util_greeting`) reads its module's binding; the
  internal path through the specialized instances still returns its value.
* The JSON probe (section 10): `exports.bot` has no top level, and
  `token_count` is right for every length (2 to a 20,000-element array).

Before (reproduced at the start of this milestone with the stand-in, on the
census's probe with the `argv()` workaround removed): `[1, 2, 3]` -> 6,
`checked(-5)` -> -10, as the census reports.

## 4. Library architecture

### The path

`native::library HIR -name NAME -out DIR ?-exports F...? ?-shared 0|1?`
(native/library.tcl), the one driver; `main.tcl -emit-native-library` is
its command-line client:

1. **Exports** are checked (`hir::exports::verify`, run in every front end
   build by `hir::CheckOnce`; with `-exports`, `hir::exports::select` then
   the same check), and the root file is checked to declare only
   (`LibraryRootStatements`: NATIVE LIBRARY TOP-LEVEL).
2. **Native lowering** with the exports as roots and `library=NAME` on
   NIR's header (native/lower.tcl).
3. **The driver** (Rust, unchanged command line plus the NIR header) emits
   one program object (`codegen::emit_object_with`, native/src/codegen/
   mod.rs): the program's functions, its descriptor
   (`codegen::library::define_descriptor`) and its C API
   (`codegen::library::define_api`).
4. **`ld -r`** joins that object with the runtime's static library
   (`native/target/release/libbotlish_native.a`, a second crate type of the
   native crate, native/Cargo.toml) into one relocatable object, pulling
   only what the program uses; **`objcopy --keep-global-symbols`** makes
   every symbol but the public API local (`--strip-debug` unless `-debug
   1`).
5. **`ar rcD`** archives it (deterministic); **`cc -shared`** links the same
   object as a shared library.
6. The **header and manifest** are written in Tcl from the export records
   (native/library.tcl's `LibraryHeader`, `LibraryManifest`): no Rust writes
   artifact metadata.

### What executables and libraries share

The **program descriptor** (native/src/runtime/program.rs, `Descriptor`):
a data symbol `botlish_program` with a magic word, a format version, the
ABI fingerprint, the function count, a pointer to the encoded
`ProgramData` (ProgramInfo, the constant pool, each function's sizes and
safepoints: the same encoding the stub linker's image uses,
runtime/aotimage.rs) and the table of every function's direct and entry
addresses, filled by relocations. `runtime::program::build_vm` reads it and
builds the Vm -- constants, statics, stack-map table -- for every start:

* a rustc-linked executable: the generated startup is now four lines,
  `aot::run(argv, || program::start(&botlish_program))`
  (codegen/aot.rs's `startup`), with no program data in it;
* a stub-linked executable: `aotimage::Loaded::instantiate`;
* a library instance: `botlish_library_create`.

So "the two startups must build the Vm identically" (AGENTS.md) now holds by
construction. **Every program function is an object-local symbol**
(codegen/clif.rs: `Linkage::Local`): nothing finds one by name, so two
program objects in one link never share one; tests/platform/aot-facts.tcl
checks the object (functions local, the descriptor global) and the
executable.

### The public boundary

Generated by Cranelift in the program object (codegen/library.rs): for
each export a C-convention trampoline `NAME_F(instance, params..., result,
error)` that stores its arguments as machine words on its stack and calls
the runtime's `botlish_library_call(descriptor, instance, k, words, result,
error)`; for each API function (create, destroy, the error accessors,
bytes_release) a thunk that passes the descriptor to its
`botlish_library_*` implementation (runtime/library.rs). The runtime code
is the same in every library; what makes it this library's is the
descriptor argument and the localized copy it is linked into.

## 5. Export syntax and API

```
exported c fn NAME [named "SYMBOL"](PARAMS) -> TYPE [errors E...]:
```

* `exported c` is a function modifier (surface/parser.tcl; `exported`,
  `c` and `named` stay ordinary names elsewhere: `nl-syntax-contextual`).
  `c` is the only ABI; `named "SYMBOL"` states the C symbol (a C
  identifier), else it is `LIBRARY_NAME`. Syntax errors are EXPORT-SYNTAX,
  located (`nl-syntax-errors`): a missing or unknown ABI, `named` without
  `exported`, a symbol that is no C identifier, an export nested in a
  function, loop or branch.
* The representation: the block's `exported {c SYMBOL}` field (hir/
  syntax.tcl's `withExport`, hir/resolve.tcl), printed and read by HIR text
  (` exported c named SYMBOL`, hir/format.tcl, hir/read.tcl; `nl-hir-text`),
  so interchange and the front-end cache carry it.
* `hir::exports::verify` (hir/exports.tcl) diagnoses, at the declaration:
  EXPORT-SIGNATURE (an untyped parameter or result, a type with no C
  representation, flags, a variadic or resume section, a required context,
  a function that may yield), EXPORT-CAPTURE (a capture of the root file's
  top level, which a library never runs; module bindings are fine) and
  EXPORT-SYMBOL (two stated symbols alike). Each has a Compilerpedia topic
  (compilerpedia/topics/libraries.topic) and a static-compile census row.
* **The export list.** `native::library -exports {F ...}` and `main.tcl
  -export F` select top-level functions not declared so; they get the same
  `exported` field (`hir::exports::select`) and the same checks
  (`nl-build-export-list`), so the two forms converge on one
  representation.
* **Visibility, three kinds**: a Botlish module's top-level bindings are
  visible to importers (IMPORTS.md); `direct module` designates raw
  authority (DIRECT-MODULES.md); `exported c fn` adds a C symbol and
  changes neither. An exported function stays an ordinary Botlish function
  to its callers and every backend (`nl-ordinary-function`).

## 6. The C ABI contract

The header states it in full (native/library.tcl's `LibraryHeader`); in
summary:

| Botlish | C parameter | C result | rule |
|---|---|---|---|
| `int` | `int64_t` | `int64_t *` | exact in; a result outside int64_t is BOUNDARY INT-RANGE, never truncated |
| `bool` | `bool` | `bool *` | |
| `Float64` | `double` | `double *` | finite: NaN or an infinity is BOUNDARY NON-FINITE; -0.0 enters as 0.0 |
| `str` | `const uint8_t *, size_t` | `NAME_bytes *` | validated UTF-8 (BOUNDARY UTF-8; surrogates included); NULL with 0 is ""; embedded NULs are characters. The result is the caller's buffer, NUL-terminated beyond `len` |
| `unit` | -- | no result parameter | |

Every function returns an `int32_t` status: `NAME_OK` 0,
`NAME_DECLARED_ERROR` 1, `NAME_RUNTIME_ERROR` 2 (a semantic error, NATIVE
LIMIT STACK, ...), `NAME_BOUNDARY_ERROR` 3 (a value that cannot cross),
`NAME_INVOCATION_ERROR` 4 (a bad handle, thread, reentrance, NULL). The
last parameter, `NAME_error **error`, receives (when non-NULL) an error
object on anything but OK, and NULL on OK.

**Errors are data.** An error holds its status, its identity -- a declared
error's canonical name (`Rejected`, `json_tokens::Malformed`), a runtime
error's code (`NATIVE LIMIT STACK`), `BOUNDARY ...`, `INVOCATION ...` --
a message, and a declared error's payload fields: name, kind (INT, BOOL,
FLOAT64, STR or OTHER) and value, with every field's text too (an Int
outside int64_t is OTHER for `error_field_int` and exact as text). It is
copied out of the Vm when the call fails (runtime/library.rs's `capture`):
the identity comes from the program's error table (the NIR `error` lines),
never from parsing a message, and nothing in it points into a Botlish
heap. It stays valid after later calls and after the instance is destroyed.

**Ownership and release.** `NAME_bytes_release(&bytes)` frees a result
buffer and empties the struct (an empty one is a no-op); a buffer this
library did not return or already took back is INVOCATION_ERROR and nothing
is freed. `NAME_error_release(error)` likewise (NULL is a no-op). Both are
checked against the runtime's registries of live buffers and errors, so a
double release is defined, not undefined (conformance `types`, `errors`,
`invalid`). Release a result with the library that returned it: another
library's release refuses it (`two-libraries`).

**Nothing unwinds into C.** A Botlish error is a status. A Rust panic in
the boundary is caught (`catch_unwind`), poisons the instance (every later
call is INVOCATION POISONED; only destruction works) and is reported as a
runtime error.

**No GC pointer leaves.** Arguments become Botlish values inside the call,
are rooted for its duration, and results are copied into C memory before
the call returns (`botlish_library_call`); the conformance suite keeps
results across collecting calls under GC stress.

The ABI version: `NAME_abi_version()` and `NAME_ABI_VERSION` are 1; the
manifest records it.

## 7. Runtime lifecycle

* `NAME_create(&instance, &error)` builds a Vm from the descriptor
  (`build_vm`) on the calling thread and runs the program's function 0,
  which for a library is the initialization of the modules it imports and
  nothing else (the root file runs nothing: NATIVE LIBRARY TOP-LEVEL, so no
  entry script or argv probe runs). A failing initialization fails the
  creation and leaves nothing behind. Any number of instances may be
  created; each has its own heap, constants, module statics, stack-map
  table and pending-error state.
* `NAME_destroy(instance)` frees the Vm. The instance's record stays in the
  registry, marked destroyed (a few dozen bytes), so its address is never
  reused for another live instance and a stale handle stays detectably
  stale: a call or a second destruction is INVOCATION DESTROYED.
* **Identity.** Every handle is looked up in the runtime's registry first:
  NULL, a pointer that was never an instance, and another library's
  instance (`OTHER-LIBRARY`, by descriptor) are invocation errors.
* **Thread affinity, enforced.** An instance is created, called and
  destroyed on one thread. Threads are told apart by a serial number each
  thread draws once (a thread-local from an atomic counter), never a thread
  id the system may reuse. Another thread's call or destruction is
  INVOCATION WRONG-THREAD and touches nothing (`threads`: the owner thread
  still calls it afterwards). Instances on different threads run at the
  same time (`threads`: four threads, each with its own alpha or beta
  instance).
* **Reentrance**: a call while a call into the same instance runs on its
  thread is INVOCATION REENTRANT (the record's state). Without callbacks
  only a signal handler can do it, so the C suite cannot; the Rust test
  `runtime::library::tests::an_instance_admits_one_call_at_a_time_from_its_own_thread`
  drives the rule itself (reentrance, another thread during and after a
  call, another library's descriptor, a stranger, NULL, a poisoned and a
  destroyed instance), and `every_thread_has_its_own_serial_number` the
  thread serials (section 13).
* **The current program.** The runtime's thread-local current program
  (what printing and error payloads read) is the called instance's for the
  call's duration and restored after (`vm::swap_current_program`).
* **The GC walk boundary.** A call makes its own frame the top of the stack
  its Vm walks (`Vm::set_stack_boundary` with `framewalk::frame_address`),
  so the host's frames above it -- C, Tcl, Hermes -- are never read as
  Botlish frames.
* **Stack safety.** Botlish code runs on the caller's thread and stack. A
  library's NIR says `library=NAME`, which makes every function with a
  Botlish call check its stack pointer against the instance's limit in its
  prologue (`nir::Program::stack_limit_checked`, codegen/roots.rs's
  `plan_checked`, clif.rs's `prologue_stack_limit`): the creating thread's
  stack bound plus a reserve of an eighth of the stack, at least 64 KiB and
  at most 1 MiB. Exhaustion is the runtime error NATIVE LIMIT STACK, a
  status; the instance goes on (`stack`: the main thread, 512 KiB and 1 MiB
  threads). No signal handler is installed and nothing calls `_exit`.

## 8. Multiple-library correctness

**Symbols.** A library archive is one object whose global symbols are its
API and exports only: `nl-build-public-symbols` checks alpha's 34 globals
are all `alpha_*` (no `botlish_*`, `rt_*`, Rust or `std` symbol);
`objcopy --keep-global-symbols` does it, and the shared library exports the
same names. Since program functions are object-local (section 4), two
program objects never collide even before localization.

**Runtime state.** Each library is linked with its own copy of the runtime
(localized), so its statics -- the instance, error and buffer registries,
the thread-serial counter, the current-program thread-local -- are its own:
alpha's registry never sees beta's handles (`OTHER-LIBRARY`), and beta's
release refuses alpha's bytes. Per instance: the Vm (heap, constants,
statics, stack maps, errors, GC roots). ProgramInfo and the function table
come from the instance's own descriptor.

**What locks.** Each library's registries are behind its own mutexes, held
only to check and change a handle's record -- never while Botlish code
runs. No global lock serializes instances or libraries.

**Results** (tests/native-library.test, each a real C executable,
observed):

| test | what | result |
|---|---|---|
| `nl-c-static` | conformance.c linking libalpha.a and libbeta.a; sections roots 16, types 25, errors 23, invalid 11, instances 7, two-libraries 5, threads 3, stack 5, gc 1 | 96 checks pass |
| `nl-c-static-gc-stress` | the same under `BOTLISH_NATIVE_GC_STRESS=1` (smaller loops) | 96 pass |
| `nl-c-shared` | the same linking libalpha.so and libbeta.so | 96 pass |
| `nl-c-json` | json.c over the JSON probe library (section 10) | 15 pass |
| `nl-build-*` | artifacts; public symbols; two builds byte-identical (header, manifest, archive); the manifest; the header compiling as C and C++ alone; the refusals; the export list; the CLI | pass |

`two-libraries` alternates allocating calls between alpha and beta, each
returning strings and errors; `instances` runs two alpha instances with
independent state, destroys one, keeps the other, then creates, uses and
destroys 300 more; `gc` keeps 20 results across 40 collecting calls of both
libraries.

## 9. Artifacts and public APIs

Tcl: `native::library HIR -name NAME -out DIR ?-exports {F ...}? ?-shared
0|1? ?-debug 0|1?` returns `{archive PATH shared PATH header PATH manifest
PATH exports RECORDS}`. Command line:

```
tclsh9.0 main.tcl -emit-native-library NAME ?-library-dir DIR? ?-export F ...? FILE.bot
```

(DIR defaults to the input's directory; paths with spaces work: the JSON
probe and the React Native host probe build into one.) Refusals are NATIVE
LIBRARY NAME, OUTPUT, HOST, ROOT, INPUT, EXPORT, TOP-LEVEL, SYMBOL and TOOL
(`nl-build-errors`; the `error.native-library` topic).

A C caller links `libNAME.a` with the system libraries the manifest's
`link` lists (`-lgcc_s -lutil -lrt -lpthread -lm -ldl` on glibc), or
`libNAME.so`:

```c
#include "calc.h"

calc_instance *in;
calc_error *err;
if (calc_create(&in, &err) != calc_OK) { /* calc_error_message(err, ...) */ }
int64_t out;
if (calc_checked(in, -5, &out, &err) == calc_DECLARED_ERROR) {
    calc_text id;
    int64_t code;
    calc_error_identity(err, &id);          /* "Rejected" */
    calc_error_field_int(err, 0, &code);    /* -5 */
    calc_error_release(err);
}
calc_destroy(in);
```

The manifest (`NAME.json`, deterministic: `nl-build-deterministic`) holds
`format` ("botlish-native-library"), `version` 1, `library`, `abiVersion`,
`target` {name, triple}, `artifacts`, `link`, `statuses`, `fieldKinds`,
`types` (each Botlish type's C representation), `ownership`, `api` (every
API function's symbol) and `exports`: per export its Botlish name, C symbol,
parameters {name, type, C types}, result {type, C type}, declared errors
and C prototype (`nl-build-manifest`). The React Native generator reads
only it and the header (section 11).

## 10. JSON/Tcl validation

`audit/compiler-service/probes/export/` now builds with the compiler:
`exports.bot` declares `token_count`, `tokens`, `shout`, `checked` and
`churn` as `exported c fn` over the unchanged `json_tokens.bot`, with no
top level; `run.sh` runs `main.tcl -emit-native-library bj` into a
directory whose path has a space and links `probe.c` -- which includes only
`bj.h` -- with `libbj.a` into a Tcl 9 extension, one library instance per
interpreter (destroyed with it; `bj::destroy`/`bj::create` for the
lifecycle checks), errors as Tcl errors with errorcode `{BOTLISH STATUS
IDENTITY FIELDS}`.

TBD: run.sh output

`nl-c-json` runs the same library from C (tests/native-library/json.c),
also in the full suite: short and 20,000-element inputs, UTF-8 keys,
malformed input folded into the count and as `json_tokens::Malformed {at:
6}`, invalid UTF-8 refused before the tokenizer runs, 20,000 repeated
calls, a result kept across a collecting call, a destroyed instance
refusing calls, and 500 create-use-destroy cycles.

## 11. React Native compatibility

TBD

## 12. Performance and size

TBD

## 13. Limitations

* **Hosts.** Linux glibc only (`libraries`: linux-x86_64, linux-aarch64);
  AArch64 was not run here. macOS needs Apple's `ld -r` and a symbol
  localization (`-exported_symbols_list`, `nmedit`), Windows a DLL and an
  import library: both are another milestone's. Mobile targets need the
  runtime built for them and the native backend's machine code for them
  (it emits its host's only).
* **Stack safety is a check, not a guard.** Generated code checks its stack
  pointer in every function that calls Botlish code; a runtime function's
  own deep recursion, or one frame larger than the reserve, is not caught,
  and the reserve (an eighth of the stack, 64 KiB to 1 MiB) is what the
  host's frames above a failing call get back. A host thread's stack bound
  is read from glibc (`pthread_getattr_np`); a stack the C library does not
  describe (a coroutine library's, a green thread's) would be wrong.
* **The calling thread.** There is no Botlish-owned thread: deep recursion
  on a small JS thread fails cleanly but fails. `host_async.cpp` shows the
  pattern a host uses today (its own worker thread owning its own instance).
* **Reentrance** is refused by state, tested on the rule itself, never by a
  real reentering call: without callbacks only a signal handler could
  reenter, and nothing here is async-signal-safe (the boundary allocates),
  so a host must not call a library from a signal handler.
* **Boundary types.** int, bool, Float64, str, unit. No collections,
  structs, enums, callbacks, function pointers, handles to Botlish objects,
  or asynchronous calls. A large Int payload field is text.
* **Size.** Every library carries its own runtime and Rust standard library
  (section 12); two libraries in one process carry two.
* **No mutation harness** yet for the library path; its regressions are
  caught by the conformance suite and the executable harness
  (audit/native-aot/tools/mutate.tcl, whose stack-map mutant now mutates
  `runtime::program::build_vm`).

## 14. Next milestone

The minimum for actor-aware embedding:

1. A **Botlish-owned thread** per instance: `NAME_create` with an option to
   start the instance's own thread (stack size chosen by the host or the
   program), the instance bound to it instead of the caller's; calls become
   messages to it. The thread rule above is what makes this an extension,
   not a rewrite: an instance already has exactly one owner thread.
2. **Asynchronous calls**: a call that returns a ticket and completes on the
   instance's thread, with completion delivered through a host callback or
   a poll; the error objects and owned buffers are already
   thread-independent data.
3. **Callbacks** (C function pointers called from Botlish), which make
   reentrance real and need a documented reentrance policy.
4. **A root actor**: the program's entry script becomes the instance's
   initial behaviour on its thread (today the root file must be empty).

For mobile targets, after that: the runtime's static library for the
Android and iOS Rust targets, machine code for a target other than the
host (or a native build on each), the platform's relocatable link and
symbol localization (`ld.lld -r` with `llvm-objcopy` for Android; Apple's
`ld -r` and an exported-symbols list for iOS), and the stack-limit source on
those platforms (bionic's and Darwin's thread stack bounds).

## 15. What to run when changing this

AGENTS.md, "Native libraries", lists it: `tests/native-library.test`,
`tests/native-executable.test`, `tests/aot-stub-linker.test`,
`tests/platform/aot-facts.tcl`, `cargo test --release --manifest-path
native/Cargo.toml --lib -- runtime::program runtime::library` (the
descriptor's round trip; the thread, reentrance and handle rules),
`audit/native-aot/tools/mutate.tcl`, the
JSON probe's `run.sh` and, for a change to the C interface, the React
Native host probe.

The files: hir/exports.tcl, hir/specialize.tcl ("Export roots"),
surface/parser.tcl, surface/lower.tcl, hir/syntax.tcl, hir/resolve.tcl,
hir/format.tcl, hir/read.tcl, native/lower.tcl (the library and export
lines), native/library.tcl, native/native.tcl (the `libraries`
capability), main.tcl, native/src/nir.rs (`ExportDecl`, `library=`,
`error` lines), native/src/codegen/library.rs, codegen/mod.rs, codegen/
clif.rs (local linkage, the stack-limit plan), codegen/roots.rs
(`plan_checked`), codegen/aot.rs (the startup), native/src/runtime/
program.rs, runtime/library.rs, runtime/aotimage.rs, runtime/vm.rs
(`swap_current_program`, `set_stack_boundary`), runtime/framewalk.rs
(`frame_address`), native/Cargo.toml (the staticlib crate type).
