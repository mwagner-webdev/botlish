#!/usr/bin/env bash
# repository.sh -- the author's side of the clean room
# (SHARED-PACKAGE-DEPENDENCIES-MILESTONE-1.md): the repository directory OUT
# of published artifacts the consumer installs from.
#
#   repository.sh OUT
#
#   event_loop_linux 0.3.0   the driver's release (tools/package-repository.tcl,
#                            its recipe: both targets' adapter archives)
#   beats 1.0.0, probes 1.0.0   examples/event-loop/shared's two libraries,
#                            packed as their authors would (package pack)
#   event_loop_linux 0.4.0, future 1.0.0   a later driver and a library that
#                            locks it, for the negative case
#
# Needs a checkout with tclsh9.0 and the release recipe's toolchains (cc, ar,
# the AArch64 GNU cross compiler).
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
out=$(realpath -m "$1")
mkdir -p "$out"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
botlish() { tclsh9.0 "$root/main.tcl" "$@"; }
tclsh9.0 "$root/tools/package-repository.tcl" "$work/release" event_loop_linux >/dev/null 2>&1
cp "$work/release/event_loop_linux-0.3.0.botpkg" "$out/"
for name in beats probes; do
  botlish package pack "$root/examples/event-loop/shared/$name" -out "$out" >/dev/null
done
mkdir -p "$work/src/event_loop_linux" "$work/src/future"
cp -r "$root/packages/event_loop_linux/." "$work/src/event_loop_linux/"
sed -i 's/"0.3.0"/"0.4.0"/' "$work/src/event_loop_linux/botlish.json"
botlish package pack "$work/src/event_loop_linux" -out "$out" >/dev/null
cat > "$work/src/future/botlish.json" <<'JSON'
{"schema": 1, "name": "future", "version": "1.0.0", "dependencies": {"event_loop_linux": "0.4"}, "lock": {"event_loop_linux": "0.4.0"}}
JSON
printf 'import event_loop_linux\n\nfn now(context n: event_loop_linux::Native) -> int:\n    event_loop_linux::now_us()\n' > "$work/src/future/future.bot"
botlish package pack "$work/src/future" -out "$out" >/dev/null
ls "$out"
