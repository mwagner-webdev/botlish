#!/usr/bin/env bash
# measure.sh -- the costs of host-startable application libraries
# (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md, "Performance and
# footprint"), on this checkout's compiler and driver:
#
#   measure.sh RESULTS
#
#   * a NAME_main call of an empty entry (a fresh Vm: made, module
#     initialization, the entry, dropped) against an instance's
#     NAME_create + NAME_destroy of the same library, 2000 each;
#   * an entry with two contexts and a 1000-frame loop, 1000 calls;
#   * 4 threads x 500 calls against 1 thread x 2000 (independent Vms), the
#     process's main thread apart (glibc's pthread_getattr_np reads
#     /proc/self/maps there: every fresh Vm finds its stack's bounds);
#   * the same under BOTLISH_NATIVE_GC_STRESS=1 (200 calls);
#   * the resident memory after 10 and after 2000 calls;
#   * the build: -emit-native-library with and without -application;
#   * Icy Tower, 600 autopilot frames on SDL's dummy driver: the committed
#     executable against main.bot as an application library under
#     SDL_RunApp (needs tests/cffi/sdl3.tcl's libSDL3.so and SDL's pinned
#     headers), five runs each.
#
# Needs cc and bc. Single runs on whatever machine runs it: the report gives each number with
# its machine and treats small differences as noise.
set -euo pipefail
results=$(realpath -m "${1:?usage: measure.sh RESULTS}")
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$(dirname "$results")"
: >"$results"
say() { echo "$*" | tee -a "$results"; }
export LANG=C.utf8 LC_ALL=C.utf8
botlish=(tclsh9.0 "$root/main.tcl")
libs=(-lgcc_s -lutil -lrt -lpthread -lm -ldl -lc)

say "machine: $(nproc) cores, $(uname -m), $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
cd "$work"
cat >empty.bot <<'BOT'
exported c fn version() -> int:
    1

x = 1
BOT
cat >ctx.bot <<'BOT'
import std::mutable_vector

context struct Frames:
    seen: MutableVector[int]

type Step = Int in 1..9

context struct Settings:
    step: Step

fn frames(n: int, total: int, context f: Frames, s: Settings) -> int:
    if n == 0:
        return total
    f.seen.push(n)
    frames(n - 1, total + n * s.step)

with context Frames {seen: std::mutable_vector::from_list([])}
with context Settings {step: 2}

if frames(1000, 0) != 1001000:
    100.mod(0)
BOT
for name in empty ctx; do
    start=$(date +%s.%N)
    "${botlish[@]}" -warnings off -emit-native-library "$name" -application -out "lib$name" "$name.bot" >/dev/null
    end=$(date +%s.%N)
    say "build: -emit-native-library $name -application: $(echo "$end - $start" | bc) s"
done
cat >ordinary.bot <<'BOT'
exported c fn version() -> int:
    1
BOT
start=$(date +%s.%N)
"${botlish[@]}" -warnings off -emit-native-library ordinary -out libordinary ordinary.bot >/dev/null
end=$(date +%s.%N)
say "build: -emit-native-library ordinary (no -application): $(echo "$end - $start" | bc) s"
cat >bench.c <<'C'
#define _GNU_SOURCE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include LIBH
#define JOIN(a, b) a##_##b
#define NAME(a, b) JOIN(a, b)
#define APP(s) NAME(LIBP, s)
static double now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec + t.tv_nsec / 1e9; }
static long rss_kib(void) { FILE *f = fopen("/proc/self/statm", "r"); long a = 0, b = 0; if (fscanf(f, "%ld %ld", &a, &b) != 2) b = 0; fclose(f); return b * 4; }
static int calls;
static void *loop(void *unused) {
    (void)unused;
    char *argv[] = {"bench", NULL};
    for (int i = 0; i < calls; i++) {
        APP(error) *e = NULL;
        if (APP(main)(1, argv, &e) != 0) { fprintf(stderr, "main failed\n"); exit(1); }
    }
    return NULL;
}
int main(int argc, char **argv) {
    int n = atoi(argv[1]);
    const char *mode = argv[2];
    /* A warm-up first: the first calls fault the runtime's pages in. */
    calls = 100;
    if (strcmp(mode, "rss") != 0 && strcmp(mode, "create") != 0) loop(NULL);
    calls = n;
    if (strcmp(mode, "main") == 0) {
        double t0 = now(); loop(NULL); double t1 = now();
        printf("%.1f us per NAME_main\n", (t1 - t0) / n * 1e6);
    } else if (strcmp(mode, "create") == 0) {
        double t0 = now();
        for (int i = 0; i < n; i++) { APP(instance) *in = NULL; APP(error) *e = NULL; APP(create)(&in, &e); APP(destroy)(in); }
        double t1 = now();
        printf("%.1f us per NAME_create + NAME_destroy\n", (t1 - t0) / n * 1e6);
    } else if (strcmp(mode, "threads") == 0) {
        calls = n / 4;
        pthread_t t[4];
        double t0 = now();
        for (int k = 0; k < 4; k++) pthread_create(&t[k], NULL, loop, NULL);
        for (int k = 0; k < 4; k++) pthread_join(t[k], NULL);
        double t1 = now();
        printf("%.1f ms for %d calls on 4 threads\n", (t1 - t0) * 1e3, n);
    } else if (strcmp(mode, "one") == 0) {
        double t0 = now(); loop(NULL); double t1 = now();
        printf("%.1f ms for %d calls on the process's main thread\n", (t1 - t0) * 1e3, n);
    } else if (strcmp(mode, "worker") == 0) {
        pthread_t t;
        double t0 = now(); pthread_create(&t, NULL, loop, NULL); pthread_join(t, NULL); double t1 = now();
        printf("%.1f ms for %d calls on 1 other thread (%.1f us each)\n", (t1 - t0) * 1e3, n, (t1 - t0) / n * 1e6);
    } else if (strcmp(mode, "rss") == 0) {
        calls = 10; loop(NULL); long early = rss_kib();
        calls = n - 10; loop(NULL); long late = rss_kib();
        printf("RSS after 10 calls %ld KiB, after %d calls %ld KiB\n", early, n, late);
    }
    return 0;
}
C
for name in empty ctx; do
    cc -O2 -D"LIBH=\"$name.h\"" -DLIBP="$name" -I "lib$name" -o "bench-$name" bench.c "lib$name/lib$name.a" "${libs[@]}"
