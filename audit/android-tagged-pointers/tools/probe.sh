#!/usr/bin/env bash
# probe.sh -- the tagged-pointer probe in Android processes
# (RN-ANDROID-TAGGED-POINTER-CORRECTNESS-MILESTONE-1.md, "Android
# execution"), from installed packages and a compiler command only:
#
#   ANDROID_NDK_ROOT=NDK probe.sh OUT REPO ROOTS BOTLISH...
#
# REPO holds the Android target support package
# (botlish_target_android_aarch64, audit/android-aarch64-target/tools/
# package.sh's OUT/repo); ROOTS the Android userspaces
# (audit/android-aarch64-target/tools/sysroot.sh's OUT: api-N/root);
# BOTLISH... the compiler command (`tclsh9.0 main.tcl` in a checkout, or the
# single-file compiler). In OUT it makes an application -- the package
# installed, the probe's sources (audit/android-tagged-pointers/android and
# the earlier milestone's liblog IO and host) beside it, tp.c built by the
# NDK into libtp.a -- builds the application libraries hello (the earlier
# milestone's liblog reproducer), heap (a C heap pointer, no exposure) and
# tagged (every crossing), and two hosts for each (the second turning
# Bionic's heap pointer tagging off first), and runs every host in every
# userspace, the newest also with 16 KiB pages and under GC stress. Each
# run's output is OUT/runs/API-HOST[-MODE].txt; a summary line per run is
# printed. Nothing is run from the images but the programs built here.
#
# With SDL3_ANDROID=DIR (Android's libSDL3.so: tests/cffi/sdl3.tcl android)
# it also builds sdl_surface (SDL3's surfaces over the committed
# android-aarch64 binding, staged as the sdl3 package with this checkout's
# tools/c-bindgen.tcl) and runs it in every userspace whose ICU the library
# can load (libSDL3 needs libandroid, which on Android 10 and later needs
# the i18n APEX's ICU: apex.sh); one whose libraries cannot load is
# reported as not run, with the library the linker did not find.
#
# Outside a checkout (the clean room: cleanroom/cleanroom.sh) PROBE_SOURCES
# names a directory holding the probe's sources (this experiment's android/
# and the earlier milestone's android_log.bot, hello.bot and host_main.c),
# PROBE_RUN the userspace runner (audit/android-aarch64-target/tools/
# android-run.sh) and SDL3_BINDING a directory staged from the committed
# binding (`tools/c-bindgen.tcl stage sdl3 -target android-aarch64`'s sdl3/),
# copied into the application in place of staging it.
set -euo pipefail
out=$(realpath -m "${1:?usage: probe.sh OUT REPO ROOTS BOTLISH...}")
repo=$(realpath "${2:?usage: probe.sh OUT REPO ROOTS BOTLISH...}")
roots=$(realpath "${3:?usage: probe.sh OUT REPO ROOTS BOTLISH...}")
shift 3
botlish=("$@")
[[ ${#botlish[@]} -gt 0 ]] || { echo "usage: probe.sh OUT REPO ROOTS BOTLISH..." >&2; exit 2; }
here=$(cd "$(dirname "$0")" && pwd)
experiment=$(dirname "$here")
root=$(cd "$experiment/../.." && pwd)
ndk=${ANDROID_NDK_ROOT:?probe.sh: set ANDROID_NDK_ROOT to the Android NDK}
bin="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin"
run=${PROBE_RUN:-$root/audit/android-aarch64-target/tools/android-run.sh}
sources=${PROBE_SOURCES:-}

app="$out/app"
rm -rf "$out"
mkdir -p "$app" "$out/runs"
printf '{"schema": 1, "dependencies": {}}\n' >"$app/botlish.json"
(cd "$app" && "${botlish[@]}" add botlish_target_android_aarch64 -repository "$repo" -target android-aarch64 >/dev/null)
if [[ -n $sources ]]; then
    cp "$sources"/{android_log.bot,hello.bot,host_main.c,tp.c,tp.bot,tagged.bot,heap.bot,sdl_surface.bot,stdio_io.bot} "$app/"
else
    cp "$root/audit/host-startable-library/android/android_log.bot" "$root/audit/host-startable-library/android/hello.bot" \
        "$root/audit/host-startable-library/android/host_main.c" "$experiment/android/"{tp.c,tp.bot,tagged.bot,heap.bot,sdl_surface.bot,stdio_io.bot} "$app/"
fi
"$bin/clang" --target=aarch64-linux-android21 -std=c11 -O2 -Wall -Wextra -Werror -fPIC -fvisibility=hidden -c -o "$app/tp.o" "$app/tp.c"
"$bin/llvm-ar" rcs "$app/libtp.a" "$app/tp.o"
for name in hello heap tagged; do
    (cd "$app" && "${botlish[@]}" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
        -emit-native-library "$name" -application -out lib "$name.bot" >/dev/null)
    "$bin/clang" --target=aarch64-linux-android21 -std=c11 -O2 -Wall -Wextra -Werror "-DAPP_HEADER=\"$name.h\"" \
        "-DAPP_PREFIX=$name" -I "$app/lib" -o "$app/lib/${name}_host" "$app/host_main.c" -L "$app/lib" "-l$name" -ldl
    "$bin/clang" --target=aarch64-linux-android21 -std=c11 -O2 -Wall -Wextra -Werror -DNO_HEAP_POINTER_TAGGING \
        "-DAPP_HEADER=\"$name.h\"" "-DAPP_PREFIX=$name" -I "$app/lib" -o "$app/lib/${name}_untagged" "$app/host_main.c" \
        -L "$app/lib" "-l$name" -ldl
done
sdl=${SDL3_ANDROID:-}
if [[ -n $sdl ]]; then
    if [[ -n ${SDL3_BINDING:-} ]]; then
        cp -r "$SDL3_BINDING" "$app/sdl3"
    else
        src=$(mktemp -d)
        cp "$app/sdl_surface.bot" "$src/"
        tclsh9.0 "$root/tools/c-bindgen.tcl" stage sdl3 -target android-aarch64 -app "$src" -into "$app" >/dev/null
        rm -rf "$src"
    fi
    (cd "$app" && "${botlish[@]}" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
        -emit-native-library sdl_surface -application -L "$sdl" -out lib sdl_surface.bot >/dev/null)
    for variant in host untagged; do
        defines=()
        [[ $variant == untagged ]] && defines=(-DNO_HEAP_POINTER_TAGGING)
        "$bin/clang" --target=aarch64-linux-android21 -std=c11 -O2 -Wall -Wextra -Werror "${defines[@]}" \
            '-DAPP_HEADER="sdl_surface.h"' -DAPP_PREFIX=sdl_surface -I "$app/lib" -o "$app/lib/sdl_surface_$variant" \
            "$app/host_main.c" -L "$app/lib" -lsdl_surface -L "$sdl" -lSDL3 -ldl
    done
    cp "$sdl/libSDL3.so" "$app/lib/"
fi
sha256sum "$app"/lib/lib*.so | sed "s|$app/||" >"$out/libraries.txt"

# Runs HOST in the userspace API with ARGS for android-run.sh; FILE gets its
# output, the summary its MAIN lines and the probe's heap/exposure lines.
probe() {
    local api=$1 host=$2 file=$3
    shift 3
    local status=0
    "$run" "$@" "$roots/api-$api/root" "$app/lib/$host" >"$out/runs/$file.txt" 2>&1 || status=$?
    local mains
    mains=$(grep -a '^MAIN' "$out/runs/$file.txt" | tr '\t' ' ' | tr '\n' ';' || true)
    local seen
    seen=$(grep -a -E '^(exposure|heap|sdl surface|sdl fill) ' "$out/runs/$file.txt" | head -n 2 | tr '\n' ';' || true)
    echo "$file exit=$status $mains $seen"
}

for dir in "$roots"/api-*; do
    api=${dir##*/api-}
    for name in hello heap tagged; do
        probe "$api" "${name}_host" "$api-$name"
        probe "$api" "${name}_untagged" "$api-$name-untagged"
    done
done
if [[ -n $sdl ]]; then
    for dir in "$roots"/api-*; do
        api=${dir##*/api-}
        for variant in host untagged; do
            file=$api-sdl_surface
            [[ $variant == host ]] || file=$file-untagged
            line=$(probe "$api" "sdl_surface_$variant" "$file")
            if grep -q 'CANNOT LINK EXECUTABLE' "$out/runs/$file.txt"; then
                echo "$file not run: $(grep -a -o 'library "[^"]*" not found[^"]*' "$out/runs/$file.txt" | head -n 1) (apex.sh's APEXes)"
            else
                echo "$line"
            fi
        done
    done
fi
newest=$(ls -d "$roots"/api-* | sort -t- -k2 -n | tail -n 1)
newest=${newest##*/api-}
probe "$newest" tagged_host "$newest-tagged-16k" -p 16384
BOTLISH_NATIVE_GC_STRESS=1 probe "$newest" tagged_host "$newest-tagged-gc-stress"
