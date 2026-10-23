# Post-2048 product fixes: application modules, native output, recursion

The [2048 workload](2048-ENGINE-WORKLOAD.md) found that its largest
obstacles were not the language but the product around it. This milestone
fixes exactly the three product failures that would make the restricted
15-puzzle workload an unfair test of Botlish usability, and nothing else:

| finding | before | after |
|---|---|---|
| S4 | `import NAME` named only `stdlib/NAME.bot`: an application could not have a module of its own (the workload compiled against a private copy of `stdlib/`; the single executable could not do it at all) | a program's own modules are the files beside its entry file |
| S15 | `main.tcl -backend cranelift` showed a printing program's value and nothing it printed | the program writes to main.tcl's own standard output and error, then main.tcl prints the value |
| S22 | `main.tcl -backend interp` failed a 200-deep recursion (`TCL LIMIT STACK`) | main.tcl runs programs under the golden runner's limit: about 14,000 interpreted calls |

Each is an existing feature made usable -- imports, `std::io::print_line`,
ordinary recursion -- not a new one. No language feature, stdlib operation,
proof, optimization, warning or diagnostic outside these three was added or
changed: no file under `hir/`, `compiler/`, `stdlib/`, `native/lower.tcl` or
`native/src/codegen/` differs, and the 2048 engine is byte-for-byte the one
the workload wrote ([section 6](#6-deliberately-unresolved-findings) lists
what stays open on purpose).

## Changes, by kind

| kind | change |
|---|---|
| front end (S4) | `surface/modules.tcl`: the application root, `ResolveModule` (the rule), `ApplicationFile`, `NamespaceExistsFor`, `NoSuchNamespace`, the `MODULE-COLLISION` diagnostic; `LoadNamespace` takes the resolved path. `surface/lower.tcl`: `-root DIR` for program text. `surface/cache.tcl`: the root in the key, each import's application path among the dependencies |
| native driver (S15) | `native/src/main.rs`: `--result PATH`; `native/src/runtime/platform/linux.rs`: the overflow guard writes its report to that file (`set_result_fd`). `native/native.tcl`: `RunDriver` and `native::evalHir -output discard\|inherit` |
| runtime host (S22) | `core/core.tcl`: `core::programRecursionLimit`, `core::useProgramRecursionLimit` |
| CLI | `main.tcl`: the recursion policy; native runs with `-output inherit`. `tests/golden/run.tcl`: the same policy instead of its own number |
| single executable | `single/smoke-test.sh`: an application module from another directory on every backend, 3000 calls deep; the missing-module diagnostic; native output |
| workload tooling | `examples/games/2048/run.tcl`: the private library removed (the obsolete part only); `bench/2048.tcl`, `tests/workload-2048.test` compile the programs as they are; `audit/2048/mutate.tcl` makes each mutant a private application directory instead of a private library; two comments in `demo.bot` and `golden.bot` that described the workaround |
| tests | `tests/application-modules.test` (21), `tests/native-program-output.test` (11), `tests/main-recursion.test` (6), `tests/hir-cache.test` (+2), `tests/workload-2048.test` (+2); census rows and the regenerated manifest; `tests/static-compile.test`'s census classifies `MODULE-COLLISION` (header only) |
| audits | `audit/hir-interchange/tools/mutants.txt`: `key-ignores-root`, `deps-ignore-application-paths` |
| docs | IMPORTS.md ("Application modules"), README.md (§17 Modules, §20), SINGLE-EXECUTABLE.md, HIR-INTERCHANGE.md, STATIC-COMPILE.md (census), 2048-ENGINE-WORKLOAD.md and its surprise log (S4, S15, S22 resolved), AGENTS.md, this report |
| stdlib, language, proofs, diagnostics otherwise | none |

## 1. S4: application modules

**Old behavior.** `import game` beside `game.bot` was `UNKNOWN-NAMESPACE: no
such module file stdlib/game.bot` -- from the single executable `no such module
file //zipfs:/app/botlish/lib/game.bot`, a path inside the executable. The
workload compiled its four programs against a temporary copy of `stdlib/` with
the engine added (D5), and a single-executable user had to concatenate the
engine into each program, which lost its opaque-struct authority and
silently shadowed its functions (S25).

**Root cause.** `surface::modules::ModulePath` mapped a namespace to exactly
`$::core::libraryDir/NAME.bot`. There was no notion of a program's own
location.

**The rule** (IMPORTS.md, "Application modules"). The *application root* is
the directory of the entry file -- `compileProgramFile`'s own path,
normalized, wherever the compiler was started from. For an import an
*application file* (the entry program or one of its application modules)
writes, namespace `NAME` is:

1. a standard namespace -- `$::core::libraryDir/NAME.bot` or compiler
   intrinsics -- exactly as before;
2. else `ROOT/NAME.bot` (`ROOT/a/b.bot` for `a::b`, the existing nesting rule
   under the new root), an application module;
3. else `UNKNOWN-NAMESPACE`, naming the application path first:

   ```text
   unknown namespace "game": no such module file /work/app/game.bot (an
   application's own modules are the files beside its entry program), and in
   the standard library no such module file //zipfs:/app/botlish/lib/game.bot
   and no intrinsics of that namespace
   ```

Considered and rejected: the working directory (the same command from two
directories would compile two programs), a search path or a `-lib` option
(path soup, and nothing the 15-puzzle needs), the application before the
standard library (a stray `list.bot` would replace `list` for the whole
program).

**Standard namespaces stay privileged.** A standard-library module's imports
are resolved in the standard library only. The one ambiguity two roots can
produce -- an application file imports standard `NAME` while the application
has `ROOT/NAME.bot` -- is `MODULE-COLLISION`, naming both files, never a
silent choice in either direction. An application file nobody imports
collides with nothing; an entry file named like a standard namespace
(`test.bot` importing `test`) imports that namespace, because the entry
program is not a module (importing the entry file itself is `SELF-IMPORT`,
from a module `CYCLE`). Cycles, self-imports, opaque structs, types, errors,
method candidates and diagnostics' locations are those of any module: an
application module is loaded by the same `LoadNamespace`, from a different
path. The repository has no program beside a file that would collide (checked
over every `.bot` outside `stdlib/`, at every nesting depth).

**Smallest fix.** `ResolveModule` decides the path; `CheckImports` and
`CheckRef` ask it (or `NamespaceExistsFor`) instead of testing
`stdlib/NAME.bot`; the loader state carries `root`, `entry` and which loaded
namespaces are the application's. `BuildProgram` takes the root;
`compileProgramFile` passes its file's directory; program text has none
unless a caller passes `-root` (bench/2048.tcl, for its edited benchmark
text).

**Front-end cache and interchange.** The root is a front-end input, so it is
in `surface::cache::Key` (one relative path from two working directories is
two programs) and each import's application path is a dependency (an edited
application module, or a new file that would now collide, is a miss). The
analyzed HIR holds the modules, so a `.hirx` runs on every backend and
becomes NIR, CLIF or an executable with its source directory deleted
(`app-interchange-without-sources`). HIR, Core IR and NIR are unchanged: the
backends never knew where a module came from.

