# audit/typed-coroutine-sources

The material of EMISSION-TYPED-COROUTINE-SOURCE-CENSUS-MILESTONE-1.md
(`../../docs/`): how the compiler types what a coroutine yields and what it
returns, and what consumers do about it. No production file is changed by
anything here.

## Contents

| path | what |
|---|---|
| `cases/*.bot` | 67 standalone programs, each stating in its leading comments what it probes (`# case:`), the census's class (`# class:`), the compiler observation it expects (`# expect:`) and, when it runs, the value every backend must produce (`# value:`) |
| `cases/support/handle.bot` | the resource the ownership case imports (`support::handle`), a copy of `tests/resources/handle.bot`'s core |
| `tools/census.tcl` | compiles every case (and, analyzed only, `examples/dfa/csv/export.bot`, `examples/dfa/csv/sinks.bot`, `examples/dfa/json/sinks.bot`), records per coroutine construction what the compiler decided, runs each runnable case on five backends, and checks both against the case's expectations |
| `tools/inventory.tcl` | every `coroutine {...} = ROOT(...)` site of `stdlib/`, `packages/`, `examples/`, `bench/`, `integrations/` and `tests/golden/`, with textual facts about its consumer |
| `tools/bench.tcl` | the native cost of narrowing a received symbol, and of a payload-enum value per segment |
| `results/census.txt`, `results/matrix.tsv` | the census's output (one row per construction) |
| `results/sites.tsv` | the inventory |
| `results/bench.md` | the benchmark |

## The classes and observations

`# class:` is the census's taxonomy (the report's section 15):

* `intended` -- compiles and runs as intended;
* `narrowing` -- compiles, but a consumer must narrow a received value
  (or the program shows the narrowing being required: a rejected direct use);
* `rejected-correct` -- rejected, rightly;
* `rejected-precision` -- rejected because of a precision limitation of
  coroutine typing;
* `unsupported` -- needs a language feature that does not exist (reading a
  payload enum's case).

`# expect:` is what `census.tcl` observes from the compiler's records,
never from a run:

* `precise` -- for every construction the outward type O equals the
  yields' join Y, and the first value's range is not wider than the yields'
  facts;
* `widened` -- for some construction Y is a strict subtype of O (the yields
  send values of a narrower type than every segment returns);
* `facts-widened` -- O equals Y, the yields' values are bounded
  (hir::range), and the first value's range is unbounded: range facts
  stopped at the coroutine boundary;
* `no-yield`, `none` -- no yield, no construction;
* `rejected CODE...` -- exactly these error kinds.

The construction facts each row records: `root`, `declared` (the root's
declared result), `R` (its result type), `Y` (the join of the static types of
every reachable yield the coroutine can reach: `hir::coroutines::YieldTypes`),
`O` (the handle's outward type: `hir::types::CoroutineOutward` of the
construction's type), `Yrange` (the join of hir::range's facts of every
yield's value, over every analyzed instance of the yielding function -- facts
of the instances the program creates, so caller-dependent), `first` and
`firstRange` (the static type and range of `coroutine#start`).

## Reproducing

```sh
export LANG=C.utf8 LC_ALL=C.utf8
cargo build --release --manifest-path native/Cargo.toml
tclsh9.0 audit/typed-coroutine-sources/tools/census.tcl
tclsh9.0 audit/typed-coroutine-sources/tools/inventory.tcl
tclsh9.0 audit/typed-coroutine-sources/tools/bench.tcl
```

The census takes about 30 seconds on a 4-core container (2026-11-13) and
exits 1 on a mismatch with a case's expectations or a backend disagreement;
`-cases GLOB` narrows it, `-external 0` leaves the repository's consumers
out, `-out DIR` writes elsewhere. `BOTLISH_NATIVE_GC_STRESS=1` runs the native
backends under GC stress (recorded in the report). The benchmark's defaults
are `-n 200000 -runs 7`; its times are this container's.

When the compiler's coroutine typing changes (the report's recommended
milestone), the cases whose expectation changes are the evidence: update
their `# expect:` lines in the same change, never their programs.
