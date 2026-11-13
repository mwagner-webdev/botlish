#!/usr/bin/env bash
# cleanroom.sh -- host-startable application libraries from the distributed
# compiler alone (RN-HOST-STARTABLE-APPLICATION-LIBRARY-MILESTONE-1.md,
# "Cleanroom"): no checkout, no source tree, no development driver, no
# undeclared cache.
#
#   cleanroom.sh BOTLISH RESULTS [REPO]
#
# BOTLISH is the single-file compiler (single/build.sh's single/out/botlish),
# copied into a fresh directory and run with an emptied environment (PATH
# /usr/bin:/bin, a fresh HOME): it finds nothing of this repository. The
# application and its C host are written here, as a developer would write
# them. Linux: the entry program -- two contexts, state, a loop, argv --
# built with -emit-native-library app -application, a C host calling
# app_main on a 1 MiB thread, its output; validate-manifest.py (beside this
# script: an external tool reading only the manifest and the bytes) on the
# manifest. Android, when REPO (a repository holding the Android target
# support package, audit/android-aarch64-target/tools/package.sh's OUT/repo)
# and ANDROID_NDK_ROOT are given: the package added from REPO, an
# application library of android-aarch64 over liblog, its ELF facts and its
# manifest. Everything is written to RESULTS.
set -euo pipefail
botlish_in=$(realpath "${1:?usage: cleanroom.sh BOTLISH RESULTS [REPO]}")
results=$(realpath -m "${2:?usage: cleanroom.sh BOTLISH RESULTS [REPO]}")
repo=${3:+$(realpath "$3")}
here=$(cd "$(dirname "$0")" && pwd)
room=$(mktemp -d)
trap 'rm -rf "$room"' EXIT
mkdir -p "$results" "$room/bin" "$room/home" "$room/linux"
cp "$botlish_in" "$room/bin/botlish"
clean=(env -i PATH=/usr/bin:/bin HOME="$room/home" LANG=C.utf8 LC_ALL=C.utf8)
[[ -n ${ANDROID_NDK_ROOT:-} ]] && clean+=(ANDROID_NDK_ROOT="$ANDROID_NDK_ROOT")
botlish=("${clean[@]}" "$room/bin/botlish")
log="$results/cleanroom.txt"
: >"$log"
say() { echo "$*" | tee -a "$log"; }

say "== the compiler: $("${botlish[@]}" -version | head -n 1)"

cd "$room/linux"
cat >app.bot <<'BOT'
import std::int
import std::io
import std::linux::io
import std::list
import std::mutable_vector
import std::str

context struct Frames:
    seen: MutableVector[int]

fn frames(n: int, total: int, context f: Frames) -> int:
    if n == 0:
        return total
    f.seen.push(n)
    frames(n - 1, total + n)

with context std::linux::io::create()
with context Frames {seen: std::mutable_vector::from_list([])}

args = argv():
    on InvalidArgumentEncoding:
        []
std::io::print_line("entry: ".concat(frames(100000, 0).to_string()).concat(", ").concat(std::list::length(args).to_string()).concat(" arguments")):
    on std::io::WriteFailed:
        unit
BOT
cat >host.c <<'C'
#include <pthread.h>
#include <stdio.h>
#include "app.h"
static void *run(void *unused) {
    (void)unused;
    char *argv[] = {"app", "one", "two", NULL};
    for (int i = 0; i < 2; i++) {
        app_error *error = NULL;
        int32_t status = app_main(3, argv, &error);
        printf("host: app_main %d\n", (int)status);
        fflush(stdout);
        app_error_release(&error);
    }
    return NULL;
}
int main(void) {
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, 1024 * 1024);
    pthread_t t;
    pthread_create(&t, &attr, run, NULL);
    pthread_join(t, NULL);
    return 0;
}
C
say "== Linux: -emit-native-library app -application"
"${botlish[@]}" -warnings error -emit-native-library app -application -out lib app.bot | tee -a "$log"
"${clean[@]}" cc -O1 -Wall -Werror -I lib -o host host.c lib/libapp.a -lgcc_s -lutil -lrt -lpthread -lm -ldl -lc
say "== Linux: the host"
./host 2>&1 | tee -a "$log"
say "== Linux: an external tool's view of the manifest"
python3 -I "$here/validate-manifest.py" lib/app.manifest.json | tee -a "$log"

if [[ -n $repo && -n ${ANDROID_NDK_ROOT:-} ]]; then
    mkdir -p "$room/android"
    cd "$room/android"
    printf '{"schema": 1, "dependencies": {}}\n' >botlish.json
    cp "$here/../android/android_log.bot" "$here/../android/hello.bot" .
    say "== Android: the target support package from the repository"
    "${botlish[@]}" add botlish_target_android_aarch64 -repository "$repo" -target android-aarch64 | tee -a "$log"
    say "== Android: -target android-aarch64 -emit-native-library hello -application"
    "${botlish[@]}" -warnings error -target android-aarch64 -target-support botlish_target_android_aarch64 \
        -emit-native-library hello -application -out lib hello.bot | sed "s|$room|ROOM|g" | tee -a "$log"
    readelf -hdlW lib/libhello.so | grep -E 'Machine|NEEDED|SONAME|TEXTREL|LOAD' | tee -a "$log"
    say "== Android: an external tool's view of the manifest"
    python3 -I "$here/validate-manifest.py" lib/hello.manifest.json | tee -a "$log"
fi
say "== done"
