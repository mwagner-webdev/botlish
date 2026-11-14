# LIBC-FREE-LINUX-EXECUTABLES-AUDIT.md

This audit asks what it would take for a standalone Linux executable to run
without a C library. That is the file `-emit-native-executable` writes, and
`-aot-run` runs, with any of the three linkers. It measures where every
C-library dependency of such an executable comes from today. It compares the
two ways to remove them: a static executable that still contains a libc, or
a runtime with no libc at all. It lists what the second needs, subsystem by
subsystem. It ends with a roadmap.

It is an audit, not a milestone: nothing in the compiler or the runtime was
changed. Every experiment ran in a scratch directory, at `b0ae98fe`
(2026-11-14), with rustc 1.97.0 on Linux x86-64, kernel 6.18. Appendix A
reproduces the measurements. COROUTINE-PREREQUISITES.md's Appendix B was the
first such measurement. Appendix B below says what changed since then.

## Summary

* **Generated machine code already needs no C library.** The program object
  references only the runtime's `rt_` helpers: no libc symbol, no libm
  symbol, no TLS. The Linux standard library makes raw system calls, not
  C calls: `std::linux::io`, `std::linux::fs` and the paths go through
  `std::linux::abi::x86_64::syscall` / `aarch64::syscall`, which are inline
  `syscall` / `svc #0` in `runtime/syscall.rs`. Every libc dependency of an
  executable comes from three places: the Rust runtime library, Rust's
  `std` under it, and the C startup files rustc links.
* **Today every executable is dynamically linked against glibc.** This
  holds for all three linkers. Each executable is a PIE. It needs
  `ld-linux-x86-64.so.2`, `libc.so.6`, `libm.so.6` and `libgcc_s.so.1`, and
  imports 82 to 84 symbols (section 4).
* **"libc-less" can mean two things, and they cost very different amounts.**
  * *Route A: no C library needed at run time.* The executable is static, so
    it runs on any Linux kernel whether or not the system has a C library.
    It still contains one. With **static glibc this works today**: the
    rustc link plus one flag, `-C target-feature=+crt-static`, gives a
    static-pie executable. That executable ran the hello program, the CSV
    workload, Botlish threads, the stack-overflow guard and general-runtime
    coroutines with the same results (section 5.1). With **static musl**
    the runtime compiles unchanged. But its capability flags read musl as
    an unknown host and fall back to the shadow-stack GC root plan. The ABI
    fingerprint then refuses every program at startup, so musl needs real
    porting work (section 5.2).
  * *Route B: no C library at all.* This is a runtime written against the
    kernel. It is a `#![no_std]` build of the runtime. It must supply its
    own process entry, allocator, threads, thread-local state, locks,
    signal setup, entropy, clock, environment and file access, panic
    handler and memory functions (section 6).
    * The toolchain side works on stable Rust: a `no_std` program built for
      `x86_64-unknown-linux-gnu` linked with `-nostartfiles -nostdlib
      -static`. It ran here as a static ELF with no interpreter and no
      dynamic section, once it supplied eight symbols (section 6.1).
    * The work is in the runtime. About 270 OS-level uses of `std` and
      `libc` in 15 of its files need replacing. The two largest pieces are
      an allocator for the GC heap and the move from `std::thread` to the
      runtime's own threads.
* **Route B can only ever cover programs that call no C.** C code expects a
  C library. So programs with `extern c fn`, C callbacks or a C package keep
  glibc. So do native libraries (a host process loads them, and it has its
  own libc). This seam exists already: `auto`, the single-file compiler's
  linker choice, splits programs exactly there.
* **Recommendation.** Decide first which property is actually wanted.
  * If it is "runs on a machine with no or another C library", route A
    with static glibc is a small milestone. Its open questions are policy:
    LGPL relinking obligations when distributing executables, and programs
    that link shared C libraries.
  * If it is "contains no C library", plan route B as the staged roadmap of
    section 11. Do the import-shrinking cleanups first; they pay off on
    glibc too. Of the three linkers, convert the stub linker's runtime
    first: once it is libc-free, the single-file compiler emits libc-free
    executables with no toolchain at all.

## Contents

1. Scope and terms
2. Method
3. What is already free of libc
4. Today's executable: every import and who needs it
5. Route A: a static executable with a libc inside
6. Route B: no C library at all
7. The three linkers, the startups and the runtime's identity
8. What stays on a C library
9. The verification route B needs
10. Risks and costs
11. Roadmap
- Appendix A. Reproducing the measurements
- Appendix B. What changed since COROUTINE-PREREQUISITES.md's Appendix B

## 1. Scope and terms

* **The executable**: what `-emit-native-executable` and `-aot-run` link
  for linux-x86_64 and linux-aarch64. It may come from any of the three
  linkers (SINGLE-EXECUTABLE.md, SINGLE-EXECUTABLE-FFI-MILESTONE-1.md):
  * `rustc` compiles the startup crate `STARTUP` (`codegen/aot.rs`) against
    `libbotlish_native.rlib`;
  * `stub` appends the program image to a copy of `botlish-aot-stub`;
  * `system` links the program object with the runtime archive
    `libbotlish_runtime.a` and its C `main`.
