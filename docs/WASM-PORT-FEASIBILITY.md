# WebAssembly: browsers, server runtimes and Cloudflare Workers

What it would take to run Botlish on WebAssembly, assessed separately for
browsers, for server-side wasm runtimes, and for a JS/TS Cloudflare Worker
that calls a Botlish kernel compiled to wasm.

This is a feasibility study, written before any implementation.

* **No production code was changed.** Every experiment ran on throwaway
  copies in a scratch directory (Appendix A).
* Code claims cite `path:line` at commit `b0ae98fe` (2026-11-14).
* **It builds on [CRANELIFT-WASM.md](CRANELIFT-WASM.md).** That study
  (written against `f6207f4`, about 2026-10-03) settles the code generator
  in depth: Cranelift cannot emit wasm, and a CLIF→wasm lowering was
  prototyped. It also covers a shadow-stack root mode, the link and a
  Wasmtime host. It assumed no WASI. This study:
  * re-checks it at HEAD (section 3);
  * adds what it left out: WASI, coroutines, threads, the event loop,
    platform I/O, the C FFI, packages, entropy and the compiler itself;
  * splits the environments.
* **Evidence tags:**
  * [run]: measured here;
  * [inspection]: read in the code at `b0ae98fe`;
  * [source]: a primary external source, listed in Appendix B;
  * [inferred]: a reading that nothing here measured or stated.
* `main` was red when this was written, with a fix underway. Nothing here
  depends on CI, and no workflow was run.

## Outcome

There are three things one could call "a wasm port". Their feasibility
differs more by *what* is ported than by *where* it runs.

| Route | Browser (JS host) | Server (WASI runtime) | JS/TS Cloudflare Worker calling a Botlish kernel |
|---|---|---|---|
| **C** -- the C backend's freestanding C, compiled by clang for wasm32 | **Works today** for its subset (Int, Bool, enums, structs, loops, declared errors). One 3.5–4.8 KB module with no imports printed exactly what `-backend interp` prints [run]. | The same module runs on any engine: it has no imports at all. | Works for integer kernels once the C backend emits `exported c fn` entry points. Today it exports only `NAME_run`, which takes no inputs. |
| **N** -- the native backend's NIR, lowered to wasm, linked with the Rust runtime compiled for wasm32 | Feasible, and the largest job. Coroutines need JSPI or Asyncify. There is no stdio or filesystem, and threads become Web Workers. | **Feasible, and the best fit for full programs.** Wasmtime shares Cranelift's lineage and has WASI 0.2/0.3. Coroutines need Asyncify, a compiler transform, or Wasmtime's experimental stack switching. Threads move into the embedder. | **Feasible, and the smallest native-backend deliverable:** library mode (`exported c fn` as wasm exports). There are no coroutines at the boundary, and no threads, event loop or I/O in the kernel. |
| **T** -- the compiler itself (Tcl 9) running in wasm | **Feasible now as a playground:** the same WASI module behind a JS WASI shim, about 3–3.5 MB compressed with its sources. It checks and runs programs on the Tcl backends; native execution is not included. | **Works today.** Tcl 9.0.1 builds for `wasm32-wasip1` with no change to Tcl's source. `-check`, `interp` and `compile` matched native byte for byte on 51 of 51 runs under Wasmtime 50, at 1.2–1.6× native time [run]. | Not useful: a Worker cannot compile wasm at run time, and a kernel is built ahead of time anyway. |

**What changed since CRANELIFT-WASM.md (section 3):**
* **The runtime still builds for wasm32.** It builds for
  `wasm32-unknown-unknown`, `wasm32-wasip1` and `wasm32-wasip2` once the
  code generator's crates are target-gated, with 10–12 errors at four
  places:
  * `thread.rs`'s guard-record calls;
  * `malloc`/`free` in `library.rs`;
  * argv in `aot.rs`;
  * two header-size assertions that assume 64-bit pointers.

  With those patched, it links [run]. The cfg discipline of the macOS and
  Windows ports carried over: every newer subsystem (coroutine switching,
  the stack guard, callbacks) compiles to its "unsupported" branch on wasm.
* **The runtime is about 2.7× larger.** As a wasm module with all 210
  exports kept it is 661 KB, 217 KB gzipped [run]. CRANELIFT-WASM.md
  measured a linked program module at about 240 KB, and a linked program
  drops what it does not use.
* **The old 32-bit correctness bugs are still there [inspection]:**
  * `MAX_COLLECTION_LENGTH = SMALL_MAX as usize` (`value.rs:105`)
    truncates.
  * `rt_list_get`'s `(i as usize) < items.len()` (`ops.rs:3253`) wraps an
    index of 2^32 to 0.
* **Cross-target emission now exists, but it does not cover wasm yet.**
  `codegen/target.rs`'s `RuntimeCapabilities` lets a driver emit for another
  target (Android). Code generation still reads the *driver's own* runtime
  constants, though: frame roots, the stack guard and stack switching.
  `emits` refuses any target whose runtime differs
  (`codegen/target.rs:207-260`). wasm differs on all three, so the explicit
  target of CRANELIFT-WASM.md's P3 is still to be built. The capability
  struct is its natural shape.

**What the language now needs that the earlier study never faced (section 4):**
* **Coroutines are load-bearing.** The following are all coroutines:
  * the golden test runner (`std::test::run`), and so every one of the 120
    golden suites;
  * `std::event_loop`'s tasks and `std::actor`'s actors;
  * `std::tree::walk`;
  * every `dfa` recognizer.

  On wasm the runtime is on the fallback root plan, which refuses
  coroutines (`coroutine.rs:121`). Fusion cannot stand in:
  * AGENTS.md forbids it making a program run where the general runtime
    refuses it.
  * The event loop and actors store their handles, which fusion always
    keeps on the general runtime.
* **Threads assume shared memory.** The cross-thread transport is a
  process-global, mutex-guarded table with an eventfd per port
  (`thread.rs:256`, `:842`). That has to become host-mediated for
  share-nothing wasm instances.
* **The keyed table hash loses its secret without WASI.** On
  `wasm32-unknown-unknown`, std's `RandomState`, which
  `draw_table_hash_key` reads (`ops.rs:1715`), is deterministic: three
  instances produced the same hash, with no imports [run]. A browser or
  Workers build must take entropy from the host (`crypto.getRandomValues`),
  or HASHABLE-AND-KEYED-HASH.md's HashDoS resistance silently disappears.
  WASI builds get it from `random_get`.
* **None of the Linux-native packages port.** `event_loop_linux`, `http`,
  `process_linux` and `raven` do not. A WASI build needs a platform layer of
  its own: a `std::wasi`, built the way `std::darwin` is built over
  libSystem, but over wasi-libc.

**Recommendation, in order.**
1. **Kernels first.** Library mode on `wasm32-unknown-unknown` with a JS host
   serves browsers and Workers alike. It avoids coroutines at the boundary
   (exports may not suspend), threads, the event loop and platform I/O.
   About **30–50 person-days** (section 9).
2. **C-backend exports**, as a cheap early option for integer kernels:
   about **3–6 person-days**, before or beside 1.
   * **Independently,** the compiler on WASI and as a browser playground
     (route T, section 8) works now and needs packaging: about **8–15
     person-days**.
3. **Server programs on WASI next** (Wasmtime). This adds the WASI platform
   layer, the C FFI on wasm, coroutines, an event-loop driver and threads in
   the embedder: about **60–110 person-days** on top of 1.
4. **Full browser programs last.** This adds the JSPI event-loop driver,
   threads on Web Workers and a browser CI lane: about **20–40
   person-days** on top of 3's coroutine work.

Full parity in both environments is therefore roughly **110–200
person-days**. The ranges are estimates by analogy with CRANELIFT-WASM.md's
calibrated milestones and with this repository's port milestones; nothing
measured them.

## Contents

