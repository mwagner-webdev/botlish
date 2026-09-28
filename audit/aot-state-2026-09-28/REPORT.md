# AOT implementation audit — 2026-09-28

Tested checkout `3da80a4ad1cbd434cff0fa0cfc771c3bdd4827b9` on branch `aot-linux-compile` with Ubuntu 24.04.3 WSL2, Tcl 9.0.1, and `LANG=C.utf8 LC_ALL=C.utf8`.

All 58 `.bot` files present in the checkout were enumerated recursively, including audit probes, module fixtures, and libraries. Each was run in a fresh Tcl process with each flag separately (116 baseline invocations):

```sh
tclsh9.0 main.tcl -aot FILE.bot
tclsh9.0 main.tcl -aot-spec FILE.bot
```

The default runtime backend was `interp`; inherited `CORE_BACKEND` and `BOTLISH_*` overrides were cleared. All invocations completed within the 180-second per-process timeout. Both flags produced identical program values or errors for each input. The Windows Git working tree was clean before and after the audit. Linux Git reported 19 modified files before execution despite the clean Windows status; its raw status is retained in `environment.json`. No tracked source was changed. The report, captured outputs, and reproduction scripts are preserved in `audit/aot-state-2026-09-28/`.

## Execution outcomes

| Outcome | `-aot` | `-aot-spec` |
|---|---:|---:|
| Analysis and default interpreter execution succeed | 47 | 47 |
| Analysis succeeds; interpreter hits `TCL LIMIT STACK` | 7 | 7 |
| Frontend rejects input before analysis | 4 | 4 |
| Analyzer crashes or timeouts | 0 | 0 |

All seven stack-limit cases succeeded when rerun with **both flags** and `-backend compile`: `steady-ascii.bot`, `steady-ascii-param.bot`, `steady-ascii-capture.bot`, `bench/loop-count.bot`, `bench/refined-checks.bot`, `bench/sum-refined.bot`, and `bench/uri-steady.bot`. The AOT reports had already completed before the interpreter reached its recursion limit.

The four frontend rejections have distinct explanations:

| Input | Reason | Follow-up |
|---|---|---|
| `audit/comprehensive-generated-code/probes/from-int-invalid.bot` | Intentional `byte::from_int(999)` rejection: `CORE SEMANTIC KNOWN-ERROR`, `AboveRange` | Expected negative probe |
| `examples/surface/10-duplicate-binding.bot` | Intentional duplicate binding: `CORE SEMANTIC DUPLICATE` | Expected negative example |
| `lib/ascii.bot` | `Byte` type is unregistered when launched alone | Loading `lib/byte.bot` first makes both flags succeed; zero guards |
| `audit/post-native-stack/module-cases/main.bot` | `plain` module is outside the default `lib/` directory | Setting `core::libraryDir` to the fixture directory makes both flags succeed; result `[2, 8, 20]`, guards 3 → 0 |

`lib/ascii.bot` documents its dependency on another compilation unit loading `byte`; existing ASCII consumers in the baseline run also succeed. The context reruns use `context.tcl` without editing any `.bot` source. With these setups and the compiler reruns, all **56 non-negative inputs** produce both reports and execute successfully.

## Readiness reported by the analysis

The following comparison covers the 54 files that produce reports without extra setup. A file is classified by the worst local status among its reported regions/instances, including retained generic entries. Semantic headings embedded in `-aot-spec` output are excluded from the instance counts.

| Classification | `-aot` semantic regions | `-aot-spec` used instances |
|---|---:|---:|
| Files with only closed regions/instances | 8 | 39 |
| Files with guards but no open dispatch | 36 | 11 |
| Files containing open dispatch | 10 | 4 |
| Closed regions/instances | 225 | 327 |
| Guarded regions/instances | 278 | 48 |
| Open regions/instances | 24 | 4 |
| Representation blockers / kind guards | 534 | 81 |

The specialized reports contain 268 specialized function instances, 57 generic function instances, and 54 program instances (379 total). The two dependency-context reruns add two fully closed files, giving **41 closed, 11 guarded, 4 open** among the 56 non-negative inputs.

