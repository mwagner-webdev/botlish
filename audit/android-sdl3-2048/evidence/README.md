# Emulator evidence

What the `android sdl3 2048` workflow's run 9 (43760740709, at commit
a1256dd1) left of its acceptance on the two emulator images, kept beside
the harness that made it (RN-BOTLISH-ANDROID-SDL3-2048-PACKAGE-MILESTONE-1.md,
section 18): each script's `summary.txt` and its screenshots (`screencap`,
checked cell by cell by `../tools/screen.py`).

* `run9-4k/`: `sdk_gphone64_x86_64`, API 34, 4 KiB pages.
* `run9-16k/`: `sdk_gphone16k_x86_64`, API 35, 16 KiB pages.

Both are x86_64 images: the applications' arm64-v8a code ran through
Android's native bridge (`libndk_translation.so`), translated -- not on
native ARM hardware. In each: `counter/` (acceptance-counter.sh),
`2048/` (acceptance-2048.sh with build.sh's game-test.apk) and
`cleanroom/` (the same script with the clean room's game-test.apk). The
full logs (logcat, input dumps, threads) are the run's artifacts.
