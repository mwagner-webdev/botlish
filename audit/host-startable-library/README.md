# audit/host-startable-library

Material of RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md (docs/):
host-startable application libraries (`-emit-native-library NAME
-application`, `NAME_main`), cross-target native link plans and the C binding
generator's android-aarch64 target.

| Path | What |
|---|---|
| `sdl/sdl_runapp_host.c` | a Linux host shaped like SDL3's Android bootstrap: a 1 MiB thread named SDLThread, `SDL_RunApp`, an `SDL_main` calling `NAME_main` (tests/application-library.test's `al-icy-tower-sdl-runapp`) |
| `sdl/sdl_threads.c` | an `LD_PRELOAD` observer of the SDL calls an application makes: how often, on which threads |
| `android/android_log.bot` | an application-owned `std::io::IO` over liblog (no standard namespace is Android's) |
| `android/hello.bot` | the smallest Android application library: its own IO, a context holding state, argv |
| `android/icy-android.bot` | Icy Tower's entry for android-aarch64 (main.bot with Android's IO) |
| `android/co.bot` | an entry that runs a coroutine (the runtime's per-thread stack pool) |
| `android/sdl_main.c` | the `SDL_main` shim an APK would carry, generic over the library's prefix |
| `android/host_main.c` | an Android process (no ART) that runs `NAME_main` on an SDLThread-shaped thread, twice; `-DNO_HEAP_POINTER_TAGGING` turns Bionic's heap pointer tagging off first |
| `android/host_dlclose.c` | the dynamic loader's lifetime rule: the library unloaded while the thread that called it lives (`unload`), kept by a second handle (`kept`), pinned (`nodelete`) |
| `cleanroom/cleanroom.sh` | the clean room: the single-file compiler alone builds and runs an application library (Linux) and builds one for android-aarch64 from the target support package's repository |
| `cleanroom/validate-manifest.py` | an external tool's view of an application library: the manifest and the bytes, nothing of the compiler |
| `tools/mutants.txt`, `tools/mutate.tcl` | the mutation catalog and its harness (each mutant names the tests that must kill it) |

The fixtures are test infrastructure: nothing here is loaded by the compiler,
and none of it is an Android or SDL integration package (the next milestone's,
outside the core).
