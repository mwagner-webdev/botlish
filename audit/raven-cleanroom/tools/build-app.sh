#!/usr/bin/env bash
# build-app.sh -- build a Raven application as a consumer would, in the clean
# room (RAVEN-CLEANROOM-DESKTOP-MILESTONE-1.md), and pack it for shipping.
#
#   build-app.sh COMPILER BOTPKG SRC NAME TITLE OUT
#
# A fresh clean-room container (tools/cleanroom.sh start: no network,
# nothing mounted, only the single-file compiler COMPILER and the release
# BOTPKG) gets SRC's *.bot files as /home/dev/app, and there, as the user
# dev, with nothing but the compiler:
#
#   botlish add BOTPKG                       the package, no build
#   botlish -backend cranelift test.bot      when SRC has one: its value is
#                                            printed into the build log
#   botlish native deploy -out NAME          NAME/lib/libraven.so.0
#   botlish -emit-native-executable -runtime-path '$ORIGIN/lib' main.bot
#                                            NAME/NAME, which finds lib/
#                                            beside itself
#   a smoke run of NAME/NAME on a virtual display: its window (titled
#   TITLE) found through the X server, closed as a window manager does,
#   the program ending with status 0
#
# OUT receives NAME-linux-x86_64.tar.gz (the executable, its library, the
# sources it was built from and a README.txt; a tarball keeps the
# executable's mode) and build.log (every command and its output). Exit
# status 0 when every step succeeded.
set -euo pipefail

[[ $# == 6 ]] || { sed -n '2,/^set -euo/p' "$0" | sed 's/^# \{0,1\}//;$d' >&2; exit 2; }
compiler=$(realpath "$1")
botpkg=$(realpath "$2")
src=$(realpath "$3")
name=$4
title=$5
out=$(realpath -m "$6")
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p "$out"
container=botlish-raven-build-$$
"$here/cleanroom.sh" start "$compiler" "$botpkg" "$container" >/dev/null
trap 'docker rm -f "$container" >/dev/null 2>&1 || true' EXIT

stage=$(mktemp -d)
trap 'docker rm -f "$container" >/dev/null 2>&1 || true; rm -rf "$stage"' EXIT
mkdir -p "$stage/app" "$stage/harness"
cp "$src"/*.bot "$stage/app/"
cp "$here/xsession.py" "$here/../acceptance/build-inside.sh" "$stage/harness/"
docker cp "$stage/app" "$container:/home/dev/app"
docker cp "$stage/harness" "$container:/home/dev/harness"
docker exec -u root "$container" chown -R dev:dev /home/dev

docker exec -u dev -e NAME="$name" -e TITLE="$title" "$container" bash /home/dev/harness/build-inside.sh \
  || { docker cp "$container:/home/dev/build.log" "$out/build.log" 2>/dev/null || true; cat "$out/build.log" 2>/dev/null | tail -30; exit 1; }

docker cp "$container:/home/dev/$name-linux-x86_64.tar.gz" "$out/"
docker cp "$container:/home/dev/build.log" "$out/build.log"
echo "$out/$name-linux-x86_64.tar.gz"