**Tests.** `tests/application-modules.test`: a sibling module on four
backends; modules importing modules, nested `util::math`; method sugar;
standard imports beside application ones (the HIR's files: `APP/main.bot`,
`APP/counter.bot`, `LIB/list.bot`); a module two files import is compiled
once and its struct passes between them; `import type` and `on game::TooBig`;
opaque authority (`OPAQUE-CONSTRUCTION`, `OPAQUE-REPRESENTATION` in the
importer); a module's diagnostic located in its own file; both missing-module
messages; `MISSING-IMPORT` for an existing application namespace;
`MODULE-COLLISION` for a module file, an intrinsics-only namespace and a
nested one; a standard module's imports never see the application; the entry
is not a module; cycles; the root is not the working directory (a decoy
`counter.bot` there, absolute and relative paths); text has no root; a root
inside the library directory; interchange with the sources gone; main.tcl run
from `/` on four backends. `tests/hir-cache.test`: `hc-application-root`,
`hc-application-module-edited`. Against the old loader 19 of the 21 fail;
the two that pass are guards of what held before (a standard module's
imports, a root inside the library), and both new cache tests fail too.

**Architectural consequence.** One more front-end input (the root) and one
more module source, both inside `surface/modules.tcl` and the cache key. The
namespace identity rule is unchanged: a file's path relative to its root is
its namespace.

## 2. S15: native program output