done
say "empty entry: $(./bench-empty 2000 main)"
say "empty entry: $(./bench-empty 2000 create)"
say "two contexts, 1000-frame loop: $(./bench-ctx 1000 main)"
say "two contexts: $(./bench-ctx 2000 one)"
say "two contexts: $(./bench-ctx 2000 worker)"
say "two contexts: $(./bench-ctx 2000 threads)"
say "empty entry: $(./bench-empty 2000 worker)"
say "empty entry, GC stress: $(BOTLISH_NATIVE_GC_STRESS=1 ./bench-empty 200 main)"
say "two contexts, GC stress: $(BOTLISH_NATIVE_GC_STRESS=1 ./bench-ctx 200 main)"
say "two contexts: $(./bench-ctx 2000 rss)"
say "library sizes: libempty.a $(stat -c %s libempty/libempty.a), libempty.so $(stat -c %s libempty/libempty.so), libordinary.so $(stat -c %s libordinary/libordinary.so)"

sdl=$(tclsh9.0 "$root/tests/cffi/sdl3.tcl" 2>/dev/null | tail -n 1 || true)
src=$(tclsh9.0 "$root/tools/c-bindgen.tcl" fetch sdl3 2>/dev/null | tail -n 1 || true)
if [[ -f $sdl/libSDL3.so && -f $src/include/SDL3/SDL_main.h ]]; then
    mkdir -p icy/src
    cp "$root"/examples/games/icy-tower/{main,game,sdl,render,hud,tower,options}.bot icy/src/
    tclsh9.0 "$root/tools/c-bindgen.tcl" stage sdl3 -target linux-x86_64 -app icy/src -into icy/app -package 1 >/dev/null
    (cd icy/app && "${botlish[@]}" -warnings error -emit-native-library icy -application -L "$sdl" -out lib main.bot >/dev/null)
    cc -O1 -DAPP_HEADER='"icy.h"' -DAPP_PREFIX=icy -I icy/app/lib -I "$src/include" -o icy/host \
        "$root/audit/host-startable-library/sdl/sdl_runapp_host.c" -L icy/app/lib -licy -L "$sdl" -lSDL3 -Wl,-rpath,"$work/icy/app/lib" -pthread
    args=(--autopilot --fixed-step --frames 600 --seed 17)
    for what in executable library; do
        for i in 1 2 3 4 5; do
            if [[ $what == executable ]]; then
                cmd=("$root/audit/icy-tower/artifacts/icy-tower" "${args[@]}")
            else
                cmd=(icy/host icy-tower "${args[@]}")
            fi
            { TIMEFORMAT='%R %U %S'; time env SDL_VIDEO_DRIVER=dummy LD_LIBRARY_PATH="$sdl" "${cmd[@]}" >/dev/null 2>&1; } 2>time.txt
            say "icy tower 600 frames, $what: wall/user/sys $(cat time.txt)"
        done
    done
else
    say "icy tower: skipped (no package-owned libSDL3.so or SDL headers)"
fi
