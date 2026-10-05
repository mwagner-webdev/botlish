#!/usr/bin/env tclsh9.0
# lowerall.tcl -- RANGE-FIXPOINT-SCALING.md: lowers every bench/*.bot and
# examples/*/*.bot file to NIR, specialized and generic, printing one line
# per file and mode (ok, lower-fail, or skip for a file the frontend
# rejects). Run from the root of the tree to lower, with dump.tcl installed
# there, to record the outputs ("bot" suite).
#
#   tclsh9.0 audit/range-fixpoint-scaling/tools/lowerall.tcl
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set files [lsort [concat [glob -nocomplain $root/bench/*.bot] [glob -nocomplain $root/examples/*/*.bot]]]
foreach path $files {
    set name [string range $path [string length $root/] end]
    if {[catch {surface::readProgramFile $path -warnings off} hir]} {
        puts "skip $name: [string range $hir 0 80]"
        continue
    }
    foreach specialize {1 0} {
        if {[catch {native::lowered $hir -specialize $specialize} message]} {
            puts "lower-fail $name $specialize: [string range $message 0 80]"
        } else {
            puts "ok $name $specialize"
        }
    }
}