* **Out of scope**: the driver (`botlish-native`: Cranelift, the JIT, rustc
  invocations), a host tool that keeps its C library. Native libraries
  (section 8). Android (Bionic's process). macOS, whose only supported
  kernel interface is libSystem (MACOS-AARCH64-MILESTONE-8.md). Windows.
* **libc-dependent**: imports a symbol from `libc.so.6`, `libm.so.6`,
  `libgcc_s.so.1` or the dynamic loader, or contains a static copy of a C
  library.
* **Route A** (static, libc inside) and **route B** (no libc) as in the
  summary.

## 2. Method

Five programs, each built with the normal driver (`cargo build --release
--manifest-path native/Cargo.toml`) and `tclsh9.0 main.tcl
-emit-native-executable`:

| Program | What it exercises |
|---|---|
| `examples/linux/context-hello.bot` | `std::linux::io` writes, a context |
| `examples/stdlib/csv.bot` | strings, Lists, the GC |
| `tests/threads/limit.bot` + `crunch.bot` | `std::thread`: starts, `ThreadLimit`, stop and join |
| a two-line unbounded recursion | the stack-overflow guard (`NATIVE LIMIT STACK`) |
| COROUTINES.md's principal program, coroutine fusion off | general-runtime coroutines (`rt_co_*`, stacks of their own) |

The measurements:

* `ldd`, `readelf -d` and `readelf -l` on every executable;
* `nm -D --undefined-only` for the imports;
* `nm -u` on the program object `botlish-native object` emits from the
  program's NIR (which `-aot-keep` keeps);
* every import attributed to the functions that reference it, from
  `objdump -d -C` (a short script: Appendix A);
* the three linkers compared on the hello program (`BOTLISH_NATIVE_LINKER`).

The route experiments are sections 5.1, 5.2 and 6.1.

## 3. What is already free of libc

* **The program object.** For all three programs, the object references
  only the runtime's `rt_` helpers (191 of them) and no C-library or libm
  symbol.
  * Cranelift is given `default_libcall_names()`, but no instruction the
    code generator emits becomes a libcall: no `floor`/`ceil`/`nearest`
    instruction, no `call_memcpy`, no TLS access (`codegen/clif.rs`).
  * The libm-style functions the runtime itself needs (`trunc`, `ceil`,
    `__powidf2`) are defined statically by Rust's `compiler_builtins`, not
    imported.
* **Botlish's Linux I/O.** `stdlib/linux.bot`, `std::linux::io`,
  `std::linux::fs` and `std::linux::path` declare no `extern c fn`. Only
  `stdlib/darwin*.bot`, `stdlib/windows*.bot` and `stdlib/ffi/c.bot` do.
  * Their system calls end in `botlish_linux_x86_64_syscall` and
    `botlish_linux_aarch64_syscall` (`runtime/syscall.rs`): an inline
    `syscall` or `svc #0` with no libc wrapper and no errno.
  * The hello program writes "Hello, world!" without a C call. Its only
    libc dependencies are the runtime's.
* **The GC, coroutines and the overflow handler.** The collector walks
  frame pointers with stack maps and never unwinds (`runtime/framewalk.rs`).
  The coroutine switch is the runtime's own assembly (`bl_co_switch`,
  `runtime/coroutine.rs`). The overflow handler's body already uses only
  atomics, `write` and `_exit` (`runtime/platform/guard.rs`). Each needs at
  most a different way to make a system call.

So route B is entirely about the runtime crate, `std` and the link. It
changes nothing in Botlish's semantics, HIR or code generation.

## 4. Today's executable: every import and who needs it

**The dependency set is the same for every linker.** All three are PIE,
BIND_NOW. All three name `libgcc_s.so.1`, `libm.so.6`, `libc.so.6` and
`ld-linux-x86-64.so.2`:

| Executable | Linker | Imports | Size (with `debug = 1` debuginfo) |
|---|---|---:|---:|
| hello | rustc | 82 | 11,510,640 B |
| hello | system | 83 | 11,411,152 B |
| hello | stub | 84 | 12,085,781 B |
| threads (`limit.bot`) | rustc | 84 | 11,962,528 B |

`botlish-aot-stub` itself imports 84 symbols from the same four libraries.
The stub linker's executables are that binary plus an image, so they inherit
it. The system linker's runtime archive is linked with
`runtime_system_libraries` (`codegen/aot.rs`): `-lgcc_s -lutil -lrt
-lpthread -lm -ldl -lc`. That list is what rustc reports for the archive
(`native/runtime-archive/libraries.tcl` checks it).