`closed` means operations and required operand kinds are statically known. `guarded` requires runtime kind checks. `open` requires dynamic semantic dispatch. These are analysis categories; a guarded or open program can still execute correctly through the existing runtime.

The 534 → 81 reduction is 84.8% in reported static guard sites. The semantic report includes all functions; the specialized report includes used instances, so this reduction combines specialization with reachability pruning. Imported modules recur across per-file reports. These counts are neither unique source-site counts nor runtime check frequencies.

Fibonacci, loop-count, URI escaping, ordinary CSV, geometric CSV, matrix multiplication, string replacement, and string reversal are fully closed in the specialized reports. `bench/test-selection.bot` has no remaining dynamic-call blocker, although five kind guards remain.

## Remaining analysis gaps

| Input | Semantic guards | Specialized guards |
|---|---:|---:|
| `examples/stdlib/csv_records.bot` | 84 | 29 |
| `examples/stdlib/hashtable.bot` | 63 | 25 |
| `bench/test-selection.bot` | 12 | 5 |
| `bench/source-checks.bot` | 11 | 4 |
| `lib/web.bot` | 24 | 4 |
| `bench/lex-strategy.bot` | 22 | 3 |
| `examples/surface/09-mutual-recursion.bot` | 2 | 2 |
| `lib/list.bot` | 8 | 2 |
| `audit/post-native-stack/module-cases/managed.bot` | 1 | 1 |
| `audit/post-native-stack/module-cases/plain.bot` | 1 | 1 |
| `audit/post-native-stack/module-cases/scalar.bot` | 1 | 1 |
| `bench/sum-refined.bot` | 3 | 1 |
| `examples/stdlib/csv_chunked.bot` | 29 | 1 |
| `examples/surface/03-closure.bot` | 2 | 1 |
| `lib/mathish.bot` | 1 | 1 |

`csv_records.bot` and `hashtable.bot` account for 54 of 81 remaining guards (two thirds). Across all reports, the residual guard causes are 47 unknown call-result kinds, 23 unknown parameter kinds, and 11 unknown aggregate-element kinds. The two largest cases repeatedly lose Int or mutable-array kinds through hashtable accessors and list-shaped records.

Four used instances still contain a `DynamicCall` blocker:

| Input | Instance | Dynamic call location |
|---|---|---|
| `bench/lex-strategy.bot` | `classify<str, bool>` | line 57:9; classifier selected between Native and Block |
| `bench/source-checks.bot` | `classify_leading<generic>` | line 56:9; callable read from the checks list |
| `lib/list.bot` | `find<generic>` | line 79:12; unconstrained predicate |
| `lib/web.bot` | `scan_while<generic>` | line 128:16; unconstrained predicate |

The library entries are open when analyzed as standalone inputs with generic callable parameters. Concrete callers can close such dispatch: e.g. `bench/uri-steady.bot` is fully closed. A standalone module run does not supply call-site facts for every exported API, and its specialized report only includes instances retained by that run.

Closed code still reports runtime requirements: arbitrary-precision integers, allocations, range checks, structural equality, captured environments, and related helpers. Closedness does not imply a runtime-free binary.

## State of executable AOT

The readiness and specialization analyses work across this corpus, subject to the guards and dynamic calls above. The requested flags print diagnostics and then evaluate through the chosen backend; neither flag emits an object or executable (`main.tcl:84` and `main.tcl:102`). This audit executed the interpreter and Tcl compiler paths, and did not test native code generation, linking, or standalone native execution.

Source inspection shows the native object path is still explicitly an AOT smoke test:

- `native/src/codegen/mod.rs:359`: `emit_object` exports generated functions, leaves runtime helpers as undefined imports, and returns the constant pool separately.
- `native/src/main.rs:168`: the object command writes the object bytes and reports the pool entry count; it does not package a constant-table initializer.
- `native/src/codegen/mod.rs:8`: a runnable executable still needs the runtime as a static library and a constant-table initializer.
- `native/src/runtime/framemap.rs:21`: GC frame-map construction and registration currently belong to JIT compilation; the object path does not install that metadata.

The next executable-AOT work is therefore runtime packaging and linking, constant initialization and startup, and GC metadata support for linked code. Separately, the largest analysis opportunities are preserving aggregate/call-result kinds and resolving callable values across control-flow joins and collections.