1. [Scope and method](#1-scope-and-method)
2. [Three routes](#2-three-routes)
3. [CRANELIFT-WASM.md re-checked at HEAD](#3-cranelift-wasmmd-re-checked-at-head)
4. [What the language needs now](#4-what-the-language-needs-now)
5. [Browsers](#5-browsers)
6. [Server runtimes (WASI)](#6-server-runtimes-wasi)
7. [A JS/TS Cloudflare Worker calling a Botlish kernel](#7-a-jsts-cloudflare-worker-calling-a-botlish-kernel)
8. [The compiler itself in wasm](#8-the-compiler-itself-in-wasm)
9. [Plan and effort](#9-plan-and-effort)
10. [Decisions for the maintainer](#10-decisions-for-the-maintainer)
* [Appendix A: experiments](#appendix-a-experiments)
* [Appendix B: external facts](#appendix-b-external-facts-as-of-2026-11-14)

---

## 1. Scope and method

* **Environments.**
  * **Browsers:** Chrome, Firefox, Safari, with the page's JavaScript as the
    host.
  * **Server runtimes:** Wasmtime, WasmEdge, Wasmer, wazero, WAMR, Node's
    `node:wasi`, and the edge platforms built on them.
  * **Cloudflare Workers:** a JS/TS Worker that imports a wasm module
    compiled from Botlish and calls it. Workers are V8 isolates, so
    technically this is a browser-like JS host with platform limits
    (section 7).
* **Questions.**
  * What runs today?
  * What does each route need, per environment?
  * What did the language gain since CRANELIFT-WASM.md that a port must
    carry?
  * What does it cost?
* **Method.**
  * Every claim about the code was checked at `b0ae98fe`.
  * The runtime was rebuilt for three wasm targets.
  * The C backend's output was compiled for wasm32 and run under V8.
  * A Worker-shaped handler called a wasm kernel.
  * The compiler's Tcl was built for WASI and run (section 8).
  * External facts come from primary sources, with dates (Appendix B).

## 2. Three routes

* **C: the C backend (`ccompile/`, C-COMPILE-FREESTANDING-MILESTONE-1.md).**
  * **What it is.** Analyzed HIR becomes freestanding C11: no allocation,
    no I/O, no `main`, only `stdint.h`, `stdbool.h` and `stddef.h`.
  * **What wasm takes.** `clang --target=wasm32 -ffreestanding -nostdlib`
    compiles it with no change. A program that needs a runtime service (an
    Int outside `int64_t`) links the example arena provider.
  * **Its subset** (`ccompile`, section 6 of that report): no Strings, no
    Lists of unknown length, no closures, no coroutines, no floating point.
  * **Its interface.** Every function is `static`, and the only entry point
    is `NAME_run(NAME_value *)`, the program's value [inspection, run]. A
    kernel called with arguments needs the backend to compile
    `exported c fn` declarations as real C entry points, with boundary
    admission (section 7.2).
* **N: the native backend (`native/`), as CRANELIFT-WASM.md designs it.**
  * NIR, unchanged, is lowered to wasm: CLIF→wasm is recommended there, and
    NIR→wasm was validated as the fallback.
  * The Rust runtime is compiled for wasm32 and linked into one module.
  * GC roots live on a shadow stack in linear memory, because wasm hides its
    call stack.
  * This is the only route to the whole language.
* **T: the compiler.**
  * `main.tcl`, the front end and the two Tcl backends (`interp`,
    `compile`) need only a Tcl 9 interpreter. A grep finds no `exec` in
    `core/`, `hir/`, `surface/`, `compiler/` or `service/` [inspection].
  * The native backends exec the Rust driver, and are out of reach in wasm.
  * Section 8 reports the experiment.

## 3. CRANELIFT-WASM.md re-checked at HEAD

| Its finding | At `b0ae98fe` | Evidence |
|---|---|---|
| Cranelift has no wasm ISA or object format | Unchanged. Cranelift is pinned at 0.135; 0.136 (Wasmtime 49) and 0.137 (Wasmtime 50) still target only native ISAs and Pulley. | [source] |
| The runtime builds for wasm32 after target-gating, with one error (the String header size) | Builds for `wasm32-unknown-unknown`, `wasip1` and `wasip2`, after gating plus four sites, 12 / 10 / 10 errors. See the patch list below. | [run] Appendix A.1 |
| The runtime has no imports on `wasm32-unknown-unknown` | Still none. On `wasip1` it imports `random_get`, `environ_get`, `environ_sizes_get`, `clock_time_get`, `fd_write`, `poll_oneoff` and `proc_exit`. | [run] A.2 |
| Its size: about 240 KB for a linked program module | The whole runtime, every export kept, is 661,221 B (216,818 B gzipped) on `unknown-unknown` and 699,136 B on `wasip1`. A linked program keeps only what it reaches, so this is an upper bound. | [run] A.2 |
| 32-bit hazards (P1): index casts, the collection limit, `Header` alignment | Still present: `value.rs:105`, `ops.rs:3253` (`rt_list_get`), and no `target_pointer_width` anywhere in the runtime. | [inspection] |
| Header layouts assume 8-byte fields (P5) | Still true, and wider. Besides `strobj.rs:108`, `BytesObj` (`bytesobj.rs:74`), which is newer than the study, asserts a 64-bit size. | [run] |
| Five host-dependent checks need an explicit `Target` (P3) | Partly addressed. `codegen/target.rs` now models a target's runtime (`RuntimeCapabilities`: frame roots, stack guard, stack switching) for cross-emission, but `emits` only *refuses* a target whose capabilities differ from the driver's own. Code generation still reads `host_runtime()`. wasm needs those three to be parameters. `codegen/mod.rs:262` (stack probes) still reads `cfg!`. | [inspection] |
| The fallback root plan has no CI coverage | No longer true. Windows' `roots` job builds `--features fallback-roots` and runs its Rust tests and GC workloads (`.github/workflows/windows-x86_64.yml:649`). The proposed `ShadowOnly` mode, with no depth token (about 1.9× on fib), does not exist. | [inspection] |
| Stack overflow is handled only on Linux x86-64 | No longer true natively: the guard covers Linux x86-64 and AArch64, macOS AArch64 and Windows x86-64. On wasm it stays the engine's trap, which every runtime reports distinctly (section 6). | [inspection], [source] |
| Effort: 46–76 pd for wasm execution plus `http_request` | The codegen core stands. Its scope omitted everything in section 4, which section 9 adds. | |

**The four build fixes (Appendix A.1), and what each stands for:**

| Error site | Cause | A real fix would be |
|---|---|---|
| `thread.rs:294`, `:298`, `:320`, `:355`, `:388`, `:391`, `:1188` | Unconditional `super::platform::reserve_guard`, `guard_mode`, `install_reserved_guard` and `free_guards`. `platform` is cfg'd to the four guarded hosts (`runtime/mod.rs:26`). | A wasm threads design (section 4.2). Until then, `std::thread::start` refused on wasm. |
| `library.rs:562`, `:848` | `libc::malloc`/`free`, which `wasm32-unknown-unknown` lacks | Rust's allocator, or an exported allocator, for owned results |
| `aot.rs:72` | `process_argv` has unix and windows branches only | A wasm program boundary (CRANELIFT-WASM.md §4.7) |
| `bytesobj.rs:74`, `strobj.rs:108` | Header sizes assume 64-bit `usize` | P5: 8-byte-slot fields, with assertions on both widths |

## 4. What the language needs now

Each subsystem below is newer than CRANELIFT-WASM.md, or was outside its
scope.

### 4.1 Coroutines

* **Where they are load-bearing [inspection]:**
  * the golden test framework's runner (`stdlib/test.bot:9`, `:66`): all 120
    suites import `std::test`;
  * `std::event_loop`, whose tasks are coroutines adopted by `Loop`;
  * `std::actor`, `std::actor::remote`, `std::tree::walk`;
  * the DFA recognizers (surface/dfa.tcl lowers every `dfa` to coroutine
    functions);
  * emission claims' sources.
* **Reach in the examples.**
  * Of the 123 `.bot` files in `examples/`, 41 name a coroutine, the event
    loop, actors, `std::test`, `std::tree` or a `dfa` directly. 21 use
    platform I/O and 12 the C FFI. 54 use none of these directly [run],
    which is an upper bound, since imports add more.
* **Why wasm cannot run them today.**
  * Native coroutines switch stacks with assembly or Windows fibers, and
    need native-frame roots.
  * On wasm, `STACK_SWITCHING` and `NATIVE_FRAME_ROOTS` are false
    (`coroutine.rs:121`, `framewalk.rs:124`), and the fallback plan refuses
    coroutines (`rt_co_start`: NATIVE UNSUPPORTED). This is by design: a
    suspended coroutine's shadow slots would break the shared shadow
    stack's order.
* **Fusion is not an answer for wasm.**
  * Fusion compiled 2,006 of the suite's 2,721 coroutine sites
    (COROUTINE-FUSION-MILESTONE-1.md).
  * It keeps every handle that is returned, passed or stored. That
    includes every event-loop task and actor.
  * AGENTS.md requires that fusion never make a program run where the
    general runtime refuses it (its "Coroutine fusion" rules). So wasm needs
    a general mechanism, with fusion as a speed layer above it.

**Every general mechanism needs the same runtime work.** Each coroutine gets
its own shadow-stack segment, and the collector scans every suspended
segment. This is the shadow-stack analogue of the native collector's walk
of suspended and resumer stacks. The mechanisms then differ in how they
suspend the wasm frames:

| Mechanism | Where it works | Cost | Fit |
|---|---|---|---|
| **Core stack switching** (proposal) | Phase 3. Flag-only in V8 and Firefox, absent in Safari. Experimental in Wasmtime, off by default, Cranelift on x86-64 Linux/macOS only. No LLVM support [source]. | None at run time once shipped | Not usable for a product in 2026. Revisit when it ships. |
| **JSPI** | Ships in Chrome 137, Firefox 153, Safari 27, Node ≥ 24.20; not on WASI [source] | Every switch goes through a JS promise and the microtask queue. V8 reserves about 1 MB of stack per suspended call; Firefox caps continuation stacks at about 2 GiB in total [source, partly inferred]. Only wasm frames may sit between the export and the import. | Right for *one* suspension point, the event loop's wait (section 5). Too heavy for general coroutines. A loop with a thousand tasks would hold about a GB of reserved stacks. |
| **Asyncify** (binaryen `wasm-opt --asyncify`) | Every engine | About 50% larger and up to 2× slower for instrumented code, about 5× for interpreter-like functions. Import lists remove most of it [source]. | Usable everywhere. The HIR's `coroutines` side table already knows which functions may yield (`hir/coroutines.tcl:370`), so instrumentation can be limited to those, plus the runtime's coroutine primitives. It adds binaryen (C++) to the link. |
| **A compiler-side resumable lowering** | Every engine | Spills only at yields; no tool dependency | The largest compiler job. It would compile yielding functions as state machines that save live registers to their segment, building on fusion's template and state-register machinery. Rust frames must never sit between a yield and its resumer: `rt_call_value` (COROUTINE-PREREQUISITES.md R7) would need inline indirect calls on wasm. |

**Recommendation.** Use Asyncify, limited by the static yield set, for the
first wasm coroutine support: it is the only one that works on every engine
now. Keep the compiler-side lowering as the follow-up if its code size or
speed costs matter. In browsers, JSPI serves the event loop's wait only.

### 4.2 Threads

* **Today [inspection].** `std::thread` starts an OS thread
  (`std::thread::Builder`, `thread.rs:344`) that makes its own VM from the
  program image. VMs share nothing and exchange transfer bytes.
* **Where it touches process memory.** The transport keeps its tables in
  process-global mutexes (`REGISTRY`, `thread.rs:256`; `TRANSPORT`,
  `:842`). Each port is an eventfd doorbell. Each thread holds a guard
  record (`records.rs`).
* **The fit with wasm.** The share-nothing semantics fit wasm, where an
  instance per thread is the natural unit:
  * **Browsers:** an instance per Web Worker. Bytes travel by `postMessage`,
    which needs no SharedArrayBuffer or cross-origin isolation [inferred].
    Blocking operations (a join, a wait for a message) need JSPI in the
    waiting instance: a Worker cannot block without `Atomics.wait`, and
    that needs a SharedArrayBuffer.
  * **Server:** an instance (a `Store`) per OS thread, made by the
    embedder. Wasmtime 47 removed wasi-threads, and component-model threads
    are incomplete [source], so guest-spawned threads are not an option.
  * **What changes.** The transport moves into the host. For Wasmtime, the
    existing Rust transport code can largely move into the embedder,
    exposed through imports [inferred]. The guard reservation becomes moot:
    the engine bounds the stack.
* **Until then,** `std::thread::start` is refused on wasm, as a native
  library's instance refuses it today.

### 4.3 The event loop

* **What exists.** `std::event_loop` is ordinary Botlish over a `Driver`
  context trait (EVENT-LOOP-MILESTONE-1.md). The deterministic driver runs
  on every backend.
* **What a wasm port adds.** Drivers:
  * **WASI:** a driver whose wait blocks in `poll_oneoff` (0.2) or on
    pollables (0.2/0.3), through a `std::wasi` module.
  * **Browsers and Workers:** the page's event loop owns the thread, so a
    wait must give control back to JS. Two shapes:
    * **JSPI (recommended).** The wait suspends the whole run until a timer
      or event promise settles, and the run stays one whole call.
    * **A `turn` per JS tick.** This is an iterate ABI, which
      RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md's rules reject
      ("no resumable or host-driven Vm"). It would need a language-design
      decision.
  * Safari 27 is the first Safari with JSPI. Older browsers would need the
    wait instrumented by Asyncify.

### 4.4 Platform I/O and the target model

* **Targets.** A target is a row of `core/cabi.tcl`'s table
  (`core/cabi.tcl:166-190`), with the model OS + architecture + C ABI
  family. wasm needs:
  * `wasm32-wasip1` and `wasm32-wasip2` rows, with OS `wasi` and
    architecture `wasm32`;
  * a browser row (`wasm32-unknown-unknown`);
  * a new data model, **ILP32** (int, long and pointers 32 bits). Every
    model today is LP64 or LLP64, so std::ffi::c's widths and every 32-bit
    hazard in section 3 become reachable;
  * `charSigned 1` (clang's wasm32 `char` is signed) [inferred from clang's
    defaults].
* **Platform namespaces.** `core::cabi::platforms` maps `std::linux`,
  `std::darwin` and `std::windows`. A WASI port adds `std::wasi`. Its
  natural design is `std::darwin`'s (MACOS-AARCH64-MILESTONE-8.md): C
  functions with -1 and errno, opaque IO, path and fs contexts. wasi-libc
  provides `write`, `read`, `open`, `close` and `__errno_location` with
  POSIX conventions, so `std::darwin::io` is close to a template
  [inferred]. Programs written against `std::io` stay portable, as the
  2048 demo's per-platform entry files show.
* **Browsers** have no stdio or filesystem: a browser platform is host
  imports. The obvious name is taken: `std::web` is the URI and email
  module (`stdlib/web.bot`).
* **Startup.** argv and the exit status exist on WASI. In a browser the
  host supplies them, or nothing.

### 4.5 The C FFI and callbacks

* **Static linking only.** `extern c fn` on wasm means C compiled to wasm32
  (wasi-sdk for WASI) and statically linked by `wasm-ld`. Dynamic
  `extern c library "X"` has no meaning; only `static` and `static at`
  apply (NATIVE-LINK-PLAN-MILESTONE-1.md).
* **The wasm32 C ABI** needs its own lowering in `foreign_call`. Scalars are
  `i32`/`i64`/`f32`/`f64`. Variadic arguments go in a buffer in linear
  memory, which is a new convention beside the `%al` and Win64 stubs
  [inferred from clang's wasm32 ABI].
* **Pointers become 32 bits.** The C address word and std::ffi::c's
  pointer types narrow with them.
* **The binding generator** gains a row: wasi-sdk's clang as the target
  compiler.
* **Callbacks.** On the fallback plan the runtime refuses them
  (`callback.rs:87`: `SUPPORTED` needs `NATIVE_FRAME_ROOTS` and
  `CROSSES_TRANSITIONS`). With shadow-stack roots there is no frame walk to
  cross, so a nested callback only pushes more shadow frames. Callbacks may
  well be *simpler* on wasm, where a function pointer is a table index
  [inferred].
* **Browsers** have no C library unless one is shipped in the module.

### 4.6 Entropy

* **The secret.** The keyed table hash's secret is drawn once, lazily, from
  std's `RandomState` (`ops.rs:1715`).
* **Where that works.** On WASI it reads `random_get`.
* **Where it does not.** On `wasm32-unknown-unknown` it is a constant
  (Appendix A.3). Every browser or Workers build must import entropy from
  the host (`crypto.getRandomValues`), drawn at first use as today.
* **When it is drawn matters.** Workers refuse randomness at global scope
  (section 7.1), and a native library's `NAME_create` runs module
  initialization, which may already hash (a module-level MutableMap). So a
  host must create the instance where entropy is available: in Workers,
  inside the first request.
* **This is a correctness requirement.** HASHABLE-AND-KEYED-HASH.md
  promises a process-local secret. It is not an optimization.

### 4.7 Stack depth

* **Natively,** programs get a 1 GiB worker stack, and overflow is
  NATIVE LIMIT STACK.
* **On wasm,** the engine's stack is the bound:
  * Wasmtime's `max_wasm_stack` defaults to 512 KiB and is configurable.
  * Browsers and Workers use about 1 MB and cannot be configured [source].
* **The error carries over.** Every runtime reports exhaustion as a
  distinct trap (Wasmtime `Trap::StackOverflow`, V8 `RangeError`, WasmEdge,
  Wasmer, wazero and WAMR codes [source]). The host maps it to the same
  NATIVE LIMIT STACK, which is already terminal.
* **The depth does not.** In a browser, deep recursion hits the limit far
  earlier: 5,000–10,000 Botlish frames on Node's default stack
  (CRANELIFT-WASM.md §8.2). Tests must keep asserting codes, never depths.

### 4.8 Packages

| Package | On wasm |
|---|---|
| `event_loop_linux` (epoll and an eventfd) | Linux only: replaced by WASI and browser drivers |
| `http` (Hyper and BoringSSL over epoll) | Does not port. WASI has `wasi:http`, browsers and Workers have `fetch`, each a new package. |
| `process_linux` (pidfd) | No processes exist in wasm |
| `raven` (X11 and Vulkan) | No |
| `boringssl` | It could be compiled for WASI, but nothing needs it there |

### 4.9 The library boundary

* **Exports fit wasm.** `exported c fn` (NATIVE-LIBRARY-MILESTONE-1.md)
  takes `int`, `bool`, `Float64` or `str` and returns one of them or unit.
  It may not suspend or require a context (`hir/exports.tcl:148`). That is
  exactly a wasm export:
  * `int64_t` becomes a JS BigInt;
  * `double` becomes a number;
  * `str` is UTF-8 bytes and a length in linear memory;
  * errors are data (status, identity, fields), ready to become typed JS
    exceptions.
* **What changes for wasm:**
  * `malloc`'d results come from the module's allocator, and the host needs
    an exported allocation function to pass strings in;
  * symbol localization (`objcopy`) becomes the module's export list;
  * pthread-key thread words become plain globals (one thread);
  * the library's own stack check becomes the shadow stack's depth bound.
* **The JS side can be generated.** The React Native integration
  (`integrations/react-native/`) is a tool package that reads the library
  manifest and generates a TypeScript-typed package. A web/Workers tool
  would do the same with an ES module and a `.d.ts`.
* **Bulk binary data has no type at the boundary yet.** There is no `Bytes`
  or `MutableBytes`, so binary data would cross as UTF-8 text.

## 5. Browsers

**Route C works today [run].**
* The C backend's output for `traffic.bot` and `factorial.bot` compiled with
  clang 18 for wasm32:
  * modules of 3,535 and 4,829 bytes with no imports;
  * the output `[State {light: Light::Green, left: 19}, 224, 8, 250, 5]` and
    `265252859812191058636308480000000`, the same as `-backend interp`.
* A browser loads the same module with `WebAssembly.instantiate`.

**Route N: what a browser port needs** beyond the codegen core of
CRANELIFT-WASM.md:

| Need | Status |
|---|---|
| Engine features | Only the wasm 2.0 set the runtime's target enables. Chrome 96, Firefox 89, Safari 16.4 [source]. |
| GC roots | A shadow stack: the fallback plan, then `ShadowOnly` |
| Coroutines | Asyncify, limited to yielding functions (section 4.1) |
| Event loop | A JSPI-based driver: Chrome 137, Firefox 153, Safari 27 (2026-09-14) [source] |
| Threads | Web Workers with a host transport. Blocking needs JSPI in the waiting instance (4.2). |
| I/O | Host imports only (console, fetch). There is no filesystem. |
| Entropy | A host import, mandatory (4.6) |
| Stack depth | About 1 MB of engine stack, not configurable (4.7) |
| Size | The runtime is at most 217 KB gzipped (A.2), plus program code |
| memory64 | Not in stable Safari: 27.3 is in beta [source]. Target wasm32, as CRANELIFT-WASM.md did. |

**The browser use cases, cheapest first:**
1. **Kernels** called from page JS (section 7's design, with the browser
   loading the module itself).
2. **Whole programs** that print to a page element.
3. **Event-driven programs** on the JSPI driver.
4. **Multi-threaded programs** on Web Workers.

## 6. Server runtimes (WASI)

**Route C** runs unchanged: a module with no imports.

**Route N fits servers best, with Wasmtime first.**
* **Lineage.** Wasmtime is built on Cranelift, and CRANELIFT-WASM.md's
  prototypes already ran on Wasmtime 48.
* **Features.** Wasmtime 50 enables the whole wasm 3.0 set by default. It
  has had WASI 0.3 (the async component model) on by default since 46, and
  WASI 0.2.12 too [source].
* **Rust.** `wasm32-wasip1`, `wasip2` and, since 1.100 (2026-11-12),
  `wasip3` are Tier 2 [source].
* **WASI's interfaces** give the platform layer a real OS surface: clocks,
  random, filesystem, sockets, cli and http are all Phase 3 [source].

**What a server port adds**, beyond the codegen core:

| Need | Design |
|---|---|
| Platform layer | `std::wasi` (io, fs, path) over wasi-libc through the C FFI, on the `std::darwin` model (4.4) |
| C FFI | The wasm32 C ABI, static archives, varargs in memory, a wasi-sdk binding-generator row (4.5) |
| Coroutines | Asyncify (4.1). Wasmtime's stack switching is experimental and x86-64-only: not a basis. |
| Event loop | A WASI driver (4.3) |
| Threads | One store per thread, transport in the embedder (4.2) |
| Host | CRANELIFT-WASM.md's `botlish-wasm` host crate, now with WASI |
| Traps | `Trap::StackOverflow` to NATIVE LIMIT STACK; memory, epoch and fuel limits to their NATIVE LIMIT codes (CRANELIFT-WASM.md, Appendix C) |

**The Cranelift and Wasmtime pins are coupled** (CRANELIFT-WASM.md §1.2).
* Each Cranelift line belongs to one Wasmtime line. The repository is on
  Cranelift 0.135 (Wasmtime 48); the latest is Wasmtime 50.0.1 on
  Cranelift 0.137 [source].
* **Changes since 48** that matter here:
  * Wasmtime 47 made GC and exceptions default;
  * Wasmtime 47 removed wasi-threads;
  * Wasmtime 46 made WASI 0.3 default.
* A host crate either pins a patched 48.x or moves the driver to the same
  Cranelift line as a newer Wasmtime. That is a decision (section 10).

**Other runtimes and platforms.**
* Every runtime reports stack exhaustion distinctly.
* Only Wasmtime and WasmEdge have the component model. wazero, WAMR and
  `node:wasi` are WASI preview 1 only, and Node calls its WASI unsuitable
  for untrusted code [source].
* A `wasip1` build is the lowest common denominator.
* **Edge platforms are tight [source]:**
  * **Fastly Compute:** `wasip1` only; 128 MB heap; a 1 MB stack; 50 ms of
    CPU per request.
  * **Akamai Functions** (Spin): 20 or 128 MiB of memory; 500 or 1,000 ms
    of CPU; WASI 0.3.2 on Wasmtime 50.
* Kernels and short request handlers fit these limits. Deep recursion does
  not.

## 7. A JS/TS Cloudflare Worker calling a Botlish kernel

**The scenario.** A Worker written in JS/TS owns the request, the event
loop, I/O and any other platform API. A Botlish module compiled to wasm is
a pure function library it calls.
* For a Botlish port this is library mode in a V8 isolate. Everything in
  section 4 except 4.6 (entropy), 4.7 (stack depth) and 4.9 (the library
  boundary) drops out.
* **No coroutines at the boundary:** an export may not suspend.
* **No threads:** Workers have none.
* **No event loop or I/O:** JS owns both.
* **No C FFI and no platform namespace.**

### 7.1 What Workers impose [source]

| Property | Fact | Consequence |
|---|---|---|
| Loading | `.wasm` files are uploaded as separate modules; `import m from "./kernel.wasm"` yields a `WebAssembly.Module`. Runtime compilation (`WebAssembly.compile`, `instantiate(buffer)`, the streaming forms) is forbidden by the docs and enforced by workerd. The docs recommend instantiating at top level. | The kernel is compiled ahead of time, by `main.tcl` in the build. It cannot compile Botlish at request time (route T is moot here). |
| Size | 64 MiB uncompressed, free and paid, since 2026-09-04. Before that the limit was 3 MB (free) or 10 MB (paid) *compressed*. | A kernel plus the runtime is well under 1 MB (A.2) |
| Memory | 128 MB per isolate, the JS heap and wasm allocations combined. One isolate serves many concurrent requests; going over recycles it (error 1102). | The Botlish heap lives in linear memory, which never shrinks: a long-lived isolate keeps its high-water mark. Size the GC to the limit (`Heap::configure`, CRANELIFT-WASM.md P6). Synchronous kernel calls cannot interleave on the isolate's single thread, so the library's one-call-at-a-time rule holds [inferred]. |
| CPU | 10 ms (free); 30 s by default, up to 5 min (paid) | Compute kernels fit. `Date.now()` does not advance while code runs, so time kernels outside the Worker. |
| Startup | 1 s of CPU for global-scope code, top-level instantiation included | Instantiating a module under 1 MB fits [inferred]. Creating the Botlish instance does not belong there (next row). |
| Randomness | `crypto.getRandomValues` exists, but throws at global scope ("generating random values are not allowed within global scope", workerd's `crypto.c++`) | Instantiate the module at top level, but call `NAME_create` (module initialization) and the first export inside a request, so that the entropy import (4.6) is never called at global scope |
| Features | "The same set as Chrome"; workerd pins V8 15.8. No threads and no SharedArrayBuffer (`SetAllowAtomicsWait(false)`), no stack switching. JSPI is present in V8 but undocumented by Cloudflare. | The wasm 2.0 set is enough. The kernel needs neither JSPI nor threads. |
| WASI | An experimental preview-1 shim only | Use `wasm32-unknown-unknown` with JS glue, as workers-rs does |
| Instance lifetime | A module-scope instance serves later requests, but isolates may be evicted at any time | Keep only caches in the Botlish instance, never state a request depends on |

### 7.2 Route C for Workers: integer kernels with no Strings

**Experiment [run] (A.5).**
* The C backend's own `gcd` instance from `traffic.bot` was given a C entry
  point by a two-line stand-in for what `exported c fn` support would emit.
* It compiled to a **295-byte** module with no imports.
* A Worker-shaped ES module (`export default { fetch }` over a
  `WebAssembly.Module` given at load, instantiated once with
  `new WebAssembly.Instance`) answered `/gcd?a=1071&b=462` with
  `{"gcd":"21"}`. The arguments arrived as BigInt.

**It ran under V8 in Node 22, not under workerd** [inferred: same engine
family and the same API path].

**The experiment also shows why the boundary must check admission.**
* `gcd` takes `Ticks`, `Int in 0..1000`.
* The stand-in passed 2^63−1 straight into code compiled under that proof.
  Here the answer happened to be right.
* A generated entry point must admit every argument as the native library's
  does: parameters of `int`, `bool`, `Float64` or `str` only, with
  conversions in the body.

**What route C needs for Workers.**
* **Exports:** the C backend compiles `exported c fn` declarations as
  non-`static`, prefixed C functions with the library ABI's types and
  statuses. About 3–6 pd with tests and a JS harness.
* **Its subset stays:** no Strings, Float64, Lists of unknown length,
  closures or allocation. That rules out text-processing and floating-point
  kernels until the C backend grows.

### 7.3 Route N for Workers: the whole language in a kernel

**Shape.**
* `main.tcl -emit-native-library NAME` with a wasm target writes
  `NAME.wasm`, the manifest (schema 2) and a TypeScript wrapper generated
  from it (4.9).
* The wrapper instantiates the module once per isolate, at top level, with
  an entropy import. It calls `NAME_create` lazily, on the first request
  (7.1), then the exports per request.
* It converts:
  * `int` to BigInt, rejecting non-integers;
  * `Float64` to a number, where NaN and ±infinity are the ABI's BOUNDARY
    error;
  * `str` to UTF-8 bytes copied in and out of linear memory;
  * a non-zero status to a thrown `BotlishError {status, identity, fields}`.

**It needs** the kernel deliverable of section 9: 30–50 pd.

**Limits of v1:**
* Coroutines *inside* a kernel are refused, as on the fallback plan today.
  That includes DFA recognizers and `std::tree::walk`, until section 4.1's
  mechanism lands (or decision 3 in section 10).
* Recursion depth is the isolate's (4.7).
* Binary data crosses as UTF-8 text (4.9).

**Alternatives, briefly.**
* **Cloudflare Containers** (GA 2026-04-13) run `linux/amd64` images in
  Firecracker microVMs behind a Worker and a Durable Object [source]. A
  Botlish native executable would run there today, with no wasm [inferred],
  at 1–3 s cold starts and container pricing.
* **Dynamic Workers** accept wasm bytes at run time in a separate isolate
  [source]. Nothing here needs that.

## 8. The compiler itself in wasm

**The compiler, with its two Tcl backends, runs on WASI today, unmodified,
with no change to Tcl's source either.** No published Tcl 9 WASI build
existed [source]. Emscripten builds of Tcl 8.6 do (tcltk.wasm), and Magic
VLSI's merged browser build of Tcl 9 (2026-10-07) had to replace Tcl's
threaded notifier.

### 8.1 The build [run]

* **Inputs.** The pinned Tcl 9.0.1 source (single/build.sh's tarball,
  SHA-256 checked), built for `wasm32-wasip1` with wasi-sdk 34 (clang
  23.1).
* **`unix/configure`:**
  * the flags `--host=wasm32-wasi --disable-shared --enable-zipfs
    --with-system-libtommath=no --disable-load`;
  * wasi-libc's emulated signal, process-clock, getpid and mman libraries;
  * `-DTCL_THREADS=0`. Tcl 9's headers still honour it, and it avoids the
    select notifier's helper thread, which Magic's build had to replace at
    run time.
* **Four small compatibility headers and a stub library** (172 lines in
  all). They declare what wasi-libc hides on `wasip1`: sockets,
  `fork`/`exec`, `pwd.h`, `grp.h`, `netdb.h` and the like. Every one fails
  with ENOSYS or "not found".
* **The link.** An 8 MiB linear-memory stack (`-Wl,-z,stack-size`). The
  zipfs archive `make` appends to the binary is cut off, because Wasmtime
  rejects trailing bytes.
* **Size:**
  * `tclsh.wasm`: 2,412,268 B (756 KB gzipped);
  * stripped: 1,929,777 B (594 KB gzipped);
  * Tcl's script library: a 1.16 MB zip;
  * the compiler's sources (`main.tcl`, `core/`, `compiler/`, `hir/`,
    `surface/`, `service/`, `stdlib/`): 1.65 MB gzipped.

### 8.2 What ran [run]

* **Under Wasmtime 50.0.1:** 17 programs (all 16 of `examples/surface/`,
  plus a mixed program and a rejected one), each with
  `main.tcl -backend interp`, `-backend compile` and `-check`.
  * **51 of 51 runs matched native `tclsh9.0` byte for byte:** stdout,
    stderr and exit status.
  * The 51 saved output pairs were re-compared here, read-only: all
    identical.
* **Deep programs** (a 1,000-deep nested expression, a 300-deep List,
  interpreted recursion 13,000 deep) were identical too. Recursion 100,000
  deep fails with TCL LIMIT STACK, exactly as natively (the program
  recursion limit).
* **Golden suites** (`tests/golden/run.tcl -backends interp,compile`; 40
  suites):
  * 32 are identical apart from timing figures (re-checked here).
  * The other 8 fail with `SURFACE MODULE UNKNOWN-TARGET`. They import
    `std::ffi::c` or `std::linux::*`, which needs a compilation target, and
    a compiler running on a `wasi`/`wasm32` host has no host target row.
    With `-target linux-x86_64`, `hashable.bot` ran identically. This is a
    policy gap, not a defect: decision 8 in section 10.
* **Node 22's `node:wasi`:** 54 of 54 runs identical. One golden suite
  (`fold-loops.bot`) crashed Node in V8's GC, entered from uvwasi's
  fast-call path. With `--no-turbo-fast-api-calls` it ran identically. That
  is a Node bug, in code a browser's JS WASI shim does not use.
* **Not available:**
  * the native backends (`NATIVE NOT-BUILT`: the Rust driver is a native
    program);
  * `exec`, sockets and processes.
* **Not tried:** the language server over stdio, and the front-end cache on
  a writable preopen.

### 8.3 Speed and limits [run]

| Median wall time (ms) | native | Wasmtime | Node 22 |
|---|---|---|---|
| tclsh `puts hi` | 7 | 30 (cached) | 176 |
| a mixed program, `interp` | 324 | 423 (1.3×) | 577 (1.8×) |
| a mixed program, `compile` | 262 | 391 (1.5×) | 503 (1.9×) |
| a mixed program, `-check` | 282 | 389 (1.4×) | 466 (1.7×) |
| a 1,000-deep expression, `-check` | 1,162 | 1,681 (1.45×) | 1,736 (1.5×) |
| recursion 13,000 deep, `interp` | 3,027 | 4,948 (1.6×) | 4,338 (1.4×) |
| golden `values.bot` | 4,564 | 6,711 (1.5×) | 6,184 (1.35×) |
| golden `fold-loops.bot` | 16,704 | 21,881 (1.3×) | about 22,000 (with the workaround) |

* **Startup.** Compiling the 2.4 MB module costs 600–714 ms without
  Wasmtime's cache, 27–33 ms with it, and 10–13 ms precompiled (`.cwasm`).
  A deployment ships the precompiled form.
* **Stacks: there are two.**
  * **The linear-memory stack.** The compiler's own walks keep C recursion
    shallow (Tcl's NRE engine and DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-
    MILESTONE-1.md's segments), so every compiler run above passed even
    with wasm-ld's default 64 KiB. A pure-Tcl probe of nested command
    substitution needs 8 MiB for 10,000 levels.
  * **The engine stack.** Wasmtime's default `max_wasm_stack` (512 KiB)
    traps that probe at 500 levels, and raising it fixes that. None of the
    compiler's runs reached it.
  * Browsers fix the engine stack at about 1 MB. That matters only for
    deep Tcl-level nesting, which the compiler avoids by design.

### 8.4 What it means

* **Server (WASI).**
  * **It works today:** `-check`, `interp` and `compile` run as a
    sandboxed WASI module at 1.2–1.6× native time, about 30 ms to start
    when precompiled.
  * **Uses:** a compile and check service in a wasm sandbox, or a CI step
    that runs the reference interpreter in isolation.
  * **What productizing takes:**
    * a build recipe beside `single/basekit.sh`;
    * the compiler packed with Tcl's library in one zipfs archive (the
      experiment showed Tcl mounts its library from an appended zip by
      itself);
    * the host-target policy (decision 8);
    * a CI lane running part of the Tcl suite under Wasmtime.
  * **Edge platforms are a poor fit.** Checking a small program costs
    200–400 ms of CPU, against Fastly's 50 ms per request [source].
* **Browser playground.**
  * **The shape:** the same `wasip1` module behind a JS WASI shim with an
    in-memory filesystem (the compiler's sources and Tcl's library,
    possibly one zip), in a Web Worker, since a run is synchronous.
  * **Speed:** V8 ran it at 1.2–2× native.
  * **Download:** about 3–3.5 MB compressed in all (the module, Tcl's
    library, the sources), cached after the first visit.
  * **What it gives:** check, run (`interp`, `compile`) and Compilerpedia
    in the page, with no server.
  * **What it does not give:** native execution. That would need route N's
    code generator compiled to wasm, emitting a module the page
    instantiates, as in CRANELIFT-WASM.md's two-module mode (O4).
    Browsers allow runtime compilation; Workers do not.
* **Cloudflare Workers:** not useful. The 128 MB isolate would hold it, but
  Workers have no native WASI and a 1 s startup budget, and a kernel is
  compiled ahead of time anyway.

## 9. Plan and effort

* Effort is in person-days (pd), given as ranges.
* "CW" marks CRANELIFT-WASM.md's milestone of that name. Its figure is
  carried over, adjusted where section 3 found the work larger or smaller.
* Like that study's, these are dominated by what the repository expects of
  a landed feature:
  * byte-identical native output;
  * GC-stress lanes;
  * parity tests across backends;
  * mutants and fuzzers;
  * documentation.
* **They are estimates, not measurements.**

### K. Kernels: library mode on `wasm32-unknown-unknown`, JS hosts (browsers, Workers)

| Item | pd |
|---|---|
| CW P1: 32-bit correctness (still open, section 3) | 1–1.5 |
| CW P5: 8-byte-slot layout and header assertions on both widths, now including `BytesObj` | 2–3.5 |
| CW P6: dependency gating, `Heap::configure`, `Instant`; plus the `thread.rs`, `library.rs` and `aot.rs` sites (section 3) | 1.5–2.5 |
| CW P7: a typed helper descriptor. The runtime now exports 214 `no_mangle` symbols. | 2–4 |
| CW P3, narrowed: code generation from the *target's* `RuntimeCapabilities` rather than `host_runtime()`, and the fallback plan chosen by target (section 3) | 2.5–4 |
| CW W1: the CLIF→wasm lowering, re-checked against today's `clif.rs` | 6–10 |
| CW W3, adapted: the wasm object writer, and the link of a *library* (export list, no program startup) | 4–6 |
| The library boundary on wasm (4.9): allocation and owned results, statuses, one thread, the shadow-stack depth bound | 3–5 |
| The entropy import (4.6) and heap configuration from the host | 0.5–1 |
| A tool package generating the ES module and `.d.ts` from the manifest, on the React Native tool's model | 4–7 |
| Tests and CI: a V8 (Node) parity lane for exports, GC stress on wasm, an optional workerd smoke test | 5–8 |
| **Total** | **31.5–52.5, about 30–50** |

### C. C-backend exports

| Item | pd |
|---|---|
| `exported c fn` as C entry points with boundary admission, the manifest, tests and a JS harness | 3–6 |

Strings and floating point in the C backend are milestones of their own and
are not estimated here.

### T. The compiler on WASI, and a browser playground

| Item | pd |
|---|---|
| A reproducible WASI build of Tcl 9.0.1 (the recipe and compatibility stubs of section 8.1), beside `single/basekit.sh` | 2–3 |
| Packing the compiler and Tcl's library into one zipfs archive; the host-target policy (decision 8) | 2–4 |
| A CI lane running part of the Tcl suite and some golden suites under Wasmtime | 2–4 |
| A browser loader: a JS WASI shim with an in-memory filesystem, a Web Worker, an example page | 2–4 |
| **Total** | **8–15** |

### S. Server programs on WASI (Wasmtime), on top of K

| Item | pd |
|---|---|
| The program boundary on wasm (CW W2): argv, exit status, stdio through WASI, fatal records | 3–5 |
| Target rows (`wasm32-wasip1`/`p2`), the ILP32 model, the `std::wasi` platform (io, fs, path over wasi-libc), golden and portable-I/O coverage | 10–16 |
| The C FFI on wasm: the wasm32 C ABI in `foreign_call`, static archives, varargs in memory, the binding-generator row, callbacks re-enabled on shadow roots | 8–14 |
| Coroutines (4.1): shadow-stack segments, the collector over suspended segments, Asyncify limited by the yield set, parity and GC stress | 15–30 |
| A WASI event-loop driver | 4–8 |
| Threads: one store per thread, the transport in the embedder | 10–18 |
| The host crate with WASI, trap classification, the CI lane and GC stress (CW W4, W5) | 10–17 |
| **Total** | **60–108, about 60–110** |

### B. Full browser programs, on top of K and S's coroutine work

| Item | pd |
|---|---|
| The browser host: loader, host I/O imports, the JSPI event-loop driver | 6–10 |
| Threads on Web Workers: the transport over `postMessage`, blocking through JSPI | 8–14 |
| Browser CI: Node and headless Chromium/Firefox (Playwright is preinstalled in this container) | 4–8 |
| Coroutine engine differences, if S used anything but Asyncify | 0–10 |
| **Total** | **18–42, about 20–40** |

### Totals

| Deliverable | pd |
|---|---|
| K alone (kernels for browsers and Workers) | 30–50 |
| C alone (integer kernels through the C backend) | 3–6 |
| T alone (the compiler on WASI and in a browser playground) | 8–15 |
| K + S (server programs) | 90–160 |
| K + S + B (full parity in both) | 110–200 |

* **Worth landing anyway.**
  * Of K's items: P1's `align(8)`, P3, P6 and P7, as CRANELIFT-WASM.md
    already argued.
  * Of S's: the coroutine-segment collector, which would also let the
    fallback root plan run coroutines.
* **Before starting.** Per AGENTS.md, read the latest `gc-stress` run on
  `main` before starting anything that touches roots or allocation (P1, P3,
  P5, P6, the coroutine work).

## 10. Decisions for the maintainer

1. **Which deliverable first?** The recommendation is K (kernels), then S,
   then B. If browsers' whole-program use matters more than kernels, B's
   JSPI driver moves up, but it still needs S's coroutine work.
2. **The coroutine mechanism on wasm:**
   * Asyncify (a binaryen dependency at link time, any engine);
   * a compiler-side resumable lowering (no dependency, the largest
     compiler job);
   * waiting for core stack switching (no shipping engine in 2026).

   The recommendation is Asyncify, limited by the static yield set, with
   the compiler-side lowering as the follow-up.
3. **May fusion make a coroutine run where the general runtime refuses it?**
   AGENTS.md says no. Keeping that rule means kernels in v1 refuse even
   coroutines that fusion would compile (DFA recognizers, tree walks).
   Relaxing it for wasm would make whether a program runs depend on an
   optimization succeeding, which is what the rule prevents. The
   recommendation is to keep it.
4. **Bytes at the C export boundary?** Binary kernels need `Bytes` or
   `MutableBytes` parameters and results in the library ABI. That would
   also reach the React Native tool and every manifest consumer.
5. **A name for the browser platform namespace,** since `std::web` is taken.
6. **The Wasmtime pin for a host crate:** a patched 48.x on Cranelift 0.135,
   or moving the driver to the Cranelift line of a newer Wasmtime (50:
   0.137). The latter is a bump of the native backend itself.
7. **`rustc` at wasm link time,** or CRANELIFT-WASM.md's two-module mode
   (O4). For kernels built in CI the former is fine. A playground would want
   the latter.
8. **The host target of a compiler running on wasm.** `hostTarget` finds no
   row for `wasi`/`wasm32`, so a program importing `std::ffi::c` or
   `std::linux::*` is `UNKNOWN-TARGET` unless `-target` is given (8.2). The
   options:
   * require `-target`;
   * default to a wasm target once one exists;
   * have the packaging pass the target the user chose.

   Never guess a native target for such a host.

---

## Appendix A: experiments

Everything ran in a scratch directory outside the repository, at `b0ae98fe`,
with:
* rustc 1.97.0;
* clang 18.1.3 and `wasm-ld`;
* Node 22.23.4;
* Tcl 9.0.1 from Ubuntu's packages (AGENTS.md's recipe).

### A.1 The runtime for three wasm targets

* **The copy.** `native/` was copied, and in its `Cargo.toml` the
  `cranelift-*` and `target-lexicon` dependencies were moved under
  `[target.'cfg(not(target_family = "wasm"))'.dependencies]`. The
  `runtime-archive` member was dropped and `default = []` set.
* **The check.** `cargo check --release --lib --target T` for
  `wasm32-unknown-unknown`, `wasm32-wasip1` and `wasm32-wasip2`.
* **The results.** 12, 10 and 10 errors, at the sites in section 3's table.
  `libc::malloc` and `free` exist on WASI but not on `unknown-unknown`.
* **The throwaway patches:**
  * a stub `platform` module for wasm;
  * a wasm branch in `process_argv`;
  * allocation shims in `library.rs`;
  * the two header assertions limited to 64-bit.
* **After them,** `cargo build --release --lib` succeeds for all three
  targets.
* **What this does not show.** These patches only prove that nothing else
  hides behind the errors. They are not the fixes section 3 lists.

### A.2 Size and imports

* **The build.** The patched copy with `crate-type` including `cdylib`,
  built with `CARGO_PROFILE_RELEASE_DEBUG=0 CARGO_PROFILE_RELEASE_STRIP=true`.
* **Sizes:**

  | Target | Bytes | Gzipped (`gzip -9`) |
  |---|---|---|
  | `wasm32-unknown-unknown` | 661,221 | 216,818 |
  | `wasm32-wasip1` | 699,136 | 231,713 |

* **Exports.** All 210 are kept, which makes this an upper bound for any
  linked program.
* **Imports.** None on `unknown-unknown`. On `wasip1`: `random_get`,
  `environ_get`, `environ_sizes_get`, `clock_time_get`, `fd_write`,
  `poll_oneoff`, `proc_exit`.

### A.3 Entropy on `wasm32-unknown-unknown`

* **The test.** A five-line Rust cdylib returned
  `RandomState::new().build_hasher()`'s hash of a constant.
* **The result.** It had no imports, and three separate Node processes
  printed the same value, `-6977442850341163764`.

### A.4 The C backend's output on wasm32

* **Generating the C.** `tclsh9.0 main.tcl -emit-c traffic.bot
  factorial.bot`, with the programs from `examples/c-freestanding/programs/`.
* **The harness.** A five-line harness per program exports `botlish_run`
  (calling `NAME_run` and then `NAME_show` into a static buffer) and
  `botlish_out`.
* **Compiling.** `clang --target=wasm32 -std=c11 -O2 -ffreestanding
  -nostdlib -Wl,--no-entry -Wl,--export-memory`. `factorial` also links
  `examples/c-freestanding/providers/botlish_rt_v1_int_arena.c` for
  `int.mul`.
* **The result.** Node printed the same values as `tclsh9.0 main.tcl
  -backend interp` for both programs (section 5).

### A.5 A Worker-shaped kernel call

* **The kernel.** `kernel.c` includes `traffic.c` and exports
  `int64_t gcd(int64_t, int64_t)` over `traffic_7_gcd`. It compiled to
  295 B.
* **The Worker.** `worker.mjs` defines `makeWorker(module)`, which returns
  `{ fetch }`. It instantiates the module once and parses `a` and `b` as
  BigInt.
* **The host.** `host.mjs` builds the `WebAssembly.Module` (as a Worker's
  import would) and calls `fetch` with three `Request`s:

  | Request | Response |
  |---|---|
  | `a=1071&b=462` | `{"gcd":"21"}` |
  | `a=9223372036854775807&b=3` | `{"gcd":"1"}` (outside `Ticks`: section 7.2) |
  | `a=0&b=0` | `{"gcd":"0"}` |

### A.6 Census

* **Examples.** Over `find examples -name '*.bot'`: 123 files. 41 match
  coroutine, event-loop, actor, `std::test`, `std::tree` or `dfa` patterns,
  21 a platform I/O namespace and 12 the C FFI. 54 match none.
* **Golden suites.** All 120 `tests/golden/*.bot` import `std::test`.

### A.7 The compiler under WASI (section 8)

* **Who ran it.** A delegated experiment in the same session, on a
  `git archive` snapshot of `b0ae98fe`, with wasi-sdk 34.0, Wasmtime 50.0.1
  and Node 22.23.4.
* **The recipe.** It runs `unix/configure` with the overrides of section
  8.1, then `make libtcl9.0.a tclsh`, then strips the appended zip.
* **The runs.** It ran `main.tcl` under `wasmtime run --argv0 tclsh9.0
  --env PATH=/bin --dir BIN::/bin --dir SNAPSHOT::/ --dir LIBRARY::/tcllib
  --env TCL_LIBRARY=/tcllib tclsh.wasm main.tcl ...`, and saved each run's
  stdout, stderr and status beside native `tclsh9.0`'s.
* **One fix along the way.** `--argv0` and a file named `tclsh9.0` on the
  guest's PATH make `info nameofexecutable` non-empty. Without them,
  main.tcl's "help:" lines lack the executable's name. That accounts for
  its first run's 9 differing pairs.
* **The check here.** The saved pairs were compared read-only:
  * the headline run's 51 pairs are identical;
  * of the golden runs, after replacing timing figures, exactly the 8
    `UNKNOWN-TARGET` suites still differ.
* **Not done here.** Re-running the downloaded Wasmtime in this session was
  refused by the session's permission policy, so the comparison is of the
  experiment's saved outputs.

### A.8 Not run

* **JSPI's per-switch cost.** Node 22 lacks the current JSPI API, and
  downloading Node 24 was refused by this session's permission policy.
  CRANELIFT-WASM.md had already run JSPI end to end on Node 24.21 and 26.10.
* **workerd itself.** It was not installed. A.5 used Node's V8.
* **Asyncify's overhead on Botlish code,** and any CLIF→wasm lowering:
  CRANELIFT-WASM.md's prototypes are not committed.
* **CI.** No workflow was run.

## Appendix B: external facts (as of 2026-11-14)

All were read in primary sources on 2026-11-14. "Inferred" marks a reading
no source states.

**Engines**
* **JSPI** (Phase 5) ships in Chrome 137, Firefox 153 (2026-07-21), Safari
  27.0 (2026-09-14) and Node 24.20.0 (2026-08-26), and is on by default in
  Node 25.
  * Sources: features.json
    (https://raw.githubusercontent.com/WebAssembly/website/main/features.json),
    the Firefox 153 release notes
    (https://developer.mozilla.org/en-US/docs/Mozilla/Firefox/Releases/153),
    the Safari 27 release notes
    (https://developer.apple.com/documentation/safari-release-notes/safari-27-release-notes)
    and the Node 24 changelog
    (https://raw.githubusercontent.com/nodejs/node/main/doc/changelogs/CHANGELOG_V24.md).
  * V8 gives each in-flight promising call its own stack, about 1 MB
    (https://github.com/v8/v8/blob/main/src/flags/flag-definitions.h).
  * The spec traps on non-wasm frames between the export and the import
    (https://github.com/WebAssembly/js-promise-integration/blob/main/proposals/js-promise-integration/Overview.md).
* **Core stack switching** is Phase 3
  (https://github.com/WebAssembly/proposals/blob/main/README.md).
  * It is behind flags in V8 and Firefox (the `wasm_stack_switching` pref),
    and absent in Safari.
  * In Wasmtime it is experimental, Cranelift-only, x86-64 Linux and macOS
    only, and in no stability tier
    (https://github.com/bytecodealliance/wasmtime/blob/main/docs/stability-tiers.md).
  * LLVM has no support
    (https://github.com/llvm/llvm-project/blob/main/llvm/lib/Target/WebAssembly/WebAssembly.td).
  * Binaryen validates it.
* **Asyncify** costs about 50% in code size and up to 2× in speed, about 5×
  on interpreter-like code
  (https://kripken.github.io/blog/wasm/2019/07/16/asyncify.html,
  https://emscripten.org/docs/porting/asyncify.html). Emscripten's
  `-sJSPI` has not been experimental since 6.0.8.
* **memory64** is in Safari 27.3 beta (2026-11-03), not in any stable
  Safari
  (https://developer.apple.com/documentation/safari-release-notes/safari-27_3-release-notes).
* **Wasm 2.0 including SIMD** shipped in Firefox 89 and Safari 16.4
  (features.json). This corrects CRANELIFT-WASM.md's Appendix B.
* **Browser threads** need SharedArrayBuffer under COOP/COEP. COEP
  `credentialless` is not in Safari; Document-Isolation-Policy is
  Chrome-only (https://developer.chrome.com/blog/document-isolation-policy).

**WASI and runtimes**
* **WASI 0.3.0** was ratified on 2026-06-11; 0.3.2 came on 2026-10-13, and
  0.2.12 on 2026-06-02 (https://github.com/WebAssembly/WASI/releases).
* The `clocks`, `random`, `filesystem`, `sockets`, `cli` and `http`
  interfaces are Phase 3; `wasi-threads` is Phase 1
  (https://github.com/WebAssembly/WASI/blob/main/docs/Proposals.md).
* **Wasmtime:**
  * 50.0.1 (2026-10-29) is on Cranelift 0.137.1; 49 is on 0.136.5.
  * 46 made WASI 0.3 and component-model async the default.
  * 47 made GC and exceptions the default and removed wasi-threads
    (https://github.com/bytecodealliance/wasmtime/blob/release-50.0.0/RELEASES.md,
    https://github.com/bytecodealliance/rfcs/blob/main/accepted/wasmtime-remove-wasi-threads.md).
  * `max_wasm_stack` defaults to 512 KiB, and stack exhaustion is
    `Trap::StackOverflow`.
* **Rust** 1.100.0 (2026-11-12) promoted `wasm32-wasip3` to Tier 2;
  `wasm32-wasip1`, `wasip2` and `wasip1-threads` are Tier 2
  (https://github.com/rust-lang/rust/blob/main/RELEASES.md).
* **Other runtimes:**
  * WasmEdge 0.18.1 has the component model opt-in.
  * Wasmer 7.5.0 has WASIX and no component model.
  * wazero 1.12.0 and WAMR 2.4.5 are WASI preview 1 only.
  * Node's `node:wasi` is preview 1 only, and its docs say not to rely on
    it for untrusted code (https://nodejs.org/api/wasi.html).
* **Edge platforms:**
  * **Fastly Compute:** `wasm32-wasip1`; 128 MB heap; a 1 MB stack; 50 ms
    of CPU per request
    (https://docs.fastly.com/products/compute-resource-limits).
  * **Akamai Functions** (Spin): 20 or 128 MiB of memory; 500 or 1,000 ms
    of CPU
    (https://techdocs.akamai.com/akamai-functions/docs/quotas-and-limits).

**Tcl on wasm**
* **No published Tcl 9 WASI build was found.** Nixpkgs lists wasi among Tcl
  9's platforms, which is weak evidence.
* **Emscripten builds of Tcl 8.6 exist:** tcltk.wasm
  (https://github.com/t3tra-dev/tcltk.wasm).
* **Magic VLSI's browser build of Tcl 9** (merged 2026-10-07) installs a
  single-threaded notifier before creating the interpreter, because Tcl 9's
  Unix notifier starts a thread
  (https://github.com/RTimothyEdwards/magic/pull/563).

**Cloudflare**
* **Workers:**
  * Wasm comes from the bundle as a `WebAssembly.Module`; runtime
    compilation is forbidden
    (https://developers.cloudflare.com/workers/runtime-apis/web-standards/).
  * workerd enforces the ban on runtime compilation: its
    `allowWasmCallback` allows wasm only where `eval` is allowed
    (https://github.com/cloudflare/workerd/blob/main/src/workerd/jsg/setup.c++).
  * Wrangler uploads `.wasm` as separate `CompiledWasm` modules
    (https://developers.cloudflare.com/workers/wrangler/bundling/).
  * Limits: a 64 MiB uncompressed script; 128 MB per isolate, wasm
    included; 10 ms of CPU (free) and 30 s to 5 min (paid); a 1 s startup
    (https://developers.cloudflare.com/workers/platform/limits/).
  * The size limit was raised from 3/10 MB compressed on 2026-09-04
    (https://developers.cloudflare.com/changelog/post/2026-09-04-increased-worker-size-limit/).
  * Wasm features as in Chrome, and no threads
    (https://developers.cloudflare.com/workers/runtime-apis/webassembly/).
    workerd pins V8 15.8.62.5
    (https://github.com/cloudflare/workerd/blob/main/build/deps/v8.MODULE.bazel).
  * WASI only through an experimental preview-1 shim
    (https://github.com/cloudflare/workers-wasi).
  * `crypto.getRandomValues` is available
    (https://developers.cloudflare.com/workers/runtime-apis/web-crypto/),
    but throws at global scope
    (https://github.com/cloudflare/workerd/blob/main/src/workerd/api/crypto/crypto.c++).
  * Isolates may be evicted, and module-scope state is not guaranteed
    across requests
    (https://developers.cloudflare.com/workers/reference/how-workers-works/).
* **Containers** have been GA since 2026-04-13. They take `linux/amd64`
  images in Firecracker microVMs, reached through a Worker and a Durable
  Object
  (https://developers.cloudflare.com/changelog/post/2026-04-13-containers-sandbox-ga/,
  https://developers.cloudflare.com/containers/concepts/architecture/).
* **Dynamic Workers** accept wasm bytes at run time in a separate isolate
  (https://developers.cloudflare.com/dynamic-workers/api-reference/).