The threads program adds `mmap` (`rt_co_start`'s coroutine stacks, which
its code reaches) and `eventfd` (`runtime::thread::port_of`'s doorbell) to
hello's 82.

The 84 imports, grouped by the code that references them:

| Group | Imported symbols | Referenced by | Route B replacement |
|---|---|---|---|
| C startup and exit | `__libc_start_main`, `exit`, `abort`, `pause`, `__cxa_finalize`; weak `__gmon_start__`, `_ITM_registerTMCloneTable`, `_ITM_deregisterTMCloneTable` | `_start` and `__do_global_dtors_aux` in the crt objects rustc links; `std::rt::lang_start_internal`; `std::process::exit` in `STARTUP` and `linked_main` | the runtime's `_start` (6.3 B1); `exit_group` |
| `std`'s process setup | `fcntl`, `dup`, `open64`, `poll`, `signal`, `sysconf`, `pthread_self`, `pthread_getattr_np`, `pthread_attr_getstack`, `pthread_attr_destroy` | `std::rt::lang_start_internal`, and `aot::rust_process_setup` for system-linked executables: fds 0-2 reopened on `/dev/null`, SIGPIPE ignored, the main thread's stack recorded | the same two effects as raw system calls in `_start`; no main-thread stack query |
| `std`'s own overflow handler | `sigaction`, `sigaltstack`, `mmap64`, `mprotect`, `munmap`, `getauxval`, `pthread_attr_getguardsize`, `gettid` | `std::sys::pal::unix::stack_overflow::imp::{make_handler, drop_handler, signal_handler}`: a second SIGSEGV handler beside the runtime's | nothing: the runtime's guard is the only one needed |
| The runtime's overflow guard | `pthread_self`, `pthread_getattr_np`, `pthread_attr_getstack`, `pthread_attr_getguardsize`, `pthread_attr_destroy`, `sigaction`, `sigaltstack`, `sigemptyset`, `raise`, `write`, `_exit`, `syscall` (gettid) | `platform::linux::current_stack` (glibc's stack and guard report); `platform::guard`'s `install_in`, `fault_handler`, `report_overflow`, `restore_handler` | stacks known by construction (B3); `rt_sigaction` with a restorer, `sigaltstack`, `tgkill`, `write`, `exit_group` (B6) |
| Threads | `pthread_create`, `pthread_join`, `pthread_detach`, `pthread_attr_init`, `pthread_attr_setstacksize`, `pthread_setname_np`, `dlsym`, `sysconf`; `eventfd`, `poll`, `read`, `write`, `close` | `std::thread::Builder` for the worker every worker-policy executable runs its program on (`aot::run`, `runtime/aot.rs:348`) and for each Botlish thread (`runtime/thread.rs:344`); `dlsym` is std's lookup of `__pthread_get_minstack`; the doorbells (`runtime/thread.rs`: `eventfd`, `poll`, `read`, `write`) | raw `clone` threads on stacks the runtime maps, joined by futex (B3) |
| Locks and parking | `syscall` (futex) | `std::sync::{Mutex, Condvar, OnceLock}` and thread parking: `runtime/thread.rs`, `platform/guard.rs`, `ops.rs`'s `TABLE_HASH_KEY` | futex-based lock, condition and once (B5) |
| Thread-locals | `__tls_get_addr`, `__cxa_thread_atexit_impl`, `pthread_key_create`, `pthread_key_delete`, `pthread_setspecific` | `thread_local!` in `platform/records.rs` (the guard record), `callback.rs` (`ACTIVE`), `coroutine.rs` (`POOL`), and std's own | a runtime-owned thread control block in the thread pointer (B4) |
| Memory | `malloc`, `calloc`, `realloc`, `posix_memalign`, `free`; `mmap`, `mprotect`, `munmap`, `sysconf` | Rust's `System` allocator behind every `Box`, `Vec` and `Rc`, **every GC heap object included**: `heap.rs` allocates objects as boxes; `strobj.rs` and `nview.rs` call `std::alloc` directly. `coroutine.rs`'s stacks (`rt_co_start`, `CoStack`) | a global allocator over `mmap` (B2); raw `mmap`/`mprotect`/`munmap`, the page size from `AT_PAGESZ` |
| Environment and arguments | `getenv`, `strlen` | `std::env::var` for the eleven `BOTLISH_NATIVE_*` / `BOTLISH_THREAD_*` variables the runtime reads; `std::env::args_os` in `aot::process_argv` (glibc hands `argc`/`argv` to std) | `envp` and `argv` read from the initial stack in `_start` (B1, B9) |
| Output and files | `write`, `writev`, `open64`, `read`, `close`, `fstat64`, `lseek64`, `statx`, `stat64`, `__errno_location`, `__xpg_strerror_r` | `eprintln!`; the driver protocol's result file and the startup report (`std::fs`, `runtime/aot.rs`); the stub's read of `/proc/self/exe` (`aotimage.rs`); `std::io::Error`'s `Display` (strerror) | `openat`/`read`/`write`/`close`; `core::fmt` into a buffer; a table of errno names (B9) |
| Time | `clock_gettime` | `std::time::Instant`: GC metrics (`heap.rs`), the driver protocol's timings, the bounded waits of `runtime/thread.rs` (`await_end`, the exit join) | `clock_gettime` by raw system call, or through the vDSO (B8) |
| Entropy | `getrandom`, with `poll`, `read` and `close` on its fallback path | `RandomState` in `ops.rs`'s `draw_table_hash_key` (the table hash's hidden key, HASHABLE-AND-KEYED-HASH.md) and `runtime/thread.rs`'s `random_word` (transport identities) | `getrandom(2)` itself (B7) |
| Panics and backtraces | 12 `_Unwind_*` from `libgcc_s`; `dl_iterate_phdr`, `getcwd`, `readlink`, `realpath`, `stat64` | `catch_unwind` in `aot.rs`, `thread.rs` and `callback.rs`; std's panic runtime and its backtrace printer, which reads the executable's debug information | `panic = "abort"` with a panic handler that keeps the `NATIVE BUG` protocol (B10) |
| Compiler-emitted | `memcpy`, `memmove`, `memset`, `bcmp`, `strlen` | code rustc generates throughout | the runtime's own (B11) |
| libm | `log2` | `num_bigint::biguint::convert::{from_radix_digits_be, to_radix_le}` under num-bigint's default `std` feature | `default-features = false` (B11) |

## 5. Route A: a static executable with a libc inside

A static executable has no `PT_INTERP`: the kernel starts it directly. It
runs whatever C library the system has, or none. The libc is inside the
file.

### 5.1 Static glibc: works today

The experiment repeated the rustc linker's own command (`link_rustc` in
`codegen/aot.rs`) with the same startup crate and the same flags, plus
`-C target-feature=+crt-static`. It linked the program object that
`botlish-native object` writes from the program's NIR. For a program that
calls no C and starts on the worker, `link_rustc` adds no link-plan or
startup arguments, so nothing else differs. Every program was then run with
`BOTLISH_NATIVE_RESULT` (the driver protocol) to compare its result:

