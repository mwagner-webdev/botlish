#!/bin/sh
# build.sh -- prepare examples/threads/broker to run: install the Linux
# event-loop driver package into its .bot_modules (tools/event-loop-
# linux.tcl) and build the device's archive (native/libdevice.a) with the
# host's C compiler. Both are build products, never committed. Then:
#
#   tclsh9.0 ../../../main.tcl run main.bot
#   tclsh9.0 ../../../main.tcl -emit-native-executable main main.bot && ./main
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
cc=${CC:-cc}
tclsh9.0 "$root/tools/event-loop-linux.tcl" install "$here"
"$cc" -O2 -Wall -Wextra -Werror -fPIC -c "$here/native/device.c" -o "$here/native/device.o"
ar rcs "$here/native/libdevice.a" "$here/native/device.o"
rm -f "$here/native/device.o"
