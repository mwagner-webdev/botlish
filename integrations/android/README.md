# botlish_android

An external tool package (BOTLISH-TOOLS.md, protocol 1): its tool `android`
turns a Botlish **application library** -- an ordinary entry program built
with `-emit-native-library NAME -application` for android-aarch64 -- into an
Android Gradle project whose `SDLActivity` starts it
(RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md).

```
botlish add botlish_android -repository REPO
botlish add sdl3 -repository REPO -target android-aarch64
botlish add botlish_target_android_aarch64 -repository REPO -target android-aarch64
botlish -target android-aarch64 -target-support botlish_target_android_aarch64 \
    -emit-native-library app -application -out lib main.bot
botlish tool -out android -artifact lib/app.manifest.json -target android-aarch64 \
    android generate -application-id org.example.app -name "My App"
(cd android && ./gradlew assembleRelease)      # or: botlish tool ... android build
```

Installing the package runs nothing; `android generate` runs only when named.

## What it checks first

The tool writes nothing before it has checked every fact it relies on, and
refuses (`AN-...` codes) a fact it cannot read:

* the manifest: schema 3 with an `application` member (an ordinary schema 2
  library has no entry: AN-NOT-APPLICATION), target android-aarch64, C ABI 1,
  the entry `int32_t NAME_main(int argc, char **argv, NAME_error **error)` run
  on the calling thread, blocking, to completion; the runtime ABI agreeing
  with the target support package's; native dependencies only Android's
  platform libraries and SDL3 (AN-DEPENDENCY);
* every file's SHA-256 against the manifest;
* the shared object's ELF: AArch64, ET_DYN, 16 KiB LOAD alignment, SONAME
  `libNAME.so`, Android's platform libraries and `libSDL3.so` only, no glibc
  symbol version, no text relocation, `NAME_main` exported;
* the SDL3 package installed in the project for android-aarch64 (`-sdl3
  PACKAGE`, default `sdl3`): its `android/sdl3-android.json`, every file it
  states by SHA-256, its `libSDL3.so` (AArch64, 16 KiB, SONAME, SDL's revision
  of the stated version) and its binding's `SDL_VERSION`, which must agree.

## What it generates

An ordinary Gradle project (Android Gradle Plugin 8.7.3, Gradle 8.12 pinned by
SHA-256, compileSdk/targetSdk 35, minSdk the library's and SDL's API level or
`-android-api`, arm64-v8a only):

* `MainActivity extends SDLActivity` (`-activity`), naming its libraries --
  `SDL3`, the application library, `main` -- and nothing else; with
  `-intent-arguments` (a test configuration) the launching intent's string
  array extra `org.botlish.android.ARGUMENTS` becomes the program's arguments;
* `app/src/main/cpp/main.c`, the `SDL_main` shim: it calls `NAME_main` and
  logs the outcome (tag `botlish-android`), and once the API level and whether
  the heap allocator tags pointers; `CMakeLists.txt` imports the two libraries
  by their recorded SHA-256 and builds `libmain.so` 16 KiB-aligned;
* SDL's Java classes, resources, ProGuard rules, Gradle wrapper and license
  from the SDL3 package; the manifest from SDL's template;
* `botlish-android.json`, the record of the inputs and of every file written
  (`-replace` regenerates over exactly those).

`-packaging uncompressed` (default) stores the libraries page-aligned in the
APK; `-packaging extracted` compresses them and has the installer extract
them. `-assets DIR` copies an application's assets (regular files only).

The tool knows no application: no names, methods or game rules are built in.