| Program | Result | Expected |
|---|---|---|
| hello | prints `Hello, world!`, status 0 | the same |
| csv | `value {list {{list {{str name} {str age}}} ...}}` | the same |
| threads | `value {list {{bool false} {bool true} {bool true}}}` | the same (tests/threads.test's `th-limit`) |
| recursion | `error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}` | the same |
| coroutines | `[Event 10, Event 20, Event 30, Event 30]` | the same (COROUTINES.md) |

* Each executable is "static-pie linked": no `INTERP`, a `DYNAMIC` section
  only for its own relocation, a `TLS` segment that glibc sets up.
* The hello program is 12,528,400 bytes, against 11,510,640 dynamic.

What a milestone would change:

* **The link flags.** `crt_args_for` already passes `+crt-static` on
  Windows. On the GNU flavor it would pass it too, for the executables that
  choose it.
* **The other two linkers.** The system linker would link with
  `-static-pie` and the archive's libraries. `botlish-aot-stub` would be
  built with `+crt-static`, so stub-linked executables follow.
* **Tests.** The tests that read dependencies change: system-linker.test's
  `dependencies` and `tests/platform/aot-facts.tcl`.

Its open questions are policy, not technique:

* **Licensing.** glibc is LGPL-2.1. Distributing an executable that
  contains a static copy carries the relinking obligation for statically
  linked works: object files or equivalent, so a user can relink against a
  modified glibc. Every Botlish user who ships an executable would inherit
  that. Dynamic glibc does not have it. Musl is MIT-licensed.
* **Shared C libraries.** A static executable cannot load shared
  libraries. A program that calls C would need its libraries as static
  archives (`extern c library "NAME" static`, NATIVE-LINK-PLAN-MILESTONE-1.md)
  or stay dynamic.
* **glibc's own reservations about static linking** concern NSS, `iconv`
  and `dlopen`. The runtime uses none of them, but a C library a program
  links may. std's `dlsym` of `__pthread_get_minstack` linked and the
  threads ran.
* **Kernel floor.** The binary is tagged "for GNU/Linux 3.2.0".

Static glibc is the cheapest way to make the executable independent of the
system's C library. But it is not libc-less.

### 5.2 Static musl: compiles, refused at startup

`rustup target add x86_64-unknown-linux-musl` installed musl's std.
`cargo build --release --target x86_64-unknown-linux-musl --lib` built the
runtime unchanged. The five programs, linked against it with the same
startup crate, are static-pie executables with no imports. Every one stops
at startup:

```
the program was compiled for a different native runtime build (NATIVE STARTUP)
```

The cause is that the runtime's capability flags name glibc, not Linux:

* **The GC root plan.** `framewalk::NATIVE_FRAME_ROOTS`
  (`runtime/framewalk.rs:124`) is true on Linux only with
  `target_env = "gnu"`. The musl runtime is therefore built on the fallback
  root plan: the shadow stack, no frame walk (WINDOWS-X86-64-MILESTONE-1.md).
* **The fingerprint.** `aotimage::ABI_SCALAR_WORDS` includes that flag. A
  program object generated for the native-frame plan by the glibc driver is
  refused before it runs. That is the fingerprint doing its job.
* **Coroutines.** `coroutine::STACK_SWITCHING` follows
  `NATIVE_FRAME_ROOTS`, so the musl runtime would refuse native coroutines.
  So would `callback::SUPPORTED`, for callbacks.
* **The driver.** `codegen::aot::EXECUTABLES` and `C_CALLS` are
  `target_env = "gnu"` on Linux. `codegen::target::same_target` compares
  the triple's environment, so a glibc driver does not take a musl triple
  for its own.

What musl would need:

* **The capability flags**, extended to musl. Its `pthread_getattr_np`
  must be checked against the guard rules first: a guard is confirmed,
  never assumed (NATIVE-STACK-OVERFLOW.md). Musl reports the main thread's
  stack in its own way.
* **A decision on what musl is.** It could be a target row of its own
  beside linux-x86_64: musl's C ABI family, as windows-x86_64-gnu is
  MinGW-w64's (C-BINDGEN-LAYOUTS.md). C libraries built for glibc do not
  link into a musl executable. Or it could be only a runtime build for
  programs that call no C.
* **Measurements.** Musl's allocator and string functions are known to be
  slower than glibc's on allocation-heavy work. Benchmarks would decide
  whether that matters for the GC's allocation rate.
* **A build-time dependency.** The musl std, a rustup component, becomes
  part of the build.

Musl removes glibc and its licence question, but keeps a libc. It costs
more than static glibc. Its porting work (the capability flags, a second
runtime build, a selection) is about the same shape route B needs. Route B
needs that shape too.

## 6. Route B: no C library at all

### 6.1 The toolchain shape (verified on stable Rust)

There are three ways to build Rust with no libc:

| Way | Status here |
|---|---|
| `x86_64-unknown-linux-none` | In rustc 1.97's target list. Its documentation: tier 3, "no support for host tools, std, or alloc", and "Rust does not yet ship pre-compiled artifacts for this target", so `core` and `alloc` must come from `build-std`. There is no `aarch64-unknown-linux-none`. |
| musl | A libc (section 5.2). |
| **`#![no_std]` + `alloc` on the `-gnu` triples** | The prebuilt `core`, `alloc` and `compiler_builtins` of `x86_64-unknown-linux-gnu` and `aarch64-unknown-linux-gnu` need no libc. Works on stable. |

The experiment for the third way was one small program:

* `#![no_std]`, `#![no_main]`, `extern crate alloc`;
* a `_start` in `global_asm!` that hands the initial stack pointer to Rust;
* a `#[global_allocator]` over the `mmap` system call;
* a `#[panic_handler]`;
* `format!`, `Vec`, `String::from_utf8_lossy` and a 4 KiB slice copy and
  comparison.

It was built with `rustc -C panic=abort -C relocation-model=static -C
link-arg=-nostartfiles -C link-arg=-nostdlib -C link-arg=-static -C
link-arg=-no-pie`. The first link failed on eight undefined symbols. The
program then defined them:

* `memcpy`, `memmove`, `memset`, `memcmp`, `bcmp`, `strlen`: the toolchain
  expects a C library to define these on the `-gnu` triple. On x86-64,
  `rep movsb`/`rep stosb` and loops over volatile reads.
* `_Unwind_Resume` and `rust_eh_personality`: the prebuilt `liballoc`'s
  landing pads and unwind tables name them, although with `panic = "abort"`
  nothing calls them. Stubs that end the process suffice.

The result:

* `./t one "two words"` printed `argc=3 argv=["./t", "one", "two words"]
  sum=522240 eq=true` and exited 0.
* `file`: "ELF 64-bit LSB executable, x86-64, ... statically linked".
* `ldd`: "not a dynamic executable".
* `readelf -l`: no `INTERP`, no `DYNAMIC`, no `TLS` segment.
* 875,352 bytes with debuginfo.

So the third way is the one to take, with stable Rust and the existing
`rustup` toolchain. The experiment ran on x86-64 only. The AArch64 triple's
prebuilt libraries are built the same way, and the first AArch64 step must
confirm that they link the same way.

### 6.2 One runtime, two system layers

The runtime must keep running where it runs today:

* in the driver's process (the JIT, `run`, `bench`, `vms`);
* in native libraries;
* in executables of programs that call C;
* on macOS, Windows and Android.

All of those have a C library and use `std`. So route B is not a rewrite.
It is a second build of the same crate:

* **A cargo feature** (call it `nolibc`) makes the library
  `#![cfg_attr(feature = "nolibc", no_std)]` with `extern crate alloc`.
  It is built with `panic = "abort"`, in its own target directory (cargo
  unifies features within one), as a rlib for the rustc linker and as the
  stub binary and the runtime archive.
* **A system layer** (`runtime::sys`) holds everything that talks to the
  OS: threads, the thread control block, locks, memory mapping, signals,
  entropy, the clock, files, the environment and the process's exit. It
  has two implementations selected by that feature: the current `std` and
  `libc` code, and raw system calls. Code above it stops naming `std::` and
  `libc::` for OS services.
* **`std`-only data types** move to their `core` and `alloc` equivalents
  in both builds:
  * `std::collections::HashMap`/`HashSet` in `vm.rs` (`transfer_plans`, the
    statics set), `metrics.rs` and `aotimage.rs` become `BTreeMap`/`BTreeSet`
    or a no_std hash table;
  * `std::io::Write` used for formatting becomes `core::fmt::Write`;
  * the one `f64` method outside tests that only std has, `trunc` in
    `ops.rs`'s `rt_f64_trunc`, becomes an implementation of the runtime's
    own or the `libm` crate's. The `powi` and `round` calls in `value.rs`,
    `decimal.rs` and `inttext.rs` are in their test modules, which keep
    `std`.

The OS-level uses of `std` and `libc` that move behind the layer were
counted per file. The search was for `std::thread`, `std::fs`, `std::env`,
`std::io`, `std::process`, `std::time`, `std::path`, `std::os`,
`std::panic`, `Mutex`, `Condvar`, `OnceLock`, `HashMap`, `HashSet`,
`thread_local!`, `catch_unwind`, `eprintln!`/`println!` and `libc::`:

| File | Uses |
|---|---:|
| `thread.rs` | 84 |
| `aot.rs` | 45 |
| `platform/guard.rs` | 40 |
| `coroutine.rs` | 24 |
| `aotimage.rs` (the stub's loader) | 17 |
| `syscall.rs` | 9 |
| `platform/records.rs` | 9 |
| `platform/linux.rs` | 8 |
| `heap.rs` | 6 |
| `framewalk.rs` | 6 |
| `ops.rs` | 5 |
| `metrics.rs` | 4 |
| `callback.rs` | 4 |
| `vm.rs` | 3 |
| `ffi.rs` | 2 |

These are about 270 uses in a runtime of about 30,000 lines. Two files
are not in the table: `library.rs` (19) is native libraries' only, and
`platform/macos.rs` and `platform/windows.rs` are other hosts'. By this
search, every other runtime file already uses only what `core` and `alloc`
provide.

### 6.3 Requirements by subsystem

**B1. Process entry.**

* `_start` in assembly, per architecture:
  * x86-64: clear `rbp`, pass `rsp`, align, call into Rust;
  * AArch64: clear `x29` and `x30`, pass `sp`.
* From the initial stack it reads `argc`, `argv`, `envp` and the auxiliary
  vector. It keeps `AT_PAGESZ`, `AT_RANDOM`, `AT_SYSINFO_EHDR` (the vDSO),
  `AT_MINSIGSTKSZ` and `AT_HWCAP`.
* It then does, in every startup, what Rust's runtime does today for
  rustc- and stub-linked executables and `rust_process_setup` does for
  system-linked ones:
  * descriptors 0-2 opened on `/dev/null` when missing (`fcntl`, `openat`);
  * SIGPIPE ignored (`rt_sigaction`).
* Then it calls `start_linked`. Every linker keeps one startup
  (`program::instantiate_linked`, AGENTS.md "The single-file compiler and
  the stub linker").
* `process_argv` reads the argument snapshot from the stack. ARGV.md's
  semantics do not change: raw bytes, nothing validated.
* Exit is `exit_group`. Nothing is buffered, so nothing needs flushing:
  `std::process::exit` flushed Rust's stdout, which the runtime only uses
  for errors.
* **PIE or not.** The simplest link is a non-PIE `ET_EXEC` (`-no-pie`), as
  in the experiment, which loses text ASLR. A static-pie needs the entry to
  apply its own `R_X86_64_RELATIVE` / `R_AARCH64_RELATIVE` relocations from
  `_DYNAMIC` before it touches a global. That is what glibc's
  `_dl_relocate_static_pie` does, and it is a few dozen lines. Recommended,
  to keep today's ASLR.

**B2. Memory allocator.**

* Every GC heap object is a Rust allocation today: boxes in `heap.rs`, one
  block per String in `strobj.rs`, `alloc_zeroed` in `nview.rs`. That is
  glibc's `malloc`.
* Route B needs a `#[global_allocator]` over `mmap`. It must be:
  * thread-safe: Botlish threads each run a Vm and allocate concurrently;
  * fast for the GC's many small objects;
  * returning large blocks to the kernel.
* The choices: an allocator of the project's own (size classes, a
  per-thread cache in the thread control block of B4), or a vendored
  `no_std` allocator crate over the system layer's `mmap`.
* **It can be built and measured under glibc first**: `#[global_allocator]`
  works in a `std` build, so the allocator can be compared with `malloc`
  on `bench/` before anything else changes (section 11, step 3).
* This is the largest single piece of work and the main performance risk.
  A heap of the GC's own (segregated pages, no `Box` per object) would be
  a further step. Route B does not need it.

**B3. Threads.**

Every worker-policy executable runs its program on a second thread:

* the worker is `std::thread::Builder` with `BOTLISH_NATIVE_STACK_BYTES`,
  1 GiB by default (`runtime/aot.rs:348`);
* each Botlish thread is one more (`runtime/thread.rs:344`), named, with
  at least 1 MiB of stack.

Route B starts them with `clone` itself:

* **The stack.** The runtime maps the stack and a `PROT_NONE` guard below
  it. The guard is confirmed because the runtime made it. That replaces
  glibc's stack report (`platform::linux::current_stack`,
  `pthread_getattr_np`) and keeps NATIVE-STACK-OVERFLOW.md's rule.
* **The flags.** `CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND |
  CLONE_THREAD | CLONE_SYSVSEM | CLONE_SETTLS | CLONE_PARENT_SETTID |
  CLONE_CHILD_CLEARTID`.
* **Join.** A futex wait on the child-tid word, which the kernel clears and
  wakes when the thread is gone.
* **The stack's release.** A thread cannot unmap the stack it runs on. Its
  joiner frees it after the wake. A thread nobody joins ends with a short
  assembly sequence (`munmap` then `exit`) that touches no stack.
* **Names.** `prctl(PR_SET_NAME)` on the new thread replaces
  `pthread_setname_np`.
* **The main thread.** Under the worker policy it only starts and joins.
  It needs no discovered stack. The startup report's `stack` line describes
  the stack the runtime mapped for the Vm's thread.
* **The process's end.** The rules of `runtime/thread.rs` stay: stop
  requests, the bounded join, 64 guard records. Exit is `exit_group`, which
  ends every thread, as glibc's `exit` does today.

**B4. Thread-local state.**

* `thread_local!` is std's, and `#[thread_local]` is unstable, so a stable
  no_std runtime has neither. Today's thread-locals:
  * `platform/records.rs`: this thread's guard record, read in the signal
    handler, with a releaser at thread end;
  * `callback.rs`: `ACTIVE`;
  * `coroutine.rs`: `POOL` and its flag;
  * std's own.
* They become fields of a **thread control block** the runtime allocates
  per thread, reached through the thread pointer:
  * x86-64: the FS base, set by `CLONE_SETTLS`, or by `arch_prctl(ARCH_SET_FS)`
    for the main thread, and read as `fs:[0]`;
  * AArch64: `TPIDR_EL0`, read with `mrs`.
* One instruction, no lock, async-signal-safe: the guard's handler can read
  it, as AGENTS.md requires.
* Destructors become explicit steps of the runtime's thread exit (the
  guard record's release, the coroutine pool's).
