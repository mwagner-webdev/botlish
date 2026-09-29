#!/usr/bin/env tclsh9.0
# validity.tcl -- which canonical source programs (bench/*.bot,
# examples/stdlib/*.bot, examples/surface/*.bot) the tree it runs in
# rejects at compile time, with every diagnostic. Used for
# INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md's design-variant evidence: run in
# the implemented tree (out/validity-implemented.txt) and in scratch copies
# with out/variant-*.patch applied (out/variant-*.txt). The declared-error
# example 10-duplicate-binding.bot is skipped.
#
#   (cd TREE && tclsh9.0 audit/intrinsic-function-contracts/tools/validity.tcl)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set programs [concat [lsort [glob -directory [file join $root bench] *.bot]] [lsort [glob -directory [file join $root examples stdlib] *.bot]] [lsort [glob -directory [file join $root examples surface] *.bot]]]
set bad 0
foreach path $programs {
    set hir [surface::readProgramFile $path -strict 0]
    set ds [hir::diagnostics $hir]
    if {[file tail $path] eq "10-duplicate-binding.bot"} { continue }
    if {$ds ne {}} {
        incr bad
        puts "[file tail $path]: [llength $ds] diagnostic(s)"
        foreach d $ds { puts "    [surface::originLocation $hir [hir::get $hir [dict get $d expr] origin]]: [dict get $d message]" }
    }
}
puts "programs with diagnostics: $bad of [llength $programs]"
