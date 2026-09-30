#!/bin/sh
# differential.sh TREE MODE OUTDIR FILE.bot ... -- one differential.tcl process
# per program (see differential.tcl), summaries concatenated into
# OUTDIR/summary.txt in argument order.
tree=$1; mode=$2; out=$3; shift 3
here=$(dirname "$0")
rm -rf "$out"; mkdir -p "$out"
: > "$out/summary.txt"
for f in "$@"; do
    tclsh9.0 "$here/differential.tcl" -root "$tree" -mode "$mode" -out "$out" "$f" >/dev/null
    cat "$out/summary-$(basename "${f%.bot}").txt" >> "$out/summary.txt"
    rm "$out/summary-$(basename "${f%.bot}").txt"
done