* The build must keep **no ELF TLS at all**. Its absence is checkable
  (`readelf -l`: no `TLS` segment, as in the experiment). One
  `#[thread_local]` slipping in would need a `PT_TLS` setup nobody does.

**B5. Locks.**

* `std::sync::{Mutex, Condvar, OnceLock}` (`runtime/thread.rs`'s transport
  tables and joins, `platform/guard.rs`, `ops.rs`'s `TABLE_HASH_KEY`)
  become a futex-based mutex, condition variable and once of the runtime's
  own.
* They use `FUTEX_WAIT_PRIVATE` and `FUTEX_WAKE_PRIVATE`, with the timed
  waits that `await_end` and the exit join need. `Arc` and the atomics are
  `alloc` and `core`, unchanged.

**B6. Signals and the stack guard.**

* **`sigaction` becomes `rt_sigaction`** with the kernel's own structure:
  handler, flags, restorer, an 8-byte mask. It is not glibc's.
  * On x86-64 the kernel requires `SA_RESTORER` and a restorer the caller
    supplies: two instructions, `mov eax, 15` (`rt_sigreturn`) and
    `syscall`.
  * On AArch64 the kernel returns through its vDSO's trampoline, so the
    restorer is optional.
* **The rest are direct system calls.** `sigaltstack` maps one-to-one.
  `raise` in `defer` becomes `tgkill(getpid(), gettid(), signal)`. `_exit`
  becomes `exit_group`.
* **The alternate stack's size.** `SIGSTKSZ` comes from `AT_MINSIGSTKSZ`
  where the kernel gives it, kept at the 64 KiB floor of `install_in`.
* **std's second SIGSEGV handler disappears** with std. The guard's own
  rules do not change (AGENTS.md "The native stack guard"): it classifies,
  reports and ends the process.
* **Coroutine stacks** (`coroutine.rs`: `mmap`, `mprotect`, `munmap`,
  `sysconf`) use raw calls, with the page size from `AT_PAGESZ`.

**B7. Entropy.**

* Two keys must stay secret and unpredictable:
  * the table hash's key (`ops.rs`'s `draw_table_hash_key`; the hidden
    secret of HASHABLE-AND-KEYED-HASH.md);
  * the thread transport's identities (`runtime/thread.rs`'s
    `random_word`).
