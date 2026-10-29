# audit/main-thread-startup

The graphical acceptance of MAIN-THREAD-STARTUP-MILESTONE-1.md (`docs/`):
the census's candidate-A cases (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md,
`audit/macos-graphical-main-thread/`) run on the production startup policy
-- executables built with `-native-startup main-thread` -- instead of the
census's disposable experimental runtime. Nothing here is part of the
compiler, the runtime or the standard library, and nothing in them loads it.

| what | where |
|---|---|
| the harness: builds the census's fixtures and Botlish programs, links each program with each policy (Botlish.app's system linker; the checkout's rustc and system linkers), runs every case under a timeout, classifies it with the census's classifier, exits 1 on a case not as predicted | `tools/acceptance.py` |
| the fixtures, the programs and the classifier it reuses, unchanged | `../macos-graphical-main-thread/native/`, `programs/`, `tools/census.py` |
| recorded outcomes of CI runs | `results/` |

Groups (`--only`): `env` (the graphical session), `identity` (which thread
runs the program and its C calls, by the fixture's pthread_main_np and
NSThread; a linked run of -backend cranelift; the executables' dynamic
libraries), `lc-main` (LC_MAIN's stacksize by `otool -l`), `report` (the
startup report's policy, thread and stack, and its Vm against the worker's),
`runtime` (the census's depths, overflows, fault, GC stress, kept coroutines
and large frames on each policy), `semantics` (errors, the driver protocol,
the startup report, a runtime panic, the overflow line, signals during a C
call and during SDL), `graphical` (SDL3 through Cocoa and Metal, captured;
the worker's failure as the positive control; the dummy driver), `controls`
(the classifier's own positive controls and self-test), `timing`.

## Running it

On GitHub's macos-15 runner, `.github/workflows/macos-arm64.yml`'s
`main-thread-startup` job, after its `app` job, on every push: the
downloaded Botlish.app in a path with a space and a non-ASCII letter, the
checkout made inaccessible (`chmod 000`) and PATH the system's (no Rust, no
tclsh), the harness copied out of the checkout first:

```sh
python3 -I acceptance.py --work "$RUNNER_TEMP/mts-app" --out results-app \
  --sdl-prefix ~/Library/Caches/botlish-sdl3-static --app "$APP" --repeat 10
```

then, the checkout restored, its own linkers (`--checkout "$PWD" --tclsh
tclsh9.0 --only identity,lc-main,report,semantics,graphical`). The static
SDL3 is `tests/platform/link-plan-sdl3.sh`'s.

On Linux the same harness is a dry run of its plumbing, never evidence about
macOS: every main-thread executable is refused when it is built (NATIVE
UNSUPPORTED startup, predicted), and the graphical cases run with SDL's dummy
driver. With a static SDL3 3.4.18 built with `-DSDL_STATIC=ON
-DSDL_SHARED=OFF -DSDL_UNIX_CONSOLE_BUILD=ON`:

```sh
python3 -I audit/main-thread-startup/tools/acceptance.py --work /tmp/mw --out /tmp/mr \
  --sdl-prefix /tmp/sdl-prefix --checkout "$PWD" --repeat 2
```
