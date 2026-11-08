#!/usr/bin/env bash
# cleanroom.sh -- the CSV exporter as a consumer builds it
# (CSV-EMISSION-VALIDATION-MILESTONE-1.md, section 15): the distributed
# single-file compiler (single/build.sh's single/out/botlish, or BOTLISH),
# run with an empty environment from a directory holding only the
# example's .bot files -- no checkout, no tclsh, no Rust, no emission tool
# -- builds examples/dfa/csv/export.bot as a standalone executable, which
# runs with nothing on PATH and writes its table; oracle.py (no Botlish)
# then checks the file.
#
#   audit/csv-emission/tools/cleanroom.sh [BOTLISH]
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
botlish=$(realpath "${1:-$root/single/out/botlish}")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/app" "$work/home"
cp "$root"/examples/dfa/csv/*.bot "$work/app/"
cd "$work/app"
echo "compiler: $botlish ($("$botlish" -version 2>&1 | head -1))"
env -i HOME="$work/home" PATH=/usr/bin:/bin LANG=C.UTF-8 "$botlish" -warnings error -emit-native-executable export.bot
env -i PATH=/nonexistent ./export "$work/table.csv"
python3 -I "$root/audit/csv-emission/tools/oracle.py" export "$work/table.csv"
