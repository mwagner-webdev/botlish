import json
from pathlib import Path

out = Path(__file__).resolve().parent
rows = json.loads((out / 'results.json').read_text())
summary = json.loads((out / 'summary.json').read_text())
metadata = json.loads((out / 'environment.json').read_text())
followup = json.loads((out / 'followup.json').read_text())
contexts = json.loads((out / 'context.json').read_text())
by_path = {}
for row in rows:
    by_path.setdefault(row['path'], {})[row['mode']] = row
assert len(by_path) == 58 and len(rows) == 116
assert all(set(pair) == {'aot', 'aot-spec'} for pair in by_path.values())
assert all(pair['aot']['value'] == pair['aot-spec']['value'] and pair['aot']['errors'] == pair['aot-spec']['errors'] for pair in by_path.values())
assert not any(r['timeout'] for r in rows)
assert len(followup) == 14 and all(r['exit_code'] == 0 for r in followup)
assert len(contexts) == 4 and all(r['exit_code'] == 0 for r in contexts)
assert sum(summary['aot']['regions'].values()) == 527
assert sum(summary['aot-spec']['regions'].values()) == 379
assert sum(summary['aot-spec']['blockers'].values()) == 85

lines = [
    '# AOT implementation audit — 2026-09-28',
    '',
    f"Tested checkout `{metadata['commit']}` on branch `{metadata['branch']}` with Ubuntu 24.04.3 WSL2, Tcl 9.0.1, and `LANG=C.utf8 LC_ALL=C.utf8`.",
    '',
    'All 58 `.bot` files present in the checkout were enumerated recursively, including audit probes, module fixtures, and libraries. Each was run in a fresh Tcl process with each flag separately (116 baseline invocations):',
    '',
    '```sh',
    'tclsh9.0 main.tcl -aot FILE.bot',
    'tclsh9.0 main.tcl -aot-spec FILE.bot',
    '```',
    '',
    'The default runtime backend was `interp`; inherited `CORE_BACKEND` and `BOTLISH_*` overrides were cleared. All invocations completed within the 180-second per-process timeout. Both flags produced identical program values or errors for each input. The Windows Git working tree was clean before and after the audit. Linux Git reported 19 modified files before execution despite the clean Windows status; its raw status is retained in `environment.json`. No tracked source was changed. The report, captured outputs, and reproduction scripts are preserved in `audit/aot-state-2026-09-28/`.',
    '',
    '## Execution outcomes',
    '',
    '| Outcome | `-aot` | `-aot-spec` |',
    '|---|---:|---:|',
    '| Analysis and default interpreter execution succeed | 47 | 47 |',
    '| Analysis succeeds; interpreter hits `TCL LIMIT STACK` | 7 | 7 |',
    '| Frontend rejects input before analysis | 4 | 4 |',
    '| Analyzer crashes or timeouts | 0 | 0 |',
    '',
    'All seven stack-limit cases succeeded when rerun with **both flags** and `-backend compile`: `steady-ascii.bot`, `steady-ascii-param.bot`, `steady-ascii-capture.bot`, `bench/loop-count.bot`, `bench/refined-checks.bot`, `bench/sum-refined.bot`, and `bench/uri-steady.bot`. The AOT reports had already completed before the interpreter reached its recursion limit.',
    '',
    'The four frontend rejections have distinct explanations:',
    '',
    '| Input | Reason | Follow-up |',
    '|---|---|---|',
    '| `audit/comprehensive-generated-code/probes/from-int-invalid.bot` | Intentional `byte::from_int(999)` rejection: `CORE SEMANTIC KNOWN-ERROR`, `AboveRange` | Expected negative probe |',
    '| `examples/surface/10-duplicate-binding.bot` | Intentional duplicate binding: `CORE SEMANTIC DUPLICATE` | Expected negative example |',
    '| `lib/ascii.bot` | `Byte` type is unregistered when launched alone | Loading `lib/byte.bot` first makes both flags succeed; zero guards |',
    '| `audit/post-native-stack/module-cases/main.bot` | `plain` module is outside the default `lib/` directory | Setting `core::libraryDir` to the fixture directory makes both flags succeed; result `[2, 8, 20]`, guards 3 → 0 |',
    '',
    '`lib/ascii.bot` documents its dependency on another compilation unit loading `byte`; existing ASCII consumers in the baseline run also succeed. The context reruns use `context.tcl` without editing any `.bot` source. With these setups and the compiler reruns, all **56 non-negative inputs** produce both reports and execute successfully.',
    '',
    '## Readiness reported by the analysis',
    '',
    'The following comparison covers the 54 files that produce reports without extra setup. A file is classified by the worst local status among its reported regions/instances, including retained generic entries. Semantic headings embedded in `-aot-spec` output are excluded from the instance counts.',
    '',
    '| Classification | `-aot` semantic regions | `-aot-spec` used instances |',
    '|---|---:|---:|',
    '| Files with only closed regions/instances | 8 | 39 |',
    '| Files with guards but no open dispatch | 36 | 11 |',
    '| Files containing open dispatch | 10 | 4 |',
    '| Closed regions/instances | 225 | 327 |',
    '| Guarded regions/instances | 278 | 48 |',
    '| Open regions/instances | 24 | 4 |',
    '| Representation blockers / kind guards | 534 | 81 |',
    '',
    'The specialized reports contain 268 specialized function instances, 57 generic function instances, and 54 program instances (379 total). The two dependency-context reruns add two fully closed files, giving **41 closed, 11 guarded, 4 open** among the 56 non-negative inputs.',
    '',
    '`closed` means operations and required operand kinds are statically known. `guarded` requires runtime kind checks. `open` requires dynamic semantic dispatch. These are analysis categories; a guarded or open program can still execute correctly through the existing runtime.',
    '',
    'The 534 → 81 reduction is 84.8% in reported static guard sites. The semantic report includes all functions; the specialized report includes used instances, so this reduction combines specialization with reachability pruning. Imported modules recur across per-file reports. These counts are neither unique source-site counts nor runtime check frequencies.',
    '',
    'Fibonacci, loop-count, URI escaping, ordinary CSV, geometric CSV, matrix multiplication, string replacement, and string reversal are fully closed in the specialized reports. `bench/test-selection.bot` has no remaining dynamic-call blocker, although five kind guards remain.',
    '',
    '## Remaining analysis gaps',
    '',
    '| Input | Semantic guards | Specialized guards |',
    '|---|---:|---:|',
]
for row in summary['remaining_guards']:
    lines.append(f"| `{row['path']}` | {row['generic']} | {row['specialized']} |")
