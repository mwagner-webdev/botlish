#!/usr/bin/env tclsh9.0
# census.tcl -- the NIR census and the transport (representation) census of
# every canonical program (bench/*.bot and examples/stdlib/*.bot), for
# VALUE-TRANSPORT-MATERIALIZATION.md. Observation only: runs against whatever
# tree it is started in (pwd is the root); a tree without the transport
# census (the previous milestone) reports the NIR rows only.
#
#   (cd TREE && tclsh9.0 audit/value-transport-materialization/tools/census.tcl OUTFILE)
#
# Per program, with the structs unoptimized (-struct-opt 0), under the legacy
# width-only policy (-struct-policy legacy, where it exists) and under the
# default policy: structnew, structget, call, callmulti, retmulti, functions,
# guards, NIR lines and machine-code bytes; then, for the default policy, the
# transport census text and the aggregate metrics.
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
set hasTransport [expr {[llength [info commands native::transportCensus]] > 0}]
set modes [list off {-struct-opt 0}]
if {$hasTransport} { lappend modes legacy {-struct-policy legacy} }
lappend modes on {}

set out {}
set totals [dict create]
set metricTotals [dict create]
set paths [concat [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]
foreach path $paths {
    set name [file rootname [file tail $path]]
    set hir [native::prepareHir [surface::readProgramFile $path]]
    foreach {mode opts} $modes {
        set row [nirRow $hir {*}$opts]
        lappend out "ROW $name $mode [join [lmap c $cols {dict get $row $c}] { }]"
        foreach c $cols { dict incr totals $mode.$c [dict get $row $c] }
    }
    if {$hasTransport} {
        set census [native::transportCensus $hir]
        lappend out "== $name"
        lappend out [native::transportCensusText $hir]
        dict for {k v} [dict get $census metrics] {
            if {[string is integer -strict $v]} {
                dict incr metricTotals $k $v
            } elseif {$k in {frontier distance causes}} {
                dict for {kk vv} $v { dict incr metricTotals $k:$kk $vv }
            }
        }
        foreach rec [dict get $census records] {
            dict with rec {
                set what $class
                if {$class eq "materialized"} { append what ":$reason" }
                lappend out "SITE $name $label $expr width=$width $what frontier=$frontier mats=[join $mats ,]"
            }
        }
    } else {
        foreach rec [dict get [native::lowered $hir] structCensus] {
            dict with rec {
                set what $class
                if {$class eq "materialized"} { append what ":$reason" }
                lappend out "SITE $name $label $expr width=$width $what mats=[join $mats ,]"
            }
        }
    }
}
lappend out "COLUMNS [join $cols { }]"
foreach {mode opts} $modes {
    lappend out "TOTAL $mode [join [lmap c $cols {dict get $totals $mode.$c}] { }]"
}
lappend out "METRIC-TOTALS [lsort -stride 2 $metricTotals]"
set f [open $outfile w]
fconfigure $f -encoding utf-8
puts $f [join $out \n]
close $f
puts "wrote $outfile"
