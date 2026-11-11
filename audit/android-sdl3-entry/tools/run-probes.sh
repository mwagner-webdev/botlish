#!/usr/bin/env bash
# run-probes.sh -- reproduces the probes of
# ANDROID-SDL3-NATIVE-APPLICATION-ENTRY-CENSUS-MILESTONE-1.md.
#
#   audit/android-sdl3-entry/tools/run-probes.sh [PART...]
#
# PART is a, c, f, d or e (default: every part whose tools are present).
#
#   a  the native-library rules a host-started application meets today:
#      each probes/a program compiled with -emit-native-library; prints the
#      diagnostics (no toolchain beyond the checkout's)
#   c  a host-driven instance: the React Native 2048 facade as a host
#      library, probes/c/host_driven.c timing `move` and calling from a
#      foreign thread (cc)
#   f  an ordinary entry program run inside a library instance on a host
#      thread: probes/f, built by a scratch worktree with
#      probes/scratch-tree.patch applied (LIBRARY-TOP-LEVEL lifted); the
#      checkout itself is never changed (cc)
#   d  Icy Tower's unchanged modules as that entry, started through
#      SDL_RunApp on a thread named SDLThread, every SDL call's thread
#      recorded (cc; SDL3 from tests/cffi/sdl3.tcl, built if missing)
#   e  the same application linked for android-aarch64 against an Android
#      SDL3 and the SDL_main shim beside it, inspected from its bytes
#      (ANDROID_NDK_ROOT; BOTLISH_ANDROID_REPO, a directory holding
#      botlish_target_android_aarch64-0.1.0.botpkg made by
#      audit/android-aarch64-target/tools/package.sh; SDL3's pinned source,
#      `tools/c-bindgen.tcl fetch sdl3`, built for Android here)
#
# Scratch files live in a `mktemp -d` directory removed at the end; the
# scratch worktree is removed with it.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
audit=$(dirname "$here")
root=$(cd "$audit/../.." && pwd)
probes=$audit/probes
export LANG=C.utf8 LC_ALL=C.utf8
parts=("$@")
[[ ${#parts[@]} -gt 0 ]] || parts=(a c f d e)
work=$(mktemp -d)
tree=""
cleanup() {
    if [[ -n $tree ]]; then git -C "$root" worktree remove --force "$tree" >/dev/null 2>&1 || true; fi
    rm -rf "$work"
}
trap cleanup EXIT
botlish=(tclsh9.0 "$root/main.tcl")
step() { printf '\n== %s\n' "$*"; }
hide() { sed -e "s|$work|WORK|g" -e "s|$root/||g"; }

scratch_tree() {
    [[ -n $tree ]] && return
    tree=$work/tree
    git -C "$root" worktree add -q --detach "$tree" HEAD
    git -C "$tree" apply "$probes/scratch-tree.patch"
    rm -rf "$tree/native/target"
    ln -s "$root/native/target" "$tree/native/target"
}

part_a() {
    step "A: the native-library rules (the checkout as it is)"
    for f in "$probes"/a/a*.bot; do
        name=p$(basename "$f" | cut -c2)
        echo "-- $(basename "$f")"
        "${botlish[@]}" -emit-native-library "$name" -out "$work/a" "$f" 2>&1 | grep -v '^help:' | hide || true
    done
}

part_c() {
    step "C: a host-driven instance (the React Native 2048 facade)"
    mkdir -p "$work/c/app"
    cp "$root/examples/react-native/2048/game.bot" "$root/examples/games/2048/game2048.bot" "$work/c/app/"
    (cd "$work/c/app" && "${botlish[@]}" -warnings error -emit-native-library game -out ../lib game.bot >/dev/null)
    cc -O2 -Wall -Wextra -Werror -I "$work/c/lib" -o "$work/c/host_driven" "$probes/c/host_driven.c" \
        -L "$work/c/lib" -lgame -Wl,-rpath,"$work/c/lib" -pthread
    "$work/c/host_driven" 20000
}

part_f() {
    step "F: an entry program inside a library instance (scratch tree: LIBRARY-TOP-LEVEL lifted)"
    scratch_tree
    mkdir -p "$work/f"
    cp "$probes"/f/f*.bot "$work/f/"
    for p in f1 f2; do
        (cd "$work/f" && tclsh9.0 "$tree/main.tcl" -warnings error -emit-native-library $p -out lib $p-*.bot >/dev/null)
        cc -O1 -Wall -Wextra -Werror -I "$work/f/lib" -DENTRY_HEADER="\"$p.h\"" "-DENTRY_PREFIX(x)=${p}_##x" \
            -o "$work/f/host_$p" "$probes/f/host_thread.c" -L "$work/f/lib" -l$p -Wl,-rpath,"$work/f/lib" -pthread
    done
    echo "-- f1 on a 1 MiB host thread"; "$work/f/host_f1" 1024
    echo "-- f2 on a 1 MiB host thread"; "$work/f/host_f2" 1024
}

part_d() {
    step "D: Icy Tower's modules as the entry, started through SDL_RunApp on SDLThread"
    scratch_tree
    local sdl src
    sdl=$(tclsh9.0 "$root/tests/cffi/sdl3.tcl" | tail -n 1)
    src=$(tclsh9.0 "$root/tools/c-bindgen.tcl" fetch sdl3 | tail -n 1)
    mkdir -p "$work/d/src"
    cp "$root"/examples/games/icy-tower/{game,sdl,render,hud,tower,options}.bot "$probes/d/d1-icy-entry.bot" "$work/d/src/"
    tclsh9.0 "$root/tools/c-bindgen.tcl" stage sdl3 -target linux-x86_64 -app "$work/d/src" -into "$work/d/app" -package 1 >/dev/null
    (cd "$work/d/app" && tclsh9.0 "$tree/main.tcl" -warnings error -emit-native-library icy -L "$sdl" -out lib d1-icy-entry.bot >/dev/null)
    cc -O1 -Wall -Wextra -I "$work/d/app/lib" -I "$sdl/include" -I "$src/include" -o "$work/d/bootstrap" \
        "$probes/d/sdl_bootstrap.c" -L "$work/d/app/lib" -licy -L "$sdl" -lSDL3 -Wl,-rpath,"$work/d/app/lib" -pthread
    cc -O1 -shared -fPIC -o "$work/d/observer.so" "$probes/d/sdl_threads.c" -ldl -pthread
    SDL_VIDEO_DRIVER=dummy LD_LIBRARY_PATH=$sdl LD_PRELOAD=$work/d/observer.so "$work/d/bootstrap" 2>&1
    echo "-- the committed executable, the same seed"
    SDL_VIDEO_DRIVER=dummy LD_LIBRARY_PATH=$sdl "$root/audit/icy-tower/artifacts/icy-tower" --autopilot --fixed-step --frames 600 --seed 17
}

part_e() {
    step "E: the application for android-aarch64 (scratch tree), inspected"
    : "${ANDROID_NDK_ROOT:?part e: set ANDROID_NDK_ROOT}" "${BOTLISH_ANDROID_REPO:?part e: set BOTLISH_ANDROID_REPO}"
    scratch_tree
    local src bin
    src=$(tclsh9.0 "$root/tools/c-bindgen.tcl" fetch sdl3 | tail -n 1)
    bin=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin
    cmake -S "$src" -B "$work/e/sdl" -G Ninja -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-21 -DCMAKE_BUILD_TYPE=Release -DSDL_SHARED=ON -DSDL_STATIC=OFF \
        -DSDL_TEST_LIBRARY=OFF -DSDL_TESTS=OFF >/dev/null
    ninja -C "$work/e/sdl" >/dev/null
    mkdir -p "$work/e/src"
    cp "$root"/examples/games/icy-tower/{game,sdl,render,hud,tower,options}.bot "$probes"/e/*.bot "$work/e/src/"
    # No android-aarch64 SDL3 binding can be generated (tools/cheader has no
    # Android triple): the linux-aarch64 one stands in, same data model.
    tclsh9.0 "$root/tools/c-bindgen.tcl" stage sdl3 -target linux-aarch64 -app "$work/e/src" -into "$work/e/app" -package 1 >/dev/null
    cd "$work/e/app"
    printf '{"schema": 1, "dependencies": {}}\n' > botlish.json
    tclsh9.0 "$tree/main.tcl" add botlish_target_android_aarch64 -repository "$BOTLISH_ANDROID_REPO" -target android-aarch64 >/dev/null
    echo "-- probe E2 on the checkout as it is (a cross-target library with a link plan)"
    "${botlish[@]}" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
        -emit-native-library e2 -out e2lib e2-link-plan-cross.bot 2>&1 | grep -v '^help:' | hide || true
    tclsh9.0 "$tree/main.tcl" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
        -emit-native-library icy -L "$work/e/sdl" -out lib e1-icy-android-entry.bot | hide
    "$bin/aarch64-linux-android21-clang" -O2 -Wall -Wextra -Werror -fPIC -shared -Wl,-z,max-page-size=16384 -Wl,-z,defs \
        -Wl,-soname,libmain.so -I lib -o libmain.so "$probes/e/android_main.c" -L lib -licy -L "$work/e/sdl" -lSDL3 -llog
    for so in lib/libicy.so libmain.so "$work/e/sdl/libSDL3.so"; do
        echo "-- $(basename "$so")"
        readelf -hdlW "$so" | grep -E 'Machine|NEEDED|SONAME|TEXTREL|LOAD' | hide
        "$bin/llvm-strip" --strip-unneeded -o "$work/e/stripped.so" "$so"
        echo "   bytes $(stat -c %s "$so"), stripped $(stat -c %s "$work/e/stripped.so")"
    done
    echo "-- SDL functions libicy.so imports: $(nm -D --undefined-only lib/libicy.so | grep -c ' SDL_')"
    cd "$root"
}

for part in "${parts[@]}"; do
    case $part in
        a) part_a ;;
        c) part_c ;;
        f) part_f ;;
        d) part_d ;;
        e) part_e ;;
        *) echo "run-probes.sh: unknown part $part (a, c, f, d, e)" >&2; exit 2 ;;
    esac
done
