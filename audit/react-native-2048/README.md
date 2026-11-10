# audit/react-native-2048

The evidence of BOTLISH-REACT-NATIVE-2048-PACKAGE-MILESTONE-1.md: the
`botlish_react_native` tool package (integrations/react-native/) turning
Botlish native libraries into React Native New Architecture TurboModule
packages, and a React Native Android app (examples/react-native/app/)
playing 2048 through one of them. Nothing here is part of the compiler, and
the compiler never loads it.

| path | what it is |
|---|---|
| `harness/game_core.cpp` | the host harness of the 2048 package's generated C++ core. It compiles `cpp/BotlishGameCore.cpp` unchanged against the host build of the same library (byte-identical header) and drives it with no JavaScript engine: declared errors and their identities, the number and string rules, ownership counters, thread affinity, the instance lifecycle (destroyed on its own thread only), GC stress, and `play SEED DIRECTIONS` for the oracle comparison |
| `harness/textkit_core.cpp` | the same for the second, unrelated library. It covers Int, Bool, Float64, str and unit, Unicode, embedded NULs, a payload's typed fields and NonFiniteFloat, with both libraries' cores in one process |
| `tools/oracle.tcl SEED DIRECTIONS` | the Botlish interpreter's snapshots of a game, one per line, from the facade's source: what every other run is compared with |
| `tools/build.sh OUT` | checkout to APK. It packs the packages as their authors do, builds the two libraries for android-aarch64 and the host, and runs the tool explicitly. Then `npm pack`, the host harnesses (also under `BOTLISH_NATIVE_GC_STRESS=1`), the oracles, the app (`npm ci`, the tarballs, TypeScript, Jest, Gradle's release build, the two device builds) and `inspect-apk.sh` |
| `tools/inspect-apk.sh APK OUT` | what the APK holds, from its bytes. Its ABIs are arm64-v8a only. Each Botlish library is the package's as the Android build strips it, and its code and dynamic symbols are unchanged. Its segments are 16 KiB-aligned and the APK is zip-aligned for 16 KiB pages. `libappmodules.so` needs the libraries and carries no runtime of its own |
| `tools/emulator.sh IMAGE` | boots an Android emulator on a GitHub runner with KVM. It requires the image to run arm64-v8a code (an x86_64 image's native bridge) and states the image's ABIs, API level and page size |
| `tools/android-acceptance.sh APK EXPECTED OUT` | the Android run. The self-test against the interpreter (module and hook), thread identity, mapped libraries, three reloads, GC stress, swipes (a burst, the background), New game, the win and the end on screen, and a clean exit |
| `tools/device-builds.sh DIR OUT` | the device builds (`-PbotlishDevice=plain`, `gc-stress`) as a person uses them, no launch extras: launched from the launcher, the Self-test button, the result on the screen, back to the game; the GC-stress build beside the plain one, and its time per call in the C ABI against the plain build's (GC stress taking effect, or NOT DEMONSTRATED through a native bridge). On a phone over USB it is the GC-stress check on hardware |
| `tools/mutate.tcl`, `tools/mutants.txt` | mutation testing: each mutant killed by a named test of `tests/react-native-package.test` |
| `cleanroom/cleanroom.sh BOTLISH REPO RESULTS` | the clean room: the single-file compiler and the published packages, under strace, then npm, Codegen and Gradle with the app's own pinned dependencies |
| `results/` | observed outputs (committed) |

Reproduce (a Linux x86-64 host: Tcl 9, Rust 1.95+, the Android NDK r28+,
the Android SDK, Node 22, Java 17+, a C and C++ compiler, CMake):

    cargo build --release --manifest-path native/Cargo.toml
    ANDROID_NDK_ROOT=... ANDROID_HOME=... audit/react-native-2048/tools/build.sh /tmp/rn2048
    ANDROID_NDK_ROOT=... BOTLISH_RN_PACKAGES=/tmp/rn2048/repo BOTLISH_RN_APP=/tmp/rn2048/app \
        tclsh9.0 tests/react-native-package.test
    ANDROID_NDK_ROOT=... BOTLISH_RN_PACKAGES=/tmp/rn2048/repo BOTLISH_RN_APP=/tmp/rn2048/app \
        tclsh9.0 audit/react-native-2048/tools/mutate.tcl
    single/build.sh
    ANDROID_NDK_ROOT=... ANDROID_HOME=... JAVA_HOME=... \
        audit/react-native-2048/cleanroom/cleanroom.sh single/out/botlish /tmp/rn2048/repo /tmp/rn2048-cleanroom

and, on a machine with an Android emulator or device:

    audit/react-native-2048/tools/android-acceptance.sh /tmp/rn2048/app-release.apk /tmp/rn2048 /tmp/rn2048-android
    ANDROID_HOME=... audit/react-native-2048/tools/device-builds.sh /tmp/rn2048 /tmp/rn2048-device

The device builds alone, for a phone without adb, from a prepared app:

    (cd /tmp/rn2048/app/android && ./gradlew assembleRelease -PbotlishDevice=gc-stress)

(`.github/workflows/react-native-2048.yml` runs `build.sh`, the clean room,
the acceptance and `device-builds.sh` on GitHub's runners.)
