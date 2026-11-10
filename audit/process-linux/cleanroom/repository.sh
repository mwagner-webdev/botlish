#!/usr/bin/env bash
# repository.sh -- the author's side of the process_linux clean room
# (PROCESS-LINUX-PACKAGE-MILESTONE-1.md, "Clean room"): the repository
# directory OUT of published artifacts the consumer installs from.
#
#   repository.sh OUT [RELEASES]
#
#   process_linux 0.1.0, event_loop_linux 0.5.0
#       the releases: copied from the directory RELEASES when given (the
#       pinned author image's build: tools/package-build/author.sh build
#       RELEASES -release process_linux event_loop_linux), else made here by
#       tools/package-repository.tcl (event_loop_linux's recipe needs the
#       AArch64 cross compiler too)
#   ticker 1.0.0
#       audit/process-linux/cleanroom/ticker, a library written apart from
#       process_linux that depends on the driver independently, packed as
#       its author would (package pack)
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
out=$(realpath -m "$1")
releases=${2:-}
mkdir -p "$out"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
botlish() { tclsh9.0 "$root/main.tcl" "$@"; }
if [[ -n $releases ]]; then
  for f in process_linux-0.1.0 event_loop_linux-0.5.0; do
    cp "$releases/$f.botpkg" "$out/"
    [[ -f $releases/$f.provenance.json ]] && cp "$releases/$f.provenance.json" "$out/"
  done
else
  tclsh9.0 "$root/tools/package-repository.tcl" "$work/release" process_linux event_loop_linux >/dev/null
  cp "$work"/release/*.botpkg "$work"/release/*.provenance.json "$out/"
fi
botlish package pack "$root/audit/process-linux/cleanroom/ticker" -out "$out" >/dev/null
sha256sum "$out"/*.botpkg
