#!/usr/bin/env tclsh9.0
# calltypes.tcl -- the semantic type of every reachable call of an ordinary
# block (an exact user or module function) in the 17 canonical programs, one
# line per call site, so the parent commit's and this tree's outputs can be
# diffed: which call results became more precise once semantic instances
# analyzed the callee under the call's concrete argument types. Observation
# only.
#
#   (cd TREE && tclsh9.0 audit/opportunistic-semantic-instances/tools/calltypes.tcl OUTFILE)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outfile
proc rel {path} {
    set root [pwd]
    if {[string first "$root/" $path] == 0} { return [string range $path [string length "$root/"] end] }
    return $path
}
set L {}
foreach path [concat [lsort [glob -directory [file join $root bench] *.bot]] \
        [lsort [glob -directory [file join $root examples stdlib] *.bot]]] {
    set hir [surface::readProgramFile $path -strict 0]
    lappend L "== [file tail $path]"
    set rows {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
        lassign [dict get $node target] kind t
        if {$kind ne "block"} continue
        set origin [dict get $node origin]
        if {[lindex $origin 0] ne "file"} continue
        set f [lrange $origin 2 end]
        set name [hir::signatures::Name $hir $t]
        lappend rows [list [dict get $f line] [dict get $f column] $name [hir::types::show [hir::typeOf $hir $e]]]
    }
    foreach r [lsort -integer -index 1 [lsort -integer -index 0 $rows]] {
        lappend L [format "%5d:%-3d %-24s : %s" {*}[lrange $r 0 1] [lindex $r 2] [lindex $r 3]]
    }
}
set f [open $outfile w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $outfile"