lines += [
    '',
    '`csv_records.bot` and `hashtable.bot` account for 54 of 81 remaining guards (two thirds). Across all reports, the residual guard causes are 47 unknown call-result kinds, 23 unknown parameter kinds, and 11 unknown aggregate-element kinds. The two largest cases repeatedly lose Int or mutable-array kinds through hashtable accessors and list-shaped records.',
    '',
    'Four used instances still contain a `DynamicCall` blocker:',
    '',
    '| Input | Instance | Dynamic call location |',
    '|---|---|---|',
    '| `bench/lex-strategy.bot` | `classify<str, bool>` | line 57:9; classifier selected between Native and Block |',
    '| `bench/source-checks.bot` | `classify_leading<generic>` | line 56:9; callable read from the checks list |',
    '| `lib/list.bot` | `find<generic>` | line 79:12; unconstrained predicate |',
    '| `lib/web.bot` | `scan_while<generic>` | line 128:16; unconstrained predicate |',
    '',
    'The library entries are open when analyzed as standalone inputs with generic callable parameters. Concrete callers can close such dispatch: e.g. `bench/uri-steady.bot` is fully closed. A standalone module run does not supply call-site facts for every exported API, and its specialized report only includes instances retained by that run.',
    '',
    'Closed code still reports runtime requirements: arbitrary-precision integers, allocations, range checks, structural equality, captured environments, and related helpers. Closedness does not imply a runtime-free binary.',
    '',
    '## State of executable AOT',
    '',
    'The readiness and specialization analyses work across this corpus, subject to the guards and dynamic calls above. The requested flags print diagnostics and then evaluate through the chosen backend; neither flag emits an object or executable (`main.tcl:84` and `main.tcl:102`). This audit executed the interpreter and Tcl compiler paths, and did not test native code generation, linking, or standalone native execution.',
    '',
    'Source inspection shows the native object path is still explicitly an AOT smoke test:',
    '',
    '- `native/src/codegen/mod.rs:359`: `emit_object` exports generated functions, leaves runtime helpers as undefined imports, and returns the constant pool separately.',
    '- `native/src/main.rs:168`: the object command writes the object bytes and reports the pool entry count; it does not package a constant-table initializer.',
    '- `native/src/codegen/mod.rs:8`: a runnable executable still needs the runtime as a static library and a constant-table initializer.',
    '- `native/src/runtime/framemap.rs:21`: GC frame-map construction and registration currently belong to JIT compilation; the object path does not install that metadata.',
    '',
    'The next executable-AOT work is therefore runtime packaging and linking, constant initialization and startup, and GC metadata support for linked code. Separately, the largest analysis opportunities are preserving aggregate/call-result kinds and resolving callable values across control-flow joins and collections.',
    '',
    '## Complete per-file baseline',
    '',
    '`C/G/O` counts closed/guarded/open regions for `-aot`, and used instances for `-aot-spec`. `stack → compile OK` records the successful follow-up for both modes. The two context successes are supplemental; the baseline columns preserve the original outcome.',
    '',
    '| File | `-aot` C/G/O | `-aot-spec` C/G/O | Guards before → after | Execution |',
    '|---|---:|---:|---:|---|',
]
for path, pair in by_path.items():
    a, b = pair['aot'], pair['aot-spec']
    counts = lambda r: '/'.join(str(r['status_counts'].get(k, 0)) for k in ('closed', 'guarded', 'open')) if r['analysis_complete'] else '—'
    guards = f"{b['guards']['generic']} → {b['guards']['specialized']}" if b['guards'] else '—'
    if b['exit_code'] == 0:
        outcome = 'OK'
    elif any('TCL LIMIT STACK' in e for e in b['errors']):
        outcome = 'stack → compile OK'
    elif path == 'lib/ascii.bot' or path == 'audit/post-native-stack/module-cases/main.bot':
        outcome = 'needs context → OK'
    else:
        outcome = 'expected frontend rejection'
    lines.append(f"| `{path}` | [{counts(a)}]({a['log']}) | [{counts(b)}]({b['log']}) | {guards} | {outcome} |")
lines += [
    '',
    '## Evidence and reproduction',
    '',
    '- [Raw manifest](files.txt), [environment](environment.json), [per-run JSON](results.json), [CSV](results.csv), [aggregate JSON](summary.json).',
    '- [Compiler reruns](followup.json), [context reruns](context.json), [context setup](context.tcl).',
    '- Run `python3 audit/aot-state-2026-09-28/run.py` inside WSL from the repository root for the baseline, followed by `followup.py`, `context.py`, `summarize.py`, and `report.py` in the same directory.',
    '',
]
(out / 'REPORT.md').write_text('\n'.join(lines))
print(f"Wrote {out / 'REPORT.md'}; verified all 116 baseline results and 18 follow-up results.")
