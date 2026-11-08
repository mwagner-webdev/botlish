# audit/android-aarch64-target

The evidence of ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md: Botlish native
libraries for Android AArch64, emitted from a Linux x86-64 host by the
distributed compiler and linked with an independently packaged Android
runtime, loaded and run by Android's own dynamic linker and Bionic.

| path | what it is |
|---|---|
| `package/botlish_target_android_aarch64/botlish.json` | the target support package's declaration (target-aware, its `android-aarch64` view holds the runtime archive and its schema 2 descriptor) |
| `tools/package.sh OUT BOTLISH...` | the author's side: builds the runtime for `aarch64-linux-android` with cargo and the NDK (`ANDROID_NDK_ROOT`), checks its identity record against the driver's runtime ABI, writes the descriptor, packs it and the 2048 engine package into `OUT/repo`, records the inputs in `OUT/build.txt` |
| `tools/sysroot.sh OUT [API...]` | Android userspaces: Google's arm64-v8a system images (API 21, 24, 35) downloaded, checked against their pinned SHA-1, unpacked into `OUT/api-N/root` (`lpunpack.py` for the dynamic-partition image, `relink.py` for absolute links) |
| `tools/android-run.sh [-p PAGESIZE] ROOT PROGRAM ARG...` | runs an Android AArch64 program under qemu-aarch64 with ROOT's `/system/bin/linker64` and Bionic; `-p 16384` presents 16 KiB pages |
| `tools/parity.tcl` | the 2048 library, played by the Android host, against the interpreter (160 steps, 321 states, the facts, the declared errors) |
| `tools/mutate.tcl`, `tools/mutants.txt` | mutation testing: each mutant killed by a named test of `tests/android-target.test` |
| `host/host2048.c` | the Android host: dlopen of the library, its C ABI driven as its header and manifest state (`play`, `lifecycle N`, `thread`) |
| `host/stress.c`, `stress/stress.bot` | the runtime workloads: large and astral-plane strings, nested Lists of structs, a growing MutableVector, many allocations, an error with a payload |
| `cleanroom/cleanroom.sh` | the clean room: the single-file compiler, the packed packages, the NDK and the Android userspaces only, under strace |
| `results/` | observed outputs (committed) |

What the execution evidence is: Android's userspace -- `linker64`, `libc.so`,
`libdl.so`, `libm.so`, `liblog.so` from Google's own system images -- loading
and running the program and the library, under qemu-aarch64's user-mode
emulation on the Linux x86-64 host's kernel. It is not an Android device or
emulator: no Android kernel, zygote, ART, property service or SELinux.

Reproduce (a Linux x86-64 host with Tcl 9, Rust 1.95+, qemu-user, debugfs,
unzip and python3):

    export ANDROID_NDK_ROOT=/path/to/android-ndk-r29
    cargo build --release --manifest-path native/Cargo.toml
    audit/android-aarch64-target/tools/package.sh /tmp/android-pkg tclsh9.0 main.tcl
    audit/android-aarch64-target/tools/sysroot.sh /tmp/android-roots
    BOTLISH_ANDROID_ROOTS=/tmp/android-roots tclsh9.0 tests/android-target.test
    single/build.sh
    audit/android-aarch64-target/cleanroom/cleanroom.sh single/out/botlish /tmp/android-pkg/repo \
        "$ANDROID_NDK_ROOT" /tmp/android-roots /tmp/android-cleanroom
