# WebAssembly for the Cranelift backend

What it would take to compile Botlish programs to WebAssembly through the
existing native backend, with no WASI, and with Rust-implemented intrinsics
(something like `http_request`) available to the program.

This is a feasibility study, written before any implementation.

* **No production code was changed.**
* Code claims cite `path:line` at commit `f6207f4`.
* Measurements come from throwaway prototypes built outside the repository and
  not committed. [Appendix D](#appendix-d-how-the-evidence-was-produced)
  describes them.
* The prototypes ran against `5199491`. Between that commit and `f6207f4` the
  only change under `native/src/` is one unit test (`string_alloc_tests.rs`).

## Outcome

**Cranelift cannot emit WebAssembly.**
* Cranelift 0.135.2, the version locked here, targets x86-64, aarch64, riscv64,
  s390x and Pulley (Wasmtime's interpreter bytecode).
* `isa::lookup` rejects `wasm32`, and `cranelift-object` rejects the wasm binary
  format.
* In the Cranelift world wasm is only an *input*: Wasmtime translates wasm into
  Cranelift IR and compiles that to machine code.
* So wasm support cannot be "one more Cranelift ISA". It has to be a new wasm
  emitter behind the existing translation (§1).

**Recommended shape: wasm as a second target of the existing translator.**
* `codegen/clif.rs` keeps building the same Cranelift IR (CLIF) from NIR.
* A new `codegen/wasm/` lowers that CLIF to wasm instead of handing it to a
  Cranelift ISA.
* The translator emits a closed set of 27 CLIF opcodes over `i64`/`i8`:
  * Each has a short, fixed wasm lowering. Most are a single instruction, and a
    few need a short sequence.
  * Control flow is structured with Ramsey's "Beyond Relooper" algorithm over
    Cranelift's own CFG and dominator-tree analyses.
* Linking follows today's standalone executable, adapted for wasm (§4.6): a
  relocatable wasm object plus a generated `startup.rs`, linked by `rustc` and
  `rust-lld` against the existing Rust runtime compiled for
  `wasm32-unknown-unknown`.
* One self-contained `.wasm` module comes out. Its only imports are three
  `botlish_host_v1` functions.

**Cranelift's role on the wasm path.**
* Used: its frontend, IR and CFG analyses, and its verifier, which is called
  explicitly.
* `cranelift-object`'s `ObjectModule` stays only as a declaration table.
* Not used: its ISA code generators, its register allocator and `cranelift-jit`.
* At run time a Wasmtime host built on the same Cranelift 0.135 line compiles the
  module to machine code.

**Rust intrinsics without WASI work in two layers.**
* **Inside the module.** The Botlish-facing half of an intrinsic is ordinary
  Rust in the runtime, compiled into the module. It is the same `rt_*` helper the
  native backend calls, so argument checks, String construction and errors behave
  identically.
* **At the boundary.** Only the raw transport crosses into the host, through a
  versioned, capability-keyed import trio (`call`/`read`/`release`).
* **In the host.**
  * A Rust/Wasmtime host implements capabilities with `Linker::func_wrap`
    (blocking) or `func_wrap_async` (fibers).
  * Browsers (Chrome 137, Firefox 153, Safari 27) and Node ≥ 24.20 use JS
    Promise Integration (JSPI).

**What the prototypes established (§2).**
* **The runtime builds for wasm32.** Once its Cranelift dependencies are
  target-gated, it compiles with exactly one error: a hard-coded 64-bit header
  size.
* **Control flow is structurable.** Every NIR and CLIF function in two
  independent censuses is reducible.
* **The CLIF lowering is correct.** A 611-line CLIF→wasm function lowering,
  with the proposed `ShadowOnly` root mode built into the Translator, matched
  native output for 286 of 287 programs on both V8 and Wasmtime 48.0.2, with GC
  stress off and on. The one difference is the wording of a stack-overflow
  message.
* **The real artifact works.** A NIR→wasm prototype, linked exactly as the
  proposed artifact (relocatable object, `startup.rs`, `rust-lld`), matched
  native output for all 121 programs on Wasmtime 48.0.2 and 119 of 121 on
  Node 22, with GC stress off and on.
* **Speed.** With the proposed root mode, CLIF→wasm under Wasmtime ran
  fib(27) within 3% of the Cranelift JIT. Allocating programs ran at 0.94–1.15×
  the JIT's time.
* **Intrinsics.** An `http_request`-style intrinsic ran end to end with a Rust
  host and no WASI.

**What has not been run (§8.1).** The CLIF path has not yet been packaged the
production way. Its runs used a two-instance loader instead of the relocatable
object, generated `startup.rs` and `rust-lld` link; that link step was proven
only with the NIR→wasm prototype. They also used a padding-type layout instead
of `u64` fields, and thread-local switches instead of an explicit `Target`.

**What has to be built:**
* the CLIF→wasm lowering and the object writer;
* an explicit compilation `Target` replacing five host-dependent checks;
* a wasm root mode;
* a pointer-width-independent runtime layout;
* a wasm program boundary in the runtime;
* a small Wasmtime host crate;
* the Tcl, harness and CI plumbing;
* for `http_request`: a struct-result type for natives, and a deterministic
  fixture transport for parity testing.

**The investigation found three bugs in today's code (§9).**
* **Stack overflow off Linux x86-64.** On every host other than Linux x86-64, a
  stack overflow can crash or silently produce a wrong value: the fallback
  prologue returns 0 to callers that do not check for it.
* **Deep recursion on Linux x86-64.** On production Linux x86-64, a recursion
  deeper than about 4.19 million frames loses GC roots and returns a wrong value.
  This reproduces on the unmodified driver.
* **32-bit truncation.** Five runtime helpers truncate an index, capacity or
  count before range-checking it on 32-bit targets.

**Effort: about 46–76 person-days.**
* That is 9–15 weeks for one engineer, or about 5–9 calendar weeks with two or
  three people.
* It covers wasm execution plus `http_request` on all six backends, with parity
  tests (§7).
* About a fifth of it is preparatory work worth landing even if wasm never ships.

## Contents

1. [What Cranelift can and cannot do](#1-what-cranelift-can-and-cannot-do)
2. [What the prototypes established](#2-what-the-prototypes-established)
3. [Inventory: what in today's backend is target-specific](#3-inventory-what-in-todays-backend-is-target-specific)
4. [Design](#4-design)
5. [Rust-based intrinsics without WASI](#5-rust-based-intrinsics-without-wasi)
6. [Driver, Tcl, test harness and CI](#6-driver-tcl-test-harness-and-ci)
7. [Plan and effort](#7-plan-and-effort)
8. [Risks and decisions for the maintainer](#8-risks-and-decisions-for-the-maintainer)
9. [Bugs and documentation drift found on the way](#9-bugs-and-documentation-drift-found-on-the-way)
* [Appendix A: measurements](#appendix-a-measurements)
* [Appendix B: wasm feature and engine support](#appendix-b-wasm-feature-and-engine-support-as-of-2026-10-03)
* [Appendix C: host ABI v1 (sketch)](#appendix-c-host-abi-v1-sketch)
* [Appendix D: how the evidence was produced](#appendix-d-how-the-evidence-was-produced)

---

## 1. What Cranelift can and cannot do

### 1.1 No wasm output

* **ISAs.** `cranelift-codegen-0.135.2/src/isa/` contains `x64/`, `aarch64/`,
  `riscv64/`, `s390x/` and `pulley32.rs`/`pulley64.rs`/`pulley_shared/`.
  * `isa::lookup` (`src/isa/mod.rs:108-124`) matches only those architectures.
  * A `wasm32-unknown-unknown` triple falls through to `LookupError::Unsupported`
    ("Support for this target has not been implemented yet").
  * The newest release, 0.136.2, has the same list.
* **Object files.** `cranelift-object-0.135.2/src/backend.rs:56-73` writes ELF,
  COFF and Mach-O. It rejects `BinaryFormat::Wasm` as "binary format wasm is
  unsupported". The underlying `object` 0.39 writer has no wasm support either.
* **The reverse direction.** The crate `cranelift-wasm` translates *from* wasm
  to CLIF.
  * Its highest version is 0.112.3, from November 2024; only 0.111.x backports
    have been published since.
  * Its successor is `translate/` inside Wasmtime's
    `wasmtime-internal-cranelift`.
* **This repository's configuration.** It builds Cranelift with only the default
  host ISA (`native/Cargo.toml`) and asks `cranelift_native` for the compiling
  machine's ISA (`native/src/codegen/mod.rs:147-165`).

### 1.2 Where Cranelift and wasm do meet: Wasmtime

* **Wasmtime is the natural host.** It compiles wasm to machine code with
  Cranelift, so it is the natural place both to run the produced modules and to
  implement Rust host intrinsics.
* **The pins are coupled.** The Wasmtime 48.x line is built on Cranelift
  0.135.x. Every `cranelift-codegen 0.135.N` requires
  `wasmtime-internal-core =48.0.N` exactly, so a host's Wasmtime pin and the
  native backend's Cranelift patch level always move together.
* **Current state.** `native/Cargo.lock` locks Cranelift 0.135.2 and
  `wasmtime-internal-core 48.0.2`; `native/Cargo.toml` itself asks only for
  `0.135`.
* **Wasmtime 49 is out of reach for now.** 49.0.0 was released 2026-09-21 and
  the latest is 49.0.2. It uses Cranelift 0.136, object 0.40 and wasmparser
  0.258, so adding it today would link two copies of Cranelift.
* **Pin the newest 48.x.** Wasmtime 48.0.3 (2026-09-24) and 48.0.4/48.0.5
  (2026-10-02) are security releases. They fix a series of advisories, mostly in
  WASI, the Component Model, GC and fuel accounting.
  * The host should pin `=48.0.5` and bump Cranelift to 0.135.5 in the same
    commit.
  * For `cranelift-codegen` itself that bump changes only the manifest.

### 1.3 The interpretations considered

| Approach | Verdict | Why |
|---|---|---|
| **CLIF→wasm**: the existing `clif.rs` translator builds CLIF as today; a new lowering turns that CLIF into wasm | **Recommended** | There is one translator, so every semantic decision, fast path and future intrinsic in `clif.rs` reaches wasm without duplication. A 611-line function lowering reproduced 286/287 programs on V8 and on Wasmtime, with the proposed root mode and under GC stress (§2). That count excludes module assembly, the loader and any object writer. It is the literal reading of "add wasm to the Cranelift backend". |
| **NIR→wasm**: a second translator beside `clif.rs` | Validated fallback | It works. The prototype is 1,844 lines including its relocatable-object writer, plus a 242-line startup generator, and linked as the real artifact it reproduced all 121 programs on Wasmtime. But every future op, fast path and intrinsic would have to land twice. It becomes the right choice only if Cranelift IR churn ever makes the CLIF lowering expensive to maintain. |
| Compile with Cranelift's Pulley ISA and run `pulley-interpreter` inside wasm | Rejected | It builds (a 156 KB wasm module with no imports) and runs, but about 11× slower than Cranelift-compiled wasm (822 ms vs 71–75 ms on the same loop). `cranelift-jit` cannot relocate Pulley host calls (`compiled_blob.rs:314` is `unimplemented!`), and `cranelift-object` rejects Pulley. |
| WasmGC object model (`struct`/`array`/`i31ref`) | Rejected | Rust cannot allocate or touch WasmGC references; LLVM 22's `gc` feature only gates `ref.test` on funcref. `wasm-ld` refuses GC types ("unmodeled reference or GC types"). `i31ref` holds 31 bits, against Botlish's 63-bit small Int. It would mean rewriting the heap, strings and bigints as generated wasm. |
| Generate Rust source and compile it with `rustc` | Rejected | A different project: it abandons NIR→CLIF translation and costs seconds per program. |
| `wasm64`/memory64 | Not needed | The Rust target is tier 3. memory64 needs explicit bounds checks and is flag-only in Safari. The 4 GiB wasm32 address space is ample. |

So the design below treats wasm as **an alternative final stage of the existing
Cranelift backend**:
* **Shared:** NIR, the Tcl lowering, the Translator, the GC-root analysis and the
  runtime.
* **Replaced:** the ISA code generator becomes a CLIF→wasm lowering, and the ELF
  link becomes a wasm link.

---

## 2. What the prototypes established

| Question | Result |
|---|---|
| Does the runtime compile for `wasm32-unknown-unknown`? | **Yes, after target-gating and one change.** `lib.rs` already contains only `nir` and `runtime` (`native/src/lib.rs:1-4`). With the real dependency list, the only failure is `region` 3.0.2, which comes from `cranelift-jit`; `native/Cargo.toml` does not target-gate it. With just the runtime's real dependencies (num-bigint, num-traits, unicode-general-category), the only error is the const assert at `native/src/runtime/strobj.rs:108`. It fails because `STR_HEADER_SIZE = 25` (`strobj.rs:83-85`) assumes 8-byte `usize` fields. |
| Does it *work* on wasm32? | **Yes.** Under Node, all of these pass: BigInt arithmetic across the 2^62 boundary, Unicode string operations, hashing (identical hashes on x86-64 and wasm32), `argv` including the declared error `0x40000000`, `show()`, error rendering, and GC with temporary roots. |
| How big is it? | 240,354 B stripped at opt-level 3 (71,544 B gzipped). 191,233 B at opt-level `z` + LTO (58,588 B gzipped). num-bigint is 41% of the code. A linked program module is about 280 KB at the median, dominated by the runtime. |
| Imports? | **None: no WASI and no wasm-bindgen.** On this target `std` compiles I/O, threads and clocks as stubs that do nothing or trap. |
| Are the control-flow graphs structurable? | **Yes, on everything measured.** Two independent re-implementations of `roots.rs`'s CFG builder found 0 irreducible functions among the 4,024 functions of the 259 committed `.nir` files, plus 298 and 804 functions from freshly lowered programs. The CLIF→wasm prototype found 0 among 8,370 CLIF functions. `native/lower.tcl` emits only single-entry loops, with forward `break`/`continue`/`handle` edges. **But nothing checks this:** `nir::validate` (`nir.rs:1485`) does not, and the JIT accepts a hand-written irreducible program. |
| Does CLIF→wasm work? | **Yes.** The unchanged Translator, forced onto its non-x86 root path, lowered all 287 programs (252 committed `.nir` files plus 35 freshly lowered): 8,370 wasm functions, every module valid. On the real runtime compiled to wasm32 (Node), **286/287** matched `botlish-native run` byte for byte, both normally and under GC stress (1,021,962 collections). The one difference was the text of a stack-overflow message. The same 286/287 held with the proposed `ShadowOnly` root mode built into the Translator, on V8 and on a Wasmtime 48.0.2 host, with GC stress off and on. On each engine the 286 matching programs ran the same 1,021,962 collections as before, program for program. These runs used a two-instance loader: runtime and program were separate instances sharing memory and table, and program metadata was parsed from the NIR inside wasm. |
| Does the real artifact work, in both engines? | **Yes.** A NIR→wasm prototype wrote a relocatable object, linked it with a generated `startup.rs` through `rustc --target wasm32-unknown-unknown` and `rust-lld`, and ran 121 programs. With GC stress off and on, **all 121** were byte-identical on Wasmtime 48.0.2 and **119** on Node 22. The 2 Node failures are deep recursions that exceed V8's default engine stack. It implements all 42 `nir::Inst` and all 79 `OpCode` variants; passing programs exercised 38 and 62 of them, and no translation bug turned up. |
| Are the shadow-stack roots really what keeps programs alive? | **Yes.** A negative control dropped every root store. 8 of 8 programs still passed without GC stress, and 0 of 8 passed with it (corrupted spans, allocator asserts, wrong values). |
| Speed? | **Close to the Cranelift JIT with the proposed root mode** (§4.4; the NIR→wasm prototype is in Appendix A.1). CLIF→wasm with `ShadowOnly` under Wasmtime, against the JIT: fib(27) 1,573 vs 1,531 µs (1.03×); csv_records (2,000 rows) 1.15×; csv_parse 0.94×; uri ×20,000 1.03×; refined-checks 1.13×. The NIR→wasm prototype gave similar figures, with csv_parse at 0.85× and csv_records at 1.01×. The one large cost is the shadow-stack frame every calling function reserves on today's non-x86 path (the "depth token", §4.4). It made fib about 1.9× slower than the JIT on both engines, and the proposed mode removes it. |
| Rust intrinsic without WASI? | **Yes.** A Rust `rt_http_request` in the linked module called a `#[link(wasm_import_module = "botlish_host")]` import, served both by Wasmtime `Linker::func_wrap` and by a Node function. The module's only imports were `botlish_host.*`. Async variants also work: Wasmtime `func_wrap_async` + `call_async` on a fiber cost about 2% more, and JSPI with a real `fetch()` worked on Node 24.21 and 26.10. A two-phase handle protocol, and a Tcl encoder byte-identical to the Rust one, were also validated. |
| Can closures and dynamic calls cross between Rust and generated code? | **Yes.** On wasm32 a Rust function pointer *is* a funcref-table index. `botlish_entry_N as *const () as usize` in the generated startup yields that index, and `rt_call_value`'s `transmute` + call (`native/src/runtime/ops.rs:1397`) becomes a `call_indirect` into generated code with no runtime change. |

What the prototypes did **not** settle is listed in §8.1.

---

## 3. Inventory: what in today's backend is target-specific

Every row was checked against the code. "Wasm status" describes today's code
compiled or run for wasm32.

| Area | Today (x86-64 Linux) | Wasm status | Change needed |
|---|---|---|---|
| NIR and `native/lower.tcl` | Target-neutral except for one assumption: a 64-bit integer word. That word carries the tagged small-Int domain [-2^62, 2^62), `rawint`, `rawShiftMax 64` (`native/lower.tcl:201-206`), and 8-character packed ASCII. NIR contains no pointer, offset, size or alignment (`native/src/nir.rs:437-574`). | Valid as long as `Value` stays an `i64`, which wasm has natively | **None.** The NIR for wasm is byte-identical to the NIR for x86-64. |
| Code generation | `clif.rs` → Cranelift ISA → machine code (`codegen/mod.rs:170-239` JIT, `:327-340` object) | No ISA exists | CLIF→wasm lowering (§4.2) |
| Target decisions | Five sites read the *compiling host*: `isa().name() == "x64"` for helper calls (`clif.rs:187`) and for stack maps (`clif.rs:527`); `native_stack_overflow_supported()` in `roots::plan` (`roots.rs:722`) and for probestack (`codegen/mod.rs:157`); `cfg!(target_arch = "x86_64")` in the root report (`roots.rs:779`) | When cross-compiling these would pick the x86 strategy | An explicit `Target` (§4.2) |
| GC roots | Native frame slots, Cranelift user stack maps and a frame-pointer chain walk (`runtime/framewalk.rs:98-158`; `.cargo/config.toml` forces frame pointers) | Impossible: wasm locals and the call stack are invisible to the program | A shadow stack in linear memory. The mechanism exists as the non-x86 fallback `RootStorage::RuntimeStack` (`roots.rs:90`, `clif.rs:699-716`) (§4.4). |
| Stack overflow | A 1 GiB worker thread (`runtime/aot.rs:26-31`, `main.rs:68-72`), a pthread guard page, and a SIGSEGV/SIGBUS handler on an alternate stack that writes `OVERFLOW_LINE` and calls `_exit` (`runtime/platform/x86_64_linux.rs:32-55`) | No threads or signals. Engine stack exhaustion is a trap the module cannot catch. | The host maps traps; shadow-stack overflow becomes fatal (§4.5) |
| Field offsets used by generated code | Host `offset_of!` plus one literal (`runtime/vm.rs:180-186`, `runtime/value.rs:283-287`, `runtime/strobj.rs:85`, `:103`, `:105`), loaded as `I64` | 10 of the 14 offsets generated code reads have different values on wasm32, and an 11th, the literal `STR_TEXT_OFFSET = 25`, no longer matches the wasm32 layout (Appendix A.3). An `I64` load reads two 4-byte fields at once. | Make every such field 8 bytes wide (§4.3) |
| Helper ABI | "all are 64-bit words, including the vm pointer" (`ops.rs:1509-1510`); every Cranelift signature is all-`I64` (`clif.rs:165-179`) | `*mut Vm` is `i32` in all 61 helpers, and so is the array pointer of 5 helpers. A mismatched import only *warns* in `wasm-ld`, and leaves a trapping stub. | A typed helper descriptor, plus `--fatal-warnings` at link (§4.3) |
| Code addresses | `func_addr` for closures (`clif.rs:1273`), `ClosureObj.code: usize`, the `GenericEntry` transmute (`ops.rs:126`, `:1397`), JIT `generic_entries` | They become funcref-table indices, which work unchanged inside one linked module | Generic entries get the exact wasm type `(i32, i64, i32) -> i64`; optionally drop `func_addr` (§4.3) |
| Heap alignment | The pointer tag needs `v & 7 == 0` (`value.rs:311`). `Header` has only `u8` fields (alignment 1, `value.rs:94-102`), so an object is 8-aligned only through an 8-byte field of its own. `NativeObj` (`native: u32`, `value.rs:277-281`) has alignment 4 even on x86-64. | On wasm32 most object types have alignment 4. They come out 8-aligned only because dlmalloc happens to return 8-aligned blocks (0 of 60,000 were misaligned). A 4-aligned pointer would read as a UnicodeChar (`CHAR_TAG = 0b100`). | `#[repr(C, align(8))]` on `Header` |
| `usize` width | `as usize` before the range check in `rt_list_get` and `rt_mutarray_{allocate,get,set,freeze}` (`ops.rs:1103`, `:1214`, `:1234`, `:1251`, `:1309`); `MAX_COLLECTION_LENGTH = SMALL_MAX as usize` (`value.rs:65`) | **Wrong answers.** `list_get([10,20,30], 2^32)` returns `10`. The collection limit becomes 4,294,967,295, which also changes RANGE messages. | Compare in `i64`/`u64` before casting (§9.2) |
| Program boundary | `runtime::aot::run` spawns a thread, reads environment variables, and prints to stdout/stderr (`runtime/aot.rs:25-70`) | Thread spawn fails, environment variables are absent, stdio is silently discarded, and `Instant::now` traps (`heap.rs:119`, with metrics on) | A `runtime/wasm.rs` boundary with host services (§4.7) |
| GC configuration | `BOTLISH_NATIVE_GC_STRESS` and `_GC_MIN` come from the environment (`heap.rs:63-67`) | Always absent | An explicit `Heap::configure`, fed by the host |
| Shadow array | Not allocated on Linux x86-64. Elsewhere `vec![0u64; 1 << 22]`, i.e. 32 MiB zero-filled (`vm.rs:36`, `:190-196`) | Zero-filling costs about 14 ms per fresh instance, and wasm memory never shrinks | Host-sized and not zero-filled (§4.4) |
| Packaging | `cranelift-*` and `libc` are unconditional dependencies (`native/Cargo.toml`) | `region` (via `cranelift-jit`) fails to compile | Target-gate the dependencies; no crate split needed |
| Linking | A Cranelift object plus a generated `startup.rs`, with `rustc` linking `libbotlish_native.rlib` (`codegen/aot.rs:20-180`). It refuses every host other than x86-64 Linux/glibc (`:120`). | The same recipe works with a wasm32 rlib and a wasm object | A wasm object writer and a wasm `startup()` (§4.6) |

---

## 4. Design

### 4.1 Pipeline

```
.bot/.hir ─▶ HIR ─▶ native::lowered (native/lower.tcl) ─▶ NIR text        (unchanged)
                                                           │
botlish-native (driver, Cranelift 0.135)                    │  nir::parse: parse, validate,
                                                           │  settle call effects (unchanged)
   run/bench/batch   clif.rs ─▶ CLIF ─▶ Cranelift ISA ─▶ JIT                   (unchanged)
   executable        clif.rs ─▶ CLIF ─▶ ELF object + startup.rs ─▶ rustc        (unchanged)
   wasm   OUT        clif.rs ─▶ CLIF ─▶ codegen/wasm ─▶ wasm object + startup.rs
                     (Target::Wasm32)                   ─▶ rustc --target wasm32-unknown-unknown
                                                        ─▶ rust-lld ─▶ program.wasm
                                                                              │
   program.wasm = generated code + Rust runtime + startup: one module          │
   imports: botlish_host_v1.{call, read, release}                              │
   exports: memory, botlish_run (+ __stack_pointer for trap classification)    ▼
botlish-wasm (new workspace crate; wasmtime =48.0.5, same Cranelift 0.135)  JS loader (Node ≥ 24.20, browsers; JSPI)
   run / harness / bench; capabilities: sys.* + http.request …               same ABI, same fixtures
```

### 4.2 Code generation: lowering the Translator's CLIF to wasm

**Explicit target.**
* A `Target { stack_maps, direct_helpers, root_mode, probestack }` replaces the
  five host checks listed in §3.
* It is passed to `clif::declare`/`define`, to `roots::plan`/`report`, and to
  `codegen::isa`.
* `Target::native(isa)` reproduces today's values exactly, so the CLIF listings
  and objects stay byte-identical.
* `Target::Wasm32` selects the `ShadowOnly` root mode (§4.4) and plain helper
  calls.

**Build/compile split.**
* `define` (`clif.rs:248-421`) builds each function's CLIF and calls
  `module.define_function` right after `b.finalize(config)` (`clif.rs:270/276`,
  `:325/326`, `:415/417`).
* Split each function into "build", which returns the `ir::Function`, and
  "compile". The native paths are unchanged.
* The wasm path calls `cranelift_codegen::verify_function` explicitly. It keeps
  an `ObjectModule` only as the table of `FuncId`s and signatures, and never
  compiles with it.
* The prototypes did not split. They captured each `ir::Function` just before
  `define_function`, still compiled it for x86-64, and discarded the result. The
  split is mechanical, but it has not been tried.

**The closed world.**
* `clif.rs` calls 33 distinct builder methods. Seven of them are `*_imm_s`
  helpers that expand to `iconst` plus the base op. That leaves 26 base opcodes,
  plus `ushr`, which is reached only through `ushr_imm_s`: 27 opcodes in all.
* Values are `I64` or `I8`, and `I8` values live zero-extended in `i32` locals.
  `I8` comes from two places:
  * `icmp` and the `*_overflow` flags;
  * `is_kind` (`clif.rs:1115-1161`), which uses an `I8` header-byte `load`,
    `iconst.i8`, an `icmp` on `I8` operands, and an `I8` block parameter.
* The lowering maps each opcode as in the table below.
* Anything else is `BackendError::Bug`, so a future `clif.rs` change that
  introduces a new opcode fails the corpus test immediately.

| CLIF | wasm |
|---|---|
| `iconst` | `i64.const` (`i32.const` for `I8`) |
| `iadd`/`isub`/`imul`, `band`/`bor`/`bxor` | `i64.add/sub/mul/and/or/xor` |
| `ishl`/`sshr`/`ushr` | `i64.shl/shr_s/shr_u`; both take the count mod 64 |
| `clz` | `i64.clz` |
| `icmp` | `i64.eq/ne/lt_s/…` on `I64` operands, `i32.*` on `I8` operands; result `i32` |
| `select` | `select`; an `I64` condition first becomes `i64.ne 0`, never `i32.wrap_i64` |
| `uextend` (I8→I64) | `i64.extend_i32_u` |
| `load`/`uload8`/`store` | address `i32.wrap_i64`, then `i64.load`, `i32.load8_u` (an `I8` load), `i64.load8_u`, `i64.store` |
| `sadd_overflow`/`ssub_overflow` | wrapping op plus the sign-of-xor test (`((a^r)&(b^r)) < 0`, respectively `((a^b)&(a^r)) < 0`) |
| `smul_overflow` | exact: wrapping product, then a division check with a non-trapping divisor (special case `a == -1`) |
| `call` | `call` with a relocated function index; `Vm` and pointer arguments are wrapped to `i32` per the typed helper descriptor (§4.3) |
| `func_addr` | `i32.const` with a relocated table index, then `i64.extend_i32_u` (or eliminated, §4.3) |
| `stack_addr` | `fp` (an `i32` frame base below Rust's `__stack_pointer`) plus a memarg offset. It is never an `i64` sum wrapped afterwards, so a frame that crosses address 0 traps, provided linear memory stays below 4 GiB minus the largest frame. The host enforces that cap, for example with a Wasmtime `ResourceLimiter` (§4.4, §4.5). |
| `return` | `return`; multiple results use multi-value |
| `jump`/`brif` | structured `br`/`br_if`/`if`; block arguments become parallel moves into locals; an `I64` `brif` condition (every `check` after a fallible call, `clif.rs:987-990`) first becomes `i64.ne 0` |
| `trap` | `unreachable` |

The overflow sequences were checked against a BigInt reference, on 179,776
operand pairs per operation, with 0 errors. The slow path is taken exactly when
the result leaves the small range. The helpers the slow path calls
(`rt_int_add`, …) are total, so a conservative multiply check would also be
sound.

**Structuring.**
* **Algorithm.** Ramsey's "Beyond Relooper" (ICFP 2022): a dominator tree plus
  reverse postorder, computed with Cranelift's own `flowgraph::ControlFlowGraph`
  and `dominator_tree::DominatorTree`.
  * A block with two or more forward in-edges is a merge node and becomes a
    `block`. The target of a back edge becomes a `loop`.
  * Translator-internal diamonds (`int_arith`, `list_get`, `is_kind`) need no
    special case, because they are ordinary CLIF blocks.
  * The prototype's core is about 120 lines.
* **Locals.** Each SSA value becomes one local, and locals are never reused.
  * The prototype's maximum was 1,815 locals per function, against the engines'
    hard limit of 50,000.
  * The lowering should check that limit and fail with `BackendError`. Reusing
    locals by liveness is the remedy if a real program ever approaches it.
* **Irreducible CFGs** are rejected as `BackendError::Bug`.
  * The check is free, because dominance is computed anyway.
  * Do not change `nir::validate`, since that would change native behaviour.
    Whether reducibility should become an NIR invariant can be decided
    separately.

**Encoding.**
* Use `wasm-encoder` and `wasmparser` from the 0.254 line, the one Wasmtime 48
  uses, so the workspace keeps one copy.
* `wasm-encoder` writes the sections and the `linking` symbol table. It has no
  encoder for `reloc.*` sections or padded LEBs, so instructions with
  relocatable immediates are written as raw bytes with 5-byte padded LEBs, and
  their offsets are recorded.
* The relocations needed are `R_WASM_FUNCTION_INDEX_LEB` (calls),
  `R_WASM_GLOBAL_INDEX_LEB` (`__stack_pointer`) and, unless `func_addr` is
  removed, `R_WASM_TABLE_INDEX_SLEB`.
* The NIR→wasm prototype's relocation writer is about 40 lines. The CLIF→wasm prototype had no object writer (§1.3).

**Why not NIR→wasm.**
* **Duplication.** A second translator would carry clif.rs's 1,314 code lines of
  decisions twice:
  * the op→helper table (`clif.rs:1682-1846`, ending in `_ => unreachable!()`
    at `:1845`);
  * the fast paths and error exits;
  * the root stores and alloc sites;
  * the generic-entry ABI conversions (`clif.rs:331-416`).
* **Intrinsic cost.** The argv commit shows how small an intrinsic's codegen
  footprint is today: 6 lines in `clif.rs`. Under CLIF→wasm it stays that way.
  Under NIR→wasm it doubles, and drift between the two copies shows up as parity
  failures.
* **The NIR→wasm prototype is still valuable.** It proves the escape hatch
  exists. It maps NIR registers to locals 1:1, uses multi-value naturally, and
  does not depend on Cranelift IR stability.

### 4.3 The runtime ↔ generated-code contract on wasm32

**Values.**
* `Value` stays `u64` (`value.rs:31`), held in a wasm `i64`.
* A heap pointer is a zero-extended 32-bit linear-memory address. Rust's
  `ptr as u64` and `u64 as *const T` already behave that way on wasm32
  (verified).
* All tag arithmetic is unchanged.
* A 32-bit `Value` would invalidate facts already baked into NIR: `fitsSmall`
  (`hir/range.tcl`), `rawint`, the 8-character ASCII tier and the 61-bit hash
  mask.

**Layout: 8-byte slots wherever generated code looks.**
* **Which fields.** Two kinds of field must occupy 8 bytes on every target, so
  that each read field has the same offset on both widths:
  * every pointer-width field that sits at or before a field generated code
    reads;
  * every lone `u32` that leaves a 4-byte hole before such a field on x86-64
    (`Vm.alloc_site`, `StructObj.shape`).

  `ClosureObj.func`/`arity` already fill one 8-byte word together and stay as
  they are. The fields affected are:
  * the `Vm` prefix: `ss_top`, `ss_limit`, `consts`, `alloc_site`,
    `native_roots_ptr`, `statics_ptr`;
  * `ListObj` `len`/`ptr`;
  * `StructObj` `shape`/`len`/`ptr`;
  * `ClosureObj` `code`/`ncaps`/`caps`;
  * `StrObj` `chars`/`byte_len`. Generated code reads `chars`, `ascii` and the
    text.

  `SetObj` is never read by generated code.
* **Asserts.** Add `const` asserts that every `VM_*`/`*_OFFSET` constant has the
  same value under both pointer widths.
* **What this buys:**
  * The host's `offset_of!` values become the wasm32 values by construction, so
    the unchanged Translator's CLIF is correct on wasm32.
  * The x86-64 layout does not change, because `usize` is already 8 bytes there.
    A prototype of the padding variant left all 287 x86 objects byte-identical.
  * `strobj.rs:108` holds as written.
  * It closes a latent hazard: `clif.rs:939-940`/`:955` store an `I64` into the
    `u32` field `alloc_site` (`vm.rs:94`). That is harmless on x86-64 only
    because 4 padding bytes follow it; on wasm32 it would overwrite
    `native_roots_ptr`.
  * There is precedent: `native_roots_len` is already a `u64`, so that generated
    code can use one `I64` op on it (`vm.rs:105-108`).
* **Two implementations, which fail differently:**
  * **(a) Change the field types to `u64`.** Preferred. It costs about 40 casts
    at use sites, and the type enforces the width.
  * **(b) A padding field after each such field.** Zero-sized on 64-bit, a `u32`
    on 32-bit. About 57 lines, with the x86 source unchanged; prototyped. But the
    type does not enforce the pad's zero value:
    * every raw-write construction path (for example `StrObj` in `strobj.rs`)
      must write the pad;
    * a missed write is invisible on x86;
    * on wasm32 it gives a garbage length, which the inline `list_get` bounds
      check trusts.

    If (b) is chosen, add a debug assertion that pads are zero on every object
    the collector visits.
* **Rejected: a per-target offset table** threaded through `clif.rs`. It keeps
  two layouts alive forever, it endangers native byte-identity, and drift means
  silent memory corruption.

**Alignment.** Add `#[repr(C, align(8))]` on `Header`. The only x86-64 effect is
that the static `NativeObj` grows from 12 to 16 bytes. Even on x86-64,
`NativeObj` relies on allocator over-alignment today.

**Helper ABI.**
* **Typed descriptor.** Each helper gets parameter kinds `Vm | Word | Ptr` and a
  result kind `Value | Raw`. A macro generates the descriptor and emits a
  compile-time signature assertion per helper. A deliberately mismatched
  descriptor was verified to be a compile error on both targets.
* **Mapping.** Cranelift keeps mapping every kind to `I64`, so `clif.rs` output
  does not change. The wasm lowering maps `Vm` and `Ptr` to `i32`.
* **Which parameters are pointers on wasm32.** `vm` in all 61 helpers, plus the
  trailing array of `rt_list_new`, `rt_struct_new`, `rt_construct`,
  `rt_closure_new` and `rt_call_value`.
* **Link checks.** Every wasm link passes `-C link-arg=--fatal-warnings`;
  without it, a signature mismatch is only a warning and produces a module that
  traps at the call. Add an all-helpers link test.
* **Docs.** Fix `ops.rs`'s ABI doc table, which misses 14 helpers.

**Code addresses.**
* **Generic entries** are emitted with exactly the type `GenericEntry` has as
  Rust sees it on wasm32: `(i32 vm, i64 closure, i32 args) -> i64`. A mismatch
  would trap `call_indirect` with a bad-signature trap.
* **Optional simplification.** Store `generic_entries` in the `Vm` at install
  time, and have `rt_closure_new` look the entry up from its `func` argument
  (`ops.rs:1368`). That removes the only `func_addr` (`clif.rs:1273`) and the
  table relocation, on both targets.
* **Startup externs.**
  * The generated startup must declare only `botlish_fn_0` (`(i32) -> i64`) and
    every `botlish_entry_N` (`(i32, i64, i32) -> i64`), with those exact wasm
    types.
  * Today's startup declares every `botlish_fn_N` as `fn botlish_fn_N();` and
    transmutes. On wasm that is a signature mismatch: `wasm-ld` warns and the
    call traps, and with `--fatal-warnings` the link fails.
  * Only the framemap block, which is dropped on wasm, references the other
    direct functions. A Rust `extern "C"` declaration could not express their
    two-result multi-value types anyway.

**Multiple results.** v1 keeps the Translator's hidden result buffer for
functions with more than 2 results (`clif.rs:165-179`); the corpus maximum is 3.
Plain multi-value returns can come later, as a `Target`-gated optimization.

### 4.4 GC roots: a `ShadowOnly` root mode

**Mechanism.**
* `roots::plan` takes a target mode instead of its boolean.
* Under `ShadowOnly`, every function with at least one colored root slot, leaf or
  not, gets a `RuntimeStack` frame in the shared shadow array:
  * bump `ss_top`;
  * check `ss_limit`;
  * store every definition of a rooted register (`clif.rs:811-823`);
  * restore on every exit, including the error exit (`clif.rs:791-806`).
* A function with no colored slots touches no shadow state.
* There is no `NativeFrame` storage and no `native_roots_ptr` publication.
* Liveness, slot coloring and `entry_zero` are unchanged. `roots.rs` is
  Cranelift-free and operates on `nir::Function` alone (`roots.rs:6-7`).
* There are no stack maps and no frame walk; off x86-64 the walker is already a
  stub (`framewalk.rs:161`).
* The collector never moves objects, so values in wasm locals stay valid across a
  safepoint without reloading.

**No depth token.** Today, on a host without native overflow handling, every
calling function reserves shadow-stack space even when it has nothing to root:
* on non-x86-64 ISAs this is a `RuntimeStack` frame of at least one slot
  (`roots.rs:737`, `prologue_runtime_stack` at `clif.rs:699`). That is the path
  the prototypes were forced onto;
* on x86-64 macOS and Windows it is a separate one-slot token
  (`prologue_depth_token`, `clif.rs:670`).

This reservation bounds recursion, and this document calls it the **depth
token**. It is the single largest cost found:

| fib(27) on V8, two-instance loader, `botlish_fn_0` timed, best of 200 | Time |
|---|---|
| CLIF→wasm, today's fallback roots (depth token) | 2.90–3.67 ms |
| CLIF→wasm, Translator switched to the x86 stack-map root path | 1.59–1.62 ms |
| NIR→wasm prototype, `ShadowOnly`-equivalent roots | 1.57 ms |
| Native JIT | 1.53 ms |

The second row is **not** `ShadowOnly`, and it is not a usable mode:
* On wasm the stack-map root path keeps roots in unscanned stack slots, so it is
  GC-unsound for any program that allocates. A re-run reproduced wrong results on
  three allocating programs.
* It equals `ShadowOnly` only for fib, which has no root slots and no safepoints.

**`ShadowOnly` was then built into a prototype Translator and validated on the
CLIF path.**
* **Correctness.** The prototype added `RootStorage::None` and a root mode to
  `roots::plan`, and made overflow fatal in `prologue_runtime_stack`
  (`rt_stack_overflow`, then trap). It matched native on 286 of 287 programs on
  V8 and on Wasmtime 48.0.2, with GC stress off and on. The one difference is the
  overflow message text.
* **What changes across the corpus** (4,185 NIR functions):
  * 578 leaf functions with slots move from published native-frame blocks to the
    shadow array;
  * 350 calling functions with no slots, `fib` among them, lose their frame
    entirely;
  * 2,479 calling functions with slots, and 778 rootless leaves, are unchanged.
* **Code size.** Wasm code shrinks by 2.1%, and functions with a linear-memory
  frame drop from 1,668 to 1,120.

Best of 200 calls, minimum over three rounds, in µs (relative to the JIT):

| Program | Native JIT | Wasmtime, fallback roots | Wasmtime, `ShadowOnly` | V8, fallback roots | V8, `ShadowOnly` |
|---|---:|---:|---:|---:|---:|
| fib(27) | 1,531 | 2,983 (1.95×) | 1,573 (1.03×) | 2,905 (1.90×) | 1,585 (1.04×) |
| csv_records, 2,000 rows | 10,668 | 12,393 (1.16×) | 12,236 (1.15×) | 11,453 (1.07×) | 11,155 (1.05×) |
| csv_parse, 2,000 rows | 6,562 | 6,030 (0.92×) | 6,153 (0.94×) | 5,961 (0.91×) | 5,654 (0.86×) |
| uri ×20,000 | 44,112 | 45,936 (1.04×) | 45,350 (1.03×) | 49,412 (1.12×) | 48,466 (1.10×) |
| refined-checks | 461 | 526 (1.14×) | 523 (1.13×) | 536 (1.16×) | 534 (1.16×) |

* **Fib.** `ShadowOnly` takes 0.53× (Wasmtime) to 0.55× (V8) the time of
  today's fallback.
* **Allocating programs.** `ShadowOnly` was 0.5–5% faster than the fallback on
  all four programs on V8, and on three of them on Wasmtime. csv_parse on
  Wasmtime was 2% slower: it has no frames to drop, and 6 leaves move to the
  shadow array.
* On Wasmtime, csv_records and csv_parse are 11–12% slower on the CLIF path than
  in the NIR→wasm prototype. Plausible causes are the CLIF lowering's
  one-local-per-SSA-value output and the unreused locals; W6 should look.
* `ShadowOnly` has not yet run on x86 (P3).

Under `ShadowOnly`, a function with no root slots touches nothing. The engine's
own stack limit bounds recursion, and the host maps that trap (§4.5).

**Scratch memory.**
* The Translator's remaining Cranelift stack slots become one frame per function
  below Rust's `__stack_pointer`, restored before every return.
* Under `ShadowOnly` this frame holds only:
  * call argument arrays (`array()`, `clif.rs:1024`);
  * `construct` words (`clif.rs:1319`);
  * result buffers (`clif.rs:1049`).
* No GC root lives in this frame, so it is never scanned:
  * argument arrays and `construct` words only copy registers that are live at
    the call, and those are rooted in their own slots;
  * result buffers are consumed before the next safepoint;
  * the collector never moves objects.
* Not scanning it matters, because `construct` words carry raw tags
  (`runtime/construct.rs:58-61`).
* The `ShadowOnly` CLIF prototype (above) used exactly this layout and never
  scanned the frame. It still matched native on 286/287 programs under GC
  stress.
* In today's fallback mode it is different: leaf root blocks live in this frame
  and are published, and therefore scanned, through `native_roots_ptr`.

**Shadow array.**
* Its size is set by the host.
* Allocate it without zero-fill (`MaybeUninit`). This is sound for three reasons:
  * the collector scans only `[ss_base, ss_top)`;
  * `entry_zero` already zeroes every slot that could be scanned before its first
    store;
  * fresh wasm pages are zero anyway.
* Zero-filling today's 32 MiB array dominated fresh-instance cost: a first run
  took 16.1 ms with zero-fill and 1.6 ms without.
* The soundness argument needs a written proof note and GC-stress coverage.

**Cost.**
* Root stores at definitions already happen on x86-64. `ShadowOnly` adds only a
  bump/compare/store prologue and a restore epilogue, and only in frames that
  have slots.
* On the CLIF path, `ShadowOnly` was 0.5–5% faster than today's fallback on the
  allocating programs, except csv_parse on Wasmtime at +2% (table above).
* The 12–22% that today's fallback costs on x86-64 fib is all depth reservation,
  because fib has no root slots.
* On x86 itself, `ShadowOnly` is unmeasured.
* Scanning one contiguous array made a GC-stress run about 3.2× faster than the
  frame walk.
* Spill-at-safepoint (`RootPlan::safepoint_slots`, `roots.rs:160-171`) is held in
  reserve as an optimization.

**CI exposure.**
* CI does not exercise this root path today. It runs only on x86-64 Linux, where
  the shadow array is not even allocated.
* A scratch build that forced today's fallback on x86-64 (`plan(f, false)`,
  depth reservation included) ran 8 of the 30 `tests/native*.test` files under GC
  stress. It passed 238 of 241 tests; the 3 failures assert the x86-only
  "no depth helper" shape.
* `ShadowOnly` itself has not run on x86. P3's lane, x86-64 under GC stress, is
  its first test, and it tests the wasm root model before any wasm exists.

### 4.5 Stack overflow, traps and instance lifecycle

**Overflow is fatal on every path.** x86-64 Linux already ends the process with
`error {NATIVE LIMIT STACK} {native stack exhausted: too many nested calls}`
(`x86_64_linux.rs:32-55`). On wasm there are three triggers, and every one must
print exactly that line:

1. **Shadow array full.** The `ss_limit` check in a frame with slots stays, for
   memory safety. `rt_stack_overflow` sends a fatal record through the host
   interface, and generated code executes `unreachable`.
2. **Engine stack exhausted.** Wasmtime raises `Trap::StackOverflow`. V8 (Node,
   Chrome) and JavaScriptCore raise `RangeError`. SpiderMonkey (Firefox) raises
   `InternalError: too much recursion`.
3. **Rust linear stack exhausted.** This traps out of bounds; with
   `--stack-first` the stack wraps below address 0.
   * The host classifies an out-of-bounds trap as `NATIVE LIMIT STACK` when
     `__stack_pointer` has wrapped or lies within a small margin (say 64 KiB) of
     address 0.
   * That needs the global to be exported, which the link does explicitly
     (§4.6); a plain rustc cdylib does not export it.
   * LLVM leaf functions address their frame from a local copy of the stack
     pointer without writing the global back, so a leaf-frame overflow can still
     be classified as `NATIVE BUG`. This rule is a heuristic and must be tested.
   * Every other trap is `{NATIVE BUG}`.

In the `ShadowOnly` prototype, overflow was fatal and the loader rendered the
pending error. Two results:
* **The deep-recursion probes from §9.1.** These are `sum` and the raw-result
  `d`, each run with call effects 0 and 1.
  * On the Wasmtime host's 768 MiB engine stack, `ShadowOnly` printed native's
    exact `NATIVE LIMIT STACK` line for all of them.
  * Today's fallback mode printed §9.1's silently wrong values: `sum` with call
    effects 1, and `d` with both. Only `sum` with call effects 0 printed the
    error.
  * On Node's default stack, both modes hit the engine limit first.
* **A GC-heavy recursion at 4–10 million frames.**
  * On wasm it reports `NATIVE LIMIT STACK`, because the 4M-slot shadow array
    fills first.
  * Native returns a value there. It is correct at 4 and 6 million, but wrong at
    8 and 10 million: 27,417,100 and 34,680,725 instead of 24,000,000 and
    30,000,000 (§9.4).
  * This is a resource-limit difference, not a correctness bug on the wasm
    side.

In-band recovery (return an error and keep the Vm) is **unsound**. `nir::parse`
settles each call's `may_error` from the callee's summary and drops the check
when it is false, and that summary does not know about overflow. This is the bug
in §9.1.

**Out of memory.**
* A large but in-range allocation can exhaust the 4 GiB wasm32 address space.
  With `panic=abort` that traps, which the host would otherwise report as
  `{NATIVE BUG}`.
* W2 should route allocator failure through `sys.fatal` as a dedicated
  `{NATIVE LIMIT MEMORY}` record, rather than wait for O3's memory limits.

**Engine stack.**
* **Wasmtime.** `max_wasm_stack` defaults to 512 KiB, and must not exceed
  `async_stack_size` (default 2 MiB) even for synchronous use; otherwise
  `Engine::new` refuses.
* **Measured on Wasmtime:**
  * a minimal hand-written wasm recursion ran 10,000,000 deep (212 ms) with
    768 MiB on a 1 GiB host thread;
  * the prototype's deepest Botlish tests (`sum(50,000)` and a 30,000-frame
    raw-ABI recursion) passed with 512 MiB.

  Botlish frames are larger, so how close this comes to today's 1 GiB worker
  depth is not established.
* **Node.** Its default stack ends a Botlish `sum` recursion between 5,000 and
  10,000 frames, against about 15,700 for a minimal wasm recursion.
* **Browsers** were not measured.
* **Consequence.** Recursion depth is a resource limit, not semantics, but
  deep-recursion tests will differ on JS hosts. That caused the prototype's 2/121
  Node differences.

**Instance lifecycle.**
* **A trap leaves state mid-update:** `__stack_pointer`, `ss_top` and the
  allocator. A probe returning the address of a stack local read 881,067 after a
  trap, against 1,048,571 in a fresh instance (whose `__stack_pointer` starts at
  1,048,576), so the stack pointer is not restored.
* **So a trapped instance is discarded**, and the host never calls into it again.
* **Default to a fresh instance per run.** With Wasmtime `InstancePre`,
  instantiation costs 9–54 µs, and with the uninitialized shadow array a fresh
  run is within about 0.06 ms of a warm one.
* **A `RUNNING` flag** in the runtime turns accidental re-entry into an error
  status instead of corruption.

### 4.6 Linking, packaging and the host crate

**Linking mirrors `codegen/aot.rs`.** The driver's `wasm OUT FILE.nir` works in
four steps:

1. **Write `program.o`.** It imports `env.__linear_memory`, `env.__stack_pointer`
   (plus `env.__indirect_function_table` if `func_addr` remains) and the typed
   helpers.
2. **Generate `startup.rs`.** Reuse `startup()`'s ProgramInfo and constants
   emission (`codegen/aot.rs:20-96`), with three changes:
   * drop the framemap block (`:97-115`);
   * replace `main`/`aot::run` with `runtime::wasm` entry points;
   * declare only `botlish_fn_0` and the generic entries, with their exact wasm
     types (§4.3).
3. **Link with `rustc`:**
   `rustc --edition=2024 --crate-name=botlish_program --target wasm32-unknown-unknown --crate-type cdylib -C opt-level=2 -C link-arg=--fatal-warnings -C link-arg=-zstack-size=<N> -C link-arg=--export=__stack_pointer --extern botlish_native=<wasm32 rlib> -L dependency=<target>/wasm32-unknown-unknown/release/deps -C link-arg=program.o startup.rs`
   * rustup's toolchain already ships `rust-lld`.
   * This needs rustc ≥ 1.96. From that version rustc stops passing
     `--allow-undefined`, so a missing helper is a link error instead of a silent
     import.
4. **Publish atomically.** Use the same private work directory, `RUSTC` override
   and atomic rename as today (`codegen/aot.rs:132-178`), so a failed link keeps
   the previous file.

**Cost.** The link takes a median of 0.26 s per program (0.24–0.41 s over 151
prototype builds). Today's `botlish-native executable` takes 0.38–0.41 s on fib.

**The rejected alternative: two modules.** A prebuilt `runtime.wasm` and a
separately instantiated program module, sharing memory and a growable table.
* **It works.** It was prototyped in Node and Wasmtime, and instantiating the
  pair takes 0.18–0.24 ms.
* **It needs no `rustc` per program**, and the runtime's machine code can be
  cached once.
* **But it adds machinery.** It replaces the generated `startup.rs` with a new
  serialized program descriptor and a decoder. Every host then needs a loader
  with a table-base protocol and an ABI-version handshake.
* **It is the documented follow-up (O4 in §7)** for the case where producing wasm
  without a Rust toolchain, or a much faster test loop, becomes a requirement.

**Crates.**
* No split is needed.
* In `native/Cargo.toml`, move `cranelift-*`, `log` and `wasm-encoder` under
  `[target.'cfg(not(target_family = "wasm"))'.dependencies]`.
* Restrict `libc` to `cfg(all(target_arch = "x86_64", target_os = "linux"))`; the
  runtime uses it only in `runtime/platform/x86_64_linux.rs`.
* The wasm rlib is then built with
  `cargo build --release --lib --target wasm32-unknown-unknown --manifest-path native/Cargo.toml`.
  The canonical native build command and its outputs do not change.

**Host crate: `native/wasm-host`, binary `botlish-wasm`.**
* **Workspace.** It is a workspace member, with `default-members = ["."]`, so
  AGENTS.md's build command still builds exactly what it builds today.
* **Dependency.**
  `wasmtime = { version = "=48.0.5", default-features = false, features = ["cranelift", "runtime", "std"] }`,
  in the same commit as
  `cargo update -p cranelift-codegen -p cranelift-frontend -p cranelift-module -p cranelift-jit -p cranelift-object -p cranelift-native`
  (§1.2).
  * That command moves the whole Cranelift 0.135 family to 0.135.5, and
    `wasmtime-internal-core`/`wasmtime-internal-jit-icache-coherence` to 48.0.5.
  * `--precise 0.135.5` on `cranelift-codegen` alone is refused, because
    `cranelift-jit` 0.135.2 pins `wasmtime-internal-jit-icache-coherence =48.0.2`
    (verified).
  * Add the `async` feature, which pulls in `wasmtime-fiber`, when the host uses
    `func_wrap_async`/`call_async` (§5.4).
* **Verified with 48.0.2 and the blocking feature set:**
  * it resolves to the lockfile's single Cranelift without changing the driver's
    dependency tree;
  * it takes about 2 minutes of clean build;
  * it produces an 11.5 MB stripped binary (15.7 MB unstripped).
* **Keep Wasmtime out of `botlish-native` itself.** Embedding it there took the
  driver from 96 s to 151 s of clean build, and from 7.9 MB to 15.0 MB stripped.
* **CI guard.** `cargo tree -d -e normal --workspace` (or `Cargo.lock`) must show
  no second *version* of any `cranelift-*`, `wasmtime-*` or `object` crate. Plain
  `cargo tree -d` also lists build-and-normal uses of the same version, so it
  cannot be used as is.
* **Upgrades.** Move to Wasmtime 49 only together with Cranelift 0.136, in one
  commit that also re-verifies the prologue assumption documented in
  `framewalk.rs:7-9`.
* **Small runner.** A runtime-only Wasmtime build (no compiler, loading
  precompiled `.cwasm`) is 1.15 MB stripped, if a small deployment runner is ever
  wanted.

### 4.7 The program boundary on wasm (`runtime/wasm.rs`)

It replaces `runtime::aot::run` on wasm32.

**Exports.**
* `memory`.
* `botlish_run(mode, runs) -> status`:
  * **mode 0, harness:** prints the driver's `value`/`error` lines (`main.rs`'s
    protocol);
  * **mode 1, standalone:** `show()`, stderr and exit-code behaviour
    (`runtime/aot.rs:41-66`);
  * **mode 2, bench:** runs the entry `runs` times in one instance, with
    `Vm::reset` between runs, and times each run through `sys.clock`.
    * It prints the driver's `timing COMPILE_US BEST_US RUNS COLLECTIONS` line.
      The host passes `COMPILE_US`, its `Module::new` time, in `sys.config`.
    * With `--alloc summary|sites` it also prints the same `alloc REPORT` line as
      the driver.
    * These are the lines that `native::measure` and `bench/*.tcl` parse.
* `__stack_pointer`, exported only so the host can classify Rust-stack
  exhaustion (§4.5). It is not ABI.
* Nothing else is ABI. A cdylib re-exports all 61 `rt_*`; trim them post-link or
  document them as non-ABI.

**Host services.** These run through the same import trio as intrinsics (§5.3),
as reserved `sys.*` capabilities:
* **`sys.argv`:** raw bytes, then `Vm::set_argv` (`vm.rs:233`).
  * In standalone mode, `botlish-wasm run MODULE ARGS…` passes
    `[MODULE-as-given, ARGS…]`.
  * `--argv-file`, in the driver's hex format, allows zero arguments, a chosen
    argv[0] and invalid UTF-8, so tests can reproduce ARGV.md's `exec -a` and
    `argc == 0` cases.
  * Harness mode keeps the driver's default, `botlish-runner`.
  * Embedders pass whatever vector they want.
* **`sys.config`:** GC stress, GC minimum, shadow size, alloc mode and bench
  parameters. This replaces the environment reads at `heap.rs:63-67`.
* **`sys.stdout`/`sys.stderr`.**
* **`sys.fatal`:** the overflow and out-of-memory records.
* **`sys.panic`:** called from a panic hook, so `NATIVE BUG` keeps its message
  under `panic=abort`.
* **`sys.clock`:** for bench and `--alloc` timing. `Instant::now` traps on this
  target, so the GC timing at `heap.rs:119` (start) and `:203` (`elapsed`) must
  be gated to record `Duration::ZERO` when the host provides no clock.

---

## 5. Rust-based intrinsics without WASI

### 5.1 Two layers, both Rust, no WASI

"Rust-based intrinsics" holds at both ends of the boundary:

1. **In the module.** The Botlish-facing implementation is an ordinary runtime
   helper, `rt_http_request`, in `native/src/runtime/ops.rs`. It is compiled into
   the wasm module like every other `rt_*`, and the native JIT and ELF
   executables call the very same function. It:
   * validates arguments, with the same TYPE messages as the reference backends;
   * encodes the request;
   * decodes the response, enforcing size limits before allocating;
   * builds Strings, Lists and structs under `temp_roots`;
   * raises the declared builtin errors.
2. **In the host.** The transport (sockets, TLS, `fetch`) belongs to the
   embedder. A Rust host implements it with Wasmtime host functions, and a
   browser implements it in JS. The runtime itself stays free of I/O.

No WASI import appears anywhere. The module imports exactly
`botlish_host_v1.{call, read, release}`.

### 5.2 The `argv()` precedent

`argv()` (ARGV.md, commit `aac9162`, 23 files) already built most of the
infrastructure a fallible, effectful, Rust-implemented native needs:
* payload-free builtin errors (`core::native::declareError`,
  `core/native.tcl:357`);
* `-errors` on natives, with legality and handler checks, the escape audit, and
  error sets in `Fn` types;
* a fixed NIR error id `0x40000000 + index` (`native/lower.tcl:7758-7765`,
  `runtime/error.rs:34-40`);
* routing through the Tcl compiler;
* the runtime protocol: validate before allocating, build under `temp_roots`,
  and on failure set `declared_error` plus the UNCAUGHT-ERROR fallback
  (`ops.rs:909-938`).

Effects need no new machinery:
* **No pass removes, reorders or CSEs a call to a native that is not
  context-free.**
  * The call-effects pass never does (CLOSED-CALL-EFFECTS.md:70).
  * Bitwise folding applies only to `iand`/`ior`/`ixor`
    (`native/lower.tcl:6268-6325`).
  * Exact-value folding and module-binding initializers both require
    `-context-free 1` (ARGV.md; `hir/modulebinding.tcl:118-119`).
* **Two table entries suffice.** Listing the op in `op_may_error` and
  `op_may_allocate` (`ops.rs:81-124`) keeps the post-call check and makes the
  call a GC safepoint.

### 5.3 Host interface (runtime side) and import ABI

**Runtime side.**
* `runtime/host.rs` defines
  `trait Host { fn call(&mut self, cap: &str, req: &[u8]) -> Result<Vec<u8>, HostError>; }`.
* Implementations:
  * `NoHost`, the native default;
  * `FixtureHost`, deterministic, used by the driver and the wasm host;
  * `ImportHost`, wasm32 only, which wraps the imports.
* The `Vm` holds the host next to the argv snapshot (the `argv` field,
  `vm.rs:149`).
* The host never re-enters Botlish code, so, as with argv, no collection can
  happen during the call.

**The wasm import ABI** is a two-phase handle protocol in a versioned module
namespace. Appendix C has the full sketch.

```
botlish_host_v1.call(cap_ptr, cap_len, req_ptr, req_len) -> i64   ;; (handle << 32) | len, or < 0
botlish_host_v1.read(handle, dst, len) -> i32
botlish_host_v1.release(handle)
```

Why this shape:
* **The host never writes into memory it was not given a pointer for, and never
  calls back into wasm.** That suits JSPI, which cannot suspend across a JS
  frame.
* **The runtime learns the response length before allocating**, so
  `HttpResponseTooLarge` is raised without allocating.
* **The import set never changes.** A new intrinsic is a new capability string,
  not a new import, and a host answers "unsupported" for capabilities it lacks.
* **It is explicitly versioned.** The major version is in the module name, so an
  incompatible host fails at instantiation, and a version byte leads every
  payload.

Rejected alternatives:
* **An exported allocator that the host calls during the import.** It is
  re-entrant; it is the pattern behind the Component Model's `cabi_realloc`.
* **Per-intrinsic imports.** They widen the ABI, and since `apply_op` keeps every
  helper alive, every module would import every capability.
* **A Component Model world with no WASI** (for example `botlish:host/http`).
  * It was verified to work: a wit-bindgen guest on `wasm32-unknown-unknown`, a
    Wasmtime 49 `bindgen!` host, and jco on Node.
  * But the Component Model is still Phase 1 in the W3C CG, browsers need jco's
    ~124 KiB of glue, and canonical-ABI lifting adds a copy, since values must be
    rebuilt in Botlish's own heap anyway.
  * The byte protocol is kept 1:1 mappable to a future WIT world (O5).

### 5.4 Hosts, and synchronous vs asynchronous calls

Botlish has no async, so from the program's view an intrinsic blocks. **The
module ABI is synchronous.** How a host satisfies a blocking import is the host's
choice:

| Host | Mechanism | Status |
|---|---|---|
| Wasmtime (Rust), blocking | `Linker::func_wrap` with a blocking transport | Verified |
| Wasmtime (Rust), async | `Linker::func_wrap_async` + `call_async` (crate feature `async`). The guest runs on a fiber, and the import still looks synchronous. `Config::async_support` is a deprecated no-op in 48. | Verified, about +2% |
| Native JIT / ELF executable | The `Host` installed by the driver (fixture) or by the generated `startup.rs` (none, or a real client) | Design |
| Node ≥ 24.20 (or ≥ 26), Chrome ≥ 137, Firefox ≥ 153, Safari ≥ 27 | JSPI: `new WebAssembly.Suspending(call)` and `WebAssembly.promising(botlish_run)`. Baseline since 2026-09-14. Node 24.0–24.19 lack it. | Verified on Node 24.21 and 26.10 with a real `fetch` |
| Older browsers | A Worker with synchronous XHR, or `Atomics.wait` | Not tested; loader-only |

**JSPI hazard.**
* Two JSPI calls suspended at once on one instance share Rust's
  `__stack_pointer`, Botlish's `ss_top` and the Vm state. This was reproduced:
  the second run's shadow root was clobbered.
* The fix is the instance-per-run policy of §4.5, plus the `RUNNING` guard,
  which returns a busy status instead of corrupting state.
* Concurrency then means several instances. Four concurrent runs overlapped as
  expected.

**Real transports live only in hosts.**
* An HTTP client crate never goes into the runtime rlib, which every executable
  links. `ureq` 3.4 with default features brings 26 further crates (29 with
  build-only dependencies), including `ring` and `rustls`.
* Instead it goes into an opt-in host feature, or a `botlish-host-std` crate
  linked only by hosts.
* CI never touches the network.

### 5.5 `http_request`: the language contract (v1)

```
http_request(method: str, url: str, headers: List[struct{name: str, value: str}], body: str)
  -> struct{body: str, headers: List[struct{name: str, value: str}], status: int}
  errors HttpUnavailable, HttpInvalidUrl, HttpNetworkError, HttpTimeout,
         HttpResponseTooLarge, HttpInvalidResponseEncoding
```

* **Status codes are values.** A 404 is a result, not an error.
* **Errors are payload-free builtins**, following ARGV.md.
  * They carry an `Http` prefix because builtin names are global and cannot be
    redeclared (`hir/errordecls.tcl:63`).
  * Under argv's scheme, Rust hard-codes each builtin id (`error.rs:38-40`),
    which couples it to Tcl declaration order. v1 keeps that and adds a test of
    the order. The schema-driven follow-up (O1) carries the ids in NIR instead.
* **The body is a strict-UTF-8 `str`**, mirroring `InvalidArgumentEncoding`. A
  binary-body variant waits for a real bytes type, since `List[int]` costs 8
  bytes per byte.
* **New language machinery: a struct result type for natives.**
  * A native's `-result-type` can only name a core kind, and the bare kind
    `struct` makes every field projection an `UNPROVEN-FIELD` error
    (`hir/structs.tcl:255-278`, with `UNPROVEN-FIELD` at `:276-277`).
  * Add `-result-shape {struct-type FIELDS}`:
    * well-formedness is checked in `core::native::ValidShape`
      (`core/native.tcl:297`);
    * the struct type is built in `hir::types::ShapeResult`
      (`hir/types.tcl:1282`, mirroring `element-type` at `:1369`) and in
      `structuralOf` (`:428`).
  * Only anonymous structs are possible, because declared struct names are per
    compilation.
  * Consequence: anonymous struct types cannot be written in annotations
    (STRUCTS.md:124-125). A user function that wraps `http_request` gets its
    result type only by inference, and annotating it `-> struct` would make the
    fields unprojectable.
  * Either accept this for v1, or let a native's result shape name a built-in,
    globally declared struct such as `HttpResponse`. That decision is for the
    maintainer (§8.2).
* **Shape numbers.** Shapes are numbered per program in lowering order. So the
  lowering declares the two anonymous shapes whenever the native is used, and the
  runtime looks them up by field set.
* **Header arguments** are element-checked at run time. Tcl and Rust must raise
  byte-identical TYPE messages, because parity tests compare message text.
* **A malformed host reply** is the uncatchable `{NATIVE HOST PROTOCOL}` on every
  backend. That includes an `int` outside `i64`, because the v1 codec has no
  big-Int encoding.
* **v1 uses one `OpCode` per intrinsic**, exactly like argv:
  * the `nir.rs` enum entry, parse name and arity (4, given explicitly, because
    the default is 2);
  * one row in `clif.rs`'s op table;
  * `apply_op` and `helpers()` entries;
  * a `native/lower.tcl` natives entry.

  The wasm lowering needs **no** change, because it lowers whatever CLIF the
  Translator builds.

### 5.6 Parity with the reference backends

The repository requires identical semantics on `interp`, `compile`,
`cranelift-generic` and `cranelift`. With this work that extends to `wasm` and
`wasm-generic`. Like `cranelift-generic`, `wasm-generic` compiles the program
with `-specialize 0`, which is the guarded, unspecialized baseline.

**A new `core/host.tcl`:**
* `core::host::withTransport`, dynamically scoped like `core::process::withArgv`.
* Transports:
  * `none`, the default, which answers `HttpUnavailable`, so test runs never
    touch the network;
  * `fixture`, which maps exact request bytes to a response or an error name and
    keeps a request log.
* A Tcl encoder for the wire format. A 15-line Tcl encoder was verified
  byte-identical to the Rust codec, including a NUL in the body, an astral
  character and a non-ASCII header name.
* Tcl ships `http` 2.10 but no `tls`, so a live Tcl transport would be
  `http://`-only. The reference is therefore fixture-only by definition.

**Native backends.** They run the driver as a subprocess
(`native/native.tcl:151-187`), so the fixture is passed as data:
* `--host-fixture-file`, next to `--argv-file`;
* the driver and `botlish-wasm` print `host CAP REQUESTHEX` lines before the
  `value`/`error` line.

**`tests/http.test`**, modelled on `tests/argv.test` (65 tests), asserts
identical results **and identical request logs** on all six backends. That is the
concrete check that no call was dropped, duplicated or reordered.

### 5.7 Further intrinsics

**With v1**, each further intrinsic costs:
* a Tcl registration and reference implementation;
* an `OpCode` row and an `rt_*` helper;
* a capability string;
* host implementations and tests.

The wasm ABI and the CLIF→wasm lowering never change.

**The follow-up O1** makes intrinsics schema-driven:
* `core::native::registerHost`;
* a generic `hostcall` NIR instruction and `rt_host_call`;
* NIR header lines carrying builtin error ids and shape numbers.

A new intrinsic is then only Tcl schema plus host code. Two constraints apply:
* the five natives-map lookup sites in `native/lower.tcl` need one
  metadata-driven fallback;
* a single Rust-side declaration cannot be the source of truth, because the Tcl
  backends must run without a cargo build.

---

## 6. Driver, Tcl, test harness and CI

**Driver (`native/src/main.rs`):**
* `wasm OUT FILE.nir` prints `wasm PATH`.
* `wasm-object OUT FILE.nir` mirrors `object`.
* Failures use the `{NATIVE AOT}` family, like `executable`.
* `--host-fixture-file` for `run`/`bench`/`batch`.
* A switch forces the fallback root path, and later `ShadowOnly`, on x86-64 for
  the CI lane (P2/P3).

**`botlish-wasm`:**
* `run`: standalone semantics, with argv per §4.7.
* `harness`: the driver's line protocol, so `native::Outcome`
  (`native/native.tcl:189`) is unchanged.
* `bench`: line-compatible with `botlish-native bench` (§4.7).
* Trap classification (§4.5).
* Forwarding of `BOTLISH_NATIVE_GC_STRESS`/`_GC_MIN` through `sys.config`.

**`native/native.tcl`:**
* `native::wasmHost`: a locator that throws `{NATIVE NOT-BUILT}`, like
  `native::binary` (`:111`).
* `native::wasm HIR PATH`: shares a readiness check factored out of
  `native::executable` (`:222-263`).
* `native::evalWasm HIR`: no readiness check, like `native::evalHir` (`:211`).
* All of these take HIR only. Add them to the entry-point scans in
  `tests/direct-hir-native.test`, which guards against Core-IR entry points.

**`main.tcl`:**
* `-backend wasm|wasm-generic` (`nativeBackends` at `:183`);
* `-emit-wasm`;
* `-host-fixture`.

**`tests/helpers.tcl` and parity lists:**
* Register `wasm` and `wasm-generic` like the Cranelift pair (`:56-57`).
* Extend `outcomeUnderHir` (`:164`) and `GenericBaselineUndefined` (`:136`).
* Add a `wasmBuilt` constraint.
* The four-backend list is hard-coded in 53 test files: 52 as
  `{interp compile cranelift-generic cranelift}`, and one as
  `{interp compile cranelift cranelift-generic}`
  (`tests/native-lockstep-rejected.test:31`). It is
  also hard-coded in `examples/stdlib/corpus.tcl:42`, whose dispatch at `:96-114`
  needs a wasm arm, and in `bench/check-unicode-parity.tcl:100`.
* A central `::parityBackends`, opt-in for wasm, avoids editing all of them per
  backend.

**New tests:**
* **`tests/native-wasm.test`**, mirroring `native-executable.test`:
  * the `\0asm` magic, and exactly the three imports;
  * the module runs after it is moved and its input is deleted;
  * GC stress;
  * error exit codes and stderr;
  * `NATIVE LIMIT STACK` through each trigger;
  * a failed link keeps the old file;
  * non-ready programs are rejected, and compiling never evaluates;
  * standalone argv parity (argv[0], `argc == 0`, invalid UTF-8);
  * a fixture intrinsic.
* **Rust tests:**
  * every committed `.nir` that today's driver accepts lowers and validates
    through the wasm path (§7, W1);
  * the opcode set is closed;
  * an all-helpers link;
  * layout asserts on both widths.

**Coverage.** `tests/native-coverage.tcl` gains `-backend`; it hard-codes
`cranelift` at `:25`.

**CI (`.github/workflows/tests.yml`):**
* Add `rustup target add wasm32-unknown-unknown`, also in
  `.devcontainer/setup.sh`.
* The build action builds the wasm rlib and `botlish-wasm`. The lockfile is
  shared, so the cache key's formula is unchanged; its value changes once, when
  the host member lands.
* A new `wasm` job.
* The push-only `gc-stress` job gains a wasm step and an x86 `ShadowOnly` step.
* Optionally, a non-gating Node ≥ 24.20 JSPI lane.

**CI cost needs care.**
* The corpus and native tests run their programs on hard-coded Cranelift
  backends, whatever `CORE_BACKEND` says. A full `CORE_BACKEND=cranelift` suite
  pass makes about 7,700 driver `run` calls, and only about 330 of them depend on
  the suite backend.
* So a `CORE_BACKEND=wasm` pass moves only those ~330 runs onto wasm, roughly 3
  extra minutes on top of today's coverage job.
* Real parity on wasm needs `wasm`/`wasm-generic` in `::parityBackends`.
  * The ~7,400 hard-coded runs already include both `cranelift` and
    `cranelift-generic`, and `wasm`/`wasm-generic` would mirror them one to one.
  * At about 0.5 s per program (link plus Wasmtime compile), that is up to about
    7,400 × 0.5 s ≈ 1 hour serial per pass.
* That needs caching of the runtime's compiled code (O4), a curated subset, or
  parallel shards before it can gate CI. Most of the per-program cost is
  Wasmtime recompiling the ~240 KB runtime for every program.

**AGENTS.md** gains a "Building the wasm target" section: rustc ≥ 1.96, the
`wasm32-unknown-unknown` target, the host crate, and the pin policy (§1.2).

---

## 7. Plan and effort

* Effort is in person-days (pd), given as ranges.
* ★ marks a change worth landing even if wasm never ships.
* Lanes: **A** codegen, **B** runtime and host, **C** language and harness.
* Every milestone lands on `main` on its own, and wasm stays opt-in until W5.
* Per AGENTS.md, check that the most recent `gc-stress` run on `main` passed
  before starting P1, P2, P3, P5, P6 or W1. They touch roots, stack walking or
  allocation.

| # | Milestone | Depends on | Exit criterion | pd | Lane |
|---|---|---|---|---|---|
| P1★ | 32-bit correctness: compare before casting at `ops.rs:1103/1214/1234/1251/1309`; `MAX_COLLECTION_LENGTH` as a fixed `u64` 2^62−1; `Header` `align(8)` | — | Unit tests at index 2^32; x86 output unchanged | 1–1.5 | B |
| P2★ | Fatal shadow-stack overflow on fallback hosts (§9.1), plus a driver/test switch that forces the fallback root path on x86-64 Linux (CI has no fallback host) | — | With the fallback forced, `sum(10^8)` (tagged result) and a raw-result recursion print `NATIVE LIMIT STACK` under both `call-effects=1` and `=0` (today they give SIGSEGV and `value {int 2}`) | 1.5–2.5 | A |
| P3★ | Explicit `Target`; `ShadowOnly` root mode (no host `cfg!`); an x86 `ShadowOnly` lane under GC stress in CI | P2 | Default `clif`/`object` output byte-identical on the corpus; the lane green under GC stress, with the tests that pin the x86 stack-map shape constrained out of it | 2.5–4 | A |
| P4★ | Split `define` into build and compile | — | Byte-identical objects | 1–1.5 | A |
| P5 | 8-byte-slot layout (`u64` fields), offset asserts on both widths, String header | — | x86 objects identical; the wasm32 lib checks | 2–3 | B |
| P6★ | Cargo target gating; `Heap::configure`; `Instant` gating; host-sized, uninitialized shadow array | — | CI builds the wasm32 lib | 1–2 | B |
| P7★ | Typed helper descriptor with compile-time checks; ABI doc table fix | — | `clif` listings unchanged | 1.5–2.5 | B |
| P8 | `Vm.generic_entries`; drop `func_addr` | — | Suite and GC stress green | 1 | B |
| P9★ | `::parityBackends` (tests, corpus, bench); `native-coverage.tcl -backend` | — | No change in test behaviour | 1–2 | C |
| W1 | CLIF→wasm lowering (closed world, Ramsey structuring, overflow emulation, local limit) and a corpus validation test | P3, P4, P7 | Every committed `.nir` that today's driver accepts lowers and validates. That is 252 of 259 once leading `#` comment lines are stripped; the other 7 are stale audit snapshots (for example, using the removed `cell` instruction), listed as explicit exclusions. | 5–8 | A |
| W2 | `runtime/wasm.rs`: harness, standalone and bench modes; `ImportHost` and `sys.*`; panic hook; fatal records (overflow, out-of-memory); `RUNNING` guard | P5, P6 | A hand-written startup prints exact protocol lines | 3–4 | B |
| W3 | Object writer (relocations), wasm `startup()`, rust-lld link, driver `wasm`/`wasm-object` | W1, W2, P8 | fib runs from the artifact; the all-helpers link passes; a failed link keeps the old file | 4–6 | A |
| W4 | `botlish-wasm` host: modes, trap classification, config passthrough, duplicate-version guard | W2 | Overflow → `NATIVE LIMIT STACK`; GC stress reaches the runtime | 3–5 | B |
| W5 | Tcl, harness and CI integration; parity triage on `wasm`/`wasm-generic` under GC stress | W3, W4, P9 | The CI `wasm` job and the wasm GC-stress step are green; a parity subset (or sharded full parity) is green | 7–12 | C+A |
| W6 | Bench column; Wasmtime and V8 report on the CLIF path; optional multi-value | W5 | Geometric mean ≤ 1.3× the JIT under Wasmtime | 2–5 | A |
| H1 | `http_request` on interp, compile, cranelift and cranelift-generic: `struct-type` shape, `core/host.tcl`, `OpCode`, `Host`/`FixtureHost`, `rt_http_request`, driver flags and log, `tests/http.test`, `HTTP-REQUEST.md` | (P7) | Identical results and request logs on 4 backends | 8–12 | C |
| H2 | `http_request` on wasm: the capability in `ImportHost`, fixture reuse in `botlish-wasm`, an optional live transport behind a host feature | H1, W5 | 6-backend parity, including the request log | 2–4 | B |

**Totals.**

| Part | pd |
|---|---|
| Preparation P1–P9 | 12.5–20 |
| Wasm core W1–W6 | 24–40 |
| Intrinsic H1–H2 | 10–16 |
| **Total** | **46.5–76, about 46–76** |

* For one engineer this is about 9–15 weeks.
* **Critical path:** P2 → P3 → W1 → W3 → W5, then W6 or H2, at 22–37.5 pd.
* **Per lane:**
  * A takes 16–27 pd (P2, P3, P4, W1, W3, W6);
  * B takes 14.5–23 pd (P1, P5–P8, W2, W4, H2);
  * C takes 9–14 pd (P9, H1);
  * W5 (7–12 pd) is shared by C and A;
  * H1 can start on day one.
* **Calendar time:** with three people about 5–7.5 weeks, with two about 6–9
  weeks.
* **Worth landing anyway:** the ★ items total 9.5–16 pd, about a fifth of the
  total.

**Calibration.**
* Both throwaway emitters reached a passing corpus within about 15–30 minutes of
  automated agent time each. Neither showed a translation bug across more than a
  hundred programs, so lowering CLIF or NIR to wasm is mechanical.
* That says little about human effort. The estimates are dominated by what this
  repository expects of a landed feature:
  * byte-identical native output;
  * GC-stress lanes;
  * parity suites across backends;
  * documentation in the style of ARGV.md;
  * the triage of a 4,852-test suite on two new backends.

**Optional follow-ups (27–43 pd).**

| # | Item | pd |
|---|---|---|
| O1 | Schema-driven host intrinsics (`registerHost`, `hostcall`, NIR `host` lines) | 8–12 |
| O2 | Reference JS loader, JSPI, Node ≥ 24.20 CI lane, example page | 3–5 |
| O3 | Embedding productization: library API (sync/async), epoch/fuel/memory limits mapped to `{NATIVE LIMIT …}`, `.cwasm` caching, export trimming, `HOST-ABI.md` | 5–9 |
| O4 | Two-module mode: prebuilt `runtime.wasm` plus a program module; no `rustc` per program; the runtime is compiled once, which is also the main CI-time lever | 8–12 |
| O5 | WIT world and component packaging (no WASI) | 3–5 |

For O3, measured on real Botlish programs: epoch interruption costs +11% to +31%,
and fuel +39% to +101%. Use epochs for timeouts. Neither should be on by default.

**Worth landing regardless of wasm:**
* P1 and P2, which fix real bugs (§9.1–9.2);
* P3, which puts the `ShadowOnly` root path (the wasm root model) under CI on
  x86-64; P2 already adds forced-fallback regression tests;
* P4, P6, P7 and P9;
* the §9.4 fix and the documentation fixes in §9.3.

---

## 8. Risks and decisions for the maintainer

### 8.1 Risks, and what has not been run

| Risk | Retirement |
|---|---|
| **The CLIF path has not been packaged the production way.** CLIF→wasm with `ShadowOnly` ran on V8 and Wasmtime (286/287 under GC stress), but as a complete module in a two-instance setup, with metadata parsed from NIR inside wasm, the padding-type layout, and thread-local switches instead of `Target`. The relocatable object, generated startup and rust-lld link were exercised only by the NIR→wasm prototype, with the unpadded layout. | W3's exit criterion (fib from the CLIF-path artifact), then W5 (the corpus on Wasmtime under GC stress) |
| **`ShadowOnly` has not run on x86** | P3 builds it in the Translator and runs it on x86 under GC stress. On wasm it is validated (§4.4). A negative control on the NIR path showed that GC stress catches missing roots; repeat it on the CLIF path. |
| Overflow unsoundness (§9.1) leaks into the wasm design | P2 lands first, with forced-fallback deep recursions as regression tests: tagged and raw-result, with call effects 0 and 1. On the unforced x86-64 Linux driver these already pass, so they prove nothing there. |
| A future `clif.rs` change emits an opcode the lowering lacks | Closed-world `BackendError::Bug`, plus the corpus test in the wasm job |
| Cranelift IR drift at version bumps (0.133 already removed most `*_imm` instructions) | Exact pin; bump Cranelift and Wasmtime together; the NIR→wasm route remains a proven fallback |
| Layout or ABI drift between targets | Offset asserts on both widths, the typed helper descriptor, `--fatal-warnings`, and an all-helpers link test |
| Performance of `ShadowOnly` frames with slots on x86. On wasm it was measured on four allocating programs: 0.95–1.02× today's fallback (§4.4). | No depth token in v1; a bench column (W6); spill-at-safepoint in reserve |
| Engine-dependent recursion depth | One error line for every trigger; tests assert codes, never depths; host stack configuration documented |
| Very large generated functions | A local-count check against the 50,000 limit; local reuse if it is ever needed |
| Out-of-memory reported as a bug | A `{NATIVE LIMIT MEMORY}` fatal record in W2 |
| CI time | A separate job; wasm parity opt-in or sharded; runtime caching (O4) |
| JSPI concurrency | Instance per run, plus the `RUNNING` guard |
| Wasmtime/Cranelift coupling, and security patches | `=48.0.N` pinned with the matching Cranelift 0.135.N; a duplicate-version guard; follow 48.x patch releases |
| Host ABI evolution | Version in the import module name, plus a payload version byte |

### 8.2 Decisions that need the maintainer

1. **Which hosts are in scope for v1?**
   * The plan assumes a Wasmtime host first, with JS/browser hosts as follow-up
     O2.
   * If browsers are a v1 requirement, O2 moves into the core. Engine recursion
     depth must then be accepted as a resource limit: 5,000–10,000 Botlish frames
     on Node's default stack, and browser limits were not measured.
2. **Is `rustc` at wasm-compile time acceptable?** Today's executable path
   already needs it. If not, O4's two-module mode replaces W3's link step and
   becomes core work of about the same size.
3. **`http_request` details:**
   * the body as `str` (strict UTF-8) or as bytes;
   * the error names and the `Http` prefix;
   * headers as a list of `struct{name, value}`;
   * whether host protocol violations should be catchable;
   * anonymous result structs, or a built-in named `HttpResponse` (§5.5).
4. **CLIF→wasm or NIR→wasm?** The recommendation is CLIF→wasm (§4.2). It is
   proven on semantics, roots and both engines. NIR→wasm is the only one proven
   through the real link step, and it trades Cranelift-IR coupling for a second
   translator.
5. **Should NIR reducibility become a validated invariant?** Today it holds on
   every censused program, but nothing enforces it.

---

## 9. Bugs and documentation drift found on the way

### 9.1 Stack overflow is unsound (crash or silently wrong value) on every host except Linux x86-64

**Mechanism (code-confirmed).**
* **Which hosts.** Every host where `native_stack_overflow_supported()` is false
  (`native/src/runtime/native_stack.rs:31-33`): x86-64 macOS and Windows-native,
  aarch64, and everything else that is not Linux x86-64. On these hosts, calling
  functions reserve shadow-stack space in their prologue:
  * on x86-64 ISAs, a one-slot depth token (`prologue_depth_token`,
    `clif.rs:670`, selected by `depth_reservation` at `roots.rs:722`);
  * on other ISAs, a `RuntimeStack` frame (`prologue_runtime_stack`,
    `clif.rs:699`).
* **On overflow**, both prologues call `rt_stack_overflow` and then *return* 0
  (`return_zeros`, `clif.rs:969`).
* **Why callers miss it.** `summarize_call_effects` (`nir.rs:1030-1094`) derives
  a function's `may_error` only from guards, `raise`/`fail`/`reraise`, fallible
  ops, `construct` and `callvalue`, propagated through direct callees. A function
  whose only possible failure is that prologue overflow is settled
  `may_error = false`.
* **The result.** Its callers, compiled with the default `call-effects=1`, have
  no `check()` after the call, and consume the 0 as a value.
* **Call effects off helps only tagged results.** With `call-effects=0`, every
  call to a tagged-result function is checked (the `sum` row below). But the
  raw-result rule at the end of `summarize_call_effects` still settles a
  raw-result callee from its own summary, so the raw-result `d` is wrong under
  both settings.

**Observed.** Two scratch builds on x86-64 Linux emulated the fallback hosts: the
depth-token path (x86-64 macOS/Windows) and the `RuntimeStack` path (other ISAs).

| Program | `call-effects=1` | `call-effects=0` |
|---|---|---|
| `sum(100000000)` (tagged result, `may_error=false`) | SIGSEGV on both builds (`rt_int_add` dereferenced the 0 sentinel) | `error {NATIVE LIMIT STACK}` |
| raw-result `d(n) = if n == 0: 1 else: (if d(n - 1) == 1: 1 else: 2)` at n = 10^8 | silently wrong `value {int 2}` | silently wrong `value {int 2}` |

* Under Wasmtime, a wasm build with the same semantics printed a silently wrong
  `value {int 207516079890175}` for `sum`. On Node the smaller engine stack
  overflowed first, and Node printed the correct line.
* The unmodified Linux x86-64 driver prints `NATIVE LIMIT STACK` for all of
  them.

**Fix (P2).**
* **What to do.** Make the fallback shadow-stack overflow fatal, with the same
  `OVERFLOW_LINE`.
  * Move that line out of the Linux-only `platform` module.
  * Keep its split between stdout/exit 0 and stderr/exit 1.
* **What it achieves.** It extends to every host the process-exit boundary that
  NATIVE-STACK-OVERFLOW.md defines for x86-64/Linux, and it removes the
  unsoundness.
* **What it does not achieve.** Fallback hosts have no guard handler and no stack
  probes (`codegen/mod.rs:157`). When the native stack runs out before the shadow
  array, the process still aborts with Rust's "has overflowed its stack" message.
  On the depth-token path that happens for any recursion whose frames exceed
  about 256 B with the default 1 GiB stack (for example
  `native/tests/fixtures/large_frame_overflow.nir`).
* **The alternative.** Count the reservation as `may_error` on those hosts. That
  is also sound, and it keeps today's in-band recovery. But it:
  * adds a check after every call to a function that itself contains a Botlish
    call;
  * turns every raw- or short-result function containing a call into a
    (value, status) pair;
  * makes call-effect settlement depend on the host.

  Fatal overflow is simpler, and matches Linux.

### 9.2 Latent 32-bit and alignment issues

* **Five helpers cast a Botlish Int (an index, capacity or count) to `usize`
  before range-checking it:**
  * `ops.rs:1103` `rt_list_get`;
  * `:1214` `rt_mutarray_allocate`;
  * `:1234` `get`;
  * `:1251` `set`;
  * `:1309` `freeze`.

  On any 32-bit target a value of 2^32 or more wraps into range. `rt_substr`
  (`ops.rs:605`) and `rt_mutarray_copy` already compare in `i64` first.
* **`MAX_COLLECTION_LENGTH = SMALL_MAX as usize`** (`value.rs:65`) truncates to
  4,294,967,295 on 32-bit targets. That also changes RANGE messages, which the
  reference prints with 4611686018427387903.
* **Heap-object alignment depends on the allocator.**
  * `NativeObj` has type alignment 4 even on x86-64.
  * On wasm32, `ListObj`, `SetObj`, `StructObj`, `ClosureObj`, `MutArrayObj` and
    `BigIntObj` are 4-aligned too.
  * Pointer tagging needs 8. `#[repr(C, align(8))]` on `Header` fixes all of
    them.
* **A 64-bit store into a 32-bit field.** `clif.rs:939-940`/`:955` store an `I64`
  into the `u32` field `Vm::alloc_site`. Only padding makes that harmless today.

### 9.3 Documentation drift

* **README §20 is stale in several places.**
  * In "Runtime helpers, errors and memory":
    * `README.md:2028-2029` still says "one shadow-stack slot per NIR register",
      and `:2034` says "at least 32 MB". In fact the roots are liveness-colored
      (`roots.rs:1-46`), on x86-64 they are native-frame slots with stack maps
      (NATIVE-STACK-MAPS.md), and the minimum threshold is 1 MiB (`heap.rs:48`).
    * That makes `:2037-2038`'s "Cranelift's stack maps would let a later
      collector drop the shadow stack" outdated too.
    * `:2023-2024`'s "Unbounded recursion ends in `NATIVE LIMIT STACK`, not a
      crash" is false on fallback hosts (§9.1).
  * The "Values" table (`:1901-1907`) still lists the removed cell (`1110`, and
    the heap kind "cell"). It lacks the UnicodeChar tag `100` and the
    MutableArray, ImmutableSet, struct and plan heap kinds.
* **The NIR grammar summary at the top of `native/lower.tcl` (`:39-73`) is
  incomplete.**
  * It omits 18 instructions: `rawint`, `shortlit`, `asciilit`, `char`,
    `staticget`/`staticset`, `structnew`/`structget`,
    `callmulti`/`callenvmulti`, `retmulti`, `faildeclared`, `declarederroreq`,
    `cleardeclarederror`, `pusherrorexit`/`poperrorexit`, `reraise` and
    `construct`.
  * It also omits the `nir 1 call-effects= statics=` line, the `shape`
    declarations, and every function attribute added after the original six.
  * `nir.rs` is the real grammar.
* **The helper ABI table at the top of `ops.rs` (`:15-61`) omits 14 of the 61
  helpers:** `rt_fail_declared`, `rt_declared_error`, `rt_clear_declared_error`,
  `rt_str_region_check`, `rt_str_region_eq`, `rt_str_to_short`, `rt_short_to_str`,
  `rt_str_to_ascii`, `rt_ascii_to_str`, `rt_str_slice_short`, `rt_struct_new`,
  `rt_construct`, `rt_plan_materialize` and `rt_char_codepoint`.

### 9.4 Deep recursion loses GC roots on Linux x86-64

**The cause.**
* The x86-64 frame walker stops after `MAX_FRAMES = 1 << 22` frames
  (`framewalk.rs:80`, loop at `:128`), and silently skips the roots of every outer
  frame.
* The 1 GiB worker allows recursion several times deeper than that.
* So a collection triggered deeper than about 4.19 million frames frees live
  objects.

**Reproduced on the unmodified production driver:**

```botlish
fn f(n, t):
    if n < 1:
        return 0
    s = concat(t, "y")
    if length(s) == 7:
        return 0
    r = f(n - 1, t)
    r + length(concat(s, "z"))
f(8000000, "x")
```

* It prints `value {int 27417100}` instead of 24000000 (f(n) = 3n).
* With GC disabled (`BOTLISH_NATIVE_GC_MIN=100000000000`) it prints 24000000.
* At n = 4,000,000 it is correct.
* An instrumented copy confirmed that the walk hit the cap.

**Fix.** Let the walk end only on the checks it already performs (stack bounds,
alignment, a monotonic `saved_rbp`), or make reaching the cap fatal.

**Unverified related observation.** `.cargo/config.toml` forces frame pointers
only for `x86_64-unknown-linux-gnu` and `x86_64-apple-darwin`. Windows x86-64 also
selects the stack-map path (any x64 ISA does), so GC root discovery there may
depend on frame pointers that are not forced. This was not tested.

---

## Appendix A: measurements

All measurements were taken on 2026-10-03, on the 4-core Linux x86-64 sandbox.

* **Toolchain:** rustc 1.97.0, Node 22.22.0 (V8) and Wasmtime 48.0.2
  (Cranelift 0.135.2).
* **Exceptions:**
  * the Pulley, Wasmtime micro-benchmark, minimal deep-recursion, embedded-driver
    and runtime-only-host measurements used Wasmtime 48.0.5;
  * JSPI used Node 24.21 and 26.10.
* **Statistics:** run times are best of several runs. Build, link and instantiate
  figures are medians or ranges, as stated.

### A.1 Runtime speed, NIR→wasm prototype vs native JIT (µs)

| Program | Native Cranelift JIT | Wasmtime | Node |
|---|---:|---:|---:|
| fib(27) | 1,537 | 1,549 | 1,595 |
| fib(30) | 6,576 | 6,551 | 6,805 |
| uri ×20,000 (strings) | 43,270 | 45,868 | 48,228 |
| csv_parse, 2,000 rows | 6,567 | 5,556 | 5,634 |
| csv_records, 2,000 rows | 10,786 | 10,927 | 11,061 |

* These modules use the `ShadowOnly`-equivalent roots (no depth token), timed as
  `botlish_run` over 10 runs.
* With the depth token, fib(27) took 2,689 µs on Wasmtime and 4,504 µs on Node.
* A separate run gave wasm vs JIT 1,540 vs 1,543 µs (fib(27)), 10,681 vs
  10,698 µs (csv_records) and 46.0 vs 44.0 ms (uri), and a later re-run agreed
  within about 3%.
* The CLIF→wasm lowering with `ShadowOnly` was timed separately (§4.4): best of
  200 calls with a reset between calls, minimum over three rounds. Under
  Wasmtime, fib(27) took 1,573 µs against the JIT's 1,531 µs, and the allocating
  programs ran at 0.94–1.15× the JIT.

### A.2 Sizes and compile times

| Item | Value |
|---|---|
| Runtime alone, wasm32, opt-level 3, stripped | 240,354 B (gzip 71,544) |
| Runtime alone, opt-level z + LTO | 191,233 B (gzip 58,588) |
| Linked program module (median / max) | about 280 KB / 440,182 B (the max carries a 140 KB CSV literal) |
| Generated code per program (median / max) | about 1.0 KB / 20,280 B |
| NIR parse, root plan and wasm emit | median about 0.3 ms (max 4.8 ms) |
| `rustc` + `rust-lld` link | median 0.26 s (0.24–0.41 s, 151 builds); today's ELF `executable` on fib: 0.38–0.41 s |
| Wasmtime `Module::new` on a linked module | ~0.28–0.33 s (almost all of it the runtime) |
| Node `new WebAssembly.Module` | ~1 ms (lazy tiering) |
| Wasmtime `InstancePre::instantiate` | 9–54 µs |
| First run in a fresh instance, fib(27) | 16.1 ms with the zero-filled 32 MiB shadow array; 1.6 ms without zero-fill |
| `botlish-wasm` host (Wasmtime with cranelift, runtime, std) | ~2 min clean build; 11.5 MB stripped (15.7 MB unstripped) |
| Wasmtime embedded in `botlish-native` (rejected) | clean build 96 → 151 s; stripped 7.9 → 15.0 MB; 55 → 118 crates |

### A.3 Field offsets in the objects generated code reads (x86-64 / wasm32, code as it is today)

With the §4.3 layout, including the `StructObj.shape` pad, every row reads the
same on both targets.

| Constant | x86-64 | wasm32 | Note |
|---|---:|---:|---|
| `VM_SS_TOP_OFFSET` | 0 | 0 | |
| `VM_SS_LIMIT_OFFSET` | 8 | 4 | |
| `VM_CONSTS_OFFSET` | 16 | 8 | |
| `VM_ALLOC_SITE_OFFSET` | 24 | 12 | |
| `VM_NATIVE_ROOTS_PTR_OFFSET` | 32 | 16 | |
| `VM_NATIVE_ROOTS_LEN_OFFSET` | 40 | 24 | |
| `VM_STATICS_OFFSET` | 48 | 32 | |
| `LIST_LEN_OFFSET` | 8 | 8 | |
| `LIST_PTR_OFFSET` | 16 | 12 | |
| `STRUCT_PTR_OFFSET` | 24 | 16 | |
| `CLOSURE_CAPS_OFFSET` | 32 | 24 | |
| `STR_CHARS_OFFSET` | 8 | 8 | |
| `STR_BYTE_LEN_OFFSET` | 16 | 12 | read only by the runtime; listed because §4.3 widens `byte_len` too |
| `STR_ASCII_OFFSET` | 24 | 16 | |
| `STR_TEXT_OFFSET` | 25 | 25 (literal) | the text would start at 17 on wasm32, so the `strobj.rs:108` assert fails and the crate does not compile |

### A.4 Other measurements

* **Pulley.** Same loop (sum of 1..10^8):
  * Cranelift-compiled wasm in Wasmtime: 71–75 ms;
  * the Pulley interpreter on a native host: 587 ms;
  * the Pulley interpreter compiled to wasm32: 822–827 ms;
  * Wasmtime with `target("pulley64")`: about 1.04 s.
* **Wasmtime limits.**
  * Hand-written wasm micro-benchmarks: recursive fib(30) costs about 2× with
    fuel and about +2% with epochs; a tight sum loop costs about +10% with fuel
    and about +50% with epochs.
  * Botlish modules (fib27 / csv_records / uri, best of 15): epochs +11% / +31% /
    +23%, fuel +101% / +50% / +39%.
* **Engine stack depth on Node 22's default stack.**
  * A Botlish `sum` recursion passes at 5,000 frames and fails at 10,000.
  * A C or Rust recursion with linear-memory frames reaches 10,467–11,418.
  * A minimal wasm recursion reaches 15,723.
* **On Wasmtime**, a minimal recursion ran 10,000,000 deep with `max_wasm_stack`
  set to 768 MiB.

---

## Appendix B: wasm feature and engine support (as of 2026-10-03)

**Wasm 3.0** was completed on 2025-09-17. It adds:
* tail calls;
* exception handling with `exnref`;
* GC;
* typed function references;
* memory64;
* multiple memories;
* extended constants;
* relaxed SIMD;
* a deterministic profile;
* custom annotation syntax;
* JS string builtins, in the JS API.

**The design above needs none of them:**
* self tail calls are already loops (`clif.rs` header);
* errors are a 0 result plus a pending VM error;
* the heap is Botlish's own.

It needs only what rustc 1.97 enables by default for `wasm32-unknown-unknown`:
`bulk-memory`, `multivalue`, `mutable-globals`, `nontrapping-fptoint`,
`reference-types` and `sign-ext`. Every current engine supports that set,
including Safari 15 and later.

| Feature | Chrome | Firefox | Safari | Node | Wasmtime 48 |
|---|---|---|---|---|---|
| The Wasm 2.0 set above | ≤ 96 | ≤ 79 | ≤ 15 | 17.2 | yes |
| Tail calls | 112 | 121 | 18.2 | 20 | default on |
| GC | 119 | 120 | 18.2 | 22 | with `gc` crate feature |
| Exceptions (`exnref`) | 137 | 131 | 18.4 | 24.15 (also 22.22; not 24.0) | with `gc` crate feature |
| memory64 | 133 | 134 | flag only | 24 | default on |
| JSPI (not part of 3.0; Phase 5) | 137 | 153 | 27 | 24.20 (26.0 per features.json) | n/a |

**Rust-side facts that matter:**
* `wasm32-unknown-unknown` is tier 2 and `panic=abort`, with a stack-first layout
  and a 1 MiB default stack.
* `wasm64-unknown-unknown` is tier 3.
* Since Rust 1.96, rustc no longer passes `--allow-undefined`, so every import
  needs an explicit `#[link(wasm_import_module = …)]`.
* `std` compiles. On this target:
  * `println!` goes nowhere;
  * `std::env` and `std::fs` return errors;
  * `thread::spawn`, `Instant::now` and panics trap.

---

## Appendix C: host ABI v1 (sketch)

**Imports, module `botlish_host_v1`** (pointers and lengths are `i32`):

| Import | Type | Meaning |
|---|---|---|
| `call` | `(cap_ptr, cap_len, req_ptr, req_len) -> i64` | `≥ 0`: `(handle << 32) \| len` of a reply payload. `-1`: capability unsupported. `-2`: host failure. |
| `read` | `(handle, dst, len) -> i32` | Copies the reply; returns the bytes copied |
| `release` | `(handle)` | Frees the reply; mandatory, also after errors |

**Reply payload.**
* It starts with a version byte, then a tag.
* Tag `0` means ok, followed by the result encoding.
* Tag `1` means a declared error, followed by its UTF-8 name. The name must be
  one of the intrinsic's `-errors`; anything else is `{NATIVE HOST PROTOCOL}`.

**Codec v1** (little-endian):
* `str` = u32 length + UTF-8;
* `int` = i64 (a value outside i64 is a protocol error in v1);
* `bool` = u8;
* `list` = u32 count + elements;
* `struct` = fields in sorted name order, the canonical order of anonymous
  shapes.

**Exports:**
* `memory`;
* `botlish_run(mode: i32, runs: i32) -> i32`: mode 0 is harness, 1 standalone,
  2 bench; the result is the exit status;
* `__stack_pointer`, for trap classification only.

**Reserved capabilities.** `sys.argv`, `sys.config`, `sys.stdout`, `sys.stderr`,
`sys.fatal`, `sys.panic`, `sys.clock`.

**Host error mapping.**

| Condition | Reported as |
|---|---|
| Fatal record received | that line (`{NATIVE LIMIT STACK}`, `{NATIVE LIMIT MEMORY}`) |
| Wasmtime `Trap::StackOverflow`; V8/JSC `RangeError`; SpiderMonkey `InternalError`; or an out-of-bounds trap with `__stack_pointer` wrapped or near 0 | `{NATIVE LIMIT STACK}` |
| Memory limiter refused growth | `{NATIVE LIMIT MEMORY}` (O3) |
| Epoch deadline / fuel exhausted | `{NATIVE LIMIT TIME}` / `{NATIVE LIMIT FUEL}` (O3) |
| Any other trap | `{NATIVE BUG}`, plus the message from `sys.panic`, if any |

**A Rust embedder, as it would look.**

```rust
let mut linker = wasmtime::Linker::new(&engine);
linker.func_wrap("botlish_host_v1", "call",
    |mut caller: wasmtime::Caller<'_, HostState>, cap_ptr: i32, cap_len: i32, req_ptr: i32, req_len: i32| -> i64 {
        let mem = caller.get_export("memory").unwrap().into_memory().unwrap();
        let (cap, req) = read_two(&mem, &caller, cap_ptr, cap_len, req_ptr, req_len);
        caller.data_mut().dispatch(&cap, &req)     // "http.request" -> Rust HTTP client, "sys.argv" -> …
    })?;
// read / release likewise; func_wrap_async + call_async (crate feature "async") for an async transport.
```

---

## Appendix D: how the evidence was produced

None of this is committed. It is described so that it can be redone.

* **Runtime port.**
  * Copied `native/src/{lib.rs,nir.rs,runtime/}` into a scratch crate whose only
    dependencies were num-bigint, num-traits and unicode-general-category.
  * Built it for `wasm32-unknown-unknown` with one edit (`STR_HEADER_SIZE`).
  * Read the module's exports, imports and signatures under Node.
* **Layout.** `size_of`/`offset_of!` probes compiled for both targets, and
  cross-checked independently.
* **Reducibility.**
  * Two independent re-implementations of `roots.rs`'s `Cfg::build`, including
    the error-span catch edges. Each checks that every retreating DFS edge
    targets a dominator of its source.
  * They ran over the 259 committed `.nir` files (4,024 functions, common to
    both), plus 35 and 112 freshly lowered programs respectively.
  * Separately, the CLIF→wasm prototype's stackifier checked all 8,370 CLIF
    functions with Cranelift's dominator tree.
* **CLIF→wasm.**
  * A 611-line function lowering, hooked in just before `define_function` (which
    still compiled each function for x86-64). The Translator was forced onto
    `RootStorage::RuntimeStack`.
  * Modules were validated with `wasmparser`, loaded as a separate instance next
    to the runtime (a two-instance Node loader), and run on the real runtime
    against `botlish-native run` output, with and without GC stress.
  * Program metadata came from parsing the NIR inside wasm.
  * The V8 depth-token ablation used the same lowering.
  * A follow-up added the `ShadowOnly` root mode to the copied `roots.rs`/`clif.rs`
    (`RootStorage::None`; no minimum slot; no native-frame publication; fatal
    overflow). Its output in the fallback mode stayed byte-identical to the
    prototype's.
  * The same 287 programs then ran on Node and on a Wasmtime 48.0.2 host. The
    host reproduced the two-instance loader with `Table::grow`, a const
    `__table_base` global and a `Linker`, and loaded a precompiled runtime
    `.cwasm`. Each ran with and without GC stress, against `botlish-native run`
    output.
  * Timings: best of 200 calls per process, three interleaved rounds.
* **NIR→wasm and the real artifact.**
  * A 1,844-line emitter with a Ramsey stackifier and a relocatable-object writer
    (wasm-encoder's linking section plus a hand-written `reloc.CODE`), plus a
    242-line generated-`startup.rs` driver.
  * Linked by `rustc --target wasm32-unknown-unknown --crate-type cdylib` with
    `--fatal-warnings`.
  * Run under a Wasmtime 48.0.2 host and under Node, with GC stress off and on,
    on 121 programs:
    * the corpus;
    * every repository `.bot` that compiles (97 of 106);
    * audit probes, targeted edge cases and benchmarks.
  * A negative control dropped the root stores.
* **Intrinsics.**
  * A `Host` trait prototype with fixture and import implementations, and a
    versioned codec with no-panic tests.
  * A Tcl encoder checked byte-for-byte against the Rust one.
  * Hosts: Wasmtime sync (`func_wrap`) and async (`func_wrap_async` on a tokio
    current-thread runtime); Node sync; Node 24/26 with JSPI and a real `fetch()`
    against a local server.
  * A custom Component Model world with no WASI, run through wit-bindgen, a
    Wasmtime 49 `bindgen!` host and jco.
* **Bugs (§9.1, §9.4).**
  * Scratch builds emulating the two fallback paths, running
    `sum(n) = n + sum(n - 1)` and the raw-result `d(n)` at n = 10^8, under
    `call-effects=1` and `=0`.
  * The unmodified release driver on the deep-recursion GC program, with and
    without GC.
* **Engines and versions.**
  * crates.io for Wasmtime, Cranelift and wasm-encoder versions, sources and
    dependency requirements; `cargo tree -d -e normal` for duplicate detection.
  * Node 22.22, 24.0–24.21 and 26.10 for feature probes.
  * WebAssembly/website `features.json`, MDN browser-compat-data, web-features
    and the Node 24 changelog for browser and Node support.
  * Wasmtime and rust-lang/rust release notes and platform docs.
