#!/bin/sh
# build.sh -- prepare audit/managed-subprocess/slice to run (the census
# MANAGED-SUBPROCESS-AND-EVENT-LOOP-CENSUS-MILESTONE-1.md): install the Linux
# event-loop driver package into its .bot_modules (tools/event-loop-linux.tcl),
# build the experimental adapter's archive (native/libmsp.a) and the helper
# child (bin/msp-child) with the host's C compiler. Build products, never
# committed (../.gitignore).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
cc=${CC:-cc}
tclsh9.0 "$root/tools/event-loop-linux.tcl" install "$here" >/dev/null
mkdir -p "$here/native" "$here/bin"
"$cc" -O2 -Wall -Wextra -Werror -fPIC -pthread -c "$here/../native/msp.c" -o "$here/native/msp.o"
ar rcs "$here/native/libmsp.a" "$here/native/msp.o"
rm -f "$here/native/msp.o"
"$cc" -O2 -Wall -Wextra -Werror "$here/../helper/msp-child.c" -o "$here/bin/msp-child"
echo "$here"