## Complete per-file baseline

`C/G/O` counts closed/guarded/open regions for `-aot`, and used instances for `-aot-spec`. `stack → compile OK` records the successful follow-up for both modes. The two context successes are supplemental; the baseline columns preserve the original outcome.

| File | `-aot` C/G/O | `-aot-spec` C/G/O | Guards before → after | Execution |
|---|---:|---:|---:|---|
| `audit/comprehensive-generated-code/bugs/handle-range-bigint.bot` | [4/6/0](logs/audit/comprehensive-generated-code/bugs/handle-range-bigint.bot.aot.txt) | [2/0/0](logs/audit/comprehensive-generated-code/bugs/handle-range-bigint.bot.aot-spec.txt) | 6 → 0 | OK |
| `audit/comprehensive-generated-code/bugs/handle-range-entry.bot` | [2/0/0](logs/audit/comprehensive-generated-code/bugs/handle-range-entry.bot.aot.txt) | [2/0/0](logs/audit/comprehensive-generated-code/bugs/handle-range-entry.bot.aot-spec.txt) | 0 → 0 | OK |
| `audit/comprehensive-generated-code/bugs/handle-return-result.bot` | [4/0/0](logs/audit/comprehensive-generated-code/bugs/handle-return-result.bot.aot.txt) | [4/0/0](logs/audit/comprehensive-generated-code/bugs/handle-return-result.bot.aot-spec.txt) | 0 → 0 | OK |
| `audit/comprehensive-generated-code/bugs/module-closure-from-user-fn.bot` | [13/16/1](logs/audit/comprehensive-generated-code/bugs/module-closure-from-user-fn.bot.aot.txt) | [11/0/0](logs/audit/comprehensive-generated-code/bugs/module-closure-from-user-fn.bot.aot-spec.txt) | 24 → 0 | OK |
| `audit/comprehensive-generated-code/probes/ascii-256.bot` | [9/6/0](logs/audit/comprehensive-generated-code/probes/ascii-256.bot.aot.txt) | [8/0/0](logs/audit/comprehensive-generated-code/probes/ascii-256.bot.aot-spec.txt) | 6 → 0 | OK |
| `audit/comprehensive-generated-code/probes/byte-set-canonical.bot` | [4/6/0](logs/audit/comprehensive-generated-code/probes/byte-set-canonical.bot.aot.txt) | [4/0/0](logs/audit/comprehensive-generated-code/probes/byte-set-canonical.bot.aot-spec.txt) | 6 → 0 | OK |
| `audit/comprehensive-generated-code/probes/byte-set-dynamic.bot` | [4/6/0](logs/audit/comprehensive-generated-code/probes/byte-set-dynamic.bot.aot.txt) | [4/0/0](logs/audit/comprehensive-generated-code/probes/byte-set-dynamic.bot.aot-spec.txt) | 6 → 0 | OK |
| `audit/comprehensive-generated-code/probes/from-int-byte.bot` | [4/6/0](logs/audit/comprehensive-generated-code/probes/from-int-byte.bot.aot.txt) | [3/0/0](logs/audit/comprehensive-generated-code/probes/from-int-byte.bot.aot-spec.txt) | 6 → 0 | OK |
| `audit/comprehensive-generated-code/probes/from-int-dynamic.bot` | [4/6/0](logs/audit/comprehensive-generated-code/probes/from-int-dynamic.bot.aot.txt) | [2/0/0](logs/audit/comprehensive-generated-code/probes/from-int-dynamic.bot.aot-spec.txt) | 6 → 0 | OK |
| `audit/comprehensive-generated-code/probes/from-int-invalid.bot` | [—](logs/audit/comprehensive-generated-code/probes/from-int-invalid.bot.aot.txt) | [—](logs/audit/comprehensive-generated-code/probes/from-int-invalid.bot.aot-spec.txt) | — | expected frontend rejection |
| `audit/comprehensive-generated-code/probes/from-int-literal.bot` | [4/6/0](logs/audit/comprehensive-generated-code/probes/from-int-literal.bot.aot.txt) | [2/0/0](logs/audit/comprehensive-generated-code/probes/from-int-literal.bot.aot-spec.txt) | 6 → 0 | OK |
| `audit/comprehensive-generated-code/probes/from-int-nonneg.bot` | [5/7/0](logs/audit/comprehensive-generated-code/probes/from-int-nonneg.bot.aot.txt) | [4/0/0](logs/audit/comprehensive-generated-code/probes/from-int-nonneg.bot.aot-spec.txt) | 7 → 0 | OK |
| `audit/comprehensive-generated-code/probes/steady-ascii-capture.bot` | [12/6/0](logs/audit/comprehensive-generated-code/probes/steady-ascii-capture.bot.aot.txt) | [10/0/0](logs/audit/comprehensive-generated-code/probes/steady-ascii-capture.bot.aot-spec.txt) | 6 → 0 | stack → compile OK |
| `audit/comprehensive-generated-code/probes/steady-ascii-param.bot` | [12/6/0](logs/audit/comprehensive-generated-code/probes/steady-ascii-param.bot.aot.txt) | [10/0/0](logs/audit/comprehensive-generated-code/probes/steady-ascii-param.bot.aot-spec.txt) | 6 → 0 | stack → compile OK |
| `audit/comprehensive-generated-code/probes/steady-ascii.bot` | [11/6/0](logs/audit/comprehensive-generated-code/probes/steady-ascii.bot.aot.txt) | [9/0/0](logs/audit/comprehensive-generated-code/probes/steady-ascii.bot.aot-spec.txt) | 6 → 0 | stack → compile OK |
| `audit/comprehensive-generated-code/probes/web-unreserved-256.bot` | [12/16/1](logs/audit/comprehensive-generated-code/probes/web-unreserved-256.bot.aot.txt) | [10/0/0](logs/audit/comprehensive-generated-code/probes/web-unreserved-256.bot.aot-spec.txt) | 24 → 0 | OK |
| `audit/comprehensive-generated-code/probes/web-unreserved-literals.bot` | [12/16/1](logs/audit/comprehensive-generated-code/probes/web-unreserved-literals.bot.aot.txt) | [10/0/0](logs/audit/comprehensive-generated-code/probes/web-unreserved-literals.bot.aot-spec.txt) | 24 → 0 | OK |
| `audit/post-native-stack/module-cases/main.bot` | [—](logs/audit/post-native-stack/module-cases/main.bot.aot.txt) | [—](logs/audit/post-native-stack/module-cases/main.bot.aot-spec.txt) | — | needs context → OK |
| `audit/post-native-stack/module-cases/managed.bot` | [1/1/0](logs/audit/post-native-stack/module-cases/managed.bot.aot.txt) | [1/1/0](logs/audit/post-native-stack/module-cases/managed.bot.aot-spec.txt) | 1 → 1 | OK |
| `audit/post-native-stack/module-cases/plain.bot` | [1/1/0](logs/audit/post-native-stack/module-cases/plain.bot.aot.txt) | [1/1/0](logs/audit/post-native-stack/module-cases/plain.bot.aot-spec.txt) | 1 → 1 | OK |
| `audit/post-native-stack/module-cases/scalar.bot` | [1/1/0](logs/audit/post-native-stack/module-cases/scalar.bot.aot.txt) | [1/1/0](logs/audit/post-native-stack/module-cases/scalar.bot.aot-spec.txt) | 1 → 1 | OK |
| `bench/fib.bot` | [1/1/0](logs/bench/fib.bot.aot.txt) | [2/0/0](logs/bench/fib.bot.aot-spec.txt) | 1 → 0 | OK |
| `bench/lex-strategy.bot` | [3/5/5](logs/bench/lex-strategy.bot.aot.txt) | [7/3/1](logs/bench/lex-strategy.bot.aot-spec.txt) | 22 → 3 | OK |
| `bench/loop-count.bot` | [1/2/0](logs/bench/loop-count.bot.aot.txt) | [3/0/0](logs/bench/loop-count.bot.aot-spec.txt) | 3 → 0 | stack → compile OK |
| `bench/refined-checks.bot` | [1/1/0](logs/bench/refined-checks.bot.aot.txt) | [2/0/0](logs/bench/refined-checks.bot.aot-spec.txt) | 4 → 0 | stack → compile OK |
| `bench/source-checks.bot` | [4/1/5](logs/bench/source-checks.bot.aot.txt) | [4/2/1](logs/bench/source-checks.bot.aot-spec.txt) | 11 → 4 | OK |
| `bench/sum-refined.bot` | [1/2/0](logs/bench/sum-refined.bot.aot.txt) | [3/1/0](logs/bench/sum-refined.bot.aot-spec.txt) | 3 → 1 | stack → compile OK |
| `bench/test-selection.bot` | [5/4/4](logs/bench/test-selection.bot.aot.txt) | [10/4/0](logs/bench/test-selection.bot.aot-spec.txt) | 12 → 5 | OK |
| `bench/uri-steady.bot` | [12/17/1](logs/bench/uri-steady.bot.aot.txt) | [19/0/0](logs/bench/uri-steady.bot.aot-spec.txt) | 28 → 0 | stack → compile OK |
| `examples/stdlib/ai_text_clean.bot` | [4/2/0](logs/examples/stdlib/ai_text_clean.bot.aot.txt) | [6/0/0](logs/examples/stdlib/ai_text_clean.bot.aot-spec.txt) | 6 → 0 | OK |
| `examples/stdlib/csv.bot` | [2/6/0](logs/examples/stdlib/csv.bot.aot.txt) | [10/0/0](logs/examples/stdlib/csv.bot.aot-spec.txt) | 17 → 0 | OK |
| `examples/stdlib/csv_chunked.bot` | [4/9/0](logs/examples/stdlib/csv_chunked.bot.aot.txt) | [19/1/0](logs/examples/stdlib/csv_chunked.bot.aot-spec.txt) | 29 → 1 | OK |
| `examples/stdlib/csv_geometric.bot` | [3/10/0](logs/examples/stdlib/csv_geometric.bot.aot.txt) | [14/0/0](logs/examples/stdlib/csv_geometric.bot.aot-spec.txt) | 24 → 0 | OK |
| `examples/stdlib/csv_records.bot` | [14/36/0](logs/examples/stdlib/csv_records.bot.aot.txt) | [41/17/0](logs/examples/stdlib/csv_records.bot.aot-spec.txt) | 84 → 29 | OK |
| `examples/stdlib/hashtable.bot` | [11/23/1](logs/examples/stdlib/hashtable.bot.aot.txt) | [20/10/0](logs/examples/stdlib/hashtable.bot.aot-spec.txt) | 63 → 25 | OK |
| `examples/stdlib/matmul.bot` | [1/4/0](logs/examples/stdlib/matmul.bot.aot.txt) | [7/0/0](logs/examples/stdlib/matmul.bot.aot-spec.txt) | 17 → 0 | OK |
| `examples/stdlib/string_replace.bot` | [1/3/0](logs/examples/stdlib/string_replace.bot.aot.txt) | [4/0/0](logs/examples/stdlib/string_replace.bot.aot-spec.txt) | 12 → 0 | OK |
| `examples/stdlib/string_reverse.bot` | [2/1/0](logs/examples/stdlib/string_reverse.bot.aot.txt) | [3/0/0](logs/examples/stdlib/string_reverse.bot.aot-spec.txt) | 4 → 0 | OK |
| `examples/surface/01-arithmetic.bot` | [1/0/0](logs/examples/surface/01-arithmetic.bot.aot.txt) | [1/0/0](logs/examples/surface/01-arithmetic.bot.aot-spec.txt) | 0 → 0 | OK |
| `examples/surface/02-recursion.bot` | [1/1/0](logs/examples/surface/02-recursion.bot.aot.txt) | [2/0/0](logs/examples/surface/02-recursion.bot.aot-spec.txt) | 1 → 0 | OK |
| `examples/surface/03-closure.bot` | [2/1/0](logs/examples/surface/03-closure.bot.aot.txt) | [3/1/0](logs/examples/surface/03-closure.bot.aot-spec.txt) | 2 → 1 | OK |
| `examples/surface/04-branch-value.bot` | [1/1/0](logs/examples/surface/04-branch-value.bot.aot.txt) | [2/0/0](logs/examples/surface/04-branch-value.bot.aot-spec.txt) | 1 → 0 | OK |
| `examples/surface/05-shadowing.bot` | [1/0/0](logs/examples/surface/05-shadowing.bot.aot.txt) | [1/0/0](logs/examples/surface/05-shadowing.bot.aot-spec.txt) | 0 → 0 | OK |
| `examples/surface/06-list.bot` | [1/0/0](logs/examples/surface/06-list.bot.aot.txt) | [1/0/0](logs/examples/surface/06-list.bot.aot-spec.txt) | 0 → 0 | OK |
| `examples/surface/07-loop-break.bot` | [1/0/0](logs/examples/surface/07-loop-break.bot.aot.txt) | [1/0/0](logs/examples/surface/07-loop-break.bot.aot-spec.txt) | 0 → 0 | OK |
| `examples/surface/08-return.bot` | [1/2/0](logs/examples/surface/08-return.bot.aot.txt) | [3/0/0](logs/examples/surface/08-return.bot.aot-spec.txt) | 2 → 0 | OK |
| `examples/surface/09-mutual-recursion.bot` | [1/2/0](logs/examples/surface/09-mutual-recursion.bot.aot.txt) | [3/2/0](logs/examples/surface/09-mutual-recursion.bot.aot-spec.txt) | 2 → 2 | OK |
| `examples/surface/10-duplicate-binding.bot` | [—](logs/examples/surface/10-duplicate-binding.bot.aot.txt) | [—](logs/examples/surface/10-duplicate-binding.bot.aot-spec.txt) | — | expected frontend rejection |
| `examples/surface/11-boolean-operators.bot` | [2/1/0](logs/examples/surface/11-boolean-operators.bot.aot.txt) | [3/0/0](logs/examples/surface/11-boolean-operators.bot.aot-spec.txt) | 3 → 0 | OK |
| `examples/surface/12-if-value.bot` | [1/1/0](logs/examples/surface/12-if-value.bot.aot.txt) | [2/0/0](logs/examples/surface/12-if-value.bot.aot-spec.txt) | 1 → 0 | OK |
| `examples/surface/13-hygiene.bot` | [2/0/0](logs/examples/surface/13-hygiene.bot.aot.txt) | [2/0/0](logs/examples/surface/13-hygiene.bot.aot-spec.txt) | 0 → 0 | OK |
| `examples/surface/14-modules.bot` | [1/1/0](logs/examples/surface/14-modules.bot.aot.txt) | [2/0/0](logs/examples/surface/14-modules.bot.aot-spec.txt) | 1 → 0 | OK |
| `lib/ascii.bot` | [—](logs/lib/ascii.bot.aot.txt) | [—](logs/lib/ascii.bot.aot-spec.txt) | — | needs context → OK |
| `lib/byte.bot` | [4/6/0](logs/lib/byte.bot.aot.txt) | [4/0/0](logs/lib/byte.bot.aot-spec.txt) | 6 → 0 | OK |
| `lib/char.bot` | [2/0/0](logs/lib/char.bot.aot.txt) | [2/0/0](logs/lib/char.bot.aot-spec.txt) | 0 → 0 | OK |
| `lib/list.bot` | [1/0/4](logs/lib/list.bot.aot.txt) | [1/0/1](logs/lib/list.bot.aot-spec.txt) | 8 → 2 | OK |
| `lib/mathish.bot` | [1/1/0](logs/lib/mathish.bot.aot.txt) | [1/1/0](logs/lib/mathish.bot.aot-spec.txt) | 1 → 1 | OK |
| `lib/web.bot` | [12/16/1](logs/lib/web.bot.aot.txt) | [21/3/1](logs/lib/web.bot.aot-spec.txt) | 24 → 4 | OK |

## Evidence and reproduction

- [Raw manifest](files.txt), [environment](environment.json), [per-run JSON](results.json), [CSV](results.csv), [aggregate JSON](summary.json).
- [Compiler reruns](followup.json), [context reruns](context.json), [context setup](context.tcl).
- Run `python3 audit/aot-state-2026-09-28/run.py` inside WSL from the repository root for the baseline, followed by `followup.py`, `context.py`, `summarize.py`, and `report.py` in the same directory.
