#!/usr/bin/env tclsh9.0
# typedsites.tcl -- the semantic type of every reachable call of a
# MutableArray/List primitive (and every call of an ordinary block) in the
# program's own source file(s), one line per site with its source location and
# enclosing function, for csv_geometric.bot and csv_records.bot. Observation
# only; runs against the tree it is started in (pwd is the root).
#
#   (cd TREE && tclsh9.0 audit/typed-mutarray-builder-refactor/tools/typedsites.tcl OUTFILE)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outfile
set prims {mutable_array_allocate mutable_array_get mutable_array_set mutable_array_copy mutable_array_freeze mutable_array_capacity list_get list_length}
# The enclosing function is the leading "NAME()" segment of the origin's node
# path (surface lowering names every function's subtree that way); a path
# without one is a module-level expression.
proc enclosing {hir e} {
    set origin [dict get $hir exprs $e origin]
    set nodePath [dict get [lrange $origin 2 end] node]
    if {[regexp {^([^()/]+)\(\)} $nodePath -> name]} { return $name }
    return "(top)"
}
set L {}
foreach name {csv_geometric csv_records} {
    set path [file join $root examples stdlib $name.bot]
    set hir [surface::readProgramFile $path -strict 0]
    lappend L "== $name.bot"
    set rows {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
        set origin [dict get $node origin]
        if {[lindex $origin 0] ne "file"} continue
        set f [lrange $origin 2 end]
        lassign [dict get $node target] tk t
        if {$tk eq "native"} {
            set callee [dict get $hir exprs [dict get $node callee]]
            set cname [dict get $callee name]
            if {$cname ni $prims} continue
        } elseif {$tk eq "block"} {
            set cname [hir::signatures::Name $hir $t]
            # ordinary block calls and library create: keep all
        } else continue
        set loc [surface::originLocation $hir [dict get $node origin]]
        if {![string match "*/$name.bot:*" $loc]} continue
        lappend rows [list [dict get $f line] [dict get $f column] $cname [hir::types::show [hir::typeOf $hir $e]] [enclosing $hir $e]]
    }
    foreach r [lsort -integer -index 1 [lsort -integer -index 0 $rows]] {
        lassign $r line col cname type fn
        lappend L [format "%5d:%-3d %-22s %-22s : %s" $line $col $fn $cname $type]
    }
}
set fh [open $outfile w]
puts $fh [join $L \n]
close $fh
puts "wrote $outfile"
