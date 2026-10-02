#!/usr/bin/env tclsh9.0
# emit-nir.tcl -- emits the NIR of the canonical corpus under the four
# short-String configurations, from the checkout at ROOT (so the same script
# run in the parent commit's checkout and in this one yields NIR that can be
# compared byte for byte: the String storage change is below NIR).
#
#   tclsh9.0 audit/string-allocation/tools/emit-nir.tcl ROOT OUTDIR
#
# Writes OUTDIR/<program>.<config>.nir; configs: default, off
# (-short-string-opt 0), ascii0 (-ascii-pack-opt 0), demand0 (-short-demand-opt 0).
lassign $argv root out
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
file mkdir $out
set programs {}
foreach name {fib lex-strategy loop-count refined-checks source-checks sum-refined test-selection uri-steady} {
    lappend programs [file join $root bench $name.bot]
}
foreach name {ai_text_clean csv csv_chunked csv_geometric csv_records hashtable matmul string_replace string_reverse} {
    lappend programs [file join $root examples stdlib $name.bot]
}
array set configs {
    default {}
    off {-short-string-opt 0}
    ascii0 {-ascii-pack-opt 0}
    demand0 {-short-demand-opt 0}
}
foreach path $programs {
    set name [file rootname [file tail $path]]
    set hir [surface::readProgramFile $path]
    foreach cfg {default off ascii0 demand0} {
        set f [open [file join $out $name.$cfg.nir] w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f [native::nir $hir {*}$configs($cfg)]
        close $f
    }
    puts "$name"
    flush stdout
}
