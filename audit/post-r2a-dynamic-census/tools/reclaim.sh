#!/usr/bin/env bash
# reclaim.sh -- deferred reclamation cost (POST-R2A-DYNAMIC-CENSUS.md): the
# between-run Vm::reset, which frees every object the previous run
# allocated and which both the timed runs and profile-nir.sh's collected
# region exclude, measured on its own via this census's audit-native.patch
# botlish_audit_reset frame. Observation only.
#
#   bash audit/post-r2a-dynamic-census/tools/reclaim.sh AUDIT-BIN PROD-BIN NAME=FILE.nir ...
#
# Prints a Markdown row per program: objects the run allocates
# (allocation report), Ir per reset (20 resets of `bench 21`), Ir per object.
set -eu
bin=${1:?usage}; prod=${2:?usage}; shift 2
export LANG=C.utf8 LC_ALL=C.utf8
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
echo "| program | objects reclaimed per reset | Ir per reset | Ir per reclaimed object |"
echo "|---|---:|---:|---:|"
for arg in "$@"; do
    name=${arg%%=*}; nir=${arg#*=}
    valgrind --tool=callgrind --toggle-collect=botlish_audit_reset --callgrind-out-file="$tmp/cg.out" \
        "$bin" bench 21 "$nir" > /dev/null 2> "$tmp/log"
    ir=$(grep '^summary' "$tmp/cg.out" | awk '{print $2}')
    objs=$("$prod" run "$nir" --alloc summary | grep -o 'total {allocations [0-9]*' | awk '{print $3}')
    python3 -c "ir=$ir/20; o=$objs; print(f'| $name | {o:,} | {ir:,.0f} | {ir/o if o else 0:,.1f} |')"
done
