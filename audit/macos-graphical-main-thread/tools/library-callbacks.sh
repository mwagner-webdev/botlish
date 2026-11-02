#!/usr/bin/env bash
# library-callbacks.sh -- candidate C through the current native-library
# boundary (MACOS-GRAPHICAL-MAIN-THREAD-CENSUS.md, sections 19-20), on Linux,
# where native libraries exist (NATIVE-LIBRARY-MILESTONE-1.md: Linux glibc
# only; on macOS `-emit-native-library` is refused, which tools/census.py
# records).
#
#   tools/library-callbacks.sh TCLSH CHECKOUT SDL_PREFIX WORK
#
# Builds the Botlish library mtplib -- one export, `step(n)`, which
# allocates (a String) and recurses a little, so a collection can walk its
# frames on the host's stack -- and native/csdl_callbacks.c with
# -DMTP_BOTLISH_LIBRARY: SDL3's main callbacks own the process's main thread
# and its loop; SDL_AppInit makes one instance (mtplib_create, on that
# thread) and calls it, every SDL_AppIterate calls it, SDL_AppQuit destroys
# it. Runs it with SDL's dummy video driver (Linux has no Cocoa: this is
# EXECUTED-HEADLESS evidence of the library boundary under a host-owned
# lifecycle, never graphical evidence), plainly and under
# BOTLISH_NATIVE_GC_STRESS=1, and prints the MTP lines.
set -euo pipefail
tclsh=$1 checkout=$(cd "$2" && pwd) prefix=$(cd "$3" && pwd) work=$4
here=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$work/lib"
cat >"$work/lib/mtplib.bot" <<'BOT'
# mtplib.bot -- the export SDL3's callbacks call (tools/library-callbacks.sh).
import std::str

fn label(depth: int, s: str) -> str:
    if depth == 0:
        return s
    label(depth - 1, std::str::concat(s, "."))

# N plus the length of a String built by a short recursion: allocation and
# frames on the host's (SDL's main thread's) stack at every call.
exported c fn step(n: int) -> int:
    n + std::str::length(label(16, "frame"))
BOT
"$tclsh" "$checkout/main.tcl" -warnings off -emit-native-library mtplib -out "$work/lib/out" "$work/lib/mtplib.bot"
cc -c -O2 -I "$prefix/include" "$here/native/mtprobe.c" -o "$work/lib/mtprobe.o"
cc -c -O2 -I "$prefix/include" "$here/native/mtprobe_sdl.c" -o "$work/lib/mtprobe_sdl.o"
cc -O2 -DMTP_BOTLISH_LIBRARY -I "$prefix/include" -I "$work/lib/out" -o "$work/lib/callbacks-botlish" \
  "$here/native/csdl_callbacks.c" "$work/lib/mtprobe.o" "$work/lib/mtprobe_sdl.o" "$work/lib/out/libmtplib.a" \
  "$prefix/lib/libSDL3.a" -lgcc_s -lutil -lrt -lpthread -lm -ldl
for stress in 0 1; do
  echo "== SDL3 main callbacks calling mtplib_step (GC stress $stress)"
  set +e
  BOTLISH_NATIVE_GC_STRESS=$stress SDL_VIDEODRIVER=dummy "$work/lib/callbacks-botlish" 2>&1 | grep '^MTP' | grep -v '"kind":"mark","stage":"callback-iterate"' | cut -c 1-400
  echo "status ${PIPESTATUS[0]}"
  set -e
done