**Old behavior.** `main.tcl -backend cranelift hello.bot` printed `value:
unit` and no `Hello, world!`; so did `cranelift-generic`; the emitted
executable printed both.

**Root cause.** `native::Driver` ran `botlish-native run` with standard
output and error in one pipe and `native::Outcome` kept the last `value` or
`error` line: the program's own writes (raw `write(2)`s on descriptor 1)
were read and dropped. The same sharing made the result fragile: a program
printing an unterminated `error {...}` would have been taken for the result.

**Smallest fix.** The driver takes `--result PATH` and writes its protocol
lines there; standard output and error are then the program's alone.
`native::evalHir ... -output inherit` runs the driver with this process's own
standard output and error (`exec ... >@stdout 2>@stderr`, which flushes
main.tcl's buffered header first) and reads the result from the file;
main.tcl uses it for both native backends. The overflow guard, which writes
its report from a signal handler, writes it to the result file too
(`set_result_fd`; found by the failure-after-output test: the report had
landed in the program's output and the run was a `NATIVE BUG`). Without
`-output`, `native::evalHir` and `native::Driver` still drop what a program
writes, so the test suite and the tools stay quiet and unchanged.

The order is the one every backend's line follows -- `== FILE (BACKEND)`, the
program's output as it writes it, then `value:` (or `error:`) -- which is the
executable's order too (output, then the value). Nothing is buffered or
decoded: the bytes go from the program to main.tcl's descriptor directly.
Interp and compile still cannot print (the only `std::io::IO` context is LinuxIO's
raw syscalls, `NATIVE-ONLY` on the Tcl backends): that is the STDLIB half of
S15, a missing capability, not this product failure.

**Tests.** `tests/native-program-output.test`, byte for byte: one line on
both native backends; several lines and a non-unit value; no output; standard
error kept separate; raw bytes `ff 00 80 0a 0d 0a` through `std::linux::io::write`
unchanged; output kept when the program then dies of native stack overflow
(exit status 1, the `NATIVE LIMIT STACK` error line after the output);
text that looks like result lines is output; several files in one run; the
same stdout and stderr as the emitted executable; the driver's `--result`
directly; `native::evalHir`'s default drops output and its `-output` is
validated. `tests/workload-2048.test`'s `workload-2048-demo-main-native`:
`main.tcl -backend cranelift demo.bot` prints the whole pinned game, then
`value: unit`. Without the fix 10 of the 11 fail (no output is all that
passes).

**Performance.** The driver run of the demo (316 moves, about 1.5 KB of
output): 52.6 ms discarding, 54.8 ms inheriting (best of 10, alternating) --
one result file more, no buffering.

**Architectural consequence.** The driver's protocol has a channel of its
own when asked. Nothing else reads it differently.

## 3. S22: interpreter recursion

**Old behavior.** main.tcl ran programs under tclsh's default recursion
limit, 1000 nested evaluations: the interpreter spends about seven per
Botlish call, so `fn total(k): ... k + total(k - 1)` failed at about 140
calls (`TCL LIMIT STACK`) while the golden runner, which set 100000, ran it.

**Root cause.** The limit was set by each harness for itself (the golden
runner's `interp recursionlimit {} 100000`, many tools' own numbers) and by
none of the product entry points.

**Smallest fix.** One policy, `core::programRecursionLimit` (100000, the
golden runner's value and the front end's own floor) and
`core::useProgramRecursionLimit`, which raises the limit and never lowers a
higher one. main.tcl and `tests/golden/run.tcl` call it; neither has a number
of its own. `core::evalProgram` and the compiler raise nothing
(`tests/compiler-opt.test`'s `opt-tail-2` still checks a compiled tail call
under 1000).

**What it gives, measured** (non-tail recursion under main.tcl): the
interpreter runs 14,218 nested calls and fails at 14,375; the Tcl compiler
runs 99,000 and fails at 100,500. Tcl 9's non-recursive engine does not grow
the C stack for these evaluations (no crash at the limit, in the checkout's
tclsh or the single executable's static one), so the limit is a count, not a
stack size.

**The remaining limit.** A deeper recursion still fails with `TCL LIMIT
STACK`. On the interpreter that failure is slow to report: Tcl unwinds an
error through the evaluator's nested `try`/`finally` bodies in quadratic time
(about 0.8 s at a limit of 10,000, 15.6 s at 50,000, about 75 s at 100,000;
a plain Tcl proc recursion with a `try`/`finally` per level shows the same
curve, 9 s at 20,000 and 43 s at 40,000). The Tcl compiler reports the same
runaway recursion in 0.7 s, and natively it is `NATIVE LIMIT STACK` at once.
Making the evaluator's error unwinding linear is optimization work, not this
milestone's.

**Tests.** `tests/main-recursion.test`, each a main.tcl process: 200 deep on
interp and compile; 5000 on interp and 20000 on compile; 3000-deep
recursions building a List and a String; the entry points use the policy
and no number of their own; the policy never lowers a limit; a runaway
recursion still fails with Tcl's limit error. Without the fix the first two
fail.

**Architectural consequence.** None beyond one named policy in core.

## 4. Single-executable acceptance

Built with `single/build.sh` (static Tcl 9.0.1 base kit from the pinned
source, 7.7 MB), copied into an empty directory outside the repository with
an application of its own, and run with `env -i` (no PATH, no Tcl, no
checkout):

```text
example/
    botlish
    counter.bot     fn count(k) -> int: 1 + count(k - 1), 0 at 0
    value.bot       import counter / counter::count(5000)
    main.bot        import counter, io, std::linux::io; std::io::print_line(...); counter::count(5000)
```

| run | before (the same build from the pre-milestone tree) | after |
|---|---|---|
| `botlish -backend interp value.bot` | `unknown namespace "counter": no such module file //zipfs:/app/botlish/lib/counter.bot and no intrinsics of that namespace` | `value: 5000` |
| `botlish -backend compile / cranelift-generic / cranelift value.bot` | the same error | `value: 5000` each |
| `botlish -backend cranelift main.bot` (and `cranelift-generic`) | (cannot import) | the printed line, then `value: 5000` |
| `botlish -emit-native-executable main.bot && ./main` | (cannot import) | the printed line, then `5000` |
| a 200-deep recursion in one file, `-backend interp` | `too many nested evaluations (infinite loop?) (TCL LIMIT STACK)` | `value: 200` |
| a printing program in one file, `-backend cranelift` | `value: unit` only | `printed`, then `value: unit` |
| `import game` with no `game.bot` | names only the archive's path | names `.../example/game.bot` first |
| a `list.bot` beside a program importing `list` | (`list` is the archive's) | `MODULE-COLLISION` naming both |
| `-emit-hir-interchange value.bot`, sources moved away, the `.hirx` run | -- | `value: 5000` on four backends, and an executable |

`main.bot` on interp fails, as before, with `NATIVE-ONLY` (printing needs
the native backend). The 2048 programs, copied into another empty directory
with the executable: `botlish -backend cranelift demo.bot` prints the whole
game and `value: unit` (the program output identical to the emitted
executable's), and `golden.bot` passes **68 of 68 on all four backends** --
the single-file workaround of the 2048 report passed 66, because the two
tests that `Board`'s construction and fields belong to the engine cannot hold
in one file (S25); with the engine a module again they hold.
`single/smoke-test.sh` now checks an application module from another working
directory on every backend at 3000 calls deep, the missing-module diagnostic
and native output, and passes.

## 5. 2048 regression

The engine (`game2048.bot`) and the benchmark program are unchanged; the demo
and the suite changed in one comment each. What changed is how they are
compiled: as they are, with the engine as their application module.

* `tests/workload-2048.test`: 7 of 7 -- the suite (68 tests on the pass's
  backends), warning-clean, strict warnings, the benchmark checksum 2002720,
  the demo executable plain and under GC stress, and two new tests: the
  engine is the application module beside the programs and not in `stdlib/`,
  and `main.tcl -backend cranelift`/`cranelift-generic` print the whole game.
* `audit/2048/mutate.tcl` (each mutant a private application directory):
  20 of 20 killed, baseline passing.
* `audit/golden/tools/perturb.tcl -lib DIR golden.bot`: 68 of 68 fail
  inverted, 60 of 60 altered (8 not alterable), as before.

The engine keeps every workaround the report recorded: the decimal digits by
subtraction (no Int-to-String, no division), `no_positions()` (typed empty
vector), `std::list::get` defaults (no List length facts), the self-recursive
accumulators (no fold), `reversed`/`transposed`/`replaced`/`total`.

## 6. Deliberately unresolved findings

Nothing here was touched; each remains evidence for the 15-puzzle run.

| finding | status |
|---|---|
| S1 Int to String | open here; closed in the standard library by NUMERIC-TEXT-BOUNDARY-MILESTONE-1.md (`std::int::to_string`), whose run left the 2048 engine's workaround in place as this evidence |
| S2 integer division | open |
| S5 descending-loop index proofs | open: `hir/range.tcl` unchanged |
| S6 typed empty MutableVector | open |
| S7 List length facts through parameters and fields | open |
| S9 lockstep over a field projection | open |
| S12 method-candidate ambiguity from a local name | open: resolution unchanged |
| S21 private module members | open: an application module's helpers are importable, as a library module's are |
| S23 folding / loop-carried state | open |
| S25 what a single-file program loses | **eliminated as a consequence of S4, not by a change of its own**: a program and its module are two namespaces again, so the engine's opaque authority holds (the 68/68 above) and a test's helper no longer silently shadows an engine function of the same name. The diagnostic that did not name the shadowing (its DIAGNOSTIC half) is unchanged, and still applies within one file |
| S26 collecting-loop element ranges | open |
| S27 exact character facts through names | open |
| S3, S11, S13, S17, S18, S20 | open (out of scope: tooling, diagnostics, performance) |
| S15's STDLIB half | open: the Tcl backends cannot print |

No collateral fix was needed for correctness.

## 7. Validation

Every test file this milestone adds or changes, plus the areas AGENTS.md
names for a front-end, cache or interchange change, passed individually:
`tests/application-modules.test` 21/21, `tests/native-program-output.test`
11/11, `tests/main-recursion.test` 6/6, `tests/hir-cache.test` 17/17,
`tests/workload-2048.test` 7/7, `tests/imports.test` 104/104,
`tests/surface-modules.test` 37/37, `tests/hir-interchange.test` 11/11,
`tests/static-compile.test` 83/83, `tests/compilation-isolation.test` 19/19,
`tests/enums.test` 66/66, `tests/opaque-struct.test` 141/141,
`tests/namespaced-errors.test` 31/31, `tests/direct-hir-native.test` 37/37,
`tests/native-stack-overflow.test` 4/4, `tests/native-executable.test`
14/14.

* `audit/hir-interchange/tools/mutate.tcl`: 27 of 27 mutants killed,
  `key-ignores-root` (by `hc-application-root`) and
  `deps-ignore-application-paths` (by `hc-application-module-edited`)
  among them.
* Targeted mutants of the new rules, each applied to a private copy of the
  tree and run against its test file: 10 of 10 killed -- no collision check
  (`app-cannot-shadow-standard`), the root taken from the working directory
  (18 tests), standard modules resolving against the application
  (`app-standard-modules-see-no-application`), the entry file loaded as a
  module (`app-entry-not-a-module`), the missing-module message without the
  application path (2), qualified references blind to application
  namespaces (`app-reference-without-import`), main.tcl's `cranelift` and
  `cranelift-generic` runs discarding output (8 and 4), main.tcl without the
  recursion policy and the policy lowered to 1000 (4 each).
* `audit/hir-interchange/tools/roundtrip.tcl`: `-via interchange` 10
  suites, 90 artifacts and outcomes compared, 0 differ; `-via cache` 10
  suites, 100 compared, 0 differ.
* `tclsh9.0 tests/local.tcl -jobs 4` on the final tree: Tcl tests on interp
  5,649 passed and on compile 5,645 passed (4 skipped), 0 failed (2,092
  golden duplicates skipped on each); 91 golden suites, 0 failed: interp
  4,708/4,708, compile 4,708/4,708, cranelift-generic 4,615/4,615,
  cranelift 4,717/4,717 (42 minutes).
* The new and changed executable-building test files with the stub linker
  (`BOTLISH_NATIVE_LINKER=stub CORE_BACKEND=compile`, CI's `stub-linker`
  job): 45 of 45; `tests/application-modules.test` and
  `tests/native-program-output.test` under `BOTLISH_NATIVE_GC_STRESS=1` on
  both passes: 32 of 32 each.

Not run here: the arm64 workflow (the guard change is the same code on
AArch64) and the static-decisions comparison (CI's, on the push to main:
AGENTS.md, "The sequential comparison runs in CI, never locally"; no
decision code changed).
