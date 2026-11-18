#!/bin/sh
# run.sh -- runs a probe of RN-OFFLINE-DOMAIN-ARCHITECTURE-CENSUS-MILESTONE-1.md
# on every backend and requires one value: `audit/rn-offline-domain/probes/
# run.sh PROBE.bot` from the repository root.
set -eu
export LANG=C.utf8 LC_ALL=C.utf8
probe=$1
first=
for b in interp compile cranelift cranelift-generic; do
    v=$(tclsh9.0 main.tcl -warnings error -backend "$b" "$probe" 2>&1 | grep '^   value: ' || true)
    if [ -z "$v" ]; then
        echo "$b: no value"; tclsh9.0 main.tcl -warnings error -backend "$b" "$probe" 2>&1 | tail -5; exit 1
    fi
    echo "$b: $v"
    if [ -z "$first" ]; then first=$v; elif [ "$v" != "$first" ]; then echo "DISAGREE"; exit 1; fi
done
echo "agree on 4 backends"