* Today both come from std's `RandomState`. Route B calls `getrandom(2)`
  directly: number 318 on x86-64, 278 on AArch64, flags 0, retried on
  `EINTR`. The kernel floor for it is 3.17.
* The auxiliary vector's `AT_RANDOM` gives 16 random bytes at startup.
  That covers the table key but not the thread keys drawn later, so it is
  no replacement.
* Never a fixed seed. That rules out COROUTINE-PREREQUISITES.md's earlier
  advice of "a fixed hasher". The advice was for the metrics map, which
  needs no secret, and it still applies there (B2's `BTreeMap`).

**B8. Time.**

* `Instant` is used for GC metrics, the driver protocol's timings and the
  thread module's bounded waits. Botlish programs have no clock today: no
  `stdlib/` module reads one.
* `clock_gettime(CLOCK_MONOTONIC)` as a raw system call is enough to begin
  with.
* The vDSO's `__vdso_clock_gettime` (found from `AT_SYSINFO_EHDR` by a
  small ELF symbol lookup) is the later optimization. It becomes relevant
  once a program-visible clock exists.

**B9. Environment, files and messages.**

* **The variables the runtime reads**, from the `envp` `_start` keeps:
  * `BOTLISH_NATIVE_ALLOC`, `_COMPILE_US`, `_COROUTINE_STACK_BYTES`,
    `_GC_MIN`, `_GC_STRESS`, `_RESULT`, `_RUNS`, `_STACK_BYTES`,
    `_STARTUP_REPORT`, `_UNWIND_CHECK`;
  * `BOTLISH_THREAD_EXIT_JOIN_US`.
* **The files** use `openat`, `read`, `write` and `close`:
  * the driver protocol's result file and the startup report, which are
    `std::fs` today;
  * the stub loader's read of `/proc/self/exe` (`aotimage.rs`).
* **Messages** are formatted with `core::fmt` into a buffer, then written
  with `write`.
* **One visible difference to settle**: `std::io::Error`'s `Display` text
  ("No such file or directory (os error 2)"), which the runtime prints in
  its `NATIVE IO` messages, comes from glibc's `strerror`. Route B needs a
  table of errno texts with the same words, or messages that are the same
  in both builds. Tests that pin such a message decide which.

**B10. Panics.**

* `catch_unwind` does not exist without std. With `panic = "abort"`, a
  `#[panic_handler]` must keep today's protocol:
  * `native executable panicked (NATIVE BUG)` on standard error, status 1,
    never Rust's 101. `tests/main-thread-startup.test`'s
    `mts-panic-native-bug` pins it for every linker.
  * Under the driver protocol, the result file's error line.
* **One behavior changes.** Today a Botlish thread's panic is caught
  (`runtime/thread.rs:397`) and joined as `ThreadFailed` with identity
  `NATIVE BUG`. Under abort it ends the process.
  * A panic is a runtime bug either way. A process-terminal `NATIVE BUG` is
    consistent with the guard's terminal overflow.
  * But it is a documented outcome, so the change needs a decision and a
    line in BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md's
    successor.
