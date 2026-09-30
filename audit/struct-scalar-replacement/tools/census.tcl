#!/usr/bin/env tclsh9.0
# census.tcl -- the materialization census and NIR census of every canonical
# program (bench/*.bot and examples/stdlib/*.bot), for STRUCT-SCALAR-
# REPLACEMENT.md. Observation only: runs against whatever tree it is started
# in (pwd is the root).
#
#   (cd TREE && tclsh9.0 audit/struct-scalar-replacement/tools/census.tcl OUTFILE)
#
# Per program, twice -- with struct scalar replacement on (the default) and
# off (-struct-opt 0, which is the structs milestone's lowering): the NIR
# statement counts the structs report used (structnew, structget, call,
# callmulti, retmulti, guards, functions, NIR lines, machine-code bytes) and,
# for the "on" run, one line per struct construction (semantic instance x
# source site) saying what became of it, and a summary by class and reason.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000
lassign $argv outfile

proc count {text rx} { return [regexp -all -line $rx $text] }

set cols {structnew structget listnew listget guards call callmulti callvalue retmulti functions lines bytes}
proc nirRow {hir args} {
    set lowered [native::lowered $hir {*}$args]
    set text [dict get $lowered text]
    return [dict create \
        structnew [count $text {= structnew }] structget [count $text {= structget }] \
        listnew [count $text {= op listnew\y}] listget [count $text {= op listget\y|= listget\y}] \
        guards [count $text {^\s+guard(bool)? }] call [count $text {= call }] \
        callmulti [count $text {= callmulti }] callvalue [count $text {= callvalue }] \
        retmulti [count $text {^\s+retmulti }] functions [count $text {^func }] \
        lines [expr {[llength [split $text \n]] - 1}] bytes [lindex [native::codeSize $hir {*}$args] 0]]
}

set out {}
set totals [dict create on {} off {}]
set classTotals [dict create]
set reasonTotals [dict create]
set paths [concat [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]
foreach path $paths {
    set name [file rootname [file tail $path]]
    set hir [native::prepareHir [surface::readProgramFile $path]]
    foreach mode {off on} {
        set row [nirRow $hir {*}[expr {$mode eq "off" ? {-struct-opt 0} : {}}]]
        lappend out "ROW $name $mode [join [lmap c $cols {dict get $row $c}] { }]"
        foreach c $cols { dict incr totals $mode.$c [dict get $row $c] }
    }
    set lowered [native::lowered $hir]
    foreach rec [dict get $lowered structCensus] {
        dict with rec {
            set what $class
            if {$class eq "materialized"} { append what ":$reason" }
            lappend out "SITE $name $label $expr width=$width $what mats=[join $mats ,]"
            dict incr classTotals $class
            if {$class eq "materialized"} { dict incr reasonTotals $reason }
            foreach m $mats { dict incr reasonTotals "+$m" }
        }
    }
}
lappend out "COLUMNS [join $cols { }]"
foreach mode {off on} {
    lappend out "TOTAL $mode [join [lmap c $cols {dict get $totals $mode.$c}] { }]"
}
lappend out "CLASSES [dict get [dict create {*}[lsort -stride 2 $classTotals]]]"
lappend out "REASONS [dict get [dict create {*}[lsort -stride 2 $reasonTotals]]]"
set f [open $outfile w]
fconfigure $f -encoding utf-8
puts $f [join $out \n]
close $f
puts "wrote $outfile"
