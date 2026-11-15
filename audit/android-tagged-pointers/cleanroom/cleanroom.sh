#!/usr/bin/env bash
# cleanroom.sh -- the tagged-pointer probe from the distributed compiler and
# installed packages alone (RN-ANDROID-TAGGED-POINTER-CORRECTNESS-
# MILESTONE-1.md, "Cleanroom"): no checkout, no source tree, no development
# driver, no undeclared cache.
#
#   ANDROID_NDK_ROOT=NDK cleanroom.sh BOTLISH REPO ROOTS RESULTS [SDL3 BINDING]
#
# BOTLISH is the single-file compiler (single/build.sh's single/out/botlish),
# copied into a fresh directory and run with an emptied environment (PATH
# /usr/bin:/bin, a fresh HOME): it finds nothing of this repository. REPO
# holds the Android target support package it installs
# (audit/android-aarch64-target/tools/package.sh's OUT/repo, packed for this
# compiler's runtime ABI), ROOTS the Android userspaces
# (audit/android-aarch64-target/tools/sysroot.sh's OUT, apex.sh's i18n APEX
# in the newest). The probe's sources -- the C side, the entries, the host --
# and the userspace runner are copied into the room first, as a developer
# would have them (the files of this experiment's android/, the earlier
# milestone's liblog IO, reproducer and host, android-run.sh); with SDL3 (a
# directory holding Android's libSDL3.so) and BINDING (the committed
# android-aarch64 binding staged: `tools/c-bindgen.tcl stage sdl3 -target
# android-aarch64`'s sdl3/), the SDL3 probe too. probe.sh (beside this
# script's parent, copied into the room) then builds and runs everything
# with the room's compiler, in the room. Its summary and every run's output
# go to RESULTS.
set -euo pipefail
usage="usage: cleanroom.sh BOTLISH REPO ROOTS RESULTS [SDL3 BINDING]"
botlish_in=$(realpath "${1:?$usage}")
repo=$(realpath "${2:?$usage}")
roots=$(realpath "${3:?$usage}")
results=$(realpath -m "${4:?$usage}")
sdl=${5:+$(realpath "$5")}
binding=${6:+$(realpath "$6")}
ndk=${ANDROID_NDK_ROOT:?cleanroom.sh: set ANDROID_NDK_ROOT to the Android NDK}
here=$(cd "$(dirname "$0")" && pwd)
experiment=$(dirname "$here")
checkout=$(cd "$experiment/../.." && pwd)
room=$(mktemp -d)
trap 'rm -rf "$room"' EXIT
mkdir -p "$results" "$room/bin" "$room/home" "$room/src" "$room/tools"
cp "$botlish_in" "$room/bin/botlish"
cp "$experiment/android/"{tp.c,tp.bot,tagged.bot,heap.bot,sdl_surface.bot,stdio_io.bot} "$room/src/"
cp "$checkout/audit/host-startable-library/android/"{android_log.bot,hello.bot,host_main.c} "$room/src/"
cp "$checkout/audit/android-aarch64-target/tools/android-run.sh" "$experiment/tools/probe.sh" "$room/tools/"
clean=(env -i PATH=/usr/bin:/bin HOME="$room/home" LANG=C.utf8 LC_ALL=C.utf8 ANDROID_NDK_ROOT="$ndk"
    PROBE_SOURCES="$room/src" PROBE_RUN="$room/tools/android-run.sh")
if [[ -n $sdl && -n $binding ]]; then
    clean+=(SDL3_ANDROID="$sdl" SDL3_BINDING="$binding")
fi
log="$results/cleanroom.txt"
{
    echo "== the compiler: $("${clean[@]}" "$room/bin/botlish" -version | head -n 1)"
    cd "$room"
    "${clean[@]}" bash "$room/tools/probe.sh" "$room/out" "$repo" "$roots" "$room/bin/botlish"
} 2>&1 | tee "$log"
cp -r "$room/out/runs" "$results/runs"
cp "$room/out/libraries.txt" "$room/out/app/lib/"*.manifest.json "$results/"