* `callback.rs`'s `catch_unwind` guards C callbacks, which a libc-free
  program cannot have (section 8).

**B11. Memory functions and math.**

* **The memory functions.** `memcpy`, `memmove`, `memset`, `memcmp`,
  `bcmp` and `strlen` must be the runtime's own.
  * On x86-64, `rep movsb`/`rep stosb`, which recent processors make fast
    (ERMS), as in the experiment.
  * On AArch64, loops written so that LLVM does not recognize them as a
    `memcpy` and call themselves: volatile accesses or `asm!`.
  * glibc's are vectorized and tuned. String- and List-heavy benchmarks
    must be compared.
* **libm's `log2`** goes with `default-features = false` on `num-bigint`
  and `num-traits`. Without its `std` feature num-bigint estimates sizes
  with integer `ilog2` (COROUTINE-PREREQUISITES.md, B.2). This is worth
  doing for the glibc build too: it drops `libm.so.6`.
* **The two prebuilt-library stubs.** `_Unwind_Resume` and
  `rust_eh_personality` stay stubs that end the process (6.1).

**B12. AArch64.** The same design:

* system call numbers from the generic table: `getrandom` 278, `clone`
  220, `futex` 98, `rt_sigaction` 134;
* the thread pointer in `TPIDR_EL0`;
* no signal restorer needed;
* the memory functions in AArch64 code.

The stub linker stays x86-64's only (AGENTS.md). On linux-aarch64, route B
goes through the rustc and system linkers.

## 7. The three linkers, the startups and the runtime's identity

**The rustc linker.**

* `STARTUP` becomes a `#![no_std] #![no_main]` crate that only references
  `botlish_program`, or nothing at all, with `_start` the runtime's.
* The link gets `-C panic=abort` and `-nostartfiles -nostdlib -static`
  (plus `-static-pie` or `-no-pie`, B1).
* `libbotlish_native.rlib` is the `nolibc` build's, from its own target
  directory beside the driver's. `link_rustc` must find it as it finds
  today's.

**The system linker.**

* A second runtime archive, the `nolibc` build of `native/runtime-archive`,
  linked with no C library: `cc -nostdlib -static`, or `ld` alone, since
  nothing of a C compiler driver is needed.
* `runtime_system_libraries` is empty for it, and `libraries.tcl` checks
  each archive against rustc's own account.

**The stub linker.**

* `botlish-aot-stub` built `nolibc`. Its loader (`aotimage::main`: read
  `/proc/self/exe`, `mmap` with `MAP_FIXED_NOREPLACE`, `mprotect`) uses raw
  system calls.
* Then every stub-linked executable is libc-free. That is the single-file
  compiler's path for programs that call no C (`auto`). The single
  executable would then emit libc-free executables with no toolchain on the
  machine at all.

**The identity of the runtime.**

* Code generated for one runtime must never run on the other. The ABI
  fingerprint already refuses a root-plan mix (`NATIVE_FRAME_ROOTS` is one
  of its words). A word for the system layer, libc or kernel, makes a
  mismatch an error at startup rather than a crash.
* Linking the wrong archive is refused by the archive's identity record
  (`aotimage::identity_record`), as target support packages are
  (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md).

**The selection.**

* Which runtime an executable links is a property of the executable,
  chosen when it is emitted. It is never a language construct, and never
  read from the environment it later runs in: the precedent is
  `-native-startup` (MAIN-THREAD-STARTUP-MILESTONE-1.md).
