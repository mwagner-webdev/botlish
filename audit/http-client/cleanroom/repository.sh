#!/usr/bin/env bash
# repository.sh -- the author's side of the HTTP clean room
# (HTTP-CLIENT-PACKAGE-MILESTONE-1.md, section 14): the repository directory
# OUT of published artifacts the consumer installs from.
#
#   repository.sh OUT [RELEASES]
#
#   boringssl 0.20261020.0, event_loop_linux 0.5.0, http 0.2.0
#       the releases: copied from the directory RELEASES when given (the
#       pinned author image's build: tools/package-build/author.sh build
#       RELEASES -release boringssl event_loop_linux http), else made here by
#       tools/package-repository.tcl
#   feeds 1.0.0
#       audit/http-client/cleanroom/feeds, a library written apart from
#       http that uses it and the driver, packed as its author would
#       (package pack)
#   oldtls 1.0.0
#       a library locking another BoringSSL release, for the negative case:
#       a program cannot hold two providers
#
# Needs a checkout with tclsh9.0 and, without RELEASES, the http recipe's
# toolchain (tools/http-package.tcl: cmake, ninja, cc, c++, cargo).
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
out=$(realpath -m "$1")
releases=${2:-}
mkdir -p "$out"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
botlish() { tclsh9.0 "$root/main.tcl" "$@"; }
if [[ -n $releases ]]; then
  for f in boringssl-0.20261020.0 event_loop_linux-0.5.0 http-0.2.0; do
    cp "$releases/$f.botpkg" "$out/"
    [[ -f $releases/$f.provenance.json ]] && cp "$releases/$f.provenance.json" "$out/"
  done
else
  tclsh9.0 "$root/tools/package-repository.tcl" "$work/release" boringssl event_loop_linux http >/dev/null
  cp "$work"/release/*.botpkg "$work"/release/*.provenance.json "$out/"
fi
botlish package pack "$root/audit/http-client/cleanroom/feeds" -out "$out" >/dev/null
mkdir -p "$work/src/oldtls"
cat > "$work/src/oldtls/botlish.json" <<'JSON'
{"schema": 1, "name": "oldtls", "version": "1.0.0", "dependencies": {"boringssl": "0.20250101"}, "lock": {"boringssl": "0.20250101.0"}}
JSON
printf 'import boringssl\n\nfn pinned() -> str:\n    boringssl::pin()\n' > "$work/src/oldtls/oldtls.bot"
botlish package pack "$work/src/oldtls" -out "$out" >/dev/null
sha256sum "$out"/*.botpkg
