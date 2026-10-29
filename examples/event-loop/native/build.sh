#!/bin/sh
# build.sh -- prepare examples/event-loop/native to run: install the Linux
# event-loop driver package into its .bot_modules (tools/event-loop-linux.tcl)
# and build the ticker's archive (libticker.a) beside it, with the host's C
# compiler. Both are build products, never committed.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
cc=${CC:-cc}
tclsh9.0 "$root/tools/event-loop-linux.tcl" install "$here"
"$cc" -O2 -Wall -Wextra -Werror -fPIC -pthread -I"$root/packages/event_loop_linux/native" -c "$here/ticker.c" -o "$here/ticker.o"
ar rcs "$here/libticker.a" "$here/ticker.o"
rm -f "$here/ticker.o"
