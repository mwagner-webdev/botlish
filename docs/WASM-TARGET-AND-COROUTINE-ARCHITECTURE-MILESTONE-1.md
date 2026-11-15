# WASM-TARGET-AND-COROUTINE-ARCHITECTURE-MILESTONE-1: a WebAssembly target for the native backend, and how its coroutines run

An architecture and feasibility milestone, not the implementation of the
Wasm backend. It answers, with executable evidence, the questions a first
implementation milestone would otherwise have to reopen: what is lowered to
Wasm and how it is linked, how general coroutines suspend and resume, where
suspended state lives and who owns it, how the collector finds exactly the
references suspended coroutines hold, how a long-lived program waits for
external events, and how one application serves both a persistent Wasmtime
process and a request-invoked WASI component.

* **No production code, language behavior, diagnostic, runtime contract or
  release artifact changed.** Every experiment ran in a scratch copy of
  `native/`; the repository gains this report and
  [`audit/wasm-architecture/`](../audit/wasm-architecture/README.md): the
  experiments' sources, two patches (applied only to scratch copies), the
  scripts that rerun everything, and the captured results.
* Measured against `main` at `c5b22364` (2026-11-15). Code citations are
  `path:line` there.
* It builds on [CRANELIFT-WASM.md](CRANELIFT-WASM.md) (2026-10-03) and
  [WASM-PORT-FEASIBILITY.md](WASM-PORT-FEASIBILITY.md) (2026-11-14, at
  `b0ae98fe`), and re-checks both (section 2).
* **Evidence tags.**
  * **[fact]** an implementation fact, read in current source;
  * **[obs]** an observation, from an experiment run here (section 11 has
    the command; the audit directory reruns it);
  * **[ext]** an external fact from a primary source or a tool's own
    behavior, with its version or date;
  * **[inf]** an inference nothing here tested;
  * **[dec]** an architectural decision, justified by the evidence cited.
* `main`'s CI when this started: the latest finished `tests` run on `main`
  (43655204800, at `aa19036c`) was green, both GC-stress jobs included;
  every later run was cancelled by a newer push, and the run of `c5b22364`
  itself was in progress. Nothing here depends on CI, and no workflow was
  dispatched: no production code changed.

## Contents

