#!/bin/bash
# emit-nir.sh SCRATCH FILE.bot OUT.nir: FILE's NIR, as main.tcl lowers it
# (-emit-nir with the native backend, which prints the NIR before the run).
source "$(dirname "$0")/common.sh"
cd "$REPO"
tclsh9.0 main.tcl -backend cranelift -emit-nir "$2" 2>/dev/null | sed -n '/^nir /,/^   value/p' | grep -v '^   value' > "$3"