* An option such as `-native-runtime libc|kernel` (the names are this
  audit's) with the driver's `--runtime`.
* A program that calls C (`calls_c`, any `links`) is refused with the
  kernel runtime before anything is linked, with a message naming the C
  declarations. It is never silently linked with glibc instead.
* `auto` picks the kernel runtime for programs that call no C once it
  passes the whole executable matrix (section 9).
* The HIR, the front-end cache's key and the compilation target do not
  change: the program and its machine code are the same.

## 8. What stays on a C library

* **Programs that call C.** `extern c fn`, `extern c library`, C callbacks,
  and every package with C or Rust-over-C code:
  * `event_loop_linux` (epoll through a C adapter);
  * `process_linux`;
  * `http` (Hyper and BoringSSL);
  * `raven`;
  * the SDL3 programs (Icy Tower).

  C code calls `malloc`, reads errno through `__errno_location` (C-FFI
  error capture reads it the same way), and runs on threads glibc can
  serve. It needs its C library's process. A program that needs both is
  route A's static glibc or musl, or stays dynamic.
* **Native libraries** (`-emit-native-library`): a host process loads them,
  and it has its own C library and threads.
* **The driver**: the JIT runs in the driver's process, on glibc. So does
  every test that runs the runtime there (`run`, `vms`, the Rust unit
  tests). The kernel layer is tested through executables only.
* **Android, macOS and Windows.**

One consequence for the standard library: `std::event_loop`'s only Linux
driver today is the C package. A libc-free program can use the
deterministic driver and threads, but not epoll, until a driver made of raw
system calls exists. That driver would be a Botlish module over the
transports, which needs no C.

## 9. The verification route B needs

**What every executable must show.**

* Structural facts, checked in `tests/platform/aot-facts.tcl`: no `INTERP`,
  no `DYNAMIC` (or only a static-pie's own), no `TLS`, no undefined symbol.
* **A run with nothing beside it**: an empty container (`FROM scratch`),
  added to `single/smoke-test.sh`'s containers. Stock Ubuntu containers
  have a glibc and cannot show its absence.

**The test matrix.**

* Every executable test file run with the kernel runtime, on every linker.
  This is a CI job beside `stub-linker` and `system-linker` in
  `.github/workflows/tests.yml`, under `BOTLISH_NATIVE_GC_STRESS=1` too, on
  x86-64 and arm64.
* The files that matter most: `tests/native-executable.test`,
  `aot-stub-linker.test`, `system-linker.test` (the three startup reports
  equal), `main-thread-startup.test` (the panic protocol),
  `native-stack-overflow.test`, `coroutines.test`, `threads.test` (63
  workers and their guard records, the overflow on a worker),
  `native-program-output.test` and `argv.test`. Then the golden suites
  through executables.

**The runtime's identity.**

* The fingerprint word, with the refusal of a mixed link in both
  directions.
* `cargo test` for the system layer's pieces that can run under std: the
  allocator, the futex locks, the errno table.

**Mutants.**

* `audit/native-aot/tools/mutate.tcl` and `audit/native-stack/tools/mutate.tcl`
  gain mutants of the new entry, guard and thread code. Examples: a guard
  page left unmapped, the restorer dropped, the child-tid wait skipped.

**Performance.**

* `bench/` against the glibc build: allocation-heavy, string-heavy and
  thread workloads.
* `bench/native-stack-guard.tcl` for the guard.

## 10. Risks and costs

* **Allocator performance and fragmentation** (B2) is the main risk. It can
  be measured early under glibc.
* **Memory-function performance** (B11): glibc's are vectorized per CPU
  feature. `rep movsb` is good on recent x86-64 and poor on some older
  processors.
* **Toolchain drift.** The stubs in 6.1 exist because of how the prebuilt
  `liballoc` is compiled, which can change between Rust releases. CI's
  runners moved from Rust 1.99.1 to 1.100.0 on 2026-11-14 and two tests
  changed results. A test that links the kernel runtime with the toolchain
  in use must catch such a change at once.
* **Two system layers to maintain.** Every OS service the runtime adds
  later needs both. This is the cost of keeping the JIT and libraries on
  `std`, and it is lower than moving them.
* **Debugging.** gdb sees the threads as LWPs but has no `libthread_db`
  view of them. Tools that interpose glibc (`LD_PRELOAD`, `ltrace`, some
  profilers' allocator hooks) do not apply to a static executable.
* **Kernel floors.** `getrandom` needs 3.17. `MAP_FIXED_NOREPLACE`, which
  the stub loader already uses, needs 4.17. Nothing else listed here is
  newer.

## 11. Roadmap

Each step stands alone and leaves every test green.

1. **Shrink today's imports. These are cleanups that pay off on glibc too.**
   * `default-features = false` on `num-bigint` and `num-traits` drops
     `libm`.
   * `BTreeMap`/`BTreeSet` for the runtime's hash maps.
   * `getrandom(2)` itself for the two keys.
   * `core::fmt` for the runtime's messages.
2. **Decide route A.** If a static executable is the goal, add static glibc
   (5.1) or musl (5.2) as a link-time choice and stop here.
3. **The system layer under std.** Route the runtime's OS services through
   `runtime::sys` with only the libc implementation. Then give the raw
   implementations of signals, memory mapping, entropy, the clock and files
   to the glibc build too, behind the same interface: they work beside
   glibc. Build the allocator as a `#[global_allocator]` and measure it
   against `malloc`.
4. **The kernel runtime.** Add the `nolibc` feature, `_start`,
   static-pie self-relocation, the thread control block, `clone` threads,
   futex locks, the panic handler and the memory functions. Then the stub
   binary, the rustc startup and the second runtime archive, the
   fingerprint word, `-native-runtime`, and the CI job of section 9. Do
   x86-64 first.
5. **linux-aarch64**, through the rustc and system linkers.
6. **Make it the default** for programs that call no C, starting with
   `auto`. Then the single executable's stub-linked output is libc-free.
7. **Later, separately**: a Linux event-loop driver of raw system calls (a
   Botlish module, no C), so libc-free programs get epoll.

## Appendix A. Reproducing the measurements

```bash
cargo build --release --manifest-path native/Cargo.toml
```

```bash
LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 main.tcl -emit-native-executable PROGRAM.bot
```

```bash
readelf -d PROGRAM; nm -D --undefined-only PROGRAM | wc -l
```

The program object: `-aot-run -aot-keep` keeps the NIR, which the driver
turns into the object alone.

```bash
native/target/release/botlish-native object PROGRAM.o PROGRAM.nir && nm -u PROGRAM.o
```

The attribution walks `objdump -d -C --no-show-raw-insn` output. It tracks
the enclosing function (`^ADDR <NAME>:$`) and collects every
`<SYMBOL@GLIBC...>` or `<SYMBOL@GCC...>` a line references, per symbol.

Static glibc (5.1) is the rustc linker's own command with the `STARTUP`
text as `startup.rs` and one more flag:

```bash
rustc --edition=2024 --crate-name=botlish_program --target=x86_64-unknown-linux-gnu -C opt-level=2 -C force-frame-pointers=yes -C relocation-model=pic --extern botlish_native=native/target/release/libbotlish_native.rlib -L dependency=native/target/release/deps -C link-arg=PROGRAM.o -C target-feature=+crt-static startup.rs -o PROGRAM
```

Musl (5.2) is the runtime built with `--target x86_64-unknown-linux-musl
--lib` in a target directory of its own, and the same command with
`--target=x86_64-unknown-linux-musl` and that directory's rlib and `deps`.

General-runtime coroutines need `BOTLISH_NATIVE_COROUTINE_FUSION=0` when
the object is emitted. Otherwise fusion compiles the principal program's
coroutine into its caller.

## Appendix B. What changed since COROUTINE-PREREQUISITES.md's Appendix B

That appendix measured 81 imports at `f7bb13c` and proposed a removal order.
Since then:

* **Removed.** The thread-local current program moved into the Vm
  (PER-THREAD-RUNTIME-STATE-MILESTONE-1.md).
* **Not taken.** The "root coroutine" that would have removed the worker
  thread. The worker is still `std::thread`.
* **New dependencies on threads.** Botlish-owned threads
  (BOTLISH-OWNED-THREADS-AND-CROSS-THREAD-ACTORS-MILESTONE-1.md) make
  `pthread_create`/`join`/`detach`, eventfd doorbells and futex locks a
  semantic dependency, not only the worker's. Per-thread guard records
  make thread-local state part of the overflow handler.
* **Entropy is now a security property.** `getrandom` serves the table
  hash's secret and the transport's identities, not only the metrics map.
* **Three linkers and three startups** (stub, system, rustc) now exist and
  share one startup function. Each must change together in route B.
* **The target check moved.** `codegen::aot` no longer refuses everything
  but `target_env = "gnu"` in the link step. `EXECUTABLES`, `C_CALLS` and
  `NATIVE_FRAME_ROOTS` encode it now. Section 5.2 shows that is where musl
  stops.
