#!/usr/bin/env tclsh9.0
# positional.tcl -- STRUCTS.md's census of positional products: Lists used as
# fixed-shape records. Observation only; runs against the tree it is started
# in (pwd is the root), so one script measures "before" and "after".
#
#   (cd TREE && tclsh9.0 audit/structs/tools/positional.tcl OUTFILE)
#
# Programs: bench/*.bot, examples/stdlib/*.bot, examples/surface/*.bot and
# every lib/*.bot module they load (a source location counts once).
#
# Sections (semantic types of the source HIR, before specialization):
#   literals   every list literal of two or more elements, with the static
#              type of each element and whether the element types agree
#   reads      every list_get whose index is an integer literal, with the
#              receiver's static type and the result type; "lost" when the
#              receiver is List[any] (the positional slot type is gone)
#   structs    every struct literal / projection (after the refactor)
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
set programs [concat \
    [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]] \
    [lsort [glob -directory [file join $root examples surface] *.bot]]]

proc siteKey {hir e} {
    set origin [hir::get $hir $e origin]
    if {[lindex $origin 0] ne "file"} { return "" }
    set f [lrange $origin 2 end]
    return "[rel [dict get [hir::sourceFile $hir [lindex $origin 1]] path]]:[dict get $f line]:[dict get $f column]"
}
proc T {hir e} { hir::types::show [hir::typeOf $hir $e] }
proc nativeName {hir e} {
    lassign [hir::get $hir $e target] kind t
    if {$kind eq "native"} { return [dict get [hir::symbol $hir $t] name] }
    return ""
}

set literals [dict create]; set reads [dict create]; set structs [dict create]
foreach path $programs {
    if {[catch {surface::readProgramFile $path -strict 0} hir]} { puts stderr "[rel $path]: $hir"; continue }
    dict for {e node} [dict get $hir exprs] {
        if {![hir::get $hir $e reachable]} continue
        set key [siteKey $hir $e]
        if {$key eq ""} continue
        set kind [dict get $node kind]
        if {$kind eq "struct"} { dict set structs $key "struct literal : [T $hir $e]" }
        if {$kind eq "project"} { dict set structs $key "projection .[dict get $node name] : [T $hir $e]" }
        if {$kind ne "call"} continue
        set name [nativeName $hir $e]
        set args [hir::get $hir $e args]
        if {$name eq "list" && [llength $args] >= 2} {
            set ts [lmap a $args {T $hir $a}]
            set same [expr {[llength [lsort -unique $ts]] == 1 ? "homogeneous" : "HETEROGENEOUS"}]
            dict set literals $key "[llength $args] elements $same : [join $ts { | }]"
        }
        if {$name eq "list_get"} {
            set idx [lindex $args 1]
            if {[hir::kind $hir $idx] ne "const"} continue
            set recv [T $hir [lindex $args 0]]
            set lost [expr {$recv in {List[any] list any} ? "lost" : "kept"}]
            dict set reads $key "list_get(receiver $recv, index [hir::get $hir $idx value]) -> [T $hir $e] ($lost)"
        }
    }
}
set out [open $outfile w]
fconfigure $out -encoding utf-8
proc emit {out title d} {
    puts $out "## $title"
    foreach k [lsort -dictionary [dict keys $d]] { puts $out "$k | [dict get $d $k]" }
    puts $out "# [dict size $d]"
    puts $out ""
}
emit $out "list literals of two or more elements" $literals
set het 0
dict for {k v} $literals { if {[string match *HETEROGENEOUS* $v]} { incr het } }
puts $out "# heterogeneous literals: $het of [dict size $literals]"
puts $out ""
emit $out "list_get with a literal index" $reads
set lost 0
dict for {k v} $reads { if {[string match *(lost) $v]} { incr lost } }
puts $out "# literal-index reads whose receiver type lost its element types: $lost of [dict size $reads]"
puts $out ""
emit $out "struct literals and projections" $structs
close $out
