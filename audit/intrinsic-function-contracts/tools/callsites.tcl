#!/usr/bin/env tclsh9.0
# callsites.tcl -- INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md's callable-site
# census: every compiled `callvalue` site of the canonical benchmarks
# (relifted pipeline, exactly as bench/bench.tcl compiles), with the
# callee expression's type in the source (whole-program) HIR and in the
# used specialization instance that compiles it, classified as
#
#   structural Fn | bare block/native | exact | any
#
# plus the call's own result type, its HIR target and the function's
# instance label. Observation only; runs against whatever tree it is
# started in, so the same script measures the parent commit and this one:
#
#   (cd TREE && tclsh9.0 audit/intrinsic-function-contracts/tools/callsites.tcl OUTFILE)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv out

proc classify {t} {
    if {[hir::types::IsFn $t]} { return "structural Fn" }
    if {$t in {block native}} { return "bare block/native" }
    if {[hir::types::IsExactBlock $t] || [hir::types::IsExactNative $t]} { return "exact" }
    if {$t eq "any"} { return "any" }
    return "other ($t)"
}

set L {}
lappend L "tree: [exec git -C $root rev-parse HEAD] (plus any uncommitted working-tree changes)"
lappend L ""
set counts [dict create]
set total 0
foreach path [lsort [glob -directory [file join $root bench] *.bot]] {
    set hir [native::prepareHir [surface::readProgramFile $path]]
    set spec [hir::specialize::analyze $hir]
    set labels [dict create]
    foreach id [dict get $spec used] {
        dict set labels [hir::specialize::label $spec $id] $id
    }
    set nir [dict get [native::lower::program $hir] text]
    set func ""
    foreach line [split $nir \n] {
        if {[regexp {^func (\d+) "([^"]*)".* instance="([^"]*)"} $line -> fid fname inst]} {
            set func "$fname<$inst>"
            if {$fname eq "<program>"} { set func "<program>" }
        }
        if {![regexp {= callvalue .*@(e\d+)} $line -> e]} continue
        incr total
        set callee [hir::get $hir $e callee]
        set source [hir::typeOf $hir $callee]
        set instLine "(instance not found)"
        set instType ""
        set instResult ""
        if {[dict exists $labels $func]} {
            set view [hir::specialize::view $hir $spec [dict get $labels $func]]
            set instType [hir::typeOf $view $callee]
            set instResult [hir::typeOf $view $e]
        }
        set class [classify [expr {$instType eq "" ? $source : $instType}]]
        dict incr counts $class
        lappend L "[file tail $path] $func @$e"
        lappend L "    source callee type:   [hir::types::show $source]"
        lappend L "    instance callee type: [expr {$instType eq "" ? "?" : [hir::types::show $instType]}]   => $class"
        lappend L "    source call result:   [hir::types::show [hir::typeOf $hir $e]]; instance: [expr {$instResult eq "" ? "?" : [hir::types::show $instResult]}]"
        lappend L "    HIR target: \"[hir::get $hir $e target]\"   calleeErrors: [list [hir::get $hir $e calleeErrors]]"
    }
}
lappend L ""
lappend L "total callvalue sites: $total"
dict for {k v} $counts { lappend L "  $k: $v" }
set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $out"
