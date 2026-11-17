#!/bin/sh
# run.sh -- probe A of RN-OFFLINE-DOMAIN-ARCHITECTURE-CENSUS-MILESTONE-1.md:
#
#   audit/rn-offline-domain/probes/outbox/run.sh SQLITE.botpkg
#
# from the repository root, with a built native backend and python3. Installs
# the sqlite package (github.com/mwagner-webdev/sqlite-botpkg 0.1.0: its
# scripts/pack.sh makes the .botpkg) into a fresh project in a temporary
# directory, builds outbox.bot as an executable, runs the census's scenario
# one step per process and compares every step's output and the database as
# Python's sqlite3 reads it with the expected transcript. Exit status 0 when
# they are equal.
set -eu
export LANG=C.utf8 LC_ALL=C.utf8
pkg=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
root=$(pwd)
here=$root/audit/rn-offline-domain/probes/outbox
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
bot() { tclsh9.0 "$root/main.tcl" "$@"; }
cd "$work"
printf '{\n  "schema": 1,\n  "name": "outbox_probe",\n  "version": "0.1.0"\n}\n' > botlish.json
bot add "$pkg" > /dev/null
cp "$here/outbox.bot" .
bot -warnings error -emit-native-executable outbox.bot > /dev/null
db=$work/pets.db
step() {
    out=$(./outbox "$db" "$@" 2>/dev/null) || out="died ($?)"
    echo "$* -> $out"
    python3 -I "$here/inspect.py" "$db" | sed 's/^/    /'
}
{
    step init
    step edit 1 "Milo Jr." available
    step edit 1 "Milo III" pending crash
    step edit 1 "Milo III" pending
    step send 1
    step edit 1 "Milo IV" pending
    step confirm 1 2
    step send 1
    step recover
    rm -f "$db" "$db-journal"
    step init
    step edit 1 Rex sold
    step send 1
    step confirm 1 2
} > transcript.txt
cat transcript.txt
if diff -u "$here/expected.txt" transcript.txt; then echo "probe A: transcript as expected"; else echo "probe A: TRANSCRIPT DIFFERS"; exit 1; fi