1. [Executive conclusion and recommended architecture](#1-executive-conclusion-and-recommended-architecture)
2. [Census against current main](#2-census-against-current-main)
3. [Target and ABI decisions](#3-target-and-abi-decisions)
4. [Emission and linking pipeline](#4-emission-and-linking-pipeline)
5. [Coroutine mechanisms compared](#5-coroutine-mechanisms-compared)
6. [Coroutines, the collector and ownership](#6-coroutines-the-collector-and-ownership)
7. [The persistent-host execution contract](#7-the-persistent-host-execution-contract)
8. [WASI and the Component Model](#8-wasi-and-the-component-model)
9. [Wasm32 correctness and runtime limits](#9-wasm32-correctness-and-runtime-limits)
10. [Browser, Emscripten and threads](#10-browser-emscripten-and-threads)
11. [Experiments](#11-experiments)
12. [Risks, open questions, rejected alternatives](#12-risks-open-questions-rejected-alternatives)
13. [Roadmap](#13-roadmap)

---

## 1. Executive conclusion and recommended architecture

**The answer to the coroutine question is a compiler-side resumable
lowering, as a NIR-to-NIR pass, for the first backend and for the long
term.** It ran every coroutine program tried here -- on wasm under Wasmtime
and, through the same pass, natively on the fallback root plan -- and it
removes the requirement both earlier reports put on any wasm mechanism (a
stack and a root segment per coroutine).

| The milestone's question | Answer | Evidence |
|---|---|---|
| 1. What is lowered to Wasm, and how is it linked? | **NIR**, by a wasm backend of the driver beside `clif.rs` (not CLIF). A relocatable wasm object plus a generated startup crate, linked by `rustc` and `rust-lld` against the Rust runtime built for wasm32 into one module. The program descriptor is the native one, unchanged. | [obs] E2: real Botlish source to a running wasm module, sections 4, 11.2 |
| 2. How is any coroutine suspended and resumed independently? | Every function that may yield becomes a state machine over a **heap frame**: a suspension saves exactly the registers live after it and returns `SUSPEND` through every activation to the coroutine's segment; a resume re-enters the chain from its outermost frame and dispatches each function to its suspension point. | [obs] the seven-case corpus on wasm and natively; 122 golden suites, 5,773 tests, natively; section 5 |
| 3. Where does suspended state live, who owns it? | In a chain of frame objects on the Botlish heap, owned by the coroutine object (`CoroutineObj.frame`), each frame owning its suspended callee's. No stack, buffer or root segment per coroutine. | [obs] section 6 |
| 4. How does GC find exactly what suspended coroutines hold? | A frame is an ordinary heap object: the collector traces its first `ntagged` slots (the tagged registers live after its suspension point) and its callee frame; it is reached only through its coroutine. Running frames keep one LIFO shadow stack (the ShadowOnly root mode). | [obs] corpus under GC stress (86,407 collections in one case), a precision probe, two killed mutants; section 6 |
| 5. How does a long-lived program wait without busy-waiting or JavaScript? | The event loop's `Driver.block(deadline)` is one blocking host call: `poll_oneoff` (WASI 0.1) or `wasi:io/poll` (0.2). The instance's thread sleeps in the host. | [obs] W1: 3 s of waits, 0.10 s of CPU including startup; section 7 |
| 6. One architecture for a persistent process and a request-invoked component? | Yes: the application is the same code, the **hosting adapter** differs -- a `wasi:cli/run` command that owns its loop, or an exported handler whose host owns dispatch and instance lifetime. | [obs] W3: `wasmtime serve` makes a fresh instance per request unless told to reuse; W4: Botlish modules as WASI 0.2 components; section 8 |
| 7. What keeps browser and Emscripten options open cheaply? | No JavaScript in the core; host services behind one import interface; coroutines that need no engine feature (so no JSPI or Asyncify dependency); entropy from the host; separate link profiles per host family. | [inf] section 10 |

**Why not Asyncify** (the earlier recommendation), on the evidence of an
Asyncify prototype that kept the same invariants and ran the same cases with
no JavaScript host [obs, section 5.2]:

* **Memory.** Each suspended coroutine needs its own linear-memory stack,
  Asyncify buffer and root segment. 10,000 suspended coroutines took
  785 MiB of linear memory with 64 KiB stacks; under the resumable lowering
  they took about 2.8 MB (20,000 frames, 1.76 MB, and 10,000 coroutine
  objects, 1.04 MB), and the stackful native runtime 53.4 MB of resident
  memory, 10,000 stacks mapped [obs].
* **Safety.** A coroutine's linear stack is ordinary heap memory with no
  guard: a coroutine whose ordinary recursion outgrew its 64 KiB stack
  overwrote a neighbouring coroutine object, without any trap [obs]. On the
  main stack, recursion runs until Wasmtime's "call stack exhausted" trap
  [obs].
* **Precision.** A suspended coroutine's root segment keeps every slot of
  every suspended frame, dead or alive, until it resumes [inf, from the
  root model]; a resumable frame keeps the live registers only [obs].
* **Cost and fragility.** Instrumentation must cover exactly the yielding
  set: leaving out the one function that starts the unwind made the module
  trap [obs]; whole-module analysis instrumented 134 of 194 functions and
  grew the module 65% [obs]; the yielding functions themselves grow 2.35×
  [obs]. It adds Binaryen to every link and invalidates debug information
  of every instrumented function [ext].

**What made the resumable lowering cheap is a language fact the earlier
reports did not use** [fact]: a function that may yield never becomes a
value (`UNWRAPPED-YIELD`, COROUTINES.md point 37), so every call that can
reach a yield is a direct call (`call`, `callenv`, `callmulti`) of a known
function, and fusion's `yielding()` (`native/src/codegen/fusion.rs:290`)
already computes the exact set from NIR. The one indirect step is the
runtime's call of a coroutine's thunk, which is the coroutine's boundary.
No Rust frame can sit between a yield and its resumer:
`rt_call_value` (COROUTINE-PREREQUISITES.md's R7) only ever calls functions
that cannot yield.

**Two findings about current `main`, outside wasm:**

* **The fallback root plan loses roots when a leaf re-enters Botlish code
  through an op** [obs]. A function without a Botlish call publishes its
  root block as the Vm's one `native_roots_ptr`
  (`native/src/codegen/clif.rs:1186-1204`); `std::mutable_array::generate`,
  a cleanup or a coroutine operation then runs Botlish code whose own leaf
  replaces that block while it runs. A sixteen-line program returns `50`
  instead of `340`, or segfaults, under GC stress on a stock
  `fallback-roots` build (section 11.6). Wasm must not use that publication;
  the ShadowOnly mode (CRANELIFT-WASM.md §4.4) does not have it.
* **The resumable lowering would let the fallback plan run coroutines**,
  which it refuses today (`native/src/runtime/coroutine.rs:121`,
  `rt_co_start`). That gives the wasm coroutine mechanism a native CI lane
  before any wasm code generator exists (milestone A0, section 13).

**Recommended architecture, in one picture:**

```text
.bot ─▶ front end ─▶ HIR ─▶ native::lowered ─▶ NIR (unchanged, target-neutral)
                                                │
botlish-native (driver)                         │ nir::parse, call effects
   resumable lowering (NIR→NIR, where the target has no stack switch: wasm)
   ShadowOnly root plan (codegen::roots, Cranelift-free)
   native:  clif.rs ─▶ Cranelift ─▶ object/JIT                    (unchanged)
   wasm:    codegen::wasm ─▶ relocatable wasm object (wasm-encoder + relocations)
            + ProgramDescriptor (unchanged) + startup crate
            ─▶ rustc --target wasm32-wasip2 (rust-lld) ─▶ program.wasm (a component)
                                                     └─ or wasm32-wasip1 core module
botlish-wasm (host; its own workspace and lockfile, Wasmtime pinned on its own):
   runs commands, classifies traps, sets memory/stack/time limits
```

---

## 2. Census against current main

### 2.1 What the earlier reports said, re-checked at `c5b22364`

| Earlier finding | Now | Evidence |
|---|---|---|
| The runtime builds for wasm32 after target-gating plus four sites; 12 / 10 / 10 errors (`unknown-unknown`, `wasip1`, `wasip2`) | **Unchanged, same lines**: `thread.rs:294, 298, 320, 355, 388, 391, 1188` (`super::platform` absent), `library.rs:562, 848` (`libc::malloc`/`free`, `unknown-unknown` only), `aot.rs:72` (`process_argv`), `bytesobj.rs:74` and `strobj.rs:108` (64-bit header assertions). With the five throwaway patches all three targets build. | [obs] E1 |
| Code generation reads the driver's own runtime constants (`RuntimeCapabilities`, `codegen/target.rs:207-260` at `b0ae98fe`); `emits` refuses a target whose runtime differs | Unchanged: `host_runtime()` and `runtime_capabilities()` (`target.rs:224-251`) have no wasm row, `emits` (`:275-293`) refuses. | [fact] |
| The fallback plan refuses coroutines | Unchanged: `STACK_SWITCHING` needs `NATIVE_FRAME_ROOTS` (`coroutine.rs:121-125`), `rt_co_start` returns NATIVE UNSUPPORTED (`:661-666`). | [fact] |
| A `ShadowOnly` root mode was proposed | Not implemented: `RootStorage` has `NativeFrame` and `RuntimeStack` only (`roots.rs:97-100`); leaves still publish one block (`roots.rs:844-848`, `clif.rs:1186-1204`). | [fact]; section 11.6 shows why it matters |
| 32-bit index and length hazards | Unchanged (`value.rs:198`, `ops.rs:3252`, `:2863`, `:3552`, `mutvec.rs:165`), and **observed** on wasm: `std::list::at(xs, 2^32)` returns `xs[0]`. | [obs] section 9 |
| Rust frames between a yield and its resumer would block a compiler-side lowering (`rt_call_value`, R7) | **Cannot happen**: a function that may yield is never a value (COROUTINES.md point 37, `UNWRAPPED-YIELD`), so `rt_call_value` never reaches a yield. | [fact] section 1 |
| CLIF→wasm over a closed set of 27 opcodes | `clif.rs` now uses **58** distinct builder methods (it grew floats, rotations for the address word, `br_table`, the library stack check, data symbols, `uload16`, stack slots), plus native-only machinery around them: stack maps, Windows unwind information, callback transition shims, stack probes. | [fact] `grep -o '\.ins()\.[a-z_0-9]*' native/src/codegen/clif.rs`; section 3.3 |
| Cranelift 0.135 is pinned; Wasmtime 50.0.1 is on 0.137 | Unchanged (`native/Cargo.toml:20-26`). Wasmtime 50.0.1 built and ran here. | [fact], [obs] |
| Entropy: deterministic on `wasm32-unknown-unknown` | Unchanged (`ops.rs:1715-1723`: `RandomState`). On WASI it reads `random_get` (the linked module imports it). | [fact], [obs] |

### 2.2 What is new since the earlier reports

* **The C backend's persistent stackless frames**
  (C-COROUTINE-FRAMES-MILESTONE-1.md) show the state-machine shape works
  for Botlish coroutines [fact]: a frame per yielding function holding
  exactly what lives across a suspension, re-entry from the outermost frame
  and a dispatch on a resume point. Its restrictions are the freestanding
  subset's, not the shape's: frames are fixed-size unions nested in the
  constructor's frame (so no recursive yielding chain, no handle leaving its
  constructor), and its liveness is computed on generated C (`Persist`).
  What carries over is the protocol; what does not is the storage model
  (section 5.1).
* **Per-VM state** (PER-THREAD-RUNTIME-STATE-MILESTONE-1.md): every runtime
  read of the program goes through the Vm (`Vm::info`), so a wasm instance's
  Vm needs no thread-local program [fact].
* **Callbacks, native libraries, application libraries, threads** all exist
  now; none is needed by the first server target, and each has a wasm
  boundary noted in section 10.

### 2.3 What the runtime does on wasm32 today

* Every newer subsystem compiles to its "unsupported" branch on wasm:
  `platform` (the stack guard) is absent, `STACK_SWITCHING` and
  `NATIVE_FRAME_ROOTS` are false, `callback::SUPPORTED` is false [fact].
* The Vm allocates the fallback plan's 4 Mi-slot shadow array zero-filled
  (`vm.rs:38`, `:366-379`): 32 MiB of linear memory before the program runs
  [fact].
* `Heap` reads `BOTLISH_NATIVE_GC_STRESS` from the environment, which WASI
  passes (`--env`) [obs].

---

## 3. Target and ABI decisions

### 3.1 Target rows [dec]

* Two rows in `core/cabi.tcl`'s `targets` (`core/cabi.tcl:169-177`), each an
  operating system and an architecture as the target model requires:
  * `wasi-wasm32`: `os wasi arch wasm32 model ILP32 charSigned 1 triple
    wasm32-wasip2 floating IEEE`;
  * a browser row later (`wasm32-unknown-unknown`, OS `web` or similar),
    not in the first milestone.
* A new data model **ILP32** (`int`, `long` and pointers 32 bits) in
  `models` (`core/cabi.tcl:166-168`). It makes std::ffi::c's widths and every
  32-bit hazard of section 9 reachable, which is the point: they become
  tests.
* A platform namespace `std::wasi` in `platforms`
  (`core/cabi.tcl:190`), on the `std::darwin` model (C functions of
  wasi-libc with -1 and errno, opaque IO/path/fs contexts) [inf: wasi-libc's
  POSIX layer is what `std::darwin` uses of libSystem].
* `wasm32-wasip1` stays a *link profile* of the same target, not a second
  target: the code generator's output, the runtime source and the C data
  model are the same; only the system interface the runtime's `std` uses
  differs (section 8) [dec].

### 3.2 Runtime capabilities come from the target [dec]

`RuntimeCapabilities` (`codegen/target.rs:216-220`) becomes the input of
code generation instead of a check against the host's constants:

| Capability | Native hosts | wasm32 |
|---|---|---|
| `frame_roots` | stack maps and the frame walk | false: **ShadowOnly** roots |
| `stack_guard` | the platform guard | false: the engine's stack trap, mapped by the host |
| `stack_switching` | assembly or fibers | false: **resumable lowering** |
| new `resumable` | false | true |
| new `pointer_width` | 64 | 32 |

`check_emit` keeps refusing what a target's runtime does not have; a wasm
row is added to `runtime_capabilities`. Fusion runs where the general
mechanism exists (stack switching *or* resumable lowering): it stays a speed
layer and never makes a program run that the general mechanism refuses
(AGENTS.md, "Coroutine fusion").

### 3.3 NIR, not CLIF, is lowered to Wasm [dec]

CRANELIFT-WASM.md recommended lowering the CLIF `clif.rs` builds, and kept
NIR→wasm as the validated fallback. The evidence now favours NIR:

* **CLIF here is machine-level, and wasm must undo it.** `clif.rs` builds
  CLIF for a 64-bit ISA: pointer-width `I64` loads of `usize` fields, the
  Vm pointer as `I64` in every helper call, explicit stack slots, stack-map
  safepoints, stack probes, three C calling conventions, the address-word
  rotation [fact]. A CLIF→wasm lowering needs the runtime layout changed so
  every field generated code reads is 8 bytes (CRANELIFT-WASM.md §4.3, P5)
  and a typed helper descriptor (P7), and must reinterpret or reject every
  native-only construct.
* **The opcode surface roughly doubled** (27 → 58 builder methods in use),
  and the CLIF it builds carries native ABI decisions (unwind info, callback
  shims, the library stack check) a wasm lowering would have to recognise
  and refuse [fact].
* **NIR is the target-neutral representation** (no pointer, offset, size or
  alignment: CRANELIFT-WASM.md §3, re-checked [fact]), it has a validator
  and a text form, and **the coroutine transformation lives at NIR level**
  (section 5), upstream of both backends.
* **The prototype NIR→wasm lowering ran real programs** with closures,
  multi-result calls, handlers across suspensions, contexts, structs,
  cleanups and coroutines, linked with the real runtime [obs E2]; the
  earlier NIR→wasm prototype ran 121 programs (CRANELIFT-WASM.md §2).
* **No Cranelift coupling for wasm.** A NIR→wasm backend needs no
  Cranelift at all: the driver emits wasm with `wasm-encoder`, and the host's
  Wasmtime version is independent of the driver's Cranelift (section 4.4).

The cost is duplicated *decisions*: each op's helper, fallibility and
allocation class, and the inline fast paths. Mitigation [dec]: move the op
table (today one `match` in `clif.rs:2968-3342`) into data both backends
read (`nir.rs`/`ops.rs`: helper name, arity, fallible, allocation kind), so
only fast paths are written twice, and only those measured to matter.

**What would reverse this:** if the native backend moved to a smaller,
pointer-width-neutral CLIF subset for its own reasons, and P5 and P7 landed
anyway, sharing `clif.rs` could become cheaper than a second lowering;
measure by running both over the golden corpus on wasm.

### 3.4 Values and the generated-code ABI [dec]

* A Value stays a 64-bit word in an `i64` (CRANELIFT-WASM.md §4.3); heap
  pointers are zero-extended 32-bit addresses [obs: the linked runtime ran
  with them].
* Helper calls: the Vm and array pointers are `i32`, Values and raw words
  `i64` (the prototype's signature table, `wasmemit.rs`'s `helper_sig`); the
  production backend derives them from the typed helper descriptor, and the
  link passes `--fatal-warnings` so a mismatch fails the link [obs: the
  prototype's links pass it].
* Multi-result functions use wasm multi-value for any result count (the
  native hidden buffer for more than two results is a Cranelift ABI matter)
  [obs: `callmulti`/`retmulti` in case 5].
* A scalar result that may fail returns `(value, status)` as natively
  [obs].
* Generated code reads no object field in the first milestone: every read
  goes through a helper, so the runtime's layout may differ by pointer width
  (the prototype's patched `STR_TEXT_OFFSET`) [obs]. Inline fast paths come
  with P5's 8-byte slots or a target layout table, and their own tests.

### 3.5 What replaces the native machinery [dec]

| Native | wasm |
|---|---|
| ELF/Mach-O/COFF relocation, `objcopy` localization | a wasm relocatable object (`linking` and `reloc.*` sections); exports by an explicit list (section 4.3) |
| stack probes, the platform stack guard | none; the engine's stack trap and a `__stack_pointer` underflow trap (stack-first layout), classified by the host (section 9) |
| startup crate and `aot::run` (a worker thread) | a startup crate with `main` (a command) or exports (a handler); no thread |
| frame walk, stack maps | ShadowOnly roots |
| `bl_co_switch`, fibers | resumable lowering |
| callback transition shims | none in milestone A–D (section 10) |

---

## 4. Emission and linking pipeline

### 4.1 The pipeline (demonstrated in prototype form) [obs]

1. `main.tcl` lowers the program to NIR, as for every native consumer.
2. The driver parses and validates it (`nir::parse`), settles call effects,
   and -- for a target without stack switching -- runs the resumable
   lowering (section 5.1).
3. The wasm backend lowers each function to wasm with ShadowOnly roots
   (`codegen::roots::plan`'s liveness and slot coloring, unchanged) and
   writes a relocatable object. The prototype writes wasm *assembly* and
   uses `llvm-mc` 18.1.3 as its object writer; production writes the object
   with `wasm-encoder` (CRANELIFT-WASM.md §4.2 has the relocation list).
4. It encodes the `ProgramDescriptor` (`runtime/program.rs:140-155`) exactly
   as for native programs. **The descriptor the x86-64 driver encoded was
   decoded and instantiated by the wasm32 runtime unchanged** [obs].
5. A generated startup crate names the code table (each function's direct
   and generic entry, which on wasm are table indices) and calls
   `program::instantiate` (`program.rs:519`), the one place a Vm is built.
6. `rustc --target wasm32-wasip1|wasip2 --crate-type bin` links the object,
   the startup crate and the runtime rlib with `rust-lld`.

### 4.2 Toolchain facts the link depends on

* **Cargo 1.100's build directory** keeps each dependency's rlib in
  `target/<triple>/release/build/<crate>/<hash>/out/`, not `deps/` [obs]:
  `-L dependency=` must name those directories (the prototype's
  `bot2wasm.sh` does). The repository's native executables met the same
  change on 2026-11-13 (MAIN-CI-FAILURES-2026-11-13.md).
* `--fatal-warnings` makes a helper signature mismatch a link error instead
  of a trapping stub [ext: CRANELIFT-WASM.md §4.3; obs: the prototype links
  with it].
* For `wasm32-wasip2`, `rustc` links with `wasm-component-ld`, which
  produces a component directly [obs].
* `llvm-mc`'s wasm type checker is stricter than the spec around values
  left on the stack across an `if`: the prototype keeps every such value in
  a local [obs]. A `wasm-encoder` writer avoids the question.

### 4.3 Exports [dec]

* **Every `#[no_mangle]` runtime helper becomes a wasm export** of the
  linked command: the fib module exports 234 items, and dead helpers stay
  alive [obs]. Production links with an explicit export list
  (`-C link-arg=--no-export-dynamic` plus `--export=` for the entry points,
  or a post-link `wasm-metadce`/export strip) [inf].
* A command exports `_start` (`wasi:cli/run` as a component); a handler
  exports its interface (section 8); a native-library-style module exports
  `NAME_*` entry points over the existing library ABI, with an exported
  allocator for strings passed in (section 10).

### 4.4 Cranelift and Wasmtime versions [dec]

* With NIR→wasm the driver does not need Wasmtime or a Cranelift wasm path,
  so the pin coupling of CRANELIFT-WASM.md §1.2 disappears from the driver.
* The host (`botlish-wasm`) is a crate with **its own workspace and
  lockfile** (or a tool package), pinned to one Wasmtime release and moved
  on its own cadence. Cargo would allow Cranelift 0.135 and 0.137 in one
  lockfile (semver-incompatible versions coexist) [ext: Cargo's resolver],
  but two copies in one build cost time and size for nothing; separate
  workspaces cost nothing.
* A CI guard keeps `wasmtime` out of `botlish-native`'s dependency tree.
* Cranelift is not upgraded for this work: nothing here needs it.

### 4.5 Sizes [obs]

| Module | Stripped | gzip -9 |
|---|---:|---:|
| fib (an Int program, prototype emitter) | 807,296 B | 258,375 B |
| case 5 (resources, abandonment) | 822,055 B | 262,453 B |

Both keep every exported helper alive (4.3); CRANELIFT-WASM.md measured
about 240 KB for a linked program whose exports were trimmed.

---

## 5. Coroutine mechanisms compared

The corpus: (1) two coroutines interleaved; (2) a nested resume
chain and a recursive deep yield; (3) handles escaping into a
MutableVector, resumed in an order the data decides; (4) a List of 2,000
Strings held only by a suspended frame while the main program allocates;
(5) cancellation and cleanup -- completion, abandonment at scope end, nested
and deep abandonment, a failing coroutine's release, a resource owned by
each (the repository's own `tests/resources/coro.bot`); (6) 1,000,000
resumes of one generator, and 10,000 coroutines suspended at once; (7)
errors before the first yield, at a resume, through a deep yield, handled
inside, and raised again by a failed coroutine. Plus (8) precision: a
structure dead at the yield.

### 5.1 B. Compiler-side resumable lowering (recommended) [obs]

**The transformation** (prototype: `codegen/resumable.rs`, about 420
lines, a NIR-to-NIR pass in the driver's load path, after fusion):

* *Which functions*: fusion's `yielding()` -- a `coyield`, or a direct call
  of a function that may yield, to a fixpoint -- exact by point 37.
* *Prologue*: take the frame left for this activation (`frtake`: UNIT for a
  fresh call); if it is a frame, switch on its resume point.
* *A yield* `%d = coyield %v`: store the outward value in the running
  coroutine (`cosuspend`), save the registers live after the yield into the
  frame (`frensure`, `frput`, `frputraw`, `frfinish`: resume point, callee
  frame, count of tagged slots), return `SUSPEND`. Resumed, `%d = comsg`:
  the message, or NO_VALUE when the coroutine is being abandoned (the
  pending error then unwinds through the frames' release pads, exactly as
  natively).
* *A call of a yielding function*: after the call, `SUSPEND` (a word no
  value has: `26`, low bits `0b11010`) means the callee suspended: take its
  frame (`frpending`), save this activation's live registers with it as the
  callee frame, return `SUSPEND`. Resumed: reload, hand the callee its frame
  (`frsetresume`) and make the same call again; the callee continues where
  it stopped.
* *What is saved* is `codegen::roots::live_at_many`'s live-out set at the
  suspension point (the root plan's own liveness), minus the result; a
  `callenv`'s closure is always saved (a resumed callee may read captures).
* *Reuse*: an activation suspending again reuses its frame, so a generator
  in steady state allocates nothing per resume [obs: 4 allocations for
  1,000,000 resumes, case 6a].
* *ABI*: a yielding function's scalar result (raw, short, packed ASCII:
  proven, so boxing is exact) is boxed at its returns and unboxed by its
  callers after their suspension check; multi-result companions carry
  `SUSPEND` in their first result; a construction plan live across a
  suspension is owned by the frame.
* *Handlers*: error exits are textual (`clif.rs:2530-2541`), so the
  dispatch block (placed after the body) may jump into a handled span, and
  a resumed call that fails reaches the same handler it would natively.
* *Runtime*: a coroutine segment calls the thunk's generic entry with the
  frame left in the Vm, and keeps the outermost frame when it returns
  `SUSPEND` (`segment_resumable`, about 200 lines with the frame object and
  its 15 helpers). The coroutine API (`rt_co_start`, `rt_co_resume`,
  `rt_co_abandon`, `rt_co_release`, `rt_co_done`) is unchanged.

**Results** [obs]:

| | Native, fallback roots + resumable | ... under GC stress | Wasm (Wasmtime 50.0.1) | ... under GC stress |
|---|---|---|---|---|
| Corpus cases 1–7 (6 as 6a and 6b) | all equal the interpreter | all equal | all equal | all equal (collections, in order: 7, 13, 22, 86,407, 42, 4, 50,005, 25) |
| Case 8 (precision) | equal | not run (quadratic: 200,000 live objects marked at every allocation) | equal | not run |
| All 122 golden suites (`std::test`'s runner is a coroutine) | **5,773 passed, 0 failed** | `coroutines.bot` 62/62, `tree-struct.bot` 19/19 | not run (the prototype emitter covers a subset of NIR) | -- |

Six suites first stopped on constructs the first prototype refused --
yielding functions with a scalar result (`coroutines.bot`,
`branch-form-boolean.bot`), a yielding scalar-replacement companion with
several results (`destructuring.bot`), a construction plan live across a
yield (`fold-virtual-construction.bot`, `loops.bot`, `loop-collecting.bot`)
-- and passed once the pass handled each as above. None needed a runtime
change.

**What it costs** [obs, native x86-64, one run each, indicative only;
`results/measurements-native.txt`]:

| Case | Stackful (stock), fusion off | Stackful, fusion on | Resumable |
|---|---|---|---|
| 6a: 1,000,000 resumes of one generator | 0.069 s | 0.016 s (fused away) | 0.053 s |
| 6b: 10,000 suspended at once | 0.25 s, maxrss 53.4 MB, 10,000 stacks mapped, 96 collections | the same (handles escape: not fusible) | 0.020 s, maxrss 16.4 MB, 3 collections |

* A resume re-enters the chain from its outermost frame: O(depth of the
  yielding call chain), as the C backend's frames and an Asyncify rewind
  [fact]. `std::tree::walk` keeps an explicit stack rather than recursing
  (TREE-STRUCT-MILESTONE-1.md), so library code is shallow.
* The prototype makes every frame operation a helper call; production
  inlines them as field stores (a frame is a fixed-shape object per
  function) [inf].
* Frames in case 6b: 20,000 frames (a thunk's and `holder`'s per
  coroutine), 88 bytes each on x86-64 [obs].

### 5.2 A. Binaryen Asyncify, with no JavaScript host [obs]

**The prototype** (`audit/wasm-architecture/asyncify/co.rs`, a minimal
runtime with the invariants Botlish would need, generated code hand-written
to the ShadowOnly protocol):

* each coroutine has its own Asyncify buffer (8 KiB), linear-memory stack
  (64 KiB, a heap allocation) and root segment (1,024 slots);
* `segment` -- which switches `__stack_pointer` and the root segment, calls
  the body through a function pointer (`call_indirect`) and stops the
  unwind -- is never instrumented; `co_yield` starts the unwind and, on the
  rewind's re-entry, stops it and returns the message;
* Binaryen redirects in-module imports of the `asyncify` module
  (`start_unwind`, `stop_unwind`, `start_rewind`, `stop_rewind`) to its own
  functions, but not `get_state` ("call to unidenfied asyncify import") [ext:
  Binaryen 132];
* the collector scans the running chain's segments and, through each
  reachable coroutine object, a suspended one's.

**It works, with care** [obs]: cases 1, 2, 3, 4, 7 and a subset of 5 match
the Botlish results, under GC stress too (case 4: 42,802 collections); an
unreachable suspended coroutine is reclaimed with nothing run.

**Its costs** [obs]:

| Configuration | Instrumented | Stripped module |
|---|---|---|
| no Asyncify (`wasm-opt -O2`) | -- | 78,321 B |
| whole-module analysis, `segment` excluded | 134 of 194 functions: indirect calls make most of `std` "possibly unwinding" | 129,049 B (+65%) |
| `asyncify-onlylist` = the yielding set | -- | **traps** (`unreachable`): `co_yield`, which starts the unwind, must be listed too |
| `asyncify-onlylist` = the yielding set + `co_yield` | exactly those | 82,653 B (+5.5%); the yielding functions 1.5–6.9×, 2.35× in all (measured before cases 8 and 9 joined the file) |

| Case | Asyncify (prototype runtime) | Resumable (Botlish, prototype emitter) |
|---|---|---|
| 6a: 1,000,000 resumes, wasm | 0.04 s wall | 0.15 s wall (helper calls for every frame and Int operation) |
| 6b: 10,000 suspended, wasm | **785 MiB** of linear memory (819.2 MB of stacks, buffers and segments) | 58.5 MB maxrss of the whole Wasmtime process; natively 2.8 MB of frames and coroutine objects |

**Its hazards** [obs]:

* **Silent stack overflow.** A coroutine whose ordinary recursion (2,000
  frames of a 64-byte local) outgrew its 64 KiB linear stack returned
  normally, and the coroutine object allocated just below its stack was
  overwritten: its stack buffer's pointer read as null and its next resume
  found a corrupt state ("bad resume"). Nothing trapped: linear memory has
  no guard pages, and LLVM emits no stack-limit checks for wasm [ext]. On
  the main stack (stack-first, growing toward address 0) the same 2,000
  frames ran to completion, and 20,000 ended in "call stack exhausted"
  under Wasmtime's default 512 KiB engine stack: a trap, never corruption.
* **Sizing.** A per-coroutine stack must hold the deepest non-yielding
  call any coroutine body makes, which nothing bounds statically; 64 KiB
  times 10,000 coroutines is already 640 MiB of a 4 GiB address space.
* **Fragility.** The instrumentation list must be exactly complete: a
  missing function is a trap at best (above). Debug information of every
  instrumented function is lost unless Binaryen maps it [ext].

### 5.3 C. Core stack switching [obs, ext]

* Wasmtime 50.0.1 runs a module with two interleaved generators
  (`cont.new`, `resume`, `suspend`) **only with `-W stack-switching=y`**;
  by default it refuses the module ("cannot define continuation types when
  stack switching is disabled") [obs]. Its stability tier: experimental,
  Cranelift on x86-64 only [ext: WASM-PORT-FEASIBILITY.md Appendix B].
* `rustc` 1.100's wasm32 target has no stack-switching feature (LLVM has
  none) [obs: `rustc --print target-features`], and browsers ship it behind
  flags only [ext: same source].
* **Migration**, should it ship everywhere: a continuation would replace the
  frame chain of one coroutine, not the root model. Each continuation's
  Rust frames would still need a linear stack of their own (the same
  overflow and sizing problem as Asyncify), unless the resumable lowering
  keeps Rust frames off suspended chains -- which it already does. So stack
  switching is at most an optimization over resumable frames for deep
  yielding chains, worth measuring then.
* **JSPI** suspends a whole wasm invocation while a JavaScript promise
  settles: the browser host's way to implement the event loop's
  `block(deadline)` (section 10), never the coroutine mechanism.

### 5.4 Decision [dec]

**The resumable lowering is the production mechanism for wasm, and the
preferred long-term one.** It is not an interim solution: it needs no
engine feature, no tool beyond the driver, no stack per coroutine, keeps the
collector precise and the shadow stack LIFO, and it is testable natively.

**What would change it**: (1) a workload where resume cost O(depth) of deep
yielding chains dominates, *and* core stack switching shipped in every
target engine with an answer for the linear stack of each continuation;
(2) a coroutine construct the lowering cannot express -- none was found in
the 122 golden suites.

---

## 6. Coroutines, the collector and ownership

### 6.1 Representation [dec, obs]

* **Running code**: ShadowOnly roots (CRANELIFT-WASM.md §4.4): every
  function with a root slot reserves a frame in the Vm's one shadow array
  and stores each rooted register there at its definition; no leaf
  publication. The prototype's `roots.rs` change (fallback storage is
  always `RuntimeStack`) is that mode, minus the depth-token removal.
* **Suspended code**: a `FrameObj` per suspended activation (`KIND_FRAME`):
  resume point, `ntagged`, the suspended callee's frame, tagged slots, raw
  slots. A coroutine object holds its outermost frame; each frame its
  callee's. Two Vm slots carry a frame across a hand-off (`resume_frame`:
  for the activation being entered; `pending_frame`: from a suspending
  callee to its caller); both are GC roots, and UNIT outside a hand-off.
* **Why no segments**: a suspension *returns* through every activation, so
  their shadow frames are popped in order; nothing of a suspended coroutine
  stays on the shadow stack or the machine stack. The per-coroutine segment
  both earlier reports required is a property of mechanisms that keep
  frames in place (stack switching, Asyncify), not of coroutines.

### 6.2 The collector [obs]

* A frame is traced like any object: `tagged[..ntagged]` and `callee`
  (`heap.rs`'s new `KIND_FRAME` case). The collector is non-moving, so a
  value in a wasm local stays valid across a safepoint without reloading.
* Reachability: a suspended coroutine's frames are reachable exactly
  through its handle. A released or abandoned coroutine drops its chain
  (`co.frame = UNIT`); an unreachable one's frames are swept with it, and
  nothing runs (no frame owns a Rust value with a destructor).
* **The required proof** (an object survives GC when its only live
  reference belongs to an independently suspended coroutine): case 4 keeps
  a List of 2,000 fresh Strings only in `keeper`'s frame across two
  suspensions while the main program allocates 40,000 Strings; under GC
  stress (a collection at every allocation: 86,407 on wasm) the resumed
  coroutine reads every String [obs]. Mutant M1, a frame whose tagged slots
  are not traced, fails it (no value in one run, garbage Ints where counts
  belong in another: it reads freed memory), and fails cases 2, 5 and 6b
  [obs: `results/mutants.txt`].
* **Precision**: case 8 builds 200,000 Strings, keeps only their count and
  suspends; while it is suspended, live objects after each collection fall
  to tens, under the stackful native runtime and the resumable frames alike
  [obs]. Retaining everything a suspended coroutine ever referenced would
  have kept 200,000.
* **Abandonment and cleanup** (case 5): completion, abandonment at the
  handle's scope end (after a note made past the handle's last use), a
  parent abandoned while it holds a suspended child (the child's resource
  released), a nested block's resources (inner first), a failing segment's
  release before the caller's handler, a deep abandonment (innermost frame
  first): the same release order as the native runtime, also under GC
  stress, natively and on wasm [obs].

### 6.3 Invariants, for assertions and mutation tests [dec]

| # | Invariant | Mutant that breaks it | Killed by |
|---|---|---|---|
| I1 | After a segment, the shadow stack's top is where it was before; no activation of a suspended coroutine is on any stack. | a suspension's `ret` that skips its shadow frame's restore | [inf] any program resuming after a deep suspension |
| I2 | `resume_frame` and `pending_frame` are UNIT outside a hand-off. | `segment_resumable` leaves `pending_frame` set | [inf] a debug assertion at every safepoint |
| I3 | A frame traces exactly `tagged[..ntagged]` and `callee`. | **M1**: tagged slots untraced | [obs] cases 2, 4, 5, 6b under GC stress |
| I4 | Every register live after a suspension point is saved and restored before any use on the resume path. | **M2**: one live tagged register not saved | [obs] cases 2, 4, 5, 6b under GC stress (each a segmentation fault) |
| I5 | Raw slots are never traced; tagged slots never hold raw words. | a raw register saved as tagged | [inf] GC stress on a program with raw registers live across a yield (case 1's loop counter) |
| I6 | A frame is reused only by the activation that made it. | `frensure` reuses any frame argument | [inf] case 2 (recursive yielding chain) |
| I7 | Release and abandonment drop the frame chain. | `rt_co_release` keeps `frame` | [inf] an allocation-report test of a released suspended coroutine |
| I8 | No root block is published per function: every rooted function's slots are in the shadow stack (ShadowOnly). | restore leaf publication | [obs] `leaf-reentry.bot` under GC stress (section 11.6) |

### 6.4 Interaction with the rest of the runtime [fact, inf]

* **Fusion**: unchanged in role. Where it applies, a fused coroutine has no
  frames at all; where it does not, the resumable lowering applies.
* **Resources and abandonment**: `coroutine#abandon` resumes with NO_VALUE;
  `comsg` fails; release pads run. The prototype changed nothing in
  `affine.rs` [obs].
* **Contexts**: a coroutine runs with the providers its construction
  selected; frames save context-bearing registers like any other, and the
  context area is the Vm's (no per-coroutine copy) [fact].
* **Out of memory**: frame allocation is an ordinary allocation; on wasm an
  allocator failure aborts (`unreachable` after "memory allocation ...
  failed" [obs W2]), which the host classifies (section 9).

---

## 7. The persistent-host execution contract

### 7.1 Three kinds of suspension [dec]

| Kind | Who does it | On wasm |
|---|---|---|
| 1. A coroutine yields to another | the Botlish runtime | resumable frames, entirely in the guest |
| 2. The event loop waits for an external event | the guest asks, the host blocks | `Driver.block(deadline)` is one blocking host call |
| 3. The host suspends, resumes or ends an invocation | the host | Wasmtime's async support (fibers), epoch interruption, fuel; WASI 0.3 async exports later. Invisible to Botlish semantics. |

The host never drives individual coroutine handles, and Botlish needs no
Wasm-specific scheduling construct: `std::event_loop` stays ordinary
Botlish over a `Driver` context trait (`stdlib/event_loop.bot:259-267`), and
the deterministic driver keeps running everywhere.

### 7.2 Waiting without busy-waiting [obs]

W1 (`wasi/wait.rs`): three 700 ms timer waits, then a wait for stdin
readiness with a 5 s deadline, each one `poll_oneoff` with a monotonic-clock
subscription (and an `fd_read` subscription for stdin). Data written to its
stdin after 3 s woke it at once: **2.98 s of wall time, 0.10 s of CPU**
including Wasmtime's startup and compilation. A WASI driver for
`std::event_loop` is exactly that call behind `block(deadline)`, with
`clock()` from `clock_time_get`; WASI 0.2 gives the same through
`wasi:io/poll` and `wasi:clocks/monotonic-clock` [inf: the component's
imports list both, W4].

### 7.3 Host services [dec]

| Service | First server target (WASI) |
|---|---|
| Initialization and termination | `wasi:cli/run` (a command); exit status = the program's (status 3 passed through [obs]) |
| Monotonic clock, timers | `clock_time_get` / `wasi:clocks`; timers as poll subscriptions |
| I/O readiness, wakeups | `poll_oneoff` / `wasi:io/poll` over stdio, files, sockets (`wasi:sockets`) |
| Standard I/O | WASI streams |
| Entropy | `random_get` / `wasi:random`, drawn lazily as today (`ops.rs:1715`) |
| Memory, stack and execution limits | the host: `max-memory-size`, `max-wasm-stack`, epoch `timeout`, fuel [obs W2] |
| Trap classification | the host, from the trap code (section 9) |
| Graceful shutdown, cancellation | the host stops the store (epoch interruption); a cooperative stop is an ordinary event the driver reports to the loop |

### 7.4 Persistent application versus request-invoked component [obs, dec]

* **Persistent** (milestone C): a command that runs until it ends, is
  cancelled or the host ends it. It keeps coroutine and application state
  while it waits.
* **Request-invoked** (milestone D's second half): the host owns dispatch,
  permissions and instance lifetime. Under `wasmtime serve`, a
  `wasi:http/incoming-handler` component saw `1, 1, 1` from a module-level
  request counter over three requests -- a fresh instance per request -- and
  `1, 2, 3` only with `--max-instance-reuse-count 10` [obs W3]. A guest can
  rely on neither.
* **What differs is the adapter.** The application's business logic is the
  same Botlish modules; a command entry installs the platform contexts and
  runs the loop; a handler entry is an exported function whose body
  installs per-request contexts, runs the request's work (coroutines
  included) to completion within the invocation, and returns. Background
  work beyond a request is unavailable in that model, by the host's choice,
  not Botlish's.
* `wasmtime serve`'s world does not provide `wasi:cli` unless asked
  (`-S cli=y`), and Rust's `std` for `wasm32-wasip2` imports
  `wasi:cli/environment` [obs]: a handler's runtime must import only what
  the proxy world provides, or the platform must allow more. A real
  constraint for PaaS hosts.

---

## 8. WASI and the Component Model

### 8.1 What ran [obs]

* The linked Botlish modules are WASI 0.1 core modules (imports
  `random_get`, `environ_get`, `environ_sizes_get`, `clock_time_get`,
  `fd_write`, `poll_oneoff`, `proc_exit`).
* `wasm-tools component new MODULE --adapt
  wasi_snapshot_preview1=ADAPTER` (Wasmtime 50.0.1's command adapter,
  51,854 B) made **components** of three of them -- fib, the nested
  coroutine case and the abandonment case -- importing
  `wasi:cli/*`, `wasi:io/*`, `wasi:clocks/*`, `wasi:filesystem/*` at
  0.2.12 and exporting `wasi:cli/run@0.2.12`; each ran under Wasmtime with
  the module's output.
* The same object, linked with the runtime built for `wasm32-wasip2`, is a
  component directly (`rustc` uses `wasm-component-ld`) exporting
  `wasi:cli/run@0.2.12`, and runs the nested coroutine case.
* Neither changed anything in the program's semantics: the adapter maps
  the runtime's own system calls.

### 8.2 Recommendations [dec]

* **First supported format**: a WASI 0.2 component (`wasm32-wasip2`
  link), plus the `wasm32-wasip1` core module as a compatibility artifact
  for hosts that only take preview 1 (Fastly Compute, wazero, WAMR,
  `node:wasi` [ext: WASM-PORT-FEASIBILITY.md §6]). Both come from one object
  and one runtime source; only the link profile differs.
* **Minimum WASI version**: 0.2 (0.2.12 is what Wasmtime 50 provides
  [obs]).
* **Component interfaces**: typed WIT interfaces at the edges -- `wasi:cli`
  for commands, `wasi:http` for handlers, `wasi:sockets` for a persistent
  server -- rather than a broad POSIX emulation. `std::wasi`'s modules call
  wasi-libc's POSIX layer where it is enough (files, stdio), and WIT
  bindings where it is not (HTTP).
* **WASI 0.3** (async functions, streams, futures; on by default in
  Wasmtime since 46 [ext: WASM-PORT-FEASIBILITY.md Appendix B]) enters with
  milestone D's handler adapter, where an async export lets the host
  interleave requests without guest threads. It does not replace Botlish
  coroutines: inside the guest, coroutines stay the program's own control
  flow, and a 0.3 async export is one host-visible suspension point (kind
  3), as JSPI is in a browser.
* `rustc` 1.100 has `wasm32-wasip3` as a target [obs: `rustup target
  list`]; untested here.

---

## 9. Wasm32 correctness and runtime limits

### 9.1 32-bit hazards [fact unless marked]

| Hazard | Where | On wasm32 |
|---|---|---|
| Index cast before the range check | `rt_list_get` (`ops.rs:3252`), `char_at` (`:2863`), `:3552`, `mutvec.rs:165` | **observed**: `std::list::at([10, 20, 30], 2^32)` is `10`, `2^32 + 2` is `30`; natively IndexNotFound [obs] |
| Collection limit | `MAX_COLLECTION_LENGTH = SMALL_MAX as usize` (`value.rs:198`) | truncates to 2^32 − 1 [inf] |
| Header alignment | `Header` is `u8` fields only (`value.rs:264-272`); the pointer tag needs `v & 7 == 0` | 8-alignment comes from the allocator (dlmalloc's minimum) [ext: CRANELIFT-WASM.md §9.2], not the type |
| String and byte header sizes | `STR_TEXT_OFFSET = 25`, `BYTES_PAYLOAD_OFFSET = 16` assume 8-byte `usize` (`strobj.rs:83-85`, `bytesobj.rs:61-74`) | the prototype patched the String constants per pointer width; generated code reads no field yet |
| Offsets generated code reads | the `Vm` prefix, `ListObj`, `StructObj`, `ClosureObj`, `StrObj` | differ unless P5's 8-byte slots land [ext: CRANELIFT-WASM.md Appendix A.3] |
| The C address word | 60-bit payload (`value.rs:32-53`) | a 32-bit address fits every encoding |
| Entropy | `RandomState` (`ops.rs:1715-1723`) | WASI: `random_get` [obs: imported]; `wasm32-unknown-unknown`: a constant [ext: WASM-PORT-FEASIBILITY.md A.3] -- every such build must take entropy from the host before the first keyed hash |
| `Instant::now` | `heap.rs:167` (metrics), `aot.rs:453`, `thread.rs` | works on WASI; traps on `unknown-unknown` [ext] |
| Threads | `aot.rs:348` (worker), `thread.rs` | refused (no guard record: the prototype's stub returns ThreadLimit) |

### 9.2 Four memories, and who bounds each [dec]

| Memory | Holds | Bounded by |
|---|---|---|
| The engine's stack | wasm frames (locals, return addresses) | the host: Wasmtime `max-wasm-stack` (512 KiB default: a 64-byte-frame recursion trapped before 20,000 frames [obs]); about 1 MB fixed in browsers [ext] |
| The linear-memory stack (`__stack_pointer`) | Rust frames' spills, generated code's scratch arrays | the link (`-z stack-size`); the stack is first in memory (the main stack pointer started at `0xfff40` [obs]), so an underflow addresses outside linear memory and traps [ext: CRANELIFT-WASM.md §4.5] -- in the runs here the engine's stack always ran out first [obs] |
| The Botlish heap (Rust's allocator in linear memory) | objects, **frames of suspended coroutines** | the host's `max-memory-size` (a 256 MiB cap made a 16 MiB allocation fail [obs]); the collector's thresholds (`Heap::configure`, CRANELIFT-WASM.md P6) |
| The shadow stack | roots of running frames only | its size, set by the host, allocated without zero fill (CRANELIFT-WASM.md §4.4) |

Under the resumable lowering, suspended state is heap memory: a host that
bounds memory bounds coroutines too, and an exhausted heap is the same
failure whether a frame or a List caused it.

### 9.3 Traps and their classification [obs]

Under the Wasmtime CLI every trap exits with status 134; the text tells them
apart:

| Run | Text | Botlish error |
|---|---|---|
| deep recursion | `call stack exhausted` | NATIVE LIMIT STACK |
| store at `0xfffffff0` | `memory fault at wasm address 0xfffffff0 in linear memory of size 0x110000` | NATIVE BUG (or NATIVE LIMIT STACK when `__stack_pointer` underflowed: CRANELIFT-WASM.md §4.5) |
| `abort` | `wasm \`unreachable\` instruction executed` | NATIVE BUG |
| allocation beyond `max-memory-size` | `memory allocation of 16777216 bytes failed` | NATIVE LIMIT MEMORY |
| infinite loop, `-W timeout=2s` | `wasm trap: interrupt` | a host limit (NATIVE LIMIT TIME, say) |

A host crate classifies by `wasmtime::Trap` codes rather than text; a
trapped instance is discarded, never called again (CRANELIFT-WASM.md §4.5).
Tests assert error codes, never recursion depths.

---

## 10. Browser, Emscripten and threads

Kept small: what the decisions above must not close off.

* **Browser** (milestone E): a JavaScript host implementing the same host
  services (section 7.3), entropy from `crypto.getRandomValues`, and the
  event loop's `block(deadline)` through **JSPI** (one suspension of the
  whole invocation while a promise settles). The resumable lowering needs
  nothing of the engine, so coroutines work in every browser; JSPI is only
  for waiting, and an older engine would need `turn`-style re-entry instead
  (a language-design question: RN-HOST-STARTABLE-APPLICATION-LIBRARY-
  MILESTONE-1.md rejects a host-driven Vm) [inf].
* **Emscripten**: a third link profile (`wasm32-unknown-emscripten` exists
  for rustc [obs: `rustup target list`]) with Emscripten's own libc and JS
  glue. Objects for plain `wasm32-unknown-unknown`, WASI and Emscripten are
  not interchangeable (different libc, different imports) [ext]. Keeping the
  core free of JS and of `wasi_snapshot_preview1` calls outside one host
  layer keeps this a link profile, not a port [inf].
* **Native-library-style exports**: the existing library ABI
  (NATIVE-LIBRARY-MILESTONE-1.md) maps to wasm exports: `int64_t` is
  `i64` (a JS BigInt), strings are bytes and a length in linear memory, an
  exported allocator for inputs, errors as data [ext:
  WASM-PORT-FEASIBILITY.md §4.9]. Exports may not suspend, so no coroutine
  crosses them.
* **Threads**: share-nothing VMs fit wasm instances; the transport moves
  into the host (a store per OS thread in Wasmtime, a Worker in a browser),
  messages as transfer bytes. Until then `std::thread::start` is refused
  [dec]. Nothing in the resumable lowering assumes one thread: frames are
  per-Vm heap objects.
* **C libraries**: static archives compiled for the same wasm32 profile
  (wasi-sdk for WASI), linked by `wasm-ld`; the wasm32 C ABI (`i32`/`i64`/
  `f32`/`f64`, variadics in memory) is a new `foreign_call` lowering
  [ext: WASM-PORT-FEASIBILITY.md §4.5]. Not in milestones A–D.

---

## 11. Experiments

Every command and its output are in
[`audit/wasm-architecture/`](../audit/wasm-architecture/README.md) (its
README reruns each one; `results/` holds what these runs printed).

**Toolchain** [obs]: rustc 1.100.0 (the repository's pin) for every Botlish
artifact; llvm-mc and clang 18.1.3 (Ubuntu); Wasmtime 50.0.1 and wasm-tools
1.263.0 built from crates.io; Binaryen 132 (`binaryen` 132.0.0 from npm,
the JavaScript build of `wasm-opt`) under Node 22.23.4; the WASI preview1
adapter from `wasi-preview1-component-adapter-provider` 50.0.1; the `wasi`
crate 0.14.2 for the HTTP handler; Tcl 9.0.1. GitHub release downloads
were refused by the session's network policy, so no tool came from there;
the third-party tool binaries were built with the container's rustc 1.97.0
(the scripts use the pinned 1.100.0).

### 11.1 E1: the runtime for three wasm32 targets

* **Input**: `native/` at `c5b22364`, the code generator's crates
  target-gated, the `runtime-archive` member dropped.
* **Command**: `cargo check --release --lib --target T` for
  `wasm32-unknown-unknown`, `wasm32-wasip1`, `wasm32-wasip2`; then with
  `patches/e1-runtime-wasm32.patch` (a platform stub, an argv branch, String
  constants per pointer width, the byte-storage assertion per width, an
  allocator shim for `unknown-unknown`), `cargo build`.
* **Observed**: 12, 10 and 10 errors at the sites of section 2.1; after the
  patches all three build (static libraries of 21.8, 22.5 and 24.1 MB with
  debug information).
* **Establishes**: nothing else hides behind those sites. **Does not**:
  that the patches are the fixes (section 9 lists those).

### 11.2 E2: real Botlish to a running wasm module

* **Input**: `corpus/e2-fib.bot` (a recursive `fib` with a raw-Int ABI,
  then a product past 2^62) and the coroutine corpus.
* **Construction**: `main.tcl -backend cranelift -emit-nir` → the
  prototype driver's `wasm-asm` (`patches/resumable-and-wasm-prototype.patch`:
  `codegen/wasmemit.rs`, about 800 lines; dispatch-loop control flow, every
  tagged operation a helper call, ShadowOnly roots through two glue
  helpers) → `llvm-mc -triple=wasm32-wasi -filetype=obj` → `rustc
  --target wasm32-wasip1 --crate-type bin -C link-arg=--fatal-warnings`
  against the runtime rlib (`tools/bot2wasm.sh`) → `wasmtime run`.
* **Observed**: `[6765, 95853241822852445765625]`, as `-backend interp`;
  with `BOTLISH_NATIVE_GC_STRESS=1`, the same with 3 collections. Every
  corpus case likewise (section 5.1's table).
* **NIR the prototype lowers**: integer, raw, short, ASCII, Bool, unit,
  String, function-value and native constants; moves; closures and
  captures; ops (raw arithmetic and comparisons inline, tagged Int
  arithmetic and comparisons, Lists, Strings, MutableVectors, coroutine and
  frame operations, cleanups, contexts through helpers); `call`, `callenv`,
  `callmulti`, `callenvmulti`, `callvalue`; `br`, `jump`, `switch`, `ret`,
  `retmulti`, `unreachable`; error exits, `faildeclared`, declared-error
  tests and payloads, `reraise`; `construct`, `structnew`, `structget`;
  `contextload`, `contextstore`. **Not**: guards, float, byte, character
  and enum constants, statics, tail calls, foreign calls, regions.
* **Establishes**: the pipeline -- real NIR, a relocatable wasm object, the
  unchanged descriptor, the real runtime, one module, Wasmtime -- works, GC
  included. **Does not**: speed, the production object writer, inline fast
  paths, or coverage of all NIR (the golden suites ran natively, not on
  wasm).

### 11.3 C-B: the resumable lowering

* **Construction**: the same patch's `codegen/resumable.rs`, the frame
  object and helpers in `runtime/coroutine.rs`, `KIND_FRAME` in `heap.rs`,
  15 ops in `nir.rs`/`ops.rs`/`clif.rs`, and fallback storage always
  `RuntimeStack` in `roots.rs`; built `--features fallback-roots` (no
  stack switching, shadow-stack roots), so the driver applies the pass.
* **Commands**: `tools/run-corpus.sh` (the corpus on interp, stock native,
  resumable native with GC stress off and on, wasm with GC stress off and
  on); `tools/golden-sweep.sh` (all 122 golden suites); the same with
  `BOTLISH_NATIVE_GC_STRESS=1` for `coroutines.bot` and `tree-struct.bot`;
  `tools/mutants.sh`.
* **Observed**: section 5.1 and 6.2: every value equal; 5,773 tests, 0
  failed; 62/62 and 19/19 under GC stress; M1 and M2 killed.
* **Establishes**: the lowering preserves coroutine semantics on every
  golden suite with the fallback root plan, and on wasm for the corpus.
  **Does not**: production performance (frame operations are helper
  calls); of the Tcl test files, only `tests/actor.test` finished (67/67,
  section 11.7).

### 11.4 C-A: Asyncify

* **Input**: `asyncify/co.rs`, `asyncify/sp.s` (`__stack_pointer` access).
* **Commands**: `tools/asyncify.sh`: `rustc --target wasm32-wasip1`, then
  `wasm-opt -O2 --asyncify` with whole-module analysis, an onlylist of the
  yielding set, and the yielding set with `co_yield`; `wasmtime run` per
  case, with and without `GC_STRESS=1`.
* **Observed**: section 5.2.
* **Establishes**: Asyncify can run general coroutines with no JavaScript
  host, and what it costs. **Does not**: its cost on Botlish-generated code
  (the functions are hand-written).

### 11.5 W1–W4 and core stack switching

`tools/wasi.sh`: section 7.2 (W1), 9.3 (W2), 7.4 (W3), 8.1 (W4) and 5.3.

### 11.6 The fallback plan and an op that runs Botlish code

* **Input**: `corpus/leaf-reentry.bot`: `outer` (no Botlish call: a leaf)
  keeps a List of 100 Strings live across `std::mutable_array::generate(n,
  label)`, whose factory `label` is itself a leaf with a root slot that
  allocates.
* **Command**: `tools/fallback-leaf.sh`: stock `main` built with `--features
  fallback-roots`, against the stack-map build and the prototype, five runs
  each.
* **Observed**: GC stress off: `340` everywhere. GC stress on: the stack-map
  build and the prototype `340`; stock fallback-roots `50` (the fold over the
  List saw it emptied) or a segmentation fault.
* **Establishes**: the defect of section 1, on a test-only build of `main`
  (Windows' `roots` CI job builds it). **Does not**: that a shipped build is
  affected: every shipped host has native-frame roots.

### 11.7 Not run

* Botlish-generated code under Asyncify (the Asyncify functions are
  hand-written).
* The golden suites on wasm (the prototype emitter covers a subset).
* The Tcl test files of the coroutine-heavy areas through the prototype
  driver (`BOTLISH_NATIVE_BIN`): `tests/actor.test` finished, **67 of 67
  passed** (std::actor over std::event_loop: every actor and task a
  coroutine); `tests/event-loop.test`, `tests/dfa.test` and
  `tests/coroutines.test` were still running when this was written
  (`results/tcl-test-files.txt` records what finished).
* JSPI, browsers, workerd, Emscripten.
* A Rust Wasmtime embedder (trap codes, epoch interruption from the host):
  the CLI's behavior stands in for it.
* CI: no workflow was dispatched.

---

## 12. Risks, open questions, rejected alternatives

### 12.1 Risks

* **Deep yielding chains**: resume is O(depth). A program that yields at
  recursion depth d pays d re-entries per resume. Measure on real workloads
  (the event loop, actors, DFA recognizers) once the wasm backend runs them;
  the remedy, if needed, is resuming the innermost frame directly and
  completing callers through their frames (a second protocol), not stack
  switching.
* **Frame size of large functions**: a frame holds every live register at
  its widest suspension point; the prototype allocates the maximum per
  function. Per-site frames are the remedy if it matters.
* **Code size**: every yielding function gains a dispatch and per-site
  save/restore code. The golden suites ran, but nothing measured the
  growth.
* **The NIR→wasm backend duplicates `clif.rs`'s decisions** (section 3.3):
  drift shows up as parity failures; the shared op table and running every
  golden suite on wasm in CI contain it.
* **Root precision of running frames**: the shadow-stack frames of running
  functions keep a slot's last value until it is overwritten (the existing
  fallback model's property); bounded by one frame's slots, but not
  per-safepoint precise as stack maps are. Clearing dead slots at calls is
  available if it ever matters.

### 12.2 Open questions

* Should the resumable lowering also replace stack switching natively?
  Not proposed: native coroutines work, and fusion covers their hot cases.
  But one mechanism everywhere would remove two assembly switches and a
  fiber port; measure first.
* The frame hand-off through Vm slots (prototype) or a hidden parameter
  (production): the parameter is cleaner and costs a register per yielding
  call; decide in milestone A0.
* Which ops the wasm backend inlines first: measure on the golden corpus.
* The export list of a wasm command and of a handler, and an exported
  allocator, for milestone C/D.

### 12.3 Rejected

| Alternative | Why |
|---|---|
| Asyncify as the production mechanism | memory per coroutine, unguarded linear stacks, exact instrumentation lists, size (section 5.2) |
| Core stack switching now | flag-only in Wasmtime, absent in LLVM, flag-only in browsers (5.3) |
| A Wasm-only coroutine subset, or fusion as the mechanism | the first would make valid programs target-dependent; AGENTS.md forbids the second ("Coroutine fusion") |
| CLIF→wasm | section 3.3 |
| Per-coroutine shadow segments | unnecessary under the resumable lowering (6.1) |
| A host that drives coroutine handles, or a Wasm-specific scheduler | breaks the event loop's abstraction (7.1) |
| POSIX emulation as the WASI strategy | typed component interfaces serve servers better (8.2) |
| The compiler inside Wasm (route T) | out of this milestone's scope: Botlish compiles ahead of time, on a build machine |

---

## 13. Roadmap

Effort ranges come from CRANELIFT-WASM.md's and WASM-PORT-FEASIBILITY.md's
calibrations where those items match, adjusted by what the prototypes
showed; they are estimates. "Architecture risk" is what could still change
the design; "implementation risk" is how much work could surprise.

**A0. Resumable coroutines and ShadowOnly roots on the native fallback
plan** (new; no wasm). The pass (production form: an explicit frame
parameter, inline frame operations), the frame object, ShadowOnly storage
(no leaf publication, no depth token), the fallback plan running
coroutines, a CI lane (x86-64 `fallback-roots`: golden suites, coroutine
test files, GC stress), mutants of section 6.3's invariants. Fixes section
11.6's defect. *Result*: every coroutine program runs on the fallback plan,
with GC stress, before any wasm exists. 12–20 pd; architecture risk low
(prototyped across all golden suites), implementation risk medium
(production frames, effects, the test lane).

**A. Wasm32 runtime and NIR→wasm lowering, non-coroutine programs.** The
target row and ILP32 (3.1); capabilities from the target (3.2); P1 (32-bit
indices and limits), P5 or a layout table, P6 (gating, `Heap::configure`),
P7 (typed helper descriptor, shared op table); the wasm backend and its
object writer; the startup crate and link (`wasm32-wasip1` and `wasip2`,
explicit exports); `botlish-wasm` (its own workspace: run, trap
classification, limits); a parity lane under Wasmtime with GC stress.
*Result*: ordinary programs run under Wasmtime with the real runtime and
pass targeted parity and GC tests. 30–50 pd.

**B. General coroutines on wasm.** A0's pass through A's backend; the
corpus and every golden suite on wasm, GC stress included. *Result*:
independently stored handles suspend and resume, suspended-root GC and
cleanup proven on wasm. 6–12 pd after A0 and A (A0 carries the risk).

**C. Persistent WASI applications.** `std::wasi` (io, fs, path, clock,
random, over wasi-libc), a WASI `std::event_loop` driver (`poll_oneoff` /
`wasi:io/poll`), host limits and configuration, components as the primary
artifact, a CI lane. *Result*: a Botlish application runs with host clocks,
I/O and event-loop wakeups. 20–35 pd.

**D. HTTP and SSE.** A persistent server first (a WASI socket driver for
the event loop; concurrent connections as coroutine tasks; streaming
responses), then a `wasi:http/incoming-handler` adapter as a separate
entry (a handler's runtime importing only the proxy world's interfaces),
then WASI 0.3 async exports evaluated for it. *Result*: the long-term
acceptance target -- a long-running HTTP server with concurrent SSE clients,
timers and independent tasks under Wasmtime -- and a request-invoked
handler of the same application. 25–45 pd; implementation risk medium
(`wasi:sockets` maturity in hosts).

**E. Further hosting.** The browser host and a JSPI driver, Emscripten as a
link profile, library-mode exports with a generated JS/TS wrapper, threads
through a host transport, the C FFI on wasm. Each its own milestone, after
D.

A0 and A are independent and can proceed in parallel; B needs both; C needs
A (and B for loops with tasks, which is most of them); D needs C.
