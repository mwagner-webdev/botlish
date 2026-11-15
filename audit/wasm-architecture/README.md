# audit/wasm-architecture

The experiments of
[WASM-TARGET-AND-COROUTINE-ARCHITECTURE-MILESTONE-1.md](../../docs/WASM-TARGET-AND-COROUTINE-ARCHITECTURE-MILESTONE-1.md):
their sources, the two patches they apply to **scratch copies** of
`native/` (never to this checkout), the scripts that rerun each one, and
what the runs printed (`results/`).

Nothing here is production code, and nothing here is run by the test suite
or by CI. Every script writes only below the scratch directory it is given.

## Layout

| Path | What |
|---|---|
| `patches/e1-runtime-wasm32.patch` | E1: the runtime target-gated for wasm32 plus the five throwaway patches (a platform stub, an argv branch, String and byte-storage header constants per pointer width, an allocator shim for `wasm32-unknown-unknown`) |
| `patches/resumable-and-wasm-prototype.patch` | E1's patch plus the prototypes: the resumable lowering (`codegen/resumable.rs`), resume frames (`runtime/coroutine.rs`, `heap.rs`, `vm.rs`, `value.rs`), 15 frame ops (`nir.rs`, `ops.rs`, `clif.rs`), ShadowOnly-style root storage (`roots.rs`), the NIR→wasm emitter (`codegen/wasmemit.rs`) and the driver's `wasm-asm` command (`main.rs`) |
| `corpus/` | the coroutine corpus (cases 1–8; case 5 is a copy of `tests/resources/coro.bot` and `handle.bot`), `e2-fib.bot`, `leaf-reentry.bot` (the fallback plan's leaf publication), `w32-index.bot` (a 32-bit index) |
| `asyncify/` | experiment C-A: `co.rs`, a minimal runtime with per-coroutine Asyncify buffers, linear stacks and root segments, and the corpus hand-written for it; `sp.s`, `__stack_pointer` access |
| `wasi/` | W1 `wait.rs` (waiting in the host), W2 `traps.rs` (how a run ends), W3 `httpc/` (a `wasi:http` handler), `adapter/` (dumps Wasmtime 50.0.1's WASI preview1 adapters) |
| `stack-switching/gen.wat` | two generators on the core stack-switching proposal |
| `tools/` | the scripts below, `measure.py` (wall, CPU, peak memory of a command) and `allocsum.py` (a driver's `--alloc summary`, condensed) |
| `results/` | what the runs printed |

## Prerequisites

* Tcl 9.0.1 and `LANG=C.utf8` (AGENTS.md, "Installing Tcl 9").
* The repository's pinned Rust (`bash tools/rust-toolchain.sh install`) and
  the stock driver: `cargo build --release --manifest-path native/Cargo.toml`.
* `llvm-mc` (LLVM 18 was used; it is the prototype emitter's object writer),
  `patch`, `curl`, Node and npm (Binaryen's JavaScript build), Python 3,
  and network access to crates.io and npm.

## Running everything

Each script takes the scratch directory first. In order:

```bash
bash audit/wasm-architecture/tools/setup-toolchain.sh SCRATCH
```

Wasmtime 50.0.1 and wasm-tools 1.263.0 from crates.io, Binaryen 132 from
npm, the WASI preview1 adapter, the wasm32 Rust targets.

```bash
bash audit/wasm-architecture/tools/make-prototype.sh SCRATCH
```

E1 (the runtime for `wasm32-unknown-unknown`, `wasm32-wasip1` and
`wasm32-wasip2`, before and after the five patches), then `SCRATCH/proto`:
the prototype built as a `fallback-roots` driver (no stack switching, so it
applies the resumable lowering) and as the wasm32-wasip1 and wasip2 runtime
the emitted objects link. About five minutes.

```bash
bash audit/wasm-architecture/tools/run-corpus.sh SCRATCH
```

Every corpus program on the reference interpreter, the stock native backend,
the prototype driver (GC stress off and on) and as wasm under Wasmtime (GC
stress off and on), each compared with the interpreter. Cases 4, 6a and 8
take minutes on the interpreter.

```bash
bash audit/wasm-architecture/tools/golden-sweep.sh SCRATCH
```

All golden suites on the native backend through the prototype driver
(`BOTLISH_NATIVE_BIN`); name suites after `SCRATCH` to run some, and set
`BOTLISH_NATIVE_GC_STRESS=1` to run them under GC stress. The whole sweep took
about two hours here.

```bash
bash audit/wasm-architecture/tools/asyncify.sh SCRATCH
```

The Asyncify prototype: three instrumentation configurations, sizes, every
case with and without GC stress, the memory of 10,000 suspended coroutines,
and the unguarded coroutine stack (case 8) against the main stack (case 9).

```bash
bash audit/wasm-architecture/tools/wasi.sh SCRATCH
```

W1–W4 and core stack switching (needs `run-corpus.sh`'s modules; uses port
8099 on 127.0.0.1).

```bash
bash audit/wasm-architecture/tools/mutants.sh SCRATCH
```

Mutants M1 (a frame's tagged slots untraced) and M2 (a live register not
saved) of the report's invariants I3 and I4, each run against the programs
that must kill it, under GC stress.

```bash
bash audit/wasm-architecture/tools/fallback-leaf.sh SCRATCH
```

Stock `main` built with `--features fallback-roots` against the stack-map
build and the prototype, on `corpus/leaf-reentry.bot`.

Single steps: `tools/emit-nir.sh SCRATCH FILE.bot OUT.nir` (a program's NIR)
and `tools/bot2wasm.sh SCRATCH FILE.nir OUTDIR [wasm32-wasip1|wasm32-wasip2]`
(one module).

## Results

| File | From |
|---|---|
| `e1-runtime-wasm32.txt` | `make-prototype.sh` |
| `corpus.txt` | `run-corpus.sh` |
| `golden-sweep-resumable.txt`, `golden-gcstress-resumable.txt` | `golden-sweep.sh` (without and with GC stress) |
| `asyncify.txt` | `asyncify.sh` |
| `wasi.txt` | `wasi.sh` |
| `mutants.txt` | `mutants.sh` |
| `fallback-leaf.txt` | `fallback-leaf.sh` |
| `measurements-native.txt` | cases 6 and 8 natively, through `tools/allocsum.py` |

The report's section 11 says what each establishes and what it does not.
