# RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md

## Generic host-startable Botlish application entries, cross-target native link plans and Android C-binding generation

An implementation milestone. It builds what
ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md selected: an
ordinary Botlish entry program, built as a native library, that a foreign
host starts on its own thread through one C function, `NAME_main`; the
cross-target link plan the census found broken; and the C binding
generator's android-aarch64 target.

> An ordinary Botlish entry program can run as an executable or as a
> host-startable application library. In either form it installs its own
> contexts, owns its computation and obeys the same language semantics. The
> foreign host supplies the thread and the call boundary, not the
> application's authority or control flow.

Material: `../audit/host-startable-library/` (the C hosts, the Android
fixtures, the clean room, the mutation catalog and its harness, the
measurement script, results), the tests `../tests/application-library.test`,
`../tests/android-target.test`'s `at-link-plan-*` and `at-application-*`,
`../tests/c-bindgen.test`'s Android tests and `../tests/external-tools.test`'s
`et-tool-application-artifact`, and the committed binding
`../generated/c/sdl3/android-aarch64/`.

Evidence is labeled throughout:

* **observed** -- a command run in this milestone's container (Linux
  x86-64, 4 cores; Ubuntu 24.04's clang 18 and Tcl 9.0.1; the Android NDK
  r29, 29.0.14206865; qemu-user 8.2.2 and Google's arm64-v8a system images
  of API 21, 24 and 35 for Android processes);
* **static** -- read from source or from an artifact's bytes;
* **CI** -- a completed workflow at an identified revision;
* **projected** -- a consequence or a later capability, not shown here.

No Android device or emulator ran anything (the container has no KVM).
What ran on Android ran as an Android *process*: Android's own dynamic
linker (`/system/bin/linker64`) and Bionic from Google's system images,
under qemu-user, on the host's Linux kernel -- no zygote, ART, Activity or
SELinux (audit/android-aarch64-target/tools/android-run.sh, the
ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md harness).

## Contents

