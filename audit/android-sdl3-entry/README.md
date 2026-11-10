# audit/android-sdl3-entry

Material of ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md
(docs/): can a foreign SDL3 host -- SDL's Android bootstrap -- start a
Botlish application that installs its own contexts and runs its own loop?

    tools/run-probes.sh [a c f d e]    reproduce the probes; parts as below

| Path | What |
|---|---|
| `probes/a/` | the native-library rules a host-started application meets today: a top-level installation, an export requiring a context, a context parameter, a suspending export, state between calls, C calls from exports (plain and direct) |
| `probes/c/host_driven.c` | a host-driven instance: the React Native 2048 facade timed per call, called from a foreign thread |
| `probes/f/` | an ordinary entry program -- installations, context-owned state, a loop; and one that fails -- run inside a library instance on a host thread (`host_thread.c`) |
| `probes/d/` | Icy Tower's unchanged modules as that entry (`d1-icy-entry.bot`), started through `SDL_RunApp` on a thread named SDLThread (`sdl_bootstrap.c`), every SDL call's thread recorded (`sdl_threads.c`, an `LD_PRELOAD` observer) |
| `probes/e/` | the same application for android-aarch64: an application-owned `std::io::IO` over liblog (`android_log.bot`), the entry (`e1-icy-android-entry.bot`), the `SDL_main` shim an APK would carry (`android_main.c`), and `e2-link-plan-cross.bot`, the smallest cross-target library with a link plan (NATIVE TARGET on the unmodified tree) |
| `probes/scratch-tree.patch` | what probes F, D and E change in a scratch git worktree of the checkout (never the checkout): LIBRARY-TOP-LEVEL lifted; for a cross-target library, the plan's shared libraries by name |
| `results/run-probes-linux-x86_64.txt` | the runner's output, all five parts, on Linux x86-64 |

Probes F, D and E are experiments, not implementations: the scratch patch
removes a check the census recommends replacing by an explicit artifact
option (`-emit-native-library NAME -application` and `NAME_main`), and its
link-plan workaround stands in for the fix the report describes. Nothing
here is loaded by the compiler, the tests or CI.

Requirements: part a, the checkout; c and f, `cc`; d, SDL3 built by
`tests/cffi/sdl3.tcl` (built if missing) and SDL's pinned headers
(`tools/c-bindgen.tcl fetch sdl3`); e, `ANDROID_NDK_ROOT` (r29 was used) and
`BOTLISH_ANDROID_REPO`, a directory holding the Android target support
package that `audit/android-aarch64-target/tools/package.sh` makes, plus
CMake and Ninja (SDL3 is built for Android in the run's scratch directory).
