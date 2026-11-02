# audit/macos-graphical-main-thread

The probes of MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md (`docs/`): how an
AOT-compiled Botlish application can take part in macOS's graphical
main-thread model. Nothing here is part of the compiler, the runtime or the
standard library, and nothing in them loads it.

| what | where |
|---|---|
| the observation fixture: thread identity (pthread_main_np, NSThread, thread ids), stacks, time, thread counts; SDL's error, driver, renderer and window, a window capture | `native/mtprobe.c`, `native/mtprobe_sdl.c` |
| candidate B's dispatcher client (each SDL call one request run on the main thread by the experimental runtime), SDL_RunOnMainThread's callback, a deadlock watchdog | `native/mtdispatch.c` |
| the C controls: the SDL3 lifecycle on the main thread and on a joined worker, SDL_RunOnMainThread with and without a pumping main thread, AppKit directly, the positive controls | `native/csdl.c`, `native/appkit.m` |
| SDL3's main callbacks (candidate C), optionally calling an exported Botlish function | `native/csdl_callbacks.c` |
| the main thread's stack under Apple ld's `-stack_size` (LC_MAIN) | `native/mainstack.c` |
| the graphical session as CoreGraphics reports it | `native/session.c` |
| a plain Rust `main`'s thread identity | `native/identity.rs` |
| the Botlish programs: identity, the SDL3 lifecycle (every SDL operation a Botlish call), recursion depths and overflows, kept coroutines, a coroutine overflow, a non-stack fault, the dispatcher client, SDL_RunOnMainThread's deadlock | `programs/*.bot`, `programs/probe.bot.in`, `programs/mtd.bot.in` |
| the disposable experimental runtime: `aot::run` on the main thread (candidate A) or serving a worker's requests (candidate B), selected per run by `BOTLISH_EXPERIMENT_THREAD`; `-stack_size` at link time by `BOTLISH_EXPERIMENT_MAIN_STACK` | `patches/main-thread-experiment.patch` |
| the harness: builds, runs every case under a timeout, classifies | `tools/census.py` |
| the native library through SDL3's callbacks (Linux, headless) | `tools/library-callbacks.sh` |
| recorded outcomes: each macOS run's census output (timestamps removed), the Linux run's outcomes and summary, the library-callbacks transcript | `results/macos-aarch64/run-RUN.log`, `results/linux-x86_64/` |

Since MAIN-THREAD-STARTUP-MILESTONE-1.md candidate A is the production
startup policy, and the harness runs it on that: the programs built by the
same compiler with `-native-startup main-thread` (Botlish.app's system
linker), by the checkout's rustc linker, and an 8 MiB control (the same
main-thread program objects linked without LC_MAIN's stack size). No
experimental runtime is involved in candidate A; `--exp` (the patch, applied
to the census's base commit 7aec2a11, the only one it applies to) serves
candidate B's dispatcher and its controls only. `--strict` makes every case
a requirement: macos-arm64.yml's `main-thread-startup` job runs it so on
every push.

## Running it

On GitHub's macos-15 runner: `.github/workflows/macos-graphical-main-thread.yml`
(pushes that change this directory or the workflow; workflow_dispatch once it
is on the default branch). It builds Botlish.app, static SDL3 through it
(`tests/platform/link-plan-sdl3.sh`), the experimental worktree (at
7aec2a11), and runs:

```sh
python3 -I audit/macos-graphical-main-thread/tools/census.py \
  --work "$RUNNER_TEMP/census" --out census-results \
  --sdl-prefix ~/Library/Caches/botlish-sdl3-static \
  --app dist/Botlish.app --checkout "$PWD" --exp "$EXP" --repeat 10
```

Locally on Linux the same harness is a dry run of its plumbing (no Cocoa:
the "cocoa" cases run with the dummy driver there) and the Linux evidence
the report quotes (the main thread's refused guard, the headless runs):

```sh
git worktree add --detach /tmp/exp 7aec2a118768f651d1401166cf1d1e596113ae1a
git -C /tmp/exp apply "$PWD/audit/macos-graphical-main-thread/patches/main-thread-experiment.patch"
cargo build --release --manifest-path /tmp/exp/native/Cargo.toml
# a static SDL3 3.4.18 (cmake -DSDL_STATIC=ON -DSDL_SHARED=OFF -DSDL_UNIX_CONSOLE_BUILD=ON ...)
python3 -I audit/macos-graphical-main-thread/tools/census.py --work /tmp/cw --out /tmp/cr \
  --sdl-prefix /tmp/sdl-prefix --checkout "$PWD" --exp /tmp/exp --repeat 2
```

Never apply the patch to this checkout: it is an experiment's, not a
runtime change (the census's non-goals).