1. [Executive result](#1-executive-result)
2. [Starting architecture](#2-starting-architecture)
3. [Application-library semantics](#3-application-library-semantics)
4. [Entry dispatch](#4-entry-dispatch)
5. [`NAME_create` compatibility](#5-name_create-compatibility)
6. [`NAME_main` ABI](#6-name_main-abi)
7. [Contexts](#7-contexts)
8. [Thread safety](#8-thread-safety)
9. [Native stack and GC](#9-native-stack-and-gc)
10. [Native-library manifest](#10-native-library-manifest)
11. [Runtime ABI integrity](#11-runtime-abi-integrity)
12. [Cross-target link-plan correction](#12-cross-target-link-plan-correction)
13. [Android C-binding generator](#13-android-c-binding-generator)
14. [Linux host execution](#14-linux-host-execution)
15. [SDL3/Icy Tower integration](#15-sdl3icy-tower-integration)
16. [Android AArch64 artifacts](#16-android-aarch64-artifacts)
17. [Dynamic loader and TLS lifetime](#17-dynamic-loader-and-tls-lifetime)
18. [Cleanroom](#18-cleanroom)
19. [Negative tests](#19-negative-tests)
20. [Mutation testing](#20-mutation-testing)
21. [Regressions and CI](#21-regressions-and-ci)
22. [Performance and footprint](#22-performance-and-footprint)
23. [Remaining limitations](#23-remaining-limitations)
24. [Next milestone](#24-next-milestone)

## 1. Executive result

**Implemented (observed):**

* `-emit-native-library NAME -application FILE.bot` builds an ordinary
  entry program -- its `with context` installations, its state, its loop --
  as a native library with one more public function:

  ```c
  int32_t NAME_main(int argc, char **argv, NAME_error **error);
  ```

  It makes a fresh VM on the calling thread, runs module initialization and
  the entry program's statements to their end, drops the VM on that thread
  and returns the native-library status. No language syntax was added; the
  same file builds an executable.
* `NAME_create` initializes only, for every library: it selects "initialize
  only" through M4's existing entry dispatch, so an application library's
  instance never runs the entry program, and an ordinary library is
  unchanged (no `NAME_main`, LIBRARY-TOP-LEVEL and LIBRARY-NO-EXPORTS still
  refuse, manifest schema 2, the same public names).
* Application manifests are schema 3 (schema 2 plus an `application`
  member); `botlish tool` accepts them as `native-library` artifacts
  (protocol 1 unchanged); the React Native generator, which reads schema 2,
  refuses them (static: `integrations/react-native/src/main.c:490`).
* The runtime ABI fingerprint now digests the native-library boundary and
  the initialize-only selector (`e6c1492eceebb13c` -> `dc11c1c031a8f12d`):
  a stale target support package is refused by its identity record before
  any link.
* **The cross-target link plan is fixed**: the driver's `link-plan` takes
  `--target` and resolves the plan for that target's linker. The census's
  probe E2 (`extern c library "log"` in an Android library) builds; so do
  libraries declaring liblog, libandroid and SDL3.
* **The C binding generator has android-aarch64**: the NDK's clang at API
  21 against the NDK's sysroot. SDL3 3.4.18's Android binding is generated,
  checked reproducible, and committed (`generated/c/sdl3/android-aarch64/`):
  the same record layouts as linux-aarch64, Bionic's prototypes and SDL's
  Android functions.
* Icy Tower's **unchanged** `main.bot` built as an application library and
  started by a Linux host shaped like SDL3's Android bootstrap (a 1 MiB
  thread named SDLThread, `SDL_RunApp`, `SDL_main` calling `icy_main` with
  the game's arguments): the 600-frame autopilot summary is the committed
  executable's, byte for byte, also under GC stress, and all 11 SDL
  functions the game calls -- initialization to `SDL_Quit` -- ran on
  SDLThread only.
* An Android application library (its own IO over liblog), and Icy Tower's
  game modules over the generated Android binding linked with Android's
  `libSDL3.so`, link with the NDK: AArch64, 16 KiB-aligned, Bionic's
  libraries and SDL's symbol version only, `NAME_main` exported; the
  `SDL_main` shim links against them.
* `NAME_main` **ran in Android processes** of API 21, 24 and 35 (qemu-user,
  Android's linker and Bionic): it completes on API 21 and 24, and on API
  35 only once Bionic's heap pointer tagging is off (section 16, a finding
  for the next milestone).
* The clean room: the distributed single-file compiler alone builds and
  runs an application library on Linux, and builds one for android-aarch64
  from the target support package.

**Found and fixed on the way (observed):**

* A latent crash in every native library: `std::thread::current()` (the
  owner check) registers a pthread-key destructor on a thread Rust did not
  start, so a host that `dlclose`d the library before the thread ended
  crashed at the thread's end. The library's per-thread state is now one
  pthread key without a destructor (section 17).

**Found, not fixed here (observed; for the next milestones):**

* On Android 11 and later Bionic tags heap pointers in their top byte; a C
  address word holds 60 bits and the byte-exposure address a small Int, so
  every byte borrowing for a C call and every heap pointer a C function
  returns is refused (CORE SEMANTIC RANGE, NATIVE ADDRESS) unless the
  application turns tagging off (`android:allowNativeHeapPointerTagging=
  "false"`, which section 16 reproduces with `mallopt`).
* On Android Rust implements `thread_local!` with pthread keys whose
  destructors live in the library: a library unloaded while a thread that
  called it lives crashes that thread's end (std's own thread-locals, the
  coroutine stack pool). The contract is a lifetime rule: never unload a
  library while such a thread lives; SDL's bootstrap keeps the application
  library loaded (section 17).

**Deferred (projected):** the SDL3 Android packages, the `botlish_android`
tool, Gradle and the APK, the playable 2048 application, Activity
lifecycle acceptance on an emulator -- the next milestone's (section 24).

## 2. Starting architecture

(**static**, at `eeaf1e3e`, the census's merge; the census itself was at
`f06de8e6`. The code paths the census named were where it said, with
these differences: none of substance.)

| Part | Before this milestone |
|---|---|
| `native::library` (native/library.tcl) | `TopLevelProblems` refused every top-level statement that is no function declaration (LIBRARY-TOP-LEVEL), `LIBRARY-NO-EXPORTS` a library without exports; schema 2 manifests |
| the program function (native/lower.tcl) | module sections, then -- only for a program with thread entries -- `ThreadDispatch` (`threadop rt_entry_index`, a `switch` on the Vm's entry: 0 the entry program, K the K-th thread entry), then the entry program's statements |
| `runtime::library` (native/src/runtime/library.rs) | `botlish_library_create`: `program::instantiate`, argv empty, `check_stack_limit`, the program function run under `enter` (the frame-walk ceiling); instances owned by `std::thread::current().id()` |
| the library object (codegen/library.rs) | one forwarder per `FORWARDERS` entry, one trampoline per export |
| the runtime ABI fingerprint (runtime/aotimage.rs) | the Vm's and objects' offsets, the root plan, the program record's layout, the helpers' names and parameter counts |
| `native::LinkPlanOf` / the driver's `link-plan` | the host's plan only: the driver refused any other target (NATIVE TARGET) and native/library.tcl asked without `--target` (the census's finding 2) |
| tools/cheader/toolchain.tcl | targets linux-x86_64, linux-aarch64, macos-*, windows-x86_64(-gnu): no android-aarch64 (finding 3) |
| M4 (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md) | entry-specific context checking, one image, `rt_entry_index` |

## 3. Application-library semantics

```sh
botlish -emit-native-library app -application -out build/lib app.bot
```

(`tclsh9.0 main.tcl` in a checkout.) `-application` is a flag of
`-emit-native-library` only; anywhere else it is a malformed invocation
(status 2: `al-main-cli`). It reaches `native::library` as `-application 1`.

**Admission (observed: `al-*`):**

| Rule | Ordinary library | Application library |
|---|---|---|
| LIBRARY-TOP-LEVEL (statements in the entry file) | refused | admitted: they are the entry program |
| LIBRARY-NO-EXPORTS | refused | admitted: the entry is the point |
| exported c fns | every export rule | every export rule (EXPORT-ENVIRONMENT: no context, no capture, no suspension) |
| LIBRARY-SYMBOL | the runtime API's names | those and `main` (`al-library-symbol-main`) |
| entry-program checking | n/a (no statements) | as any entry program's, executable or library: installations in order, every requirement met (MISSING-CONTEXT: `al-authority`), one selection per context trait |

Nothing in the front end distinguishes the artifact: the entry program is
checked exactly as for an executable. `al-authority` shows both halves of
the authority rule: an application library's export that requires
`std::io::IO` is refused EXPORT-ENVIRONMENT even though the entry installs
one (the entry's authority never reaches a C caller, who has not entered the
application), and an entry that calls what it never installs is refused
MISSING-CONTEXT.

## 4. Entry dispatch

The program function of an application library (native/lower.tcl's
`ThreadDispatch`, now emitted for a program with thread entries *or* an
application) has one more case: "initialize only".

```text
func 0 "<program>" ...
    %6 = op listnew %0 %2 %4          ; module sections: each VM's statics
    staticset 0 %6
    %7 = int 29                        ; rt_entry_index
    %15 = op threadop %7 %8 ... %13
    %16 = op runbox %15
    switch %16 L0 -1:-1:L1             ; -1: initialize only; default: the entry program
  label L1
    %17 = unit
    ret %17                            ; NAME_create's Vm stops here
  label L0
    ...                                ; the entry program's statements (NAME_main's)
```

(**observed**: `al-dispatch-nir` checks this shape -- one `staticset`,
before the switch; the -1 case returns at once; the entry's statements after
it -- and the NIR's `application` line.)

| Selector | Who | Runs |
|---|---|---|
| -1 (`runtime::thread::ENTRY_INITIALIZE_ONLY`, reported as `ENTRY_INDEX_INITIALIZE_ONLY`; `core::thread::initializeOnly`) | `NAME_create`'s Vm, every library | module initialization |
| 0 | `NAME_main`'s Vm, every executable | module initialization and the entry program |
| K >= 1 | a thread entry's worker Vm (M4) | module initialization and thread entry K |

The cases are sorted (the -1 case first); a program with a thread entry gets
both (`al-thread-entries`: `switch %N L0 -1:-1:L1 1:1:L2`). The entry
program is lowered once; module initialization runs once per VM. The NIR
line `application` (nir.rs's `Program::application`) tells the driver to
emit the `NAME_main` forwarder; an ordinary library's NIR is unchanged.

## 5. `NAME_create` compatibility

`botlish_library_create` sets the new Vm's entry to "initialize only" for
every library. For an ordinary library without thread entries there is no
dispatch and nothing changes; with thread entries the -1 index matches no
case and falls to the entry program, which an ordinary library's entry file
does not have. For an application library it stops after module
initialization.

`al-create-initializes-only` (**observed**, also under GC stress): a library
whose entry program prints "the entry program ran" and which exports
`twice`:

```text
create: 0
twice: 0 42
destroy: 0
the entry program ran
main: 0
the entry program ran
main again: 0
```

`NAME_create` printed nothing, the export answered, the destroy succeeded,
and each `NAME_main` ran the entry once, in a fresh VM.

## 6. `NAME_main` ABI

The header (**observed**, `hello.h`):

```c
/* Application. This is an application library: its entry program runs
 * through hello_main (below), on the calling thread, blocking, to its end.
 * Each call makes a fresh Botlish VM there -- module initialization, then the
 * entry program's statements, which install its own contexts -- and drops it
 * on that thread before returning: no handle escapes, nothing is left behind,
 * and the host supplies the thread, never a context. argc and argv (argv[0]
 * included) become argv(), copied first; ... */
int32_t hello_main(int argc, char **argv, hello_error **error);
```

`botlish_library_main(program, int argc, char **argv, error)`
(native/src/runtime/library.rs), reached by a forwarder that passes `argc`
as the C `int` it is (an `I32` parameter: its upper register bits are never
read):

1. `*error` is set to NULL (when ERROR is not NULL).
2. REENTRANT-CALL if this thread runs a call of this library (section 8).
3. The arguments are checked and copied, before any VM exists:

   | Input | Outcome |
   |---|---|
   | `argc < 0` | INVOCATION `ARGUMENT-COUNT` |
   | `argc > 0`, `argv == NULL` | INVOCATION `NULL-POINTER` |
   | `argv[i] == NULL` | BOUNDARY `ARGUMENT-NULL`, field `argument=i` |
   | `argv[i]` not UTF-8 | BOUNDARY `ARGUMENT-NOT-UTF8`, field `argument=i` |
   | `argc == 0` (any `argv`, NULL included) | `argv()` is `[]` |

   C argument strings are NUL-terminated; no embedded NUL is invented. Each
   becomes an owned byte vector, so no host pointer outlives the copy. The
   contract is UTF-8 whatever the host's encoding: an executable takes its
   process's bytes and refuses invalid UTF-8 when `argv()` is read; a
   library's C caller states the contract and is refused at the boundary.
4. The program record is read and a VM instantiated; `argv()` is the copy,
   argv[0] included, as an executable's; the entry is 0; the stack-limit
   check is on.
5. The program function runs under `enter` (the frame-walk ceiling at that
   frame, the stack limit of the running stack), counted as an active call.
6. NO_VALUE becomes the failure's error (`botlish_error`: a declared error's
   identity and payload, a runtime error's code; NATIVE BUG as INTERNAL).
7. The VM is dropped, on this thread, on every path, before the status is
   returned. A panic in boundary code is caught (INTERNAL); nothing unwinds
   into C; nothing calls `exit`.

**observed** (`al-argv`, `al-errors`, `al-stack`):

```text
argc 0                                    (argc 0, argv NULL: status 0)
argc 3 / [0] 2 chars: <av> / [1] 0 chars: <> / [2] 6 chars: <grüß 😀>
argc 2 / [1] 1000000 chars: <(long)>      (a 1 MB argument)
negative: status 4 ARGUMENT-COUNT
argv NULL: status 4 NULL-POINTER
NULL argument: status 3 ARGUMENT-NULL argument=1
not UTF-8: status 3 ARGUMENT-NOT-UTF8 argument=2
runtime error: status 2 CORE SEMANTIC ARITHMETIC   (error released: yes)
success: 0, error NULL                    (*error held 0x1 before the call)
failure, no error out-parameter: 2
deep: status 2 NATIVE LIMIT STACK         (SIGSEGV handler unchanged: yes)
```

The program's value is not reported (as an executable reports none); a
completed entry is status 0. A declared error cannot escape the entry
silently: the top level must handle it (UNHANDLED-ERROR), so failures that
reach `NAME_main` are runtime errors (status 2) or boundary/invocation
refusals.

## 7. Contexts

An application library uses the entry program's own installations:

* **Static semantics** are unchanged: installation order, requirements,
  restricted injection, context-trait selection, affine ownership, resource
  cleanup obligations -- all the entry program's, checked once for the one
  image.
* **No host injection**: there is no way for C to put a context into a VM;
  the host passes `argc` and `argv`.
* **Context-owned state** lives through a long loop: `al-contexts` installs
  `std::linux::io`, `Frames` (a MutableVector) and `Settings` (a domain
  value), runs a 100,000-frame self-tail-recursive loop on a 1 MiB host
  thread and prints `total 15000150000, frames 100000, arguments 3` -- the
  same line the same file prints as an executable with the same arguments
  (**observed**, also under GC stress).
* **Cleanup**: the VM's drop releases its heap and context area on the
  calling thread after a completion and after a failure; resources the
  program closes itself (Icy Tower's SDL session) close before the entry
  returns (section 15).
* **Exports in an application library** keep the export rule, so a C
  caller of an instance never reaches the entry's contexts (`al-authority`).

## 8. Thread safety

| Question | Answer | Evidence |
|---|---|---|
| Which thread runs the entry? | the caller's; no thread is started | `al-contexts` (1 MiB host thread), section 15 (SDLThread) |
| Is the VM moved? | never: made, run and dropped in the call | static, library.rs |
| Two threads at once? | independent VMs, context areas, heaps, statics | `al-threads`: 4 threads x 100 calls, each its own context-owned state, 0 failures, also under GC stress |
| Sequential calls on one thread? | a fresh VM each | `al-repeated`: 1,000 calls, resident memory within 4 MiB of after 10 |
| Reentrancy? | `NAME_main` while this thread runs a call of the same library (from inside the entry, an export or an initialization) is INVOCATION REENTRANT-CALL; nothing changes; the outer call goes on | `al-reentrant` |
| An instance from inside the entry? | allowed (another VM): it initializes only and answers | `al-reentrant` |
| A process-wide lock? | none: the only shared state is the error and buffer registries' mutexes, as before | static |
| Thread-local state after a call? | the thread's word (token, active count) back to its value; no VM pointer kept | static, section 17 |

`al-reentrant`'s output (**observed**):

```text
nested main: status 4 REENTRANT-CALL
instance inside the entry: 0 version 7
the entry goes on after the host's call: 5
main: status 0
```

The active-call count covers `create`'s initialization, export calls and
`main`; only `main` reads it, so an ordinary library's nesting rules
(another instance from inside a call: `nl-reentrant`) are unchanged.

## 9. Native stack and GC

* **Stack**: `NAME_main` turns on the library's stack check
  (`check_stack_limit`, an eighth of the running stack in reserve) and runs
  under `enter`, which takes the limit of the stack the call is on. The
  executable's process-wide stack guard is never installed in a library.
  `al-stack`: non-tail recursion 10,000,000 deep on a 1 MiB host thread is
  NATIVE LIMIT STACK, the SIGSEGV disposition is SIG_DFL before and after,
  the next call succeeds, the host goes on. A self-tail-recursive loop of
  100,000 frames runs in constant stack (`al-contexts`).
* **GC**: every behavior test runs twice, the second time with
  `BOTLISH_NATIVE_GC_STRESS=1` (a collection before every allocation), and
  requires the same output. The frame walk stops at `enter`'s frame, so host
  frames above `NAME_main` are never read.

## 10. Native-library manifest

Schema 3 is an application library's only; every other library's stays
schema 2 byte for byte (`al-ordinary`). The one addition (**observed**,
`hello.manifest.json`):

```json
"application": {
  "symbol": "hello_main",
  "c": "int32_t hello_main(int argc, char **argv, hello_error **error)",
  "thread": "calling",
  "execution": "blocking-to-completion",
  "vm": "made and dropped on the calling thread inside each call; no handle escapes",
  "argv": {"encoding": "utf-8", "includes": "argv0", "copied": true,
           "refusals": ["ARGUMENT-COUNT", "NULL-POINTER", "ARGUMENT-NULL", "ARGUMENT-NOT-UTF8"]},
  "contexts": "installed by the entry program itself; the host supplies none",
  "returns": {"ok": "the entry completed", "otherwise": "the failure's status"},
  "status": "native-library",
  "error": {"c": "hello_error **", "nullable": true, "ownership": "owned", "release": "hello_error_release"},
  "reentrancy": "refused while this thread runs a call of this library (REENTRANT-CALL)",
  "concurrency": "independent calls on different threads, each with its own VM",
  "stack": "the calling thread's, bounded by the library's stack check (NATIVE LIMIT STACK); no signal handler"
}
```

`api` lists `hello_main`; `lifecycle.initialization` says the entry runs in
`hello_main`, never in `hello_create`; `sha256` binds the static library,
the shared library and the header as for schema 2 (`al-header-manifest`,
`at-application-library`).

**Tools.** `botlish tool -artifact` (pm/tools.tcl's `Artifact`) takes
schemas 2 and 3, and refuses a schema 3 manifest without its `application`
member and a schema 2 one with it (`et-tool-application-artifact`). The
protocol 1 request is unchanged: a tool that needs an application reads the
manifest itself (`cleanroom/validate-manifest.py` does, from the manifest
and the ELF bytes only). The React Native generator refuses schema 3
(RN-MANIFEST), so it never takes an application entry for an export.

## 11. Runtime ABI integrity

The library object's forwarders call runtime functions by symbol, and an
application library's program function relies on `create` selecting
initialize-only. Both are binary interface between the driver that emits a
library object and the runtime archive it is linked with -- a target
support package's, built elsewhere. So the fingerprint
(runtime::aotimage's `abi_words`, `ABI_FINGERPRINT`) now digests:

* `runtime::library::SIGNATURES`: every `botlish_library_*` function a
  library object calls, by name and word count (the program record
  counted) -- the forwarders', the trampolines' `botlish_library_call` and
  `botlish_library_main`. A unit test (`signatures_are_the_forwarders`)
  derives the list from `FORWARDERS`, `CALL` and `MAIN`;
* `ENTRY_INDEX_INITIALIZE_ONLY` (-1), one scalar word.

`e6c1492eceebb13c` became `dc11c1c031a8f12d` (**observed**: `botlish-native
runtime-abi`). Consequences: every target support package is rebuilt (the
Android one was, by audit/android-aarch64-target/tools/package.sh); an old
package's identity record is refused before any linker runs
(`at-runtime-identity`'s rule), rather than failing at link time on a
missing `botlish_library_main`. Nothing committed records the old value
except two result files of the React Native milestone
(`audit/react-native-2048/results/record-*.json`), which are evidence of
that run and are checked by nothing. No other ABI input changed.

## 12. Cross-target link-plan correction

**The defect** (the census's probe E2, observed there): `native::library`
asked the driver's `link-plan` for the program's plan without `--target`;
the driver checked the program against the host and refused another
target's (NATIVE TARGET). Any Android library declaring a library failed.

**The fix** (native/src/main.rs, codegen/aot.rs, native/library.tcl,
native/native.tcl):

* `link-plan` accepts `--target TRIPLE` (`--target` stays refused by every
  command but `library` and `link-plan`; `run --target` is still a usage
  error: `at-driver-refusals`).
* `resolve_link_plan_for(program, search, target)`: the host's own target
  is `resolve_link_plan` exactly; another target's plan is resolved for its
  linker flavor (`flavor_of`: GNU-style for Linux and Android) and object
  format (`machine_of`: ELF AArch64 for Android), named in every message,
  and a static library declared without a path is searched in the -L
  directories only -- never this host's toolchain directories, which hold
  this host's libraries.
* `native::library` passes the library's `--target` to `link-plan` as it
  does to `library`.

What is unchanged: plans stay intent in HIR and are resolved at link
(NATIVE-LINK-PLAN-MILESTONE-1.md); system libraries, archive checks,
determinism and diagnostics are the same code; `run` and the JIT still
require the host's target.

**observed:**

| Case | Result |
|---|---|
| probe E2 for android-aarch64 | builds; NEEDED liblog.so; manifest dependency `-llog` |
| `extern c library "log"` and `"android"` (`at-link-plan-cross`) | builds; NEEDED libandroid.so, liblog.so; dependencies `-llog -landroid` |
| Icy Tower over Android SDL3 (`at-application-sdl3`) | builds; NEEDED libSDL3.so, liblog.so |
| a static archive of this host's x86-64 objects declared for Android (`at-link-plan-cross-refusals`) | NATIVE LINK ARCHIVE: "holds object code for ELF x86-64, and this program is linked for android-aarch64 (ELF AArch64)"; nothing left behind |
| `extern c library "m" static` for Android, no -L | NATIVE LINK ARCHIVE: "no static archive libm.a is in the library search directories (none)" |
| Linux's x86-64 libSDL3.so given by -L for Android | the NDK's link refuses it (NATIVE LIBRARY TOOL cc); no library left |
| a framework for Android | refused naming the target (the driver's unit test; the front end refuses it first, UNSUPPORTED-PLATFORM) |
| a library without dependencies, the host's own target | unchanged (the native-library suite, 28/28) |

The driver's unit test `link_plan_for_another_target_is_that_targets`
covers the flavors, the machines, libraries by name, an AArch64 archive
accepted and an x86-64 one refused for Android, the missing -L case, and the
host's own target equal to `resolve_link_plan`.

## 13. Android C-binding generator

**Target row** (tools/cheader/toolchain.tcl): `android-aarch64
aarch64-linux-android21` -- API 21, the Android target support package's
minimum. `configFor android-aarch64`:

* always the NDK's own clang (`AndroidNdk`:
  `$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/HOST/bin/clang`), never
  BOTLISH_C_CC, never a host clang;
* the NDK's sysroot (`.../prebuilt/HOST/sysroot`) unless
  BOTLISH_C_SYSROOT_android_aarch64 names one, and generation refuses a
  sysroot without `usr/include/android/api-level.h` (generate.tcl's
  `CheckCrossHeaders`): Bionic's headers, never the host's;
* the NDK's directory never appears in a generated file: `hide` shows it as
  `$ANDROID_NDK_ROOT` (the manifest's command line, the import profile's
  compiler path).

**SDL3 3.4.18** (commit `829a65d7`), generated by NDK r29's clang (Android
clang 21.0.0, `based on r563880c`) in about 2 s (**observed**):

```text
sdl3 android-aarch64: 1226 direct, 3 alias, 15 thunk, 158 unsupported, 1657 constants
command {$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/clang -E -x c
         --target=aarch64-linux-android21 --sysroot=$ANDROID_NDK_ROOT/... -I$SRC/include $TU/entry.c}
```

Compared with the committed linux-aarch64 binding (**observed**,
`cb-sdl3-android-abi`):

| Fact | Android vs Linux AArch64 |
|---|---|
| record layouts (`layouts.tsv`: every record's size, alignment and offsets) | identical, all 103 records; the event, touch-finger, rectangle and window-event layouts among them |
| event types (WILL/DID_ENTER_BACKGROUND, TERMINATING, LOW_MEMORY, FINGER_DOWN/CANCELED, WINDOW_PIXEL_SIZE_CHANGED, RENDER_DEVICE_RESET) | identical values |
| pointer width, `long` | LP64 both |
| functions | Android has `SDL_GetAndroidJNIEnv`, `SDL_GetAndroidActivity`, `SDL_GetAndroidSDKVersion`, `SDL_IsChromebook`, `SDL_IsDeXMode`, `SDL_SendAndroidBackButton`, the storage paths, `SDL_RequestAndroidPermission`, `SDL_ShowAndroidToast`, `SDL_SendAndroidMessage`; Linux has `SDL_SetLinuxThreadPriority(AndPolicy)` instead |
| prototypes of the C library functions SDL aliases | Bionic's: `void *_Nonnull memcpy(void *_Nonnull, const void *_Nonnull, size_t)`, other parameter names |
| platform constant | `SDL_PLATFORM_ANDROID`, not `SDL_PLATFORM_LINUX` |

Matching layouts are evidence of ABI compatibility for the records; the
functions and constants show the binding is not a relabeling. The binding
is committed (`generated/c/sdl3/android-aarch64/`, 65 files); `check sdl3
-target android-aarch64` reproduces it byte for byte (`cb-sdl3-current-
android`). The c-bindgen workflow installs NDK r29 by its SHA-256
(`4abbbcdc…7a308ecf`, cached) and checks it with every committed binding,
and fuzzes the target's layouts (`layout-fuzz.tcl -target android-aarch64`:
0 disagreements, observed). The profile's new target changed its CRC, which
the committed Linux manifests record: only that line was updated (this
container's clang is 18, the pinned one 21.1.8; regenerating here would
change the toolchain lines the workflow checks).

No Android `.botpkg` of SDL3 is built here (the next milestone's): the
binding is staged into the tests' applications by `tools/c-bindgen.tcl
stage sdl3 -target android-aarch64`, and Android's `libSDL3.so` built by
`tclsh9.0 tests/cffi/sdl3.tcl android` (CMake, Ninja, the NDK's toolchain
file, arm64-v8a, API 21; every LOAD segment 0x4000-aligned, observed).

## 14. Linux host execution

`tests/application-library.test` (**observed**: 18 tests, all passing;
every behavior test also under GC stress):

| Test | What it shows |
|---|---|
| `al-create-initializes-only` | section 5 |
| `al-contexts` | section 7; the executable prints the same line |
| `al-argv` | section 6's argument table, a 1 MB argument |
| `al-errors` | statuses and errors, `*error` NULL after a success, a NULL out-parameter |
| `al-stack` | NATIVE LIMIT STACK on a 1 MiB host thread; no SIGSEGV handler installed |
| `al-reentrant` | section 8 |
| `al-threads` | 4 concurrent threads x 100 calls, independent VMs |
| `al-repeated` | 1,000 sequential calls, bounded memory |
| `al-authority` | EXPORT-ENVIRONMENT in an application library; MISSING-CONTEXT |
| `al-library-symbol-main` | `main` reserved in application libraries only |
| `al-dispatch-nir` | section 4's program function |
| `al-ordinary` | an ordinary library unchanged |
| `al-header-manifest` | the header and schema 3 |
| `al-symbols` | the global symbols are exactly the public names, `NAME_main` among them |
| `al-main-cli` | `main.tcl -application` |
| `al-dlopen` | section 17 |
| `al-thread-entries` | the dispatch with a thread entry |
| `al-icy-tower-sdl-runapp` | section 15 |

The census's probes F and D are these tests now, against `NAME_main`
rather than a scratch tree's `create`.

## 15. SDL3/Icy Tower integration

`al-icy-tower-sdl-runapp` (**observed**): Icy Tower's modules -- `main.bot`
unchanged, with game, sdl, render, hud, tower and options -- staged with the
committed linux-x86_64 SDL3 binding and built with `-warnings error
-emit-native-library icy -application`. `main.bot` reads its arguments
from `argv()` (`game::arguments()`), so the host passes the game's
arguments through `icy_main`, and the very file the executable is built
from is the application library's entry.

The host (`audit/host-startable-library/sdl/sdl_runapp_host.c`) is the
shape of SDL3's Android bootstrap: the main thread starts a 1 MiB thread
named SDLThread, which calls `SDL_RunApp(argc, argv, SDL_main, NULL)`;
`SDL_main` calls `icy_main(argc, argv, &error)`. The host knows nothing of
the game.

```text
host: SDL_main on thread SDLThread, SDL_IsMainThread 1
frames=600 round=1 floor=36 score=360 best=35.5 time=10.0 over=no x=247 y=3469 camera=3211 platforms=11 rng=659525717
host: the application returned 0
host: SDL_RunApp returned 0
observer: SDL_Init 1 calls on SDLThread
observer: SDL_CreateWindow 1 calls on SDLThread
observer: SDL_CreateRenderer 1 calls on SDLThread
observer: SDL_PollEvent 611 calls on SDLThread
observer: SDL_RenderClear 600 calls on SDLThread
observer: SDL_RenderFillRect 13262 calls on SDLThread
observer: SDL_RenderDebugText 2876 calls on SDLThread
observer: SDL_RenderPresent 600 calls on SDLThread
observer: SDL_DestroyRenderer 1 calls on SDLThread
observer: SDL_DestroyWindow 1 calls on SDLThread
observer: SDL_Quit 1 calls on SDLThread
```

The committed executable (`audit/icy-tower/artifacts/icy-tower --autopilot
--fixed-step --frames 600 --seed 17`) prints the identical summary; so does
the library under `BOTLISH_NATIVE_GC_STRESS=1`. The observer
(`sdl/sdl_threads.c`, an `LD_PRELOAD` interposer built against SDL's pinned
headers) records every SDL function's calling threads: initialization,
window, renderer, polling, drawing, presenting, destruction and shutdown all
on SDLThread. Not covered (SDL's dummy driver): touch, resize, lifecycle,
a GPU renderer.

## 16. Android AArch64 artifacts

**The application library** (`at-application-library`, **observed**):
`hello.bot` installs `android_log::create()` (its own `std::io::IO` over
liblog's `__android_log_write`) and a context holding state; built with
`-target android-aarch64 -target-support botlish_target_android_aarch64
-emit-native-library hello -application`:

| Fact | Value |
|---|---|
| machine, type | AArch64 (183), shared object |
| LOAD alignment | 0x4000, all three segments |
| text relocations | none |
| NEEDED | libc.so, libdl.so, liblog.so, libm.so |
| symbol versions | LIBC only (no GLIBC_) |
| exports | exactly the public names (16), `hello_main` among them |
| SONAME | libhello.so |
| manifest | schema 3, `application.symbol` hello_main, target android-aarch64, target support package and toolchain, every SHA-256 |

**SDL3** (`at-application-sdl3`, **observed**): Icy Tower's six game modules,
unchanged, with `icy-android.bot` (main.bot with Android's IO), over the
generated android-aarch64 binding, linked with Android's libSDL3.so:

| File | Machine | NEEDED | LOAD | Bytes / stripped | SHA-256 (first 16) |
|---|---|---|---|---|---|
| libicy.so (the application) | AArch64 | liblog, libSDL3, libdl, libm, libc | 0x4000 | 1,283,560 / 909,536 | 6ffa239502353fd7 |
| libmain.so (`android/sdl_main.c`) | AArch64 | libicy, libSDL3, liblog, libdl, libc | 0x4000 | 6,048 / 4,624 | 18ef11b9ec63a042 |
| libSDL3.so (3.4.18, NDK r29, API 21) | AArch64 | (SDL's own) | 0x4000 | 12,141,504 / 2,401,784 | 285a581926e2b6b5 |
| libhello.so | AArch64 | liblog, libdl, libm, libc | 0x4000 | 1,100,232 / 744,976 | 8bd98b123090308f |

libicy.so imports 24 SDL functions, all `@SDL3_0.0.0`; `icy_main` is
exported; libmain.so defines `SDL_main`. No Linux artifact enters: Linux's
libSDL3.so given instead is refused by the NDK's link.

**Execution in Android processes** (`at-application-run`, **observed**): an
Android host (`android/host_main.c`, NDK clang, API 21) runs `hello_main`
twice on a 1 MiB thread named SDLThread, under Android's linker and Bionic:

| Image | Result |
|---|---|
| API 21 (Android 5.0) | `MAIN 0 0`, `MAIN 1 0`, `HOST done` |
| API 24 (Android 7.0) | `MAIN 0 0`, `MAIN 1 0`, `HOST done` |
| API 35 (Android 15), 4 KiB and 16 KiB pages | `MAIN 0 2 CORE SEMANTIC RANGE std::abi::x86_64::from_bytes: the payload address 0xb4004000b48d15c0 is outside the small-Int range` |
| API 35, Bionic's heap pointer tagging off first (`-DNO_HEAP_POINTER_TAGGING`: `mallopt(M_BIONIC_SET_HEAP_TAGGING_LEVEL, M_HEAP_TAGGING_LEVEL_NONE)`) | `MAIN 0 0`, `MAIN 1 0` |

**Tagged heap pointers (a finding).** Android 11 and later tag every heap
pointer's top byte (0xb4) on AArch64. Botlish's byte exposure for a C call
passes the payload address as a small Int (62 bits), and a C address word
holds 60 bits (runtime/value.rs's `cptr_fits`), so any byte borrowing --
here liblog's tag and text -- is refused CORE SEMANTIC RANGE, and any heap
pointer a C function returns (`SDL_CreateWindow`'s) NATIVE ADDRESS. The
runtime refuses rather than truncates, as designed; the application entry is
not at fault (it completes once tagging is off). An application can opt out
today in its manifest (`android:allowNativeHeapPointerTagging="false"`, the
same `mallopt` the platform performs); a runtime that carries tagged
addresses -- C address words and exposure addresses of 64 bits -- is a
milestone of its own. This is the next milestone's first prerequisite for
SDL on current Android (section 24).

The census's earlier evidence (Botlish library code on ART threads on a
phone, the React Native device builds) is the React Native milestone's
(owner-observed there); none of its libraries passed bytes to C or held a
C heap pointer.

## 17. Dynamic loader and TLS lifetime

What the runtime registers on a thread that called a library decides what a
host may do with `dlclose` afterwards.

**On Linux glibc** (**observed**, `al-dlopen` and the experiments behind
it):

* `NAME_main` (an entry without coroutines) and an instance's
  create/destroy register no thread-local destructor: `dlclose` while the
  thread lives unmaps the library, and the thread's later end is clean.
  Before this milestone an instance's `std::thread::current()` registered a
  pthread-key destructor on a foreign thread: `dlclose` then crashed the
  process when the thread ended (**observed**: SIGSEGV in
  `__nptl_deallocate_tsd`). The owner rule now uses a token drawn once per
  thread, never reused, kept in the slot of one pthread key created without
  a destructor (runtime/library.rs's `thread_word`), with the active-call
  count.
* An entry that runs a coroutine registers the coroutine stack pool's
  destructor through `__cxa_thread_atexit_impl`, which glibc pins: after
  `dlclose` the library stays mapped (and stays so after the thread ends).
  Safe.
* `al-dlopen`: three rounds of dlopen, `NAME_main`, dlclose; then a thread
  that ran `NAME_main`, and one that ran an instance, outliving the
  unloading -- all clean, also under GC stress.

**On Android (Bionic)** (**observed**, `at-application-unload`,
`android/host_dlclose.c`, API 21, 24 and 35): Rust implements `thread_local!`
on aarch64-linux-android with pthread keys whose destructors live in the
library (`std::sys::thread_local::os::destroy_value`; the library imports
`pthread_key_create`, has no TLS segment and no `__cxa_thread_atexit_impl`).
std's own thread-locals register one (the fault was in
`destroy_value<Cell<(usize, bool)>>` of std itself once the library's own
state was destructor-free), and so does the coroutine stack pool:

| How the library is held while the thread that ran `NAME_main` ends | API 21 | API 24 | API 35 |
|---|---|---|---|
| `unload`: the one handle closed while the thread lives | crash at the thread's end | crash | crash |
| `kept`: a second handle opened first and never closed (SDLActivity's `System.loadLibrary` of every library in `getLibraries()`) | clean | clean | clean |
| `nodelete`: the handle opened with RTLD_NODELETE (a shim's pin) | refused ("invalid flags": API 21 has no RTLD_NODELETE) | clean | clean |

**The rule** (header, manifest, AGENTS.md): a host must not unload a
library while a thread that called it lives. glibc enforces it for
`__cxa_thread_atexit_impl` destructors and the library's own state needs
none; Bionic does not, and Rust's thread-locals there cannot be made
destructor-free by library code. SDL's Android bootstrap already obeys it:
SDLActivity loads the application library with `System.loadLibrary`
(never unloaded); `nativeRunMain`'s `dlclose` unloads `libmain.so`, the
shim, whose NEEDED reference is not the last. A shim may additionally pin
with RTLD_NODELETE on API 23 and later. No dynamic-loader workaround entered
the compiler or the runtime.

## 18. Cleanroom

`audit/host-startable-library/cleanroom/cleanroom.sh BOTLISH RESULTS [REPO]`
(**observed**, results in
`audit/host-startable-library/results/cleanroom-linux-x86_64.txt`):

* the single-file compiler built by `single/build.sh` (15,572,402 bytes),
  copied into a fresh directory and run with an emptied environment (PATH
  `/usr/bin:/bin`, a fresh HOME): no checkout, no development driver, no
  package cache;
* **Linux**: an entry program with two contexts, state, a 100,000-frame
  loop and argv, built with `-emit-native-library app -application`; a C
  host calling `app_main` twice on a 1 MiB thread: `entry: 5000050000, 3
  arguments`, `host: app_main 0`, twice;
* **an external tool's view**: `validate-manifest.py` (Python, reading only
  the manifest and the ELF bytes) -- kind, schema 3, the application member
  and its C signature, blocking on the calling thread, every SHA-256, and
  `app_main` defined in the shared object;
* **Android**: the target support package added from its repository (the
  package manager verifies and installs it; nothing in it runs), an
  application library of android-aarch64 over liblog built: AArch64,
  16 KiB LOAD segments, liblog and Bionic's libraries; the validator accepts
  its manifest.

`et-tool-application-artifact` covers protocol 1's side: `botlish tool
-artifact app/app.manifest.json` runs a tool that requires a native library
on an application library's manifest.

## 19. Negative tests

| Refusal | Test |
|---|---|
| top-level statements in an ordinary library (LIBRARY-TOP-LEVEL) | `al-ordinary` |
| an ordinary library without exports (LIBRARY-NO-EXPORTS) | `al-ordinary` |
| no `NAME_main` in an ordinary library's header, symbols, manifest (schema 2) or NIR | `al-ordinary` |
| an export requiring a context in an application library (EXPORT-ENVIRONMENT) | `al-authority` |
| an entry missing an installation (MISSING-CONTEXT) | `al-authority` |
| an application export named `main` (LIBRARY-SYMBOL) | `al-library-symbol-main` |
| `NAME_create` running the entry | `al-create-initializes-only` |
| negative argc, NULL argv, a NULL argument, invalid UTF-8 | `al-argv` |
| a stale error pointer after a success; a leaked error | `al-errors` |
| deep recursion on a host thread | `al-stack` |
| a nested `NAME_main` | `al-reentrant` |
| `-application` without `-emit-native-library` (usage, status 2) | `al-main-cli` |
| a host archive, a searched static library for Android | `at-link-plan-cross-refusals` |
| Linux's libSDL3.so for an Android library | `at-application-sdl3` |
| a schema 3 manifest without its member; schema 2 with one | `et-tool-application-artifact` |
| an Android binding without the NDK, or against a sysroot that is no Android one | `cb-android-configuration` |
| unloading while a caller thread lives (the lifetime rule's evidence) | `at-application-unload` |
| `--target` on another driver command | `at-driver-refusals` |

A failed build leaves no library or manifest behind (`native::library`
deletes the old files before linking; `at-toolchain-failures`,
`at-link-plan-cross-refusals`).

## 20. Mutation testing

`audit/host-startable-library/tools/mutate.tcl` with
`audit/host-startable-library/tools/mutants.txt`: 38 mutants, each naming the
tests that must kill it (`!!`); a mutant counts as killed only when one of
its named tests fails. Result (**observed**, with ANDROID_NDK_ROOT and
BOTLISH_ANDROID_ROOTS set): MUTATION_RESULT_PENDING

| Mutant | Killed by |
|---|---|
MUTATION_TABLE_PENDING

Six mutants of other catalogs whose text moved (android-aarch64-target's
`run-with-target`, `target-not-passed`, `thread-affinity-ignored`;
native-aot's `fingerprint-ignores-record`; native-library's
`wrong-thread-accepted`, `stack-limit-never-set`) were updated to the new
code, kept mutants of the same rule; `tools/mutant-catalogs.tcl` reports
all 107 catalogs' 3,637 mutants applying.

## 21. Regressions and CI

REGRESSIONS_PENDING

## 22. Performance and footprint

PERFORMANCE_PENDING

## 23. Remaining limitations

* **Tagged heap pointers on Android 11+** (section 16): byte borrowing and
  C heap pointers are refused unless the application turns tagging off.
  Required for SDL on current Android; the runtime change (64-bit C address
  words and exposure addresses) is a milestone of its own.
* **The unload rule on Android** (section 17): a library must stay loaded
  while a thread that called it lives. SDL's bootstrap satisfies it; any
  other Android host must too.
* **No Activity lifecycle evidence**: no ART, Activity, surface, touch or
  pause ran here; the qemu-user runs are Android processes. The next
  milestone's emulator jobs own it.
* **std::thread in an application library**: a library has no VM factory,
  so a thread start fails at run time (as in every library); thread entries
  compile and dispatch (`al-thread-entries`).
* **A blocking entry only**: no resumable or host-driven VM, by design.
* **Icy Tower's `exit`**: its usage and float-failure paths call C's
  `exit`, which in a library ends the host process; an application library
  should return instead (the SDL 2048 application will).
* **macOS and Windows**: native libraries are made on Linux glibc and for
  Android only, so are application libraries.
* **CI's verdicts** are pending at the time of writing (section 21).

## 24. Next milestone

**RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1** -- a playable Android
2048 whose entry, contexts, state, UI, input interpretation, rendering
decisions, lifecycle policy and main loop are Botlish, packaged
independently of the compiler. This milestone gives it, generically:

* `NAME_main` and schema 3 manifests: `botlish_android`'s `SDL_main` shim is
  `audit/host-startable-library/android/sdl_main.c`'s shape; its tool
  reads the `application` member;
* cross-target link plans: the application library links `libSDL3.so` and
  liblog;
* the android-aarch64 SDL3 binding, committed, for the `sdl3` package's
  Android view;
* `tests/cffi/sdl3.tcl android`'s recipe for the package's `libSDL3.so`.

What it must add or decide first:

1. **Heap pointer tagging**: either the generated `AndroidManifest.xml`
   sets `android:allowNativeHeapPointerTagging="false"` (documented, with
   the reason), or a runtime milestone carries 64-bit tagged addresses
   first.
2. **The unload rule**: keep the application library in `getLibraries()`
   (System.loadLibrary), and pin it in the shim with RTLD_NODELETE where
   the minimum API is 23 or later.
3. An Android IO package (this milestone's `android_log.bot` is a fixture).
4. The played-game rules moved out of the React Native facade (the
   census's section 15), the `sdl3` package's Android view, the tool, the
   APK and its emulator acceptance.
